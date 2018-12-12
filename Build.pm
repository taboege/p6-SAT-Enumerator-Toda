unit class Build;

method build (IO() $dist-path) {
    my $make = $*VM.config<make>;
    my $src = $dist-path.add("src");
    my $res = $dist-path.add("resources");
    $res.mkdir;
    for <bdd_minisat_all bc_minisat_all nbc_minisat_all> -> $solver {
        my $dir = $src.add($solver);
        say "Building $solver...";
        run $make, '-C', ~$dir;
        say "Copying $solver to resources";
        copy $dir.add($solver), $res.add($solver);
    }
    True
}

# vim: ft=perl6
