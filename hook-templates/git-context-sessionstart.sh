#!/usr/bin/env bash
# Inject git branch + last commit summary at session start.
# Used as a Claude Code SessionStart hook.
set -euo pipefail
branch=$(cd "$CLAUDE_PROJECT_DIR" && git branch --show-current 2>/dev/null || echo 'detached')
last=$(cd "$CLAUDE_PROJECT_DIR" && git log --oneline -1 2>/dev/null || echo 'no commits')
echo "{\"additionalContext\": \"Git: $branch | $last\"}"
