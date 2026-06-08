% -------------------------------------------------------------------------- %
% Tests for exercises/4_family.pl
% -------------------------------------------------------------------------- %
% Run with:
%   ?- ['exercises/4_family'].
%   ?- load_test_files([]).
%   ?- run_tests.
% Or in one shot:
%   ?- ['exercises/4_family'], load_test_files([]), run_tests.
% -------------------------------------------------------------------------- %

:- begin_tests(family_exercises).

% --- a) childless_family/1 -------------------------------------------------- %

test(childless_finds_smith) :-
    childless_family(smith).

test(childless_rejects_fox, [fail]) :-
    childless_family(fox).

test(childless_count) :-
    findall(S, childless_family(S), Surnames),
    length(Surnames, 1),
    Surnames = [smith].


% --- b) employed_child/1 and employed_child2/1 are equivalent --------------- %

test(employed_child_equivalence) :-
    findall(C, employed_child(C),  Xs),
    findall(C, employed_child2(C), Ys),
    Xs == Ys.

test(employed_child_finds_emma) :-
    employed_child(person(emma, jones, _, works(spotify, _))).

test(employed_child_count) :-
    findall(C, employed_child(C), Cs),
    length(Cs, N),
    N >= 2.   % Emma Jones + Oliver Miller + James Carter


% --- c) wife_sole_earner/1 -------------------------------------------------- %

test(wife_sole_earner_finds_miller) :-
    wife_sole_earner(miller).

test(wife_sole_earner_rejects_jones, [fail]) :-
    wife_sole_earner(jones).   % Robert works, so not "sole" earner

test(wife_sole_earner2_equivalence) :-
    findall(S, wife_sole_earner(S), Xs),
    findall(family(person(_, S, _, _), _, _),
            wife_sole_earner2(family(person(_, S, _, _), _, _)),
            Ys),
    length(Xs, N),
    length(Ys, N).


% --- d) large_age_gap_family/2 ---------------------------------------------- %

test(carters_have_large_gap) :-
    large_age_gap_family(15, family(person(henry, carter, _, _), _, _)).

test(carters_at_threshold_22) :-
    large_age_gap_family(22, family(person(henry, carter, _, _), _, _)).

test(no_family_with_50_year_gap, [fail]) :-
    large_age_gap_family(50, _).

test(threshold_is_strict_at_23, [fail]) :-
    % Carters have a 22-year gap, so 23 should exclude them
    large_age_gap_family(23, family(person(henry, carter, _, _), _, _)).

test(zero_gap_finds_all_families) :-
    findall(F, large_age_gap_family(0, F), Fs),
    length(Fs, N),
    N >= 5.   % at least all current families

:- end_tests(family_exercises).
