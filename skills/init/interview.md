# Interview flow — `/dotclaude:init`

This is the **adaptive question script** the init skill walks through. It is NOT a multiple-choice survey. Most answers are open-ended. The skill should skip questions whose answer is obvious from Phase 1 reading (project scan).

Match the asking pace to the user — clump related questions where possible, but don't dump the whole list at once. Conversational, one or two questions per turn.

## Section A — Project shape (skip if obvious from Phase 1)

A1. **What kind of project is this in one sentence?** (e.g., "an iOS app for X," "a CLI tool that does Y," "a backend service for Z"). This anchors everything.

A2. **Solo or team?** (Affects whether agents like `code-reviewer` and `pre-flight` are critical or overkill.)

A3. **Production-facing or internal/prototype?** (Affects what counts as a real failure vs an acceptable rough edge.)

A4. **Customer-facing, developer-facing, or both?** (Affects whether things like `a11y-audit`, `persona-testing`, voice / tone discipline matter.)

## Section B — Failure modes (THE most important section)

B1. **Name 2-3 bugs or incidents in this codebase that you wish hadn't shipped.** (Not asking for postmortems — just the shape: "we had a thing where X silently failed and we didn't notice for a week" / "we shipped Y that violated our design system because nobody checked"). These are the guardrails to derive.

B2. **What kinds of mistakes does AI-written code make in this repo that you find yourself fixing?** (Specific to AI-assistance failure modes — e.g., "generates files over 1000 LOC," "uses raw hex colors," "fakes Apple-iOS UI with custom RN chrome.")

B3. **Are there any patterns in the codebase that you DON'T want this `.claude/` to reinforce?** (E.g., "we have a 5000-LOC controller that everyone hates — don't let the agents act like that's normal.")

## Section C — Quality bar

C1. **What products / apps do you benchmark against?** (Examples: "Apple iOS 26 + Telegram for chrome," "Linear for keyboard speed," "Stripe for API ergonomics," "WHOOP for data presentation," or "we don't benchmark — just ship working." Either answer is valid; it shapes the rubric anchors.)

C2. **What does 'S-tier' mean for this project?** (E.g., "doesn't embarrass me in front of the user I'm trying to recruit as customer #2.")

C3. **What's the line between 'ship it' and 'polish more'?** (If they say "always polish" — that's a different project than "ship at credible, polish post-traction.")

## Section D — Stack & flow

D1. **What's the dev loop look like?** (E.g., "Metro on physical iPhone, hot reload, screenshot via WDA scripts" / "Vite dev server in browser" / "Docker compose up, hit /healthz, iterate" / "headless lib, runs only in tests")

D2. **How do you verify changes?** (Tests? Manual? Screenshots? CI? "I just look at it in dev" is a valid answer.)

D3. **Any specific tools the agents need to know about?** (E.g., Maestro for E2E, specific seed scripts, custom CLI tools.) — only if NOT obvious from `package.json` scripts.

D4. **Is there an existing `CLAUDE.md` / `AGENTS.md` / coding conventions doc I should respect?** (If yes, read it before continuing.)

## Section E — Database / state

(Skip if project has no DB.)

E1. **What's the database setup?** (E.g., "Postgres + Supabase + RLS," "SQLite local," "DynamoDB," "no DB — just files / API.")

E2. **Are there silent-no-op classes of write failure?** (RLS policies that drop writes? Eventually-consistent reads that look right but stale?) If yes — `data-integrity.md` principle becomes critical.

E3. **Any LLM-callable DB tools** (MCP DB servers, BI integrations) **in use?** (Drives `database-query-discipline` artifact.)

## Section F — AI / LLM workflows

(Skip if project has no AI workflows.)

F1. **What AI calls happen in production code or tests?** (Single model? Multi-stage pipeline? Critic loops? Eval harness?)

F2. **What's the LLM cost ceiling per dev iteration?** (Drives whether `ai-cost-monitoring.md` artifact is worth shipping.)

F3. **Do you have an eval harness / regression suite for prompts?** (If yes, an `eval-cost-watcher` agent may help; if no, that's a candidate for the roadmap.)

## Section G — Voice / tone (skip for libs / dev tools)

G1. **Does the product have a voice?** (E.g., friendly, terse, professional, irreverent.)

G2. **Are there phrases you NEVER want in user-facing copy?** (Forbidden-phrases list. Common starters: "As an AI language model," "I'd be happy to help," "Certainly! Here is" — but the user may have their own brand-specific list.)

G3. **Is there an in-product assistant / character?** (If yes — there's a class of bug where its onboarding voice leaks into daily-driver copy. Worth a hook.)

## Section H — Closing

H1. **Anything else you want the AI agents working in this repo to know about?** (Catch-all. Sometimes the most valuable answer comes here.)

H2. **What's the smallest useful `.claude/` for you?** (Optional. If they say "give me everything," you can go broader. If they say "just file-size + a code-reviewer," respect that.)

---

## How to use this script

- Adapt the order based on signal. If the user mentions a specific bug in A1, jump to B1 to dig in.
- If the user gives a one-word answer, ask for the next-level detail.
- If the user starts talking about something off-script that matters, follow it — your goal is project DNA, not survey completion.
- End the interview when you have enough to author. You don't need every section answered. 5-7 strong answers beat 25 thin ones.

After the interview, summarize back to the user before authoring:

> "Based on our conversation, I'm going to author <N> artifacts focused on <themes>. I'm SKIPPING <list> because <reasons>. Sound right?"

Wait for confirmation, then proceed to Phase 4.
