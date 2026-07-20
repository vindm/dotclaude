# persona-testing — designing an outside-eyes lens on every visible string

Teaching material for Claude Code. Teaches you how to author a persona-lens skill — three outside-eyes tests that run on every copy element to catch the "still apologizing on day 30" / "performing helpfulness" / "introducing the assistant the user has known for a month" class of voice violation.

## DUAL LOAD — runs at BOTH design time AND audit time

Dual-loaded: it fires inside `product-designer` (design time, Section 0b of every spec — every proposed copy element passes the triad) AND inside `ux-audit` / `interaction-audit` / `flow-audit` (audit time, against every visible copy element on the captured surface). **The audit-time rerun catches implementation drift from spec** — a spec where every string passed at design time can still ship with strings that fail (an engineer swapped "Continue" for "Next"; a translation file was extended with copy pattern-matched from an adjacent first-touch surface; an LLM-shaped pipeline produced a customer-service register). Without the rerun, those substitutions ship invisible. Designers load it as Section 0b (proposed strings); reviewers load it as the first action when any visible copy is found (verify the string in source, apply the three tests, REWRITE is binding regardless of spec status).

## When to ship one

Ship a persona-testing skill when the project has voice / persona discipline (an authored voice every string should fit), assistant-style or conversational copy where tone matters, a history of "this string feels wrong on the daily-driver" bugs, or both designer and reviewer roles (the dual-run prevents drift). Skip when copy is purely functional (form labels, schema'd error messages), when the user is indifferent to voice, or when strings are user-generated content the platform shouldn't impose voice on.

## Why it matters

A phrase deny-list catches binary violations; `element-reuse.md` catches context-mismatch reuse. But strings can pass both and still feel wrong — a day-1 string (*"Welcome back!"*) reads condescending on day 30; a customer-service string (*"I'm here to help"*) reads performative when the assistant should feel like a peer; a stranger-framed string (*"Tap below to continue"*) reads patronizing when the user knows the app. These don't appear on a deny-list — they're voice-register failures spread across many specific words. The three tests catch them, and the dual-run (design + audit) stops implementations silently drifting from passing specs.

## Core methodology — the three tests

Orthogonal; a string passes only if ALL THREE pass — two-of-three ships drift.

**Test 1 — Frequency-jaded (the "day-30" test):** *would this read OK if the user saw this exact string on day 30? day 365?* A first-touch string fails instantly (*"Hi — I'm <assistant>"* on day 30 is repetition, not welcome); an evergreen status string passes (*"Floor's quiet — 0 sessions today"* works every day it's true). Catches strings authored for new-user emotional context and shipped to surfaces the user revisits.

**Test 2 — Partner / peer (the voice-register test):** *would <named-reference-voice> say this — or does it sound like customer service / tutorial / performance?* The reference is project-specific (Apple's Photos/Notes empty-state voice — calm, observant, doesn't apologize; Telegram's terseness; a named character). The anti-references that FAIL: customer-service (*"I'm here to help," "anything else?"*), apology (*"sorry, that didn't work," "oops"*), performance (*"Great job!" "you're crushing it"*), tutorial (*"tap the button below"*). Catches strings that fall into the LLM's default friendly-helpful register when the project's voice is cooler / more confident.

**Test 3 — Cold-stranger (the "did this introduce me to something I know?" test):** *does this assume the user has already met the assistant and product, or introduce them as if for the first time?* PASS treats the user as someone who already knows the context; FAIL re-introduces / re-explains / re-asks (*"I'm <assistant>, your <product>'s <role>"* on a daily-driver; *"let me explain how <feature> works"* to a week-long user). Catches strings authored without knowledge of the user's accumulated context.

Each is orthogonal — a string can be evergreen yet in customer-service voice; in partner voice yet introduce the assistant; introduction-free yet grate at day 30. All three must return PASS.

## Core procedure

**Step 1 — Enumerate every copy element** on the target (designs: every string in the spec; audits: capture the surface and grep its strings — translation files + inline strings). **Step 2 — Test each** into the audit table (Surface / Copy element / Day-30 / Partner / Stranger / Verdict). **Step 3 — Apply the verdict** (all three PASS → ship; any FAIL → REWRITE; never ship a spec or claim audit-clean with failing strings). **Step 4 — Hard-bound banned phrases**, independent of the three tests: mirror the project's deny-list as a mechanical check — these never ship on the wrong surface regardless of what the interpretive tests say.

## How to derive THIS project's specifics

1. **The named voice reference** for the Partner test — a specific one (Apple Photos' empty-state voice, Telegram's terseness, a named character), not "friendly but not too friendly."
2. **The anti-references** — customer-service is the usual one; *"we don't want to sound like enterprise SaaS X"* is actionable.
3. **The deny-list path** — for the hard-bound check.
4. **The copy file locations** — grep paths for Step 1.
5. **Time-frequency framing** — day-30 suits a daily-driver; a once-per-user checkout wants *"did this read OK under cognitive load"* instead.
6. **The right test triad for the product type** — day-30 / partner / stranger is canonical for consumer / daily-use; a CLI tool wants first-run / power-user / regression-debugger; a doc site wants skimmer / focused-learner / reference-checker; a B2B SaaS wants trial-evaluator / power-admin / new-team-member.

## Authoring the skill

The final skill (typically `.claude/skills/persona-lens/SKILL.md`) assembles the three tests (with the project's reference voices), the enumerate/test/verdict/deny-list procedure, and the audit-table format above, plus the non-negotiables: all three pass or REWRITE (two-of-three is the drift slope — each compromise looks small, the cumulative effect is voice collapse); REWRITE is binding (*"FAIL — but it's contextually fine"* defeats the gate; either rewrite the string or fix the test definition); the audit-time rerun is mandatory (design-time-only misses drift; audit-time-only lands rewrites late — run both ends); and the hard-bound deny-list backstops the interpretive tests (without it, ruled-out phrases slip through when the tests are run charitably).

## Cross-references

- `journey-mapping.md` — provides the surface-type classification the stranger test needs.
- `element-reuse.md` — Gate A (context fit); persona-lens is Gate B (voice fit). Both run, both bind.
- `flow-audit.md` / `ux-audit.md` / `interaction-audit.md` — these run persona-lens on visible copy at audit time.
- `quality-rubric.md` — persona-lens failures register against the "tone mismatch" pitfall.
