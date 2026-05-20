#!/usr/bin/env bash
# Demo simulation of /dotclaude:design — used by demo/demo.tape (vhs) to generate
# the README hero gif. The output mirrors the actual flow; sleeps create rhythm.

set -e

C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_GRAY='\033[90m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

# Prompt
echo -e "${C_CYAN}${C_BOLD}> /dotclaude:design${C_RESET}"
sleep 0.6

# Scan phase — 12 reads
echo ""
echo -e "${C_BOLD}Reading your project...${C_RESET}"
sleep 0.3
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}package.json${C_RESET} — Vite + React 18 + TypeScript + Tailwind"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}README.md${C_RESET} — analytics SaaS dashboard"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}src/${C_RESET} — 47 components, 12 routes, 5 primary sections"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}tailwind.config.ts${C_RESET} — design tokens in theme.extend"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}src/styles/tokens.ts${C_RESET} — 34 semantic tokens, dark mode ready"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}src/components/${C_RESET} — sampled 8 component files"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}.github/workflows/${C_RESET} — Playwright e2e, no visual regression yet"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}package.json scripts${C_RESET} — dev / build / test / e2e wired"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}eslintrc${C_RESET} — no a11y plugin yet, no token-discipline rule"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}CLAUDE.md${C_RESET} — not found"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}git log${C_RESET} — 4 design-flavored fix commits in last 30"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}routes${C_RESET} — dashboard / settings / billing / team / reports"
sleep 0.7

# Phase A confirmation
echo ""
echo -e "${C_DIM}I see this is a Vite SaaS dashboard with semantic tokens already wired.${C_RESET}"
echo -e "${C_DIM}Skipping platform / persona questions — your README says it all.${C_RESET}"
sleep 1.0

# Interview — 7 visible Qs
echo ""
echo -e "${C_BOLD}A few questions:${C_RESET}"
sleep 0.4

echo ""
echo -e "${C_CYAN}❯${C_RESET} Tier 1 chrome benchmarks — 2-3 apps your users compare you to:"
sleep 0.4
echo -e "${C_YELLOW}  Linear, Stripe Dashboard${C_RESET}"
sleep 0.6

echo ""
echo -e "${C_CYAN}❯${C_RESET} Tier 2 domain anchors — apps + the specific dimension:"
sleep 0.4
echo -e "${C_YELLOW}  Linear for keyboard speed, WHOOP for data density,${C_RESET}"
echo -e "${C_YELLOW}  Things 3 for empty states${C_RESET}"
sleep 0.7

echo ""
echo -e "${C_CYAN}❯${C_RESET} Anti-references — apps the design should NOT look like:"
sleep 0.4
echo -e "${C_YELLOW}  Bootstrap admin themes, anything SAP-flavored${C_RESET}"
sleep 0.7

echo ""
echo -e "${C_CYAN}❯${C_RESET} In-product character / assistant?"
sleep 0.4
echo -e "${C_YELLOW}  No — chrome only, no mascot${C_RESET}"
sleep 0.7

echo ""
echo -e "${C_CYAN}❯${C_RESET} I see commit ${C_BOLD}abc1234${C_RESET} — 'fix(settings): type scale violation'"
echo -e "  ${C_CYAN}Tell me what happened?${C_RESET}"
sleep 0.5
echo -e "${C_YELLOW}  Settings page bypassed our type scale for 2 weeks${C_RESET}"
echo -e "${C_YELLOW}  before someone screenshotted it next to Linear${C_RESET}"
sleep 0.9

echo ""
echo -e "${C_CYAN}❯${C_RESET} And commit ${C_BOLD}def5678${C_RESET} — 'fix(billing): two CTAs same route'?"
sleep 0.5
echo -e "${C_YELLOW}  Card had Upgrade + Continue both routing to checkout${C_RESET}"
sleep 0.9

echo ""
echo -e "${C_CYAN}❯${C_RESET} Quality bar — defensive or offensive?"
sleep 0.4
echo -e "${C_YELLOW}  defensive — Linear-grade chrome, no rough edges${C_RESET}"
sleep 1.0

# Authoring — 12 file lines
echo ""
echo -e "${C_BOLD}Authoring 12 artifacts in .claude-staging/${C_RESET}${C_DIM} — tuned to your stack${C_RESET}"
sleep 0.3
echo -e "  ${C_GREEN}✓${C_RESET} agents/ux-reviewer.md           ${C_DIM}# Linear + Stripe anchored${C_RESET}"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} agents/a11y-audit.md            ${C_DIM}# WCAG AA, web-flavored${C_RESET}"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} agents/interaction-audit.md     ${C_DIM}# bakes in def5678 lesson${C_RESET}"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} agents/design-token-auditor.md  ${C_DIM}# src/styles/tokens.ts${C_RESET}"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} agents/pages-audit.md           ${C_DIM}# 5-section consistency${C_RESET}"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} skills/journey-audit/SKILL.md"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} skills/element-reuse-check/SKILL.md"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} skills/persona-lens/SKILL.md    ${C_DIM}# B2B power-user lens${C_RESET}"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} skills/quality-bar/SKILL.md"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} rules/design-north-star.md      ${C_DIM}# Linear + Stripe + Things 3${C_RESET}"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} rules/audit-routing.md"
sleep 0.12
echo -e "  ${C_GREEN}✓${C_RESET} hooks/check-design-tokens.sh    ${C_DIM}# blocks raw hex outside tokens.ts${C_RESET}"
sleep 0.9

echo ""
echo -e "${C_GREEN}${C_BOLD}✓ Done.${C_RESET} Review .claude-staging/, commit when approved."
sleep 1.1

# Authored-output excerpt — 15 lines from ux-reviewer.md
echo ""
echo -e "${C_CYAN}${C_BOLD}> sed -n '40,55p' .claude-staging/agents/ux-reviewer.md${C_RESET}"
sleep 0.6
echo -e "${C_GRAY}### Rubric (anchored to YOUR benchmarks)${C_RESET}"
echo ""
echo -e "${C_GRAY}- ${C_BOLD}S${C_RESET}${C_GRAY} = sits next to a ${C_BOLD}Linear${C_RESET}${C_GRAY} screen with no visible chrome drop${C_RESET}"
echo -e "${C_GRAY}- ${C_BOLD}A${C_RESET}${C_GRAY} = ships at Linear quality after one polish pass${C_RESET}"
echo -e "${C_GRAY}- ${C_BOLD}B${C_RESET}${C_GRAY} = competent SaaS, recognizably yours, not Linear-tier${C_RESET}"
echo -e "${C_GRAY}- ${C_BOLD}C${C_RESET}${C_GRAY} = ships but visibly behind ${C_BOLD}Stripe Dashboard${C_RESET}${C_GRAY} parity${C_RESET}"
echo -e "${C_GRAY}- ${C_BOLD}D${C_RESET}${C_GRAY} = embarrassing next to either; block ship${C_RESET}"
echo ""
echo -e "${C_GRAY}### Project-specific anti-patterns${C_RESET}"
echo ""
echo -e "${C_GRAY}1. ${C_BOLD}Type-scale bypass on Settings${C_RESET}${C_GRAY} (commit abc1234)${C_RESET}"
echo -e "${C_GRAY}   — scan every Settings-class surface for inline${C_RESET}"
echo -e "${C_GRAY}   font-size literals against tokens.ts typography scale${C_RESET}"
echo -e "${C_GRAY}2. ${C_BOLD}Empty state apologizes${C_RESET}${C_GRAY} — Things 3 teaches; ours sometimes...${C_RESET}"
sleep 1.4
