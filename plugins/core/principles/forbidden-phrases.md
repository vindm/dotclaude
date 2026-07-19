# forbidden-phrases — designing a voice / tone deny-list for ANY project

Teaching material for Claude Code. When you bootstrap a `.claude/` directory, this doc teaches you HOW to design a project-specific deny-list of phrases — the kind of voice-discipline enforcement that catches AI-slop and tone drift before it ships.

## When to ship one (applicability gate)

Ship a forbidden-phrases list (+ companion hook from `hook-templates/check-forbidden-phrases.sh`) when:

- The project has **any human-facing copy** — UI strings, error messages, marketing copy, documentation read by end users, AI-assistant output text, in-app onboarding.
- The user has **opinions about voice / brand / tone** — they've used words like "voice," "register," "tone," "personality," "doesn't sound like us."
- The user has had to revert / rewrite shipped copy at least once because it "sounded wrong."

Skip when:

- The project is a developer library / CLI tool with no human-readable strings beyond error messages.
- The user is indifferent to voice — "as long as it's grammatical, ship it."
- The project's voice is entirely user-generated content (forum / chat / social) where the platform shouldn't impose voice constraints on users.

## Why it matters — what this catches that nothing else does

Two failure modes, equally pernicious:

1. **AI-slop phrases.** LLMs default to a set of phrases ("Let me help you with that!" / "I'd be happy to assist!" / "I'm here to help" / "Let's get started!") that don't belong on any production surface that isn't an introduction. They sound friendly in isolation; they sound like a customer-service bot when stacked on every screen. A deny-list catches them at edit time before they ship.

2. **Voice drift.** A brand voice with personality — terse, direct, dry, technical, intimate, whatever — accretes counter-examples one copy change at a time. Someone writes a friendly "Welcome!" because it seems polite. The reviewer doesn't catch it because each individual change looks fine. Six months later the product sounds like a default startup. A deny-list is the cheapest defense: write the phrases that don't belong, and edit-time guards block them.

What this catches that ESLint doesn't: linters don't see content. What this catches that code review doesn't: a busy reviewer reads code, not strings — and even if they did, voice violations look fine in isolation. Only an automated phrase scan on every translation / copy file catches the problem reliably.

## Core methodology — the two-axis structure

A good deny-list has two parts. Each entry belongs to one axis or the other:

### Axis 1 — Universal AI-slop denials

Phrases that don't belong on any production surface in any project. These are stack-agnostic and project-agnostic. Examples:

- Greeting-as-stranger when the assistant has already met the user ("Hi", "Hello", "Hey there")
- Self-introduction phrases on non-introduction surfaces ("I'm <name>", "My name is", "Let me introduce", "Meet <name>")
- Welcoming language outside actual welcome screens ("Welcome", "Welcome to <product>")
- Onboarding register on daily-driver surfaces ("Let's get started", "Let's begin", "First, let me explain", "Here's how this works")
- Customer-service bot register ("I'm here to help", "How can I help", "Sorry to interrupt", "Sorry, that didn't work", "Oops")
- Filler validation phrases ("Great question!", "Excellent!", "Absolutely!", "Of course!")

These survive across projects because they are LLM-default text. If the user's project uses LLMs to generate any text, these are nearly-mandatory denials.

### Axis 2 — Project-specific voice violations

Phrases that violate THIS project's voice. These can only come from the user. Examples (illustrative shapes, not literal entries):

- A product that doesn't use exclamation marks → ban "!"
- A product whose voice is intimate first-person → ban third-person referring to the user
- A product that never apologizes → ban "Sorry"
- A product that uses dry-British-technical voice → ban "awesome", "amazing", "love"
- A product that doesn't promise outcomes → ban "guaranteed", "definitely", "always"
- A product that addresses customers as professionals → ban "guys", "folks", "hi there"

These are the entries that make the deny-list specific to THIS project. Without them, the list is just a generic AI-slop filter — useful, but not voice-shaping.

## How to derive THIS project's specifics

Before authoring the list, gather signal:

1. **Direct user interview.** Ask: *"Read me a piece of your product's copy that nails the voice. Now read me one that doesn't sound right. What's the difference?"* The answers expose the voice rules.

2. **Check for an existing voice / tone doc.** `docs/voice.md`, `docs/style-guide.md`, `docs/persona.md`, `docs/brand.md`. If one exists, treat it as authoritative; extract its forbidden / discouraged list as candidate entries.

3. **Look at the product's actual production copy.** Grep for adjectives and exclamation marks: `grep -rEi "amazing|awesome|love|exciting|!" <copy-dirs>/`. The grep results are either intentional or accidental. Ask the user to mark which.

4. **Look for recent "reverted copy" commits.** `git log --grep="copy.*revert\|rewrite.*string\|fix.*tone"`. Reverted phrases are the canonical voice violations — they shipped, the user noticed, the user pulled them back. Each one is a candidate entry.

5. **Identify the project's exempt surfaces.** Where does Axis 1 NOT apply? Usually:
   - First-touch onboarding (the one place greetings + introductions belong)
   - Marketing landing pages (different voice posture)
   - Error states (some apologies are appropriate)
   - Documentation (more formal voice register)

   The hook should exempt these paths so it doesn't flag legitimate uses.

6. **Identify the LLM-generated surfaces.** Where does AI write strings that end up in the product? Prompt templates, generated copy, assistant responses. These need the deny-list applied to the *output*, not just the source code. Encode the path patterns for the LLM-output files.

## Authoring the list

The final artifact (typically `.claude/rules/forbidden-phrases.txt`) is a flat text file, one phrase per line, with `#` comments for grouping. Companion hook (`hook-templates/check-forbidden-phrases.sh`) does case-insensitive word-boundary matching against the file.

Structure conventions:

```txt
# Forbidden phrases — <one-line scope statement>
#
# Format: one phrase per line. # for comments.
# Match: case-insensitive, word boundaries inside string literals.
# Source of truth for: <related doc paths>
#
# Override syntax: <on-line override comment>
# Exempt files: <list of path patterns>

# === Universal AI-slop ===

# Greeting-as-stranger
Hi
Hello
Hey there

# Self-introduction
I'm <assistant-name>
My name is

# Welcome
Welcome
Welcome to <product>

# === Project-specific voice violations ===

# (project-specific entries derived from the user's voice rules)
```

Each section heading is grouping for the human reader; the hook ignores them.

## The override convention

Some matches will be legitimate. The first-touch wizard's "Welcome!" is a legitimate use; the deny-list shouldn't block it. Override mechanisms:

- **Per-line override comment.** `welcome: "Welcome to <product>",  // allow-forbidden: <reason>`. Requires the developer to acknowledge they're using a forbidden phrase and write a reason. Cheap, audit-trail-preserving.
- **Per-file exemption.** Listed in the hook config, by path. For files that are entirely greeting / introduction content (e.g., `wizard/meet-assistant.tsx`), exempt the file rather than every line.

The reason field is the audit trail. A bare `// allow-forbidden:` with no reason should be itself a violation; the override mechanism should fail if the reason is missing.

## The companion hook — the teeth

The deny-list alone is advisory; the companion hook is the enforcement. The hook:

- Fires on Edit / Write to files matching the project's copy-file patterns (translation files, narration files, copy modules, assistant-name files).
- Reads the deny-list (path is config).
- Scans the changed lines for any match.
- Reports the violation with the matched phrase, line number, and a pointer to the override convention.

Configure the hook's file-pattern scope to match THIS project's actual copy file locations. A web app might check `src/translations/*.ts`, `src/copy/*.json`, `src/components/*Copy.tsx`. A mobile app might check `lib/translations/`, `lib/<feature>/narration.ts`. Encode the project's actual paths; generic globs miss real files and flag wrong ones.

The hook should NOT scan:
- Source comments (matches inside `// ...` or `/* ... */` are usually irrelevant)
- Test fixtures (test data might intentionally contain phrases under test)
- The deny-list file itself (it contains all the phrases by definition)

## Cross-references

- `quality-rubric.md` — voice / tone is one dimension of the rubric (the "tone mismatch" pitfall). The deny-list is the upstream enforcement.
- `audit-routing.md` — when audit agents grade content quality, voice violations they would flag are upstream-prevented by the hook + deny-list.
- `hook-templates/check-forbidden-phrases.sh` — the edit-time enforcement. List is empty without the hook wired in.

## Anti-patterns in the list you write

- **Generic AI-slop only.** A list of "Hi / Hello / Welcome" is useful but not voice-shaping. The project-specific entries are what make the list characterize the product's voice — don't ship without them.

- **Project-specific entries without examples.** A bare entry like "amazing" doesn't tell the future maintainer why. A grouped section with a one-line comment ("# adjectives that don't match our dry-technical register") is self-documenting.

- **No override mechanism.** When the legitimate first-touch greeting gets blocked, the developer needs a way to allow it without disabling the whole hook. The on-line override syntax with a required reason is the minimum.

- **Wide-glob file patterns.** Scanning every `*.ts` file produces false positives in test fixtures, debug code, and example data. Scope to the actual copy / translation / narration / assistant-name file patterns.

- **No source-of-truth pointer.** The deny-list is referenced by other docs (voice / tone style guide, persona doc). The header should name the related docs so they don't drift apart.

- **List grows without pruning.** Every "we shipped a thing and reverted it" adds an entry; nothing removes entries. Periodically (every quarter, every major release), audit which entries still match the current voice. Some will be stale.

- **Forgetting LLM-output surfaces.** If the project uses LLMs to generate text, the deny-list applies to the OUTPUT, not just the source. Encode the post-generation scan (in the prompt's system / fewshot, in a validation step) so model-generated slop doesn't ship.
