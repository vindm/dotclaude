# The doc that lied and the code that didn't

## Symptom

A task: "add a `cancelled` state to the order lifecycle." The architecture doc — `docs/order-lifecycle.md`, a clean diagram with states and transitions — said orders moved `pending → paid → fulfilled`, with a single reducer at `lib/orders/reducer.ts` owning every transition. Straightforward: add the new state to the reducer, wire the transition, done.

The change shipped. Lint passed, tests passed, the doc's diagram now showed the new state. Two days later: orders were getting stuck. A `cancelled` order would silently flip back to `pending` overnight. Nobody could reproduce it on demand.

## Root cause

The doc was a year old. Since it was written, a background reconciliation job had been added — `jobs/reconcile-orders.ts` — that *also* wrote order state, directly, bypassing the reducer entirely. It re-derived state from the payment provider every night and wrote it back. It knew about `pending / paid / fulfilled`. It had never heard of `cancelled`, so it "corrected" every cancelled order back to `pending`.

The reducer was not the single owner of order state. The doc *said* it was. The doc was a reflection of how the system worked a year ago, and it had quietly gone stale while the code moved on. I trusted the diagram over the code, never grepped for other writers of the state column, and shipped a change that was correct against the doc and wrong against reality.

## The diagnostic that finally worked

`grep -rn "order.*state\s*=" lib/ jobs/ app/` — every place that *assigned* order state. Two hits, not one. The second was the reconciliation job. The moment the second writer showed up, the overnight flip-back was obvious.

## Lesson

**Code is truth; a doc is a reflection that may have stopped reflecting.** A doc-vs-code conflict is not a tie to reason about — code wins, always. The doc told me there was one writer; thirty seconds of grep would have told me there were two. I asked the doc instead of asking the code.

## The discipline this produced

1. **Reflection docs are a map to find code fast, not an authority.** Use them to locate the reducer; then verify the load-bearing claim ("single owner") against the code before relying on it.
2. **Before changing a state machine / shared resource, grep for all writers.** The parallel-path instinct: one writer in the doc means *grep for the second one anyway.*
3. **When you change code a doc describes, update the doc or stale-mark it in the same change.** `code → docs`, never the reverse. The year-old diagram drifted precisely because nobody enforced this when the reconciliation job landed.

## See also

- `principles/knowledge-layers.md` — the authority order `.claude` → code → docs; doc-vs-code conflict → code wins. This story is what that rule prevents.
- `principles/code-review.md` — parallel-path detection: grep for every other path performing the same operation before trusting that one path owns it.
- `principles/authoring-skills.md` — the same staleness failure applied to skills: point at code, don't mirror a snapshot that rots.
