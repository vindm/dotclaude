# Worktree discipline — isolation over detection for concurrent sessions

## The problem this solves

Several AI sessions (interactive + background + scheduled) working in one
checkout collide in two ways that advisory protocols cannot prevent:

1. **The shared git index.** Any `git add` stages whatever a sibling session
   left in the working tree; a "commit my change" in session A quietly ships
   session B's WIP. Pathspec-scoped commits reduce but don't remove the risk.
2. **Shared working files.** Two sessions edit the same file in the same hour;
   the second write silently clobbers the first (a real incident class — two
   sessions editing one lint module in the same hour, discovered only by diff).

Lock files and "check before you edit" conventions only *detect* the second
writer. Git worktrees *remove* the collision: each session gets its own working
tree and its own index over the same object store. The discipline: **every
substantive edit happens in a dedicated worktree; a blocking PreToolUse hook
makes the main checkout read-only for the agent.** Prose rules get forgotten
mid-session; the hook is the mechanism, the prose is the explanation.

## The universal / project-specific split

The mechanics are identical everywhere; the calibration is a judgment call per
project. So the hook is CONSUMED — one debugged script, wired always-on — and
the per-project part is a `worktree:` block in `dotclaude.yml` that the hook
reads, not a rendered per-project copy.

**Universal (ships as ONE consumed hook — `hooks/scripts/check-main-checkout-edit.sh`):**
- The detection logic: a file's repo is found via `git rev-parse
  --git-common-dir` from its nearest EXISTING ancestor directory (a Write may
  target a directory that doesn't exist yet); a worktree is recognized by
  `--git-dir` ≠ `--git-common-dir`; other repos and non-repo paths are ignored.
- The stray-worktree guard (a path that looks like a worktree but resolves
  OUTSIDE the policed repo) and the escape hatch (a
  `.claude/.runtime/allow-main-edits` flag, created only on the user's explicit
  ask, removed right after).
- NO-OP when the project has no `worktree:` config — so the one hook ships
  always-on yet bites only opted-in projects.

The hook guards every future edit — a guard each installation rewrites from
prose is itself unguarded. A subtly wrong PreToolUse hook (bad exit code,
unhandled missing `jq`, no nearest-existing-dir walk) can block EVERY edit.
Consume the one debugged hook; a project supplies only data, never logic (its
own logic is tested in the plugin, not re-tested per install).

**Project-specific (interviewed / detected → the `worktree:` config block, never defaulted):**
- *Which repo to police.* The project root is not always the repo — audit
  zones and monorepo-of-repos layouts keep the policed repo one level down.
- *The exempt list.* See "markdown is sometimes code" below.
- *The fresh-worktree setup recipe.* See "git-ignored per-machine files".
- *The verify + close protocol.* The project's own gates (build, lint,
  integrity checks) and merge etiquette.
- *Out-of-repo shared resources.* See "worktrees don't solve everything".

## The five hard-won lessons

**1. Markdown is sometimes code — never blanket-exempt `*.md`.**
The natural default ("docs are free, code is policed") is wrong for a growing
class of projects where markdown IS the program: runtime-executed policies,
agent instructions, prompt libraries, `.claude/` kits themselves. In one real
port, exempting `*.md` would have left the system's entire behavioral layer
(`policies/`, `workflows/`) unprotected — editing those files is exactly the
behaviour change that must go through a worktree. The generator must ask:
"is any of your markdown executed rather than read by humans?" and build the
exempt list from the answer.

**2. Git-ignored per-machine files make a fresh worktree broken by default.**
`git worktree add` checks out tracked files only. Everything `.gitignore`d
that the main checkout accumulated — `.env`, a per-machine `config/*.yaml`
pointer, `node_modules`, credentials — is absent in the new worktree, and the
project's build fails until each is recreated. Detect them (`git status
--ignored --porcelain` filtered to what exists in main), and give every one an
explicit recipe: copy a committed template, symlink from main (heavy dep
trees), regenerate, or consciously skip. The recipe belongs in the lifecycle
skill AND in the hook's block message — it's the first thing a blocked session
needs.

**3. Derived artifacts dirty the tree — only a live smoke run finds them.**
A project's normal build/render may rewrite committed derived files (a
generated index with a `generated_at` stamp, a lockfile, formatted output).
The worktree then refuses `git worktree remove` as "dirty", and naive sessions
either force-remove (losing work) or commit the noise. No static analysis
finds these: the installer must create a scratch worktree, run the project's
real verify command, record what got dirty, and fold a "drop the noise" step
into the close protocol. This is also the end-to-end proof the setup works.

**4. Hooks register at session start — an unrestarted install is unverified.**
The freshly written `settings.json` hook does NOT fire in the session that
wrote it (nor in already-open sibling sessions). Every install must end with:
restart, then live-fire — ask for a trivial edit to a policed file and watch
the block. Without this step the install *looks* finished while enforcing
nothing; with parallel sessions it also means the discipline phases in as each
session restarts, which the user should be told explicitly.

**5. The worktree's absolute path comes from git — never hand-built.**
`git -C <repo> worktree add ../<prefix><slug>` resolves `../` against the
`-C <repo>` directory, NOT the shell's cwd — so the new tree lands beside the
repo, which may be one level below the project root. An agent that then
composes that path by eye (or "from the project root") drops a segment and
writes into a stray sibling directory outside every repo; the build still
"passes" because a `cd` inside one command finds the sources there, so the
work silently lands in the wrong place (a real incident). Two reinforcing
hazards make eyeballing fatal: file-writing tools need an ABSOLUTE path, and
the harness resets cwd between separate tool calls (a `cd <wt> && ls` split
across calls shows an empty dir and misleads diagnosis). The generated skill
must therefore instruct: capture the absolute path from `git worktree list
--porcelain`, assert it (`test -d "$WT/<build-marker>"`), and use that literal
path for every subsequent write — never recompose it. The hook can back this
with a guard that blocks a write to a `<prefix>*` path which does NOT resolve
into the policed repo (the dropped-segment case), turning a silent misfile
into an immediate block.

## Worktrees don't solve everything — the narrowed lease

Isolation covers collisions *inside the repo*. Shared mutable resources
outside it remain: a real-data snapshot several sessions render against, a
device/simulator pool, a bundler port, the merge/push window on main itself.
For those, keep (or introduce) a lightweight courtesy lease — one lock file,
one line `<session-label> | <scope> | <ISO8601>`, stale after ~60 minutes —
scoped ONLY to the shared resource and the merge window. Edits inside one's
own worktree need no lease. The pairing is the point: worktrees for the repo,
the lease for what worktrees can't isolate.

Two hard-won details for the lease itself. **Take it atomically — a check that
only PRINTS does not gate the write.** `cat lock || echo "taking"` gates
nothing: `cat` of an existing file exits 0, so the `||` never fires and the
write lands on top of a live lease (a real incident). Acquire with the write
itself failing when the file exists — `if ( set -o noclobber; echo "$label |
$scope | $ts" > "$lock" ) 2>/dev/null; then :; else echo busy; fi`. **And the
merge window has a hazard the lease can't see:** the shared checkout may sit
mid-*another* session's merge, so `test -f <repo>/.git/MERGE_HEAD` before you
merge. The reassurance underneath is that `git merge` with a sibling's foreign
staged files *refuses* (`Your local changes would be overwritten`) rather than
absorbing them — a busy main is impossible to merge into, not silently
corruptible; the things to guard are the lease *overwrite* and the
*interrupted merge*, not merge itself.

## Boundaries of the discipline

- **Opt-in per project, never an always-on plugin guard.** A plugin-level
  hook would police every consumer's repo with unconfigurable exempt defaults
  — wrong for markdown-as-code projects and hostile for solo single-session
  work. This ships only through the generator, into the project's own
  `.claude/`.
- **Enforcement is orthogonal to worktree creation tooling.** Whether
  worktrees are made by hand, by a lifecycle skill, or by a harness-native
  tool (e.g. an EnterWorktree feature), the hook is the layer that makes main
  read-only; it doesn't care who creates the worktree.
- **Close protocol etiquette:** gates green inside the worktree → commit on
  the feature branch → (lease) merge in main → `git worktree remove` → delete
  branch. `worktree remove` refusing = uncommitted work or derived noise;
  never `--force` without the user's explicit ok.
