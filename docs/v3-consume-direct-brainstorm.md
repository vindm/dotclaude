# dotclaude v3 — consume-direct (brainstorm + plan)

> **The reframe**: dotclaude moves from a **generator** (bootstrap authors a bespoke `.claude/` kit per project from teaching-material principles) to a **consumable base + thin generator** (projects enable the plugin and use ready-made universal artifacts as-is; the generator authors only what can't be shared as a file — project identity, architecture, stack/domain specifics).

**Status:** Brainstorm v1. Foundation for the v3 enhancement program.
**Authored:** 2026-06-14.
**Relationship to `v2-vision.md`:** v2 is shipped and entirely *generator-centric* (bootstrap authors; principles are teaching-material; §1.5 explicitly "not a code generator beyond `.claude/` skeleton"). v3 is **additive and new** — it introduces a distribution model v2 does not have. v2's bootstrap survives as the thin generator; v2's principles get *re-classified*, not discarded.

---

## 0. TL;DR

dotclaude today is write-only: its principles teach the generator how to author a kit, but nothing dotclaude ships ever *runs* in a real project — so the generalized form is never exercised, and the manual "catch-up" (re-auditing the source project against the framework) is hand-cranked.

v3 fixes this by shipping a **directly-consumable base layer** (universal rules / skills / agents / hooks) that any project enables as a plugin and uses as-is. The generator shrinks to only the un-shareable. Knowledge flows: a lesson proves itself in a real project's local `.claude/` → gets distilled into the consumable base → flows back to every consumer. The base is now *dogfooded* (it runs), single-source-of-truth, and improvable for all consumers at once.

**Four decisions locked (2026-06-14):**
1. **Model** — consume-direct. Ship ready files; generator only for the un-shareable.
2. **Split** — **balanced**. Base = project-agnostic universals (operating-principles, process rules, generic agents, all universal hooks). Generator = identity (vision / moat / ICP) + anything referencing project-specifics (paths, stack, domain).
3. **Mechanics** — verified against Claude Code plugin docs (see §3). The model is feasible; one constraint reshapes it (CLAUDE.md can't ship from a plugin → always-on universals become path-less rules).
4. **Sequencing** — **incremental**. Ship the consumable base alongside the working v2 generator; prove on one vertical slice (the process-discipline module) including a real dogfood; then expand. v2 never breaks during the transition.

---

## 1. The two distribution models

| | Generator (v2, shipped) | Consume-base (v3) |
|---|---|---|
| What a project gets | a bespoke kit authored from principles | the universal base as-is + a generated identity layer |
| Dogfooding | zero — principles are teaching-material, they never run | yes — the shared base runs in every consumer |
| Source of truth | drifts (generated kit diverges from principles) | single (fix the base → fixed for all consumers) |
| Cost of a fix | re-run bootstrap per project; old kits rot | edit base once; consumers pick it up |
| Downside | write-only loop, no shared improvement | version coupling; the base MUST be excellent as-is |

The balanced split is what makes the downside manageable: the base is **only** the things that don't need per-project customization, so the common case needs no override. Project-specifics live in the generated local layer, separate from the base.

---

## 2. v3 architecture (balanced, by artifact type)

- **Always-on universal methodology** → plugin **path-less rules** (rules with no `paths:` frontmatter load by default). This is the `operating-principles` + cross-cutting invariants (grill-before-plan, lean-by-default, parallel-paths, subagent-orchestration, knowledge-layers, plan-driven-work, verification ladder).
- **Path-scoped universal gotchas + domain kits** → plugin path-scoped rules / skills / agents (auto-load on the *consuming* project's matching file paths). The current 40 `principles/` that are genuinely universal become **real consumable artifacts here**, not teaching-material.
- **Universal hooks** (file-size, git-safety, secret-leak, no-console-log) → plugin hooks; they fire in every consumer additively.
- **Project-specific** (identity, moat, architecture, quality-bar benchmarks, stack gotchas, project-coupled hooks like token-needs-theme-path or boundary-needs-layers) → authored by the **thin bootstrap** into the project's **local** `CLAUDE.md` + `.claude/`.
- **Override** → a project shadows a base artifact by defining a same-named local one (rare, deliberate). There is no granular per-artifact disable, so the base must be designed override-free for the common case.

### The core transformation

Today's `principles/` (40 files of teaching-material) splits in two:
1. **Genuinely universal** → converted into consumable plugin artifacts (the base). The form changes: a consumable rule says *"grill before you plan"* directly, not *"when you bootstrap, author a grill-before-plan rule."*
2. **Teaches how to author project-specifics** → stays as teaching-material for the thin bootstrap (identity, architecture, quality-bar interview, etc.).

This classification is the first real work item.

---

## 3. Plugin mechanics — verified constraints (load-bearing)

> **⚠️ CORRECTION (2026-06-14, supersedes the table below).** A second, more rigorous docs check (citing the plugin **File locations reference** table) found that **rules are NOT a plugin-distributable artifact type.** Plugins expose only: `skills/`, `commands/`, `agents/`, `hooks/hooks.json`, `mcpServers`, `lspServers`, `monitors/`, `output-styles/`, `themes/`. **There is no `rules/` exposure and no manifest key for it** — rules are project-local only. The earlier "rules coexist / path-less rules are the always-on channel" claim (table below) was based on a first agent answer that conflated project-local rule loading with plugin-provided; it is **wrong**.
>
> **Implication:** the "always-on universal methodology → plugin path-less rules" mechanism in §2/§4 is invalid. The CONTENT (the converted consumable rules) stands; the DELIVERY changes.
>
> **Confirmed directly against the official docs** (`plugins-reference.md`, fetched 2026-06-14): the plugin component types are skills / agents / hooks / MCP / LSP / monitors / themes — no rules. And line 793, verbatim: *"A `CLAUDE.md` file at the plugin root is not loaded as project context. Plugins contribute context through skills, agents, and hooks rather than CLAUDE.md. **To ship instructions that load into Claude's context, put them in a skill.**"* So the official channel for plugin-shipped guidance is a **skill**, not a rule, not a hook. `base/rules/*.md` become the *content* of one or more consumable **skills**.
>
> **The always-on caveat (refines the balanced split).** A skill loads "automatically based on task context" — **soft** always-on (model judgment), not the **hard** every-session guarantee a project-local path-less rule / CLAUDE.md gives. Consequence:
> - **Path-scoped gotchas + domain + hooks** → ship cleanly as plugin skills (with `paths:`) / agents / hooks. consume-direct works here as designed.
> - **Hard-always-on methodology** (operating-principles, lean, parallel-paths, subagent-orchestration) → the platform gives a plugin only *soft* always-on (a broadly-scoped skill). For hard always-on, that slice must be authored into the consuming project's **local CLAUDE.md by the generator**. So this slice stays partly generator-model; the consume-direct win is strongest for path-scoped / domain / hooks.

Original (partially superseded — see correction above):

| Artifact | Plugin + project-local coexist? | Same-name precedence | Per-artifact disable? | Path-scoped auto-load in consumer? |
|---|---|---|---|---|
| Rules (path-scoped) | Yes, both load | both load (no name collision by default) | No | ✅ Yes |
| Rules (no `paths:`) | **Load by default** — the always-on channel | — | No | n/a |
| Skills | Yes (namespaced `plugin:skill`) | project-local overrides same-name | No (shadow only) | ✅ Yes |
| Agents | Yes | project-local overrides same-name | No (shadow only) | n/a |
| Hooks | Yes, **both fire** | merge by scope order, both run | No (disable whole plugin) | n/a |
| **CLAUDE.md** | **plugin CLAUDE.md is NOT loaded** | n/a | n/a | n/a |

**The CLAUDE.md constraint is the design-shaping one.** A plugin cannot ship always-loaded `CLAUDE.md` context. So the universal "How You Work" methodology cannot be CLAUDE.md — it ships as **path-less rules** (which do load by default). Consequence: a consuming project's local `CLAUDE.md` shrinks to **identity + project-specifics**; the bulk of "how to work" comes from the plugin's path-less rules. This is exactly the balanced split, enforced by the platform.

**Override implication.** Because there's no granular disable, the base must be safe-as-is everywhere. Anything that would need per-project tuning (a hook that assumes a theme path, a rule that names project layers) does NOT go in the base — it's generated locally. This is already the balanced split; the mechanics confirm it's the only workable line.

---

## 4. Incremental plan

### Phase 0 — Proof slice: the process-discipline module (+ real dogfood)

The smallest end-to-end proof of the whole v3 loop. Chosen because the process layer is the most universal, its source material was just battle-tested and consolidated in a real project's `.claude/`, and it exercises the hardest mechanic (always-on via path-less rules).

1. **Classify** the process-layer principles (operating-principles, lean-by-default, plan-driven-work, task-classification, knowledge-layers, memory-system, handoff, subagent-orchestration, parallel-paths) → always-on (path-less rule) vs path-scoped vs teaching-material.
2. **Convert** the always-on universals from teaching-material form into **direct consumable form** as plugin path-less rules (imperative "do this," not "author a rule that says this"). Anonymized.
3. **Ship** them as a plugin module alongside the existing v2 generator (additive — v2 untouched).
4. **Dogfood**: a real source project enables the plugin, the process rules load, and that project **sheds its now-duplicated local copies** (its `CLAUDE.md` "How You Work" shrinks to identity; the universal rules come from the plugin). This is the proof: the base runs, the duplication resolves, the loop closes on one slice.
5. **Verify**: confirm path-less rules actually load in the consumer, no conflict with the local thin CLAUDE.md, hooks fire additively.

**Exit criterion:** a real project runs on the plugin's process base instead of its own local universals, with no regression.

### Phase 1 — Expand the base (after the proof validates)

Repeat the Phase-0 pattern per remaining universal cluster: domain kits (the existing v2 design/coding/testing/data agents → consumable), universal hooks, the quality-bar rubric, knowledge-graph conventions. Each cluster ships as a consumable module, validated by the same dogfood.

### Phase 2 — `/distill` pipeline

Systematize what Phase 0–1 did by hand: a tool that takes a proven local `.claude/` (and memory), classifies durable-universal vs project-specific, generalizes + anonymizes the universal slice, and lands it as consumable base artifacts (running the anonymization guard). This is the repeatable engine that keeps the base fed from real projects without a manual re-audit.

### Phase 3 — Shrink bootstrap to the thin generator

Once the base exists and is consumed, bootstrap stops re-authoring universals. Its new job: (a) "enable the dotclaude plugin," then (b) author only the un-shareable identity/architecture/quality-bar/stack layer into the local `.claude/` + thin `CLAUDE.md`, plus any deliberate overrides. v2's interview shrinks accordingly.

---

## 5. Open questions / risks

- **Version coupling.** A consuming project now depends on the plugin version. Need a story for: pinning, breaking changes to a base rule, and how a consumer reacts when the base updates under it. (Mitigant: base = universals that rarely change; semver discipline.)
- **The base must be excellent as-is.** No per-project tuning means a mediocre base hurts every consumer. Raises the quality bar for promoting anything into the base — the `/distill` gate must be strict ("proven in ≥1 real project, genuinely universal, override-free").
- **Discovery of path-less rules.** Confirm in practice that a plugin's path-less rules reliably enter context every session in a consumer (docs say rules with no `paths:` load by default — validate on the Phase-0 slice before scaling).
- **Two-entry-path positioning (from v2-vision §1.6) still holds** — "just want X kit" (generator) vs "consume the base" (plugin enable). v3 adds the second path without removing the first.
- **Bootstrap ↔ base handoff.** The thin bootstrap must reference base artifacts rather than re-author them; define how the generated local layer points at / extends the consumed base.

---

## 6. Progress + next action

**Done (2026-06-14):** the always-on process quartet (operating-principles, lean-by-default, parallel-paths, subagent-orchestration) is converted from teaching-material into direct consumable form and landed as a single skill — `skills/operating-discipline/SKILL.md` — with a broad description for soft-always-on loading. Auto-discovered by the plugin (root `skills/`); no manifest change needed. The conversion pattern (teaching → imperative; project-specifics deferred to the local layer) is proven; `parallel-paths` and `subagent-orchestration` were net-new distillations from a real project's battle-tested rules. (The exploratory `base/` directory was removed — the platform exposes consumable artifacts only at root `skills/` / `agents/` / `hooks/`, so there is no separate "base" location.)

**Phase 1 — universal hooks slice DONE (2026-06-14):** `hooks/hooks.json` registers the 5 zero-config, universally-safe guards (`check-git-safety` PreToolUse·Bash, `check-secret-leak` + `check-file-size` PostToolUse·Write|Edit, `git-context-sessionstart` SessionStart, `warn-uncommitted-on-clear` SessionEnd), scripts referenced via `${CLAUDE_PLUGIN_ROOT}/hook-templates/`. They fire additively in every consumer — this is the purest consume-direct win (platform fully supports plugin hooks; no always-on caveat, no override needed). Config-needing templates (design-tokens, import-boundary, forbidden-phrases, console-log, todo, prebuild, regen, auto-lint, bash-safety) stay generator-authored — they need project config. Classification + notes in `hooks/README.md`.

**Phase 1 — universal agents batch DONE (2026-06-14):** 7 consumable agents in `agents/` — `code-review` (exemplar) + `pre-flight`, `test-architect` (Write/Edit, implements tests), `skill-vs-code-audit`, `data-integrity` (DB access discovered at runtime — no MCP dependency), `product-direction-validator` (Write/Edit, updates docs) — plus the `decomposition` skill. All default `model: sonnet` (shadow with opus for rigor), read-only auditors carry no Write/Edit. The agent-conversion pattern: teaching → system-prompt; project-specifics (anti-patterns, schema, invariants, layers) **derived at runtime** by the agent reading the consuming project's git log / code / docs, not hardcoded — strictly better than a generator snapshot (no rot).

**Next action — the dogfood validation (cannot be fully verified from an authoring session):** install/enable the plugin in a real consuming project and confirm (a) the `operating-discipline` skill loads on substantive work (soft always-on), (b) the 5 hooks fire (`jq` must be on PATH), (c) the agents are dispatchable as `dotclaude:<name>`. If soft-always-on proves unreliable for the methodology layer, fall back to the hybrid (generator writes a one-line pointer into the consuming project's local `CLAUDE.md`).

**Phase 1 — UI-universal family DONE (2026-06-14):** 8 UI agents (`a11y-audit`, `ux-audit`, `interaction-audit`, `flow-audit` [Write], `flow-continuity-review`, `pages-audit`, `design-token-audit` [haiku], `product-designer` [Write]) + 4 UI skills (`journey-mapping`, `persona-testing`, `element-reuse`, `iterative-polish-autoloop`). All grade against the consuming project's quality-bar / design-north-star **read at runtime** — no hardcoded benchmark apps; fall back to platform-native and say so when none exists. Visual auditors use whatever capture method the project provides or caller-supplied screenshots (tools `Read/Grep/Glob/Bash` only — no assumed simulator).

**Plugin surface now: 14 agents · 14 skills · 5 hooks.** Authored across 4 delegated subagent batches, each verified (files exist · anonymization clean · frontmatter valid · spot-read).

**Phase 1 — process/knowledge skills tail DONE (2026-06-14):** 7 consumable skills — `authoring-skills`, `handoff`, `plan-driven-work`, `knowledge-layers`, `memory-system`, `migration-create` (discovers the project's migration tool at runtime), `saturday-ritual` (marked optional). **Stays generator-authored** (project-specific by nature): `project-identity`, `task-classification`, `audit-routing`, `ai-cost-monitoring`, `design-benchmarking`, `design-system-reference-skill`, `knowledge-graph`.

### Phase 1 COMPLETE — the consume-direct base is built

**Final surface: 14 agents · 21 skills (13 new consumable + 8 generator interview skills) · 5 hooks.** Every consumable artifact: project-agnostic, anonymized (CI-guard clean), and self-adapting (project specifics derived at runtime, not snapshot-baked). Authored across 6 delegated subagent batches, each verified per the subagent-orchestration discipline (files exist · anonymization clean · frontmatter valid · spot-read).

**Phase 2 — `/distill` DONE (2026-06-14):** the extraction pipeline this effort ran by hand is now a skill — but it lives in the **source project**, not here. Distillation is the source's responsibility (knowledge flows source → framework); `/distill` reads the source's `.claude/` + memory and lands the universal slice into this plugin's base. It is NOT a dotclaude consumable artifact (a maintainer tool would only pollute every consumer), so it does not ship in dotclaude. The pipeline it encodes: promotion gate (proven + universal + override-free) → inventory/classify (universal vs stack vs project) → gap-vs-base → convert (platform constraints baked in: rules not pluggable → methodology is a skill; runtime-derivation not snapshot; auditor → read-only agent; zero-config guard → hook) → anonymize + guard + verify-don't-trust-rollup → report. Future catch-up is `/distill` from the source instead of a manual audit.

**Phase 3 — thin bootstrap DONE (2026-06-14):** `skills/bootstrap/SKILL.md` rewritten 673 → 92 lines and `interview.md` trimmed 553 → 379 (phases A/B/D/E only). Bootstrap no longer re-authors the universal base — Phase 0 enables the plugin (which provides `operating-discipline`, the auditor agents, the universal hooks, the process/knowledge skills, the ritual), and bootstrap authors ONLY the un-shareable project layer: identity, architecture + `dotclaude.yml` config + project boundary hooks, the named quality-bar benchmarks, the knowledge graph + the project's task-classification routing table + DoD, and a **thin local `CLAUDE.md`** that points at the consumed `operating-discipline` skill (the hard-always-on hybrid) instead of restating ~250 lines of methodology. Process / domain / maintenance are consumed, not interviewed.

### The v3 authoring program (Phases 0–3) is COMPLETE.

**Dogfood — round 1 (2026-06-14):**
- ✅ **file-size hook bug caught + fixed.** The `check-file-size` template shipped into the base hooks with unsubstituted `{{fileSize.ceiling}}` placeholders → bash error → silent no-op (an oversized file passed). Hardcoded ceiling 1000; re-tested (1500→block, 10→pass). The `{{}}`-substitution model is for *generator* templates, not *consumed* base hooks — base hooks must be runnable as-is.
- ✅ **git-safety hook works live** (it blocked a force-push command in the running session).
- ⚠️ **Distribution finding (load-bearing for the v3 dev loop).** Enabling the marketplace plugin loads the **cached** copy (`~/.claude/plugins/cache/`), sourced from **GitHub** (`vindm/dotclaude`). The cache was a stale **1.0.0** (Skills 7, Agents 0, Hooks 0) — none of the committed-but-**unpushed** v3 work. So **"enable the plugin" ≠ "run local dev work."** To dogfood un-pushed v3 either: (a) `claude --plugin-dir <repo>` (loads the working dir in-place, session-scoped — the local-dev loop), or (b) push to GitHub → `claude plugin marketplace update dotclaude` → reinstall. A headless `--plugin-dir -p` skill-list probe was inconclusive (a `-p` model can't reliably enumerate its own skill registry) — skill-load is best confirmed by a human in an interactive `--plugin-dir` session.

**Dogfood — round 2: VALIDATED (2026-06-14).** A consuming project ran the actual v3 via `claude --plugin-dir <repo>`. Confirmed live: all **14 agents** dispatchable as `dotclaude:<name>`; **`dotclaude:operating-discipline`** + all 13 consumable skills loaded with the `dotclaude:` namespace; **`dotclaude:bootstrap`** is the thin v3 version (description = "consume-direct way… author ONLY the un-shareable project-specific layer"). Namespacing is clean: plugin skills are `dotclaude:<name>`, so they coexist with a consumer's same-named local skills (e.g. a local `handoff` and `dotclaude:handoff` both present, no collision) — the redundancy is the "shed local dupes" opportunity, not a bug. **The consume-direct model is proven end-to-end: the base is consumed as-is from the plugin; the thin generator is in place.**

**Still open:**
- **Real distribution** — `--plugin-dir` is the local-dev loop; for consumers to install from the marketplace, push v3 to GitHub (`vindm/dotclaude`) so `claude plugin marketplace update` + reinstall pulls it (the cache is still 1.0.0 until then).
- **Consumer adoption is maturity-graduated, NOT a blanket shed** (corrected 2026-06-14). A mature *source* project is a **lab + producer**, not a consumer of its own canon — stripping it to consume a frozen base kills the surface where lessons actually evolve. And many of its "dupes" aren't dupes: they're **tuned, project-specific** versions that beat the generic base *for that project* (a local `code-review` that knows the stack vs the generic one that derives it at runtime). So per artifact, on the axis **maturity × tuning**: shed only **stable + generic + untuned** (e.g. `git-safety` / `secret-leak` hooks, `decomposition`); **keep + evolve locally** everything tuned or still-evolving (design agents, the calibrated operating principles, fresh disciplines). A lesson graduates frontier→canon via `/distill` when it stabilizes; to re-evolve canon, **shadow** it with a same-named local (Claude Code: local overrides plugin), mutate in the lab, re-distill up. The generic base serves **greenfield / un-tuned** consumers; consume-back becomes valuable only once **multiple** sources feed the base (then a project pulls others' improvements). For now the source project keeps its tuned locals and the plugin stays disabled there — it's the producer.
- **`principles/` cleanup** — the 28 retire-candidates now that the base is proven (see `principles/README.md`).
- **`principles/` cleanup:** the teaching-material principles whose universal content now ships as consumable artifacts are partly redundant. Decide per principle: keep as bootstrap's input for the *project-specific* layers it still authors (project-identity, architecture, quality-rubric, knowledge-graph, task-classification, design-benchmarking — bootstrap still reads these), vs. retire the ones whose entire content became a consumable artifact (operating-principles, lean-by-default, the auditor principles, the process/knowledge ones). A `/distill`-style audit decides.

**Then:** build `/distill` (Phase 2) and shrink bootstrap to the thin generator (Phase 3).
