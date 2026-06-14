# `hooks/` — plugin-provided universal guards

`hooks/hooks.json` registers the **zero-config, universally-safe** guards that fire in every project enabling the plugin. They are additive — they run *in addition to* the consuming project's own hooks (Claude Code merges plugin and project hooks; both fire). Scripts live in `hook-templates/` and are referenced via `${CLAUDE_PLUGIN_ROOT}` (a plugin cannot reference files outside its own directory).

## Shipped (universal, safe as-is — the consume-direct base)

| Hook | Event | What it does |
|---|---|---|
| `check-git-safety` | PreToolUse · Bash | Blocks destructive git (force-push, `reset --hard`, `clean -f`, `--no-verify`, history rewrites) by whole-command match. exit 2 = block. |
| `check-secret-leak` | PostToolUse · Write\|Edit | Blocks obvious credential patterns in written files. exit 2. Override per-line `// allow-secret: <reason>`. |
| `check-file-size` | PostToolUse · Write\|Edit | Blocks files over the LOC ceiling (default; warns near it). exit 2. |
| `git-context-sessionstart` | SessionStart | Injects real git state (branch / commit / uncommitted / ahead-behind / worktrees) via `additionalContext` + a memory self-healing nudge. |
| `warn-uncommitted-on-clear` | SessionEnd | Warns on uncommitted WIP before `/clear` / compaction. |

## NOT shipped here — generator-authored locally

These templates in `hook-templates/` need project-specific config (a path, a rule list, a phrase list, a command) and so are **not** safe-as-is in an arbitrary consumer. The thin generator (`bootstrap`) installs the ones a project wants and writes its `dotclaude.yml`: `check-design-tokens` (theme path), `check-import-boundary` (boundary rules), `check-forbidden-phrases` (phrase list), `check-no-console-log` (allow-paths), `check-no-todo-comments`, `check-prebuild-required`, `regen-generated-artifacts` (regen command), `auto-lint-posttool` (lint command). `check-bash-safety` is available but left opt-in (its unquoted-`$VAR` warning is broad enough to be noisy).

## Notes

- **`jq` dependency.** The scripts parse the hook payload with `jq` — consumers need it on PATH. (Inherent to the templates.)
- **Per-edit latency.** Two PostToolUse Write/Edit hooks = two spawns per edit (plus the consumer's own). Both are fast deterministic guards. A future optimization is one consolidated dispatcher (per `operating-discipline` lean guidance), but independent fast scripts are acceptable.
