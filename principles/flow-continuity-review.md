# flow-continuity-review — designing a lightweight flow continuity grader for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author the **lightweight continuity-aware reviewer** that grades a pre-captured screenshot series as a single flow — judging arc-level properties (tone consistency, CTA visual-weight progression, loading vocabulary, disclosure pacing, color drift, progress legibility) that per-screen reviewers literally cannot see. Pairs with an auto-capture skill that produces the screenshot manifest.

## When to ship one (applicability gate)

Ship a flow-continuity-review agent when:

- The project has **multi-screen arcs** (onboarding / setup wizard / checkout / multi-step task).
- There's a **capture pipeline** that produces ordered screenshot series (Maestro / Playwright / equivalent autoplay).
- The team cares about **arc-level continuity**, not just per-screen polish. (If the team only ships single-screen surfaces, this agent is overkill — `ux-audit` covers it.)
- An **iterative polish loop** is desirable — `flow-continuity-review` is the L1 grading layer in `iterative-polish-autoloop.md`.

Skip when:

- Project has only 1-2 screens — continuity is trivial.
- No capture harness — without ordered screenshots, the agent has nothing to grade.
- The team's design discipline is whole-arc gap-detection (8-class taxonomy) — that's `flow-audit`'s scope, not this one. The two are distinct (see below).

## Why it matters — what this catches that nothing else does

Per-screen reviewers (`ux-audit`) grade one screen at a time. A multi-screen arc can ship 6 individually-S-tier screens that, taken together, feel amateur. Without a continuity reviewer:

- **Voice drifts mid-arc.** Screen 1 sounds like a senior PM; screen 4 sounds like a customer-service rep. Each screen reads fine individually.
- **CTA visual weight inverts.** "Confirm" at step 6 has more visual weight than "Confirm" at step 9 — confidence should *increase* across an arc, not decrease.
- **Loading vocabulary scatters.** Shimmer here, spinner there, skeleton somewhere else. The eye reads "this product wasn't designed together."
- **Disclosure pacing breaks.** Early-flow shows too much; late-flow shows too little. Or the reverse.
- **Color/tonality drifts.** Accent color used consistently for "active" on screens 1-5, then used for "warning" on screen 6.
- **Progress treatment scatters.** "N of 7" on screen 1, "Step 3" on screen 4, no indicator on screen 5.

These are arc-level properties. A reviewer that only sees one screen at a time literally cannot see them. The continuity reviewer's value is **the questions per-screen agents can't answer.**

### Distinct from `flow-audit`

`flow-audit` is the **deep per-arc audit** — 4 phases, builds the canonical flow doc, produces a dated gap report graded across 8 gap classes, includes the audit-don't-fix handoff column. Heavy artifact, infrequent run.

`flow-continuity-review` is the **lightweight series-grader** — takes a pre-captured manifest, grades 6 flow-level dimensions + per-screen grades + lowest-graded screens + regression delta vs prior runs. Light artifact, frequent run (every iteration of an autoloop, every commit on a polished arc).

The two compose: `flow-audit` produces the canonical flow doc (scope-lock + gap detection); `flow-continuity-review` grades a specific capture against the bar. If a project has only one, pick `flow-audit` (it's the deeper analysis); if both, the continuity reviewer is what runs continuously.

## Core methodology — the manifest-driven grading pattern

The agent does NOT interact with the app. It grades pre-captured artifacts. Input is a manifest; output is a markdown report.

### Step 1 — Input ingestion

The agent receives:

- **Audit directory path** — contains PNGs named `NN-screen-name.png` (e.g. `04-walk-tag-scanning.png`).
- **Manifest JSON path** — describes each screenshot's `step`, `name`, `path`, `context` (what state, how reached).
- **Flow context** — which flow (e.g. *"owner space-setup, 7 moments"*), which fixture drove synthetic data, deterministic quirks.

If manifest is missing or malformed → abort, surface the gap. The agent does NOT mint its own capture.

### Step 2 — Six flow-level dimensions

For each, grade S/A/B/C/D/F with a one-paragraph justification referencing specific screens by step number. The dimensions (project-tunable via `FLOW_CONTINUITY_DIMENSIONS`):

1. **Voice / tone consistency** — does the voice stay the same? Does formality shift? Does warmth drop at moments that matter?
2. **CTA visual weight progression** — does the primary CTA feel consistent in weight and treatment? Where does it get louder/quieter — is that earned?
3. **Loading-state treatment** — shimmer / spinner / skeleton / empty-state — is the vocabulary consistent? Do loading states hold the eye the same way?
4. **Disclosure pacing** — are you showing the right amount at each step? Early sparse → late cluttered, or the reverse?
5. **Color / tonality drift** — does the palette hold across screens? Are accent colors used consistently (e.g. amber means one thing throughout)?
6. **Progress legibility** — can the user tell where they are at any moment? Is "N of K" treatment consistent?

### Step 3 — Per-screen critique

For each screenshot in manifest order:

- **Grade** (S–F).
- **First impression (2-second test)** — what the eye lands on, mood (calm / anxious / premium / cheap).
- **What works** — 2-3 bullets.
- **What fails** — 2-3 bullets, specific (*"quality-pill contrast too low against map"* beats *"pill is bad"*).
- **One thing to fix first** — the highest-leverage change.

### Step 4 — Lowest-graded screens callout

The 3 worst-graded screens — the caller may follow up with `ux-audit` drilldowns on these. For each: one sentence on why it's worth a deeper pass.

### Step 5 — Regression delta (if prior runs exist)

Look in the same `.claude/audits/<flow>/` directory for prior `manifest.json` + `report.md`. If any exist:

- Table comparing per-screen grade deltas vs the most recent prior run.
- One-paragraph narrative — what moved, what didn't, likely cause if inferable from fixture/context.

### Step 6 — Flow-level persona check

Beyond per-screen, apply `persona-testing` across the entire arc:

- Does the assistant's voice stay the partner register from screen 1 to N?
- Does the day-30 test pass for *every* string in the arc, not just first-touch?
- Does any screen treat the user as a stranger after they've already met the assistant earlier in the arc?

A single failure here = flow-level CRIT, even if all per-screen grades are S.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **Flow continuity dimensions** → `FLOW_CONTINUITY_DIMENSIONS`. Six is the default; project may add (e.g. *"haptic-feedback consistency"* on iOS) or drop (e.g. progress legibility is moot if there's no progress indicator).
2. **Manifest schema** → `MANIFEST_SCHEMA`. The JSON shape the capture harness produces. Common: `{step, name, path, context}` per screenshot.
3. **Bridge reference apps** → `BRIDGE_REFERENCE_APPS`. References for elegant arc transitions (Apple iCloud onboarding, Stripe checkout, Telegram phone-number flow). Hard cuts between surfaces are an anti-pattern in modern mobile.
4. **Maestro YAML / capture path** → `MAESTRO_YAML_PATH_BY_VERTICAL` (or equivalent capture-harness path). The agent doesn't run this, but the report references it.
5. **Capture autoplay build env** → `CAPTURE_AUTOPLAY_BUILD_ENV`. The env vars baked at bundle time for autoplay (so the capture pipeline can drive the flow without user input).
6. **Tier 1 + Tier 2 benchmarks** → inherited from `design-benchmarking.md` (the project's named references).

## Authoring the agent

The final agent (typically `.claude/agents/flow-ux-reviewer.md`) specifies:

1. **Frontmatter** — `name: flow-ux-reviewer`, `description:` naming the series-as-flow scope + the manifest-driven input, `tools: [Read, Grep, Glob, Bash]` (NO capture / interaction tools — the agent does not drive the app), `model: <opus-class>`, `effort: high`, `skills: [design-system, quality-rubric, journey-mapping, persona-testing]`.
2. **Framing paragraph** — *"You are NOT grading one screen at a time in isolation. Your job is the questions per-screen agents can't answer."*
3. **Input section** — manifest + audit dir + flow context shape.
4. **Output section** — the 5-section markdown report structure (summary / flow-level dimensions / per-screen critique / lowest-graded callout / regression delta).
5. **Six flow-level dimensions** with grading rubric per each.
6. **Per-screen critique format** — grade, 2-second test, works, fails, one-fix.
7. **Flow-level persona check** — references the project's `persona-testing` skill, calls a single failure CRIT even if per-screen are S.
8. **Benchmarks** — the project's Tier 1 + Tier 2 + bridge references.
9. **What NOT to do** — don't interact, don't grade N as independent, don't praise/ding without specificity, don't invent screens not in the manifest.

## Rubric / output format

```markdown
## Flow continuity audit — <flow name> — <date>

### Summary
- **Flow grade**: <S/A/B/C/D/F>
- **Per-screen grade table**: <one row per screen>
- **Top 3 flow-level issues**: <bullets>
- **Top 3 flow-level strengths**: <bullets>

### Flow-level dimensions
- **Voice / tone consistency**: <grade> — <justification referencing screen numbers>
- **CTA visual weight progression**: <grade> — <justification>
- **Loading-state treatment**: <grade> — <justification>
- **Disclosure pacing**: <grade> — <justification>
- **Color / tonality drift**: <grade> — <justification>
- **Progress legibility**: <grade> — <justification>

### Per-screen critique
<for each screen in manifest order:>
#### <NN-screen-name>
- **Grade**: <S-F>
- **2-second test**: <eye lands on X, mood = Y>
- **What works**: <bullets>
- **What fails**: <bullets>
- **One thing to fix first**: <single move>

### Lowest-graded screens
<3 worst, one sentence each on why a deeper pass is worth it>

### Regression delta
<table vs prior run + paragraph narrative>
```

## Depth signatures — what battle-tested looks like

The authored `flow-ux-reviewer.md` agent fails the depth bar if it lacks any of these 10 structural elements.

1. **Manifest input contract explicit** — `{step, name, path, context}` shape stated. Without it, the agent infers.
2. **NO capture tools in `tools:`** — the agent grades, never drives. If the frontmatter includes Maestro / Playwright / `xcrun` tools, the agent will reflexively recapture instead of grading.
3. **Six flow-level dimensions named and graded individually** — not "evaluate continuity" but each dimension scored separately.
4. **2-second test in every per-screen critique** — *"what the eye lands on, mood"* — without this, the agent dives into critique without grounding in first-impression.
5. **One-fix-first per screen** — single concrete move, not a list. The list version dilutes urgency.
6. **Flow-level persona check called out as CRIT trigger** — *"a single failure here = flow-level CRIT, even if all per-screen grades are S."* Without this, persona drift gets graded as A-tier composition.
7. **Regression delta section** — table + narrative. Without comparing to prior runs, the agent loses its iterative-polish utility.
8. **Bridge reference apps named** — *"Apple iCloud onboarding + Stripe checkout"* as the references for elegant transitions. Generic "smooth flow" fails the depth check.
9. **Lowest-graded callout limited to 3** — opens the door to follow-up `ux-audit` drilldowns. More than 3 dilutes the signal.
10. **"What NOT to do" section verbatim** — explicit refusal of interaction, of independent-screen grading, of vague praise/ding. Without this, the agent drifts toward the easier per-screen-review job.

If the authored agent lacks any of these, redo.

## Cross-references

- `flow-audit.md` — the deeper per-arc audit (4 phases, 8 gap classes, canonical flow doc). This agent is the lighter companion.
- `ux-audit.md` — single-screen polish; followed up on the 3 lowest-graded screens from this agent's callout.
- `iterative-polish-autoloop.md` — the user-invocable autoloop uses this agent as L1 grading.
- `persona-testing.md` — flow-level persona check uses this skill across the whole arc.
- `journey-mapping.md` — the agent inherits the surface-type classification per screen.
- `design-benchmarking.md` — the Tier 1 + Tier 2 + bridge references come from here.
- `visual-verification.md` — the capture harness that produces the manifest is orthogonal to this agent.

## Anti-patterns in the agent you write

- **Interacts with the app.** The agent grades captured screenshots. Launching Maestro / Playwright is the capture skill's job, not this one. If the frontmatter has capture tools, drop them.

- **Grades N screens as N independent entities.** If the report would be valid with the screens in random order, the agent failed the continuity check. Continuity is about ordering and progression.

- **Praises without specificity.** *"Great typography"* — useless. *"The 28pt semibold headline against 17pt body across screens 3-5 reads consistently like Oura's score views"* — useful.

- **Dings without specificity.** *"Weak CTA"* — useless. *"The Confirm button at step 09 loses visual weight vs the Looks Good at step 06 — confidence should increase across the arc, not decrease"* — useful.

- **Invents screens not in the manifest.** If the manifest lists 12 screenshots, grade 12. If one is missing (capture flow crashed mid-way), flag it and grade what's there.

- **Skips the regression delta when prior runs exist.** The iterative-polish utility of this agent depends on the delta. Without it, every run is a fresh judgment.

- **Doesn't surface bridge transitions as a dimension.** Hard cuts between surfaces are an anti-pattern in modern mobile. If the agent doesn't grade the *transitions*, half the arc-level value is lost.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash`. **No** capture / interaction tools (deliberate — see anti-pattern above).

Model: highest-capable (opus-class). Arc-level reasoning needs the model's depth.

Effort: high. But cheaper than running `ux-audit` six times on a 6-screen arc — the continuity reviewer is one dispatch, the per-screen drilldowns happen only on the 3 lowest-graded screens.
