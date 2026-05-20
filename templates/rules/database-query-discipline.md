# Database query discipline (CLI > LLM tool for reads)

LLM-callable database tools (BI integrations, schema introspection MCPs, in-IDE query runners) return UNBOUNDED JSON. A 50-row query on a wide table can dump 10–20k tokens into your context window. Multiply by 3–4 exploratory queries and you've burned the entire budget you needed for the actual problem.

## The default path for reads

```bash
# Bound the output explicitly; never let the database decide how much to return.
psql "$DB_URL" -c "SELECT col FROM table WHERE pred LIMIT n"
```

For provider-specific equivalents (MySQL `mysql`, SQLite `sqlite3`, MongoDB `mongosh`), use the CLI with explicit `LIMIT` / `--limit` / `.find().limit(n)`.

For logs:

```bash
<provider-cli> logs <service> --since 1h | tail -200
```

For type generation after schema change:

```bash
<provider-cli> gen types > src/db/schema.ts
```

## When to use the LLM-callable tool

Only when:

- You need to WRITE (apply a migration, mutate state)
- The CLI genuinely cannot do it (rare — most providers cover the full surface)
- You're inspecting one specific JSON shape and the row count is < 5

## Why this matters

Every token spent on raw query output is a token NOT spent on understanding. After one bad query dump, you have ~3k tokens of half-recall "I think the schema looks like this" and a polluted context window. The CLI path keeps your context for the actual problem.

## A specific trap: RLS-silently-no-op writes

When a write-path policy restricts writes to a privileged role (e.g., `service_role` on Supabase, owner roles in row-level-security setups), a user-JWT call returns `{ data: null, error: null }` — success-shaped, but the write never happened. Symptom: feature appears to work in dev (where you run as service role), silently fails in prod.

Diagnostic: when a write returns nothing-and-no-error, immediately re-query for the row you expected to insert. If absent, your call hit an RLS no-op. Fix is provider-specific — usually adding `WITH CHECK` to policies or routing the write through a privileged client.

## Configuration

`dotclaude.yml` `database: postgres | mysql | sqlite | none` — used by the `regen-generated-artifacts` hook to know which type-generation command to run.

## See also

- `check-secret-leak` hook (blocks committing credentials)
- `regen-generated-artifacts` hook (refreshes types after migrations)
