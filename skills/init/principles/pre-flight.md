# pre-flight — designing a pre-implementation validation agent for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory via `/dotclaude:init`, you read this doc to learn HOW to author a pre-flight agent for the user's project. The examples here are NOT to be copied into their `.claude/`. You derive their pre-flight from their codebase.

## When to ship one (applicability gate)

Ship a pre-flight agent when:

- The project has more than 2–3 modules with real coupling (changes in module A frequently require changes in module B).
- The project has had at least one incident where "we shipped feature X and it broke unrelated thing Y."
- The project has multiple data paths writing the same store, or multiple workers consuming the same queue, or multiple UIs reading the same state.
- Refactors regularly take longer than estimated because hidden coupling surfaces mid-implementation.

Skip when:

- The project is a single-file utility or a flat library where every change is local.
- The user explicitly prefers "code first, refactor when it breaks" — pre-flight friction is wrong for that workflow.
- The codebase is small enough (< 20 files) that the user already holds the integration map in their head.

If unclear, ask the user: *"Has a refactor ever surprised you mid-implementation with hidden coupling? Often, occasionally, or never?"* If "often" or "occasionally," ship pre-flight.

## Why it matters — what this catches that nothing else does

Pre-flight is the answer to a specific failure mode: **you write the code, then discover halfway through that the design is wrong because of something you didn't know about the codebase.** The cost of that discovery — partial work, frustrating roll-back, re-planning under time pressure — is the cost pre-flight prevents.

Code review catches bugs in code that was written. Type-checkers catch type mismatches in code that was written. Pre-flight catches **design mistakes before any code exists**, when the cost of changing direction is one conversation and a deleted plan, not a deleted branch.

The bugs pre-flight catches that nothing else does:

- **Hidden coupling.** A table has a database trigger, an undocumented webhook subscriber, a cron job that polls it. The naive design ignores them; pre-flight surfaces them.
- **Parallel-path proliferation.** The new feature adds path #4 for an operation that already has paths #1, #2, #3 — and each path has subtly different guarantees. Pre-flight forces consistency planning upfront.
- **Cross-boundary data loss.** Native bridge / FFI / IPC / RPC boundaries silently drop data unless every event is wired both directions. Pre-flight does the bridge audit *before* you've committed to a design that requires the wiring.
- **Premature abstraction.** Pre-flight asks "is there an existing pattern to follow?" The answer is often yes, and the user was about to invent a new one.

## Core methodology — five phases

The agent always runs the same five phases. Labels constant across projects; specifics derive from the codebase.

### Phase 1 — Map the territory

Before evaluating the proposed approach, the agent builds its own picture of the existing landscape:

- Read any per-module or per-domain context docs the project has (`CLAUDE.md`, `AGENTS.md`, sub-module READMEs).
- Identify the PRIMARY files the change will touch (named by the user, or inferred from the feature description).
- Read each of those files end-to-end. Map their dependencies via imports / requires / use statements.
- Identify the SECONDARY files — anything that imports the primary files, calls the same functions, or queries the same data.

This is read-only. The agent is not allowed to write anything in this phase. It is building the map it will reason against.

### Phase 2 — Integration-point analysis

For each layer the change interacts with, the agent enumerates the touch points:

- **Data layer.** Tables read / written. Existing queries against those tables. Database triggers. Row-level-security or access policies. Whether a migration is needed.
- **State layer.** Cache keys affected (React Query / SWR / Apollo / TanStack). Store slices involved (Redux / Zustand / Pinia / signals). Invalidation patterns already established for this data.
- **UI / presentation layer.** Screens / routes / components displaying the data. Loading / empty / error states. Real-time subscriptions.
- **Background-work layer.** Job queues / cron / workers / scheduled tasks. Auto-chaining implications. Duplicate-prevention guarantees. Constraints on job-type values (DB enums, application constants).
- **External layer.** Third-party APIs called. Webhooks emitted / consumed. Rate limits or cost ceilings touched.

Not every project has every layer. The agent enumerates only the layers that exist; absent layers go unnamed.

### Phase 3 — Parallel-path inventory

This is the load-bearing phase. The agent lists EVERY existing code path that performs a similar operation, then asks whether the new path will maintain the same guarantees.

For each operation the new feature will perform:
1. Grep for the function / table / endpoint it touches.
2. List every existing caller and every alternative implementation.
3. For each existing path, document its guarantees (retries, error handling, cache invalidation, ordering, idempotence).
4. Flag any guarantee that the new path will not maintain — that's the consistency gap to resolve.

The output of this phase is a table the agent can hand the implementer. Without this table, parallel-path drift is shipped silently.

### Phase 3B — Cross-boundary verification (when applicable)

When the change touches a runtime boundary — native bridge (RN / Expo modules), FFI (Rust ↔ C, Python ↔ Rust), IPC (Electron main ↔ renderer, parent process ↔ worker), RPC (gRPC / tRPC / GraphQL clients), serialization (queue messages, websocket frames) — the agent performs a bridge audit:

1. List every event / message / call that crosses the boundary in this direction.
2. For each: trace from sender → boundary → receiver → state-or-side-effect.
3. Verify that the event fires on every meaningful change, not only on cleanup.
4. Verify that the receiver updates both the canonical store AND any mirror it maintains (ref + state pattern in React, mutex-guarded shared state in Rust, etc.).
5. Verify any async setup completes before the operation depending on it runs.
6. Flag any event that fires data the receiver never reads — silent data loss.

Cross-boundary silent data loss is one of the most expensive bug classes because the typical signature is "feature works in dev with one path, fails in prod when the second path activates." Pre-flight is the only realistic place to catch it before the user does.

### Phase 4 — Risk assessment

For each integration point and parallel-path gap surfaced, the agent rates risk on two axes — likelihood (low / med / high) and impact (low / med / high) — and lists the mitigation. The mitigations form the "what the implementer must do" section of the report.

Risk categories the agent should consider, in order of typical importance:

- **Data corruption.** Could the change write incorrect / inconsistent data? Leave orphans? Violate invariants?
- **Silent failure.** Could the change fail in a way nobody notices? (See `../examples/the-write-that-returned-success.md`.)
- **Inconsistency.** Could parallel paths produce different results after the change?
- **Performance.** N+1, missing indexes, render storms, cache pressure, queue depth.
- **Migration / rollback.** Is the DB / schema change reversible? Does it handle existing data? What's the rollback if the deploy fails halfway?

### Phase 5 — Recommendation

The agent produces a recommendation: *Clear for Takeoff*, *Caution*, or *Abort*. Anchors:

- **Clear for Takeoff** — all integration points mapped and low-risk. Parallel paths identified, consistency plan obvious. Existing patterns cover the use case; the implementer just follows them. Migration (if any) is additive-only.
- **Caution** — some medium-risk integration points. Parallel paths exist but require careful consistency wiring. Migration touches existing data. Pattern doesn't fully cover; some new shape is needed.
- **Abort** — high risk of data corruption or silent failure. Parallel paths too numerous or too divergent. Migration destructive or irreversible. The proposed approach fights the existing architecture and needs redesign before any code is written.

Along with the recommendation, the agent emits an implementation plan: ordered steps, exact files to modify, patterns to follow (point to specific existing code as the template), patterns to avoid (anti-patterns that would be tempting but wrong), tests needed, migration order if applicable.

## How to derive THIS project's specifics

Before authoring the agent, gather signal on what kinds of pre-flight blunders this codebase has actually suffered. Sources:

1. **`git log --grep="revert"` and `git log --grep="rollback"`** — these are the design mistakes that shipped. The pattern behind the revert is the pre-flight gap that wasn't caught.

2. **Architecture-doc gaps.** Look for `docs/architecture.md`, `docs/design/`, sub-module READMEs. Wherever a doc says "this used to be X, we changed it because Y" — that's a real lesson, and pre-flight should be primed to surface the kind of consideration that motivated the change.

3. **PRs that grew during review.** `git log --merges` then look at the diff sizes. The merges where the PR doubled in size mid-review are the cases where pre-flight would have caught the missing scope upfront.

4. **Stack-specific cross-boundary surfaces.** Identify which boundaries exist in this project:
   - React Native / Expo: JS ↔ native modules (Swift / Kotlin)
   - Web: server-render ↔ hydration, service-worker ↔ page
   - Electron / Tauri: main ↔ renderer, IPC channels
   - Microservices: HTTP / gRPC / message queue boundaries
   - WebAssembly: host ↔ wasm linear-memory marshaling
   - FFI: Rust ↔ C, Python ↔ native extensions
   - Worker threads: main ↔ worker postMessage
   These are the places where Phase 3B applies. Encode the specific surfaces this project has.

5. **User-interview signal.** Ask: *"Have you ever started a refactor, gotten 80% in, then realized you missed something fundamental? What was it?"* The answer names a Phase-2 or Phase-3 gap the agent should now check for.

## Authoring the agent's surface map

The agent file will have an "Integration Points" section enumerating the layers this project has. Concretely, the user's pre-flight agent should know:

- Names of the data stores it should check (their actual table / collection names)
- Names of the queue / job systems if any (the project's actual job-type constants)
- Names of cache / store slices (the actual query-key prefixes, the actual store slice names)
- Names of boundary surfaces (the actual native module names, the actual IPC channel names)

Do NOT write these as placeholders ("TABLES_HERE"). The agent should reference real names from the codebase so its grep instructions are concrete.

## Report format (universal shape)

```markdown
## Pre-Flight Report: <feature name>

### Status: <Clear for Takeoff / Caution / Abort>

<one-paragraph assessment>

### Territory Map
| Module | Files affected | Risk level |
|---|---|---|

### Integration Points
| Point | Layer (data / state / UI / jobs / external) | Risk | Notes |
|---|---|---|---|

### Parallel Paths
| Operation | Existing paths | New path consistent? |
|---|---|---|

### Risk Matrix
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|

### Recommended Implementation Plan
<numbered steps with file:line references where possible>

### Do NOT
<specific mistakes to avoid, with reasoning>

### Open Questions
<things the implementer should clarify before starting>
```

## Cross-references

- `code-review.md` — the post-implementation companion. Pre-flight catches design gaps; code-review catches implementation gaps. They share the parallel-path methodology.
- `migration-create.md` — when pre-flight flags a migration in scope, that's where the migration discipline lives.
- `data-integrity.md` — when pre-flight surfaces concerns about persistent-state writes.
- `../examples/the-test-passed-for-the-wrong-reason.md` — a canonical case where pre-flight's "list every entry point" question would have caught the bug.
- `../examples/the-write-that-returned-success.md` — pre-flight's "trust boundary" question is the question that catches RLS no-ops.

## Anti-patterns in the agent you write (mistakes to avoid)

- **Recommending architecture from file names alone.** The agent that says "looks like you have a jobs system, just add a new job type" without reading the existing jobs code is guessing. Require the agent to READ before it recommends.

- **Generic boundary checklists.** The agent has no value if its Phase 3B reads "verify the native bridge is wired correctly." It needs to know THIS project's bridge events by name. Stack-stereotype checklists are wasted opus tokens.

- **Recommending the most clever approach.** Pre-flight is biased toward "follow the existing pattern" and against "introduce a new abstraction." The decision framework should explicitly prefer the boring path. Three lines of code that match the existing style is the best outcome; a clever abstraction that adds a new pattern is, by default, suspect.

- **Producing recommendations without "Do NOT" entries.** The "Do NOT" section is often more valuable than the "do" section. The implementer is going to be tempted by some shape that looks right but isn't — pre-flight's job is to name that temptation explicitly.

- **Stopping at the first risk found.** Pre-flight is exhaustive. If the agent finds one critical risk and immediately recommends Abort without enumerating the rest, the implementer learns one thing instead of the full picture.

- **Not flagging unknowns.** If the agent searched for a pattern and couldn't find it, it should SAY SO ("I searched for cache invalidation patterns for table X and couldn't find any — verify"). A confident "all clear" based on incomplete search is worse than a "here's what I couldn't verify."

## Tool surface for the agent

The agent needs read-only access: `Read`, `Grep`, `Glob`, `Bash` (for `git log`, `git grep`, directory traversal). It does NOT need `Edit` or `Write` — pre-flight is analysis, not implementation. The structural guarantee is part of the value: the user can trust that running pre-flight doesn't modify their codebase.

Effort: high. Model: the project's most-capable reasoning model. Pre-flight pays off most when the model can hold the whole codebase context and reason carefully — this is not the place to economize.
