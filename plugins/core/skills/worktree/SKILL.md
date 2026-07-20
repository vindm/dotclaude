---
description: Set up worktree-per-feature discipline for a project where several AI sessions (or humans + agents) work concurrently and collide in one checkout. Writes a thin `worktree:` config block that the plugin's CONSUMED main-checkout hook reads (no rendered per-project hook copy), plus a project-specific worktree lifecycle skill — calibrated by interview (which repo, what's exempt, how a fresh worktree gets configured) and PROVEN by a live smoke worktree before handoff. Invoke /dotclaude:worktree when parallel sessions are real or planned.
---

# `/dotclaude:worktree` — parallel-session isolation kit

You are setting up worktree-per-feature discipline: every substantive edit to
the policed repo happens in a dedicated git worktree, enforced by a blocking
PreToolUse hook. Read `../../principles/worktree-discipline.md` FIRST — it
carries the doctrine and the five hard-won lessons this flow encodes; this
file is the procedure.

**The hook is CONSUMED, not rendered.** The plugin ships one debugged
`check-main-checkout-edit.sh` (in `hooks/scripts/`, wired always-on) that reads
a `worktree:` block from the project's `dotclaude.yml` and NO-OPs when there is
none. So this flow does NOT copy a hook into the project — it writes the config
the consumed hook reads. No per-project hook copy, no drift, and a project
tunes its policing in one data file.

The deliverable is not files — it is a **proven** install: the `worktree:`
config the consumed hook reads correctly, a smoke worktree that built the
project for real, and an explicit restart + live-fire handoff.

## Phase 1 — Read the project's concurrency shape

Before any question:

1. **Repo topology** — is the project root the repo, or does the policed repo
   sit below it?
   ```bash
   git rev-parse --show-toplevel 2>/dev/null
   for d in */; do git -C "$d" rev-parse --show-toplevel 2>/dev/null; done
   git worktree list 2>/dev/null
   ```
   Multiple sibling repos → ask which one(s) carry the collision risk (usually
   the one being actively developed, not read-only references/snapshots).

2. **Parallel-session evidence** — lock files (`.session_lock`, `*.lock` at
   repo root), CLAUDE.md sections about session coordination, git history
   mentions of collisions/clobbered work, scheduled/background agents. This
   calibrates urgency and whether a lease protocol already exists to narrow.

3. **Git-ignored per-machine files** (lesson 2 — the fresh-worktree breakers):
   ```bash
   git -C <repo> status --ignored --porcelain | grep '^!!'
   ```
   Filter to files/dirs the build actually needs: `.env*`, `config/*` pointers,
   `node_modules`, credential stores. For each, note the likely recipe: copy a
   committed `*.example` template / symlink from main / regenerate / skip.

4. **Markdown-as-code signal** (lesson 1): does the repo carry markdown the
   *system executes* — `policies/`, `workflows/`, prompt libraries, agent
   instructions, `.claude/` kits? If yes, those paths must NOT be exempt.

5. **Verify command** — how the project proves itself (from `package.json`
   scripts, Makefile, CI config, README): the build/test/render command the
   smoke run (Phase 5) will execute, and the close-protocol gates.

## Phase 2 — Interview

Open `interview.md` (same directory). 4-5 questions, adaptive — skip what
Phase 1 answered. Non-skippable even when scan feels conclusive: **W2 (exempt
list / markdown-as-code)** — it is a judgment call only the user can make.

## Phase 3 — Read the principle

`../../principles/worktree-discipline.md` — in particular the
universal/project-specific split (what the `worktree:` config carries vs what
you author) and the five lessons (each maps to a concrete step below).

## Phase 4 — Author the config + the lifecycle skill

### Config (write the `worktree:` block to `dotclaude.yml`)

The consumed hook reads these keys; you do NOT render or wire a hook. Write (or
merge) a `worktree:` block into the project root's `dotclaude.yml`:

```yaml
worktree:
  policedRepo: <repo path relative to the project root; "." when root IS the repo>
  namePrefix:  <repo>-wt-        # unless the user prefers otherwise
  exempt:                        # main-checkout paths that stay freely editable
    - "docs/*"
    - "README.md"
    - "LICENSE*"
  setup:                         # fresh-worktree recipe, shown in the block message
    - "cp config/instance.example.yaml <wt>/config/instance.yaml"
  skillPath: .claude/skills/worktree/SKILL.md
```

- **`exempt`** — the interviewed list, matched against the repo-relative path
  (`*` spans directory separators). NEVER include `*.md` unless the user
  explicitly confirmed no markdown is executed (markdown-as-code, lesson 1).
- **`setup`** — the per-machine-files recipe (lesson 2), one line each; `<wt>`
  stands for the worktree dir in the block message.
- The stray-worktree guard (lesson 5) and the escape hatch are built into the
  consumed hook — no per-project authoring.
- Merge into an existing `dotclaude.yml` (from another elicitation) — never
  clobber the `artifacts:` / `fileSize:` keys.

### Skill (in `.claude-staging/skills/worktree/SKILL.md`)

The project's lifecycle skill — author it (this one is project-specific by
nature). Sections, each filled with THIS project's real commands:

1. **Create + configure**: `git -C <repo> worktree add ../<prefix><slug> -b
   feat/<slug>` + the setup recipe (one line per per-machine file, real paths).
   Then (lesson 5) author a **capture + assert** step: pull the worktree's
   ABSOLUTE path from `git -C <repo> worktree list --porcelain` into a variable,
   assert it (`test -d "$WT/<build-marker>"`), and tell the agent to use that
   literal path for every later write — never recompose `../<prefix><slug>` by
   eye. Include the path-discipline note: `../` resolves against the
   `-C <repo>` dir (not the shell cwd), write tools need an absolute path, and
   the harness resets cwd between tool calls.
2. **Verify**: the project's verify command + expected output.
3. **Close**: the project's gates → commit (with any project-specific
   pre-commit review the repo's conventions demand) → merge etiquette → 
   `git worktree remove` → branch cleanup. Include the derived-artifacts
   "drop the noise" step with the EXACT paths Phase 5's smoke run recorded.
4. **Escape hatch**: the `allow-main-edits` convention, ask-first.
5. **Shared resources lease** (only if Phase 1/interview surfaced out-of-repo
   shared state): the narrowed lock protocol from the principle doc.

### No wiring step

The consumed hook is wired once in the plugin's `hooks/hooks.json` (always-on,
NO-OP without a `worktree:` block). Do NOT add a local hook to the project's
`.claude/settings.json` — a project-level hook copy is exactly the drift this
model removes. The `worktree:` block written in Phase 4 is the entire opt-in.

### CLAUDE.md section

A short "Session coordination" section for the project's CLAUDE.md: the rule,
the hook path, the exempt list, the escape hatch, the lifecycle skill pointer,
and — if a lease protocol survives — its narrowed scope (out-of-repo shared
resources + the merge window ONLY).

## Phase 5 — Prove it live (mandatory, before presenting)

1. **Live-fire the consumed hook against the written config**: feed it a few
   synthetic tool inputs and confirm the verdicts.
   ```bash
   H="$CLAUDE_PLUGIN_ROOT/hooks/scripts/check-main-checkout-edit.sh"
   fire() { echo "{\"tool_input\":{\"file_path\":\"$1\"}}" | bash "$H"; echo "exit=$?"; }
   fire "<policed-repo>/<a source file>"   # expect exit 2 (block)
   fire "<a markdown-as-code file>"        # expect exit 2 if the project has any
   fire "<an exempt path>"                 # expect exit 0
   fire "<a real worktree>/<a file>"       # expect exit 0
   ```
   A wrong verdict means the `worktree:` block is off (wrong `policedRepo`, a bad
   exempt glob) — fix the config, not a hook. The hook's own logic is tested in
   the plugin; this proves THIS project's config drives it correctly.
2. **Smoke worktree** (lesson 3): create a real worktree per the lifecycle
   skill, run the setup recipe, run the project's verify command inside it.
   - Record EVERY file `git status` shows dirty afterwards — these are the
     project's derived artifacts; write their exact paths into the lifecycle
     skill's "drop the noise" close step.
   - Re-run the Phase 5.1 live-fire with the smoke worktree's path (the
     worktree-allowed case → expect exit 0).
   - Tear down per the close protocol (`worktree remove` must succeed WITHOUT
     `--force`).
3. If the verify command fails in the worktree but works in main — a
   per-machine file is missing from the setup recipe. Fix the recipe, not the
   worktree; re-run.

## Phase 6 — Present + handoff

Present per dotclaude staging convention (inventory, highlight reasoning, what
was skipped and why). After approval, move `.claude-staging/` → `.claude/`,
merge the `worktree:` block into `dotclaude.yml`, commit. (No settings-fragment
merge — the hook is plugin-wired and reads the config.)

Then the two lines every install ends with (lesson 4):

> "Hooks register at session start — the block is NOT active in this session
> or in already-open ones. Restart, then live-fire: ask for a trivial edit to
> `<a policed file>` and confirm the hook blocks with the worktree
> instructions. Until each parallel session restarts, it remains unpoliced."

## Non-negotiable rules for this flow

1. **Never blanket-exempt `*.md` by default.** The markdown-as-code question
   (W2) is mandatory. Projects whose markdown is the program (policies,
   prompts, agent kits) need those paths POLICED; a docs-are-free default
   silently unguards their behavioral layer.
2. **The hook is consumed, never copied.** The plugin ships one debugged
   `check-main-checkout-edit.sh` (nearest-existing-dir walk, worktree detection,
   other-repo pass-through, stray-worktree guard) that reads the `worktree:`
   block. Write config, not a hook — never author a local hook copy or a
   `.claude/settings.json` hook entry; that project-level copy is exactly the
   drift this model kills. If the hook needs logic it lacks, that's a dotclaude
   PR, not a local fork.
3. **Prove the config drives the hook.** The hook's own logic is tested in the
   plugin; this install's job is to live-fire the consumed hook against THIS
   project's `worktree:` block (Phase 5.1). A green block / allow / exempt /
   worktree set is the proof the config is right.
4. **The smoke run is not optional.** Derived-artifact dirt and missing
   per-machine files are only discoverable by actually building in a fresh
   worktree. An install presented without a smoke run has unknown failure
   modes scheduled for the user's first real feature.
5. **Opt-in only.** Never wire this into plugin-level always-on hooks; never
   install it uninvited on a project with no concurrency signal — for a solo
   single-session project, recommend AGAINST installing (say so explicitly in
   the applicability decision).
6. **Worktrees + lease, not worktrees instead of lease.** If out-of-repo
   shared resources exist (data snapshots, device pools, the merge window),
   ship the narrowed lease protocol alongside; if a broad lock protocol
   already exists, narrow it rather than deleting it.
