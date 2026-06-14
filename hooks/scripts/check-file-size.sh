#!/usr/bin/env bash
# Block edits that push a file above the LOC ceiling.
# Ceiling 1000 / warn 950 (a consumer that wants a different limit edits these two lines).
#
# Override per-line: append `# allow-size: <reason>` to the line that explains the exemption.

set -euo pipefail

CEILING=1000
WARN=950

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" || ! -f "$file_path" ]]; then
  exit 0
fi

# Skip generated artifacts
case "$file_path" in
  *node_modules*|*dist/*|*build/*|*.generated.*|*.types.ts) exit 0 ;;
esac

lines=$(wc -l < "$file_path" | tr -d ' ')

if (( lines > CEILING )); then
  echo "❌ File too large: $file_path is $lines lines (ceiling: $CEILING)" >&2
  echo "   Decompose this file. Suggested: use the decompose-file skill." >&2
  exit 2  # block
fi

if (( lines > WARN )); then
  echo "⚠️  $file_path is $lines lines (approaching $CEILING ceiling)" >&2
fi

exit 0
