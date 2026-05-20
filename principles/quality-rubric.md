# quality-rubric — designing the S/A/B/C/D/F operational rubric for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to design a project-specific quality rubric — the operational definition of "done" — that the user actually applies before claiming work is shipped.

## When to ship one (applicability gate)

Ship a quality-rubric skill when:

- The project has a **quality bar to hold**. The user has used phrases like "S-tier," "Apple-parity," "production-grade," "demo-ready," etc.
- The project is customer-facing (members, end-users, paying customers see the output).
- The user has had to send work back for re-do — quality drift is a real cost being paid.

Skip when:

- The user's posture is explicitly "just ship it" with no quality bar held. Forcing a rubric on a velocity-first culture produces resentment without lift.
- The project is internal tooling where "works correctly" is the only relevant bar.
- The project is so early that "anything visible" is the success criterion — premature rubrics are noise.

## Why it matters — what this catches that nothing else does

The rubric solves three failure modes:

1. **"Good enough" drift.** Without a named tier, "done" becomes a feeling. Six months in, the team's calibration has drifted and yesterday's "good" is today's "ship it." A rubric with concrete reference anchors arrests the drift.

2. **Argument resolution.** When two contributors disagree on whether a screen is done, the rubric is the third party. "You think A; I think B; let's compare to the reference for each tier" is faster than relitigating taste.

3. **What-to-fix-first.** The rubric pairs grade-of-current-state with the single highest-ROI move to lift one tier. This is more useful than "needs polish" because it names the move.

A rubric is NOT a code review checklist; it's a **shipping decision** scaffold. It runs at the point in the loop where someone is about to declare work done.

## Core methodology — the rubric's five components

A useful rubric has five elements. Each is project-specific in its detail; the shape is universal.

### Component 1 — The single demo test

One question, asked of every change, that short-circuits debate. Example shapes:

- "Would I demo this to the customer I'm trying to win next?"
- "Would I show this to a journalist writing about us?"
- "Would I expect this to pass code review at <FAANG-tier company we benchmark against>?"
- "Would my technical co-founder approve this?"

The test must be specific to a real audience the user actually faces. Generic ("is this good?") is useless. The audience must be someone the user could name. If the user can't name an audience, the rubric isn't ready to be authored.

### Component 2 — The five-tier grade scale

S / A / B / C / D / F (or whatever the user prefers — some teams use 1-5 or P0-P3). The structure is what matters: top tier reserved for indistinguishable-from-reference, bottom tier reserved for don't-ship.

Universal anchor template (fill with project-specific references):

| Tier | Means | Reference |
|---|---|---|
| **S** | Indistinguishable from the user's named top-tier benchmark. Demo-ready to the demo-test audience. | <project's actual top benchmark> |
| **A** | Clearly intentional, no rough edges, doesn't embarrass next to a top-tier app. Minor polish gaps. | <project's domain references> |
| **B** | Functional, looks designed, but has 1-2 visible cracks. Reviewer can point them out within 30 seconds of looking. | <project's "decent SaaS" references> |
| **C** | Looks rushed. Inconsistent, residue elements, lazy edge cases. | (no positive reference — this is "what we don't want to ship") |
| **D** | Broken or embarrassing. Black screens, dead ends, untranslated copy in prod. | Don't ship. |
| **F** | Will cause active harm. Wrong data, security holes, breaks the user's existing workflow. | Block merge. |

For every PR-sized change, the user names: tier currently at, and the **single highest-ROI move to push up one tier**.

### Component 3 — Named composition pitfalls

The most useful part of a project-specific rubric. Each pitfall is a class of mistake that recurs in this project's domain, named so reviewers can spot and call it.

Universal pitfall categories (project-specific names and examples derive from the user's work):

- **Duplication.** Two or more elements communicating the same fact. Three things saying the user's name; two progress indicators showing the same percent.
- **Orphan elements.** A control with no clear job. Residue from a prior state. Default-rendered widget no one designed.
- **Tone mismatch.** Element's voice doesn't match the user's situation. Placeholder asking when the situation requires answering. Cheerful copy on an error state.
- **Hierarchy violations.** Visual weight doesn't match importance. Chrome louder than CTA. Status indicator competing with the primary action.
- **Residue / cruft.** Overlay chrome covering interactive content. Universal-X dismiss button blocking the right edge of every widget. Debug labels in prod.

THIS project's named pitfalls come from the user's actual work — extract them by reading the recent UX reviews, by interviewing the user, or by reviewing the last few "this looks rushed" commits.

### Component 4 — Benchmark anchors (Tier 1 / Tier 2)

The rubric is empty unless it names specific reference apps the user grades against. Two layers:

**Tier 1 — chrome / platform reference.** What is "S-tier" on the platform the user ships to? Examples:
- iOS app → Apple's iOS 26 native chrome (Music, Settings, Photos, Wallet) + Telegram on iOS 26.
- Android app → Material Design 3 reference apps (Google Calendar, YouTube Music) + Telegram.
- Web app → Linear, Stripe, Vercel, Superhuman.
- B2B SaaS → Notion, Linear, Figma.
- CLI tool → Raycast, Things 3 (the bar for first-run quality).
- Developer tool → GitHub CLI, gh-dash, Lazygit.

Whatever the project's platform / domain, NAME the Tier 1 references explicitly. "Premium" without naming references is unactionable.

**Tier 2 — domain reference.** What's the bar for the SPECIFIC type of surface this project is building? Examples:
- Onboarding flow → WHOOP onboarding, Things 3 first-run.
- Dashboard → Linear inbox, Superhuman triage.
- Empty states → Things 3, Raycast.
- Settings → Apple Settings, Telegram settings.
- Workflow / wizard → Stripe checkout, TurboTax.

When grading a screen, name BOTH a Tier 1 (chrome) and Tier 2 (domain) reference, and say what we're missing relative to each. *"Chrome at Apple-Settings parity; copy below Things 3 — Things teaches; ours apologizes."*

### Component 5 — Fast vs careful decision rule

Not every change deserves the full rubric. A typo fix doesn't need a five-step quality scan. The rubric should encode the fast / careful split:

**Fast** (no rubric pass needed): typos, single-style nudges, type-only fixes, isolated callback rename, adding a missing test.

**Careful** (full rubric applies): UI surface changes, cross-module refactors, copy or voice changes, state-machine modifications, anything customer-facing.

When in doubt, default to careful. The cost of running the rubric on a fast task is low; the cost of skipping it on a careful task is shipping a regression.

## How to derive THIS project's specifics

Before authoring the rubric, gather:

1. **The user's named benchmarks.** Ask directly: *"When you say 'S-tier', which specific apps are you grading against?"* Get specific app names, not categories.

2. **Past quality-related feedback.** Look at `git log --grep="polish\|cleanup\|fix.*layout\|broken.*UX"` for the bug classes the user has fixed. Each repeated pattern is a candidate pitfall to name.

3. **The user's audience for the demo test.** Who would they show this to? A specific customer? A friend whose opinion they trust? A specific persona? Get a name or a role specific enough that the user could imagine showing them the screen.

4. **The project's surface inventory.** What does it have? Onboarding? Dashboard? Settings? Each surface category may benefit from a domain reference; collect those.

5. **The project's platform.** iOS / Android / web / desktop / CLI / something else. Tier 1 references derive from this.

6. **The user's known anti-patterns.** Phrases like "I always forget to" — every one of those is a candidate for the named-pitfall list. Listen for them.

## Authoring the rubric

The final rubric (typically `.claude/skills/quality-bar/SKILL.md` or `.claude/rules/quality-rubric.md`) should contain:

1. **The demo test** — one question, specific audience.
2. **The five-tier scale** — with project-specific references in each row.
3. **Five named composition pitfalls** — each with a one-line example from THIS project's history.
4. **Benchmark anchors** — Tier 1 and Tier 2 tables, populated with specific app names.
5. **Fast vs careful rule** — concrete examples for each mode from the project's actual work shapes.
6. **"Claim of done" preconditions** — the checklist the user / Claude runs before writing "shipped" / "done" / "ready." This typically includes: capture / lint / test / pitfall-scan / benchmark-named.

The rubric is best as a skill (auto-loaded on UI work) rather than a rule (passive). When Claude proposes UI work, the rubric should be active so the assessment is built into the proposal.

## When to auto-load the rubric

The skill's frontmatter (or the project's CLAUDE.md routing) should auto-load the rubric when:

- The change touches user-facing screens (frontend files).
- The user mentions design / polish / demo / S-tier / parity / broken-UX.
- A visual audit agent (ux-reviewer, etc.) is being invoked.
- A flow-spanning change is in scope.

Skip auto-loading for:

- Backend-only / internal-tooling work.
- Type-only / lint-only / tooling-only changes.
- Documentation-only changes (unless they describe UI behavior).

## Cross-references

- `design-benchmarking.md` — the "name your benchmarks" principle. The rubric's Tier 1/Tier 2 tables are an instance of that broader discipline.
- `audit-routing.md` — when multiple audit agents apply, the rubric's grades cross-translate to those agents' rubrics.
- `ux-audit.md` / `flow-audit.md` / `interaction-audit.md` — these agents grade against the rubric; the rubric is their reference.
- `forbidden-phrases.md` — voice / tone discipline. The rubric's "tone mismatch" pitfall is enforced upstream by the phrase-deny list.
- `visual-verification.md` — capture is a precondition to applying the rubric; you can't grade what you haven't seen.

## Anti-patterns in the rubric you write

- **Tier descriptions without named references.** "S = excellent" is vibes. "S = indistinguishable from <specific app>" is enforceable. Every tier row needs a real reference.

- **Pitfalls copied from this principle doc.** The list of pitfalls here (duplication / orphan / tone-mismatch / hierarchy / residue) is teaching material. The project's pitfalls are the ones the user actually exhibits — extract from the project's history, don't copy from here.

- **A demo test with a generic audience.** "Would I be proud of this?" — pride is unstable. "Would I demo this to <specific person whose taste I respect>?" — concrete.

- **No fast vs careful split.** Without it, the rubric becomes friction on every change, including the ones it shouldn't apply to. Users start ignoring it. Encode the split explicitly.

- **No "next move up one tier" guidance.** A grade alone says "B." A grade plus the move says "B; the highest-ROI move to A is fix the empty state's copy." The second form is actionable; the first triggers debate.

- **Anchors that drift with platform updates.** "Apple iOS 17 chrome" was the right reference once; iOS 26 is the right reference now. The rubric should be dated and reviewed periodically.

- **Setting the bar at the top tier for every change.** Not every change is S-tier worth. Some surfaces are correctly at B (they're rarely-touched admin tools). The rubric should accept that grade-targeted varies by surface, and not demand S of every screen.
