---
name: knowledge-layers
description: The authority order across a project's three knowledge layers — guidance (.claude/), code (truth), and docs/ (reflection + transient intent) — with code as the tiebreak when a doc and the code disagree. Load when reading or trusting a doc to make a code decision, when authoring rules or skills that reference docs, or whenever a load-bearing fact comes from a description rather than from the code itself.
---

# Knowledge layers — authority order

A project has three knowledge layers, and they rank in a fixed authority order. Most doc-trust bugs come from not knowing which one wins when they disagree.

1. **`.claude/` (or the project's guidance layer) is GUIDANCE.** Rules, skills, invariants, conventions — *how to build* this project. Intentional, hand-authored, prescriptive. It tells you what discipline to apply; it does not describe what the system currently does.

2. **Code is TRUTH.** It is what the system actually does, because it is the thing that runs. For any factual question about real behavior — the actual retry limit, the actual auth check, the actual schema — read code, not a description of code.

3. **`docs/` is a REFLECTION of code, plus transient intent.** *Reflection docs* (architecture overviews, flow docs, a capabilities index) are a downstream *description* of code — a navigable map to find the right code fast, not an authority on what it does. *Transient intent* (brainstorms, plans) is forward-looking exploration consumed when the work ships, then archived. Neither is authoritative about current behavior.

## The rule that follows from the ranking

**Derive correctness from code plus the guidance layer.** Verify any load-bearing claim against code. **When a doc and the code disagree, the code wins — every time, no exceptions.** This is not "prefer code"; it is code wins. Hedged language invites you to trust the doc anyway.

The reason: code is executed, so it can't lie for long; a doc is never executed, so it can be wrong indefinitely and look fine. `docs/` is downstream of code, so it drifts, and drift is silent. Pointing authority at code is how you stop trusting the layer that rots.

## Three consequences for how you work

- **Code → docs, never the reverse.** When you change code that a reflection doc describes, update that doc *in the same change*, or stale-mark it with a *"verify against code"* note. Correctness flows one direction: code is the source, docs follow. Never edit a reflection doc to *declare* new behavior and expect code to catch up — that inverts the authority order and manufactures drift. (Specs and plans are transient intent, and may legitimately lead code; a *reflection* doc must never lead it.)

- **Reference stable anchors only.** Point rules and skills at canonical indexes (a docs README, a capabilities index) and at folder conventions, never at a specific dated artifact. Discover the specific doc at runtime by searching the folder. A folder convention is permanent; a dated filename rots into a dangling reference the moment the doc archives or is superseded.

- **Archive is out of reach.** Shipped and superseded docs move to the archive, which is kept for humans and Read-denied to the agent. Nothing is deleted — the history survives for people — but the agent can't read it, so an abandoned decision can't be mistaken for current authority. Never cite an archived decision as current.

## Common failures to avoid

- **Doc-as-authority.** Reading a flow doc that says the retry limit is 3, "fixing" a call site back to 3 to match it, and shipping a regression because the code raised it to 5 a month ago. When a doc and the code disagree, the doc is the thing that's wrong.
- **Hard-citing a dated file** in a rule or skill. The doc archives, the path dies, the reference dangles — or worse, its absence reads as "this concern no longer applies." Cite the folder convention and discover the file at runtime.
- **Deleting history instead of archiving.** The *why* behind a reversed decision vanishes and the current direction looks arbitrary. Move to the archive, never delete.
- **Stating the doctrine but not enforcing code → docs at change time.** Every change then widens the gap between description and reality until the reflection layer is fiction. Update or stale-mark the doc in the same change.
