:- use_module(library(sldnfdraw)).
:- sldnf.
:- set_depth(20).  % Set max depth

:-begin_program.

t(0+1, 1+0).
t(X+0+1, X+1+0).
t(X+1+1, Z) :-
    t(X+1, X1),
    t(X1+1, Z).

:-end_program.

:-begin_query.

t(1+0+1+1+1, C).

:-end_query.
