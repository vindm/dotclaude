# test-architect — designing a test-coverage agent for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a test-architect agent that fits THIS project's stack, risk model, and existing test infrastructure.

## When to ship one (applicability gate)

Ship a test-architect agent when:

- The project has **non-trivial business logic** in pure functions, state machines, or business workflows.
- The user wants to maintain or grow test coverage as a discipline (not just "add a test if I remember").
- The project has had at least one regression that proper test coverage would have caught.

Skip when:

- The project is exploratory / spike code where tests would constrain iteration.
- The dominant value is in code where unit tests are categorically wrong (raw UI rendering — defer to E2E).
- The user explicitly prefers integration / E2E coverage only and isn't authoring unit tests.

## Why it matters — what this catches that nothing else does

The agent solves a specific gap: **the project's test coverage is partial, and the user doesn't have time to systematically audit which untested code is highest-risk.**

Linters / type-checkers / code-reviewers catch what's wrong in the code that exists. The test-architect catches what's missing — the code that has no test at all, the code where the test exists but only covers the happy path, the test that's stale (referencing renamed functions).

Five concrete failure modes the agent prevents:

1. **High-risk untested code.** A pure function that takes user input, computes something important, and lacks any test. Cheapest possible test, highest possible ROI — and routinely the gap in real codebases.
2. **Behavior coupled to implementation.** Tests that verify "the function called `_internal()` with `args`" instead of "given input X, the output is Y." Behavior-coupled tests break on refactor; implementation-coupled tests provide little real safety.
3. **Stale tests.** Tests that import functions that have been renamed or deleted, or tests that pass against fossilized assumptions about the current API.
4. **Untested boundaries.** Tests cover the function's middle but ignore edge cases (null input, empty collection, boundary values, error path).
5. **Wrong-shaped tests.** Unit tests for pure rendering (better as E2E); integration tests for pure helpers (better as unit); E2E for trivial branches (better as unit). The agent classifies by testability tier and recommends the right shape.

## Core methodology — four operating modes

The agent operates in distinct modes. The user's request determines which.

### Mode 1 — Audit

Triggered by: "audit test coverage", "what's untested", "coverage gaps."

Process:
1. Glob for all source files in the project's source directories.
2. Glob for existing test files.
3. Build a module-by-module inventory: source files vs corresponding test files.
4. Flag highest-risk untested code first (see Risk-Weighted Priority below).
5. Classify each untested file by testability tier (see Tiers below).
6. Prioritize by risk + tier.
7. Output a structured coverage report.

Report shape: a coverage map table, top priorities (what to test first and why), any stale tests detected.

### Mode 2 — Design

Triggered by: "design tests for <module>", "test plan for <module>."

Process:
1. Read every source file in the target module.
2. Identify exported functions / hooks / stores / types.
3. For each export, determine:
   - Input types and edge cases (null, empty, boundary, error path)
   - Dependencies needing mocks (DB clients, auth, HTTP, navigation)
   - State transitions (for stores / hooks)
4. Decide which test utilities to use (see Infrastructure below).
5. Design the test file structure: describe blocks, test cases, fixtures.

Report shape: functions-to-test table, test-file layout per module, mock strategy.

### Mode 3 — Implement

Triggered by: "write tests for <module>", "implement the test plan."

Process:
1. If no design exists, run Design first.
2. Create test files following project conventions.
3. Create any needed fixture helpers or mock factories — add to a centralized location (e.g., `test-utils/mocks.ts`), not inline in test files.
4. Run each test file standalone.
5. Fix failures.
6. Update coverage manifest if the project maintains one.

**Critical**: always run the tests after writing them. Untested tests are a contradiction in terms — they're just text.

### Mode 4 — Maintain

Triggered by: "check test health", "are tests stale."

Process:
1. For each existing test file, verify:
   - All imported source files still exist
   - All imported functions / types still match current signatures
   - Mock factories still match current type shapes
2. Run the full test suite — flag any failures.
3. Check for snapshot drift.
4. Report stale tests with fix suggestions.

## The five-tier testability classification

Classify code by what testing approach actually adds value:

| Tier | What | Approach |
|---|---|---|
| **A** | Pure functions (utils, transforms, algorithms) | Direct import, `baseInput()` factory, exhaustive edge cases. Highest ROI per test. |
| **B** | State stores (Zustand, Redux, signals) | Create store, dispatch actions, assert state transitions. |
| **C** | Hooks / composables with business logic | `renderHook`-style harness + mocked deps + assertions on return values. |
| **D** | Thin query / fetch wrappers | LOW priority — test the underlying function instead; the wrapper is implementation detail. |
| **E** | UI rendering components | SKIP unit-testing rendering — E2E covers it. Unit-test logic extracted out, not JSX. |

This tier system is universal in shape. The specific code patterns that land in each tier are stack-specific. Encode the project's actual patterns in the agent file.

## Risk-weighted priority

When multiple modules need tests, prioritize by risk. The agent should know the project's actual high-risk categories. Examples:

| Priority | Category | Why |
|---|---|---|
| 1 | Auth / identity / permissions | Affects all users; broken auth breaks the product. |
| 2 | Data-pipeline / ingestion logic | Garbage in, garbage out — corruption at ingestion contaminates everything downstream. |
| 3 | Money / billing / pricing | Customer trust + financial liability. |
| 4 | Persistence write paths | Data loss is unrecoverable. |
| 5 | Public API contracts | External consumers break if these change without notice. |
| 6 | Domain algorithms / business logic | The core competency of the product. |
| 7 | Utility functions | General reliability. |

THIS project's priorities derive from THIS project's risk model. A B2B SaaS prioritizes auth + billing; a game engine prioritizes performance-critical paths; a developer tool prioritizes CLI command parsing.

## Test infrastructure inventory

Before writing any tests, the agent inventories what's already available so it doesn't duplicate or fight existing patterns. Categories to enumerate:

- **Test runner**: Jest, Vitest, pytest, cargo test, go test, etc. The agent uses the project's runner; it doesn't introduce a new one.
- **Test utilities**: helper modules at `test-utils/` or `tests/helpers/` or similar. The agent uses these, doesn't reinvent.
- **Mock factories**: pre-built fixture builders (e.g., `createMockUser()`). The agent extends these; doesn't sprinkle inline mocks.
- **Test wrappers**: `QueryClientProvider` wrappers, `<Provider>` wrappers, app-context wrappers. The agent uses the canonical wrapper.
- **Snapshot directories**: where existing snapshots live; how naming works.
- **Coverage manifest**: if the project tracks coverage explicitly (separate from tool output), where it lives.

If the project lacks any of these, the agent may PROPOSE creating one — but only after audit reveals the gap. Don't pre-emptively introduce infrastructure.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The test runner + configuration.** `package.json` scripts, `jest.config.*`, `pyproject.toml` [tool.pytest], `Cargo.toml` [dev-dependencies]. The agent must know how to run a single test file.

2. **Existing patterns.** Read 3-5 representative test files. The agent should mirror the project's idioms (describe / it shape, fixture conventions, mock placement).

3. **Risk categories.** Ask the user: *"If a test gap caused a production incident, what would the incident category be?"* Their answer is the Risk-Weighted Priority table.

4. **Tier mapping.** Look at the project's directory structure. Where are pure helpers? Stores? Hooks? Components? The agent's tier classification rules should reference the project's actual paths.

5. **Coverage gaps the user already knows about.** Ask: *"What part of the code do you avoid changing because you don't trust the test coverage?"* That's the top of the audit list.

6. **Coverage manifest convention.** Does the user want a `test-manifest.json` (or similar) tracking which modules have which tier of coverage? If yes, encode the path; if no, omit that step.

## Authoring the agent

The final agent (typically `.claude/agents/tests-architect.md`) should encode:

1. **The four modes (Audit / Design / Implement / Maintain)** — triggers, process, report format for each.
2. **The five testability tiers** — with the project's actual file path patterns landing in each.
3. **The risk-weighted priority table** — populated with this project's categories.
4. **The test infrastructure inventory** — names of the actual utilities, fixture factories, wrappers the project has.
5. **Gold-standard reference tests** — paths to 1-3 well-written existing tests the agent should model. New tests should look like these; the references are the project's calibration.
6. **The "test behavior, not implementation" injunction** — the agent's prime directive.
7. **The "always run after writing" rule** — every implementation must end with a successful run.

## Cross-references

- `code-review.md` — finds untested changes; refers test-architect for the design work.
- `pre-flight.md` — should ask "what tests will verify this change?" before code is written; test-architect operationalizes the answer.
- `data-integrity.md` — for projects with DB write paths, integrity tests overlap; test-architect handles the unit / integration layer while data-integrity audits the persistent-state layer.
- `../examples/the-test-passed-for-the-wrong-reason.md` — paradigm for "test against the wrong code path." Test-architect's job is to ensure tests exercise the real entry points, not just the convenient ones.

## Anti-patterns in the agent you write

- **Test boilerplate generation without testability classification.** An agent that writes 50 tests for tier-D thin query wrappers is producing noise. The agent's value is in WHAT to test, not in churning out test files.

- **Tests that mirror the implementation.** "It called `_internal('x', 'y')` with these args" is implementation-coupled and breaks on refactor. The agent should refuse to write tests that assert on internals; it asserts on behavior.

- **Unit tests for UI rendering.** Snapshot tests are usually low-value; rendering tests usually break on theme changes; E2E is the right tool. The agent's tier E says "skip" for a reason.

- **Inline mocks scattered across test files.** Centralize in `test-utils/mocks.ts` or equivalent. Inline mocks drift; centralized factories stay correct as type shapes evolve.

- **Writing tests without running them.** Untested tests are not tests. The agent's Implement mode must end with a successful run, or the work isn't complete.

- **Audit reports that don't prioritize.** "Here are 50 untested files" is useless. "Here are the top 5 untested files weighted by risk, in this order" is actionable.

- **Designing tests against fictional infrastructure.** If the project uses Vitest, don't write Jest-style imports. If the project lacks a `renderHook` harness, design tests that work without one (or propose adding the harness as a separate step).

- **Tests that test the test framework.** If a test asserts `expect(true).toBe(true)` or wraps trivial assertions in describe blocks for show, the agent has filled out the file without testing anything. The Audit mode should flag these as "no real coverage."

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash` (to run tests), `Write` (to create test files), `Edit` (to update existing tests and the manifest). It is one of the few agents that legitimately needs write access — testing IS creating code.

Effort: medium. Model: the project's mid-tier reasoning model is usually sufficient — test writing is methodical work that doesn't require the most capable model. Save the top-tier model for code review and pre-flight where deep reasoning pays off most.
