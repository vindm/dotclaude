# iterative-polish-autoloop — designing a continuous iterative UI polish loop for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author the **user-invocable autoloop skill** that drives a flow end-to-end on a clean fixture, grades ruthlessly, picks ONE highest-ROI fix, applies + commits atomically, and re-runs — until award-quality OR an iteration cap is reached. Layers three scrutiny dimensions (reviewer agent + composition scan + backend-truth probe).

## When to ship one (applicability gate)

Ship an iterative-polish-autoloop skill when:

- The project has **multi-screen arcs** worth polishing iteratively (onboarding / setup / checkout / a generative pipeline visualization).
- There's a **capture harness** that drives the flow without user input (Maestro / Playwright / similar).
- There's a **reviewer agent** that grades the captured artifacts (`flow-continuity-review` is the standard L1 grader).
- The team's **quality posture is offensive** ("polish toward award-quality"), not defensive ("ship and iterate").
- A **fixture-reset mechanism** exists (seed scripts / orphan SQL / mock-mode env vars) so each iteration starts from a known state.

Skip when:

- No capture harness exists — without auto-capture, the loop has no input.
- Single-shot audits cover the need (use the reviewer agent directly).
- The project's polish posture is "ship and iterate" — autoloops are friction without lift.
- Single-screen polish (use `ux-audit` directly).

## Why it matters — what this catches that nothing else does

A single audit run produces a verdict; a verdict isn't the same as a polished flow. Without an autoloop:

- **Polish stalls at "B+ feels good enough."** Without iteration discipline, the team plateaus at first acceptable quality. The autoloop's hard cap forces N tries to reach S-tier.
- **Per-iteration regressions slip in.** Without the regression-delta check (inherited from `flow-continuity-review`), fixing one screen breaks another.
- **Fixes batch into "polish PRs."** Five fixes in one commit = no way to attribute grade delta. The autoloop's atomic-commit discipline gives each fix its own grade delta.
- **Composition-level bugs survive macro grading.** Reviewer agents are excellent at per-screen and arc-level grading but blind to composition-level duplication / orphan elements / semantic-count lies / status-color abuse. The L2 composition scan catches what L1 misses.
- **Backend truth diverges from UI claims.** UI says "all done"; backend says "3 of 4 missing." Without L3 backend-truth probes, the autoloop ships UI-polished flows that lie. NON-NEGOTIABLE on generative surfaces.
- **Iteration loops run forever.** Without hard and soft caps, "one more iteration" becomes weeks.

The autoloop's value is **closed-loop quality drive** — each iteration produces measurable grade delta, one fix at a time, with backend-truth verification at every step.

## Core methodology — three layers of scrutiny per iteration

Every iteration runs ALL THREE layers. Skipping any one is a known cause of plateau / regression.

### Layer 1 — Reviewer agent (macro)

`flow-continuity-review` for multi-screen arcs; `ux-audit` for single-screen drilldowns. Grades per-screen quality + flow-level dimensions (voice consistency, CTA progression, loading vocab, disclosure pacing, color drift, progress legibility).

Reviewer agents are excellent at macro tone and per-screen grading but **blind to composition-level duplication** because they grade each screen against a benchmark, not against itself. Hence L2.

When aggregating verdicts across multiple agents (token-auditor + interaction-audit + reviewer), use the cross-rubric translation table in `audit-routing.md` — don't reinvent the S↔Crit↔S0 mapping per iteration.

### Layer 2 — Composition scan (micro)

The five composition pitfalls (duplication / orphan elements / tone mismatch / hierarchy violations / residue) live in `quality-rubric.md`. Apply that checklist on every screenshot before accepting the reviewer verdict.

**Plus an autoloop-specific addition: semantic-count audit.**

For **every count rendered to the user** (`1/4`, `3/3`, `Processing 2`, `N items ready`):

- **Name the denominator.** Is it "total items the user would count" (user truth) or "the job's scoped subset" (job truth)?
- **If the denominator is a job-scoped subset, THE COUNT LIES.** Users count their physical items, not pipeline nodes. A green `1/1` on a stage that processed 1 of 4 items reads as "all done" when reality is "3 of 4 missing."
- **Cascade corollary for DAG pipelines** (when stages compose): when an upstream stage has soft-failures, downstream stages must NOT render the surviving subset as a green checkmark. Render `{eligible}/{totalUserCount} · {blocked} blocked by upstream` in muted amber.
- **Fix pattern:** every UI count's denominator = the thing the user would count. Numerator = actual persisted coverage. When numerator < total due to cascade blocking, surface the block count.

Ask on every screenshot: *"If a user glanced at this number for 2 seconds and answered 'am I done?', would their answer match backend reality?"* If no → semantic-count violation → flag immediately.

NON-NEGOTIABLE on generative surfaces. Composition polish is meaningless if numbers themselves lie.

### Layer 3 — Backend truth probe

For generative surfaces / data-dependent surfaces, probe what the pipeline actually produced via `BACKEND_TRUTH_PROBE_QUERIES`:

```sql
-- Coverage probe
SELECT COUNT(*) FROM <table> WHERE <field> IS NULL OR <field> = <empty>;
-- Job state probe
SELECT type, status, result_json FROM jobs WHERE <scope> ORDER BY created_at DESC;
```

Look for anti-patterns (project-specific, listed below in §"anti-patterns to hunt actively"):

- `status='success'` but zero persisted output → silent-success.
- `status='queued'` for >5 min → silent-queue.
- Mutation race patterns (multiple `.mutate` calls clobber `result_json`).
- Active pipeline running but UI surfaces "Add X" CTA on the same field.
- Server mutations without query invalidation.

## Anti-patterns to hunt actively

Project-specific by `BACKEND_TRUTH_PROBE_QUERIES` content, but the patterns generalize:

- **Silent-success family** — runner reports `status='success'` but persisted state is partial. Never let UI trust `job.status` alone — derive from persisted state + soft-failure markers in `result_json.<stage>_failed[]` + a `partial` UI status.
- **Silent-queue** — `status='queued'` never transitions. Surface via queued-too-long amber chip.
- **React Query / SWR mutation race** — multiple `.mutate` calls on the same field race because HTTP requests don't serialize. Mitigation: every intermittent write carries the accumulator. Architectural fix: progress in a separate column OR serialize via `mutationKey`.
- **"Add X" CTA during active pipeline** — when a job is enriching the same field the CTA would populate, suppress the CTA.
- **Semantic color abuse** — amber = actionable warning, NOT "still generating." Red = hard error, NOT "soft fail on 1 of N."
- **Bundle / device-target staleness** — capture harness targets a different device than where the fix landed. Sanity-gate the dev-server target every iteration.
- **Hypothesis-spam over tracing** — first response to a bug is "could be A, could be B, could be C." Wastes the loop's time. **Trace end-to-end before responding** — cite a specific file:line as root cause.
- **Server mutation without query invalidation** — tool persists DB rows; client cache keyed on those rows isn't invalidated; screen renders empty.

## Orchestration loop

### Per-iteration steps (canonical)

1. **Sanity gate** — `DEVICE_TARGET_DETECT_COMMAND` returns the expected device; `git status` matches last commit.
2. **Reset** — run `FIXTURE_RESET_COMMAND`.
3. **Mint IDs** — `RUN_ID=$(date -u +%Y-%m-%d_%H-%M-%SZ)`; `REPORT_DIR=<AUDIT_REPORT_DIR_CONVENTION>/R<N>-$RUN_ID`.
4. **Apply one fix** from prior iteration's report. Lint + type-check baseline must hold.
5. **Capture** — run the capture harness (e.g. dual-flow Maestro setup + live yaml chained on same fixture).
6. **Layer 2 scan (OPERATOR-DRIVEN)** — open 2-3 key screenshots and run `quality-rubric`'s 5 pitfalls + semantic-count audit BEFORE invoking reviewer. This is the step that catches what reviewers miss.
7. **Layer 1 grade** — invoke the reviewer agent with manifest.
8. **Layer 3 probe** — run `BACKEND_TRUTH_PROBE_QUERIES`.
9. **Write report** — merge L1+L2+L3 into `$REPORT_DIR/report.md`.
10. **Pick next fix** — highest-ROI. Apply ROI multiplier (e.g. `1.5×`) for generative-surface or backend-truth fixes per project priority.
11. **Commit atomically** — `audit(<flow>): R<N-1>→R<N> <fix>`.
12. **Update ledger** — append to `<AUDIT_REPORT_DIR_CONVENTION>/AUTOLOOP-LOG.md`.
13. **Schedule next** (if not terminating) — delay-then-run on the same flow.

## How to derive THIS project's specifics

Before authoring the skill, gather:

1. **Fixture reset command** → `FIXTURE_RESET_COMMAND`. Project-specific seed pipeline. Example: `yarn e2e:seed:layer1 + orphan SQL cleanup` / `pnpm seed:fresh` / `npm run db:reset && npm run db:seed`.

2. **Flow capture harness** → `FLOW_CAPTURE_HARNESS`. The auto-driver. Common: Maestro YAML chain / Playwright spec / a custom shell script.

3. **Reviewer agent name** → `REVIEWER_AGENT_NAME`. Which agent powers L1. Default: `flow-continuity-review`; for single-screen autoloops, `ux-audit`.

4. **Backend truth probe queries** → `BACKEND_TRUTH_PROBE_QUERIES`. Project-specific SQL / API calls. Each query has a known "good" shape; deviation = a bug. List 3-5 queries.

5. **Semantic-count audit patterns** → `SEMANTIC_COUNT_AUDIT_PATTERNS`. When does a UI count lie for THIS project? (e.g. pipeline subset vs user truth on generative surfaces; filter-scoped vs unfiltered counts on dashboards).

6. **Iteration caps** → `ITERATION_CAP_HARD` (e.g. 10), `ITERATION_CAP_SOFT` (e.g. 6). The hard cap is the budget ceiling; the soft cap triggers pivot-or-escalate.

7. **Audit report dir convention** → `AUDIT_REPORT_DIR_CONVENTION`. Where reports + ledger + captures land. Common: `.claude/audits/<flow>/R<N>-<RUN_ID>/`.

8. **Safety invariants** → `SAFETY_INVARIANTS`. The do-not-edit list. Typical: migrations, package.json, tokens.ts structure, fixture files, the capture-harness YAML itself (except sanctioned harness-nav fixes).

## Authoring the skill

The final skill (typically `.claude/skills/<flow>-autoloop/SKILL.md`) specifies:

1. **Frontmatter** — `name: <flow>-autoloop` (or generic `ruthless-ux-autoloop`), `description:` naming the 3-layer scrutiny + iterative-polish-toward-award-quality posture.
2. **Purpose section** — *"Drive a flow from raw to award-quality through tight iterative loops. Each iteration: drive end-to-end on a clean fixture → capture every state → grade ruthlessly → pick ONE highest-ROI fix → apply + commit atomically → schedule next."*
3. **Three layers of scrutiny** named explicitly — L1 reviewer, L2 composition scan + semantic-count audit, L3 backend-truth probe.
4. **Anti-patterns to hunt actively** — the project-specific list with concrete patterns.
5. **Orchestration loop** — 13 numbered steps verbatim.
6. **Inputs section** — fixture reset, harness, reviewer, budget.
7. **Mid-iteration user-bug triage protocol** — what to do when the user surfaces a bug mid-loop (stop, classify, fix or park, acknowledge the miss).
8. **Termination conditions** — flow grade S + every generative screen S + state-clarity dims S + backend counts clean; OR iteration cap; OR hard failure; OR new user message.
9. **Plateau protocol** — *"Plateau is NOT a stop. If grade plateaus at B+/A- for 2 iterations, diagnose: reviewer miscapture, harness flakiness, or wrong fix target. Pivot."*
10. **Safety invariants (locked)** — never edit migrations / package.json / fixture files; every fix passes lint + typecheck; every commit atomic; backend changes via migration tool only.
11. **Artifacts per iteration** — `report.md` / `manifest.json` / `*.png` / `AUTOLOOP-LOG.md` / `next_design_required.md`.
12. **Generative-surface checklist** (if project has generative surfaces) — 4 questions every generative surface must answer at every moment (working right now? on what specifically? anything failing? how do I know when done?).
13. **User's standing principle** — one-line quotable quality posture (e.g. *"polished UX with every element having a purpose and within the entire composition"*).

## Rubric / output format

Per-iteration report shape:

```markdown
## Autoloop R<N> — <flow> — <RUN_ID>

### Sanity gate
- Device target: <expected vs detected>
- Git status: <clean vs dirty>

### Fix applied this iteration
<one-paragraph summary of the fix + commit SHA>

### L1 — Reviewer grade
<flow grade + per-screen table — from REVIEWER_AGENT_NAME report>

### L2 — Composition scan
- Pitfall 1 (duplication): <found / clean>
- Pitfall 2 (orphan): <found / clean>
- Pitfall 3 (tone mismatch): <found / clean>
- Pitfall 4 (hierarchy violation): <found / clean>
- Pitfall 5 (residue): <found / clean>
- Semantic-count audit: <per count rendered, denominator named, verdict>

### L3 — Backend truth probe
- Query 1: <result + verdict>
- Query 2: <result + verdict>
- ...

### Regression delta vs R<N-1>
<per-screen delta table + paragraph>

### Next fix (highest-ROI)
<single concrete move + ROI multiplier rationale>
```

Plus the append-only ledger entry per iteration:

```markdown
| R<N> | <focus> | <files touched> | <grade delta> | <commit SHA> |
```

## Depth signatures — what battle-tested looks like

The authored autoloop skill fails the depth bar if it lacks any of these 10 structural elements.

1. **Three layers named explicitly with non-skippable framing** — L1 + L2 + L3, all-three-every-iteration. *"Skipping any one is a known cause of plateau / regression."*
2. **Layer 2 semantic-count audit** — the denominator-naming exercise. Without it, generative surfaces ship green-checkmark lies.
3. **Layer 3 backend-truth probe with project-specific SQL/API** — generic *"check the database"* fails. Specific queries with known-good shapes pass.
4. **Orchestration loop with 13 numbered steps** — sanity gate → reset → mint IDs → apply → capture → L2 → L1 → L3 → report → pick next → commit atomically → ledger → schedule. Each step concrete.
5. **One-fix-per-iteration atomic-commit rule** — *"No batching."* Without atomic commits, grade-delta attribution breaks.
6. **Iteration caps (hard + soft) with concrete numbers** — hard 10, soft 6 (project-tunable). Without caps, the loop runs forever.
7. **Plateau pivot protocol** — *"Plateau is NOT a stop. If grade plateaus at B+/A- for 2 iterations, diagnose..."* Without this, the loop hits plateau and reports complete.
8. **Safety invariants (locked) list** — migrations / package.json / tokens / fixture files / capture-harness YAML. Without explicit do-not-edit, the loop edits the wrong things and corrupts the harness.
9. **Mid-iteration user-bug triage protocol** — stop / classify / fix-or-park / acknowledge. Without it, the loop ignores user input mid-cycle.
10. **Anti-patterns to hunt actively with concrete project examples** — silent-success / silent-queue / mutation race / status-color abuse / etc. Each with the symptom + the fix pattern. Generic *"check for bugs"* fails.

If the authored skill lacks any of these, redo.

## Cross-references

- `flow-continuity-review.md` — the L1 grader for multi-screen autoloops.
- `ux-audit.md` — the L1 grader for single-screen autoloops, OR the follow-up drilldown on lowest-graded screens.
- `quality-rubric.md` — the 5 composition pitfalls source of truth for L2.
- `audit-routing.md` — cross-rubric translation table (S ↔ Crit ↔ S0).
- `visual-verification.md` — capture discipline (`FIXTURE_RESET_COMMAND` + `FLOW_CAPTURE_HARNESS` discipline).
- `design-benchmarking.md` — Tier 1 / Tier 2 benchmarks inherited via the L1 reviewer.
- `forbidden-phrases.md` — hooks that pre-empt copy-register findings before iterations spend on them.

## Anti-patterns in the skill you write

- **Single-shot audit dressed as autoloop.** If the skill runs the reviewer once and stops, it's not an autoloop — it's a wrapper around the reviewer. The iterative-commit-pick-next discipline is the autoloop.

- **L2 skipped because reviewer "already covers it."** No. Reviewers grade per-screen against benchmarks; L2 grades a screen against itself (composition). Different lens.

- **L3 skipped because "the UI looks fine."** Generative surfaces lie. UI says "1/1 done" while backend says "1 of 4 attempted." Backend-truth probes catch the lie.

- **Multi-fix batches per iteration.** Five fixes in one commit = no grade-delta attribution = no learning. One fix per iteration is binding.

- **Iteration cap absent or treated as "soft."** Without a hard cap, the loop's compute budget burns through. The cap is the budget; respect it.

- **Plateau treated as stop.** Plateau = a signal something's wrong (reviewer miscapture, harness flakiness, wrong fix target). Pivot, don't stop.

- **No safety invariants — autoloop edits the harness YAML to make tests pass.** Catastrophic. Migrations / fixtures / harness YAMLs are locked. Sanctioned harness-nav fixes are the only exception, and they're explicit.

- **No user-message handling protocol.** The autoloop runs while the user is doing other things. When a user message arrives, the loop must finish current iteration cleanly and pause for instruction.

- **Auto-dispatches escalation agents.** When a fix needs architectural work (e.g. mutation-race → progress-in-separate-column migration), the autoloop parks it in `next_design_required.md` and recommends `pre-flight` — never auto-runs migrations.

## Tool surface

The skill needs (in the dispatching agent's tool budget): `Read`, `Grep`, `Glob`, `Bash`, `Write`, `Edit`, plus capture / interaction tools (Maestro / Playwright / `xcrun simctl`) and database tools (Supabase MCP / `psql`) for L3 probes.

Model: highest-capable (opus-class). Each iteration runs reviewer + composition scan + backend probe + fix-pick + commit. The model's depth makes the difference between "polished" and "plateau."

Effort: high per iteration, but the budget is bounded by the iteration cap. 6-10 iterations × ~5-10 min each = 30-100 min total budget. Substantial but bounded.
