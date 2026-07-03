---
description: Set up worktree-per-feature discipline for a project where several AI sessions (or humans + agents) work concurrently and collide in one checkout. Authors a blocking main-checkout hook (from a tested template), its test harness, and a project-specific worktree lifecycle skill — calibrated by interview (which repo, what's exempt, how a fresh worktree gets configured) and PROVEN by a live smoke worktree before handoff. Invoke /dotclaude:worktree when parallel sessions are real or planned.
---

# `/dotclaude:worktree` — parallel-session isolation kit

You are setting up worktree-per-feature discipline: every substantive edit to
the policed repo happens in a dedicated git worktree, enforced by a blocking
PreToolUse hook. Read `../../principles/worktree-discipline.md` FIRST — it
carries the doctrine and the four hard-won lessons this flow encodes; this
file is the procedure.

The deliverable is not files — it is a **proven** install: the rendered hook
passing its harness, a smoke worktree that built the project for real, and an
explicit restart + live-fire handoff.

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
universal/project-specific split (what you substitute vs what you author) and
the four lessons (each maps to a concrete step below).

## Phase 4 — Author the kit (in `.claude-staging/`)

### Hooks (render from `../../hook-templates/` — consume, don't rewrite)

- **`check-main-checkout-edit.sh`** — substitute:
  - `{{worktree.policedRepo}}` — from Phase 1/interview (`.` when root=repo)
  - `{{worktree.exemptCasePattern}}` — the interviewed exempt list as a joined
    case-glob (e.g. `docs/*|README.md|LICENSE*`). NEVER include `*.md` unless
    the user explicitly confirmed no markdown is executed.
  - `{{worktree.namePrefix}}` — `<repo>-wt-` unless the user prefers otherwise
  - `{{worktree.setupLines}}` — the fresh-worktree setup command(s) from the
    per-machine-files recipe, as indented shell lines for the block message
- **`test-check-main-checkout-edit.sh`** — substitute the case lists:
  - `{{worktree.blockedCases}}` — at least: one source file; one
    markdown-as-code file **if the project has any** (the regression case for
    lesson 1); one path in each policed area the user named
  - `{{worktree.allowedCases}}` — every exempt pattern gets a case; plus a
    path in each sibling repo that must stay untouched
  - `{{worktree.blockedSamplePath}}` — reuse one blocked path
- Verify NO `{{` remains in either rendered file.

### Skill (in `.claude-staging/skills/worktree/SKILL.md`)

The project's lifecycle skill — author it (this one is project-specific by
nature). Sections, each filled with THIS project's real commands:

1. **Create + configure**: `git -C <repo> worktree add ../<prefix><slug> -b
   feat/<slug>` + the setup recipe (one line per per-machine file, real paths).
2. **Verify**: the project's verify command + expected output.
3. **Close**: the project's gates → commit (with any project-specific
   pre-commit review the repo's conventions demand) → merge etiquette → 
   `git worktree remove` → branch cleanup. Include the derived-artifacts
   "drop the noise" step with the EXACT paths Phase 5's smoke run recorded.
4. **Escape hatch**: the `allow-main-edits` convention, ask-first.
5. **Shared resources lease** (only if Phase 1/interview surfaced out-of-repo
   shared state): the narrowed lock protocol from the principle doc.

### Wiring (in `.claude-staging/hooks/settings-fragment.json`)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/check-main-checkout-edit.sh\"",
            "timeout": 5,
            "statusMessage": "Checking the edit targets a worktree, not the main checkout..."
          }
        ]
      }
    ]
  }
}
```

Merge into the project's `.claude/settings.json` at approval time (create it
if absent; merge the `hooks` key if it exists — never clobber).

### CLAUDE.md section

A short "Session coordination" section for the project's CLAUDE.md: the rule,
the hook path, the exempt list, the escape hatch, the lifecycle skill pointer,
and — if a lease protocol survives — its narrowed scope (out-of-repo shared
resources + the merge window ONLY).

## Phase 5 — Prove it live (mandatory, before presenting)

1. **Harness green**: run the rendered
   `test-check-main-checkout-edit.sh` — every case `ok`. A failing or skipped
   harness is a blocker, not a footnote.
2. **Smoke worktree** (lesson 3): create a real worktree per the lifecycle
   skill, run the setup recipe, run the project's verify command inside it.
   - Record EVERY file `git status` shows dirty afterwards — these are the
     project's derived artifacts; write their exact paths into the lifecycle
     skill's "drop the noise" close step.
   - Re-run the harness with the smoke worktree's path as the argument (the
     worktree-allowed case).
   - Tear down per the close protocol (`worktree remove` must succeed WITHOUT
     `--force`).
3. If the verify command fails in the worktree but works in main — a
   per-machine file is missing from the setup recipe. Fix the recipe, not the
   worktree; re-run.

## Phase 6 — Present + handoff

Present per dotclaude staging convention (inventory, highlight reasoning, what
was skipped and why). After approval, move `.claude-staging/` → `.claude/`,
merge the settings fragment, commit.

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
2. **Consume the hook template; substitute placeholders only.** The template
   is debugged (nearest-existing-dir walk, worktree detection, other-repo
   pass-through, missing-jq behavior). Rewriting it from prose per-install
   reintroduces the bugs the template already paid for. If the project needs
   logic the template lacks, that's a dotclaude PR, not a local fork.
3. **The harness ships and runs, both.** Rendered-but-untested is unverified;
   tested-once-then-deleted leaves future hook edits unguarded. The harness
   lands in the project's `.claude/hooks/` next to the hook.
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
