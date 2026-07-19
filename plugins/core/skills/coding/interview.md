# `/dotclaude:coding` interview

4-5 questions, adaptive. Skip what Phase 1 (project scan) already answered. The goal: extract the project-specific calibration — file ceiling, recurring bug classes, voice rules — that can't be read from code alone.

## C1 — File-size ceiling

> "Looking at the top of your file-size distribution, I see `<path1>` at <N1> LOC, `<path2>` at <N2> LOC, and `<path3>` at <N3> LOC; the bulk of your files sit under <M> LOC. I'm proposing a ceiling of <X> LOC with a warning at <Y>. Does that fit, or should it be tighter / looser?"

Lead with the data you already have. If the user pushes back ("we have legitimate state machines that grow to 1500"), accept and adjust — encode the exemption rather than fighting the user's instinct.

If the codebase is uniformly small (every file < 300 LOC), float skipping the rule: "Your code is already disciplined on file size — I don't think a ceiling rule earns its keep here. Record one anyway in `dotclaude.yml` as a tripwire, or skip it?"

## C2 — Register (optional, one line)

> "One optional note: when you imagine the review report's tone, is it 'careful colleague pointing out missed cases' or 'staff engineer enforcing the bar'? This isn't shaping an agent — the consumed `code-review` agent's rubric and methodology are fixed — it's just a one-line preference the artifact can carry if you want it recorded."

There's no reviewer being generated here, so there's nothing to tune in depth or tooling. If the user has no preference, skip this entirely — the consumed agent's rubric already has sane defaults regardless. If they do care, record it as a single `**Register:** <colleague / staff-engineer>` line near the top of `code-anti-patterns.md` — a note the agent can read, not a rewrite of its behavior.

## C3 — Past bug classes (THE most important question)

> "Name 2-4 bugs your project has shipped where you wished a reviewer had caught it. Not asking for postmortems — just the shape: 'the cache invalidation in feature X forgot to fire on path Y' or 'we had two places writing to the same table and they drifted apart.'"

These become the reviewer's project-specific anti-patterns. WITHOUT this question the reviewer leans on generic patterns from the principle doc and misses the bugs that actually matter to THIS project.

Listen for repeated structural patterns ("we keep forgetting X"). Each repeated pattern is one entry in the anti-pattern section.

Cross-check against the fix-prefix commits you read in Phase 1. If the user names a bug class that's NOT in the recent commit history, ask whether it's recent or historical — recent ones are still live concerns; ancient ones might be fully solved by now.

## C4 — Voice / brand forbidden phrases

> "Three quick checks on voice:
> 1. Does your product have user-facing copy (UI strings, error messages, AI-generated text, marketing copy)?
> 2. Are there phrases you'd never want in production copy? AI-slop ('Let me help you with that!', 'I'd be happy to assist!', 'Great question!') is one category; brand-specific is another ('amazing', '!', 'guys', whatever doesn't fit your voice).
> 3. Does the product have an in-app assistant / character whose voice could leak into daily-driver surfaces?"

If yes to (1) and (2): collect the list. The list becomes the `forbiddenPhrases.phrases` + `.scopes` block in `dotclaude.yml` — data the project can later wire into the `check-forbidden-phrases` hook template (that wiring is `/dotclaude:bootstrap`'s job, not this skill's).

If yes to (3): flag the first-touch-vs-daily-driver trap (assistant's onboarding voice leaks into surfaces where it doesn't belong). The `dotclaude.yml` scopes list should include the assistant's copy files specifically.

If no to all: skip the `forbiddenPhrases` key entirely. Note in the summary that this is deferred until voice emerges.

## C5 — Existing conventions to respect

> "Anything in `CLAUDE.md`, `CONTRIBUTING.md`, or a style guide I should align the artifact with? Specific things to call out:
> - Naming conventions (snake_case / camelCase / PascalCase per layer)
> - Existing decomposition patterns (where pure helpers live, where hooks live, where types live)
> - Lint rules you've explicitly disabled (the consumed reviewer shouldn't re-flag those)
> - Any 'never do X' rules already documented"

Read whichever docs the user names. Conflicts between the artifact and the user's existing docs are bugs — the user's docs win.

If the project has no convention docs but the codebase shows clear patterns (every screen has a `<Screen>.tsx` + `useScreen.ts` pair, every domain has a `lib/<domain>/operations/` directory), these are useful context for framing an anti-pattern entry (e.g., "helpers landing outside `lib/utils/` drift from the rest of the codebase") — they don't get their own section in the artifact; fold them into a C3 entry only if they map to a real bug class.

---

## How to use this script

- Don't fire-hose. One or two questions per turn, conversational.
- Lead with data when you have it (Phase 1 read the file-size distribution and the git log — use those numbers in C1 and C3 rather than asking the user to recall from memory).
- Skip ruthlessly. If Phase 1 shows zero user-facing copy and a backend-only stack, skip C4 entirely.
- Listen for off-script signal. "Our settings handler has gotten messy" is a hint — follow it, that's anti-pattern gold.
- End when you have enough. C2 and C5 are skippable for solo projects with conventional stacks.

## After the interview

Summarize back before writing the artifact:

> "Based on our chat: file ceiling = <N> LOC (warn at <M>), register note = <colleague / staff-engineer / skipping>, project-specific anti-patterns I'll write into `code-anti-patterns.md` = <count> (drawn from <list of bug classes>), voice deny-list in `dotclaude.yml` = <count or 'skipping for now'>, existing conventions I'll respect = <key items>. About to write the artifact — confirm?"

Wait for confirmation, then proceed to Phase 3 of `SKILL.md`.
