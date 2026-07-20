# test-architect — designing a test-coverage agent for ANY project

Teaching material for Claude Code. Teaches you how to author a test-architect agent that fits THIS project's stack, risk model, and existing test infrastructure.

## When to ship one

Ship a test-architect agent when the project has non-trivial business logic in pure functions, state machines, or workflows; when the user wants to maintain or grow coverage as a discipline (not "add a test if I remember"); or when a regression has happened that proper coverage would have caught. Skip for exploratory / spike code where tests constrain iteration, for code where unit tests are categorically wrong (raw UI rendering — defer to E2E), or when the user authors integration / E2E coverage only.

## Why it matters

Linters, type-checkers, and code-review catch what's wrong in the code that exists; the test-architect catches what's *missing* — untested code, tests that only cover the happy path, and stale tests referencing renamed functions. It solves a specific gap: coverage is partial, and the user doesn't have time to systematically audit which untested code is highest-risk. Five failure modes it prevents:

1. **High-risk untested code** — a pure function taking user input and computing something important, with no test. Cheapest test, highest ROI, routine gap.
2. **Behavior coupled to implementation** — tests asserting "called `_internal()` with `args`" instead of "input X → output Y." Break on refactor, provide little safety.
3. **Stale tests** — importing renamed / deleted functions, or passing against fossilized API assumptions.
4. **Untested boundaries** — the middle is covered, the edges (null, empty, boundary, error path) aren't.
5. **Wrong-shaped tests** — unit tests for pure rendering (want E2E), integration tests for pure helpers (want unit), E2E for trivial branches (want unit). The agent classifies by testability tier and recommends the right shape.

## Core methodology — four operating modes

The user's request selects the mode.

**Mode 1 — Audit** (*"audit coverage," "what's untested," "coverage gaps"*). Glob source files and test files; build a module-by-module inventory of source vs corresponding test; flag highest-risk untested code first (see Risk-Weighted Priority); classify each untested file by tier; prioritize by risk + tier; output a coverage report (coverage map, top priorities with why, any stale tests detected).

**Mode 2 — Design** (*"design tests for <module>," "test plan for <module>"*). Read every source file in the module; identify exported functions / hooks / stores / types; for each, determine input types and edge cases (null, empty, boundary, error path), dependencies needing mocks (DB, auth, HTTP, navigation), and state transitions; decide which test utilities to use; design the file structure (describe blocks, cases, fixtures). Report: functions-to-test table, per-module layout, mock strategy.

**Mode 3 — Implement** (*"write tests for <module>," "implement the test plan"*). Run Design first if none exists; create test files following project conventions; put fixture helpers / mock factories in a centralized location (e.g. `test-utils/mocks.ts`), not inline; run each test file standalone; fix failures; update the coverage manifest if the project keeps one. **Always run the tests after writing them — untested tests are just text.**

**Mode 4 — Maintain** (*"check test health," "are tests stale"*). For each test file, verify imported source files still exist, imported functions / types still match current signatures, and mock factories still match current shapes; run the full suite and flag failures; check snapshot drift; report stale tests with fix suggestions.

## The five-tier testability classification

Classify code by what testing approach actually adds value. The shape is universal; the specific patterns landing in each tier are stack-specific — encode the project's.

| Tier | What | Approach |
|---|---|---|
| **A** | Pure functions (utils, transforms, algorithms) | Direct import, `baseInput()` factory, exhaustive edge cases. Highest ROI per test. |
| **B** | State stores (Zustand, Redux, signals) | Create store, dispatch actions, assert state transitions. |
| **C** | Hooks / composables with business logic | `renderHook`-style harness + mocked deps + assertions on return values. |
| **D** | Thin query / fetch wrappers | LOW priority — test the underlying function; the wrapper is implementation detail. |
| **E** | UI rendering components | SKIP unit-testing rendering — E2E covers it. Unit-test logic extracted out, not JSX. |

## Risk-weighted priority

When multiple modules need tests, prioritize by risk. The agent should know the project's actual high-risk categories:

| Priority | Category | Why |
|---|---|---|
| 1 | Auth / identity / permissions | Affects all users; broken auth breaks the product. |
| 2 | Data-pipeline / ingestion | Corruption at ingestion contaminates everything downstream. |
| 3 | Money / billing / pricing | Customer trust + financial liability. |
| 4 | Persistence write paths | Data loss is unrecoverable. |
| 5 | Public API contracts | External consumers break on silent change. |
| 6 | Domain algorithms / business logic | The core competency of the product. |
| 7 | Utility functions | General reliability. |

THIS project's priorities derive from ITS risk model — a B2B SaaS prioritizes auth + billing; a game engine, performance-critical paths; a dev tool, CLI parsing.

## Test infrastructure inventory

Before writing tests, inventory what exists so the agent doesn't duplicate or fight it: the **test runner** (Jest / Vitest / pytest / cargo test — use the project's, don't introduce a new one), **test utilities** (`test-utils/`, `tests/helpers/`), **mock factories** (`createMockUser()` — extend, don't sprinkle inline), **test wrappers** (`QueryClientProvider`, `<Provider>`, app-context — use the canonical one), **snapshot directories**, and a **coverage manifest** if one is tracked separately from tool output. If the project lacks one, the agent may PROPOSE creating it — but only after audit reveals the gap, never pre-emptively.

## How to derive THIS project's specifics

1. **The test runner + config** — `package.json` scripts, `jest.config.*`, `pyproject.toml` `[tool.pytest]`, `Cargo.toml`. The agent must know how to run a single test file.
2. **Existing patterns** — read 3-5 representative test files; mirror the project's idioms (describe/it shape, fixture conventions, mock placement).
3. **Risk categories** — ask: *"If a test gap caused a production incident, what category would it be?"* That's the priority table.
4. **Tier mapping** — from the directory structure, where the pure helpers / stores / hooks / components live; the tier rules reference the project's actual paths.
5. **Known-untrusted code** — *"What part do you avoid changing because you don't trust the coverage?"* Top of the audit list.
6. **Coverage-manifest convention** — does the user want a `test-manifest.json` tracking tier-of-coverage per module? Encode the path, or omit the step.

## Authoring the agent

The final agent (typically `.claude/agents/tests-architect.md`) encodes the four sections above — the four modes, the five tiers with the project's file-path patterns, the risk table with the project's categories, the infrastructure inventory with real utility names — plus three things not yet stated:

- **Gold-standard reference tests** — paths to 1-3 well-written existing tests the agent models new tests on. These are the project's calibration.
- **"Test behavior, not implementation"** — the prime directive. The agent refuses to assert on internals; it asserts on input → output.
- **"Always run after writing"** — every Implement run ends with a successful test run, or the work isn't complete.

## Acceptance — mistakes in the agent you write

- **Boilerplate without testability classification** — 50 tests for tier-D thin wrappers is noise. The value is in WHAT to test, not churning out files.
- **Tests that mirror the implementation** — assert on behavior, not on which internal was called with which args.
- **Unit tests for UI rendering** — snapshot tests are low-value, rendering tests break on theme changes; tier E says skip for a reason.
- **Inline mocks scattered across files** — centralize in `test-utils/mocks.ts`; inline mocks drift as type shapes evolve.
- **Audit reports that don't prioritize** — "here are 50 untested files" is useless; "top 5 by risk, in this order" is actionable.
- **Designing against fictional infrastructure** — Vitest project, don't write Jest imports; no `renderHook` harness, design without one (or propose adding it as a separate step).
- **Tests that test the framework** — `expect(true).toBe(true)` or describe blocks wrapping trivial assertions. Audit mode flags these as "no real coverage."

## Tool surface

`Read`, `Grep`, `Glob`, `Bash` (to run tests), `Write` (create test files), `Edit` (update tests and the manifest). One of the few agents that legitimately needs write access — testing IS creating code. Effort: medium. Model: the project's mid-tier reasoning model is usually enough — test writing is methodical; save the top-tier model for code-review and pre-flight where deep reasoning pays off most.

## Cross-references

- `code-review.md` — finds untested changes and refers here for the design work.
- `pre-flight.md` — asks "what tests will verify this change?" before code is written; test-architect operationalizes the answer.
