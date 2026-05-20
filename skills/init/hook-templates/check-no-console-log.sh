#!/usr/bin/env bash
# Block `console.log` / `console.debug` in non-test/non-dev source paths.
# Configurable: dotclaude.yml `consoleLog.allowPaths` (default: ['scripts/', '__tests__/', 'tests/'])
set -euo pipefail
input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0
case "$file" in *.ts|*.tsx|*.js|*.jsx) ;; *) exit 0 ;; esac

# Skip allowed paths
allowed=false
{{#consoleLog.allowPaths}}
case "$file" in *{{.}}*) allowed=true ;; esac
{{/consoleLog.allowPaths}}
{{^consoleLog.allowPaths}}
case "$file" in *scripts/*|*__tests__/*|*tests/*|*.test.*|*.spec.*) allowed=true ;; esac
{{/consoleLog.allowPaths}}
[[ "$allowed" == "true" ]] && exit 0

if grep -nE 'console\.(log|debug)\(' "$file" 2>/dev/null | grep -v 'allow-console' > /tmp/.dc-clog.$$; then
  echo "❌ console.log in production path:" >&2
  while IFS= read -r line; do echo "  $file:$line" >&2; done < /tmp/.dc-clog.$$
  echo "   Use a logger. Override: \`// allow-console: <reason>\`" >&2
  rm -f /tmp/.dc-clog.$$
  exit 2
fi
rm -f /tmp/.dc-clog.$$
exit 0
