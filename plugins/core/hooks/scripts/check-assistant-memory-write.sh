#!/usr/bin/env bash
# Block a Write/Edit that parks PROJECT knowledge in the assistant's own memory
# (~/.claude/projects/<slug>/memory/). That store is keyed by this machine's
# absolute project path — move or hand over the project and it is gone, silently.
# It is also invisible to the product's runtime, to every other checkout and to
# every teammate: knowledge parked there is a dependency nothing declares.
# Measured on the project that asked for this: 570 memory files, 76% about the
# engine, 0 of type `user`, and an index that had outgrown its load window.
#
# Config-driven & consumed as-is: reads the `memory:` block of the project's
# dotclaude.yml. NO-OP without a `homes:` list — a project that never opted in
# never feels it.
#
#   memory:
#     allowTypes:  [ user ]        # frontmatter `type:` values that MAY live here
#     allowScopes: [ universal ]   # frontmatter `scope:` values that MAY live here
#     exempt:      [ MEMORY.md ]   # basenames always writable (the index itself)
#     homes:                       # shown in the block: where each kind goes instead
#       - "engine anti-patterns, traps -> .claude/dotclaude/code-anti-patterns.md"
#
# A note is allowed only when it DECLARES why it may live here (type or scope);
# an undeclared note is project knowledge by default — the recoverable side.
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

homes=$(read_cfg memory.homes "")
# No `memory.homes` -> this project hasn't opted in. Silent no-op.
[ -z "$homes" ] && exit 0

payload=$(cat)
f=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || echo "")
[ -z "$f" ] && exit 0

# Only the assistant-memory store is policed.
case "$f" in
  */.claude/projects/*/memory/*) ;;
  *) exit 0 ;;
esac

# Escape hatch — create ONLY on the user's explicit ask; remove right after.
[ -f "$proj/.claude/.runtime/allow-memory-write" ] && exit 0

base=$(basename "$f")
exempt=$(read_cfg memory.exempt "")
[ -z "$exempt" ] && exempt="MEMORY.md"
while IFS= read -r e; do
  [ -n "$e" ] && [ "$base" = "$e" ] && exit 0
done <<EOF
$exempt
EOF

# The note's own declaration: a Write carries the content; an Edit edits what is
# on disk; a brand-new file reached by Edit has declared nothing.
tool=$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
if [ "$tool" = "Write" ]; then
  head_txt=$(printf '%s' "$payload" | jq -r '.tool_input.content // empty' 2>/dev/null | head -n 20)
elif [ -f "$f" ]; then
  head_txt=$(head -n 20 "$f" 2>/dev/null)
else
  head_txt=""
fi
note_type=$(printf '%s\n' "$head_txt" | sed -n 's/^[[:space:]]*type:[[:space:]]*//p' | head -n 1 | tr -d '[:space:]')
note_scope=$(printf '%s\n' "$head_txt" | sed -n 's/^[[:space:]]*scope:[[:space:]]*//p' | head -n 1 | tr -d '[:space:]')

allow_types=$(read_cfg memory.allowTypes "");   [ -z "$allow_types" ]  && allow_types="user"
allow_scopes=$(read_cfg memory.allowScopes ""); [ -z "$allow_scopes" ] && allow_scopes="universal"
while IFS= read -r t; do
  [ -n "$t" ] && [ -n "$note_type" ] && [ "$note_type" = "$t" ] && exit 0
done <<EOF
$allow_types
EOF
while IFS= read -r s; do
  [ -n "$s" ] && [ -n "$note_scope" ] && [ "$note_scope" = "$s" ] && exit 0
done <<EOF
$allow_scopes
EOF

homes_list=""
while IFS= read -r h; do
  [ -n "$h" ] && homes_list+="  - $h"$'\n'
done <<EOF
$homes
EOF
declared="type: ${note_type:-<none>}, scope: ${note_scope:-<none>}"
cat >&2 <<EOF
BLOCKED: project knowledge written to ASSISTANT MEMORY: $base
Assistant memory is keyed by this machine's absolute project path — it does not
move with the project and no runtime, checkout or teammate can read it. This note
declares $declared; only $(printf '%s' "$allow_types" | tr '\n' ',' | sed 's/,$//') (type) or $(printf '%s' "$allow_scopes" | tr '\n' ',' | sed 's/,$//') (scope) may live here.
Put it in the project home it belongs to:
${homes_list}A lesson that truly needs no project: add \`scope: universal\` to its frontmatter.
About the person you work with: \`type: user\` — or ~/.claude/CLAUDE.md.
Legit memory write (user asked for it) — ask first, then:
  touch "\$CLAUDE_PROJECT_DIR/.claude/.runtime/allow-memory-write"   # remove right after
EOF
exit 2
