# Prolog Execution Trace: del(b, [a,b,c])

## The del/3 Predicate Definition

```prolog
del(X, [X|Tail], Tail).
del(X, [Y|RestOfInput], [Y|RestOfOutput]) :- del(X, RestOfInput, RestOfOutput).
```

## Query: `del(b, [a,b,c], Result)`

### Step-by-Step Execution Trace

#### Call 1: `del(b, [a,b,c], Result)`

**Clause matching attempt:**
- **Clause 1:** `del(X, [X|Tail], Tail)`
  - Try to unify: `X = b`, `[X|Tail] = [a,b,c]`
  - This would require `X = b` AND `X = a` (since first element is 'a')
  - **FAILS** - cannot unify b with a

- **Clause 2:** `del(X, [Y|RestOfInput], [Y|RestOfOutput]) :- del(X, RestOfInput, RestOfOutput)`
  - Unify: `X = b`, `Y = a`, `RestOfInput = [b,c]`, `RestOfOutput = ?`
  - **SUCCEEDS** - creates subgoal: `del(b, [b,c], RestOfOutput)`
  - Current result structure: `[a|RestOfOutput]`

#### Call 2: `del(b, [b,c], RestOfOutput)`

**Clause matching attempt:**
- **Clause 1:** `del(X, [X|Tail], Tail)`
  - Try to unify: `X = b`, `[X|Tail] = [b,c]`
  - This means `X = b` (✓) and `Tail = [c]` (✓)
  - **SUCCEEDS** - `RestOfOutput = [c]`

### Backtracking and Result Construction

Now we work backwards through the call stack:

1. **Call 2 returns:** `RestOfOutput = [c]`
2. **Call 1 completes:** Result = `[a|RestOfOutput]` = `[a|[c]]` = `[a,c]`

### Final Result
```prolog
Result = [a,c]
```

## Visual Representation

```
del(b, [a,b,c], Result)
│
├─ Try Clause 1: del(b, [b|Tail], Tail) 
│  └─ FAIL: b ≠ a
│
└─ Try Clause 2: del(b, [a|RestOfInput], [a|RestOfOutput])
   ├─ Unify: Y=a, RestOfInput=[b,c]
   └─ Recursive call: del(b, [b,c], RestOfOutput)
      │
      ├─ Try Clause 1: del(b, [b|Tail], Tail)
      │  └─ SUCCESS: X=b, Tail=[c]
      │     Result: RestOfOutput = [c]
      │
      └─ Final assembly: [a|[c]] = [a,c]
```

## Key Prolog Concepts Demonstrated

### 1. Pattern Matching
- `[X|Tail]` matches any non-empty list where X is the head
- Prolog tries to unify variables with actual values
- If unification fails, Prolog backtracks to try other clauses

### 2. Recursion
- The second clause calls itself with a smaller problem
- Base case (first clause) stops the recursion
- Results are built up as the recursion unwinds

### 3. List Construction
- `[Y|RestOfOutput]` constructs a new list with Y as head
- The tail (RestOfOutput) comes from the recursive call
- This preserves elements that don't match the deletion target

### 4. Unification Process
Each step involves attempting to make the query match a clause:
- Variables get bound to values
- Structures must match exactly
- If any part fails to unify, try the next clause

## Alternative Queries

### What if we query: `del(b, [a,b,c], [a,c])`?
Prolog would verify this is true by following the same trace and checking if the final result matches `[a,c]`.

### What if we query: `del(X, [a,b,c], [a,c])`?
Prolog would find `X = b` by working through the same process but solving for X instead of the result.