# dotclaude v2 — vision

> **The reframe**: dotclaude moves from "design audit plugin" to "AI dev infrastructure framework." The current v1 (7 domain skills authoring `.claude/` kits) becomes Layer 6 of a 7-layer hierarchy. The new headline is the **bootstrap** flow — a hierarchical interview from project identity down to domain tooling that authors `CLAUDE.md` + `docs/` knowledge graph + `.claude/` system, all derived from project context.

**Status:** Draft v1. The foundation doc for Stages 2–5 — every downstream deliverable executes against this.
**Authored:** 2026-05-21.
**Supersedes:** the implicit v1 framing in `README.md` + `plugin.json` (description scoped to "design-discipline + coding hygiene"); v2 retains the v1 contract but recontextualizes it under a wider hierarchy.
**Related:** `docs/design-stack-analysis.md` (the 26-artifact knob extraction underneath Layer 6) · `docs/design-greenfield-audit.md` (the 78-knob greenfield expansion underneath bootstrap) · `docs/design-smoke-test-2026-05-20.md` (~85% parity on a brownfield source project — validates Layer 6 as already-shipped).

---

## 0. TL;DR for future readers

**What this doc is.** The foundational design document for dotclaude v2. It defines the reframe (design-plugin → infrastructure-framework), the 7-layer hierarchy that organizes the new mental model, the 12 transferable methodology lessons we distilled from one battle-tested production codebase, the new plugin command surface, a walkthrough of the headline `/dotclaude:bootstrap` flow, the v1 → v2 migration shape, and the implementation roadmap for Stages 2–5.

**Why this exists.** v1 shipped well (`/dotclaude:design` is the showpiece, the 78-knob analysis proved depth, smoke-test hit ~85% parity against a real mature codebase). But the framing left value on the table. Most Claude Code plugins are *bottom-up* — they paste a hook, a slash command, a subagent at a time. v1's design plugin already operates at a higher level — it *authors* a coherent `.claude/` kit per project — but the public framing ("design discipline + coding hygiene") doesn't tell you that. Other plugin authors are not competing in this niche yet; the differentiator is the *meta-framework* angle, not the design-audit angle.

**What changes.** The headline becomes `/dotclaude:bootstrap` — a hierarchical interview that starts at project identity (vision / ICP / moat) and walks down through architecture, process discipline, quality bar, knowledge graph, domain kits, and maintenance ritual. Each layer authors a slice of the project's `CLAUDE.md` + `docs/` + `.claude/`. Current v1 artifacts become Layer 6 (domain kits) of the hierarchy — they don't go away, they slot in. The v1 contract is preserved; v2 is additive.

**What ships when.** Stage 1 is this doc. Stage 2 (~3–4h) writes 5–6 new upstream principles in `principles/` (project-identity, architecture, plan-driven-work, memory-system, task-classification, maintenance-ritual). Stage 3 (~2–3h) writes the bootstrap skill itself. Stage 4 (~2h) smoke-tests bootstrap against the source project + a fresh greenfield. Stage 5 (~3–4h) repositions the repo (README + plugin.json + demo). Cumulative: ~10–13 hours of focused work to ship v2 publicly.

**Quality bar.** "Stages 2–5 can pick this up and proceed without re-deriving the reframe." If a future contributor or AI coding tool reading this doc has to ask *what does Layer 3 author exactly* or *how does the hierarchy interact with bottom-up plugins*, this doc has failed. Specificity over brevity throughout — examples, paths, anonymized templates, the 12 transferable lessons concretized.

---

## 1. Why v2 — the motivation

### 1.1 — v1 framing was too narrow

The v1 README says: *"Design-discipline + coding hygiene for Claude Code. Reads your project, interviews you about goals and past failure modes, then authors a customized .claude/ kit."*

This is *accurate* but *under-priced*. Two specific problems with the framing:

**Problem 1 — The deliverable is bigger than "design audit agents."** The 78-knob greenfield audit (`docs/design-greenfield-audit.md`) identified ~10 conceptual scaffolds that v1's design skill quietly handles: capability maps, brainstorm doc conventions, audit doc conventions, flow doc conventions, fixture-tier seed pipelines, app-state-navigation recipe catalogs, named anti-patterns mined from git history, multi-section primary surface structures, named in-product assistant characters with single-exempt-surface contracts. These aren't "design agents" — they're project infrastructure. v1 ships them as a side effect of `/dotclaude:design`; v2 makes them the headline.

**Problem 2 — The interview is bottom-up under the hood, top-down in spirit.** Read v1's `skills/design/SKILL.md` Phase 1 — it scans `package.json`, file tree, existing `CLAUDE.md`, git log. It already operates top-down (identity-first, then artifacts). But the public surface (`/dotclaude:design`) is bottom-up (here's a kit of agents). The mismatch costs us. A user opens v1, sees "design audit plugin," and never discovers that the same tool authors `CLAUDE.md` sections + docs structure + a hook ladder. v2 names the top-down framing.

### 1.2 — The empty niche

Look at the Claude Code plugin landscape (as of 2026-05): the vast majority of plugins ship *one or two* of {hook, subagent, slash command, skill, MCP server}. They're component-level. There's almost nothing at the *framework* level — no plugin that says "let me bootstrap your project's entire AI dev infrastructure based on what your project is."

**This is structural.** Bottom-up plugins are easier to publish — write one hook, ship. Framework-level plugins require an opinionated methodology backed by real evidence of working in production. dotclaude has that evidence: the source project's `CLAUDE.md` + `docs/` + `.claude/` + memory + per-domain skills is the most opinionated, most-evolved AI-dev infrastructure stack we've encountered (~600-line `CLAUDE.md`, ~40 docs in `docs/`, 30+ skills, 15+ agents, 5 cross-cutting rules, 5 enforcement hooks, indexed cross-conversation memory). v1 distilled the *design audit* slice of that. v2 distills the entire stack.

### 1.3 — The moat becomes the methodology, not the agents

v1's competitive moat was *depth per agent* — the 78-knob analysis, the 10-element depth checklist, the per-grade rubric anchored to named benchmarks. That's still the moat at Layer 6. v2 adds a higher-order moat: *the hierarchy itself*. Anyone can publish "here's a code-reviewer agent." Almost nobody can publish "here's a hierarchical framework that authors a coherent infrastructure stack from project identity down to domain tooling, grounded in a real production codebase's evolutionary history."

### 1.4 — Why now

Three signals:

1. **Layer 6 is already shipped** (v1 design skill, the smoke test at ~85% parity). We're not speculating about whether the methodology works — we have evidence.
2. **The source project's `CLAUDE.md` is ~600 LOC** of distilled methodology — task-classification matrix, DoD, file-size discipline, vertical boundaries, etc. It's *ready to be abstracted* into a framework. Waiting longer adds churn without information.
3. **The Claude Code plugin market is forming now.** Most plugins shipped post-2026 plugin GA are component-level. The framework-level niche is empty for ~6 more months at most before someone else publishes one. Move before the niche fills.

### 1.5 — What v2 is NOT

To prevent scope creep:

- **Not a multi-language porting effort.** v2 stays Claude-Code-first. Whether the framework concepts (memory typing, hooks, subagents) generalize to Cursor / Continue / Aider is a future RFC — see §9.4. The discipline transfers; the implementation doesn't, and trying to abstract over multiple tools dilutes both.
- **Not a hosted service.** Everything stays git-tracked plugin code. No backend, no auth, no usage metrics, no telemetry. The plugin is local-first by design; if a user wants telemetry they can wire their own.
- **Not a code generator beyond `.claude/` + `docs/` skeleton + `CLAUDE.md` sections.** v2 authors *infrastructure*, not *features*. The user still implements features via Claude Code's normal interaction patterns; v2 just makes those patterns more disciplined.
- **Not a replacement for existing skills.** All 7 v1 domain skills survive — they slot into Layer 6. Migration burden = zero for existing v1 users.
- **Not a "from scratch" framework.** v2 is the published abstraction of one battle-tested codebase's methodology, not a synthesized "what would the ideal AI dev infrastructure look like." The grounding matters. Without it, every claim becomes opinion. The source project has been the laboratory for ~12 months; v2 ships the lessons.
- **Not opinionated about which AI model to use.** v2 names tier targets (opus / sonnet / haiku) per agent but the user can override. Bootstrap asks once at Layer 6 (model tier defaults) and threads through.
- **Not opinionated about git workflow.** v2 ships a worktree-aware subagent dispatch pattern but doesn't require worktrees. Single-branch development works.

### 1.6 — Strategic positioning trade-offs

The reframe trades clear positioning for less-immediate positioning. A user landing on `dotclaude` v1 understood within ~5 seconds: *"it sets up design audit agents."* Concrete, demoable, easy to evaluate. v2's headline takes longer to evaluate: *"it walks 7 layers from identity to maintenance"* requires more context.

This is a deliberate trade. The hypothesis: a small audience that *does* understand v2 within ~20 seconds becomes evangelists. The much larger audience that doesn't understand can still use `/dotclaude:design` (the same v1 showpiece) as the entry point — they get value without ever invoking bootstrap.

Concretely: v2's README should have two entry paths:

1. **"Just want design audits?"** → `claude plugin install ... && /dotclaude:design`. Same as v1.
2. **"Want the full infrastructure stack?"** → `claude plugin install ... && /dotclaude:bootstrap`. The headline.

Both paths visible, neither hidden. The user picks. v2 is *additively* more powerful than v1 without breaking v1's existing UX.

---

## 2. The 7-layer hierarchy

The hierarchy is the organizing concept of v2. Every authored artifact (`CLAUDE.md` section, `docs/` doc, `.claude/` artifact) belongs to exactly one layer. Layers are dependency-ordered top-down: Layer 1 (project identity) is read first by every other layer, Layer 7 (maintenance) is read last because it polices everything above it.

| # | Layer | What it captures | Where it lives in the project |
|---|---|---|---|
| 1 | **Project Identity** | Vision / ICP / moat / production-vs-internal / solo-vs-team / maturity | `CLAUDE.md` opening section + `docs/product/vision.md` |
| 2 | **Architecture** | Layer model / stack / boundaries / constraints / engine-vs-vertical or equivalent | `CLAUDE.md` "Architecture" + `docs/architecture/*` + `.claude/rules/*` (boundary hooks) |
| 3 | **Process Discipline** | Plan-driven y/n / task classification / 4-tier cost ladder / subagent dispatch / verification / file size / memory typing | `CLAUDE.md` "How You Work" + DoD + `.claude/rules/*` + `.claude/skills/*` (process-level) |
| 4 | **Quality Bar** | Tier 1 + Tier 2 benchmarks / demo test / per-domain rubrics / anti-references | `.claude/rules/design-north-star.md` (or equivalent per domain) + `.claude/skills/quality-bar/SKILL.md` |
| 5 | **Knowledge Graph** | `docs/` root convention / brainstorms / specs / plans / audits / capabilities / design-system docs / archive policy / memory directory | `docs/README.md` + the `docs/` skeleton |
| 6 | **Domain Kits** | Design / coding / planning / testing / data / ai-workflow / native-bridge / pipeline-integrity quality + verification kits | `.claude/{agents,skills,hooks}/*` per domain. THIS IS V1. |
| 7 | **Maintenance** | Saturday design-debt ritual / drift detection / audit cadence / skill audit | `.claude/rules/maintenance-ritual.md` + `.claude/agents/skill-auditor.md` + `docs/design-debt/` |

The next seven subsections describe each layer in depth.

---

### 2.1 — Layer 1: Project Identity

**What this layer captures.** The answer to *"what is this project, who is it for, what makes it defensible, what stage is it at."* In particular:

- **Vision** — one sentence describing the product and its primary user. NOT a marketing tagline; a sentence Claude reads at the top of every session to ground its judgment.
- **Wedge ICP** — the *specific* initial customer segment (not the TAM). Drives priority lens — "would this feature help ICP customer #2?"
- **Moat** — what's hard for a competitor to replicate. Drives the *engine tax* lens — every feature either compounds the moat or doesn't.
- **Production-vs-internal** — does this project ship to external users, or is it internal tooling / a library / a research prototype? Drives quality bar (production needs Apple-parity polish; internal tools target *credible*, not *S-tier*).
- **Solo-vs-team** — solo developers can skip multi-author coordination conventions (PR review etiquette, commit-message verbosity). Team projects need them.
- **Maturity** — greenfield / early prototype / shipped / mature. Drives which layers even apply — a 2-week-old project skips Layer 7 (no debt to audit yet).

**What it authors.**

- `CLAUDE.md` opening section (top of file, ~30–80 LOC):
  - One-paragraph product description.
  - "Wedge ICP" line.
  - "Moat" bullet list.
  - "Pace" sentence (deadline / no deadline / runway-bound).
  - "Stage" tag.
- `docs/product/vision.md` (the canonical longer form, ~200–400 LOC):
  - Full product narrative.
  - Strategic posture (stealth / public / fundraise / acquihire-shaped / etc.).
  - Anti-vision (what we're explicitly *not* building).
  - Decision log when vision shifts.

**Why it must be first.** Every downstream layer depends on identity. Layer 2 picks architecture appropriate to the project shape (a CLI doesn't need a vertical boundary; a multi-product platform does). Layer 3 picks process discipline (a solo prototype skips PR review; a team product doesn't). Layer 4 picks the quality bar (production needs Tier 1 benchmark chrome; internal tool doesn't). Asking Layer 4 questions before Layer 1 answers leads to *generic* outputs ("Apple iOS 26 + Telegram" as defaults regardless of whether the project even has a UI).

**Source-project example.** The source project's `CLAUDE.md` opens with:

> *"Primary product + optionality on one codebase. Primary: [domain] vertical. 'The intelligence layer for premium specialty [venues].' Map-first user surface, dashboard for operators. Wedge ICP: premium specialty [venues] in tech-dense cities, starting [city]. Moat = frontier models + the [venue]'s own corpus."*

Note what's load-bearing here:

- *"Primary product + optionality on one codebase"* — declares the architecture stance (one codebase, two products, dual quality bar).
- *"The intelligence layer for ..."* — three-word product positioning that survives every other context-load.
- *"Map-first user surface"* — implies UI shape (dictates Layer 6 design kit picks).
- *"Wedge ICP: premium specialty [venues] in tech-dense cities, starting [city]"* — specific enough that "would feature X serve this ICP" is decidable.
- *"Moat = frontier models + the [venue]'s own corpus"* — declares the *engine quality signals* (per-venue persistent state) as load-bearing. Drives the *engine tax* lens in Layer 3.

**Universal pattern.** Every non-trivial project benefits from this layer regardless of domain. Examples by project type:

- A **CLI tool**: *"POSIX-compliant text processing for the Linux power user; ICP = SREs at mid-size shops; moat = composability + zero-config defaults; production; solo author."*
- A **docs site**: *"API reference + tutorials for [framework X]; ICP = first-day adopters who want runnable examples; moat = code-runnable examples + interactive playground; production; team of 3."*
- A **library**: *"Type-safe HTTP client for TypeScript; ICP = frontend devs at SaaS startups who currently use `fetch` directly; moat = TS-native API + zero runtime cost; production; solo + community contributors."*
- A **research prototype**: *"Exploring whether [novel technique] can replace [common practice]; ICP = future-me + 2 collaborators; moat = N/A (research); internal; solo."*
- A **B2B SaaS dashboard**: *"Observability dashboard for [niche stack]; ICP = SRE teams of 5-20 at series-B companies; moat = pre-built integrations + 1-click incident timeline; production; team."*

Whatever the project is, identity-first authoring forces clarity at the moment when clarity is cheapest. For a B2B product, the absence of identity layer typically manifests as feature bloat ("we built for everyone, now we don't have a wedge"). For a research prototype, the absence manifests as scope creep ("we started exploring X, now we're rebuilding the underlying framework"). For a library, the absence manifests as API drift ("we have 3 ways to do the same thing"). Layer 1 surfaces these *before* they become hard to revert.

**Anonymized template** (what `/dotclaude:bootstrap` would author):

```markdown
# <PROJECT_NAME>

## Vision

<ONE_PARAGRAPH_PRODUCT_DESCRIPTION>

**ICP (wedge):** <SPECIFIC_INITIAL_SEGMENT>
**Production-vs-internal:** <PROD | INTERNAL | LIBRARY | PROTOTYPE>
**Stage:** <GREENFIELD | EARLY | SHIPPED | MATURE>
**Pace:** <NO_DEADLINE | RUNWAY_BOUND | FUNDRAISE_WINDOW>

## Moat

- <MOAT_BULLET_1>
- <MOAT_BULLET_2>
- ...

## Anti-vision (what this is NOT)

- <ANTI_BULLET_1>
- <ANTI_BULLET_2>
- ...
```

The bootstrap interview drives values for each placeholder. The user can refuse / defer — `<UNKNOWN>` is a valid value for `moat` on a 1-week-old prototype.

---

### 2.2 — Layer 2: Architecture

**What this layer captures.** The structural shape of the codebase:

- **Layer model** — single-tier (one app) / two-tier (engine + vertical) / three-tier (engine + multiple verticals + shared) / N-tier (microservices, monorepo with N packages).
- **Stack** — languages / frameworks / runtimes / build tools. Just the spine — full dependency list lives in `package.json`.
- **Boundaries** — one-way import rules (e.g. *"never import from `verticals/` into `engine/`"*), DI patterns, public-vs-internal API surface markers.
- **Constraints** — non-negotiables enforced at edit-time (file-size ceiling, theme-tokens-only, etc.) or at build-time (lint, type-check, knip).
- **Type generation** — auto-generated types (from DB schema, OpenAPI, GraphQL) marked as exempt from manual edit + size limits.

**What it authors.**

- `CLAUDE.md` "Architecture" section (~50–200 LOC):
  - Layer diagram in ASCII or as a numbered list.
  - One-line per layer describing its responsibility.
  - Boundary statements explicit ("never X → Y").
  - Constraint bullets (each backed by either a hook, a rule, or a manual review checkpoint).
- `docs/architecture/*` (if architecture is non-trivial, ~1–4 docs):
  - Each layer or major subsystem gets a doc.
  - Substrate companions to the user-facing flow docs.
- `.claude/rules/*` (boundary enforcement):
  - One rule per boundary that needs binding language (e.g. `.claude/rules/vertical-boundary.md`).
  - Optional hook companion (e.g. `.claude/hooks/check-vertical-boundary.sh`) — only if the boundary is greppable.
- `.claude/hooks/check-file-size.sh` (the universal file-size hook — ships in every kit).

**Source-project example.** The source project has:

- **Two-tier architecture**: engine (5 horizontal layers) + verticals (currently 1, reference impl).
- **Vertical boundary**: closed 2026-04. Engine never imports vertical types. `lib/verticals/<name>/ → lib/{engine-domains}` is one-way enforced by hook.
- **File-size ceiling**: 1000 LOC, warning at 950, mandatory decomposition. Auto-generated types are the only exemption.
- **Token discipline**: hex literals outside `lib/theme/` blocked by hook, override per-line.

The source-project `CLAUDE.md` Architecture section is ~30 LOC of horizontal + vertical layers, plus a paragraph of constraints, plus a list of edit-time hooks. The constraints list is the load-bearing part: each constraint either has a hook (enforced automatically, no LLM cost) or a rule (read by Claude every relevant session). No constraint exists *only* in human memory.

**Universal pattern.** Even single-tier projects benefit from explicit boundaries. Examples:

- A **CLI tool** may have "core logic" / "presentation" / "I/O" as its three implicit layers; making that explicit prevents the slow drift where presentation logic ends up inside core. Boundary: `core/` doesn't import from `cli/` (the CLI argparse layer).
- A **docs site** has "content authors edit" / "build pipeline transforms" / "deploy artifact" as implicit layers. Boundary: build scripts never reach into authored content directories.
- A **monolith web app** has "models" / "controllers" / "views" (in MVC parlance) or "domain" / "application" / "presentation" / "infrastructure" (in DDD parlance). Boundary: domain doesn't know about infrastructure.
- A **mono-repo with multiple packages** has each package as a layer. Boundary: peer packages don't import each other directly — they import from a shared base.

Layer 2 forces the user to *name* these — even if they refuse a strict boundary, the naming alone improves Claude's ability to route changes. *"This is a UI change, so the file path should be under `presentation/`, not `domain/`"* is a routing decision that requires the layers to be named.

**The 4-tier cost ladder is born here.** This layer establishes the *cheapest-tier-wins* discipline: prefer hook over rule, rule over skill, skill over agent.

| Tier | Catches | Cost | Source-project example |
|---|---|---|---|
| **Hook** | Greppable patterns at edit time | ~0 (no LLM round-trip) | `check-token-only.sh` blocks raw hex outside theme |
| **Rule** | Cross-cutting binding language Claude reads every relevant session | ~200–800 tokens always-on | `.claude/rules/file-size.md` — file-size discipline + decomposition guidance |
| **Skill** | Procedural knowledge, auto-loaded by file path | ~2.7–5.5k on-invoke | `.claude/skills/auth-navigation/SKILL.md` — auto-loads when working on auth files |
| **Agent** | Specialist dispatch, fresh per task | ~5–30k per dispatch (depends on `model:` + `effort:`) | `.claude/agents/code-reviewer.md` — Opus, runs end of feature |

The discipline: when adding a new check, ask *can a hook catch this?* before reaching for an agent. A hook that blocks `expo-blur` imports prevents an entire class of `design-token-auditor` findings. Every layer downstream of Architecture is expected to ask this question.

**Anonymized template.**

```markdown
## Architecture (<N>-tier)

*<Horizontal layers description>:*
1. **<LAYER_1>** — <one-sentence responsibility>
2. **<LAYER_2>** — <responsibility>
...

*<Vertical layers if applicable>:*
N+1. **<VERTICAL_1>** — <responsibility>

## Boundaries

- **<BOUNDARY_NAME>** — <one-way import rule>. Enforced by: <hook | rule | review checkpoint>.

## Constraints

- **<CONSTRAINT_NAME>** — <statement>. Enforced by: <hook | rule | manual>.
- Edit-time hooks active in `.claude/hooks/`:
  - `<HOOK_FILE>.sh` — <what it catches> — override per-line: `// <OVERRIDE_COMMENT>: <reason>`
- After `<TRIGGER_FILE>`: `<COMMAND>` (e.g. after `lib/theme/tokens.ts` → `yarn generate:theme`).
```

**Worked example — applying the template to a generic Next.js B2B SaaS dashboard.**

```markdown
## Architecture (2-tier)

*Horizontal:*
1. **Shared** (`lib/`) — domain logic, types, utilities. Pure TS, no React, no Next.
2. **App** (`app/`, `components/`) — Next.js App Router routes + React components. Consumes `lib/`.

*Engine:*
3. **API layer** (`app/api/`) — REST + tRPC endpoints. Server-only.

## Boundaries

- **shared → app** — `lib/` never imports from `app/` or `components/`. Enforced by: `.claude/hooks/check-shared-boundary.sh`.
- **client → server** — Client components never import server-only modules. Enforced by: Next.js compiler + `.claude/rules/server-client-boundary.md`.

## Constraints

- **File-size ceiling**: 800 LOC (lower than source-project default — Next.js components benefit from smaller files). Enforced by: `check-file-size.sh`.
- **No raw color literals outside `tailwind.config.ts`**: enforced by: `check-tailwind-tokens.sh`. Override: `// allow-color: <reason>`.
- **No `any` type**: enforced by: `tsconfig.json` strict + `eslint-no-explicit-any`. Override: `// eslint-disable-next-line @typescript-eslint/no-explicit-any -- <reason>`.
- **API routes must validate input with Zod**: enforced by: `code-reviewer` agent + manual.
- After `prisma/schema.prisma` edit: `pnpm prisma generate` + `pnpm prisma migrate dev`.
- After `tailwind.config.ts` edit: rebuild dev server (Tailwind auto-reload doesn't catch token deletions).
```

This worked example shows how the template absorbs project-specific values while preserving the universal structure. Bootstrap's Layer 2 interview drives the variable substitution; the user reviews the rendered output.

---

### 2.3 — Layer 3: Process Discipline

**What this layer captures.** *How* changes get made — the operating manual for a working session. Six sub-disciplines, each backed by either a rule, a skill, or a `CLAUDE.md` section:

- **Plan-driven y/n** — does this project use written specs / brainstorms / plans before non-trivial implementation, and what does a "conformance matrix" look like (spec § × implementation status)?
- **Task classification matrix** — the routing table inside `CLAUDE.md` that says *"for a UI feature: do A → B → C; for a bug fix: do D → E"*.
- **4-tier cost ladder** — the hook/rule/skill/agent escalation (established in Layer 2, applied here).
- **Subagent dispatch patterns** — fresh-per-task / two-stage review / cd-into-worktree gate.
- **Verification ladder** — visual verification (screenshots) / semantic verification (interaction-audit) / flow verification (end-to-end) / conformance verification (spec § × impl).
- **File-size + decomposition** — when to refactor, the ceiling + threshold.
- **Memory typing system** — user / feedback / project / reference, decay policy.

**What it authors.**

- `CLAUDE.md` "How You Work" section (~80–250 LOC) — the operating manual paragraphs.
- `CLAUDE.md` "Task classification" table — the routing matrix.
- `CLAUDE.md` "Definition of Done" — the checklist that ends every task.
- `.claude/rules/*.md` — the cross-cutting rules: `file-size.md`, `database-queries.md`, `visual-verification.md`, `subagent-dispatch.md`, etc.
- `.claude/skills/*/SKILL.md` — the foundational skills: `pre-flight`, `decompose-file`, `verify-conformance`, etc. (Distinct from Layer 6's *domain* skills — Layer 3 skills are *process* skills.)

**Source-project example — the task classification table.** From the source project's `CLAUDE.md`:

| Task | Approach |
|---|---|
| UI feature/redesign | Interview → `product-designer` agent (research + design + spec) → implement → pipeline per audit-routing |
| Backend / pipeline | Domain skill → `pre-flight` if complex → implement → `code-reviewer` → `tests-architect` |
| Bug fix | Reproduce → fix → test |
| Architecture change | `pre-flight` → `product-compass` → plan → implement → `code-reviewer` |
| Data / schema | `apply_migration` → `yarn db:types` → `data-auditor` |
| Plan-backed (spec/design-doc + sub-plans) | Implement per sub-plan → produce `docs/audits/<plan-slug>-conformance.md` → resolve CRIT/MAJ → only THEN declare done |
| Ambiguous | Ask first. Summarize back in 3-5 bullets. Wait for confirmation. |

This table is doing *enormous* work. It compresses dozens of "how should I approach this" decisions into a one-row lookup. Without it, every session re-derives the routing. With it, the routing is stable across sessions.

**Source-project example — the Definition of Done.** ~15 checklist items, including:

- `yarn lint --fix` 0 errors; `yarn test` green.
- No file > 1000 LOC.
- Operations / MCP tools / branching functions have tests.
- Semantic tokens only — no hardcoded hex.
- Validation agents invoked per task classification.
- Fresh screenshot of affected surfaces (NOT "compiles" / "tests pass").
- Interaction-semantics check on every UI surface.
- Plan-backed work: conformance matrix at `docs/audits/<plan-slug>-conformance.md`.
- Engine tax applied: capability either consumes an engine primitive, adds a new one + MCP tool, or is documented vertical-only.
- Telemetry on new write paths.
- Skills + memory updated if domain knowledge changed.

Notice the *negation form* on several items — "NOT compiles / tests pass." This is doing important work: it tells future-Claude what *doesn't* count as done. Negation is high-information.

**Universal pattern — the verification ladder.** Every project, regardless of domain, has a verification ladder:

| Surface type | Cheapest verification | Mid-tier | Most expensive |
|---|---|---|---|
| UI screen | Static screenshot | Interaction-audit | Maestro/Playwright e2e |
| API endpoint | Type-check pass | Unit test | Integration test against staging |
| Database write | Schema lint | RLS audit | Cross-table consistency probe |
| CLI tool | `--help` output diff | Output-matches-golden test | E2E shell-script harness |
| Doc page | Markdown render | Link-check | Human read-through |

Every project has *some* version of this. Layer 3 captures the project's specific ladder.

**Memory typing system.** The source project uses four memory types in cross-conversation memory:

| Type | Prefix | Decay | Example |
|---|---|---|---|
| **Project** | `project_*.md` | Manual archive when superseded | `project_strategy_2026_05.md` |
| **Feedback** | `feedback_*.md` | Promote to rule when it fires 3+ times | `feedback_no_minimal_blast_radius.md` |
| **Reference** | (other names) | Permanent | `LANGUAGE_PATTERNS.md` |
| **User** | embedded in MEMORY.md top | Permanent + auto-loaded | "User's email is X" |

The typing matters because *the four types have different lifecycles*. Project memory ages out as strategy shifts; feedback memory should ideally graduate to rules; user memory is permanent. Without typing, all memory becomes a pile that grows monotonically and stops being useful.

**Anonymized template — Process Discipline `CLAUDE.md` block.**

```markdown
## How You Work

**<PROJECT_VOICE_BIAS>** — <key behavioral defaults: e.g. "Aim for the best result, not the smallest diff" / "Trace before you propose" / "Plan-driven work: spec ↔ impl conformance is mandatory">.

**Task classification:**

| Task | Approach |
|---|---|
| <TASK_TYPE_1> | <ROUTING> |
| ... |

**Specialists:**
- **Domain skills** auto-load by file path — see `.claude/skills/*/SKILL.md` frontmatter `paths:`. <ENUMERATE_KEY_ONES>.
- **Validation agents** — see `.claude/agents/*.md`. Common: <ENUMERATE>.
- **User-invocable skills** (require explicit `/<name>`): <ENUMERATE>.

## Definition of Done

- <DOD_BULLET_1>
- <DOD_BULLET_2>
- ...
```

---

### 2.4 — Layer 4: Quality Bar

**What this layer captures.** The *what does good look like* layer. Without it, "ship S-tier work" is meaningless. The 78-knob design analysis surfaced one core insight: every quality rubric needs anchored references. *"Looks like Linear"* is binding; *"looks premium"* is not.

Five sub-concerns:

- **Tier 1 benchmarks** — the chrome reference apps. 2–3 specific named apps that grade every surface decision in the relevant domain. For UI: e.g. "Apple iOS 26 + Telegram" for native iOS, "Linear + Stripe + Vercel" for SaaS dashboards. For CLI: "Raycast + gh CLI." For docs: "Stripe API ref + Linear changelog."
- **Tier 2 benchmarks** — the domain reference apps with the specific dimension each is the reference for. E.g. "WHOOP for data density, Things 3 for empty states, Stripe Checkout for wizard pacing."
- **Anti-references** — the apps the design must *not* look like. E.g. "Material 2 / Bootstrap / SAP enterprise grid; consumer-bubbly tone; heavy drop-shadow Android card stacking."
- **Demo test** — the single concrete question that grades work. The source project uses *"Would I demo this to a [target customer #2] I'm trying to recruit?"* This is a customer-truth question, not a vibes question.
- **Per-domain rubrics** — S/A/B/C/D grades anchored to the named benchmarks. *"S = a [Tier 1 app] engineer would compliment this. A = ships at [Tier 1 app] quality with one polish pass. B = ships at competent SaaS quality. C = ships but visibly behind. D = embarrassing next to [Tier 1 app]. F = block ship."*

**What it authors.**

- `.claude/rules/<domain>-north-star.md` per applicable domain — the binding statement of what S-tier looks like in that domain. For most projects this is `design-north-star.md` (UI); some projects also have a `voice-north-star.md` (brand voice) or `api-north-star.md` (developer-facing API ergonomics).
- `.claude/skills/quality-bar/SKILL.md` — the operational rubric. Auto-loaded by every Layer 6 quality-audit agent.
- Per-domain rubric anchors inside `.claude/agents/<auditor>.md` frontmatter / body — each auditor's grade scale references the benchmarks.

**Source-project example.** From `.claude/rules/design-north-star.md`:

> *"Every owner-facing surface is graded against **Apple's iOS 26 native chrome and Telegram on iOS 26**. Not 'premium SaaS.' Not 'WHOOP-style.' Apple + Telegram. Specifically. This isn't aesthetic preference — it's a calibrated decision about who our users compare us against. Owners run their gym from an iPhone they already use for Apple Music, Photos, Messages, Telegram, Wallet."*

Notice the structure:

1. **One sentence stating the benchmark.**
2. **Negation of close-but-wrong alternatives.** ("Not premium SaaS. Not WHOOP-style.") This is doing a lot of work — it pre-empts the inevitable drift toward generic-SaaS aesthetics.
3. **Calibration rationale.** Why these specific apps and not others.

Then the rest of the rule is a *per-surface chrome reference table*: tab bar → Apple's `UITabBar`; cards → Apple Settings rows + Telegram settings rows; sheets → Apple Settings sheets (NOT Apple Music Now Playing); empty states → Apple Photos memories; motion → UIKit spring physics; etc. Every surface has *the specific reference screen*, not a vague "iOS-native."

**Universal pattern.** Every project benefits from this layer, but the *content* varies by domain:

- A **UI product** has design north-star: Tier 1 chrome refs (e.g. Apple iOS 26 + Telegram for native iOS; Linear + Stripe + Vercel for SaaS dashboards) + Tier 2 domain refs (e.g. WHOOP for data density, Things 3 for empty states) + per-surface table.
- A **CLI tool** has CLI north-star: Tier 1 (e.g. `git` + `gh`) + Tier 2 (e.g. `jq` for output formatting, `ripgrep` for performance, `httpie` for output color) + per-subcommand references. Example surface table: command parsing → `git` (subcommand model); help output → `gh` (structured, scannable); error messages → `cargo` (recovery-suggestion focused).
- A **dev library** has API north-star: Tier 1 (e.g. React Query for hook ergonomics + Zod for type-narrowing API) + per-API-surface refs.
- A **docs site** has docs north-star: Tier 1 (e.g. Stripe API ref + Linear changelog) + per-page-type refs (tutorial → Astro docs; reference → MDN; changelog → Vercel).
- A **research prototype** may skip this layer entirely (no users → no quality bar above "produces interpretable output"). Bootstrap detects this and offers the skip.

**The benchmark dimension is load-bearing.** *"Stripe is good"* is not a benchmark. *"Stripe for wizard pacing — the multi-step checkout that doesn't feel multi-step"* is. The *specific dimension* each benchmark is the reference for forces clarity. Without it, every Tier 2 reference becomes a vague "good design" claim that doesn't survive the first design decision.

**Anti-references are load-bearing.** Naming what the design must *not* look like is harder than naming what it should. The source project's design-north-star names "Material You / Android-y card stacking" as anti-pattern explicitly. Without that, every contributor brings their own implicit anti-references, and the design drifts. With it, "is this Material-y?" becomes a falsifiable question.

**Anonymized template — `design-north-star.md` skeleton.**

```markdown
# Design north star — <TIER_1_BENCHMARKS>

Every <USER_FACING_SURFACE_TYPE> is graded against **<TIER_1_BENCHMARKS>**. Not <ANTI_REF_1>. Not <ANTI_REF_2>. <TIER_1_BENCHMARKS>. Specifically.

This isn't aesthetic preference — <CALIBRATION_RATIONALE>.

## Surfaces this rule binds

| Surface | <TIER_1_BENCHMARK_1> reference | <TIER_1_BENCHMARK_2> reference |
|---|---|---|
| <SURFACE_TYPE_1> | <SPECIFIC_SCREEN_OR_PATTERN> | <SPECIFIC_SCREEN_OR_PATTERN> |
| ... |

## Anti-patterns

- <ANTI_PATTERN_1> — <why we reject it> (override syntax: <OVERRIDE_COMMENT>).
- ...

## Verification checklist

1. Open <TIER_1_BENCHMARK_1>'s nearest-equivalent screen — screenshot it.
2. Compare side-by-side with our screen.
3. Name 1 thing we do better, 1 thing they do better, 1 thing to fix.
4. If we can't claim parity on any non-trivial dimension, it's not done.
```

---

### 2.5 — Layer 5: Knowledge Graph

**What this layer captures.** The *external memory* layer — `docs/` as the project's persistent, indexed brain. Without it, every session re-derives context. With it, sessions reference stable canonical sources.

Six sub-concerns:

- **`docs/` root conventions** — naming, dating, archive policy.
- **Brainstorms** — exploratory WHAT-to-build docs, dated, slug-named.
- **Specs** — point-in-time design specs from `product-designer` or equivalent.
- **Plans** — multi-step implementation plans (from `superpowers:writing-plans` or equivalent).
- **Audits** — dated audit artifacts (conformance, flow, interaction, UX, security).
- **Capability map** — the WHAT-the-product-does layer (stable IDs referenced by brainstorms / specs / audits).
- **Design system docs** — identity layer if the project has a non-trivial design system.
- **Memory directory** — cross-conversation memory, indexed at the top of `MEMORY.md`.
- **Archive policy** — nothing is deleted; aged docs move to `docs/archive/<category>/`.

**What it authors.**

- `docs/README.md` — the entry point. Lists the structure, the reading order for a newcomer, the authority hierarchy (which doc answers which question).
- `docs/` skeleton — empty subdirectories with `.gitkeep` if needed:
  - `docs/brainstorms/`
  - `docs/specs/` (or `docs/designs/`)
  - `docs/plans/`
  - `docs/audits/`
  - `docs/product/capabilities.md` (stable IDs scaffold)
  - `docs/design-system/` (if applicable)
  - `docs/archive/{brainstorms,audits,specs,memory}/`
- `CLAUDE.md` "Where to find what" section — pointers into `docs/` + the authority hierarchy.

**Source-project example — `docs/README.md`.** The source project's `docs/README.md` (this doc was read in §0 context-gathering) explicitly lays out:

1. **Reading order for a newcomer.** Seven steps from `CLAUDE.md` → strategy rule → capability map → design-system README → flows doc → onboarding doc → topic-specific.
2. **Authority hierarchy table.** "Which doc answers which question." Twelve question shapes, each mapped to its canonical source. *"What can users currently do?" → `docs/product/capabilities.md`*. *"How should this card animate?" → `docs/design-system/motion.md`*.
3. **Top-level legacy docs resolution.** Each pre-existing top-level doc explicitly classified (keep / archive / rewrite) with date and reason.
4. **Maintenance conventions.** Naming convention per doc type, cross-link convention, last-verified-dates convention, archive policy.

The load-bearing parts: **(a)** the reading order means a new session / new contributor / AI tool knows what to read first; **(b)** the authority hierarchy means when two docs claim authority on the same topic, there's a tiebreak procedure (date + specificity); **(c)** the archive policy means nothing is deleted, so historical context is recoverable.

**Universal pattern — every project benefits from external memory.** Even a 1-week-old prototype benefits from a `docs/README.md` and one `docs/brainstorms/2026-MM-DD-initial-direction.md`. The marginal cost is ~30 minutes; the marginal benefit compounds as the project grows. By the 3-month mark, projects without an external memory layer are paying tax every session — Claude re-asks the same context questions, the user re-explains the same product context, decisions are re-derived.

The doc-type taxonomy generalizes:

| Doc type | Purpose | Lifecycle |
|---|---|---|
| **Brainstorm** | WHAT-to-build exploration | Captures + decision log; ages out after capability ships or pivot |
| **Spec** | Point-in-time design contract | Lives until the feature ships + conformance audit; then archives |
| **Plan** | Multi-step implementation roadmap | Lives until the plan completes; archives after |
| **Audit** | Dated snapshot of state | Lives until next audit at same scope supersedes |
| **Flow** | Canonical multi-screen journey | Permanent + last-audited dated |
| **Capability map** | Stable-ID list of what users can do | Permanent + per-entry status-tagged |
| **Reference** | Substrate / pipeline / architecture description | Permanent + last-verified dated |
| **Research** | Competitive / UX dossier | Permanent (archive if invalidated) |

**The capability map is the highest-leverage doc.** The source project introduced `docs/product/capabilities.md` 2026-05-18 — a stable-ID list (`O.1`, `O.2`, `M.1`, etc.) of *what users can currently do*. Every brainstorm, every design spec, every audit conformance matrix references the capability IDs. This decouples *what* the product does from *how* it does it (which churns more). When the implementation refactors, capability IDs stay stable; when the capability set evolves, the IDs reflect that with `[partial] → [shipped]` status tags.

Why this matters for bootstrap: the capability map is the *one* doc that should exist from day-1 of a non-trivial project. Even with `<UNKNOWN>` placeholders, it forces *naming* the product's capabilities — and the names become the lingua franca for every downstream doc.

**Anonymized template — `docs/README.md` skeleton.**

```markdown
# `docs/` — <PROJECT_NAME> knowledge graph

This folder is the primary knowledge graph for <PROJECT_NAME>. Anyone (or any agent) opening the repo reads this file before anything else under `docs/`.

> Companion knowledge sources outside this folder: `CLAUDE.md` (root), `.claude/rules/*.md`, `.claude/skills/*/SKILL.md`, memory directory.

## Reading order for a newcomer

1. `CLAUDE.md` (root) — rules + DoD + task classification.
2. `<STRATEGY_OR_VISION_DOC>` — current strategy / ICP.
3. `docs/product/capabilities.md` — what users can currently do.
4. `<DESIGN_SYSTEM_README_IF_APPLICABLE>`
5. `<FLOW_DOC_FOR_CANONICAL_USER_JOURNEY>`
6. (Topic-specific) — `<TOPIC_DOC_LIST>`

## Authority hierarchy

| Question | Canonical source |
|---|---|
| "What can users currently do?" | `docs/product/capabilities.md` |
| "What's the canonical flow X look like?" | `docs/flows/<arc>.md` |
| ... |

## Maintenance conventions

### Naming
- Brainstorms: `docs/brainstorms/YYYY-MM-DD-<slug>-brainstorm.md`
- Specs: `docs/specs/YYYY-MM-DD-<slug>-spec.md`
- Audits: `docs/audits/YYYY-MM-DD-<slug>-<audit-type>.md`

### Archive policy
- Brainstorm > 60 days without commit-follow-up → `docs/archive/brainstorms/`
- Audit > 90 days without re-audit → `docs/archive/audits/`
- Nothing is deleted.
```

---

### 2.6 — Layer 6: Domain Kits (where current v1 lives)

**What this layer captures.** Domain-specific quality + verification kits. This is where current v1 already operates. The reframe: v1 isn't *the plugin*, it's *Layer 6 of the plugin*.

Eight domains canonical (the user's project may need fewer; bootstrap checks applicability before authoring):

- **Design** — UX / IA / a11y / visual quality / interaction semantics / flow continuity. Showpiece domain, most-developed by v1.
- **Coding** — file-size / code review / decomposition / voice / forbidden phrases.
- **Planning** — pre-flight risk assessment / audit routing / development pipeline.
- **Testing** — test architecture / coverage strategy / fixture discipline.
- **Data** — DB integrity / query discipline / migrations / RLS / schema audits.
- **AI workflow** — LLM cost monitoring / eval discipline / cache hit rate / model-routing decisions.
- **Native bridge** (optional) — if RN/iOS/Android: ref-vs-state events / delegate-queue patterns / Swift-actor pitfalls.
- **Pipeline integrity** (optional) — if data pipelines / ETL / generators: dual-path enrichment / data quality assertions / per-stage telemetry.

**What it authors per domain.**

- `.claude/agents/*` — auditor agents specific to the domain (one to ~10 per domain).
- `.claude/skills/*` — domain-specific skills (auto-loaded by file path).
- `.claude/hooks/*` — domain-specific enforcement hooks.
- `.claude/rules/*` (cross-cutting) — when the rule is consumed by multiple domains.

**This is what v1 already does — the contract is preserved.** The 53-knob design analysis (`docs/design-stack-analysis.md`) and the 78-knob greenfield expansion (`docs/design-greenfield-audit.md`) are the methodology for one domain (design). The smoke test (`docs/design-smoke-test-2026-05-20.md`) demonstrated ~85% parity on a mature brownfield codebase. Other domains follow the same pattern at smaller scale (coding ≈ 15 knobs, planning ≈ 10, testing ≈ 12, data ≈ 18, ai-workflow ≈ 10).

**Per-domain artifact count signal.** From the source project's `.claude/`:

| Domain | Agents | Skills | Hooks | Rules | Total |
|---|---|---|---|---|---|
| Design | 9 | 8 | 4 | 5 | 26 |
| Coding | 3 | 3 | 1 | 1 | 8 |
| Planning | 2 | 2 | 0 | 0 | 4 |
| Testing | 1 | 2 | 0 | 0 | 3 |
| Data | 2 | 2 | 0 | 1 | 5 |
| AI workflow | 1 | 1 | 0 | 0 | 2 |
| Native bridge | 1 | 1 | 0 | 0 | 2 |
| Pipeline integrity | 1 | 1 | 0 | 0 | 2 |

Design dominates because it's the most-developed domain in the source project. Bootstrap is calibrated to that distribution: a mature design domain ships ~25 artifacts; a coding domain ~8; the long tail is smaller.

**Applicability gates.** Not every project needs every domain. Bootstrap's Phase 2 (domain applicability check) is preserved from v1's `skills/init/SKILL.md`:

| Domain | Apply if project has… | Skip if… |
|---|---|---|
| **design** | UI surfaces | Pure backend / library / dev tool |
| **coding** | Any code at all | (Universal — never skip) |
| **planning** | Multi-module changes | Single-file utility |
| **testing** | Tests exist or should | Pure exploration |
| **data** | Database / persistent state | Stateless |
| **ai-workflow** | LLM / AI calls | No AI in scope |
| **native-bridge** | RN / iOS / Android with native modules | Web-only / pure-RN |
| **pipeline-integrity** | Multi-stage data pipelines / ETL | No pipelines |

Skip is a deliberate call with a stated reason, surfaced to the user before any authoring. The user can override.

**Reference: the v1 design skill is the most-developed Layer 6 implementation.** See `skills/design/SKILL.md` for the canonical structure: Phase 1 (project scan), Phase 2 (interview, ~5–6 super-questions driving 28+ knobs), Phase 3 (selective principle read), Phase 4 (authoring with the 10-element depth checklist), Phase 5 (stage + present + commit). Other domains follow the same five-phase shape but with smaller knob counts. The shape is the contract — bootstrap's per-domain handoff trusts each domain skill to honor it.

**Where v2 changes Layer 6 (minimal).** The v1 domain skills assume *Layers 1–5 don't exist yet* — they author standalone. v2's domain skills consume Layers 1–5 as upstream context. Specifically:

- A v2 `/dotclaude:design` reads `CLAUDE.md` for identity / architecture / process / quality bar before its own interview. Questions whose answers are already in those upstream layers are skipped. E.g. if Layer 4 already named "Linear + Stripe" as Tier 1 chrome, design's Q-B1 doesn't re-ask; it confirms.
- A v2 `/dotclaude:coding` reads `CLAUDE.md` "Definition of Done" before authoring `code-reviewer.md` — the agent's anti-pattern list extends DoD rather than restating. The DoD is the *contract*; the code-reviewer enforces it. Duplicating DoD inside the reviewer creates drift.
- A v2 `/dotclaude:planning` reads `docs/README.md` (Layer 5) for the audit-doc convention before authoring `pre-flight.md` — pre-flight outputs land at the same convention path, no invented alternative.
- Cross-domain consistency: `forbidden-phrases.txt` ships under design (voice) and coding (AI slop); v2 merges them at bootstrap time rather than v1's "last domain wins" approach.

This is *backward-compatible* — v1's domain skills work standalone too (an existing `/dotclaude:design` invocation in v1 still works). Bootstrap just gives them richer upstream context when invoked through the hierarchy.

**Per-domain skill structure (the v1 pattern, preserved).** Each domain skill in `skills/<domain>/SKILL.md` follows the 5-phase shape:

1. **Phase 1 — Project scan.** Read project files to ground the interview.
2. **Phase 2 — Interview.** 3–6 super-questions driving the domain's knob set.
3. **Phase 3 — Read principles.** Selective principle reads from `principles/` based on Phase 1/2 signals.
4. **Phase 4 — Author the kit.** Write artifacts to `.claude-staging/`. Each must pass the 10-element depth checklist.
5. **Phase 5 — Stage + present + commit.** Walk user through, get approval, move to `.claude/`.

v2 inherits this shape. Bootstrap orchestrates by calling each domain skill's Phase 1–5 in sequence after handing it the Layers 1–5 context.

---

### 2.7 — Layer 7: Maintenance

**What this layer captures.** Long-lived projects drift. Layer 7 is the *drift detection + correction ritual* layer — the operational loop that keeps Layers 1–6 honest over time.

Four sub-concerns:

- **Design-debt ritual** — periodic batch audit of open findings, decision sheet, user marks F/D/?/X, implementer takes the marked items.
- **Drift detection** — automated audits that fire on a schedule (weekly token sweep, monthly skill-vs-code consistency check, quarterly capability-map vs reality audit).
- **Audit cadence** — re-audit policy per artifact type (audit doc > 90 days stale → re-audit; flow doc > 180 days → re-audit against current code).
- **Skill audit** — skill files vs the code they describe. If `auth-navigation/SKILL.md` says `app/wizard/auth.tsx` is the auth entry but the code now lives elsewhere, the skill is drift.

**What it authors.**

- `.claude/rules/maintenance-ritual.md` — the operating loop description (cadence, decision protocol, archive policy).
- `.claude/agents/skill-auditor.md` — the agent that audits skills vs code (runs monthly).
- `.claude/skills/audit-rituals/SKILL.md` — the user-invocable Saturday audit (`/dotclaude:audit-week` or equivalent).
- `docs/design-debt/registry.md` — the canonical open-findings registry.
- (Optional) `.github/workflows/weekly-token-sweep.yml` — automated weekly hook of `design-token-auditor` over the codebase.

**Source-project example — the Saturday design-debt ritual.** From the source project's memory entry `project_saturday_design_ritual`:

> *"Weekly 30-min cadence: Fri-night audit → Sat-morning batch sheet → user F/D/?/X marks → Claude implements during week. Registry at `docs/design-debt/registry.md`. Edit-time hooks (forbidden-phrases, token-only) prevent classes of finding entirely."*

The ritual has **four properties** that make it work:

1. **Bounded time.** 30 minutes / week. Not "audit when you feel like it." Recurring blocks become habit; ad-hoc ones don't.
2. **Batch decision interface.** The user marks each finding F (fix now) / D (defer) / ? (need-more-info) / X (won't fix / accept). Claude implements only F items. The structured input keeps the loop tight.
3. **Hooks first.** Edit-time hooks prevent the most common findings *before they enter the registry*. The ritual is for finds the hooks miss.
4. **Registry as canonical source.** Open findings live in *one* doc. No GitHub issues + Linear + Notion + chat-channel sprawl.

**Universal pattern — long-lived projects need explicit drift-detection rituals.** Without one, three drift modes emerge:

- **Skill drift** — `auth-navigation/SKILL.md` describes the auth flow as of 6 months ago, doesn't match current code. Claude consumes the stale knowledge, makes wrong recommendations.
- **Doc drift** — `docs/flows/onboarding.md` describes the onboarding flow as of last redesign, doesn't match shipped state. Conformance matrices fail silently because the "matches what spec said" assertion uses a stale spec.
- **Rule drift** — `.claude/rules/file-size.md` says ceiling is 1000 LOC, but the team's been routinely overriding via `// allow-large: <reason>`. The rule is dead.

Layer 7 detects all three.

**When to defer Layer 7.** Two cases:

- **Project < 1 month old.** Not enough debt to ritualize. Bootstrap notes Layer 7 as "deferred until first audit cycle surfaces > 5 open findings."
- **Solo + small.** A solo dev on a 5-file repo doesn't need a Saturday ritual. The cost-benefit favors deferral.

In both cases bootstrap *names* Layer 7 (so the user knows it exists) and stages the artifacts under `.claude/_deferred/` for opt-in promotion later.

**The four properties of a working ritual** (from Lesson 12) generalize beyond design debt:

1. **Bounded time.** Pick a cadence (weekly / biweekly / monthly) and stick to it. Variable cadence becomes no cadence.
2. **Batch decision interface.** Findings come in batched; user marks each F/D/?/X in a single sitting. Ad-hoc decision-making per finding is exhausting; batch is bearable.
3. **Hooks first.** Edit-time hooks prevent the most common findings *before they enter the registry*. The ritual is for finds the hooks miss.
4. **Registry as canonical source.** Open findings live in *one* doc. No GitHub issues + Linear + Notion + chat-channel sprawl.

**Drift detection categories.** Three drift modes Layer 7 detects:

| Drift mode | What's drifting | Detection method | Frequency |
|---|---|---|---|
| **Skill drift** | `.claude/skills/<X>/SKILL.md` describes the code as of N months ago | `skill-auditor` agent reads skill + greps cited paths + checks they exist with cited shape | Monthly |
| **Doc drift** | `docs/flows/<arc>.md` describes the journey as of last redesign | Re-run flow capture (Maestro / Playwright) + compare against doc's documented terminals | Quarterly |
| **Rule drift** | `.claude/rules/file-size.md` says ceiling 1000 LOC but `// allow-large` overrides used routinely | Grep for override syntax across codebase, count occurrences, surface trend | Monthly |

Each detection mode has its own automation. The Saturday ritual is the user-facing decision interface for findings; the detection automation runs in CI / on schedule.

**The skill-auditor agent.** Reads each `.claude/skills/<X>/SKILL.md`. For each cited file path, code reference, or grep pattern: verifies the cited target still exists with the cited shape. Reports stale skills with severity tags (CRIT = skill is fundamentally wrong about current code; MAJ = skill is partially stale; minor = one minor inaccuracy). Runs monthly. Findings land in `docs/design-debt/registry.md` for user F/D/?/X marking.

**Anonymized template — `maintenance-ritual.md` skeleton.**

```markdown
# Maintenance ritual

Cadence: <WEEKLY | BIWEEKLY | MONTHLY>. Time-box: <N> minutes.

## The loop

1. **<TRIGGER>** (e.g. Friday evening) — run the audit batch:
   - <AUDIT_AGENT_1>
   - <AUDIT_AGENT_2>
   - ...
2. **<DECISION_INTERFACE>** (e.g. Saturday morning) — user marks each finding:
   - F = fix now
   - D = defer (move to backlog)
   - ? = need more info (Claude investigates)
   - X = won't fix / accept (closes finding with rationale)
3. **Implementation** — Claude takes F-marked items during the week, one PR per item.
4. **Registry update** — `docs/design-debt/registry.md` reflects current state.

## Drift detection (automated)

- Weekly: <DRIFT_CHECK_1> (e.g. `design-token-auditor` over codebase)
- Monthly: `skill-auditor` agent vs `.claude/skills/*` (skill ↔ code consistency)
- Quarterly: `capability-map-auditor` (capabilities.md ↔ shipped code reality)
```

---

## 3. The 12 transferable lessons distilled from the source project

The seven layers above are the *organizing skeleton*. The twelve lessons below are the *load-bearing methodology*. Each one was extracted from the source project's `CLAUDE.md` + `docs/` + `.claude/` + memory + actual session history. Each is *transferable* — applies to most non-trivial projects regardless of domain.

A future v2 release ships these as principles under `principles/` (filling the gap above v1's existing 29 principles which live at Layer 6).

### Lesson 1: CLAUDE.md as single entry point

**The pattern.** One `CLAUDE.md` at repo root, ~300–600 LOC, with these sections in this order: Identity → Architecture → How You Work → Constraints → Where to find what → Definition of Done. Read by Claude at the start of every session, before anything else. The hard discipline: **one** file, **not** sprawl across `AGENTS.md` + `CONTRIBUTING.md` + `STYLE_GUIDE.md` + scattered READMEs.

**Why it matters.** Without it, every session re-derives context. With it, the context is stable: Claude reads it once per session, references it across the conversation, doesn't re-ask "what's the architecture again." It's the *project north star* surfaced to the AI tool. Three failure modes without `CLAUDE.md`:

1. **Re-derivation tax.** Every session opens with 5–10 turns of "where does X live? what's the import boundary? do you use TDD here?" That's tokens + user time + context drift, all preventable.
2. **Routing inconsistency.** Without the task classification matrix in `CLAUDE.md`, sessions route the same task differently — sometimes UI feature → product-designer agent → impl → audit; sometimes UI feature → straight to impl → no audit. The kit's quality bar floats.
3. **Lost institutional knowledge.** Lessons learned in session N are usually lost by session N+1 unless they land in memory or `CLAUDE.md`. The latter scales further (every session reads `CLAUDE.md`; only the relevant session reads its own memory).

**Source-project example.** `CLAUDE.md` is ~600 LOC at repo root. Identity opens with the product positioning (1 paragraph + ICP + moat), then architecture (~80 LOC with horizontal + vertical layers + boundary statement), then "How You Work" (~150 LOC including the task classification table + Specialists subsection), then Constraints (~80 LOC of bullets each backed by a hook or rule), then "Where to find what" (~40 LOC of pointers into `docs/` + skills + rules + memory), then Definition of Done (~50 LOC of checklist items). Critically: every paragraph is *actionable* — no marketing copy, no aspirational vision, no "we believe in quality." Every line either binds Claude's behavior or routes Claude to a place that does.

**Abstract / universal form.** Every project that has > 1 contributor, > 100 files, or > 1 month of history benefits from `CLAUDE.md`. The 6 sections above are minimum; specific projects may add:
- A "Constraints" subsection enumerating active edit-time hooks (project-specific to the hook stack).
- A "Pre-flight" subsection listing risk-assessment triggers for complex changes.
- A "Memory" subsection pointing into the typed memory directory.
- A "Deferred work" subsection — explicit list of layers/concerns not yet active (e.g. *"Layer 7 maintenance deferred until first audit cycle"*).

**Anti-pattern.** The biggest failure mode of `CLAUDE.md` is **growing without curation**. A `CLAUDE.md` that hits 1500+ LOC stops being read carefully — Claude loads it, but the lower sections lose attention. Discipline: when adding to `CLAUDE.md`, ask *"does this belong here, or in a `.claude/rules/` doc that `CLAUDE.md` points to?"* Most cross-cutting concerns belong in rules; `CLAUDE.md` should be the table-of-contents + binding-language layer.

**Maps to layer.** Layers 1, 2, 3 (the file itself spans identity, architecture, process). Layer 5 references it.

---

### Lesson 2: `docs/` as external memory

**The pattern.** A `docs/` directory with strict naming conventions per doc type (brainstorms / specs / plans / audits / capabilities / flows / archive). Every doc dated when temporal (`YYYY-MM-DD-<slug>-<type>.md`), slug-named when permanent (no date in filename — date lives inside as `**Last verified:** YYYY-MM-DD`). Cross-link convention at the top of each doc (`**Related:** upstream → · downstream ← · sibling ↔`). Archive policy: nothing deleted, aged docs move to `docs/archive/<category>/`, indexed via reverse-chronological ls.

**Why it matters.** External memory is the only way to scale context past one session. Without `docs/`, every brainstorm is lost when the chat closes. With `docs/`, the brainstorm is a referenceable artifact: a future spec cites it; a future audit traces back to it; a future contributor reads it. Three concrete failure modes without external memory:

1. **Brainstorm amnesia.** *"Did we already discuss the X approach a month ago?"* Without `docs/brainstorms/`, you re-explore. With it, `ls docs/brainstorms/ | grep X` resolves in 10 seconds.
2. **Conformance illegibility.** *"Did sub-plan 3 actually ship every § of the spec?"* Without `docs/audits/`, you read the implementation and reconstruct. With dated audit reports, you read the matrix and know.
3. **Cross-link rot.** *"The README says see `flow.md`, but that doc moved."* With a maintained `docs/README.md` authority hierarchy + last-verified dates, drift is detectable. Without, the graph silently rots.

**Source-project example.** `docs/` has ~12 subdirectories:
- `brainstorms/` — dozens of dated docs going back ~3 months, naming convention `YYYY-MM-DD-<slug>-brainstorm.md`.
- `specs/` (named `designs/` in source project) — point-in-time design specs, same naming convention.
- `audits/` — dated audit reports per artifact type (`-conformance.md`, `-flow-audit.md`, `-ux.md`).
- `flows/` — canonical multi-screen journey docs, no date in filename, last-audited inside.
- `product/capabilities.md` — single capability map with stable IDs (`O.1`, `M.1`, etc.).
- `design-system/` — identity layer docs (persona / motion / tokens / agent-layer / components).
- `archive/` — aged-out content. Brainstorms > 60 days without commit-follow-up; audits > 90 days without re-audit; design specs whose feature shipped + has conformance matrix.

`docs/README.md` is the entry point that maps the whole graph + reading order + authority hierarchy + archive policy. ~180 LOC. Read by Claude when entering the `docs/` knowledge graph.

**Abstract / universal form.** Every project that does *any* non-trivial design work or architectural decision-making benefits. The 6 sub-directories (brainstorms / specs / audits / archive + capabilities + flows) are minimum; specific projects add:
- `docs/design-system/` — for projects with a non-trivial UI design system.
- `docs/preflights/` — for projects that use pre-flight risk assessment.
- `docs/superpowers/{plans,specs}/` — for projects using the superpowers plan-writing skill.
- `docs/research/` — for projects that capture competitive/UX research dossiers.
- `docs/mcp/` — for projects that author MCP servers.

**Anti-pattern.** *Dumping all docs at `docs/` root with no subdirectory convention.* Within 6 months you have 80 mixed `.md` files at `docs/` and no way to find anything. Subdirectory discipline is what makes the graph navigable.

**Maps to layer.** Layer 5.

---

### Lesson 3: 4-tier cost ladder discipline

**The pattern.** Catch at the cheapest tier. Hook < Rule < Skill < Agent in LLM cost. When adding a new check, ask *can a hook catch this?* before reaching for an agent. A token-discipline hook prevents an entire class of design-token-auditor findings at edit time, with zero LLM cost.

**The promotion / demotion direction.** Findings should flow *upward* in the ladder. Pattern emerges in an agent finding → if it fires 3+ times, write it as a skill → if it becomes a hot path, escalate to a rule → if it's greppable, escalate to a hook. The end state is the catch at the cheapest tier that can express it. Inverse rule: when a hook fires constantly with the same `// allow-X: <reason>` override, ask if the rule is wrong (demote upward into a rule with conditional language).

**Why it matters.** Cost compounds. An always-on rule costs ~500 tokens/session × 100 sessions/month = 50k tokens. An agent dispatched 20×/month at 15k tokens/dispatch = 300k tokens. Hook = 0 LLM cost. Cheapest-tier-first saves measurable money over project lifetime, AND it makes failure more reliable (a hook always runs; an agent only runs when invoked).

A worked example. The source project's `check-token-only.sh` blocks raw hex outside `lib/theme/`. Before the hook existed, `design-token-auditor` (haiku-tier agent) would catch raw hex during periodic sweeps — but findings sat in the registry for days before fix. After the hook landed, raw hex is rejected at edit time; the agent's role shrinks to "audit overrides + propose token gaps." Same finding class, 1/20th the cost, 100× the reliability.

**Source-project example.** Six active edit-time hooks: `check-file-size.sh`, `check-vertical-boundary.sh`, `check-forbidden-phrases.sh`, `check-token-only.sh`, `check-no-expo-blur.sh`, `check-nativetabs-sf-icon.sh`. Each prevents a class of finding that would otherwise need an LLM dispatch. The audit-routing rule explicitly says *"If you find yourself dispatching `design-token-auditor` to find raw hex, ask first: did `check-token-only.sh` fire on the offending edit? If not, fix the hook."* This sentence is doing huge work — it makes the cost ladder a *binding* discipline, not just a recommendation.

**Hook authoring discipline.** Every hook in the source project follows the same shape:
- Filter input by tool name (PostToolUse `Write|Edit` only).
- Filter by file path (skip tests, generated, vendored).
- Grep for the violation pattern.
- Filter out overridden lines (`// allow-<rule>: <reason>`).
- Block on remaining matches, exit 0 otherwise.
- Output to stderr in a specific format Claude can parse.

The override convention (`// allow-X: <reason>`) is what makes hooks usable. Without it, hooks become hated chokepoints; with it, they're enforced-with-escape-hatch.

**Abstract / universal form.** Every project benefits. The specific hooks vary:
- A **Python project** may have `check-black-formatting.sh`, `check-import-order.sh`, `check-no-print-in-prod.sh`.
- A **Rust project** may have `check-unwrap-discipline.sh`, `check-no-pub-everywhere.sh`.
- A **TypeScript project** may have `check-no-any.sh`, `check-no-default-export.sh`.
- A **docs site** may have `check-frontmatter-required.sh`, `check-no-broken-links.sh`.

The discipline transfers; the specific patterns are project-language-specific.

**Maps to layer.** Layer 2 (the ladder is established as part of architecture's enforcement story).

---

### Lesson 4: Plan-driven discipline + conformance matrix

**The pattern.** Non-trivial work goes spec → plan → impl → conformance matrix. The conformance matrix is a `docs/audits/<plan-slug>-conformance.md` doc where every § of the spec is checked off as `matches | deviates(why) | deferred(why)` with per-surface screenshots. "Tests green" is *not* a substitute for the matrix. "Merged" is *not* a substitute either. The matrix is a separate work product that gets read, reviewed, and disagreed-with before claim-of-done.

**Conformance matrix anatomy.** A real matrix has:
- **First row: capability delta.** Lists capability IDs (from `docs/product/capabilities.md`) that this plan transitions. *"`O.3 [partial] → [shipped]`; `M.4 new`."* The capability-delta survives spec-doc archiving; §sections below it are implementation details under the capability.
- **§ rows.** One per spec section. Columns: spec §, assertion (one sentence), evidence (file paths + line ranges + screenshot links), verdict (matches / deviates(why) / deferred(why)), severity (CRIT / MAJ / minor — for deviations only).
- **CRIT/MAJ resolution block.** Below the table: per-deviation, the resolution (fix shipped same change / fix shipped follow-up commit / deferred to plan N+1 with rationale).
- **Screenshot directory.** Captured screenshots referenced from the matrix, stored in `docs/audits/<plan-slug>-screenshots/`.

The discipline: the user reads the matrix, agrees or disagrees with verdicts, signs off. Only then is work "shipped." A subagent's "done" summary is NOT a substitute — the matrix is a human-readable artifact, not an agent self-report.

**Why it matters.** Without conformance matrices, plan-backed work routinely ships 70–85% of the spec while feeling 100% complete. The deviation report after the fact is the painful one — *"oh, we never built §4.2 of the spec, and §3.1 was implemented differently than spec said."* The matrix forces the deviation surfacing *before* claim-of-done. The cost is ~30–60 min of writing the matrix; the benefit is catching deviations while they're still cheap to fix.

The lesson the source project learned the hard way: an approved spec + a subagent reporting "all sub-plans complete" does NOT equal shipped. The subagent reports against the *plan*, not against the *spec*. A plan that fails to fully encode the spec is invisible to the subagent. The matrix audits *spec → reality*, which is what the user cares about.

**Source-project example.** `docs/audits/2026-05-16-onboarding-arc-conformance-audit.md` is the reference matrix. ~10 spec sections, each with assertion + screenshot + status. Caught one CRIT-class deviation (G-001) + 9 minor deviations before ship. Without the matrix, those would've shipped silently and surfaced months later when a recruited customer flagged the broken behavior.

**Abstract / universal form.** Every project that does *plan-driven work at all* benefits. Solo prototypes can defer (no plan → no matrix needed). Team projects, plan-driven solo projects, or projects with external commitments need it. The matrix shape generalizes:
- For a feature spec → matrix rows are spec §.
- For an API redesign → matrix rows are API surface (endpoint × method × status code).
- For a docs reorganization → matrix rows are doc-tree positions.
- For an architectural refactor → matrix rows are before/after import boundaries.

**Maps to layer.** Layer 3 (process discipline). Plan-backed task type in the task classification matrix.

---

### Lesson 5: Task classification → specialist routing table

**The pattern.** A 7–10-row table in `CLAUDE.md` mapping task types (UI feature / bug fix / architecture change / data / plan-backed / ambiguous) to a sequence of specialist agents + validation steps. Read at the start of every non-trivial task to decide the routing.

**The shape that works.** Two columns, named rows:

| Task | Approach |
|---|---|
| (named task type) | (verb-led sequence: "Interview → agent X → implement → validation Y → done") |

Three properties make the table actually used:

1. **Verb-led sequences, not abstract descriptions.** The Approach column reads like a runbook — *"interview, then dispatch agent X, then implement, then run agent Y."* Not *"design phase, implementation phase, validation phase"* (too abstract).
2. **Named specialists by file path.** *"Dispatch `product-designer`"* not *"dispatch a designer agent."* The named specialists exist as files in `.claude/agents/` — clickable links.
3. **An "Ambiguous" row exists.** Always. *"Ask first. Summarize back in 3-5 bullets. Wait for confirmation."* Without this row, sessions silently make scope decisions that the user wouldn't have approved.

**Why it matters.** Compresses dozens of "how should I approach this" decisions into a one-row lookup. Without it, every session re-derives the routing — sometimes well, sometimes badly. With it, the routing is stable across sessions, contributors, and AI tools. The routing matrix also makes *cross-session consistency* possible — if Claude routes UI feature work through `product-designer → impl → pipeline` in Monday's session and through `direct impl → ux-reviewer` in Tuesday's session, the quality bar floats; the user can't predict what they'll get.

**Source-project example.** 7 rows: UI feature/redesign / Backend / pipeline / Bug fix / Architecture change / Data / schema / Plan-backed / Ambiguous. Each row is a sequence like *"Interview → `product-designer` agent (research + design + spec) → implement → pipeline per audit-routing"*. The "Ambiguous" row is critical — it says *"Ask first. Summarize back in 3-5 bullets. Wait for confirmation."* This row has prevented dozens of scope drift incidents.

**Abstract / universal form.** Every project of > 5 file types + > 1 task pattern benefits. Specific rows vary:
- A **CLI project** may have *"New flag/subcommand"* / *"Output format change"* / *"Bug fix"* / *"Refactor"*.
- A **docs project** may have *"New tutorial"* / *"API ref update"* / *"Migration guide"* / *"Site reorganization"*.
- A **library project** may have *"New public API"* / *"Internal refactor"* / *"Bug fix"* / *"Breaking change"*.

The shape is universal. The number of rows scales with project complexity — a simple CLI may have 4 rows; a complex multi-tier product may have 12.

**Maps to layer.** Layer 3.

---

### Lesson 6: Memory typing system

**The pattern.** Four memory types in cross-conversation memory: **user / feedback / project / reference**. Each with its own decay policy.

| Type | Filename pattern | Lifecycle | Promotion target | Example |
|---|---|---|---|---|
| **user** | (top of `MEMORY.md`) | Permanent, auto-loaded | Never promotes | "User's email is X" |
| **feedback** | `feedback_*.md` | Auto-promoted to a rule when it fires 3+ times | `.claude/rules/*.md` | "Never `git stash --include-untracked` on populated WIP" |
| **project** | `project_*.md` | Manual archive when superseded by ship / pivot | `docs/archive/memory/` | "Stage 4 GREEN on Demo" |
| **reference** | (other names) | Permanent unless invalidated | `docs/<topic>.md` if grows | "wedge ICP target is multi-floor" |

Feedback memory is the highest-leverage type. It captures lessons-learned that future-Claude should respect — *"don't do X again"* / *"the trap when Y is Z"*. Each feedback entry should ideally graduate to a rule when it's fired enough times.

**Why it matters.** Untyped memory becomes a pile that grows monotonically. After 6 months it stops being read carefully because the signal-to-noise ratio drops. With typing:
- Memory **graduates upward** (feedback → rule when 3+ firings). The lesson moves from "Claude reads if relevant" to "Claude reads every session."
- Memory **ages out gracefully** (project → archive when superseded). Strategy memory from 6 months ago doesn't pollute current session context.
- Memory **stays permanent** for true persistent facts (user info, reference data).
- Memory **gets indexed at top of `MEMORY.md`** with one-line summary + filename, so Claude reads the index and lazy-loads only relevant entries.

**Source-project example.** `~/.claude/projects/.../memory/MEMORY.md` indexes ~50 entries across the four types. `feedback_*.md` entries are the highest-leverage — they capture lessons-learned that future-Claude should respect. Several graduated to `.claude/rules/*` once they fired enough times (e.g. *"never `git stash --include-untracked` on populated WIP"* is now a `CLAUDE.md` constraint after near-disaster).

The index format matters too. Each entry is a markdown bullet:

```markdown
- [<title> (<date>)](<filename>.md) — <one-sentence summary>.
```

Claude reads only the index by default; entries get expanded when relevant to the current session. This is *lazy loading* of cross-session memory — keeps the always-on context small while making the full memory addressable.

**Abstract / universal form.** Every long-lived project benefits. Short-lived projects (< 2 weeks) can skip — not enough cross-session continuity to type. The specific filename conventions are flexible — what matters is (a) the typing exists, (b) each type has an explicit lifecycle, (c) the index is curated.

**Anti-pattern.** *Letting all memory be "project" type.* Every entry becomes monotonic accumulation. The promotion / archive paths don't fire. After 12 months the directory has 200 entries and nobody knows which still apply.

**Maps to layer.** Layer 3 (memory is part of how-you-work).

---

### Lesson 7: Subagent dispatch patterns

**The pattern.** Three patterns, used in combination:

(a) **Fresh-per-task.** Subagents get a clean context per dispatch, no inherited state. The dispatching session passes context *explicitly* via the prompt (file paths to read, references to consider, the specific question). The subagent doesn't see the parent's conversation history — that's a feature, not a bug.

(b) **Two-stage review.** A primary agent writes (e.g. implementer), a second agent reviews (e.g. `code-reviewer`). For plan-backed work, a *third* stage exists: the conformance matrix (audits the implementation against the spec).

(c) **cd-into-worktree gate.** When dispatching implementers into a git worktree, prefix the prompt with `cd $WORKTREE && pwd && git branch --show-current` plus a STOP/BLOCKED instruction if branch is `main`. Without this, subagents occasionally commit to the parent checkout. The source project has lost partial work to this; the gate prevents recurrence.

**Why it matters.** Subagents are powerful but easy to misuse.
- *Inheriting parent context* bloats their token budget for no reason — a 50k-token parent conversation passed to a focused subagent task wastes 80%+ of the tokens. Fresh-per-task fixes this.
- *Not separating write from review* makes self-review the only review. Self-review misses things; cross-review catches them. Two-stage review fixes this.
- *Not gating worktree* means implementers occasionally commit to the wrong directory. The source project has lost work to this — see `feedback_subagent_worktree_cd_guard` memory. The gate is a non-negotiable.

**Source-project example.** The `subagent-driven-development` superpower skill is the canonical pattern. Worktree gate is in `CLAUDE.md` constraints. Two-stage review pattern: `code-reviewer` agent runs after implementer; conformance matrix is a *third* stage for plan-backed work. The source project also distinguishes between *user-invocable* subagents (require explicit `/<name>`) and *auto-invoked* subagents (fired by the orchestrator under specific conditions) — the distinction matters because user-invocable agents can refuse the wrong task ("this isn't my scope — try X"), while auto-invoked ones execute regardless.

**Abstract / universal form.** Every project that uses subagents at all. Patterns vary by AI tool (Claude Code's `Task` tool vs Aider's multi-agent vs OpenAI Codex's swarm), but the discipline transfers. The cd-into-worktree gate is Claude-Code-and-git-worktree-specific; other tooling needs equivalent isolation.

**Maps to layer.** Layer 3.

---

### Lesson 8: Quality verification ladder

**The pattern.** Every domain has a verification ladder from cheap → expensive. Verification order matters: cheap-first means most issues surface before expensive verifications run; expensive-first means you grade an artifact, then a cheap fix moves stuff around, then you have to re-grade.

For UI: token audit → semantic chrome audit + a11y audit (parallel) → visual polish review → flow continuity audit (multi-screen) → conformance matrix (plan-backed).
For data: schema lint → RLS audit → cross-table consistency probe → data-quality assertions.
For CLI: `--help` diff → output-matches-golden test → e2e harness against staging.
For API: type-check pass → unit tests → integration tests → contract tests against consumers.
For docs: markdown render → link-check → screenshot-of-rendered-output → human read-through.

**Why it matters.** Without the ladder, verification is ad hoc — sometimes only screenshots, sometimes only tests, never both. With the ladder, claim-of-done has a *specific protocol*: tier 1 verified → tier 2 → tier 3, top to bottom, in canonical order. The order is part of the discipline; reversing it costs token + time.

The source-project example makes this concrete. From `.claude/rules/design-audit-routing.md`:

> *"The canonical UI-batch validation order:*
> *1. `design-token-auditor` (free, fast, haiku — fix raw hex first)*
> *2. `interaction-audit` + `a11y-audit` (run in PARALLEL — they audit orthogonal dimensions: semantic chrome vs accessibility integrity)*
> *3. `ux-reviewer` (visual polish — last, because steps 1-2 may shift layout)*"

The reasoning behind the order is load-bearing: *"reversing it forces ux-reviewer to redo work after semantic / a11y fixes move things around."* Without that reasoning stated, someone runs ux-reviewer first because *"visual is the most important," then* fixes a11y, then needs to re-grade visual. Wasted tokens.

**Source-project example.** Design verification ladder (above). Other domains have ladders too:
- **Code**: `lint --fix` → `tests` → `code-reviewer` agent → `tests-architect` agent (for plan-backed).
- **Data**: `apply_migration` → `db:types` generation → `data-auditor` agent (for plan-backed).
- **Plan-backed**: per-stage validation + final conformance matrix.

**Abstract / universal form.** Every domain benefits. Specific ladders vary by the verification primitives the domain has.

**Cross-rubric translation.** When multiple validators grade on different scales, the ladder needs a translation map. The source project's `design-audit-routing.md` has one — S/A/B/C/D (visual reviewer) ↔ Crit/High/Med/Low (flow auditor) ↔ S0/S1/S2 (token auditor) → composite grade. Without this, aggregating verdicts is impossible.

**Maps to layer.** Layers 3 (the discipline) + 6 (the per-domain implementation).

---

### Lesson 9: File-size discipline with decomposition

**The pattern.** Hard ceiling (e.g. 1000 LOC) + soft threshold (e.g. 950 LOC warns). Auto-generated types exempt. Hook enforces at edit time. Hitting threshold triggers mandatory decomposition *in the same change* — not deferred. Decomposition is guided by a `decompose-file` skill that provides the procedure.

**Why it matters.** Files monotonically grow without enforcement. A 200-LOC component becomes 600 LOC over a year, 1200 LOC over two. At 1200 LOC, Claude struggles to reason about the file as a whole — recommendations get worse, refactors get scarier. The ceiling forces decomposition *while it's still cheap*. Decomposing a 1100-LOC file at the moment it crosses the ceiling is ~30 min of work. Decomposing the same file 6 months later when it's 1800 LOC and has accreted more responsibilities is ~3 hours and carries refactor risk.

The discipline has a second-order benefit: *the ceiling is a forcing function for design.* When a file approaches 1000 LOC, the question *"what's the natural split?"* surfaces. Often the answer is *"this file has been doing two things and the split is obvious"* — but that observation only surfaces when forced. Without the ceiling, the two-things file silently grows for years.

**Source-project example.** `.claude/hooks/check-file-size.sh` blocks > 1000 LOC, warns at 950. `CLAUDE.md` says *"Decompose in the same change. `wc -l` after edits."* `decompose-file` skill provides the guided procedure (1. Read the file. 2. Identify natural seams. 3. Propose a split. 4. User approves. 5. Apply via series of small commits.). Auto-generated types are exempt — the source project's generated database types file exceeds 2000 LOC and is correctly exempt.

**Anti-pattern.** *Adding the ceiling but not the decomposition skill.* The user hits the ceiling, the hook blocks, and decomposition is left as an exercise. Half the time the user reverts to a partial edit + `// allow-large: <reason>` override and the file keeps growing. With the skill, decomposition has a procedure; without it, decomposition is friction.

**Abstract / universal form.** Every project. Specific ceilings vary:
- **TypeScript / JS**: 1000 LOC (the source project's choice).
- **Python**: ~500 LOC is often cited.
- **Rust**: 800 LOC given verbosity.
- **Go**: 600 LOC given its style preference for small files.
- **HTML / templates**: 300 LOC (template files have implicit hierarchy that breaks above ~300 LOC).
- **Markdown docs**: 1500 LOC (docs read top-to-bottom, smaller penalty for length).

The discipline transfers; the ceiling is a project-language calibration.

**Maps to layer.** Layers 2 (constraint declared) + 3 (decomposition is process).

---

### Lesson 10: Boundary discipline (when applicable)

**The pattern.** When the project has multiple architectural tiers (engine + vertical / shared + per-app / core + plugins / etc.), the boundary is *one-way*: lower layer never imports from upper. Enforced by hook (greppable import-path patterns).

**Why it matters.** Architectural boundaries drift silently. A *"just one quick import from `verticals/`"* in `engine/` is hard to revert later when more code depends on it. The hook closes the boundary at the moment the mistake is made — *the only time it's cheap to fix*. Once 3 files depend on the violation, fixing requires either reverting all 3 or accepting the boundary loss.

Two specific failure modes without the hook:
1. **Drift via tactical exceptions.** *"This one import is fine, it's just temporary."* Six months later there are 40 imports.
2. **Drift via PR-review-fatigue.** A reviewer notices the boundary violation but doesn't want to block the PR. The violation lands. Six months later there are 40 imports.

The hook makes both impossible — boundary violations don't pass the edit-time check, so they never reach review.

**Source-project example.** Vertical boundary closed 2026-04. `.claude/hooks/check-vertical-boundary.sh` blocks new `lib/verticals/<name>/ → lib/{engine-domains}` imports. `CLAUDE.md` says *"Engine never imports vertical types."* Before the hook: occasional violations slipped in during feature work. After the hook: zero violations land. The hook is now load-bearing — closing it would re-open a class of bug the project has paid to eliminate.

**Abstract / universal form.** Applicable when project has multiple architectural tiers + one-way dependency makes sense. Examples:
- **Engine + vertical** (the source project's case): `engine` never imports `verticals/`.
- **Library + app**: library files never import app-specific code.
- **Core + plugins**: core never imports plugin code; plugins import from core.
- **Domain + UI**: domain logic never imports UI components.
- **Backend + frontend** (monorepo): frontend imports from `shared/`, never from `backend/`.

NOT applicable when project is single-tier or when dependencies are intentionally bidirectional (rare — usually a code smell).

**Hook implementation pattern.** Greppable import paths are the precondition. If the boundary is *"frontend imports from `shared/` but not `backend/`,"* the hook greps imports in files under `frontend/` for the disallowed pattern `from ['"]@/backend` (or relative-path equivalent). Per-line override (`// allow-cross-tier: <reason>`) provides escape hatch.

**Maps to layer.** Layer 2.

---

### Lesson 11: Anonymization / privacy discipline

**The pattern.** When the project may ever be open-sourced, demoed publicly, or used in shared screenshots, ship an **anonymization guard**: a pre-push / CI script that greps tracked content for forbidden patterns (customer names, internal aliases, personal handles, API keys). Block push on hit.

**Why it matters.** Private context leaks publicly with frightening regularity. *"I'll remember to redact this"* fails ~30% of the time across a year of edits. The guard catches it 100% of the time. The catch happens *before* push, so the leak never reaches a public branch — recovery is *"git reset"* (cheap), not *"force-push history rewrite + worry about cached copies"* (expensive, sometimes impossible if the leak was scraped).

Privacy discipline has two scopes:
1. **Project-internal**: customer names, internal codenames, employee handles, third-party API keys checked into config.
2. **Cross-project**: when working with multiple projects, secrets from project A don't leak into project B's commits. (Easy to violate when you copy a snippet between projects.)

The anonymization guard handles scope 1. Scope 2 is harder — requires per-project secrets isolation in dev tooling.

**Source-project example.** N/A in source project (private repo, no anonymization needed). But dotclaude itself ships `scripts/check-anonymization.sh` — blocks the source project's own forbidden patterns from leaking into the public plugin code:

```bash
PATTERNS=(
  "<source-project-name>"
  "<assistant-character-name>"
  "<wedge-city>"
  "<specific-customer-1>"
  "<specific-customer-2>"
  "<personal-email-handle>"
)
```

CI mirror at `.github/workflows/anonymization-guard.yml`. Every push to `main` runs the guard; any hit fails the workflow. Manual pre-push wrapper at `.git/hooks/pre-push` (opt-in per developer).

**Abstract / universal form.** Every project that *may* go public. Pattern lists vary:
- **Customer names** (B2B SaaS, consulting projects).
- **Internal aliases / codenames** (large companies often have project codenames separate from public product names).
- **Employee names** (PII concerns).
- **API keys / tokens** (security concerns).
- **Internal URLs / hostnames** (staging URLs, internal admin tools).

The guard is cheap to set up (~30 min) and pays dividends every time someone almost-leaks something. The cost-benefit is asymmetric — the guard runs in milliseconds; one prevented leak saves hours or days of cleanup.

**Anti-pattern.** *Relying on `.gitignore` alone.* `.gitignore` prevents tracking of named files; it doesn't prevent leaks *inside* tracked files (a stray customer name in a code comment, a screenshot with a real email visible). The grep-based guard catches both.

**Maps to layer.** Layer 2 (constraint enforced by hook) + Layer 7 (drift detection — guard runs on every push, catches new leaks).

---

### Lesson 12: Maintenance ritual (Saturday or equivalent)

**The pattern.** A bounded recurring cadence (e.g. 30 min / week) that batches drift detection + design-debt review + skill audit. Decision interface: F/D/?/X marks. Registry as single canonical source. The ritual is *time-boxed* (not "audit when you feel like it" — that never happens consistently).

**Why it matters.** Without the ritual, drift accumulates invisibly. Three drift modes were named in Layer 7 (§2.7) — skill drift, doc drift, rule drift. Each is invisible per-session and toxic across sessions. The ritual is the *detection* mechanism. Without detection, even an opinionated CLAUDE.md becomes lies-the-codebase-tells-itself within ~6 months.

The 30-min-per-week budget is calibrated: long enough to surface real findings, short enough that it never feels like overhead worth skipping. The F/D/?/X decision interface is calibrated to minimize the user's per-finding cognitive load — *"fix now / defer / I need to think / won't fix"* is fast.

**Source-project example.** Saturday design-debt ritual:
1. **Friday night**: Claude runs the batch audit (token sweep + skill-vs-code consistency check + open-findings registry diff).
2. **Saturday morning**: Claude produces a batch sheet with all findings tabulated.
3. **User F/D/?/X marks**: 30 min over coffee, mark each row.
4. **Sunday onwards**: Claude implements F-marked items one at a time, one commit per item, lands during the week.
5. **Registry update**: `docs/design-debt/registry.md` reflects current state.

This loop has been running since ~2026-04. It catches drift that no single session would notice. `project_saturday_design_ritual` memory entry documents the loop's evolution.

**Abstract / universal form.** Every project > 3 months old benefits. Newer projects defer. Specific cadence varies — weekly may be too frequent for low-activity projects (biweekly or monthly works), too infrequent for high-activity ones (twice-weekly may be needed in heavy-iteration phases).

**Anti-pattern.** *Ritual without batch decision interface.* Without F/D/?/X marks, the user reads findings one at a time, each with a *"should I fix this?"* mental load — exhausting after 5 findings. The batch interface is what makes 30 findings feel like 30 minutes rather than 3 hours.

**Maps to layer.** Layer 7.

---

## 4. Plugin architecture (new command surface)

The v2 plugin ships **14 slash commands** organized by layer:

| Command | Layer | What it sets up |
|---|---|---|
| `/dotclaude:bootstrap` | meta | Full hierarchical interview — Layers 1–7 in one pass. The headline. |
| `/dotclaude:identity` | 1 | Just Layer 1 — `CLAUDE.md` identity section + `docs/product/vision.md` |
| `/dotclaude:architecture` | 2 | Just Layer 2 — `CLAUDE.md` architecture section + `docs/architecture/` + boundary rules + file-size hook |
| `/dotclaude:process` | 3 | Just Layer 3 — `CLAUDE.md` "How You Work" + DoD + cross-cutting rules + memory typing scaffold |
| `/dotclaude:quality-bar` | 4 | Just Layer 4 — `.claude/rules/<domain>-north-star.md` + quality-bar skill per domain |
| `/dotclaude:knowledge-graph` | 5 | Just Layer 5 — `docs/README.md` + `docs/` skeleton + authority hierarchy |
| `/dotclaude:design` | 6 | Layer 6 design kit (existing v1 — preserved) |
| `/dotclaude:coding` | 6 | Layer 6 coding kit (existing v1 — preserved) |
| `/dotclaude:planning` | 6 | Layer 6 planning kit (existing v1 — preserved) |
| `/dotclaude:testing` | 6 | Layer 6 testing kit (existing v1 — preserved) |
| `/dotclaude:data` | 6 | Layer 6 data kit (existing v1 — preserved) |
| `/dotclaude:ai-workflow` | 6 | Layer 6 ai-workflow kit (existing v1 — preserved) |
| `/dotclaude:maintenance` | 7 | Layer 7 — Saturday ritual + skill-auditor agent + drift hooks |
| `/dotclaude:audit-week` | 7 | User-invocable — runs the weekly maintenance batch |

### Why bootstrap is the headline

Bootstrap is the *meta-framework* command. It does what no other Claude Code plugin currently does: takes a project from zero or low-AI-infra state to a coherent `CLAUDE.md` + `docs/` + `.claude/` stack in a single guided session. The other 13 commands are *incremental enhancements* — useful when a project already has some layers but wants to add others. Bootstrap is the **demo-worthy** command: the user invokes it, ~30 min later (target — see §9 for caveats) their project has structured AI dev infrastructure.

The competitive positioning rests on bootstrap. *"dotclaude is the plugin that scaffolds your AI dev infrastructure from project context"* is a sentence no other plugin can claim. *"dotclaude is a design audit plugin"* is a sentence many plugins could approximate. The reframe trades easy positioning for hard positioning — but hard positioning is defensible.

The demo narrative is the test. A 90-second screencast showing:
1. Fresh `npm create vite@latest my-app` checkout.
2. `claude plugin install dotclaude@dotclaude`.
3. `/dotclaude:bootstrap` — voiceover narrates through Layer 1 → 7.
4. At end: `tree CLAUDE.md docs/ .claude/` showing the authored output.
5. Punchline: *"From empty to infrastructure-ready in <N> minutes. The plugin reads your project, walks 7 layers from identity to maintenance, authors a coherent stack."*

If this narrative is compelling, v2 has positioning. If it isn't, the positioning is weaker than v1's existing design-audit narrative — and v1 stays as-is.

### Why per-layer skills exist

Not every project is greenfield. A mature project may already have a `CLAUDE.md` but no `docs/` knowledge graph. A new project may want only the architecture layer and skip identity (because the user has identity-clarity but uncertainty on architecture shape). Per-layer skills allow incremental adoption.

Per-layer commands also serve as **diagnostic tools**. The user runs `/dotclaude:identity` on an existing project — Claude reads what's there and reports gaps (e.g. *"your `CLAUDE.md` doesn't name an ICP — propose: <X>"*). The user accepts / rejects / refines.

Concrete adoption scenarios bootstrap enables but per-layer commands fit:

- **Mature project, has CLAUDE.md, no docs/.** User runs `/dotclaude:knowledge-graph` only. Bootstrap would re-author Layers 1–4 the user already has; per-layer command surgically adds Layer 5.
- **New solo project, has ICP-clarity, no architecture decisions yet.** User runs `/dotclaude:identity` to commit the identity, then `/dotclaude:architecture` later when the layer model becomes clear.
- **Team adopting dotclaude on existing project.** Lead runs `/dotclaude:audit` (a synthesis of all per-layer commands in audit mode) — gets a gap report — fills gaps one layer at a time.
- **Project doing a strategy pivot.** User re-runs `/dotclaude:identity` only — updates vision / ICP / moat without disturbing Layers 2–7.

The per-layer surface is what makes v2 *adoptable*, not just *demonstrable*.

### Why domain kits stay

Layer 6 is the most-developed part of v1. ~85% smoke-test parity on a brownfield mature codebase is real evidence of working methodology. v2 *adds* to Layer 6 rather than refactoring it. The existing 7 domain skills remain — they're just enriched by upstream context from Layers 1–5 when bootstrap drives them.

This also means **v1 users have zero migration burden**. Their `/dotclaude:design` invocation works the same way in v2. The v2-only features (bootstrap, per-layer skills, maintenance) are additive.

### Why maintenance is a separate layer

Layer 7 has a different *cadence* than the others. Layers 1–6 are *authored once* and updated when state changes. Layer 7 is *recurring* — runs on a schedule, not on a state change. Separating it means the bootstrap interview can defer it (e.g. *"your project is < 1 month old, deferring Layer 7 until first audit cycle"*) without leaving a gap in the other layers.

It also means the **opt-in default** is configurable. For solo developers, Layer 7 may default to *off* (you don't need a ritual when you're the only dev). For teams, default *on* (drift is faster with more contributors). Bootstrap asks one Layer-7-specific question to set the default.

---

## 5. The bootstrap flow walkthrough

A narrative walkthrough as if you're a user invoking `/dotclaude:bootstrap` on a fresh project. Concrete, with quoted exchanges.

### Opening

**User**: `/dotclaude:bootstrap`

**Claude** (after a Phase-0 silent project scan — ~5–10 seconds reading `package.json`, top-level `ls`, any existing `CLAUDE.md` / `docs/` / `.claude/`):

> *I've scanned the project. Here's what I found:*
>
> *- Stack: Vite + React + TypeScript + Tailwind*
> *- Top-level: `src/` (15 files), `public/`, `package.json`, no `CLAUDE.md`, no `docs/`, no `.claude/`*
> *- Git history: 12 commits, mostly "feat:" prefixed*
> *- No tests yet, no DB, no AI calls visible*
>
> *Looks like a greenfield-ish web project ~2 weeks in.*
>
> *Bootstrap will walk through 7 layers. Each layer is 1–3 questions; ~20–30 min total. You can skip a layer at any point if it doesn't apply. At the end I stage everything to `.claude-staging/` + `docs-staging/` + `CLAUDE.md.draft`; you review before commit.*
>
> *Ready? Or want to scope down to a specific layer first?*

**User**: *Let's do the full thing.*

### Layer 1 — Identity

**Claude**:

> *Layer 1 — Project Identity. Three questions.*
>
> *1. One-paragraph product description: what is this, who's it for? (Or: paste a tagline you've already written.)*

**User**: *It's a habit tracker for software developers — like Streaks but with git-commit pull instead of manual taps. Wedge: side-project developers who feel they're "not shipping enough" and want frictionless tracking. Targeting consumer launch on Product Hunt.*

**Claude**:

> *Captured. Two follow-ups:*
>
> *2. What's the moat? What's hard for a competitor to replicate in 3 months?*
> *3. Production-vs-internal: this ships to external users (Product Hunt = yes), production.*

**User**: *Moat: I think the git-pull integration UX is novel — if you "ship" a commit it auto-credits the habit. Plus the per-repo correlation feature (does shipping on weekends correlate with weekday burnout). Stage: pre-launch, 2 weeks in.*

**Claude**:

> *Drafting `CLAUDE.md` identity section now. Show me before I move to Layer 2?*

[Claude shows a ~40-LOC `CLAUDE.md` draft section with the captured fields]

**User**: *Looks good — ship it.*

### Layer 2 — Architecture

**Claude**:

> *Layer 2 — Architecture. From the scan: single-tier React + Vite app, no backend yet. Three questions.*
>
> *1. Does this stay single-tier (frontend-only with eventual API via Vercel functions / similar), or are you planning a separate backend?*
> *2. Constraints: any non-negotiables yet? (e.g. file-size ceiling, theme-tokens-only, no inline styles, etc.)*
> *3. Should I ship the universal file-size hook (1000 LOC ceiling) by default?*

**User**: *Single-tier for now, will add Supabase later. Theme-tokens-only is a hard rule — already using Tailwind. File-size hook yes.*

**Claude**:

> *Drafting:*
> *- `CLAUDE.md` architecture section (single-tier; Tailwind theme tokens as constraint; file-size 1000 LOC; future Supabase tier marked deferred).*
> *- `.claude/hooks/check-file-size.sh` (universal).*
> *- `.claude/hooks/check-token-only.sh` (Tailwind-arbitrary-values pattern).*
> *- `.claude/rules/file-size.md`.*
>
> *Layer 2 staged. Move to Layer 3?*

### Layer 3 — Process

**Claude**:

> *Layer 3 — Process Discipline. Four sub-questions.*
>
> *1. Do you do plan-driven work? (Write specs / brainstorms before non-trivial features.)*
> *2. Do you do TDD / test-first?*
> *3. Solo vs team — solo so far?*
> *4. Default verification ladder — for this project I'd propose: visual screenshot (Playwright) → manual review → ship. Anything else?*

**User**: *Solo. Plan-driven for anything > 1 day of work. Not TDD strict. Verification ladder yes that's right.*

**Claude**:

> *Drafting:*
> *- `CLAUDE.md` "How You Work" section: solo workflow, plan-driven > 1 day, verification ladder for visual surfaces.*
> *- `CLAUDE.md` Task classification table (5 rows: UI feature / bug fix / API integration / data / plan-backed).*
> *- `CLAUDE.md` Definition of Done (8 items).*
> *- `.claude/rules/visual-verification.md` (Playwright screenshot pattern).*
>
> *Layer 3 staged. Layer 4?*

### Layer 4 — Quality Bar

**Claude**:

> *Layer 4 — Quality Bar. Three questions, the most important in the whole interview.*
>
> *1. Tier 1 chrome benchmarks — name 2–3 specific apps you grade chrome against. For a web app launching on Product Hunt, common picks: Linear, Stripe, Vercel, Notion, Things 3 web app.*
> *2. Tier 2 domain benchmarks with the specific dimension each is reference for. E.g. "Things 3 for empty states; WHOOP for data density."*
> *3. Anti-references — apps the design must NOT look like. E.g. "Bootstrap-y card stacks; consumer-bubbly tone; Notion's information density."*

**User**: *Tier 1: Linear and Stripe. Tier 2: Things 3 for empty states, Streaks for the daily-rhythm feel, GitHub's contribution graph for the data viz. Anti: Bootstrap-y, Notion-density, gamified-childish (no big celebration animations).*

**Claude**:

> *Drafting:*
> *- `.claude/rules/design-north-star.md` — Linear + Stripe as Tier 1; per-surface table (tab bar / cards / list rows / sheets / motion / color / typography); anti-patterns list.*
> *- `.claude/skills/quality-bar/SKILL.md` — S/A/B/C/D grades anchored to Linear; 5 composition pitfalls with anti-reference framing.*
>
> *Layer 4 staged. Layer 5?*

### Layer 5 — Knowledge Graph

**Claude**:

> *Layer 5 — Knowledge Graph. Two questions.*
>
> *1. Should I scaffold `docs/` from scratch? (Subdirectories: `brainstorms/`, `specs/`, `audits/`, `archive/{brainstorms,specs,audits}/`, plus `product/capabilities.md`.) Yes/no/customize.*
> *2. Should I author `docs/README.md` with the authority hierarchy + reading order + naming conventions? Yes/no.*

**User**: *Yes to both. Add `docs/flows/` too — I'll need that for the onboarding arc once we get there.*

**Claude**:

> *Drafting:*
> *- `docs/README.md` (entry point, reading order, authority hierarchy table, archive policy).*
> *- `docs/{brainstorms,specs,audits,flows,product,archive/{brainstorms,specs,audits}}/` with `.gitkeep`.*
> *- `docs/product/capabilities.md` (empty scaffold with the ID convention: `M.X` for member-side, no `O.X` since solo product).*
> *- CLAUDE.md "Where to find what" section pointing to docs structure.*
>
> *Layer 5 staged. Layer 6 — the domain kits. This is where the existing dotclaude commands kick in.*

### Layer 6 — Domain Kits (delegates to existing v1)

**Claude**:

> *Layer 6 — Domain applicability check.*
>
> *- ✅ design — you have `src/components/` and the project ships UI*
> *- ✅ coding — universal*
> *- ✅ planning — multi-file (`src/`, `public/`, scripts)*
> *- ❓ testing — no tests yet. Skip for now, revisit after first test?*
> *- ❌ data — no DB yet. Skip until you add Supabase.*
> *- ❌ ai-workflow — no AI calls. Skip.*
> *- ❌ native-bridge — web only. Skip.*
> *- ❌ pipeline-integrity — no pipelines. Skip.*
>
> *Confirm? I'll then run the design + coding + planning domain skills in sequence (each ~5–10 min). The design skill is the biggest — 5–6 questions.*

**User**: *Skip testing for now. Run the other three.*

[The design skill runs — interview ~5 questions, authoring ~9 artifacts to `.claude-staging/`. Coding ~3 questions, ~4 artifacts. Planning ~2 questions, ~3 artifacts. Total Layer 6 time: ~20 min for an engaged user.]

### Layer 7 — Maintenance

**Claude**:

> *Layer 7 — Maintenance. Two questions.*
>
> *1. Your project is 2 weeks old. Layer 7 (Saturday-style design-debt ritual) is usually deferred until first audit cycle surfaces > 5 open findings. Defer by default?*
> *2. Should I scaffold `.claude/_deferred/maintenance-ritual.md` so the artifact exists but is opt-in to enable later?*

**User**: *Defer, scaffold the opt-in stub. Add a TODO in CLAUDE.md so I remember in 2 months.*

**Claude**:

> *Drafting:*
> *- `.claude/_deferred/maintenance-ritual.md` (opt-in stub).*
> *- CLAUDE.md "Deferred work" section with the 2-month reminder.*
>
> *Layer 7 staged.*

### Final summary screen

**Claude**:

> *Bootstrap complete. Here's the inventory before commit.*
>
> *## CLAUDE.md sections drafted*
> *1. Identity (paragraph + ICP + moat + stage + pace)*
> *2. Architecture (single-tier; constraints; hooks list)*
> *3. How You Work (workflow + task classification + Definition of Done)*
> *4. Where to find what (pointers to docs/ + skills + rules)*
> *5. Deferred work (2-month reminder to enable Layer 7)*
>
> *Total: ~250 LOC*
>
> *## docs/ skeleton*
> *- `docs/README.md` (entry point — reading order + authority hierarchy)*
> *- `docs/product/capabilities.md` (scaffold)*
> *- `docs/{brainstorms,specs,audits,flows,archive/{...}}/`*
>
> *## .claude/ artifacts*
> *- agents: 4 (ux-reviewer, code-reviewer, pre-flight, design-token-auditor)*
> *- skills: 7 (design-system, quality-bar, journey-audit, element-reuse-check, persona-lens, decompose-file, pre-flight)*
> *- rules: 5 (design-north-star, audit-routing, visual-verification, file-size, frontend-components)*
> *- hooks: 3 (check-file-size, check-token-only, check-forbidden-phrases — phrase file empty for you to populate)*
>
> *## What got deferred*
> *- Layer 7 maintenance (2-week-old project, no debt yet)*
> *- testing domain (no tests yet)*
> *- data domain (no DB yet)*
> *- ai-workflow domain (no AI calls)*
>
> *Want to walk through 3 highlight artifacts before committing? Or commit-and-iterate?*

**User**: *Commit and iterate.*

[Claude moves `.claude-staging/` → `.claude/`, moves `docs-staging/` → `docs/`, moves `CLAUDE.md.draft` → `CLAUDE.md`, runs `git add . && git commit -m "feat(dotclaude): initial bootstrap (7 layers, design + coding + planning)"`.]

**Total user time**: ~25 minutes engaged + ~5 minutes of waiting for Claude to author. ~10 turn exchanges. The user walks away with a structured `.claude/` + `docs/` + `CLAUDE.md` they can iterate on, not from scratch.

### What the walkthrough shows about bootstrap's design

Five properties of the bootstrap flow worth naming explicitly:

1. **Phase 0 scan happens silently.** The first user-visible turn is *"Here's what I found, here's the plan."* Not a request for context. Claude already read `package.json`, `git log`, top-level `ls` before asking the user anything.

2. **Each layer has a STAGE checkpoint.** After Layer 1 drafts, Claude shows the draft → user approves → moves to Layer 2. The user is in control at every step. The full stack is only committed at the final summary.

3. **Skip is a first-class option.** Layer 7 was deferred. The design + coding + planning domains were applied, testing + data + ai-workflow + native-bridge + pipeline-integrity skipped. Skip is *explicit and justified*, not silent.

4. **Authored output is honest about what's there vs deferred.** The CLAUDE.md "Deferred work" section names Layer 7 explicitly. Future-user (or future-Claude) can see what was deliberately deferred vs what was forgotten.

5. **Compute waste is bounded.** Layers that don't apply don't fire their interview questions or author artifacts. A solo dev on a 2-week project doesn't get a 30-question Layer 7 ritual.

These properties are what differentiate bootstrap from a template-paster. Templates don't ask. Templates don't skip. Templates don't show what they're authoring before they ship it. Bootstrap is a *guided conversation*, not a template fire-and-forget.

---

## 6. v1 → v2 migration

### What stays (zero migration burden for existing users)

- **All 29 existing principles in `principles/`.** They underpin Layer 6 (most of them) + Layer 3 (`file-discipline.md`, `decomposition.md` apply at process discipline tier).
- **All 7 existing domain skills.** `skills/design/`, `skills/coding/`, `skills/planning/`, `skills/testing/`, `skills/data/`, `skills/ai-workflow/`, `skills/init/`. The contract is preserved.
- **All hook templates in `hook-templates/`.** They're consumed by Layer 2 (`check-file-size.sh` is universal) and Layer 6 (per-domain hooks like `check-design-tokens.sh`).
- **Showcase docs in `docs/showcase/`.** They demonstrate Layer 6 outputs on different project shapes.
- **War stories in `principles/war-stories/`** (if present). Anonymized debugging narratives — proof material referenced by Layer 6 audit agents.
- **Anonymization guard** (`scripts/check-anonymization.sh`). Universal, no change.

### What changes (low-risk shape adjustments)

- **`plugin.json` description.** Rewritten to lead with the meta-framework angle:
  > *"Hierarchical AI dev infrastructure framework for Claude Code. Reads your project, walks 7 layers from identity → domain tooling, authors a coherent CLAUDE.md + docs/ knowledge graph + .claude/ system. Headline: /dotclaude:bootstrap. Per-layer commands also available."*
- **`README.md` full rewrite.** Lead with the 7-layer hierarchy + bootstrap flow + demo gif of bootstrap. Layer 6 (current showpiece) moves to *"What's inside / Layer 6"* rather than the lead.
- **`skills/init/` rebadge.** Becomes `skills/bootstrap/` *or* `skills/init/` retained as alias. The skill's contents expand to cover Layers 1–7 (currently covers ~Layer 6 only).
- **Demo gif regenerated.** Current shows `/dotclaude:design` running. New shows `/dotclaude:bootstrap` running through Layers 1–7 (sped up).

### What's NEW

- **5–6 new principles in `principles/` upstream of Layer 6** — these become Stage 2 deliverables:
  - `project-identity.md` — Layer 1 methodology (vision / ICP / moat structure; what to ask; what to author).
  - `architecture-discipline.md` — Layer 2 (layer model + boundaries + constraint enforcement + the 4-tier cost ladder).
  - `plan-driven-work.md` — Layer 3, specifically the spec → plan → impl → conformance-matrix pattern.
  - `memory-system.md` — Layer 3, the user / feedback / project / reference typing + decay policies.
  - `task-classification.md` — Layer 3, the routing matrix pattern + when each row applies.
  - `maintenance-ritual.md` — Layer 7, Saturday-style ritual + drift detection + skill audit.
- **5–6 new per-layer skills** in `skills/`:
  - `skills/identity/SKILL.md`
  - `skills/architecture/SKILL.md`
  - `skills/process/SKILL.md`
  - `skills/quality-bar/SKILL.md`
  - `skills/knowledge-graph/SKILL.md`
  - `skills/maintenance/SKILL.md`
- **The bootstrap skill** at `skills/bootstrap/SKILL.md` — the meta-orchestrator. Runs Phase 0 scan → Layer 1 → Layer 2 → ... → Layer 7. Calls into the per-layer skills + the v1 domain skills.

### What's DEPRECATED (soft — kept for back-compat)

- **`skills/init/` standalone.** Becomes a thin redirect to `skills/bootstrap/`. Existing `/dotclaude:init` invocations continue to work, route to bootstrap with `--layer=6-only` flag (preserves current behavior).
- **The "design audit plugin" framing in the README.** Moved to a "Showcase" subsection rather than the lead. Not removed — many users may have linked to the showcase.

### Migration friction summary

For a v1 user: invoking `/dotclaude:design` in v2 behaves identically. Invoking `/dotclaude:init` in v2 routes to bootstrap with the Layer-6-only flag (matches current behavior). The user only sees the v2 surface when they invoke `/dotclaude:bootstrap` explicitly or read the updated README.

For a v2 user (greenfield install): they read the new README, invoke `/dotclaude:bootstrap`, get the full hierarchical experience.

Zero breaking changes. Strictly additive.

---

## 7. Smoke test plan

Two candidate test targets, both real.

### Target A — the source project (brownfield, ground truth available)

**Approach**: invoke `/dotclaude:bootstrap` on the source project. Bootstrap will detect existing `CLAUDE.md` + `docs/` + `.claude/` and offer two modes:

- **Mode 1 — audit mode (default)**: read existing layers, report gaps, propose deltas. Don't overwrite.
- **Mode 2 — fresh mode (opt-in)**: ignore existing state, author from scratch into `.claude-staging/`. Compare authored output to actual `.claude/` for parity.

Mode 2 is the rigorous test. Bootstrap should produce ~80% parity to the existing state (the source-project `.claude/` evolved over months; bootstrap producing it in ~30 min would be implausibly good, ~80% is realistic and meaningful).

**"Passing" criteria** for Target A:

- CLAUDE.md sections match the existing 6-section structure (identity / architecture / how-you-work / constraints / where-to-find-what / DoD) at ~70% content parity.
- `docs/` skeleton matches the existing structure at 100% (no missing top-level subdirectories).
- Layer 6 design kit matches v1's existing output (we already know this from the smoke test — ~85% parity).
- Layer 7 ritual: present in the authored output, matches existing Saturday-ritual shape at ~60% parity (memory-derived, harder to reproduce).

**Why Target A first**: ground truth available. Failure modes surface fast.

### Target B — fresh greenfield project (no ground truth, sanity check)

**Approach**: scaffold a fresh Vite + React project (`npm create vite@latest`). Invoke `/dotclaude:bootstrap`. Walk through all 7 layers as a real user. Capture the full transcript + the authored output. Use the output for a real workday (30–60 min) and report friction.

**"Passing" criteria** for Target B:

- Bootstrap completes in ≤ 35 min wall clock.
- All 7 layers produce *some* artifact (no layer entirely empty).
- The user (the developer or a recruited external contributor) can answer every question without external research.
- The authored `CLAUDE.md` reads like a *real* project guide, not a template.
- After 30–60 min of using the output: at least 3 specific moments where the authored stack helped (e.g. "design-token-auditor caught a stray hex"; "task classification routed me correctly"; "docs/brainstorms/<my-first-brainstorm>.md slot matched my intent").

### Recommended test order

1. **Target A Mode 1 (audit mode)** — ~30 min. Detects whether bootstrap correctly reads existing state. Low risk of breaking anything.
2. **Target A Mode 2 (fresh mode → staging)** — ~45 min. Compares authored output to ground truth. Highest information per minute.
3. **Target B (greenfield)** — ~60 min. Real-user friction surface.

Total smoke test time: ~2 hours. This is Stage 4 (~2h estimate).

### What we expect to find (predictions)

- **Layer 1 / identity will be the most under-tested.** v1's interview doesn't ask identity questions; bootstrap adds them. We don't have prior evidence the questions are well-calibrated. Likely failure mode: identity questions are too abstract for first-time users — *"what's your moat?"* requires sophistication some users don't yet have. Mitigation: provide examples per project type (B2C app moat examples, B2B SaaS moat examples, library moat examples).
- **Layer 7 / maintenance will produce a thin artifact on Target B.** Greenfield projects have nothing to maintain. The skill should detect this and ship the deferred-stub variant. Likely failure mode: the skill *forgets to detect* and ships a full ritual scaffold the user doesn't need yet.
- **Layer 6 will be at near-parity to v1.** This is the well-tested layer. The ~85% smoke-test parity from Target A Mode 2 is the prediction.
- **Layer 4 / quality bar will struggle on Target B.** The user has to name 2–3 specific benchmark apps; first-time users sometimes can't. Mitigation per §9.7: ship per-platform defaults the user can accept / refine.
- **Total time will exceed 30 min on Target B.** Predicted ~45 min for an engaged first-time user. We mention this in §9 as a known risk.

### Pre-smoke-test checklist

Before running smoke tests:

- [ ] All Stage 2 principles committed.
- [ ] All Stage 3 bootstrap + per-layer skills committed.
- [ ] `scripts/check-anonymization.sh` passes on current state.
- [ ] Target A clone available at `/tmp/smoke-source-project/`.
- [ ] Target B greenfield scaffolded at `/tmp/smoke-greenfield/`.
- [ ] Recording tool ready (asciinema or terminal recording for transcript capture).
- [ ] Time budget allocated (2.5h block, no other commitments).

### Post-smoke-test deliverables

After the smoke tests run:

- [ ] `docs/v2-smoke-test-<date>.md` written with all three runs documented.
- [ ] `docs/v2-bugs.md` with any bugs / improvements logged.
- [ ] `principles/*` or `skills/*` patches for any high-priority findings (defer low-pri to follow-up).
- [ ] Updated `docs/v2-vision.md` if the smoke test surfaces a vision-level issue (this doc may need amendments — that's OK).

---

## 8. Implementation roadmap (Stages 2–5)

This doc ships as **Stage 1**. The remaining stages execute against this doc.

### Stage 2 — Upstream principles (5–6 docs, ~3–4 hours)

**What gets written.** Six principles under `principles/` (the directory that already houses the 29 existing Layer 6 principles):

| File | LOC target | Purpose |
|---|---|---|
| `principles/project-identity.md` | 180–250 | Layer 1 methodology: what to ask, what to author. Anonymized template. Examples. |
| `principles/architecture-discipline.md` | 250–350 | Layer 2 methodology: layer model + boundaries + 4-tier cost ladder. |
| `principles/plan-driven-work.md` | 200–280 | Layer 3: spec → plan → impl → conformance matrix. |
| `principles/memory-system.md` | 150–220 | Layer 3: user/feedback/project/reference typing + decay. |
| `principles/task-classification.md` | 150–220 | Layer 3: the routing matrix pattern + per-row templates. |
| `principles/maintenance-ritual.md` | 200–280 | Layer 7: Saturday ritual + drift detection + skill audit. |

**Per-principle structure** (mirror existing `principles/quality-rubric.md` shape):
- Purpose paragraph.
- Universal methodology (cross-project pattern).
- Configuration knobs (project-specific values).
- Composition triggers (when applicable / when skip).
- Output shape (what gets authored).
- Anonymized template.
- 1–2 source-project examples (anonymized).

**Per-principle interview question budget.** Each principle will eventually be driven by per-layer interview questions. Question counts per principle (approximate):

| Principle | Approximate questions | Key knobs driven |
|---|---|---|
| `project-identity.md` | 4–5 | `PRODUCT_DESCRIPTION`, `WEDGE_ICP`, `MOAT_BULLETS`, `STAGE`, `PRODUCTION_OR_INTERNAL` |
| `architecture-discipline.md` | 4–6 | `LAYER_MODEL`, `BOUNDARY_LIST`, `CONSTRAINT_LIST`, `FILE_SIZE_CEILING`, `TYPE_GEN_EXEMPTIONS` |
| `plan-driven-work.md` | 2–3 | `PLAN_DRIVEN_THRESHOLD`, `CONFORMANCE_MATRIX_PATH_CONVENTION` |
| `memory-system.md` | 1–2 | `MEMORY_TYPING_ENABLED`, `MEMORY_INDEX_LOCATION` |
| `task-classification.md` | 3–5 | `TASK_TYPES`, `SPECIALIST_PER_TASK`, `AMBIGUOUS_PROTOCOL` |
| `maintenance-ritual.md` | 2–4 | `RITUAL_ENABLED`, `RITUAL_CADENCE`, `REGISTRY_PATH`, `DRIFT_DETECTION_SCOPE` |

Total: 16–25 questions across the 6 new principles, plus the existing Layer 6 interview question budget.

**Effort estimate.** ~30–45 min per principle × 6 = 3–4.5h.

**Dependencies.** None beyond this doc.

**Smoke test before moving on.** Spot-check: invoke `/dotclaude:design` (existing v1) after Stage 2 lands — does it still work? (Yes — Stage 2 is additive.) Read one principle aloud as if onboarding a new contributor — does it stand alone or require external context?

**Definition of done.** All 6 files committed. Each ≥ 150 LOC. Each cross-references at least 2 other principles or skills. `bash scripts/check-anonymization.sh` passes. Each principle has at least one anonymized template + at least one source-project example.

### Stage 3 — Bootstrap skill (~2–3 hours)

**What gets written.**

- `skills/bootstrap/SKILL.md` (target 400–600 LOC).
- `skills/bootstrap/interview-layer1.md` through `skills/bootstrap/interview-layer7.md` (per-layer interview scripts, ~80–150 LOC each).
- `skills/identity/SKILL.md` (~120 LOC — thin wrapper around the Layer 1 interview).
- `skills/architecture/SKILL.md`, `skills/process/SKILL.md`, `skills/quality-bar/SKILL.md`, `skills/knowledge-graph/SKILL.md`, `skills/maintenance/SKILL.md` (~120 LOC each).

**Bootstrap SKILL.md structure** (mirror `skills/init/SKILL.md` + extend):
- Phase 0 — project scan (Phase 1 of v1's init, expanded). Reads `README.md`, `package.json`/equivalent, top-level `ls`, existing `CLAUDE.md` / `docs/` / `.claude/`, `git log --oneline -30`, one representative source file per major module.
- Phase 1 — Layer 1 interview (delegates to `skills/identity/`). Outputs `CLAUDE.md.draft` identity section + `docs/product/vision.md`.
- Phase 2 — Layer 2 interview. Outputs `CLAUDE.md.draft` architecture section + boundary rules + universal file-size hook.
- Phase 3 — Layer 3 interview. Outputs `CLAUDE.md.draft` "How You Work" + DoD + cross-cutting rules.
- Phase 4 — Layer 4 interview. Outputs `.claude/rules/<domain>-north-star.md` + `quality-bar/SKILL.md`.
- Phase 5 — Layer 5 interview. Outputs `docs/README.md` + `docs/` skeleton + authority hierarchy.
- Phase 6 — Layer 6 applicability + delegation to v1 domain skills. Per-domain Phase 1–5 runs with Layers 1–5 context pre-loaded.
- Phase 7 — Layer 7 interview + deferral logic. Outputs maintenance artifacts under `.claude/` (active) or `.claude/_deferred/` (opt-in stub).
- Phase 8 — final summary + stage + present + commit. Moves `.claude-staging/` → `.claude/`, `docs-staging/` → `docs/`, `CLAUDE.md.draft` → `CLAUDE.md`. Commits with structured message.

**Bootstrap mode flags.**

- **Audit mode (default for brownfield)**: detect existing layers, report gaps, propose deltas. Don't overwrite.
- **Fresh mode (default for greenfield, opt-in for brownfield)**: author all 7 layers into staging. Overwrite confirmed by user.
- **Layer-6-only mode**: skip Layers 1–5 + 7. Reproduces v1's `/dotclaude:init` behavior. Routes from legacy invocation.
- **Lite mode** (proposed in §9.8): for small projects, ship Layers 1 + 2 + 6-coding + 7-deferred only.

**Effort estimate.** ~30 min per per-layer SKILL × 6 = 3h. Plus bootstrap itself ~30 min.

**Dependencies.** Stage 2 (the 6 upstream principles).

**Smoke test before moving on.** Dry-run bootstrap on a freshly-cloned source project (audit mode). Walk through all 7 layers without committing. Verify no infinite loops, no missing prompts, no obvious bugs.

**Definition of done.** Bootstrap completes a dry run on the source project. Per-layer skills can be invoked standalone (`/dotclaude:identity` works without bootstrap). Anonymization guard passes. Each per-layer skill has ≥ 100 LOC + interview script + cross-reference to its principle.

### Stage 4 — Smoke test (~2 hours)

**What gets executed.** The smoke test plan from §7. Two targets, three runs.

**Effort estimate.** ~30 min Target A Mode 1 + ~45 min Target A Mode 2 + ~60 min Target B + ~15 min writeup = ~2.5h. Round to 2h if we move fast.

**Dependencies.** Stages 2 + 3.

**Smoke test before moving on.** N/A — Stage 4 *is* the smoke test.

**Definition of done.** `docs/v2-smoke-test-<date>.md` written with all three runs documented. ≥ 70% parity on Target A Mode 2 (acceptable if not 85%; bootstrap is broader-scoped than v1). Target B runs to completion. List of bugs / improvements logged as `docs/v2-bugs.md` or as inline TODOs.

### Stage 5 — Reposition repo (~3–4 hours)

**What gets rewritten.**

- `README.md` — full rewrite leading with the 7-layer hierarchy + bootstrap. ~280 LOC current, target ~350.
- `.claude-plugin/plugin.json` — description rewritten.
- `.claude-plugin/marketplace.json` — if it exists, listing tags updated.
- `demo/demo.gif` — regenerated showing `/dotclaude:bootstrap`. ~15 second loop at 30fps.
- Showcase docs updated to reference Layer 6 framing (`docs/showcase/react-saas.md`, etc.).

**Effort estimate.** README rewrite ~90 min. Plugin metadata ~15 min. Demo gif recording + editing ~60 min. Showcase doc updates ~30 min. ~3h total.

**README rewrite structure** (target ~350 LOC):

1. **Hero**: tagline + animated demo (bootstrap flow, sped up).
2. **The 7 layers** in a single graphic (ASCII or SVG) — visual overview of the hierarchy.
3. **Two entry paths**: "Just want design audits?" → `/dotclaude:design`. "Want the full stack?" → `/dotclaude:bootstrap`.
4. **Slash commands table**: 14 commands organized by layer with one-line descriptions.
5. **What's authored** (per layer summary).
6. **See it in action**: 3 showcase links (existing showcase docs, updated for Layer 6 framing).
7. **Install** (unchanged from v1).
8. **Contribute** (extend to mention principles + skills + per-layer).
9. **License / footer** (unchanged).

**Demo gif requirements** (~15 seconds, looping):

- Frame 1–3 sec: terminal with `/dotclaude:bootstrap` typed, Enter pressed.
- Frame 4–8 sec: Phase 0 scan output (file tree, package.json, git log mentions).
- Frame 9–11 sec: Layer 1 question + user answer (sped up).
- Frame 12–14 sec: jump cut to final summary screen (authored CLAUDE.md + docs/ + .claude/).
- Frame 15 sec: hold on summary frame for 2 sec then loop.

Recording tool: Terminalizer or `agg` (asciinema → gif). Voiceover NOT in the gif; let the visual carry it.

**Dependencies.** Stage 4 (smoke test must inform README claims).

**Smoke test before moving on.** Read the new README out loud — does it make sense to someone who's never used dotclaude? Watch the demo gif — is it clear what bootstrap *does*? Run the install instructions on a fresh laptop or VM — do they work?

**Definition of done.** README + plugin.json + demo + showcase docs all committed. Anonymization guard passes. Public marketplace listing updated (if applicable).

### Stages timeline summary

| Stage | Effort | Cumulative |
|---|---|---|
| Stage 1 (this doc) | ~3h | 3h |
| Stage 2 (principles) | 3–4h | 6–7h |
| Stage 3 (bootstrap) | 2–3h | 8–10h |
| Stage 4 (smoke test) | ~2h | 10–12h |
| Stage 5 (reposition) | 3–4h | 13–16h |

A focused weekend of work, or 2–3 weeknight sessions.

### Parallel-track opportunity

Stages 2 and 3 have a clean dependency boundary. Stage 2 can be drafted in parallel with Stage 3 IF the principle bodies are stubbed-then-filled rather than fully-authored upfront:

1. **Phase 2A** — stub all 6 principles with table-of-contents + section headers + 1-paragraph purpose each. ~45 min.
2. **Phase 3** — write bootstrap + per-layer skills referencing the stubbed principles by section header. ~2.5h.
3. **Phase 2B** — fill in principle bodies fully. ~3h.

Risk: if Phase 3 surfaces a principle section that doesn't exist yet, mid-Phase-3 work blocks on Phase 2B. Mitigation: stubbed table-of-contents in Phase 2A is comprehensive enough that Phase 3 doesn't surprise.

Time saved by parallelism: ~1 hour. Not huge, but useful if calendar is constrained.

### Risk register per stage

| Stage | Risk | Mitigation |
|---|---|---|
| 2 | Principle bodies turn into restatements of source-project CLAUDE.md (too project-specific) | Anonymized template in each + 1 alternative project-type example |
| 3 | Bootstrap interview is too long (>40 min) | Time the dry-run; if >35 min, reduce question count |
| 3 | Per-layer skills duplicate logic with bootstrap | Bootstrap delegates explicitly to per-layer skills; no duplication |
| 4 | Source-project parity is below 70% | Acceptable if reason is identified + addressable in Stage 5 follow-up |
| 4 | Greenfield run takes > 60 min | Add lite-mode flag (per §9.8) |
| 5 | README rewrite buries the design audit narrative that v1 users love | Keep design audit prominent in "What's inside" subsection; lead with bootstrap but don't hide v1 |

---

## 9. Risks + decisions deferred

Twelve open questions. Each becomes a future RFC / decision point.

### 9.1 — Will bootstrap actually be ~30 min, or longer?

The §5 walkthrough assumes ~25–30 min user-engaged time. We don't have evidence. Predicted risk: real first-time users may take 45–60 min, especially at Layer 4 (benchmark naming is hard) and Layer 1 (identity articulation forces clarity that some founders haven't reached yet). **Mitigation**: time the smoke test on Target B (greenfield), report actuals, update README claims with measured numbers rather than predictions.

Specifically, the questions most likely to slow first-time users:
- *"What's your moat? What's hard for a competitor to replicate in 3 months?"* — sophistication-required, may need follow-up examples.
- *"Tier 1 chrome benchmarks — name 2–3 specific apps you grade chrome against."* — requires the user to have *thought about* what their reference is. Many haven't.
- *"Anti-references — apps the design must NOT look like."* — even harder; few users have negation-axis benchmarks.
- *"Task classification: which task types are most common in your project?"* — requires retrospective thinking about workflow patterns.

For each, ship a "I'm not sure — propose for me" branch that auto-fills with a defensible default the user can refine later. This converts "I'm blocked" into "let me confirm or revise" — much faster.

### 9.2 — How do we handle EXISTING `CLAUDE.md` / `docs/` / `.claude/`?

The §5 walkthrough assumed greenfield. Brownfield is the harder case. Options per artifact type:

- **Merge mode**: read existing, propose deltas, ask user to accept/reject per delta. Best for `CLAUDE.md` where the user has invested in opinionated content.
- **Refuse mode**: detect brownfield, recommend per-layer commands instead of bootstrap. Best for `.claude/` where artifacts can collide silently.
- **Append-only mode**: never modify existing, only add missing layers. Best for `docs/` where the user's docs are sacred.

Current preference: ship **merge mode** for `CLAUDE.md` (granular section-by-section diff), **append-only** for `docs/` (never delete a user's doc, only add missing subdirectories), **refuse mode** for `.claude/` (recommend per-domain commands).

The brownfield interactive flow:

1. Bootstrap detects existing infrastructure during Phase 0 scan.
2. Reports findings: *"You have `CLAUDE.md` (450 LOC, identity + architecture present; how-you-work missing). You have `docs/` with brainstorms but no `docs/README.md`. You have `.claude/agents/` with 3 agents."*
3. Offers three paths:
   - **(a) Audit mode**: read everything, produce gap report, no writes.
   - **(b) Selective bootstrap**: skip layers the user already has, only run missing layers.
   - **(c) Fresh-overwrite mode**: ignore existing, author all 7 layers into staging, user reviews the diff before committing.
4. User picks. Bootstrap proceeds accordingly.

Decide concretely in Stage 3.

### 9.3 — Saturday ritual: opt-in default-on or opt-out default-off?

Layer 7's ritual is *opinionated*. Defaulting it on for everyone feels prescriptive (a solo dev on a 2-week-old prototype doesn't want it). Defaulting it off means most projects never enable it (defaults are sticky).

Current preference: **default-off + scaffold the opt-in stub** so the artifact exists but is dormant. The 2-month / 5-finding reminder is a comment in `CLAUDE.md`.

The activation threshold could be smarter:
- **Auto-suggest activation** when `docs/design-debt/registry.md` (or equivalent) accumulates > 5 open findings.
- **Auto-suggest activation** when `.claude/skills/<X>/SKILL.md` files reach age > 60 days without `Last verified:` update.
- **Auto-suggest activation** when CLAUDE.md's "Constraints" section grows by 3+ items in 30 days (signal of mounting discipline that needs ritualized review).

These auto-suggestions land in CLAUDE.md as commented-out reminders that surface during the next bootstrap re-run or `/dotclaude:audit-week` invocation.

### 9.4 — How does memory typing map to non-Claude-Code AI tools?

Memory typing (`user / feedback / project / reference`) is Claude-Code-specific in implementation (memory dir under `~/.claude/projects/.../`). For Cursor / Continue / Aider, the implementation differs (Cursor has rules / context; Continue has slash commands + context items; Aider has read-only files). The *discipline* transfers; the implementation doesn't.

Current preference: stay Claude-Code-first in v2. If multi-tool support emerges as user demand, ship a v3 with abstracted memory backend. **Not a blocker for v2.**

### 9.5 — Should bootstrap require a git worktree?

Risk: bootstrap modifies `CLAUDE.md` + `docs/` + `.claude/` in the user's checkout. If the user has uncommitted work, those modifications interleave. Worktrees isolate; the source project's `feedback_subagent_worktree_cd_guard` memory documents pain from not isolating.

Current preference: detect uncommitted work, *warn* the user, offer worktree creation as opt-in. Default to in-place modification with the `.claude-staging/` + `docs-staging/` + `CLAUDE.md.draft` staging pattern (already standard).

### 9.6 — What's the relationship between bootstrap and the `feature-dev:feature-dev` skill?

Both walk through phases (bootstrap: 7 layers; feature-dev: 8 phases). One could imagine bootstrap subsuming feature-dev or vice versa. Current view: they're *orthogonal* — bootstrap authors infrastructure (`CLAUDE.md` + `docs/` + `.claude/`), feature-dev authors a feature inside that infrastructure. No conflict.

### 9.7 — Should Layer 4 (quality bar) ship a default per platform?

Layer 4 asks the user to name 2–3 Tier 1 benchmarks. First-time users sometimes can't. Should bootstrap ship a per-platform default the user can accept (e.g. "iOS web → Linear + Stripe + Apple HIG" by default)?

Current preference: **yes, with explicit confirmation**. The default is a *starting point*; the user can edit. Refusing to default forces every first-time user to do research mid-interview.

### 9.8 — Does bootstrap need a "lite mode" for small projects?

A 5-file CLI utility doesn't need 7 layers. Bootstrap may over-engineer for tiny projects.

Current preference: detect at Phase 0 — if project < 20 files + < 5 commits + no UI + solo, offer **lite mode** = Layers 1 + 2 + 6-coding + 7-deferred only. Skip 3 / 4 / 5 unless user opts in. Decide concretely in Stage 3.

Lite-mode specifics:

| Layer | Lite mode | Full mode |
|---|---|---|
| 1 — Identity | 2 questions (description + ICP) | 4–5 questions |
| 2 — Architecture | 2 questions (stack + 1 universal hook) | 4–6 questions |
| 3 — Process | Skipped (single-file ≈ no routing complexity) | 3–5 questions |
| 4 — Quality Bar | Skipped (no UI ≈ no benchmarks) | 3 questions |
| 5 — Knowledge Graph | Skipped (no docs needed yet) | 2 questions |
| 6 — Domain Kits | coding only (universal) | All applicable domains |
| 7 — Maintenance | Stub deferred | Configurable |

Total lite-mode interview: ~8 questions (vs ~25 full mode). Walltime: ~10 min (vs ~25 min).

Upgrade path: when the project grows past lite-mode thresholds, user runs `/dotclaude:bootstrap --promote-to-full` and bootstrap walks the previously-skipped layers.

### 9.9 — How do per-layer commands handle missing prior layers?

Example: user runs `/dotclaude:quality-bar` on a project with no `CLAUDE.md`. Quality bar depends on identity (what's the product?) and architecture (what platforms?). Two options:
- **Refuse mode**: *"Layer 4 requires Layers 1 + 2. Run bootstrap or those individual commands first."*
- **Ask mode**: ask the user the 2–3 questions normally answered by upstream layers, just in this session.

Current preference: **ask mode** — softer UX. The skill detects missing context, asks the bare-minimum questions to fill the gap, proceeds. Doesn't author upstream layers (that's bootstrap's job).

### 9.10 — Is the 12-lesson list complete?

We named 12. Are there more? Candidate omissions:

- **Engine tax**: every feature compounds moat or doesn't (source-project's `prototype-gates.md` rule). Currently embedded in Lesson 1 (CLAUDE.md content) but worth promoting if it generalizes.
- **Trace before propose**: when a bug is reported, read the path end-to-end before hypothesizing. Currently a `CLAUDE.md` directive in the source project.
- **Tooling discipline** (yarn-vs-npm, pip-vs-poetry, etc.): project-specific runtime tool choice. Currently a `CLAUDE.md` constraint.
- **Anonymization carry-through**: privacy at all boundaries (subagent prompts, screenshots, log captures). Currently part of Lesson 11.
- **Interaction-semantics 4Q docstring**: every new/redesigned UI screen carries a 4-question docstring resolving primary action / chrome-promise-vs-handler-does / etc. Currently embedded in Lesson 8 verification ladder.
- **Aim for best result, not smallest diff**: a behavioral default that overrides minimize-blast-radius. Currently a `CLAUDE.md` directive.
- **Hooks must not have ceiling**: enforcement hooks need escape hatches (override syntax). Currently embedded in Lesson 3.

Current preference: keep at 12 in v2. Add as principle docs in Layer 6 (where most belong) rather than promoting to top-level lessons. Re-audit at 6-month mark when we have more evidence of which lessons transfer broadly vs which are source-project-idiosyncratic.

### 9.11 — Should we ship a `dotclaude:audit-existing` command?

A read-only audit that reports gaps without writing. Useful for users who want to evaluate dotclaude before committing to bootstrap. Implementation: bootstrap Mode 1 (audit mode) wrapped as a standalone command.

Current preference: defer to post-Stage-5. Not a blocker for v2 launch.

### 9.12 — What about the existing `feature-dev:` / `superpowers:` plugins?

Cite their relationship to dotclaude in the README. They're complementary (feature-dev = per-feature workflow; superpowers = brainstorming / planning / TDD skills). dotclaude = infrastructure (one-time setup). Not competitive — show the composition.

Current preference: Stage 5 README explicitly says *"dotclaude composes with feature-dev and superpowers — dotclaude scaffolds the project, those skills drive day-to-day work inside it."*

---

## 10. Glossary

Key terms used throughout, defined for future-readers.

**4-tier cost ladder** — The hook < rule < skill < agent escalation by LLM cost. Catch at the cheapest tier. See Lesson 3 (§3).

**Anti-references** — Apps / designs the project must *not* look like. Named explicitly. Used in Layer 4 (quality bar). Without anti-references, design drifts toward generic defaults.

**Authority hierarchy** — In `docs/README.md`, the table mapping question shapes ("what's the canonical X?") to the canonical source doc. Resolves disputes when two docs claim authority.

**Bootstrap** — The headline v2 command. `/dotclaude:bootstrap` walks Layers 1–7 in one session. ~25–45 min user-engaged.

**Brownfield** — Project with existing `CLAUDE.md` / `docs/` / `.claude/`. Opposite of greenfield. Bootstrap handles via merge / append / refuse modes (§9.2).

**Capability map** — `docs/product/capabilities.md`. Stable-ID list of *what users can currently do*. Decouples *what* from *how* (which churns more).

**Conformance matrix** — `docs/audits/<plan-slug>-conformance.md`. Every § of a spec checked off as `matches | deviates(why) | deferred(why)` with screenshots. Plan-backed work is not "shipped" without one. See Lesson 4 (§3).

**Daily-driver surface** — A surface the user sees often (home, dashboard, inbox). Opposite of first-touch (onboarding, sign-up). Important distinction for copy / tone — first-touch language is wrong on daily-driver.

**Demo test** — The single concrete question that grades work. Source-project example: *"Would I demo this to a [recruited customer #2]?"* Customer-truth, not vibes.

**Depth checklist** — The 10-element list in `skills/design/SKILL.md` that every authored agent must pass. Named benchmarks / inspection dimensions / rubric / report sections / cross-refs / non-negotiable rules / project-specific anti-patterns / edge cases / calibration text / operational specifics.

**Domain kit** — A coherent set of `.claude/` artifacts for one quality / verification domain (design / coding / planning / testing / data / ai-workflow / native-bridge / pipeline-integrity). Layer 6 of the hierarchy. v1's main deliverable.

**Engine tax** — In multi-tier architectures, the discipline of asking *does this feature compound the moat / consume an engine primitive / add a new one + MCP tool?* Source-project specific but generalizes.

**External memory** — `docs/` as the project's indexed, persistent brain. Distinct from intra-session context (which evaporates at session end). See Lesson 2 (§3).

**Greenfield** — Project with no existing AI dev infrastructure. Bootstrap's primary intended use case.

**Hook** — Edit-time enforcement script. Runs via Claude Code's PostToolUse hook system. Cheapest tier of the 4-tier cost ladder. Greppable-pattern only.

**Hierarchical interview** — The bootstrap pattern: walk Layers 1 → 7 top-down, each layer's answers grounding the next. Distinct from flat interviews (all questions in one phase).

**Identity layer** — Layer 1. Vision / ICP / moat / production-vs-internal / solo-vs-team / maturity. Read by every downstream layer.

**Knob** — A configuration value the bootstrap interview captures. Total knob count: ~78 across all 7 layers (53 in Layer 6 design alone, per `docs/design-stack-analysis.md`).

**Knowledge graph** — Layer 5. `docs/` structured with conventions + reading order + authority hierarchy. See Lesson 2 (§3).

**Layer 6** — The domain-kit layer where v1 lives. Most-developed layer in v2.

**Memory typing** — The user / feedback / project / reference taxonomy applied to cross-conversation memory. See Lesson 6 (§3).

**Per-layer command** — `/dotclaude:identity`, `/dotclaude:architecture`, etc. Allow incremental adoption when a project doesn't want the full bootstrap.

**Plan-driven** — Workflow shape where non-trivial work goes spec → plan → impl → conformance matrix. Opposite of *vibes-driven* / *PR-as-plan*. See Lesson 4 (§3).

**Process discipline** — Layer 3. The *how* layer: plan-driven y/n, task classification, cost ladder, verification ladder, subagent dispatch, file size, memory typing.

**Quality bar** — Layer 4. Tier 1 + Tier 2 benchmarks, anti-references, demo test, per-domain rubrics. Without it, "S-tier" is meaningless.

**Saturday ritual** — The source-project's specific implementation of Layer 7. 30-min weekly batch audit + F/D/?/X decision interface + registry. See Lesson 12 (§3).

**Specialist routing** — In `CLAUDE.md`'s task classification table, the mapping from task types to specialist agent sequences. See Lesson 5 (§3).

**Subagent dispatch** — The pattern of spawning child Claude sessions for bounded sub-tasks. Three sub-patterns: fresh-per-task, two-stage review, cd-into-worktree gate. See Lesson 7 (§3).

**Tier 1 / Tier 2 benchmarks** — Layer 4 concept. Tier 1 = chrome reference apps (universal). Tier 2 = domain-specific reference apps with the *specific dimension* each is reference for.

**Verification ladder** — Per-domain ordered list of verifications from cheap → expensive. UI: screenshot → semantic audit → flow audit → conformance. See Lesson 8 (§3).

**Wedge ICP** — The *specific* initial customer segment a product targets first. Not the TAM, not the eventual market — the *first* customers the product is calibrated for. Layer 1 captures this. The wedge constrains feature priority.

**Worktree gate** — A safety pattern when dispatching implementer subagents into a git worktree. The dispatching prompt prefixes `cd $WORKTREE && pwd && git branch --show-current` plus a STOP/BLOCKED instruction if branch is `main`. Prevents subagents from committing to the wrong directory. See Lesson 7 (§3).

**Layer 1 / 2 / 3 / 4 / 5 / 6 / 7** — The seven layers of the v2 hierarchy: Identity / Architecture / Process Discipline / Quality Bar / Knowledge Graph / Domain Kits / Maintenance. Each authored sequentially by bootstrap.

**Lite mode** — Bootstrap variant for small projects that ships only Layers 1 + 2 + 6-coding + 7-deferred. See §9.8.

**Audit mode** — Bootstrap variant for brownfield projects that reads existing state, reports gaps, doesn't write. Default for brownfield.

**Fresh mode** — Bootstrap variant that authors all 7 layers from scratch into staging. Default for greenfield; opt-in for brownfield.

**Engine tax** — Discipline name from the source project: *"every feature either compounds the moat / consumes an engine primitive / adds a new one + MCP tool, OR is documented as vertical-only."* Forces feature decisions to consider engine compounding. Source-project specific in name, generalizes as *"every feature serves a strategic primitive or is explicitly scoped out."*

**Forbidden phrases** — A `.claude/rules/forbidden-phrases.txt` deny-list, one phrase per line, used by both `check-forbidden-phrases.sh` hook AND `persona-lens` skill. Voice / tone discipline. Override per-line: `// allow-forbidden: <reason>`.

**Override syntax** — Per-line escape hatch for enforcement hooks. The source project uses `// allow-<rule>: <reason>` (e.g. `// allow-color: <reason>` for color hooks, `// allow-large: <reason>` for size hooks). Makes hooks usable; without escape hatches, hooks become hated chokepoints.

**Phase 0 scan** — In bootstrap, the silent project-reading phase before any user question. Reads `README.md`, `package.json`, top-level `ls`, existing `CLAUDE.md` / `docs/` / `.claude/`, `git log`. Outputs a mental-model summary the rest of the interview adapts to.

**Showcase doc** — A point-in-time demonstration of dotclaude's output on a specific project shape. Lives in `docs/showcase/<project-type>.md`. Used as marketing material + as proof of cross-project transferability.

**Top-down vs bottom-up plugin** — Bottom-up plugins ship components (one hook, one slash command, one subagent). Top-down plugins ship coherent stacks derived from project context. Most Claude Code plugins are bottom-up; v2's positioning is top-down meta-framework.

**`.claude-staging/`** — Bootstrap's staging directory. Authored artifacts land here first; user reviews; moves to `.claude/` on approval. Prevents stomping on existing user state.

---

*End of v2 vision doc. Stages 2–5 execute against this. If a stage finds the doc ambiguous on its scope, the stage either (a) flags the ambiguity here for the next pass, or (b) makes the call locally and notes it in the stage's deliverable. Drift between this doc and shipped stages should be reconciled at Stage 5.*

---

## Appendix A — Quick reference card

For future readers who need the highlights without re-reading the full doc:

**The reframe in one sentence**: dotclaude v2 = AI dev infrastructure framework with v1's design plugin sitting as Layer 6 of a 7-layer hierarchy authored by `/dotclaude:bootstrap`.

**The 7 layers**: Identity / Architecture / Process / Quality Bar / Knowledge Graph / Domain Kits / Maintenance.

**The 12 lessons**: CLAUDE.md / external memory / 4-tier cost ladder / plan-driven + conformance / task classification / memory typing / subagent dispatch / verification ladder / file-size + decomposition / boundaries / anonymization / maintenance ritual.

**The 14 commands**: bootstrap + 6 per-layer + 6 domain kits + 1 weekly audit.

**The implementation roadmap**: Stage 1 (this doc) → Stage 2 (6 principles) → Stage 3 (bootstrap skill) → Stage 4 (smoke test) → Stage 5 (reposition repo). ~13–16h total.

**The biggest open risk**: bootstrap interview time. Predicted ~30 min, measured may be ~45 min. Mitigate via auto-suggest defaults + lite-mode for small projects.

**The biggest open decision**: how to handle brownfield projects with existing CLAUDE.md / docs / .claude. Current preference: merge mode for CLAUDE.md, append-only for docs, refuse for .claude with per-domain command recommendation.

**The non-negotiable**: anonymization guard must pass on every push. v2 is a public plugin; the source project is private. The guard is the only thing preventing source-project leakage.

---

## Appendix B — Cross-document map

For future contributors / future-Claude / AI tools — where does each concept actually live across the dotclaude repo:

| Concept | Lives in | Status |
|---|---|---|
| 7-layer hierarchy | This doc § 2 | Vision only — not yet implemented |
| 12 transferable lessons | This doc § 3 | Vision only — Stage 2 will write principles |
| Layer 6 design kit (the v1 contract) | `skills/design/` + `principles/*-audit.md` + `principles/quality-*.md` | Shipped (~85% smoke parity) |
| Layer 6 coding kit | `skills/coding/` + `principles/decomposition.md` + `principles/file-discipline.md` + `principles/code-review.md` | Shipped |
| Layer 6 planning kit | `skills/planning/` + `principles/pre-flight.md` + `principles/audit-routing.md` | Shipped |
| Layer 6 testing kit | `skills/testing/` + `principles/test-architect.md` | Shipped (lighter than design) |
| Layer 6 data kit | `skills/data/` + `principles/data-integrity.md` + `principles/database-query-discipline.md` + `principles/migration-create.md` | Shipped |
| Layer 6 ai-workflow kit | `skills/ai-workflow/` + `principles/ai-cost-monitoring.md` | Shipped (lightest) |
| 53-knob design analysis | `docs/design-stack-analysis.md` | Reference doc — feeds principle authoring |
| 78-knob greenfield expansion | `docs/design-greenfield-audit.md` | Reference doc — feeds principle authoring |
| Smoke test (~85% parity) | `docs/design-smoke-test-2026-05-20.md` | Validation evidence |
| Layer 1 / project-identity | (TBD Stage 2) | Not yet implemented |
| Layer 2 / architecture-discipline | (TBD Stage 2) | Not yet implemented |
| Layer 3 / process discipline | (TBD Stage 2) | Not yet implemented |
| Layer 4 / quality bar | (partial in `principles/quality-rubric.md`) | Cross-cuts Layer 6 currently |
| Layer 5 / knowledge graph | (TBD Stage 2) | Not yet implemented |
| Layer 7 / maintenance | (TBD Stage 2) | Not yet implemented |
| Bootstrap skill | (TBD Stage 3) | Not yet implemented |
| Per-layer skills (6) | (TBD Stage 3) | Not yet implemented |
| Anonymization guard | `scripts/check-anonymization.sh` + `.github/workflows/anonymization-guard.yml` | Shipped |
| Hook templates | `hook-templates/` | Shipped (universal subset) |
| Showcase docs | `docs/showcase/{react-saas,expo-mobile,cli-tool}.md` | Shipped |
| War stories | `principles/war-stories/*.md` (if present) | Shipped |
| Demo gif | `demo/demo.gif` | Shipped (will be regenerated in Stage 5) |

This appendix is a living index — update it as Stages 2–5 ship.

---

## Appendix C — Open questions for Stage 2 authors

When Stage 2 begins (writing the 6 upstream principles), the principle author will face these decisions. Resolve them concretely; this doc is intentionally undecided to preserve Stage 2's design space.

1. **Principle file naming.** Use the v1 convention (`<topic>.md` flat in `principles/`) or introduce a subdirectory for v2 upstream principles (e.g. `principles/v2-upstream/`)? Trade-off: flat is simpler, subdirectory separates layer-3+ from layer-6 concerns more cleanly.
2. **How much to lift directly from source-project artifacts.** The source-project `CLAUDE.md` is the gold standard. How much of its prose can the principles quote vs paraphrase? Anonymization permitting, longer quotes preserve nuance; shorter paraphrases generalize better.
3. **Worked examples per principle.** Each principle should have 1–2 source-project examples. Should there also be 1 example from a *different* project type to demonstrate transferability? Yes if the principle isn't obviously universal; no if it is.
4. **Principle interactions.** Some lessons compose: `plan-driven-work` consumes `task-classification` consumes `memory-system`. Should the composition graph be stated explicitly in each principle's "Composition" subsection? Yes — without it, principles become orphans.
5. **Tone alignment with existing 29 principles.** The existing `principles/*.md` have a specific tone — direct, declarative, command-like. The new 6 should match. Spot-check by reading 2–3 existing principles before drafting the new ones.

These resolve in Stage 2's planning sub-phase. Logged here so they're not re-discovered.

6. **Plugin manifest claims.** Should `plugin.json` description list every command, or just bootstrap + one example? Brevity wins on first read; completeness wins on second.

7. **Demo gif vs demo video.** A gif (small, autoplay) vs a video (richer, opt-in click). Trade-off: gif is README-embeddable, video is more compelling. Recommend gif primary + link to a 90-sec video for users who want more.
