<div align="center">

<img src="./assets/logo.svg" width="560" alt="dotclaude — AI dev infrastructure for Claude Code">

<br>

# Your AI should work like a senior who's shipped under pressure for a year.

Not a template you fill in — a **discipline**, distilled from a real production codebase. Split into two plugins so you install only the discipline your project actually needs.

[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-cc785c?style=for-the-badge)](https://docs.anthropic.com/claude-code/plugins)
[![License](https://img.shields.io/badge/license-MIT-cc785c?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/version-3.0.0-cc785c?style=for-the-badge)](#)

</div>

<br>

```bash
claude plugin marketplace add vindm/dotclaude
```

That registers the marketplace. Install either plugin below on its own, or both.

<br>

## The two plugins

<table>
<tr>
<td width="50%" valign="top">

### [dotclaude (CORE)](./plugins/core/README.md)

*A senior who won't let you shoot your own foot.*

Parallel-session worktree isolation, blast-radius pre-flight, guard hooks against the foot-guns, graded code review, test coverage by risk.

```bash
claude plugin install dotclaude@dotclaude
```

</td>
<td width="50%" valign="top">

### [dotclaude-design](./plugins/design/README.md)

*The AI design/UX auditor nobody else has.*

Elicits what "good" means for your product — the north-star — then holds every screen to it: ux, flow, pages, a11y, interaction, and design-token audits, plus a product-designer IA/flow spec.

```bash
claude plugin install dotclaude-design@dotclaude
```

</td>
</tr>
</table>

<br>

## The idea

Quality AI development isn't a setting — it's a way of working. The instincts that make a senior engineer, or a senior designer, good are mostly **universal** and almost entirely **learnable**. They just don't live in a config file; they live in how you and the agent agree to work.

**Distilled, not invented.** Every tool in either plugin earned its place by catching a real bug or stopping a real disaster in a codebase shipped daily for a year. Hard-won discipline can't be made up — only lived, then extracted.

**Universal by default, yours where it matters.** Most of a good setup is the same in every project — that part is *consumed*, working the instant you install, nothing to configure. Only what's genuinely yours — your quality bar, your named benchmarks, your risk priorities — is *elicited* through a short interview each plugin runs once.

**One plugin, one promise.** This marketplace used to ship as a single plugin listing everything it did. Splitting coding/testing/pre-flight discipline from design/UX audit means each plugin does one job and says so — read its README, install it, done.

<br>

<div align="center">

Distilled from a year of using Claude Code as a daily driver — [how it's built](./docs/v3-consume-direct-brainstorm.md). · MIT · [Contribute](./CONTRIBUTING.md) · [Changelog](./CHANGELOG.md)

</div>
