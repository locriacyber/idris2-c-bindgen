unit module App::IdrisCBindGen::FFITypes;

multi get_ffi_type_name ('Int') { 'Int' }
multi get_ffi_type_name ('String') { 'String' }
multi get_ffi_type_name ('Bool') { 'Bits8' }
multi get_ffi_type_name ('()') { '()' }

class Type is export {
    has Str $.idr_name;
    has Str $.idr_ffi_name;

    submethod from_idris_name (Str $name) is export {
        Type.new(
            idr_name => $name,
            idr_ffi_name => get_ffi_type_name($name),
        )
    }
}

class Function is export {
    has Str $.c_name;
    has Type @.args;
    has Type $.ret;

    method type-primio (--> Str) {
        my $r = '';
        for @!args -> $arg {
            $r ~= "$arg.idr_ffi_name() -> ";
        }
        $r ~= "PrimIO $!ret.idr_ffi_name()";
        $r
    }

    method type-monad (Str $m --> Str) {
        my $r = '';
        for @!args -> $arg {
            $r ~= "$arg.idr_name() -> ";
        }
        $r ~= "$m $!ret.idr_name()";
        $r
    }
}
