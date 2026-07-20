# decomposition — designing a skill that decomposes a bloated file

Teaching material for Claude Code. Teaches you how to author the decomposition skill that fits THIS stack. Pair with `file-discipline.md` — that's the rule (what to enforce); this is the skill (how to do the work when the rule fires).

## When to ship one

Ship a decomposition skill when you also shipped `file-discipline.md` and its hook (the skill is what the user invokes when the hook warns) and the stack has stable extraction patterns (most do — hooks, components, types, pure helpers, modules). Skip when file-size discipline isn't enforced (no hook → no signal → no use) or when the project is a tiny single-language utility where decomposition is "just move 50 lines."

## Why it matters

Decomposition is skill-shaped because it has a **wrong way that looks right**: extract aggressively into 8 micro-files (navigation gets worse, nothing is comprehensible in isolation); cut on textual seams (line 500) instead of cognitive ones (the hook, the sub-component, the pure helper); hide the file behind a barrel `index.ts` re-exporting a still-bloated module; split a function across files purely to drain line count. The skill encodes the *right* way — identify natural seams, extract in a particular order, verify the parent is under the ceiling, run tests — as institutional memory of "we tried the wrong way and learned what the right one looks like." It also benefits hugely from **user approval before executing**: decomposition rewrites file structure, so the user wants to see the plan before code moves, and the skill enforces that handshake.

## Core methodology — the natural-seam doctrine

The principle: **extract at cognitive boundaries, not textual ones.** A 1500-LOC React screen is not "top 750 + bottom 750." It is, more usefully: a few hooks bundling state + effects + callbacks for distinct concerns; one or more sub-components rendering large JSX subtrees; a handful of pure helpers transforming data; maybe a types module if inline types exceed ~50 LOC. Each has a natural file; the skill identifies, names, and proposes the extraction.

### Extraction-pattern table (per stack)

The skill's core asset maps bloated-file shapes to extraction targets. The pattern is stack-independent; the targets are stack-specific. React / React Native (TypeScript):

| Pattern in the bloated file | Extract to |
|---|---|
| Stateful effect + refs + callbacks scoped to one feature | `useFeature.ts` hook |
| > 100 LOC sub-component inside a screen | `<ChildComponent>` in its own file |
| Pure transformation function + helpers | `lib/.../operations/<verb>.ts` module |
| > 50 LOC of inline types | sibling `types.ts` |
| Per-action dispatch / handler bundle | `useFeatureHandlers.ts` returning `{ handle*, state }` |

The same shapes map onto any stack — Python: > 5 views → `views/<domain>.py`, long serializers → `serializers/<resource>.py`, query patterns → `selectors.py`; Go: multiple handlers → `handlers_<resource>.go`, long method blocks → `<struct>_methods.go`; Rust: multiple impl blocks → `<type>/impl_<aspect>.rs`, traits → `traits.rs`, oversized test module → `tests/`. Derive THIS project's table from how the user's codebase already organizes itself when files stay healthy.

### Order of operations

When a file genuinely needs decomposition, order matters:

1. **Hooks / state-bearing logic first** — the most-coupled extraction; doing it first shrinks the parent's surface for the rest.
2. **JSX sub-components / view modules second** — these pull cleanly once hooks are out.
3. **Pure helpers last** — the easiest (no closure dependencies); save them for the tail.

Reversing this — helpers first — leaves the bloated stateful body untouched and barely drains the parent's LOC.

## How to derive THIS project's specifics

Look at how the project already decomposes when files stay healthy, and mirror that convention rather than imposing a different one:

1. **`<X>.tsx` + `useX.ts` pairs** → the hook-extraction pattern is established; follow it.
2. **`lib/<domain>/operations/` or `helpers/` directories** → pure-helper extraction is established; encode the path.
3. **`types.ts` siblings** → the user separates types when they grow; replicate.
4. **sub-component directories** (`<Screen>/components/`) → the JSX-extraction convention.

If the user puts pure helpers in `lib/utils/`, the skill says `lib/utils/`, not `lib/operations/`.

## Authoring the skill

The skill (typically `.claude/skills/decompose-file/SKILL.md`) is `disable-model-invocation: true` — user-invoked (`/decompose-file <path>`), not auto-loaded: the operation is structural, the user should opt in explicitly, and the Step 3 approval gate is part of the value. Its first action is always to verify the input file exists and is over the ceiling; if under, refuse — there's no work to do. It orchestrates:

**Step 1 — Read and classify.** Read the whole file, identify which extraction-table patterns apply, note approximate LOC per chunk.

**Step 2 — Propose the split (don't edit yet).**

```
File: <path> (<N> LOC)

Proposed split:
1. <hook 1> → <new path> (~<LOC> LOC)
2. <subcomponent> → <new path> (~<LOC> LOC)
3. <pure helpers> → <new path> (~<LOC> LOC)

Resulting parent file: ~<LOC> LOC
```

Sanity checks before presenting: each new file lands 100-500 LOC (chunks < 30 LOC fold back, don't create a tiny file); the parent holds composition + JSX root + non-extractable wiring only; if the parent stays > 80% of the ceiling after the split, the feature is genuinely two features — flag it and ask whether to split into sibling features.

**Step 3 — Get approval, then execute.** Wait for confirmation or amendment. Then create new files one at a time; after each, run the line-count check on touched files; after all, run lint + tests on touched files; verify the parent is under the ceiling, iterate if not.

**Step 4 — Don't game the rule.** Refuse to add a `// disable-next-line` over the file-size check, to create a barrel `index.ts` re-exporting one bloated module, or to split a function arbitrarily to dodge the count. If any of those tempts you, the honest answer is "this feature is two features" — split conceptually.

## When NOT to decompose

Refuse politely, and say WHY (the user invoked the skill expecting work — if there's none, they need the reason), on: **auto-generated files** (`*.gen.ts`, `@generated` / `// AUTOGENERATED` headers — codegen would redo it), **test fixtures** with raw recorded data (tabular; line count is incidental), **snapshot files** (`__snapshots__/` — atomic by definition), and **files where every extraction candidate is < 30 LOC** (decomposition would produce useless micro-files; consolidate or accept the file is fine).

## Acceptance — mistakes in the skill you write

- **No plan before code moves** — the Step 3 approval gate is structural; skipping it produces churn and resentment.
- **5+ files for one decomposition** — 2-4 sibling files is the sweet spot. Going higher means either the original was 3000+ LOC (the user should break it down conceptually first) or the skill is over-extracting.
- **Skipping post-extraction verification** — lint + tests + line-count must run after; without them, broken imports and missing exports ship silently.
- **Dogma over project convention** — insisting on `lib/operations/` when the project uses `lib/utils/` makes the user fight the skill.

## Cross-references

- `file-discipline.md` — the rule this skill enforces; the ceiling number and override convention live there.
- `code-review.md` — flags files near the ceiling in any change touching them.
- `hook-templates/check-file-size.sh` — the edit-time hook that surfaces "needs decomposition" warnings.
