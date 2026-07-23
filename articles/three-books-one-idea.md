# Three books, one idea

The justification for reading in parallel at all. Without this file, three books is
three times the pages; with it, each concept gets met three times from three angles,
which is the whole bet.

**One row per concept.** Filled in the day a book actually reaches it — never in advance
from a table of contents. An empty cell means "not reached yet", not "absent".

Columns:

- **B** — Bratko, *Prolog Programming for Artificial Intelligence*
- **CM** — Clocksin & Mellish, *Programming in Prolog*
- **SS** — Sterling & Shapiro, *The Art of Prolog*
- **Std** — Deransart et al., *Prolog: The Standard* — consulted, not read through; the
  tiebreaker when two books disagree, and the arbiter of "is that Prolog or is that SWI?"

## The table

| Idea | B | CM | SS | Std | Delta worth writing |
|---|---|---|---|---|---|
| Facts / relations as data | 1.1 | 1.1 | | | |
| Asking questions | 1.1 | 1.2 | | | |
| Variables in queries | 1.1 | 1.3 | | | |
| Conjunction, backtracking | 1.4 | 1.4 | | | |
| Rules | 1.2 | 1.5 | | | |
| Recursion | 1.3 | | | | |
| Declarative vs procedural meaning | 1.5 | | | | |

Section numbers for CM are from the chapter map and unverified against the physical
copy — correct them on contact.

## How to use the Delta column

The delta is the point of the exercise. Candidates for what actually goes there:

- **Order of introduction.** Which book shows rules before recursion, and what that
  implies about what it thinks is hard.
- **Vocabulary.** Where the two books name the same thing differently, and which name is
  better. Feeds `lexicon.md` when that opens.
- **What each one omits.** An omission is a claim about what a beginner doesn't need yet.
  Often the most revealing cell.
- **Where they disagree outright.** Rare and valuable. `Std` breaks the tie.
- **The example each chooses.** Bratko's family tree and C&M's opening database are doing
  the same didactic job; the difference in choice is a difference in what the book is for.

## Standing rule

When a section here restates one already done in another book, the note to write in the
section's own `notes.md` is the *delta* — not the material a second time. This file is
where the deltas accumulate into an argument.
