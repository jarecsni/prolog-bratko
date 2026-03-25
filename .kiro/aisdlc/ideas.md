# AI SDLC - Key Ideas

## AI Can Write Complete Test Suites Against Vapourware

### The Problem for Humans

Writing acceptance tests for features that don't exist yet is cognitively brutal:

- **Chained dependencies**: Feature F1 produces state X, F2 consumes X and produces Y, F3 needs both X and Y
- **Consistency across flows**: If F1 changes, do F2 and F3 still make sense?
- **Mental model maintenance**: Humans lose track after a few layers of dependency
- **Tedium fatigue**: Writing verbose Gherkin for 20 scenarios is error-prone

After a few levels of F1 → F2 → F3 → F4, human testers start making inconsistent assumptions, forgetting preconditions, or just giving up and writing shallow tests.

### Why AI Excels Here

AI doesn't get tired. It doesn't forget that F2 depends on F1's output. It can hold the entire flow in context and apply rules consistently across dozens of scenarios.

**Key enablers:**
1. **UX mockups in the story** - AI can see the actual design, not guess at it
2. **Selector naming conventions** - Steering rules or UX specs define `data-testid` patterns
3. **Flow definitions** - The dependency chain is visible in the UX, not invented

With these inputs, AI isn't speculating about a UI that doesn't exist - it's codifying a design that exists visually but hasn't been implemented yet.

### The Mental Gymnastics AI Handles

Given a story with:
- Screenshots of screens A, B, C
- Flow: A → B → C
- Naming convention: `data-testid="[screen]-[action]-[element]"`

AI can:
1. Parse the visual design to identify interactive elements
2. Apply naming rules to generate deterministic selectors
3. Track state transitions across the flow (A produces X, B expects X)
4. Generate complete Gherkin scenarios covering happy path, edge cases, error states
5. Maintain consistency - if A's output changes, flag that B's input assumptions break

This is exactly the kind of systematic, context-heavy, tedium-resistant work that AI does better than humans.

### The Claim for the Article

> "When stories include UX mockups and selector naming conventions, AI can generate complete acceptance test suites against features that don't exist yet. The cognitive load of tracking dependencies across complex multi-step flows - the mental gymnastics that exhaust human testers - is precisely where AI outperforms us. It doesn't forget, doesn't fatigue, and doesn't make inconsistent assumptions three screens deep."

### Why This Matters for the Vision

This capability is what makes the async ATDD flow viable:

```
BA writes story (with UX) → AI validates testability → QA generates AT (AI-assisted) → DEV implements → AT gates deployment
```

Without AI handling the complexity of test generation against vapourware, QA becomes the bottleneck. With it, QA can focus on reviewing and refining AI-generated tests rather than writing them from scratch.

The test suite becomes a **contract written before the code exists** - and AI is what makes that contract comprehensive rather than superficial.


---

## To Unlock the 10x Promise of AI, We Need to Remove the Bottlenecks

The productivity gains from AI coding assistants are real but constrained. You can generate code 10x faster, but if that code still waits 3 days for QA, 2 days for review, and a week for the next release window — you've just created a faster way to fill up a queue.

The 10x promise isn't about typing speed. It's about cycle time from idea to production.

**Current state**: AI accelerates individual tasks within a human-paced pipeline.

**Required state**: AI handles the coordination and handoffs that create the bottlenecks in the first place.

The bottlenecks aren't in the coding — they're in:
- Waiting for requirements clarification
- Waiting for test coverage
- Waiting for code review
- Waiting for QA sign-off
- Waiting for the release window

AI that writes code faster just means features pile up faster at these chokepoints. To actually deliver 10x, we need AI that eliminates the waiting.


---

## Ideation Phase: Today vs Tomorrow

### Today (Early 2026)

**What we actually use:**
- Jira MCP integration - AI coding assistant reads stories directly from Jira
- Atlassian Rovo (built-in) - PRD writing, work item planning, readiness checking

**The BA realisation:**
When we connected the AI coding assistant to Jira via MCP, the BA immediately saw that acceptance criteria need to be written differently. Not just *for* the AI, but *with AI consumption in mind*. Vague, human-oriented ACs that rely on implicit context don't work when an AI agent is going to implement them literally.

**Rovo's current capabilities:**
- Product Requirements Guide agent - creates/reviews PRDs
- Readiness Checker - validates work items against team's definition of ready
- Work Item Planner - breaks epics into tasks
- Rovo Dev can validate code against ACs in Jira

**The gap:**
Rovo can check if ACs exist and are formatted correctly. It can even validate code against them. But it doesn't (yet) validate whether ACs are *AI-implementable* - clear enough that an AI coding agent could implement them without ambiguity.

### Tomorrow (The Vision)

**AI validates testability at story creation:**
- BA writes story with UX mockups
- AI immediately flags: "AC #3 is ambiguous - what happens if the user cancels mid-flow?"
- AI suggests: "Consider adding selector naming convention for the new modal"
- Story doesn't leave ideation until AI confirms it's implementable

**The shift:**
From "is this story ready for a human developer?" to "is this story ready for an AI agent to implement and a human to review?"


---

## Steering Files: The Institutional Knowledge Layer

AI coding assistants are powerful but context-blind. They don't know your team's conventions, your architecture decisions, your naming patterns, or your "we tried that and it didn't work" history. Every session starts from zero.

Steering files change this. They're persistent instructions that travel with the codebase - living documentation that the AI reads before every interaction. Think of them as the institutional knowledge that a senior developer carries in their head, but externalised and consistent.

**What steering files encode:**
- Coding standards and conventions
- Architecture patterns and anti-patterns
- Selector naming conventions (critical for testable UIs)
- Error handling approaches
- Security requirements
- "Don't do X because Y" tribal knowledge

**Why they matter for the pipeline:**
Without steering, every AI interaction is a fresh start. The AI might generate code that works but violates team conventions. Or uses a pattern you deprecated last quarter. Or ignores the selector naming convention that QA depends on for test automation.

With steering, the AI operates within guardrails. It's not just "write code that works" - it's "write code that works *the way we do things here*."

**The connection to acceptance criteria:**
Steering files can include rules like "all interactive UI elements must have data-testid attributes following the pattern [screen]-[action]-[element]". Now when the AI implements a story, it automatically generates testable markup - even if the AC didn't explicitly specify it.

This is how you scale quality: encode it once in steering, apply it to every story automatically.

**AWS AI-DLC calls these "Project Rules"** - same concept, different name. The pattern is emerging across tools because it solves a real problem: AI without context is fast but unreliable. AI with steering is fast *and* consistent.


---

## The Enterprise Code Estate Problem: Cross-Repository Context

Most enterprises don't have *a* codebase - they have 50-500 repositories spanning millions of lines of code. Microservices architectures, shared libraries, internal frameworks, legacy systems. The code estate.

**The problem for AI coding assistants:**

Current AI tools operate within context windows - the amount of code they can "see" at once. Even with 200,000-token windows (roughly 150,000 lines), that's a fraction of an enterprise codebase. The AI sees the current file, maybe some related files, but not:
- How this service depends on three others
- That the authentication pattern was deprecated last quarter
- That changing this API will break consumers in four other repositories
- The internal framework conventions that aren't in public training data

**The result:** AI generates code that works in isolation but violates architectural patterns, breaks downstream dependencies, or ignores organisational conventions. The developer becomes the "human thread" - manually coordinating cross-repository changes, contextualising tasks, collating information across tickets and PRs.

**Current state of tooling (early 2026):**

| Tool | Multi-Repo Capability | Notes |
|------|----------------------|-------|
| **Kiro** | ✅ "Changes spanning multiple repositories" | AWS re:Invent 2025 announcement. Maintains awareness across sessions, learns from PRs. Amazon using internally. |
| **GitLab Duo** | ⚠️ Codebase as context (single repo) | Can index entire repository or sub-directory. Multi-repo support in design phase. |
| **Sourcegraph Cody** | ✅ Full multi-repo context | Requires Sourcegraph platform deployment. Expensive (~$66k/year). Self-hosted for data sovereignty. |
| **Augment Code** | ✅ 400k+ files, cross-repo | "Context Engine" with semantic dependency analysis. Claims architectural understanding, not just context stuffing. |
| **Amazon Q Developer** | ⚠️ Workspace-local indexing | Cannot aggregate across repositories. AWS-centric. |
| **GitHub Copilot** | ⚠️ 128k token context | Larger window, but still single-repo focused. |
| **Cursor** | ⚠️ Single-repo | Good for individual repos, struggles at enterprise scale. |

**The architectural insight:**

Bigger context windows aren't the answer. Cramming more code into context treats a multi-repo architecture as "one big file" rather than a system with service boundaries, dependency graphs, and architectural patterns.

What's needed is *architectural intelligence* - understanding how services relate, which APIs are deprecated, which patterns the team follows. This requires:
1. Indexing across repositories (not just the open workspace)
2. Semantic understanding of dependencies (not just text matching)
3. Persistent knowledge of organisational conventions (steering files help here)

**The gap for most teams:**

- Kiro and Augment claim multi-repo capability, but adoption is early
- GitLab Duo is building toward it but not there yet
- Sourcegraph Cody works but requires significant platform investment
- Most teams are still in "AI sees one repo at a time" mode

**Implication for the pipeline:**

If AI can't see across repositories, it can't:
- Validate that a change won't break downstream consumers
- Generate code that follows patterns from shared libraries
- Understand the full impact of a story that touches multiple services

This is a current limitation, not a permanent one. The tooling is evolving fast. But for now, humans remain the "architectural glue" that AI can't replace.


---

## MCP: The Bridge for Multi-Repository Context

Model Context Protocol (MCP) is emerging as the solution to the "AI can only see one repo" problem. Instead of waiting for AI tools to natively support multi-repo, MCP lets you plug in external context sources.

**What MCP enables:**

MCP servers act as bridges between AI assistants and external data. The AI doesn't need to "see" all your repositories - it can query an MCP server that has indexed them.

**Current MCP solutions for code estate context:**

| MCP Server | What it does | Multi-Repo? |
|------------|--------------|-------------|
| **Sourcegraph MCP** | Full code search, navigation, analysis. Keyword search, semantic search, go-to-definition, find-references, commit search, diff search. | ✅ Yes - searches across all indexed repos |
| **GitHub MCP** | Official GitHub server. Search code, repos, issues, PRs. | ✅ Yes - searches across GitHub |
| **GitLab MCP** | Access repos, MRs, code review, diffs. Multiple community versions. | ✅ Yes - searches across GitLab |
| **VectorCode** | Semantic code indexing with ChromaDB. RAG for codebases. | ✅ Yes - indexes multiple repos |
| **Enterprise Code Search** | Semantic search across local projects and Git repos using AI embeddings. | ✅ Yes |

**The Sourcegraph MCP is particularly powerful:**
- `keyword_search` - Exact matches with boolean operators
- `nls_search` - Semantic/linguistic search (broader matching)
- `go_to_definition` - Cross-repository symbol navigation
- `find_references` - Find all usages across repos
- `commit_search` - Search by author, message, date
- `diff_search` - Search actual code changes

**How this changes the game:**

Instead of the AI being limited to the open workspace, you configure an MCP server that has indexed your entire code estate. When the AI needs to understand a dependency, it queries the MCP server. When it needs to find where an API is used, it searches across all repos.

**The practical setup:**
1. Deploy Sourcegraph (or similar) to index your repositories
2. Configure the Sourcegraph MCP server in your AI tool (Kiro, Cursor, Claude, etc.)
3. AI now has "eyes" across your entire codebase

**Current limitations:**
- Requires infrastructure (Sourcegraph deployment, or similar)
- MCP adoption is still early (though growing fast - 90% org adoption projected by late 2025)
- Quality depends on indexing - stale indexes = stale context

**The key insight:**

MCP is the "API for AI context". Just as REST APIs let applications talk to services, MCP lets AI assistants talk to knowledge sources. The multi-repo problem isn't solved by bigger context windows - it's solved by giving AI the ability to *query* rather than *contain*.


---

## Sourcegraph Deep Dive: How It Actually Works for Enterprise

Let's get concrete. Imagine a banking client app that depends on a platform offering 10 internal libraries. Or a large bank with hundreds of repositories across multiple teams.

### The Architecture

**1. Code Host Connections**
Sourcegraph connects to your code hosts (GitHub, GitLab, Bitbucket, or generic Git). It syncs repository metadata and clones the code. Supports:
- Up to 100,000 repositories
- Monorepos up to 16GB
- 10,000 users
- Multiple code hosts simultaneously (e.g., GitHub + GitLab)

**2. Two Types of Code Intelligence**

| Type | How it works | Accuracy | Setup |
|------|--------------|----------|-------|
| **Search-based** | Text/regex matching, heuristics | Good for simple cases | Automatic |
| **Precise (SCIP/LSIF)** | Compiler-level analysis, pre-indexed | Compiler-accurate | Requires indexing |

**Search-based** is the fallback - works immediately but can have false positives/negatives.

**Precise code navigation** is the magic. It uses SCIP (Sourcegraph Code Intelligence Protocol) or LSIF (Language Server Index Format) to pre-compute:
- Go-to-definition (cross-repository!)
- Find all references (across all indexed repos)
- Hover documentation
- Dependency navigation

**3. How Precise Indexing Works**

For each repository, you run a language-specific indexer (scip-java, scip-typescript, etc.) that:
1. Parses the code with compiler-level accuracy
2. Generates an index of all symbols, definitions, references
3. Uploads the index to Sourcegraph

This can be:
- **Manual**: Run indexer in CI, upload to Sourcegraph
- **Auto-indexing**: Sourcegraph executors automatically index your repos

**Supported languages (generally available):**
- Go, TypeScript/JavaScript, Java/Kotlin/Scala, Python, Ruby, Rust, C/C++, C#

### The Banking Scenario

**Your client app + 10 platform libraries:**

1. **Setup**: Connect Sourcegraph to your code host (GitHub Enterprise, GitLab, etc.)
2. **Indexing**: Configure auto-indexing for all 11 repositories
3. **Cross-repo navigation**: When you're in your client app and call `platformLib.authenticate()`, Sourcegraph can:
   - Jump to the definition in the platform library
   - Show all other consumers of that method across all repos
   - Show the commit history of that method

**The MCP layer:**

Once Sourcegraph is indexing your code estate, the MCP server exposes this to AI:

```
AI: "Where is PaymentService.processTransaction defined?"
→ MCP query to Sourcegraph
→ Returns: platform-payments/src/services/PaymentService.java:142

AI: "What other services call this method?"
→ MCP query to Sourcegraph  
→ Returns: 
  - client-app/src/checkout/CheckoutFlow.java:89
  - batch-processor/src/jobs/ReconciliationJob.java:234
  - admin-portal/src/controllers/RefundController.java:67
```

### Practical Considerations

**Pricing (as of early 2026):**
- Enterprise Starter: $19/user/month (up to 50 devs, 100 repos)
- Enterprise: Custom pricing (median ~$66k/year per Vendr data)
- Self-hosted: Same product, you manage infrastructure

**For a bank:**
- Self-hosted is likely required (data sovereignty, compliance)
- Need to run indexers in CI pipelines
- Initial setup: days to weeks depending on repo count
- Ongoing: indexes update automatically via CI or auto-indexing

**What you get:**
- AI can "see" across your entire code estate via MCP
- Cross-repository go-to-definition and find-references
- Semantic search (not just text matching)
- Commit and diff search across all repos

**What you don't get (yet):**
- Real-time awareness of uncommitted changes
- Automatic understanding of runtime dependencies (only static analysis)
- Magic - still need to set up and maintain the infrastructure

### The Bottom Line

Sourcegraph + MCP is the most mature solution for giving AI visibility across an enterprise code estate. It's not trivial to set up, but it's production-proven at scale (4 of top 10 US banks are customers).

For your "client app + 10 libraries" scenario, it's probably overkill unless you're already using Sourcegraph. But for a large bank with hundreds of repos? It's the answer to "how does AI understand our architecture?"


---

## Lighter-Weight Options: Multi-Repo Context Without Sourcegraph

Not everyone needs (or can afford) Sourcegraph. Here's what you can do with just MCP servers:

### Option 1: GitHub/GitLab MCP Servers (Simplest)

**GitHub MCP Server** (Official, from GitHub):
- Browse and query code across any repo you have access to
- Search files, analyse commits, understand project structure
- Manage issues and PRs
- Works with GitHub Enterprise too

**What it gives you:**
```
AI: "Search for PaymentService across all my repos"
→ GitHub API search
→ Returns matches from multiple repositories
```

**Limitations:**
- Text/regex search only (not semantic)
- No go-to-definition or find-references
- Rate limited by GitHub API
- Can't see uncommitted local changes

**Setup:** Add to your MCP config, authenticate with PAT or OAuth. Done in 5 minutes.

### Option 2: Code Context MCP (Local Semantic Search)

**Code Context MCP** (Open source):
- Clones repos locally
- Generates embeddings for code chunks (using Ollama or OpenAI)
- Semantic search across indexed code
- Stores in SQLite

**What it gives you:**
```
AI: "Find code related to authentication flow"
→ Semantic search across embeddings
→ Returns conceptually related code, not just text matches
```

**Limitations:**
- Need to clone repos locally
- Embedding generation takes time
- No compiler-level accuracy (semantic similarity, not symbol resolution)
- You manage the infrastructure

**Setup:** Clone, npm install, configure Ollama for embeddings. ~30 mins.

### Option 3: VectorCode (RAG for Codebases)

**VectorCode**:
- Indexes code with ChromaDB
- Semantic search via embeddings
- CLI, MCP server, and Neovim plugin
- Designed for RAG use cases

**Similar to Code Context MCP but more mature tooling.**

### Option 4: Multi-Root Workspace + Native Indexing

**The simplest approach for your "client app + 10 libraries" scenario:**

1. Clone all 11 repos into a parent folder
2. Open the parent folder in VS Code/Kiro as a multi-root workspace
3. Let the IDE's native indexing handle cross-repo navigation
4. AI assistant sees all repos in context

**What it gives you:**
- Native go-to-definition across repos (if language server supports it)
- AI can read any file across all repos
- No additional infrastructure

**Limitations:**
- Context window limits still apply
- Not truly "semantic" - AI still needs to read files
- Doesn't scale to hundreds of repos

### Comparison Table

| Approach | Setup Time | Multi-Repo Search | Semantic? | Go-to-Def | Scale |
|----------|-----------|-------------------|-----------|-----------|-------|
| GitHub/GitLab MCP | 5 mins | ✅ | ❌ | ❌ | Unlimited (API) |
| Code Context MCP | 30 mins | ✅ | ✅ | ❌ | 10s of repos |
| VectorCode | 30 mins | ✅ | ✅ | ❌ | 10s of repos |
| Multi-root workspace | 10 mins | ⚠️ (manual) | ❌ | ✅ (native) | ~10 repos |
| Sourcegraph + MCP | Days | ✅ | ✅ | ✅ | 100k repos |

### The Practical Recommendation

**For your "client app + 10 platform libraries" scenario:**

1. **Start with multi-root workspace** - Open all repos in one workspace, let native tooling handle navigation
2. **Add GitHub MCP** - For searching across repos when you need to find something
3. **Consider Code Context MCP** - If you want semantic search and have time to set up embeddings

**For a large bank with hundreds of repos:**
- Sourcegraph is probably the right answer
- Or accept that AI won't have full cross-repo visibility and use steering files to encode architectural knowledge manually

### The Key Insight

The gap isn't "can AI search multiple repos?" - GitHub MCP does that today.

The gap is "can AI understand how code in repo A relates to code in repo B at a semantic level?" - That requires either:
1. Compiler-level indexing (Sourcegraph)
2. Embedding-based similarity (Code Context MCP, VectorCode)
3. Human-encoded knowledge (steering files)

For most teams, a combination of GitHub MCP + steering files is the pragmatic middle ground.


---

## The "Evil Masterplan": Lazy-Loading Library Context via Steering

*AKA: How to get Sourcegraph-like multi-repo awareness without Sourcegraph, new tools, or procurement approval.*

### The Problem

You're in an enterprise. You have 10, 50, maybe 100 internal libraries. Your AI coding assistant can't see them. Sourcegraph costs £50k/year and requires a 6-month procurement cycle. GitLab Knowledge Graph Phase 2 (multi-repo) has no ship date. You need a solution *now*, using only what you already have.

### The Insight

You already have:
- **Kiro** (or similar AI IDE)
- **GitLab MCP** (searches your code estate)
- **Context7 MCP** (for third-party library docs)
- **Steering files** (persistent instructions)

What if steering files could orchestrate these tools to *build their own context* on demand?

### The Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        STEERING RULES                           │
│                                                                 │
│  "When you encounter an import from org/*, check if a snapshot  │
│   exists in .kiro/library-snapshots/. If not, or if stale,     │
│   fetch via GitLab MCP and generate an API extract."           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AI ENCOUNTERS IMPORT                       │
│                                                                 │
│  import { PaymentService } from '@org/platform-payments'        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CHECK LOCAL CACHE                          │
│                                                                 │
│  .kiro/library-snapshots/platform-payments.md exists?           │
│  └─ Yes → Check timestamp against GitLab main branch            │
│  └─ No  → Fetch and generate                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│      CACHE HIT           │    │      CACHE MISS/STALE    │
│                          │    │                          │
│  Use existing snapshot   │    │  1. GitLab MCP: fetch    │
│  for context             │    │     source files         │
│                          │    │  2. Generate API extract │
│                          │    │  3. Save with timestamp  │
│                          │    │  4. Use for context      │
└──────────────────────────┘    └──────────────────────────┘
```

### The Snapshot Format

```markdown
# platform-payments API Snapshot

**Last Updated:** 2026-01-15T14:32:00Z
**Source:** gitlab.company.com/org/platform-payments
**Main Branch SHA:** a1b2c3d4

## Public API

### PaymentService

```typescript
class PaymentService {
  /**
   * Process a payment transaction
   * @param amount - Amount in pence
   * @param currency - ISO 4217 currency code
   * @param merchantId - Registered merchant identifier
   * @returns TransactionResult with status and reference
   */
  processTransaction(amount: number, currency: string, merchantId: string): Promise<TransactionResult>
  
  /**
   * Refund a previous transaction
   * @param transactionRef - Original transaction reference
   * @param amount - Partial refund amount (optional, defaults to full)
   */
  refundTransaction(transactionRef: string, amount?: number): Promise<RefundResult>
}
```

### Types

```typescript
interface TransactionResult {
  status: 'success' | 'declined' | 'pending'
  reference: string
  timestamp: Date
}
```

## Usage Patterns

- Always wrap in try/catch - throws `PaymentError` on network issues
- `merchantId` must be pre-registered via admin portal
- Currency conversion handled automatically if merchant supports it

## Dependencies

- Requires `@org/auth-client` for service-to-service auth
- Uses `@org/logging` for audit trail
```

### Why This Works

1. **Lazy loading** - Only indexes libraries you actually use
2. **Self-maintaining** - Timestamp check is one cheap API call
3. **Context-efficient** - API extract is ~10% the size of full source
4. **Credential-scoped** - Naturally respects your GitLab access
5. **Zero infrastructure** - Uses existing tools
6. **Incremental** - Builds knowledge base over time as you work

### The Steering Rules

```markdown
# Library Context Management

## Internal Libraries (@org/*)

When you encounter an import from `@org/*`:

1. **Check cache**: Look for `.kiro/library-snapshots/{library-name}.md`

2. **If exists**: 
   - Use GitLab MCP to get the latest commit date on main branch
   - Compare with `Last Updated` in snapshot
   - If snapshot is older, regenerate
   - If current, use snapshot for context

3. **If missing or stale**:
   - Use GitLab MCP to fetch: README, main export files, type definitions
   - Generate an API snapshot containing:
     - Public classes/functions with JSDoc/docstrings
     - Type definitions
     - Usage patterns from README
     - Key dependencies
   - Save to `.kiro/library-snapshots/{library-name}.md`
   - Include timestamp and source SHA

4. **Depth limit**: Follow imports 2 levels deep, then stop

## Third-Party Libraries

For npm/PyPI packages not in training data:
- Use Context7 MCP to fetch current documentation
- Cache results in `.kiro/library-snapshots/external/`

## Force Refresh

If user says "refresh library context for X":
- Delete existing snapshot
- Regenerate from source
```

### Edge Cases & Gotchas

**First encounter is slow:**
- Fetching and summarising a library takes 30-60 seconds
- Acceptable trade-off for zero-infrastructure solution
- Gets faster as cache builds up

**Deep transitive dependencies:**
- Depth limit prevents infinite recursion
- May miss context from deeply nested deps
- Solution: manually trigger refresh for critical deps

**Private implementation details:**
- Snapshot only captures public API
- Sometimes you need internal details
- Solution: steering rule to fetch specific files on request

**Stale detection isn't perfect:**
- Checks main branch timestamp, not specific files
- Could miss changes in feature branches
- Acceptable for most use cases

### The Registry (Optional Enhancement)

Instead of checking each library individually, maintain a central registry:

```json
// .kiro/library-registry.json
{
  "libraries": {
    "platform-payments": {
      "lastUpdated": "2026-01-15T14:32:00Z",
      "mainSha": "a1b2c3d4",
      "snapshotPath": ".kiro/library-snapshots/platform-payments.md"
    },
    "auth-client": {
      "lastUpdated": "2026-01-10T09:15:00Z",
      "mainSha": "e5f6g7h8",
      "snapshotPath": ".kiro/library-snapshots/auth-client.md"
    }
  },
  "lastFullCheck": "2026-01-15T14:00:00Z"
}
```

Steering rule: "At start of session, if `lastFullCheck` is >24h old, batch-check all library timestamps via GitLab MCP."

### Why This Is "Evil"

It's not actually evil - it's just clever. You're:
- Not asking for new tools
- Not waiting for GitLab to ship Phase 2
- Not paying for Sourcegraph
- Not violating any policies

You're just... using steering files creatively. The AI builds its own knowledge base, maintains it automatically, and operates within your existing access controls.

**The "evil" part:** You've essentially replicated 80% of Sourcegraph's value proposition using nothing but text files and existing MCP integrations. No procurement. No infrastructure. No approval needed.

### For the Article

> "While waiting for native multi-repo support, teams can use steering files to orchestrate existing MCP tools into a self-maintaining library context system. The AI lazily indexes internal libraries on first encounter, caches API extracts locally, and invalidates based on source timestamps. It's not as powerful as Sourcegraph's compiler-level indexing, but it's free, requires no infrastructure, and works today."

