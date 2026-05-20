---
name: persona-lens
description: Three tests applied to every copy element on every user-facing surface — Day-30 (would this still read OK on day 30?), Partner (would a partner-companion say this, not customer-service?), Stranger (does this assume the user has already met the assistant?). Used by product-designer at design time AND by ux-reviewer / flow-auditor / interaction-audit at ship time, so implementations cannot silently drift from the spec. Auto-loads when editing translation / narration / copy files.
paths: "src/translations/**/*.ts,src/narration/**/*.ts,src/copy/**/*.ts,src/i18n/locales/**/*.ts"
---

# Persona Lens (Gate B)

A spec can pass `journey-audit` (right surface type) and pass `element-reuse-check` (no first-touch→daily reuse) and STILL ship copy that feels wrong on day 30 — because the copy was authored with the wrong voice in mind. This skill is the third gate.

Critically: this gate is run at BOTH ends of the pipeline. Designers run it before shipping a spec. Reviewers run it before declaring a surface done. Without both ends, the implementation can silently drift from the spec.

## When to use

- **Design** (`product-designer`): every copy element in the spec.
- **Audit** (`ux-reviewer`, `flow-auditor`, `interaction-audit`): every visible string on the target surface(s).
- **String-file edits**: when editing translation / narration / copy files, run this gate on the diff before committing.

## When NOT to use

- Pure-engineering code (no user-visible copy).
- Internal debug labels (clearly marked `dev`/`debug`).
- Logging strings (`log.info(...)`, etc.) — these aren't user-facing.

## The three tests

Apply all three to every copy element. A string passes only if ALL three return PASS.

### Test 1 — Day-30

> "Would this string read OK if the user saw this exact string on day 30? day 60? day 365?"

A first-touch string fails Day-30 instantly: "Hi — I'm <assistant>" on day 30 is repetition, not welcome. A status string passes Day-30 if it's evergreen ("Floor's quiet — 0 sessions today" works every day it's true).

**Failure mode:** "Welcome back!" — fine on day 2, weird on day 30, condescending on day 365.

### Test 2 — Partner

> "Would Samantha (the partner-companion model, not customer service) say this?"

Reference: the "Samantha" voice from *Her* — present, observant, doesn't apologize, doesn't perform helpfulness. Telegram's product voice. Apple's empty-state voice in Photos / Notes.

Anti-references (these FAIL the partner test):
- Customer-service register: "I'm here to help" / "How can I help" / "Is there anything else"
- Apology register: "Sorry to interrupt" / "Sorry, that didn't work" / "Oops"
- Performance register: "Great job!" / "You're crushing it" / over-eager exclamation points
- Tutorial register: "Tap the button below to continue" / "Here's how this works"

**Failure mode:** "I'd love to help you set up your account!" — partners observe and propose; they don't gush.

### Test 3 — Stranger

> "Does this string assume the user has already met the assistant — or is it introducing them as if for the first time?"

PASS = treats the user as someone who already knows the product / assistant.
FAIL = re-introduces the assistant, re-explains the product, re-asks information already provided.

**Failure mode:** "I'm <assistant>, your intelligent companion" on the daily home — the user met the assistant in the onboarding wizard 15 minutes ago.

## Procedure

### Step 1 — Enumerate every copy element on the target surface

For designs, list every string in the proposed spec.

For audits, capture the surface and grep its strings:

```bash
# Strings in translation files for the surface
grep -rn "<surface-key-prefix>" src/translations/ src/i18n/locales/

# Inline strings in the component
grep -E '"[A-Z][^"]+\."' <component-file>
```

### Step 2 — Test each element

Build the audit table:

| Surface | Copy element | Day-30 | Partner | Stranger | Verdict |
|---|---|---|---|---|---|
| Daily-home hero | "Floor's empty — let's go for a walk?" | PASS | PASS | PASS | OK |
| Daily-home card 1 | "Walk the floor" | PASS | PASS | PASS | OK |
| Daily-home hero | "Hi — I'm <assistant>, your companion" | FAIL | PASS | FAIL | **REWRITE** |

### Step 3 — Apply the verdict

- **All three PASS** = ship the string.
- **Any FAIL** = REWRITE. Do not ship a spec or claim "audit clean" with failing strings.

### Step 4 — Hard-bound forbidden phrases

Independent of the three tests, this list is **always** forbidden on daily-driver / settings / error / promotional surfaces (no exceptions):

- "Hi", "Hello", "Hey there"
- "I'm <assistant>", "My name is <assistant>", "Let me introduce", "Meet <assistant>"
- "Welcome", "Welcome to <product>"
- "Let's get started", "Let's begin", "Get started", "Here's how this works", "Let me show you around", "First, let me explain"
- "I'm here to help", "How can I help", "Is there anything else", "Sorry to interrupt", "Sorry, that didn't work", "Oops"

The authoritative list lives in your project's `forbidden-phrases.txt` and is enforced at edit time by a `check-forbidden-phrases.sh` hook. This skill's hard-bound list mirrors that — if the file is the source of truth, the hook catches violations before this gate; this gate is the runtime check for files outside the hook's scope (PR descriptions, design specs, spec doc strings).

## Output

**Designs:** Section 0b of the spec doc.

**Audits:** Per-element table in the gap report. Failing strings are Crit-class persona violations.

**String-file edits:** Inline gate before commit — the diff must show only PASS rows.

## Non-negotiables

1. **All three tests must pass.** Two-of-three is not enough.
2. **The forbidden-phrase list is binding everywhere except the explicit "meet the assistant" intro surface.** That one file is the auto-exempt because it IS the introduction.
3. **REWRITE verdicts are binding.** Don't ship "FAIL — but it's contextually fine" without explicit owner sign-off on overriding the test.
4. **Audit-time gate is mandatory.** Even if the design passed this gate at spec time, the audit re-runs it — implementations drift.

## Cross-references

- `journey-audit` skill — provides surface-type classification (needed to know which forbidden patterns apply)
- `element-reuse-check` skill — Gate A: when reusing a string, this gate is the third check
- your project's `forbidden-phrases.txt` — authoritative phrase list
- `check-forbidden-phrases.sh` hook — edit-time enforcement on `*/translations/`, `*/narration/`, `*/copy/`, and assistant-named files
