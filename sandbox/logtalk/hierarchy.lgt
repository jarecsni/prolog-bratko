% The smallest thing that shows what Logtalk adds to Prolog:
% inheritance with overriding — "inherit unless overridden".
%
% Nothing in pure Prolog gives you this. Written by hand it needs an
% explicit isa/2 chain, a search predicate walking it, and a cut to stop
% at the most specific answer. Here it is language syntax.
%
% Load:  swilgt
%        ?- {hierarchy}.
%        ?- penguin::moves(X).

:- object(animal).

    :- public(moves/1).
    moves(walking).

:- end_object.


:- object(bird,
    extends(animal)).

    moves(flying).

:- end_object.


:- object(penguin,
    extends(bird)).

    % overrides bird's answer, which overrode animal's
    moves(swimming).

    % ^^/1 reaches the *inherited* definition — the "super" call.
    :- public(ancestral_move/1).
    ancestral_move(X) :-
        ^^moves(X).

:- end_object.
