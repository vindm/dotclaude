---
name: migration-create
description: Author a database schema migration safely — one atomic change per migration, classified by risk with an explicit confirmation gate on destructive changes, access policies composed in the same migration as any new table, generated artifacts regenerated after, and a smoke test before declaring done. Discovers the project's own migration tool, conventions, and regen command at runtime. Use whenever you need to change the schema.
---

# Migration create

Schema migrations fail in ways code review and tests don't catch: a new table ships wide open because its access policy was forgotten, generated types drift because nobody regenerated them, a destructive drop or rename goes in without anyone opting into the loss, or a blocking DDL statement takes a large table offline. Catch these *before* the migration applies, when the cost is one conversation rather than a rollback.

**One migration is one atomic change.** Don't bundle an additive column, a backfill, and a policy change into a single file; each is its own migration so each can be reasoned about and rolled back independently. Never edit a historical migration file — old migrations are frozen artifacts; corrections go through a new migration, never by retroactively rewriting an applied one.

## Step 0 — Discover the project's migration mechanism

Do not assume the tool, the command, or the database. Find them at runtime before composing anything:

- **The migration mechanism.** Look for a migrations directory, an ORM or migration CLI in the dependency manifest, or a database-tooling config. That tells you how migrations are authored and applied here.
- **The conventions.** Read two or three existing migrations. Mirror exactly what's there: identifier casing, table singular-vs-plural, foreign-key and timestamp naming, the timestamp type, numeric-type choices, and whether constraints are inline or named separately. Convention drift compounds — one off-style migration nudges the next one further off.
- **The access-control mechanism.** Row-level security policies, a permissions layer, application-level access control — each shapes the policy step differently.
- **The regeneration command.** Whatever turns the live schema back into typed artifacts (generated types, query bindings, an ORM client). Find the actual command this project uses.
- **The cross-cutting concerns this project tracks.** Telemetry on new write paths, audit logging, backup wiring, cache invalidation — read the project's own conventions so the closing reminders match reality.

## Step 1 — Classify the change

Migrations are not equally risky. Classify before composing, and let the class set the gate:

- **Low — ship without ceremony:** additive nullable column; additive index (verify the non-blocking / concurrent variant on a large table); new function or RPC (verify its security context and search path).
- **Low forward but hard to roll back:** a new enum or enum value. Note the irreversibility.
- **New table:** low to add, but it is not done until it has an access policy (see Step 3).
- **Medium — flag the risk, proceed once acknowledged:** a backfill of existing rows (chunk it if the table is large); setting `NOT NULL` on an existing column (backfill first).
- **High — always confirm before applying:** dropping a column, renaming a column, or changing an existing column's type. These are destructive. Never apply one without the user explicitly opting in, even if their prompt said "drop column X" — the confirmation is a structural safety gate, not a formality.

Also watch for whole-table-rewrite footguns the database version may impose (for example, adding a non-null column with a default can rewrite the table on some engines) and reach for the safe variant.

## Step 2 — Compose with the project's conventions

Write the SQL (or the migration in whatever form the tool takes) using the casing, types, constraint style, and grant pattern you read in Step 0. A new table gets its grants in the same migration.

## Step 3 — Access policy, required for every new table

For any new table — and any access-relevant column change — answer four questions before composing the policy: who reads, who writes, what the predicate is (an ownership column, a join through a membership table, etc.), and whether some rows are owner-mutable but user-read-only. Compose the policy and enable it **in the same migration as the table**. Production enforces access; a table without a policy is leaked data.

If the user can't articulate the predicate, **stop and ask** — guessing at a policy is worse than blocking the migration. If the database uses application-level access control instead of database policies, substitute the equivalent: enumerate which queries gain new constraints.

## Step 4 — Apply, regenerate, smoke test

After the user confirms the change:

1. Apply it through the project's migration tool.
2. Run the regeneration command you found in Step 0. The migration is not done until the generated artifacts match the new schema — skip this and downstream code drifts silently (a new field comes through as an untyped value, or compilation breaks later).
3. Smoke test: run one query against the new shape and confirm it produced the expected effect. "Applied, looks good" without a verifying query is faith-based; a ten-second read is the cheapest possible verification.
4. Surface the downstream wiring the change implies — telemetry for a new write path, UI plumbing for a new field, backup or job wiring for a new table — using the project's actual list of cross-cutting concerns. The schema change is rarely the whole story; without these reminders the work is half-done.
