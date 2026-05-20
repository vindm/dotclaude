# `/dotclaude:planning` interview

3-4 questions, adaptive. Skip what Phase 1 (project scan) already answered. The goal: confirm coupling shape, surface the kinds of changes pre-flight should anticipate, and decide whether the audit-routing rule earns its keep.

## P1 — Change shape (skip if obvious from Phase 1)

> "Looking at your recent commits, the median seems to touch <N> files across <M> top-level modules. Does that match your felt sense, or does it understate / overstate? When you imagine the typical change you make, is it 'one file, one concept' or 'one feature, four modules'?"

If single-file-one-concept dominates: float skipping the pre-flight agent entirely. Pre-flight is overhead on a flat codebase. Confirm the user wants it before proceeding.

If multi-module dominates: confirm and move to P2.

## P2 — Cross-module coupling (THE most important question)

> "Name 2-3 'kinds of change' that regularly touch multiple parts of your codebase. Not specific PRs — patterns. Examples of the shape:
> - 'Auth changes touch UI + API + DB'
> - 'New job type touches the queue + the worker + the consumer + the DB enum'
> - 'New screen touches the router + the navigation types + the screen file + the back-end endpoint'
> - 'Schema changes touch the migration + the type-gen + the API + the UI form'"

These named patterns are what the pre-flight agent's integration-point map encodes. WITHOUT this question, the agent's territory-mapping section is generic and pre-flight loses most of its value.

Listen for the patterns that have surfaced reverts. "We always forget X" is gold — the X is a pre-flight check that should fire automatically.

Cross-check with the revert history from Phase 1. If the user names a pattern that matches a real revert (e.g., "we keep forgetting to invalidate the cache" and you found a `revert: cache invalidation fix` commit), the pattern goes into the agent's "Do NOT" section explicitly.

## P3 — Pre-impl review posture

> "Honestly: when you start a non-trivial change, do you actually pause to map it out, or is your workflow more 'write code, fix what breaks'?
>
> No judgment — both are legitimate. The answer shapes whether pre-flight is helpful (validates intent before code) or friction (slows the iterate-on-the-real-code-flow you prefer)."

If write-then-fix: the agent should be optional, lighter, and explicitly opt-in. Tell the user they can skip pre-flight on simple changes and reach for it only when about to do a big refactor.

If pause-and-map: the agent is more central — wire it as a default reach for cross-module changes, and consider whether the user wants a routing rule promoting pre-flight on changes touching N+ modules.

## P4 — Audit pipeline order (only if `.claude/` will have 3+ audit agents)

> "Looking at your other domain-skill choices, you'll end up with these audit agents: <list — e.g. code-reviewer, pre-flight, ux-reviewer, data-auditor, tests-architect>. Two questions:
> 1. When you have a UI batch — say, you just finished a multi-screen redesign — what order should the audits fire?
> 2. Are there fixed sequences you'd want documented? (E.g., 'always run pre-flight before any change touching `lib/db/`', or 'after every schema change, run data-auditor.')"

If the user has no strong opinions: apply the canonical order from `audit-routing.md` — mechanical sweeps first (token / hex), semantic + a11y in parallel, visual polish last for UI; data-auditor after schema changes; tests-architect after any change to logic-bearing modules.

If the user has opinions: encode them. The user's actual workflow beats the generic order.

If fewer than 3 audit agents will end up in `.claude/` after all domain skills run, skip this question entirely — and skip authoring the routing rule (cognitive overhead exceeds value below that threshold).

---

## How to use this script

- Don't fire-hose. One or two questions per turn, conversational.
- Lead with data when you have it (Phase 1 has the change-shape signal, the revert history, the module count — use them in P1 and P2 rather than asking the user to recall from memory).
- Skip ruthlessly. Single-file utility with 1 module → skip everything and tell the user pre-flight isn't earning its keep here.
- Listen for "I always forget" / "we always miss" — every one is an anti-pattern entry waiting to be named.

## After the interview

Summarize back before authoring:

> "Based on our chat: pre-flight applies to <N> kinds of change you described, with integration-point map covering <list of modules / boundaries>, and <count> 'Do NOT' entries derived from your revert history. Audit-routing rule = <yes / no, because < 3 agents>. About to author the kit — confirm?"

Wait for confirmation, then proceed to Phase 4 of `SKILL.md`.
