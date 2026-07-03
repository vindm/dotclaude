#!/usr/bin/env bash
# Unit-drive for check-main-checkout-edit.sh — feeds synthetic PreToolUse
# payloads and asserts the exit code. Ships WITH the hook: a fresh install is
# unverified until this passes, and any later edit to the hook re-proves itself
# here. Run from anywhere:
#   bash .claude/hooks/test-check-main-checkout-edit.sh [<worktree-path>]
# The optional argument enables the worktree-allowed case (pass a live worktree
# of the policed repo).
#
# Template placeholders (substituted by /dotclaude:worktree; named without
# braces here so substitution never touches this comment block):
#   worktree.blockedCases  — `t <name> "$P/<path>" 2` lines: paths in the main
#                            checkout that MUST be blocked (include at least one
#                            source file AND, if markdown is code in this project,
#                            one .md file — the markdown-as-code regression case)
#   worktree.allowedCases  — `t <name> "$P/<path>" 0` lines: exempt paths, paths
#                            in other repos / outside any repo
#   worktree.blockedSamplePath — one blocked path, reused for the escape-hatch case

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/check-main-checkout-edit.sh"
P="$(cd "$HERE/../.." && pwd)"          # project root (.claude/hooks/ -> two up)
export CLAUDE_PROJECT_DIR="$P"
ESC="$P/.claude/.runtime/allow-main-edits"

pass=0; fail=0
t() { # t <name> <file_path> <want-exit>
  printf '{"tool_input":{"file_path":"%s"}}' "$2" | bash "$HOOK" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$3" ]; then pass=$((pass+1)); echo "ok   $1"
  else fail=$((fail+1)); echo "FAIL $1 (want exit $3, got $got)"; fi
}

rm -f "$ESC"
{{worktree.blockedCases}}
{{worktree.allowedCases}}
t outside-repo-allowed     "/tmp/dc-wt-scratch.py"                 0
t empty-input-allowed      ""                                      0

mkdir -p "$(dirname "$ESC")"; touch "$ESC"
t escape-hatch-allowed     "$P/{{worktree.blockedSamplePath}}"     0
rm -f "$ESC"

if [ -n "${1:-}" ]; then
  t worktree-allowed       "$1/some-source-file"                   0
fi

echo "----- pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
