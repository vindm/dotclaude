# data-integrity — designing a database integrity audit agent

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a data-integrity audit agent for projects with persistent state. The agent catches what code review and test coverage can't: latent corruption / drift / orphans accumulated over time in the actual production data.

## When to ship one (applicability gate)

Ship a data-integrity agent when:

- The project has a **database or persistent store** (relational DB, document store, key-value store, file-based persistence).
- The project has **complex write paths** (pipelines, jobs, multi-step workflows that write at various stages).
- The project has had at least one bug where the data ended up in an unexpected state.
- The data has lifecycle stages (created → processed → completed) where rows can get stuck.

Skip when:

- The project has no persistent state (pure stateless API, calculator app, etc.).
- The project's data is trivial (single-table flat structure with no pipelines / lifecycles).
- The project uses a managed service where the host enforces all the integrity constraints (rare in practice).

## Why it matters — what this catches that nothing else does

The bugs this catches are the ones where **the code is correct and the data is wrong.** Examples:

- **Stuck-job orphans.** A multi-stage pipeline got partway through; the row sits at stage 3 with stage 4's marker missing. The code logic to advance it has been fixed; the stuck row needs explicit detection + recovery.
- **Incomplete enrichment.** A pipeline produces records that should have N fields populated; some have N-1 because a downstream step failed silently. Tests pass; the rows are silently incomplete.
- **Orphaned references.** Row A.b_id references row B's primary key; row B was deleted; A.b_id still has the (now stale) value. Foreign-key cascades weren't set; the orphan lingers.
- **Cross-tenant leaks.** Row tagged with tenant X is accessible to tenant Y because the access policy has a bug. The query returns extra data; the user doesn't notice; the audit catches it.
- **Stale state machine markers.** A row's state machine columns show "in_progress" with `started_at` from 6 months ago. The job has been dead; nothing reaps it.
- **Silent no-op writes** (see `../examples/the-write-that-returned-success.md`). The trust-boundary class: the write succeeded-shaped but the row wasn't created. Periodic audit catches the resulting absence.

These don't surface in code review (the diff is fine). They don't surface in unit tests (the test data is clean). They don't surface in user testing (the affected user doesn't notice, or notices and stops using a specific feature). They surface in periodic data audit, or in a customer-support ticket six months later.

## Core methodology — five categories of check

The agent runs five families of integrity check. Each is a SQL (or store-specific) query; results are interpreted into a health report.

### Category 1 — Enrichment completeness

For each entity type that goes through an enrichment pipeline: are all expected fields populated?

```sql
-- Example shape (entity / fields are project-specific)
SELECT
  count(*) total,
  count(*) FILTER (WHERE field_a IS NOT NULL) has_a,
  count(*) FILTER (WHERE field_b IS NOT NULL) has_b,
  count(*) FILTER (WHERE field_c IS NOT NULL) has_c
FROM enriched_entities
WHERE created_at > now() - interval '30 days';
```

If `has_a` lags `total`, there are entities stuck without field_a. The audit reports the gap + lists 5–10 example IDs for investigation.

### Category 2 — Orphan detection

For each foreign-key relationship: do all referenced rows exist?

```sql
-- Rows pointing to non-existent parents
SELECT t.id, t.parent_id
FROM child_table t
WHERE NOT EXISTS (
  SELECT 1 FROM parent_table p WHERE p.id = t.parent_id
);
```

Orphans typically indicate: a delete that didn't cascade, a denormalization that wasn't kept in sync, a race condition where the parent was deleted between the child's read and write.

### Category 3 — Stale state-machine markers

For each entity with a state machine: are any rows in a non-terminal state for unreasonably long?

```sql
-- Stuck-in-progress rows
SELECT id, status, started_at
FROM jobs
WHERE status = 'in_progress'
  AND started_at < now() - interval '1 day';
```

Stuck rows usually indicate: a worker crashed mid-execution, a status update that didn't fire, a recovery path that doesn't promote stuck → retryable.

### Category 4 — Cross-tenant / access-policy verification

For multi-tenant systems: does any row's access policy allow tenants other than the owner?

```sql
-- Example: rows visible to multiple tenants
SELECT t.id, t.tenant_id, count(distinct policy.tenant_id)
FROM resources t
LEFT JOIN access_policies policy ON policy.resource_id = t.id
GROUP BY t.id, t.tenant_id
HAVING count(distinct policy.tenant_id) > 1;
```

Cross-tenant leaks are typically high-severity findings — a customer-trust + potentially-legal issue depending on the data.

### Category 5 — Invariant violations

For each business invariant: are there rows that violate it?

Examples:
- Subscription has a `cancelled_at` but `status = 'active'`.
- Order has `total_cents = 0` but `line_items.count > 0`.
- User has `email_verified_at` but `email IS NULL`.

These are project-specific invariants. The agent should encode the actual invariants the project holds.

## How to derive THIS project's specifics

Before authoring the agent, gather:

1. **The DB query method.** SQL via `psql`? MCP tool? ORM in script? The agent should use the cheapest path with explicit `LIMIT` bounds (see `database-query-discipline.md`).

2. **The project's schema map.** Which tables exist? Which have pipelines / enrichment / state machines? Which have multi-tenant access policies? The agent's queries derive from this map.

3. **The project's invariants.** What rules MUST hold about the data? "Every order has at least one line item." "Every paid subscription has a payment method." Each invariant is a query the agent runs.

4. **Recent data-integrity incidents.** Has the project shipped a data bug before? What did the incident look like? Encode the corresponding check.

5. **Multi-tenancy structure** (if applicable). How is tenancy enforced — row-level security, query-time filtering, separate databases? The cross-tenant check shape depends on this.

6. **Acceptable orphan / staleness thresholds.** "Stuck > 1 day" is arbitrary; the right threshold depends on the project's typical processing times. Calibrate per check.

## Authoring the agent

The final agent (typically `.claude/agents/data-auditor.md`) should specify:

1. **The connection method** — how to reach the DB; CLI-first per `database-query-discipline.md`.
2. **The five check categories** — enrichment / orphans / state-machine / cross-tenant / invariants.
3. **The queries per category** — project-specific SQL using project's actual table / column names.
4. **The severity tiers** — Crit (data corruption / cross-tenant leak) / High (orphans / invariant violations) / Med (stuck jobs) / Low (mild enrichment lag).
5. **The report format** — health summary, per-category findings with example IDs.
6. **The "report, don't fix" constraint** — the agent flags findings; remediation is a separate decision (some findings are bugs to fix; some are expected; some are evidence of an upstream problem).

## Report format

```markdown
## Data Health Audit — <date>

### Overall: <Good / Gaps / Critical>

<one-paragraph summary>

### Enrichment completeness
| Entity | Total | Has field A | Has field B | Has field C | Gap |
|---|---|---|---|---|---|

### Orphan detection
| Child table | Orphan count | Example IDs | Likely cause |
|---|---|---|---|

### Stuck state-machine rows
| Entity | Status | Stuck count | Oldest |
|---|---|---|---|

### Cross-tenant / access verification
| Issue | Affected rows | Severity |
|---|---|---|

### Invariant violations
| Invariant | Violating rows | Example IDs |
|---|---|---|

### Recommended actions
<grouped by severity>
```

## Cross-references

- `database-query-discipline.md` — query cost discipline. The agent uses CLI-first queries with explicit LIMITs.
- `migration-create.md` — when migrations introduce new fields / invariants, the agent should add corresponding checks.
- `code-review.md` — when the audit surfaces a write-path bug, the upstream fix flows through code-review.
- `pre-flight.md` — before changes to data pipelines, pre-flight should ask "what data-integrity checks will run after?"
- `../examples/the-write-that-returned-success.md` — paradigm for "the write succeeded-shaped and didn't persist." The audit's enrichment-completeness check catches the resulting absence.

## Anti-patterns in the agent you write

- **Queries without LIMITs.** A `SELECT * FROM big_table WHERE complex_predicate` can return millions of rows. The agent's queries should all have explicit row caps and return summary counts + example IDs, not the full rowset.

- **Fixing data from within the audit.** The agent reports; the user (or a separate remediation script) fixes. Some findings should NOT be fixed automatically (cross-tenant leak might require legal review; stuck rows might need investigation before deletion). Strict reporting role.

- **Audit without an interpretation.** Raw query results — "12 orphans" — are noise. The report includes interpretation: what this likely means, what to investigate, severity.

- **Schema-blind queries.** Queries copied from another project that reference tables this project doesn't have are wasted. The agent's queries must use this project's actual schema.

- **No "what's likely happening" diagnosis.** "Orphan count: 12" without "this is consistent with a missing ON DELETE CASCADE on the foreign key in `child_table.parent_id`" is unactionable. Each finding should have a diagnostic hypothesis.

- **No example IDs.** "20 stuck jobs" without IDs makes investigation impossible. Always include a sample of affected row IDs (bounded — 5–10, not all of them).

- **Periodic-only framing.** If the agent runs once and is forgotten, it produces a snapshot. The agent should be designed to run weekly / after deploys / on demand, with the report kept dated so trends are visible.

- **Acceptable-baseline confusion.** Some "findings" are expected baseline (e.g., 3 orphans/week from a known race condition that's not worth fixing). The agent should distinguish "new finding" from "known baseline" if possible.

## Tool surface

The agent needs: `Read`, `Grep`, `Glob`, `Bash` (for `psql` / CLI DB access), plus the DB MCP tool only for write paths (which the audit doesn't need — read-only by design).

Model: medium-capability (sonnet-class). The work is mostly query writing + result interpretation; not the heaviest reasoning workload.
Effort: medium. Runs frequently enough that cost discipline matters.
