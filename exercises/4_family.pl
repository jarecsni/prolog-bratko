% -------------------------------------------------------------------------- %
% Bratko Chapter 4 — Exercise solutions
% -------------------------------------------------------------------------- %
% Solutions operate on the family database defined in ../4_family.pl.
% Load with: ?- ['exercises/4_family'].
% Reload after edits with: ?- make.
% -------------------------------------------------------------------------- %

:- consult('../4_family').

% -------------------------------------------------------------------------- %
% a) names of families with no children
% -------------------------------------------------------------------------- %
childless_family(Surname) :-
    family(person(_, Surname, _, _), _, []).

% -------------------------------------------------------------------------- %
% b) all employed children
% Generate then filter
% -------------------------------------------------------------------------- %
employed_child(Child) :-
    child(Child),
    Child = person(_, _, _, works(_, _)).

% -------------------------------------------------------------------------- %
% b) all employed children
% Filter (constraint) then generate.
% -------------------------------------------------------------------------- %
employed_child2(Child) :-
    Child = person(_, _, _, works(_, _)),
    child(Child).
