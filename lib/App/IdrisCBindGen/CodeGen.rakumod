unit module App::IdrisCBindGen::CodeGen;

use App::IdrisCBindGen::FFITypes;


#! mangle C name to be idris identifier
sub mangle (Str $name --> Str) { $name } # TODO: make it work

proto gimme-some-args (Int $argc where * >= 0 --> Str) {*}
multi gimme-some-args (0) { '' }
multi gimme-some-args ($argc) {
    my $i = $argc - 1;
    samewith($i) ~ " a$i"
}

constant $IDRIS_PRELUDE = q:to/EOF/;
interface WrapIO a b | a where
   wrapIO : a -> b

Cast rb ra => WrapIO a b => WrapIO (ra -> a) (rb -> b) where
   wrapIO f x = wrapIO (f (cast x))

Cast a b => HasIO io => WrapIO (PrimIO a) (io b) where
   wrapIO p = do
      va <- primIO p
      pure (cast va)


Cast Bits8 Bool where
   cast 0 = True
   cast _ = False

Cast Bool Bits8 where
   cast True = 1
   cast False = 0
EOF


class BindingsGenerator_Easy is export {
    has Str $.module_name;
    has Str $.monad_name;
    has Str $.c_lib_name;
    has Function @.functions;

    #| generate idris module file
    method generate-full(--> Str) {
        my $r = '';
        $r ~= qq:to/EOF/;
        module $!module_name

        CFFI : String -> String
        CFFI fname = "C:" ++ fname ++ ",$!c_lib_name"


        EOF
        $r ~= $IDRIS_PRELUDE;
        
        $r ~= "\n\n";

        for @!functions -> $f {
            my $fname = $f.c_name.&mangle;
            $r ~= qq:to/EOF/;
            %foreign CFFI "$f.c_name()"
            prim__$fname : $f.type-primio()

            EOF            
        }

        $r ~= "\n";

        $r ~= qq:to/EOF/;
        public export
        data $!monad_name : Type -> Type where
        EOF
        for @!functions -> $f {
            my $fname = $f.c_name.&mangle;
            $r ~= qq:to/EOF/;
              $fname : $f.type-monad($!monad_name)
            EOF            
        }
        
        $r ~= "\n\n";

        $r ~= qq:to/EOF/;
        export
        handleWithIO : HasIO io => $!monad_name a -> io a
        EOF
        for @!functions -> $f {
            my $fname = $f.c_name.&mangle;
            my $arg-list = gimme-some-args($f.args.elems);
            $r ~= qq:to/EOF/;
            handleWithIO ($fname$arg-list) = (wrapIO prim__$fname)$arg-list
            EOF
        }
        
        $r
    }
}
