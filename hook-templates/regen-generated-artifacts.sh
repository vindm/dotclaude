#!/usr/bin/env bash
# After a migration / schema change, regenerate generated artifacts (e.g. db types).
# Configurable: dotclaude.yml `regenCommand` (e.g. "yarn db:types")
set -euo pipefail
COMMAND="{{#regenCommand}}{{regenCommand}}{{/regenCommand}}"
[[ -z "$COMMAND" ]] && exit 0
cd "$CLAUDE_PROJECT_DIR" && eval "$COMMAND" 2>&1 | tail -5
