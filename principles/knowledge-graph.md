# knowledge-graph — designing `docs/` as external memory for ANY project

Teaching material for Claude Code. When you bootstrap a project's AI dev infrastructure, this doc teaches you HOW to scaffold a `docs/` directory that acts as the project's *external memory*: an indexed, persistent, navigable brain that survives across sessions and contributors. Layer 5 of the v2 hierarchy.

## When to ship one (applicability gate)

Ship a `docs/` knowledge graph when:

- The project will live > 1 month and accumulate decisions worth referencing later.
- The project has had at least one *"didn't we already discuss this?"* moment. That's the symptom of missing external memory.
- The project's design decisions, strategic shifts, or audit reports have value beyond the conversation that produced them.
- More than one Claude session will work on the project. The graph is how session N references decisions made in session M.

Skip when:

- The project is < 2 weeks old AND the user has no decisions yet to externalize. Scaffold an empty `docs/README.md` so the convention exists; defer the subdirectories until there's content.
- The project is a single-script utility — no decisions, no audits, no architectural choices to record.
- The project is a research notebook where the README + the notebook IS the documentation.

The default bias is **ship**, even minimally. A 30-LOC `docs/README.md` + empty subdirectories costs almost nothing and pays compounding returns as the project ages. Projects without external memory pay re-derivation tax every session forever; projects with it pay the cost once.

## Why it matters — what this catches that nothing else does

Without external memory, three failure modes recur:

- **Brainstorm amnesia.** *"Did we already discuss the X approach a month ago?"* Without `docs/brainstorms/`, you re-explore. With it, `ls docs/brainstorms/ | grep X` resolves in 10 seconds. The cost of re-exploring is ~30 minutes per occurrence; over a year, this is dozens of hours.

- **Conformance illegibility.** *"Did sub-plan 3 actually ship every section of the spec?"* Without `docs/audits/`, you read the implementation and reconstruct. With dated audit reports, you read the matrix and know.

- **Cross-link rot.** *"The README says see `flow.md`, but that doc moved."* Without a maintained `docs/README.md` authority hierarchy + last-verified dates, drift is detectable. Without that infrastructure, the graph silently rots and references become lies.

External memory also enables a property no in-session context can provide: **cross-session continuity for AI tools**. Each Claude session starts fresh; the graph is what lets session N+1 reference what session N decided. Without the graph, every session re-derives context from scratch. With it, sessions become a continuous body of work.

## Core methodology — the 7-subdirectory taxonomy

The graph organizes docs by *lifecycle and authority*, not by topic. Topic-based organization collapses under scale (every doc is "about feature X" in some sense). Lifecycle-based organization scales indefinitely.

The seven standard subdirectories:

### `docs/brainstorms/` — exploratory WHAT-to-build docs

Captures pre-commitment exploration. Dated naming convention (`YYYY-MM-DD-<slug>-brainstorm.md`). Each brainstorm has a *decision log* at the bottom — what was decided, what was rejected, why.

- **Lifecycle**: created during exploration → referenced when revisiting the topic → archived to `docs/archive/brainstorms/` when the capability ships or the direction pivots.
- **Naming**: `YYYY-MM-DD-<slug>-brainstorm.md`. Date matters because brainstorms supersede each other; the latest is canonical.

### `docs/specs/` — point-in-time design contracts

Formal design specs produced by a product-designer agent (or equivalent). Dated. Each spec corresponds to one capability and lives until the capability ships + has a conformance matrix.

- **Lifecycle**: spec authored → plan written against spec → implementation → conformance matrix audits spec-vs-implementation → spec archives if shipped capability is stable.
- **Naming**: `YYYY-MM-DD-<slug>-spec.md` (or `-design.md`; pick one and stay consistent).

### `docs/plans/` — multi-step implementation plans

The output of plan-writing skills (superpowers writing-plans, or equivalent). One plan per spec, often split into multiple sub-plans for complex features.

- **Lifecycle**: plan written → sub-plans dispatched to implementers → conformance matrix verifies → plan archives when complete.
- **Naming**: `YYYY-MM-DD-<plan-slug>.md`. May live under `docs/superpowers/plans/` if using the superpowers convention.

### `docs/audits/` — dated audit artifacts

The verification ladder lands here. Every conformance matrix, flow audit, interaction audit, UX review, security review produces a dated artifact under `docs/audits/`.

- **Lifecycle**: created when audit runs → referenced for follow-up fixes → superseded when next audit at same scope runs (older audit archives).
- **Naming**: `YYYY-MM-DD-<slug>-<audit-type>.md`. The `<audit-type>` suffix is load-bearing — it disambiguates per-audit categories (conformance, flow, ux, interaction, a11y, security).

### `docs/product/capabilities.md` — the WHAT-the-product-does layer

A single file (not a subdirectory) that's the stable-ID list of user capabilities. Stable IDs (`O.1`, `O.2`, `M.1`, `M.2`, etc.) referenced by brainstorms, specs, audits.

- **Lifecycle**: capability added when planning a new feature → status tag updated when the feature ships → entries never deleted (deferred / superseded capabilities stay as historical record).
- **Why a single file**: the index needs to fit in one read. Splitting capabilities across files breaks the *"one place to see what users can do"* property.

### `docs/design-system/` — identity layer for UI projects

Per-domain design language docs. Only ships if the project has a non-trivial UI design system. Subdirectory contains README + per-aspect docs (persona, motion, components, tokens, patterns).

- **Lifecycle**: authored at design-system establishment → updated as the system evolves → versioned via in-doc *"Last verified"* dates rather than dated filenames (because design-system docs are permanent canon, not point-in-time).
- **Naming**: slug-based, no dates (`persona.md`, `motion.md`, `tokens.md`, etc.). Date lives inside as `**Last verified:** YYYY-MM-DD`.

### `docs/archive/` — aged-out content (nothing is ever deleted)

When a brainstorm > 60 days has no commit follow-up, when an audit > 90 days hasn't been re-audited, when a spec's feature shipped + has a conformance matrix → move to `docs/archive/<category>/`. The archive is reverse-chronologically indexed via `ls -lt`.

- **Lifecycle**: archived → searchable but out of the active reading order → recoverable if context demands.
- **Why never delete**: historical context matters. The decision log that led to a pivot is the cheapest way to understand *why* the current direction exists. Deleting it makes the current direction look arbitrary.

### Optional subdirectories

Ship these only when the project has specific needs:

- `docs/flows/` — canonical multi-screen journey docs. Permanent + last-audited dated. Ship when UI has multi-screen arcs worth treating as canonical.
- `docs/preflights/` — pre-flight risk-assessment outputs. Ship when using a pre-flight agent.
- `docs/research/` — competitive / UX research dossiers. Ship when research is a meaningful activity.
- `docs/scratch/` — ephemeral working docs. Ship when you need a doc that doesn't fit elsewhere and may not survive.
- `docs/blueprints/` — architectural blueprints (rare; for projects that pre-design engine primitives).
- `docs/superpowers/{plans,specs}/` — output of superpowers plan-writing skill if used.
- `docs/mcp/` — MCP server architecture / tools if the project authors MCP servers.
- `docs/design-debt/registry.md` — the Saturday-ritual canonical findings registry. Ship if Layer 7 maintenance is active.

## How to derive THIS project's specifics

Before authoring the knowledge graph, audit:

1. **What docs already exist?** `ls docs/ 2>/dev/null && ls *.md && ls **/*.md 2>/dev/null` — many projects have docs scattered (root README + WIKI + a `docs/` with three files). Inventory before reorganizing.

2. **What's the project's maturity?** From the identity layer. Greenfield → minimal scaffold (`README.md` + empty subdirs). Shipped → full structure. Mature → full structure + populated capability map + active archive.

3. **What activities does the team do?** Brainstorm? Yes → ship `brainstorms/`. Plan-driven? Yes → ship `plans/` + `audits/`. UI design? Yes → ship `design-system/` + `flows/`. Research dossiers? Yes → ship `research/`. Each activity earns its subdirectory.

4. **What naming patterns is the user already using?** If they have `2026-04-15-onboarding-redesign.md` in root, the dated-slug convention is already established. Preserve their choices when reasonable.

5. **Is a capability map worth shipping?** The capability map is the highest-leverage doc. Ship it when the project has > 5 user-facing capabilities AND the team will reference stable IDs. Scaffold empty otherwise.

6. **What's the archive policy?** Default: brainstorm > 60 days no commit-follow-up → archive. Audit > 90 days no re-audit → archive. Spec whose feature shipped + has conformance → archive. Confirm or adjust thresholds with the user.

## Authoring guidance — what to write into the final artifact

### `docs/README.md` — the entry point (~120-200 LOC)

This file is read by Claude when entering the knowledge graph. It IS the navigation aid. Structure:

```markdown
# `docs/` — <PROJECT_NAME> knowledge graph

This folder is the primary knowledge graph for <PROJECT_NAME>. Anyone (or any agent) opening the repo reads this file before anything else under `docs/`.

> Companion knowledge sources outside this folder: `CLAUDE.md` (root), `.claude/rules/*.md`, `.claude/skills/*/SKILL.md`, memory directory.

## How this folder is organized

<TREE_DIAGRAM>

## Reading order for a newcomer

1. `CLAUDE.md` (root) — identity + rules + DoD + task classification.
2. `<STRATEGY_OR_VISION_DOC>` — current strategy / ICP.
3. `docs/product/capabilities.md` — what users can currently do.
4. <DESIGN_SYSTEM_README if applicable>
5. <PRIMARY_FLOW_DOC for canonical user journey>
6. (Topic-specific) <TOPIC_DOC_LIST>

## Authority hierarchy

| Question | Canonical source |
|---|---|
| "What can users currently do?" | `docs/product/capabilities.md` |
| "What's the canonical flow X look like?" | `docs/flows/<arc>.md` |
| "How should this card animate?" | `docs/design-system/motion.md` |
| ... |

## Maintenance conventions

### Naming
- Brainstorms: `docs/brainstorms/YYYY-MM-DD-<slug>-brainstorm.md`
- Specs: `docs/specs/YYYY-MM-DD-<slug>-spec.md`
- Audits: `docs/audits/YYYY-MM-DD-<slug>-<audit-type>.md`
- Permanent (capabilities, flows, design-system docs): slug-only, no date in filename. Date lives inside as `**Last verified:** YYYY-MM-DD`.

### Cross-link convention
Each doc opens with:
```
**Related:** upstream → <up-doc> · downstream ← <down-doc> · sibling ↔ <peer-doc>
```

### Archive policy
- Brainstorm > 60 days without commit-follow-up → `docs/archive/brainstorms/`
- Audit > 90 days without re-audit → `docs/archive/audits/`
- Spec whose feature shipped + has conformance matrix → `docs/archive/specs/`
- Nothing is ever deleted.
```

The load-bearing parts: **(a)** the reading order means a new session / new contributor / AI tool knows what to read first; **(b)** the authority hierarchy means when two docs claim authority on the same topic, there's a tiebreak procedure (canonical source per question shape); **(c)** the archive policy means nothing is deleted, so historical context is recoverable.

### Subdirectory scaffolding

Empty subdirectories need `.gitkeep` files to be tracked by git. Each subdirectory should also have a `README.md` if the user adopts the *"every directory explains itself"* convention. Most projects skip per-subdirectory READMEs and rely on `docs/README.md` alone.

### `docs/product/capabilities.md` — scaffold even if empty

If you're shipping the file, scaffold the ID convention:

```markdown
# <PROJECT_NAME> capability map

**Purpose.** Cross-cutting index of user capabilities — what users can currently do at goal level.

**Status tags.** `[shipped]` / `[partial]` / `[planned]` / `[deferred]`.

**Entry format.**
```
### <ID> <Name> [status]
> <One-sentence goal: user can X to achieve Y.>
**Deep refs:** <where the canonical doc lives>
**Constraint:** <preconditions or blockers — only if non-trivial>
```

## Personas
- <PERSONA_1> — <one-line>
- <PERSONA_2> — <one-line>

## <PERSONA_1> capabilities

(none yet)

## <PERSONA_2> capabilities

(none yet)
```

Even with no entries, the convention is set. Future capabilities slot in.

## Depth signatures — what battle-tested looks like

The authored knowledge graph fails the depth bar if it lacks any of these signals.

1. **`docs/README.md` exists and is current.** Reading order + authority hierarchy + maintenance conventions present. Last-updated date inside.

2. **Reading order makes a newcomer effective in < 30 minutes.** Test: read the listed docs in order; can you make sense of the project's shape? If not, the reading order is wrong.

3. **Authority hierarchy table maps ≥ 8 question shapes.** Below 8, the tiebreak procedure is mostly empty. Above 8, the table earns its keep.

4. **Naming conventions are followed.** Spot-check: are brainstorms dated and slugged? Are audits dated and audit-type suffixed? Are capabilities slug-only with internal dates? If any doc violates, fix in same change.

5. **Cross-references use full paths, not bare slugs.** `docs/brainstorms/2026-05-19-setup-multichannel-brainstorm.md` not `the multichannel brainstorm`. Bare-slug references rot when files move; full-path references break loudly and get fixed.

6. **Archive policy is stated AND followed.** Stating without following produces a graph that LOOKS organized but is silently bloating. `ls docs/brainstorms/ | wc -l` should be < 30 in a healthy mature project; higher means archive policy isn't running.

7. **`docs/product/capabilities.md` has stable IDs referenced from elsewhere.** Test: `grep -r "O\.[0-9]" docs/` should find references in brainstorms + specs + audits. If only the capability map itself mentions the IDs, the map isn't load-bearing.

8. **Plans reference their specs.** Each plan opens with *"Implements: docs/specs/<...>.md"*. Plans without specs are orphan plans.

9. **Audits reference what they're auditing.** Each audit opens with *"Auditing: docs/specs/<...>.md against implementation per `<plan>.md`"*. Audits without context are dated reports without provenance.

10. **Permanent docs have last-verified dates inside.** `flows/onboarding-arc.md` opens with *"**Last verified:** 2026-05-16."* When the date is > 90 days old, the doc enters drift territory; Layer 7 should flag it.

If the authored graph lacks any of these, redo. The graph's value is in its addressability; addressability requires discipline at every layer.

## Anti-patterns to avoid

- **Dumping all docs at `docs/` root.** Within 6 months you have 80 mixed `.md` files at `docs/` and no way to find anything. Subdirectory discipline is what makes the graph navigable.

- **Topic-based subdirectories instead of lifecycle-based.** `docs/auth/`, `docs/payments/`, `docs/onboarding/` collapses under scale — every doc is *"about feature X"* in some sense, and brainstorms / specs / audits all get mixed together within each topic. Lifecycle-based (`brainstorms/`, `specs/`, `audits/`) scales because the lifecycle distinction is universal.

- **No naming convention.** *"I'll just name files whatever feels right."* Within 3 months you can't find docs by listing the directory. The naming convention is the index.

- **`docs/README.md` that becomes a wiki TOC instead of a navigation aid.** The README's job is *reading order + authority hierarchy + maintenance conventions*. If it grows into a topic-by-topic listing of every doc, it stops being load-bearing — Claude reads the index but can't tell which doc to read first.

- **Capability map without stable IDs.** *"Capability: user can sign in"* with no ID. References from elsewhere can't link to a specific capability; the map becomes free-text. Stable IDs (`O.1`, `M.1`) are what make the map referenceable.

- **Permanent docs with dates in filenames.** `docs/flows/2026-04-15-onboarding-flow.md` becomes a historical snapshot the moment a newer one lands. Use `docs/flows/onboarding-flow.md` (slug-only) + last-verified dates inside.

- **Dated docs without dates in filenames.** `docs/brainstorms/onboarding.md` and `docs/brainstorms/onboarding-v2.md` and `docs/brainstorms/onboarding-final.md` — chaos. Use `YYYY-MM-DD-<slug>-brainstorm.md`; the date is the version.

- **Archive that's actually deleted.** *"I cleaned up old brainstorms."* Recovery is now impossible. Move-to-archive is the only valid disposition.

- **Cross-links that go stale silently.** Every doc that references another should test the link. Add a Layer-7 link-check ritual if cross-links matter (most graphs benefit).

- **`docs/` as a substitute for in-code documentation.** External memory is for *decisions, plans, audits, capabilities, flows*. It's NOT for *"how does function X work."* That's a code comment. Don't blur the boundary.

- **`docs/` as a substitute for memory.** Memory (cross-conversation factoids) lives in the memory directory; `docs/` is project-level external memory. The two are different — see `memory-system.md` for the distinction.

- **A `docs/scratch/` that becomes the dumping ground for unfiled work.** Either give every doc a real home, or accept that `scratch/` items get deleted on a schedule. Otherwise scratch absorbs the whole graph.

## Cross-references

- `project-identity.md` — Layer 1. The identity layer in `CLAUDE.md` is the entry point; this principle is the second-level entry (the `docs/` graph).
- `plan-driven-work.md` — Layer 3. Plans live in `docs/plans/`; conformance matrices in `docs/audits/`. The plan-driven discipline depends on the graph existing.
- `memory-system.md` — Layer 3. Memory and `docs/` have different lifetimes: memory is cross-conversation factoids; `docs/` is project-level external memory. The two compose but don't substitute.
- `task-classification.md` — Layer 3. The task classification table in `CLAUDE.md` references `docs/` paths; the graph must exist for the references to resolve.
- `maintenance-ritual.md` — Layer 7. Drift detection (skill audit, doc audit) operates on the graph. The archive policy is enforced by the ritual.
