---
description: Set up a project's AI dev infrastructure the consume-direct way — enable the dotclaude plugin (which provides the universal base: operating-discipline, the auditor agents, the universal guard hooks) and author ONLY the un-shareable project-specific layer (identity, architecture, quality-bar benchmarks, knowledge graph, a thin local CLAUDE.md). The thin generator. Invoke /dotclaude:bootstrap in any project root.
---

# `/dotclaude:bootstrap` — thin generator over the consumable base

The base is **consumed, not authored.** Enabling the dotclaude plugin already gives the project the universal layer: the `operating-discipline` skill (how to work), the auditor agents (`code-review`, `pre-flight`, `test-architect`, `data-integrity`, `a11y-audit`, `ux-audit`, … dispatchable as `dotclaude:<name>`), the process/knowledge skills (`plan-driven-work`, `memory-system`, `handoff`, `knowledge-layers`, `decomposition`, `journey-mapping`, `persona-testing`, `element-reuse`, `iterative-polish-autoloop`, `saturday-ritual`), and the universal guard hooks (git-safety, secret-leak, file-size, session-start git context, uncommitted-on-clear). **Bootstrap does NOT re-author any of these.**

Bootstrap authors only what a shared file cannot carry — the project-specific layer:

| Authored by bootstrap (un-shareable) | Consumed from the plugin (do NOT author) |
|---|---|
| **Identity** — vision / ICP / moat / stage (CLAUDE.md opening) | Process discipline (`operating-discipline` skill) |
| **Architecture** — layers / boundaries + project boundary hooks + `dotclaude.yml` config for the config-needing guard templates | The universal guard hooks (`hooks/hooks.json`) |
| **Quality bar** — the project's *named* benchmarks (`design-north-star.md`) | The auditor agents (they read the north-star at runtime) |
| **Knowledge graph** — `docs/` structure + the project's task-classification routing table + capability map | The domain skills + maintenance ritual skill |
| **A THIN local `CLAUDE.md`** — identity + architecture + task table + DoD (project verification commands) + a pointer to the consumed methodology | — |

The thin local CLAUDE.md is the headline change from older bootstrap: it carries identity + project routing + project verification, and **points at** the consumed `operating-discipline` skill for the universal "how you work" rather than restating ~250 lines of it.

---

## Phase 0 — Enable the base (the consume step)

Before authoring anything, confirm the dotclaude plugin is enabled in this project (so the universal base is live). If it isn't, tell the user how to enable it and what it provides, and that bootstrap will author only the project-specific layer on top. The base is the floor; bootstrap adds the project's own facts.

## Phase 1 — Project scan (before ANY question)

Read the project so the interview only asks what the code can't answer. Run these, mapping each to a downstream authored layer:

- **Shape:** `ls -la`, `README.md` head → project name, one-paragraph description, top-level dirs. (→ Identity, Architecture, Knowledge graph)
- **Stack:** `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` (+ the `scripts` block) → language, framework, build/test/lint commands. (→ Architecture, the DoD verification commands, `dotclaude.yml`)
- **Existing infra:** read `CLAUDE.md`, `AGENTS.md`, `.claude/`, `docs/` fully if present → the brownfield-vs-greenfield decision (modes below).
- **Git:** `git log --oneline -30`, contributors, age, commit-prefix conventions → maturity tag, solo-vs-team, the task-classification rows.
- **Surfaces:** UI files (`components/`, `app/`, `pages/`), DB (`migrations/`, ORM imports), AI deps, native (`ios/`, `android/`, expo) → which auditor agents the project will actually dispatch, what the quality bar covers.

End Phase 1 with a one-paragraph mental-model summary (name · stack · existing infra scale · maturity · UI/DB/AI/native present · operating mode). Skip any question whose answer is already in it.

## Phase 2 — Author the project-specific layer (only)

Interview is short — only the un-shareable layers. Author to `.claude-staging/` + `docs-staging/` + `CLAUDE.md.draft`, confirm each before the next.

### Identity → `CLAUDE.md.draft` opening
Vision (one sentence), `ICP (wedge)`, production-vs-internal, stage, `## Moat` (name what's NOT the moat), `## Anti-vision`. Bar: ICP named specifically; moat names its own negation. (Identity is the most project-specific thing there is — no shared file can carry it.)

### Architecture → `CLAUDE.md.draft` + project hooks + `dotclaude.yml`
- CLAUDE.md "Architecture": layer model, one-line-per-layer, boundary statements, constraints — each constraint with WHY + WHERE-ENFORCED. Add the trailing anchor comment: *"new constraints accrue here as one bullet with WHY + WHERE-ENFORCED; graduate recurring memory lessons into constraints when they fire repeatedly."*
- **`dotclaude.yml`** — config for the base's config-needing guard templates the project opts into (file-size ceiling, design-token theme path, import-boundary rules, console-log allow-paths, forbidden-phrase list). The universal guards already fire from the plugin; here you only configure the project-tunable ones.
- **Project boundary hooks** — copy the relevant config-needing templates from the plugin's `hook-templates/` into `.claude-staging/hooks/` with the project's values (these are project-specific, so they're authored locally, not consumed). Do NOT re-author the universal guards — they come from the plugin.

### Quality bar → `.claude-staging/rules/<domain>-north-star.md`
The project's *named* benchmarks: Tier-1 chrome reference + Tier-2 domain references (each with its specific dimension — "X for keyboard speed," not "X is good") + anti-references + the demo test. This is the one input the consumed auditor agents (`ux-audit`, `a11y-audit`, …) read at runtime to grade against — without it they fall back to platform-native. No UI → ship `api-north-star.md` or skip (log the reason).

### Knowledge graph → `docs-staging/` + the task table
- `docs-staging/README.md` — reading order + authority hierarchy + naming/archive conventions (the conventions are universal; the instance is the project's). Make `docs/archive/**` Read-denied via `.claude/settings.json`.
- Subdirectory skeleton (`brainstorms/ specs/ plans/ audits/ archive/...`) + `product/capabilities.md` scaffold if opted in.
- **The task-classification routing table** → `CLAUDE.md.draft` "How You Work". This IS project-specific (it routes to the project's task types + names which `dotclaude:<agent>` to dispatch + project specialists). 5+ rows, an Ambiguous row mandatory, verb-led cells. (The *principles* of how to work are consumed from `operating-discipline`; the *routing table* is authored here because it's the project's own map.)
- **Definition of Done** → `CLAUDE.md.draft`, with this project's real verification commands (the lint/test commands from Phase 1) — so "verified" is unambiguous.

### The methodology pointer (hybrid always-on)
The consumed `operating-discipline` skill is *soft* always-on (loads on task context). For a hard every-session guarantee, add ONE line near the top of `CLAUDE.md.draft`: *"How you work: follow the `operating-discipline` skill (provided by the dotclaude plugin) — understand before building · reason to the right solution · goal-driven complete execution · depth by default, ceremony on demand."* This is the hard-always-on hook that pulls the soft-loaded skill. Do NOT paste the full methodology — point at it.

## Phase 3 — Stage → review → commit

Stage everything in `.claude-staging/` + `docs-staging/` + `CLAUDE.md.draft`. Present the inventory, walk the user through 3–5 distinctive authored elements explaining the reasoning ("I set your moat to X, anti-vision to Y, per Q-…"; "your task table routes UI features to `dotclaude:product-designer`"). Wait for explicit approval ("ship it" / "yes commit" — not silence / "ok"). On approval, move staged → project, merge into existing CLAUDE.md section-by-section in APPEND mode. Then output a summary: what was authored (project layer), what is consumed from the plugin (the base), and recommended next steps.

---

## Brownfield handling

The Phase 1 infra read sets the mode:
- **APPEND** (existing `CLAUDE.md` < 50 LOC OR `.claude/` < 5 artifacts): author only the missing project-specific layers; never stomp; final CLAUDE.md merge is section-by-section with per-section approval.
- **REFUSE + recommend** (existing `CLAUDE.md` > 200 LOC AND structured AND `.claude/` > 10 artifacts): don't run end-to-end. Recommend per-layer commands or an audit. Offer fresh-overwrite only on a double-confirmed explicit request. The recommendation IS the value-add.
- **FRESH** (no existing infra): full project-specific authoring.

A comprehensive existing project is often a `/distill` candidate (push its universal lessons UP into the base), not a bootstrap target — surface that.

## Non-negotiable rules

1. **Consume, don't re-author.** The base (operating-discipline, the auditor agents, the universal hooks, the process/knowledge skills, the ritual) comes from the plugin. Authoring local copies defeats consume-direct and creates drift. If a project needs to amend a base artifact, it *shadows* it by same-name — a deliberate exception, not the default.
2. **Project scan before any question.** A question answerable from Phase 1 is a wasted question.
3. **Stage before commit; explicit approval gate** ("ship it", not silence).
4. **The thin CLAUDE.md points at the methodology, never restates it.** Identity + architecture + task table + DoD + the one-line operating-discipline pointer. Not 250 lines of how-to-work.
5. **Never stomp existing content** — APPEND/REFUSE are binding.
6. **The task-classification table's Ambiguous row is mandatory.**
7. **Anonymization is not bootstrap's concern** — it authors project-owned content into the user's own repo. (Anonymization governs `/distill` writing UP into the public plugin, not bootstrap writing DOWN into a project.)

## See also

- `interview.md` — the short interview (identity / architecture / quality-bar / knowledge-graph only; process / domain / maintenance are consumed, not interviewed).
- `../../docs/v3-consume-direct-brainstorm.md` — why bootstrap shrank: the consume-direct model, the balanced split, the plugin-mechanics constraints (rules aren't pluggable → methodology is the `operating-discipline` skill).
- The consumable base lives in `../` (the plugin's `agents/`, `skills/`, `hooks/`).
