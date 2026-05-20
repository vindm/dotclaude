# The test passed for the wrong reason

## Symptom

A multi-stage AI workflow processes user input through three models in sequence: stage A produces a draft, stage B refines it, stage C critiques. Each stage costs real LLM tokens. To make development affordable, we'd added a mock mode: setting `AI_MOCK_MODE=1` short-circuits every call to a pre-recorded fixture.

A new feature shipped. We ran the dev cron that exercises the whole pipeline against a queue of seeded test inputs. Output looked great. Costs were trivial — exactly what mock mode promised. We merged.

The next morning, our LLM bill showed a four-figure overnight charge from the dev environment.

## Root cause

The mock-mode short-circuit lived in exactly one place: the HTTP route handler at `/api/ai/workflow`. When the workflow was invoked through that route (from the UI, from manual scripts, from anything that issued an HTTP request), `AI_MOCK_MODE=1` was checked and the fixture loaded. Skip the real LLM. Cheap.

The dev cron didn't issue HTTP requests. It imported the workflow module directly and called the entry function. Bypassing the HTTP layer meant bypassing the mock-mode check. The cron ran the actual LLM stack against every fixture, paid full token cost, and produced output that looked indistinguishable from the mock fixture (because the fixture was, of course, captured from the real LLM in the first place).

The pre-merge tests had passed because the tests were also issuing HTTP requests. They exercised the mock short-circuit, not the real code path. The real code path — direct workflow invocation — had no test coverage at all.

## Lesson

**Feature flags that short-circuit at one layer don't propagate to other layers.**

The mock-mode flag was a property of the *route*, not of the *workflow*. As long as the only caller was the route, the abstraction held. Adding a second caller (the cron) silently routed around the mock — and the test suite, which exercised only the original caller, had no way to know.

## The diagnostic that finally worked

The first signal was the LLM bill alert. From there: grep for every call site of the workflow's entry function. Find that one of them doesn't pass through the mock-aware layer. Realize the flag is route-scoped, not workflow-scoped.

## The discipline this produced

When you add a short-circuit / mock / dry-run / dev-mode flag:

1. **List every entry point to the thing being short-circuited.** Not "every entry point we currently use" — every entry point that *exists in the code*, even unused ones. Cron jobs. Background workers. Test fixtures. Manual scripts.
2. **The check belongs in the lowest common ancestor of all entry points.** If the workflow has 5 callers, the mock check goes inside the workflow's first call, not inside one of the 5 callers.
3. **Write at least one test that exercises the workflow directly, NOT through the HTTP layer.** That test is the canary for "are we accidentally bypassing the short-circuit again."

The bug-cost diagnostic: if your test suite passes and your production bill spikes overnight, your tests exercise a code path that no real user / cron / worker exercises.

## See also

- `rules/file-discipline.md` — a workflow that holds multiple entry points is a candidate for explicit decomposition; the mock check belongs in a shared `runWorkflow.ts` helper, not in each caller.
- `check-secret-leak` hook — the same "is this layer the right enforcement point?" question, applied to credentials.
