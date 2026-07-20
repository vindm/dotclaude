# project-identity — designing the identity layer for ANY project

Teaching material for Claude Code. Teaches you how to surface and write a project's identity into `CLAUDE.md` + `docs/product/vision.md`. Identity is read first by every downstream layer; getting it wrong means the architecture, process discipline, and quality bar all calibrate against the wrong target.

## When to ship one

Ship a project-identity layer when the project has more than one contributor (current or future), has (or expects) external users, has been alive > 2 weeks (long enough that re-deriving "what is this?" every session has real cost), or has any opinion about a moat — naming it forces clarity at the moment clarity is cheapest. Skip when the project is < 1 week old and the user has no opinion yet about ICP / moat / stage (premature identity locks in placeholders that ossify), when it's a one-file utility / scratchpad, or when it's a research artifact tied to a paper (the paper IS the identity doc; a parallel one drifts).

**Default: ship.** Even a 3-line identity (one-paragraph vision + ICP placeholder + `<MOAT_TBD>`) beats none, because the placeholders themselves prompt the user to fill them over time. Empty identity is a request for clarity; no identity layer is silent.

## Why it matters

Without an explicit identity layer, three failure modes recur:

- **Re-derivation tax every session** — each conversation opens with 5-10 turns of *"what's the architecture? who's the user? what's the moat?"* Across a year, hundreds of hours of preventable re-work.
- **Feature creep without a wedge** — when ICP is implicit, every feature feels equally valid and *"should we add X?"* has no falsifiable answer. A named wedge (*"side-project developers who feel they're not shipping enough"*) turns it into *"does X serve them?"* — decidable.
- **Quality-bar drift** — a project without a stated stage doesn't know what "good enough" means. Greenfield work calibrated against shipped-product polish wastes 3× the time; shipped work calibrated against greenfield posture ships embarrassing surfaces.

Identity is also what makes **negation possible**: an anti-vision (*"we are explicitly NOT building X"*) is as load-bearing as the vision. Without it, scope creep has no boundary; with it, *"I want to add X"* gets a fast, principled *"no — see anti-vision."*

## Core methodology — six dimensions

Six dimensions, each a separate question. The user may answer some confidently and defer others — defer is fine, conflate is not.

**1 — Vision.** One paragraph describing the product and its primary user — not a marketing tagline, a sentence Claude reads at the top of every session to ground its judgment, framed in terms of *what users do*, not what the tech is. Good: *"A type-safe HTTP client for TypeScript that lets frontend developers replace raw `fetch()` calls with typed request/response shapes derived from their OpenAPI schema."* Bad: *"A modern, scalable, developer-friendly HTTP library."* (Adjectives without nouns — tells you nothing about what users do.)

**2 — Wedge ICP.** The *specific* initial segment, not the TAM. Three properties make it usable: **named** (industry / role / company-size — "developers" is not a wedge; "SREs at series-B SaaS companies running on Kubernetes" is), **located** if geography matters (*"premium specialty gyms in tech-dense cities, starting [city]"*), and **reachable** (can you name 5 candidate customers? if not, it's not tight enough). A good wedge survives the *"would feature X serve them?"* test on every proposed feature; a bad one devolves into *"well, it could help some users…"* and constrains nothing.

**3 — Moat.** What's hard to replicate — drives the *engine-tax* lens where every feature either compounds the moat or doesn't. Two parts: **what IS the moat**, named specifically (*"user-uploaded corpus that compounds over time + per-user fine-tuning gated by months of usage history"*), and **what is NOT**, equally important (*"the UI is replicable in a quarter; pricing in a week"*). The negation is load-bearing: without it, every feature feels moat-relevant and budget goes to replicable polish. For early-stage projects, `<MOAT_TBD>` is valid — don't invent a moat to fill the slot.

**4 — Production-vs-internal.** A category with hugely different downstream calibration: **production** (external users; verification ladders, design polish, quality anchored to consumer references — Linear, Stripe, Apple, Telegram), **internal tool** (team-used; *credible* not S-tier, lighter verification), **library / SDK** (used by other developers; quality is API ergonomics + docs + types, not visual design), **research prototype** (quality is *"produces interpretable output"*; most discipline is overhead). Pick one — the downstream layers calibrate against it.

**5 — Solo-vs-team.** Solo developers skip multi-author coordination (PR etiquette, commit verbosity, branching); teams need it. The threshold for "team" is ≥ 2 developers writing code regularly. Solo-staying-solo and solo-onboarding-in-3-months differ — the latter benefits from team-ready discipline early, since retrofitting is harder than greenfield habits.

**6 — Maturity.** A four-state taxonomy that drives which discipline even applies: **greenfield** (< 2 weeks, no users — skip the maintenance ritual and capability map, lightweight identity), **early prototype** (2 weeks–3 months, 1-5 users — maintenance deferred-stub, capability map scaffolded), **shipped** (> 3 months, > 5 users — full discipline, capability map populated), **mature** (> 1 year, > 50 users or meaningful revenue — all discipline + maintenance ritual, anonymization guard if it may go open). Maturity is what the project IS, not what the founder wishes — pretending mature discipline on a 2-week prototype produces noise that drives the team off the discipline entirely.

## How to derive THIS project's specifics

1. **Product description** — *"In one paragraph, what is this, who's it for? Explain it to a developer friend who's curious."* If they hand you a tagline, dig for the underneath.
2. **Wedge ICP via the 3-property test** — *"Name the first 5 specific customers you'd want — companies, roles, or people."* Can't name 5 → surface the fuzziness, suggest a sharper wedge by exclusion (*"so NOT enterprise, NOT consumer — that leaves mid-market B2B SaaS"*).
3. **Moat via the differentiation test** — *"If a well-funded competitor cloned you tomorrow, what would take 3 months to catch up to? What could they never catch up to?"* The first is the moat-shaped differentiator; the second is the load-bearing moat.
4. **Anti-vision** — *"What's adjacent that you're explicitly NOT building? What feedback would you reject?"* Often more illuminating than the vision question.
5. **Production-vs-internal from the deployment target** — *"Where does this ship — App Store? Open-source registry? Internal dashboard? Notebook on your laptop?"* The target implies the category unambiguously.
6. **Solo-vs-team from `git log --format='%an' | sort -u`** — count unique authors; if > 1, ask whether the others are active or historical.
7. **Maturity from `git log --oneline | wc -l` + `git log --format='%ai' | tail -1` + user-disclosed user count** — age + commits + users → the maturity tag.

## Authoring guidance — what to write into the final artifact

The identity layer lands in two files.

### File 1 — `CLAUDE.md` opening section (~30-80 LOC)

The first section, before architecture, read every session:

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

Phrasing patterns that battle-test well: *"This project's job is X"* (direct, declarative, no marketing); *"Primary product + optionality on one codebase"* (a lead product with a secondary upside); *"The intelligence layer for [niche]"* (three-word positioning); *"Wedge: [segment]. Then: [expansion path]"* (names what's first and what's planned); *"Moat = [substrate] + [compounding signal]"* (static + dynamic components).

### File 2 — `docs/product/vision.md` (~200-400 LOC, optional)

Ship only when the identity has nuance worth the longer form — skip for a 2-week prototype (the CLAUDE.md opening is enough); ship for a shipped product with strategic posture (stealth / public / fundraise / acquihire-shaped). Sections: full product narrative, strategic posture, ICP expansion (wedge + adjacent + future, in unlock order), moat deep dive (why each component is defensible; what could invalidate it), anti-vision deep dive (per-item rationale), decision log (date + reason + what changed on each vision shift).

### When to add a capability map (`docs/product/capabilities.md`)

A stable-ID list of *what users can currently do* (`O.1`, `M.1`). Ship one ONLY past greenfield, with 5+ user-facing capabilities, and when the team references "feature X" often enough that stable IDs help. Below that, skip or scaffold an empty one with the ID convention documented — authoring it before there's something to index produces a permanent placeholder. Entry format:

```markdown
### <ID> <Name> [status]
> <One-sentence goal: user can X to achieve Y.>
**Deep refs:** <where the canonical doc lives>
**Constraint:** <preconditions or blockers — only if non-trivial>
```

Status tags: `[shipped]` / `[partial]` / `[planned]` / `[deferred]`. Add entries when capabilities ship, not when planned (or `[planned]` if scaffolding ahead).

## Acceptance — what battle-tested looks like

The opening sentence shows whether the author treated identity as marketing or as Claude-grounding. The layer fails the bar if any is missing (each names the signature and the failure it prevents):

1. **Vision is one sentence, not three paragraphs** — identity is read every session; brevity protects attention. If the draft runs long, push to compress; the shorter version forces clarity.
2. **ICP is named specifically** — industry + size + role minimum. *"Developers"* fails; *"SREs at series-B SaaS on Kubernetes"* passes. It's a *wedge*, not the total addressable market.
3. **Moat is named with what's NOT-the-moat called out** — without negation, every feature feels moat-relevant; with it, *"this is not the moat — defer"* is a fast call. And the moat is real, not aspirational: *"the community we'll build"* is a plan, not a moat — tag `<MOAT_TBD>` honestly instead of overstating.
4. **Anti-vision exists** — at least 2-3 *"we are NOT building X"* bullets; without it, scope has no boundary.
5. **Production-vs-internal tag is unambiguous** — one of the four categories, not a hybrid (hybrids drift toward whichever bar the author prefers).
6. **Stage tag matches reality, and isn't hidden because it's embarrassing** — a `[shipped]` project with 0 users is `[early]`. The tag governs downstream quality calibration; honesty saves 10× more than the discomfort costs.
7. **Pace tag exists** — even `no_deadline` is useful (drives prototype-gate posture over artificial urgency); a real launch / fundraise window gets named and quoted in priority decisions.
8. **The DoD points to (doesn't duplicate) the verification ladder and plan-driven conformance-matrix discipline.**
9. **Identity changes downstream behavior** — test: read the identity, then the architecture section; if the identity constrained no architectural choice, it's decorative. Rewrite it to force choices downstream. (Same test for marketing copy: *"a revolutionary new way to…"* is noise — strip adjectives, state what users do.)
10. **A single source of truth, kept current** — one primary source (usually the CLAUDE.md opening), others cross-reference; no `README` + `CLAUDE.md` + `vision.md` + `strategy.md` all claiming authority. And it updates same-day on a pivot with a decision-log entry — an identity 6 months stale actively misleads, worse than none.

## Cross-references

- `task-classification.md` — the routing table lives in `CLAUDE.md` directly below the identity section; the two are co-located on purpose, identity grounds the routing.
- `quality-rubric.md` — the identity's production-vs-internal tag and stage tag drive what S-tier means.
