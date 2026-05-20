# Design stack analysis — source project → dotclaude reusability map

**Date:** 2026-05-20
**Source repo (anonymized):** a React Native iOS-first vertical app (mobile-app stack)
**Artifacts in scope:** 9 agents + 8 skills + 5 rules + 4 hooks = 26 design-related artifacts
**Goal:** every knob, dependency, and applicability trigger inventoried so the dotclaude interview can fully reproduce this stack on any other project via configuration alone.

This document is analytical foundation only. No principle / interview / SKILL.md mutations follow from it; mutations come in a separate pass after human review.

---

## 1. Inventory (the 26 artifacts)

Each row of each table follows the six-dimension schema:

1. **Name + LOC**
2. **Purpose (1 sentence)**
3. **Universal methodology** (the abstracted pattern that applies to any project)
4. **Configuration knobs** (project-specific values, named in `SCREAMING_SNAKE_CASE`)
5. **Composition triggers** (when does this fire / when skip)
6. **Dependencies** (other artifacts it cross-references — the composition graph rows live here)
7. **Output shape** (report, scan, score, modified file, etc.)

### 1.1 Agents (9)

#### Agent 1 — `ux-reviewer.md` (187 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | S-tier single-screen visual-polish auditor that captures the rendered UI on the target device, grades against named benchmarks, and produces a per-screen letter grade with concrete fixes. |
| **Universal methodology** | (a) Auto-detect dev-server's device target. (b) Capture via cheap CLI path. (c) Classify the screen via journey-audit. (d) Grade against Tier 1 (chrome) + Tier 2 (domain) references. (e) Scan for 5 composition pitfalls. (f) Apply persona-lens to every visible string. (g) Produce S/A/B/C/D/F grade with one highest-ROI move. |
| **Configuration knobs** | `PRIMARY_SURFACE_PLATFORM`, `TIER_1_BENCHMARKS`, `TIER_2_BENCHMARKS_WITH_DIMENSION`, `CAPTURE_COMMAND_PRIMARY`, `CAPTURE_COMMAND_PHYSICAL_DEVICE`, `HIERARCHY_INSPECTION_COMMAND`, `DEVICE_TARGET_DETECT_COMMAND`, `MODEL_TIER` (here: opus-tier high-effort), `THEME_TOKENS_PATH`, `IN_PRODUCT_ASSISTANT_CHARACTER` (drives the daily-driver-trap check) |
| **Triggers** | Single-screen visual polish, after any UI screen edit, before declaring done. Skip for multi-screen arcs (→ flow-auditor), cross-tab consistency (→ pages-audit), pure backend / pipeline work. |
| **Dependencies** | reads: `quality-bar`, `journey-audit`, `persona-lens`, `app-state-navigation` (project-specific recipe catalog), `design-north-star.md`, `visual-verification.md`. Pipeline-paired with: `interaction-audit`, `a11y-audit`, `design-token-auditor`. Defers to: `flow-auditor` (multi-screen scope). |
| **Output** | Markdown report at audit doc path; overall grade + showstoppers + design debt + polish pass + screen-by-screen grade table + consistency matrix. |

#### Agent 2 — `interaction-audit.md` (225 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Semantic-integrity auditor that builds an affordance-vs-behavior table per interactive element to catch dead chrome, redundant affordances, and optical-group disconnects. |
| **Universal methodology** | For each Pressable / button / link on a screen: capture chrome promise (from rendered output), trace handler (from source), TAP and observe runtime behavior, mark match ✓ / ✗ / ⚠, scan table for three pattern classes (dead chrome / redundant affordance / optical disconnect), grade per element + per screen lowest. |
| **Configuration knobs** | `PRIMARY_SURFACE_PLATFORM`, `INTERACTIVE_ELEMENT_TYPES` (Pressable / TouchableOpacity / button / a / etc.), `TESTID_CONVENTION` (testID / data-testid / aria-label / id), `HANDLER_TRACING_PATTERN` (onPress → router.push / onClick → server action / formAction / etc.), `TAP_COMMAND_PRIMARY`, `TAP_COMMAND_PHYSICAL_DEVICE`, `HIERARCHY_INSPECTION_COMMAND`, `MODEL_TIER`, `PAST_DEAD_CHROME_SHAS` (anti-pattern shape examples from git history) |
| **Triggers** | After any UI screen edit, before ux-reviewer (so semantic fixes shift layout before visual review). Skip for visual-polish, arc structure, token discipline, copy register, pure read-only screens. |
| **Dependencies** | reads: `design-system`, `quality-bar`, `app-state-navigation`, `journey-audit`, `persona-lens`. Pipeline-paired with: `a11y-audit` (orthogonal, parallel). Sequenced before: `ux-reviewer`. |
| **Output** | Markdown audit doc with affordance-vs-behavior table, patterns detected (CRIT/MAJ severity), per-element grades, severity-graded fix list with row IDs. |

#### Agent 3 — `a11y-audit.md` (274 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Accessibility auditor against platform a11y standards + WCAG 2.2 AA — labels, hit-target sizes, contrast ratios, text scaling, reduced motion. CRIT-class failures block ship regardless of visual grade. |
| **Universal methodology** | Walk five dimensions (4 hard + 1 soft): (1) assistive-tech labels; (2) hit-target size against platform minimum; (3) contrast ratios computed from token values, not screenshots; (4) text-scale survival at 200%+ ; (5) reduced-motion honoring. CRIT-class on any hard dim blocks ship. |
| **Configuration knobs** | `PRIMARY_SURFACE_PLATFORM`, `A11Y_COMPLIANCE_TARGET` (WCAG 2.2 AA / Section 508 / etc.), `HIT_TARGET_MINIMUM_PT` (44pt iOS / 48dp Android / 44px web touch), `THEME_TOKENS_PATH` (for contrast computation), `LIGHT_AND_DARK_MODE_BOTH` (boolean), `DYNAMIC_TYPE_UPPER_BOUND_PERCENT` (e.g. 200% / 310%), `REDUCED_MOTION_HOOK_PATH`, `LABEL_API` (accessibilityLabel / aria-label / contentDescription), `HIERARCHY_INSPECTION_COMMAND`, `MODEL_TIER`, `PAST_A11Y_BUG_SHAS` |
| **Triggers** | Any UI screen edit on a user-facing surface. Parallel to interaction-audit. Skip for: pure backend / pipeline, internal-only debug tools, single-line copy fixes. |
| **Dependencies** | reads: `design-system`, `app-state-navigation`, `quality-bar`, `design-north-star.md`, `audit-routing.md`. Pipeline-paired with: `interaction-audit` (parallel, orthogonal). Sequenced before: `ux-reviewer`. |
| **Output** | Markdown audit doc with per-dim tables (labels / hit-size / contrast / Dynamic Type / motion), CRIT/MAJ/LOW severity classification, ship-block header if CRIT present, cross-screen patterns. |

#### Agent 4 — `flow-auditor.md` (366 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Whole-arc auditor for multi-screen user journeys; produces TWO artifacts — canonical flow doc (persistent) + dated gap report (point-in-time) — graded across 8 gap classes. |
| **Universal methodology** | Four phases: (1) arc inventory + scope-lock; (2) build/update canonical flow doc with surface inventory table; (3) gap-detect across 8 classes (copy/context mismatch, dead-end, missing bridge, tone drift, missing state variant, UI inconsistency, IA boundary violation, copy register drift); (4) write dated audit report with severity-graded fix list + resolution-of-prior-audit section. Agent audits, does NOT fix — every row has a handoff column. |
| **Configuration knobs** | `MULTI_SCREEN_ARCS_EXIST` (boolean, gates whole agent), `ARC_INVENTORY` (named arcs the project has: onboarding / checkout / signup-to-daily / etc.), `FLOW_DOC_PATH_CONVENTION` (e.g. `docs/flows/<slug>.md`), `AUDIT_REPORT_PATH_CONVENTION` (e.g. `docs/audits/YYYY-MM-DD-<slug>-audit.md`), `SEED_FIXTURE_MECHANISM` (how to drive app to arc-start state), `MOTION_LANGUAGE_PRIMITIVES` (Reanimated / CSS transitions / view-controller animations), `BINDING_MEMORIES_FOR_FORBIDDEN_PATTERNS` (e.g. "daily-driver-never-uses-onboarding-copy"), `PAST_ARC_BUG_SHAS` |
| **Triggers** | Multi-screen arc audit, "what's broken in the whole onboarding flow" type questions. Refuses single-screen polish (→ ux-reviewer), single-tab consistency (→ pages-audit), new design proposals (→ product-designer), pure backend audits. |
| **Dependencies** | reads: `design-system`, `quality-bar`, `app-state-navigation`, `e2e-testing` (project-specific Maestro patterns), `journey-audit`, `persona-lens`, `product-atlas` (project-specific cross-domain map), `design-north-star.md`, `prototype-gates.md`. Routes findings to: `ux-reviewer`, `interaction-audit`, `product-designer`, direct impl. |
| **Output** | Two markdown artifacts — canonical flow doc + dated gap report with G-XXX IDs, severity (Crit/High/Med/Low), 8-class taxonomy, prior-audit resolution table. |

#### Agent 5 — `flow-ux-reviewer.md` (113 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Continuity-aware UX reviewer that grades an ordered series of captured screenshots as a single flow — judges flow-level dimensions invisible to per-screen reviewers. |
| **Universal methodology** | Takes manifest of N screenshots + context. Grades flow-level dimensions (voice/tone consistency across screens, CTA visual weight progression, loading-state treatment, disclosure pacing, color/tonality drift, progress legibility) + per-screen grades. Does NOT interact with the app — grades pre-captured artifacts. Pairs with auto-capture skill (`flow-ux-audit`) that produces the manifest. |
| **Configuration knobs** | `MANIFEST_SCHEMA` (path + JSON shape), `FLOW_CONTINUITY_DIMENSIONS` (which continuity properties matter — tone, CTA weight, loading vocab, pacing, color drift, progress legibility), `TIER_1_BENCHMARKS`, `TIER_2_BENCHMARKS_WITH_DIMENSION`, `BRIDGE_REFERENCE_APPS` (e.g. Apple iCloud onboarding, Stripe checkout), `MODEL_TIER` |
| **Triggers** | Multi-screen flow grading from captured artifacts. Skip if only 1-2 screenshots (use ux-reviewer instead), or if no flow-shaped sequence exists. |
| **Dependencies** | reads: `design-system`, `quality-bar`, `app-state-navigation`, `journey-audit`, `persona-lens`. Sequenced after: visual-polish (`ux-reviewer`). Sequenced after: setup-capture skill (`flow-ux-audit`). |
| **Output** | Markdown report — flow grade + per-screen grade table + flow-level dimension grades + lowest-graded screens + regression delta vs prior runs. |

#### Agent 6 — `pages-audit.md` (264 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Cross-section consistency audit comparing N primary sections (tabs / dashboards / panels) against each other via majority-rules verdict — surfaces single-tab outliers and overlay drift. |
| **Universal methodology** | Inventory N primary sections. Capture all at same device/viewport/theme/state. Build Shared Pattern Adherence Table (what shared primitives each section uses). Code-grep FIRST for shared-component usage (cheap + decisive). Pixel-measure LAST when grep can't resolve. Apply majority-rules: deviation from the majority value is flagged regardless of "better." Inspect every reachable overlay (sheets / dialogs) for shared-primitive usage. |
| **Configuration knobs** | `MULTI_SECTION_PRIMARY_SURFACE` (boolean, gates whole agent), `PRIMARY_SECTION_INVENTORY` (named tab list + route + file path + testID), `SHARED_LAYOUT_PRIMITIVES` (page header / page content / section title / card wrappers), `SHARED_OVERLAY_PRIMITIVES` (bottom sheet / confirm dialog / modal), `OVERLAY_INVENTORY` (per-section list of reachable overlays), `SEED_COMMAND_FOR_FULL_SHELL`, `MODEL_TIER` |
| **Triggers** | Project has multi-section primary surface (3+ tabs / panels). Skip when project has only 1-2 primary sections, or when sections are intentionally divergent. |
| **Dependencies** | reads: `design-system`, `quality-bar`, `app-state-navigation`, `design-north-star.md`, `design-audit-routing.md`. Sequenced between: `a11y-audit/interaction-audit` (step 2) and `ux-reviewer` (step 3) in the canonical pipeline. |
| **Output** | Markdown audit doc — Shared Pattern Adherence Table (per-section × per-pattern grid), per-tab deviations, overlay deviations, fixes grouped by impact (systemic / outlier / overlay polish). |

#### Agent 7 — `design-token-auditor.md` (75 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Lightweight haiku-class periodic sweep that finds raw hex / rgba / non-semantic color literals across the codebase and proposes semantic-token replacements from the project's theme file. |
| **Universal methodology** | Read theme/token file FIRST. Grep for violation patterns (`#[0-9a-fA-F]{3,8}`, `rgba(`, `rgb(`, `hsl(`, inline style color literals, Tailwind arbitrary values). Exempt the theme file itself + generated + tests + native asset dirs. Classify each hit by severity tier (S0 chrome / S1 content / S2 internal / Exempt). Propose replacement by reading available tokens; if no token fits, propose a NEW token name. Never auto-apply. |
| **Configuration knobs** | `DESIGN_SYSTEM_TOKENS_PATH`, `THEME_CONVENTION` (semantic-token / palette / CSS-variable / Tailwind / SCSS / styled-components), `STYLING_SYSTEM_IN_USE` (drives sweep patterns), `EXEMPT_PATHS` (theme file, generated, tests, native asset dirs), `SEVERITY_TIER_MAPPING_BY_PATH` (which dirs = S0 chrome vs S1 content vs S2 internal), `MODEL_TIER` (haiku-class — this is the only cheap-model agent in the kit) |
| **Triggers** | Has a design system / theme file. After UI batches. Periodic sweep. Skip when project has no theme system or styling is wholly Tailwind-arbitrary-values-only. |
| **Dependencies** | reads: theme tokens source file, `design-north-star.md`. Pipeline step 1 (before semantic / a11y / visual). Hook companion: `check-token-only.sh` (edit-time enforcement). |
| **Output** | Markdown report grouped by file, with line numbers, by severity tier, with proposed token replacements + new-token proposals + investor-narrative test for P0 hits. |

#### Agent 8 — `product-designer.md` (499 LOC — by far the largest)

| Dimension | Content |
|---|---|
| **Purpose** | Senior-IC product designer for IA / user-flow / multi-screen architecture work. The spec doc IS the deliverable. Refuses single-screen polish (→ ux-reviewer). |
| **Universal methodology** | Step 0 scope classification + refusal check. Step 1 system read (CLAUDE.md / rules / capability map / area-specific reads). Step 1.5 journey audit (MANDATORY — Section 0 of spec). Step 2 current-state read via visual baseline. Step 3 realistic data-shape probe (conditional). Step 4 competitive research (steal sheet). Step 5 design (direction principles + IA + flow + state inventory + engine asks + considered/rejected + element-reuse gate + persona-lens gate + north-star verification). Step 6.5 self-audit checklist. Step 7 write spec at `docs/brainstorms/YYYY-MM-DD-<slug>-design.md`. Step 8 return with handoff menu. |
| **Configuration knobs** | `BRAINSTORM_DOC_PATH_CONVENTION`, `SPEC_DOC_PATH_CONVENTION`, `CAPABILITY_MAP_PATH` (if exists — project's WHAT-the-product-does layer), `PROTOTYPE_GATES_PATH` (if exists — strategy lens), `DATA_SHAPE_PROBE_INTERFACE` (Supabase MCP / psql / direct API), `COMPETITIVE_REFERENCE_TABLE` (per-topic Apple / domain-app references), `INFRASTRUCTURE_VERIFY_GREPS` (where the spec must verify-before-naming), `JOURNEY_AUDIT_REQUIRED` (boolean), `ELEMENT_REUSE_CHECK_REQUIRED` (boolean), `PERSONA_LENS_REQUIRED` (boolean), `MODEL_TIER` |
| **Triggers** | New feature, redesign of existing flow, IA decision, multi-screen design. REFUSES single-screen polish / copy tweaks / single-prop adjustments / color tweaks. |
| **Dependencies** | reads: `design-system`, `quality-bar`, `product-atlas` (project map), `app-state-navigation`, `journey-audit`, `element-reuse-check`, `persona-lens`, `design-north-star.md`, `prototype-gates.md`, capability map. Sequenced before: implementation + UI-batch validation pipeline (`design-token-auditor` → `interaction-audit`+`a11y-audit` → `ux-reviewer`). |
| **Output** | Single markdown spec doc at the convention path. Sections: 0 journey map, 0a element-reuse audit, 0b persona-lens audit, 1 goal + capability delta, 2 direction (experience principles + anti-references), 3 user flow, 4 IA, 5 per-screen state inventory, 6 engine asks, 7 steal sheet, 8 considered & rejected, 9 north-star verification, 10 handoff. |

#### Agent 9 — `product-compass.md` (193 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Vision-alignment guardian / direction validator. Audits work against core product goals, identifies drift, asks clarifying questions, coordinates other agents. NOT a code reviewer. |
| **Universal methodology** | Read vision docs fresh every invocation. Look at recent work via `git log --oneline -30`, `git diff --stat HEAD~10`, `git status`, `ls`. Score each significant change against architecture layer priorities. Detect drift in three categories (feature creep, architecture drift, priority drift). Ask user clarifying questions when ambiguous (frame as A/B/C interpretations). Update CLAUDE.md / memories / skills when direction shifts. Recommend which agents to dispatch next. |
| **Configuration knobs** | `VISION_DOCS_INVENTORY` (paths to core vision / strategy files / architecture layer doc), `ARCHITECTURE_LAYER_PRIORITY` (layer 1 → N priority order — engine-vs-vertical for this project, but generalizes to other architectures), `CORE_DIFFERENTIATORS_LIST` (the named moats / differentiators), `DRIFT_SIGNALS` (per-project antipatterns to scan for), `AGENT_COORDINATION_TABLE` (what to recommend when) |
| **Triggers** | Start of major feature work, after large batches of work, when questioning product direction. Skip for tactical / one-shot tasks. |
| **Dependencies** | reads: project vision docs + memories. Coordinates: every other agent in the kit (recommends, never auto-dispatches). |
| **Output** | Markdown report — Vision Health (Aligned/Drifting/Recalibration) + Core Differentiators Status table + Recent Work Alignment table + Drift Warnings + Clarifying Questions for Owner + Recommended Actions + Documentation Updates Made. |

### 1.2 Skills (8)

#### Skill 1 — `quality-bar/SKILL.md` (171 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Operational rubric — the demo test, S/A/B/C/D scale, 5 named composition pitfalls, Tier 1/Tier 2 benchmark anchors, fast-vs-careful decision rule, claim-of-done preconditions. Auto-loads on UI work. |
| **Universal methodology** | (1) Single demo test (anchored on a specific imaginable audience). (2) S/A/B/C/D grading with concrete reference anchors per tier. (3) Five composition pitfalls each with project-history-anchored examples (duplication / orphan / tone-mismatch / hierarchy-violation / residue). (4) Tier 1 chrome benchmark table + Tier 2 domain benchmark table — each with "what to steal." (5) Fast vs careful split. (6) Five claim-of-done preconditions (screenshot, lint, tests, pitfall scan, benchmark named). |
| **Configuration knobs** | `DEMO_TEST_AUDIENCE` (who the user demos to), `TIER_1_BENCHMARKS` (with "what to steal" per ref), `TIER_2_BENCHMARKS_WITH_DIMENSION` (per-surface-category), `ANTI_REFERENCES` (apps the design must NOT look like), `COMPOSITION_PITFALL_EXAMPLES` (project-history examples for each pitfall), `QUALITY_GRADE_TARGETS_BY_SURFACE` (e.g. core flows = S, settings = A min), `DONE_PRECONDITIONS_CHECKLIST` |
| **Triggers** | Auto-loads when work touches owner-facing / member-facing UI, persona prompts that shape UX, onboarding flows, anything visible to recruited users. Skip for internal scripts / type-only fixes / lint cleanups / server-only logic. |
| **Dependencies** | reads: `design-north-star.md`. Loaded by: every UI agent (`ux-reviewer`, `interaction-audit`, `a11y-audit`, `flow-auditor`, `flow-ux-reviewer`, `pages-audit`, `product-designer`). |
| **Output** | Skill (no artifact). Surfaces grading rubric + named pitfalls + benchmarks in the dispatching agent's report. |

#### Skill 2 — `journey-audit/SKILL.md` (114 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | The mandatory prior-surfaces map before designing or auditing — every surface user touched before the target, with type classification + forbidden-pattern matrix. Auto-loads on design / audit / flow files. |
| **Universal methodology** | (1) Enumerate prior surfaces from first app open via project-specific globs. (2) Classify each as one of six types (first-touch / daily-driver / settings / error / promotional / bridge). (3) Build journey map table with verbatim copy. (4) Apply forbidden-pattern matrix by target type. (5) Cross-surface duplication grep. STOP if map can't complete — read more. |
| **Configuration knobs** | `SURFACE_DIR_STRUCTURE` (`app/wizard/**`, `app/(owner)/**`, etc.), `TRANSLATION_FILE_LOCATIONS`, `NARRATION_FILE_LOCATIONS`, `IN_PRODUCT_ASSISTANT_CHARACTER` (the persona name for forbidden-pattern matrix), `SURFACE_TYPES_IN_USE` (subset of 6 standard types — some products lack `bridge` or `promotional`), `JOURNEY_MAP_OUTPUT_SECTION_NAME` (Section 0 of spec / inline preamble in audit) |
| **Triggers** | Designing new surface, auditing existing one, auditing whole arc. Skip for pure visual-polish where surface type is obvious + uncontested, and code-only refactors. |
| **Dependencies** | reads: `forbidden-phrases.txt`, binding memories ("daily-vs-onboarding-copy", "execution-without-judgment", "assistant-intro-onboarding-only"). Loaded by: `product-designer`, `flow-auditor`, `ux-reviewer`, `interaction-audit`, `flow-ux-reviewer`. |
| **Output** | Skill (no artifact directly). Surfaces Section 0 of spec/audit doc — journey map table + target classification + forbidden-pattern matrix application. |

#### Skill 3 — `element-reuse-check/SKILL.md` (98 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Gate A — verdict matrix on reusing existing strings / components on a new surface. Catches first-touch copy reused on daily-driver class of bug at design time. |
| **Universal methodology** | (1) Grep for existing usage with file:line evidence. (2) Classify both contexts via journey-audit taxonomy. (3) Apply universal verdict matrix (e.g. first-touch → daily-driver = REJECT). (4) Document as Section 0a of spec doc OR inline gap-class entry in audit. REJECT verdicts are binding. CAUTION verdicts demand written rationale. |
| **Configuration knobs** | `USER_VISIBLE_CODE_DIRS` (grep search paths), `SPEC_SECTION_HEADER_FOR_REUSE_AUDIT` (Section 0a / equivalent name), `REUSE_HOT_SPOT_PATHS` (high-frequency reuse paths — translation files, common components) |
| **Triggers** | Whenever a proposed reuse of a user-visible string / component / copy pattern is on the table. Skip for fresh-authored strings, structural-only component reuse (e.g. `<GlassCard>`), pure-engine reuse. |
| **Dependencies** | reads: `journey-audit`, `forbidden-phrases.txt`. Loaded by: `product-designer`, `ux-reviewer`, `flow-auditor`, `interaction-audit`. |
| **Output** | Skill (no artifact). Surfaces verdict-matrix table as Section 0a of spec or inline gap-class row in audit. |

#### Skill 4 — `persona-lens/SKILL.md` (125 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Gate B — three outside-eyes tests applied to every visible copy element (Day-30 / Partner-voice / Stranger). All three must pass; one fail = REWRITE. Auto-loads when editing translation / narration / copy files. |
| **Universal methodology** | (1) Enumerate every copy element on target surface. (2) Apply three orthogonal tests — Day-30 (frequency-jaded), Partner (named voice reference like Apple Photos / Telegram), Stranger (assumes user already knows the assistant). (3) Build audit table per element. (4) Hard-bound forbidden-phrase check (mirrors deny-list). REWRITE verdicts are binding. Run at BOTH design + audit time — drift catch. |
| **Configuration knobs** | `PRODUCT_HAS_VOICE` (boolean — gates the skill), `BRAND_VOICE_REFERENCE` (the named "Partner voice" reference — Apple Photos / Telegram / a specific film character / etc.), `VOICE_ANTI_REFERENCES` (customer-service register, apology register, performance register), `USAGE_FREQUENCY_FRAMING` (day-30 for daily-driver products; "did this read OK under cognitive load" for checkout; etc.), `TRIAD_OVERRIDE` (alternative test triads — CLI tool: first-run/power-user/regression-debugger; doc site: skimmer/focused/reference) |
| **Triggers** | Auto-loads on translation / narration / copy file edits (frontmatter path glob). Loaded explicitly by `product-designer`, `ux-reviewer`, `flow-auditor`, `interaction-audit`, `flow-ux-reviewer`. Skip for pure-engineering, debug labels, log strings. |
| **Dependencies** | reads: `journey-audit`, `element-reuse-check`, `forbidden-phrases.txt`. Loaded by: every designer + reviewer agent. Hook companion: `check-forbidden-phrases.sh`. |
| **Output** | Skill (no artifact). Surfaces audit table (Day-30 / Partner / Stranger / Verdict per copy element) as Section 0b of spec or inline gap-class entries in audit. |

#### Skill 5 — `design-system/SKILL.md` (331 LOC — second-largest)

| Dimension | Content |
|---|---|
| **Purpose** | Theme tokens / color system / styling-system conventions / native chrome primitives / animation presets / RN library gotchas + i18n conventions. Auto-loads on theme / component / widget file edits. |
| **Universal methodology** | (1) North-star reference (Apple iOS 26 + Telegram, or platform-equivalent). (2) Inventory of native chrome primitives (NativeTabs, GlassCard, BottomSheetModal, useConfirmDialog) — always-reach-for-these before rolling your own. (3) Token architecture (single source of truth → generated outputs for tailwind / CSS). (4) Surface hierarchy (background / card / sheet / elevated card / frosted-glass-over-camera). (5) Motion principles + canonical animation presets. (6) Status color system. (7) Quality tiers per surface category. (8) Project-specific library gotchas (RN-primitives-select doesn't reset, bottom-sheet snap-point hot-reload, etc.). (9) Interaction-semantics 4Q header docstring requirement. (10) Memoization rules. (11) i18n conventions. |
| **Configuration knobs** | `DESIGN_SYSTEM_TOKENS_PATH`, `THEME_CONVENTION`, `NATIVE_CHROME_PRIMITIVES_LIST`, `CHROME_PRIMITIVE_PATHS` (per-primitive file paths), `THEME_GENERATION_COMMAND` (`yarn generate:theme` or equivalent), `SURFACE_HIERARCHY_LEVELS` (back-to-front layering rules), `MOTION_LIBRARY` (Reanimated 4 / Framer Motion / CSS / native), `ANIMATION_PRESET_FILE_PATH`, `STATUS_COLOR_SYSTEM` (per-status colors + iconography), `QUALITY_TIER_BY_SURFACE` (which surfaces target which letter grade), `RN_LIBRARY_GOTCHAS_LIST` (project-specific library footguns), `INTERACTION_SEMANTICS_4Q_DOCSTRING_REQUIRED` (boolean), `I18N_CONVENTIONS` |
| **Triggers** | Auto-loads on `lib/theme/**`, `components/ui/**`, `lib/widgets/primitives/**`. Skip for non-UI work. |
| **Dependencies** | reads: `design-north-star.md`. Loaded by: every UI agent. |
| **Output** | Skill (no artifact). Surfaces design-system reference in dispatching agent's reasoning. |

#### Skill 6 — `ruthless-ux-autoloop/SKILL.md` (170 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Continuous iterative review-and-polish autoloop. User-invocable (`/ruthless-ux-autoloop`). Drives a flow end-to-end on a clean fixture, grades, picks ONE highest-ROI fix, applies, commits, re-runs — until award-quality OR iteration cap reached. |
| **Universal methodology** | Three scrutiny layers per iteration: (L1) reviewer agent macro grading; (L2) composition scan + semantic-count audit; (L3) backend-truth probe. Per-iteration: sanity gate → reset fixture → mint IDs → apply one fix → dual-flow capture → L2 scan → L1 grade → L3 probe → write report → pick next fix (highest-ROI) → commit atomically → ledger update → schedule next. Hard cap 10 iterations. Soft cap 6. Termination on award-grade OR cap OR hard failure OR new user message. |
| **Configuration knobs** | `FIXTURE_RESET_COMMAND` (project-specific seed pipeline), `FLOW_CAPTURE_HARNESS` (Maestro / Playwright / etc.), `REVIEWER_AGENT_NAME` (which reviewer agent powers L1), `BACKEND_TRUTH_PROBE_QUERIES` (project-specific SQL / API calls), `SEMANTIC_COUNT_AUDIT_PATTERNS` (when does a UI count lie — pipeline subset vs user-truth), `AUDIT_REPORT_DIR_CONVENTION` (`.claude/audits/<flow>/R<N>-<RUN_ID>/`), `ITERATION_CAP_HARD`, `ITERATION_CAP_SOFT`, `SAFETY_INVARIANTS` (do-not-edit list — migrations / fixtures / yaml / etc.) |
| **Triggers** | User-invocable for iterative UI polish toward award-tier quality. Skip for single-shot audit (use the reviewer agent directly) or single-pass audit (use the auto-capture skill). |
| **Dependencies** | reads: `quality-bar` (5 pitfalls source of truth), `design-audit-routing.md` (cross-rubric translation), `design-north-star.md`. Drives: `flow-ux-reviewer` (L1), `ux-reviewer` (L1 for single-screen drilldowns). |
| **Output** | Multi-iteration ledger at `.claude/audits/<flow>/AUTOLOOP-LOG.md` + per-iteration report.md + manifest.json + screenshots + one git commit per iteration. |

#### Skill 7 — `flow-ux-audit/SKILL.md` (124 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | User-invocable (`/flow-ux-audit`) automated UX audit of an owner setup flow on iOS simulator via Maestro. Parameterized by vertical. Screenshots every state → feeds to `flow-ux-reviewer`. ~3-5 min runtime. |
| **Universal methodology** | (1) Verify capture-harness build is up. (2) Seed fixture. (3) Mint run-id + audit dir. (4) Run YAML capture flow. (5) Build manifest. (6) Dispatch `flow-ux-reviewer` with audit dir + manifest. Vertical-parameterized: each project-vertical has its own YAML / fixture / screen sequence / known terminals. |
| **Configuration knobs** | `CAPTURE_AUTOPLAY_BUILD_ENV` (env vars baked at bundle time for autoplay), `METRO_TARGET_DETECTION_COMMAND`, `SEED_LAYER_COMMAND_BY_TIER` (`yarn e2e:seed:layer1` etc.), `MAESTRO_YAML_PATH_BY_VERTICAL`, `AUDIT_DIR_CONVENTION_BY_VERTICAL` (`.claude/audits/<flow>/$RUN_ID`), `MANIFEST_SCHEMA_VERSION`, `CANONICAL_SCREEN_SEQUENCE_BY_VERTICAL` (named states 01-NN), `KNOWN_GOTCHAS` (project-specific Maestro quirks per flow) |
| **Triggers** | User explicitly asks for owner setup flow audit / walkthrough grade / regression check. Skip for member-side flows, physical-device audits, fixture authoring. |
| **Dependencies** | reads: project's existing fixtures + Maestro YAMLs. Spawns: `flow-ux-reviewer`. |
| **Output** | Audit dir with manifest.json + screenshots + report.md (produced by reviewer). |

#### Skill 8 — `storybook-story/SKILL.md` (145 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Add `.stories.tsx` files for shared UI components matching the project's existing Storybook convention. Auto-loads on `components/ui/**`, `lib/widgets/primitives/**`, `.storybook/**`. |
| **Universal methodology** | Read closest sibling story first. Author story file matching convention (variant matrix × size × state × dark-default theme). Required exports: `meta` with argTypes + sensible default args; `Default`; `AllVariants` (matrix); per-state stories (`Loading` / `Disabled` / `Error` / `Empty` / `LongContent`). Verify locally via `yarn storybook`. Stay under file-size ceiling. |
| **Configuration knobs** | `STORYBOOK_FRAMEWORK` (`@storybook/react-vite` / equivalent), `STORYBOOK_TITLE_CONVENTION` (`UI/<Name>` / `Widgets/<Name>` / etc.), `STORYBOOK_DARK_DEFAULT` (boolean), `STORYBOOK_RN_WEB_RESOLUTION` (is it a React-Native project rendered via react-native-web?), `STORYBOOK_REFERENCE_STORY_PATHS` (per-pattern reference: variant-matrix / composition / form-field / typography / data-viz), `STATE_SPECTRUM_PER_COMPONENT_KIND` (which states each component kind needs covered) |
| **Triggers** | Adding new component to component library, adding new variant/size/state to existing component with story, design-debt sweep calls out story gap. Skip for per-screen surfaces (Storybook is for primitives), one-off compositions, native-only views. |
| **Dependencies** | reads: existing reference stories, `design-system`, `design-north-star.md`. |
| **Output** | New `.stories.tsx` file sibling to component. |

### 1.3 Rules (5)

#### Rule 1 — `design-north-star.md` (65 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | The single binding statement of "what does S-tier look like on this platform" — names specific reference apps the whole project grades chrome against. |
| **Universal methodology** | (1) One-sentence north-star statement naming specific reference apps. (2) Per-surface-type chrome reference table (tab bar / cards / list rows / sheets / modal alerts / empty states / motion / color / typography / iconography — each row names the specific reference). (3) Anti-patterns table (specific design moves the rule REJECTS). (4) Verification checklist (4 steps before claiming done). (5) Where to find primitives. (6) Per-surface evolution notes (e.g. "this primitive was rolled back on date X because Y"). |
| **Configuration knobs** | `TIER_1_BENCHMARKS` (Apple iOS 26 + Telegram, or platform equivalent), `PRIMARY_SURFACE_PLATFORM`, `PER_SURFACE_CHROME_REFERENCE_TABLE`, `ANTI_PATTERNS_LIST` (specific design moves to reject — usually project-experience-derived), `PRIMITIVES_INVENTORY` (where the chrome primitives live in the codebase) |
| **Triggers** | Every UI design decision references this rule. Always-on for visible surfaces. Skip for backend / lib / type-only work. |
| **Dependencies** | Referenced by: `ux-reviewer`, `interaction-audit`, `a11y-audit`, `flow-auditor`, `flow-ux-reviewer`, `pages-audit`, `product-designer`, `design-system`, `quality-bar`, `design-audit-routing.md`, `visual-verification.md`. |
| **Output** | Rule (no artifact). Sets the binding reference for every visual decision. |

#### Rule 2 — `design-audit-routing.md` (94 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Decision tree for "which audit agent for which question." Includes canonical pipeline order for multi-audit UI batches + cross-rubric translation table + hook-catches-instead-of-agent guidance. |
| **Universal methodology** | (1) Routing table — question shape → agent → one-line why. (2) Refusal behaviors per agent (what each agent will NOT handle and where it routes). (3) Canonical pipeline order: `token-audit → semantic+a11y || → visual` (with arc / multi-section additions). (4) Shared skills table (which skills auto-load for which agents). (5) Cross-rubric translation map (S/A/B/C/D ↔ Crit/High/Med/Low ↔ S0/S1/S2 → composite grade). (6) Hooks-that-prevent-findings table. |
| **Configuration knobs** | `AUDIT_AGENT_INVENTORY` (this project's actual agents), `TYPICAL_QUESTION_SHAPES` (user phrasings), `REFUSAL_BEHAVIOR_TABLE_PER_AGENT`, `CANONICAL_PIPELINE_ORDER`, `CROSS_RUBRIC_TRANSLATION_TABLE`, `HOOK_INVENTORY_WITH_OVERRIDES` |
| **Triggers** | Read before dispatching ANY design-related agent. Skip if only 1-2 audit agents exist (trivially routable). |
| **Dependencies** | references every audit agent + every UI rule. |
| **Output** | Rule (no artifact). Decision authority for agent dispatching. |

#### Rule 3 — `visual-verification.md` (37 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | After UI edits, see what you built before reporting done. CLI-first capture discipline. Reporting contract: include final screenshot path. |
| **Universal methodology** | (1) Pick device target via dev-server inspection. (2) Capture via cheap CLI path (returns file path, not bytes — token discipline). (3) Compare against approved design + benchmark. (4) Iterate if not. (5) Report final screenshot path. Subsection: CLI > MCP for screen inspection (5-20k token savings per call). Subsection: per-platform RN/log gotchas. |
| **Configuration knobs** | `DEVICE_TARGET_DETECT_COMMAND`, `CAPTURE_COMMAND_PRIMARY` (sim / web headless / etc.), `CAPTURE_COMMAND_PHYSICAL_DEVICE`, `HIERARCHY_INSPECTION_COMMAND_CHEAP` (CLI), `HIERARCHY_INSPECTION_COMMAND_EXPENSIVE` (MCP — only when needed), `LOG_INSPECTION_PATH` (per-platform), `SCREENSHOT_PATH_CONVENTION` (`/tmp/<name>.png` or similar) |
| **Triggers** | After every UI edit. Skip when no visible output is produced (pure library / backend / type-only). |
| **Dependencies** | Referenced by: every UI audit agent + `product-designer` + `quality-bar`. |
| **Output** | Rule (no artifact). Sets the see-before-claim discipline. |

#### Rule 4 — `forbidden-phrases.txt` (45 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Voice/tone deny-list — one phrase per line. Match-source for `check-forbidden-phrases.sh` hook + `persona-lens` skill's hard-bound check. |
| **Universal methodology** | Two-axis structure: (Axis 1) universal AI-slop denials (Hi / Hello / Welcome / I'm here to help / etc.); (Axis 2) project-specific voice violations (the assistant-name self-introduction phrases, tone-register violations specific to this product's voice). One phrase per line, `#` comments. Override convention: per-line `// allow-forbidden: <reason>` or per-file exemption (e.g. the one assistant-intro surface file is the canonical exempt path). |
| **Configuration knobs** | `PRODUCT_HAS_VOICE` (boolean, gates everything), `IN_PRODUCT_ASSISTANT_CHARACTER` (drives self-introduction phrases), `BRAND_FORBIDDEN_PHRASES` (project-specific Axis 2 entries), `EXEMPT_SURFACES_BY_PATH` (which paths auto-exempt — e.g. wizard intro file), `OVERRIDE_SYNTAX` (per-line override comment shape) |
| **Triggers** | The hook runs on translation / narration / copy / persona file edits. Skip for pure-engineering, debug labels, log strings. |
| **Dependencies** | Source-of-truth for: `check-forbidden-phrases.sh` hook + `persona-lens` skill. Referenced by: `journey-audit`. |
| **Output** | Rule (text file). Drives hook + skill enforcement. |

#### Rule 5 — `frontend-components.md` (12 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | Tiny rule pinning frontend conventions — which page-wrapper components to use; search-before-create discipline; no inline wrappers around stable callbacks. Auto-loads on `app/**/*.tsx`, `lib/*/components/**`. |
| **Universal methodology** | (1) Owner screens use specific shared page wrappers (named). (2) Before creating a component: search `components/ui/` and `lib/*/components/`. (3) Before creating a hook: search `lib/*/hooks/`. (4) No inline wrappers around `useCallback` refs — pass directly. |
| **Configuration knobs** | `SHARED_PAGE_WRAPPER_NAMES`, `COMPONENT_SEARCH_PATHS`, `HOOK_SEARCH_PATHS` |
| **Triggers** | Auto-loads on frontend component file edits. Skip for non-frontend files. |
| **Dependencies** | Cross-references `design-system` skill for full taxonomy. |
| **Output** | Rule (no artifact). Conventions reminder. |

### 1.4 Hooks (4)

#### Hook 1 — `check-forbidden-phrases.sh` (67 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | PostToolUse Write|Edit hook blocking forbidden phrases on owner-facing surfaces. Source of truth: `forbidden-phrases.txt`. Auto-exempt: the one wizard intro file. Override per-line: `// allow-forbidden: <reason>`. |
| **Universal methodology** | (1) Read changed file path from tool input JSON. (2) Filter to `.ts`/`.tsx` only. (3) Apply path-based exemptions (test files, generated, the one intro surface). (4) Filter to translation / narration / copy / persona files. (5) Build alternation regex from `forbidden-phrases.txt`. (6) Grep for matches inside string literals with word boundaries. (7) Filter out `allow-forbidden`-overridden lines. (8) BLOCK on any violation. |
| **Configuration knobs** | `FORBIDDEN_PHRASES_FILE_PATH`, `EXEMPT_FILE_PATHS` (intro surface, tests, generated), `ENFORCEMENT_FILE_PATH_PATTERNS` (translation / narration / copy / persona), `OVERRIDE_COMMENT_SYNTAX` (`// allow-forbidden:`) |
| **Triggers** | Edit/Write tool calls on matching file paths. Skip for non-matching files. |
| **Dependencies** | reads: `forbidden-phrases.txt`. Pairs with: `persona-lens` skill (runtime check after hook). |
| **Output** | Hook (no artifact). BLOCKED stderr message + non-zero exit on violation. |

#### Hook 2 — `check-token-only.sh` (51 LOC) — referred to as `check-design-tokens.sh` in the task brief, but actual filename is `check-token-only.sh`

| Dimension | Content |
|---|---|
| **Purpose** | PostToolUse Write|Edit hook blocking raw hex / rgba color literals outside the theme file. Override per-line: `// allow-color: <reason>`. |
| **Universal methodology** | (1) Read changed file path. (2) Filter to `.ts`/`.tsx`. (3) Exempt theme source + tests + generated + scripts. (4) Grep for `'#[0-9a-fA-F]{3,8}'` and `rgba?([0-9]` inside string literals. (5) Filter out `allow-color`-overridden lines. (6) BLOCK on any violation. |
| **Configuration knobs** | `THEME_FILE_EXEMPT_PATH`, `ADDITIONAL_EXEMPT_PATHS` (tests, generated, scripts), `OVERRIDE_COMMENT_SYNTAX` (`// allow-color:`), `RAW_COLOR_PATTERNS` (hex regex + rgba/rgb/hsl/hsla functions — depends on styling system) |
| **Triggers** | Edit/Write tool calls on matching file paths. Skip for non-matching. |
| **Dependencies** | Pairs with: `design-token-auditor` agent (periodic sweep). |
| **Output** | Hook (no artifact). BLOCKED stderr message + non-zero exit on violation. |

#### Hook 3 — `check-nativetabs-sf-icon.sh` (72 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | PostToolUse Write|Edit hook blocking native-tab-bar icon usages that lack the system-symbol prop. Enforces "iOS chrome icons must be SF Symbols" per design-north-star. Override: `// allow-sf: <reason>`. |
| **Universal methodology** | (1) Read changed file path. (2) Filter to `.tsx`/`.ts`. (3) Exempt tests + generated. (4) Cheap pre-filter — bail if file doesn't mention the native-tabs icon component at all. (5) Multi-line-aware block detection via awk — find each `<NativeTabs.Trigger.Icon ...>` opening tag through `>` or `/>`, concat lines, check for `sf=` and `allow-sf`. (6) BLOCK on any violation. |
| **Configuration knobs** | `PLATFORM_CHROME_ICON_COMPONENT` (`NativeTabs.Trigger.Icon` for this project; varies per platform), `PLATFORM_SYSTEM_ICON_PROP` (`sf=` for SF Symbols), `OVERRIDE_COMMENT_SYNTAX`, `EXEMPT_FILE_PATHS` |
| **Triggers** | Edit/Write on files mentioning the platform-chrome-icon component. Skip otherwise. |
| **Dependencies** | Enforces: `design-north-star.md` §"Iconography". |
| **Output** | Hook (no artifact). BLOCKED stderr on violation. |

#### Hook 4 — `check-no-expo-blur.sh` (50 LOC)

| Dimension | Content |
|---|---|
| **Purpose** | PostToolUse Write|Edit hook blocking legacy-blur-API imports — enforces "use the system glass primitive, not the legacy blur API." Override: `// allow-blur: <reason>`. |
| **Universal methodology** | (1) Read changed file path. (2) Filter to `.ts`/`.tsx`. (3) Exempt theme source + tests + generated + scripts. (4) Grep for legacy blur import pattern. (5) Filter out `allow-blur`-overridden lines. (6) BLOCK on any violation. |
| **Configuration knobs** | `LEGACY_BLUR_PACKAGE` (`expo-blur` for this project; varies per platform), `MODERN_GLASS_PRIMITIVE_NAME` (`<GlassCard>`), `OVERRIDE_COMMENT_SYNTAX`, `EXEMPT_FILE_PATHS` |
| **Triggers** | Edit/Write on files. Skip for non-matching. |
| **Dependencies** | Enforces: `design-north-star.md` §"Anti-patterns". |
| **Output** | Hook (no artifact). BLOCKED stderr on violation. |

---

## 2. Knob map

This is the critical deliverable — every unique configuration knob across the 26 artifacts, with type, possible values, consumers, and capture method. Knobs are organized by "topic clusters" for the interview design downstream. Total: **41 distinct knobs**.

### Cluster A — Platform + dev-loop

#### `PRIMARY_SURFACE_PLATFORM`
- **Type**: enum
- **Description**: The user-facing platform the project ships on. Drives capture path, native primitives, accessibility minimums, Tier 1 chrome reference candidates, and which hooks even apply.
- **Possible values**: `iOS` / `Android` / `iOS+Android (RN/Flutter)` / `web` / `desktop-macOS` / `desktop-Windows` / `desktop-Linux` / `desktop-cross-platform` / `CLI` / `TUI` / `browser-extension` / `multi`
- **Feeds artifacts**: `ux-reviewer`, `interaction-audit`, `a11y-audit`, `flow-auditor`, `pages-audit`, `product-designer`, `design-system`, `design-north-star.md`, `visual-verification.md`, `check-nativetabs-sf-icon.sh`, `check-no-expo-blur.sh`
- **Capture method**: Interview question A1 — "What does this project ship on?"

#### `CAPTURE_COMMAND_PRIMARY`
- **Type**: string (shell command)
- **Description**: Exact CLI invocation to capture a screenshot on the primary dev surface. Token-disciplined (returns file path, not bytes).
- **Possible values**: `xcrun simctl io <udid> screenshot <path>` (iOS sim) / `adb exec-out screencap -p > <path>` (Android emulator) / `playwright screenshot <url> <path>` (web headless) / `screencapture <path>` (macOS desktop) / etc.
- **Feeds artifacts**: every audit agent + `visual-verification.md` + `product-designer`
- **Capture method**: Interview Phase 1 scan — detect from `ps aux | grep`, `package.json` scripts, infer from platform.

#### `CAPTURE_COMMAND_PHYSICAL_DEVICE`
- **Type**: string (shell command) or "N/A"
- **Description**: Capture path for physical device (when the project targets one — physical iPhone, real Android device, real desktop).
- **Possible values**: `bash scripts/iphone-screenshot.sh <path>` (WDA-based for iOS 17+) / `adb -s <serial> exec-out screencap -p > <path>` / "N/A"
- **Feeds artifacts**: `ux-reviewer`, `interaction-audit`, `a11y-audit`, `flow-auditor`, `pages-audit`, `product-designer`, `visual-verification.md`
- **Capture method**: Interview question — "Do you ever audit on a physical device? If yes, what's the screenshot command?"

#### `DEVICE_TARGET_DETECT_COMMAND`
- **Type**: string (shell command)
- **Description**: How agents detect whether the dev server is currently targeting the simulator or a physical device.
- **Possible values**: `ps aux | grep "expo run"` (RN / Expo) / `scripts/detect-metro-target.sh` (custom) / "always sim" / "always device"
- **Feeds artifacts**: every audit agent
- **Capture method**: Interview Phase 1 scan + question.

#### `HIERARCHY_INSPECTION_COMMAND`
- **Type**: string (shell command)
- **Description**: Cheap (CLI) view-hierarchy inspection. Used by interaction / a11y / pages audits to find specific elements without paying for full JSON dumps.
- **Possible values**: `maestro --device <udid> hierarchy --compact` (iOS sim) / Chrome DevTools accessibility tree (web) / `axe-core` JSON (web) / Xcode Accessibility Inspector (iOS native) / `uiautomator dump` (Android)
- **Feeds artifacts**: `ux-reviewer`, `interaction-audit`, `a11y-audit`, `pages-audit`, `product-designer`, `visual-verification.md`
- **Capture method**: Interview Phase 1 scan + question.

#### `LOG_INSPECTION_PATH`
- **Type**: string
- **Description**: Where to read application logs (RN console.log goes to Metro stdout, not iOS unified logging — these are platform-specific gotchas).
- **Possible values**: `tail -f metro.log` / `npx react-native log-ios` / `os_log` (iOS native) / browser DevTools console / etc.
- **Feeds artifacts**: `visual-verification.md`
- **Capture method**: Interview question (optional).

#### `DEV_LOOP_TOOL`
- **Type**: enum
- **Description**: The dev-loop / hot-reload mechanism the project uses.
- **Possible values**: `Metro` (RN) / `Vite` / `Webpack` / `Turbopack` / `esbuild` / `Docker compose` / `native rebuild` / `none`
- **Feeds artifacts**: `visual-verification.md`, `flow-ux-audit` (skill)
- **Capture method**: Phase 1 scan — read `package.json` scripts.

### Cluster B — Benchmarks + voice

#### `TIER_1_BENCHMARKS`
- **Type**: list of 2-3 named apps with "what to steal" per each
- **Description**: The platform/chrome reference apps every screen is graded against. Specific named apps the user has installed and uses.
- **Possible values**: e.g. `["Apple iOS 26 Music/Photos/Settings/Wallet", "Telegram on iOS 26"]` for iOS / `["Linear", "Stripe", "Vercel"]` for web / `["Raycast", "gh CLI"]` for CLI / etc.
- **Feeds artifacts**: `ux-reviewer`, `interaction-audit`, `a11y-audit`, `flow-ux-reviewer`, `pages-audit`, `product-designer`, `design-system`, `design-north-star.md`, `quality-bar`, `ruthless-ux-autoloop`
- **Capture method**: Interview question B1 — "When you say S-tier, which specific apps do you mean?"

#### `TIER_2_BENCHMARKS_WITH_DIMENSION`
- **Type**: list of named apps tagged with the dimension/surface-type they anchor
- **Description**: Per-surface-category domain references. Each tagged with what dimension it's the bar on.
- **Possible values**: e.g. `["WHOOP onboarding (rhythm)", "Linear (text hierarchy)", "Things 3 (empty states teach)", "Stripe checkout (form flow)"]`
- **Feeds artifacts**: `ux-reviewer`, `flow-ux-reviewer`, `pages-audit`, `product-designer`, `design-system`, `design-north-star.md`, `quality-bar`, `ruthless-ux-autoloop`
- **Capture method**: Interview question B2 — "For onboarding / dashboard / settings / empty-state / etc., which apps do you grade against?"

#### `ANTI_REFERENCES`
- **Type**: list of named products / patterns
- **Description**: Apps the design must NOT look like. Useful for ruling out tempting-but-wrong directions.
- **Possible values**: e.g. `["Material You / Android-y card stacking", "Stripe Dashboard's data density", "Linear's keyboard density"]`
- **Feeds artifacts**: `product-designer`, `design-north-star.md`, `quality-bar`
- **Capture method**: Interview question B3 — "Which apps do you specifically NOT want to be compared to?"

#### `BRIDGE_REFERENCE_APPS`
- **Type**: list of named flows
- **Description**: References for elegant arc transitions (the bridge surfaces in `flow-ux-reviewer`).
- **Possible values**: e.g. `["Apple iCloud onboarding", "Telegram phone-number flow", "Stripe checkout post-payment"]`
- **Feeds artifacts**: `flow-ux-reviewer`, `flow-auditor`
- **Capture method**: Interview question (optional add-on to B2).

#### `PRODUCT_HAS_VOICE`
- **Type**: boolean
- **Description**: Does the product have an authored voice / brand / tone discipline? Drives whether persona-lens + forbidden-phrases ship.
- **Possible values**: `true` / `false`
- **Feeds artifacts**: `persona-lens`, `forbidden-phrases.txt`, `check-forbidden-phrases.sh`, `journey-audit`, `product-designer`
- **Capture method**: Interview question — "Does this product have a 'voice' the team enforces, or is copy purely functional?"

#### `BRAND_VOICE_REFERENCE`
- **Type**: string (named reference)
- **Description**: The specific named voice the Partner test in persona-lens grades against.
- **Possible values**: e.g. `"Apple Photos empty-state voice"` / `"Telegram product voice"` / `"the partner-companion from Her"` / `"Stripe docs voice"` / `"GitHub CLI voice"` / etc.
- **Feeds artifacts**: `persona-lens`
- **Capture method**: Interview question (if `PRODUCT_HAS_VOICE=true`) — "Whose voice does this product aspire to sound like?"

#### `VOICE_ANTI_REFERENCES`
- **Type**: list
- **Description**: Register/tones to specifically avoid (customer-service, apology, performance, tutorial).
- **Possible values**: e.g. `["customer-service register ('I'm here to help')", "apology register", "performance register ('crushing it!')"]`
- **Feeds artifacts**: `persona-lens`
- **Capture method**: Interview question (if `PRODUCT_HAS_VOICE=true`).

#### `BRAND_FORBIDDEN_PHRASES`
- **Type**: list of strings
- **Description**: Project-specific Axis 2 phrases (layered on top of universal AI-slop deny-list). The phrases this product has explicitly forbidden.
- **Possible values**: e.g. specific assistant self-introduction phrases, specific tone violations.
- **Feeds artifacts**: `forbidden-phrases.txt`, `check-forbidden-phrases.sh`, `persona-lens`
- **Capture method**: Interview question + Phase 1 mining (look at git log for copy-revert commits).

#### `IN_PRODUCT_ASSISTANT_CHARACTER`
- **Type**: boolean + name + intro-surface-path
- **Description**: Does the product have a named in-product assistant character? If yes, drives daily-driver re-greeting trap detection in journey-audit + persona-lens + hooks.
- **Possible values**: `{ has: true, name: "<assistant-name>", introSurfacePath: "<file>" }` / `{ has: false }`
- **Feeds artifacts**: `journey-audit`, `persona-lens`, `forbidden-phrases.txt`, `check-forbidden-phrases.sh`
- **Capture method**: Interview question — "Does your product have a named assistant character?"

#### `USAGE_FREQUENCY_FRAMING`
- **Type**: enum
- **Description**: What time-frame does the Day-30 test use? Daily-driver products use day-30; checkout flows use "under cognitive load"; etc.
- **Possible values**: `daily-driver-day-30` / `transactional-single-use` / `weekly-tool` / `monthly-tool` / `power-user-daily`
- **Feeds artifacts**: `persona-lens`
- **Capture method**: Interview question.

### Cluster C — Design system

#### `DESIGN_SYSTEM_MATURITY`
- **Type**: enum
- **Description**: How mature is the design system? Drives whether design-token-auditor + token-hook + design-system skill ship.
- **Possible values**: `none` / `partial` (some tokens, lots of drift) / `mature` (single source of truth, generation pipeline)
- **Feeds artifacts**: `design-token-auditor`, `check-token-only.sh`, `design-system`, `pages-audit`
- **Capture method**: Phase 1 scan + question.

#### `DESIGN_SYSTEM_TOKENS_PATH`
- **Type**: file path
- **Description**: Where semantic tokens live (single source of truth).
- **Possible values**: e.g. `lib/theme/tokens.ts` / `src/styles/tokens.css` / `tailwind.config.js` extend block / `tokens.json` / etc.
- **Feeds artifacts**: `design-token-auditor`, `check-token-only.sh`, `design-system`, `a11y-audit` (for contrast computation)
- **Capture method**: Phase 1 scan — look for `tokens`, `theme`, `colors` files; verify with user.

#### `THEME_CONVENTION`
- **Type**: enum
- **Description**: What styling convention applies.
- **Possible values**: `semantic-token` / `palette` / `CSS-variable` / `Tailwind` / `Tailwind+NativeWind` / `SCSS` / `styled-components` / `Emotion` / `CSS-modules` / `vanilla-extract` / `RN StyleSheet`
- **Feeds artifacts**: `design-token-auditor`, `design-system`, `storybook-story`
- **Capture method**: Phase 1 scan.

#### `THEME_GENERATION_COMMAND`
- **Type**: string (or "none")
- **Description**: If the project has a token-generation step (`yarn generate:theme` or similar), the command.
- **Possible values**: e.g. `yarn generate:theme` / `npx style-dictionary build` / "none"
- **Feeds artifacts**: `design-system`
- **Capture method**: Phase 1 scan — read `package.json`.

#### `NATIVE_CHROME_PRIMITIVES_LIST`
- **Type**: list of named primitives
- **Description**: The native chrome primitives the project wraps (always-reach-for-these-first).
- **Possible values**: e.g. for iOS RN: `[NavTabs (wraps NativeTabs), GlassCard, BottomSheetModal, useConfirmDialog]`; for web: `[Dialog, Sheet, Tooltip from Radix]`; etc.
- **Feeds artifacts**: `design-system`, `design-north-star.md`, `pages-audit`
- **Capture method**: Phase 1 scan — look for primitive files; verify with user.

#### `CHROME_PRIMITIVE_PATHS`
- **Type**: map (primitive name → file path)
- **Description**: Per-primitive file paths. So agents can grep for them.
- **Possible values**: e.g. `{NavTabs: "components/NavTabs.tsx", GlassCard: "lib/widgets/primitives/GlassCard.tsx"}`
- **Feeds artifacts**: `design-system`, `pages-audit`
- **Capture method**: Phase 1 scan.

#### `MOTION_LIBRARY`
- **Type**: enum
- **Description**: The animation library — drives motion-language-drift detection + reduced-motion checks.
- **Possible values**: `Reanimated 4` / `Reanimated 3` / `Framer Motion` / `CSS transitions` / `Web Animations API` / `native UIKit/Compose` / `none`
- **Feeds artifacts**: `flow-auditor`, `a11y-audit`, `design-system`
- **Capture method**: Phase 1 scan.

#### `ANIMATION_PRESET_FILE_PATH`
- **Type**: file path (or "none")
- **Description**: Where canonical animation presets live.
- **Possible values**: e.g. `lib/theme/patterns.ts` / "none"
- **Feeds artifacts**: `design-system`
- **Capture method**: Phase 1 scan.

#### `STATUS_COLOR_SYSTEM`
- **Type**: table (status × color × icon)
- **Description**: The product's status semantic mapping (e.g. green = catalog match, amber = uncertain, red = failed).
- **Possible values**: project-specific table.
- **Feeds artifacts**: `design-system`
- **Capture method**: Interview + Phase 1 scan.

### Cluster D — Surfaces + product context

#### `MULTI_SCREEN_ARCS_EXIST`
- **Type**: boolean
- **Description**: Does the project have multi-screen arcs (onboarding / checkout / setup wizard / multi-step task)?
- **Possible values**: `true` / `false`
- **Feeds artifacts**: `flow-auditor`, `flow-ux-reviewer`, `flow-ux-audit`, `ruthless-ux-autoloop`, `journey-audit`, `product-designer`
- **Capture method**: Interview question.

#### `ARC_INVENTORY`
- **Type**: list of named arcs with entry/exit surfaces
- **Description**: The named multi-screen arcs the project has.
- **Possible values**: e.g. `["sign-up → wizard → daily-home", "owner setup → equipment placement", "checkout flow", "account deletion"]`
- **Feeds artifacts**: `flow-auditor`, `flow-ux-audit`, `journey-audit`
- **Capture method**: Interview question (if `MULTI_SCREEN_ARCS_EXIST=true`).

#### `MULTI_SECTION_PRIMARY_SURFACE`
- **Type**: boolean + (if true) section inventory
- **Description**: Does the project have a primary multi-section surface with 3+ tabs / panels that should feel consistent? Drives whether pages-audit ships.
- **Possible values**: `{ has: true, sections: [{name, route, file}] }` / `{ has: false }`
- **Feeds artifacts**: `pages-audit`
- **Capture method**: Interview question + Phase 1 scan for `(tabs)/`, `app/`, `routes/`.

#### `SURFACE_DIR_STRUCTURE`
- **Type**: list of glob paths
- **Description**: Where do screens / routes / pages live? Used by journey-audit to enumerate prior surfaces.
- **Possible values**: e.g. `["app/wizard/**", "app/(owner)/**", "app/(member)/**"]` (RN/Expo Router) / `["src/pages/**", "src/routes/**"]` (web)
- **Feeds artifacts**: `journey-audit`, `flow-auditor`, `product-designer`
- **Capture method**: Phase 1 scan.

#### `TRANSLATION_FILE_LOCATIONS`
- **Type**: list of glob paths
- **Description**: Where copy / translation / narration files live.
- **Possible values**: e.g. `["lib/verticals/*/owner/translations/**/*.ts", "lib/i18n/locales/**/*.ts"]`
- **Feeds artifacts**: `journey-audit`, `element-reuse-check`, `persona-lens`, `check-forbidden-phrases.sh`
- **Capture method**: Phase 1 scan — look for `translations`, `i18n`, `locales`, `copy`, `narration` files.

#### `SEED_FIXTURE_MECHANISM`
- **Type**: command(s) + per-tier mapping
- **Description**: How to drive the app into a specific state (empty / typical / overflow). Used by audits + autoloop.
- **Possible values**: e.g. `yarn e2e:seed:layer1` (orphan) / `yarn e2e:seed:layer3` (full shell) / `seed-fixtures.sh --tier basic` / URL params / mock-mode env vars
- **Feeds artifacts**: `flow-auditor`, `pages-audit`, `ruthless-ux-autoloop`, `flow-ux-audit`, `product-designer`
- **Capture method**: Phase 1 scan + question.

### Cluster E — Product posture

#### `PROD_VS_INTERNAL`
- **Type**: enum
- **Description**: Is the project user-facing production code, or internal-only tooling?
- **Possible values**: `production-user-facing` / `internal-only` / `mixed`
- **Feeds artifacts**: `ux-reviewer`, `a11y-audit`, `quality-bar`, `forbidden-phrases.txt`
- **Capture method**: Interview question.

#### `USER_PERSONA_TYPE`
- **Type**: enum
- **Description**: Who's the user — consumer? B2B? Developer? Enterprise admin? Drives quality-bar's demo audience.
- **Possible values**: `B2C consumer` / `B2B SaaS user` / `dev-tool user` / `enterprise admin` / `internal user`
- **Feeds artifacts**: `quality-bar`, `product-designer`, `product-compass`
- **Capture method**: Interview question.

#### `DEMO_TEST_AUDIENCE`
- **Type**: string (specific imaginable audience)
- **Possible values**: e.g. `"a friend's customer I'm trying to recruit as customer #2"` / `"a journalist writing about us"` / `"a CTO at a target enterprise"` / `"a designer whose taste I respect"`
- **Description**: The one question for every change ("would I demo this to X?").
- **Feeds artifacts**: `quality-bar`
- **Capture method**: Interview question.

#### `QUALITY_BAR_REGISTER`
- **Type**: enum
- **Description**: The grading register — defensive (don't ship if not S-tier) vs offensive (ship and iterate).
- **Possible values**: `defensive (block-on-not-S)` / `offensive (ship-and-iterate)` / `bar-by-surface`
- **Feeds artifacts**: `quality-bar`, `ux-reviewer`
- **Capture method**: Interview question.

#### `QUALITY_GRADE_TARGETS_BY_SURFACE`
- **Type**: map (surface category → target grade)
- **Description**: Which surface categories target which grade (e.g. core flows = S, settings = A min, admin = B ok).
- **Possible values**: project-specific.
- **Feeds artifacts**: `quality-bar`, `ux-reviewer`, `flow-ux-reviewer`
- **Capture method**: Interview question.

#### `CAPABILITY_MAP_PATH`
- **Type**: file path (or "none")
- **Description**: Path to the project's capability map (WHAT-the-product-does layer between vision and code).
- **Possible values**: e.g. `docs/product/capabilities.md` / "none"
- **Feeds artifacts**: `product-designer`
- **Capture method**: Phase 1 scan + question.

#### `PROTOTYPE_GATES_PATH`
- **Type**: file path (or "none")
- **Description**: Path to the strategy lens (which prototype gate this work serves).
- **Possible values**: e.g. `.claude/rules/prototype-gates.md` / "none"
- **Feeds artifacts**: `product-designer`, `flow-auditor`
- **Capture method**: Phase 1 scan + question.

#### `PRODUCT_VISION_DOCS`
- **Type**: list of file paths
- **Description**: Where vision / core-product-identity docs live.
- **Possible values**: e.g. `["docs/vision.md", "memory/core-vision.md"]`
- **Feeds artifacts**: `product-compass`
- **Capture method**: Phase 1 scan + question.

#### `ARCHITECTURE_LAYER_PRIORITY`
- **Type**: ordered list
- **Description**: The architectural layer priority — when features compete for resource, which layer wins?
- **Possible values**: project-specific (e.g. engine > MCP > vertical-UI > polish).
- **Feeds artifacts**: `product-compass`
- **Capture method**: Interview question.

### Cluster F — Compliance + accessibility

#### `A11Y_COMPLIANCE_TARGET`
- **Type**: enum
- **Description**: The accessibility compliance target (drives contrast thresholds, label requirements, etc.).
- **Possible values**: `WCAG 2.2 AA` / `WCAG 2.2 AAA` / `Section 508` / `App Store guidelines` / `none`
- **Feeds artifacts**: `a11y-audit`
- **Capture method**: Interview question.

#### `HIT_TARGET_MINIMUM`
- **Type**: number + unit
- **Description**: Platform-minimum tappable area.
- **Possible values**: `44pt` (iOS HIG) / `48dp` (Android Material) / `44px` (web touch) / `24px` (web mouse-only — soft)
- **Feeds artifacts**: `a11y-audit`
- **Capture method**: Inferred from `PRIMARY_SURFACE_PLATFORM`.

#### `DYNAMIC_TYPE_UPPER_BOUND_PERCENT`
- **Type**: number
- **Description**: The text-scale upper bound to verify against (iOS Dynamic Type goes to 310%; Android to 200%; web user-set).
- **Possible values**: `200` / `310`
- **Feeds artifacts**: `a11y-audit`
- **Capture method**: Inferred from platform; user can override.

#### `LABEL_API`
- **Type**: string
- **Description**: The platform's a11y-label API name.
- **Possible values**: `accessibilityLabel` (iOS / RN) / `aria-label` (web) / `contentDescription` (Android) / etc.
- **Feeds artifacts**: `a11y-audit`
- **Capture method**: Inferred from platform.

#### `REDUCED_MOTION_HOOK_PATH`
- **Type**: string
- **Description**: The reduced-motion hook / API name (drives reduced-motion-respect checks).
- **Possible values**: e.g. `useReducedMotion()` from `react-native-reanimated` / `prefers-reduced-motion` CSS query / `UIAccessibility.isReduceMotionEnabled` (iOS native)
- **Feeds artifacts**: `a11y-audit`, `design-system`
- **Capture method**: Phase 1 scan + inferred from `MOTION_LIBRARY`.

### Cluster G — Testing + docs infrastructure

#### `TEST_FRAMEWORK`
- **Type**: enum
- **Description**: Project's primary test framework.
- **Possible values**: `Jest` / `Vitest` / `pytest` / `cargo test` / `go test` / `RSpec` / `none`
- **Feeds artifacts**: indirect (none directly, but informs Phase 1 scan for `*.test.*`/`*__tests__*/` exemption patterns in hooks)
- **Capture method**: Phase 1 scan — `package.json`.

#### `VISUAL_VERIFICATION_TOOL`
- **Type**: enum or list
- **Description**: The mechanism for visual capture + interaction in tests/audits.
- **Possible values**: `Maestro` / `Playwright` / `Cypress` / `Puppeteer` / `xcrun simctl io` (CLI only) / `manual` / `WDA-based physical device scripts` / etc.
- **Feeds artifacts**: every audit agent + `flow-ux-audit` + `visual-verification.md`
- **Capture method**: Phase 1 scan + interview question.

#### `STORYBOOK_FRAMEWORK`
- **Type**: enum
- **Description**: If the project has Storybook, the framework variant.
- **Possible values**: `@storybook/react-vite` / `@storybook/react-webpack` / `none`
- **Feeds artifacts**: `storybook-story` skill
- **Capture method**: Phase 1 scan.

#### `STORYBOOK_TITLE_CONVENTION`
- **Type**: string template
- **Description**: How story titles are conventioned (sidebar grouping).
- **Possible values**: e.g. `UI/<Name>` + `Widgets/<Name>` / `Components/<Category>/<Name>` / etc.
- **Feeds artifacts**: `storybook-story`
- **Capture method**: Phase 1 scan — read existing stories.

#### `STORYBOOK_REFERENCE_STORY_PATHS`
- **Type**: list of file paths
- **Description**: The existing story files that demonstrate the project's patterns (variant-matrix / composition / form-field / typography / data-viz).
- **Possible values**: project-specific.
- **Feeds artifacts**: `storybook-story`
- **Capture method**: Phase 1 scan.

#### `EXISTING_CLAUDE_MD`
- **Type**: file path (or "none")
- **Description**: Whether a CLAUDE.md / equivalent already exists.
- **Possible values**: e.g. `CLAUDE.md` / `AGENTS.md` / `.cursorrules` / "none"
- **Feeds artifacts**: `product-compass`, `product-designer`
- **Capture method**: Phase 1 scan.

#### `EXISTING_STYLE_GUIDE`
- **Type**: file path (or "none")
- **Description**: Whether a voice / style guide doc exists.
- **Possible values**: e.g. `docs/voice.md` / `docs/style-guide.md` / `docs/persona.md` / "none"
- **Feeds artifacts**: `forbidden-phrases.txt`, `persona-lens`
- **Capture method**: Phase 1 scan.

#### `AUDIT_REPORT_PATH_CONVENTION`
- **Type**: string template
- **Description**: Where dated audit reports land.
- **Possible values**: e.g. `docs/audits/YYYY-MM-DD-<slug>-<type>-audit.md` / `.claude/audits/<type>/<run-id>/report.md` / etc.
- **Feeds artifacts**: `flow-auditor`, `interaction-audit`, `a11y-audit`, `pages-audit`, `ruthless-ux-autoloop`, `flow-ux-audit`
- **Capture method**: Phase 1 scan + question.

#### `FLOW_DOC_PATH_CONVENTION`
- **Type**: string template
- **Description**: Where canonical flow docs land.
- **Possible values**: e.g. `docs/flows/<arc-slug>.md`
- **Feeds artifacts**: `flow-auditor`
- **Capture method**: Phase 1 scan + question.

#### `SPEC_DOC_PATH_CONVENTION`
- **Type**: string template
- **Description**: Where design spec docs land.
- **Possible values**: e.g. `docs/brainstorms/YYYY-MM-DD-<slug>-design.md` / `docs/designs/<slug>.md`
- **Feeds artifacts**: `product-designer`
- **Capture method**: Phase 1 scan + question.

#### `BRAINSTORM_DOC_PATH_CONVENTION`
- **Type**: string template
- **Description**: Where brainstorm docs land (input to product-designer).
- **Possible values**: e.g. `docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md`
- **Feeds artifacts**: `product-designer`
- **Capture method**: Phase 1 scan + question.

### Cluster H — Git mining

#### `PAST_BUGS_BY_SHA`
- **Type**: list of commit SHAs + subject + bug class
- **Description**: Past UX bugs by commit SHA + short subject, mined from `git log`. Each becomes a project-specific anti-pattern example for the agents' "project-specific anti-patterns from git" depth-signature requirement.
- **Possible values**: project-specific from `git log --grep="polish|cleanup|fix.*layout|broken.*UX|revert.*copy"` and `git log --grep="a11y|accessibility|VoiceOver|contrast"` and `git log --grep="dead.*chrome|redundant|click.*nothing"`.
- **Feeds artifacts**: every depth-signed agent (ux-reviewer, interaction-audit, a11y-audit, flow-auditor, design-token-auditor) — Phase D mining.
- **Capture method**: Phase 1 git mining (semi-automated grep against git log) + interview confirmation.

#### `PAST_DEAD_CHROME_SHAS`
- **Type**: subset of past-bugs by category
- **Description**: Specifically the dead-chrome / redundant-affordance / overlay-blackhole bugs from history.
- **Feeds artifacts**: `interaction-audit`
- **Capture method**: Phase 1 git mining `git log --grep="overlay|tap.*intercept|dead.*chrome|redundant"`.

#### `PAST_A11Y_BUG_SHAS`
- **Type**: subset of past-bugs by category
- **Description**: Specifically the a11y bugs from history.
- **Feeds artifacts**: `a11y-audit`
- **Capture method**: Phase 1 git mining `git log --grep="a11y|contrast|label|hit.*target"`.

#### `PAST_TOKEN_DRIFT_SHAS`
- **Type**: subset of past-bugs by category
- **Description**: Specifically token-drift bugs (raw hex slipping in).
- **Feeds artifacts**: `design-token-auditor`
- **Capture method**: Phase 1 git mining.

#### `PAST_ARC_BUG_SHAS`
- **Type**: subset of past-bugs by category
- **Description**: Specifically multi-screen / arc bugs (dead-end / missing-bridge / wrong-copy-on-wrong-surface).
- **Feeds artifacts**: `flow-auditor`
- **Capture method**: Phase 1 git mining.

### Cluster I — Model selection

#### `MODEL_TIER_DEFAULT`
- **Type**: enum
- **Description**: Default model tier for high-effort agents.
- **Possible values**: `opus-4-7` / `opus-4-5` / `sonnet-4-5` / etc.
- **Feeds artifacts**: every agent's frontmatter
- **Capture method**: Interview question (default to top opus).

#### `MODEL_TIER_LIGHTWEIGHT`
- **Type**: enum
- **Description**: Lightweight model tier for mechanical agents (design-token-auditor uses haiku-class).
- **Possible values**: `haiku-4-5` / `sonnet-4-5` (if no haiku available)
- **Feeds artifacts**: `design-token-auditor`
- **Capture method**: Interview question or default.

---

**Total knobs identified: 53** (over the expected 25-35 — the source project is unusually thoroughly configured, so the knob count surfaced is high. Many are redundant for simpler projects and can be defaulted; the interview should focus on the 12-15 highest-leverage ones).

---

## 3. Artifact applicability matrix

For each artifact, when does it apply vs skip? Drives interview decision points.

| Artifact | Applies when... | Skips when... | Triggering knobs |
|---|---|---|---|
| `ux-reviewer` | Has user-facing UI surface, has named quality bar | CLI tool / library / no UI / no quality bar | `PRIMARY_SURFACE_PLATFORM` ≠ CLI/lib, `TIER_1_BENCHMARKS` set, `PROD_VS_INTERNAL` ≠ pure-internal |
| `interaction-audit` | Has multi-element interactive screens (forms, dashboards, wizards) | Trivial single-element screens / read-only / library-generated UI | `PRIMARY_SURFACE_PLATFORM` has UI, screens have multiple Pressables/buttons/etc. |
| `a11y-audit` | User-facing UI with real users (not just internal devs); compliance target exists | Pure backend / internal-only debug tools / spike code | `PROD_VS_INTERNAL = production-user-facing`, `A11Y_COMPLIANCE_TARGET` ≠ none |
| `flow-auditor` | Multi-screen user flows exist | Single-screen apps; flows are all 1-2 screens | `MULTI_SCREEN_ARCS_EXIST = true`, `ARC_INVENTORY` has 1+ named arcs |
| `flow-ux-reviewer` | Multi-screen flow grading wanted; have capture pipeline | Single-screen reviews; no flow shape | `MULTI_SCREEN_ARCS_EXIST = true`, `VISUAL_VERIFICATION_TOOL` supports series capture |
| `pages-audit` | Multi-section primary surface with 3+ tabs/panels | 1-2 primary sections; intentionally divergent sections | `MULTI_SECTION_PRIMARY_SURFACE.has = true` and ≥3 sections |
| `design-token-auditor` | Design system / theme exists with drift potential | No theme system; styling is wholly Tailwind-arbitrary with no escape | `DESIGN_SYSTEM_MATURITY` ≠ none, `DESIGN_SYSTEM_TOKENS_PATH` set |
| `product-designer` | New features / redesigns / IA decisions happen | Project is feature-complete; no new design work | (Always-on; deferred dispatch decision happens at use-time) |
| `product-compass` | Has named product vision + strategy lens | No vision doc / no strategy posture | `PRODUCT_VISION_DOCS` ≥ 1 path, `ARCHITECTURE_LAYER_PRIORITY` set |
| `quality-bar` | Has quality bar to hold ("S-tier" language used) | Velocity-first culture ("just ship it") | `TIER_1_BENCHMARKS` set, `DEMO_TEST_AUDIENCE` set |
| `journey-audit` | Multi-step user flows exist; surface-types differ | Single-screen tool; surfaces all equivalent | `MULTI_SCREEN_ARCS_EXIST = true` OR `IN_PRODUCT_ASSISTANT_CHARACTER.has = true` |
| `element-reuse-check` | Reusable string/component library worth reusing; multi-step flows | Greenfield; surfaces all of one type; structural-only reuse | `MULTI_SCREEN_ARCS_EXIST = true`, `TRANSLATION_FILE_LOCATIONS` non-empty |
| `persona-lens` | Has voice/persona discipline | Functional-only copy; user-generated content platform | `PRODUCT_HAS_VOICE = true`, `BRAND_VOICE_REFERENCE` set |
| `design-system` (skill) | Has theme / design system primitives | No design system | `DESIGN_SYSTEM_MATURITY` ≠ none |
| `ruthless-ux-autoloop` | Iterative polish to award-tier wanted; has capture harness | Single-shot audits only | `VISUAL_VERIFICATION_TOOL` set + reviewer agent available + `FIXTURE_RESET_COMMAND` set |
| `flow-ux-audit` (skill) | Specific named setup-flow audit wanted; has Maestro/equivalent autoplay | Member-side flows; manual review | `MAESTRO_YAML_PATH_BY_VERTICAL` set + autoplay build exists |
| `storybook-story` | Has Storybook | No component-library Storybook | `STORYBOOK_FRAMEWORK` ≠ none |
| `design-north-star.md` | Has named platform quality bar | Functional-only posture | `TIER_1_BENCHMARKS` set, `PRIMARY_SURFACE_PLATFORM` has chrome |
| `design-audit-routing.md` | 3+ audit agents shipped | 1-2 audit agents (routing is trivial) | `AUDIT_AGENT_INVENTORY` ≥ 3 |
| `visual-verification.md` | Project produces visible output | Pure library / API / structured-data-only output | `PRIMARY_SURFACE_PLATFORM` has UI |
| `forbidden-phrases.txt` | Has product voice | Functional-only copy | `PRODUCT_HAS_VOICE = true` |
| `frontend-components.md` | Has frontend component library | No frontend code | `PRIMARY_SURFACE_PLATFORM` has UI |
| `check-forbidden-phrases.sh` | Has product voice + `PostToolUse` hooks possible | Functional-only copy / hooks unsupported | `PRODUCT_HAS_VOICE = true`, hook infra wired |
| `check-token-only.sh` | Has design system + hooks possible | No theme / hooks unsupported | `DESIGN_SYSTEM_TOKENS_PATH` set, hook infra wired |
| `check-nativetabs-sf-icon.sh` | iOS chrome with native tab bar + SF Symbols convention | Non-iOS platforms / no native tabs | `PRIMARY_SURFACE_PLATFORM = iOS`, native tab primitive used |
| `check-no-expo-blur.sh` | Expo + iOS + has migrated to modern glass primitive | Non-Expo / non-iOS / no glass primitive | `PRIMARY_SURFACE_PLATFORM = iOS` + Expo + `NATIVE_CHROME_PRIMITIVES_LIST` has glass primitive |

Reading this matrix: ~12 of the 26 artifacts are always-applicable if the project has any UI; the remaining 14 are conditional on specific knob values. The interview's primary job is determining which conditional-applicability knobs apply.

---

## 4. Composition graph

The cross-reference dependency map. Shows which artifacts read which, which run in parallel, which sequence after which. Helps reveal the kit's emergent structure.

### Root nodes (referenced by many, reference few)

- **`design-north-star.md`** — referenced by 13 artifacts: every UI agent + `quality-bar` + `design-system` + `design-audit-routing.md` + `visual-verification.md` + hooks. References: nothing else within the design stack (it IS the foundation).
- **`forbidden-phrases.txt`** — referenced by 4 artifacts: `persona-lens` + `journey-audit` + `check-forbidden-phrases.sh` + `element-reuse-check` (deny-list reasoning). References: nothing.
- **`visual-verification.md`** — referenced by every audit agent + `product-designer` + `quality-bar`. References: nothing within design stack.
- **`quality-bar`** (skill) — referenced by every UI agent. References: `design-north-star.md`.
- **`design-system`** (skill) — referenced by every UI agent. References: `design-north-star.md`.

### Leaf nodes (depend on many, depended on by few)

- **`ruthless-ux-autoloop`** — depends on: `quality-bar`, `design-audit-routing.md`, `design-north-star.md`, dispatches `flow-ux-reviewer` + `ux-reviewer`. Referenced by: no other artifact (user-invocable terminus).
- **`flow-ux-audit`** — depends on: project fixtures, dispatches `flow-ux-reviewer`. Referenced by: `design-audit-routing.md` (routing entry only).
- **`storybook-story`** — depends on: `design-system`, `design-north-star.md`. Referenced by: nothing else.
- **`product-compass`** — depends on: project vision docs. Referenced by: nothing else (top-level dispatcher).

### Middle layer — bidirectional composition

#### `ux-reviewer` →
- reads: `design-system`, `quality-bar`, `app-state-navigation` (project-specific), `journey-audit`, `persona-lens`, `design-north-star.md`, `visual-verification.md`
- invokes alongside: `a11y-audit`, `interaction-audit`, `design-token-auditor` (per `design-audit-routing.md` pipeline)
- defers to: `flow-auditor` (if multi-screen scope), `pages-audit` (if cross-tab scope), `product-designer` (if redesign-not-polish)

#### `a11y-audit` →
- reads: `design-system` (for tokens / contrast computation), `app-state-navigation`, `quality-bar`, `design-north-star.md`, `audit-routing.md`
- invokes alongside: `interaction-audit` (PARALLEL — orthogonal dimensions)
- sequenced before: `ux-reviewer` (a11y fixes shift layout)

#### `interaction-audit` →
- reads: `design-system`, `quality-bar`, `app-state-navigation`, `journey-audit`, `persona-lens`
- invokes alongside: `a11y-audit` (PARALLEL)
- sequenced before: `ux-reviewer`
- references war-stories: `examples/the-button-that-never-fired.md`

#### `flow-auditor` →
- reads: `design-system`, `quality-bar`, `product-atlas` (project-specific), `app-state-navigation`, `e2e-testing` (project-specific), `journey-audit`, `persona-lens`, `design-north-star.md`, `prototype-gates.md`, binding memories
- routes findings to: `ux-reviewer`, `interaction-audit`, `product-designer`, direct impl
- sequenced before: `design-token-auditor` (in multi-screen-arc batch — provides scope)

#### `flow-ux-reviewer` →
- reads: `design-system`, `quality-bar`, `app-state-navigation`, `journey-audit`, `persona-lens`, `design-north-star.md`
- sequenced after: `ux-reviewer` (visual polish first, then continuity)
- consumes capture from: `flow-ux-audit` skill

#### `pages-audit` →
- reads: `design-system`, `quality-bar`, `app-state-navigation`, `design-north-star.md`, `design-audit-routing.md`
- sequenced between: `interaction-audit/a11y-audit` and `ux-reviewer`

#### `design-token-auditor` →
- reads: theme tokens source, `design-north-star.md`
- pipeline step 1 (cheapest, broadest)
- hook companion: `check-token-only.sh`

#### `product-designer` →
- reads: `design-system`, `quality-bar`, `product-atlas`, `app-state-navigation`, `journey-audit`, `element-reuse-check`, `persona-lens`, `design-north-star.md`, `prototype-gates.md`, capability map, brainstorm doc
- routes to: implementation + UI-batch validation pipeline
- refuses → routes to: `ux-reviewer` (single-screen polish)

#### `journey-audit` (skill) →
- reads: `forbidden-phrases.txt`, binding memories
- loaded by: `product-designer`, `flow-auditor`, `ux-reviewer`, `interaction-audit`, `flow-ux-reviewer`

#### `element-reuse-check` (skill) →
- reads: `journey-audit`, `forbidden-phrases.txt`
- loaded by: `product-designer`, `ux-reviewer`, `flow-auditor`, `interaction-audit`

#### `persona-lens` (skill) →
- reads: `journey-audit`, `element-reuse-check`, `forbidden-phrases.txt`
- loaded by: every designer + reviewer agent
- hook companion: `check-forbidden-phrases.sh`

### Pipeline order (canonical, per `design-audit-routing.md`)

```
For a multi-screen UI arc:
  Phase 0 — flow-auditor (scope-lock, surface arc-level gaps)
  Phase 1 — design-token-auditor (cheapest, widest)
  Phase 2 — interaction-audit + a11y-audit (parallel, orthogonal)
  Phase 2.5 — pages-audit (if multi-section primary surface)
  Phase 3 — ux-reviewer (visual polish, last)
  Phase 4 — flow-ux-reviewer (arc continuity on polished output)
```

### The hooks-prevent-findings shortcut

Before dispatching any agent, edit-time hooks already catch:

- `check-token-only.sh` → prevents 80%+ of token-discipline findings without LLM tokens.
- `check-forbidden-phrases.sh` → prevents most copy-register findings the same way.
- `check-nativetabs-sf-icon.sh` → prevents iOS-chrome-icon findings.
- `check-no-expo-blur.sh` → prevents legacy-blur findings.

This is the cheapest layer of the kit and must be presented BEFORE any audit agent dispatch.

---

## 5. Interview design recommendations

The interview drives all 53 knobs to capture. Knobs cluster into 9 question batches (with some questions yielding multiple knobs). Recommended phase structure:

### Phase A — Platform + dev-loop (2 questions, ~5 knobs)

**Q-A1.** "What does this project ship on? (iOS / Android / web / desktop / CLI / mixed)" → drives `PRIMARY_SURFACE_PLATFORM` + `HIT_TARGET_MINIMUM` + `LABEL_API` + `DYNAMIC_TYPE_UPPER_BOUND_PERCENT`.

**Q-A2.** "How do you capture screenshots / inspect rendered output during development?" → drives `CAPTURE_COMMAND_PRIMARY` + `CAPTURE_COMMAND_PHYSICAL_DEVICE` + `HIERARCHY_INSPECTION_COMMAND` + `VISUAL_VERIFICATION_TOOL` + `DEVICE_TARGET_DETECT_COMMAND` + `DEV_LOOP_TOOL` + `LOG_INSPECTION_PATH`. (Many of these inferrable from Phase 1 scan if package.json / scripts present.)

### Phase B — Benchmarks (3 questions, ~6 knobs)

**Q-B1.** "When you say 'S-tier' / 'world-class' for THIS project, which specific apps do you mean? Name 2-3. What about each one is great?" → drives `TIER_1_BENCHMARKS`.

**Q-B2.** "For each surface category your product has (onboarding / dashboard / settings / empty-state / detail view / etc.), which 2-3 apps are your bar?" → drives `TIER_2_BENCHMARKS_WITH_DIMENSION` + `BRIDGE_REFERENCE_APPS`.

**Q-B3.** "Which apps do you specifically NOT want to be compared to?" → drives `ANTI_REFERENCES`.

### Phase C — Voice + persona (4 questions, ~7 knobs; collapse if `PRODUCT_HAS_VOICE = false`)

**Q-C1.** "Does this product have an authored 'voice' the team enforces, or is copy purely functional?" → drives `PRODUCT_HAS_VOICE` (gates all of Phase C).

**Q-C2.** "Does your product have a named in-product assistant character? If yes — name + where does it introduce itself?" → drives `IN_PRODUCT_ASSISTANT_CHARACTER`.

**Q-C3.** "Whose voice does this product aspire to sound like? Name a specific reference (app empty-state voice / character from a film / a specific company's product voice)." → drives `BRAND_VOICE_REFERENCE`.

**Q-C4.** "What tones do you actively reject? (customer-service register / apology / performance / etc.)" → drives `VOICE_ANTI_REFERENCES` + `BRAND_FORBIDDEN_PHRASES` (the project-specific Axis 2 entries; backfill with git log mining for revert-copy commits) + `USAGE_FREQUENCY_FRAMING` (inferred from how often a typical user opens the product).

### Phase D — Surfaces + product context (4 questions, ~8 knobs)

**Q-D1.** "Does the project have multi-screen arcs (onboarding / checkout / setup wizard / multi-step task)? Name them." → drives `MULTI_SCREEN_ARCS_EXIST` + `ARC_INVENTORY`.

**Q-D2.** "Does the project have a primary multi-section surface (3+ tabs / dashboards / panels)? List the sections with routes + file paths." → drives `MULTI_SECTION_PRIMARY_SURFACE`.

**Q-D3.** "Where do screens / routes / pages live in the codebase? Where do copy / translation / narration files live?" → drives `SURFACE_DIR_STRUCTURE` + `TRANSLATION_FILE_LOCATIONS`. (Phase 1 scan can pre-populate.)

**Q-D4.** "How does the app get into specific data states for testing/auditing? (seed scripts? fixture accounts? mock-mode env vars?)" → drives `SEED_FIXTURE_MECHANISM`.

### Phase E — Product posture (3 questions, ~6 knobs)

**Q-E1.** "Who's your user? (consumer / B2B / dev / enterprise admin / internal)" → drives `USER_PERSONA_TYPE`.

**Q-E2.** "Is the project production-user-facing or internal-only or mixed?" → drives `PROD_VS_INTERNAL`.

**Q-E3.** "Who would you demo a polished change to — be specific, name the role or person?" → drives `DEMO_TEST_AUDIENCE` + `QUALITY_BAR_REGISTER` (inferred from how strict they are) + `QUALITY_GRADE_TARGETS_BY_SURFACE`.

### Phase F — Design system (Phase 1 scan + 2 questions, ~9 knobs)

**Q-F1.** "Where do your design tokens / theme values live? Walk me through how a color gets from token to render." → drives `DESIGN_SYSTEM_TOKENS_PATH` + `DESIGN_SYSTEM_MATURITY` + `THEME_CONVENTION` + `THEME_GENERATION_COMMAND`.

**Q-F2.** "Which native chrome primitives do you already have, and where do they live? (tab bars / glass cards / bottom sheets / etc.)" → drives `NATIVE_CHROME_PRIMITIVES_LIST` + `CHROME_PRIMITIVE_PATHS` + `MOTION_LIBRARY` + `ANIMATION_PRESET_FILE_PATH` + `STATUS_COLOR_SYSTEM`. (Phase 1 scan can pre-populate.)

### Phase G — Compliance + accessibility (1 question if applicable, ~5 knobs)

**Q-G1.** "What's your accessibility compliance target? (WCAG AA / AAA / Section 508 / App Store / none-explicit-but-care)" → drives `A11Y_COMPLIANCE_TARGET` + `REDUCED_MOTION_HOOK_PATH` (inferred). Hit-target / Dynamic Type / label-API knobs are platform-inferred (Phase A).

### Phase H — Testing + docs infrastructure (Phase 1 scan + 1 fallback question, ~7 knobs)

**Phase 1 scan auto-populates:**
- `TEST_FRAMEWORK` (read package.json)
- `STORYBOOK_FRAMEWORK` (check for `.storybook/`)
- `STORYBOOK_TITLE_CONVENTION` + `STORYBOOK_REFERENCE_STORY_PATHS` (read existing stories)
- `EXISTING_CLAUDE_MD` / `EXISTING_STYLE_GUIDE` (check for files)

**Q-H1.** "Where do your audit reports / flow docs / spec docs land?" → drives `AUDIT_REPORT_PATH_CONVENTION` + `FLOW_DOC_PATH_CONVENTION` + `SPEC_DOC_PATH_CONVENTION` + `BRAINSTORM_DOC_PATH_CONVENTION` (often all under `docs/audits/` and `docs/brainstorms/` — sane defaults apply).

### Phase I — Git mining (automated + interview confirmation, ~5 knobs)

Semi-automated: run grep against `git log` for:
- copy-revert / tone-fix commits → `BRAND_FORBIDDEN_PHRASES` candidates
- polish / cleanup / fix-layout commits → `PAST_BUGS_BY_SHA`
- a11y / contrast / label / hit-target commits → `PAST_A11Y_BUG_SHAS`
- overlay / dead-chrome / redundant commits → `PAST_DEAD_CHROME_SHAS`
- token / hex / color commits → `PAST_TOKEN_DRIFT_SHAS`
- arc / dead-end / wrong-screen commits → `PAST_ARC_BUG_SHAS`

**Q-I1.** "Here are 12 commit SHAs I mined as candidate examples — mark which 3-5 are most representative for each category." → confirms the mining.

### Phase J — Strategy + vision (2 optional questions, ~3 knobs)

**Q-J1.** "Do you have a vision doc / capability map / strategy lens? Paths?" → drives `PRODUCT_VISION_DOCS` + `CAPABILITY_MAP_PATH` + `PROTOTYPE_GATES_PATH`.

**Q-J2.** "What's your architectural layer priority — when features compete for time, which layer wins?" → drives `ARCHITECTURE_LAYER_PRIORITY`. (Skip if simple project.)

### Phase K — Model selection (1 question, 2 knobs)

**Q-K1.** "Default model tier for high-effort audit agents? (opus-4-7 default; some shops have policies)" → drives `MODEL_TIER_DEFAULT` + `MODEL_TIER_LIGHTWEIGHT`.

### Interview structure summary

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
| I | Git mining | 1 (confirmation) | 5 | Yes (mining-automated) |
| J | Strategy + vision | 2 | 3 | Partial |
| K | Model tier | 1 | 2 | No (policy-driven) |
| **Total** | | **24 questions** | **53 knobs** | |

24 questions is a lot. Recommended: **batch into 5 super-questions** for the actual interview UX, each super-question pulling 3-5 sub-knobs:

1. **Super-Q1**: "What does this project ship on, who are the users, and how do you currently capture+test rendered output?" (Phases A + E)
2. **Super-Q2**: "Name your benchmarks (Tier 1, Tier 2, anti-references) and the demo audience." (Phase B + part of E)
3. **Super-Q3**: "Does the product have a voice? If yes — character / reference / anti-references / forbidden phrases." (Phase C)
4. **Super-Q4**: "Tell me about your design system + surface structure — tokens path, primitives, screen dirs, copy file locations, seed mechanism." (Phases D + F + H)
5. **Super-Q5**: "Compliance bar + vision/strategy lens (optional) + model tier." (Phases G + J + K)
6. **Super-Q6 (automated then confirmed)**: "Here are commit SHAs I mined as anti-pattern candidates — mark the 3-5 most representative." (Phase I)

5-6 super-questions × ~3 minutes each = ~15-20 min interview = battle-tested baseline.

---

## 6. Gaps in current dotclaude principles

Current dotclaude principles (in `/Users/dima/Documents/Projects/dotclaude/principles/`):

```
a11y-audit.md            interaction-audit.md      pages-audit.md
audit-routing.md         journey-mapping.md        persona-testing.md
design-benchmarking.md   quality-rubric.md         visual-verification.md
design-token-audit.md    element-reuse.md          forbidden-phrases.md
flow-audit.md            ux-audit.md
```

Cross-comparison: every source-project artifact has at least one corresponding principle. The principles are well-aligned to the kit's universal methodology. The gaps are mostly **depth + composability + new artifacts**, not "missing topics."

### Gap 6.1 — `flow-ux-reviewer` has no dedicated principle

**What's missing**: The source has both `flow-auditor` (whole-arc audit producing flow doc + gap report) AND `flow-ux-reviewer` (continuity-aware grader of pre-captured screenshot series). Current dotclaude `flow-audit.md` covers the former; nothing covers the latter.

**Why this matters**: The two agents serve different purposes — `flow-auditor` is the per-arc deep audit (4 phases, 8 gap classes, 2 artifacts); `flow-ux-reviewer` is the lightweight continuity grader you point at any captured screenshot series. Without the latter, you can't enable `ruthless-ux-autoloop` (which uses the reviewer as its L1 grading layer) or `flow-ux-audit` (which auto-captures and dispatches to the reviewer).

**Fix recommendation**: Add new principle `flow-continuity-review.md` (or extend `flow-audit.md` with a "lightweight continuity grader" sibling section). Knobs it must surface: `FLOW_CONTINUITY_DIMENSIONS` (tone / CTA weight / loading vocab / pacing / color drift / progress legibility), `MANIFEST_SCHEMA`, `BRIDGE_REFERENCE_APPS`.

### Gap 6.2 — `product-designer` has no dedicated principle

**What's missing**: The source's largest agent (499 LOC) — senior-IC product designer for IA / flow / multi-screen architecture work, with the journey-audit + element-reuse + persona-lens gates baked in, and the spec doc as deliverable. dotclaude has no `product-designer.md` principle.

**Why this matters**: This is the entry point for new-feature work — the gateway between brainstorm and implementation. Without an articulated principle, the interview can't ask the right questions to configure this agent (capability-map path / spec-doc convention / data-shape probe interface / etc.).

**Fix recommendation**: Add new principle `product-designer.md`. It's a substantial principle (the source agent is 500 LOC, the universal methodology is rich). Knobs it must surface: `BRAINSTORM_DOC_PATH_CONVENTION`, `SPEC_DOC_PATH_CONVENTION`, `CAPABILITY_MAP_PATH`, `PROTOTYPE_GATES_PATH`, `DATA_SHAPE_PROBE_INTERFACE`, `COMPETITIVE_REFERENCE_TABLE`, `INFRASTRUCTURE_VERIFY_GREPS`, the journey/reuse/persona gate requirements, self-audit checklist. Important sub-principles to cross-reference: `journey-mapping`, `element-reuse`, `persona-testing`, `design-benchmarking`, `quality-rubric`.

### Gap 6.3 — `product-compass` has no dedicated principle

**What's missing**: The vision-alignment-guardian agent — direction validator, drift detector, agent coordinator. Currently dotclaude has no principle for this kind of work.

**Why this matters**: Without a vision-keeper, the rest of the kit drifts. The source uses this agent to keep CLAUDE.md / memories / skills aligned across major changes. It's the "meta" agent that coordinates the others.

**Fix recommendation**: Add new principle `product-direction-validator.md` (or `product-compass.md` to match). Knobs: `PRODUCT_VISION_DOCS`, `ARCHITECTURE_LAYER_PRIORITY`, `CORE_DIFFERENTIATORS_LIST`, `DRIFT_SIGNALS`, `AGENT_COORDINATION_TABLE`.

### Gap 6.4 — `ruthless-ux-autoloop` has no dedicated principle

**What's missing**: The continuous iterative review-and-polish autoloop skill — user-invocable, with 3 scrutiny layers (reviewer / composition scan / backend truth probe), per-iteration commit cadence, hard-cap iteration discipline.

**Why this matters**: This is one of the most distinctive artifacts in the source — the autoloop pattern is the operationalization of "polish to award-tier quality." Without a principle, the interview can't ask the right questions (which backend-truth probes? what's the fixture-reset command? what's the iteration cap?).

**Fix recommendation**: Add new principle `iterative-polish-autoloop.md`. Knobs: `FIXTURE_RESET_COMMAND`, `FLOW_CAPTURE_HARNESS`, `BACKEND_TRUTH_PROBE_QUERIES`, `SEMANTIC_COUNT_AUDIT_PATTERNS`, `ITERATION_CAP_HARD/SOFT`, `SAFETY_INVARIANTS`. This is a hard principle to write generically — the backend-truth probes are very project-specific — but the universal-methodology layer is teachable (the 3-layer scrutiny pattern is reusable).

### Gap 6.5 — `flow-ux-audit` skill has no dedicated principle

**What's missing**: The auto-capture-then-dispatch-to-reviewer skill. User invokes `/flow-ux-audit`, the project's setup flow gets driven end-to-end via Maestro/equivalent, screenshots become a manifest, the manifest goes to `flow-ux-reviewer`.

**Why this matters**: This is the auto-capture half of the autoloop. Without an articulated principle, projects with capture harnesses can't reproduce it.

**Fix recommendation**: Add new principle `auto-capture-flow-audit.md` (or fold into `flow-continuity-review.md` from Gap 6.1). Knobs: `MAESTRO_YAML_PATH_BY_VERTICAL`, `CAPTURE_AUTOPLAY_BUILD_ENV`, `CANONICAL_SCREEN_SEQUENCE_BY_VERTICAL`, `MANIFEST_SCHEMA_VERSION`.

### Gap 6.6 — `storybook-story` skill has no dedicated principle

**What's missing**: The "add a story file matching the project's existing convention" skill.

**Why this matters**: Lower priority than 6.1–6.5 — only applies when the project has Storybook. But still an artifact-shaped reusable pattern that the source kit articulates.

**Fix recommendation**: Add new principle `component-story-authoring.md`. Knobs: `STORYBOOK_FRAMEWORK`, `STORYBOOK_TITLE_CONVENTION`, `STORYBOOK_REFERENCE_STORY_PATHS`, `STATE_SPECTRUM_PER_COMPONENT_KIND`. Optional gate ("ship Storybook-story skill when project has Storybook installed").

### Gap 6.7 — `design-system` skill has no dedicated principle (the SKILL form, not the audit form)

**What's missing**: The design-system principle currently exists implicitly inside `design-token-audit.md` and `design-benchmarking.md`. But the source's `design-system` skill is much broader — it covers theme tokens AND native chrome primitives AND surface hierarchy AND motion presets AND library gotchas AND i18n conventions AND the interaction-semantics 4Q docstring AND memoization rules.

**Why this matters**: The skill is the "where do I look up the design system" reference loaded by every UI agent. Without an articulated principle, the interview captures token-discipline but misses the rest (chrome primitives inventory / motion presets / surface hierarchy levels / library gotchas).

**Fix recommendation**: Add new principle `design-system-reference-skill.md` (or rename + expand the topic). This is the "design-system skill catalog" — what a project's design-system entry-point skill should contain. Knobs: `NATIVE_CHROME_PRIMITIVES_LIST`, `CHROME_PRIMITIVE_PATHS`, `MOTION_LIBRARY`, `ANIMATION_PRESET_FILE_PATH`, `STATUS_COLOR_SYSTEM`, `SURFACE_HIERARCHY_LEVELS`, `RN_LIBRARY_GOTCHAS_LIST`, `INTERACTION_SEMANTICS_4Q_DOCSTRING_REQUIRED`, `I18N_CONVENTIONS`.

### Gap 6.8 — `frontend-components.md` rule has no dedicated principle

**What's missing**: The tiny project-conventions rule pinning page-wrapper component names + search-before-create discipline + no-inline-wrappers-around-stable-callbacks.

**Why this matters**: Low priority — it's a 12-LOC rule. But it captures a class of "before creating, search" hygiene that other projects could benefit from. Probably folds into `design-system-reference-skill.md` from Gap 6.7 (its conventions are a subset of the design system).

**Fix recommendation**: Optional — fold into Gap 6.7. Or skip if simplicity-over-completeness.

### Gap 6.9 — Existing principles miss certain depth elements

**Surface analysis** (no rewrite needed, but worth noting for future iteration):

- **`ux-audit.md`** (already in principles, well-developed) — **misses** an articulated `IN_PRODUCT_ASSISTANT_CHARACTER` knob in its depth-signature anti-patterns. The "daily-driver trap" is the most common UX bug in this codebase class; depth-signature anti-pattern #7 should call it out explicitly.

- **`a11y-audit.md`** (already in principles) — **misses** an articulated mention of how contrast ratios should be computed from the project's TOKEN values, not screenshot-estimated. This is present in depth-signature #6 but could be in the core methodology section.

- **`interaction-audit.md`** (already in principles) — **good coverage**. Specifically the "TAP before grading" rule is well-articulated.

- **`flow-audit.md`** (already in principles) — **good coverage** of the 8-class taxonomy. **Misses** explicit guidance on the "audit, don't fix" handoff column convention; this is a structural feature of the source agent that the principle understates.

- **`pages-audit.md`** (already in principles) — **good coverage**. The "code-grep FIRST, pixel-measure LAST" cost discipline is well-articulated.

- **`design-token-audit.md`** (already in principles) — **good coverage**. The S0/S1/S2/Exempt tier mapping is well-articulated.

- **`journey-mapping.md`** + **`element-reuse.md`** + **`persona-testing.md`** — **good coverage** as a Gate-A/Gate-B/Gate-C trinity. **Misses** explicit "this skill loads at BOTH design time AND audit time" — the dual-load is what prevents implementation drift, and the source's `persona-lens` skill calls it out as critical. The current principles describe the design-time use but only briefly mention the audit-time rerun.

- **`quality-rubric.md`** — **good coverage**. Could **expand** the "claim-of-done preconditions" — the source has 5 specific preconditions (screenshot, lint, tests, pitfall scan, benchmark named); the principle should articulate these as a checklist template.

- **`design-benchmarking.md`** — **good coverage**. **Misses** the per-surface chrome reference table convention (the source's `design-north-star.md` has a row-per-surface table — tab bar / cards / sheets / motion / color / typography / iconography — each row naming the specific reference). The principle should template this surface-row table.

- **`visual-verification.md`** — **good coverage**. The CLI > MCP token-discipline section is excellent.

- **`forbidden-phrases.md`** — **good coverage**. The two-axis structure (universal AI-slop + project-specific voice violations) is well-articulated.

- **`audit-routing.md`** — **good coverage**. The cross-rubric translation table + hooks-prevent-findings table are well-articulated.

### Gaps summary

| Gap # | Severity | Type | Fix |
|---|---|---|---|
| 6.1 | High | Missing principle | New: `flow-continuity-review.md` |
| 6.2 | High | Missing principle | New: `product-designer.md` |
| 6.3 | Medium | Missing principle | New: `product-direction-validator.md` |
| 6.4 | Medium | Missing principle | New: `iterative-polish-autoloop.md` |
| 6.5 | Medium | Missing principle | New: `auto-capture-flow-audit.md` (or fold into 6.1) |
| 6.6 | Low | Missing principle | New: `component-story-authoring.md` |
| 6.7 | High | Missing principle | New: `design-system-reference-skill.md` |
| 6.8 | Low | Missing principle | Fold into 6.7 |
| 6.9 | Low | Existing depth | Touch-ups per principle, no rewrites |

Net: **5-6 new principles needed** (6.1, 6.2, 6.3, 6.4, 6.5/folded, 6.7) + light depth touch-ups on existing ones. The highest-leverage additions are 6.2 (`product-designer`) and 6.7 (`design-system-reference-skill`) — they unlock interview questions for ~15 of the 53 knobs that current principles don't drive.

---

## 7. Summary

### What the design stack is

A 26-artifact kit — 9 agents + 8 skills + 5 rules + 4 hooks — that operationalizes "S-tier UX" on a React Native iOS-first project. The kit has three structural properties worth preserving on any reuse:

1. **Tiered specialization with refusal behaviors.** Each agent is scoped narrowly (single-screen visual / semantic chrome / accessibility / cross-tab / whole-arc / etc.) and explicitly refuses out-of-lane work — routing to the right agent. The kit can be dispatched intelligently because each agent knows what it won't do.
2. **Canonical pipeline order with cross-rubric translation.** When multiple audits apply, they run in a deterministic order (tokens → semantic+a11y || → visual) so each one's work doesn't get clobbered. When their verdicts aggregate, a cross-rubric table translates between letter grades / severity tiers.
3. **Three shared gates run at BOTH design AND audit time.** Journey-mapping (surface-type classification), element-reuse-check (Gate A verdict matrix), persona-lens (Gate B day-30 / partner / stranger tests) — these run at design time inside `product-designer` AND at audit time inside every reviewer. This is what prevents spec-to-impl drift; a passing spec doesn't survive if the implementation drifted from it. Plus four edit-time hooks (forbidden phrases / token-only / native-tab SF icons / no legacy blur) prevent entire classes of finding before any LLM tokens are spent.

### What configures it

**53 knobs** across 9 clusters: platform + dev-loop (5), benchmarks + voice (6), design system (9), surfaces + product context (8), product posture (6), compliance + a11y (5), testing + docs infrastructure (7), git mining (5), strategy + model selection (5). Of these, ~25 are reliably auto-discoverable via Phase 1 scan (file paths, package.json, existing stories, existing CLAUDE.md). The remaining ~28 need explicit user input, batchable into ~5-6 super-questions covering: (a) what does the project ship on + who are the users + capture path; (b) named Tier 1 / Tier 2 benchmarks + anti-references + demo audience; (c) does the product have a voice + reference + forbidden phrases; (d) design system + surface dirs + seed mechanism; (e) compliance + vision + model tier; (f) git-mined anti-pattern confirmation. Battle-tested baseline = ~15-20 min interview.

### What the interview must capture

The two highest-leverage knobs are `TIER_1_BENCHMARKS` and `TIER_2_BENCHMARKS_WITH_DIMENSION` — without specific named apps, every design agent's grading collapses to vibes. The two highest-applicability-gating knobs are `MULTI_SCREEN_ARCS_EXIST` (gates `flow-auditor` + `flow-ux-reviewer` + `journey-audit`-as-mandatory + `element-reuse-check`) and `PRODUCT_HAS_VOICE` (gates `persona-lens` + `forbidden-phrases.txt` + `check-forbidden-phrases.sh`). The two highest-reusability-blockers in current dotclaude principles are the missing `product-designer.md` principle (without which the interview can't drive the 8 product-designer-specific knobs) and the missing `design-system-reference-skill.md` principle (without which the interview captures token discipline but misses 8 other design-system knobs). Add those 2 principles + 3 more new ones (`flow-continuity-review`, `product-direction-validator`, `iterative-polish-autoloop`, optionally `component-story-authoring`) and dotclaude can fully reproduce the source kit on any matching project via configuration alone.
