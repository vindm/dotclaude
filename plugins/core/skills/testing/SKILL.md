---
description: Elicit test-coverage risk priorities for a project and write them to a thin artifact — `.claude/dotclaude/test-risk-model.md` plus a `dotclaude.yml` key — derived from the project's actual test/source ratio, its most-edited untested files, and the user's own sense of what scares them most. No agent, rule, or hook is authored: the consumed `test-architect` agent already reads this artifact at runtime. Invoke /dotclaude:testing in any project where tests exist OR should exist.
---

# `/dotclaude:testing` — test-risk elicitation

You are eliciting the project-specific test-coverage intent for the user's project: the coverage philosophy (as-we-go / backlog / none), the ONE module whose lack of coverage scares the user most, and the testing depth the project holds versus aspires to. The output is ONE thin artifact — `.claude/dotclaude/test-risk-model.md` — plus a key in `dotclaude.yml`. You do **not** author an agent, a rule file, or a hook: the consumed `test-architect` agent (shipped by the plugin — see `agents/test-architect.md`) already reads `dotclaude.yml`'s `artifacts.test-risk-model` path at runtime, seeds its risk-weighted priority table from the artifact's top entry, falls back to deriving priorities from runtime signals alone when the artifact is absent, and layers the artifact's entries on top of its own four-mode methodology (audit / design / implement / maintain) when it's present (full contract: `../../docs/artifact-contract.md`).

This elicitation is cheap and the consumed `test-architect` agent is useful even with an empty artifact — it falls back to its own generic risk tiers (auth → data-pipeline → billing → persistence → public API → algorithms → utilities) and to runtime signals (test/source ratio, most-edited untested files) when nothing has been elicited yet. What this skill adds is the part the codebase can't tell you: which module actually keeps the user up at night, and how far the team wants testing depth to go.

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
   The presence (or absence) of these signals discipline maturity — useful context for the interview, even though the consumed agent (not this artifact) is what actually uses shared infrastructure at runtime.

4. **Coverage gap analysis** — source vs tests:
   ```bash
   # JS / TS — module-by-module pairing
   find . -name "*.ts" -not -name "*.test.ts" -not -name "*.d.ts" \
     -not -path "*/node_modules/*" 2>/dev/null | wc -l
   find . -name "*.test.ts" -not -path "*/node_modules/*" 2>/dev/null | wc -l
   # Look at most-edited source files vs whether tests exist for them
   git log --format=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn | head -20
   ```
   The ratio (source files to test files) + the most-edited untested files feed straight into the interview's T3 — use them to jog the user's memory rather than asking cold.

5. **Existing CI / coverage gates** — `.github/workflows/`, `circle.yml`, etc., for test scripts; look for coverage thresholds.

Build mental model of: what framework + idioms, what's currently tested vs untested, what shared infrastructure exists, what risk categories the project carries. This scan grounds the interview questions in data instead of asking the user to recall facts you can already see.

## Phase 2 — Interview

Open `interview.md` (same directory). 3-4 questions. Adaptive — skip what Phase 1 already answered.

- **Test framework** — usually obvious; only ask if Phase 1 didn't resolve.
- **Coverage status** — current felt-sense (as-we-go / backlog / none).
- **Highest-risk untested code** — THE most important question; its answer becomes the artifact's top priority entry.
- **Testing depth** — behavior-only or richer (property / mutation / integration / E2E), current vs aspired.

## Phase 3 — Write the artifact

After the interview, write ONLY the elicited human intent. Nothing in this phase authors an agent, a rule file, a skill, or a hook — the consumed `test-architect` agent already carries the four-mode methodology, the five-tier testability classification, and the generic risk ordering, and reads what you write here at runtime. Do NOT author a `tests-architect.md` (or `test-architect.md`) agent copy — that would duplicate the consumed agent and drift the moment either side changes.

### 1. `.claude/dotclaude/test-risk-model.md`

One top-priority entry from T3, plus the coverage-status and testing-depth framing from T2 and T4. This is a short, human-readable statement of intent — not a coverage report and not a copy of the agent's tier table:

```markdown
# Test risk model

Project-specific risk priorities the `test-architect` agent weighs on top of
its generic four-mode methodology and risk-tier ordering.

**Coverage status:** <as-we-go / backlog / none>
**Testing depth today:** <behavior-only / +property / +mutation / +contract>
**Testing depth aspired:** <same as today / richer — name what>

## Risk-weighted priorities

1. **<name, e.g. "auth / identity / session">**
   - **Why:** <the worst failure mode, in the user's own words from T3>
   - **Where:** `<path, if the user named one or Phase 1 surfaced it>`

2. **<second priority, only if the user named one>**
   - **Why:** <...>
```

If T3 came up empty or hesitant (see `interview.md`'s guidance on hesitation-as-data), it's fine to ship a single lightly-populated entry flagged `evolving` rather than inventing a confident-sounding priority the user didn't actually state. A thin, honest artifact beats a padded one.

### 2. `dotclaude.yml` — artifact path

Record the `artifacts.test-risk-model` path so `test-architect` can locate the file without a hardcoded convention:

```yaml
artifacts:
  test-risk-model: .claude/dotclaude/test-risk-model.md
```

Merge into an existing `dotclaude.yml` if one already exists (from `/dotclaude:coding` or another domain elicitation) — never overwrite unrelated keys, in particular an existing `artifacts.code-anti-patterns` entry.

### Present + confirm

Show the drafted `test-risk-model.md` and the `dotclaude.yml` diff. Walk through the top-priority entry with real reasoning — "you named the auth callback as the module that scares you most; a bug there means everyone's locked out or worse, cross-session leakage — that's now the agent's priority-1 audit target" — and note the coverage-status and depth framing you recorded. Wait for explicit confirmation before writing. This is a two-file change, not a multi-file kit, so no `.claude-staging/` review pass is needed: write directly to `.claude/dotclaude/test-risk-model.md` and merge into `dotclaude.yml` on approval.

## Non-negotiable rules for this flow

1. **The top priority comes from the user, not from the principle doc.** `principles/test-architect.md` lists a generic risk ordering (auth → data-pipeline → billing → persistence → public API → algorithms → utilities) as a fallback for when no artifact exists. This artifact's job is to override that generic ordering with the user's actual answer to T3 — ask, and encode their answer verbatim.

2. **Don't invent a priority the user didn't state.** If T3 comes up hesitant or empty, populate the artifact lightly and flag it `evolving` rather than dressing up a guess as a confident risk model.

3. **Do NOT author an agent, a rule, or a hook.** The consumed `test-architect` agent already owns the four-mode methodology, the five-tier classification, the mock-infrastructure discipline, and the "run what you write" rule. Writing a project-local `tests-architect.md` (or `test-architect.md`) copy duplicates what the plugin already ships and creates drift the moment either side changes. If a project genuinely needs to override the consumed agent's behavior, that's a deliberate same-name shadow, not this skill's default output.

4. **Coverage status shapes framing, not action.** Whether the project is as-we-go, backlog, or near-zero changes what the `test-architect` agent's audit mode will emphasize at runtime — this skill's job is only to record which one it is, not to run an audit itself.

5. **Match the project's framework, don't introduce a new one.** Note the framework in Phase 1 for interview context, but the artifact itself doesn't need to restate it — the consumed agent reads the project's own manifests for that.

## See also

- `interview.md` — the short interview (T1 framework, T2 coverage status, T3 highest-risk untested code, T4 testing depth).
- `../../docs/artifact-contract.md` — the full elicit → artifact → consumed-agent contract.
- `../../agents/test-architect.md` — the consumed agent that reads `test-risk-model.md` at runtime.
