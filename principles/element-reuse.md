# element-reuse — designing the Gate A verdict matrix before reuse

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a reuse-gate skill that catches the "borrowed copy / component on the wrong surface type" class of bug at design time, not at user-testing time.

## When to ship one (applicability gate)

Ship an element-reuse skill when:

- The project has a **component library or string catalog** worth reusing (i.e., reuse is a common temptation).
- The project has multi-step user flows where surface types differ (see `journey-mapping.md`).
- The project has had at least one shipped bug where existing copy / a component leaked onto the wrong surface type.

Skip when:

- The project is greenfield — there's no existing inventory to reuse, so the gate is vestigial.
- The project's surfaces are all of one type (no first-touch / daily-driver distinction).
- Reuse is purely structural and rarely involves user-facing copy.

## Why it matters — what this catches that nothing else does

The failure mode this prevents: **a developer notices an existing string / component / copy pattern, reuses it on a new surface, and ships a bug that's invisible to per-element review because the element is fine in isolation.**

The canonical scenario:
- A string lives at `lib/copy/narration.ts:60`. It was authored for the first-touch wizard.
- A developer building a new daily-home widget needs a greeting line. They grep, find the string, reuse it.
- The reviewer sees a green diff that uses an existing translation key — the cheapest, lowest-risk-looking shape of change.
- The user sees "Hi — I'm <assistant>. Let me show you around." every morning when they open the app. The reviewer never noticed; the diff looked clean.

This bug class is invisible to:
- ESLint / TypeScript (the import resolves correctly).
- Code review (the diff looks fine in isolation).
- Visual review of the surface alone (the copy "reads OK" if you don't know the journey).

It's only visible if someone — or something — asks: *"What context was this string authored for, and does that context match this new surface?"* That question is the gate.

## Core methodology — the gate procedure

The skill runs four steps:

### Step 1 — Locate the existing usage

When a reuse is proposed (a string key, a component import, a copy pattern), the skill greps for the existing usage:

```
grep -rn "<exact-string-or-key>" <user-visible-code-dirs>
```

For each existing hit, capture:
- File:line of existing usage
- Surface on which it fires (read surrounding code to confirm)
- What role it plays there (intro / confirmation / CTA / status / error)
- When the user sees it (first-touch / daily / settings / error / promotional / bridge)

No grep evidence → no finding. "I think this is reused somewhere" without file:line is not a verdict-eligible claim.

### Step 2 — Classify both contexts

The skill uses the journey-mapping surface taxonomy (see `journey-mapping.md`). Both surfaces — the existing usage site and the proposed reuse site — must be classified as one of:

- first-touch
- daily-driver
- settings
- error
- promotional
- bridge

If the target hasn't been mapped yet, the skill stops and instructs the user to run journey-mapping first. The reuse gate is downstream of the journey map; without the map, the gate can't operate.

### Step 3 — Apply the verdict matrix

The matrix is a fixed lookup. The cell values are universal:

| Existing context → Proposed context | Verdict |
|---|---|
| first-touch → daily-driver | **REJECT** — write new copy |
| first-touch → settings | **REJECT** — write new copy |
| first-touch → error | **REJECT** — error surfaces have their own register |
| first-touch → first-touch (different stage) | **CAUTION** — re-introduction is itself a pattern |
| daily-driver → daily-driver (similar role) | **OK** |
| daily-driver → first-touch | **OK** — welcome surfaces can inherit ambient copy |
| daily-driver → settings | **OK** if neutral; **REJECT** if it implies first-use |
| settings → daily-driver | **REJECT** — settings register is too formal for active surfaces |
| settings → settings | **OK** |
| error → any non-error | **REJECT** — error register doesn't translate |
| any → promotional | **CAUTION** — promotional surfaces interrupt; copy must earn the interrupt |
| any → bridge | **REJECT** — bridges need authored transition copy, not borrowed |

**REJECT** = do not ship the reuse. Author new copy that fits the proposed context.
**OK** = proceed.
**CAUTION** = explicit judgment call required; name why the reuse is intentional, in writing.

### Step 4 — Document the audit

For designs (specs / brainstorms): append a Section 0a (or equivalent named section) to the design doc with a row per proposed reuse:

```markdown
## Section 0a — Element-reuse audit

| Proposed reuse | Existing in (file:line) | Existing context | New context | Verdict |
|---|---|---|---|---|
| <key or component name> | <path:line> | <type> | <type> | OK / CAUTION / REJECT |
```

For audits (reviews / grades): surface findings inline as a specific gap class. Mismatched-context reuse should be tagged at the project's highest severity tier — it's a real user-visible bug, not a polish concern.

If no reuse was proposed, the audit explicitly states "no element reuse proposed — all strings / components are new." The empty result is itself part of the audit — silence is not a substitute for a no-reuse claim.

## How to derive THIS project's specifics

Before authoring the skill, gather:

1. **The project's user-visible code directories.** Where do translation files live? Where are components? Where are screens? The Step-1 grep needs these paths or it misses real reuse.

2. **The project's existing reuse hot-spots.** Look at `grep -rn "useTranslation\|i18n.t\|t('" <code-dirs> | wc -l` for translation usage; high usage suggests many reuse decisions. Look at component imports — which components have the most call sites? These are the high-reuse-frequency elements where the gate is most useful.

3. **The project's deny-list.** The gate's REJECT rationale often points to deny-list violations (see `forbidden-phrases.md`). The skill should reference the deny-list.

4. **Whether the project has a journey map convention.** The gate depends on journey-mapping being available. If the user is shipping both skills (recommended), encode the cross-reference; if only one, decide whether reuse-gate is viable without the journey map (it usually isn't).

5. **The project's design-doc convention.** Where do specs live? `docs/designs/`? `docs/specs/`? Encode the doc shape so the Section 0a output landing convention is consistent.

## Authoring the skill

The final skill (typically `.claude/skills/element-reuse-check/SKILL.md`) should specify:

1. **When to use** — every proposed reuse of a user-visible string / component / copy pattern.
2. **When NOT to use** — new strings authored fresh; structural-only component reuse; pure-engine reuse (hooks, queries, internal utilities).
3. **The four-step procedure** — locate / classify / verdict / document.
4. **The verdict matrix** — copied as-is into the skill; the matrix cells are universal.
5. **Non-negotiables** — REJECT verdicts are binding; grep evidence is required; CAUTION demands written rationale.
6. **The output shape** — Section 0a (or equivalent) in design docs; inline gap entries in audits.

## When this skill is the precondition

The skill is meant to be invoked by:
- `product-designer` (or equivalent design agent), at design-spec authoring time — for every existing element the spec proposes to reuse.
- `flow-audit`, `ux-audit`, `interaction-audit` (audit agents) — when reviewing a surface that uses existing strings / components.

If a design / audit skips this gate, the failure mode it exists to prevent ships. Make it a non-negotiable precondition in those agents' workflows.

## Cross-references

- `journey-mapping.md` — provides the type classification this gate depends on. Required upstream input.
- `persona-testing.md` — Gate B. Independent test of each copy element against outside-eyes lenses. Reuse-gate is Gate A (context fit); persona-testing is Gate B (voice fit). Both run; both bind.
- `forbidden-phrases.md` — REJECT rationale often references deny-list violations.
- `quality-rubric.md` — reuse violations typically register as the rubric's "tone mismatch" pitfall.

## Anti-patterns in the skill you write

- **Soft REJECTs.** "REJECT — but it's fine because the user might not notice" → the user DOES notice; that's the bug class the gate exists to catch. REJECT is binding. The skill should refuse to ship work where a REJECT verdict was overridden without authoring new copy.

- **CAUTION without rationale.** A CAUTION verdict requires a written reason. An empty CAUTION row is functionally a REJECT.

- **Skipping grep evidence.** "I think this string is reused somewhere" without `grep -rn` evidence is not a finding. The skill should refuse to produce verdicts without file:line citations.

- **Operating without the journey map.** The gate's classifications depend on the journey map; without it, the gate is guessing. Encode the precondition explicitly.

- **Restricted to strings only.** Component reuse, copy patterns, narration variants all carry context. The gate applies to any user-visible element with an authored intent. Don't narrow to just translation strings.

- **Verdict matrix tuned per project.** The matrix cells are universal — they encode general truths about surface-type fit. Project-specific tuning is usually a sign that the project's surface types haven't been classified clearly. If the user wants to "soften" the matrix, the right move is to re-examine the classification, not the verdicts.

- **No empty-result reporting.** When no reuse is proposed, the audit should say so explicitly. Silence ≠ a no-reuse claim. The explicit statement is part of the audit trail.

- **Forgetting that "OK" verdicts are also signals.** When the matrix returns OK on a reuse, the design / audit can proceed — but if the OK count is unusually high (most copy is borrowed), that's a different kind of finding: the project's voice may be over-DRY at the cost of context fit. Surface the meta-pattern when relevant.
