unit module Test::SAT::Enumerator;

use Test;

sub enumerate-ok (
    $p (IO() :key($file), Set() :value($list)),
    &transform = { $^x },
) is export {
    subtest "$file" => {
        plan 2;
        my @sat = $*SAT-ENUMERATOR.new.enumerate($file).List;
        is +@sat, $list.elems, "same number of answers"; # in particular no duplications!
        is-deeply @sat.map(&transform).Set, $list, "assignments match";
    }
}
