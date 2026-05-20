---
name: decompose-file
description: Use when a file approaches or exceeds {{fileSize.ceiling}} LOC. Guides natural-seam identification and split.
---

# Decompose file

When `check-file-size` blocks or warns, use this skill to find natural seams.

## Pre-decomposition checklist

1. Read the whole file once.
2. Map the responsibilities: what does this file ACTUALLY do? List them.
3. Are responsibilities orthogonal, or coupled? If coupled, decomposition won't help — refactor the abstraction first.

## Decomposition patterns

- **Pure helpers** → extract to `helpers/` sibling directory
- **Types & interfaces** → extract to `types.ts` sibling
- **State machines / stores** → keep together; don't split
- **Parallel concerns** → if a file does X for A and X for B (where A and B differ), split by domain not by operation

## Test discipline during decomposition

- Tests should pass before, during (per commit), and after.
- One commit per extraction.
- Run the full suite between commits.

## When NOT to decompose

- File is 1100 LOC of auto-generated types
- The split would create a circular import dependency
- The "natural seam" is actually a leaky abstraction (fix the abstraction instead)
