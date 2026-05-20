#!/usr/bin/env bash
# Warn on TODO/FIXME comments without a ticket reference like (PROJ-123) or (#456).
# Block instead of warn by setting `todoBlock: true` in dotclaude.yml.
set -euo pipefail
input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0
case "$file" in *.ts|*.tsx|*.js|*.jsx|*.py|*.rs|*.go) ;; *) exit 0 ;; esac

if grep -nE '(TODO|FIXME|XXX|HACK):' "$file" 2>/dev/null | grep -vE '\(([A-Z]+-[0-9]+|#[0-9]+)\)' > /tmp/.dc-todo.$$; then
  echo "⚠️  TODO/FIXME without ticket ref:" >&2
  while IFS= read -r line; do echo "  $file:$line" >&2; done < /tmp/.dc-todo.$$
  echo "   Reference like (PROJ-123) or (#456). Override: \`// allow-todo: <reason>\`" >&2
  rm -f /tmp/.dc-todo.$$
  {{#todoBlock}}exit 2{{/todoBlock}}{{^todoBlock}}exit 0{{/todoBlock}}
fi
rm -f /tmp/.dc-todo.$$
exit 0
