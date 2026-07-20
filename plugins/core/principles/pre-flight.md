# pre-flight — designing a pre-implementation validation agent for ANY project

Teaching material for Claude Code. Teaches you how to author a pre-flight agent for the user's project. The examples here are not to be copied into their `.claude/`; you derive their pre-flight from their codebase.

## When to ship one

Ship a pre-flight agent when the project has more than 2-3 modules with real coupling (a change in A regularly forces a change in B), has had a "we shipped X and broke unrelated Y" incident, has multiple data paths writing the same store (or workers on the same queue, or UIs reading the same state), or where refactors regularly overrun because hidden coupling surfaces mid-implementation.

Skip for a single-file utility or flat library where every change is local, when the user prefers "code first, refactor when it breaks," or when the codebase is small enough (< 20 files) that the user already holds the integration map in their head. If unclear, ask: *"Has a refactor ever surprised you mid-implementation with hidden coupling — often, occasionally, or never?"* "Often" or "occasionally" → ship.

## Why it matters

Pre-flight answers one failure mode: **you write the code, then discover halfway through that the design is wrong because of something you didn't know about the codebase.** Code review and type-checkers catch bugs in code that was written; pre-flight catches design mistakes *before any code exists*, when changing direction costs one conversation and a deleted plan, not a deleted branch. What it catches that nothing else does:

- **Hidden coupling** — a table has a trigger, an undocumented webhook subscriber, a cron poller; the naive design ignores them, pre-flight surfaces them.
- **Parallel-path proliferation** — the feature adds path #4 for an operation that already has #1-3, each with subtly different guarantees. Pre-flight forces consistency planning upfront.
- **Cross-boundary data loss** — native-bridge / FFI / IPC / RPC boundaries silently drop data unless every event is wired both directions. Pre-flight does the bridge audit before you commit to a design that requires the wiring.
- **Premature abstraction** — pre-flight asks "is there an existing pattern?" The answer is often yes, and the user was about to invent a new one.

## Core methodology — five phases

Same five phases every time; labels constant, specifics from the codebase.

### Phase 1 — Map the territory

Before evaluating the proposed approach, build a picture of the existing landscape. Read the project's context docs (`CLAUDE.md`, `AGENTS.md`, sub-module READMEs); identify the PRIMARY files the change touches (named by the user or inferred from the feature) and read each end-to-end, mapping dependencies via imports; identify the SECONDARY files — anything importing the primaries, calling the same functions, or querying the same data. Read-only: the agent builds the map it will reason against, and writes nothing.

### Phase 2 — Integration-point analysis

For each layer the change interacts with, enumerate the touch points. Enumerate only the layers that exist; absent layers go unnamed.

- **Data.** Tables read / written, existing queries against them, triggers, row-level-security / access policies, whether a migration is needed.
- **State.** Cache keys affected (React Query / SWR / Apollo), store slices (Redux / Zustand / signals), invalidation patterns already established for this data.
- **UI.** Screens / routes / components displaying the data; loading / empty / error states; real-time subscriptions.
- **Background.** Job queues / cron / workers; auto-chaining implications; duplicate-prevention guarantees; constraints on job-type values (DB enums, application constants).
- **External.** Third-party APIs called; webhooks emitted / consumed; rate limits or cost ceilings touched.

### Phase 3 — Parallel-path inventory

The load-bearing phase. List EVERY existing path performing a similar operation, then ask whether the new path keeps the same guarantees. For each operation the feature performs: grep for the function / table / endpoint it touches; list every existing caller and alternative implementation; document each existing path's guarantees (retries, error handling, cache invalidation, ordering, idempotence); flag any guarantee the new path won't maintain — that's the consistency gap to resolve. The output is a table the agent hands the implementer; without it, parallel-path drift ships silently.

### Phase 3B — Cross-boundary verification (when applicable)

When the change touches a runtime boundary — native bridge (RN / Expo modules), FFI (Rust ↔ C, Python ↔ Rust), IPC (Electron main ↔ renderer, parent ↔ worker), RPC (gRPC / tRPC / GraphQL), serialization (queue messages, websocket frames) — do a bridge audit:

1. List every event / message / call crossing the boundary in this direction.
2. For each, trace sender → boundary → receiver → state-or-side-effect.
3. Verify the event fires on every meaningful change, not only on cleanup.
4. Verify the receiver updates both the canonical store AND any mirror it maintains (ref + state in React, mutex-guarded shared state in Rust).
5. Verify any async setup completes before the operation depending on it runs.
6. Flag any event firing data the receiver never reads — silent data loss.

Cross-boundary silent data loss is among the most expensive bug classes: the signature is "works in dev with one path, fails in prod when the second path activates." Pre-flight is the only realistic place to catch it first.

### Phase 4 — Risk assessment

For each integration point and parallel-path gap, rate risk on two axes — likelihood and impact (low / med / high) — and list the mitigation. The mitigations become the "what the implementer must do" section. Categories, in typical order of importance: **data corruption** (incorrect / inconsistent writes, orphans, invariant violations), **silent failure** (fails where nobody notices), **inconsistency** (parallel paths diverge after the change), **performance** (N+1, missing indexes, render storms, queue depth), **migration / rollback** (reversible? handles existing data? rollback if the deploy fails halfway?).

### Phase 5 — Recommendation

Produce a verdict — *Clear for Takeoff*, *Caution*, or *Abort*:

- **Clear for Takeoff** — all integration points mapped and low-risk, parallel paths identified with an obvious consistency plan, existing patterns cover the case, any migration additive-only.
- **Caution** — some medium-risk points; parallel paths need careful consistency wiring; migration touches existing data; the pattern doesn't fully cover and some new shape is needed.
- **Abort** — high risk of corruption or silent failure; parallel paths too numerous or divergent; migration destructive or irreversible; the approach fights the architecture and needs redesign before any code.

With the verdict, emit an implementation plan: ordered steps, exact files to modify, patterns to follow (point to specific existing code as the template), patterns to avoid, tests needed, migration order if applicable.

## How to derive THIS project's specifics

1. **`git log --grep="revert"` / `git log --grep="rollback"`** — the design mistakes that shipped; the pattern behind each revert is a pre-flight gap that wasn't caught.
2. **Architecture-doc gaps** — wherever `docs/architecture.md` or a README says "this used to be X, we changed it because Y," pre-flight should be primed to surface the consideration that motivated the change.
3. **PRs that grew during review** — `git log --merges`, then the diff sizes; the merges that doubled mid-review are where pre-flight would have caught the missing scope upfront.
4. **Stack-specific cross-boundary surfaces** — identify which boundaries exist (RN/Expo: JS ↔ native modules · web: server-render ↔ hydration, service-worker ↔ page · Electron/Tauri: main ↔ renderer · microservices: HTTP / gRPC / queue · WebAssembly: host ↔ wasm memory · FFI: Rust ↔ C · worker threads: main ↔ worker). These are where Phase 3B applies; encode this project's actual surfaces.
5. **User interview** — *"Have you ever started a refactor, gotten 80% in, then realized you missed something fundamental? What was it?"* names a Phase-2 or Phase-3 gap to check for.

## Authoring the agent's surface map

The agent's "Integration Points" section should reference real names from the codebase, not placeholders — the actual data stores / table names, the actual job-type constants, the actual query-key prefixes and store-slice names, the actual native-module and IPC-channel names — so its grep instructions are concrete. Never ship `TABLES_HERE`.

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

## Acceptance — mistakes in the agent you write

- **Recommending architecture from file names alone.** An agent that says "looks like you have a jobs system, add a job type" without reading the jobs code is guessing. Require it to READ before it recommends.
- **Generic boundary checklists.** "Verify the native bridge is wired correctly" has no value; the agent needs THIS project's bridge events by name. Stack-stereotype checklists are wasted tokens.
- **Recommending the clever approach.** Pre-flight is biased toward "follow the existing pattern" and against "introduce a new abstraction" — three lines matching the existing style beat a clever abstraction that adds a pattern. Make the framework prefer the boring path explicitly.
- **Recommendations without "Do NOT" entries.** The "Do NOT" section is often more valuable than the "do" — the implementer will be tempted by a shape that looks right but isn't, and pre-flight's job is to name that temptation.
- **Stopping at the first risk.** Pre-flight is exhaustive. Finding one critical risk and recommending Abort without enumerating the rest teaches the implementer one thing instead of the full picture.
- **Not flagging unknowns.** If the agent searched for a pattern and couldn't find it, it must SAY SO (*"searched for cache-invalidation patterns for table X, found none — verify"*). A confident "all clear" on an incomplete search is worse than a stated gap.

## Tool surface

Read-only: `Read`, `Grep`, `Glob`, `Bash` (for `git log`, `git grep`, traversal). NOT `Edit` or `Write` — pre-flight is analysis, not implementation, and the guarantee that running it doesn't modify the codebase is part of the value. Effort: high. Model: the project's most-capable reasoning model — pre-flight pays off most when the model holds the whole codebase context; don't economize here.

## Cross-references

- `code-review.md` — the post-implementation companion. Pre-flight catches design gaps, code-review catches implementation gaps; they share the parallel-path methodology.
- `task-classification.md` — several routing rows start their runbook with a `pre-flight` invocation.
