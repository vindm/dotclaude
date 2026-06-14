# authoring-skills — "point, don't mirror," so skills age gracefully

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author skills that survive refactors instead of rotting the moment the code moves. It's a Layer 6 (Domain Kits) authoring concern, but it's cross-cutting: it governs EVERY skill in every domain — design, coding, data, testing, planning. The doctrine is one line: a skill should *point* at durable invariants, not *mirror* perishable snapshots of the current code. A skill that mirrors the code is a copy that goes stale silently; a skill that points at the code stays correct because the pointer re-resolves after the code changes.

## When to ship one (applicability gate)

Ship an authoring-skills rule whenever:

- The project authors **any skills at all** (`.claude/skills/*/SKILL.md`). The rule governs how those skills are written; if skills exist, the rule applies.
- The codebase is **actively evolving** — files get renamed, functions get resigned, components get deleted. Churn is what turns a mirror into a trap.
- The user has shipped (or will ship) **referential skills** — ones that name code paths, functions, components, constants, flow stages.

Skip when:

- The project authors **no skills** — pure rules + agents, nothing in `.claude/skills/`. Nothing to govern.
- The skills are **purely conceptual** — philosophy, conventions, methodology with zero code denotations. Conceptual content doesn't rot the same way (though even it benefits from the date-and-hedge habit).

The default bias is **ship**. The rule is one short file, it costs almost nothing, and it prevents the single most common skill failure: the confidently-wrong skill. A skill that's silently lying is worse than no skill — with no skill, Claude reads the code; with a wrong skill, Claude trusts the lie and skips the code.

## Why it matters — what this catches that nothing else does

A skill is loaded into context and *believed*. That's its whole value and its whole danger. When a skill mirrors the code, three failure modes recur, and each one is hard to diagnose because the symptom shows up in Claude's output while the root cause hides in a doc nobody thought to re-read:

- **The skill cites a file and line that moved.** The skill says *"the rate limiter lives in `lib/net/limiter.ts:142`."* A refactor split that file months ago. Claude reads the cited location, finds something unrelated (or nothing), and either edits the wrong place or hallucinates around the gap. The line number was perishable the instant it was written — any edit above line 142 invalidates it.

- **The skill mirrors a flow that changed.** The skill restates a step-by-step procedure: *"first the request hits the validator, then the normalizer, then the dispatcher."* The pipeline was rearchitected; the normalizer is gone. Claude follows the dead procedure, produces a change shaped for the old flow, and the change doesn't fit reality.

- **An exhaustive roster goes stale.** The skill lists *"the available widgets: A, B, C, D, E."* Someone deleted D and added F. Claude, trusting the roster, recommends building on D (which no longer exists) and never reaches for F (which the roster never mentioned). An exhaustive list is a standing promise to keep it exhaustive — a promise nobody keeps.

The common thread: the skill froze a snapshot of a moving target. Pointing instead of mirroring is what makes a skill robust to exactly this churn.

## Core methodology — invariants vs snapshots

The whole discipline is a sorting problem. Before any sentence goes into a skill, ask: *is this a durable invariant or a perishable snapshot?* Bind to the first; never mirror the second.

| Bind to this (durable — survives refactors) | Never mirror that (perishable — rots in one refactor) |
|---|---|
| Conventions — *"all money is stored in minor units (cents)"* | Step-by-step flow prose that restates current code |
| Contracts — *"the importer must be idempotent"* | `file.ts:142` line citations |
| Gotchas / footguns — *"this library doesn't reset on `undefined`"* | Exhaustive component / function / endpoint rosters |
| Navigation — *"the auth logic lives under the auth module"* | Copied code blocks duplicated from source |
| The WHY behind a decision — *"we queue writes because the API rate-limits"* | Counts and values that drift (*"there are 7 widgets," "limit is 3"*) |

Invariants are the things that stay true *across* a refactor because they describe intent, not implementation. The footgun is still a footgun after the file is renamed. The contract still holds after the function is rewritten. The "why" outlives every line of the "how."

### The pointer mechanism

Instead of copying a canonical thing's *content* into the skill, name *where it lives* and let the reader resolve it:

- Don't paste the token values — point at the token file: *"semantic tokens are defined in the theme source; read it for current values."*
- Don't transcribe the flow — point at the entry point: *"the import pipeline starts at the importer module; trace from there."*
- Don't enumerate every component — point at the index: *"see the component directory / its README for the current roster."*

If the canonical thing changes, a pointer still resolves to the right place; a copy goes stale silently. This is the entire mechanism. A skill is a *map to* the durable structure of the project, not a *photograph of* its current state.

### Date and hedge any structural claim you must include

Sometimes a structural claim genuinely helps — *"there are roughly four surface layers"* orients a reader fast even though the exact count may drift. When you must include a perishable claim, mark it as perishable: write it as *"as of <date>, the pipeline has four stages — verify against the code before relying on this."* The date and the hedge tell the next reader (human or Claude) *"this is a snapshot, trust the code over me."* An undated structural claim reads as eternal truth; a dated one reads as a note that may have expired. The difference is whether a stale claim quietly misleads or loudly flags itself.

### Ties to maintenance

A `skill-auditor`-style agent (see `skill-vs-code-audit.md`) mechanically re-verifies skill claims against code — does this path exist, does this function have this signature, does this flow still run in this order. "Point, don't mirror" is what makes most skills **audit-clean by construction**: a skill that points at canonical sources and carries no raw file:line cites has almost nothing for the auditor to flag, because it made very few falsifiable snapshot-claims in the first place. The two practices are complements: this rule reduces the drift surface up front; the auditor sweeps whatever drift remains.

## How to derive THIS project's specifics

Before authoring the rule, gather:

1. **The durable invariants this project actually has.** Walk the codebase (or ask the user) for the three kinds that matter: **boundaries** (which module owns what; where the seams between layers are), **contracts** (idempotency, ordering, units, null-handling — the promises code must keep), and **footguns** (the library quirks and non-obvious traps the team has hit). These are what the project's skills should bind to.

2. **Where the canonical sources live to point AT.** For each domain a skill might cover, find the single source of truth to point at instead of copying: the token file, the schema / migrations directory, the types module, the pipeline entry point, the component index or its README. A pointer is only useful if it names a real, stable location — get these paths right.

3. **Whether a skill-auditor runs.** Check `.claude/agents/` for a `skill-auditor` (or equivalent). If one exists, the rule should reference it as the backstop. If none exists, note that "point, don't mirror" is doing the drift-prevention work *alone* — which raises the stakes on following it — and flag the auditor as a roadmap item.

## Authoring guidance — what to write into the final artifact

The rule lands at `.claude/rules/authoring-skills.md` in the target project. It's short on purpose — a checklist the skill author reads before saving any skill. Author it roughly like this:

```markdown
# Authoring skills — point, don't mirror

A skill is loaded into context and believed. So it must bind to things that
stay true, and never freeze a snapshot of things that move.

## Bind to (durable — survives refactors)
- Conventions and contracts (units, ordering, idempotency, null-handling).
- Gotchas and footguns (library quirks, non-obvious traps).
- Navigation — "the X logic lives under <module>." Point, don't transcribe.
- The WHY behind a decision — the rationale outlives the implementation.

## Never mirror (perishable — rots in one refactor)
- Step-by-step flow prose that restates current code.
- `file.ts:142` line citations.
- Exhaustive rosters of components / functions / endpoints.
- Copied code blocks that duplicate source.
- Bare counts and values that drift ("there are 7 widgets").

## Point at canonical, don't copy
Name where the source of truth lives; let the reader resolve it. If it
changes, a pointer still resolves; a copy goes stale silently.

## Date and hedge any structural claim you must include
Write it as: "as of <date>, <claim> — verify against code." A dated claim
flags itself as a snapshot; an undated one masquerades as eternal truth.
```

Then add the pre-save checklist the author runs before committing any skill:

```markdown
## Before saving a skill, confirm:
- [ ] Zero raw `file.ts:line` cites (unless dated AND hedged).
- [ ] No code blocks copied from source — point at the source instead.
- [ ] No exhaustive roster — point at the index / directory.
- [ ] Flow described by entry point ("trace from <here>"), not restated step-by-step.
- [ ] Every structural count / value either omitted or dated-and-hedged.
- [ ] Every claim with a code denotation points at a real, current location.
```

## Depth signatures — what battle-tested looks like

The authored rule (and the skills it governs) fail the depth bar if they lack any of these:

1. **Skills contain zero raw `file:line` cites** — except ones that are explicitly dated AND hedged. A bare line number is a guaranteed-to-rot claim.

2. **Skills point at canonical sources** instead of copying their content — the token file, the schema, the pipeline entry point, the component index. Every "where the X lives" is a pointer, not a transcription.

3. **No copied code blocks that duplicate source.** If a snippet exists verbatim in the codebase, the skill names where it lives instead of pasting it. (Illustrative pseudo-code that doesn't claim to *be* the source is fine.)

4. **No exhaustive rosters.** Lists of "all the X" are replaced by a pointer to the directory or index that *is* the roster.

5. **Every structural claim is dated and hedged**, or omitted. No undated "the pipeline has N stages" sitting in the skill as if it were permanent.

6. **A `skill-auditor` exists or is on the roadmap.** Either the backstop is wired (and the rule references it) or its absence is acknowledged as a gap to close — see `skill-vs-code-audit.md`.

If the authored skills fail any of these, redo them. A skill that mirrors is technical debt that accrues interest every refactor.

## Anti-patterns to avoid

- **The step-by-step mirror.** Restating the current code's procedure as prose — *"first it validates, then it normalizes, then it dispatches."* The moment the flow changes, the skill describes a procedure that no longer runs. Point at the entry point and say "trace from here."

- **The `file:line` cite.** *"See `lib/net/limiter.ts:142`."* Line numbers are the most perishable claim there is — any edit above the line invalidates it. Name the file and the symbol, not the line; or, if the location genuinely matters, date-and-hedge it.

- **The exhaustive roster.** *"The available widgets are A, B, C, D, E."* An exhaustive list is a promise to keep it exhaustive that nobody keeps. Point at the directory or index that *is* the canonical list.

- **The copied code block.** Pasting a function body or config object straight from source into the skill. It's a copy; copies drift. Point at the source file and let the reader read the current version.

- **The undated structural claim.** *"The pipeline has four stages."* Stated flatly, it reads as eternal truth and silently misleads once a fifth stage lands. If you must state it, date-and-hedge it: *"as of <date>, four stages — verify against code."*

## Cross-references

- `design-system-reference-skill.md` — the closest sibling: how to author the design-system entry-point skill. That skill is exactly where "point, don't mirror" gets tested hardest — it's tempting to transcribe every token and component; instead, point at the token file and the primitive paths, and date-and-hedge any structural table.
- `skill-vs-code-audit.md` — the drift-detection backstop. "Point, don't mirror" reduces the drift surface up front; the `skill-auditor` sweeps what remains. Authoring this way makes most skills audit-clean by construction.
- `knowledge-layers.md` — the same anti-staleness instinct applied to `docs/` rather than skills: code is truth, reflection docs describe it and point into the codebase instead of duplicating content that would drift.
- `memory-system.md` — the memory counterpart: don't save facts that are derivable from code. A fact mirrored into memory rots exactly like a fact mirrored into a skill; save decisions and rationale (durable), not snapshots (perishable).
- `saturday-ritual.md` — the periodic maintenance ritual where the `skill-auditor` and other sweeps run, catching whatever drift slipped past the authoring discipline.
