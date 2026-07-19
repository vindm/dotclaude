---
description: Elicit the project's design north-star + design-system reference (the two artifacts the consumed design audits read at runtime); no agent copies are authored. Derived from the project's actual UI surfaces, the user's named design benchmarks, and past design failure modes. Invoke /dotclaude:design in any project root that has a human-facing surface.
---

# `/dotclaude:design` — design north-star + design-system elicitation

You are eliciting the project-specific design-discipline intent for the user's project: the named benchmarks, voice, and design-system vocabulary a design audit should grade against. The output is TWO thin artifacts — `.claude/rules/design-north-star.md` and `.claude/rules/design-system.md` — written directly, no staged agent or skill copies. The 7 design audits (`ux-audit`, `a11y-audit`, `interaction-audit`, `flow-audit`, `pages-audit`, `product-designer`, `design-token-audit`) ship with the plugin and are consumed as-is: every one already opens with "discover THIS project at runtime" and reads these two artifacts directly, so writing a project-local copy of an audit would only duplicate what the plugin ships and drift the moment either side changes.

**This is the showpiece flow.** Most Claude Code plugins focus on engineering (CI, testing, refactoring). Design / IA / UX / a11y is a near-empty niche — your user's expertise in this area is what makes dotclaude unique. Treat this flow as the differentiator: the value isn't in generating more files, it's in the depth of the elicited benchmarks, voice, and design-system digest the consumed audits read.

## Phase 1 — Read the project's UI shape

Before any question. The goal is to enter the interview already knowing **what** the project ships, **how** it's structured, **what** discipline already exists. The richer Phase 1, the fewer questions the interview needs — and the more grounded the two written artifacts will be.

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

Sample 5-8 component files. Read for: naming convention (kebab vs PascalCase), prop API patterns, styling approach (CSS modules / Tailwind / styled-components / inline). The consumed `design-token-audit` agent reads `design-system.md` for these patterns instead of re-deriving them, so name them precisely here.

### 1.6 — Route / screen inventory

```bash
# Next/Expo Router (file-based)
find . -path ./node_modules -prune -o \( -name "page.tsx" -o -name "page.jsx" -o -name "+page.svelte" -o -name "index.tsx" \) -print | head -20
# React Router / explicit
grep -rn "Route\|createBrowserRouter\|router\.get\|Stack\.Screen" src/ app/ 2>/dev/null | head -20
```

Count routes. Identify: is this single-screen, multi-screen, multi-section (tabs / dashboard sections / docs sidebar)? This determines whether the consumed `flow-audit` and `pages-audit` agents apply, and whether `design-north-star.md` needs a multi-surface chrome-reference table.

### 1.7 — CI + scripts

```bash
ls .github/workflows/ scripts/ 2>/dev/null
cat package.json 2>/dev/null | grep -A 30 '"scripts"'
```

Read for: existing visual-verification machinery (Playwright config? Maestro flows? Storybook? Chromatic?). Existing lint config. Build/test/dev scripts. The consumed `visual-verification.md` principle (read in Phase 3) already carries the see-what-you-built discipline against whatever exists; don't invent new machinery.

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

Read for: existing test infrastructure (Jest / Vitest / Playwright / Maestro). Lint rules already covering tokens / hex / a11y. `design-system.md` should name what exists so the consumed audits integrate with it, not replace it.

### 1.10 — Dev loop signal

From `package.json` scripts (already read in 1.7): identify the **dev** command (`dev`, `start`, `serve`), the **test** command, the **build** command, the **e2e** command if present. The consumed `visual-verification.md` principle and the `ux-audit` agent's capture procedure reference these commands directly at runtime — no artifact needs to restate them.

---

**At end of Phase 1**, write a one-paragraph mental-model summary to yourself:

> *Primary surface: <X>. Stack: <Y>. Existing conventions doc: <yes/no, path>. Design-system maturity: <none / partial / mature>. Multi-screen or single-screen: <X>. CI maturity: <X>. Visual-verification path already wired: <yes/no, what>. War-story SHAs to ask about: <list of 2-3 SHA + subject>.*

This is the substrate the interview adapts to. Skip questions whose answer is already in the summary.

## Phase 2 — Interview

Open `interview.md` (same directory). The interview is structured as **7 phases (A–G) driving 47 configuration knobs** — a reduced subset of the original 53-knob calibration target inherited from `docs/design-stack-analysis.md`, after dropping the knobs that only existed to tune a per-project agent copy's internals (gone now that the 7 design audits ship with the plugin and are consumed as-is). Adaptive: ~20 knobs auto-populate from Phase 1's scan; the interview drives the remaining ~27 via 19 sub-questions batchable into ~5 super-questions per turn.

The most important questions (the ones to fight for if the user resists):

- **Q-B1 / Q-B2 / Q-B3** — Tier 1 (chrome) + Tier 2 (domain, with dimension) + anti-references. Without named benchmarks in `design-north-star.md`, every consumed audit grades on vibes.
- **Q-C1 → Q-C4** — voice + assistant character + brand voice reference + banned phrases. Gates whether `persona-testing` ships.
- **Q-D1 / Q-D2** — multi-screen arcs + multi-section primary surface. Gates whether `flow-audit` / `iterative-polish-autoloop` / `pages-audit` apply.
- **Q-I1** — git-mined commit confirmation. Transforms generic textbook anti-patterns into project-specific ones.
- **Q-E3** — demo audience + quality posture. Defines what "shipped well" means.

## Phase 3 — Read the principles

Read these from `../../principles/` SELECTIVELY based on what the project actually has:

**Always read** (universal design discipline):
- `design-benchmarking.md` — picks Tier 1 + Tier 2 references + per-surface chrome reference table convention
- `visual-verification.md` — see-what-you-built discipline
- `quality-rubric.md` — S/A/B/C/D anchored on the user's benchmarks + claim-of-done preconditions (5-item checklist)
- `audit-routing.md` — canonical audit order (mechanical token sweep → semantic/interaction + a11y in parallel → visual/pages polish last, since token and semantic fixes shift layout before visual grading locks it in)
- `design-system-reference-skill.md` — teaches the eleven-section pattern for `design-system.md` (always read; the broad reference for tokens / primitives / motion / status / gotchas — authored as a rule doc now, not a project skill)

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
- `flow-audit.md` — whole-arc audit with two input modes: (a) walks a live flow end-to-end (deep, infrequent — produces canonical flow doc + dated gap report); (b) grades a pre-captured series (lightweight, frequent — takes a manifest, grades 6 flow-level dimensions)

**Read if user wants iterative polish to award-tier** (capture harness + reviewer + fixture reset all present):
- `iterative-polish-autoloop.md` — continuous polish loop with 3-layer scrutiny (reviewer / composition scan / backend-truth probe)

## Phase 4 — Write the artifacts

Based on what applied + the interview answers, write exactly two files to `.claude/rules/`, plus wire the token-discipline hook. Each artifact must cite the user's actual code paths, name THEIR benchmarks, reference THEIR past bugs — the same specificity bar Phases 1-3 built toward.

**Do NOT author any agent copy — the 7 design audits are consumed as-is from the plugin and self-adapt at runtime.** `ux-audit`, `a11y-audit`, `interaction-audit`, `flow-audit`, `pages-audit`, `product-designer`, and `design-token-audit` all ship with the plugin, already open with "discover THIS project at runtime," and read the two artifacts below directly. Writing a project-local copy of any of them (or of the plugin's `journey-mapping`, `element-reuse`, `persona-testing`, or `iterative-polish-autoloop` skills — all of which already self-adapt the same way, e.g. `persona-testing` derives its own test triad from "the project's stated voice / quality-bar / design-north-star at runtime") would duplicate what the plugin ships and drift the moment either side changes. This phase writes reference data, not code.

**Calibration target**: the interview's knob set (per `docs/design-stack-analysis.md`). Every artifact's body must thread the relevant knobs. If a drafted artifact still reads like a template, the interview didn't drive enough knobs through.

### `.claude/rules/design-north-star.md`

The binding statement of what "good" means on this project — the doc every consumed audit's rubric anchors against.

- **Tier 1 + Tier 2 benchmarks** (Q-B1/Q-B2/Q-B3) — named apps, with WHY each is the benchmark, plus anti-references (what NOT to look like)
- **Per-surface chrome reference table** — the row-per-surface convention from `design-benchmarking.md`: one row per named surface, its Tier 1 reference, its Tier 2 reference
- **Voice / banned phrases** (Q-C4) — the elicited `BRAND_BANNED_PHRASES` deny-list plus the voice/anti-reference signal, so `persona-testing` and the taste audits have a home for it at runtime
- **Accessibility compliance target** (Q-E3) — the named bar: WCAG 2.2 AA (default), AAA, Section 508, or none/internal-only. The consumed `a11y-audit` agent reads this at runtime to set its contrast and text-scaling thresholds — omitting it silently falls back to WCAG 2.2 AA rather than the project's actual bar.
- **Project-specific anti-patterns mined from git** (Phase 1.8 SHAs, confirmed in Q-I1) — 3-5 concrete "this shipped wrong before, here's the commit" entries, not generic anti-patterns lifted from a principle doc
- **The demo test** — one line, instantiated from `quality-rubric.md`'s Component 1: "would I show this screen to \<the named audience/benchmark peer>?" Anchor the audience to a real person, role, or the Tier 1/Tier 2 benchmark the user named — this is the reproducible check that closes a grading debate without re-litigating taste.
- **Claim-of-done checklist** — the design-specific definition-of-done, instantiated from `quality-rubric.md`'s canonical 5-item checklist: fresh screenshot captured / lint clean / tests pass / 5-pitfall composition scan done / Tier 1+Tier 2 benchmark named in the grade. A UI change isn't "done," only "in progress," until all five hold.

### `.claude/rules/design-system.md`

The design-system reference digest, per the `design-system-reference-skill.md` principle's eleven-section pattern: north-star pointer / native chrome primitives / token architecture / tokens source-of-truth / styling API / semantic colors table / surface hierarchy / motion principles + presets / shadow presets / status color system / quality tiers + library gotchas + i18n. It was previously authored as a project skill (`design-system/SKILL.md`); it's now a plain reference doc in `.claude/rules/` — the consumed audits read it directly at runtime instead of re-deriving tokens / primitives / motion on every dispatch.

- Include the **post-edit command rule** ("after editing `<tokens source>`, run `<command>`") inside this doc — without it, generated tokens drift from source.
- Include the **library gotchas** as a dedicated, easy-to-extend subsection, not buried in prose.
- Include the S-tier quality-tier table (per-surface grade targets) here rather than as a separate skill — it reads the Tier 1/2 names from `design-north-star.md` and pairs them with the generic rubric mechanics already covered by the always-read `quality-rubric.md` principle.
- Include the **fast-vs-careful decision rule**, instantiated from `quality-rubric.md`'s Component 5: name which of THIS project's actual change shapes need the full audit pass (UI surface changes, copy/voice changes, cross-module refactors) versus which are trivial enough to skip it (typo fixes, isolated renames, type-only diffs). When in doubt, default to careful.

### Hooks (in `.claude-staging/hooks/` — render from `../../hook-templates/`)

- **`check-design-tokens.sh`** — substitute `THEME_PATH` with the user's actual theme source file path
- **`check-no-legacy-blur.sh`** (if iOS / Expo + has modern glass primitive) — block legacy blur API imports
- **`check-platform-icons.sh`** (if iOS + native tabs use SF Symbols) — block native-tab icons without system-symbol prop

## Depth checklist (MANDATORY per authored artifact)

Each of the two artifacts you write in Phase 4 MUST contain ALL of these 10 structural elements, or the artifact is shallow and the user will reject it. This checklist is the difference between a "v0.1 sketch" and a "battle-tested reference." Treat it as binding.

**Calibration target**: the interview's knob set (see `docs/design-stack-analysis.md` for the full knob map). Each artifact's depth signature is achieved by threading the relevant subset of knobs into its body — not by adding length. A 150-LOC rule with 12 project-specific knob references beats a 300-LOC body of generic methodology.

1. **Named benchmarks** — specific Tier 1 + Tier 2 apps from the interview, with WHY each is the benchmark. "Apple-like" or "modern apps" is NOT a benchmark. "Linear for keyboard speed" or "Apple iOS 26 Settings + Telegram for chrome" is. (`design-north-star.md`)

2. **5+ inspection dimensions** — each with a concrete method (grep pattern, command, manual check) THIS project's audits can run against `design-system.md`'s vocabulary. Vague "look for issues" fails this check. "Sweep `#[0-9a-fA-F]{3,8}` across `src/**/*.tsx` excluding `theme.ts`" passes. (`design-system.md`)

3. **Rubric anchored per grade** — S/A/B/C/D/F with each grade referencing a NAMED benchmark. "S = a Linear engineer would compliment this; A = ships at Linear quality with one polish pass; B = ships at competent SaaS quality; C = ships but visibly behind; D = embarrassing next to Linear; F = block ship." Each tier mentions the actual app. (`design-north-star.md`, mirrored in `design-system.md`'s quality-tier table)

4. **Named sections, not prose dumps** — both artifacts use explicit headers (`## Tier 1 / Tier 2`, `## Per-surface chrome reference`, `## Voice / banned phrases`, `## Surface hierarchy`, `## Status colors`, etc.) so a consumed audit's runtime read is predictable and scannable.

5. **Cross-references** — each artifact names the other, plus at least one principle it pairs with (e.g. `design-system.md` says "quality-tier grades pair with `quality-rubric.md`'s S/A/B/C/D mechanics"; `design-north-star.md` says "voice/banned phrases feed `persona-testing` at runtime"). Composability is what makes the two artifacts a system, not two disconnected files.

6. **Numbered non-negotiable rules / discipline statements** — 5-10 with rationale per rule, not just a list of "do this." "1. Never grade without a captured screenshot — pixel review is the contract; reading code is not a substitute." The rationale clause is what makes the rule sticky.

7. **Project-specific anti-patterns from git** — 3-5 anti-patterns derived from the **bug-mining sub-phase** (interview Phase D / Phase 1.8 SHAs). E.g. "Settings page bypassed the type scale for two weeks before someone noticed (commit `abc1234`) — sweep for `font-size:` / `text-[` outside the typography scale." Generic anti-patterns from a principle doc do NOT count for this slot. (`design-north-star.md`)

8. **Edge cases + abort conditions** — explicit "do NOT do X" and "abort if Y" that a consumed audit reading this artifact should honor. E.g. "Never skip a surface-hierarchy level — a level-4 surface only appears in the contexts level 4 is designed for."

9. **Calibration text** — concrete examples of S-tier and F-tier output. *"S-tier looks like: <2-3 sentences of what a passing audit reads like>. F-tier looks like: <2-3 sentences of what failure reads like>."* This is what makes "S" enforceable rather than impressionistic.

10. **Operational specifics** — tool commands, file paths derived from Phase 1 scan, environment variables. E.g. `npx playwright test --grep "@visual"`, `find src/components -name "*.tsx" | xargs grep -l "useTheme"`, `theme.colors.accent.primary`. Abstract artifacts cite no commands and ground nothing.

**If your draft lacks ANY of these 10 elements, go back and add it.** Battle-tested depth is not optional polish — it's the contract.

### LOC targets (signal, not gospel)

- **`design-north-star.md`**: **40–100 LOC**.
- **`design-system.md`**: **100–200 LOC** (eleven sections; longer than the north-star because it's the full digest).

If your draft comes in noticeably under these ranges, you've shipped shallow. Stop and deepen — almost always one of the 10 elements is missing or perfunctory. The LOC range is a heuristic; the 10-element checklist is the actual contract.

### How to verify depth before writing

After drafting each artifact, before writing it to `.claude/rules/`, run a self-check:

```
For each of the 10 elements:
- Is it present? (yes / no)
- Is it project-specific or generic-textbook? (project / generic)
- Would the user be able to point at the specific line that fulfills it? (yes / no)
```

Any "no" or "generic" answer means redo. Cite the user's interview answers; cite the Phase 1 file paths; cite the SHAs you mined from git. Specificity is the signal.

## Phase 5 — Present + commit

### Present

Walk the user through:

1. **The two artifacts** — what landed in `design-north-star.md` vs `design-system.md`, plus which hooks were wired
2. **Highlight the calibration** — explain reasoning concretely. NOT "I set up your benchmarks" but: "`design-north-star.md` names Linear + Stripe as your Tier 1 chrome and Things 3 as Tier 2 domain — those are the apps you named. The per-surface table anchors S = your screen sits next to a Linear screen without embarrassment."
3. **What got SKIPPED** — sections of `design-system.md` with no project equivalent (no motion library → no presets table; no i18n → no i18n subsection), and why. Each skip is a deliberate call, with a reason the user can audit.
4. **Consumed-audit note** — remind the user which of the 7 consumed audits use opus-class models (`ux-audit`, `a11y-audit`, `interaction-audit`, `flow-audit`, `pages-audit`, `product-designer`) vs haiku (`design-token-audit`), so they know the projected token spend when those audits run — none of this is authored per-project, it's the plugin's existing model tiering.

### Approve → commit

After explicit user approval, write the two files to `.claude/rules/`, wire the hook(s), and commit with structured message:

```
feat(.claude): design north-star + design-system reference (dotclaude:design)

Authored:
- rules: design-north-star (Linear + Stripe + Things 3 anchors), design-system
- hooks: check-design-tokens[, check-no-legacy-blur, check-platform-icons]

Consumed as-is (no project copy): ux-audit, a11y-audit, interaction-audit,
design-token-audit[, flow-audit, pages-audit], product-designer

Tier 1 benchmarks (chrome): <list>
Tier 2 benchmarks (domain): <list>
```

## Non-negotiable rules for this flow

1. **Name benchmarks explicitly.** `design-north-star.md` must reference THEIR Tier 1 + Tier 2 apps by name. "Apple iOS 26 + Telegram" is one valid pick; "Linear + Stripe + Notion" is another. The artifact has no value if the rubric anchors are generic ("looks good") — every consumed audit's rubric depends on it.

2. **Cite real code paths.** `design-system.md` must reference the user's actual theme/token source file and component paths, not abstract examples — the consumed `design-token-audit` and `a11y-audit` agents read it instead of re-deriving the path.

3. **Derive project-specific anti-patterns.** Don't paste a principle doc's example anti-patterns into `design-north-star.md`. Read the project's recent design fixes (Phase 1 git log) and write anti-patterns specific to what THIS project has shipped wrong before.

4. **No iOS-flavored chrome references in `design-system.md` for web projects.** If the project is web, don't reach for `xcrun simctl` or UIKit-specific primitives. Adapt to playwright / browser DevTools / Radix / etc. The principles are platform-agnostic; the artifact you write is platform-specific to THIS project.

5. **Persona names match audience — but that's the consumed skill's job, not yours.** `persona-testing` already derives the fitting triad (day-30/partner/stranger for consumer apps, first-run/power-user/regression-debugger for a CLI, etc.) from "the project's stated voice / quality-bar / design-north-star at runtime." Your job in this flow is narrower: make sure `design-north-star.md` states the project's actual voice and audience accurately enough for that runtime derivation to work.

6. **Anonymization carry-through.** The plugin's own anonymization guard runs on this repo; the two artifacts you write in the user's `.claude/rules/` are project-content, not plugin-content — the user owns them. But: do not leak between project boundaries (don't paste another user's specifics into this user's `.claude/`).

7. **Show, don't tell.** When presenting the drafted output, quote a real section of `design-north-star.md` or `design-system.md` so the user sees the level of project-specific detail. If you can't show that detail, the artifact isn't tuned enough yet — go back and tighten.
