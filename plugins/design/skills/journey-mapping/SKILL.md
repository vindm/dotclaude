---
name: journey-mapping
description: Build the prior-surface inventory before designing OR auditing any screen — walk every surface the user touched before reaching this one, classify each by type, and apply the forbidden-pattern matrix so first-touch copy/voice/chrome never leaks onto a daily-driver surface. Load before any new design spec or any single-screen / flow audit.
---

# Journey mapping

Before you design a new surface or audit an existing one, you must know where the user came from. Screens designed in isolation leak copy, voice, and chrome appropriate to one surface type onto another — and the bug is invisible to per-screen review. The canonical shape: the onboarding flow greets the user with "Hi — I'm your assistant, let me show you around" (correct); weeks later a daily home banner reuses that same greeting (wrong — the user has known the assistant for weeks; re-introducing is condescending). The screen reads fine alone; only the *journey* exposes the failure.

Run this at **both** moments and the verdict is binding at both:
- **Design time** — Section 0 of any spec, before proposing a surface.
- **Audit time** — first action before grading any captured surface, before any per-screen verdict. Rerunning against the *implemented* surface catches the case where implementation drifted from spec (the spec's intended surface-type classification no longer matches what shipped).

Other failures it catches that per-screen review cannot: a "Get started" call-to-action on a daily-driver, re-introducing a concept the user reached *after* using it, apology copy on a success state, tone hopping mid-flow (intimate second-person step 3 → corporate third-person step 4), and a hard cut between two arcs with no transition surface.

## Procedure

### Step 1 — Enumerate prior surfaces

Starting from the user's **first interaction with the product** (sign-up, sign-in, app open), walk forward through every surface up to the target. First discover where surfaces live in *this* project — glob for screen/route/page files, for flow-defining files (wizard/onboarding modules), and for copy/translation/narration sources. Read each well enough to know: what does the user SEE here, what does the system or assistant SAY, what's the tone. Do not hardcode paths — derive them from this codebase's layout.

If you can't enumerate the prior surfaces because you don't know the codebase well enough, **STOP and read more**. A partial map is worse than none — proceed only with a complete walk.

### Step 2 — Classify each surface

Every surface gets exactly one type. The taxonomy is universal; the examples come from this project's actual surfaces:

| Type | Definition |
|---|---|
| **first-touch** | User hasn't met this assistant or concept yet. Introductions are appropriate. |
| **daily-driver** | User opens this regularly; knows the assistant and product. Greetings/introductions are wrong. |
| **settings** | Infrequent configuration surface. Assumes product knowledge. |
| **error** | Recovery surface — the user is in a flow that hit a problem. |
| **promotional** | One-shot announcement / celebration / nudge. |
| **bridge** | Transition surface between two arcs (flow completed → first daily surface). |

No "kind of both" answers — surfaces have one type. If genuinely ambiguous, force a decision and write down the rationale; both-and classifications defeat the matrix below. Not every project has all six categories; enumerate only the ones that exist.

### Step 3 — Build the journey map

A linear table, one row per surface, ending with the target:

| Order | Surface | Type | Key copy / components the user sees |
|---|---|---|---|

Two rules: **fill every row** (no stubs, no "…and so on"), and use **verbatim copy only** — paraphrasing hides cross-surface duplication, which is the entire point of the map.

### Step 4 — Apply the forbidden-pattern matrix

Once the target's type is fixed, certain patterns are categorically disallowed for that type:

| Target type | Forbidden patterns |
|---|---|
| **first-touch** | None — this IS the introduction surface. |
| **daily-driver** | Greetings, introductions, "welcome", "let me show you", "let's get started", plus any phrase on this project's deny-list. |
| **settings** | Daily-driver forbidden set + re-introducing concepts the user has already configured. |
| **error** | Apologies — "sorry", "oops", "I'm here to help". State the situation; offer one path forward. |
| **promotional** | Re-introducing concepts. A celebration is not a re-greeting. |
| **bridge** | Hard-cutting into the next arc without acknowledging the transition. |

The project's deny-list (read it at runtime if one exists) supplies the daily-driver phrase set. A target exhibiting a forbidden pattern is a **critical gap** for audits and a **rewrite-required** mark for designs — no softening. The pattern is wrong for the type, and the type is fixed.

### Step 5 — Cross-surface duplication check

Grep the target's copy against the rest of the codebase:

```
grep -rn "<exact-string-from-target>" <surface-dirs>
```

If the same string already appears on a surface of a *different* type, that's a problem — the user has seen it, and repeating it across types is repetition, not communication.

## Output and non-negotiables

Emit the map as Section 0 of the design/audit doc, or as an inline preamble before the gap table. The map is mandatory — never skip it "because the surface is simple"; that is exactly the failure this procedure prevents. Verbatim copy only. Classification is binding. If you can't complete the map, stop and read more rather than proceed on a partial one. The map's value is in being consulted by the rest of the design or audit — not in existing.
