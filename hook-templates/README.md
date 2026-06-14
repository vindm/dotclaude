# `hook-templates/` — generator templates (NOT consumable as-is)

These are `{{placeholder}}` templates the **thin generator** (`/dotclaude:bootstrap`) copies into a consuming project's **local** `.claude/hooks/` and substitutes with that project's config (from `dotclaude.yml`). They are **project-specific by nature** — they need a value a shared file can't carry, so they cannot ship as consumable base hooks. Running one as-is would error or no-op on the unsubstituted `{{}}`.

| Template | Needs (project-specific) |
|---|---|
| `check-design-tokens.sh` | the theme/token source path (where raw color is allowed) |
| `check-import-boundary.sh` | the project's one-way import boundary rules |
| `check-forbidden-phrases.sh` | the project's brand/voice phrase list + scopes |
| `check-no-console-log.sh` | allow-paths (and a block-vs-warn taste call) |
| `check-no-todo-comments.sh` | ticket-reference convention (opinionated) |
| `check-prebuild-required.sh` | which paths require a prebuild step |
| `regen-generated-artifacts.sh` | the regen command (e.g. `yarn db:types`) |
| `auto-lint-posttool.sh` | the lint command (also: per-edit lint is usually an anti-pattern — prefer pre-commit + DoD) |

**The ready-to-run universal guards moved to `../hooks/scripts/`** (consumed as-is via `../hooks/hooks.json`). Keep this directory for genuine templates only; if a script here loses its `{{placeholders}}`, it belongs in `../hooks/scripts/`, not here.

*Some of these (e.g. `check-forbidden-phrases` with a universal AI-slop base list, `check-no-console-log` with default allow-paths) could be promoted to consumable base hooks with sensible universal defaults + an optional project-extension — a deliberate per-hook taste call, deferred.*
