=begin pod

=head1 NAME

SAT::Enumerator::Toda - AllSAT solvers based on MiniSAT by Takahisa Toda

=head1 SYNOPSIS

=begin code
use SAT::Enumerator::Toda;

toda('t/gaussoids-4.cnf'.IO).map(-> @bools {
    @bools».Int.join
})».say;
#=«
000000000000000000000000
000011110000000000000000
000000001111000000000000
000000000000111100000000
000000001111111100000000
010111110000111100000000
000000000000000011110000
000011110000000011110000
001100001111000011110000
000000000000111111111100
...
»
=end code

=head1 DESCRIPTION

SAT::Enumerator::Toda wraps the C<bdd_minisat_all>, C<nbc_minisat_all>
and C<bc_minisat_all> executables (bunled with the module) used to list all
satisfying assignments for a Boolean formula given in the C<DIMACS cnf>
format. This is known as the C<AllSAT> problem associated with the formula.

Given a DIMACS cnf problem, it starts one of the solvers, feeds it the problem
and returns a Supply which emits all satisfying assignments as arrays of Bools.

=end pod

use SAT;

# XXX: Workaround for zef stripping execute bits on resource install.
BEGIN for <bdd_minisat_all bc_minisat_all nbc_minisat_all> -> $solver {
    sink with %?RESOURCES{$solver}.IO { .chmod: 0o100 +| .mode }
}

role SAT::Enumerator::Toda::Generic[$solver] does SAT::Enumerator {
    multi method enumerate (Supply $lines, *% () --> Supply) {
        my $exe = %?RESOURCES{$solver};

        # XXX: We use stdin and stdout to communicate. This requires
        # my patches to the programs, which are linked in this repo's
        # git submodules.
        my token literal { \-? \d+ };
        my ($proc, $out);
        with Proc::Async.new: $exe, :w {
            .bind-stderr: $*SPEC.devnull.IO.open(:w);
            $out = .stdout.lines;
            #$proc = .start;
            .start and await .ready;
            react whenever $lines -> $line {
                .put: $line;
                LAST .close-stdin;
            }
        }

        $out.map({
            if m/^ [ <literal> \s+ ]+ 0 $/ {
                not« $<literal>».starts-with('-')
            }
            # TODO: Error handling
        })
        # TODO: in a react whenever or supply?
        #die X::SAT::Proc.new(:error($errmsg // "N/A"))
        #if $proc.status ~~ Kept and $proc.result.exitcode > 0;
    }
}

# Default solver is C<nbc> because it doesn't have a long preprocessing
# step like C<bdd> and starts emitting values immediately, and doesn't
# hoard memory like C<bc>.
class SAT::Enumerator::Toda does SAT::Enumerator::Toda::Generic["nbc_minisat_all"] is export {
    class bdd does SAT::Enumerator::Toda::Generic["bdd_minisat_all"] { }
    class  bc does SAT::Enumerator::Toda::Generic[ "bc_minisat_all"] { }
    class nbc does SAT::Enumerator::Toda::Generic["nbc_minisat_all"] { }
}

multi sub toda (|c) is export {
    SAT::Enumerator::Toda.new.enumerate(|c)
}

multi sub toda-bdd (|c) is export {
    SAT::Enumerator::Toda::bdd.new.enumerate(|c)
}

multi sub toda-bc (|c) is export {
    SAT::Enumerator::Toda::bc.new.enumerate(|c)
}

multi sub toda-nbc (|c) is export {
    SAT::Enumerator::Toda::nbc.new.enumerate(|c)
}

=begin pod

=head1 AUTHOR

Tobias Boege <tboege@ovgu.de>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Tobias Boege

This library is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.

=end pod
