# AI SDLC Research Notes

## Tools Supporting ATDD / AI-Assisted Acceptance Testing

### 1. Requirements → Gherkin/BDD Generation

- **Gherkinizer** (gherkinizer.com) - AI-powered tool that takes user stories and generates Gherkin BDD tests. Uses Gemini to understand stories and output Cucumber-compatible tests.
- **Workik Cucumber Generator** (workik.com) - Free AI tool that creates Given-When-Then scenarios from user stories
- **Codespell.ai** - Enterprise-focused AI for generating feature files from requirements

### 2. Acceptance Criteria Validation

- **StoriesOnBoard** (storiesonboard.com) - Has AI acceptance criteria writing features
- **Clipmove Acceptance Criteria Builder** (clipmove.com) - Helps define clear, testable AC
- **V2Solutions** - AI-based requirements validation using NLP to check quality and consistency of requirements

### 3. AI-Assisted ATDD Workflows

- **testRigor** - Marketed as "90% test automation with AI" for ATDD. Lets you write tests in plain English, AI handles execution
- **Robot Framework** - Classic ATDD tool (Python-based), now with AI integrations

### 4. End-to-End from Requirements

- **Paul Duvall's ATDD-driven AI Development** (paulmduvall.com) - Built an app (DoubleUp!) specifically to test ATDD with AI. Finding: "Acceptance tests can steer AI to generate reliable code"

---

## Key Insight

The tooling exists in pieces:
- AI to validate AC is testable ✓
- AI to generate Gherkin from stories ✓
- AI to execute plain-English tests ✓

**What's missing**: The integrated pipeline where these pieces flow together automatically:

```
BA writes AC → AI validates → QA generates AT (AI-assisted) → DEV implements → AT gates deployment
```

The tools exist. The orchestration doesn't - yet.

**Article angle**: "The building blocks are here. What's missing is the vision to connect them."

---

## Related Research Links

- ATDD 90% automation: https://journal.optivem.com/p/atdd-90-test-automation-with-ai
- Paul Duvall ATDD+AI: https://www.paulmduvall.com/atdd-driven-ai-development-how-prompting-and-tests-steer-the-code/
- AI requirements validation: https://www.v2solutions.com/whitepapers/ai-requirements-validation-quality-consistency-guide/
- Enterprise BDD with AI: https://www.codespell.ai/blog/ai-generated-feature-files-enterprise-bdd
