# `principles/` — status under v3 (consume-direct)

These are **teaching-material** — docs that taught the `bootstrap` generator HOW to author a `.claude/` for a project. Under v3, dotclaude ships a **consumable base** (`../agents`, `../skills`, `../hooks`) used as-is, so the role of each principle changed. Three buckets:

## 1. Now shipped as consumable artifacts — retire candidates

Their universal content is now a directly-consumed agent/skill/hook; bootstrap no longer authors them per-project. Kept for now as rationale and as `/distill` re-derivation source. A future explicit cleanup may remove them (deleting 28 docs is its own decision — not done silently).

- → consumable **agents**: `code-review`, `pre-flight`, `test-architect`, `data-integrity`, `skill-vs-code-audit`, `product-direction-validator`, `a11y-audit`, `ux-audit`, `interaction-audit`, `flow-audit`, `flow-continuity-review`, `pages-audit`, `design-token-audit`, `product-designer`.
- → consumable **skills**: `operating-principles` + `lean-by-default` (→ `operating-discipline`), `decomposition`, `journey-mapping`, `persona-testing`, `element-reuse`, `iterative-polish-autoloop`, `authoring-skills`, `handoff`, `plan-driven-work`, `knowledge-layers`, `memory-system`, `migration-create`, `saturday-ritual`.

## 2. Still bootstrap's input — keep

The thin `bootstrap` still reads these to author the **project-specific** layer it can't ship as a shared file (identity / architecture / quality-bar / knowledge-graph + the project's own routing table, design system, eval, voice list):

`project-identity`, `file-discipline`, `quality-rubric`, `design-benchmarking`, `knowledge-graph`, `task-classification`, `design-system-reference-skill`, `audit-routing`, `ai-cost-monitoring`, `forbidden-phrases`.

## 3. Universal but not yet converted — future base candidates

Project-agnostic, would fit the consumable base, but not yet promoted:

`database-query-discipline`, `visual-verification`.

---

*The split mirrors the v3 balanced line: universal + override-free → the consumable base; project-specific → the generator's input. See `../docs/v3-consume-direct-brainstorm.md`.*
