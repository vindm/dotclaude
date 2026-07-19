---
name: element-reuse
description: Before reusing an existing string, component, or copy pattern on a NEW surface — locate its current usage with grep, classify both the existing and the proposed surface by type, and apply the verdict matrix. Catches first-touch copy leaking onto a daily-driver surface, a bug invisible to lint, code review, and per-surface visual review. Load at design time and audit time on any borrowed user-visible element.
---

# Element reuse (Gate A)

When you reuse an existing user-visible element on a new surface, you risk shipping the same intent into a context it wasn't authored for. The canonical scenario: a greeting string lives in the codebase, authored for a first-touch wizard. A developer building a daily-home widget needs a greeting line, greps, finds it, reuses it. The diff looks clean — an existing key, the cheapest-looking change. The user then sees "Hi — I'm your assistant, let me show you around" every single morning. Lint passes (the import resolves), code review passes (the diff is fine in isolation), visual review of the surface alone passes (the copy "reads OK" if you don't know the journey). It's only visible if someone asks: *what context was this authored for, and does it match this new surface?* That question is this gate.

Run at **both** moments:
- **Design time** — Section 0a of the spec, for every existing element the spec proposes to reuse.
- **Audit time** — first action when any borrowed string/component is detected on the captured surface. This catches implementation drift: the spec said "fresh string authored for daily-driver", but the implementation reached for the nearest existing string to save time. The design-time gate saw new authorship; the audit-time gate catches the silent substitution.

## Procedure

### Step 1 — Locate the existing usage

Grep for the existing usage of the proposed element (a string key, a component import, a copy pattern), across this project's user-visible code directories (discover them at runtime — translation files, components, screens):

```
grep -rn "<exact-string-or-key>" <user-visible-code-dirs>
```

For each hit, capture: file:line, the surface it fires on (read the surrounding code to confirm), the role it plays there (intro / confirmation / CTA / status / error), and when the user sees it.

**No grep evidence → no finding.** "I think this is reused somewhere" without a file:line is not a verdict-eligible claim.

### Step 2 — Classify both contexts

Classify both the existing usage site and the proposed reuse site as exactly one surface type — first-touch / daily-driver / settings / error / promotional / bridge. (This is the journey-map taxonomy; the gate is downstream of it.) If the target surface hasn't been mapped yet, stop and build the journey map first — without it the gate is guessing.

### Step 3 — Apply the verdict matrix

A fixed lookup; the cells are universal truths about surface-type fit, not project-tunable:

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

- **REJECT** = do not ship the reuse; author new copy that fits the proposed context.
- **OK** = proceed.
- **CAUTION** = explicit judgment call; name in writing why the reuse is intentional. An empty CAUTION row is functionally a REJECT.

If you find yourself wanting to "soften" a matrix cell, the real problem is almost always unclear surface classification — re-examine the classification, not the verdict.

### Step 4 — Document the audit

For designs, append a section to the spec with one row per proposed reuse:

```markdown
## Section 0a — Element-reuse audit

| Proposed reuse | Existing in (file:line) | Existing context | New context | Verdict |
|---|---|---|---|---|
| <key or component> | <path:line> | <type> | <type> | OK / CAUTION / REJECT |
```

For audits, surface findings inline as a gap, tagged at the project's highest severity tier — mismatched-context reuse is a real user-visible bug, not a polish concern.

If no reuse was proposed, **say so explicitly** — "no element reuse proposed; all strings/components are new". Silence is not a no-reuse claim. And if the OK count is unusually high (most copy is borrowed), surface that as its own meta-finding: the project's voice may be over-DRY at the cost of context fit.

## Non-negotiables

REJECT verdicts are binding — refuse to ship work where a REJECT was overridden without authoring new copy ("the user might not notice" is wrong; the user *does* notice, and that's the whole bug class). Grep evidence with file:line is required for any verdict. CAUTION demands a written rationale. The gate applies to any user-visible element with an authored intent — strings, components, copy patterns, narration variants — not just translation strings.
