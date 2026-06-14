---
name: saturday-ritual
description: Run an OPTIONAL bounded weekly drift-detection cadence — batch the findings hooks can't prevent (stale skills, stale docs, dead rules) into one decision sheet the user marks fix-now / defer / need-info / won't-fix, tracked in a single canonical open-findings registry. Small, young, or solo projects skip this entirely. Use only when a long-lived project has accumulated review-worthy drift.
---

# Maintenance ritual

**This is optional.** Skip it for anything small, young, or throwaway — a short-lived project, a solo developer on a handful of files, a prototype. The maintenance overhead exceeds the value until a project is long-lived enough to accumulate real drift across its skills, docs, and rules. The default bias is to defer; only run this once drift is actually piling up (a registry filling with findings, skill docs that describe how the code worked months ago, a rules file that's been routinely overridden).

When it does apply, it catches what nothing else does. Long-lived projects drift invisibly: a skill doc cites file paths that have moved and function shapes that have changed, so it quietly produces wrong recommendations; a flow doc still describes the journey as of the last redesign, so conformance checks pass against a stale baseline; a rule says one thing while everyone routes around it with the override syntax, so the rule book is fiction. Each is harmless per session and toxic across sessions. The ritual is the detection loop that keeps the canonical sources honest.

## The four properties — ship all four or none

A ritual fails the moment it lacks any of these.

1. **Bounded time.** Pick a cadence and a time-box and hold them — a common default is thirty minutes a week, longer for high-activity projects, biweekly or monthly for quiet ones. Cadence without a time-box stretches to fill the day and gets skipped when busy; a time-box without a cadence never happens. Both, or neither.

2. **Batch decision interface.** Findings arrive as one sheet, and the user marks each with a single letter: **F** fix now (taken during the week), **D** defer to backlog, **?** need more info (investigate), **X** won't fix / accept (close with a rationale). The structured mark dictionary is what makes thirty findings feel like thirty minutes instead of three hours — reading them one at a time, each carrying its own "should I fix this?" load, is exhausting after five. Document the dictionary in the registry header so marks stay consistent week to week.

3. **Hooks first.** Edit-time guards must prevent the mechanically-catchable classes — raw values that should be tokens, forbidden phrases, oversized files — *before* they ever reach the registry. Install those first. If the ritual surfaces a stream of mechanical findings every week, it's doing hook work and the higher-order findings drown in the noise. The ritual is for what the hooks can't catch.

4. **A single canonical registry.** Open findings live in exactly one document, in the project's docs area. Not issues plus a tracker plus a chat channel — three places to look is effectively no place. Everything else is a view onto that one registry. Without it, findings duplicate, get marked F in one place and X in another, and nobody can tell what's still open.

## How to run it

Derive the project's specifics first: the cadence and time-box the user wants, the trigger (when the batch gets prepared and when they mark it), which detection mechanisms feed the registry, where the registry lives, and who takes the F-marked items during the week. Don't impose defaults the user didn't choose.

Then the loop: on the trigger, run the detection batch and write its findings into the registry; the user marks each F/D/?/X; F items get implemented during the week, one change per item; the registry reflects current state throughout. Tailor the detection set to what the project is — a UI-heavy project sweeps for token and interaction drift, a backend project for schema and access-policy drift, a library for public-API and doc drift — but skill-vs-code drift detection belongs in every flavor, since stale skills mislead silently regardless of stack.

## Registry hygiene

The registry has an open section (the table of findings with their marks), a recently-closed section, and an archive. Close a finding by moving it to the closed section with its resolution; after it has aged out of the recent window, move it to a dated archive. **Archive, never delete** — a deleted finding takes its rationale with it, and "why did we decide to skip this?" becomes unanswerable. Keep the open list scannable: a registry that never archives stops being read.

When the ritual surfaces that a rule has been overridden many times, the rule is dead. Detection is only half the job — the consequence is updating the canonical source: retire the rule, or strengthen its enforcement. A ritual that detects drift but never feeds the fix back into the project's rules and docs is just generating reading material.
