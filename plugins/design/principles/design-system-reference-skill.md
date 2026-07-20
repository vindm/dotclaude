# design-system-reference-skill — designing the design-system entry-point skill for ANY project

Teaching material for Claude Code. Teaches you how to author the design-system reference skill — the always-on entry-point EVERY UI agent loads to learn the project's tokens, chrome primitives, surface hierarchy, motion presets, status colors, library gotchas, and i18n conventions. It's what prevents agents from re-deriving "what does this project's design system contain" on every dispatch.

## When to ship one

Ship a design-system reference skill when the project has any kind of design system (semantic tokens, palette, theme file, native chrome primitives, animation presets, or a shared component library), when multiple agents need to reach for the same primitives consistently, when there are library gotchas worth documenting once, or when there's a visual quality-tier system per surface. Skip when there's no design system at all (ad-hoc inline styling), when the project is engineering-only, or when token discipline is wholly enforced by a hook + lint with no further conventions.

## Why it matters

A single audit agent only sees its narrow slice. Without an entry-point skill, agents re-derive what's in the design system on every run (tokens path, primitive paths, motion presets, gotchas — re-investigated each dispatch, wasting tokens and producing inconsistent verdicts); native chrome primitives get re-implemented (agents recommend "build a custom X" when `<X>` already ships); surface-hierarchy violations slip through (a frosted-glass card on a normal page); library footguns get re-discovered the hard way; animation conventions drift (every component invents its own motion vocabulary); status colors get misused (amber for "still generating" instead of "actionable warning"); and i18n conventions get reinvented per surface. The skill is the **always-load reference** that stops agents rebuilding context they could just read.

## Core methodology — the eleven-section pattern

A flat reference every UI agent loads on dispatch, in order:

1. **North star** — one sentence on what S-tier looks like on this platform, naming specific reference apps; points at the broader `design-north-star.md` rule and its chrome-by-chrome table.
2. **Native chrome primitives** — a table (`Primitive` | `Wraps` | `Use for`) of the project's wrapped system-API components (UIKit / Material / Radix), always reached for before rolling custom — e.g. `<NavTabs>` (native tab bar), `<GlassCard>` (glass material), `<BottomSheetModal>` (sheet API), `<useConfirmDialog>` (alert API). Plus an anti-patterns paragraph naming the rejected approaches (custom fake-platform chrome, legacy blur, heavy shadow stacks, competing accents).
3. **Token architecture** — a diagram naming the single source of truth and how it generates downstream artifacts (`<tokens source>` → `<THEME_GENERATION_COMMAND>` → CSS variables + styling-library config), plus the **post-edit rule**: *"after editing `<tokens source>`, always run `<command>`."*
4. **Tokens (source of truth)** — tables of the exports: `palette` (raw scales), `theme` (semantic tokens for light/dark), `spacing` / `radii` / `shadows`. Each row: `Export` | `Description`.
5. **Styling API surface** — project-specific snippets for using the tokens: semantic colors (theme-aware, the common path), palette colors (raw, rare), spacing/radius/shadow utilities or style functions or CSS variables, and JS access for libraries (charts, maps).
6. **Semantic colors table** — `Token` | `Light value` | `Dark value` | `Usage` for every semantic token; the canonical reference for contrast computation and token picking.
7. **Surface hierarchy** — a back-to-front table (Level / Surface / Background / Border / Shadow / When), e.g. 0 background → 1 card → 2 sheet → 3 elevated → 4 frosted glass (over camera / photo / map), plus the binding rule: *"never skip levels; a level-4 surface only appears in the contexts level 4 is designed for."*
8. **Motion principles** — five rules (spring not linear; staggered not simultaneous; purposeful not decorative; fast exits 100-200ms / slow entrances 250-400ms; respect reduced motion), plus a canonical presets table referencing `ANIMATION_PRESET_FILE_PATH` (`cardEnter(index)`, `sectionEnter`, `heroEnter`, `cardLayout`, `cardExit`, `selectionBounce`), plus the performance cap: *"animate only the first N visible items; the rest enter instantly."*
9. **Shadow presets + card patterns** — tables for `cardShadow` / `sheetShadow` / `glowShadow(color)` / `frostedShadow`, plus the canonical card-wrapper pattern (margin, radius, border rules, padding) every list item / detail card inherits.
10. **Status color system** — a table (Status / Left accent / Pill bg / Pill text / Icon) for success / active / likely / uncertain / failed, plus the discipline: **one amber per surface per concern** — amber = actionable warning (NOT "still generating"), red = hard error (NOT "soft fail on 1 of N"), accent = active/pending (NOT "this is fine").
11. **Quality tiers + project conventions** — a table classifying surfaces by target grade (*"core flows S-tier, settings A min, admin B ok"*), plus three project-specific closers: **`RN_LIBRARY_GOTCHAS_LIST`** (discovered footguns with the exact workaround code — *"`@rn-primitives/select` doesn't reset on `value: undefined`; force remount with a `key` prop"*), the **`INTERACTION_SEMANTICS_4Q_DOCSTRING`** template if required (purpose / primary action + location / per-element chrome-vs-handler / no-redundant-affordances), and **`I18N_CONVENTIONS`** (e.g. AI prompts producing labeled output need explicit translations baked in).

## How to derive THIS project's specifics

Fill the placeholders: **`DESIGN_SYSTEM_TOKENS_PATH`** (the single source of truth), **`THEME_CONVENTION`** (semantic-token / palette / CSS-variable / Tailwind+NativeWind / styled-components / RN StyleSheet), **`THEME_GENERATION_COMMAND`** (the post-edit command, or "none"), **`NATIVE_CHROME_PRIMITIVES_LIST` + `CHROME_PRIMITIVE_PATHS`**, **`MOTION_LIBRARY`** (Reanimated / Framer Motion / CSS / native / none), **`ANIMATION_PRESET_FILE_PATH`**, **`SURFACE_HIERARCHY_LEVELS`**, **`STATUS_COLOR_SYSTEM`**, **`QUALITY_TIER_BY_SURFACE`**, **`RN_LIBRARY_GOTCHAS_LIST`**, **`INTERACTION_SEMANTICS_4Q_DOCSTRING_REQUIRED`** (boolean), and **`I18N_CONVENTIONS`**.

## Authoring the skill

The final skill (typically `.claude/skills/design-system/SKILL.md`) assembles the eleven sections above with the project's actual paths, names, and values, behind frontmatter with `name: design-system`, a `description:` naming tokens + primitives + the north-star reference, and a **`paths:` glob** that auto-loads it on theme / component / widget edits (e.g. `lib/theme/**,components/ui/**`).

## Acceptance — what battle-tested looks like

The authored skill fails the bar if any is missing (each names the signature and the failure it prevents):

1. **A frontmatter `paths:` glob** — without it the skill never auto-loads and agents skip it.
2. **Native chrome primitives with file paths** — `<GlassCard>` at `lib/widgets/primitives/GlassCard.tsx`, not "use the glass primitive."
3. **The post-edit command rule named** — or tokens drift between source and generated.
4. **A surface-hierarchy table (4-5 levels) with the never-skip-levels rule** — or level-4 surfaces leak onto level-0 contexts.
5. **An animation presets table referencing the actual file** — or every component invents its own motion vocabulary. Plus the performance cap, or scroll lists ship with hundreds of animated props.
6. **The status-color system with one-amber discipline language** — or status colors drift.
7. **Library gotchas with concrete workaround code** — not "`Select` is flaky" but the exact `key`-prop fix; otherwise the gotcha gets re-debugged every few months.
8. **A quality-tier table with per-surface targets** — or every surface gets graded against the same bar.
9. **Project-specific code paths threaded throughout** — every snippet uses the project's actual imports and names; generic templates fail.
10. **Inventories paired with anti-patterns, and it doesn't reinvent `design-north-star.md`** — listing "what to use" without "what to reject" leaves the rejected approach available; this skill is the *operational reference*, the north-star is the *binding statement* — they cross-reference, they don't duplicate.

## Tool surface

Text-only — no tools at the skill level; the agents that load it use `Read`, `Grep`, and capture/inspection tools. Effort: low — reading it costs the dispatching agent ~2-3k tokens but saves 5-10k per dispatch by preventing context-rebuild.

## Cross-references

- `design-token-audit.md` — sweeps for raw hex; uses this skill's tokens table.
- `design-benchmarking.md` — Tier 1 / Tier 2 reference picking; populates the chrome anti-patterns paragraph.
- `ux-audit.md` — uses the surface hierarchy + quality tiers.
- `interaction-audit.md` — uses the 4Q docstring template.
- `pages-audit.md` — uses the surface hierarchy + native-primitives inventory.
- `visual-verification.md` — capture discipline, referenced by every agent that loads this skill.
