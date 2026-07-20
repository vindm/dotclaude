# quality-rubric — designing the S/A/B/C/D/F operational rubric for ANY project

Teaching material for Claude Code. Teaches you how to design a project-specific quality rubric — the operational definition of "done" that the user actually applies before claiming work is shipped. A rubric is not a code-review checklist; it's a **shipping-decision scaffold** that runs at the point where someone is about to declare work done.

## When to ship one

Ship a quality-rubric skill when the project has a **quality bar to hold** — the user says "S-tier," "Apple-parity," "production-grade," "demo-ready" — or is customer-facing, or has had to send work back for re-do (quality drift is a real cost being paid).

Skip when the user's posture is explicitly "just ship it" (a rubric on a velocity-first culture breeds resentment without lift), when "works correctly" is the only relevant bar (internal tooling), or when the project is so early that "anything visible" is the success criterion.

## Why it matters

The rubric closes three failure modes:

- **"Good enough" drift** — without a named tier, "done" is a feeling, and six months of drift makes yesterday's "good" today's "ship it." Concrete reference anchors arrest it.
- **Argument resolution** — when two contributors disagree on whether a screen is done, the rubric is the third party: *"compare to the reference for each tier"* beats relitigating taste.
- **What-to-fix-first** — pairing grade-of-current-state with the single highest-ROI move to lift one tier is more actionable than "needs polish," because it names the move.

## Core methodology — the rubric's five components

Each is project-specific in detail; the shape is universal.

### 1 — The single demo test

One question, asked of every change, that short-circuits debate — and it must name a real audience the user actually faces:

- *"Would I demo this to the customer I'm trying to win next?"*
- *"Would I show this to a journalist writing about us?"*
- *"Would this pass review at <the FAANG-tier company we benchmark against>?"*

Generic (*"is this good?"*) is useless. If the user can't name an audience, the rubric isn't ready to author.

### 2 — The five-tier grade scale

S / A / B / C / D / F (or 1-5, or P0-P3 — the structure is what matters: top tier reserved for indistinguishable-from-reference, bottom for don't-ship). Fill each row with a project-specific reference:

| Tier | Means | Reference |
|---|---|---|
| **S** | Indistinguishable from the user's named top benchmark. Demo-ready to the demo-test audience. | <top benchmark> |
| **A** | Clearly intentional, no rough edges, doesn't embarrass next to a top-tier app. Minor polish gaps. | <domain references> |
| **B** | Functional, looks designed, 1-2 visible cracks a reviewer spots within 30 seconds. | <"decent SaaS" references> |
| **C** | Looks rushed. Inconsistent, residue elements, lazy edge cases. | (no positive reference) |
| **D** | Broken or embarrassing. Black screens, dead ends, untranslated copy in prod. | Don't ship. |
| **F** | Active harm. Wrong data, security holes, breaks an existing workflow. | Block merge. |

For every PR-sized change, name the tier it's at and the **single highest-ROI move to push up one tier**.

### 3 — Named composition pitfalls

The most useful project-specific part: recurring mistake classes, named so reviewers can call them. The universal categories (project-specific names and examples derive from the user's own work):

- **Duplication** — two elements communicating the same fact (two progress indicators showing the same percent).
- **Orphan elements** — a control with no clear job; residue from a prior state; a default-rendered widget no one designed.
- **Tone mismatch** — an element's voice doesn't match the situation (cheerful copy on an error state).
- **Hierarchy violations** — visual weight not aligned to importance (chrome louder than the CTA).
- **Residue / cruft** — overlay chrome covering interactive content; debug labels in prod.

Extract THIS project's named pitfalls from its recent UX reviews, the user's interview, or the last few "this looks rushed" commits — don't copy the categories above verbatim.

### 4 — Benchmark anchors (Tier 1 / Tier 2)

The rubric is empty unless it names specific reference apps. Two layers:

**Tier 1 — chrome / platform reference:** what's "S-tier" on the platform you ship to? (iOS → Apple's native chrome + Telegram; Web → Linear, Stripe, Vercel; B2B SaaS → Notion, Linear, Figma; CLI → Raycast, Things 3; dev tool → GitHub CLI, Lazygit.)

**Tier 2 — domain reference:** the bar for the *specific* surface type. (Onboarding → WHOOP, Things 3 first-run; Dashboard → Linear inbox, Superhuman; Settings → Apple Settings, Telegram; Wizard → Stripe checkout, TurboTax.)

When grading, name BOTH and say what's missing relative to each: *"Chrome at Apple-Settings parity; copy below Things 3 — Things teaches, ours apologizes."* "Premium" without named references is unactionable.

### 5 — Fast vs careful decision rule

Not every change deserves the full rubric. **Fast** (no rubric pass): typos, single-style nudges, type-only fixes, an isolated rename, adding a missing test. **Careful** (full rubric): UI surface changes, cross-module refactors, copy / voice changes, state-machine edits, anything customer-facing. When in doubt, default to careful — running the rubric on a fast task is cheap; skipping it on a careful one ships a regression.

## Claim-of-done preconditions — the canonical 5-item checklist

The rubric's binding gate. **Five items minimum, every UI surface, every claim of "shipped" / "done":**

1. **Fresh screenshot of every affected surface.** "Compiles" / "tests pass" / "I read the code" are NOT substitutes — the screenshot is the visual contract. Exception: pure copy-string diffs (the diff IS the artifact). If capture is impossible for non-string work, say so and ask the user to verify.
2. **Lint passes, 0 errors.** The lint config is the project's contract on what the code looks like; if the change can't pass it, it isn't done.
3. **Tests green** (the project's primary command — `npm test` / `pytest` / `cargo test` / etc.). Failures block the claim.
4. **5-pitfall composition scan complete** — duplication / orphan / tone-mismatch / hierarchy / residue, verdict per pitfall (found / clean) on every affected screen. Without the explicit scan, the claim is "I think it looks fine."
5. **Tier 1 + Tier 2 benchmark named** for every graded surface. *"Sits next to Linear's project view"* is what claim-of-done sounds like; "looks good" is not.

Any item unchecked → the claim is "in progress," not "done."

The rubric is best shipped as a skill (auto-loaded on UI work) rather than a passive rule, so the assessment is built into the proposal. Auto-load when the change touches user-facing screens, the user mentions design / polish / demo / S-tier / parity, a visual audit agent is invoked, or a flow-spanning change is in scope. Skip for backend-only, type-only, and doc-only work.

## How to derive THIS project's specifics

1. **The user's named benchmarks** — ask directly: *"when you say 'S-tier,' which specific apps?"* Get app names, not categories.
2. **Past quality feedback** — `git log --grep="polish\|cleanup\|fix.*layout\|broken.*UX"` surfaces the bug classes to name as pitfalls.
3. **The demo-test audience** — a specific customer, a friend whose taste they trust, a named persona.
4. **The surface inventory** — onboarding? dashboard? settings? Each may want its own domain reference.
5. **The platform** — iOS / Android / web / desktop / CLI. Tier 1 references derive from it.
6. **The user's known anti-patterns** — every *"I always forget to…"* is a candidate for the named-pitfall list.

## Acceptance — what the authored rubric must have

- **Every tier row names a real reference.** "S = excellent" is vibes; "S = indistinguishable from <specific app>" is enforceable.
- **Pitfalls extracted from THIS project's history**, not copied from the categories above (those are teaching material).
- **A demo test with a nameable audience** — "would I be proud of this?" is unstable; "would I demo this to <specific person>?" is concrete.
- **A fast-vs-careful split**, so the rubric isn't friction on every change and users don't start ignoring it.
- **A "next move up one tier" for each grade** — "B" alone triggers debate; "B; highest-ROI move to A is fix the empty-state copy" is actionable.
- **Dated, periodically-reviewed anchors** — "iOS 17 chrome" was right once; the reference moves with the platform.
- **Grade target that varies by surface** — a rarely-touched admin tool is correctly at B; don't demand S of every screen.

## Cross-references

- `audit-routing.md` — when multiple audit agents apply, this rubric's grades cross-translate to theirs.
- `operating-principles.md` — principle 3's "verify" and this checklist's claim-of-done gate are the same discipline at two altitudes.
