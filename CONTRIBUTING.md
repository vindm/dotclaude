# Contributing to dotclaude

Thanks for your interest. dotclaude is opinionated: it ships a specific methodology distilled from one battle-tested codebase. Contributions that strengthen the methodology are welcome; contributions that broaden scope or dilute focus may be politely declined.

## Project structure

The repo is a **two-plugin marketplace**. Everything a user installs lives under `plugins/`; everything else is repo-level material (provenance, analysis, demo) that never ships inside a plugin.

| Path | What lives there |
|---|---|
| `.claude-plugin/marketplace.json` | The marketplace manifest listing both plugins. |
| `plugins/core/` | The **`dotclaude`** plugin — worktree isolation, pre-flight, guard hooks, code review, risk-weighted testing. Has its own `.claude-plugin/plugin.json`. |
| `plugins/design/` | The **`dotclaude-design`** plugin — ux / flow / pages / a11y / interaction / design-token audits + the product-designer IA agent. |
| `plugins/<plugin>/agents/` | Consumed subagents (`code-review`, `pre-flight`, `ux-audit`, …) — used as-is at runtime, adapting to the project; never re-authored per project. |
| `plugins/<plugin>/skills/` | Slash-command setup skills (`bootstrap`, `coding`, `testing`, `design`, `worktree`) + auto-loading process skills (`operating-discipline`, `knowledge-layers`, `decomposition`, …). Each is `SKILL.md` (+ `interview.md` where it runs an interview). |
| `plugins/<plugin>/principles/` | Teaching-material methodology docs the setup skills read on-demand to author a project's own layer. Single-source-of-truth: skills cite, never duplicate. |
| `plugins/<plugin>/hook-templates/` | Config-needing shell hooks (Mustache-configurable) that a setup skill renders into a target project. |
| `plugins/core/hooks/` | The universal always-on guard hooks + `hooks.json` wiring — shipped live, no per-project config. |
| `examples/` | Anonymized war stories (~400 words each) showing where the methodology came from. Repo-level provenance — not shipped in either plugin. |
| `deferred/` | Domains authored but not yet shipped in a plugin (data, ai-workflow, migration). |
| `docs/` | Analysis docs — vision, smoke-test reports, audits. |
| `assets/` | Logo SVG. |
| `demo/` | VHS tape sources + rendered gifs for the README. |

## How to contribute

Decide first which plugin your change belongs to — the engineering base (`plugins/core`) or the design layer (`plugins/design`).

### Add a principle

Drop a markdown file in `plugins/<plugin>/principles/<name>.md` matching the structure of existing principles. A principle is teaching material: it teaches a setup skill how to author that discipline into *any* project, so it stays project-agnostic. Typical sections:

- **When to ship one** — when this applies (and when it doesn't).
- **Core methodology** — the abstract, project-agnostic pattern.
- **How to derive THIS project's specifics** — what a skill should discover or ask to instantiate the pattern.
- **Acceptance** — what a battle-tested authored result has, paired with the failure each element prevents.
- **Report format / rubric** — the output contract, where the discipline produces a graded artifact.
- **Cross-references** — related principles + the skills/agents that consume this one.

Cross-reference it from any skill that should read it.

### Add a hook

Three homes, depending on the hook's nature:

- **Universal, always-on** (fires for every user with no config) → `plugins/core/hooks/scripts/<name>.sh`, wired in `plugins/core/hooks/hooks.json`.
- **Config-gated, always-on** (needs project facts, but reads them at runtime) → same place, wired the same way, but it reads its block from the consuming project's `dotclaude.yml` via `hooks/scripts/_read_dotclaude_yml.py` and is a **silent no-op when the block is absent**. This is the preferred shape for anything project-tunable: one home for the logic, no rendered per-project copy to drift. `check-file-size`, `check-main-checkout-edit`, `check-main-checkout-bash-write` and `check-delivery-claim` are the current examples.
- **Config-needing at INSTALL time** (the value cannot be read at runtime — a rendered path, a substituted command) → `plugins/<plugin>/hook-templates/<name>.sh` with Mustache placeholders (`{{ PROJECT_VAR }}`); a setup skill renders it into the target project.

Prefer the second over the third. A rendered copy forks the logic per project and stops receiving fixes.

Config keys must stay **two levels deep** (`delivery.claimsPushed`, not `delivery.claims.pushed`). `_read_dotclaude_yml.py` prefers PyYAML but falls back to a bundled minimal parser that reads exactly two levels; a nested key resolves to nothing there, so the hook goes silently dead on any machine without PyYAML.

Either way, a hook must:

1. Be project-agnostic in core logic — no hardcoded paths, names, or assumptions (config comes via Mustache substitution at install time).
2. Be safe to run on every `Edit` / `Write` / `Bash` event with no side effects beyond logging or exit code.
3. Exit `0` on pass, `2` on block, `1` on warn. Stderr is shown to Claude; stdout is silent. (`PostToolUse` cannot block — the tool already ran — so exit `2` there is informational. If a hook relies on that, say so in its header rather than implying prevention.)
4. Carry a brief header comment naming the mistake classes it prevents.
5. Ship a `test-<name>.sh` beside it that drives a **real fixture** (a `git init`'d temp repo, an actual write, an actual push) rather than restating the hook's own condition. Prove it bites: break the hook's core assertion on purpose and confirm the harness goes red.

### Add a skill

Create `plugins/<plugin>/skills/<name>/SKILL.md` (+ `interview.md` if it interviews). There are two shapes:

- **A setup skill** (like `coding` / `testing` / `design`) elicits the project's own intent and writes a **thin artifact** the already-shipped agents read at runtime — it does **not** author a project-local copy of an agent, rule, or hook (that would fork the logic and drift). Canonical references: `plugins/core/skills/coding/` and the showpiece `plugins/design/skills/design/`. The shape: (1) scan the repo to ground decisions in real code; (2) interview only for what code can't answer; (3) read the relevant principles; (4) write the artifact; (5) present for explicit approval before writing.
- **An auto-loading process skill** (like `operating-discipline` / `decomposition`) is consumed as-is at runtime — a clear applicability gate in the frontmatter `description` is what makes Claude load it at the right moment.

Cite the project's actual file paths in any authored output (never generic `src/components/`).

### Add a war story

Drop a ~400-word debugging narrative in `examples/<slug>.md`. Required sections:

- **Symptom** — what looked broken from the outside.
- **Root cause** — what was actually wrong.
- **The diagnostic that finally worked** — the specific move that made it visible.
- **Lesson** — the methodology principle this derives.
- **The discipline this produced** — the rule / hook / skill / agent that now prevents recurrence.

Anonymize it (see below), and point its `See also` at the current artifacts by repo path, so the links survive future restructuring.

## Anonymization

Every war story and doc must be anonymized — no proper nouns from real projects, no real customer / employer / colleague names. Replace specifics with generic placeholders (`<project>`, `<customer>`, `<the gym>`, etc.).

There is deliberately **no automated deny-list guard in this repo.** The guard used to live here (`scripts/check-anonymization.sh` + a CI workflow) but was moved to the private source project — the deny-list *is* the secret vocabulary of real names, so a public repo can't contain the very list it must avoid emitting. Anonymize by hand, and when in doubt, leave the specific out.

## Smoke test before claiming a principle works

For new principles or skills, run a smoke test:

1. Pick a real project (or a fresh fixture).
2. Have Claude execute the new skill or principle against it.
3. Compare the output to battle-tested depth — the standard is what an experienced engineer would author after a week in the codebase, not a generic template fill.
4. Document gaps as P0 / P1 follow-ups in a `docs/<slug>-smoke-test-YYYY-MM-DD.md` report.

See `docs/coding-real-smoke-test-2026-05-21.md` and `docs/design-real-smoke-test-2026-05-21.md` as canonical examples. The shape:

- What was tested + how.
- Authored output + LOC delta.
- Side-by-side comparison with what the source project actually shipped.
- Gaps classified P0 / P1 / P2.
- Verdict: ready / ready-with-followups / not-ready.

## A fix INSIDE an already-released version reaches nobody

The plugin cache is keyed by version. Fixing two defects inside a released `x.y.z`, pushing
them, then running `plugin marketplace update` and `plugin install` gives three cheerful
successes — «Successfully updated», «Plugin is already installed» — and the installed copy is
byte-for-byte the old one, because the version string did not move. Every consumer keeps
running the broken code while every step reports success.

So: **any change to shipped plugin content bumps the version**, in `plugin.json`, in
`marketplace.json` and in the CHANGELOG, in the same commit. And verify delivery by reading a
file out of the installed cache path, never by trusting the installer's output.

## Pull request checklist

- [ ] Story / doc anonymized by hand — no real project, customer, or company names.
- [ ] `CHANGELOG.md` updated with the change (date + one-line description).
- [ ] If new principle / skill / hook — smoke test report added under `docs/`.
- [ ] Cross-references point at real, current repo paths (no links to moved or deleted files).
- [ ] No emojis except where explicitly stylistic (logo wordmark, README table icons, demo gif content).
- [ ] No new runtime dependencies (the plugins are zero-dep — keep it that way).
- [ ] No new files > 1000 LOC.
- [ ] No raw hex colors in any markdown / shell — semantic placeholders only.

## What we'll politely decline

- **Contributions that broaden scope to non-Claude-Code AI assistants** (Cursor, Continue, Codex CLI, Aider, etc.). dotclaude is Claude-Code-native; cross-tool support dilutes the methodology.
- **Generic / templated content.** The methodology *is* the project-specific derivation pattern. "Here's a one-size-fits-all CLAUDE.md template" is the opposite of what we ship.
- **Tooling that requires a runtime dependency.** The plugins author files; they don't ship a binary. Anything that needs `npm install` or `pip install` lives elsewhere.
- **Tests for skills themselves.** Skills are prose; their value emerges from Claude executing them against a real project. Unit-testing prose is theater — use smoke tests instead.
- **Per-language stack kits** (`/dotclaude:python`, `/dotclaude:rust`, etc.). Domains are horizontal (coding, testing, design); language-specific is too narrow and ages badly.

## Local dev install

```bash
git clone https://github.com/vindm/dotclaude.git
cd dotclaude
claude --plugin-dir ./plugins/core     # or ./plugins/design
```

The setup commands (`/dotclaude:bootstrap`, `/dotclaude:coding`, `/dotclaude:testing`, `/dotclaude:design`, `/dotclaude:worktree`) are then available in any project Claude Code opens against this checkout. To iterate on a skill, edit `plugins/<plugin>/skills/<name>/SKILL.md` and re-run the slash command — Claude re-reads the file each invocation.

For the installed-from-marketplace path, see the README:

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
claude plugin install dotclaude-design@dotclaude
```

## License

MIT. By contributing, you agree your contributions are licensed under the same terms.
