#!/usr/bin/env bash
# Report a note that a Bash command just wrote into ASSISTANT MEMORY — the hole
# its sibling check-assistant-memory-write.sh cannot see.
#
# The mistake class is the one already fixed once in this plugin, for the main
# checkout: the sibling matches Write|Edit|NotebookEdit and reads
# tool_input.file_path, so a heredoc, a `tee`, a `python3 -c` or a `cat >` walks
# straight past it. For assistant memory this is not a corner case but the main
# road — a memory file is routinely rewritten by a script (an index re-sort, a
# batch cleanup, a project whose encoding rule forbids the editor tools), and a
# session working in that style never meets the guard at all.
#
# MEASURED, on the project that asked for the sibling: the pre-tool hook shipped
# 2026-09-03 with the `memory:` block configured and the escape hatch closed —
# and memory still grew by 90 notes over the next five days (10/10/13/35/22),
# none declaring `scope`, every one carrying a `type` the block forbids. One door
# of two was guarded, and the traffic used the other.
#
# 🔴 WHY OUTCOME AND NOT PATTERN. Grepping the command for write verbs is dodged
# by a quoted path, a `cd`, a variable, a shell function, or a mechanism nobody
# has invented yet. This hook asks the filesystem what actually happened: it
# snapshots the memory dir and diffs it against the same session's previous
# answer. It never looks at the verb, so nothing dodges it.
#
# 🔴 WHAT THIS IS: a detector with a recovery instruction, NOT a preventer.
# PostToolUse runs after the command; exit 2 only shows this text to Claude. That
# is acceptable for the same reason as the sibling's: a stray note is fully
# reversible (delete it, put the knowledge in its real home), so detection plus an
# exact undo restores the invariant — and a second, dodgeable pre-blocker would be
# a second home for one rule.
#
# Config-driven: reuses the `memory:` block check-assistant-memory-write.sh reads
# (allowTypes / allowScopes / exempt / homes). NO-OP when there is no such block.
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

# Settles the common case without spawning python3 on every Bash call.
[ -f "$yml" ] || exit 0

homes=$(read_cfg memory.homes "")
# No `memory.homes` -> this project has not opted in. Silent no-op, exactly like
# the pre-tool sibling, so one config switch governs both doors.
[ -z "$homes" ] && exit 0

# The memory store is keyed by the project's absolute path with `/` -> `-`.
slug=$(printf '%s' "$proj" | tr '/' '-')
mem="$HOME/.claude/projects/$slug/memory"
[ -d "$mem" ] || exit 0

payload=$(cat)
sid=""
if command -v jq >/dev/null 2>&1; then
  sid=$(printf '%s' "$payload" | jq -r '.session_id // empty' 2>/dev/null)
fi

rt="$proj/.claude/.runtime"
mkdir -p "$rt" 2>/dev/null
cache="$rt/memory-state.${sid:-nosession}"

# Snapshot: one line per note, `<mtime> <name>`, so both a NEW file and a
# REWRITTEN one show up as a changed line.
now=$(mktemp "${TMPDIR:-/tmp}/memory-state.XXXXXX")
trap 'rm -f "$now"' EXIT

exempt_list=$(read_cfg memory.exempt "")
[ -z "$exempt_list" ] && exempt_list="MEMORY.md"

: > "$now"
while IFS= read -r path; do
  [ -z "$path" ] && continue
  base=$(basename "$path")
  keep=1
  while IFS= read -r e; do
    [ -n "$e" ] && [ "$base" = "$e" ] && { keep=0; break; }
  done <<< "$exempt_list"
  [ "$keep" = "0" ] && continue
  st=$(stat -f '%m' "$path" 2>/dev/null || stat -c '%Y' "$path" 2>/dev/null || echo 0)
  printf '%s %s\n' "$st" "$base" >> "$now"
done < <(find "$mem" -maxdepth 1 -type f -name '*.md' 2>/dev/null)
sort -o "$now" "$now"

# First call of a session seeds the baseline and says nothing — notes written
# before this session are not its doing, and reporting them would train the
# reader to ignore this hook.
if [ ! -f "$cache" ]; then
  cp "$now" "$cache" 2>/dev/null
  find "$rt" -name 'memory-state.*' -mtime +1 -delete 2>/dev/null
  exit 0
fi

changed=$(comm -13 "$cache" "$now" | awk '{ $1=""; sub(/^ /,""); print }' | sort -u)
cp "$now" "$cache" 2>/dev/null

# Same escape hatch as the sibling, so one flag lifts both — but checked HERE,
# after the snapshot has moved on, not before it. Leaving early would keep the
# sanctioned notes out of the baseline, and they would then surface as "new" on
# the first call after the hatch is removed: a false report about a write the
# user had explicitly approved. Its test case is the one that caught this.
[ -f "$proj/.claude/.runtime/allow-memory-write" ] && exit 0

[ -z "$changed" ] && exit 0

# A changed note is reported only when its OWN declaration does not permit it to
# live here — the same question the pre-tool sibling asks of the payload.
allow_types=$(read_cfg memory.allowTypes "");   [ -z "$allow_types" ]  && allow_types="user"
allow_scopes=$(read_cfg memory.allowScopes ""); [ -z "$allow_scopes" ] && allow_scopes="universal"

offending=""
while IFS= read -r base; do
  [ -z "$base" ] && continue
  f="$mem/$base"
  [ -f "$f" ] || continue
  head_txt=$(head -n 20 "$f" 2>/dev/null)
  nt=$(printf '%s\n' "$head_txt" | sed -n 's/^[[:space:]]*type:[[:space:]]*//p'  | head -n 1 | tr -d '[:space:]')
  ns=$(printf '%s\n' "$head_txt" | sed -n 's/^[[:space:]]*scope:[[:space:]]*//p' | head -n 1 | tr -d '[:space:]')
  ok=0
  while IFS= read -r t; do
    [ -n "$t" ] && [ -n "$nt" ] && [ "$nt" = "$t" ] && { ok=1; break; }
  done <<< "$allow_types"
  if [ "$ok" = "0" ]; then
    while IFS= read -r s; do
      [ -n "$s" ] && [ -n "$ns" ] && [ "$ns" = "$s" ] && { ok=1; break; }
    done <<< "$allow_scopes"
  fi
  [ "$ok" = "0" ] && offending+="  - $base (type: ${nt:-<none>}, scope: ${ns:-<none>})"$'\n'
done <<< "$changed"

[ -z "$offending" ] && exit 0

homes_list=""
while IFS= read -r h; do
  [ -n "$h" ] && homes_list+="  - $h"$'\n'
done <<< "$homes"

count=$(printf '%s' "$offending" | grep -c .)
cat >&2 <<EOF
ASSISTANT MEMORY WRITTEN BY A SHELL COMMAND — $count note(s) the memory: block forbids:
${offending}
Assistant memory is keyed by this machine's absolute project path — it does not move
with the project, and no runtime, checkout or teammate can read it. The command already
ran, so undo it by hand: delete the note and put the knowledge in its home.
${homes_list}A lesson that truly needs no project: add \`scope: universal\` to its frontmatter.
About the person you work with: \`type: user\` — or ~/.claude/CLAUDE.md.
Legit memory write (the user asked for it) — ask first, then:
  touch "\$CLAUDE_PROJECT_DIR/.claude/.runtime/allow-memory-write"   # remove right after
EOF
exit 2
