# Prolog Execution Trace: likes(mary, X), likes(john, X)

## Query

```
likes(mary, X), likes(john, X)
```

## Clause Definitions

| Line # | Clause |
|--------|--------|
| 12 | `likes(mary, food)` |
| 13 | `likes(mary, wine)` |
| 14 | `likes(john, wine)` |
| 15 | `likes(john, mary)` |

## Execution Timeline

<pre style="line-height: 1.15">
┌─ Step 1: likes(mary, X)
│  Fact: likes(mary, food) [line 12]
│  =&gt; X = food
└─

┌─ Step 2: CALL likes(john, X) → likes(john, food)
│  where X = food (from Step 1)
│  
│  ┌─ Step 3: FAIL likes(john,food)
│  │  Failure
│  └─
└─

┌─ Step 4: REDO likes(mary, X)
│  Retry of Step 1 — X = food led to failure; undone, seeking another solution
│  Fact: likes(mary, wine) [line 13]
│  =&gt; X = wine
└─

┌─ Step 5: likes(john, X) → likes(john, wine)
│  where X = wine (from Step 4)
│  Fact: likes(john, wine) [line 14]
└─

</pre>

## Call Tree

```mermaid
%%{init: {'flowchart': {'nodeSpacing': 46, 'rankSpacing': 50}, 'themeVariables': {'fontSize': '15px'}}}%%
graph TD

%% Nodes
A["?- likes(mary, X), likes(john, X)"]
B["① likes(mary, X)<br/>X = food · fact 12"]
C["② likes(john, food)"]
D["③ ✗ fail"]
E["④ likes(mary, X)<br/>X = wine · fact 13"]
F["⑤ likes(john, wine)<br/>fact 14"]
G["✓ X = wine"]

%% Flow
A --> B
B --> C
C --> D
D -.->|"backtrack to ①"| B
B ==>|"next solution"| E
E --> F
F --> G

%% Styles
style A fill:#e1f5ff,stroke:#01579b,stroke-width:3px,color:#0b2440
style B fill:#c8e6c9,stroke:#388e3c,color:#14361a
style C fill:#fff9c4,stroke:#f57f17,color:#4a3208
style D fill:#ffcdd2,stroke:#c62828,stroke-width:2px,color:#4a1414
style E fill:#c8e6c9,stroke:#388e3c,color:#14361a
style F fill:#c8e6c9,stroke:#388e3c,color:#14361a
style G fill:#c8e6c9,stroke:#2e7d32,stroke-width:3px,color:#14361a
```

## Final Answer

```
X = wine
```

_Showing the first solution only — re-run with `-n <count>` or `--all` to see more._