# Hemingway Bridge

## Where We Are
- Bratko, page 84 — Section 3.4 (Arithmetic)
- Covered GCD example (Euclidean algorithm in Prolog)
- Covered `length/2` — understood the shift from functional thinking to relational (no return values, bind through unification)
- Key insight: `1 + length(T)` is just a term, not a computation. Must use `is` to force evaluation.

## Key Concepts Solidified
- Arithmetic operators (`<`, `>`, `=:=`, `is`) force evaluation; `=` is purely structural unification
- Prolog arithmetic is a one-way street — both sides must be ground (no backward reasoning without CLP)
- Cut (`!`) commits to choices, prunes backtracking
- `gcd(X, X, X).` — elegant base case using repeated variable to enforce equality via unification

## What's Next
- `llength1` — a version of length that does NOT use `is`
- This likely uses successor notation (s(0), s(s(0)), ...) to represent numbers structurally, so arithmetic happens through unification rather than evaluation
- Continue through Section 3.4 arithmetic examples

## Side Threads
- Neuro-symbolic AI as the broader motivation for learning Prolog
- Wolfram's computational metaphysics / ruliad — interesting parallel to symbolic reasoning
- CLP(FD) for constraint-based reasoning (came up naturally when vanilla arithmetic hit its limits)

## Open Questions
- How does the `is`-free length compare in practice? Trade-offs?
- When does successor arithmetic make sense vs evaluated arithmetic?
