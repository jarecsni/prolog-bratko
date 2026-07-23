# Objective Prolog

*Started 2026-07-21, from a remark in Clocksin & Mellish ch01 distinguishing how
object-oriented languages interpret "objects" from how Prolog does.*

The idle question was: **would there be any point in an "Objective Prolog"?**

The answer is yes, the point has been taken, and the thing exists — but the useful part
isn't the yes. It's that "OO" turns out to be three separate wishes, and Prolog answers
each one differently. One it already grants more generously than OO does. One it is right
to refuse. Only the third is a genuine gap.

## First: a term is a description, not an entity

The thing C&M are pointing at. In an object-oriented language an object is a *thing*:
it has identity, it owns state, it persists through change, two references can name the
same one, and mutating it through one reference is visible through the other.

`person(john, 42)` is none of that. It's a statement of structure — a description. It has
no identity distinct from its content; there is no "the same person, now aged 43"; there
is no aliasing, because there is nothing to alias. Two identical terms are simply
identical. Prolog's unit of meaning is the **relation**, not the entity, and a relation
has no location for state to live in.

Everything below follows from this one asymmetry.

## The three wishes

### 1. Dispatch — Prolog already wins

A method call `obj.foo(x)` chooses an implementation based on *one* distinguished
argument: the receiver. Everything else is just parameters.

Prolog chooses based on **all** arguments simultaneously, by unification. Clause selection
is dispatch, and it is dispatch on the entire head.

Sharpen it: first-argument indexing *is* single dispatch. The first argument of a
predicate plays exactly the role the receiver plays in a method call, and the compiler
even optimises it the same way — a jump table on the principal functor. The difference is
that Prolog doesn't stop there. The other arguments participate too, which is the
generalisation mainstream OO never got. (CLOS multimethods are the exception that proves
the rule, and they're usually described as exotic.)

So adding OO-style dispatch to Prolog would be a **restriction**, not an addition. This
wish is already granted, and granted better.

### 2. Encapsulated mutable state — a category error, in its naive form

An object owns state that changes while identity stays fixed. To get that in Prolog you
reach for `assert/1` and `retract/1` — and that is the door through which the declarative
reading walks out. The clause database stops being a set of true statements and becomes a
mutable heap with terrible syntax.

But there's a principled version, and it's the good idea in this whole essay:

> **An object is a perpetual process consuming a stream of messages. Its state is carried
> in the arguments of a tail-recursive call. Its identity is the stream.**

No mutation, no database side effects — the state "changes" because each recursive call
receives different arguments, exactly as an accumulator does. This is the concurrent
logic programming tradition; Shapiro and Takeuchi wrote it up in the early 1980s, which
means the machinery for it is Sterling & Shapiro territory and will show up on the shelf.

**And I have already written one without noticing.** In
[`books/bratko/archive/beginnings/2_5_monkey_with_state.pl`](../books/bratko/archive/beginnings/2_5_monkey_with_state.pl)
the monkey's world-state is a term threaded through a recursive predicate. That is an
object's life history, laid out flat in the trace instead of hidden in a heap cell. The
accumulator pattern and the object are the same shape seen from two directions — which
is the kind of thing neither book says out loud.

So this wish is half category error, half already-solved-differently.

### 3. Inheritance with defaults and overriding — the real gap

Nothing in pure Prolog gives you *"inherit unless overridden"*.

By hand, it costs an explicit `isa/2` chain, a predicate that walks it, and a cut to stop
the walk at the most specific answer — and the cut is there because the behaviour is
**non-monotonic**: adding the fact that penguins swim must *withdraw* the previously
derivable conclusion that penguins fly. Classical logic doesn't do withdrawal. That's why
this doesn't fall out of resolution, and why it has to be built.

It's also the wish with the strongest AI pedigree — frames, semantic networks, inheritance
hierarchies with exceptions — territory Bratko reaches later in the book.

## The thing already exists: Logtalk

[logtalk.org](https://logtalk.org/) — v3.100.1 as of May 2026, actively maintained,
by Paulo Moura. Installed here with `brew install logtalk`; `swilgt` starts SWI-Prolog
with it loaded.

It's pitched as a language, and mostly is one: its own syntax, its own inheritance
semantics, its own libraries, tooling (`lgtunit`, `lgtdoc`), and compile-time linting.
But it has no runtime — it's a **transcompiler** onto a backend Prolog, and the backend
stays visible. The honest analogy is **TypeScript to JavaScript**: real language identity,
adds real machinery, compiles away to the host, treats the host as very nearly a subset.
Plain Prolog clauses inside an object are just Prolog clauses. You never stop writing
Prolog; you write it inside a bigger enclosure.

Its object model is wider than the OO dichotomy: prototypes (`extends`), classes
(`instantiates` / `specializes`), protocols (interfaces), and **categories** — composable
chunks of predicates mixed into objects, closer to traits or mixins than to classes.

The whole argument, in nine lines
([`sandbox/logtalk/hierarchy.lgt`](../sandbox/logtalk/hierarchy.lgt)):

```logtalk
:- object(animal).
    :- public(moves/1).
    moves(walking).
:- end_object.

:- object(bird, extends(animal)).
    moves(flying).
:- end_object.

:- object(penguin, extends(bird)).
    moves(swimming).
:- end_object.
```

Verified output:

```
animal::moves  -> walking
bird::moves    -> flying
penguin::moves -> swimming
penguin::ancestral_move -> flying     % via ^^moves(X), the "super" call
```

Note what `::` and `^^` are doing: `::` sends a message to a named object, `^^` calls the
definition this one overrode. Wish #3, promoted from a hand-rolled `isa/2` walk to syntax.

## The verdict

Objective Prolog is worth having, but not for the reason the name suggests. Its
dispatch wish is redundant. Its state wish is one Prolog is *right* to resist, and which
has a better answer in the process reading. Its structuring wish — namespaces, interfaces,
inheritance with defaults, reuse beyond copy-and-rename — is legitimate, unmet by plain
Prolog, and is what Logtalk actually sells.

Which also means it sits strictly **downstream** of Prolog. Nothing here competes with
learning the language. Revisit when Bratko reaches frames and inheritance networks — that's
the chapter where the absence will be felt rather than argued.

## To verify

- [ ] Shapiro & Takeuchi, *Object Oriented Programming in Concurrent Prolog* — believed
      New Generation Computing 1(1), 1983. Confirm the citation before quoting it anywhere.
- [ ] Locate the exact C&M passage that started this, and quote it properly.
- [ ] Check whether Logtalk's inheritance is genuinely non-monotonic or whether it
      resolves overriding statically at compile time. The claim above assumes the former.
