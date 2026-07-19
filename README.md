<img src="./assets/logo.svg" width="340" alt="dotclaude">

Two Claude Code plugins: engineering workflow discipline, and design/UX audits.
Consumed as-is; each adapts to your project at runtime.

    claude plugin marketplace add vindm/dotclaude

## dotclaude

worktree isolation · pre-flight · guard hooks · graded code review · risk-weighted test coverage

    claude plugin install dotclaude@dotclaude

See [plugins/core](./plugins/core/README.md).

## dotclaude-design

elicits your design north-star, then grades every screen against it —
ux · flow · pages · a11y · interaction · design-token audits

    claude plugin install dotclaude-design@dotclaude

See [plugins/design](./plugins/design/README.md).

## How it works

Most of a good setup is the same in every project — that part is consumed,
working the moment you install. What's genuinely yours — your quality bar,
your named benchmarks, your risk priorities — is elicited through one short
interview each plugin runs once, and written to a file the agents read at
runtime. Nothing is generated that can rot.

MIT · [Changelog](./CHANGELOG.md) · [Contributing](./CONTRIBUTING.md)
