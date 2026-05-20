<div align="center">

<img src="./assets/logo.svg" width="560" alt="dotclaude">

<br>

**The Claude Code plugin that writes itself.**

Most plugins paste fixed templates. `dotclaude` reads your project,<br>
asks 5 smart questions, and authors a custom `.claude/` from scratch.

<br>

<img src="./demo/demo.gif" width="900" alt="/dotclaude:design running on a Vite + React project, authoring 8 design artifacts in ~15 seconds">

<br>

[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-cc785c?style=for-the-badge)](https://docs.anthropic.com/claude-code/plugins)
[![License](https://img.shields.io/badge/license-MIT-cc785c?style=for-the-badge)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-7-cc785c?style=for-the-badge)](#slash-commands)

</div>

<br>

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
```

Then in any project: `/dotclaude:design`

<br>

## dotclaude vs. typical plugin

|  | `dotclaude` | typical plugin |
|--|--|--|
| Approach | **Authors fresh per project** | Pastes fixed templates |
| Anti-patterns | **Mined from your git history** | Generic AI-slop list |
| Benchmarks | **The apps you named** | Hardcoded "iOS / Material" |
| File paths | **Your actual paths** | Placeholders |
| Voice | **Your brand voice** | Generic friendly |

<br>

## Slash commands

|  | Command | What it sets up |
|--|--|--|
| 🎨 | `/dotclaude:design` | UI / IA / a11y / visual-quality audit agents *(the showpiece)* |
| 🧹 | `/dotclaude:coding` | File-size discipline, code review, voice / forbidden phrases |
| 📐 | `/dotclaude:planning` | Pre-impl validation, audit routing |
| 🧪 | `/dotclaude:testing` | Test architecture + coverage strategy |
| 🗃️ | `/dotclaude:data` | DB integrity, query discipline, migrations |
| 🤖 | `/dotclaude:ai-workflow` | LLM cost monitoring + eval discipline |
| 🪄 | `/dotclaude:init` | Meta — runs the relevant subset |

<br>

## See it in action

<table>
<tr>
<td width="33%" valign="top">

#### ⚛️ React SaaS dashboard
Linear + Stripe anchored. Tailwind token sweep. Settings-page type-scale anti-pattern from git history.

[**View output →**](./docs/showcase/react-saas.md)

</td>
<td width="33%" valign="top">

#### 📱 Expo iOS habit tracker
Apple iOS 26 + WHOOP + Things 3 anchored. Disabled-CTA rule. Maestro-driven workflow.

[**View output →**](./docs/showcase/expo-mobile.md)

</td>
<td width="33%" valign="top">

#### 🦀 Rust CLI tool
Most of kit *skipped* (no UI). Interaction-audit adapted to flag-vs-handler. `--force` dead-flag rule.

[**View output →**](./docs/showcase/cli-tool.md)

</td>
</tr>
</table>

<br>

## How it works

<table>
<tr>
<td width="50%" valign="top">

**1. Reads your project**
`package.json`, file tree, existing `CLAUDE.md`, `git log --grep="fix:"` for recurring bug classes.

**2. Interviews you**
3–6 adaptive questions. The most important: *"name 2–4 apps you benchmark against."* Without anchors the rubric is meaningless.

</td>
<td width="50%" valign="top">

**3. Decides what to author**
Applicability matrix. Skips what doesn't fit (a CLI tool gets no `ux-reviewer`; a backend gets no `journey-mapping`).

**4. Authors fresh**
Every artifact cites your actual file paths, references bugs from your git history, anchors rubrics to *your* named benchmarks.

</td>
</tr>
</table>

Stages to `.claude-staging/` first. Walks you through. Commits only on approval.

<br>

---

<div align="center">

### Authored, not pasted.

</div>

---

<br>

## What's inside

| | |
|--|--|
| 🎯 **7 domain skills** | One slash command per concern (design / coding / planning / testing / data / ai-workflow / init) |
| 📚 **24 principles** | Methodology docs Claude reads selectively per project — not copied into your `.claude/` |
| 🔧 **12 hook templates** | Generic shell guardrails (file-size ceiling, raw-hex sweep, secret leak, etc.) — the only true templates |
| 📖 **4 war stories** | Anonymized debugging narratives — proof material, not output |

Always-on cost: **~984 tokens per session**. On-invoke: 2.7k–5.5k per skill.

<br>

## Install

```bash
# Production
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude

# Dev (contributing)
git clone https://github.com/vindm/dotclaude.git && cd dotclaude
claude --plugin-dir .
```

<br>

## Contribute

- **Add a principle** — drop a `.md` in [`principles/`](./principles/) matching existing structure
- **Add a hook template** — drop a `.sh` in [`hook-templates/`](./hook-templates/) with Mustache placeholders
- **Add a domain skill** — create `skills/<name>/` matching [`skills/design/`](./skills/design/) as canonical

Anonymization enforced — see [`scripts/check-anonymization.sh`](./scripts/check-anonymization.sh).

<br>

---

<div align="center">

<sub>Built from months of working with Claude Code as a daily driver.</sub><br>
<sub>MIT licensed.</sub>

</div>
