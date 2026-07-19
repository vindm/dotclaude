# product-designer — designing a senior-IC IA / flow / multi-screen designer agent for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a senior-IC product-designer agent — the gateway between brainstorm and implementation. It's the agent that produces spec docs (IA + user flow + state inventory + considered-and-rejected) for new features and redesigns. The spec doc IS the deliverable; no visual mockup is the contract.

## When to ship one (applicability gate)

Ship a product-designer agent when:

- The project does **new-feature work** or **redesigns** with non-trivial information-architecture decisions.
- The project has surfaces with **state inventories** that matter (empty / typical / overflow / error / loading) and the IA decisions depend on them.
- The team has **brainstorm-to-design-to-implementation** as a meaningful phase, not just "open a PR and start coding."
- There's a named quality bar (Tier 1 + Tier 2 benchmarks per `design-benchmarking.md`) the designer is held to.

Skip when:

- The project is **purely engineering / library / API** — no user-facing surfaces.
- The team's design discipline is single-screen polish only — use the `ux-audit` agent instead.
- There's no concept of a "spec doc" or "design phase" in the workflow — adding one is premature ceremony.

## Why it matters — what this catches that nothing else does

A single-screen polish reviewer (`ux-audit`) cannot answer: *"what should this screen even be?"* That's an IA question, not a polish question. Without an articulated principle for the designer role:

- **Implementation drives design.** Engineers improvise IA at edit-time because no spec exists, then ship divergent versions across surfaces.
- **Brainstorms become limbo.** A brainstorm doc captures the WHY; without a designer step, it never becomes the WHAT.
- **Re-litigation loops.** v1 → v2 → v3 → v4 because the design decisions weren't crisp in round one. Engineering time burns on alternatives that should have been rejected on paper.
- **First-touch copy leaks onto daily-driver surfaces.** Without a journey-mapping step (Section 0 of every spec), the designer treats every screen as a fresh introduction and re-greets the user every visit.
- **Existing components get re-implemented** when reuse was the right call (or worse — reused when fresh authorship was right). The element-reuse gate is what catches this.

The agent's value is **clarity that makes implementation obvious.** Not pixels — product clarity. A passing spec means the engineer never has to invent IA at the keyboard.

## Core methodology — the eight-step pattern

The agent operates in eight ordered steps. Each step has a refusal/abort condition.

### Step 0 — Scope classification (refusal check)

Before any reads, classify the topic. **Fire** when the task involves IA / multi-screen flow / state-inventory work. **Refuse** for single-screen polish / copy tweak / single-prop adjustment / color tweak.

The polish-vs-redesign line: changing *what's on the screen* / *data hierarchy* / *what user can do* → fire. Tweaking *how it looks* → refuse and route to `ux-audit`.

Refusal must be terse and route explicitly. Do not negotiate scope.

### Step 1 — System read

Depth scales with topic. Universal reads:

- **Active brainstorm doc** (if exists at `BRAINSTORM_DOC_PATH_CONVENTION`) — the WHY layer.
- **Project conventions doc** (`CLAUDE.md` / `AGENTS.md` / equivalent) — the rules and quality bar.
- **Capability map** (if `CAPABILITY_MAP_PATH` exists) — the WHAT-the-product-does layer. Every spec must name the capability ID(s) it transitions.
- **Design north star** (the project's chrome-reference doc) — the visual contract.
- **Strategy lens** (if `PROTOTYPE_GATES_PATH` exists) — which prototype gate this work serves.

Plus topic-specific area reads (relevant domain skills, area CLAUDE.md files, key source files).

**Verify infrastructure exists before reasoning about it.** Grep for any table / file / MCP tool / function before naming it in the spec. Hallucinated infrastructure ("the X table" when there's no X table) corrupts the entire design.

### Step 1.5 — Journey audit (MANDATORY)

Run `journey-mapping`. It produces Section 0 of the spec — the prior-surfaces map + target classification + forbidden-pattern matrix.

This is the single most common cause of design failure. A real product designer would never propose "put intro copy on the daily home" — but a screen-generator would, and has. Step 1.5 separates the two.

If the skill can't complete the map (missing infrastructure / unreachable surface), STOP. Read more. The discipline is *"I need to read more of the existing flow before I can design around it."*

### Step 2 — Visual baseline (current state read)

Read the running UI before redesigning. Designing without baseline = wrong.

- **Detect device target** via `DEVICE_TARGET_DETECT_COMMAND`.
- **Capture** via `CAPTURE_COMMAND_PRIMARY` (or `CAPTURE_COMMAND_PHYSICAL_DEVICE` if applicable).
- **Inspect hierarchy** cheaply via `HIERARCHY_INSPECTION_COMMAND` (CLI > MCP — see `visual-verification.md`).

What to capture: every screen currently in the flow you're redesigning (state the current IA); for new surfaces, the 2-3 nearest analogues (state what patterns you're inheriting / breaking from); empty / typical / overflow states if data-dependent.

**You cannot design what you haven't seen.** Never skip.

### Step 3 — Realistic data shape probe (conditional)

Trigger when IA decisions depend on **count or distribution**:

- List vs grid (list works for 5-20; grid for 20-100; pagination beyond).
- Pagination threshold.
- Empty-vs-typical-vs-overflow design.
- When to surface filtering / search UI.
- Card density (avg user has 3 sessions or 30?).

Skip when the design is purely about presence/absence of features, not amounts.

Use `DATA_SHAPE_PROBE_INTERFACE` (Supabase MCP / `psql` / direct API). Always bound with `LIMIT`. Always summarize to one sentence in the spec: *"designed against actual P50 = 42 items per gym (observed YYYY-MM-DD)"*.

### Step 4 — Competitive research (steal sheet)

Use `WebSearch` for specific Tier 1 + Tier 2 reference screens per the `COMPETITIVE_REFERENCE_TABLE`. Goal: 3-5 bullets in the format:

> Borrow **X** from **App Y (specific screen)** because Z.

If you can't name the specific reference screen, reject your own bullet — generality means you haven't done the research.

### Step 5 — Design (the seven dimensions)

The body of senior-IC work. Cover all seven, in order:

- **5.0 Direction** — 2-3 experience principles (each resolves a design tension; format: *"X over Y — <what this means in practice>"*) + 2-3 anti-references (*"Not Linear's keyboard density — owners are on iPhone touch."*).
- **5.1 Information architecture** — what lives in which tab/sheet/surface; navigation pattern (pick one, justify); hierarchy of objects per screen; chrome reference per surface.
- **5.2 User flow** — numbered steps from entry to exit; decision branches; happy path + abandon path + error path + return path.
- **5.3 Per-screen state inventory** — table with columns Screen / Data / Primary / Secondary / Empty / Error / Loading. No TBDs.
- **5.4 Engine asks** — when IA hits gaps, propose engine-side work inline (field name + target file + reasoning + effort).
- **5.5 Considered & rejected** — 2+ real alternatives with concrete rejection reasons. Not straw-men.
- **5.5 Element-reuse + persona gates (MANDATORY)** — Gate A (run `element-reuse-check`, output to Section 0a, first-touch → daily-driver reuses are auto-REJECT) + Gate B (run `persona-testing`, output to Section 0b, three tests all must pass).
- **5.6 North-star verification** — chrome reference per surface, "we do better X, they do better Y, to close Z," parity claim per chrome dimension.

### Step 6.5 — Self-audit (MANDATORY before writing the spec)

Checklist (every box must be checked; if any unchecked, STOP — iterate, do not write):

- [ ] Journey map (Section 0) complete via `journey-mapping`.
- [ ] Element-reuse audit (Section 0a) complete via `element-reuse-check` — no first-touch → daily-driver reuses.
- [ ] Persona-lens audit (Section 0b) complete via `persona-testing` — every copy element passed all three tests.
- [ ] No forbidden phrases (per the project's forbidden-phrases deny-list) on daily-driver / settings / error surfaces.
- [ ] No string in the spec duplicates an onboarding string (verified by grep, not assumption).
- [ ] IA decisions reference the journey explicitly.
- [ ] State inventory covers empty / typical / overflow per screen — no TBDs.
- [ ] Engine asks are concrete — field names, target file paths, reasoning per ask.
- [ ] Considered & rejected has 2+ real alternatives with concrete rejection reasons.

This step is non-negotiable. The pattern of failure: mechanically execute the template without applying judgment at the gates. The self-audit is the gate.

### Step 7 — Write the spec

Path: `SPEC_DOC_PATH_CONVENTION` (e.g. `docs/brainstorms/YYYY-MM-DD-<slug>-design.md`). Use the template (sections 0 / 0a / 0b / 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 / 9 / 10) verbatim. Fill every section. No TBDs.

### Step 8 — Return with handoff menu

Return a menu (pre-flight / code-architect / direct implementation / iterate). Never auto-dispatch — parent or user picks.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **Spec doc location convention** → `SPEC_DOC_PATH_CONVENTION`. Where do design specs live? Common: `docs/brainstorms/YYYY-MM-DD-<slug>-design.md` / `docs/designs/<slug>.md` / `specs/<feature>/design.md`.

2. **Brainstorm doc location convention** → `BRAINSTORM_DOC_PATH_CONVENTION`. The pre-design WHY artifact. Common: `docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md`.

3. **Capability map path** → `CAPABILITY_MAP_PATH`. If the project has a WHAT-the-product-does layer (between vision and code), every spec names the capability ID(s) it transitions. Skip the requirement if no capability map exists.

4. **Strategy lens path** → `PROTOTYPE_GATES_PATH`. The doc that says which prototype gate this work serves. Skip if none exists.

5. **Data shape probe interface** → `DATA_SHAPE_PROBE_INTERFACE`. The cheap way to query realistic counts/distributions. Common: Supabase MCP / `psql` / a CLI utility / mocked seed scripts.

6. **Competitive reference table** → `COMPETITIVE_REFERENCE_TABLE`. Per-topic Tier 1 / Tier 2 references (list rows / cards / empty states / sheets / charts / activity feed / onboarding / search). Each cell = an actual app name to search.

7. **Infrastructure-verify greps** → `INFRASTRUCTURE_VERIFY_GREPS`. The grep patterns the agent runs before naming any table/file/tool in a spec. Pattern + the path(s) it scans.

8. **Mandatory-gate booleans**:
   - `JOURNEY_AUDIT_REQUIRED` (almost always `true` for multi-screen products)
   - `ELEMENT_REUSE_CHECK_REQUIRED` (`true` if reusable string/component library exists)
   - `PERSONA_LENS_REQUIRED` (`true` if `PRODUCT_HAS_VOICE = true`)

9. **Model tier** → `MODEL_TIER`. Senior-IC design work is opus-class. Don't downgrade.

## Authoring the agent

The final agent (typically `.claude/agents/product-designer.md`) specifies:

1. **Frontmatter** — `name: product-designer`, `description:` explaining the IA / flow / multi-screen scope + refusal behavior, `tools:` including `WebSearch` + `Read` + `Grep` + `Bash` + `Write` + capture tools, `model: <MODEL_TIER>`, `effort: high`, `skills: [design-system, quality-rubric, journey-mapping, element-reuse, persona-testing]`.
2. **Senior-IC framing paragraph** — names the designer's posture. Reference the project's quality bar. Phrase: *"opinionated, system-aware, uncompromising on the quality bar."*
3. **Step 0 refusal block** with verbatim refusal output and the ux-reviewer routing.
4. **Step 1 reads list** — universal + topic-specific. Cite the project's actual paths.
5. **Step 1.5 journey-audit gate** — verbatim mandatory-stop language.
6. **Step 2 capture procedure** — the project's actual capture / hierarchy commands.
7. **Step 3 data shape probe block** — the project's actual query interface + LIMIT discipline.
8. **Step 4 steal-sheet** — the project's actual competitive reference table.
9. **Step 5 design dimensions** — 5.0–5.6 with project-specific examples.
10. **Step 5.5 element-reuse + persona-lens gates** — verbatim binding language.
11. **Step 6.5 self-audit checklist** — verbatim binding language.
12. **Step 7 spec template** — verbatim section structure (0 → 10). Path convention is the project's.
13. **Step 8 handoff menu** — list of follow-up agents, never auto-dispatch.
14. **Non-negotiable rules** — 12-15 rules with rationale clauses.

## Rubric / output format

The spec doc structure (binding template):

```markdown
# <Feature title> — design

**Date:** YYYY-MM-DD
**Designer:** product-designer agent
**Brainstorm source:** <path or "direct invocation">
**Status:** Draft → Approved

## 0. Journey map (mandatory)
<table: order / surface / type / verbatim key copy; target surface classified>

## 0a. Element-reuse audit (mandatory)
<table: proposed reuse / existing in (file:line) / existing context / new context / verdict>

## 0b. Persona-lens audit (mandatory)
<table: surface / copy element / day-30 / partner / stranger / verdict>

## 1. Goal
<what / for whom / why now / capability delta>

## 2. Direction
### 2.1 Experience principles (2-3)
### 2.2 Anti-references (2-3)

## 3. User flow
<numbered steps + branches + edge paths>

## 4. Information architecture
<what lives where + navigation + hierarchy + chrome reference per surface>

## 5. Per-screen state inventory
<table: Screen / Data / Primary / Secondary / Empty / Error / Loading>

## 6. Engine asks
<each: field/tool/event + target file + reasoning>

## 7. Steal sheet
<3-5 bullets: "Borrow X from Y because Z">

## 8. Considered & rejected
<2-3 alternatives with rejection reasons>

## 9. North-star verification
<chrome reference + we-do-better / they-do-better / to-close + parity claim>

## 10. Handoff
<menu — pre-flight / code-architect / direct impl / iterate>
```

## Depth signatures — what battle-tested looks like

The authored `product-designer.md` agent fails the depth bar if it lacks any of these 10 structural elements.

1. **Refusal block with explicit ux-reviewer routing** — Step 0's "out of scope" paragraph appears verbatim. Polish requests are routed, never absorbed.
2. **Mandatory gates named upfront** — journey-audit, element-reuse, persona-lens. Each with a hard-stop ("STOP if can't complete"). Not "consider running" — *binding*.
3. **Verify-before-name discipline** — grep patterns appear in Step 1 with the message *"if absent, label explicitly 'unverified — no such X currently' and design around the gap."* Without this, the spec hallucinates infrastructure.
4. **Visual-baseline-required language** — Step 2 says *"You cannot design what you haven't seen. Never skip."* Without explicit baseline language, designers improvise.
5. **Data-probe LIMIT discipline** — Step 3 includes the LIMIT requirement + the spec summary format (*"P50 = 42 items per gym, observed YYYY-MM-DD"*).
6. **Steal-sheet rejection rule** — Step 4 says *"reject your own bullet if you can't name the specific reference screen."* Generality is the failure mode.
7. **Self-audit checklist verbatim** — Step 6.5 lists all 9 boxes. Without this, designers write specs first and audit later (or never).
8. **Spec template verbatim** — Sections 0 / 0a / 0b / 1–10 appear. Skipping section numbering is shallow.
9. **Project-specific examples threaded** — *"the X tab inherits the Settings-row pattern, not the Music-card pattern, because the user is scanning, not browsing"* — concrete example from the project's actual surfaces.
10. **Non-negotiable rules (12-15) with rationale clauses** — each rule says *what* + *why*. *"NO FIRST-TOUCH COPY ON DAILY SURFACES — 'Hi — I'm X' / 'Welcome' / 'Get started' patterns are forbidden on daily-driver / settings / error surfaces. The 'Hi — I'm <assistant> on daily home' bug comes from skipping Step 1.5."*

If the authored agent lacks any of these, redo. Battle-tested ≠ optional polish.

## Cross-references

- `journey-mapping.md` — Section 0 of every spec. The single biggest design-failure preventer.
- `element-reuse.md` — Gate A. Verdict matrix for reused strings/components.
- `persona-testing.md` — Gate B. Day-30 / partner / stranger tests on every copy element.
- `design-benchmarking.md` — Tier 1 / Tier 2 reference picking; populates the competitive-reference table.
- `quality-rubric.md` — S/A/B/C/D/F anchors + composition pitfalls + claim-of-done preconditions.
- `visual-verification.md` — capture discipline for Step 2 (baseline read).
- `audit-routing.md` — where ux-reviewer / interaction-audit / a11y-audit / pages-audit fit relative to this agent.
- `forbidden-phrases.md` — the deny-list the self-audit checks against.

## Anti-patterns in the agent you write

- **Visual mockup is the contract.** No. The spec doc is the contract. A pretty mockup without IA / state inventory / considered-and-rejected is decoration, not design. If the agent feels like it "needs a mockup to show," the IA decision isn't crisp enough yet — go back to Step 5.

- **No refusal — try to do polish anyway.** The agent must refuse single-screen polish and route. Trying to do it produces a mediocre IA spec for a problem that didn't need one.

- **Skip the journey-audit gate when "the surface is obvious."** No surface is obvious. The forbidden-pattern matrix depends on the type. Skipping Step 1.5 is the single most common failure mode.

- **Write the spec first, audit later.** The self-audit (Step 6.5) gates spec-writing, not the other way around. Writing first and auditing later is mechanical-template-execution, not design.

- **Reuse without verdict.** Every reused string / component must have an explicit element-reuse verdict (PASS / CAUTION / REJECT). Silent reuse is the first-touch-on-daily-driver bug class.

- **Strawman alternatives in "Considered & rejected."** *"Considered: do nothing. Rejected because we need to ship."* — not real. Real alternatives are alternatives the designer could have picked.

- **Vague engine asks.** *"Needs more data."* — not concrete. *"Add `member.last_seen_at` to the gym-detail query response. Target file: lib/.../queries.ts. Why: member-list IA shows 'active in last 7 days' pill. Effort: ~1h."* — concrete.

- **Auto-dispatching the next agent.** The agent returns a menu. Parent or user picks. Auto-dispatch removes the user's judgment from the workflow.

- **Designing without baseline.** *"Looks fine in my head."* — no. Step 2's capture is mandatory.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash`, `Write`, `Edit`, `WebSearch`, plus capture / interaction tools specific to the platform (browser automation / simulator CLI / MCP visual tools).

Model: **highest-capable** (`MODEL_TIER` = opus-class). Senior-IC design needs the model's reasoning depth.

Effort: **high**. This is one of the most expensive agent runs in the inventory. Don't dispatch for trivial scope — the refusal block exists for a reason.
