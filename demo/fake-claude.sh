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
sleep 0.7

# Scan phase
echo ""
echo -e "${C_BOLD}Reading your project...${C_RESET}"
sleep 0.35
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}package.json${C_RESET} — Vite + React + TypeScript + Tailwind"
sleep 0.22
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}src/${C_RESET} — 47 components, 12 routes"
sleep 0.22
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}tailwind.config.ts${C_RESET} — design system present"
sleep 0.22
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}git log${C_RESET} — 3 recent design fixes"
sleep 0.9

# Interview
echo ""
echo -e "${C_BOLD}A few questions:${C_RESET}"
sleep 0.5

echo ""
echo -e "${C_CYAN}❯${C_RESET} Name 2-4 apps you benchmark against:"
sleep 0.45
echo -e "${C_YELLOW}  Linear, Stripe Dashboard${C_RESET}"
sleep 0.7

echo ""
echo -e "${C_CYAN}❯${C_RESET} Past design bugs you wish hadn't shipped?"
sleep 0.45
echo -e "${C_YELLOW}  Settings page bypassed our type scale for 2 weeks${C_RESET}"
sleep 0.7

echo ""
echo -e "${C_CYAN}❯${C_RESET} Quality bar — defensive or offensive?"
sleep 0.45
echo -e "${C_YELLOW}  defensive${C_RESET}"
sleep 0.9

# Authoring
echo ""
echo -e "${C_BOLD}Authoring 8 artifacts in .claude-staging/${C_RESET}${C_DIM} — tuned to your stack${C_RESET}"
sleep 0.3
echo -e "  ${C_GREEN}✓${C_RESET} agents/ux-reviewer.md           ${C_DIM}# Linear + Stripe anchored${C_RESET}"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} agents/a11y-audit.md            ${C_DIM}# WCAG AA, web-flavored${C_RESET}"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} agents/interaction-audit.md"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} agents/design-token-auditor.md  ${C_DIM}# sweeps src/styles/tokens.ts${C_RESET}"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} skills/journey-audit/SKILL.md"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} skills/element-reuse-check/SKILL.md"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} rules/design-north-star.md      ${C_DIM}# your benchmarks${C_RESET}"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} hooks/check-design-tokens.sh"
sleep 0.7

echo ""
echo -e "${C_GREEN}${C_BOLD}✓ Done.${C_RESET} Review .claude-staging/, commit when approved."
sleep 1.3

# Peek at one authored file
echo ""
echo -e "${C_CYAN}${C_BOLD}> head -5 .claude-staging/rules/design-north-star.md${C_RESET}"
sleep 0.5
echo -e "${C_GRAY}# Design north star — analytics dashboard${C_RESET}"
echo ""
echo -e "${C_GRAY}This project benchmarks against ${C_RESET}${C_BOLD}Linear + Stripe Dashboard${C_RESET}${C_GRAY}.${C_RESET}"
echo ""
echo -e "${C_GRAY}When making a UI decision: ${C_RESET}${C_DIM}\"would Linear or Stripe do this?\"${C_RESET}"
sleep 2.2
