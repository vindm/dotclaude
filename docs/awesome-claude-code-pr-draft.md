# awesome-claude-code submission draft

Target: [`hesreallyhim/awesome-claude-code`](https://github.com/hesreallyhim/awesome-claude-code) — the most prominent curated list in the Claude Code ecosystem.

**Status (2026-05-21): NOT YET SUBMITTABLE.** See "Blocker" below. Submit on or after **2026-05-28**.

## Blocker — 1-week public-history requirement

The target's [`docs/CONTRIBUTING.md`](https://github.com/hesreallyhim/awesome-claude-code/blob/main/docs/CONTRIBUTING.md) and issue template (`recommend-resource.yml`) require:

> *"It has been over one week since the first public commit to the repo I am recommending"* (mandatory checkbox; submission blocked if unchecked).

dotclaude's first public commit was **2026-05-20**. The earliest legitimate submission date is **2026-05-28**.

Submitting before then would:
1. Trip the bot's automated rejection.
2. Per the target's CONTRIBUTING: *"Failure to comply with the simple requirements stated in the CONTRIBUTING document will result in increasingly severe penalties."* (Risk: temporary or permanent ban from the repo.)

**DO NOT SUBMIT BEFORE 2026-05-28.**

## Why this target (not a different one)

Considered alternatives:
- `hesreallyhim/awesome-claude-code` — chosen. Most prominent (general Claude Code list). Broad audience. Includes Agent Skills, plugins, slash commands as first-class categories.
- `VoltAgent/awesome-claude-code-subagents` — narrower (subagent-focused). dotclaude's primary value is bootstrap + slash commands, not subagents specifically; would be a thinner fit.
- `pchalasani/awesome-claude-code` (smaller alt) — lower reach; less curatorial signal.

## Why PR mechanic doesn't apply

The target explicitly **forbids PR submissions**:

> *"NOTE: ALL RECOMMENDATIONS MUST BE MADE USING THE WEB UI ISSUE FORM TEMPLATE, OR YOU RISK BEING BANNED FROM INTERACTING WITH THIS REPOSITORY TEMPORARILY OR PERMANENTLY."*

And:

> *"It is **not** possible to submit a resource recommendation using the `gh` CLI."*

The submission path is the GitHub Web UI **only**. Use this link:
[https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml](https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml)

## Submission form — filled-out values

Copy-paste these into the form on or after 2026-05-28.

### Display Name
```
dotclaude
```

### Category
```
Agent Skills
```
(Rationale: dotclaude is primarily a plugin distributed via Claude Code's plugin marketplace, containing 8 slash-command skills. "Agent Skills" is the form's umbrella category for plugins per the form's note: *"I'm currently lumping most things called 'plugins' under 'Agent Skills' until I figure out a better classification system."*)

### Sub-Category
```
General
```

### Primary Link
```
https://github.com/vindm/dotclaude
```

### Author Name
```
vindm
```

### Author Link
```
https://github.com/vindm
```

### License
```
MIT
```

### Description (1-3 sentences max, no emojis, descriptive not promotional, don't address the reader)

```
AI dev infrastructure framework for Claude Code projects. The /dotclaude:bootstrap command walks a 7-layer hierarchical interview — project identity, architecture, process discipline, quality bar, knowledge graph, domain kits, maintenance — and authors a tailored CLAUDE.md, docs/ subtree, and .claude/ subset (agents, skills, rules, hooks) derived from the project's actual code shape. Per-domain entry points (design, coding, planning, testing, data, ai-workflow) compose with bootstrap or run standalone for incremental setup.
```

### Validate Claims (mandatory for plugins/skills/frameworks)

```
Install the plugin into a fresh Vite + React + TypeScript project and run /dotclaude:design. The skill scans the project's stack, asks ~5 questions (auto-skipping any pre-answered by the scan), and authors 15 files (4 agents, 5 skills, 4 rules, 2 hooks) totaling ~1500 LOC to .claude-staging/. Each artifact cites the project's actual file paths, mines war-story SHAs from git history, and names project-specific anti-patterns. Full smoke-test report: https://github.com/vindm/dotclaude/blob/main/docs/design-real-smoke-test-2026-05-21.md
```

### Specific Task(s)

```
Run /dotclaude:design (or /dotclaude:coding) against a fresh Vite + React TypeScript project that has at least one fix-prefix commit. Diff .claude-staging/ against what a generic template kit would produce.
```

### Specific Prompt(s)

```
After installing the plugin in a target project, just type: /dotclaude:design

The skill will run an interview, ask 4-6 questions, then author to .claude-staging/. Compare the authored .claude-staging/agents/ux-reviewer.md against any generic ux-reviewer template — observe that the file cites your project's actual src/styles/tokens.ts, references your project's real git SHAs as anti-pattern war stories, and names the design-system benchmarks YOU specified (Linear / Stripe / Vercel etc.) rather than defaulting to Apple / Telegram. The artifact is derived, not templated.
```

### Additional Comments (optional)

```
dotclaude's primary differentiator is the hierarchical bootstrap — Layer 1 (project identity) outputs feed Layer 2 (architecture) which feed Layer 4 (quality bar), so the kit refuses to ask "what's your S-tier benchmark?" without first knowing whether the project even has a UI. Skipping Layer 1 produces generic outputs; the bootstrap walks layers in dependency order.

Two real smoke-test reports validate breadth (different domains) and depth (depth-bound honesty):
- docs/design-real-smoke-test-2026-05-21.md — fresh Vite project, 15 artifacts, A-grade
- docs/coding-real-smoke-test-2026-05-21.md — same project, coding domain, A-minus with honest depth-bound caveats

Zero runtime dependencies. Anonymization-guarded (no leak of the source project's identifiers in any shipped artifact). CI-enforced.

Could Opus build this in one session? No — methodology distilled from 6+ months of running Claude Code on one battle-tested production codebase. The principles/ directory (35 markdown files) is the institutional memory.
```

### Checklist (all checked)

- [x] I have checked that this resource hasn't already been submitted
- [x] It has been over one week since the first public commit to the repo I am recommending **(verify on submission date — must be on or after 2026-05-28)**
- [x] All provided links are working and publicly accessible
- [x] I do NOT have any other open issues in this repository
- [x] I am primarily composed of human-y stuff and not electrical circuits

## Pre-submission verification (run on submission day)

```bash
# 1. Confirm the 1-week clock has elapsed
git -C /Users/dima/Documents/Projects/dotclaude log --reverse --format="%ai %h" | head -1
# Output should show 2026-05-20 or earlier; today must be >= 2026-05-28

# 2. Confirm no other open issues on the target
gh issue list --repo hesreallyhim/awesome-claude-code --author vindm --state open
# Output should be empty (per checklist requirement)

# 3. Confirm CI is green on dotclaude main
gh run list --repo vindm/dotclaude --limit 1
# Output should show "success"

# 4. Confirm anonymization guard passes
bash /Users/dima/Documents/Projects/dotclaude/scripts/check-anonymization.sh
# Output should show "PASS"

# 5. Confirm both smoke-test reports are pushed to main
gh api repos/vindm/dotclaude/contents/docs/design-real-smoke-test-2026-05-21.md --jq '.name'
gh api repos/vindm/dotclaude/contents/docs/coding-real-smoke-test-2026-05-21.md --jq '.name'
```

All 5 should pass before opening the form.

## After submission

Per the target's flow:

1. The bot runs automated validation (well-formed-ness only, not a content review).
2. If validation passes, the submission enters the maintainer's queue. No timeline guarantee.
3. If approved, a PR is automatically created on the curated list.
4. Maintainer may ask follow-up questions; per CONTRIBUTING, *"If I raise any further questions about your project, it's usually because I'm interested in it, and want to understand it better."*

**Do NOT submit follow-up issues or comments aggressively.** The CONTRIBUTING document is explicit that the maintainer's obligation ends at recommendation receipt.

## If rejected or stuck in queue

Backup distribution channels (independent of awesome-claude-code):
1. Twitter/X post with the demo gif (target audience: Claude Code dev community).
2. Anthropic's Discord (`#community-projects` if it exists, or general).
3. HackerNews — Show HN submission (timing matters: Tue/Wed mornings PST historically perform best).
4. Submit to `VoltAgent/awesome-claude-code-subagents` as the narrower fit (subagent emphasis).
5. Direct outreach to influential Claude Code users (Simon Willison, etc.) — only if they've publicly engaged with similar tools.

Do NOT spam multiple awesome-lists with the same submission simultaneously — each list has its own review queue and the duplication signal is negative.
