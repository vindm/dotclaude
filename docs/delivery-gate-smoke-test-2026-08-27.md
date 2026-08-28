# Delivery gate — smoke test, 2026-08-27

What was tested: the two hooks added in 3.1.0 — `check-delivery-claim.sh` (Stop) and
`check-main-checkout-bash-write.sh` (PostToolUse · Bash) — against a real consuming
project (a bookkeeping-engine audit zone: ~2 300 tracked files, a policed repo below
the project root, live worktrees, a real remote) and against purpose-built fixtures.

**Verdict: ready.** Five defects were found and fixed during the run. Four of the
five were surfaced by the live project rather than by the fixtures — the synthetic
repo simply did not have the shapes that produced them. All five carry regression
tests now.

## Harnesses

| Harness | Cases | Result |
|---|---|---|
| `test-check-delivery-claim.sh` | 30 | pass=30 fail=0 |
| `test-check-main-checkout-bash-write.sh` | 9 | pass=9 fail=0 |

Every case moves real repository state — `git init --bare` as origin, a clone, real
commits, a real `push`, a real worktree, a real receipt file — rather than restating
the hook's own condition.

### Proof the harness bites (mutation)

A green harness proves nothing until a broken hook turns it red.

| Mutation | Expected | Observed |
|---|---|---|
| `exit 0` before the rung comparison (hook never blocks) | most cases red | pass=11 **fail=11** |
| receipt staleness comparison forced false | exactly the stale case red | pass=21 **fail=1** |
| none (restored) | all green | pass=22 fail=0 (before the 2 regression cases were added) |

The second mutation is the more informative one: a single, narrowly-targeted break
turns exactly one case red, which means the cases discriminate rather than all
riding on one code path.

## Defects found and fixed

### 1. "pushed" measured the wrong distance — found in LIVE use, not by the fixtures

The first implementation asked `<remote>/<main>..<main>`: is the main branch ahead of
its remote? Run against the live project it answered **no** and let the claim pass —
while every commit of the work sat on an unpushed feature branch. `main` was level
with `origin` precisely *because* the work had never reached it.

Fixed to `<tip> --not --remotes` over the main branch plus every worktree branch:
"is this work anywhere but this machine?". Regression case
`main-clean-but-branch-unpushed` keeps `main` deliberately clean.

This is the one the fixture set could not have caught as written, because the fixture
committed on `main`. The live population had a shape the synthetic one did not.

### 2. Receipt staleness was anchored on HEAD, which moves on an innocent step

The receipt originally recorded `HEAD` + a hash of `git status`. Committing changes
neither a byte of the verified code nor its correctness, but it moves `HEAD` and
empties the dirty list — so the most ordinary sequence in the workflow (run gates →
commit → say it is green) would have gone stale and the gate would have cried wolf on
a true claim.

Re-anchored on the tree **as it would be committed**, built in a throwaway index.
Measured on a 200-file fixture:

| Action | Fingerprint moves? | Wanted |
|---|---|---|
| edit a tracked file | yes | yes |
| `git add` | no | no |
| `git commit` | no | no |
| add an untracked file | yes | yes |

### 3. The `verified` rung was unsatisfiable in the live project — found in LIVE use

The project's JS lint gate skips on every run because `node_modules` is absent. Any
claim of "gates are green" would therefore have been blocked forever, and the block
message's own advice — *"say which, or run the full set"* — did not work, because a
substring match fires on the narrowed wording too. **A gate nobody can satisfy gets
switched off**, taking the discipline with it.

Fixed by recognising a *skip acknowledgement* in the message: naming the skipped gate
means the sentence has stopped asserting that everything passed, which is the
legitimate "correct the wording" path, not a silencing of the check. English defaults
ship with the hook; a project adds its own via `claimsSkipAck`.

### 4. The per-branch breakdown invited a wrong sum

The union total was correct, but the breakdown printed one count per branch and read
as additive. On the live repo it showed `2`, `1`, `2` under a total of `2` — the
feature branch and a neighbouring session's worktree branch both sat at main's tip,
so each reported main's whole count as its own. A reader (this one) took the mismatch
for a counting bug and went looking for it.

The numbers were right; the sentence was not. Reworded to "reachable from … (these
sets overlap; the total is the union)".

### 5. The `committed` rung fired on a NEIGHBOURING session's work

Caught while handing the work over, before the hook had run live for a single turn.
The rung scanned every worktree of the policed repo — but the setup this guard ships
into exists *because* several agent sessions share one repo through worktrees. A
sibling session with work in progress would have blocked "I committed" for an author
whose own tree was spotless.

A false positive on day one is how a guard gets switched off, taking the rungs that
worked with it. Scoped to the session's own worktree, falling back to all of them only
when the turn ran outside the repo — and the message now says which case it is.

Note on evidence: the live repo could not demonstrate this, because the neighbouring
worktree happened to be clean at the time. The fixture case
`neighbour-dirt-not-mine` makes a sibling worktree dirty on purpose, paired with
`my-own-dirt-still-blocks` so the fix cannot pass by simply never firing.

## Cost, measured

| Path | Cost |
|---|---|
| PostToolUse · Bash, project **without** a `dotclaude.yml` | **0.01 s** |
| PostToolUse · Bash, project with a `worktree:` block (2 300 files) | 0.17 s |
| Stop, turn with no delivery claim | 0.30 s → **0.01 s** without config |
| Stop, turn with a claim (full state gathering) | 0.6–0.8 s |
| Tree fingerprint (only on a `verified` claim) | 0.33 s |

The unconfigured case is what most consumers of the plugin pay, so it was made free
with a `test -f` bail-out before any process is spawned. Three temp files became one
and the stale-cache sweep moved off the per-call path during the same pass.

## Config parsing — the flat-key claim, measured rather than asserted

The hooks' header comments insist the claim-phrase keys must stay flat
(`delivery.claimsPushed`, not `delivery.claims.pushed`). Verified on the real
project's config:

| Parser | `delivery.claimsPushed` | `delivery.claims.pushed` (control) |
|---|---|---|
| PyYAML | 4 phrases | 1 phrase |
| bundled minimal parser (PyYAML absent) | 4 phrases | **`None`** |

So the nested form would have made the gate silently dead on any machine without
PyYAML — the failure the flat keys exist to prevent, now demonstrated rather than
claimed.

## End-to-end against the real project

`python3 tools/local_gates.py --quick` in a live worktree: 5 passed, 0 failed, 2
skipped; receipt written to that worktree's own git dir (per-worktree isolation
confirmed — the path was `.git/worktrees/<name>/dotclaude-gates-receipt.json`).

Feeding the Stop hook a claim of "gates are green" against that receipt produced:

```
BLOCKED: the message claims delivery the repository denies.
  CLAIMED "гейты зелёные" — the run was green but SKIPPED 2 gate(s);
      that is not "everything passed". Say which, or run the full set.
```

Writer and reader agree: the receipt format has two homes (`local_gates.py` writes,
`_delivery_claim.py` reads) and they were measured together, not separately.

## Consuming-project finding worth recording

The project's own worktree lifecycle skill ran gates → commit → merge → tear down →
re-render, and contained **no push step**. The word "pushing" appeared once, inside a
different step, as a subordinate clause. A reference that is never a step is how the
step goes missing — and it had, twice.

The gate would therefore have been enforcing a rung the written procedure did not
have. The procedure was fixed in the same change. This is now a stated boundary in
`principles/delivery-discipline.md`: check that the documented lifecycle contains the
rung you enforce, or the guard is enforcing folklore.

## Follow-ups

- **P2** — the `committed` rung reports derived-artifact noise (a render that rewrites
  a tracked index file) as uncommitted work. True, but it will read as a false alarm.
  Worth a `committedIgnore` glob list if it proves annoying in daily use.
- **P2** — the plugin now registers three PostToolUse hooks; the consolidated
  dispatcher already noted in `hooks/README.md` would pay for itself.
