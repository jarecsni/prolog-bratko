% -------------------------------------------------------------------------- %
% Bratko Chapter 4 — Exercise solutions
% -------------------------------------------------------------------------- %
% Solutions operate on the family database defined in ../4_family.pl.
% Load with: ?- ['exercises/4_family'].
% Reload after edits with: ?- make.
% -------------------------------------------------------------------------- %

:- consult('../4_family').

childless_family(Surname) :-
    family(person(_, Surname, _, _), _, []).