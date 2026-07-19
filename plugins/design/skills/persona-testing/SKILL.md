---
name: persona-testing
description: Run three orthogonal outside-eyes tests on every user-visible string — day-30 (frequency-jaded), partner (voice-register), and stranger (already-knows-me) — to catch voice violations that pass a deny-list but still feel wrong. Load at design time on every proposed string and at audit time on every visible string on a captured surface.
---

# Persona testing

A deny-list catches binary phrase violations and the reuse gate catches context-mismatch reuse, but a string can pass both and still feel wrong: written for day-1 enthusiasm it reads condescending on day 30; written in customer-service register it reads performative when the assistant is meant to feel like a peer; written for a stranger it reads patronizing to a user who already knows the app. These aren't specific phrases — they're voice-register failures spread across many words. Three orthogonal tests catch them.

Run this at **both** moments:
- **Design time** — every proposed copy element in the spec passes the triad before the spec is approved.
- **Audit time** — first action when any visible copy element is found on the audited surface; verify the string in source, apply all three tests, and the REWRITE verdict binds regardless of what the spec said. This rerun is the only thing that catches implementation drift: an engineer swapping "Continue" for "Next", a translation file extended by pattern-matching from an adjacent first-touch surface, or an LLM-shaped pipeline emitting a customer-service register that was never in the spec.

## The three tests

Each is orthogonal. A string passes **only if all three PASS** — two-of-three ships drift.

### Test 1 — Frequency-jaded ("day-30")

> "Would this string read OK if the user saw this exact string on day 30? Day 60? Day 365?"

A first-touch string fails instantly: "Hi — I'm your assistant" on day 30 is repetition, not welcome. An evergreen status string passes: a quiet-state line works every day it's true. Catches strings authored for new-user emotional context and shipped to surfaces the user revisits regularly.

Match the framing to the product's usage pattern, derived at runtime. For a once-per-user flow (a checkout) the right framing is "did this read OK to a user under cognitive load" rather than "on the 30th rerun". For other product shapes, swap the whole triad for the fitting one — a CLI tool: first-run / power-user / regression-debugger; a doc site: skimmer / focused-learner / reference-checker; a B2B tool: trial-evaluator / power-admin / new-team-member. Pick the triad that fits this project's reader.

### Test 2 — Partner / peer (voice-register)

> "Would the project's reference voice say this — or does it sound like customer service, a tutorial, or a performance?"

The reference voice is project-specific — read the project's stated voice / quality-bar / design-north-star at runtime to find what it aspires to (a calm, observant, non-apologizing empty-state voice; a terse, confident, present product voice; or a specific named persona the team adopted). The anti-references that FAIL this test:
- **Customer-service register:** "I'm here to help" / "How can I help" / "Is there anything else"
- **Apology register:** "Sorry to interrupt" / "Sorry, that didn't work" / "Oops"
- **Performance register:** "Great job!" / "You're crushing it" / over-eager exclamation
- **Tutorial register:** "Tap the button below" / "Here's how this works"

Catches strings that fall into the default friendly-helpful register when the project's voice is meant to be cooler, more confident, less performative.

### Test 3 — Cold-stranger (already-knows-me)

> "Does this string assume the user has met the assistant and the product — or is it introducing them as if for the first time?"

PASS = treats the user as someone who already knows the assistant and the context. FAIL = re-introduces, re-explains, or re-asks information already provided ("I'm your assistant, here to help" on a daily-driver; "Let me explain how this works" on a feature used for a week; "What kind of thing do you have?" after it's configured). Catches strings authored without knowledge of the user's accumulated context.

## Procedure

1. **Enumerate every copy element on the target.** For designs, list every string in the proposed spec. For audits, capture the surface and grep its strings (translation files + inline strings in components — discover the paths at runtime).

2. **Test each element** into a table:

   | Surface | Copy element | Day-30 | Partner | Stranger | Verdict |
   |---|---|---|---|---|---|
   | <surface> | <verbatim string> | PASS/FAIL | PASS/FAIL | PASS/FAIL | OK/REWRITE |

3. **Apply the verdict.** All three PASS → ship. Any FAIL → REWRITE; do not ship a spec or claim audit-clean with a failing string.

4. **Hard-bound deny-list check (independent of the three tests).** Some phrases are categorically forbidden on certain surface types. Mirror the project's deny-list (read it at runtime if present) as a mechanical backstop — those phrases never ship on the wrong surface regardless of how charitably the three interpretive tests were run.

## Non-negotiables

All three tests pass or the string is REWRITE — no "FAIL but contextually fine" (if a test genuinely doesn't apply, the test definition was wrong, not the verdict). Run at both ends: design-time application catches problems cheaply, audit-time rerun catches the drift that ships otherwise. The partner test needs a *specific* reference voice — "friendly but not too friendly" is vibes; name the real one from the project.
