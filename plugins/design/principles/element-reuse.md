# element-reuse — designing the Gate A verdict matrix before reuse

Teaching material for Claude Code. Teaches you how to author a reuse-gate skill that catches the "borrowed copy / component on the wrong surface type" class of bug at design time, not at user-testing time.

## DUAL LOAD — runs at BOTH design time AND audit time

Dual-loaded: it fires inside `product-designer` (design time, Section 0a of every spec) AND inside `ux-audit` / `interaction-audit` / `flow-audit` (audit time, when any borrowed string / component is detected). The dual-load catches **implementation drift from spec** — the spec said "fresh string authored for daily-driver context," the implementation reached for the nearest existing string at `lib/copy/narration.ts:60` to save time. The design-time gate caught nothing (the proposal was new authorship); the audit-time gate catches the silent substitution and flags the first-touch → daily-driver reuse as REJECT. Without the rerun, the audit grades the result without checking provenance, and the bug ships. Designers load it as Section 0a; reviewers load it as the first action when any user-visible string / component is encountered (grep the source, classify both contexts via `journey-mapping`, apply the matrix).

## When to ship one

Ship an element-reuse skill when the project has a component library or string catalog worth reusing (so reuse is a common temptation), has multi-step flows where surface types differ, and has shipped at least one "existing copy leaked onto the wrong surface type" bug. Skip when the project is greenfield (no inventory to reuse — the gate is vestigial), when all surfaces are one type, or when reuse is purely structural and rarely involves user-facing copy.

## Why it matters

The failure mode: a developer notices an existing string / component / pattern, reuses it on a new surface, and ships a bug invisible to per-element review because the element is fine in isolation. The canonical scenario — a string at `lib/copy/narration.ts:60` authored for the first-touch wizard; a developer building a daily-home widget greps, finds it, reuses it; the reviewer sees a green diff using an existing translation key (the cheapest, lowest-risk-looking change); the user sees *"Hi — I'm <assistant>, let me show you around"* every morning. Invisible to ESLint / TypeScript (the import resolves), code review (the diff looks fine), and single-surface visual review (the copy "reads OK" if you don't know the journey). Only one question exposes it: *what context was this authored for, and does it match the new surface?* That question is the gate.

## Core methodology — the gate procedure

**Step 1 — Locate the existing usage.** When a reuse is proposed (a string key, a component import, a copy pattern), grep for it (`grep -rn "<exact string or key>" <user-visible-code-dirs>`). For each hit, capture the file:line, the surface it fires on (read surrounding code to confirm), the role it plays (intro / confirmation / CTA / status / error), and when the user sees it (first-touch / daily / settings / error / promotional / bridge). No grep evidence → no finding — *"I think this is reused somewhere"* without file:line is not verdict-eligible.

**Step 2 — Classify both contexts** using the `journey-mapping` taxonomy — both the existing usage site and the proposed reuse site get one of first-touch / daily-driver / settings / error / promotional / bridge. If the target hasn't been mapped, STOP and run journey-mapping first — the gate is downstream of the map and can't operate without it.

**Step 3 — Apply the verdict matrix** (cells are universal):

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
| any → promotional | **CAUTION** — promotional interrupts; copy must earn the interrupt |
| any → bridge | **REJECT** — bridges need authored transition copy, not borrowed |

**REJECT** = don't ship the reuse; author new copy that fits. **OK** = proceed. **CAUTION** = explicit judgment call, name why the reuse is intentional in writing.

**Step 4 — Document the audit.** For designs, append Section 0a (a row per proposed reuse: Proposed reuse / Existing in file:line / Existing context / New context / Verdict). For audits, surface findings inline at the project's highest severity tier — mismatched-context reuse is a real user-visible bug, not a polish concern. If no reuse was proposed, state *"no element reuse proposed — all strings / components are new"* explicitly; the empty result is part of the audit trail, silence is not a substitute.

## How to derive THIS project's specifics

1. **The user-visible code directories** — where translations, components, screens live; the Step-1 grep needs these or it misses real reuse.
2. **The reuse hot-spots** — high translation usage (`grep -rn "useTranslation\|i18n.t\|t('" <dirs> | wc -l`) and the most-imported components are where the gate is most useful.
3. **The deny-list** — REJECT rationale often points to deny-list violations.
4. **Whether a journey-map convention exists** — the gate depends on it; if only one skill ships, the reuse-gate usually isn't viable without the map.
5. **The design-doc convention** — where specs live, so the Section 0a landing is consistent.

## Authoring the skill

The final skill (typically `.claude/skills/element-reuse-check/SKILL.md`) copies the verdict matrix as-is (the cells are universal) and assembles the four-step procedure and the Section-0a output format above, plus the non-negotiables: REJECT is binding (*"REJECT — but the user might not notice"* → the user DOES notice, that's the bug class; refuse to ship work where a REJECT was overridden without new copy); CAUTION requires written rationale (an empty CAUTION is functionally a REJECT); grep evidence with file:line is required; the gate operates only with a journey map; it applies to any user-visible element with authored intent (strings, components, copy patterns, narration variants — not just translation strings); and if a project wants to "soften" the matrix, the fix is re-examining the surface classification, not the verdicts. Note two meta-signals: an unusually high OK count (most copy borrowed) means the project's voice may be over-DRY at the cost of context fit — surface it.

## Cross-references

- `journey-mapping.md` — provides the type classification this gate depends on; required upstream.
- `persona-testing.md` — Gate B (voice fit); reuse-gate is Gate A (context fit). Both run, both bind.
- `quality-rubric.md` — reuse violations register as the rubric's "tone mismatch" pitfall.
