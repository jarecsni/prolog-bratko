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

/*
Find all months before and after May
*/
:- conc(Before, [may|After], [jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]),
   writeln('Months before May:'), writeln(Before),
   writeln('Months after May:'), writeln(After).

/*
Find the month before and after May
*/
:- conc(_, [Before, may, After | _], [jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]),
   writeln('Month before May:'), writeln(Before),
   writeln('Month after May:'), writeln(After).

/*
member2/2 implementation using conc/3
*/
member2(X, L) :- conc(_, [X|_], L).


/*
3.1(a)
Write a goal using conc/3 to delete the last 3 elements from a list L, producing another list L1. Hint: L is the concatenation of L1 and a list with 3 elements.
*/
delete_last_3(List, ResultList) :- conc(ResultList, [_, _, _], List).

/*
Delete the last N elements from a list
*/
delete_last_n(L, N, L1) :-
    N >= 0,                      % Guard: N must be non-negative
    length(Suffix, N),           % Create a list of length N (with unbound variables)
    conc(L1, Suffix, L).

/*
Alternative: build a list of N elements manually
*/
make_list(0, []).
make_list(N, [_|T]) :-
    N > 0,
    N1 is N - 1,
    make_list(N1, T).

delete_last_n_alt(L, N, L1) :-
    make_list(N, Suffix),
    conc(L1, Suffix, L).

% 3.1 (b)
delete_first_and_last_3(List, ResultList) :- conc([_, _, _], TempList, List), conc(ResultList, [_, _, _], TempList).


/*
Execution Trace (with variable renaming):
CALL 1: make_list(3, Suffix)

Prolog renames the clause to: make_list(N₁, [_₁|T₁])

Unify: 3 with N₁ → N₁ = 3 ✓
Unify: Suffix with [_₁|T₁] → Suffix = [_₁|T₁] (T₁ is unbound)
Check: N₁ > 0 → 3 > 0 ✓
Calculate: N1₁ is N₁ - 1 → N1₁ = 2
New goal: make_list(2, T₁) ← We're solving for T₁ now!
Current state:

Suffix = [_₁|T₁] where T₁ = ???
CALL 2: make_list(2, T₁) ← This is the goal from Call 1

Prolog renames the clause to: make_list(N₂, [_₂|T₂]) (fresh variables!)

Unify: 2 with N₂ → N₂ = 2 ✓
Unify: T₁ with [_₂|T₂] → T₁ = [_₂|T₂] (T₂ is unbound)
Check: N₂ > 0 → 2 > 0 ✓
Calculate: N1₂ is N₂ - 1 → N1₂ = 1
New goal: make_list(1, T₂) ← We're solving for T₂ now!
Current state:

Suffix = [_₁|T₁] where T₁ = [_₂|T₂]
So: Suffix = [_₁, _₂|T₂] where T₂ = ???
CALL 3: make_list(1, T₂) ← This is the goal from Call 2

Prolog renames the clause to: make_list(N₃, [_₃|T₃]) (fresh variables!)

Unify: 1 with N₃ → N₃ = 1 ✓
Unify: T₂ with [_₃|T₃] → T₂ = [_₃|T₃] (T₃ is unbound)
Check: N₃ > 0 → 1 > 0 ✓
Calculate: N1₃ is N₃ - 1 → N1₃ = 0
New goal: make_list(0, T₃) ← We're solving for T₃ now!
Current state:

Suffix = [_₁|T₁] where T₁ = [_₂|T₂] where T₂ = [_₃|T₃]
So: Suffix = [_₁, _₂, _₃|T₃] where T₃ = ???
CALL 4: make_list(0, T₃) ← This is the goal from Call 3

Prolog tries the base case: make_list(0, [])

Unify: 0 with 0 → ✓
Unify: T₃ with [] → T₃ = [] ✓
No more goals! Success!
Final state:

Suffix = [_₁, _₂, _₃|T₃] where T₃ = []
So: Suffix = [_₁, _₂, _₃]
The Key Insight:
In Call 2, when we match make_list(N, [_|T]), the T in that clause is NOT the same as the T from Call 1!

Here's the mapping:

Call 1's T → I called it T₁
Call 2's T → I called it T₂ (different variable!)
Call 3's T → I called it T₃ (different variable!)
The connection happens through the GOAL:

Call 1 creates goal make_list(2, T₁) ← T₁ from Call 1
Call 2 matches this with make_list(N₂, [_₂|T₂]) ← T₂ is Call 2's local variable
The unification T₁ = [_₂|T₂] connects Call 1's T₁ to Call 2's structure
*/

/*
`Suffix = [_₁, _₂, _₃]` is the **simplified view** after all unifications are complete.

But the **actual structure** is:

```
Suffix = [_₁|T₁]
  where T₁ = [_₂|T₂]
    where T₂ = [_₃|T₃]
      where T₃ = []
```

It's **nested unifications**, not a flat list. Russian dolls is the perfect analogy.

**In memory, it's literally:**

```
Suffix points to: [_₁ | pointer-to-T₁]
T₁ points to:     [_₂ | pointer-to-T₂]
T₂ points to:     [_₃ | pointer-to-T₃]
T₃ points to:     []
```

When you **follow all the pointers**, you get `[_₁, _₂, _₃]`, but the underlying structure is a chain of linked cells, each created by a different recursive call.

**This is why `make_list(0, [])` doesn't wipe anything out** - it only binds `T₃ = []`, the innermost doll. All the outer dolls (`Suffix`, `T₁`, `T₂`) are already constructed and pointing to each other.

You've got it. That's the real mental model. The "simplified" notation `[_₁, _₂, _₃]` is just syntactic sugar for the nested structure.

*/

/*
**Exactly, Cooper!** The base case determines the **direction of data flow**.

## Base Cases:

**`make_list`:**
```prolog
make_list(0, []).
```
- Unifies the result with `[]`
- This is the **starting point** for building
- Data flows **outward** from here

**`member`:**
```prolog
member(X, [X|_]).
```
- Matches when element is found
- This is the **stopping point** for searching
- Data flows **inward** to here

## The Pattern:

**Construction (build outward):**
```prolog
base_case(..., []).              % Start with []
recursive_case(..., [H|T]) :-    % Wrap it with [H|...]
    recursive_case(..., T).
```
- Base case provides the **seed value** (`[]`)
- Recursion **wraps** it layer by layer
- Result built as recursion **unwinds**

**Search/Consumption (search inward):**
```prolog
base_case(X, [X|_]).             % Found it!
recursive_case(X, [_|T]) :-      % Not here, keep looking
    recursive_case(X, T).
```
- Base case provides the **success condition**
- Recursion **peels** layers until match
- Result found as recursion **descends**

## Another Example - `conc/3`:

```prolog
conc([], SecondList, SecondList).              % Base: first list empty
conc([Head|RestOfFirst], Second, [Head|RestOfResult]) :-
    conc(RestOfFirst, Second, RestOfResult).
```

This is a **constructor** like `make_list`:
- Base case: `conc([], L, L)` - when first list is empty, result is second list
- Builds result from inside-out as recursion unwinds
- `RestOfResult` gets filled by recursive call, then wrapped with `Head`

## The Rule:

**Base case determines direction:**
- Base case returns a **value** (like `[]`) → **Constructor** (builds outward)
- Base case checks a **condition** (like `X = X`) → **Searcher** (searches inward)

You nailed it. The base case is the key.
*/

% Declarative meaning: "Last is the last element of List if List can be split
% into some prefix and a single-element list [Last]"
% In other words: List = [anything...] ++ [Last]
last_element(List, Last) :- conc(_, [Last], List).

% Declarative meaning: "Last is the last element of List if the reverse of List
% has Last as its head"
% In other words: reversing puts the last element first
last_element2(List, Last) :- reverse(List, [Last|_]).


% Declarative meaning:
% Base case: Last is the last element of a single-element list [Last]
% Recursive case: Last is the last element of [_|T] if Last is the last element of T
% In other words: "The last element of a list is the last element of its tail"
last_element3(Last, [Last]).
last_element3(Last, [_|T]) :- last_element3(Last, T).

% add element with a single fact - that's terse
add(Item, List, [Item|List]).

del(X, [X|Tail], Tail).
del(X, [Y|RestOfInput], [Y|RestOfOutput]) :- del(X, RestOfInput, RestOfOutput).
