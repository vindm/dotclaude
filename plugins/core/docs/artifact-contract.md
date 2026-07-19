# Domain artifact contract

A domain elicitation skill writes ONE thin, human-readable markdown file per
project. The consumed agent reads it at runtime. No agent is generated.

| Domain | Artifact | Written by | Read by |
|---|---|---|---|
| coding | `.claude/dotclaude/code-anti-patterns.md` | coding elicitation | `code-review` agent |
| testing | `.claude/dotclaude/test-risk-model.md` | testing elicitation | `test-architect` agent |

Rules:
- The artifact holds ONLY elicited human intent (bug classes, risk priorities,
  benchmark apps) — never a copy of the agent's methodology.
- Every artifact is optional. Absent → the agent falls back to the generic
  methodology in its `principles/<name>.md`. Present → each entry is a
  project-specific check layered on top of the generic pass.
- `dotclaude.yml` records the path under an `artifacts:` map so the agent can
  locate it without a hardcoded convention.

Note — design's artifacts are NOT part of this map, by design. The
`dotclaude-design` plugin's `/dotclaude:design` elicitation writes TWO thin
artifacts — `.claude/rules/design-north-star.md` (named benchmarks, voice,
project-specific anti-patterns) and `.claude/rules/design-system.md` (the
eleven-section design-system reference digest) — see the design skill's
Phase 4. The consumed design audits (`ux-audit`, `a11y-audit`,
`interaction-audit`, `flow-audit`, `pages-audit`, `design-token-audit`,
`product-designer`) find both via loose **runtime discovery** — each opens
by searching for "a north-star file, a design-system reference, a CLAUDE.md
section…" — rather than a hardcoded path or the `dotclaude.yml` artifacts
map above. This is a deliberate, permanent choice, not a stopgap awaiting a
later fold-in: discovery lets the audits work even when a project keeps its
rules doc at a nonstandard path, at the cost of the map's precision.
`plugins/core/skills/bootstrap/SKILL.md` does not author either design
artifact — that is `/dotclaude:design`'s job alone.
