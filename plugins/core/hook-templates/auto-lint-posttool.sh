#!/usr/bin/env bash
# After Write/Edit on TS/TSX/JS/JSX files, auto-run eslint --fix.
# Configurable: {{lint.command}} (default: npx eslint --fix)
#
# WHEN NOT TO USE THIS (per principles/lean-by-default.md — per-edit latency budget):
#   - The project already has lint-staged / a pre-commit formatter AND a
#     Definition-of-Done lint gate. Then this is REDUNDANT: the same fix runs
#     dozens of times per session instead of once at commit. Battle-tested setups
#     remove it for exactly this reason.
#   - The linter is slow (multi-second). A PostToolUse Write|Edit hook fires on
#     EVERY write; a slow command here taxes the whole session, compounded.
# Prefer linting at commit (lint-staged) + at done (DoD), not on every edit.
# Keep the per-edit tier for INSTANT, deterministic checks only (file-size,
# token/hex sweep, forbidden phrases, secret-leak). Ship this hook only if the
# project has NO lint-staged AND the formatter is genuinely fast (e.g. dprint).
set -euo pipefail
input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0
case "$file" in
  *.ts|*.tsx|*.js|*.jsx) {{#lint.command}}{{lint.command}}{{/lint.command}}{{^lint.command}}npx eslint --fix{{/lint.command}} "$file" 2>/dev/null || true ;;
esac
exit 0
