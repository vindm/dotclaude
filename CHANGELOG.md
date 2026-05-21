# Changelog

All notable changes to dotclaude are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project loosely follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) — minor versions for new layers / skills / principles, patches for fixes and doc corrections.

## [1.1.0] - 2026-05-21

### Added — v2 reframe

The plugin moves from "design audit kit" to **AI dev infrastructure framework**. See [`docs/v2-vision.md`](./docs/v2-vision.md) for the full architecture rationale; the 7-layer hierarchy is now the headline.

- **`/dotclaude:bootstrap`** — new headline command. 7-layer hierarchical interview (project identity → architecture → process → quality bar → knowledge graph → domain kits → maintenance) authoring `CLAUDE.md` + `docs/` + `.claude/`. Adaptive per project shape; brownfield-safe with three modes (APPEND / REFUSE / FRESH-OVERWRITE).
- **5 upstream methodology principles** to anchor bootstrap's pre-Layer-6 stages:
  - `principles/project-identity.md` — Layer 1 (vision / ICP / moat / production-vs-internal / stage).
  - `principles/knowledge-graph.md` — Layer 5 (`docs/` index, authority hierarchy, capability map scaffold).
  - `principles/plan-driven-work.md` — Layer 3 (spec → plan → impl → conformance-matrix pattern).
  - `principles/memory-system.md` — Layer 3 (user / feedback / project / reference memory typing + decay policies).
  - `principles/task-classification.md` — Layer 3 (the routing matrix pattern).
- **Optional Layer 7 principle** for projects opting into maintenance discipline:
  - `principles/saturday-ritual.md` — weekly design-debt batch + drift detection.
- **Bootstrap smoke test report** ([`docs/bootstrap-smoke-test-2026-05-21.md`](./docs/bootstrap-smoke-test-2026-05-21.md)) — bootstrap's one-pass output compared against the source project's months-evolved ground truth. ~65% depth match calibration evidence.
- **Real /dotclaude:design smoke test on a fresh project** ([`docs/design-real-smoke-test-2026-05-21.md`](./docs/design-real-smoke-test-2026-05-21.md)) — first NON-case-study validation; targets a fresh Vite + React 19 + TS 6 + Tailwind 4 project the test had no prior exposure to. Match level A.
- **`bootstrap.gif` demo** — 38-second 1200×800 JetBrains Mono walk through the headline flow. Replaces the design-only demo as README hero.
- **5 GitHub topics** added to repo metadata: `ai-dev-infrastructure`, `bootstrap`, `claude-md`, `methodology`, `ai-workflow`.

### Changed

- **Repo positioning**: design plugin → AI dev infrastructure framework.
- **README rewrite** — bootstrap as headline; design demoted to "Layer 6 in action" example. The 7-layer hierarchy is the lead narrative.
- **`plugin.json`** + **`marketplace.json`** descriptions updated to reflect the meta-framework angle.
- **Demo gif typography** — uses JetBrains Mono at 18pt 1200×720 (previously the unstyled fallback at smaller dimensions).
- **`skills/init/SKILL.md` frontmatter + prose** — clarified as a Layer-6-only entry, lighter alternative to `/dotclaude:bootstrap` for users skipping upstream layers.

### Fixed

- **Anonymization guard** now catches binary-file false positives (the previous version emitted noise on `assets/*.gif`).
- **9 proper-noun leaks** in analysis docs (source-project domain-specific names) scrubbed.
- **README false references** — removed mentions of `/dotclaude:audit`, `/dotclaude:identity`, `/dotclaude:architecture`, `/dotclaude:quality-bar` (skills that do NOT ship in v1.1; remain on v2 roadmap). README's Brownfield section now describes the actually-supported alternatives (Layer 6 standalone / manual CLAUDE.md edits / bootstrap APPEND mode).
- **`docs/v2-vision.md` §6** — added "Status note" header clarifying that only bootstrap + upstream principles ship in v1.1; per-layer skills are forward-looking.

### Preserved (zero breaking changes for v1 users)

- **All 7 v1 domain skills** untouched: `/dotclaude:design`, `/dotclaude:coding`, `/dotclaude:planning`, `/dotclaude:testing`, `/dotclaude:data`, `/dotclaude:ai-workflow`, `/dotclaude:init`. The contract is preserved exactly.
- **All hook templates in `hook-templates/`** unchanged.
- **All war stories in `principles/war-stories/`** unchanged.
- **Anonymization guard** (`scripts/check-anonymization.sh`) — universal, ships on every commit through CI.

A v1 user invoking `/dotclaude:design` in v1.1 sees no behavior change. The v2 surface is opt-in via `/dotclaude:bootstrap`.

## [1.0.0] - 2026-05-20

Initial release. The "design audit kit" framing — Layer 6 of what would later become the 7-layer hierarchy.

- **7 domain skills**: design / coding / planning / testing / data / ai-workflow / init.
- **24 methodology principles** in `principles/` covering file discipline, decomposition, task classification, quality rubric, design benchmarking, audit routing, visual verification, and per-domain depth.
- **12 hook templates** in `hook-templates/` — generic shell guardrails (file-size ceiling, raw-hex sweep, secret leak, boundary checks, forbidden phrases, etc.) with Mustache placeholders.
- **4 war stories** in `principles/war-stories/` — anonymized debugging narratives as proof material.
- **4 example showcase outputs** in `docs/showcase/` demonstrating Layer 6 outputs on different project shapes.
- **Anonymization guard** (`scripts/check-anonymization.sh`) + CI workflow (`.github/workflows/anonymization-guard.yml`).
- **`/dotclaude:design` demo gif** as README hero.

[1.1.0]: https://github.com/vindm/dotclaude/releases/tag/v1.1.0
[1.0.0]: https://github.com/vindm/dotclaude/releases/tag/v1.0.0
