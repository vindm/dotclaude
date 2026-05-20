# Example output — Rust CLI tool

What `/dotclaude:design` (and `/dotclaude:coding`) authored for a Rust CLI tool — a local Kubernetes cluster manager, terminal-only, no GUI.

A CLI tool has a "design surface" too — flag ergonomics, output formatting, help text, progress feedback. But MUCH of what `/dotclaude:design` would produce for a web app is irrelevant. The kit Claude authors here is correspondingly smaller.

**Important**: this is example output. Your CLI / TUI project will get different artifacts based on YOUR exact stack, your tested patterns, your help-text voice.

---

## Interview answers Claude inferred + asked about

```
Primary surface         terminal (TUI, not pure stdout)
Tier 1 benchmarks       `gh` CLI (help formatting, error register), `kubectl` (subcommand discoverability)
Tier 2 benchmarks       Raycast (keyboard speed, if a GUI is ever added), Lazygit (TUI interaction)
Voice                   terse, no preamble. NO "Welcome!" NO "Successfully completed."
                        Error messages must be specific + actionable, never just "Error: failed."
Past bugs               - shipped a `--force` flag that didn't skip the confirmation prompt
                        - shipped a subcommand whose --help text said it accepted JSON but it actually only accepted YAML
                        - panic on a 0-byte config file (no helpful error, just stack trace)
Quality bar             defensive — every error message reads as "the tool's fault, not the user's"
```

## What Claude SKIPPED for this project

Notice the agents that were NOT authored for a Rust CLI tool:

- **No `ux-reviewer.md`** — no visual chrome to grade
- **No `a11y-audit.md`** — accessibility maps differently on CLI (covered in interaction-audit instead)
- **No `design-token-auditor.md`** — no design tokens
- **No `journey-audit.md`** — single-screen interaction model
- **No `pages-audit.md`** — no multi-section primary surface
- **No `element-reuse.md`** — no reusable UI components

Claude Code asked the user to confirm these skips before authoring. The user agreed. The resulting kit is tight.

## Authored `.claude/agents/interaction-audit.md` excerpt (adapted for CLI)

```markdown
---
name: interaction-audit
description: Flag-vs-handler semantic integrity audit for the Rust K8s CLI. Adapted from UI interaction-audit pattern — applies to flag promises and subcommand behavior. Catches dead flags, redundant flags, optical-group disconnects in --help output.
tools: Read, Grep, Glob, Bash
model: claude-opus-4-7
---

# Interaction-Semantics Auditor — CLI

You audit CLI flag / subcommand integrity. The CLI's "chrome" is the `--help` output + flag names + subcommand structure. The "handler" is what each flag actually does. Promises and behavior must match.

## The 3 patterns this catches

1. **Dead flag** — a flag that parses but has no effect in the handler. Example: the `--force` flag that promised to skip the confirmation prompt but the handler didn't read it.
2. **Redundant flag** — two flags that do the same thing without a documented reason. Common when refactoring: `--output json` and `-o json` both work, but only one is documented in `--help`.
3. **Help-text mismatch** — `--help` says the flag accepts X but the parser accepts Y. (The JSON-vs-YAML bug shipped.)

## Audit procedure

### 1. Inventory flags

For each subcommand, list all defined flags via the argparse / clap definitions:

```bash
grep -rn 'arg\|flag(' src/cmd/ | head -100
```

For each flag, capture: name, alias, what `--help` says, what the handler reads.

### 2. Build the table

| Subcommand | Flag | --help promises | Handler does | Match? |
|---|---|---|---|---|
| `cluster create` | `--force` | "Skip confirmation prompt" | (handler doesn't read it — dead flag) | ✗ |
| `cluster delete` | `--output json` | "Output as JSON" | uses `serde_json::to_string` | ✓ |
| `pod logs` | `-f / --follow` | "Stream logs in real time" | calls `tail_logs()` | ✓ |

### 3. Pattern-detect

- ANY ✗ on a CRIT-class flag (--force, --dry-run, --output) is a CRIT.
- ANY redundant pair without documentation is a MAJ.
- ANY --help text that doesn't match the parser's actual behavior is a CRIT.

## Project-specific known dead-flag risk

The `--force` bug shipped because the flag was added to the clap config but never threaded into the prompt-skip logic. Sweep specifically for:

```bash
# Flags defined but not read
for flag in $(grep -rEo '\-\-[a-z]+' src/cmd/ | sort -u); do
  if ! grep -rq "\"$flag\"\|\"${flag#--}\"" src/handler/; then
    echo "Possibly dead: $flag"
  fi
done
```

(...full audit report format follows...)
```

## Authored `.claude/rules/forbidden-phrases.txt` (CLI-specific)

```
# Forbidden in --help output, stderr, stdout, error messages
# Override per-line: `// allow-forbidden: <reason>`

Welcome
Welcome!
Successfully completed
✨
🎉
Hi there
Let me
Please note
Note that
You should
Sorry, but
Unfortunately
As an AI
```

The principle says "include universal AI-slop deny-list + your project-specific voice phrases." Claude noticed the user's "no preamble, no celebratory language" voice and added the specific phrases ("Welcome", "Successfully completed", "✨", "🎉") that violated that.

## Authored `.claude/agents/code-reviewer.md` excerpt (Rust-specific)

```markdown
---
name: code-reviewer
description: Post-implementation review for the Rust K8s CLI. Project-specific anti-patterns derived from past bugs.
tools: Read, Grep, Glob, Bash
model: claude-opus-4-7
---

# Code Reviewer — Rust K8s CLI

You are reviewing changes to a Rust CLI tool. The general code-review methodology applies (blast-radius analysis, parallel-path detection, type contract verification). This is the project-specific layer.

## Project-specific anti-patterns (from your git log)

### Anti-pattern 1: Flag-handler disconnect
A flag defined in clap but not threaded into the handler. The `--force` bug shipped this way.
- Check: every `arg()` or `Args` field in the clap struct must be READ in the corresponding handler.
- Grep: `grep -rn "args.<flag_name>" src/handler/`

### Anti-pattern 2: Stack-trace error messages
A panic on edge input (0-byte config, malformed YAML, network error) without a graceful `Result`-typed error path.
- Check: every `unwrap()` / `expect()` in production code paths is suspect.
- Grep: `grep -rEn '\\.unwrap\\(\\)|\\.expect\\(' src/ | grep -v tests/`

### Anti-pattern 3: --help text drift
The `--help` documentation says X but the parser accepts Y.
- Check: every `clap::Arg::value_parser()` should be reflected in the `--help` line for that flag.
- Test: `cargo run -- <subcommand> --help` and read the output against the source.

(...rest of the standard code-review methodology follows...)
```

---

## What this kit demonstrates

This is what makes the plugin different from a "30-agent design kit":

- **Most of the kit is SKIPPED** because it doesn't apply (no UI = no visual reviewer; no design tokens = no token auditor)
- **The agents that DO get authored are adapted for CLI** — interaction-audit's "chrome" is help output + flag names, not buttons
- **Anti-patterns are mined from real past bugs** — the `--force` dead flag, the JSON-vs-YAML help drift, the 0-byte config panic
- **Voice rules ban CLI-specific bad phrasing** ("Welcome!", "✨", "Successfully completed")

A template kit for "design audits in any project" would either ship inapplicable agents (UX reviewer for a CLI? noise) or be useless for CLI work. Authored-per-project is the only way the kit stays focused.
