---
description: Set up design / IA / UX / a11y / visual-quality discipline for a project. Authors a tailored kit of design audit agents, IA skills, and design-token rules — derived from the project's actual UI surfaces, the user's named design benchmarks, and past design failure modes. Invoke /dotclaude:design in any project root that has a human-facing surface.
---

# `/dotclaude:design` — design discipline kit

You are setting up design-discipline for the user's project. The output is a `.claude/` subset tuned to design / IA / UX / a11y / visual quality — agents that audit, skills that pre-empt, rules that anchor.

**This is the showpiece flow.** Most Claude Code plugins focus on engineering (CI, testing, refactoring). Design / IA / UX / a11y is a near-empty niche — your user's expertise in this area is what makes dotclaude unique. Treat this flow as the differentiator.

## Phase 1 — Read the project's UI shape

Before any question. The goal is to enter the interview already knowing **what** the project ships, **how** it's structured, **what** discipline already exists. The richer Phase 1, the fewer questions the interview needs — and the more grounded the authored agents will be.

Run these 10 reads. Each gives a data point the interview leverages.

### 1.1 — Stack signal

```bash
# Stack identity
cat README.md 2>/dev/null | head -40
cat package.json 2>/dev/null | head -60
cat pyproject.toml Cargo.toml go.mod composer.json 2>/dev/null | head -20
```

Read for: framework, language, target platform. Mobile? Web? Desktop? Both?

### 1.2 — Top-level structure (2 levels deep)

```bash
ls -la
ls -la src/ app/ lib/ components/ pages/ routes/ 2>/dev/null
```

Read for: where does UI code live? Is there a clear `components/` directory? `app/` (Next/Expo Router)? `routes/` (SvelteKit/Remix)?

### 1.3 — Existing project conventions

```bash
ls -la CLAUDE.md AGENTS.md CONTRIBUTING.md STYLE_GUIDE.md BRAND.md docs/ 2>/dev/null
find . -maxdepth 3 -name "CLAUDE.md" -o -name "AGENTS.md" 2>/dev/null
```

Read **every** found doc fully. Conventions in these files override anything you'd otherwise author. The user's existing docs win every conflict.

### 1.4 — Design system source

```bash
find . -path ./node_modules -prune -o \( \
  -name "tokens.*" -o -name "theme.*" -o -name "design-system.*" \
  -o -name "*.tokens.json" -o -name "tailwind.config.*" \
  -o -name "globals.css" -o -name "variables.scss" \
\) -print 2>/dev/null
```

If found, **read the file**. Note: token naming convention (semantic vs palette), dark-mode support, the scale of the system (10 tokens vs 200).

### 1.5 — Component library inventory

```bash
ls components/ src/components/ src/ui/ lib/ui/ app/components/ 2>/dev/null
```

Sample 5-8 component files. Read for: naming convention (kebab vs PascalCase), prop API patterns, styling approach (CSS modules / Tailwind / styled-components / inline). The authored `design-token-auditor` needs to know which patterns to sweep.

### 1.6 — Route / screen inventory

```bash
# Next/Expo Router (file-based)
find . -path ./node_modules -prune -o \( -name "page.tsx" -o -name "page.jsx" -o -name "+page.svelte" -o -name "index.tsx" \) -print | head -20
# React Router / explicit
grep -rn "Route\|createBrowserRouter\|router\.get\|Stack\.Screen" src/ app/ 2>/dev/null | head -20
```

Count routes. Identify: is this single-screen, multi-screen, multi-section (tabs / dashboard sections / docs sidebar)? This determines whether `flow-auditor` and `pages-audit` agents apply.

### 1.7 — CI + scripts

```bash
ls .github/workflows/ scripts/ 2>/dev/null
cat package.json 2>/dev/null | grep -A 30 '"scripts"'
```

Read for: existing visual-verification machinery (Playwright config? Maestro flows? Storybook? Chromatic?). Existing lint config. Build/test/dev scripts. The authored `visual-verification.md` rule references whatever exists; don't invent new ones.

### 1.8 — Git history mining (PRE-INTERVIEW)

```bash
git log --oneline -30
git log --oneline --grep="fix:" -30
git log --oneline -E --grep="design|UX|style|color|spacing|a11y|layout|copy|tone|chrome|polish" -30
```

Identify the **2-3 most design-flavored commits** by subject line. These are what you'll ask about by SHA in interview Phase D. **Do this before the interview**, not during — you want to enter the interview already armed with the SHAs.

### 1.9 — Assertions / lint config

```bash
ls .eslintrc* .prettierrc* tsconfig.json biome.json 2>/dev/null
find . -maxdepth 3 -name "jest.config.*" -o -name "vitest.config.*" -o -name "playwright.config.*" -o -name ".maestro" 2>/dev/null
```

Read for: existing test infrastructure (Jest / Vitest / Playwright / Maestro). Lint rules already covering tokens / hex / a11y. The authored agents should integrate with what exists, not replace it.

### 1.10 — Dev loop signal

From `package.json` scripts (already read in 1.7): identify the **dev** command (`dev`, `start`, `serve`), the **test** command, the **build** command, the **e2e** command if present. The authored `visual-verification.md` and the `ux-reviewer` agent's capture procedure reference these explicitly.

---

**At end of Phase 1**, write a one-paragraph mental-model summary to yourself:

> *Primary surface: <X>. Stack: <Y>. Existing conventions doc: <yes/no, path>. Design-system maturity: <none / partial / mature>. Multi-screen or single-screen: <X>. CI maturity: <X>. Visual-verification path already wired: <yes/no, what>. War-story SHAs to ask about: <list of 2-3 SHA + subject>.*

This is the substrate the interview adapts to. Skip questions whose answer is already in the summary.

## Phase 2 — Interview

Open `interview.md` (same directory). The interview is structured as **10 phases (A–J) driving 53 configuration knobs** — the calibration target inherited from `docs/design-stack-analysis.md`. Adaptive: ~25 knobs auto-populate from Phase 1's scan; the interview drives the remaining ~28 via ~17-18 sub-questions batchable into 5-6 super-questions per turn.

The most important questions (the ones to fight for if the user resists):

- **Q-B1 / Q-B2 / Q-B3** — Tier 1 (chrome) + Tier 2 (domain, with dimension) + anti-references. Without named benchmarks, every authored agent grades on vibes.
- **Q-C1 → Q-C4** — voice + assistant character + brand voice reference + forbidden phrases. Gates whether `persona-testing` + `forbidden-phrases` ship.
- **Q-D1 / Q-D2** — multi-screen arcs + multi-section primary surface. Gates whether `flow-audit` / `flow-continuity-review` / `iterative-polish-autoloop` / `pages-audit` apply.
- **Q-I1** — git-mined commit confirmation. Transforms generic textbook anti-patterns into project-specific ones.
- **Q-E3** — demo audience + quality posture. Defines what "shipped well" means.

## Phase 3 — Read the principles

Read these from `../../principles/` SELECTIVELY based on what the project actually has:

**Always read** (universal design discipline):
- `design-benchmarking.md` — picks Tier 1 + Tier 2 references + per-surface chrome reference table convention
- `visual-verification.md` — see-what-you-built discipline
- `quality-rubric.md` — S/A/B/C/D anchored on the user's benchmarks + claim-of-done preconditions (5-item checklist)
- `audit-routing.md` — which audit fires for which question + cheapest-tier-wins discipline
- `design-system-reference-skill.md` — design-system entry-point skill the project ships (always read; the broad reference for tokens / primitives / motion / status / gotchas)

**Read if project is in design / spec / IA phase** (new features incoming):
- `product-designer.md` — senior-IC IA / flow / multi-screen designer agent

**Read if project has multi-screen UI** (most non-trivial UIs):
- `ux-audit.md` — single-screen audit
- `a11y-audit.md` — accessibility
- `interaction-audit.md` — semantic chrome-vs-handler
- `design-token-audit.md` — token discipline sweep
- `journey-mapping.md` — prior-surface mapping before any new screen design (DUAL LOAD — design + audit time)
- `element-reuse.md` — Gate A reuse verdict (DUAL LOAD — design + audit time)
- `persona-testing.md` — outside-eyes lens on copy (DUAL LOAD — design + audit time)

**Read if project has multi-section primary surface** (tabs / dashboard sections / docs sidebar):
- `pages-audit.md` — cross-section consistency

**Read if project has multi-screen arcs** (onboarding, wizard, checkout):
- `flow-audit.md` — whole-arc audit (deep, infrequent — produces canonical flow doc + dated gap report)
- `flow-continuity-review.md` — lightweight series grader (frequent, takes pre-captured manifest, grades 6 flow-level dimensions)

**Read if user wants iterative polish to award-tier** (capture harness + reviewer + fixture reset all present):
- `iterative-polish-autoloop.md` — continuous polish loop with 3-layer scrutiny (reviewer / composition scan / backend-truth probe)

**Read if project has a CLAUDE.md / vision doc** (drift detection wanted):
- `product-direction-validator.md` — vision-alignment guardian / drift detector / agent coordinator

**Read if project has product voice** (any user-facing copy):
- `forbidden-phrases.md` — voice discipline

## Phase 4 — Author the kit

Based on what applied + the interview answers, author these in `.claude-staging/`. Each artifact must cite the user's actual code paths, name THEIR benchmarks, reference THEIR past bugs.

**Calibration target**: the **53-knob configuration** captured by the interview (per `docs/design-stack-analysis.md`). Every authored artifact's frontmatter + body must thread the relevant knobs. The interview's purpose is exactly this calibration; if an authored artifact still reads like a template, the interview didn't drive enough knobs through.

### Agents (in `.claude-staging/agents/`)

- **`ux-reviewer.md`** — single-screen visual audit
  - Frontmatter: `description: <copy from principle, tuned with user's Tier 1 + Tier 2 names>`
  - Body: screenshot procedure for THEIR device target (iOS sim? Playwright? screenshot script?), grading rubric anchored to THEIR named benchmarks (e.g. "S = looks like Linear or Stripe" if those are their picks), composition pitfalls grounded in screenshots they showed in interview
  - Include the `IN_PRODUCT_ASSISTANT_CHARACTER` daily-driver trap check if Q-C2 said yes
  - Reference `quality-bar` skill

- **`a11y-audit.md`** — accessibility (only if UI is user-facing-end-user, not internal-only)
  - 4+1 dimensions adapted to THEIR platform (VoiceOver for iOS, screen reader for web, equivalent for desktop)
  - Hit-target sizes per platform (44pt iOS, 48dp Android, 44×44px web touch)
  - **Contrast computed from THEIR TOKEN values, not screenshot-estimated** (per principle's core methodology)
  - Dynamic Type / rem-scaling per platform

- **`interaction-audit.md`** — semantic chrome integrity
  - The affordance-vs-behavior table
  - Pattern catalog (dead chrome / redundant affordance / optical-group disconnect)
  - Project-specific examples from THEIR codebase if found in Phase 1 git log (Q-I1 confirmations)

- **`design-token-auditor.md`** — token discipline regex sweep
  - Targets: THEIR design system source file (which you found in Phase 1)
  - Sweep patterns: hex / rgba / hsla / Tailwind arbitrary values
  - Override convention: `// allow-color: <reason>`
  - Tier: haiku model (cheap) per `design-token-audit.md` principle

- **`flow-auditor.md`** (if multi-screen arcs) — whole-arc audit
  - 8-class gap rubric from `flow-audit.md` principle
  - Arc inventory: list THEIR known arcs (signup, onboarding, checkout, etc.) — derive from Q-D1 + Phase 1 routes
  - **Owner / Fix-by handoff column convention** in findings table

- **`pages-audit.md`** (if multi-section primary surface) — cross-section consistency
  - Shared-component grep first, pixel measurement last
  - List THEIR primary sections (read from Q-D2 + Phase 1 routes/tabs)

- **`product-designer.md`** (if user wants design phase support — Q-J1 + general posture)
  - Per `product-designer.md` principle — 8-step procedure
  - Reference THEIR spec doc convention (Q-H1), capability map path if any (Q-J1), prototype gates if any (Q-J1)
  - Self-audit checklist verbatim

- **`flow-ux-reviewer.md`** (if multi-screen arcs + capture harness)
  - Per `flow-continuity-review.md` principle — manifest-driven series grader
  - 6 flow-level dimensions
  - Bridge reference apps from Q-B2

- **`product-compass.md`** (if vision docs exist — Q-J1)
  - Per `product-direction-validator.md` principle — Vision Health verdict + drift detection + agent coordination

### Skills (in `.claude-staging/skills/`)

- **`design-system/SKILL.md`** — design-system entry-point skill per `design-system-reference-skill.md` principle (11 sections — north-star / native primitives / tokens / styling API / semantic colors / surface hierarchy / motion / shadows / status / quality tiers / library gotchas + i18n)
- **`journey-audit/SKILL.md`** — prior-surface mapping skill (DUAL LOAD — fires at design AND audit time)
- **`element-reuse-check/SKILL.md`** — Gate A reuse verdict matrix (DUAL LOAD)
- **`persona-lens/SKILL.md`** — Gate B day-30 / partner / stranger lens (DUAL LOAD; adapt triad: for B2C use day-30/partner/stranger; for CLI tool maybe first-run/power-user/regression-debugger; for docs-site skimmer/focused/reference)
- **`quality-bar/SKILL.md`** — S-tier rubric + composition pitfalls + demo test + claim-of-done preconditions (5-item checklist), anchored to THEIR benchmarks
- **`ruthless-ux-autoloop/SKILL.md`** (if user wants iterative polish) — per `iterative-polish-autoloop.md` principle — 3-layer scrutiny + iteration cap + safety invariants

### Rules (in `.claude-staging/rules/`)

- **`design-north-star.md`** — explicitly names THEIR Tier 1 + Tier 2 benchmarks; quotes specific anti-patterns the user mentioned in interview; **per-surface chrome reference table** (the row-per-surface convention from `design-benchmarking.md`)
- **`audit-routing.md`** — the pipeline order + when-to-dispatch table, scoped to the agents you just authored; **cheapest-tier-wins discipline** explicit (hook < rule < skill < agent in token cost)
- **`visual-verification.md`** — see-what-you-built discipline, with THEIR device-screenshot commands
- **`forbidden-phrases.txt`** — if the project has voice; populate with the universal AI-slop list + the brand-specific phrases the user provided in interview (Q-C4)

### Hooks (in `.claude-staging/hooks/` — render from `../../hook-templates/`)

- **`check-design-tokens.sh`** — substitute `THEME_PATH` with the user's actual theme source file path
- **`check-forbidden-phrases.sh`** (if rules/forbidden-phrases.txt is shipped) — substitute scopes with the user's actual user-copy paths
- **`check-no-legacy-blur.sh`** (if iOS / Expo + has modern glass primitive) — block legacy blur API imports
- **`check-platform-icons.sh`** (if iOS + native tabs use SF Symbols) — block native-tab icons without system-symbol prop

### Companion artifacts to ship alongside the major artifacts

When you ship a major artifact, also ship its companion(s):

- **`product-designer.md` agent** ships with the **self-audit checklist** verbatim in the agent body — not as a reference. The checklist is the gate.
- **`iterative-polish-autoloop.md` skill** ships with the **iteration-cap rule** (hard cap N, soft cap N-4) + the **safety invariants list** (do-not-edit migrations / fixtures / harness YAML).
- **`flow-ux-reviewer.md` agent** ships with the **manifest schema** definition — `{step, name, path, context}` shape stated explicitly so the capture skill produces compatible output.
- **`design-system/SKILL.md`** ships with the **post-edit command rule** (*"After editing `<tokens>`, run `<command>`"*) — without it, generated tokens drift from source.
- **`product-compass.md` agent** ships with the **agent coordination table** (situation → recommended-agent), not just prose.

## Depth checklist (MANDATORY per authored agent)

Every agent / skill / rule you author in Phase 4 MUST contain ALL of these 10 structural elements, or the artifact is shallow and the user will reject it. This checklist is the difference between a "v0.1 sketch" and a "battle-tested kit." Treat it as binding.

**Calibration target**: the **53-knob configuration** from the interview (see `docs/design-stack-analysis.md` for the full knob map; the interview drives them). Each authored artifact's depth signature is achieved by threading the relevant subset of knobs into its body — not by adding length. A 250-LOC agent body with 12 project-specific knob references beats a 400-LOC body of generic methodology.

1. **Named benchmarks** — specific Tier 1 + Tier 2 apps from the interview, with WHY each is the benchmark. "Apple-like" or "modern apps" is NOT a benchmark. "Linear for keyboard speed" or "Apple iOS 26 Settings + Telegram for chrome" is.

2. **5+ inspection dimensions** — each with a concrete method (grep pattern, command, manual check). Vague "look for issues" fails this check. "Sweep `#[0-9a-fA-F]{3,8}` across `src/**/*.tsx` excluding `theme.ts`" passes.

3. **Rubric anchored per grade** — S/A/B/C/D/F with each grade referencing a NAMED benchmark. "S = a Linear engineer would compliment this; A = ships at Linear quality with one polish pass; B = ships at competent SaaS quality; C = ships but visibly behind; D = embarrassing next to Linear; F = block ship." Each tier mentions the actual app.

4. **Report-format sections** — explicit named sections (not "describe findings" but `## Strengths / ## Critical issues / ## Verdict / ## Highest-ROI move`). The agent must produce predictable output the user can scan.

5. **Cross-references** — at least 2 other artifacts (skills / rules / agents) this composes with. The artifact says "runs AFTER `interaction-audit`," "consumes the journey map from `journey-audit/SKILL.md`," etc. Composability is what makes a kit a kit.

6. **Numbered non-negotiable rules** — 5-10 rules with rationale per rule, not just a list of "do this." "1. Never grade without a captured screenshot — pixel review is the contract; reading code is not a substitute." The rationale clause is what makes the rule sticky.

7. **Project-specific anti-patterns from git** — 3-5 anti-patterns derived from the **bug-mining sub-phase** (interview Phase D). E.g. "Settings page bypassed the type scale for two weeks before someone noticed (commit `abc1234`) — sweep for `font-size:` / `text-[` outside the typography scale." Generic anti-patterns from the principle doc do NOT count for this slot.

8. **Edge cases + abort conditions** — explicit "do NOT do X" and "abort if Y." E.g. "If the captured screenshot is stale (timestamp older than the most recent edit), STOP and recapture before grading." Refusal lists are part of this slot.

9. **Calibration text** — concrete examples of S-tier and F-tier output. *"S-tier looks like: <2-3 sentences of what a passing audit reads like>. F-tier looks like: <2-3 sentences of what failure reads like>."* This is what makes "S" enforceable rather than impressionistic.

10. **Operational specifics** — tool commands, file paths derived from Phase 1 scan, environment variables. E.g. `npx playwright test --grep "@visual"`, `find src/components -name "*.tsx" | xargs grep -l "useTheme"`, `theme.colors.accent.primary`. Abstract artifacts cite no commands and grade nothing.

**If your draft lacks ANY of these 10 elements, go back and add it.** Battle-tested depth is not optional polish — it's the contract.

### LOC targets (signal, not gospel)

- **Major agents** (`ux-reviewer`, `a11y-audit`, `interaction-audit`, `flow-auditor`): **150–250 LOC**.
- **Skills** (`journey-audit/SKILL.md`, `element-reuse-check/SKILL.md`, `persona-lens/SKILL.md`, `quality-bar/SKILL.md`): **80–150 LOC**.
- **Rules** (`design-north-star.md`, `audit-routing.md`, `visual-verification.md`): **40–100 LOC**.

If your draft comes in **under 100 LOC for a major agent**, you've shipped shallow. Stop and deepen — almost always one of the 10 elements is missing or perfunctory. The 100-LOC line is a heuristic; the 10-element checklist is the actual contract.

### How to verify depth before staging

After authoring each artifact, before moving to staging, run a self-check:

```
For each of the 10 elements:
- Is it present? (yes / no)
- Is it project-specific or generic-textbook? (project / generic)
- Would the user be able to point at the specific line that fulfills it? (yes / no)
```

Any "no" or "generic" answer means redo. Cite the user's interview answers; cite the Phase 1 file paths; cite the SHAs you mined from git. Specificity is the signal.

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
