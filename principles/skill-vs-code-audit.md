# skill-vs-code-audit — designing a meta-audit agent that detects doc drift

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author an agent that audits documentation against the actual code — catching the drift that accumulates between docs and reality.

## When to ship one (applicability gate)

Ship a skill-vs-code audit agent when:

- The user is about to ship 3+ skills / agents / domain docs that reference specific code paths, function names, table names, or constants.
- The project codebase is **actively evolving** (renames, refactors, schema changes happen routinely).
- The user has experienced or anticipates "Claude operated on stale information from a skill doc and produced a buggy change."

Skip when:

- The project's `.claude/` is minimal — 1-2 short docs, no specific code references. There's nothing to drift.
- The docs are conceptual (philosophy, conventions) rather than referential (specific paths, names, constants). Conceptual docs don't drift the same way.
- The codebase is mostly frozen / mature. Drift requires churn.

## Why it matters — what this catches that nothing else does

Skill / agent / domain docs contain claims that look like:
- "The auth hook is at `lib/auth/useAuth.ts`"
- "`startEnrichment()` is called after import"
- "The job-types union is in `lib/jobs/types.ts`"
- "Concurrency limit is 3"

Each claim has a fixed denotation in the codebase. When the codebase moves and the doc doesn't, the doc becomes a **trap**: Claude reads it, believes it, operates on the false claim, and produces a change that doesn't fit reality. The user catches the bug at the wrong layer — they think Claude got the code wrong, when actually Claude got the doc right but the doc was lying.

The audit catches this drift before it produces bugs. The bugs it prevents are:

- "Claude tried to edit a file that no longer exists" — file path was renamed; doc not updated.
- "Claude called a function with the old signature" — function arguments changed; doc still has the old version.
- "Claude referenced a table column that's been split into two" — schema migration happened; doc unchanged.
- "Claude followed a flow that's been replaced" — pipeline rearchitected; doc describes the old shape.

These bugs are hard to diagnose because the symptom is in Claude's output, but the root cause is in a doc the user doesn't think to check. The audit makes the root cause visible.

## Core methodology — five steps

The agent walks a fixed five-step process:

### Step 1 — Inventory the docs

Glob for all docs in scope:
- `.claude/skills/*/SKILL.md` and any sub-files referenced
- `.claude/agents/*.md`
- `.claude/rules/*.md`
- Any per-module convention docs (`lib/*/CLAUDE.md`, `src/*/AGENTS.md`, etc.)
- Any top-level architecture docs the user wants included (`docs/architecture.md`, etc.)

The agent should let the user configure the scope. By default it audits `.claude/**/*.md`; the user can extend to other doc locations.

### Step 2 — Extract verifiable claims

For each doc, the agent extracts every claim that has a fixed denotation in code:

- **File paths**: `lib/auth/useAuth.ts`, `src/jobs/types.ts`, `modules/native-bridge/`
- **Function / hook / method names**: `startEnrichment()`, `useEnrichmentJob`, `process_jobs()`
- **Type / class names**: `JobType`, `AuthState`, `EnrichmentPayload`
- **Table / column / collection names**: `equipment_products.icon_url`, `users.is_admin`
- **Constants / configuration values**: "concurrency: 3", "retry limit: 5"
- **Flow descriptions**: "specs → icon → done" (the named stages exist in code)
- **Trigger / hook / observer names**: "DB trigger `trg_specs_job_complete`"

Claims that are NOT verifiable (philosophy, opinions, design rationale, methodology) are skipped — the audit is for claims with code denotations.

### Step 3 — Verify each claim

For each extracted claim:

| Claim type | Verification |
|---|---|
| File path | Glob — does it exist? |
| Function / hook / method | Grep — is it defined? Does the signature match? |
| Type / class | Grep for the definition; check the declared shape. |
| Table / column | Grep schema / migration files OR consult the live DB (CLI, not LLM-callable tool — see `database-query-discipline.md`). |
| Constant | Grep for the value; flag mismatches. |
| Flow | Read the actual code; verify the sequence matches the doc. |
| Trigger / hook | Grep the migration / config files for the named trigger. |

The agent reports per-claim: verified / stale / missing. "Stale" = was true once, no longer is. "Missing" = the doc references something that doesn't exist (could be a typo, could be deleted code).

### Step 4 — Check for undocumented additions

The drift cuts both ways: docs going stale, AND code being added without being documented. The agent walks the source directory for each documented domain and flags significant additions:

- New exported functions / hooks
- New types
- New tables / migrations
- New flow stages

For each, the agent asks: *should this be in the doc?* Significant additions that AREN'T in the doc are gaps the user should fix.

### Step 5 — Produce a structured report

The report has three sections:

1. **Stale references** — each with the doc, the claim, the gap, the suggested fix.
2. **Missing documentation** — each with the doc, what's missing, why it matters.
3. **Verified OK** — list of docs that are fully current. This section matters: it tells the user which docs DON'T need attention.

The report should be actionable. For stale references, the agent provides the exact old-text → new-text edit suggestion. The user can apply suggestions directly without re-doing the verification.

## What to verify vs. what to skip

The audit is fast. It does NOT:

- Re-verify methodology / principles (those don't drift in the same way).
- Check style / formatting of the docs (that's a different concern).
- Audit accuracy of opinions or design rationale (subjective).
- Validate that the docs are "good" — only that their factual claims match reality.

It DOES:

- Verify every file path / function name / type / table / constant claim.
- Flag any reference that fails the verification.
- Surface missing documentation for newly-added code.

The model choice should be **lightweight** (haiku-tier, sonnet-tier, equivalent). The work is mechanical grep + glob; reasoning overhead is low. Save the high-effort models for design / review where they pay off.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The doc inventory.** What documentation files exist that reference specific code? Just `.claude/**`? Or also `docs/architecture.md`, sub-module READMEs, etc.? Get the scope right or the audit either misses real drift or wastes time on unrelated docs.

2. **The cadence.** Does the user want this run after every PR? Weekly? Manually only? Configure accordingly — and consider whether to wire as a cron-eligible / scheduled agent.

3. **The signal-to-noise ratio of typical docs.** If the project's docs are mostly methodology and few specific references, the audit may be cheap and rarely produce findings. If the docs are heavy on code references, the audit produces a lot of value.

4. **What "significant addition" means in this project.** A new utility function in a domain doc isn't usually worth flagging. A new exported hook in a documented domain probably is. Calibrate the threshold for "missing documentation."

5. **The DB query path** (if the project has DB schema docs). Schema verification can use the live DB via CLI (cheapest) or grep migration files (cheap, may miss). Pick the path; encode it.

## Authoring the agent

The final agent (typically `.claude/agents/skill-auditor.md`) should specify:

1. **The five-step process** — inventory / extract / verify / undocumented-additions / report.
2. **The doc scope** — globs for the directories audited.
3. **The verification methods table** — claim type → verification command.
4. **The report format** — stale references / missing docs / verified OK.
5. **The model choice** — lightweight model is correct here.

## Output format

```markdown
## Skill Audit Report — <date>

### Summary
- <N> docs audited
- <N> claims verified
- <N> stale references found
- <N> missing documentation gaps

### Stale References (fix needed)
| Doc | Claim | Status | Fix |
|---|---|---|---|

### Missing Documentation (should add)
| Doc | What's missing | Why it matters |
|---|---|---|

### Verified OK
<list of docs that are fully up-to-date>

### Suggested Doc Updates
<for each stale doc, the exact old → new edit>
```

## Cross-references

- `code-review.md` — should flag changes to documented files / functions that didn't update the corresponding skill doc. Skill audit is the periodic sweep; code review is the per-change guard.
- `journey-mapping.md` — design / journey audits assume docs describe current flows; if the audit says the docs are stale, journey-mapping inherits the staleness.
- `database-query-discipline.md` — schema-claim verification should use CLI (cheap) not LLM-callable tools (expensive).

## Anti-patterns in the agent you write

- **Verifying philosophy.** "The skill says 'be careful with state' — is that still true?" — not a verifiable claim. The agent should skip non-referential text and focus on claims with denotations.

- **Re-grepping the same paths the user already corrected.** If a stale reference was fixed in a previous audit, the next audit shouldn't re-flag it (because it isn't stale anymore). The state is implicit in the docs themselves — re-running the audit against current docs will produce correct results.

- **Suggesting fixes without verification.** "I think this should be renamed to X" — without grep-evidence that X is the actual new name, the suggestion is a guess. Every suggested edit cites the source of the correction.

- **Mass-applying suggested fixes automatically.** Even if the fixes look obvious, the user should review them. The agent produces suggestions, not auto-edits.

- **Overly aggressive "missing documentation" findings.** Not every new function deserves a doc entry. Flag only significant additions (new entry points, new public APIs, new architectural shapes). A new internal helper doesn't move the doc.

- **Reporting only the bad news.** Without a "verified OK" section, the user can't tell which docs they CAN trust. The audit's value is partly negative (find drift) and partly positive (confirm what's current). Report both.

- **Running the heavy model.** This is mechanical work; haiku-class models do it correctly and cheaply. Don't burn opus on grep-and-glob.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash` (for git log to compare doc modification dates against code modification dates, if useful). It does NOT need `Edit` or `Write` — suggesting fixes is its output, not applying them. The structural read-only constraint is part of the value: the user reviews suggestions before any doc changes.

Model: lightweight. Effort: low to medium. The agent should be fast enough to run frequently — weekly cron, or after-every-large-PR — without burning a meaningful budget.
