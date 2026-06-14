---
name: iterative-polish-autoloop
description: Drive a multi-screen flow from raw to award-quality through a bounded iterative loop — reset to a clean fixture, capture every state, grade across three scrutiny layers (reviewer agent + composition scan + backend-truth probe), apply ONE highest-ROI fix, commit atomically, re-run — until award-quality OR a hard iteration cap. Invoke for iterative UI/UX polish on a flow with an auto-capture harness.
---

# Iterative polish autoloop

A single audit produces a verdict; a verdict is not a polished flow. This skill closes the loop: each iteration produces a measurable grade delta, one fix at a time, with backend-truth verification at every step. It exists because, without the loop, polish stalls at "B+ feels good enough", per-iteration fixes regress other screens, fixes batch into un-attributable PRs, composition-level bugs survive macro grading, and the UI ships claims the backend contradicts.

**Purpose:** drive a flow from raw to award-quality through tight iterative loops. Each iteration: drive end-to-end on a clean fixture → capture every state → grade ruthlessly → pick ONE highest-ROI fix → apply + commit atomically → schedule next.

## Derive this project's inputs first

Read the project at runtime to resolve these — do not assume:
- **Fixture reset command** — the seed/cleanup that returns a known clean state.
- **Flow capture harness** — the auto-driver (Maestro YAML chain / Playwright spec / a shell script) that runs the flow without user input.
- **Reviewer agent** — the L1 grader for multi-screen flows (or the single-screen UX reviewer when drilling down).
- **Backend-truth probe queries** — 3–5 project-specific SQL/API calls, each with a known-good shape; deviation = a bug.
- **Semantic-count audit patterns** — where a rendered count can lie for this project (pipeline-subset vs user truth on generative surfaces; filter-scoped vs unfiltered counts on dashboards).
- **Iteration caps** — a hard cap (the budget ceiling, e.g. 10) and a soft cap (pivot-or-escalate trigger, e.g. 6).
- **Audit report dir** — where reports, ledger, and captures land.
- **Safety invariants** — the do-not-edit list (migrations, the package manifest, the design-token structure, fixture files, the capture-harness file itself except sanctioned navigation fixes).
- **Quality bar / design-north-star** — read the project's stated quality reference to anchor what "award-quality" means; do not hardcode benchmark apps.

## Three layers of scrutiny — every iteration runs all three

Skipping any one is a known cause of plateau or regression.

### Layer 1 — Reviewer agent (macro)

Invoke the project's reviewer agent with the capture manifest. It grades per-screen quality plus flow-level dimensions a per-screen lens can't see: voice consistency, CTA-weight progression, loading vocabulary, disclosure pacing, color drift, progress legibility. Reviewers grade each screen against a benchmark, not against itself — hence Layer 2.

### Layer 2 — Composition scan (micro)

Open 2–3 key screenshots yourself and run the project's composition pitfalls (duplication / orphan elements / tone mismatch / hierarchy violations / residue) **before** trusting the reviewer verdict — this catches what the reviewer misses.

**Plus the semantic-count audit.** For every count rendered to the user (`1/4`, `3/3`, `Processing 2`, `N items ready`):
- **Name the denominator.** Is it "total items the user would count" (user truth) or "the job's scoped subset" (job truth)?
- **If the denominator is a job-scoped subset, the count lies.** Users count their physical items, not pipeline nodes. A green `1/1` on a stage that processed 1 of 4 reads as "all done" when reality is "3 of 4 missing".
- **Cascade corollary (composed/DAG pipelines):** when an upstream stage soft-failed, downstream stages must NOT render the surviving subset as a green checkmark — render `{eligible}/{totalUserCount} · {blocked} blocked by upstream` in muted amber.
- **Fix pattern:** every count's denominator = the thing the user would count; numerator = actual persisted coverage; when numerator < total due to cascade blocking, surface the block count.

Ask on every screenshot: *"If a user glanced at this number for 2 seconds and answered 'am I done?', would their answer match backend reality?"* If no → semantic-count violation → flag immediately. Non-negotiable on generative surfaces — composition polish is meaningless if the numbers themselves lie.

### Layer 3 — Backend-truth probe

For generative or data-dependent surfaces, probe what the pipeline actually produced via this project's probe queries. Coverage probe (rows with a null/empty enriched field) and job-state probe (recent job rows: type, status, result payload). Hunt these anti-patterns:
- **Silent-success** — `status='success'` but persisted output is partial or zero. Never trust `job.status` alone; derive from persisted state + soft-failure markers + a `partial` UI status.
- **Silent-queue** — `status='queued'` that never transitions; surface via a queued-too-long amber chip.
- **Mutation race** — multiple writes to the same field race because requests don't serialize; mitigate by carrying the accumulator on every intermittent write, or fix architecturally (progress in a separate column / serialize by mutation key).
- **"Add X" CTA during an active pipeline** — suppress the CTA while a job is enriching the same field.
- **Semantic-color abuse** — amber = actionable warning, not "still generating"; red = hard error, not "soft fail on 1 of N".
- **Server mutation without cache invalidation** — rows persist, the client cache keyed on them isn't invalidated, the screen renders empty.
- **Bundle / device-target staleness** — the capture harness targets a different device than where the fix landed.

When a bug appears, **trace end-to-end and cite a file:line root cause** — do not hypothesis-spam ("could be A, could be B"); that wastes the loop's budget.

## Orchestration loop (per iteration)

1. **Sanity gate** — the dev-server / device target is the expected one; `git status` matches the last commit.
2. **Reset** — run the fixture reset.
3. **Mint IDs** — `RUN_ID=$(date -u +%Y-%m-%d_%H-%M-%SZ)`; report dir = `<audit-dir>/R<N>-$RUN_ID`.
4. **Apply one fix** from the prior iteration's report. Lint + type-check baseline must hold.
5. **Capture** — run the capture harness on the clean fixture.
6. **Layer 2 scan (operator-driven)** — open 2–3 key screenshots, run the composition pitfalls + semantic-count audit, BEFORE invoking the reviewer.
7. **Layer 1 grade** — invoke the reviewer agent with the manifest.
8. **Layer 3 probe** — run the backend-truth queries.
9. **Write report** — merge L1+L2+L3 into `$REPORT_DIR/report.md`.
10. **Pick next fix** — highest-ROI; apply a priority multiplier for generative-surface / backend-truth fixes.
11. **Commit atomically** — one fix, one commit, e.g. `audit(<flow>): R<N-1>→R<N> <fix>`.
12. **Update ledger** — append to the autoloop log.
13. **Schedule next** (if not terminating) — re-run on the same flow.

## Report shape

```markdown
## Autoloop R<N> — <flow> — <RUN_ID>
### Sanity gate
- Device target: <expected vs detected>   - Git status: <clean vs dirty>
### Fix applied this iteration
<one paragraph + commit SHA>
### L1 — Reviewer grade
<flow grade + per-screen table>
### L2 — Composition scan
- Duplication / orphan / tone mismatch / hierarchy / residue: <found / clean each>
- Semantic-count audit: <per count: denominator named, verdict>
### L3 — Backend truth probe
- <query: result + verdict> (one line each)
### Regression delta vs R<N-1>
<per-screen delta table + paragraph>
### Next fix (highest-ROI)
<single concrete move + ROI rationale>
```

Plus an append-only ledger row per iteration: `| R<N> | <focus> | <files touched> | <grade delta> | <commit SHA> |`.

## Rules and protocols

- **One fix per iteration, committed atomically.** No batching — five fixes in one commit means no grade-delta attribution and no learning.
- **Iteration caps are real.** The hard cap is the budget ceiling; respect it. The soft cap triggers pivot-or-escalate.
- **Plateau is NOT a stop.** If the grade plateaus at B+/A- for two iterations, diagnose the cause — reviewer miscapture, harness flakiness, or wrong fix target — and pivot.
- **Mid-iteration user message** — finish the current iteration cleanly, then stop: classify the surfaced bug, fix it now or park it, and acknowledge the miss. Don't ignore user input mid-cycle.
- **Termination** — flow grade S + every generative screen S + state-clarity dimensions S + backend counts clean; OR the hard iteration cap; OR a hard failure; OR a new user message.
- **Safety invariants (locked)** — never edit migrations, the package manifest, the design-token structure, fixture files, or the capture harness (except sanctioned navigation fixes). Every fix passes lint + type-check; every commit atomic; backend schema changes go through the project's migration tool only.
- **Never auto-run escalation.** When a fix needs architectural work (e.g. a mutation-race → progress-in-separate-column migration), park it in a `next_design_required.md` note and recommend the pre-implementation validation path — never auto-run a migration.

If the project has generative surfaces, every such surface must answer four questions at every moment: is it working right now, on what specifically, is anything failing, and how does the user know when it's done. A surface that can't answer all four is not award-quality yet.
