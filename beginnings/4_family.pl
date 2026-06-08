
% -------------------------------------------------------------------------- %
% Bratko Chapter 4.1 — Retrieving structured information from a database
% -------------------------------------------------------------------------- %
% Each family is a single fact of the form:
%
%   family(Husband, Wife, [Child1, Child2, ...])
%
% where each person is itself a structure:
%
%   person(FirstName, Surname, date(Day, Month, Year), Work)
%
% and Work is either:
%
%   works(Company, AnnualSalary)
%   unemployed
%
% This is the canonical Bratko example of using compound terms to
% represent structured information — the data IS the term, no separate
% parsing or schema layer.
% -------------------------------------------------------------------------- %

family(
    person(tom,  fox, date(7, may, 1950), works(bbc, 15200)),
    person(ann,  fox, date(9, may, 1951), unemployed),
    [person(pat, fox, date(5, may, 1973), unemployed),
    person(jim, fox, date(5, may, 1973), unemployed)]
).

family(
    person(george, brown, date(15, june, 1948), works(siemens, 24000)),
    person(mary,   brown, date(3, april, 1949), works(nhs, 28500)),
    [person(susan, brown, date(20, august, 1975), works(ibm, 33500))]
).

family(
    person(peter, smith, date(2, march, 1945), works(university, 21000)),
    person(jane,  smith, date(15, july, 1946), works(university, 19000)),
    []
).

family(
    person(robert, jones, date(11, october, 1962), works(google, 95000)),
    person(linda,  jones, date(22, december, 1965), unemployed),
    [person(emma, jones, date(4, april, 1995), works(spotify, 42000)),
     person(luke, jones, date(14, july, 1998), unemployed),
     person(noah, jones, date(30, may, 2003), unemployed)]
).

family(
    person(david, miller, date(18, february, 1955), unemployed),
    person(sarah, miller, date(7, november, 1957), works(barclays, 32000)),
    [person(oliver, miller, date(12, june, 1985), works(deloitte, 47000))]
).

family(
    person(henry,  carter, date(3, january, 1940), works(shell, 38000)),
    person(claire, carter, date(20, september, 1962), works(harrods, 17500)),
    [person(james, carter, date(8, april, 1988), works(reuters, 41000))]
).


% -------------------------------------------------------------------------- %
% Accessor predicates — derive role from position in the family/3 term
% -------------------------------------------------------------------------- %

husband(X) :- family(X, _, _).
wife(X)    :- family(_, X, _).
child(X)   :- family(_, _, Children), member(X, Children).

% Anyone in a family — husband, wife, or child.
exists(Person) :-
    husband(Person)
  ; wife(Person)
  ; child(Person).


% -------------------------------------------------------------------------- %
% Field accessors — pattern-match into the person/4 term
% -------------------------------------------------------------------------- %

dateofbirth(person(_, _, Date, _), Date).

salary(person(_, _, _, works(_, S)), S).
salary(person(_, _, _, unemployed),  0).


% -------------------------------------------------------------------------- %
% Derived predicates — relationships between people
% -------------------------------------------------------------------------- %

% Same family — two people share a family/3 fact.
same_family(P1, P2) :-
    family(P1, P2, _).
same_family(P1, P2) :-
    family(P2, P1, _).
same_family(Parent, Child) :-
    family(Parent, _, Children), member(Child, Children).
same_family(Parent, Child) :-
    family(_, Parent, Children), member(Child, Children).

% Total household income.
total([], 0).
total([P|Ps], Sum) :-
    salary(P, S),
    total(Ps, Rest),
    Sum is S + Rest.

household_income(Husband, Wife, Children, Total) :-
    family(Husband, Wife, Children),
    total([Husband, Wife | Children], Total).


% -------------------------------------------------------------------------- %
% Sample queries (paste at the ?- prompt to try)
% -------------------------------------------------------------------------- %
% ?- husband(X).
%    enumerates all husbands across the four families
%
% ?- child(person(Name, fox, _, _)).
%    finds all children whose surname is fox
%
% ?- exists(person(Name, _, _, unemployed)).
%    finds all unemployed people
%
% ?- exists(person(Name, _, date(_, _, Y), _)), Y > 1990.
%    finds people born after 1990
%
% ?- salary(person(tom, fox, _, works(_, S)), S).
%    looks up Tom Fox's salary
%
% ?- household_income(person(H, S, _, _), _, _, Income), Income > 50000.
%    finds households earning over £50k total
%
% ?- findall(Name, exists(person(Name, _, _, works(_, S))), Workers),
%    length(Workers, N).
%    counts employed people across all families
% -------------------------------------------------------------------------- %

% -------------------------------------------------------------------------- %
% nth_member (used here for children selector)
% Also this is E4.3
% -------------------------------------------------------------------------- %
nth_member(0, [H|_], H).
nth_member(N, [_|T], E) :-
    succ(N0, N), % N > 0 is one directional, limits uses
    nth_member(N0, T, E).