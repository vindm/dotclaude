# File discipline

No file in this repo should exceed **{{fileSize.ceiling}} LOC**. The `check-file-size` hook enforces this at edit time.

## Why this matters

You reason best about code you can hold in context at once. Past ~1000 LOC, comprehension degrades, edits become unreliable, and parallel-path drift sets in.

## What to do when a file approaches the ceiling

1. **Look for natural seams.** A file doing two unrelated things should become two files.
2. **Extract pure helpers.** Stateless transforms can live in a `helpers/` subdir.
3. **Split types from logic.** Move interfaces to a `types.ts` sibling.
4. **Use the `decompose-file` skill** for guided refactoring.

## Exemptions

Auto-generated types are the only exemption. Use `// allow-size: generated` on the first line for clarity.
