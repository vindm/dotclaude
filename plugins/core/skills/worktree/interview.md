# `/dotclaude:worktree` interview

4-5 questions, adaptive. Skip what Phase 1 (concurrency scan) already
answered — EXCEPT W2, which is a judgment call the scan can inform but never
settle. The goal: the calibration that turns the tested template into this
project's guard — which repo, what stays free, how a fresh worktree becomes
buildable, what the close protocol gates on.

## W1 — The policed repo + worktree placement

> "I see <repo layout summary — e.g. 'your project root is itself the repo' /
> 'three repos under the root: `engine/` (active development), `legacy/`
> (read-only reference), `data-snapshot/` (not a repo)'>. I'm proposing to
> police `<repo>` only — worktrees created as siblings named
> `<repo>-wt-<slug>`. Right repo? Right placement?"

Lead with the topology you already read. Multi-repo zones usually police ONE
actively-developed repo; read-only references and data directories are
naturally out of scope (the hook ignores other repos by design).

## W2 — The exempt list (mandatory; THE markdown-as-code question)

> "Which paths in the main checkout should stay freely editable? My default
> exempt candidates: `docs/`, root `README.md`, `LICENSE*`, per-machine
> git-ignored configs. And the critical check: **is any of your markdown
> executed rather than just read by humans** — runtime policies, prompt
> libraries, agent instructions, `.claude/` kits? Those must be POLICED like
> code, not exempted like docs."

If Phase 1 found `policies/`-like directories, name them and propose policing
them explicitly. If the user asks for a blanket `*.md` exemption, push back
once with the concrete risk (an unguarded behavioral layer), then respect
their call — it's their project.

## W3 — Fresh-worktree setup recipe

> "A new worktree checks out tracked files only. In your main checkout I found
> these git-ignored files the build likely needs: <list — e.g. `.env`,
> `config/instance.yaml`, `node_modules/`>. For each: copy a committed
> template, symlink from main, regenerate, or skip? (e.g. `node_modules` →
> symlink; `.env` → copy `.env.example` then fill; a per-machine config →
> copy the committed `*.example`)"

Every file gets an explicit recipe — these lines become both the lifecycle
skill's setup step and the hook's block-message hint. A worktree that can't
build sends the user straight back to editing main.

## W4 — Verify command + close gates

> "What proves a worktree is healthy — and what must be green before merging
> back? I found <e.g. `npm test` / `make check` / `python3 engine/generate.py`>.
> Anything else the close protocol should gate on (lint, integrity checks,
> a diff review convention)?"

The verify command also drives the Phase 5 smoke run — it must be the REAL
build/render, not a formatter; derived-artifact dirt only shows up under the
real thing.

## W5 — Shared resources outside the repo (only if signals exist)

> "Worktrees isolate the repo, not shared state outside it. I noticed <e.g.
> 'a real-data snapshot several sessions render against' / 'an existing
> `.session_lock` protocol' / 'a device pool'>. Should the kit keep a narrow
> lease for those — one lock file covering ONLY <the resource> writes and the
> merge/push window — while your own-worktree edits need no lock?"

If a broad lock protocol already exists, propose narrowing it (worktrees now
cover in-repo collisions); if none exists and no shared resources surfaced,
skip this question entirely.
