#!/usr/bin/env bash
# Warn (don't block) when a session ends with uncommitted WIP on disk.
# /clear and auto-compaction lose the conversation context that knows about those
# changes; without a git record the next session can't recover them. Nudge toward a
# WIP commit on a branch — NOT `git stash`: a killed pipeline can strand a stash and
# the work is then easy to lose.
# Fires on SessionEnd. Output is surfaced to the user.
set -euo pipefail
input=$(cat)
reason=$(echo "$input" | jq -r '.reason // "unknown"')
dir="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$dir" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
[[ "$dirty" == "0" ]] && exit 0

echo "⚠️  Session ending (${reason}) with ${dirty} uncommitted file(s)." >&2
echo "   The context that knows about this WIP is about to be lost." >&2
echo "   Prefer a WIP commit on a branch over 'git stash' — a killed pipeline can strand a stash." >&2
exit 0
