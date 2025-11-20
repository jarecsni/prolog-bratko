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

