# task-classification — designing the routing table in CLAUDE.md for ANY project

Teaching material for Claude Code. Teaches you how to author the task-classification routing table — the 7-10 row matrix in `CLAUDE.md` that compresses dozens of *"how should I approach this"* decisions into a one-row lookup.

## When to ship one

Ship a routing table when the project has more than one task pattern (UI *and* backend *and* data, say) and uses validation agents, audit pipelines, or specialist subagents to route work to. The symptom it fixes: inconsistency between sessions — *"Monday I got an audit, Tuesday I didn't, same kind of task."*

Skip when the project has exactly one task pattern (*"every change is a flag addition"*), when the table would have ≤ 3 rows (prose is fine below that), or when the user rejects table-driven routing. **Default: ship** — even a 5-row table beats ad-hoc routing, because routing becomes consistent across sessions, contributors, and tools. The table encodes *project-level* discipline, so the same logic holds whether the implementer is Claude Code, Cursor, Aider, or a human.

## Why it matters

Three failure modes recur without the table:

- **Re-derivation per session** — every session reopens *"this is a UI feature — dispatch the designer first, or implement then audit?"* Tokens, user time, and drift, all preventable by a one-row lookup.
- **Routing inconsistency** — the same task routed differently across sessions, so the kit's quality bar floats and the user can't predict what they'll get.
- **Silent scope decisions on ambiguous tasks** — without an explicit *Ambiguous* row, a session reads "polish this screen" as "full redesign" and never asks. The Ambiguous row teaches Claude to ASK before acting.

## Core methodology — the routing table shape

The table lives in `CLAUDE.md` "How You Work." Two columns: Task type / Approach.

### Column 1 — Task types (the rows)

Each row names a *task pattern*, not a *feature area* — patterns are workflow-shaped: **UI feature / redesign**, **Backend / pipeline**, **Bug fix**, **Architecture change**, **Data / schema**, **Plan-backed**, **Ambiguous**. Project-specific rows extend the list where the pattern is real: **API addition**, **Dependency upgrade**, **Hotfix**, **Test-only change**, **Doc update**. Cap at ~8-10 — beyond that the table stops being scannable; combine adjacent patterns instead.

### Column 2 — Approaches (verb-led runbooks)

Each cell is a runbook, `<verb> → <verb> → <verb>`, where each verb names a specialist (agent / skill / hook by file path) or a concrete action. Three properties make a cell actually get used:

1. **Verb-led** — reads like a runbook (*"interview, dispatch `product-designer`, implement, run audit"*), not noun-led phases (*"design phase, implementation phase"*).
2. **Named specialists by path** — *"dispatch `product-designer`"*, not *"dispatch a designer agent."* The names are files in `.claude/agents/` — clickable, and resolvable.
3. **Terse** — 5-10 words per cell, 15 the ceiling. The cell is a pointer; the depth lives in the specialist it points to.

### The "Ambiguous" row is mandatory

```
| Ambiguous | Ask first. Summarize back in 3-5 bullets. Wait for confirmation. |
```

Without it, sessions silently scope-decide on unclear requests. With it, Claude learns: *not sure which row applies — stop, ask, summarize back, wait.*

## How to derive THIS project's specifics

1. **The dominant task patterns.** Ask: *"in a typical week, what kinds of tasks do you work on?"* Group answers into patterns.
2. **The validation agents the project has** (`ls .claude/agents/`). With agents, cells reference them by path; without, cells are plain verb sequences.
3. **The audit pipelines.** If there's a canonical one (`design-token-audit → interaction-audit + a11y-audit → ux-audit`), reference it by name; don't restate its order in every row.
4. **The plan-backed threshold** — when the conformance-matrix workflow kicks in.
5. **The pre-flight gate** — which rows should route through `pre-flight` first for risk mapping.
6. **Domain skills that auto-load by path** (`.claude/skills/*/SKILL.md` `paths:` frontmatter) — cells lean on the auto-load rather than naming the skill.
7. **Hotfix / urgency patterns** — if prod incidents need a reduced-ceremony fast path, add a Hotfix row.
8. **The Ambiguous escalation shape** — "summarize back in 3-5 bullets" is the default; some users want a different one.

## Authoring guidance — what to write into the final artifact

The table lands in **`CLAUDE.md` "How You Work"** as a first-class navigation aid, NOT a sub-file: Claude reads `CLAUDE.md` every session, but reading sub-files is contingent — and this table governs the first decision of every session. (Only if `CLAUDE.md` is already > 800 LOC does the table move to a sub-file behind a strong pointer.)

```markdown
**Task classification:**

| Task | Approach |
|------|----------|
| UI feature/redesign | Interview → `product-designer` agent (research + design + spec) → implement → pipeline per `.claude/rules/design-audit-routing.md` (`design-token-audit` → `interaction-audit` + `a11y-audit` in parallel → `ux-audit`) |
| Backend / pipeline | Domain skill → `pre-flight` if complex → implement → `code-review` → `test-architect` |
| Bug fix | Reproduce → fix → test |
| Architecture change | `pre-flight` → plan → implement → `code-review` |
| Data / schema | apply migration → regen types → `data-auditor` |
| Plan-backed (spec/design-doc + sub-plans) | Implement per sub-plan → produce `docs/audits/<plan-slug>-conformance.md` (§section × `matches/deviates/deferred` + per-surface screenshots) BEFORE claiming shipped → resolve CRIT/MAJ → only THEN declare done. Subagent rollup ≠ matrix. |
| Ambiguous | Ask first. Summarize back in 3-5 bullets. Wait for confirmation. |
```

Then a *Specialists* subsection, so the named specialists are discoverable (without it, *"dispatch `product-designer`"* is a dangling reference):

```markdown
**Specialists:**
- **Domain skills** auto-load by file path — see `.claude/skills/*/SKILL.md` frontmatter `paths:`. <ENUMERATE_KEY_ONES>.
- **Validation agents** — see `.claude/agents/*.md`. Common: <ENUMERATE>.
- **User-invocable skills** (require explicit `/<name>`): <ENUMERATE>.
```

Row labels stay stable across project types; only the Approach cells change (a CLI tool's UI row becomes a `--help` row, a docs site's becomes a link-check row). Derive the cells from the project's real agents and actions — don't paste a template from another project's shape.

## Acceptance — what battle-tested looks like

The authored table fails the bar if any of these is missing (each names the signature and the failure it prevents):

1. **5-10 rows.** Below 5 it isn't routing; above ~10-12 it's job classification, not task routing, and stops being scannable. Rows that lump 6 task types into one vague bucket can't route — split them.
2. **Each row's Approach cell names specific agents / skills / hooks and is verb-led.** *"Dispatch `ux-audit` per `.claude/rules/design-audit-routing.md`"*, not *"do design review"* or *"design phase, implementation phase."* Generic abstract cells don't route; they describe.
3. **Cells describe actions, not outcomes, and carry no conditional logic.** *"Interview → dispatch → implement,"* not *"produce a high-quality UI"* and not *"if complex dispatch X else Y."* The table is a routing surface; push conditionals and goals down into the dispatched specialist.
4. **The "Ambiguous" row exists** with "ask first, summarize back." Without it, Claude silently scope-decides on unclear requests.
5. **The table is in `CLAUDE.md`, not buried in a sub-file.** Test: `head -200 CLAUDE.md` shows it. Sessions that don't read sub-files miss a buried table entirely.
6. **Cells reference the canonical audit-pipeline doc rather than restating it** — restated pipeline order drifts from its source. Same for the Plan-backed row referencing the conformance-matrix discipline inline.
7. **Every named agent / skill / hook exists in `.claude/`.** Test: extract backtick names from `CLAUDE.md` and resolve them against `ls .claude/{agents,skills,hooks}/`. Names pointing at non-existent specialists are dead ends.
8. **A Specialists subsection enumerates the key agents and skills**, so the table's named references are findable.
9. **The table reflects current discipline** — updated same-PR as agents and process change, not left as a historical snapshot Claude routes against.

The table is the most-read part of `CLAUDE.md` after identity; getting it right is high leverage. Miss any signal and redo.

## Cross-references

- `project-identity.md` — identity sits above the table and grounds *what kinds of tasks even apply*.
- `operating-principles.md` — the four principles sit *above* this table: they say how to work, the table routes which runbook applies.
- `pre-flight.md` / `code-review.md` — the `pre-flight` agent starts several rows' runbooks; `code-review` is the terminal step in several.
- `audit-routing.md` — the UI row references the audit pipeline doc; its cells don't restate the pipeline.
