# dotclaude

> **The design-discipline plugin for Claude Code.** Authors a customized `.claude/` kit for your project — UX audit agents, IA / a11y / visual-quality skills, code-review and data-integrity guardrails — derived from your actual stack, named benchmarks, and past failure modes. Not templates. Authored fresh per project.

```
/plugin marketplace add vindm/dotclaude
/plugin install dotclaude@vindm
```

Then in any project root, invoke a domain flow:

| Flow | Slash | What it sets up |
|---|---|---|
| 🎨 **Design** | `/dotclaude:design` | UI / IA / a11y / visual-quality audit agents + rules |
| `coding` | `/dotclaude:coding` | File-size discipline, code review, voice / forbidden phrases |
| `planning` | `/dotclaude:planning` | Pre-impl validation, audit routing |
| `testing` | `/dotclaude:testing` | Test architecture + coverage strategy |
| `data` | `/dotclaude:data` | DB integrity, query discipline, migrations |
| `ai-workflow` | `/dotclaude:ai-workflow` | LLM cost monitoring + eval discipline |
| `init` | `/dotclaude:init` | Meta — runs the subset of above relevant to your project |

Each flow runs a focused interview, reads the project, and authors only what fits.

---

## Why dotclaude leads with design

Most published Claude Code plugins focus on **engineering**: CI tooling, refactoring, code review, test setup. **Design / IA / UX / a11y / visual quality is a near-empty niche** — and it's where AI-assisted dev fails most often. Code Claude writes compiles. Design Claude generates needs adult supervision: dead chrome that promises taps but does nothing, copy that's wrong for the surface, accessibility skipped, design tokens drifting into raw hex.

`/dotclaude:design` is the showpiece. It authors:

- **`ux-reviewer`** — single-screen visual audit, S/A/B/C/D rubric anchored to **your** named benchmark apps (you pick: iOS 26 + Telegram for chrome, Linear / Stripe for B2B, Things 3 + Reeder for content, etc. — the kit has no value without specific anchors)
- **`a11y-audit`** — WCAG 2.2 AA + platform-specific (VoiceOver on iOS / ARIA on web / equivalent), computed against your actual design tokens
- **`interaction-audit`** — affordance-vs-behavior table; catches dead chrome, redundant affordances, optical-group disconnects
- **`design-token-auditor`** — sweep for raw hex / non-token color outside the theme source (haiku-class, cheap)
- **`flow-auditor`** — whole-arc audit with 8-class gap rubric for multi-screen flows
- **`pages-audit`** — cross-section consistency on primary surface (tabs / dashboard panels / nav)
- **`journey-audit` skill** — prior-surface mapping before any new screen design
- **`element-reuse-check` skill** — Gate A verdict matrix (REUSE / REUSE+context / NEW(rename) / NEW) before authoring a new UI element
- **`persona-lens` skill** — Gate B outside-eyes test (day-30 / partner / stranger or equivalent for your audience)
- **`quality-bar` skill** — S-tier rubric + demo test + 5 composition pitfalls
- **`design-north-star` rule** — your named Tier 1 (chrome) + Tier 2 (domain) benchmarks, project-specific anti-pattern catalog
- **`audit-routing` rule** — which audit fires for which question, canonical pipeline order

Plus the hooks: `check-design-tokens.sh` (blocks raw hex at edit time), `check-forbidden-phrases.sh` (blocks AI-slop + brand-specific phrases).

Most of these are **substantial, multi-hundred-LOC agents and skills**. Their value isn't the structure — it's the project-specific tuning: benchmarks you named, anti-patterns derived from your git history, token sweep targeting your actual theme file.

---

## What this is not

- **Not a template kit.** Templates assume every project is the same shape. They aren't.
- **Not opinionated about stack.** Works for RN, web, backend, CLI, libs.
- **Not runtime-coupled.** After authoring your `.claude/`, you can remove the plugin entirely. The artifacts are yours.
- **Not a `CLAUDE.md` replacement.** Your existing `CLAUDE.md` wins on conflicts.

---

## How it works (the four-phase flow)

When you invoke any domain flow (e.g. `/dotclaude:design`), Claude Code:

1. **Reads your project** — `README`, `package.json` (or stack equivalent), top-level structure, existing `CLAUDE.md`, recent commit messages with "fix:" prefix, representative source files. Builds understanding before asking you anything.

2. **Interviews you** — 3-6 adaptive questions scoped to that domain. Skips what's obvious from Phase 1. The most important question for design: **name your benchmark apps**. Without named anchors, the rubric is "looks good" — meaningless.

3. **Reads the relevant principles** — `principles/<topic>.md` are abstract methodology docs. They teach Claude Code HOW to think about the artifact class, not WHAT to write. Each principle is selectively read based on what the project has.

4. **Authors fresh artifacts** — for each applicable artifact class, Claude writes a NEW agent / skill / rule / hook specific to your project: cites your actual file paths, references bugs from your git history, picks anti-patterns from your code, anchors rubrics to your named benchmarks.

5. **Stages → reviews → commits** — writes to `.claude-staging/` first, walks you through the reasoning, asks for explicit approval, then moves to `.claude/`.

The 4-tier model of the kit:

| Tier | Fires when | Catches |
|---|---|---|
| **Hooks** (`.sh` scripts) | Every tool call (edit / bash / session) | Cheap mechanical violations — raw hex, forbidden phrases, file-size ceiling, secrets |
| **Rules** (`.md`) | Read by the agent as context | Cross-cutting policy: visual verification, audit routing, design benchmarks, query discipline |
| **Skills** (`.md` directories) | Triggered by file path or topic | Procedural how-to: reuse-check matrices, decomposition recipes, persona testing |
| **Agents** (delegated subagents) | Invoked during work | Pre-implementation validation, post-implementation review, semantic / visual / a11y audits |

Cheapest tier wins. A regex hook costs zero LLM tokens. A reviewer agent can cost thousands. The discipline: catch what you can at the cheapest tier; reserve agents for problems that need judgment.

---

## Plugin contents

```
dotclaude/
├── .claude-plugin/plugin.json       # Manifest
├── skills/
│   ├── design/        ⭐            # /dotclaude:design — the showpiece
│   ├── coding/                       # /dotclaude:coding
│   ├── planning/                     # /dotclaude:planning
│   ├── testing/                      # /dotclaude:testing
│   ├── data/                         # /dotclaude:data
│   ├── ai-workflow/                  # /dotclaude:ai-workflow
│   └── init/                         # /dotclaude:init — meta-orchestrator
├── principles/                       # 24 teaching docs Claude reads selectively
├── hook-templates/                   # 12 generic shell-script guardrails
└── examples/                         # 4 war stories — proof material
```

### Principles (24 teaching docs)

The methodology library. Each principle teaches Claude Code how to design ONE class of artifact for ANY project. The principles are NOT copied to your `.claude/` — they're read by Claude during the authoring flow.

Grouped:

- **Core methodology** (6): code-review, pre-flight, file-discipline, decomposition, visual-verification, audit-routing
- **Quality + voice + tests + meta** (6): quality-rubric, forbidden-phrases, test-architect, skill-vs-code-audit, journey-mapping, element-reuse
- **UI audits** (6): ux-audit, a11y-audit, interaction-audit, design-token-audit, pages-audit, flow-audit
- **Supporting + data + AI** (6): design-benchmarking, persona-testing, data-integrity, database-query-discipline, migration-create, ai-cost-monitoring

### Hook templates (12)

The only true templates — small bash guards that ARE genuinely project-agnostic. Each takes a few config values (file-size ceiling, theme path, forbidden phrases list, etc.) and Mustache-renders to `.claude/hooks/` in your project.

### War stories (4)

Real anonymized debugging narratives — *the button that never fired*, *the write that returned success and changed nothing*, *the test passed for the wrong reason*, *the bug surfaced five screens later than the cause*. Read by Claude as proof material for the kinds of bugs each artifact class is meant to catch. NOT copied into your `.claude/`.

---

## Philosophy

**Specificity from your project, abstraction in the plugin.** The plugin's teaching material is abstract ("here's how to think about post-implementation code review"). The output in your `.claude/` is specific ("look for stale closures in `useCallback` refs in `lib/spatial/`, because git log shows two recent fixes for this pattern"). The plugin never hardcodes specifics.

**Cheapest tier wins.** Hook before rule before skill before agent.

**War stories first-class.** Every constraint should be traceable to a bug it prevents.

**Author, do not copy.** Every artifact in your `.claude/` is reasoned from your actual code + your actual answers — not substituted into a hole.

**A small focused kit beats a sprawling one.** 5-10 well-tuned artifacts beat 25 generic ones. Each domain skill picks selectively.

---

## Manual install (development / contributing)

```bash
git clone https://github.com/vindm/dotclaude.git
cd dotclaude
claude --plugin-dir .
```

Then `/dotclaude:design` (or any other flow) is available in any project Claude Code opens.

## Contributing

Add a principle: drop a markdown file in `principles/<name>.md` following the structure of existing docs (applicability gate → why it matters → core methodology → how to derive THIS project's specifics → authoring guidance → rubric / output format → cross-references → anti-patterns to avoid).

Add a hook template: drop a `<name>.sh` in `hook-templates/` with Mustache placeholders for config values.

Add a domain skill: create `skills/<domain>/SKILL.md` + `skills/<domain>/interview.md` matching the structure of `skills/design/` (canonical reference).

Anonymization is enforced — see `scripts/check-anonymization.sh` + `.github/workflows/anonymization-guard.yml`. Plugin content must not reference specific source projects, customers, or target companies.

## License

MIT. See `LICENSE`.

---

Built from months of working with Claude Code as a daily driver — the design-discipline that's mostly absent from the public plugin ecosystem, packaged so any project can teach Claude Code its own taste.
