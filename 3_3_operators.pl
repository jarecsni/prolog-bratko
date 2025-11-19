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
