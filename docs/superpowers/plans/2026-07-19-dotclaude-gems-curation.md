# dotclaude Gems Curation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce dotclaude to its gems — split into two focused plugins (CORE + design), replace tool-copy generation with per-domain elicitation that writes thin artifacts consumed agents read at runtime, and cut duplicates of superpowers/built-ins.

**Architecture:** One repo, one `marketplace.json`, two independently-installable plugins under `plugins/core/` and `plugins/design/`. Domain generators shrink to elicitation-only; consumed agents gain a "read the project artifact, fall back to defaults" contract. No generated agent copies.

**Tech Stack:** Claude Code plugin format (agents/skills/hooks as markdown + JSON), bash hook scripts, `jq` for JSON validation, `git mv` for history-preserving moves.

## Global Constraints

- **Spec:** `docs/superpowers/specs/2026-07-19-dotclaude-gems-curation-design.md` — the authority; every task traces to it.
- **Two plugins, one promise each.** CORE = "a senior who won't let you shoot your own foot." DESIGN = "the AI design/UX auditor nobody else has."
- **Consumed, not generated.** Agents read project facts at runtime + a thin `.claude/dotclaude/<domain>.md` artifact + `dotclaude.yml` knobs. Never author a project-local copy of a plugin agent.
- **Config boundary:** what Claude Code itself reads → `settings.json` (permissions, hook registration); what only dotclaude tools read → `dotclaude.yml` (hook thresholds, artifact locations, ceilings, boundaries, deny-lists).
- **Domain artifact location (in a consuming project):** `.claude/dotclaude/code-anti-patterns.md`, `.claude/dotclaude/test-risk-model.md`, `.claude/dotclaude/design-north-star.md`. `dotclaude.yml` records these paths.
- **Preserve history:** move files with `git mv`, never delete-and-recreate.
- **Every phase leaves the repo installable.** After each phase, `jq . <every plugin.json/marketplace.json>` must pass and no reference may dangle.
- **CUT set:** skills+principles for `authoring-skills`, `plan-driven-work`, `memory-system`, `handoff`, `saturday-ritual`; the `init` skill; the tool-copy-authoring half of the generators.
- **DEFER set (move, do not delete):** the `data` and `ai-workflow` domains → `deferred/`.
- **Do not touch dated historical docs** under `docs/` (smoke tests, vision, showcase) — they are records of past state. Reference fixes apply only to live surfaces: `README.md`, `principles/`, `skills/`, `agents/`, the manifests.

---

## Phase 1 — Cut the box-duplicates

Removes the five skills that duplicate superpowers/built-ins, plus `init`. Lowest risk, biggest immediate honesty gain. Repo stays installable throughout.

### Task 1: Remove the five duplicate skills + `init` and their principles

**Files:**
- Delete: `skills/authoring-skills/`, `skills/plan-driven-work/`, `skills/memory-system/`, `skills/handoff/`, `skills/saturday-ritual/`, `skills/init/`
- Delete: `principles/authoring-skills.md`, `principles/plan-driven-work.md`, `principles/memory-system.md`, `principles/handoff.md`, `principles/saturday-ritual.md`
- Modify (drop dangling references): `principles/README.md`, `principles/operating-principles.md`, `principles/knowledge-graph.md`, `principles/knowledge-layers.md`, `principles/task-classification.md`, `principles/lean-by-default.md`, `principles/project-identity.md`, `skills/bootstrap/SKILL.md`, `skills/bootstrap/interview.md`, `skills/worktree/SKILL.md`, `README.md`

- [ ] **Step 1: Inventory every live reference before deleting**

Run:
```bash
cd /Users/dima/Documents/Projects/dotclaude
grep -rnE "authoring-skills|plan-driven-work|memory-system|handoff|saturday-ritual|dotclaude:init|skills/init" \
  README.md principles/ skills/ agents/ .claude-plugin/ \
  | grep -vE "/(authoring-skills|plan-driven-work|memory-system|handoff|saturday-ritual|init)/"
```
Expected: a finite list of files+lines. Keep it open — each hit is edited in Step 3.

- [ ] **Step 2: Delete the skill and principle directories/files**

```bash
git rm -r skills/authoring-skills skills/plan-driven-work skills/memory-system skills/handoff skills/saturday-ritual skills/init
git rm principles/authoring-skills.md principles/plan-driven-work.md principles/memory-system.md principles/handoff.md principles/saturday-ritual.md
```

- [ ] **Step 3: Edit each referencing file to drop the reference**

For every hit from Step 1: remove the list item / sentence that names a deleted tool. Where a deleted tool was one item in a roster (e.g. `principles/knowledge-graph.md`, `skills/bootstrap/SKILL.md`'s "process/knowledge skills" list), delete just that item and keep the sentence grammatical. Where a whole paragraph exists only to describe a deleted tool, delete the paragraph. Do not leave "(removed)" placeholders.

- [ ] **Step 4: Verify zero live references remain**

Run:
```bash
grep -rnE "authoring-skills|plan-driven-work|memory-system|handoff|saturday-ritual|dotclaude:init|skills/init" \
  README.md principles/ skills/ agents/ .claude-plugin/ \
  | grep -vE "/(authoring-skills|plan-driven-work|memory-system|handoff|saturday-ritual|init)/"
```
Expected: no output.

- [ ] **Step 5: Verify the plugin still parses and the skill count dropped**

```bash
jq . .claude-plugin/plugin.json .claude-plugin/marketplace.json >/dev/null && echo "JSON OK"
ls skills/ | wc -l   # expect 6 fewer than before (22 → 16)
```
Expected: `JSON OK`, and the reduced count.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor: cut 5 box-duplicate skills + init generator

authoring-skills, plan-driven-work, memory-system, handoff, saturday-ritual
duplicate superpowers/built-ins; init only chained the domain generators.
Drop them and their principles, fix all live references.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Phase 2 — Elicitation → artifact → consumed agent

Transforms the `coding` and `testing` generators from kit-authors into elicitation-only skills that write a thin artifact, and teaches the consumed `code-review` / `test-architect` agents to read it. This is the load-bearing behavioral change.

### Task 2: Define the artifact contract + `dotclaude.yml` schema

**Files:**
- Create: `docs/artifact-contract.md`
- Modify: `skills/bootstrap/SKILL.md` (the `dotclaude.yml` description — add the `artifacts:` block)

**Interfaces:**
- Produces: the artifact path convention `.claude/dotclaude/<domain>.md` and the `dotclaude.yml` `artifacts:` map, consumed by Tasks 3–6.

- [ ] **Step 1: Write the artifact contract doc**

Create `docs/artifact-contract.md` with exactly:

```markdown
# Domain artifact contract

A domain elicitation skill writes ONE thin, human-readable markdown file per
project. The consumed agent reads it at runtime. No agent is generated.

| Domain | Artifact | Written by | Read by |
|---|---|---|---|
| coding | `.claude/dotclaude/code-anti-patterns.md` | coding elicitation | `code-review` agent |
| testing | `.claude/dotclaude/test-risk-model.md` | testing elicitation | `test-architect` agent |
| design | `.claude/dotclaude/design-north-star.md` | design north-star elicitation | `ux-audit`, `flow-audit`, `pages-audit` |

Rules:
- The artifact holds ONLY elicited human intent (bug classes, risk priorities,
  benchmark apps) — never a copy of the agent's methodology.
- Every artifact is optional. Absent → the agent falls back to the generic
  methodology in its `principles/<name>.md`. Present → each entry is a
  project-specific check layered on top of the generic pass.
- `dotclaude.yml` records the path under an `artifacts:` map so the agent can
  locate it without a hardcoded convention.
```

- [ ] **Step 2: Add the `artifacts:` block to the `dotclaude.yml` description in bootstrap**

In `skills/bootstrap/SKILL.md`, in the `dotclaude.yml` bullet, append that `dotclaude.yml` carries an `artifacts:` map, e.g.:

```yaml
artifacts:
  code-anti-patterns: .claude/dotclaude/code-anti-patterns.md
  test-risk-model: .claude/dotclaude/test-risk-model.md
  design-north-star: .claude/dotclaude/design-north-star.md
```

- [ ] **Step 3: Verify**

```bash
test -f docs/artifact-contract.md && echo "contract present"
grep -q "artifacts:" skills/bootstrap/SKILL.md && echo "schema wired"
```
Expected: both echoes.

- [ ] **Step 4: Commit**

```bash
git add docs/artifact-contract.md skills/bootstrap/SKILL.md
git commit -m "feat: domain-artifact contract + dotclaude.yml artifacts map

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

### Task 3: Wire `code-review` agent to read the coding artifact

**Files:**
- Modify: `agents/code-review.md`
- Test: `docs/artifact-contract.md` (reference), a scratch fixture project

**Interfaces:**
- Consumes: `.claude/dotclaude/code-anti-patterns.md` (Task 2 convention).

- [ ] **Step 1: Add the read-and-fallback contract to the agent**

In `agents/code-review.md`, in the section where the agent gathers project context (before it grades), add a block with this exact intent:

```markdown
## Project-specific anti-patterns

Before grading, resolve the coding artifact:
1. Read `dotclaude.yml` `artifacts.code-anti-patterns` if present; else default
   to `.claude/dotclaude/code-anti-patterns.md`.
2. If the file exists, treat each listed bug class as a project-specific check
   and grade against it IN ADDITION to the generic patterns in
   `principles/code-review.md`. Cite the artifact entry a finding maps to.
3. If the file is absent, fall back to the generic patterns only, and note in
   the report that no project anti-pattern artifact was found.
```

- [ ] **Step 2: Verify the contract text is present and names both branches**

```bash
grep -q "code-anti-patterns" agents/code-review.md && \
grep -q "absent" agents/code-review.md && echo "read+fallback wired"
```
Expected: `read+fallback wired`.

- [ ] **Step 3: Manual behavioral checkpoint (fixture)**

Create a scratch fixture with and without the artifact, dispatch the agent, confirm: with artifact → findings cite artifact entries; without → report states fallback. Record the two outputs in the task's review notes. (This is an LLM-behavior check, not an automated test — the reviewer confirms it during the between-task gate.)

- [ ] **Step 4: Commit**

```bash
git add agents/code-review.md
git commit -m "feat: code-review reads project anti-pattern artifact with fallback

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

### Task 4: Shrink the `coding` generator to elicitation-only

**Files:**
- Modify: `skills/coding/SKILL.md`, `skills/coding/interview.md`

- [ ] **Step 1: Rewrite the SKILL to elicit → write artifact, not author a kit**

In `skills/coding/SKILL.md`: keep Phase 1 (project scan) and Phase 2 (interview). Replace the "author a tailored code-review agent / rules / hooks" phases with a single "Phase 3 — Write the artifact" that writes the elicited bug classes to `.claude/dotclaude/code-anti-patterns.md` and sets the file-size ceiling + exemptions in `dotclaude.yml`. Remove every instruction that authors a `code-review.md` agent copy (the consumed agent reads the artifact — Task 3). Keep the C4 voice/forbidden-phrases branch, but have it write the deny-list into `dotclaude.yml`, not author a hook.

- [ ] **Step 2: Trim the interview to what the artifact needs**

In `skills/coding/interview.md`: keep C1 (ceiling), C3 (bug classes — the artifact's content), C4 (voice). Drop C2's "reviewer agent depth/tone shaping" language that assumed a generated agent; if register still matters, record it as a one-line note in the artifact, not as agent-authoring.

- [ ] **Step 3: Verify no agent-authoring remains**

```bash
grep -niE "author.*(agent|reviewer)|generate.*agent" skills/coding/SKILL.md
```
Expected: no output (or only the explicit "do NOT author" guard line).

- [ ] **Step 4: Verify the artifact-writing path is named**

```bash
grep -q "code-anti-patterns.md" skills/coding/SKILL.md && echo "writes artifact"
```
Expected: `writes artifact`.

- [ ] **Step 5: Commit**

```bash
git add skills/coding/
git commit -m "refactor: coding generator becomes elicitation-only

Elicits bug classes → writes .claude/dotclaude/code-anti-patterns.md +
dotclaude.yml ceiling; no longer authors a code-review agent copy.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

### Task 5: Wire `test-architect` to read the testing artifact

**Files:**
- Modify: `agents/test-architect.md`

- [ ] **Step 1: Add the read-and-fallback contract**

In `agents/test-architect.md`, before it builds the risk-weighted priority table, add:

```markdown
## Project risk model

Before auditing, resolve the testing artifact:
1. Read `dotclaude.yml` `artifacts.test-risk-model` if present; else default to
   `.claude/dotclaude/test-risk-model.md`.
2. If present, seed the risk-priority table from it (top entry = the module the
   author named as scariest-if-untested), layered on the generic risk tiers.
3. If absent, derive priorities from runtime signals only (test/source ratio,
   most-edited untested files) and note that no risk-model artifact was found.
```

- [ ] **Step 2: Verify**

```bash
grep -q "test-risk-model" agents/test-architect.md && \
grep -q "absent" agents/test-architect.md && echo "read+fallback wired"
```
Expected: `read+fallback wired`.

- [ ] **Step 3: Commit**

```bash
git add agents/test-architect.md
git commit -m "feat: test-architect reads project risk-model artifact with fallback

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

### Task 6: Shrink the `testing` generator to elicitation-only

**Files:**
- Modify: `skills/testing/SKILL.md`, `skills/testing/interview.md`

- [ ] **Step 1: Rewrite to elicit → write `test-risk-model.md`**

In `skills/testing/SKILL.md`: keep Phase 1 + interview. Replace kit-authoring with "Phase 3 — Write the artifact" that writes the elicited risk priorities to `.claude/dotclaude/test-risk-model.md`. Remove authoring of a `tests-architect` agent copy — the consumed `test-architect` reads the artifact (Task 5).

- [ ] **Step 2: Verify no agent-authoring remains + artifact path named**

```bash
grep -niE "author.*agent|generate.*agent" skills/testing/SKILL.md   # expect none
grep -q "test-risk-model.md" skills/testing/SKILL.md && echo "writes artifact"
```
Expected: no authoring hits; `writes artifact`.

- [ ] **Step 3: Commit**

```bash
git add skills/testing/
git commit -m "refactor: testing generator becomes elicitation-only

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Phase 3 — Physical split into two plugins

Moves files under `plugins/core/` and `plugins/design/`, merges the two flow agents, relocates the product tools, and rewrites the manifests + READMEs. Do this only after Phases 1–2 fixed the membership.

### Task 7: Merge `flow-continuity-review` into `flow-audit`

**Files:**
- Modify: `agents/flow-audit.md`
- Delete: `agents/flow-continuity-review.md`, `principles/flow-continuity-review.md`
- Modify: references in `principles/flow-audit.md`, `principles/audit-routing.md`, `principles/README.md`, `README.md`

- [ ] **Step 1: Fold the pre-captured-series mode into flow-audit**

In `agents/flow-audit.md`, add an "Input modes" section: (a) walk a live flow end-to-end (existing behavior); (b) grade a pre-captured ordered screenshot series with a manifest (the `flow-continuity-review` behavior — continuity across voice drift, CTA-weight progression, loading vocabulary, disclosure pacing, color drift, progress legibility). Both produce the same S/A/B/C/D/F continuity report.

- [ ] **Step 2: Delete the merged agent + principle, fix references**

```bash
git rm agents/flow-continuity-review.md principles/flow-continuity-review.md
grep -rln "flow-continuity-review" README.md principles/ agents/ skills/ .claude-plugin/
```
Edit each hit to point at `flow-audit` (mode b).

- [ ] **Step 3: Verify no dangling reference + agent count**

```bash
grep -rn "flow-continuity-review" README.md principles/ agents/ skills/ .claude-plugin/  # expect none
ls agents/ | wc -l   # one fewer
```
Expected: no output; reduced count.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: merge flow-continuity-review into flow-audit (two input modes)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

### Task 8: Create the two-plugin directory layout and move files

**Files:**
- Create: `plugins/core/`, `plugins/design/`
- Move: agents/skills/principles/hooks/hook-templates into the right plugin

**Interfaces:**
- Produces: the per-plugin roots that `${CLAUDE_PLUGIN_ROOT}` and the manifests (Task 9) resolve against.

- [ ] **Step 1: Create plugin roots**

```bash
mkdir -p plugins/core/agents plugins/core/skills plugins/core/principles plugins/core/hooks plugins/core/hook-templates
mkdir -p plugins/design/agents plugins/design/skills plugins/design/principles
```

- [ ] **Step 2: Move CORE members**

```bash
# CORE agents
git mv agents/code-review.md agents/pre-flight.md agents/test-architect.md \
       agents/skill-vs-code-audit.md agents/product-direction-validator.md plugins/core/agents/
# CORE skills
git mv skills/worktree skills/decomposition skills/coding skills/testing \
       skills/operating-discipline skills/bootstrap plugins/core/skills/
# CORE hooks (active guards) + templates
git mv hooks/* plugins/core/hooks/ && rmdir hooks
git mv hook-templates/* plugins/core/hook-templates/ && rmdir hook-templates
# CORE principles: move the ones owned by CORE tools (see Step 4 for the mapping)
# DEFERRED domains — move straight to deferred/ now so no root dir is orphaned
mkdir -p deferred/skills deferred/agents deferred/principles
git mv skills/data skills/ai-workflow skills/migration-create deferred/skills/
git mv agents/data-integrity.md deferred/agents/
git mv principles/data-integrity.md principles/migration-create.md \
       principles/database-query-discipline.md principles/ai-cost-monitoring.md deferred/principles/
```

(The deferred domains are relocated here as part of the single big move; Task 11 only writes the deferral note and verifies. Their principles go to `deferred/principles/`, never into CORE.)

- [ ] **Step 3: Move DESIGN members**

```bash
# DESIGN agents (6 audits after the merge) + product-designer
git mv agents/ux-audit.md agents/a11y-audit.md agents/interaction-audit.md \
       agents/flow-audit.md agents/pages-audit.md agents/design-token-audit.md \
       agents/product-designer.md plugins/design/agents/
# DESIGN skills
git mv skills/design skills/element-reuse skills/journey-mapping \
       skills/persona-testing skills/iterative-polish-autoloop plugins/design/skills/
```

- [ ] **Step 4: Split `principles/` by owning plugin**

Move each `principles/<name>.md` next to the plugin that owns it. CORE gets: `code-review, pre-flight, test-architect, skill-vs-code-audit, product-direction-validator, worktree-discipline, decomposition, file-discipline, operating-principles, lean-by-default, task-classification, audit-routing, knowledge-graph, knowledge-layers, project-identity, quality-rubric, forbidden-phrases, database-query-discipline, migration-create, data-integrity, ai-cost-monitoring, pre-flight, README, visual-verification` (verification-shared docs stay with CORE). DESIGN gets: `ux-audit, a11y-audit, interaction-audit, flow-audit, pages-audit, design-token-audit, product-designer, design-benchmarking, design-system-reference-skill, element-reuse, journey-mapping, persona-testing`. Run the moves, then in Step 5 re-point every `../../principles/<name>.md` cite that crossed a plugin boundary.

- [ ] **Step 5: Re-point cross-plugin principle references**

```bash
grep -rn "principles/" plugins/core/skills plugins/core/agents plugins/design/skills plugins/design/agents
```
For each cite, confirm the target now lives in the same plugin; fix the relative path if it moved. No cite may cross from one plugin into the other (plugins are independent).

- [ ] **Step 6: Verify structure**

```bash
find plugins -maxdepth 3 -type d | sort
test -z "$(ls agents skills 2>/dev/null)" && echo "root emptied"   # old dirs drained
```
Expected: the two plugin trees; old `agents/`/`skills/` empty or gone.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "refactor: split into plugins/core and plugins/design

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

### Task 9: Rewrite `plugin.json` ×2 and `marketplace.json`

**Files:**
- Create: `plugins/core/.claude-plugin/plugin.json`, `plugins/design/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Delete: `.claude-plugin/plugin.json` (root — replaced by per-plugin manifests)

- [ ] **Step 1: Write the CORE plugin manifest**

`plugins/core/.claude-plugin/plugin.json`:
```json
{
  "name": "dotclaude",
  "description": "A senior who won't let you shoot your own foot: parallel-session worktree isolation, blast-radius pre-flight, guard hooks, graded code review, coverage by risk. Consumed as-is; adapts at runtime; run the coding/testing setup to elicit your bar.",
  "version": "3.0.0",
  "author": { "name": "Dima Vinokurov" },
  "homepage": "https://github.com/vindm/dotclaude",
  "repository": "https://github.com/vindm/dotclaude",
  "license": "MIT"
}
```

- [ ] **Step 2: Write the DESIGN plugin manifest**

`plugins/design/.claude-plugin/plugin.json`:
```json
{
  "name": "dotclaude-design",
  "description": "The AI design/UX auditor nobody else has: elicits what 'good' means for your product (the north-star), then holds every screen to it — ux, flow, pages, a11y, interaction, and design-token audits, plus the product-designer IA/flow spec.",
  "version": "3.0.0",
  "author": { "name": "Dima Vinokurov" },
  "homepage": "https://github.com/vindm/dotclaude",
  "repository": "https://github.com/vindm/dotclaude",
  "license": "MIT"
}
```

- [ ] **Step 3: Rewrite `marketplace.json` to list both plugins**

Set the top-level `description` to the two-plugin framing and replace the `plugins` array with two entries whose `source` is the in-repo path:
```json
"plugins": [
  { "name": "dotclaude",        "source": "./plugins/core",   "version": "3.0.0", "license": "MIT", "homepage": "https://github.com/vindm/dotclaude", "tags": ["ai-dev-infrastructure","worktree","pre-flight","code-review","hooks","testing"] },
  { "name": "dotclaude-design", "source": "./plugins/design", "version": "3.0.0", "license": "MIT", "homepage": "https://github.com/vindm/dotclaude", "tags": ["design","ux-audit","a11y","design-tokens","ia","product-design"] }
]
```
Then `git rm .claude-plugin/plugin.json` (the root single-plugin manifest is superseded).

- [ ] **Step 4: Verify all manifests are valid JSON and names are unique**

```bash
jq . .claude-plugin/marketplace.json plugins/core/.claude-plugin/plugin.json plugins/design/.claude-plugin/plugin.json >/dev/null && echo "JSON OK"
jq -r '.plugins[].name' .claude-plugin/marketplace.json | sort | uniq -d   # expect empty (no dupes)
```
Expected: `JSON OK`; no duplicate names.

- [ ] **Step 5: Verify both plugins load**

```bash
claude --plugin-dir ./plugins/core -p "list the dotclaude agents you can dispatch" 2>&1 | head
claude --plugin-dir ./plugins/design -p "list the dotclaude-design agents you can dispatch" 2>&1 | head
```
Expected: each lists its own agents, no load errors. (If `--plugin-dir` prompts, this is the manual load checkpoint for the review gate.)

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: two-plugin marketplace — dotclaude + dotclaude-design v3

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

### Task 10: Rewrite the READMEs — one promise each

**Files:**
- Modify: `README.md` (repo root — becomes the marketplace overview pointing at both plugins)
- Create: `plugins/core/README.md`, `plugins/design/README.md`

- [ ] **Step 1: Write the CORE plugin README**

`plugins/core/README.md`: the single promise ("a senior who won't let you shoot your own foot"), the install line (`claude plugin install dotclaude@dotclaude`), the consumed tools (worktree, pre-flight, code-review, decomposition, test-architect, guards, operating-discipline), and the elicitation setup (`/dotclaude:coding`, `/dotclaude:testing` write the artifacts the agents read). No design content.

- [ ] **Step 2: Write the DESIGN plugin README**

`plugins/design/README.md`: the single promise ("the AI design/UX auditor nobody else has"), install line (`claude plugin install dotclaude-design@dotclaude`), the north-star elicitation as the headline, then the 6 audits + product-designer.

- [ ] **Step 3: Rewrite the root README as a marketplace overview**

`README.md`: one paragraph on the marketplace, then two cards — "dotclaude (CORE)" and "dotclaude-design" — each linking to its plugin README. Remove the old "14 agents / 13 skills / 6 guards" counts and the single-plugin install framing.

- [ ] **Step 4: Verify no README still advertises cut tools**

```bash
grep -rnE "authoring-skills|plan-driven-work|memory-system|handoff|saturday-ritual|flow-continuity-review|dotclaude:init" README.md plugins/*/README.md
```
Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add README.md plugins/core/README.md plugins/design/README.md
git commit -m "docs: one-promise READMEs per plugin + marketplace overview

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Phase 4 — Defer the data / ai-workflow domains

Parks the two niche domains behind a documented note instead of shipping them first-class or deleting the work.

### Task 11: Write the deferral note for `data` + `ai-workflow`

The relocation to `deferred/` already happened in Task 8. This task documents it and verifies nothing in the shipped plugins references the parked domains.

**Files:**
- Create: `deferred/README.md`

- [ ] **Step 1: Write the deferral note**

`deferred/README.md`: state that `data` (data-integrity + migration-create) and `ai-workflow` (eval-cost-watcher) are unique but niche (DB/AI projects only), parked pending demand, and how to revive one (move it back under `plugins/core/`, add its elicitation artifact to the contract, wire the consumed agent to read it — same pattern as coding/testing).

- [ ] **Step 3: Verify the deferred domains are out of both plugins**

```bash
grep -rlnE "data-integrity|migration-create|ai-workflow|eval-cost" plugins/core plugins/design | grep -vE "deferred/"
```
Expected: no output (nothing in the shipped plugins references the parked domains).

- [ ] **Step 4: Verify manifests still valid**

```bash
jq . .claude-plugin/marketplace.json plugins/core/.claude-plugin/plugin.json plugins/design/.claude-plugin/plugin.json >/dev/null && echo "JSON OK"
```
Expected: `JSON OK`.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: defer data + ai-workflow domains to deferred/ with revival note

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

### Task 12: Final sweep + CHANGELOG

**Files:**
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Add the v3 changelog entry**

Prepend a `## 3.0.0` section summarizing: two-plugin split, elicitation-not-generation, cut duplicates, merged flow agents, deferred data/ai-workflow.

- [ ] **Step 2: Full dangling-reference sweep across shipped surfaces**

```bash
grep -rnE "authoring-skills|plan-driven-work|memory-system|handoff|saturday-ritual|flow-continuity-review|dotclaude:init|skills/init" \
  README.md CHANGELOG.md plugins/ .claude-plugin/ | grep -vE "deferred/|CHANGELOG.md:"
```
Expected: no output.

- [ ] **Step 3: Verify agent + skill counts match the spec**

```bash
echo "core agents:";   ls plugins/core/agents   | wc -l   # 5
echo "design agents:"; ls plugins/design/agents | wc -l   # 7 (6 audits + product-designer)
```
Expected: the spec's counts.

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: changelog for v3 gems curation

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review

**Spec coverage:**
- Two-plugin split → Tasks 8–10. ✓
- Kill tool-copy generation, keep elicitation → Tasks 4, 6. ✓
- Consumed agents read artifact + fallback → Tasks 2, 3, 5. ✓
- Cut box-duplicates + init → Task 1. ✓
- Merge flow agents → Task 7. ✓
- product-direction-validator → CORE → Task 8 Step 2. ✓
- skill-vs-code-audit → CORE → Task 8 Step 2. ✓
- Defer data/ai-workflow → Task 11. ✓
- dotclaude.yml boundary + artifacts map → Task 2. ✓
- One promise per README → Task 10. ✓

**Known soft spots (flagged, not placeholders):**
- Tasks 3/5 behavioral checks are LLM-behavior confirmations at the review gate, not automated tests — inherent to auditing agents.
- Task 9 Step 5 (`--plugin-dir` load) may need a manual/interactive confirmation depending on the Claude Code version's non-interactive support.
- Task 8 Step 4's principle-ownership mapping must be reconciled against the actual `principles/` list at execution time (the list there is the current best inventory).

**Type/name consistency:** artifact paths (`.claude/dotclaude/code-anti-patterns.md`, `test-risk-model.md`, `design-north-star.md`) and the `dotclaude.yml` `artifacts.<key>` names are identical across Tasks 2–6. ✓
