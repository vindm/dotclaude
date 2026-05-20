# Visual verification (UI work)

After UI edits, **see what you built** before reporting done.

1. **Pick the device.** `ps aux | grep "expo run"` — `--device <UDID>` = physical iPhone, `--simulator` = sim. Hot reload only lands on Metro's target.
   - **Simulator:** `xcrun simctl io <udid> screenshot /tmp/sim-now.png` (CLI, default — no image bytes return until you `Read` the file). MCP `mcp__maestro__take_screenshot` only when you need Maestro-managed device state coupling.
   - **Physical iPhone (iOS 17+):** Maestro doesn't support — use your project's WDA-based helper scripts:
     - Screenshot: a `device-screenshot` script writing to a path, then `Read`.
     - Tap: a `device-tap` script using a predicate (e.g. `label == 'Photos'`).
     - Type: a `device-type` script (focused field).
     - One-time per boot: a `start-tunneld` + `start-wda` sequence (sudo, Trust prompt).
2. Evaluate against approved design + Apple iOS 26 / Telegram bar (see your `design-north-star` rule).
3. If not — edit, wait for hot reload, screenshot again. Iterate.
4. Include the final screenshot path when reporting.

Never present UI work you haven't visually verified. "Tests pass" / "compiles" / "should work" are NOT substitutes — say so explicitly if a capture isn't possible and ask the user to verify.

## CLI > MCP for screen inspection (default path)

`mcp__maestro__inspect_screen` returns the entire view hierarchy as JSON — chat / map / setup-flow screens routinely return 5–20k tokens of nested `Text`/`View`/`Image` nodes. Bound output via CLI before reading.

**Sim hierarchy → CLI:**
- `maestro --device <udid> hierarchy --compact | head -200` — CSV format (`element_num,depth,attributes,parent_num`), 3–5× cheaper than JSON; top of tree usually enough to find the element you're after.
- `maestro --device <udid> hierarchy --compact | grep -A 2 "<accessibility-id-or-text>"` — locate one specific element.
- `maestro --device <udid> hierarchy > /tmp/h.json` then `Read` only the slice you need — full tree without conversation cost.
- (`--device` / `--udid` is a top-level flag, *before* the subcommand — `maestro hierarchy --device …` will fail.)
- MCP `mcp__maestro__inspect_screen` only when you genuinely need every node + JSON shape (rare — usually you're hunting one element).

**Sim screenshot → CLI:**
- `xcrun simctl io <udid> screenshot /tmp/sim-now.png` returns a path, not bytes. Claude burns image tokens only when you `Read /tmp/sim-now.png` — so you can capture-then-skip-read cheaply when you only need to confirm "did the screen change at all".
- MCP `mcp__maestro__take_screenshot` always returns the image inline — costs image tokens every call.

**Token-discipline rule:** before any screen inspection, ask "do I need the *whole* hierarchy, or one specific element?" If the latter (almost always), CLI + `grep` / `head` is the default. The MCP tool has no ceiling and will dump everything.

## RN console.log doesn't reach iOS unified logging

`console.log` from React Native code goes to **Metro's stdout**, not `os_log` / iOS unified logging. `xcrun simctl spawn <udid> log show … | grep` silently misses every JS-side log. To read RN logs: tail the Metro terminal window directly, or `npx react-native log-ios`. Use iOS unified logging only for native (Swift / Obj-C) signals — crashes, delegate-queue traps, ARSession events.
