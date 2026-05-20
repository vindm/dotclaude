# ux-audit — designing a single-screen visual polish agent for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a single-screen UX-review agent that grades against project-specific benchmarks rather than vibes.

## When to ship one (applicability gate)

Ship a ux-audit agent when:

- The project has **user-facing screens** that are graded against a quality bar.
- The user has a named bar ("we want to look like X").
- Visual polish has been a recurring concern — work has been sent back for polish, or shipped surfaces have been "good enough but not quite right."

Skip when:

- The project has no UI (CLI / library / API).
- The project's UI is generated wholesale by a design system / framework with no per-screen latitude (e.g., admin-jsonforms).
- The user is explicitly fine with "functional, not polished" — UX audit is friction without lift in that posture.

## Why it matters — what this catches that nothing else does

The agent catches the gap between **"this screen functions correctly"** and **"this screen would not embarrass us next to the apps we admire."** Specifically:

- **Vibes-grading.** Without a named reference, "looks fine" is unstable. The same screen rates fine on Monday and rough on Tuesday depending on the reviewer's mood. A named-benchmark grade is reproducible.
- **Composition pitfalls.** Duplicated info elements, orphan controls, tone mismatches, hierarchy violations, residue from previous states. Each is invisible per-element; only screen-as-composition reveals them.
- **Chrome-vs-domain parity gaps.** A screen can be at chrome parity (the materials, motion, typography are right) but fail the domain bar (the empty state apologizes instead of teaching). Or vice versa. Naming both dimensions separates the diagnosis.
- **Voice / copy drift.** Strings that read fine in isolation but feel wrong for the surface type (see `journey-mapping.md`).
- **Default-render acceptance.** "It looks like the framework wants it to look" — i.e., a default-Material screen on a project that should look bespoke. The audit catches surfaces that haven't been actively designed.

## Core methodology — three layers

The audit operates on three layers:

### Layer 1 — Capture

Before grading anything, capture the screen. Per `visual-verification.md`:
- Pick the right device target (project-specific; web → headless browser; iOS → simulator or device; etc.).
- Use the cheap-by-default capture path (CLI returns a file path; expensive only when bytes are needed for inspection).
- Confirm the captured state is the change-under-review's state, not a stale cache / wrong build / different device.

### Layer 2 — Journey classification

Per `journey-mapping.md`, classify the target screen's type: first-touch / daily-driver / settings / error / promotional / bridge. This is mandatory before grading because:
- The forbidden-patterns matrix depends on the type.
- The bar differs by type — a wizard screen is graded against onboarding references; a daily-driver against daily-driver references.
- "Hi — I'm <assistant>" is correct on a first-touch surface and wrong on a daily-driver surface.

If the agent can't classify the target (because the journey map hasn't been built), it should STOP and ask the user to run journey-mapping first. No grading without classification.

### Layer 3 — Two-tier benchmark grading

Every screen is graded against TWO references:

**Tier 1 — chrome reference.** What does the project's platform's gold-standard chrome look like? Examples:
- iOS app → Apple iOS 26 system apps (Music, Settings, Photos, Wallet) + Telegram on iOS 26.
- Android app → Material Design 3 reference apps + Telegram.
- Web app (general) → Linear + Vercel + Stripe.
- Web app (developer-focused) → Linear + Raycast Web + GitHub.
- Desktop app → native platform conventions (Apple HIG for macOS, Win11 Fluent for Windows).
- CLI / TUI → `gh`, `lazygit`, `htop`, Things 3 (as gold standard for first-run quality).
- B2B SaaS → Linear + Notion + Figma.

**Tier 2 — domain reference.** What's the bar for THE TYPE OF SURFACE this screen is? Examples:
- Onboarding flow → WHOOP onboarding, Things 3 first-run, Stripe checkout.
- Dashboard → Linear inbox, Superhuman triage, Vercel project view.
- Empty state → Things 3, Raycast.
- Settings → Apple Settings, Telegram settings, Linear settings.
- Auth flow → Stripe sign-in, Linear sign-in.
- Activity feed → Strava, Linear changelog.
- Detail / drill-in → Apple App Store detail page, Notion page.

When grading, the agent names BOTH tiers' references and says what's missing relative to each. *"Chrome at Apple-Settings parity; empty state below Things 3 — Things teaches; ours apologizes."*

The grade itself is per the `quality-rubric.md` scale (S/A/B/C/D/F) with concrete reference anchors per tier.

### The five composition pitfalls

For every screen, the agent scans for the five universal composition mistakes:

1. **Duplication** — two or more elements communicating the same fact.
2. **Orphan elements** — controls with no clear job; residue from prior states.
3. **Tone mismatch** — element's voice doesn't match the user's situation.
4. **Hierarchy violations** — visual weight not aligned to importance.
5. **Residue / cruft** — overlay chrome covering interactive content.

Even one named hit means not-done. The agent surfaces each finding with a screenshot pointer and a one-sentence fix proposal.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The project's Tier 1 references.** Ask: *"When you say S-tier, which specific apps do you mean?"* These are platform-specific and stable.

2. **The project's Tier 2 references.** Ask: *"For onboarding / dashboard / settings / empty-state / etc., which apps do you grade against?"* Domain-specific.

3. **The project's platform.** Web / iOS / Android / desktop / CLI / something else. The capture path and the Tier 1 references derive from this.

4. **The project's hot-iteration UI areas.** Where does most visual polish work happen? These are the surfaces the audit will run on most often.

5. **The project's design-system primitives.** Components, tokens, themes, motion presets. The audit should check for primitive usage (rather than ad-hoc re-implementation of the same chrome).

6. **The capture + inspection commands.** Project-specific. Get the exact commands the user runs to screenshot the target environment.

## Authoring the agent

The final agent (typically `.claude/agents/ux-reviewer.md`) should specify:

1. **Device-target picker** — which capture path applies (sim / device / browser / etc.) and how to confirm.
2. **The capture commands** — cheap-by-default per `visual-verification.md`.
3. **The journey-classification gate** — mandatory before grading; stop if not done.
4. **The Tier 1 / Tier 2 benchmark tables** — populated with this project's actual references.
5. **The five composition pitfalls** — referenced from `quality-rubric.md`.
6. **The S/A/B/C/D/F grading scale** — referenced from `quality-rubric.md`.
7. **The report format** — overall grade + per-tier finding + composition pitfalls + named "next move up one tier."
8. **The "do not present without a captured artifact" rule** — every audit references the screenshot it graded.

## When to dispatch this agent

The agent is for **single-screen** visual polish. It explicitly REFUSES:
- Multi-screen arcs → recommend `flow-audit.md`
- Cross-tab consistency → recommend `pages-audit.md`
- Accessibility → run `a11y-audit.md` in parallel
- Semantic chrome integrity → run `interaction-audit.md` first

See `audit-routing.md` for the full routing rules.

## Report format

```markdown
## UX Audit — <screen name> — <date>

### Captured artifact
<path to screenshot the audit graded>

### Surface type
<first-touch | daily-driver | settings | error | promotional | bridge> — per journey map

### Overall grade: <S/A/B/C/D/F>
<one-paragraph diagnosis>

### Tier 1 (chrome) vs <named reference>
<what we do well, what's missing, one-sentence "next move">

### Tier 2 (domain) vs <named reference>
<what we do well, what's missing, one-sentence "next move">

### Composition pitfalls
- Duplication: <found / not-found> — <if found, what + fix>
- Orphan elements: <found / not-found>
- Tone mismatch: <found / not-found>
- Hierarchy violations: <found / not-found>
- Residue / cruft: <found / not-found>

### Highest-ROI move to push up one tier
<single concrete action>
```

## Depth signatures — what battle-tested looks like

The authored `ux-reviewer.md` agent fails the depth bar if it lacks any of these 10 structural elements. Tune per the interview's answers — the textbook is here, but the *project-specific* anchors come from the user.

1. **Named benchmarks** — the **2-3 Tier 1 apps + 2-3 Tier 2 apps with dimensions** the user named in interview B1/B2 appear by name in the agent body. Not "modern apps" — the names. E.g. *"Tier 1 chrome = Linear + Stripe Dashboard. Tier 2 = Things 3 for empty states (they teach, not apologize), Linear for keyboard-affordance discoverability."*
2. **5+ inspection dimensions** — chrome material, motion language, type scale conformance, color discipline, hierarchy, copy register, hit-target consistency. Each with a concrete read method (grep pattern / hierarchy command / manual visual scan against a captured screenshot).
3. **Rubric anchored per grade** — `S = looks like a Linear screen next to a Linear screen / A = ships at Linear quality with one polish pass / B = competent SaaS but visibly ours / C = ships but lags / D = embarrassing / F = block ship`. Each grade name-checks the benchmark.
4. **Report-format sections** — `## Captured artifact / ## Surface type (from journey map) / ## Overall grade / ## Tier 1 (chrome) vs <named ref> / ## Tier 2 (domain) vs <named ref> / ## Composition pitfalls (5 named) / ## Highest-ROI move`. Predictable structure.
5. **Cross-references** — composes with `journey-audit/SKILL.md` (mandatory surface-type classification BEFORE grading), `visual-verification.md` (capture precondition), `interaction-audit.md` (runs BEFORE so semantic fixes don't shift layout under the visual review), `a11y-audit.md` (runs in parallel — orthogonal dimensions), `quality-bar/SKILL.md` (composition pitfalls source).
6. **Numbered non-negotiable rules** — minimum 6: *(1) Never grade without a captured screenshot — pixel review is the contract. (2) Never grade without surface-type classification — register depends on type. (3) Tier 1 + Tier 2 BOTH named in every grade — chrome and domain are separable. (4) Composition pitfalls scanned BEFORE the grade, not after — they inform the grade. (5) "Highest-ROI move" is one concrete action, not a list. (6) Refuse multi-screen scope and route to `flow-audit`.* Each with a rationale clause.
7. **Project-specific anti-patterns from git** — 3-5 from interview Phase D bug-mining. E.g. *"Settings page bypassed the type scale for 2 weeks (commit `abc1234`) — scan for typography violations against the scale on EVERY settings-class surface."* The SHA and the symptom are both present.
8. **Edge cases + abort conditions** — *"Abort if surface isn't reachable in current build. Abort if captured screenshot timestamp is older than last edit. Refuse multi-screen requests. Refuse if Tier 1 benchmark unspecified."*
9. **Calibration text** — `S-tier looks like: <Linear-quality screen sitting next to a Linear screen with no visible drop in chrome rigor; hierarchy reads at 1m; empty state teaches>. F-tier looks like: <default-Material rendering, type-scale violations, apologetic empty state, hierarchy noise>.`
10. **Operational specifics** — capture commands derived from Phase 1 (Playwright? Maestro? `xcrun simctl io`? manual + Cmd-Shift-3?). File paths to the user's theme tokens. The user's actual component-library directory. Names of the user's primary chrome surfaces (e.g. settings sheet, dashboard cards, modal headers).

If the authored `ux-reviewer.md` lacks any of these, redo. Battle-tested ≠ optional polish.

## Cross-references

- `visual-verification.md` — capture discipline. The audit grades captured artifacts; capture is the precondition.
- `journey-mapping.md` — surface-type classification. The audit's grading lens depends on type.
- `quality-rubric.md` — the S/A/B/C/D/F anchors and composition pitfalls.
- `design-benchmarking.md` — the Tier 1 / Tier 2 reference picking methodology.
- `audit-routing.md` — when to dispatch this agent vs. flow-audit / pages-audit / interaction-audit / a11y-audit.
- `interaction-audit.md` — semantic chrome integrity; runs BEFORE ux-audit because semantic fixes shift layout.
- `a11y-audit.md` — accessibility audit; runs in parallel with interaction-audit.

## Anti-patterns in the agent you write

- **Grading without capture.** "I read the code and it looks fine" — no. The agent grades pixels, not source. Every report cites the captured artifact path.

- **Tier 1 reference unspecified.** "Apple-tier" is vibes. "Apple iOS 26 Settings + Telegram on iOS 26" is enforceable. Specify the references.

- **Skipping the journey map.** Without surface-type classification, the forbidden-patterns don't apply correctly. The agent should stop if classification isn't done.

- **Grading per-element instead of per-composition.** A screen full of individually-fine elements can still be a B-tier composition if there's duplication / orphan / hierarchy chaos. The audit looks at the screen as a whole.

- **No "next move up one tier" guidance.** A grade alone says "B." A grade plus the move says "B; the highest-ROI move to A is rewrite the empty state's copy." The second form is actionable.

- **Auditing surfaces the user can't currently reach.** If the audit grades a screen state the app's current state doesn't expose, the user can't act on the findings. Verify the screen is reachable in the current build before grading.

- **Mixing single-screen and multi-screen scope.** The agent refuses multi-screen; it doesn't try. Route to `flow-audit`.

- **Lossy summaries.** "Grade B, some issues" — useless. The audit's value is in specific findings with screenshot anchors and exact fixes. Pad-to-look-thorough loses signal.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash`, plus capture / interaction tools specific to the platform (browser automation, simulator CLI, MCP visual tools, etc.). It does NOT need `Edit` or `Write` to source files — it produces an audit doc, which it can write, but it should never directly edit the UI source as part of the audit.

Model: highest-capable. UX grading benefits from the model's visual reasoning depth.
Effort: high. This is one of the most expensive agent runs in the inventory; don't dispatch reflexively.
