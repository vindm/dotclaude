# iterative-polish-autoloop — designing a continuous iterative UI polish loop for ANY project

Teaching material for Claude Code. Teaches you how to author the **user-invocable autoloop skill** that drives a flow end-to-end on a clean fixture, grades ruthlessly, picks ONE highest-ROI fix, applies + commits atomically, and re-runs — until award-quality or an iteration cap. It layers three scrutiny dimensions: a reviewer agent, a composition scan, and a backend-truth probe.

## When to ship one

Ship an iterative-polish-autoloop skill when the project has multi-screen arcs worth polishing iteratively (onboarding / setup / checkout / a generative pipeline), a capture harness that drives the flow without user input (Maestro / Playwright), a reviewer agent that grades the captured artifacts (`flow-audit` mode (b) is the standard L1 grader), a fixture-reset mechanism so each iteration starts from a known state, and an offensive quality posture ("polish toward award-quality"). Skip when there's no capture harness (the loop has no input), single-shot audits cover the need (use the reviewer directly), the posture is "ship and iterate," or the work is single-screen (use `ux-audit`).

## Why it matters

A single audit produces a verdict; a verdict isn't a polished flow. Without an autoloop: polish stalls at "B+ feels good enough" (no iteration discipline); per-iteration regressions slip in (no regression-delta check); fixes batch into "polish PRs" (no way to attribute grade delta); composition-level bugs survive macro grading (reviewers grade each screen against a benchmark, not against itself); backend truth diverges from UI claims ("all done" while the backend says "3 of 4 missing"); and iteration runs forever without caps. The value is **closed-loop quality drive** — each iteration produces a measurable grade delta, one fix at a time, with backend-truth verification at every step.

## Core methodology — three layers of scrutiny per iteration

Every iteration runs ALL THREE; skipping any one is a known cause of plateau / regression.

**Layer 1 — Reviewer agent (macro).** `flow-audit` mode (b) for multi-screen arcs, `ux-audit` for single-screen drilldowns — grades per-screen quality + flow-level dimensions (voice, CTA progression, loading vocab, disclosure pacing, color drift, progress legibility). Reviewers are excellent at macro tone but **blind to composition-level duplication** (they grade each screen against a benchmark, not against itself) — hence L2. When aggregating verdicts across agents, use the cross-rubric table in `audit-routing.md`; don't reinvent the S↔Crit↔S0 mapping per iteration.

**Layer 2 — Composition scan (micro).** Apply `quality-rubric.md`'s five pitfalls (duplication / orphan / tone mismatch / hierarchy / residue) on every screenshot before accepting the reviewer verdict. **Plus the autoloop-specific semantic-count audit:** for every count rendered to the user (`1/4`, `3/3`, `N ready`), name the denominator — is it "total items the user would count" or "the job's scoped subset"? *If it's a job-scoped subset, the count LIES* (users count physical items, not pipeline nodes; a green `1/1` on a stage that processed 1 of 4 reads as "all done" when reality is "3 of 4 missing"). Cascade corollary for DAG pipelines: when an upstream stage soft-fails, downstream must NOT render the surviving subset as a green checkmark — render `{eligible}/{totalUserCount} · {blocked} blocked by upstream` in muted amber. The test on every screenshot: *"if a user glanced at this number for 2 seconds and answered 'am I done?', would their answer match backend reality?"* No → flag immediately. NON-NEGOTIABLE on generative surfaces — composition polish is meaningless if the numbers lie.

**Layer 3 — Backend truth probe.** For generative / data-dependent surfaces, probe what the pipeline actually produced via `BACKEND_TRUTH_PROBE_QUERIES` (a coverage probe for null/empty output; a job-state probe for `type, status, result_json`). Look for the anti-patterns below.

## Anti-patterns to hunt actively

Project-specific by `BACKEND_TRUTH_PROBE_QUERIES` content, but the patterns generalize:

- **Silent-success** — `status='success'` but persisted state is partial. Never let the UI trust `job.status` alone; derive from persisted state + soft-failure markers in `result_json.<stage>_failed[]` + a `partial` UI status.
- **Silent-queue** — `status='queued'` never transitions; surface via a queued-too-long amber chip.
- **Mutation race** (React Query / SWR) — multiple `.mutate` calls on the same field race because HTTP requests don't serialize. Mitigation: every intermittent write carries the accumulator; architectural fix: progress in a separate column, or serialize via `mutationKey`.
- **"Add X" CTA during an active pipeline** — when a job is enriching the same field the CTA would populate, suppress the CTA.
- **Semantic color abuse** — amber = actionable warning, NOT "still generating"; red = hard error, NOT "soft fail on 1 of N."
- **Bundle / device-target staleness** — the capture harness targets a different device than where the fix landed; sanity-gate the dev-server target every iteration.
- **Hypothesis-spam over tracing** — trace end-to-end and cite a file:line root cause before responding; "could be A, B, or C" wastes the loop.
- **Server mutation without query invalidation** — rows persist, the client cache keyed on them isn't invalidated, the screen renders empty.

## Orchestration loop (per iteration)

1. **Sanity gate** — `DEVICE_TARGET_DETECT_COMMAND` returns the expected device; `git status` matches the last commit.
2. **Reset** — run `FIXTURE_RESET_COMMAND`.
3. **Mint IDs** — `RUN_ID` from a timestamp; `REPORT_DIR=<AUDIT_REPORT_DIR_CONVENTION>/R<N>-$RUN_ID`.
4. **Apply one fix** from the prior report; lint + type-check baseline must hold.
5. **Capture** — run the capture harness.
6. **Layer 2 scan (operator-driven)** — open 2-3 key screenshots, run the 5 pitfalls + semantic-count audit BEFORE invoking the reviewer. This catches what reviewers miss.
7. **Layer 1 grade** — invoke the reviewer with the manifest.
8. **Layer 3 probe** — run `BACKEND_TRUTH_PROBE_QUERIES`.
9. **Write report** — merge L1+L2+L3 into `$REPORT_DIR/report.md`.
10. **Pick next fix** — highest-ROI, with an ROI multiplier for generative-surface / backend-truth fixes per project priority.
11. **Commit atomically** — `audit(<flow>): R<N-1>→R<N> <fix>`.
12. **Update ledger** — append to `AUTOLOOP-LOG.md`.
13. **Schedule next** (if not terminating).

## How to derive THIS project's specifics

Fill: **`FIXTURE_RESET_COMMAND`** (the seed pipeline), **`FLOW_CAPTURE_HARNESS`** (the auto-driver), **`REVIEWER_AGENT_NAME`** (default `flow-audit` mode (b); `ux-audit` for single-screen), **`BACKEND_TRUTH_PROBE_QUERIES`** (3-5 queries, each with a known-good shape), **`SEMANTIC_COUNT_AUDIT_PATTERNS`** (when a UI count lies here), **`ITERATION_CAP_HARD`** / **`ITERATION_CAP_SOFT`** (e.g. 10 / 6 — the budget ceiling and the pivot trigger), **`AUDIT_REPORT_DIR_CONVENTION`** (where reports + ledger + captures land), and **`SAFETY_INVARIANTS`** (the do-not-edit list: migrations, package.json, tokens structure, fixture files, the capture-harness YAML).

## Report format

```markdown
## Autoloop R<N> — <flow> — <RUN_ID>

### Sanity gate: <device expected vs detected · git clean vs dirty>
### Fix applied this iteration: <summary + commit SHA>
### L1 — Reviewer grade: <flow grade + per-screen table>
### L2 — Composition scan
- Pitfalls 1-5 (duplication / orphan / tone / hierarchy / residue): <found / clean>
- Semantic-count audit: <per count, denominator named, verdict>
### L3 — Backend truth probe: <per query, result + verdict>
### Regression delta vs R<N-1>: <per-screen delta table + paragraph>
### Next fix (highest-ROI): <single move + ROI-multiplier rationale>
```

Plus the append-only ledger row: `| R<N> | <focus> | <files touched> | <grade delta> | <commit SHA> |`.

## Authoring the skill

The final skill (typically `.claude/skills/<flow>-autoloop/SKILL.md`) assembles the three layers, the active-hunt anti-patterns, the 13-step loop, and the report format above, plus: frontmatter (`name: <flow>-autoloop`, a `description:` naming the 3-layer scrutiny + polish-toward-award-quality posture); the derived inputs; a **mid-iteration user-bug triage protocol** (stop / classify / fix-or-park / acknowledge the miss); **termination conditions** (flow grade S + every generative screen S + state-clarity dims S + backend counts clean, OR the cap, OR a hard failure, OR a new user message); a **plateau protocol** (*"plateau is NOT a stop — if grade plateaus at B+/A- for 2 iterations, diagnose reviewer miscapture / harness flakiness / wrong fix target, and pivot"*); the **safety invariants** (never edit migrations / package.json / fixture files / harness YAML except sanctioned nav fixes; every fix passes lint + typecheck; every commit atomic; backend changes via the migration tool only); and, if the project has generative surfaces, the 4-question generative-surface checklist (working right now? on what specifically? anything failing? how do I know when done?).

## Acceptance — what battle-tested looks like

The authored skill fails the bar if any is missing (each names the signature and the failure it prevents):

1. **Three layers named with non-skippable framing** — all three every iteration; skipping any is a known plateau / regression cause.
2. **The Layer-2 semantic-count audit** — the denominator-naming exercise; without it, generative surfaces ship green-checkmark lies.
3. **Layer-3 backend-truth probe with project-specific SQL/API** — a generic *"check the database"* fails; specific queries with known-good shapes pass.
4. **The 13-step orchestration loop, each step concrete** — sanity → reset → mint → apply → capture → L2 → L1 → L3 → report → pick → commit → ledger → schedule.
5. **One-fix-per-iteration, atomic commit** — no batching, or grade-delta attribution breaks and the loop stops learning.
6. **Iteration caps (hard + soft) with concrete numbers** — without them the loop runs forever and burns the compute budget.
7. **A plateau pivot protocol** — plateau is a signal (miscapture / flakiness / wrong target), not a stop.
8. **A locked safety-invariants list** — without it the loop edits the harness YAML to make tests pass, which is catastrophic.
9. **A mid-iteration user-bug triage protocol** — without it the loop ignores user input mid-cycle.
10. **Active-hunt anti-patterns with concrete project examples and fix patterns** — silent-success / silent-queue / mutation race / status-color abuse; a generic *"check for bugs"* fails.

And it must be a real loop, not a single-shot audit dressed as one (the iterative pick-fix-commit-rerun discipline IS the autoloop); it must not auto-dispatch escalation agents (architectural fixes park in `next_design_required.md` and recommend `pre-flight`; the loop never auto-runs migrations).

## Tool surface

`Read`, `Grep`, `Glob`, `Bash`, `Write`, `Edit`, plus capture / interaction tools (Maestro / Playwright / `xcrun simctl`) and database tools (Supabase MCP / `psql`) for L3. Model: highest-capable (opus-class — each iteration runs reviewer + composition scan + backend probe + fix-pick + commit; depth is the difference between "polished" and "plateau"). Effort: high per iteration, bounded by the cap (6-10 iterations × ~5-10 min ≈ 30-100 min total).

## Cross-references

- `flow-audit.md` — mode (b) is the L1 grader for multi-screen autoloops.
- `ux-audit.md` — the L1 grader for single-screen autoloops, or the drilldown on lowest-graded screens.
- `quality-rubric.md` — the five composition pitfalls, the source of truth for L2.
- `audit-routing.md` — the cross-rubric translation table (S ↔ Crit ↔ S0).
- `visual-verification.md` — capture discipline (`FIXTURE_RESET_COMMAND` + `FLOW_CAPTURE_HARNESS`).
- `design-benchmarking.md` — Tier 1 / Tier 2 benchmarks inherited via the L1 reviewer.
