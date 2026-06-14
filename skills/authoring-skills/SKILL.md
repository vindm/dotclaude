---
name: authoring-skills
description: How to write a skill or rule that survives refactors instead of rotting — bind to durable invariants and point at canonical sources, never mirror perishable snapshots (file:line cites, step-by-step flow prose, exhaustive rosters, copied code, bare counts). Load whenever you author or edit a skill, a rule, or any reference doc that names code paths, functions, components, or flow stages.
---

# Authoring skills — point, don't mirror

A skill or rule is loaded into context and *believed*. That is its whole value and its whole danger. So it must bind to things that stay true and never freeze a snapshot of things that move. A skill that *mirrors* the code is a copy that goes stale silently — and a silently-wrong skill is worse than no skill, because Claude trusts the lie and skips reading the code. A skill that *points* at the code stays correct: the pointer re-resolves after the code changes.

Three mirror failures recur, each hard to diagnose because the symptom shows up in output while the cause hides in a doc nobody re-reads: a cited file and line that a refactor moved; a step-by-step flow restated as prose after the pipeline was rearchitected; an "exhaustive" roster that someone added to or deleted from. The common thread is a frozen snapshot of a moving target.

## Sort every sentence before it goes in: durable invariant, or perishable snapshot?

Bind to the first. Never mirror the second.

**Bind to (durable — survives refactors):**
- Conventions and contracts — units, ordering, idempotency, null-handling. *"All money is stored in minor units."* *"The importer must be idempotent."*
- Gotchas and footguns — library quirks, non-obvious traps. The footgun is still a footgun after the file is renamed.
- Navigation — *"the auth logic lives under the auth module."* Point, don't transcribe.
- The WHY behind a decision — *"we queue writes because the API rate-limits."* The rationale outlives every line of the implementation.

**Never mirror (perishable — rots in one refactor):**
- Step-by-step flow prose that restates current code.
- `file.ts:142` line citations — any edit above the line invalidates it.
- Exhaustive rosters of components / functions / endpoints — an exhaustive list is a promise to stay exhaustive that nobody keeps.
- Copied code blocks duplicated from source — copies drift.
- Bare counts and values that drift — *"there are 7 widgets," "the limit is 3."*

## Point at canonical sources, don't copy their content

Name *where* the source of truth lives and let the reader resolve it. Don't paste token values — point at the token file. Don't transcribe the flow — point at its entry point: *"trace from the importer module."* Don't enumerate every component — point at the directory or index that *is* the roster. If the canonical thing changes, a pointer still resolves; a copy goes stale. A skill is a *map to* the durable structure of the project, not a *photograph of* its current state.

## Date and hedge any structural claim you must include

Sometimes a structural claim genuinely orients a reader fast even though the exact value may drift. When you must include one, mark it as perishable: *"as of <date>, the pipeline has four stages — verify against code before relying on this."* The date and hedge tell the next reader to trust the code over you. An undated claim masquerades as eternal truth; a dated one flags itself as a snapshot that may have expired.

## Before saving any skill or rule, confirm

- [ ] Zero raw `file.ts:line` cites (unless dated AND hedged).
- [ ] No code blocks copied from source — point at the source instead. (Illustrative pseudo-code that doesn't claim to *be* the source is fine.)
- [ ] No exhaustive roster — point at the index / directory.
- [ ] Flow described by entry point (*"trace from <here>"*), not restated step by step.
- [ ] Every structural count / value either omitted or dated-and-hedged.
- [ ] Every claim with a code denotation points at a real, current location.

If a skill fails any of these, redo it. A skill that mirrors is technical debt that accrues interest every refactor.
