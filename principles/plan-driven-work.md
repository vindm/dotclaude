# plan-driven-work — designing the spec → plan → impl → conformance workflow for ANY project

Teaching material for Claude Code. When you bootstrap a project's AI dev infrastructure, this doc teaches you HOW to install plan-driven discipline: the spec → plan → implementation → conformance-matrix workflow that prevents "tests green ≠ shipped" failure modes. Layer 3 of the v2 hierarchy.

## When to ship one (applicability gate)

Ship plan-driven discipline when:

- The project does multi-module changes regularly. Multi-module = touches > 3 files / > 2 layers (UI + API, frontend + backend, engine + vertical).
- The project has external users or external commitments. Shipping the wrong thing has consequences beyond your dev loop.
- The project has had at least one *"oh, we never actually built §4.2 of the spec"* moment after a major feature merge. That's the symptom.
- The project uses subagents for implementation. Without conformance discipline, subagent rollups become *"I think it's done"* with no audit trail.

Skip when:

- The project is a one-developer prototype with sub-1-week iteration cycles. Plan-driven overhead exceeds the discipline's value.
- All changes are 1-2 file diffs. The matrix audits multi-§ specs; there's no spec for a typo fix.
- The project's tests are robust enough that *"green tests"* is the actual shipped-bar (rare; most test suites have measurable gaps).

The default bias is **ship for non-trivial work, skip for trivial**. The threshold in CLAUDE.md should be specific: *"Plan-driven for anything > 1 day of work OR > 5 files touched"*. Below the threshold: bug fix / quick polish workflow.

## Why it matters — what this catches that nothing else does

Without plan-driven discipline, three failure modes recur:

- **70-85% shipped feels like 100%.** A subagent reports *"all sub-plans complete"* and the user trusts it. Months later a recruited user flags broken behavior — turns out §4.2 of the original spec was never implemented. The subagent reported against the *plan*, not against the *spec*. Plans routinely fail to fully encode specs. The conformance matrix audits spec → reality, which is what the user cares about.

- **"Tests green" becomes the silent ship-bar.** Tests cover what was thought of when tests were written; they don't cover *"did this implement what the spec said."* A test suite can be 100% green while the implementation diverges from spec in 5 places. Conformance matrix forces the comparison.

- **Subagent rollups replace human verification.** A subagent's *"done"* summary feels like an audit. It isn't — the subagent verified itself against its own plan, with all the same blind spots. The matrix is human-readable, human-reviewable. It's a separate work product.

The cost asymmetry: writing a conformance matrix is ~30-60 minutes per plan. Catching deviations *after* ship costs hours to days to weeks. Across a year of plan-driven projects, the matrix discipline pays for itself in the first month.

## Core methodology — the four-stage workflow

The workflow is **spec → plan → impl → conformance**. Each stage has its own artifact, lifecycle, and verification.

### Stage 1 — Spec

A spec is the *what* — what should exist after this work ships. Authored before the plan. Lives at `docs/specs/<slug>-spec.md` (or `docs/designs/<slug>-design.md`; pick one convention per project and stay consistent).

Spec structure:

- **Capability delta** — names which capability IDs (from `docs/product/capabilities.md`) this spec transitions. *"`O.3 [partial] → [shipped]`; `M.4 new`."* This is the first row; everything else is implementation detail under it.
- **§-section structure** — each section is a self-contained requirement. Numbered or named. *"§1 — Authentication flow. §2 — Session persistence. §3 — Logout cleanup."*
- **Acceptance criteria per §** — what does *"matches spec"* mean for this section? Written as falsifiable statements.
- **Out of scope** — explicit list of what this spec doesn't cover. Prevents scope creep during plan-writing.
- **Open questions** — flagged for resolution before plan-writing.

The spec is **stable during implementation**. Changes to scope mean a new spec version or a documented deviation. Don't silently move the spec.

### Stage 2 — Plan

The plan is the *how* — the multi-step roadmap that implements the spec. Authored after spec, before code. Lives at `docs/plans/<plan-slug>.md` or `docs/superpowers/plans/<plan-slug>.md`.

Plan structure:

- **Spec reference** — opens with *"Implements: docs/specs/<...>-spec.md"*. Without this, plans become orphan plans.
- **Task list** — sub-plans or numbered tasks. Each task has clear input, output, verification command.
- **Verification commands** — bash commands the user (or a subagent) runs after each task to confirm the task completed. *"After T3: `yarn test src/auth/`; expected: green."*
- **Definition of Done per task** — what does *"this task complete"* mean? Per-task DoD prevents *"I think it's done"* drift.
- **Sub-plan structure** — if the work is large, split into sub-plans (Plan 1, Plan 2, ...) per logical chunk. Each sub-plan has its own task list and DoD.

Plans get executed by either the user or a subagent. The plan is what the subagent reads; the spec is what gets audited later.

### Stage 3 — Implementation

The actual code-writing. Driven by the plan; verified per-task by the plan's verification commands. Most of the work effort lives here, but the *verification* and *audit* live in Stages 2 and 4.

Multi-file commits get verified after each commit with `git show --stat HEAD`. Lint-staged stash-and-restore occasionally desyncs the staged set — a 7-file stage can land as a 1-file commit while the message claims all 7. Recovery: `git reset --soft HEAD~1` (non-destructive), re-stage explicitly, recommit.

Subagent-driven execution: each task dispatches to a fresh subagent. The dispatching prompt prefixes `cd $WORKTREE && pwd && git branch --show-current` plus a STOP/BLOCKED instruction if branch is `main`. Without this, subagents occasionally commit to the wrong directory.

### Stage 4 — Conformance matrix

The matrix is the *spec ↔ reality* audit. It is **not optional**. *"Tests green"* is not a substitute. *"Subagent reports done"* is not a substitute. *"It looks right"* is not a substitute.

The matrix lives at `docs/audits/<plan-slug>-conformance.md`. Anatomy:

- **First row: capability delta** — lists capability IDs transitioned (`O.3 [partial] → [shipped]`, etc.). Survives spec-doc archiving.
- **§ rows** — one per spec section. Columns: spec §, assertion (one sentence), evidence (file paths + line ranges + screenshot links), verdict (`matches | deviates(why) | deferred(why)`), severity (CRIT / MAJ / minor — for deviations only).
- **CRIT/MAJ resolution block** — below the table, per-deviation: the resolution (fixed same change / shipped in follow-up commit / deferred to plan N+1 with rationale).
- **Screenshot directory** — captured screenshots referenced from the matrix, stored in `docs/audits/<plan-slug>-screenshots/`.

The matrix is **human-readable**, **human-reviewable**, **dated**. The user reads it, agrees or disagrees with verdicts, signs off. *Only then* is the work shipped.

## How to derive THIS project's specifics

Before authoring the plan-driven discipline rules, gather:

1. **The threshold for plan-driven**. Ask: *"What size of work makes you wish you'd written a plan first?"* Common answers: > 1 day / > 3 files / > 2 modules / > 1 conceptual surface. Encode the threshold in CLAUDE.md.

2. **The spec convention**. Does the project use `docs/specs/` or `docs/designs/`? Pick one. Stay consistent.

3. **The plan convention**. Does the project use the superpowers plan-writing skill (lands at `docs/superpowers/plans/`) or its own convention (`docs/plans/`)?

4. **The audit convention**. `docs/audits/<plan-slug>-conformance.md` is canonical, but some projects subdivide (`docs/audits/conformance/<plan-slug>.md`). Pick one.

5. **The screenshot policy**. Per-surface screenshots stored at `docs/audits/<plan-slug>-screenshots/` is canonical. Confirm with user — some projects use external image hosts.

6. **Subagent dispatch patterns**. Does the project use `superpowers:subagent-driven-development`? Worktrees? Git branches per task? Encode the dispatch convention in CLAUDE.md.

7. **The capability map state**. Is `docs/product/capabilities.md` populated? If yes, conformance matrices reference IDs from it. If no, scaffold first (see `knowledge-graph.md`).

## Authoring guidance — what to write into the final artifact

The plan-driven discipline lands in TWO places:

### Place 1 — `CLAUDE.md` task classification + DoD

The task classification table gets a row:

```markdown
| Plan-backed (spec/design-doc + sub-plans) | Implement per sub-plan → produce `docs/audits/<plan-slug>-conformance.md` (§section × `matches/deviates/deferred` + per-surface screenshots) BEFORE claim shipped → resolve CRIT/MAJ → only THEN declare done. Subagent rollup ≠ matrix. |
```

The Definition of Done gets entries:

```markdown
- **Plan-backed work: conformance matrix at `docs/audits/<plan-slug>-conformance.md` resolves every §section of the spec** (matches / deviates(why) / deferred(why) + per-surface screenshot). Required artifact before claiming shipped. First row is the capability-delta header — lists capability IDs from `docs/product/capabilities.md` that this plan transitions (e.g. `O.3 [partial] → [shipped]`, `M.4 new`). The capability-delta survives spec-doc archiving; §sections are implementation details under it. Subagent's "done" summary does NOT substitute.
- Multi-file commits verified via `git show --stat HEAD` after every `git commit`.
```

### Place 2 — `.claude/rules/plan-driven-work.md` (or merged into existing rules)

A 60-120 LOC rule capturing:

- The threshold for triggering plan-driven flow.
- The four-stage workflow with paths.
- The conformance matrix anatomy.
- The "subagent rollup ≠ matrix" non-negotiable.
- Cross-reference to capability map + audit dir conventions.

If the project's `CLAUDE.md` is already large (> 500 LOC), keep the rule file thin (50 LOC) and let CLAUDE.md table-of-contents it. If CLAUDE.md is small, fold the rule's body directly into CLAUDE.md's "How You Work" section.

## Depth signatures — what battle-tested looks like

The authored plan-driven discipline fails the depth bar if it lacks any of these signals.

1. **Spec exists at `docs/specs/<slug>-spec.md` before plan.** Plans without specs are orphan plans. Test: every plan opens with *"Implements: docs/specs/<...>-spec.md"*.

2. **Plan exists at `docs/plans/<plan-slug>.md` (or equivalent) referencing the spec.** Plans without verification commands per task become *"do these things, trust me"*. Test: every task in a plan has an explicit verification command.

3. **Conformance matrix at `docs/audits/<plan-slug>-conformance.md` exists BEFORE claim-shipped.** Not after. Test: search for the matrix file before declaring done. If absent, NOT shipped.

4. **First conformance matrix row is the capability delta.** Test: open any matrix; row 1 names capability IDs transitioned. If row 1 is a spec § instead, the matrix is missing its capability-delta header.

5. **Every § section of the spec has a matrix entry.** Count: number of §s in spec vs number of rows in matrix should match. Missing entries are silent deviations.

6. **CRIT and MAJ deviations have resolutions in the matrix.** Below the table, per-deviation, the resolution. Without resolutions, the matrix is informational, not actionable.

7. **Per-surface screenshots referenced from the matrix.** Each `matches` verdict points to a screenshot proving it matches. Each `deviates` points to a screenshot showing the deviation. Test: `ls docs/audits/<plan-slug>-screenshots/` is non-empty.

8. **Subagent rollups are NOT treated as conformance audits.** The DoD says explicitly *"Subagent's 'done' summary does NOT substitute."* Without this clause, the bar erodes.

9. **`git show --stat HEAD` is run after every multi-file commit.** Lint-staged corruption is real (a 7-file stage can land as 1-file commit). Verification is a 1-line bash command; running it is non-negotiable.

10. **Worktree gate is enforced on subagent dispatch.** *"cd $WORKTREE && pwd && git branch --show-current — STOP if main"* prefix on every implementer dispatch. Without this, subagents have lost partial work in the source project.

If the authored discipline lacks any of these, redo. Plan-driven work without the matrix is the workflow's name without its substance.

## Reference matrix example (universal shape)

```markdown
# Conformance matrix — <plan-slug>

**Implements:** docs/specs/<...>-spec.md
**Plan:** docs/plans/<plan-slug>.md
**Date:** YYYY-MM-DD
**Status:** SHIPPED | IN-REVIEW | BLOCKED

## Capability delta

| Capability ID | Transition |
|---|---|
| O.3 | [partial] → [shipped] |
| M.4 | new |

## § conformance

| Spec § | Assertion | Evidence | Verdict | Severity |
|---|---|---|---|---|
| §1 Auth flow | User can sign in with email + magic link | `app/auth/login.tsx:42-89` · screenshot: `01-login.png` | matches | — |
| §2 Session persistence | Session survives app relaunch within 30 days | `lib/auth/session.ts:15-50` · screenshot: `02-session-restored.png` | matches | — |
| §3 Logout cleanup | Logout clears keychain + IndexedDB | `lib/auth/logout.ts:8-32` · screenshot: `03-logout-state.png` | deviates(IndexedDB not cleared on iOS due to expo-secure-store quirk) | MAJ |
| §4.2 Session expiry banner | Show banner 24h before token expires | not implemented | deferred(low priority; tracked as M.4.1 for next plan) | — |

## CRIT/MAJ resolutions

- §3 MAJ: deviation accepted as known iOS quirk; tracked as feedback memory `feedback_expo_secure_store_indexeddb_cleanup.md`; fix scheduled for Plan-N+1.

## Screenshots

See `docs/audits/<plan-slug>-screenshots/`.
```

This matrix takes ~30 minutes to write for a typical 4-§ plan. The user reads it, signs off, ship is committed.

## Anti-patterns to avoid

- **"Tests green = shipped."** Tests cover what was thought of. Specs cover what was promised. They're different scopes. Conformance audits the spec.

- **Subagent rollup as conformance.** *"The subagent reports all sub-plans complete."* The subagent verified itself against its plan. The plan may not encode every spec §. The rollup is informational; the matrix is authoritative.

- **Matrix authored after declaring shipped.** *"I'll write the matrix retroactively."* By the time you write it, the impl is gone from working memory and you can't accurately verify. Matrix is written DURING the verification step, not after.

- **Matrix without screenshots.** *"It works; here's a 4-row table."* Visual surfaces need pixel evidence; without screenshots the verdict is *"I read the code and it looks right."* Read-the-code is what we're trying to escape.

- **Deviation entries without resolution.** *"§3 deviates because of iOS quirk."* OK — and? Was it fixed? Deferred to Plan-N+1? Accepted as known? Without resolution, the matrix is a list of known issues with no closure.

- **Plan without verification commands.** *"Task 4: implement auth."* OK — how do I know task 4 completed? Without `yarn test src/auth/` or equivalent, the subagent verifies itself against vibes. Verification commands convert vibes into truth-claims.

- **Spec changes during implementation without versioning.** *"The spec said X but actually we did Y."* That's a deviation. Document it. Don't silently update the spec to match the impl — that erases the audit trail.

- **Conformance matrix that doesn't reference the capability delta.** Without the capability delta row, the matrix is implementation detail. The capability delta is what survives the spec being archived; without it, future readers see audit results with no anchor.

- **Plan-driven discipline applied to 1-line typo fixes.** Overhead exceeds value. The threshold in CLAUDE.md should be specific (> 1 day / > 5 files / > 2 modules); below it, the bug-fix workflow applies.

- **One mega-matrix for a 20-spec multi-month effort.** Matrices become unreadable above ~10 §s. For large efforts, split the spec into sub-specs (Plan 1, Plan 2, ...) with one matrix per sub-plan. The composite is implicit in the union of sub-matrices.

- **Matrix that lives in a chat transcript instead of `docs/audits/`.** Chat transcripts are not searchable from future sessions. The matrix is a permanent artifact; it lives in the knowledge graph.

## Cross-references

- `knowledge-graph.md` — Layer 5. Specs live in `docs/specs/`; plans in `docs/plans/`; audits in `docs/audits/`. The knowledge graph must exist for plan-driven discipline to land.
- `task-classification.md` — Layer 3. The task classification table includes a "plan-backed" row routing to this workflow.
- `project-identity.md` — Layer 1. The DoD that gates plan-driven work lives in CLAUDE.md after identity. Identity sets the production-vs-internal context that drives how strict the matrix needs to be.
- `pre-flight.md` — Layer 6 planning kit. Runs before complex changes to surface risks; complements plan-driven discipline by sizing the work before plan is written.
- `code-review.md` — Layer 6 coding kit. Code review is the *implementation*-level check; conformance matrix is the *spec*-level check. Both run.
