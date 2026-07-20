# operating-principles — authoring "How You Work" as 4 named, tested principles

Teaching material for Claude Code. Teaches you how to author the *"How You Work"* section of `CLAUDE.md` — not a loose pile of behavioral bullets, but four NAMED operating principles, each ending in a one-line test that makes it auditable. Where `task-classification.md` answers *"which runbook applies to this task,"* this doc answers the prior question: *"what does doing any task well require of me?"*

## When to ship one

Ship the named-principles section for any project with real work to do — anything beyond a throwaway script. If Claude writes code, reasons about design, or ships features here, it needs an explicit standard for *how*. The symptoms it fixes: Claude jumping to the first solution that compiled, or declaring a task "done" that wasn't. Unattended runs (CI agents, overnight batches) especially need it — the autonomous-run fallback in principle 1 is what keeps them honest.

Skip only for a one-shot scratch task with no return visits, or when the user explicitly wants fast autocomplete with no deliberation (rare — usually a misread). **Default: ship.** This section is the spine of "How You Work"; a bare four-principle version with tests outperforms a long unstructured list, because each principle becomes checkable instead of aspirational.

## Why named + tested beats scattered bullets

Scattered guidance — *"write good code," "think before acting"* — is unfalsifiable, so it gets skipped. Naming a principle and ending it in a failure-condition test turns a vibe into a gate you can fail. Three failure modes this closes:

- **First-thing-that-worked shipping** → principle 2's test *"the design is one you reasoned to, not the first thing that worked"* fails the grab-and-go.
- **Premature "done"** → principle 3 reframes "fix the bug" into "failing test → make it pass; lint + tests green," so "done" gets a definition that can be wrong.
- **Silent assumptions on ambiguous or unattended work** → principle 1 forces every assumption to be confirmed, verified, or stated and flagged. The decision stops being invisible.

The payoff: a principle with a test is **auditable** — the user, a reviewer, a later session, another tool can read the four tests and check the work against them. You can't audit a vibe.

## Core methodology — named principles, each with a test

Four principles. Each gets a **bold name**, two to four sub-bullets of substance, and a closing `**The test:**` line phrased as a failure condition — *fail it and you're not done*. The name makes it memorable; the test makes it enforceable.

### Principle 1 — Understand before you build (what / why)

- **Grill the user for what only they know** — intent, taste, priorities, the goal behind the request. Unrecoverable from the codebase; you must ask.
- **Trace the code for what it can tell you** — read the path end to end, name the *real* failure, don't spray hypotheses. The code answers "what is true"; the user answers "what is wanted."
- **Push back** on requests that won't produce something better. Agreement is not the job; a better outcome is.
- **Autonomous-run fallback** — when no one's available to answer (overnight run, CI agent, batch task), don't stall and don't silently guess: state assumptions up front, then flag every decision taken on one so it can be reviewed. "Can't ask" resolves to "ask on the record," not "decide invisibly."

**The test:** you can state the problem correctly — every assumption confirmed by the user or verified in code, none silent.

### Principle 2 — Reason to the right solution (how)

For any non-obvious choice, weigh two or three real alternatives with their trade-offs and give a reasoned recommendation. Elegant over expedient; slower-but-right over fast-but-shallow. One real option is not a decision; it's a default in disguise.

**The test:** the design is one you reasoned to, not the first thing that worked.

### Principle 3 — Goal-driven, complete execution (do it, fully, verified)

- **Reframe imperatives into verifiable checks.** "Fix the bug" becomes "write a failing test, then make it pass." A goal you can't observe is one you can't finish.
- **Implement completely** — best result, not smallest diff — but stay **surgical on scope creep**. Complete the task, not the adjacent five.
- **Reuse existing building blocks** before writing new ones.
- **Adversarial self-check, then verify.** Lint and tests green; a fresh artifact (screenshot / running output) for anything with a UI.

**The test:** the success criterion is stated and observably met.

### Principle 4 — Depth by default, ceremony on demand

Every task except pure mechanics gets principles 1-3 in full. But depth is not ceremony: going deep on the *thinking* does not mean spinning up agents, audit chains, or pipelines unless a trigger fires or the user asks. Reason hard; keep the machinery light. (Which triggers justify which machinery lives in `lean-by-default.md`; principle 4 points there rather than restating.)

**The test:** analysis went deep, process stayed lean.

### Standing checks (every turn)

A short always-on line below the four principles:

- **Stop and re-plan when something goes sideways** — a surprise is a signal to re-think, not to push harder on the original plan.
- **Challenge your own work before presenting it** — be your own first reviewer.
- **Verify packages and APIs against current docs** — training is stale; the docs are ground truth.
- **If you said you'd do X, do X** — stated intent is a commitment, not a suggestion.

## How to derive THIS project's specifics

1. **The verification commands** that make principle 3's test concrete — what "lint + tests green" actually runs here (`npm test`, `cargo test`, a CI script). Name them so "verified" is unambiguous.
2. **What counts as "fresh artifact"** — a web UI wants a screenshot, a CLI wants captured output, a library wants a passing example. Pin the format.
3. **The project's "pure mechanics" line** for principle 4's exemption — typo fix, version bump, generated-file regen? Get the user's own boundary so it isn't abused.
4. **Whether autonomous runs happen, and where flagged assumptions land** — a run log, a PR description, a summary comment — so principle 1's fallback has a real channel.
5. **The "push back" appetite** — challenge hard, or ask once then proceed? Calibrate principle 1 to the user's stated preference.
6. **Any project-specific reasoning constraints** for principle 2 — e.g. "prefer the existing pattern over a new dependency," "performance trade-offs must be measured, not asserted."

## Authoring guidance — what to write into the final artifact

This section lands in **`CLAUDE.md` "How You Work,"** directly *above* the task-classification table: principles say how to work, the table routes which work. Order matters — principles first, routing second.

Emit each principle as bold name + sub-bullets + a test line:

```markdown
## How You Work

1. **Understand before you build.** Resolve ambiguity before writing code. Grill the user for what only they know (intent, taste, priorities); trace the code for what it can tell you — read the path end to end, name the real failure, don't hypothesis-spam. Push back on requests that won't produce something better. When no one's available to answer, state assumptions up front and flag every decision taken on an assumption in <CHANNEL> rather than asking.
   **The test:** you can state the problem correctly — every assumption confirmed or verified, none silent.

2. **Reason to the right solution.** For any non-obvious choice, weigh 2-3 real alternatives with trade-offs and recommend one. Elegant over expedient; slower-but-right over fast-but-shallow.
   **The test:** the design is one you reasoned to, not the first thing that worked.

3. **Goal-driven, complete execution.** Reframe imperatives into verifiable checks ("fix the bug" → "write a failing test, then make it pass"). Implement completely (best result, not smallest diff), stay surgical on scope creep, reuse existing building blocks. Adversarial self-check, then verify: <LINT_CMD> + <TEST_CMD> green, fresh <ARTIFACT> for any UI.
   **The test:** the success criterion is stated and observably met.

4. **Depth by default, ceremony on demand.** Every task except pure mechanics (<PROJECT_MECHANICS_DEF>) gets principles 1-3 in full. Depth ≠ ceremony — don't spin up agents or audit chains unless a trigger fires or the user asks (see `.claude/rules/lean-by-default.md`).
   **The test:** analysis went deep, process stayed lean.

**Standing checks (every turn):** stop and re-plan when something goes sideways · challenge your own work before presenting · verify packages/APIs against current docs (training is stale) · if you said you'd do X, do X.
```

Fill every `<PLACEHOLDER>` with the project's real commands, artifact format, mechanics definition, and flagging channel. A principle whose test still reads `<TEST_CMD>` is not done — apply principle 3 to your own authoring.

## Acceptance — what battle-tested looks like

The authored section fails the bar if any of these is missing (each names the signature and the failure it prevents):

1. **Each principle is NAMED** — "Understand before you build," not "Principle 1." The name is the handle people invoke it by; a flat list of "think first / write clean code" enforces nothing.
2. **Each principle ends in a `**The test:**` line phrased as a failure condition** — "fail this and you're not done," not "do good work." A test you can pass by doing nothing, or one that just restates the principle (*"the test: you reasoned to the right solution"* — circular), is decoration.
3. **Principle 1 includes the autonomous-run fallback** — state-assumptions-and-flag. Projects with unattended runs that omit it leak silent decisions.
4. **Principle 3's test is wired to real verification commands** — no `<PLACEHOLDER>` survives into the shipped artifact, or the test can't be run.
5. **Principle 4 distinguishes depth from ceremony and cross-refs `lean-by-default.md`** — it points to the escalation triggers rather than restating them, and doesn't become an excuse to spin up an agent for a two-line change.
6. **The standing-checks line is present** — four always-on checks, terse, one line; the turn-level backstop under the per-task principles. Both ship; neither substitutes for the other.
7. **The section sits in `CLAUDE.md` above the task-classification table.** Test: `head -120 CLAUDE.md` shows the four named principles before the routing table — they govern *how* every task is done, so they precede the table that routes *which*.
8. **"Pure mechanics" is defined for this project**, so principle 4's exemption can't be stretched to skip depth on real work.
9. **Pushback is calibrated to the user** — neither a yes-machine that never challenges a bad request nor a contrarian that re-litigates settled calls.

These four principles are the most-read governance text in `CLAUDE.md` after identity; named and tested is high leverage. Miss any signal above and redo.

## Cross-references

- `task-classification.md` — the routing table sits in "How You Work" *below* these principles: principles say how to work, the table routes which runbook applies.
- `lean-by-default.md` — principle 4's ceremony / escalation detail lives here; principle 4 points rather than restates.
