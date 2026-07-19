#!/usr/bin/env bash
# Inject real git state at session start + a memory self-healing instruction.
# State: branch, last commit, uncommitted count, ahead/behind upstream, live worktrees.
# Self-healing: if a memory entry claims a branch / worktree / pending push that this
# state contradicts, Claude reconciles the memory file BEFORE starting work — the
# session start is a reconciliation checkpoint, not just a status line.
# Used as a Claude Code SessionStart hook.
set -euo pipefail
dir="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$dir" 2>/dev/null || { echo '{}'; exit 0; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo '{}'; exit 0; }

branch=$(git branch --show-current 2>/dev/null || echo 'detached')
last=$(git log --oneline -1 2>/dev/null || echo 'no commits')
dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
worktrees=$(git worktree list 2>/dev/null | wc -l | tr -d ' ')

ahead=0; behind=0
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo '')
if [[ -n "$upstream" ]]; then
  counts=$(git rev-list --left-right --count "${upstream}...HEAD" 2>/dev/null || echo '0	0')
  behind=$(echo "$counts" | cut -f1)
  ahead=$(echo "$counts" | cut -f2)
fi

ctx="Git state — branch: ${branch} | last: ${last} | uncommitted: ${dirty} | ahead/behind upstream: ${ahead}/${behind} | worktrees: ${worktrees}. Memory self-healing: if a memory entry claims a branch, worktree, or pending push this state contradicts, reconcile that memory file BEFORE starting work."

# jq does the JSON escaping so newlines / quotes in the commit subject stay safe.
jq -cn --arg c "$ctx" '{additionalContext:$c}'
