# design-benchmarking — designing the "name your benchmarks" rule

Teaching material for Claude Code. Teaches you how to author a benchmarking rule — the artifact that names the specific reference apps the project grades against and holds the team to those references on every screen.

## When to ship one

Ship a design-benchmarking rule when the project has a quality bar to hold (S-tier, "world-class," "production-grade"), the user has named reference apps they admire (*"we want to look like X"*), and visual reviewers (ux-audit, flow-audit) need a shared reference to grade against. Skip when the posture is "functional, not benchmarked," when it's a library / CLI with no visual bar, or when the user is indifferent to design references.

## Why it matters

Without named benchmarks, "S-tier" / "premium" / "polished" collapse into vibes — two people can both honestly believe a screen is S-tier and mean entirely different things, with no shared reference to resolve it. Naming benchmarks does three things: it **aligns calibration** (everyone grading against "Apple iOS 26 Settings + Telegram" gives the same screen the same grade), **forces the comparison** (*"is this S-tier?"* is unanswerable; *"could this sit next to <reference> on the same home screen without embarrassing itself?"* is answerable in 5 seconds), and **anchors specific improvements** (*"this empty state is below the Things 3 bar — Things teaches, ours apologizes"* names the move). Above all it arrests the loss of ambition that happens when no one specifies what "great" means — without an external reference, "great" drifts to "what we shipped last quarter."

## Core methodology — Tier 1 + Tier 2

Every screen is graded against both tiers.

**Tier 1 — platform / chrome reference:** the bar for the project's platform. Pick references that are widely available (the team can install and look), ship the platform's idiomatic chrome at the highest tier, and the team has actually used (so "Apple parity" is real, not a buzzword).

| Platform | Typical Tier 1 references |
|---|---|
| iOS app | Apple's iOS 26 system apps (Music, Photos, Settings, Wallet) + Telegram |
| Android app | Google Calendar, YouTube Music (Material 3) + Telegram |
| Web app (general) | Linear + Stripe + Vercel + Superhuman |
| Web app (developer-focused) | Linear + Raycast Web + GitHub + Vercel |
| Desktop (macOS) | Apple Music / Notes / Mail, Linear, Tweetbot |
| Desktop (cross-platform) | Linear (Electron-done-well), Figma |
| CLI / TUI | `gh`, `lazygit`, `htop`, Raycast |
| B2B SaaS | Linear + Notion + Figma |
| Marketing site | Stripe.com + Linear.app + Vercel.com |

**Tier 2 — domain reference:** the bar for the specific surface type, which has its own conventions for "great":

| Surface type | Typical Tier 2 references |
|---|---|
| Onboarding / wizard | WHOOP onboarding, Things 3 first-run, Stripe checkout |
| Dashboard / triage | Linear inbox, Superhuman triage, Vercel overview |
| Empty state | Things 3, Raycast (empty states that teach) |
| Settings | Apple Settings, Telegram settings, Linear settings |
| Auth flow | Stripe sign-in, Linear sign-in, Apple ID |
| Detail / drill-in | App Store detail, Notion page, Linear issue |
| Form-heavy | Stripe checkout, TurboTax wizard, Linear new-issue |
| Search / command palette | Raycast, Linear command palette, Superhuman |

Both tables are recommendations — the project's tiers should be what the user actually grades against, not another project's picks. When grading, name both and name the move: *"Chrome at Apple-Settings parity; empty state below Things 3 — Things teaches, ours apologizes."*

## How to derive THIS project's specifics

1. **Direct interview** — *"When you say 'S-tier,' which specific apps? Open each one. What about them is great?"* Get apps and the user's own articulation of what makes them great.
2. **The platform** — determines the candidate Tier 1 references.
3. **The surface inventory** — determines which Tier 2 categories to populate (a SaaS without onboarding needs no wizard row).
4. **Anti-references** — *"Which apps do you specifically NOT want to be compared to?"* Useful for ruling out tempting-but-wrong directions.
5. **Per-surface translation** — a user may pick a Tier 1 reference off-platform (*"I want our RN app to feel like Telegram on iOS 26"*); that's legitimate, but the rule must encode what "feel like" means concretely (spacing, typography, dividers).

## Authoring the rule

The final rule (typically `.claude/rules/design-north-star.md`) contains the one-sentence north star (*"Every owner-facing surface is graded against Apple iOS 26 native chrome + Telegram"*), the Tier 1 and Tier 2 tables with **what to steal** from each reference (*"compare to X and steal their empty-state pattern"* — not just "compare to X"), a rejected-moves anti-patterns list (*"custom RN chrome faking iOS — use native primitives"; "multiple competing accent colors — restraint is part of the reference"*), a before-done verification checklist (open the Tier 1 + Tier 2 reference for the equivalent screen, compare side-by-side, name one thing we do better, one they do better, one we'll fix), and a pointer to the project's native chrome primitives so reviewers don't reinvent them. And the per-surface chrome reference table — binding in shape, project-specific in content:

| Surface | Tier 1 reference | Tier 2 anchor |
|---|---|---|
| Tab bar / primary nav | <ref> | — |
| Cards / list rows | <ref> | — |
| Sheets / modals | <ref> | <ref for content density> |
| Empty states | <ref> | <domain ref for what-to-teach> |
| Motion / transitions | <ref> | — |
| Color discipline | <ref> | — |
| Typography hierarchy | <ref> | — |
| Form inputs / controls | <ref> | — |
| Loading / skeleton states | <ref> | — |

Cells are filled with apps named in the interview; an empty cell is an explicit "no Tier 2 reference for this surface," not an omission. A reviewer grading a chrome surface looks up the row, names the reference, and grades against it — without this table, "Apple-tier chrome" stays an aspiration.

## Authored artifacts (the inventory contract)

When a bootstrap or `/dotclaude:design` run hits the applicability gate, these ship by default — if your output lacks any for a UI-shipping project, you skimped:

- **`.claude/rules/design-north-star.md`** — Tier 1 + Tier 2 benchmarks with WHY each was picked, the per-surface chrome table, and the anti-patterns list. ~80-150 LOC, read by every visual reviewer every session — terse and binding.
- **`.claude/skills/quality-bar/SKILL.md`** — the operational S/A/B/C/D rubric anchored to the named benchmarks; auto-loads on any UI work; cross-references the north-star for the references themselves.
- **Per-domain quality anchors** in each design agent's body — each agent's grade scale references the north-star's benchmarks rather than re-deriving them (stated once, consumed many times).
- **(Mature projects) `docs/design-system/` per-aspect docs** (`persona.md` / `motion.md` / `tokens.md` / `components.md`) — output of design exploration over time, not one bootstrap pass. Bootstrap scaffolds the `README.md` entry point and invites the per-aspect docs as content emerges; don't author empty ones (they become wishlist docs that stay empty).
- **(Conditional) `voice-north-star.md`** — when the project has a brand voice worth grading; same shape, for tone / register.
- **(Conditional) `api-north-star.md`** — when the project is a library / SDK; same shape, for API ergonomics (React Query for hook ergonomics, Zod for type-narrowing, requests-Python for readability).

The set scales with project shape — a research prototype ships only `api-north-star.md` (and only if it's a library); a mature consumer iOS app ships the full set plus a populated `docs/design-system/`.

## Acceptance — mistakes in the rule you write

- **Tier rows without specific apps** — *"premium SaaS aesthetics"* is unactionable; *"Linear + Stripe + Vercel"* is enforceable.
- **References the team has never used** — reviewers can't grade against an app they haven't internalized; a reference no one has opened is a fiction.
- **Benchmarks the team aspires to but can't reach** — if *"Tier 1 = Stripe checkout"* is beyond the team's engineering and design budget, the rule produces shame, not direction. Pick a stretch goal, not an unreachable one.
- **Single-tier benchmarking** — Tier 1 alone produces "looks Apple-ish" without domain fit; Tier 2 alone produces domain fit without chrome quality. Both are needed.
- **No "what to steal" column** — *"compare to X"* is vague; *"compare to X and steal their empty-state pattern"* is concrete.
- **Undated references** — "iOS 17 chrome" was right once; the rule is a dated snapshot, not eternal truth.

## Cross-references

- `quality-rubric.md` — the rubric's Tier 1 / Tier 2 anchors derive from this rule.
- `ux-audit.md` / `visual-verification.md` — the reviewer grades against these benchmarks; the comparison step's reference target is the benchmark.
- `audit-routing.md` — the audit pipeline grades against the benchmarks this rule names.
