% 3.12 
:- op(300, xfx, plays).
:- op(200, xfy, and).

test1 :- 
    Term = (jimmy plays football and squash),
    write('Pretty: '), write(Term), nl,
    write('Canonical: '), write_canonical(Term), nl.

test2 :- 
    Term = (susan plays tennis and basketball and volleyball),
    write('Pretty: '), write(Term), nl,
    write('Canonical: '), write_canonical(Term), nl.

% 3.13
:- op(500, xfx, was).
:- op(400, xfx, of).
:- op(300, fx, the).
diana was the secretary of the department.
test3 :- 
    Term = (diana was the secretary of the department),
    write('Pretty: '), write(Term), nl,
    write('Canonical: '), write_canonical(Term), nl.

% 3.14
t(0+1, 1+0).
t(X+0+1, X+1+0).
t(X+1+1, Z) :-
    t(X+1, X1),
    t(X1+1, Z).

/**
    Questions:
    1) ?- t(0 + 1, A). => A = 1+0.
    2) ?- t(0 + 1 + 1, B). B = 1+1+0.
    3) ?- t(1 + 0 + 1 + 1 + 1, C). => C = 
 **/

% 3.15 - Operator versions of member, conc, del

% member as "in" operator
% Usage: a in [a, b, c].
:- op(600, xfx, in).

X in [X|_].
X in [_|T] :- X in T.

% conc as "and ... gives" operators
% Usage: [a,b] and [c,d] gives Result.
:- op(500, xfx, and).
:- op(600, xfx, gives).

[] and L gives L.
[H|T] and L gives [H|R] :- T and L gives R.

% del as "deleting ... from ... gives" operators
% Usage: deleting b from [a,b,c] gives Result.
:- op(400, xfx, from).
:- op(450, fx, deleting).
% Note: 'gives' already defined above at 600

deleting X from [X|T] gives T.
deleting X from [Y|T] gives [Y|R] :- deleting X from T gives R.
