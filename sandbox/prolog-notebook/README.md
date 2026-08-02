# prolog-notebook — spike

A Jupyter-style notebook for Prolog that runs entirely in the browser, with no server and
no local Prolog install. Built on [swipl-wasm](https://github.com/SWI-Prolog/swipl-wasm) —
the official SWI-Prolog WebAssembly build.

The question this spike answers: **can a Head First-style Prolog book be an executable web
page?** `index.html` is a worked sample section — the `once/1` placement puzzle — not a demo
of the widget.

## Running it

```sh
npm install
python3 -m http.server 8777
open http://localhost:8777/
```

`node_modules/` is gitignored; the WASM bundle is 5.9 MB and comes from npm.

## Cell types

- **program** — a clause base. `Consult` writes it to the WASM virtual filesystem and
  consults it into `user`. Everything below a program cell sees its predicates.
- **query** — `Run` gives the first solution, `; next` steps to the following one, `all`
  exhausts (capped at 500).

The `; next` button is the whole point and the reason this is not just Jupyter with a
different kernel. A Prolog query does not have *an* answer; it has answers one at a time on
backtracking, and stepping through them is the thing being taught. In the sample section,
`is_son(X)` reporting edward twice *is* the lesson — a notebook that showed only a final
result list would have hidden it.

## Two things that cost an hour

Both were found by driving the page in a real browser, not by reading the docs.

**Module context.** `prolog.query(Goal)` runs with `system` as the context module, while
`consult/1` loads into `user`. Unqualified goals therefore raise
`Unknown procedure: system:is_son/1` even though the consult reported success. Goals are
wrapped as `user:( Goal )`.

**The last solution arrives with `done`.** `query.next()` can return
`{done: true, value: {...}}` — a final binding and the end of the search in a single step.
Treating `done` as "no more answers, stop" silently drops the last solution. Report the
binding first, then exhaustion.

## Not done yet

- No `trace/0` integration. SWI-Tinker's WASM shell has a debugger with ANSI/tty support, so
  live backtracking visualisation is reachable — this is where `ptv` would plug in.
- No syntax highlighting in cells.
- Prediction boxes don't persist; a reader who reloads loses what they typed.
- The 5.9 MB bundle loads on first interaction with no progress indication.
