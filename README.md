# dotclaude

![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)
![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-plugin-orange)
![Skills: 7](https://img.shields.io/badge/skills-7-blue)

> **Most Claude Code plugins paste fixed templates. dotclaude AUTHORS them for your project.** UX audit agents, a11y, design tokens, code review, data integrity — derived from your actual stack, named benchmarks, and past failure modes. Not generic boilerplate.

---

> **The button that never fired.** A signup form. The test reported success. The handler never ran. The OS had silently absorbed the tap. *Three hours of wrong-direction debugging.*
>
> `/dotclaude:design` authors an `interaction-audit` agent for your project that catches this class of bug before the test runs — tuned to your code, your benchmarks, your past failure modes. **Authored, not pasted.**

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
# Then in any project root:
/dotclaude:design
```

| Slash command | What it sets up |
|---|---|
| 🎨 `/dotclaude:design` | UI / IA / a11y / visual-quality audit agents + rules (the showpiece) |
| 🧹 `/dotclaude:coding` | File-size discipline, code review, voice / forbidden phrases |
| 📐 `/dotclaude:planning` | Pre-impl validation, audit routing |
| 🧪 `/dotclaude:testing` | Test architecture + coverage strategy |
| 🗃️ `/dotclaude:data` | DB integrity, query discipline, migrations |
| 🤖 `/dotclaude:ai-workflow` | LLM cost monitoring + eval discipline |
| 🪄 `/dotclaude:init` | Meta — runs the relevant subset of above |

---

## Authored, not pasted

Most Claude Code plugins ship a fixed library of agents / skills / rules. You install the kit; the kit is the same for every user. That works when the project shape is the same — but it isn't. A React SaaS dashboard, an Expo mobile app, and a Rust CLI tool need *different* `.claude/` directories. Pasting the same UX-audit agent into a CLI tool is noise; pasting an iOS-flavored a11y agent into a web app is wrong.

dotclaude flips the model. The plugin ships **methodology** — abstract teaching docs that describe how to design each kind of artifact for any project. When you invoke `/dotclaude:design` in your project root, Claude Code:

1. **Reads your project** — `package.json`, file tree, existing `CLAUDE.md`, recent commit messages (`git log --oneline --grep="fix:"` is gold), one representative source file per major module
2. **Interviews you** — 3-6 adaptive questions about benchmarks, voice, past failures, quality bar. **The most important question**: name 2-4 apps you benchmark your design against. Without anchors the rubric is "looks good" — meaningless.
3. **Decides what to author** — applicability matrix; skips what doesn't fit (a CLI tool gets no `ux-reviewer`; a backend gets no `journey-mapping`)
4. **Authors fresh artifacts** — every agent / skill / rule cites your actual file paths, references bugs from your git history, anchors rubrics to your named benchmarks, picks anti-patterns from your code
5. **Stages, then commits** — writes to `.claude-staging/` first, walks you through the reasoning, asks for approval, then moves to `.claude/`

The result is a small focused kit that *fits*. 5-10 well-tuned artifacts beat 25 generic ones.

### See actual authored output

| Project type | What `/dotclaude:design` (+ flows) authored |
|---|---|
| [React SaaS dashboard](./docs/showcase/react-saas.md) | Linear + Stripe anchored; Tailwind token sweep; settings-page type-scale bypass anti-pattern from git history |
| [Expo iOS habit tracker](./docs/showcase/expo-mobile.md) | Apple iOS 26 + Telegram + WHOOP + Things 3 anchored; disabled-CTA bug from past; Maestro-driven workflow |
| [Rust CLI tool](./docs/showcase/cli-tool.md) | Most of the kit SKIPPED (no UI); interaction-audit adapted to flags + help-text; `--force` dead-flag anti-pattern from git history |

None of these would work pasted into the wrong project. That's the point.

---

## How it works (the 4-tier model)

The kit dotclaude authors decomposes into four tiers, each addressing a different failure mode at a different cost:

| Tier | Fires when | Catches |
|---|---|---|
| **Hooks** (`.sh`) | Every tool call (edit / bash / session) | Mechanical violations — raw hex, forbidden phrases, file-size ceiling, secrets |
| **Rules** (`.md`) | Read by the agent as context | Cross-cutting policy — visual verification, audit routing, design benchmarks |
| **Skills** (`.md` dirs) | Auto-loaded by file path or topic | Procedural how-to — reuse-check matrices, decomposition recipes, persona testing |
| **Agents** (subagents) | Invoked during work | Pre-impl validation, post-impl review, semantic / visual / a11y audits |

**Cheapest tier wins.** A regex hook costs zero LLM tokens. A reviewer agent can cost thousands. The discipline: catch what you can at the cheapest tier; reserve agents for problems that need judgment.

---

## What's in the plugin

```
dotclaude/
├── .claude-plugin/
│   ├── plugin.json                  # Plugin manifest
│   └── marketplace.json             # Marketplace registration
├── skills/
│   ├── design/    ⭐                 # /dotclaude:design — the showpiece
│   ├── coding/                       # /dotclaude:coding
│   ├── planning/                     # /dotclaude:planning
│   ├── testing/                      # /dotclaude:testing
│   ├── data/                         # /dotclaude:data
│   ├── ai-workflow/                  # /dotclaude:ai-workflow
│   └── init/                         # /dotclaude:init — meta-orchestrator
├── principles/                       # 24 teaching docs read selectively per project
├── hook-templates/                   # 12 generic shell-script guardrails
├── examples/                         # 4 war stories — proof material
└── docs/showcase/                    # Example authored outputs
```

**24 principles** — methodology library. Each principle teaches Claude Code how to design ONE class of artifact (code-review, ux-audit, a11y-audit, data-integrity, etc.) for ANY project. The principles are read by Claude during the authoring flow; they are not copied to your `.claude/`.

**12 hook templates** — the only true templates. Small bash guards that ARE genuinely project-agnostic (file-size ceiling, forbidden phrases, raw-hex sweep, secret leak detection, etc.). Each takes a few config values and Mustache-renders to your `.claude/hooks/`.

**4 war stories** — anonymized debugging narratives (the button that never fired; the write that returned success and changed nothing; the test passed for the wrong reason; the bug surfaced five screens later than the cause). Read by Claude as proof material; never copied into your `.claude/`.

Token cost (honest): always-on ~984 tokens per session (skill descriptions); per-skill on-invoke 2.7k-5.5k. Modest.

---

## Philosophy

- **Specificity from your project, abstraction in the plugin.** Plugin's teaching material is abstract; output in your `.claude/` is specific.
- **Cheapest tier wins.** Hook before rule before skill before agent.
- **War stories first-class.** Every constraint should be traceable to a bug it prevents.
- **Authored, not pasted.** No templates with placeholders; LLM-judgment-rewriting per project.
- **A small focused kit beats a sprawling one.** Each domain skill picks selectively. The applicability matrix exists to keep scope tight.

---

## Install & contribute

### Production install (any Claude Code session)

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
```

Then `/dotclaude:design` (or any other flow) is available in any project.

### Manual dev install (contributing)

```bash
git clone https://github.com/vindm/dotclaude.git
cd dotclaude
claude --plugin-dir .
```

### Contributing

- Add a principle: drop a markdown file in `principles/<name>.md` matching the structure of existing docs (applicability gate → why it matters → core methodology → how to derive THIS project's specifics → authoring guidance → rubric / output format → cross-references → anti-patterns to avoid).
- Add a hook template: drop a `<name>.sh` in `hook-templates/` with Mustache placeholders for config values.
- Add a domain skill: create `skills/<domain>/SKILL.md` + `skills/<domain>/interview.md` matching the structure of `skills/design/` (canonical reference).

Anonymization is enforced — `scripts/check-anonymization.sh` + `.github/workflows/anonymization-guard.yml`. Plugin content must not reference specific source projects, customers, or target companies.

### License

MIT. See `LICENSE`.

---

Built from months of working with Claude Code as a daily driver — the design-discipline mostly absent from the public plugin ecosystem, packaged so any project can teach Claude Code its own taste. Authored, not pasted.
