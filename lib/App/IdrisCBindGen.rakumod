unit module App::IdrisCBindGen;

use App::IdrisCBindGen::CodeGen;
use App::IdrisCBindGen::FFITypes;

sub ez_func (Str $name, $args, Str $ret --> Function) is export {
    Function.new(
        c_name => $name,
        args => (Type.from_idris_name($_) for $args.list),
        ret => Type.from_idris_name($ret),
    )
}

sub ez_bind(*%args) is export {
    BindingsGenerator_Easy.new(|%args)
}
