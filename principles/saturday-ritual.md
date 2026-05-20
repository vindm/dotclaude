# saturday-ritual — designing a weekly drift-detection cadence for ANY project (OPTIONAL)

Teaching material for Claude Code. When you bootstrap a project's AI dev infrastructure, this doc teaches you HOW to install a weekly maintenance ritual — a bounded recurring cadence that batches drift detection + design-debt review + skill audit into a single decision interface. Layer 7 of the v2 hierarchy.

**This principle is OPTIONAL.** Many projects don't need it. Ship default-off, surface as an opt-in. See *When to ship one* below.

## When to ship one (applicability gate)

Ship the Saturday-style ritual when:

- The project is > 3 months old AND has accumulated drift across at least one of: skills, docs, rules.
- The project has an active design-debt registry or audit pipeline that produces > 5 findings per month.
- The project has multiple contributors (team-shape) so drift accelerates relative to solo work.
- The project has had at least one *"oh, that skill doc described how the code worked 6 months ago"* moment. That's the symptom.

Skip when:

- The project is < 3 months old. Not enough drift to ritualize. Scaffold an opt-in stub if the project is on a trajectory toward needing the ritual; defer otherwise.
- The project is a throwaway prototype or 1-week sprint. Maintenance overhead exceeds value.
- The project is solo + small (< 30 files). The cost-benefit favors deferral; the developer's own attention substitutes for the ritual.
- The user explicitly prefers ad-hoc drift detection over a recurring cadence. Forced cadence on the wrong user produces ritual-skipping, which is worse than no ritual.

The default bias is **defer + scaffold the opt-in stub**. The artifact exists (so the user can flip it on later) but doesn't fire until activated. This is the most common shipping mode for greenfield + early-stage projects.

## Why it matters — what this catches that nothing else does

Long-lived projects drift. The ritual is the *drift-detection + correction loop* that keeps Layers 1-6 honest over time. Without it, three drift modes accumulate invisibly:

- **Skill drift.** `.claude/skills/<X>/SKILL.md` describes the code as of N months ago. The skill cites file paths that have moved, function signatures that have changed, grep patterns that no longer match. Claude consumes the stale knowledge and makes wrong recommendations. The session feels fine; the suggestion is wrong.

- **Doc drift.** `docs/flows/<arc>.md` describes the journey as of last redesign. The doc is referenced by conformance matrices as the *"matches what spec said"* baseline. If the doc is stale, matrices pass against the stale doc while diverging from current reality. The conformance bar erodes silently.

- **Rule drift.** `.claude/rules/file-size.md` says ceiling is 1000 LOC. The team's been routinely overriding via `// allow-large: <reason>`. The rule is dead; nobody enforces it; new files cluster around the override pattern. The rule book is fiction.

Each drift mode is invisible per-session and toxic across sessions. The ritual is the *detection* mechanism. Without detection, even an opinionated CLAUDE.md becomes lies-the-codebase-tells-itself within ~6 months.

The cost asymmetry: 30 minutes per week for the ritual. Catching one stale skill saves ~2 hours of session-confusion downstream. The breakeven is < 4 weeks of cadence.

## Core methodology — the four properties of a working ritual

Rituals fail when they lack any of these properties. Ship all four or ship none.

### Property 1 — Bounded time

Pick a cadence (weekly / biweekly / monthly) and a time-box (30 min / 1 hour). Stick to it. Variable cadence becomes no cadence — *"audit when you feel like it"* never happens consistently.

Default: **30 minutes / week**. Long enough to surface real findings, short enough that it never feels like overhead worth skipping. For very high-activity projects (5+ commits/day), consider 45 min / week. For very low-activity (1 commit/week), biweekly or monthly.

### Property 2 — Batch decision interface

Findings come in as a batch (one sheet). User marks each finding with one of:

- **F** — fix now. Claude implements during the week.
- **D** — defer (move to backlog).
- **?** — need more info. Claude investigates.
- **X** — won't fix / accept. Closes the finding with rationale.

The structured mark dictionary minimizes per-finding cognitive load. Reading findings one at a time, each with a *"should I fix this?"* mental load, is exhausting after 5 findings. The batch interface is what makes 30 findings feel like 30 minutes.

### Property 3 — Hooks first

Edit-time hooks prevent the most common findings *before they enter the registry*. The ritual is for the finds the hooks miss. Without hooks, the ritual gets overwhelmed by mechanically-preventable findings — *"another raw hex color, another forbidden phrase, another oversized file"* — and the higher-order findings get lost in the noise.

Install hooks first. Run the ritual against what hooks can't catch.

### Property 4 — Registry as canonical source

Open findings live in ONE doc: `docs/design-debt/registry.md` (or equivalent per project). No GitHub issues + Linear + Notion + chat-channel sprawl. The registry is the single source of truth; everything else is a view.

Without a single registry, findings duplicate across systems, get marked F in one place and X in another, and the user can't tell which findings are open.

## How to derive THIS project's specifics

Before authoring the ritual, gather:

1. **The cadence**. Ask: *"How often do you want to batch drift review? Weekly / biweekly / monthly?"* Default weekly. Confirm.

2. **The time-box**. Ask: *"How much time per cadence?"* Default 30 min. Confirm.

3. **The trigger**. Ask: *"When does the batch get prepared and when do you mark it?"* Default: Friday-evening audit runs, Saturday-morning mark. Confirm.

4. **The audit agents**. Which detection mechanisms feed the registry? Common: `design-token-auditor` (token sweep), `skill-auditor` (skill ↔ code consistency), `capability-map-auditor` (capabilities.md ↔ reality), `link-checker` (cross-link rot in docs).

5. **The registry location**. Default `docs/design-debt/registry.md`. Some projects prefer `docs/audits/_open-registry.md` or similar. Confirm.

6. **The implementer**. Who takes F-marked items during the week? Default: Claude implements one-per-commit during normal working sessions. Some projects have a designated "debt sprint" instead.

7. **The activation threshold**. When does the ritual graduate from deferred-stub to active? Default triggers:
   - Registry accumulates > 5 open findings.
   - `.claude/skills/<X>/SKILL.md` files reach age > 60 days without `Last verified:` update.
   - CLAUDE.md "Constraints" section grows by 3+ items in 30 days.

## Authoring guidance — what to write into the final artifact

The ritual lands in FOUR places:

### Place 1 — `.claude/rules/maintenance-ritual.md`

The operating-loop description (~80-150 LOC). Includes cadence, trigger, decision protocol, archive policy.

```markdown
# Maintenance ritual

**Cadence:** <WEEKLY | BIWEEKLY | MONTHLY>. **Time-box:** <N> minutes.

## The loop

1. **<TRIGGER>** (e.g. Friday evening) — run the audit batch:
   - <AUDIT_AGENT_1>
   - <AUDIT_AGENT_2>
   - <AUDIT_AGENT_3>
2. **<DECISION_INTERFACE>** (e.g. Saturday morning) — user marks each finding:
   - F = fix now
   - D = defer (move to backlog)
   - ? = need more info (Claude investigates)
   - X = won't fix / accept (closes finding with rationale)
3. **Implementation** — Claude takes F-marked items during the week, one PR/commit per item.
4. **Registry update** — `docs/design-debt/registry.md` reflects current state.

## Drift detection categories

- **Skill drift** — `.claude/skills/<X>/SKILL.md` describes code as of N months ago. Detection: `skill-auditor` agent reads skill + greps cited paths + checks they exist with cited shape. Cadence: monthly.
- **Doc drift** — `docs/flows/<arc>.md` describes journey as of last redesign. Detection: re-run flow capture + compare against doc's documented terminals. Cadence: quarterly.
- **Rule drift** — `.claude/rules/<X>.md` says X but override syntax used routinely. Detection: grep for override syntax across codebase, count occurrences, surface trend. Cadence: monthly.

## Activation triggers (if ritual is deferred-stub)

- Registry accumulates > 5 open findings.
- Skills > 60 days without `Last verified:` update.
- Constraints section grows by 3+ items in 30 days.
```

### Place 2 — `.claude/agents/skill-auditor.md`

The monthly agent that audits skills vs the code they describe. Reads each `.claude/skills/<X>/SKILL.md`; for each cited file path, code reference, or grep pattern: verifies the cited target still exists with the cited shape. Reports stale skills with severity tags:

- **CRIT** — skill is fundamentally wrong about current code.
- **MAJ** — skill is partially stale.
- **minor** — one minor inaccuracy.

Findings land in `docs/design-debt/registry.md` for user F/D/?/X marking.

### Place 3 — `docs/design-debt/registry.md`

The canonical open-findings registry. Format:

```markdown
# <PROJECT_NAME> design-debt registry

Open findings batched by the maintenance ritual. Marked F/D/?/X by user during weekly cadence.

## Open

| Date added | Source | Severity | Finding | Mark | Notes |
|---|---|---|---|---|---|
| 2026-05-17 | skill-auditor | MAJ | `skills/auth-navigation/SKILL.md` cites `app/auth/login.tsx` but file moved to `app/wizard/auth.tsx` | F | |
| 2026-05-17 | design-token-auditor | minor | `app/dashboard.tsx:42` raw hex `#ff5733` — should use `bg-accent` | F | |
| ... |

## Closed (last 30 days)

| Date closed | Mark | Finding | Resolution |
|---|---|---|---|
| 2026-05-10 | F | <finding> | Fixed in commit <SHA> |
| 2026-05-09 | X | <finding> | Accepted: <rationale> |
| ... |

## Archive

Findings closed > 30 days ago archived to `docs/archive/design-debt/<YYYY-QQ>.md`.
```

### Place 4 — `.claude/skills/audit-rituals/SKILL.md` (user-invocable)

A user-invocable skill that runs the weekly batch on demand. E.g. `/dotclaude:audit-week`. Reads the audit agents, batches findings into the registry, surfaces the new findings for marking.

This is what the user invokes during the ritual itself. Without the skill, the user has to manually dispatch each audit agent — adds friction that erodes the cadence.

## Depth signatures — what battle-tested looks like

The authored ritual fails the depth bar if it lacks any of these signals.

1. **Registry exists at `docs/design-debt/registry.md`** (or equivalent path). Test: `ls docs/design-debt/registry.md` resolves.

2. **Weekly cadence is calendared or automated.** Either user has a calendar reminder, or a CI job runs the audits on a schedule. Without enforcement, the cadence drifts to *"when I remember"* (never).

3. **Marks dictionary is documented.** F/D/?/X (or equivalent) defined in the registry header. Without the dictionary, marks become inconsistent across weeks.

4. **Closed items archived, not deleted.** Closed findings move to a closed-section after 30 days, then to `docs/archive/design-debt/<YYYY-QQ>.md`. Recovery is possible; history is preserved.

5. **Hooks installed first.** `.claude/hooks/` has the mechanical-prevention hooks (token-only, forbidden-phrases, file-size) BEFORE the ritual runs. Otherwise the ritual drowns in mechanically-preventable findings.

6. **Skill-auditor agent exists and runs monthly.** Detects skill drift. Without it, skills rot invisibly.

7. **The ritual references the registry, not chat / issues / external tools.** Single source of truth.

8. **The activation threshold is named** (for deferred-stub mode). Without it, the stub stays stub forever; no signal triggers promotion.

9. **The implementer assignment is clear.** Who takes F-marked items? Claude during sessions? A designated debt-sprint? Without assignment, F items pile up.

10. **The ritual is bounded.** Time-box is named (30 min). Not *"audit when you can."* Bounded time is what makes the ritual sustainable.

If the authored ritual lacks any of these, redo. A ritual without all four properties is a ritual that gets skipped.

## Universal patterns by project type

The cadence + decision interface generalize across project types; the audit categories vary.

### For a UI-heavy project

Audits: `design-token-auditor` (token sweep), `interaction-audit-sweep` (semantic chrome drift), `skill-auditor`, `link-checker`. Cadence: weekly.

### For a backend-heavy project

Audits: `data-auditor` (schema drift), `rls-security-reviewer` (RLS drift), `skill-auditor`, `dependency-auditor` (lockfile age). Cadence: biweekly.

### For a library / SDK

Audits: `api-surface-auditor` (public API drift), `skill-auditor`, `doc-sync-auditor` (docs ↔ code). Cadence: monthly.

### For a docs site

Audits: `link-checker` (cross-link rot), `render-auditor` (broken builds), `skill-auditor`. Cadence: weekly.

### For a research prototype

Skip the ritual. Add only when the prototype graduates to a shipped product.

## Anti-patterns to avoid

- **Ritual without batch decision interface.** Without F/D/?/X marks, the user reads findings one at a time, each with a *"should I fix this?"* mental load — exhausting after 5 findings. The batch interface is what makes 30 findings feel like 30 minutes rather than 3 hours.

- **Ritual without hooks installed first.** The ritual surfaces *every* class of finding, including the mechanical-prevention ones that hooks would catch. The signal drowns. Install hooks first.

- **Ritual without a registry.** Findings live in chat / GitHub issues / scattered. No single source of truth means findings duplicate, get inconsistent marks, get lost.

- **Cadence without time-box.** *"Weekly"* without *"30 min"* — sessions stretch to fill available time, get skipped when busy. Time-box is what makes the cadence sustainable.

- **Time-box without cadence.** *"30 min when I feel like it"* — never happens. Cadence is what makes the time-box realizable.

- **Ritual that doesn't archive closed items.** Closed findings stay in the open list, growing indefinitely. The registry stops being scannable. Archive on close.

- **Ritual that deletes instead of archives.** Once closed, the finding's context is gone. *"Why did we decide to skip X?"* — unanswerable. Archive, never delete.

- **Ritual graduated from stub to active without the activation triggers firing.** Premature activation produces empty registries; the cadence runs against nothing; the user stops trusting the ritual. Wait for triggers.

- **Implementer assignment ambiguous.** F-marked items pile up because nobody owns them. Make the assignment explicit (*"Claude during normal sessions"* / *"designated weekly debt-sprint"*).

- **Ritual that surfaces only mechanical findings.** If every Saturday review surfaces hex-color and file-size violations, the ritual is doing hook work. The ritual should surface higher-order findings (skill drift, doc drift, rule drift, capability-map drift). Mechanical findings should be hook-prevented or zero.

- **Multiple registries.** *"Design debt here, security debt over there, code debt somewhere else."* Three registries = three lookups = effectively no registry. Consolidate or accept the cost.

- **Ritual that doesn't update CLAUDE.md when discipline shifts.** If the ritual surfaces *"rule X has been overridden 20 times"* — the rule is dead. Either retire the rule (update CLAUDE.md), or strengthen enforcement. The ritual's job is detection; the *consequence* of detection is updating the canonical sources.

## Cross-references

- `knowledge-graph.md` — Layer 5. The registry lives in `docs/design-debt/`; the archive policy applies. Without the knowledge graph, the registry has no home.
- `task-classification.md` — Layer 3. Drift findings F-marked become routed work (UI fix → UI feature row, skill update → docs row). The ritual feeds the routing table.
- `memory-system.md` — Layer 3. Memory archive cadence is part of the ritual; without the ritual, memory bloats. The ritual sweeps both.
- `plan-driven-work.md` — Layer 3. Plan-backed work produces conformance matrices that themselves can drift; the ritual audits matrix-vs-reality on long-lived flows.
- `project-identity.md` — Layer 1. Identity sets the project's maturity tag; ritual is only applicable to mature projects.
- `skill-vs-code-audit.md` — Layer 6 coding kit. The `skill-auditor` agent's methodology; the ritual is the cadence under which the agent runs.
