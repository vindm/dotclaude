---
name: handoff
description: Consciously capture in-flight state before context loss — a /clear, an auto-compaction, or the end of a long session. Routes durable facts to memory, plan progress to the plan doc, orphan WIP to an ephemeral handoff doc, and WIP-commits rather than stashing. Invoke before clearing context, when context is filling toward auto-compaction, or at the end of a long working session with state still in flight.
---

# Handoff — conscious session handoff before context loss

Context loss is lossy and narrative-biased. Auto-compaction and `/clear` keep what reads like a story and drop what reads like scaffolding — the next action, the failed approaches, the WHY behind a half-made decision. A conscious handoff is the antidote: you decide what survives instead of letting the summarizer decide for you. The cost is a few minutes of deliberate writing now; the failure it prevents — a fresh session re-burning hours on a dead end the last session already ruled out — costs hours, repeatedly.

## Route each piece of state to its one home

One piece of state, one home. Putting state in the wrong home (or two homes) is where handoffs rot.

- **Durable fact** — a footgun learned, a user preference, a decision rationale → a **memory file**. Lead with the rule, then the WHY, then how-to-apply (*"never X — because Y — fires when Z"*). Keep it short; do not dump the session narrative into memory — that buries the rule and defeats lazy-loading.
- **Plan progress** — what's done, what's next, conformance status → the owning **plan or spec doc's resume banner / conformance matrix**, never memory. Writing *"finished step 3"* into memory duplicates the plan and creates two sources of truth that drift. Memory holds at most a one-line pointer.
- **Orphan WIP** — work in flight with no natural home → an **ephemeral handoff doc** (under the project's handoffs directory, dated-and-slugged) plus a one-line pointer from the memory index. It is consumed by the next session, then archived — ephemeral by design, not a permanent record.

## WIP-commit, never stash

When the handoff includes uncommitted work, commit it as WIP on a branch — never `git stash`. A stash is invisible state attached to no branch and no history; a killed pipeline or an unaware next session strands it and it is silently lost. A WIP commit is visible in `git log`, survives a `/clear`, and is trivially amended or rebased later.

## The quality gate — the test every handoff must pass

> *"If I `/clear` right now and a fresh session reads ONLY this handoff plus the project's always-loaded guidance and the memory index, does it know the NEXT action, the WHY, and the don't-retry set?"*

The three pieces are mandatory, not optional:

- **The next action** — the single concrete thing to do next, stated as a verb.
- **The WHY** — the reason the work is shaped the way it is, so the next session doesn't "fix" a deliberate choice.
- **The don't-retry set** — the approaches already tried and why they failed, so nobody re-burns the dead ends. This is the single most valuable thing a handoff preserves and the first thing compaction discards.

If the answer is no — if the fresh session would have to reconstruct any of the three from the transcript — the handoff is incomplete. Fix it before clearing.

## To run this skill

1. Find where plans live and where memory lives in *this* project before routing — don't assume paths.
2. Sort the in-flight state: each durable fact → memory; plan progress → the plan doc; orphan WIP → an ephemeral handoff doc with a memory pointer.
3. WIP-commit any uncommitted work on a branch.
4. Run the quality gate. If it fails, write the missing piece, then clear.
