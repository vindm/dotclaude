#!/usr/bin/env bash
# Drive check-assistant-memory-bash-write.sh against a REAL memory store written by
# REAL shell commands. Every case writes an actual note the way a session would (a
# heredoc, a `cat >`, a python one-liner) and then asks the hook what it sees —
# nothing here restates the hook's condition.
#
#   bash test-check-assistant-memory-bash-write.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/check-assistant-memory-bash-write.sh"

FIX=$(mktemp -d "${TMPDIR:-/tmp}/memory-bash-write-fixture.XXXXXX")
trap 'rm -rf "$FIX"' EXIT

PROJ="$FIX/proj"
mkdir -p "$PROJ"
export CLAUDE_PROJECT_DIR="$PROJ"
export HOME="$FIX/home"                       # the store lives under $HOME
SLUG=$(printf '%s' "$PROJ" | tr '/' '-')
MEM="$HOME/.claude/projects/$SLUG/memory"
mkdir -p "$MEM"

ESC="$PROJ/.claude/.runtime/allow-memory-write"
SID="fixed-session"
CACHE="$PROJ/.claude/.runtime/memory-state.$SID"

note() {  # note <file> <type> [scope]  — written by a SHELL command, on purpose
  local f="$MEM/$1" ty="$2" sc="${3:-}"
  { echo "---"
    echo "name: ${1%.md}"
    echo "description: fixture"
    echo "metadata:"
    echo "  type: $ty"
    [ -n "$sc" ] && echo "  scope: $sc"
    echo "---"
    echo "body"
  } > "$f"
}

pass=0; fail=0
t() {  # t <name> <want-exit>
  printf '{"session_id":"%s","tool_name":"Bash"}' "$SID" | bash "$HOOK" >/dev/null 2>&1
  local got=$?
  if [ "$got" = "$2" ]; then pass=$((pass+1)); printf '  ok   %s\n' "$1"
  else fail=$((fail+1)); printf '  FAIL %s (want exit %s, got %s)\n' "$1" "$2" "$got"; fi
}

echo "check-assistant-memory-bash-write"

# 1. No dotclaude.yml at all -> silent.
t "no dotclaude.yml -> quiet" 0

# 2. A dotclaude.yml WITHOUT a memory: block -> this project has not opted in.
cat > "$PROJ/dotclaude.yml" <<'YML'
worktree:
  policedRepo: repo
YML
t "no memory: block -> quiet" 0

# 3. Opt in. The first call of a session seeds the baseline and says nothing.
cat > "$PROJ/dotclaude.yml" <<'YML'
memory:
  allowTypes:
    - user
  allowScopes:
    - universal
  exempt:
    - MEMORY.md
  homes:
    - "a rule the runtime obeys -> policies/"
YML
note pre-existing.md project
t "first call seeds baseline -> quiet" 0

# 4. A note written by a shell heredoc, of a forbidden type -> reported.
note leaked.md project
t "shell-written project note -> reported" 2

# 5. Same state again, nothing new -> quiet (the report is not sticky).
t "no change since last call -> quiet" 0

# 6. An allowed type passes.
note about-dima.md user
t "type: user -> quiet" 0

# 7. An allowed scope passes even with a forbidden type.
note universal-lesson.md feedback universal
t "scope: universal -> quiet" 0

# 8. The exempt index is not policed.
printf 'index\n' > "$MEM/MEMORY.md"
t "exempt MEMORY.md -> quiet" 0

# 9. A REWRITE of an existing forbidden note is caught, not only a new file.
sleep 1
printf 'rewritten by a shell command\n' >> "$MEM/leaked.md"
t "rewrite of an existing note -> reported" 2

# 10. The escape hatch lifts the guard.
mkdir -p "$(dirname "$ESC")"; touch "$ESC"
note second-leak.md project
t "escape hatch -> quiet" 0
rm -f "$ESC"

# 11. And a note reached through the hatch is not reported afterwards either —
#     the snapshot moved on while the hatch was open, which is the intent.
t "after hatch removed, earlier write not re-reported" 0

echo
echo "$pass passed, $fail failed"
[ "$fail" = "0" ]
