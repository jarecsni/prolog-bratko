# Prolog Execution Trace: appendo([1,2], [3,4], X)

## Query

```
appendo([1,2], [3,4], X)
```

## Clause Definitions

| Line # | Clause |
|--------|--------|
| 14 | `childless_family(Surname) :- family(person(_, Surname, _, _), _, [])` |
| 21 | `employed_child(Child) :- child(Child), Child = person(_, _, _, works(_, _))` |
| 29 | `employed_child2(Child) :- Child = person(_, _, _, works(_, _)), child(Child)` |
| 36 | `wife_sole_earner(Surname) :- family( person(_, Surname, _, unemployed), person(_, _, _, works(_, _)), _ )` |
| 43 | `wife_sole_earner2(Family) :- Family = family( person(_, _, _, unemployed), person(_, _, _, works(_, _)), _ ), call(Family)` |
| 54 | `large_age_gap_family(MinGap, Family) :- Family = family( person(_, _, date(_, _, YH), _), person(_, _, date(_, _, YW), _), _ ), call(Family), Diff is abs(YH - YW), Diff >= MinGap` |
| 67 | `twin(Child1, Child2) :- family(_, _, Children), member(Child1, Children), member(Child2, Children), Child1 = person(_, _, DOB, _), Child2 = person(_, _, DOB, _), Child1 \== Child2` |
| 76 | `appendo([], L, L)` |
| 77 | `appendo([H|T], L, [H|R]) :- appendo(T, L, R)` |

## Execution Timeline

┌─ Step 1: appendo([1,2], [3,4], [H|R])
│  Clause: appendo([H|T], L, [H|R]) [line 77]
│  Unifications:
│    H = 1
│    T = [2]
│    L = [3,4]
│  Subgoals:
│    [1.1] appendo(T, L, R) → appendo([2], [3,4], R)
│  
│  ┌─ Step 2 [Goal 1.1]: appendo(T, L, R) → appendo([2], [3,4], R)
│  │  Clause: appendo([H|T], L, [H|R]) [line 77]
│  │  Unifications:
│  │    H = 2
│  │    T = []
│  │    L = [3,4]
│  │  Subgoals:
│  │    [2.1] appendo(T, L, R) → appendo([], [3,4], R)
│  │  
│  │  ┌─ Step 3 [Goal 2.1]: appendo(T, L, R) → appendo([], [3,4], R)
│  │  │  Fact: appendo([], L, L) [line 76]
│  │  │  Unifications:
│  │  │    L = [3,4]
│  │  │  => R = [3,4]
│  │  └─
│  │  => R = [2,3,4]
│  └─
│  => [H|R] = [1,2,3,4]
│  Query Variable: X = [1,2,3,4]
└─


## Final Answer

```
X = [1,2,3,4]
```

_Showing first solution only._