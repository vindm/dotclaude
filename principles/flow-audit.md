# flow-audit — designing a multi-screen arc audit agent

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author an agent that audits **whole user-flow arcs** (multi-screen journeys felt as one experience) — the dimension that single-screen reviewers structurally miss.

## When to ship one (applicability gate)

Ship a flow-audit agent when:

- The project has **multi-screen user flows** — onboarding wizards, checkout flows, setup processes, sign-up → first-use arcs, account-deletion arcs.
- The project has shipped a "screens individually fine, the journey feels off" experience.
- Continuity properties — tone, pacing, disclosure rhythm — matter to the product.

Skip when:

- The project is single-screen or single-mode (no real arc structure).
- The flows are all 1-2 screens long (per-screen review is sufficient).
- The user explicitly handles arc-level review themselves and doesn't want it agent-mediated.

## Why it matters — what this catches that nothing else does

Per-screen reviewers grade screens. They cannot grade the **journey between screens** — which is where the most important UX failures hide. The eight-class taxonomy of arc-level failures:

1. **Copy / context mismatch.** A string that was authored for first-touch leaks onto a daily-driver surface (see `journey-mapping.md` and `element-reuse.md`). Each screen in isolation reads fine; the journey makes the mismatch glaring.

2. **IA boundary violations.** Two arcs that should be separate are joined; or one arc is split across boundaries the user perceives as one. Wizard → Settings transitions that should be Wizard → Daily-Home; deep links that bypass arc stages without acknowledgement.

3. **Motion-language drift.** Step 1 cross-fades; step 2 slides; step 3 modal-presents. Each animation is platform-idiomatic in isolation; the journey feels stuttery.

4. **First-touch vs daily-driver drift.** A wizard surface that the user revisits as a daily destination has the wrong register — still apologizing, still introducing, still teaching, when it should be operational.

5. **Disclosure pacing.** Critical information dumped on screen 1 (overwhelming) or trickled past screen 5 (frustrating). The journey has bad info-rhythm.

6. **CTA weight progression.** Wizard step 1's primary action is a solid CTA; step 2's is a ghost button; step 3's is a list-row chevron. The user can't tell where the primary action is at any given step.

7. **Dead-end surfaces.** A screen in the arc has no clear exit — back leaves the user stranded, the proposed forward action doesn't fire, the surface is reachable only by accident.

8. **Missing transition bridges.** Two arcs meet at a junction with no acknowledgement — wizard → first daily home should feel like a transition, not a hard cut. Or sign-up → wizard should welcome the user across the boundary.

These bugs are invisible to:
- Single-screen visual review (`ux-audit.md`) — each screen passes its own grade.
- Cross-section consistency review (`pages-audit.md`) — different scope; comparing tabs, not arc stages.
- Code review — the diff for any one screen is fine.

Only an agent that walks the arc end-to-end and grades CONTINUITY catches them.

## Core methodology — four phases

The agent walks four phases per invocation. Two artifacts come out the other end: a canonical flow doc (persistent) and a point-in-time gap report (dated).

### Phase 1 — Arc inventory (scope locking)

The user's invocation is usually loose ("audit the onboarding flow"). Before walking, the agent locks scope:

1. Identify the **entry surface** — first screen of this arc.
2. Identify the **exit surface(s)** — where the user lands when the arc is "done."
3. Identify **branches and edges** — back, error, abandon paths.
4. Convert the loose name to a slug for file paths.

The output is a one-paragraph scope statement at the top of the audit doc: entry / exits / in-scope branches / out-of-scope adjacent arcs.

If the invocation is ambiguous ("audit onboarding" — does that include the post-signup setup wizard?), the agent ASKS before walking. Auditing the wrong arc wastes the run.

### Phase 2 — Build / update the flow doc

For each surface in the arc, in user-traversal order, the agent documents:

| Field | What to capture |
|---|---|
| Order | 1, 2, 3, … |
| Surface name | Human-readable label |
| File:line | Path to the component + line of relevant copy / state |
| Type | first-touch / daily-driver / settings / error / promotional / bridge |
| Trigger | What routes the user TO this surface |
| Exit paths | Where can the user go FROM this surface? |
| Visible copy (verbatim) | NOT paraphrased. Pull from translation / source. |
| Components mounted | Key components with file refs |
| State variants | empty / typical / overflow / loading / error — described or marked "not present" |

The flow doc is the canonical reference for the arc. Future design / audit work reads it as truth. The agent overwrites the existing flow doc on each run (it's the current state), but preserves prior gap reports as history.

### Phase 3 — Gap detection (the eight classes)

Walk the arc looking for each class:

1. **Copy / context mismatch** — for each visible string, run the reuse-gate (per `element-reuse.md`). Surface any REJECT verdict.
2. **IA boundary violations** — does any surface route into a different arc unexpectedly? Does the deep-link structure bypass stages?
3. **Motion-language drift** — for each transition, what's the animation? Are they consistent?
4. **First-touch vs daily-driver drift** — for surfaces accessed BOTH in the arc and outside it, does the copy register match the access context?
5. **Disclosure pacing** — what gets revealed at each step? Is the cumulative load reasonable?
6. **CTA weight progression** — at each step, is the primary action visually consistent with prior / next steps?
7. **Dead-end surfaces** — for each surface, list its exit paths. Any surface with no exit is a dead-end.
8. **Missing transition bridges** — at each arc junction, is there acknowledgement of the transition?

Each finding gets a severity (Crit / High / Med / Low) and a fix recommendation.

### Phase 4 — Produce the gap report

Dated audit doc with:
- Scope statement (from Phase 1)
- Arc map (summary of the flow doc)
- Findings table (per finding: surface, class, severity, description, fix recommendation)
- Resolution of prior audit's open items (which fixed, which remain, which are new)
- Routing recommendations (some findings route to other agents — IA gaps to design, UI polish to ux-audit, copy fixes to direct edit)

The agent **does not fix anything.** Audit + document only. Hand-off to specialist agents.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The project's actual arc inventory.** What flows exist? Onboarding? Checkout? Account-creation? Each is a candidate audit target.

2. **The project's flow-doc convention.** Where do flow docs live? `docs/flows/`? `docs/journeys/`? `.claude/flows/`? Encode the path.

3. **The project's audit-history convention.** Dated gap reports go where? `docs/audits/`? `.claude/audits/`? Encode.

4. **The project's deep-link / navigation structure.** The agent needs to know how to enumerate "next surface from here" given a route + handler.

5. **The platform-specific animation conventions.** What does "motion-language drift" look like in this project? Reanimated transitions? CSS transitions? View controller animations?

6. **The seed / fixture mechanism.** How does the agent get the app into the arc's starting state? Account fixture? Reset script? URL with params?

## Authoring the agent

The final agent (typically `.claude/agents/flow-auditor.md`) should specify:

1. **When to fire vs refuse** — explicit refusal list for single-screen / single-tab / single-PR / new-design requests.
2. **Mandatory pre-audit reads** — rules, prior flow docs, prior audit history.
3. **The four phases** — scope-lock / build flow doc / detect gaps / produce audit report.
4. **The eight gap classes** — populated with project-specific examples.
5. **The severity tiers** — Crit / High / Med / Low with project anchors.
6. **The two output artifacts** — canonical flow doc + dated audit report.
7. **The non-fixing constraint** — agent audits, doesn't fix.

## Cross-references

- `journey-mapping.md` — the journey map is the input to flow-audit. If no map exists for the arc's surfaces, the agent builds one.
- `element-reuse.md` — Gap class 1 (copy/context mismatch) operationalizes the reuse-gate matrix.
- `ux-audit.md` — UI polish findings route to ux-audit.
- `interaction-audit.md` — dead-chrome / redundant-affordance findings on individual surfaces route to interaction-audit.
- `audit-routing.md` — full routing rules. Flow-audit refuses single-screen / single-tab / single-PR.
- `quality-rubric.md` — severity cross-rubric translation; Crit-class flow gaps block ship.

## Anti-patterns in the agent you write

- **Auditing without scope-lock.** "Audit the onboarding flow" ranges from sign-up to first day. The agent must ASK or commit to a precise scope before walking, or the audit covers a different arc than the user meant.

- **Skipping the canonical flow doc.** The audit's value compounds when the flow doc is the persistent artifact future work reads. An audit without a flow doc is point-in-time-only and re-does discovery on every invocation.

- **Per-screen findings instead of arc findings.** The agent's value is in the BETWEEN. If 80% of the report is per-screen polish, the work belongs to ux-audit.

- **Fixing instead of routing.** The agent audits and documents; it does NOT apply fixes. Fixes have their own paths (design agent / direct edit / interaction-audit).

- **Walking the arc without entering the user state.** If the audit reads the code statically without reproducing the arc in the app, it misses runtime patterns (which surfaces fire which transitions in practice). Capture is part of the audit.

- **Severity inflation.** Tagging every finding as Crit dilutes the meaning. Reserve Crit for ship-blockers (dead-end surfaces, daily-driver showing wizard copy). Severity tiers are calibrated against actual user impact.

- **No resolution-of-prior-audit section.** Without it, every audit is full-discovery and the user can't track progress. The agent should explicitly mark which prior findings are fixed, which remain, which are new.

- **Refusing the wrong things.** Refusing legitimate arc audits because the user invoked with a single-screen phrase is over-correction. The refusal list should be narrow and the agent should accept arc-shaped intent even if the phrasing was loose.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash`, `Write` (to write the flow doc + audit doc), `Edit` (to update the flow doc as it evolves), plus platform-specific capture + navigation tools.

Model: high-capability. Multi-screen continuity reasoning benefits from depth.
Effort: high. Walking a real arc end-to-end + producing two artifacts is a substantial run.
