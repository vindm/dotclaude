# `/dotclaude:design` interview

10-12 questions across 5 phases. Adaptive: skip ruthlessly when Phase 1 (project scan) already answered. The interview's job is to surface the **design DNA Claude Code cannot read from code** — named benchmarks, voice character, war-story bugs, quality bar, tooling — so the authored kit grades against *real anchors* instead of vibes.

**Pacing rule**: 1–2 questions per turn, conversational. Never fire-hose all 12 at once. Listen for off-script signal ("our settings page got out of hand") — that's gold for the agents' anti-patterns sections.

**Skip discipline**: if a question's answer is obvious from Phase 1's scan, do NOT ask — confirm in one sentence and move on. The cost of asking a redundant question is real (it signals "you weren't paying attention to my code").

---

## Phase A — Context (1–3 Qs, skip what's obvious)

The point of Phase A is **confirmation, not discovery**. By now the project scan has already told you 70% of this. Use it to confirm + flush out the remaining 30%.

### A1 — Primary surface

> "What's the primary surface this project ships? iOS, Android, web (browser), desktop (native macOS/Win/Linux), CLI/TUI, browser extension, embedded device?"

If multi-surface (e.g. "RN app + admin web"), ask which surface to prioritize for the design kit. Multi-surface kits can come later as a re-invocation. **Skip if Phase 1 found `package.json` with `expo` + an `ios/` directory** — confirm in one sentence: *"Looks like an iOS Expo app — primary surface is iOS, confirm?"*

### A2 — Production-facing or internal-only

> "Is this product user-facing (shipped to real end users) or internal-only (dev tools, admin panels, internal dashboards)?"

This drives several downstream defaults — `a11y-audit` only ships for user-facing; `forbidden-phrases.txt` only ships if there's a brand voice. **Skip if obvious** (a marketing site, a B2C app, a public SaaS dashboard is obviously user-facing).

### A3 — Primary user persona

> "In one sentence, who is the primary user of this product?"

Capture the persona shape (B2B power user / consumer / developer / enterprise admin / etc.). This determines which persona-lens skill template fits and how the voice section reads. **Skip if the README or `package.json` description already says.**

---

## Phase B — Benchmarks (3 Qs, THE most important section)

Without named benchmarks, every authored agent's grading rubric collapses to "looks good," which is unenforceable. **Do not skip this phase.** If the user resists, push once — *"Even one app you respect helps. Without an anchor, the audit has no rubric."*

### B1 — Tier 1 benchmark apps (chrome parity)

> "Name 2-3 apps you benchmark **chrome** against — the apps your users already have on their device, the apps your product gets compared to by reflex when they open it. Think: 'when I look at my screen and then look at App X, which one tells me my chrome is wrong?'"

Common picks by platform (PROMPT, don't prescribe):

- **iOS consumer** → Apple Music / Settings / Telegram-on-iOS
- **Web SaaS B2B** → Linear / Stripe / Notion
- **Developer tool** → Linear / Raycast / Things 3
- **Content product** → Apple News / Reeder / Substack
- **B2B dashboards** → Linear / Vercel / Stripe / Grafana
- **CLI / TUI** → `gh`, `lazygit`, `htop`

If the user says "we don't really benchmark" — try once: *"What app on your device do you think is well-designed?"* Almost everyone has an answer.

### B2 — Tier 2 benchmark apps (domain anchors, **with dimension**)

> "Name 2-3 apps you benchmark **specific dimensions** against. Not chrome-overall but specific things they do well that you want to learn from. E.g., Linear for keyboard speed, WHOOP for data density, Things 3 for empty states, Stripe for checkout sequencing. Each name should come with the dimension."

The **dimension is the load-bearing part**. "We like Notion" is useless. "Notion for inline editing affordances" is enforceable. Push for the dimension; without it the Tier 2 benchmark doesn't anchor anything.

If the user only gives names without dimensions, ask follow-up: *"Why that one? What does it do that you want to learn from?"*

### B3 — Anti-references

> "Are there apps the design should **NOT** look like? Aesthetics or patterns you've explicitly rejected? 'No SAP', 'no early-Material 2', 'nothing that screams Bootstrap', 'no consumer-y/bubbly tone'."

Anti-references are equally important to positive references — they tell the agents what to **reject**. Without B3, the rubric only knows what to chase, not what to avoid. The "looks like another React Native app" or "looks like a Bootstrap admin theme" diagnoses come from B3 calibration.

---

## Phase C — Voice + Character (1–3 Qs)

Skip entirely if A2 said "internal-only" or the product has no user-facing copy beyond labels.

### C1 — Brand voice

> "Does the product have a voice? Three quick checks:
> 1. Is there a brand voice doc / style guide / `STYLE_GUIDE.md`?
> 2. Pick 3 adjectives that describe the voice (e.g. 'direct, dry, slightly nerdy' vs 'warm, inviting, conversational').
> 3. Show me one phrasing from a real surface that nails the voice."

The third part — the real example — is the highest-signal answer. Adjectives are too vague; a real phrase from a real surface anchors the voice for every authored copy / forbidden-phrases artifact.

### C2 — Forbidden phrases

> "Are there phrases you'd NEVER want in user-facing copy?
>
> Universal AI-slop to ban by default: 'As an AI language model', 'I'd be happy to help', 'Let me know if you have any questions', 'I apologize for the confusion'.
>
> Brand-specific? E.g. 'no greeting like Hi/Welcome on daily surfaces', 'no apologetic empty states', 'no exclamation marks', 'no emoji in chrome'."

These become the `forbidden-phrases.txt` ship-list. Universal AI-slop is shipped by default; brand-specific gets layered on top.

### C3 — In-product character / assistant

> "Is there an in-product character / assistant (a named AI helper, a mascot, a personality the product wears)?"

If **yes**, flag the **daily-driver-vs-first-touch trap** — a class of bug where the assistant's onboarding voice ("Hi — I'm <name>, let me show you around!") leaks onto daily-driver surfaces the user revisits dozens of times.

The combination of `interaction-audit` + `forbidden-phrases.txt` + `element-reuse-check` is the structural guard against this trap. Make sure these three artifacts ship together if C3 is yes.

If **no**, skip the trap and ship lighter copy discipline.

---

## Phase D — Bug-mining (THE most important new section)

This is the phase that transforms generic principle-doc anti-patterns into **project-specific anti-patterns the agents will catch.** Without it, the audits regurgitate the textbook; with it, they catch the actual bugs this team has shipped before.

### D0 — Setup (Claude runs, no question yet)

Before asking, mine the git log:

```bash
git log --oneline --grep="fix:" -30
git log --oneline --grep="bug:" -20
git log --oneline -E --grep="design|UX|style|color|spacing|a11y|layout|copy|tone|chrome|polish" -20
```

Read the top 5-10 commit subjects. Identify the 2-3 most design-flavored ones (anything mentioning style, color, spacing, layout, copy, chrome, tone, alignment, accessibility, or a specific component going wrong).

### D1 — Specific commit by SHA

> "I see commit `<SHA>` — *'<subject line>'*. Tell me what happened there? What was the user-visible symptom?"

**By SHA, by subject line.** This signals "I read your code" and gets a richer story than abstract "any UX bugs?" — concreteness primes concreteness.

### D2 — Root cause follow-up

After the user tells the story, ask:

> "How did it ship in the first place? Was it a single-screen issue, a journey-continuity issue, a token-discipline gap, a voice mismatch, or something else?"

The user's framing of "how it shipped" determines which agent should have caught it — and therefore which authored agent's anti-pattern list needs this story.

### D3 — Off-the-record bugs

> "Any UX bugs that DIDN'T make it into git but still bother you? 'I keep meaning to fix that' / 'it's not technically broken but it's bad' / 'we know about it'."

These tend to be the most-valuable answers — bugs that bother the user but never reached the threshold for a fix-commit. They're exactly what the audit agents should surface periodically.

Each story from D1/D2/D3 becomes a named anti-pattern in the relevant authored agent. Goal: 3-5 project-specific anti-patterns total to thread into the kit.

---

## Phase E — Tooling + conventions (1–2 Qs)

Brief, mostly confirmation. The point is to make sure the authored agents reference the *right* commands and respect *existing* docs.

### E1 — Dev loop + visual verification

> "How do you currently verify a UI change visually? Hot-reload + look at the simulator? Playwright screenshots? Manual screenshot at a staging URL? Storybook?"

The authored `visual-verification.md` rule and the `ux-reviewer` agent's "capture commands" section need this. **Skip if Phase 1 found a `playwright.config.ts` / Maestro flows / explicit screenshot script** — confirm in one sentence.

### E2 — Existing docs to respect

> "Is there an existing `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, or design-system doc I should respect? Anywhere your existing conventions live that I should align the agents with?"

If yes, **READ those docs before authoring.** Conflicts with your agents are bugs — the user's existing docs win. **Skip if Phase 1 found NONE of these** — there's nothing to respect, so move on.

---

## Summary turn (mandatory before authoring)

Before invoking Phase 4 of `SKILL.md`, summarize back what you captured + what you'll author. Wait for explicit "go."

> "Based on our chat:
> - **Surface**: <iOS / web / etc.>
> - **Tier 1 chrome**: <Linear, Stripe, ...>
> - **Tier 2 domain anchors**: <Things 3 for empty states, WHOOP for data density, ...>
> - **Anti-references**: <Bootstrap admin themes, early-Material 2, ...>
> - **Voice**: <characterization or 'none for now'>
> - **In-product character**: <yes — name; daily-driver trap applies / no>
> - **War-story anti-patterns to bake in** (from git mining + your stories): <N items, briefly>
> - **Quality bar**: <S-tier definition>
>
> About to author the kit:
> - **Agents**: <list>
> - **Skills**: <list>
> - **Rules**: <list>
> - **Hooks**: <list>
>
> Confirm to proceed?"

Wait for confirmation, then proceed to Phase 4 of `SKILL.md`.

---

## How to use this script

- **One or two questions per turn**, conversational.
- **Skip ruthlessly.** If Phase 1's scan already answered a question, confirm in one sentence rather than asking.
- **Listen for off-script signal.** A user-volunteered "our settings page got out of hand" is more valuable than 5 in-script questions answered tersely. Follow it.
- **Push gently** on B1/B2/B3 if the user is reluctant — these are the most load-bearing answers.
- **End when you have enough.** Don't grind through E1/E2 if A–D already gave you a rich picture; just confirm tooling in the summary turn.
- **Mine git in Phase D no matter what.** Even if the user has prepared their war stories, the SHA + subject-line specificity makes the conversation 2-3× more concrete.
