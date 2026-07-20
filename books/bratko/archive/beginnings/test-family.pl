% Load the family facts
:- consult('family.pl').

% Main program
main :-
    write('Welcome to the Family Tree System'), nl,
    write('====================================='), nl, nl,
    write('Complete Offspring Tree:'), nl,
    write('------------------------'), nl,
    show_all_offspring,
    nl, nl,
    show_family_tree.

% Display all offspring relationships
show_all_offspring :-
    offspring(Parent, Child),
    write(Parent), write(' -> '), write(Child), nl,
    fail.
show_all_offspring.

% Alternative: Show organized family tree
show_family_tree :-
    write('Family Tree by Generation:'), nl,
    write('=========================='), nl,
    findall(Person, parent(Person, _), Parents),
    list_to_set(Parents, UniqueParents),
    forall((member(Ancestor, UniqueParents), \+ parent(_, Ancestor)),
           (write('Ancestor: '), write(Ancestor), nl,
            show_descendants(Ancestor, 1))),
    !.

% Show descendants with indentation
show_descendants(Person, Level) :-
    parent(Person, Child),
    tab(Level),
    write('- '), write(Child), nl,
    NextLevel is Level + 1,
    show_descendants(Child, NextLevel),
    fail.
show_descendants(_, _).

% To run the program, call: ?- main.