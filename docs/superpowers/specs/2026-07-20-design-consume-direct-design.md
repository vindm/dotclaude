# Design plugin → consume-direct transformation

**Date:** 2026-07-20
**Status:** design, approved (brainstorm decisions locked)
**Author:** Dima Vinokurov (with Claude)

## Problem

The two-plugin split (merged `828cb49`, 2026-07-20) made `coding`/`testing` consume-direct: the generator elicits human intent, writes a thin artifact, and the CONSUMED agent reads it at runtime. The `dotclaude-design` plugin was assumed to already work this way — but the final whole-branch review found it does not. `/dotclaude:design` Phase 4 "Author the kit" still **generates project-local copies of the 7 design agents** (`ux-reviewer`, `a11y-audit`, `interaction-audit`, `flow-auditor`, `pages-audit`, `product-designer`, `design-token-auditor`) — the exact anti-pattern the redesign kills everywhere else. The agents also rot, and the contract doc over-promised design parity.

## Key finding that shapes the fix

The 7 consumed design audits **already self-adapt at runtime** — every one opens with "Discover THIS project at runtime — don't hardcode" and reads (a) the project's north-star / quality-bar doc for benchmarks and (b) the project's real theme/token source for tokens and contrast. So the generated copies are pure redundancy; the audits never needed them.

What the audits genuinely consume is two pieces of un-derivable / digest project data:
1. **The north-star** — named benchmarks + per-surface chrome references + voice/banned-phrases + past design bug classes. Not in the code.
2. **A design-system reference digest** — tokens / primitives / motion / status colors / library gotchas, aggregated so UI agents don't re-derive the design system on every dispatch. (A convenience digest of the project's real design-system files, not a copy of a plugin agent.)

## Decisions (locked in brainstorm)

1. **Discovery model: keep loose runtime discovery.** The audits keep finding the north-star / design-system docs by runtime search ("a north-star file, a CLAUDE.md section, a design-system doc — derive paths, never hardcode"). This already works and is more robust for design, whose docs live in varied project-specific places. Design does NOT join the `dotclaude.yml` artifacts-map that `coding`/`testing` use — the contract doc is made honest about this instead.
2. **Artifact scope: two artifacts.** The design skill writes both `design-north-star.md` (benchmarks/voice/bugs) and `design-system.md` (the 11-section digest). Both are project data the audits read — neither is an agent copy. The interview shrinks to only the knobs that feed these two.

## Target state

`/dotclaude:design` becomes **elicitation-only**:

- **Phase 4 "Author the kit" → "Write the artifacts".** It writes exactly two files to `.claude/rules/` (where the audits already search + where bootstrap writes the quality bar):
  - `.claude/rules/design-north-star.md` — Tier 1 + Tier 2 benchmarks, per-surface chrome-reference table, voice + `BRAND_BANNED_PHRASES`, project-specific design anti-patterns mined from git.
  - `.claude/rules/design-system.md` — the eleven-section design-system digest.
- **Removed from Phase 4:** authoring the 7 agent copies; authoring `audit-routing.md` / `visual-verification.md` rules (those are consumed principles now). The `check-design-tokens.sh` hook wiring stays (it is project config, analogous to `coding` writing `dotclaude.yml`).
- **Interview shrinks** from 10 phases / ~39 knobs to only what feeds the two artifacts: benchmarks (Phase B), voice (Phase C), per-surface/arc scoping (Phase D), design-system vocabulary, and the git-mined past-bug phase. Drop the knobs that only tuned generated-agent internals.
- **Consumed audits keep loose discovery** — add "read the project's design-system reference doc if present" to each audit's runtime-discovery list so they pick up the digest; no other agent change. The north-star discovery they already have.
- **Doc reconciliation:**
  - `plugins/core/docs/artifact-contract.md` — the design row states the two artifacts live at `.claude/rules/` and are found by runtime discovery (explicitly NOT via the `dotclaude.yml` artifacts map). Keep the coding/testing rows unchanged.
  - `plugins/core/skills/bootstrap/SKILL.md` — stop authoring the design north-star (a monolith-era assumption); its quality-bar phase points the user at the `dotclaude-design` plugin's `/dotclaude:design` for the design north-star.
  - The design skill's frontmatter description and `plugins/design/README.md` — reworded from "authors a tailored kit of design audit agents" to "elicits the project's design north-star + design-system reference that the consumed audits read at runtime."

## Non-goals

- Not changing the audits' grading methodology — only their runtime-discovery list (add the digest).
- Not joining the `dotclaude.yml` artifacts map (decided against).
- Not touching `deferred/`.
- Design agent/skill counts stay 7 agents / 5 skills — the agents are the same consumed ones, just no longer copied per project.

## Verification

- No `.claude-staging/agents/` authoring remains in `plugins/design/skills/design/SKILL.md` (grep for agent-authoring instructions → only "do NOT author" guards).
- The skill's Phase 4 writes both `.claude/rules/design-north-star.md` and `.claude/rules/design-system.md`.
- Each design audit's runtime-discovery text mentions the design-system reference doc.
- `artifact-contract.md` design row no longer claims the `dotclaude.yml` map or the fiction `.claude/dotclaude/design-north-star.md` path.
- `plugins/design/` loads via `claude --plugin-dir`; counts unchanged (7 agents / 5 skills).
