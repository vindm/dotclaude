---
name: plan-driven-work
description: The spec → plan → implementation → conformance-matrix workflow for non-trivial work — prevents the "tests green ≠ shipped" and "subagent reported done ≠ verified" failure modes. Use when a task crosses from in-head reasoning into a written plan: roughly more than a day of work, or several files / more than one module / one conceptual surface. Skip for 1-2 file diffs and typo fixes.
---

# Plan-driven work — spec, plan, impl, conformance

For non-trivial work, "tests pass" and "the subagent reported done" are not the ship-bar. Tests cover what was thought of when they were written; a subagent verifies itself against its own plan, with all the same blind spots; and plans routinely fail to fully encode the spec, so 70-85% shipped feels like 100% until a real user hits the gap months later. The conformance matrix is the separate, human-readable audit of spec against reality — what the user actually cares about. It costs roughly half an hour to write and pays for itself the first time it catches a deviation before ship.

**Threshold.** Cross into this workflow when the task is more than about a day of work, or touches more than a few files / more than one module / more than one conceptual surface. Below that, the quick bug-fix / polish loop applies — don't impose plan-driven overhead on a one-line change.

## The four stages

**1 — Spec (the *what*).** What should exist after this work ships. Authored before the plan, kept stable during implementation (scope changes mean a documented deviation or a new version, never a silent edit). Lives under the project's spec/design convention. Structure:
- **Capability delta** — first row; which capability IDs this transitions (e.g. `<id> [partial] → [shipped]`, `<id> new`). Everything else is detail under it.
- **§-sections** — each a self-contained requirement, numbered or named.
- **Acceptance criteria per §** — falsifiable statements of what "matches spec" means.
- **Out of scope** + **Open questions** — explicit, to prevent creep and to resolve before plan-writing.

**2 — Plan (the *how*).** The multi-step roadmap implementing the spec. Authored after the spec, before code. Opens with *"Implements: <spec path>"* — a plan without a spec reference is an orphan plan. Each task carries a clear input, output, a **verification command** to confirm it completed (*"after this task: run <the project's test command on the touched area>; expected: green"*), and a per-task Definition of Done. Large work splits into sub-plans, each with its own task list and DoD.

**3 — Implementation.** Code written per the plan, verified per-task by the plan's verification commands. After every multi-file commit, confirm the staged set actually landed (`git show --stat HEAD`) — staged-file desync is real and a multi-file stage can land as a one-file commit while the message claims all of them. Recovery: soft-reset, re-stage explicitly, recommit. When dispatching implementation to a subagent, prefix the dispatch with a working-directory verify-and-STOP gate (`cd <dir> && pwd && git branch --show-current`, stop if it's the wrong branch).

**4 — Conformance matrix (spec ↔ reality).** Not optional. "Tests green," "subagent reports done," and "it looks right" are NOT substitutes. Authored *during* the verification step, not retroactively (by then the implementation is gone from working memory). Lives under the project's audit convention. Anatomy:
- **First row: capability delta** — the IDs transitioned; survives the spec doc being archived.
- **§ rows** — one per spec section: spec §, a one-sentence assertion, evidence (paths + a screenshot link for any visual surface), verdict (`matches` / `deviates(why)` / `deferred(why)`), and severity for deviations.
- **CRIT/MAJ resolution block** — per deviation, the resolution: fixed in this change / shipped in a follow-up / deferred to a later plan with rationale.

The matrix is human-readable, human-reviewable, and dated. The user reads it, agrees or disagrees with the verdicts, and signs off — *only then* is the work shipped.

## Before declaring shipped, confirm

- [ ] A spec exists and the plan opens with *"Implements: <spec>"*.
- [ ] Every plan task has an explicit verification command.
- [ ] A conformance matrix exists (search for it before declaring done — if absent, NOT shipped).
- [ ] The matrix's first row is the capability delta.
- [ ] Every § of the spec has a matrix row; counts should match (missing rows are silent deviations).
- [ ] Every CRIT/MAJ deviation has a resolution.
- [ ] Every visual surface verdict points at a screenshot.
- [ ] Multi-file commits were checked with `git show --stat HEAD`.

A subagent's "done" summary does NOT substitute for the matrix. Plan-driven work without the matrix is the workflow's name without its substance.
