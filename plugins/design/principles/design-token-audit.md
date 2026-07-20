# design-token-audit — designing a token-discipline sweep agent

Teaching material for Claude Code. Teaches you how to author a token-discipline audit agent — the cheap, periodic sweep that catches raw colors / spacing / typography literals leaking into the codebase.

## When to ship one

Ship a token-audit agent when the project has a design system / theme / token file defining semantic values, has had raw literals slip in despite it, and the user wants periodic enforcement that the theme stays the source of truth. Skip when there's no theme to enforce against, when styling is wholly Tailwind utility-class with no raw-color escape hatch, or when the user doesn't care about per-token discipline.

## Why it matters

Token discipline is the invisible foundation of dark-mode support, design-system consistency, rebranding, and contrast tuning. Each raw `#0AC8FA` in code is a dark-mode bug (it doesn't adapt), a barrier to brand updates (N grep-replaces instead of one token edit), a drift signal (where one raw hex appears, more follow), and a maintenance tax (the next developer copies the pattern). Lint *can* ban raw colors, but in practice gets disabled for "just this one case" exceptions that compound; a periodic agent surfaces the accumulated debt and proposes a specific token replacement per finding — easier to action than a raw lint report. The companion hook (`hook-templates/check-design-tokens.sh`) is the edit-time enforcement; this agent is the periodic sweep that catches what the hook missed (older code, overridden lines, regex edge cases).

## Core methodology — the four-step sweep

**Step 1 — Sweep for violation patterns.** Universal: raw hex (`#[0-9a-fA-F]{3,8}`), raw color functions (`rgba(` / `rgb(` / `hsl(` / `hsla(` / `color(`), inline style color literals (`style={{ color: '…' }}`), Tailwind arbitrary values (`bg-[#abc]`, `text-[rgb(…)]`), style-object color properties (`StyleSheet.create({ x: { color: '…' } })`, `` styled.div`color: #…` ``). For projects with strict spacing / typography discipline, optionally also raw pixels in spacing contexts (`margin: 13px` against a 4/8/12/16 scale) and raw font sizes outside the scale. Default scope: color only; add spacing / typography if the user opts in.

**Step 2 — Exclude paths that shouldn't be swept.** The theme / token source file itself (it DEFINES the tokens — raw values are correct there), generated files (codegen, type files, snapshots), vendor code, native platform files (`ios/`, `android/` where colors live in `.xcassets` / `colors.xml`), test fixtures. Match the exemption list to the project's actual paths.

**Step 3 — Classify each hit by severity.** **S0 (must-fix):** user-facing chrome — sheets, buttons, headers; these visibly break dark mode / brand. **S1 (should-fix):** visible content — cards, list rows; drift accumulates. **S2 (low-priority):** internal-only screens — dev tools, debug dashboards; won't ship. Plus **Exempt** for intentional raw colors (visualization heatmaps where the gradient IS the data; debug overlays that won't ship) — flagged with a note, no replacement proposed.

**Step 4 — Propose replacements.** For each non-exempt hit, read the theme file and propose the closest semantic token:

```
L42: `#0AC8FA` → `theme.colors.accent.primary` (cyan)
L78: `rgba(0,0,0,0.6)` → `theme.colors.surface.scrim` (NEW — propose adding)
```

If no token fits, propose a NEW token name with a one-line rationale; the user decides whether to add it or refactor the call site.

## How to derive THIS project's specifics

1. **The theme / token file path** — `lib/theme/tokens.ts`? `src/styles/tokens.css`? A `tailwind.config.js` extend block? The agent reads it to know the available tokens.
2. **The styling system** — RN StyleSheet / Tailwind / CSS modules / styled-components / emotion; the sweep patterns differ.
3. **The exemption list** — native asset dirs, the theme file, generated files.
4. **The severity mapping** — what the project considers chrome (S0) vs content (S1) vs internal (S2), by file-path prefix.
5. **Token-discipline rules** — an "only one accent color" rule? Semantic vs palette naming? Encode the philosophy so recommendations align.
6. **Whether the hook is wired** — if `check-design-tokens.sh` is configured, this agent is the sweep behind it; if not, tell the user to wire the hook for cheaper edit-time enforcement.

## Report format

```markdown
# Design token audit — <date>

## Summary
- Files scanned: <N> · Violations: <M> (S0: <x>, S1: <y>, S2: <z>) · New tokens proposed: <K>

## S0 (must-fix, user-facing chrome)
### <file path>
- L<line>: `<raw value>` → `<token name>` (<context>)
- L<line>: `<raw value>` → `<token name>` (NEW — propose adding)

## S1 (should-fix) · ## S2 (low-priority)
...

## Token gaps (propose adding to <theme file>)
- `<new token name>` — <use case + frequency>

## Exempt (no fix recommended)
- <file:line> — `<value>` — <why exempt>
```

## Authoring the agent

The final agent (typically `.claude/agents/design-token-auditor.md`) assembles the four-step sweep, the severity tiers, and the report format above, plus:

- **Named benchmarks** — Linear (every color a semantic token, zero raw hex outside the token file), Tailwind config best practices (`theme.extend` over arbitrary values), Stripe Dashboard (semantic naming `surface.elevated` over palette `gray-100`). What "token-disciplined" looks like, named.
- **Rubric anchored per grade** — `S = 0 raw literals outside the theme file (Linear-grade) · A = <5 hits, all S2 · B = <20 hits, S0 zero · C = S0 hits on chrome · D = pervasive S0 · F = theme effectively bypassed`.
- **Project anti-patterns from git** (3-5): *"Settings used inline `style={{ color: '#1a1a1a' }}` instead of `colors.text.primary` (commit `abc1234`) — sweep `style=` props on every Settings-class file."* *"Tailwind `bg-[#0ac8fa]` snuck into 7 files before the linter caught it (PR #123) — flag every `[#` literal in `className=`."*
- **Calibration** — *S-tier: 0 raw hits across `src/**/*.tsx` outside `theme.ts`; every color a semantic token; new colors trigger a token-file edit, not an inline literal. F-tier: 80+ raw hex hits, mixed Tailwind-arbitrary and inline-style, brand hex repeated in 12 places, dark mode broken.*
- **Non-negotiable rules**, each with its why: never auto-apply replacements (report; the user decides — some "violations" are intentional heatmaps) · use word-bounded hex `#[0-9a-fA-F]{3,8}\b` (bare `#[0-9a-f]+` matches `id123abc`) · exempt the theme file · read the theme file BEFORE proposing (recommendations to non-existent tokens are noise) · severity tiers are mandatory (flat 200-item lists get ignored) · stay in lane (colors, optionally spacing/typography — not motion, not copy).
- **Abort / skip conditions** — skip the theme file, generated files, native asset dirs, test fixtures, and visualization heatmaps (Exempt those).
- **Cadence** — run weekly or after every UI batch; without a stated cadence it runs once and gets forgotten.

## Tool surface

`Read`, `Grep`, `Glob`, `Bash`. NOT `Edit` or `Write` — it reports findings; the user applies them. Model: **lightweight (haiku-class)** — this is grep + classify + lookup + propose; don't burn a top-tier model on it. Effort: low; designed to run cheaply and often.

## Cross-references

- `hook-templates/check-design-tokens.sh` — edit-time enforcement; this agent is the periodic sweep behind it.
- `audit-routing.md` — token audit is step 1 in the canonical UI-audit pipeline (cheapest, widest impact first).
- `ux-audit.md` — runs AFTER token audit, because token fixes may shift color semantics.
