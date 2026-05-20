#!/usr/bin/env bash
# Anonymization guard for dotclaude.
#
# Greps committed content for project-specific patterns that must NOT appear in the public repo.
# Excludes author-attribution files (LICENSE) where the copyright holder's name is legitimate.
#
# Usage:
#   bash scripts/check-anonymization.sh
#
# Exit codes:
#   0 — clean
#   2 — at least one forbidden pattern detected; details on stderr
#
# Integration:
#   - Run before `git push` (manually or via .git/hooks/pre-push wrapper)
#   - Mirrored by .github/workflows/anonymization-guard.yml in CI

set -euo pipefail

# Forbidden patterns — project / customer / target-company references that must never leak.
# Author attribution is NOT in this list — copyright in LICENSE is legitimate.
PATTERNS=(
  "opengym"
  "intel-gym"
  "\\brex\\b"           # word-bounded; "regex" and similar are fine
  "bali"
  "\\bomni\\b"
  "obsidian"
  "gymnasium"
  "genki"
  "vinokuroff\\.dm"     # personal email handle (not the surname itself, which appears in LICENSE)
)

# Files / paths to exclude from the scan.
EXCLUDE_PATHS=(
  "LICENSE"               # author copyright holder name is legitimate here
  "scripts/check-anonymization.sh"  # this file lists the patterns themselves
  ".github/workflows/anonymization-guard.yml"  # CI mirror of this script
)

# Build the egrep alternation pattern
joined_pattern=$(printf "|%s" "${PATTERNS[@]}")
joined_pattern="${joined_pattern:1}"

# Get tracked files, filter out excluded paths
files=$(git ls-files | grep -vFf <(printf '%s\n' "${EXCLUDE_PATHS[@]}"))

violations=$(echo "$files" | xargs grep -nliE --binary-files=without-match "$joined_pattern" 2>/dev/null || true)

if [[ -n "$violations" ]]; then
  echo "❌ Anonymization guard FAILED — forbidden pattern(s) detected:" >&2
  echo "" >&2
  echo "$violations" | while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    echo "  $f:" >&2
    grep -nE "$joined_pattern" "$f" 2>/dev/null | head -5 | sed 's/^/    /' >&2
  done
  echo "" >&2
  echo "Patterns checked: ${PATTERNS[*]}" >&2
  echo "" >&2
  echo "Fix the offending file(s) before pushing. If a match is a legitimate use" >&2
  echo "(e.g., a new file that warrants exemption), add it to EXCLUDE_PATHS in" >&2
  echo "this script and re-run." >&2
  exit 2
fi

echo "✓ Anonymization guard PASS — no forbidden patterns in committed content"
