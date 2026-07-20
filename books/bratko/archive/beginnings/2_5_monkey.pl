% -------------------------------------------------------------------------- %
% 2.5 monkey.pl
%   move(State1, Move, State2): making Move in State1 results in State2
%       a state is represented by a term:
%       state(MonkeyHorizontal, MonkeyVertical, BoxPosition, HasBanana)
% Test: canget(state(atdoor, onfloor, atwindow, hasnot))
% -------------------------------------------------------------------------- %

move(state(middle, onbox, middle, hasnot), grasp, state(middle, onbox, middle, has)).
move(state(Place, onfloor, Place, HasBanana), climb, state(Place, onbox, Place, HasBanana)).
move(state(Place1, onfloor, Place1, HasBanana), push(Place1, Place2), state(Place2, onfloor, Place2, HasBanana)).
move(state(Place1, onfloor, BoxPosition, HasBanana), walk(Place1, Place2), state(Place2, onfloor, BoxPosition, HasBanana)).

% canget(State): true if monkey can get banana in State
canget(state(_, _, _, has)).

% canget(State1): monkey can get banana in State1 if there exists a move Move from State1 to State2, such that monkey can get banana in State2
canget(State1) :-
    move(State1, _Move, State2),
    canget(State2).


% version returning the list of moves
canget(state(_, _, _, has), []).
canget(State1, [Move|RestActions]) :-
    move(State1, Move, State2),
    canget(State2, RestActions).

