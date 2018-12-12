use Test;
use Test::SAT::Enumerator;
use SAT::Enumerator::Toda;

plan 3;

# See https://gaussoids.de
sub gaussoid-coding (@bools) { @bools.map({ .so ?? '1' !! '0' }).join }
sub oriented-coding (@bools) { @bools.map({ $^x.not ?? '-' !! $^y.not ?? '+' !! '0' }).join }
sub uniform-coding  (@bools) { @bools.map({ .so ?? '-' !! '+' }).join }
sub positive-coding (@bools) { @bools.map({ .so ?? '+' !! '0' }).join }

sub orientation-coding ($gaussoid, @bools) {
    my @S = uniform-coding(@bools).comb;
    S:g[1] = @S[$++] with $gaussoid
}

for (Toda::bdd, Toda::bc, Toda::nbc) -> $*SAT-ENUMERATOR {
    subtest $*SAT-ENUMERATOR.^name => {
        plan 7;
        # Bunch of gaussoid classes
        enumerate-ok 't/gaussoids-4.cnf'      => 't/gaussoids-4.txt'.IO.lines,      &gaussoid-coding;
        enumerate-ok 't/real-gaussoids-4.cnf' => 't/real-gaussoids-4.txt'.IO.lines, &gaussoid-coding;
        enumerate-ok 't/oriented-3.cnf'       => 't/oriented-3.txt'.IO.lines,       &oriented-coding;
        enumerate-ok 't/orientable.cnf'       => 't/orientable.txt'.IO.lines,       &orientation-coding.assuming("11111111111111111111111011011011111101011101101111111111111111111101111101111111");
        enumerate-ok 't/unorientable.cnf'     =>  set(),                            &orientation-coding.assuming("111111111101111110111101");
        enumerate-ok 't/uniform-4.cnf'        => 't/uniform-4.txt'.IO.lines,        &uniform-coding;
        enumerate-ok 't/positive-5.cnf'       => 't/positive-5.txt'.IO.lines,       &positive-coding;
    }
}
