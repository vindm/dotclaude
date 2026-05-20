<div align="center">

<img src="./assets/logo.svg" width="560" alt="dotclaude">

<br>

**AI dev infrastructure framework for any Claude Code project.**

dotclaude walks you through 7 layers — project identity → architecture → process →
quality bar → knowledge graph → domain kits → maintenance — and authors
CLAUDE.md + docs/ + .claude/ derived from your project.

Not templates. Not a kit. A **methodology**.

<br>

<img src="./demo/demo.gif" width="900" alt="/dotclaude:design — Layer 6 design kit running on a Vite + React project, authoring 8 artifacts in ~15 seconds">

<br>

[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-cc785c?style=for-the-badge)](https://docs.anthropic.com/claude-code/plugins)
[![License](https://img.shields.io/badge/license-MIT-cc785c?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.1.0-cc785c?style=for-the-badge)](#)

</div>

<br>

```bash
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude
```

Then in any project root:

| Command | What it does |
|---|---|
| 🪄 `/dotclaude:bootstrap` | **Headline.** Full 7-layer hierarchical interview. Authors CLAUDE.md + docs/ + .claude/. |
| 🎨 `/dotclaude:design` | **Showpiece.** Set up design / UX / IA / a11y / visual audit kit (Layer 6 standalone). |
| 🧹 `/dotclaude:coding` | Layer 6: file-size discipline, code review, voice / forbidden phrases. |
| 📐 `/dotclaude:planning` | Layer 6: pre-impl validation, audit routing. |
| 🧪 `/dotclaude:testing` | Layer 6: test architecture + coverage strategy. |
| 🗃️ `/dotclaude:data` | Layer 6: DB integrity, query discipline, migrations. |
| 🤖 `/dotclaude:ai-workflow` | Layer 6: LLM cost monitoring + eval discipline. |
| 🪄 `/dotclaude:init` | v1 entry — Layer 6 only (no upstream layers). Use for incremental setup. |

<br>

## The 7-layer hierarchy

Every Claude Code project benefits from a layered AI dev infrastructure stack. dotclaude organizes that stack into seven dependency-ordered layers. Each layer authors a specific slice of `CLAUDE.md` + `docs/` + `.claude/`. Layers compose: Layer 1's output feeds Layers 2–6; Layer 7 polices everything above.

| # | Layer | What bootstrap authors |
|---|---|---|
| 1 | **Project Identity** | `CLAUDE.md` opening — vision + wedge ICP + moat + production-vs-internal + stage. The grounding every later layer reads. |
| 2 | **Architecture** | `CLAUDE.md` Architecture + Constraints + boundary rules + universal hooks (`check-file-size.sh`, boundary checks). |
| 3 | **Process Discipline** | `CLAUDE.md` "How You Work" + Definition of Done + task classification table + verification ladder rules + memory typing scaffold. |
| 4 | **Quality Bar** | `.claude/rules/design-north-star.md` (Tier 1 + Tier 2 benchmarks + anti-references + per-surface chrome table) + `quality-bar` skill. |
| 5 | **Knowledge Graph** | `docs/README.md` + subdirectory skeleton + authority hierarchy + `docs/product/capabilities.md` scaffold. |
| 6 | **Domain Kits** | Per applicable domain: design / coding / planning / testing / data / ai-workflow / native-bridge / pipeline-integrity. `.claude/{agents,skills,hooks,rules}/*`. **This is what v1 already did** — preserved as Layer 6. |
| 7 | **Maintenance** | Saturday-style design-debt ritual + drift detection + `skill-auditor` agent. Default-deferred for greenfield / early projects. |

Layers are dependency-ordered. Skipping Layer 1 and asking Layer 4 questions produces generic outputs (*"Apple iOS + Telegram"* as defaults regardless of whether the project even has a UI). Bootstrap walks them in order, pre-loads each layer with upstream context, and refuses to barrel through.

**Full reference**: [`docs/v2-vision.md`](./docs/v2-vision.md) — the foundation doc for v2 with every layer described in depth, 12 transferable methodology lessons distilled from one battle-tested production codebase, and the full bootstrap flow walkthrough.

<br>

## How bootstrap works

`/dotclaude:bootstrap` runs in 5 phases:

**1. Phase 1 — Project scan (silent, ~5 sec).** Reads `package.json` / `Cargo.toml` / `pyproject.toml`, file tree, existing `CLAUDE.md` / `docs/` / `.claude/`, `git log` (contributors + age + cadence + prefix conventions), test config, DB / AI / native-module signals. Auto-discovers ~30–40% of all 7-layer inputs before any question.

**2. Phase 2 — Hierarchical interview (~20–60 min).** Seven phases (A–G), one per layer, 1–3 questions per turn (never fire-hose). Skip discipline: if a question's answer is already in the Phase 1 scan, confirm in one sentence and move on. Each layer waits for explicit user confirmation before authoring.

**3. Phase 3 — Cross-layer coordination.** When Layer 4 (voice) and Layer 6 (design + coding) both propose forbidden phrases, bootstrap merges them into one file. When Layer 4 (cross-rubric translation) and Layer 6 (per-domain audit pipelines) both touch audit routing, bootstrap reconciles. Conflicts between layers (Layer 1 says "production" + Layer 4 set to "internal") are surfaced for resolution.

**4. Phase 4 — Stage + review + commit.** Everything authored lands in `.claude-staging/` + `docs-staging/` + `CLAUDE.md.draft` first. Bootstrap walks the user through 3–5 highlight artifacts with concrete reasoning citations (*"I authored X because you said Y in Q-A2"*). Explicit approval gate — *"ok"* or silence is NOT approval; bootstrap waits for *"ship it"* / *"yes commit"*.

**5. Phase 5 — Output summary.** Structured inventory by layer, with skipped layers + their reasons, recommended next steps, and the next-session re-entry points.

**Brownfield-safe.** Bootstrap detects existing `CLAUDE.md` + `.claude/` + `docs/` content and runs in one of three modes: **APPEND** (add missing layers without stomping), **REFUSE** (recommend `/dotclaude:audit` instead when the existing setup is comprehensive), **FRESH-OVERWRITE** (destructive, requires double confirmation). The REFUSE mode is a feature — it protects the user's investment in mature AI infrastructure.

<br>

## Brownfield vs greenfield

Bootstrap's first question is *"is this a fresh project or one with existing AI infrastructure?"* and answers it from Phase 1's scan, not by asking.

**Greenfield** (no `CLAUDE.md`, no `.claude/`, no substantial `docs/`): bootstrap runs all 7 layers fresh. ~25–45 min wall-clock for typical 1–5 domain projects.

**Brownfield partial** (`CLAUDE.md` < 50 LOC, OR `.claude/` with < 5 artifacts): bootstrap detects what's missing and runs only those layers. Existing content is never stomped. Final CLAUDE.md merge is section-by-section diff with per-section user approval.

**Brownfield comprehensive** (`CLAUDE.md` > 200 LOC **OR** > 5 H2 sections with Identity / Architecture / How You Work all present, AND `.claude/` has > 10 artifacts): bootstrap **refuses** to run end-to-end. The project already has substantial infrastructure; running bootstrap risks overwriting load-bearing content like task-classification tables, accumulated constraints, conformance-matrix discipline. Bootstrap surfaces three alternatives:

- `/dotclaude:audit` — read existing infra, produce gap report, no writes.
- Per-layer commands (`/dotclaude:identity` / `/dotclaude:architecture` / `/dotclaude:quality-bar` / etc.) — surgically address one layer at a time.
- Layer 6 standalone (`/dotclaude:design`, `/dotclaude:coding`, etc.) — re-run a domain kit in update mode.

The REFUSE recommendation IS the value-add. Bootstrap protects the months of accumulated AI infrastructure that comprehensive-brownfield projects represent.

<br>

## Honest limitations

dotclaude is calibrated against one battle-tested production codebase (the source project; 5 months active, ~960 commits, 7k source files, 74 `.claude/` artifacts, 40+ docs in `docs/`). The 2026-05-21 bootstrap smoke test compared bootstrap's one-pass output against that ground truth ([full report](./docs/bootstrap-smoke-test-2026-05-21.md)). The findings calibrate honest expectations:

**~65% depth match against a fully battle-tested project.** Decomposed:
- Universal infrastructure (file-size hooks, vertical-boundary patterns, task-classification table, design-north-star, quality-bar rubric): **~75–95% match.** Bootstrap structurally delivers what the methodology promises.
- Accumulated-feedback constraints in `CLAUDE.md` (translation-files-shallow-spread, lint-staged-stash-desync, language-specific compiler warnings): **~30–50% match.** Each one is a captured incident from lived debug experience. Bootstrap authors the scaffold + the "accrue-here" anchor; the entries themselves emerge over months.
- Domain-specific procedural skills (substrate runbooks like `chat-system`, `import-scanner`, `equipment-ai`; decision skills like `engine-vs-vertical-decision`): **~40% match.** These emerge from coding sessions where you wanted procedural memory of how subsystem X works. They land when you've lost > 1 hour relearning the same substrate twice — not on first bootstrap.

**Wall-clock — honest range:**

| Project shape | Time |
|---|---|
| Greenfield 1–2 weeks, 1–3 domains | 20–35 min |
| Early prototype, 3–5 domains | 40–60 min |
| Shipped, 5–7 domains | 60–90 min |
| Mature, 8 domains (max-domain case) | 90–120 min |
| Brownfield comprehensive (REFUSE) | < 5 min (no authoring) |
| Brownfield partial (APPEND) | 15–45 min (subset of greenfield-fresh) |

The 25–45 min vision claim holds for **greenfield + 1–5 domains**, which is most projects. Mature 8-domain projects are the outlier — bootstrap surfaces the wall-clock estimate during Phase F applicability confirmation and offers to defer Layer 6 to per-domain invocation across multiple sessions.

**What bootstrap structurally cannot do in one pass:**

- **Accumulated dated incident memories** (`feedback_*` / `project_*` entries) — output of coding sessions over time. Bootstrap scaffolds the memory typing taxonomy; the entries themselves accumulate.
- **Battle-tested per-aspect design system docs** (`docs/design-system/{persona,motion,tokens,components,page-archetypes}.md`) — output of design exploration over months. Bootstrap scaffolds the entry README; the per-aspect docs land when content emerges.
- **Project-specific audit reports** (`docs/audits/*.md`) — output of conformance matrices when plans ship. Bootstrap creates the empty `docs/audits/` directory; audit reports land when the work happens.
- **Substrate runbook skills** (`chat-system`, `import-scanner`, `auth-navigation`) — procedural memory of project subsystems. Land when a session demands them.

**Recommendation**: run bootstrap once for the universal infrastructure. Then expand `.claude/skills/` organically as the project matures and recurring "I had to relearn this" moments emerge. The methodology compounds; the one-pass output is the seed, not the tree.

<br>

## What's inside

| | |
|--|--|
| 🎯 **7 domain skills** (Layer 6) | One slash command per concern — design / coding / planning / testing / data / ai-workflow / init |
| 🪄 **1 bootstrap meta-skill** (Layers 1–7) | The headline `/dotclaude:bootstrap` orchestrator + hierarchical `interview.md` |
| 📚 **35 principles** | Methodology docs Claude reads selectively per project — covering project identity / architecture / file discipline / decomposition / task classification / plan-driven work / memory system / quality rubric / design benchmarking / knowledge graph / audit routing / Saturday ritual + 23 per-domain depth principles |
| 🔧 **12 hook templates** | Generic shell guardrails (file-size ceiling, raw-hex sweep, secret leak, boundary checks, forbidden phrases, etc.) — the only true templates with Mustache placeholders |
| 📖 **4 war stories** | Anonymized debugging narratives — proof material for methodology claims, not output |

Cost profile: **~984 tokens per session** always-on (the slash command definitions). **2.7–5.5k tokens per skill on-invoke**. Bootstrap itself is ~12k tokens because it loads the upstream principles selectively per layer.

Full architectural reference: [`docs/v2-vision.md`](./docs/v2-vision.md).

<br>

## Install

```bash
# Production
claude plugin marketplace add vindm/dotclaude
claude plugin install dotclaude@dotclaude

# Dev (contributing)
git clone https://github.com/vindm/dotclaude.git && cd dotclaude
claude --plugin-dir .
```

<br>

## Contribute

- **Add a principle** — drop a `.md` in [`principles/`](./principles/) matching existing structure (when-to-ship gate, why-it-matters, core methodology, depth signatures, anti-patterns, cross-references).
- **Add a hook template** — drop a `.sh` in [`hook-templates/`](./hook-templates/) with Mustache placeholders.
- **Add a domain skill** — create `skills/<name>/` matching [`skills/design/`](./skills/design/) as canonical (5-phase shape: project scan → interview → principle read → author → stage + commit).
- **Add a Layer-1-through-5 contribution** — touch `skills/bootstrap/` + write principle docs.

Anonymization enforced — see [`scripts/check-anonymization.sh`](./scripts/check-anonymization.sh) + the CI mirror.

<br>

---

<div align="center">

<sub>Built from months of working with Claude Code as a daily driver.</sub><br>
<sub>MIT licensed.</sub>

</div>
