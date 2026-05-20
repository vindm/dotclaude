---
name: quality-bar
description: The operational rubric for non-trivial UI work — demo test, S/A/B/C/D grading, named composition pitfalls (duplication / orphan elements / tone mismatch / hierarchy violations / residue), benchmark anchors (Apple iOS 26 + Telegram first; WHOOP / Linear / Raycast secondary), and the fast-vs-careful decision rule. Auto-load when the change touches a user-facing screen. See your project's design-north-star rule for the chrome-by-chrome reference.
---

# Quality Bar

The operational rubric easy to forget to apply. Project rules say "S-tier" and "Apple-or-Telegram parity"; this skill is *how* to actually do it.

**Invoke when:** the change touches a user-facing screen, a prompt that shapes UX, an onboarding flow, or anything a real user could see. Auto-load on UI work.

**Don't invoke for:** internal scripts, type-only fixes, lint cleanups, server-only logic with no UI surface.

---

## The demo test (the only test that actually matters)

For every UI change ask one question:

> *"Would I demo this to a real user / customer I'm trying to recruit?"*

If **no**, it's not done. Not "ship it and iterate later." Not "good enough for now." Not done.

This single question short-circuits hours of debate. It also reveals what the work is actually for: every user-facing surface either earns the user's next conversation or it doesn't.

Corollary: if the answer is "yes, but only with caveats" — name the caveat. *"Yes, but the placeholder is wrong."* That's the first thing to fix.

---

## S/A/B/C/D rubric

Grade every changed surface against a concrete reference, not a vague feeling.

| Tier | Means | Reference |
|---|---|---|
| **S** | Indistinguishable from Apple's own iOS 26 chrome OR Telegram on iOS 26. Real Liquid Glass, native motion, copy authored, hierarchy obvious. Demo-ready. | **Apple Music / Photos / Wallet / Settings on iOS 26. Telegram on iOS 26.** |
| **A** | Clearly intentional, no rough edges, would not embarrass anyone next to a top-tier app. Polish gaps minor. | WHOOP onboarding. Linear inbox. Raycast. Things 3. |
| **B** | Functional, looks designed, but has one or two visible cracks (truncated copy, off-by-pixel padding, generic empty state, fake-glass that reads as another RN app). | Decent SaaS dashboards. Notion's lesser surfaces. |
| **C** | Looks rushed. Inconsistent spacing, residue elements, lazy empty states, untranslated strings, debug labels showing in prod. | Half-shipped startups. |
| **D** | Broken or embarrassing. Black screens, overlapping controls, no done button, dead-end. | Don't ship. |

For every PR-sized change, name the tier you're shipping at and the **single highest-ROI move to push up one tier.**

**S-tier requires Apple-or-Telegram parity on the chrome dimension.** A flat-card "decent SaaS" surface is A-tier — never S — even if it's tasteful. See your project's `design-north-star` rule for what "Apple-or-Telegram parity" means concretely (Liquid Glass, SF Symbols, native tab bar, glass sheets).

---

## The five composition pitfalls

These are the ones easily missed when grading individual elements but a real user sees instantly.

### 1. Duplication
Two or more elements communicating the same fact.

*Pattern:* an assistant's prose "Got it — 2 floors, 6 rooms" + a confirmation chip "Floors and rooms? → 2 floors, 6 rooms" + a setup-progress widget all conveying the same state. Three elements, one piece of information. Collapse to one.

**Fix:** pick the canonical surface; delete the others. Usually the prose is fine on its own.

### 2. Orphan elements
A control with no clear job. Often residue from a previous turn.

*Pattern:* a "Kind? → villa" chip lingering in the active-ask slot after the user moved on to the next question. Visible, looks tappable, has no meaning in current context.

**Fix:** explicit teardown. When state transitions, close prior surfaces. A `.close()` call after the state mutation is the canonical pattern.

### 3. Tone mismatch
The element's voice doesn't match what the user is doing.

*Pattern:* composer placeholder reading "Type a name…" or "Ask a question…" when the user is *answering* the assistant. The placeholder asks; the situation requires answering. Mismatch.

**Fix:** placeholders should be context-aware. Switch placeholder based on the current conversation state.

### 4. Hierarchy violations
Elements have visual weight that doesn't match their importance.

*Pattern:* a progress / status widget rendered as a 50%-screen-height card on top of the assistant's actual question, which was the action the user needed to take. The progress *anchor* was louder than the *call to action*.

**Fix:** primary action gets primary visual weight. Status indicators are secondary or tertiary. When in doubt, demote the chrome.

### 5. Residue / cruft
Overlay elements (close buttons, "skip" affordances, badges) covering interactive controls.

*Pattern:* a universal X dismiss button positioned at `top: 6, right: 6` over every active widget — it overlapped the rightmost chip in a suggested-replies widget and the `+` stepper in a tree-picker widget. Made the widget partially unusable.

**Fix:** if a chrome element collides with content, the content wins — push the chrome out of the way or remove it. Most widgets have a built-in resolution path; a universal X is redundant.

---

## Benchmark anchors

Stop saying "premium" and "S-tier" without naming what you mean. Use these.

### Tier 1 — North Star (chrome must reach this bar)

| Reference | What to steal |
|---|---|
| **Apple Music / Photos / App Store on iOS 26** | The actual Liquid Glass treatment. Floating tab bars, glass sheets, refractive surfaces, specular highlights. Native UIKit chrome. |
| **Apple Settings + Wallet on iOS 26** | List rows, hairline dividers, tap targets, semantic color discipline. The reference for settings + list-style content + workouts list. |
| **Telegram on iOS 26** | Density without crowding, restrained accent color, perfect chrome adoption, gesture-rich navigation. Bar to match for chat surfaces, settings, and sheets. |

If our chrome can sit next to one of these on the same Home Screen and not embarrass itself, it's S-tier. Otherwise it isn't, regardless of how nice we think it looks. See your project's `design-north-star` rule for the chrome-by-chrome mapping.

### Tier 2 — Domain-specific references (still required for their domain)

| Reference | What to steal |
|---|---|
| **WHOOP onboarding** | Rhythm — confident progressions, motion that proves work is happening. The reference for any onboarding / first-touch flow. |
| **Linear** | Text hierarchy. Density without crowding. Command palette as primary input. The reference for keyboard-driven power-tools. |
| **Raycast** | Input-first. Keyboard-driven. Never blocks the user. Empty states that *teach*. |
| **Things 3** | Empty states that don't apologize. Onboarding that feels like product. |
| **Apple's Quick Look + native demos** | The bar for fluidity. If the app feels slower or jankier than Apple's own demo, it's below the bar. |

When grading a screen, name BOTH a Tier 1 reference (chrome) and a Tier 2 reference (domain), and say what we're missing relative to each. *"This empty state's chrome is at Apple Settings parity but the copy is below Things 3 — Things teaches; ours apologizes."*

---

## Fast vs careful — decision rule

Two modes. Pick consciously.

### Fast (one-shot edit, no plan-mode, no agent delegation)

Use for:
- Typo / copy fix
- Type-only fix in a single file
- Renaming an isolated callback
- Tightening a guard (adding `?.`)
- Adjusting a single-style value (padding, color)
- Adding a missing test for code that already works

### Careful (plan-mode, agent delegation, screenshot-before-done)

Use for:
- Any UI surface change
- Any cross-module refactor
- Any prompt change (assistant behavior is UI behavior)
- Any state-machine modification (scan phase, setup step, multi-screen flow)
- Any DB write that affects an existing screen's queries
- Anything a real user could see

**Default to careful when in doubt.** The cost of a careful pass on a fast task is low; the cost of a fast pass on a careful task is days of debugging.

---

## "Claim of done" preconditions (mirror the project's hard rule)

Before you write "✓ done" / "shipped" / "ready":

1. **Fresh screenshot** of the affected surface(s) on the device the user is testing on. No screenshot, no "done."
2. **Lint clean** — your lint runner returns 0 errors.
3. **Tests touched** if the change has logic, even if just the smoke test verifying the new path executes.
4. **Composition pitfalls scanned** — the five above. Even one named hit means not-done.
5. **Benchmark named** — what's our reference? What grade did we ship at? What's the next move up?

If you can't say all five truthfully, you're not done — say what's missing instead of claiming "done."

---

## When to load this skill

Auto-load when:
- The user mentions "design", "polish", "demo", "looks bad", "broken UX", "S-tier", "Apple parity"
- The work touches `app/*.tsx`, `src/*/components/`, `src/*/widgets/`, or any prompt file
- The work changes the in-app assistant's voice, tools, or active-ask flow
- A reviewer agent (`ux-reviewer`, `flow-ux-reviewer`) is invoked

Skip when:
- Pure server-side logic with no UI surface
- Tooling / test infrastructure
- Documentation-only changes (skills, READMEs, etc.) unless they describe UI behavior
