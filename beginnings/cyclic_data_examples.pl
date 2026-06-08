% ============================================================================
% REAL-WORLD EXAMPLES OF CYCLIC/RECURSIVE DATA STRUCTURES
% ============================================================================

% ============================================================================
% PART 1: TRUE X = f(X) STYLE CYCLIC STRUCTURES
% ============================================================================

% ----------------------------------------------------------------------------
% EXAMPLE 1: SELF-REFERENTIAL OBJECT (like JSON circular references)
% ----------------------------------------------------------------------------
% Problem: Representing an object that contains itself
% Like: var obj = {}; obj.self = obj;

% Create a self-referential structure
make_self_ref(Obj) :-
    Obj = object(name, Obj).

demo_self_ref :-
    nl,
    write('=== SELF-REFERENTIAL OBJECT ==='), nl,
    make_self_ref(Obj),
    write('Created: '), write(Obj), nl,
    write('This is like: obj = {name: "name", self: obj}'), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 2: INFINITE TREE (fractal-like structure)
% ----------------------------------------------------------------------------
% Problem: A tree where each node contains the whole tree
% Like a fractal: tree(left: tree, right: tree) where left and right are the same tree

make_infinite_tree(Tree) :-
    Tree = node(Tree, Tree).

demo_infinite_tree :-
    write('=== INFINITE TREE (FRACTAL) ==='), nl,
    make_infinite_tree(T),
    write('Created: '), write(T), nl,
    write('Each node contains itself as left and right child'), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 3: RECURSIVE TYPE DEFINITION
% ----------------------------------------------------------------------------
% Problem: Representing a type that contains itself
% Like: type List = Cons(value, List)

% A stream that generates itself
make_recursive_stream(Stream) :-
    Stream = stream(value, Stream).

demo_recursive_stream :-
    write('=== RECURSIVE STREAM ==='), nl,
    make_recursive_stream(S),
    write('Created: '), write(S), nl,
    write('Like: stream(value, stream(value, stream(value, ...)))'), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 4: CYCLIC GRAPH NODE
% ----------------------------------------------------------------------------
% Problem: A graph node that points to itself (self-loop)
% Common in graph algorithms

make_self_loop_node(Node) :-
    Node = graph_node(id, [Node]).

demo_self_loop :-
    write('=== SELF-LOOP GRAPH NODE ==='), nl,
    make_self_loop_node(N),
    write('Created: '), write(N), nl,
    write('A node with an edge pointing back to itself'), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 5: OMEGA COMBINATOR (λ-calculus)
% ----------------------------------------------------------------------------
% Problem: The famous ω = λx.(x x) applied to itself
% In Prolog: omega(omega)

make_omega(Omega) :-
    Omega = apply(Omega, Omega).

demo_omega :-
    write('=== OMEGA COMBINATOR ==='), nl,
    make_omega(O),
    write('Created: '), write(O), nl,
    write('The self-application from lambda calculus'), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 6: PLACEHOLDER/LAZY EVALUATION
% ----------------------------------------------------------------------------
% Problem: A computation that refers to its own result
% Like: x = expensive_computation(x) - used in lazy evaluation

make_lazy_value(Value) :-
    Value = lazy(computation, Value).

demo_lazy :-
    write('=== LAZY VALUE ==='), nl,
    make_lazy_value(V),
    write('Created: '), write(V), nl,
    write('Represents a computation that uses its own result'), nl, nl.

% ----------------------------------------------------------------------------
% PRACTICAL EXAMPLE: DETECTING CYCLES IN UNIFICATION
% ----------------------------------------------------------------------------

% Check if a term is cyclic
is_cyclic(Term) :-
    \+ acyclic_term(Term).

% Demo: Compare cyclic vs non-cyclic
demo_cycle_detection :-
    write('=== CYCLE DETECTION ==='), nl,

    X = f(X),
    write('X = f(X): '),
    (is_cyclic(X) -> write('CYCLIC') ; write('ACYCLIC')), nl,

    Y = f(a),
    write('Y = f(a): '),
    (is_cyclic(Y) -> write('CYCLIC') ; write('ACYCLIC')), nl,

    Z = f(Z, g(Z)),
    write('Z = f(Z, g(Z)): '),
    (is_cyclic(Z) -> write('CYCLIC') ; write('ACYCLIC')), nl, nl.

% ----------------------------------------------------------------------------
% RUN TRUE CYCLIC DEMOS
% ----------------------------------------------------------------------------

run_true_cyclic_demos :-
    demo_self_ref,
    demo_infinite_tree,
    demo_recursive_stream,
    demo_self_loop,
    demo_omega,
    demo_lazy,
    demo_cycle_detection.

% ============================================================================
% PART 2: CYCLIC LISTS (append-based, not pure X=f(X))
% ============================================================================

% ----------------------------------------------------------------------------
% EXAMPLE 1: ROUND-ROBIN SCHEDULER (Circular List)
% ----------------------------------------------------------------------------
% Problem: You have 3 workers and want to assign tasks in rotation
% Workers: [alice, bob, charlie, alice, bob, charlie, alice, bob, ...]

% Create a circular list of workers
make_round_robin(Workers, RoundRobin) :-
    append(Workers, RoundRobin, RoundRobin).

% Get next N assignments from the round-robin
get_assignments(_, 0, []).
get_assignments([Worker|Rest], N, [Worker|Assignments]) :-
    N > 0,
    N1 is N - 1,
    get_assignments(Rest, N1, Assignments).

% Demo
demo_round_robin :-
    nl,
    write('=== ROUND-ROBIN SCHEDULER ==='), nl,
    make_round_robin([alice, bob, charlie], RR),
    write('Circular worker list created: '), write(RR), nl,
    write('Assigning 10 tasks:'), nl,
    get_assignments(RR, 10, Assignments),
    write('  '), write(Assignments), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 2: INFINITE STREAM OF ONES
% ----------------------------------------------------------------------------
% Problem: Generate an infinite sequence [1, 1, 1, 1, ...]
% Useful for lazy evaluation, default values, etc.

% Create infinite stream of a value
infinite_stream(Value, Stream) :-
    Stream = [Value|Stream].

% Take first N elements from a stream
take(_, 0, []).
take([H|T], N, [H|Rest]) :-
    N > 0,
    N1 is N - 1,
    take(T, N1, Rest).

% Demo
demo_infinite_stream :-
    write('=== INFINITE STREAM ==='), nl,
    infinite_stream(1, Ones),
    write('Created infinite stream of 1s: '), write(Ones), nl,
    write('Taking first 15 elements:'), nl,
    take(Ones, 15, First15),
    write('  '), write(First15), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 3: REPEATING PATTERN (Wallpaper/Tile Pattern)
% ----------------------------------------------------------------------------
% Problem: Create a repeating pattern like [red, green, blue, red, green, blue, ...]

make_pattern(Pattern, Repeating) :-
    append(Pattern, Repeating, Repeating).

% Demo
demo_pattern :-
    write('=== REPEATING PATTERN ==='), nl,
    make_pattern([red, green, blue], Colors),
    write('Pattern created: '), write(Colors), nl,
    write('First 12 colors:'), nl,
    take(Colors, 12, First12),
    write('  '), write(First12), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 4: CYCLIC STATE MACHINE
% ----------------------------------------------------------------------------
% Problem: Traffic light cycles through states: green -> yellow -> red -> green ...

% Create cyclic state sequence
traffic_light_cycle(Cycle) :-
    Cycle = [green, yellow, red | Cycle].

% Simulate N state transitions
simulate_traffic(_, 0, []).
simulate_traffic([State|Rest], N, [State|States]) :-
    N > 0,
    N1 is N - 1,
    simulate_traffic(Rest, N1, States).

% Demo
demo_traffic_light :-
    write('=== TRAFFIC LIGHT CYCLE ==='), nl,
    traffic_light_cycle(Cycle),
    write('Cycle created: '), write(Cycle), nl,
    write('Simulating 10 state changes:'), nl,
    simulate_traffic(Cycle, 10, States),
    write('  '), write(States), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 5: CIRCULAR BUFFER (Ring Buffer)
% ----------------------------------------------------------------------------
% Problem: Fixed-size buffer that wraps around
% Used in audio processing, network buffers, etc.

% Create a circular buffer of size N with initial value
make_circular_buffer(Size, InitValue, Buffer) :-
    length(Slots, Size),
    maplist(=(InitValue), Slots),
    append(Slots, Buffer, Buffer).

% Demo
demo_circular_buffer :-
    write('=== CIRCULAR BUFFER ==='), nl,
    make_circular_buffer(5, empty, Buffer),
    write('Created 5-slot circular buffer: '), write(Buffer), nl,
    write('First 12 positions (wraps around):'), nl,
    take(Buffer, 12, Positions),
    write('  '), write(Positions), nl, nl.

% ----------------------------------------------------------------------------
% EXAMPLE 6: FIBONACCI-LIKE INFINITE SEQUENCE
% ----------------------------------------------------------------------------
% This is trickier but shows the power of cyclic structures

% Create infinite Fibonacci sequence using cyclic structure
% Note: This is more of a demonstration - not the most practical way
fib_stream(Fibs) :-
    Fibs = [0, 1 | Rest],
    fib_pairs(Fibs, Rest).

fib_pairs([A, B | Tail], [Sum | Rest]) :-
    Sum is A + B,
    fib_pairs([B | Tail], Rest).

% Demo (careful - this one is truly infinite in computation)
demo_fibonacci :-
    write('=== FIBONACCI STREAM (first 10) ==='), nl,
    fib_stream(Fibs),
    take(Fibs, 10, First10),
    write('  '), write(First10), nl, nl.

% ----------------------------------------------------------------------------
% PRACTICAL USE CASE: TASK SCHEDULER
% ----------------------------------------------------------------------------

% Schedule tasks to workers in round-robin fashion
schedule_tasks(Tasks, Workers, Schedule) :-
    make_round_robin(Workers, RR),
    assign_tasks(Tasks, RR, Schedule).

assign_tasks([], _, []).
assign_tasks([Task|Tasks], [Worker|Workers], [task(Task, Worker)|Schedule]) :-
    assign_tasks(Tasks, Workers, Schedule).

% Demo
demo_scheduler :-
    write('=== PRACTICAL TASK SCHEDULER ==='), nl,
    Tasks = [email, backup, report, cleanup, update, monitor, log, archive],
    Workers = [server1, server2, server3],
    write('Tasks: '), write(Tasks), nl,
    write('Workers: '), write(Workers), nl,
    schedule_tasks(Tasks, Workers, Schedule),
    write('Schedule:'), nl,
    print_schedule(Schedule).

print_schedule([]).
print_schedule([task(Task, Worker)|Rest]) :-
    write('  '), write(Task), write(' -> '), write(Worker), nl,
    print_schedule(Rest).

% ----------------------------------------------------------------------------
% RUN ALL DEMOS
% ----------------------------------------------------------------------------

run_all_demos :-
    write('╔════════════════════════════════════════════════════════════╗'), nl,
    write('║  PART 1: TRUE X=f(X) CYCLIC STRUCTURES                    ║'), nl,
    write('╚════════════════════════════════════════════════════════════╝'), nl,
    run_true_cyclic_demos,

    write('╔════════════════════════════════════════════════════════════╗'), nl,
    write('║  PART 2: CYCLIC LISTS (practical examples)                ║'), nl,
    write('╚════════════════════════════════════════════════════════════╝'), nl,
    demo_round_robin,
    demo_infinite_stream,
    demo_pattern,
    demo_traffic_light,
    demo_circular_buffer,
    demo_fibonacci,
    demo_scheduler.

% ----------------------------------------------------------------------------
% EXAMPLE QUERIES
% ----------------------------------------------------------------------------
/*
?- demo_round_robin.
?- demo_infinite_stream.
?- demo_pattern.
?- demo_traffic_light.
?- demo_scheduler.
?- run_all_demos.

% Create your own:
?- infinite_stream(hello, S), take(S, 5, L).
L = [hello, hello, hello, hello, hello].

?- make_pattern([a, b, c], P), take(P, 10, L).
L = [a, b, c, a, b, c, a, b, c, a].

?- schedule_tasks([t1, t2, t3, t4, t5], [w1, w2], Sched).
Sched = [task(t1, w1), task(t2, w2), task(t3, w1), task(t4, w2), task(t5, w1)].
*/

