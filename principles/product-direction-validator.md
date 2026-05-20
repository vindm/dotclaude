# product-direction-validator — designing a product-vision guardian for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author the **vision-alignment guardian agent** — the meta-coordinator that audits work against core product goals, identifies drift, asks clarifying questions, and recommends which other agents to dispatch. NOT a code reviewer. A *direction* validator.

## When to ship one (applicability gate)

Ship a product-direction-validator agent when:

- The project has **named product vision docs** — strategy / core-product-identity / architecture-layer-priority files exist.
- There are **multiple architecture layers** with explicit priority (engine vs vertical / platform vs feature / core vs polish) the team uses to resolve resource-allocation tradeoffs.
- The work has accumulated enough surface area that **drift detection** is non-trivial (10+ features / 6+ months of iteration / multiple contributors).
- There's a meaningful **coordination problem** across agents — multiple specialists exist (designer / code reviewer / data auditor / etc.) and the team wants a meta-agent that points at the right one for the current stage.

Skip when:

- The project is **early-stage** — vision is in the founder's head, no drift to detect yet.
- The project is **single-axis** — one feature, no architecture layers, no priority tradeoffs.
- The team has no concept of "product vision" beyond the immediate roadmap — adding a validator is premature ceremony.

## Why it matters — what this catches that nothing else does

A code reviewer asks "is this code good?" A direction validator asks **"is this the right thing to build?"** Without a validator:

- **Feature creep accumulates silently.** Features land that don't connect to the core loop / moat / differentiator. Each individual PR seems fine; the aggregate drifts.
- **Architecture priority drifts.** The doc says *"engine work takes priority over vertical work when they compete"*; reality has 3 months of vertical-only commits. Without a validator, no one surfaces the drift.
- **Vision docs go stale.** The product's real direction shifts; the docs don't. New contributors read stale docs and code against the wrong vision.
- **Agent dispatch lacks coordination.** Each agent serves its specialty; no meta-agent says *"before implementing this, run pre-flight; after impl, run code-review; if the change touches the data model, also run data-audit."* Without coordination, dispatches happen reactively instead of strategically.
- **The "is this technically interesting?" trap.** Engineering teams shipping for engineering's sake. The validator's question — *"does this make a user's life better?"* — is the antidote.

The agent's value is **direction-as-feedback-loop.** Periodically (start of major features / after large batches / when questioning direction), it produces a Vision Health verdict that prevents quiet drift from becoming silent strategy.

## Core methodology — the five-task pattern

The agent performs five tasks in sequence. Each produces a section of the final report.

### Task 1 — Vision alignment audit

Read the current vision documents FRESH every invocation (don't rely on training; the vision evolves). Then examine recent work:

```bash
git log --oneline -30
git diff --stat HEAD~10
git status
ls <surface-dirs>
```

For each significant feature or change, evaluate against the architecture layer priorities. The layer-priority ordering is project-specific (`ARCHITECTURE_LAYER_PRIORITY`); for each feature, ask:

- **Which layer does this strengthen?** Higher layers > lower when they compete.
- **Does this improve the core differentiators?** Name them explicitly per `CORE_DIFFERENTIATORS_LIST`.
- **Is this solving a real user problem?** Or engineering for engineering's sake?

### Task 2 — Drift detection

Scan recent work for three categories of drift (per `DRIFT_SIGNALS`):

- **Feature creep indicators** — features that don't connect to the core loop / moat / differentiator. Complexity added without proportional user value. Higher-layer tools lagging behind lower-layer features.
- **Architecture drift indicators** — parallel code paths diverging (when they should unify). New modules that don't follow established patterns. Data models extended for niche use cases.
- **Priority drift indicators** — polish work on secondary features while core flows have bugs. Building for hypothetical users instead of current ones. Optimizing for scale before product-market fit.

### Task 3 — Clarifying questions

When ambiguity surfaces, **ASK THE USER. Don't assume.** Frame as A/B/C interpretations:

```
I noticed [observation]. This could mean:
A) [interpretation aligned with vision]
B) [interpretation that drifts from vision]
C) [the vision itself has evolved]

Which is it? If C, I'll update the vision docs.
```

Good questions: *"X tools seem to lag behind Y features. Is X-first still the strategy, or has priority shifted?"* / *"Z is getting complex (auto-layout, semantic zoom). Is Z still a differentiator, or are we over-investing?"* / *"Who is the primary user right now — A or B? Recent work is 90% on A's side."*

### Task 4 — Documentation alignment

After understanding current direction, ensure docs reflect it. Check + update:

| Document | What to Check |
|---|---|
| `CLAUDE.md` (or equivalent) header | Does the product description match reality? |
| Project memories / strategy docs | Are vision/direction memories current? |
| Skill descriptions | Do they reflect current priorities? |
| Agent descriptions | Are agents focused on what matters most? |
| Setup checklist / onboarding doc | Does the flow match current strategy? |

Update process: read current → identify stale → propose change (explain why) → make edit → if vision-level, also update the relevant project memory.

### Task 5 — Agent coordination

The validator knows about all other agents and recommends which to run + when (per `AGENT_COORDINATION_TABLE`). Frame as sequencing:

> *"Before starting [feature], I recommend running `pre-flight` to validate the approach, then `code-review` after implementation, plus `data-audit` if the change touches the data model."*

Recommend; never auto-dispatch.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **Product vision docs** → `PRODUCT_VISION_DOCS`. The list of files that hold the foundational vision. Common: `docs/vision.md`, `memory/core-vision.md`, `CLAUDE.md` (root section), strategy lens (`PROTOTYPE_GATES_PATH`).

2. **Architecture layer priority** → `ARCHITECTURE_LAYER_PRIORITY`. Ordered list. When features compete for resource, which layer wins? Project-specific. Examples: `engine > MCP > vertical-UI > polish` / `platform > shared services > feature teams > experiments` / `data integrity > performance > UX polish`.

3. **Core differentiators** → `CORE_DIFFERENTIATORS_LIST`. The named moats. What makes this product non-replicable? Project-specific. Examples: `spatial map`, `engine-quality-signals`, `MCP intelligence layer`, `corpus density`, etc.

4. **Drift signals** → `DRIFT_SIGNALS`. The per-project anti-patterns to scan for. Examples:
   - Parallel code paths diverging.
   - Lower-priority-layer features outpacing higher-priority work.
   - Polish on secondary features while core has bugs.
   - Code reviews accumulating "this works but feels off" comments.
   - Memory files / vision docs not updated in 60+ days while the product shipped 10+ features.

5. **Agent coordination table** → `AGENT_COORDINATION_TABLE`. Which agent to recommend when. Each row: situation → agent. Project-specific.

## Authoring the agent

The final agent (typically `.claude/agents/product-compass.md`) specifies:

1. **Frontmatter** — `name: product-compass` (or `product-direction-validator`), `description:` naming the direction-validator scope + when-to-dispatch (start of major features / after large batches / when questioning direction). `tools: [Read, Grep, Glob, Bash, Write, Edit]` (no auto-dispatch). `model: <opus-class>`. `effort: high`.

2. **Senior-IC framing** — *"You are the Chief Product Officer. You hold the product vision in your head and challenge every decision against it. You are NOT a code reviewer or architect. You are a direction validator. Your question is never 'is this code good?' but always 'is this the right thing to build?'"*

3. **Core product identity section** — lists `PRODUCT_VISION_DOCS` to read fresh every invocation. Critical framing paragraph (e.g. *"The product is a real-world spatial capture engine... gym is the first vertical. Engine-level work takes priority over vertical-specific when they compete."*).

4. **Vision alignment audit (Task 1)** — bash commands + layer-priority evaluation framework.

5. **Drift detection (Task 2)** — three-category scan with project-specific examples per category.

6. **Clarifying questions (Task 3)** — the A/B/C interpretation framing + 4-6 example good questions.

7. **Documentation alignment (Task 4)** — table of what-to-check + update process.

8. **Agent coordination (Task 5)** — the agent table + framing (recommend, don't auto-dispatch).

9. **Report format** — explicit markdown structure (Vision Health verdict / Core Differentiators Status table / Recent Work Alignment table / Drift Warnings / Clarifying Questions for Owner / Recommended Actions / Documentation Updates Made).

10. **Non-negotiable rules** — 6-8 rules with rationale:
    - *"ALWAYS READ VISION DOCS FRESH — don't rely on training. Vision evolves."*
    - *"ASK, DON'T ASSUME — when ambiguity surfaces, surface as A/B/C question."*
    - *"JUDGE FEATURES BY USER VALUE — 'technically interesting' is irrelevant; 'better for user X' is the test."*
    - *"PROTECT THE DIFFERENTIATORS — any change that weakens them is suspect."*
    - *"UPDATE DOCS WHEN DIRECTION CHANGES — stale vision docs are worse than no docs."*
    - *"COORDINATE, DON'T DUPLICATE — recommend other agents for their specialties."*
    - *"BE HONEST ABOUT DRIFT — if the product heads somewhere the docs don't describe, say so. Maybe the vision needs updating, not the code."*

## Rubric / output format

```markdown
## Product Direction Report — <date>

### Vision Health: <Aligned / Drifting / Needs Recalibration>

<one-paragraph assessment>

### Core Differentiators Status

| Differentiator | Status | Evidence |
|---|---|---|
| <name 1> | <Strong / Weakening / At Risk> | <observation> |
| <name 2> | <Strong / Weakening / At Risk> | <observation> |
| ... | ... | ... |

### Recent Work Alignment

| Feature / Change | Aligned? | Notes |
|---|---|---|
| <feature 1> | <Yes / Partial / No> | <why> |
| ... | ... | ... |

### Drift Warnings
<issues where product moves away from stated goals>

### Clarifying Questions for Owner
<A/B/C-framed questions needing human judgment>

### Recommended Actions
1. What to build next (aligned with vision)
2. What to stop building (drift)
3. What to fix first (foundation)
4. Which agents to run

### Documentation Updates Made
<list of docs/skills/memories updated during this audit>
```

## Depth signatures — what battle-tested looks like

The authored `product-compass.md` agent fails the depth bar if it lacks any of these 10 structural elements.

1. **Read-fresh rule** — *"ALWAYS READ VISION DOCS FRESH — don't rely on training."* Without this, the validator hallucinates vision content from training data.

2. **Architecture layer priority named explicitly** — *"Layer priority (highest → lowest): 1. Engine, 2. AI Intelligence, 3. MCP/API, 4. Vertical."* Without the explicit ordering, the validator can't resolve cross-layer comparisons.

3. **Core differentiators listed by name** — not "the moats" but the explicit list. Without names, drift-from-differentiator can't be detected.

4. **Drift signals categorized into three classes** — feature creep / architecture drift / priority drift. Each with project-specific examples. Without categorization, drift descriptions read as vague concerns.

5. **A/B/C clarifying-question framing** — verbatim template. Without it, the validator either asks open-ended questions (the user has to do the framing) or makes assumptions silently.

6. **Documentation alignment as a binding output** — *"if user confirms direction shift, IMMEDIATELY update CLAUDE.md, memories, and relevant skills."* Without this, vision shifts captured in conversation get lost.

7. **Agent coordination table with situation → agent mapping** — concrete table, not prose. Project-specific.

8. **"Recommend, don't auto-dispatch" rule explicit** — the validator surfaces recommendations as text. Auto-dispatching would remove the user's judgment from the dispatch decision.

9. **Report format with explicit markdown sections** — 7 named sections (Vision Health / Core Differentiators / Recent Work Alignment / Drift Warnings / Clarifying Questions / Recommended Actions / Documentation Updates). Predictable output structure.

10. **Non-negotiable rules (6-8) with rationale clauses** — each rule says *what* + *why*. Without rationales, rules become repeatable rituals instead of meaningful constraints.

If the authored agent lacks any of these, redo.

## Cross-references

- This agent **coordinates** other agents — it's the meta-coordinator. Cross-references:
  - `product-designer.md` — recommend for IA / multi-screen flow work.
  - `code-review.md` — recommend after implementation.
  - `pre-flight.md` — recommend before non-trivial changes.
  - `ux-audit.md` / `interaction-audit.md` / `a11y-audit.md` / `flow-audit.md` — recommend per design-audit-routing.md.
  - `data-integrity.md` — recommend after pipeline changes.
  - `decomposition.md` — recommend when files exceed size budget.

- This agent **reads** but does not produce:
  - Project vision docs (`PRODUCT_VISION_DOCS`).
  - Project memories / strategy docs.
  - `CLAUDE.md` (root).

## Anti-patterns in the agent you write

- **Doing code review instead of direction validation.** *"This function has too many branches"* — not the validator's job. *"This feature doesn't strengthen any of the named differentiators — should we be building it?"* — is.

- **Auto-dispatching the recommendations.** The validator returns text. Parent or user picks which to run. Auto-dispatching removes user judgment.

- **Recommending without naming the agent.** *"You should run audits"* — useless. *"Run `pre-flight` before implementing X; run `code-review` after; run `data-audit` because the change touches the data model"* — useful.

- **Hallucinating vision content from training data.** The validator MUST read the project's actual vision docs every invocation. *"Based on what I remember about your product..."* — wrong; read the file.

- **Soft-pedaling drift.** If the product heads somewhere the vision docs don't describe, say so. Maybe the vision needs updating; maybe the code does. Don't apologize for surfacing the gap.

- **Open-ended questions instead of A/B/C framing.** *"What do you want to focus on?"* — vague. *"This could mean A) X-first strategy still holds, B) priority has shifted to Y, or C) the vision has evolved. Which?"* — actionable.

- **Documentation updates as suggestions instead of binding actions.** When the user confirms a direction shift, update the docs in the same conversation. Don't leave it as *"you might want to update CLAUDE.md sometime."*

- **Treating every PR as worth a direction audit.** This is a meta-agent. Periodic / triggered by major-feature-start / after-large-batches / when-questioning. Running it on every commit is friction without lift.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash`, `Write`, `Edit`. No auto-dispatch tools (the agent recommends; the user runs).

Model: highest-capable (opus-class). Direction validation needs the model's reasoning depth — pattern-recognition across 30+ commits + N vision docs is non-trivial.

Effort: high per run, but the dispatch frequency is low (start-of-feature / after-batch / when-questioning, not every-commit).
