# audit-routing — designing a routing rule when multiple audit agents coexist

Teaching material for Claude Code. When you bootstrap a `.claude/` directory and the user's project ends up with multiple audit / review agents, this doc teaches you HOW to author the rule that decides which agent runs for which question — and in what order when multiple are needed.

## When to ship one (applicability gate)

Ship an audit-routing rule when the user's `.claude/` will contain **3 or more audit-shaped agents**. Below that count, routing is overhead — the user can hold "code-reviewer vs pre-flight" in their head trivially.

The threshold is about cognitive cost, not capability. The moment Claude (or the user) reflexively reaches for the wrong agent because the inventory is large enough to be confusing, the rule earns its keep.

Skip when:

- Only 1–2 audit agents exist in `.claude/agents/`.
- The agents serve obviously-different purposes (e.g., one for backend correctness, one for a11y) and there's no ambiguity at the dispatch boundary.
- The user is the only operator and prefers to dispatch by feel rather than by rule.

## Why it matters — what this catches that nothing else does

The failure mode this prevents: **dispatching the wrong audit agent on the wrong question, getting a misleading verdict, and either shipping a bug or wasting a full agent run.**

A code-reviewer dispatched on a question about visual polish will produce generic "looks fine" output and miss every chrome-vs-handler integrity gap. A visual-polish reviewer dispatched on a question about parallel-path drift will not even know to look for the failure mode. The agents are domain-specific by design; the rule encodes the routing so Claude doesn't have to re-derive it each time.

A second value of the rule: **canonical pipeline order**. When multiple audits apply (e.g., on a UI batch you might want token discipline + accessibility + interaction semantics + visual polish), the rule says what order to run them in so each one's work doesn't get clobbered by the next. Without this, the user redoes work by accident.

## Core methodology — the routing table + pipeline order

The rule has two halves:

### Half 1 — Routing table

A table mapping question-shape to agent. Each row is a single, specific question. The agent name and a one-line "why this one" caption keep the table honest.

Example structure (placeholders — the user's table fills with their actual agent inventory):

| Question shape | Agent | Why this one |
|---|---|---|
| "Is this code change safe to merge?" | code-reviewer | Post-implementation parallel-path + blast-radius analysis. |
| "Is this proposed approach the right one before I write code?" | pre-flight | Pre-implementation integration / risk mapping. |
| "Is this one UI screen visually polished?" | ux-audit | Screen-as-composition grading against benchmarks. |
| "Are these N screens consistent across the flow?" | flow-audit (or its equivalent) | Continuity properties across screens. |
| "Are the X primary tabs consistent with each other?" | pages-audit | Cross-tab measurement. |
| "Does this chrome promise what its handler does?" | interaction-audit | Semantic affordance-vs-behavior. |
| "Is this accessible?" | a11y-audit | Accessibility dimensions (labels / hit-size / contrast / scaling / motion). |
| "Sweep for raw hex / non-token color across the codebase" | design-token-audit | Token-discipline regex sweep. |
| "Database integrity / orphan detection" | data-integrity (data-auditor) | DB query patterns specific to the schema. |
| "Test coverage gaps on this change" | test-architect | Coverage / testability classification. |

The table is THIS project's actual agents and THIS project's typical questions. Don't write rows for agents that don't exist.

### Half 2 — Pipeline order (when multiple audits apply)

When a UI batch (or any multi-dimensional artifact) needs more than one audit, run them in a deterministic order so each one's findings don't get clobbered by the next.

The canonical order for UI work:

```
1. Token / linter / mechanical sweeps        (cheapest, fixes wide-scale violations first)
2. Semantic + accessibility audits in parallel
   (semantic = chrome-vs-handler; a11y = labels / hit / contrast)
   These audit orthogonal dimensions; running them in parallel saves wall time.
3. Visual polish audit last
   (because steps 1-2 may shift layout / sizes / labels;
    if you run visual first, you redo it after steps 1-2.)
```

For multi-screen arcs, add:
- Flow scoping / mapping BEFORE step 1 (to know what surfaces are in scope)
- Flow continuity audit AFTER step 3 (continuity properties only emerge on the polished output)

For the project's primary multi-section surface (e.g., the main app's tab bar), add `pages-audit` (or equivalent cross-section consistency audit) between step 2 and step 3 — catches consistency drift before visual polish locks the surface.

This order is binding. Reversing it forces the visual audit to redo work after semantic / a11y fixes move things around — wasted agent run.

## How to derive THIS project's specifics

Before authoring the rule, gather:

1. **The actual agent inventory.** List of agent files the user is about to have in `.claude/agents/`. Each row in the routing table maps to one of these; no rows for agents that don't exist.

2. **The project's actual question shapes.** What does the user typically ask Claude? "Review this PR" is one question; "is this design done?" is another; "did I miss anything?" is a third. The routing table should anticipate the user's actual phrasings.

3. **The project's actual multi-audit batches.** When does the user run more than one audit at once? UI batches? Schema-change batches? Performance-investigation batches? Each batch has its own pipeline order.

4. **The "refuse and recommend" behaviors of each agent.** Some agents (e.g., a single-screen ux-reviewer) explicitly refuse multi-screen requests and recommend the flow-audit agent. The rule should encode these refusal behaviors so the user knows which way the redirect goes.

## Authoring the rule

The final rule file (typically `.claude/rules/audit-routing.md`) should contain:

1. **A routing table** — question → agent, with one-line "why this one."
2. **Refuse-and-recommend behaviors** — for each agent, what it WILL NOT handle and where it points instead.
3. **The canonical pipeline order** — for the project's typical multi-audit batches.
4. **Cross-rubric translation** (optional but valuable) — if different agents grade on different scales (S/A/B/C/D/F vs Crit/High/Med/Low vs S0/S1/S2/S3), a translation table for aggregating verdicts.
5. **Hooks that prevent classes of finding entirely** — before invoking any agent, the user should know which edit-time hooks already catch certain findings. This section says "if you find yourself dispatching design-token-audit for raw hex, check whether the token-guard hook fired on the offending edit — fix the hook, not the finding."

## Cross-rubric translation table

Different agents use different grade scales. When aggregating verdicts (e.g., in a release-readiness check), translation is needed. Example shape (the actual letters / labels depend on the project's agents):

| ux-style verdict | flow-style verdict | token-style verdict | Composite grade |
|---|---|---|---|
| S | no gaps | no violations | S |
| A | low only | S2 only | A |
| B | low-medium | S1 | B |
| C | high count > 2 | S0 (1-2) | C |
| D | any critical | S0 (3+) | D |
| F | multiple critical + missing | — | (block ship) |

The principle: a single critical from any blocking-class audit blocks ship regardless of visual grade. Example: a missing accessibility label on an interactive element or a < 44pt hit target is ship-blocking even if the visual reviewer gives an A.

## The "what each agent refuses" sub-table

Some agents will be explicitly scoped to refuse certain requests. The rule should encode these so the user (and Claude) don't fight the agent:

| Agent | Refuses | Recommends instead |
|---|---|---|
| ux-audit (single-screen) | Multi-screen arcs | flow-audit |
| flow-audit | Single-screen polish | ux-audit |
| flow-audit | New design proposals | the design / brainstorm skill |
| design-token-audit | Component-level redesign | ux-audit |

When an agent refuses, follow the recommendation — don't re-prompt it to do the work it explicitly refuses. Re-prompting wastes a high-effort agent run on an explicit refusal it will produce again.

## Hooks-prevent-findings sub-table

The cheapest finding is one prevented by an edit-time hook. Before dispatching any audit agent, the rule reminds the user of which findings the hooks already prevent:

| Hook | Catches | Override convention |
|---|---|---|
| `check-token-only.sh` | Raw hex / rgba color literals outside theme files | Per-line: `// allow-color: <reason>` |
| `check-file-size.sh` | Files > ceiling LOC | Decomposition required, no inline override |
| `check-forbidden-phrases.sh` | Voice-discipline phrases | Per-line: `// allow-forbidden: <reason>` |
| (project-specific) | (project-specific) | (project-specific) |

If a class of finding is fully prevented by a hook, dispatching an audit agent to find more of it is wasted spend. The rule should explicitly route "did you fix the hook?" before "did you run the audit?"

### Cheapest-tier-wins discipline — first-class routing principle

"Hooks prevent classes of finding entirely" is **a first-class principle in this rule**, not an aside. The whole audit-routing decision tree is shaped by the cost-of-detection ladder:

| Tier | Mechanism | Cost | Catches |
|---|---|---|---|
| 0 | **Hook** (edit-time, deterministic) | ~0 tokens, milliseconds | Mechanical patterns (raw hex / forbidden phrases / file-size / platform-icon API) |
| 1 | **Rule** (always-loaded reference) | Tokens-in-context only, no extra dispatch | Conventions the agent already knows (north-star reference, routing) |
| 2 | **Skill** (auto-loaded by path/topic) | ~2-5k tokens per dispatch | Methodology + reference data the agent loads situationally (journey-mapping, persona-testing) |
| 3 | **Agent** (explicit dispatch) | ~20-50k+ tokens per run, expensive model | Reasoning-heavy work (visual polish grading, semantic chrome integrity, arc continuity) |

**The discipline**: when a class of finding can be prevented at a cheaper tier, push it there. Conversely, before dispatching an expensive agent, ask: "is this what hooks / rules / skills already cover?" — and if yes, fix the cheaper-tier first.

Concrete applications:

- **Don't dispatch `design-token-audit` to find raw hex if `check-token-only.sh` already blocks it on edit.** If raw hex is slipping past, the hook is broken — fix the hook (cheaper). Then run the agent only to sweep accumulated drift before the hook landed.
- **Don't dispatch `ux-audit` to find "the welcome message on daily home" if `forbidden-phrases.txt` + the hook would have caught it.** First check the phrase is on the deny-list; if not, add it; if yes but the override was used inappropriately, address the override.
- **Don't dispatch `flow-audit` to find IA gaps that `product-designer`'s self-audit (run at design time) would catch.** If specs are drifting, fix the designer's gate discipline; the flow-auditor's whole-arc audit is too expensive for "the designer skipped Section 0a."

This shapes the dispatching mental model: ask which tier should catch the finding, and operate at THAT tier — not the highest one available. The audit-routing rule's existence is itself a Tier 1 mechanism preventing Tier 3 wastes.

## Cross-references

- `code-review.md` / `pre-flight.md` — non-UI audit agents. The routing table should include them.
- `ux-audit.md`, `a11y-audit.md`, `interaction-audit.md`, `pages-audit.md`, `flow-audit.md`, `design-token-audit.md` — the typical UI-audit inventory; each row in the routing table maps to one.
- `quality-rubric.md` — the cross-rubric translation table relies on rubric anchors; if those move, the translation updates.
- `visual-verification.md` — every visual audit assumes a captured artifact to grade. The rule should remind dispatchers to capture before invoking.

## Anti-patterns in the rule you write

- **Routing rows for agents that don't exist.** Don't list `flow-audit` if the project doesn't have a flow auditor. The rule is THIS project's inventory, not the abstract universe.

- **No refusal behaviors documented.** If the user dispatches single-screen polish work to flow-audit and that agent refuses, the user will assume the refusal is a bug rather than a feature. Document the refusals so users follow the redirects.

- **Pipeline order undefined for multi-audit batches.** Without a deterministic order, every UI batch becomes "run a few audits, see what they say" — and some audits clobber others. Define the order explicitly.

- **Cross-rubric translation missing.** If agents grade on different scales, aggregating verdicts is impossible without translation. Either ship the translation or align the rubrics (the latter is cleaner; see `quality-rubric.md`).

- **No mention of hooks.** The cheapest find is a prevented one. If the rule doesn't surface the existing hooks, users dispatch agents to find what hooks already prevent — burning model spend on settled questions.

- **Table that's overly generic.** Rows like "use the right audit for the question" are useless. Every row should be specific enough that a new contributor knows which agent to dispatch on first read.
