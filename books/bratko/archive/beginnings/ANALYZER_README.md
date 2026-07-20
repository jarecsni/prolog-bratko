# Prolog Execution Analyzer

A tool for analyzing and visualizing Prolog program execution with cycle detection and interactive exploration.

## Features

- 🔍 **Execution tree visualization** - See how Prolog explores the search space
- 🔄 **Cycle detection** - Automatically detects infinite loops
- 📊 **Depth limiting** - Control tree explosion with configurable depth limits
- 🎮 **Interactive mode** - Step through execution and choose which branches to explore
- 📝 **Auto mode** - Generate complete execution tree up to depth limit

## Installation

No installation needed! Just make sure you have SWI-Prolog installed.

```bash
chmod +x analyze
```

## Usage

### Command Line

```bash
# Interactive mode - step through execution
./analyze <file.pl> "<goal>" interactive

# Auto mode - generate full tree with depth limit
./analyze <file.pl> "<goal>" auto [depth]
```

### Examples

```bash
# Analyze parent relationships interactively
./analyze family.pl "parent(tom, X)" interactive

# Auto-analyze grandparent with depth 5
./analyze family.pl "grandparent(tom, Who)" auto 5

# Analyze monkey-banana problem (detects cycles!)
./analyze 2_5_monkey.pl "canget(state(atdoor, onfloor, atwindow, hasnot))" auto 3

# Analyze predecessor (shows recursion)
./analyze family.pl "predecessor(tom, Who)" auto 4
```

### From SWI-Prolog REPL

```prolog
?- ['prolog_analyzer.pl'].

% Interactive exploration
?- explore(parent(tom, X)).

% Auto-analysis with depth limit
?- print_analysis(grandparent(tom, Who), 5).

% Analyze a specific file
?- analyze_file('family.pl', parent(tom, X), interactive).
?- analyze_file('family.pl', grandparent(tom, Who), auto(5)).
```

## Interactive Mode

In interactive mode, you control the execution:

```
[Step 1] Current Goal: parent(tom, X)

Available clauses:
  1. parent(tom, bob) (fact)
  2. parent(tom, liz) (fact)

Choose clause number (or q to quit, b to back): 1

Selected: parent(tom, bob) ✓
Fact matched! Press ENTER to continue...
```

**Commands:**
- **Number (1, 2, etc.)** - Choose that clause to explore
- **q** - Quit the explorer
- **b** - Backtrack to previous choice

## Auto Mode

Auto mode generates the complete execution tree up to the specified depth:

```
╔════════════════════════════════════════════════════════════╗
║  PROLOG EXECUTION ANALYSIS                                 ║
╚════════════════════════════════════════════════════════════╝
Goal: parent(tom, X)
Max Depth: 2

?- parent(tom, X)
  ├─ parent(tom, bob)
     ✓ SUCCESS
  ├─ parent(tom, liz)
     ✓ SUCCESS
```

## Output Symbols

- `✓ SUCCESS` - Goal succeeded (fact matched or all subgoals satisfied)
- `🔄 CYCLE DETECTED` - Infinite loop detected (goal revisited)
- `⚠ DEPTH LIMIT REACHED` - Maximum depth reached
- `⚙ BUILTIN` - Built-in predicate (auto-evaluates)
- `❌ UNDEFINED` - Predicate not defined
- `AND` - Conjunction (multiple goals to prove)

## Example Output

### Simple Facts
```bash
./analyze family.pl "parent(tom, X)" auto 2
```
```
?- parent(tom, X)
  ├─ parent(tom, bob)
     ✓ SUCCESS
  ├─ parent(tom, liz)
     ✓ SUCCESS
```

### Recursive Rules
```bash
./analyze family.pl "grandparent(tom, Who)" auto 4
```
```
?- grandparent(tom, Who)
  ├─ grandparent(tom, _123)
     AND
       ?- parent(tom, _124)
         ├─ parent(tom, bob)
            ✓ SUCCESS
       ?- parent(bob, _123)
         ├─ parent(bob, ann)
            ✓ SUCCESS
         ├─ parent(bob, pat)
            ✓ SUCCESS
```

### Cycle Detection
```bash
./analyze 2_5_monkey.pl "canget(state(atdoor, onfloor, atwindow, hasnot))" auto 3
```
```
?- canget(state(atdoor, onfloor, atwindow, hasnot))
  ├─ canget(...)
     AND
       ?- move(...)
         ├─ move(...) ✓ SUCCESS
       ?- canget(_3482)
         🔄 CYCLE DETECTED: canget(_3482)
```

## Tips

1. **Start with small depth limits** (2-3) to avoid explosion
2. **Use interactive mode** for complex queries to control exploration
3. **Cycle detection** helps identify infinite loops before they hang
4. **Increase depth gradually** if you need to see deeper execution

## Limitations

- Cannot analyze all possible paths (halting problem)
- Large depth limits can cause memory issues
- Built-in predicates shown but not expanded
- Some meta-predicates may not analyze correctly

## Files

- `prolog_analyzer.pl` - Main analyzer implementation
- `analyze` - Shell script wrapper for command line usage
- `ANALYZER_README.md` - This file

## License

Free to use for learning and teaching Prolog!

