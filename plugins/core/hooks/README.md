# `hooks/` — consumable universal guards

`hooks/hooks.json` registers the **zero-config, universally-safe** guards that fire in every project enabling the plugin. They are additive — they run *in addition to* the consuming project's own hooks (Claude Code merges plugin and project hooks; both fire). The scripts live in `hooks/scripts/` and are referenced via `${CLAUDE_PLUGIN_ROOT}/hooks/scripts/…` (a plugin cannot reference files outside its own directory).

**These are real, ready-to-run scripts — NOT templates.** They run as-is in a consumer, no substitution. (Contrast `../hook-templates/`, which holds genuine `{{placeholder}}` templates the generator copies + substitutes into a project's local `.claude/hooks/` — those are project-specific by nature: a theme path, boundary rules, a brand phrase list, a project command.)

## Wired (fire in every consumer)

| Hook | Event | What it does |
|---|---|---|
| `check-git-safety` | PreToolUse · Bash | Blocks destructive git (force-push, `reset --hard`, `clean -f`, `--no-verify`, history rewrites) by whole-command match. exit 2 = block. |
| `check-bash-safety` | PreToolUse · Bash | Warns on `rm -rf`/`cd`/`cp -r`/`mv` with an **unquoted** `$VAR` (which can expand empty/dangerous). Scoped to those commands; warn-only. |
| `check-secret-leak` | PostToolUse · Write\|Edit | Blocks obvious credential patterns in written files. exit 2. Override per-line `// allow-secret: <reason>`. |
| `check-file-size` | PostToolUse · Write\|Edit | Blocks files over the LOC ceiling (1000; warns at 950). exit 2. |
| `git-context-sessionstart` | SessionStart | Injects real git state (branch / commit / uncommitted / ahead-behind / worktrees) via `additionalContext` + a memory self-healing nudge. |
| `warn-uncommitted-on-clear` | SessionEnd | Warns on uncommitted WIP before `/clear` / compaction. |
| `check-main-checkout-bash-write` | PostToolUse · Bash | Reports files a SHELL command wrote into the policed main checkout — the hole `check-main-checkout-edit` cannot see (no `file_path` on `sed -i`, heredocs, `tee`). Outcome-anchored: diffs `git status` against this session's previous answer, so no write mechanism dodges it. Config-gated on `worktree:`; exit 2 (informational — PostToolUse cannot block). |
| `check-assistant-memory-write` | PreToolUse · Write\|Edit\|NotebookEdit | Blocks a note of PROJECT knowledge written into the assistant's own memory (`~/.claude/projects/<slug>/memory/`) — a store keyed by this machine's absolute project path, invisible to the runtime, to other checkouts and to teammates. A note passes only when it DECLARES why it may live there (`type: user`, or a configured `scope:`); the block message names the project homes instead. Config-gated on `memory:`; exit 2 = block. |
| `check-delivery-claim` | Stop | Blocks a turn whose final message CLAIMS delivery the repo denies (committed / merged / pushed / gates-green). No claim, no sound. Config-gated on `delivery:`. exit 2 = block. |

## Config-gated, not zero-config

Four of these read the consuming project's `dotclaude.yml` and are a **silent
no-op without their block** — `check-file-size` (`fileSize:`),
`check-main-checkout-edit` + `check-main-checkout-bash-write` (`worktree:`),
`check-delivery-claim` (`delivery:`), and `check-assistant-memory-write` (`memory:`). That is what makes them safe to ship always-on
without being universal: a project that never opted in never feels them.

## Notes

- **`jq` dependency.** The scripts parse the hook payload with `jq` — consumers need it on PATH.
- **Per-Bash latency.** `check-main-checkout-bash-write` runs on every Bash call.
  Measured on a 2 300-file repo: **0.17 s** with a `worktree:` block, **0.01 s**
  without one (it bails on a `test -f` before spawning anything). The unconfigured
  case is the one most consumers pay, and it was deliberately made free.
- **Per-edit latency.** Two PostToolUse Write/Edit hooks = two spawns per edit (plus the consumer's own). Both are fast deterministic guards. A future optimization is one consolidated dispatcher (per the `operating-discipline` lean guidance).
- **Want a project-tunable guard** (design-token sweep, import-boundary, console-log, regen-on-migration)? Those live in `../hook-templates/` and are authored locally by the thin generator with the project's config — they're not safe-as-is in an arbitrary consumer.
