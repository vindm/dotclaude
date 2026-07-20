# pages-audit — designing a cross-section consistency agent

Teaching material for Claude Code. Teaches you how to author an agent that grades **whether the primary multi-section surface feels like ONE app or like N independently-built apps.**

## When to ship one

Ship a pages-audit agent when the project has a primary multi-section surface (a tab bar with 3+ tabs, a dashboard with 4+ sections, a multi-page docs site, an app with multiple top-level views), each section was built at a different time so drift is plausible, and the user has noticed that two sections "look slightly different" even though both use the design system. Skip when there are only one or two primary sections (consistency is trivially holdable), there's no top-level multi-section surface, or the user treats section-by-section variation as a feature.

## Why it matters

The failure mode: the project ships features as isolated screens, accumulating subtle deviations across primary sections that the user perceives as "this feels off" without being able to name it. Five drift classes the agent catches — each invisible to single-screen review (each screen passes its own grade), to token / a11y audits (each screen passes its own checks), and to code review (each diff is consistent with the design-system primitives):

1. **Header pattern drift** — centered title in A, left-aligned in B, search-prominent in C.
2. **Section-header typography drift** — a custom heading component in one, raw text with className in another, an old version of the component in a third.
3. **Card / row pattern drift** — chevrons in A, none in B, shadowed cards in C.
4. **Empty-state drift** — one teaches, another apologizes, a third renders nothing.
5. **Tap-target drift** — 50pt CTAs in A, 44pt in B, 56pt in C. Each is a11y-compliant; the user feels the inconsistency.

Only a side-by-side comparison surfaces this.

## Core methodology — majority rules

The prime directive: **for every property, the majority value is the expected one.** Any section that deviates is flagged, even if its value is arguably "better" — consistency trumps individual optimization, and majority-rules sidesteps the "which section is right?" holy war. Convergence is the goal.

**Step 1 — Inventory the sections.** Enumerate the primary surfaces (for a tabbed app, tab names + screen file paths), encoded explicitly so the agent doesn't guess.

**Step 2 — Capture all sections** at the same device / viewport / theme / state, with enough seeded data to render meaningfully — a screenshot, the view hierarchy, and the source path for each. Comparing iPhone-portrait to web-desktop, or seeded to empty, is a bug.

**Step 3 — Build the comparison matrix.** For each section extract: header treatment (pattern / height / font / color), section-divider style (card or row, chevron, padding, separators), empty-state pattern (present? teaches / apologizes / silent?), primary CTA (shape / color / placement / hit-size), background / surface treatment, loading state, error state. Each row is a property, each column a section; the majority value per row is "expected," deviating cells are findings.

**Step 4 — Code-grep first, pixel-measure last.** The cheapest, most decisive check is grep: do all N sections import the same header component? render titles via the same component? use semantic tokens? wrap content in the same layout? If yes, most consistency questions are answered without pixel inspection. Only when grep can't disambiguate ("section 2's padding looks tighter") drop to pixel measurement via the hierarchy — it's slow and noisy, grep is fast and decisive.

**Step 5 — Deviation report.** Per deviation: the property, the majority value (and which sections share it), the deviating section and its value, and a recommended fix — align to majority, OR (if the deviation is genuinely better) propose a project-wide design-system update rather than silently elevating one section. When there's no majority (2 use X, 2 use Y), flag it as "no convention — propose one."

## How to derive THIS project's specifics

1. **The section inventory** — routes, file paths, navigation testIDs.
2. **The design-system primitives shared across sections** — page header, section title, empty state, CTA; the grep checks need these names.
3. **The capture / navigation setup** — how the agent gets the app into a state where all sections render with data (seed scripts, fixture users, mock toggles).
4. **The platform** — iPhone / desktop web / multi; the capture path and section-tap navigation differ, and so do the relevant properties (web has landmarks + breadcrumbs; mobile has tabs; desktop has sidebars).
5. **Recent consistency complaints** — "section X looks weird" primes which properties most need checking.

## Authoring the agent

The final agent (typically `.claude/agents/pages-audit.md`) assembles the majority-rules principle, the five-step protocol, the properties matrix, and the deviation-report format above, plus: the explicit section inventory (routes + file paths); the project-specific capture commands; and the **refusal** — pages-audit is for the comparison ACROSS sections, so it refuses single-screen quality requests and routes them to `ux-audit`. Every finding carries a concrete fix (*"section B's header is centered; A, C, D, E are left-aligned. Fix: switch B, or propose updating the shared `<PageHeader>` to centered"*) — a bare *"section B's header is different"* is unactionable.

## Tool surface

`Read`, `Grep`, `Glob`, `Bash`, plus the platform's capture + interaction tools. Model: high-capability (cross-section pattern detection benefits from depth). Effort: high — captures + comparisons across N sections take time.

## Cross-references

- `ux-audit.md` — single-screen quality; pages-audit refuses single-screen requests and routes here.
- `audit-routing.md` — pages-audit sits between interaction-audit and ux-audit in the pipeline (catches cross-section drift before visual polish locks the surface).
- `design-token-audit.md` — token discipline is upstream; color drift across sections is usually a token issue, not a pages-audit one.
- `quality-rubric.md` — findings register against the rubric's consistency / hierarchy pitfalls.
