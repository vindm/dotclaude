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

Note — design's north-star is NOT part of this map. `design`'s quality-bar
elicitation writes `.claude/rules/design-north-star.md` (see the design
skill's Phase 4 and `bootstrap/SKILL.md`'s "Quality bar" section), and the
design audit agents (`ux-audit`, `flow-audit`, `pages-audit`,
`product-designer`) find it via loose runtime discovery — searching for "a
north-star file, a CLAUDE.md section…" — rather than a hardcoded path or the
`dotclaude.yml` artifacts map above. Folding design into the map is pending
the design-skill transformation; until then, treat this as a separate,
looser contract.
