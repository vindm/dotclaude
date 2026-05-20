---
description: Set up design / IA / UX / a11y / visual-quality discipline for a project. Authors a tailored kit of design audit agents, IA skills, and design-token rules — derived from the project's actual UI surfaces, the user's named design benchmarks, and past design failure modes. Invoke /dotclaude:design in any project root that has a human-facing surface.
---

# `/dotclaude:design` — design discipline kit

You are setting up design-discipline for the user's project. The output is a `.claude/` subset tuned to design / IA / UX / a11y / visual quality — agents that audit, skills that pre-empt, rules that anchor.

**This is the showpiece flow.** Most Claude Code plugins focus on engineering (CI, testing, refactoring). Design / IA / UX / a11y is a near-empty niche — your user's expertise in this area is what makes dotclaude unique. Treat this flow as the differentiator.

## Phase 1 — Read the project's UI shape

Before any question:

1. **UI surface inventory** — find every file with visible-to-user output:
   ```bash
   # Mobile (RN / Expo / SwiftUI / Compose)
   find . -path ./node_modules -prune -o -name "*.tsx" -print | head -50
   find . -name "*.swift" -path "*/UI/*" | head -20
   find . -path "*/composables/*" -name "*.kt" | head -20

   # Web (React / Vue / Svelte / etc.)
   find . -path ./node_modules -prune -o \( -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) -print | head -50

   # CLI / TUI
   find . -name "*.{ts,py,rs,go}" -path "*/{ui,tui,prompts}*" | head -20
   ```

2. **Design system signal** — look for:
   ```bash
   find . -path ./node_modules -prune -o \( -name "tokens.*" -o -name "theme.*" -o -name "design-system.*" -o -name "*.tokens.json" -o -name "tailwind.config.*" \) -print
   ```

3. **Component library**:
   ```bash
   ls -d components/ src/components/ src/ui/ lib/ui/ 2>/dev/null
   ```

4. **Existing design conventions** — search for:
   - `CLAUDE.md` mentioning design / theme / chrome / tokens
   - `docs/design-system/` or similar
   - A `STYLE_GUIDE.md` / `BRAND.md`

5. **Recent design fixes** — `git log --oneline --grep="fix.*design\|fix.*UI\|fix.*style\|fix.*ux\|fix.*color\|fix.*spacing" -30`. These are the real bug classes.

Build mental model of: what's the primary surface? What's the design system maturity? What kinds of design bugs has this project shipped?

## Phase 2 — Interview

Open `interview.md` (same directory). 4-6 questions. Adaptive — skip what's obvious from Phase 1. The most important questions:

- **Design benchmarks** — Tier 1 (chrome) + Tier 2 (domain). Without these the kit has no anchors.
- **Voice / tone** — does the product have a character? Brand-specific forbidden phrases?
- **Past design bugs** — the war stories that informed the original methodology.
- **Quality bar** — "shipped well" definition for THIS project.

## Phase 3 — Read the principles

Read these from `../../principles/` SELECTIVELY based on what the project actually has:

**Always read** (universal design discipline):
- `design-benchmarking.md` — picks Tier 1 + Tier 2 references
- `visual-verification.md` — see-what-you-built discipline
- `quality-rubric.md` — S/A/B/C/D anchored on the user's benchmarks
- `audit-routing.md` — which audit fires for which question

**Read if project has multi-screen UI** (most non-trivial UIs):
- `ux-audit.md` — single-screen audit
- `a11y-audit.md` — accessibility
- `interaction-audit.md` — semantic chrome-vs-handler
- `design-token-audit.md` — token discipline sweep
- `journey-mapping.md` — prior-surface mapping before any new screen design
- `element-reuse.md` — Gate A reuse verdict
- `persona-testing.md` — outside-eyes lens on copy

**Read if project has multi-section primary surface** (tabs / dashboard sections / docs sidebar):
- `pages-audit.md` — cross-section consistency

**Read if project has multi-screen arcs** (onboarding, wizard, checkout):
- `flow-audit.md` — whole-arc audit

**Read if project has product voice** (any user-facing copy):
- `forbidden-phrases.md` — voice discipline

## Phase 4 — Author the kit

Based on what applied + the interview answers, author these in `.claude-staging/`. Each artifact must cite the user's actual code paths, name THEIR benchmarks, reference THEIR past bugs.

### Agents (in `.claude-staging/agents/`)

- **`ux-reviewer.md`** — single-screen visual audit
  - Frontmatter: `description: <copy from principle, tuned with user's Tier 1 + Tier 2 names>`
  - Body: screenshot procedure for THEIR device target (iOS sim? Playwright? screenshot script?), grading rubric anchored to THEIR named benchmarks (e.g. "S = looks like Linear or Stripe" if those are their picks), composition pitfalls grounded in screenshots they showed in interview
  - Reference `quality-bar` skill

- **`a11y-audit.md`** — accessibility (only if UI is user-facing-end-user, not internal-only)
  - 4+1 dimensions adapted to THEIR platform (VoiceOver for iOS, screen reader for web, equivalent for desktop)
  - Hit-target sizes per platform (44pt iOS, 48dp Android, 44×44px web touch)
  - Contrast computed against THEIR design tokens
  - Dynamic Type / rem-scaling per platform

- **`interaction-audit.md`** — semantic chrome integrity
  - The affordance-vs-behavior table
  - Pattern catalog (dead chrome / redundant affordance / optical-group disconnect)
  - Project-specific examples from THEIR codebase if found in Phase 1 git log

- **`design-token-auditor.md`** — token discipline regex sweep
  - Targets: THEIR design system source file (which you found in Phase 1)
  - Sweep patterns: hex / rgba / hsla / Tailwind arbitrary values
  - Override convention: `// allow-color: <reason>`
  - Tier: haiku model (cheap) per `design-token-audit.md` principle

- **`flow-auditor.md`** (if multi-screen arcs) — whole-arc audit
  - 8-class gap rubric from `flow-audit.md` principle
  - Arc inventory: list THEIR known arcs (signup, onboarding, checkout, etc.) — derive from the routes/screens you found in Phase 1

- **`pages-audit.md`** (if multi-section primary surface) — cross-section consistency
  - Shared-component grep first, pixel measurement last
  - List THEIR primary sections (read from Phase 1 routes/tabs)

### Skills (in `.claude-staging/skills/`)

- **`journey-audit/SKILL.md`** — prior-surface mapping skill (auto-loads when designing new screens)
- **`element-reuse-check/SKILL.md`** — Gate A reuse verdict matrix
- **`persona-lens/SKILL.md`** — Gate B day-30 / partner / stranger lens (adapt persona names to fit the project; for B2C use day-30/partner/stranger; for CLI tool maybe first-run/power-user/regression-debugger)
- **`quality-bar/SKILL.md`** — S-tier rubric + composition pitfalls + demo test, anchored to THEIR benchmarks

### Rules (in `.claude-staging/rules/`)

- **`design-north-star.md`** — explicitly names THEIR Tier 1 + Tier 2 benchmarks; quotes specific anti-patterns the user mentioned in interview
- **`audit-routing.md`** — the pipeline order + when-to-dispatch table, scoped to the agents you just authored
- **`visual-verification.md`** — see-what-you-built discipline, with THEIR device-screenshot commands
- **`forbidden-phrases.txt`** — if the project has voice; populate with the universal AI-slop list + the brand-specific phrases the user provided in interview

### Hooks (in `.claude-staging/hooks/` — render from `../../hook-templates/`)

- **`check-design-tokens.sh`** — substitute `THEME_PATH` with the user's actual theme source file path
- **`check-forbidden-phrases.sh`** (if rules/forbidden-phrases.txt is shipped) — substitute scopes with the user's actual user-copy paths

## Phase 5 — Stage + present + commit

### Staging

Write everything to `.claude-staging/` first, organized by artifact type.

### Present

Walk the user through:

1. **The kit overview** — list what landed by type
2. **Top 3 highlight artifacts** — explain reasoning concretely. NOT "I added a code reviewer" but: "I added `ux-reviewer.md` with Linear + Stripe as your Tier 1 chrome and Things 3 as Tier 2 domain — those are the apps you named. The rubric anchors S = your screen sits next to a Linear screen without embarrassment."
3. **What got SKIPPED** — and why. Each skip is a deliberate call, with a reason the user can audit.
4. **Token-cost note** — a11y-audit and ux-reviewer use opus-class models; design-token-auditor uses haiku. Be honest about projected token spend.

### Approve → commit

After explicit user approval, move `.claude-staging/` → `.claude/` and commit with structured message:

```
feat(.claude): design discipline (dotclaude:design)

Authored:
- agents: ux-reviewer, a11y-audit, interaction-audit, design-token-auditor[, flow-auditor, pages-audit]
- skills: journey-audit, element-reuse-check, persona-lens, quality-bar
- rules:  design-north-star (Linear + Stripe + Things 3 anchors), audit-routing, visual-verification[, forbidden-phrases]
- hooks:  check-design-tokens, check-forbidden-phrases

Tier 1 benchmarks (chrome): <list>
Tier 2 benchmarks (domain): <list>
Voice forbidden phrases: <count>
```

## Non-negotiable rules for this flow

1. **Name benchmarks explicitly.** Every audit agent must reference THEIR Tier 1 + Tier 2 apps by name. "Apple iOS 26 + Telegram" is one valid pick; "Linear + Stripe + Notion" is another. The kit has no value if the rubric anchors are generic ("looks good").

2. **Cite real code paths.** The `interaction-audit` agent should reference the user's actual screens / components, not abstract examples. The `design-token-auditor` should know the user's actual theme file path.

3. **Derive project-specific anti-patterns.** Don't paste the principle doc's example anti-patterns into the agent's body. Read the project's recent design fixes (Phase 1 git log) and write anti-patterns specific to what THIS project has shipped wrong before.

4. **No iOS-flavored chrome agents for web projects.** If the project is web, don't reach for `xcrun simctl` references. Adapt to playwright / browser DevTools / etc. The principles are platform-agnostic; the authored agent is platform-specific to THIS project.

5. **Persona names match audience.** Day-30 / partner / stranger is right for consumer apps. For B2B dev tools, maybe first-time-user / power-user / new-team-member. For CLI: first-run / scripting / debugging-prod. The skill body should reflect THIS project's audience, not a copy from the principle.

6. **Anonymization carry-through.** The plugin's own anonymization guard runs on this repo; the artifacts you author in the user's `.claude/` are project-content, not plugin-content — the user owns them. But: do not leak between project boundaries (don't paste another user's specifics into this user's `.claude/`).

7. **Show, don't tell.** When presenting the staged output, screenshot one example agent body so the user sees the level of project-specific detail. If you can't show that detail, the agent isn't tuned enough yet — go back and tighten.
