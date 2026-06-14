<div align="center">

<img src="./assets/logo.svg" width="560" alt="dotclaude — AI dev infrastructure for Claude Code">

<br>

**Install one plugin and your project instantly has a team of senior-engineer AI tools** — code reviewers, design auditors, safety guards, and a "how to work" discipline — all ready to use, no setup. Distilled from a real production codebase used daily under pressure.

<br>

[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-cc785c?style=for-the-badge)](https://docs.anthropic.com/claude-code/plugins)
[![License](https://img.shields.io/badge/license-MIT-cc785c?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.1-cc785c?style=for-the-badge)](#)

</div>

<br>

```bash
# 1. install (run once, in any Claude Code session)
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude

# 2. that's it — now just ask Claude to use a tool, e.g.:
#    "review my changes with dotclaude:code-review"
#    "audit this screen with dotclaude:ux-audit"
```

# dotclaude

A [Claude Code](https://docs.anthropic.com/claude-code) plugin. **You install it, and a set of ready-made AI dev tools immediately works in your project** — you don't configure or generate anything. The tools are the kind a senior engineer would set up by hand, distilled from one production codebase and battle-tested in daily use.

**Jump to:** [What you get](#what-you-get) · [Install](#install) · [How to use it](#how-to-use-it) · [Advanced: scaffold a new project](#advanced-scaffold-a-new-project) · [FAQ](#faq)

<br>

## What you get

The moment the plugin is enabled, three things become available in your project. **You use them as-is — nothing to set up.**

### 🛡️ Guard hooks — run automatically

These fire on their own as you (or Claude) work. No invocation needed.

| Guard | What it does |
|---|---|
| **git-safety** | Blocks destructive git (`push --force`, `reset --hard`, `clean -f`, `--no-verify`) before it runs |
| **secret-leak** | Blocks obvious credentials (API keys, tokens) from being written into source |
| **file-size** | Blocks files over 1000 lines (nudges you to split them) |
| **bash-safety** | Warns on `rm -rf $VAR` and friends where an unquoted variable could expand to something dangerous |
| **git-context** | At session start, tells Claude your current branch / uncommitted changes / unpushed commits |
| **uncommitted-warning** | Warns before `/clear` if you have uncommitted work that would be lost |

### 🔍 Review & audit agents — call them on demand

Ask Claude to run one (e.g. *"use dotclaude:code-review on my changes"*). Each is read-only and gives a graded report — it reads **your** project and adapts, it doesn't apply a generic checklist.

| Agent | Use it when… |
|---|---|
| `dotclaude:code-review` | you finished a change and want a senior second pair of eyes before committing |
| `dotclaude:pre-flight` | you're about to start something risky and want the blast-radius mapped first |
| `dotclaude:test-architect` | you want tests designed + written for code that lacks them |
| `dotclaude:data-integrity` | you have a database and want to find orphaned / stuck / corrupt rows |
| `dotclaude:ux-audit` | you built a screen and want it graded for visual polish |
| `dotclaude:a11y-audit` | you want a screen checked for accessibility (labels, contrast, hit targets) |
| `dotclaude:interaction-audit` | you want to find "dead" buttons that look like they do something but don't |
| `dotclaude:flow-audit` | you want a whole multi-screen flow (onboarding, checkout) audited end-to-end |

*(Also: `pages-audit`, `flow-continuity-review`, `design-token-audit`, `product-designer`, `skill-vs-code-audit`, `product-direction-validator`. 14 in total.)*

### 🧭 Working-discipline skills — load when relevant

Claude pulls these in automatically when the task calls for it. The headline one:

- **`dotclaude:operating-discipline`** — the "how to work well" baseline: understand before building, weigh real alternatives, finish + verify, stay lean. It's what keeps Claude from grabbing the first thing that compiles.
- Plus `handoff` (save state before context runs out), `decomposition` (split a too-big file), `plan-driven-work`, `memory-system`, and more.

<br>

## Install

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
```

That enables everything above. There is **no configuration step** — the agents read your project at runtime and adapt to your stack.

To try it without installing (e.g. to evaluate it), clone and point a session at it:

```bash
git clone https://github.com/vindm/dotclaude.git
claude --plugin-dir ./dotclaude
```

<br>

## How to use it

- **Hooks** — nothing to do. They run as you work and block / warn automatically. (They need `jq` on your PATH.)
- **Agents** — ask Claude in plain language: *"review this with dotclaude:code-review"*, *"run dotclaude:a11y-audit on the settings screen"*. You'll get a graded report; the agent never edits your code (except `test-architect` and `product-designer`, which produce artifacts).
- **Skills** — you don't invoke most of them; Claude loads them when the work matches. You can also call one explicitly: *"use dotclaude:decomposition on this file"*.

Your own project's `.claude/` always wins: if you define a tool with the same name, yours overrides the plugin's.

<br>

## Advanced: scaffold a new project

The tools above work in **any** project as-is. But a project also has things no shared tool can know — its vision, architecture, design benchmarks, the routing table for which tool to run when. For that there's the generator:

```bash
/dotclaude:bootstrap     # in a project root
```

It reads your project, asks a short interview, and authors the **project-specific** layer — a `CLAUDE.md`, a `docs/` structure, and a thin local `.claude/` — on top of the consumed tools above. It never re-creates what the plugin already provides; it only writes what's unique to your project. It stages everything for your approval and never overwrites an existing setup.

<img src="./demo/bootstrap.gif" width="820" alt="/dotclaude:bootstrap interviewing a project and authoring its project-specific CLAUDE.md + docs/ + .claude/">

<br>

## How it's built

dotclaude is a **consumable base + a thin generator**:

- The **base** (agents / skills / hooks above) is universal and used as-is — that's most of the value, and why there's nothing to configure.
- The **generator** (`bootstrap`) handles only the un-shareable, project-specific layer.

Everything is distilled from one production codebase, anonymized, and shaped so the agents derive your project's specifics at runtime instead of baking in someone else's. Design rationale: [`docs/v3-consume-direct-brainstorm.md`](./docs/v3-consume-direct-brainstorm.md).

<br>

## FAQ

**Do I have to configure anything after installing?**
No. The agents, skills, and hooks work immediately. The agents read your project (stack, git history, conventions) at runtime, so they adapt without setup.

**Will it overwrite my `CLAUDE.md` or `.claude/`?**
No. The base is provided *alongside* your files — both coexist, and anything you define with the same name as a plugin tool overrides the plugin's. Only the optional `/dotclaude:bootstrap` writes files, and it stages for approval and refuses to overwrite an existing setup.

**Does it work for my stack (not React Native / iOS)?**
Yes — it's stack-agnostic. The agents discover your language, framework, and conventions at runtime. No UI? The UI agents just stay unused.

**What does it cost in tokens?**
Hooks are free (no model call). Skills load only when relevant; an agent run is paid only when you invoke it. There's no heavy always-on cost.

**How do I uninstall?**
`claude plugin uninstall dotclaude@dotclaude`. Anything `/dotclaude:bootstrap` wrote into your project stays — it's yours.

<br>

## Install & contribute

```bash
# install
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude

# develop / contribute (run the local copy in-place)
git clone https://github.com/vindm/dotclaude.git && cd dotclaude
claude --plugin-dir .
```

[CONTRIBUTING.md](./CONTRIBUTING.md) · [CHANGELOG.md](./CHANGELOG.md)

---

<div align="center">

<sub>Built from months of using Claude Code as a daily driver. MIT licensed.</sub>

</div>
