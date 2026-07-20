# a11y-audit — designing an accessibility audit agent for ANY project

Teaching material for Claude Code. Teaches you how to author an accessibility-audit agent that catches the gap between "the screen looks polished" and "the screen actually works for users with assistive tech."

## When to ship one

Ship an a11y-audit agent when the project has user-facing UI that real users (not just internal developers) operate, when it faces an accessibility regulation (App Store / Play Store / WCAG / Section 508 / public-sector procurement), when real users with assistive tech will use it, or when the user holds an "Apple-parity" bar — that bar is unreachable without a11y parity (Apple ships every chrome surface with proper VoiceOver / Dynamic Type / contrast). Skip for internal developer tools with no external users, exploratory code that won't ship, or a wholly text-only platform-rendered UI (a CLI relying on the terminal's a11y).

## Why it matters

Visual reviewers grade what they see. An a11y audit grades what the screen reader, keyboard navigator, contrast-sensitive viewer, motion-sensitive user, and dynamic-type user experience — dimensions orthogonal to visual polish and invisible to both per-screen review and linters:

- A screen can be S-tier visually and silent to VoiceOver — every interactive element missing its label.
- Visually beautiful, with hit targets at 28×28 where Apple's HIG demands 44×44 and Android's 48dp.
- Passing dark-mode review and failing Dynamic Type at 200% (text overflows, layout collapses).
- Using motion gracefully while ignoring the user's reduced-motion preference.
- On-brand and failing WCAG contrast at 3.5:1 where 4.5:1 is required.

A missing label on an interactive element or a sub-threshold hit target is **ship-blocking severity regardless of visual grade** (see `audit-routing.md` for cross-rubric translation). A shallow a11y audit is worse than none — it passes the screen on cosmetic criteria while real users stay locked out.

## Core methodology — four hard dimensions + one soft

Every audit walks five dimensions; the first four are hard (failures block ship), the fifth best-effort.

**Dimension 1 — Assistive-tech labels (hard).** Every interactive element needs a meaningful semantic label; the mechanism varies by platform (Web: `aria-label` / semantic HTML, `<button>` not `<div onClick>` · iOS SwiftUI: `accessibilityLabel` · iOS RN: `accessibilityLabel` + `accessibilityRole` · Android Compose: `contentDescription` + `Modifier.semantics` · desktop: NSAccessibility / UIA). Failure modes: icon-only button without a label (reader announces "button" with no context); Pressable wrapping a View without a label (silence); decorative image not hidden (reader reads the filename); a related group without a semantic group (read in isolation, no structure). Severity: missing label on an interactive element = CRIT; decorative-image label missing = MAJOR.

**Dimension 2 — Hit-target size (hard).** Minimum tappable area: iOS 44×44 pt, Android 48×48 dp, Web-touch 44×44 px (WCAG 2.2). Measure rendered bounds (view hierarchy / DOM); `hitSlop` counts if it meets the threshold. Failure modes: a 24×24 close-X with no hit-slop, inline links at default text height, dense rows with packed actions. Any tappable below threshold = CRIT.

**Dimension 3 — Contrast ratios (hard).** WCAG 2.2 AA: normal text 4.5:1, large text (18pt+ / 14pt+ bold) 3:1, UI components 3:1. **Contrast MUST be computed from TOKEN values, not screenshot-estimated** — this is core methodology, not a refinement. Screenshot sampling is unreliable (anti-aliasing, sub-pixel rendering, compression, blur backdrops, per-display gamma all distort the apparent pair): a 4.5:1 token pair can sample to 3.8:1 and false-flag compliant chrome, while a 4.2:1 pair can sample to 4.6:1 over an off-white edge and miss a real failure. Read the project's semantic tokens (`DESIGN_SYSTEM_TOKENS_PATH`), pick the actual foreground + background tokens for the surface, compute ratios mathematically. Pixel sampling is a *fallback* when tokens are unavailable. Audit BOTH modes if the project has dark + light; failures in either block. Severity: text below 4.5:1 or UI below 3:1 = MAJOR; multiple across a screen = CRIT.

**Dimension 4 — Text scaling (hard where the platform has system text size).** iOS Dynamic Type, Android font scale, browser `rem`-based scaling. At the project's upper target (typically 200% / XXXL) the screen must not truncate critical text, overflow critical controls, or collapse into unreadable density. Severity: critical text truncated or control overflowed at supported scale = MAJOR.

**Dimension 5 — Motion / reduced-motion (soft).** When the user requests reduced motion (iOS / Android setting, `prefers-reduced-motion`), animations should skip, minimize (cross-fade over slide), or stay brief. Soft because non-honoring is rarely critical — but on parallax-heavy / motion-rich screens it matters (vestibular conditions). Severity: critical chrome ignoring the preference = MAJOR; decorative = LOW.

**Platform extras.** Web: keyboard order, focus-ring visibility, focus management on dialog open/close, skip-links, ARIA landmarks. iOS: VoiceOver rotor, accessibility actions for swipe-only gestures. Android: TalkBack live-region announcements, content grouping. The agent knows its platform and applies the relevant extras.

## How to derive THIS project's specifics

1. **The platform** — determines which dimensions and extras apply.
2. **The theme / token system** — contrast checks reference the semantic tokens, not screenshot guesses.
3. **The accessibility audit history** — prior findings are the highest-priority recurrence checks.
4. **The compliance target** — WCAG AA / AAA / Section 508 / App Store; each shifts thresholds slightly.
5. **The animation library** — does it have a reduced-motion hook? Check its usage.
6. **The capture / inspection commands** — `maestro hierarchy` for iOS sim, `axe-core` / `pa11y` / `lighthouse` for web, Xcode Accessibility Inspector for native iOS.

## Report format

```markdown
## A11y Audit — <screen> — <date>

### Captured artifact: <screenshot + view-hierarchy capture>
### Overall: <S/A/B/C/D/F>

### Dim 1 — Assistive labels
| Element | Has label? | Label quality | Severity |
|---|---|---|---|

### Dim 2 — Hit targets
| Element | Bounds (w × h) | Meets <threshold>? | Severity |
|---|---|---|---|

### Dim 3 — Contrast
| Foreground | Background | Ratio | Required | Pass? |
|---|---|---|---|---|

### Dim 4 — Text scaling · Dim 5 — Motion
| Element / animation | Behavior at 200% / honors reduced-motion? | Severity |
|---|---|---|

### Ship-blocking (CRIT) · Major · Minor
<grouped findings, each with a concrete fix>
```

## Authoring the agent

The final agent (typically `.claude/agents/a11y-audit.md`) assembles the five dimensions with platform-specific inspection commands, the severity mapping, and the report format above, plus these project-specific pieces:

- **Named benchmarks** — real products to compare against, not "WCAG AA pass": *"Tier 1 = Apple Settings VoiceOver flow; Tier 2 = Linear keyboard navigation."* Parity without a11y is no parity.
- **Rubric anchored per grade** — `S = Apple-parity (zero CRIT/MAJOR, every element labeled and reachable) · A = 1-2 MAJOR · B = multiple MAJOR, CRIT clear · C = ≥1 CRIT (blocked) · D = pervasive CRIT · F = unusable by assistive tech`. CRIT-class severity overrides the visual grade.
- **Project anti-patterns from git** (3-5, from the interview): *"Close-X on modal at 28×28 (fix `abc1234`) — sweep sub-44pt close icons in `src/components/Modal/`."*
- **Calibration** — *S-tier: every element labeled, screen reader completes the primary task unaided, 44pt+ targets, computed contrast > 4.5:1 text / > 3:1 UI in both modes, 200% Dynamic Type reflows cleanly. F-tier: unlabeled icon buttons, 24×24 targets, 2.8:1 text, layout collapses at 130%.*
- **Non-negotiable rules**, each with its why: CRIT findings named in the report's first line · audit both light and dark modes · audit all meaningful states (happy / error / empty / loading / focus / disabled) · compute contrast from tokens · a fix per finding (*"missing label"* without *"add `accessibilityLabel='close'`"* is unactionable) · verify Dynamic Type at 200% explicitly (devs test at 100%, which is where scale bugs hide).
- **Abort conditions** — no theme file (no contrast source of truth); "the whole app" scope (one surface at a time); no animation library (skip Dim 5, but flag the omission).

## Tool surface

`Read`, `Grep`, `Glob`, `Bash` for static analysis, plus the platform's capture + hierarchy inspection tools (CLI > MCP per `visual-verification.md`). The audit grades a captured artifact, not source — token values are an input, the verification is on rendered output. Model: high-capability (contrast / scaling / semantic-structure reasoning benefits from depth). Effort: high.

## Cross-references

- `ux-audit.md` — visual polish; orthogonal to a11y, both must pass.
- `interaction-audit.md` — semantic chrome integrity; runs in parallel, same dispatch batch.
- `audit-routing.md` — when to dispatch, and the cross-rubric rule that a11y CRIT blocks ship regardless of visual grade.
- `visual-verification.md` — capture is the precondition.
- `quality-rubric.md` — a11y is one input to the composite grade.
