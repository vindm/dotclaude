#!/usr/bin/env bash
# Report a file that a Bash command just wrote into the MAIN checkout of the
# policed repo — the hole its sibling check-main-checkout-edit.sh cannot see.
#
# The mistake class: that sibling matches Write|Edit|NotebookEdit and reads
# tool_input.file_path. A `sed -i`, a heredoc redirect, a `tee`, a `python3 -c`
# that opens a file for writing — none of them carry a file_path, so all of them
# walk straight past worktree isolation. Worse, some projects REQUIRE the shell
# route for certain files (an encoding rule that forbids the editor tools), which
# points the riskiest writes at the unguarded door.
#
# 🔴 WHY OUTCOME AND NOT PATTERN. The obvious implementation greps the command
# string for write verbs. That check is dodged by a quoted path, a `cd` first, a
# variable, a shell function, a python one-liner, or any write mechanism nobody has
# invented yet — an invariant a rename can dodge is anchored on the wrong thing.
# This hook instead asks the repository what actually happened: `git status` on the
# main checkout, diffed against the same session's previous answer. Nothing can
# dodge it, including future write mechanisms, because it never looks at the verb.
#
# 🔴 WHAT THIS IS: a detector with a recovery instruction, NOT a preventer. A
# PostToolUse hook cannot block — the command already ran (exit 2 only shows this
# text to Claude). That is acceptable here and the reason is worth stating rather
# than filing as a gap: a stray write into the main checkout is fully reversible
# (move the change to the worktree, `git checkout -- <path>`), so detection plus an
# exact undo restores the invariant. Adding a pattern-matching pre-blocker on top
# would create a second, dodgeable home for one rule.
#
# Config-driven: reuses the `worktree:` block that check-main-checkout-edit.sh
# already reads (policedRepo + exempt). NO-OP when there is no such block.
#
# Wire as PostToolUse on "Bash". Exit 0 = quiet, 2 = report to Claude.

set -uo pipefail

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

# Costs nothing and settles the common case: a consumer with no dotclaude.yml pays
# a `test -f`, not a python3 spawn plus a git round trip, on every Bash call.
[ -f "$yml" ] || exit 0

POLICED_REL=$(read_cfg worktree.policedRepo "")
[ -z "$POLICED_REL" ] && exit 0

# Same escape hatch as the sibling hook, so one flag lifts both.
[ -f "$proj/.claude/.runtime/allow-main-edits" ] && exit 0

common=$(git -C "$proj/$POLICED_REL" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo "")
[ -z "$common" ] && exit 0
main_root=$(dirname "$common")
[ -d "$main_root" ] || exit 0

payload=$(cat)
sid=""
if command -v jq >/dev/null 2>&1; then
  sid=$(printf '%s' "$payload" | jq -r '.session_id // empty' 2>/dev/null)
fi

rt="$proj/.claude/.runtime"
mkdir -p "$rt" 2>/dev/null
cache="$rt/main-dirty.${sid:-nosession}"

# Current dirty set, exempt paths removed. Rename entries ("old -> new") are
# reduced to the destination — that is the path now sitting in main.
now=$(mktemp "${TMPDIR:-/tmp}/main-dirty.XXXXXX")
trap 'rm -f "$now"' EXIT

# Read the exempt list ONCE. Reading it per dirty path would spawn a python3 per
# file on every single Bash call — a guard nobody keeps.
exempt_list=$(read_cfg worktree.exempt "")

: > "$now"
while IFS= read -r rel; do
  [ -z "$rel" ] && continue
  keep=1
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    # shellcheck disable=SC2053
    if [[ "$rel" == $pat ]]; then keep=0; break; fi
  done <<< "$exempt_list"
  [ "$keep" = "1" ] && printf '%s\n' "$rel" >> "$now"
done < <(git -C "$main_root" status --porcelain 2>/dev/null \
           | cut -c4- | sed 's/.* -> //' | sed 's/^"//; s/"$//')
sort -o "$now" "$now"

# First call of a session seeds the baseline and says nothing — pre-existing WIP in
# main is not this session's doing, and reporting it would train the reader to
# ignore this hook.
if [ ! -f "$cache" ]; then
  cp "$now" "$cache" 2>/dev/null
  # Once per session, on the cold path only — never on the per-call hot path.
  find "$rt" -name 'main-dirty.*' -mtime +1 -delete 2>/dev/null
  exit 0
fi

new=$(comm -13 "$cache" "$now")
cp "$now" "$cache" 2>/dev/null
[ -z "$new" ] && exit 0

count=$(printf '%s\n' "$new" | grep -c . )
cat >&2 <<EOF
MAIN CHECKOUT WRITTEN BY A SHELL COMMAND — $count new path(s) in $main_root:
$(printf '%s\n' "$new" | sed 's/^/  /')

Substantive changes belong in a worktree; concurrent sessions share this checkout's
index and working files. The command already ran, so restore it by hand:

  # if the change is wanted — redo it inside your worktree, then in main:
  git -C "$main_root" checkout -- <path>        # tracked file
  rm "$main_root/<path>"                        # file the command created

If this really was a legitimate main edit (merge-conflict resolution, an approved
hotfix), say so and set the flag the sibling hook reads:
  touch "\$CLAUDE_PROJECT_DIR/.claude/.runtime/allow-main-edits"   # remove right after
EOF
exit 2
