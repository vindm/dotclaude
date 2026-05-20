# `/dotclaude:design` interview

4-6 questions, adaptive. Skip what Phase 1 (project scan) already answered. The goal is to surface the design-DNA Claude Code cannot read from code: benchmarks, voice, past failures, quality bar.

## D1 — Primary surface (skip if obvious)

> "What's the primary surface this project ships? iOS app, Android, web, desktop, CLI / TUI, browser extension, embedded device?"

If multi-surface (e.g. "RN app + admin web"), ask which surface to prioritize for the design kit. Multi-surface kits can come later as a re-invocation.

## D2 — Benchmark apps (THE most important question)

> "Name 2-4 apps you benchmark your design against. Tier 1 = chrome parity (the apps your user already has on their device and will compare you against by reflex). Tier 2 = domain anchors (apps in your category that do specific things well — e.g. Strava for activity feeds, Notion for content density, Linear for keyboard speed)."

If the user says "we don't really benchmark" — push gently: "Even one app you respect helps. Without a named benchmark, the audit has no anchors and the rubric is 'looks good' which means nothing."

Common picks by category (for prompting if needed, NOT for prescribing):

- **iOS app, consumer**: Tier 1 = Apple Music / Settings / Telegram. Tier 2 varies (WHOOP for data, Strava for activity, Things 3 for tasks)
- **Web SaaS, B2B**: Tier 1 = Linear / Stripe / Notion. Tier 2 = depends on category
- **Developer tool**: Tier 1 = Linear / Raycast / Things 3. Tier 2 = `gh` CLI, Fig
- **Content product**: Tier 1 = Apple News / Reeder / Things 3. Tier 2 = Substack, Medium for type
- **B2B dashboards**: Tier 1 = Linear / Vercel / Stripe. Tier 2 = Datadog, Grafana for data density

The user picks ONLY their own. Your role is to give the framework, not the answer.

## D3 — Voice / tone

> "Does the product have a voice? Three quick checks:
> 1. Is there a brand voice document or style guide?
> 2. Are there phrases you'd NEVER want in user-facing copy? (e.g. 'Hi!', 'Welcome!', 'Sorry to interrupt', or AI-slop phrases like 'As an AI language model', 'I'd be happy to help')
> 3. Is there an in-product character / assistant (a Spot or a Clippy or a personality the product wears)?"

If yes to (3), flag the daily-driver-vs-first-touch trap (a class of bug where the assistant's onboarding voice leaks into daily-driver copy). The interaction-audit + forbidden-phrases combo guards against this.

If no voice yet: skip authoring `forbidden-phrases.txt` for now, but flag it as a candidate-for-later-when-voice-emerges.

## D4 — Past design bugs (the war stories)

> "Name 1-3 design / UX bugs in this project that you wish hadn't shipped. Not asking for postmortems — just the shape: 'we had a button on screen X that did nothing for two weeks before someone noticed' or 'we shipped a screen that violated our spacing scale because nobody checked.'"

These become the project-specific anti-patterns in the authored agents. WITHOUT this question, the audit agents will lean on generic anti-patterns from the principle docs and miss the bugs that actually matter to THIS project.

## D5 — Quality bar / S-tier definition

> "What does 'S-tier' mean for THIS project? Two framings — pick whichever fits:
> 1. 'A new user wouldn't notice anything off.' (defensive)
> 2. 'A designer I respect would screenshot it and send to their colleague.' (offensive)"

The framing matters. Defensive bar → strict polish + no rough edges; offensive bar → distinct + memorable + idiosyncratic-where-it-helps. The authored rubric anchors differ.

## D6 — Existing design conventions (skip if obvious from Phase 1)

> "Is there an existing `CLAUDE.md`, `STYLE_GUIDE.md`, or design system doc I should respect? Are there conventions in the codebase I should align the agents with (e.g. shared layout primitives, named animation presets, accessibility prop conventions)?"

If yes, READ the referenced docs before authoring. Conflicts with your agents are bugs — the user's existing docs win.

---

## How to use this script

- Don't fire-hose. One or two questions per turn, conversational.
- Skip ruthlessly. If D1 is obvious from `package.json` showing `expo` + `ios/` directory, don't ask — just confirm: "I see this is an iOS Expo app — confirming primary surface is iOS?"
- Listen for "off-script" signal. If the user mentions a specific component that's caused them pain ("our settings page got out of hand"), follow it — that's gold for the agent's anti-patterns section.
- End when you have enough. Don't push for D5 + D6 if D2-D4 gave you a rich picture.

## After the interview

Summarize back before authoring:

> "Based on our chat: Tier 1 benchmarks = [list], Tier 2 = [list], voice = [characterization or 'none for now'], past design bugs to catch = [N items I'll bake into the audit agents], quality bar = [defensive/offensive]. About to author the kit — confirm?"

Wait for confirmation, then proceed to Phase 4 of `SKILL.md`.
