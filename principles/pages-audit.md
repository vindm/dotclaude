# pages-audit — designing a cross-section consistency agent

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author an agent that grades **whether the primary multi-section surface feels like ONE app or like N independently-built apps.**

## When to ship one (applicability gate)

Ship a pages-audit agent when:

- The project has a **primary multi-section surface** — tab bar with 3+ tabs, a dashboard with 4+ sections, a multi-page documentation site, an app with multiple top-level views.
- Each section was built at a different time and consistency drift is plausible.
- The user has noticed that two sections "look slightly different" even though both use the design system.

Skip when:

- The project has only one or two primary sections — consistency is trivially holdable.
- The project doesn't have a top-level multi-section surface (e.g., a single-page app with one detail flow).
- The user is fine with section-by-section variation as a feature (rare).

## Why it matters — what this catches that nothing else does

The failure mode this prevents: **the project ships features as if each were an isolated screen, accumulating subtle deviations across primary sections that the user perceives as "this feels off" without being able to name it.**

Five specific drift classes the agent catches:

1. **Header pattern drift.** Section A uses a centered title; section B uses a left-aligned title; section C uses a search-prominent header. Each looks fine in isolation; together they break the chrome promise.

2. **Section-header typography drift.** One section uses a custom heading component; another uses raw text with className; a third uses an old version of the heading component. Visually 3-pixel-off; together they feel inconsistent.

3. **Card / row pattern drift.** Section A's list rows have chevrons; section B's don't; section C uses cards with shadows. Each was reviewed in isolation by someone who didn't compare to the others.

4. **Empty state pattern drift.** One section's empty state teaches; another apologizes; a third just renders nothing. The product feels less coherent than it should.

5. **Tap-target consistency drift.** Section A's primary CTAs are 50pt tall; section B's are 44pt; section C's are 56pt. Each is technically a11y-compliant; the user feels the inconsistency.

These bugs are invisible to:
- Single-screen visual review — each screen passes its own grade.
- Token / a11y audits — both screens may pass their own checks.
- Code review — each screen's diff is consistent with the design-system primitives.

Only an audit that compares the sections side-by-side surfaces the drift.

## Core methodology — majority rules

The agent's central principle: **for every property, majority is the expected value.** Any section that deviates is flagged, even if its value is arguably "better." Consistency trumps individual optimization.

Why majority-rules: enforcing best-of becomes a holy war ("which section's pattern is right?"). Majority-rules sidesteps the debate — it's mechanical, and convergence is the goal.

### Step 1 — Inventory the sections

Enumerate the primary surfaces. The agent should know the project's actual section list — for a tabbed app, the tab names + screen file paths. Encoded explicitly so the agent doesn't have to guess.

### Step 2 — Capture all sections

For each section, capture: a screenshot of the default state (with enough seeded data to render meaningfully), the view hierarchy, and the source file path.

The capture should be at the same device / viewport / theme / state across all sections. Comparing iPhone-portrait sections to web-desktop sections is a bug.

### Step 3 — Comparison properties

For each section, extract:

- **Header treatment**: pattern type (centered title / left-title / search-first / etc.), height, font, color.
- **Primary section-divider style**: card or row, with/without chevron, padding, separator style.
- **Empty state pattern**: present? Teaches / apologizes / silent? Iconography? Tone?
- **Primary CTA pattern**: shape, color, placement, hit-size.
- **Background / surface treatment**: solid / translucent / grouped.
- **Loading state**: pattern (skeleton / spinner / fade-in / nothing).
- **Error state**: pattern (in-line / banner / full-screen / silent).

This is the cross-section comparison matrix. Each row is a property; each column is a section. Majority value per row is the "expected." Cells deviating from the majority are findings.

### Step 4 — Code-grep first, pixel-measure last

The cheapest, most decisive check is grep. If the design system has primitive components (`<PageHeader>`, `<SectionTitle>`, `<EmptyState>`), the agent first asks: do all N sections USE the same primitives? If yes, most consistency questions are answered without pixel inspection.

The grep checks:
- All sections import the same header component.
- All sections render section titles via the same component.
- All sections use semantic tokens for surfaces (no raw hex, already enforced by `design-token-audit` and the token-only hook).
- All sections wrap content in the same page-content layout.

When grep can't disambiguate ("section 2's padding looks tighter than the others"), THEN use pixel measurement via the view hierarchy.

This order — grep first, pixel last — is cost discipline. Pixel measurement across multiple sections is slow and noisy; grep across the source files is fast and decisive.

### Step 5 — Produce the deviation report

For each deviation, the report has:

- The property
- The majority value (with which sections share it)
- The deviating section + its value
- Recommended fix: align to majority, OR (if the deviation is intentional and better) propose a project-wide design-system update.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The section inventory.** What are the project's primary sections? Their routes, file paths, navigation testIDs.

2. **The design-system primitives.** Which components are SHARED across sections — page header, section title, empty state, CTA button? The agent's grep checks need these names.

3. **The capture / navigation setup.** How does the agent get the app into a state where all sections render with data? Seed scripts, fixture users, mock data toggles.

4. **The platform.** iPhone? Desktop web? Multi-platform? The capture path and the section-tap navigation differ.

5. **Recent consistency complaints.** Has the user said "section X looks weird compared to the others"? That history primes the agent on which properties most need checking.

## Authoring the agent

The final agent (typically `.claude/agents/pages-audit.md`) should specify:

1. **The section inventory** — explicit list with routes + file paths.
2. **The majority-rules principle** — the agent's prime directive.
3. **The audit protocol** — capture all sections, build the comparison matrix, code-grep first / pixel-measure last.
4. **The properties matrix** — header / dividers / empty state / CTA / surface / loading / error.
5. **The capture commands** — project-specific.
6. **The report format** — deviation table with property / majority / deviator / fix.
7. **The "NOT for grading single-screen quality" refusal** — route to `ux-audit` for that.

## Cross-references

- `ux-audit.md` — single-screen quality. Pages-audit refuses single-screen requests.
- `audit-routing.md` — pages-audit sits between interaction-audit and ux-audit in the canonical UI-audit pipeline (catches cross-section drift before final visual polish locks the surface).
- `design-token-audit.md` — token discipline is upstream; section drift on COLORS is usually a token issue, not a pages-audit issue.
- `quality-rubric.md` — pages-audit findings typically register against the rubric's "consistency" / "hierarchy violations" pitfalls.

## Anti-patterns in the agent you write

- **Grading single sections.** Pages-audit is for the comparison ACROSS sections. Single-screen polish is `ux-audit`'s job.

- **Pixel measurement before grep.** If three sections all use `<PageHeader>` and one uses raw `<View>`, grep finds the deviation in seconds. Pixel measurement is slow and noisy by comparison. Order matters.

- **Best-of grading.** If section A is "better-designed" than the others, the agent should NOT recommend the others adopt A. Instead: flag the divergence and recommend a project-wide decision (either align to A, or align A to the others). Majority-rules is the default; "elevate to A" is a separate proposal.

- **Inconsistent capture state.** Section A captured with seeded data, section B captured empty, section C captured mid-load — comparison is meaningless. The agent must ensure same-state captures across all sections.

- **Property matrix too narrow.** Limiting to just "header style" misses 80% of drift. The matrix should cover the meaningful comparison dimensions for the project's primary sections.

- **No platform-specific tailoring.** Web has nav landmarks + breadcrumbs; mobile has tabs; desktop has sidebars. The properties matrix should match the actual surface type.

- **Findings without proposed fixes.** "Section B's header is different" is unactionable. "Section B's header uses centered alignment; sections A, C, D, E use left alignment. Fix: switch B to left alignment OR (if centered is preferred) propose updating the shared `<PageHeader>` to centered." The recommendation is part of the report.

- **Failing to identify the majority value.** A 5-section project where 3 use pattern X and 2 use pattern Y — pattern X is majority. A 4-section project where 2 use X and 2 use Y — no majority; the agent should flag this as "no convention, propose one."

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash`, plus the platform's capture + interaction tools.

Model: high-capability. Cross-section reasoning benefits from the model's pattern-detection.
Effort: high. Captures + comparisons across N sections take time.
