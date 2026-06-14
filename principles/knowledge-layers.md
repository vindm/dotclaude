# knowledge-layers — teaching authority order across `.claude/`, code, and `docs/`

Teaching material for Claude Code. When you bootstrap a project's AI dev infrastructure, this doc teaches you HOW to author the *authority-order doctrine*: the rule that tells every future session which of the three knowledge layers wins when they disagree. It belongs to Layer 5 (Knowledge Graph) but cuts across all of them. Where `knowledge-graph.md` teaches the `docs/` subdirectory taxonomy — how to *organize* the reflection-and-intent layer — this doc teaches how the three layers *rank against each other*. Read `knowledge-graph.md` for the `docs/` lifecycle and naming conventions; this doc does not restate them.

## When to ship one (applicability gate)

Ship the authority-order doctrine when:

- The project has any `docs/` that *describes* the code — architecture overviews, flow docs, a capabilities index, integration write-ups. The moment a doc paraphrases what code does, it can drift from code, and the agent needs a tiebreak rule.
- The project has had a *"the doc said X but the code does Y"* moment. That's the symptom of missing authority order.
- More than one session or contributor works on the project. The doctrine is what stops session N from trusting a doc session M wrote three months ago and never updated.
- The project ships skills or rules that cite specific docs. Those citations rot; the doctrine is what keeps them pointed at stable anchors instead.

Skip the full machinery when:

- The project is a single-script utility with no descriptive docs — code IS the documentation, so there's nothing to rank against it.
- The project is < 2 weeks old and has no reflection docs yet. The conflict can't happen until a doc describes code.

The default bias is **ship the doctrine line even for tiny projects** — one paragraph in `CLAUDE.md` stating `.claude/` → code → `docs/` with code as the tiebreak costs almost nothing and inoculates the project against doc-trust bugs from day one. The *full* archive-and-Read-deny machinery only earns its keep once `docs/` is non-trivial (an archive worth fencing off, dated artifacts worth not citing). For a tiny project, ship the line and defer the rest.

## Why it matters — what this catches that nothing else does

Without an explicit authority order, three failure modes recur:

- **Stale-doc trust ships a bug.** A flow doc says the retry limit is 3; the code raised it to 5 a month ago and nobody updated the doc. The agent reads the doc, "fixes" a call site back to 3 to match the documentation, and ships a regression. The doc looked authoritative because nothing told the agent it isn't. With the doctrine, the agent knows: verify the load-bearing number against code, and when they conflict, code wins.

- **Dangling dated-doc citations.** A rule or skill hard-cites `docs/specs/2026-03-04-billing-spec.md`. The spec shipped and got archived; the path now resolves to nothing. Every session that loads the rule chases a dead reference, or worse, treats the absence as "this concern no longer applies." With the doctrine, rules cite stable anchors (`docs/README.md`, a capabilities index, a folder convention) and discover the specific dated doc at runtime — so there's nothing to dangle.

- **An archived decision cited as current authority.** A six-month-old brainstorm proposed an approach that was later reversed. It still sits in `docs/`, readable, and a session finds it, takes it as the current plan, and builds against a direction the project abandoned. With the doctrine, superseded docs move to `docs/archive/`, which is Read-denied to the agent — kept for humans, fenced off from automated authority.

The deeper point all three share: **`docs/` is downstream of code, so it drifts, and drift is silent.** Code is executed, so it can't lie for long; a doc is never executed, so it can be wrong indefinitely and look fine. Pointing authority at code is how you stop trusting the layer that rots.

## Core methodology — the three layers and their authority order

Every project has three knowledge layers. They rank in a fixed authority order, and the order is what every other rule in this doc derives from.

1. **`.claude/` is GUIDANCE.** Rules, skills, invariants, conventions — *how to build* this project. It's intentional, hand-authored, and prescriptive. It tells the agent what discipline to apply. It does not describe what the system currently does; it describes how to act on it.

2. **Code is TRUTH.** It's what the system actually does, because it's the thing that runs. When you need to know real behavior — the actual retry limit, the actual auth check, the actual schema — you read code, not a description of code. Code is the tiebreak for every factual question about behavior.

3. **`docs/` is a REFLECTION of code, plus transient intent.** Two distinct things live here. *Reflection docs* (architecture overviews, flow docs, a capabilities index) are a downstream *description* of code — a navigable map, not an authority. *Transient intent* (brainstorms, plans) is forward-looking exploration that gets consumed when the work ships and then archived. Neither is authoritative about current behavior; only code is.

The rule that follows from the ranking:

> **Derive correctness from code + `.claude/`.** Reflection docs are a map to find the right code fast, not a source of truth about what that code does. Verify any load-bearing claim against code. When a doc and the code disagree, **code always wins** — every time, no exceptions.

This is *why* docs go stale and mislead: they're a description maintained by hand, decoupled from the thing they describe. The doctrine doesn't try to keep docs perfectly fresh (impossible at scale); it keeps *authority* pointed at the layer that can't silently lie.

Three consequences for how you author and maintain everything else:

- **Code → docs, never the reverse.** When you change code that a reflection doc describes, update that doc *in the same change*, or stale-mark it with a *"verify against code"* note. The flow of correctness is one-directional: code is the source, docs follow. You never edit a doc to declare new behavior and expect code to catch up — that inverts the authority order and manufactures drift.

- **Stable-anchor references.** Point rules and skills at canonical indexes (`docs/README.md`, a capabilities index) and at *folder conventions* (`docs/specs/`, `docs/audits/`), never at a specific dated artifact. Discover the specific doc at runtime by searching the folder (`ls docs/specs/ | grep billing`). A folder convention is permanent; a dated filename rots into a dangling reference the moment the doc archives or supersedes.

- **Archive out of reach.** Shipped and superseded docs move to `docs/archive/`, which is *Read-denied to the agent* via the harness permission system. The history is kept for humans (nothing is ever deleted — see `knowledge-graph.md`), but the agent can't read it, so an abandoned decision can't be mistaken for current authority. The archive is a human record, not an agent-readable one.

## How to derive THIS project's specifics

Before authoring the doctrine, audit:

1. **Does the project have reflection docs?** `ls docs/ 2>/dev/null && grep -rl "architecture\|flow\|overview\|capabilities" docs/ 2>/dev/null`. If docs describe code, the conflict rule applies and the full doctrine earns its keep. If there are no descriptive docs yet, ship only the one-paragraph line.

2. **Is there a `docs/README` index to anchor on?** Per `knowledge-graph.md`, the README is the navigation entry point. If it exists, anchor rule/skill references at it. If it doesn't, authoring the doctrine is a good moment to scaffold it — without a stable anchor, references have nothing permanent to point at.

3. **Is there an `archive/` convention?** `ls docs/archive/ 2>/dev/null`. If the project already archives aged-out docs, the Read-deny fence is the natural next step. If not, ship `docs/archive/*/` empty subdirs first (see `knowledge-graph.md`), then fence them.

4. **Is a Read-deny mechanism available?** Check whether the harness supports per-path permission denies (`settings.json` permissions with a `deny` list). If yes, add `docs/archive/**` to the deny list so the agent can't read archived docs. If the harness has no such mechanism, fall back to a strong convention line in `CLAUDE.md` (*"never treat `docs/archive/` as current"*) and accept it's softer than an enforced deny.

## Authoring guidance — what to write into the final artifact

The doctrine lands in two places: a paragraph in `CLAUDE.md` (always-loaded, so every session sees the authority order) and a permission entry in `settings.json` (the enforced archive fence).

### `CLAUDE.md` — the "Knowledge layers" paragraph

```markdown
**Knowledge layers (authority order).** This project has three knowledge layers,
ranked: **`.claude/` (guidance — how to build) → code (truth — what the system
does) → `docs/` (a reflection of code + transient intent).** Derive correctness
from code + `.claude/`. Reflection docs (`docs/` architecture / flows /
capabilities) are a map to find code fast, NOT an authority — verify any
load-bearing claim against code. **When a doc and the code disagree, the code
wins, every time.**

**Reference stable anchors only.** Rules and skills point at canonical indexes
(`docs/README.md`, the capabilities index) and folder conventions
(`docs/specs/`, `docs/audits/`) — never at a specific dated file. Discover the
specific doc at runtime (`ls docs/<folder>/ | grep <topic>`). Dated filenames
rot into dangling references; folder conventions are permanent.

**Archive is out of reach.** `docs/archive/` holds shipped / superseded docs.
It is kept for humans and Read-denied to the agent (see `settings.json`
permissions) — an abandoned decision must never be cited as current authority.
```

### `settings.json` — the archive Read-deny fence

Add `docs/archive/**` to the permission deny list so the agent cannot read archived docs:

```json
{
  "permissions": {
    "deny": ["Read(docs/archive/**)"]
  }
}
```

This is the enforced half of *"archive out of reach."* The `CLAUDE.md` paragraph states the policy; the deny pattern makes it real. If the harness lacks a deny mechanism, drop this block and rely on the convention line alone.

### Definition-of-Done addition

Add one line to the project's Definition of Done:

```markdown
- Reflection docs follow code: when a change alters behavior a doc describes,
  update or stale-mark that doc in the SAME change.
```

This is what makes code → docs discipline survive past the session that authored the doctrine. Without it, the rule is stated but never enforced at the moment it matters — and the docs drift exactly as predicted.

## Depth signatures — what battle-tested looks like

The authored doctrine fails the depth bar if it lacks any of these signals.

1. **The authority order is stated explicitly in `CLAUDE.md`**, with all three layers named and code as the named tiebreak. Test: `grep -i "code wins\|authority\|knowledge layer" CLAUDE.md` resolves.

2. **The "code wins on conflict" rule is unambiguous** — not *"prefer code"* but *"code wins, every time."* Hedged language invites the agent to trust the doc anyway.

3. **Rule and skill references use stable anchors**, not dated filenames. Test: `grep -rE "docs/[a-z]+/[0-9]{4}-[0-9]{2}-[0-9]{2}" .claude/` should be empty — any hit is a hard-cited dated artifact that will rot.

4. **`docs/archive/` is Read-denied** in `settings.json` (or, if no deny mechanism, a convention line exists). Test: `grep -r "docs/archive" .claude/settings*.json`.

5. **The Definition of Done includes the code → docs rule.** Without it, the discipline isn't enforced at change time.

6. **Reflection docs carry a `last-verified` date inside** (per `knowledge-graph.md`), so an agent reading one can judge how much to trust it before checking code.

7. **The doctrine cross-references `knowledge-graph.md`** for the `docs/` taxonomy rather than restating it. Test: the doc names the sibling, not the seven subdirectories.

If the authored doctrine lacks any of these, redo. The authority order is the cheapest insurance the project has against the most expensive class of bug: shipping behavior that matched a stale description instead of reality.

## Anti-patterns to avoid

- **Doc-as-authority.** Treating a flow doc or architecture overview as the source of truth and editing code to match it. The doc is downstream; code is the source. When they disagree, the doc is the thing that's wrong.

- **Hard-citing dated files in rules or skills.** `see docs/specs/2026-03-04-billing-spec.md` inside a rule. The spec archives, the path dies, and the rule now points at nothing. Cite the folder convention and discover the file at runtime.

- **Deleting history instead of archiving.** *"I removed the old brainstorm."* Now the *why* behind a reversed decision is gone, and the current direction looks arbitrary. Move to `docs/archive/` (fenced from the agent), never delete — see `knowledge-graph.md`.

- **Docs that drift because code → docs discipline isn't enforced.** The doctrine is stated in `CLAUDE.md` but the Definition of Done doesn't require updating docs alongside code. Every change widens the gap between description and reality until the reflection layer is pure fiction. State the rule AND enforce it in the DoD.

- **Leaving the archive readable.** `docs/archive/` exists but nothing fences it, so the agent reads superseded decisions as current. Either Read-deny the path or accept that the archive will be cited as authority.

- **Inverting the flow.** Authoring a doc that declares new behavior and expecting the code to be written to match it later. Specs and plans are *transient intent* (fine), but a *reflection* doc must never lead code — that's how the description and the truth come apart.

## Cross-references

- `knowledge-graph.md` — Layer 5, the sibling. It teaches the `docs/` subdirectory taxonomy, dated-vs-permanent naming, and the archive lifecycle. This doc teaches how the three layers rank; that doc teaches how the `docs/` layer is organized internally. Read both together.
- `authoring-skills.md` — *point, don't mirror.* The same anti-staleness instinct applied to skills: a skill that mirrors code drifts the same way a doc does, so skills point at code rather than restating it. The authority order is why.
- `memory-system.md` — Layer 3. Memory is a fourth knowledge surface with its own lifetime; it composes with these three but isn't ranked among them. The distinction matters when deciding whether a fact belongs in memory, a doc, or code.
- `skill-vs-code-audit.md` — Layer 6. The meta-audit agent that detects doc-vs-code drift is the *enforcement* arm of this doctrine: it finds the reflection docs that have fallen out of sync with code and flags them for update or stale-marking.
- `plan-driven-work.md` — Layer 3. Plans are the *transient intent* half of `docs/`: forward-looking, consumed when the work ships, then archived. This doc explains why they leave the active reading order once consumed.
