---
description: Set up test architecture + coverage discipline for a project. Authors a tests-architect agent (4 modes — audit / design / implement / maintain) tuned to the project's stack, test framework, risk model, and existing patterns. Plus a small "test discipline" rule when helpful. Invoke /dotclaude:testing in any project where tests exist OR should exist.
---

# `/dotclaude:testing` — test architecture + coverage kit

You are setting up test-coverage discipline. The output is a `.claude/` subset focused on what to test, in what order, with what shape — calibrated to the project's stack, framework, and risk model.

The tests-architect agent is the showpiece. It operates in four modes (audit / design / implement / maintain) and produces risk-weighted coverage decisions, not test-file boilerplate.

## Phase 1 — Read the project's test shape

Before any question:

1. **Test framework** — read whichever exists:
   ```bash
   # JS / TS
   cat package.json 2>/dev/null | grep -A 2 '"scripts"' | grep -E "test|jest|vitest"
   ls jest.config.* vitest.config.* 2>/dev/null
   # Python
   cat pyproject.toml 2>/dev/null | grep -A 5 "\[tool.pytest"
   ls pytest.ini conftest.py 2>/dev/null
   # Rust
   grep -A 3 "\[dev-dependencies\]" Cargo.toml 2>/dev/null
   # Go
   ls *_test.go 2>/dev/null | head
   # Other
   ls .mocharc.* karma.conf.* phpunit.xml 2>/dev/null
   ```

2. **Test file inventory** — find what's already tested:
   ```bash
   find . -path ./node_modules -prune -o \
     \( -name "*.test.*" -o -name "*_test.*" -o -name "test_*.*" \
        -o -path "*/__tests__/*" -o -path "*/tests/*" -o -path "*/spec/*" \) \
     -print 2>/dev/null | head -50
   ```
   Count them. Note the directory convention (colocated `*.test.ts`? `__tests__/` siblings? top-level `tests/` directory?).

3. **Test infrastructure** — look for shared helpers:
   ```bash
   find . -path "*test-utils*" -o -path "*test-helpers*" -o -path "*fixtures*" \
     -o -path "*mocks*" -o -name "conftest.py" 2>/dev/null | head -20
   ```
   The presence (or absence) of these signals discipline maturity. A project with `test-utils/mocks.ts` has invested in shared infrastructure; the agent should USE it, not invent parallel patterns.

4. **Coverage gap analysis** — source vs tests:
   ```bash
   # JS / TS — module-by-module pairing
   find . -name "*.ts" -not -name "*.test.ts" -not -name "*.d.ts" \
     -not -path "*/node_modules/*" 2>/dev/null | wc -l
   find . -name "*.test.ts" -not -path "*/node_modules/*" 2>/dev/null | wc -l
   # Look at most-edited source files vs whether tests exist for them
   git log --format=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn | head -20
   ```
   The ratio (source files to test files) + the most-edited untested files give the audit's headline finding.

5. **Representative test files** — read 3-5 of them:
   - Pick from different modules
   - Note: describe / it shape, fixture conventions, mock placement, what testability tier the existing tests target

6. **Existing CI / coverage gates** — `.github/workflows/`, `circle.yml`, etc., for test scripts; look for coverage thresholds.

Build mental model of: what framework + idioms, what's currently tested vs untested, what shared infrastructure exists, what risk categories the project carries.

## Phase 2 — Interview

Open `interview.md` (same directory). 3-4 questions. Adaptive — skip what Phase 1 already answered.

- **Test framework** — usually obvious; only ask if Phase 1 didn't resolve.
- **Coverage status** — current felt-sense (as-we-go / backlog / none).
- **Highest-risk untested code** — for the audit mode's first-priority entry.
- **Testing depth** — behavior-only or richer (property / mutation / integration / E2E)?

## Phase 3 — Read the principles

Read these from `../../principles/` SELECTIVELY:

**Always read**:
- `test-architect.md` — the four-mode methodology, the five testability tiers, the risk-weighted priority pattern
- `quality-rubric.md` — coverage decisions inherit the rubric's risk language

**Read if project has DB write paths** (will overlap with `/dotclaude:data`):
- `data-integrity.md` — the data-auditor handles persistent-state correctness; the tests-architect handles unit / integration coverage. Boundary needs to be clear.

**Cross-reference** (link from the tests-architect agent, do not re-author):
- `code-review.md` — code-review surfaces coverage gaps; routes to tests-architect for the design
- `pre-flight.md` — pre-flight asks "what tests verify this?"; tests-architect operationalizes the answer

**Read the war-story example**:
- `../examples/the-test-passed-for-the-wrong-reason.md` — the canonical "test exercises a path that bypasses the real code" failure. The audit mode's stale-test check should explicitly look for this.

## Phase 4 — Author the kit

### Agents (in `.claude-staging/agents/`)

- **`tests-architect.md`** — the four-mode test-coverage agent
  - Frontmatter: `description:` — derived from `test-architect.md` principle, tuned to THE user's framework
  - Tool surface: `Read, Grep, Glob, Bash, Write, Edit` — this agent legitimately needs write access (testing IS creating code), unlike code-review / pre-flight
  - Body sections:
    - The four modes (audit / design / implement / maintain) — each with its trigger phrases, process, and report format
    - **Project-specific five-tier classification** — Tier A (pure functions), B (state stores), C (hooks / composables), D (thin wrappers — SKIP), E (UI rendering — SKIP). For each tier, name the project's actual file path patterns. E.g., "Tier A: `lib/<domain>/operations/*.ts`" — substitute with what the user's codebase actually shows.
    - **Project-specific risk-weighted priority** — populated with this project's risk categories. Examples to ground from but NOT to copy: auth, data-pipeline, money / billing, persistence write paths, public API contracts. Reorder + edit based on the user's interview answer to Q T3.
    - **Test infrastructure inventory** — names of THIS project's actual `test-utils/`, mock factories, wrappers, fixtures. If the project lacks shared infrastructure, the agent's first run should propose creating one (`test-utils/mocks.ts`) before sprinkling inline mocks.
    - **Gold-standard reference tests** — paths to 1-3 existing well-written tests in THIS project that the agent should model new tests on. (Read 5-10 existing tests in Phase 1; pick the cleanest 2-3.)
    - The "test behavior, not implementation" injunction — explicit and prominent
    - The "always run after writing" rule — implement mode must end with a successful run
  - Model: mid-tier reasoning model. Test writing is methodical work; doesn't require the heaviest reasoning. Save top-tier for code-review and pre-flight.

### Rules (in `.claude-staging/rules/`)

- **`test-discipline.md`** (small rule — author only if helpful)
  - Test what BEHAVIOR, not implementation. Examples specific to the project's stack.
  - What to skip for E2E coverage (typically UI rendering tier E — explicit list of what NOT to unit-test)
  - The "tests run after writing" rule
  - Cross-reference to the `tests-architect` agent for design / authoring
  - Skip authoring this rule entirely if the user has clear conventions documented elsewhere — pointing AT the existing doc is better than competing with it.

### Hooks

The testing kit doesn't typically ship hooks. Test-quality is the wrong shape for an edit-time hook (linters already catch syntax; the value of tests is in design, not enforcement). One exception: if the project enforces "no untested module shipped," a CI hook (not edit-time) might be wanted — but that's CI config, not `.claude/` scope.

If `/dotclaude:coding` has shipped `check-no-console-log.sh` already and the project's test files use `console.log` legitimately, ensure the hook's `consoleLog.allowPaths` includes `__tests__/` / `tests/` / `*.test.*`. Coordinate, don't duplicate.

## Phase 5 — Stage + present + commit

### Staging

Write everything to `.claude-staging/` first, organized by artifact type.

### Present

Walk the user through:

1. **The kit overview** — what landed (typically 1 agent + maybe 1 rule)
2. **Top 2-3 highlight artifacts** — concrete reasoning. NOT "I added a test-architect" but: "The tests-architect's audit mode will run against your <N> source files vs <M> test files. The top-3 risk-weighted untested modules I identified from your git history: `<path1>` (auth-adjacent, edited <X> times in last 90 days), `<path2>` (the cascade pipeline, written but no tests), `<path3>` (the API contract handlers). The agent's first audit will surface these."
3. **Gold-standard references** — quote the 2-3 reference tests you picked from the project. Be explicit: "New tests model after `<path-to-good-test>` — clean fixtures, behavior-focused assertions, no implementation coupling."
4. **What got SKIPPED** — and why. "Skipped tier-D and tier-E coverage — your thin wrappers in `<path>` and your UI rendering in `<path>` are correctly out of unit-test scope. Address those via E2E."
5. **Model + token-cost note** — tests-architect uses the mid-tier reasoning model and is moderately expensive (especially in Implement mode, which writes files). Audit mode is cheap; Implement mode scales with the count of tests being authored.

### Approve → commit

After explicit user approval, move `.claude-staging/` → `.claude/` and commit with structured message:

```
feat(.claude): testing discipline (dotclaude:testing)

Authored:
- agents:  tests-architect
- rules:   [test-discipline]

Test framework: <jest / vitest / pytest / etc.>
Risk-weighted priorities: <list of top 3>
Gold-standard reference tests: <paths>
```

## Non-negotiable rules for this flow

1. **Tier classification anchored on the project's actual files.** If you say "Tier A = pure functions" without naming where the user's pure functions actually live (`lib/utils/`? `src/helpers/`? `internal/algorithm/`?), the agent has no concrete grounding and will produce generic advice. Read Phase 1 carefully; encode the actual paths.

2. **Risk-weighted priority comes from the user, not from the principle doc.** The principle doc lists auth, billing, persistence, etc. as example categories. The user's project may not have billing (free product) and may have a different top concern (e.g., a content-pipeline project's top risk is ingestion-correctness). Ask. Encode their answer.

3. **Gold-standard reference tests are mandatory.** If the project has any tests at all, pick 2-3 of the cleanest as references the agent should model new tests on. WITHOUT references, the agent invents its own style and drifts from the project's idioms. WITH references, new tests look like existing tests and the codebase stays coherent.

4. **Tier D / Tier E are SKIPS, not low-priority.** The agent should refuse to write unit tests for thin wrappers (test the underlying function instead) and for UI rendering (use E2E). Be explicit: "These categories should NOT be unit-tested. If the user asks, redirect." Otherwise the agent generates noise.

5. **Implement mode MUST run the tests it writes.** Untested tests are not tests — they're text. The agent's Implement mode workflow is: write test → run test → fix failures → confirm green. If a test can't be run (missing infrastructure, broken setup), that's a finding to report, not a reason to skip the run.

6. **Don't sprinkle inline mocks.** If the project lacks shared mock infrastructure, the agent's first action on Implement mode should be to PROPOSE creating `test-utils/mocks.ts` (or equivalent) before writing any test that needs mocks. Inline mocks drift; centralized factories stay correct as type shapes evolve.

7. **Match the project's framework, don't introduce a new one.** If the project uses Vitest, write Vitest imports. If pytest, write pytest. Never introduce a new test runner because "this one is better." The cost of the new runner exceeds any incremental quality gain.

8. **Audit mode is the cheap, frequent invocation.** Make sure the audit mode's output is actionable (prioritized list, not a flat 50-file dump). The user will run audit much more often than Implement; the audit's report is the agent's day-to-day surface.
