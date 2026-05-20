# memory-system — designing typed cross-conversation memory for ANY project

Teaching material for Claude Code. When you bootstrap a project's AI dev infrastructure, this doc teaches you HOW to install a typed memory system: a four-category taxonomy with per-type lifecycles that keeps cross-conversation memory useful instead of letting it accumulate into noise. Layer 3 of the v2 hierarchy.

## When to ship one (applicability gate)

Ship a typed memory system when:

- The project will live > 2 weeks AND have > 5 Claude Code sessions over its lifetime.
- The user has at least one *"remember when we discussed X"* moment per week. That's the symptom that memory typing would help.
- The user has corrected Claude on the same point twice. Each correction is a candidate feedback entry; without typing, they vanish into chat history.
- The project has user-specific preferences (e.g. *"never run npm, use yarn"*) that should persist across sessions.

Skip when:

- The project is single-session — one user, one focused effort, no return visits.
- The user actively prefers fresh context per session and rejects memory as friction.
- Project lifetime is < 2 weeks. Not enough cross-session continuity for typing to pay off.

The default bias is **ship a minimal version**. Even a `MEMORY.md` index with user-info + 3 feedback entries pays for itself in the second week.

## Why it matters — what this catches that nothing else does

Without typed memory, three failure modes recur:

- **Untyped memory becomes a noise pile.** After 6 months, the memory directory has 200 entries and nobody knows which still apply. The signal-to-noise ratio drops below the threshold where Claude reads memory carefully; entries get loaded as context but ignored.

- **Feedback never graduates to rules.** The user corrects Claude on the same point 5 times. Without typing, the corrections vanish into chat. With typing (`feedback_*` files + promotion-when-fires-3x policy), the lesson graduates to a `.claude/rules/*.md` that fires every session.

- **Stale project memory pollutes current sessions.** Strategy memory from 6 months ago — *"we're pre-investor demo"* — gets loaded into a session where strategy has shifted. Claude makes recommendations against the stale context. Without archive lifecycles, the memory dir grows monotonically and *every old entry is equally weighted*.

The cost asymmetry is sharp: typing adds one filename-prefix decision per entry (~5 seconds). The decay policy adds one decision per quarter (*"should I archive this?"*). Both pay back across years of compounding session efficiency.

## Core methodology — the four memory types

Memory typing splits cross-conversation memory into four categories. Each has its own filename pattern, lifecycle, and promotion path.

### Type 1 — User memory

**What it captures**: who the user is, their role, their preferences, their constraints.

- **Examples**: *"User's email is X."* *"User prefers yarn over npm."* *"User is on macOS; never assume Linux paths."*
- **Filename pattern**: usually embedded at the top of `MEMORY.md` (the index file) as `# userEmail` / `# userPreferences` sections, OR as standalone `user_<topic>.md` files.
- **Lifecycle**: Permanent + auto-loaded. Never promotes (already top-tier).
- **Decay policy**: only changes when the user's situation changes (new email, new role, new platform).
- **Example load-bearing entry**: *"The user owns all native iOS builds — never run `expo run:ios`, `prebuild`, `xcodebuild`, or `pod install` yourself; always delegate to the user."* This is user-shape memory; it gates every native-iOS task.

### Type 2 — Feedback memory

**What it captures**: corrections, lessons learned, anti-patterns the user has explicitly flagged. These are the highest-leverage entries because they encode *what NOT to do*.

- **Examples**: *"Never `git stash --include-untracked` on populated WIP — branch + WIP-commit instead."* *"When user says 'parallel channels,' don't reintroduce step ordering."* *"First use of internal jargon per session = expand in plain language."*
- **Filename pattern**: `feedback_<topic>_<optional_date>.md`. The `feedback_` prefix is load-bearing.
- **Lifecycle**: starts as a single-session correction → captures the lesson → graduates to a rule when it fires 3+ times.
- **Promotion target**: `.claude/rules/*.md`. Once graduated, the rule fires every relevant session; the feedback memory can stay (as the historical context) or be archived.
- **Decay policy**: archive when the rule supersedes it, or when the trigger condition no longer exists in the codebase.

Feedback memory is the **single highest-leverage type**. Every untyped *"oh right, you mentioned that last week"* moment is a candidate feedback entry that's leaking value. Capture them aggressively.

### Type 3 — Project memory

**What it captures**: active strategic state, in-flight decisions, recently-shipped work, open punch lists. Time-sensitive.

- **Examples**: *"Stage 4 GREEN on Demo (2026-05-14)"*. *"Plan 2 post-ship punch list — prod secret drift still open."* *"R2.5 SHIPPED + merged to main; R3 next (2026-05-19)"*.
- **Filename pattern**: `project_<topic>_<date>.md`. Date in filename when the entry is dated; in the body otherwise.
- **Lifecycle**: created during active work → referenced as the work progresses → archived to `docs/archive/memory/` when superseded by ship / pivot / next-phase.
- **Decay policy**: manual archive when status shifts. The trigger is *"is this still active?"* — if no, archive.
- **Promotion target**: usually `docs/archive/memory/`. Sometimes a project entry generates a permanent reference entry (e.g. *"Strategy 2026-05: gym-vertical-first, engine-as-optionality"* becomes a permanent ref doc when the strategy is durable).

### Type 4 — Reference memory

**What it captures**: stable factual references, external pointers, framework / API knowledge specific to this project's setup.

- **Examples**: *"Wedge-ICP venues are multi-floor + multi-room — full spatial primitive is load-bearing, not over-engineering."* *"Capability map introduced (2026-05-18) — `docs/product/capabilities.md` ships as WHAT-the-product-does layer."*
- **Filename pattern**: descriptive slug; no prefix needed (`<topic>.md`).
- **Lifecycle**: Permanent unless invalidated. Updated in place when facts shift.
- **Decay policy**: only invalidate when reality contradicts; otherwise it lives.
- **Promotion target**: if a reference entry grows beyond a one-paragraph factoid into a multi-section doc, promote to `docs/<topic>.md` (project knowledge graph) and link from memory.

### The MEMORY.md index

A single index file at the root of the memory directory. Format:

```markdown
- [<title> (<date>)](<filename>.md) — <one-sentence summary>.
```

Each entry is one bullet ~150 chars total. Claude reads the index by default; entries get expanded on relevance.

The index format matters because it enables **lazy loading**. The full memory dir may be 200 entries / 50k tokens; Claude reads the 5k-token index, picks the 3 entries that matter for the current session, expands those. Without the index, the choice is either *"read everything"* (expensive) or *"read nothing"* (useless).

## How to derive THIS project's specifics

Before authoring the memory system, gather:

1. **Where does memory live?** Claude Code's per-project memory dir is `~/.claude/projects/<project-hash>/memory/`. The MEMORY.md index goes at the root. Confirm path with user — some setups use custom locations.

2. **Existing memory state**. `ls ~/.claude/projects/<hash>/memory/ 2>/dev/null` — what's there? Are there untyped entries to retroactively type? Inventory before installing the discipline.

3. **User's preference style**. Some users want aggressive memory (capture every correction). Some want minimal (only graduate to memory if it fires 3+ times). The capture threshold is project-specific; surface it.

4. **Promotion-to-rule policy**. The default: graduate to a rule after 3 firings of the same feedback. Some projects want 2; some want 5. Set the threshold explicitly.

5. **Archive cadence**. Default: review project memory monthly; archive entries whose work has shipped. Confirm cadence; encode in Layer 7 ritual if active.

6. **Cross-link convention**. Most memory entries reference each other via `[[wikilink]]` syntax or full-path markdown links. Pick one; stay consistent.

## Authoring guidance — what to write into the final artifact

The memory system lands in THREE places:

### Place 1 — `MEMORY.md` index file (the navigation layer)

Top of file: user memory (the always-loaded section). Below: the index of all other entries.

```markdown
# userEmail
The user's email address is <USER_EMAIL>.

# userPreferences
- <PREFERENCE_1> (e.g. "Prefers yarn over npm")
- <PREFERENCE_2>

# currentDate
Today's date is <YYYY-MM-DD>.

---

## Project memory

- [<title> (<date>)](project_<slug>_<date>.md) — <one-sentence summary>.
- ...

## Feedback memory

- [<title> (<date>)](feedback_<slug>.md) — <one-sentence summary>.
- ...

## Reference memory

- [<title> (<date>)](<slug>.md) — <one-sentence summary>.
- ...
```

### Place 2 — Per-entry memory files

Each file is named by type+slug. Body follows a consistent structure based on type:

**For feedback entries**:

```markdown
# <Lesson title>

**Rule:** <one-sentence imperative — what to do or not do>.

**Why:** <why this lesson exists — the underlying cost or risk>.

**How to apply:** <concrete trigger condition + action>.

**Cross-refs:** <related memory entries via [[wikilink]] or `<path>` cross-links>.

**Status:** <active / promoted-to-rule (link to rule) / archived>.
```

**For project entries**:

```markdown
# <Active state title>

**Status:** <active / shipped / in-review / blocked>.
**Date:** YYYY-MM-DD (last update).

<2-5 paragraph body capturing the current state, open items, decisions made, next action>.

**Related:** [[other-entry]] · [[doc-path]].
```

**For reference entries**:

```markdown
# <Fact / pointer title>

<Body — one or more paragraphs of stable fact>.

**Last verified:** YYYY-MM-DD.
**Cross-refs:** ...
```

### Place 3 — `CLAUDE.md` memory section (the discoverability hook)

A short section in `CLAUDE.md` "Where to find what" pointing into the memory dir:

```markdown
**Cross-conversation memory** lives at `~/.claude/projects/<project-hash>/memory/`. Index at `MEMORY.md`. Read top of index for user info + current date; expand specific entries on relevance. Types: `user` (permanent) / `feedback` (lessons; promote to rule at 3 firings) / `project_<topic>_<date>` (active state; archive on supersession) / `<slug>` (reference; permanent unless invalidated).
```

This is the *meta*-pointer: Claude knows memory exists, knows where to find the index, knows the typing conventions, and can pull entries lazily.

## Depth signatures — what battle-tested looks like

The authored memory system fails the depth bar if it lacks any of these signals.

1. **Memory files named by type+slug.** `user_role.md`, `feedback_<rule>.md`, `project_<topic>_<date>.md`, `<reference-slug>.md`. The prefix encodes the type; type encodes the lifecycle.

2. **MEMORY.md index entries are one-line (~150 chars).** Longer than this and the index becomes a wiki. Shorter and entries can't be evaluated for relevance.

3. **Feedback memory bodies lead with the rule.** *"Never X."* / *"When Y happens, do Z."* — direct, imperative, scannable. Without the rule-first structure, feedback becomes narrative; lesson is buried.

4. **Project memory bodies have a status tag.** active / shipped / in-review / blocked / archived. Without it, project entries are timeless — and timelessness means *every* entry is equally current, which is false.

5. **Active dates on dated entries.** Project memory should have a date in filename + body. Feedback memory should have a date in body. Reference memory should have `Last verified:`. Undated entries are unauditable.

6. **Cross-references between memory files.** `[[wikilink]]` or full-path. The memory dir is itself a small graph; cross-refs are what make it navigable.

7. **Promotion path exists.** When a feedback entry fires 3+ times, it graduates to `.claude/rules/<X>.md`. The memory entry should reference its rule promotion (`**Status:** promoted to .claude/rules/X.md (2026-05-19)`). Without the promotion path documented, feedback ossifies in memory instead of compounding into discipline.

8. **Archive cadence runs.** `ls ~/.claude/projects/.../memory/ | wc -l` should be < 50 in a healthy project. > 100 entries means archive cadence isn't running.

9. **CLAUDE.md mentions the memory dir.** Without this, new sessions don't know memory exists.

10. **The index lazy-loads.** Test: read MEMORY.md alone (without expanding entries); can you decide which entries to read next? If yes, lazy-loading works. If no, the index summaries are too thin.

If the authored memory system lacks any of these, redo. Typing without lifecycle is just labels.

## When to save / when to access / when to remove

### When to save (capture trigger)

- **The user just told me something.** *"Don't do X anymore."* / *"Actually, prefer Y."* / *"Remember that we already shipped Z."* → feedback or project entry.
- **The user corrected me on a non-obvious choice.** Not a typo; not a one-off. A choice that future-me would default to the wrong way. → feedback entry.
- **I just resolved an ambiguity in a way the user approved.** *"OK, we'll do approach A not approach B."* That decision is recoverable as code, but the *rationale* is not. → project or reference entry.
- **A non-obvious environmental fact would burn a future session if forgotten.** *"This project's database is on Supabase Edge, not standard Postgres."* → reference entry.
- **The user expressed frustration with a recurring miss.** *"You keep doing X — stop."* → feedback entry, high priority for promotion-to-rule.

### When NOT to save

- **Facts derivable from git / code / files.** *"This project uses TypeScript."* — readable from `package.json`. Don't duplicate.
- **Plan progress that duplicates a doc.** *"We finished sub-plan 3."* — that's what the conformance matrix is for. Memory is for cross-conversation factoids; plan progress lives in the doc.
- **Implementation details.** *"The function `foo()` takes a `Bar` parameter."* — that's in the code. Reading code is cheaper than reading memory.
- **Single-use context.** If you needed it once and won't need it again, don't save.

### When to access (load trigger)

- **The user references prior work.** *"Like we discussed last week"* / *"remember when..."* — Claude searches memory for the referenced thing.
- **Decisions depend on past context.** Before recommending a tech choice, check feedback for *"we already decided against X"*.
- **The session opens with no obvious context.** Read MEMORY.md index; expand any entries whose summaries match current session topic.

### When to remove

- **Memory contradicts current code / state.** *"We use yarn"* but the project just migrated to pnpm. Update or archive.
- **The user says *"we no longer do X"*.** Archive (don't delete) the entry; the historical context is still useful for understanding why state shifted.
- **Project memory whose work has shipped + been audited.** Archive to `docs/archive/memory/` after the project memory is no longer load-bearing.
- **Feedback memory after promotion to rule.** Either archive (the rule is canonical now) or keep with a `**Status:** promoted` note (for historical context).

## Anti-patterns to avoid

- **Letting all memory be "project" type.** Every entry becomes monotonic accumulation. The promotion / archive paths don't fire. After 12 months the directory has 200 entries and nobody knows which still apply.

- **Saving facts derivable from code.** *"The auth handler is at `app/auth/handler.ts`."* — readable from `ls`. Don't duplicate; let Claude grep.

- **Memory entries without dates.** Undated project memory is timeless = currently-true = false 80% of the time. Always date.

- **Feedback bodies that bury the rule.** Long narrative *"so the other day we were discussing..."* with the actionable lesson three paragraphs in. Lead with the rule.

- **No promotion path from feedback to rule.** Feedback that fires 5 times and stays in memory is a discipline failure. The promotion path is what makes feedback compound into rules.

- **Index entries that are useless without expanding the file.** *"Note about auth."* — what about it? The one-line summary should be informative enough that Claude can decide relevance without expanding.

- **Memory dir growing without archive cadence.** 100+ active entries means the archive policy doesn't run. Even if no entries are *wrong*, the volume drowns the signal.

- **Saving every chat as memory.** Memory is for *non-obvious* facts and *load-bearing* decisions. The whole chat history is recoverable via session search; don't duplicate.

- **`MEMORY.md` that's just `ls memory/`.** The index is curated summaries; auto-generated dir listings have no summaries and no relevance signal.

- **User-preference contradictions across entries.** *"User prefers yarn"* in one entry; *"User uses npm"* in another (from a different time). Resolve, don't accumulate. The user-info section should be authoritative; if changing, update in place.

- **Cross-references that point to deleted entries.** When archiving, update the references. Otherwise the graph has dead links.

## Cross-references

- `project-identity.md` — Layer 1. User memory captures user-shape facts; identity captures project-shape facts. Different scopes, same kind of always-loaded persistence.
- `knowledge-graph.md` — Layer 5. `docs/` and memory have different lifetimes: `docs/` is project-level external memory (specs, plans, audits); memory is cross-conversation factoids. They compose but don't substitute. Project memory that grows into a multi-section reference promotes to `docs/<topic>.md`.
- `task-classification.md` — Layer 3. The task classification routing references memory access: *"check feedback memory for prior decisions"* is part of how-you-work for several task types.
- `plan-driven-work.md` — Layer 3. Conformance matrices live in `docs/audits/`; the plan's status is project memory until the matrix is final.
- `maintenance-ritual.md` — Layer 7. Memory archive cadence is part of the Saturday-style ritual; without the ritual, memory bloats.
