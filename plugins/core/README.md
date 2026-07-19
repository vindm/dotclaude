# dotclaude

Code review, pre-flight, worktree isolation, guard hooks, and risk-weighted
testing for Claude Code. Consumed as-is — it works the moment you install.

    claude plugin marketplace add vindm/dotclaude
    claude plugin install dotclaude@dotclaude

## What's inside

The bold names are what you invoke; none of it needs configuration.

- **`operating-discipline`** — the always-on layer under every task: understand before building, weigh real alternatives, never call a job done that isn't verified.
- **Guard hooks** — block a force-push or history rewrite, a secret sliding into a commit, a file past the size ceiling — before you ask, no setup.
- **`pre-flight`** — maps integration points, parallel paths, and cross-boundary risk before a line of code is written; returns a Clear / Caution / Abort verdict with a risk matrix.
- **`code-review`** — post-implementation review for blast-radius, parallel-path drift, and trust-boundary no-ops that per-file linters miss. Graded S through F.
- **`decomposition`** — splits a file that has outgrown itself at the right seams, behind a plan you approve first.
- **`test-architect`** — audits coverage gaps weighted by risk, designs the suite, and writes the tests in your runner.

One tool takes a one-time setup:

- **`/dotclaude:worktree`** — for repos where several sessions (or humans + agents) work concurrently and collide in one checkout. Interviews the concurrency shape, authors a blocking main-checkout hook from a tested template, and proves it with a live smoke worktree.

## Calibrating the bar

Two agents read a project-specific file at runtime when it exists, and fall back to generic methodology when it doesn't:

- **`/dotclaude:coding`** — a short interview on your file-size ceiling and the bug classes your git history repeats; writes `.claude/dotclaude/code-anti-patterns.md`, which `code-review` reads on every run.
- **`/dotclaude:testing`** — a short interview on which module scares you most and how deep testing should go; writes `.claude/dotclaude/test-risk-model.md`, which `test-architect` seeds its priorities from.

Run either once per project. Skip them and the agents still work — against generic priors instead of yours.

---

Part of the [dotclaude](../../README.md) marketplace. Companion: [dotclaude-design](../design/README.md), the design/UX audit layer.
