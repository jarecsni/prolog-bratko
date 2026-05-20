
% -------------------------------------------------------------------------- %
% 3.16
% max_(X, Y, Max) 
% Return the greater of two numbers, X and Y.
% -------------------------------------------------------------------------- %
max_(X, Y, X) :- X >= Y.
max_(X, Y, Y) :- X < Y.

% -------------------------------------------------------------------------- %
% 3.17
% maxlist(List, Max) 
% Return the greatest number of the list numbers.
% -------------------------------------------------------------------------- %
maxlist([X], X).
maxlist([H|T], Max) :-
    maxlist(T, MaxT),
    max_(H, MaxT, Max).

% -------------------------------------------------------------------------- %
% 3.18
% sumlist_(List, Sum) 
% Return the sum of the numbers in the list.
% -------------------------------------------------------------------------- %
sumlist_([], 0).
sumlist_([H|T], Sum) :-
    sumlist_(T, SumT),
    Sum is H + SumT.

% -------------------------------------------------------------------------- %
% 3.19
% ordered(List) 
% Returns true if List is an ordered list of numbers.
% -------------------------------------------------------------------------- %
ordered([]).
ordered([X]).
ordered([A,B|T]) :-
    A =< B,
    ordered([B|T]).