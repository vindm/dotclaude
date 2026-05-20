---
description: Set up pre-implementation discipline + audit routing for a project with regular multi-module changes. Authors a pre-flight agent that maps integration points, parallel paths, and cross-boundary surfaces — plus an audit-routing rule that orders which agent fires for which question. Invoke /dotclaude:planning in any project where "we shipped feature X and broke unrelated thing Y" has happened more than once.
---

# `/dotclaude:planning` — pre-implementation discipline kit

You are setting up the pre-impl half of the validation loop. The output is a `.claude/` subset focused on what happens BEFORE code is written: territory mapping, integration-point analysis, parallel-path detection, cross-boundary verification, and the routing rule that decides which audit agent fires for which question once the user's `.claude/` accumulates more than 2-3 of them.

`/dotclaude:coding` ships the post-impl reviewer; this skill ships its pre-impl companion + the routing layer that organizes them.

## Phase 1 — Read the project's coupling shape

Before any question:

1. **Module / package layout** — top-level structure:
   ```bash
   ls -la
   ls packages/ workspaces/ apps/ services/ lib/ src/ 2>/dev/null
   ```
   Count the modules. Note whether this is a monorepo (multiple `package.json` / `Cargo.toml` / `pyproject.toml`), a workspace, or a flat single-package project.

2. **Cross-module change frequency** — read the git log for multi-module PRs:
   ```bash
   git log --merges --oneline -30
   git log --oneline --stat -50 | head -200
   ```
   Look for commits / merges that touch files in 3+ different top-level directories. These are the kinds of changes pre-flight earns its keep on.

3. **Revert / rollback history** — design mistakes that shipped:
   ```bash
   git log --oneline --grep="revert" -30
   git log --oneline --grep="rollback" -30
   ```
   Each revert is a pre-flight gap that wasn't caught. Read the diffs of the 3-5 most expensive-looking ones.

4. **Cross-boundary surfaces** — identify which layer-crossings exist in this project:
   ```bash
   # Native bridges (React Native / Expo, mobile)
   find . -name "*.swift" -path "*modules*" 2>/dev/null | head
   find . -path "*ios/*" -name "*.swift" 2>/dev/null | head
   find . -path "*android/*" -name "*.kt" 2>/dev/null | head
   # IPC / Electron / Tauri
   find . -name "preload.*" -o -name "main.*" -path "*electron*" 2>/dev/null | head
   # FFI / wasm
   grep -rn "wasm_bindgen\|extern \"C\"\|napi_" --include="*.rs" --include="*.toml" . 2>/dev/null | head
   # Web service boundaries
   find . -path "*api/*" -name "*.ts" -o -path "*routes/*" -name "*.ts" 2>/dev/null | head
   ```
   Each detected boundary is a Phase 3B trigger in the pre-flight agent (cross-boundary verification).

5. **Existing planning docs** — `CLAUDE.md`, `AGENTS.md`, `docs/architecture.md`, sub-module READMEs. If the project documents its module map already, the pre-flight agent leverages that doc instead of rediscovering it.

6. **Existing agent inventory** — what's already in `.claude/agents/` or `.claude-staging/agents/` from previous domain skills:
   ```bash
   ls .claude/agents/ .claude-staging/agents/ 2>/dev/null
   ```
   This determines whether the `audit-routing.md` rule earns its keep (3+ audit agents threshold).

Build mental model of: how coupled is this codebase, what cross-boundary surfaces exist, what kinds of changes have produced reverts, what other audit agents will the routing rule need to organize.

## Phase 2 — Interview

Open `interview.md` (same directory). 3-4 questions. Adaptive — skip what Phase 1 already answered.

- **Change shape** — typical PR / commit shape (Phase 1 has data; confirm).
- **Cross-module coupling** — what kinds of changes regularly touch multiple parts of the system?
- **Pre-impl review posture** — does the user actually pause to validate before coding?
- **Audit pipeline** — if multiple audit agents are already authored (or will be), is there a sequence the user wants?

## Phase 3 — Read the principles

Read these from `../../principles/` SELECTIVELY:

**Always read** (pre-flight discipline):
- `pre-flight.md` — the full 5-phase methodology (territory / integration / parallel-path / cross-boundary / risk / recommendation)
- `quality-rubric.md` — the Clear-for-Takeoff / Caution / Abort scale derives from the rubric anchor pattern

**Read if `.claude/` will have 3+ audit-shaped agents** (count the union of agents from `/dotclaude:coding`, `/dotclaude:design`, `/dotclaude:testing`, `/dotclaude:data`, `/dotclaude:ai-workflow`):
- `audit-routing.md` — the routing-table + pipeline-order methodology

**Cross-reference** (link from the pre-flight agent, do not re-author):
- `code-review.md` — pre-flight and code-review share the parallel-path methodology
- `data-integrity.md` — pre-flight flags data concerns; data-auditor does the deeper sweep
- `migration-create.md` — pre-flight flags migrations in scope; the migration skill executes

**Read the war-story examples** (the pre-flight agent's "Do NOT" section should reference them):
- `../examples/the-write-that-returned-success.md` — trust boundary; pre-flight asks the question
- `../examples/the-test-passed-for-the-wrong-reason.md` — entry-point listing; pre-flight would have caught it
- `../examples/the-bug-surfaced-five-screens-later.md` — cascade-through-valid; pre-flight asks about origin validation

## Phase 4 — Author the kit

### Agents (in `.claude-staging/agents/`)

- **`pre-flight.md`** — the pre-implementation validation agent
  - Frontmatter: `description:` — derived from `pre-flight.md` principle, tuned to THE user's stack and cross-boundary surfaces
  - Tool surface: `Read, Grep, Glob, Bash` (NO `Edit`, NO `Write` — pre-flight is analysis, not implementation; the read-only constraint is part of the value)
  - Body sections:
    - The five phases (territory map / integration analysis / parallel-path inventory / cross-boundary verification when applicable / risk assessment / recommendation)
    - **Project-specific integration-point map** — name the actual modules / tables / queue systems / cache slices / boundary surfaces this project has. Concrete names, not placeholders ("TABLES_HERE"). Derived from Phase 1.
    - Phase 3B cross-boundary surfaces enumerated — list each boundary actually present (e.g., "JS ↔ Swift native modules at `modules/`", "Main ↔ renderer IPC at `electron/preload.ts`", "API ↔ DB via `lib/db/`"). Skip surfaces the project doesn't have.
    - Risk-categories tuned to the project's actual stakes (financial → data corruption + cross-tenant top; consumer app → silent failure + UX cascade top)
    - The Clear for Takeoff / Caution / Abort verdict scale
    - "Do NOT" entries derived from the revert history Phase 1 surfaced + the war-story examples
    - Report-format template

- **`code-reviewer.md`** — IF `/dotclaude:coding` did NOT run yet
  - The lightweight version: enough to be useful, but the user is encouraged to invoke `/dotclaude:coding` for the full kit
  - If `/dotclaude:coding` already ran, do NOT duplicate — cross-reference its agent in this kit's overview message

### Rules (in `.claude-staging/rules/`)

- **`audit-routing.md`** (only if `.claude/` will have 3+ audit-shaped agents — count the union across all domain skills the user runs or has run)
  - The routing table — scoped to ACTUAL agents in the user's `.claude/agents/`. Don't list `flow-auditor` if there's no flow-auditor in the inventory.
  - The refuse-and-recommend behaviors — for each agent that refuses certain question shapes (e.g., single-screen reviewers refuse multi-screen requests)
  - The canonical pipeline order — for the project's typical multi-audit batches (UI batch, schema-change batch, etc.)
  - Cross-rubric translation table — only if the agents grade on different scales
  - Hooks-prevent-findings sub-table — name the edit-time hooks already wired (file-size, forbidden-phrases, secret-leak, etc.) so the user knows which findings are pre-empted

### Hooks

Pre-flight discipline doesn't have a dedicated hook (the agent IS the discipline). The audit-routing rule references hooks from other domain skills — do not re-author them here.

## Phase 5 — Stage + present + commit

### Staging

Write everything to `.claude-staging/` first, organized by artifact type.

### Present

Walk the user through:

1. **The kit overview** — what landed (typically 1 agent + 1 rule)
2. **Top 2-3 highlight artifacts** — concrete reasoning. NOT "I added pre-flight" but: "The pre-flight agent knows about your three top-level boundaries — `<modules/ios/foo.swift>` ↔ JS, `<lib/api/>` ↔ Postgres, and `<workers/>` ↔ queue. Its Phase 3B will trigger automatically on any change touching one of those. I derived 4 'Do NOT' entries from your revert history — for example, `<short-sha>` shows the pattern of <X>, so pre-flight will now explicitly warn against <Y>."
3. **Audit-routing rule** (if shipped) — show the routing table populated with the user's actual agents, and the pipeline order for their typical multi-audit batches. Be explicit about which agents are NOT yet authored (they show as gaps to fill via other domain skills).
4. **What got SKIPPED** — and why. If `audit-routing.md` wasn't shipped, say so: "Only 2 audit agents exist; routing rule would be overhead. Re-run this if the inventory grows."
5. **Model + token-cost note** — pre-flight uses the highest-tier reasoning model and is the most expensive non-code-review agent. Each pre-flight invocation costs the same order of magnitude as a code review. Be honest.

### Approve → commit

After explicit user approval, move `.claude-staging/` → `.claude/` and commit with structured message:

```
feat(.claude): planning discipline (dotclaude:planning)

Authored:
- agents:  pre-flight[, code-reviewer]
- rules:   [audit-routing]

Cross-boundary surfaces mapped: <list>
Revert-derived "Do NOT" entries: <count>
Audit pipeline: <order or "not authored (< 3 agents)">
```

## Non-negotiable rules for this flow

1. **Concrete integration-point map, not placeholders.** The pre-flight agent's body should list ACTUAL table names, ACTUAL queue names, ACTUAL native module names, ACTUAL IPC channel names. If you can't fill in the names, you haven't done Phase 1 thoroughly enough — go back. A pre-flight agent that says "check the data layer" is useless; one that says "check `equipment.identity_confidence`, `jobs` (status enum), `cache_keys.member_*`" earns its keep.

2. **Phase 3B is conditional.** If the project has no cross-runtime boundaries (pure backend service, pure frontend SPA with no native code), don't include Phase 3B in the agent's body. A phantom cross-boundary phase wastes opus tokens on a non-existent concern. Read Phase 1 first; only include surfaces the project actually has.

3. **Derive "Do NOT" entries from real history.** The "Do NOT" section is often more valuable than the "do" section. Each entry should reference a real revert / rollback in the project's git log (with short SHA) — NOT generic warnings copied from the principle doc. If the project has no revert history yet, the "Do NOT" section pulls from the war-story examples instead, with a note that it'll be extended as the project's own history accrues.

4. **Read-only tool surface is structural.** The pre-flight agent must NOT have `Edit` or `Write` tools. The whole value is that the user can run pre-flight and trust the codebase is unchanged. If you give it write access "for convenience," users will stop trusting the read-only contract and the agent's role collapses into "another implementer."

5. **The routing rule needs a real inventory.** Don't ship `audit-routing.md` with rows for agents that don't exist. If the user's `.claude/` has 2 agents, ship no routing rule (cognitive overhead exceeds value at that size). If it has 3+, list ONLY the ones present. Re-run the rule's generation when new audit agents are added.

6. **Pipeline order is binding.** When multiple audits apply to one batch, the order in the routing rule must be deterministic (cheapest mechanical sweeps first, semantic/a11y in parallel, visual polish last for UI work). Reversing the order produces wasted agent runs. Encode the order; don't leave it to taste.

7. **Cross-reference, don't duplicate.** If `/dotclaude:coding` already shipped a `code-reviewer.md`, do NOT re-author it here — link to it. If `/dotclaude:data` will ship `data-auditor.md`, the pre-flight agent's risk-assessment phase can REFERENCE that agent but should not encode its query logic. Boundary discipline between domain skills prevents drift.

8. **Be honest about cost.** Pre-flight is one of the two most-expensive agents (the other being code-review). The kit overview should say so. Pre-flight earns its keep on changes that justify it (cross-module refactors, new pipelines, schema-touching features) — it's overhead on a one-file typo fix. The user should understand the tradeoff.
