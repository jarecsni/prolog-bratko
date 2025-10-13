// Simulating Prolog's make_list in JavaScript
// Shows how the "Russian doll" unification chain works

// ============================================
// VERSION 1: Direct simulation of Prolog's unification
// ============================================

function makeListProlog(n) {
  if (n === 0) {
    return [];
  } else {
    // Create a cell with a "hole" for the tail
    // This simulates: [_|T] where T is unbound
    const head = undefined;  // The _ (anonymous variable)
    const tail = makeListProlog(n - 1);  // Recursive call fills the tail
    
    return [head, ...tail];  // Construct [_|T]
  }
}

console.log("=== VERSION 1: Direct simulation ===");
console.log(makeListProlog(3));
// Output: [undefined, undefined, undefined]


// ============================================
// VERSION 2: Showing the nested structure explicitly
// ============================================

// In Prolog, lists are actually nested structures like:
// [a, b, c] is really .(a, .(b, .(c, [])))
// Let's simulate that with objects

function makeListNested(n) {
  if (n === 0) {
    return { type: 'empty' };  // []
  } else {
    return {
      type: 'cons',
      head: undefined,  // The _
      tail: makeListNested(n - 1)  // The T (filled by recursive call)
    };
  }
}

function printNested(list, indent = 0) {
  const spaces = '  '.repeat(indent);
  if (list.type === 'empty') {
    console.log(spaces + '[]');
  } else {
    console.log(spaces + '{');
    console.log(spaces + '  head: undefined,');
    console.log(spaces + '  tail:');
    printNested(list.tail, indent + 2);
    console.log(spaces + '}');
  }
}

console.log("\n=== VERSION 2: Nested structure (Russian dolls) ===");
const nested = makeListNested(3);
printNested(nested);


// ============================================
// VERSION 3: Simulating unification with mutable references
// ============================================

// This shows how Prolog builds the structure with "holes" that get filled

class UnboundVar {
  constructor(name) {
    this.name = name;
    this.binding = null;  // null = unbound
  }
  
  bind(value) {
    this.binding = value;
  }
  
  getValue() {
    if (this.binding === null) {
      return `<unbound ${this.name}>`;
    }
    if (this.binding instanceof UnboundVar) {
      return this.binding.getValue();
    }
    if (Array.isArray(this.binding)) {
      return this.binding.map(v => 
        v instanceof UnboundVar ? v.getValue() : v
      );
    }
    return this.binding;
  }
}

function makeListWithUnification(n, varCounter = { count: 0 }) {
  console.log(`\nCALL: makeListWithUnification(${n})`);
  
  if (n === 0) {
    console.log(`  Base case: returning []`);
    return [];
  } else {
    // Create fresh variables (like Prolog's variable renaming)
    const T = new UnboundVar(`T${varCounter.count++}`);
    const result = [undefined, T];  // [_|T] where T is unbound
    
    console.log(`  Created structure: [_, ${T.name}] where ${T.name} is unbound`);
    
    // Recursive call - this will bind T
    const tailValue = makeListWithUnification(n - 1, varCounter);
    
    // Unify T with the result from recursive call
    T.bind(tailValue);
    console.log(`  Unified ${T.name} = ${JSON.stringify(tailValue)}`);
    
    return result;
  }
}

console.log("\n=== VERSION 3: Simulating unification ===");
const unified = makeListWithUnification(3);
console.log("\nFinal structure (with unbound vars):");
console.log(unified);
console.log("\nResolved values:");
console.log(unified.map(v => v instanceof UnboundVar ? v.getValue() : v));


// ============================================
// VERSION 4: Step-by-step trace like our Prolog analysis
// ============================================

function makeListTrace(n, depth = 0) {
  const indent = '  '.repeat(depth);
  const callNum = depth + 1;
  
  console.log(`\n${indent}CALL ${callNum}: make_list(${n}, T${callNum})`);
  
  if (n === 0) {
    console.log(`${indent}  Match base case: make_list(0, [])`);
    console.log(`${indent}  Unify: T${callNum} = []`);
    return [];
  } else {
    console.log(`${indent}  Match recursive case: make_list(N${callNum}, [_${callNum}|T${callNum+1}])`);
    console.log(`${indent}  Unify: N${callNum} = ${n}`);
    console.log(`${indent}  Unify: T${callNum} = [_${callNum}|T${callNum+1}]`);
    console.log(`${indent}  Create goal: make_list(${n-1}, T${callNum+1})`);
    
    const tail = makeListTrace(n - 1, depth + 1);
    
    console.log(`${indent}  T${callNum+1} resolved to: ${JSON.stringify(tail)}`);
    console.log(`${indent}  Therefore T${callNum} = [undefined|${JSON.stringify(tail)}]`);
    
    return [undefined, ...tail];
  }
}

console.log("\n=== VERSION 4: Step-by-step trace ===");
const traced = makeListTrace(3);
console.log("\n\nFinal result:", traced);


// ============================================
// SUMMARY
// ============================================

console.log("\n\n=== SUMMARY ===");
console.log("In Prolog:");
console.log("  Suffix = [_₁|T₁]");
console.log("    where T₁ = [_₂|T₂]");
console.log("      where T₂ = [_₃|T₃]");
console.log("        where T₃ = []");
console.log("\nIn JavaScript (conceptually):");
console.log("  Suffix = [undefined, T₁]");
console.log("  T₁ gets bound to [undefined, T₂]");
console.log("  T₂ gets bound to [undefined, T₃]");
console.log("  T₃ gets bound to []");
console.log("\nAfter all bindings resolve:");
console.log("  Suffix = [undefined, [undefined, [undefined, []]]]");
console.log("  Which flattens to: [undefined, undefined, undefined]");

