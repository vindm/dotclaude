# dotclaude

> A battle-tested Claude Code workflow pack — guardrails, audit pipelines, and war stories. Generates a curated `.claude/` directory for your project in under a minute.

```bash
cd your-project
npx dotclaude init
```

Pick a profile. Answer four questions. Get a working `.claude/` directory wired into your repo. Every artifact in it is something that earned its place by catching a real bug, blocking real AI slop, or shortening a real debugging session.

This is the artifact behind months of working with Claude Code as a daily driver. It's the codified discipline; the war stories that produced it are checked in alongside.

---

## What this is

When you let an AI agent write code in your repo, three failure modes show up. None of them are about the AI being "bad" — they're about the absence of constraints that a senior engineer would impose on a junior teammate by reflex:

1. **Drift.** Files grow. Conventions slip. The 200-LOC component becomes a 1200-LOC component over six PRs, none of which individually crossed any threshold worth flagging.
2. **Slop.** AI-shaped phrasing leaks into user-facing copy. Raw hex colors land outside the design system. "TODO: fix later" piles up. Production becomes a museum of half-finished tangents.
3. **Confidence theatre.** Tests pass for the wrong reason. The handler reports success while the database silently no-ops. The screenshot looks right while the button does nothing.

`dotclaude` is a curated set of constraints aimed at all three. Some constraints fire at edit time (hooks). Some prime the agent's reasoning (rules and skills). Some validate before merge (agents). All of them are extracted from real workflows, anonymized, and generalized to apply across stacks.

It's a workflow pack, not a framework. You install it into your repo, you can edit anything, you can delete what doesn't fit. There's no runtime dependency on this package after `init`.

---

## The four-tier model

The kit decomposes into four artifact types, each addressing a different failure mode:

| Tier | Fires when | Catches |
|---|---|---|
| **Hooks** (`.sh` scripts) | Every tool call — edits, bashes, sessions | Cheap, mechanical violations. Raw hex colors. Forbidden phrases. File-size ceiling. Secret credentials. |
| **Rules** (`.md`) | Read by the agent as context | Cross-cutting policy. "How we test." "When to use the privileged DB client." "Visual verification discipline." |
| **Skills** (auto-loaded `.md`) | Triggered by file path or topic | Domain expertise. Reuse-check verdict matrices. Decomposition recipes. Pre-design audits. |
| **Agents** (delegated subagents) | Invoked by name during work | Pre-implementation validation, post-implementation review, semantic audits. |

The pipeline is designed to compose. A hook blocks a raw hex literal at edit time → the agent never has to remember the policy. A rule reminds the agent of the policy → the agent applies it during design. A skill encodes the procedural how-to → the agent doesn't reinvent the matrix. A reviewer agent catches what slipped through → before merge.

Each tier is cheaper than the next. A hook costs zero LLM tokens. A reviewer agent can cost thousands. The discipline is: catch what you can at the cheapest tier; reserve agents for things that genuinely need judgment.

---

## What's in this release

### Profiles (`profiles/`)

Pre-curated kits for common stacks:

- **`minimal`** — sole-dev SPA. The smallest useful guardrail set. Start here.
- **`web-saas`** — TypeScript + React + GraphQL + Vite + Cloudflare-style. Adds import-boundary, design-tokens, secret-leak, console-log discipline.
- **`mobile-rn`** — React Native + Expo + iOS. Adds prebuild-required warning, mobile-tuned file-size ceiling.
- **`api-only`** — backend / headless services. UI hooks dropped, database discipline emphasized.
- **`full-stack`** — kitchen sink for monorepos covering web + mobile + API.

### Hooks (`templates/hooks/`)

12 hook templates covering: file-size ceiling, forbidden phrases, import boundaries, design-token discipline, secret-leak prevention, console-log discipline, TODO-without-ticket warnings, bash safety, prebuild-required warnings, regen-after-migration triggers, auto-lint, session-start context injection.

Each is a Mustache-templated `.sh` script. Edit-time enforcement; zero token cost.

### Rules (`templates/rules/`)

6 cross-cutting policy rules the agent reads as context:

- `file-discipline` — file-size ceiling + decomposition triggers
- `audit-routing` — which agent runs for which audit question + the canonical pipeline order
- `design-north-star` — Apple iOS 26 + Telegram as design benchmark; anti-pattern catalog
- `visual-verification` — "see what you built" discipline before claiming done
- `database-query-discipline` — CLI > LLM-tool for reads; RLS silent-no-op trap
- `forbidden-phrases.txt` — authoritative AI-slop deny-list (enforced by the `check-forbidden-phrases` hook)

### Skills (`templates/skills/`)

6 skill templates, loaded by file path or topic:

- `decompose-file` — guided refactoring when a file approaches the size ceiling
- `journey-audit` — prior-surface mapping before designing a new screen or flow
- `element-reuse-check` — Gate A verdict matrix before authoring a new UI element
- `persona-lens` — Gate B: day-30 / partner / stranger tests on every visible copy element
- `quality-bar` — S-tier rubric + demo test + 5 composition pitfalls + benchmark anchors
- `migration-create` — DB migration discipline: reversibility, parallel paths, type regeneration

### Agents (`templates/agents/`)

14 agent templates, grouped by role:

**Validation agents** (run after implementation, before merge):
- `code-reviewer` — post-implementation review
- `pre-flight` — pre-implementation cross-module risk validation
- `interaction-audit` — semantic integrity (does chrome promise what the handler does?)
- `a11y-audit` — VoiceOver / Dynamic Type / contrast / tap targets
- `data-auditor` — DB / pipeline data quality
- `tests-architect` — test coverage gaps
- `design-token-auditor` — raw hex / non-token color sweep (haiku, cheap)
- `ux-reviewer` — per-screen visual polish against the design north star

**Audit agents** (cross-cutting / multi-screen):
- `pages-audit` — cross-tab consistency on the primary surface
- `flow-auditor` — whole-arc audit (sign-up → wizard → first-driver-open)
- `skill-auditor` — skill docs vs code drift (haiku)

**Strategy / design agents**:
- `product-designer` — IA / flow / multi-screen architecture; spec doc IS the deliverable
- `product-compass` — vision-vs-drift guardian

**AI-workflow agents**:
- `eval-cost-watcher` — projects LLM-token cost of an AI-workflow change before the regression-eval runs

### War stories (`docs/war-stories/`)

Four narratives, each ~400 words, walking through a specific debugging session — symptom, root cause, diagnostic that worked, lesson, and the discipline derived from it. The war stories are why the constraints exist. They're the proof that the constraints aren't speculative.

- *The button that never fired* — an OS-level overlay absorbed taps; the test reported success while the handler never ran.
- *The write that returned success and changed nothing* — RLS silently no-op'd writes; the response shape lied.
- *The test passed for the wrong reason* — a mock-mode flag short-circuited at the route layer but not at the worker layer; the tests exercised the short-circuit.
- *The bug surfaced five screens later than the cause* — an environment-variable substitution silently produced `"undefined"`; the cascade made every intermediate screen look fine.

---

## How to use it

1. **`npx dotclaude init`** in the root of your repo.
2. Pick a profile. Profiles are starting points, not contracts — you can mix-and-match artifacts later.
3. The CLI writes `.claude/` (hooks, rules, skills, agents) and a `dotclaude.yml` config file.
4. Commit the result. Anyone who runs Claude Code in your repo now gets the constraints automatically.

Edit any artifact directly. The CLI doesn't manage the artifacts after `init` — it just bootstraps them. Your `.claude/` directory is yours to evolve.

To override a constraint on a specific line, every hook supports a per-line escape comment (`// allow-color: <reason>`, `// allow-forbidden: <reason>`, etc.). The override pattern is uniform; you're never forced to disable a rule globally to make one exception.

---

## Roadmap

- **Examples directory** — fully-rendered `.claude/` directories per profile, so you can browse the output without running the CLI.
- **Bootstrap skill** — a Claude Code skill that reads your codebase, detects the stack, and recommends profile + custom adjustments through dialogue.
- **More hooks, rules, agents** — the kit grows opportunistically as new patterns earn their place via the war-story discipline.

---

## Philosophy

A few principles guide what gets into this kit and what doesn't:

**Specificity over generality.** A rule that says "write good code" teaches nothing. A rule that says "after every multi-file commit, run `git show --stat HEAD` to verify your stash-restore didn't desync" earned its place by catching a specific bug.

**Cheapest tier wins.** If a regex hook can prevent a class of bug at edit time, use the hook — don't write a rule, don't dispatch an agent. Reserve LLM tokens for problems that genuinely need judgment.

**War stories are first-class.** Every constraint should be traceable to a bug it prevents. If you can't write the war story, you don't have a constraint — you have an opinion. Opinions belong in style guides, not in load-bearing guardrails.

**No half-finished implementations.** When the kit catches a problem, the kit also provides the disciplined response. A hook that blocks raw hex without pointing at the design-token rule is incomplete. The artifacts cross-reference.

---

## License

MIT. See `LICENSE`.

---

Built on real workflows. Battle-tested. Anonymized for sharing.
