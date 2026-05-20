---
paths: "src/db/**,**/queries/**,**/operations/**,lib/db/**"
---

# Database & Query Quick Checks

For type conventions and schema patterns, see your `db-types` skill (if present). This rule covers gotchas only:

- Many JS DB clients' `insert()`/`update()`/`delete()` return `{ data, error }` — they do NOT throw. Their error type is often NOT `instanceof Error`. Always destructure and check.
- **`numeric` columns return strings.** PostgREST (and many other ORMs / clients) serializes Postgres `numeric`/`decimal` as JSON strings (`"3"` not `3`). Coerce with `Number(v)` + `Number.isFinite()` at the query boundary. Don't use `typeof x === 'number'`. Affects any numeric-valued precision column.
- **RLS / authorization joins fail silently.** Most DB clients' FK joins return `null` (not error) when RLS blocks the joined table. If you expect a related row but get `null`, suspect a policy mismatch before debugging your query.
- Never filter by a status column without checking what its default is for fresh rows — `status = null` on freshly inserted records is the classic silent-skip bug.
- React Query: ensure cross-tab queries use consistent cache keys. Use `useFocusEffect` (RN) or `revalidateOnFocus` (web SWR) for tab-level invalidation.

## CLI > MCP / LLM-callable tools for reads (default path)

LLM-callable database tools (BI integrations, schema introspection MCPs, in-IDE query runners) dump unbounded JSON into the conversation — a single `list_tables` or `execute_sql` without `LIMIT` can burn 10–20k tokens. Prefer the CLI path for reads; reserve LLM tools for write paths and operations the CLI can't do.

**Read paths — use CLI / `psql`:**
- Schema introspection → `psql "$DB_URL" -c "\d+ table_name" | head -60` (NOT a JSON-returning MCP `list_tables`).
- Ad-hoc query → `psql "$DB_URL" -c "SELECT ... LIMIT 50"` (NOT an unbounded `execute_sql`). Pipe through `head` / `jq -c` to bound output. Save large results to `/tmp/q.json` and `Read` only the slice you need.
- Edge / serverless function logs → `<provider> functions logs <name> | tail -100` (NOT an unbounded `get_logs`).
- Type generation → your project's `db:types` script (typically wraps `<provider> gen types`).
- Migration list → `<provider> migration list`.

**Write paths — keep MCP / managed tool:**
- Schema migrations: managed-tool `apply_migration` (never raw .sql files, never `psql` for DDL — bypasses migration history).
- After migrations: re-run type generation.

**Token-discipline rule:** before any DB read, mentally answer "what's the row-count ceiling?" If it's not bounded by a `LIMIT` or a known-small index lookup, add the `LIMIT` *before* running the query. The LLM-callable tools have no such ceiling and will dump everything they receive.

**Setup:** if `supabase` / `psql` are missing locally and your project uses them, install once: `brew install supabase/tap/supabase libpq && brew link --force libpq`.

## A specific trap: RLS-silently-no-op writes

When a write-path policy restricts writes to a privileged role (e.g., `service_role` on Postgres-with-RLS, owner roles in row-level-security setups), a user-JWT call returns `{ data: null, error: null }` — success-shaped, but the write never happened. Symptom: feature appears to work in dev (where you run as service role), silently fails in prod.

Diagnostic: when a write returns nothing-and-no-error, immediately re-query for the row you expected to insert. If absent, your call hit an RLS no-op. Fix is provider-specific — usually adding `WITH CHECK` to policies or routing the write through a privileged client.
