# design-token-audit — designing a token-discipline sweep agent

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a token-discipline audit agent — the cheap, periodic sweep that catches raw colors / spacing / typography literals leaking into the codebase.

## When to ship one (applicability gate)

Ship a token-audit agent when:

- The project has a **design system / theme / token file** that defines semantic values.
- The project has had raw color / spacing literals slip into code despite the design system existing.
- The user wants periodic enforcement that the theme stays the source of truth.

Skip when:

- The project has no theme / design system to enforce against.
- The project's styling is wholly Tailwind / utility-class-only with no raw-color escape hatches.
- The user doesn't care about per-token discipline (rare; usually voiced explicitly).

## Why it matters — what this catches that nothing else does

Token discipline is the invisible foundation of dark-mode support, design-system consistency, theme rebranding, accessibility contrast tuning. Each raw `#0AC8FA` in code is:

- A bug in dark mode (it doesn't adapt; either invisible or jarring).
- A barrier to brand updates (a color change requires N grep-replaces instead of one token edit).
- A drift signal — the team is bypassing the design system, and where one raw hex appears, more follow.
- A maintenance tax — the next developer sees the raw color, doesn't know if it's intentional or accident, defaults to copying the pattern.

What this catches that linters typically don't: lint rules CAN be configured to ban raw colors, but in practice they're often disabled for "just this one case" exceptions that compound. A periodic audit run by an LLM-callable agent surfaces the accumulated debt and proposes specific token replacements per finding — easier to action than a raw lint report.

The companion hook (`hook-templates/check-token-only.sh`) is the edit-time enforcement; this agent is the periodic sweep that catches what the hook missed (older code, overridden lines, edge cases the hook's regex doesn't cover).

## Core methodology — the four-step sweep

The agent walks four steps.

### Step 1 — Sweep for violation patterns

Universal patterns the agent greps for:

- **Raw hex**: `#[0-9a-fA-F]{3,8}` in source files.
- **Raw color functions**: `rgba(`, `rgb(`, `hsl(`, `hsla(`, `color(`.
- **Inline style literals with color**: framework-specific syntax (`style={{ color: '...' }}`, `<View style={[styles, { backgroundColor: '#...' }]} />`).
- **Tailwind arbitrary values**: `bg-[#abc]`, `text-[rgb(...)]`, `border-[hsl(...)]`.
- **Style-object color properties**: `StyleSheet.create({ x: { color: '...' } })`, `styled.div\`color: #...\``.

For projects with strict spacing or typography token discipline, the agent can be configured to also sweep:
- **Raw pixel values** in spacing-relevant contexts (`margin: 13px`, `padding: 9px` where the design system has a 4 / 8 / 12 / 16 scale).
- **Raw font sizes** outside the typography scale.

Default scope: sweep only color discipline. Add spacing / typography if the user wants extra enforcement.

### Step 2 — Exclude paths that should not be swept

Common exemptions:
- The theme / token source file itself (it DEFINES the tokens; raw values are correct here).
- Generated files (codegen output, type files, snapshot files).
- Vendor / third-party code (`node_modules/`, `vendor/`).
- Native platform files (`ios/`, `android/`) where colors live in `.xcassets` / `colors.xml`.
- Test fixtures.

The agent's exemption list should match the project's actual paths.

### Step 3 — Classify each hit by severity

Three tiers:

- **S0 (must-fix)**: violations on user-facing chrome surfaces — sheets, buttons, headers, primary chrome. These visibly break the design system's dark mode / brand consistency.
- **S1 (should-fix)**: violations on visible content surfaces — cards, list rows, content components. Drift accumulates over time.
- **S2 (low-priority)**: violations on internal-only screens — dev tools, debug dashboards, feature-flag panels. Won't ship to end users.

The agent also has an **Exempt** classification for cases where a raw color is intentional (e.g., visualization heatmap colors where the gradient is the data; debug overlays in colors that won't ship). The agent flags these with a note and doesn't propose replacements.

### Step 4 — Propose replacements

For each non-exempt hit, the agent reads the theme file and proposes the closest semantic token. The proposal is specific:

```
L42: `#0AC8FA` → `theme.colors.accent.primary` (cyan)
L78: `rgba(0,0,0,0.6)` → `theme.colors.surface.scrim` (NEW — propose adding)
```

If no existing token fits, the agent proposes a NEW token name with a one-line rationale. The user decides whether to add the token or refactor the call site differently.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The theme / token file path.** Where do semantic tokens live? `lib/theme/tokens.ts`? `src/styles/tokens.css`? `tailwind.config.js` extend block? The agent reads this file to understand the available tokens.

2. **The styling system in use.** React Native StyleSheet? Tailwind? CSS / SCSS modules? CSS-in-JS (styled-components / emotion)? The sweep patterns differ.

3. **The exemption list.** Which paths legitimately have raw colors? The native asset directories, the theme file itself, generated files, etc.

4. **The severity-tier mapping.** What does the project consider chrome (S0) vs. content (S1) vs. internal (S2)? Encode by file-path prefix or directory.

5. **Token-discipline rules the project holds.** Does the project have an "only one accent color" rule? Does it differentiate semantic from palette colors? Encode the project's design-system philosophy so the agent's recommendations align.

6. **Whether the hook is wired.** If `hook-templates/check-token-only.sh` is configured, the agent is the periodic sweep behind the hook. If not, the agent does the work the hook would have done — and the user should be told to wire the hook for cheaper edit-time enforcement.

## Authoring the agent

The final agent (typically `.claude/agents/design-token-auditor.md`) should specify:

1. **The inputs to read first** — theme file, design-system docs, any color-discipline rules.
2. **The sweep patterns** — regex per styling system.
3. **The exemption list** — paths to skip.
4. **The classification tiers** — S0 / S1 / S2 / Exempt.
5. **The replacement-proposal procedure** — read tokens, propose closest match, flag gaps.
6. **The report format** — grouped by file, with line numbers.
7. **The "stay in your lane" rule** — token discipline only; don't audit typography, spacing, motion (those have other agents).

## The model choice

Token audit is mechanical: grep, classify, lookup, propose. A **lightweight model** (haiku-class) handles it correctly and cheaply. Don't burn opus tokens on grep-and-lookup.

The agent should run frequently — weekly cron, or after every batch of UI work — without a meaningful budget impact.

## Report format

```markdown
# Design token audit — <date>

## Summary
- Files scanned: <N>
- Violations: <M> (S0: <x>, S1: <y>, S2: <z>)
- New tokens proposed: <K>

## S0 (must-fix, user-facing chrome)

### <file path>
- L<line>: `<raw value>` → `<token name>` (<one-line context>)
- L<line>: `<raw value>` → `<token name>` (NEW — propose adding)

### <file path>
...

## S1 (should-fix)
...

## S2 (low-priority)
...

## Token gaps (propose adding to <theme file>)
- `<new token name>` — <use case + frequency>
- ...

## Exempt (no fix recommended)
- <file:line> — `<value>` — <why exempt>
```

## Depth signatures — what battle-tested looks like

The authored `design-token-auditor.md` agent is the lightweight, periodic sweep — but lightweight doesn't mean shallow. The depth signatures here are about **specificity and exemption discipline**, not LOC. A token audit can be 100 LOC and battle-tested, or 100 LOC and useless — the difference is whether the 10 elements are present.

1. **Named benchmarks** — Linear's token discipline (every color is a semantic token; zero raw hex outside the token file), Tailwind config best practices (`theme.extend` over arbitrary values), Stripe Dashboard (semantic naming `surface.elevated` over palette naming `gray-100`). The benchmark is what "token-disciplined codebase" looks like, named.
2. **5+ inspection dimensions** — raw hex (`#[0-9a-fA-F]{3,8}`), raw rgba/rgb/hsl/hsla functions, inline style color literals, Tailwind arbitrary values (`bg-[#abc]`), style-object color properties (`StyleSheet.create({ x: { color: '#...' } })`). Optionally: raw spacing pixels, raw font sizes (only if user opted in to spacing/typography discipline).
3. **Rubric anchored per grade** — `S = 0 raw color literals outside theme file (Linear-grade) / A = <5 hits, all S2 internal / B = <20 hits with S0 hits zero / C = S0 hits present on user-facing chrome / D = pervasive S0 violations across chrome / F = theme system effectively bypassed`. Grade names cite the file count and severity tier.
4. **Report-format sections** — `## Summary (files scanned, violations by tier) / ## S0 (must-fix, user-facing chrome) / ## S1 (should-fix, visible content) / ## S2 (low-priority, internal) / ## Token gaps (propose adding to <theme file>) / ## Exempt (no fix recommended, with rationale)`. Tiered grouping is what makes the report actionable rather than a flat 200-item list.
5. **Cross-references** — composes with `hook-templates/check-token-only.sh` (edit-time enforcement; the agent is the periodic catch behind the hook), `audit-routing.md` (token audit is STEP 1 in canonical UI-audit pipeline — cheapest, widest impact), `ux-audit.md` (runs AFTER token audit; token fixes may shift color semantics).
6. **Numbered non-negotiable rules** — minimum 6: *(1) Never auto-apply replacements — agent reports; user decides. (2) Use word-bounded hex regex `#[0-9a-fA-F]{3,8}\b` — bare `#[0-9a-f]+` matches `id123abc`. (3) Exempt the theme file itself (it DEFINES tokens; raw values are correct there). (4) Read the theme file BEFORE proposing replacements — recommendations to non-existent tokens are noise. (5) Severity tiers (S0/S1/S2) are mandatory — flat lists get ignored. (6) Stay in lane — token audit is for colors (optionally spacing/typography); not motion, not copy, not chrome composition.*
7. **Project-specific anti-patterns from git** — 3-5 from interview Phase D. E.g. *"Settings page used inline `style={{ color: '#1a1a1a' }}` instead of `colors.text.primary` (commit `abc1234`) — sweep `style=` props on every Settings-class file."* *"Tailwind arbitrary `bg-[#0ac8fa]` snuck in across 7 files before the linter caught it (PR #123) — flag every `\[#` literal in `className=`."*
8. **Edge cases + abort conditions** — *"Skip the project's theme file (cite path). Skip generated files (`*.generated.ts`, `dist/`, `node_modules/`). Skip native asset directories (`ios/*.xcassets`, `android/res/values/colors.xml`) — colors live there legitimately. Skip test fixtures and snapshots. Skip visualization heatmap files where gradients ARE the data (flag in Exempt section)."*
9. **Calibration text** — `S-tier looks like: <0 raw color hits across src/**/*.tsx outside theme.ts; every color references a semantic token; new design-system color additions trigger a token-file edit, not an inline literal>. F-tier looks like: <80+ raw hex hits across components, mixed Tailwind arbitrary and inline-style approaches, brand color hex repeated in 12 places, dark-mode broken because raw colors don't adapt>.`
10. **Operational specifics** — exact theme file path derived from Phase 1 (`src/styles/tokens.ts` / `lib/theme/tokens.ts` / `tailwind.config.ts`), the styling system in use (RN StyleSheet / Tailwind / CSS modules / styled-components / emotion — drives sweep patterns), the exemption path list from Phase 1, the model tier (haiku-class — this is mechanical work, don't burn opus tokens).

If the authored `design-token-auditor.md` lacks any of these, redo. Token discipline depth isn't LOC — it's specificity of patterns, exemptions, and tier mapping.

## Cross-references

- `hook-templates/check-token-only.sh` — edit-time enforcement. The agent is the periodic sweep behind the hook.
- `audit-routing.md` — token audit is step 1 in the canonical UI-audit pipeline (cheapest, fixes wide-scale violations first).
- `ux-audit.md` — runs AFTER token audit, because token fixes may shift layout / color semantics.

## Anti-patterns in the agent you write

- **Auto-applying replacements.** The agent reports; the user decides. Some "violations" are intentional (heatmap colors, visualization gradients) — auto-fix would break them.

- **Wrong-shaped sweep.** A regex `#[0-9a-f]+` matches "id123abc" as a "color." Use `#[0-9a-fA-F]{3,8}` with word boundaries to bound matches.

- **Auditing the theme file itself.** The theme file DEFINES the tokens; raw values are correct there. Exempt it explicitly.

- **One-tier severity.** Without S0 / S1 / S2 split, the user gets a flat list of 200 violations and ignores all of them. Severity tiers make the report actionable — fix the 12 S0 first, defer the rest.

- **Proposing replacement without checking the token file.** Recommending `theme.colors.accent.primary` is useful only if that token exists. The agent must read the theme before proposing.

- **Out-of-lane gradings.** Token audit is for tokens. Typography / spacing / motion audits have other agents. The agent should refuse out-of-lane requests and route to the right specialist.

- **Heavy model.** This is grep + lookup work; lightweight models are correct. Match the model to the task.

- **No periodic-cadence guidance.** The audit's value is in catching drift over time. Without a "run weekly / after every UI batch" usage convention, it runs once and the user forgets to repeat.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash`. It does NOT need `Edit` or `Write` — it reports findings; the user applies them. The structural read-only constraint matches the audit's role.

Model: lightweight (haiku-class). Effort: low. Designed to run cheaply and often.
