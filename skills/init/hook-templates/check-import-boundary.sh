#!/usr/bin/env bash
# Block cross-module imports per declared boundaries.
# Configurable via dotclaude.yml `importBoundary.rules`: list of {from, to, message}.
# Override per-line: append `// allow-import: <reason>`
set -euo pipefail
input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0
case "$file" in *.ts|*.tsx|*.js|*.jsx) ;; *) exit 0 ;; esac

violations=()
{{#importBoundary.rules}}
# Rule: from {{from}} -> {{to}} forbidden ({{message}})
if [[ "$file" == *{{from}}* ]]; then
  if grep -n "from '.*{{to}}" "$file" 2>/dev/null | grep -v 'allow-import' > /tmp/.dc-imp.$$; then
    while IFS= read -r line; do
      violations+=("  $file:$line — {{message}}")
    done < /tmp/.dc-imp.$$
  fi
  rm -f /tmp/.dc-imp.$$
fi
{{/importBoundary.rules}}

if (( ${#violations[@]} > 0 )); then
  echo "❌ Import boundary violation(s):" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "   Override per-line: append \`// allow-import: <reason>\`" >&2
  exit 2
fi
exit 0
