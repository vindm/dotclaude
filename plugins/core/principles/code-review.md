# code-review — designing a post-implementation review agent for ANY project

Teaching material for Claude Code. Teaches you how to author a code-review agent that fits THIS project. You don't copy examples from this doc into the user's `.claude/`; you read the user's code, learn its failure modes, and write fresh anti-patterns from what you observe.

## When to ship one

Ship a code-review agent when any of these hold: the project has regular multi-file commits (`git log --oneline --stat | head -50` — median commit touches 3+ files); it crosses runtime boundaries (UI ↔ API, app ↔ native, app ↔ DB, app ↔ external); more than one engineer touches it (review is the cheapest shared-standards channel); or it has had a "silent failure" or "parallel-path bug." Skip for a throwaway prototype, a single-file utility, or pure exploration where review friction dominates the loop. If unclear, ask: *"Have you ever had a bug where two code paths drifted apart and produced inconsistent behavior?"* Yes → ship.

## Why it matters

Linters and type-checkers work one file at a time, on syntactic / typing rules. They miss the bugs that live between files:

- **Parallel-path drift** — two paths update the same table / call the same API / handle the same event, one with guards the other lacks. Each file looks fine in isolation.
- **Trust-boundary no-ops** — a write that returns success-shaped but silently did nothing.
- **Cascade-through-valid** — a bad value enters five layers upstream and propagates through valid-shaped ops until something finally asserts.
- **Cache-invalidation gaps** — a mutation updates state X but forgets to invalidate the keys that read it.
- **Implicit-guarantee violations** — a comment says "never returns null"; the code sometimes does.

The agent's whole value is this gap. It is not a style checker — it's a second pair of eyes that grep-traces the change and reports what a careful per-file review would still miss.

## Core methodology — five phases, in order

Labels stay constant across projects; specifics fill in from the code.

**Phase 1 — Understand the change.** Read `git diff --stat` and `git diff`; for each touched file read enough surrounding code to state the change's purpose in one sentence. If you can't, that unclear intent is itself a finding.

**Phase 2 — Blast-radius analysis.** For every changed function / hook / type / table / constant, grep for direct callers, other references to the identifier, and sibling modules touching the same external resource. Output a "who depends on this" graph. Cheapest, highest-leverage step — skip it and parallel-path bugs are invisible.

**Phase 3 — Parallel-path detection (the signature move).** For every operation the change performs (write, call, job enqueue, cache invalidation), search for OTHER paths doing the same, and ask: will the new code keep the same guarantees? Red flags: two paths writing the same table with different field sets; different filtering on the same query; one handles errors, the other swallows; one invalidates caches, the other forgets; one retries, the other gives up; conditional logic one place the sibling lacks. If the agent produced no other value, this phase alone justifies its cost.

**Phase 4 — Consistency checks.** Walk a fixed, project-specific checklist. Universal categories: data-flow (required fields, cache invalidation, error handling), error-type propagation, type-safety (`as unknown as` / `any` / unchecked casts), trust-boundary (permission-scoped writes actually verified).

**Phase 5 — Graded report.** A single S/A/B/C/D/F grade plus the structured sections below.

## How to derive THIS project's failure modes

Audit the codebase for the bug classes that actually recur, in order of signal:

1. **`git log --grep="fix:" --oneline -100`** — fix commits name the bugs. Read the 10 most recent diffs; repeated patterns (same module, same forgotten step) are candidate anti-pattern entries.
2. **`git log --grep="revert" --oneline -50`** — reverts mark shipped bugs that escaped review, usually the most expensive. The pattern behind a revert is the highest-priority entry.
3. **Most-edited files** — `git log --format=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn | head -20`. The top is where complexity concentrates; read 2-3, encode the coupling traps.
4. **Convention docs** — `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`. Encode any written rule whose violation is grep-able.
5. **Stack-shape mapping** — from the manifest, the typical failure modes for this stack (React/RN: stale ref closures, cache gaps, native-bridge loss · backend: missing transactions, RLS no-ops, swallowed rejections · SQL: missing `WITH CHECK`, silent coercion, N+1 · Go: missing `defer`, unchecked errors · Rust: `unwrap()` in non-test, panic-vs-Result drift · CLI: stdin EOF, signal trapping, exit codes). Guidance for where to look, not the answer — that comes from the project's own code.
6. **User interview** — *"Tell me about the last bug you wished a reviewer had caught. What was the underlying mistake?"* Often surfaces a pattern not yet in the git log.

## Authoring the anti-pattern section

The agent gets a "Known Anti-Patterns (Project-Specific)" section with 5-10 entries. Each one:

- **Cites a real `file:line`** where the pattern appeared (or where the safe pattern lives, for contrast).
- **References a real past bug** from git history where possible (`fix:` message + short SHA).
- **Is grep-able** — *"any `useCallback` that closes over `useState` values and returns them — must use refs,"* not *"be careful with async."*
- **Is NOT copied** from this doc, another project's list, or your training data.

Fewer than 5 real patterns → write fewer. A short accurate list beats a padded one; the quality of the entries is the quality of the agent.

## Rubric (universal S/A/B/C/D/F)

| Grade | Meaning |
|-------|---------|
| **S** | Bulletproof. All parallel paths consistent, edge cases handled, tests cover the change. Nothing to add. |
| **A** | Solid. No bugs; minor readability suggestions only. |
| **B** | Good but gaps — one or two missing checks (error handling on a branch, partial cache invalidation, one path not aligned). Should fix, not blocking. |
| **C** | Concerning. A parallel-path inconsistency, or a guarantee the rest of the codebase upholds is missing here. |
| **D** | Risky. A logic bug or data-integrity gap that will misbehave under realistic input. |
| **F** | Dangerous. Will silently corrupt data, drop writes, or cascade in production. Block merge. |

Tune the anchors to project stakes where warranted (a financial system might collapse C/D into a single block-merge tier).

## Report format (universal shape)

```markdown
## Code Review: <one-line description of the change>

### Overall Grade: <S/A/B/C/D/F>
<one paragraph: what changed + the headline finding>

### Blast Radius
- <N> files changed · <N> callers affected · <N> parallel paths inspected

### Critical Issues (blocks merge)
<each: file:line · what's wrong · concrete fix>

### Warnings (should fix)
<each: file:line · risk · suggested fix>

### Parallel Path Analysis
| Path | File | Consistent with this change? | Gap |
|---|---|---|---|

### Suggestions (nice to have)
### What's Done Well   <-- always include; pure-negative reviews train against shipping>
```

## Commit integrity — verify the staged set landed

When the project runs a pre-commit formatter or `lint-staged`-style hook that re-stages files, the committed set can silently drift from the message: the hook reformats or a glob misses a file, the message claims seven files while one lands, lint passes, tests pass, the message lies — and the drift surfaces days later when a "committed" change turns out missing. Encode one cheap discipline wherever the project commits multi-file changes: **after every multi-file commit, run `git show --stat HEAD`** and confirm the file list matches the message — one command that turns a silent, days-late failure into an immediate one. Recovery is `git reset --soft HEAD~1`, re-stage explicitly, recommit — never a follow-up "oops also this file" commit that splits one logical change across two. Add it as a line item to the `code-review` agent or the Definition-of-Done checklist. Same instinct as parallel-path detection: trust the result less than the intent, and verify they match.

## Acceptance — mistakes in the agent you write

- **Style review.** Linters and formatters own indentation; an agent re-reviewing it wastes top-tier model spend. Tell it explicitly: *do not review style or formatting.*
- **Generic anti-pattern lists.** Entries copied from another project report findings that don't reproduce here; the user stops trusting the agent.
- **No grading.** Without a grade, reports collapse into "here are some thoughts" — no signal for "merge or not." The S/A/B/C/D/F dimension is what makes it actionable.
- **Findings without `file:line`.** "There may be a race somewhere" is unactionable. Pin every finding; if you can't, mark it a hypothesis, not a finding.
- **Grading the diff without reading around it.** The diff doesn't show what the function is FOR. Require: read the changed file and at least one caller before grading.
- **Reviewing the whole repo.** The agent reviews the change. Whole-repo audits are a different invocation. Scope discipline.

## Tool surface

`Read`, `Grep`, `Glob`, `Bash` (for `git diff` / `git log` / traversal). NOT `Edit` or `Write` — a reviewer that edits is no longer a reviewer; the restriction is a structural guarantee it stays in its lane. Effort: high. Model: the project's most-capable reasoning model — code review is exactly where marginal model quality pays off.

## Cross-references

- `pre-flight.md` — the pre-implementation companion. Run `pre-flight` before writing code, `code-review` after; they share the parallel-path methodology at different points in the loop.
- `test-architect.md` — when review surfaces "missing test coverage," route there for the design.
