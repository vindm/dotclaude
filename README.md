# dotclaude

> Battle-tested Claude Code workflow pack — guardrails, audit pipelines, war-stories.
> Generates a curated `.claude/` directory for your project in 60 seconds.

**Status:** Pre-release (v0.x). Plans 2-6 still landing. Star to follow.

## Quick start

```bash
cd your-project
npx dotclaude init
```

Pick a profile, answer 4 questions, get a working `.claude/`.

## What's in v0.0.1

- 1 profile: `minimal` (sole-dev SPA starter)
- 2 hooks: `check-file-size`, `check-forbidden-phrases`
- 4 CLI commands: `init`, `list`, `status`, `help`

## What's coming

- More profiles (web-saas, mobile-rn, api-only, full-stack)
- Full template library: hooks, rules, skills, agents
- War-stories: dated failure cases with the guardrail that prevents them
- Bootstrap skill: smart detection that reads your codebase and recommends a setup
- Examples: battle-tested instantiations for different stacks

## License

MIT
