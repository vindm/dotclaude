<div align="center">

<img src="./assets/logo.svg" width="560" alt="dotclaude — AI dev infrastructure for Claude Code">

<br>

dotclaude sets up a project's `CLAUDE.md`, `docs/` knowledge graph, and `.claude/` system through a guided, layered interview. It reads your actual project first and authors infrastructure tuned to it, rather than handing you a template to fill in.

<br>

<img src="./demo/bootstrap.gif" width="900" alt="/dotclaude:bootstrap walking the 7-layer interview and authoring CLAUDE.md + docs/ + .claude/ on a fresh project">

<br>

[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-cc785c?style=for-the-badge)](https://docs.anthropic.com/claude-code/plugins)
[![License](https://img.shields.io/badge/license-MIT-cc785c?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-cc785c?style=for-the-badge)](#)

</div>

<br>

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
# then, in any project root:
/dotclaude:bootstrap
```

# dotclaude

A Claude Code plugin that bootstraps a project's AI dev infrastructure — `CLAUDE.md`, a `docs/` knowledge graph, and a `.claude/` system — through a hierarchical interview. The methodology is distilled from one production codebase, used daily and refined under real pressure.

**Jump to:** [Slash commands](#slash-commands) · [How it works](#how-it-works) · [Examples](#examples) · [What to expect](#what-to-expect) · [FAQ](#faq) · [Install](#install--contribute)

<br>

## Slash commands

| Command | What it sets up |
|---|---|
| `/dotclaude:bootstrap` | The full 7-layer interview. Authors `CLAUDE.md` + `docs/` + `.claude/`. |
| `/dotclaude:design` | UI / IA / a11y / visual-quality audit kit (Layer 6, standalone). |
| `/dotclaude:coding` | File-size discipline, code review, voice / forbidden phrases. |
| `/dotclaude:planning` | Pre-implementation validation, audit routing. |
| `/dotclaude:testing` | Test architecture and coverage strategy. |
| `/dotclaude:data` | DB integrity, query discipline, migrations. |
| `/dotclaude:ai-workflow` | LLM cost monitoring and eval discipline. |
| `/dotclaude:init` | v1 entry — Layer 6 only, skips the upstream layers. |

The plugin holds 40 methodology principles, 14 hook templates, 7 domain skills plus a bootstrap orchestrator, and 7 anonymized war stories. Session overhead is about 984 tokens (the always-on skill descriptions); a single skill runs 2.7–5.5k, a full bootstrap roughly 12k. Architecture reference: [`docs/v2-vision.md`](./docs/v2-vision.md).

<br>

## How it works

### The 7-layer hierarchy

Each layer authors one slice of `CLAUDE.md` + `docs/` + `.claude/`, in dependency order: Layer 1 feeds Layers 2–6, and Layer 7 maintains the rest.

| # | Layer | What bootstrap authors |
|---|---|---|
| 1 | Project Identity | `CLAUDE.md` opening — vision, ICP, moat, production-vs-internal, stage |
| 2 | Architecture | `CLAUDE.md` Architecture + Constraints + boundary rules + universal hooks |
| 3 | Process Discipline | `CLAUDE.md` "How You Work" (named principles + tests), DoD, task-classification table, memory typing, handoff |
| 4 | Quality Bar | `.claude/rules/<domain>-north-star.md` (benchmarks + anti-references) + `quality-bar` skill |
| 5 | Knowledge Graph | `docs/README.md` + subdirectory skeleton + `docs/product/capabilities.md` scaffold + knowledge-layers doctrine |
| 6 | Domain Kits | Per applicable domain: design / coding / planning / testing / data / ai-workflow. `.claude/{agents,skills,hooks,rules}/*` |
| 7 | Maintenance | Design-debt ritual + drift detection + `skill-auditor` agent (deferred by default for early projects) |

### Bootstrap in 5 phases

| Phase | What happens | Duration |
|---|---|---|
| 1. Project scan | Auto-discovers ~30–40% of inputs from `package.json`, file tree, `git log`, existing `CLAUDE.md` / `docs/` / `.claude/` | ~5s |
| 2. Hierarchical interview | 7 phases (A–G), 1–3 questions per turn, skipping anything Phase 1 already answered | 20–60 min |
| 3. Cross-layer coordination | Merges forbidden-phrase lists; reconciles audit routing | < 1 min |
| 4. Stage → review → commit | All authoring lands in `.claude-staging/` first; explicit approval gate | varies |
| 5. Output summary | Inventory by layer, skip reasons, next-step recommendations | < 30s |

### Brownfield safety

Bootstrap detects your project's state in its Phase 1 scan and picks a mode automatically.

| Project state | Mode | What bootstrap does |
|---|---|---|
| No `CLAUDE.md` and no `.claude/` | Fresh | Runs all 7 layers |
| `CLAUDE.md` < 50 LOC or `.claude/` < 5 artifacts | Append | Adds missing layers only; never overwrites existing |
| `CLAUDE.md` > 200 LOC or structured with > 5 sections | Refuse | Recommends a standalone Layer 6 skill or manual edits |

Refuse mode is deliberate: an existing, substantial setup is left untouched rather than overwritten.

<br>

## Examples

`/dotclaude:design` running on a fresh Vite + React + TypeScript project, authoring 8 tailored design artifacts (4 agents, 2 skills, 2 hooks) in about 15 seconds:

<div align="center">

<img src="./demo/demo.gif" width="900" alt="/dotclaude:design authoring a Layer 6 design kit for a Vite + React + Tailwind project">

</div>

Validation reports from real runs:

- [Bootstrap on a production codebase](./docs/bootstrap-smoke-test-2026-05-21.md) — full 7-layer flow, ~65% depth match against months-evolved ground truth
- [`/dotclaude:design` on a fresh Vite + React project](./docs/design-real-smoke-test-2026-05-21.md) — grade A
- [`/dotclaude:coding` on the same fresh project](./docs/coding-real-smoke-test-2026-05-21.md) — grade A−

<br>

## What to expect

Wall-clock per project shape:

| Project shape | Bootstrap time |
|---|---|
| Greenfield, 1–3 domains | 20–35 min |
| Early prototype, 3–5 domains | 40–60 min |
| Shipped, 5–7 domains | 60–90 min |
| Mature, 8 domains | 90–120 min |
| Brownfield comprehensive (Refuse) | < 5 min, no authoring |

Some things a single pass can't manufacture — they accumulate from real work over time:

- **Incident memories** emerge from coding sessions over weeks and months.
- **Per-aspect design-system docs** land when the content shows up in actual design work.
- **Substrate runbook skills** get written the second time you lose an hour relearning a subsystem.

Bootstrap creates the scaffold and the "accrue here" anchors; the entries fill in as you work. The one-pass output is the seed, not the tree. Full depth-match analysis: [`docs/bootstrap-smoke-test-2026-05-21.md`](./docs/bootstrap-smoke-test-2026-05-21.md).

<br>

## FAQ

**How is this different from a `CLAUDE.md` template?**

A template is static text you paste and edit. dotclaude reads your actual project — `package.json`, the file tree, `git log --grep="fix:"`, existing conventions — and authors a `CLAUDE.md` tuned to it. The 7 layers are a methodology, not a fill-in-the-blanks file.

**Will it overwrite my existing `CLAUDE.md` or `.claude/`?**

No. The Phase 1 scan detects existing infrastructure. A substantial setup triggers Refuse mode (it recommends a standalone Layer 6 skill instead); a partial one triggers Append mode (missing layers only, nothing overwritten). All authoring goes to `.claude-staging/` first, behind an explicit approval gate.

**Does it work outside iOS / React Native?**

Yes — the methodology is platform-agnostic. It's been smoke tested on a Vite + React + TypeScript + Tailwind project (grade A). The 7 layers map to any project shape, and the domain skills are stack-universal.

**Can I use one domain skill without bootstrap?**

Yes. `/dotclaude:design`, `/dotclaude:coding`, or any other domain skill runs standalone — useful for incremental setup or adding a single concern to an existing `CLAUDE.md`.

**What does it cost in tokens?**

About 984 tokens always-on per session (the skill descriptions), 2.7–5.5k per skill invocation, and roughly 12k for a full bootstrap. Per-session overhead is under 1% of typical usage.

**How do I uninstall?**

`claude plugin uninstall dotclaude@dotclaude`. The `.claude/` directory it authored stays in your project — it's yours to edit, version, or remove.

<br>

## Install & contribute

```bash
# install (any Claude Code session)
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude

# develop / contribute
git clone https://github.com/vindm/dotclaude.git && cd dotclaude
claude --plugin-dir .
```

Contributing guide: [CONTRIBUTING.md](./CONTRIBUTING.md) — adding principles, hooks, skills, and war stories, the smoke-test discipline, and the PR checklist.

Changelog: [CHANGELOG.md](./CHANGELOG.md) covers v1.0.0 through v1.2.0.

---

<div align="center">

<sub>Built from months of using Claude Code as a daily driver.</sub><br>
<sub>MIT licensed · <a href="./docs/v2-vision.md">architecture</a> · <a href="./CHANGELOG.md">changelog</a> · <a href="./CONTRIBUTING.md">contribute</a></sub>

</div>
