member(X, [X|_]).
member(X, [_|T]) :- member(X, T).

conc([], L, L).
conc([H|T1], L2, [H|T3]) :- conc(T1, L2, T3).

/*
How Prolog solves conc([a], [1], L):

Query: conc([a], [1], L)

Step 1: Try first clause conc([], L, L)
- Does [a] unify with []? No. Fail, try next clause.

Step 2: Try second clause conc([H|T1], L2, [H|T3]) :- conc(T1, L2, T3)
- Unify [a] with [H|T1] → H = a, T1 = []
- Unify [1] with L2 → L2 = [1]
- Unify L with [H|T3] → L = [a|T3] (partially constructed!)
- Now solve subgoal: conc([], [1], T3)

Step 3: Solve conc([], [1], T3)
- Try first clause conc([], L, L)
- Unify [] with [] → ✓
- Unify [1] with L → ✓
- Unify T3 with [1] → T3 = [1]

Step 4: Backtrack and substitute
- We found T3 = [1]
- Remember from Step 2: L = [a|T3]
- Substitute: L = [a|[1]] = [a, 1]

Result: L = [a, 1]

The magic is that Prolog builds the result incrementally through unification.
Each recursive call adds one element to the head of the result list, and when
it hits the base case, it unifies the tail with L2.
*/

/*
Good question, Cooper. Let me trace through how Prolog solves `conc([a], [1], L)` step by step.

The key is **unification** - Prolog doesn't just check true/false, it builds the answer by unifying variables with structures.

Here's the execution trace:

```
Query: conc([a], [1], L)
```

**Step 1:** Try first clause `conc([], L, L)`
- Does `[a]` unify with `[]`? **No.** Fail, try next clause.

**Step 2:** Try second clause `conc([H|T1], L2, [H|T3]) :- conc(T1, L2, T3)`
- Unify `[a]` with `[H|T1]` → `H = a, T1 = []`
- Unify `[1]` with `L2` → `L2 = [1]`
- Unify `L` with `[H|T3]` → `L = [a|T3]` (partially constructed!)
- Now solve subgoal: `conc([], [1], T3)`

**Step 3:** Solve `conc([], [1], T3)`
- Try first clause `conc([], L, L)`
- Unify `[]` with `[]` → ✓
- Unify `[1]` with `L` → ✓
- Unify `T3` with `[1]` → **T3 = [1]**

**Step 4:** Backtrack and substitute
- We found `T3 = [1]`
- Remember from Step 2: `L = [a|T3]`
- Substitute: `L = [a|[1]]` = `[a, 1]`

**Result:** `L = [a, 1]`

The magic is that Prolog builds the result **incrementally** through unification. Each recursive call adds one element to the head of the result list, and when it hits the base case, it unifies the tail with `L2`.

*/