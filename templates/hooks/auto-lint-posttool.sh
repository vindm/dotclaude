#!/usr/bin/env bash
# After Write/Edit on TS/TSX/JS/JSX files, auto-run eslint --fix.
# Configurable: {{lint.command}} (default: npx eslint --fix)
set -euo pipefail
input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0
case "$file" in
  *.ts|*.tsx|*.js|*.jsx) {{#lint.command}}{{lint.command}}{{/lint.command}}{{^lint.command}}npx eslint --fix{{/lint.command}} "$file" 2>/dev/null || true ;;
esac
exit 0
