# Meta-interview — `/dotclaude:init`

The meta init does NOT do a long interview itself. Its only interview question is:

> "Based on the project scan, I'm planning to run these domain flows: [list]. SKIPPING these because [reasons]. Sound right, or want to adjust the list?"

The detailed interview happens inside each domain skill (`skills/<domain>/interview.md`). Each domain owns its own 3-5 scoped questions.

## When to deviate from "just confirm the list"

- If the project scan in Phase 1 surfaced something AMBIGUOUS (e.g. "I see `ios/` AND `web/` — is this a monorepo with both surfaces, or did you migrate from one to the other?"), ask one clarifying question first.
- If the user's framing in `README.md` suggests goals that don't map to any domain (e.g. "this is a research notebook for ML experiments"), ask which domain framing fits best — the matrix may need adapting.

Otherwise: keep this interview ONE turn. The domain skills are where the real Q&A happens.
