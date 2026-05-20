# Audit routing

When the user asks for a UI / UX / design audit, route deterministically to the right agent. The wrong agent on the wrong question produces a misleading verdict.

## The pipeline

For a multi-screen arc with non-trivial UI:

```
1. token-auditor       (regex sweep — raw hex, non-token colors)
2. semantic-audit + a11y-audit   (parallel — chrome integrity + accessibility)
3. visual-reviewer     (last — visual polish, after steps 1-2 may shift layout)
```

Reversing this order forces the visual reviewer to redo work after semantic/a11y fixes move things around.

## Routing table

| Question shape | Agent |
|---|---|
| "Is this one screen visually polished?" | `ux-reviewer` |
| "Does the chrome promise match the handler?" | `interaction-audit` |
| "Is this accessible?" | `a11y-audit` |
| "Sweep for raw hex" | `design-token-auditor` |
| "Pre-implementation validation" | `pre-flight` |
| "Post-implementation review" | `code-reviewer` |

## See also

- The audit pipeline pattern is what makes "shipping with AI agents" safe at team scale. Hooks block at edit time; agents validate at task completion.
