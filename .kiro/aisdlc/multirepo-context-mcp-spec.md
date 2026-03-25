# Multi-Repository Context MCP Server

## Specification Document

**Version:** 2.0.0  
**Author:** [Your Name]  
**Date:** January 2026  
**Status:** Ready for Implementation

> **Note:** This specification includes vector search as core MVP functionality. The "don't reinvent the wheel" use case - arguably the most valuable - requires semantic search to work at scale. See "Why Vector Search is Required" section for rationale.

---

## Executive Summary

This document specifies an MCP (Model Context Protocol) server that provides AI coding assistants with context about project dependencies by reading directly from `node_modules`. It solves the "dependency blindness" problem with zero network calls and no external service dependencies.

**The Problem:** AI assistants can't see what your dependencies expose. When your code imports `@org/payments-lib`, the AI has no idea what that library's API looks like.

**The Solution:** An MCP server that:
1. Reads dependency metadata and types directly from `node_modules`
2. Generates compact API snapshots from type definitions (`.d.ts` files)
3. Indexes snapshots in a local vector database for semantic search
4. Caches snapshots locally, invalidated by version changes
5. Optionally enriches with source from GitLab when types are insufficient

**Key Benefits:**
- Zero network calls for core functionality
- No authentication required (reads local filesystem)
- Instant response (no API latency)
- Semantic search: "find me a date formatter" → finds `@company/utils.formatDate`
- Auto-invalidates when `npm install` updates versions
- Works offline

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     AI CODING ASSISTANT                         │
│                    (Kiro, Cursor, etc.)                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ MCP Protocol
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  DEPENDENCY CONTEXT MCP SERVER                  │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │   Tools     │  │   Cache     │  │   Filesystem Reader     │ │
│  │             │  │   Manager   │  │                         │ │
│  │ • get_dep   │  │             │  │ • Read package.json     │ │
│  │ • list_deps │  │ • Check ver │  │ • Parse .d.ts files     │ │
│  │ • refresh   │  │ • Store     │  │ • Read README.md        │ │
│  │ • search    │  │ • Invalidate│  │ • Find source if avail  │ │
│  │ • semantic  │  └─────────────┘  └─────────────────────────┘ │
│  └─────────────┘                                                │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │   VECTOR DATABASE (ChromaDB)                                ││
│  │   • Stores embeddings of exported symbols                   ││
│  │   • Enables semantic search: "date formatter" → formatDate  ││
│  │   • Local, no external service required                     ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │   OPTIONAL: GitLab Client (for source enrichment)          ││
│  │   Only used when .d.ts insufficient and repo URL available ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌──────────────────┐  ┌──────────────┐  ┌──────────────────────┐
│  node_modules/   │  │ LOCAL CACHE  │  │   VECTOR INDEX       │
│                  │  │              │  │                      │
│ @company/pay/    │  │ .cache/      │  │ .cache/chromadb/     │
│ ├── package.json │  │ ├── registry │  │ ├── collections/     │
│ ├── index.d.ts   │  │ └── snaps/   │  │ │   └── deps/        │
│ ├── dist/        │  │     └── *.md │  │ └── embeddings       │
│ └── README.md    │  │              │  │                      │
└──────────────────┘  └──────────────┘  └──────────────────────┘
```

---

## Core Principle: Local-First

The server reads from `node_modules` which already contains:

| File | Information |
|------|-------------|
| `package.json` | Name, version, description, repository URL, entry points |
| `*.d.ts` | **Full type definitions** - the complete public API |
| `README.md` | Documentation (often shipped with package) |
| `src/` | Source code (sometimes shipped, especially internal packages) |
| `CHANGELOG.md` | Version history and breaking changes |

**No network calls needed.** The dependencies are already installed locally.

**Cache invalidation is trivial:** Compare `package.json` version with cached version. When developer runs `npm install` and version changes, cache auto-invalidates.

---

## MCP Tool Definitions

### Tool 1: `get_dependency_context`

**Purpose:** Retrieve API context for an installed dependency by reading from `node_modules`.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "package_name": {
      "type": "string",
      "description": "Package name as it appears in imports, e.g., '@company/payments' or 'lodash'"
    },
    "include_source": {
      "type": "boolean",
      "description": "Include source code if available (slower, more detail)",
      "default": false
    }
  },
  "required": ["package_name"]
}
```

**Output:**
```json
{
  "package": "@company/payments",
  "version": "2.1.0",
  "installed": true,
  "cache_status": "hit|miss|refreshed",
  "source_type": "types|source|readme_only",
  "repository": "https://gitlab.company.com/org/payments",
  "context": "# @company/payments API\n\n## Types\n\n..."
}
```

**Behaviour:**
1. Resolve package path in `node_modules` (handles scoped packages)
2. Read `package.json` for metadata
3. Check cache: if version matches, return cached snapshot
4. If cache miss: parse `.d.ts` files for type definitions
5. Include README.md content if present
6. Optionally include `src/` if `include_source=true` and source exists
7. Generate and cache snapshot
8. Return snapshot content

---

### Tool 2: `list_dependencies`

**Purpose:** List all dependencies with their context availability status.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "include_dev": {
      "type": "boolean",
      "description": "Include devDependencies",
      "default": false
    },
    "filter": {
      "type": "string",
      "description": "Filter by package name pattern (glob)",
      "default": "*"
    }
  },
  "required": []
}
```

**Output:**
```json
{
  "project": "my-app",
  "dependencies": [
    {
      "name": "@company/payments",
      "version": "2.1.0",
      "has_types": true,
      "has_source": false,
      "has_readme": true,
      "cached": true,
      "repository": "https://gitlab.company.com/org/payments"
    },
    {
      "name": "lodash",
      "version": "4.17.21",
      "has_types": true,
      "has_source": false,
      "has_readme": true,
      "cached": false,
      "repository": "https://github.com/lodash/lodash"
    }
  ],
  "total": 45,
  "with_types": 42,
  "cached": 12
}
```

---

### Tool 3: `refresh_dependency`

**Purpose:** Force regeneration of a dependency snapshot.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "package_name": {
      "type": "string",
      "description": "Package name to refresh"
    }
  },
  "required": ["package_name"]
}
```

**Output:**
```json
{
  "package": "@company/payments",
  "status": "refreshed",
  "previous_version": "2.0.0",
  "current_version": "2.1.0",
  "types_extracted": 24,
  "readme_included": true
}
```

---

### Tool 4: `search_dependencies`

**Purpose:** Search installed dependencies by name or description.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "query": {
      "type": "string",
      "description": "Search term"
    }
  },
  "required": ["query"]
}
```

**Output:**
```json
{
  "query": "payment",
  "results": [
    {
      "name": "@company/payments",
      "version": "2.1.0",
      "description": "Payment processing utilities",
      "match_type": "name"
    },
    {
      "name": "@company/checkout",
      "version": "1.5.0",
      "description": "Checkout flow with payment integration",
      "match_type": "description"
    }
  ]
}
```

---

### Tool 5: `enrich_from_source` (Optional - Requires GitLab)

**Purpose:** Fetch additional context from source repository when local types are insufficient.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "package_name": {
      "type": "string",
      "description": "Package name"
    },
    "files": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Specific files to fetch (e.g., ['src/utils.ts', 'docs/API.md'])"
    }
  },
  "required": ["package_name"]
}
```

**Output:**
```json
{
  "package": "@company/payments",
  "repository": "https://gitlab.company.com/org/payments",
  "files_fetched": ["src/PaymentService.ts", "src/types.ts"],
  "enriched_context": "## Source Code\n\n### PaymentService.ts\n..."
}
```

**Note:** This tool requires GitLab authentication and is only needed when:
- Package doesn't ship `.d.ts` files
- Package doesn't ship source
- You need implementation details, not just API

---

### Tool 6: `search_codebase` (Semantic Search)

**Purpose:** Semantically search across all indexed dependencies to find relevant functionality. This is the key tool for "don't reinvent the wheel" - finding existing solutions before writing new code.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "query": {
      "type": "string",
      "description": "Natural language description of what you're looking for, e.g., 'format currency for display' or 'validate email address'"
    },
    "limit": {
      "type": "number",
      "description": "Maximum number of results to return",
      "default": 5
    },
    "packages": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Filter to specific packages (glob patterns supported), e.g., ['@company/*']",
      "default": ["*"]
    },
    "min_relevance": {
      "type": "number",
      "description": "Minimum relevance score (0-1) to include in results",
      "default": 0.7
    },
    "confirm_indexing": {
      "type": "boolean",
      "description": "If true, proceed with indexing unindexed packages. If false/omitted and indexing would take >3s, returns confirmation_required status instead of blocking.",
      "default": false
    }
  },
  "required": ["query"]
}
```

**Output (success - index exists):**
```json
{
  "status": "success",
  "query": "format currency for display",
  "results": [
    {
      "package": "@company/utils",
      "symbol": "formatCurrency",
      "type": "function",
      "signature": "formatCurrency(amount: number, currency: string, locale?: string): string",
      "description": "Formats a numeric amount as a localised currency string with proper symbol placement and decimal handling",
      "relevance": 0.94,
      "file": "dist/formatting.d.ts"
    },
    {
      "package": "@company/payments",
      "symbol": "PaymentFormatter.formatAmount",
      "type": "method",
      "signature": "formatAmount(amount: number): string",
      "description": "Formats payment amounts using the merchant's configured currency",
      "relevance": 0.87,
      "file": "dist/index.d.ts"
    }
  ],
  "indexed_packages": 45,
  "total_symbols": 1247
}
```

**Output (confirmation required - cold start):**
```json
{
  "status": "confirmation_required",
  "action": "index_packages",
  "reason": "First-time setup: packages need to be indexed before searching",
  "packages_to_index": ["@company/payments", "@company/utils", "@company/auth"],
  "packages_already_indexed": [],
  "estimated_duration_seconds": 12,
  "estimated_symbols": 150,
  "message": "8 internal packages need to be indexed. This is a one-time operation that enables semantic search across your dependencies. Retry with confirm_indexing=true to proceed."
}
```

**Output (success after indexing):**
```json
{
  "status": "success",
  "results": [...],
  "indexing_performed": true,
  "packages_indexed": ["@company/payments", "@company/utils", "@company/auth"],
  "indexing_duration_ms": 11420,
  "symbols_indexed": 147,
  "message": "Indexed 8 packages (one-time setup complete)"
}
```

**Behaviour:**
1. Check which packages in scope need indexing
2. If indexing needed and estimated time >3s and `confirm_indexing=false`:
   - Return `confirmation_required` status (don't block)
3. If indexing needed and (`confirm_indexing=true` OR estimated time ≤3s):
   - Index packages in parallel
   - Include indexing metadata in response
4. Convert query to embedding using configured embedding model
5. Search ChromaDB for semantically similar symbols
6. Filter by package patterns if specified
7. Return ranked results with relevance scores

**Handling confirmation_required (steering guidance):**

When the AI receives `status: "confirmation_required"`, it should:
1. Explain to the user that one-time indexing is needed
2. State the estimated duration
3. Ask if the user wants to proceed
4. If yes, retry with `confirm_indexing: true`
5. If no, proceed without searching (explain trade-off)

**Why This is MVP:**
Without semantic search, the AI would need to:
1. Call `list_dependencies` → 50 packages
2. Call `get_dependency_context` for each → 50 API calls
3. Read ~500KB of markdown to find "formatCurrency"

With semantic search:
1. Call `search_codebase("format currency")` → instant result

The "check before you build" steering rule is impractical without this tool.

---

### Tool 7: `refresh_index`

**Purpose:** Manually trigger reindexing of packages. Useful after major dependency updates or when troubleshooting stale results.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "packages": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Packages to reindex (glob patterns supported, e.g., '@company/*'). If empty, reindexes all stale packages."
    },
    "force": {
      "type": "boolean",
      "description": "Force reindex even if version hasn't changed",
      "default": false
    }
  },
  "required": []
}
```

**Output:**
```json
{
  "reindexed": ["@company/utils", "@company/payments"],
  "skipped": ["@company/auth"],
  "skipped_reason": "version unchanged",
  "errors": [],
  "total_symbols": 847,
  "duration_ms": 5420
}
```

**Behaviour:**
1. If `packages` empty, find all packages where installed version ≠ indexed version
2. If `force=true`, reindex regardless of version match
3. For each package: extract types → generate summaries → create embeddings → upsert to ChromaDB
4. Update registry with new index metadata

**Note:** This is the only tool that intentionally blocks for extended periods. Use sparingly.

---

## Snapshot Format

Each dependency snapshot is a Markdown file optimised for AI consumption:

```markdown
# {package-name} v{version}

**Description:** {from package.json}  
**Repository:** {repository URL if available}  
**Generated:** {ISO timestamp}  
**Source:** node_modules (types)

---

## Overview

{Content from README.md, truncated to first 500 words}

---

## Exported Types

### Interfaces

```typescript
export interface PaymentRequest {
  /** Amount in smallest currency unit (e.g., pence) */
  amount: number
  /** ISO 4217 currency code */
  currency: string
  /** Registered merchant identifier */
  merchantId: string
}

export interface PaymentResult {
  status: 'success' | 'declined' | 'pending'
  reference: string
  timestamp: Date
}
```

### Classes

```typescript
export class PaymentService {
  /**
   * Process a payment transaction
   */
  processTransaction(request: PaymentRequest): Promise<PaymentResult>
  
  /**
   * Refund a previous transaction
   * @param reference - Original transaction reference
   * @param amount - Partial refund amount (optional)
   */
  refundTransaction(reference: string, amount?: number): Promise<RefundResult>
}
```

### Functions

```typescript
/**
 * Validate a payment request before processing
 */
export function validatePayment(request: PaymentRequest): ValidationResult

/**
 * Format amount for display
 */
export function formatCurrency(amount: number, currency: string): string
```

### Type Aliases

```typescript
export type Currency = 'GBP' | 'USD' | 'EUR'
export type PaymentStatus = 'success' | 'declined' | 'pending'
```

### Enums

```typescript
export enum ErrorCode {
  INVALID_AMOUNT = 'INVALID_AMOUNT',
  MERCHANT_NOT_FOUND = 'MERCHANT_NOT_FOUND',
  NETWORK_ERROR = 'NETWORK_ERROR'
}
```

---

## Dependencies

{Extracted from package.json dependencies}

- `axios` ^1.6.0 - HTTP client
- `@company/auth` ^3.0.0 - Authentication (internal)

---

## Notes

- {Any important notes from README}
```

---

## Configuration

### Server Configuration File

Location: `config.json` in server root, or `DEPCONTEXT_CONFIG` environment variable.

```json
{
  "project": {
    "root": ".",
    "package_manager": "auto",
    "node_modules_paths": ["node_modules", "packages/*/node_modules"]
  },
  "cache": {
    "directory": ".cache/dep-context",
    "enabled": true
  },
  "extraction": {
    "include_readme": true,
    "readme_max_words": 500,
    "include_changelog": false,
    "parse_jsdoc": true
  },
  "vector": {
    "enabled": true,
    "db_path": ".cache/chromadb",
    "embedding_provider": "openai",
    "embedding_model": "text-embedding-3-small",
    "generate_summaries": true,
    "summary_model": "gpt-4o-mini"
  },
  "gitlab": {
    "enabled": false,
    "url": "https://gitlab.company.com",
    "token_env": "GITLAB_TOKEN"
  }
}
```

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DEPCONTEXT_CONFIG` | No | Path to config file |
| `DEPCONTEXT_CACHE_DIR` | No | Override cache directory |
| `OPENAI_API_KEY` | For vector search | OpenAI API key for embeddings |
| `GITLAB_TOKEN` | Only for enrichment | GitLab PAT for source fetching |

### Alternative: Local Embeddings with Ollama

For fully offline operation, use Ollama instead of OpenAI:

```json
{
  "vector": {
    "enabled": true,
    "embedding_provider": "ollama",
    "embedding_model": "nomic-embed-text",
    "ollama_url": "http://localhost:11434",
    "generate_summaries": true,
    "summary_model": "llama3.2"
  }
}
```

---

## Implementation Details

### Resolving Package Paths

```typescript
function resolvePackagePath(packageName: string, projectRoot: string): string | null {
  // Handle scoped packages: @company/payments → node_modules/@company/payments
  const segments = packageName.startsWith('@') 
    ? packageName.split('/').slice(0, 2).join('/')
    : packageName.split('/')[0]
  
  const candidates = [
    path.join(projectRoot, 'node_modules', segments),
    // Monorepo support
    ...glob.sync(path.join(projectRoot, 'packages/*/node_modules', segments))
  ]
  
  for (const candidate of candidates) {
    if (fs.existsSync(path.join(candidate, 'package.json'))) {
      return candidate
    }
  }
  
  return null
}
```

### Finding Type Definitions

```typescript
function findTypeDefinitions(packagePath: string): string[] {
  const pkg = readJson(path.join(packagePath, 'package.json'))
  
  const typeFiles: string[] = []
  
  // 1. Check "types" or "typings" field in package.json
  if (pkg.types) typeFiles.push(path.join(packagePath, pkg.types))
  if (pkg.typings) typeFiles.push(path.join(packagePath, pkg.typings))
  
  // 2. Check for index.d.ts
  const indexDts = path.join(packagePath, 'index.d.ts')
  if (fs.existsSync(indexDts)) typeFiles.push(indexDts)
  
  // 3. Check dist/index.d.ts
  const distDts = path.join(packagePath, 'dist', 'index.d.ts')
  if (fs.existsSync(distDts)) typeFiles.push(distDts)
  
  // 4. Glob for all .d.ts files if nothing found
  if (typeFiles.length === 0) {
    typeFiles.push(...glob.sync(path.join(packagePath, '**/*.d.ts')))
  }
  
  return [...new Set(typeFiles)] // dedupe
}
```

### Parsing Type Definitions

Use TypeScript compiler API for accurate parsing:

```typescript
import * as ts from 'typescript'

function extractExports(dtsContent: string): ExportedSymbol[] {
  const sourceFile = ts.createSourceFile(
    'temp.d.ts',
    dtsContent,
    ts.ScriptTarget.Latest,
    true
  )
  
  const exports: ExportedSymbol[] = []
  
  function visit(node: ts.Node) {
    if (ts.isInterfaceDeclaration(node) && isExported(node)) {
      exports.push({
        kind: 'interface',
        name: node.name.text,
        text: node.getText(sourceFile),
        jsdoc: getJSDoc(node)
      })
    }
    
    if (ts.isClassDeclaration(node) && isExported(node)) {
      exports.push({
        kind: 'class',
        name: node.name?.text || 'anonymous',
        text: node.getText(sourceFile),
        jsdoc: getJSDoc(node)
      })
    }
    
    if (ts.isFunctionDeclaration(node) && isExported(node)) {
      exports.push({
        kind: 'function',
        name: node.name?.text || 'anonymous',
        text: getSignature(node),
        jsdoc: getJSDoc(node)
      })
    }
    
    if (ts.isTypeAliasDeclaration(node) && isExported(node)) {
      exports.push({
        kind: 'type',
        name: node.name.text,
        text: node.getText(sourceFile),
        jsdoc: getJSDoc(node)
      })
    }
    
    ts.forEachChild(node, visit)
  }
  
  visit(sourceFile)
  return exports
}
```

### Cache Structure

```
.cache/dep-context/
├── registry.json
└── snapshots/
    ├── @company__payments@2.1.0.md
    ├── lodash@4.17.21.md
    └── axios@1.6.0.md
```

**Registry format:**
```json
{
  "version": "2.0.0",
  "project_root": "/path/to/project",
  "snapshots": {
    "@company/payments": {
      "version": "2.1.0",
      "snapshot_file": "snapshots/@company__payments@2.1.0.md",
      "generated": "2026-01-15T14:32:00Z",
      "has_types": true,
      "has_readme": true,
      "exports_count": 24
    }
  }
}
```

### Cache Invalidation Logic

```typescript
function isCacheValid(packageName: string): boolean {
  const cached = registry.snapshots[packageName]
  if (!cached) return false
  
  const packagePath = resolvePackagePath(packageName)
  if (!packagePath) return false
  
  const pkg = readJson(path.join(packagePath, 'package.json'))
  
  // Simple version comparison - if version changed, invalidate
  return cached.version === pkg.version
}
```

No network calls. No timestamp comparisons with remote servers. Just: "did the version in node_modules change?"

---

## File Structure

```
dep-context-mcp/
├── package.json
├── tsconfig.json
├── config.json
├── README.md
├── src/
│   ├── index.ts              # MCP server entry point
│   ├── tools/
│   │   ├── get-dependency.ts # get_dependency_context
│   │   ├── list.ts           # list_dependencies
│   │   ├── refresh.ts        # refresh_dependency
│   │   ├── search.ts         # search_dependencies (text-based)
│   │   ├── semantic.ts       # search_codebase (vector-based)
│   │   └── enrich.ts         # enrich_from_source (optional)
│   ├── extraction/
│   │   ├── typescript.ts     # .d.ts parsing
│   │   ├── readme.ts         # README extraction
│   │   └── snapshot.ts       # Snapshot generation
│   ├── cache/
│   │   ├── manager.ts        # Cache operations
│   │   └── registry.ts       # Registry management
│   ├── vector/
│   │   ├── index.ts          # ChromaDB integration
│   │   ├── embeddings.ts     # Embedding generation (OpenAI/Ollama)
│   │   └── summaries.ts      # AI summary generation
│   ├── resolver/
│   │   └── package.ts        # node_modules resolution
│   └── config/
│       └── loader.ts         # Configuration
├── .cache/                   # Generated at runtime
│   ├── dep-context/
│   │   ├── registry.json
│   │   └── snapshots/
│   └── chromadb/             # Vector database
└── tests/
    ├── extraction.test.ts
    ├── resolver.test.ts
    ├── cache.test.ts
    └── vector.test.ts
```

---

## MCP Server Registration

### For Kiro

Add to `.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "dep-context": {
      "command": "node",
      "args": ["path/to/mcp-servers/dep-context-mcp/dist/index.js"],
      "env": {}
    }
  }
}
```

Note: No authentication required for core functionality!

### For Cursor

Add to MCP settings:

```json
{
  "dep-context": {
    "command": "node",
    "args": ["path/to/dep-context-mcp/dist/index.js"]
  }
}
```

---

## Usage Examples

### Example 1: AI Encounters Unknown Import

**User prompt:** "Add error handling to the payment flow"

**AI sees:**
```typescript
import { PaymentService } from '@company/payments'
```

**AI calls:**
```json
{
  "tool": "get_dependency_context",
  "arguments": {
    "package_name": "@company/payments"
  }
}
```

**Server does:**
1. Looks in `node_modules/@company/payments`
2. Reads `package.json` → version 2.1.0
3. Checks cache → miss (or version changed)
4. Finds `dist/index.d.ts`
5. Parses type definitions
6. Reads `README.md`
7. Generates snapshot, caches it
8. Returns snapshot

**AI receives:** Full API with `PaymentService` class, methods, error types.

**AI can now:** Generate correct error handling using the actual API.

---

### Example 2: Listing Available Dependencies

**User prompt:** "What payment-related libraries do we have?"

**AI calls:**
```json
{
  "tool": "search_dependencies",
  "arguments": {
    "query": "payment"
  }
}
```

**AI receives:** List of installed packages matching "payment" in name or description.

---

### Example 3: Checking What's Available

**AI calls:**
```json
{
  "tool": "list_dependencies",
  "arguments": {
    "filter": "@company/*"
  }
}
```

**AI receives:** All internal `@company/` scoped packages with their context availability.

---

## Error Handling

| Scenario | Behaviour |
|----------|-----------|
| Package not installed | Return `{ installed: false, error: "Package not found in node_modules. Run npm install." }` |
| No type definitions | Return snapshot with README only, flag `source_type: "readme_only"` |
| No README either | Return minimal snapshot from package.json description |
| Malformed .d.ts | Log warning, skip problematic file, continue with others |
| Cache directory not writable | Disable caching, log warning, continue without cache |

---

## Testing Strategy

### Unit Tests

- Package resolution: scoped packages, monorepos, nested node_modules
- Type extraction: interfaces, classes, functions, generics, JSDoc
- Cache: hit/miss/invalidation scenarios
- Snapshot generation: various package structures

### Integration Tests

- Real packages: lodash, axios, express (well-known structures)
- Internal packages: mock @company/* packages
- Edge cases: packages without types, packages with only README

### Manual Testing Checklist

- [ ] Fresh project, no cache
- [ ] Cache hit (instant response)
- [ ] Cache miss (extraction runs)
- [ ] Version change triggers re-extraction
- [ ] Scoped package (@company/x)
- [ ] Package without .d.ts files
- [ ] Package with complex generics
- [ ] Monorepo with multiple node_modules
- [ ] Package with only README

---

## Security Considerations

1. **No network by default:** Core functionality reads only local filesystem
2. **No secrets required:** No tokens needed for basic operation
3. **Sandboxed to project:** Only reads from project's node_modules
4. **Optional GitLab:** Source enrichment requires explicit opt-in and token

---

## Performance Characteristics

| Operation | Expected Time |
|-----------|---------------|
| Cache hit | <10ms |
| Cache miss (small package) | 50-200ms |
| Cache miss (large package, 50+ .d.ts files) | 500ms-2s |
| List all dependencies | 20-100ms |
| Search dependencies | 10-50ms |

All operations are local filesystem reads. No network latency.

---

## Tool Activation via Steering

The MCP tools are passive - they only work when called. The AI needs guidance on *when* to use them.

### Recommended Steering File

Create `.kiro/steering/dependency-context.md`:

```markdown
# Dependency Context Rules

## Rule 1: Check Before You Build (Don't Reinvent the Wheel)

**BEFORE writing any new functionality**, search for existing solutions:

1. Call `search_codebase` with a natural language description of what you need
2. Review results - there may already be a utility for this
3. If found, call `get_dependency_context` to get the full API

**Why:** Internal libraries exist to solve common problems. Reimplementing 
something that already exists wastes time and creates inconsistency.

**Example:**
- Task: "Add date formatting to the invoice"
- WRONG: Write a new formatDate() function
- RIGHT: `search_codebase("format date for display")` → finds @company/utils.formatDate

## Rule 2: Discover Full API on Import Encounter

When you encounter an `@company/*` import (in existing code or from codebase search):

1. Call `get_dependency_context` for that package
2. Review the FULL API - not just what's used in the example
3. There may be additional utilities relevant to your task

**Why:** Seeing `import { X } from '@company/foo'` only tells you X exists.
The package likely exports Y and Z too, which might be exactly what you need.

**Example:**
- Codebase search finds: `import { PaymentService } from '@company/payments'`
- Call `get_dependency_context('@company/payments')`
- Discover: Also exports `PaymentErrorBoundary`, `usePaymentRetry`, `formatCurrency`
- Use the full toolkit, not just what the example showed

## Rule 3: Verify Before Generating

**NEVER assume** the API of an internal package. Always verify:

1. Call `get_dependency_context` before writing import statements
2. Use the actual method signatures, not guesses
3. Check for error types, options, and edge cases in the API

**Why:** Internal packages aren't in training data. Hallucinated APIs cause
runtime errors and waste debugging time.

## Rule 4: Follow Existing Patterns

When Kiro's codebase search finds an existing pattern:

1. Note which `@company/*` packages it uses
2. Call `get_dependency_context` for each
3. Apply the same pattern - consistency matters
4. Check if the full API offers improvements over the example

## Error Handling

If `get_dependency_context` returns `installed: false`:
1. Tell the user: "Package not installed locally. Run `npm install` first."
2. Do NOT hallucinate the API
3. Wait for installation or ask user for guidance

If a package has no type definitions:
1. Note this limitation to the user
2. Suggest checking the source repository for documentation
3. Use `enrich_from_source` if GitLab access is configured

If `search_codebase` returns no results:
1. Try broader/alternative search terms
2. Check `list_dependencies` to see what's available
3. If nothing exists, proceed with new implementation
```

### Why Steering is Essential

The MCP tools solve: **"How do I get dependency context?"**

Steering solves: **"When should I look, and what should I do with it?"**

| Without Steering | With Steering |
|------------------|---------------|
| AI writes new utility function | AI searches for existing utility first |
| AI sees one import, uses only that | AI gets full API, uses best tool |
| AI guesses internal API signatures | AI verifies before generating |
| AI ignores existing patterns | AI follows established patterns |

### Steering + Semantic Search = Behaviour Change

With `search_codebase` available, the steering becomes actionable:

| Steering Rule | Without Vector Search | With Vector Search |
|---------------|----------------------|-------------------|
| Rule 1: Check before you build | ❌ Impractical at scale | ✅ One tool call |
| Rule 2: Full API on import | ✅ Works | ✅ Works |
| Rule 3: Verify before generating | ✅ Works | ✅ Works |
| Rule 4: Follow existing patterns | ✅ Works | ✅ Works + discovery |

**The key insight:** Steering tells the AI *what to do*. Semantic search makes Rule 1 *actually possible*.

---

## Why Vector Search is Required (Core MVP)

### The Two Core Use Cases

| Use Case | Example Query | What's Needed |
|----------|---------------|---------------|
| **Understand an import** | "What does @company/payments export?" | Lookup by name |
| **Find existing solution** | "Is there a date formatting utility?" | Semantic search |

### Text Snapshots Only Solve Half the Problem

Text-based tools (`get_dependency_context`, `list_dependencies`) handle "understand an import" well:
```
AI sees: import { X } from '@company/payments'
AI calls: get_dependency_context('@company/payments')
AI gets: Full API documentation
✅ Works perfectly
```

But text-based search **fails** at "find existing solution" at scale:
```
AI needs: "something that formats dates"
AI would have to:
  1. list_dependencies → 50 @company/* packages
  2. get_dependency_context for EACH (50 calls)
  3. Read 50 markdown files (~500KB of text)
  4. Hope to spot formatDate() somewhere
❌ Impractical, slow, error-prone
```

### Semantic Search Makes "Don't Reinvent" Possible

With vector embeddings via `search_codebase`:
```
AI needs: "something that formats dates"
AI calls: search_codebase("date formatting")
AI gets: @company/utils.formatDate (relevance: 0.94)
✅ One call, instant, accurate
```

### The Honest Assessment

| Steering Rule | Text-Only Viable? | Needs Vector? |
|---------------|-------------------|---------------|
| Rule 1: Check before you build | ❌ At scale | ✅ Required |
| Rule 2: Full API on import | ✅ Yes | Nice to have |
| Rule 3: Verify before generating | ✅ Yes | Nice to have |
| Rule 4: Follow existing patterns | ✅ Yes | Nice to have |

**Rule 1 - the most valuable rule - doesn't work without vector search.**

This is why `search_codebase` is a core MVP tool, not a future enhancement.

---

## Complementary Architecture: Kiro Codebase Indexing

Kiro has experimental codebase indexing (vector) which handles finding patterns in your project's own code. This MCP tool complements that by providing full API context for dependencies.

| Capability | Kiro Codebase Index | Dependency Context MCP |
|------------|---------------------|------------------------|
| Scope | Your project's source code | node_modules dependencies |
| Use case | "Find similar patterns in our code" | "What does this library export?" |
| Discovery | "How do we handle auth?" | "Is there an auth utility in @company/*?" |

**They work together:**
1. Kiro finds a pattern in your codebase using `@company/auth`
2. MCP provides full API context for `@company/auth`
3. AI applies the pattern correctly with verified API signatures
```

No more manual domain mappings - the vector search handles discovery.

---

## Future Enhancements (Post-MVP)

These are genuinely optional features that can be added after the core MVP is proven:

1. **Python support:** Read from `site-packages`, parse `.pyi` stub files
2. **Go support:** Read from `go.mod` dependencies
3. **Rust support:** Read from `Cargo.toml` dependencies
4. **Dependency graph:** Show which packages depend on which
5. **Watch mode:** Auto-refresh when node_modules changes
6. **Shared cache:** Team-wide cache server for faster onboarding
7. **Index own codebase:** Not just dependencies, but project source too
8. **Cross-project search:** Search across multiple projects' dependencies
9. **Usage analytics:** Track which internal packages are most/least used

---

## Success Metrics

After deployment, measure:

1. **Cache hit rate:** Target >90% (versions don't change often)
2. **Time to context:** <50ms for cache hit, <500ms for typical cache miss
3. **Coverage:** % of dependencies with extractable types
4. **Adoption:** Number of tool calls per session

---

## Appendix A: Comparison with GitLab-Fetch Approach

During design, we considered fetching dependency source from GitLab. Here's why local-first won:

| Aspect | GitLab Fetch | Local node_modules |
|--------|--------------|-------------------|
| Network calls | Many | Zero |
| Auth required | Yes (GitLab token) | No |
| Works offline | No | Yes |
| Setup time | Configure GitLab | Zero config |
| Cache invalidation | Timestamp comparison | Version comparison |
| Source availability | Always (if access) | Only if shipped |
| Speed | Seconds | Milliseconds |

**Local-first is simpler, faster, and requires no setup.** GitLab fetch (`enrich_from_source`) is an optional enhancement for edge cases.

---

## Appendix B: When to Use GitLab Enrichment

The optional `enrich_from_source` tool is useful when:

1. Package doesn't ship `.d.ts` files (rare for TypeScript packages)
2. Package doesn't ship source (common for compiled packages)
3. You need implementation details, not just API signatures
4. JSDoc comments were stripped during build

For most internal packages that ship types, local extraction is sufficient.

---

## Appendix C: Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "Package not found" | Not installed | Run `npm install` |
| Empty snapshot | No .d.ts files | Use `enrich_from_source` or check if package has types |
| Stale context | Version changed | Run `refresh_dependency` or delete cache |
| Slow extraction | Large package | Expected; cache will speed up subsequent calls |
| Missing JSDoc | Stripped in build | Use `enrich_from_source` to get original source |

---

*End of Specification*

---

## Vector Database Architecture

### Why Vector Search is Core to MVP

| Use Case | Example Query | Solution |
|----------|---------------|----------|
| **Understand an import** | "What does @company/payments export?" | `get_dependency_context` (lookup by name) |
| **Find existing solution** | "Is there a date formatting utility?" | `search_codebase` (semantic search) |

The first use case works fine with text snapshots. The second - which prevents the most wasted effort - requires vector search to work at scale.

**Without vector search:**
```
AI needs: "something that formats dates"
AI would have to:
  1. list_dependencies → 50 @company/* packages
  2. get_dependency_context for EACH (50 calls)
  3. Read 50 markdown files (~500KB of text)
  4. Hope to spot formatDate() somewhere
❌ Impractical, slow, error-prone
```

**With vector search:**
```
AI needs: "something that formats dates"
AI calls: search_codebase("date formatting")
AI gets: @company/utils.formatDate (relevance: 0.94)
✅ One call, instant, accurate
```

### What Gets Indexed

For each exported symbol, we store:

```json
{
  "id": "@company/payments::PaymentService.processTransaction",
  "package": "@company/payments",
  "version": "2.1.0",
  "symbol": "PaymentService.processTransaction",
  "type": "method",
  "signature": "processTransaction(request: PaymentRequest): Promise<PaymentResult>",
  "jsdoc": "Process a payment transaction",
  "ai_summary": "Handles payment processing including validation, fraud checks, and gateway communication. Throws PaymentError on failure. Requires merchantId to be pre-registered.",
  "embedding": [0.123, -0.456, ...]
}
```

**Key insight:** The `ai_summary` field is generated by an LLM from the source/types. Natural language descriptions embed better than raw code signatures.

### Tech Stack

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Vector DB | ChromaDB | Local, no external service, JS bindings, easy setup |
| Embeddings | `text-embedding-3-small` (OpenAI) or Ollama | OpenAI is easy, Ollama is free/local |
| Summary generation | Same LLM as Kiro | Consistency, or smaller model for cost |

### ChromaDB Integration

```typescript
import { ChromaClient, Collection } from 'chromadb'

interface SymbolDocument {
  id: string
  package: string
  version: string
  symbol: string
  type: 'function' | 'class' | 'method' | 'interface' | 'type'
  signature: string
  description: string
}

class VectorIndex {
  private client: ChromaClient
  private collection: Collection
  
  async initialize(cacheDir: string) {
    this.client = new ChromaClient({
      path: path.join(cacheDir, 'chromadb')
    })
    
    this.collection = await this.client.getOrCreateCollection({
      name: 'dependency_symbols',
      metadata: { 'hnsw:space': 'cosine' }
    })
  }
  
  async indexPackage(packageName: string, symbols: SymbolDocument[]) {
    // Remove old entries for this package
    await this.collection.delete({
      where: { package: packageName }
    })
    
    // Generate embeddings and summaries
    const documents = await Promise.all(
      symbols.map(async (sym) => ({
        id: sym.id,
        document: `${sym.symbol}: ${sym.description}. ${sym.signature}`,
        metadata: {
          package: sym.package,
          version: sym.version,
          symbol: sym.symbol,
          type: sym.type,
          signature: sym.signature
        }
      }))
    )
    
    await this.collection.add({
      ids: documents.map(d => d.id),
      documents: documents.map(d => d.document),
      metadatas: documents.map(d => d.metadata)
    })
  }
  
  async search(query: string, options: SearchOptions): Promise<SearchResult[]> {
    const results = await this.collection.query({
      queryTexts: [query],
      nResults: options.limit || 5,
      where: options.packageFilter 
        ? { package: { $in: options.packageFilter } }
        : undefined
    })
    
    return results.ids[0].map((id, i) => ({
      id,
      relevance: 1 - (results.distances?.[0][i] || 0),
      ...results.metadatas?.[0][i]
    }))
  }
}
```

### Indexing Workflow

```
npm install completes (or package-lock.json changes)
        │
        ▼
┌─────────────────────────────────────────────────────────────────┐
│ 1. Detect changed packages (compare versions in registry.json) │
│ 2. For each changed package:                                    │
│    a. Extract API from .d.ts files                             │
│    b. Generate AI summaries for each symbol                    │
│    c. Create embeddings                                        │
│    d. Upsert to ChromaDB                                       │
│ 3. Update registry.json with new versions                      │
└─────────────────────────────────────────────────────────────────┘
```

**Trigger options:**
- Kiro hook on `package-lock.json` change (recommended)
- Manual `refresh_index` tool call
- Background watcher on node_modules (optional)

### Embedding Model Configuration

```json
{
  "vector": {
    "enabled": true,
    "embedding_provider": "openai",
    "embedding_model": "text-embedding-3-small",
    "openai_api_key_env": "OPENAI_API_KEY",
    "generate_summaries": true,
    "summary_model": "gpt-4o-mini"
  }
}
```

**Alternative: Local embeddings with Ollama:**
```json
{
  "vector": {
    "enabled": true,
    "embedding_provider": "ollama",
    "embedding_model": "nomic-embed-text",
    "ollama_url": "http://localhost:11434",
    "generate_summaries": true,
    "summary_model": "llama3.2"
  }
}
```

### Index Structure

```
.cache/dep-context/
├── registry.json           # Package versions + metadata
├── snapshots/              # Markdown snapshots (for get_dependency_context)
│   ├── @company__payments@2.1.0.md
│   └── lodash@4.17.21.md
└── chromadb/               # Vector database
    ├── chroma.sqlite3      # Metadata
    └── index/              # HNSW index files
```

### Performance Characteristics

| Operation | Expected Time |
|-----------|---------------|
| Semantic search | 20-50ms |
| Index single package (small) | 1-3s (includes embedding generation) |
| Index single package (large, 100+ symbols) | 5-15s |
| Full reindex (50 packages) | 2-5 minutes (one-time) |

**Note:** Embedding generation is the bottleneck. Consider:
- Batch embedding calls (OpenAI supports up to 2048 inputs per call)
- Incremental indexing (only changed packages)
- Background indexing (don't block tool responses)

---

## Indexing Strategy: Lazy with User Confirmation

### The Problem with Eager Indexing

Indexing 50+ packages on first run = 2-5 minute wait before the tool is usable. That's a terrible first experience.

**Eager indexing fails because:**
- User installs MCP, tries it immediately, waits forever
- Most packages won't be queried in a given session
- Embedding API costs scale with indexed symbols (OpenAI charges per token)
- Full reindex on every `npm install` is wasteful

### The Problem with Silent Blocking

If we silently index on first `search_codebase` call, the user stares at a spinner for 15+ seconds with no explanation. That's also terrible UX.

### Solution: Confirmation Flow for Cold Start

When indexing is required, return a confirmation request instead of blocking:

```
┌─────────────────────────────────────────────────────────────────┐
│                  CONFIRMATION FLOW                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. AI calls search_codebase("retry logic")                     │
│                                                                 │
│  2. MCP detects: 8 packages need indexing (~15s)                │
│                                                                 │
│  3. MCP returns: { status: "confirmation_required", ... }       │
│                                                                 │
│  4. AI asks user: "I need to index 8 packages (one-time,        │
│                    ~15 seconds). Proceed?"                      │
│                                                                 │
│  5. User: "yes"                                                 │
│                                                                 │
│  6. AI calls search_codebase(..., confirm_indexing: true)       │
│                                                                 │
│  7. MCP indexes packages, returns results                       │
│                                                                 │
│  8. AI: "Found @company/utils.withRetry..."                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Updated Tool Schema: `search_codebase`

Add `confirm_indexing` parameter:

```json
{
  "type": "object",
  "properties": {
    "query": {
      "type": "string",
      "description": "Natural language description of what you're looking for"
    },
    "packages": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Filter to specific packages (glob patterns supported)",
      "default": ["*"]
    },
    "confirm_indexing": {
      "type": "boolean",
      "description": "If true, proceed with indexing if required. If false/omitted and indexing needed, returns confirmation_required status.",
      "default": false
    }
  },
  "required": ["query"]
}
```

### Response Types

**Normal response (index exists):**
```json
{
  "status": "success",
  "results": [
    {
      "package": "@company/utils",
      "symbol": "withRetry",
      "relevance": 0.91,
      "signature": "withRetry<T>(fn: () => Promise<T>, options?: RetryOptions): Promise<T>"
    }
  ],
  "search_duration_ms": 45
}
```

**Confirmation required (cold start):**
```json
{
  "status": "confirmation_required",
  "action": "index_packages",
  "reason": "First-time setup: packages need to be indexed before searching",
  "packages_to_index": [
    "@company/payments",
    "@company/utils",
    "@company/auth",
    "@company/logging"
  ],
  "packages_already_indexed": [],
  "estimated_duration_seconds": 15,
  "estimated_symbols": 200,
  "message": "8 internal packages need to be indexed. This is a one-time operation that enables semantic search across your dependencies."
}
```

**Indexing performed (after confirmation):**
```json
{
  "status": "success",
  "results": [...],
  "indexing_performed": true,
  "packages_indexed": ["@company/payments", "@company/utils", ...],
  "indexing_duration_ms": 14320,
  "symbols_indexed": 187,
  "message": "Indexed 8 packages (one-time setup complete)"
}
```

### Steering Update for Confirmation Flow

Update the steering file to handle confirmations:

```markdown
## Handling Indexing Confirmation

When `search_codebase` returns `status: "confirmation_required"`:

1. Explain to the user what's needed:
   - This is a one-time setup for semantic search
   - It takes approximately {estimated_duration_seconds} seconds
   - It indexes {packages_to_index.length} internal packages

2. Ask for confirmation:
   "I need to index your internal packages to search for existing utilities. 
    This takes about 15 seconds and only happens once. Should I proceed?"

3. If user confirms, retry with `confirm_indexing: true`

4. If user declines, proceed without searching (may result in reimplementing 
   existing functionality)
```

### Cold Start Scenario: Fresh Checkout

```
Timeline: git clone → npm install → first AI prompt
──────────────────────────────────────────────────────────────────

1. User: "Add retry logic to the payment flow"

2. AI (guided by steering Rule 1): Check for existing utilities first
   └── Calls: search_codebase("retry logic", packages=["@company/*"])

3. MCP server:
   └── Checks .cache/chromadb → doesn't exist
   └── Finds 8 @company/* packages in node_modules
   └── Estimates: 8 packages × ~2s = ~16 seconds
   └── Returns: { status: "confirmation_required", ... }

4. AI to user:
   "Before I write new code, I'd like to check if there's an existing 
    retry utility in your internal packages. This requires a one-time 
    index setup (~15 seconds). Should I proceed?"

5. User: "yes" (or "sure" / "go ahead" / "ok")

6. AI calls: search_codebase("retry logic", packages=["@company/*"], 
                             confirm_indexing=true)

7. MCP server:
   └── Initialises ChromaDB
   └── Indexes 8 packages (parallel, ~4s with 4 concurrent)
   └── Searches index
   └── Returns results + indexing metadata

8. AI to user:
   "I indexed your internal packages and found @company/utils.withRetry 
    which handles retry logic with exponential backoff. Here's how to 
    use it in your payment flow..."

9. Subsequent searches: <50ms, no confirmation needed
```

### When Confirmation is NOT Required

Skip confirmation and proceed immediately when:

| Scenario | Behaviour |
|----------|-----------|
| All queried packages already indexed | Search immediately |
| Only 1-2 packages need indexing (<3s) | Index silently, include in response |
| `confirm_indexing: true` passed | Index and search |
| `refresh_index` tool called | User explicitly requested, proceed |

**Threshold for silent indexing:**
```typescript
const SILENT_INDEXING_THRESHOLD_SECONDS = 3

if (estimatedDuration <= SILENT_INDEXING_THRESHOLD_SECONDS) {
  // Index silently, don't ask for confirmation
  await indexPackages(packagesToIndex)
  return searchResults
} else {
  // Ask for confirmation
  return { status: 'confirmation_required', ... }
}
```

### Parallel Indexing for Performance

When indexing is confirmed, run in parallel to reduce wait time:

```typescript
async function indexPackagesParallel(
  packages: string[], 
  concurrency: number = 4
): Promise<IndexResult[]> {
  const results: IndexResult[] = []
  const queue = [...packages]
  
  const workers = Array(concurrency).fill(null).map(async () => {
    while (queue.length > 0) {
      const pkg = queue.shift()!
      const result = await indexSinglePackage(pkg)
      results.push(result)
    }
  })
  
  await Promise.all(workers)
  return results
}

// 8 packages × 2s each:
// Sequential: 16 seconds
// Parallel (4): ~4 seconds
```

### Freshness Check: Lockfile Timestamp Comparison

**The cheapest safe approach:** Compare `package-lock.json` mtime with the last index sync time. One `stat()` call.

**Why this works:**
- `npm install` *always* updates `package-lock.json`
- The lockfile contains exact versions of every installed package
- If lockfile hasn't changed, nothing has changed. Period.
- No need to scan `node_modules` - the lockfile *is* the manifest

**The flow:**

```
search_codebase(query, packages=["@company/*"])
        │
        ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: Compare timestamps (1 stat call, <1ms)                  │
│                                                                 │
│   package-lock.json mtime: 2026-01-18T10:30:00                  │
│   registry.lockfile_mtime: 2026-01-15T14:00:00                  │
│                                                                 │
│   Lockfile is NEWER → dependencies may have changed            │
└─────────────────────────────────────────────────────────────────┘
        │
        ├── SAME → Fast path: trust index, search immediately
        │
        └── DIFFERENT → Ask user for confirmation to rebuild
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: Return confirmation_required                            │
│                                                                 │
│ "Your dependencies have changed since the index was built.      │
│  The search index needs rebuilding to ensure accurate results.  │
│  This takes approximately 15 seconds. Proceed?"                 │
└─────────────────────────────────────────────────────────────────┘
        │
        ▼ (user confirms)
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: Parse lockfile, diff with registry, rebuild             │
│                                                                 │
│ - Parse package-lock.json (one JSON file)                       │
│ - Compare versions with registry                                │
│ - Identify: new, updated, removed packages                      │
│ - Reindex changed packages                                      │
│ - Update registry.lockfile_mtime                                │
└─────────────────────────────────────────────────────────────────┘
```

**Implementation:**

```typescript
interface SyncStatus {
  inSync: boolean
  lockfileMtime: number
  registryMtime: number
}

async function checkSyncStatus(projectRoot: string): Promise<SyncStatus> {
  const lockfilePath = path.join(projectRoot, 'package-lock.json')
  const lockfileMtime = (await fs.stat(lockfilePath)).mtimeMs
  const registryMtime = registry.lockfile_mtime || 0
  
  return {
    inSync: lockfileMtime === registryMtime,
    lockfileMtime,
    registryMtime
  }
}

async function searchCodebase(
  query: string,
  packages: string[],
  confirmIndexing: boolean
): Promise<SearchResponse> {
  
  const syncStatus = await checkSyncStatus(projectRoot)
  
  // Fast path: lockfile unchanged, trust the index
  if (syncStatus.inSync) {
    return {
      status: 'success',
      results: await vectorSearch(query, packages),
      index_status: 'current'
    }
  }
  
  // Lockfile changed - need to rebuild
  if (!confirmIndexing) {
    // Ask for confirmation
    return {
      status: 'confirmation_required',
      action: 'rebuild_index',
      reason: 'Dependencies have changed since the index was built',
      message: 'Your package-lock.json has been modified (npm install ran). The search index needs rebuilding to ensure accurate results.',
      lockfile_changed: new Date(syncStatus.lockfileMtime).toISOString(),
      index_built: syncStatus.registryMtime 
        ? new Date(syncStatus.registryMtime).toISOString() 
        : 'never',
      estimated_duration_seconds: await estimateRebuildTime(packages)
    }
  }
  
  // User confirmed - do the rebuild
  const changes = await diffLockfileWithRegistry(packages)
  await rebuildIndex(changes)
  
  // Update sync marker
  registry.lockfile_mtime = syncStatus.lockfileMtime
  await saveRegistry()
  
  // Now search
  return {
    status: 'success',
    results: await vectorSearch(query, packages),
    index_status: 'rebuilt',
    packages_added: changes.added.map(p => p.name),
    packages_updated: changes.updated.map(p => `${p.name}: ${p.oldVersion} → ${p.newVersion}`),
    packages_removed: changes.removed.map(p => p.name),
    rebuild_duration_ms: changes.durationMs
  }
}
```

**Parsing the lockfile (no filesystem scanning):**

```typescript
interface PackageChange {
  name: string
  oldVersion?: string
  newVersion?: string
}

interface LockfileDiff {
  added: PackageChange[]
  updated: PackageChange[]
  removed: PackageChange[]
  unchanged: string[]
}

async function diffLockfileWithRegistry(
  packageFilter: string[]
): Promise<LockfileDiff> {
  // Parse lockfile - this is the source of truth
  const lockfile = JSON.parse(
    await fs.readFile('package-lock.json', 'utf-8')
  )
  
  // npm v2+ lockfile format: packages["node_modules/@company/utils"]
  const installedPackages = new Map<string, string>()
  
  for (const [path, info] of Object.entries(lockfile.packages || {})) {
    if (!path.startsWith('node_modules/')) continue
    const name = path.replace('node_modules/', '')
    
    // Apply filter (e.g., "@company/*")
    if (matchesFilter(name, packageFilter)) {
      installedPackages.set(name, (info as any).version)
    }
  }
  
  // Compare with registry
  const diff: LockfileDiff = { added: [], updated: [], removed: [], unchanged: [] }
  
  // Check installed packages
  for (const [name, version] of installedPackages) {
    const indexed = registry.snapshots[name]
    
    if (!indexed || !indexed.indexed) {
      diff.added.push({ name, newVersion: version })
    } else if (indexed.version !== version) {
      diff.updated.push({ name, oldVersion: indexed.version, newVersion: version })
    } else {
      diff.unchanged.push(name)
    }
  }
  
  // Check for removed packages
  for (const [name, snapshot] of Object.entries(registry.snapshots)) {
    if (snapshot.indexed && matchesFilter(name, packageFilter)) {
      if (!installedPackages.has(name)) {
        diff.removed.push({ name, oldVersion: snapshot.version })
      }
    }
  }
  
  return diff
}
```

**Response types:**

**Fast path (index current):**
```json
{
  "status": "success",
  "results": [...],
  "index_status": "current"
}
```

**Confirmation required (lockfile changed):**
```json
{
  "status": "confirmation_required",
  "action": "rebuild_index",
  "reason": "Dependencies have changed since the index was built",
  "message": "Your package-lock.json has been modified. The search index needs rebuilding to ensure accurate results.",
  "lockfile_changed": "2026-01-18T10:30:00.000Z",
  "index_built": "2026-01-15T14:00:00.000Z",
  "estimated_duration_seconds": 12
}
```

**After rebuild:**
```json
{
  "status": "success",
  "results": [...],
  "index_status": "rebuilt",
  "packages_added": ["@company/newlib"],
  "packages_updated": ["@company/utils: 2.0.0 → 2.1.0"],
  "packages_removed": ["@company/legacy"],
  "rebuild_duration_ms": 11420
}
```

**Steering guidance for handling stale index:**

```markdown
## Handling Index Rebuild Confirmation

When `search_codebase` returns `status: "confirmation_required"` with `action: "rebuild_index"`:

1. Explain to the user:
   - Their dependencies have changed (npm install ran)
   - The search index needs updating to give accurate results
   - This is a one-time rebuild, not every search

2. Ask for confirmation:
   "Your dependencies have changed since I last indexed them. I need to 
    rebuild the search index to ensure I find the right utilities (~12 seconds). 
    Should I proceed?"

3. If user confirms, retry with `confirm_indexing: true`

4. If user declines:
   - Warn that search results may be inaccurate or incomplete
   - Proceed with search using stale index (better than nothing)
   - Suggest rebuilding later with `refresh_index`
```

**Performance summary:**

| Operation | Cost |
|-----------|------|
| Check if rebuild needed | 1 `stat()` call, <1ms |
| Parse lockfile | 1 file read, ~5-20ms for large lockfile |
| Full rebuild (50 packages) | ~15-30s (parallel indexing) |
| Incremental rebuild (5 changed) | ~3-8s |

**Edge cases:**

| Scenario | Handling |
|----------|----------|
| `yarn.lock` instead of `package-lock.json` | Check for yarn.lock, pnpm-lock.yaml |
| Monorepo with multiple lockfiles | Check all lockfiles, rebuild if any changed |
| Fresh checkout (no registry) | Treat as full rebuild needed |
| Manual node_modules edit (rare) | User's problem - they can run `refresh_index` |

### Cost Optimisation (OpenAI Embeddings)

If using OpenAI for embeddings, costs can add up:

| Scenario | Symbols | Tokens (est.) | Cost (text-embedding-3-small) |
|----------|---------|---------------|-------------------------------|
| Initial index (50 packages) | ~2,500 | ~125,000 | ~$0.003 |
| Reindex single package | ~50 | ~2,500 | ~$0.00006 |
| Daily reindex (5 changed) | ~250 | ~12,500 | ~$0.0003 |

**Cost is negligible**, but for fully offline operation, use Ollama with `nomic-embed-text`.

### Indexing State in Registry

Track indexing state in `registry.json`:

```json
{
  "version": "2.0.0",
  "project_root": "/path/to/project",
  "lockfile_mtime": 1737196200000,
  "snapshots": {
    "@company/payments": {
      "version": "2.1.0",
      "snapshot_file": "snapshots/@company__payments@2.1.0.md",
      "generated": "2026-01-15T14:32:00Z",
      "has_types": true,
      "has_readme": true,
      "exports_count": 24,
      "indexed": true,
      "indexed_at": "2026-01-15T14:32:05Z",
      "symbols_indexed": 24
    },
    "lodash": {
      "version": "4.17.21",
      "snapshot_file": "snapshots/lodash@4.17.21.md",
      "generated": "2026-01-15T14:30:00Z",
      "has_types": true,
      "has_readme": true,
      "exports_count": 312,
      "indexed": false
    }
  },
  "index_stats": {
    "total_packages_indexed": 12,
    "total_symbols": 847,
    "last_rebuild": "2026-01-15T14:32:05Z"
  }
}
```

**Key field:** `lockfile_mtime` - the mtime of `package-lock.json` when the index was last synced. If current lockfile mtime differs, a rebuild is needed.
```

### Summary: Indexing Philosophy

| Principle | Implementation |
|-----------|----------------|
| **Cheapest safe check** | Compare lockfile mtime vs registry mtime (1 stat call) |
| **Never fly blind** | If lockfile changed, ask to rebuild before searching |
| **Conversational** | Always ask user before long operations |
| **Parse lockfile, not node_modules** | Lockfile is the manifest - no filesystem scanning |
| **Incremental rebuild** | Only reindex changed packages, not everything |
| **User control available** | `refresh_index` tool for manual rebuild |
| **Graceful degradation** | If user declines rebuild, search with stale index + warning |

---
