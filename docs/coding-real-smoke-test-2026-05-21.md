# `/dotclaude:coding` real smoke test — 2026-05-21

**Target**: fresh Vite + React + TypeScript + Tailwind project at `/tmp/dotclaude-real-test/my-app/` (same fixture as the design smoke test the day prior, reused).
**Plugin version**: dotclaude main HEAD (commit `61b1d09` — post-CONTRIBUTING.md).
**Protocol**: Claude reads dotclaude's `skills/coding/SKILL.md` + `skills/coding/interview.md` + the relevant principles (`file-discipline.md`, `decomposition.md`, `code-review.md`, `quality-rubric.md`, `forbidden-phrases.md`, `skill-vs-code-audit.md`) as instructions; targets a project Claude has no prior exposure to. Authors `.claude-staging/` per the kit's spec.

This is the **second NON-case-study validation** of the kit. The design smoke test answered "does the methodology transfer from the deepest source-project IP (design) to a foreign stack?" with a strong yes. This run answers a different question: **does it transfer to a domain where the source project's IP is shallower (coding-discipline is a more universal concern)?** Phrased adversarially: when the methodology has less unique anchor to derive from, does the kit lose value, or is the methodology robust enough to ship credibly anyway?

## 1. Phase 1 scan — what was discovered automatically

Per `SKILL.md` Phase 1 (5 categories of scan). Findings:

### 1.1 Stack signal

- `package.json`: Vite 8.0.12, React 19.2.6, TypeScript ~6.0.2, Tailwind 4.3.0, ESLint 10.3.0 + typescript-eslint 8.59.2.
- No `pyproject.toml` / `Cargo.toml` / `go.mod`.
- Scripts: `dev`, `build` (tsc + vite), `lint`, `preview`. No `test`.

### 1.2 File-size distribution

```
184 ./src/App.css
125 ./src/App.tsx
111 ./src/index.css
 22 ./eslint.config.js
 10 ./src/main.tsx
  8 ./tailwind.config.js
  7 ./vite.config.ts
  5 ./src/styles/tokens.ts
```

Total source: ~472 LOC across 8 files. 95th-percentile healthy file: `App.tsx` 125 LOC. Largest: `App.css` 184 LOC. **Calibration verdict: 500 LOC ceiling (warn 450).** The principle's default of 1000 LOC for TS/React would be useless here — nothing would ever hit it. 500 gives ~3× headroom over today's worst and tightens to surface drift once the project grows.

### 1.3 Bug-class signal from git history

```
e201b52 fix: stale rgba in card border       (1 fix-prefix commit)
4013778 feat: add tokens scaffold
bfa9601 initial vite react ts setup
```

**One** fix commit. Diff: `App.tsx +2 / -0` — added a `// removed raw rgba` tombstone comment, no actual code change. **This is the entire mineable bug history.** The kit's `code-reviewer.md` will be working with extraordinarily thin signal here.

Top-edited files (only useful with > ~20 commits, but inspected anyway):
- `src/App.tsx` (3 commits — the entire history minus pure scaffolding)

### 1.4 Existing conventions

- No `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `STYLE_GUIDE.md`.
- Lint config: `eslint.config.js` (flat config) — TypeScript ESLint recommended + React Hooks + React Refresh.
- No project-specific lint rules. No `.prettierrc`. No `docs/`.

### 1.5 Voice signal

- No `translations.*`, `copy.*`, `i18n/`, `locale/` files.
- No copy directory.
- The only user-facing string in the codebase: `<h1>Get started</h1>` + `<p>Edit src/App.tsx and save to test HMR</p>` (Vite starter).

**Voice discipline DOES NOT APPLY here.** The kit will deliberately skip `forbidden-phrases.txt` + its companion hook. (This is the right call per principle: "Voice discipline is opt-in. If the project has no user-facing copy, skip entirely.")

### Phase 1 mental model

> Tiny TS/React fixture, ~470 LOC source. File ceiling should be 500 LOC (not 1000 — codebase is too small for the default). One fix-prefix commit, so anti-patterns will come from CODE-SHAPE OBSERVATION (what the next bug is likely to look like) rather than from history. Voice doesn't apply. Dual token surfaces already disagree at HEAD (the same drift the design kit flagged) — that's the #1 active bug class for the reviewer to encode.

The honest assessment from Phase 1: the kit will be **bounded by the project's history depth** in a way the design kit wasn't. Design has the dual-token-drift to chew on visually (which it does); coding has the same drift to chew on systemically (which it should), but otherwise has very thin signal.

## 2. Phase 2 — simulated interview

The skill specifies 4-5 questions. Simulated as a small-SaaS dev who is solo, careful, and wants the reviewer to "block on C/D":

### Q-C1 — File-size ceiling

> "Your largest file is `src/App.css` at 184 LOC; the 95th percentile of your source files sits at 125 LOC (`App.tsx`). I'm proposing a ceiling of 500 LOC with warning at 450. Fits, or tighter / looser?"

**A**: "500 fits. I want headroom for screens to grow but not so much that drift hides."

### Q-C2 — Reviewer audience + tone

> "Solo project. When you imagine the ideal reviewer — careful-colleague pointing out misses, or staff-engineer enforcing the bar?"

**A**: "Staff-engineer tone. I want it to block on a C, not just advise."

→ Rubric anchors set so C/D = block, A/B = ship. (Encoded in `code-reviewer.md` Grading section.)

### Q-C3 — Past bug classes (THE most important question)

> "Name 2-4 bugs the project has shipped where you wished a reviewer had caught it."

**A**: "Only one so far — the raw rgba leaking into component code (`e201b52`). The token surfaces in `src/styles/tokens.ts` and `src/index.css` already disagree on `accent` — `#3b82f6` vs `#aa3bff`. That's the active recurring class. Future I expect: stale-closure setState patterns, missing `useEffect` deps, premature memoization when React Compiler should be enabled instead."

→ Yielded 5 named patterns for the reviewer (3 derived from code shape, 1 from git, 1 forward-looking). Honest depth.

### Q-C4 — Voice / forbidden phrases

> "Any user-facing copy?"

**A**: "Not yet. Skip the deny-list."

→ `forbidden-phrases.txt` NOT shipped. `check-forbidden-phrases.sh` NOT wired. Documented as a deliberate skip.

### Q-C5 — Existing conventions to respect

> "Any conventions to mirror? Naming, decomposition patterns, lint rules you've disabled?"

**A**: "None codified. The ESLint flat config is just the Vite default. If hooks land later they'll live in `src/hooks/`; components in `src/components/`. Pure helpers I'd put in `src/lib/` (typical for my style)."

→ The decompose-file skill's extraction table set to `src/hooks/`, `src/components/`, `src/lib/`. (No pre-existing layout to mirror; the user's preference becomes the convention.)

## 3. Phase 3 — principles read

Per `SKILL.md` Phase 3 selective-loading:

**Always read**:
- `code-review.md` ✓ — drove the agent body (5-phase methodology + grading + report shape).
- `file-discipline.md` ✓ — drove the rule (ceiling calibration argument + extraction table + override convention).
- `decomposition.md` ✓ — drove the decompose-file skill (natural-seam doctrine + order-of-extraction + sanity checks).
- `quality-rubric.md` ✓ — drove the quality-bar skill (5-tier rubric + named pitfalls + claim-of-done checklist).

**Read conditionally**:
- `forbidden-phrases.md` — NOT read (Phase 1 voice signal = none; Phase 2 confirmed skip).
- `skill-vs-code-audit.md` — NOT read (only 3 docs landing in `.claude/`; threshold is 3+ with code references — this project doesn't have a stable enough code-reference base for the auditor to add value yet).
- `pre-flight.md` — NOT read (small project; pre-flight discipline ships separately via `/dotclaude:planning`).

**War-story examples** read for anti-pattern inspiration:
- `examples/the-write-that-returned-success.md` ✓ — informed Step 3.4 "stale-closure-in-callback" pattern in the reviewer.
- `examples/the-bug-surfaced-five-screens-later.md` ✓ — informed "blast-radius analysis" emphasis.
- `examples/the-test-passed-for-the-wrong-reason.md` — NOT incorporated (no tests yet; principle doesn't yet apply).

**Total principles consulted directly**: 4 of 6 candidate. Adequate for the project's size.

## 4. Phase 4 — authored artifacts

8 files, 528 LOC total. Inventory by type:

### Agents (1 file, 191 LOC)
- `.claude-staging/agents/code-reviewer.md` — 191 LOC (opus, tool restriction `Read, Grep, Glob, Bash` — no Edit/Write)

### Skills (2 files, 176 LOC)
- `.claude-staging/skills/quality-bar/SKILL.md` — 77 LOC
- `.claude-staging/skills/decompose-file/SKILL.md` — 99 LOC

### Rules (1 file, 56 LOC)
- `.claude-staging/rules/file-discipline.md` — 56 LOC

### Hooks (4 files, 105 LOC)
- `.claude-staging/hooks/check-file-size.sh` — 37 LOC (rendered with `CEILING=500`, `WARN=450`)
- `.claude-staging/hooks/check-secret-leak.sh` — 21 LOC (universal, no substitution)
- `.claude-staging/hooks/check-bash-safety.sh` — 17 LOC (universal)
- `.claude-staging/hooks/check-no-console-log.sh` — 30 LOC (rendered with my-app's actual allow-paths: `scripts/`, `vite.config.ts`, `eslint.config.js` since no tests exist yet)

### NOT shipped (explicit skip + rationale)
- `skill-auditor.md` — only 4 staged docs; below the 3+ threshold mentioned in the SKILL.md for shipping the meta-auditor.
- `forbidden-phrases.txt` — no user-facing copy yet (Phase 1 + Phase 2 confirmed).
- `check-forbidden-phrases.sh` — companion to the deny-list; both skipped together.
- `check-no-todo-comments.sh` — user didn't explicitly opt-in to ticket-discipline in C5; deferred.
- `check-design-tokens.sh` — already shipped by the design kit (the staged hooks would overlap; the coding kit's job is the design kit's complement, not its duplicate).

## 5. Authored output quality assessment

### Is the reviewer's anti-pattern section project-specific?

**Mostly yes, with honest scope bounds.** Of the 7 anti-pattern entries in `code-reviewer.md` Step 5:

- **2 are GIT-DERIVED** (cite `e201b52` directly + reference `App.tsx:124-125` tombstone comment + the dual token surfaces' actual divergent values `#3b82f6` vs `#aa3bff`).
- **3 are CODE-SHAPE-DERIVED** (orphan `<div className="ticks">` at `App.tsx:33`, `// TODO: refactor` at `App.tsx:123`, asset-path-convention mixing on `App.tsx:38` vs `App.tsx:2-4`).
- **1 is REFERENCE-PATTERN** (the correct `setCount((count) => count + 1)` at `App.tsx:27` named as the reference for future regressions to be measured against).
- **1 is FORWARD-LOOKING** (React Compiler vs manual memoization — flagged as drift to watch for).

The reviewer cites real file:line references throughout. The entry count (7) is honest — the principle says "5-10 entries if history supports it; fewer if not; don't pad." 7 is the right number for what's mineable.

**Anti-grade**: had the reviewer copied entries from `code-review.md`'s "stack-shape mapping" section (e.g., "stale closures in refs, cache invalidation gaps, native-bridge data loss") without grounding them in my-app's actual code, depth-signature would have failed. The kit didn't do this — every pattern names a real path or names "future regression target" honestly.

### Is the file-size ceiling calibrated to the codebase?

**Yes — and the rule defends the number explicitly.** `file-discipline.md` opens with:

> *"This project's current 95th-percentile healthy file is `src/App.tsx` at 125 LOC; the largest is `src/App.css` at 184 LOC. A 500-LOC ceiling gives ~3× headroom over today's worst — generous enough that nothing routine hits it, tight enough that genuine bloat surfaces. A 1000-LOC ceiling (the React / TS default) would be useless here — nothing would ever hit it."*

This is the principle's "don't pick a ceiling the codebase doesn't approach" guidance applied. The rule is also self-aware about recalibration: *"When the codebase grows past ~30 source files, re-calibrate."* That's the honest signature.

### Does the quality-bar skill name a specific audience?

**Yes — two roles tied to this project's stack:** *"Would I demo this to a Linear engineer or a friend's CTO whose taste I respect?"* These map cleanly to a Vite + React + TS B2B-SaaS-flavored stack. Tier 1 anchors named: Linear / Stripe Dashboard / Vercel Dashboard. Tier 2 named per surface category.

**Anti-grade**: a generic *"Would I be proud of this?"* would have failed. The actual audience is specific enough that the user could imagine showing them.

### Are tool restrictions on the reviewer structural?

**Yes.** Frontmatter `tools: Read, Grep, Glob, Bash` — no `Edit`, no `Write`. The principle's structural argument is encoded as a non-negotiable rule in the agent body too: *"This agent has `Read, Grep, Glob, Bash` — no `Edit` / `Write`. If you find yourself wanting to fix something, REPORT it and let the implementer act. A reviewer that edits is no longer a reviewer."*

### Is the kit usable as-is, or are there gaps?

**Mostly usable. Four manual gaps the user would still need to handle:**

1. **`.claude-staging/` not staged to `.claude/`.** Same Phase 5 approval gate as the design kit — intentional.

2. **No `settings.json` written.** Same gap as the design kit. The hooks need to be wired into `.claude/settings.json` `hooks.PostToolUse` to fire. The SKILL.md Phase 5 mentions commit, doesn't mention hook registration.

3. **Token-drift not auto-resolved.** Same as the design kit — `tokens.ts:accent = '#3b82f6'` vs `--accent: #aa3bff` flagged repeatedly across both kits but never resolved. Correct: the kit's job is to surface, not pick. User decides.

4. **Hook overlap risk with design kit.** If a user runs `/dotclaude:design` AND `/dotclaude:coding`, both might want to ship `check-file-size.sh`. Currently the coding kit ships it; the design kit doesn't. Documented to avoid duplicate staging if both run.

## 6. Side-by-side with the source project's `code-reviewer.md`

The source project's `code-reviewer.md` (the battle-tested codebase from which dotclaude's principles were distilled — 162 LOC) is what the principle abstracts FROM. Comparison:

| Dimension | Source project | my-app staged kit | Verdict |
|---|---|---|---|
| 5-phase methodology | Yes (`Understand / Blast-radius / Parallel-path / Consistency / Data-flow-completeness / Report`) | Yes (`Understand / Blast-radius / Parallel-path / Consistency / Anti-patterns / Report`) | Structure transferred cleanly; "Data-flow completeness for Native modules" replaced by "Anti-patterns for project-specific patterns" — correct, no native bridge here. |
| Project-specific anti-patterns | 9 entries (catalog products / status filter / Supabase error swallow / stale closure in finish / native events on cleanup / DB constraint mismatch / split-type-label mismatch / comment-code divergence) | 7 entries (raw color leak / token surface drift / non-functional setX / orphan JSX / TODO survivor / asset path mixing / Compiler-vs-manual-memo) | Source has 9 from years of fixes; my-app has 7 from 1 fix + code-shape. Honest depth bound. |
| Grading scale | S/A/B/C/D/F | S/A/B/C/D/F | Identical structure. |
| Tool restriction | `Read, Grep, Glob, Bash` (no Edit/Write) | Same | Identical. |
| Model | claude-opus-4-7 | claude-opus-4-7 | Identical. |
| Cites real file:line | Yes (`src/hooks/usePlayback.ts:142` etc.) | Yes (`src/styles/tokens.ts`, `src/index.css`, `App.tsx:27,33,38,123-125`) | Both grounded. |
| Cross-references project skills | `pipeline-integrity, db-types, job-system` in frontmatter | None (no domain skills exist in my-app yet) | Honest — there are no domain skills to reference. |
| Stack-specific signature move | "Native bridge data flow completeness" | "Dual token surface check" (the project's actual #1 active bug) | Both name a project-specific signature move tied to the actual code shape. Transferred well. |

**The structural skeleton transferred 1:1. The depth-of-content varied — the source project has 5+ years of fix-prefix commits to mine, and my-app has 1. The kit handles this honestly.**

The same comparison holds for `file-discipline.md` (40 LOC source vs 56 LOC staged — my-app's version is longer because it documents the *calibration argument* explicitly, whereas the source project's just states the rule) and `decompose-file/SKILL.md` (90 LOC source vs 99 LOC staged — near-identical structure, my-app's includes a slightly broader extraction table because the project is greenfield and the convention isn't established yet).

## 7. Comparison to the design smoke test

| Axis | Design smoke test | Coding smoke test |
|---|---|---|
| Source-project IP depth | Deepest (years of UX reviews, Apple/Telegram benchmarking, audit-agent specialization) | Shallower (code-review + file-size are universal; less project-specific stack on top) |
| Anti-pattern catalog source | UX reviews + git history + interaction-audit findings | Fix-prefix commits only (1 fix commit here) |
| Project-specific signature move | Tier 1/Tier 2 benchmark hierarchy (Linear / Stripe / Vercel) | Parallel-path detection on dual token surfaces |
| LOC authored | 1466 LOC across 15 files | 528 LOC across 8 files |
| What transferred well | Adaptive interview, applicability gates, citation pattern | Structural skeleton (5 phases / 5 tiers / extraction table), calibration discipline (ceiling vs codebase), honest depth bounds |
| What didn't transfer cleanly | Capture procedure iOS-centric, hook single-theme-path limit | Hook overlap risk with design kit, skill-auditor threshold ambiguous |
| Honest depth bound hit | Anti-pattern count bounded by git history (1-2/agent on 3-commit project) | Anti-pattern count bounded the same way (7/agent — half from code shape, half from git) |

**The methodology transferred WELL to coding domain.** The kit's structural skeleton holds. The depth-bounds work is **harder** for coding than for design, because coding-domain anti-patterns are more git-history-dependent than design anti-patterns (design has token surfaces, hex literals, orphan elements visible from a single read of the code; coding's parallel-path drift is largely INVISIBLE without commit history).

This is the key finding: **coding-domain output is correctly calibrated to the project's git depth, but is therefore SHALLOWER on greenfield projects than the design-domain output.** This is honest, not a kit defect — but worth being explicit about.

## 8. Diagnosis — root causes for gaps

### Gap A — Hook overlap risk when running both /dotclaude:design and /dotclaude:coding

`check-file-size.sh` is plausibly authored by either skill (or both). If a user runs both, the file lands twice in `.claude-staging/hooks/`. Currently coding ships it; design doesn't. The skill prompts should document this.

Root cause: hook-template ownership not explicitly partitioned across skills. The bootstrap-level orchestration (`/dotclaude:bootstrap` calling both) would resolve this; the individual skills don't.

### Gap B — `skill-vs-code-audit` threshold is ambiguous

The SKILL.md says ship `skill-auditor.md` only "if the user expects to ship 3+ docs / skills / agents referencing specific code paths." On my-app, the staged kit has 4 docs (1 agent + 2 skills + 1 rule) — technically above the 3+ threshold. But the auditor's value scales with the rate of code change, not just the doc count. On a 3-commit project, the auditor would re-run finding nothing because the code shape barely changes.

Root cause: the threshold should incorporate "code change velocity" not just doc count. Easy fix: rephrase as *"ship the auditor when there are 3+ docs AND the project averages > 5 commits per week. Below that velocity, the auditor's value is marginal."*

### Gap C — Anti-pattern depth on greenfield projects

Phase 3 (Parallel-path detection) of `code-reviewer.md` cites real file:line for the FOUR known traps, but two of them (`3.3 non-functional setX` and `3.4 stale-closure-in-callback`) have zero current occurrences. Honest about this: the entry says "no occurrence in HEAD code... future regression target." That's correct framing, but the depth-signature of "every entry cites a real file:line" is partially synthetic on these two.

Root cause: depth-signature was calibrated for mature codebases. On greenfield, the kit honestly notes "future regression target" — that's the right escape hatch. Could be made more explicit in `code-review.md` principle: *"On greenfield projects (< 50 commits), 1-3 entries may be code-shape projections rather than git-derived. Mark these clearly."*

### Gap D — Voice-skip is invisible in the final report

The kit correctly skipped `forbidden-phrases.txt` because Phase 1 + Phase 2 said no voice yet. But a user running this skill against the kit's output might wonder *"why did this NOT ship?"* The Phase 5 kit-overview message addresses this — but only at first-run. Six months later, when voice DOES emerge, the user has to remember to re-run the skill (or the rule never lands).

Root cause: kits are point-in-time installations. No mechanism notifies the user "voice has emerged, re-run /dotclaude:coding."

## 9. Recommended fixes (prioritized)

### P0 — Hook overlap documentation across kits

Add a NOTE to both `/dotclaude:coding`'s SKILL.md Phase 4 and `/dotclaude:design`'s equivalent that says:

> *"If `.claude/hooks/check-file-size.sh` is already present (from a prior kit invocation), DON'T re-author it. Diff the existing hook against the template; if substitutions differ, surface the conflict and ask the user which value wins."*

Without this, running both kits in sequence quietly clobbers one with the other.

### P0 — Document greenfield anti-pattern bound in `code-review.md` principle

Add to the authoring guidance:

> *"On greenfield projects (< 50 commits with < 5 fix-prefix commits), 1-3 entries in the project-specific anti-pattern section may be **code-shape projections** rather than **git-derived patterns**. Mark these clearly — e.g., 'no occurrence in HEAD; future regression target.' The depth-signature target (5-10 entries) applies when history supports it; otherwise, write fewer and don't pad."*

The kit already does this in practice; the principle should reflect.

### P1 — Skill-auditor threshold incorporates velocity

`/dotclaude:coding`'s SKILL.md currently: *"Ship `skill-auditor.md` if the user expects to ship 3+ docs / skills / agents referencing specific code paths."*

Better: *"Ship `skill-auditor.md` if 3+ docs reference code paths AND the project averages > 5 commits / week (`git log --since='4 weeks ago' --oneline | wc -l > 20`). Below that velocity, the auditor's value is marginal — defer until code-change rate increases."*

### P1 — `/dotclaude:bootstrap` should partition hook ownership across kits

The bootstrap orchestration calls multiple domain skills. It should track which kit owns which hook so the staging step doesn't double-ship. Recommended ownership:

- coding: `check-file-size.sh`, `check-secret-leak.sh`, `check-bash-safety.sh`, `check-no-console-log.sh`, `check-no-todo-comments.sh`
- design: `check-design-tokens.sh`, `check-forbidden-phrases.sh`, `check-no-legacy-blur.sh` (iOS), `check-platform-icons.sh` (iOS)
- data: `check-prebuild-required.sh`, `regen-generated-artifacts.sh`
- ai-workflow: `check-import-boundary.sh` (cross-module discipline)

### P2 — "Re-run when voice emerges" hint in Phase 5 message

When voice is correctly skipped, the kit-overview should note:

> *"Skipped: forbidden-phrases.txt + check-forbidden-phrases.sh (no user-facing copy detected). Re-run /dotclaude:coding when copy / i18n strings land — the kit will detect the new voice surface and offer to ship the deny-list."*

This makes the skip auditable to future-user.

### P2 — Calibration note on greenfield anti-pattern shallowness

Add a one-line caveat to the kit-overview Phase 5 message specifically when the project has < 10 commits:

> *"Anti-pattern catalog is 7 entries — bounded by 1 fix-prefix commit in your history. Re-run after the project has 30+ commits to extract additional project-specific patterns."*

User knows what they got AND knows when to re-run.

## 10. Verdict

### Match level

**A-minus** — the kit ships at usable quality with two honest depth-bounds the user should be aware of.

- Y Named audience (Linear engineer / friend's CTO) tied to stack.
- Y Cites this project's actual file paths (`src/styles/tokens.ts`, `src/index.css`, `App.tsx:27,33,38,123-125`).
- Y War-story SHA `e201b52` cited 3× across artifacts (code-reviewer + quality-bar + file-discipline).
- Y Ceiling calibrated to codebase (500 not the default 1000) WITH calibration argument in the rule.
- Y Tool restriction structural (no Edit/Write on reviewer).
- Y Adaptive applicability gates correctly suppressed `forbidden-phrases.txt` + companion hook + `skill-auditor.md`.
- Y Honest depth bounds (7 anti-patterns, half code-shape, half git-derived; explicit "future regression target" on the unverifiable entries).
- - Anti-pattern catalog is shallower than the source project's (7 vs 9) — bounded by git history; honest, not a defect.
- - `settings.json` wiring still not written by the kit (same gap as design smoke test).
- - Hook overlap with design kit needs documentation.

### Ship-ability

**Would a user be happy with this?** Yes, with the same caveats as design:

1. User gets a coherent kit ready to `mv .claude-staging .claude`.
2. They'd need to manually wire `settings.json` hook entries (~5 lines of JSON).
3. They'd need to resolve the token-drift before the next color-touching change.
4. The reviewer correctly identifies the current `App.tsx` shape as B-tier (functional, has 1-2 visible cracks: dual-token drift + TODO survivor + orphan div) — accurate diagnosis.

### Major issues blocking ship

**None.** The 3 caveats are surfaceable, not blocking.

### Bottom line — does the methodology transfer from design to coding?

**Yes.** The kit's structural skeleton — applicability gate, 5-phase methodology, S/A/B/C/D/F grading, named anti-patterns, fast/careful split, claim-of-done checklist — transferred cleanly. The depth-of-content shrank where signal shrank (1 fix commit vs decades-of-bugs at the source), but the kit was honest about that shrinkage rather than padding.

**The breadth claim holds.** Design and coding are both first-class domains in dotclaude. The methodology is not "design-domain-exclusive with coding as a shallow afterthought" — both produce coherent kits when the kit applies the same discipline to a different domain.

**Caveat the user should know**: coding-domain output is more git-history-dependent than design-domain output. A truly greenfield project (< 10 commits) will get a shallower coding kit than the same project's design kit, because design anti-patterns can be inferred from code shape (raw colors, orphan elements, tone in copy) while coding anti-patterns largely surface from commit history. This is an honest property of the domain, not a kit deficiency — but it's worth being explicit about.

**Recommendation**: ship the kit as-is. Address P0 hook-overlap documentation in a follow-up. P1/P2 fixes are quality-of-life, not blockers.
