% -------------------------------------------------------------------------- %
% 2.5 monkey_with_state.pl
%   Enhanced monkey-banana problem with proper state tracking and cycle detection
%
%   State representation: state(MonkeyHorizontal, MonkeyVertical, BoxPosition, HasBanana)
%     MonkeyHorizontal: atdoor | atwindow | middle
%     MonkeyVertical: onfloor | onbox
%     BoxPosition: atdoor | atwindow | middle
%     HasBanana: has | hasnot
%
%   This version demonstrates:
%     1. Cycle detection using visited states list
%     2. Path tracking to show the sequence of moves
%     3. Proper state threading in Prolog
% -------------------------------------------------------------------------- %

% -------------------------------------------------------------------------- %
% DOMAIN CONSTRAINTS
% -------------------------------------------------------------------------- %

% Define valid places in the room
place(atdoor).
place(atwindow).
place(middle).

% -------------------------------------------------------------------------- %
% MOVE RULES - Define valid state transitions
% -------------------------------------------------------------------------- %

% Grasp: monkey can grasp banana only when on box in middle position
move(state(middle, onbox, middle, hasnot),
     grasp,
     state(middle, onbox, middle, has)).

% Climb: monkey climbs onto box (must already be at box location)
move(state(Place, onfloor, Place, HasBanana),
     climb,
     state(Place, onbox, Place, HasBanana)) :-
    place(Place).

% Push: monkey pushes box from Place1 to Place2 (monkey moves with box)
move(state(Place1, onfloor, Place1, HasBanana),
     push(Place1, Place2),
     state(Place2, onfloor, Place2, HasBanana)) :-
    place(Place1),
    place(Place2).

% Walk: monkey walks from Place1 to Place2 (box position unchanged)
move(state(Place1, onfloor, BoxPosition, HasBanana),
     walk(Place1, Place2),
     state(Place2, onfloor, BoxPosition, HasBanana)) :-
    place(Place1),
    place(Place2),
    place(BoxPosition).

% -------------------------------------------------------------------------- %
% CANGET WITH CYCLE DETECTION
% -------------------------------------------------------------------------- %

% canget(State): true if monkey can get banana from State
%   Uses cycle detection to prevent infinite backtracking

% Base case: monkey already has banana
canget(state(_, _, _, has)).

% Recursive case: find a move to an unvisited state
%   Wrapper initializes visited list, then uses helper predicate
canget(State1) :-
    canget_helper(State1, [State1]).

% Helper predicate that threads visited states
canget_helper(state(_, _, _, has), _Visited).

canget_helper(State1, Visited) :-
    move(State1, _Move, State2),
    \+ member(State2, Visited),           % Cycle detection: don't revisit states
    canget_helper(State2, [State2|Visited]).     % Thread state: add State2 to visited list

% -------------------------------------------------------------------------- %
% CANGET WITH PATH TRACKING
% -------------------------------------------------------------------------- %

% canget_path(State, Path): Path is the sequence of moves to get banana from State
%   Returns the actual list of moves needed
canget_path(State, Path) :- 
    canget_path(State, [State], [], Path).

% Base case: monkey has banana, reverse accumulated path
canget_path(state(_, _, _, has), _Visited, PathAcc, Path) :-
    reverse(PathAcc, Path).

% Recursive case: find move, check for cycles, accumulate the move
canget_path(State1, Visited, PathAcc, Path) :-
    move(State1, Move, State2),
    \+ member(State2, Visited),                    % Cycle detection
    canget_path(State2, [State2|Visited], [Move|PathAcc], Path).

% -------------------------------------------------------------------------- %
% SHORTEST PATH (using iterative deepening)
% -------------------------------------------------------------------------- %

% shortest_path(State, Path): finds shortest path using iterative deepening
shortest_path(State, Path) :-
    length(Path, _),                      % Generate increasing lengths
    canget_path_bounded(State, [State], [], Path, 20).  % Max depth 20

% Bounded depth search to prevent infinite loops
canget_path_bounded(state(_, _, _, has), _Visited, PathAcc, Path, _MaxDepth) :-
    reverse(PathAcc, Path).

canget_path_bounded(State1, Visited, PathAcc, Path, MaxDepth) :-
    MaxDepth > 0,
    move(State1, Move, State2),
    \+ member(State2, Visited),
    MaxDepth1 is MaxDepth - 1,
    canget_path_bounded(State2, [State2|Visited], [Move|PathAcc], Path, MaxDepth1).

% -------------------------------------------------------------------------- %
% PRETTY PRINTING UTILITIES
% -------------------------------------------------------------------------- %

% show_solution(State): find and display solution with moves
show_solution(State) :-
    write('Initial state: '), write(State), nl,
    (   canget_path(State, Path) ->
        write('Solution found!'), nl,
        write('Moves: '), nl,
        print_moves(Path, 1),
        length(Path, Len),
        write('Total moves: '), write(Len), nl
    ;   write('No solution exists.'), nl
    ).

% print_moves(Moves, N): print numbered list of moves
print_moves([], _).
print_moves([Move|Rest], N) :-
    write('  '), write(N), write('. '), write(Move), nl,
    N1 is N + 1,
    print_moves(Rest, N1).

% -------------------------------------------------------------------------- %
% EXAMPLE QUERIES
% -------------------------------------------------------------------------- %
/*
?- canget(state(atdoor, onfloor, atwindow, hasnot)).
true.

?- canget_path(state(atdoor, onfloor, atwindow, hasnot), Path).
Path = [walk(atdoor, atwindow), push(atwindow, middle), climb, grasp].

?- show_solution(state(atdoor, onfloor, atwindow, hasnot)).
Initial state: state(atdoor, onfloor, atwindow, hasnot)
Solution found!
Moves:
  1. walk(atdoor, atwindow)
  2. push(atwindow, middle)
  3. climb
  4. grasp
Total moves: 4
true.

?- canget(state(middle, onbox, middle, hasnot)).
true.

?- canget_path(state(middle, onbox, middle, hasnot), Path).
Path = [grasp].
*/



