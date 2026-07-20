# `/dotclaude:design` interview

19 questions across 7 phases (A–G), capturing the **47 configuration knobs that feed the two written artifacts** — `.claude/rules/design-north-star.md` and `.claude/rules/design-system.md`. This is a reduced subset of the original 53-knob design-stack analysis: the knobs that only existed to tune a per-project agent copy's internals (depth, tool surface, model tier, doc-path conventions, "which agents to author") are gone now that the 7 design audits ship with the plugin and are consumed as-is at runtime. Adaptive: skip ruthlessly when Phase 1 (project scan) already answered. The interview's job is to surface the **design DNA Claude Code cannot read from code** — named benchmarks, voice character, war-story bugs, surface inventories, native primitives, and capture commands — so the two artifacts grade against *real anchors* instead of vibes.

**Pacing rule**: 1–2 questions per turn, conversational. Never fire-hose all the questions at once. Listen for off-script signal ("our settings page got out of hand") — that's gold for `design-north-star.md`'s anti-patterns section.

**Skip discipline**: if a question's answer is obvious from Phase 1's scan, do NOT ask — confirm in one sentence and move on. The cost of asking a redundant question is real (it signals "you weren't paying attention to my code"). Phase 1 reliably auto-discovers ~20 of the 47 knobs; the interview drives the remaining ~27.

**Batching guidance**: questions can be batched into ~5 super-questions per turn for actual interview UX. The numbered Q-A1 / Q-B2 / etc. are the underlying knob drivers; the turns can group several.

---

## Phase A — Platform + dev-loop (2 Qs, 11 knobs)

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

## Phase B — Benchmarks (3 Qs, 4 knobs) — THE most important section

Without named benchmarks, `design-north-star.md`'s grading rubric collapses to "looks good," which is unenforceable by any of the 7 consumed audits. **Do not skip this phase.** If the user resists, push once — *"Even one app you respect helps. Without an anchor, the audit has no rubric."*

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

Anti-references are equally important — they tell the consumed audits what to **reject**. Without B3, the rubric only knows what to chase, not what to avoid.

---

## Phase C — Voice + persona (4 Qs, 6 knobs)

Skip entirely if Q-E2 said "internal-only" OR product has no user-facing copy beyond labels.

### Q-C1 — Brand voice + product-has-voice gate

> "Does the product have an authored voice the team enforces, or is copy purely functional? Three quick checks: (1) Is there a brand voice doc / style guide? (2) Pick 3 adjectives. (3) Show me one phrasing from a real surface that nails the voice."

**Drives knobs**: `PRODUCT_HAS_VOICE` (boolean, gates all of Phase C remainder), the adjective triad for downstream calibration.

The third part — the real example — is highest-signal. Adjectives are too vague; a real phrase from a real surface anchors voice for every authored copy artifact.

If `PRODUCT_HAS_VOICE = false`, **skip C2 / C3 / C4** and move to Phase D.

### Q-C2 — In-product assistant character

> "Does the product have a named in-product assistant character (an AI helper, a mascot, a personality the product wears)? If yes — name + where does it introduce itself (file path)?"

**Drives knob**: `IN_PRODUCT_ASSISTANT_CHARACTER` (boolean + name + intro-surface-path).

If **yes**, flag the **daily-driver-vs-first-touch trap** — a class of bug where the assistant's onboarding voice ("Hi — I'm <name>, let me show you around!") leaks onto daily-driver surfaces. This becomes one of `design-north-star.md`'s anti-patterns; the consumed `interaction-audit` and `persona-testing` read the project's phrase deny-list and the north-star's voice section as the structural guard at runtime.

### Q-C3 — Brand voice reference

> "Whose voice does this product aspire to sound like? Name a specific reference — an app's empty-state voice / a character from a film / a specific company's product voice."

**Drives knob**: `BRAND_VOICE_REFERENCE` — the named "Partner voice" reference `design-north-star.md` states so the consumed `persona-testing` skill's Partner test can derive from it at runtime.

Examples: `"Apple Photos empty-state voice"` / `"Telegram product voice"` / `"Stripe docs voice"` / `"the partner-companion from Her"` / `"GitHub CLI voice"`.

### Q-C4 — Voice anti-references + banned phrases + usage frequency

> "What tones do you actively reject? Customer-service register ('I'm here to help'), apology, performance ('crushing it!'), tutorial-explainer? And — any phrases you'd NEVER want in user-facing copy?"

**Drives knobs**: `VOICE_ANTI_REFERENCES`, `BRAND_BANNED_PHRASES`, `USAGE_FREQUENCY_FRAMING` (inferred from how often a typical user opens the product — daily-driver / weekly-tool / transactional / power-user).

Backfill `BRAND_BANNED_PHRASES` with Phase G git-mining for revert-copy commits.

---

## Phase D — Surfaces + product context (3 Qs, 5 knobs)

### Q-D1 — Multi-screen arcs

> "Does the project have multi-screen arcs — onboarding, checkout, setup wizard, multi-step task? Name them (entry → exit surfaces)."

**Drives knobs**: `MULTI_SCREEN_ARCS_EXIST` (boolean), `ARC_INVENTORY` (named arcs with entry/exit surfaces).

Determines whether `design-north-star.md`'s per-surface chrome reference table needs arc rows, and whether Phase 3 of `SKILL.md` reads `flow-audit.md` / `iterative-polish-autoloop.md` / `journey-mapping.md` before authoring. If `MULTI_SCREEN_ARCS_EXIST = false`, the north-star simplifies meaningfully — no arc rows needed.

### Q-D2 — Multi-section primary surface

> "Does the project have a primary multi-section surface — 3+ tabs / panels / dashboard sections that should feel consistent? List the sections with routes + file paths."

**Drives knob**: `MULTI_SECTION_PRIMARY_SURFACE` (boolean + section inventory).

Determines whether `design-north-star.md`'s per-surface chrome table needs a section-consistency row set, and whether Phase 3 reads `pages-audit.md`. Phase 1 scan can pre-populate from `(tabs)/`, `app/`, `routes/`.

### Q-D3 — Surface directory structure + translation file locations

> "Where do screens / routes / pages live in the codebase? Where do copy / translation / narration files live?"

**Drives knobs**: `SURFACE_DIR_STRUCTURE` (glob paths the consumed `journey-mapping` skill enumerates at runtime), `TRANSLATION_FILE_LOCATIONS` (for the consumed `persona-testing` skill's deny-list check).

**Phase 1 scan pre-populates this** — confirm in one sentence if scan found `app/wizard/**`, `lib/i18n/**`, `lib/*/translations/**` patterns. Otherwise ask.

---

## Phase E — Product posture (3 Qs, 6 knobs)

### Q-E1 — User persona

> "Who's your user? Consumer (B2C), B2B SaaS user, developer / dev-tool user, enterprise admin, internal-only?"

**Drives knob**: `USER_PERSONA_TYPE`. States the audience `design-north-star.md` names for the demo test and for the consumed `persona-testing` skill's triad-derivation at runtime.

### Q-E2 — Production vs internal

> "Is the project production-user-facing, internal-only, or mixed?"

**Drives knob**: `PROD_VS_INTERNAL`. Internal-only projects skip Phase C (voice) and keep `design-north-star.md`'s voice section terse; production-user-facing needs the full voice + banned-phrases treatment.

### Q-E3 — Demo test audience + quality posture

> "Who would you demo a polished change to — be specific. Name the role or person. ('A friend's customer I'm recruiting as customer #2', 'a journalist writing about us', 'a CTO at a target enterprise', 'a designer whose taste I respect'.) And — is your quality posture defensive ('block if not S-tier') or offensive ('ship and iterate')? Plus: what accessibility compliance bar does this project target — WCAG 2.2 AA (the default if you're not sure), AAA, Section 508, or none/internal-only?"

**Drives knobs**: `DEMO_TEST_AUDIENCE`, `QUALITY_BAR_REGISTER` (defensive / offensive / bar-by-surface), `QUALITY_GRADE_TARGETS_BY_SURFACE` (which surface categories target which grade), `A11Y_COMPLIANCE_TARGET` (WCAG 2.2 AA / AAA / Section 508 / none-internal).

`DEMO_TEST_AUDIENCE` becomes `design-north-star.md`'s demo-test line verbatim. `QUALITY_GRADE_TARGETS_BY_SURFACE` feeds `design-system.md`'s quality-tier table. `A11Y_COMPLIANCE_TARGET` lands in `design-north-star.md` too — the consumed `a11y-audit` agent reads it at runtime to set its contrast/scaling thresholds, defaulting to WCAG 2.2 AA only when the doc states nothing.

---

## Phase F — Design system (2 Qs + Phase 1 scan, 10 knobs)

### Q-F1 — Tokens path + theme convention

> "Where do your design tokens / theme values live? Walk me through how a color gets from token to render."

**Drives knobs**: `DESIGN_SYSTEM_TOKENS_PATH`, `DESIGN_SYSTEM_MATURITY` (`none` / `partial` / `mature`), `THEME_CONVENTION` (`semantic-token` / `palette` / `CSS-variable` / `Tailwind` / `Tailwind+NativeWind` / `SCSS` / `styled-components` / `Emotion` / `vanilla-extract` / `RN StyleSheet`), `THEME_GENERATION_COMMAND` (`yarn generate:theme` / `npx style-dictionary build` / `"none"`).

**Phase 1 scan heavily pre-populates** — confirm if scan found `tokens.ts` / `theme.*` / `tailwind.config.*` / `globals.css`.

### Q-F2 — Native chrome primitives + motion library + status colors

> "Which native chrome primitives do you already have, and where do they live? Tab bars / glass cards / bottom sheets / confirm dialogs? Plus: what's your animation library, do you have canonical animation presets, and does it expose a reduced-motion hook? And — what's your status color system (success / warning / error / pending)?"

**Drives knobs**: `NATIVE_CHROME_PRIMITIVES_LIST`, `CHROME_PRIMITIVE_PATHS` (map: primitive name → file path), `MOTION_LIBRARY` (Reanimated 4 / Framer Motion / CSS transitions / Web Animations API / native UIKit-Compose / `none`), `ANIMATION_PRESET_FILE_PATH`, `REDUCED_MOTION_HOOK_PATH` (`useReducedMotion()` for Reanimated, `prefers-reduced-motion` for CSS, `UIAccessibility.isReduceMotionEnabled` for iOS native), `STATUS_COLOR_SYSTEM` (table: status × color × icon).

These are exactly the six knobs `design-system.md`'s "native chrome primitives" and "motion principles" sections need — the reduced-motion hook is project-specific integration, not a platform constant, so it belongs here rather than being inferred.

**Phase 1 scan pre-populates** — look for primitive files under `components/ui/`, `lib/widgets/primitives/`, `src/components/`.

---

## Phase G — Git mining (automated + 1 confirmation Q + 1 optional Q, 5 knobs)

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

### Q-G1 — Git-mined commit confirmation

> "I mined N candidate commits as anti-pattern examples — here are the top 8-12 with subject lines. Tell me which 3-5 are most representative for each category (dead-chrome / a11y / token-drift / arc-bug / copy-revert / general-polish)? For the ones you confirm — what was the user-visible symptom?"

**Drives knobs**: `PAST_BUGS_BY_SHA`, `PAST_DEAD_CHROME_SHAS`, `PAST_A11Y_BUG_SHAS`, `PAST_TOKEN_DRIFT_SHAS`, `PAST_ARC_BUG_SHAS`.

**By SHA, by subject line.** This signals "I read your code" and gets a richer story than abstract "any UX bugs?" — concreteness primes concreteness. Each confirmed story becomes one of `design-north-star.md`'s 3-5 project-specific anti-pattern entries. Goal: 3-5 anti-patterns total, each citing a real SHA.

### Q-G2 — Off-the-record bugs follow-up (optional)

> "Any UX bugs that DIDN'T make it into git but still bother you? 'I keep meaning to fix that' / 'it's not technically broken but it's bad' / 'we know about it'."

These are often the highest-value answers — bugs that bothered the user but never reached the threshold for a fix-commit. They're exactly what the consumed audit agents should surface periodically, and they fold into the same `PAST_BUGS_BY_SHA`-adjacent anti-pattern slot in `design-north-star.md` (cited by symptom rather than SHA when there's no commit).

---

## Interview structure summary

| Phase | Topic | Questions | Knobs captured | Phase-1-scan helps |
|---|---|---|---|---|
| A | Platform + dev-loop | 2 | 11 | Yes (heavy) |
| B | Benchmarks | 3 | 4 | No |
| C | Voice + persona | 4 | 6 | Partial (Phase G mining) |
| D | Surfaces + product context | 3 | 5 | Yes (file path discovery) |
| E | Product posture | 3 | 6 | No |
| F | Design system | 2 | 10 | Yes (heavy) |
| G | Git mining | 1 (confirm) + 1 (off-record) | 5 | Yes (mining-automated) |
| **Total** | | **19 questions** | **47 knobs** | |

### Batched super-questions for actual interview UX

The 19 sub-questions can be grouped into ~5 super-questions per turn:

1. **Super-Q1** (Phases A + E): *"What does this project ship on, who are the users, and how do you currently capture + test rendered output?"*
2. **Super-Q2** (Phase B + part of E): *"Name your benchmarks — Tier 1 chrome, Tier 2 with dimension, anti-references — and the demo audience."*
3. **Super-Q3** (Phase C): *"Does the product have a voice? If yes — character / reference / anti-references / banned phrases."*
4. **Super-Q4** (Phases D + F): *"Tell me about your design system + surface structure — tokens path, primitives, motion library + reduced-motion hook, status colors, screen dirs, copy file locations."*
5. **Super-Q5** (Phase G, automated then confirmed): *"Here are commit SHAs I mined as anti-pattern candidates — mark the 3-5 most representative."*

5 super-questions × ~3 minutes each = ~15 min interview.

---

## Summary turn (mandatory before authoring)

Before invoking Phase 4 of `SKILL.md`, summarize back what you captured + what you'll write. Wait for explicit "go."

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
> **Motion library + reduced-motion hook**: <library + hook path or 'none'>
> **Demo audience**: <specific role/person>
> **War-story anti-patterns to bake in** (Phase G mining): <N items, briefly>
>
> About to write the two artifacts:
> - **`.claude/rules/design-north-star.md`** — Tier 1/2 benchmarks + anti-references, per-surface chrome table, voice/banned-phrases, N git-mined anti-patterns, demo test, claim-of-done checklist
> - **`.claude/rules/design-system.md`** — the eleven-section design-system digest (tokens, primitives, motion, status colors, quality tiers, library gotchas)
> - **Hooks**: <list — check-design-tokens, [check-no-legacy-blur], [check-platform-icons]>
>
> The 7 design audits (`ux-audit`, `a11y-audit`, `interaction-audit`, `flow-audit`, `pages-audit`, `product-designer`, `design-token-audit`) ship with the plugin and read these two artifacts directly at runtime — no per-project agent copy is authored.
>
> Confirm to proceed?"

Wait for confirmation, then proceed to Phase 4 of `SKILL.md`.

---

## How to use this script

- **One or two questions per turn**, conversational. The super-question batching above is fine for actual UX.
- **Skip ruthlessly.** If Phase 1's scan already answered, confirm in one sentence rather than asking. Phase 1 reliably handles ~20 of the 47 knobs.
- **Listen for off-script signal.** A user-volunteered "our settings page got out of hand" is more valuable than 5 in-script questions answered tersely. Follow it.
- **Push gently on B1/B2/B3** — these are the most load-bearing answers. Without named benchmarks, `design-north-star.md` has no anchors.
- **Mine git in Phase G no matter what.** Even if the user has prepared their war stories, the SHA + subject-line specificity makes the conversation 2-3× more concrete.
- **End when you have enough.** Don't grind through low-leverage sub-questions if A-F + G already gave you a rich picture; default sensibly and confirm in the summary.
- **The 47-knob configuration is the calibration target** — when you summarize before authoring, the user should recognize THEIR project, not a templatized version of it.
