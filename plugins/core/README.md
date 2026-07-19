# dotclaude — a senior who won't let you shoot your own foot

Parallel-session worktree isolation. Blast-radius pre-flight before you touch anything risky. Guard hooks that block the foot-guns automatically. Graded code review that catches what passed every test and shipped anyway. Test coverage designed and implemented by risk, not by vibes.

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
```

## What's inside

Everything below is *consumed* — it works the moment you install, nothing to configure:

- **`operating-discipline`** — the always-on "how to work" layer underneath every task: understand before building, weigh real alternatives instead of grabbing idea #1, never call a job done that isn't verified.
- **Guard hooks** — block a force-push or history rewrite, a secret sliding into a committed file, a file past the size ceiling — before you ever ask, no setup required.
- **`pre-flight`** — maps integration points, parallel paths, and cross-boundary risk before a line of code is written; returns a Clear-for-Takeoff / Caution / Abort verdict with a risk matrix.
- **`code-review`** — post-implementation review for blast-radius, parallel-path drift, and trust-boundary no-ops that per-file linters miss. Graded S through F.
- **`decomposition`** — splits a file that has outgrown itself at the right seams, behind a plan you approve first.
- **`test-architect`** — audits coverage gaps weighted by risk, designs the suite, and writes the tests in your own runner.

One tool needs a one-time setup instead of working out of the box:

- **`/dotclaude:worktree`** — for projects where several AI sessions (or humans + agents) work concurrently and collide in one checkout. Interviews your repo's concurrency shape, authors a blocking main-checkout hook from a tested template, and proves it with a live smoke worktree before handing off.

## Calibrating the bar

Two of the agents above read a project-specific artifact at runtime when one exists, and fall back to generic methodology when it doesn't:

- **`/dotclaude:coding`** — a short interview on your file-size ceiling and the bug classes your git history actually repeats; writes `.claude/dotclaude/code-anti-patterns.md`. `code-review` reads it on every run.
- **`/dotclaude:testing`** — a short interview on which module scares you most and how deep testing should go; writes `.claude/dotclaude/test-risk-model.md`. `test-architect` seeds its risk-weighted priorities from it.

Run either once per project. Skip them and the agents still work — just against generic priors instead of yours.

---

Part of the [dotclaude](../../README.md) marketplace. Companion plugin: [dotclaude-design](../design/README.md), the design/UX audit layer.
