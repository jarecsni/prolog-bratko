% Quick test for interactive explorer
:- ['prolog_analyzer.pl'].

% Simple test predicates
likes(alice, prolog).
likes(bob, prolog).
likes(alice, coffee).

parent(tom, bob).
parent(bob, ann).

grandparent(GP, GC) :- parent(GP, P), parent(P, GC).

% Test it
test_interactive :-
    write('Starting interactive exploration of: likes(Who, prolog)'), nl,
    write('This will let you step through clause selection.'), nl,
    nl,
    explore(likes(Who, prolog)).

