# visual-verification — see-what-you-built discipline

Teaching material for Claude Code. Teaches you how to design the visual-verification rule for projects where work produces visible output — UI, CLI TTY, generated images, charts, PDFs, anything a human eyeballs.

## When to ship one

Ship a visual-verification rule when the project produces any visible output (web pages, mobile screens, desktop apps, color/TUI CLI output, generated reports / charts / images) and appearance bugs have shipped uncaught by tests, or the user has said "tests pass but it looks wrong" / "this compiled but the layout broke." Skip for pure library code, headless APIs, or output that's purely structured data (JSON / SQL rows) consumed only by other services — text-diffing suffices there.

## Why it matters

The discipline is one sentence: **after a change with a visible output, capture the output and look at it before claiming done.** What it catches:

- **"It compiles" ≠ "it works."** Type-checkers don't see layout, linters don't see color, tests assert on values — none see misaligned text.
- **Hot-reload / build-target mismatch.** Your local view may be a stale build, a different runtime target, or a wrong-device deploy; the rendered artifact is the only source of truth.
- **Cascade bugs.** A bad value at screen 1 propagates through valid-looking renders until screen 6 finally asserts; screenshot-every-screen surfaces it cheaply.
- **Reference-drift.** "Looks fine" with no reference is a vibes-based ship gate; captured output against a named reference (design comp, prior screenshot, benchmark app) is principled.

The rule is one page; its value is large because it's the only mechanism that closes the gap between "I made the change" and "the change does what I intended in the rendered world."

## Core methodology — four steps

**Step 1 — Pick the capture target** (the cheapest path that returns *a file* without spending tokens on the bytes): web → headless browser (Playwright / Puppeteer) or `curl` + manual check; iOS sim → `xcrun simctl io <udid> screenshot <path>`; Android emu → `adb exec-out screencap -p > <path>`; physical device → vendor-specific (iOS 17+ needs tunneld + WebDriverAgent); desktop → OS screenshot CLI (`screencapture` / `grim`); CLI/TTY → redirect to file, view ANSI; generated images / PDFs → render to a viewable form. If the model only needs "did the screen change at all," capture-without-read is the cheapest mode.

**Step 2 — Compare against a reference.** A screenshot in isolation is just a picture; the verification is the *comparison*. The reference: the approved design comp (Figma export), a prior screenshot (regression), a benchmark app's equivalent screen, or the user's stated expectation. Without a reference, the check collapses into "looks fine to me" — not a check.

**Step 3 — Iterate if it doesn't match.** The gap → edit → reload → re-capture → compare loop runs *before* declaring done, not as a follow-up audit — typically 1-5 iterations on any non-trivial change. Each is cheap (capture automated, comparison an eyeball); the cost of skipping the loop is shipping the wrong thing.

**Step 4 — Report the final capture path.** When reporting a UI change done, include the path to the final captured artifact so the user can open it. The contract: visual changes are never claimed without a corresponding visible artifact.

## Token-discipline subsection

When the capture tool returns image bytes inline, every call costs image tokens. For capture-heavy workflows the rule names the cheap and expensive paths explicitly, so Claude reaches for the cheap one by default:

- **CLI capture (returns a file path) is the default** — no tokens until the model `Read`s the file; the cheap iteration mode.
- **MCP / inline-bytes capture is the exception** — only when the model genuinely needs to inspect the image (final review before declaring done).
- **View-hierarchy inspection** — CLI tools (`maestro hierarchy --compact`) return CSV 3-5× cheaper than MCP JSON; pipe through `head` / `grep` to bound output to the element of interest.

## The "see what you built" injunction

The rule's core: **never present UI work you haven't visually verified.** Tests passing, code compiling, types correct — none are substitutes. The default model failure mode is confusing "I performed the actions a working build requires" with "the build works"; the two diverge constantly, and the screenshot is the only reliable close. If capture is genuinely impossible (CI without a simulator, blocked device, missing credentials), say so explicitly and ask the user to verify — never claim done by proxy.

## How to derive THIS project's specifics

1. **Devices / platforms targeted** — web only? iOS? both? tablet variants?
2. **The simulator / emulator in use** — reference the specific CLI invocations the user already runs.
3. **The hot-reload story** — Metro / Vite / Webpack-dev-server; the rule says "wait for hot reload to land before capturing" (screenshotting before the change is live is a common bug).
4. **OS-specific quirks** — iOS 17+ tunneld for physical devices, Android 14+ permission prompts, Windows capture by display server; be specific about the actual target versions.
5. **A screenshot-archive convention** — e.g. `docs/screenshots/<date>/`; respect or establish it.
6. **A reference-design source** — a Figma URL, a `docs/design/` directory of comps; name where the canonical reference lives.

## Authoring the rule

The final rule (typically `.claude/rules/visual-verification.md`) answers: which surfaces are in scope; the concrete capture command for each target (copy-paste, not generic guidance); where the comparison reference lives; when the loop ends (*"iterate until at parity on every non-trivial chrome dimension"*); how the final artifact is reported (the path appears in the report — that's the audit trail); and the cost discipline (CLI-first, MCP-as-exception). Be honest about environments: capture is required when the environment supports it, otherwise the implementer says so and asks the user to verify.

## Cross-references

- `ux-audit.md` — visual-verification produces the artifact; ux-reviewer grades it.
- `audit-routing.md` — when multiple visual audits exist (a11y, tokens, interaction), routing decides which the captured surface needs.
