# Prolog — Bratko, second pass

Working through Bratko, *Prolog Programming for Artificial Intelligence*, from page one —
better instrumented this time. *Repetitio est mater studiorum.*

The first pass (Oct 2025 – Jun 2026, up to §4.5) lives untouched in [`archive/`](archive/),
kept for comparison, not consultation.

## Layout

- Folders carry the book coordinate, files carry the meaning:
  `ch03/3.2-list-operations/conc.pl` — never `3_2_conc.pl`, never `solution.pl`.
- Section folders are created lazily, the day that section is opened. No empty scaffolding.
- `lib/` — shared clause bases (e.g. the family database) once they recur across chapters.
- `articles/` — cross-cutting essays; the "missing didactic book" layer, written forward.
- `templates/` — skeletons copied into a new section folder.

## The artifact set

A section is **done** when its folder contains all four:

| Artifact | Named | Holds |
|---|---|---|
| `<concept>.pl` | for its central predicate/idea | the predicates |
| `<concept>.plt` | same stem | plunit tests |
| `trace.md` | fixed | one traceviz-annotated query, control flow made visible |
| `notes.md` | fixed | own commentary — what Bratko *didn't* say |

Related exercises share one `.pl` file named for the theme; distinct ideas get separate files.

## Running tests

```sh
swipl -g "consult('ch03/3.2-list-operations/conc'), load_test_files([]), run_tests" -t halt
```

The `.plt` is found automatically by stem (plunit convention).

## Returning cold

Each chapter's `README.md` is the hemingway bridge: where I stopped, what was warm,
what to retrieve first. Read it before reading the book.
