final(s3).
trans(s1, a, s1).
trans(s1, a, s2).
trans(s1, b, s1).
trans(s2, b, s3).
trans(s3, b, s4).
silent(s2, s4).
silent(s3, s1).

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