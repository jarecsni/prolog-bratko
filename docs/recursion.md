# Prolog Recursion: The Complete Mental Model

## Table of Contents
1. [The Fundamental Challenge](#the-fundamental-challenge)
2. [How Prolog Executes: The Goal Stack](#how-prolog-executes-the-goal-stack)
3. [The Russian Doll Model](#the-russian-doll-model)
4. [Variable Renaming and Fresh Variables](#variable-renaming-and-fresh-variables)
5. [Unification: Symmetric and Simultaneous](#unification-symmetric-and-simultaneous)
6. [Recursion Patterns](#recursion-patterns)
7. [The Searcher vs Builder Pattern](#the-searcher-vs-builder-pattern)
8. [Tail Call Optimization](#tail-call-optimization)
9. [Common Pitfalls](#common-pitfalls)
10. [Key Insights](#key-insights)

---

## The Fundamental Challenge

Learning Prolog is fundamentally different from learning other programming languages:

**Traditional Programming:**
- Learn syntax: loops, conditionals, functions
- Learn libraries: how to call APIs
- Progress is measurable: "I learned async/await today"

**Prolog:**
- Syntax is trivial (you learn it quickly)
- **The hard part:** Rewiring your brain to think declaratively
- Progress is invisible until suddenly... it clicks

### What You're Actually Learning

1. **Unification thinking** - "How do these patterns match?"
2. **Relational thinking** - "What's the relationship, not the procedure?"
3. **Recursive decomposition** - "How does this break into smaller pieces?"
4. **Backtracking intuition** - "What happens when this fails?"
5. **Variable binding flow** - "Where does this value come from?"

These aren't "features" you can check off a list. They're **mental models** that take time to internalize.

---

## How Prolog Executes: The Goal Stack

Prolog maintains a **goal stack** and processes goals until the stack is empty.

### Example: `conc([a], [1], L)`

**Initial state:**
- Goal stack: `[conc([a], [1], L)]`
- Bindings: `{}`

**Step 1:** Try to satisfy `conc([a], [1], L)`
- Match against clause 2: `conc([Head|RestOfFirst], SecondList, [Head|RestOfResult]) :- conc(RestOfFirst, SecondList, RestOfResult)`
- Unifications: `Head=a, RestOfFirst=[], SecondList=[1], L=[a|RestOfResult]`
- The `:-` means "to prove this, you must prove the right side"
- **New goal added to stack:** `conc([], [1], RestOfResult)`
- Goal stack: `[conc([], [1], RestOfResult)]`
- Bindings: `{Head=a, RestOfFirst=[], SecondList=[1], L=[a|RestOfResult]}`

**Step 2:** Try to satisfy `conc([], [1], RestOfResult)`
- Match against clause 1: `conc([], SecondList, SecondList)`
- Unifications: `SecondList=[1], RestOfResult=[1]`
- This clause has no body (no `:-`), so **no new goals added**
- Goal stack: `[]` (empty!)
- Bindings: `{Head=a, RestOfFirst=[], SecondList=[1], L=[a|RestOfResult], RestOfResult=[1]}`

**Step 3:** Goal stack is empty → SUCCESS
- Now apply all bindings: `L = [a|RestOfResult]` where `RestOfResult=[1]`
- Final result: `L = [a, 1]`

### What Keeps Prolog Going?

- As long as the goal stack is **not empty**, Prolog keeps trying to satisfy goals
- Each clause body adds new goals to the stack
- When a goal is satisfied (matched with no body), it's removed from the stack
- When the stack is empty, the query succeeds

### What Makes Unifications Stick?

- Unifications are **permanent** during a proof attempt
- They only get undone on **failure backtracking** (trying alternative clauses)
- Since we never failed, all unifications remain

---

## The Russian Doll Model

This is the **key mental model** for understanding Prolog recursion.

### The Core Insight

Variables don't "grow" - they get **built from the inside out through nested unifications**.

### Example: `make_list(3, Suffix)`

```prolog
make_list(0, []).
make_list(N, [_|T]) :- 
    N > 0, 
    N1 is N - 1, 
    make_list(N1, T).
```

**The structure is NOT:**
```
Suffix = [_, _, _]  (flat)
```

**The structure IS:**
```
Suffix = [_₁|T₁]
  where T₁ = [_₂|T₂]
    where T₂ = [_₃|T₃]
      where T₃ = []
```

### Detailed Trace

**CALL 1:** `make_list(3, Suffix)`
- Match clause 2 (renamed): `make_list(N₁, [_₁|T₁])`
- Unify: `N₁ = 3`, `Suffix = [_₁|T₁]` (T₁ is unbound)
- New goal: `make_list(2, T₁)`

**Current state:** `Suffix = [_₁|T₁]` where `T₁ = ???`

**CALL 2:** `make_list(2, T₁)`
- Match clause 2 (renamed): `make_list(N₂, [_₂|T₂])`
- Unify: `N₂ = 2`, `T₁ = [_₂|T₂]` (T₂ is unbound)
- New goal: `make_list(1, T₂)`

**Current state:** `Suffix = [_₁|T₁]` where `T₁ = [_₂|T₂]` where `T₂ = ???`

**CALL 3:** `make_list(1, T₂)`
- Match clause 2 (renamed): `make_list(N₃, [_₃|T₃])`
- Unify: `N₃ = 1`, `T₂ = [_₃|T₃]` (T₃ is unbound)
- New goal: `make_list(0, T₃)`

**Current state:** `Suffix = [_₁, _₂, _₃|T₃]` where `T₃ = ???`

**CALL 4:** `make_list(0, T₃)`
- Match clause 1: `make_list(0, [])`
- Unify: `T₃ = []`
- No more goals!

**Final state:** `Suffix = [_₁, _₂, _₃]`

### Why `make_list(0, [])` Doesn't Wipe Out the Array

Because `make_list(0, [])` is matching against `T₃`, not `Suffix`!

The chain:
- `Suffix = [_₁|T₁]` (from Call 1)
- `T₁ = [_₂|T₂]` (from Call 2)
- `T₂ = [_₃|T₃]` (from Call 3)
- `T₃ = []` (from Call 4)

When Call 4 unifies `T₃ = []`, it's only binding that **innermost tail**. The rest of the structure is already built.

### Visual Representation

```
After Call 1: Suffix → [_|?]
After Call 2: Suffix → [_|[_|?]]
After Call 3: Suffix → [_|[_|[_|?]]]
After Call 4: Suffix → [_|[_|[_|[]]]]  which is [_,_,_]
```

Each recursive call adds ONE element to the structure and leaves a hole (`?`) for the next call to fill.

---

## Variable Renaming and Fresh Variables

### The Mechanism

Each time Prolog tries to match a goal against a clause, it creates a **renamed copy** of that clause with brand new variables.

### Example

```prolog
% The clause as written:
make_list(N, [_|T]) :- N > 0, N1 is N - 1, make_list(N1, T).
```

**First invocation** with goal `make_list(3, Suffix)`:
- Prolog creates: `make_list(N₁, [_₁|T₁]) :- ...`
- Unifies: `3` with `N₁`, `Suffix` with `[_₁|T₁]`
- Result: `Suffix = [_₁|T₁]` (binding created!)
- New goal: `make_list(2, T₁)` ← passes T₁ to next call

**Second invocation** with goal `make_list(2, T₁)`:
- Prolog creates: `make_list(N₂, [_₂|T₂]) :- ...` (fresh variables!)
- Unifies: `2` with `N₂`, `T₁` with `[_₂|T₂]`
- Result: `T₁ = [_₂|T₂]` (another binding!)
- New goal: `make_list(1, T₂)` ← passes T₂ to next call

### The Chain

- Goal's `T₁` gets unified with clause's `[_₂|T₂]`
- This creates the link: `Suffix → [_₁|T₁] → [_₁|[_₂|T₂]]`

### Why This Works

- Variable renaming ensures no conflicts between recursive calls
- Unification creates the binding chain
- Each call's "output" (its fresh `T`) becomes the next call's "input" (the goal argument)

---

## Unification: Symmetric and Simultaneous

### Unification is Bidirectional

It doesn't matter which side has the variable. Both sides can have variables, and they all get bound to make the two terms match.

```prolog
Goal:   add(1,    [],    L)
Clause: add(Item, List, [Item|List])
```

**Bindings created:**
- `1` ↔ `Item` → `Item = 1`
- `[]` ↔ `List` → `List = []`
- `L` ↔ `[Item|List]` → `L = [Item|List]` which becomes `L = [1|[]]` = `[1]`

### Unification Happens "All at Once"

"All at once" means the unification is a **single atomic operation** that either:
- Succeeds and creates all bindings, OR
- Fails and creates no bindings

**But** the bindings can reference each other.

### The Process for `add(1, [], L)` with `add(Item, List, [Item|List])`:

**Step 1:** Match argument by argument (structurally)
```
Position 1: 1        ↔ Item        → Item = 1
Position 2: []       ↔ List        → List = []
Position 3: L        ↔ [Item|List] → L = [Item|List]
```

**Step 2:** Substitute known bindings into `L`'s binding
```
L = [Item|List]
L = [1|[]]        (substitute Item=1, List=[])
L = [1]           (simplify)
```

### Key Insight

`L = [Item|List]` is a **structural binding** that contains **references** to other variables. When `Item` and `List` get bound, those bindings **propagate** into `L`'s structure.

---

## Recursion Patterns

There are three main patterns for where the accumulator/result variable appears:

### Pattern 1: Result Built in HEAD (builds as recursion unwinds)

```prolog
del(X, [X|Tail], Tail).
del(X, [Y|RestOfInput], [Y|RestOfOutput]) :- 
    del(X, RestOfInput, RestOfOutput).
```

- Result structure `[Y|RestOfOutput]` is in the **clause head**
- `RestOfOutput` gets filled by the recursive call
- Result is built **backwards** from base case up
- **Russian doll:** Each call wraps the result from the recursive call

**Examples:** `del`, `conc`, `make_list`, `map` operations

### Pattern 2: Accumulator in BODY (builds as recursion descends)

```prolog
reverse_acc([], Acc, Acc).
reverse_acc([H|T], Acc, Result) :- 
    reverse_acc(T, [H|Acc], Result).
```

- The accumulator `[H|Acc]` is in the **recursive call** (body)
- Result is built **forwards** as you go down
- Base case: accumulator becomes the final result
- **Russian doll:** Each call adds to the accumulator and passes it down

**Examples:** `reverse`, `sum`, `length`, `fold` operations

### Pattern 3: Searcher (no result building, just searching)

```prolog
member(X, [X|_]).
member(X, [_|T]) :- member(X, T).
```

- Variable `T` in the **recursive call** (body)
- No result building, just searching
- Base case: found it!

**Examples:** `member`, `contains`, `find`

### When to Use Each Pattern

**Pattern 1 (Result in HEAD):**
- Use when: Building a structure that mirrors the input
- Pros: Natural, declarative, easy to understand
- Cons: Not tail-recursive (for some cases), can be inefficient for large lists

**Pattern 2 (Accumulator in BODY):**
- Use when: Aggregating or transforming with state
- Pros: Tail-recursive, efficient, constant stack space
- Cons: Less intuitive, requires helper predicate

**Pattern 3 (Searcher):**
- Use when: Just checking/finding, not building
- Pros: Simple, direct
- Cons: Only for search, not construction

---

## The Searcher vs Builder Pattern

This is the **critical insight** for understanding predicates like `del`.

### The Base Case Reveals the Pattern

```prolog
del(X, [X|Tail], Tail).
       ↑         ↑
    SEARCH    BUILD
   (input)   (output)
```

**Input side (search/decompose):**
- `[X|Tail]` - **pattern matching** to find X
- We're **searching** for when the head matches X
- **Decomposition**: breaking down the input structure

**Output side (build):**
- `Tail` - **what we return**
- This is the **seed** for building the result
- **Construction**: this becomes the base of the output

### How This Propagates to the Recursive Case

```prolog
del(X, [Y|RestOfInput], [Y|RestOfOutput]) :- del(X, RestOfInput, RestOfOutput).
       ↑                ↑
    Like [X|Tail]    Like Tail
    (searching)      (building)
```

**RestOfInput** corresponds to the `[X|Tail]` pattern:
- We're decomposing/searching through it
- Looking for when it matches `[X|Tail]` (base case)
- Gets **smaller** with each recursive call

**RestOfOutput** corresponds to the `Tail` result:
- We're building/composing with it
- It gets filled with what the base case returns (`Tail`)
- Gets **built** by the recursive call

### The Asymmetry

Both `RestOfInput` and `RestOfOutput` appear in the head AND body, but:

**RestOfInput:**
- **In HEAD**: Extracted from input `[Y|RestOfInput]` (decompose)
- **In BODY**: Passed as input to recursive call (search continues)
- **Direction**: Gets smaller (peeling off elements)

**RestOfOutput:**
- **In HEAD**: Part of output structure `[Y|RestOfOutput]` (compose)
- **In BODY**: Received from recursive call (gets filled)
- **Direction**: Gets built (filling in the hole)

### Why `Y` Appears Twice But Does Different Things

```prolog
del(X, [Y|RestOfInput], [Y|RestOfOutput]) :- del(X, RestOfInput, RestOfOutput).
       ↑ throw away Y   ↑ KEEP Y!
       (for searching)  (for building)
```

By appearing in **both** the input pattern AND the output pattern, `Y`:
- Gets **removed** from the search (we look in `RestOfInput`, not `[Y|RestOfInput]`)
- Gets **preserved** in the result (we build `[Y|RestOfOutput]`, not just `RestOfOutput`)

### Trace Example: `del(b, [a,b,c], L)`

**CALL 1:** `del(b, [a,b,c], L)`
- Match clause 2: `[a,b,c] = [Y|RestOfInput]` → `Y = a`, `RestOfInput = [b,c]`
- Keep `a`: `L = [a|RestOfOutput]`
- New goal: `del(b, [b,c], RestOfOutput)`

**CALL 2:** `del(b, [b,c], RestOfOutput)`
- Match clause 1: `[b,c] = [b|Tail]` → `Tail = [c]`
- Found `b`: `RestOfOutput = [c]`

**Final:** `L = [a|[c]]` = `[a,c]`

---

## Tail Call Optimization

### Definition

When the recursive call is the **last operation** in the clause (nothing happens after it returns), the compiler can reuse the stack frame.

### Example of Tail-Recursive (can be optimized)

```prolog
reverse_acc([H|T], Acc, Result) :- 
    reverse_acc(T, [H|Acc], Result).  % ← Last thing: recursive call
```

### Example of NOT Tail-Recursive

```prolog
reverse_bad([], []).
reverse_bad([H|T], Result) :-
    reverse_bad(T, RevT),             % ← Recursive call
    conc(RevT, [H], Result).          % ← Work AFTER the call returns!
```

### Important: `del` IS Tail-Recursive

```prolog
del(X, [Y|RestOfInput], [Y|RestOfOutput]) :- del(X, RestOfInput, RestOfOutput).
```

This IS tail-recursive because:
- The recursive call is the last goal
- The structure `[Y|RestOfOutput]` is built **during unification** (before the call), not after
- When the call returns, there's nothing left to do

### The Key Test for TCO

**Is the recursive call the last thing in the clause body?**
- If yes → tail-call optimizable
- If no (more goals after) → not tail-call optimizable

### Tail Recursion Pattern vs Tail Call Optimization

These are **different concepts**:

**"Tail recursion pattern"** (code structure):
- Where the accumulator/result variable appears in the code
- Pattern 1 (HEAD) vs Pattern 2 (BODY)
- About **code structure**, not optimization

**"Tail call optimization"** (compiler optimization):
- Whether the recursive call is the **last operation**
- Can the compiler reuse the stack frame?
- About **execution efficiency**

Both `del` (Pattern 1) and `reverse_acc` (Pattern 2) are tail-call optimizable.

---

## Common Pitfalls

### 1. Anonymous Variables Don't Share Values

```prolog
% WRONG - each _ is different!
del(X, [_|Tail], [_|Tail1]) :- del(X, Tail, Tail1).
```

Each `_` is a unique anonymous variable - they're not connected!

### 2. Thinking Variables "Grow"

Variables don't grow - they get bound through nested unifications (Russian dolls).

### 3. Thinking Unification is Sequential

Unification happens simultaneously, not left-to-right. It's constraint satisfaction, not sequential assignment.

### 4. Confusing Input and Output Patterns

Remember: the base case shows which pattern is for searching and which is for building.

---

## Key Insights

1. **Prolog maintains a goal stack** - execution continues until the stack is empty

2. **Variables are renamed in each clause invocation** - ensures no conflicts, creates the binding chain

3. **The Russian Doll Model** - structures are built through nested unifications, not by "growing" variables

4. **Unification is symmetric and simultaneous** - both sides participate equally, bindings can reference each other

5. **The base case defines the roles** - shows what's being searched for (input pattern) and what's being built (output seed)

6. **Searcher vs Builder asymmetry** - same variable name, different behaviors based on position

7. **Y appears twice but does different things** - removed from search, preserved in result

8. **Tail call optimization ≠ tail recursion pattern** - different concepts that happen to overlap

9. **The learning curve is about mental models** - not syntax, but thinking patterns

10. **Traditional Prolog books fail beginners** - they show code without explaining the execution model

---

## Further Reading

- See `recursion_patterns.pl` for comprehensive examples of all three patterns
- See `make_list_js_demo.js` for JavaScript simulations of the Russian doll model
- See `3_2_lists.pl` for detailed commented examples

---

*This document synthesizes insights from a deep exploration of Prolog's execution model, focusing on the mental models needed to understand recursive list processing.*

