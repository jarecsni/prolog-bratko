parent(tom, bob).
parent(pam, bob).
parent(tom, liz).
parent(bob, ann).
parent(bob, pat).
parent(pat, jim).

offspring(Parent, Child) :- parent(Parent, Child).
offspring(Parent, Descendant) :- parent(Parent, Intermediate), offspring(Intermediate, Descendant).