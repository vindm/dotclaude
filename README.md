<div align="center">

<img src="./assets/logo.svg" width="560" alt="dotclaude — AI dev infrastructure framework for Claude Code">

<br>

**AI dev infrastructure framework for Claude Code.**

Walks you through 7 layers — project identity → architecture → process → quality bar → knowledge graph → domain kits → maintenance — and authors `CLAUDE.md` + `docs/` + `.claude/` derived from your project.

Not templates. Not a kit. A **methodology**.

<br>

<img src="./demo/bootstrap.gif" width="900" alt="/dotclaude:bootstrap walking the full 7-layer hierarchical interview, authoring CLAUDE.md + docs/ + .claude/ in ~30s on a fresh project">

<br>

[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-cc785c?style=for-the-badge)](https://docs.anthropic.com/claude-code/plugins)
[![License](https://img.shields.io/badge/license-MIT-cc785c?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-cc785c?style=for-the-badge)](#)

</div>

<br>

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
# Then in any project root:
/dotclaude:bootstrap
```

# dotclaude — AI dev infrastructure for Claude Code

A Claude Code plugin that bootstraps your project's `CLAUDE.md`, `docs/` knowledge graph, and `.claude/` system through a hierarchical interview. Distilled methodology from one battle-tested production codebase.

**Jump to:** [Slash commands](#slash-commands) · [How it works](#how-it-works) · [See it in action](#see-it-in-action) · [What to expect](#what-to-expect) · [FAQ](#faq) · [Install](#install--contribute)

<br>

## Slash commands

| Command | What it sets up |
|---|---|
| 🪄 `/dotclaude:bootstrap` | **Headline.** Full 7-layer hierarchical interview. Authors `CLAUDE.md` + `docs/` + `.claude/`. |
| 🎨 `/dotclaude:design` | **Showpiece.** UI / IA / a11y / visual-quality audit kit (Layer 6 standalone). |
| 🧹 `/dotclaude:coding` | File-size discipline, code review, voice / forbidden phrases. |
| 📐 `/dotclaude:planning` | Pre-impl validation, audit routing. |
| 🧪 `/dotclaude:testing` | Test architecture + coverage strategy. |
| 🗃️ `/dotclaude:data` | DB integrity, query discipline, migrations. |
| 🤖 `/dotclaude:ai-workflow` | LLM cost monitoring + eval discipline. |
| 🪄 `/dotclaude:init` | v1 entry — Layer 6 only, skips upstream layers. |

**Inside the plugin** — 40 methodology principles · 14 hook templates · 7 domain skills + 1 bootstrap orchestrator · 7 anonymized war stories. Cost: ~984 tokens always-on per session; 2.7–5.5k per skill invocation; ~12k for full bootstrap. Full architectural reference in [`docs/v2-vision.md`](./docs/v2-vision.md).

<br>

## How it works

### The 7-layer hierarchy

Each layer authors a specific slice of `CLAUDE.md` + `docs/` + `.claude/`. Dependency-ordered — Layer 1's output feeds Layers 2–6; Layer 7 polices the rest.

| # | Layer | What bootstrap authors |
|---|---|---|
| 1 | **Project Identity** | `CLAUDE.md` opening — vision + ICP + moat + production-vs-internal + stage |
| 2 | **Architecture** | `CLAUDE.md` Architecture + Constraints + boundary rules + universal hooks |
| 3 | **Process Discipline** | `CLAUDE.md` "How You Work" + DoD + task-classification table + verification ladder + memory typing |
| 4 | **Quality Bar** | `.claude/rules/design-north-star.md` (Tier 1 + Tier 2 benchmarks + anti-references) + `quality-bar` skill |
| 5 | **Knowledge Graph** | `docs/README.md` + subdirectory skeleton + `docs/product/capabilities.md` scaffold |
| 6 | **Domain Kits** | Per applicable domain: design / coding / planning / testing / data / ai-workflow. `.claude/{agents,skills,hooks,rules}/*` |
| 7 | **Maintenance** | Saturday-style design-debt ritual + drift detection + `skill-auditor` agent (default-deferred for early projects) |

### Bootstrap in 5 phases

| Phase | What happens | Duration |
|---|---|---|
| 1. Project scan | Auto-discovers ~30–40% of inputs from `package.json`, file tree, `git log`, existing `CLAUDE.md` / `docs/` / `.claude/` | ~5s |
| 2. Hierarchical interview | 7 phases (A–G), 1–3 Qs per turn, skip-if-Phase-1-answered | 20–60 min |
| 3. Cross-layer coordination | Merges forbidden-phrase lists; reconciles audit routing | < 1 min |
| 4. Stage → review → commit | All authoring lands in `.claude-staging/` first; explicit approval gate | varies |
| 5. Output summary | Inventory by layer + skipped reasons + next-step recommendations | < 30s |

### Brownfield safety

Bootstrap detects your project's state via Phase 1 scan and runs in the right mode automatically.

| Project state | Mode | What bootstrap does |
|---|---|---|
| No `CLAUDE.md` + no `.claude/` | **Fresh** | Runs all 7 layers |
| `CLAUDE.md` < 50 LOC OR `.claude/` < 5 artifacts | **APPEND** | Adds missing layers only; never stomps existing |
| `CLAUDE.md` > 200 LOC OR > 5 H2s + structured | **REFUSE** | Recommends Layer 6 standalone or manual edits |

REFUSE is a feature — it protects accumulated AI infrastructure from being overwritten.

<br>

## See it in action

`/dotclaude:design` running on a fresh Vite + React + TypeScript project, authoring 8 tailored design artifacts (4 agents + 2 skills + 2 hooks) in ~15 seconds:

<div align="center">

<img src="./demo/demo.gif" width="900" alt="/dotclaude:design — Layer 6 design kit authored fresh for a Vite + React + Tailwind project with Linear + Stripe Dashboard benchmarks">

</div>

**Validation reports** (real runs, not simulations):
- [Bootstrap on a battle-tested production codebase](./docs/bootstrap-smoke-test-2026-05-21.md) — full 7-layer flow, ~65% depth match
- [`/dotclaude:design` on a fresh Vite + React project](./docs/design-real-smoke-test-2026-05-21.md) — grade **A**
- [`/dotclaude:coding` on the same fresh project](./docs/coding-real-smoke-test-2026-05-21.md) — grade **A-minus**

<br>

## What to expect

**Wall-clock per project shape:**

| Project shape | Bootstrap time |
|---|---|
| Greenfield, 1–3 domains | 20–35 min |
| Early prototype, 3–5 domains | 40–60 min |
| Shipped, 5–7 domains | 60–90 min |
| Mature, 8 domains (max-domain) | 90–120 min |
| Brownfield comprehensive (REFUSE) | < 5 min, no authoring |

**What bootstrap can't manufacture in one pass:**

- **Accumulated incident memories** — emerge from coding sessions over weeks/months
- **Per-aspect design system docs** — land when content emerges from real design work
- **Substrate runbook skills** — written when you've lost > 1 hour relearning a subsystem twice

Bootstrap creates the scaffold + the "accrue-here" anchors. The entries themselves accumulate over time. The methodology compounds; one-pass output is the seed, not the tree.

Full depth-match analysis: [`docs/bootstrap-smoke-test-2026-05-21.md`](./docs/bootstrap-smoke-test-2026-05-21.md).

<br>

## FAQ

**How is this different from a `CLAUDE.md` template?**

Templates are static text you paste + edit. dotclaude reads your actual project (`package.json`, file tree, `git log --grep="fix:"`, existing conventions) and **authors** a `CLAUDE.md` tuned to it. The 7 layers are a methodology, not a template.

**Will dotclaude overwrite my existing `CLAUDE.md` or `.claude/`?**

No. Phase 1 scan detects existing infrastructure. Mature setups trigger REFUSE mode (recommends Layer 6 standalone instead). Partial setups trigger APPEND mode (adds missing layers only, never stomps). All authoring goes to `.claude-staging/` first; explicit approval gate before commit.

**Does it work for non-iOS / non-React-Native projects?**

Yes. The methodology is platform-agnostic. Smoke tested on a Vite + React + TypeScript + Tailwind project — grade A. The 7 layers map to any project shape; the domain skills (`/dotclaude:coding`, `/dotclaude:data`, etc.) are stack-universal.

**Can I use just one domain skill without bootstrap?**

Yes. `/dotclaude:design`, `/dotclaude:coding`, or any other domain skill runs standalone. Useful for incremental setup or adding a new concern to an existing `CLAUDE.md`.

**What does it cost in tokens?**

~984 tokens always-on per session (skill descriptions). 2.7–5.5k per single skill invocation. ~12k for the full bootstrap (loads upstream principles selectively per layer). Session overhead is < 1% of typical Claude usage.

**How do I uninstall?**

`claude plugin uninstall dotclaude@dotclaude`. The `.claude/` directory dotclaude authored stays in your project — it's yours to edit, version, or remove.

<br>

## Install & contribute

```bash
# Production install (any Claude Code session)
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude

# Dev install (for contributing)
git clone https://github.com/vindm/dotclaude.git && cd dotclaude
claude --plugin-dir .
```

**Contributing**: full guide in [**CONTRIBUTING.md**](./CONTRIBUTING.md) — covers adding principles, hooks, skills, war stories, smoke test discipline, and the PR checklist.

**Changelog**: see [CHANGELOG.md](./CHANGELOG.md) for v1.0.0 → v1.1.0 (v2 reframe).

---

<div align="center">

<sub>Built from months of working with Claude Code as a daily driver.</sub><br>
<sub>MIT licensed · <a href="./docs/v2-vision.md">v2 architecture</a> · <a href="./CHANGELOG.md">changelog</a> · <a href="./CONTRIBUTING.md">contribute</a></sub>

</div>
