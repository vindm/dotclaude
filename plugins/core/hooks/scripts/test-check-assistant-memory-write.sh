#!/usr/bin/env bash
# Drive check-assistant-memory-write.sh against a REAL fixture: a project with a
# `memory:` block, a fake ~/.claude/projects/<slug>/memory/ store, and actual
# Write/Edit payloads. Nothing here restates the hook's condition.
#
#   bash test-check-assistant-memory-write.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/check-assistant-memory-write.sh"

FIX=$(mktemp -d "${TMPDIR:-/tmp}/memory-write-fixture.XXXXXX")
trap 'rm -rf "$FIX"' EXIT

PROJ="$FIX/proj"; BARE="$FIX/bare"
MEM="$FIX/home/.claude/projects/-fix-proj/memory"
mkdir -p "$PROJ" "$BARE" "$MEM/archive" "$PROJ/repo"
cat > "$PROJ/dotclaude.yml" <<'YML'
memory:
  allowTypes:
    - user
  allowScopes:
    - universal
  homes:
    - "engine anti-patterns -> repo/.claude/dotclaude/code-anti-patterns.md"
    - "engine rules -> repo/policies/"
YML
printf 'fileSize:\n  ceiling: 1000\n' > "$BARE/dotclaude.yml"

printf -- '---\ntype: project\n---\nold note\n' > "$MEM/existing-project-note.md"
printf -- '---\ntype: user\n---\nDima prefers plain prose\n' > "$MEM/existing-user-note.md"
printf -- '# Index\n' > "$MEM/MEMORY.md"

pass=0; fail=0
t() {  # t <name> <want-exit> <tool> <path> [content]
  local got payload
  if [ "$3" = "Write" ]; then
    payload=$(jq -n --arg t "$3" --arg p "$4" --arg c "${5:-}" '{tool_name:$t,tool_input:{file_path:$p,content:$c}}')
  else
    payload=$(jq -n --arg t "$3" --arg p "$4" '{tool_name:$t,tool_input:{file_path:$p,old_string:"a",new_string:"b"}}')
  fi
  printf '%s' "$payload" | bash "$HOOK" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$2" ]; then pass=$((pass+1)); printf 'ok   %s\n' "$1"
  else fail=$((fail+1)); printf 'FAIL %s (want exit %s, got %s)\n' "$1" "$2" "$got"; fi
}

echo "--- no memory: block -> silent no-op ---"
export CLAUDE_PROJECT_DIR="$BARE"
t unconfigured-project-quiet        0 Write "$MEM/new-project-note.md" $'---\ntype: project\n---\nx'

export CLAUDE_PROJECT_DIR="$PROJ"
echo "--- writes OUTSIDE the memory store are not ours ---"
t write-into-repo-quiet             0 Write "$PROJ/repo/notes.md"      $'---\ntype: project\n---\nx'

echo "--- a Write of project knowledge into memory is blocked ---"
t write-type-project-blocked        2 Write "$MEM/new-project-note.md"  $'---\nname: n\ntype: project\n---\nx'
t write-type-feedback-blocked       2 Write "$MEM/new-feedback-note.md" $'---\ntype: feedback\n---\nx'
t write-type-reference-blocked      2 Write "$MEM/new-ref-note.md"      $'---\ntype: reference\n---\nx'
t write-no-frontmatter-blocked      2 Write "$MEM/bare-note.md"         'just prose, declares nothing'
t write-into-archive-blocked        2 Write "$MEM/archive/old.md"       $'---\ntype: project\n---\nx'

echo "--- a note that DECLARES why it may live here passes ---"
t write-type-user-allowed           0 Write "$MEM/about-dima.md"        $'---\ntype: user\n---\nx'
t write-scope-universal-allowed     0 Write "$MEM/universal-lesson.md"  $'---\ntype: feedback\nscope: universal\n---\nx'
t write-indented-type-user-allowed  0 Write "$MEM/about-dima-2.md"      $'---\nmetadata:\n  type: user\n---\nx'

echo "--- an Edit judges the file on disk ---"
t edit-existing-project-blocked     2 Edit  "$MEM/existing-project-note.md"
t edit-existing-user-allowed        0 Edit  "$MEM/existing-user-note.md"
t edit-new-file-undeclared-blocked  2 Edit  "$MEM/does-not-exist-yet.md"

echo "--- the index stays writable ---"
t edit-index-allowed                0 Edit  "$MEM/MEMORY.md"
t write-index-allowed               0 Write "$MEM/MEMORY.md" '# Index'

echo "--- escape hatch ---"
mkdir -p "$PROJ/.claude/.runtime"; touch "$PROJ/.claude/.runtime/allow-memory-write"
t escape-hatch-allows               0 Write "$MEM/new-project-note.md"  $'---\ntype: project\n---\nx'
rm -f "$PROJ/.claude/.runtime/allow-memory-write"
t escape-hatch-removed-blocks-again 2 Write "$MEM/new-project-note.md"  $'---\ntype: project\n---\nx'

echo "--- the block message names the homes ---"
msg=$(jq -n --arg p "$MEM/x.md" '{tool_name:"Write",tool_input:{file_path:$p,content:"---\ntype: project\n---\nx"}}' | bash "$HOOK" 2>&1 >/dev/null)
if printf '%s' "$msg" | grep -q "code-anti-patterns.md" && printf '%s' "$msg" | grep -q "repo/policies/"; then
  pass=$((pass+1)); echo "ok   block-message-lists-homes"
else fail=$((fail+1)); echo "FAIL block-message-lists-homes"; printf '%s\n' "$msg"; fi

echo; echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]
