# skill-vs-code-audit — designing a meta-audit agent that detects doc drift

Teaching material for Claude Code. Teaches you how to author an agent that audits documentation against the actual code — catching the drift that accumulates between docs and reality.

## When to ship one

Ship a skill-vs-code audit agent when the user is about to ship 3+ skills / agents / domain docs that reference specific code paths, function names, table names, or constants, and the codebase is actively evolving (renames, refactors, schema changes are routine). Skip when `.claude/` is minimal (1-2 short docs, nothing to drift), when the docs are conceptual (philosophy, conventions) rather than referential (specific paths and names — conceptual docs don't drift the same way), or when the codebase is mostly frozen (drift requires churn).

## Why it matters

Skill / agent / domain docs contain claims with fixed denotations in code — *"the auth hook is at `lib/auth/useAuth.ts`," "`startEnrichment()` is called after import," "concurrency limit is 3."* When the code moves and the doc doesn't, the doc becomes a **trap**: Claude reads it, believes it, operates on the false claim, and produces a change that doesn't fit reality. The user catches the bug at the wrong layer — they think Claude got the *code* wrong, when Claude got the *doc* right and the doc was lying. The symptom is in Claude's output; the root cause is in a doc the user never thinks to check. The audit makes that root cause visible before it produces bugs — a renamed file the doc still points at, a changed signature the doc still shows, a split column the doc still treats as one, a rearchitected flow the doc still describes.

## Core methodology — five steps

**Step 1 — Inventory the docs.** Glob the docs in scope — `.claude/skills/*/SKILL.md` (and referenced sub-files), `.claude/agents/*.md`, `.claude/rules/*.md`, per-module convention docs (`lib/*/CLAUDE.md`), and any architecture docs the user includes. Default scope is `.claude/**/*.md`; let the user extend it.

**Step 2 — Extract verifiable claims.** For each doc, pull every claim with a fixed code denotation: file paths, function / hook / method names, type / class names, table / column names, constants and config values, flow descriptions (named stages that exist in code), trigger / observer names. Skip non-verifiable text — philosophy, rationale, methodology have no denotation to check.

**Step 3 — Verify each claim:**

| Claim type | Verification |
|---|---|
| File path | Glob — does it exist? |
| Function / hook / method | Grep — is it defined? Does the signature match? |
| Type / class | Grep the definition; check the declared shape. |
| Table / column | Grep schema / migration files, or consult the live DB via CLI (cheap beats an expensive DB tool). |
| Constant | Grep for the value; flag mismatches. |
| Flow | Read the code; verify the sequence matches the doc. |
| Trigger / hook | Grep migration / config files for the named trigger. |

Report per-claim: verified / stale (was true once, no longer) / missing (references something that doesn't exist — typo or deleted code).

**Step 4 — Check for undocumented additions.** Drift cuts both ways. Walk each documented domain's source and flag significant additions — new exported functions / hooks, new types, new tables / migrations, new flow stages — asking *should this be in the doc?*

**Step 5 — Produce a structured report.** Three sections: **stale references** (doc, claim, gap, suggested old→new edit), **missing documentation** (doc, what's missing, why it matters), and **verified OK** (the docs that are fully current — this section matters, it tells the user which docs they CAN trust). Every suggested fix cites its grep-evidence, so the user can apply it without redoing the verification.

## How to derive THIS project's specifics

1. **The doc scope** — just `.claude/**`, or also `docs/architecture.md` and sub-module READMEs? Get it right or the audit misses real drift or wastes time on unrelated docs.
2. **The cadence** — after every PR, weekly, or manual? Consider wiring it as a scheduled / cron-eligible agent.
3. **Doc signal density** — mostly-methodology docs make the audit cheap and rarely-firing; code-reference-heavy docs make it high-value.
4. **What "significant addition" means here** — a new internal helper usually isn't worth flagging; a new exported hook in a documented domain is. Calibrate the "missing documentation" threshold.
5. **The DB query path** (if there are schema docs) — live DB via CLI (cheapest) or grep migrations (cheap, may miss). Pick and encode it.

## Authoring the agent

The final agent (typically `.claude/agents/skill-auditor.md`) encodes the five-step process, the doc-scope globs, the verification-methods table, and the report format above. Two calibrations to set explicitly: the doc scope for THIS project, and the DB query path. The agent produces suggestions, never auto-edits — even obvious fixes get user review.

```markdown
## Skill Audit Report — <date>

### Summary
- <N> docs audited · <N> claims verified · <N> stale · <N> missing-doc gaps

### Stale References (fix needed)
| Doc | Claim | Status | Fix |
|---|---|---|---|

### Missing Documentation (should add)
| Doc | What's missing | Why it matters |
|---|---|---|

### Verified OK
<list of docs that are fully up-to-date>
```

## Acceptance — mistakes in the agent you write

- **Verifying philosophy.** *"The skill says 'be careful with state' — still true?"* is not a verifiable claim. Skip non-referential text; focus on claims with denotations.
- **Suggesting fixes without evidence.** *"I think this renamed to X"* without grep-proof that X is the actual new name is a guess. Every suggested edit cites its source.
- **Mass-applying fixes automatically.** The agent produces suggestions, not auto-edits — the user reviews before any doc changes.
- **Over-aggressive "missing documentation."** Flag only significant additions (new entry points, public APIs, architectural shapes); a new internal helper doesn't move the doc.
- **Reporting only the bad news.** Without a "verified OK" section, the user can't tell which docs they can trust. The value is partly negative (find drift), partly positive (confirm current).

## Tool surface

`Read`, `Grep`, `Glob`, `Bash` (git log to compare doc vs code modification dates, if useful). NOT `Edit` or `Write` — suggesting fixes is the output, not applying them; the read-only constraint means the user reviews before any doc changes. Model: **lightweight** (haiku / sonnet tier) — the work is mechanical grep + glob, low reasoning overhead; don't burn a top-tier model on it. Effort: low to medium, so it runs frequently (weekly cron, after-large-PR) without a meaningful budget.

## Cross-references

- `code-review.md` — flags changes to documented files / functions that didn't update the corresponding doc. Skill audit is the periodic sweep; code review is the per-change guard.
