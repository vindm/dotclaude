# visual-verification — see-what-you-built discipline

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to design the visual-verification rule for projects where work produces visible output (UI, CLI TTY, generated images, charts, PDFs, anything a human eyeballs).

## When to ship one (applicability gate)

Ship a visual-verification rule when:

- The project produces **any visible output** — web pages, mobile screens, desktop apps, CLI output that uses color / TUIs / progress displays, generated reports / charts / images.
- Bugs in the output's appearance have shipped without being caught by tests.
- The user has ever said "tests pass but it looks wrong" or "this compiled but the layout broke."

Skip when:

- The project is pure library code, headless API surface, or backend service with no visible output for a human.
- Output is purely structured data (JSON / Protobuf / SQL rows) consumed only by other services — text-diffing is sufficient verification.

## Why it matters — what this catches that nothing else does

The discipline is one sentence: **after a change with a visible output, capture the output and look at it before claiming done.** What this catches:

- **"It compiles" ≠ "it works."** Type-checkers don't see layout. Linters don't see color. Tests assert on values; they don't see misaligned text.
- **Hot-reload / build-target mismatch.** Your local view of the change is from a stale build, a different runtime target, or a wrong-device deploy. The rendered artifact is the only source of truth (see `../examples/the-bug-surfaced-five-screens-later.md` for a related cascade).
- **Cascade bugs.** A bad value entered at screen 1 propagates through valid-looking renders until screen 6 finally asserts. Screenshot-every-screen is the diagnostic that surfaces this cheaply.
- **Reference-drift.** "Looks fine" without a reference comparison is a vibes-based ship gate. Captured output against a named reference (design comp, prior screenshot, benchmark app) is principled.

The rule is small (one page); its enforcement value is large because it's the only mechanism that closes the gap between "I made the change" and "the change does what I intended in the rendered world."

## Core methodology — the four steps

The discipline, applied universally:

### Step 1 — Pick the capture target

Where does the output get rendered, and what's the cheapest way to capture it?

- **Web pages**: headless browser (Puppeteer / Playwright) screenshot, or browser-extension capture, or `curl` + manual visual check.
- **Mobile (iOS simulator)**: `xcrun simctl io <udid> screenshot <path>` (CLI, returns a path — no image-token cost until you `Read` it).
- **Mobile (Android emulator)**: `adb exec-out screencap -p > <path>`.
- **Mobile (physical device)**: vendor-specific (Xcode for iOS 17+ requires tunneld + WebDriverAgent; Android uses `adb`).
- **Desktop apps (Electron / Tauri / native)**: OS-level screenshot CLI (`screencapture` on macOS, `gnome-screenshot` / `grim` on Linux).
- **CLI / TTY output**: redirect to file, view with `cat` or in a terminal that renders ANSI escapes.
- **Generated images / PDFs / charts**: open the file, render to a viewable form.

Pick the path that returns *a file* without consuming tokens for the bytes. If the LLM doesn't need to see the image (it just needs to verify "the screen changed at all"), capture-without-read is the cheapest mode.

### Step 2 — Compare against a reference

A captured screenshot in isolation is not verification — it's just a picture. The verification step is the *comparison*. The reference can be:

- The approved design comp (Figma export, mockup PNG)
- A prior screenshot of the same surface (regression check)
- A benchmark app's equivalent screen (e.g., "this list row should match the analogous row in Linear / Things 3 / Telegram")
- The user's verbal description of what they expected ("there should be a button labeled X here")

Without a reference, the visual check collapses into "looks fine to me." That's not a check.

### Step 3 — Iterate if it doesn't match

The visual gap → an edit → reload → re-capture → compare loop is the iteration unit. The rule should set the expectation that this loop runs *before* declaring done, not as a follow-up audit.

For UI work, this loop is typically 1–5 iterations on any non-trivial change. Each iteration is cheap (capture is automated, comparison is human or LLM eyeball). The cost of NOT doing this loop is shipping the wrong thing.

### Step 4 — Report the final capture path

When Claude reports back to the user that a UI change is done, the report **includes the path to the final captured artifact**. The user can open the file and see what was produced. This is the contract: visual changes are never claimed without a corresponding visible artifact.

## How to derive THIS project's specifics

Before authoring the rule, identify the project's capture surfaces:

1. **What devices / platforms does the project target?** Web only? iOS only? Both? Tablet variants?
2. **Is there a development simulator or emulator already in use?** If yes, the rule should reference the specific CLI invocations the user already runs.
3. **What's the hot-reload story?** If the project uses Metro / Webpack-dev-server / Vite / etc., the rule should specify "wait for hot reload to land before capturing" — common bug class is screenshotting before the change is live.
4. **Are there OS-specific quirks?** iOS 17+ requires tunneld for physical device automation. Android 14+ has new permission prompts. Windows screen capture varies by display server. The rule should be specific about the project's actual target OS versions.
5. **Is there a screenshot-archive convention?** Some teams put screenshots in `docs/screenshots/<date>/`. The rule should respect / establish that convention.
6. **Is there a reference-design source?** Figma file URL? `docs/design/` directory with comps? The rule should name where to look for the canonical reference.

## Authoring the rule

The final rule (typically `.claude/rules/visual-verification.md`) should answer:

1. **What devices / surfaces are in scope?** Be explicit about the targets.
2. **What's the capture command for each target?** Concrete commands the user copies into a terminal, not generic guidance.
3. **What's the comparison reference?** Point to where the design comp / reference screenshots / benchmark sources live.
4. **When does the loop end?** Concrete: "compare against approved design; if not at parity on any non-trivial chrome dimension, iterate."
5. **How is the final artifact reported?** Concrete: "include the path to the final screenshot when reporting back."
6. **What's the cost discipline?** This matters if capture uses MCP tools that return image bytes — guidance on capture-without-read for "did the screen change at all" verification, full read only when the LLM needs to evaluate appearance.

## Token-discipline subsection

When the LLM-callable capture tool returns image bytes inline, every capture call costs image tokens. For projects with capture-heavy workflows, the rule should establish:

- **CLI capture (returns file path) is the default.** No tokens consumed until the LLM `Read`s the file. This is the cheap iteration mode.
- **MCP / inline-bytes capture is the exception.** Use only when the LLM genuinely needs to inspect the image (e.g., final review pass before declaring done).
- **Inspection of view hierarchies (mobile)**: similar discipline — CLI tools (e.g., `maestro hierarchy --compact`) return CSV that's 3–5× cheaper than MCP JSON dumps. Pipe through `head` / `grep` to bound output to the element of interest.

The rule should name the cheap and expensive paths explicitly so Claude reaches for the cheap one by default.

## The "see what you built" injunction

The rule's emotional core is: **never present UI work you haven't visually verified.** Tests passing, code compiling, types being correct — these are NOT substitutes. If for some reason capture is impossible (CI environment without a simulator, blocked device, missing credentials), Claude must say so explicitly and ask the user to verify, rather than claiming done by proxy.

This injunction matters because the default LLM failure mode is to confuse "I performed the actions a working build requires" with "the build works." The two diverge constantly. The screenshot is the only mechanism that closes the divergence reliably.

## Cross-references

- `ux-audit.md` — when the visual check surfaces "looks wrong," the ux-reviewer agent does the deeper grading. Visual-verification produces the artifact; ux-reviewer grades it.
- `audit-routing.md` — when multiple visual audits exist (a11y, design tokens, interaction), routing decides which to invoke based on what the captured surface needs.
- `../examples/the-bug-surfaced-five-screens-later.md` — paradigm for screenshot-every-screen as a cascade-bug diagnostic. When the assertion fails at screen N, screenshot screens 0, N-1, N — the bug is usually visible upstream of the failure.
- `../examples/the-button-that-never-fired.md` — a related lesson on the gap between "the tool reported success" and "the change actually happened." Visual capture is one defense; instrumented state mirrors (in test harnesses) is another.

## Anti-patterns in the rule you write

- **Generic "take a screenshot" without device-specific commands.** The user wants to know exactly what to type. "Take a screenshot of the iOS simulator" is unactionable; `xcrun simctl io <udid> screenshot /tmp/x.png` is.

- **No reference comparison.** A screenshot alone doesn't verify; it just produces a picture. Always specify what the screenshot is being compared against.

- **No cost discipline for capture-heavy workflows.** If every capture costs image tokens, capture-heavy projects accidentally burn $$/session on visual iteration. Encode CLI-first; MCP-as-exception.

- **Demanding capture in unrealistic environments.** If CI doesn't have a simulator, demanding capture in CI is dishonest. The rule should say "capture is required when the environment supports it; otherwise the implementer says so explicitly and asks the user to verify."

- **Treating capture as a one-shot final step.** Visual iteration is a loop. The rule should expect 1–5 capture-edit cycles per non-trivial UI change, not one capture at the end.

- **No reporting contract.** If the user doesn't see the captured artifact in the agent's final report, the discipline degrades silently into "I think I screenshotted it." Make the path appear in the report; that's the audit trail.
