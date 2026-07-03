#!/usr/bin/env bash
# Block substantive Write/Edit/NotebookEdit in the MAIN checkout of the policed
# repo — such changes go through a dedicated git worktree, so concurrent AI
# sessions never collide in one checkout (shared git index staging a sibling's
# WIP; two sessions editing the same file).
#
# Wire as PreToolUse on "Write|Edit|NotebookEdit". Exit 0 = allow, 2 = block.
#
# Template placeholders (substituted by /dotclaude:worktree; named without
# braces here so substitution never touches this comment block):
#   worktree.policedRepo       — repo path RELATIVE to the project root ("." when
#                                the project root is itself the repo)
#   worktree.exemptCasePattern — joined case-glob of main-checkout paths that stay
#                                free, e.g.: docs/*|README.md|LICENSE*
#                                CAUTION: do NOT blanket-exempt *.md without the
#                                markdown-as-code check (see principles/worktree-discipline.md)
#   worktree.namePrefix        — worktree dir prefix, e.g. myapp-wt-
#   worktree.setupLines        — the project's fresh-worktree setup command(s)
#                                shown in the block message (recreate git-ignored
#                                per-machine files: .env, config, node_modules …)
#
# Allowed:
#   - edits inside ANY worktree of the policed repo (git-dir != git-common-dir)
#   - exempt paths in main (see above)
#   - anything outside the policed repo (other repos, memory, scratch)
#   - escape hatch (merge-conflict resolution, user-approved hotfix — ask first):
#       touch "$CLAUDE_PROJECT_DIR/.claude/.runtime/allow-main-edits"
#     (remove right after)

set -uo pipefail

f=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || echo "")
[ -z "$f" ] && exit 0

# Resolve the TARGET file's repo (walk to the nearest EXISTING ancestor dir —
# a Write may create a file in a directory that doesn't exist yet).
dir=$(dirname "$f")
while [ ! -d "$dir" ] && [ "$dir" != "/" ]; do dir=$(dirname "$dir"); done

tgt_common=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo "")
[ -z "$tgt_common" ] && exit 0   # not in a git repo -> not ours

# Only police the configured repo (it may sit BELOW the project root).
proj="${CLAUDE_PROJECT_DIR:-$PWD}"
policed_common=$(git -C "$proj/{{worktree.policedRepo}}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo "")
[ -z "$policed_common" ] && exit 0
[ "$tgt_common" = "$policed_common" ] || exit 0

# Worktree -> its git-dir lives under .git/worktrees/<name>, != common dir.
tgt_git=$(git -C "$dir" rev-parse --path-format=absolute --git-dir 2>/dev/null || echo "")
[ "$tgt_git" = "$tgt_common" ] || exit 0   # in a worktree -> allowed

# Escape hatch — create ONLY on the user's explicit ask; remove right after.
[ -f "$proj/.claude/.runtime/allow-main-edits" ] && exit 0

main_root=$(dirname "$tgt_common")
rel="${f#"$main_root"/}"
case "$rel" in
  {{worktree.exemptCasePattern}}) exit 0 ;;
esac

cat >&2 <<EOF
BLOCKED: substantive edit in the MAIN checkout: $rel
Concurrent sessions collide in main (shared index + working files) — every
substantive change goes through a dedicated worktree:

  git -C "$main_root" worktree add ../{{worktree.namePrefix}}<slug> -b feat/<slug>
{{worktree.setupLines}}
  # then edit ../{{worktree.namePrefix}}<slug>/$rel

Exempt in main: {{worktree.exemptCasePattern}}
Legit main edit (merge-conflict resolution, user-approved hotfix) — ask first, then:
  touch "\$CLAUDE_PROJECT_DIR/.claude/.runtime/allow-main-edits"   # remove right after
Lifecycle skill: .claude/skills/worktree/SKILL.md
EOF
exit 2
