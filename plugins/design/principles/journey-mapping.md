# journey-mapping — designing the prior-surface inventory before any new design

Teaching material for Claude Code. Teaches you how to author a journey-mapping skill for projects with multi-step user flows. It's the precondition every other design / audit agent depends on: before designing a screen or grading a flow, *know where the user came from.*

## DUAL LOAD — runs at BOTH design time AND audit time

This skill is dual-loaded: it fires inside `product-designer` (design time, Section 0 of every spec) AND inside `ux-audit` / `interaction-audit` / `flow-audit` (audit time, before grading any captured surface). The dual-load is **structural drift prevention** — a spec passing journey-audit at design time tells you the *intended* classification; rerunning at audit time against the *implemented* surface catches impl drifting from spec. Without it, an audit grades against the implementation's de-facto surface type, which may not match the spec's de-jure one, and the bug hides in plain sight. Designers load it as Section 0 of the spec; reviewers load it as the first action before any per-screen verdict. Frontmatter `paths:` handles auto-load on file edits; explicit invocation in the dispatch flow handles the audit-time rerun.

## When to ship one

Ship a journey-mapping skill when the project has multi-step user flows (onboarding, checkout, wizard), an assistant / persona with a voice and an introduction moment, a history of "the welcome message appeared on the daily home" bugs, or multiple designer / reviewer agents that need a shared input. Skip when the project is a single-screen tool, all surfaces are equivalent, or the product has no voice (copy is purely functional and surface-type doesn't change tone).

## Why it matters

The failure mode: screens get designed in isolation, and copy / voice / chrome appropriate to one surface type leaks onto another. The canonical shape — the onboarding wizard's *"Hi — I'm <assistant>, let me show you around"* is correct; three weeks later a notification banner reuses it and re-introduces an assistant the user has known for weeks; the reviewer didn't catch it because the screen in isolation is fine. Only the *journey* makes it visible. Other patterns the map catches: reused copy on the wrong surface type (*"Get started"* on the daily home), re-introductions of concepts the user already used, apology copy on success states, tone-hopping mid-flow, and bridge gaps (two arcs joined with no transition surface). All invisible to per-screen review.

## Core methodology — five steps

**Step 1 — Enumerate prior surfaces.** Starting from first interaction (sign-up / sign-in / app open), walk forward through every surface up to the target. Mechanical: glob the screen / route / page files, the flow-defining files (wizard / onboarding), and the copy / translation sources; for each, read enough to know what the user SEES, what the system SAYS, and the tone. Be specific about the project's directory structure (RN: `app/wizard/`, `app/(owner)/`, `lib/persona/`; web: `src/pages/`, `src/copy/`) — encode the actual paths.

**Step 2 — Classify each surface** into exactly one type (the shape is universal; the examples derive from the project's surfaces):

| Type | Definition | Examples |
|---|---|---|
| **first-touch** | User hasn't seen this assistant/concept yet; introductions are appropriate. | Sign-up, wizard step 0, first-run tutorial. |
| **daily-driver** | Opened regularly; knows the assistant and product; greetings are wrong. | Home / dashboard, feed, tab destinations. |
| **settings** | Configuration, infrequent, assumes product knowledge. | Profile, billing, integrations. |
| **error** | Recovery surface; the user hit a problem. | Network lost, permission denied, job failed. |
| **promotional** | One-shot announcements / celebrations. | Feature launch, milestone, win-back. |
| **bridge** | Transition between two arcs. | Wizard done → first daily surface. |

**Step 3 — Build the journey map** — a linear table (Order / Surface / Type / Key copy the user sees). Two rules: fill every row (no stubs), and **verbatim copy only** (paraphrasing hides duplication).

**Step 4 — Apply the banned-pattern matrix.** Once the target's type is known, certain patterns are categorically disallowed:

| Target type | Banned patterns |
|---|---|
| **first-touch** | None — this IS the introduction surface. |
| **daily-driver** | Greetings, introductions, "welcome," "let me show you," "let's get started" (project deny-list). |
| **settings** | Same as daily-driver + re-introducing configured concepts. |
| **error** | Apologies, "sorry," "oops." State the situation; offer one path forward. |
| **promotional** | Re-introducing concepts — celebrations are not re-greetings. |
| **bridge** | Hard-cut into the next arc without acknowledging the transition. |

A target exhibiting a banned pattern is a critical gap (audits) or rewrite-required mark (designs). No softening — the pattern is wrong for the type, and the type is fixed.

**Step 5 — Cross-surface duplication check.** Grep the target's copy against the codebase (`grep -rn "<exact string>" <surface-dirs>`). The same string on a surface of a different type is a problem — the user has already seen it; repeating across types is repetition, not communication.

## How to derive THIS project's specifics

1. **The surface directory structure** — where screens / routes / pages live, the extension, the naming; the Step-1 globs need it.
2. **The copy file locations** — the cross-surface duplication grep needs these paths.
3. **The assistant / persona** — the daily-driver banned row depends on what voice signals "introduction" here.
4. **The surface types in use** — not every project has all six; enumerate only the categories that exist.
5. **The deny-list** — the banned-pattern matrix references it for daily-driver violations.

## Authoring the skill

The final skill (typically `.claude/skills/journey-audit/SKILL.md`) assembles the five-step procedure (with project-specific globs), the surface-type taxonomy (with project examples), and the banned-pattern matrix (populated for the project's deny-list) above, plus: a `paths:` glob matching where design / audit work happens (`docs/designs/**`, `docs/audits/**`, `docs/brainstorms/**`) so it auto-loads when the design/audit agents fire; the output shape (Section 0 of a design/audit doc, or an inline preamble before the gap table); and the non-negotiables — the map is mandatory, verbatim only, classification is binding (force a decision on ambiguous surfaces and document the rationale — never both-and answers that defeat the matrix), and STOP if you can't complete the map (read more; don't proceed on a partial map).

## Cross-references

- `element-reuse.md` — Gate A; journey-mapping is the input to "what does the user already associate with this string?"
- `persona-testing.md` — Gate B; operates on the surfaces named in the journey map.
- `flow-audit.md` — the journey map IS the arc inventory.
- `ux-audit.md` — the map provides the surface-type classification that shapes grading.
