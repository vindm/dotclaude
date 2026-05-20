---
name: element-reuse-check
description: When proposing reuse of an existing string, component, narration variant, or copy pattern on a new surface — grep for existing usage, classify the context of both surfaces, apply the verdict matrix. Catches the "first-touch copy reused on daily-driver" class of bug at design or audit time, not at user-testing time. Used by product-designer, ux-reviewer, flow-auditor, interaction-audit.
---

# Element-Reuse Check (Gate A)

Existing code is a draw. "I'll just reuse `bucket.l0.allDay`" is the most common path to shipping wrong copy. The string lives in `translations/narration.ts:60` — but it was authored for the **wizard meet-assistant** surface, and surfacing it on a **daily-driver** is what produces "Hi — I'm <assistant>" on every morning open.

This skill is the gate between "I noticed an existing string" and "I shipped it."

## When to use

Trigger this gate **whenever** you propose using an EXISTING:

- String key (translations / narration / copy)
- Component (especially state-rendering or copy-rendering ones)
- Narration variant
- Surface treatment / layout pattern
- Empty-state copy

…on a **target surface**, regardless of whether you're designing or auditing.

## When NOT to use

- New strings you're authoring fresh (no reuse claim → no gate needed).
- Component reuse where the component is purely structural (e.g. `<PageContent>` wrapper, `<GlassCard>`) with no copy of its own — surface type doesn't affect their semantics.
- Pure-engine reuse (a hook, a query, an RPC tool) — this gate is for **user-visible** reuse.

## Procedure

### Step 1 — Locate the existing usage

```bash
# Exact-string search across user-visible code
grep -rn "<exact-string-or-key>" app/ src/ docs/ 2>/dev/null | head
```

For each hit, capture:
- **File:line** of existing usage
- **Surface** on which it fires (read the surrounding code if not obvious)
- **What role it plays** there (intro? confirmation? CTA? status update?)
- **When the user sees it** (first-touch? daily? error recovery?)

### Step 2 — Classify both contexts

Use the journey-audit type taxonomy (`first-touch / daily-driver / settings / error / promotional / bridge`). If you haven't run the `journey-audit` skill yet, run it first — you cannot classify a target surface without the journey.

### Step 3 — Apply the verdict matrix

| Existing context | Proposed context | Verdict |
|---|---|---|
| first-touch | daily-driver | **REJECT** — write new copy |
| first-touch | settings | **REJECT** — write new copy |
| first-touch | error | **REJECT** — error surfaces have their own register |
| first-touch | first-touch (different stage) | **CAUTION** — re-introduction is itself a pattern |
| daily-driver | daily-driver (similar role) | **OK** |
| daily-driver | first-touch | **OK** — welcome surfaces can inherit ambient copy |
| daily-driver | settings | **OK** if neutral; **REJECT** if it implies first use |
| settings | daily-driver | **REJECT** — settings register is too formal for active surfaces |
| settings | settings | **OK** |
| error | any non-error | **REJECT** — error register doesn't translate |
| any | promotional | **CAUTION** — promotional surfaces interrupt; copy must earn the interrupt |
| any | bridge | **REJECT** — bridges need authored transition copy, not borrowed |

**REJECT** = do not ship the reuse. Write new copy that fits the proposed context.
**OK** = proceed.
**CAUTION** = make an explicit judgment call in the spec/audit, naming why the reuse is intentional.

### Step 4 — Document the audit

For designs, append Section 0a to the spec doc:

```markdown
## Section 0a — Element-reuse audit

| Proposed reuse | Existing in (file:line) | Existing context | New context | Verdict |
|---|---|---|---|---|
| `bucket.l0.allDay` ("Hi — I'm <assistant>...") | translations/narration.ts:60 | first-touch (wizard) | daily-driver (home) | **REJECT** — write new daily copy |
| `<SnapshotCard>` | components/SnapshotCard.tsx | daily-driver (home S3) | daily-driver (home S2 zero-state) | **OK** — same surface role |
```

For audits, surface findings inline in the gap report as Class-1 (context-mismatch copy) gaps with severity Crit.

If no reuse was proposed, state explicitly: "no element reuse proposed — all strings/components are new."

## Non-negotiables

1. **REJECT verdicts are binding.** Don't ship "REJECT — but it's fine because…" — write new copy instead.
2. **Grep is the evidence.** "I think this is reused" without `grep -rn` evidence is not a finding. Every row in the audit table needs file:line.
3. **CAUTION verdicts demand a written rationale.** Empty rationale = REJECT.

## Cross-references

- `journey-audit` skill — provides the type classification this gate depends on
- `persona-lens` skill — Gate B: independent test that each copy element passes day-30 / partner / stranger
- your project's `forbidden-phrases.txt` — authoritative list (also enforced at edit-time by `check-forbidden-phrases.sh`)
