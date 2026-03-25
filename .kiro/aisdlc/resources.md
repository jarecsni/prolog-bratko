# AI SDLC Resources

Collection of links, tools, articles, and references for the article and workshop.

---

## Videos

| Title | URL | Notes |
|-------|-----|-------|
| | | |

---

## Atlassian Rovo AI (as of early 2026)

### Core Components
- **Rovo Search** - Unified search across Jira, Confluence, JSM + 50+ third-party apps (Slack, Google Drive, Notion, etc.)
- **Rovo Chat** - Conversational AI that can take actions (create issues, send Slack messages, create calendar events)
- **Rovo Agents** - AI agents that automate tasks, ~2,000+ agents in ecosystem
- **Rovo Studio** - Build custom agents with or without code
- **Rovo Dev** - Separate product for developers (code planning, generation, reviews)

### Out-of-the-Box Agents Relevant to Ideation/BA Work
| Agent | What it does |
|-------|--------------|
| Product Requirements Guide | Creates and reviews PRDs, gives feedback on best practices |
| Work Item Planner | Breaks big projects/epics into smaller actionable tasks |
| OKR Generator | Creates OKRs, finds similar ones in org, reviews drafts |
| Readiness Checker | Checks if work item meets team's definition of ready |
| Bug Report Assistant | Writes clear bug reports with necessary details |
| Release Notes Drafter | Summarises up to 20 Jira items into release notes |

### Rovo Dev (Developer-focused)
- Validates code changes against acceptance criteria in Jira
- Code planning, generation, reviews
- Works with Bitbucket Cloud and GitHub
- Separate pricing from Rovo

### Key Insight for Article
Rovo can validate code against ACs, but the **quality of those ACs** determines the value. If ACs are vague or human-oriented, AI validation is superficial. The BA's realisation - "ACs need to be written with AI consumption in mind" - is the unlock.

### Rollout Timeline
- Premium/Enterprise: April-July 2025
- Standard: August-October 2025
- Free with Jira/Confluence subscriptions (usage quotas vary by tier)

### Sources
- https://idalko.com/blog/atlassian-rovo-transformation
- https://www.atlassian.com/software/rovo-dev
- https://support.atlassian.com/rovo/docs/atlassian-agents/

---

## BA-Friendly AI Tools for AC Generation & Validation

### Jira Marketplace Apps (Native Integration)

| Tool | What it does | BA-Friendly? | Notes |
|------|--------------|--------------|-------|
| **POPal** (AI Test Case & User Story Generator) | Breaks epics into user stories with ACs, generates test cases. Can use org's own LLM. Integrates with Zephyr/Xray. | ✅ Yes | Fortune 500 customers, 10k+ stories generated. Review before saving feature. |
| **AutoStory** | ChatGPT-powered ticket creation. Generates description, ACs, testing details from title. | ✅ Yes | ~15 sec generation time. Saves ~20 min per ticket. |
| **AI Jeannie** | Generates ACs based on project definition + epic/story summary. Append or overwrite existing description. | ✅ Yes | Uses project context. Manual review step with labels. |
| **Agile AI Assistant** | Creates user stories, DoD, DoR. Multi-model (ChatGPT, Gemini). Private AI option. | ✅ Yes | No Jira Premium required. Per-project enablement. |
| **StoryPilot** | AI test case generation, real-time updates. Multi-language support. | ✅ Yes | QA-focused but useful for AC→test flow |
| **QAssert** | Test case generation + user story creation | ✅ Yes | Newer entrant |

### Standalone Tools (Outside Jira)

| Tool | What it does | BA-Friendly? | Notes |
|------|--------------|--------------|-------|
| **StoriesOnBoard** | User story mapping with AI AC generation. Groups criteria into themes. Customisable templates (Given-When-Then, etc.) | ✅ Yes | Visual backlog tool. Good for workshops. |
| **SynqForge** | Transforms meeting notes/briefs into validated user stories with ACs and estimates | ✅ Yes | "AI co-pilot for Agile delivery" |
| **Clipmove AC Builder** | Free online tool for drafting ACs | ✅ Yes | Simple, no integration |
| **Easy-Peasy AI** | Free AC generator | ✅ Yes | Basic, good for quick drafts |
| **Pace AI** | AC drafting tool | ✅ Yes | Focused on AC specifically |

### Key Insight: Generation vs Validation

**Most tools focus on GENERATION** - creating ACs from story titles/descriptions.

**Few tools focus on VALIDATION** - checking if ACs are:
- Complete (cover edge cases, error states)
- Testable (specific enough to write tests against)
- AI-implementable (clear enough for an AI coding agent)

**The gap**: Rovo's "Readiness Checker" validates against team's DoR, but doesn't specifically check "is this implementable by AI?"

**The opportunity**: A tool that validates ACs against AI-implementability criteria:
- Are selectors/identifiers specified or derivable?
- Are state transitions explicit?
- Are error conditions covered?
- Is the happy path unambiguous?

### Kiro + Jira MCP Option

Yes, giving a BA a Kiro license with Jira MCP configured would work, but:
- Requires IDE familiarity
- Overkill for pure BA work
- Better suited for BA/Dev hybrid roles

**More BA-friendly approach**: Use POPal or AI Jeannie in Jira directly, then have a steering rule in Kiro that validates ACs when devs pull stories.

---

## Tools & Repos

| Tool | URL | Category | Notes |
|------|-----|----------|-------|
| AI-DLC Workflows | https://github.com/awslabs/aidlc-workflows | Workflow/Rules | Open-source AI-DLC implementation using Amazon Q Rules or Kiro Steering Files. Three-phase adaptive workflow (Inception, Construction, Operations). Copy rules to `.amazonq/rules/` or `.kiro/steering/` |
| Sample AI-DLC Workflows (Archived) | https://github.com/aws-samples/sample-aidlc-workflows | Workflow/Rules | **ARCHIVED** - Moved to awslabs/aidlc-workflows |
| Spec Kit (GitHub) | https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/ | Spec-Driven Dev | GitHub's open-source toolkit for spec-driven development. Works with Copilot, Claude Code, Gemini CLI. Four phases: Specify → Plan → Tasks → Implement |
| River Crossing Demo | https://prod.d13rzhkk8cj2z0.amplifyapp.com | Demo App | Example app built using AI-DLC workflow (referenced in AWS blog) |

---

## Articles / Blog Posts

| Title | URL | Key Takeaway |
|-------|-----|--------------|
| AI-Driven Development Life Cycle: Reimagining Software Engineering | https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/ | Introduces AI-DLC methodology. Two dimensions: AI as central collaborator + human oversight. Three phases: Inception, Construction, Operations. Replaces "sprints" with "bolts" (hours/days not weeks). Key insight: "Simply retrofitting AI as an assistant constrains its capabilities and reinforces outdated inefficiencies" |
| Building with AI-DLC using Amazon Q Developer | https://aws.amazon.com/blogs/devops/building-with-ai-dlc-using-amazon-q-developer/ | Practical walkthrough of AI-DLC using Amazon Q Developer. Shows Project Rules feature. Demonstrates building River Crossing Puzzle app. Workflow: AI creates plan → asks clarifying questions → implements after human validation |
| Spec-driven development with AI (GitHub Blog) | https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/ | "Vibe-coding" problem: code looks right but doesn't work. Solution: specs as living, executable artifacts. Four phases: Specify (user journeys) → Plan (technical) → Tasks (small chunks) → Implement. Key: "treat coding agents like literal-minded pair programmers, not search engines" |

---

## Research Papers / Whitepapers

| Title | URL | Notes |
|-------|-----|-------|
| AI-DLC Method Definition Paper | (Referenced in AWS blogs) | Defines the three phases: Inception (planning/architecture), Construction (design/implementation), Operations (deployment/monitoring). Adaptive workflow based on complexity. |

---

## Key Concepts from Research

### AI-DLC (AWS)
- **Three Phases**: Inception → Construction → Operations
- **Mental Model**: AI creates plan → asks clarifying questions → implements after human validation
- **Adaptive**: Simple bug fixes skip planning; complex features need full requirements analysis
- **Terminology shift**: "Sprints" → "Bolts" (hours/days), "Epics" → "Units of Work"
- **Persistent context**: AI saves plans, requirements, design artifacts to repo

### Spec Kit (GitHub)
- **Four Phases**: Specify → Plan → Tasks → Implement
- **Specify**: User journeys, experiences, success criteria (not technical)
- **Plan**: Stack, architecture, constraints, compliance requirements
- **Tasks**: Small, reviewable chunks - "like TDD for your AI agent"
- **Key insight**: Specs as living artifacts, not static documents

### Common Themes
1. **Human oversight at checkpoints** - AI proposes, human validates
2. **Structured phases** - Not just "ask AI to build it"
3. **Persistent artifacts** - Context maintained across sessions
4. **Adaptive complexity** - Scale rigour to match the task

---

## Enterprise Multi-Repository AI Context

### The Problem
- Enterprise codebases span 50-500 repositories, millions of lines
- AI context windows (even 200k tokens) see only a fraction
- AI generates code that works in isolation but violates architectural patterns
- Developers become "human thread" coordinating cross-repo changes

### Tool Comparison (Early 2026)

| Tool | Multi-Repo | Context Size | Notes |
|------|-----------|--------------|-------|
| Kiro | ✅ Yes | Not specified | "Changes spanning multiple repositories" - AWS re:Invent 2025. Amazon using internally. |
| GitLab Duo | ⚠️ Single repo | Codebase indexing | Multi-repo in design phase. Vector embeddings for semantic search. |
| Sourcegraph Cody | ✅ Yes | 100k lines/response | Requires Sourcegraph platform. ~$66k/year. Self-hosted. |
| Augment Code | ✅ Yes | 200k tokens, 400k+ files | "Context Engine" with semantic dependency analysis. |
| Amazon Q Developer | ⚠️ Workspace-local | 200k tokens | Cannot aggregate across repositories. |
| GitHub Copilot | ⚠️ Single repo | 128k tokens | Larger window but single-repo focused. |

### Key Insight
Bigger context windows ≠ better multi-repo support. Need *architectural intelligence*:
- Semantic understanding of dependencies
- Service boundary awareness
- Persistent knowledge of org conventions

### Sources
- https://www.theregister.com/2025/12/02/aws_kiro_devops_coding_agents/
- https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/codebase_as_chat_context/
- https://www.augmentcode.com/guides/6-ai-tools-for-cross-repo-dependency-mapping-at-scale
- https://www.augmentcode.com/tools/amazon-q-developer-vs-sourcegraph-cody

---

## GitLab Knowledge Graph & Multi-Repo Roadmap (Deep Dive)

This section provides detailed research on GitLab's approach to multi-repository AI context - particularly relevant for organisations using Kiro + GitLab.

### The Current State (January 2026)

GitLab Duo operates primarily at the single-project level. When you ask Duo Chat a question, it has access to:
- Current file content
- GitLab documentation
- Project-level context (issues, MRs, pipelines) when explicitly referenced
- Repository X-Ray reports for `/refactor`, `/fix`, `/tests` commands

**What's missing:** Semantic understanding across multiple repositories. If your client app depends on 10 internal libraries, Duo doesn't automatically understand those relationships.

### GitLab Knowledge Graph (Beta - 18.4, September 2025)

The Knowledge Graph is GitLab's answer to the multi-repo context problem. It's a property graph that indexes both code and SDLC metadata into a queryable structure.

**Architecture:**
- Property graph format (nodes and edges representing code entities and relationships)
- Powered by ClickHouse (after KuzuDB was archived in October 2025)
- Exposes data via MCP for AI tool integration
- Supports Cypher-like queries (aligned with SQL 2023's ISO/IEC 9075-16:2023 standard)

**What it indexes:**
1. **Code:** Call graphs, definitions, references, repository metadata
2. **SDLC:** MRs, CI pipelines, issues, work items, groups, projects
3. **Custom entities:** Planned for future - user-defined nodes

**Current capabilities (Phase 1):**
- Local CLI tool (`gkg index`) creates a graph database from your repo
- MCP server allows AI tools to query the graph
- Go-to-definition, codebase search, reference tracking
- Single repository only

**Installation:**
```
curl -fsSL https://gitlab.com/gitlab-org/rust/knowledge-graph/-/raw/main/install.sh | bash
gkg index
gkg server start
```

### The Multi-Repo Roadmap

| Phase | What | Status | Timeline |
|-------|------|--------|----------|
| **Phase 1** | Single-project code + SDLC indexing | Beta (18.4) | Now |
| **Phase 2** | Multi-project code graphs | Planned | TBD |
| **Phase 3** | Unified code + SDLC across projects | Planned | TBD |

**Phase 2 explicitly states:** "We will allow users to query across multiple projects simultaneously."

The design document acknowledges this is "a challenging engineering problem" due to scale and query performance across large graphs.

### "Poly Repos" Architecture (Proposed - April 2025)

A separate but related initiative introducing "Change Sets" - the ability to manage cross-repository changes as a single unit.

**Capabilities (when shipped):**
- Push changes spanning multiple projects
- Review changes together in one place
- Run CI across the change set
- Merge when all tests pass
- Revert changes together if needed

**Status:** Still "proposed" - not shipped as of January 2026.

**Target users:** Organisations with multi-repository codebases like Android Open Source Project (1000+ repos).

### What's Actually Available Now

| Feature | Status | Multi-Repo? | Notes |
|---------|--------|-------------|-------|
| Knowledge Graph CLI + MCP | Beta (18.4) | ❌ Single repo | Local indexing only |
| Advanced Search (Elasticsearch) | GA | ✅ Yes | Text/regex search across repos |
| GitLab MCP Server | Beta (18.3+) | ✅ Yes | Search repos, MRs, issues via MCP |
| Duo Agent Platform | GA (18.8) | ⚠️ Single project | "Full context of your project" |
| Exact Code Search | GA (18.5) | ✅ Yes | Regex patterns across terabytes |
| Poly Repos / Change Sets | Proposed | ❌ Not shipped | Cross-repo change management |
| Knowledge Graph Phase 2 | Planned | ✅ Multi-project | Future |

### Practical Workarounds for Kiro + GitLab (Today)

Until Knowledge Graph Phase 2 ships, here's how to get multi-repo context:

**1. GitLab MCP Server (5 min setup)**
- Configure in Kiro's MCP settings
- Provides: repo search, MR access, issue queries
- Limitation: Text search, not semantic understanding

**2. Multi-root Workspace**
- Clone related repos into one parent folder
- Open as multi-root workspace in Kiro
- AI can read files across all repos
- Limitation: Context window limits still apply

**3. Steering Files for Architectural Knowledge**
- Encode cross-repo patterns in `.kiro/steering/`
- Document: "Service A calls Service B via X endpoint"
- AI applies this knowledge even without seeing Service B's code

**4. GitLab Advanced Search + Manual Context**
- Use Elasticsearch-powered search to find cross-repo references
- Manually provide relevant snippets to AI
- Labour-intensive but works

### The Honest Assessment

GitLab is building toward multi-repo AI context, but they're not there yet. The Knowledge Graph is the right architecture - property graphs are well-suited for code relationships - but Phase 2 (multi-project) has no announced timeline.

For organisations using Kiro + GitLab today:
- **Single repo work:** Well-supported via Duo + Knowledge Graph
- **Cross-repo understanding:** Requires workarounds (MCP search + steering files)
- **Cross-repo changes:** Manual coordination until Poly Repos ships

**The gap compared to competitors:**
- Sourcegraph Cody: Multi-repo now, but expensive (~$66k/year)
- Augment Code: Claims 400k+ file context across repos
- Kiro: "Changes spanning multiple repositories" (AWS claim, details unclear)

### Key Sources
- https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/gitlab_knowledge_graph/
- https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/gitlab_knowledge_graph/indexing/
- https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/poly_repos/
- https://gitlab-org.gitlab.io/rust/knowledge-graph
- https://about.gitlab.com/blog/gitlab-18-4-ai-native-development-with-automation-and-insight
- https://about.gitlab.com/blog/exact-code-search-find-code-faster-across-repositories/

---

## To Investigate

Paste links here for research:


