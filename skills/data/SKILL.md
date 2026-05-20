---
description: Set up database / persistent-state discipline for a project with a DB. Authors a data-auditor agent (5 categories of integrity check), a migration-create skill, query-discipline rule (CLI > MCP DB tool for reads), and edit-time regen hook — all derived from the project's actual schema, migration framework, and access-control model. Optionally an RLS-security-reviewer if Postgres + row-level security is in use. Invoke /dotclaude:data in any project with persistent state.
---

# `/dotclaude:data` — database + persistent-state discipline kit

You are setting up the data layer's audit + safety discipline. The output is a `.claude/` subset focused on what code review and tests can't catch: latent corruption / drift / orphans in the actual data, migration safety, query cost, and access-policy correctness.

The data-auditor agent runs the five-category integrity sweep; the migration-create skill enforces the four-step migration workflow; the query-discipline rule prevents the unbounded-MCP-DB-read class of token waste.

## Phase 1 — Read the project's data shape

Before any question:

1. **DB platform + ORM / framework** — read whichever exists:
   ```bash
   cat package.json 2>/dev/null | grep -E "supabase|prisma|drizzle|knex|sequelize|typeorm|mongodb|mongoose|sqlite|pg|mysql"
   cat Cargo.toml 2>/dev/null | grep -E "sqlx|diesel|sea-orm|tokio-postgres"
   cat pyproject.toml 2>/dev/null | grep -E "alembic|sqlalchemy|django|asyncpg|psycopg|pymongo"
   cat go.mod 2>/dev/null | grep -E "gorm|sqlx|ent|mongo-go-driver"
   ```

2. **Migration directory** — find it:
   ```bash
   ls migrations/ db/migrations/ supabase/migrations/ alembic/versions/ 2>/dev/null
   find . -path ./node_modules -prune -o \( -name "*.sql" -o -name "*migration*" \) -print 2>/dev/null | head -20
   ```
   Note the convention: how migrations are named, whether they include UP + DOWN, whether they include access-policy blocks alongside DDL.

3. **Schema files** — find canonical schema sources:
   ```bash
   ls schema.sql schema.prisma drizzle/schema.* 2>/dev/null
   find . -name "*.types.ts" -path "*db*" -o -name "database.types.ts" 2>/dev/null | head
   ```

4. **Access-control signal** — does the project use RLS / equivalent?
   ```bash
   # Postgres RLS
   grep -rn "row level security\|enable rls\|create policy" migrations/ db/ supabase/ 2>/dev/null | head
   # Application-layer auth
   grep -rn "tenant_id\|workspace_id\|owner_id" --include="*.ts" lib/ src/ 2>/dev/null | head
   ```

5. **DB connection signal** — figure out the env var:
   ```bash
   grep -rn "SUPABASE_DB_URL\|DATABASE_URL\|MONGODB_URI\|REDIS_URL\|POSTGRES_URL" \
     .env.example .env.sample README.md docs/ 2>/dev/null | head
   ```

6. **LLM-callable DB tools** — check for MCP servers / BI integrations:
   ```bash
   ls .mcp.json 2>/dev/null
   grep -l "mcp__supabase\|mcp__postgres\|mcp__mongo" .claude/ 2>/dev/null
   ```
   The presence (or absence) of an LLM-callable DB tool determines whether the query-discipline rule applies — if only CLI exists, the rule is unnecessary.

7. **Wrapper commands** — `yarn db:types`, `prisma generate`, `sqlx prepare`, etc.:
   ```bash
   cat package.json 2>/dev/null | grep -A 2 '"scripts"' | grep -E "db|migrate|types|schema"
   ```

8. **Recent data-integrity fixes** — `git log --oneline --grep="orphan\|integrity\|cascade\|stuck\|cross-tenant\|RLS\|policy" -20`

Build mental model of: what platform, what migration framework, whether RLS applies, whether MCP DB tools exist (and so query-discipline applies), what wrapper commands the user already has.

## Phase 2 — Interview

Open `interview.md` (same directory). 3-5 questions. Adaptive — skip what Phase 1 already answered.

- **DB stack** — usually obvious; only ask if Phase 1 didn't resolve.
- **Access-control model** — RLS / app-layer / managed? Drives whether `rls-security-reviewer` is worth shipping.
- **Migration discipline** — past production migration failures? Drives the destructive-change gate's strictness.
- **Past data-integrity bugs** — orphans, stuck jobs, cross-tenant leaks? Project-specific audit checks.
- **LLM-callable DB tools in use** — drives query-discipline rule emphasis.

## Phase 3 — Read the principles

Read these from `../../principles/` SELECTIVELY:

**Always read** (any project with a DB):
- `data-integrity.md` — the five-category audit methodology
- `migration-create.md` — the four-step migration workflow

**Read if Phase 1 shows BOTH CLI + LLM-callable DB tools exist**:
- `database-query-discipline.md` — the read/write split methodology

**Cross-reference** (link from the data-auditor, do not re-author):
- `code-review.md` — code-review catches write-path bugs; data-auditor catches their downstream effects
- `pre-flight.md` — pre-flight should ask "what data-integrity checks fire after this?"

**Read the war-story example** — load-bearing for this skill:
- `../examples/the-write-that-returned-success.md` — RLS silent no-op. Both the data-auditor's enrichment-completeness check AND the migration-create skill's access-policy step exist because of this class of bug.

## Phase 4 — Author the kit

### Agents (in `.claude-staging/agents/`)

- **`data-auditor.md`** — the five-category integrity audit agent
  - Frontmatter: `description:` — derived from `data-integrity.md` principle, tuned to THE user's schema
  - Tool surface: `Read, Grep, Glob, Bash` (CLI `psql` / `mongosh` / equivalent for reads). NOT the LLM-callable DB tool for reads — see query-discipline rule. The agent is read-only; no `Edit` or `Write`.
  - Body sections:
    - The five-category methodology (enrichment-completeness / orphan-detection / stale-state-machine / cross-tenant / invariant-violation)
    - **Project-specific queries** for each category, using THE project's actual table names, column names, lifecycle stages. NOT placeholders like `entity_table`. Read the schema in Phase 1; write the SQL.
    - All queries have explicit `LIMIT` clauses and return summary counts + 5-10 example IDs (NOT full rowsets — see `database-query-discipline.md`)
    - **Project-specific invariants** — the rules the user named in the interview. E.g., "Every order has at least one line item" → query that flags orders with zero line items.
    - **Project-specific staleness thresholds** — calibrate against the user's typical processing times. Not "stuck > 1 day" generic; "stuck > <N> minutes for jobs whose 95th percentile completes in <M> minutes" specific.
    - Severity tiers (Crit = data corruption / cross-tenant leak; High = orphans / invariant violations; Med = stuck jobs; Low = mild enrichment lag)
    - Report-format template with the structured table per category
    - "Report, don't fix" constraint explicit

- **`rls-security-reviewer.md`** (ONLY if Phase 1 confirms RLS is in use)
  - The Postgres-specific access-policy auditor
  - Walks new migrations + new tables for: policy presence, predicate sanity, role grants
  - Specifically catches the war-story pattern (RLS silent no-op on user-scoped writes)
  - Skip authoring entirely if the project uses app-layer auth or a managed service that enforces tenancy upstream — a generic RLS reviewer on a non-RLS project is noise.

### Skills (in `.claude-staging/skills/`)

- **`migration-create/SKILL.md`** — the four-step migration workflow skill
  - User-invocable (`/migration-create <name>`)
  - The four steps (classify / compose / access-policy-plan / apply+regen+smoke-test)
  - **Project-specific risk classification table** — tuned to the platform. Postgres-specific entries (e.g., `ALTER TYPE ADD VALUE` is forward-only) vs MySQL-specific (online DDL behavior on InnoDB) vs MongoDB (no migrations beyond app-layer schema).
  - **Project-specific naming + type conventions** — read 2-3 of the user's existing migrations and mirror them. Snake_case columns? Singular vs plural tables? `timestamptz` vs `bigint` epoch?
  - **Access-policy plan step** — ALWAYS for new tables (if RLS); the skill REFUSES to apply a new-table migration without a policy block in the same migration
  - **Type-regeneration step** — names THE actual command (`yarn db:types`, `prisma generate`, `sqlx migrate run`, `sqlc generate`)
  - **Destructive-change confirmation gate** — explicit ASK BEFORE on `DROP COLUMN`, `RENAME COLUMN`, `ALTER COLUMN TYPE`. Even if the user's prompt said "drop column X."
  - **Cross-cutting reminders** — telemetry, UI plumbing, backup, cache invalidation (whichever apply to THIS project)

### Rules (in `.claude-staging/rules/`)

- **`database-query-discipline.md`** (ONLY if BOTH CLI + LLM-callable DB tool exist)
  - Platform + connection-string env var (concrete — not `DATABASE_URL` generic if the user uses `SUPABASE_DB_URL`)
  - The CLI-first principle — one sentence, prominent
  - The reads-table with the project's actual operations and CLI commands
  - The writes-table — operations that DO use the LLM-callable tool (typically just migrations)
  - The token-discipline ritual ("before any read, what's the row-count ceiling?")
  - Platform-specific gotchas (Postgres `numeric` returns strings, MongoDB `_id` ObjectID quirks, MySQL collation, etc.)
  - One-time setup commands if `psql` / `mongosh` / equivalent isn't installed by default

### Hooks (in `.claude-staging/hooks/` — render from `../../hook-templates/`)

- **`regen-generated-artifacts.sh`** — substitute `{{regenCommand}}` with THE project's actual type-regen command (`yarn db:types` / `prisma generate` / etc.)
  - Fires after migration edits, runs the command, surfaces output. Prevents the "migration shipped, types drifted" failure mode.

## Phase 5 — Stage + present + commit

### Staging

Write everything to `.claude-staging/` first, organized by artifact type.

### Present

Walk the user through:

1. **The kit overview** — what landed
2. **Top 2-3 highlight artifacts** — concrete reasoning. NOT "I added a data-auditor" but: "The data-auditor's enrichment-completeness check covers your <N> pipeline-bearing tables — `<table1>`, `<table2>`, `<table3>`. The orphan-detection runs on your <M> FK relationships. The cross-tenant check uses `<column>` as the tenant boundary, per the convention in your schema. Project-specific invariants encoded: <list from interview>."
3. **Migration discipline** — show the destructive-change gate explicitly: "The migration-create skill will REFUSE to apply a `DROP COLUMN` without your confirmation, even if you ask. Same for `RENAME`. Type-regen runs `<actual-command>` after every apply."
4. **Query-discipline rule** (if shipped) — call out the cost asymmetry: "Your `<MCP-DB-tool-name>` dumps unbounded JSON; `psql -c '... LIMIT 50'` returns nothing to context until you Read it. The rule encodes the table of when to use which."
5. **What got SKIPPED** — and why. "Skipped `rls-security-reviewer.md` because you use app-layer auth, not RLS — the agent would be noise."
6. **Model + token-cost note** — data-auditor uses mid-tier model and is moderately expensive (especially if the schema is large). Migration-create is cheap per invocation (composing SQL is light work).

### Approve → commit

After explicit user approval, move `.claude-staging/` → `.claude/` and commit with structured message:

```
feat(.claude): data discipline (dotclaude:data)

Authored:
- agents:  data-auditor[, rls-security-reviewer]
- skills:  migration-create
- rules:   [database-query-discipline]
- hooks:   regen-generated-artifacts

DB platform: <postgres / sqlite / mongo / etc.>
Access-control model: <RLS / app-layer / managed>
Project invariants encoded: <count>
Type-regen command: <actual command>
```

## Non-negotiable rules for this flow

1. **Queries use the project's actual schema.** The data-auditor's SQL must reference real table names, real column names, real FK relationships. Don't ship `SELECT * FROM entity_table WHERE field_a IS NULL` — ship `SELECT id, status FROM equipment WHERE identity_confidence IS NULL LIMIT 10`. Read the schema; write the queries. If you can't find a table the audit category needs, skip that category for now and note the gap — better to ship 3 categories that work than 5 that are placeholders.

2. **All queries have explicit `LIMIT` clauses.** Unbounded queries are how the data-auditor itself becomes a token-cost problem. Every query returns summary counts + 5-10 example IDs, not full rowsets. This is structural; encode it in the agent's body as a constraint on every query it composes.

3. **Migration-create REFUSES destructive changes without confirmation.** Even if the user's prompt is `/migration-create drop the email column`, the skill must respond: "This is a destructive change. Confirm you want to proceed and that you've audited downstream code for references to `email`." Confirmation is structural, not advisory. The user can override after the gate; the gate's existence is what prevents the accidental drop.

4. **Access-policy plan is mandatory for new tables (if RLS applies).** The skill refuses to apply a new-table migration without a policy block in the same migration. If the user can't articulate the policy predicate, the skill STOPS and asks. Guessing at predicates is worse than blocking; the war story (`the-write-that-returned-success.md`) is precisely the failure mode this gate prevents.

5. **Type-regen is mandatory after every migration.** The skill's apply step is not "apply migration"; it's "apply migration AND run regen AND smoke-test." Skipping regen ships a migration whose downstream types are stale — the bug shows up in unrelated code 2 days later.

6. **Reads use CLI; writes use the LLM-callable tool.** If both paths exist, the rule encodes this explicitly. Don't soften the rule because the MCP tool is convenient — every unbounded MCP read silently burns tokens. The CLI is the default. The MCP tool is reserved for writes (where it adds migration-tracking value).

7. **Skip what doesn't apply.** If the project uses app-layer auth (not RLS), skip `rls-security-reviewer.md`. If the project has no LLM-callable DB tool, skip `database-query-discipline.md` (the rule is unnecessary). Each skip is a deliberate decision logged in the kit overview, with a reason. Phantom artifacts dilute the kit's value.

8. **Severity tiers anchor remediation urgency.** Cross-tenant leak = Crit = block ship + remediate immediately. Stuck jobs = Med = log a ticket. Mild enrichment lag = Low = informational. Without the severity discipline, the user sees a flat list of findings and can't prioritize; with it, the user knows which finding is the fire and which is the backlog.
