#!/usr/bin/env bash
# Warn when an edit lands in a path that requires a prebuild step.
# Configurable: dotclaude.yml `prebuild.triggerPaths` (paths that need prebuild)
set -euo pipefail
input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0

triggered=false
{{#prebuild.triggerPaths}}
case "$file" in *{{.}}*) triggered=true ;; esac
{{/prebuild.triggerPaths}}

if [[ "$triggered" == "true" ]]; then
  echo "⚠️  $file changed — prebuild may be required." >&2
  echo "   Run: {{#prebuild.command}}{{prebuild.command}}{{/prebuild.command}}{{^prebuild.command}}npm run prebuild{{/prebuild.command}}" >&2
fi
exit 0
