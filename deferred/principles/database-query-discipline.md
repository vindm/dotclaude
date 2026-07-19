# database-query-discipline — CLI > LLM-callable tool for reads

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to design the read-discipline rule for projects that have BOTH a CLI / `psql`-style DB access path AND an LLM-callable database tool (MCP server, BI plugin, IDE schema introspection, etc.).

## When to ship one (applicability gate)

Ship this rule when:

- The project has a **database accessible via more than one path** — typically CLI (`psql` / mongosh / redis-cli / sqlite3) + an LLM-callable tool (MCP, BI integration).
- The project has accidentally burned tokens on unbounded DB read results.
- Claude is doing meaningful DB-shape work (writing migrations, querying for debug, schema introspection).

Skip when:

- The project has no LLM-callable DB tool (only CLI is available). The rule is unnecessary.
- The project's DB reads are trivial (single-row lookups via well-bounded queries). No discipline needed.
- The user explicitly prefers MCP-only access (rare; usually because of credential sandboxing).

## Why it matters — what this catches that nothing else does

LLM-callable DB tools have a structural failure mode: they **dump the full result** of any query into the conversation context. A `list_tables` call on a project with 80 tables can produce 15k tokens of schema JSON. An `execute_sql` without a `LIMIT` clause can dump a million rows.

The CLI doesn't have this problem. `psql "$URL" -c "SELECT ... LIMIT 50"` runs the query, but the result lives on the terminal, not in the LLM's context. Even better: `psql ... > /tmp/q.json` returns nothing to the LLM until the LLM explicitly reads the slice it needs.

What this catches that nothing else does: a class of token waste that's invisible during the session and only shows up in the cost report later. Every unbounded MCP DB read silently burns tokens that could've been 90% cheaper via CLI. The discipline is the only mechanism that prevents the accumulation.

## Core methodology — the read / write split

The rule has two halves:

### Half 1 — Reads use CLI

Schema introspection, ad-hoc queries, log fetches, list operations: all reads default to the CLI path. Examples:

| Operation | LLM-tool path (avoid) | CLI path (default) |
|---|---|---|
| List tables | `mcp__db__list_tables` | `psql -c "\dt"` (Postgres), `sqlite3 .tables`, `mongosh --eval "db.runCommand({listCollections:1})"` |
| Describe table | `mcp__db__execute_sql` with `\d table` | `psql -c "\d+ table" \| head -60` |
| Ad-hoc query | `mcp__db__execute_sql` (unbounded) | `psql -c "SELECT ... LIMIT 50"` |
| Function logs | `mcp__db__get_logs` (unbounded) | `<runtime> logs <fn> \| tail -100` |
| Type generation | (depends) | `yarn db:types` (or stack equivalent) |
| Migration list | `mcp__db__list_migrations` (unbounded) | `<migration-tool> list` |

The CLI commands should be the project's actual setup. If `psql` requires the `SUPABASE_DB_URL` env var, the rule names that var. If the project uses `sqlx` for Rust, the rule references the right `sqlx-cli` command.

### Half 2 — Writes use the LLM-callable tool (when one exists)

Schema migrations, DDL, structured DML are written via the LLM-callable tool because:
- The tool understands the project's migration history.
- The tool may enforce safety guardrails (transaction wrapping, dry-run, etc.).
- Writes via raw `psql` bypass the migration log and are harder to roll back.

Examples:
- `mcp__db__apply_migration` for schema changes — never raw `.sql` files via `psql`.
- Tool-provided import / restore for bulk data load.

### The token-discipline mental ritual

Before any DB read, ask: *"What's the row-count ceiling on this result?"*

- If bounded by a `LIMIT` or a known-small index lookup → run it.
- If unbounded → add the `LIMIT` first, OR pipe through `head` / `jq -c` to bound the output, OR redirect to `/tmp/q.json` and `Read` only the slice needed.

The MCP tools have no such ceiling. The CLI tool obeys what you tell it.

## How to derive THIS project's specifics

Before authoring the rule, gather:

1. **The DB platform.** Postgres? MySQL? SQLite? MongoDB? DynamoDB? Each has different CLI commands.

2. **The connection-string env var.** `DATABASE_URL`? `SUPABASE_DB_URL`? `MONGODB_URI`? The rule should name the env var the CLI uses.

3. **The LLM-callable tool inventory.** Which MCP tools are wired? Which BI / dashboard integrations does the user use? The rule covers each.

4. **Existing wrapper commands.** Many projects have `yarn db:types`, `npm run schema:check`, `mage db:dump`, etc. These are usually safe (well-bounded) — the rule should reference them by name rather than reinventing.

5. **Log-fetching command.** Often DB-adjacent — e.g., Supabase has `supabase functions logs`, AWS has `aws logs tail`. The rule should name the project's actual log-fetch command.

6. **Setup instructions.** If `psql` isn't installed by default, the rule should name the install command (`brew install libpq && brew link --force libpq`, etc.). One-time setup notes belong in the rule so future Claudes don't re-discover them.

## Authoring the rule

The final rule (typically `.claude/rules/database-queries.md`) should specify:

1. **The platform + connection string.** Concrete.
2. **The CLI-first principle.** One sentence, prominently.
3. **The reads-table** — operation → CLI command, with the LLM-tool path called out as avoid-by-default.
4. **The writes-table** — operations that DO use the LLM tool (typically migrations).
5. **The token-discipline ritual.** "Before any read, ask 'what's the row-count ceiling?'"
6. **Setup instructions** for the CLI tools if they're not part of typical dev setup.
7. **Gotchas** specific to the project's DB platform (Postgres `numeric` returning strings, MongoDB `_id` ObjectID gotchas, etc.).

## Cross-references

- `data-integrity.md` — the agent uses this rule's CLI-first discipline for its audit queries.
- `migration-create.md` — uses the writes-via-LLM-tool path for migrations.
- `code-review.md` — should flag any new code reading from the DB without an explicit LIMIT.
- `pre-flight.md` — Phase 2 (data layer) queries should follow this rule.

## Anti-patterns in the rule you write

- **Vague "use CLI"** without the concrete command for each operation. The user needs to know exactly what to type, not to derive it.

- **No write-path carve-out.** The rule should NOT say "use CLI for everything." Writes via raw CLI bypass migration history and create rollback nightmares. The migration tool exists for a reason.

- **Forgetting platform-specific gotchas.** Postgres `numeric` returning strings, MySQL collation gotchas, SQLite type affinity — these are platform-specific and worth including.

- **No mental ritual.** Without the "what's the row-count ceiling?" framing, the user just reads the table and runs queries. The framing is what makes the discipline portable to NEW operations not in the table.

- **Out-of-date connection info.** If the env var is wrong, every example in the rule fails. Verify the actual env var at authoring time.

- **No "where to find more" pointer.** When the user hits a case the rule doesn't cover, they should know where to look. Reference the platform's official CLI docs or the project's existing wrappers.

- **No setup-time guidance.** A user who has never run `psql` will fail at the first command. The rule should have a one-line "if you don't have psql installed: <command>" note.

- **Treating LLM-tools as forbidden.** They're not forbidden; they're expensive. The rule should name when LLM-tools ARE appropriate (writes, complex tooling the CLI lacks) rather than treating them as anti-patterns universally.
