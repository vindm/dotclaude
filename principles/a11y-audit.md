# a11y-audit — designing an accessibility audit agent for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author an accessibility-audit agent that catches the gap between "the screen looks polished" and "the screen actually works for users with assistive tech."

## When to ship one (applicability gate)

Ship an a11y-audit agent when:

- The project has **user-facing UI** that real users (not just internal developers) will operate.
- The project will face an accessibility regulation (App Store / Play Store / WCAG compliance / public sector procurement / Section 508).
- The user holds an "Apple-parity" or "world-class" bar — that bar is unreachable without a11y parity (Apple ships every chrome surface with proper VoiceOver / Dynamic Type / contrast).
- Real users with assistive tech will use the product.

Skip when:

- The project is an internal developer tool with no external users.
- The project is exploratory / spike code where the surface won't ship.
- The project's UI is wholly text-only and platform-rendered (e.g., a CLI that depends on the terminal's a11y).

## Why it matters — what this catches that nothing else does

Visual reviewers grade what they see. An a11y audit grades what the **screen reader, keyboard navigator, contrast-sensitive viewer, motion-sensitive user, dynamic-type user** experience. These dimensions are orthogonal to visual polish:

- A screen can be S-tier visually and silent to VoiceOver — every interactive element missing its label.
- A screen can be visually beautiful and have hit targets at 28×28 px — Apple's HIG demands 44×44; Android's demands 48dp.
- A screen can pass dark-mode review and fail Dynamic Type at 200% (text overflows, layout collapses).
- A screen can use motion gracefully and ignore the user's reduced-motion preference.
- A screen can be on-brand and fail WCAG contrast at 3.5:1 where 4.5:1 is required.

None of these are visible to per-screen visual review. None are caught by linters. The a11y audit is the only realistic guard.

The shipping-block rationale: a missing accessibility label on an interactive element or a < 44pt hit target is **ship-blocking severity**, regardless of how the visual audit grades the screen. See `audit-routing.md` for cross-rubric severity translation.

## Core methodology — four hard dimensions + one soft

Every audit walks five dimensions. The first four are hard (failures block ship); the fifth is best-effort.

### Dimension 1 — Assistive-tech labels (hard)

Every interactive element must have a meaningful semantic label. The mechanism varies by platform:

| Platform | Mechanism |
|---|---|
| Web | `aria-label`, `aria-labelledby`, semantic HTML (`<button>` not `<div onClick>`) |
| iOS / SwiftUI | `accessibilityLabel`, `.accessibilityElement(children: .combine)` |
| iOS / React Native | `accessibilityLabel`, `accessibilityRole`, `accessible={true|false}` |
| Android / Compose | `contentDescription`, `Modifier.semantics` |
| Android / RN | `accessibilityLabel` |
| Desktop / native | platform-specific (NSAccessibility on macOS, UIA on Windows) |

Failure modes the agent looks for:
- Icon-only button without a label → reader announces "button" with no context.
- Pressable / TouchableOpacity wrapping a View without label → silence.
- Decorative image not hidden → reader reads filename.
- Group of related elements without semantic group → reader reads each in isolation, no structure.

Severity: missing label on an interactive element = CRIT (block ship). Decorative-image label missing = MAJOR.

### Dimension 2 — Hit-target size (hard)

Minimum tappable area:
- iOS: 44×44 points (Apple HIG)
- Android: 48×48 dp (Material guidelines)
- Web (touch): 44×44 px (WCAG 2.2 Target Size)
- Web (mouse-only): no strict minimum, but a11y for mobile-web requires the touch threshold.

The agent measures rendered bounds (via view hierarchy or DOM inspection) and flags any tappable below the threshold. `hitSlop` / extended hit areas count if they meet the threshold.

Failure modes:
- Close-X icon at 24×24 with no hit-slop → CRIT.
- Inline links at default text height (often ~20 px) → fail.
- Dense list rows with multiple actions packed → each action below threshold.

Severity: any tappable below the threshold = CRIT.

### Dimension 3 — Contrast ratios (hard)

WCAG 2.2 AA:
- Normal text: 4.5:1 minimum.
- Large text (18pt+ or 14pt+ bold): 3:1 minimum.
- UI components and graphical objects: 3:1 minimum.

The agent computes the contrast ratio between foreground and background colors. It should pull colors from the **semantic tokens** the project uses (theme files) rather than visually estimating from pixels.

For projects with dark + light modes, the agent audits BOTH modes. Failures in either are blocking.

Severity: text below 4.5:1 or UI below 3:1 = MAJOR. Multiple failures across a screen = CRIT.

### Dimension 4 — Text scaling (hard for platforms with system text size)

iOS Dynamic Type, Android font scale, browser `prefers-text-size` / `rem`-based scaling. The user can request 130%, 150%, 200% text. The screen must:
- Not truncate critical text.
- Not overflow critical controls.
- Not collapse layout into unreadable density.

The agent should verify at the project's defined upper scaling target (typically 200% / XXXL). Test mode-switches if the project supports them.

Severity: critical text truncated or critical control overflowed at supported scale = MAJOR.

### Dimension 5 — Motion / reduced-motion (soft)

If the user has indicated reduced-motion preference (iOS, Android, `prefers-reduced-motion` CSS query), animations should either:
- Skip entirely
- Use minimal motion (cross-fade instead of slide)
- Not exceed brief duration thresholds

The agent should check whether the project's animation library / motion primitives honor the preference. This is soft because non-honoring is rarely a critical failure, but on parallax-heavy / motion-rich screens it can be (motion sensitivity, vestibular conditions).

Severity: animations on critical chrome ignoring reduced-motion preference = MAJOR. Decorative animation ignoring it = LOW.

### Additional dimensions for specific platforms

- **Web only**: keyboard navigation order, focus-ring visibility, focus management on dialog open/close, skip-links, semantic HTML, ARIA landmarks.
- **iOS only**: VoiceOver rotor configuration, accessibility actions for swipe-only gestures, voice control hints.
- **Android only**: TalkBack-specific live-region announcements, content-grouping rules.

The agent should know its platform and apply the relevant additional checks.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The project's platform.** Determines which dimensions apply and which platform-specific extras to include.

2. **The project's theme / token system.** Contrast checks should reference the project's semantic tokens, not raw colors guessed from a screenshot.

3. **The project's accessibility audit history.** Have any audits been done? What did they find? Those findings are the highest-priority recurrence checks.

4. **The project's compliance target.** WCAG AA? WCAG AAA? Section 508? App Store? Each has slightly different thresholds.

5. **The project's animation library.** Does it have a reduced-motion hook / setting? The agent should check usage.

6. **The capture / inspection commands.** View-hierarchy inspection differs by platform (`maestro hierarchy`, Chrome DevTools tree, Xcode accessibility inspector, etc.).

## Authoring the agent

The final agent (typically `.claude/agents/a11y-audit.md`) should specify:

1. **When to invoke** — default: in parallel with `interaction-audit` and `ux-audit` before claiming a UI surface done.
2. **The four hard dimensions** — with platform-specific commands for each check.
3. **The fifth soft dimension** — motion / reduced-motion.
4. **The severity mapping** — CRIT / MAJOR / LOW; CRIT blocks ship regardless of visual grade.
5. **The platform-specific extras** — keyboard / focus-ring for web; VoiceOver rotor for iOS; TalkBack live regions for Android.
6. **The report format** — graded per dimension, with per-element findings.
7. **The "ship-block" precondition** — a missing label or sub-threshold hit-target blocks ship; the report's first line names this if applicable.

## Report format

```markdown
## A11y Audit — <screen name> — <date>

### Captured artifact
<path to screenshot + view-hierarchy capture>

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

### Dim 4 — Text scaling
| Element / surface | Behavior at 200% | Severity |
|---|---|---|

### Dim 5 — Motion / reduced-motion
| Animation | Honors prefers-reduced-motion? | Severity |
|---|---|---|

### Ship-blocking findings (CRIT)
<list — these block merge>

### Major findings
<list — should fix before ship>

### Minor / suggestions
<list>
```

## Depth signatures — what battle-tested looks like

The authored `a11y-audit.md` agent fails the depth bar if it lacks any of these 10 structural elements. Accessibility is a domain where shallow audits are actively misleading — they pass the screen on cosmetic criteria while real users with assistive tech remain locked out. Depth is not negotiable.

1. **Named benchmarks** — Apple's own apps (Music, Settings, Wallet) for iOS a11y; Stripe / Linear for web a11y standards; Microsoft Office for desktop a11y. The benchmark for "S-tier a11y" must be a real product the user can open and compare against, not "WCAG AA pass." E.g. *"Tier 1 = Apple Settings VoiceOver flow; Tier 2 = Linear keyboard navigation for power-user a11y."*
2. **5+ inspection dimensions** — assistive labels, hit-target size, contrast ratios, text scaling, motion preference, plus platform-specific (focus rings on web; VoiceOver rotor on iOS; TalkBack live regions on Android). Each with the concrete command/grep for inspecting it.
3. **Rubric anchored per grade** — `S = Apple-parity (zero CRIT, zero MAJOR, every interactive element labeled and reachable) / A = ships with 1-2 MAJOR / B = ships with multiple MAJOR; ship-blocking CRIT clear / C = at least one CRIT; ship blocked / D = pervasive CRITs / F = unusable by assistive-tech users`. Crit-class severity OVERRIDES visual grade — Apple iOS 26 Settings is the parity claim, and parity without a11y is no parity.
4. **Report-format sections** — `## Captured artifact / ## Overall grade / ## Dim 1: Assistive labels (table) / ## Dim 2: Hit targets (table) / ## Dim 3: Contrast (table with computed ratios) / ## Dim 4: Text scaling / ## Dim 5: Motion / ## Ship-blocking findings (CRIT) / ## Major findings / ## Minor`. Tables are mandatory; flat prose loses signal.
5. **Cross-references** — composes with `ux-audit.md` (orthogonal dimensions; both must pass), `interaction-audit.md` (parallel dispatch), `audit-routing.md` (CRIT in a11y blocks ship regardless of visual grade), `visual-verification.md` (capture is precondition), the project's theme/token file (contrast computation source).
6. **Numbered non-negotiable rules** — minimum 6: *(1) CRIT-class findings (missing label on interactive, sub-threshold hit target) block ship regardless of visual grade — call this out in the first line of the report. (2) Audit BOTH light and dark modes if the project supports them. (3) Audit all meaningful states — happy, error, empty, loading, focus, disabled. (4) Compute contrast from token values, NOT visual estimation from a screenshot. (5) Provide a fix per finding — "missing label" without "add `accessibilityLabel='close'`" is unactionable. (6) Verify Dynamic Type / text-scale at 200% explicitly — devs test at 100%, and that's where scale bugs hide.*
7. **Project-specific anti-patterns from git** — 3-5 from interview Phase D. E.g. *"Close-X icon on modal at 28×28 (commit `abc1234` fix) — sweep for sub-44pt close icons on every modal in `src/components/Modal/`."* *"Empty list state used decorative-image label that screen reader spoke verbatim (commit `def5678`) — flag every `Image` not wrapped in `accessibilityHidden`."*
8. **Edge cases + abort conditions** — *"Abort if project has no theme file (no source of truth for contrast computation). Refuse if scope is "the whole app" — audit one surface at a time. Skip Dim 5 (motion) if the project has no animation library — but flag the omission."*
9. **Calibration text** — `S-tier looks like: <every interactive element labeled, VoiceOver/screen-reader can complete the primary task without sighted assistance, 44pt+ hit targets throughout, contrast computed > 4.5:1 for text and > 3:1 for UI in both modes, Dynamic Type at 200% reflows cleanly>. F-tier looks like: <icon-only buttons with no labels, hit targets at 24×24, contrast 2.8:1 on primary text, layout collapses at 130% Dynamic Type, motion ignores reduced-motion preference>.`
10. **Operational specifics** — platform-specific hierarchy/inspection commands derived from Phase 1: `maestro hierarchy --compact` for iOS sim, `axe-core` for web (or `pa11y` / `lighthouse --only-categories=accessibility`), Xcode Accessibility Inspector for native iOS, the user's actual theme/token path for contrast computation. Compliance target (WCAG 2.2 AA vs AAA vs Section 508) stated explicitly.

If the authored `a11y-audit.md` lacks any of these, redo. A shallow a11y audit is worse than no audit — it gives false confidence.

## Cross-references

- `ux-audit.md` — visual polish. Visual + a11y are orthogonal; both must pass.
- `interaction-audit.md` — semantic chrome integrity. Runs in parallel with a11y; same dispatch batch.
- `audit-routing.md` — when to dispatch this agent; cross-rubric severity translation (a11y CRIT blocks ship regardless of visual grade).
- `visual-verification.md` — capture is the precondition.
- `quality-rubric.md` — a11y is one input to the overall composite grade.

## Anti-patterns in the agent you write

- **Skipping a11y because "the visual is fine."** Visual quality doesn't predict a11y quality. The agent runs regardless of visual grade.

- **Auditing only the happy path.** Disabled states, focus states, error states, loading states all have a11y requirements. Audit the surface in its meaningful states, not just the default.

- **Visual estimate of contrast.** "Looks contrast-y" is not a check. Compute ratios from the actual tokens.

- **No per-platform tailoring.** Web a11y has focus rings + landmarks; iOS has VoiceOver rotor + accessibility actions; Android has TalkBack live regions. Don't ship a one-size-fits-all checklist.

- **CRIT findings without a "this blocks ship" header.** The audit's authority depends on calling its blocking findings clearly. Don't bury ship-blockers in a list.

- **Auditing the design-token file directly.** The audit grades a captured artifact, not source code. Token values are an input, but the verification is on rendered output.

- **Ignoring scaling.** Dynamic Type / font-scale failures are common because devs test at 100% only. The audit must explicitly check the scaled state.

- **Confusing reduced-motion as cosmetic.** For motion-sensitive users, ignoring reduced-motion is a real accessibility failure, not a polish detail. Severity should reflect that.

- **Producing audit findings without fix suggestions.** "This pressable lacks a label" is unactionable without "add `accessibilityLabel='close'` or wrap in a button with appropriate text." Every finding has the fix.

## Tool surface

Read, Grep, Glob, Bash for static analysis. Platform-specific capture + hierarchy inspection tools (CLI > MCP per `visual-verification.md`).

Model: high-capability. The contrast / scaling / semantic-structure reasoning benefits from depth.
Effort: high. A11y audits are detailed and dense; don't shortchange the model.
