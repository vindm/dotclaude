# ai-cost-monitoring — designing an LLM-cost projection agent

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author an agent that projects the cost of an AI / LLM workflow change BEFORE the regression eval runs, so the user can pick the cheapest test that still produces signal.

## When to ship one (applicability gate)

Ship a cost-monitoring agent when:

- The project has **AI / LLM workflows in production OR in dev** — prompt-driven features, eval suites, multi-stage cascades, agent loops.
- The user has been surprised by an LLM bill spike at least once.
- Eval / regression runs are expensive (the suite is multi-fixture × multi-stage × frontier-model).
- Decisions about model choice / temperature / prompt size are routine and cost-impactful.

Skip when:

- The project has no AI / LLM dependencies.
- The project's AI usage is wholly bounded by an upstream budget (e.g., user-driven only, with caps already enforced).
- The user runs evals so rarely that pre-projection is overhead.

## Why it matters — what this catches that nothing else does

LLM workflow changes have hidden cost amplifiers:

- **Model swaps.** Swapping a Flash-tier model for a Pro-tier model is a 5–10× cost multiplier per call. If the workflow has 20 fixtures and 3 passes, the multiplier compounds. The change looks like one line in the config; the bill looks like a typo.
- **Fixture-set growth.** Adding 10 new fixtures to a 20-fixture eval suite is a 50% cost increase per run. The PR adding the fixtures looks innocent; the next eval run is 50% more expensive.
- **Cascade depth.** A workflow with N stages × M passes per stage = N×M calls per fixture. Adding a second pass to one stage multiplies cost by 2x for that stage.
- **Token-count creep.** Prompt files grow over time. Each new system instruction, each new few-shot example, costs tokens per call. Sub-linearly visible per change; compounded across many calls.
- **Mock-mode bypass.** Tests / dev runs that go through one mock-aware code path are cheap; runs that go through a parallel non-mock-aware path pay full price. See `../examples/the-test-passed-for-the-wrong-reason.md`.

The agent projects cost BEFORE the eval runs, so the user can:
- Pick a subset of fixtures.
- Use mock mode if available.
- Run a smaller-cascade variant.
- Decide it's not worth running this round.

What this catches that nothing else does: the cost of LLM runs is invisible until the bill arrives. Pre-projection is the only realistic guard against surprise bills.

## Core methodology — five-step projection

The agent walks five steps:

### Step 1 — Classify the diff

What changed? Run `git diff --stat` on the AI-workflow paths and identify which stages / models / fixtures the change touches.

Map each touched path to the eval stages that exercise it. Example shape:

| Workflow path | Eval stage | Run command |
|---|---|---|
| `<path-to-stage-A>` | `stageA` | `<eval-command-for-stageA>` |
| `<path-to-stage-B>` | `stageB` | `<eval-command-for-stageB>` |
| `<path-to-shared>` | (propagates to all stages that import it) | `<grep callers>` |

For shared modules, grep callers to determine the blast radius.

### Step 2 — Read the model + temperature per stage

Each stage's config typically names a model + temperature. The agent reads these directly from source:

```
grep -E "MODEL_NAME|model.*=" <config-files>
```

Common model tiers (verify by reading — projects' tier maps drift):

| Tier | Examples | Relative cost (per 1M tokens) |
|---|---|---|
| Frontier-large | claude-opus-4-7, gemini-pro | High |
| Frontier-mid | claude-sonnet-4-6, gemini-pro (older) | Medium |
| Frontier-fast | claude-haiku-4-5, gemini-flash | Low |
| Embedding / classifier | text-embedding-*, smaller models | Very low |

If the diff SWAPS a model tier (e.g., Flash → Pro), that's a 5–10× multiplier on its own. Flag it explicitly.

### Step 3 — Count fixtures per stage

Each stage has a set of test fixtures. A "pass" = one fixture × one model call. The agent counts:

```
ls <fixtures-dir-for-stage> | wc -l
```

Multi-stage cascades multiply: a stage with 3 sub-passes per fixture × 20 fixtures = 60 model calls.

### Step 4 — Estimate tokens per call

Per-call token cost is approximately:
- (system prompt tokens + input tokens) × input price per million
- + (expected output tokens) × output price per million

For a rough projection: the agent reads the prompt file, estimates input tokens (~length / 4 for English), estimates output (typically capped by `max_tokens` config), multiplies by per-call count, multiplies by per-million pricing.

The agent should consult the project's actual model pricing — pricing changes; don't trust embedded numbers in older docs.

### Step 5 — Produce the projection

```
## Cost Projection: <change-name>

### Affected stages
| Stage | Fixtures | Passes/fixture | Total calls |
|---|---|---|---|

### Model changes
<any tier swaps with multiplier impact>

### Projected cost
| Stage | Cost (low estimate) | Cost (high estimate) |
|---|---|---|

### Total: ~$X (low) - $Y (high)

### Cheaper alternatives
- Subset N of M fixtures: ~$Z
- Use mock mode (if applicable): ~$0 (verify mock-mode coverage)
- Skip cascade pass <X>: ~$W
- Run only the affected stage: ~$V

### Recommendations
<one-line direct recommendation>
```

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The AI-workflow file structure.** Where do prompts / configs / fixtures live? `lib/ai/workflow/`? `src/ai/`? `prompts/`? `evals/`? The agent's path classification needs to match.

2. **The eval command set.** What yarn scripts / make targets / Python entry points run the evals? Each stage typically has its own. The agent references the actual commands.

3. **The model tier map for THIS project.** Read the config files to see which model identifiers the project uses. Encode them with their tier.

4. **The project's mock-mode story.** Is there a mock / dry-run / fixture-mode? Which entry points respect it? Which BYPASS it (see `../examples/the-test-passed-for-the-wrong-reason.md`)? The agent should flag mock-bypass risks.

5. **The model pricing source.** Either inline (with a "verify pricing at <URL> — drifts" note) or via an API the agent can call. Recommend a config file the project maintains and the agent reads.

6. **The cascade architecture.** How many passes does each stage have? Are there research / synthesis / critic phases? The agent needs the shape of the cascade to count calls.

## Authoring the agent

The final agent (typically `.claude/agents/eval-cost-watcher.md`) should specify:

1. **When to invoke** — pre-eval-run when AI-workflow files changed; pre-improvement-loop runs that compound costs.
2. **When NOT to invoke** — pure cosmetic edits, fixture-only changes that don't shift counts, mock-mode-bypassed paths (with caveat).
3. **The five-step methodology** — classify / model-read / fixture-count / token-estimate / project.
4. **The project's model-tier map** — concrete model names + tier classification.
5. **The mock-mode coverage check** — which entry points respect mock mode, which don't; flag bypass risk.
6. **The projection format** — affected stages / model changes / cost ranges / cheaper alternatives / recommendation.
7. **The "I do not run the eval" constraint** — the agent projects; the user decides.

## Cross-references

- `pre-flight.md` — for AI-workflow changes, pre-flight should ask about cost impact; this agent operationalizes that question.
- `code-review.md` — should flag uncosted AI workflow changes for the cost agent.
- `../examples/the-test-passed-for-the-wrong-reason.md` — the mock-mode bypass trap. The cost agent should explicitly check for this.
- `data-integrity.md` — when AI workflows produce records, integrity audit covers the output side; cost monitoring covers the input side.

## Anti-patterns in the agent you write

- **Running the eval to estimate cost.** Defeats the purpose. The agent projects FROM source files, not by burning calls.

- **Single-point estimates without ranges.** Token counts vary by input fixture; the projection should be a range (low / high) so the user knows the uncertainty.

- **No "cheaper alternative" suggestions.** A projection alone says "this will cost $X." A projection + alternatives says "this will cost $X; here are three ways to get the signal for less." The second form is actionable.

- **Trusting stale pricing.** LLM pricing changes frequently. The agent should consult a maintained config file with a "verify against provider's docs" note, not hardcoded numbers from training data.

- **Ignoring mock-mode coverage.** A workflow that LOOKS expensive may be cheap because mock mode covers the entry point. A workflow that LOOKS cheap may be expensive if mock-mode is bypassed (see the war story). Always check mock coverage.

- **No model-swap flag.** Tier swaps (Flash → Pro) are the highest-impact category of change. The agent should call them out separately with the multiplier number, not bury them in a general projection.

- **Burning the budget being projected.** The agent itself is an LLM call. Use a mid-tier model and keep the agent's context bounded — the cost of the projection shouldn't approach the cost of the eval being projected.

- **Projection without acknowledging variability.** Different fixtures produce different output lengths. Different inputs produce different cache-hit behavior. The projection is a model; the actual bill is the bill. Acknowledge the gap.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash` (for `git diff`, file counting). It does NOT need `Edit`, `Write`, or `Bash` access to actually run evals — projection is the role.

Model: medium-capability. Token estimation + diff classification benefits from the model's pattern recognition but doesn't require the heaviest reasoning.
Effort: medium. Designed to run pre-eval as a 1-2 minute step, not a half-hour analysis.
