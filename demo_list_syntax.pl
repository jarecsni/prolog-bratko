% demo_list_syntax.pl
% Demonstration of $ operator usage with to_list/2
% Load with: swipl demo_list_syntax.pl

:- [list_syntax].

% Run all demos
demo :-
    writeln('=== $ Operator Demo ==='),
    nl,
    demo_functor_notation,
    nl,
    demo_infix_notation,
    nl,
    demo_pattern_matching,
    nl,
    demo_with_predicates,
    nl,
    writeln('=== All demos complete ===').

% Example 1: Functor notation (like Bratko's .(H,T))
demo_functor_notation :-
    writeln('1. Functor notation: $(a, $(b, $(c, [])))'),
    to_list($(ann, $(bob, $(tom, []))), People),
    format('   Result: ~w~n', [People]),
    is_list(People),
    writeln('   ✓ Verified: is a real list').

% Example 2: Infix notation (cleaner for longer lists)
demo_infix_notation :-
    writeln('2. Infix notation: a $ b $ c $ []'),
    to_list(1 $ 2 $ 3 $ 4 $ 5 $ [], Numbers),
    format('   Result: ~w~n', [Numbers]),
    is_list(Numbers),
    writeln('   ✓ Verified: is a real list').

% Example 3: Pattern matching with $ structures
demo_pattern_matching :-
    writeln('3. Pattern matching:'),
    X $ Y $ Z $ [] = apple $ banana $ cherry $ [],
    format('   X = ~w, Y = ~w, Z = ~w~n', [X, Y, Z]),
    
    % Head and tail decomposition
    H $ Tail = first $ second $ third $ [],
    format('   Head = ~w~n', [H]),
    to_list(Tail, TailList),
    format('   Tail as list = ~w~n', [TailList]).

% Example 4: Using $ in custom predicates
demo_with_predicates :-
    writeln('4. Custom predicates with $ notation:'),
    
    % Length of $ structure
    dollar_length(a $ b $ c $ [], Len),
    format('   Length of (a $ b $ c $ []): ~w~n', [Len]),
    
    % Append two $ structures
    dollar_append(x $ y $ [], z $ w $ [], Result),
    to_list(Result, ResultList),
    format('   Append (x $ y $ []) and (z $ w $ []): ~w~n', [ResultList]).

% Helper: Calculate length of $ structure
dollar_length([], 0).
dollar_length(_ $ Tail, N) :-
    dollar_length(Tail, N1),
    N is N1 + 1.

% Helper: Append two $ structures
dollar_append([], L, L).
dollar_append(H $ T1, L2, H $ T3) :-
    dollar_append(T1, L2, T3).

