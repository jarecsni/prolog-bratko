% Test cyclic unification in Prolog

test_all :-
    nl,
    write('========================================'), nl,
    write('CYCLIC UNIFICATION TESTS'), nl,
    write('========================================'), nl, nl,
    
    test1,
    test2,
    test3,
    test4.

test1 :-
    write('TEST 1: X = f(X)'), nl,
    write('  Does it succeed? '),
    (   X = f(X)
    ->  write('YES'), nl,
        write('  X = '), write(X), nl
    ;   write('NO'), nl
    ), nl.

test2 :-
    write('TEST 2: unify_with_occurs_check(Y, f(Y))'), nl,
    write('  Does it succeed? '),
    (   unify_with_occurs_check(Y, f(Y))
    ->  write('YES'), nl,
        write('  Y = '), write(Y), nl
    ;   write('NO (correctly detects occurs-check violation)'), nl
    ), nl.

test3 :-
    write('TEST 3: Z = [1|Z] (infinite list)'), nl,
    write('  Does it succeed? '),
    (   Z = [1|Z]
    ->  write('YES'), nl,
        write('  Z = '), write(Z), nl
    ;   write('NO'), nl
    ), nl.

test4 :-
    write('TEST 4: Can W=f(W) unify with f(f(a))?'), nl,
    W = f(W),
    write('  W = '), write(W), nl,
    write('  Trying W = f(f(a))... '),
    (   W = f(f(a))
    ->  write('YES'), nl,
        write('  W = '), write(W), nl
    ;   write('NO (infinite f(f(f(...))) cannot match finite f(f(a)))'), nl
    ), nl.

% Run tests on load
:- initialization(test_all, main).

