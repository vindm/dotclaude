# Domain artifact contract

A domain elicitation skill writes ONE thin, human-readable markdown file per
project. The consumed agent reads it at runtime. No agent is generated.

| Domain | Artifact | Written by | Read by |
|---|---|---|---|
| coding | `.claude/dotclaude/code-anti-patterns.md` | coding elicitation | `code-review` agent |
| testing | `.claude/dotclaude/test-risk-model.md` | testing elicitation | `test-architect` agent |
| design | `.claude/dotclaude/design-north-star.md` | design north-star elicitation | `ux-audit`, `flow-audit`, `pages-audit` |

Rules:
- The artifact holds ONLY elicited human intent (bug classes, risk priorities,
  benchmark apps) — never a copy of the agent's methodology.
- Every artifact is optional. Absent → the agent falls back to the generic
  methodology in its `principles/<name>.md`. Present → each entry is a
  project-specific check layered on top of the generic pass.
- `dotclaude.yml` records the path under an `artifacts:` map so the agent can
  locate it without a hardcoded convention.
