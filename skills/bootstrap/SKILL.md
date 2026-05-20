---
description: Full hierarchical bootstrap of a project's AI dev infrastructure — walks 7 layers from identity to maintenance, authoring CLAUDE.md + docs/ knowledge graph + .claude/ system in one guided session. Reads the project first, interviews per-layer, stages everything for review, then commits. The headline v2 command. Invoke /dotclaude:bootstrap in any project root.
---

# `/dotclaude:bootstrap` — hierarchical project infrastructure setup

You are running the **headline v2 flow**: a hierarchical interview that starts at project identity and walks down through architecture, process discipline, quality bar, knowledge graph, domain kits, and maintenance ritual. Each layer authors a slice of the project's `CLAUDE.md` + `docs/` knowledge graph + `.claude/` system, all derived from project context.

**What makes this different from `/dotclaude:init` (v1):** init runs only Layer 6 (domain kits). Bootstrap is the *meta-framework* command — it adds Layers 1–5 above and Layer 7 below. The v1 contract is preserved (init still works for Layer-6-only invocations); bootstrap supersedes init as the headline.

**The 7 layers**:

| # | Layer | Authors |
|---|---|---|
| 1 | **Project Identity** | `CLAUDE.md` opening section + optional `docs/product/vision.md` |
| 2 | **Architecture** | `CLAUDE.md` "Architecture" + boundary rules + universal hooks |
| 3 | **Process Discipline** | `CLAUDE.md` "How You Work" + DoD + task classification + memory typing |
| 4 | **Quality Bar** | `.claude/rules/<domain>-north-star.md` per domain + quality-bar skill |
| 5 | **Knowledge Graph** | `docs/README.md` + `docs/` skeleton + authority hierarchy |
| 6 | **Domain Kits** | `.claude/{agents,skills,hooks,rules}/*` per applicable domain (delegates to existing v1 skills) |
| 7 | **Maintenance** | Saturday-ritual artifacts (default opt-in stub) |

Layers are dependency-ordered: Layer 1 is read by every later layer. Skipping Layer 1 and asking Layer 4 questions produces generic outputs ("Apple iOS + Telegram" as defaults regardless of whether the project even has a UI). Walk in order.

**Total time**: ~25–40 min for greenfield / ~20–30 min for brownfield in audit-and-fill mode. Each layer is 2–6 questions. The user can skip any layer at any point.

---

## Phase 1 — Project scan (universal reads, before ANY question)

Phase 1 is the most important phase. The richer your read, the less the interview has to extract. Phase 1 reliably auto-discovers ~30–40% of all 7-layer inputs from a brownfield project; ~15–20% from a greenfield.

Run these reads in order. Each maps to one or more downstream layers.

### 1.1 — Top-level project shape

```bash
ls -la
cat README.md 2>/dev/null | head -60
```

Read for: project name, one-paragraph description (if the user wrote one), top-level dirs (`src/` `app/` `lib/` `docs/` `.claude/` `tests/` `migrations/`).

Drives: Layer 1 (vision opening sentence), Layer 2 (architecture top-level shape), Layer 5 (existing `docs/` shape).

### 1.2 — Stack + dependencies

```bash
cat package.json 2>/dev/null | head -80
cat pyproject.toml Cargo.toml go.mod composer.json Gemfile 2>/dev/null | head -40
```

Read for: language, framework, build tools, test framework, lint config, runtime deps that signal architecture (Supabase / Postgres / Stripe / OpenAI / etc.). Read the `scripts` section in `package.json` carefully — this drives Layer 2 dev-loop + Layer 3 verification commands.

Drives: Layer 2 (stack), Layer 3 (verification commands), Layer 6 (applicable domains).

### 1.3 — Existing AI dev infrastructure

```bash
ls -la CLAUDE.md AGENTS.md CONTRIBUTING.md STYLE_GUIDE.md 2>/dev/null
ls -la .claude/ 2>/dev/null
ls -la docs/ 2>/dev/null
```

**Read each found file fully.** This is the brownfield-vs-greenfield decision point.

- **CLAUDE.md exists and (> 200 LOC OR > 5 top-level H2 sections with Identity / Architecture / How You Work all present) AND `.claude/` has > 10 artifacts** → **brownfield comprehensive**. Recommend REFUSE mode (suggest `/dotclaude:audit` or per-layer commands instead — see "Brownfield handling" below). *Rationale: the case-study smoke test (2026-05-21) had a 100-LOC-but-comprehensive CLAUDE.md backed by 74 `.claude/` artifacts; the 200-LOC threshold alone missed it. The OR clause catches founders who write terse but structurally mature docs.*
- **CLAUDE.md exists but < 50 LOC** → **brownfield partial**. APPEND mode (add missing layers without stomping).
- **CLAUDE.md missing, but .claude/ has artifacts** → **brownfield v1-bootstrapped**. APPEND Layers 1–5 + 7; respect existing Layer 6.
- **None of the above** → **greenfield**. Run all 7 layers fresh.

Drives: the operating mode for the entire bootstrap session.

### 1.4 — Git history mining

```bash
git log --oneline -30
git log --format='%an' | sort -u
git log --format='%ai' | tail -1
git log --oneline | wc -l
```

Read for: contributor count (solo vs team — drives Layer 1 + Layer 7), project age (drives Layer 1 maturity tag + Layer 7 applicability), commit cadence (drives Layer 7 cadence default), commit prefix conventions (`feat:` / `fix:` / etc. — drives Layer 3 task classification rows).

Drives: Layer 1 (solo-vs-team + maturity), Layer 7 (cadence + applicability gate), Layer 3 (task patterns).

### 1.5 — Source-file surface

```bash
find . -path ./node_modules -prune -o -path ./.git -prune -o \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.rs" -o -name "*.go" -o -name "*.swift" -o -name "*.kt" \) -print | wc -l
find . -path ./node_modules -prune -o -path ./.git -prune -o -name "*.tsx" -print | head -20
ls components/ src/components/ app/ src/ui/ pages/ routes/ 2>/dev/null
```

Read for: file count (drives Layer 1 maturity tag), language families present, surface count (gates Layer 6 applicability — design only ships if there are UI files).

Drives: Layer 2 (layer model — single-tier vs multi-tier), Layer 6 (which domains apply).

### 1.6 — Test + CI infrastructure

```bash
ls .github/workflows/ scripts/ 2>/dev/null
find . -maxdepth 3 -name "jest.config.*" -o -name "vitest.config.*" -o -name "playwright.config.*" -o -name ".maestro" 2>/dev/null
ls tests/ __tests__/ spec/ 2>/dev/null
```

Drives: Layer 3 (verification ladder — what test commands exist), Layer 6 (testing domain applicability).

### 1.7 — Database + persistent state

```bash
ls migrations/ db/migrations/ supabase/migrations/ prisma/ 2>/dev/null
grep -rE "from ['\"]@supabase|from ['\"]pg|from ['\"]drizzle|from ['\"]prisma" . --include="*.ts" --include="*.tsx" 2>/dev/null | head -5
```

Drives: Layer 6 (data domain applicability), Layer 2 (data tier in architecture if present).

### 1.8 — AI / LLM dependencies

```bash
grep -rE "from ['\"]@anthropic|from ['\"]openai|from ['\"]ai|from ['\"]@ai-sdk" . --include="*.ts" --include="*.tsx" --include="*.py" 2>/dev/null | head -5
```

Drives: Layer 6 (ai-workflow domain applicability).

### 1.9 — Native / mobile signals

```bash
ls ios/ android/ modules/ 2>/dev/null
grep -E "\"expo\":|\"react-native\":" package.json 2>/dev/null
```

Drives: Layer 6 (native-bridge domain applicability), Layer 2 (mobile architecture if present), Layer 4 (iOS/Android benchmark defaults).

### 1.10 — Existing memory directory

```bash
# Memory dir lookup heuristics
ls ~/.claude/projects/ 2>/dev/null | head -20
```

Read for: any existing memory dir for this project. If found, note it — Layer 3 memory system phase doesn't recreate; it audits.

Drives: Layer 3 (memory system — scaffold-from-scratch vs audit-existing).

---

**At end of Phase 1**, write yourself a one-paragraph mental-model summary:

> *Project name: <X>. Stack: <Y>. Existing infra: <CLAUDE.md / docs/ / .claude/ presence + scale>. Maturity signals: <commit count, age, contributor count, file count>. Likely maturity tag: <greenfield / early / shipped / mature>. UI surfaces: <yes/no, count>. Persistent state: <yes/no>. AI calls: <yes/no>. Native modules: <yes/no>. Operating mode this session: <greenfield-fresh | brownfield-append | brownfield-comprehensive-refuse>.*

This is the substrate the interview adapts to. Skip questions whose answer is already in the summary.

---

## Phase 2 — Hierarchical layer walk

Now walk the 7 layers in order. For each layer:

1. Read the upstream principle from `../../principles/` (paths below).
2. Open `interview.md` (same directory). Run the corresponding Phase (A–G).
3. Author the layer's artifact to `.claude-staging/` (NOT directly to project — staging first).
4. Confirm "Layer N staged. Move to Layer N+1?" before proceeding.

The user can interrupt at any layer with "skip layer N" / "I'll do that later" / "go back to layer M." Honor it.

### Layer 1: Project Identity

**Read first**: `../../principles/project-identity.md`. Sections to extract: "Core methodology — six dimensions" + "Authoring guidance — what to write into the final artifact" + "Depth signatures".

**Run**: `interview.md` Phase A (4–6 questions).

**Author** to `.claude-staging/`:

- **`CLAUDE.md.draft`** (create if not exists; append "Identity" section if exists per APPEND mode):
  - One-paragraph product description (from Q-A1).
  - `**ICP (wedge):**` line (Q-A2).
  - `**Production-vs-internal:**` (Q-A3).
  - `**Stage:**` (Q-A5).
  - `**Pace:**` (derived from Q-A3 + Q-A5).
  - `## Moat` section (Q-A6 — bullet list; allow `<MOAT_TBD>` if user can't articulate).
  - `## Anti-vision` section (from off-script signal during Phase A).
- **`docs-staging/product/vision.md`** (~200-400 LOC) — only if maturity ≥ shipped AND user opts in. Skip for greenfield.

**Depth bar**: per `project-identity.md` depth signatures — vision is ONE sentence, ICP is named specifically (industry + size + role minimum), moat names what's NOT-the-moat, anti-vision exists, stage tag matches reality.

**Confirm before moving on**: show the user the drafted CLAUDE.md identity section. Wait for "ship it" or revision request.

### Layer 2: Architecture

**Read first**: skim `../../principles/file-discipline.md` and `../../principles/decomposition.md` for the universal file-size discipline. Also re-read v2-vision.md §2.2 if needed (architecture layer detail).

**Run**: `interview.md` Phase B (3–5 questions).

**Author** to `.claude-staging/`:

- **`CLAUDE.md.draft`** — append "Architecture" section:
  - Layer model (1-tier / 2-tier / N-tier).
  - One-line per layer describing responsibility.
  - Boundary statements ("never X → Y") if multi-tier.
  - Constraints bullets (file-size ceiling, theme tokens, etc.).
  - **Trailing comment in the Constraints block** (load-bearing — included by default):
    ```
    <!-- Add new constraints below as the project grows. Each constraint = one bullet with WHY (the problem it prevents) + WHERE-ENFORCED (hook / rule / manual review). Graduate recurring `feedback_*` memory entries into constraints here when they fire 3+ times. -->
    ```
    This anchor is doing real work: it tells future-Claude (and future contributors) exactly where new constraints accrue, what shape they take, and where they come from (graduated memory). Without the anchor, the Constraints list becomes either calcified ("we set it once 6 months ago, nobody updates it") or sprawled ("constraints showed up in 3 different sections of CLAUDE.md"). The load-bearing constraints accrue from lived incidents, NOT from a single-pass interview; the anchor invites them home.
- **`.claude-staging/rules/file-size.md`** — universal rule (substitute ceiling from interview).
- **`.claude-staging/hooks/check-file-size.sh`** — universal hook (ceiling substituted).
- **`.claude-staging/rules/<boundary>.md`** + **`.claude-staging/hooks/check-<boundary>.sh`** — per declared boundary, if greppable.
- **`docs-staging/architecture/`** subdirectory with `.gitkeep` (placeholder; Layer 5 fills the actual `docs/` tree).

**Depth bar**: at least one constraint backed by a hook, at least one boundary statement (even if single-tier — *"core/ doesn't import from cli/"* applies broadly). The ceiling is project-language-specific (1000 LOC for TS/JS, 500 for Python, 800 for Rust, 600 for Go).

**Confirm before moving on**.

### Layer 3: Process Discipline

**Read first**: `../../principles/plan-driven-work.md` + `../../principles/memory-system.md` + `../../principles/task-classification.md`. These three principles together capture Layer 3's substance.

**Run**: `interview.md` Phase C (4–6 questions).

**Author** to `.claude-staging/`:

- **`CLAUDE.md.draft`** — append "How You Work" section:
  - Behavioral defaults (one or two sentences — "Trace before you propose" / "Plan-driven work: spec ↔ impl conformance mandatory" if applicable).
  - **Task classification table** (per `task-classification.md` template — 5–8 rows minimum; Ambiguous row mandatory). Cell content uses verb-led sequences referencing named specialists.
  - Specialists subsection enumerating domain skills, validation agents, user-invocable skills (placeholder names; Layer 6 fills them).
- **`CLAUDE.md.draft`** — append "Definition of Done" section (8–15 items per `plan-driven-work.md` template).
- **`.claude-staging/rules/plan-driven-work.md`** — only if user opted in to plan-driven discipline.
- **`.claude-staging/rules/visual-verification.md`** — per `../../principles/visual-verification.md`, with project-specific capture command from interview.
- **Memory system scaffold**: a `memory-conventions.md` doc inside `.claude-staging/` describing the typing taxonomy (user / feedback / project / reference) per `memory-system.md`. The actual memory directory is outside the project — bootstrap creates the *conventions doc*, not the directory itself. The user wires up the memory directory after bootstrap.

**Depth bar**: per `task-classification.md` depth signatures — 5+ rows, Ambiguous row exists, verb-led cells, named specialists by file path (even if those file paths are placeholders Layer 6 fills), table is in CLAUDE.md not a sub-file.

**Confirm before moving on**.

### Layer 4: Quality Bar

**Read first**: `../../principles/quality-rubric.md` + `../../principles/design-benchmarking.md`. These define the per-domain quality bar pattern.

**Run**: `interview.md` Phase D (4–6 questions).

**Author** to `.claude-staging/`:

- **`.claude-staging/rules/<domain>-north-star.md`** per applicable domain:
  - **Design**: `design-north-star.md` (Tier 1 + Tier 2 + anti-references + per-surface chrome reference table).
  - **Voice** (if project has voice — usually only for consumer / B2C): `voice-north-star.md`.
  - **API ergonomics** (if library/SDK): `api-north-star.md`.
- **`.claude-staging/skills/quality-bar/SKILL.md`** — per-domain S/A/B/C/D rubric anchored to the named benchmarks. ~80–150 LOC.

**Depth bar**: per `design-benchmarking.md` — every Tier 2 benchmark has its **specific dimension** named (*"Linear for keyboard speed"* not *"Linear is good"*). Anti-references named explicitly. The demo test framing is captured (the single concrete question that grades work).

For projects with no UI / no chrome surface (libraries, pure backend, research prototypes), Layer 4 ships an `api-north-star.md` or skips entirely. The skip is logged with reason in the final summary.

**Confirm before moving on**.

### Layer 5: Knowledge Graph

**Read first**: `../../principles/knowledge-graph.md`. Sections to extract: "Core methodology — the 7-subdirectory taxonomy" + "Authoring guidance — what to write into the final artifact" + "Depth signatures".

**Run**: `interview.md` Phase E (3–5 questions).

**Author** to `.claude-staging/docs-staging/`:

- **`docs-staging/README.md`** — entry point per `knowledge-graph.md` template (~120–200 LOC):
  - Reading order for a newcomer.
  - Authority hierarchy table (≥ 8 question shapes).
  - Maintenance conventions (naming + cross-link + archive policy).
- **Subdirectory skeleton** with `.gitkeep`:
  - `docs-staging/brainstorms/`
  - `docs-staging/specs/` (or `designs/` — match user preference)
  - `docs-staging/plans/`
  - `docs-staging/audits/`
  - `docs-staging/archive/{brainstorms,specs,plans,audits}/`
- **`docs-staging/product/capabilities.md`** — only if user opted in (capability map). Scaffold per `knowledge-graph.md` template even if empty.
- **Optional** (user opt-in per project shape):
  - `docs-staging/flows/` if multi-screen UI arcs exist (Layer 6 design will populate).
  - `docs-staging/design-system/` if non-trivial design system exists.
  - `docs-staging/research/` if competitive research is an activity.
  - `docs-staging/superpowers/{plans,specs}/` if superpowers plan-writing skill is in use.
  - `docs-staging/design-debt/registry.md` — only if Layer 7 is being activated (not deferred-stub).

**Depth bar**: per `knowledge-graph.md` — `docs/README.md` exists with reading order + authority hierarchy + maintenance conventions; naming conventions documented; permanent docs use slug-only filenames + last-verified dates inside; dated docs use `YYYY-MM-DD-<slug>-<type>.md`.

**This is the most CREATE-heavy layer** (entire directory structure + entry-point doc). Take time. The graph is what makes external memory work; rushing it leaves the project without a navigation aid.

**Confirm before moving on**.

### Layer 6: Domain Kits (delegates to existing v1 skills)

**Read first**: `../../principles/audit-routing.md` for the cross-domain pipeline order.

**Run**: `interview.md` Phase F. The applicability matrix is derived from Phase 1 scan; user confirms / overrides.

The 8 canonical domains:

| Domain | Apply if Phase 1 found… | Skip if… |
|---|---|---|
| **design** | UI surfaces (components/, app/, pages/, routes/), theme files | Pure backend / library / dev tool / research prototype with no UI |
| **coding** | Any code at all | (Universal — never skip) |
| **planning** | Multi-module / multi-file changes are common | Single-file utility |
| **testing** | Tests exist OR should exist | Pure exploration / one-off script |
| **data** | Database / persistent state / migrations | Stateless app / pure-compute lib |
| **ai-workflow** | LLM / AI dependencies in `package.json` | No AI in scope |
| **native-bridge** | RN / iOS / Android with native modules (`modules/`, `ios/`, `android/`) | Web-only / pure-RN no native modules |
| **pipeline-integrity** | Multi-stage data pipelines / ETL / generators | No pipelines |

Show the user the applicability matrix BEFORE running anything. Each skip is a deliberate call with a stated reason.

**Author**: for each confirmed-applicable domain, **delegate to the existing v1 domain skill** — read `skills/<domain>/SKILL.md` (sibling directory) and execute its Phase 1–5 sequence. Bootstrap orchestrates; domain skills do the actual authoring.

**Bootstrap's contribution to Layer 6**: pre-load each domain skill with Layers 1–5 context. Specifically:

- Pass Layer 1 identity (vision / ICP / stage) so domain Phase 1 (project scan) doesn't re-derive.
- Pass Layer 2 architecture (layer model / constraints) so domain skills respect boundaries.
- Pass Layer 3 task classification (which task types apply) so domain skills slot into the routing matrix.
- Pass Layer 4 quality bar (benchmarks) so domain auditors anchor to the named references rather than re-asking.
- Pass Layer 5 doc paths so domain skills land docs at the canonical paths (audits → `docs/audits/`, specs → `docs/specs/`).

Without this pre-loading, each domain skill re-derives upstream context — wasteful, inconsistent across domains. With it, the domain skills focus on their specific knob set.

**Each domain interview**: 3–6 questions, ~5–10 min. The `/dotclaude:design` skill is the deepest (~17 questions, 53 knobs). Others are smaller. Cumulative time across 3–5 applied domains: ~20–30 min.

**Wall-clock for ≥6-domain projects.** When the applicability matrix lights up ≥ 6 domains (typical for mature multi-tier projects: design + coding + planning + testing + data + ai-workflow + maybe native-bridge + pipeline-integrity), total bootstrap wall-clock extends to **~90–110 min** (vs ~25–45 min for typical 1–5 domain projects). Surface this estimate to the user during Phase F applicability confirmation; offer to **defer Layer 6 to per-domain invocation across multiple sessions** (e.g. run `/dotclaude:design` today, `/dotclaude:data` tomorrow) rather than barreling through in one sitting. The user can also accept the long run if they have a 2-hour block. Either is fine; what's not fine is silently committing them to 90 min when they expected 30.

**Cross-domain consistency**: `forbidden-phrases.txt` ships under design (voice) AND coding (AI slop). Bootstrap merges them at the end of Layer 6 rather than the v1 "last domain wins" approach — see Phase 3 below.

**Confirm before moving on**: show the per-domain inventory after each domain completes.

### Layer 7: Maintenance

**Read first**: `../../principles/saturday-ritual.md`. Sections to extract: "When to ship one" + "Core methodology — the four properties" + "Authoring guidance".

**Run**: `interview.md` Phase G (1–2 questions). This phase is OPTIONAL and default-deferred.

**Decision logic**:

- **Project < 1 month old AND solo + small** → **defer-and-scaffold-stub**. Author `.claude-staging/_deferred/maintenance-ritual.md` (opt-in stub). Add a TODO comment in CLAUDE.md.
- **Project 1–3 months OR multi-contributor** → **ask the user**. Default propose deferred-stub unless user opts in.
- **Project > 3 months AND has accumulated drift** (skill files old, design-debt registry has > 5 findings if registry exists) → **ship active**. Author full Layer 7 artifacts.

**Author** to `.claude-staging/`:

If active:
- **`.claude-staging/rules/maintenance-ritual.md`** per `saturday-ritual.md` template (~80–150 LOC).
- **`.claude-staging/agents/skill-auditor.md`** — monthly agent that audits skills vs code.
- **`.claude-staging/skills/audit-rituals/SKILL.md`** — user-invocable weekly batch (`/dotclaude:audit-week`).
- **`docs-staging/design-debt/registry.md`** — canonical open-findings registry scaffold.

If deferred-stub:
- **`.claude-staging/_deferred/maintenance-ritual.md`** — the opt-in stub with activation triggers documented.
- **`CLAUDE.md.draft`** — append "Deferred work" section listing Layer 7 + the 2-month / 5-finding reminder.

**Depth bar**: per `saturday-ritual.md` — bounded time (30 min default), batch decision interface (F/D/?/X), hooks-first discipline, registry-as-canonical-source. Skip layer entirely if project is throwaway / 1-week sprint / pure research notebook.

**Confirm before moving on**.

---

## Phase 3 — Cross-layer coordination + composition

After all 7 layers run, before staging:

### 3.1 — Aggregate `forbidden-phrases.txt`

Layer 4 (voice) + Layer 6 (design + coding) may all propose entries. Merge into one file at `.claude-staging/rules/forbidden-phrases.txt`. Sections:

```
# Universal AI-slop phrases (Layer 6 coding)
# ...

# Project voice anti-references (Layer 4 voice north-star)
# ...

# Brand-specific forbidden phrases (Layer 6 design)
# ...
```

Surface the merged file to the user:

> *Both Layer 4 (voice) and Layer 6 (design + coding) proposed forbidden phrases. Merged into one file at `.claude-staging/rules/forbidden-phrases.txt` — N total entries across 3 sections. The hook fires on all of them.*

### 3.2 — Merge audit-routing.md

Layer 4 (cross-rubric translation) + Layer 6 (per-domain audit pipelines) both touch the audit-routing rule. Author one merged `.claude-staging/rules/audit-routing.md` containing:

- The canonical pipeline order (per Layer 4 quality-bar logic).
- The which-agent-for-which-question routing table (per Layer 6 design + coding contributions).
- Cross-rubric translation (S/A/B/C/D ↔ Crit/High/Med/Low ↔ S0/S1/S2 ↔ composite grade).
- Hooks-prevent-classes-of-finding section.

### 3.3 — Reconcile CLAUDE.md sections

The `CLAUDE.md.draft` accumulated additions from Layers 1, 2, 3, and (deferred) 7. Final structure:

```
# <Project Name>

<Identity paragraph + ICP + production-vs-internal + stage + pace>          (Layer 1)

## Moat                                                                      (Layer 1)
## Anti-vision                                                               (Layer 1)

## Architecture                                                              (Layer 2)
### Boundaries
### Constraints

## How You Work                                                              (Layer 3)
### Task classification
### Specialists

## Where to find what                                                        (Layer 5)

## Definition of Done                                                        (Layer 3)

## Deferred work (optional)                                                  (Layer 7 if deferred)
```

Read the assembled `CLAUDE.md.draft` end-to-end. Check:

- Total LOC reasonable (~300–600 LOC).
- No section duplicates another (e.g. constraints in Architecture vs Constraints listed in How-You-Work).
- Cross-references resolve (`See docs/audits/...` paths exist in the staged docs/ tree).
- All named specialists in the task classification table exist as files in `.claude-staging/{agents,skills}/`.

### 3.4 — Surface conflicts

If two layers disagree (e.g. Layer 1 says "production" but Layer 4 says "internal-only quality bar"), surface the conflict to the user:

> *Layer 1 said `production`, but Layer 4 quality bar is set for `internal-only` (relaxed visual standard). These are inconsistent. Which is the project — production or internal?*

Resolve, then re-stage the affected artifacts.

---

## Phase 4 — Stage → review → commit

All authored content lives in `.claude-staging/` + `docs-staging/` + `CLAUDE.md.draft` first. Move to project only after explicit user approval.

### 4.1 — Inventory presentation

Show the user the full staged inventory:

```
## CLAUDE.md sections drafted
<list with LOC count>

## docs/ skeleton
<list>

## .claude/ artifacts
- agents:  <list — N total>
- skills:  <list — N total>
- rules:   <list — N total>
- hooks:   <list — N total>

## By layer
Layer 1 (Identity):       <subset>
Layer 2 (Architecture):   <subset>
Layer 3 (Process):        <subset>
Layer 4 (Quality Bar):    <subset>
Layer 5 (Knowledge Graph):<subset>
Layer 6 (Domain Kits):    <subset by domain>
Layer 7 (Maintenance):    <subset or "deferred-stub">

## Skipped (with reasons)
<list>

## Cross-layer merges
<list — e.g. "forbidden-phrases.txt merged from 3 layers">
```

### 4.2 — Walk through 3-5 distinctive elements

Don't dump the full inventory and ask for approval. Walk through 3-5 highlight artifacts and explain reasoning concretely:

- "I drafted your CLAUDE.md identity with `<wedge ICP from interview>` and `<moat from interview>` — the latter intentionally leaves `<NOT-the-moat>` as a callout per the depth bar."
- "Your task classification table has 6 rows including Ambiguous. The UI feature row routes through `product-designer` agent (Layer 6 design authored it); the Plan-backed row references `docs/audits/<plan-slug>-conformance.md` per the conformance-matrix discipline."
- "Your `design-north-star.md` anchors S-tier on Linear + Stripe + Things 3 (your Tier 1 + Tier 2 picks). The anti-references section explicitly names Bootstrap-aesthetic + Notion-density + gamified-childish per your interview."
- "Layer 7 maintenance is deferred-stub. The artifact exists at `.claude/_deferred/maintenance-ritual.md`; CLAUDE.md has a TODO reminding you in 2 months. Activation trigger: > 5 open findings in registry OR > 60 days of uncommitted skill changes."

### 4.3 — Explicit approval gate

Wait for explicit user approval. Acceptable signals: *"ship it"* / *"looks good"* / *"yes commit"*. Do NOT proceed on implicit signals (silence, "ok", emoji thumbs-up). The approval gate is binding.

### 4.4 — Commit moves

On approval:

```bash
# Move staged content to project root
mv .claude-staging/* .claude/        # creates .claude/ if not exists
mv docs-staging/* docs/              # merges with existing docs/ if present (APPEND mode)
mv CLAUDE.md.draft CLAUDE.md         # or merges into existing CLAUDE.md per APPEND mode
```

**APPEND mode special handling**: if `CLAUDE.md` exists, do NOT overwrite. Diff the existing file against the drafted sections and propose section-by-section additions:

> *Your existing CLAUDE.md has Identity + Architecture but no "How You Work" or "Definition of Done." I'm proposing to insert these sections after Architecture. Show the diff?*

The user accepts/rejects per section.

### 4.5 — Commit message

```
feat(.claude): bootstrap — 7-layer hierarchical infrastructure

Authored via /dotclaude:bootstrap:
- CLAUDE.md (~<LOC> LOC) — identity + architecture + how-you-work + DoD + where-to-find-what
- docs/ skeleton — <list of subdirs>
- .claude/agents/ — <list>
- .claude/skills/  — <list>
- .claude/rules/   — <list>
- .claude/hooks/   — <list>

Tier 1 chrome benchmarks: <list>
Tier 2 domain benchmarks: <list>
Layer 6 domains applied: <list>
Layer 6 domains skipped: <list with reasons>
Layer 7: <active | deferred-stub | skipped — reason>
```

---

## Phase 5 — Output summary

After commit, output the structured summary:

```
✓ /dotclaude:bootstrap complete

Project shape detected:
  Stack: <X>
  Maturity: <greenfield | early | shipped | mature>
  Mode: <greenfield-fresh | brownfield-append | brownfield-partial>

Layers authored: <list>
Layers skipped: <list with one-line reasons>

In CLAUDE.md (<LOC> LOC):
  Sections: <list>

In docs/:
  <tree structure>

In .claude/:
  N agents:  <list>
  N skills:  <list>
  N rules:   <list>
  N hooks:   <list>

Layer 6 domain kits ran:
  <domain>: <agent count> agents + <skill count> skills + <hook count> hooks
  ...

Recommended next steps:
  1. <e.g. "Fill in your first capability in docs/product/capabilities.md (currently empty scaffold)">
  2. <e.g. "Run /dotclaude:design when shipping your first UI feature — the agents are wired but their bodies are ready for project-specific anti-patterns from your first commits">
  3. <e.g. "Re-run /dotclaude:bootstrap with --layer 7 in 2 months to activate maintenance ritual when the registry passes 5 findings">
  4. <e.g. "Wire up cross-conversation memory directory per .claude/memory-conventions.md — bootstrap created the conventions doc but not the dir itself">

Commit the staged .claude/ + docs/ + CLAUDE.md when ready.
```

---

## Brownfield handling (CRITICAL)

The §1.3 scan determines the operating mode. Three modes; bootstrap behaves differently in each.

### Mode A: APPEND (default for brownfield-partial)

**Triggered when**: existing `CLAUDE.md` < 50 LOC OR `.claude/` has < 5 artifacts OR `docs/` has 1–3 docs only.

**Behavior**: bootstrap detects existing structure, identifies missing layers, runs ONLY those layers. Does not stomp existing content.

- If `CLAUDE.md` has Identity but no Architecture → skip Layer 1, run Layer 2+.
- If `docs/` exists but no `docs/README.md` → run Layer 5's `docs/README.md` authoring only.
- If `.claude/agents/` has 3 agents but no `code-reviewer` → Layer 6 coding runs and adds the missing agent.

Final CLAUDE.md merge is section-by-section diff with user approval per section.

### Mode B: REFUSE + recommend per-layer (default for brownfield-comprehensive)

**Triggered when**: existing `CLAUDE.md` > 200 LOC AND structured (has Identity + Architecture + How-You-Work or equivalents) AND `.claude/` has > 10 artifacts.

**Behavior**: bootstrap refuses to run end-to-end. The project already has a substantial AI-dev infrastructure; running bootstrap risks stomping load-bearing content.

Recommend instead:

> *Your project has a substantial CLAUDE.md (XYZ LOC, all sections present) and ~N .claude/ artifacts. Running bootstrap end-to-end risks overwriting load-bearing content.*
>
> *Recommend instead one of:*
> *- `/dotclaude:audit` (audit-only mode) — read your existing infra, produce a gap report, no writes.*
> *- Per-layer commands (`/dotclaude:identity` / `/dotclaude:architecture` / `/dotclaude:process` / `/dotclaude:quality-bar` / `/dotclaude:knowledge-graph` / `/dotclaude:maintenance`) — surgically address one layer at a time.*
> *- `/dotclaude:design` (or `/dotclaude:coding` etc.) — re-run a Layer 6 domain skill in update mode.*
>
> *If you really want to run bootstrap in fresh-overwrite mode (DESTRUCTIVE — re-authors all 7 layers from scratch), say "bootstrap fresh-overwrite" and confirm twice.*

REFUSE mode is not silent. The recommendation IS the value-add.

### Mode C: FRESH (default for greenfield)

**Triggered when**: no existing `CLAUDE.md` AND no `.claude/` AND no substantial `docs/` (< 3 docs).

**Behavior**: full 7-layer walk. Author all layers fresh. The §5 walkthrough in `docs/v2-vision.md` is this mode's reference.

### Mode detection edge cases

- **`AGENTS.md` exists but not `CLAUDE.md`**: treat as partial brownfield. Read AGENTS.md fully; propose migrating its content into CLAUDE.md's Identity + How-You-Work sections.
- **`docs/` exists but no `docs/README.md` AND no naming convention**: APPEND mode for Layer 5 (author the README + propose subdirectory reorganization to the user).
- **`.claude/` exists from a different plugin** (e.g. installed via another tool): respect existing artifacts. APPEND only what's missing per layer.

---

## Non-negotiable rules for this flow

1. **Project scan first, always.** Phase 1 reads happen before ANY question. A question whose answer is obvious from Phase 1's reads is a wasted question.

2. **Never stomp existing content.** Brownfield detection in Phase 1 §1.3 is binding. Mode B (REFUSE) and Mode A (APPEND) are not optional — they protect user investment.

3. **Stage before commit.** All authored content lives in `.claude-staging/` + `docs-staging/` + `CLAUDE.md.draft` first. Move to project root only after explicit user approval per §4.3.

4. **Explain reasoning per layer.** Each layer's authoring decisions cite the interview answers + Phase 1 findings. "I authored `<X>` because you said `<Y>` in Q-A2" is the explanation shape. Generic "I added a quality bar" is not.

5. **Each layer waits for confirmation.** The user can stop at any layer. Honor "skip layer 5" / "go back to layer 2" requests. Don't barrel through.

6. **Phase 1 mental-model summary before any question.** Without it, you ask redundant questions and signal "I didn't read your code."

7. **Cross-layer coordination is bootstrap's job, not the layer skills'.** Layer skills author independently; Phase 3 reconciles. Don't push reconciliation into the individual layer skills.

8. **The Ambiguous row in task classification is mandatory.** Per `task-classification.md` depth signatures. Without it, sessions silently scope-decide on ambiguous requests.

9. **Layer 7 defaults to deferred-stub for greenfield + early projects.** Per `saturday-ritual.md` applicability gate. Activation needs an actual reason (project age + drift signals).

10. **Anonymization carry-through.** The plugin's own anonymization guard runs on this repo; the artifacts authored in the user's `.claude/` are project-content, user-owned. Do not leak between project boundaries (don't paste another user's specifics into this user's `.claude/`).

11. **Skill v1 contract is preserved.** `/dotclaude:init`, `/dotclaude:design`, `/dotclaude:coding`, etc. all continue to work standalone. Bootstrap orchestrates them; it doesn't replace them.

12. **Show, don't tell, in §4.2.** When walking through the staged output, point at specific lines in specific files. "Your `CLAUDE.md.draft` line 23–41 is the identity section; the moat bullet on line 38 names `<X>` per your Q-A6." This is the difference between "we authored a kit" and "here's what we authored, and why."

---

## Quick-reference: principle → layer → artifact map

| Principle | Layer | Authored artifact (location in `.claude-staging/`) |
|---|---|---|
| `project-identity.md` | 1 | `CLAUDE.md.draft` Identity + `docs-staging/product/vision.md` (optional) |
| `file-discipline.md` + `decomposition.md` | 2 | `CLAUDE.md.draft` Architecture + `rules/file-size.md` + `hooks/check-file-size.sh` |
| `task-classification.md` + `plan-driven-work.md` + `memory-system.md` | 3 | `CLAUDE.md.draft` How You Work + DoD + `rules/plan-driven-work.md` + `rules/visual-verification.md` + `memory-conventions.md` |
| `quality-rubric.md` + `design-benchmarking.md` | 4 | `rules/<domain>-north-star.md` per domain + `skills/quality-bar/SKILL.md` |
| `knowledge-graph.md` | 5 | `docs-staging/README.md` + `docs-staging/` subdirectory skeleton + `docs-staging/product/capabilities.md` (optional) |
| `audit-routing.md` + each domain's principle | 6 | Delegated to `skills/<domain>/SKILL.md` v1 |
| `saturday-ritual.md` | 7 | `rules/maintenance-ritual.md` + `agents/skill-auditor.md` + `skills/audit-rituals/SKILL.md` + `docs-staging/design-debt/registry.md` — OR `_deferred/maintenance-ritual.md` stub |

---

## See also

- `interview.md` (same directory) — the hierarchical interview script Phase A–G.
- `../init/SKILL.md` — v1 meta-orchestrator (Layer 6 only). Bootstrap supersedes init as headline; init remains as lightweight Layer-6-only entry path.
- `../design/SKILL.md` — Layer 6 design kit (deepest domain — ~17-question interview, 53 knobs).
- `../coding/SKILL.md`, `../planning/SKILL.md`, `../testing/SKILL.md`, `../data/SKILL.md`, `../ai-workflow/SKILL.md` — other Layer 6 domain skills.
- `../../docs/v2-vision.md` — the foundational design doc for v2. §2 defines the 7-layer hierarchy; §5 walks the bootstrap flow with quoted exchanges; §8 details the Stage 3 implementation plan this skill executes.
- `../../principles/` — the 35 principle docs. Each layer's authoring reads selectively per the principle → layer → artifact map above.
