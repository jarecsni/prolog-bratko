// A notebook runtime for Prolog, built on swipl-wasm.
//
// The difference from Jupyter: a Prolog query does not produce "the" answer, it
// produces answers one at a time on backtracking. So a query cell has a Run button
// *and* a "; next" button, and stepping it is the point rather than a detail.

let swipl = null;
let readyPromise = null;

function boot() {
  if (!readyPromise) {
    readyPromise = SWIPL({ arguments: ['-q'] }).then((m) => {
      swipl = m;
      return m;
    });
  }
  return readyPromise;
}

// --- program cells --------------------------------------------------------

let programSerial = 0;

function initProgramCell(cell) {
  const source = cell.querySelector('textarea');
  const button = cell.querySelector('button');
  const status = cell.querySelector('.status');
  const path = `/cell${programSerial++}.pl`;

  autosize(source);

  button.addEventListener('click', async () => {
    status.textContent = 'loading Prolog…';
    status.className = 'status busy';
    await boot();
    try {
      swipl.FS.writeFile(path, source.value);
      const r = swipl.prolog.query(`user:consult('${path}')`).once();
      if (r && r.success === false) throw new Error('consult failed');
      status.textContent = 'consulted';
      status.className = 'status ok';
      cell.dataset.consulted = 'true';
    } catch (e) {
      status.textContent = e.message;
      status.className = 'status err';
    }
  });
}

// --- query cells ----------------------------------------------------------

function initQueryCell(cell) {
  const input = cell.querySelector('input');
  const runBtn = cell.querySelector('[data-act="run"]');
  const nextBtn = cell.querySelector('[data-act="next"]');
  const allBtn = cell.querySelector('[data-act="all"]');
  const out = cell.querySelector('.out');

  let query = null;
  let count = 0;

  const write = (text, cls) => {
    const line = document.createElement('div');
    line.className = `line ${cls || ''}`;
    line.textContent = text;
    out.appendChild(line);
    out.scrollTop = out.scrollHeight;
  };

  const bindings = (value) => {
    const pairs = Object.entries(value).filter(([k]) => k !== '$tag' && k !== 'success');
    if (!pairs.length) return 'true';
    return pairs.map(([k, v]) => `${k} = ${format(v)}`).join(',  ');
  };

  // The engine can deliver the final solution *with* done:true — a solution and the
  // end of the search in one step. Report the binding before reporting exhaustion.
  const step = () => {
    if (!query) return;
    const r = query.next();
    if (r.error) {
      write(r.message, 'err');
      finish();
      return;
    }
    if (r.value) {
      count += 1;
      write(`${count}.  ${bindings(r.value)}`, 'sol');
    }
    if (r.done) {
      write(count === 0 ? 'false.' : 'no more solutions.', 'done');
      finish();
    }
  };

  const finish = () => {
    query = null;
    nextBtn.disabled = true;
    allBtn.disabled = true;
  };

  runBtn.addEventListener('click', async () => {
    out.innerHTML = '';
    count = 0;
    await boot();
    const goal = input.value.trim().replace(/\.$/, '');
    if (!goal) return;
    write(`?- ${goal}.`, 'echo');
    try {
      // Cells consult into `user`, but prolog.query/1 runs with `system` as the
      // context module — so an unqualified goal resolves against the wrong module.
      query = swipl.prolog.query(`user:( ${goal} )`);
      nextBtn.disabled = false;
      allBtn.disabled = false;
      step();
    } catch (e) {
      write(e.message, 'err');
      finish();
    }
  });

  nextBtn.addEventListener('click', step);

  allBtn.addEventListener('click', () => {
    // guard against a genuinely infinite generator
    let guard = 0;
    while (query && guard++ < 500) step();
    if (guard >= 500) write('stopped after 500 solutions.', 'done');
  });

  input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') runBtn.click();
    if (e.key === ';') { e.preventDefault(); if (!nextBtn.disabled) step(); }
  });
}

// --- helpers --------------------------------------------------------------

function format(v) {
  if (v === null || v === undefined) return '_';
  if (Array.isArray(v)) return `[${v.map(format).join(', ')}]`;
  if (typeof v === 'object') {
    if (v.$tag === 'string') return `"${v.text}"`;
    if (v.functor) return `${v.functor}(${(v.args || []).map(format).join(', ')})`;
    if (v.v !== undefined) return `_${v.v}`;
    return JSON.stringify(v);
  }
  return String(v);
}

function autosize(ta) {
  const fit = () => {
    ta.style.height = 'auto';
    ta.style.height = `${ta.scrollHeight}px`;
  };
  ta.addEventListener('input', fit);
  requestAnimationFrame(fit);
}

document.querySelectorAll('.cell.program').forEach(initProgramCell);
document.querySelectorAll('.cell.query').forEach(initQueryCell);
