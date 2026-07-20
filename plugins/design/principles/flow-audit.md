# flow-audit — designing a multi-screen arc audit agent (two input modes)

Teaching material for Claude Code. Teaches you how to author an agent that audits **whole user-flow arcs** (multi-screen journeys felt as one experience) — the dimension single-screen reviewers structurally miss. It grades the same thing in **two input modes**, differing only in what's handed to it: (a) a live app to walk end-to-end, graded across eight gap classes, producing a canonical flow doc + dated gap report; (b) a pre-captured, ordered screenshot series with manifest, graded across six continuity dimensions, producing a dated S/A/B/C/D/F continuity report.

## When to ship one

Ship a flow-audit agent when the project has multi-screen user flows (onboarding wizards, checkout, setup, sign-up → first-use, account-deletion arcs), has shipped a "screens individually fine, the journey feels off" experience, and continuity properties (tone, pacing, disclosure rhythm) matter. Ship **mode (b)** specifically when there's also a capture pipeline producing ordered screenshot series (Maestro / Playwright — mode b has nothing to grade without one) and an iterative polish loop is desirable (mode b is the standard L1 grading layer in `iterative-polish-autoloop.md`, cheap enough to run every iteration where a full live walk isn't). Skip when the project is single-screen, flows are all 1-2 screens (per-screen review suffices), or the user handles arc review themselves.

## Why it matters

Per-screen reviewers grade screens; they cannot grade the **journey between screens**, where the most important UX failures hide — invisible to single-screen review (`ux-audit.md`: each screen passes its own grade), cross-section review (`pages-audit.md`: different scope), and code review (each diff is fine). Only walking the arc and grading CONTINUITY catches them.

**Mode (a) — the eight gap classes (live walk):**
1. **Copy / context mismatch** — a string authored for first-touch leaks onto a daily-driver surface. Each screen reads fine; the journey makes it glaring.
2. **IA boundary violations** — arcs that should be separate are joined, or one arc is split across boundaries the user perceives as one (Wizard → Settings where it should be Wizard → Daily-Home; deep links bypassing stages).
3. **Motion-language drift** — step 1 cross-fades, step 2 slides, step 3 modal-presents; each idiomatic in isolation, the journey feels stuttery.
4. **First-touch vs daily-driver drift** — a wizard surface revisited as a daily destination still apologizes / introduces / teaches when it should be operational.
5. **Disclosure pacing** — critical info dumped on screen 1 (overwhelming) or trickled past screen 5 (frustrating).
6. **CTA weight progression** — solid CTA at step 1, ghost button at step 2, list-row chevron at step 3; the user can't tell where the primary action is.
7. **Dead-end surfaces** — a screen with no clear exit; back strands the user, the forward action doesn't fire.
8. **Missing transition bridges** — two arcs meet at a junction with no acknowledgement; a hard cut where there should be a welcome across the boundary.

**Mode (b) — the six continuity dimensions (captured series):** the same underlying failure restated for series-grading — **voice drift** (screen 1 sounds like a senior PM, screen 4 like a support rep), **CTA weight inversion** (confidence should increase across an arc, not decrease), **loading-vocabulary scatter** (shimmer here, spinner there, skeleton elsewhere — "not designed together"), **disclosure pacing** breaks, **color/tonality drift** (accent = "active" on screens 1-5, "warning" on 6), **progress-treatment scatter** ("N of 7", then "Step 3", then no indicator). A reviewer who sees one screen at a time literally cannot see these; grading the series in order is what makes them visible.

## Core methodology — two modes

The agent picks its mode by what it's handed. Mode (a) is the deep, infrequent audit (four phases, two artifacts); mode (b) is the lightweight, frequent grader (one manifest in, one report out). They compose: (a) produces the canonical flow doc and periodic deep gap report; (b) grades a specific capture against the bar on every polish-loop iteration or commit. If only one can be authored, mode (a) is the deeper analysis; mode (b) is what you lean on for continuous grading once a capture harness exists.

### Mode (a) — walking a live flow

**Phase 1 — Arc inventory (scope-lock).** The invocation is usually loose (*"audit the onboarding flow"*). Before walking, identify the entry surface, the exit surface(s), and the branches/edges (back, error, abandon), and slug the arc name. Output: a one-paragraph scope statement (entry / exits / in-scope branches / out-of-scope adjacent arcs). If ambiguous (does "onboarding" include the post-signup wizard?), ASK — auditing the wrong arc wastes the run.

**Phase 2 — Build / update the flow doc.** For each surface in traversal order, capture:

| Field | What to capture |
|---|---|
| Order | 1, 2, 3, … |
| Surface name | Human-readable label |
| File:line | Component path + line of relevant copy / state |
| Type | first-touch / daily-driver / settings / error / promotional / bridge |
| Trigger | What routes the user TO this surface |
| Exit paths | Where the user can go FROM this surface |
| Visible copy (verbatim) | Pulled from source / translation, NOT paraphrased |
| Components mounted | Key components with file refs |
| State variants | empty / typical / overflow / loading / error — or "not present" |

The flow doc is the canonical arc reference future work reads as truth. Overwrite it each run (it's the current state); preserve prior gap reports as history.

**Phase 3 — Gap detection (the eight classes).** Walk the arc looking for each class above: run the reuse-gate (`element-reuse.md`) on every visible string for class 1; check routing / deep-links for class 2; compare transitions for class 3; match copy register to access context for class 4; assess cumulative disclosure for class 5; check CTA consistency step-to-step for class 6; list every surface's exits (none = dead-end) for class 7; check junction acknowledgement for class 8. Each finding gets a severity (Crit / High / Med / Low) and a fix recommendation.

**Phase 4 — Gap report.** Dated doc with the scope statement, an arc-map summary, a findings table, the resolution of the prior audit's open items (fixed / remain / new), and routing recommendations. The agent **audits, does not fix** — every findings row carries an explicit **Owner / Fix-by** column naming where it routes, which is the structural enforcement of that discipline (without it, findings get "noted and moved on from"):

| ID | Surface | Gap class | Severity | Description | Fix recommendation | Owner / Fix-by |
|---|---|---|---|---|---|---|
| G-001 | <surface> | IA boundary | Crit | <description> | <one-line> | `product-designer` |
| G-002 | <surface> | Copy register | High | <description> | <one-line> | direct edit |
| G-003 | <surface> | UI inconsistency | Med | <description> | <one-line> | `ux-audit` |

### Mode (b) — grading a captured series

The agent does NOT interact with the app here; it grades pre-captured artifacts.

**Step 1 — Ingest input:** an audit directory of PNGs named `NN-screen-name.png`, a manifest JSON describing each screenshot's `{step, name, path, context}`, and flow context (which flow, which fixture, deterministic quirks). If the manifest is missing or malformed, ABORT and surface the gap — never mint a capture.

**Step 2 — Six flow-level dimensions.** Grade each (voice/tone, CTA weight progression, loading-state treatment, disclosure pacing, color/tonality drift, progress legibility) S/A/B/C/D/F with a one-paragraph justification citing specific screens by step number. Project-tunable via `FLOW_CONTINUITY_DIMENSIONS` (add e.g. haptic-feedback consistency on iOS; drop progress legibility if there's no indicator).

**Step 3 — Per-screen critique.** For each screenshot in manifest order: grade, the 2-second test (what the eye lands on, the mood), what works (2-3 bullets), what fails (2-3 *specific* bullets — *"quality-pill contrast too low against map"* beats *"pill is bad"*), one thing to fix first.

**Step 4 — Lowest-graded callout.** The 3 worst screens, each with one sentence on why it's worth a deeper `ux-audit` pass.

**Step 5 — Regression delta.** If prior manifest + report exist in the directory, table the per-screen grade deltas vs the most recent run plus a one-paragraph narrative of what moved and why.

**Step 6 — Flow-level persona check.** Apply `persona-testing` across the whole arc: does the voice hold register from screen 1 to N? Does any screen treat the user as a stranger after an earlier screen met them? A single failure here is a flow-level CRIT even if every per-screen grade is S.

## How to derive THIS project's specifics

1. **The arc inventory** — which flows exist (onboarding / checkout / account-creation); each is a candidate target.
2. **The flow-doc convention** — where flow docs live (`docs/flows/`, `.claude/flows/`).
3. **The audit-history convention** — where dated gap reports go (`docs/audits/`).
4. **The deep-link / navigation structure** — so the agent can enumerate "next surface from here" given a route + handler.
5. **Platform animation conventions** — what "motion drift" looks like here (Reanimated / CSS / view-controller transitions); required for mode (a).
6. **The seed / fixture mechanism** — how mode (a) reaches the arc's starting state (fixture account, reset script, URL params).

For mode (b), also: **`FLOW_CONTINUITY_DIMENSIONS`** (six default, add/drop per project); **`MANIFEST_SCHEMA`** (the JSON shape the harness produces, commonly `{step, name, path, context}`); **`BRIDGE_REFERENCE_APPS`** for elegant transitions (Apple iCloud onboarding, Stripe checkout, Telegram phone-number flow — hard cuts between surfaces are an anti-pattern); and the **capture-pipeline path** the manifest came from (the agent references it but doesn't run it).

## Authoring the agent

The final agent (typically `.claude/agents/flow-auditor.md`) assembles the two modes, the eight gap classes and six dimensions, the flow-doc and findings-table formats, and the artifact set above, plus these project-specific pieces:

- **Named benchmarks** — Stripe checkout for arc continuity (every step feels like one experience, CTA progression tight, back paths explicit), WHOOP onboarding for disclosure pacing, Apple Setup Assistant for transition bridges, plus mode (b)'s bridge-reference apps.
- **Rubric anchored per grade, both modes** — mode (a): `S = no gaps across all 8 classes (Stripe-checkout-grade) · A = max Med, no Crit · B = up to High, no Crit · C = High > 2 or 1 Crit · D = pervasive Crit · F = arc unshippable`. Mode (b): `S = reads as one designed product · A = coheres, one minor seam · B = one or two dimensions drift · C = a clear arc-level inconsistency · D = reads as separately-built screens · F = continuity broken or a persona failure even if per-screen grades are S`.
- **Project anti-patterns from git** (3-5): *"Onboarding wizard ended at a dead-end for two days (fix `abc1234`) — every arc audit verifies each surface has a forward exit or an explicit completion state."* *"Settings entry from onboarding leaked wizard copy onto daily-driver settings (fix `def5678`) — grade copy register against access context for any surface reached from both arcs."*
- **Calibration** — *S-tier (a): Stripe-checkout-grade — copy register matches surface type, CTA weight monotonic, transitions consistent, every junction acknowledged, no dead-ends. F-tier (a): onboarding ending at a dead-end, wizard copy on daily-driver settings, motion random per step, primary CTA vanishing between steps. S-tier (b): a 7-screen capture where voice, CTA weight, loading vocabulary, and accent color hold from 1 to 7. F-tier (b): voice swinging senior-PM → support-rep mid-arc, or a persona failure on one screen despite every per-screen grade being S.*
- **Non-negotiable rules**, each with its why: scope-lock BEFORE walking (mode a) · walk the arc in the user's actual runtime state, not statically (mode a — runtime reveals which transitions fire) · produce BOTH mode-(a) artifacts · severity discipline (reserve Crit for ship-blockers: dead-end / daily-driver-showing-wizard-copy / missing-exit in mode a, a persona failure across the arc in mode b) · the prior-audit-resolution / regression-delta section is mandatory whenever prior runs exist (without it every audit is rediscovery) · audit does NOT fix — route findings · mode (b) never interacts with the app or invents a screen the manifest doesn't list (abort on a bad manifest instead).
- **Refusals** — single-screen (→ `ux-audit`), single-tab (→ `pages-audit`), single-PR diff (→ `code-review`), new-design proposal (→ `product-designer`). Keep the list narrow — accept arc-shaped intent even when the phrasing was loose.

## Tool surface

`Read`, `Grep`, `Glob`, `Bash`, `Write` (flow doc + gap report + continuity report), `Edit` (update the flow doc), plus platform capture + navigation tools for mode (a). Mode (b) deliberately uses none of the capture/navigation tools even though they're in the budget — grading, not driving, is the job (a capture-tool nudge makes it reflexively recapture instead of grading). Model: high-capability (multi-screen continuity reasoning benefits from depth). Effort: high — mode (a)'s live walk + two artifacts is substantial; mode (b) is cheaper per run but still benefits from depth since it runs most frequently.

## Cross-references

- `journey-mapping.md` — the journey map is mode (a)'s input; built if missing.
- `element-reuse.md` — gap class 1 operationalizes the reuse-gate matrix.
- `persona-testing.md` — mode (b)'s flow-level persona check applies this across the arc; a single failure is CRIT.
- `ux-audit.md` / `interaction-audit.md` — per-screen polish and dead-chrome findings from either mode route here; mode (b)'s 3 lowest-graded screens are natural drilldown targets.
- `iterative-polish-autoloop.md` — mode (b) is the standard L1 grading layer.
- `audit-routing.md` — full routing rules; flow-audit refuses single-screen / single-tab / single-PR in either mode.
- `quality-rubric.md` — severity cross-rubric translation; Crit-class flow gaps block ship.
