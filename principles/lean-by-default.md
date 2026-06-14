# lean-by-default — depth by default, ceremony on demand

Teaching material for Claude Code. When you bootstrap a project's AI dev infrastructure, this doc teaches you HOW to author the discipline that keeps a session *deep on the problem but lean on process* — going all-in on understanding, but spinning up subagents, audit chains, and conformance matrices only when an explicit trigger fires. Layer 3 (Process Discipline), cross-cutting into Layer 2 (the hook/rule/skill/agent cost ladder) and Layer 6 (escalation). It is the operational headline of principle 4 in `operating-principles.md`.

## When to ship one (applicability gate)

Ship the lean-by-default discipline when:

- The project has *any* heavyweight process machinery — subagents, audit pipelines, conformance matrices, design pipelines, pre-flight gates. The more machinery exists, the stronger the reflex to fire it on every task, and the more this discipline earns its keep.
- The user has noticed sessions over-process — *"why did it spin up three agents to add a config flag?"* That's the symptom: ceremony decoupled from need.
- `CLAUDE.md` plus auto-loaded rules plus agent descriptions are creeping up in size, and every session starts slower / more expensively because of it.

Skip when:

- The project genuinely has no process machinery at all — no agents, no audit chain, nothing to over-fire. Then there's nothing to gate. (Rare; even single-agent projects benefit from the context-budget half.)
- The user explicitly wants maximal ceremony on every task and accepts the token cost.

The default bias is **ship**. Every project benefits, because the always-loaded context budget exists whether or not there's any machinery to gate, and almost every project accretes machinery over time. This is one of the few docs that ships by default in nearly all bootstraps.

## Why it matters — what this catches that nothing else does

Three failure modes recur without this discipline:

- **Reflexive agent-spawning burns tokens and wall time.** A session reads "this is a feature" and reaches for the design pipeline, the pre-flight agent, and a conformance matrix — for a one-line copy change. Each agent run is tens of thousands of tokens of an expensive model (see the cost ladder in `audit-routing.md`). Most reflexive dispatches solve nothing the inline session couldn't; they're pure overhead dressed as rigor.

- **Context bloat degrades every single session.** `CLAUDE.md` plus auto-loaded rules plus every agent's description string load on *every* session, before any work happens. A bloated always-loaded surface (1500-line `CLAUDE.md`, ten-line agent descriptions, junk swept into context) taxes every task forever — slower reads, higher cost, more room for the model to lose the thread. This cost is invisible per-session and enormous in aggregate.

- **Ceremony hides the real escalation signals.** When a session spins up machinery for everything, the genuine high-risk change — the DB migration, the architecture shift — looks identical to the trivial one. The escalation signal is drowned out. Firing ceremony selectively is what makes "this one is serious" legible. Universal ceremony is the same as no ceremony: neither distinguishes risk.

The core confusion this resolves: **depth is not ceremony.** Going deep — reading the code that matters, tracing the real failure mode, refusing the shallow fix — is mandatory on every task (principles 1-3 of `operating-principles.md`). Spinning up process machinery is a *cost* you pay only when a trigger justifies it. Conflating the two produces either shallow-but-ceremonious work (machinery firing on un-understood problems) or deep-but-undisciplined work (no escalation when it's actually warranted).

## Core methodology

### Idea 1 — Depth by default, ceremony on demand

Two dials, moved independently:

- **Depth** is always at maximum. Understand the problem, read the load-bearing code, find the root cause, propose the real fix not the patch. This is non-negotiable and applies to the one-line change as much as the migration.
- **Ceremony** is at zero by default and rises *only* when a trigger fires or the user asks. Subagents, audit chains, conformance matrices, design pipelines, pre-flight gates — none of these fire reflexively.

The test for any piece of machinery: *"Did a named trigger fire, or did the user ask for it?"* If neither, don't spin it up. "It seemed thorough" is not a reason. Thoroughness lives in depth, not in process count.

### Idea 2 — The "Escalate when (and only when)" table

The discipline is enforced by a small table that maps a *concrete, observable trigger* to the *specialist or process to add*. The table is a **hard gate**: no trigger, no ceremony. It reads as "by default, implement inline at full depth; escalate ONLY when a row below matches."

Sample table (placeholders — the project's real triggers and specialists fill it):

| Escalate when… | …add this |
|---|---|
| The change includes a DB migration or schema edit | `data-auditor` agent + migration skill |
| The change spans multiple modules / shifts an architecture boundary | `pre-flight` agent (integration + blast-radius map) before writing code |
| The task is a new user-facing UI surface | design pipeline per `audit-routing.md` |
| The change touches native / platform code | platform-specialist agent or skill |
| The user explicitly asks for a review / audit | the matching audit agent |
| The work is backed by a written plan or spec | conformance matrix at `docs/audits/<slug>-conformance.md` before claiming done |

Everything not matching a row is *pure mechanics*: implement inline, at full depth, with no added process. The point of the table is that "just to be safe" is **not a trigger**. A trigger is observable from the diff or the request — a migration file, a cross-module edit, an explicit "review this." If you can't point at the row that fired, you don't escalate.

### Idea 3 — Context budget discipline

The always-loaded surface costs tokens on every session: `CLAUDE.md` + every auto-loaded rule + every agent's `description` field (descriptions load even when the agent never runs). Keep it lean:

- **One-line agent and skill descriptions.** The description is a routing pointer, not a spec. Depth lives in the agent/skill body, which loads only on dispatch.
- **Compress `CLAUDE.md` sections.** Prefer a pointer (*"see `.claude/rules/x.md`"*) over inlining content that isn't needed first-decision. The routing table and identity stay inline; everything else can be a pointer.
- **Use a `.claudeignore`** to keep build artifacts, generated files, vendored code, and large fixtures out of context entirely.
- **Cheapest tier that solves the problem wins.** This is the same cost ladder as `audit-routing.md`: Tier 0 hook (~0 tokens, deterministic) → Tier 1 rule (in-context only) → Tier 2 skill (~2-5k per dispatch) → Tier 3 agent (~tens of thousands per run). Don't reach for a Tier 3 agent when a Tier 0 hook or Tier 1 rule already covers it. (See that doc for the full ladder; don't restate it here.)

### Idea 4 — Per-edit latency budget

Context budget is paid once per session; **latency budget is paid on every single edit.** A `PostToolUse` hook on `Write|Edit` runs after *each* file write, so anything slow or redundant there taxes the whole session, compounded over hundreds of edits. Two rules keep it cheap:

- **Don't run multi-second commands per edit.** Per-edit `eslint --fix` / type-check / test runs feel thorough but add seconds to every write, and they're usually *redundant* with a `lint-staged` pre-commit step plus the Definition-of-Done lint/test gate — the same check, run dozens of times instead of once. Lint at commit and at done, not on every keystroke-equivalent. (This is exactly why the `auto-lint-posttool.sh` template ships with a "when NOT to use" warning.)
- **Consolidate `Write|Edit` checks into one dispatcher.** Each registered hook is a separate process spawn per edit; ten hooks mean ten spawns. Collapse them into a single `check-all.sh` dispatcher that reads the hook payload once and runs every check in-process, preserving per-violation blocking. One spawn, not N — the difference is felt on every edit.

The deterministic guardrails that DO belong per-edit are the instant ones: file-size ceiling, token/hex sweep, forbidden-phrase scan, secret-leak check. Cheap and fast is the bar for the per-edit tier.

## How to derive THIS project's specifics

Before authoring, gather:

1. **Which escalation triggers this project actually has.** Read the project's reality, not the abstract universe. Does it have migrations (`ls` the migrations dir)? Multiple modules / a real architecture boundary? UI surfaces? Native / platform code? An eval suite? Each *present* one becomes a row; absent ones don't. A pure CLI library may have only two rows (plan-backed, user-asks-for-review).

2. **What counts as "pure mechanics" here.** The complement of the trigger table. Name it concretely so sessions recognize it: *"single-file edits, copy changes, config tweaks, adding a flag, bug fixes with an obvious root cause"* — implement inline, full depth, zero ceremony. The clearer the mechanics definition, the less reflexive escalation.

3. **The always-loaded token budget target.** Measure the current surface: `wc -l CLAUDE.md`, count auto-loaded rules, count agent description lengths. Set a target (e.g. `CLAUDE.md` under ~400-600 LOC for a typical project, agent descriptions one line each). The target is what the depth-signature checklist tests against.

## Authoring guidance — what to write into the final artifact

This discipline lands in **`CLAUDE.md` "How You Work"** (the always-loaded surface — it governs the first decision of every session). Three pieces:

A one-line headline:

```markdown
**Depth by default, ceremony on demand.** Go all-in on understanding the problem (read the load-bearing code, find the root cause, propose the real fix). Do NOT spin up subagents, audit chains, or conformance matrices reflexively — they fire only when a row below matches or the user asks. Everything else is pure mechanics: implement inline, at full depth, no added process.
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

A one-line context-budget note:

```markdown
**Context budget.** The always-loaded surface (this file + auto-loaded rules + agent descriptions) costs tokens every session — keep it lean. Agent/skill descriptions stay one line; prefer pointers over inlined content; cheapest tier that solves the problem wins (see `.claude/rules/audit-routing.md`). Junk stays out of context via `.claudeignore`.
```

And ensure a `.claudeignore` exists at the project root covering build output, generated files, vendored deps, and large fixtures. If one doesn't exist, author a starter.

## Depth signatures — what battle-tested looks like

The authored discipline fails the bar if it lacks any of these:

1. **A "Depth by default, ceremony on demand" line exists in `CLAUDE.md` "How You Work"** — not buried in a sub-file, because it governs the first decision of every session.

2. **The escalate table has concrete, observable triggers** — *"includes a DB migration," "spans multiple modules"* — not *"complex work"* or *"important changes."* Test: can you point at the diff or request and say which row fired?

3. **Every trigger maps to a specialist or process that actually exists** in `.claude/`. No rows for agents the project doesn't have (same rule as `audit-routing.md`).

4. **"Pure mechanics" is named explicitly** as the default path, so sessions know the table is a *gate*, not a *menu* — most tasks match no row and ship inline.

5. **Agent and skill descriptions are one line each.** Test: `grep -A1 '^description:' .claude/agents/*.md` — multi-line descriptions are context tax on every session.

6. **`CLAUDE.md` is within the budget target** (e.g. under ~400-600 LOC). Test: `wc -l CLAUDE.md`. A 1500-line file taxes every task.

7. **A `.claudeignore` exists** and covers build artifacts, generated files, and large fixtures.

8. **The context-budget note cross-references the cost ladder** in `audit-routing.md` rather than restating it.

9. **No multi-second command runs per edit.** Test: read the `PostToolUse` `Write|Edit` hooks — none should invoke a linter/type-checker/test that takes seconds. Those belong in `lint-staged` + the Definition of Done, run once, not per edit.

10. **`Write|Edit` checks are consolidated into one dispatcher.** Test: count registered `PostToolUse` `Write|Edit` hooks — many separate scripts mean many process spawns per edit; collapse to a single dispatcher.

## Anti-patterns to avoid

- **Agents-by-reflex.** Dispatching the design pipeline / pre-flight / a conformance matrix on a one-line change because it "felt like a feature." Tens of thousands of tokens for nothing. The table is the gate; if no row fired, implement inline.

- **Confusing "go lean" with "go shallow."** This is the worst misread. Lean means *less process*, never *less understanding*. A lean session still reads the load-bearing code and finds the root cause — it just doesn't wrap that in machinery. If the discipline produces shallow fixes, it was misapplied.

- **`CLAUDE.md` that grew to 1500 LOC.** Every section inlined, nothing pointered out. Every session pays the full read. Compress to identity + routing table + the lean headline; pointer the rest.

- **Escalation table with vague triggers.** *"Escalate when the work is complex / important / risky."* Unobservable, so it fires on everything or nothing. Triggers must be readable off the diff or the request.

- **Escalation table used as a menu, not a gate.** Treating the rows as *"things I may do"* rather than *"the only conditions under which I add ceremony."* The default is no ceremony; the table is the exhaustive list of exceptions.

- **Multi-line agent descriptions.** A paragraph in the `description` field loads on every session whether the agent runs or not. One line; depth in the body.

- **No `.claudeignore`.** Generated files, build output, and giant fixtures swept into context, taxing every read for zero benefit.

- **"Just to be safe" as a trigger.** Safety comes from depth, not from spinning up agents. If you can't name the row that fired, the safe-feeling escalation is just waste.

- **Heavy commands on every edit.** A per-edit `eslint --fix` / type-check / test run that's already covered by `lint-staged` + the Definition of Done: the same check paid dozens of times, seconds each. Run it at commit and at done, not per write.

- **A pile of separate `Write|Edit` hooks.** Ten registered hooks = ten process spawns per edit. Consolidate into one dispatcher that runs every check in-process.

## Cross-references

- `operating-principles.md` — principle 4 is the headline of this doc: depth is mandatory, ceremony is on-demand. Principles 1-3 (the depth mandate) are what "depth by default" refers to.
- `audit-routing.md` — the cheapest-tier-wins cost ladder (Tier 0 hook → Tier 3 agent). The context-budget half cross-references it; don't restate the ladder.
- `task-classification.md` — Layer 3. The routing table and this escalate table are complementary: classification routes *what kind* of task; this gates *whether ceremony fires at all*.
- `knowledge-layers.md` — the layer model this doc sits in (Layer 3, cross-cutting into 2 and 6); the always-loaded surface is the Layer 1/3 boundary the context budget governs.
- `authoring-skills.md` — skill descriptions are part of the always-loaded budget; that doc's one-line-description guidance is the same discipline applied to skills.
