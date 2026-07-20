# lean-by-default — depth by default, ceremony on demand

Teaching material for Claude Code. Teaches you how to author the discipline that keeps a session *deep on the problem, lean on process*: all-in on understanding, but subagents, audit chains, and conformance matrices fire only when an explicit trigger does. It is the operational headline of principle 4 in `operating-principles.md`, and it builds on the hook/rule/skill/agent cost ladder in `audit-routing.md`.

## When to ship one

Ship it when the project has *any* heavyweight process machinery — subagents, audit pipelines, conformance matrices, design pipelines, pre-flight gates. The more machinery, the stronger the reflex to fire it on every task, and the more this earns its keep. Two symptoms confirm the need: the user asking *"why did it spin up three agents to add a config flag?"*, and an always-loaded surface (`CLAUDE.md` + auto-loaded rules + agent descriptions) that keeps growing.

Skip only when the project has no machinery to over-fire and the user accepts the token cost of maximal ceremony. Both are rare — the context-budget half applies even to single-agent projects, and projects accrete machinery over time. **Default: ship.**

## The idea — two dials, moved independently

- **Depth** is always at maximum: understand the problem, read the load-bearing code, find the root cause, propose the real fix. Non-negotiable on the one-line change as much as the migration.
- **Ceremony** sits at zero and rises *only* when a trigger fires or the user asks. Subagents, audit chains, conformance matrices, design pipelines, pre-flight gates — none fire reflexively.

The confusion this resolves: **depth is not ceremony.** Going deep is mandatory (principles 1-3 of `operating-principles.md`); spinning up machinery is a cost you pay only when justified. Conflate them and you get either shallow-but-ceremonious work (machinery on an un-understood problem) or deep-but-undisciplined work (no escalation when it's actually warranted). The test for any piece of machinery: *did a named trigger fire, or did the user ask?* If neither, don't spin it up — thoroughness lives in depth, not in process count.

Three costs make the discipline pay:

- **Reflexive agent-spawning burns tokens and wall time** — tens of thousands of tokens of an expensive model per run (cost ladder in `audit-routing.md`), usually solving nothing the inline session couldn't.
- **Context bloat degrades every session** — `CLAUDE.md` + auto-loaded rules + every agent description load *before any work happens*, on every session. Invisible per-session, enormous in aggregate.
- **Universal ceremony hides the real escalation signal** — when everything spins up machinery, the DB migration looks identical to the copy tweak. Firing selectively is what makes "this one is serious" legible.

## The escalate table — a gate, not a menu

The discipline is enforced by a table mapping a *concrete, observable trigger* to the machinery to add. It reads: *by default implement inline at full depth; escalate ONLY when a row matches.* Everything not matching a row is pure mechanics — inline, full depth, no process.

Sample (the project's real triggers and specialists replace these):

| Escalate when… | …add this |
|---|---|
| The change includes a DB migration or schema edit | `data-auditor` agent + migration skill |
| The change spans modules / shifts an architecture boundary | `pre-flight` agent before writing code |
| The task is a new user-facing UI surface | design pipeline per `audit-routing.md` |
| The change touches native / platform code | platform-specialist agent or skill |
| The user explicitly asks for a review / audit | the matching audit agent |
| The work is plan- or spec-backed | conformance matrix before claiming done |

A trigger is readable off the diff or the request — a migration file, a cross-module edit, an explicit "review this." *"Just to be safe"* is not a trigger; if you can't point at the row that fired, you don't escalate.

## Context and latency budgets

Two budgets, paid on different clocks.

**Context budget — paid once per session.** The always-loaded surface (`CLAUDE.md` + every auto-loaded rule + every agent `description`, which loads even when the agent never runs) taxes every task. Keep it lean:

- One-line agent and skill descriptions — a description is a routing pointer; depth lives in the body, which loads only on dispatch.
- Prefer a pointer (*"see `.claude/rules/x.md`"*) over inlining anything not needed first-decision; keep the routing table and identity inline.
- Cheapest tier that solves the problem wins — the `audit-routing.md` cost ladder (Tier 0 hook → Tier 1 rule → Tier 2 skill → Tier 3 agent). Don't reach for an agent when a hook or rule covers it.
- A `.claudeignore` keeps build output, generated files, vendored code, and large fixtures out of context entirely.

**Latency budget — paid on every edit.** A `PostToolUse` hook on `Write|Edit` runs after each file write, so anything slow or redundant there compounds over hundreds of edits:

- No multi-second commands per edit. Per-edit `eslint --fix` / type-check / test runs are redundant with `lint-staged` + the Definition-of-Done gate — the same check run dozens of times instead of once. Lint at commit and at done. (This is why `auto-lint-posttool.sh` ships with a "when NOT to use" warning.)
- Consolidate `Write|Edit` checks into one `check-all.sh` dispatcher — each registered hook is a separate process spawn; ten hooks mean ten spawns per edit. One spawn, not N, with per-violation blocking preserved.

What *does* belong per-edit is the instant deterministic guardrail: file-size ceiling, token/hex sweep, secret-leak check. Cheap and fast is the bar.

## How to derive THIS project's specifics

1. **Which escalation triggers exist here.** Read the project's reality, not the abstract universe: migrations (`ls` the migrations dir)? Multiple modules / a real architecture boundary? UI surfaces? Native code? An eval suite? Each *present* one becomes a row; absent ones don't. A pure CLI library may have two rows (plan-backed, user-asks-for-review).
2. **What "pure mechanics" means here** — the complement of the table, named concretely (*"single-file edits, copy changes, config tweaks, adding a flag, bug fixes with an obvious root cause"*) so sessions recognize the default path. The clearer the definition, the less reflexive escalation.
3. **The always-loaded token target.** Measure the current surface (`wc -l CLAUDE.md`, count auto-loaded rules and agent-description lengths) and set a target — e.g. `CLAUDE.md` under ~400-600 LOC, descriptions one line each. The target is what the acceptance checklist tests against.

## Authoring guidance

This lands in **`CLAUDE.md` "How You Work"** — the always-loaded surface that governs the first decision of every session. Three pieces:

The headline:

```markdown
**Depth by default, ceremony on demand.** Go all-in on understanding (read the load-bearing code, find the root cause, propose the real fix). Do NOT spin up subagents, audit chains, or conformance matrices reflexively — they fire only when a row below matches or the user asks. Everything else is pure mechanics: implement inline, at full depth.
```

The gate table:

```markdown
**Escalate when (and only when):**

| Escalate when… | …add this |
|---|---|
| <trigger derived from this project> | <specialist / process> |
| The user explicitly asks for a review | <matching audit agent> |
| Work is plan/spec-backed | conformance matrix before claiming done |
```

The context-budget note:

```markdown
**Context budget.** The always-loaded surface costs tokens every session — keep it lean. Descriptions stay one line; prefer pointers over inlined content; cheapest tier wins (see `.claude/rules/audit-routing.md`). Junk stays out via `.claudeignore`.
```

And ensure a `.claudeignore` exists covering build output, generated files, vendored deps, and large fixtures; author a starter if none exists.

## Acceptance — what battle-tested looks like

The authored discipline fails the bar if any of these is missing (each line names the signature and the failure it prevents):

1. **The headline sits in `CLAUDE.md` "How You Work,"** not a sub-file — it governs the first decision of every session.
2. **The escalate table has concrete, observable triggers** (*"includes a DB migration"*), not *"complex work."* Test: can you point at the diff and say which row fired?
3. **Every trigger maps to a specialist that exists** in `.claude/`. No rows for agents the project doesn't have.
4. **"Pure mechanics" is named** as the default path — so the table reads as a gate, not a menu; most tasks match no row and ship inline.
5. **Descriptions are one line each.** Test: `grep -A1 '^description:' .claude/agents/*.md` — a paragraph in `description` is context tax on every session.
6. **`CLAUDE.md` is within budget.** Test: `wc -l CLAUDE.md`; a 1500-line file taxes every task.
7. **A `.claudeignore` exists** covering build artifacts, generated files, and large fixtures.
8. **No multi-second command runs per edit, and `Write|Edit` checks are one dispatcher.** Test: read the `PostToolUse` `Write|Edit` hooks — none should invoke a linter/type-check/test, and many separate scripts should be collapsed to one.

The two misreads that undo everything: **"lean" is not "shallow"** — lean means less process, never less understanding; a lean session still reads the load-bearing code and finds the root cause. And **the table is a gate, not a menu** — the default is no ceremony, the rows are the exhaustive list of exceptions. If the discipline produces shallow fixes or fires on everything, it was misapplied.

## Cross-references

- `operating-principles.md` — principle 4 is this doc's headline; principles 1-3 are the depth mandate that "depth by default" refers to.
- `audit-routing.md` — the cheapest-tier-wins cost ladder the context budget builds on; don't restate the ladder here.
- `task-classification.md` — classification routes *what kind* of task; this table gates *whether ceremony fires at all*.
