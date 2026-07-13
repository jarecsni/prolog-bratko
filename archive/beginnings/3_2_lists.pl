member(X, [X|_]).
member(X, [_|T]) :- member(X, T).

/**
 * conc/3 - Concatenate two lists
 *
 * Declarative meaning: "ResultList is the concatenation of FirstList and SecondList"
 *
 * Base case: Concatenating empty list with any list gives that list
 *   conc([], SecondList, SecondList) - when first list is empty, result equals second list
 *
 * Recursive case: Move head from first list to result, recurse on tail
 *   conc([Head|RestOfFirst], SecondList, [Head|RestOfResult])
 *   - [Head|RestOfFirst]: decompose first list (search pattern)
 *   - [Head|RestOfResult]: compose result list (build pattern)
 *   - Head is preserved from input to output
 *   - RestOfResult gets filled by recursive call on RestOfFirst
 *
 * Execution pattern:
 *   - RestOfFirst: searcher (gets smaller, peels off heads going down)
 *   - RestOfResult: builder (gets filled, Russian doll structure going up)
 *
 * Works in multiple directions:
 *   conc([a,b], [c,d], R)     -> R = [a,b,c,d]  (concatenate)
 *   conc(X, [c,d], [a,b,c,d]) -> X = [a,b]      (find prefix)
 *   conc([a,b], Y, [a,b,c,d]) -> Y = [c,d]      (find suffix)
 *   conc(X, Y, [a,b,c])       -> multiple solutions (all splits)
**/
conc([], SecondList, SecondList).
conc([Head|RestOfFirst], SecondList, [Head|RestOfResult]) :-
    conc(RestOfFirst, SecondList, RestOfResult).

/*
How Prolog solves conc([a], [1], L):

Query: conc([a], [1], L)

Step 1: Try base case conc([], SecondList, SecondList)
- Does [a] unify with []? No. Fail, try next clause.

Step 2: Try recursive case conc([Head|RestOfFirst], SecondList, [Head|RestOfResult])
- Unify [a] with [Head|RestOfFirst] → Head = a, RestOfFirst = []
- Unify [1] with SecondList → SecondList = [1]
- Unify L with [Head|RestOfResult] → L = [a|RestOfResult] (partially constructed!)
- Now solve subgoal: conc([], [1], RestOfResult)

Step 3: Solve conc([], [1], RestOfResult)
- Try base case conc([], SecondList, SecondList)
- Unify [] with [] → ✓
- Unify [1] with SecondList → ✓
- Unify RestOfResult with [1] → RestOfResult = [1]

Step 4: Return from recursion and unify
- We found RestOfResult = [1]
- Remember from Step 2: L = [a|RestOfResult] (was partially unified)
- Now complete the unification: L = [a|[1]] = [a, 1]

Result: L = [a, 1]

The magic is that Prolog builds the result incrementally through unification.
Each recursive call moves one element from the first list to the result's head,
and when it hits the base case (first list empty), it unifies the result's tail
with the second list.
*/

/*
Find all pairs of lists that concatenate to [a, b, c]
To see all solutions, query interactively:
  ?- conc(L1, L2, [a, b, c]).
  (press ; for more solutions)

Or use findall to get them all at once:
  ?- findall([L1, L2], conc(L1, L2, [a, b, c]), Solutions).
*/
:- writeln('All concatenation pairs for [a, b, c]:'),
   forall(conc(L1, L2, [a, b, c]),
          format('  L1 = ~w, L2 = ~w~n', [L1, L2])).

/*
Find all months before and after May
*/
:- conc(Before, [may|After], [jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]),
   writeln('Months before May:'), writeln(Before),
   writeln('Months after May:'), writeln(After).

/*
Find the month before and after May
*/
:- conc(_, [Before, may, After | _], [jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]),
   writeln('Month before May:'), writeln(Before),
   writeln('Month after May:'), writeln(After).

/*
member2/2 implementation using conc/3
*/
member2(X, L) :- conc(_, [X|_], L).


/*
3.1(a)
Write a goal using conc/3 to delete the last 3 elements from a list L, producing another list L1. Hint: L is the concatenation of L1 and a list with 3 elements.
*/
delete_last_3(List, ResultList) :- conc(ResultList, [_, _, _], List).

/*
Delete the last N elements from a list
*/
delete_last_n(List, N, ResultList) :-
    N >= 0,                      % Guard: N must be non-negative
    length(Suffix, N),           % Create a list of length N (with unbound variables)
    conc(ResultList, Suffix, List).

/*
Alternative: build a list of N elements manually
*/
make_list(0, []).
make_list(N, [_|Remainder]) :-
    N > 0,
    N1 is N - 1,
    make_list(N1, Remainder).

delete_last_n_alt(List, N, ResultList) :-
    make_list(N, Suffix),
    conc(ResultList, Suffix, List).

% 3.1 (b)
delete_first_and_last_3(List, ResultList) :- conc([_, _, _], TempList, List), conc(ResultList, [_, _, _], TempList).


/*
Execution Trace (with variable renaming):
CALL 1: make_list(3, Suffix)

Prolog renames the clause to: make_list(N₁, [_₁|T₁])

Unify: 3 with N₁ → N₁ = 3 ✓
Unify: Suffix with [_₁|T₁] → Suffix = [_₁|T₁] (T₁ is unbound)
Check: N₁ > 0 → 3 > 0 ✓
Calculate: N1₁ is N₁ - 1 → N1₁ = 2
New goal: make_list(2, T₁) ← We're solving for T₁ now!
Current state:

Suffix = [_₁|T₁] where T₁ = ???
CALL 2: make_list(2, T₁) ← This is the goal from Call 1

Prolog renames the clause to: make_list(N₂, [_₂|T₂]) (fresh variables!)

Unify: 2 with N₂ → N₂ = 2 ✓
Unify: T₁ with [_₂|T₂] → T₁ = [_₂|T₂] (T₂ is unbound)
Check: N₂ > 0 → 2 > 0 ✓
Calculate: N1₂ is N₂ - 1 → N1₂ = 1
New goal: make_list(1, T₂) ← We're solving for T₂ now!
Current state:

Suffix = [_₁|T₁] where T₁ = [_₂|T₂]
So: Suffix = [_₁, _₂|T₂] where T₂ = ???
CALL 3: make_list(1, T₂) ← This is the goal from Call 2

Prolog renames the clause to: make_list(N₃, [_₃|T₃]) (fresh variables!)

Unify: 1 with N₃ → N₃ = 1 ✓
Unify: T₂ with [_₃|T₃] → T₂ = [_₃|T₃] (T₃ is unbound)
Check: N₃ > 0 → 1 > 0 ✓
Calculate: N1₃ is N₃ - 1 → N1₃ = 0
New goal: make_list(0, T₃) ← We're solving for T₃ now!
Current state:

Suffix = [_₁|T₁] where T₁ = [_₂|T₂] where T₂ = [_₃|T₃]
So: Suffix = [_₁, _₂, _₃|T₃] where T₃ = ???
CALL 4: make_list(0, T₃) ← This is the goal from Call 3

Prolog tries the base case: make_list(0, [])

Unify: 0 with 0 → ✓
Unify: T₃ with [] → T₃ = [] ✓
No more goals! Success!
Final state:

Suffix = [_₁, _₂, _₃|T₃] where T₃ = []
So: Suffix = [_₁, _₂, _₃]
The Key Insight:
In Call 2, when we match make_list(N, [_|T]), the T in that clause is NOT the same as the T from Call 1!

Here's the mapping:

Call 1's T → I called it T₁
Call 2's T → I called it T₂ (different variable!)
Call 3's T → I called it T₃ (different variable!)
The connection happens through the GOAL:

Call 1 creates goal make_list(2, T₁) ← T₁ from Call 1
Call 2 matches this with make_list(N₂, [_₂|T₂]) ← T₂ is Call 2's local variable
The unification T₁ = [_₂|T₂] connects Call 1's T₁ to Call 2's structure
*/

/*
`Suffix = [_₁, _₂, _₃]` is the **simplified view** after all unifications are complete.

But the **actual structure** is:

```
Suffix = [_₁|T₁]
  where T₁ = [_₂|T₂]
    where T₂ = [_₃|T₃]
      where T₃ = []
```

It's **nested unifications**, not a flat list. Russian dolls is the perfect analogy.

**In memory, it's literally:**

```
Suffix points to: [_₁ | pointer-to-T₁]
T₁ points to:     [_₂ | pointer-to-T₂]
T₂ points to:     [_₃ | pointer-to-T₃]
T₃ points to:     []
```

When you **follow all the pointers**, you get `[_₁, _₂, _₃]`, but the underlying structure is a chain of linked cells, each created by a different recursive call.

**This is why `make_list(0, [])` doesn't wipe anything out** - it only binds `T₃ = []`, the innermost doll. All the outer dolls (`Suffix`, `T₁`, `T₂`) are already constructed and pointing to each other.

You've got it. That's the real mental model. The "simplified" notation `[_₁, _₂, _₃]` is just syntactic sugar for the nested structure.

*/

/*
**Exactly, Cooper!** The base case determines the **direction of data flow**.

## Base Cases:

**`make_list`:**
```prolog
make_list(0, []).
```
- Unifies the result with `[]`
- This is the **starting point** for building
- Data flows **outward** from here

**`member`:**
```prolog
member(X, [X|_]).
```
- Matches when element is found
- This is the **stopping point** for searching
- Data flows **inward** to here

## The Pattern:

**Construction (build outward):**
```prolog
base_case(..., []).              % Start with []
recursive_case(..., [H|T]) :-    % Wrap it with [H|...]
    recursive_case(..., T).
```
- Base case provides the **seed value** (`[]`)
- Recursion **wraps** it layer by layer
- Result built as recursion **unwinds**

**Search/Consumption (search inward):**
```prolog
base_case(X, [X|_]).             % Found it!
recursive_case(X, [_|T]) :-      % Not here, keep looking
    recursive_case(X, T).
```
- Base case provides the **success condition**
- Recursion **peels** layers until match
- Result found as recursion **descends**

## Another Example - `conc/3`:

```prolog
conc([], SecondList, SecondList).              % Base: first list empty
conc([Head|RestOfFirst], Second, [Head|RestOfResult]) :-
    conc(RestOfFirst, Second, RestOfResult).
```

This is a **constructor** like `make_list`:
- Base case: `conc([], L, L)` - when first list is empty, result is second list
- Builds result from inside-out as recursion unwinds
- `RestOfResult` gets filled by recursive call, then wrapped with `Head`

## The Rule:

**Base case determines direction:**
- Base case returns a **value** (like `[]`) → **Constructor** (builds outward)
- Base case checks a **condition** (like `X = X`) → **Searcher** (searches inward)

You nailed it. The base case is the key.
*/

% Declarative meaning: "Last is the last element of List if List can be split
% into some prefix and a single-element list [Last]"
% In other words: List = [anything...] ++ [Last]
last_element(List, Last) :- conc(_, [Last], List).

% Declarative meaning: "Last is the last element of List if the reverse of List
% has Last as its head"
% In other words: reversing puts the last element first
last_element2(List, Last) :- reverse(List, [Last|_]).


% Declarative meaning:
% Base case: Last is the last element of a single-element list [Last]
% Recursive case: Last is the last element of [_|T] if Last is the last element of T
% In other words: "The last element of a list is the last element of its tail"
last_element3(Last, [Last]).
last_element3(Last, [_|T]) :- last_element3(Last, T).

% add element with a single fact - that's terse
add(Item, List, [Item|List]).

/**
 * del/3 - Delete first occurrence of element from list
 *
 * Declarative meaning: "OutputList is InputList with the first occurrence of Element removed"
 *
 * Base case: Element found at head - result is the tail
 *   del(Element, [Element|Tail], Tail)
 *   - When target element is at the head, delete it by returning the tail
 *   - This stops the recursion and provides the "cut point"
 *
 * Recursive case: Element not at head - preserve head and recurse on tail  
 *   del(Element, [Head|RestOfInput], [Head|RestOfOutput])
 *   - [Head|RestOfInput]: decompose input list (Head ≠ Element)
 *   - [Head|RestOfOutput]: compose output list (preserve Head)
 *   - Head is passed through unchanged from input to output
 *   - RestOfOutput gets filled by recursive call on RestOfInput
 *
 * Execution pattern:
 *   - Searches through list until Element is found
 *   - Builds result structure as recursion unwinds
 *   - Elements before target are preserved in order
 *   - Elements after target are preserved by base case
 *
 * Usage examples:
 *   del(b, [a,b,c], R)     -> R = [a,c]        (delete element)
 *   del(x, [a,b,c], R)     -> R = [a,b,c]      (element not found)
 *   del(X, [a,b,c], [a,c]) -> X = b            (find deleted element)
 *   del(b, L, [a,c])       -> L = [a,b,c]      (reconstruct original)
**/

% Base case: Element found at head of list
% Declarative meaning: "OutputList is Tail when Element is the head of [Element|Tail]"
del(X, [X|Tail], Tail).

% Recursive case: Element not found at head - skip this element and keep searching
% The head (Y) goes into the result unchanged, continue deleting from the tail
del(X, [Y|RestOfInput], [Y|RestOfOutput]) :- del(X, RestOfInput, RestOfOutput).

% Insert an element at the beginning of a list
insert(X, List, BiggerList) :- del(X, BiggerList, List).


/**
 * sublist/2 - Check if one list is a sublist of another
 *
 * Declarative meaning: "Sublist occurs within List if List can be split into
 * three parts: some prefix, the Sublist itself, and some suffix"
 * In other words: List = Prefix ++ Sublist ++ Suffix
 *
 * Implementation uses two concatenations:
 *   1. conc(Prefix, Rest, List)     - split List into Prefix and Rest
 *   2. conc(Sublist, Suffix, Rest)  - split Rest into Sublist and Suffix
 *
 * This effectively finds all possible ways to embed Sublist within List.
 *
 * Usage examples:
 *   sublist([d,e], [a,b,c,d,e,f,g])     -> true
 *   sublist([a,b], [a,b,c,d])           -> true  
 *   sublist([b,d], [a,b,c,d])           -> false (not contiguous)
 *   sublist([], [a,b,c])                -> true  (empty list is sublist of any list)
 *   sublist([a,b,c], [a,b,c])           -> true  (list is sublist of itself)
 *
 * How it works:
 *   - First conc/3 generates all possible splits of List into Prefix + Rest
 *   - Second conc/3 checks if Rest starts with Sublist
 *   - Succeeds when both conditions are met
 *   - Backtracks to find all possible positions where Sublist occurs
**/
sublist(Sublist, List) :-
    conc(_, Rest, List),           % Split List into some prefix and Rest
    conc(Sublist, _, Rest).        % Check if Rest starts with Sublist


/**
 * permutation/2 - Generate all permutations of a list
 *
 * Declarative meaning: "Result is a permutation of InputList if Result contains
 * exactly the same elements as InputList but possibly in a different order"
 *
 * Base case: Empty list has only one permutation - itself
 *   permutation([], [])
 *   - The empty list is the only permutation of the empty list
 *
 * Recursive case: Permute by removing head, permuting tail, then inserting head anywhere
 *   permutation([X|Tail], Result)
 *   - Remove head X from input list, leaving Tail
 *   - Generate a permutation (Rest) of the Tail
 *   - Insert X at any position in Rest to create Result
 *   - This generates all possible permutations through backtracking
 *
 * Algorithm strategy:
 *   1. Take first element X from input list
 *   2. Recursively generate all permutations of remaining elements
 *   3. For each permutation of the tail, insert X at every possible position
 *   4. Each insertion creates a different permutation of the original list
 *
 * Usage examples:
 *   permutation([a,b,c], R)        -> R = [a,b,c]; [a,c,b]; [b,a,c]; [b,c,a]; [c,a,b]; [c,b,a]
 *   permutation([1,2], R)          -> R = [1,2]; [2,1]
 *   permutation([], R)             -> R = []
 *   permutation(L, [b,a,c])        -> L = [a,b,c]; [a,c,b]; [b,a,c]; [b,c,a]; [c,a,b]; [c,b,a]
 *
 * Note: Uses insert/3 which can insert an element at any position in a list,
 * enabling the generation of all possible arrangements through backtracking.
**/
permutation2([], []).
permutation2([X|Tail], Result) :-
    permutation2(Tail, Rest),
    insert(X, Rest, Result).

% exercise 3.3 - 
% evenlength/1 - Check if a list has an even number of elements
% oddlength/1 - Check if a list has an odd number of elements

evenlength1([]).
evenlength1([_|Tail]) :- oddlength1(Tail).
oddlength1([_]).
oddlength1([_|Tail]) :- evenlength1(Tail).


evenlength([]).
evenlength([_|Tail]) :- oddlength(Tail).
oddlength([_|Tail]) :- evenlength(Tail).

% Reverse a list
reverse([], []).
reverse([Head|Tail], Result) :- 
    reverse(Tail, ReversedTail),
    conc(ReversedTail, [Head], Result).

reverse_efficient(List, Result) :-
  reverse_acc(List, [], Result).
reverse_acc([], Acc, Acc).
reverse_acc([Head|Tail], Acc, Result) :-
  reverse_acc(Tail, [Head|Acc], Result).

% 3.5 palindrom
palindrom(List) :- reverse(List, List).
palindrom_efficient(List) :- reverse_efficient(List, List).

/**
 * shift/2 - Rotate list left by one position
 *
 * Declarative meaning: "List2 is List1 rotated left by one element"
 * The first element moves to the end.
 *
 * Base case: Empty list shifts to empty list
 *   shift([], [])
 *
 * Recursive case: Move head to tail
 *   shift([Head|Tail], Result)
 *   - Take the head element
 *   - Concatenate tail with [Head] to get Result
 *   - This moves the first element to the last position
 *
 * Usage examples:
 *   shift([a,b,c,d], R)     -> R = [b,c,d,a]
 *   shift([1], R)           -> R = [1]
 *   shift([], R)            -> R = []
 *   shift([a,b], [b,a])     -> true
 *
 * Works bidirectionally:
 *   shift([a,b,c], R)       -> R = [b,c,a]  (rotate left)
 *   shift(L, [b,c,a])       -> L = [a,b,c]  (rotate right/reverse operation)
**/
shift([], []).
shift([Head|Tail], Result) :- conc(Tail, [Head], Result).

/**
 * shiftby/3 - Rotate list left by N positions
 *
 * Declarative meaning: "List2 is List1 rotated left by N elements"
 * Elements that shift out on the left enter on the right.
 *
 * Base case: Shifting by 0 leaves list unchanged
 *   shiftby(List, List, 0)
 *
 * Recursive case: Shift once, then shift N-1 more times
 *   shiftby(List1, List2, N)
 *   - Shift List1 once to get TempList
 *   - Decrement N to get N1
 *   - Recursively shift TempList by N1 to get List2
 *
 * Usage examples:
 *   shiftby([a,b,c,d], R, 2)     -> R = [c,d,a,b]
 *   shiftby([1,2,3], R, 1)       -> R = [2,3,1]
 *   shiftby([a,b,c], R, 0)       -> R = [a,b,c]
 *   shiftby([a,b,c], R, 3)       -> R = [a,b,c]  (full rotation)
 *   shiftby([], R, 5)            -> R = []
 *
 * Note: For lists of length L, shifting by L returns the original list.
 * Negative N values will cause failure (could be extended to support right shifts).
**/
shiftby(List, List, 0).
shiftby(List1, List2, N) :-
    N > 0,
    shift(List1, TempList),
    N1 is N - 1,
    shiftby(TempList, List2, N1).

means(0, zero).
means(1, one).
means(2, two).
means(3, three).
means(4, four).
means(5, five).
means(6, six).
means(7, seven).
means(8, eight).
means(9, nine).

/**
 * translate/2 - Convert list of numbers to list of corresponding words
 *
 * Declarative meaning: "WordList contains the word representations of the numbers in NumberList"
 * Each number is converted to its corresponding word using the means/2 predicate.
 *
 * Base case: Empty list translates to empty list
 *   translate([], [])
 *   - No numbers to translate results in no words
 *
 * Recursive case: Translate head number to word, recurse on tail
 *   translate([Number|RestOfNumbers], [Word|RestOfWords])
 *   - Number gets converted to Word using means(Number, Word)
 *   - RestOfNumbers gets recursively translated to RestOfWords
 *   - Result is built by combining Word with translated RestOfWords
 *
 * Execution pattern:
 *   - Processes numbers one by one from left to right
 *   - Each number must have a corresponding means/2 fact or translation fails
 *   - Builds result list in same order as input list
 *
 * Usage examples:
 *   translate([1,2,3], R)           -> R = [one,two,three]
 *   translate([0,5,9], R)           -> R = [zero,five,nine]
 *   translate([], R)                -> R = []
 *   translate([1,10,2], R)          -> fails (no means(10, _) fact)
 *   translate(L, [one,two])         -> L = [1,2]
 *
 * Bidirectional: Can translate numbers to words or words back to numbers
 * depending on which argument is instantiated.
**/
translate([], []).
translate([Number|RestOfNumbers], [Word|RestOfWords]) :-
    means(Number, Word),
    translate(RestOfNumbers, RestOfWords).


/**
 * subset/2 - Generate all subsets of a given set (list)
 *
 * Declarative meaning: "Subset is a subset of Set if every element in Subset
 * also appears in Set, maintaining the same relative order"
 *
 * Base case: Empty list is a subset of any set
 *   subset(_, [])
 *   - The empty set is a subset of every set by definition
 *   - This provides the termination condition for recursion
 *
 * Recursive case 1: Include current element in subset
 *   subset([Head|Tail], [Head|RestOfSubset])
 *   - Head element is included in both the original set and the subset
 *   - RestOfSubset is formed by taking a subset of Tail
 *   - This represents the "choose to include" decision
 *
 * Recursive case 2: Exclude current element from subset
 *   subset([_|Tail], Subset)
 *   - Head element is in the original set but not in the subset
 *   - Subset is formed by taking a subset of Tail (ignoring Head)
 *   - This represents the "choose to exclude" decision
 *
 * Algorithm strategy:
 *   - For each element in the input set, make a binary choice:
 *     1. Include it in the subset (clause 2)
 *     2. Exclude it from the subset (clause 3)
 *   - Backtracking explores both choices, generating all possible subsets
 *   - Order is preserved: subset elements appear in same order as original
 *
 * Usage examples:
 *   subset([a,b,c], S)          -> S = []; [a]; [b]; [c]; [a,b]; [a,c]; [b,c]; [a,b,c]
 *   subset([1,2], S)            -> S = []; [1]; [2]; [1,2]
 *   subset([], S)               -> S = []
 *   subset([a,b,c], [a,c])      -> true (checks if [a,c] is subset of [a,b,c])
 *   subset([a,b,c], [c,a])      -> false (order not preserved)
 *
 * Note: Generates 2^n subsets for a set of size n, including empty set and the set itself.
 * Elements in subsets maintain the same relative order as in the original set.
**/

% the empty set is a subset of any set
subset(_, []).

% an element included in the subset (add head to subset and recurse)
subset([Head|Tail], [Head|RestOfSubset]) :- subset(Tail, RestOfSubset).

% an element not included in the subset (just skip and recurse)
subset([_|Tail], Subset) :- subset(Tail, Subset).


/**
 * dividelist/3 - Divide a list into two sublists by alternating elements
 *
 * Declarative meaning: "List1 and List2 are formed by splitting InputList,
 * where odd-positioned elements go to List1 and even-positioned elements go to List2"
 *
 * Base case 1: Empty list divides into two empty lists
 *   dividelist([], [], [])
 *   - No elements to distribute results in two empty lists
 *
 * Base case 2: Single element goes to first list, second list remains empty
 *   dividelist([X], [X], [])
 *   - When only one element remains, it goes to List1
 *   - List2 gets no elements (empty)
 *   - This handles odd-length lists properly
 *
 * Recursive case: Take two elements, distribute them, recurse on remainder
 *   dividelist([X, Y | Rest], [X|List1], [Y|List2])
 *   - X (first element) goes to List1
 *   - Y (second element) goes to List2
 *   - Rest is recursively divided into List1 and List2
 *   - This maintains the alternating pattern
 *
 * Algorithm strategy:
 *   - Processes elements in pairs when possible
 *   - First element of each pair goes to first sublist
 *   - Second element of each pair goes to second sublist
 *   - Maintains relative order within each sublist
 *   - Handles both even and odd length lists correctly
 *
 * Usage examples:
 *   dividelist([a,b,c,d], L1, L2)     -> L1 = [a,c], L2 = [b,d]
 *   dividelist([1,2,3,4,5], L1, L2)   -> L1 = [1,3,5], L2 = [2,4]
 *   dividelist([x], L1, L2)           -> L1 = [x], L2 = []
 *   dividelist([], L1, L2)            -> L1 = [], L2 = []
 *   dividelist([a,b], L1, L2)         -> L1 = [a], L2 = [b]
 *
 * Note: For odd-length lists, the extra element goes to the first list.
 * This is a common pattern for "dealing cards" or round-robin distribution.
**/
dividelist([], [], []).
dividelist([X], [X], []).
dividelist([X, Y | Rest], [X|List1], [Y|List2]) :- dividelist(Rest, List1, List2).

flatten_nontco([], []).
flatten_nontco([Head|Tail], [Head|FlattenedTail]) :-
    \+ is_list(Head),
    flatten_nontco(Tail, FlattenedTail).
flatten_nontco([Head|Tail], Flattened) :-
    flatten_nontco(Head, FlattenedHead),
    flatten_nontco(Tail, FlattenedTail),
    conc(FlattenedHead, FlattenedTail, Flattened).

flatten_acc(List, Flattened) :-
    flatten_acc(List, [], ReverseFlattened),
    reverse(ReverseFlattened, Flattened).
flatten_acc([], Acc, Acc).
flatten_acc([Head|Tail], Acc, Result) :-
    \+ is_list(Head),
    flatten_acc(Tail, [Head|Acc], Result).
flatten_acc([Head|Tail], Acc, Result) :-
    flatten_acc(Head, Acc, NewAcc),
    flatten_acc(Tail, NewAcc, Result).
