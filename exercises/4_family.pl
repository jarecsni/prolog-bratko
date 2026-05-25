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
% Filter (constraint) then generate - fail fast (more performant)
% -------------------------------------------------------------------------- %
employed_child2(Child) :-
    Child = person(_, _, _, works(_, _)),
    child(Child).

% -------------------------------------------------------------------------- %
% c) Families with unemployed husbands and employed wives
% -------------------------------------------------------------------------- %
wife_sole_earner(Surname) :-
    family(
        person(_, Surname, _, unemployed),
        person(_, _, _, works(_, _)),
        _
    ).

wife_sole_earner2(Family) :-
    Family = family(
        person(_, _, _, unemployed),
        person(_, _, _, works(_, _)),
        _
    ),
    call(Family).

% -------------------------------------------------------------------------- %
% d) Families where parents age differs by at least 15 years
% -------------------------------------------------------------------------- %
large_age_gap_family(MinGap, Family) :-
    Family = family(
        person(_, _, date(_, _, YH), _),
        person(_, _, date(_, _, YW), _),
        _
        ),
    call(Family),
    Diff is abs(YH - YW),
    Diff >= MinGap.

% -------------------------------------------------------------------------- %
% 4.2) Define relation twin(Child1, Child2)
% -------------------------------------------------------------------------- %
twin(Child1, Child2) :-
    family(_, _, Children),
    member(Child1, Children),
    member(Child2, Children),
    Child1 = person(_, _, DOB, _),
    Child2 = person(_, _, DOB, _),
    Child1 \== Child2. 
    % Or Child1 @< Child2 (it would reduce symmetric pairs to 1 find)
         