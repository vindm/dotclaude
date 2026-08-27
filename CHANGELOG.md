# Changelog

All notable changes to dotclaude are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project loosely follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) — minor versions for new layers / skills / principles, patches for fixes and doc corrections.

## [3.1.0] - 2026-08-27 — the delivery gate

"Merged into main", "pushed", "all gates green" describe the author's desk, not the
recipient's machine — and said in a final message they read as fact while nothing
ever revises them. This release adds the moment at which reality gets consulted: a
**Stop** hook that reads the claim the final message actually makes and asserts
exactly that rung against the repository. Plus the outcome-anchored detector for
shell writes into a policed main checkout, a hole its `Write|Edit`-matched sibling
structurally could not see.

### Added
- **`hooks/scripts/check-delivery-claim.sh`** (Stop) — blocks a turn whose final
  message claims a rung of delivery the repo denies: *committed* (no uncommitted
  changes in any worktree), *merged* (branch tip is an ancestor of the main branch),
  *pushed* (no commit on a live branch is absent from every remote), *verified* (a
  gates receipt matching this tree, 0 failed, 0 skipped). **No claim, no sound** — it
  is deliberately not a check for unfinished work, because Stop fires after every
  turn and a guard that nags about a dirty tree gets switched off within a day.
  Config-gated on a `delivery:` block; silent no-op without one. Ships sensitive
  English claim phrases; a project adds its own language via `claimsCommitted` /
  `claimsMerged` / `claimsPushed` / `claimsVerified`.
- **`hooks/scripts/check-main-checkout-bash-write.sh`** (PostToolUse · Bash) — reports
  files a shell command wrote into the policed main checkout. `sed -i`, heredoc
  redirects, `tee`, a python one-liner: none carry a `tool_input.file_path`, so all
  of them walked past `check-main-checkout-edit`, and in one consuming project the
  encoding rules actively *required* the shell route for the riskiest files. Anchored
  on the **outcome** (`git status` diffed against the same session's previous answer),
  not on command patterns, which a quoted path, a `cd`, a variable or any
  not-yet-invented write mechanism defeats. Honest limit stated in its header: a
  PostToolUse hook cannot block, so it detects and hands back an exact undo.
- **`principles/delivery-discipline.md`** — the doctrine: gate the claim rather than
  the work; the four rungs; why the receipt instead of a re-run; why the fingerprint
  is the tree-as-it-would-be-committed rather than `HEAD` + dirty list; why there is
  no escape phrase; why the loop guard is not optional.
- **`delivery.claimsSkipAck`** — phrases that narrow a "green" claim by naming the
  skipped gate. Without it the `verified` rung is unsatisfiable wherever a gate is
  legitimately unavailable (no node toolchain, no docker): the JS lint in the live
  test project skips on every run, so no wording and no amount of re-running could
  ever have cleared the claim. An unsatisfiable gate gets switched off.
- **Test harnesses beside both hooks** (`test-check-delivery-claim.sh`,
  `test-check-main-checkout-bash-write.sh`) — 28 and 9 cases against **real** fixture
  repositories with real remotes, worktrees, commits and pushes. Proven to bite by
  mutation: neutering the claim comparison turns 11 cases red, neutering only the
  staleness comparison turns exactly 1 red.

### Changed
- **`hooks/scripts/_read_dotclaude_yml.py`** — the parse and lookup logic became
  importable (`load()` / `lookup()`) so the new hooks reuse it instead of growing a
  second YAML parser. CLI behaviour unchanged.
- **`CONTRIBUTING.md`, "Add a hook"** — it described **two** homes, which had been
  untrue since 2.1.0: the config-gated always-on shape (always shipped, reads
  `dotclaude.yml` at runtime, no-op without its block) is now named as the third and
  **preferred** home for anything project-tunable, since a rendered per-project copy
  forks the logic and stops receiving fixes. Also records the two-level config-key
  constraint, that `PostToolUse` exit 2 cannot block, and the fixture-plus-mutation
  requirement for a hook's test.
- **`hooks/README.md`** — the two new rows, a "config-gated, not zero-config" section
  naming which hooks no-op without which block, and the measured per-Bash cost
  (0.17 s configured / 0.01 s not).

## [3.0.0] - 2026-07-20 — split into two plugins + elicitation-not-generation

The single `dotclaude` plugin splits into **`dotclaude`** (coding/testing/pre-flight/worktree base) and **`dotclaude-design`** (the design/UX/a11y audit layer) — install either independently or both together. Alongside the split, the domain generators (`/dotclaude:coding`, `/dotclaude:testing`) change shape: instead of authoring a project-local copy of an agent, they now elicit the project's own intent (anti-pattern lists, a risk model) into a **thin artifact** that the shipped, consumed agent reads at runtime — so the reviewer/architect logic lives in one place and stays current with the plugin instead of forking per project.

### Added
- **`.claude-plugin/marketplace.json`** — the two-plugin marketplace manifest; `plugins/core` and `plugins/design` each carry their own `.claude-plugin/plugin.json`, version `3.0.0`.
- **Domain-artifact contract** (`plugins/core/docs/artifact-contract.md`) — the elicit → thin-artifact → consumed-agent-reads-at-runtime pattern that replaces the old per-project generator output. `code-review` reads `.claude/dotclaude/code-anti-patterns.md`; `test-architect` reads a project risk-model artifact; both fall back to generic methodology when the artifact is absent.

### Changed
- **`/dotclaude:coding`** and **`/dotclaude:testing`** — became elicitation-only. They no longer author an agent, rule, or hook copy; they write the project-specific artifact the already-shipped `code-review` / `test-architect` agents consume at runtime.
- **`flow-continuity-review` merged into `flow-audit`** — one agent, two input modes (single screen vs. multi-screen arc), instead of two agents with overlapping scope.
- **`pre-flight` stays directly consumed** — the planning generator that used to author a project-local copy of it was cut; the shipped agent is used as-is.

### Removed
- **5 box-duplicate skills**: `authoring-skills`, `plan-driven-work`, `memory-system`, `handoff`, `saturday-ritual` — each duplicated a discipline already carried by `operating-discipline` or by the artifact-contract pattern above; kept as one thing instead of two drifting copies.
- **The `init` generator** (`/dotclaude:init`) — folded away now that the consumable base plus the per-domain elicitation skills cover the one-shot-bootstrap use case without a separate full-bootstrap command.
- **`forbidden-phrases`** hook template — a voice-policing mechanism that didn't earn its keep against false positives; cut rather than kept as dead weight.

### Deferred
- **The `data` domain** (data-integrity agent + `migration-create` skill) and the **`ai-workflow` domain** moved to `deferred/` — not shipped in either plugin this release. Stale references to them across agents, principles, and skill docs were reworded or removed so nothing in the shipped plugins advertises a tool that isn't there.

## [2.1.0] - 2026-07-03

### Added
- **`/dotclaude:worktree` — parallel-session isolation domain** (`skills/worktree/` + `principles/worktree-discipline.md`). For projects where several AI sessions collide in one checkout (shared git index staging a sibling's WIP; simultaneous edits to one file): a generator that authors a blocking main-checkout PreToolUse hook, its test harness, and a project-specific worktree lifecycle skill. Distilled from a real two-project port (an RN monorepo's Metro/sim-registry discipline generalized, then re-landed on a bookkeeping-engine audit zone); the principle doc carries the five hard-won lessons: markdown-is-sometimes-code (never blanket-exempt `*.md` — runtime policies/prompts must be POLICED), git-ignored per-machine files break fresh worktrees (interviewed setup recipe), derived artifacts dirty the tree (mandatory live smoke-worktree run before handoff), hooks register at session start (restart + live-fire handoff), and the worktree's absolute path comes from git — never hand-built (`../<prefix><slug>` resolves against the `-C` repo dir, not the shell cwd; capture from `git worktree list`, assert, and use the literal path — a dropped segment silently misfiles work into a stray sibling dir). Strictly opt-in via the generator — deliberately NOT a plugin-level always-on guard (exempt lists are per-project judgment calls).
- **`hook-templates/check-main-checkout-edit.sh` + `test-check-main-checkout-edit.sh`** — the debugged, consumed-not-rewritten enforcement pair (nearest-existing-dir walk for not-yet-created files, worktree detection via `--git-dir` ≠ `--git-common-dir`, other-repo pass-through, escape-hatch flag file, and a misplaced-worktree guard that blocks a write to a `<namePrefix>*` path which does not resolve into the policed repo). The harness ships INTO the project next to the hook so future hook edits stay guarded. Verified on both topologies: policed repo below the project root, and root-is-repo.

### Changed
- **`init`** — worktree domain added to the applicability matrix (apply on concurrency signals: lock files, session-coordination CLAUDE.md sections, clobbered-parallel-work history; recommend AGAINST for solo single-session projects) and to the Phase 3 run order (last — its smoke run sees the other domains' staged artifacts, its restart handoff closes the init).

## [2.0.1] - 2026-06-14

### Changed
- **Hooks restructured for clarity (consume-direct hygiene).** The ready-to-run universal guard scripts moved from `hook-templates/` to **`hooks/scripts/`** — they are consumed as-is by `hooks/hooks.json`, not templates. `hook-templates/` now holds ONLY genuine `{{placeholder}}` generator templates (project-specific by nature: theme path, boundary rules, brand phrases, project commands). READMEs in both dirs make the split explicit. No consumer-facing behavior change beyond the addition below.

### Added
- **`check-bash-safety` wired into the base hooks** — warns on `rm -rf` / `cd` / `cp -r` / `mv` with an unquoted `$VAR` (which can expand empty/dangerous). Scoped to those commands; warn-only.

## [2.0.0] - 2026-06-14 — v3: consume-direct base

The framework gains a **directly-consumable base** alongside the generator. Enabling the plugin now gives a project a ready-made universal layer used as-is — no per-project authoring — and `bootstrap` shrinks to a thin generator that authors only the un-shareable project layer on top. Full rationale + the verified plugin-mechanics constraints in `docs/v3-consume-direct-brainstorm.md`.

### Added
- **`agents/` (14 consumable)** — `code-review`, `pre-flight`, `test-architect`, `data-integrity`, `skill-vs-code-audit`, `product-direction-validator`, `a11y-audit`, `ux-audit`, `interaction-audit`, `flow-audit`, `flow-continuity-review`, `pages-audit`, `design-token-audit`, `product-designer`. Default `model: sonnet` (shadow with opus); read-only auditors carry no Write/Edit; all derive project specifics (anti-patterns, schema, benchmarks) at runtime rather than from a baked snapshot.
- **`skills/` (13 new consumable)** — `operating-discipline` (the always-on "how you work" methodology), `decomposition`, `journey-mapping`, `persona-testing`, `element-reuse`, `iterative-polish-autoloop`, `authoring-skills`, `handoff`, `plan-driven-work`, `knowledge-layers`, `memory-system`, `migration-create`, `saturday-ritual`.
- **`hooks/hooks.json` (5 universal guards)** — git-safety, secret-leak, file-size, session-start git context, uncommitted-on-clear; fire additively in every consumer; scripts referenced via `${CLAUDE_PLUGIN_ROOT}`.
- **`docs/v3-consume-direct-brainstorm.md`** — the v3 design, plan, and verified plugin-mechanics constraints.

### Changed
- **`bootstrap` → thin generator** (`skills/bootstrap/SKILL.md` 673 → 92 lines; `interview.md` 553 → 379, phases A/B/D/E only). Phase 0 enables the plugin (the base); bootstrap then authors only identity / architecture / quality-bar / knowledge-graph + a thin local `CLAUDE.md` that points at the consumed `operating-discipline` skill. Process / domain / maintenance are consumed, not interviewed.
- **Distribution model** — generator-only → consumable base + thin generator. The distillation tool that grows the base lives in the *source* project, not here (the source owns the act of distillation).

### Constraints discovered (load-bearing, verified against the plugin reference)
- Plugins cannot ship `rules`, and a plugin root `CLAUDE.md` is not loaded — instructions ship as **skills**. So always-on methodology is a skill (soft always-on); a hard every-session guarantee is a one-line pointer the generator writes into the project's local `CLAUDE.md`.

### Still open
- Dogfood validation in a live consuming session (does the skill load / hooks fire / agents dispatch as `dotclaude:<name>`).
- `principles/` cleanup — many are now redundant with the shipped base; status map in `principles/README.md`.

## [1.2.0] - 2026-06-14

### Added — process-discipline catch-up from the source project

A re-audit of the battle-tested source codebase (the project dotclaude distills) against the v1.1 framework surfaced ~3 weeks of process-layer learnings not yet generalized. This release ports the project-agnostic core; the RN/iOS/Supabase-specific machinery stays in the source project.

- **5 new methodology principles:**
  - `principles/operating-principles.md` — Layer 3. "How You Work" authored as 3–4 NAMED operating principles (Understand before you build · Reason to the right solution · Goal-driven complete execution · Depth by default, ceremony on demand), each closing in a `**The test:**` line that makes it auditable. Folds in the autonomous-run fallback (state assumptions when no one can answer) and the every-turn standing checks.
  - `principles/lean-by-default.md` — Layer 3. Depth ≠ ceremony: an "Escalate when (and only when)" trigger table gates all process machinery, plus context-budget discipline for the always-loaded surface. Cross-refs the cost ladder in `audit-routing.md`.
  - `principles/knowledge-layers.md` — Layer 5. The cross-layer authority order `.claude/` (guidance) → code (truth) → `docs/` (reflection); doc-vs-code conflict → code wins; stable-anchor references; archive-out-of-reach (Read-denied history).
  - `principles/authoring-skills.md` — Layer 6. "Point, don't mirror" — skills bind to durable invariants and point at canonical sources, never mirror perishable snapshots (`file.ts:142` cites, step-by-step prose, exhaustive rosters) that rot within one refactor.
  - `principles/handoff.md` — Layer 3. Conscious session handoff before context loss: route durable facts → memory, plan progress → doc banner, orphan WIP → ephemeral handoff doc; the `/clear` quality gate; WIP-commit-not-stash.
- **2 new hook templates:**
  - `hook-templates/check-git-safety.sh` — PreToolUse hook blocking destructive git (force push, `reset --hard`, `clean -f`, `--no-verify`, history rewrites) by whole-command match, so flag reordering can't bypass a prefix deny rule.
  - `hook-templates/warn-uncommitted-on-clear.sh` — SessionEnd hook warning on uncommitted WIP before `/clear` (nudges a WIP commit over `git stash`).
- **3 new anonymized war stories** in `examples/`:
  - `the-doc-that-lied.md` — a stale reflection doc trusted over code; a second writer of the same state, found by grep too late. Paradigm for `knowledge-layers.md`.
  - `the-stash-that-ate-the-afternoon.md` — `git stash` inside a killed pipeline stranded an afternoon's WIP. Paradigm for WIP-commit-not-stash (`handoff.md`).
  - `the-commit-that-dropped-six-files.md` — `lint-staged` re-staged a subset; the message claimed seven files, one landed. Paradigm for commit-integrity verification.

### Changed

- **`principles/memory-system.md`** — added the ≤ 40-line per-entry ceiling (entries are facts, not essays), a "Self-healing" section (SessionStart git-state reconcile + periodic headless audit), and two depth signatures. Cross-refs `handoff.md` + `knowledge-layers.md`.
- **`hook-templates/git-context-sessionstart.sh`** — upgraded from a one-line branch/commit echo to full git state (uncommitted count, ahead/behind upstream, live worktrees) plus a memory self-healing instruction: reconcile any memory entry the git state contradicts before starting work.
- **`skills/bootstrap/SKILL.md`** — Layer 3 now authors the named-principles-with-tests "How You Work" + Escalate table + handoff skill; Layer 5 authors the knowledge-layers doctrine + archive Read-deny; Layer 6 applies "point, don't mirror" to every authored skill. The principle → layer → artifact map and the universal-hooks set updated accordingly.
- **`principles/knowledge-graph.md`** — strengthened the `docs/archive/` section with the agent Read-deny (`docs/archive/**` permission deny) and added a "Reference discipline — stable anchors, never hard-cites" subsection (bind to indexes / capability IDs / folder conventions, not dated filenames).
- **`principles/code-review.md`** — added a "Commit integrity" section: verify the staged set landed (`git show --stat HEAD`) after multi-file commits, since `lint-staged`-style hooks can silently desync the committed set from the message.
- **`principles/lean-by-default.md` + `hook-templates/auto-lint-posttool.sh`** — added a per-edit latency budget (Idea 4): don't run multi-second commands per edit, consolidate `Write|Edit` checks into one dispatcher. The per-edit `eslint --fix` template now ships with a "when NOT to use" warning (redundant with lint-staged + DoD; slow linters tax every write) — the source project removed exactly this pattern as redundant and slow.
- **README + plugin/marketplace descriptions** — inventory updated to 40 principles · 14 hook templates · 7 war stories; version badge to 1.2.0.

## [1.1.0] - 2026-05-21

### Added — v2 reframe

The plugin moves from "design audit kit" to **AI dev infrastructure framework**. See [`docs/v2-vision.md`](./docs/v2-vision.md) for the full architecture rationale; the 7-layer hierarchy is now the headline.

- **`/dotclaude:bootstrap`** — new headline command. 7-layer hierarchical interview (project identity → architecture → process → quality bar → knowledge graph → domain kits → maintenance) authoring `CLAUDE.md` + `docs/` + `.claude/`. Adaptive per project shape; brownfield-safe with three modes (APPEND / REFUSE / FRESH-OVERWRITE).
- **5 upstream methodology principles** to anchor bootstrap's pre-Layer-6 stages:
  - `principles/project-identity.md` — Layer 1 (vision / ICP / moat / production-vs-internal / stage).
  - `principles/knowledge-graph.md` — Layer 5 (`docs/` index, authority hierarchy, capability map scaffold).
  - `principles/plan-driven-work.md` — Layer 3 (spec → plan → impl → conformance-matrix pattern).
  - `principles/memory-system.md` — Layer 3 (user / feedback / project / reference memory typing + decay policies).
  - `principles/task-classification.md` — Layer 3 (the routing matrix pattern).
- **Optional Layer 7 principle** for projects opting into maintenance discipline:
  - `principles/saturday-ritual.md` — weekly design-debt batch + drift detection.
- **Bootstrap smoke test report** ([`docs/bootstrap-smoke-test-2026-05-21.md`](./docs/bootstrap-smoke-test-2026-05-21.md)) — bootstrap's one-pass output compared against the source project's months-evolved ground truth. ~65% depth match calibration evidence.
- **Real /dotclaude:design smoke test on a fresh project** ([`docs/design-real-smoke-test-2026-05-21.md`](./docs/design-real-smoke-test-2026-05-21.md)) — first NON-case-study validation; targets a fresh Vite + React 19 + TS 6 + Tailwind 4 project the test had no prior exposure to. Match level A.
- **`bootstrap.gif` demo** — 38-second 1200×800 JetBrains Mono walk through the headline flow. Replaces the design-only demo as README hero.
- **5 GitHub topics** added to repo metadata: `ai-dev-infrastructure`, `bootstrap`, `claude-md`, `methodology`, `ai-workflow`.

### Changed

- **Repo positioning**: design plugin → AI dev infrastructure framework.
- **README rewrite** — bootstrap as headline; design demoted to "Layer 6 in action" example. The 7-layer hierarchy is the lead narrative.
- **`plugin.json`** + **`marketplace.json`** descriptions updated to reflect the meta-framework angle.
- **Demo gif typography** — uses JetBrains Mono at 18pt 1200×720 (previously the unstyled fallback at smaller dimensions).
- **`skills/init/SKILL.md` frontmatter + prose** — clarified as a Layer-6-only entry, lighter alternative to `/dotclaude:bootstrap` for users skipping upstream layers.

### Fixed

- **Anonymization guard** now catches binary-file false positives (the previous version emitted noise on `assets/*.gif`).
- **9 proper-noun leaks** in analysis docs (source-project domain-specific names) scrubbed.
- **README false references** — removed mentions of `/dotclaude:audit`, `/dotclaude:identity`, `/dotclaude:architecture`, `/dotclaude:quality-bar` (skills that do NOT ship in v1.1; remain on v2 roadmap). README's Brownfield section now describes the actually-supported alternatives (Layer 6 standalone / manual CLAUDE.md edits / bootstrap APPEND mode).
- **`docs/v2-vision.md` §6** — added "Status note" header clarifying that only bootstrap + upstream principles ship in v1.1; per-layer skills are forward-looking.

### Preserved (zero breaking changes for v1 users)

- **All 7 v1 domain skills** untouched: `/dotclaude:design`, `/dotclaude:coding`, `/dotclaude:planning`, `/dotclaude:testing`, `/dotclaude:data`, `/dotclaude:ai-workflow`, `/dotclaude:init`. The contract is preserved exactly.
- **All hook templates in `hook-templates/`** unchanged.
- **All war stories in `principles/war-stories/`** unchanged.
- **Anonymization guard** (`scripts/check-anonymization.sh`) — universal, ships on every commit through CI.

A v1 user invoking `/dotclaude:design` in v1.1 sees no behavior change. The v2 surface is opt-in via `/dotclaude:bootstrap`.

## [1.0.0] - 2026-05-20

Initial release. The "design audit kit" framing — Layer 6 of what would later become the 7-layer hierarchy.

- **7 domain skills**: design / coding / planning / testing / data / ai-workflow / init.
- **24 methodology principles** in `principles/` covering file discipline, decomposition, task classification, quality rubric, design benchmarking, audit routing, visual verification, and per-domain depth.
- **12 hook templates** in `hook-templates/` — generic shell guardrails (file-size ceiling, raw-hex sweep, secret leak, boundary checks, forbidden phrases, etc.) with Mustache placeholders.
- **4 war stories** in `principles/war-stories/` — anonymized debugging narratives as proof material.
- **4 example showcase outputs** in `docs/showcase/` demonstrating Layer 6 outputs on different project shapes.
- **Anonymization guard** (`scripts/check-anonymization.sh`) + CI workflow (`.github/workflows/anonymization-guard.yml`).
- **`/dotclaude:design` demo gif** as README hero.

[1.1.0]: https://github.com/vindm/dotclaude/releases/tag/v1.1.0
[1.0.0]: https://github.com/vindm/dotclaude/releases/tag/v1.0.0
