parent(tom, bob).
parent(pam, bob).
parent(tom, liz).
parent(bob, ann).
parent(bob, pat).
parent(pat, jim).

female(pam).            % alternative could be sex(pam, female)
female(liz).
female(pat).
female(ann).
male(jim).
male(tom).
male(bob).

different(X, Y) :- X \= Y.

offspring(Child, Parent) :- parent(Parent, Child).
% offspring(Descendant, Parent) :- parent(Parent, Intermediate), offspring(Descendant, Intermediate).

mother(Child, Mother) :- parent(Mother, Child), female(Mother).
father(Child, Father) :- parent(Father, Child), male(Father).

grandparent(Grandparent, Grandchild) :- parent(Grandparent, Parent), parent(Parent, Grandchild).
grandfather(Grandchild, Grandfather) :- grandparent(Grandfather, Grandchild), male(Grandfather).
grandmother(Grandchild, Grandmother) :- grandparent(Grandmother, Grandchild), female(Grandmother).

sister(Sister, SisterOf) :- parent(Parent, Sister), parent(Parent, SisterOf), female(Sister), different(Sister, SisterOf).
brother(Brother, BrotherOf) :- parent(Parent, Brother), parent(Parent, BrotherOf), male(Brother), different(Brother, BrotherOf).

% exercise 1.3
happy(X) :- once(parent(X, _)).

has2Children(X) :- once((parent(X, Y), sister(Y, Z), different(Y, Z))).

% exercise 1.4
grandchild(Grandchild, Grandparent) :- parent(Grandparent, Parent), parent(Parent, Grandchild).

% exercise 1.5
aunt(Aunt, NieceOrNephew) :- sister(Aunt, Parent), parent(Parent, NieceOrNephew).
uncle(Uncle, NieceOrNephew) :- brother(Uncle, Parent), parent(Parent, NieceOrNephew).

% chapter 1.3 Recursive rules
predecessor(Predecessor, Successor) :- 
    parent(Predecessor, Successor).
predecessor(Predecessor, Successor) :- 
    parent(Predecessor, Intermediate), 
    predecessor(Intermediate, Successor).

predecessor2(Predecessor, Successor) :- 
    parent(Predecessor, Successor).
predecessor2(Predecessor, Successor) :- 
    parent(Intermediate, Successor), 
    predecessor2(Predecessor, Intermediate).
