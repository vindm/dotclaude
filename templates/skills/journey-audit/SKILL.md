---
name: journey-audit
description: Build a user-journey map BEFORE designing or auditing a UI surface — every surface the user touched before the target, with type classification (first-touch / daily-driver / settings / error / promotional / bridge). Mandatory input for product-designer, flow-auditor, ux-reviewer, and interaction-audit. Without this map, designs and audits repeat onboarding copy on daily surfaces — the single most common failure pattern in growing UI codebases. Auto-loads when writing design / audit / flow documentation.
paths: "docs/audits/**,docs/flows/**,docs/designs/**,docs/brainstorms/**"
---

# Journey Audit

The user is not a stranger to your screen. They came from somewhere. Every design decision and every audit verdict depends on knowing *where*.

This skill is what separates a senior product designer from a screen-generator. A screen-generator places "Hi — I'm <assistant>" on every entrypoint because they look at one screen in isolation. A senior IC reads the journey first and knows: "The user has been introduced to the assistant 15 minutes ago in the wizard — re-introducing on this surface is wrong."

## When to use

- **Designing a new surface** (`product-designer`) — Section 0 of every spec is the journey map. No spec ships without it.
- **Auditing an existing surface** (`ux-reviewer`, `interaction-audit`) — before grading, classify the target's type. A daily-driver screen is graded by different rules than a wizard screen.
- **Auditing an arc** (`flow-auditor`) — the journey IS the arc; this map IS the inventory.

## When NOT to use

- Pure visual-polish tasks where the surface type is obvious and uncontested (e.g. "this list row has wrong padding").
- Code-only refactors with no UI surface impact.

## Procedure

### Step 1 — Enumerate prior surfaces

Start from **first app open** (sign-in / sign-up) and walk forward to the target surface. For each:

```bash
# Onboarding / first-touch
ls app/wizard/**/*.tsx 2>/dev/null
ls app/wizard/**/_layout.tsx 2>/dev/null
ls src/onboarding/**/*.ts 2>/dev/null
ls src/auth/**/*.tsx 2>/dev/null

# Authenticated daily-driver
ls app/\(authenticated\)/**/*.tsx 2>/dev/null

# Every user-facing string (this is where re-use lives)
ls src/translations/**/*.ts 2>/dev/null
ls src/narration/**/*.ts 2>/dev/null
```

Read enough of each file to know: what does the user see, what does the system / assistant say, what's the tone.

### Step 2 — Classify each surface

| Type | Definition | Example |
|---|---|---|
| `first-touch` | User hasn't seen the assistant or this concept yet | sign-up, wizard step 0, post-signup welcome |
| `daily-driver` | User opens this regularly, knows the assistant, knows the product | home, primary tabs |
| `settings` | Configuration surface, infrequent use, assumes product knowledge | account config, profile, billing |
| `error` | Recovery surface, user already in a flow | Job failed, network lost, permission denied |
| `promotional` | Marketing / nudges / one-shot announcements | Feature-launch banner, milestone celebration |
| `bridge` | Transition surface between two arcs | Wizard.completed → daily-home acknowledgement |

### Step 3 — Build the journey map

| Order | Surface | Type | Key copy / components shown to user |
|---|---|---|---|
| 1 | Sign-up | first-touch | <verbatim copy from the screen> |
| 2 | Wizard step 1 — Meet the assistant | first-touch | "Hi — I'm <assistant>. Let's set up your account." (verbatim) |
| 3 | Wizard step 2 — Vertical pick | first-touch | "What kind of account?" + 4 cards |
| ... | ... | ... | ... |
| K | **TARGET** (this design/audit) | <classify> | <what's proposed OR what's there now> |

Fill every row. Do not abbreviate. Verbatim copy — not paraphrase.

### Step 4 — Apply the forbidden-pattern matrix

Once the target is classified, these are hard rules (no exceptions):

| Target type | Forbidden patterns |
|---|---|
| `first-touch` | None — this IS the introduction surface |
| `daily-driver` | "Hi", "I'm <assistant>", "Welcome", "Let me introduce", "Let's get started", "Here's how this works", "Get started", "Meet <assistant>" — see your `forbidden-phrases.txt` |
| `settings` | Same as daily-driver + re-introducing concepts the user has set |
| `error` | "Sorry", "Oops", "I'm here to help" — never apologize. Apple Photos / Things 3 patterns: state the situation + offer one path forward |
| `promotional` | Re-introducing concepts the user already knows. Celebration ≠ re-greeting |
| `bridge` | Hard-cut into the next arc without acknowledgement — must narrate the transition |

If you find any forbidden pattern on the target: **that's a Crit-class gap** for audits, OR **rewrite required** for designs. No softening, no "but it kinda works."

### Step 5 — Cross-surface duplication check

Grep the target's proposed/current copy against the rest of the codebase:

```bash
grep -rn "<exact-string>" app/ src/ docs/ 2>/dev/null | head
```

If the same string appears on a surface of a DIFFERENT type, that's a problem — surface the duplication. The user has already seen it; repeating is repetition, not communication.

## Output

**For designs:** Section 0 of the spec doc (`docs/brainstorms/YYYY-MM-DD-<slug>-design.md`).

**For audits:** Section 0 of the audit doc OR an inline preamble before the gap table, naming target type + 1-2 prior surfaces that bind the audit.

## Non-negotiables

1. **The map is mandatory.** No spec / audit ships without it. The pattern "I'll skip Phase 0 because the surface feels simple" is exactly how "Hi — I'm <assistant> on the daily home" ships.
2. **Verbatim copy only.** Paraphrasing prior-surface copy hides duplication.
3. **Classification is binding.** Once you classify the target as daily-driver, the forbidden patterns apply — no judgment call to override.
4. **If you can't complete the map, STOP.** Tell the user "I need to read more of the existing flow before I can design/audit around it." That's senior-IC discipline.

## See also

- `element-reuse-check` skill — Gate A: when reusing an existing string, this is the second gate
- `persona-lens` skill — Gate B: every copy element passes day-30 / partner / stranger tests
- your project's `forbidden-phrases.txt` — authoritative phrase list
