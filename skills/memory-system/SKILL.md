---
name: memory-system
description: Use the project's cross-conversation memory directory well — typed entries (user / feedback / project / reference), each type with its own lifecycle and promotion path, kept as facts not essays, navigated through a curated index. Load when saving a durable fact, reading prior-session context, or deciding whether something belongs in memory at all.
---

# Memory system

Cross-conversation memory is only useful if it stays typed and pruned. Untyped memory becomes a noise pile — after months the directory holds hundreds of entries and nobody knows which still apply, so they get loaded as context and ignored. The discipline below keeps it a navigable graph of load-bearing facts instead.

First, derive where this project keeps memory and which conventions it already uses: find the memory directory and its index file (an entry-listing markdown file at the root), read a few existing entries to see the filename prefixes and cross-link style in play, and mirror those. Don't impose a layout the project doesn't use.

## The four types — each has its own lifecycle

Every entry is one of four types. The type decides the filename, the lifecycle, and where it eventually goes.

1. **User memory** — who the user is: role, preferences, hard constraints ("prefers one package manager over another", "is on a specific platform — never assume another", "owns all native builds — never run them, delegate"). Lives at the top of the index as an always-loaded section, or as standalone `user_<topic>` entries. Permanent and auto-loaded; never promotes (already top-tier). Changes only when the user's situation changes — and then you update it in place, never accumulate a contradicting second copy.

2. **Feedback memory** — corrections, lessons, anti-patterns the user explicitly flagged. The highest-leverage type, because it encodes what NOT to do. Filename carries a `feedback_` prefix. Lifecycle: a single-session correction → captured as a lesson → **graduates to a rule once it fires repeatedly** (use the project's threshold; a common default is three firings). When it graduates, move the lesson into the project's rules location so it fires every relevant session, and mark the memory entry as promoted (or archive it). Every untyped "oh right, you mentioned that last week" moment is a feedback entry leaking value — capture them aggressively.

3. **Project memory** — active strategic state, in-flight decisions, recently-shipped work, open punch lists. Time-sensitive. Filename carries a `project_` prefix; put the date in the filename when the entry is dated, in the body otherwise. Lifecycle: created during active work → referenced as it progresses → **archived when superseded** by ship / pivot / next-phase. Every project entry carries a status tag (active / shipped / in-review / blocked) and a date — without them every entry reads as currently-true, which is false most of the time.

4. **Reference memory** — stable facts, external pointers, project-specific framework or API knowledge. Descriptive slug, no prefix. Permanent unless reality contradicts it; updated in place. If a reference entry grows past a one-paragraph factoid into a multi-section document, promote it out to the project's docs area and leave a one-line pointer behind.

## The index enables lazy loading

Keep a single curated index at the root of the memory directory. Each entry is one bullet — a link plus a one-sentence summary informative enough to judge relevance without opening the file:

```
- [<title> (<date>)](<filename>) — <one-sentence summary>.
```

The index is what lets memory scale: the full directory may be large, but you read the small index, pick the two or three entries that matter for the current session, and expand only those. An index that's just an auto-generated directory listing defeats this — it has no summaries and no relevance signal. A summary like "note about auth" is useless; say what about it.

## Keep each entry a fact, not an essay

Hold every entry short — a single load-bearing fact with its rationale, not a narrative. Past roughly 40 lines it's a document wearing a memory filename: trim it to rule + why + how-to-apply, or promote it to the project's docs with a one-line pointer. Bloated entries defeat lazy loading.

Lead feedback entries with the rule, imperative and scannable — "Never X" / "When Y, do Z" — then a line on why it exists and a line on the trigger that fires it. Burying the lesson three paragraphs into a story means it's never read in time. Cross-reference related entries so the directory stays a navigable graph; when you archive an entry, fix the references that pointed at it so the graph has no dead links.

## When to save, access, and remove

**Save when:** the user just told you something durable ("don't do X anymore", "prefer Y", "we already shipped Z"); they corrected you on a non-obvious choice future-you would default wrong; you resolved an ambiguity in a way they approved (the decision is recoverable from code, the *rationale* is not); a non-obvious environmental fact would burn a future session if forgotten; or they showed frustration at a recurring miss (high priority for promotion to a rule).

**Don't save:** anything derivable from code, git, or config files — reading code is cheaper than reading memory, and duplicating it just creates a second source that drifts. Don't save plan progress that a plan doc already tracks, implementation details that live in the code, or single-use context you won't need again.

**Access when:** the user references prior work ("like we discussed", "remember when"); a decision depends on past context (before recommending a tech choice, check feedback for "we already decided against this"); or a session opens cold — read the index, expand entries whose summaries match the topic.

**Remove when:** an entry contradicts current code or state; the user says "we no longer do X"; project work has shipped and been audited; or feedback has been promoted to a rule. Archive, never delete — the historical context explains why state shifted. Keep the archive out of the live directory so volume never drowns the signal.

## Reconcile against reality

Project memory rots the instant reality moves and the entry doesn't — a branch merges, a worktree is removed, a "pending push" lands. A stale entry loaded as current context is worse than no entry: it actively misleads. At the start of any session that touches active-work memory, reconcile its branch / worktree / pending-state claims against actual git state and fix the memory file *before* starting work — the session opens by reconciling, not by trusting. For long-lived projects, a periodic unattended audit of the whole directory pays off (reconcile against git, spot-check that cited paths still exist, flag over-ceiling entries and dangling cross-links) — and it must archive only, never delete, and never touch a just-edited file.
