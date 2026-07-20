# `/dotclaude:bootstrap` interview

The interview that drives the thin-generator bootstrap. Under dotclaude v3 consume-direct, the universal base — process discipline (the `operating-discipline` skill) and the auditor agents / domain kits — is **consumed from the plugin, not authored by bootstrap.** So the interview covers ONLY the four un-shareable project-specific layers: **A Identity, B Architecture, D Quality Bar, E Knowledge Graph.** Phases C (process) and F (domain kits) were removed because they're consumed — the A/B/D/E letters are kept as-is so they still map to SKILL.md's Phase references.

Four phases, ~12–20 questions total, ~16–28 min wall clock for greenfield, ~10–18 min for brownfield in APPEND mode.

**Pacing rule**: 1–3 questions per conversational turn. Never fire-hose. Listen for off-script signal — a user-volunteered *"our settings page got out of hand"* is gold for the Quality Bar's anti-patterns slot.

**Skip discipline**: if a question's answer is obvious from Phase 1's project scan, do NOT ask — confirm in one sentence and move on. The cost of asking a redundant question is real (signals *"you weren't paying attention to my code"*).

**Adaptive depth**: each phase has a default question count. Reduce when Phase 1 pre-populated; expand only when the user gives volunteered signal. Greenfield runs need fewer pre-populates and more questions; brownfield runs the inverse.

**Pause-and-confirm gate**: after each phase, the SKILL.md flow stages that phase's artifact and asks whether to move to the next. The user can interrupt, revise, or skip the next phase.

---

## Phase A — Project Identity — 4–6 questions

### A0 — Mode confirmation (only if brownfield detected)

If Phase 1 §1.3 found existing `CLAUDE.md` / `docs/` / `.claude/`:

> *I noticed you already have <CLAUDE.md / docs/ / .claude/>. Three modes available:*
>
> *- **Append mode** (default): I'll add only the missing layers; existing content stays untouched. You diff per-section before commit.*
> *- **Audit mode**: I read your existing infra and produce a gap report; no writes.*
> *- **Fresh-overwrite mode** (destructive): I author the project-specific layers (identity / architecture / quality bar / knowledge graph) from scratch into staging; you diff before commit; the existing content gets replaced.*
>
> *Which?*

Default to APPEND. If the existing CLAUDE.md is > 200 LOC AND structured (all major sections present), recommend REFUSE per SKILL.md "Brownfield handling" — *"Recommend `/dotclaude:audit` or per-layer commands instead. Want to proceed with fresh-overwrite anyway?"*

Wait for explicit mode pick. The rest of Phase A is unchanged.

### A1 — One-sentence product description

> *"In one sentence: what is this, who's it for? Pretend you're explaining to a developer friend who's curious."*

**Drives**: the vision opening sentence + downstream task classification calibration.

**Listen for**: marketing copy. If the answer is *"a revolutionary new way to..."* or *"the modern X for Y"*, push back gently: *"Strip the adjectives — what do users DO with this?"* The opening sentence battle-tests when it has a noun + verb + user, not when it has marketing register.

**Skip-if-Phase-1**: if README.md opens with a clear one-paragraph description, confirm in one sentence: *"Your README says `<X>` — is that still the right framing, or has it shifted?"*

### A1.5 — Secondary product framing (optional, ~30 sec)

> *"In ONE more sentence, what makes this project hard or different from the obvious-looking version of it? Skip if your A1 already captures it. (Common shape: 'X with optionality on Y' — e.g. 'a gym vertical, with the spatial engine generalizing to other venues as optionality.' Captures the moat hint without committing the moat.)"*

**Drives**: the secondary-product framing — distinct from A6 moat. A1 captures purpose; A1.5 captures the "primary product + optionality" structure if it exists. Useful for CLAUDE.md Architecture (when the optionality has a code-shape implication, e.g. one codebase serving two products) AND for the Quality Bar register (one product may be S-tier register, the other credible-register).

**Listen for**: a user volunteering *"actually it's two things on one codebase"* or *"the underlying engine could generalize to..."* These are the signals A1 didn't fully capture. Most projects answer *"A1 already says it"* — that's fine. Don't force a second framing if there isn't one.

**Skip-if-volunteered-already**: if A1's answer already contains *"primary X + optionality Y"* / *"a vertical that uses an engine"* / *"two products on one codebase"* — confirm in one sentence and skip A1.5 question.

### A2 — Wedge ICP

> *"Who are the first 5 specific customers you'd want for this? Name them — companies, roles, or specific people. If you can't list 5 by name, the wedge is too fuzzy; tell me what you DO know and I'll help sharpen."*

**Drives**: the ICP line. Anchors every downstream "does feature X serve our users" question.

**3-property test** per `project-identity.md`:
- **Named** (industry / role / company-size).
- **Located** (if geography matters).
- **Reachable** (can list 5 by name).

If the user names ≥ 3, the wedge is workable. If they name 0–2, surface the fuzziness:

> *"It sounds like the wedge isn't fully crisp yet. That's fine — I'll write `<TENTATIVE_ICP>` in the identity section with a TODO. You can sharpen later. But noting the fuzziness now means downstream layers won't pretend it's resolved."*

### A3 — Production-vs-internal

> *"Where does this ship? App Store / public website / open-source registry / internal dashboard / notebook on your laptop?"*

**Drives**: the production-vs-internal tag. Anchors the quality-bar register (production = consumer-app benchmarks; internal = credible-not-S-tier; library = API ergonomics; research = produces-interpretable-output).

**Skip-if-Phase-1**: if the project is a public package on npm / PyPI / Cargo (visible in `package.json` `"name"` field + a `"main"` / `"bin"` / `"exports"` pattern), confirm: *"Looks like a public library — `<package-name>` on npm/PyPI/Cargo. Confirm production-library?"*

### A4 — Solo-vs-team

**Skip-if-Phase-1**: Phase 1 §1.4 already ran `git log --format='%an' | sort -u`. If 1 contributor, confirm: *"`git log` shows 1 contributor — solo, confirm?"*. If > 1, ask:

> *"`git log` shows N contributors. Are they all actively writing code, or some historical / collaborators-via-issues only? And — solo-staying-solo, or planning to add collaborators in the next 3 months?"*

**Drives**: the maturity/stage tag (A5) + downstream calibration. (Team coordination conventions are consumed from the plugin — the `operating-discipline` skill — not authored here.)

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

**Drives**: the stage tag (and downstream quality-bar register calibration).

### A6 — Moat / differentiation (optional, defer-able)

> *"What would a well-funded competitor need 3 months to catch up to? What couldn't they ever catch up to?"*

**Drives**: the moat bullets + the NOT-the-moat negation.

The two-question form is intentional. *"Couldn't ever catch up to"* is the load-bearing answer (per `project-identity.md`); *"3 months to catch up to"* is the moat-shaped-differentiator (real but copyable).

If the user can't articulate a moat:

> *"Totally fine to defer. I'll write `<MOAT_TBD>` in the identity section with a comment. You can fill it in over the next few weeks of customer truth. The placeholder is better than an invented moat."*

`<MOAT_TBD>` is a valid output for greenfield / pre-product projects. Don't pressure.

---

## Phase B — Architecture — 3–5 questions

### B1 — Stack confirmation

**Skip-if-Phase-1**: Phase 1 §1.2 read `package.json` / `Cargo.toml` / `pyproject.toml`. Confirm in one sentence:

> *"Looks like `<language>` + `<framework>` + `<runtime>`. Confirm? Any major components I missed?"*

**Drives**: the stack + downstream domain applicability matrix.

### B2 — Layer model

> *"How would you describe the codebase's structure in 1–3 layers? Common patterns: single-tier (one app, one codebase), two-tier (e.g. shared/ + app/, or engine + vertical), N-tier (microservices, monorepo with N packages). Or is there a less-standard shape?"*

**Drives**: the architecture diagram + boundary detection.

For most greenfield projects: single-tier is default. The question forces *naming* the implicit layers (e.g. *"core logic / presentation / I/O"* for a CLI, or *"models / controllers / views"* for a monolith). Naming makes the boundaries enforceable downstream.

### B3 — Boundaries

> *"Any non-negotiable boundaries? Examples: 'lib/ never imports from app/', 'frontend never imports from backend/', 'domain doesn't know about infrastructure.' If yes — name them; I'll author a hook + rule per boundary. If unclear — fine to defer."*

**Drives**: the boundary rules + boundary hooks.

If the user says *"not really"*: ship only the universal file-size hook + rule. Don't invent boundaries.

If the user names ≥ 1 boundary: confirm greppability (*"can this boundary be expressed as a grep pattern over import statements?"*). Greppable boundaries get a hook; non-greppable boundaries get a rule only.

### B4 — Constraints + file-size ceiling

> *"Any non-negotiable constraints? Examples: file-size ceiling (1000 LOC for TS / 500 for Python / 800 for Rust / 600 for Go), no raw color literals, no `any` types, no inline styles. I'll author hooks + rules for each."*

**Drives**: the constraints bullets + per-constraint hook/rule.

**Universal default**: ship `check-file-size.sh` at the project-language-appropriate ceiling unless user opts out. Don't ask if they want it — propose, accept opt-out.

**Skip-if-Phase-1**: if Phase 1 found existing hooks (`.claude/hooks/`), confirm: *"You already have `<X.sh>` and `<Y.sh>`. I'll keep those; want to add the universal file-size hook on top?"*

### B5 — External integrations (no separate interview)

Don't ask here. The integrations (Supabase, Stripe, OpenAI, AI SDK) get caught by Phase 1 §1.7 + §1.8 + §1.9. They inform which of the plugin's consumed auditor agents the project will actually dispatch (e.g. a DB may warrant the deferred data domain, once it ships) — but the auditors are consumed from the plugin, so there's no per-domain interview to feed.

---

## Phase D — Quality Bar — 2–4 questions

The quality bar splits by surface, and after the two-plugin split bootstrap owns only the **non-design** half:

- **Visual / UX / design benchmarks** (chrome references, domain references, anti-references) belong to the companion **dotclaude-design** plugin. **If Phase 1 found a human-facing UI surface, do NOT interview for visual benchmarks here** — tell the user to run `/dotclaude:design`, which elicits them and writes `.claude/rules/design-north-star.md` + `.claude/rules/design-system.md` for the consumed design audits to read. Bootstrap authors no `<domain>-north-star.md` for UI; it only records that the design north-star is owned there.
- **Non-design quality bar** (API ergonomics, CLI, library output) — bootstrap authors `api-north-star.md` here, for the parts of the project with no visual surface to benchmark.

### D1 — Demo test framing (generic — any surface)

> *"Who would you demo a polished change to — be specific. Name the role or person. ('A friend's customer I'm recruiting as customer #2', 'a journalist writing about us', 'a CTO at a target enterprise', 'a designer whose taste I respect', 'my dad'.)"*

**Drives**: the demo-test framing + the quality-bar register (production = consumer-grade; internal = credible-not-S-tier; library = API ergonomics). Applies whether or not the project has UI.

The specificity matters. *"Users"* fails the test; *"a CTO at a target enterprise during a 30-min sales call"* passes.

### D2 — Non-design benchmarks (only where there's a non-visual surface to benchmark)

> *"For the non-visual surfaces — your API, CLI, or library — name 2–3 references you benchmark against, each with the dimension. 'React Query for hook ergonomics', 'Zod for type-narrowing', 'requests-Python for readability', 'Stripe for API design', 'gh for CLI first-run'."*

**Drives**: the `api-north-star.md` benchmarks with named dimensions. The dimension is load-bearing — *"we like Stripe"* is useless; *"Stripe for API-key rotation ergonomics"* is enforceable.

**If the project is UI-only** (no meaningful API / CLI / library surface): skip this — there is no non-design bar to author, and the visual bar is `/dotclaude:design`'s job. Point the user there and move on. Pure-backend / library / research projects: this is the whole quality bar.

### D3 — Per-domain quality definitions (optional)

> *"If you hold different bars for different non-visual surfaces — one line each of what S-tier looks like. API: '<Y>'. CLI: '<Z>'. Code review: '<W>'."*

**Drives**: the per-domain (non-design) quality anchors. Most projects answer this implicitly through D1–D2; ask explicitly only if the user says they hold different bars per surface.

---

## Phase E — Knowledge Graph — 3–5 questions

### E1 — `docs/` root convention

**Skip-if-Phase-1**: if `docs/` already exists with content, confirm: *"Your `docs/` has `<existing structure>`. Keep + extend, or reorganize per the standard 7-subdirectory taxonomy?"*

If no `docs/`:

> *"I'll scaffold `docs/` at the repo root. Default subdirectories: `brainstorms/`, `specs/` (or `designs/` — pick one), `plans/`, `audits/`, `archive/{...}/`. Plus optional: `flows/`, `design-system/`, `research/`, `superpowers/{plans,specs}/`, `design-debt/`. Want any of the optionals? Or use a different root location (e.g. `notes/` instead of `docs/`)?"*

**Drives**: the `docs/` root + subdirectory selection.

### E2 — Specs vs designs naming

> *"Spec convention: `docs/specs/<slug>-spec.md` or `docs/designs/<slug>-design.md`? Pick one and stay consistent."*

**Drives**: the spec naming convention. Authority hierarchy table uses the picked convention.

### E3 — Capability map y/n

> *"Capability map at `docs/product/capabilities.md` is a stable-ID list of what users can currently do (e.g. `O.1`, `M.1`, etc.). Brainstorms, specs, audits reference these IDs. Default-on for shipped/mature projects; default-defer for greenfield/early. Yours: `<recommendation based on maturity>`. Confirm?"*

**Drives**: the `docs/product/capabilities.md` scaffold.

For shipped/mature: scaffold + propose 3-5 initial capability IDs based on Phase 1 surface inventory.

For greenfield/early: scaffold empty (convention documented, entries empty). User fills as capabilities ship.

For research / library: skip the capability map. Different doc shape applies.

### E4 — Permanent docs needed

> *"Any permanent docs you want scaffolded (no date in filename, slug-only + 'Last verified' inside)? Common: `docs/design-system/README.md`, `docs/flows/<arc>.md` for canonical user journeys, `docs/architecture/<subsystem>.md` for substrate docs."*

**Drives**: the optional subdirectories + permanent doc scaffold.

For greenfield: most projects skip — author them when there's content to document. Don't pre-scaffold empty permanent docs (they become wishlist docs that stay empty).

### E5 — Memory directory placement

> *"Where should cross-conversation memory live? Default: `~/.claude/projects/<project-slug>/memory/` (Claude Code default). Override only if you want project-local memory (uncommon)."*

**Drives**: the CLAUDE.md "Where to find what" memory pointer (the only project-specific piece). The memory conventions themselves are Claude Code's built-in behavior, not authored by dotclaude — bootstrap just records where this project's memory lives.

For 99% of cases: accept default. Override only if user has a specific reason.

---

## Summary turn (mandatory before authoring)

Before invoking SKILL.md Phase 3 (stage → review → commit), summarize back what you captured:

> *"Based on our conversation:*
>
> ***Project identity***
> *- Vision: `<one sentence>`*
> *- Wedge ICP: `<specific segment>`*
> *- Production-vs-internal: `<X>`*
> *- Stage: `<greenfield | early | shipped | mature>`*
> *- Moat: `<bullets | TBD>`*
> *- Anti-vision: `<bullets | none yet>`*
>
> ***Architecture***
> *- Layer model: `<1-tier | 2-tier | N-tier>`*
> *- Stack: `<X>`*
> *- Boundaries: `<list or "single-tier — none">`*
> *- Constraints: `<list, with hook/rule binding>`*
>
> ***Quality bar***
> *- Demo audience: `<specific role/person>`*
> *- Non-design bar (`api-north-star.md`): `<references with dimensions | n/a — UI-only>`*
> *- Design bar: `<owned by dotclaude-design — run /dotclaude:design | n/a — no UI>`*
>
> ***Knowledge graph***
> *- `docs/` subdirectories: `<list>`*
> *- Specs naming: `<docs/specs/ | docs/designs/>`*
> *- Capability map: `<scaffold | empty | skip>`*
> *- Memory directory: `<path>`*
>
> *(Process discipline and domain auditor kits are consumed from the dotclaude plugin — not authored here, so they're not summarized.)*
>
> *About to author the kit:*
> *- `CLAUDE.md.draft` (~`<estimated LOC>` LOC) with sections: `<list>`*
> *- `docs-staging/`: `<list of subdirs + README + capabilities scaffold if applicable>`*
> *- `.claude-staging/` artifacts: `<rule count>` rules (`dotclaude.yml`, `api-north-star.md` if applicable), `<hook count>` project boundary hooks — no agents/skills (those are consumed from the plugins)*
>
> *Bootstrap takes ~5–10 more min for authoring + staging + review. Sound right? Or revise something first?*

Wait for explicit "go" before authoring. Acceptable signals: *"ship it"* / *"yes"* / *"sounds right, proceed"*. Don't infer approval from silence or terse acknowledgment.

---

## Interview structure summary

Only the four project-specific phases are interviewed. Phases C (process) and F (domain kits) are **removed because they're consumed from the dotclaude plugin** — the `operating-discipline` skill and the auditor agents respectively. The A/B/D/E letters are kept as-is so they still map to SKILL.md's Phase references.

| Phase | Topic | Questions | Phase-1 scan helps |
|---|---|---|---|
| A | Project Identity | 4–6 | Partial (age, contributors, files) |
| B | Architecture | 3–5 | Heavy (stack, dirs) |
| ~~C~~ | ~~Process Discipline~~ | — | consumed (`operating-discipline` skill) |
| D | Quality Bar (non-design; UI → `/dotclaude:design`) | 2–4 | No (benchmarks are user-derived) |
| E | Knowledge Graph | 3–5 | Partial (existing docs/) |
| ~~F~~ | ~~Domain Kits~~ | — | consumed (auditor agents) |
| **Total** | | **12–20** | |

### Batched super-questions for actual interview UX

The 12–20 sub-questions can be grouped into ~4–6 super-questions per turn for conversational pacing:

1. **Super-Q1** (Phase A1–A3): *"In one sentence — what is this and who's it for? Where does it ship? Production-user-facing or internal?"*
2. **Super-Q2** (Phase A4–A6): *"Solo / team? Project maturity (rough age + user count)? Moat — what's hard for a competitor to catch up to?"*
3. **Super-Q3** (Phase B): *"Confirm stack. Single-tier or multi? Any non-negotiable boundaries or constraints?"*
4. **Super-Q4** (Phase D): *"Demo audience. Non-design benchmarks — API / CLI / library references, each with its dimension. (If the project has a UI surface, don't ask for visual benchmarks here — point the user at `/dotclaude:design`.)"*
5. **Super-Q5** (Phase E): *"docs/ structure — keep default subdir taxonomy or customize? Spec/design naming? Capability map y/n? Memory directory location?"*

4–6 super-questions × ~2–4 min each = ~18–30 min total interview. (Process / domain are consumed from the plugin, so there's no per-domain delegation pass.) Total bootstrap session: ~22–35 min.

---

## How to use this script

- **One or two questions per turn**, conversational. The super-question batching above is fine for actual UX.
- **Skip ruthlessly.** If Phase 1's project scan answered, confirm in one sentence rather than asking. Phase 1 reliably handles 30–40% of all questions in brownfield projects.
- **Listen for off-script signal.** A user-volunteered *"our settings page got out of hand"* is gold for the Quality Bar's anti-patterns slot. Follow it.
- **Push gently on D2/D3** (benchmarks) — these are the most load-bearing answers. Without named benchmarks, the consumed auditor agents have no anchors to grade against.
- **Honor skip / pause / go-back.** The user can interrupt at any phase. Don't barrel through.
- **Don't interview process / domain.** They're consumed from the plugin (`operating-discipline`, the auditor agents) — bootstrap authors only the project-specific A/B/D/E layers.
- **End the interview when you have enough.** Don't grind through low-leverage questions if A/B/D/E already gave a rich picture; default sensibly and confirm in the summary.
- **The summary turn is the contract.** When you summarize back, the user should recognize THEIR project, not a templatized version of it. If they don't — go back and refine.

---

## Anti-patterns to avoid in the interview

- **Fire-hosing.** Asking 5+ questions in one turn. Pacing rule: 1–3 per turn.
- **Re-asking what Phase 1 already answered.** Signals lack of attention to the code; erodes trust.
- **Defaulting to design-heavy questions for non-UI projects.** A research prototype doesn't have a "primary surface" question. A CLI doesn't have a "demo to journalist" question. Adapt phase D to the project shape per Phase 1 signals.
- **Asking the moat question to a 1-week-old greenfield project.** They don't have an answer yet. Defer with `<MOAT_TBD>` placeholder.
- **Forcing maturity tag against project reality.** A project with 0 users is `[early]`, not `[shipped]`, even if the founder feels they've shipped. Be honest; the downstream layers calibrate against this answer.
- **Skipping the Ambiguous row in the task-classification table.** That table is authored into CLAUDE.md's "How You Work" (per SKILL.md) and its Ambiguous row is mandatory per `task-classification.md` depth bar. Don't ask the user; just include it.
- **Quality bar with no anchored benchmarks.** *"Looks good"* is unenforceable. Push for at least 1 Tier 1 + 1 Tier 2-with-dimension, or skip the quality bar entirely (research / library) with the skip logged.
- **Re-authoring a consumed layer.** Process discipline and the auditor agents come from the plugin. Don't interview for them or write local copies — that defeats consume-direct and creates drift.
- **Implicit approval before authoring.** *"OK"* or silence is not approval. Wait for explicit *"go"* / *"ship it"* / *"yes proceed"*.

---

## Cross-references

- `SKILL.md` (same directory) — the orchestrator. The kept phases here (A Identity, B Architecture, D Quality Bar, E Knowledge Graph) each correspond to an authoring block in SKILL.md Phase 2. Process / domain / maintenance are consumed from the plugin, not authored.
- `../../principles/project-identity.md` — identity substance + depth signatures.
- `../../principles/file-discipline.md` + `../../principles/decomposition.md` — architecture file-size + decomposition discipline.
- `../../principles/quality-rubric.md` — quality-bar substance. The design north-star / benchmarking elicitation (naming Tier 1 + Tier 2 references) is owned by the separate `dotclaude-design` plugin, not authored here — point the user at that plugin's own bootstrap if they want it.
- `../../principles/task-classification.md` — the task-classification table authored into CLAUDE.md's "How You Work" (E5 / SKILL.md), including the mandatory Ambiguous row.
- **Consumed from the plugin (not interviewed):** the `operating-discipline` skill (process discipline) and the auditor agents (domain kits). Bootstrap does not re-author these.
