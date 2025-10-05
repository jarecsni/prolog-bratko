% ============================================================================
% PROLOG EXECUTION ANALYZER
% Traces execution paths with cycle detection and depth limiting
%
% USAGE:
%   Interactive mode:
%     swipl -s prolog_analyzer.pl -g "analyze_file('myfile.pl', mypred(X), interactive)"
%
%   Auto mode with depth limit:
%     swipl -s prolog_analyzer.pl -g "analyze_file('myfile.pl', mypred(X), auto(5))"
%
%   Command line:
%     ./analyze myfile.pl "mypred(X)" interactive
%     ./analyze myfile.pl "mypred(X)" auto 5
% ============================================================================

:- use_module(library(lists)).

% ----------------------------------------------------------------------------
% COMMAND LINE INTERFACE
% ----------------------------------------------------------------------------

% Main entry point for command line usage
main :-
    current_prolog_flag(argv, Argv),
    (   parse_args(Argv, File, Goal, Mode)
    ->  analyze_file(File, Goal, Mode)
    ;   show_usage
    ),
    halt.

% Parse command line arguments
parse_args([File, GoalStr, 'interactive'], File, Goal, interactive) :- !,
    atom_string(GoalAtom, GoalStr),
    term_string(Goal, GoalAtom).

parse_args([File, GoalStr, 'auto'], File, Goal, auto(5)) :- !,
    atom_string(GoalAtom, GoalStr),
    term_string(Goal, GoalAtom).

parse_args([File, GoalStr, 'auto', DepthStr], File, Goal, auto(Depth)) :- !,
    atom_string(GoalAtom, GoalStr),
    term_string(Goal, GoalAtom),
    atom_string(DepthAtom, DepthStr),
    atom_number(DepthAtom, Depth).

parse_args(_, _, _, _) :- fail.

% Show usage information
show_usage :-
    nl,
    write('╔════════════════════════════════════════════════════════════╗'), nl,
    write('║  PROLOG EXECUTION ANALYZER - Usage                         ║'), nl,
    write('╚════════════════════════════════════════════════════════════╝'), nl,
    nl,
    write('USAGE:'), nl,
    write('  ./analyze <file.pl> "<goal>" interactive'), nl,
    write('  ./analyze <file.pl> "<goal>" auto [depth]'), nl,
    nl,
    write('EXAMPLES:'), nl,
    write('  ./analyze family.pl "parent(tom, X)" interactive'), nl,
    write('  ./analyze family.pl "grandparent(tom, Who)" auto 5'), nl,
    nl,
    write('MODES:'), nl,
    write('  interactive - Step through execution interactively'), nl,
    write('  auto [depth] - Auto-analyze with depth limit (default: 5)'), nl,
    nl.

% Analyze a file with a goal
analyze_file(File, Goal, Mode) :-
    nl,
    format('Loading file: ~w~n', [File]),
    consult(File),
    nl,
    (   Mode = interactive
    ->  explore(Goal)
    ;   Mode = auto(Depth)
    ->  print_analysis(Goal, Depth)
    ;   write('Unknown mode'), nl
    ).

% ----------------------------------------------------------------------------
% MAIN ANALYZER
% ----------------------------------------------------------------------------

% analyze(Goal, MaxDepth, Tree)
%   Analyzes execution of Goal up to MaxDepth, detecting cycles
analyze(Goal, MaxDepth, Tree) :-
    analyze_helper(Goal, [], MaxDepth, Tree).

% Helper with visited goals tracking
analyze_helper(_, _, 0, cutoff(depth_limit)) :- !.

analyze_helper(Goal, Visited, Depth, cycle(Goal)) :-
    member_variant(Goal, Visited), !.

analyze_helper(Goal, Visited, Depth, Tree) :-
    Depth > 0,
    (   predicate_property(Goal, built_in)
    ->  Tree = builtin(Goal, evaluates)
    ;   predicate_property(Goal, defined)
    ->  analyze_clauses(Goal, Visited, Depth, Tree)
    ;   Tree = undefined(Goal)
    ).

% Analyze all matching clauses
analyze_clauses(Goal, Visited, Depth, node(Goal, Branches)) :-
    findall(
        branch(Head, BodyTree),
        (   clause(Goal, Body),
            copy_term(Goal-Body, Head-BodyCopy),
            Depth1 is Depth - 1,
            analyze_body(BodyCopy, [Goal|Visited], Depth1, BodyTree)
        ),
        Branches
    ).

% Analyze clause body (conjunction of goals)
analyze_body(true, _, _, success) :- !.
analyze_body((G1, G2), Visited, Depth, conj(T1, T2)) :- !,
    analyze_helper(G1, Visited, Depth, T1),
    analyze_helper(G2, Visited, Depth, T2).
analyze_body(Goal, Visited, Depth, Tree) :-
    analyze_helper(Goal, Visited, Depth, Tree).

% Check if goal is variant of any in visited list
member_variant(Goal, [H|_]) :- subsumes_term(H, Goal), subsumes_term(Goal, H), !.
member_variant(Goal, [_|T]) :- member_variant(Goal, T).

% ----------------------------------------------------------------------------
% PRETTY PRINTING
% ----------------------------------------------------------------------------

print_analysis(Goal, MaxDepth) :-
    nl,
    write('╔════════════════════════════════════════════════════════════╗'), nl,
    write('║  PROLOG EXECUTION ANALYSIS                                 ║'), nl,
    write('╚════════════════════════════════════════════════════════════╝'), nl,
    format('Goal: ~w~n', [Goal]),
    format('Max Depth: ~w~n~n', [MaxDepth]),
    analyze(Goal, MaxDepth, Tree),
    print_tree(Tree, 0),
    nl.

print_tree(Tree, Indent) :-
    print_indent(Indent),
    print_node(Tree, Indent).

print_node(cutoff(depth_limit), _) :-
    write('⚠ DEPTH LIMIT REACHED'), nl.

print_node(cycle(Goal), _) :-
    write('🔄 CYCLE DETECTED: '), write(Goal), nl.

print_node(builtin(Goal, _), _) :-
    write('⚙ BUILTIN: '), write(Goal), nl.

print_node(undefined(Goal), _) :-
    write('❌ UNDEFINED: '), write(Goal), nl.

print_node(success, _) :-
    write('✓ SUCCESS'), nl.

print_node(conj(T1, T2), Indent) :-
    write('AND'), nl,
    Indent1 is Indent + 2,
    print_tree(T1, Indent1),
    print_tree(T2, Indent1).

print_node(node(Goal, Branches), Indent) :-
    format('?- ~w~n', [Goal]),
    Indent1 is Indent + 2,
    print_branches(Branches, Indent1).

print_branches([], _).
print_branches([branch(Head, BodyTree)|Rest], Indent) :-
    print_indent(Indent),
    write('├─ '), write(Head), nl,
    Indent1 is Indent + 3,
    print_tree(BodyTree, Indent1),
    print_branches(Rest, Indent).

print_indent(0) :- !.
print_indent(N) :-
    N > 0,
    write(' '),
    N1 is N - 1,
    print_indent(N1).

% ----------------------------------------------------------------------------
% CYCLE DETECTION DEMO
% ----------------------------------------------------------------------------

% Test predicates
test_fact(a).
test_fact(b).

test_rule(X) :- test_fact(X).

test_recursive(0).
test_recursive(N) :- N > 0, N1 is N - 1, test_recursive(N1).

test_infinite(X) :- test_infinite(X).

test_mutual_a(X) :- test_mutual_b(X).
test_mutual_b(X) :- test_mutual_a(X).

% ----------------------------------------------------------------------------
% DEMOS
% ----------------------------------------------------------------------------

demo_simple :-
    write('=== SIMPLE FACT ==='), nl,
    print_analysis(test_fact(X), 3).

demo_rule :-
    write('=== SIMPLE RULE ==='), nl,
    print_analysis(test_rule(X), 3).

demo_recursive :-
    write('=== RECURSIVE (BOUNDED) ==='), nl,
    print_analysis(test_recursive(3), 5).

demo_infinite :-
    write('=== INFINITE LOOP DETECTION ==='), nl,
    print_analysis(test_infinite(X), 3).

demo_mutual :-
    write('=== MUTUAL RECURSION DETECTION ==='), nl,
    print_analysis(test_mutual_a(X), 3).

demo_family :-
    write('=== FAMILY EXAMPLE ==='), nl,
    % Assumes family.pl is loaded
    print_analysis(parent(tom, X), 2).

run_demos :-
    demo_simple,
    demo_rule,
    demo_recursive,
    demo_infinite,
    demo_mutual.

% ----------------------------------------------------------------------------
% STATISTICS
% ----------------------------------------------------------------------------

count_nodes(cutoff(_), 1).
count_nodes(cycle(_), 1).
count_nodes(builtin(_, _), 1).
count_nodes(undefined(_), 1).
count_nodes(success, 1).
count_nodes(conj(T1, T2), N) :-
    count_nodes(T1, N1),
    count_nodes(T2, N2),
    N is N1 + N2.
count_nodes(node(_, Branches), N) :-
    count_branches(Branches, N1),
    N is N1 + 1.

count_branches([], 0).
count_branches([branch(_, Tree)|Rest], N) :-
    count_nodes(Tree, N1),
    count_branches(Rest, N2),
    N is N1 + N2.

analyze_with_stats(Goal, MaxDepth) :-
    analyze(Goal, MaxDepth, Tree),
    count_nodes(Tree, NodeCount),
    nl,
    format('Analysis complete:~n', []),
    format('  Total nodes explored: ~w~n', [NodeCount]),
    format('  Max depth: ~w~n', [MaxDepth]),
    nl.

% ----------------------------------------------------------------------------
% INTERACTIVE WALKTHROUGH
% ----------------------------------------------------------------------------

% Interactive exploration - user chooses which branches to expand
explore(Goal) :-
    nl,
    write('╔════════════════════════════════════════════════════════════╗'), nl,
    write('║  INTERACTIVE PROLOG EXECUTION EXPLORER                     ║'), nl,
    write('╚════════════════════════════════════════════════════════════╝'), nl,
    nl,
    explore_step(Goal, [], 1).

explore_step(Goal, Visited, StepNum) :-
    format('~n[Step ~w] Current Goal: ~w~n', [StepNum, Goal]),

    % Check for cycles
    (   member_variant(Goal, Visited)
    ->  write('🔄 CYCLE DETECTED! This goal was already visited.'), nl,
        write('Press ENTER to backtrack...'), nl,
        read_line_to_string(user_input, _)

    % Check if built-in
    ;   predicate_property(Goal, built_in)
    ->  format('⚙ BUILTIN: ~w (auto-evaluates)~n', [Goal]),
        write('Press ENTER to continue...'), nl,
        read_line_to_string(user_input, _)

    % Check if undefined
    ;   \+ predicate_property(Goal, defined)
    ->  format('❌ UNDEFINED: ~w~n', [Goal]),
        write('Press ENTER to backtrack...'), nl,
        read_line_to_string(user_input, _)

    % Show available clauses
    ;   show_clauses_and_choose(Goal, Visited, StepNum)
    ).

show_clauses_and_choose(Goal, Visited, StepNum) :-
    findall(
        clause_info(N, Head, Body),
        (   clause(Goal, Body),
            copy_term(Goal-Body, Head-Body),
            N = _  % Will be numbered below
        ),
        Clauses
    ),

    (   Clauses = []
    ->  write('No matching clauses found.'), nl
    ;   number_clauses(Clauses, 1, NumberedClauses),
        nl,
        write('Available clauses:'), nl,
        print_clause_menu(NumberedClauses),
        nl,
        write('Choose clause number (or q to quit, b to back): '),
        read_line_to_string(user_input, Input),
        handle_choice(Input, NumberedClauses, Goal, Visited, StepNum)
    ).

number_clauses([], _, []).
number_clauses([clause_info(_, H, B)|Rest], N, [clause_info(N, H, B)|Numbered]) :-
    N1 is N + 1,
    number_clauses(Rest, N1, Numbered).

print_clause_menu([]).
print_clause_menu([clause_info(N, Head, Body)|Rest]) :-
    format('  ~w. ~w', [N, Head]),
    (   Body = true
    ->  write(' (fact)'), nl
    ;   format(' :- ~w~n', [Body])
    ),
    print_clause_menu(Rest).

handle_choice("q", _, _, _, _) :-
    nl, write('Exiting explorer.'), nl, !.

handle_choice("b", _, _, _, _) :-
    nl, write('Backtracking...'), nl, !, fail.

handle_choice(Input, Clauses, Goal, Visited, StepNum) :-
    atom_string(Atom, Input),
    atom_number(Atom, Choice),
    member(clause_info(Choice, Head, Body), Clauses),
    !,
    nl,
    format('Selected: ~w', [Head]),
    (   Body = true
    ->  write(' ✓'), nl,
        write('Fact matched! Press ENTER to continue...'), nl,
        read_line_to_string(user_input, _),
        StepNum1 is StepNum + 1,
        explore_step(Goal, Visited, StepNum1)  % Continue with next goal
    ;   nl,
        format('Body to prove: ~w~n', [Body]),
        write('Press ENTER to explore body...'), nl,
        read_line_to_string(user_input, _),
        StepNum1 is StepNum + 1,
        explore_body(Body, [Goal|Visited], StepNum1)
    ).

handle_choice(_, Clauses, Goal, Visited, StepNum) :-
    write('Invalid choice. Try again.'), nl,
    show_clauses_and_choose(Goal, Visited, StepNum).

% Explore conjunction of goals
explore_body(true, _, _) :-
    nl, write('✓ All goals satisfied!'), nl, !.

explore_body((G1, G2), Visited, StepNum) :- !,
    nl, write('Conjunction: need to prove both goals'), nl,
    format('  First:  ~w~n', [G1]),
    format('  Second: ~w~n', [G2]),
    write('Press ENTER to prove first goal...'), nl,
    read_line_to_string(user_input, _),
    explore_step(G1, Visited, StepNum),
    nl, write('First goal succeeded! Now proving second goal...'), nl,
    write('Press ENTER to continue...'), nl,
    read_line_to_string(user_input, _),
    StepNum1 is StepNum + 1,
    explore_body(G2, Visited, StepNum1).

explore_body(Goal, Visited, StepNum) :-
    explore_step(Goal, Visited, StepNum).

% ----------------------------------------------------------------------------
% QUICK INTERACTIVE DEMOS
% ----------------------------------------------------------------------------

demo_interactive_simple :-
    write('Try: explore(test_fact(X)).'), nl.

demo_interactive_recursive :-
    write('Try: explore(test_recursive(2)).'), nl.

demo_interactive_infinite :-
    write('Try: explore(test_infinite(X)).'), nl,
    write('(You will see cycle detection in action)'), nl.

% ----------------------------------------------------------------------------
% EXAMPLE QUERIES
% ----------------------------------------------------------------------------
/*
NON-INTERACTIVE:
?- print_analysis(test_fact(X), 2).
?- print_analysis(test_recursive(3), 5).
?- print_analysis(test_infinite(X), 3).
?- run_demos.

INTERACTIVE:
?- explore(test_fact(X)).
?- explore(test_rule(X)).
?- explore(test_recursive(2)).
?- explore(test_infinite(X)).

% With family.pl loaded:
?- ['family.pl'].
?- explore(parent(tom, X)).
?- explore(grandparent(tom, Who)).
?- explore(predecessor(tom, Who)).

NON-INTERACTIVE ANALYSIS:
?- print_analysis(grandparent(tom, Who), 4).
?- print_analysis(predecessor(tom, Who), 3).

% Check tree size:
?- analyze(test_recursive(5), 10, Tree), count_nodes(Tree, N).
*/

