# flow-audit — designing a multi-screen arc audit agent (two input modes)

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author an agent that audits **whole user-flow arcs** (multi-screen journeys felt as one experience) — the dimension that single-screen reviewers structurally miss. The agent supports **two input modes**: (a) walking a live flow end-to-end and grading it across eight gap classes, producing a canonical flow doc + dated gap report; (b) grading a pre-captured, ordered screenshot series (with manifest) across six continuity dimensions, producing a dated S/A/B/C/D/F continuity report. Both modes grade the same thing — arc-level continuity that per-screen review can't see — they just differ in what's handed to the agent: a live app to walk, or an already-captured series to grade.

## When to ship one (applicability gate)

Ship a flow-audit agent when:

- The project has **multi-screen user flows** — onboarding wizards, checkout flows, setup processes, sign-up → first-use arcs, account-deletion arcs.
- The project has shipped a "screens individually fine, the journey feels off" experience.
- Continuity properties — tone, pacing, disclosure rhythm — matter to the product.

Ship (or lean on) **mode (b)** specifically when, in addition:

- There's a **capture pipeline** that produces ordered screenshot series (Maestro / Playwright / equivalent autoplay) — mode (b) has nothing to grade without one.
- An **iterative polish loop** is desirable — mode (b) is the standard L1 grading layer in `iterative-polish-autoloop.md`, since it's cheap enough to run every iteration where a full live walk (mode a) is not.

Skip when:

- The project is single-screen or single-mode (no real arc structure).
- The flows are all 1-2 screens long (per-screen review is sufficient).
- The user explicitly handles arc-level review themselves and doesn't want it agent-mediated.
- (mode b specifically) There's no capture harness — without ordered screenshots, mode (b) has nothing to grade; fall back to mode (a) or skip.

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

### Mode (b)'s complementary taxonomy — six continuity dimensions

Mode (a)'s eight gap classes assume a live walk; mode (b) grades a pre-captured series against six **flow-level** dimensions that are the same underlying failure mode restated for a series-grading input:

- **Voice drifts mid-arc.** Screen 1 sounds like a senior PM; screen 4 sounds like a customer-service rep. Each screen reads fine individually.
- **CTA visual weight inverts.** "Confirm" at step 6 has more visual weight than "Confirm" at step 9 — confidence should *increase* across an arc, not decrease.
- **Loading vocabulary scatters.** Shimmer here, spinner there, skeleton somewhere else. The eye reads "this product wasn't designed together."
- **Disclosure pacing breaks.** Early-flow shows too much; late-flow shows too little. Or the reverse.
- **Color/tonality drifts.** Accent color used consistently for "active" on screens 1-5, then used for "warning" on screen 6.
- **Progress treatment scatters.** "N of 7" on screen 1, "Step 3" on screen 4, no indicator on screen 5.

A reviewer that only sees one screen at a time literally cannot see these. Grading the series in order is what makes them visible, exactly as walking the live arc makes the eight gap classes visible in mode (a).

## Core methodology — two input modes

The agent operates in one of two modes per invocation, chosen by what it's handed: a live app to walk (mode a), or a pre-captured manifest + screenshot series to grade (mode b). Mode (a) is the deep, infrequent audit — four phases, two artifacts. Mode (b) is the lightweight, frequent grader — one manifest in, one continuity report out — and composes with mode (a): mode (a) produces the canonical flow doc and periodic deep gap report; mode (b) grades a specific capture against the bar on every iteration of a polish loop or every commit on a polished arc. If a project can only justify authoring for one mode, mode (a) is the deeper analysis and covers more ground; mode (b) is what you lean on for continuous grading once a capture harness exists.

### Mode (a) — walking a live flow end-to-end

The agent walks four phases per invocation. Two artifacts come out the other end: a canonical flow doc (persistent) and a point-in-time gap report (dated).

#### Phase 1 — Arc inventory (scope locking)

The user's invocation is usually loose ("audit the onboarding flow"). Before walking, the agent locks scope:

1. Identify the **entry surface** — first screen of this arc.
2. Identify the **exit surface(s)** — where the user lands when the arc is "done."
3. Identify **branches and edges** — back, error, abandon paths.
4. Convert the loose name to a slug for file paths.

The output is a one-paragraph scope statement at the top of the audit doc: entry / exits / in-scope branches / out-of-scope adjacent arcs.

If the invocation is ambiguous ("audit onboarding" — does that include the post-signup setup wizard?), the agent ASKS before walking. Auditing the wrong arc wastes the run.

#### Phase 2 — Build / update the flow doc

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

#### Phase 3 — Gap detection (the eight classes)

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

#### Phase 4 — Produce the gap report

Dated audit doc with:
- Scope statement (from Phase 1)
- Arc map (summary of the flow doc)
- Findings table (per finding: surface, class, severity, description, fix recommendation, **Owner / Fix-by handoff column**)
- Resolution of prior audit's open items (which fixed, which remain, which are new)
- Routing recommendations (some findings route to other agents — IA gaps to design, UI polish to ux-audit, copy fixes to direct edit)

The agent **does not fix anything.** Audit + document only. Hand-off to specialist agents.

#### The "audit, don't fix" handoff column convention

Every findings-table row carries an explicit **Owner / Fix-by** column naming which agent (or direct-edit path) the finding routes to. This is the structural enforcement of the "audit, don't fix" discipline — without an explicit handoff column, the temptation to start applying fixes inline corrupts the audit artifact's purpose (the audit is the *persistent record*; fixes belong in commits + the prior-audit resolution table).

Recommended findings-table structure:

| ID | Surface | Gap class | Severity | Description | Fix recommendation | Owner / Fix-by |
|---|---|---|---|---|---|---|
| G-001 | <surface> | IA boundary | Crit | <description> | <one-line> | `product-designer` |
| G-002 | <surface> | Copy register | High | <description> | <one-line> | direct edit |
| G-003 | <surface> | UI inconsistency | Med | <description> | <one-line> | `ux-audit` |
| G-004 | <surface> | Motion drift | Med | <description> | <one-line> | direct edit |

The Owner column makes the routing explicit — the next-action reader (engineer, designer, project owner) knows where each finding goes. Without it, findings get "noted and moved on from"; with it, every row has a target landing zone.

### Mode (b) — grading a pre-captured screenshot series

The agent does NOT interact with the app in this mode. It grades pre-captured artifacts a caller hands it. Input is a manifest; output is a markdown report.

#### Step 1 — Input ingestion

The agent receives:

- **Audit directory path** — contains PNGs named `NN-screen-name.png` (e.g. `04-walk-tag-scanning.png`).
- **Manifest JSON path** — describes each screenshot's `step`, `name`, `path`, `context` (what state, how reached).
- **Flow context** — which flow (e.g. *"owner space-setup, 7 moments"*), which fixture drove synthetic data, deterministic quirks.

If the manifest is missing or malformed, the agent aborts and surfaces the gap — it does NOT mint its own capture.

#### Step 2 — Six flow-level dimensions

For each of the six dimensions named above (voice/tone, CTA weight progression, loading-state treatment, disclosure pacing, color/tonality drift, progress legibility), grade S/A/B/C/D/F with a one-paragraph justification referencing specific screens by step number. The dimensions are project-tunable (a `FLOW_CONTINUITY_DIMENSIONS` knob) — a project can add one (e.g. *"haptic-feedback consistency"* on iOS) or drop one that's moot (e.g. progress legibility, if there's no progress indicator in the arc).

#### Step 3 — Per-screen critique

For each screenshot in manifest order: grade (S–F); first impression / 2-second test (what the eye lands on, mood); what works (2-3 bullets); what fails (2-3 specific bullets — *"quality-pill contrast too low against map"* beats *"pill is bad"*); one thing to fix first (the highest-leverage change, not a list).

#### Step 4 — Lowest-graded screens callout

The 3 worst-graded screens — the caller may follow up with `ux-audit` drilldowns on these. For each: one sentence on why it's worth a deeper pass.

#### Step 5 — Regression delta (if prior runs exist)

Look in the same audit directory for prior manifest + report. If any exist: a table comparing per-screen grade deltas vs the most recent prior run, plus a one-paragraph narrative of what moved and why (likely cause if inferable from fixture/context).

#### Step 6 — Flow-level persona check

Beyond per-screen, apply `persona-testing` across the whole arc: does the voice stay in the same register from screen 1 to N? Does any screen treat the user as a stranger after an earlier screen already met them? A single failure here is a flow-level CRIT, even if every per-screen grade is S.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The project's actual arc inventory.** What flows exist? Onboarding? Checkout? Account-creation? Each is a candidate audit target.

2. **The project's flow-doc convention.** Where do flow docs live? `docs/flows/`? `docs/journeys/`? `.claude/flows/`? Encode the path.

3. **The project's audit-history convention.** Dated gap reports go where? `docs/audits/`? `.claude/audits/`? Encode.

4. **The project's deep-link / navigation structure.** The agent needs to know how to enumerate "next surface from here" given a route + handler.

5. **The platform-specific animation conventions.** What does "motion-language drift" look like in this project? Reanimated transitions? CSS transitions? View controller animations?

6. **The seed / fixture mechanism.** How does the agent get the app into the arc's starting state? Account fixture? Reset script? URL with params?

For mode (b), also gather:

7. **Flow continuity dimensions** → `FLOW_CONTINUITY_DIMENSIONS`. Six is the default; project may add (e.g. *"haptic-feedback consistency"* on iOS) or drop (e.g. progress legibility is moot if there's no progress indicator).
8. **Manifest schema** → `MANIFEST_SCHEMA`. The JSON shape the capture harness produces. Common: `{step, name, path, context}` per screenshot.
9. **Bridge reference apps** → `BRIDGE_REFERENCE_APPS`. References for elegant arc transitions (Apple iCloud onboarding, Stripe checkout, Telegram phone-number flow). Hard cuts between surfaces are an anti-pattern in modern mobile.
10. **Capture pipeline path.** The Maestro YAML / Playwright spec / equivalent the manifest was produced by. The agent doesn't run this, but the report can reference it.

## Authoring the agent

The final agent (typically `.claude/agents/flow-auditor.md`) should specify:

1. **When to fire vs refuse** — explicit refusal list for single-screen / single-tab / single-PR / new-design requests (applies to both modes).
2. **Input modes** — how the agent determines which mode applies (a live app handed vs a manifest + capture directory handed), and what each mode produces.
3. **Mandatory pre-audit reads** — rules, prior flow docs, prior audit/continuity history.
4. **Mode (a): the four phases** — scope-lock / build flow doc / detect gaps / produce audit report.
5. **Mode (a): the eight gap classes** — populated with project-specific examples.
6. **Mode (b): the six continuity dimensions** — graded individually with a manifest-referencing justification (step numbers cited).
7. **Mode (b): per-screen critique format** — grade / 2-second test / works / fails / one-fix-first.
8. **The severity tiers** — Crit / High / Med / Low (mode a) and the shared S/A/B/C/D/F scale (both modes), with project anchors.
9. **The output artifacts** — mode (a)'s canonical flow doc + dated gap report; mode (b)'s dated continuity report.
10. **The non-fixing constraint** — agent audits, doesn't fix, in either mode.

## Depth signatures — what battle-tested looks like

The authored `flow-auditor.md` is the most complex agent in the kit — across its two modes it walks a real arc AND grades a captured series, produces up to three artifact shapes (canonical flow doc / dated gap report / dated continuity report), grades 8 gap classes plus 6 continuity dimensions, and routes findings to other agents. Depth here is non-optional; a shallow flow audit can't even scope its own work.

1. **Named benchmarks** — Stripe checkout for arc continuity (every step feels like one experience; CTA progression is tight; back paths are explicit), WHOOP onboarding for disclosure pacing (information rationed without overwhelming), Apple Setup Assistant for transition bridges (every arc junction acknowledges the boundary), plus mode (b)'s bridge-reference apps (Apple iCloud onboarding, Telegram phone-number flow) for elegant transitions. The benchmark is what "arc done right" feels like, named.
2. **5+ inspection dimensions** — mode (a)'s **8 gap classes**: (a) copy/context mismatch, (b) IA boundary violations, (c) motion-language drift, (d) first-touch vs daily-driver drift, (e) disclosure pacing, (f) CTA weight progression, (g) dead-end surfaces, (h) missing transition bridges — plus mode (b)'s **6 continuity dimensions**: voice/tone, CTA weight progression, loading vocabulary, disclosure pacing, color/tonality drift, progress legibility. Each with a concrete check method.
3. **Rubric anchored per grade, for both modes** — mode (a): `S = no gaps across all 8 classes (Stripe-checkout-grade arc) / A = max Med findings, no Crit / B = up to High, no Crit / C = High count > 2 or 1 Crit / D = pervasive Crit / F = arc unshippable (dead-end + missing-bridge + copy mismatch + motion drift)`. Mode (b): `S = the arc reads as one designed product / A = coheres, one minor seam / B = one or two dimensions drift / C = a clear arc-level inconsistency / D = multiple dimensions drift, reads as separately-built screens / F = continuity broken or a persona failure, even if per-screen grades are S`. Per `audit-routing.md` cross-rubric translation.
4. **Report-format sections for both modes** — mode (a): **canonical flow doc** (`docs/flows/<arc-slug>.md` — order / surface / type / trigger / exit paths / visible copy verbatim / state variants) + **dated gap report** (`docs/audits/<arc-slug>-<date>.md` — scope statement / arc map summary / findings table by gap class with severity / prior-audit resolution status / routing recommendations). Mode (b): **dated continuity report** — summary / six flow-level dimensions / per-screen critique / lowest-graded callout / regression delta.
5. **Cross-references** — composes with `journey-audit/SKILL.md` (journey map is INPUT; built if missing), `element-reuse.md` (Gap class 1 operationalizes the reuse-gate matrix), `persona-testing.md` (mode b's flow-level persona check), `ux-audit.md` (per-screen polish findings from either mode route here), `interaction-audit.md` (per-screen dead-chrome / redundancy findings route here), `iterative-polish-autoloop.md` (mode b is the standard L1 grading layer there), `audit-routing.md` (refuses single-screen / single-tab / new-design requests; routing table maps refusals).
6. **Numbered non-negotiable rules covering both modes** — minimum 7: *(1) Scope-lock BEFORE walking in mode (a) — ambiguous "audit the onboarding" gets clarified or commits to a precise definition. (2) Walk the arc in the user's actual state, not statically from code, in mode (a) — runtime reveals which transitions fire which animations. (3) Produce BOTH mode (a) artifacts (flow doc + gap report). (4) Severity discipline — reserve Crit for ship-blockers (mode a: dead-end, daily-driver showing wizard copy, missing exit path; mode b: a persona failure across the arc). (5) Resolution-of-prior-audit / regression-delta section is mandatory whenever prior runs exist — without it every audit is rediscovery. (6) Audit does NOT fix — route findings to specialist agents (ux-audit / interaction-audit / direct edit) in either mode. (7) Refuse single-screen scope — that's `ux-audit`'s job. (8) Mode (b) never interacts with the app or invents a screen the manifest doesn't list — abort on a missing/malformed manifest instead.*
7. **Project-specific anti-patterns from git** — 3-5 from interview Phase D. E.g. *"Onboarding wizard ended at a dead-end screen for two days (commit `abc1234` added the exit) — every arc audit explicitly verifies every surface has a forward exit OR an explicit completion state."* *"Settings entry from onboarding leaked wizard copy onto daily-driver settings (commit `def5678`) — sweep for surfaces that are accessed from both arcs and grade copy register against access context."*
8. **Edge cases + abort conditions** — *"Refuse if scope is single-screen (route to `ux-audit`) / single-tab (route to `pages-audit`) / single-PR diff (use `code-review` instead) / new-design proposal (route to `product-designer` or equivalent). Abort mode (a) scope-lock if user can't articulate entry/exit surfaces — ask, don't walk blindly. Abort mode (a) if the arc isn't reachable in the current build. Abort mode (b) if the manifest is missing or malformed rather than minting a capture."*
9. **Calibration text** — `S-tier (mode a) looks like: <Stripe-checkout-grade arc — every step feels like one experience, the copy register matches surface type, CTA weight is monotonic, transitions are platform-idiomatic and consistent, every junction is acknowledged, no dead-ends, disclosure paced to information complexity>. F-tier (mode a) looks like: <onboarding ending at a dead-end, wizard copy on a daily-driver settings page, motion that cross-fades / slides / modal-presents at random steps, primary CTA disappearing between steps, jump-cut from sign-up to wizard with no welcome bridge>. S-tier (mode b) looks like: <a 7-screen capture where voice, CTA weight, loading vocabulary, and accent color all hold from screen 1 to 7>. F-tier (mode b) looks like: <voice swinging from senior-PM to customer-service-rep mid-arc, or a persona failure on one screen even though every per-screen grade is S>.`
10. **Operational specifics** — the project's arc inventory derived from Phase 1 (signup arc / onboarding wizard / checkout / settings-deletion arc — whichever apply). The flow-doc convention (`docs/flows/<slug>.md` vs `.claude/flows/<slug>.md` — encode the project's choice). The seed/fixture mechanism (how does mode a get into the arc's starting state? Fixture account? URL params? Reset script?). The platform-specific animation conventions (Reanimated transitions / CSS transitions / view-controller animations) — required for mode (a)'s motion-drift detection. Mode (b)'s manifest schema and capture-pipeline path.

If the authored `flow-auditor.md` lacks any of these, redo. Arc audits without depth scope creep, produce one-off discovery, and fail to compose with the rest of the kit.

## Cross-references

- `journey-mapping.md` — the journey map is the input to mode (a). If no map exists for the arc's surfaces, the agent builds one.
- `element-reuse.md` — Gap class 1 (copy/context mismatch) operationalizes the reuse-gate matrix.
- `persona-testing.md` — mode (b)'s flow-level persona check applies this lens across the whole arc; a single failure is CRIT even if every per-screen grade is S.
- `ux-audit.md` — UI polish findings from either mode route to ux-audit; mode (b)'s 3 lowest-graded screens are its natural drilldown targets.
- `interaction-audit.md` — dead-chrome / redundant-affordance findings on individual surfaces route to interaction-audit.
- `iterative-polish-autoloop.md` — mode (b) is the standard L1 grading layer for multi-screen autoloops (cheap enough to run every iteration).
- `audit-routing.md` — full routing rules. Flow-audit refuses single-screen / single-tab / single-PR in either mode.
- `quality-rubric.md` — severity cross-rubric translation; Crit-class flow gaps block ship.

## Anti-patterns in the agent you write

- **Auditing without scope-lock (mode a).** "Audit the onboarding flow" ranges from sign-up to first day. The agent must ASK or commit to a precise scope before walking, or the audit covers a different arc than the user meant.

- **Skipping the canonical flow doc (mode a).** The audit's value compounds when the flow doc is the persistent artifact future work reads. An audit without a flow doc is point-in-time-only and re-does discovery on every invocation.

- **Per-screen findings instead of arc findings (either mode).** The agent's value is in the BETWEEN. If 80% of the report is per-screen polish, the work belongs to ux-audit. In mode (b): if the report would still be valid with the screens shuffled into random order, the agent graded N independent screens and missed the job.

- **Fixing instead of routing.** The agent audits and documents; it does NOT apply fixes, in either mode. Fixes have their own paths (design agent / direct edit / interaction-audit).

- **Walking the arc without entering the user state (mode a).** If the audit reads the code statically without reproducing the arc in the app, it misses runtime patterns (which surfaces fire which transitions in practice). Capture is part of the audit.

- **Interacting with the app in mode (b).** Mode (b) grades captured screenshots. Driving Maestro / Playwright is the capture step's job, not the agent's. If the frontmatter tool list nudges the agent toward capture tools in mode (b), it will reflexively recapture instead of grading.

- **Severity inflation.** Tagging every finding as Crit dilutes the meaning. Reserve Crit for ship-blockers (mode a: dead-end surfaces, daily-driver showing wizard copy; mode b: a persona failure across the arc). Severity tiers are calibrated against actual user impact.

- **No resolution-of-prior-audit / regression-delta section.** Without it, every run is full-discovery and the user can't track progress. The agent should explicitly mark which prior findings are fixed, which remain, which are new (mode a), or table the per-screen grade deltas vs the most recent prior run (mode b).

- **Mode (b) invents a screen not in the manifest.** If the manifest lists 12 screenshots, grade 12. If one is missing (capture crashed mid-arc), flag it and grade what's there.

- **Refusing the wrong things.** Refusing legitimate arc audits because the user invoked with a single-screen phrase is over-correction. The refusal list should be narrow and the agent should accept arc-shaped intent even if the phrasing was loose.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash`, `Write` (to write the flow doc + gap report + continuity report), `Edit` (to update the flow doc as it evolves), plus platform-specific capture + navigation tools for mode (a). Mode (b) deliberately uses none of the capture/navigation tools even though they're in the same agent's tool budget — grading, not driving, is the job.

Model: high-capability. Multi-screen continuity reasoning benefits from depth, in either mode.
Effort: high. Mode (a)'s live walk + two artifacts is a substantial run; mode (b) is cheaper per invocation (no capture, one report) but still benefits from depth since it's the layer that runs most frequently (e.g. every iteration of a polish loop).
