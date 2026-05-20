# `/dotclaude:bootstrap` interview

The hierarchical interview that drives the 7-layer bootstrap. Seven phases (A–G), one per layer, ~22–30 questions total, ~25–40 min wall clock for greenfield, ~15–25 min for brownfield in APPEND mode.

**Pacing rule**: 1–3 questions per conversational turn. Never fire-hose. Listen for off-script signal — a user-volunteered *"our settings page got out of hand"* is gold for Layer 6 design's anti-patterns slot.

**Skip discipline**: if a question's answer is obvious from Phase 1's project scan, do NOT ask — confirm in one sentence and move on. The cost of asking a redundant question is real (signals *"you weren't paying attention to my code"*).

**Adaptive depth**: each phase has a default question count. Reduce when Phase 1 pre-populated; expand only when the user gives volunteered signal. Greenfield runs need fewer pre-populates and more questions; brownfield runs the inverse.

**Pause-and-confirm gate**: after each phase, the SKILL.md flow stages the layer's artifact and asks *"Layer N staged. Move to Layer N+1?"*. The user can interrupt, revise, or skip the next layer.

---

## Phase A — Project Identity (Layer 1) — 4–6 questions

### A0 — Mode confirmation (only if brownfield detected)

If Phase 1 §1.3 found existing `CLAUDE.md` / `docs/` / `.claude/`:

> *I noticed you already have <CLAUDE.md / docs/ / .claude/>. Three modes available:*
>
> *- **Append mode** (default): I'll add only the missing layers; existing content stays untouched. You diff per-section before commit.*
> *- **Audit mode**: I read your existing infra and produce a gap report; no writes.*
> *- **Fresh-overwrite mode** (destructive): I author all 7 layers from scratch into staging; you diff before commit; the existing content gets replaced.*
>
> *Which?*

Default to APPEND. If the existing CLAUDE.md is > 200 LOC AND structured (all major sections present), recommend REFUSE per SKILL.md "Brownfield handling" — *"Recommend `/dotclaude:audit` or per-layer commands instead. Want to proceed with fresh-overwrite anyway?"*

Wait for explicit mode pick. The rest of Phase A is unchanged.

### A1 — One-sentence product description

> *"In one sentence: what is this, who's it for? Pretend you're explaining to a developer friend who's curious."*

**Drives**: Layer 1 vision opening sentence + downstream task classification calibration.

**Listen for**: marketing copy. If the answer is *"a revolutionary new way to..."* or *"the modern X for Y"*, push back gently: *"Strip the adjectives — what do users DO with this?"* The opening sentence battle-tests when it has a noun + verb + user, not when it has marketing register.

**Skip-if-Phase-1**: if README.md opens with a clear one-paragraph description, confirm in one sentence: *"Your README says `<X>` — is that still the right framing, or has it shifted?"*

### A1.5 — Secondary product framing (optional, ~30 sec)

> *"In ONE more sentence, what makes this project hard or different from the obvious-looking version of it? Skip if your A1 already captures it. (Common shape: 'X with optionality on Y' — e.g. 'a gym vertical, with the spatial engine generalizing to other venues as optionality.' Captures the moat hint without committing the moat.)"*

**Drives**: Layer 1 secondary-product framing — distinct from A6 moat. A1 captures purpose; A1.5 captures the "primary product + optionality" structure if it exists. Useful for CLAUDE.md Architecture (when the optionality has a code-shape implication, e.g. one codebase serving two products) AND for the Quality Bar register (one product may be S-tier register, the other credible-register).

**Listen for**: a user volunteering *"actually it's two things on one codebase"* or *"the underlying engine could generalize to..."* These are the signals A1 didn't fully capture. Most projects answer *"A1 already says it"* — that's fine. Don't force a second framing if there isn't one.

**Discovered**: 2026-05-21 smoke test against the case-study project. A1 captured *"intelligence layer for premium specialty gyms,"* but the ground-truth CLAUDE.md opens with *"Primary product + optionality on one codebase. Primary: gym vertical. Optionality: spatial engine."* The optionality framing was load-bearing for downstream architecture decisions; missing it produced a thinner Identity section.

**Skip-if-volunteered-already**: if A1's answer already contains *"primary X + optionality Y"* / *"a vertical that uses an engine"* / *"two products on one codebase"* — confirm in one sentence and skip A1.5 question.

### A2 — Wedge ICP

> *"Who are the first 5 specific customers you'd want for this? Name them — companies, roles, or specific people. If you can't list 5 by name, the wedge is too fuzzy; tell me what you DO know and I'll help sharpen."*

**Drives**: Layer 1 ICP line. Anchors every downstream "does feature X serve our users" question.

**3-property test** per `project-identity.md`:
- **Named** (industry / role / company-size).
- **Located** (if geography matters).
- **Reachable** (can list 5 by name).

If the user names ≥ 3, the wedge is workable. If they name 0–2, surface the fuzziness:

> *"It sounds like the wedge isn't fully crisp yet. That's fine — I'll write `<TENTATIVE_ICP>` in the identity section with a TODO. You can sharpen later. But noting the fuzziness now means downstream layers won't pretend it's resolved."*

### A3 — Production-vs-internal

> *"Where does this ship? App Store / public website / open-source registry / internal dashboard / notebook on your laptop?"*

**Drives**: Layer 1 production-vs-internal tag. Anchors Layer 4 quality bar register (production = consumer-app benchmarks; internal = credible-not-S-tier; library = API ergonomics; research = produces-interpretable-output).

**Skip-if-Phase-1**: if the project is a public package on npm / PyPI / Cargo (visible in `package.json` `"name"` field + a `"main"` / `"bin"` / `"exports"` pattern), confirm: *"Looks like a public library — `<package-name>` on npm/PyPI/Cargo. Confirm production-library?"*

### A4 — Solo-vs-team

**Skip-if-Phase-1**: Phase 1 §1.4 already ran `git log --format='%an' | sort -u`. If 1 contributor, confirm: *"`git log` shows 1 contributor — solo, confirm?"*. If > 1, ask:

> *"`git log` shows N contributors. Are they all actively writing code, or some historical / collaborators-via-issues only? And — solo-staying-solo, or planning to add collaborators in the next 3 months?"*

**Drives**: Layer 3 process discipline (team coordination conventions: PR review etiquette, commit-message verbosity, branching strategy). Layer 7 maintenance ritual cadence default.

### A5 — Maturity stage

**Pre-populate from Phase 1**: project age (`git log --format='%ai' | tail -1` from §1.4) + file count (§1.5) + commit count (§1.4).

Propose maturity tag with the heuristic:

| Age | Files | Users (ask user) | Tag |
|---|---|---|---|
| < 2 weeks | < 30 | 0 | `greenfield` |
| 2 wk – 3 mo | 30–200 | 1–5 internal | `early` |
| > 3 mo | > 200 | > 5 | `shipped` |
| > 1 yr | > 500 | > 50 OR meaningful revenue | `mature` |

> *"Based on git: project is `<age>` old with `<file count>` source files. I'd tag this `<proposed maturity>`. Do you have external users yet — and roughly how many?"*

**Drives**: Layer 7 applicability + Layer 1 stage tag.

### A6 — Moat / differentiation (optional, defer-able)

> *"What would a well-funded competitor need 3 months to catch up to? What couldn't they ever catch up to?"*

**Drives**: Layer 1 moat bullets + Layer 1 NOT-the-moat negation.

The two-question form is intentional. *"Couldn't ever catch up to"* is the load-bearing answer (per `project-identity.md`); *"3 months to catch up to"* is the moat-shaped-differentiator (real but copyable).

If the user can't articulate a moat:

> *"Totally fine to defer. I'll write `<MOAT_TBD>` in the identity section with a comment. You can fill it in over the next few weeks of customer truth. The placeholder is better than an invented moat."*

`<MOAT_TBD>` is a valid output for greenfield / pre-product projects. Don't pressure.

---

## Phase B — Architecture (Layer 2) — 3–5 questions

### B1 — Stack confirmation

**Skip-if-Phase-1**: Phase 1 §1.2 read `package.json` / `Cargo.toml` / `pyproject.toml`. Confirm in one sentence:

> *"Looks like `<language>` + `<framework>` + `<runtime>`. Confirm? Any major components I missed?"*

**Drives**: Layer 2 stack + downstream domain applicability matrix.

### B2 — Layer model

> *"How would you describe the codebase's structure in 1–3 layers? Common patterns: single-tier (one app, one codebase), two-tier (e.g. shared/ + app/, or engine + vertical), N-tier (microservices, monorepo with N packages). Or is there a less-standard shape?"*

**Drives**: Layer 2 architecture diagram + Layer 2 boundary detection.

For most greenfield projects: single-tier is default. The question forces *naming* the implicit layers (e.g. *"core logic / presentation / I/O"* for a CLI, or *"models / controllers / views"* for a monolith). Naming makes the boundaries enforceable downstream.

### B3 — Boundaries

> *"Any non-negotiable boundaries? Examples: 'lib/ never imports from app/', 'frontend never imports from backend/', 'domain doesn't know about infrastructure.' If yes — name them; I'll author a hook + rule per boundary. If unclear — fine to defer."*

**Drives**: Layer 2 boundary rules + boundary hooks.

If the user says *"not really"*: ship only the universal file-size hook + rule. Don't invent boundaries.

If the user names ≥ 1 boundary: confirm greppability (*"can this boundary be expressed as a grep pattern over import statements?"*). Greppable boundaries get a hook; non-greppable boundaries get a rule only.

### B4 — Constraints + file-size ceiling

> *"Any non-negotiable constraints? Examples: file-size ceiling (1000 LOC for TS / 500 for Python / 800 for Rust / 600 for Go), no raw color literals, no `any` types, no inline styles. I'll author hooks + rules for each."*

**Drives**: Layer 2 constraints bullets + per-constraint hook/rule.

**Universal default**: ship `check-file-size.sh` at the project-language-appropriate ceiling unless user opts out. Don't ask if they want it — propose, accept opt-out.

**Skip-if-Phase-1**: if Phase 1 found existing hooks (`.claude/hooks/`), confirm: *"You already have `<X.sh>` and `<Y.sh>`. I'll keep those; want to add the universal file-size hook on top?"*

### B5 — External integrations (deferred to Layer 6)

Don't ask here. The integrations (Supabase, Stripe, OpenAI, AI SDK) get caught by Phase 1 §1.7 + §1.8 + §1.9 and feed Layer 6 applicability.

---

## Phase C — Process Discipline (Layer 3) — 4–6 questions

### C1 — Plan-driven y/n + threshold

> *"Do you write specs / brainstorms / plans before non-trivial implementation, or do you trunk-based-ship-fast? And if plan-driven — what size of work triggers a plan? Common thresholds: > 1 day, > 3 files, > 2 modules."*

**Drives**: Layer 3 plan-driven discipline rule + Plan-backed row in task classification table.

If trunk-based: skip the conformance-matrix discipline; CLAUDE.md gets a shorter DoD; no Plan-backed row in task classification.

If plan-driven: the conformance-matrix discipline ships. Threshold from user's answer goes into CLAUDE.md.

### C2 — Task classification rows

> *"In a typical week, what kinds of tasks do you work on? I have starter rows for: UI feature, bug fix, backend / pipeline, architecture change, data / schema, plan-backed, ambiguous. Which of these apply? Anything I should add (e.g. 'API addition' for backend-heavy projects, 'hotfix' if you have prod incidents)?"*

**Drives**: Layer 3 task classification table rows.

Show the universal default starter table per `task-classification.md` (or per-project-type variants for CLI / SaaS / docs / library / research). User confirms / adjusts.

**Cap at 8–10 rows**. If the user wants > 10, push back: *"More than 10 rows stops being scannable. Some of these can be combined — e.g. 'bug fix' and 'hotfix' can be one row with hotfix as a sub-mode."*

The **Ambiguous** row is mandatory; don't ask whether to include it.

### C3 — Memory system y/n

> *"Do you want a typed cross-conversation memory system? It captures: user preferences (e.g. 'always yarn, never npm'), feedback / corrections (graduate to rules when fired 3+ times), active project state, stable references. Default-on for projects > 2 weeks old; default-skip for single-session tools."*

**Drives**: Layer 3 memory-conventions doc + memory section in "Where to find what."

For greenfield / 1-week-old: default-skip. For everything else: default-on, propose the four-type taxonomy.

If user says yes: explain the convention briefly, note the memory directory location is outside the project (`~/.claude/projects/<project-slug>/memory/`), bootstrap creates the conventions doc only.

### C4 — Subagent dispatch pattern (skip-if-not-applicable)

> *"Do you use subagents / Task tool / dispatch patterns? If yes — any project-specific conventions (worktree gates, dispatch prefixes, fresh-per-task)? If no — skip."*

**Drives**: Layer 3 subagent-dispatch rule (only if applicable).

For solo single-conversation use: skip. For team / multi-conversation projects: ask.

### C5 — Verification ladder

> *"For UI surfaces — how do you verify changes? Screenshot in browser / sim / device? Playwright / Maestro / manual? I'll codify the verification ladder so future sessions follow it."*

**Drives**: Layer 3 `visual-verification.md` rule with project-specific capture commands.

**Skip-if-Phase-1**: if Phase 1 §1.6 found Playwright / Maestro / Storybook config, propose the discovered command. Otherwise ask.

**Skip-if-no-UI**: if Phase 1 §1.5 found no UI files, skip Phase C5 — Layer 3 ships without `visual-verification.md`.

### C6 — File-size discipline (continuation from B4 if needed)

Already covered in B4 unless user wants to revisit. If file-size ceiling is the universal default, the discussion ended in Phase B.

---

## Phase D — Quality Bar (Layer 4) — 4–6 questions

**THE most important phase.** Without named benchmarks, every authored audit collapses to vibes. Push if the user resists; one named app is the minimum.

### D1 — Demo test framing

> *"Who would you demo a polished change to — be specific. Name the role or person. ('A friend's customer I'm recruiting as customer #2', 'a journalist writing about us', 'a CTO at a target enterprise', 'a designer whose taste I respect', 'my dad'.)"*

**Drives**: Layer 4 demo-test framing + Layer 4 quality bar register.

The specificity matters. *"Users"* fails the test; *"a CTO at a target enterprise during a 30-min sales call"* passes.

### D2 — Tier 1 chrome benchmarks (per platform)

> *"Name 2–3 apps you benchmark **chrome** against — the apps your users already have on their device, the apps your product gets compared to by reflex. 'When I look at my screen and then look at App X, which one tells me my chrome is wrong?'"*

**Drives**: Layer 4 `<domain>-north-star.md` Tier 1 benchmarks.

Common picks by platform (prompt, don't prescribe):
- **iOS consumer** → Apple iOS 26 Music / Photos / Settings / Wallet + Telegram on iOS 26
- **Web SaaS B2B** → Linear / Stripe / Notion / Vercel
- **Developer tool** → Linear / Raycast / Things 3
- **Content product** → Apple News / Reeder / Substack
- **B2B dashboards** → Linear / Vercel / Stripe / Datadog
- **CLI / TUI** → `gh`, `lazygit`, `htop`, `bat`
- **Docs site** → Stripe API ref / Linear changelog / Astro docs

If the user says *"we don't really benchmark"* — try once: *"What app on your device do you think is well-designed?"* Almost everyone has an answer.

**Skip if no UI** (research prototype, pure backend, pure library). Layer 4 ships an `api-north-star.md` instead, with API-ergonomics benchmarks (React Query for hook ergonomics, Zod for type-narrowing, requests-Python for readability, etc.).

### D3 — Tier 2 domain benchmarks (with dimension)

> *"Name 2–3 apps you benchmark **specific dimensions** against. Not chrome-overall but specific things they do well. E.g. 'Linear for keyboard speed, WHOOP for data density, Things 3 for empty states, Stripe for checkout sequencing.' Each name comes with the dimension."*

**Drives**: Layer 4 Tier 2 benchmarks with named dimensions.

The **dimension is the load-bearing part**. *"We like Notion"* is useless. *"Notion for inline editing affordances"* is enforceable. Push for the dimension; without it, the Tier 2 benchmark doesn't anchor anything.

### D4 — Anti-references

> *"Apps the design should **NOT** look like? Aesthetics or patterns you've explicitly rejected? 'No SAP-enterprise grid', 'no early-Material', 'nothing Bootstrap-y', 'no consumer-y/bubbly tone'."*

**Drives**: Layer 4 anti-references list.

Anti-references are equally important — they tell agents what to **reject**. Without D4, the rubric only knows what to chase, not what to avoid. Push for at least 2 names.

### D5 — Per-domain quality definitions (optional, batched with D2/D3)

> *"For each domain you ship — one-line of what S-tier looks like. UI: '<X>'. API: '<Y>'. Code review: '<Z>'."*

**Drives**: Layer 4 per-domain quality anchors.

Most projects answer this implicitly through D1–D4. Ask explicitly only if user says *"we have different bars for different surfaces."*

---

## Phase E — Knowledge Graph (Layer 5) — 3–5 questions

### E1 — `docs/` root convention

**Skip-if-Phase-1**: if `docs/` already exists with content, confirm: *"Your `docs/` has `<existing structure>`. Keep + extend, or reorganize per the standard 7-subdirectory taxonomy?"*

If no `docs/`:

> *"I'll scaffold `docs/` at the repo root. Default subdirectories: `brainstorms/`, `specs/` (or `designs/` — pick one), `plans/`, `audits/`, `archive/{...}/`. Plus optional: `flows/`, `design-system/`, `research/`, `superpowers/{plans,specs}/`, `design-debt/`. Want any of the optionals? Or use a different root location (e.g. `notes/` instead of `docs/`)?"*

**Drives**: Layer 5 `docs/` root + subdirectory selection.

### E2 — Specs vs designs naming

> *"Spec convention: `docs/specs/<slug>-spec.md` or `docs/designs/<slug>-design.md`? Pick one and stay consistent."*

**Drives**: Layer 5 spec naming convention. Authority hierarchy table uses the picked convention.

### E3 — Capability map y/n

> *"Capability map at `docs/product/capabilities.md` is a stable-ID list of what users can currently do (e.g. `O.1`, `M.1`, etc.). Brainstorms, specs, audits reference these IDs. Default-on for shipped/mature projects; default-defer for greenfield/early. Yours: `<recommendation based on maturity>`. Confirm?"*

**Drives**: Layer 5 `docs/product/capabilities.md` scaffold.

For shipped/mature: scaffold + propose 3-5 initial capability IDs based on Phase 1 surface inventory.

For greenfield/early: scaffold empty (convention documented, entries empty). User fills as capabilities ship.

For research / library: skip the capability map. Different doc shape applies.

### E4 — Permanent docs needed

> *"Any permanent docs you want scaffolded (no date in filename, slug-only + 'Last verified' inside)? Common: `docs/design-system/README.md`, `docs/flows/<arc>.md` for canonical user journeys, `docs/architecture/<subsystem>.md` for substrate docs."*

**Drives**: Layer 5 optional subdirectories + permanent doc scaffold.

For greenfield: most projects skip — author them when there's content to document. Don't pre-scaffold empty permanent docs (they become wishlist docs that stay empty).

### E5 — Memory directory placement

> *"Where should cross-conversation memory live? Default: `~/.claude/projects/<project-slug>/memory/` (Claude Code default). Override only if you want project-local memory (uncommon)."*

**Drives**: Layer 3 memory-conventions doc + CLAUDE.md "Where to find what" memory pointer.

For 99% of cases: accept default. Override only if user has a specific reason.

---

## Phase F — Domain Kits (Layer 6) — 1–2 questions per applicable domain

### F1 — Applicability matrix confirmation

Show the user the applicability matrix derived from Phase 1 scan:

> *"Based on the project scan, here's what applies for Layer 6:*
>
> *- ✅ **design** — `<reason: e.g. components/ directory has React Native screens>`*
> *- ✅ **coding** — universal*
> *- ✅ **planning** — `<reason: multi-module changes are common>`*
> *- ❓ **testing** — `<no tests yet but `vitest` in deps. Skip or run?>`*
> *- ❌ **data** — `<no DB / no migrations>`*
> *- ❌ **ai-workflow** — `<no AI SDK deps>`*
> *- ❌ **native-bridge** — `<web-only, no `ios/` or `android/`>`*
> *- ❌ **pipeline-integrity** — `<no multi-stage pipelines>`*
>
> *Confirm? I'll then run the applied domains in sequence.*"

User accepts / overrides. Each skip is a deliberate call.

### F1.5 — Broadest runbook / master entry-point skill

> *"Is there a 'master runbook' for this project — the one document a developer would read from cold to understand how the codebase is organized? Knowledge-graph entry point + capability map + recent-activity summary all in one. If yes, name the broadest doc that does this today (default: `docs/README.md`). If no, I'll author one as the universal entry point under Layer 5."*

**Drives**: Layer 5 entry-point doc + Layer 6 substrate-runbook skill scaffold (e.g. a `product-context` / `product-atlas` / `runbook` skill that auto-loads on the broadest path glob and points into the knowledge graph).

**Discovered**: 2026-05-21 smoke test. The case-study had a `product-context` skill — the broadest-path-glob skill that fires on every owner/member/wizard/brainstorm file and routes the conversation to the right capability ID + canonical flow + recent audit. Without F1.5, bootstrap missed scaffolding this — and runbook-shaped skills are structurally hard to invent without explicit prompting.

**Three answers shape the output**:
- *"Yes — `docs/README.md` already does this"*: Layer 5 confirms and Layer 6 scaffolds a thin `runbook` / `project-context` skill that auto-loads broadly and points into `docs/README.md`.
- *"Yes but it's named differently"* (e.g. `docs/onboarding.md`, `OVERVIEW.md`): Layer 5 standardizes — propose moving to `docs/README.md` or preserve the user's chosen name + cross-link.
- *"No — please author one"*: Layer 5 authors `docs/README.md` per knowledge-graph principle + Layer 6 scaffolds the runbook skill referencing it.

**Skip-if-tiny-project**: if Phase 1 found < 50 source files AND no `docs/` AND solo: skip F1.5. A runbook skill earns its keep at scale; a 20-file solo project doesn't need it yet.

### F2 — Per-domain delegation

For each confirmed-applicable domain, bootstrap reads `skills/<domain>/SKILL.md` (sibling directory) and runs its Phase 1–5 sequence. Bootstrap pre-loads:

- Layer 1 identity (vision / ICP / production-vs-internal / stage)
- Layer 2 architecture (layer model / constraints)
- Layer 3 task classification (which task types apply)
- Layer 4 quality bar (Tier 1 + Tier 2 benchmarks)
- Layer 5 doc paths (audit / spec / plan paths)

These pre-loads mean each domain skill skips questions whose answers are already known from upstream layers. E.g. `/dotclaude:design`'s Q-B1 (Tier 1 chrome benchmarks) is already answered from Layer 4 — confirm in one sentence rather than re-asking.

Each domain interview: 3–6 questions, ~5–10 min. The design skill is the deepest (~17 questions, 53 knobs in v1, reduced to ~12 questions in v2 thanks to upstream pre-loads). Other domains are smaller.

**Total Layer 6 time**: ~20–30 min for 3–5 applied domains.

### F3 — Cross-domain merge surfacing

After all domains complete, show the user any cross-domain merges:

> *"Both Layer 4 (voice) and Layer 6 (design + coding) proposed forbidden phrases. Merged into one file at `.claude-staging/rules/forbidden-phrases.txt` — N total entries across 3 sections.*
>
> *Both Layer 4 (quality bar) and Layer 6 (design audit-routing) contributed to audit pipeline ordering. Merged into `.claude-staging/rules/audit-routing.md`.*"

---

## Phase G — Maintenance (Layer 7) — 1–2 questions (default-DEFERRED)

### G1 — Long-lived project y/n

> *"Layer 7 is a Saturday-style design-debt ritual — weekly 30-min cadence, batch decision interface (F/D/?/X marks), registry as canonical source. Default-defer for projects < 1 month OR solo+small. Default-on for projects > 3 months with active drift.*
>
> *Your project: `<maturity from A5>`. Recommend: `<defer-and-stub | activate | skip>`. Confirm?*"

**Drives**: Layer 7 mode (active / deferred-stub / skipped).

Decision tree:
- **< 1 month + solo + < 30 files** → recommend **skip entirely**. No artifact authored.
- **1–3 months + (solo OR team)** → recommend **deferred-stub**. Authors `.claude/_deferred/maintenance-ritual.md` + CLAUDE.md TODO reminder.
- **> 3 months + (team OR > 50 files)** → recommend **active**. Authors full Layer 7 artifacts.
- **Research prototype** → recommend **skip entirely**. Maintenance overhead exceeds value.

User can override the recommendation.

### G2 — Cadence + audit categories (only if active)

> *"Cadence: weekly (default) / biweekly / monthly. Time-box: 30 min (default). Audit categories — which detection mechanisms feed the registry?*
>
> *Defaults (per project shape):*
> *- UI-heavy → `design-token-auditor`, `skill-auditor`, `link-checker`*
> *- Backend-heavy → `data-auditor`, `skill-auditor`, `dependency-auditor`*
> *- Library → `api-surface-auditor`, `skill-auditor`*
> *- Docs site → `link-checker`, `skill-auditor`*
>
> *Customize?*"

**Drives**: Layer 7 cadence + audit-categories list.

Most projects accept the default. Customize only if user has specific preference.

### G3 — Skip Phase G entirely

If A5 said greenfield + < 30 files + solo: skip Phase G entirely. SKILL.md authors no Layer 7 artifact. Add a note in the final summary: *"Layer 7 skipped — re-run bootstrap in 2 months when the project crosses the activation threshold."*

---

## Summary turn (mandatory before authoring)

Before invoking Phase 3 (cross-layer coordination) + Phase 4 (stage + commit), summarize back what you captured:

> *"Based on our conversation:*
>
> ***Project identity (Layer 1)***
> *- Vision: `<one sentence>`*
> *- Wedge ICP: `<specific segment>`*
> *- Production-vs-internal: `<X>`*
> *- Stage: `<greenfield | early | shipped | mature>`*
> *- Moat: `<bullets | TBD>`*
> *- Anti-vision: `<bullets | none yet>`*
>
> ***Architecture (Layer 2)***
> *- Layer model: `<1-tier | 2-tier | N-tier>`*
> *- Stack: `<X>`*
> *- Boundaries: `<list or "single-tier — none">`*
> *- Constraints: `<list, with hook/rule binding>`*
>
> ***Process discipline (Layer 3)***
> *- Plan-driven y/n: `<X>` (threshold: `<Y>` if y)*
> *- Task classification: `<N>` rows including Ambiguous*
> *- Memory system: `<y/n>`*
> *- Verification ladder: `<X>`*
>
> ***Quality bar (Layer 4)***
> *- Tier 1 chrome: `<list>`*
> *- Tier 2 domain: `<list with dimensions>`*
> *- Anti-references: `<list>`*
> *- Demo audience: `<specific role/person>`*
>
> ***Knowledge graph (Layer 5)***
> *- `docs/` subdirectories: `<list>`*
> *- Specs naming: `<docs/specs/ | docs/designs/>`*
> *- Capability map: `<scaffold | empty | skip>`*
> *- Memory directory: `<path>`*
>
> ***Domain kits (Layer 6)***
> *- Apply: `<list>`*
> *- Skip: `<list with reasons>`*
>
> ***Maintenance (Layer 7)***
> *- Mode: `<active | deferred-stub | skipped>`*
> *- Cadence (if active): `<weekly | biweekly | monthly>`*
>
> *About to author the kit:*
> *- `CLAUDE.md.draft` (~`<estimated LOC>` LOC) with sections: `<list>`*
> *- `docs-staging/`: `<list of subdirs + README + capabilities scaffold if applicable>`*
> *- `.claude-staging/` artifacts: `<agent count>` agents, `<skill count>` skills, `<rule count>` rules, `<hook count>` hooks*
>
> *Bootstrap takes ~5–10 more min for authoring + staging + review. Sound right? Or revise something first?*

Wait for explicit "go" before authoring. Acceptable signals: *"ship it"* / *"yes"* / *"sounds right, proceed"*. Don't infer approval from silence or terse acknowledgment.

---

## Interview structure summary

| Phase | Layer | Topic | Questions | Phase-1 scan helps |
|---|---|---|---|---|
| A | 1 | Project Identity | 4–6 | Partial (age, contributors, files) |
| B | 2 | Architecture | 3–5 | Heavy (stack, dirs) |
| C | 3 | Process Discipline | 4–6 | Partial (tests, scripts) |
| D | 4 | Quality Bar | 4–6 | No (benchmarks are user-derived) |
| E | 5 | Knowledge Graph | 3–5 | Partial (existing docs/) |
| F | 6 | Domain Kits (delegates) | 1 + per-domain | Yes (applicability matrix auto-populates) |
| G | 7 | Maintenance | 1–2 (default-defer) | Partial (age + drift signals) |
| **Total** | | | **20–30** | |

### Batched super-questions for actual interview UX

The 20–30 sub-questions can be grouped into ~7–10 super-questions per turn for conversational pacing:

1. **Super-Q1** (Phase A1–A3): *"In one sentence — what is this and who's it for? Where does it ship? Production-user-facing or internal?"*
2. **Super-Q2** (Phase A4–A6): *"Solo / team? Project maturity (rough age + user count)? Moat — what's hard for a competitor to catch up to?"*
3. **Super-Q3** (Phase B): *"Confirm stack. Single-tier or multi? Any non-negotiable boundaries or constraints?"*
4. **Super-Q4** (Phase C): *"Plan-driven discipline? Common task types? Memory system y/n? Verification ladder for UI surfaces?"*
5. **Super-Q5** (Phase D): *"Demo audience. Tier 1 chrome benchmarks (2–3 apps). Tier 2 domain benchmarks (with dimension). Anti-references."*
6. **Super-Q6** (Phase E): *"docs/ structure — keep default 7-subdir taxonomy or customize? Capability map y/n? Memory directory location?"*
7. **Super-Q7** (Phase F1): *"Applicability matrix for Layer 6 — confirm or adjust."*
8. **Super-Q8** (per applicable domain): each domain skill's interview runs here, with upstream Layers 1–5 context pre-loaded. The design skill is the deepest; others are shorter.
9. **Super-Q9** (Phase G): *"Layer 7 maintenance — defer, activate, or skip?"*

7–9 super-questions × ~2–4 min each = ~20–30 min total interview. Add ~5–10 min for Layer 6 domain delegation. Total bootstrap session: ~25–40 min.

---

## How to use this script

- **One or two questions per turn**, conversational. The super-question batching above is fine for actual UX.
- **Skip ruthlessly.** If Phase 1's project scan answered, confirm in one sentence rather than asking. Phase 1 reliably handles 30–40% of all questions in brownfield projects.
- **Listen for off-script signal.** A user-volunteered *"our settings page got out of hand"* is gold for Layer 6 design's anti-patterns slot. Follow it.
- **Push gently on D2/D3/D4** (benchmarks) — these are the most load-bearing answers. Without named benchmarks, the kit has no anchors.
- **Honor skip / pause / go-back.** The user can interrupt at any layer. Don't barrel through.
- **Don't ask Phase G if A5 said greenfield + solo + < 30 files.** Skip entirely; Layer 7 doesn't apply at that scale.
- **End the interview when you have enough.** Don't grind through low-leverage questions if A–F already gave a rich picture; default sensibly and confirm in the summary.
- **The summary turn is the contract.** When you summarize back, the user should recognize THEIR project, not a templatized version of it. If they don't — go back and refine.

---

## Anti-patterns to avoid in the interview

- **Fire-hosing.** Asking 5+ questions in one turn. Pacing rule: 1–3 per turn.
- **Re-asking what Phase 1 already answered.** Signals lack of attention to the code; erodes trust.
- **Defaulting to design-heavy questions for non-UI projects.** A research prototype doesn't have a "primary surface" question. A CLI doesn't have a "demo to journalist" question. Adapt phase D to the project shape per Phase 1 signals.
- **Asking the moat question to a 1-week-old greenfield project.** They don't have an answer yet. Defer with `<MOAT_TBD>` placeholder.
- **Forcing maturity tag against project reality.** A project with 0 users is `[early]`, not `[shipped]`, even if the founder feels they've shipped. Be honest; the downstream layers calibrate against this answer.
- **Skipping the Ambiguous row in C2.** It's mandatory per `task-classification.md` depth bar. Don't ask the user; just include it.
- **Layer 4 with no anchored benchmarks.** *"Looks good"* is unenforceable. Push for at least 1 Tier 1 + 1 Tier 2-with-dimension, or skip Layer 4 entirely (research / library) with the skip logged.
- **Activating Layer 7 on a 2-week-old greenfield.** Premature activation produces empty registries; cadence runs against nothing; user loses trust in the ritual. Defer-and-stub or skip.
- **Implicit approval before authoring.** *"OK"* or silence is not approval. Wait for explicit *"go"* / *"ship it"* / *"yes proceed"*.

---

## Cross-references

- `SKILL.md` (same directory) — the orchestrator. Each Phase A–G here corresponds to an authoring block in SKILL.md Phase 2.
- `../../principles/project-identity.md` — Layer 1 substance + depth signatures.
- `../../principles/file-discipline.md` + `../../principles/decomposition.md` — Layer 2 file-size + decomposition discipline.
- `../../principles/task-classification.md` + `../../principles/plan-driven-work.md` + `../../principles/memory-system.md` — Layer 3 substance.
- `../../principles/quality-rubric.md` + `../../principles/design-benchmarking.md` — Layer 4 substance.
- `../../principles/knowledge-graph.md` — Layer 5 substance.
- `../../principles/audit-routing.md` + per-domain principles — Layer 6 routing + delegation.
- `../../principles/saturday-ritual.md` — Layer 7 substance + applicability gates.
- `../design/interview.md` — Layer 6 design domain's interview (the deepest — 17 questions, 53 knobs in v1). Bootstrap reuses it via delegation; doesn't restate.
