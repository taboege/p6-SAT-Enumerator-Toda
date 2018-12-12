unit module SAT::Enumerator::Toda;

role Generic[$solver] {
    multi method enumerate (IO::Path $file --> Supply) {
        self.enumerate: $file.lines
    }

    multi method enumerate (Str $DIMACS --> Supply) {
        self.enumerate: $DIMACS.lines
    }

    multi method enumerate (List $lines --> Supply) {
        self.enumerate: $lines.Supply
    }

    multi method enumerate (Seq $lines --> Supply) {
        self.enumerate: $lines.Supply
    }

    multi method enumerate (Supply $lines --> Supply) {
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
            m/^ [ <literal> \s+ ]+ 0 $/;
            not« $<literal>».starts-with('-')
        })
        # TODO: in a react whenever or supply?
        #die X::SAT::Proc.new(:error($errmsg // "N/A"))
        #if $proc.status ~~ Kept and $proc.result.exitcode > 0;
    }
}

class Toda is export {
    class bdd does Generic["bdd_minisat_all"] { }
    class  bc does Generic[ "bc_minisat_all"] { }
    class nbc does Generic["nbc_minisat_all"] { }

    # Default solver is C<nbc> because it doesn't have a long preprocessing
    # step like C<bdd> and starts emitting values immediately, and doesn't
    # hoard memory like C<bc>.
    method enumerate (|c) { nbc.new.enumerate(|c) }
}

=begin pod

=head1 NAME

SAT::Enumerator::Toda - AllSAT solvers based on MiniSAT by Takahisa Toda

=head1 SYNOPSIS

  use SAT::Enumerator::Toda;

  say $_ for Toda.new.enumerate($my-cnf-file.IO)

=head1 DESCRIPTION

SAT::Enumerator::Toda wraps the C<bdd_minisat_all>, C<nbc_minisat_all>
and C<bc_minisat_all> executables (bunled with the module) used to list all
satisfying assignments for a Boolean formula given in the C<DIMACS cnf>
format. This is known as the C<AllSAT> problem associated with the formula.

Given a DIMACS cnf problem, it starts one of the solvers, feeds it the problem
and returns a Supply which emits all satisfying assignments as arrays of Bools.

=head1 AUTHOR

Tobias Boege <tboege@ovgu.de>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Tobias Boege

This library is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.

=end pod
