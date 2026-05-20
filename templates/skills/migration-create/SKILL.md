---
name: migration-create
description: Use when adding columns, tables, indexes, RLS policies, RPCs, or enums to the database schema. Wraps the migration workflow per your database type-generation conventions, enforces additive-safe defaults, prompts for RLS coverage, and reminds about telemetry on new write paths. Invoke as `/migration-create <snake_case_name>`.
paths: "supabase/migrations/**,db/migrations/**,src/db/**,lib/db/**"
---

# migration-create

Apply a database migration through your project's CLI (Supabase CLI, Prisma, Drizzle, etc.), regenerate types automatically (if a PostToolUse hook is wired), and surface the cross-cutting concerns that schema changes always touch: RLS / authorization, parallel paths, telemetry.

## Why this exists

Schema changes cluster around a few footguns documented across `db-types`, `pipeline-integrity`, and database-backend skills:

- Forget RLS → tenant data leaks across boundaries.
- Forget type regeneration → TS drifts from runtime, `numeric` columns silently break downstream code.
- Forget telemetry on new write paths → corpus / observability rate-limiter clogs.
- Forget parallel paths → twin tables drift; dual-path enrichment skips fields.

This skill makes those reminders mandatory at the moment they're load-bearing.

## When to use

- Any addition / change to `public.*` tables, columns, indexes, RLS, RPCs, or enums
- Promoting `metadata_json` keys to real columns
- Adding new write paths that should emit telemetry events
- Schema work that landed in a brainstorm doc and needs to ship

## When NOT to use

- Editing existing historical migration files — those are frozen artifacts. Changes go via fresh migration only.
- Pure RLS audits with no schema change — use your database-backend skill's audit pattern.
- Local-only experiments — use your local type-generation flow.

## Inputs

User passes `<snake_case_name>` describing the migration intent. Examples: `intent_fields_add`, `objects_add_score_column`, `observations_geometry_index`, `relations_endpoint_kind_enum`.

If the user passes prose ("add score column to objects"), convert it to snake_case yourself. Don't ask — the convention is well-established in any historical migration list.

## Workflow

### Step 1 — Classify the change

| Class | Examples | Risk |
|---|---|---|
| **Additive-nullable column** | `ALTER TABLE t ADD COLUMN c kind` (no NOT NULL) | Safe on main; ship without ask |
| **Additive index** | `CREATE INDEX CONCURRENTLY ...` | Safe but can block writes if not CONCURRENTLY |
| **New table** | `CREATE TABLE t (...)` | Safe; needs RLS + grants |
| **New enum / new value** | `CREATE TYPE` / `ALTER TYPE ADD VALUE` | Safe forward; rollback is hard |
| **New RPC / function** | `CREATE FUNCTION f(...) ... SECURITY DEFINER` | Safe; verify SECURITY DEFINER + search_path |
| **Backfill of existing rows** | `UPDATE t SET c = ...` | Risky on large tables; chunk + monitor |
| **NOT NULL on existing column** | `ALTER COLUMN c SET NOT NULL` | Requires backfill first |
| **Drop / rename / type-change** | `DROP COLUMN`, `ALTER COLUMN c TYPE u` | **Always ask before applying** |

For destructive changes, surface the class and ask before proceeding. The convention: "Destructive (drop / rename) — ask first, even via direct DB CLI."

### Step 2 — Compose the SQL

Apply the conventions baked into existing migrations:

- Snake_case names; `*_id` for FKs; `*_at` (epoch ms `bigint` if your project uses that convention; otherwise `timestamptz`) for timestamps; `*_json` for ad-hoc bags.
- New enum migrations: follow the **drop default → drop constraint → retype → set default** order. Order matters; default is `text`-typed and would block the cast.
- `numeric` columns will return as **strings** at runtime (PostgREST and many JS DB clients). Prefer `float4`/`float8` when the value is JS-arithmetic-bound. `numeric` only when precision matters (money, identity scores).
- Grants: any new table needs `GRANT SELECT, INSERT, UPDATE, DELETE ON <table> TO authenticated, service_role` (or narrower per RLS plan).

### Step 3 — RLS plan (REQUIRED for new tables)

For every new table or new RLS-relevant column, state:

1. Who reads? (anon / authenticated / service_role)
2. Who writes? (same)
3. What's the predicate? (e.g., `tenant_id IN (SELECT tenant_id FROM tenant_members WHERE user_id = auth.uid())`)
4. Are there owner-only rows? (e.g., `tenants.owner_user_id = auth.uid()`)

Then write the `ENABLE ROW LEVEL SECURITY` + `CREATE POLICY` statements in the same migration. **Don't apply a table without RLS** — production has policies; missing policies = leaked data.

If the user can't articulate the predicate, stop and ask. Don't guess RLS — a wrong policy is worse than a blocked migration.

### Step 4 — Apply via your database CLI

Use your project's standard migration command. For Supabase MCP projects, this is `mcp__supabase__apply_migration` with the project ID. For projects using direct CLI, this is the relevant `supabase migration new` / `prisma migrate dev` / `drizzle-kit push` flow.

If a PostToolUse hook on the migration command is wired, it'll automatically run type regeneration. If not, run your project's type-generation command manually after the migration applies. **Don't paste raw type-output into the auto-generated `database.types.ts` file by hand** — the hook (or CLI) handles it.

If the type regen fails (CLI exit code != 0), the migration *still applied*. Re-run type generation manually and investigate why the regen failed.

### Step 5 — Cross-cutting reminders

After the migration applies, surface these checks. Don't auto-fix; report and let the user decide:

#### Parallel paths

Run a quick grep for the affected entity:

```bash
grep -rn "<table_name>\|<column_name>" src/ app/ --include='*.ts' --include='*.tsx' | head -30
```

Flag any code path that inserts into the same table without including the new column when the column is meant to be set on insert. The `code-reviewer` agent calls this "parallel path detection" — for migrations it's the same pattern: dual writers drift silently.

#### Telemetry

If the migration adds a *write path* (new table that gets inserted into, or new "intent" / "event" column), check whether the writer lives in your project's job / pipeline / workflow modules. Those paths should emit telemetry events per your project's telemetry convention.

Surface the path; let the user wire it via your project's telemetry-instrumentation skill or slash command.

#### Hand-curated type bridge

If your project keeps a hand-curated bridge file at `src/db/types.ts` or similar, it may need a new `*Row` / `*Insert` alias. Convention: "Import from bridge file, not `database.types.ts` directly." If the new column belongs to an entity that already has a bridge type, suggest the alias addition.

#### Twin-table parallel

Some projects keep a primary truth table (e.g. `objects` for spatial position) plus an enrichment-overlay table keyed by FK. If the migration touches identity / position / detection metadata, it almost always belongs on the truth table, not the overlay. Surface this if the project's convention applies.

## Output

After applying, render:

```markdown
## /migration-create: <name> — APPLIED

### Migration
<class — additive nullable / new table / etc.>

### RLS
<plan summary, policies created>

### Auto-regen
<type-gen command> — <ok / failed>

### Cross-cutting checks
- Parallel paths in <files>: <none / N writers; review needed>
- Telemetry: <not applicable / wire up at <path>>
- Hand-curated type bridge: <up to date / suggest add `<TypeName>Row`>
- Twin-table placement: <correct / mismatched>

### Next steps
[concrete, e.g. "wire telemetry event in src/jobs/processors/specs.ts" or "review insert paths in src/import/index.ts"]
```

## Common pitfalls

| Symptom | Cause | Fix |
|---|---|---|
| Hook fired but types didn't regen | type-gen command shells to remote DB; needs network + auth | Run manually; check CLI status |
| `Edit <database.types.ts>` blocked | Intentional deny rule in `settings.json` | Use `Write` for full-file replacement, or run type-gen |
| New enum value not visible in code after regen | TS union derived from generated enum — usually picks up automatically; if not, a hand-typed alias may exist | Update the alias to derive from the generated enum type |
| RLS policy blocks legitimate query | Predicate too narrow | Test with `service_role` to confirm it's RLS, not query bug |
| Migration applied but rolled back implicitly | Some CLI errors return success but DB wasn't changed | Verify with `list_tables` or `psql` |

## Don't

- Don't write raw `.sql` files into the migrations folder unless your project's tooling explicitly requires that (most CLI tools manage this for you).
- Don't apply destructive migrations (drop / rename / type-change) without explicit user OK.
- Don't ship a new table without RLS in the same migration.
- Don't assume type-gen ran successfully — check the exit code in the hook output.
- Don't skip the parallel-path grep when the migration touches a twin-table pair (truth + overlay) — drift is silent.
- Don't propose a "follow-up migration to add the index later" — additive indexes are cheap; ship them in the same migration.

## Cross-references

- your project's `db-types` skill (if present) — type bridge conventions, MCP-first rule, numeric-string footgun, enum migration pattern
- your project's database-backend skill (`supabase`, `prisma`, `drizzle`, etc.) — RLS patterns, auth client conventions
- `pipeline-integrity` skill (if present) — dual-path enrichment, parallel path detection
- your project's `database-query-discipline` rule — read paths via CLI, write paths via the migration CLI
