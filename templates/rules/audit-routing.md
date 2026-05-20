# Design audit routing — which agent for which question

When the user asks for a UI / UX / design audit, route deterministically. The wrong agent on the wrong question wastes a 30-minute opus-high run and produces a misleading verdict.

This rule is the decision tree. Read it before dispatching ANY design-related agent.

## Routing table

| Question shape | Agent | Why this one |
|---|---|---|
| "Is this one screen visually polished / S-tier?" | `ux-reviewer` | Screen-as-composition grading. Apple/Telegram parity per chrome dimension. |
| "Do these N screens hold together as one experience?" | `flow-ux-reviewer` (from captured screenshots) | Continuity properties (tone drift, CTA weight progression, disclosure pacing) — invisible to per-screen reviewers. |
| "What's broken in this whole arc (sign-up → wizard → first daily open)?" | `flow-auditor` | Whole-arc audit. Produces canonical flow doc + dated gap report. Catches IA-boundary, dead-end surfaces, missing bridges. |
| "Are the primary tabs consistent with each other?" | `pages-audit` | Cross-tab measurement audit. Majority-rules deviation finder. |
| "Does this screen's chrome promise what its handler actually does?" | `interaction-audit` | Semantic integrity — dead chrome, redundant affordances, optical-group disconnects. Visual reviewers miss this. |
| "Is this screen accessible (VoiceOver / Dynamic Type / contrast / 44pt)?" | `a11y-audit` | iOS 26 + WCAG 2.2 AA. Apple-parity claim is empty without a11y parity. |
| "Sweep for raw hex / non-token colors across the codebase" | `design-token-auditor` | Token-discipline regex sweep (haiku, cheap, periodic). |
| "Design a new feature / redesign a flow / restructure IA" | `product-designer` | IA + flow + state inventory + spec doc. The spec doc IS the deliverable; no visual mockup is the contract. NOT for single-screen polish. |
| "Iterate this flow to award-tier through tight review-fix loops" | `/ruthless-ux-autoloop` (skill, user-invocable) | Bounded iterative polish with 3 scrutiny layers. Hard cap 10 iterations. |
| "Run an automated UX audit of an onboarding setup" | `/flow-ux-audit` (skill, user-invocable) | Maestro autoplay → screenshot series → flow-ux-reviewer. ~3-5 min. |

## What each agent will REFUSE

These agents have explicit refuse-and-recommend behavior. Don't try to bend them:

- `product-designer` refuses single-screen polish / copy tweaks / single-prop adjustments → recommends `ux-reviewer`.
- `flow-auditor` refuses single-screen polish → recommends `ux-reviewer`. Refuses single-tab consistency → recommends `pages-audit`. Refuses new design proposals → recommends `product-designer`.

When an agent refuses, follow its recommendation — don't relitigate.

## The canonical UI-batch validation order

When multiple audits are warranted on a UI batch (e.g. after shipping a screen or arc):

```
1. design-token-auditor   (free, fast, haiku — fix raw hex first)
2. interaction-audit  +  a11y-audit   (run in PARALLEL — they audit orthogonal dimensions: semantic chrome vs accessibility integrity)
3. ux-reviewer            (visual polish — last, because steps 1-2 may shift layout)
```

This order is binding. Reversing it forces ux-reviewer to redo work after semantic / a11y fixes move things around.

For multi-screen arcs, add `flow-auditor` BEFORE step 1 (to scope and surface arc-level gaps) and `flow-ux-reviewer` AFTER step 3 (to check arc-level continuity properties on the polished output).

For the project's primary tab set, add `pages-audit` between step 2 and step 3 to catch cross-tab consistency drift before final visual polish.

## Shared skills every design agent uses

These skills are reusable across the agents and should auto-load when those agents fire (declared in agent frontmatter `skills:` field):

| Skill | Loaded by | What it does |
|---|---|---|
| `design-system` | every UI agent | Tokens, Liquid Glass primitives, motion presets |
| `quality-bar` | every UI agent | Demo test, 5 composition pitfalls, S/A/B/C/D rubric, benchmark anchors |
| `app-state-navigation` | every audit agent | Recipe catalog — "how do I get the app to <state-X>" |
| `journey-audit` | every design / audit agent | Build the prior-surfaces map. Mandatory before design or audit. |
| `element-reuse-check` | designers + reviewers | Gate A — verdict matrix for reusing existing strings/components |
| `persona-lens` | designers + reviewers | Gate B — day-30 / partner / stranger tests on every copy element |

If you dispatch an agent and notice its frontmatter doesn't list a needed skill, that's a bug — fix the frontmatter, don't paper over with prose in the prompt.

## Cross-rubric translation

Agents grade on different scales. When aggregating multiple verdicts, translate using this map:

| `ux-reviewer` / `flow-ux-reviewer` / `interaction-audit` / `a11y-audit` | `flow-auditor` severity | `design-token-auditor` tier | `quality-bar` |
|---|---|---|---|
| S | (no gaps OR Low only) | (no violations) | S |
| A | max Med | S2 only | A |
| B | up to High | S1 | B |
| C | High count > 2 | S0 (1-2) | C |
| D | any Crit | S0 (3+) | D |
| F | multiple Crit + missing required surfaces | — | (Don't ship) |

When in doubt: a single Crit-class gap from `flow-auditor` OR `a11y-audit` blocks ship regardless of `ux-reviewer`'s overall grade. Crit > visual polish. Specifically: a missing accessibilityLabel on an interactive element or a < 44pt hit target is ship-blocking — same severity as a flow-auditor Class-1 Crit.

## Hooks that prevent classes of finding entirely (the cheapest wins)

Before invoking any agent, remember edit-time hooks fire automatically and prevent the largest classes of finding without any LLM tokens:

| Hook | Catches | Notes |
|---|---|---|
| `check-token-only.sh` | Raw hex / rgba color literals outside the theme tokens file | Override per-line: `// allow-color: <reason>` |
| `check-forbidden-phrases.sh` | Forbidden phrases on `*/translations/`, `*/narration/`, `*/copy/` files | Override per-line: `// allow-forbidden: <reason>` |
| `check-file-size.sh` | Files > 1000 LOC (warn at 950) | Mandatory decomposition |

If you find yourself dispatching `design-token-auditor` to find raw hex, ask first: did `check-token-only.sh` fire on the offending edit? If not, fix the hook.

## See also

- `design-north-star` rule — Apple iOS 26 + Telegram chrome reference (the bar all visual agents grade against)
- `visual-verification` rule — screenshot / hierarchy capture discipline (CLI-first, MCP fallback)
- `forbidden-phrases.txt` — authoritative phrase list
