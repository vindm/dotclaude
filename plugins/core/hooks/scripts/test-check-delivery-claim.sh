#!/usr/bin/env bash
# Drive check-delivery-claim.sh against a REAL fixture repository.
#
# 🔴 Why a real repo and not a mocked git: a test that restates the hook's own
# condition tests nothing. Every case here changes actual repository state — makes
# a commit, pushes it to a real bare remote, dirties a file, writes a receipt — and
# then asks the hook for a verdict. If the hook's logic were deleted, these fail.
#
#   bash test-check-delivery-claim.sh
#
# Leaves nothing behind: the fixture lives in a mktemp dir removed on exit.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/check-delivery-claim.sh"

FIX=$(mktemp -d "${TMPDIR:-/tmp}/delivery-gate-fixture.XXXXXX")
trap 'rm -rf "$FIX"' EXIT

PROJ="$FIX/proj"
REPO="$PROJ/repo"
ORIGIN="$FIX/origin.git"

mkdir -p "$PROJ"
git init --quiet --bare "$ORIGIN"
git clone --quiet "$ORIGIN" "$REPO" 2>/dev/null
git -C "$REPO" config user.email t@example.com
git -C "$REPO" config user.name  Test
git -C "$REPO" symbolic-ref HEAD refs/heads/main
echo one > "$REPO/a.txt"
git -C "$REPO" add a.txt
git -C "$REPO" commit --quiet -m "initial"
git -C "$REPO" push --quiet -u origin main 2>/dev/null

write_yml() {  # write_yml <with-delivery-block: yes|no>
  if [ "$1" = "no" ]; then
    printf 'fileSize:\n  ceiling: 1000\n' > "$PROJ/dotclaude.yml"
    return
  fi
  cat > "$PROJ/dotclaude.yml" <<'YML'
fileSize:
  ceiling: 1000
delivery:
  repo: repo
  mainBranch: main
  remote: origin
  gatesCommand: "python3 tools/local_gates.py"
  claimsPushed:
    - "отправлено в origin"
  claimsVerified:
    - "гейты зелёные"
  claimsSkipAck:
    - "пропущ"
YML
}
write_yml yes

export CLAUDE_PROJECT_DIR="$PROJ"

RECEIPT="$REPO/.git/dotclaude-gates-receipt.json"
tree_now() {
  local i; i=$(mktemp); rm -f "$i"
  GIT_INDEX_FILE="$i" git -C "$REPO" read-tree HEAD 2>/dev/null \
    && GIT_INDEX_FILE="$i" git -C "$REPO" add -A 2>/dev/null \
    && GIT_INDEX_FILE="$i" git -C "$REPO" write-tree 2>/dev/null
  rm -f "$i"
}

write_receipt() {  # write_receipt <failed> <skipped> [tree]
  printf '{"tree":"%s","failed":%s,"skipped":%s,"passed":6,"quick":false}\n' \
    "${3:-$(tree_now)}" "$1" "$2" > "$RECEIPT"
}

pass=0; fail=0
t() {  # t <name> <message> <want-exit> [session-id]
  local sid="${4:-sid-$RANDOM-$RANDOM}"
  local got
  printf '{"last_assistant_message":%s,"cwd":"%s","session_id":"%s"}' \
    "$(printf '%s' "$2" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
    "$REPO" "$sid" | bash "$HOOK" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$3" ]; then pass=$((pass+1)); printf 'ok   %s\n' "$1"
  else fail=$((fail+1)); printf 'FAIL %s (want exit %s, got %s)\n' "$1" "$3" "$got"; fi
}

grep_stderr() {  # grep_stderr <name> <message> <regex-that-must-match>
  local out
  out=$(printf '{"last_assistant_message":%s,"cwd":"%s","session_id":"g-$RANDOM"}' \
    "$(printf '%s' "$2" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
    "$REPO" | bash "$HOOK" 2>&1 >/dev/null)
  if printf '%s' "$out" | grep -qE "$3"; then pass=$((pass+1)); printf 'ok   %s\n' "$1"
  else fail=$((fail+1)); printf 'FAIL %s (no match for /%s/ in:)\n%s\n' "$1" "$3" "$out"; fi
}

echo "--- no claim / not opted in ---"
t no-claim-silent          "Looked at the code, three places need work."   0
t empty-message-silent     ""                                             0
write_yml no
t no-delivery-block-silent "Done, pushed to origin."                      0
write_yml yes

echo "--- pushed rung ---"
t clean-repo-claim-ok      "Done, pushed to origin."                      0
echo two > "$REPO/b.txt"; git -C "$REPO" add b.txt; git -C "$REPO" commit --quiet -m "second"
t unpushed-claim-blocked   "Done, pushed to origin."                      2
t unpushed-no-claim-silent "Still working on the second file."            0
t unpushed-ru-claim-blocked "Готово, отправлено в origin."                2
git -C "$REPO" push --quiet origin main 2>/dev/null
t pushed-claim-ok          "Done, pushed to origin."                      0

echo "--- pushed rung: work parked on an unmerged feature branch ---"
# Regression for a hole found in live use: the first implementation compared only
# origin/main..main, so with main level with origin the claim passed while every
# commit sat on an unpushed feature branch. main is CLEAN here on purpose.
FWT="$FIX/repo-wt-feature"
git -C "$REPO" worktree add --quiet -b feat/parked "$FWT" 2>/dev/null
echo three > "$FWT/c.txt"
git -C "$FWT" add c.txt
git -C "$FWT" commit --quiet -m "parked work"
t main-clean-but-branch-unpushed  "Done, pushed to origin."               2
git -C "$FWT" push --quiet -u origin feat/parked 2>/dev/null
t branch-pushed-claim-ok          "Done, pushed to origin."               0
git -C "$REPO" worktree remove "$FWT" 2>/dev/null

echo "--- unpushed count is the UNION, not the sum ---"
# After a merge the feature branch and main both contain the same commit. Summing
# per-branch counts reports it twice — the normal state at the moment this hook runs.
MWT="$FIX/repo-wt-merged"
git -C "$REPO" worktree add --quiet -b feat/merged "$MWT" 2>/dev/null
echo four > "$MWT/d.txt"
git -C "$MWT" add d.txt
git -C "$MWT" commit --quiet -m "one shared commit"
git -C "$REPO" merge --no-ff --quiet -m "merge feat/merged" feat/merged
grep_stderr union-not-sum "Done, pushed to origin." "but 2 commit\\(s\\) exist on no remote"
git -C "$REPO" push --quiet origin main 2>/dev/null
git -C "$REPO" worktree remove "$MWT" 2>/dev/null

echo "--- committed rung ---"
t clean-committed-ok       "Committed."                                   0
echo dirt >> "$REPO/a.txt"
t dirty-committed-blocked  "Committed."                                   2

echo "--- verified rung (tree is dirty, so the rung applies) ---"
rm -f "$RECEIPT"
t verified-no-receipt-blocked "All gates green."                          2
write_receipt 0 0
t verified-fresh-receipt-ok   "All gates green."                          0
write_receipt 0 2
t verified-skipped-blocked    "All gates green."                          2
write_receipt 1 0
t verified-red-blocked        "All gates green."                          2
write_receipt 0 0 "0000000000000000000000000000000000000000"
t verified-stale-tree-blocked  "All gates green."                         2
write_receipt 0 0
t verified-fresh-again-ok      "All gates green."                         0
write_receipt 0 0
t verified-ru-claim-ok        "Гейты зелёные."                            0
write_receipt 0 2
t verified-ru-skipped-blocked "Гейты зелёные."                            2

echo "--- a message that names the skip is not claiming everything passed ---"
write_receipt 0 2
t verified-skipped-ack-en-ok   "Gates are all green, except the JS lint which was skipped."  0
t verified-skipped-ack-ru-ok   "Гейты зелёные, JS-линт пропущен."                            0
t verified-skipped-noack-block "All gates green."                                           2

echo "--- verified rung does NOT apply on a clean, pushed repo ---"
git -C "$REPO" checkout --quiet -- a.txt
rm -f "$RECEIPT"
t verified-clean-repo-silent  "All gates green."                          0

echo "--- loop guard: same claim, same state, third time stands down ---"
echo dirt2 >> "$REPO/a.txt"
LOOPSID="loop-fixed-session"
rm -f "$PROJ/.claude/.runtime/delivery-stop.$LOOPSID"
t loop-1-blocks            "Committed."                                   2 "$LOOPSID"
t loop-2-blocks            "Committed."                                   2 "$LOOPSID"
t loop-3-stands-down       "Committed."                                   0 "$LOOPSID"

echo "----- pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
