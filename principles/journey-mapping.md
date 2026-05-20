# journey-mapping — designing the prior-surface inventory before any new design

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a journey-mapping skill for projects with multi-step user flows. The skill is the precondition every other design / audit agent depends on: before designing a screen, before grading a flow, *know where the user came from.*

## DUAL LOAD — this skill runs at BOTH design time AND audit time

This skill is **dual-loaded**: it fires inside `product-designer` (design time, Section 0 of every spec) AND inside `ux-audit` / `interaction-audit` / `flow-continuity-review` / `flow-audit` (audit time, before grading any captured surface).

This dual-load is **structural drift prevention**. A spec passing journey-audit at design time tells you the *intended* surface-type classification; rerunning the skill at audit time against the *implemented* surface catches the case where impl drifted from spec. Without dual-load, an audit grades against the implementation's *de facto* surface type, which may not match the spec's *de jure* one — the bug class hides in plain sight.

Concretely: the agent dispatching this skill MUST be configured to load it at the appropriate moment. For designers — Section 0 of the spec template. For reviewers — first action before grading, before journey classification, before any per-screen verdict. Skill frontmatter's `paths:` glob makes auto-load happen on the file edits; explicit invocation in agent dispatch flow makes the audit-time rerun happen.

## When to ship one (applicability gate)

Ship a journey-mapping skill when:

- The project has **multi-step user flows** — onboarding, checkout, wizard, multi-screen tasks.
- The project has an assistant / agent / persona that has a voice and an introduction moment.
- The project has shipped a "the welcome message appeared on the daily home screen" class of bug — copy appropriate to first-touch leaking onto daily-driver surfaces.
- Multiple designer / reviewer agents will operate; they need a shared input to coordinate.

Skip when:

- The project is a single-screen tool with no flow structure.
- All surfaces are equivalent (e.g., a settings-app with no onboarding distinct from daily use).
- The product has no voice / persona — copy is purely functional and surface-type doesn't change tone.

## Why it matters — what this catches that nothing else does

The failure mode this prevents: **screens get designed in isolation, and copy / voice / chrome appropriate to one surface type leaks onto another.** The canonical bug shape:

- The onboarding wizard greets the user with "Hi — I'm <assistant>. Let me show you around." Correct.
- Three weeks later, someone adds a notification banner that says "Hi — I'm <assistant>. Here's an update." Wrong. The user has known the assistant for three weeks. Re-introducing is condescending.
- The reviewer didn't catch it because the screen in isolation is fine. Only the *journey* makes it visible.

Other patterns the journey map catches:

- **Reused copy on inappropriate surface types.** A "Get started" call-to-action belongs on a wizard step, not on the daily-driver home page.
- **Re-introductions of concepts.** Explaining what a feature is on a surface the user reaches AFTER they've used it.
- **Apology-state copy on success states.** "Sorry, we couldn't…" copy living on a screen the user lands on after a successful operation.
- **Tone hopping mid-flow.** Step 3 uses intimate-second-person; step 4 switches to corporate-third-person; user notices something feels off but can't name it.
- **Bridge gaps.** Two arcs (wizard → daily home) connected with no transition surface — user feels jarred.

These bugs are invisible to per-screen review. Only the journey-as-a-whole exposes them. The journey-mapping skill produces the inventory; downstream agents grade against it.

## Core methodology — five steps

The skill walks a fixed procedure:

### Step 1 — Enumerate prior surfaces

Starting from **first interaction with the product** (sign-up, sign-in, app open), walk forward through every screen / surface the user touches up to the target. The enumeration is mechanical:

- Glob for all screen / route / page files in the relevant directories.
- Glob for all flow-defining files (wizard / onboarding modules).
- Glob for all copy / translation / narration sources.
- For each found file, read enough to know: what does the user SEE on this surface? What does the system / assistant SAY? What's the tone?

The skill should be **specific about the project's surface directory structure**. For a React Native app it might be `app/wizard/`, `app/(owner)/`, `lib/persona/`. For a web app it might be `src/pages/`, `src/routes/`, `src/copy/`. Encode the project's actual paths.

### Step 2 — Classify each surface

Every surface gets exactly one type. The universal taxonomy:

| Type | Definition | Examples |
|---|---|---|
| **first-touch** | User hasn't seen this assistant or this concept yet. Introductions are appropriate. | Sign-up, wizard step 0, post-signup welcome, first-run tutorial. |
| **daily-driver** | User opens this regularly. Knows the assistant. Knows the product. Greetings and introductions are wrong. | Home / dashboard, feed, primary list view, tab destinations. |
| **settings** | Configuration surface. Infrequent use. Assumes product knowledge. | User profile, billing, integrations, preferences. |
| **error** | Recovery surface. User is in a flow that hit a problem. | Network lost, permission denied, payment failed, job failed. |
| **promotional** | One-shot announcements / celebrations / nudges. | Feature launch banner, milestone celebration, win-back. |
| **bridge** | Transition surface between two arcs. | Wizard completed → first daily surface, payment confirmed → home. |

The taxonomy is universal in shape; the *examples* per category derive from the user's actual surfaces.

### Step 3 — Build the journey map

A linear table:

| Order | Surface | Type | Key copy / components the user sees |
|---|---|---|---|
| 1 | sign-up | first-touch | `<verbatim copy from the screen>` |
| 2 | wizard step 1 | first-touch | `<verbatim copy>` |
| ... | ... | ... | ... |
| K | **TARGET** (this design / audit) | `<classify>` | `<what's proposed OR what's there now>` |

Two rules:
- **Fill every row.** Do not abbreviate or stub.
- **Verbatim copy only.** Paraphrasing hides duplication.

### Step 4 — Apply the forbidden-pattern matrix

Once the target's type is known, certain patterns are categorically disallowed:

| Target type | Forbidden patterns |
|---|---|
| **first-touch** | None — this IS the introduction surface. |
| **daily-driver** | Greetings, introductions, "welcome," "let me show you," "let's get started." (Project-specific deny-list — see `forbidden-phrases.md`.) |
| **settings** | Same as daily-driver + re-introducing concepts the user has configured. |
| **error** | Apologies, "sorry," "oops," "I'm here to help." State the situation; offer one path forward. |
| **promotional** | Re-introducing concepts. Celebrations are not re-greetings. |
| **bridge** | Hard-cut into the next arc without acknowledging the transition. |

If the target exhibits a forbidden pattern, it's a critical gap for audits, or a rewrite-required mark for designs. No softening. The pattern is wrong for the type; the type is fixed.

### Step 5 — Cross-surface duplication check

Grep the target's copy against the rest of the codebase:

```
grep -rn "<exact-string-from-target>" <surface-dirs>
```

If the same string appears on a surface of a different type, that's a problem. The user has already seen it; repeating across surface types is repetition, not communication.

## How to derive THIS project's specifics

Before authoring the skill, gather:

1. **The project's surface directory structure.** Where do screens / routes / pages live? What's the file extension? What's the naming convention? The skill's Step-1 glob commands need to be specific.

2. **The project's copy file locations.** Where do translation / narration / copy files live? The cross-surface duplication grep needs these paths.

3. **The project's assistant / persona (if any).** Is there a named assistant? An on-brand voice? The forbidden-pattern matrix's daily-driver row depends on what voice signals "introduction" in this project.

4. **The project's surface types in use.** Not every project has all six categories. A B2B SaaS might have wizard + dashboard + settings only; no promotional, no bridge. Configure the skill to enumerate only the categories that exist.

5. **The deny-list** (typically `forbidden-phrases.md` ships alongside) — the forbidden-pattern matrix references the deny-list for daily-driver violations.

## Authoring the skill

The final skill (typically `.claude/skills/journey-audit/SKILL.md`) should specify:

1. **When to use** — design + audit triggers. Always before designing a new surface; always before auditing one.
2. **When NOT to use** — pure visual-polish or single-screen code-only refactors.
3. **The five-step procedure** — with project-specific glob commands.
4. **The surface-type taxonomy** — with project-specific examples for each row.
5. **The forbidden-pattern matrix** — populated for THIS project's deny-list.
6. **The output shape** — Section 0 of a design / audit doc, OR an inline preamble before the gap table.
7. **Non-negotiables** — the map is mandatory; verbatim only; classification is binding; if you can't complete the map, stop.

## When this skill is the precondition

The skill is meant to AUTO-LOAD when other design / audit agents fire. The frontmatter `paths:` field should match the directories where design / audit work happens:

- For projects that produce design specs in `docs/designs/`: `paths: "docs/designs/**"`
- For projects that produce audit docs in `docs/audits/`: `paths: "docs/audits/**"`
- For projects with brainstorm artifacts in `docs/brainstorms/`: add `docs/brainstorms/**`

When `product-designer`, `ux-audit`, `flow-audit`, `interaction-audit` agents are dispatched, the skill loads automatically and forms Section 0 of their output. If any of those agents skip the journey map, the audit / design is incomplete by definition.

## Cross-references

- `element-reuse.md` — Gate A. When reusing an existing string, journey-mapping is the input to "what does the user already associate with this string?"
- `persona-testing.md` — Gate B. Every copy element passes outside-eyes tests; persona-testing operates on the surfaces named in the journey map.
- `forbidden-phrases.md` — the authoritative deny-list. Journey-mapping's Step 4 matrix references it.
- `flow-audit.md` — audits the whole arc; the journey map IS the arc inventory.
- `ux-audit.md` — single-screen visual polish; the journey map provides surface-type classification that shapes the grading.

## Anti-patterns in the skill you write

- **Skipping the map "because the surface is simple."** This is the failure pattern the skill exists to prevent. Make it non-negotiable in the skill's prose.

- **Allowing paraphrased copy in the map.** Paraphrase hides duplication. The verbatim rule isn't a stylistic preference; it's the only way to detect cross-surface drift.

- **Letting classification slip ("kind of a daily-driver but also kind of first-touch").** Surfaces have one type. If genuinely ambiguous, the skill should force a decision and document the rationale; it should NOT enable both-and answers that defeat the forbidden-pattern matrix.

- **Forbidden-pattern matrix copied from this principle doc.** The patterns are project-specific. The daily-driver forbidden list comes from the user's voice and the deny-list. Don't ship a generic list; derive from the project.

- **No "STOP if you can't complete the map" clause.** When the user can't enumerate prior surfaces because they're unfamiliar with the codebase, the right action is to read more — not to proceed with a partial map. The skill should encode the stop signal.

- **Treating the map as documentation, not an audit input.** The map's value is in being CONSULTED. If it lives in a doc that nobody references after writing, the skill has failed. Wire it into the design / audit agents' workflows.

- **Auto-load paths too narrow.** If the skill's frontmatter `paths:` only matches `docs/audits/**` but the user also produces designs in `docs/specs/**`, the skill misses half the work. Enumerate paths precisely.
