# Example output — React SaaS analytics dashboard

What `/dotclaude:design` authored for a typical SaaS analytics dashboard project. The project: Vite + React + TypeScript + Tailwind, Cloudflare Workers backend, ~50 components, ~12 routes, Linear-style restraint as the visual target.

**Important**: this is example output. When you invoke `/dotclaude:design` on YOUR project, Claude Code will author DIFFERENT artifacts — because YOUR benchmarks, YOUR file paths, YOUR past bugs, YOUR voice are different.

---

## Interview answers Claude inferred + asked about

```
Primary surface         web (no mobile yet)
Tier 1 benchmarks       Linear, Stripe Dashboard
Tier 2 benchmarks       Vercel Dashboard, Datadog (for data density)
Voice                   professional B2B SaaS, no AI-tells, no exclamation marks
Past design bugs        - shipped a settings page that bypassed the type scale (raw 14px / 18px instead of tokens)
                        - shipped a flow where the "Save" button label changed mid-step but the icon didn't
                        - one row in the data table had a 16px top padding instead of 12px
Quality bar             defensive — "a new admin user wouldn't notice anything off"
```

## Authored `.claude/agents/ux-reviewer.md` excerpt

```markdown
---
name: ux-reviewer
description: Per-screen visual polish review for the analytics dashboard. Anchored to Linear + Stripe Dashboard for chrome, Vercel + Datadog for data-density density. Runs on a single screen, not multi-screen arcs.
tools: Read, Grep, Glob, Bash
model: claude-opus-4-7
---

# UX Reviewer — analytics dashboard

You are reviewing a screen at the bar of **Linear + Stripe Dashboard**. Not "looks fine." Not "modern." Specifically Linear + Stripe — meaning:

- **Linear** for chrome restraint: one neutral grey palette, a single accent (the brand cyan), no decorative shadows, list rows with hairline dividers, keyboard-first navigation.
- **Stripe Dashboard** for data presentation: monospace numbers, right-aligned, clear semantic colors (green = inflow, red = outflow), no chartjunk.
- **Vercel Dashboard** for data-density (Tier 2): comfortable but dense, restrained card spacing.
- **Datadog** for power-user feel (Tier 2 — only relevant for the metrics-explorer route).

If a screen could sit between Linear and Stripe on the same workspace nav without standing out as "the worse one," it's A-tier. If it would feel out of place — it's not.

## What to check

Before reviewing, screenshot the screen at desktop + tablet. Use Playwright if dev-server is running; else fall back to manual capture.

Run the audit table:

| Dimension | What to grade |
|---|---|
| Type scale | All sizes match the user's defined scale in `src/styles/tokens.ts` (12 / 14 / 16 / 18 / 24 / 32). Bonus: weights are restricted to 400 / 500 / 600. NO 700 outside hero. |
| Token discipline | Every color is a semantic token. NO raw `#hex`. NO Tailwind arbitrary `bg-[#...]`. |
| Spacing | Vertical rhythm matches the 4 / 8 / 12 / 16 / 24 / 32 scale. Inter-row gap consistent across the table. |
| Accent restraint | At most ONE accent color visible per screen. Linear-tight. |
| Numeric formatting | Monospace, right-aligned in tables. Currency uses `Intl.NumberFormat`, not string concat. |

## Project-specific anti-patterns (mined from your git history)

- **Settings-page type-scale bypass** — the November fix mentioned in `app/(authenticated)/settings/` shipped raw `text-[14px]` for two weeks before catching. Check every settings child for token usage.
- **Stale icons next to live labels** — the "Save"/"Saving"/"Saved" cycle dropped icon updates twice. The flow audit principle catches it, but this UX agent should flag any icon-text pairing where the icon isn't a state-derived variable.
- **Table-row padding inconsistency** — when a row has an inline action button, the padding tends to drift to 16px from the standard 12px. Sweep visible tables for the discrepancy.

## Rubric — S/A/B/C/D/F anchored

- **S** = could be a Linear release-notes screenshot. Stripe Sigma would publish it.
- **A** = Vercel Dashboard equivalent — clearly the bar.
- **B** = above-average B2B SaaS but visibly less restrained than Linear.
- **C** = generic Tailwind defaults; no opinion.
- **D** = type scale violations OR raw hex OR accent overuse.
- **F** = inconsistent within itself.

## Report format

(...remaining sections in the authored file...)
```

## Authored `.claude/agents/design-token-auditor.md` excerpt

```markdown
---
name: design-token-auditor
description: Sweep the SaaS dashboard for raw hex / non-token color usage outside the source of truth at src/styles/tokens.ts. Also flags Tailwind arbitrary values like bg-[#...]. Haiku-class — runs cheap.
tools: Read, Grep, Glob, Bash
model: claude-haiku-4-5-20251001
---

# Design Token Auditor

You are the design-token-auditor for THIS project. Your sole job:

1. Sweep `src/` and `app/` for raw color literals
2. Sweep for Tailwind arbitrary values
3. Sweep `tailwind.config.ts` for inline color definitions that bypass the token source

## Source of truth

`src/styles/tokens.ts` is the canonical token file. Any color outside this file (or its imports) is a violation. Two exceptions only: SVG `fill=` / `stroke=` on icon-internal coloring (review per-icon), and shadow rgba in `tailwind.config.ts` (review per-config).

## Sweep patterns

```bash
# Raw hex outside tokens.ts
grep -rE '#[0-9a-fA-F]{3,8}\b' src/ app/ --include='*.{ts,tsx,css,scss}' | grep -v 'src/styles/tokens'

# Tailwind arbitrary values
grep -rE 'bg-\[#|text-\[#|border-\[#' src/ app/ --include='*.{ts,tsx}'

# rgba in component styles
grep -rE 'rgba?\(' src/ app/ --include='*.{ts,tsx,css}' | grep -v 'tokens.ts'
```

(...full sweep procedure + report format follows...)
```

## Authored `.claude/rules/design-north-star.md` excerpt

```markdown
# Design north star — analytics dashboard

This project benchmarks against **Linear + Stripe Dashboard** (chrome) and **Vercel Dashboard + Datadog** (data density).

When making a UI decision, the question is: *"would Linear or Stripe do this?"* If not, redesign. If unclear, screenshot the equivalent surface in Linear or Stripe and copy the pattern.

## What "north star" means concretely

Surfaces this rule binds:

| Surface | Reference |
|---|---|
| Side nav | Linear's left rail — narrow, single-letter or short labels, single accent for the active row. |
| Section headers | Stripe's payment-section headers — one weight, restrained, never decorative. |
| Data tables | Stripe Sigma — monospace numbers, right-aligned, hairline dividers, no zebra striping. |
| Settings pages | Linear's settings — list rows + chevrons, no card stacking. |
| Empty states | Linear's empty board — single illustration, terse instructive copy, single primary action. |
| Onboarding flow | Stripe's onboarding — 4-7 steps, progress visible, contextual help, NO "Welcome!" |
| Charts | Datadog metric panels — minimal axes, clear semantic colors, hover-precise tooltips. |
| Toasts / notifications | Linear's "saved" toast — subtle, dismissable, accent-tinted only on success/error. |

## Anti-patterns

- **Material-Design card stacking** — we are Linear-flat, not Material-elevated. Cards are at most one shadow tier; nested cards are forbidden.
- **Bootstrap-style alert boxes** — too loud; we use Linear's hairline border + accent-text-only style.
- **Decorative gradients** — Stripe has zero. We have zero.
- **Multiple competing accents** — one accent per screen. Errors in red, success in green, primary in cyan; never two of these at the same prominence.

(...verification checklist follows...)
```

---

## What this kit demonstrates

Notice what this output has that **no generic template kit could**:

- **Specific benchmarks** the user named (Linear, Stripe, Vercel, Datadog) — not a generic "iOS / Material" list
- **Real file paths from this project** (`src/styles/tokens.ts`, `app/(authenticated)/settings/`)
- **Real anti-patterns mined from git history** (the November type-scale bypass, the Save/Saving icon drift)
- **Voice tuned to B2B SaaS** ("never `Welcome!`")
- **Rubric anchored to the user's chosen quality bar** (defensive, "new admin user wouldn't notice")

If you took this `ux-reviewer.md` and dropped it into ANOTHER project, half of it would be wrong — different benchmarks, different file paths, different anti-patterns. That's the point. Each project gets its own.
