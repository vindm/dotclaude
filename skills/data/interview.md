# `/dotclaude:data` interview

3-5 questions, adaptive. Skip what Phase 1 (project scan) already answered. The goal: extract the access-control model, the past data-integrity bug shapes, and the LLM-callable-DB-tool inventory — none of which can be reliably read from code alone.

## D1 — Database stack (skip if obvious)

> "I see `<platform + ORM>` in your deps. Confirming:
> - Platform: `<Postgres / SQLite / MongoDB / DynamoDB / etc.>`
> - Migration framework: `<Supabase migrations / Alembic / Knex / Drizzle / Prisma migrate / sqlx-migrate>`
> - Connection env var: `<SUPABASE_DB_URL / DATABASE_URL / MONGODB_URI>`
> - Type-regen command: `<yarn db:types / prisma generate / sqlx prepare>`
> 
> Anything off?"

Phase 1 should have surfaced most of this. Confirm and move to D2. Only ask the full question if Phase 1 left ambiguity.

## D2 — Access-control model (drives whether RLS-reviewer applies)

> "How does the project enforce who-can-read-what at the data layer?
> 1. **Database-level policies** — Postgres RLS, similar. Predicates run inside the DB; bypassing application logic still respects them.
> 2. **Application-layer** — every query filtered by `tenant_id` / `owner_id` / equivalent in the app code; the DB itself allows any-row access.
> 3. **Managed service** — the host (Firebase Firestore, Supabase Auth, etc.) handles access policies; the app doesn't think about it.
> 4. **None / single-tenant** — no multi-tenancy in scope; everyone with DB access sees everything."

If (1): ship `rls-security-reviewer.md`. The reviewer catches the war-story pattern (RLS silent no-op on user-scoped writes).

If (2): skip `rls-security-reviewer.md`. Surface the app-layer enforcement to the data-auditor's cross-tenant category instead (the audit query joins through the app-layer filter to detect leaks).

If (3) / (4): skip both. Note in the kit overview why.

## D3 — Migration discipline + past failures (drives destructive-change gate)

> "Two questions:
> 1. Schema changes — always via migrations, or sometimes direct DDL? Any pattern of 'I hotfixed prod by running raw SQL'?
> 2. Has the project shipped a bad migration before? Examples of the shape:
>    - 'We dropped a column that was still referenced downstream and broke the app for 20 minutes.'
>    - 'We renamed a column, forgot to regenerate types, and the next deploy compiled but failed at runtime.'
>    - 'We added a NOT NULL column without a default and a `CREATE INDEX` without `CONCURRENTLY`; the deploy locked the table for 4 minutes.'
>    - 'We forgot the access policy on a new table and a customer's data was visible to all other authenticated users.'"

If yes to direct DDL: encode the migration-create skill's "this is a destructive change, are you SURE" gate more strictly — the user has the muscle memory for shortcuts and the gate is the discipline.

If yes to a past bad migration: the war story shapes a specific entry in the migration skill's classification table. E.g., "We've shipped this kind of bug before" entries warrant a more aggressive prompt-before-apply for that change class.

## D4 — Past data-integrity bugs (project-specific audit checks)

> "Have you ever discovered the data was wrong even though the code was right? Examples of the shape:
> - Orphan records (FK references pointing at deleted parents)
> - Stuck-state-machine rows (jobs in 'processing' for weeks)
> - Incomplete enrichment (records missing fields they should have)
> - Cross-tenant leaks (data visible to the wrong tenant)
> - Invariant violations (subscriptions with `cancelled_at` set but `status = active`)
> - Silent no-op writes (the row should exist but doesn't, no error in the logs)"

Each named pattern becomes a project-specific check in the data-auditor's body. The agent's queries should target the actual tables / columns where these bugs surfaced.

If the user hasn't experienced any of these yet (or doesn't recall): float that the audit categories will be GENERIC and may need refinement as real bugs surface. The agent ships with placeholder coverage of all 5 categories; the user updates it after the first real finding.

## D5 — LLM-callable DB tools (drives query-discipline rule emphasis)

> "Two questions:
> 1. Do you use an LLM-callable DB tool — Supabase MCP, a BI integration, IDE schema introspection, anything that lets Claude or another agent run DB queries directly?
> 2. Have you ever been surprised by token cost on what you thought was a cheap query? (E.g., `list_tables` on a project with 80 tables produced 15k tokens of JSON.)"

If yes to (1): ship the `database-query-discipline.md` rule. The rule's value scales with how often the user reaches for the LLM-callable tool — every unbounded read silently burns tokens that could've been 90% cheaper via CLI.

If no to (1): skip the rule entirely. CLI-only access doesn't have the discipline problem.

If yes to (1) but no to (2): the user hasn't been burned yet but the structural risk exists. Ship the rule anyway with the rationale: "This is a tripwire for the day you DO get burned. The cost is one paragraph in the rule; the savings are token-bill insurance."

---

## How to use this script

- Don't fire-hose. One or two questions per turn, conversational.
- Lead with data when you have it (Phase 1 has the platform, migration framework, connection string format — confirm rather than re-ask).
- Skip ruthlessly. Single-tenant project with no MCP DB tool → skip D2 / D5 entirely.
- Listen for "we always X" patterns. Each one is either a check the audit should run or a gate the migration skill should fire.

## After the interview

Summarize back before authoring:

> "Based on our chat: platform = `<X>`, access-control = `<RLS / app-layer / managed>`, RLS reviewer = `<yes / no>`, query-discipline rule = `<yes / no>`, project invariants to encode = `<list>`, past bugs to catch = `<list>`. About to author the kit — confirm?"

Wait for confirmation, then proceed to Phase 4 of `SKILL.md`.
