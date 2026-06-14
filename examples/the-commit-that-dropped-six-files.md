# The commit that claimed seven files and landed one

## Symptom

A focused change touched seven files: a new module, its test, three call sites, a type, and a barrel export. `git add -A`, commit with a message that listed all seven, push, move on. The commit message read like the change was complete.

A teammate pulled the branch and the build broke: the new module was imported in three places but the module file itself wasn't there. The commit that "added the module" had landed the call sites and the export — but not the module or its test. The message described a change that wasn't in the tree.

## Root cause

A `lint-staged` pre-commit hook ran a formatter and re-staged what it touched. Something in its interaction with the staged set — a glob that didn't match the new file's path, a formatter that errored on one file and left the staging index in a partial state — meant the hook re-staged a *subset* of what was originally `git add`-ed. The commit captured that subset. Git reported success. The pre-commit output scrolled past in the terminal. Nothing failed loudly; the commit just contained fewer files than intended, and the message — written before the hook ran — still claimed all seven.

The failure is invisible at commit time and surfaces only when someone (often you, later) relies on a file that was never actually committed.

## The diagnostic that finally worked

`git show --stat HEAD`. The stat showed four files. The message listed seven. The gap was immediate and undeniable. Before that, every signal said the commit was fine — lint green, push accepted, message complete.

## Lesson

**A pre-commit hook that re-stages can silently desync the committed set from your intent.** Commit "success" means git wrote *a* commit, not *the* commit you meant. When a formatter or `lint-staged` sits between your `git add` and the actual commit, the only proof the right files landed is to look at what landed.

## The discipline this produced

1. **After every multi-file commit, run `git show --stat HEAD`** and confirm the file list matches the message. One command; converts a days-late "where did my file go" into an at-the-keyboard catch.
2. **Recovery is `git reset --soft HEAD~1`, re-stage explicitly (`git add <each path>`), recommit.** Don't paper over it with a follow-up "also this file" commit — that splits one logical change across two and muddies history.
3. **Let a hook check it for you.** A PostToolUse hook that echoes `git show --stat` after a commit puts the proof in front of you without remembering to look.

## See also

- `principles/code-review.md` — "Commit integrity — verify the staged set landed"; the same trust-the-result-less instinct as parallel-path detection.
- `principles/operating-principles.md` — Goal-driven complete execution: the success criterion is *observably* met, not assumed from a green exit code.
