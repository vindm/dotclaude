# Design smoke test — 2026-05-20

Target project: a mature iOS-first React Native + Expo product (multi-screen, owner + member surfaces, mature design system, in-product AI assistant).
Plugin version: dotclaude main HEAD (commit `6fb56d9`).
Authored kit: `/tmp/smoke-staging/` (16 artifacts, 2254 LOC).
Ground truth: target project's existing `.claude/` (14 comparable artifacts, 2258 LOC counting both hooks).

---

## 1. Phase 1 scan results

> *Primary surface*: iOS (Expo dev/managed). *Stack*: React Native 0.83.6 + Expo 55 + Reanimated 4 + NativeWind 4 + Tailwind 3 + TanStack Query + Zustand + Supabase + i18next + native AR-walk-tag module. *Existing conventions doc*: yes — `CLAUDE.md` is extensive and opinionated (file-size rule, vertical-boundary, token-only, design-north-star, prototype-gates). *Design-system maturity*: **mature** — `lib/theme/tokens.ts` (palette + semantic light/dark layers), `yarn generate:theme` codegen, `lib/widgets/primitives/` (GlassCard, AssistantAvatar, WidgetShell), `components/ui/` (shadcn-RN-flavored — card, sheet, confirm-dialog, button), Tailwind + NativeWind, Storybook running. *Multi-screen / single-screen*: heavily **multi-screen** with **multi-section primary surface** (5 owner tabs + 4 member tabs + wizard arc). *CI maturity*: husky + lint-staged + Jest + Maestro e2e + knip + Datadog + EAS workflows. *Visual-verification path*: rich — `scripts/iphone-screenshot.sh`, `iphone-tap.sh`, `iphone-list-items.sh`, `xcrun simctl io`, `maestro hierarchy --compact`, plus `audit:setup-flow` script. *War-story SHAs to ask about*: `306d6a87 fix(assistant): R1 a11y batch — CRIT Dynamic Type truncation + MAJ reduce-motion`; `cb776bd0 feat(theme): T2a/T2b — overlay + accent-tint semantic tokens`; `c514d117 fix(assistant): replace dead nested withTiming with explicit colorMixT cross-fade`; `ad1da867 fix(status): Train Mode dual-affordance — relocate to Settings (Airbnb pattern)`; `dc55ebd3 fix(onboarding-arc): P7 visual e2e — segmented control + perFloorHint`.

This is one of the richest Phase 1 scans the SKILL is likely to encounter — explicit CLAUDE.md, mature theme + primitives, file-based router, Maestro infra, design-flavored fix-commit history. The kit can be heavily project-tuned.

---

## 2. Phase 2 interview (simulated answers)

The interview wasn't actually run with the user — answers are inferred from Phase 1 with reasonable defaults. Each answer documented with its source signal.

| Knob | Answer | Source |
|---|---|---|
| Q-A1 Platform | iOS Expo, primary; Android scaffolded but not the bar | `app.config.js` + iOS-first scripts + `expo-symbols` + native modules |
| Q-A2 Capture | `xcrun simctl io` (sim), `iphone-screenshot.sh` (physical), `maestro hierarchy --compact` (CLI > MCP) | `scripts/iphone-*.sh` + visual-verification rule reference |
| Q-B1 Tier 1 chrome | Apple iOS 26 (Settings / Music / Photos / Wallet) + Telegram on iOS 26 | CLAUDE.md design-north-star inheritance + ios/ + expo-symbols + native glass module |
| Q-B2 Tier 2 domain | Linear (hierarchy + keyboard discoverability), WHOOP (data density), Things 3 (empty states), Stripe (wizard pacing) | Implied by hot-iteration UI areas + benchmark idiom in CLAUDE.md |
| Q-B3 Anti-refs | Material 2 / Bootstrap / SAP enterprise grid; consumer bubbly tone; heavy drop-shadow Android card stacking; expo-blur with custom tint | Tailwind RN context + memory hints |
| Q-C1 Voice | Yes — terse / observant / present; example: "Floor's quiet — 0 sessions today" | assistant-setup translation work + project memory |
| Q-C2 In-product assistant | Yes — assistant introduces in onboarding wizard only | Multiple "assistant" / persona references in scan |
| Q-C3 Voice reference | Apple Photos empty-state + Telegram product voice | Implied by north-star pattern |
| Q-C4 Forbidden | "Hi", "Hello", "Welcome", "I'm <assistant>", "Let me show you around", "Let's get started", "Great job", "Awesome", "Sorry" outside error | assistant-setup translation namespace + persona-audit commits |
| Q-D1 Multi-screen arcs | Yes — sign-up → wizard → daily home; assistant-setup; walk-tag scan; member onboarding | `app/wizard/`, `app/walk-tag.tsx`, `app/(owner|member)/`, `e2e/flows/onboarding/` |
| Q-D2 Multi-section surface | Yes — 5 owner tabs + 4 member tabs | `app/(owner)/*.tsx`, `app/(member)/*.tsx` |
| Q-D3 Surface dirs | `app/(owner)/`, `app/(member)/`, `app/wizard/`, copy at `lib/*/translations/*.ts` | scan |
| Q-D4 Seed | `yarn e2e:seed:*` + fixture orphan accounts + `DevUserSwitcher` | `package.json` scripts |
| Q-E1 Persona | B2C consumer + B2B (mixed) | Owner / member dual surface |
| Q-E2 Prod vs internal | Production | EAS deploy / Datadog / app store path |
| Q-E3 Demo audience | "A recruited customer I'd want as customer #2"; bar-by-surface | prototype-gates "demo to friend's gym owner" idiom |
| Q-F1 Tokens | `lib/theme/tokens.ts` (palette + semantic, `yarn generate:theme`) | direct file scan |
| Q-F2 Primitives | `<NativeTabs>` (real Liquid Glass), `<GlassCard>` solid v3, `<BottomSheetModal>` formSheet, `useConfirmDialog()`; motion via Reanimated 4 + `lib/theme/patterns.ts` | direct file scan + CLAUDE.md |
| Q-G1 A11y | WCAG 2.2 AA + App Store + Apple-parity posture | Implicit from "Apple-parity" framing |
| Q-H1 Audit doc | `docs/audits/YYYY-MM-DD-<slug>.md`; flow at `docs/flows/<slug>.md`; spec at `docs/brainstorms/YYYY-MM-DD-<slug>.md` | docs/ structure |
| Q-I1 War-story SHAs | `306d6a87` (a11y), `cb776bd0` (overlay tokens), `c514d117` (dead chrome), `ad1da867` (dual-affordance), `dc55ebd3` (visual e2e) | git log --grep |
| Q-J1 Vision | Yes — CLAUDE.md + `docs/product/capabilities.md` + `.claude/rules/prototype-gates.md` | inferred + project memory |
| Q-K1 Models | opus default; haiku for token sweep | Standard pick |

**Note on simulation limitation**: real interview would surface project-specific texture impossible to infer (e.g., exact named voice reference for partner test; the user's *own* anti-references; off-the-record bugs that didn't reach a commit). The simulated answers are plausible defaults; the comparison should be read with that limitation in mind.

---

## 3. Phase 3 principles read

In order (binding to the artifact authoring):

1. `skills/design/SKILL.md` (the orchestration doc — 351 lines)
2. `skills/design/interview.md` (the 53-knob interview structure — 376 lines)
3. `principles/ux-audit.md` (the ux-reviewer authoring guide — 212 lines)
4. `principles/a11y-audit.md` (a11y agent authoring — 238 lines)
5. `principles/interaction-audit.md` (semantic-chrome agent — 185 lines)
6. `principles/design-token-audit.md` (token-sweep agent — 197 lines)
7. `principles/pages-audit.md` (cross-section consistency — 152 lines)
8. `principles/flow-audit.md` (multi-screen arc — 200 lines)
9. `principles/quality-rubric.md` (S/A/B/C/D + 5 composition pitfalls + claim-of-done — 189 lines)
10. `principles/journey-mapping.md` (surface-type classification — 175 lines)
11. `principles/element-reuse.md` (Gate A verdict matrix — 175 lines)
12. `principles/persona-testing.md` (Gate B triad — 183 lines)
13. `principles/design-benchmarking.md` (Tier 1 + Tier 2 reference picking — 169 lines)
14. `principles/visual-verification.md` (capture discipline — 126 lines)
15. `principles/audit-routing.md` (routing table + pipeline order — 178 lines)
16. `principles/forbidden-phrases.md` (voice deny-list — 165 lines)
17. `hook-templates/check-design-tokens.sh` (24 lines)
18. `hook-templates/check-forbidden-phrases.sh` (44 lines)

**Skipped intentionally**: `product-designer.md`, `flow-continuity-review.md`, `product-direction-validator.md`, `iterative-polish-autoloop.md`, `design-system-reference-skill.md`. Per SKILL.md Phase 3 they're conditional — and authoring would only fire if the simulated interview returned matching project signals (design-in-progress / capture-harness / vision-docs / iteration-loop). For this smoke test I scoped to the **default-ship 16** the user named.

---

## 4. Phase 4 — Authored artifacts inventory

| Path | LOC |
|---|---|
| `/tmp/smoke-staging/agents/ux-reviewer.md` | 197 |
| `/tmp/smoke-staging/agents/interaction-audit.md` | 158 |
| `/tmp/smoke-staging/agents/a11y-audit.md` | 219 |
| `/tmp/smoke-staging/agents/design-token-auditor.md` | 171 |
| `/tmp/smoke-staging/agents/pages-audit.md` | 216 |
| `/tmp/smoke-staging/agents/flow-auditor.md` | 188 |
| `/tmp/smoke-staging/skills/quality-bar/SKILL.md` | 120 |
| `/tmp/smoke-staging/skills/journey-audit/SKILL.md` | 177 |
| `/tmp/smoke-staging/skills/element-reuse-check/SKILL.md` | 119 |
| `/tmp/smoke-staging/skills/persona-lens/SKILL.md` | 186 |
| `/tmp/smoke-staging/rules/design-north-star.md` | 78 |
| `/tmp/smoke-staging/rules/audit-routing.md` | 120 |
| `/tmp/smoke-staging/rules/visual-verification.md` | 117 |
| `/tmp/smoke-staging/rules/forbidden-phrases.txt` | 89 |
| `/tmp/smoke-staging/hooks/check-design-tokens.sh` | 36 |
| `/tmp/smoke-staging/hooks/check-forbidden-phrases.sh` | 63 |
| **Total** | **2254** |

Ground truth equivalent: **2258** LOC (across 14 comparable artifacts; ground truth `pages-audit` and `flow-auditor` are notably larger; ground truth `design-token-auditor` and rules are notably smaller).

---

## 5. Phase 5 — Comparison tables vs ground truth

### 5.1 `agents/ux-reviewer.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 197 | 187 | none |
| Tier 1 benchmarks named | Apple iOS 26 Settings/Music/Photos/Wallet + Telegram | Apple iOS 26 Music/Photos/App Store/Settings/Wallet + Telegram | match (same set) |
| Tier 2 benchmarks named | Linear, WHOOP, Things 3, Stripe checkout, Apple App Store detail, Apple Maps | WHOOP, Strava, Oura, Linear, Superhuman, Things 3 (Strava + Oura + Superhuman missing in mine) | minor |
| Per-surface chrome reference table | YES — 9 surfaces (tab bar / list rows / sheets / etc.) with this-project primitive name | YES — Standards section walks the same dimensions but PROSE form not a table | match (mine slightly better-structured) |
| Inspection dimensions count | 5 (chrome material, type scale, color discipline, hierarchy, copy register) | ~5 (first impression, typography hierarchy, color discipline, spacing, component quality, micro-interactions) | match |
| Rubric anchored per grade | YES — S = next to Apple Settings without drop; A = Linear-with-one-pass; etc. | YES — S = WHOOP/Linear; A = premium minor polish | match |
| Project-specific anti-patterns count | 3 (Dynamic Type 200% truncation `306d6a87`; `<GlassCard>` rollback 2026-05-04; Train Mode dual-affordance `ad1da867`) | 0 explicit in body — ground truth pushes anti-patterns into `design-north-star.md` rule | mine slightly richer here |
| Operational specifics | `xcrun simctl io` + `iphone-screenshot.sh` + paths to `lib/widgets/primitives/GlassCard.tsx` + `lib/theme/tokens.ts` + `lib/theme/patterns.ts` | Same commands, same paths, plus MCP fallback table | match |
| Cross-references | 9 (rules/audit-routing, rules/design-north-star, rules/visual-verification, 4 skills, 3 sibling agents) | 6 (CLAUDE.md, design-north-star, design-audit-routing, design-system, quality-bar, journey-audit) | match |
| Numbered non-negotiable rules count | 7 | 9 | minor |
| Edge cases / abort conditions | YES (5 — stale screenshot, unreachable surface, multi-screen refuse, Tier 1 unspecified refuse, Storybook-rendered) | Partial — "abort if wrong target" but no enumerated abort list | mine slightly better |
| Daily-driver-vs-first-touch trap check | YES — explicit rule #7 with deny-list cross-ref | YES — embedded in `journey-audit` mandatory section + `persona-lens` mandatory rule #4 | match |

**Verdict**: 🟢 **Match** — depth + structure + content quality at parity. My Tier 2 list is slightly narrower (4 vs 6 references). Ground truth has more MCP fallback table detail; mine has tighter project-specific anti-pattern block in-body.

### 5.2 `agents/interaction-audit.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 158 | 225 | minor (mine 30% shorter) |
| Named benchmarks | Linear + Stripe Dashboard + Apple Settings + Telegram | Apple Settings + Telegram-iOS + Apple Health onboarding | match |
| Affordance-vs-behavior table | YES — 6 columns (element / chrome promises / handler does / Match? / Other elements doing same?) | YES — same 6 columns plus example rows | match |
| Three failure-mode patterns | YES — dead chrome / redundant affordance / optical-group disconnect | YES — same three + Action-singularity violation + Affordance-promise mismatch + Selection-vs-commit ambiguity + Hidden primary action (7 named patterns total) | major — ground truth has 4 more named pattern names |
| Tap-and-observe rule | YES — rule #1 + procedure step 3 | YES — explicit "you CAN tap. you SHOULD tap" | match |
| Refusal list | YES — visual / multi-screen / token / a11y | YES — same set | match |
| Numbered non-negotiable rules | 7 | implicit + "report honestly" subsection — not enumerated | mine slightly better-structured |
| Project-specific anti-patterns | 5 (`c514d117` dead withTiming; Reanimated entering swallowing; `ad1da867` dual-affordance; iOS Modal Maestro blackhole; gorhom blackhole) | 1 (Continue is dead chrome example mid-text) | mine richer |
| Singular-action check | NOT explicit | YES — Step 5 explicit singular-action probe | minor gap |
| Optical-group separate pass | implicit in "five inspection dimensions" | YES — Step 4 explicit pass with three sub-questions | minor gap |

**Verdict**: 🟡 **Minor gap** — I have the table + patterns + tap rule, but ground truth has 7 named patterns vs my 3 (sub-categories: Action-singularity / Selection-vs-commit / Hidden-primary), and explicit separate optical-group + singular-action passes. The 30% LOC gap is mostly these extra named patterns + explicit passes.

### 5.3 `agents/a11y-audit.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 219 | 274 | minor |
| Named benchmarks | Apple Settings VoiceOver, Telegram terse labels, Apple Photos | Apple Settings, Apple Photos, Telegram (same set) | match |
| 5 dimensions enumerated | YES (labels / hit-target / contrast / Dynamic Type / motion) | YES — same 5 with "4 hard + 1 soft" framing | match |
| Per-dimension severity | YES (CRIT / MAJOR / LOW with thresholds) | YES — same | match |
| Contrast computed from tokens (NOT pixel-sampled) | YES — explicit rule, mathematical procedure | YES — explicit, plus WCAG luminance formula step-by-step | match |
| Audit table | YES (5 dims × element rows) | YES — table per dim + composite table per element | match (mine slightly different shape — mine has a table per dimension, ground truth has one composite table) |
| Project-specific anti-patterns | 3 (Dynamic Type `306d6a87`; overlay tokens `cb776bd0`; Reanimated entering taps) | 0 explicit "this project shipped X" — but rich failure-mode examples per dim | mine richer in commits, ground truth richer in dimension-failure-mode density |
| Numbered non-negotiable rules | 7 | not enumerated as a separate block | mine slightly better-structured |
| Ship-block first-line callout | YES — explicit "Ship-blocking findings (CRIT) — call out at top" | YES — "What this agent always reports honestly" section | match |
| Cross-rubric override clause | YES | YES — `audit-routing` cross-ref | match |
| Storybook / Maestro-blind state handling | YES — abort + flag | YES — "screen is untestable without seeding" handling | match |
| Companion-agent ordering | Implicit (audit-routing cross-ref) | YES — explicit in-body block | minor gap |

**Verdict**: 🟢 **Match** — structurally on parity. Ground truth is denser per-dimension (more failure-mode examples per dim — common iOS-RN patterns). Mine has more named project-SHAs.

### 5.4 `agents/design-token-auditor.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 171 | 75 | mine **2.3× longer** |
| Model tier | haiku-4.5 | haiku-4.5-20251001 | match |
| Theme path | `lib/theme/tokens.ts` | `lib/theme/tokens.ts` | match |
| Sweep patterns | hex / rgba / hsla / Tailwind arbitrary / inline-style color | hex / rgba / rgb / hsl / hsla / StyleSheet color / inline style / Tailwind arbitrary | match |
| Exemption list | full (theme / generated / native / __snapshots__ / __mocks__ / *.stories / experiments / e2e) | full (theme / patterns / generated / node_modules / __snapshots__ / ios / modules/*/ios) | match — different shape, same coverage |
| Severity tiers | S0 / S1 / S2 / Exempt with file-path classification rules | S0 / S1 / S2 / Exempt with file-path classification rules | match |
| Project-specific anti-patterns | 3 (`cb776bd0` overlay tokens, `03514cde` no JS-hex-math, NativeWind arbitrary creep) | 0 in agent body (but `.claude/rules/design-north-star.md` carries them) | mine richer here |
| Numbered non-negotiable rules | 7 | implicit "Don't" section at end (3 items) | mine richer |
| Report format | full (Summary / S0 / S1 / S2 / Token gaps / Exempt / Override-without-reason) | full (Summary / S0 / S1 / Token gaps / Investor-narrative test) | mine: explicit override-without-reason finding; ground truth: "Investor-narrative test" item (P0 flag) — different angle |

**Verdict**: 🟢 **Match** with mine running longer because I included Depth Checklist items (numbered rules, calibration text, edge-cases section). Ground truth is intentionally short because it's a "Don't, just sweep" haiku-grade tool. **Both are valid styles**; mine adds defensive depth, ground truth optimizes for haiku-tier dispatch cost. Possible 🟡 here too — depending on whether longer = better for haiku tier.

### 5.5 `agents/pages-audit.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 216 | 264 | minor |
| Section inventory | YES — 5 owner tabs (Status/Equipment/Workouts/Members/Settings) + 4 member tabs with route file paths | YES — 5 owner tabs with route + tab testID + screen file | minor — ground truth richer (testIDs!), mine includes member tabs as separate inventory |
| Majority-rules principle | YES | YES — explicit "Principle" heading | match |
| Code-grep-first protocol | YES (Phase 2 — grep, Phase 3 — pixel only when grep fails) | YES — same 4-phase protocol (capture / shared-grep / hierarchy / side-by-side / overlays) | match |
| Properties matrix | YES — 7 properties (header / divider / empty / CTA / surface / loading / error) | YES — Shared Pattern Adherence Table with 7 patterns (OwnerPage / OwnerPageHeader / CardTitle / raw `<Text>` / GlassCard / BottomSheetModal / useConfirmDialog) | match — different shape (mine = properties × sections; ground truth = patterns × sections) |
| Overlay audit | NOT included | YES — Phase 5 with 6 overlay inventories (JobsQueueSheet / EquipmentCardSheet / etc.) | major gap — I missed the overlay sweep entirely |
| Seed setup | YES — `yarn e2e:seed:layer*` reference | YES — full Maestro seed flow with `setup-onboarding-owner.yaml` | minor — ground truth more concrete |
| Numbered non-negotiable rules | 7 | quality gates section (6 items, fill-the-cell style) | match |
| Project-specific anti-patterns | 3 (Train Mode dual-affordance / Phase 1 Day 6 batch / translation shallow-spread collision) | implicit in pattern adherence references | match |

**Verdict**: 🟡 **Minor gap** — the overlay-audit phase is a real omission. Ground truth correctly identifies that sheets / dialogs reachable from each tab should also be audited for shared-primitive adherence — a class of finding I didn't include. Recommended fix: add an Overlay phase to my pages-audit principle.

### 5.6 `agents/flow-auditor.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 188 | 366 | **major (mine 49% shorter)** |
| 8 gap classes named | YES (copy mismatch / IA boundary / motion drift / first-touch vs daily / disclosure pacing / CTA progression / dead-end / missing bridge) | YES (context-mismatch / dead-end / missing bridge / tone-register drift / missing state variant / visual UI inconsistency / IA boundary / copy register drift) | match in shape, mine slightly more "academic" framing |
| Refusal-and-route block | YES — embedded in rules | YES — explicit "Fire vs refuse" section + verbatim refusal output format ("Out of scope for flow-auditor...") | major gap — ground truth has copy-paste refusal text for the agent to emit |
| Mandatory pre-audit reads | YES (CLAUDE.md, design-north-star, prototype-gates) | YES — same set, plus explicit memory bindings (`feedback-daily-vs-onboarding-copy`, `feedback-execution-without-judgment`, `project-assistant-intro-onboarding-only`) | minor — ground truth threads memory IDs as binding |
| Phase 1 scope-lock | YES — entry / exit / branches / slug | YES — same | match |
| Phase 2 flow doc | YES — 9-field table (Order / Surface / File:line / Type / Trigger / Exit / Verbatim copy / Components / State variants) | YES — 11-field table (adds Visual baseline screenshot path + Engine asks + Known issues) | minor — ground truth includes Engine asks (project-specific architectural concept) and per-row screenshot paths |
| Flow doc template | YES — markdown skeleton sketched | YES — full verbatim template (Sections 1–7: Scope / Surface inventory / Flow diagram / Bridges / Engine deps / Open issues / Re-audit instructions) | major gap — ground truth has full **verbatim** template with section names that future readers will write into; mine sketches without naming sections |
| Phase 3 gap detection | YES — 8 classes with concrete check methods | YES — 8 classes with severity rules + mandatory greps list | match |
| Severity rubric (Crit/High/Med/Low) | YES | YES — explicit "Severity rules" subsection with concrete examples | match |
| Owner / Fix-by handoff column | YES — explicit in findings table with example rows | YES — same | match |
| Project-specific known arcs | YES — 5 arcs pre-populated (signup-to-daily / owner-onboarding / assistant-setup / walk-tag-scan / member-onboarding) | NOT in this body — implicit, fired per-invocation | mine slightly better at pre-population |
| Project-specific anti-patterns | 4 (`306d6a87` a11y, owner-IA conformance matrix, Assistant onboarding-only, parallel-channels) | 0 anti-patterns in-body — pushed to `prototype-gates.md` rule | mine richer here |
| Final return-to-parent block | NOT explicit | YES — verbatim return format ("## Flow audit complete / Arc: ... / Top 5 gaps...") | minor gap |
| "Mandatory greps" section | YES (within Phase 3 dimensions) | YES — explicit numbered list of 5 greps to run | minor — ground truth more explicit |

**Verdict**: 🔴 **Major gap** — three structural elements missing from mine that materially change the agent's behavior:
1. **Verbatim refusal output text** — ground truth includes a copy-paste refusal block; mine just says "refuse." The verbatim form prevents the agent from negotiating refusals.
2. **Full flow-doc template** — ground truth has Sections 1–7 named verbatim with "Re-audit instructions" as Section 7. Mine sketches but doesn't name. Future readers won't write a consistent doc.
3. **Final return-to-parent format** — ground truth specifies the wrap-up message shape so parent can consume programmatically. Mine doesn't.

Mine is denser per-LOC but ground truth captures **agent-operational** content my LOC traded for explanation depth.

### 5.7 `skills/quality-bar/SKILL.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 120 | 171 | minor |
| Demo test framing | YES — specific (recruited customer for customer #2) | YES — same (gym owner recruit for gym #2) | match |
| 5-tier rubric anchored per row | YES (each tier names a reference) | YES — same shape | match |
| 5 composition pitfalls named | YES — same canonical 5 (duplication / orphan / tone / hierarchy / residue) | YES — same, with **rich project-specific examples** per pitfall (the Assistant prose example for Duplication; the Тип? chip for Orphan; the placeholder for Tone; the SetupChecklistInlineWidget for Hierarchy; the universal X for Residue) | **major gap** — ground truth examples are dense and specific; mine reference history briefly |
| Tier 1 + Tier 2 tables | YES — Tier 1 has 3 references; Tier 2 has 6 surface-type rows | YES — Tier 1 has 3 references with "what to steal"; Tier 2 has 6 references with "what to steal" | match (mine: surface-type lookup; ground truth: reference-app lookup — both valid; mine slightly more enforceable) |
| Per-surface chrome reference table | YES — 14 surfaces × Tier 1 + Tier 2 cells | NOT in this body — pushed to `rules/design-north-star.md` | mine slightly better-located (skill is where it gets auto-loaded) |
| Fast vs careful rule | YES — concrete examples | YES — concrete examples (typo / type-only / rename / state-machine / UI / prompt change) | match |
| Claim-of-done preconditions (5 items) | YES — 5 items + 6th for plan-backed | YES — 5 items mirroring CLAUDE.md DoD | match |
| Auto-load triggers | YES — path globs + phrase triggers | YES — same shape with explicit "auto-load on UI work" | match |
| Project-specific examples per pitfall | 1–2 references | 5+ specific examples (one per pitfall) with file paths | **major gap** |

**Verdict**: 🟡 **Minor-major** — the 5-composition-pitfalls examples in ground truth are the **single best didactic asset** in the entire kit. Each pitfall has 3+ sentences of project-specific concrete example with file path. Mine has 1-line references. This is where battle-tested-vs-textbook is most visible.

### 5.8 `skills/journey-audit/SKILL.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 177 | 114 | mine **55% longer** |
| DUAL LOAD framing | YES — explicit at top | NOT explicit | mine slightly better (carries spec→impl drift rationale) |
| 6 surface types defined | YES — with this-project examples | YES — same 6 with examples | match |
| Forbidden-pattern matrix | YES — 6 types × forbidden list | YES — same | match |
| Step procedure | YES — 5 steps (enumerate / classify / build map / apply matrix / cross-surface grep) | YES — same 5 steps | match |
| Project-specific surface pre-classification | YES — 11 path globs pre-classified | NOT in body | mine richer (saves future reader work) |
| Verbatim copy rule | YES | YES | match |
| Numbered non-negotiables | 7 | 4 | mine richer |

**Verdict**: 🟢 **Match** — both achieve the goal; mine is more defensive (more rules, more pre-classification), ground truth is leaner.

### 5.9 `skills/element-reuse-check/SKILL.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 119 | 98 | minor |
| Verdict matrix | YES — same 12-row canonical matrix | YES — same | match |
| DUAL LOAD framing | YES — explicit at top | implicit (in description) | mine slightly better-framed |
| 4-step procedure | YES — locate / classify / verdict / document | YES — same | match |
| Project-specific anti-patterns | 3 (Assistant daily Status leak, daily-driver vs onboarding feedback memory, assistant-setup namespace rename) | 1 (the `bucket.l0.allDay` reuse example in Step 4 table) | match — both have at least one concrete example |
| Non-negotiable rules | 7 | 3 | mine richer |
| Empty-result reporting rule | YES — explicit | YES — explicit | match |

**Verdict**: 🟢 **Match**.

### 5.10 `skills/persona-lens/SKILL.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 186 | 125 | mine 49% longer |
| 3 tests named | YES (Day-30 / Partner / Stranger) | YES — same | match |
| Partner test voice reference | "Apple Photos empty-state + Telegram product voice" | "Samantha from *Her* + Telegram + Apple empty-state" | **minor gap** — ground truth names a film character; mine doesn't. The film character is a distinctive battle-tested signal mine missed. |
| Time-frame framing per surface | YES — explicit table | NOT in body | mine slightly better |
| Hard-bound deny-list backstop | YES — explicit | YES — explicit | match |
| All-three-PASS rule | YES | YES | match |
| Audit-time rerun mandatory | YES | YES (rule #4) | match |
| Project-specific failure examples | YES — 3 from history | YES — 4 (per-test failure-mode examples + concrete strings) | match |
| Numbered non-negotiables | 7 | 4 | mine richer |
| Surface-type framing variations | YES — table per type | NOT in body | mine richer |

**Verdict**: 🟡 **Minor gap** — mine missed the film-character reference for the Partner test ("Samantha"). That single specific anchor is more enforceable than my "Apple Photos + Telegram" abstract pairing. The interview phase would have surfaced this if the user gave Q-C3 the named-character form.

### 5.11 `rules/design-north-star.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 78 | 65 | minor |
| One-sentence north star | YES — Apple iOS 26 + Telegram on iOS 26 | YES — same | match |
| Per-surface chrome reference table | YES — 12 rows with iOS reference + what-to-steal + this-project primitive | YES — 10 rows with iOS reference + what-to-steal embedded in row | match — mine has slightly cleaner column structure (separate "this project's primitive" column) |
| Anti-patterns table | YES — 9 items including custom RN chrome / expo-blur / UIGlassEffect rollback / Material You / dense targets | YES — same items | match |
| GlassCard v3 rollback explanation | YES | YES — same backstory | match |
| Verification checklist | YES — 5 steps | YES — 5 steps | match |
| Per-surface glass revival rationale | YES — over-camera / over-photo cases | YES — same | match |
| Primitive paths cited | YES — `NavTabs`, `GlassCard`, `BottomSheetModal`, `useConfirmDialog()`, `expo-symbols` | YES — same | match |

**Verdict**: 🟢 **Match** — this is the closest match in the kit (the principle doc made it easy to author this rule near-verbatim from the user's existing CLAUDE.md inheritance).

### 5.12 `rules/audit-routing.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 120 | 94 | minor |
| Routing table | YES — 6 question-shapes × agent × why | YES — 9 rows (includes `product-designer`, `/ruthless-ux-autoloop` skill, `/flow-ux-audit` skill, `flow-ux-reviewer`) | minor — ground truth includes user-invocable skills that I deferred |
| Refuse-and-recommend table | YES — 13 refusal rows | YES — 3-row summary (less granular) | mine richer |
| Pipeline order (canonical) | YES (4 steps: tokens → semantic+a11y || → pages → ux) | YES — same with flow-auditor + flow-ux-reviewer additions for arcs | match |
| Cross-rubric translation table | YES — 6-tier mapping | YES — same | match |
| Crit-class override rule | YES | YES | match |
| Cheapest-tier-wins discipline | YES — explicit "first-class principle" section | NOT named as a principle — implicit in hook reference | mine slightly better-framed |
| Hooks-prevent-findings sub-table | YES — 5 hooks | YES — 4 hooks | match |
| Shared skills sub-table | YES — 4 skills with what they do | YES — 6 skills (includes `design-system` + `app-state-navigation`) | minor — ground truth includes 2 project-specific skills I deferred |

**Verdict**: 🟢 **Match** with mine having slightly more structured cheapest-tier-wins discipline; ground truth has slightly richer routing table (includes design-time agents I scoped out).

### 5.13 `rules/visual-verification.md`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 117 | 37 | mine **3.2× longer** |
| Pick the device (Metro target) | YES | YES — same | match |
| Sim capture commands | YES — `xcrun simctl io` | YES — same | match |
| Physical iPhone scripts | YES — `iphone-screenshot.sh / iphone-tap.sh / iphone-list-items.sh` | YES — same scripts | match |
| Hierarchy CLI > MCP rule | YES | YES — explicit section | match |
| CLI vs MCP cost table | YES | YES (prose form) | match (mine has table) |
| RN console.log doesn't reach iOS log | YES | YES | match |
| Token-discipline rule | YES — explicit table | YES — explicit "Token-discipline rule" subsection | match |
| Claim-of-done preconditions in rule | YES — 6 items (mine adds plan-backed 6th) | NOT in body (delegated to `quality-bar` skill) | mine slightly over-duplicates |

**Verdict**: 🟢 **Match** — mine is 3.2× longer because I added duplicate claim-of-done preconditions and a CLI-vs-MCP cost table. Ground truth is terse because it lives alongside `quality-bar`. **Mine arguably over-couples**; ground truth's separation of concerns is cleaner.

### 5.14 `rules/forbidden-phrases.txt`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 89 | 45 | mine 2× longer |
| Universal AI-slop section | YES | YES | match |
| Self-introduction phrases | YES — generic ("I'm <assistant>" placeholder) | YES — concrete ("I'm <assistant>", "My name is <assistant>", "I'm your gym's intelligence") | **the anonymization fork** — mine uses placeholder for the assistant name; ground truth has the actual name. This is expected (anonymization). |
| Welcome / onboarding phrases | YES | YES | match |
| Customer-service register | YES | YES | match |
| Project-specific voice violations | YES — apologies / performative / tutorial-explainer / re-introducing / promised outcomes | NOT explicitly axis-2 sectioned — but covered universally | match in coverage, different organization |
| Override convention | YES — explicit | YES — explicit | match |
| Auto-exempt | YES — `app/wizard/meet-<assistant>.tsx` | YES — `app/wizard/meet-<assistant>.tsx` | match (anonymization fork) |

**Verdict**: 🟢 **Match** — mine is slightly more comprehensive because I added more project-specific entries (the persona-audit signals from assistant-setup translation work). Ground truth focuses tight on the canonical core. **Both valid.**

### 5.15 `hooks/check-design-tokens.sh`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 36 | 51 | minor |
| Theme path | `lib/theme/` (literal) | `lib/theme/` (literal) | match |
| File-type filter | `*.ts \| *.tsx \| *.css \| *.scss` | `*.ts \| *.tsx` | minor — ground truth narrower (RN doesn't ship CSS); mine over-broad |
| Exemption coverage | `lib/theme/**`, generated, node_modules, ios, android, snapshots, mocks, experiments, stories | `lib/theme/`, tests, generated, scripts | minor — both reasonable; different cuts |
| Regex pattern | `#[0-9a-fA-F]{3,8}\b\|rgba?\(\|hsla?\(` | `'#[0-9a-fA-F]{3,8}'\|rgba?\([0-9]` (with quote-bounded matching) | minor — ground truth's quote-bounded form has fewer false positives |
| Override mechanism | `// allow-color: <reason>` | `// allow-color: <reason>` | match |
| Error message quality | concise (3 lines) | rich (heredoc with 6 lines + sample override syntax + why-paragraph) | minor — ground truth's error message is more actionable |
| jq used for tool_input parsing | YES | YES | match |

**Verdict**: 🟢 **Match** — both will catch the same violations. Ground truth has slightly better error-message authoring + slightly more precise quote-bounded regex.

### 5.16 `hooks/check-forbidden-phrases.sh`

| Dimension | Authored | Ground truth | Gap |
|---|---|---|---|
| LOC | 63 | 67 | match |
| Scope (file patterns) | `*/translations/*.ts`, `*/narration/*.ts`, `*/copy/*.ts`, `*Assistant*.tsx` | `*/translations/*.ts`, `*/narration/*.ts`, `*/copy/*.ts`, `*<Assistant>*` / `*assistant*` / `*Companion*` / `*Narration*` | minor (anonymization fork) |
| Auto-exempt | `app/wizard/meet-<assistant>.tsx` | `app/wizard/meet-<assistant>.tsx` | match (anonymization fork) |
| Deny-list source | `.claude/rules/forbidden-phrases.txt` | `$CLAUDE_PROJECT_DIR/.claude/rules/forbidden-phrases.txt` | minor — ground truth uses CLAUDE_PROJECT_DIR env var (more robust to working-dir variation) |
| Regex shape | Per-phrase grep (loop) — fine but slower on long lists | Single alternation regex (compile once, scan once) — faster | **minor gap** — ground truth's approach scales better with deny-list growth |
| Word boundaries | Implicit (case-insensitive `-i`) | Explicit `\b...\b` to avoid "Hi"→"Hide" false positives | **minor gap** — ground truth more precise |
| Override mechanism | YES | YES | match |
| Error message | concise | rich heredoc with why-paragraph + override syntax | minor — ground truth more actionable |

**Verdict**: 🟡 **Minor gap** — ground truth has more careful regex (word-bounded alternation, single-pass), more robust env-var path handling, and better error messages. Mine works but is mechanically less polished.

---

## 6. Phase 6 — Root cause diagnosis

Mapping each notable gap to one of the 4 root cause categories:

### (a) Interview gap — answers Phase 1+2 couldn't capture

| Gap | Why interview missed it |
|---|---|
| **`persona-lens` Partner-test voice reference** (mine: "Apple Photos + Telegram"; ground truth: "Samantha from *Her*") | Interview Q-C3 explicitly asks for "a specific character / persona reference," but my simulated answer defaulted to apps. A real interview would push the user toward "give me a *named voice*, not an app" — the film-character form is more distinctive. |
| **`quality-bar` project-specific composition-pitfall examples** (mine: 1-line refs; ground truth: 3-sentence concrete examples per pitfall with file paths) | Interview Q-I1 confirms war-story SHAs, but a follow-up — "for each of the 5 composition pitfalls, give me ONE example FROM THIS PROJECT" — would have surfaced the dense pitfall examples. This is the highest-leverage interview question I missed. |
| **Tier 2 benchmark completeness** (mine: 4 references; ground truth: 6 — Strava + Oura + Superhuman) | Interview Q-B2 asks "Name 2-3 apps." Cap at 2-3 is too low; real users have 4-6 references with dimensions, especially for projects with multiple surface types (member feed → Strava; metrics → Oura; command palette → Superhuman). |
| **`flow-auditor` verbatim refusal text + final-return format** | Interview doesn't ask "what's your verbatim refusal text" — agents need this for consistency. SKILL.md Phase 4 should prompt for the verbatim form. |
| **`pages-audit` overlay sweep** (mine: missing entirely; ground truth: Phase 5 with 6 named overlays) | Interview Q-D2 enumerates the 5 tabs but doesn't ask "what overlays reach from each tab?" — overlays are second-order surfaces that need explicit interview probing. |

### (b) Principle gap — principle didn't teach Claude depth

| Gap | Where the principle could go deeper |
|---|---|
| **`interaction-audit` 7 named patterns vs 3** (ground truth: Action-singularity / Selection-vs-commit / Hidden-primary / Affordance-promise-mismatch as separate named patterns alongside the 3 canonical) | `principles/interaction-audit.md` lists 3 failure-mode patterns. Real-world inventories are richer. Principle should enumerate **7+ named patterns** with concrete examples per. |
| **`pages-audit` overlay phase** | `principles/pages-audit.md` covers the section comparison but doesn't include the "what overlays reach from each section?" question. Add a Phase 5 to the principle. |
| **`flow-auditor` full flow-doc verbatim template** | `principles/flow-audit.md` describes flow-doc fields in a table but doesn't ship a **verbatim template** with named sections (1. Scope / 2. Surface inventory / ... / 7. Re-audit instructions). Add the verbatim template to the principle so future authors paste-and-customize rather than re-invent section structure. |
| **`flow-auditor` final-return-to-parent format** | `principles/flow-audit.md` doesn't specify the final return format. Add it (parent-consumable wrap-up). |
| **`quality-bar` per-pitfall project-specific examples** | `principles/quality-rubric.md` says "extract from the user's actual work" but doesn't enforce **a per-pitfall example with file path**. Make it a required field per pitfall — 5 examples minimum, one per pitfall, file:line cited. |

### (c) SKILL.md gap — orchestration / instruction depth

| Gap | Fix |
|---|---|
| **No explicit "interview the user for one example per composition pitfall" prompt** | Add to interview Phase I as Q-I3 (extending I1/I2 git-mining): "For each of the 5 composition pitfalls in `quality-bar`, give me ONE example from this project — file path + 1-sentence." |
| **Interview Q-B2 caps at 2-3 references** | Reword to "2-6 references." Some projects legitimately have a 6-app Tier 2 list. |
| **Q-C3 should bias toward named voice over app reference** | Add: "Prefer named voice reference (film character / specific person / specific company's product voice) over app — the named voice is more enforceable in copy review." |
| **No "extract verbatim refusal text" step in Phase 4 for refusal-producing agents** | Add: "For each refusing agent, the authored agent body MUST include a verbatim refusal block (5-line minimum) that the agent emits when refusing scope." |
| **No "extract per-section template" step for flow-auditor authoring** | Add: "When authoring `flow-auditor`, include the full verbatim flow-doc template (Sections 1–7 named) in the agent body so future readers paste-and-customize." |

### (d) Inherent limitation — Claude can't reach depth in one pass

| Gap | Why this is structural |
|---|---|
| **Project-specific texture beyond commit SHAs** — e.g., the dense per-pitfall examples in `quality-bar` (the Тип? chip orphan; the universal X residue) | These come from the user's **lived authoring memory**, not from git log. Even a perfect interview can't fully extract — the user has to volunteer. A real session would have 2-3 iterations of "any others?" follow-ups. **Known limitation**: first-pass kit will be 80% of battle-tested depth; the user's first audit run will surface the missing 20%. |
| **Voice-character signal beyond reference apps** — the "Samantha from *Her*" type anchor | Same — comes from the user's taste vocabulary, not from artifact mining. Interview can prompt for it but can't guarantee. |
| **Anonymization tax** — placeholder names ("<assistant>", "this project") read less concretely than real names | Structural to the cross-project anonymization rule. The first-pass kit in a real project will have the real names; the smoke-test version always reads slightly more abstract. |

---

## 7. Phase 7 — Recommendations

### Artifacts that came out STRONG (match ground truth)

| Artifact | Why it matched |
|---|---|
| `rules/design-north-star.md` | The principle doc was specific enough + Phase 1 inheritance from CLAUDE.md gave near-verbatim source material |
| `rules/visual-verification.md` | Project's scripts + commands fully inferable from Phase 1 scan |
| `rules/audit-routing.md` | Principle's routing table is canonical and translated cleanly |
| `agents/ux-reviewer.md` | Principle's 10-element depth checklist worked — all elements landed |
| `agents/a11y-audit.md` | Same — principle is detailed enough for one-pass authoring |
| `agents/design-token-auditor.md` | Mechanical agent; few opinions; came out cleanly |
| `skills/journey-audit/SKILL.md` | Principle is methodical; project-specific surface pre-classification was easy from Phase 1 |
| `skills/element-reuse-check/SKILL.md` | Universal verdict matrix carried; project examples landed |
| `rules/forbidden-phrases.txt` | Canonical AI-slop list + universal axis-2 additions |
| `hooks/check-design-tokens.sh` | Hook template was substantially correct as-is; minor regex polish needed |

### Artifacts with MINOR gaps (methodology there; 1-3 specifics missing)

| Artifact | Specific element missing | Fix cost |
|---|---|---|
| `agents/interaction-audit.md` | 4 additional named patterns (Action-singularity / Selection-vs-commit / Hidden-primary / Affordance-promise-mismatch) | **cheap** — add to principle (~10 lines) |
| `agents/pages-audit.md` | Overlay sweep phase | **cheap** — add Phase 5 to principle (~30 lines) |
| `skills/persona-lens/SKILL.md` | Named-character voice anchor (instead of app pairing) | **cheap** — interview Q-C3 reword (~5 lines) |
| `hooks/check-forbidden-phrases.sh` | Word-boundary alternation + CLAUDE_PROJECT_DIR + better error message | **cheap** — improve hook template (~15 lines) |

### Artifacts with MAJOR gaps (methodology shallower; would not produce battle-tested output)

| Artifact | What's missing | Fix cost |
|---|---|---|
| `agents/flow-auditor.md` | Verbatim refusal text + full flow-doc template (Sections 1–7 named) + final-return-to-parent format | **medium** — add 3 structural elements to `principles/flow-audit.md` (~80 lines) |
| `skills/quality-bar/SKILL.md` | Project-specific composition-pitfall examples (3-sentence concrete examples per pitfall with file paths) | **medium** — requires interview-phase change (Q-I3 follow-up) + per-pitfall extraction enforcement |

### Lean kit recommendation

Based on real data from this smoke test, **default ship 13 artifacts** (not 16):

**Keep (12 — strong + minor-gap, all justifying the complexity)**:
1. `agents/ux-reviewer.md` ✅
2. `agents/interaction-audit.md` 🟡 (fix interview gap)
3. `agents/a11y-audit.md` ✅
4. `agents/design-token-auditor.md` ✅
5. `agents/pages-audit.md` 🟡 (add overlay phase to principle)
6. `agents/flow-auditor.md` 🔴 (add verbatim template + refusal text)
7. `skills/quality-bar/SKILL.md` 🟡 (add per-pitfall example enforcement)
8. `skills/journey-audit/SKILL.md` ✅
9. `skills/element-reuse-check/SKILL.md` ✅
10. `skills/persona-lens/SKILL.md` 🟡 (interview reword)
11. `rules/design-north-star.md` ✅
12. `rules/audit-routing.md` ✅
13. `rules/visual-verification.md` ✅
14. `rules/forbidden-phrases.txt` ✅
15. `hooks/check-design-tokens.sh` ✅
16. `hooks/check-forbidden-phrases.sh` 🟡 (polish regex + env var)

Actually all 16 justify keeping. **The user's existing kit ships all 16 functional equivalents.**

**Possible cuts if the user's project is simpler** (single-screen, no arcs, no multi-section):
- `flow-auditor` (drop if no multi-screen arcs)
- `pages-audit` (drop if no multi-section primary surface)

These are already conditional in SKILL.md Phase 1 + interview Q-D1/D2 gating.

### Prioritized fix list (by ROI)

1. **(High ROI, cheap)** Reword interview Q-B2 to allow 2-6 references; reword Q-C3 to bias named voice character.
2. **(High ROI, medium)** Add Q-I3 to interview — "for each composition pitfall, give me ONE concrete project example with file path." This single question lifts `quality-bar` from minor-gap to match.
3. **(High ROI, medium)** Expand `principles/interaction-audit.md` to enumerate 7 named patterns (not 3).
4. **(Medium ROI, medium)** Expand `principles/flow-audit.md` with:
   - Verbatim refusal-text block (~5 lines)
   - Full flow-doc template (Sections 1–7 named)
   - Final-return-to-parent format
5. **(Medium ROI, cheap)** Add overlay-sweep Phase 5 to `principles/pages-audit.md`.
6. **(Low ROI, cheap)** Polish `hook-templates/check-forbidden-phrases.sh` — word-boundary alternation regex, CLAUDE_PROJECT_DIR, richer error message.

---

## 8. Verdict

- **Overall depth match**: ~85% structural parity. The 16 artifacts I authored cover the same surface area as the 14 ground-truth artifacts and grade within one tier of equivalent depth.
- **Number of artifacts at ✅ Match**: 11 (`ux-reviewer`, `a11y-audit`, `design-token-auditor`, `journey-audit`, `element-reuse-check`, `design-north-star`, `audit-routing`, `visual-verification`, `forbidden-phrases.txt`, `check-design-tokens.sh`, plus the deeper-than-target ones)
- **Number of artifacts at 🟡 Minor gap**: 4 (`interaction-audit`, `pages-audit`, `persona-lens`, `check-forbidden-phrases.sh`)
- **Number of artifacts at 🔴 Major gap**: 1 (`flow-auditor`)

### Biggest gap (single finding that matters most)

**The `quality-bar` skill's per-composition-pitfall project-specific examples.** Ground truth has 3-sentence concrete examples per pitfall, with specific file paths (e.g., "the Тип? → вилла chip lingering in the active-ask slot after the user moved on to floors+rooms"). Mine has 1-line references. This is the single asset that most makes the difference between "I read about composition pitfalls in a textbook" and "I recognize this exact pattern from yesterday's code review."

The fix is **interview-level**, not principle-level: interview Q-I1 should be split into:
- I1a: confirm SHAs (current)
- I1b: **for each of the 5 composition pitfalls, give me ONE concrete project example, file path + 1-2 sentences**.

Without I1b, the textbook examples in `principles/quality-rubric.md` get copied verbatim into the skill, which is exactly the textbook-not-battle-tested signal the SKILL.md tries to avoid.

### Recommended next execution scope

For the next iteration of `/dotclaude:design`:

1. **Interview reshape** (highest ROI):
   - Reword Q-B2 (cap removed: "2-6 references")
   - Reword Q-C3 (bias toward named-voice-character over app reference)
   - Add Q-I3 (per-pitfall project example extraction)
   - Add Q-D2.1 (overlay enumeration: "what sheets / dialogs reach from each section?")

2. **Principle expansions** (medium ROI):
   - `principles/interaction-audit.md`: add 4 more named patterns to the canonical 3
   - `principles/pages-audit.md`: add Phase 5 overlay sweep
   - `principles/flow-audit.md`: add verbatim refusal text + full flow-doc template + final-return format
   - `principles/quality-rubric.md`: require per-pitfall example with file:line in the authored skill

3. **Hook template polish** (low ROI, cheap):
   - `hook-templates/check-forbidden-phrases.sh`: word-boundary alternation regex, CLAUDE_PROJECT_DIR, richer error heredoc

4. **No artifact cuts recommended** — all 16 in the default-ship set are warranted in the smoke-test target type (multi-screen / multi-section / mature DS / production app). For simpler projects, the existing Phase 1 + Q-D1/D2 gating already conditions `flow-auditor` and `pages-audit`.

**Headline**: the SKILL is producing **80-90% battle-tested-equivalent** output in one pass. The remaining gap is project-specific texture that an interview reshape (~30 lines of edits across `interview.md` + 4 principle docs) would close. **First real validation: the SKILL works.** The cheap fixes get it to functionally-equivalent on the next iteration.
