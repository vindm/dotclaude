#!/usr/bin/env bash
# Block substantive Write/Edit/NotebookEdit in the MAIN checkout of the policed
# repo — such changes go through a dedicated git worktree, so concurrent AI
# sessions never collide in one checkout (shared git index staging a sibling's
# WIP; two sessions editing the same file).
#
# Config-driven & consumed as-is: reads the `worktree:` block from the project's
# dotclaude.yml (written by /dotclaude:worktree) instead of being a rendered
# per-project copy. NO-OP when there is no `worktree:` block — so it is safe to
# ship always-on: a project that hasn't opted into worktree discipline never
# feels it.
#
#   worktree:
#     policedRepo: <repo path relative to project root; "." if root IS the repo>
#     namePrefix:  <worktree dir prefix, e.g. myapp-wt->
#     exempt:      [ list of main-checkout globs that stay free — NEVER blanket
#                    *.md without the markdown-as-code check ]
#     setup:       [ optional fresh-worktree setup commands shown in the block ]
#     skillPath:   <optional lifecycle skill path for the block message>
#
# Wire as PreToolUse on "Write|Edit|NotebookEdit". Exit 0 = allow, 2 = block.

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

POLICED_REL=$(read_cfg worktree.policedRepo "")
# No worktree config -> this project hasn't opted in. Silent no-op.
[ -z "$POLICED_REL" ] && exit 0

PREFIX=$(read_cfg worktree.namePrefix "wt-")
SKILL=$(read_cfg worktree.skillPath ".claude/skills/worktree/SKILL.md")
# No arrays / mapfile — this must run under macOS's bash 3.2 too.

f=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || echo "")
[ -z "$f" ] && exit 0

# Resolve the TARGET file's repo (walk to the nearest EXISTING ancestor dir —
# a Write may create a file in a directory that doesn't exist yet).
dir=$(dirname "$f")
while [ ! -d "$dir" ] && [ "$dir" != "/" ]; do dir=$(dirname "$dir"); done

tgt_common=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo "")

# Only police the configured repo (it may sit BELOW the project root).
policed_common=$(git -C "$proj/$POLICED_REL" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo "")

# Guard a MISPLACED worktree write: a path that LOOKS like a worktree
# (.../<namePrefix>*/...) but does NOT resolve into the policed repo — a dropped
# path segment landing files in a stray sibling dir the "not in a repo" bail
# below would wave through. Stay silent if the policed repo can't be resolved.
case "$f" in
  */"$PREFIX"*)
    if [ -n "$policed_common" ] && [ "$tgt_common" != "$policed_common" ]; then
      cat >&2 <<EOF
BLOCKED: this path looks like a worktree but is NOT one: $f
A real worktree resolves into the policed repo; this path resolves outside it —
likely a path segment was dropped (files landing in a stray sibling dir). Get
the real absolute path from git and use THAT:
  git -C "$proj/$POLICED_REL" worktree list
EOF
      exit 2
    fi
    ;;
esac

[ -z "$tgt_common" ] && exit 0     # not in a git repo -> not ours
[ -z "$policed_common" ] && exit 0
[ "$tgt_common" = "$policed_common" ] || exit 0

# Worktree -> its git-dir lives under .git/worktrees/<name>, != common dir.
tgt_git=$(git -C "$dir" rev-parse --path-format=absolute --git-dir 2>/dev/null || echo "")
[ "$tgt_git" = "$tgt_common" ] || exit 0   # in a worktree -> allowed

# Escape hatch — create ONLY on the user's explicit ask; remove right after.
[ -f "$proj/.claude/.runtime/allow-main-edits" ] && exit 0

main_root=$(dirname "$tgt_common")
rel="${f#"$main_root"/}"

# Exempt paths in main stay freely editable.
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  # shellcheck disable=SC2053
  [[ "$rel" == $pat ]] && exit 0
done < <(read_cfg worktree.exempt "")

# Build the setup hint + exempt list for the block message.
setup_hint=""
while IFS= read -r s; do
  [ -n "$s" ] && setup_hint+="  $s"$'\n'
done < <(read_cfg worktree.setup "")
exempt_list=""
while IFS= read -r e; do
  [ -z "$e" ] && continue
  exempt_list+="${exempt_list:+|}$e"
done < <(read_cfg worktree.exempt "")

cat >&2 <<EOF
BLOCKED: substantive edit in the MAIN checkout: $rel
Concurrent sessions collide in main (shared index + working files) — every
substantive change goes through a dedicated worktree:

  git -C "$main_root" worktree add ../${PREFIX}<slug> -b feat/<slug>
${setup_hint}  # then edit ../${PREFIX}<slug>/$rel

Exempt in main: ${exempt_list}
Legit main edit (merge-conflict resolution, user-approved hotfix) — ask first, then:
  touch "\$CLAUDE_PROJECT_DIR/.claude/.runtime/allow-main-edits"   # remove right after
Lifecycle skill: ${SKILL}
EOF
exit 2
