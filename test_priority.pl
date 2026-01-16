% Test operator priorities
:- op(500, xfx, tight).
:- op(700, xfx, loose).

test1 :- 
    Term = (a tight b loose c),
    write('Expression: a tight b loose c'), nl,
    write('Parsed as: '), write_canonical(Term), nl, nl.

test2 :-
    Term = (a loose b tight c),
    write('Expression: a loose b tight c'), nl,
    write('Parsed as: '), write_canonical(Term), nl.
