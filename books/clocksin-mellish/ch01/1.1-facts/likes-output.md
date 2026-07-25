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

┌─ Step 1: likes(mary, X)
│  Fact: likes(mary, food) [line 12]
│  => X = food
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
│  => X = wine
└─

┌─ Step 5: likes(john, X) → likes(john, wine)
│  where X = wine (from Step 4)
│  Fact: likes(john, wine) [line 14]
└─


## Call Tree

```mermaid
graph TD

%% Nodes
A["?- likes(mary, X), likes(john, X)"]
B["① likes(mary, X)<br/>fact 12<br/>X = food"]
C["② likes(john, X)"]
D["③ FAIL likes(john,food)"]
E["④ REDO likes(mary, X)<br/>fact 13<br/>X = wine"]
F["⑤ likes(john, X)<br/>fact 14"]

%% Edges
A --> B
A --> C
C --> D
A --> E
A --> F
E -.->|"backtrack"| B

%% Styles
style A fill:#e1f5ff,stroke:#01579b,stroke-width:3px
style B fill:#c8e6c9,stroke:#388e3c
style C fill:#fff9c4,stroke:#f57f17
style D fill:#ffcdd2,stroke:#c62828
style E fill:#c8e6c9,stroke:#388e3c
style F fill:#c8e6c9,stroke:#388e3c
```

## Final Answer

```
X = wine
```

_Showing first solution only._