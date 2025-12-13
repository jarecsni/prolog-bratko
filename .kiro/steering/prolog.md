# Prolog-Specific Guidelines

## Enhanced Trace Format

When the user asks for a "detailed trace" or "enhanced trace" of Prolog execution, provide an emulated trace that shows:

1. **Clause matching attempts** - show each clause being tried
2. **Why clauses fail** - explicit explanation of unification failures
3. **Successful matches** - show variable bindings clearly
4. **Nested call structure** - indent recursive calls appropriately
5. **Term structure** - explain how terms are parsed (associativity, etc.)

### Format Template

```
═══════════════════════════════════════════════════════════════
QUERY: <original query>
═══════════════════════════════════════════════════════════════

[depth] CALL: <goal>
    
    Trying clause N: <clause head>
      ✗ Fails: <clear explanation>
             Term structure: <show canonical form if helpful>
             Expected: <what pattern needs>
             Got: <what term has>
    
    Trying clause M: <clause head> :- <body if recursive>
      ✓ Matches with <variable bindings>
      Body goals: <list of subgoals>

  [depth+1] CALL: <subgoal>
      ...
      [depth+1] EXIT: <subgoal with bindings>
      Bindings: <show what got bound>

  [depth] EXIT: <goal with final bindings>

═══════════════════════════════════════════════════════════════
RESULT: <final answer>
═══════════════════════════════════════════════════════════════
```

### Clarity Guidelines for Failure Explanations

Be explicit about term structure when explaining why unification fails.

**IMPORTANT:** Focus on what actually fails to unify. Avoid partial or ambiguous comments that might confuse which parts are being compared.

**❌ Unclear:**
```
✗ Fails: right arg is 1, not 0+1
```
This is confusing - which "right arg"? At what level of nesting?

**✅ Clear - Show the exact unification failure:**
```
✗ Fails: Cannot unify 0+1+1 with X+0+1
         Both parse as: (something)+1
         Need to match: (0+1) with (X+0)
         Requires: +(0,1) = +(X,0)
         Breakdown: 0=X ✓ but 1=0 ✗
         Failure point: 1 cannot unify with 0
```

**✅ Also acceptable - Full structural breakdown:**
```
✗ Fails: Cannot unify (0+1)+1 with (X+0)+1
         Term structure: +(+(0,1), 1)
         Pattern expects: +(+(X,0), 1)
         Outer functor: + = + ✓
         Right argument: 1 = 1 ✓
         Left argument: +(0,1) vs +(X,0)
           - Functor: + = + ✓
           - Left: 0 = X ✓
           - Right: 1 = 0 ✗ FAILS HERE
```

**Key principle:** Always trace down to the exact atomic values or variables that fail to unify. Don't leave the reader guessing about which subterm caused the failure.

### Key Points

- Always show term structure in canonical form when it clarifies matching
- Explain associativity when relevant (e.g., "X+0+1 parses as (X+0)+1 due to left-associativity")
- Show both what the pattern expects and what the term provides
- Use indentation to show call depth
- Mark successes with ✓ and failures with ✗
- Show variable bindings after each successful unification

## General Prolog Notes

- Remember that operators are just syntactic sugar for functors
- Associativity affects pattern matching significantly
- No implicit arithmetic or commutativity - everything is symbolic
- Variables can hold arbitrarily complex terms
