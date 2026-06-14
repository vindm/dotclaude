<div align="center">

<img src="./assets/logo.svg" width="560" alt="dotclaude — AI dev infrastructure for Claude Code">

<br>

# Your AI should work like a senior engineer who's shipped under pressure for a year.

Not a template you fill in — a **discipline**, distilled from a real production codebase and handed to your project. The bugs a senior smells before the tests run. The foot-guns they refuse to step on. The instinct to think before they type. Install it; it's already working.

[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-cc785c?style=for-the-badge)](https://docs.anthropic.com/claude-code/plugins)
[![License](https://img.shields.io/badge/license-MIT-cc785c?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.1-cc785c?style=for-the-badge)](#)

</div>

<br>

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
```

<br>

## The idea

Quality AI development isn't a setting — it's a way of working. The instincts that make a senior engineer good are mostly **universal** (how to review, how to decompose, what to never let slip) and almost entirely **learnable**. They just don't live in a config file; they live in how you and the agent agree to work.

dotclaude captures that discipline and makes your AI work by it. Three convictions shape it:

**Distilled, not invented.** This is not a synthesized "best practices" list. Every tool here earned its place by catching a real bug or stopping a real disaster in a codebase shipped daily for a year. Hard-won discipline can't be made up — only lived, then extracted.

**Universal by default, yours where it matters.** Most of a good setup is the same in every project. That part is *consumed* — it works the instant you install, nothing to configure. Only what's genuinely yours — your project's identity, architecture, and standards — is *generated*. (A consumable base + a thin generator: stop hand-rolling the 90% that's already solved.)

**Adapts to your code, never imposes a checklist.** The agents read your stack, your git history, your conventions at runtime and judge against *those*. Guidance that points at principles and derives the specifics — never a snapshot that's wrong by next week.

<br>

## What you get

A senior's coverage across your whole workflow — **14 agents, 13 working-discipline skills, 6 guards**, organized by what you're working on. All live the moment you install.

**🧠 Always on — under everything.**
`operating-discipline` makes the agent work like a senior on every real task: understand before building, weigh real alternatives instead of grabbing idea #1, never call a job "done" that isn't verified. And 6 guards refuse the foot-guns automatically — a secret sliding into a commit, a force-push over a teammate's work, a file past every sane limit.

**⌨️ Coding.**
`code-review` catches the bug that passed every test and shipped anyway — paths that drifted apart, a write that returned success but saved nothing — judged against the mistakes *your* git history repeats. `decomposition` splits a file that's outgrown itself, at the right seams.

**🗺️ Planning.**
`pre-flight` maps the blast radius before you touch anything risky. `plan-driven-work` turns a vague task into spec → plan → verified-done. `product-designer` takes a feature from idea to a real IA + flow spec.

**🎨 Design & UX.**
Grade a surface the way a design team would: `ux-audit` (visual polish), `a11y-audit` (accessibility), `interaction-audit` (chrome that lies about what it does), `flow-audit` (a whole journey end-to-end), `pages-audit` (cross-screen consistency), `design-token-audit` (color discipline).

**🧪 Testing.**
`test-architect` finds what's untested by risk, then designs *and writes* the tests in your runner.

**🗄️ Data.**
`data-integrity` sweeps your real data for corruption, orphans, and stuck rows — the rot you'd otherwise meet six months later in a support ticket. `migration-create` writes safe schema migrations against your actual setup.

Every one reads *your* project at runtime — your stack, your history, your conventions — and judges against those, not a generic checklist.

<br>

## Try it

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
```

Then, in any project — just ask:

> *"review my changes with dotclaude:code-review"*
> *"audit the settings screen with dotclaude:ux-audit"*

A graded report comes back; your code isn't touched. The guards are already on. Nothing to configure, and your own `.claude/` always wins — define a tool with the same name and yours overrides.

*Evaluating first? `git clone https://github.com/vindm/dotclaude.git && claude --plugin-dir ./dotclaude`*

<br>

## Going further

The tools work in any project as-is. When you want the rest — a `CLAUDE.md`, a `docs/` knowledge graph, your project's own identity and standards — run `/dotclaude:bootstrap`. It interviews your project and authors only what's unique to it, on top of the tools you already have. Stages for approval; never overwrites what's there.

<div align="center">

<img src="./demo/bootstrap.gif" width="820" alt="/dotclaude:bootstrap interviewing a project and authoring its CLAUDE.md + docs/ + project-specific .claude/">

</div>

<br>

<div align="center">

Distilled from a year of using Claude Code as a daily driver — [how it's built](./docs/v3-consume-direct-brainstorm.md). · MIT · [Contribute](./CONTRIBUTING.md) · [Changelog](./CHANGELOG.md)

</div>
