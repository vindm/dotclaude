# `/dotclaude:testing` interview

3-4 questions, adaptive. Skip what Phase 1 (project scan) already answered. The goal: extract risk priorities + coverage philosophy that can't be read from the codebase alone.

## T1 — Test framework (skip if obvious)

> "I see `<framework>` in your config — confirming that's the test runner I should target? Any test-related tooling I should know about (e.g., snapshot testing strategy, property-based testing library, mutation testing harness)?"

Lead with what Phase 1 already disclosed. If the framework is unambiguous from `package.json` / `Cargo.toml` / `pyproject.toml`, skip the first part and just probe for extras.

## T2 — Coverage status (THE temperature-check question)

> "Three framings — pick whichever fits:
> 1. 'We test as we go — most logic-bearing code has tests; gaps are usually deliberate.'
> 2. 'We have a backlog of untested code — newer modules have coverage, older ones don't.'
> 3. 'We have no real tests yet — bootstrapping from zero or near-zero.'"

The answer shapes the tests-architect's first run:

- **As-we-go** → Audit mode finds the small list of recent gaps + the stale-test sweep is more valuable than mass coverage adds.
- **Backlog** → Audit mode produces a prioritized list of legacy untested modules to work through; Implement mode runs against them in priority order.
- **None / near-zero** → The first action is Design mode on the highest-risk module, NOT a mass coverage audit (the audit would just say "everything is untested," which is unactionable). Start small, build infrastructure, expand.

Confirm which framing fits before authoring; the agent's defaults shift.

## T3 — Highest-risk untested code (THE most important question)

> "If you had to point at the ONE module / file / area whose lack of test coverage scares you the most, what is it? What's the worst failure mode if a bug shipped there undetected?"

The answer goes verbatim into the risk-weighted priority table as priority 1. Examples of shapes:

- "Our auth callback — a bug there means everyone's locked out, or worse, cross-session leakage." → top priority is auth / identity / session
- "The ingestion pipeline — if it produces bad data, it contaminates everything downstream and is unrecoverable." → top priority is data-pipeline correctness
- "The pricing calculator — wrong number = customer trust + financial liability." → top priority is money / billing
- "The matchmaking algorithm — bad matches break the core product experience." → top priority is the domain algorithm

If the user hesitates, push: "Even if all your code is good — which area would keep you up at night if I told you the tests there were stale and the framework had upgraded?"

The hesitation itself is data. Lack of named highest-risk code can mean: (a) the project is too early to have one yet, or (b) the user doesn't have a sharp risk model yet. Either way, the agent's risk-priority table should reflect that — populate it lightly, flag it as "evolving."

## T4 — Testing depth

> "What depth of testing does the project actually hold today?
> - Behavior tests only (unit + integration, asserting input → output)
> - Plus property-based testing (Hypothesis, fast-check, etc.)
> - Plus mutation testing (Stryker, mutmut, etc.)
> - Plus contract tests / snapshot tests for serialized output
>
> And: what depth do you ASPIRE to but don't currently hold?"

The answer shapes the agent's Design mode richness:

- If the project is behavior-only: agent doesn't propose property tests on every module (it'd be friction). Mention as an option for high-risk modules only.
- If the project already uses property tests: encode that as a default for pure-function tier (Tier A); the agent should reach for property tests on algorithmic code.
- If the user aspires upward but hasn't invested: the agent can propose property-based or mutation-testing infrastructure on the right module — but as a separate proposal, not bundled with every Implement run.

Skip this question if the project clearly only does behavior tests AND the user expressed no interest in going deeper.

---

## How to use this script

- Don't fire-hose. One or two questions per turn, conversational.
- Lead with data when you have it (Phase 1 has the framework, the test/source ratio, the most-edited untested files — use those rather than asking the user to recall).
- Skip ruthlessly. If the project has zero tests AND the user wants to keep it that way ("this is a prototype, tests are overhead I'm rejecting"), float skipping the whole kit. Don't force tests on a project that doesn't want them.
- If the user names a risk module that's NOT in the codebase you can see (different repo, vendored deps, etc.), note that the agent will need to be re-pointed when that code lands.

## After the interview

Summarize back before authoring:

> "Based on our chat: framework = `<X>`, coverage status = `<as-we-go / backlog / none>`, top risk priority = `<user's answer>`, depth = `<behavior-only / +property / +mutation>`. The audit mode will surface the top <N> untested-and-high-risk modules first. About to author the kit — confirm?"

Wait for confirmation, then proceed to Phase 4 of `SKILL.md`.
