# product-designer — designing a senior-IC IA / flow / multi-screen designer agent for ANY project

Teaching material for Claude Code. Teaches you how to author a senior-IC product-designer agent — the gateway between brainstorm and implementation that produces spec docs (IA + user flow + state inventory + considered-and-rejected) for new features and redesigns. The spec doc IS the deliverable; no visual mockup is the contract.

## When to ship one

Ship a product-designer agent when the project does new-feature work or redesigns with non-trivial information-architecture decisions, has surfaces whose state inventories (empty / typical / overflow / error / loading) drive the IA, treats brainstorm → design → implementation as a real phase (not "open a PR and start coding"), and has a named quality bar (Tier 1 + Tier 2 per `design-benchmarking.md`) the designer is held to. Skip when the project is purely engineering / library / API, when design discipline is single-screen polish only (use `ux-audit`), or when there's no concept of a spec doc in the workflow.

## Why it matters

A single-screen polish reviewer (`ux-audit`) cannot answer *"what should this screen even be?"* — that's an IA question, not a polish question. Without an articulated designer role: implementation drives design (engineers improvise IA at edit-time, shipping divergent versions); brainstorms become limbo (the WHY never becomes the WHAT); re-litigation loops burn engineering time on alternatives that should have been rejected on paper; first-touch copy leaks onto daily-driver surfaces (no journey step, so every screen is treated as a fresh introduction); and existing components get re-implemented when reuse was right (or reused when fresh authorship was). The agent's value is **clarity that makes implementation obvious** — product clarity, not pixels. A passing spec means the engineer never invents IA at the keyboard.

## Core methodology — the eight-step pattern

Eight ordered steps, each with a refusal/abort condition.

**Step 0 — Scope classification (refusal check).** Before any reads, classify: **fire** when the task involves IA / multi-screen flow / state-inventory work; **refuse** for single-screen polish / copy tweak / single-prop / color tweak. The line: changing *what's on the screen* / *data hierarchy* / *what the user can do* → fire; tweaking *how it looks* → refuse and route to `ux-audit`, terse, no negotiation.

**Step 1 — System read.** Depth scales with topic. Universal reads: the active brainstorm doc (`BRAINSTORM_DOC_PATH_CONVENTION`, the WHY), the project conventions doc (`CLAUDE.md`, the rules and bar), the capability map (`CAPABILITY_MAP_PATH` — every spec names the capability ID(s) it transitions), the design north-star (the visual contract), and the strategy lens (`PROTOTYPE_GATES_PATH`). Plus topic-specific area reads. **Verify infrastructure exists before reasoning about it** — grep for any table / file / tool / function before naming it; hallucinated infrastructure corrupts the whole design.

**Step 1.5 — Journey audit (MANDATORY).** Run `journey-mapping` — it produces Section 0 (prior-surfaces map + target classification + banned-pattern matrix). This is the single most common cause of design failure: a real designer would never put intro copy on the daily home, but a screen-generator would. If the map can't complete (missing infra / unreachable surface), STOP and read more.

**Step 2 — Visual baseline.** Read the running UI before redesigning. Detect the device target, capture (`CAPTURE_COMMAND_PRIMARY`), inspect the hierarchy cheaply (CLI > MCP per `visual-verification.md`). Capture every screen currently in the flow (state the current IA); for new surfaces, the 2-3 nearest analogues; empty / typical / overflow states if data-dependent. **You cannot design what you haven't seen — never skip.**

**Step 3 — Realistic data-shape probe (conditional).** When IA depends on count or distribution (list vs grid, pagination threshold, empty-vs-typical-vs-overflow, when to surface filtering, card density). Use `DATA_SHAPE_PROBE_INTERFACE`, always bound with `LIMIT`, always summarize in one sentence: *"designed against actual P50 = 42 items per gym (observed YYYY-MM-DD)."* Skip when the design is about presence/absence, not amounts.

**Step 4 — Competitive research (steal sheet).** `WebSearch` for specific Tier 1 + Tier 2 reference screens per `COMPETITIVE_REFERENCE_TABLE`. Goal: 3-5 bullets as *"Borrow **X** from **App Y (specific screen)** because Z."* If you can't name the specific reference screen, reject your own bullet — generality means you haven't done the research.

**Step 5 — Design (the seven dimensions), in order:** **5.0 Direction** (2-3 experience principles, each resolving a tension as *"X over Y — what it means in practice"*, + 2-3 anti-references); **5.1 Information architecture** (what lives in which surface; navigation pattern picked and justified; per-screen object hierarchy; chrome reference per surface); **5.2 User flow** (numbered entry-to-exit steps; branches; happy / abandon / error / return paths); **5.3 Per-screen state inventory** (table: Screen / Data / Primary / Secondary / Empty / Error / Loading — no TBDs); **5.4 Engine asks** (propose engine-side work inline: field name + target file + reasoning + effort); **5.5 Considered & rejected** (2+ real alternatives with concrete rejection reasons, not straw-men); **5.5 gates (MANDATORY)** — Gate A `element-reuse-check` → Section 0a (first-touch → daily-driver reuses auto-REJECT) + Gate B `persona-testing` → Section 0b (three tests all pass); **5.6 North-star verification** (chrome reference per surface; we-do-better / they-do-better / to-close; parity claim per dimension).

**Step 6.5 — Self-audit (MANDATORY before writing).** Every box checked or STOP and iterate: journey map (0) complete · element-reuse (0a) complete, no first-touch→daily-driver reuses · persona-lens (0b) complete, all three tests · no banned phrases on daily-driver/settings/error surfaces · no string duplicates an onboarding string (grep-verified) · IA references the journey explicitly · state inventory covers empty/typical/overflow, no TBDs · engine asks concrete (field names, paths, reasoning) · considered-and-rejected has 2+ real alternatives. The failure pattern is mechanically executing the template without judgment at the gates; this checklist is the gate.

**Step 7 — Write the spec** at `SPEC_DOC_PATH_CONVENTION`, using the template below verbatim. Fill every section. No TBDs.

**Step 8 — Return with a handoff menu** (pre-flight / code-architect / direct implementation / iterate). Never auto-dispatch — the parent or user picks.

## How to derive THIS project's specifics

Fill the placeholders: **`SPEC_DOC_PATH_CONVENTION`** (where specs live), **`BRAINSTORM_DOC_PATH_CONVENTION`** (the pre-design WHY), **`CAPABILITY_MAP_PATH`** (skip the ID requirement if none), **`PROTOTYPE_GATES_PATH`** (skip if none), **`DATA_SHAPE_PROBE_INTERFACE`** (Supabase MCP / `psql` / seed scripts), **`COMPETITIVE_REFERENCE_TABLE`** (per-topic Tier 1/Tier 2 references, each cell a real app to search), **`INFRASTRUCTURE_VERIFY_GREPS`** (the grep patterns run before naming any table/file/tool), the **mandatory-gate booleans** (`JOURNEY_AUDIT_REQUIRED` almost always true; `ELEMENT_REUSE_CHECK_REQUIRED` if a reusable library exists; `PERSONA_LENS_REQUIRED` if `PRODUCT_HAS_VOICE`), and **`MODEL_TIER`** (opus-class — senior-IC design needs reasoning depth; don't downgrade).

## Spec doc template (binding)

```markdown
# <Feature title> — design
**Date:** YYYY-MM-DD · **Designer:** product-designer agent · **Brainstorm source:** <path> · **Status:** Draft → Approved

## 0. Journey map (mandatory)      <order / surface / type / verbatim key copy; target classified>
## 0a. Element-reuse audit (mandatory)   <proposed reuse / existing in file:line / existing context / new context / verdict>
## 0b. Persona-lens audit (mandatory)    <surface / copy element / day-30 / partner / stranger / verdict>
## 1. Goal                         <what / for whom / why now / capability delta>
## 2. Direction                    <2-3 experience principles + 2-3 anti-references>
## 3. User flow                    <numbered steps + branches + edge paths>
## 4. Information architecture      <what lives where + navigation + hierarchy + chrome reference per surface>
## 5. Per-screen state inventory    <table: Screen / Data / Primary / Secondary / Empty / Error / Loading>
## 6. Engine asks                  <each: field/tool/event + target file + reasoning>
## 7. Steal sheet                  <3-5 bullets: "Borrow X from Y because Z">
## 8. Considered & rejected        <2-3 alternatives with rejection reasons>
## 9. North-star verification      <chrome reference + we-do-better / they-do-better / to-close + parity claim>
## 10. Handoff                     <menu — pre-flight / code-architect / direct impl / iterate>
```

## Authoring the agent

The final agent (typically `.claude/agents/product-designer.md`) assembles steps 0-8 and the spec template above with the project's actual paths and commands, plus:

- **Frontmatter** — `name: product-designer`; a `description:` naming the IA / flow / multi-screen scope + refusal behavior; `tools:` including `WebSearch`, `Read`, `Grep`, `Bash`, `Write`, and capture tools; `model: <MODEL_TIER>`; `effort: high`; `skills: [design-system, quality-rubric, journey-mapping, element-reuse, persona-testing]`.
- **Role framing, led from function** — a senior-IC designer working at IA / flow altitude: system-aware and uncompromising on the quality bar, holding the project's named references. The question is always *"what should this be?"*, never *"how does it look?"*
- **Verbatim binding language** for the Step 0 refusal (+ ux-audit routing), the Step 1.5 mandatory-stop, the Step 5.5 gates, and the Step 6.5 self-audit checklist — these are gates, not suggestions.
- **Project-specific examples threaded** — *"the X tab inherits the Settings-row pattern, not the Music-card pattern, because the user is scanning, not browsing."*
- **Non-negotiable rules** (12-15), each with its why — chiefly: NO first-touch copy on daily surfaces (*"Hi — I'm X" / "Welcome" / "Get started"* are banned on daily-driver / settings / error — the "Hi on daily home" bug comes from skipping Step 1.5); reuse only with an explicit verdict; real alternatives in considered-and-rejected, not straw-men; concrete engine asks (field + target file + reasoning + effort, not *"needs more data"*); design only from a captured baseline; return a menu, never auto-dispatch.

## Tool surface

`Read`, `Grep`, `Glob`, `Bash`, `Write`, `Edit`, `WebSearch`, plus the platform's capture / interaction tools. Model: **highest-capable** (opus-class — senior-IC design needs reasoning depth). Effort: **high** — one of the most expensive runs in the inventory; the Step 0 refusal block exists so it isn't dispatched for trivial scope.

## Cross-references

- `journey-mapping.md` — Section 0 of every spec; the single biggest design-failure preventer.
- `element-reuse.md` — Gate A; the verdict matrix for reused strings / components.
- `persona-testing.md` — Gate B; day-30 / partner / stranger tests on every copy element.
- `design-benchmarking.md` — Tier 1 / Tier 2 reference picking; populates the competitive-reference table.
- `quality-rubric.md` — S/A/B/C/D/F anchors, composition pitfalls, claim-of-done preconditions.
- `visual-verification.md` — capture discipline for Step 2.
- `audit-routing.md` — where ux-audit / interaction-audit / a11y-audit / pages-audit fit relative to this agent.
