# task-classification — designing the routing table in CLAUDE.md for ANY project

Teaching material for Claude Code. When you bootstrap a project's AI dev infrastructure, this doc teaches you HOW to author the task classification routing table — the 7-10 row matrix in `CLAUDE.md` that compresses dozens of *"how should I approach this"* decisions into a one-row lookup. Layer 3 of the v2 hierarchy.

## When to ship one (applicability gate)

Ship a task classification table when:

- The project has > 1 task pattern (UI work AND backend AND data, for example).
- The project uses validation agents, audit pipelines, or specialist subagents. The table is what routes work to the right specialist.
- The user has experienced inconsistency between sessions — *"this Monday I got an audit, this Tuesday I didn't, same kind of task."* That's the symptom.
- The project's quality bar varies by task type. E.g. UI work needs ux-reviewer; bug fixes need reproduce-fix-test; data work needs migration + types regen.

Skip when:

- The project has exactly one task pattern. *"This is a CLI tool; every change is a flag addition."* No routing needed.
- The user prefers ad-hoc routing per task and rejects table-driven discipline.
- The project is so small that the table would have ≤ 3 rows. Below 3 rows, prose is fine.

The default bias is **ship**. Even a 5-row table outperforms ad-hoc routing because routing becomes *consistent* across sessions, contributors, and AI tools.

## Why it matters — what this catches that nothing else does

Without the task classification table, three failure modes recur:

- **Re-derivation per session.** Every session opens with *"OK, this is a UI feature — should I dispatch the designer agent first? Or just implement and run ux-reviewer at the end? Hmm."* That's tokens + user time + decision drift, all preventable. With the table, the routing is a one-row lookup.

- **Routing inconsistency.** Without the table, sessions route the same task differently — sometimes UI feature → product-designer → impl → audit; sometimes UI feature → straight to impl → no audit. The kit's quality bar floats. The user can't predict what they'll get.

- **Silent scope decisions on ambiguous tasks.** Without an explicit *"Ambiguous"* row, sessions make scope calls the user wouldn't have approved. The user wanted a 1-screen polish; the session interpreted it as a full redesign. The Ambiguous row teaches Claude to ASK before acting.

The table also makes **cross-tool transferability possible**. The same routing logic works whether the implementer is Claude Code, Cursor, Aider, or a human reviewer. The table encodes *project-level discipline*, not tool-level.

## Core methodology — the routing table shape

The table is in `CLAUDE.md` "How You Work" section. Two columns: Task type / Approach.

### Column 1 — Task types (the rows)

Each row names a *task pattern*, not a *feature area*. The patterns are workflow-shaped:

- **UI feature / redesign** — multi-screen design + impl + audit work.
- **Backend / pipeline** — server-side / data-pipeline / job-system work.
- **Bug fix** — reproduce + fix + test.
- **Architecture change** — multi-module refactor / boundary shift / new layer.
- **Data / schema** — DB migration + type regeneration + integrity audit.
- **Plan-backed** — spec-driven work with conformance matrix.
- **Ambiguous** — request unclear; ask first.

Project-specific rows can extend the list. Examples:

- **API addition** (for backend-heavy projects)
- **Documentation update** (for projects with substantive docs)
- **Test-only change** (for projects with separate test ownership)
- **Dependency upgrade** (for projects with significant lockfile discipline)
- **Hotfix** (for projects with prod incidents)

Cap at ~8-10 rows. More rows = the table stops being scannable. Combine adjacent patterns into one row if you're over the cap.

### Column 2 — Approaches (verb-led sequences)

Each cell is a *runbook*, not an abstract description. Format:

```
<verb> → <verb> → <verb>
```

Where each verb names a specialist (agent / skill / hook) or a concrete action. Example:

```
Interview → `product-designer` agent (research + design + spec) → implement → pipeline per `.claude/rules/design-audit-routing.md` (`design-token-auditor` → `interaction-audit` + `a11y-audit` in parallel → `ux-reviewer`)
```

Three properties make the cell actually used:

1. **Verb-led**. Reads like a runbook. Not *"design phase, implementation phase, validation phase"* (too abstract); rather *"interview, dispatch agent X, implement, run audit Y"*.

2. **Named specialists by file path**. *"Dispatch `product-designer`"* not *"dispatch a designer agent."* The named specialists exist as files in `.claude/agents/` — clickable links if rendered.

3. **Terse**. 5-10 words per cell ideal; 15 words is the upper bound. The cell is a pointer, not a doc. The pointed-to specialist contains the depth.

### The "Ambiguous" row is mandatory

Every table has this row:

```
| Ambiguous | Ask first. Summarize back in 3-5 bullets. Wait for confirmation. |
```

Without this row, sessions silently make scope decisions on ambiguous requests. With it, Claude learns: *"I'm not sure which row applies — STOP, ask, summarize back, wait."* This row has prevented dozens of scope-drift incidents in mature projects.

## How to derive THIS project's specifics

Before authoring the table, gather:

1. **The dominant task patterns.** Ask: *"In a typical week, what kinds of tasks do you work on?"* List answers. Group into patterns. Common groupings: UI / backend / bug fix / data / planning / hotfix.

2. **The validation agents the project has.** `ls .claude/agents/` if existing. Without agents, the Approach cells are simpler (just verb sequences). With agents, the cells reference them by file path.

3. **The audit pipelines.** Does the project have a canonical pipeline (e.g. `design-token-auditor → interaction-audit + a11y-audit → ux-reviewer`)? Reference it in cells; don't restate.

4. **The plan-driven threshold.** Per `plan-driven-work.md`. The "Plan-backed" row routes to the conformance-matrix workflow when the threshold is met.

5. **The pre-flight gate.** Does the project use a `pre-flight` agent for risk assessment on complex changes? If yes, several rows route through pre-flight first.

6. **Domain skills with auto-load by path.** `.claude/skills/` with `paths:` frontmatter. The Approach cells should reference *"Load domain skill X for this file path"* implicitly via the skill auto-load.

7. **Hotfix / urgency patterns.** Does the project have prod incidents requiring fast-path workflows? If yes, add a "Hotfix" row with reduced ceremony.

8. **The Ambiguous escalation policy.** When Claude asks, what does the user prefer? *"Summarize back in 3-5 bullets"* is the default; some users want a different shape.

## Authoring guidance — what to write into the final artifact

The routing table lands in **one** place: `CLAUDE.md` "How You Work" section, *first-class navigation aid*, NOT buried in a sub-file. Format:

```markdown
**Task classification:**

| Task | Approach |
|------|----------|
| UI feature/redesign | Interview → `product-designer` agent (research + design + spec) → implement → pipeline per `.claude/rules/design-audit-routing.md` (`design-token-auditor` → `interaction-audit` + `a11y-audit` in parallel → `ux-reviewer`) |
| Backend / pipeline | Domain skill → `pre-flight` if complex → implement → `code-reviewer` → `tests-architect` |
| Bug fix | Reproduce → fix → test |
| Architecture change | `pre-flight` → `product-compass` → plan → implement → `code-reviewer` |
| Data / schema | `mcp__supabase__apply_migration` → `yarn db:types` → `data-auditor` |
| Plan-backed (spec/design-doc + sub-plans) | Implement per sub-plan → produce `docs/audits/<plan-slug>-conformance.md` (§section × `matches/deviates/deferred` + per-surface screenshots) BEFORE claim shipped → resolve CRIT/MAJ → only THEN declare done. Subagent rollup ≠ matrix. |
| Ambiguous | Ask first. Summarize back in 3-5 bullets. Wait for confirmation. |
```

After the table, add the *Specialists* subsection:

```markdown
**Specialists:**
- **Domain skills** auto-load by file path — see `.claude/skills/*/SKILL.md` frontmatter `paths:`. <ENUMERATE_KEY_ONES>.
- **Validation agents** — see `.claude/agents/*.md`. Common: <ENUMERATE>.
- **User-invocable skills** (require explicit `/<name>`): <ENUMERATE>.
```

This subsection makes the named specialists discoverable; without it, *"dispatch `product-designer`"* in the table is a dangling reference.

### Don't bury the table

The table belongs in `CLAUDE.md`, NOT in a sub-file like `.claude/rules/task-classification.md`. Reason: Claude reads `CLAUDE.md` at the start of every session; reading sub-files is contingent on context. The table is what governs the *first decision of every session*, so it must be in the always-loaded surface.

If `CLAUDE.md` is already very large (> 800 LOC), the table can be in a sub-file with a strong pointer in `CLAUDE.md` ("see `.claude/rules/task-routing.md`"). But the default is in-CLAUDE.md.

## Depth signatures — what battle-tested looks like

The authored task classification table fails the depth bar if it lacks any of these signals.

1. **5-8 task classes minimum.** Below 5, the table isn't doing much routing. Above 10, the table stops being scannable.

2. **Each class names specific agents/skills/hooks to invoke.** Not *"do design review"* but *"dispatch `ux-reviewer` per `.claude/rules/design-audit-routing.md`"*. Named specialists are clickable links to depth; vague language defeats the purpose.

3. **"Ambiguous" row exists and includes "ask first, summarize back".** This row is mandatory. Without it, the table is incomplete.

4. **Routing table is in CLAUDE.md, not buried in a sub-file.** Test: `head -200 CLAUDE.md` shows the table. If the table is in `.claude/rules/<X>.md`, sessions that don't read sub-files miss it entirely.

5. **Each row's Approach cell is verb-led**, not noun-led. *"Interview → dispatch → implement"* not *"Design phase, implementation phase."* Verbs are actionable; nouns are abstract.

6. **The table cross-references the audit pipeline doc** if one exists (e.g. `.claude/rules/design-audit-routing.md`). Without the cross-ref, the table restates pipeline order; the restatement drifts from the canonical source.

7. **Plan-backed row references the conformance-matrix discipline.** Either inline (*"produce `docs/audits/<plan-slug>-conformance.md`"*) or via cross-ref to `plan-driven-work.md`. Without this, the table doesn't enforce the conformance bar.

8. **Each named agent / skill / hook exists in `.claude/`.** Test: `grep -oE '\\`[a-z-]+\\`' CLAUDE.md` (extracting backtick names) → `ls .claude/{agents,skills,hooks}/` should resolve them. Names referencing non-existent specialists are dead ends.

9. **Specialists subsection enumerates the key agents and skills.** Without it, the table's named specialists are not discoverable.

10. **The table is < 12 rows.** Bigger than 12 and the table is doing job classification, not task routing. Pare back.

If the authored table lacks any of these, redo. The table is the most-read part of CLAUDE.md after identity; getting it right is high leverage.

## Universal task patterns (cross-project)

These patterns generalize across project types. The Approach cells differ; the row labels are stable.

### For a CLI tool / library

| Task | Approach |
|---|---|
| New flag / subcommand | Read CLI conventions → implement → add tests → update `--help` | 
| Output format change | Reproduce existing → update → add golden-file test |
| Bug fix | Reproduce → fix → test |
| Refactor | `pre-flight` → plan → implement → review |
| Doc update | Edit doc → render → spot-check |
| Ambiguous | Ask first. Summarize back in 3-5 bullets. Wait for confirmation. |

### For a B2B SaaS dashboard

| Task | Approach |
|---|---|
| UI feature | `product-designer` agent → implement → `ux-reviewer` → `a11y-audit` |
| API endpoint | Schema design → implement → `code-reviewer` → integration test |
| DB migration | `apply_migration` → regen types → `data-auditor` |
| Bug fix | Reproduce → fix → test |
| Architecture change | `pre-flight` → plan → implement → `code-reviewer` |
| Plan-backed | Conformance matrix at `docs/audits/<plan-slug>-conformance.md` |
| Ambiguous | Ask first. Summarize back in 3-5 bullets. Wait for confirmation. |

### For a docs site

| Task | Approach |
|---|---|
| New tutorial | Outline → draft → render → link-check → ship |
| API ref update | Find existing entry → edit → render → verify |
| Site reorganization | `pre-flight` → plan → implement → link-check |
| Bug fix | Reproduce → fix → verify rendered output |
| Ambiguous | Ask first. Summarize back in 3-5 bullets. Wait for confirmation. |

### For a research prototype

| Task | Approach |
|---|---|
| Run experiment | Verify setup → run → capture results in notebook |
| Add measurement | Implement → verify against baseline |
| Refactor pipeline | `pre-flight` → plan → implement → re-run baseline |
| Ambiguous | Ask first. Summarize back in 3-5 bullets. Wait for confirmation. |

These are *starting points*. Adjust columns and rows to the actual project.

## Anti-patterns to avoid

- **Generic abstract cells.** *"Design phase, then implementation phase."* No agent named, no skill named, no hook named. The cell doesn't route — it just describes a generic workflow. Cells must reference specific specialists by name.

- **Table buried in a sub-file.** *".claude/rules/task-routing.md exists."* Claude doesn't read sub-files unless prompted. The table must be in always-loaded surface (CLAUDE.md).

- **No Ambiguous row.** Without it, Claude silently scope-decides on unclear requests. Adding the row is one minute of work; not having it costs hours per quarter in scope-drift incidents.

- **Cells that restate audit pipelines instead of referencing them.** *"design-token-auditor → interaction-audit → a11y-audit → ux-reviewer"* expanded in every row. Reference the canonical doc (`.claude/rules/design-audit-routing.md`) once; cells use the canonical pipeline name.

- **Rows too narrow.** 15-20 rows = the table is doing job classification. Pare to 7-10 actual task patterns.

- **Rows too wide.** 3-4 rows that each lump 6 distinct task types together. The table can't route — every task fits in one of three buckets and the bucket name is vague. Split.

- **Named specialists that don't exist.** *"Dispatch `product-strategist`"* but `.claude/agents/product-strategist.md` isn't there. Either ship the agent or stop referencing it.

- **Cells with conditional logic.** *"If the change is complex, dispatch X; else dispatch Y."* The table is a *routing* surface, not a *decision-tree* surface. Push conditionals to the dispatched specialist's body; keep the table flat.

- **Approach cells that describe outcomes instead of actions.** *"Produce a high-quality UI."* What does the implementer DO? The cell must name verbs (interview, dispatch, implement, audit), not goals.

- **Table that doesn't reflect current discipline.** Strategy shifts; specialists change; the table doesn't update. The table becomes a historical snapshot, and Claude routes against stale process. Update the table same-PR as discipline changes.

- **Specialists subsection missing.** The table references named agents but doesn't enumerate them. Future readers can't find the agent definitions. Always include the Specialists subsection.

- **One table per task category.** *"UI tasks table, then backend tasks table, then data tasks table."* Three tables = three lookups = no scan. One table, more rows, one lookup.

## Cross-references

- `project-identity.md` — Layer 1. Identity is in CLAUDE.md above the routing table; identity grounds *what kinds of tasks even apply*.
- `plan-driven-work.md` — Layer 3. The "Plan-backed" row routes to plan-driven workflow + conformance-matrix discipline.
- `knowledge-graph.md` — Layer 5. Many Approach cells reference `docs/` paths (specs, plans, audits); the knowledge graph must exist for the references to resolve.
- `memory-system.md` — Layer 3. Memory access is part of how-you-work for several task types (*"check feedback memory for prior decisions"* gets executed as part of the Approach).
- `pre-flight.md` — Layer 6 planning kit. The pre-flight agent is referenced in multiple rows (architecture change, complex backend); the row's runbook starts with pre-flight invocation.
- `code-review.md` — Layer 6 coding kit. The code-reviewer agent is the terminal step in multiple rows.
- `audit-routing.md` — Layer 6 design kit. The UI row references the audit pipeline doc; cells in the UI row don't restate the pipeline.
