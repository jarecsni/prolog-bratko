# Thinking Declaratively: A Mental Model for Prolog Beyond Recursion

A companion to [recursion.md](recursion.md). Where that article explains *how* Prolog executes, this one is about *what you write* — and the strange habit-flip required to write it.

## Table of Contents
1. [The Fundamental Shift](#1-the-fundamental-shift)
2. [The Anatomy of a Declaration](#2-the-anatomy-of-a-declaration)
3. [The Body's Dual Role](#3-the-bodys-dual-role)
4. [Choice Points and the Search Engine](#4-choice-points-and-the-search-engine)
5. [Modes: Predicates as Relations](#5-modes-predicates-as-relations)
6. [Operators: Surface Syntax Over Trees](#6-operators-surface-syntax-over-trees)
7. [Why Bratko Teaches Operators](#7-why-bratko-teaches-operators)
8. [A Taxonomy of Patterns](#8-a-taxonomy-of-patterns)
9. [Closing: Where Fluency Lives](#9-closing-where-fluency-lives)

---

## 1. The Fundamental Shift

> **"When we program in Prolog, we express the possible truths, and leave it to Prolog to traverse them. The difficulty lies in stopping yourself from thinking in terms of creating the traversal — you must think instead in terms of the static pillars of the problem."**

That is the whole game. The rest of this article is unpacking what those words mean.

### Imperative habits

If your background is JavaScript, Python, Java, Swift — anything in the Algol family — your mind is *trained for verbs*: iterate, increment, compare, push, return. Programs are recipes. You describe **what to do, in what order**, with **what state**.

```python
def maxlist(numbers):
    best = numbers[0]
    for n in numbers[1:]:
        if n > best:
            best = n
    return best
```

This reads naturally because every line is a *step*. Step 1: take the first element. Step 2: iterate. Step 3: compare. Step 4: maybe update. Step 5: return. **The control flow is the program.** The data is something the steps act on.

### Declarative thinking

Now look at the Prolog equivalent:

```prolog
maxlist([X], X).
maxlist([H|T], Max) :-
    maxlist(T, MaxT),
    max_(H, MaxT, Max).
```

There are no steps. No "first do this, then do that." Instead, two **statements of truth** about `maxlist`:

- *The maximum of a single-element list is its only element.*
- *The maximum of a longer list is the larger of its head and the maximum of its tail.*

That is all. There is no loop, no counter, no "current best" variable, no return. You have **defined** what `maxlist` *means*, and Prolog handles the rest.

### Programming = Logic + Control

In 1979, Robert Kowalski compressed this idea into a slogan that still defines the field:

> Programming = Logic + Control

The **logic** is the programmer's responsibility: declare what is true, what relationships hold, what counts as a solution. The **control** — the search, the traversal, the order of attempts — is the engine's responsibility.

Pure Prolog is the experiment of "how much of the control can the engine take off our hands?" The answer, mostly, is: **almost all of it**. You write the logic; Prolog does the search.

This is the deep reason Prolog feels alien at first. Every habit you brought from imperative programming is a *control* habit. Loops, conditionals, mutation, early-exit — these are all ways of telling the machine *how to do the work*. In Prolog, the machine already knows how. Your job is to tell it *what counts as success*.

### The new question to ask

Stop asking: *"What steps must the machine perform to compute the answer?"*

Start asking: *"What is true of a valid answer?"*

That single substitution — verbs to nouns, procedure to definition, *quomodo* to *quid* — is the entire paradigm shift. Once it clicks, Prolog opens up. Until it does, every program will feel like swimming against the current.

---

## 2. The Anatomy of a Declaration

Every recursive Prolog predicate has the same anatomy. Two parts, with distinct logical roles.

### The nucleus

The **nucleus** is the irreducible truth — the smallest, simplest case where the answer requires no further reasoning. It anchors the entire definition. Without it, the recursion has nothing to bottom out on (*ex nihilo nihil fit* — nothing comes from nothing).

```prolog
maxlist([X], X).
sumlist_([], 0).
ordered([]).
ordered([X]).
between(N1, N2, N1) :- N1 =< N2.
```

Each of these is a complete statement of a single fact: a special case whose answer is self-evident. No recursion, no construction — just a declaration anchored to the structure of the input.

### The extension

The **extension** is a structural equivalence: it says how the answer for a *bigger* problem follows from the answer for a *smaller* one. It does not introduce new truths; it *reduces* a complex case to a simpler one, eventually bottoming out on the nucleus.

```prolog
maxlist([H|T], Max) :-
    maxlist(T, MaxT),
    max_(H, MaxT, Max).

sumlist_([H|T], Sum) :-
    sumlist_(T, SumT),
    Sum is H + SumT.

ordered([A, B | T]) :-
    A =< B,
    ordered([B | T]).

between(N1, N2, X) :-
    N1 < N2,
    N1Next is N1 + 1,
    between(N1Next, N2, X).
```

These are not algorithms. Read them as *logical equivalences*:

- "The max of `[H|T]` *equals* `max_(H, MaxT)` where `MaxT` is the max of `T`."
- "`X` is in `[N1, N2]` *if and only if* `X` is in `[N1+1, N2]` (when `N1 < N2`)."

That "if and only if" is doing all the work. It is not a step; it is a *definition*. Prolog operationalises it via depth-first search, but the statement itself makes no reference to time, motion, or order.

### A comparative gallery

| Predicate | Nucleus | Extension |
|---|---|---|
| `sumlist_` | sum of `[]` is `0` | sum of `[H\|T]` is `H +` sum-of-`T` |
| `maxlist` | max of `[X]` is `X` | max of `[H\|T]` is the larger of `H` and max-of-`T` |
| `ordered` | `[]` and `[X]` are ordered | `[A,B\|T]` is ordered iff `A =< B` and `[B\|T]` is ordered |
| `between` | `N1` is in `[N1, N2]` if `N1 =< N2` | `X` is in `[N1, N2]` iff `X` is in `[N1+1, N2]` |
| `length` | length of `[]` is `0` | length of `[_\|T]` is `1 +` length-of-`T` |

Five predicates, five different domains, identical anatomy. **Nucleus + extension = the entire logical core of recursive Prolog.**

### Why this is not a procedure

A reader from imperative-land sees `maxlist([H|T], Max) :- maxlist(T, MaxT), ...` and thinks: "Ah, first you recurse on the tail, *then* you compute the max." That is the imperative reading — and it is operationally correct.

But the *logical* reading is different. The clause does not say "first do A, then do B." It says **"the head is true *provided* A and B are both true."** Conjunction in Prolog is logical AND, not sequencing. The fact that Prolog evaluates left-to-right is a *control* decision the engine makes. Your *declaration* is order-agnostic.

This distinction matters. The same clause can run **forward** (compute the max from a list) or **partially backward** (verify that a given value is the max of a list). The clause did not change; only the binding pattern of the query did. **Reversibility is the gift of declarative-first thinking** — and it is the gift you lose the moment you start writing predicates as procedures with one privileged direction.

---

## 3. The Body's Dual Role

The body of a clause does two distinct things, although syntactically they look identical. Recognising the distinction is the difference between writing Prolog and merely typing it.

We'll start with the surface split — *guards* vs *outcomes* — and then see that it dissolves into something more fundamental.

### Guards: goals that test

Some body goals exist to **verify** that the clause applies. They commit no work; they succeed or fail. If they fail, the clause is abandoned and Prolog tries the next.

```prolog
max_(X, Y, X) :- X >= Y.        %  X >= Y is a guard
ordered([A, B | T]) :-
    A =< B,                      %  A =< B is a guard
    ordered([B | T]).
between(N1, N2, X) :-
    N1 < N2,                     %  N1 < N2 is a guard
    ...
```

Guards are the *if* of declarative programming. They gate the clause, ensuring it only fires when the conditions are right. They never bind variables (well-formed guards don't); they only check.

### Outcomes: goals that establish

Other body goals exist to **construct** the answer. They bind variables, perform unifications, do arithmetic.

```prolog
Sum1 is Sum - N,                 %  outcome: bind Sum1
Var = Val3,                      %  outcome: bind Var
subsum(Set, Sum1, Sub).          %  outcome: recurse to produce Sub
```

These goals *make things true*. They establish the bindings that the clause head was claiming.

### The natural ordering

This duality gives every Prolog rule its narrative shape:

```prolog
head(Args) :-
    guard1, guard2, ...,        %  verify
    outcome1, outcome2, ....    %  establish
```

The conjunction is logically symmetric (you could reorder without changing meaning), but **operationally** the order matters: guards first means failing fast. Why do expensive construction work if you'll fail a check three lines later?

### Failure as universal control

This is why Prolog needs no `if` statement. The combination of *guards-that-fail* and *multiple-clauses-as-fallback* gives you the entire control-flow vocabulary of conditional execution — for free, without any new constructs.

```python
if val1 > val2:
    var = val3
else:
    var = val4
```

```prolog
if Val1 > Val2 then Var := Val3 else Var := Val4 :-
    Val1 > Val2,
    Var = Val3.
if Val1 > Val2 then Var := Val3 else Var := Val4 :-
    Val1 =< Val2,
    Var = Val4.
```

Two clauses, identical heads, disjoint guards. Try the first; if its guard fails, try the second. **The case discrimination is invisible** — it falls out of failing-clauses-trigger-backtracking. *Tertium non datur*: the guards are mutually exclusive and exhaustive, so exactly one clause fires.

This is also why an `if`-then-else *interpreter* in Prolog is two lines of code: you are using Prolog's own conditional mechanism — failure plus clause fallback — to implement the user-visible one. The semantics layer is paper-thin because the substrate already does what you need.

### Guards as semantic heads

Here is a deeper observation about what guards are *really* doing.

Look at the head of a clause and at its guards side by side:

```prolog
max_(X, Y, X) :- X >= Y, ... .
%   ^^^^^^^^^^    ^^^^^^
%   head:         guard:
%   structural    computed
%   filter        filter
```

Both are doing the **same job**: they decide whether the clause is even *applicable* to the current query. The head asks "does the query's term shape match this clause?" The guard asks "does this precondition evaluate to true?" Either failure rejects the clause and sends Prolog backtracking to the next alternative.

The head and the guards are not really different categories of thing. They are two *flavours* of the same act: **gating**. One gates by structure, the other gates by computation. Both happen before the clause's real work begins.

This means the dual role in the section title is, on closer inspection, a **triplet**:

| Role | Where | What it does |
|---|---|---|
| Structural gate | Head pattern | Filters by term shape (unification) |
| Semantic gate | Body guards | Filters by computed predicates (`>=`, `member`, `\+ p`) |
| Establishment | Body outcomes | Binds variables, constructs answers, performs the work |

The real cleavage in a clause is not between **goals in the head** and **goals in the body** — it is between **goals that gate** and **goals that establish**.

This reframing matters because it changes how you *write* clauses. Once you see head and guards as "the gate," you instinctively reach for whichever expresses your filter most naturally. A case-split that can be done structurally goes in the head (cheaper, faster, more reversible). A case-split that needs arithmetic goes in the guards (necessary, but less reversible). The decision is no longer "head or body?" — it is "which kind of filter does this case-split want to be?"

Some Prolog dialects, and the constraint-logic-programming family (CLP), blur this boundary even further: predicates like CLP(FD)'s `#=/2` act as *both* structural and semantic constraints simultaneously, gating without committing to one direction. They reveal that head-vs-guard was always a syntactic accident; logically, both points sit on the same continuum of **conditions for clause applicability**.

---

## 4. Choice Points and the Search Engine

The most disorienting thing about Prolog, for an imperative programmer, is that a single query can produce **many answers**. Press `;` and another arrives. The program did not "return" once — it kept going.

This is non-determinism, and it is not a feature added on top of Prolog. It is the *default*.

### The signature of backtracking: overlapping clauses

Wherever a query could match more than one clause head, Prolog leaves a **choice point** — a bookmark saying "I tried clause N, but clauses N+1, N+2... are still options." On success, the user can press `;` to revisit the bookmark. On failure, the engine *automatically* revisits it.

So writing a non-deterministic predicate is mechanically simple: write multiple clauses whose heads can unify with the same query. **The choice points emerge from the overlap.**

```prolog
subsum([], 0, []).
subsum([N|Set], Sum, [N|Sub]) :-          % INCLUDE clause
    Sum1 is Sum - N,
    subsum(Set, Sum1, Sub).
subsum([_|Set], Sum, Sub) :-              % SKIP clause
    subsum(Set, Sum, Sub).
```

For any non-empty input list, **both** the include and skip clauses are eligible. Prolog tries one, leaves the other as a choice point, recurses. The whole search tree of 2ⁿ include/skip decisions falls out of this single fact.

### The tree, not the trace

The right mental image is not "Prolog executes" but "Prolog explores." Picture a tree:

- Each node is a goal.
- Each branch is an attempt to satisfy that goal by some clause.
- Leaves are either ✓ (a successful proof terminating at a fact) or ✗ (a failure).

Your query produces an answer for every ✓ leaf, in depth-first left-to-right order. Failures are silent. The "loop" you imagine is the engine walking that tree.

This is why your `subsum` definition, three lines long, suffices to enumerate all subsets summing to a target. You did not write the loop; you described the tree. The walking is Prolog's job.

### Tertium non datur: the include/skip choice

The subsum predicate's two recursive clauses encode a fundamental fact about subsets:

> Every element of the input is either *in* the output subset, or *not in* it.

There is no third option. *Tertium non datur* — the law of the excluded middle, expressed in code. Each clause embodies one of the two possibilities; together they cover the space exhaustively.

This is the structural reason a 3-line predicate suffices: subsets are an inherently binary recursive structure, and Prolog's two-clauses-equals-binary-choice idiom matches the structure exactly.

### Failure as silent pruning

When the search tree has 2⁵ = 32 leaves and only 3 succeed, you see 3 answers. The 29 failures happen invisibly — the engine walks those branches, hits a base case with the wrong target, finds no matching clause, backtracks. **Failure is not an error or an exception; it is a routine signal to the engine to try something else.**

This is the deepest single fact about Prolog's execution model: *no match = fail; fail = try the next alternative.* Everything else is consequences.

---

## 5. Modes: Predicates as Relations

In an imperative language, a function has a *signature*: known input types, one return type. The direction of computation is fixed by the language itself — arguments flow in, a value flows out.

In Prolog, a predicate is a **relation**. It does not distinguish inputs from outputs at the language level; it only distinguishes *bound* (instantiated) arguments from *unbound* (variable) ones. The same predicate, queried with different binding patterns, performs different computations.

This is the **mode grid** of a predicate: the set of input/output combinations for which it works.

### The relational fantasy

Consider `max_(X, Y, Max)`. The clauses:

```prolog
max_(X, Y, X) :- X >= Y.
max_(X, Y, Y) :- X < Y.
```

In an ideal world, you could query this in *any* direction:

- `max_(3, 7, M).` — compute the max of 3 and 7 → `M = 7`. ✓
- `max_(3, 7, 7).` — verify that 7 is the max of 3 and 7. ✓
- `max_(X, 5, 7).` — find an X such that the max of X and 5 is 7. ✗ instantiation error.
- `max_(X, Y, 5).` — enumerate pairs whose max is 5. ✗ instantiation error.

The relational fantasy says "all four should work." Reality is harsher: only the first two run cleanly. The reason is the body's arithmetic guards (`>=`, `<`). Arithmetic comparison in Prolog requires both sides be ground numbers; with unbound arguments, the guard throws an instantiation error.

### What collapses the relation

| Body construct | Effect on modes |
|---|---|
| Pure unification (`=`, head sharing) | Reversible — predicate runs in many directions. |
| Structural pattern matching | Reversible — `[H\|T]` works both as decomposition and construction. |
| `is/2`, `<`, `=<`, `>`, `>=`, `=:=`, `=\=` | **Requires ground operands** — collapses the relation to specific input modes. |
| Negation (`\+`) | Requires goal to be ground; works only as a test. |
| Cuts (`!`) | Removes choice points; may silently break some modes. |

The more arithmetic you sprinkle in, the more *moded* the predicate becomes. Pure structural predicates like `append/3`, `member/2`, `last/2` retain near-full reversibility. Predicates built on arithmetic guards behave like functions with privileged directions.

### The mode grid for subsum

```prolog
subsum([1,2,5,3,2], 5, Sub).      % (+, +, -)  enumerate subsets        ✓
subsum([1,2,5,3,2], 5, [2,3]).    % (+, +, +)  verify a subset           ✓
subsum([1,2,5,3,2], 5, [_,_]).    % (+, +, partial) filter by shape     ✓
subsum([1,2,5,3,2], Sum, [2,3]).  % (+, -, +)  compute sum from subset  ✗ instantiation error
```

The fourth mode fails because the include clause does `Sum1 is Sum - N` — `Sum` must be ground. A *different* formulation (summing up rather than subtracting down) would support that mode but lose the elegant base case. Each formulation makes different trade-offs in the mode grid.

### Designing for modes

When you write a new predicate, the question to ask is not just "does this compute the right answer?" but **"in which modes does it run?"** This is the Prolog equivalent of choosing function signatures — except instead of one direction, you are choosing a *set* of supported directions.

Sometimes you want maximum reversibility (write structurally; defer arithmetic). Sometimes you want efficiency in one specific mode (use arithmetic for fast tests). Both are legitimate; the choice depends on how the predicate will be used.

The mature Prolog programmer reads a predicate and instinctively sees its mode grid: "this is `+ + -` only, because of the `is`"; "this is fully reversible, like `append`"; "this works in three modes but throws in the fourth." That instinct is most of what fluency consists of.

---

## 6. Operators: Surface Syntax Over Trees

So far we have written Prolog programs in their natural functor form: `max_(X, Y, M)`, `between(1, 10, X)`, `[H|T]`. Now consider this line:

```prolog
if X > Y then Z := X else Z := Y
```

It does not look like Prolog at all — yet, with four `op/3` declarations, Prolog parses it as a perfectly normal term. Operators turn Prolog into a language with **user-extensible syntax**, and understanding them is the gateway to Bratko's later chapters on AI and symbolic computation.

### The key insight: operators are pure sugar

`op/3` does **not** add semantics. It does **not** create new data structures. It does **not** introduce control flow. It only teaches the parser to recognise a particular surface pattern and build a tree from it.

The line above, after parsing, is exactly the term:

```prolog
if(then(>(X,Y), else(:=(Z,X), :=(Z,Y))))
```

A normal nested compound term. Operators are *how it was written*; this is *what it is*. The two are interchangeable — `write_canonical/1` will print the functor form; the prompt's binding report will use operator form.

### Precedence as outerness

Every operator declaration has a precedence number from 1 to 1200. The rule, condensed:

> **Higher precedence number = closer to the root of the tree.**

A simple chain of declarations:

```prolog
:- op(1000, fx,  if).
:- op(900,  xfx, then).
:- op(800,  xfx, else).
:- op(700,  xfx, :=).
```

`if` (1000) is the outermost; `:=` (700) is innermost. The parser, given a flat token stream, finds the highest-precedence operator that fits, makes it the root, and recursively parses each side at strictly lower precedence. The tree assembles itself outside-in, ending with the highest-precedence operator at the root.

This is the *same engine* that parses arithmetic. `2 + 3 * 4` parses as `2 + (3 * 4)` because `*` has lower precedence (tighter binding) than `+`. Prolog generalises this single mechanism to *every* infix syntax — clause necks, conjunction, disjunction, your custom operators. There is no special parser for arithmetic, or for clauses, or for `if/then/else`. There is one parser, driven by `op/3` declarations.

### Fixity: prefix, infix, postfix

| Type code | Fixity | Notes |
|---|---|---|
| `fx`, `fy` | Prefix | One arg on the right. `\+ X`, `- X`. |
| `xfx`, `xfy`, `yfx` | Infix | One arg each side. `A + B`, `X = Y`. |
| `xf`, `yf` | Postfix | One arg on the left. (Rare in Prolog.) |

The `x` means "strictly tighter precedence required on that side"; the `y` means "same-or-tighter allowed." For most user-defined operators, the strict `x` versions are the safe default.

### Why this is profound

Pause and consider what `op/3` lets you do. With four declarations, you have **extended Prolog's syntax** to accept a domain-specific notation that reads almost like English prose:

```prolog
if temperature > 100 then alarm := critical else alarm := normal
```

You did not modify the parser. You did not compile a new grammar. You just filled in four rows of an operator table, and Prolog's general-purpose parser handled the rest.

This is why Prolog is sometimes (only half-jokingly) called *"the language with no syntax."* The surface looks however you want it to look, because the surface is configurable. The *substrate* is just terms — and terms have no syntax; they only have structure.

### From syntax to semantics

A term built by your custom operators is **inert**. It has shape but no meaning. To give it meaning, you write **clauses that pattern-match on the term and execute it** — an *interpreter*.

```prolog
if Val1 > Val2 then Var := Val3 else Var := Val4 :-
    Val1 > Val2,
    Var = Val3.
if Val1 > Val2 then Var := Val3 else Var := Val4 :-
    Val1 =< Val2,
    Var = Val4.
```

These clauses give the term its operational meaning. The user writes `if X > Y then Z := X else Z := Y.` at the prompt; Prolog parses it (using the operators) into a tree; calls it as a goal; finds these clauses; executes the body. **Syntax and semantics are cleanly decoupled** — the first lives in `op/3` declarations, the second in normal clauses.

This is the architecture of every DSL ever embedded in Prolog: operators for the surface, clauses for the meaning. Two lines of code each, often, for very expressive results.

---

## 7. Why Bratko Teaches Operators

Operators feel like a digression when you first encounter them. *We were just doing arithmetic — why this detour into syntax extension?*

Because Bratko's book is *Prolog Programming for Artificial Intelligence*, and operators are foundational to several AI subfields his later chapters cover. The exercise that asks you to define `if`, `then`, `else`, `:=` is a *kindergarten preview* of how serious symbolic AI in Prolog looks.

### Knowledge representation

Classic AI represents knowledge as facts and rules in a form humans can read. With operators:

```prolog
john owns car.
A causes B if A precedes B.
mortal(X) :- man(X).
```

Without operators, these become `owns(john, car)`, `:-(causes(A,B), precedes(A,B))`, and so on — equivalent, but unreadable. Expert systems often contained *thousands* of such statements; operator syntax was the difference between writeable knowledge and unwriteable LISP-style nesting.

### Symbolic computation

AI traditionally manipulates symbolic expressions: logical formulas, mathematical expressions, parse trees. A symbolic differentiator might be written as:

```prolog
diff(X^2 + 3*X + 5, X, Result).
```

Without operators, that argument becomes `+(+(^(X,2), *(3,X)), 5)` — a tree of seven nested functor calls. Bratko covers symbolic differentiation explicitly, and it would be nearly unwritable without operator notation.

### Rule-based systems

Production rules — the workhorse of expert systems — need rule syntax. With operators you can define:

```prolog
if temperature > 100 and pressure_low then alarm := critical.
```

This is an expert system rule, expressed in the surface syntax. Bratko's later chapters build *meta-interpreters* for exactly this kind of rule language. Your `if`-then-else interpreter is the toy version; the production-system version differs only in scale and ambition.

### DCGs: the operator-powered DSL

The single most famous DSL in Prolog — **Definite Clause Grammars** for natural-language parsing — is built entirely on one operator:

```prolog
sentence --> noun_phrase, verb_phrase.
noun_phrase --> [the], noun.
```

The `-->` operator is declared once; from that single declaration, Prolog gains the ability to define grammar rules in near-BNF syntax. Bratko uses DCGs extensively for parsing examples. The `op/3` mechanism makes that possible.

### The pedagogical architecture

So when Bratko slips an operator exercise into Chapter 3, it is not a curiosity. It is **groundwork**. Chapters 4 onwards rely on this skill constantly — to build symbolic differentiators, theorem provers, expert system shells, game-playing programs, meta-interpreters, parsers. The `if/then/else` exercise looks small, but it is a doorway.

The pattern you have just learned — **operators for surface syntax + clauses for interpretation** — is the dominant style of "AI in Prolog" as Bratko teaches it. Spotting that early is spotting Bratko's pedagogical architecture, which is a sign you are reading him well.

---

## 8. A Taxonomy of Patterns

You have now seen, across the exercises of Chapter 3, *five distinct uses* of the same minimal substrate (clauses + conjunction + unification). Worth naming them.

### Pattern 1: Case discrimination at the head

Two clauses whose heads share most variables but differ in one critical position. The differentiation happens at unification time, and a guard in the body enforces mutual exclusivity.

```prolog
max_(X, Y, X) :- X >= Y.
max_(X, Y, Y) :- X < Y.
```

Use when the case split corresponds to a *structural* difference in the answer.

### Pattern 2: Recursive fold

A base case + a recursive case where the recursion threads a value back up through a combiner.

```prolog
sumlist_([], 0).
sumlist_([H|T], Sum) :- sumlist_(T, SumT), Sum is H + SumT.
```

This is the functional-programming `foldr` pattern, expressed in Prolog. `length`, `sumlist`, `maxlist`, `reverse` — all instances of this single shape.

### Pattern 3: Sliding window

Pattern-match on adjacent elements with `[A, B | T]`, check a relationship between them, recurse on `[B | T]` to keep the window moving.

```prolog
ordered([A, B | T]) :- A =< B, ordered([B | T]).
```

Use when the property to check is about *consecutive pairs* — ordering, monotonicity, no-duplicates, run-length encoding, etc.

### Pattern 4: Overlapping clauses for non-deterministic choice

Two clauses, both eligible for the same query, encoding a *tertium non datur* binary decision. Prolog's backtracking enumerates the resulting search tree.

```prolog
subsum([N|Set], Sum, [N|Sub]) :- Sum1 is Sum - N, subsum(Set, Sum1, Sub).
subsum([_|Set], Sum, Sub)     :- subsum(Set, Sum, Sub).
```

Use whenever the problem decomposes into "for each element, two possibilities" — subsets, permutations, partitions, choose-one-of-many.

### Pattern 5: Same head + disjoint guards

Two clauses with identical heads, differentiated only by guards in the body. The case split depends on a *computed* condition that cannot be expressed by head unification alone.

```prolog
if Val1 > Val2 then Var := Val3 else Var := Val4 :-
    Val1 > Val2, Var = Val3.
if Val1 > Val2 then Var := Val3 else Var := Val4 :-
    Val1 =< Val2, Var = Val4.
```

Use when the case split is *arithmetic* or *semantic* rather than *structural*.

### Pattern 6 (bonus): Generator + filter

A non-deterministic predicate (generator) combined with one or more guard predicates (filters). The generator enumerates candidates; the filters reject the bad ones; backtracking handles all of it for free.

```prolog
divisors(N, D) :- between(1, N, D), 0 is N mod D.

pythag(A, B, C) :-
    between(1, 20, A),
    between(A, 20, B),
    between(B, 20, C),
    A*A + B*B =:= C*C.
```

This is the kernel of every brute-force constraint-satisfaction program in Prolog. Generators on top, constraints below, conjunction joining everything. Most non-trivial Prolog programs have this shape at their heart.

### Summary table

| Pattern | Signature | Use case |
|---|---|---|
| Case at head | Different heads, optional guards | Structural case split |
| Recursive fold | Base + recurse + combine | Compute a value from a list |
| Sliding window | `[A,B\|T]` + recurse on `[B\|T]` | Property of consecutive elements |
| Overlapping clauses | Two clauses, same head shape, both eligible | Binary choice per step (enumeration) |
| Same head + disjoint guards | Identical heads, mutually exclusive body guards | Computed case split |
| Generator + filter | Non-det generator(s) + guard(s) | Search / constraint satisfaction |

These six patterns cover the vast majority of Chapter 3 Prolog. Once they are muscle memory, the language feels *small* — because it is. The complexity comes from how richly these few patterns combine.

---

## 9. Closing: Where Fluency Lives

Fluency in Prolog is not the ability to write any specific predicate. It is the ability to **read a problem and immediately see its declarative shape**:

- *What are the static pillars? What is invariantly true of any solution?*
- *What is the nucleus — the smallest case where the answer is self-evident?*
- *How does the bigger case reduce to a smaller one?*
- *Where is the case split? At the head (structural) or in the guard (computed)?*
- *Is this a generator or a function? What modes does it need to support?*

These questions are not steps in a method. They are habits of attention. They take months to settle in — there is no rushing them. But every exercise you do, every predicate you write, every trace you puzzle through, builds the same neural pathways. *Repetitio est mater studiorum* — repetition is the mother of learning, and Prolog rewards repetition uncommonly well, because the patterns are few and re-applicable everywhere.

The moment fluency arrives, you will notice it not as a triumph but as an absence — the disappearance of the friction. The first time you stop translating from "how do I compute this?" to "what is true of this?" and just *write the relation directly* — that is the crossing. From then on, Prolog is a different language.

Captain Picard's android first officer once observed: *"It is not enough that I observe. I must understand."* That is the work, in any discipline worth doing.

Welcome aboard.
