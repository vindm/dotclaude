# audit-routing — designing a routing rule when multiple audit agents coexist

Teaching material for Claude Code. When a project's `.claude/` ends up with multiple audit / review agents, this doc teaches you how to author the rule that decides which agent runs for which question — and in what order when several apply.

## When to ship one

Ship an audit-routing rule when `.claude/agents/` will hold **3 or more audit-shaped agents**. Below that, the user holds "code-review vs pre-flight" in their head trivially and the rule is pure overhead. The threshold is about cognitive cost: the moment someone reflexively reaches for the wrong agent because the inventory is large enough to be confusing, the rule earns its keep.

Skip when only 1-2 audit agents exist, when they serve obviously-different purposes with no ambiguity at the dispatch boundary, or when the user prefers to dispatch by feel.

## Why it matters

The rule prevents two costs. First, **dispatching the wrong audit on the wrong question** — a code-review dispatched on visual polish produces generic "looks fine" and misses every chrome-vs-handler gap; a visual reviewer dispatched on parallel-path drift doesn't even know to look. The agents are domain-specific by design; the rule encodes the routing so Claude doesn't re-derive it each time. Second, **wrong pipeline order** — when several audits apply to one artifact, running them out of order makes one clobber the next (visual polish redone after a11y fixes move things). The rule fixes the order so work isn't accidentally redone.

## Core methodology — the routing table + pipeline order

### Half 1 — Routing table

Maps question-shape → agent, with a one-line "why this one" that keeps the table honest. This project's actual agents and typical questions fill it — no rows for agents that don't exist.

| Question shape | Agent | Why this one |
|---|---|---|
| "Is this code change safe to merge?" | code-review | Post-implementation parallel-path + blast-radius analysis. |
| "Is this approach right before I write code?" | pre-flight | Pre-implementation integration / risk mapping. |
| "Is this one UI screen visually polished?" | ux-audit | Screen-as-composition grading against benchmarks. |
| "Are these N screens consistent across the flow?" | flow-audit | Continuity properties across screens. |
| "Are the primary tabs consistent with each other?" | pages-audit | Cross-tab measurement. |
| "Does this chrome promise what its handler does?" | interaction-audit | Semantic affordance-vs-behavior. |
| "Is this accessible?" | a11y-audit | Labels / hit-size / contrast / scaling / motion. |
| "Sweep for raw hex / non-token color" | design-token-audit | Token-discipline regex sweep. |
| "Test coverage gaps on this change" | test-architect | Coverage / testability classification. |

### Half 2 — Pipeline order (when multiple audits apply)

Run multi-dimensional artifacts through a deterministic order so no audit clobbers another:

```
1. Token / linter / mechanical sweeps        (cheapest; fixes wide-scale violations first)
2. Semantic + accessibility audits in parallel
   (semantic = chrome-vs-handler; a11y = labels / hit / contrast — orthogonal dimensions)
3. Visual polish audit last
   (steps 1-2 shift layout / sizes / labels; visual-first means redoing it after)
```

For multi-screen arcs: flow scoping BEFORE step 1 (to know what's in scope), flow continuity AFTER step 3 (continuity only emerges on polished output). For the primary multi-section surface (e.g. the tab bar), add `pages-audit` between steps 2 and 3. This order is binding — reversing it wastes an agent run.

## How to derive THIS project's specifics

1. **The actual agent inventory** the user is about to have in `.claude/agents/` — one routing row per agent, none for agents that don't exist.
2. **The project's actual question shapes** — "review this PR," "is this design done?", "did I miss anything?" The table should anticipate the user's real phrasings.
3. **The project's actual multi-audit batches** — UI batches? Schema-change batches? Each gets its own pipeline order.
4. **Each agent's refuse-and-recommend behavior** — which requests it declines and where it redirects, so the user reads a refusal as a feature, not a bug.

## Authoring the rule

The final rule (typically `.claude/rules/audit-routing.md`) contains: the **routing table**; the **canonical pipeline order** for the project's multi-audit batches; each agent's **refuse-and-recommend** behavior; the **hooks-prevent-findings** table; and optionally a **cross-rubric translation** table if agents grade on different scales.

### Refuse-and-recommend sub-table

| Agent | Refuses | Recommends instead |
|---|---|---|
| ux-audit (single-screen) | Multi-screen arcs | flow-audit |
| flow-audit | Single-screen polish | ux-audit |
| flow-audit | New design proposals | the design / brainstorm skill |
| design-token-audit | Component-level redesign | ux-audit |

When an agent refuses, follow the recommendation — re-prompting a high-effort agent to do what it explicitly refuses just buys the same refusal again.

### Hooks-prevent-findings sub-table

The cheapest finding is one a hook prevented at edit time. Before dispatching any agent, the rule reminds the user which findings the hooks already catch:

| Hook | Catches | Override convention |
|---|---|---|
| `check-design-tokens.sh` | Raw hex / rgba outside theme files | Per-line: `// allow-color: <reason>` |
| `check-file-size.sh` | Files > ceiling LOC | Decomposition required, no inline override |
| (project-specific) | (project-specific) | (project-specific) |

### Cross-rubric translation (optional)

When agents grade on different scales, aggregating verdicts (e.g. a release-readiness check) needs translation:

| ux-style | flow-style | token-style | Composite |
|---|---|---|---|
| S | no gaps | no violations | S |
| A | low only | S2 only | A |
| B | low-medium | S1 | B |
| C | high count > 2 | S0 (1-2) | C |
| D | any critical | S0 (3+) | D |
| F | multiple critical + missing | — | block ship |

The binding principle: a single critical from any blocking-class audit blocks ship regardless of visual grade — a missing a11y label or a < 44pt hit target is ship-blocking even against a visual A.

## Cheapest-tier-wins — the discipline behind the whole rule

"Hooks prevent classes of finding entirely" is the rule's organizing principle, not an aside. The whole routing decision is shaped by the cost-of-detection ladder:

| Tier | Mechanism | Cost | Catches |
|---|---|---|---|
| 0 | **Hook** (edit-time, deterministic) | ~0 tokens, milliseconds | Mechanical patterns (raw hex / file-size / platform-icon API) |
| 1 | **Rule** (always-loaded reference) | Tokens-in-context only | Conventions the agent already knows (north-star, routing) |
| 2 | **Skill** (auto-loaded by path/topic) | ~2-5k per dispatch | Methodology + reference loaded situationally (journey-mapping) |
| 3 | **Agent** (explicit dispatch) | ~20-50k+ per run, expensive model | Reasoning-heavy work (visual grading, semantic integrity, arc continuity) |

Before dispatching an expensive agent, ask which tier *should* catch the finding, and operate at that tier — not the highest available:

- **Don't dispatch `design-token-audit` for raw hex if `check-design-tokens.sh` blocks it on edit.** If hex is slipping past, the hook is broken — fix the hook (cheaper); run the agent only to sweep drift that accumulated before it landed.
- **Don't dispatch `flow-audit` for IA gaps that `product-designer`'s design-time self-audit would catch.** If specs drift, fix the designer's gate; the whole-arc audit is too expensive for "the designer skipped a section."

The audit-routing rule's own existence is a Tier 1 mechanism preventing Tier 3 waste.

## Acceptance — what the authored rule must have

- **No routing rows for agents that don't exist.** The rule is this project's inventory, not the abstract universe.
- **Refusal behaviors documented**, so users follow the redirects instead of assuming the refusal is a bug.
- **Pipeline order defined for each multi-audit batch** — without it, every batch is "run a few, see what they say," and some clobber others.
- **Hooks surfaced before agents.** If the rule doesn't name the existing hooks, users burn model spend re-finding what hooks already prevent.
- **Cross-rubric translation present when scales differ** (or the rubrics aligned instead — cleaner; see `quality-rubric.md`).
- **Every row specific enough to act on.** *"Use the right audit for the question"* is useless; a new contributor should know which agent to dispatch on first read.

## Cross-references

- `ux-audit.md`, `a11y-audit.md`, `interaction-audit.md`, `pages-audit.md`, `flow-audit.md`, `design-token-audit.md` — the typical UI-audit inventory; each routing-table row maps to one.
- `quality-rubric.md` — the cross-rubric translation relies on rubric anchors; if those move, the translation updates.
- `visual-verification.md` — every visual audit assumes a captured artifact to grade; the rule should remind dispatchers to capture before invoking.
