member(X, [X|_]).
member(X, [_|T]) :- member(X, T).

% Base case: concatenating empty list with any list gives that list
conc([], SecondList, SecondList).

% Recursive case: move head from first list to result, recurse on tail
conc([Head|RestOfFirst], SecondList, [Head|RestOfResult]) :-
    conc(RestOfFirst, SecondList, RestOfResult).

/*
How Prolog solves conc([a], [1], L):

Query: conc([a], [1], L)

Step 1: Try base case conc([], SecondList, SecondList)
- Does [a] unify with []? No. Fail, try next clause.

Step 2: Try recursive case conc([Head|RestOfFirst], SecondList, [Head|RestOfResult])
- Unify [a] with [Head|RestOfFirst] → Head = a, RestOfFirst = []
- Unify [1] with SecondList → SecondList = [1]
- Unify L with [Head|RestOfResult] → L = [a|RestOfResult] (partially constructed!)
- Now solve subgoal: conc([], [1], RestOfResult)

Step 3: Solve conc([], [1], RestOfResult)
- Try base case conc([], SecondList, SecondList)
- Unify [] with [] → ✓
- Unify [1] with SecondList → ✓
- Unify RestOfResult with [1] → RestOfResult = [1]

Step 4: Return from recursion and unify
- We found RestOfResult = [1]
- Remember from Step 2: L = [a|RestOfResult] (was partially unified)
- Now complete the unification: L = [a|[1]] = [a, 1]

Result: L = [a, 1]

The magic is that Prolog builds the result incrementally through unification.
Each recursive call moves one element from the first list to the result's head,
and when it hits the base case (first list empty), it unifies the result's tail
with the second list.
*/

/*
Find all pairs of lists that concatenate to [a, b, c]
To see all solutions, query interactively:
  ?- conc(L1, L2, [a, b, c]).
  (press ; for more solutions)

Or use findall to get them all at once:
  ?- findall([L1, L2], conc(L1, L2, [a, b, c]), Solutions).
*/
:- writeln('All concatenation pairs for [a, b, c]:'),
   forall(conc(L1, L2, [a, b, c]),
          format('  L1 = ~w, L2 = ~w~n', [L1, L2])).
