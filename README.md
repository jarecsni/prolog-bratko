# Prolog studies

A long-term study of Prolog, run across several books rather than one. Each book keeps its
own shelf under [`books/`](books/); the conventions below are the constant that spans them.

*Repetitio est mater studiorum.*

## The shelf

| Book | Folder | State |
|---|---|---|
| Bratko, *Prolog Programming for Artificial Intelligence* | [`books/bratko/`](books/bratko/) | second pass, ch01 |
| Sterling & Shapiro, *The Art of Prolog* | [`books/the-art-of-prolog/`](books/the-art-of-prolog/) | not started |

## Layout

- Folders carry the book coordinate, files carry the meaning:
  `books/bratko/ch03/3.2-list-operations/conc.pl` — never `3_2_conc.pl`, never `solution.pl`.
- Section folders are created lazily, the day that section is opened. No empty scaffolding.
- `articles/` — cross-cutting essays; the "missing didactic book" layer, written forward.
  Not book-bound: an idea met in Bratko and sharpened in Sterling & Shapiro belongs here.
- `templates/` — skeletons copied into a new section folder. Shared by every book.
- `lib/` — shared clause bases (e.g. the family database), once something actually recurs.

## The artifact set

A section is **done** when its folder contains all four:

| Artifact | Named | Holds |
|---|---|---|
| `<concept>.pl` | for its central predicate/idea | the predicates |
| `<concept>.plt` | same stem | plunit tests |
| `trace.md` | fixed | one traceviz-annotated query, control flow made visible |
| `notes.md` | fixed | own commentary — what the book *didn't* say |

Related exercises share one `.pl` file named for the theme; distinct ideas get separate files.

## Running tests

```sh
swipl -g "consult('books/bratko/ch03/3.2-list-operations/conc'), load_test_files([]), run_tests" -t halt
```

The `.plt` is found automatically by stem (plunit convention).

## Returning cold

Each book's `README.md` says where that book stands. Each chapter's `README.md` is the
hemingway bridge: where I stopped, what was warm, what to retrieve first.
Read it before reading the book.
