# design-system-reference-skill — designing the design-system entry-point skill for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author the design-system reference skill — the always-on entry-point that EVERY UI agent loads to learn the project's tokens, chrome primitives, surface hierarchy, motion presets, status colors, library gotchas, and i18n conventions. It's the skill that prevents agents from re-deriving "what does this project's design system contain" on every dispatch.

## When to ship one (applicability gate)

Ship a design-system reference skill when:

- The project has **any kind of design system** — semantic tokens, palette, theme file, native chrome primitives, animation presets, OR a shared component library.
- Multiple agents need to **reach for the same primitives consistently** (token names, primitive components, animation presets).
- The team has **library gotchas** worth documenting once (e.g., "X library doesn't reset on `value: undefined`," "Y library's hot reload doesn't apply animation changes").
- There's a **visual quality tier system** (S / A / B / C grades per surface) the team holds itself to.

Skip when:

- The project has **no design system at all** — ad-hoc inline styling everywhere, no tokens, no shared primitives.
- The project is **engineering-only** with no visual surface.
- Token discipline is wholly enforced by a hook + lint config with no further conventions to surface.

## Why it matters — what this catches that nothing else does

A single audit agent (`design-token-auditor`, `ux-audit`, etc.) only sees its narrow slice. Without an entry-point skill:

- **Agents re-derive what's in the design system on every run.** Tokens path / primitive paths / motion presets / library gotchas are re-investigated each dispatch — wastes tokens, produces inconsistent verdicts.
- **Native chrome primitives get re-implemented.** Agents recommend "build a custom X" when `<X>` already ships; the design system skill is what surfaces "we already have one — use this."
- **Surface hierarchy violations slip through.** A `<FrostedGlassCard>` on a normal page (not over camera / over photo) gets shipped because nobody catches the level-mismatch.
- **Library footguns get re-discovered the hard way.** *"Why doesn't this select reset?"* — the answer lives in the design-system skill if it's been documented; otherwise it's re-debugged every 3 months.
- **Animation conventions drift.** Spring vs linear; stagger timing; enter-vs-exit asymmetry — without a presets file + skill that points at it, every component invents its own motion vocabulary.
- **Status colors get misused.** Amber means "actionable warning," not "still generating." Without a single status-color table the skill points at, semantic color discipline drifts.
- **i18n conventions get reinvented per surface.** Without a single doc the AI prompts reference, generated content slips into wrong-register translations.

The skill is the **always-load reference** that prevents agents from rebuilding context they could just read.

## Core methodology — the eleven-section pattern

The skill is structured as a flat reference. Every UI agent loads it on dispatch. It covers eleven sections, in order.

### 1. North star

One-sentence statement of "what does S-tier look like on this platform." Names specific reference apps. Reference the project's `design-north-star.md` rule (the broader doc) and point at the chrome-by-chrome reference table.

### 2. Native chrome primitives

A table of the project's wrapped native primitives — the components that wrap real system APIs (UIKit, Material Design, Radix, etc.) and render the same chrome the platform's own apps render. Always reach for these before rolling custom.

Table columns: `Primitive` | `Wraps` | `Use for`.

Example shape (project-specific values):

| Primitive | Wraps | Use for |
|---|---|---|
| `<NavTabs>` | native tab bar API | The primary tab bar — auto-glass on iOS 26 |
| `<GlassCard>` | platform glass material API | Surfaces that should read as "lifted glass" |
| `<BottomSheetModal>` | platform sheet API | All bottom sheets |
| `<useConfirmDialog>` | platform alert API | Promise-returning confirm dialogs |

Plus an anti-patterns paragraph naming the rejected approaches (custom fake-platform chrome, legacy blur APIs, heavy shadow stacks, multiple competing accents).

### 3. Token architecture

A diagram or paragraph naming the single source of truth and how it generates downstream artifacts:

```
<tokens source file> (SINGLE SOURCE OF TRUTH)
    │
    └─► <THEME_GENERATION_COMMAND>
            │
            ├─► <generated CSS variables for web>
            │
            └─► <generated config for styling library>
```

Plus the **post-edit rule**: *"After editing `<tokens source>`, always run `<command>`."*

### 4. Tokens (source of truth)

Tables listing the project's exports:

- `palette` — raw color scales (50-950 or equivalent).
- `theme` — semantic tokens for light/dark modes.
- `spacing` / `radii` / `shadows` — the scales.

Each row: `Export` | `Description`.

### 5. Styling API surface

How to use the tokens in components. Project-specific code snippets:

- Semantic colors (theme-aware) — most common path.
- Palette colors (raw, same in all modes) — rare.
- Spacing / radius / shadow utility classes (if Tailwind-shaped) OR style functions (if RN StyleSheet) OR CSS variable references (if web).
- JS access for libraries (charts, maps, etc.) — the hook / function name.

### 6. Semantic colors table

For every named semantic token, list `Token` | `Light value` | `Dark value` | `Usage`. This is the canonical reference any agent uses to compute contrast or pick the right token.

### 7. Surface hierarchy

A table layering back-to-front. Each level adds visual weight:

| Level | Surface | Background | Border | Shadow | When |
|---|---|---|---|---|---|
| 0 | Background | base bg token | none | none | Page fill |
| 1 | Card | card token | border token | soft shadow | Standard content |
| 2 | Sheet | card token | top-radius | sheet shadow | Bottom sheets / modals |
| 3 | Elevated card | card token | accent border | glow shadow | Selected / active |
| 4 | Frosted glass | translucent | high-contrast border | strong shadow | Over camera / photo / map |

Plus the binding rule: *"Never skip levels. A level-4 surface only appears in the contexts level 4 is designed for."*

### 8. Motion principles

Five-rule shape:

1. Spring-based, not linear (springs feel natural; linear feels robotic).
2. Staggered, not simultaneous (lists reveal item-by-item).
3. Purposeful, not decorative (every animation serves hierarchy or feedback).
4. Fast exits, slow entrances (enter 250-400ms; exit 100-200ms).
5. Respect reduced motion (check the platform's reduced-motion hook; skip animations, keep state changes).

Plus a **canonical presets table** referencing the project's `ANIMATION_PRESET_FILE_PATH`:

| Preset | Config | Use for |
|---|---|---|
| `cardEnter(index)` | spring stagger | List item entrances |
| `sectionEnter` | slide-in | Section headers |
| `heroEnter` | zoom-in | Celebration / hero elements |
| `cardLayout` | linear transition | Smooth layout shifts |
| `cardExit` | fast fade-out | Item removal |
| `selectionBounce` | scale | Toggle / badge tap |

Plus performance cap: *"Animate only first N visible items in a list; the rest enter instantly."*

### 9. Shadow presets + card patterns

Tables for `cardShadow` / `sheetShadow` / `glowShadow(color)` / `frostedShadow` with their values + use cases.

Plus a canonical card-wrapper pattern (container margin, border radius, border color rules, padding) — the shape every list item / detail card inherits.

### 10. Status color system

The product's status semantic mapping. Table:

| Status | Left accent | Pill bg | Pill text | Icon |
|---|---|---|---|---|
| Success / match | green | green-tint | green | check |
| Active / new | accent | accent-tint | accent | sparkles |
| Likely (medium confidence) | accent | accent-tint-light | accent-dim | none |
| Uncertain (low confidence) | amber | amber-tint | amber | warning |
| Failed / error | red | red-tint | red | X |

Discipline: **one amber per surface per concern.** Amber = actionable warning, NOT "still generating." Red = hard error, NOT "soft fail on 1 of N." Accent = active/pending, NOT "this is fine."

### 11. Quality tiers + project conventions

A table classifying surfaces by target quality grade (S / A / B / C). Lists which surfaces target which grade — *"core flows should be S-tier; settings A minimum; admin B okay."*

Plus three closing sub-sections (project-specific):

- **`RN_LIBRARY_GOTCHAS_LIST`** — discovered footguns. E.g. *"`@rn-primitives/select` doesn't reset display on `value: undefined`; force remount with `key` prop."* / *"`@gorhom/bottom-sheet` snap-point changes don't hot-reload; full restart needed."* / *"Tab navigators don't remount; use `useFocusEffect` to invalidate React Query."*
- **`INTERACTION_SEMANTICS_4Q_DOCSTRING_REQUIRED`** (if `true`) — every new / redesigned screen carries a 4-question header docstring (one-sentence purpose / THE primary action + location / per-element chrome-vs-handler / explicit "no redundant affordances" or list).
- **`I18N_CONVENTIONS`** — project-specific translation conventions (e.g., AI prompts producing labeled output need explicit translations baked in to prevent the model inventing its own).

## How to derive THIS project's specifics

Before authoring the skill, gather:

1. **Tokens path** → `DESIGN_SYSTEM_TOKENS_PATH`. Where the single source of truth lives. Common: `lib/theme/tokens.ts` / `tailwind.config.js` / `tokens.json` / `src/styles/tokens.css`.
2. **Theme convention** → `THEME_CONVENTION`. `semantic-token` / `palette` / `CSS-variable` / `Tailwind` / `Tailwind+NativeWind` / `SCSS` / `styled-components` / `Emotion` / `vanilla-extract` / `RN StyleSheet`.
3. **Theme generation command** → `THEME_GENERATION_COMMAND`. The post-edit command (or `"none"` if tokens are read directly).
4. **Native chrome primitives** → `NATIVE_CHROME_PRIMITIVES_LIST` + `CHROME_PRIMITIVE_PATHS`. The wrapped primitives. For iOS RN: NavTabs / GlassCard / BottomSheetModal / useConfirmDialog. For web: Dialog / Sheet / Tooltip from Radix. For CLI: prompt / spinner / table primitives.
5. **Motion library** → `MOTION_LIBRARY`. `Reanimated 4` / `Reanimated 3` / `Framer Motion` / `CSS transitions` / `Web Animations API` / `native UIKit/Compose` / `none`.
6. **Animation preset file** → `ANIMATION_PRESET_FILE_PATH`. Where canonical presets live (or `"none"` if no presets file).
7. **Surface hierarchy levels** → `SURFACE_HIERARCHY_LEVELS`. The back-to-front layering rules for this product's visual surface stack.
8. **Status color system** → `STATUS_COLOR_SYSTEM`. The project's status semantic mapping (status × color × icon).
9. **Quality tier targets** → `QUALITY_TIER_BY_SURFACE`. Which surface categories target which letter grade.
10. **Library gotchas** → `RN_LIBRARY_GOTCHAS_LIST`. Project-specific footguns worth documenting once.
11. **4Q docstring requirement** → `INTERACTION_SEMANTICS_4Q_DOCSTRING_REQUIRED`. Boolean — does every new screen carry a 4-question header.
12. **i18n conventions** → `I18N_CONVENTIONS`. Project-specific translation conventions.

## Authoring the skill

The final skill (typically `.claude/skills/design-system/SKILL.md`) specifies:

1. **Frontmatter** — `name: design-system`, `description:` naming tokens + primitives + the north-star reference, `paths:` glob pattern (auto-load on theme / component / widget file edits — e.g. `lib/theme/**,components/ui/**,lib/widgets/primitives/**`).
2. **North-star section** — paragraph + pointer to the broader `design-north-star.md` rule.
3. **Native chrome primitives table** — the project's actual primitives + anti-patterns paragraph.
4. **Token architecture diagram** + post-edit command rule.
5. **Tokens (source of truth) tables** — exports of palette / theme / spacing / radii / shadows.
6. **Styling API code snippets** — semantic colors / palette colors / spacing / JS access patterns.
7. **Semantic colors table** — token / light / dark / usage.
8. **Surface hierarchy table** + binding rule (never skip levels).
9. **Motion principles** + canonical presets table + performance cap.
10. **Shadow presets table** + canonical card pattern.
11. **Status color system table** + one-amber discipline.
12. **Quality tiers table** + per-surface targets.
13. **Library gotchas** subsection (only if gotchas exist).
14. **Interaction-semantics 4Q docstring template** (if required).
15. **i18n conventions** subsection (if applicable).

## Depth signatures — what battle-tested looks like

The authored `design-system/SKILL.md` fails the depth bar if it lacks any of these 10 structural elements.

1. **Frontmatter `paths:` glob** — auto-loads on theme / component / primitive file edits. Without `paths:`, the skill never auto-loads and agents skip it.
2. **Native chrome primitives table with file paths** — every entry cites the wrapped API + the project file path. Not "use the glass primitive" but `<GlassCard>` at `lib/widgets/primitives/GlassCard.tsx`.
3. **Post-edit command rule** named explicitly — *"After editing `<tokens source>`, always run `<THEME_GENERATION_COMMAND>`."* Without this, tokens drift between source and generated.
4. **Surface hierarchy table with 4-5 levels** — and the binding rule. Without explicit levels, level-4 surfaces leak onto level-0 contexts.
5. **Animation presets table referencing the actual preset file** — names the file + lists each preset by name. Without the table, every component invents its own motion vocabulary.
6. **Performance cap on animations** — explicit *"animate only first N visible items."* Without a cap, scroll lists ship with hundreds of `useAnimatedProps` and burn frame budget.
7. **Status color system with one-amber discipline language** — *"Amber = actionable warning, NOT 'still generating.'"* Without explicit semantics, status colors drift.
8. **Library gotchas with concrete code snippets** — not "`Select` is flaky" but the exact `key` prop workaround code. Without snippets, the gotcha gets re-debugged.
9. **Quality tier table with per-surface targets** — *"core flows S-tier, settings A min, admin B ok."* Without targets, every surface gets graded against the same bar.
10. **Project-specific code paths threaded throughout** — every code snippet uses the project's actual import paths, file names, hook names. Generic templates fail this check.

If the authored skill lacks any of these, redo. Battle-tested ≠ optional polish.

## Cross-references

- `design-token-audit.md` — the agent that sweeps for raw hex; uses the tokens table from this skill.
- `design-benchmarking.md` — the Tier 1 / Tier 2 reference picking; populates the chrome anti-patterns paragraph.
- `ux-audit.md` — single-screen polish; uses the surface hierarchy + quality tier from this skill.
- `interaction-audit.md` — semantic chrome integrity; uses the 4Q docstring template from this skill.
- `pages-audit.md` — cross-section consistency; uses the surface hierarchy + native primitives inventory.
- `visual-verification.md` — capture discipline; orthogonal to this skill but referenced by every agent that uses it.

## Anti-patterns in the skill you write

- **Generic templates without project-specific names.** *"Use the glass primitive"* — no. `<GlassCard>` at the actual project path.

- **Inventories without anti-patterns.** Listing "what to use" without "what to reject" leaves the rejected approaches available. Always pair the inventory with the anti-patterns paragraph.

- **Token tables without `Usage` column.** *"`primary: #06b6d4`"* — no. *"`primary` (light: #06b6d4, dark: #1fc3f9) — primary actions"* — yes.

- **Motion principles without preset table.** Principles say "spring-based"; the presets are what an agent reaches for. Without the table, agents invent.

- **Status color table without the discipline paragraph.** The table without *"one amber per surface per concern"* leaves agents using amber for "in progress."

- **Hard-to-update sub-sections.** If `RN_LIBRARY_GOTCHAS_LIST` is buried mid-skill in prose, gotchas get forgotten. Keep it as a dedicated subsection so it's easy to extend.

- **No 4Q docstring template if the project enforces interaction semantics.** Other agents (`interaction-audit`) check for the 4Q docstring; if the design-system skill doesn't show the template, the docstring stays unwritten.

- **Reinventing the design-north-star.md rule's content.** This skill is the *operational reference*; the north-star rule is the *binding statement*. They cross-reference; they don't duplicate.

## Tool surface

The skill is text-only — no tools needed at the skill level. The agents that load it use `Read` + `Grep` + capture/inspection tools.

Model: N/A (the skill is loaded into the dispatching agent's context). The dispatching agent's model tier determines effort.

Effort: low (the skill is a reference; reading it costs the dispatching agent ~2-3k tokens but saves 5-10k per dispatch by preventing context-rebuild).
