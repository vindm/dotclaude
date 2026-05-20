# `/dotclaude:design` interview

17-20 questions across 10 phases (A–J), capturing **all 53 configuration knobs** from the design-stack analysis (`docs/design-stack-analysis.md`). Adaptive: skip ruthlessly when Phase 1 (project scan) already answered. The interview's job is to surface the **design DNA Claude Code cannot read from code** — named benchmarks, voice character, war-story bugs, surface inventories, native primitives, capture commands, compliance bar, model tier, and strategy lens — so the authored kit grades against *real anchors* instead of vibes.

**Pacing rule**: 1–2 questions per turn, conversational. Never fire-hose all 17+ at once. Listen for off-script signal ("our settings page got out of hand") — that's gold for the agents' anti-patterns sections.

**Skip discipline**: if a question's answer is obvious from Phase 1's scan, do NOT ask — confirm in one sentence and move on. The cost of asking a redundant question is real (it signals "you weren't paying attention to my code"). Phase 1 reliably auto-discovers ~25 of the 53 knobs; the interview drives the remaining ~28.

**Batching guidance**: questions can be batched into ~5-6 super-questions per turn for actual interview UX. The numbered Q-A1 / Q-B2 / etc. are the underlying knob drivers; the turns can group several.

---

## Phase A — Platform + dev-loop (2 Qs, ~5 knobs)

The point of Phase A is **confirmation, not discovery**. Phase 1 has already told you ~70% of this.

### Q-A1 — Primary surface platform

> "What's the primary surface this project ships? iOS, Android, web (browser), desktop (native macOS/Win/Linux), CLI/TUI, browser extension, embedded device?"

**Drives knobs**: `PRIMARY_SURFACE_PLATFORM`, `HIT_TARGET_MINIMUM` (inferred: 44pt iOS / 48dp Android / 44px web touch), `LABEL_API` (inferred: `accessibilityLabel` iOS/RN / `aria-label` web / `contentDescription` Android), `DYNAMIC_TYPE_UPPER_BOUND_PERCENT` (inferred: 200 Android / 310 iOS).

If multi-surface (e.g. "RN app + admin web"), ask which surface to prioritize. **Skip if Phase 1 found `package.json` with `expo` + an `ios/` directory** — confirm in one sentence: *"Looks like an iOS Expo app — primary surface is iOS, confirm?"*

### Q-A2 — Capture + dev-loop

> "How do you capture screenshots / inspect rendered output during development? Hot-reload + sim screenshot? Playwright? Manual screenshot at a staging URL? Storybook? Maestro? Any physical device path?"

**Drives knobs**: `CAPTURE_COMMAND_PRIMARY`, `CAPTURE_COMMAND_PHYSICAL_DEVICE`, `HIERARCHY_INSPECTION_COMMAND`, `VISUAL_VERIFICATION_TOOL`, `DEVICE_TARGET_DETECT_COMMAND`, `DEV_LOOP_TOOL`, `LOG_INSPECTION_PATH`.

Many of these are inferrable from Phase 1 scan (`package.json` scripts / `playwright.config.ts` / `.maestro` directory / `ps aux | grep`). **Skip-and-confirm when scan found explicit signals.**

---

## Phase B — Benchmarks (3 Qs, ~6 knobs) — THE most important section

Without named benchmarks, every authored agent's grading rubric collapses to "looks good," which is unenforceable. **Do not skip this phase.** If the user resists, push once — *"Even one app you respect helps. Without an anchor, the audit has no rubric."*

### Q-B1 — Tier 1 benchmark apps (chrome parity)

> "Name 2-3 apps you benchmark **chrome** against — the apps your users already have on their device, the apps your product gets compared to by reflex when they open it. 'When I look at my screen and then look at App X, which one tells me my chrome is wrong?'"

**Drives knob**: `TIER_1_BENCHMARKS` (with "what to steal" per ref).

Common picks by platform (PROMPT, don't prescribe):
- **iOS consumer** → Apple iOS 26 Music / Photos / Settings / Wallet + Telegram on iOS 26
- **Web SaaS B2B** → Linear / Stripe / Notion
- **Developer tool** → Linear / Raycast / Things 3
- **Content product** → Apple News / Reeder / Substack
- **B2B dashboards** → Linear / Vercel / Stripe / Datadog
- **CLI / TUI** → `gh`, `lazygit`, `htop`

If the user says "we don't really benchmark" — try once: *"What app on your device do you think is well-designed?"* Almost everyone has an answer.

### Q-B2 — Tier 2 benchmark apps (domain anchors, **with dimension**)

> "Name 2-3 apps you benchmark **specific dimensions** against. Not chrome-overall but specific things they do well. E.g. Linear for keyboard speed, WHOOP for data density, Things 3 for empty states, Stripe for checkout sequencing. Each name comes with the dimension."

**Drives knobs**: `TIER_2_BENCHMARKS_WITH_DIMENSION`, `BRIDGE_REFERENCE_APPS` (optional follow-up — references for elegant arc transitions, e.g. Apple iCloud onboarding, Stripe checkout, Telegram phone-number flow).

The **dimension is the load-bearing part**. "We like Notion" is useless. "Notion for inline editing affordances" is enforceable. Push for the dimension; without it the Tier 2 benchmark doesn't anchor anything.

### Q-B3 — Anti-references

> "Apps the design should **NOT** look like? Aesthetics or patterns you've explicitly rejected? 'No SAP', 'no early-Material 2', 'nothing that screams Bootstrap', 'no consumer-y/bubbly tone'."

**Drives knob**: `ANTI_REFERENCES`.

Anti-references are equally important — they tell agents what to **reject**. Without B3, the rubric only knows what to chase, not what to avoid.

---

## Phase C — Voice + persona (4 Qs, ~7 knobs)

Skip entirely if Q-E2 said "internal-only" OR product has no user-facing copy beyond labels.

### Q-C1 — Brand voice + product-has-voice gate

> "Does the product have an authored voice the team enforces, or is copy purely functional? Three quick checks: (1) Is there a brand voice doc / style guide? (2) Pick 3 adjectives. (3) Show me one phrasing from a real surface that nails the voice."

**Drives knobs**: `PRODUCT_HAS_VOICE` (boolean, gates all of Phase C remainder), the adjective triad for downstream calibration.

The third part — the real example — is highest-signal. Adjectives are too vague; a real phrase from a real surface anchors voice for every authored copy / forbidden-phrases artifact.

If `PRODUCT_HAS_VOICE = false`, **skip C2 / C3 / C4** and move to Phase D.

### Q-C2 — In-product assistant character

> "Does the product have a named in-product assistant character (an AI helper, a mascot, a personality the product wears)? If yes — name + where does it introduce itself (file path)?"

**Drives knob**: `IN_PRODUCT_ASSISTANT_CHARACTER` (boolean + name + intro-surface-path).

If **yes**, flag the **daily-driver-vs-first-touch trap** — a class of bug where the assistant's onboarding voice ("Hi — I'm <name>, let me show you around!") leaks onto daily-driver surfaces. The combination of `interaction-audit` + `forbidden-phrases.txt` + `element-reuse-check` is the structural guard.

### Q-C3 — Brand voice reference

> "Whose voice does this product aspire to sound like? Name a specific reference — an app's empty-state voice / a character from a film / a specific company's product voice."

**Drives knob**: `BRAND_VOICE_REFERENCE` — the named "Partner voice" reference for `persona-testing`'s Partner test.

Examples: `"Apple Photos empty-state voice"` / `"Telegram product voice"` / `"Stripe docs voice"` / `"the partner-companion from Her"` / `"GitHub CLI voice"`.

### Q-C4 — Voice anti-references + forbidden phrases + usage frequency

> "What tones do you actively reject? Customer-service register ('I'm here to help'), apology, performance ('crushing it!'), tutorial-explainer? And — any phrases you'd NEVER want in user-facing copy?"

**Drives knobs**: `VOICE_ANTI_REFERENCES`, `BRAND_FORBIDDEN_PHRASES`, `USAGE_FREQUENCY_FRAMING` (inferred from how often a typical user opens the product — daily-driver / weekly-tool / transactional / power-user).

Backfill `BRAND_FORBIDDEN_PHRASES` with Phase I git-mining for revert-copy commits.

---

## Phase D — Surfaces + product context (4 Qs, ~8 knobs)

### Q-D1 — Multi-screen arcs

> "Does the project have multi-screen arcs — onboarding, checkout, setup wizard, multi-step task? Name them (entry → exit surfaces)."

**Drives knobs**: `MULTI_SCREEN_ARCS_EXIST` (boolean), `ARC_INVENTORY` (named arcs with entry/exit surfaces).

Gates whether `flow-audit`, `flow-continuity-review`, `iterative-polish-autoloop`, and the journey-mapping-mandatory discipline ship. If `MULTI_SCREEN_ARCS_EXIST = false`, downstream design simplifies meaningfully.

### Q-D2 — Multi-section primary surface

> "Does the project have a primary multi-section surface — 3+ tabs / panels / dashboard sections that should feel consistent? List the sections with routes + file paths."

**Drives knob**: `MULTI_SECTION_PRIMARY_SURFACE` (boolean + section inventory).

Gates whether `pages-audit` ships. Phase 1 scan can pre-populate from `(tabs)/`, `app/`, `routes/`.

### Q-D3 — Surface directory structure + translation file locations

> "Where do screens / routes / pages live in the codebase? Where do copy / translation / narration files live?"

**Drives knobs**: `SURFACE_DIR_STRUCTURE` (glob paths for journey-audit to enumerate), `TRANSLATION_FILE_LOCATIONS` (for `forbidden-phrases` hook + `persona-testing` skill).

**Phase 1 scan pre-populates this** — confirm in one sentence if scan found `app/wizard/**`, `lib/i18n/**`, `lib/*/translations/**` patterns. Otherwise ask.

### Q-D4 — Seed fixture mechanism

> "How does the app get into specific data states for testing/auditing? Seed scripts? Fixture accounts? Mock-mode env vars? URL params?"

**Drives knob**: `SEED_FIXTURE_MECHANISM` (commands + per-tier mapping if multi-tier seeds exist).

Used by `flow-audit`, `pages-audit`, `iterative-polish-autoloop`, `product-designer` (Step 3 data-shape probe).

---

## Phase E — Product posture (3 Qs, ~6 knobs)

### Q-E1 — User persona

> "Who's your user? Consumer (B2C), B2B SaaS user, developer / dev-tool user, enterprise admin, internal-only?"

**Drives knob**: `USER_PERSONA_TYPE`. Drives `quality-rubric`'s demo audience + `persona-testing`'s triad-override.

### Q-E2 — Production vs internal

> "Is the project production-user-facing, internal-only, or mixed?"

**Drives knob**: `PROD_VS_INTERNAL`. Internal-only projects skip `a11y-audit` and voice discipline; production-user-facing ships full kit.

### Q-E3 — Demo test audience + quality posture

> "Who would you demo a polished change to — be specific. Name the role or person. ('A friend's customer I'm recruiting as customer #2', 'a journalist writing about us', 'a CTO at a target enterprise', 'a designer whose taste I respect'.) And — is your quality posture defensive ('block if not S-tier') or offensive ('ship and iterate')?"

**Drives knobs**: `DEMO_TEST_AUDIENCE`, `QUALITY_BAR_REGISTER` (defensive / offensive / bar-by-surface), `QUALITY_GRADE_TARGETS_BY_SURFACE` (which surface categories target which grade).

---

## Phase F — Design system (2 Qs + Phase 1 scan, ~9 knobs)

### Q-F1 — Tokens path + theme convention

> "Where do your design tokens / theme values live? Walk me through how a color gets from token to render."

**Drives knobs**: `DESIGN_SYSTEM_TOKENS_PATH`, `DESIGN_SYSTEM_MATURITY` (`none` / `partial` / `mature`), `THEME_CONVENTION` (`semantic-token` / `palette` / `CSS-variable` / `Tailwind` / `Tailwind+NativeWind` / `SCSS` / `styled-components` / `Emotion` / `vanilla-extract` / `RN StyleSheet`), `THEME_GENERATION_COMMAND` (`yarn generate:theme` / `npx style-dictionary build` / `"none"`).

**Phase 1 scan heavily pre-populates** — confirm if scan found `tokens.ts` / `theme.*` / `tailwind.config.*` / `globals.css`.

### Q-F2 — Native chrome primitives + motion library + status colors

> "Which native chrome primitives do you already have, and where do they live? Tab bars / glass cards / bottom sheets / confirm dialogs? Plus: what's your animation library, and do you have canonical animation presets? And — what's your status color system (success / warning / error / pending)?"

**Drives knobs**: `NATIVE_CHROME_PRIMITIVES_LIST`, `CHROME_PRIMITIVE_PATHS` (map: primitive name → file path), `MOTION_LIBRARY` (Reanimated 4 / Framer Motion / CSS transitions / Web Animations API / native UIKit-Compose / `none`), `ANIMATION_PRESET_FILE_PATH`, `STATUS_COLOR_SYSTEM` (table: status × color × icon).

**Phase 1 scan pre-populates** — look for primitive files under `components/ui/`, `lib/widgets/primitives/`, `src/components/`.

---

## Phase G — Compliance + accessibility (1 Q, ~5 knobs)

### Q-G1 — A11y compliance target

> "What's your accessibility compliance target? WCAG 2.2 AA / AAA / Section 508 / App Store guidelines / 'none-explicit-but-care'?"

**Drives knobs**: `A11Y_COMPLIANCE_TARGET`, `REDUCED_MOTION_HOOK_PATH` (inferred from `MOTION_LIBRARY` — `useReducedMotion()` for Reanimated, `prefers-reduced-motion` for CSS, `UIAccessibility.isReduceMotionEnabled` for iOS native).

`HIT_TARGET_MINIMUM`, `DYNAMIC_TYPE_UPPER_BOUND_PERCENT`, `LABEL_API` were all platform-inferred from Q-A1.

Skip Phase G entirely if `PROD_VS_INTERNAL = internal-only` (a11y skipped).

---

## Phase H — Testing + docs infrastructure (Phase 1 scan + 1 Q, ~7 knobs)

### Phase 1 scan auto-populates

- `TEST_FRAMEWORK` (read `package.json`) — Jest / Vitest / pytest / cargo test / etc.
- `STORYBOOK_FRAMEWORK` (check for `.storybook/`) — `@storybook/react-vite` / `@storybook/react-webpack` / `none`.
- `STORYBOOK_TITLE_CONVENTION` + `STORYBOOK_REFERENCE_STORY_PATHS` (read existing stories).
- `EXISTING_CLAUDE_MD` / `EXISTING_STYLE_GUIDE` (check for files).

### Q-H1 — Audit doc / spec doc path conventions

> "Where do your audit reports / flow docs / spec docs land? E.g. `docs/audits/YYYY-MM-DD-<slug>-audit.md` / `docs/flows/<arc>.md` / `docs/brainstorms/YYYY-MM-DD-<topic>-design.md`?"

**Drives knobs**: `AUDIT_REPORT_PATH_CONVENTION`, `FLOW_DOC_PATH_CONVENTION`, `SPEC_DOC_PATH_CONVENTION`, `BRAINSTORM_DOC_PATH_CONVENTION`.

Often all under `docs/audits/` and `docs/brainstorms/` — propose sane defaults and confirm in one sentence.

---

## Phase I — Git mining (automated + 1 confirmation Q, ~5 knobs)

### Semi-automated mining (Claude runs, no question yet)

Before asking, mine the git log against six grep patterns:

```bash
# Copy-revert / tone-fix
git log --oneline --grep="copy" -20
git log --oneline --grep="tone" -10

# Polish / cleanup / fix-layout
git log --oneline -E --grep="polish|cleanup|fix.*layout|broken.*UX|revert.*copy" -20

# A11y / contrast / label / hit-target
git log --oneline -E --grep="a11y|accessibility|VoiceOver|contrast|aria" -20

# Overlay / dead-chrome / redundant
git log --oneline -E --grep="overlay|tap.*intercept|dead.*chrome|redundant|click.*nothing" -10

# Token / hex / color drift
git log --oneline -E --grep="token|hex|color" -10

# Arc / dead-end / wrong-screen
git log --oneline -E --grep="arc|dead.?end|wrong.*screen|missing.*bridge" -10
```

Identify the top 8-12 commit subjects. Tag each by candidate category.

### Q-I1 — Git-mined commit confirmation

> "I mined N candidate commits as anti-pattern examples — here are the top 8-12 with subject lines. Tell me which 3-5 are most representative for each category (dead-chrome / a11y / token-drift / arc-bug / copy-revert / general-polish)? For the ones you confirm — what was the user-visible symptom?"

**Drives knobs**: `PAST_BUGS_BY_SHA`, `PAST_DEAD_CHROME_SHAS`, `PAST_A11Y_BUG_SHAS`, `PAST_TOKEN_DRIFT_SHAS`, `PAST_ARC_BUG_SHAS`.

**By SHA, by subject line.** This signals "I read your code" and gets a richer story than abstract "any UX bugs?" — concreteness primes concreteness. Each confirmed story becomes a project-specific anti-pattern in the relevant authored agent. Goal: 3-5 anti-patterns per agent that gets them.

### Q-I2 (off-the-record bugs follow-up — optional)

> "Any UX bugs that DIDN'T make it into git but still bother you? 'I keep meaning to fix that' / 'it's not technically broken but it's bad' / 'we know about it'."

These are often the highest-value answers — bugs that bothered the user but never reached the threshold for a fix-commit. They're exactly what the audit agents should surface periodically.

---

## Phase J — Strategy + vision (2 optional Qs, ~3 knobs)

Skip if the project is early-stage / single-feature / has no vision-docs concept.

### Q-J1 — Vision docs + capability map + strategy lens

> "Do you have a vision doc / capability map / strategy lens? Paths? E.g. `docs/vision.md` / `docs/product/capabilities.md` / `.claude/rules/prototype-gates.md`?"

**Drives knobs**: `PRODUCT_VISION_DOCS`, `CAPABILITY_MAP_PATH`, `PROTOTYPE_GATES_PATH`.

These gate whether `product-direction-validator` and the capability-delta requirement in `product-designer`'s spec template ship.

### Q-J2 — Architecture layer priority

> "What's your architectural layer priority — when features compete for time, which layer wins? E.g. 'engine > MCP > vertical-UI > polish' or 'platform > shared services > feature teams > experiments'."

**Drives knob**: `ARCHITECTURE_LAYER_PRIORITY`. Gates `product-direction-validator`.

Skip if simple project (single-axis architecture).

---

## Phase K — Model selection (1 Q, ~2 knobs)

### Q-K1 — Default model tiers

> "Default model tier for high-effort audit agents? (Top-of-the-line opus is the default; some shops have token-budget policies that pin to sonnet.) And the lightweight tier for mechanical sweeps?"

**Drives knobs**: `MODEL_TIER_DEFAULT` (default: `claude-opus-4-7`), `MODEL_TIER_LIGHTWEIGHT` (default: `claude-haiku-4-5` for `design-token-audit`).

---

## Interview structure summary

| Phase | Topic | Questions | Knobs captured | Phase-1-scan helps |
|---|---|---|---|---|
| A | Platform + dev-loop | 2 | 5 | Yes (heavy) |
| B | Benchmarks | 3 | 6 | No |
| C | Voice + persona | 4 | 7 | Partial (Phase I mining) |
| D | Surfaces + product context | 4 | 8 | Yes (file path discovery) |
| E | Product posture | 3 | 6 | No |
| F | Design system | 2 | 9 | Yes (heavy) |
| G | A11y compliance | 1 | 5 | Partial (platform-inferred) |
| H | Docs paths | 1 | 7 | Yes (heavy) |
| I | Git mining | 1 (confirm) + 1 (off-record) | 5 | Yes (mining-automated) |
| J | Strategy + vision | 2 (optional) | 3 | Partial |
| K | Model tier | 1 | 2 | No (policy-driven) |
| **Total** | | **18 questions** | **53 knobs** | |

### Batched super-questions for actual interview UX

The 18 sub-questions can be grouped into ~5-6 super-questions per turn:

1. **Super-Q1** (Phases A + E): *"What does this project ship on, who are the users, and how do you currently capture + test rendered output?"*
2. **Super-Q2** (Phase B + part of E): *"Name your benchmarks — Tier 1 chrome, Tier 2 with dimension, anti-references — and the demo audience."*
3. **Super-Q3** (Phase C): *"Does the product have a voice? If yes — character / reference / anti-references / forbidden phrases."*
4. **Super-Q4** (Phases D + F + H): *"Tell me about your design system + surface structure — tokens path, primitives, screen dirs, copy file locations, seed mechanism, doc-path conventions."*
5. **Super-Q5** (Phases G + J + K): *"Compliance bar + vision/strategy lens (optional) + model tier."*
6. **Super-Q6** (Phase I, automated then confirmed): *"Here are commit SHAs I mined as anti-pattern candidates — mark the 3-5 most representative."*

5-6 super-questions × ~3 minutes each = ~15-20 min interview = battle-tested baseline.

---

## Summary turn (mandatory before authoring)

Before invoking Phase 4 of `SKILL.md`, summarize back what you captured + what you'll author. Wait for explicit "go."

> "Based on our chat:
>
> **Platform**: <iOS / web / etc.>
> **Capture path**: <command>
> **Tier 1 chrome**: <2-3 apps>
> **Tier 2 domain**: <2-3 apps + dimensions>
> **Anti-references**: <list>
> **Voice**: <characterization or 'functional-only'>
> **In-product character**: <yes — name + intro file / no>
> **Multi-screen arcs**: <list or 'no'>
> **Multi-section primary surface**: <list or 'no'>
> **Design system maturity**: <none / partial / mature>
> **Tokens path**: <file>
> **Native primitives**: <list>
> **Compliance target**: <WCAG AA / AAA / Section 508 / App Store / none>
> **Demo audience**: <specific role/person>
> **Vision docs / capability map**: <list or 'none'>
> **War-story anti-patterns to bake in** (Phase I mining): <N items, briefly>
>
> About to author the kit:
> - **Agents**: <list — ux-reviewer, a11y-audit, interaction-audit, design-token-auditor, [flow-auditor], [pages-audit], [product-designer], [flow-ux-reviewer], [product-compass]>
> - **Skills**: <list — journey-audit, element-reuse-check, persona-lens, quality-bar, design-system, [iterative-polish-autoloop]>
> - **Rules**: <list — design-north-star, audit-routing, visual-verification, [forbidden-phrases]>
> - **Hooks**: <list — check-design-tokens, [check-forbidden-phrases], [check-no-legacy-blur], [check-platform-icons]>
>
> Confirm to proceed?"

Wait for confirmation, then proceed to Phase 4 of `SKILL.md`.

---

## How to use this script

- **One or two questions per turn**, conversational. The super-question batching above is fine for actual UX.
- **Skip ruthlessly.** If Phase 1's scan already answered, confirm in one sentence rather than asking. Phase 1 reliably handles ~25 of the 53 knobs.
- **Listen for off-script signal.** A user-volunteered "our settings page got out of hand" is more valuable than 5 in-script questions answered tersely. Follow it.
- **Push gently on B1/B2/B3** — these are the most load-bearing answers. Without named benchmarks, the kit has no anchors.
- **Mine git in Phase I no matter what.** Even if the user has prepared their war stories, the SHA + subject-line specificity makes the conversation 2-3× more concrete.
- **End when you have enough.** Don't grind through low-leverage Phases G/J/K if A-F + I already gave you a rich picture; default sensibly and confirm in the summary.
- **The 53-knob configuration is the calibration target** — when you summarize before authoring, the user should recognize THEIR project, not a templatized version of it.
