use Test;
use SAT::Enumerator::Toda;

plan 6;

is Toda.new.enumerate('t/gaussoids-4.cnf'.IO).elems.wait,       679, "IO dispatch";
is Toda.new.enumerate(slurp 't/gaussoids-4.cnf').elems.wait,    679, "Str dispatch";
is Toda.new.enumerate('t/gaussoids-4.cnf'.IO.lines).elems.wait, 679, "Seq dispatch";

my $DIMACS = q:to/EOF/;
p cnf 9 1
1 2 3 4 5 6 7 8 9 0
EOF
my $actee := cache $DIMACS.lines.map({
    if m/^ [ $<var>=[\d+] \s+ ]+ 0 $/ {
        slip gather {
            take $_;
            for $<var> -> $negate {
                take $<var>».Str.map(-> $n {
                    $n == $negate ?? -$n !! $n
                }).join(' ') ~ " 0";
            }
        }
    }
    elsif m/^ 'p cnf' \s $<vars>=[\d+] \s $<clauses>=[\d+] / {
        "p cnf $<vars> { $<clauses> * (1 + $<vars>) }"
    }
});

is Toda.new.enumerate($DIMACS).elems.wait,                        511, "Str dispatch";
is Toda.new.enumerate($actee).elems.wait,                         502, "List dispatch";
is Toda.new.enumerate($actee.Supply.throttle(1, 0.3)).elems.wait, 502, "Supply dispatch";
