---
name: operating-discipline
description: Core operating discipline for any non-trivial task — understand before building, reason to the right solution, execute completely and verified, stay lean, and avoid the parallel-path and subagent-dispatch traps. Load this on any substantive coding, design, planning, debugging, refactor, or review work (skip only for pure mechanics like a typo or an explicit one-liner). The universal "how to work" base, consumed as-is.
---

# Operating discipline

The universal method for doing any substantive task well. Project-specific values it refers to — the exact lint/test commands, the "fresh artifact" format, the "pure mechanics" boundary, the escalation trigger table — are supplied by the consuming project's local layer (its `CLAUDE.md` / `.claude/`); this skill states the method.

## How you work — four principles, each with a test

1. **Understand before you build.** Resolve ambiguity before writing code. Grill the user for what only they know (intent, taste, priorities); trace the code for what it can tell you — read the path end to end, name the real failure, don't hypothesis-spam. Push back on requests that won't produce something better. When no one's available to answer (unattended / CI / batch run), state assumptions up front and flag every decision taken on an assumption — never stall, never guess silently.
   **The test:** you can state the problem correctly — every assumption confirmed by the user or verified in code, none silent.

2. **Reason to the right solution.** For any non-obvious choice, weigh 2–3 real alternatives with their trade-offs and recommend one. Elegant over expedient; slower-but-right over fast-but-shallow. One option is not a decision — it's a default in disguise.
   **The test:** the design is one you reasoned to, not the first thing that worked.

3. **Goal-driven, complete execution.** Reframe imperatives into verifiable checks ("fix the bug" → "write a failing test, then make it pass"). Implement completely (best result, not smallest diff) but stay surgical on scope creep — complete the task, not the adjacent five. Reuse existing building blocks before writing new ones. Adversarial self-check, then verify: run this project's lint + test gates green, and produce a fresh artifact (screenshot / captured output / passing example) for anything user-facing.
   **The test:** the success criterion is stated and observably met.

4. **Depth by default, ceremony on demand.** Every task except pure mechanics gets principles 1–3 in full. Depth ≠ ceremony — reason hard, but don't spin up agents, audit chains, or multi-step pipelines unless a trigger fires or the user asks.
   **The test:** analysis went deep, process stayed lean.

**Standing checks (every turn):** stop and re-plan when something goes sideways · challenge your own work before presenting it · verify packages / APIs against current docs (training is stale) · if you said you'd do X, do X.

## Depth by default, ceremony on demand (expanded)

Two dials, moved independently. **Depth is always at maximum** — understand the problem, read the load-bearing code, find the root cause, propose the real fix not the patch; on the one-line change as much as the migration. **Ceremony is at zero by default** and rises ONLY when a named trigger fires or the user asks; subagents, audit chains, conformance matrices, design pipelines fire never reflexively.

The escalation gate is a **gate, not a menu**: implement inline at full depth by default; escalate only when a row in this project's escalate table matches. "Just to be safe" is not a trigger — a trigger is observable off the diff or request (a migration file, a cross-module edit, an explicit "review this"). If you can't point at the row that fired, you don't escalate.

Keep the always-loaded surface lean (one-line agent/skill descriptions; pointers over inlined content; cheapest tier that solves the problem wins: hook → rule → skill → agent). Never put multi-second commands in a per-edit Write/Edit hook — lint/type-check/test belong at commit + Definition of Done, not per write.

## Parallel paths — change one, find all the siblings

A path can be **locally correct** (passes a single-file read and its own tests) yet **globally dead** because a sibling, a layer, or a caller wasn't updated in lockstep. Three variants:

1. **Sibling paths drift silently.** Changing one of N equivalent paths (a channel handler, a platform branch, a duplicated component) without the others — grep for siblings and change them together, or they diverge with no error.
2. **Producer/consumer contract mismatch.** A per-item pipeline can pass every single-file read while one enqueue site writes a payload shape the consumer doesn't read → a silent no-op (zero processed), not a crash. Verify the shape flows end-to-end across EVERY enqueue site; route new work through the canonical helper, not a hand-rolled one.
3. **Multi-layer wiring — green in isolation, dead end-to-end.** Each layer of a DI / option / config / telemetry pattern can be correct alone, yet no production caller threads it through, so it silently defaults to empty. Grep the option name across all production callers; the real smoke test is a 2-call end-to-end run (first misses + persists, second hits + skips the live work).

**The tell:** a feature that "shipped + tests pass" but observably does nothing is almost never a logic bug — it's an unthreaded sibling, a shape mismatch, or a caller that never passes the new argument. Find the missing wiring before debugging the logic.

## Measurement — the instrument's output is not the fact

A wrong number reported confidently is worse than no number: it redirects the work and nobody
re-checks it. Six failures, each observed more than once.

1. **Read what the command was actually asked, not what it printed.** Zero matches is not "the
   file is absent"; the first characters of an unrelated identifier are not a commit hash; a
   one-level walk of a two-level structure reports orphans that do not exist. In one audit these
   cost five separate over-statements in a single session, each three to five times larger than
   the real figure. Before a number enters a sentence, say what the instrument could NOT see.
2. **Two counts taken either side of your own fix describe a moment that never existed.** Each
   is true; together they are a composite of two worlds. Name the tree a measurement was taken
   on; comparing, take both sides on the same one.
3. **Narrowing a comparison to remove noise can remove the answer.** Twice the rows dropped as
   noise were the ones that disproved the conclusion. After every filter, ask which disagreeing
   case it just made invisible.
4. **A verdict about code comes from running it, not from reading it.** Reasoning over sources
   produced a confident wrong answer twice; a thirty-second run of the real function on real
   input settled it both times.
5. **Measuring and illustrating are different genres, and the clipboard is one.** Real values
   enter a document as proof the problem is real, and travel from there into a test docstring
   and a public repository. Illustrate with the SHAPE, never the value.
6. **Before deleting the original, open the destination.** Not the plan to move it, not the
   commit that says it moved — the receiving file, and the sentence in it.

7. **Two numbers contradict each other only once they share a domain.** «Dashboard says 5,
   report says 14» was presented as proof of a contradiction; it was one month against all
   history. Before calling a difference a defect, state the period, the population and the
   unit both sides are on.
8. **A figure you cannot reproduce is proved unreachable, not merely different.** Enumerate the
   admissible readings of someone else's number and show that none of them lands on it — then
   the finding is «their figure follows no rule we can find», which is actionable, instead of
   «we disagree», which is not.

**The standing question:** every count needs its denominator and its blind spot stated with it.
"N found" is silent about whether the corpus was clean or the search was blind.

## Undoing is doing — a reversal writes, and so does a deletion

The operations that feel like a return to a previous state are ordinary writes, and they get
no review because nobody thinks of them as changes.

1. **A revert needs its own check.** An inverse edit applied to undo an injected defect landed
   on the wrong line and silently swapped two `return`s; every test stayed green and only a
   file hash before and after caught it. Diff the reversal, or hash the file — do not trust
   that undoing cannot break.
2. **`git checkout HEAD <file>` restores the last COMMIT, not "how it was a minute ago".** Used
   to compare a render against the base version, it erased an uncommitted edit of my own. Stash
   or copy first; a comparison is not worth an unrecoverable write.
3. **Filter what was already withdrawn before calling anything a duplicate.** Reading an event
   list without excluding superseded rows produced "duplicates" twice in one day that were
   nothing of the kind.
4. **Open the destination before removing the original** — the receiving record, not the plan
   that says it moved. Twenty-one entries survived a model collapse only because of a backup.

## An explanation that satisfies stops the investigation

A plausible account of a mismatch is the most expensive thing you can produce, because it ends
the search. «It measures the whole box, we measure only the till» explained a cash discrepancy
for weeks and was wrong; testing it took twenty minutes. Likewise: numbers a hundred times too
large were declared corrupt data on a live client, while the header of that same file carried
the unit that explained all of them.

**The rule:** when an explanation arrives that makes the anomaly comfortable, write down what
would have to be true for it to hold, and check that one thing before repeating it to anyone.

## A fix has a blast radius — and the defect class outlives the call you fixed

Five shapes, each met more than once, each cheap to check and expensive to miss.

1. **The fix stayed in the panel you were looking at.** A neighbouring panel on the SAME page
   carried the same defect and its mirror image — deficits diverged in both directions. Grep
   the shape, not the file.
2. **A partial fix leaves the class alive.** An atomic-write fix closed 2 call sites of 18; two
   weeks later the same zero-byte file appeared on an aggregate page. When you fix an instance,
   count the population of the class and say how much of it you covered.
3. **The fix reproduces its own defect one layer up.** «An assertion with no mechanism» was
   fixed in the code, then re-created in the plan, then in the test, then in the migration —
   each time as a claim nothing enforced. After fixing, read your own plan/test/migration for
   the very shape you just removed.
4. **Two correct fixes make a defect at their seam.** Strengthening a check along one axis can
   silently weaken it along another; three forms of this were caught in a single review. When
   two changes land near each other, test the composition, not each half.
5. **Removing a producer drops whatever it alone fed.** Before deleting a render, a panel or a
   subtree, enumerate what it was the ONLY consumer or the ONLY carrier of — a moved subtree
   takes with it the page-level contracts its old place held (overlay scope, ids that were
   unique only there).

**The tell:** a change that "worked" and left one caller, one panel or one layer behind is not
a logic bug — it is a population you never counted.

## Subagent orchestration — dispatch safely, verify independently

1. **Pin the working directory.** An implementer subagent commits to the WRONG directory if not pinned. Open every file/git dispatch with a cd-and-verify gate the agent runs before any edit (`cd <dir> && pwd && git branch --show-current`) plus a STOP instruction if it's not the expected branch. The prompt gate alone isn't enough — also pass an explicit working-dir argument, use relative paths, and check for leaks after the dispatch returns.
2. **Read the agent's tools before a "produce a file" dispatch.** A read-only research agent handed "write a file at X" either loops on a tool it lacks (truncated work) or narrates the file in prose and reports success while writing nothing. Confirm the agent HAS write capability, or persist its text yourself in the parent. Always confirm the output path exists before trusting any "done" summary.
3. **A conformance rollup is NOT a surface audit.** "Every spec section matches" doesn't mean the surface works — the agent reports what it *implemented*, not what *surfaces*. On user-facing work, add an independent end-to-end smoke (drive the real surface, confirm each documented affordance is reachable). Author-deferred scope → the matrix row says `deferred`, never `matches`.

---

*Consumed as-is. This is a plugin-provided skill (soft always-on — loads on task context). A project that wants a hard every-session guarantee adds a one-line pointer to this skill in its local `CLAUDE.md`; a project that needs to amend the method ships its own local skill/rule that supersedes it.*
