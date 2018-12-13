NAME
====

SAT::Enumerator::Toda - AllSAT solvers based on MiniSAT by Takahisa Toda

SYNOPSIS
========

``` perl6
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
```

DESCRIPTION
===========

SAT::Enumerator::Toda wraps the `bdd_minisat_all`, `nbc_minisat_all` and `bc_minisat_all` executables (bunled with the module) used to list all satisfying assignments for a Boolean formula given in the `DIMACS cnf` format. This is known as the `AllSAT` problem associated with the formula.

Given a DIMACS cnf problem, it starts one of the solvers, feeds it the problem and returns a Supply which emits all satisfying assignments as arrays of Bools.

AUTHOR
======

Tobias Boege <tboege ☂ ovgu ☇ de>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Tobias Boege

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

