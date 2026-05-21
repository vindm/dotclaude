# Contributing to dotclaude

Thanks for your interest. dotclaude is opinionated: it ships a specific methodology distilled from one battle-tested codebase. Contributions that strengthen the methodology are welcome; contributions that broaden scope or dilute focus may be politely declined.

## Project structure

| Path | What lives there |
|---|---|
| `.claude-plugin/` | Plugin manifests (`plugin.json`, `marketplace.json`). |
| `skills/` | The 8 slash-command skills — `init`, `bootstrap`, `design`, `coding`, `planning`, `testing`, `data`, `ai-workflow`. Each is `SKILL.md` + `interview.md` (where applicable). |
| `principles/` | 35 methodology docs read on-demand by skills (single-source-of-truth: skills cite, never duplicate). |
| `hook-templates/` | 12 reusable shell hooks (Mustache-configurable, plugin-agnostic core logic). |
| `examples/` | 4 anonymized war stories (~400 words each) demonstrating where the methodology came from. |
| `docs/` | Analysis docs — v2-vision, smoke-test reports, audits. |
| `assets/` | Logo SVG. |
| `demo/` | VHS tape sources + rendered gifs for the README. |
| `scripts/check-anonymization.sh` | Pre-push leak guard; mirrored in CI. |

## How to contribute

### Add a principle

Drop a markdown file in `principles/<name>.md` matching the structure of existing principles. Required sections:

- **Applicability gate** — when this principle applies (and when it doesn't).
- **Why it matters** — the failure mode this prevents, with a concrete cost.
- **Core methodology** — the abstract pattern (project-agnostic).
- **Derive specifics for your project** — interview questions a skill should ask to instantiate the pattern.
- **Authoring guidance** — what gets written into `CLAUDE.md` / `.claude/` / `docs/`.
- **Depth signatures** — what S-tier vs A-tier vs B-tier output looks like.
- **Rubric** — how to grade the result.
- **Cross-references** — related principles + skills that consume this one.
- **Anti-patterns** — what failure looks like.

Cross-reference from any skill that should read it.

### Add a hook template

Drop a `.sh` in `hook-templates/` with Mustache placeholders (`{{ PROJECT_VAR }}`) for config values. Hooks must:

1. Be project-agnostic in core logic — no hardcoded paths, names, or assumptions.
2. Take config via Mustache substitution at install time (skills handle interpolation).
3. Be safe to run on every `Edit` / `Write` / `Bash` event without side effects beyond logging or exit code.
4. Exit `0` on pass, `2` on block, `1` on warn. Stderr is shown to Claude; stdout is silent.
5. Include a brief header comment explaining what classes of mistake the hook prevents.

### Add a domain skill

Create `skills/<name>/SKILL.md` plus `skills/<name>/interview.md` matching the canonical reference `skills/design/`. Skills must:

1. Have a clear **applicability gate** in the frontmatter description — when Claude should auto-load this skill.
2. Walk the canonical **5 phases**:
   - Phase 1 — project scan (read repo to ground decisions in actual code).
   - Phase 2 — interview (ask AskUserQuestion blocks; never a wall of text).
   - Phase 3 — read relevant principles (cite, don't duplicate).
   - Phase 4 — author artifacts.
   - Phase 5 — stage to `.claude-staging/` for user review, never directly to `.claude/`.
3. Cite project's actual file paths in the output (not generic `src/components/`).
4. Cross-reference the principles it consumes.

### Add a war story

Drop a ~400-word debugging narrative in `examples/<slug>.md`. Required sections:

- **Symptom** — what looked broken from the outside.
- **Root cause** — what was actually wrong.
- **Diagnostic that worked** — the specific move that made it visible.
- **Lesson** — the methodology principle this derives.
- **Derived discipline** — the rule / hook / skill that now prevents recurrence.

Story should be anonymized — no proper nouns from real projects, no real customer / employer / colleague names.

## Anonymization is enforced

The repo has a strict deny-list (see `scripts/check-anonymization.sh`):

```
opengym, intel-gym, rex, bali, omni, obsidian, gymnasium, genki, vinokuroff.dm
```

Plus any specific project, customer, or company names should be replaced with generic placeholders (`<project>`, `<customer>`, `<the gym>`, etc.).

Run before pushing:

```bash
bash scripts/check-anonymization.sh
```

The CI workflow `.github/workflows/anonymization-guard.yml` re-runs this on every push and blocks merge on failure.

## Smoke test before claiming a principle works

For new principles or skills, run a smoke test:

1. Pick a real project (or a fresh fixture).
2. Have Claude execute the new skill or principle against it.
3. Compare output to expected battle-tested depth — the standard is what an experienced senior engineer would author after a week of grokking the codebase, not a generic template fill.
4. Document gaps as P0 / P1 follow-ups in a `docs/<slug>-smoke-test-YYYY-MM-DD.md` report.

See `docs/design-real-smoke-test-2026-05-21.md` and `docs/coding-real-smoke-test-2026-05-21.md` as canonical examples. The shape:

- What was tested + how.
- Authored output + LOC delta.
- Side-by-side comparison with what the source project actually shipped.
- Gaps classified P0 / P1 / P2.
- Verdict: ready / ready-with-followups / not-ready.

## Pull request checklist

- [ ] Anonymization guard passes locally (`bash scripts/check-anonymization.sh`).
- [ ] `CHANGELOG.md` updated with the change (date + one-line description).
- [ ] If new principle / skill / hook template — smoke test report added under `docs/`.
- [ ] No emojis except where explicitly stylistic (logo wordmark, README table icons, demo gif content).
- [ ] No new runtime dependencies (plugin is zero-dep — keep it that way).
- [ ] No new files > 1000 LOC.
- [ ] No raw hex colors in any markdown / shell — semantic placeholders only.

## What we'll politely decline

- **Contributions that broaden scope to non-Claude-Code AI assistants** (Cursor, Continue, Codex CLI, Aider, etc.). dotclaude is Claude-Code-native; cross-tool support dilutes the methodology.
- **Generic / templated content.** The methodology is specifically the project-specific derivation pattern. "Here's a one-size-fits-all CLAUDE.md template" is the opposite of what we ship.
- **Tooling that requires a runtime dependency.** The plugin authors files; it doesn't ship a binary. Anything that needs `npm install` or `pip install` lives elsewhere.
- **Tests for skills themselves.** Skills are prose; their value emerges from Claude executing them against a real project. Unit-testing prose is theater. Use smoke tests instead.
- **Per-language stack kits** (`/dotclaude:python`, `/dotclaude:rust`, etc.). Domain kits are horizontal (coding, testing, data, design); language-specific is too narrow and ages badly.

## Local dev install

```bash
git clone https://github.com/vindm/dotclaude.git
cd dotclaude
claude --plugin-dir .
```

Then `/dotclaude:bootstrap` (and the other 7 commands) are available in any other project Claude Code opens against this checkout.

To iterate on a skill, edit the file in `skills/<name>/SKILL.md` and re-run the slash command in a target project — Claude re-reads the file each invocation.

## License

MIT. By contributing, you agree your contributions are licensed under the same terms.
