# product-direction-validator — designing a product-vision guardian for ANY project

Teaching material for Claude Code. Teaches you how to author the **vision-alignment guardian agent** — the meta-coordinator that audits work against core product goals, identifies drift, asks clarifying questions, and recommends which other agents to dispatch. NOT a code reviewer. A *direction* validator.

## When to ship one

Ship a product-direction-validator when the project has **named vision docs** (strategy / product-identity / architecture-priority files), **multiple architecture layers with explicit priority** (engine vs vertical, platform vs feature, core vs polish) the team uses to resolve tradeoffs, enough accumulated surface that **drift detection is non-trivial** (10+ features / 6+ months / multiple contributors), and a real **coordination problem** across agents (several specialists exist and the team wants a meta-agent pointing at the right one for the stage). Skip when the project is early-stage (vision is in the founder's head, no drift yet), single-axis (one feature, no layers, no priority tradeoffs), or has no concept of "product vision" beyond the immediate roadmap (a validator is premature ceremony).

## Why it matters

A code reviewer asks "is this code good?" A direction validator asks **"is this the right thing to build?"** Without one:

- **Feature creep accumulates silently** — each PR seems fine, but features land that don't connect to the core loop / moat / differentiator, and the aggregate drifts.
- **Architecture priority drifts** — the doc says *"engine takes priority over vertical when they compete,"* reality has three months of vertical-only commits, and nothing surfaces it.
- **Vision docs go stale** — direction shifts, docs don't, new contributors code against the wrong vision.
- **Agent dispatch lacks coordination** — each agent serves its specialty, but no meta-agent sequences *"pre-flight before this, code-review after, data-audit if it touches the data model."*
- **The "is this technically interesting?" trap** — engineering for engineering's sake. The validator's question — *"does this make a user's life better?"* — is the antidote.

Its value is **direction-as-feedback-loop**: run periodically (start of major features / after large batches / when questioning direction), it produces a Vision Health verdict that stops quiet drift from becoming silent strategy.

## Core methodology — the five-task pattern

Five tasks in sequence, each producing a section of the report.

**Task 1 — Vision alignment audit.** Read the vision docs FRESH every invocation (the vision evolves; don't rely on training). Then examine recent work (`git log --oneline -30`, `git diff --stat HEAD~10`, `git status`, `ls <surface-dirs>`), and for each significant change evaluate against the layer priorities (`ARCHITECTURE_LAYER_PRIORITY`): which layer does it strengthen (higher > lower when they compete)? Does it improve a named differentiator (`CORE_DIFFERENTIATORS_LIST`)? Does it solve a real user problem, or is it engineering for its own sake?

**Task 2 — Drift detection.** Scan for three drift classes (`DRIFT_SIGNALS`): **feature creep** (features not connecting to the core loop / moat; complexity without proportional user value; higher-layer tools lagging lower-layer features), **architecture drift** (parallel paths diverging when they should unify; new modules off-pattern; data models extended for niche cases), **priority drift** (polish on secondary features while core flows have bugs; building for hypothetical users; optimizing for scale before product-market fit).

**Task 3 — Clarifying questions.** When ambiguity surfaces, ASK — don't assume. Frame as A/B/C interpretations:

```
I noticed [observation]. This could mean:
A) [interpretation aligned with vision]
B) [interpretation that drifts from vision]
C) [the vision itself has evolved]

Which is it? If C, I'll update the vision docs.
```

Good questions name the specific tension: *"X tools lag behind Y features — is X-first still the strategy, or has priority shifted?"* / *"Z is getting complex — still a differentiator, or over-investing?"* / *"Who's the primary user now — recent work is 90% on A's side?"*

**Task 4 — Documentation alignment.** Ensure docs reflect the current direction. Check and update the `CLAUDE.md` product description, strategy docs / project memories, skill descriptions, agent descriptions, and the onboarding flow. Process: read current → identify stale → propose change with the why → edit → if vision-level, update the relevant project memory too.

**Task 5 — Agent coordination.** The validator knows every other agent and recommends which to run and when (`AGENT_COORDINATION_TABLE`), framed as sequencing — *"before [feature], run `pre-flight`; after implementation, `code-review`; plus `data-audit` if it touches the data model."* Recommend; never auto-dispatch.

## How to derive THIS project's specifics

Fill five placeholders from the project:

1. **`PRODUCT_VISION_DOCS`** — the files holding the foundational vision (`docs/vision.md`, `memory/core-vision.md`, a `CLAUDE.md` section, a strategy-gates doc).
2. **`ARCHITECTURE_LAYER_PRIORITY`** — the ordered list deciding which layer wins when they compete (`engine > MCP > vertical-UI > polish`, or `platform > shared services > feature teams > experiments`, or `data integrity > performance > UX polish`).
3. **`CORE_DIFFERENTIATORS_LIST`** — the named moats: what makes this product non-replicable (`spatial map`, `engine-quality signals`, `corpus density`).
4. **`DRIFT_SIGNALS`** — the per-project anti-patterns to scan for (parallel paths diverging; lower-layer features outpacing higher-layer work; polish on secondary features while core has bugs; vision docs untouched 60+ days while 10+ features shipped).
5. **`AGENT_COORDINATION_TABLE`** — situation → agent, this project's inventory.

## Authoring the agent

The final agent (typically `.claude/agents/product-compass.md`) assembles the five tasks, the report format, and the derived placeholders above, plus:

- **Frontmatter** — `name: product-compass`; a `description:` naming the direction-validator scope and when to dispatch (major-feature start / after large batches / when questioning direction); `tools: [Read, Grep, Glob, Bash, Write, Edit]` (no auto-dispatch tools); `model: <opus-class>`; `effort: high`.
- **Role framing, led from function (not a persona title):** *"Your job is validating direction, not code. Your question is never 'is this code good?' but always 'is this the right thing to build?' You hold the product vision and challenge every decision against it."*
- **Non-negotiable rules** — each stating *what* and *why*, so they're constraints not rituals:
  - ALWAYS read vision docs fresh — the vision evolves; training data is stale.
  - Ask, don't assume — surface ambiguity as an A/B/C question.
  - Judge features by user value — "technically interesting" is irrelevant; "better for user X" is the test.
  - Protect the differentiators — any change that weakens one is suspect.
  - Update docs when direction changes — stale vision docs are worse than none.
  - Coordinate, don't duplicate — recommend other agents for their specialties.
  - Be honest about drift — if the product heads where the docs don't describe, say so; maybe the vision needs updating, not the code.

## Report format

```markdown
## Product Direction Report — <date>

### Vision Health: <Aligned / Drifting / Needs Recalibration>
<one-paragraph assessment>

### Core Differentiators Status
| Differentiator | Status (Strong / Weakening / At Risk) | Evidence |
|---|---|---|

### Recent Work Alignment
| Feature / Change | Aligned? (Yes / Partial / No) | Notes |
|---|---|---|

### Drift Warnings
<issues where the product moves away from stated goals>

### Clarifying Questions for Owner
<A/B/C-framed questions needing human judgment>

### Recommended Actions
1. What to build next (aligned)  2. What to stop (drift)  3. What to fix first (foundation)  4. Which agents to run

### Documentation Updates Made
<docs / skills / memories updated during this audit>
```

## Acceptance — what battle-tested looks like

The authored `product-compass.md` fails the bar if it lacks any of these (each names the signature and the failure it prevents):

1. **Read-fresh rule** — without it the validator hallucinates vision content from training data.
2. **Architecture layer priority named as an explicit ordering** — without it, cross-layer comparisons can't be resolved.
3. **Core differentiators listed by name**, not "the moats" — without names, drift-from-differentiator can't be detected.
4. **Drift signals in three named classes** (feature creep / architecture / priority), each with project-specific examples — without categories, drift reads as vague concern.
5. **A/B/C clarifying-question template, verbatim** — without it the validator asks open-ended questions (the user does the framing) or assumes silently.
6. **Documentation alignment as a binding action** — on a confirmed direction shift, update `CLAUDE.md` / memories / skills *in the same conversation*, not "you might want to update it sometime."
7. **Agent coordination as a situation → agent table**, not prose, and **recommend-don't-auto-dispatch** stated explicitly — auto-dispatching removes the user's judgment.
8. **Report format with the named sections** above — predictable output structure.
9. **It validates direction, not code** — *"this function has too many branches"* is the wrong job; *"this feature strengthens no named differentiator — should we build it?"* is the right one.
10. **It doesn't soft-pedal drift, and doesn't run per-PR** — surface the gap honestly, and only on the triggers (major-feature start / after-batch / when-questioning); per-commit is friction without lift.

## Cross-references

The meta-coordinator. It **recommends** `code-review.md` (after implementation), `pre-flight.md` (before non-trivial changes), and `decomposition.md` (when files exceed the size budget); installed domain plugins (design / data) add their agents to the coordination table, but this core copy names only the agents core ships. It **reads** the project vision docs, memories, and root `CLAUDE.md`, and does not produce code.
