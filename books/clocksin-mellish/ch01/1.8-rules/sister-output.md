# Prolog Execution Trace: sister_of(alice, X)

## Query

```
sister_of(alice, X)
```

## Clause Definitions

| Line # | Clause |
|--------|--------|
| 1 | `male(albert)` |
| 2 | `male(edward)` |
| 3 | `female(alice)` |
| 4 | `female(victoria)` |
| 6 | `parents(edward, victoria, albert)` |
| 7 | `parents(alice, victoria, albert)` |
| 9 | `sister_of(X, Y) :- female(X), parents(X, M, F), parents(Y, M, F)` |

## Execution Timeline

<pre style="line-height: 1.15">
┌─ Step 1: sister_of(alice, X)
│  Clause: sister_of(X@1, Y) [line 9]
│  Unifications:
│    X@1 = alice
│  Subgoals:
│    [1.1] female(X@1) → female(alice)
│    [1.2] parents(X@1, M, F) → parents(alice, M, F)
│    [1.3] parents(Y, M, F)
│  
│  ┌─ Step 2 [Goal 1.1]: female(X@1) → female(alice)
│  │  Fact: female(alice) [line 3]
│  └─
│  ┌─ Step 3 [Goal 1.2]: parents(X@1, M, F) → parents(alice, M, F)
│  │  where X@1 = alice (from Step 2)
│  │  Fact: parents(alice, victoria, albert) [line 7]
│  │  =&gt; M = victoria, F = albert
│  └─
│  ┌─ Step 4 [Goal 1.3]: parents(Y, M, F) → parents(Y, M, albert)
│  │  where F = albert (from Step 3)
│  │  Fact: parents(edward, victoria, albert) [line 6]
│  │  =&gt; Y = edward
│  └─
│  =&gt; X = edward
└─

</pre>

## Final Answer

```
X = edward
```

_Showing the first solution only — re-run with `-n <count>` or `--all` to see more._