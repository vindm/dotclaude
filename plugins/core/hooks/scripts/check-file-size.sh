#!/usr/bin/env bash
# Block edits that push a file above the LOC ceiling.
#
# Config-driven: reads `fileSize.ceiling` / `fileSize.warn` / `fileSize.exempt`
# from the project's dotclaude.yml when present (written by /dotclaude:coding),
# else falls back to the built-in defaults below. So a project tunes the ceiling
# in one data file — no editing this script, no rendered per-project copy.
#
# Override per-line: append `# allow-size: <reason>` to the line that explains
# the exemption.

set -uo pipefail

DEFAULT_CEILING=1000
DEFAULT_WARN=950

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
proj="${CLAUDE_PROJECT_DIR:-$PWD}"
yml="$proj/dotclaude.yml"
reader="$HERE/_read_dotclaude_yml.py"

read_cfg() {  # <dotted.key> <default>
  if command -v python3 >/dev/null 2>&1 && [ -f "$reader" ]; then
    python3 "$reader" "$yml" "$1" "$2" 2>/dev/null || printf '%s' "$2"
  else
    printf '%s' "$2"
  fi
}

CEILING=$(read_cfg fileSize.ceiling "$DEFAULT_CEILING")
WARN=$(read_cfg fileSize.warn "$DEFAULT_WARN")
# guard against a non-numeric value slipping through the parser
[[ "$CEILING" =~ ^[0-9]+$ ]] || CEILING=$DEFAULT_CEILING
[[ "$WARN" =~ ^[0-9]+$ ]] || WARN=$DEFAULT_WARN

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" || ! -f "$file_path" ]]; then
  exit 0
fi

# Skip generated artifacts (built-in, always on).
case "$file_path" in
  *node_modules*|*dist/*|*build/*|*.generated.*|*.types.ts) exit 0 ;;
esac

# Skip project-configured exemptions (fileSize.exempt globs). In bash `[[ == ]]`
# a `*` already spans directory separators, so `**/x` and `*/x` and `x` all match
# against the full path directly — no normalization needed.
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  # shellcheck disable=SC2053
  if [[ "$file_path" == $pat ]]; then
    exit 0
  fi
done < <(read_cfg fileSize.exempt "")

lines=$(wc -l < "$file_path" | tr -d ' ')

if (( lines > CEILING )); then
  echo "❌ File too large: $file_path is $lines lines (ceiling: $CEILING)" >&2
  echo "   Decompose this file. Suggested: use the decompose-file skill." >&2
  echo "   (Tune the ceiling or exempt this path in dotclaude.yml → fileSize.)" >&2
  exit 2  # block
fi

if (( lines > WARN )); then
  echo "⚠️  $file_path is $lines lines (approaching $CEILING ceiling)" >&2
fi

exit 0
