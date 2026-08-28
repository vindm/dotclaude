#!/usr/bin/env bash
# Block a STOP whose final message CLAIMS delivery the repository state denies.
#
# The mistake class: "merged into main", "pushed", "all gates green" describe the
# author's desk, not the recipient's machine. Said in a final message they read as
# fact and nothing revises them — work sits unpushed for days while every summary
# says it shipped. A rule with no trigger is not a rule, so this is the trigger.
#
# WHAT IT IS NOT: a check for unfinished work. Stop fires after EVERY turn,
# including mid-task ones, and a hook that nags about a dirty tree on every reply
# gets disabled within a day. This hook reads the claim the message actually makes
# and asserts EXACTLY the rung that claim names — no claim, no sound.
#
#   claimed "committed"  -> no uncommitted changes in any worktree
#   claimed "merged"     -> the branch tip is an ancestor of <mainBranch>
#   claimed "pushed"     -> <remote>/<mainBranch>..<mainBranch> is empty
#   claimed "verified"   -> the gates receipt is fresh, 0 failed, 0 skipped
#
# There is deliberately NO magic escape phrase. A declaration must not be able to
# silence the check that asked for it. The ways out are: make the state true, stop
# asserting what is not, or the loop guard below.
#
# Config-driven & consumed as-is: reads the `delivery:` block from the project's
# dotclaude.yml. NO-OP when there is no such block — safe to ship always-on.
#
#   delivery:
#     repo:         <repo path relative to project root; "." if root IS the repo>
#     mainBranch:   <default: main>
#     remote:       <default: origin>
#     gatesCommand: <shown in the block message so the fix is one paste>
#     claimsCommitted / claimsMerged / claimsPushed / claimsVerified:
#                   <project vocabulary added to the shipped English defaults>
#
# 🔴 Those four phrase keys are FLAT (claimsPushed), not nested (claims.pushed),
# on purpose. _read_dotclaude_yml.py prefers PyYAML but falls back to a bundled
# minimal parser that reads exactly two levels. Nested keys would resolve to
# nothing on a machine without PyYAML, no phrase would match, and the hook would
# go permanently and silently quiet — the worst failure available to a guard. Do
# not "tidy" these into a nested block.
#
# Wire as Stop. Exit 0 = let the turn end, 2 = block (stderr is shown to Claude,
# which then gets another turn).

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
proj="${CLAUDE_PROJECT_DIR:-$PWD}"
yml="$proj/dotclaude.yml"
reader="$HERE/_read_dotclaude_yml.py"
claimer="$HERE/_delivery_claim.py"

read_cfg() {  # <dotted.key> <default>
  if command -v python3 >/dev/null 2>&1 && [ -f "$reader" ]; then
    python3 "$reader" "$yml" "$1" "$2" 2>/dev/null || printf '%s' "$2"
  else
    printf '%s' "$2"
  fi
}

# Free bail-out before any spawn — see the note in check-main-checkout-bash-write.sh.
[ -f "$yml" ] || exit 0

REPO_REL=$(read_cfg delivery.repo "")
# No delivery config -> this project hasn't opted in. Silent no-op.
[ -z "$REPO_REL" ] && exit 0

REPO="$proj/$REPO_REL"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || exit 0

MAIN=$(read_cfg delivery.mainBranch "main")
REMOTE=$(read_cfg delivery.remote "origin")
GATES_CMD=$(read_cfg delivery.gatesCommand "")

payload=$(cat)

# Unicode claim folding needs python3 (macOS bash 3.2 cannot lowercase non-ASCII).
# Without it the hook would match nothing and look like a passing guard, so it says
# so — once per session, not on every turn.
if ! command -v python3 >/dev/null 2>&1 || [ ! -f "$claimer" ]; then
  warn="$proj/.claude/.runtime/delivery-nopython"
  if [ ! -f "$warn" ]; then
    mkdir -p "$(dirname "$warn")" 2>/dev/null && : > "$warn"
    echo "delivery gate INACTIVE: python3 or $claimer missing — claims are not being checked." >&2
  fi
  exit 0
fi

cwd=""; sid=""
if command -v jq >/dev/null 2>&1; then
  { read -r cwd; read -r sid; } < <(printf '%s' "$payload" | jq -r '(.cwd // ""), (.session_id // "")' 2>/dev/null)
fi

rungs=$(printf '%s' "$payload" | python3 "$claimer" claims "$yml" 2>/dev/null)
[ -z "$rungs" ] && exit 0

_sha() {
  if command -v shasum >/dev/null 2>&1; then shasum | awk '{print $1}'
  else sha1sum | awk '{print $1}'; fi
}

claims() { printf '%s\n' "$rungs" | cut -f1 | grep -qx "$1"; }
phrase_for() { printf '%s\n' "$rungs" | awk -F'\t' -v r="$1" '$1==r{print $2; exit}'; }

# ---- gather state -----------------------------------------------------------

# The receipt and the loop-guard fingerprint belong to the worktree the session is
# actually sitting in; fall back to the main checkout when cwd is elsewhere.
tgt="$REPO"
repo_common=$(git -C "$REPO" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo "")
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  cwd_common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo "")
  if [ -n "$cwd_common" ] && [ "$cwd_common" = "$repo_common" ]; then
    tgt=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || echo "$REPO")
  fi
fi

head_sha=$(git -C "$tgt" rev-parse HEAD 2>/dev/null || echo "")
dirty_sha=$(git -C "$tgt" status --porcelain 2>/dev/null | _sha)

# Uncommitted — in THIS session's worktree, not every worktree of the repo.
#
# 🔴 Scoped deliberately. Where several agent sessions share one repo through
# worktrees (the setup the sibling worktree guard exists for), checking all of them
# blocks "I committed" because a NEIGHBOURING session has work in progress. The
# author can only speak for their own tree, and a guard that fires on someone else's
# dirt is a false positive on day one — which is how a guard gets switched off.
# Falls back to every worktree only when cwd is outside the repo, i.e. when there is
# no "own" tree to point at; the message says which case it is.
dirty_lines=""
dirty_scope="this worktree"
scan_all=0
if [ "$tgt" = "$REPO" ] && [ -n "$cwd" ]; then
  cwd_common2=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo "")
  [ "$cwd_common2" = "$repo_common" ] || scan_all=1
elif [ -z "$cwd" ]; then
  scan_all=1
fi
if [ "$scan_all" = "1" ]; then
  dirty_scope="every worktree (this turn ran outside the repo, so there is no own tree to scope to)"
fi

_scan_dirty() {  # <worktree path>
  st=$(git -C "$1" status --porcelain 2>/dev/null | head -8)
  [ -z "$st" ] && return
  n=$(git -C "$1" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  dirty_lines+="    $1 — $n uncommitted:"$'\n'
  dirty_lines+="$(printf '%s\n' "$st" | sed 's/^/      /')"$'\n'
}

if [ "$scan_all" = "1" ]; then
  while IFS= read -r wt; do
    [ -z "$wt" ] && continue
    _scan_dirty "$wt"
  done < <(git -C "$REPO" worktree list --porcelain 2>/dev/null | awk '$1=="worktree"{print $2}')
else
  _scan_dirty "$tgt"
fi

# Unmerged feature branches.
unmerged=""
while IFS= read -r wt; do
  [ -z "$wt" ] && continue
  b=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  # Detached HEAD and the main branch itself are not "an unmerged feature branch".
  if [ -z "$b" ] || [ "$b" = "HEAD" ] || [ "$b" = "$MAIN" ]; then continue; fi
  if ! git -C "$REPO" merge-base --is-ancestor "$b" "$MAIN" 2>/dev/null; then
    ahead_b=$(git -C "$REPO" rev-list --count "$MAIN..$b" 2>/dev/null || echo "?")
    unmerged+="    $b — $ahead_b commit(s) not in $MAIN"$'\n'
  fi
done < <(git -C "$REPO" worktree list --porcelain 2>/dev/null | awk '$1=="worktree"{print $2}')

# Commits that exist on NO remote. Measured as `<tip> --not --remotes`, which asks
# the honest question — "is this work anywhere but this machine?" — instead of the
# narrow one. An earlier version compared only <remote>/<main>..<main> and let
# "pushed" pass while every commit sat on an unpushed feature branch: main was level
# with origin because the work had never reached it.
#
# Never fetches: a network call on every turn is not acceptable. So it measures
# against the last known remote refs and can over-report work that someone else has
# since pushed. That direction is the safe one.
unpushed=0
unpushed_where=""
remote_known=1
if [ -z "$(git -C "$REPO" remote 2>/dev/null)" ]; then
  remote_known=0
else
  tips=""
  while IFS= read -r tip; do
    [ -z "$tip" ] && continue
    tips="$tips $tip"
    c=$(git -C "$REPO" rev-list --count "$tip" --not --remotes 2>/dev/null || echo 0)
    [ "${c:-0}" -gt 0 ] && unpushed_where+="    reachable from $tip: $c"$'\n'
  done < <(
    {
      git -C "$REPO" rev-parse --verify --quiet "$MAIN" >/dev/null 2>&1 && printf '%s\n' "$MAIN"
      git -C "$REPO" worktree list --porcelain 2>/dev/null \
        | awk '$1=="branch"{sub("refs/heads/","",$2); print $2}'
    } | sort -u          # main is usually BOTH the branch and a worktree branch
  )
  # The TOTAL is the union, not the sum. Summing per-branch counts double-counts a
  # commit that a feature branch and main both contain after a merge — which is the
  # normal state at exactly the moment this hook runs.
  # shellcheck disable=SC2086
  [ -n "$tips" ] && unpushed=$(git -C "$REPO" rev-list --count $tips --not --remotes 2>/dev/null || echo 0)
fi

# ---- judge each claimed rung ------------------------------------------------

violations=""

if claims committed && [ -n "$dirty_lines" ]; then
  violations+="  CLAIMED \"$(phrase_for committed)\" — but $dirty_scope is not clean:"$'\n'
  violations+="$dirty_lines"
fi

if claims merged && [ -n "$unmerged" ]; then
  violations+="  CLAIMED \"$(phrase_for merged)\" — but these are not in $MAIN:"$'\n'
  violations+="$unmerged"
fi

if claims pushed && [ "$remote_known" = "1" ] && [ "${unpushed:-0}" -gt 0 ]; then
  violations+="  CLAIMED \"$(phrase_for pushed)\" — but $unpushed commit(s) exist on no remote."$'\n'
  # 🔴 These per-branch numbers OVERLAP — do not add them up. After a merge the
  # feature branch and main contain the same commits, so a branch sitting at main's
  # tip reports main's whole count as its own. The total above is the union.
  violations+="  Where they are reachable from (these sets overlap; the total is the union):"$'\n'
  violations+="$unpushed_where"
  violations+="      git -C \"$REPO\" push $REMOTE $MAIN"$'\n'
fi

# "verified" is judged only when there is work whose verification is being claimed.
# On a clean, pushed repo the same words are almost always about something else, and
# blocking there would train the reader to route around the gate.
if claims verified && { [ -n "$dirty_lines" ] || [ "${unpushed:-0}" -gt 0 ]; }; then
  gitdir=$(git -C "$tgt" rev-parse --absolute-git-dir 2>/dev/null || echo "")
  receipt="$gitdir/dotclaude-gates-receipt.json"
  # The tree AS IT WOULD BE COMMITTED, built in a throwaway index so the real one is
  # untouched. Costs a few hundred ms on a large repo — paid ONLY here, on a claim
  # of verification, never on an ordinary turn. See the note in local_gates.py for
  # why this and not HEAD + dirty list.
  tmpidx=$(mktemp "${TMPDIR:-/tmp}/delivery-idx.XXXXXX")
  rm -f "$tmpidx"
  tree_fp=$(GIT_INDEX_FILE="$tmpidx" git -C "$tgt" read-tree HEAD 2>/dev/null \
            && GIT_INDEX_FILE="$tmpidx" git -C "$tgt" add -A 2>/dev/null \
            && GIT_INDEX_FILE="$tmpidx" git -C "$tgt" write-tree 2>/dev/null)
  rm -f "$tmpidx"
  verdict=$(python3 "$claimer" receipt "$receipt" "$tree_fp" 2>/dev/null)
  vkind=$(printf '%s' "$verdict" | cut -f1)
  vdet=$(printf '%s' "$verdict" | cut -f2-)
  case "$vkind" in
    OK) : ;;
    MISSING)
      violations+="  CLAIMED \"$(phrase_for verified)\" — but no gates receipt exists for this worktree."$'\n'
      violations+="      expected: $receipt"$'\n'
      [ -n "$GATES_CMD" ] && violations+="      run: $GATES_CMD"$'\n' ;;
    STALE)
      violations+="  CLAIMED \"$(phrase_for verified)\" — the receipt is stale: $vdet"$'\n'
      [ -n "$GATES_CMD" ] && violations+="      re-run: $GATES_CMD"$'\n' ;;
    RED)
      violations+="  CLAIMED \"$(phrase_for verified)\" — the last gate run was RED ($vdet failed)."$'\n' ;;
    SKIPPED)
      # A message that says some gates were skipped is no longer claiming everything
      # passed — that is the wording being corrected, not the check being silenced.
      if ! claims _skipack; then
        violations+="  CLAIMED \"$(phrase_for verified)\" — the run was green but SKIPPED $vdet gate(s)"$'\n'
        violations+="      and the message does not say so. Either name the skipped gate(s) in"$'\n'
        violations+="      the sentence, or run the full set."$'\n'
      fi ;;
    *)
      violations+="  CLAIMED \"$(phrase_for verified)\" — the receipt could not be read ($receipt)."$'\n' ;;
  esac
fi

rt="$proj/.claude/.runtime"
state="$rt/delivery-stop.${sid:-nosession}"

if [ -z "$violations" ]; then
  rm -f "$state" 2>/dev/null
  exit 0
fi

# ---- loop guard -------------------------------------------------------------
# Claude Code has no built-in Stop-loop prevention: a hook that keeps returning 2
# locks the session with no way out. Two blocks on an UNCHANGED state mean the
# problem is not forgetfulness (no network for the push, a branch that cannot merge)
# and trapping the session is now the greater harm. Stand down loudly — the
# discrepancy is still stated, it just stops being a wall.
mkdir -p "$rt" 2>/dev/null
find "$rt" -name 'delivery-stop.*' -mtime +1 -delete 2>/dev/null
fp=$(printf '%s|%s|%s' "$rungs" "$head_sha" "$dirty_sha" | _sha)
prev_fp=""; prev_n=0
[ -f "$state" ] && read -r prev_fp prev_n < "$state" 2>/dev/null
if [ "$fp" = "$prev_fp" ]; then n=$((prev_n + 1)); else n=1; fi
printf '%s %s\n' "$fp" "$n" > "$state"

if [ "$n" -ge 3 ]; then
  cat >&2 <<EOF
DELIVERY GATE STANDING DOWN — blocked twice already on this exact state, so it
stops blocking rather than trapping the session. The discrepancy still stands:

$violations
Either finish the delivery or say plainly what is undelivered and why.
EOF
  exit 0
fi

cat >&2 <<EOF
BLOCKED: the message claims delivery the repository denies.

$violations
Do one of two things, not a third: make the state true, or correct the wording so
it stops asserting what has not happened. Saying it again unchanged blocks once
more, then stands down.
EOF
exit 2
