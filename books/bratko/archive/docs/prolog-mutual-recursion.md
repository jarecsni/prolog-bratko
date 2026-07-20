# Prolog Unearthed: The Elegance of Mutual Recursion

When you're learning Prolog, there's a moment when the language stops fighting you and starts making sense. For me, that moment came when I realized that **the absence of a clause is just as meaningful as its presence**.

Let me show you what I mean.

## The Problem: Checking List Parity

Say you want to check if a list has an even number of elements. Coming from an imperative background, you might think: count the elements, check if the count is divisible by 2. But that's not how Prolog thinks.

In Prolog, we can define even and odd length through mutual recursion - two predicates that call each other, ping-ponging back and forth until they hit a base case.

## First Attempt: The Obvious Approach

Here's what seems natural:

```prolog
evenlength([]).
evenlength([_|Tail]) :- oddlength(Tail).

oddlength([_]).
oddlength([_|Tail]) :- evenlength(Tail).
```

The logic seems sound:
- An empty list has even length (0 elements)
- A list with one element has odd length
- For any other list, strip one element and flip the parity

Let's test it:

```prolog
?- evenlength([1,2,3]).
false.

?- oddlength([1,2,3]).
true ;
true.
```

Wait. Why two `true` results?

## The Redundancy Problem

When Prolog gives you multiple identical solutions, it means you've created multiple proof paths to the same conclusion. Let's trace what's happening with `oddlength([1,2,3])`:

**Path 1 (via mutual recursion):**
```
oddlength([1,2,3])
├─ Strip one element → evenlength([2,3])
   ├─ Strip one element → oddlength([3])
      ├─ Strip one element → evenlength([])
         └─ Base case matches! ✓
```

**Path 2 (via the explicit base case):**
```
oddlength([1,2,3])
├─ Strip one element → evenlength([2,3])
   ├─ Strip one element → oddlength([3])
      └─ Matches oddlength([_]) base case! ✓
```

We have two ways to prove that a list with odd length is odd: through the mutual recursion bottoming out at `evenlength([])`, and through the explicit `oddlength([_])` base case. The second one is redundant.

## The Elegant Solution

Here's the insight: **we only need one base case**.

```prolog
evenlength([]).
evenlength([_|Tail]) :- oddlength(Tail).

oddlength([_|Tail]) :- evenlength(Tail).
```

That's it. No base case for `oddlength` at all.

"But wait," you might think, "won't this break? How does `oddlength` know when to stop?"

Let's trace it:

**For `oddlength([1,2,3])` (3 elements - odd):**
```
oddlength([1,2,3])
├─ Strip 1 → evenlength([2,3])
   ├─ Strip 1 → oddlength([3])
      ├─ Strip 1 → evenlength([])
         └─ Base case matches! SUCCESS ✓
```

**For `evenlength([1,2,3])` (3 elements - odd):**
```
evenlength([1,2,3])
├─ Strip 1 → oddlength([2,3])
   ├─ Strip 1 → evenlength([3])
      ├─ Strip 1 → oddlength([])
         └─ No clause matches oddlength([])! FAIL ✗
```

The magic is in what happens at the bottom:
- When you call `evenlength` on an even-length list, you bottom out at `evenlength([])` → succeeds
- When you call `evenlength` on an odd-length list, you bottom out at `oddlength([])` → fails (no clause exists)
- When you call `oddlength` on an odd-length list, you bottom out at `evenlength([])` → succeeds
- When you call `oddlength` on an even-length list, you bottom out at `oddlength([])` → fails

The **absence** of an `oddlength([])` clause is what makes the predicate work correctly.

## The Pattern

This reveals a beautiful pattern in Prolog. When you call `evenlength` on a list:

```
0 elements → ends at evenlength([]) ✓
1 element  → ends at oddlength([])  ✗ (no clause)
2 elements → ends at evenlength([]) ✓
3 elements → ends at oddlength([])  ✗
4 elements → ends at evenlength([]) ✓
```

The mutual recursion ensures you ping-pong between the predicates, stripping one element at a time. The parity of the original list determines which predicate you're calling when you hit the empty list. If you start with `evenlength` and the list has even length, you'll end at `evenlength([])` (success). If the list has odd length, you'll end at `oddlength([])` (failure, no clause).

It's like defining even and odd numbers by saying "zero is even, and every other number flips the parity." No arithmetic, no modulo operator - just pure logic and recursion dancing together.

## Why This Matters

This isn't just a clever trick. It's a fundamental shift in how you think about computation:

**Imperative thinking:**
- Count the elements
- Check if count % 2 == 0
- Return true or false

**Declarative thinking:**
- Define what "even length" means in terms of "odd length"
- Define what "odd length" means in terms of "even length"
- Let the absence of a base case express impossibility

In Prolog, **failure is data**. The fact that `oddlength([])` has no clause isn't a bug or an oversight - it's the entire point. It's how we express "an empty list cannot have odd length."

## The Takeaway

When you're writing Prolog, pay attention to what you're *not* writing. Sometimes the most elegant solution is the one where you delete code rather than add it.

The redundant `oddlength([_])` clause seemed helpful - it explicitly stated that a single-element list has odd length. But it was noise. The mutual recursion already expressed that truth implicitly.

This is Prolog at its best: saying more with less, letting logic do the heavy lifting, and trusting that the absence of a clause is just as meaningful as its presence.

---

*This is part of my "Prolog Unearthed" series, where I document the moments when Prolog stops being weird and starts being beautiful. If you're learning Prolog and something finally clicks, I'd love to hear about it.*
