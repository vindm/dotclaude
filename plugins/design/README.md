# dotclaude-design — the AI design/UX auditor nobody else has

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude-design@dotclaude
```

## Start here: tell it what "good" means

Before any audit is worth running, run `/dotclaude:design` once. It reads your stack, your existing screens, and the design-flavored commits in your git history, then interviews you: which apps set your visual bar (a platform-chrome reference plus a domain reference), your voice and banned phrases, whether your surfaces form multi-screen arcs or a multi-section dashboard. The output is a north-star doc — your named benchmarks, not "make it look nice" — that the taste audits below read and grade every screen against.

Skip this step and the taste audits still run, but they fall back to general platform-native conventions and say so explicitly in every report. Useful, but generic — the north-star is what turns "S-tier" from a vibe into something two people can agree on.

## The audits

Three grade only what's in front of them — no north-star needed:

- **`a11y-audit`** — assistive-tech labels, hit-target size, contrast computed from your actual token values (not estimated from a screenshot), text scaling, reduced-motion. A missing label blocks ship regardless of visual grade.
- **`interaction-audit`** — a per-element table of what the chrome *promises* versus what the handler *does*. Catches dead chrome, redundant affordances, and optical-group disconnects invisible to both code review and visual review.
- **`design-token-audit`** — a cheap, periodic regex sweep for raw color literals bypassing your design system, classified by severity with the nearest semantic token proposed.

Four grade against your north-star, and say so if you skipped the setup:

- **`ux-audit`** — single-screen visual polish, graded against your named chrome and domain references, plus a highest-ROI fix.
- **`flow-audit`** — whole-arc continuity, in two modes: walk a live flow end-to-end and grade eight gap classes single-screen review structurally misses, or grade a pre-captured screenshot series across six continuity dimensions (voice drift, CTA-weight progression, color drift, and more).
- **`pages-audit`** — cross-section consistency: does your dashboard or tab bar feel like one app, or like several built independently.

And one design partner, not an audit:

- **`product-designer`** — senior-IC information-architecture and user-flow work for new features and redesigns. Produces a spec — IA, flow, per-screen state inventory, considered-and-rejected alternatives — the spec is the deliverable, not a mockup.

---

Part of the [dotclaude](../../README.md) marketplace. Companion plugin: [dotclaude](../core/README.md), the coding/testing/pre-flight base.
