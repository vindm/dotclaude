# file-discipline — designing file-size limits and the override convention

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, you read this doc to decide whether file-size discipline is worth enforcing in the user's project — and if so, what the ceiling should be and how the override convention should work.

## When to ship one (applicability gate)

Ship a file-size rule (+ companion hook from `hook-templates/check-file-size.sh`) when:

- The project has source files > 800 LOC already in main branches.
- The project's stack typically grows files (React components, controller classes, Rails models, Django views often accrete).
- The user wants Claude Code to participate in decomposition discipline (otherwise, files quietly grow because every individual edit looks justifiable).

Skip when:

- The codebase is uniformly < 300 LOC per file already. The discipline is internalized; the rule adds friction without value.
- The dominant file type is auto-generated (DB types, GraphQL types, protobuf bindings). Rule applies to the generated files; you'd just be writing exemptions.
- The user pushes back hard against any line-count ceiling. Forced discipline against the user's instinct produces noise, not signal.

When in doubt, ship the rule with a generous ceiling. A 1500-LOC ceiling is still useful; a 600-LOC ceiling on a codebase that averages 200 LOC adds zero friction and catches outliers.

## Why it matters — what this catches

File-size discipline is a **proxy for cognitive-load discipline**. A 2000-LOC file is, in practice, ALWAYS:

- Too expensive for an LLM to re-read on every edit. Claude pays tokens to load context that's already there but bloated.
- Too hard for a human reviewer to hold in their head. Parallel-path drift between sibling code blocks in the same file goes unnoticed because the reviewer's working memory has tapped out.
- A signal that the file is doing too many things. State machines past ~400 LOC, persistence pipelines past ~600 LOC, screens past ~800 LOC stop being legible. Continuing to add to them costs more per change than decomposing once.

The cost asymmetry is the argument: **decomposition is paid once; editing-a-bloated-file is paid every change forever.**

What an LLM-callable rule catches that lint typically doesn't: lint can be configured to enforce file size, but the rule lives in `.claude/` so that Claude Code — when proposing an edit that would push a file over — proactively decomposes instead of just adding lines. The companion hook (`hook-templates/check-file-size.sh`) is the edit-time enforcement; this rule is the methodology Claude reaches for when the hook fires.

## Core methodology — picking the ceiling

The right ceiling varies by stack and language. Defaults based on observed practice:

| Stack | Typical ceiling | Why |
|---|---|---|
| TypeScript / JavaScript (React, Node) | 1000 LOC | Idiomatic React screens with hooks, JSX, callbacks accrete fast. 1000 is generous; 500 is aggressive. |
| Python | 500 LOC | Idiomatic Python files are tighter (no JSX, less framework boilerplate). |
| Swift / Kotlin (mobile native) | 600 LOC | View controllers and ViewModels grow; this catches the worst offenders. |
| Rust | 1500–2000 LOC | Crates with many types in one module are idiomatic. Higher ceiling. |
| Go | 800 LOC | Go's per-file convention is "one cohesive thing" — 800 catches drift without being punitive. |
| Java / C# / Kotlin (backend) | 1000 LOC | Class-per-file convention naturally bounds; 1000 is the outlier-catcher. |
| HTML / templates / Vue SFC / Svelte | 600 LOC | Single-file components want strict ceilings; bloated SFCs become unreviewable. |
| SQL / migration files | 1000 LOC for schema dumps; 200 LOC for hand-written migrations | Hand-written migrations should be tight; dumps are auto-generated. |
| Markdown / docs | No ceiling | This rule is for source. |

These are starting points. The actual ceiling should be calibrated against the project's current distribution: look at `find . -name '*.<ext>' -not -path './node_modules/*' | xargs wc -l | sort -rn | head -20` for the worst offenders and set the ceiling at the *95th percentile of healthy files* plus a small buffer.

## How to derive THIS project's specifics

Before authoring the rule, audit the codebase:

1. **Run `wc -l` over source files** and look at the distribution:
   ```bash
   find . -path ./node_modules -prune -o -name '*.<ext>' -print | xargs wc -l | sort -rn | head -30
   ```
   The right ceiling is where most healthy files sit + comfortable margin. Don't pick a ceiling that the codebase already routinely violates — you'll just produce constant noise.

2. **Identify auto-generated files** that need exemption. Common patterns:
   - DB type files (`database.types.ts`, `schema.ts` generated from Prisma / Drizzle / Supabase)
   - GraphQL codegen output (`generated.ts`, `types.gen.ts`)
   - Protobuf / OpenAPI generated clients
   - Snapshot files (`__snapshots__/`)
   - Test fixtures with recorded data
   - Anything with `// AUTOGENERATED` or `@generated` headers

   Encode the exemption list explicitly. Don't blanket-exempt a directory if only some files in it are generated.

3. **Identify legitimate large-file types** the user prefers not to decompose:
   - Long config files (Tailwind config, project-wide constants)
   - Single-source-of-truth lookup tables
   - State-machine definitions that are atomic by intent

4. **Pick the warning threshold.** Hook templates usually warn at ceiling × 0.95 (e.g., 950 if ceiling is 1000). This gives the dev a chance to decompose before they hit the hard limit. If the user has explicit opinions ("warn me at 80% so I have time"), respect them.

5. **Decide the override convention.** Override mechanisms vary; pick one:
   - **Per-line override comment** (`// allow-size: <reason>` or similar). Rare; only for files that the user has consciously decided to grow.
   - **Per-file override header** (a sentinel comment near the top). For files like state-machine definitions.
   - **Exemption list** in the hook script itself, by path pattern.

   The override convention should require a written reason. "I overrode the limit because the reason is X" is one keystroke more than `// allow-size:` alone — and the reason is what makes the override auditable later.

## Authoring the rule

The final rule file (typically `.claude/rules/file-discipline.md`) should answer:

1. **What is the ceiling?** A specific number, per file type if needed.
2. **Why this ceiling specifically?** One paragraph; the user should be able to defend it to a teammate.
3. **What does decomposition look like?** A short table of extraction patterns (this stack's typical patterns — pure helpers, sub-components, type modules, etc.). See `decomposition.md` for the methodology; the rule file should reference it, not duplicate it.
4. **What's the override convention?** The exact comment syntax + the rule that every override carries a reason.
5. **What's exempt?** The list of auto-generated patterns + any legitimate large-file types.
6. **What does "decompose now" mean?** Crucially: the decomposition lands in the same PR as the work that pushed the file over. Not a backlog item, not a follow-up ticket.

## Companion hook — the enforcement teeth

The rule alone is advisory. The companion hook (`hook-templates/check-file-size.sh`) is the enforcement: it fires on Edit / Write and blocks (or warns) when a file exceeds the ceiling. The rule and the hook are paired — ship both or neither.

When configuring the hook:
- Substitute the ceiling value (the number you picked above).
- Substitute the warning threshold.
- Substitute the file-extension patterns that the hook should check.
- Substitute the exemption list (paths the hook should skip).

The hook itself stays generic; only the config substitutions are project-specific. See `hook-templates/check-file-size.sh` for the substitution markers.

## Don't-game-the-rule clauses

The rule should explicitly call out the games people play to avoid genuine decomposition:

- **`// eslint-disable-next-line` over the file-size check.** No. If you'd disable the rule, you'd also dismiss the underlying signal — decompose instead.
- **Barrel files (`index.ts` re-exporting one giant internal file).** No. The internal file is still bloated; you've just hidden the count behind an export.
- **Splitting a function across files purely for line count.** No. The split must be at a natural cognitive boundary, not an arbitrary cut.
- **Adding helper files that are 5 LOC each just to drain the parent's count.** No. The decomposition should produce 2–4 sibling files of 100–500 LOC each, not 20 micro-files.

Naming these games in the rule is the cheapest defense. The user reads them and recognizes the temptation when it surfaces.

## Cross-references

- `decomposition.md` — the skill that runs when a file approaches the ceiling. The rule says *what*; the skill says *how*.
- `code-review.md` — the agent should treat a 950-LOC file (close to ceiling) as a red flag in any change touching it.
- `hook-templates/check-file-size.sh` — the edit-time hook. Wire it; the rule is toothless without it.

## Anti-patterns in the rule you write

- **Picking a ceiling lower than the codebase's current 95th percentile.** Constant red squiggles. Devs stop trusting the rule. Set the ceiling at *current healthy distribution + buffer*, and let it stay there as the codebase tightens.

- **No exemption list.** The first time the hook fires on `database.types.ts` and refuses to merge, the user adds `// allow-size:` overrides everywhere and the discipline collapses. Encode exemptions up front.

- **Rule with no companion hook.** Advisory rules without edit-time enforcement do nothing; everyone forgets they exist. Either ship the rule with the hook wired, or don't ship the rule.

- **Override mechanism that doesn't require a reason.** `// allow-size:` alone tells the future reviewer nothing. `// allow-size: shared lookup table, not decomposable` tells them the override is principled. The reason field is the audit trail.

- **Decomposition deferred to "follow-up PR."** Follow-up PRs don't happen. The rule must say: decomposition lands in the same change. If you can't decompose now, the change is the wrong scope.

- **One ceiling for a polyglot codebase.** A 1000-LOC ceiling makes sense for TS, is too strict for Rust, and is too loose for Python. Configure per-extension if the project is polyglot.
