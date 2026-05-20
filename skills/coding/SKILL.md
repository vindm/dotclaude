---
description: Set up coding hygiene + voice discipline for a project. Authors a tailored kit of code-review agent, decomposition skill, file-size + voice rules, and edit-time hooks — derived from the project's stack, its actual file-size distribution, the bug classes visible in git history, and any project-specific voice. Invoke /dotclaude:coding in any project root with source code.
---

# `/dotclaude:coding` — coding hygiene + voice discipline kit

You are setting up the universally-applicable coding-discipline layer for the user's project. The output is a `.claude/` subset focused on what every project benefits from regardless of stack: post-implementation review, file-size ceilings, decomposition, voice / AI-slop guards, and the edit-time hooks that enforce them.

This is the layer the user wants set up FIRST on any project. The other domain skills (`/dotclaude:design`, `/dotclaude:data`, `/dotclaude:testing`, `/dotclaude:ai-workflow`) layer on top.

## Phase 1 — Read the project's code shape

Before any question:

1. **Stack signal** — read whichever exists:
   ```bash
   cat package.json 2>/dev/null
   cat Cargo.toml 2>/dev/null
   cat pyproject.toml 2>/dev/null
   cat go.mod 2>/dev/null
   ```
   The dependencies + scripts disclose: language, framework, runtime, test runner, lint setup.

2. **File-size distribution** — find the worst offenders:
   ```bash
   find . -path ./node_modules -prune -o -path ./.git -prune -o \
     \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" \
        -o -name "*.rs" -o -name "*.go" -o -name "*.swift" -o -name "*.kt" \) \
     -print 2>/dev/null | xargs wc -l 2>/dev/null | sort -rn | head -20
   ```
   The top of this list calibrates the right ceiling: pick at the 95th percentile of *healthy* files + a buffer. A 1500-line outlier doesn't justify a 1500 LOC ceiling — it justifies decomposing the outlier.

3. **Bug-class signal from git history** — the project's actual failure modes:
   ```bash
   git log --oneline --grep="^fix" -30
   git log --oneline --grep="revert" -20
   git log --oneline --grep="rollback" -20
   git log --format=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn | head -20
   ```
   The fix-prefixed commits name the bugs; the top-edited files name where complexity concentrates. Read 5-10 of the fix commits' diffs — these are the patterns the project's reviewer should catch.

4. **Existing conventions** — read each that exists:
   - `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `STYLE_GUIDE.md`
   - The project's lint config (`.eslintrc*`, `ruff.toml`, `clippy.toml`)
   - Any `docs/architecture.md` or sub-module READMEs

5. **Voice signal** — does any user-facing copy exist?
   ```bash
   find . -path ./node_modules -prune -o \
     \( -name "translations.*" -o -name "copy.*" -o -name "*.locale.*" \
        -o -path "*/i18n/*" -o -path "*/translations/*" -o -path "*/copy/*" \) \
     -print 2>/dev/null | head -20
   grep -rE "amazing|awesome|love|exciting|!" --include="*.ts" \
     <copy-dir> 2>/dev/null | head -20
   ```
   If voice files exist, the project may want the forbidden-phrases guard. If only error-message strings exist, voice is probably out of scope.

Build mental model of: what stack, what the right file ceiling is, what bug classes recur, whether voice discipline applies.

## Phase 2 — Interview

Open `interview.md` (same directory). 4-5 questions. Adaptive — skip what Phase 1 already answered. The most important questions:

- **File ceiling** — propose the number you derived from Phase 1; confirm or adjust.
- **Past bug classes** — for project-specific anti-patterns the reviewer should catch.
- **Voice / brand phrases** — only if the project has user-facing copy.
- **Existing conventions** — anything in `CLAUDE.md` or contributing docs the kit must respect.

## Phase 3 — Read the principles

Read these from `../../principles/` SELECTIVELY:

**Always read** (universal coding discipline):
- `code-review.md` — the post-impl reviewer methodology + how to derive project anti-patterns
- `file-discipline.md` — picking the ceiling + override convention
- `decomposition.md` — the natural-seam doctrine for the decompose-file skill
- `quality-rubric.md` — the S/A/B/C/D anchors the review report uses

**Read if multi-module project**:
- `pre-flight.md` — the lightweight version (full pre-flight discipline ships separately via `/dotclaude:planning`). Cross-reference from the reviewer.

**Read if voice / brand applies**:
- `forbidden-phrases.md` — voice deny-list authoring

**Read if `.claude/` will have 3+ docs with code references**:
- `skill-vs-code-audit.md` — the doc-drift meta-auditor

**Read the war-story examples** (the reviewer's anti-patterns should reference them):
- `../examples/the-write-that-returned-success.md`
- `../examples/the-bug-surfaced-five-screens-later.md`
- `../examples/the-test-passed-for-the-wrong-reason.md`

## Phase 4 — Author the kit

Based on what applied + the interview answers, author these in `.claude-staging/`. Every artifact must cite THIS project's actual code paths, name THIS project's actual bug classes from git history, mirror THIS project's conventions.

### Agents (in `.claude-staging/agents/`)

- **`code-reviewer.md`** — the post-impl reviewer
  - Frontmatter: `description:` — derived from `code-review.md` principle, tuned to THE user's stack
  - Tool surface: `Read, Grep, Glob, Bash` (NO `Edit`, NO `Write` — reviewer that edits is no longer a reviewer)
  - Body sections:
    - The five-phase methodology (understand / blast-radius / parallel-path / consistency / report)
    - "Known anti-patterns (project-specific)" — **5-10 entries derived from the fix-prefix commits you read in Phase 1**. Each entry: a real file:line + a short SHA reference + grep-able pattern. NOT generic patterns copied from the principle doc.
    - The S/A/B/C/D/F rubric tuned to the project's stakes (financial project → collapse C/D to "block"; exploration → looser thresholds)
    - The report-format template
    - Tool restriction explicit: "I do not edit. I report."
  - Model: the project's most-capable reasoning model. Code review pays off most on the marginal model quality.

- **`skill-auditor.md`** (only if the user expects to ship 3+ docs / skills / agents referencing specific code paths)
  - The doc-drift agent from `skill-vs-code-audit.md` — five-step process (inventory / extract / verify / undocumented-additions / report)
  - Glob scope: `.claude/**/*.md` by default; let the user extend
  - Model: lightweight (haiku-class). Mechanical grep work; reasoning overhead low.

### Skills (in `.claude-staging/skills/`)

- **`decompose-file/SKILL.md`** — user-invocable (`/decompose-file <path>`), `disable-model-invocation: true`
  - The four-step workflow (read+classify / propose-split / approve / execute+verify)
  - The extraction-pattern table SCOPED TO THIS PROJECT'S STACK and mirroring conventions you observed in Phase 1 (if pure helpers live in `lib/utils/`, the table says `lib/utils/`)
  - Approval gate explicit — propose the split, wait for user "ok," then execute
  - Anti-patterns: barrel files, 5-LOC micro-files, split-for-line-count

- **`quality-bar/SKILL.md`** — the operational definition of "done"
  - Demo test with a SPECIFIC audience the user named in the interview
  - 5-tier rubric with project-specific reference anchors
  - 5 named composition pitfalls drawn from the project's actual bug history (NOT copied from `quality-rubric.md`)
  - Fast vs careful split — concrete examples from THE project's work shapes
  - "Claim of done" checklist (capture / lint / test / benchmark-named)

### Rules (in `.claude-staging/rules/`)

- **`file-discipline.md`** — names the ceiling, the warn threshold, the project's actual auto-generated exemption patterns, the override convention (`// allow-size: <reason>`)
- **`forbidden-phrases.txt`** (only if voice applies — confirmed in interview)
  - Universal AI-slop entries (greeting-as-stranger / self-intro / welcome / customer-service register / filler validation)
  - Project-specific entries the user provided (NOT copied from `forbidden-phrases.md`)
  - Source-of-truth comment pointing at the project's voice doc if one exists
  - Exempt-paths list specific to THIS project (e.g., onboarding wizard, marketing pages)

### Hooks (in `.claude-staging/hooks/` — render from `../../hook-templates/`)

Always wire:
- **`check-file-size.sh`** — substitute `{{fileSize.ceiling}}` + `{{fileSize.warn}}` with the numbers you picked
- **`check-secret-leak.sh`** — universal; no substitution needed
- **`check-bash-safety.sh`** — universal; no substitution needed

Wire conditionally:
- **`check-forbidden-phrases.sh`** (if voice applies) — substitute `{{forbiddenPhrases.phrases}}` and `{{forbiddenPhrases.scopes}}` with the user's actual list + path patterns
- **`check-no-console-log.sh`** (if JS / TS project) — substitute `{{consoleLog.allowPaths}}` with the user's actual test / script paths
- **`check-no-todo-comments.sh`** (if the project enforces ticket discipline) — set `{{todoBlock}}` per user preference

Decline templates that don't fit the stack — e.g., `check-no-console-log.sh` for a Rust project is noise.

## Phase 5 — Stage + present + commit

### Staging

Write everything to `.claude-staging/` first, organized by artifact type.

### Present

Walk the user through:

1. **The kit overview** — list what landed by type (N agents, M skills, K rules, L hooks)
2. **Top 3 highlight artifacts** — concrete reasoning. NOT "I added a code reviewer" but: "I set the file ceiling at 800 LOC — your healthy files top out around 650, and your three outliers (`<path1>`, `<path2>`, `<path3>`) are all decomposition candidates. The hook will warn you at 760." Or: "I derived 7 project-specific anti-patterns from your fix-prefix commits — for example, `<short-sha>` shows the pattern of <X>, so the reviewer now greps for <Y>."
3. **What got SKIPPED** — and why. "Skipped `forbidden-phrases.txt` because no user-facing copy exists yet — recommend re-running this when voice emerges."
4. **Model + token-cost note** — code-reviewer uses the high-tier reasoning model and is the most expensive agent. Skill-auditor (if shipped) uses haiku. Be honest about projected token spend.

### Approve → commit

After explicit user approval, move `.claude-staging/` → `.claude/` and commit with structured message:

```
feat(.claude): coding discipline (dotclaude:coding)

Authored:
- agents:  code-reviewer[, skill-auditor]
- skills:  decompose-file, quality-bar
- rules:   file-discipline[, forbidden-phrases]
- hooks:   check-file-size, check-secret-leak, check-bash-safety[, check-forbidden-phrases, check-no-console-log, check-no-todo-comments]

File-size ceiling: <N> LOC (warn at <M>)
Project-specific anti-patterns: <count>
Voice forbidden phrases: <count or "n/a">
```

## Non-negotiable rules for this flow

1. **Derive anti-patterns from git, not from the principle doc.** The code-reviewer's value is project-specific. If you copy the example anti-patterns from `code-review.md` into the user's agent, you've shipped a generic linter wearing an opus mask. Read the fix-prefix commits, extract the real patterns, cite real file:line + short-SHA references. A reviewer with 5 real patterns is more valuable than one with 20 generic ones.

2. **Calibrate the ceiling against the codebase, not stack defaults.** A 1000 LOC default ceiling on a TS project where the median file is 80 LOC and the 95th percentile is 320 LOC is a useless ceiling — nothing will ever hit it. Pick a number where the warning threshold catches drift, not where it never fires. Don't pick a number the codebase already routinely violates — devs will stop trusting the rule.

3. **Cite real code paths in the reviewer's anti-patterns.** Each anti-pattern entry references a real file in the project. If the reviewer says "watch for stale closures in refs," that's noise. If it says "watch for stale closures like the one fixed in `<sha>` at `src/hooks/usePlayback.ts:142`," the reviewer knows what to look for AND the user knows the entry is legit.

4. **Voice discipline is opt-in.** If the project has no user-facing copy, skip `forbidden-phrases.txt` entirely. A deny-list with only "Hi / Hello / Welcome" on a backend-only library is friction without value. The rule is for projects whose voice matters; the absence is a deliberate skip, with the reason logged in the kit-overview message.

5. **Tool restrictions on the reviewer are structural.** The code-reviewer agent must NOT have `Edit` or `Write` in its tools list. The whole point of separating the reviewer from the implementer is that the reviewer doesn't touch the code. If you add write tools "for convenience," the agent will start fixing what it should be reporting, and the report quality collapses.

6. **Hooks are mandatory companions for rules.** If you ship `file-discipline.md` without wiring `check-file-size.sh`, the rule is decorative. The hook is the teeth. Either ship the rule with the hook, or don't ship the rule. Same applies to forbidden-phrases + its hook.

7. **Match the project's lint convention, don't fight it.** If the project uses ESLint with specific rules disabled, the reviewer shouldn't re-flag those (the user has already decided). Read the lint config before authoring. The reviewer reviews what lint can't see — parallel paths, trust boundaries, cascade-through-valid — NOT what lint already catches.

8. **Show, don't tell.** When presenting the staged output, screenshot or quote one example anti-pattern from the reviewer's body so the user sees the level of project-specific detail. If the detail isn't there, the kit isn't tuned enough yet — go back and tighten.
