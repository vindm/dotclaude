# ux-audit — designing a single-screen visual polish agent for ANY project

Teaching material for Claude Code. Teaches you how to author a single-screen UX-review agent that grades against project-specific benchmarks rather than vibes.

## When to ship one

Ship a ux-audit agent when the project has user-facing screens graded against a quality bar, the user has a named bar (*"we want to look like X"*), and visual polish has been a recurring concern (work sent back for polish, or surfaces "good enough but not quite right"). Skip when there's no UI (CLI / library / API), when the UI is generated wholesale by a design system with no per-screen latitude, or when the user is explicitly fine with "functional, not polished."

## Why it matters

The agent catches the gap between *"this screen functions"* and *"this screen would not embarrass us next to the apps we admire"*:

- **Vibes-grading.** Without a named reference, "looks fine" rates fine Monday and rough Tuesday. A named-benchmark grade is reproducible.
- **Composition pitfalls** — duplicated info, orphan controls, tone mismatch, hierarchy violations, residue from prior states. Each is invisible per-element; only screen-as-composition reveals them.
- **Chrome-vs-domain parity gaps** — a screen can hit chrome parity (materials, motion, typography) yet fail the domain bar (the empty state apologizes instead of teaching), or vice versa. Naming both dimensions separates the diagnosis.
- **Voice / copy drift** — strings that read fine in isolation but feel wrong for the surface type.
- **Default-render acceptance** — a default-Material screen on a project that should look bespoke; the audit catches surfaces that were never actively designed.

## Core methodology — three layers

**Layer 1 — Capture** (per `visual-verification.md`). Pick the right device target (web → headless browser; iOS → simulator / device); use the cheap-by-default capture path (CLI returns a file path; bytes only when needed); confirm the captured state is the change-under-review's, not a stale cache / wrong build.

**Layer 2 — Journey classification** (per `journey-mapping.md`). Classify the surface: first-touch / daily-driver / settings / error / promotional / bridge. Mandatory before grading — the banned-copy patterns depend on the type, the bar differs by type, and *"Hi — I'm <assistant>"* is correct on first-touch and wrong on a daily-driver. If the agent can't classify (the journey map isn't built), STOP and ask the user to run journey-mapping first.

**Layer 3 — Two-tier benchmark grading.** Every screen graded against TWO references, both named:

- **Tier 1 — chrome reference:** the platform's gold-standard chrome (iOS → Apple system apps + Telegram; Web general → Linear + Vercel + Stripe; Web dev-focused → Linear + Raycast + GitHub; desktop → platform HIG; CLI/TUI → `gh`, `lazygit`, Things 3; B2B SaaS → Linear + Notion + Figma).
- **Tier 2 — domain reference:** the bar for THIS surface type (Onboarding → WHOOP, Things 3 first-run, Stripe checkout; Dashboard → Linear inbox, Superhuman; Empty state → Things 3, Raycast; Settings → Apple Settings, Telegram; Auth → Stripe sign-in; Detail → App Store detail, Notion page).

Name both references and say what's missing relative to each: *"Chrome at Apple-Settings parity; empty state below Things 3 — Things teaches, ours apologizes."* Grade per the `quality-rubric.md` scale.

**The five composition pitfalls** — scan every screen: **duplication** (two elements, same fact), **orphan elements** (controls with no clear job, residue), **tone mismatch** (voice vs situation), **hierarchy violations** (weight vs importance), **residue / cruft** (overlay chrome over interactive content). Even one hit means not-done; surface each with a screenshot pointer and a one-sentence fix.

## How to derive THIS project's specifics

1. **Tier 1 references** — *"When you say S-tier, which specific apps?"* Platform-specific, stable.
2. **Tier 2 references** — *"For onboarding / dashboard / settings / empty-state, which apps do you grade against?"* Domain-specific.
3. **The platform** — drives the capture path and the Tier 1 references.
4. **Hot-iteration UI areas** — where polish work concentrates; the audit runs there most.
5. **Design-system primitives** — components, tokens, motion presets; the audit checks primitive usage over ad-hoc re-implementation.
6. **Capture + inspection commands** — the exact commands for screenshotting the target.

## Report format

```markdown
## UX Audit — <screen> — <date>

### Captured artifact: <path the audit graded>
### Surface type: <first-touch | daily-driver | settings | error | promotional | bridge> — per journey map
### Overall grade: <S/A/B/C/D/F>
<one-paragraph diagnosis>

### Tier 1 (chrome) vs <named reference>
<done well · missing · one-sentence next move>

### Tier 2 (domain) vs <named reference>
<done well · missing · one-sentence next move>

### Composition pitfalls
- Duplication / Orphan / Tone mismatch / Hierarchy / Residue: <found + fix | not-found>

### Highest-ROI move to push up one tier
<single concrete action>
```

## Authoring the agent

The final agent (typically `.claude/agents/ux-reviewer.md`) assembles the three layers, the five pitfalls, and the report format above, plus these project-specific pieces:

- **Named benchmarks** — the 2-3 Tier 1 + 2-3 Tier 2 apps *with dimensions*, by name: *"Tier 1 = Linear + Stripe Dashboard. Tier 2 = Things 3 for empty states (they teach, not apologize), Linear for keyboard-affordance discoverability."* Not "modern apps."
- **Rubric anchored per grade** — `S = looks like a Linear screen next to a Linear screen · A = ships at that quality after one polish pass · B = competent but visibly ours · C = ships but lags · D = embarrassing · F = block ship`. Each grade name-checks the benchmark.
- **Project anti-patterns from git** (3-5): *"Settings page bypassed the type scale for 2 weeks (commit `abc1234`) — scan typography against the scale on every settings-class surface."*
- **Calibration** — *S-tier: Linear-quality screen next to a Linear screen with no visible drop in chrome rigor; hierarchy reads at 1m; empty state teaches. F-tier: default-Material render, type-scale violations, apologetic empty state, hierarchy noise.*
- **Non-negotiable rules**, each with its why: never grade without a captured screenshot (pixel review is the contract) · never grade without surface-type classification · both Tier 1 and Tier 2 named in every grade · pitfalls scanned before the grade (they inform it) · "highest-ROI move" is one action, not a list · refuse multi-screen scope and route to `flow-audit`.
- **The daily-driver trap** (when the project has a named in-product assistant character) — thread this anti-pattern into the agent body: *"'Hi — I'm <assistant>, let me show you around' / 'Welcome' / 'Let me introduce' is BANNED on daily-driver / settings / error surfaces — first-touch register is correct ONLY on the named intro surface."* It reads fine in isolation; the bug is the surface-type mismatch, the single most common UX bug in product-voice products. Cross-ref `interaction-audit.md`.
- **Abort conditions** — surface not reachable in the current build; captured screenshot older than the last edit; Tier 1 benchmark unspecified; multi-screen request (refuse, route to `flow-audit`).

## Tool surface

`Read`, `Grep`, `Glob`, `Bash`, plus the platform's capture / interaction tools. It may Write its audit doc but never edits UI source. Model: highest-capable (visual grading benefits from reasoning depth). Effort: high — one of the most expensive runs in the inventory; don't dispatch reflexively.

## Cross-references

- `visual-verification.md` — capture discipline; the precondition to grading.
- `journey-mapping.md` — surface-type classification; the grading lens depends on type.
- `quality-rubric.md` — the S/A/B/C/D/F anchors and composition pitfalls.
- `design-benchmarking.md` — the Tier 1 / Tier 2 reference-picking methodology.
- `audit-routing.md` — when to dispatch this vs. flow / pages / interaction / a11y.
- `interaction-audit.md` — semantic chrome integrity; runs BEFORE ux-audit because semantic fixes shift layout.
- `a11y-audit.md` — runs in parallel with interaction-audit.
