# interaction-audit — designing a semantic chrome-vs-handler integrity agent

Teaching material for Claude Code. Teaches you how to author an agent that catches a class of UX bug invisible to both code review and visual review: **what the chrome PROMISES vs. what the handler ACTUALLY does.**

## When to ship one

Ship an interaction-audit agent when the project has multi-element interactive screens (forms, dashboards, lists with actions, wizards with cards + CTAs), when it has had or anticipates "the user taps and nothing happens" / "can't tell which control does what" bugs, or when visual reviews pass while the interactions feel off. Skip when interactions are trivial (a single submit button), the UI is view-only, or a library authors the handlers.

## Why it matters

Three failure modes that survive both correctness-focused code review and `ux-audit.md`:

1. **Dead chrome.** A button / pressable / card visually promises action — chevron, solid CTA color, hover state — but its handler never fires on the primary path. The user taps; nothing happens (or something unexpected does).
2. **Redundant affordances.** Two interactive elements reach the same outcome; the user must choose and gets no feedback. The visual hierarchy lies — it suggests different actions.
3. **Optical-group disconnects.** Control block A modifies target field B but lives far from it, separated by unrelated content; the user can't see the relationship, and tapping A appears to do nothing because the feedback is elsewhere.

These are invisible to code review (the diff is fine, the handler returns the right value, types match), to visual review (each element is well-styled), and to E2E tests (they assert the primary flow completes; they don't ask whether the user could have taken a different path). Only an audit that traces each affordance's visible promise to its actual behavior catches them.

## Core methodology — the affordance-vs-behavior table

The agent's central output, per screen, is a table — one row per interactive element:

| # | Element (testID / label) | Chrome promises | Handler does | Match? | Other elements doing same? |
|---|---|---|---|---|---|

**Step 1 — Capture the surface.** Screenshot; inspect the view hierarchy; identify every visually-interactive element (Pressable, Button, Tab, Link, Card-with-onPress — anything that visually invites a tap).

**Step 2 — Fill each row.** *Chrome promises* — what the visual design tells the user this does (*"tap to navigate"* = chevron + row chrome; *"tap to commit"* = solid CTA; *"tap to dismiss"* = X top-right). *Handler does* — read the actual code: grep the testID, trace the onPress 1-2 hops; don't infer from chrome. *Match?* — ✓ (matches), ✗ (mismatch: chevron promises navigation, handler is decorative), or ⚠ (works but unclear which action the user thinks they're taking). *Other elements doing same?* — if any other element reaches the same outcome, that's a redundant-affordance candidate.

**Step 3 — Tap, don't only read.** Runtime behavior diverges from static code: the handler reads stale state (closure trap), depends on an effect that hasn't fired, is intercepted by an overlay, or runs but writes to a store the screen doesn't read. The Match column is informed by tapping, not reading alone.

**Step 4 — Pattern-detect across the table.** *Dead chrome*: the ✗ rows. *Redundant affordances*: rows where "Other elements doing same?" is non-empty. *Optical-group disconnects*: cross-reference each element's screen position with its target — A at (100,200) modifying B at (300,600) with unrelated content between is a disconnect.

**Step 5 — Graded report** per the `quality-rubric.md` scale, patterns named:

```markdown
## Interaction Audit — <screen> — <date>

### Overall: <S/A/B/C/D/F>
### Affordance-vs-behavior table
<the full table>
### Dead chrome findings
<each: element · chrome promise · what the handler does · severity>
### Redundant affordance findings
<each: paired elements · shared outcome · recommended consolidation>
### Optical-group disconnect findings
<each: element + target · screen separation · fix>
### Highest-ROI move
<one action to resolve the most-severe finding>
```

## How to derive THIS project's specifics

1. **Interactive element types** — RN: Pressable / Touchable / Button; Web: button / a / div-with-onClick / form elements; iOS: UIButton / UIControl. The enumeration grep needs the project's specific strings.
2. **The handler-tracing pattern** — `onPress` → handler → mutation? `onClick` → router push? `formAction` → server action? The "read the handler" step needs the project's pattern.
3. **The testID convention** — `testID` / `data-testid` / `id` / accessibility labels. The grep needs the right attribute.
4. **Capture / inspection commands** — web → DOM tree via DevTools / `axe-core`; iOS sim → `maestro hierarchy`; native iOS → Xcode accessibility inspector.
5. **The redundancy history** — a past "two buttons doing the same thing" bug primes the agent for the pattern.

## Authoring the agent

The final agent (typically `.claude/agents/interaction-audit.md`) assembles the five steps, the affordance-vs-behavior table, the three failure-mode patterns, and the report format above, plus:

- **When to invoke** — after any UI screen edit, BEFORE `ux-audit` (per `audit-routing.md`: semantic before visual, because semantic fixes shift layout).
- **What this agent is NOT** — an explicit refusal list: not visual polish, not arc / IA, not token discipline, not copy register.
- **Named benchmarks** — Apple (Settings: every row navigates predictably; Music: chrome always matches), Linear (no redundant affordances; every control a unique outcome), Stripe Dashboard (deterministic form interactions). What "interactions feel right" means, named.
- **Rubric anchored per grade** — `S = no dead chrome, no redundancy, all interactions one-to-one (Linear-tier) · A = 1-2 ambiguities · B = one redundancy or minor dead chrome · C = ≥1 CRIT dead chrome · D = pervasive dead chrome · F = primary flow blocked`.
- **Project anti-patterns from git** (3-5): *"Floating action button intercepted by overlay (commit `abc1234`) — verify every element's tap actually fires by tapping."* *"Two CTAs on the hero card went to the same route (fix `def5678`) — redundancy-scan every screen with multiple primary-looking buttons."*
- **Calibration** — *S-tier: every Pressable has one unique outcome matching its chrome; nothing invites a tap that doesn't fire; nothing fires invisibly off-screen; no two affordances route to the same place. F-tier: chevron rows that don't navigate, a solid CTA that opens a sheet instead of committing, two buttons both going to settings, a swipe action no chrome indicates.*
- **Non-negotiable rules**, each with its why: TAP every affordance (runtime divergence — stale closures, async races, intercepting overlays — is the bug class this exists to catch) · read the chrome promise from rendered output, not source · the "Other elements doing same?" column is mandatory (redundancy is invisible without it) · refuse out-of-lane requests (visual → `ux-reviewer`, arc → `flow-auditor`) · flag ⚠ ambiguous findings, not just ✗ (ambiguity IS a finding) · a one-sentence fix per finding.
- **Abort conditions** — single screen only; skip a permission-gated affordance the audit can't reach (and flag it); abort if hierarchy inspection returns empty (a build issue, not an audit finding).

## Tool surface

`Read`, `Grep`, `Glob`, `Bash`, plus the platform's capture + interaction tools (tap / type / inspect hierarchy). Model: high-capability (the "what does this chrome promise" reasoning is non-trivial). Effort: high — per-element behavioral tracing takes time.

## Cross-references

- `ux-audit.md` — visual polish; runs AFTER interaction-audit (semantic fixes shift layout, so visual goes last).
- `a11y-audit.md` — accessibility; runs in PARALLEL, orthogonal dimensions.
- `audit-routing.md` — the canonical pipeline (token → semantic + a11y || → visual) is binding.
- `quality-rubric.md` — the rubric's tone-mismatch and hierarchy pitfalls map to interaction-audit findings.
