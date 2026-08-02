% §1.9 Exercise 1.3 — derive the kinship relations from a base of facts.
%
% Given: male/1, female/1, father/2, mother/2, and diff/2.
% Wanted: everything else, defined as rules over that base.
%
% The tree (Victoria & Albert, continuing the §1.8 example):
%
%       victoria = albert
%                |
%      +---------+----------+----------+
%      |         |          |          |
%   edward     alice      alfred    beatrice
%   = alexandra  = louis
%      |            |
%   +--+---+     +--+---+
%   |      |     |      |
% george  maud  ella  irene
%
% george/maud and ella/irene are cousins — the smallest tree in which
% aunt, uncle and cousin all have solutions to find.

% --- the base facts -------------------------------------------------------

male(albert).
male(edward).
male(alfred).
male(louis).
male(george).

female(victoria).
female(alice).
female(alexandra).
female(beatrice).
female(maud).
female(ella).
female(irene).

father(albert, edward).
father(albert, alice).
father(albert, alfred).
father(albert, beatrice).
father(edward, george).
father(edward, maud).
father(louis, ella).
father(louis, irene).

mother(victoria, edward).
mother(victoria, alice).
mother(victoria, alfred).
mother(victoria, beatrice).
mother(alexandra, george).
mother(alexandra, maud).
mother(alice, ella).
mother(alice, irene).

% --- given ----------------------------------------------------------------

% diff(X, Y) — X and Y are not the same individual.
% The book assumes this exists; SWI spells the non-pure version \== and the
% pure, constraint-based one dif/2. \== is a snapshot: it compares the terms
% as they stand at call time, so an unbound argument passes it vacuously and
% is never re-checked once bound. Every caller must therefore place it where
% both arguments are already bound — see sister_of/2, where it comes last for
% exactly that reason. dif/2 is a constraint and carries no such obligation;
% see sister_of_dif/2, which states it first and still works.
diff(X, Y) :- X \== Y.

% --- to define ------------------------------------------------------------
is_mother(X) :-
    mother(X, _).

is_father(X) :-
    father(X, _).

is_son(X) :- 
    male(X),
    parent(_, X).

is_son_unique(X) :- 
    male(X),
    once(parent(_, X)).

sons(Sons) :- 
    findall(X, is_son(X), L), 
    sort(L, Sons).

% is X a parent of Y
parent(X, Y) :- 
    father(X, Y);
    mother(X, Y).

% X is a sister of Y
sister_of(X, Y) :-
    female(X),
    parent(Z, X),
    parent(Z, Y),
    diff(X, Y).

sister_of_dif(X, Y) :-
    female(X),
    dif(X, Y), % ! dif/2 works with unbound vars too, it's a constraint
    parent(Z, X),
    parent(Z, Y).

% X is a grandpa of Y
grandpa_of(X, Y) :-
    father(X, Z),
    parent(Z, Y).
