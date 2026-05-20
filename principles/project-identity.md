# project-identity — designing the identity layer for ANY project

Teaching material for Claude Code. When you bootstrap a project's AI dev infrastructure, this doc teaches you HOW to surface and write a project's identity into `CLAUDE.md` + `docs/product/vision.md`. The identity layer is read first by every downstream layer; getting it wrong means the architecture, process discipline, and quality bar all calibrate against the wrong target.

## When to ship one (applicability gate)

Ship a project-identity layer when:

- The project has more than one contributor (current or future). Identity scales the bigger the team gets.
- The project has external users, or expects to. Identity drives the priority lens — *"does feature X serve our ICP?"*
- The project has been alive > 2 weeks. Long enough that re-deriving "what is this?" every session has measurable cost.
- The project has any opinion at all about a moat or differentiation. Once a defensible niche exists, naming it forces clarity at the moment when clarity is cheapest.

Skip when:

- The project is < 1 week old AND the user has no opinion yet about ICP / moat / stage. Premature identity authoring locks in placeholder values that ossify. Defer until the user has *something* to say.
- The project is a one-file utility / personal scratchpad. Identity is overhead with no compounding return on a 50-LOC repo.
- The project is a research artifact tied to a paper / thesis — the paper IS the identity doc. Authoring a parallel one in `CLAUDE.md` creates drift.

The default bias is **ship**. Even a 3-line identity (one-paragraph vision + ICP placeholder + `<UNKNOWN>` moat) outperforms no identity, because the placeholders themselves prompt the user to fill them in over time. Empty identity is a request for clarity; absence of an identity layer is silent.

## Why it matters — what this catches that nothing else does

Without an explicit identity layer, three failure modes recur:

- **Re-derivation tax every session.** Each new conversation opens with 5-10 turns of *"what's the architecture? who's the user? what's the moat?"* The user re-explains the project; Claude re-derives the routing; context drifts. Multiplied across a year of sessions, this is hundreds of hours of preventable re-work.
- **Feature creep without a wedge.** When ICP is implicit, every feature feels equally valid. *"Should we add X?"* has no falsifiable answer. With a named wedge ICP (*"side-project developers who feel they're not shipping enough"*), the question becomes *"does X serve them?"* — falsifiable, decidable, defendable.
- **Quality bar drift.** A project without a stated stage (greenfield / early / shipped / mature) doesn't know what *"good enough"* means. Greenfield work that's calibrated against shipped-product polish wastes 3x the time. Shipped-product work calibrated against greenfield posture ships embarrassing surfaces.

Identity is also the layer that makes **negation possible**. An anti-vision (*"we are explicitly NOT building X"*) is just as load-bearing as the vision. Without negation, scope creep has no boundary. With a stated anti-vision, *"I want to add X"* gets a fast, principled *"no — see anti-vision."*

## Core methodology — six dimensions

The identity layer captures six dimensions. Each is a separate question; the user may answer some confidently and defer others. Defer is fine; conflate is not.

### Dimension 1 — Vision

**One paragraph** describing the product and its primary user. NOT a marketing tagline; a sentence Claude reads at the top of every session to ground its judgment. The product is described in terms of *what users do*, not what the tech is.

Good: *"A type-safe HTTP client for TypeScript that lets frontend developers replace raw `fetch()` calls with typed request/response shapes derived from their OpenAPI schema."*

Bad: *"A modern, scalable, developer-friendly HTTP library."* (Adjectives without nouns. Tells you nothing about what users do.)

### Dimension 2 — Wedge ICP

The *specific* initial customer segment. Not the TAM, not the eventual market — the *first* customers the product is calibrated for. Three properties make a wedge ICP usable:

- **Named industry / role / company-size**. "Developers" is not a wedge. "SREs at series-B SaaS companies running on Kubernetes" is.
- **Located**. If geography matters (early-stage products often have geographic wedges — *"premium specialty gyms in tech-dense cities, starting [city]"*), name the location.
- **Reachable**. Can you list 5 specific candidate customers by name? If not, the wedge isn't tight enough.

A good wedge survives the *"would feature X serve them?"* test on every proposed feature. A bad wedge devolves into *"well, it could help some users..."* — which means it doesn't constrain anything.

### Dimension 3 — Moat

What's hard for a competitor to replicate. Drives the *engine tax* lens: every feature either compounds the moat or doesn't. The moat statement has two parts:

- **What IS the moat**. One or two bullets, named specifically. *"User-uploaded corpus that compounds over time + per-user fine-tuning that's gated by months of usage history."*
- **What is NOT the moat**. Equally important. *"The UI itself is replicable in a quarter. The pricing model is replicable in a week. The brand is replicable when a competitor has comparable scale."*

The negation is load-bearing. Without it, every feature feels moat-relevant; budget gets spent on UI polish that any competitor can reproduce. With it, *"this UI change doesn't compound the moat"* becomes a deliberate trade-off, not an oversight.

For early-stage projects, `<MOAT_TBD>` is a valid placeholder. Don't invent a moat to fill the slot.

### Dimension 4 — Production-vs-internal

A binary with hugely different downstream calibration:

- **Production** — ships to external users; needs verification ladders, design polish, quality bar anchored to consumer references (Linear, Stripe, Apple, Telegram, etc.).
- **Internal tool** — used by the team; targets *credible*, not S-tier. Lighter verification, lower polish bar, faster iteration.
- **Library / SDK** — used by other developers; quality bar is API ergonomics + docs + types, NOT visual design.
- **Research prototype** — used by the researcher + maybe a collaborator; quality bar is *"produces interpretable output"*. Most quality discipline is overhead.

Pick one. The downstream layers (architecture, process, quality bar) calibrate against this answer.

### Dimension 5 — Solo-vs-team

Solo developers can skip multi-author coordination conventions (PR review etiquette, commit-message verbosity, branching strategy). Team projects need them. The threshold for *"team"* is ≥ 2 developers writing code regularly, not just collaborators commenting on issues.

Solo + plans-to-stay-solo and solo + plans-to-onboard-collaborators-in-3-months are different cases. The latter benefits from team-ready discipline early — retrofitting is harder than greenfield habits.

### Dimension 6 — Maturity

A four-state taxonomy that drives which layers even apply:

- **Greenfield** (< 2 weeks, no users yet). Skip Layer 7 maintenance. Skip capability map. Lightweight identity (vision + ICP placeholder).
- **Early prototype** (2 weeks – 3 months, internal use or 1-5 users). Layer 7 deferred-stub. Capability map scaffolded.
- **Shipped** (> 3 months, > 5 users). Full layers active. Capability map populated.
- **Mature** (> 1 year, > 50 users OR meaningful revenue). All layers + maintenance ritual active. Anonymization guard if any chance of going open.

Maturity is what the project IS, not what the founder wishes it were. Be honest. Pretending mature-stage discipline on a 2-week prototype produces noise that drives the team off the discipline entirely.

## How to derive THIS project's specifics

Before authoring the identity layer, gather:

1. **The product description from the user**. Ask: *"In one paragraph — what is this, who's it for? Pretend you're explaining to a developer friend who's curious."* If they hand you a tagline, dig for the underneath — taglines are aspirational; the identity layer needs the actual underneath.

2. **The wedge ICP via the 3-property test**. Ask: *"Who are the first 5 specific customers you'd want? Name them — companies, roles, or specific people."* If they can't name 5, the wedge is fuzzy — surface the fuzziness, suggest a sharper wedge by exclusion (*"so NOT enterprise, NOT consumer — that leaves mid-market B2B SaaS"*).

3. **The moat via the differentiation test**. Ask: *"If a well-funded competitor saw your product on Product Hunt tomorrow and decided to clone it — what would take them 3 months to catch up to? What couldn't they ever catch up to?"* The first answer is the moat-shaped differentiator; the second answer is the moat. Both matter; the second is the load-bearing one.

4. **The anti-vision**. Ask: *"What's adjacent that you're explicitly NOT building? What kind of feedback would you reject?"* This question is often more illuminating than the vision question — founders who can articulate what they're not building usually have clearer identity than those who can only articulate what they are.

5. **Production-vs-internal from the deployment target**. *"Where does this ship — App Store? Open-source registry? Internal dashboard? Notebook in your laptop?"* The deployment target unambiguously implies the category.

6. **Solo-vs-team from `git log --format='%an' | sort -u`**. Count unique authors. If 1, it's solo. If > 1, ask whether the others are active or historical.

7. **Maturity from `git log --oneline | wc -l` + `git log --format='%ai' | tail -1` + user disclosure of user count**. Project age + commit count + user count → maturity tag.

## Authoring guidance — what to write into the final artifact

The identity layer lands in TWO files:

### File 1 — `CLAUDE.md` opening section (~30-80 LOC)

The first section of `CLAUDE.md`, before architecture. Read by Claude at the start of every session. Format:

```markdown
# <PROJECT_NAME>

<ONE_PARAGRAPH_PRODUCT_DESCRIPTION>

**ICP (wedge):** <SPECIFIC_INITIAL_SEGMENT>
**Production-vs-internal:** <PRODUCTION | INTERNAL | LIBRARY | PROTOTYPE>
**Stage:** <GREENFIELD | EARLY | SHIPPED | MATURE>
**Pace:** <NO_DEADLINE | RUNWAY_BOUND | FUNDRAISE_WINDOW | LAUNCH_WINDOW>

## Moat

- <MOAT_BULLET_1> — <one sentence>
- <MOAT_BULLET_2> — <one sentence>

What is NOT the moat (don't invest as if it were):
- <NOT_MOAT_1>
- <NOT_MOAT_2>

## Anti-vision

- <NOT_BUILDING_1>
- <NOT_BUILDING_2>
```

Stable phrasing patterns that battle-test well:

- *"This project's job is X."* — survives every other context-load. Direct, declarative, no marketing.
- *"Primary product + optionality on one codebase."* — for projects with a lead product and a secondary upside.
- *"The intelligence layer for [niche]."* — three-word positioning that survives every read.
- *"Wedge: [specific segment]. Then: [expansion path]."* — names what's first AND what's planned.
- *"Moat = [substrate] + [compounding signal]."* — names both static and dynamic moat components.

### File 2 — `docs/product/vision.md` (~200-400 LOC, optional)

Only ship when the identity has nuance worth the longer form. For a 2-week-old prototype, skip — CLAUDE.md opening is enough. For a shipped product with strategic posture (stealth / public / fundraise / acquihire-shaped), the longer doc is load-bearing. Sections:

- Full product narrative — multi-paragraph version of the vision.
- Strategic posture — stealth, public, fundraise window, acquihire-shaped, etc.
- ICP expansion — wedge + adjacent + future segments with the order they unlock.
- Moat deep dive — why each moat component is defensible; what could invalidate it.
- Anti-vision deep dive — what we're explicitly NOT building, with rationale per item.
- Decision log — when vision shifts, the date + reason + what changed.

### When to add a capability map (`docs/product/capabilities.md`)

The capability map is a stable-ID list of *what users can currently do* (e.g. `O.1`, `O.2`, `M.1`). Ship one ONLY when the project is past `greenfield` AND has 5+ user-facing capabilities AND the team references "feature X" enough times that stable IDs would help.

For greenfield / early-stage / library / research projects: skip the capability map entirely or scaffold an empty one with the ID convention documented. Authoring it before there's something to index produces a doc that's a placeholder forever.

When you ship one, the entry format is:

```markdown
### <ID> <Name> [status]
> <One-sentence goal: user can X to achieve Y.>
**Deep refs:** <where the canonical doc lives>
**Constraint:** <preconditions or blockers — only if non-trivial>
```

Status tags: `[shipped]`, `[partial]`, `[planned]`, `[deferred]`. The map evolves with the product; entries are added when capabilities ship, not when they're planned (or use `[planned]` if scaffolding ahead).

## Depth signatures — what battle-tested looks like

The authored identity layer fails the depth bar if it lacks any of these signals. The opening sentence shows whether the author treated identity as marketing or as Claude-grounding.

1. **Vision is one sentence, not three paragraphs.** Identity is read every session; brevity protects attention. If the user's draft runs long, push back: *"can we compress to one sentence?"* The shorter version forces clarity.

2. **ICP is named specifically.** Industry + company size + role minimum. *"Developers"* fails; *"SREs at series-B SaaS companies running on Kubernetes"* passes. If geography matters, named.

3. **Moat is named with what's NOT-the-moat called out**. Without negation, every feature feels moat-relevant. With it, *"this is not the moat — defer"* becomes a fast call.

4. **Anti-vision exists**. At least 2-3 bullets of *"we are NOT building X"*. Without it, scope has no boundary.

5. **Production-vs-internal tag is unambiguous**. One of the four categories, not a hybrid. Hybrids drift toward whichever quality bar the author prefers; tag the dominant case.

6. **Stage tag matches reality**. A `[shipped]` project with 0 paying users is `[early]`, not shipped. Be honest. The downstream layers calibrate against this.

7. **Pace tag exists**. Even `no_deadline` is useful — drives the prototype-gate / customer-truth posture rather than artificial urgency. If there's a real deadline (launch, fundraise window), name it; pace gets quoted in priority decisions.

8. **DoD includes verification ladder + plan-driven discipline references**. The Definition-of-Done section at the bottom of CLAUDE.md should reference the verification ladder (Lesson 8) and plan-driven conformance matrix discipline (Lesson 4) — not duplicate them, point to them.

9. **No marketing copy**. Identity is operational, not promotional. *"We believe in X"* fails the test. *"This project's job is X"* passes.

10. **Cross-refs to other layers exist**. *"For architecture, see `CLAUDE.md` Architecture section. For task classification, see [link]. For quality bar, see `.claude/rules/design-north-star.md`."* Identity is the entry point; it points to the rest.

If the authored identity layer lacks any of these, redo. The cost of a re-derive every session for a year is a hundred-fold more than the cost of authoring identity correctly once.

## Anti-patterns to avoid

- **Marketing-copy identity**. *"A revolutionary new way to..."* — every word is noise. Strip adjectives. Replace with what users do.

- **Aspirational moat**. *"Our moat will be the community we build."* If you don't have the community yet, that's not a moat — it's a plan. Tag honestly: `<MOAT_TBD>` is better than overstated moat.

- **ICP that's everyone**. *"Developers"* / *"businesses"* / *"users"* — these aren't wedges, they're total addressable markets. Push for the specific first segment.

- **Identity that doesn't change downstream behavior**. Test: read the identity, then read the architecture section. If the identity didn't constrain any architectural choice, the identity is decorative. Rewrite identity so it forces choices downstream.

- **Capability map authored before capabilities exist**. Scaffolding the doc is fine; populating it with planned-only entries creates a doc that's a wishlist, not a map. Wait until capabilities ship.

- **Identity that doesn't get updated**. Identity is supposed to be relatively stable, but *strategy shifts*. When the project pivots, the identity layer updates same-day, with a decision-log entry. An identity layer 6 months out of date is worse than no identity layer (it actively misleads).

- **Multiple identity docs without a single source of truth**. `README.md` + `CLAUDE.md` + `docs/product/vision.md` + `docs/strategy.md` all claiming authority on the vision = guaranteed drift. Pick ONE primary source (CLAUDE.md opening is usually the right call). Others cross-reference.

- **Hiding the stage tag because it's embarrassing**. *"We're shipped"* on a project with 0 users serves nobody. Stage tag governs downstream quality calibration; being honest saves 10x more time than the discomfort costs.

- **Vision that requires reading other docs to understand**. The opening paragraph should stand alone. If a reader needs to load three other files to understand what the product is, the vision has failed at its job.

## Cross-references

- `knowledge-graph.md` — Layer 5 conventions. The identity layer in `CLAUDE.md` is the entry point to the knowledge graph; this principle teaches what entry-point content looks like.
- `task-classification.md` — Layer 3 routing table that lives in `CLAUDE.md` directly below the identity section. The two are co-located on purpose; identity grounds the routing.
- `quality-rubric.md` — Layer 4 grading. The identity's production-vs-internal tag and stage tag drive what S-tier means.
- `plan-driven-work.md` — Layer 3 process discipline. Identity references DoD; DoD references plan-driven discipline.
- `memory-system.md` — Layer 3 memory typing. Identity-shaped facts (user info, product context) land in user / project memory typed correctly.
