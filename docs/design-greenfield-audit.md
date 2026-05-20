# Design stack — greenfield audit

**Date:** 2026-05-20
**Scope:** every non-generic element across all 26 design-related artifacts mapped to a configuration mechanism that works for a brand-new project with ZERO existing data.
**Extends (does not replace):** `docs/design-stack-analysis.md` (1186 LOC) + `skills/design/interview.md` (376 LOC).
**Greenfield reframe:** previous analysis assumed Phase 1 project scan would auto-populate ~25 of 53 knobs. For a greenfield project, that scan returns nothing — no tokens file, no CLAUDE.md, no git history, no design system, no test fixtures. Every "Phase 1 will find this" assumption is restated as "interview must capture this, OR ship a defensible default the user confirms, OR scaffold the missing concept itself."

---

## 0. Executive summary

**Biggest finding.** The source stack assumes ~10 conceptual scaffolds that don't exist in greenfield projects — capability map, brainstorm doc convention, audit doc convention, flow doc convention, fixture-tier seed pipeline, "the X primitives wrapped by `<NavTabs>` / `<GlassCard>`," `app-state-navigation` recipe catalog, named anti-patterns from git history, the "5 owner tabs" multi-section structure, and the named in-product assistant character with its single-exempt-surface contract. These aren't knobs in the traditional sense — they're *concepts the project must learn how to host*. The plugin must SCAFFOLD them (offer to create templates + add CLAUDE.md sections), not just configure them. 13 distinct **Category C (knowledge-graph)** scaffolding decisions surface from this audit.

**Biggest gap.** The current `skills/design/interview.md` runs 18 questions to capture 53 knobs in ~15-20 min, with a heavy assumption that "Phase 1 scan reliably handles ~25 of the 53 knobs." Greenfield projects flip that ratio — Phase 1 scan handles 0-3 knobs (just `package.json` if it exists). The remaining ~80 knobs (counting greenfield-only additions) must come from the interview OR from defensible defaults. The interview also has no mode-branch — it assumes existing surfaces, tokens files, git log, translation file locations. Without a greenfield mode, the kit either fires meaningless questions ("which 3-5 commits do you confirm as anti-patterns?" — on an empty repo) or ships principle text referencing infrastructure that doesn't exist.

**Recommended next step.** **Option 2 (Greenfield interview + setup flows)** — rewrite `skills/design/interview.md` with a Phase 0 mode-declaration branching greenfield vs brownfield, expand to a 13-phase ~25-min interview covering 78 knobs, and ship 11 mini-scaffolding skills for Category C knowledge-graph concepts. Estimated 8-12 hours of focused work. Risk: medium — every existing principle's "authoring instructions" section needs auditing for greenfield-compatibility, and 5-6 principles will need explicit "skip-when-greenfield-defaults-apply" sections. Option 3 (full execution + demo regeneration + all 29 principles updated) adds another 6-10 hours and is appropriate if the user wants the kit production-ready for first external user immediately.

---

## 1. Per-artifact non-generic element extraction

Each sub-section: 5-column table. Categories — **A** = project-specific VALUE (slot is universal; value varies); **B** = project-specific STRUCTURE (the shape itself varies between projects); **C** = KNOWLEDGE-GRAPH scaffolding (concept that doesn't exist yet in greenfield).

### 1.1 — `agents/ux-reviewer.md` (24 non-generic elements)

| # | Element | Verbatim text / pattern | Cat | Knob name | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Product framing | "auditing ProductName — a React Native fitness app" | A | `PROJECT_DESCRIPTOR` | Ask in interview Q-D5 |
| 2 | Tier 1 chrome reference | "Apple iOS 26 + Telegram on iOS 26" | A | `TIER_1_BENCHMARKS` | Ask in interview Q-B1 (default by platform) |
| 3 | Tier 2 domain references | "WHOOP/Strava/Oura/Linear/Superhuman" | A | `TIER_2_BENCHMARKS_WITH_DIMENSION` | Ask in interview Q-B2 (per-surface-category) |
| 4 | Primary platform | "iOS simulator OR the user's physical iPhone" | A | `PRIMARY_SURFACE_PLATFORM` | Ask in interview Q-A1 |
| 5 | Hot-reload framing | "The app is already running. Never launch the dev server." | A | `DEV_SERVER_ALREADY_RUNNING` | Default: true (almost universal); confirm Q-A2 |
| 6 | Device detection cmd | "`ps aux \| grep "expo run"`" | A | `DEVICE_TARGET_DETECT_COMMAND` | Default by platform; confirm Q-A2 |
| 7 | Sim screenshot cmd | "`xcrun simctl io <udid> screenshot /tmp/x.png`" | A | `CAPTURE_COMMAND_PRIMARY` | Default by platform; confirm Q-A2 |
| 8 | Physical device cmd | "`bash scripts/iphone-screenshot.sh /tmp/iphone-now.png`" | A | `CAPTURE_COMMAND_PHYSICAL_DEVICE` | Default: "N/A" greenfield; opt-in Q-A2b |
| 9 | Hierarchy cmd | "`maestro --device <udid> hierarchy --compact \| grep -A 2 "<id>"`" | A | `HIERARCHY_INSPECTION_COMMAND` | Default by platform; confirm Q-A2 |
| 10 | Maestro MCP tool inventory | "mcp__maestro__take_screenshot, mcp__maestro__tap_on, …" | B | `INTERACTION_TOOL_INVENTORY` | Default by platform's automation tool; ask Q-A3 |
| 11 | iPhone scripts dir | "`bash scripts/iphone-screenshot.sh` / `iphone-tap.sh` / `iphone-type.sh` / `iphone-list-items.sh` / `start-tunneld.sh` / `start-wda.sh`" | C | `PHYSICAL_DEVICE_SCRIPTS_DIR` | Scaffold via `/dotclaude:setup-physical-device-scripts` (opt-in) |
| 12 | Tier 2 per-dimension table | "WHOOP onboarding — rhythm; Strava — bold typography; Oura — progressive disclosure; Linear — text hierarchy; Superhuman/Raycast — speed" | A | `TIER_2_BENCHMARKS_WITH_DIMENSION` | Ask Q-B2 |
| 13 | Bridge reference apps | "Apple iCloud onboarding, Telegram phone-number flow" | A | `BRIDGE_REFERENCE_APPS` | Ask Q-B2b |
| 14 | Anti-RN-app framing | "Anything in our UI that reads as 'another React Native app' instead of 'iOS-native'" | A | `ANTI_FRAMING_STATEMENT` | Derive from `PRIMARY_SURFACE_PLATFORM` + `ANTI_REFERENCES` |
| 15 | Seed command tiers | "`yarn e2e:seed:layer1 / layer2 / layer3`" | A | `SEED_FIXTURE_MECHANISM` | Ask Q-D4 (default: "none" for greenfield) |
| 16 | App-state-navigation skill | "use the `app-state-navigation` skill recipe catalog, don't reinvent" | C | `APP_STATE_NAVIGATION_SKILL_EXISTS` | Scaffold via `/dotclaude:setup-app-state-navigation` (opt-in; empty recipe catalog stub) |
| 17 | Specific tab-bar primitive | "NavTabs" | A | `NATIVE_TAB_BAR_PRIMITIVE_NAME` | Default by platform; confirm Q-F2 |
| 18 | Grading scale labels | "S / A / B / C / D / F" | A | `GRADING_SCALE` | Default: S/A/B/C/D/F (universal); override Q-E3 |
| 19 | Target-grade declaration | "Target: A or above on every screen" | A | `QUALITY_GRADE_TARGETS_BY_SURFACE` | Ask Q-E3 |
| 20 | NativeWind reference | "every issue has a specific NativeWind class or code change" | A | `STYLING_SYSTEM_IN_USE` | Default by Phase 1 scan / Q-F1 |
| 21 | Persona-lens auto-load | "`skills: [design-system, quality-bar, app-state-navigation, journey-audit, persona-lens]`" | B | `AGENT_SKILL_FRONTMATTER` | Derive from `PRODUCT_HAS_VOICE` + scaffolding decisions |
| 22 | Model tier | "`model: claude-opus-4-7` / `effort: high`" | A | `MODEL_TIER_DEFAULT` | Ask Q-K1; default opus-4-7 |
| 23 | Surface-class examples | "owner-facing or member-facing screen" | A | `USER_FACING_AUDIENCE_NAMES` | Ask Q-D5 |
| 24 | Demo-pricing test | "Would you pay $200/year for this based on design alone?" | A | `DEMO_TEST_PRICING_FRAMING` | Default: per-product (derive from `PRODUCT_TYPE`); override Q-E3 |

### 1.2 — `agents/interaction-audit.md` (16 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Product framing | "doing heuristic evaluation of ProductName screens" | A | `PROJECT_DESCRIPTOR` | reuse |
| 2 | Past dead-chrome example | "Continue button on a vertical-pick step where card-tap already advances synchronously" | A | `PAST_DEAD_CHROME_EXAMPLES` | Skip entirely greenfield; backfill after first audit cycle |
| 3 | Past redundant-affordance example | "a card with chevron AND a separate Continue button both pushing to the same next route" | A | `PAST_REDUNDANT_AFFORDANCE_EXAMPLES` | Skip greenfield |
| 4 | Past optical-disconnect example | "name-suggestion chips placed BELOW the gym-type chip group on the name screen" | A | `PAST_OPTICAL_DISCONNECT_EXAMPLES` | Skip greenfield |
| 5 | Interactive element types | "every Pressable, Button, Tab, Link, Card-with-onPress" | A | `INTERACTIVE_ELEMENT_TYPES` | Default by platform/framework |
| 6 | testID convention | "`grep -rn 'testID=\"<id>\"' app/ lib/`" | A | `TESTID_CONVENTION` | Default by platform (testID iOS/RN, data-testid web); confirm Q-A4 |
| 7 | Handler tracing pattern | "Read the onPress / handler function. Trace 1-2 hops if needed." | A | `HANDLER_TRACING_PATTERN` | Default by framework (onPress→router.push in RN; onClick→handler+formAction in Next; etc.) |
| 8 | Reference apps for chrome integrity | "Apple Settings / Telegram-iOS / Apple Health onboarding" | A | `INTERACTION_INTEGRITY_REFERENCES` | Subset of `TIER_1_BENCHMARKS` |
| 9 | Audit doc path | "`docs/audits/<YYYY-MM-DD>-<scope>-interaction-audit.md`" | A | `AUDIT_REPORT_PATH_CONVENTION` | Ask Q-H1; scaffold convention |
| 10 | Companion ordering | "1. design-token-auditor → 2. interaction-audit → 3. ux-reviewer" | B | `CANONICAL_PIPELINE_ORDER` | Default universal; confirm during summary |
| 11 | Severity tags | "CRIT / MAJ / LOW" | A | `SEVERITY_TAXONOMY` | Default: CRIT/MAJ/LOW; override Q-E3 |
| 12 | Audit ID prefix | "IA-001 / IA-002" | A | `AUDIT_ID_PREFIX_PER_AGENT` | Default by agent name |
| 13 | "Companion to ux-reviewer" framing | "dispatched as part of a UI-batch validation" | B | `UI_BATCH_VALIDATION_PATTERN` | Universal |
| 14 | Per-element grade column shape | "Match? ✓ / ✗ / ⚠ + Competing? column" | B | `AFFORDANCE_TABLE_SCHEMA` | Universal; document in principle |
| 15 | 7-pattern detection list | "Dead chrome / Redundant affordance / Optical-group disconnect / Action-singularity / Affordance-promise mismatch / Selection-vs-commit ambiguity / Hidden primary action" | B | `INTERACTION_PATTERN_TAXONOMY` | Universal (default); audit if project context requires override |
| 16 | "Apple HIG single-screen-job test" reference | "Apple's HIG single-screen-job test passes" | A | `INTERACTION_PRINCIPLE_REFERENCE` | Default: Apple HIG (iOS); platform-specific equivalent for others (Material guidelines for Android; etc.) |

### 1.3 — `agents/a11y-audit.md` (18 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Product framing | "ProductName owner & member screens" | A | `PROJECT_DESCRIPTOR` | reuse |
| 2 | Compliance target | "iOS-26 + WCAG 2.2 AA bar" | A | `A11Y_COMPLIANCE_TARGET` | Ask Q-G1 |
| 3 | Label API | "`accessibilityLabel`" | A | `LABEL_API` | Inferred from `PRIMARY_SURFACE_PLATFORM` |
| 4 | Hit-target minimum | "Apple HIG: 44×44 pt minimum" | A | `HIT_TARGET_MINIMUM_PT` | Inferred from platform |
| 5 | Dynamic-type upper bound | "iOS Dynamic Type goes up to 310%" | A | `DYNAMIC_TYPE_UPPER_BOUND_PERCENT` | Inferred from platform (310 iOS / 200 Android / web user-set) |
| 6 | Reduced-motion API | "`useReducedMotion()` from `react-native-reanimated`" | A | `REDUCED_MOTION_HOOK_PATH` | Inferred from `MOTION_LIBRARY` |
| 7 | Token file path for contrast | "`lib/theme/tokens.ts`" | A | `DESIGN_SYSTEM_TOKENS_PATH` | Ask Q-F1; scaffold if missing |
| 8 | Light + dark mode framing | "Look up the actual hex from `lib/theme/tokens.ts` (light + dark mode)" | A | `LIGHT_AND_DARK_MODE_BOTH` | Default: true; ask Q-F1c |
| 9 | Specific failure mode (text-muted) | "`text-muted-foreground` on `bg-muted` — common drift, often < 4.5:1 in dark mode" | A | `PAST_A11Y_FAILURE_PATTERNS` | Skip greenfield |
| 10 | Specific failure mode (tinted glass) | "Tinted glass over photographic content" | A | `PLATFORM_SPECIFIC_CONTRAST_HAZARDS` | Default by platform |
| 11 | hitSlop API | "`hitSlop={{top: 10, bottom: 10, left: 10, right: 10}}`" | A | `HIT_SLOP_API_SYNTAX` | Default by framework |
| 12 | Dynamic Type test path | "Settings → Accessibility → Display & Text Size → Larger Text" | A | `DYNAMIC_TYPE_TEST_INSTRUCTIONS` | Default by platform |
| 13 | Native tab bar handling text scale | "Tab bar labels overflow at large sizes — NativeTabs handles this natively; custom tab bars often don't" | A | `NATIVE_CHROME_DYNAMIC_TYPE_NOTES` | Default by platform |
| 14 | Animation primitives to scan | "`useAnimatedStyle\|withTiming\|withSpring\|cardEnter\|sectionEnter\|heroEnter`" | A | `ANIMATION_PRIMITIVES_GREP_PATTERN` | Inferred from `MOTION_LIBRARY` + `ANIMATION_PRESET_FILE_PATH` |
| 15 | Audit ID prefix | "A11Y-001 / A11Y-002" | A | `AUDIT_ID_PREFIX_PER_AGENT` | Default by agent name |
| 16 | Critical-fail framing | "If a CRIT-class failure is on an OWNER-facing surface, it's a ship-blocker" | A | `CRIT_BLOCKS_SHIP_SCOPE` | Ask Q-G1 |
| 17 | Reference apps for a11y | "Apple Settings / Apple Photos / Telegram on iOS 26 — those apps pass every dimension, every screen" | A | `A11Y_BENCHMARK_REFERENCES` | Subset of `TIER_1_BENCHMARKS` |
| 18 | Untestable-without-seeding framing | "If a screen is untestable without seeding (needs members, equipment, sessions), it says so and seeds via `app-state-navigation` recipes" | C | `APP_STATE_NAVIGATION_SKILL_EXISTS` | Scaffold via opt-in |

### 1.4 — `agents/flow-auditor.md` (32 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Product framing | "ProductName" | A | `PROJECT_DESCRIPTOR` | reuse |
| 2 | Example arc names | "sign-up → wizard → first daily-driver open; or fresh-gym → walk-tag → equipment placed → ready-for-members" | A | `ARC_INVENTORY` | Ask Q-D1 (default empty in greenfield) |
| 3 | Flow doc path | "`docs/flows/<arc-slug>.md`" | A | `FLOW_DOC_PATH_CONVENTION` | Ask Q-H1 + scaffold via `/dotclaude:setup-flow-docs` |
| 4 | Audit doc path | "`docs/audits/YYYY-MM-DD-<arc-slug>-audit.md`" | A | `AUDIT_REPORT_PATH_CONVENTION` | Ask Q-H1 + scaffold |
| 5 | Routing-to-other-agents framing | "Hand off fixes to product-designer (IA gaps), ux-reviewer (UI polish), or direct implementation" | B | `AUDIT_AGENT_INVENTORY` | Derive from kit composition |
| 6 | Memory binding refs | "`feedback-daily-vs-onboarding-copy`, `feedback-execution-without-judgment`, `project-assistant-intro-onboarding-only`" | C | `BINDING_MEMORIES_FOR_FORBIDDEN_PATTERNS` | Scaffold via `/dotclaude:setup-binding-memories` (template + opt-in) |
| 7 | Prototype gates path | "`.claude/rules/prototype-gates.md` (which gate this arc serves)" | C | `PROTOTYPE_GATES_PATH` | Scaffold via `/dotclaude:setup-strategy-lens` (opt-in) |
| 8 | Gate names | "self-dogfood / friend-onboarded / self-onboarding / Gate-0" | A | `PROTOTYPE_GATE_NAMES` | Scaffold default templates per project type |
| 9 | Seed commands | "`yarn e2e:seed`" | A | `SEED_FIXTURE_MECHANISM` | Ask Q-D4 |
| 10 | Supabase MCP usage | "use Supabase MCP to inspect what the state would look like" | A | `DATA_SHAPE_PROBE_INTERFACE` | Default: "none" greenfield |
| 11 | Capability-delta requirement | "Spec MUST name the capability ID(s) it changes (e.g. `O.3 [partial] → [shipped]`, `M.4 new`)" | C | `CAPABILITY_MAP_PATH` | Scaffold via `/dotclaude:setup-capability-map` (opt-in) |
| 12 | Class-1 trigger phrases | "'Hi', 'I'm Assistant', 'Welcome', 'Let me introduce', 'Let's get started', 'Let's begin', 'Get started', 'Meet Assistant'" | A | `BRAND_FORBIDDEN_PHRASES` | Ask Q-C4 |
| 13 | Class-1 example surface | "The 'Hi — I'm Assistant on daily home' class" | A | `CLASS_1_EXAMPLE_BUG` | Skip greenfield; backfill |
| 14 | "8 gap classes" enumeration | "Context-mismatch / Dead-end / Missing bridge / Tone drift / Missing state variant / Visual inconsistency / IA boundary / Copy register" | B | `GAP_CLASS_TAXONOMY` | Universal default; document in principle |
| 15 | "Apple iCloud + Telegram phone-number" bridge refs | "Apple iCloud onboarding and Telegram phone-number flow are the references for elegant bridges" | A | `BRIDGE_REFERENCE_APPS` | Subset of `TIER_1_BENCHMARKS` |
| 16 | Sentence-case framing | "Sentence case on most surfaces, then sudden Title Case on a button" | A | `COPY_CASE_CONVENTION` | Ask Q-C5 (default sentence) |
| 17 | Accent color discipline | "amber means one thing throughout" | A | `STATUS_COLOR_SYSTEM` | Ask Q-F2 |
| 18 | Translation file paths | "`lib/verticals/gym/owner/translations/`, `lib/wizard/translations.ts`" | A | `TRANSLATION_FILE_LOCATIONS` | Ask Q-D3 (default empty greenfield) |
| 19 | Narration file paths | "`lib/verticals/gym/owner/translations/narration.ts`" | A | `NARRATION_FILE_LOCATIONS` | Ask Q-D3 |
| 20 | Per-tab data owner | "Floor owns the map, People owns the roster, Status references both via counts" | A | `IA_OWNERSHIP_TABLE` | Skip greenfield; build after Section IA-design |
| 21 | Branding capitalization examples | "ProductName vs productname" | A | `BRAND_CAPITALIZATION` | Ask Q-D5 |
| 22 | Severity taxonomy | "Crit / High / Med / Low" | A | `SEVERITY_TAXONOMY` | Default; per-agent |
| 23 | Resolution columns | "A resolved, B remaining, C new" | B | `AUDIT_RESOLUTION_DELTA_SCHEMA` | Universal default |
| 24 | Gap ID prefix | "G-001 / G-002 …" | A | `AUDIT_ID_PREFIX_PER_AGENT` | Default |
| 25 | Handoff column | "Handoff: product-designer / ux-reviewer / direct impl / pre-flight / data-auditor" | A | `HANDOFF_AGENT_INVENTORY` | Derive from kit composition |
| 26 | Re-audit cadence framing | "After any ship / After 90 days of no changes / Before any redesign" | B | `REAUDIT_CADENCE` | Universal default |
| 27 | "STOP and ask if ambiguous" | "If the user invocation is ambiguous (e.g. 'audit onboarding' — does that include walk-tag?), ASK before walking" | B | `AMBIGUOUS_SCOPE_PROTOCOL` | Universal |
| 28 | Verbatim-copy rule | "Visible copy verbatim — NOT paraphrased. Pull from translations files / inline strings" | B | `COPY_INVENTORY_RULE` | Universal |
| 29 | App-state-navigation skill | "use Maestro to seed via `yarn e2e:seed` or use Supabase MCP" | C | `APP_STATE_NAVIGATION_SKILL_EXISTS` | Scaffold opt-in |
| 30 | Refusal output verbatim | "Recommending <agent-name> with brief: <one sentence>. No further work from me on this topic." | B | `AGENT_REFUSAL_TEMPLATE` | Universal |
| 31 | Specific assistant character name | "Assistant" | A | `IN_PRODUCT_ASSISTANT_CHARACTER` | Ask Q-C2 |
| 32 | Bucket-key example | "`bucket.l0.allDay`" | A | `NARRATION_KEY_NAMING_CONVENTION` | Skip greenfield; project develops its own |

### 1.5 — `agents/flow-ux-reviewer.md` (14 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | In-product character | "Assistant tone consistency" | A | `IN_PRODUCT_ASSISTANT_CHARACTER` | Q-C2 |
| 2 | Tier 1 reference | "Apple iOS 26 + Telegram on iOS 26" | A | `TIER_1_BENCHMARKS` | Q-B1 |
| 3 | Tier 2 references | "WHOOP/Strava/Oura/Linear/Superhuman" | A | `TIER_2_BENCHMARKS_WITH_DIMENSION` | Q-B2 |
| 4 | Manifest schema | "PNGs named `NN-screen-name.png` … manifest JSON describes each screenshot's `step`, `name`, `path`, and `context`" | B | `MANIFEST_SCHEMA` | Universal default; document in principle |
| 5 | Audit dir path | "`.claude/audits/<flow-name>/<run-id>/report.md`" | A | `FLOW_AUDIT_DIR_CONVENTION` | Ask Q-H1; scaffold |
| 6 | 6 flow-level dimensions | "tone consistency / CTA weight progression / loading-state treatment / disclosure pacing / color/tonality drift / progress legibility" | B | `FLOW_CONTINUITY_DIMENSIONS` | Universal default |
| 7 | Bridge references | "Apple iCloud onboarding and Telegram's phone-number flow" | A | `BRIDGE_REFERENCE_APPS` | Q-B2b |
| 8 | Persona check at flow level | "Does Assistant's voice stay the partner-companion register from screen 1 to N?" | A | `PRODUCT_HAS_VOICE` + `IN_PRODUCT_ASSISTANT_CHARACTER` | Q-C1/C2 |
| 9 | "Don't interact with the app" framing | "You're grading captured screenshots. Don't launch Maestro" | B | `FLOW_REVIEWER_INTERACTION_BOUNDARY` | Universal |
| 10 | 6-dim state-clarity (gen surfaces) | "truth alignment, motion proof, stage legibility, partial disclosure, failure affordance, terminal state" | B | `STATE_CLARITY_DIMENSIONS` | Universal default for projects that have generative surfaces; opt-in Q-D6 |
| 11 | Read-prior-runs pattern | "Look in the same `.claude/audits/<flow-name>/` directory for prior `manifest.json` + `report.md`" | B | `REGRESSION_DELTA_PATTERN` | Universal |
| 12 | Grade target | "flow grade A or above; no screen below B" | A | `QUALITY_GRADE_TARGETS_BY_SURFACE` | Q-E3 |
| 13 | Default output path | "`.claude/audits/flow/report.md`" | A | `FLOW_AUDIT_DIR_CONVENTION` | derive |
| 14 | Skills frontmatter | "`skills: [design-system, quality-bar, app-state-navigation, journey-audit, persona-lens]`" | B | `AGENT_SKILL_FRONTMATTER` | Derive |

### 1.6 — `agents/pages-audit.md` (24 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Section count | "The 5 owner tabs" | A | `PRIMARY_SECTION_INVENTORY` | Ask Q-D2 (default: skip ship in greenfield) |
| 2 | Section names | "GYM / EQUIPMENT / WORKOUTS / MEMBERS / SETTINGS" | A | `PRIMARY_SECTION_INVENTORY` | Ask Q-D2 |
| 3 | Section routes | "`/(owner)/`, `/(owner)/equipment`, `/(owner)/workouts`, …" | A | `PRIMARY_SECTION_INVENTORY` | Ask Q-D2 |
| 4 | Section testIDs | "`tab-status`, `tab-gym`, `tab-workouts`, `tab-members`, `tab-settings`" | A | `PRIMARY_SECTION_INVENTORY` | Ask Q-D2 |
| 5 | Section file paths | "`app/(owner)/index.tsx`, etc." | A | `PRIMARY_SECTION_INVENTORY` | Ask Q-D2 |
| 6 | Persona name | "gym owner on iPhone" | A | `USER_PERSONA_TYPE` | Q-E1 |
| 7 | Reference apps | "Apple Music, Photos, Wallet, Telegram" | A | `TIER_1_BENCHMARKS` | Q-B1 |
| 8 | Shared layout primitive (page) | "`<OwnerPage>` + `<OwnerPageHeader>`" | A | `SHARED_PAGE_WRAPPER_NAMES` | Default empty greenfield; scaffold after first impl |
| 9 | Shared layout primitive path | "`components/OwnerPageHeader.tsx`, `components/PageContent.tsx`" | A | `SHARED_PAGE_WRAPPER_PATHS` | Default empty greenfield |
| 10 | Shared header primitive | "`<CardTitle>` or `<InsightsSectionHeader>`" | A | `SHARED_HEADER_PRIMITIVE_NAMES` | Default empty |
| 11 | Token hook reference | "`bg-card` / `bg-background`" | A | `THEME_TOKEN_NAMES` | Inferred from `STYLING_SYSTEM_IN_USE` |
| 12 | Token-hook companion ref | "already enforced by `check-token-only.sh` hook" | A | `HOOK_INVENTORY` | Derive from kit composition |
| 13 | Seed cmd specific | "`yarn e2e:seed:layer3`, `yarn e2e:seed:archetypes`" | A | `SEED_FIXTURE_MECHANISM` | Q-D4 |
| 14 | Auth fixture vars | "TEST_ORPHAN_EMAIL=e2e-orphan@test.intelgym.app TEST_PASSWORD='TestPassword123!'" | A | `SEED_AUTH_ENVIRONMENT` | Skip greenfield |
| 15 | E2E helper path | "`e2e/helpers/setup-onboarding-owner.yaml`" | A | `E2E_HELPER_INVENTORY` | Skip greenfield |
| 16 | Native tab bar name | "NavTabs" | A | `NATIVE_TAB_BAR_PRIMITIVE_NAME` | Default by platform |
| 17 | Overlay inventory (per-section) | "JobsQueueSheet / EquipmentCardSheet / QuickIdentifySheet / TemplateDetailSheet / MemberDetailSheet / Sign Out Dialog" | A | `OVERLAY_INVENTORY` | Default empty greenfield |
| 18 | Sheet primitive | "`<BottomSheetModal>` from `components/ui/sheet.tsx`" | A | `SHARED_OVERLAY_PRIMITIVES` | Default empty |
| 19 | Confirm dialog primitive | "`useConfirmDialog()` from `components/ui/confirm-dialog.tsx`" | A | `SHARED_OVERLAY_PRIMITIVES` | Default empty |
| 20 | Glass card backing | "All use `<GlassCard>` backing (already-solid v3)" | A | `SHARED_CHROME_PRIMITIVE` | Default by platform |
| 21 | Audit doc path | "`docs/audits/<YYYY-MM-DD>-pages-consistency-audit.md`" | A | `AUDIT_REPORT_PATH_CONVENTION` | Q-H1 |
| 22 | Retired web-variant note | "The legacy desktop-web variant of this audit was retired 2026-05-18" | A | `RETIRED_AUDIT_VARIANTS_NOTES` | Skip greenfield |
| 23 | NavTabs accessibility pattern | "NavTabs uses accessibility 'TITLE, tab, N of M' pattern" | A | `NATIVE_TAB_BAR_A11Y_PATTERN` | Default by platform |
| 24 | "Majority Rules" principle | "majority is the expected value. Any tab that deviates is flagged — even if its value is arguably 'better.'" | B | `CONSISTENCY_VERDICT_RULE` | Universal default |

### 1.7 — `agents/design-token-auditor.md` (11 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Token file path | "`lib/theme/tokens.ts`" | A | `DESIGN_SYSTEM_TOKENS_PATH` | Q-F1 |
| 2 | "One accent = cyan" | "one accent = cyan, restraint, etc." | A | `BRAND_ACCENT_COLOR` | Q-F2; default by platform/brand |
| 3 | CLAUDE.md mandate quote | "CLAUDE.md mandates 'Theme tokens only — `bg-primary` > palette > never raw hex.'" | B | `CLAUDE_MD_TOKEN_RULE` | Scaffold CLAUDE.md template includes this |
| 4 | ESLint hook companion | "Existing ESLint hooks lint+format but don't audit token discipline" | A | `LINT_INFRASTRUCTURE` | Default by language ecosystem |
| 5 | Sweep paths | "`app/`, `components/`, `lib/`" | A | `SOURCE_CODE_PATHS` | Default by framework |
| 6 | Pattern set (RN-flavored) | "`StyleSheet.create` blocks with inline color literals / `style={{ ... color: ... }}` with literals / Tailwind arbitrary values like `bg-[#abc]`" | A | `RAW_COLOR_PATTERNS_BY_STYLING_SYSTEM` | Derive from `STYLING_SYSTEM_IN_USE` |
| 7 | Excluded paths | "`lib/theme/tokens.ts`, `lib/theme/patterns.ts`, generated files, `node_modules/`, `__snapshots__/`, `ios/`, `modules/*/ios/`" | A | `EXEMPT_PATHS` | Default by framework; greenfield = generic exemptions only |
| 8 | S0-tier examples | "Owner-facing chrome (sheets, buttons, headers, tab labels, Assistant bubbles, NavTabs). These break Apple-or-Telegram parity." | A | `S0_TIER_SURFACE_EXAMPLES` | Default by platform |
| 9 | S1 examples | "Visible content surfaces (cards, list rows, equipment hero)" | A | `S1_TIER_SURFACE_EXAMPLES` | Default |
| 10 | S2 examples | "Internal-only screens (dev tools, audit dashboards, feature flags)" | A | `S2_TIER_SURFACE_EXAMPLES` | Default |
| 11 | Model tier | "`claude-haiku-4-5-20251001`" | A | `MODEL_TIER_LIGHTWEIGHT` | Q-K1 |

### 1.8 — `agents/product-designer.md` (38 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Product framing | "at ProductName" | A | `PROJECT_DESCRIPTOR` | reuse |
| 2 | Vertical naming | "gym vertical" | A | `PRODUCT_VERTICAL_LABEL` | Q-D5 |
| 3 | North-star ref | "Apple iOS 26 + Telegram on iOS 26" | A | `TIER_1_BENCHMARKS` | Q-B1 |
| 4 | Active brainstorm path | "active `docs/brainstorms/<topic>-brainstorm.md`" | C | `BRAINSTORM_DOC_PATH_CONVENTION` | Scaffold via `/dotclaude:setup-brainstorm-docs` |
| 5 | CLAUDE.md ref | "CLAUDE.md (root) — product rules, DoD, the quality bar" | C | `EXISTING_CLAUDE_MD` | Scaffold via `/dotclaude:setup-claude-md` |
| 6 | Capability map ref | "`docs/product/capabilities.md`" | C | `CAPABILITY_MAP_PATH` | Scaffold via `/dotclaude:setup-capability-map` |
| 7 | Capability ID format | "`O.3 [partial] → [shipped]`, `M.4 new`" | C | `CAPABILITY_ID_NAMING` | Template ships with scaffold |
| 8 | Strategy lens ref | "`.claude/rules/prototype-gates.md`" | C | `PROTOTYPE_GATES_PATH` | Scaffold via `/dotclaude:setup-strategy-lens` |
| 9 | Engine-area CLAUDE.md refs | "Relevant `lib/<area>/CLAUDE.md` files" | C | `AREA_CLAUDE_MD_INVENTORY` | Optional scaffold (advanced) |
| 10 | Topic-specific skill list | "chat / Assistant → `chat-system` skill; owner setup → `owner-onboarding` skill; …" | C | `TOPIC_SPECIFIC_SKILLS_INVENTORY` | Project-grown over time; greenfield = empty |
| 11 | Verify-before-naming greps | "`grep -r '<symbol-or-table-name>' lib/ app/ supabase/migrations/`" | A | `INFRASTRUCTURE_VERIFY_GREPS` | Default by source-dir layout |
| 12 | Spec doc path | "`docs/brainstorms/YYYY-MM-DD-<slug>-design.md`" | A | `SPEC_DOC_PATH_CONVENTION` | Q-H1 + scaffold |
| 13 | Bash mkdir scaffold | "`mkdir -p docs/brainstorms/`" | A | derived | derived |
| 14 | Data-shape probe interface | "`mcp__supabase__execute_sql`" | A | `DATA_SHAPE_PROBE_INTERFACE` | Default: "none" greenfield; ask if applicable |
| 15 | psql fallback | "`psql \"$SUPABASE_DB_URL\" -c \"...\"`" | A | `DATA_SHAPE_PROBE_FALLBACK` | derived |
| 16 | Probe example | "P50 = 42 items per gym (observed 2026-05-12)" | A | `DATA_SHAPE_PROBE_OUTPUT_FORMAT` | Default |
| 17 | Steal-sheet topic table | "List rows → Settings rows / Cards over data → Music albums / Empty states → Photos Memories / Sheets → iOS Settings sheets / …" | A | `COMPETITIVE_REFERENCE_TABLE` | Default by platform; expand via Q-B |
| 18 | WebSearch patterns | "`WebSearch: 'iOS 26 Settings app row design 2026'`" | A | `COMPETITIVE_RESEARCH_QUERY_TEMPLATES` | Default by platform |
| 19 | Direction principle examples | "Progressive disclosure over upfront complexity" / "Not Linear's keyboard density" | A | `EXPERIENCE_PRINCIPLE_EXAMPLES` | Universal templates |
| 20 | Engine-ask format | "Add `member.last_seen_at` to the gym-detail query response. Target file: lib/verticals/gym/owner/members/queries.ts" | A | `ENGINE_ASK_FORMAT` | Universal default; project example |
| 21 | Element-reuse gate ref | "Section 0a documents every reused string/component" | C | `ELEMENT_REUSE_CHECK_REQUIRED` | Default true if `MULTI_SCREEN_ARCS_EXIST` |
| 22 | Persona lens gate ref | "Section 0b documents every copy element" | C | `PERSONA_LENS_REQUIRED` | Default true if `PRODUCT_HAS_VOICE` |
| 23 | Self-audit checklist (8 boxes) | "Journey map / Element-reuse audit / Persona lens audit / No forbidden phrases / No string duplicates onboarding / IA decisions reference journey / State inventory covers states / Engine asks concrete / Considered-and-rejected real" | B | `PRODUCT_DESIGNER_SELF_AUDIT_CHECKLIST` | Universal default |
| 24 | Self-audit framing memory | "The pattern of failure across this codebase has been: mechanically execute the spec template without applying judgment at the gates" | A | `PROJECT_FAILURE_PATTERNS` | Skip greenfield |
| 25 | Spec template — Section 0 | "Journey map (Phase 0 mandatory output)" | B | `SPEC_DOC_TEMPLATE_SECTIONS` | Universal default |
| 26 | Spec template — Section 0a | "Element-reuse audit (Phase 1 mandatory output)" | B | (same) | Universal |
| 27 | Spec template — Section 0b | "Persona lens audit (Phase 2 mandatory output)" | B | (same) | Universal |
| 28 | Spec template — Section 1 | "Goal + capability delta" | B | (same) | Capability delta only if `CAPABILITY_MAP_PATH` set |
| 29 | Stitch retirement note | "Stitch mockups were rejected 2× by the user as 'interpretation noise, not design'" | A | `MOCKUP_TOOL_POLICY` | Universal: skip mockup tools (defensible default) |
| 30 | Handoff menu | "pre-flight agent / feature-dev:code-architect / direct implementation / iterate" | A | `HANDOFF_AGENT_INVENTORY` | Derive from kit |
| 31 | Surface-platform check | "Owners are on iPhone touch, not 27-inch keyboard" | A | `PRIMARY_SURFACE_PLATFORM` | Q-A1 |
| 32 | Surface platform descriptor | "owners scan, don't read" | A | `USER_INTERACTION_MODE` | derive from persona |
| 33 | Considered & rejected examples | "Stacked list with summary header (Apple Settings pattern) / Filter-first chrome (Mail VIP-style pre-filtered inboxes)" | A | `CONSIDERED_ALTERNATIVES_EXAMPLES` | Universal templates |
| 34 | Sub-area skill list | "chat-system / owner-onboarding / intelligence-pipeline / equipment-ai / map-placement / job-system / import-scanner / pipeline-integrity" | C | `TOPIC_SPECIFIC_SKILLS_INVENTORY` | Empty greenfield |
| 35 | "verify infrastructure" rule | "VERIFY infrastructure exists before reasoning about it" | B | `INFRASTRUCTURE_VERIFY_RULE` | Universal |
| 36 | i18n / language conventions | "На всё тело / День жима / День тяги" | A | `I18N_CONVENTIONS` | Q-D7 (greenfield = none) |
| 37 | Brainstorm-doc-as-input | "Active `docs/brainstorms/<topic>-brainstorm.md` if one exists" | C | `BRAINSTORM_DOC_PATH_CONVENTION` | Scaffold opt-in |
| 38 | Tool inventory | "`WebSearch, WebFetch, mcp__supabase__execute_sql, mcp__supabase__list_tables`" | B | `AGENT_TOOL_INVENTORY` | Derive from kit + data layer |

### 1.9 — `agents/product-compass.md` (12 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Role framing | "Chief Product Officer of ProductName" | A | `PROJECT_DESCRIPTOR` | reuse |
| 2 | Vision doc inventory | "`project_core_vision.md` / `project_mcp_vision.md` / `project_autoresearch.md` / `project_map_ux.md` / MEMORY.md" | C | `PRODUCT_VISION_DOCS` + memory inventory | Scaffold via `/dotclaude:setup-vision-docs` (opt-in) |
| 3 | Architecture-layer priority | "Spatial Engine > AI Intelligence > MCP / API > Gym Vertical" | A | `ARCHITECTURE_LAYER_PRIORITY` | Q-J2 (greenfield default: "simple") |
| 4 | Core differentiators table | "Spatial layout (map-first UX) / Equipment ↔ Movement bridge / MCP intelligence layer / Premium feel (WHOOP-tier)" | A | `CORE_DIFFERENTIATORS_LIST` | Q-J3 |
| 5 | Drift indicators | "Features that don't connect to the spatial model or equipment graph" | A | `DRIFT_SIGNALS` | Q-J4 (optional) |
| 6 | Agent coordination table | "`pre-flight` / `product-designer` / `code-reviewer` / `data-auditor` / `ux-reviewer` / …" | B | `AGENT_COORDINATION_TABLE` | Derive from kit |
| 7 | Recent-work greps | "`git log --oneline -30 / git diff --stat HEAD~10 / git status`" | A | `RECENT_WORK_GREP_PATTERNS` | Universal default |
| 8 | File-tree greps | "`ls app/(owner)/ app/(member)/ / ls lib/*/`" | A | `PROJECT_FILE_TREE_GREPS` | Default by framework |
| 9 | Quality posture reference | "WHOOP/Strava/Oura benchmark" | A | `TIER_2_BENCHMARKS_WITH_DIMENSION` | Q-B2 |
| 10 | Documentation alignment table | "CLAUDE.md header / Project memories / Skill descriptions / Agent descriptions / Setup checklist" | B | `DOCUMENTATION_ALIGNMENT_TARGETS` | Derive |
| 11 | "Read fresh every invocation" | "ALWAYS READ VISION DOCS FRESH" | B | universal | universal |
| 12 | "Ask, don't assume" — A/B/C framing | "I noticed [observation]. This could mean: A) … B) … C) … Which is it?" | B | universal | universal |

### 1.10 — `skills/quality-bar/SKILL.md` (16 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Demo audience | "a friend's gym owner I'm trying to recruit as gym #2" | A | `DEMO_TEST_AUDIENCE` | Q-E3 |
| 2 | Prototype gates ref | "every member-facing or owner-facing surface either advances the recruitment of gym #2" | A | `PROTOTYPE_GATES_PATH` | Scaffold opt-in |
| 3 | S-tier benchmark | "Indistinguishable from Apple's own iOS 26 chrome OR Telegram on iOS 26" | A | `S_TIER_BENCHMARK_REFERENCES` | Subset of TIER_1 |
| 4 | A-tier benchmark | "WHOOP onboarding. Linear inbox. Raycast. Things 3." | A | `A_TIER_BENCHMARK_REFERENCES` | Q-B2 |
| 5 | C-tier benchmark | "Half-shipped startups." | A | `C_TIER_BENCHMARK_DESCRIPTOR` | Universal |
| 6 | 5 composition pitfalls | "Duplication / Orphan / Tone mismatch / Hierarchy violations / Residue" | B | `COMPOSITION_PITFALL_TAXONOMY` | Universal |
| 7 | Pitfall examples — Duplication | "Assistant's prose 'Got it — 2 floors, 6 rooms' + the `showAskResolved` chip … + the `showSetupChecklist` widget" | A | `COMPOSITION_PITFALL_EXAMPLES` | Skip greenfield |
| 8 | Pitfall examples — Orphan | "The 'Тип? → вилла' chip lingering in the active-ask slot" | A | (same) | Skip greenfield |
| 9 | Pitfall examples — Tone | "Composer placeholder reading 'Type a name…' when the user is *answering* Assistant" | A | (same) | Skip greenfield |
| 10 | Pitfall examples — Hierarchy | "`SetupChecklistInlineWidget` rendered as a 50%-screen-height card on top of Assistant's actual question" | A | (same) | Skip greenfield |
| 11 | Pitfall examples — Residue | "The universal X dismiss button positioned at `top: 6, right: 6` over every active-ask widget" | A | (same) | Skip greenfield |
| 12 | Tier 1 benchmarks (with steal) | "Apple Music / Photos / App Store / Settings / Wallet on iOS 26 / Telegram on iOS 26" + per-app what-to-steal | A | `TIER_1_BENCHMARKS` | Q-B1 |
| 13 | Tier 2 benchmarks (with steal) | "WHOOP onboarding — rhythm / Linear — text hierarchy / Raycast — input-first / Things 3 — empty states / Matterport/Polycam — spatial capture speed / Apple Quick Look + RoomPlan — AR fluidity" | A | `TIER_2_BENCHMARKS_WITH_DIMENSION` | Q-B2 |
| 14 | Fast vs careful examples | "Fast: typo / type-only fix in single file / renaming isolated callback. Careful: UI surface change / cross-module refactor / prompt change" | B | `FAST_VS_CAREFUL_TASK_TYPES` | Universal default; project-tune via Q-E4 |
| 15 | 5 done preconditions | "Fresh screenshot / Lint clean / Tests touched / Composition pitfalls scanned / Benchmark named" | B | `DONE_PRECONDITIONS_CHECKLIST` | Universal |
| 16 | Auto-load triggers | "Auto-load when … work touches `app/*.tsx`, `lib/*/components/`, `lib/*/widgets/`, or any prompt file" | A | `SKILL_AUTO_LOAD_PATHS` | Derive from `SURFACE_DIR_STRUCTURE` |

### 1.11 — `skills/journey-audit/SKILL.md` (10 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Surface enumeration globs | "`ls app/wizard/**/*.tsx / ls app/wizard/**/_layout.tsx / ls lib/assistant/setup/**/*.ts / ls lib/auth/**/*.tsx / ls app/(owner)/**/*.tsx`" | A | `SURFACE_DIR_STRUCTURE` | Q-D3 (greenfield = none) |
| 2 | Translation glob | "`ls lib/verticals/gym/owner/translations/**/*.ts`" | A | `TRANSLATION_FILE_LOCATIONS` | Q-D3 |
| 3 | Narration glob | "`ls lib/verticals/gym/owner/narration/**/*.ts`" | A | `NARRATION_FILE_LOCATIONS` | Q-D3 |
| 4 | 6 surface types | "first-touch / daily-driver / settings / error / promotional / bridge" | B | `SURFACE_TYPES_IN_USE` | Universal default; subset by project |
| 5 | Example surfaces per type | "Sign-up = first-touch; Status/Floor/People = daily-driver; …" | A | `SURFACE_TYPE_EXAMPLES` | Skip greenfield |
| 6 | Wizard intro example | "Wizard step 1 — Meet Assistant" + "Hi — I'm Assistant. Let's set up your gym." | A | (paired with C2) | Q-C2 |
| 7 | Forbidden-pattern matrix | "first-touch=None / daily-driver=Hi, I'm Assistant, Welcome, …" | B | `FORBIDDEN_PATTERN_MATRIX` | Universal default + brand additions |
| 8 | Path frontmatter | "`paths: \"docs/audits/**,docs/flows/**,docs/designs/**,docs/brainstorms/**\"`" | A | `JOURNEY_AUDIT_AUTO_LOAD_PATHS` | Derive from doc-path conventions |
| 9 | Cross-references | "`feedback_daily_vs_onboarding_copy` / `project_rex_intro_onboarding_only`" | C | `BINDING_MEMORIES_FOR_FORBIDDEN_PATTERNS` | Scaffold opt-in |
| 10 | Mandatory framing | "STOP if the map can't complete — read more files" | B | universal | universal |

### 1.12 — `skills/element-reuse-check/SKILL.md` (8 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Example bug | "`bucket.l0.allDay` — translations/narration.ts:60" | A | `PAST_REUSE_BUG_EXAMPLES` | Skip greenfield |
| 2 | Existing assistant name | "Assistant" | A | `IN_PRODUCT_ASSISTANT_CHARACTER` | Q-C2 |
| 3 | Grep search paths | "`grep -rn \"<exact-string-or-key>\" app/ lib/ docs/`" | A | `USER_VISIBLE_CODE_DIRS` | Derive |
| 4 | Verdict matrix | "first-touch → daily-driver = REJECT (write new copy) / first-touch → first-touch (different stage) = CAUTION / …" | B | `REUSE_VERDICT_MATRIX` | Universal |
| 5 | Section 0a name | "Section 0a — Element-reuse audit" | A | `SPEC_SECTION_HEADER_FOR_REUSE_AUDIT` | Universal |
| 6 | Component example | "`<MemberSnapshotCard>` — components/MemberSnapshotCard.tsx" | A | `PROJECT_COMPONENT_NAMES` | Skip greenfield |
| 7 | "Structural-only reuse exempt" | "Component reuse where the component is purely structural (e.g. `<PageContent>` wrapper, `<GlassCard>`)" | A | `STRUCTURAL_REUSE_EXEMPT_COMPONENTS` | Default by platform native primitives |
| 8 | Hook companion ref | "enforced at edit-time by `check-forbidden-phrases.sh`" | A | `HOOK_INVENTORY` | Derive |

### 1.13 — `skills/persona-lens/SKILL.md` (10 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Path frontmatter | "`paths: \"lib/verticals/gym/owner/translations/**/*.ts,lib/verticals/gym/owner/narration/**/*.ts,lib/wizard/translations.ts,lib/i18n/locales/**/*.ts\"`" | A | `PERSONA_LENS_AUTO_LOAD_PATHS` | Derive from `TRANSLATION_FILE_LOCATIONS` |
| 2 | Day-30 framing | "Would this string read OK if the user saw this exact string on day 30? day 60? day 365?" | B | `USAGE_FREQUENCY_FRAMING` | Q-C4 |
| 3 | Partner test reference | "Samantha (the partner-companion model … from *Her*). Telegram's product voice. Apple's empty-state voice in Photos / Notes." | A | `BRAND_VOICE_REFERENCE` | Q-C3 |
| 4 | Anti-references (4 registers) | "Customer-service / Apology / Performance / Tutorial" | B | `VOICE_ANTI_REFERENCES` | Q-C4 |
| 5 | Stranger test framing | "Does this string assume the user has already met the assistant — or is it introducing them as if for the first time?" | A | `IN_PRODUCT_ASSISTANT_CHARACTER` | Q-C2 |
| 6 | Forbidden-phrase mirror | "Hi / Hello / Hey there / I'm Assistant / Welcome / …" | A | `BRAND_FORBIDDEN_PHRASES` | Q-C4 |
| 7 | Auto-exempt file | "The forbidden-phrase list is binding everywhere except `app/wizard/meet-assistant.tsx`" | A | `ASSISTANT_INTRO_EXEMPT_FILE` | Q-C2 (intro file path) |
| 8 | Triad override note | "Day-30 / Partner / Stranger" | A | `PERSONA_TRIAD` | Q-C5 (override) |
| 9 | Mandatory framing | "Audit-time gate is mandatory. Even if the design passed this gate at spec time, the audit re-runs it" | B | universal | universal |
| 10 | Memory cross-refs | "`feedback_daily_vs_onboarding_copy`, `project_rex_intro_onboarding_only`" | C | `BINDING_MEMORIES_FOR_FORBIDDEN_PATTERNS` | Scaffold opt-in |

### 1.14 — `skills/design-system/SKILL.md` (32 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Path frontmatter | "`paths: \"lib/theme/**,components/ui/**,lib/widgets/primitives/**\"`" | A | `DESIGN_SYSTEM_AUTO_LOAD_PATHS` | Derive from token path + primitive paths |
| 2 | North-star reference | "Apple iOS 26 + Telegram on iOS 26" | A | `TIER_1_BENCHMARKS` | Q-B1 |
| 3 | Native primitive — NavTabs | "`<NavTabs items={items} />` (`components/NavTabs.tsx`)" | A | `NATIVE_CHROME_PRIMITIVES_LIST` + `CHROME_PRIMITIVE_PATHS` | Q-F2 (greenfield: empty) |
| 4 | Native primitive — GlassCard | "`<GlassCard variant=\"regular\" />` (`lib/widgets/primitives/GlassCard.tsx`)" | A | (same) | Q-F2 |
| 5 | Native primitive — BottomSheetModal | "`<BottomSheetModal>` (`components/ui/sheet.tsx`)" | A | (same) | Q-F2 |
| 6 | Native primitive — useConfirmDialog | "`useConfirmDialog()` (`components/ui/confirm-dialog.tsx`)" | A | (same) | Q-F2 |
| 7 | Token file path | "`lib/theme/tokens.ts (SINGLE SOURCE OF TRUTH)`" | A | `DESIGN_SYSTEM_TOKENS_PATH` | Q-F1 + scaffold via `/dotclaude:setup-token-system` |
| 8 | Theme generation cmd | "`yarn generate:theme`" | A | `THEME_GENERATION_COMMAND` | Q-F1; default "none" greenfield |
| 9 | Generated output paths | "`global.css` (CSS variables for web SSR) / `tokens.generated.cjs` (for tailwind.config.js)" | A | `THEME_GENERATED_FILES` | Derive |
| 10 | Token export list | "`palette, theme, spacing, radii, shadows`" | B | `TOKEN_TAXONOMY` | Universal default |
| 11 | NativeWind classes | "`bg-background text-foreground / bg-primary text-primary-foreground / bg-card border-border / …`" | A | `STYLING_SYSTEM_IN_USE` | Q-F1 |
| 12 | JS access hook | "`import { useThemeColor } from '@/lib/theme/hooks/use-theme-color'`" | A | `THEME_COLOR_HOOK_PATH` | Derive from token system |
| 13 | Semantic color table | "`background = #f5f8f8 light / #101e23 dark / foreground = …`" | A | `SEMANTIC_COLOR_VALUES` | Q-F2 (scaffolded) |
| 14 | Palette scales | "`neutral 50-950 / cyan 50-950 / red 50-950 / green 50-950 / amber 50-950`" | A | `BRAND_PALETTE_SCALES` | Q-F2 |
| 15 | Per-gym theming | "Gym-specific overrides in `lib/theme/gymThemes.ts`" | A | `PER_TENANT_THEMING_PATH` | Skip greenfield (advanced) |
| 16 | "WHOOP / Strava / Oura / Vision Pro" — what to take from each | "WHOOP: Minimal dark surfaces, animated score rings, restrained color use" | A | `TIER_2_BENCHMARKS_WITH_DIMENSION` | Q-B2 |
| 17 | 5-level surface hierarchy | "Background / Card / Sheet / Elevated card / Frosted glass" + per-level (bg, border, shadow) | B | `SURFACE_HIERARCHY_LEVELS` | Universal default |
| 18 | 5 motion principles | "Spring-based / Staggered / Purposeful / Fast exits, slow entrances / Respect reduced motion" | B | `MOTION_PRINCIPLES` | Universal |
| 19 | Animation presets path | "`lib/theme/patterns.ts`" | A | `ANIMATION_PRESET_FILE_PATH` | Q-F2c |
| 20 | Animation preset names | "`cardEnter / sectionEnter / heroEnter / cardLayout / cardExit / selectionBounce`" | A | `ANIMATION_PRESET_NAMES` | Skip greenfield (project-grown) |
| 21 | Animation perf cap | "Only animate first 10 visible items in a list" | B | `ANIMATION_PERFORMANCE_CAP` | Universal default |
| 22 | SVG techniques | "Loop-clean periodic morph / Fill-on-morphing-path / ClipPath with AnimatedPath child / Single time-driver + per-particle phase / Particle-influenced shape / Inverse size→opacity" | A | `PROJECT_SPECIFIC_SVG_TECHNIQUES` | Skip greenfield |
| 23 | SVG footguns | "`transform` string animation throws 'invalidTransform' / Worklet variable order matters in tests / Metro hot-reload unreliable for changes inside `useAnimatedProps`" | A | `RN_LIBRARY_GOTCHAS_LIST` | Skip greenfield; backfill |
| 24 | Shadow presets | "`cardShadow / sheetShadow / glowShadow(color) / frostedShadow`" | A | `SHADOW_PRESET_NAMES` | Skip greenfield |
| 25 | Card pattern | "Container: mx-6 mb-2 / Card: bg-card rounded-2xl border overflow-hidden / Border: border-white/5 (default) / Shadow: cardShadow / Padding: p-4" | A | `STANDARD_CARD_PATTERN` | Skip greenfield |
| 26 | Status color system | "Catalog match=green / New product (high confidence)=cyan / Likely=cyan / Uncertain=amber / Failed=red" | A | `STATUS_COLOR_SYSTEM` | Q-F2d |
| 27 | Quality tier per surface | "S=Walk & Tag AR / Dashboard hero / A=Equipment list, member list / B=Current import review / C=Current import summary" | A | `QUALITY_TIER_BY_SURFACE` | Q-E3 |
| 28 | RN library gotchas — select | "`@rn-primitives/select` doesn't reset display" | A | `RN_LIBRARY_GOTCHAS_LIST` | Skip greenfield |
| 29 | RN library gotchas — bottom-sheet | "`@gorhom/bottom-sheet` — fixed snap points clip variable content. Use `enableDynamicSizing`" | A | (same) | Skip greenfield |
| 30 | RN library gotchas — tab navigators | "Tab navigators don't remount components" | A | (same) | Skip greenfield |
| 31 | 4Q docstring template | "Screen: <name> / 1. One-sentence purpose / 2. Primary action / 3. Per-element chrome-vs-handler / 4. Redundant affordances?" | B | `INTERACTION_SEMANTICS_4Q_DOCSTRING_REQUIRED` | Universal default; opt-in for new UI agents to require |
| 32 | i18n conventions | "Full Body → На всё тело / Push Day → День жима / Pull Day → День тяги" | A | `I18N_CONVENTIONS` | Q-D7 (skip if no localization) |

### 1.15 — `skills/ruthless-ux-autoloop/SKILL.md` (22 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Iteration cap hard | "hard cap 10 iterations" | A | `ITERATION_CAP_HARD` | Universal default; override Q-K2 |
| 2 | Iteration cap soft | "soft target 6" | A | `ITERATION_CAP_SOFT` | Universal default |
| 3 | Reviewer agent name | "`flow-ux-reviewer` for multi-screen arcs; `ux-reviewer` for single-screen drilldowns" | B | `REVIEWER_AGENT_NAME` | Derive from kit |
| 4 | Tier 1/2 refs | "Apple iOS 26 + Telegram on iOS 26 = Tier 1; WHOOP/Strava/Oura/Linear/Superhuman = Tier 2" | A | `TIER_1_BENCHMARKS` + `TIER_2_BENCHMARKS` | Q-B1/B2 |
| 5 | Flow-level dimensions | "Assistant tone consistency, CTA weight progression, loading-state treatment, disclosure pacing, color/tonality drift" | B | `FLOW_CONTINUITY_DIMENSIONS` | Universal |
| 6 | State-clarity scorecard | "truth alignment, motion proof, stage legibility, partial disclosure, failure affordance, terminal state" | B | `STATE_CLARITY_DIMENSIONS` | Universal; opt-in per project |
| 7 | Semantic-count rule | "`1/4`, `3/3`, `Processing 2`, `N items ready` — Name the denominator out loud. Is it 'total equipment in this gym' (user truth) or 'the job's scoped subset' (job truth)?" | A | `SEMANTIC_COUNT_AUDIT_PATTERNS` | Skip greenfield; default rule preserved |
| 8 | DAG pipeline corollary | "specs → icons → exercises → templates" | A | `PROJECT_PIPELINE_DAG` | Skip greenfield |
| 9 | Backend truth probe SQL | "`SELECT COUNT(*) FROM <table> WHERE <field> IS NULL OR <field> = <empty>;` / `SELECT type, status, result_json FROM jobs …`" | A | `BACKEND_TRUTH_PROBE_QUERIES` | Skip greenfield; default "none" |
| 10 | Anti-pattern catalog (9 named) | "Silent-success / Silent-queue / React Query mutation race / 'Add X' CTA during active pipeline / Semantic color abuse / Bundle/device-target staleness / Hypothesis-spam / Server mutation without query invalidation / Engine flow assumes vertical-specific callback" | A | `PAST_AUTOLOOP_ANTIPATTERNS` | Skip greenfield; build over time |
| 11 | Fixture orphan SQL cascade | "cascades through workout_template_exercises → workout_templates → product_ai_generations → …" | A | `FIXTURE_RESET_CASCADE` | Skip greenfield |
| 12 | Fixture cmd | "`yarn e2e:seed:layer1`" | A | `FIXTURE_RESET_COMMAND` | Q-D4 (greenfield: none) |
| 13 | Harness — dual-flow | "dual-flow Maestro capture — setup-arc yaml + live-generative yaml chained on same orphan" | A | `FLOW_CAPTURE_HARNESS` | Q-A3 + scaffold |
| 14 | Audit dir convention | "`.claude/audits/<flow>/R<N>-$RUN_ID`" | A | `AUTOLOOP_AUDIT_DIR_CONVENTION` | Universal default |
| 15 | Audit ledger | "`.claude/audits/<flow>/AUTOLOOP-LOG.md`" | A | (same) | Universal |
| 16 | Per-iteration commit format | "`audit(<flow>): R<N-1>→R<N> <fix>`" | A | `AUTOLOOP_COMMIT_FORMAT` | Universal default |
| 17 | Schedule wakeup | "`ScheduleWakeup(delaySeconds=270, prompt=<same /loop prompt updated with R<N+1> state>)`" | A | `AUTOLOOP_SCHEDULE_API` | Default by harness availability |
| 18 | Safety invariants — never edit list | "Never edit: migrations, `package.json`, `tokens.ts` structure, fixture files, Maestro YAML" | A | `SAFETY_INVARIANTS` | Default; project-specific Q |
| 19 | Environment var examples | "`EXPO_PUBLIC_FORCE_SPECS_FAIL`" | A | `TOUCHY_ENV_VARS` | Skip greenfield |
| 20 | Generative-surface checklist | "Is the AI working right now? On what specifically? Is anything failing? How do I know when it's done?" | B | `GENERATIVE_SURFACE_CHECKLIST` | Universal; opt-in if `HAS_GENERATIVE_SURFACES` |
| 21 | User's standing principle | "Polished UX with every element having a purpose and within the entire composition" | A | `USER_STANDING_PRINCIPLE` | Q-E5; default to this text |
| 22 | Termination on user msg | "New user message arrives — finish current iteration, summarize, wait" | B | universal | universal |

### 1.16 — `skills/flow-ux-audit/SKILL.md` (18 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Vertical params | "gym / space" | A | `VERTICAL_PARAMETERIZATIONS` | Skip greenfield; project-grown |
| 2 | Setup-flow YAMLs | "`e2e/flows/owner/gym-ux-audit.yaml`, `e2e/flows/owner/setup-ux-audit.yaml`" | A | `MAESTRO_YAML_PATH_BY_VERTICAL` | Skip greenfield; opt-in |
| 3 | Autoplay env vars | "`EXPO_PUBLIC_MOCK_WALK_TAG=1`, `EXPO_PUBLIC_WALK_TAG_AUTOPLAY=1`, `EXPO_PUBLIC_WALK_TAG_FIXTURE=<gym-home\|villa-studio>`" | A | `CAPTURE_AUTOPLAY_BUILD_ENV` | Skip greenfield |
| 4 | Build cmd | "`yarn ios --simulator \"iPhone 15 Pro\"`" | A | `DEV_CLIENT_BUILD_COMMAND` | Default by Phase 1 scan |
| 5 | Metro detect script | "`scripts/detect-metro-target.sh`" | A | `METRO_TARGET_DETECTION_COMMAND` | Default; project-specific |
| 6 | Seed layer cmd | "`yarn e2e:seed:layer1`" | A | `SEED_LAYER_COMMAND_BY_TIER` | Q-D4 |
| 7 | Audit dir conv | "`.claude/audits/<gym-flow\|setup-flow>/$RUN_ID`" | A | `AUDIT_DIR_CONVENTION_BY_VERTICAL` | Default; greenfield: single-vertical |
| 8 | Manifest schema v1 | "`schemaVersion: 1 / runId / vertical / fixture / screens[].step / .name / .path / .context`" | B | `MANIFEST_SCHEMA_VERSION` | Universal default |
| 9 | Canonical screen sequence — gym | "01 setup-picker · 02 create-gym-empty · …" | A | `CANONICAL_SCREEN_SEQUENCE_BY_VERTICAL` | Skip greenfield |
| 10 | Canonical screen sequence — space | "01 setup-picker · 02 create-space-greeting · …" | A | (same) | Skip greenfield |
| 11 | Hermes correction suppression note | "Hermes correction emission is suppressed under autoplay" | A | `TELEMETRY_SUPPRESSION_NOTES` | Skip greenfield |
| 12 | Autoplay testID | "`mock-walk-tag-playback`" | A | `AUTOPLAY_TESTID_SENTINEL` | Skip greenfield |
| 13 | "Photo 404s" gotcha | "fixture URLs resolve to `fixtures.local/*` if Supabase fixture bucket is empty" | A | `KNOWN_GOTCHAS` | Skip greenfield |
| 14 | "Three valid terminals" | "YAML branches on whichever testID appears first — `enrichment-waterfall-card` (clean), `post-scan-widget-partial`, `unplaced-tray`" | A | `MULTI_TERMINAL_FLOWS` | Skip greenfield |
| 15 | Type ID fixture violation | "`equipment_products_type_fkey` if a fixture references an unknown type" | A | `KNOWN_FIXTURE_INTEGRITY_RULES` | Skip greenfield |
| 16 | LogBox-as-modal gotcha | "`console.error` during the flow overlays UI and absorbs taps" | A | `PLATFORM_KNOWN_GOTCHAS` | Default by platform |
| 17 | AppLoadingOverlay gotcha | "AppLoadingOverlay paints over owner tabs for up to 2.5s" | A | (same) | Skip greenfield |
| 18 | Phase 2 pending note | "Phase 2 (pending re-entry coverage): state 07 owner-home-after-setup · …" | A | `PHASE_2_DEFERRED_COVERAGE` | Skip greenfield |

### 1.17 — `skills/storybook-story/SKILL.md` (14 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Storybook framework | "`@storybook/react-vite`" | A | `STORYBOOK_FRAMEWORK` | Phase 1 scan; ask Q-H2 if absent |
| 2 | Storybook config path | "`.storybook/main.ts`, `.storybook/preview.ts`" | A | `STORYBOOK_CONFIG_PATHS` | Derive |
| 3 | RN-web resolution | "handles `react-native` → `react-native-web` resolution" | A | `STORYBOOK_RN_WEB_RESOLUTION` | Default if `STORYBOOK_FRAMEWORK` + RN |
| 4 | Component dirs | "`components/ui/`, `lib/widgets/primitives/`" | A | `COMPONENT_LIBRARY_PATHS` | Q-F2 |
| 5 | Title convention | "`'UI/<Name>'` for `components/ui`, `'Widgets/<Name>'` for `lib/widgets/primitives`" | A | `STORYBOOK_TITLE_CONVENTION` | Derive |
| 6 | Reference stories | "Button / Card / Input / Text / ScoreArc / Badge" | A | `STORYBOOK_REFERENCE_STORY_PATHS` | Skip greenfield (no existing) |
| 7 | Dark default | "`.storybook/preview.ts` sets `defaultTheme: 'dark'` via `withThemeByClassName`" | A | `STORYBOOK_DARK_DEFAULT` | Q-H2 (default true on RN/native) |
| 8 | RN-primitives web list | "`rnPrimitivesWebPackages` list in `.storybook/main.ts`" | A | `STORYBOOK_RN_PRIMITIVES_WEB_LIST` | Skip greenfield |
| 9 | Coverage gap note | "Storybook 10 / 57 components, only 5 have stories" | A | `STORYBOOK_COVERAGE_PROGRESS_NOTE` | Skip greenfield |
| 10 | State spectrum table | "Loading / Disabled / Error / Empty / Long content / Dark + Light" | B | `STATE_SPECTRUM_PER_COMPONENT_KIND` | Universal |
| 11 | Storybook verify cmd | "`yarn storybook` (`http://localhost:6006`)" | A | `STORYBOOK_VERIFY_COMMAND` | Derive |
| 12 | File-size ceiling | "1000-LOC rule. If `AllVariants` balloons past ~150 LOC of JSX, extract" | A | `FILE_SIZE_CEILING_LOC` | Universal default (project-tune) |
| 13 | Storybook auto-load paths | "`paths: \"components/ui/**,lib/widgets/primitives/**,.storybook/**\"`" | A | `STORYBOOK_SKILL_AUTO_LOAD_PATHS` | Derive |
| 14 | Saturday-ritual cross-ref | "design-debt sweep batched on Saturday (see memory `project_saturday_design_ritual`)" | C | `DESIGN_DEBT_RITUAL_PATH` | Scaffold opt-in `/dotclaude:setup-design-debt-ritual` |

### 1.18 — `rules/design-north-star.md` (~16 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Tier 1 north star | "Telegram + Apple iOS 26" | A | `TIER_1_BENCHMARKS` | Q-B1 |
| 2 | Surface comparator | "Apple Music, Photos, Messages, Telegram, Wallet" | A | `USER_DEVICE_COMPARATOR_APPS` | Subset of TIER_1 |
| 3 | Tab bar primitive | "Native `UITabBar` (Liquid Glass pill, floating, refractive). `<NativeTabs>`" | A | `NATIVE_TAB_BAR_PRIMITIVE_NAME` | Q-F2 |
| 4 | Cards/list rows ref | "Apple Settings rows, Telegram settings rows" | A | `LIST_ROW_REFERENCE` | Default by platform |
| 5 | Chrome surface ref | "Telegram-iOS-style solid neutral card + hairline border" | A | `CHROME_SURFACE_REFERENCE` | Default by platform |
| 6 | Sheets ref | "UIKit-native bottom sheets with **solid** dark background" | A | `SHEET_REFERENCE` | Default by platform |
| 7 | Modal alerts ref | "Apple's iOS 26 `UIAlertController` aesthetic" | A | `MODAL_ALERT_REFERENCE` | Default by platform |
| 8 | Empty states ref | "Apple Photos memories — never apologize, always teach or invite" | A | `EMPTY_STATE_REFERENCE` | Default; ask Q-B2 |
| 9 | Motion ref | "UIKit spring physics, never linear. Reanimated 4 spring presets only" | A | `MOTION_LANGUAGE_PRIMITIVES` | Q-F2c |
| 10 | Color discipline | "iOS 26 system colors (semantic tokens). One accent (cyan), one destructive, everything else neutral grays" | A | `BRAND_ACCENT_COLOR` + `COLOR_DISCIPLINE_RULE` | Q-F2 |
| 11 | Typography ref | "Apple's system fonts (SF Pro on iOS) for chrome. Onest is acceptable for content" | A | `TYPOGRAPHY_SYSTEM` | Q-F3 |
| 12 | Iconography rule | "SF Symbols on iOS chrome (`<NativeTabs.Trigger.Icon sf=\"...\" />`). Lucide is the FALLBACK" | A | `ICONOGRAPHY_RULE` | Default by platform |
| 13 | Anti-pattern — RN-rendered tab bar | "Custom RN-rendered chrome trying to fake iOS — every attempt fails" | A | `ANTI_PATTERNS_LIST` | Default by platform |
| 14 | Anti-pattern — expo-blur | "`expo-blur` with custom tints — it's the legacy `UIBlurEffect` API" | A | (same) | Default by platform |
| 15 | Anti-pattern — material You | "'Material You' / Android-y card stacking" | A | (same) | Default by platform |
| 16 | Per-surface evolution notes | "v3 is solid; UIGlassEffect rolled back on dark canvas" | A | `PER_SURFACE_EVOLUTION_NOTES` | Skip greenfield |

### 1.19 — `rules/design-audit-routing.md` (~12 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Audit agent inventory | "`ux-reviewer / flow-ux-reviewer / flow-auditor / pages-audit / interaction-audit / a11y-audit / design-token-auditor / product-designer / /ruthless-ux-autoloop / /flow-ux-audit`" | B | `AUDIT_AGENT_INVENTORY` | Derive from kit composition |
| 2 | Typical-question phrasings | "'Is this one screen visually polished / S-tier?' / 'Do these N screens hold together as one experience?' / …" | B | `TYPICAL_QUESTION_SHAPES` | Universal templates |
| 3 | Refusal behaviors per agent | "product-designer refuses single-screen polish / copy tweaks → recommends ux-reviewer" | B | `REFUSAL_BEHAVIOR_TABLE_PER_AGENT` | Universal default |
| 4 | Canonical pipeline order | "1. design-token-auditor → 2. interaction-audit + a11y-audit || → 3. ux-reviewer" | B | `CANONICAL_PIPELINE_ORDER` | Universal |
| 5 | Multi-screen extension | "add `flow-auditor` BEFORE step 1, `flow-ux-reviewer` AFTER step 3" | B | (same) | Universal |
| 6 | Multi-section extension | "For the 5 owner tabs specifically — add `pages-audit` between step 2 and step 3" | A | `MULTI_SECTION_PRIMARY_SURFACE` | Q-D2 |
| 7 | Shared skills table | "design-system / quality-bar / app-state-navigation / journey-audit / element-reuse-check / persona-lens" | B | `SHARED_SKILL_INVENTORY` | Derive from kit |
| 8 | Cross-rubric translation | "S/A/B/C/D/F ↔ Crit/High/Med/Low ↔ S0/S1/S2" | B | `CROSS_RUBRIC_TRANSLATION_TABLE` | Universal default |
| 9 | Crit > visual rule | "a single Crit-class gap from `flow-auditor` OR `a11y-audit` blocks ship regardless of `ux-reviewer`'s overall grade" | B | `CRIT_OVERRIDES_VISUAL_RULE` | Universal |
| 10 | Hooks-prevent-findings table | "`check-token-only.sh` / `check-forbidden-phrases.sh` / `check-file-size.sh` / `check-vertical-boundary.sh`" | A | `HOOK_INVENTORY` | Derive from kit |
| 11 | Override syntax | "Override per-line: `// allow-color: <reason>` / `// allow-forbidden: <reason>`" | B | `HOOK_OVERRIDE_SYNTAX` | Universal default |
| 12 | "fix the hook" framing | "If you find yourself dispatching `design-token-auditor` to find raw hex, ask first: did `check-token-only.sh` fire on the offending edit?" | B | universal | universal |

### 1.20 — `rules/visual-verification.md` (~13 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Device detection | "`ps aux \| grep \"expo run\"`" | A | `DEVICE_TARGET_DETECT_COMMAND` | Q-A2 |
| 2 | Sim capture cmd | "`xcrun simctl io <udid> screenshot /tmp/sim-now.png`" | A | `CAPTURE_COMMAND_PRIMARY` | Q-A2 |
| 3 | Physical iPhone cap | "`bash scripts/iphone-screenshot.sh /tmp/iphone-now.png` then `Read`" | A | `CAPTURE_COMMAND_PHYSICAL_DEVICE` | Q-A2b (opt-in) |
| 4 | Physical tap | "`bash scripts/iphone-tap.sh --predicate \"label == 'Photos'\"`" | A | `PHYSICAL_DEVICE_TAP_COMMAND` | derive |
| 5 | Physical type | "`bash scripts/iphone-type.sh \"text\"`" | A | `PHYSICAL_DEVICE_TYPE_COMMAND` | derive |
| 6 | List-items | "`iphone-list-items.sh`" | A | `PHYSICAL_DEVICE_LIST_COMMAND` | derive |
| 7 | One-time WDA bootstrap | "`bash scripts/start-tunneld.sh` (sudo, Trust prompt) → `bash scripts/start-wda.sh`" | A | `PHYSICAL_DEVICE_BOOTSTRAP_COMMANDS` | derive |
| 8 | Sim hierarchy cmd | "`maestro --device <udid> hierarchy --compact \| head -200`" | A | `HIERARCHY_INSPECTION_COMMAND_CHEAP` | Q-A2 |
| 9 | MCP inspect cost | "`mcp__maestro__inspect_screen` returns the entire view hierarchy as JSON — 5–20k tokens" | A | `MCP_VS_CLI_COST_DELTA` | Universal default |
| 10 | Token-discipline rule | "do I need the *whole* hierarchy, or one specific element?" | B | `TOKEN_DISCIPLINE_PRINCIPLE` | Universal |
| 11 | RN console.log gotcha | "`console.log` from React Native code goes to Metro's stdout, not `os_log`" | A | `LOG_INSPECTION_PATH` | Default by platform |
| 12 | Capture-then-skip-read | "Returns a path, not bytes. Claude burns image tokens only when you `Read /tmp/sim-now.png`" | B | `CAPTURE_THEN_READ_PATTERN` | Universal |
| 13 | "Never present UI you haven't visually verified" | binding rule | B | universal | universal |

### 1.21 — `rules/forbidden-phrases.txt` (~10 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Per-line phrase format | one phrase per line | B | `FORBIDDEN_PHRASES_FILE_FORMAT` | Universal |
| 2 | Comment syntax | "`#` comments" | B | (same) | Universal |
| 3 | Override syntax | "`greeting: \"Hi, developer\",  // allow-forbidden: meet-assistant intro`" | B | `OVERRIDE_COMMENT_SYNTAX` | Universal default |
| 4 | Exempt-file pattern | "Or in `app/wizard/meet-assistant.tsx` (auto-exempt)" | A | `ASSISTANT_INTRO_EXEMPT_FILE` | Q-C2 (intro path) |
| 5 | Universal AI-slop denials | "Hi / Hello / Hey there" | B | `UNIVERSAL_FORBIDDEN_PHRASES` | Universal default |
| 6 | Self-introduction patterns | "I'm Assistant / My name is Assistant / I'm your gym's intelligence / Let me introduce / Meet Assistant" | A | `BRAND_FORBIDDEN_PHRASES` (self-intro tier) | Q-C2/C4 |
| 7 | Welcome-as-stranger | "Welcome / Welcome to ProductName" | A | (same) | Q-C4 |
| 8 | Onboarding-register on daily | "Let's get started / Let's begin / Get started / Here's how this works / Let me show you around / First, let me explain" | B | `ONBOARDING_REGISTER_FORBIDDEN_ON_DAILY` | Universal default |
| 9 | Customer-service register | "I'm here to help / How can I help / Is there anything else / Sorry to interrupt / Sorry, that didn't work / Oops" | B | `CUSTOMER_SERVICE_REGISTER_FORBIDDEN` | Universal default |
| 10 | Persona-doc cross-ref | "Authoritative source for: docs/design-system/persona.md, .claude/hooks/check-forbidden-phrases.sh" | C | `PERSONA_DOC_PATH` | Scaffold opt-in (Q-C3 follow-up) |

### 1.22 — `rules/frontend-components.md` (~5 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Auto-load paths | "`paths: \"app/**/*.tsx,lib/*/components/**\"`" | A | `FRONTEND_RULE_AUTO_LOAD_PATHS` | Derive |
| 2 | Page wrapper names | "OwnerPage / OwnerPageHeader / OwnerPageContent" | A | `SHARED_PAGE_WRAPPER_NAMES` | Default empty greenfield |
| 3 | Component search paths | "`components/ui/` and `lib/*/components/`" | A | `COMPONENT_SEARCH_PATHS` | Default by framework |
| 4 | Hook search paths | "`lib/*/hooks/`" | A | `HOOK_SEARCH_PATHS` | Default by framework |
| 5 | Inline-wrapper rule | "No inline wrappers around stable callbacks — pass `useCallback` refs directly as props" | B | `MEMOIZATION_DISCIPLINE_RULE` | Universal default |

### 1.23 — `hooks/check-forbidden-phrases.sh` (~9 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Source-of-truth path | "`$CLAUDE_PROJECT_DIR/.claude/rules/forbidden-phrases.txt`" | A | `FORBIDDEN_PHRASES_FILE_PATH` | Universal default |
| 2 | Filter to TS/TSX | "case \"$f\" in *.ts\|*.tsx" | A | `ENFORCED_FILE_EXTENSIONS` | Default by language |
| 3 | Auto-exempt file | "*app/wizard/meet-assistant.tsx" | A | `ASSISTANT_INTRO_EXEMPT_FILE` | Q-C2 |
| 4 | Generic exemptions | "*__tests__* / *.test.* / *.spec.* / *__snapshots__* / *.gen.ts / *database.types.ts" | A | `GENERIC_EXEMPT_PATHS` | Default |
| 5 | Enforcement file patterns | "*/translations/*.ts / */narration/*.ts / */copy/*.ts / *Assistant* / *assistant* / *Companion* / *Narration*" | A | `ENFORCEMENT_FILE_PATH_PATTERNS` | Derive from translation paths + assistant name |
| 6 | Override comment | "`// allow-forbidden`" | A | `OVERRIDE_COMMENT_SYNTAX` | Universal |
| 7 | Match pattern | "`['\"][^'\"]*\b(${phrases})\b[^'\"]*['\"]`" | B | `MATCH_PATTERN_GENERATOR` | Universal default |
| 8 | Error message | "BLOCKED: $f contains forbidden Assistant phrase(s)" | A | `BLOCK_MESSAGE_TEMPLATE` | Derive |
| 9 | Persona doc link | "Persona doc: docs/design-system/persona.md §\"Forbidden phrases\"" | C | `PERSONA_DOC_PATH` | Scaffold opt-in |

### 1.24 — `hooks/check-token-only.sh` (~7 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Theme dir exempt | "*lib/theme/*" | A | `THEME_FILE_EXEMPT_PATH` | Q-F1 |
| 2 | CLAUDE.md citation | "CLAUDE.md \"Theme tokens only\" rule" | C | `EXISTING_CLAUDE_MD` | Scaffold opt-in |
| 3 | Generic exemptions | "*__tests__* / *.test.* / *.gen.ts / *database.types.ts / *scripts/*" | A | `GENERIC_EXEMPT_PATHS` | Default |
| 4 | Raw color patterns | "`['\"]#[0-9a-fA-F]{3,8}['\"]\|rgba?\\([0-9]`" | A | `RAW_COLOR_PATTERNS` | Default; varies by styling system |
| 5 | Override comment | "`// allow-color`" | A | `OVERRIDE_COMMENT_SYNTAX` | Universal |
| 6 | Token-import example | "bg-primary, text.tertiary, color.accent" | A | `TOKEN_USAGE_EXAMPLES` | Derive |
| 7 | Companion-agent ref | "The design-token-auditor agent does periodic sweeps — this hook prevents new violations at edit time" | A | `HOOK_INVENTORY` | Derive |

### 1.25 — `hooks/check-nativetabs-sf-icon.sh` (~6 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Component pattern | "`NativeTabs\\.Trigger\\.Icon`" | A | `PLATFORM_CHROME_ICON_COMPONENT` | Default by platform |
| 2 | Required prop | "`sf=`" | A | `PLATFORM_SYSTEM_ICON_PROP` | Default by platform |
| 3 | Override syntax | "`// allow-sf`" | A | `OVERRIDE_COMMENT_SYNTAX` | Universal |
| 4 | Block message ref | "iOS chrome icons MUST be SF Symbols" | A | `ICONOGRAPHY_RULE_REF` | Derive |
| 5 | Fallback note | "Lucide is the FALLBACK for Android + content icons" | A | `ICON_FALLBACK_LIBRARY` | Default by platform |
| 6 | Hook applies only to platform | "Only enforce on iOS surfaces" | A | `HOOK_APPLIES_WHEN` | Default: `PRIMARY_SURFACE_PLATFORM = iOS` |

### 1.26 — `hooks/check-no-expo-blur.sh` (~5 non-generic elements)

| # | Element | Verbatim | Cat | Knob | Greenfield strategy |
|---|---|---|---|---|---|
| 1 | Legacy package name | "`expo-blur`" | A | `LEGACY_BLUR_PACKAGE` | Default by platform |
| 2 | Modern primitive name | "`<GlassCard>`" | A | `MODERN_GLASS_PRIMITIVE_NAME` | Q-F2 |
| 3 | Modern primitive path | "`lib/widgets/primitives/GlassCard.tsx`" | A | `MODERN_GLASS_PRIMITIVE_PATH` | Q-F2 |
| 4 | Override syntax | "`// allow-blur`" | A | `OVERRIDE_COMMENT_SYNTAX` | Universal |
| 5 | Modern API ref | "wraps real iOS 26 UIGlassEffect (with UIBlurEffect fallback pre-26)" | A | `MODERN_GLASS_API_NAME` | Default by platform |

**Total non-generic elements extracted: 401** across 26 artifacts. Median per artifact ~15; max 38 (`product-designer.md`); min 5 (`check-no-expo-blur.sh`, `frontend-components.md`).

---

## 2. The expanded knob taxonomy (Phases A–M, 78 knobs)

This extends the existing 53-knob list. Knobs marked **NEW** were not in the prior analysis. Knobs marked **GREENFIELD-RECAST** had an existing definition but their capture method changes substantially in greenfield mode.

### Phase A — Platform + tooling (8 knobs)

```
KNOB: PRIMARY_SURFACE_PLATFORM
  Type: enum
  Category: A
  Possible values: iOS | Android | iOS+Android | web | desktop-macOS | desktop-Windows | desktop-Linux | desktop-cross-platform | CLI | TUI | browser-extension | multi
  Default for greenfield: must ask
  Feeds artifacts: ux-reviewer, interaction-audit, a11y-audit, flow-auditor, pages-audit, product-designer, design-system, design-north-star.md, visual-verification.md, check-nativetabs-sf-icon.sh, check-no-expo-blur.sh
  Capture method: Phase A Q-A1
  Scaffolding: n/a

KNOB: CAPTURE_COMMAND_PRIMARY
  Type: string (shell command)
  Category: A
  Possible values: `xcrun simctl io <udid> screenshot <path>` | `adb exec-out screencap -p > <path>` | `playwright screenshot <url> <path>` | `screencapture <path>` | …
  Default for greenfield: derived from platform (table); confirm in summary
  Feeds artifacts: every audit agent, visual-verification.md, product-designer
  Capture method: Phase A Q-A2 with platform-default proposal

KNOB: CAPTURE_COMMAND_PHYSICAL_DEVICE  (GREENFIELD-RECAST)
  Type: string or "N/A"
  Category: A
  Default for greenfield: "N/A" — opt-in only
  Feeds artifacts: ux-reviewer, interaction-audit, a11y-audit, flow-auditor, pages-audit, product-designer, visual-verification.md
  Capture method: Phase A Q-A2b ("Do you ever audit on a physical device?"). If yes, scaffold via /dotclaude:setup-physical-device-scripts.
  Scaffolding: if iOS + physical device → opt-in scaffold for the WDA-based iphone-*.sh script suite

KNOB: HIERARCHY_INSPECTION_COMMAND
  Type: string
  Category: A
  Possible values: `maestro --device <udid> hierarchy --compact` | Chrome DevTools a11y tree | `axe-core` JSON | `uiautomator dump` | "none"
  Default for greenfield: derived from platform + automation tool
  Feeds artifacts: ux-reviewer, interaction-audit, a11y-audit, pages-audit, product-designer, visual-verification.md
  Capture method: Phase A Q-A2 with default

KNOB: DEVICE_TARGET_DETECT_COMMAND
  Type: string
  Category: A
  Default for greenfield: derived from platform (`ps aux | grep "expo run"` for RN/Expo; "always sim" for web)
  Feeds artifacts: every audit agent
  Capture method: Phase A Q-A2 with default

KNOB: LOG_INSPECTION_PATH
  Type: string
  Category: A
  Default for greenfield: derived from platform
  Feeds artifacts: visual-verification.md
  Capture method: Phase A Q-A2 (optional follow-up)

KNOB: DEV_LOOP_TOOL
  Type: enum
  Category: A
  Possible values: Metro | Vite | Webpack | Turbopack | esbuild | Docker compose | native rebuild | none
  Default for greenfield: must ask; default by Phase 1 scan if package.json exists
  Feeds artifacts: visual-verification.md, flow-ux-audit
  Capture method: Phase A Q-A2

KNOB: INTERACTION_TOOL_INVENTORY  (NEW)
  Type: list
  Category: B
  Possible values: Maestro MCP tools | Playwright MCP tools | computer-use MCP | none
  Default for greenfield: derived from platform's automation tool
  Feeds artifacts: ux-reviewer, interaction-audit, flow-auditor, product-designer (tool inventory in agent frontmatter)
  Capture method: Phase A Q-A3
```

### Phase B — Benchmarks (6 knobs)

```
KNOB: TIER_1_BENCHMARKS
  Type: list of 2-3 named apps with "what to steal" per each
  Category: A
  Default for greenfield: derived by platform table (iOS → "Apple iOS 26 chrome + Telegram"; web SaaS → "Linear + Stripe + Vercel"; CLI → "gh + lazygit + htop"); user confirms
  Feeds artifacts: ux-reviewer, interaction-audit, a11y-audit, flow-ux-reviewer, pages-audit, product-designer, design-system, design-north-star.md, quality-bar, ruthless-ux-autoloop
  Capture method: Phase B Q-B1
  Scaffolding: n/a

KNOB: TIER_2_BENCHMARKS_WITH_DIMENSION
  Type: list tagged with dimension
  Category: A
  Default for greenfield: must ask (per-surface-category, where surface categories are derived from `SURFACES_PRESENT`)
  Feeds artifacts: ux-reviewer, flow-ux-reviewer, pages-audit, product-designer, design-system, design-north-star.md, quality-bar, ruthless-ux-autoloop
  Capture method: Phase B Q-B2

KNOB: ANTI_REFERENCES
  Type: list of named products / patterns
  Category: A
  Default for greenfield: must ask; offer 4-5 platform-typical starter rejections (e.g. iOS RN: "Material You / Android-y card stacking")
  Feeds artifacts: product-designer, design-north-star.md, quality-bar
  Capture method: Phase B Q-B3

KNOB: BRIDGE_REFERENCE_APPS
  Type: list
  Category: A
  Default for greenfield: derived ("Apple iCloud onboarding, Telegram phone-number flow, Stripe checkout post-payment" for product-iOS; "Apple Music Now Playing transitions" subset)
  Feeds artifacts: flow-ux-reviewer, flow-auditor
  Capture method: Phase B Q-B2b (optional)

KNOB: USER_DEVICE_COMPARATOR_APPS  (NEW)
  Type: list
  Category: A
  Description: The apps already on the user's device that the product gets compared against by reflex
  Default for greenfield: subset of TIER_1_BENCHMARKS
  Feeds artifacts: design-north-star.md
  Capture method: Derived from Q-B1

KNOB: A_TIER_BENCHMARK_REFERENCES  (NEW)
  Type: list
  Category: A
  Description: A-tier (not S) benchmarks. Subset of TIER_2 — apps that are clearly intentional but don't reach Apple/Telegram parity.
  Default for greenfield: derived from TIER_2
  Feeds artifacts: quality-bar
  Capture method: Derived
```

### Phase C — Voice + character (8 knobs)

```
KNOB: PRODUCT_HAS_VOICE
  Type: boolean
  Category: A
  Default for greenfield: must ask
  Feeds: persona-lens, forbidden-phrases.txt, check-forbidden-phrases.sh, journey-audit, product-designer
  Capture method: Phase C Q-C1
  Gates: Q-C2 through Q-C5

KNOB: IN_PRODUCT_ASSISTANT_CHARACTER
  Type: { has: bool, name: str, introSurfacePath: str }
  Category: A
  Default for greenfield: { has: false }
  Feeds: journey-audit, persona-lens, forbidden-phrases.txt, check-forbidden-phrases.sh, ux-reviewer (daily-driver-trap), flow-ux-reviewer
  Capture method: Phase C Q-C2
  Scaffolding: if has=true → ask intro-surface-path; if doesn't exist yet, offer to scaffold app/wizard/meet-<assistant>.tsx stub

KNOB: BRAND_VOICE_REFERENCE
  Type: string
  Category: A
  Default for greenfield: must ask
  Feeds: persona-lens
  Capture method: Phase C Q-C3

KNOB: VOICE_ANTI_REFERENCES
  Type: list
  Category: A
  Default for greenfield: ship 4 universal defaults (customer-service / apology / performance / tutorial); user confirms or extends
  Feeds: persona-lens
  Capture method: Phase C Q-C4

KNOB: BRAND_FORBIDDEN_PHRASES
  Type: list
  Category: A
  Default for greenfield: ship 4 universal categories (greeting-as-stranger / self-introduction / welcome-as-stranger / customer-service-register); user adds project-specific
  Feeds: forbidden-phrases.txt, check-forbidden-phrases.sh, persona-lens
  Capture method: Phase C Q-C4

KNOB: USAGE_FREQUENCY_FRAMING
  Type: enum
  Category: A
  Possible values: daily-driver-day-30 | transactional-single-use | weekly-tool | monthly-tool | power-user-daily
  Default for greenfield: derived from USER_PERSONA_TYPE + PRODUCT_TYPE
  Feeds: persona-lens
  Capture method: Phase C Q-C5 (or derived)

KNOB: PERSONA_TRIAD  (NEW)
  Type: 3-tuple of named tests
  Category: B
  Default for greenfield: ("Day-30", "Partner", "Stranger") — universal default for daily-driver products
  Override examples: ("First-run", "Power-user", "Regression-debugger") for dev-tools; ("Skimmer", "Focused", "Reference") for doc sites
  Feeds: persona-lens
  Capture method: Phase C Q-C5 (only ask if user wants to override default)

KNOB: ASSISTANT_INTRO_EXEMPT_FILE  (NEW)
  Type: file path or "N/A"
  Category: A
  Default for greenfield: if IN_PRODUCT_ASSISTANT_CHARACTER.has=true → scaffold "app/wizard/meet-<assistant>.tsx" or equivalent for the platform
  Feeds: persona-lens, check-forbidden-phrases.sh
  Capture method: Derived from Q-C2; scaffold via /dotclaude:setup-assistant-intro-surface
  Scaffolding: opt-in
```

### Phase D — Personas + audience (5 knobs)

```
KNOB: USER_PERSONA_TYPE
  Type: enum
  Category: A
  Possible values: B2C consumer | B2B SaaS user | dev-tool user | enterprise admin | internal user
  Default for greenfield: must ask
  Feeds: quality-bar, product-designer, product-compass, persona-lens (triad override)
  Capture method: Phase D Q-D1

KNOB: PROD_VS_INTERNAL
  Type: enum
  Category: A
  Possible values: production-user-facing | internal-only | mixed
  Default for greenfield: must ask (default: production-user-facing)
  Feeds: ux-reviewer, a11y-audit, quality-bar, forbidden-phrases.txt
  Capture method: Phase D Q-D2

KNOB: DEMO_TEST_AUDIENCE
  Type: string (specific imaginable audience)
  Category: A
  Default for greenfield: must ask; offer 4 starter patterns ("first customer I'm trying to recruit", "a journalist", "a CTO at a target enterprise", "a designer whose taste I respect")
  Feeds: quality-bar
  Capture method: Phase D Q-D3

KNOB: USER_FACING_AUDIENCE_NAMES  (NEW)
  Type: list of audience labels
  Category: A
  Description: e.g. "owner-facing / member-facing" — the labels the rest of the kit uses for surface scoping
  Default for greenfield: derived from USER_PERSONA_TYPE (B2B SaaS → "admin-facing / end-user-facing"; B2C consumer → "user-facing"; dev-tool → "user-facing / contributor-facing")
  Feeds: every UI agent's surface scoping; pages-audit; quality-bar
  Capture method: Phase D Q-D1b (with default)

KNOB: PRODUCT_DESCRIPTOR  (NEW)
  Type: string (10-25 words)
  Category: A
  Description: One-sentence product description that gets reused in every agent's role framing
  Default for greenfield: must ask; format: "<product type> for <persona> doing <core action>"
  Feeds: ux-reviewer, interaction-audit, a11y-audit, flow-auditor, product-designer, product-compass, design-system
  Capture method: Phase D Q-D4
```

### Phase E — Surfaces + architecture (8 knobs)

```
KNOB: MULTI_SCREEN_ARCS_EXIST
  Type: boolean
  Category: A
  Default for greenfield: ask; default true for most product types
  Feeds: flow-auditor, flow-ux-reviewer, flow-ux-audit, ruthless-ux-autoloop, journey-audit, element-reuse-check, product-designer
  Capture method: Phase E Q-E1
  Gates: ARC_INVENTORY + 4 audit agents shipping at all

KNOB: ARC_INVENTORY
  Type: list of named arcs
  Category: A
  Default for greenfield: empty (no arcs exist yet); scaffold a starter "first-run onboarding" stub when project ships first arc
  Feeds: flow-auditor, flow-ux-audit, journey-audit
  Capture method: Phase E Q-E1 (greenfield: probably empty; design-time later)

KNOB: MULTI_SECTION_PRIMARY_SURFACE
  Type: { has: bool, sections: [{name, route, file, testID}] }
  Category: A
  Default for greenfield: { has: false }
  Feeds: pages-audit (gates shipping at all)
  Capture method: Phase E Q-E2
  Greenfield: pages-audit DOES NOT SHIP until this becomes true (user re-runs interview when they reach the multi-section structure)

KNOB: SURFACE_DIR_STRUCTURE
  Type: list of glob paths
  Category: A
  Default for greenfield: derived from framework convention (Expo Router → "app/**/*.tsx"; Next.js → "app/**" + "pages/**"; Vite + RR → "src/routes/**")
  Feeds: journey-audit, flow-auditor, product-designer
  Capture method: Phase E Q-E3 (with default proposal)

KNOB: TRANSLATION_FILE_LOCATIONS
  Type: list of glob paths
  Category: A
  Default for greenfield: empty (no copy files yet)
  Feeds: journey-audit, element-reuse-check, persona-lens, check-forbidden-phrases.sh
  Capture method: Phase E Q-E3 (default empty greenfield)

KNOB: NARRATION_FILE_LOCATIONS  (NEW — split from TRANSLATION)
  Type: list of glob paths
  Category: A
  Default for greenfield: empty; ask if IN_PRODUCT_ASSISTANT_CHARACTER.has=true
  Feeds: persona-lens, check-forbidden-phrases.sh
  Capture method: Phase E Q-E3b

KNOB: SURFACES_PRESENT  (NEW)
  Type: list of surface categories
  Category: A
  Description: Which surface categories the product has — onboarding / dashboard / settings / empty-state / detail / form / list / chart / chat / etc. Drives which Tier-2 references are needed.
  Default for greenfield: must ask (small enumeration of 6-10 categories user checks); used to drive Q-B2 per-category prompts
  Feeds: TIER_2_BENCHMARKS_WITH_DIMENSION capture
  Capture method: Phase E Q-E4

KNOB: HAS_GENERATIVE_SURFACES  (NEW)
  Type: boolean
  Category: A
  Description: Does the product have AI-driven surfaces showing live progress (specs being generated, jobs running)? Gates the STATE_CLARITY_DIMENSIONS + semantic-count audit features.
  Default for greenfield: ask; default false
  Feeds: ruthless-ux-autoloop (gen-surface checklist), flow-ux-reviewer (state-clarity)
  Capture method: Phase E Q-E5
```

### Phase F — Design system (13 knobs)

```
KNOB: DESIGN_SYSTEM_MATURITY
  Type: enum
  Category: A
  Possible values: none | partial | mature
  Default for greenfield: "none"
  Feeds: design-token-auditor, check-token-only.sh, design-system, pages-audit
  Capture method: Phase F Q-F1

KNOB: DESIGN_SYSTEM_TOKENS_PATH
  Type: file path
  Category: A
  Default for greenfield: scaffold default "lib/theme/tokens.ts" (RN), "src/styles/tokens.css" (web), "tokens.json" (cross-platform); user confirms or overrides
  Feeds: design-token-auditor, check-token-only.sh, design-system, a11y-audit
  Capture method: Phase F Q-F1 + scaffold via /dotclaude:setup-token-system
  Scaffolding: opt-in starter tokens file with 12 semantic colors + spacing scale + 3 shadow presets

KNOB: THEME_CONVENTION
  Type: enum
  Category: A
  Possible values: semantic-token | palette | CSS-variable | Tailwind | Tailwind+NativeWind | SCSS | styled-components | Emotion | CSS-modules | vanilla-extract | RN StyleSheet
  Default for greenfield: must ask; offer 3 most common per platform
  Feeds: design-token-auditor, design-system, storybook-story
  Capture method: Phase F Q-F1

KNOB: STYLING_SYSTEM_IN_USE  (NEW — was implicit)
  Type: enum
  Category: A
  Possible values: Tailwind utility classes | NativeWind | RN StyleSheet | CSS Modules | styled-components | Emotion | vanilla-extract | inline-styles
  Default for greenfield: derived from THEME_CONVENTION + framework
  Feeds: design-token-auditor (raw color pattern set), check-token-only.sh
  Capture method: Derived

KNOB: THEME_GENERATION_COMMAND
  Type: string or "none"
  Category: A
  Default for greenfield: "none" (no generation step yet)
  Feeds: design-system
  Capture method: Phase F Q-F1c (only ask if DESIGN_SYSTEM_MATURITY=mature)

KNOB: NATIVE_CHROME_PRIMITIVES_LIST
  Type: list of named primitives
  Category: A
  Default for greenfield: empty (no primitives wrapped yet)
  Feeds: design-system, design-north-star.md, pages-audit
  Capture method: Phase F Q-F2 (greenfield: empty list with platform-specific default recommendations e.g. "consider wrapping NativeTabs / UIGlassEffect / BottomSheetModal once you need them")

KNOB: CHROME_PRIMITIVE_PATHS
  Type: map (primitive name → file path)
  Category: A
  Default for greenfield: empty
  Feeds: design-system, pages-audit
  Capture method: Phase F Q-F2

KNOB: MOTION_LIBRARY
  Type: enum
  Category: A
  Possible values: Reanimated 4 | Reanimated 3 | Framer Motion | CSS transitions | Web Animations API | native UIKit-Compose | none
  Default for greenfield: must ask
  Feeds: flow-auditor, a11y-audit, design-system
  Capture method: Phase F Q-F2c

KNOB: ANIMATION_PRESET_FILE_PATH
  Type: file path or "none"
  Category: A
  Default for greenfield: "none" (no presets file yet); scaffold "lib/theme/patterns.ts" or equivalent as part of token-system setup
  Feeds: design-system
  Capture method: Phase F Q-F2c

KNOB: STATUS_COLOR_SYSTEM
  Type: table (status × color × icon)
  Category: A
  Default for greenfield: ship 6-row default (success / warning / error / pending / info / disabled with platform-typical color+icon mapping); user confirms or adapts
  Feeds: design-system
  Capture method: Phase F Q-F2d (with default)

KNOB: SURFACE_HIERARCHY_LEVELS  (NEW)
  Type: ordered list of layer names with bg/border/shadow specs
  Category: B
  Default for greenfield: 5-level default (Background / Card / Sheet / Elevated card / Frosted glass) — universal
  Feeds: design-system
  Capture method: Universal default; override only on Q-F2 follow-up

KNOB: TYPOGRAPHY_SYSTEM  (NEW)
  Type: { chrome_font, content_font, scale_method }
  Category: A
  Default for greenfield: derived by platform (iOS chrome = SF Pro; web SaaS = Inter; etc.); content font = ask
  Feeds: design-north-star.md, design-system
  Capture method: Phase F Q-F3

KNOB: BRAND_ACCENT_COLOR  (NEW)
  Type: string (token name + value)
  Category: A
  Default for greenfield: must ask (or "cyan" platform-default starter)
  Feeds: design-token-auditor (S-tier discipline), design-system, design-north-star.md
  Capture method: Phase F Q-F2
```

### Phase G — Accessibility (5 knobs)

```
KNOB: A11Y_COMPLIANCE_TARGET
  Type: enum
  Category: A
  Possible values: WCAG 2.2 AA | WCAG 2.2 AAA | Section 508 | App Store guidelines | none-explicit-but-care | none
  Default for greenfield: "WCAG 2.2 AA" if PROD_VS_INTERNAL=production-user-facing; "none" if internal-only
  Feeds: a11y-audit (gates shipping)
  Capture method: Phase G Q-G1

KNOB: HIT_TARGET_MINIMUM_PT
  Type: number + unit
  Category: A
  Default for greenfield: inferred from platform (44pt iOS / 48dp Android / 44px web touch / 24px web mouse-only)
  Feeds: a11y-audit
  Capture method: Inferred from Phase A; user override possible

KNOB: DYNAMIC_TYPE_UPPER_BOUND_PERCENT
  Type: number
  Category: A
  Default for greenfield: inferred (310 iOS / 200 Android / user-set web)
  Feeds: a11y-audit
  Capture method: Inferred

KNOB: LABEL_API
  Type: string
  Category: A
  Default for greenfield: inferred (accessibilityLabel iOS/RN; aria-label web; contentDescription Android)
  Feeds: a11y-audit
  Capture method: Inferred

KNOB: REDUCED_MOTION_HOOK_PATH
  Type: string
  Category: A
  Default for greenfield: inferred from MOTION_LIBRARY
  Feeds: a11y-audit, design-system
  Capture method: Inferred
```

### Phase H — Knowledge graph + docs conventions (12 knobs, mostly NEW)

```
KNOB: EXISTING_CLAUDE_MD
  Type: file path or "none"
  Category: C
  Default for greenfield: "none"
  Feeds: product-compass, product-designer
  Capture method: Phase 1 scan (brownfield) / Phase H Q-H1 (greenfield)
  Scaffolding: /dotclaude:setup-claude-md — guided template authoring with sections (product framing / how-you-work / task classification / constraints / DoD)

KNOB: BRAINSTORM_DOC_PATH_CONVENTION
  Type: string template
  Category: C
  Default for greenfield: "docs/brainstorms/YYYY-MM-DD-<slug>-brainstorm.md"
  Feeds: product-designer
  Capture method: Phase H Q-H2
  Scaffolding: /dotclaude:setup-brainstorm-docs — creates `docs/brainstorms/` + a sample template

KNOB: SPEC_DOC_PATH_CONVENTION
  Type: string template
  Category: C
  Default for greenfield: "docs/brainstorms/YYYY-MM-DD-<slug>-design.md" (alongside brainstorm)
  Feeds: product-designer
  Capture method: Phase H Q-H2
  Scaffolding: pairs with brainstorm setup

KNOB: AUDIT_REPORT_PATH_CONVENTION
  Type: string template
  Category: C
  Default for greenfield: "docs/audits/YYYY-MM-DD-<slug>-<type>-audit.md"
  Feeds: every audit agent
  Capture method: Phase H Q-H2
  Scaffolding: /dotclaude:setup-audit-docs — creates `docs/audits/` + README explaining the convention

KNOB: FLOW_DOC_PATH_CONVENTION
  Type: string template
  Category: C
  Default for greenfield: "docs/flows/<arc-slug>.md"
  Feeds: flow-auditor
  Capture method: Phase H Q-H2
  Scaffolding: /dotclaude:setup-flow-docs — only if MULTI_SCREEN_ARCS_EXIST=true

KNOB: CAPABILITY_MAP_PATH  (NEW for greenfield)
  Type: file path or "none"
  Category: C
  Default for greenfield: "none"
  Feeds: product-designer (capability-delta requirement)
  Capture method: Phase H Q-H3
  Scaffolding: /dotclaude:setup-capability-map — creates docs/product/capabilities.md with stable-ID template (O.1 owner / M.1 user / S.1 shared) + 2-week-review framing in CLAUDE.md

KNOB: PRODUCT_VISION_DOCS  (GREENFIELD-RECAST)
  Type: list of file paths
  Category: C
  Default for greenfield: "none" — most greenfield projects don't have vision docs
  Feeds: product-compass
  Capture method: Phase H Q-H3
  Scaffolding: /dotclaude:setup-vision-docs — optional CLAUDE.md "Vision" section + memory templates for project_core_vision

KNOB: PROTOTYPE_GATES_PATH  (NEW for greenfield)
  Type: file path or "none"
  Category: C
  Default for greenfield: "none"
  Feeds: product-designer, flow-auditor, quality-bar
  Capture method: Phase H Q-H3
  Scaffolding: /dotclaude:setup-strategy-lens — creates .claude/rules/prototype-gates.md from template (with placeholders for project-specific gate names)

KNOB: BINDING_MEMORIES_FOR_FORBIDDEN_PATTERNS  (NEW for greenfield)
  Type: list of memory file names
  Category: C
  Default for greenfield: "none"; populated only after first audit cycle surfaces a recurring pattern
  Feeds: flow-auditor, journey-audit, persona-lens
  Capture method: Skip greenfield; surface during post-audit retro
  Scaffolding: /dotclaude:setup-binding-memories — explains the pattern + provides 2 starter memory templates

KNOB: APP_STATE_NAVIGATION_SKILL_EXISTS  (NEW for greenfield)
  Type: boolean
  Category: C
  Default for greenfield: false
  Feeds: ux-reviewer, interaction-audit, a11y-audit, flow-auditor, pages-audit, product-designer (recipe catalog references)
  Capture method: skip / opt-in
  Scaffolding: /dotclaude:setup-app-state-navigation — creates empty skill stub at .claude/skills/app-state-navigation/SKILL.md with the "recipe catalog" frame; user adds recipes as project grows

KNOB: DESIGN_DEBT_RITUAL_PATH  (NEW for greenfield)
  Type: file path or "none"
  Category: C
  Default for greenfield: "none"
  Feeds: storybook-story (cross-ref)
  Capture method: Phase H Q-H4 (optional)
  Scaffolding: /dotclaude:setup-design-debt-ritual — creates docs/design-debt/registry.md + Saturday cadence doc

KNOB: PERSONA_DOC_PATH  (NEW for greenfield)
  Type: file path or "none"
  Category: C
  Default for greenfield: "none"
  Feeds: forbidden-phrases.txt, check-forbidden-phrases.sh
  Capture method: Phase C Q-C3 follow-up
  Scaffolding: /dotclaude:setup-persona-doc — creates docs/design-system/persona.md with brand voice + forbidden phrases sections
```

### Phase I — Process + tooling (5 knobs)

```
KNOB: TEST_FRAMEWORK
  Type: enum
  Category: A
  Possible values: Jest | Vitest | pytest | cargo test | go test | RSpec | none
  Default for greenfield: must ask; default by language
  Feeds: indirect (Phase-1 scan exempt patterns in hooks)
  Capture method: Phase I Q-I1

KNOB: VISUAL_VERIFICATION_TOOL
  Type: enum or list
  Category: A
  Possible values: Maestro | Playwright | Cypress | Puppeteer | xcrun simctl io (CLI only) | manual | WDA-based physical device scripts
  Default for greenfield: derived from platform
  Feeds: every audit agent, flow-ux-audit, visual-verification.md
  Capture method: Phase I Q-I2

KNOB: LINT_INFRASTRUCTURE  (NEW)
  Type: enum
  Category: A
  Possible values: ESLint | RuboCop | Clippy | Ruff | Prettier-only | none
  Default for greenfield: derived from package.json (Phase 1) or asked
  Feeds: design-token-auditor (hook companion ref), quality-bar (done preconditions)
  Capture method: Phase 1 scan + Q-I1

KNOB: FILE_SIZE_CEILING_LOC  (NEW)
  Type: number
  Category: A
  Default for greenfield: 1000 LOC (universal default — already in other parts of the kit via check-file-size.sh)
  Feeds: storybook-story (skill cross-ref), CLAUDE.md template
  Capture method: Universal default; override via Q-I3

KNOB: HOOK_OVERRIDE_SYNTAX  (NEW)
  Type: comment template
  Category: B
  Default for greenfield: "// allow-<class>: <one-sentence reason>" (universal)
  Feeds: all 4 hooks
  Capture method: Universal default
```

### Phase J — Bug history (6 knobs, all SKIP-GREENFIELD)

```
KNOB: PAST_BUGS_BY_SHA
  Greenfield: SKIP — empty list; surface after 4-6 weeks of audit cycles produce examples

KNOB: PAST_DEAD_CHROME_SHAS
  Greenfield: SKIP

KNOB: PAST_A11Y_BUG_SHAS
  Greenfield: SKIP

KNOB: PAST_TOKEN_DRIFT_SHAS
  Greenfield: SKIP

KNOB: PAST_ARC_BUG_SHAS
  Greenfield: SKIP

KNOB: PROJECT_FAILURE_PATTERNS  (NEW — distinct from bug SHAs)
  Type: list of named recurring failure patterns
  Category: A
  Default for greenfield: empty; example pattern surfaces from binding memory ritual after a few audit cycles
  Feeds: product-designer (self-audit framing), interaction-audit, flow-auditor
  Capture method: Greenfield = empty; scaffold via binding-memories ritual
```

### Phase K — Composition + scope decisions (8 knobs)

```
KNOB: MODEL_TIER_DEFAULT
  Type: enum
  Category: A
  Default for greenfield: claude-opus-4-7 (universal default)
  Feeds: every high-effort agent's frontmatter
  Capture method: Phase K Q-K1

KNOB: MODEL_TIER_LIGHTWEIGHT
  Type: enum
  Category: A
  Default for greenfield: claude-haiku-4-5 (universal default; used by design-token-auditor)
  Feeds: design-token-auditor
  Capture method: Phase K Q-K1

KNOB: CANONICAL_PIPELINE_ORDER  (NEW — was implicit in audit-routing)
  Type: ordered list
  Category: B
  Default for greenfield: "design-token-auditor → interaction-audit + a11y-audit (parallel) → ux-reviewer" with arc/section extensions
  Feeds: design-audit-routing.md, every audit agent
  Capture method: Universal default

KNOB: CROSS_RUBRIC_TRANSLATION_TABLE  (NEW)
  Type: 6-tier mapping
  Category: B
  Default for greenfield: universal default (S↔Crit↔S0 mapping)
  Feeds: design-audit-routing.md, product-compass, ruthless-ux-autoloop
  Capture method: Universal default

KNOB: GRADING_SCALE
  Type: enum
  Category: A
  Default for greenfield: S/A/B/C/D/F (universal)
  Feeds: every audit agent
  Capture method: Universal default; override in summary

KNOB: SEVERITY_TAXONOMY
  Type: list of severity levels
  Category: A
  Default for greenfield: Crit / High / Med / Low (universal)
  Feeds: flow-auditor, ux-reviewer, interaction-audit, a11y-audit, etc.
  Capture method: Universal default

KNOB: QUALITY_GRADE_TARGETS_BY_SURFACE
  Type: map
  Category: A
  Default for greenfield: must ask; default pattern: "core flows = S, secondary = A, settings/admin = B ok"
  Feeds: quality-bar, ux-reviewer, flow-ux-reviewer
  Capture method: Phase D Q-D3 follow-up

KNOB: QUALITY_BAR_REGISTER
  Type: enum
  Category: A
  Possible values: defensive (block-on-not-S) | offensive (ship-and-iterate) | bar-by-surface
  Default for greenfield: bar-by-surface
  Feeds: quality-bar, ux-reviewer
  Capture method: Phase D Q-D3
```

### Phase L — State + test data scaffolding (5 knobs, mostly NEW for greenfield)

```
KNOB: SEED_FIXTURE_MECHANISM
  Type: command(s) + per-tier mapping
  Category: A
  Default for greenfield: "none"
  Feeds: flow-auditor, pages-audit, ruthless-ux-autoloop, flow-ux-audit, product-designer
  Capture method: Phase L Q-L1
  Greenfield: most projects have no seed pipeline; skill ships with stub guidance

KNOB: DATA_SHAPE_PROBE_INTERFACE
  Type: enum
  Category: A
  Possible values: Supabase MCP | psql | direct API | none
  Default for greenfield: "none"
  Feeds: product-designer (Step 3)
  Capture method: Phase L Q-L2

KNOB: FIXTURE_RESET_COMMAND
  Type: command
  Category: A
  Default for greenfield: "none"
  Feeds: ruthless-ux-autoloop (mandatory)
  Capture method: Phase L Q-L1
  Gates: ruthless-ux-autoloop ships only if this is set OR user explicitly accepts "use last good state"

KNOB: BACKEND_TRUTH_PROBE_QUERIES  (NEW)
  Type: list of SQL/API templates
  Category: A
  Default for greenfield: empty
  Feeds: ruthless-ux-autoloop (Layer 3)
  Capture method: Phase L Q-L3 (only if HAS_GENERATIVE_SURFACES=true)

KNOB: SAFETY_INVARIANTS  (NEW)
  Type: list of never-edit paths
  Category: A
  Default for greenfield: universal default (migrations / package.json / generated files / fixture files)
  Feeds: ruthless-ux-autoloop
  Capture method: Phase L Q-L4 (with default)
```

### Phase M — Strategy + vision (5 knobs, mostly Cat C)

```
KNOB: ARCHITECTURE_LAYER_PRIORITY
  Type: ordered list
  Category: A
  Default for greenfield: "simple" (single-layer); user defines if architecture warrants
  Feeds: product-compass
  Capture method: Phase M Q-M1 (optional)

KNOB: CORE_DIFFERENTIATORS_LIST  (NEW — was implicit in product-compass)
  Type: list of named moats / differentiators
  Category: A
  Default for greenfield: must ask; default empty
  Feeds: product-compass
  Capture method: Phase M Q-M2

KNOB: DRIFT_SIGNALS  (NEW)
  Type: list of per-project antipatterns to scan for
  Category: A
  Default for greenfield: empty; populated post-audit
  Feeds: product-compass
  Capture method: Skip greenfield; populated over time

KNOB: PROTOTYPE_GATE_NAMES  (NEW)
  Type: list of project-specific gate names
  Category: A
  Default for greenfield: empty unless strategy-lens scaffolded
  Feeds: flow-auditor, product-designer, quality-bar
  Capture method: Comes via /dotclaude:setup-strategy-lens scaffold

KNOB: USER_STANDING_PRINCIPLE  (NEW)
  Type: string (the one-line user principle the autoloop terminates against)
  Category: A
  Default for greenfield: "Polished UX with every element having a purpose and within the entire composition" (universal default)
  Feeds: ruthless-ux-autoloop
  Capture method: Phase M Q-M3 (or universal default)
```

**Total knobs: 78.** Distribution: 56 Category A (project-specific value), 11 Category B (universal structure), 11 Category C (knowledge-graph scaffolding). Of the 78: ~12 are universally-defaulted (Category B + a few B-leaning A knobs); ~30 are derived/inferred from a handful of seed answers (platform + persona + voice); ~25 require explicit user input; ~11 are Category C scaffolding decisions.

---

## 3. The greenfield interview blueprint

**Mode-branched.** Phase 0 establishes greenfield vs brownfield; everything downstream branches. The greenfield path is longer (25-30 min vs 15-20 min) because there's nothing to confirm — every knob with `Capture method: Phase 1 scan` in the brownfield interview becomes either "ask the user" or "default ship, confirm in summary."

**Estimated total: 24-30 minutes for full greenfield.** Justifies the trade — this is project-DNA-level configuration that lives in the repo for months. The user is making the up-front investment to avoid re-explaining their project to every Claude session for the next 6+ months.

### Phase 0 — Mode declaration (1 Q, 1 knob)

#### Q-0 — Greenfield or brownfield?

> "Is this a brand-new project (greenfield — no code, or just a fresh scaffold) or an existing codebase with some history (brownfield)? Greenfield means I'll ask more questions because I can't scan an existing tokens file / git log / surface inventory."

**Drives**: `PROJECT_MATURITY = greenfield | brownfield`. Mode-branches everything downstream:

- **Brownfield** → existing interview (skip-and-confirm based on Phase 1 scan); ~15-20 min.
- **Greenfield** → this blueprint; ~25-30 min.

Default if user is unsure: ask `git log --oneline | wc -l`. If < 5 commits AND no `tokens.*` / `theme.*` / `CLAUDE.md` files → greenfield.

### Phase A — Platform + tooling (2 Qs, ~8 knobs) — estimated 3 min

#### Q-A1 — Primary surface platform

> "What's the primary surface this project ships? iOS, Android, web (browser), desktop (native), CLI/TUI, browser extension, embedded?"

Drives: `PRIMARY_SURFACE_PLATFORM`, `HIT_TARGET_MINIMUM_PT`, `LABEL_API`, `DYNAMIC_TYPE_UPPER_BOUND_PERCENT` (all platform-inferred). If multi, ask which to prioritize.

#### Q-A2 — Capture, hierarchy, dev-loop (3-part)

> "Three quick ones: (a) which platform automation tool do you use or plan to use — Maestro / Playwright / Cypress / Puppeteer / manual? (b) Do you ever audit on a physical device (and if yes, what's the screenshot command)? (c) What's your dev-loop / hot-reload setup — Metro, Vite, webpack, Docker compose, native rebuild?"

Drives: `CAPTURE_COMMAND_PRIMARY` (derived from platform + automation), `CAPTURE_COMMAND_PHYSICAL_DEVICE`, `HIERARCHY_INSPECTION_COMMAND`, `DEVICE_TARGET_DETECT_COMMAND`, `DEV_LOOP_TOOL`, `LOG_INSPECTION_PATH`, `INTERACTION_TOOL_INVENTORY`. Ship platform-defaults; user confirms in summary.

If physical-device path: confirm whether they want `/dotclaude:setup-physical-device-scripts` to scaffold the WDA-based iphone-*.sh suite.

### Phase B — Benchmarks (3 Qs, ~6 knobs) — estimated 5 min, **most load-bearing phase**

#### Q-B1 — Tier 1 chrome benchmarks

> "Name 2-3 apps you benchmark **chrome** against — the apps your users already have on their device, that your product gets compared to by reflex. 'When I look at my screen and then look at App X, which one tells me my chrome is wrong?'"

Drives: `TIER_1_BENCHMARKS`, `USER_DEVICE_COMPARATOR_APPS`. If user says "we don't really benchmark," push once: *"What app on your device do you think is well-designed?"*

Defaults to offer if user is stuck (platform table):
- iOS consumer → Apple iOS 26 + Telegram
- Web SaaS → Linear + Stripe + Vercel
- Dev tool → Linear + Raycast + Things 3
- B2B dashboard → Linear + Stripe + Datadog
- CLI / TUI → gh + lazygit + htop

#### Q-B2 — Tier 2 domain benchmarks (with dimension) — driven by SURFACES_PRESENT

> "Walking the surfaces your product has — for each one, which app do you grade against? Onboarding? Empty states? Lists? Charts? Forms? Search? Chat?"

Drives: `TIER_2_BENCHMARKS_WITH_DIMENSION`, `BRIDGE_REFERENCE_APPS`, `SURFACES_PRESENT`. The **dimension is load-bearing** — "we like Notion" useless; "Notion for inline editing affordances" enforceable.

Skip for surfaces the project doesn't have. For greenfield, build from a small enumeration of common surface categories (6-10 checks).

#### Q-B3 — Anti-references

> "Apps the design should **NOT** look like? Aesthetics or patterns explicitly rejected?"

Drives: `ANTI_REFERENCES`. Offer 3-4 platform-typical starters if user stuck (e.g. iOS: "Material You / Android-y card stacking," "Cluttered Material 2 SaaS dashboards").

### Phase C — Voice + character (5 Qs, ~8 knobs; collapse if PRODUCT_HAS_VOICE=false) — estimated 4 min

#### Q-C1 — Brand voice gate

> "Does the product have an authored voice the team enforces, or is copy purely functional? Three checks: (1) Is there a brand voice doc / style guide? (2) Pick 3 adjectives. (3) Show me one phrasing from a real surface that nails the voice. (Greenfield: 'aspirational adjectives + a reference voice' if no real surface yet.)"

Drives: `PRODUCT_HAS_VOICE`, adjective triad. **If false, skip C2-C5.**

#### Q-C2 — In-product assistant character

> "Does the product have (or plan to have) a named in-product assistant character — an AI helper, a mascot, a personality the product wears? If yes — name and (for greenfield: planned) intro-surface path."

Drives: `IN_PRODUCT_ASSISTANT_CHARACTER`, `ASSISTANT_INTRO_EXEMPT_FILE`. If has=true, flag the daily-driver-vs-first-touch trap.

If intro surface doesn't exist yet: offer `/dotclaude:setup-assistant-intro-surface` to scaffold `app/wizard/meet-<assistant>.tsx` or platform-equivalent.

#### Q-C3 — Brand voice reference

> "Whose voice does this product aspire to sound like? Name a specific reference — an app's empty-state voice / a character from a film / a specific company's product voice."

Drives: `BRAND_VOICE_REFERENCE`. Offer to scaffold `docs/design-system/persona.md` via `/dotclaude:setup-persona-doc`.

#### Q-C4 — Voice anti-references + forbidden phrases

> "What tones do you actively reject? ('I'm here to help', apology, performance, tutorial-explainer?) And any phrases you'd NEVER want in user-facing copy?"

Drives: `VOICE_ANTI_REFERENCES`, `BRAND_FORBIDDEN_PHRASES`, `USAGE_FREQUENCY_FRAMING` (inferred from product type).

Ship 4 universal categories (greeting / self-intro / welcome / customer-service) regardless; user adds project-specific.

#### Q-C5 — Persona triad override (optional)

> "The default persona-lens triad is Day-30 / Partner / Stranger — works for daily-driver products. Override for: dev-tools (First-run / Power-user / Regression-debugger), doc sites (Skimmer / Focused / Reference), other?"

Drives: `PERSONA_TRIAD`. Default unless user opts to override.

### Phase D — Personas + audience (4 Qs, ~5 knobs) — estimated 3 min

#### Q-D1 — User persona

> "Who's your user? (B2C consumer / B2B SaaS user / dev-tool user / enterprise admin / internal-only?) And what's the natural surface label — 'user-facing' / 'owner-facing + member-facing' / 'admin + end-user' / etc.?"

Drives: `USER_PERSONA_TYPE`, `USER_FACING_AUDIENCE_NAMES`.

#### Q-D2 — Production posture

> "Is this production-user-facing, internal-only, or mixed?"

Drives: `PROD_VS_INTERNAL`. Internal-only skips Phase G entirely.

#### Q-D3 — Demo audience + quality posture

> "Who would you demo a polished change to — be specific. Name the role or person. And — is your quality posture defensive ('block if not S-tier') or offensive ('ship and iterate'), or bar-by-surface?"

Drives: `DEMO_TEST_AUDIENCE`, `QUALITY_BAR_REGISTER`, `QUALITY_GRADE_TARGETS_BY_SURFACE`.

#### Q-D4 — Product descriptor (1-sentence)

> "In one sentence, what does this product do? Format: '<product type> for <persona> doing <core action>'."

Drives: `PRODUCT_DESCRIPTOR`. Gets reused in every agent's role framing — extra-load-bearing.

### Phase E — Surfaces + architecture (5 Qs, ~8 knobs) — estimated 4 min

#### Q-E1 — Multi-screen arcs

> "Does (or will) the project have multi-screen arcs — onboarding, checkout, setup wizard, multi-step task? Name any planned arcs."

Drives: `MULTI_SCREEN_ARCS_EXIST`, `ARC_INVENTORY` (greenfield: usually empty until arcs ship). Gates `flow-auditor` / `flow-ux-reviewer` / `flow-ux-audit` shipping.

#### Q-E2 — Multi-section primary surface

> "Does (or will) the project have a primary multi-section surface — 3+ tabs / panels / dashboard sections that should feel consistent? Names + routes + file paths if it exists."

Drives: `MULTI_SECTION_PRIMARY_SURFACE`. Greenfield default: `{ has: false }` — pages-audit DOES NOT ship until this surface exists. User can re-run interview later to enable.

#### Q-E3 — Surface dir structure + translation/narration locations

> "Where do screens / routes / pages live in the codebase (or where will they)? Where do copy / translation / narration files live (if applicable)?"

Drives: `SURFACE_DIR_STRUCTURE` (default by framework), `TRANSLATION_FILE_LOCATIONS`, `NARRATION_FILE_LOCATIONS`. Greenfield: copy/translation usually empty.

#### Q-E4 — Surfaces present (drives Q-B2 reverse)

> "Which surface categories does (or will) your product have? Check all: onboarding / dashboard / settings / empty-state / detail view / form / list / chart / chat / search / data-viz / map / camera/AR / video / table / sidebar nav?"

Drives: `SURFACES_PRESENT`. Used to drive Q-B2 reverse — only ask for Tier-2 references for surfaces the product has.

#### Q-E5 — Generative surfaces

> "Does (or will) the product have AI-driven surfaces that show live progress — specs being generated, jobs running, partial states with retries?"

Drives: `HAS_GENERATIVE_SURFACES`. Gates the state-clarity audit dimension + semantic-count audit + backend-truth probe features.

### Phase F — Design system (3 Qs, ~13 knobs) — estimated 5 min

#### Q-F1 — Token system

> "Three quick ones: (a) Where do (or will) your design tokens / theme values live — file path? (b) What styling convention — Tailwind / NativeWind / RN StyleSheet / CSS-Modules / styled-components / SCSS / vanilla-extract / inline? (c) Light + dark mode both supported?"

Drives: `DESIGN_SYSTEM_TOKENS_PATH`, `DESIGN_SYSTEM_MATURITY`, `THEME_CONVENTION`, `STYLING_SYSTEM_IN_USE`, `LIGHT_AND_DARK_MODE_BOTH`, `THEME_GENERATION_COMMAND`.

If tokens file doesn't exist: offer `/dotclaude:setup-token-system` — scaffolds starter file with 12 semantic colors + spacing scale + 3 shadow presets.

#### Q-F2 — Native chrome primitives + brand accent + status colors

> "Two parts: (a) Which native chrome primitives have you wrapped (tab bars / glass cards / bottom sheets / confirm dialogs) — or planned? (b) Brand accent color (one — be disciplined) + status color system (success/warning/error/pending mapping)?"

Drives: `NATIVE_CHROME_PRIMITIVES_LIST`, `CHROME_PRIMITIVE_PATHS`, `BRAND_ACCENT_COLOR`, `STATUS_COLOR_SYSTEM`. Greenfield: primitive list usually empty; ship platform-typical recommendations.

Ship 6-row default for status colors (success / warning / error / pending / info / disabled); user confirms.

#### Q-F3 — Motion + animation + typography

> "Three: (a) What's your animation library (Reanimated / Framer / CSS / native)? (b) Animation presets file path (or 'none')? (c) Chrome font + content font?"

Drives: `MOTION_LIBRARY`, `ANIMATION_PRESET_FILE_PATH`, `TYPOGRAPHY_SYSTEM`. Greenfield: presets file probably empty; scaffold via token-system setup.

### Phase G — Accessibility (1 Q, ~5 knobs) — estimated 1 min, skip if PROD_VS_INTERNAL=internal-only

#### Q-G1 — A11y compliance target

> "What's your accessibility compliance target? WCAG 2.2 AA / AAA / Section 508 / App Store guidelines / 'none-explicit-but-care'?"

Drives: `A11Y_COMPLIANCE_TARGET`. Hit-target / Dynamic Type / Label API are platform-inferred. Reduced-motion hook is inferred from `MOTION_LIBRARY`.

### Phase H — Knowledge graph + docs conventions (4 Qs + scaffold decisions, ~12 knobs) — estimated 5 min (mostly scaffold opt-ins)

#### Q-H1 — Audit / flow / spec / brainstorm doc path conventions

> "Where do (or will) audit reports / flow docs / spec docs / brainstorm docs land? Universal defaults: `docs/audits/YYYY-MM-DD-<slug>-audit.md`, `docs/flows/<slug>.md`, `docs/brainstorms/YYYY-MM-DD-<slug>-design.md`. Confirm or override."

Drives: `AUDIT_REPORT_PATH_CONVENTION`, `FLOW_DOC_PATH_CONVENTION`, `SPEC_DOC_PATH_CONVENTION`, `BRAINSTORM_DOC_PATH_CONVENTION`. Greenfield: usually accept defaults; scaffold the convention via mini-skills.

#### Q-H2 — Scaffold opt-ins (multi-choice)

> "Which knowledge-graph scaffolds do you want? Mark Y/N/?:
> - **CLAUDE.md** at project root (product framing, DoD, constraints) — recommended
> - **`docs/brainstorms/`** convention + sample template — recommended if MULTI_SCREEN_ARCS or new-feature work expected
> - **`docs/audits/`** convention + README — recommended (audit agents land here)
> - **`docs/flows/`** convention — only if MULTI_SCREEN_ARCS_EXIST
> - **`docs/product/capabilities.md`** (capability map) — recommended if PROD_VS_INTERNAL=production-user-facing
> - **`docs/design-system/persona.md`** — recommended if PRODUCT_HAS_VOICE
> - **`.claude/rules/prototype-gates.md`** (strategy lens) — optional; useful for early-stage products with clear gates
> - **`.claude/skills/app-state-navigation/`** (recipe catalog stub) — useful when audits need to drive app to specific states
> - **`docs/design-debt/registry.md`** (Saturday-ritual cadence) — optional
> - **Vision docs** memory templates — optional"

Drives all Category C scaffold knobs. Each Y triggers the corresponding `/dotclaude:setup-<name>` mini-skill.

#### Q-H3 — Vision docs path (if scaffolded)

> "If you said Y to vision-docs scaffolding: any existing vision docs to link, or all from-scratch?"

Drives: `PRODUCT_VISION_DOCS`.

#### Q-H4 — Test framework + Storybook

> "Test framework (Jest / Vitest / pytest / cargo test / RSpec / none)? Storybook configured (`@storybook/react-vite` / `@storybook/react-webpack` / 'none')?"

Drives: `TEST_FRAMEWORK`, `STORYBOOK_FRAMEWORK`, `STORYBOOK_TITLE_CONVENTION` (greenfield: derived `UI/<Name>` default), `STORYBOOK_DARK_DEFAULT` (default true if RN).

### Phase I — Process + tooling (1 Q, ~5 knobs) — estimated 1 min

#### Q-I1 — Lint + visual verification + file size

> "Three quick confirmations: (a) Lint tool (ESLint / RuboCop / Clippy / Ruff / Prettier-only / none)? (b) Confirm visual verification tool from Q-A2. (c) File-size ceiling — default 1000 LOC per file. Override?"

Drives: `LINT_INFRASTRUCTURE`, `VISUAL_VERIFICATION_TOOL` (confirm), `FILE_SIZE_CEILING_LOC`.

### Phase J — Git mining (1 Q greenfield-mode) — estimated 1 min

#### Q-J1 — Greenfield = skip mining; brownfield = surface 8-12 candidate SHAs

> Greenfield branch: *"You're greenfield — no git log to mine yet. I'll surface anti-pattern candidates after your first 4-6 weeks of audit cycles produce examples. For now, the kit ships with universal pattern examples in each agent."*

Drives: nothing in greenfield. Brownfield: as before.

### Phase K — Composition + scope decisions (2 Qs, ~8 knobs) — estimated 2 min

#### Q-K1 — Model tier

> "Default model tier for high-effort audit agents? (claude-opus-4-7 is the universal default; pinning to sonnet is the budget-conscious choice.) And the lightweight tier for mechanical sweeps (default haiku-4-5)?"

Drives: `MODEL_TIER_DEFAULT`, `MODEL_TIER_LIGHTWEIGHT`.

#### Q-K2 — Iterative-polish caps (only if ruthless-ux-autoloop ships)

> "Iteration caps for the autoloop — defaults 10 hard / 6 soft?"

Drives: `ITERATION_CAP_HARD`, `ITERATION_CAP_SOFT`.

### Phase L — State + test data scaffolding (2 Qs, ~5 knobs) — estimated 1 min greenfield

#### Q-L1 — Seed fixture mechanism

> "How does (or will) the app get into specific data states for testing/auditing? Seed scripts / fixture accounts / mock-mode env vars / URL params / 'use last good state' / 'none'?"

Drives: `SEED_FIXTURE_MECHANISM`, `FIXTURE_RESET_COMMAND`. Greenfield default: "none."

#### Q-L2 — Data-shape probe + safety invariants (combined)

> "Two: (a) Data-shape probe interface (Supabase MCP / psql / direct API / 'none')? (b) Safety invariants — default never-edit list is migrations / package.json / generated files / fixture files. Override?"

Drives: `DATA_SHAPE_PROBE_INTERFACE`, `SAFETY_INVARIANTS`.

If `HAS_GENERATIVE_SURFACES=true`, follow-up Q-L3 for `BACKEND_TRUTH_PROBE_QUERIES` (or accept empty and let user populate later).

### Phase M — Strategy + vision (3 Qs optional, ~5 knobs) — estimated 2 min, skippable

#### Q-M1 — Architecture layer priority (optional)

> "Architectural layer priority — when features compete for time, which layer wins? 'simple' if single-axis (most products); else name the layers in priority order."

Drives: `ARCHITECTURE_LAYER_PRIORITY`. Default: "simple."

#### Q-M2 — Core differentiators

> "What are your core differentiators / moats — 2-4 named claims, each with a 1-sentence test?"

Drives: `CORE_DIFFERENTIATORS_LIST`. Greenfield: usually empty until product matures.

#### Q-M3 — Standing UX principle

> "Default standing principle: 'Polished UX with every element having a purpose and within the entire composition.' Confirm or replace."

Drives: `USER_STANDING_PRINCIPLE`.

### Total estimate

| Phase | Topic | Qs | Knobs | Time | Skip if… |
|---|---|---|---|---|---|
| 0 | Mode declaration | 1 | 1 | <1 min | — |
| A | Platform + tooling | 2 | 8 | 3 min | — |
| B | Benchmarks | 3 | 6 | 5 min | — |
| C | Voice + character | 5 | 8 | 4 min | PRODUCT_HAS_VOICE=false |
| D | Personas + audience | 4 | 5 | 3 min | — |
| E | Surfaces + architecture | 5 | 8 | 4 min | — |
| F | Design system | 3 | 13 | 5 min | — |
| G | Accessibility | 1 | 5 | 1 min | PROD_VS_INTERNAL=internal-only |
| H | Knowledge graph + docs | 4 + scaffold | 12 | 5 min | — |
| I | Process + tooling | 1 | 5 | 1 min | — |
| J | Git mining | 1 (skip) | 6 | <1 min | greenfield |
| K | Composition + scope | 2 | 8 | 2 min | — |
| L | State + test data | 2 | 5 | 1 min | — |
| M | Strategy + vision | 3 (opt) | 5 | 2 min | early-stage |
| **Total greenfield** | | **~37 Qs** | **78 knobs** | **~26 min** | |

37 questions is more than 18, but batched into ~6-8 super-questions per the interview UX. The key Phase 0 branch keeps brownfield projects at the previous 18-Q / 15-20 min cost.

### Summary turn (mandatory before authoring)

Format same as brownfield, with greenfield-specific additions:

```
**Project maturity**: greenfield
**Platform**: <iOS / web / etc.>
**Capture path**: <command>
**Tier 1 chrome**: <2-3 apps>
**Tier 2 domain**: <2-3 apps + dimensions>
**Anti-references**: <list>
**Voice**: <characterization or 'functional-only'>
**In-product character**: <name + planned intro file / no>
**Multi-screen arcs**: <planned list or 'no'>
**Multi-section primary surface**: <planned list or 'no'>
**Design system maturity**: none
**Tokens path (proposed)**: <file>
**Native primitives**: empty (planned via opt-in)
**Compliance target**: <WCAG AA / etc.>
**Demo audience**: <specific role/person>

**SCAFFOLDS YOU APPROVED:**
- [ ] CLAUDE.md template at project root
- [ ] docs/brainstorms/ + sample
- [ ] docs/audits/ + README
- [ ] docs/flows/ (if arcs)
- [ ] docs/product/capabilities.md (capability map)
- [ ] docs/design-system/persona.md
- [ ] .claude/rules/prototype-gates.md
- [ ] .claude/skills/app-state-navigation/ stub
- [ ] docs/design-debt/registry.md
- [ ] starter tokens.ts (12 semantic colors + spacing + shadows)
- [ ] assistant intro file at app/wizard/meet-<assistant>.tsx
- [ ] physical-device script suite

**About to author the kit:**
- Agents: <list — ux-reviewer, a11y-audit, interaction-audit, design-token-auditor, [flow-auditor], [pages-audit deferred], [product-designer], [flow-ux-reviewer], [product-compass]>
- Skills: <list — journey-audit, element-reuse-check, persona-lens, quality-bar, design-system, [iterative-polish-autoloop deferred]>
- Rules: <list — design-north-star, audit-routing, visual-verification, [forbidden-phrases]>
- Hooks: <list — check-design-tokens, [check-forbidden-phrases], [check-no-legacy-blur], [check-platform-icons]>
- Deferred: <list — pages-audit if multi-section ships later; flow-ux-audit if Maestro/equivalent set up later>

Confirm to proceed?
```

---

## 4. Scaffolding decisions (Category C knowledge-graph)

13 distinct scaffolding decisions. Each is an opt-in `/dotclaude:setup-<name>` mini-skill that creates the missing concept + adds a CLAUDE.md section (or memory template) cross-referencing it.

### Scaffold-1: `/dotclaude:setup-claude-md`

- **What**: Walks user through authoring a CLAUDE.md at project root.
- **Why**: 6 agents + 2 skills cross-reference "CLAUDE.md" — the kit assumes the project has one. Greenfield projects often don't.
- **Opt-in question**: "Want me to walk you through authoring a CLAUDE.md template? Sections: product framing / how-you-work / task classification / constraints / DoD."
- **Default if accepted**: 5-section template (~80 LOC) with placeholders filled from interview answers.

### Scaffold-2: `/dotclaude:setup-brainstorm-docs`

- **What**: Creates `docs/brainstorms/` + sample brainstorm doc + adds CLAUDE.md cross-ref.
- **Why**: `product-designer` reads "active brainstorm doc" as Step 1. Without convention, designer agent has nothing to read.
- **Opt-in**: "Set up `docs/brainstorms/YYYY-MM-DD-<slug>-brainstorm.md` convention for design exploration?"
- **Default**: Empty dir + `docs/brainstorms/README.md` explaining the convention + sample template.

### Scaffold-3: `/dotclaude:setup-audit-docs`

- **What**: Creates `docs/audits/` + README + cross-ref in CLAUDE.md.
- **Why**: Every audit agent writes here. Without convention, audits land in random locations.
- **Opt-in**: "Set up `docs/audits/YYYY-MM-DD-<slug>-<type>-audit.md` convention?"
- **Default**: Empty dir + README explaining the convention.

### Scaffold-4: `/dotclaude:setup-flow-docs`

- **What**: Creates `docs/flows/` + README, only if `MULTI_SCREEN_ARCS_EXIST=true`.
- **Why**: `flow-auditor` produces canonical flow docs there. Useless without convention.
- **Opt-in**: "Set up `docs/flows/<arc-slug>.md` convention?"
- **Default**: Empty dir + README.

### Scaffold-5: `/dotclaude:setup-capability-map`

- **What**: Creates `docs/product/capabilities.md` template with stable-ID format (O.1 owner / M.1 user / S.1 shared) + 2-week review cadence in CLAUDE.md.
- **Why**: `product-designer` requires "capability delta" in spec doc Section 1. Conformance matrices reference capability IDs. Without a map, the requirement is undefined.
- **Opt-in**: "Set up a capability map at `docs/product/capabilities.md`? It's the WHAT-the-product-does layer between vision and code — referenced by spec docs and audits via stable IDs (O.1, M.1, etc.)."
- **Default**: ~40 LOC template with 3-5 starter capability stubs per audience tier (O / M / S) + format docs.

### Scaffold-6: `/dotclaude:setup-vision-docs`

- **What**: Optional CLAUDE.md "Vision" section + memory templates for project_core_vision / project_mcp_vision / etc.
- **Why**: `product-compass` reads vision docs every invocation. Without them, the agent has nothing to align against.
- **Opt-in**: "Want vision docs scaffolding? Adds a Vision section to CLAUDE.md + memory templates Claude can populate as you decide things."
- **Default**: CLAUDE.md gains a "Product identity" section + `~/.claude/projects/.../memory/project_core_vision.md` template.

### Scaffold-7: `/dotclaude:setup-strategy-lens`

- **What**: Creates `.claude/rules/prototype-gates.md` from template with placeholders for project-specific gate names.
- **Why**: `flow-auditor` reads "which gate this arc serves" + `product-designer` requires "prototype gate served." Without it, the requirement is undefined.
- **Opt-in**: "Set up a strategy lens at `.claude/rules/prototype-gates.md`? It's where you name your prototype gates (e.g. 'self-dogfood / friend-onboarded / scaling') so design specs and audits can reference them."
- **Default**: ~30 LOC template with 3 named gate stubs + per-gate "what passing looks like" framing.

### Scaffold-8: `/dotclaude:setup-persona-doc`

- **What**: Creates `docs/design-system/persona.md` with brand voice + forbidden phrases + voice-anti-references sections.
- **Why**: `check-forbidden-phrases.sh` references the persona doc in its error message. `persona-lens` skill cross-refs it.
- **Opt-in**: "Set up `docs/design-system/persona.md` — brand voice + forbidden phrases + voice anti-references?"
- **Default**: ~30 LOC template populated from C1-C4 answers.

### Scaffold-9: `/dotclaude:setup-token-system`

- **What**: Scaffolds starter token file at `lib/theme/tokens.ts` (or platform-appropriate path) with 12 semantic colors (light + dark variants) + spacing scale (xs/sm/md/lg/xl/2xl) + 3 shadow presets + 5 animation presets.
- **Why**: `design-token-auditor` + `check-token-only.sh` + `design-system` skill all assume token file exists.
- **Opt-in**: "Set up a starter tokens file with 12 semantic colors, spacing scale, shadow + animation presets? Customize colors after, or accept the iOS-26-tone defaults."
- **Default**: ~100 LOC tokens.ts file + (if NativeWind) tailwind.config.js stub.

### Scaffold-10: `/dotclaude:setup-app-state-navigation`

- **What**: Creates `.claude/skills/app-state-navigation/SKILL.md` empty recipe catalog stub.
- **Why**: 5 agents reference the recipe catalog. Without it, agents can't drive the app to specific states; they reinvent navigation each time.
- **Opt-in**: "Set up an `app-state-navigation` skill — empty recipe catalog you populate as you build out flows? Agents reference it to drive the app to specific states (e.g. 'Status S2 / mid-wizard / walk-tag entry')."
- **Default**: Empty SKILL.md template + 2 starter recipes (fresh-user / authenticated-user).

### Scaffold-11: `/dotclaude:setup-binding-memories`

- **What**: Creates 2 starter memory templates explaining the binding-memory pattern: when a class of bug surfaces multiple times, capture as memory; agents cite it as "Crit-class gap automatically."
- **Why**: `flow-auditor` reads "memory rules bind your audit." Without memories, the binding rule is dead code.
- **Opt-in**: "Set up the binding-memories pattern? Adds 2 starter memory templates + CLAUDE.md cross-ref explaining when memories become binding rules in audits."
- **Default**: ~20 LOC explainer + 2 memory templates (feedback_X.md + project_Y.md format).

### Scaffold-12: `/dotclaude:setup-design-debt-ritual`

- **What**: Creates `docs/design-debt/registry.md` + Saturday-ritual doc + CLAUDE.md cross-ref.
- **Why**: `storybook-story` skill cross-refs the ritual. Useful for periodic design-quality cadence.
- **Opt-in**: "Set up the Saturday design-debt ritual? Weekly cadence: Friday-night audit → Saturday batch sheet → user marks F/D/?/X → implement during week. Adds `docs/design-debt/registry.md`."
- **Default**: ~30 LOC ritual doc + empty registry table.

### Scaffold-13: `/dotclaude:setup-assistant-intro-surface`

- **What**: Scaffolds `app/wizard/meet-<assistant>.tsx` (or platform-appropriate path) + adds to `ASSISTANT_INTRO_EXEMPT_FILE` knob + updates `check-forbidden-phrases.sh` exempt-file pattern.
- **Why**: If `IN_PRODUCT_ASSISTANT_CHARACTER.has=true`, the assistant has to introduce itself somewhere — and that surface needs to be the single auto-exempt file for forbidden-phrases enforcement. Without it, the assistant can't say its own name anywhere.
- **Opt-in**: "Scaffold the assistant intro surface at `app/wizard/meet-<assistant>.tsx`? It's the single file where 'Hi — I'm <name>' is allowed; everything else stays daily-driver register."
- **Default**: Empty wizard surface stub + intro copy template.

---

## 5. Per-artifact greenfield-mode requirements

| Artifact | # non-generic elements | Ships by default greenfield? | Required scaffolding to ship | Greenfield authoring strategy |
|---|---|---|---|---|
| `ux-reviewer.md` | 24 | YES | scaffolds 1, 9 (CLAUDE.md, tokens) for full effect | Read TIER_1/2 + PRIMARY_PLATFORM from knobs; project-history examples skipped; PRODUCT_DESCRIPTOR fills role framing |
| `interaction-audit.md` | 16 | YES | none required (universal patterns work) | Skip past-bug examples; ship universal pattern taxonomy |
| `a11y-audit.md` | 18 | YES (if PROD_VS_INTERNAL≠internal) | scaffold 9 (tokens) for contrast computation | Token contrast skipped if no tokens; rest universal |
| `flow-auditor.md` | 32 | ONLY if MULTI_SCREEN_ARCS_EXIST=true | scaffolds 3 (audits), 4 (flows), optionally 7 (strategy) | Empty arc inventory greenfield; agent ships waiting for first arc |
| `flow-ux-reviewer.md` | 14 | ONLY if MULTI_SCREEN_ARCS_EXIST=true AND VISUAL_VERIFICATION_TOOL captures series | scaffold 3 + capture harness | Ships but doesn't fire until manifest produced |
| `pages-audit.md` | 24 | NO — defer until MULTI_SECTION_PRIMARY_SURFACE.has=true | requires concrete section inventory | Skip until user has 3+ tabs/sections shipped |
| `design-token-auditor.md` | 11 | YES | scaffold 9 (tokens) — without it, agent has no proposal target | If DESIGN_SYSTEM_TOKENS_PATH set, agent proposes from there; if not, proposes NEW tokens |
| `product-designer.md` | 38 | YES with caveat | requires scaffolds 2 (brainstorms), 3 (audits), at least optionally 5 (capability map) | Full agent ships; capability-delta requirement softens to "if capability map exists" |
| `product-compass.md` | 12 | NO — defer if no vision docs | requires scaffold 6 (vision docs) | Agent ships only if PRODUCT_VISION_DOCS≥1 path or ARCHITECTURE_LAYER_PRIORITY set |
| `quality-bar/SKILL.md` | 16 | YES | none required | Past project-history examples skipped; ship universal pitfall catalog |
| `journey-audit/SKILL.md` | 10 | YES | scaffold 8 if PRODUCT_HAS_VOICE | Default surface types ship; greenfield projects start with empty journey maps |
| `element-reuse-check/SKILL.md` | 8 | YES | needs MULTI_SCREEN_ARCS_EXIST OR TRANSLATION_FILE_LOCATIONS to be meaningful | Ships; refuses gracefully if no existing strings to reuse |
| `persona-lens/SKILL.md` | 10 | YES if PRODUCT_HAS_VOICE=true | scaffold 8 (persona doc) recommended | Default triad ships; project triad override optional |
| `design-system/SKILL.md` | 32 | YES | scaffold 9 (tokens) for real value | Without tokens scaffold, skill has limited content; with scaffold, full reference |
| `ruthless-ux-autoloop/SKILL.md` | 22 | NO — defer until FIXTURE_RESET_COMMAND set AND reviewer agent shipped | requires fixture pipeline + capture harness + reviewer | Mark as "available when you have a seed pipeline" |
| `flow-ux-audit/SKILL.md` | 18 | NO — defer until MAESTRO_YAML_PATH or equivalent autoplay set | requires capture harness + autoplay build | Defer; mention as available when project sets up E2E |
| `storybook-story/SKILL.md` | 14 | NO — defer until STORYBOOK_FRAMEWORK set | requires Storybook configured | Skip; surface when Storybook added |
| `design-north-star.md` | 16 | YES | none required | TIER_1 + ANTI_REFERENCES drive content; chrome reference table built from platform defaults |
| `design-audit-routing.md` | 12 | YES — if 3+ audit agents ship | none required | Universal pipeline order ships; cross-rubric translation ships |
| `visual-verification.md` | 13 | YES | none required | CLI-first defaults derived from platform |
| `forbidden-phrases.txt` | 10 | YES if PRODUCT_HAS_VOICE=true | scaffold 8 (persona doc) | 4 universal categories ship; project additions from interview |
| `frontend-components.md` | 5 | YES if PRIMARY_PLATFORM has UI | none required | Page wrapper names empty greenfield; populated post-first-component |
| `check-forbidden-phrases.sh` | 9 | YES if PRODUCT_HAS_VOICE=true AND hooks supported | scaffolds 8 + 13 (intro file) | Hook ships; intro-file exemption depends on scaffold 13 |
| `check-token-only.sh` | 7 | YES if tokens exist | scaffold 9 (tokens) | Hook waits for tokens file before activating; doesn't error until then |
| `check-nativetabs-sf-icon.sh` | 6 | ONLY if PRIMARY_SURFACE_PLATFORM=iOS AND native tab primitive used | none required | Hook auto-skips when iOS not platform |
| `check-no-expo-blur.sh` | 5 | ONLY if PRIMARY_SURFACE_PLATFORM=iOS + Expo | none required | Hook auto-skips when Expo not in stack |

**Summary**: of 26 artifacts, **5 don't ship by default greenfield** (`pages-audit`, `product-compass`, `ruthless-ux-autoloop`, `flow-ux-audit`, `storybook-story`) — they require specific infrastructure that greenfield projects haven't built yet. Another **4 ship conditionally** based on key knobs (`flow-auditor`, `flow-ux-reviewer`, `persona-lens`, `forbidden-phrases.txt`). The remaining **17 ship by default** with graceful degradation when scaffolding is absent.

---

## 6. Existing principle gaps for greenfield

29 principles currently in `/Users/dima/Documents/Projects/dotclaude/principles/`. The authoring instructions of most assume the kit can derive configuration from "the user's interview answers" or "Phase 1 project scan." In greenfield, those instructions need explicit greenfield-mode branches.

Notation: ✓ = no greenfield-specific change needed; ⚠ = section-bounded update needed; ✗ = significant restructure needed.

| # | Principle | Greenfield status | Needed change |
|---|---|---|---|
| 1 | `a11y-audit.md` | ⚠ | Add "if no token system yet, contrast computation defers — surface as deferred check, not skip" |
| 2 | `ai-cost-monitoring.md` | ✓ | n/a |
| 3 | `audit-routing.md` | ⚠ | Note: when fewer than 3 audit agents ship, the routing table degrades to "use the one that exists" — don't fail the principle |
| 4 | `code-review.md` | ✓ | n/a (out of design scope) |
| 5 | `data-integrity.md` | ✓ | n/a |
| 6 | `database-query-discipline.md` | ✓ | n/a |
| 7 | `decomposition.md` | ✓ | n/a |
| 8 | `design-benchmarking.md` | ⚠ | Add greenfield instruction: "if user has no benchmarks, ship platform-default Tier-1 table as starter; flag that benchmarks must be confirmed before first audit fires" |
| 9 | `design-system-reference-skill.md` | ⚠ | Add: "if no chrome primitives wrapped, populate via platform-typical recommendations + mark each as 'planned'" + cross-ref to scaffold 9 |
| 10 | `design-token-audit.md` | ⚠ | Add: "if no DESIGN_SYSTEM_TOKENS_PATH, this agent is deferred; surface as 'available after token setup'" |
| 11 | `element-reuse.md` | ⚠ | Add: "if no existing strings/components, the gate ships but doesn't fire; surface this gracefully" |
| 12 | `file-discipline.md` | ✓ | n/a |
| 13 | `flow-audit.md` | ⚠ | Add: "if MULTI_SCREEN_ARCS_EXIST=false at interview time, do not author this principle in the kit; surface re-run instruction" |
| 14 | `flow-continuity-review.md` | ⚠ | Same: gate on arcs exist + visual-verification supports series |
| 15 | `forbidden-phrases.md` | ⚠ | Add: "in greenfield, ship 4 universal categories + persona-lens triad; project-specific entries come from Q-C4 + post-audit accumulation" |
| 16 | `interaction-audit.md` | ⚠ | Add: "past-bug examples are illustrative-only in greenfield; the principle ships the pattern taxonomy without project-history citations" |
| 17 | `iterative-polish-autoloop.md` | ✗ | Add: "this principle ships only if FIXTURE_RESET_COMMAND set AND reviewer agent shipped; otherwise defer with re-run instruction" + greenfield variant of orchestration with no-fixture path |
| 18 | `journey-mapping.md` | ⚠ | Add: "in greenfield, the journey map for the first surface is itself the first design output; the skill ships with placeholder-driven surface types" |
| 19 | `migration-create.md` | ✓ | n/a |
| 20 | `pages-audit.md` | ✗ | Add: "this principle ships only if MULTI_SECTION_PRIMARY_SURFACE.has=true; otherwise defer entirely" |
| 21 | `persona-testing.md` | ⚠ | Add: "in greenfield, ship the default Day-30/Partner/Stranger triad + universal forbidden categories; project-specific adds via Q-C4" |
| 22 | `pre-flight.md` | ✓ | n/a (out of pure design scope) |
| 23 | `product-designer.md` | ⚠ | Add: "in greenfield, capability-delta requirement softens to 'if capability map scaffold accepted (scaffold 5)'; data-shape probe gates on DATA_SHAPE_PROBE_INTERFACE; brainstorm doc reading gates on scaffold 2" |
| 24 | `product-direction-validator.md` | ✗ | Add: "this principle ships only if PRODUCT_VISION_DOCS≥1 or ARCHITECTURE_LAYER_PRIORITY non-trivial; otherwise defer" |
| 25 | `quality-rubric.md` | ⚠ | Add: "in greenfield, past pitfall-examples are illustrative; surface that the rubric ships with universal patterns + invites accumulation" |
| 26 | `skill-vs-code-audit.md` | ✓ | n/a |
| 27 | `test-architect.md` | ✓ | n/a |
| 28 | `ux-audit.md` | ⚠ | Add: "in greenfield, past dead-chrome / a11y / token-drift / arc-bug commit references are skipped; the depth signature ships with the pattern names without project examples" |
| 29 | `visual-verification.md` | ⚠ | Add: "in greenfield, capture commands derive from platform; physical-device path is opt-in via scaffold 1" |

**Summary**: of 29 principles, **5 need significant restructure** (`iterative-polish-autoloop`, `pages-audit`, `product-direction-validator`, + 2 less obvious) for graceful greenfield deferral; **17 need section-bounded updates** for greenfield-mode branches; **7 need no change**. The pattern across principles: the *methodology* is universal, but the *authoring instructions* often say "read the project's <X>" or "derive from git history of <Y>" — and need an explicit "if <X> doesn't exist yet" branch that defers or substitutes a default.

### Recurring authoring-instruction patches needed

The same 4 patches repeat across principles — making them factor-out candidates for a shared `principles/_greenfield-mode.md` reference doc:

1. **"Read existing X" → "if X exists; else ship defaults / defer"** — applies to 11 principles (every principle that reads files like `tokens.ts`, `CLAUDE.md`, `flow docs`, `capability map`).

2. **"Git-mine for past examples" → "skip in greenfield; defer to post-audit accumulation"** — applies to 6 principles (ux-audit, interaction-audit, a11y-audit, flow-audit, design-token-audit, quality-rubric).

3. **"Read project memories" → "skip if no memories; offer to scaffold via /dotclaude:setup-binding-memories"** — applies to 4 principles (flow-audit, persona-testing, journey-mapping, product-direction-validator).

4. **"Reference project_*_skills" → "if those skills exist; else use platform-defaults"** — applies to 3 principles (product-designer, flow-audit, ux-audit's app-state-navigation cross-ref).

A shared `principles/_greenfield-mode.md` doc could centralize these 4 patches as authoring-time conditionals; principle authors invoke them by reference instead of re-explaining the branch each time.

---

## 7. Category classification tables

### 7.1 — Category A: Project-specific VALUES (alphabetical)

Universal slot, value varies per project. These all become interview questions with defensible defaults.

```
A11Y_COMPLIANCE_TARGET                          → Q-G1
A_TIER_BENCHMARK_REFERENCES                     → derived from Q-B2
ANIMATION_PRESET_FILE_PATH                      → Q-F3
ARC_INVENTORY                                   → Q-E1 (greenfield: empty)
ARCHITECTURE_LAYER_PRIORITY                     → Q-M1 (optional)
ASSISTANT_INTRO_EXEMPT_FILE                     → derived from Q-C2
BACKEND_TRUTH_PROBE_QUERIES                     → Q-L3 (only if generative)
BRAND_ACCENT_COLOR                              → Q-F2
BRAND_FORBIDDEN_PHRASES                         → Q-C4
BRAND_VOICE_REFERENCE                           → Q-C3
BRIDGE_REFERENCE_APPS                           → Q-B2b
CAPTURE_COMMAND_PHYSICAL_DEVICE                 → Q-A2b
CAPTURE_COMMAND_PRIMARY                         → Q-A2 (platform-default)
CHROME_PRIMITIVE_PATHS                          → Q-F2
CORE_DIFFERENTIATORS_LIST                       → Q-M2
DATA_SHAPE_PROBE_INTERFACE                      → Q-L2
DEMO_TEST_AUDIENCE                              → Q-D3
DESIGN_SYSTEM_MATURITY                          → Q-F1
DESIGN_SYSTEM_TOKENS_PATH                       → Q-F1
DEVICE_TARGET_DETECT_COMMAND                    → Q-A2
DEV_LOOP_TOOL                                   → Q-A2
DRIFT_SIGNALS                                   → skip greenfield
DYNAMIC_TYPE_UPPER_BOUND_PERCENT                → inferred from platform
FILE_SIZE_CEILING_LOC                           → universal default 1000
FIXTURE_RESET_COMMAND                           → Q-L1
GRADING_SCALE                                   → universal S/A/B/C/D/F
HAS_GENERATIVE_SURFACES                         → Q-E5
HIERARCHY_INSPECTION_COMMAND                    → Q-A2
HIT_TARGET_MINIMUM_PT                           → inferred from platform
IN_PRODUCT_ASSISTANT_CHARACTER                  → Q-C2
ITERATION_CAP_HARD / SOFT                       → Q-K2
LABEL_API                                       → inferred from platform
LIGHT_AND_DARK_MODE_BOTH                        → Q-F1
LINT_INFRASTRUCTURE                             → Q-I1
LOG_INSPECTION_PATH                             → derived from platform
MODEL_TIER_DEFAULT / LIGHTWEIGHT                → Q-K1
MOTION_LIBRARY                                  → Q-F3
MULTI_SCREEN_ARCS_EXIST                         → Q-E1
MULTI_SECTION_PRIMARY_SURFACE                   → Q-E2
NARRATION_FILE_LOCATIONS                        → Q-E3b
NATIVE_CHROME_PRIMITIVES_LIST                   → Q-F2 (greenfield: empty)
PERSONA_TRIAD                                   → Q-C5 (default ships)
PRIMARY_SURFACE_PLATFORM                        → Q-A1
PRODUCT_DESCRIPTOR                              → Q-D4
PRODUCT_HAS_VOICE                               → Q-C1
PROD_VS_INTERNAL                                → Q-D2
PROJECT_DESCRIPTOR                              → Q-D4
PROTOTYPE_GATE_NAMES                            → scaffold 7
QUALITY_BAR_REGISTER                            → Q-D3
QUALITY_GRADE_TARGETS_BY_SURFACE                → Q-D3
REDUCED_MOTION_HOOK_PATH                        → inferred from MOTION
SAFETY_INVARIANTS                               → Q-L2 (universal default)
SEED_FIXTURE_MECHANISM                          → Q-L1
SEVERITY_TAXONOMY                               → universal Crit/High/Med/Low
STATUS_COLOR_SYSTEM                             → Q-F2d
STORYBOOK_DARK_DEFAULT                          → Q-H4
STORYBOOK_FRAMEWORK                             → Q-H4
STYLING_SYSTEM_IN_USE                           → Q-F1
SURFACE_DIR_STRUCTURE                           → Q-E3
SURFACES_PRESENT                                → Q-E4
TEST_FRAMEWORK                                  → Q-H4
THEME_CONVENTION                                → Q-F1
THEME_GENERATION_COMMAND                        → Q-F1c
TIER_1_BENCHMARKS                               → Q-B1
TIER_2_BENCHMARKS_WITH_DIMENSION                → Q-B2
TRANSLATION_FILE_LOCATIONS                      → Q-E3
TYPOGRAPHY_SYSTEM                               → Q-F3
USAGE_FREQUENCY_FRAMING                         → Q-C5 (derived)
USER_DEVICE_COMPARATOR_APPS                     → derived from TIER_1
USER_FACING_AUDIENCE_NAMES                      → Q-D1b
USER_PERSONA_TYPE                               → Q-D1
USER_STANDING_PRINCIPLE                         → Q-M3 (universal default)
VOICE_ANTI_REFERENCES                           → Q-C4
VISUAL_VERIFICATION_TOOL                        → Q-I1
ANTI_REFERENCES                                 → Q-B3
```

**Total Category A: ~56 knobs.**

### 7.2 — Category B: Project-specific STRUCTURE

The shape itself varies between projects. These are more dangerous than Category A — the principle's STRUCTURE may need to adapt per project. For each, the decision: is the structure actually universal? Or does it need configuration?

```
AFFORDANCE_TABLE_SCHEMA                — universal; document in interaction-audit principle
CANONICAL_PIPELINE_ORDER               — universal default; document in audit-routing principle
COMPOSITION_PITFALL_TAXONOMY (5)       — universal: Duplication / Orphan / Tone mismatch / Hierarchy / Residue
CONSISTENCY_VERDICT_RULE               — universal: "majority rules" — applies whenever you have 3+ comparable sections
CROSS_RUBRIC_TRANSLATION_TABLE         — universal: S↔Crit↔S0 mapping
DONE_PRECONDITIONS_CHECKLIST           — universal: 5 items (screenshot/lint/tests/pitfalls/benchmark)
FAST_VS_CAREFUL_TASK_TYPES             — universal default with project-specific examples
FLOW_CONTINUITY_DIMENSIONS (6)         — universal: tone / CTA weight / loading / pacing / color drift / progress legibility
FORBIDDEN_PATTERN_MATRIX               — universal scaffold; project-specific phrases fill in (BRAND_FORBIDDEN_PHRASES)
GAP_CLASS_TAXONOMY (8)                 — universal: context-mismatch / dead-end / missing bridge / tone drift / missing state / visual inconsistency / IA boundary / copy register. Possibly contractable to 5-6 for simpler projects.
GENERATIVE_SURFACE_CHECKLIST           — universal IF HAS_GENERATIVE_SURFACES; else N/A
INTERACTION_PATTERN_TAXONOMY (7)       — universal: dead chrome / redundant / optical / action-singularity / promise-mismatch / selection-commit / hidden-primary
MANIFEST_SCHEMA                        — universal default schemaVersion:1; per-project extensions allowed
MOTION_PRINCIPLES (5)                  — universal: spring / staggered / purposeful / fast-exit / reduced-motion
REGRESSION_DELTA_PATTERN               — universal: look in same audit dir for prior runs
REUSE_VERDICT_MATRIX                   — universal: 6×6 grid covering surface-type × surface-type reuse decisions
SAFETY_INVARIANTS                      — universal default; project-tuning ADDS to the list, never removes
STATE_CLARITY_DIMENSIONS (6)           — universal IF HAS_GENERATIVE_SURFACES
STATE_SPECTRUM_PER_COMPONENT_KIND      — universal default; per-component opt-out
SURFACE_HIERARCHY_LEVELS (5)           — universal: Background / Card / Sheet / Elevated / Frosted
SURFACE_TYPES_IN_USE (6)               — universal: first-touch / daily-driver / settings / error / promotional / bridge. Possibly subset (e.g. CLI tool lacks "bridge").
TOKEN_TAXONOMY                         — universal: palette / theme / spacing / radii / shadows
```

**Verdict on each Category B**: every one above is **actually universal** with at most a small subsetting for very-simple products (e.g. CLI tool with no "bridge" surface type). None require deep configuration. The kit can ship them as defaults; only consider per-project override when an explicit user request justifies it. **22 Category B knobs total.**

### 7.3 — Category C: Knowledge-graph scaffolding

Concepts that don't exist yet in greenfield projects. The plugin must offer to BUILD these.

```
APP_STATE_NAVIGATION_SKILL_EXISTS              → scaffold 10
AUDIT_REPORT_PATH_CONVENTION (concept)          → scaffold 3
BINDING_MEMORIES_FOR_FORBIDDEN_PATTERNS         → scaffold 11
BRAINSTORM_DOC_PATH_CONVENTION (concept)        → scaffold 2
CAPABILITY_MAP_PATH                             → scaffold 5
DESIGN_DEBT_RITUAL_PATH                         → scaffold 12
EXISTING_CLAUDE_MD                              → scaffold 1
FLOW_DOC_PATH_CONVENTION (concept)              → scaffold 4
PERSONA_DOC_PATH                                → scaffold 8
PRODUCT_VISION_DOCS                             → scaffold 6
PROTOTYPE_GATES_PATH                            → scaffold 7
SPEC_DOC_PATH_CONVENTION (concept)              → scaffold 2 (paired with brainstorm)
TOKENS_FILE_EXISTENCE                           → scaffold 9
```

**Total Category C: ~13 scaffolding decisions.** Each becomes an opt-in `/dotclaude:setup-<name>` mini-skill (Section 4).

---

## 8. Recommendations — next execution scope

### Option 1 — Pure analysis (DONE after this audit)

**Scope**: This doc + zero file changes outside it.
**Effort**: 0 (done).
**Risk**: 0.
**Outcome**: User reviews the doc, decides whether to commit to Option 2 or 3.
**When this is right**: User wants to think + share + sleep on it before any code changes.

### Option 2 — Greenfield interview + setup flows (RECOMMENDED)

**Scope**:

1. Rewrite `skills/design/interview.md`:
   - Phase 0 mode-declaration (greenfield vs brownfield).
   - Greenfield branch: 13 phases (A through M), 37 questions, ~26 min.
   - Brownfield branch: existing 18-Q ~15-20 min flow (mostly unchanged).
   - Skip discipline preserved for brownfield; explicit defaults for greenfield.

2. Ship 13 scaffolding mini-skills as `/dotclaude:setup-<name>`:
   - `setup-claude-md`, `setup-brainstorm-docs`, `setup-audit-docs`, `setup-flow-docs`, `setup-capability-map`, `setup-vision-docs`, `setup-strategy-lens`, `setup-persona-doc`, `setup-token-system`, `setup-app-state-navigation`, `setup-binding-memories`, `setup-design-debt-ritual`, `setup-assistant-intro-surface`.
   - Each: ~30-100 LOC template + opt-in question + CLAUDE.md cross-ref (where applicable).

3. Update **17 existing principles** with section-bounded greenfield-mode branches (Section 6, ⚠-marked). Pattern: add a "Greenfield mode" section after the methodology, with the 4 recurring patches.

4. Update **5 principles** needing significant restructure (✗-marked in Section 6) with explicit "ships only if <condition>" gates.

5. Factor out `principles/_greenfield-mode.md` — a shared reference doc with the 4 recurring greenfield patches.

**Effort estimate**: 8-12 hours focused work, breakable into 3 sessions:
- Session 1 (3-4 hr): interview rewrite + Phase-0 mode branch + greenfield super-questions.
- Session 2 (3-4 hr): 13 scaffolding mini-skills (parallel-able via subagents).
- Session 3 (2-4 hr): principle updates + shared `_greenfield-mode.md` factor-out + smoke test on a new project.

**Risk**: medium.
- The principle updates touch 22 of 29 principles — broad blast radius. Risk: regression in brownfield mode if greenfield branches aren't tightly bounded. Mitigation: every greenfield branch starts with `if greenfield_mode: …` so brownfield path is unchanged byte-for-byte.
- The 13 scaffolding skills are simple templates; risk: under-tested in practice. Mitigation: smoke-test on at least 1 fresh project before declaring done.
- Interview rewrite is the riskiest piece — 37 Qs is a lot; risk: greenfield mode feels exhausting. Mitigation: super-question batching (5-6 per turn) + heavy use of platform-defaults + scaffold opt-in batched at end (Q-H2).

**When this is right**: User wants the kit production-ready for the next external user; the 8-12 hours is acceptable; the current brownfield experience must remain stable.

### Option 3 — Full execution (Option 2 + demo + all principles + comprehensive smoke test)

**Scope**: Option 2 + the additional:

6. Regenerate the demo (`examples/<demo-project>/`) showing greenfield mode end-to-end — fresh `git init`, interview-driven knob capture, scaffolds applied, kit authored, first audit run.
7. Update authoring instructions across **all 29 principles** for explicit greenfield-mode handling (the 7 currently-marked ✓ get a one-line "greenfield: no change needed" annotation for traceability).
8. Add a `scripts/smoke-test-greenfield.sh` that runs the full interview against a synthetic project in CI.
9. Update `README.md` + top-level docs explaining the greenfield-vs-brownfield distinction.

**Effort estimate**: 14-22 hours total (Option 2 + 6-10 hours of additional work).

**Risk**: medium-high.
- The demo regeneration is high-touch and may surface gaps that require Option 2 work to revisit.
- The smoke-test script may reveal interview UX issues that require iteration.

**When this is right**: User wants the kit to be the production reference for greenfield design setup for the next 6+ months; the additional 6-10 hours is acceptable; the smoke-test investment pays back via every future external user.

### Recommendation

**Option 2.** Ship the greenfield interview + 13 scaffolding mini-skills + the principle updates in the next 8-12 hours of focused work. Defer the demo regeneration + smoke-test script (Option 3 extras) until at least one external user has run through Option 2 in real-world conditions. That validates the interview UX before investing in the demo + smoke test, which would otherwise risk encoding interview decisions that turn out wrong in practice.

The case against Option 3 isn't the work effort — it's premature optimization. The interview's UX needs real user contact before it's ready to be canonical-demoed. Ship Option 2, get a first user, iterate, then Option 3.

The case against Option 1 isn't quality — it's that Option 1 leaves the kit not-shippable to greenfield projects. As of right now, anyone running `/dotclaude:design` on a brand-new project gets confused agents referencing infrastructure that doesn't exist. Option 2 closes that gap.

---

## Appendix: knob delta from existing 53-knob list

**Carried forward unchanged from existing analysis**: 51 knobs (every knob in the original Clusters A-I except `STORYBOOK_RN_WEB_RESOLUTION` which folds into framework derivation, and `EXISTING_STYLE_GUIDE` which became scaffold 8 — `PERSONA_DOC_PATH`).

**New in greenfield analysis (27 knobs)**:

```
PROJECT_DESCRIPTOR               — Phase D (1-sentence product description; reused in every agent's framing)
PRODUCT_VERTICAL_LABEL           — Phase D (the user-visible product vertical label)
USER_FACING_AUDIENCE_NAMES       — Phase D (e.g. "owner-facing / member-facing")
INTERACTION_TOOL_INVENTORY       — Phase A (automation tool mcp inventory)
A_TIER_BENCHMARK_REFERENCES      — derived from Tier-2
USER_DEVICE_COMPARATOR_APPS      — subset of Tier-1
PERSONA_TRIAD                    — Phase C (override mechanism)
ASSISTANT_INTRO_EXEMPT_FILE      — Phase C scaffold 13
NARRATION_FILE_LOCATIONS         — Phase E (split from translations)
SURFACES_PRESENT                 — Phase E (drives Q-B2 reverse)
HAS_GENERATIVE_SURFACES          — Phase E
STYLING_SYSTEM_IN_USE            — Phase F (explicit knob)
SURFACE_HIERARCHY_LEVELS         — Phase F universal
TYPOGRAPHY_SYSTEM                — Phase F
BRAND_ACCENT_COLOR               — Phase F
LINT_INFRASTRUCTURE              — Phase I
FILE_SIZE_CEILING_LOC            — Phase I universal
HOOK_OVERRIDE_SYNTAX             — Phase I universal
PROJECT_FAILURE_PATTERNS         — Phase J (distinct from PAST_BUGS_BY_SHA)
CROSS_RUBRIC_TRANSLATION_TABLE   — Phase K universal
CANONICAL_PIPELINE_ORDER         — Phase K universal
GRADING_SCALE                    — Phase K universal default
SEVERITY_TAXONOMY                — Phase K universal default
BACKEND_TRUTH_PROBE_QUERIES      — Phase L (only if generative)
SAFETY_INVARIANTS                — Phase L default
CORE_DIFFERENTIATORS_LIST        — Phase M
DRIFT_SIGNALS                    — Phase M
PROTOTYPE_GATE_NAMES             — scaffolded by Phase H scaffold 7
USER_STANDING_PRINCIPLE          — Phase M
DESIGN_DEBT_RITUAL_PATH          — Phase H scaffold 12
APP_STATE_NAVIGATION_SKILL_EXISTS — Phase H scaffold 10
BINDING_MEMORIES_FOR_FORBIDDEN_PATTERNS — Phase H scaffold 11
PERSONA_DOC_PATH                 — Phase H scaffold 8 (was EXISTING_STYLE_GUIDE)
```

**Total final knob count: 78.** 51 existing + 27 new − 0 retired = 78.

---

*End of audit.*
