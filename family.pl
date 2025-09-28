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
