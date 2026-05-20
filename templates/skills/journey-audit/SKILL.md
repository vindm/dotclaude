---
name: journey-audit
description: Build a prior-surface map before designing a new screen or flow. Mandatory pre-design step for any UI work that joins existing flows.
---

# Journey audit

Before designing a new screen, you must know what comes before it and what comes after. The journey audit produces that map.

## The map

For each prior surface that can navigate to the new screen:
- **Surface name + path**
- **What it promises** (CTA label, hero copy, expected outcome)
- **What state user has at entry** (logged in? completed setup? holding cart?)
- **Returning vs first-time** distinction if applicable

For each downstream surface the new screen navigates to:
- **Transition trigger** (button click, form submit, automatic redirect)
- **State delta** (what new state the user has post-transition)

## Output format

A markdown file at `docs/journeys/<screen-name>-journey.md` with the map above plus a 2-3 sentence summary of the joining requirements.

## When to skip

- Single-screen utility (e.g., a standalone error page with no prior context)
- Hotfix to existing screen with no IA change

## When to expand

- New flow joining 3+ surfaces → also build a state-transition diagram
- New flow crossing tenant / role boundaries → audit per role
