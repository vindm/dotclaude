# `principles/` — status under v3 (consume-direct)

These are **teaching-material** — docs that taught the `bootstrap` generator HOW to author a `.claude/` for a project. Under v3, dotclaude ships a **consumable base** (`../agents`, `../skills`, `../hooks`) used as-is, so the role of each principle changed. Three buckets:

## 1. Now shipped as consumable artifacts — retire candidates

Their universal content is now a directly-consumed agent/skill/hook; bootstrap no longer authors them per-project. Kept for now as rationale and as `/distill` re-derivation source. A future explicit cleanup may remove them (deleting 28 docs is its own decision — not done silently).

- → consumable **agents**: `code-review`, `pre-flight`, `test-architect`, `skill-vs-code-audit`, `product-direction-validator`. (The design auditors — `a11y-audit`, `ux-audit`, `interaction-audit`, `flow-audit`, `pages-audit`, `design-token-audit`, `product-designer` — now ship in the separate dotclaude-design plugin.)
- → consumable **skills**: `operating-principles` + `lean-by-default` (→ `operating-discipline`), `decomposition`, `knowledge-layers`. (The design-only skills — `journey-mapping`, `persona-testing`, `element-reuse`, `iterative-polish-autoloop` — now ship in dotclaude-design.)

## 2. Still bootstrap's input — keep

The thin `bootstrap` still reads these to author the **project-specific** layer it can't ship as a shared file (identity / architecture / quality-bar + the project's own routing table, design system, eval, voice list):

`project-identity`, `file-discipline`, `quality-rubric`, `design-benchmarking`, `task-classification`, `design-system-reference-skill`, `audit-routing`, `ai-cost-monitoring`.

## 3. Universal but not yet converted — future base candidates

Project-agnostic, would fit the consumable base, but not yet promoted:

`database-query-discipline`, `visual-verification`.

---

*The split mirrors the v3 balanced line: universal + override-free → the consumable base; project-specific → the generator's input.*
