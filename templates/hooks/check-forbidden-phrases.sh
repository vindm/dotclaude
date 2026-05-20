#!/usr/bin/env bash
# Block edits that introduce forbidden phrases (AI slop, off-brand voice).
# Configurable via dotclaude.yml `forbiddenPhrases.phrases` and `.scopes`.
#
# Override per-line: append `# allow-forbidden: <reason>`

set -euo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" || ! -f "$file_path" ]]; then
  exit 0
fi

# Check scope
in_scope=false
{{#forbiddenPhrases.scopes}}
case "$file_path" in {{.}}) in_scope=true ;; esac
{{/forbiddenPhrases.scopes}}

if [[ "$in_scope" == "false" ]]; then
  exit 0
fi

violations=()
{{#forbiddenPhrases.phrases}}
if grep -n "{{.}}" "$file_path" 2>/dev/null | grep -v 'allow-forbidden' > /tmp/.dc-forbidden.$$; then
  while IFS= read -r line; do
    violations+=("  $file_path:$line")
  done < /tmp/.dc-forbidden.$$
fi
rm -f /tmp/.dc-forbidden.$$
{{/forbiddenPhrases.phrases}}

if (( ${#violations[@]} > 0 )); then
  echo "❌ Forbidden phrase(s) detected:" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "   Override per-line: append \`# allow-forbidden: <reason>\`" >&2
  exit 2
fi

exit 0
