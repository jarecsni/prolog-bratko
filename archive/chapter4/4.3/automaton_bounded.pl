% Bratko Exercise 4.5 — bound the automaton's search with a move budget.
%
% The naive accepts/2 (below) can loop forever on a silent cycle, because a
% silent move recurses on the SAME string: nothing decreases, so depth-first
% search never bottoms out. Instead of a visited-set, this exercise caps the
% number of moves: every transition (reading OR silent) spends one unit of a
% budget; when the budget is gone, the branch fails.
%
% Trade-off vs the visited-set:
%   visited-set -> terminating AND complete (loses no accepted string)
%   maxmoves    -> terminating but INCOMPLETE: any string whose shortest
%                  accepting run needs more than MaxMoves moves is rejected.
%
% --- automaton (copied from automaton.pl) ----------------------------------

final(s3).
trans(s1, a, s1).
trans(s1, a, s2).
trans(s1, b, s1).
trans(s2, b, s3).
trans(s3, b, s4).
silent(s2, s4).
silent(s3, s1).
silent(s1, s3).   % added vs the 4.3 original: closes the s1 <-> s3 silent cycle.
                  % A silent move consumes no input, so this 2-cycle lets the
                  % unbounded accepts/2 spin forever. It is exactly the case the
                  % move budget below is here to tame.

% --- original, unbounded recogniser (kept for contrast) --------------------

% Accepts the empty string.
accepts(State, []) :-
    final(State).

% accept by reading first symbol
accepts(State, [Symbol|Rest]) :-
    trans(State, Symbol, State1),
    accepts(State1, Rest).

% accept by making silent move
accepts(State, String) :-
    silent(State, State1),
    accepts(State1, String).

% --- Exercise 4.5: bounded recogniser, accepts/3 ---------------------------
% accepts(State, String, MaxMoves) — accept String from State using at most
% MaxMoves transitions. Write the three clauses below.

% clause 1 — base case: empty string on a final state. Accepting is arrival,
% not a move, so the budget is irrelevant here (any leftover, even 0, is fine).
accepts(State, [], _) :- final(State).

% clause 2 — reading move: spends one unit of budget on a trans.
accepts(State, [Symbol|Rest], MaxMoves) :-
    MaxMoves > 0,
    trans(State, Symbol, State1),
    NewMaxMoves is MaxMoves - 1,
    accepts(State1, Rest, NewMaxMoves).

% clause 3 — silent move: also spends one unit. String is unchanged (silent
% moves consume no input), so the budget is the ONLY thing that shrinks here —
% which is precisely what stops the cycle.
accepts(State, String, MaxMoves) :-
    MaxMoves > 0,
    silent(State, State1),
    NewMaxMoves is MaxMoves - 1,
    accepts(State1, String, NewMaxMoves).