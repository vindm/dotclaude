# code-review — designing a post-implementation review agent for ANY project

This is teaching material for Claude Code. When the user runs `/dotclaude:init`, you read this doc to learn HOW to author a code-review agent that fits THEIR project. You do not copy examples from this doc into the user's `.claude/`. You read the user's code, learn ITS failure modes, and write fresh anti-patterns derived from what you observe.

## When to ship one (applicability gate)

Ship a code-review agent when **any** of the following hold:

- The project has multi-file commits regularly (look at `git log --oneline --stat | head -50` — if the median commit touches 3+ files, this applies).
- The project crosses runtime boundaries (UI ↔ API, app ↔ native, app ↔ DB, app ↔ external service).
- The project has more than one engineer touching it (review is the cheapest channel for shared standards).
- The project has had at least one "silent failure" or "parallel-path bug" in its history.

Skip when the project is a throwaway prototype, a single-file utility, or pure exploration where review friction would dominate the dev loop. If unclear, ask the user: *"Have you ever had a bug where two code paths drifted apart and produced inconsistent behavior?"* If the answer is yes, ship the agent.

## Why it matters — what this catches that nothing else does

Linters and type-checkers operate on **one file at a time** and on **syntactic / typing rules**. They do not catch:

- **Parallel-path drift**: two code paths that update the same table / call the same API / handle the same event, where one has guards the other lacks. The bug ships because each file in isolation looks fine.
- **Trust-boundary no-ops**: writes that succeed-shaped but no-op silently (see `../examples/the-write-that-returned-success.md`).
- **Cascade-through-valid bugs**: a bad value enters the system five layers earlier and propagates through valid-shaped operations until something finally asserts on it (see `../examples/the-bug-surfaced-five-screens-later.md`).
- **Cache invalidation gaps**: a mutation updates state X but forgets to invalidate query keys Y and Z that read the same data.
- **Implicit guarantees**: comments saying "this function never returns null" while the code does, in fact, sometimes return null.

A code-review agent's value is precisely in this gap. It is not a style checker. It is a **senior-engineer second pair of eyes** that grep-traces the change and reports gaps that a careful per-file review would still miss.

## Core methodology (apply universally)

The agent should run five phases, in order, on every change. The labels stay constant across projects; the specifics fill in from the project's code.

### Phase 1 — Understand the change

The agent reads `git diff --stat` and `git diff`, then for each touched file reads enough surrounding context to know the function's intent. It writes down the *purpose* of the change in one sentence before evaluating anything. If it can't, the agent flags that as a finding (unclear intent is a review blocker).

### Phase 2 — Blast-radius analysis

For every changed function, hook, type, table, or constant, the agent greps for:
- Direct callers / importers
- Other files referencing the same identifier
- Sibling modules touching the same external resource (table, endpoint, file)

The output is a dependency graph: *who depends on this change?* This is the cheapest, highest-leverage step. Skip it and parallel-path bugs are invisible.

### Phase 3 — Parallel-path detection

For every operation the changed code performs (a write, a call, a job enqueue, a cache invalidation), the agent searches for OTHER code paths performing the same operation. For each parallel path found, it asks: *will the new code maintain the same guarantees as this existing path?*

Concrete red flags the agent looks for:
- Two paths writing the same table with different field sets
- Two paths with different filtering logic on the same query
- One path handles errors, the other swallows them
- One path invalidates caches, the other forgets
- One path retries, the other gives up after first failure
- Conditional logic in one place that the parallel path doesn't share

This is the agent's signature move. If it produces no other value, parallel-path detection alone justifies its cost.

### Phase 4 — Consistency checks

The agent walks a fixed checklist (project-specific — see "How to derive THIS project's specifics" below). Examples of universal categories:
- Data-flow consistency (required fields, cache invalidation, error handling)
- Error-handling consistency (does the error type propagate correctly?)
- Type-safety (any `as unknown as` / `any` / unchecked casts?)
- Trust-boundary checks (writes against permission-scoped resources verified?)

### Phase 5 — Produce a graded report

Single overall grade (S/A/B/C/D/F — anchors below) plus structured sections: critical issues that block merge, warnings to fix, parallel-path analysis, suggestions, what's done well.

## How to derive THIS project's specifics

Before authoring the agent file, audit the codebase to find what classes of bug actually recur. Sources of signal, in order:

1. **`git log --grep="fix:" --oneline -100`** — fix-prefixed commits name the bugs. Read the diffs of the 10 most recent. Look for repeated patterns: same module, same kind of mistake, same forgotten step. Each repeated pattern is a candidate anti-pattern entry.

2. **`git log --grep="revert" --oneline -50`** — reverts mark shipped bugs that escaped review. These are usually the *most expensive* bugs (already deployed before caught). The pattern behind a revert is the highest-priority anti-pattern.

3. **Most-edited files** — `git log --format=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn | head -20`. The top of this list is where the project's complexity concentrates. Read 2-3 of them. The coupling patterns visible there are the parallel-path traps to encode.

4. **Existing convention docs** — `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `docs/architecture.md`. If the user has written down rules, encode the ones whose violation is mechanically grep-able.

5. **Stack-shape mapping** — based on the dependencies in `package.json` / `Cargo.toml` / etc., identify the typical failure modes for THIS stack:
   - React / RN / Expo: stale closures in refs, cache invalidation gaps, native-bridge data loss
   - Backend APIs (Express / Fastify / Nest / FastAPI / Rails): missing transactions, RLS no-ops, swallowed promise rejections
   - SQL / Prisma / Drizzle: missing `WITH CHECK`, silent type coercion, N+1 queries
   - Go services: missing `defer`, unchecked errors, goroutine leaks
   - Rust crates: panic-vs-Result drift, `unwrap()` in non-test code, missing trait bounds
   - CLI tools: stdin EOF handling, signal trapping, exit-code discipline
   - Build tooling / monorepos: workspace boundary violations, hoisted-dep accidents

   These are **guidance for where to look**, not the answer. The answer comes from the project's actual code, not from a stack stereotype.

6. **Direct user-interview signal** — ask: *"Tell me about the last bug you wished a reviewer had caught. What was the underlying mistake?"* The user's answer often surfaces a pattern that's not yet visible in the git log.

## Authoring the agent's anti-pattern section

The final agent will have a section labeled something like "Known Anti-Patterns (Project-Specific)" with 5-10 entries. Each entry should:

- **Cite a real file:line** from this project's code where the pattern appeared (or where the safe pattern lives, for contrast).
- **Reference a real past bug** from git history if you can find one (`fix: ` commit message + short SHA).
- **Be specific enough that the agent can grep for the bad pattern** — abstract entries like "be careful with async" are useless; entries like "any `useCallback` that closes over `useState` values and returns them — must use refs" are actionable.
- **NOT be copied** from this principle doc, from another project's list, or from your training data.

If you have fewer than 5 patterns the project actually exhibits, write fewer. A short, accurate list beats a padded list. Quality of entries is the quality of the agent.

## Rubric (universal S/A/B/C/D/F)

The grade is a single letter on the overall change. Anchors:

| Grade | Meaning |
|-------|---------|
| **S** | Bulletproof. All parallel paths consistent. Edge cases handled. Tests cover the change. Nothing the reviewer would add. |
| **A** | Solid. No bugs found. Minor stylistic / readability suggestions only. |
| **B** | Good but has gaps. Missing one or two checks (error handling on a branch, partial cache invalidation, one parallel path not fully aligned). Not blocking, should fix. |
| **C** | Concerning. A parallel-path inconsistency exists, or a guarantee is missing that the rest of the codebase upholds. Reviewer can imagine a scenario where this misbehaves. |
| **D** | Risky. A logic bug or data-integrity gap was found. Will misbehave under realistic input. |
| **F** | Dangerous. Will silently corrupt data, drop writes, or cause cascading failure in production. Block merge. |

Tune the anchors to project-specific stakes if the project's stakes call for it (e.g., a financial system might collapse C/D into a single "block merge" tier).

## Report format (universal shape)

```markdown
## Code Review: <one-line description of the change>

### Overall Grade: <S/A/B/C/D/F>

<one-paragraph summary of what changed and the headline finding>

### Blast Radius
- <N> files directly changed
- <N> callers / importers affected
- <N> parallel code paths inspected

### Critical Issues (blocks merge)
<each: file:line, what's wrong, concrete fix>

### Warnings (should fix)
<each: file:line, risk, suggested fix>

### Parallel Path Analysis
| Path | File | Consistent with this change? | Gap |
|---|---|---|---|

### Suggestions (nice to have)
<polish / naming / structure>

### What's Done Well
<acknowledge solid patterns worth replicating>
```

The agent should always include "what's done well." Pure-negative reviews train against shipping; reviews that name what's working calibrate the team on the bar.

## Cross-references

- `pre-flight.md` — the pre-implementation companion. Run `pre-flight` before writing code; run `code-review` after. They share the parallel-path methodology but operate at different points in the loop.
- `test-architect.md` — when code review surfaces "missing test coverage," route to test-architect for the design.
- `data-integrity.md` — when code review surfaces a write-path concern on persistent state, the data-integrity agent does the deeper sweep.
- `../examples/the-write-that-returned-success.md` — paradigm example of a bug code-review catches: silent no-op at a trust boundary.
- `../examples/the-bug-surfaced-five-screens-later.md` — paradigm example of cascade-through-valid: code review catches this by tracing the operation back across all entry points, not by debugging the symptom.

## Anti-patterns in the agent you write (mistakes to avoid)

- **Style review.** ESLint, gofmt, rustfmt, ruff, prettier all do this. The agent that re-reviews indentation wastes opus-level model spend on commodity work. Tell the agent explicitly: *do not review style or formatting*.
- **Generic anti-pattern lists.** Entries copied from another project's review agent are noise — they don't match this codebase's actual failure modes. The reviewer will report findings that don't reproduce, and the user will stop trusting the agent.
- **No grading.** Without a grade, reports collapse into "here are some thoughts" — no signal for "should this merge or not?" The S/A/B/C/D/F dimension is what makes the report actionable.
- **Findings without file:line.** "There may be a race somewhere in the handler" is unactionable. Every finding cites a path and line number. If the agent can't pin it down, the finding is a hypothesis, not a finding — mark it as such.
- **Reading the diff without reading the surrounding code.** The diff doesn't show what the function is FOR. The agent that grades a 3-line diff without reading the file it lives in cannot do parallel-path detection. Require: read the changed file, read at least one caller, before grading.
- **Reviewing the whole repo.** The agent reviews **the change**. If the user wants a whole-repo audit, that's a different agent (or a different invocation). Scope discipline.

## Tool surface for the agent

The agent needs: `Read`, `Grep`, `Glob`, `Bash` (for `git diff`, `git log`, file traversal). It does NOT need `Edit` or `Write` — a code reviewer that edits the code is no longer a reviewer. Tool restriction is a structural guarantee that the agent stays in its lane.

Effort: high. Model: the project's most-capable reasoning model. Code review is exactly the workload where the marginal model quality pays off.
