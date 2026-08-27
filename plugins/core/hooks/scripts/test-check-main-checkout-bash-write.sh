#!/usr/bin/env bash
# Drive check-main-checkout-bash-write.sh against a REAL fixture repository with a
# REAL worktree. Every case writes an actual file with an actual shell command and
# then asks the hook what it sees — nothing here restates the hook's condition.
#
#   bash test-check-main-checkout-bash-write.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/check-main-checkout-bash-write.sh"

FIX=$(mktemp -d "${TMPDIR:-/tmp}/main-bash-write-fixture.XXXXXX")
trap 'rm -rf "$FIX"' EXIT

PROJ="$FIX/proj"
REPO="$PROJ/repo"
mkdir -p "$REPO/docs" "$REPO/engine"
git init --quiet "$REPO"
git -C "$REPO" config user.email t@example.com
git -C "$REPO" config user.name  Test
echo one    > "$REPO/engine/gen.py"
echo "docs" > "$REPO/docs/GUIDE.md"
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m initial

cat > "$PROJ/dotclaude.yml" <<'YML'
worktree:
  policedRepo: repo
  namePrefix: repo-wt-
  exempt:
    - "docs/*"
YML

WT="$FIX/repo-wt-feature"
git -C "$REPO" worktree add --quiet -b feat/x "$WT" 2>/dev/null

export CLAUDE_PROJECT_DIR="$PROJ"
ESC="$PROJ/.claude/.runtime/allow-main-edits"
SID="fixed-session"
CACHE="$PROJ/.claude/.runtime/main-dirty.$SID"

pass=0; fail=0
t() {  # t <name> <want-exit>
  local got
  printf '{"session_id":"%s","tool_name":"Bash"}' "$SID" | bash "$HOOK" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$2" ]; then pass=$((pass+1)); printf 'ok   %s\n' "$1"
  else fail=$((fail+1)); printf 'FAIL %s (want exit %s, got %s)\n' "$1" "$2" "$got"; fi
}

echo "--- baseline ---"
t first-call-seeds-quietly        0
t unchanged-quiet                 0

echo "--- a shell write into MAIN is seen ---"
sed -i '' 's/one/two/' "$REPO/engine/gen.py" 2>/dev/null || sed -i 's/one/two/' "$REPO/engine/gen.py"
t sed-into-main-reported          2
t same-dirt-not-reported-twice    0

echo "--- a heredoc that CREATES a file is seen (no file_path anywhere) ---"
cat > "$REPO/engine/new_module.py" <<'PY'
x = 1
PY
t heredoc-created-file-reported   2

echo "--- exempt paths stay quiet ---"
echo "more docs" >> "$REPO/docs/GUIDE.md"
t exempt-path-quiet               0

echo "--- a write inside the WORKTREE is not a main write ---"
echo "wt change" >> "$WT/engine/gen.py"
t worktree-write-quiet            0

echo "--- escape hatch lifts it, same as the sibling hook ---"
echo "yet more" >> "$REPO/engine/gen.py"
mkdir -p "$(dirname "$ESC")"; touch "$ESC"
t escape-hatch-quiet              0
rm -f "$ESC" "$CACHE"

echo "--- no worktree block: silent no-op ---"
printf 'fileSize:\n  ceiling: 1000\n' > "$PROJ/dotclaude.yml"
t no-config-silent                0

echo "----- pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
