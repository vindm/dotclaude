---
description: Lighter alternative to /dotclaude:bootstrap when you want Layer 6 domain kits only, skipping upstream layers. Orchestrates the relevant subset of domain skills (design / coding / planning / testing / data / ai-workflow) based on project shape — no identity / architecture / process / quality-bar / knowledge-graph / maintenance authoring. Use /dotclaude:init for incremental Layer 6 setup on partial-brownfield projects, or when the user already has CLAUDE.md authored by hand.
---

# `/dotclaude:init` — Layer 6 meta-orchestrator

## v2 context (read first — added 2026-05-21)

In v1.1, dotclaude introduced **`/dotclaude:bootstrap`** as the headline 7-layer setup command. Bootstrap walks project identity → architecture → process discipline → quality bar → knowledge graph → domain kits (this IS Layer 6) → maintenance, authoring `CLAUDE.md` + `docs/` + `.claude/` together.

**`/dotclaude:init` is the v1 entry-point — preserved, now positioned as Layer-6-only.** Use it when:

- You already have a `CLAUDE.md` authored by hand and don't want bootstrap to touch it.
- You want incremental Layer 6 setup on a partial-brownfield project (some `.claude/` artifacts exist; you want to extend them).
- The project doesn't need the upstream layers yet (early prototype; you want design discipline before deciding on long-term architecture).

**Use `/dotclaude:bootstrap` instead when**: greenfield project, no `CLAUDE.md`, want comprehensive AI dev infrastructure setup (~25–45 min wall-clock for typical 1–5 domain projects). See [README.md](../../README.md) §"How bootstrap works" for the full 7-layer walkthrough.

The two commands are complementary, not competing:
- `/dotclaude:bootstrap` = full hierarchical setup (Layers 1–7).
- `/dotclaude:init` = Layer 6 only (this skill).

For an even more targeted setup, the user can invoke a single domain skill directly:

- `/dotclaude:design` — UI / IA / a11y / visual quality discipline ⭐
- `/dotclaude:coding` — file size, code review, decomposition, voice
- `/dotclaude:planning` — pre-impl validation, audit routing
- `/dotclaude:testing` — test architecture + coverage
- `/dotclaude:data` — DB integrity, query discipline, migrations
- `/dotclaude:ai-workflow` — LLM workflow cost monitoring + eval discipline

`/dotclaude:init` is the meta over those domain skills — it picks which of them flow. It does NOT author the upstream-layer artifacts (`CLAUDE.md` identity / architecture sections, `docs/` knowledge graph, `quality-bar/SKILL.md` cross-cutting rubric, etc.) — those are bootstrap's lane.

## Phase 1 — Project scan (do this BEFORE asking the user anything)

Read in order:

1. `README.md` (or `README*` variant) — the user's own framing
2. `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / equivalent — stack signal + dependencies + scripts
3. Top-level directory structure (`ls -la` + one level deep) — look for: `app/` `pages/` `src/` `lib/` `components/` `ui/` `ios/` `android/` `infra/` `docs/` `migrations/` `tests/` `__tests__/`
4. Existing `CLAUDE.md` / `AGENTS.md` / `CONTRIBUTING.md` — respect existing conventions
5. `git log --oneline -30` — what bug classes recur? "fix:" prefix is the signal
6. One representative source file per major module — language idioms, conventions

Use these signals to decide which domain skills apply (next phase).

## Phase 2 — Domain applicability check

For each domain, decide: does this project NEED this kind of discipline?

| Domain | Apply if project has… | Skip if… |
|---|---|---|
| **design** | UI surfaces (web, mobile, desktop, CLI TUI), components, theme files, design tokens | Pure backend / library / dev tool with no human-facing surface |
| **coding** | Any code at all | Truly throwaway prototype |
| **planning** | Multi-module / multi-file changes are common | Single-file utility |
| **testing** | Tests exist OR should exist | Pure exploration / one-off script |
| **data** | Database / persistent state / migrations | Stateless app / pure-compute lib |
| **ai-workflow** | LLM / AI calls in production or eval suites | No AI in scope |

Default: apply most domains. Skip is the exception, with a stated reason.

Show the user the applicability matrix BEFORE running anything:

> "Based on the project scan, I'm planning to run:
>   - `/dotclaude:design` — your `app/` has React Native screens
>   - `/dotclaude:coding` — universal
>   - `/dotclaude:planning` — your `lib/` is multi-module
>   - `/dotclaude:data` — Postgres migrations under `db/migrations`
>   - SKIPPING `/dotclaude:testing` — no test directory found yet
>   - SKIPPING `/dotclaude:ai-workflow` — no LLM dependencies
>
> Confirm before I start, or adjust the list."

Wait for user confirmation.

## Phase 3 — Run the domains in sequence

For each domain in the confirmed list, read its `SKILL.md` and execute its instructions:

1. `skills/design/SKILL.md` (if applied)
2. `skills/coding/SKILL.md` (if applied)
3. `skills/planning/SKILL.md` (if applied)
4. `skills/testing/SKILL.md` (if applied)
5. `skills/data/SKILL.md` (if applied)
6. `skills/ai-workflow/SKILL.md` (if applied)

Each domain skill is self-contained: it does its own interview (scoped to that domain), reads the relevant principles from `../../principles/`, and authors artifacts to `.claude-staging/` in the user's project.

You do NOT have to repeat the meta-level project scan inside each domain — each domain skill may do its own additional scoping reads, but the macro context you've built in Phase 1 stays loaded.

**Token discipline**: each domain interview should be 3-5 questions, not 10. The cumulative interview across 4-5 domains is what the user is signing up for when they invoke `init` rather than a targeted single skill.

## Phase 4 — Cross-domain coordination

Some artifacts appear in multiple domains' applicability — e.g. `forbidden-phrases.txt` is referenced by both `design` (voice / tone) and `coding` (AI slop). When two domains both want to author the same file, the LAST one wins by default — but call this out:

> "Both `/dotclaude:design` and `/dotclaude:coding` proposed a `forbidden-phrases.txt`. I merged them — design's brand-voice phrases + coding's universal AI-slop phrases. The file is at `.claude-staging/rules/forbidden-phrases.txt`."

Domains should not stomp on each other silently.

## Phase 5 — Final review + commit

After all domains finish, show the user the full `.claude-staging/` inventory:

```
Authored:
  agents/      <list — N total>
  skills/      <list — N total>
  rules/       <list — N total>
  hooks/       <list — N total>

By domain:
  design       <subset>
  coding       <subset>
  planning     <subset>
  data         <subset>

Skipped at domain-applicability check: <list with reasons>
Cross-domain merges: <list>
```

Walk through 3-5 highlight artifacts and explain the reasoning ("I picked these design benchmarks because you named them in the interview; I added this DB-integrity check because your `db/migrations/` shows you've been adding RLS recently").

Wait for explicit user approval, then move `.claude-staging/` → `.claude/` and commit with a structured message.

## Non-negotiable rules

1. **Project scan first, always.** Phase 1 reads happen before ANY question. A question whose answer is obvious from `package.json` is a wasted question.
2. **Show the domain plan before running.** User has veto power. They may want to skip a domain you flagged as applicable, or add one you skipped.
3. **Each domain interview is scoped.** Don't ask design questions inside the coding flow. The domain skill knows its own questions.
4. **Stage, never overwrite.** All artifacts land in `.claude-staging/` until user approves. Then move to `.claude/`.
5. **Author, do not copy.** Domain skills enforce this. If you catch a domain authoring a template-substitute artifact, that's a bug in the domain skill — report it.
6. **A focused `.claude/` of 5-10 well-tuned artifacts beats 25 sprawling ones.** Resist comprehensiveness. The applicability matrix exists to keep scope tight.

## Output format

When all domains complete + user approves, output:

```
✓ dotclaude:init complete

Domains run: <list>
Domains skipped: <list with one-line reasons>

In .claude/:
  N agents:  <list>
  N skills:  <list>
  N rules:   <list>
  N hooks:   <list>

Recommended next steps:
  1. <e.g. "Add concrete forbidden phrases to .claude/rules/forbidden-phrases.txt — the hook is wired but the list is empty">
  2. <e.g. "Re-run /dotclaude:init in 4 weeks as the project grows">
  3. <e.g. "Read .claude/agents/code-reviewer.md — its anti-pattern list cites your actual file paths and may need refinement">

Commit the staged .claude/ when ready.
```
