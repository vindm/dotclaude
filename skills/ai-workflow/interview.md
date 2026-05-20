# `/dotclaude:ai-workflow` interview

3-4 questions, adaptive. Skip what Phase 1 (project scan) already answered. The goal: extract the cost shape (workflow architecture, model tiers, fixture scale) and the user's spend tolerance — neither fully readable from code.

## AI1 — Workflow shape (skip if obvious)

> "Describe the AI workflow at a high level:
> 1. **Single call** — one model invocation per user action (e.g., a chat endpoint that calls Claude once per message).
> 2. **Multi-stage cascade** — pipeline of stages (e.g., planner → executor → critic, or research → draft → refine), each calling a model.
> 3. **Agent loop** — a model that decides which tool to call, possibly recursively (e.g., a multi-step research agent).
> 4. **Eval harness** — fixture-based regression suite that runs the workflow against canned inputs.
>
> And: is the workflow in **production** (real users hitting it), **dev-only** (you run it manually / via cron), or both?"

The answer determines the watcher's complexity:

- **Single call, production-only**: watcher's cost projection is simple (cost per call × estimated call volume). Mock-mode coverage is the critical concern.
- **Multi-stage cascade**: watcher needs the full cascade architecture in its body — stages × passes × fixtures.
- **Agent loop**: watcher needs depth-of-recursion bounds. Agent loops can blow up unpredictably; the watcher should encode a ceiling on iterations.
- **Eval harness**: the watcher's primary use case. Pre-eval projection is exactly what this skill ships for.

Lead with what Phase 1 already showed. If the workflow looks like a cascade from the code, confirm the stage count + passes per stage rather than asking from scratch.

## AI2 — Cost ceiling (drives the watcher's alarm threshold)

> "What's a 'this eval just got too expensive' threshold for you, per single dev iteration?
> - Hard ceiling: any single eval run over $X should require explicit confirmation.
> - Soft ceiling: above $Y the watcher should suggest cheaper alternatives but not block.
>
> Numbers — what are X and Y for your tolerance?"

If the user has no felt sense yet: float anchors. "$5-10 per iteration is typical for medium-sized eval suites on frontier-large models. $50+ should usually warrant blocking."

If the user has been burned before: ask what the surprise bill was. Use 50% of that as the hard ceiling — that's how much surprise the user has demonstrated they can absorb without flinching.

If the project is dev-only (no production user-facing AI calls): the ceiling is the user's personal pain threshold. Encode it; the watcher uses it to suggest mock-mode + fixture-subsetting when projections approach it.

## AI3 — Models in use per stage (often discoverable; confirm)

> "Confirming the model-per-stage map I extracted from your config:
> - Stage A `<name>`: `<model-id>` (tier: <fast / mid / large>)
> - Stage B `<name>`: `<model-id>`
> - Stage C `<name>`: `<model-id>`
>
> Anything wrong? Any models you're considering swapping (and to what)?"

Phase 1 should have extracted this from the config. Confirm rather than re-ask.

If the user mentions a planned swap: surface it explicitly. Tier swaps are the highest-impact category of change. The watcher will flag any future change touching the affected stage's model ID; encode that the user is already planning the swap so the watcher doesn't fire spuriously.

If pricing is somewhere maintained (a config file, a doc): point at it. If not, suggest creating one — hardcoded prices in agent bodies go stale fast.

## AI4 — Past cost surprises (drives the watcher's safety thresholds)

> "Have you been surprised by an LLM bill at least once? What happened?
> - 'I added 20 new fixtures and didn't realize it was a 50% cost bump per run.'
> - 'I swapped a model from Flash to Pro for one stage; the bill 10x'd.'
> - 'A dev cron bypassed mock mode and ran the real LLM against everything overnight.'
> - 'Recursive agent loop got stuck on one input and burned $X chasing its tail.'"

Each named pattern shapes the watcher's safety logic:

- Fixture-count surprise → watcher flags any change adding > N fixtures.
- Model-swap surprise → watcher's "Model changes" section is the highest-prominence finding when it applies.
- Mock-mode bypass → the war-story pattern; watcher's mock-coverage check is the highest-priority finding.
- Agent loop runaway → watcher encodes the iteration-ceiling check.

If the user hasn't been burned yet: ask if there's an upcoming scale change they're worried about (a launch, a fixture expansion, a new stage). If yes, encode that as the watcher's near-term focus.

If genuinely no surprises and no anticipated scale change: the watcher ships with conservative defaults, and the user adjusts when reality demands.

---

## How to use this script

- Don't fire-hose. One or two questions per turn, conversational.
- Lead with data when you have it (Phase 1 has the workflow shape, the model IDs, the fixture count — confirm rather than re-ask).
- Skip ruthlessly. Simple single-call workflow with no eval suite → skip AI3 and AI4 to a quick confirm.
- Listen for "we always X" / "we keep doing Y" cost patterns. Each is a watcher safety threshold waiting to be tuned.

## After the interview

Summarize back before authoring:

> "Based on our chat: workflow shape = `<single / cascade / agent loop / eval>`, hard cost ceiling = `$X` per iteration, soft = `$Y`, models in use = `<tier 1 IDs, tier 2 IDs, tier 3 IDs>`, mock-mode coverage status = `<fully covered / N bypasses flagged>`, past cost surprises = `<list>`. About to author the kit — confirm?"

Wait for confirmation, then proceed to Phase 4 of `SKILL.md`.
