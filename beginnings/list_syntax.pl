% list_syntax.pl
% Alternative list construction syntax for SWI-Prolog
% Created: 2025-10-08
%
% PROBLEM:
% Modern SWI-Prolog (7.0+) reserves the '.' functor for dictionary operations,
% breaking the classic Prolog list notation .(H, T) used in Bratko's book and
% other traditional Prolog texts. The internal list functor is now '[|]', which
% requires ugly quoted syntax: '[|]'(a, '[|]'(b, '[|]'(c, []))).
%
% SOLUTION:
% This module provides the '$' operator as a cleaner alternative for exploring
% list structure in cons-cell notation, similar to the classic dot notation.
%
% USAGE IN REPL:
%
%   Load the file:
%     $ swipl list_syntax.pl
%
%   Or from within SWI-Prolog:
%     ?- [list_syntax].
%
%   Then use either syntax:
%
%   Infix notation (like [H|T]):
%     ?- to_list(a $ b $ c $ [], L).
%     L = [a, b, c].
%
%   Functor notation (like classic .(H,T)):
%     ?- to_list($(a, $(b, $(c, []))), L).
%     L = [a, b, c].
%
%   Verify it's a real list:
%     ?- to_list($(1, $(2, $(3, []))), L), is_list(L).
%     L = [1, 2, 3].
%
% AUTO-LOAD:
%   To load automatically on SWI-Prolog startup, add to ~/.swiplrc:
%     :- ['/Users/johnny/dev/ai/prolog-bratko/list_syntax'].
%
% NOTE:
%   The $ structure is NOT a list until converted with to_list/2.
%   It's just syntactic sugar that gets transformed into proper '[|]' lists.

:- op(600, xfy, $).

%% to_list(+DollarStructure, -List) is det.
%
%  Converts a $ structure to a proper Prolog list.
%  Recursively handles nested $ functors in both head and tail positions.
%
%  @param DollarStructure A term using $ as list constructor
%  @param List The resulting proper Prolog list
%
%  Examples:
%    ?- to_list(a $ b $ c $ [], L).
%    L = [a, b, c].
%
%    ?- to_list($(1, $(2, [])), L).
%    L = [1, 2].
%
to_list(H $ T, [H2|T2]) :-
    !,
    to_list_elem(H, H2),
    to_list(T, T2).
to_list([], []) :- !.
to_list(X, X).

%% to_list_elem(+Element, -ConvertedElement) is det.
%
%  Helper predicate to handle nested $ structures in head position.
%  Recursively expands $ functors found in list elements.
%
to_list_elem(H $ T, [H2|T2]) :-
    !,
    to_list_elem(H, H2),
    to_list(T, T2).
to_list_elem(X, X).

