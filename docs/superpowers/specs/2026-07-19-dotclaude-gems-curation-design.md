# dotclaude → gems: curation & consume-direct redesign

**Date:** 2026-07-19
**Status:** design, pending author review
**Author:** Dima Vinokurov (with Claude)

## Problem

dotclaude has grown into a sprawling suite — 14 agents, ~22 skills, ~40 principles,
~10 guard hooks, plus a bootstrap generator and per-domain generators. The author's own
read: *"the project is overloaded and nobody will use it this way."* The pain is not
personal ergonomics — it is that a plugin promising ~22 things at once promises nothing a
new user can grab onto. There is no single hook.

Two curation criteria were named, and they point in different directions:

- **Proven by use** — keep what actually runs on live projects. Confirmed against
  `saldo-project`: `pre-flight` is installed locally, the `check-main-checkout-edit` hook
  is wired live with a test, and dozens of real `git worktree add/remove ../saldo-wt-*`
  calls show the worktree discipline runs in anger.
- **Uniqueness** — measured concretely against what already ships in this environment:
  the `superpowers` plugin and Claude Code built-ins (`/code-review`, `/init`,
  `/security-review`, the `frontend-design` skill). A dotclaude tool that duplicates a
  built-in is not a gem, however good.

## Decision

Adopt **Variant C — split into two focused plugins in one repo** — combined with a
**consume-direct redesign** of how project-specific tuning works.

The headline reframe that fell out of reading the code: the project already solved the
right architecture in its **design** flow, and simply never propagated it to the other
domains. The redesign generalizes the design pattern to every surviving domain.

## Core architecture principle

Every domain needs to adapt to a project. There are exactly three adaptation mechanisms,
and the right one depends on whether "good" is derivable from the code:

| What we adapt to | Mechanism | Needs a generator? |
|---|---|---|
| Facts of the code (stack, schema, file-size distribution, bug/revert history) | the tool reads it at runtime | no |
| Machine-readable knobs (file ceiling, import boundaries, forbidden-phrase list, commands) | `dotclaude.yml`, tool reads the file | no |
| Human intent — *"what does good mean to you here"* — not in the code | a **focused per-domain interview** → writes a thin, agent-read artifact | no (this is elicitation, not tool-generation) |

### The finding that drove this

Reading every domain interview (`coding/interview.md`, `data`, `testing`, `ai-workflow`,
`planning`) showed that **each domain has its own un-derivable question**, flagged in the
files themselves as "THE most important question." They are the same category as design's
north-star — *"what does good mean to you here"* — just aimed at a different surface:

| Domain | The un-derivable question | What it configures |
|---|---|---|
| coding | "name 2-4 bugs you wish a reviewer had caught" (C3) | the reviewer's project-specific anti-patterns |
| testing | "which untested module scares you most?" (T3) | priority #1 in the risk table |
| data | "when was the data wrong even though the code was right?" (D4) | the auditor's project-specific checks |
| planning | "which 2-3 kinds of change keep breaking multiple modules?" (P2) | pre-flight's integration-point map |
| ai-workflow | "your pain threshold on the bill + past surprises" (AI2/AI4) | the cost-watcher's alarm thresholds |
| design | "which apps are your bar? open each one" | the north-star for the taste audits |

Two consequences:

1. **Design is not special** — it is one of six domains with a genuinely un-derivable
   elicitation. It only *looked* special because it already uses the right architecture.
2. **Per-domain interviews beat one big bootstrap interview.** Each domain's depth is
   specific (bug classes ≠ risk modules ≠ benchmark apps ≠ cost tolerance). A single
   mega-interview would either ask twenty questions at once or flatten the depth to
   platitudes. Separate focused interviews keep the depth and let a user run only the
   domains they care about.

### What dies vs what transforms

Today's domain generators bundle two jobs:

1. **Elicit un-derivable intent** — the focused interview. *Keep.*
2. **Author a project-local COPY of the agent** (`code-review`, `data-auditor`,
   `ux-audit`) with that intent baked into a frozen file. *Cut* — it duplicates the
   consumed agent and rots (this is precisely the drift `skill-vs-code-audit` exists to
   clean up).

The design flow already does it right: *elicit → write a thin `north-star.md` → the
consumed `ux-audit` reads it at runtime.* Every surviving domain adopts this exact shape:

> focused per-domain interview → writes a thin, human-readable artifact
> (bug-classes / risk-model / north-star) → the **consumed** universal agent reads it
> at runtime. No generated agent copies.

**Key implementation requirement:** the consumed agents (`code-review`, `test-architect`,
etc.) must be taught to look for and read their domain artifact from `.claude/`, falling
back to sane defaults when it is absent. Today only the design audits read a project
artifact; the others rely on generated copies. Wiring the consumed agents to read the
artifact is the load-bearing change.

## Packaging & repo layout

One repository, one `marketplace.json`, two independently-installable plugins. Not two
repos — a single history, one `git clone` for evaluation, one CONTRIBUTING.

```
dotclaude/                              (repository)
├── .claude-plugin/marketplace.json     → declares 2 plugins
├── plugins/core/                       → plugin "dotclaude"
│   ├── agents/  skills/  hooks/  principles/
└── plugins/design/                     → plugin "dotclaude-design"
    ├── agents/  skills/  principles/
```

Each plugin's description carries **one** promise:

- **dotclaude** — "a senior who won't let you shoot your own foot": parallel-session
  isolation, blast-radius pre-flight, guard hooks, graded code review, coverage by risk.
- **dotclaude-design** — "the AI design/UX auditor nobody else has": figures out what
  good looks like for your product, then holds every screen to it.

## The manifest

### CORE — plugin `dotclaude`

**Consumed proven agents (read the project at runtime):**
`worktree` · `pre-flight` · `code-review` · `decomposition` · `test-architect`

**Guard hooks (unique — superpowers has none):** secrets-in-commit, force-push,
file-size ceiling, forbidden-phrases, main-checkout guard, import-boundary, no-console,
no-todo, prebuild-required, regen-generated-artifacts.

**Always-on base:** `operating-discipline` (kept by author's decision despite partial
overlap with superpowers — it is the connective tissue of the core).

**Direction guardian:** `product-direction-validator` — audits work against the stated
product direction and catches feature-creep. No proven alternative exists in superpowers
or the built-ins, so it stays; it lives in CORE rather than the design plugin because it
is a direction/discipline instrument (a senior asking "does this serve what we're
building?"), not a visual concern — and keeping it out of DESIGN preserves that plugin's
sharp "design auditor" hook.

**Doc/artifact drift auditor:** `skill-vs-code-audit` — kept in CORE, light. Less
generation means less drift, but the surviving thin artifacts (bug-classes, risk-model,
north-star) reference code paths and rot; this is what it now guards.

**Per-domain elicitation skills (transformed — elicit only, no agent-copy authoring):**
- coding → writes the bug-classes artifact + `dotclaude.yml` ceiling/exemptions.
- testing → writes the risk-model artifact.

**Config + thin generator:** the `dotclaude.yml` schema, and a thin `bootstrap` that
authors only human-intent identity/architecture/quality-bar + wires config-needing hook
templates. Bootstrap becomes an optional orchestrator; each domain skill also runs
standalone.

### DESIGN — plugin `dotclaude-design`

**The brain — north-star elicitation (first-class, the headline):**
the `design-benchmarking` methodology, supported by `journey-mapping` and
`persona-testing` as its craft.

**Taste audits (near-useless without the north-star, hence the brain matters):**
`ux-audit` · `flow-audit` (merged, see below) · `pages-audit`

**Objective audits (work standalone against rules/HIG — bonus):**
`a11y-audit` · `interaction-audit` · `design-token-audit`

`flow-audit` and `flow-continuity-review` **merge into a single `flow-audit`** with two
input modes (walk a live flow, or grade a pre-captured ordered screenshot series). They
graded the same thing — multi-screen continuity — and differed only in input; merging
drops a confusing near-duplicate (7 audits → 6).

**Supporting:** `element-reuse` micro-skill · `iterative-polish-autoloop`.

**`product-designer`** — the "what to build" front (idea → IA/flow spec) that feeds the
audits. It **overlaps** superpowers `brainstorming` (idea → design → spec); kept because
it is deeper and UI-specialized (IA + per-screen state inventory + considered-and-rejected
+ engine-asks, refuses single-screen polish). This is a "deeper for the UI niche"
argument, not "no alternative" — flagged honestly.

### CUT — remove in both plugins

- **Box-duplicates:** `authoring-skills` (= superpowers `writing-skills`) ·
  `plan-driven-work` (= `writing-plans` + `executing-plans`) · `memory-system`
  (= built-in memory) · `handoff` · `saturday-ritual` (optional, niche).
- **The tool-copy-authoring half** of every generator (the surviving domains keep only
  the elicitation half).
- **`init`** — the orchestrator exists only to chain generators.

### DEFER — not cut, revisited later

- **`data` domain** — `data-integrity`, `migration-create` (unique, but only DB projects).
- **`ai-workflow` domain** — the eval-cost-watcher (niche, only AI projects).

These are unique enough to keep eventually; they just don't ship first-class now. Park
them behind a documented "later domains" note rather than deleting the work.

## Sequencing

1. **Phase 1 — cut the box-duplicates** (5 skills). Unambiguous and risk-free; the
   monolith immediately gets leaner and more honest.
2. **Phase 2 — transform coding & testing generators** to elicitation-only, and wire the
   consumed `code-review` / `test-architect` agents to read their `.claude/` artifact
   (with default fallback). Prove the pattern on coding first, then testing.
3. **Phase 3 — physically split** CORE vs DESIGN into two plugins, rewrite
   `marketplace.json` and author two single-promise READMEs.
4. **Phase 4 — defer data / ai-workflow** behind the "later domains" note.

## Resolved decisions

1. **`product-direction-validator` → CORE.** No proven alternative exists, so it stays; it
   sits in CORE as a direction/discipline instrument, not in DESIGN. (See the CORE
   manifest.)
2. **`skill-vs-code-audit` → keep, CORE, light.** It now guards drift in the surviving
   thin artifacts, which reference code paths. (See the CORE manifest.)
3. **`flow-audit` + `flow-continuity-review` → merge into one `flow-audit`** with two input
   modes (walk live / grade a pre-captured series). Design audits go 7 → 6. (See the DESIGN
   manifest.)
4. **`dotclaude.yml` vs `.claude/settings.json` boundary.** The rule: anything Claude Code
   itself reads (permissions, hook registrations) lives in `settings.json`; anything only
   dotclaude's own tools read lives in `dotclaude.yml`. Concretely — a hook is *registered*
   in `settings.json` (Claude Code runs it), but its thresholds and config (file ceiling,
   import-boundary rules, forbidden-phrase list, design-token theme path, and the locations
   of the domain artifacts) live in `dotclaude.yml`, which the hook script and the consumed
   agents read. This matches the existing bootstrap design.

## `product-designer` — a noted overlap, not an open decision

Kept in DESIGN despite overlapping superpowers `brainstorming`; the rationale (deeper,
UI-specialized) is recorded in the DESIGN manifest. Revisit only if `brainstorming`'s spec
output later closes the IA-depth gap.

## Non-goals

- Not rewriting the auditor agents' methodology — only their input source (read a project
  artifact instead of being generated).
- Not deleting the deferred data/ai-workflow work — parking it.
- Not chasing a raw feature-count target. The win is coherence and a single promise per
  plugin; the honest reduction is the 5 box-duplicates + the tool-copy-authoring half of
  the generators, plus shipping fewer first-class domains (design, coding, testing).
