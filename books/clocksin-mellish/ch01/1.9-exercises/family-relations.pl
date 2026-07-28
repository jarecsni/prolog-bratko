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
% pure, constraint-based one dif/2. \== is enough while both arguments are
% bound at call time — which, in every rule below, they will be.
diff(X, Y) :- X \== Y.

% --- to define ------------------------------------------------------------
%
% parent(P, C)          P is a parent of C
% sister_of(X, Y)       X is a sister of Y            (the §1.8 rule, fixed)
% brother_of(X, Y)
% grandparent(G, C)
% grandmother(G, C)
% grandfather(G, C)
% aunt_of(A, X)
% uncle_of(U, X)
% cousin_of(X, Y)
