# migration-create — designing a schema-migration discipline skill

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a migration-create skill — the workflow that turns "I need to change the schema" into a safe, reversibility-checked, RLS-respecting, type-regenerated change.

## When to ship one (applicability gate)

Ship a migration-create skill when:

- The project has a **database with a migration framework** — Postgres + Supabase / Knex / Alembic / Active Record / Drizzle / Prisma migrate / sqlx-migrate / Mongoose, etc.
- The user authors migrations as part of dev flow (not just runtime DDL via ORM auto-sync).
- The project has had at least one bad migration ship (missed RLS, broke type generation, irreversible without realizing, blocked production writes).

Skip when:

- The project has no DB or no migrations (NoSQL with no schema validation, embedded DB only).
- Schema changes are wholly auto-derived from code (e.g., schema is regenerated from ORM models on each deploy and migrations aren't authored).
- The user is the sole DBA with strong opinions and prefers no workflow scaffold.

## Why it matters — what this catches that nothing else does

Schema migrations fail in particular ways that don't show up in code review or test coverage:

- **Forgotten access policies.** New table ships without row-level-security or access policies; the table is wide open to all authenticated users. See `../examples/the-write-that-returned-success.md` for the related class of trust-boundary failure.
- **Forgotten type regeneration.** Migration applied; TypeScript types not regenerated; downstream code drifts from runtime. Either fails at compile, or worse, fails silently because the new field is `any`.
- **Irreversible changes shipped.** Dropping a column is destructive; renaming is destructive; type-narrowing on an existing column is destructive. The skill surfaces these explicitly so the user OPTS IN to irreversibility instead of stumbling into it.
- **Blocking DDL on large tables.** `CREATE INDEX` without `CONCURRENTLY` on a 50M-row table can take the table offline for minutes. The skill prompts for the safe variant.
- **Wrong default-value handling.** `ALTER TABLE ADD COLUMN x INT DEFAULT 0 NOT NULL` rewrites the entire table on some DBs / versions.
- **Forgotten downstream wiring.** New write path needs telemetry, new field needs UI plumbing, new table needs a backup job. The skill prompts for the cross-cutting concerns the project has established.

The skill catches these BEFORE the migration applies, when the cost of catching them is one conversation, not a rollback.

## Core methodology — four-step workflow

The skill walks four steps every invocation:

### Step 1 — Classify the change

Migrations are not equally risky. Classify before composing:

| Class | Examples | Risk |
|---|---|---|
| **Additive nullable column** | `ADD COLUMN x t` (no NOT NULL) | Low. Ship without confirmation. |
| **Additive index** | `CREATE INDEX CONCURRENTLY ...` | Low. Verify CONCURRENTLY for large tables. |
| **New table** | `CREATE TABLE t (...)` | Low. Requires access policies + grants. |
| **New enum / value** | `CREATE TYPE` / `ALTER TYPE ADD VALUE` | Low forward; **hard to roll back**. |
| **New function / RPC** | `CREATE FUNCTION ...` | Low. Verify security context + search path. |
| **Backfill of existing rows** | `UPDATE t SET x = ...` | Medium. Chunk if large; monitor. |
| **NOT NULL on existing column** | `ALTER COLUMN x SET NOT NULL` | Medium. Requires backfill first. |
| **Drop / rename / type-change** | `DROP COLUMN`, `RENAME COLUMN`, `ALTER COLUMN x TYPE u` | **High. Always ask before applying.** |

The skill should confirm the user's intent before applying any High-risk change. For Medium-risk changes, the skill flags the risk and proceeds if the user has acknowledged.

### Step 2 — Compose the SQL with project conventions

The skill applies the project's actual conventions:

- **Naming.** Snake_case columns? CamelCase? PascalCase? Tables singular or plural? `*_id` for FKs? `*_at` for timestamps? Each project has a convention; the skill should know and follow it.
- **Timestamp shape.** `timestamptz`? `bigint` epoch ms? Custom serialization? Use whichever the project uses.
- **Type choices.** `numeric` vs `decimal` vs `float8` vs `bigint` — the right choice depends on what the column represents and how downstream code reads it. The skill should know the project's preferences.
- **Constraint patterns.** Inline vs separate `CONSTRAINT` statements; named vs auto-named; deferred vs immediate.
- **Grants.** New tables typically need `GRANT SELECT, INSERT, UPDATE, DELETE` to specific roles. The skill knows the project's grant pattern.

### Step 3 — Access-policy plan (REQUIRED for new tables)

For every new table and any RLS-relevant column change, the skill prompts:

1. **Who reads?** (anon / authenticated / role X / role Y)
2. **Who writes?** (same)
3. **What's the predicate?** (e.g., `owner_id = auth.uid()`, or a join through a membership table)
4. **Are there owner-only rows?** (e.g., admin-mutable but user-read-only)

Then the skill composes the access policy + enables it in the same migration. **Don't apply a table without policies** — production enforces them; missing policies = leaked data.

If the user can't articulate the predicate, the skill STOPS and asks. Guessing at policies is worse than blocking the migration.

This step is project-conditional: if the DB doesn't have row-level security (e.g., pure MongoDB, application-layer access control), the skill substitutes the project's equivalent (a list of which queries gain new constraints, etc.).

### Step 4 — Apply, regenerate types, smoke test

After the user confirms the SQL:

1. Apply via the project's migration tool (CLI command or LLM-callable tool — see `database-query-discipline.md`).
2. Regenerate types: `yarn db:types`, `prisma generate`, `sqlx migrate run`, `sqlc generate`, whatever the project uses.
3. Smoke test: run a known query against the new shape; verify the migration produced the expected effect.
4. Surface downstream wiring required: new write path → telemetry? New field → UI plumbing? New table → backup job? The skill enumerates the standing cross-cutting concerns and reminds the user.

## How to derive THIS project's specifics

Before authoring the skill, gather:

1. **The migration framework.** Postgres migrations via Supabase MCP? Alembic? Knex? Drizzle? The skill's `apply` step uses the right tool.

2. **The naming + timestamp + type conventions.** Read 2-3 existing migrations from the project's `migrations/` directory. The skill should mirror what's already there.

3. **The access-policy mechanism.** RLS? Hasura permissions? Application-layer? Each shapes Step 3 differently.

4. **The type-regeneration command.** Almost always `yarn db:types` or equivalent. Encode the actual command.

5. **The destructive-change confirmation gate.** Does the user want hard "ASK BEFORE" prompts on drops / renames? Encode the exact gate.

6. **The cross-cutting concerns the project tracks.** Hermes telemetry? Audit logging? Backup wiring? Cache invalidation? The skill's Step 4 reminders should be the project's actual list.

## Authoring the skill

The final skill (typically `.claude/skills/migration-create/SKILL.md`) should specify:

1. **When to use** — additions, changes, or new RLS / RPC / enum / index work.
2. **When NOT to use** — editing existing historical migration files (frozen artifacts), pure access-policy audits with no schema change, local-only experiments.
3. **Inputs** — the user passes a name (snake_case typically); the skill converts loose prose if needed.
4. **The four-step workflow** — classify / compose / RLS-plan / apply.
5. **The classification table** — populated with the project's actual risk classes.
6. **Conventions** — the project's actual naming / type / constraint patterns.
7. **The destructive-change confirmation gate** — explicit.
8. **The type-regeneration command** — the exact thing to run.
9. **Cross-cutting reminders** — telemetry / UI / cache / etc.

## Cross-references

- `database-query-discipline.md` — writes use the LLM-callable tool (migration apply); reads use CLI. The skill follows that pattern.
- `data-integrity.md` — after a migration that introduces new fields / constraints, the integrity agent should pick up corresponding checks.
- `code-review.md` — code that depends on the new schema should be reviewed for type drift (forgotten regeneration).
- `pre-flight.md` — for any migration in a larger feature scope, pre-flight should map the integration points.

## Anti-patterns in the skill you write

- **Applying destructive migrations without explicit confirmation.** The skill should never `DROP COLUMN` without asking, even if the user's prompt said "drop column X." The confirmation is a structural safety gate.

- **Skipping the access-policy plan for new tables.** RLS / equivalent is not optional. The skill should refuse to apply a new-table migration without a policy block in the same migration.

- **Forgetting type regeneration.** The migration ships; types drift; downstream code silently breaks. The skill's Step 4 must include the regen command.

- **Convention drift.** If the project uses snake_case and the skill produces camelCase, the migration sticks out and the next migration drifts further. Read existing migrations and mirror conventions.

- **No smoke test.** "Migration applied, looks good" without a verifying query is faith-based. A 10-second SELECT against the new shape is the cheapest possible verification.

- **No cross-cutting reminders.** The schema change is rarely the whole story — new write paths need telemetry, new fields need UI, new tables need backups. Without the reminders, the work is half-done.

- **Editing historical migration files.** Old migrations are frozen artifacts. Changes go via new migrations, not by retroactively editing. The skill should refuse to edit `migrations/0001-*.sql` (or equivalent).

- **No "ask first" gate for new RLS policies.** The user must articulate the predicate. If they can't, the skill stops and asks — guessing produces silent data leaks.

## Tool surface

The skill needs: `Read`, `Grep`, `Glob`, `Bash` (to run regen / smoke-test commands), the migration-apply LLM tool if one exists. It does NOT need `Write` to source code — it composes SQL and feeds it to the apply tool.

Model: medium-capability. SQL composition + convention adherence; not the deepest reasoning, but precision matters.
Effort: medium. Migration work is per-change; not a sweep operation.
