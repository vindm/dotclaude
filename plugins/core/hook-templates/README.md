# `hook-templates/` — generator templates (NOT consumable as-is)

These are `{{placeholder}}` templates the **thin generator** (`/dotclaude:bootstrap`) copies into a consuming project's **local** `.claude/hooks/` and substitutes with that project's config (from `dotclaude.yml`). They are **project-specific by nature** — they need a value a shared file can't carry, so they cannot ship as consumable base hooks. Running one as-is would error or no-op on the unsubstituted `{{}}`.

| Template | Needs (project-specific) |
|---|---|
| `check-design-tokens.sh` | the theme/token source path (where raw color is allowed) |
| `check-import-boundary.sh` | the project's one-way import boundary rules |
| `check-no-console-log.sh` | allow-paths (and a block-vs-warn taste call) |
| `check-no-todo-comments.sh` | ticket-reference convention (opinionated) |
| `check-prebuild-required.sh` | which paths require a prebuild step |
| `regen-generated-artifacts.sh` | the regen command (e.g. `yarn db:types`) |
| `auto-lint-posttool.sh` | the lint command (also: per-edit lint is usually an anti-pattern — prefer pre-commit + DoD) |

**The ready-to-run universal guards moved to `../hooks/scripts/`** (consumed as-is via `../hooks/hooks.json`). Keep this directory for genuine templates only; if a script here loses its `{{placeholders}}`, it belongs in `../hooks/scripts/`, not here.

**The worktree main-checkout guard was promoted out of this directory** — it now ships as a consumed, config-driven hook (`../hooks/scripts/check-main-checkout-edit.sh`) that reads a `worktree:` block from the project's `dotclaude.yml` and NO-OPs without one, so it needs no rendered per-project copy. That is the model for the remaining templates: a consumed script reading its project-specifics from `dotclaude.yml` beats a copied-and-substituted file that drifts.

*Some of the rest (e.g. `check-no-console-log` with default allow-paths) could follow the same path — a consumed base hook reading optional project config — a deliberate per-hook taste call, deferred.*
