# Design Plugin Consume-Direct Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make `/dotclaude:design` elicitation-only — stop generating project-local agent copies; write two consumed-read artifacts (north-star + design-system digest); keep the audits on loose runtime discovery.

**Architecture:** Mirror the coding/testing consume-direct pattern for design, but keep loose discovery (not the `dotclaude.yml` artifacts map) and two artifacts (design is richer). The 7 design audits are consumed as-is and already self-adapt; the skill's job shrinks to elicit → write two artifacts.

**Tech Stack:** Claude Code plugin (markdown), `grep`/`jq` verification, no code test suite.

## Global Constraints

- **Spec:** `docs/superpowers/specs/2026-07-20-design-consume-direct-design.md` — the authority.
- **Two artifacts, at `.claude/rules/`:** `design-north-star.md` (benchmarks + per-surface chrome table + voice/`BRAND_BANNED_PHRASES` + git-mined design bugs) and `design-system.md` (11-section digest: tokens/primitives/motion/status/gotchas).
- **Loose discovery, NOT the `dotclaude.yml` artifacts map.** Audits find the artifacts by runtime search.
- **Consumed, not generated:** the design skill must NOT author any `.claude-staging/agents/*` copy. The 7 audits are used as-is from the plugin.
- **Keep:** the `check-design-tokens.sh` hook wiring (project config). Drop: authoring `audit-routing.md` / `visual-verification.md` rules (consumed principles now).
- **Counts unchanged:** design 7 agents / 5 skills.
- **Preserve elicitation depth** for the two artifacts (benchmarks, voice, design-system vocabulary, past design bugs) — this is the design product's value; do not gut it.
- Commit each task; do not touch `docs/` historical files or `deferred/`.

---

## Task 1: Rewrite the design skill Phase 4 — kit-authoring → two-artifact write

**Files:**
- Modify: `plugins/design/skills/design/SKILL.md`

- [ ] **Step 1: Replace Phase 4 "Author the kit" with "Write the artifacts"**

Rewrite Phase 4 so it authors exactly two files:
- `.claude/rules/design-north-star.md` — keep the existing rich content spec (Tier 1/Tier 2 benchmarks, per-surface chrome-reference table, Voice / banned phrases from Q-C4, project-specific anti-patterns mined from git).
- `.claude/rules/design-system.md` — the eleven-section design-system digest (previously authored as `design-system/SKILL.md`); it is now a reference doc the consumed UI audits read, not a project skill.

Remove entirely: the "Agents (in `.claude-staging/agents/`)" subsection that authors `ux-reviewer`, `a11y-audit`, `interaction-audit`, `flow-auditor`, `pages-audit`, `product-designer`, `design-token-auditor` copies. Add an explicit guard line: "Do NOT author any agent copy — the 7 design audits are consumed as-is from the plugin and self-adapt at runtime." Remove authoring of `audit-routing.md` and `visual-verification.md` rules (consumed principles). Keep the `check-design-tokens.sh` hook wiring subsection.

- [ ] **Step 2: Update the skill's frontmatter description + intro**

Frontmatter `description:` → "Elicit the project's design north-star + design-system reference (the two artifacts the consumed design audits read at runtime); no agent copies are authored." Update the intro/overview lines that call this a "kit" generator to describe the two-artifact elicitation. Fix the Phase 5 "Approve → commit" message's `Authored:` list to name only the two rules + the hook, not agents/skills.

- [ ] **Step 3: Update the Depth checklist + LOC-target lines**

The "Depth checklist (MANDATORY per authored agent)" and the LOC-targets section reference authored agents. Rescope them to the two artifacts (north-star + design-system digest) — the depth signals (cite real paths, name THEIR benchmarks, THEIR git bugs) still apply to the artifacts. Drop per-agent-only checklist items.

- [ ] **Step 4: Verify**

```bash
cd /Users/dima/Documents/Projects/dotclaude
grep -niE "\.claude-staging/agents|author.*(ux-reviewer|flow-auditor|design-token-auditor|agent copy)" plugins/design/skills/design/SKILL.md   # expect none, or only "do NOT author" guards
grep -q "design-north-star.md" plugins/design/skills/design/SKILL.md && grep -q "design-system.md" plugins/design/skills/design/SKILL.md && echo "writes both artifacts"
```
Expected: no agent-authoring; `writes both artifacts`.

- [ ] **Step 5: Commit**

```bash
git add plugins/design/skills/design/SKILL.md
git commit -m "refactor: design skill authors two artifacts, not agent copies

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Shrink the interview to the two artifacts' inputs

**Files:**
- Modify: `plugins/design/skills/design/interview.md`

- [ ] **Step 1: Keep the artifact-feeding phases, drop agent-tuning knobs**

Keep at full depth the phases that feed the two artifacts: Phase B (benchmarks → north-star), Phase C (voice/banned-phrases → north-star), Phase D (surfaces/arcs → north-star per-surface refs), the git-mining phase (past design bugs → north-star), and the design-system vocabulary knobs (tokens/primitives/motion/status → design-system digest). Remove or fold knobs whose only purpose was tuning a generated agent's internals (per-agent depth/scope/tool-surface settings). Update the intro line's knob count to reflect the reduced set. Fix any question whose closing text says "the authored agents" — retarget to "the two artifacts."

- [ ] **Step 2: Verify no dangling agent-authoring references**

```bash
grep -niE "authored agent|the kit|agent body|tool surface" plugins/design/skills/design/interview.md
```
Review each hit; retarget or remove references to generated agents. Expected after fixes: no reference implies an agent is authored.

- [ ] **Step 3: Commit**

```bash
git add plugins/design/skills/design/interview.md
git commit -m "refactor: design interview drops agent-tuning knobs, keeps artifact inputs

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Wire the consumed audits to discover the design-system digest

**Files:**
- Modify: `plugins/design/agents/ux-audit.md`, `a11y-audit.md`, `interaction-audit.md`, `flow-audit.md`, `pages-audit.md`, `design-token-audit.md`, `product-designer.md`

- [ ] **Step 1: Add the design-system digest to each audit's runtime-discovery list**

Each audit already has a "Discover THIS project at runtime" section that reads the north-star. Add one line to that section: read the project's **design-system reference doc** (`.claude/rules/design-system.md` or an equivalent the project ships) if present — the token/primitive/motion/status vocabulary — falling back to reading the real theme/token source directly when absent. Keep it consistent with each audit's existing voice. Do NOT introduce the `dotclaude.yml` artifacts map — loose discovery only. For `design-token-audit` and `a11y-audit` (which already read the real theme file), frame the digest as a faster first stop, not a replacement.

- [ ] **Step 2: Verify**

```bash
cd /Users/dima/Documents/Projects/dotclaude
for a in ux-audit a11y-audit interaction-audit flow-audit pages-audit design-token-audit product-designer; do
  grep -qi "design-system" "plugins/design/agents/$a.md" && echo "$a: ok" || echo "$a: MISSING digest discovery"
done
grep -rn "dotclaude.yml\|artifacts\." plugins/design/agents/   # expect empty (no artifacts-map)
```
Expected: all 7 "ok"; no artifacts-map references.

- [ ] **Step 2b: Confirm plugin still loads**

```bash
claude --plugin-dir ./plugins/design -p "list your agents" </dev/null 2>&1 | head
```
Expected: lists the 7 design agents, no load errors. (If non-interactive load is unavailable, note it — this is the review-gate manual check.)

- [ ] **Step 3: Commit**

```bash
git add plugins/design/agents/
git commit -m "feat: design audits discover the design-system digest at runtime (loose)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Reconcile the contract, bootstrap, and README

**Files:**
- Modify: `plugins/core/docs/artifact-contract.md`, `plugins/core/skills/bootstrap/SKILL.md`, `plugins/design/README.md`

- [ ] **Step 1: Make the artifact-contract design row honest**

In `plugins/core/docs/artifact-contract.md`, replace the design row so it states: design writes two artifacts — `.claude/rules/design-north-star.md` and `.claude/rules/design-system.md` — read by the consumed design audits via **runtime discovery** (explicitly NOT the `dotclaude.yml` artifacts map). Keep the coding/testing rows (which DO use the map) unchanged. If the table structure can't express "two files + discovery," add a short note under the table for design.

- [ ] **Step 2: Stop bootstrap authoring the design north-star**

In `plugins/core/skills/bootstrap/SKILL.md`, the Quality-bar phase authors a `<domain>-north-star.md`. Reword so bootstrap does NOT author the design north-star (that is the `dotclaude-design` plugin's `/dotclaude:design` job); bootstrap's quality-bar step points the user at the companion `dotclaude-design` plugin for design benchmarking. Keep bootstrap authoring a non-design quality bar (e.g. `api-north-star.md`) where relevant. Remove any remaining `design-north-star` mention that implies core authors it.

- [ ] **Step 3: Align the design README**

In `plugins/design/README.md`, ensure the "start here" section describes the setup as eliciting the two artifacts (north-star + design-system reference) that the consumed audits read — not authoring agents. The "voice and banned phrases" line stays accurate (folded into the north-star). If it names a path, use `.claude/rules/`.

- [ ] **Step 4: Verify**

```bash
cd /Users/dima/Documents/Projects/dotclaude
grep -n "dotclaude/design-north-star\|artifacts.design" plugins/   # expect empty (no fiction path / no map for design)
grep -ni "design-north-star\|design-system" plugins/core/docs/artifact-contract.md
jq . .claude-plugin/marketplace.json plugins/core/.claude-plugin/plugin.json plugins/design/.claude-plugin/plugin.json >/dev/null && echo "JSON OK"
```
Expected: no fiction path / design-in-map; the contract mentions both design artifacts + discovery; JSON OK.

- [ ] **Step 5: Commit**

```bash
git add plugins/core/docs/artifact-contract.md plugins/core/skills/bootstrap/SKILL.md plugins/design/README.md
git commit -m "docs: reconcile contract + bootstrap + README with design consume-direct

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review

**Spec coverage:**
- Phase 4 kit → two-artifact write → Task 1. ✓
- Interview shrink, depth preserved → Task 2. ✓
- Audits discover the digest (loose) → Task 3. ✓
- Contract/bootstrap/README reconciliation → Task 4. ✓
- No agent copies authored; counts unchanged → Task 1 + Task 3 verification. ✓

**Known soft spots (flagged):**
- Task 2's "which knobs only tuned generated agents" needs judgment against the actual interview.md at execution — the plan names the artifact-feeding phases to keep; everything agent-internal-only goes.
- Task 3's `--plugin-dir` load may need the review-gate manual check if non-interactive load isn't available.

**Type/name consistency:** artifact paths `.claude/rules/design-north-star.md` and `.claude/rules/design-system.md` are identical across Tasks 1–4. ✓
