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

## Notes

- **`jq` dependency.** The scripts parse the hook payload with `jq` — consumers need it on PATH.
- **Per-edit latency.** Two PostToolUse Write/Edit hooks = two spawns per edit (plus the consumer's own). Both are fast deterministic guards. A future optimization is one consolidated dispatcher (per the `operating-discipline` lean guidance).
- **Want a project-tunable guard** (design-token sweep, import-boundary, forbidden-phrases, console-log, regen-on-migration)? Those live in `../hook-templates/` and are authored locally by the thin generator with the project's config — they're not safe-as-is in an arbitrary consumer.
