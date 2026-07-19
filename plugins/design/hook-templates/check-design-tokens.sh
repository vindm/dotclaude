#!/usr/bin/env bash
# Block raw hex / rgba color literals outside the theme source.
# Configurable: dotclaude.yml `designTokens.theme` (default: src/theme/)
# Override per-line: append `// allow-color: <reason>`
set -euo pipefail
input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0
case "$file" in *.ts|*.tsx|*.css|*.scss) ;; *) exit 0 ;; esac

THEME_PATH="{{#designTokens.theme}}{{designTokens.theme}}{{/designTokens.theme}}{{^designTokens.theme}}src/theme/{{/designTokens.theme}}"
case "$file" in *${THEME_PATH}*) exit 0 ;; esac

# Match #rgb / #rrggbb / #rrggbbaa / rgba(...)
if grep -nE '#[0-9a-fA-F]{3,8}|rgba?\(' "$file" 2>/dev/null | grep -v 'allow-color' > /tmp/.dc-clr.$$; then
  echo "❌ Raw color literal(s) detected outside $THEME_PATH:" >&2
  while IFS= read -r line; do echo "  $file:$line" >&2; done < /tmp/.dc-clr.$$
  echo "   Use a semantic token from $THEME_PATH or override: \`// allow-color: <reason>\`" >&2
  rm -f /tmp/.dc-clr.$$
  exit 2
fi
rm -f /tmp/.dc-clr.$$
exit 0
