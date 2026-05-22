
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

% -------------------------------------------------------------------------- %
% 3.20
% subsum(Set, Sum, SubSet) 
% Set is a list of numbers, SubSet is a subset of these, and sum of the 
% numbers in SubSet is Sum.
% 
% Example
% subsum([1,2,5,3,2], 5, Sub).
% Sub = [1,2,2]
% Sub = [2,3]
% Sub = [5]
% -------------------------------------------------------------------------- %
subsum([], 0, []).
subsum([N|Set], Sum, [N|Sub]) :- 
    Sum1 is Sum - N,
    subsum(Set, Sum1, Sub).
subsum([_|Set], Sum, Sub) :-
    subsum(Set, Sum, Sub).

% -------------------------------------------------------------------------- %
% 3.21
% between(N1, N2, X)
% find all X that satisfy N1 <= X <= N2
% -------------------------------------------------------------------------- %
between(N1, N2, N1) :-
    N1 =< N2.
between(N1, N2, X) :-
    N1 < N2,
    N1Next is N1 + 1,
    between(N1Next, N2, X).

% -------------------------------------------------------------------------- %
% 3.22
% define operators 'if' 'then' 'else' and ':=' so that the following becomes legal term:
% if X > Y then Z := X else Z := Y
% -------------------------------------------------------------------------- %
:- op(1000, fx, if).
:- op(900, xfx, then).
:- op(800, xfx, else).
:- op(700, xfx, :=).

if Val1 > Val2 then Var := Val3 else Var := Val4 :-
    Val1 > Val2,
    Var = Val3.

if Val1 > Val2 then Var := Val3 else Var := Val4 :- 
    Val1 =< Val2,
    Var = Val4.
