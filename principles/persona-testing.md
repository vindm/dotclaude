# persona-testing — designing an outside-eyes lens on every visible string

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a persona-lens skill — three outside-eyes tests that run on every copy element to catch the "still apologizing on day 30" / "performing helpfulness" / "introducing the assistant the user has known for a month" class of voice violations.

## When to ship one (applicability gate)

Ship a persona-testing skill when:

- The project has **voice / persona discipline** — there's an authored voice the team wants every string to fit.
- The project has assistant-style or conversational copy where tone matters.
- The project has shipped a "this string feels wrong on the daily-driver surface" bug.
- Both designers and reviewers exist as roles (skill runs at both ends to prevent drift).

Skip when:

- The project has only functional copy (form labels, error messages with strict schemas) where voice considerations don't apply.
- The user is indifferent to voice — "as long as it's grammatical."
- The project's strings are user-generated content (chat / forum) where the platform shouldn't impose voice.

## Why it matters — what this catches that nothing else does

`forbidden-phrases.md` catches binary violations (specific phrases that shouldn't appear). `element-reuse.md` catches context-mismatch reuse. But strings can pass both and still feel wrong:

- A string written for day-1 enthusiasm ("Welcome back!") reads as condescending on day 30.
- A string written in customer-service register ("I'm here to help") reads as performative when the assistant is supposed to feel like a peer.
- A string written for a stranger ("Tap below to continue") reads as patronizing when the user already knows how the app works.

These don't appear on a deny-list because they're not specific phrases — they're voice-register failures that show up across many specific words. The persona-testing skill catches them by running three orthogonal outside-eyes tests on every string.

The skill also serves a **drift-prevention** role: it runs at both DESIGN time (designers test their proposed strings) AND AUDIT time (reviewers re-test the shipped strings). Without the audit-time rerun, implementations can silently drift from passing specs.

## Core methodology — the three tests

The three tests are orthogonal. A string passes only if ALL THREE pass. Two-of-three is insufficient.

### Test 1 — Frequency-jaded (the "day-30" test)

> "Would this string read OK if the user saw this exact string on day 30? Day 60? Day 365?"

A string that's fine on day 1 may grate on day 30. A first-touch string fails this instantly: "Hi — I'm <assistant>" on day 30 is repetition, not welcome.

A status string passes if it's evergreen: "Floor's quiet — 0 sessions today" works every day it's true.

Failure modes:
- "Welcome back!" — fine on day 2, weird on day 30.
- "Your data is loaded" — fine on day 1, condescending on day 365.
- "Tap the button below to continue" — fine for first-touch, patronizing thereafter.

This test catches strings that were authored for new-user emotional context and shipped to surfaces the user revisits regularly.

### Test 2 — Partner / peer (the voice-register test)

> "Would <named-reference-voice> say this — or does this sound like customer service / tutorial / performance?"

The reference voice depends on the project. Examples:
- Apple's empty-state voice in Photos / Notes (calm, observant, doesn't apologize).
- Telegram's product voice (terse, confident, present).
- A specific character / persona the team has named (e.g., "the partner-companion from <a film the team referenced>").

The anti-references (these FAIL the partner test):
- Customer-service register: "I'm here to help" / "How can I help" / "Is there anything else"
- Apology register: "Sorry to interrupt" / "Sorry, that didn't work" / "Oops"
- Performance register: "Great job!" / "You're crushing it" / over-eager exclamation
- Tutorial register: "Tap the button below" / "Here's how this works"

This test catches strings that fall into the LLM's default friendly-helpful register when the project's voice is supposed to be cooler / more confident / less performative.

### Test 3 — Cold-stranger (the "did this introduce me to something I know?" test)

> "Does this string assume the user has already met the assistant and the product — or is it introducing them as if for the first time?"

PASS = the string treats the user as someone who already knows the assistant and the product context.
FAIL = the string re-introduces, re-explains, re-asks information the user already provided.

Failure modes:
- "I'm <assistant>, your <product>'s <role>" on a daily-driver — user met the assistant in the wizard.
- "Let me explain how <feature> works" — user has used the feature for a week.
- "What kind of <thing> do you have?" — user has already configured it.

This test catches strings authored without knowledge of the user's accumulated context.

## Why all three are needed

Each test is orthogonal:

- A string can be evergreen (passes day-30) and still in customer-service voice (fails partner).
- A string can be in partner voice and still introduce the assistant (fails stranger).
- A string can avoid introduction and still grate at day 30 (fails day-30).

A string passes only if all three return PASS. Two-of-three ships drift.

## Core procedure

The skill walks four steps:

### Step 1 — Enumerate every copy element on the target

For designs: list every string in the proposed spec.

For audits: capture the surface and grep its strings (translation files + inline strings in components).

### Step 2 — Test each element

Build the audit table:

| Surface | Copy element | Day-30 | Partner | Stranger | Verdict |
|---|---|---|---|---|---|
| <surface> | <verbatim string> | PASS / FAIL | PASS / FAIL | PASS / FAIL | OK / REWRITE |

### Step 3 — Apply the verdict

- **All three PASS** → ship the string.
- **Any FAIL** → REWRITE. Do not ship a spec or claim audit-clean with failing strings.

### Step 4 — Hard-bound forbidden phrases (independent of the three tests)

Some phrases are categorically forbidden on certain surface types (see `forbidden-phrases.md`). The persona skill mirrors that deny-list as a hard-bound check independent of the three tests — these phrases never ship on the wrong surface, regardless of what the tests say.

## How to derive THIS project's specifics

Before authoring the skill, gather:

1. **The project's named voice reference.** The Partner test needs a specific reference: which voice does the project's assistant aspire to? Apple Photos' empty-state voice? Telegram's terseness? A character from a film the team references? Get a specific reference.

2. **The project's anti-references.** Customer-service tone is usually anti-reference. Are there others? "We don't want to sound like enterprise SaaS X" — that's actionable.

3. **The project's deny-list path.** The hard-bound forbidden-phrases check needs the path to the deny-list.

4. **The project's copy file locations.** Grep paths for Step 1 enumeration.

5. **Time-frequency framing.** If the project isn't day-30 framed (e.g., a checkout flow that runs once per user), the day-30 test may be wrong. Use the right time-frequency framing: a checkout might be "did this read OK to a user under cognitive load," a daily-driver might be "did this read OK on the 30th rerun."

6. **Alternative test triads.** Day-30 / partner / stranger is the canonical set for consumer / daily-use products. For other product types, the tests differ:
   - CLI tool: first-run / power-user / regression-debugger
   - Doc site: skimmer / focused-learner / reference-checker
   - B2B SaaS: trial-evaluator / power-admin / new-team-member
   The skill should pick the right triad for the product.

## Authoring the skill

The final skill (typically `.claude/skills/persona-lens/SKILL.md`) should specify:

1. **When to use** — at design time AND at audit time (the dual-run is the drift-prevention).
2. **When NOT to use** — pure-engineering code, internal debug labels, logging strings.
3. **The three tests** — with project-specific reference voices.
4. **The procedure** — enumerate / test / verdict / hard-bound deny-list.
5. **The audit-table format** — Day-30 / Partner / Stranger / Verdict columns.
6. **The non-negotiables** — all three pass; REWRITE is binding; audit-time rerun is mandatory.

## Cross-references

- `journey-mapping.md` — provides surface-type classification needed for the stranger test.
- `element-reuse.md` — Gate A (context fit). Persona-lens is Gate B (voice fit). Both run; both bind.
- `forbidden-phrases.md` — the authoritative deny-list. Persona-lens's hard-bound check references it.
- `flow-audit.md` / `ux-audit.md` / `interaction-audit.md` — these agents run persona-lens on visible copy at audit time.
- `quality-rubric.md` — persona-lens failures register against the "tone mismatch" pitfall.

## Anti-patterns in the skill you write

- **Two-of-three ships.** All three tests are needed. Allowing two-of-three is the drift slope: each compromise looks small in isolation; the cumulative effect is voice collapse.

- **No reference voice for the partner test.** "Friendly but not too friendly" is vibes. "Telegram's product voice" or "Apple Photos' empty-state voice" is enforceable.

- **Time-frame mismatch.** Using day-30 for a checkout flow that runs once is wrong; using first-run-only for a daily-driver is wrong. Match the test framing to the product's usage pattern.

- **Running only at design time.** Implementations drift from specs. The audit-time rerun is the only mechanism that catches the drift.

- **Running only at audit time.** Design-time application catches problems cheaply; audit-time-only means rewrites land late. Run at both ends.

- **REWRITE softening.** "FAIL — but it's contextually fine" defeats the gate. Either the test fails and the string is rewritten, or the test was wrong (in which case the test definition needs work, not the verdict).

- **No hard-bound deny-list check.** The three tests are interpretive; the deny-list is mechanical. Without the deny-list as a backstop, specific phrases the project has explicitly ruled out can slip through if the tests are run charitably.

- **Generic reference triad.** "Imagine three readers — frequency-jaded, partner, and cold-stranger" is the universal shape; the specifics must come from the project. A CLI-tool's triad is different from a consumer-app's triad.
