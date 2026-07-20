---
description: Elicit coding hygiene intent for a project and write it to a thin artifact — `.claude/dotclaude/code-anti-patterns.md` plus a few `dotclaude.yml` keys — derived from the project's actual file-size distribution and the bug classes visible in git history. No agent, rule, or hook is authored: the consumed `code-review` agent already reads this artifact at runtime. Invoke /dotclaude:coding in any project root with source code.
---

# `/dotclaude:coding` — coding hygiene elicitation

You are eliciting the project-specific coding-discipline intent for the user's project: the right file-size ceiling and the bug classes a reviewer should specifically watch for. The output is ONE thin artifact — `.claude/dotclaude/code-anti-patterns.md` — plus a handful of keys in `dotclaude.yml`. You do **not** author an agent, a rule file, or a hook: the consumed `code-review` agent (shipped by the plugin — see `agents/code-review.md`) already reads `dotclaude.yml`'s `artifacts.code-anti-patterns` path at runtime, falls back to its own generic methodology when the artifact is absent, and grades new changes against each entry in addition to the generic pass when it's present (full contract: `../../docs/artifact-contract.md`).

This is the layer the user wants set up FIRST on any project — the elicitation is cheap, and the consumed `code-review` agent is useful even with an empty artifact. The companion `/dotclaude:testing` setup layers on top for test discipline, and the separate **dotclaude-design** plugin covers design / UX / a11y discipline for projects with a human-facing surface.

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

Build mental model of: what stack, what the right file ceiling is, what bug classes recur.

## Phase 2 — Interview

Open `interview.md` (same directory). 4-5 questions. Adaptive — skip what Phase 1 already answered. The most important questions:

- **File ceiling** — propose the number you derived from Phase 1; confirm or adjust.
- **Past bug classes** — for project-specific anti-patterns the reviewer should catch.
- **Existing conventions** — anything in `CLAUDE.md` or contributing docs the artifact must respect.

## Phase 3 — Write the artifact

After the interview, write ONLY the elicited human intent. Nothing in this phase authors an agent, a rule file, a skill, or a hook — the consumed `code-review` agent already carries the review methodology (five-phase analysis, tool restrictions, S/A/B/C/D/F rubric, report format) and reads what you write here at runtime. Do NOT author a `code-review.md` (or `code-reviewer.md`) agent copy — that would duplicate the consumed agent and drift the moment either side changes.

### 1. `.claude/dotclaude/code-anti-patterns.md`

One entry per bug class surfaced in interview C3, cross-checked against the fix-prefix commits read in Phase 1. Each entry names the bug shape in plain language, the real file:line + short-SHA it maps to, and — where an obvious one exists — a grep-able pattern:

```markdown
# Code anti-patterns

Project-specific bug classes the `code-review` agent checks new changes
against, in addition to its generic methodology.

## <short name, e.g. "cache invalidation on the write path">
- **Shape:** <what goes wrong, one or two sentences>
- **Seen in:** `<path/to/file.ts:142>` (`<short-sha>`)
- **Watch for:** <grep-able pattern, if one exists>
```

5-10 entries is the useful range — a curated list of real, project-specific failure modes, not a generic checklist (the generic case is already covered by the consumed agent's `principles/code-review.md`). If interview C2 surfaced a register preference (colleague vs. staff-engineer tone), add one line near the top — `**Register:** <colleague / staff-engineer>` — as a note the agent can read, not an instruction to regenerate its rubric.

If the project has fewer than 2-3 real bug classes to report (a young project, or C3 came up empty), it's fine to ship a short artifact or skip it entirely — log the skip and why, rather than padding with generic patterns. A thin, honest artifact beats a padded one.

### 2. `dotclaude.yml` — file-size ceiling + artifact path

Record the ceiling from C1 (and any exemption globs the project needs — generated files, vendored code, wide config objects) plus the `artifacts.code-anti-patterns` path so `code-review` can locate the file without a hardcoded convention:

```yaml
fileSize:
  ceiling: <N>
  warn: <M>
  exempt:
    - "**/*.generated.*"
    - "**/*.types.ts"

artifacts:
  code-anti-patterns: .claude/dotclaude/code-anti-patterns.md
```

Merge into an existing `dotclaude.yml` if one already exists (from `/dotclaude:bootstrap` or another domain elicitation) — never overwrite unrelated keys.

### Present + confirm

Show the drafted `code-anti-patterns.md` and the `dotclaude.yml` diff. Walk through 2-3 concrete entries with real reasoning — "I mapped the cache-invalidation bug you named to `src/cache.ts:88`, seen in `a1b2c3d`; the reviewer will now grade against it" — and note anything skipped and why. Wait for explicit confirmation before writing. This is a two-file change, not a multi-file kit, so no `.claude-staging/` review pass is needed: write directly to `.claude/dotclaude/code-anti-patterns.md` and merge into `dotclaude.yml` on approval.

## Non-negotiable rules for this flow

1. **Derive anti-patterns from git + the user's own words, never invent generic ones.** If an entry could apply to any codebase ("watch for stale closures"), it doesn't belong here — the consumed agent's `principles/code-review.md` already covers the generic case. Every entry cites a real file:line and, where possible, a short-SHA.

2. **Calibrate the ceiling against the codebase, not stack defaults.** A 1000 LOC default on a project where the 95th percentile is 320 LOC never fires — pick a number where the warning threshold catches drift. Don't pick a number the codebase already routinely violates; the ceiling stops being trusted the moment it's decorative.

3. **Do NOT author an agent, a rule, or a hook.** The consumed `code-review` agent already owns the reviewer methodology, the tool restrictions, and the rubric. Writing a project-local `code-review.md` copy — or a `file-discipline.md` rule, or a hook script — duplicates what the plugin already ships and creates drift the moment either side changes. If a project genuinely needs to override the consumed agent's behavior, that's a deliberate same-name shadow, not this skill's default output.

4. **Show, don't tell.** When presenting the artifact, quote at least one real entry so the user sees the level of specificity before approving. If every entry reads generic, the interview didn't extract enough — go back to C3.

## See also

- `interview.md` — the short interview (C1 ceiling, C2 optional register note, C3 bug classes, C4 existing conventions).
- `../../docs/artifact-contract.md` — the full elicit → artifact → consumed-agent contract.
- `../../agents/code-review.md` — the consumed agent that reads `code-anti-patterns.md` at runtime.
