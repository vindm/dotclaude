#!/usr/bin/env bash
# Block obvious credential patterns in source.
# Critical hook — exit 2 on any match. Override: `// allow-secret: <reason>` per line.
set -euo pipefail
input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0

# Skip .env files themselves; they're meant to hold secrets locally
case "$file" in *.env*|*node_modules*) exit 0 ;; esac

# AWS access key, OpenAI/Anthropic-prefix, GitHub PAT, Stripe keys
if grep -nE '(AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{30,}|ghp_[A-Za-z0-9]{30,}|pk_(test|live)_[A-Za-z0-9]{20,}|sk_(test|live)_[A-Za-z0-9]{20,})' "$file" 2>/dev/null | grep -v 'allow-secret' > /tmp/.dc-sec.$$; then
  echo "❌ Credential pattern detected:" >&2
  while IFS= read -r line; do echo "  $file:$line" >&2; done < /tmp/.dc-sec.$$
  echo "   Move secret to .env (gitignored). Override: \`// allow-secret: <reason>\`" >&2
  rm -f /tmp/.dc-sec.$$
  exit 2
fi
rm -f /tmp/.dc-sec.$$
exit 0
