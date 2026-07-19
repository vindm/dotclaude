# Deferred domains

This directory holds domain elicitation skills, agents, and principles that are unique and valuable but niche — they apply only to projects with specific stacks (databases, AI workflows). They were deferred (not deleted) to keep the shipped plugins focused while demand clarifies.

## What's parked

### `data` domain
Database and persistent-state discipline kit:
- **Agent:** `agents/data-integrity.md` — five-category integrity audit (schema drift, orphaned records, stale access policies, migration safety, query cost)
- **Skill:** `skills/data/` — elicits a project-specific data-auditor agent, migration-create skill, query-discipline rule, optional RLS-security-reviewer
- **Principles:** `principles/data-integrity.md`, `principles/database-query-discipline.md`, `principles/migration-create.md`

**Applies to:** Any project with a persistent data layer (Postgres, SQLite, MongoDB, etc.) that has production data or migration workflows.

### `ai-workflow` domain
LLM workflow and cost discipline kit:
- **Agent:** `agents/` — (named for now, see below)
- **Skill:** `skills/ai-workflow/` — elicits an eval-cost-watcher agent that projects token cost before regression evals run, plus an AI-workflow-discipline rule covering mock-mode placement, fixture freshness, and cost accumulation
- **Principles:** `principles/ai-cost-monitoring.md`

**Applies to:** Projects with LLM calls in production or eval suites, where cost control and eval safety matter.

## Why deferred

Both domains are specialized enough that they add friction to project setup when they don't apply. A starter project with no database or AI usage shouldn't see `/dotclaude:data` or `/dotclaude:ai-workflow` in the skill menu. By parking them here, the shipped plugins stay lean while these remain available when a project genuinely needs them.

## How to revive one

If demand emerges (a major customer, clear use-case cluster, or internal need), revive a domain by:

1. **Move the domain back into the shipped plugins:**
   - Skills → `plugins/core/skills/<domain>/` (e.g., `plugins/core/skills/data/`)
   - Agent → `plugins/core/agents/<agent-name>.md`
   - Principles → `plugins/core/principles/<name>.md`

2. **Add its elicitation artifact(s) to the artifact contract** (`plugins/core/docs/artifact-contract.md`):
   - The domain elicitation writes ONE thin markdown artifact per project (e.g., `.claude/dotclaude/data-audit-config.md` for `data`)
   - Update the contract table with the artifact name, its writer (the elicitation skill), and its consumer (the agent or rule that reads it)
   - Example (for `data`):
     ```markdown
     | data | `.claude/dotclaude/data-audit-config.md` | data elicitation | `data-integrity` agent |
     ```

3. **Wire the consumed agent to read its artifact at runtime** (same pattern as `coding` / `testing`):
   - The agent reads the path from `dotclaude.yml` under `artifacts: <key>` (e.g., `artifacts.data-audit-config`)
   - Falls back to its generic methodology (in `principles/<name>.md`) when the artifact is absent
   - See `plugins/core/agents/code-review.md` and `plugins/core/skills/coding/SKILL.md` for the full pattern — the agent does NOT generate a fallback; the elicitation skill is the only author of project-local intent

## See also

- `plugins/core/docs/artifact-contract.md` — the elicit → artifact → consumed-agent contract
- `plugins/core/skills/coding/SKILL.md` — the template for elicitation skills
- `plugins/core/agents/code-review.md` — a consumed agent that reads `code-anti-patterns.md` at runtime
