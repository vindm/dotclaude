# The stash that ate an afternoon of work

## Symptom

Mid-refactor, an hour of uncommitted changes across a dozen files. A different urgent fix came in on another branch. The instinct: `git stash`, switch branches, fix the urgent thing, come back, `git stash pop`. Routine.

Except the stash command ran inside a longer compound command that also pulled, switched branches, and reinstalled dependencies — and the dependency install hung, so the whole thing got killed with Ctrl-C partway through. After sorting out the urgent fix and coming back: `git stash list` was empty. The afternoon's work was not on any branch, not in the working tree, not in the stash. Gone.

## Root cause

`git stash` moves your changes into a dangling commit referenced only by the stash ref. It is not on a branch. When a compound command that includes `git stash` is interrupted, you can land in a state where the stash ref was created and then clobbered, or never fully written, or the subsequent steps moved `HEAD` out from under it. The work technically still exists as an unreferenced object in the object database for a while — but recovering it means spelunking `git fsck --unreachable` and guessing which dangling blob is yours, under time pressure, which is exactly when you make it worse.

The deeper cause: stash is a *fragile, unnamed, off-branch* place to put work you care about, and it was buried inside a pipeline that could die halfway.

## The diagnostic that finally worked

`git fsck --unreachable | grep commit`, then `git show` on each candidate until one looked like the refactor. It was recoverable — barely, and only because the objects hadn't been garbage-collected yet. An hour of work to recover an afternoon of work, with no guarantee.

## Lesson

**Never put work you care about in a stash — especially not inside a compound or backgrounded command.** A WIP commit on a branch is durable, named, and survives an interrupted pipeline; a stash is none of those things. The convenience of `stash` is not worth the tail risk of losing the work outright.

## The discipline this produced

1. **WIP-commit, never stash.** When you need to set work aside: `git checkout -b wip/<slug> && git add -A && git commit -m "wip"`. It's on a branch, it has a name, and `Ctrl-C` can't erase it.
2. **Never run `git stash` inside a compound or backgrounded command.** A killed pipeline is precisely when the stash gets stranded. If a script must set work aside, it WIP-commits.
3. **Warn before context loss.** A SessionEnd hook that notices uncommitted WIP before `/clear` nudges the WIP commit while the work is still safe to capture.

## See also

- `principles/handoff.md` — WIP-commit-not-stash is part of the conscious-handoff discipline; orphan WIP gets a durable home before context is lost.
- `hook-templates/warn-uncommitted-on-clear.sh` — the SessionEnd nudge that fires when a session ends with uncommitted changes.
- `hook-templates/check-git-safety.sh` — blocks `git stash drop` / `clear` (among other destructive git ops) so a stash can't be discarded by accident.
