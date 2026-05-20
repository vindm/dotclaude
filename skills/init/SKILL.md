---
description: Bootstrap a customized .claude/ directory for the current project. Reads the codebase, interviews the user about goals and failure modes, then authors project-specific skills, agents, rules, and hooks. Invoke with /dotclaude:init in any project root.
---

# `/dotclaude:init` — bootstrap a customized `.claude/`

You are bootstrapping a `.claude/` directory for the user's current project. Your output is **NEW project-specific artifacts you author**, not copies of templates. The user's project has its own stack, failure modes, conventions, and goals. Your job is to figure those out, then synthesize a set of skills / agents / rules / hooks that actually fit.

## The four phases

### Phase 1 — Read the project

Before asking the user anything, build your own understanding. Read in this order:

1. **`README.md`** (or `README*` variants) — the user's own framing of what this is.
2. **`package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / `pom.xml` / etc.** — the stack signal. Note dependencies, scripts, engines.
3. **Top-level directory structure** — `ls` the repo root + one level deep. Look for markers: `app/` `pages/` `src/` `lib/` `modules/` `ios/` `android/` `infra/` `docs/`.
4. **Existing `CLAUDE.md` or `AGENTS.md`** if present — codified conventions; respect them.
5. **Recent commit messages** — `git log --oneline -30` — what kinds of changes does this repo see? "fix:" prefixes hint at recurring bug classes; "refactor:" prefixes hint at architectural concerns.
6. **One representative source file per major module** — read just enough to understand the language idioms, framework conventions, naming.

Take notes mentally. You're going to use this to (a) write better interview questions, (b) author artifacts that reference the project's actual code, not generic placeholders.

### Phase 2 — Interview the user

Open `interview.md` (same skill directory) for the question flow. The interview is **adaptive**, not a fixed script: skip questions whose answer is already obvious from Phase 1, dig deeper on questions where the answer surprises you.

Goal of the interview: surface what you cannot derive from reading the code.
- The user's **goals** for the AI-collaboration workflow (catching specific failure modes, enforcing specific discipline, etc.)
- Past **bugs / incidents** that should never recur
- **Conventions** that aren't documented anywhere in the repo
- The **bar** the user holds (Apple-iOS-26-and-Telegram parity? "ship faster"? "no regressions"?)
- Constraints: solo dev vs team? Open source vs proprietary? Customer-facing vs internal tool?

### Phase 3 — Decide what to author

Based on Phase 1 + 2, decide **which artifact classes apply** to this project. Not every project needs every artifact. Use the matrix in the next section to decide. Then, for each applicable class, read the corresponding `principles/<class>.md` to learn how to author it. The principles docs are NOT templates — they teach you the methodology. You author the final artifact from the project's actual code + the user's actual answers.

### Phase 4 — Author + present + commit

Write artifacts to a staging directory first: `.claude-staging/`. Then walk the user through what you wrote, explaining the reasoning ("I added a code-reviewer with these project-specific anti-patterns because I saw <X> in your codebase"). When the user approves, move from `.claude-staging/` to `.claude/` and commit.

Never write to `.claude/` directly until the user has explicitly approved the staging output.

## Artifact-class applicability matrix

Use this to decide what to author. Each row is one principle doc to read.

| Class | Read when project has… | Skip when… |
|---|---|---|
| `code-review.md` | Any code at all | Truly throwaway prototype |
| `pre-flight.md` | Multi-module / multi-file changes are common | Single-file utility |
| `file-discipline.md` | Long files exist OR will appear | Auto-generated code only |
| `decomposition.md` | Pair with file-discipline | Same as file-discipline |
| `ux-audit.md` | UI surfaces (web / mobile / desktop) | Backend / CLI / lib |
| `a11y-audit.md` | User-facing UI | Backend / CLI / lib |
| `interaction-audit.md` | Multi-element UI screens (forms, dashboards) | Single-element UI |
| `design-token-audit.md` | Design system / theme tokens / Tailwind config exists | No design system |
| `visual-verification.md` | UI changes happen | Same as ux-audit |
| `pages-audit.md` | Multi-tab / multi-section primary surface | Single-page app or no UI |
| `journey-mapping.md` | Multi-step user flows exist | Single-screen interaction model |
| `element-reuse.md` | Component library or string catalog exists | Greenfield project |
| `quality-rubric.md` | Project has a quality bar to hold | "Just ship it" mentality is explicit |
| `design-benchmarking.md` | Project has named design references | No external benchmark culture |
| `forbidden-phrases.md` | Project has voice / tone / brand discipline | Library / tool with no human-facing copy |
| `flow-audit.md` | Multi-screen arcs (onboarding, checkout, wizard) | Single-screen app |
| `persona-testing.md` | Customer-facing product | Internal tool / open-source lib |
| `data-integrity.md` | Database / persistent state | Stateless app |
| `database-query-discipline.md` | DB reads happen via LLM-callable tools (MCP / BI) | No such tooling |
| `migration-create.md` | Schema migrations are part of dev flow | No DB or no migrations |
| `ai-cost-monitoring.md` | AI / LLM workflows in production OR dev | No AI usage |
| `test-architect.md` | Tests exist or should exist | Pure exploration code |
| `skill-vs-code-audit.md` | Skill docs may drift from code | Single-file project |
| `audit-routing.md` | Multiple audit agents will coexist | Only 1-2 agents total |

## Hooks — the only true templates

The 12 shell-script hooks in `hook-templates/` ARE genuinely project-agnostic (they're tiny bash guards). For these, you DO substitute config values into the template and write the result to `.claude/hooks/`. Each hook template has a heading explaining its config — read the file, ask the user about the config (file size ceiling? forbidden phrase list? import boundary rules?), substitute, write.

For everything else (skills / agents / rules), do NOT substitute — author fresh.

## Examples — for inspiration, NOT copying

`examples/` contains four war stories — real anonymized debugging narratives. Read them so you understand the KIND of bug each artifact class is meant to catch. When you author the user's artifacts, derive your examples from the user's own codebase, not from the war stories. The war stories are training data; they are not output.

You may, however, optionally include a `docs/war-stories/` directory in the user's `.claude/`-adjacent docs if the user wants to start their own. Ask before doing this.

## Non-negotiable rules

1. **Read before asking.** A question whose answer is obvious from `package.json` is a wasted question.
2. **Author, do not copy.** Every artifact you write should reference the user's actual code paths, conventions, and failure modes — not generic templates.
3. **Stage, then commit.** Never write to `.claude/` directly. Always go through `.claude-staging/` and get user approval first.
4. **Explain reasoning.** When you present the staged output, walk through "I picked these artifacts because…" and "I tuned them this way because…". If the user can't trace your reasoning, they can't trust the output.
5. **Pick a small set.** A focused `.claude/` with 5 well-tuned artifacts beats a sprawling 25-artifact kit. Resist the urge to be comprehensive.
6. **Respect existing `CLAUDE.md`.** If the user already has one, your artifacts must align with its conventions, not contradict them.
7. **When in doubt, ask the user, don't guess.** This skill produces project-DNA-level work; getting it wrong is more costly than asking one extra question.

## Output format

After Phase 4 completes successfully, output a summary block:

```
✓ dotclaude:init complete

Authored in .claude/:
  - <N> agents:  <list>
  - <N> skills:  <list>
  - <N> rules:   <list>
  - <N> hooks:   <list>

Skipped (not applicable to this project): <list with one-line reason each>

Recommended next steps:
  1. <e.g. "Add forbidden-phrases list to .claude/rules/forbidden-phrases.txt — the hook is wired but the list is empty">
  2. <e.g. "Run /dotclaude:init again in 4 weeks to refresh as the project grows">

Commit the staged .claude/ when ready.
```
