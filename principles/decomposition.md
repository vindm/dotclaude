# decomposition — designing a skill that decomposes a bloated file

Teaching material for Claude Code. When the user runs `/dotclaude:init`, you read this doc to learn HOW to author the decomposition skill that fits THEIR stack. Pair with `file-discipline.md` — that's the rule (what to enforce); this is the skill (how to do the work when the rule fires).

## When to ship one (applicability gate)

Ship a decomposition skill when:

- You also shipped `file-discipline.md` (and its companion hook). The skill is what the user invokes when the hook warns.
- The project's stack has stable extraction patterns (most do — hooks, components, types, pure helpers, modules).

Skip when:

- File-size discipline isn't being enforced. No hook → no signal → no use for a decomposition skill.
- The project is a single-language tiny utility where decomposition is "just move 50 lines."

## Why it matters — what this catches that nothing else does

Decomposition is a skill-shaped task because it has a **wrong way that looks right**. The wrong way:

- Extract aggressively into 8 micro-files. Now navigation is worse; nothing is comprehensible in isolation.
- Extract on textual seams (random cut at line 500) rather than cognitive seams (the hook, the sub-component, the pure helper).
- Hide the file behind a barrel `index.ts` that re-exports a still-bloated internal module.
- Split a function across files purely to drain line count.

A skill encodes the *right* way: identify natural seams, extract at those seams in a particular order, verify the parent is now under the ceiling, run the test suite to confirm nothing broke. The skill is the institutional memory of "we tried the wrong way and learned what the right way looks like."

This is also a skill that benefits hugely from **user approval before executing**. Decomposition rewrites file structure; the user wants to see the plan before code moves. A skill enforces that handshake.

## Core methodology — the natural-seam doctrine

The principle is: **extract at cognitive boundaries, not at textual boundaries.** A 1500-LOC React screen is not "the top 750 lines" + "the bottom 750 lines." It is, more usefully:

1. A few hooks bundling state + effects + callbacks for distinct concerns
2. One or more sub-components that render large JSX subtrees
3. A handful of pure helper functions transforming data
4. Maybe a types module if inline types exceed ~50 LOC

Each of these has a natural file. The skill identifies them, names them, and proposes the extraction.

### Extraction-pattern table (per stack)

The skill's core asset is a table mapping bloated-file shapes to extraction targets. Examples by stack:

**React / React Native (TypeScript):**
| Pattern in the bloated file | Extract to |
|---|---|
| Stateful effect + refs + callbacks scoped to one feature | `useFeature.ts` hook |
| > 100 LOC sub-component inside a screen | `<ChildComponent>` in its own file |
| Pure transformation function + helpers | `lib/.../operations/<verb>.ts` module |
| > 50 LOC of inline types | sibling `types.ts` |
| Per-action dispatch / handler bundle | `useFeatureHandlers.ts` returning `{ handle*, state }` |

**Python (Django / FastAPI):**
| Pattern | Extract to |
|---|---|
| > 5 view functions in one file | split by domain into `views/<domain>.py` |
| Long serializer / schema definitions | `serializers/<resource>.py` or `schemas/<resource>.py` |
| Pure validation helpers | `validators.py` or `helpers/<topic>.py` |
| Repeated query patterns | `selectors.py` or `repositories/<resource>.py` |

**Go:**
| Pattern | Extract to |
|---|---|
| Multiple HTTP handlers in one file | `handlers_<resource>.go` |
| Long type-method blocks for one struct | `<struct>_methods.go` |
| Pure helpers | `helpers.go` or topic-named file in same package |

**Rust:**
| Pattern | Extract to |
|---|---|
| Multiple impl blocks for one type | split impls into `<type>/impl_<aspect>.rs` |
| Trait definitions intermixed with impl | `traits.rs` |
| Test module larger than the code module | `tests.rs` or `tests/` directory |

These tables are guidance. Derive THIS project's specific extraction-pattern table from how the user's codebase already organizes itself when files stay healthy.

### Order of operations

When a file genuinely needs decomposition, the order matters:

1. **Hooks / state-bearing logic first.** This is the most-coupled extraction; doing it first reduces the parent's surface area for subsequent extractions.
2. **JSX sub-components / view modules second.** These usually pull cleanly once hooks have been extracted.
3. **Pure helpers last.** These are the easiest extraction (no closure dependencies); save them for the tail of the work.

Reversing this order — extracting pure helpers first — leaves the bloated stateful body untouched and produces little useful drain on the parent's LOC count.

## How to derive THIS project's specifics

Before authoring the skill, look at how the user's project already decomposes when files stay healthy:

1. **Find pairs of `<X>.tsx` + `useX.ts` files.** This signals the user already uses the hook-extraction pattern; the skill should follow that convention.
2. **Find `lib/<domain>/operations/` or `lib/<domain>/helpers/` directories.** This signals pure-helper extraction is established; encode the path convention.
3. **Find `types.ts` siblings.** This signals the user separates types when they grow; replicate.
4. **Find sub-component directories** (e.g., `<Screen>/components/`). This signals the JSX-extraction convention.

The skill's extraction-pattern table should mirror the user's existing convention, not impose a different one. If the user puts pure helpers in `lib/utils/`, the skill says `lib/utils/`, not `lib/operations/`.

## Authoring the skill

The skill file (typically `.claude/skills/decompose-file/SKILL.md`) should orchestrate this workflow:

### Step 1 — Read and classify

The skill reads the whole file, identifies which patterns from the extraction table apply, and notes approximate LOC per identified chunk.

### Step 2 — Propose the split (don't edit yet)

The skill produces a plan in this shape:

```
File: <path> (<N> LOC)

Proposed split:
1. <hook 1> → <new path> (~<LOC> LOC)
2. <hook 2> → <new path> (~<LOC> LOC)
3. <subcomponent> → <new path> (~<LOC> LOC)
4. <pure helpers> → <new path> (~<LOC> LOC)

Resulting parent file: ~<LOC> LOC
```

Sanity checks before presenting:
- Each new file should land 100–500 LOC. Chunks < 30 LOC → fold back, don't create a tiny file.
- The parent file should hold composition + JSX root + non-extractable wiring only.
- If the parent stays > 80% of the ceiling after the split, the feature is genuinely two features — flag conceptually, ask whether to split into sibling features.

### Step 3 — Get approval, then execute

Wait for the user to confirm or amend. After approval:

1. Create new files one at a time.
2. After each extraction, run the line-count check on the touched files.
3. After all extractions, run lint + tests on the touched files.
4. Verify the parent is under the ceiling; iterate if not.

### Step 4 — Don't game the rule

The skill should refuse to:
- Add `// disable-next-line` over the file-size check.
- Create barrel `index.ts` files re-exporting one bloated internal module.
- Split a function across files arbitrarily to dodge the count.

If any of these are tempting, the right answer is "this feature is two features" — split conceptually.

## When NOT to decompose

The skill should refuse politely on certain inputs:

- **Auto-generated files** (`database.types.ts`, `*.gen.ts`, anything with `// AUTOGENERATED` or `@generated` header). The decomposition would just be re-done on next codegen.
- **Test fixtures** with raw recorded data. They're tabular; line count is incidental.
- **Snapshot files** (`__snapshots__/`). Snapshots are atomic by definition.
- **Files where every extraction candidate is < 30 LOC.** The "decomposition" would produce useless micro-files. The right action might be to consolidate, not split — or to accept that the file is fine.

If the user invokes the skill on one of these, the skill should point this out and not proceed.

## Skill output shape

A decomposition skill is a `disable-model-invocation: true` skill — it's user-invoked (`/decompose-file <path>` or similar), not auto-loaded. Why: the operation is structural, the user should explicitly opt in, and the approval gate at Step 3 is part of the value.

The skill's first action is always to verify the input file exists and is over the ceiling. If under, refuse — there's no work to do.

## Cross-references

- `file-discipline.md` — the rule this skill enforces. The ceiling number and the override convention live there.
- `code-review.md` — should flag files near ceiling in any change touching them.
- `hook-templates/check-file-size.sh` — the edit-time hook that surfaces "needs decomposition" warnings.

## Anti-patterns in the skill you write

- **Decomposing without showing the plan first.** The user must see the proposed split before files move. The approval gate is structural; skipping it produces churn and resentment.

- **5-file fragmentation.** Aiming for 2–4 sibling files is sweet spot. 5+ files for one decomposition means either the original was 3000+ LOC (in which case the user should manually break it down conceptually first), or the skill is over-extracting.

- **Skipping the post-extraction verification.** Lint + tests + line-count must run after extraction completes. Without the verification, "decomposition done" is unverified and silent bugs (broken imports, missing exports) ship.

- **Following extraction-pattern dogma over project convention.** If the user puts pure helpers in `lib/utils/` and the skill insists on `lib/operations/`, the user has to fight the skill. Mirror the project's existing convention.

- **Not surfacing the "two features" diagnosis.** When the parent file stays bloated after every reasonable extraction, the skill should say "this is two features, not one — consider splitting conceptually" rather than fighting harder for a tighter cut.

- **Refusing on exemption files silently.** When the skill won't proceed (auto-generated, snapshot, fixture), say WHY explicitly. The user invoked the skill because they thought work needed doing — if it doesn't, they need to know why.
