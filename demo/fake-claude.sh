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

# Scan phase — 15 reads
echo ""
echo -e "${C_BOLD}Reading your project...${C_RESET}"
sleep 0.3
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}package.json${C_RESET} — Vite + React 18 + TypeScript + Tailwind"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}README.md${C_RESET} — analytics SaaS dashboard, B2B"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}src/${C_RESET} — 47 components, 12 routes, 5 primary sections"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}tailwind.config.ts${C_RESET} — design tokens in theme.extend"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}src/styles/tokens.ts${C_RESET} — 34 semantic tokens, dark-mode ready"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}src/components/ui/${C_RESET} — Radix primitives wrapped (Dialog, Sheet, Tooltip)"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}src/lib/motion.ts${C_RESET} — Framer Motion presets file present"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}.github/workflows/${C_RESET} — Playwright e2e, no visual regression yet"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}package.json scripts${C_RESET} — dev / build / test / e2e wired"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}eslintrc${C_RESET} — no a11y plugin yet, no token-discipline rule"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}CLAUDE.md${C_RESET} — not found"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}docs/${C_RESET} — vision.md present, capabilities.md absent"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}routes${C_RESET} — dashboard / settings / billing / team / reports"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}.storybook/${C_RESET} — present, Vite framework, dark default"
sleep 0.14
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}git log${C_RESET} — mined 9 candidate anti-pattern commits"
sleep 0.7

# Phase A confirmation
echo ""
echo -e "${C_DIM}I see a Vite SaaS dashboard, semantic tokens, Storybook + Playwright wired.${C_RESET}"
echo -e "${C_DIM}Skipping platform / persona questions — your README + tooling say it all.${C_RESET}"
sleep 1.0

# Interview — 8 super-questions
echo ""
echo -e "${C_BOLD}A few questions:${C_RESET}"
sleep 0.4

echo ""
echo -e "${C_CYAN}❯${C_RESET} Q-A1 confirm: primary surface = web (browser, desktop-first)?"
sleep 0.4
echo -e "${C_YELLOW}  yes — desktop-first, responsive secondary${C_RESET}"
sleep 0.55

echo ""
echo -e "${C_CYAN}❯${C_RESET} Q-B1 — Tier 1 chrome benchmarks (2-3 apps your users compare you to):"
sleep 0.4
echo -e "${C_YELLOW}  Linear, Stripe Dashboard, Vercel${C_RESET}"
sleep 0.6

echo ""
echo -e "${C_CYAN}❯${C_RESET} Q-B2 — Tier 2 domain anchors with the dimension:"
sleep 0.4
echo -e "${C_YELLOW}  Linear for keyboard speed, WHOOP for data density,${C_RESET}"
echo -e "${C_YELLOW}  Things 3 for empty states, Datadog for charts${C_RESET}"
sleep 0.7

echo ""
echo -e "${C_CYAN}❯${C_RESET} Q-B3 — anti-references:"
sleep 0.4
echo -e "${C_YELLOW}  Bootstrap admin themes, SAP, Material 2 stacking${C_RESET}"
sleep 0.6

echo ""
echo -e "${C_CYAN}❯${C_RESET} Q-C3 — in-product assistant character?"
sleep 0.4
echo -e "${C_YELLOW}  no — chrome only, no mascot${C_RESET}"
sleep 0.6

echo ""
echo -e "${C_CYAN}❯${C_RESET} Q-D1 — multi-screen arcs (onboarding, checkout, setup)?"
sleep 0.4
echo -e "${C_YELLOW}  yes — signup → workspace-setup → first-dashboard${C_RESET}"
sleep 0.6

echo ""
echo -e "${C_CYAN}❯${C_RESET} Q-F2 — native chrome primitives + motion library?"
sleep 0.4
echo -e "${C_YELLOW}  Radix Dialog/Sheet/Tooltip; Framer Motion presets${C_RESET}"
sleep 0.6

echo ""
echo -e "${C_CYAN}❯${C_RESET} Q-I1 — I mined commit ${C_BOLD}abc1234${C_RESET} 'fix(settings): type scale violation'"
echo -e "  ${C_CYAN}+ ${C_BOLD}def5678${C_RESET} 'fix(billing): two CTAs same route'. Confirm both?"
sleep 0.5
echo -e "${C_YELLOW}  yes — settings bypassed type scale 2 weeks;${C_RESET}"
echo -e "${C_YELLOW}  billing card had Upgrade + Continue both → checkout${C_RESET}"
sleep 0.9

echo ""
echo -e "${C_DIM}Captured 47 of 53 knobs. Inferring remaining 6 from defaults.${C_RESET}"
sleep 0.8

# Authoring — 16 file lines (5 new principle outputs)
echo ""
echo -e "${C_BOLD}Authoring 16 artifacts in .claude-staging/${C_RESET}${C_DIM} — tuned to your stack${C_RESET}"
sleep 0.3
echo -e "  ${C_GREEN}✓${C_RESET} agents/ux-reviewer.md           ${C_DIM}# Linear + Stripe + Vercel anchored${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} agents/a11y-audit.md            ${C_DIM}# WCAG 2.2 AA, token-derived contrast${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} agents/interaction-audit.md     ${C_DIM}# bakes in def5678 lesson${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} agents/design-token-auditor.md  ${C_DIM}# src/styles/tokens.ts target${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} agents/pages-audit.md           ${C_DIM}# 5-section consistency${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} agents/flow-auditor.md          ${C_DIM}# signup→setup→dashboard arc${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} agents/flow-ux-reviewer.md      ${C_DIM}# continuity grader, 6 dims${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} agents/product-designer.md      ${C_DIM}# 8-step procedure, self-audit${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} agents/product-compass.md       ${C_DIM}# drift detector, reads vision.md${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} skills/design-system/SKILL.md   ${C_DIM}# Radix + Framer + token system${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} skills/journey-audit/SKILL.md   ${C_DIM}# DUAL LOAD: design + audit${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} skills/element-reuse-check/SKILL.md ${C_DIM}# Gate A verdict matrix${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} skills/persona-lens/SKILL.md    ${C_DIM}# B2B power-user lens${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} skills/quality-bar/SKILL.md     ${C_DIM}# 5-item claim-of-done${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} rules/design-north-star.md      ${C_DIM}# per-surface chrome ref table${C_RESET}"
sleep 0.1
echo -e "  ${C_GREEN}✓${C_RESET} hooks/check-design-tokens.sh    ${C_DIM}# blocks raw hex outside tokens.ts${C_RESET}"
sleep 0.9

echo ""
echo -e "${C_GREEN}${C_BOLD}✓ Done.${C_RESET} Review .claude-staging/, commit when approved."
sleep 1.1

# Authored-output excerpt — 15 lines from ux-reviewer.md
echo ""
echo -e "${C_CYAN}${C_BOLD}> sed -n '42,57p' .claude-staging/agents/ux-reviewer.md${C_RESET}"
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
echo -e "${C_GRAY}2. ${C_BOLD}Redundant CTA on billing${C_RESET}${C_GRAY} (commit def5678) — affordance-vs-handler...${C_RESET}"
sleep 1.4
