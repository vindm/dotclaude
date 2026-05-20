# dotclaude

> A Claude Code plugin that generates a customized `.claude/` directory for **your** project — not generic templates, not a one-size-fits-all kit. Claude Code reads your codebase, interviews you about goals and past failure modes, then authors project-specific skills, agents, rules, and hooks tailored to your actual stack.

```
/plugin marketplace add vindm/dotclaude
/plugin install dotclaude@vindm
```

Then in any project root:

```
/dotclaude:init
```

Answer a few questions. Get a `.claude/` directory authored from your codebase — anti-patterns derived from your actual code, benchmarks named by you, voice and quality bar matched to your project.

---

## Why this exists

When you let an AI agent write code in your repo, three failure modes show up:

1. **Drift.** Files grow. Conventions slip. The 200-LOC component becomes 1200 LOC over six PRs, none of which individually crossed any threshold worth flagging.
2. **Slop.** AI-shaped phrasing leaks into user-facing copy. Raw hex colors land outside the design system. "TODO: fix later" piles up.
3. **Confidence theatre.** Tests pass for the wrong reason. The handler reports success while the database silently no-ops. The screenshot looks right while the button does nothing.

A `.claude/` directory of guardrails (hooks, rules, skills, audit agents) catches all three — but only if the guardrails fit the project. A code-reviewer agent that checks for "stale closures in `useCallback` refs" is gold for a React Native project and noise for a Python CLI. The shape of the kit has to match the shape of the project.

`dotclaude` is the plugin that does that fitting. It ships **methodology**, not finished artifacts. When you invoke `/dotclaude:init`, Claude Code reads your repo, learns its conventions and failure modes from git history + source files + your answers, and authors a `.claude/` that fits.

## What the plugin contains

```
dotclaude/
├── .claude-plugin/plugin.json       # Plugin manifest
└── skills/init/
    ├── SKILL.md                     # The orchestrator — read by Claude when you invoke /dotclaude:init
    ├── interview.md                 # The Q&A flow Claude follows
    ├── principles/                  # 24 teaching docs Claude reads selectively per project
    ├── hook-templates/              # 12 generic shell-script guardrails (the only true templates)
    └── examples/                    # 4 war stories — proof material, NOT copied to your .claude/
```

### Principles (24 teaching docs)

Each principle doc teaches Claude Code how to design ONE class of artifact for ANY project. The docs are NOT templates — they don't get copied to your `.claude/`. They tell Claude HOW to think about that class, then Claude authors a fresh artifact derived from your actual code.

**Core methodology** (6): `code-review`, `pre-flight`, `file-discipline`, `decomposition`, `visual-verification`, `audit-routing`

**Quality + voice + tests + meta** (6): `quality-rubric`, `forbidden-phrases`, `test-architect`, `skill-vs-code-audit`, `journey-mapping`, `element-reuse`

**UI audits** (6): `ux-audit`, `a11y-audit`, `interaction-audit`, `design-token-audit`, `pages-audit`, `flow-audit`

**Supporting + data + AI** (6): `design-benchmarking`, `persona-testing`, `data-integrity`, `database-query-discipline`, `migration-create`, `ai-cost-monitoring`

### Hook templates (12 — the only true templates)

Shell-script guardrails that ARE genuinely project-agnostic — small bash files that block edits violating size ceilings, forbidden phrases, raw color literals, secrets, etc. Each takes a few config values; the init flow fills them in based on your project.

### War stories (4 examples)

Real anonymized debugging narratives — *the button that never fired*, *the write that returned success and changed nothing*, *the test passed for the wrong reason*, *the bug surfaced five screens later than the cause*. Read by Claude Code at init time as training material for the kinds of bugs the kit prevents. They are NOT copied into your `.claude/`.

## How `/dotclaude:init` works

When you invoke it in your project root, Claude Code:

1. **Reads your project** — `README`, `package.json` (or stack equivalent), top-level structure, existing `CLAUDE.md` if any, recent commit messages, a few representative source files. Builds its own understanding before asking you anything.

2. **Interviews you** — 5-15 adaptive questions covering: project shape, recent bug classes you wish hadn't shipped, quality bar / benchmark apps, stack-specific failure modes, voice / tone discipline. Open-ended. Skips questions whose answer is obvious from the project scan.

3. **Decides what to author** — applies the applicability matrix in `SKILL.md` to choose which artifact classes fit. A CLI tool skips `ux-audit`; a backend skips `journey-mapping`; a project without AI workflows skips `ai-cost-monitoring`.

4. **Authors fresh artifacts** — for each applicable class, reads the corresponding principle doc, then writes a NEW artifact specific to your project: cites your actual file paths, references bugs from your git history, picks anti-patterns derived from your code.

5. **Stages → reviews → commits** — writes to `.claude-staging/` first, walks you through the reasoning, asks for approval, then moves to `.claude/` for committing.

A small focused `.claude/` with 5 well-tuned artifacts beats a sprawling 25-artifact kit. The plugin is biased toward focus.

## Philosophy

A few principles guide what the plugin teaches:

**Specificity from project, abstraction in plugin.** The plugin's teaching material is abstract ("here's how to think about post-implementation code review"). The output in your `.claude/` is specific ("look for stale closures in finish/done refs in `lib/spatial/`"). The plugin never hardcodes the specifics.

**Cheapest tier wins.** If a regex hook can prevent a class of bug at edit time, use the hook. If a rule reminds the agent of the policy at design time, that's cheaper than dispatching an agent. Reserve LLM tokens for problems that genuinely need judgment. The 4-tier model (hooks / rules / skills / agents) is a cost ladder.

**War stories first-class.** Every constraint should be traceable to a bug it prevents. If you can't write the war story, you have an opinion, not a constraint. Opinions belong in style guides, not in load-bearing guardrails.

**Author, do not copy.** The plugin's authoring flow rejects templates-with-placeholders. Every artifact in your `.claude/` is reasoned from your project's actual code + your actual answers — not substituted into a hole.

## Manual install (for development)

If you're contributing to the plugin or testing changes:

```bash
git clone https://github.com/vindm/dotclaude.git
cd dotclaude
claude --plugin-dir .
```

Then `/dotclaude:init` is available in any project Claude Code opens.

## What this plugin will NOT do

- Generate the same `.claude/` for every project — it derives from your code
- Ship finished agents you can't customize — every artifact authored is yours to edit
- Lock you into a specific stack — works for RN, web, backend, CLI, libs
- Replace `CLAUDE.md` — it complements it; your `CLAUDE.md` wins on conflicts
- Run after init — there's no runtime dependency; you can remove the plugin and your `.claude/` keeps working

## Anonymization

Plugin content is verified non-leak via `scripts/check-anonymization.sh` + a GitHub Actions guard. The deny-list blocks references to the source project / customers / target companies that the methodology was distilled from. Author copyright in `LICENSE` is excluded as legitimate.

## License

MIT. See `LICENSE`.

---

Built from months of working with Claude Code as a daily driver — the methodology that earned its place, extracted, abstracted, and packaged so any project can teach Claude Code its own discipline.
