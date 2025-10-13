% Recursion Patterns in Prolog
% Demonstrating where the "accumulator" or "result" variable appears

% ============================================
% PATTERN 1: Result built in HEAD (builds as recursion unwinds)
% ============================================

% Example 1a: del - delete element
% Result structure [Y|Tail1] is in the HEAD
del(X, [X|Tail], Tail).                      % Base: found X, return tail
del(X, [Y|Tail], [Y|Tail1]) :-               % Recursive: keep Y, recurse
    del(X, Tail, Tail1).                     % Tail1 filled by recursive call

% Example 1b: conc - concatenate lists
% Result structure [Head|RestOfResult] is in the HEAD
conc([], L, L).                              % Base: first list empty
conc([Head|RestOfFirst], Second, [Head|RestOfResult]) :-
    conc(RestOfFirst, Second, RestOfResult). % RestOfResult filled by recursive call

% Example 1c: make_list - create list of N elements
% Result structure [_|T] is in the HEAD
make_list(0, []).                            % Base: empty list
make_list(N, [_|T]) :-                       % Recursive: add element
    N > 0,
    N1 is N - 1,
    make_list(N1, T).                        % T filled by recursive call

% Example 1d: double_list - double each element
% Result structure [Double|RestResult] is in the HEAD
double_list([], []).
double_list([H|T], [Double|RestResult]) :-
    Double is H * 2,
    double_list(T, RestResult).              % RestResult filled by recursive call


% ============================================
% PATTERN 2: Accumulator in BODY (builds as recursion descends)
% ============================================

% Example 2a: reverse with accumulator
% Accumulator [H|Acc] is in the BODY (recursive call)
reverse_acc([], Acc, Acc).                   % Base: accumulator IS result
reverse_acc([H|T], Acc, Result) :-
    reverse_acc(T, [H|Acc], Result).         % Build accumulator going down

% Example 2b: sum with accumulator
% Accumulator (Acc + H) is in the BODY
sum_acc([], Acc, Acc).                       % Base: accumulator IS result
sum_acc([H|T], Acc, Result) :-
    NewAcc is Acc + H,
    sum_acc(T, NewAcc, Result).              % Accumulate going down

% Example 2c: length with accumulator
% Accumulator (Acc + 1) is in the BODY
length_acc([], Acc, Acc).                    % Base: accumulator IS result
length_acc([_|T], Acc, Result) :-
    NewAcc is Acc + 1,
    length_acc(T, NewAcc, Result).           % Count going down

% Example 2d: flatten with accumulator (more complex)
% Accumulator is built in BODY and passed down
flatten_acc([], Acc, Acc).
flatten_acc([H|T], Acc, Result) :-
    flatten_acc(T, Acc, TailResult),         % Process tail first
    flatten_acc(H, TailResult, Result).      % Then prepend head
flatten_acc(X, Acc, [X|Acc]) :-              % Non-list: add to accumulator
    \+ is_list(X).


% ============================================
% PATTERN 3: Searcher (no result building, just searching)
% ============================================

% Example 3a: member - search for element
% Variable T is in BODY, no result building
member(X, [X|_]).                            % Base: found it
member(X, [_|T]) :- member(X, T).            % Recursive: search tail

% Example 3b: last_element - find last element
% Variable T is in BODY, searching for single-element list
last_element(Last, [Last]).                  % Base: single element
last_element(Last, [_|T]) :-                 % Recursive: search tail
    last_element(Last, T).

% Example 3c: contains_zero - check if list contains 0
contains_zero([0|_]).                        % Base: found 0
contains_zero([_|T]) :- contains_zero(T).    % Recursive: search tail


% ============================================
% COMPARISON: Same operation, different patterns
% ============================================

% Reverse using PATTERN 1 (result in HEAD - inefficient!)
reverse_head([], []).
reverse_head([H|T], Result) :-
    reverse_head(T, RevT),                   % Recurse first
    conc(RevT, [H], Result).                 % Then append (expensive!)

% Reverse using PATTERN 2 (accumulator in BODY - efficient!)
reverse_tail(List, Result) :-
    reverse_tail_helper(List, [], Result).

reverse_tail_helper([], Acc, Acc).
reverse_tail_helper([H|T], Acc, Result) :-
    reverse_tail_helper(T, [H|Acc], Result). % Build going down


% ============================================
% WHEN TO USE EACH PATTERN
% ============================================

/*
PATTERN 1 (Result in HEAD):
- Use when: Building a structure that mirrors the input
- Examples: del, conc, map operations, filter
- Pros: Natural, declarative, easy to understand
- Cons: Not tail-recursive, can be inefficient for large lists

PATTERN 2 (Accumulator in BODY):
- Use when: Aggregating or transforming with state
- Examples: reverse, sum, length, fold operations
- Pros: Tail-recursive, efficient, constant stack space
- Cons: Less intuitive, requires helper predicate

PATTERN 3 (Searcher):
- Use when: Just checking/finding, not building
- Examples: member, contains, find
- Pros: Simple, direct
- Cons: Only for search, not construction
*/


% ============================================
% DEMO QUERIES
% ============================================

:- writeln('=== PATTERN 1: Result in HEAD ===').
:- del(b, [a,b,c], R1), format('del(b, [a,b,c], ~w)~n', [R1]).
:- conc([a,b], [c,d], R2), format('conc([a,b], [c,d], ~w)~n', [R2]).
:- make_list(3, R3), format('make_list(3, ~w)~n', [R3]).

:- writeln('').
:- writeln('=== PATTERN 2: Accumulator in BODY ===').
:- reverse_acc([a,b,c], [], R4), format('reverse_acc([a,b,c], [], ~w)~n', [R4]).
:- sum_acc([1,2,3,4], 0, R5), format('sum_acc([1,2,3,4], 0, ~w)~n', [R5]).
:- length_acc([a,b,c,d,e], 0, R6), format('length_acc([a,b,c,d,e], 0, ~w)~n', [R6]).

:- writeln('').
:- writeln('=== PATTERN 3: Searcher ===').
:- (member(b, [a,b,c]) -> writeln('member(b, [a,b,c]): true') ; writeln('member(b, [a,b,c]): false')).
:- last_element(X, [a,b,c]), format('last_element(X, [a,b,c]): X = ~w~n', [X]).
:- (contains_zero([1,0,2]) -> writeln('contains_zero([1,0,2]): true') ; writeln('contains_zero([1,0,2]): false')).

:- writeln('').
:- writeln('=== COMPARISON: Reverse ===').
:- reverse_head([a,b,c], R7), format('reverse_head([a,b,c], ~w) - builds in HEAD~n', [R7]).
:- reverse_tail([a,b,c], R8), format('reverse_tail([a,b,c], ~w) - accumulator in BODY~n', [R8]).

