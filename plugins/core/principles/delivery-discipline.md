# Delivery discipline — gate the claim, not the work

## The problem this solves

"Merged into main." "Pushed." "All gates green." Each describes the author's desk.
Between that desk and the recipient's machine there is always a delivery mechanism,
and until it has run the change is not delivered — which means it is not done.

The failure is not laziness. It is that a sentence like *"merged into main"*, said
in a final message, **reads as a fact and nothing ever revises it**. The next
session inherits the summary, not the repository. Work sits unpushed for days while
every account of it says it shipped. In the codebase this discipline came from, the
same sentence was true-on-the-desk and false-on-the-remote twice in one month; both
times the commits reached the remote later, carried by somebody else's push.

A rule with no trigger is not a rule. Everyone involved already knew the principle.
What was missing was a moment at which reality got consulted.

## Where the trigger belongs

At the moment the work is called done — not during design, not at commit time. In
Claude Code that moment has a name: the **Stop** event, which fires when the model
is about to end its turn, and whose payload carries `last_assistant_message` — the
very sentence making the claim.

## The core move: compare the claim against the state

The naive design blocks the turn whenever the repository has uncommitted or
unpushed work. Do not build that. Stop fires after **every** turn, including the
dozens that happen mid-task, and a guard that objects to a dirty tree on every
reply is switched off within a day. Worse, it is not even measuring the right
thing: unfinished work is normal, and saying so is not a defect.

What is a defect is a **claim the state denies**. So:

1. Read the final message.
2. Detect which rung of delivery it asserts, if any.
3. Assert exactly that rung — not a stricter one, not a looser one.
4. No claim, no sound.

The rungs, weakest to strongest:

| The message claims | The evidence that settles it |
|---|---|
| committed | no uncommitted changes in any worktree of the repo |
| merged | the branch tip is an ancestor of the main branch |
| pushed | no commit on any live branch is absent from every remote |
| verified | a gates receipt exists, matches this tree, 0 failed, 0 skipped |

🔴 **Measure "pushed" as `<tip> --not --remotes`, never as `<remote>/<main>..<main>`.**
The narrow form asks whether the main branch is ahead of its remote, and answers
"no" in the commonest real situation — main level with origin because the work never
reached main, sitting instead on an unpushed feature branch. The honest question is
"is this work anywhere but this machine?", and it has a one-line answer.

## Verification needs a receipt, not a re-run

The "verified" rung cannot be settled by running the gates: a real suite takes
minutes, and no guard that costs minutes per turn survives. Nor can it be settled by
asking the model whether it ran them — that is the declaration the gate exists to
doubt.

Settle it with the record the act itself makes. The gate runner writes a small
receipt when it finishes; the hook compares that receipt against the current tree.
Three properties make it work:

- **Write it on RED as well as green.** A red receipt is evidence. It lets the
  reader be told *"the last run failed"* instead of *"no run found"*, which are
  different facts with different fixes.
- **Keep `skipped` distinct from `passed`.** A suite that skipped two gates was not
  "everything passing", and collapsing the two is how a green-looking result stops
  meaning anything.
- **Fingerprint the tree as it WOULD BE COMMITTED**, not `HEAD` plus a dirty list.
  Committing changes neither a byte of the verified code nor its correctness, but it
  does move `HEAD` and empty the dirty list — so a HEAD-based receipt goes stale on
  the most ordinary step in the workflow (run gates → commit → say it is green) and
  the gate cries wolf. Build the tree in a throwaway index: stable across `git add`
  and `git commit`, moved by any real edit.

Put the receipt in the worktree's own git directory. That buys per-worktree
isolation for free and makes the file impossible to commit by accident.

## No escape phrase

Do not add a magic word that suppresses the gate. **A declaration must not be able
to silence the check that asked for it** — the moment it can, the check measures
the author's willingness to type the word.

There are exactly three ways past:

1. Make the state true.
2. Correct the wording so it stops asserting what has not happened.
3. The loop guard (below).

The second is not a loophole, it is the correct semantics. The gate polices
**claims**, not work. An honest "I have not pushed this yet" is a passing state.

## The loop guard is not optional

Claude Code has no built-in Stop-loop prevention. A hook that keeps returning exit 2
locks the session with no way out — and a guard that can brick the tool it guards
will be removed, taking the discipline with it.

Count consecutive blocks on an **unchanged** fingerprint. Two blocks on identical
state mean the obstacle is not forgetfulness (no network, a branch that will not
merge, a genuinely undeliverable change); trapping the session is now the greater
harm. Stand down loudly: keep stating the discrepancy, stop being a wall.

## The companion problem: guards anchored on the wrong thing

A sibling guard in this plugin blocks main-checkout edits by matching
`Write|Edit|NotebookEdit` and reading `tool_input.file_path`. Shell writes — `sed
-i`, a heredoc redirect, `tee`, a python one-liner — carry no file path and walk
straight past it. In one consuming project the encoding rules actively *required*
the shell route for the riskiest files, aiming them at the unguarded door.

The instinct is to grep the command string for write verbs. Resist it: that check is
dodged by a quoted path, a `cd` first, a variable, a shell function, or any write
mechanism nobody has invented yet. **An invariant a rename can dodge is anchored on
the wrong thing.**

Anchor on the outcome instead — ask the repository what actually changed, diffed
against the same session's previous answer. Nothing dodges `git status`, including
future mechanisms, because it never looks at the verb.

The honest cost, which belongs in the open and not in a "known gap" comment: a
`PostToolUse` hook cannot block, so this is a **detector with a recovery
instruction**. That is adequate precisely here — a stray write into a shared
checkout is fully reversible — and it beats a preventer that a rename defeats.

## Boundaries of the discipline

- **Opt-in per project.** Ship the hook always-on but config-gated: no `delivery:`
  block, silent no-op. What counts as delivery is a project's own fact.
- **The vocabulary is the project's.** Ship sensitive English defaults; let each
  project add its own language and idiom. A phrase list may be sensitive rather than
  precise, because the state check — not the phrase — is the actual gate: a stray
  match against a clean, pushed repo blocks nothing.
- **Never fetch.** A network call per turn is unacceptable, so measure against the
  last known remote refs. The error direction is over-reporting work as unpushed,
  which is the safe one.
- **Check that the documented lifecycle contains the rung you enforce.** In the
  project this came from, the worktree lifecycle skill ran gates → commit → merge →
  tear down, and never mentioned pushing. The gate would have policed a step the
  written procedure did not have. Fix the procedure in the same change, or the guard
  is enforcing folklore.

## Cross-references

- `worktree-discipline.md` — the isolation this gate's sibling hook protects.
- `hooks/scripts/check-delivery-claim.sh` — the Stop hook.
- `hooks/scripts/check-main-checkout-bash-write.sh` — the outcome-anchored detector.
- `hooks/scripts/test-check-delivery-claim.sh` — the fixture-driven harness; every
  case moves real repository state, so deleting the hook's logic fails the tests.
