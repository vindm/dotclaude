# design-benchmarking — designing the "name your benchmarks" rule

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to author a benchmarking rule — the artifact that names the specific reference apps the project grades against and holds the team to those references on every screen.

## When to ship one (applicability gate)

Ship a design-benchmarking rule when:

- The project has a **quality bar to hold** (S-tier, "world-class," "production-grade").
- The user has talked about specific reference apps they admire ("we want to look like X").
- Visual reviewers (ux-audit, flow-audit) need a shared reference to grade against.

Skip when:

- The project's design posture is "functional, not benchmarked." Benchmarks are wrong tool for "ship it" culture.
- The project is a library / CLI tool with no visual quality bar (per se).
- The user is indifferent to design references — "use whatever feels right." Imposing benchmarks against that posture produces friction without lift.

## Why it matters — what this catches that nothing else does

Without benchmarks named, "S-tier" / "premium" / "polished" / "great UX" collapse into vibes. Two team members can both honestly believe a screen is S-tier and mean entirely different things. The argument can't be resolved because there's no shared reference.

Naming benchmarks does three things:

1. **Aligns calibration.** When everyone grades against "Apple iOS 26 Settings + Telegram on iOS 26," the same screen gets the same grade from any reviewer.

2. **Forces the comparison.** "Is this S-tier?" is unanswerable. "Could this screen sit next to <named-reference> on the same home screen without embarrassing itself?" is answerable in 5 seconds.

3. **Anchors specific improvements.** "This empty state needs work" is unactionable. "This empty state is below the Things 3 bar — Things teaches; ours apologizes" names the move.

What this catches that nothing else does: the loss of design ambition that happens when no one specifies what "great" means. Without named benchmarks, "great" drifts to "what we shipped last quarter." Benchmarks lock the bar to something external.

## Core methodology — Tier 1 + Tier 2

The rule has a two-tier structure. Every screen is graded against both tiers.

### Tier 1 — Platform / chrome reference

The bar for the project's PLATFORM. What does the gold-standard chrome look like on this platform? Pick references that:
- Are widely available (the team can install them and look at them).
- Ship the platform's idiomatic chrome at the highest tier (system apps, leading native apps).
- The team has actually used (so "Apple parity" is a real reference, not a buzzword).

By platform:

| Platform | Typical Tier 1 references |
|---|---|
| iOS app | Apple's iOS 26 system apps (Music, Photos, Settings, Wallet, App Store) + Telegram on iOS 26 |
| Android app | Google Calendar, YouTube Music (Material 3) + Telegram for Android |
| Web app (general) | Linear + Stripe + Vercel + Superhuman |
| Web app (developer-focused) | Linear + Raycast Web + GitHub + Vercel |
| Desktop app (macOS) | Apple Music / Notes / Mail (native), Linear, Tweetbot |
| Desktop app (Windows) | Win11 Fluent native apps (Settings, Photos, Mail) |
| Desktop cross-platform | Linear (Electron-done-well), Figma |
| CLI / TUI | `gh`, `lazygit`, `htop`, Raycast (as the gold standard for first-run quality) |
| B2B SaaS | Linear + Notion + Figma |
| Mobile-web responsive | Vercel mobile + Stripe checkout |
| Marketing site | Stripe.com + Linear.app + Vercel.com |

These are recommendations, not mandates. The project's Tier 1 should be what the user actually grades against — not what someone else's project does.

### Tier 2 — Domain reference

The bar for the SPECIFIC type of surface this screen is. Different surface types have different conventions for "great":

| Surface type | Typical Tier 2 references |
|---|---|
| Onboarding / wizard | WHOOP onboarding, Things 3 first-run, Stripe checkout |
| Dashboard / triage view | Linear inbox, Superhuman triage, Vercel project overview |
| Empty state | Things 3, Raycast (empty states that teach) |
| Settings | Apple Settings, Telegram settings, Linear settings |
| Auth flow | Stripe sign-in, Linear sign-in, Apple ID flow |
| Detail / drill-in page | Apple App Store detail, Notion page, Linear issue |
| Activity feed / log | Strava activity, Linear changelog, Vercel deployments |
| Form-heavy surface | Stripe checkout, TurboTax wizard, Linear new-issue |
| Map / spatial view | Apple Maps, Google Maps (the bar for canvas fluidity) |
| Notification / alert | Apple notifications, Linear inbox notifications |
| Search / command palette | Raycast, Linear command palette, Superhuman command bar |

Again, these are recommendations. The project's Tier 2 should reflect what the user has used and would aim for.

### Per-screen grading

Every screen names BOTH tiers' references in its audit:

*"Chrome at Apple-Settings parity; empty state below Things 3 — Things teaches; ours apologizes."*

The format: identify what we do at parity, identify what we're below parity on, name the move to close the gap.

## How to derive THIS project's specifics

Before authoring the rule, gather:

1. **Direct user interview.** Ask: *"When you say 'S-tier,' which specific apps do you mean? Open each one for me. What about them is great?"* Get specific apps and the user's own articulation of what makes them great.

2. **The project's platform.** Determines the candidate Tier 1 references.

3. **The project's surface inventory.** Determines which Tier 2 categories the rule needs to populate. A B2B SaaS without onboarding doesn't need a wizard Tier 2 row.

4. **Anti-references.** Sometimes the most useful signal is "we do NOT want to look like X." Ask: *"Which apps do you specifically not want to be compared to?"* Anti-references are useful for ruling out tempting-but-wrong directions.

5. **Per-surface translation.** Sometimes the user picks Tier 1 references not on the project's platform (e.g., "I want our React Native app to feel like Telegram on iOS 26"). That's legitimate — the rule should encode the cross-platform translation.

## Authoring the rule

The final rule (typically `.claude/rules/design-benchmarking.md` or `.claude/rules/design-north-star.md`) should contain:

1. **The one-sentence north star.** "Every owner-facing surface is graded against Apple iOS 26 native chrome + Telegram on iOS 26." (Or whatever the project's actual benchmark posture is.)

2. **The Tier 1 table** — platform reference + what to steal from each.

3. **The Tier 2 table** — per-surface-category references + what to steal.

3.5. **Per-surface chrome reference table** — the row-per-surface convention. Every project that takes design seriously names which reference informs each chrome surface type. The shape is binding (every project should produce this table); the content is project-specific. Template:

| Surface | Tier 1 reference | Tier 2 anchor |
|---|---|---|
| Tab bar / primary nav | <ref> | — |
| Cards / list rows | <ref> | — |
| Sheets / modals | <ref> | <ref for content density> |
| Modal alerts / confirms | <ref> | — |
| Empty states | <ref> | <domain ref for what-to-teach> |
| Motion / transitions | <ref> | — |
| Color discipline | <ref> | — |
| Typography hierarchy | <ref> | — |
| Iconography | <ref> | — |
| Form inputs / controls | <ref> | — |
| Loading / skeleton states | <ref> | — |

The cells are filled with specific apps named in the interview (Q-B1 + Q-B2). Empty cells are explicit "no Tier 2 reference for this surface" — not omissions. When a reviewer grades a chrome surface, they look up the row, name the reference, and grade against it. Without this table, "Apple-tier chrome" stays an aspiration; with it, every surface has an enforceable bar.

4. **Anti-patterns table** — specific design moves the rule REJECTS based on the benchmark posture. Examples:
   - "Custom RN-rendered chrome trying to fake iOS — use native primitives."
   - "Multiple competing accent colors — restraint is part of the reference."
   - "Heavy drop shadows when the reference uses material edge highlights."

5. **The verification checklist.** Before claiming a screen done:
   - Open the Tier 1 reference for an equivalent screen.
   - Open the Tier 2 reference if applicable.
   - Compare side-by-side.
   - Name 1 thing we do better, 1 thing they do better, 1 thing we'll fix to close the gap.

6. **Per-platform primitives.** Where the project's native chrome primitives live — components, tokens, theme. The rule should point at the existing infrastructure (e.g., "use `<NativeTabs>`, not a custom tab bar") so reviewers don't reinvent.

## Cross-references

- `quality-rubric.md` — the rubric's Tier 1 / Tier 2 anchors derive from this rule.
- `ux-audit.md` — visual reviewer grades against the benchmarks named here.
- `visual-verification.md` — the comparison step's reference target is the benchmark.
- `audit-routing.md` — when the audit pipeline runs, it grades against the benchmarks; this rule names them.

## Anti-patterns in the rule you write

- **Tier rows without specific apps.** "Premium SaaS aesthetics" is unactionable. "Linear + Stripe + Vercel" is enforceable.

- **References the team has never seen.** If the rule says "Tier 1 = Things 3" but no one on the team has used Things 3, the reference is a fiction. Reviewers can't grade against an app they haven't internalized.

- **Cross-platform references without translation.** "Make our Android app feel like Apple Settings" — possible, but needs explicit translation. The rule should say what "feel like" means concretely (the spacing, the typography, the row-row dividers).

- **No anti-patterns.** Without anti-patterns, the rule produces aspirations but doesn't shape decisions. The anti-patterns are how the rule binds — "we tried X and it failed for reason Y; don't try X again."

- **References that drift with time.** "Apple iOS 17 chrome" was the right reference once; iOS 26 is the right reference now. The rule should be dated; reviewers should treat it as a snapshot, not eternal truth.

- **Single-tier benchmarking.** Tier 1 alone produces "looks Apple-ish" without domain fit. Tier 2 alone produces domain fit without chrome quality. Both tiers are needed.

- **Picking benchmarks the team aspires to but can't reach.** If "Tier 1 = Stripe checkout" is the bar but the team has neither the engineering nor the design budget to ever approach it, the rule produces shame, not direction. Pick a stretch goal, not an unreachable one.

- **No "what to steal" column.** "Compare to X" is vague; "compare to X and steal their empty-state pattern" is concrete. Each row should name what specifically to take from that reference.
