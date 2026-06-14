# handoff — conscious session handoff before context loss

Teaching material for Claude Code. When you bootstrap a project's AI dev infrastructure, this doc teaches you HOW to install a session handoff discipline: a small skill plus a routing rule that captures in-flight state before a `/clear`, an auto-compaction, or the end of a long session erases it. Layer 3 of the v2 hierarchy (Process Discipline). The premise is that context loss is *lossy and narrative-biased* — auto-compaction keeps the story and drops the operational detail (the next action, the failed approaches, the WHY behind a half-made decision). A conscious handoff is the antidote: you decide what survives instead of letting the summarizer decide for you.

## When to ship one (applicability gate)

Ship a handoff discipline when:

- The project has long multi-session work — features that span days, plans that outlive a single context window.
- The user hits `/clear` frequently, or sessions routinely run long enough to trigger auto-compaction.
- The user has felt the pain: a fresh session re-proposed an approach the previous session already ruled out, or asked *"where were we?"* and couldn't answer from the artifacts.
- Work regularly ends with uncommitted state and an unstated next step.

Skip when:

- The project is one-shot or single-session — open it, finish the task, never return.
- Every task fits comfortably in one context window with margin to spare.
- The user starts each session fresh by design and treats carried-over state as friction.

The default bias is **ship a minimal version** for any project expected to live > 2 weeks. Minimal means exactly two things: the routing rule (one piece of state, one home) and the quality gate (the `/clear` test below). Even that much prevents the most expensive failure — a fresh session re-deriving a dead end the last session already burned hours on.

## Why it matters — what this catches that nothing else does

Auto-compaction and `/clear` both throw away in-flight state, and they do it with a narrative bias — they keep what reads like a story and drop what reads like scaffolding. Three failure modes follow:

- **The next session re-runs a failed approach.** The previous session tried approach A, hit a wall, and switched to B. Compaction keeps *"we're doing B"* but drops *"A doesn't work because of X."* The fresh session sees B in progress, wonders why not A, tries A, and re-burns the same hours. The don't-retry set is the single most valuable thing handoff preserves, and it's the first thing compaction discards.

- **The next action is lost, so the session flails.** Mid-task, the operative next step lives in working memory — *"now wire the new validator into the request path."* After a `/clear` that step is gone; the fresh session reads the code, sees plausible-looking work, and either re-does finished work or picks a different (wrong) next step. The session spends its first 20 minutes reconstructing a state that one sentence would have carried.

- **A durable lesson evaporates into chat history.** During the session you learned a footgun (*"this build target silently caches; always clean first"*) or settled a decision rationale. If it isn't routed to a memory file before the context closes, it lives only in the transcript — recoverable in theory, never actually re-read in practice. The lesson dies, and the project re-learns it the expensive way.

The cost asymmetry is the usual one: a conscious handoff costs a few minutes of deliberate writing at the end of a session; the failure modes cost hours at the start of the next one, repeatedly.

## Core methodology — route each state piece to its home

The discipline is a routing rule first and a document second. The rule: **one piece of state, one home.** Each kind of in-flight state has exactly one correct destination. Putting state in the wrong home (or in two homes) is where handoffs rot.

| State piece | Home | Why there |
|---|---|---|
| Durable fact — a footgun learned, a user preference, a decision rationale | A memory file, typed per `memory-system.md` | These are cross-conversation factoids that outlive the current plan. Memory is the always-loaded surface a fresh session reads. |
| Plan progress — what's done, what's next, conformance status | The owning plan/spec doc's "resume" banner or conformance matrix | Plan status belongs *with the plan*, not in memory. Memory is for factoids; a plan's state is the plan's own concern. |
| Orphan WIP — work in flight with no natural home | An ephemeral handoff doc (`docs/handoffs/<date>-<slug>.md`) + a one-line pointer from memory | When state belongs to neither a memory factoid nor a tracked plan, it needs a temporary home. The doc is consumed by the next session, then archived. |

Two routing details carry most of the value:

- **Memory entries stay short and lead with the rule.** A durable fact routed to memory follows the memory-system shape: lead with the rule, then the WHY, then how-to-apply. *"Never X — because Y — fires when Z."* Do not dump the session narrative into memory; that defeats lazy-loading and buries the rule.

- **Plan progress goes to the doc, never to memory.** The single most common routing mistake is writing *"finished sub-plan 3"* into a memory file. That duplicates the conformance matrix and creates two sources of truth that drift. Plan state lives in the plan doc; memory holds at most a one-line pointer to it.

### The quality gate (the test)

Every handoff must pass one question:

> *"If I `/clear` right now and a fresh session reads ONLY this handoff + CLAUDE.md + the memory index, does it know the NEXT action, the WHY, and the don't-retry set (the approaches already tried and ruled out)?"*

If the answer is no — if the fresh session would have to reconstruct any of those three from the transcript — the handoff is incomplete. The three pieces are not optional:

- **The next action** — the single concrete thing to do next, stated as a verb.
- **The WHY** — the reason the work is shaped the way it is, so the next session doesn't "fix" a deliberate choice.
- **The don't-retry set** — the approaches already tried and why they failed, so nobody re-burns the dead ends.

A handoff that lists what was *done* but not what's *next* fails the gate. A handoff that states the next action but omits why approach A was abandoned fails the gate. The gate is the whole discipline compressed into one check.

### WIP-commit, never stash

When the handoff includes uncommitted work, commit it as WIP on a branch — do not `git stash`. A stash is invisible state attached to no branch and no history; if the next session (or a hook, or a killed pipeline) doesn't know to `git stash pop`, the work is silently stranded and eventually lost. A WIP commit on a branch is visible in `git log`, survives a `/clear`, and is trivially amended or rebased later. Cross-reference the project's git-safety / uncommitted-on-clear hooks if it has them: those hooks are the automated backstop, and WIP-commit is the manual discipline that makes them coherent.

## How to derive THIS project's specifics

Before authoring the handoff artifact, gather:

1. **Where do plans live?** Find the plan/spec directory (commonly `docs/plans/` or `docs/specs/`) so plan progress routes *there*. If the project uses conformance matrices (`docs/audits/`), the resume state lives in the matrix. No plan home means the routing table's middle row collapses into the ephemeral-doc row.

2. **Where does memory live?** Per `memory-system.md` — usually `~/.claude/projects/<hash>/memory/` with the `MEMORY.md` index. Durable facts route here; confirm the path and the index exists before pointing handoffs at it.

3. **Is there a `docs/handoffs/` home?** If not, propose one (with a `.gitkeep`). Confirm the project wants ephemeral handoff docs versioned in the repo versus living outside it.

4. **Does the project hit `/clear` or auto-compaction often?** Ask the user directly. High frequency justifies the full skill + directory; low frequency justifies the minimal version (routing rule + quality gate in a rule file, no dedicated skill).

## Authoring guidance — what to write into the final artifact

The handoff discipline lands in **two** places (three if the project takes the ephemeral-doc home).

### Place 1 — `.claude/skills/handoff/SKILL.md`

A skill the user invokes (or that fires) before context loss. Shape:

```markdown
---
name: handoff
description: Capture in-flight state before /clear, auto-compaction, or end of a long session.
---

# handoff

**Trigger:** before a `/clear`, when context is filling toward auto-compaction, or at the end of a long working session with state still in flight.

## Routing checklist — one piece of state, one home
- Durable fact (footgun / preference / decision rationale) → memory file, typed per memory-system. Lead with the rule + why + how-to-apply. Keep it short.
- Plan progress (done / next / conformance) → the owning plan or spec doc's resume banner or conformance matrix. NOT memory.
- Orphan WIP with no natural home → `docs/handoffs/<date>-<slug>.md` + a one-line pointer from the memory index.
- Uncommitted work → WIP commit on a branch. Never `git stash`.

## Quality gate — the test
Ask: *"If I /clear now and a fresh session reads ONLY this handoff + CLAUDE.md + the memory index, does it know the NEXT action, the WHY, and the don't-retry set?"*
If no, the handoff is incomplete — fix it before clearing.
```

The skill body is short on purpose: it is a runbook, not a doc. The depth (memory typing, plan conformance) lives in the cross-referenced principles.

### Place 2 — `CLAUDE.md` pointer

One line in `CLAUDE.md` so every session knows the discipline exists:

```markdown
**Before /clear or when context is filling:** run the `handoff` skill — route durable facts to memory, plan progress to the plan doc, orphan WIP to `docs/handoffs/`; WIP-commit, never stash. Quality gate: a fresh session must know the next action, the WHY, and the don't-retry set.
```

### Place 3 — the `docs/handoffs/` directory

If the project takes the ephemeral-doc home, create `docs/handoffs/` with a `.gitkeep` so the directory exists before the first handoff needs it. Each handoff doc is consumed by the next session and then archived (move to `docs/archive/handoffs/` once acted on) — it is ephemeral by design, not a permanent record.

## Depth signatures — what battle-tested looks like

The authored handoff discipline fails the depth bar if it lacks any of these signals.

1. **Routing is explicit.** The skill names all three state-to-home mappings, not a vague *"write down what you were doing."* A reader can route any piece of state without judgment calls.

2. **The quality gate is present and verbatim.** The `/clear` test appears in the skill body with its three required pieces (next action, WHY, don't-retry set). A handoff discipline without the gate is just a note-taking suggestion.

3. **WIP-commit-not-stash is stated.** The skill explicitly forbids `git stash` for handoff and prefers a WIP commit on a branch. Without this, killed pipelines strand work.

4. **Handoff docs are ephemeral and archived.** The discipline says handoff docs are consumed-then-archived, not accumulated. A `docs/handoffs/` that only grows is a symptom the archive step isn't running.

5. **Memory entries stay short.** Durable facts routed to memory follow the memory-system shape (rule-first, one factoid per entry), not dumped session narratives. Test: a handoff-sourced memory entry reads like a rule, not like a chat log.

## Anti-patterns to avoid

- **Dumping everything into one giant memory file.** The whole session state — narrative, plan status, WIP, the lot — pasted into a single memory entry. This buries the load-bearing rules, defeats lazy-loading, and mixes lifecycles (a permanent footgun next to throwaway WIP). Route each piece to its own home.

- **Plan progress duplicated in both memory and the doc.** *"Finished sub-plan 3"* written into a memory file *and* the conformance matrix. Two sources of truth that drift; the next session can't tell which is current. Plan state lives in the doc only; memory holds at most a pointer.

- **A handoff doc that omits the don't-retry set.** It lists what was done and what's next but says nothing about the approaches already tried and ruled out. The next session re-discovers the dead ends — the exact failure handoff exists to prevent. The don't-retry set is mandatory, not optional.

- **Using `git stash` for handoff.** Stashed work is attached to no branch and invisible in `git log`. A killed pipeline or an unaware next session strands it, and it gets lost. WIP-commit on a branch instead.

## Cross-references

- `memory-system.md` — Layer 3. Durable facts route to typed memory; handoff is the *moment* memory typing gets applied (a footgun → feedback entry, a preference → user entry). Handoff feeds memory; memory defines the shape.
- `plan-driven-work.md` — Layer 3. Plan progress routes to the plan doc's resume banner or conformance matrix, never to memory. Handoff is how plan state survives a context boundary mid-plan.
- `knowledge-graph.md` — Layer 5. `docs/handoffs/` lives in the project knowledge graph alongside specs, plans, and audits; ephemeral handoff docs archive to `docs/archive/handoffs/` like other graph artifacts.
- `operating-principles.md` — Layer 0. Conscious-over-lossy is an operating principle; handoff is its concrete process expression for the context-loss boundary.
- `lean-by-default.md` — Layer 0. The minimal-version bias (routing rule + quality gate, skip the dedicated skill for low-frequency projects) is lean-by-default applied to this discipline.
