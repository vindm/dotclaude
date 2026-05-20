---
name: element-reuse-check
description: Before authoring a new UI element (string, component, modal, screen), verify whether an existing element does the job. Run this CHECK before opening any design file.
---

# Element reuse check (Gate A)

Before designing a new UI element, run this verdict matrix to decide whether to reuse, adapt, or build new.

## The matrix

For each new element you're about to author, classify it:

| Existing element shape | Verdict | Action |
|---|---|---|
| Identical use case, identical context | **REUSE** | Import the existing component / string verbatim |
| Same use case, different context | **REUSE w/ context-prop** | Extend the existing component with a `variant` or `context` prop |
| Different use case, similar shape | **NEW (rename)** | Create a new component; do NOT overload the existing |
| No matching element | **NEW** | Create from scratch |

## Why "REUSE w/ context-prop" is the right default

Most growing UI codebases have two failure modes:

1. **Over-reuse** — one component does 7 things, the prop API balloons to 20 booleans, nothing is testable, nothing is removable
2. **Under-reuse** — 5 similar buttons across 5 features, each with subtle inconsistencies, design drift sets in within a quarter

The matrix above splits the difference: extend when SHAPE matches, fork when USE CASE differs.

## Strings specifically

Strings are the highest-leverage place to apply this skill. A button labeled `"Continue"` in 5 places that means 5 different things is a UX bug — users build the wrong mental model of "Continue advances me one step" because sometimes it does, sometimes it commits, sometimes it skips. The matrix per-string catches this.

## How to actually run the check

1. Grep your existing component / string library for plausible matches (`grep -rn "Continue" src/ui/`).
2. Look at the top 3 hits. For each, classify against the matrix above.
3. Write the verdict inline in your design doc: `Considered reuse of <X>; verdict: <REUSE | REUSE w/ context-prop | NEW (rename) | NEW>; reason: <one line>`.
4. This becomes the design-time receipt; reviewers can challenge it.

## When to skip

- Throwaway prototype code that won't ship
- A11y-required labels (those MUST be context-specific — never reuse a label that misrepresents the action)
- Auto-generated UI (forms from schema, etc. — different discipline applies)

## Pairing

Run this skill BEFORE the `journey-audit` skill. Reuse decisions are upstream of flow-joining decisions — if you reuse an existing screen with its own established journey, you inherit the journey too. New screens need their journey designed; reused screens slot into the existing one.
