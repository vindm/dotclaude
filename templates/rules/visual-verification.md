# Visual verification (UI work)

After UI edits, **see what you built** before reporting done.

## The discipline

1. Identify the target device (browser, simulator, physical device).
2. Capture a screenshot — store the path; don't burn token budget reading the image until you need to compare.
3. Compare against the approved design and the nearest first-party reference (Apple HIG for iOS, Material You for Android, your design system reference app for web).
4. If it doesn't match — edit, wait for hot reload, capture again. Iterate.
5. Include the final screenshot path when reporting the work.

## What this rule rejects

"Tests pass" / "compiles cleanly" / "should work" are NOT substitutes for visual verification.

If capture is genuinely impossible (no device available, no headless rendering path), say so explicitly. Ask the user to verify. Don't claim done.

## Why this matters

Compilers don't catch:
- Off-by-1px padding that breaks rhythm
- Wrong shade of accent color (token-correct but theme-incorrect)
- Animation that lands at the wrong easing
- Text overflow in long-string locales (German, Russian)
- Touch target too small (44pt minimum on iOS, 48dp on Android)

Tests catch logic. Eyes catch design.

## Anti-pattern: token-grep audits without seeing the screen

Auditing "no raw hex literals" via grep is fast and cheap (use the `check-design-tokens` hook). But it can't tell you the *composition* is right. Run both: the regex check AND the screenshot check.

## Anti-pattern: console-log debugging that never reaches the device

On mobile platforms, the host's unified-logging stream (e.g., `os_log` on iOS) does NOT capture framework-level `console.log` from JavaScript runtimes. If you're tailing the wrong log source, silent misses cost hours. Identify the right stream (the JS runtime's stdout, typically your bundler's terminal) before assuming the log line "didn't fire."

## See also

- The `check-design-tokens` hook enforces token discipline at edit time
- The `check-file-size` hook keeps component files small enough to audit confidently
