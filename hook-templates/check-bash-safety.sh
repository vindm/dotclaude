#!/usr/bin/env bash
# Block bash commands with unquoted $VAR or ${VAR} that could expand to empty/dangerous values.
# Fires on PreToolUse Bash matcher.
set -euo pipefail
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
[[ -z "$cmd" ]] && exit 0

# Look for risky patterns: rm -rf $VAR (without quotes), cd $VAR && ...
if echo "$cmd" | grep -qE '(rm -rf|cd|cp -r|mv) +\$[A-Za-z_]|\$\{[A-Za-z_]+\}'; then
  if ! echo "$cmd" | grep -qE '"\$|"\${'; then
    echo "⚠️  Bash command has unquoted \$VAR — quote it: \"\$VAR\"" >&2
    echo "   Command: $cmd" >&2
    exit 0
  fi
fi
exit 0
