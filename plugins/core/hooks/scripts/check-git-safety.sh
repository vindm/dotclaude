#!/usr/bin/env bash
# Block destructive git operations regardless of flag POSITION.
# Prefix-based permission deny rules (e.g. deny "git push --force") are bypassable
# by reordering flags ("git push origin main --force"); this hook matches the whole
# command string, so the flag is caught wherever it sits.
# Fires on PreToolUse Bash matcher. Exit 2 = block; stderr is fed back to Claude.
set -euo pipefail
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
[[ -z "$cmd" ]] && exit 0

# Only inspect commands that actually invoke git.
echo "$cmd" | grep -qE '(^|[;&|[:space:]])git([[:space:]]|$)' || exit 0

block() {
  echo "⛔ Blocked destructive git: $1" >&2
  echo "   Command: $cmd" >&2
  echo "   If this is genuinely intended, run it yourself or ask the user to confirm." >&2
  exit 2
}

# Force push — --force / --force-with-lease / -f anywhere on a push.
if echo "$cmd" | grep -qE '\bgit\b.*\bpush\b' \
   && echo "$cmd" | grep -qE '(--force([^-]|$)|--force-with-lease|(^|[[:space:]])-[A-Za-z]*f)'; then
  block "force push"
fi

# History / working-tree destroyers — flag matched anywhere in the command.
echo "$cmd" | grep -qE '\bgit\b.*\breset\b.*--hard'                && block "git reset --hard"
echo "$cmd" | grep -qE '\bgit\b.*\bclean\b.*-[A-Za-z]*f'           && block "git clean -f"
echo "$cmd" | grep -qE '\bgit\b.*\bcheckout\b.*--force'            && block "git checkout --force"
echo "$cmd" | grep -qE '\bgit\b.*\bbranch\b.*[[:space:]]-D'        && block "git branch -D (force delete)"
echo "$cmd" | grep -qE '\bgit\b.*\bfilter-branch\b'               && block "git filter-branch (history rewrite)"
echo "$cmd" | grep -qE '\bgit\b.*\bstash\b.*(drop|clear)'         && block "git stash drop/clear"
echo "$cmd" | grep -qE '\bgit\b.*\breflog\b.*expire'             && block "git reflog expire"
echo "$cmd" | grep -qE '\bgit\b.*\bupdate-ref\b.*[[:space:]]-d'   && block "git update-ref -d"

# --no-verify / -n on commit|push anywhere (skips the safety hooks).
echo "$cmd" | grep -qE '\bgit\b.*(commit|push).*--no-verify'      && block "--no-verify (skips commit/push hooks)"

exit 0
