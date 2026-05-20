#!/usr/bin/env bash
# Demo simulation of /dotclaude:bootstrap — full 7-layer hierarchical setup.
# Used by demo/bootstrap.tape (vhs) to generate the README hero gif.

set -e

C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_GRAY='\033[90m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

# Invocation
echo -e "${C_CYAN}${C_BOLD}> /dotclaude:bootstrap${C_RESET}"
sleep 0.8

# Phase 1 — Project scan
echo ""
echo -e "${C_BOLD}Phase 1${C_RESET} ${C_GRAY}— Reading your project...${C_RESET}"
sleep 0.3
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}package.json${C_RESET}    Expo + React Native + TypeScript"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}src/${C_RESET}            23 components, 8 routes"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}CLAUDE.md${C_RESET}       none (greenfield)"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}git log${C_RESET}         4 weeks, 1 contributor, 'fix:' x 3"
sleep 0.6
echo -e "${C_DIM}  → mode: greenfield, full 7-layer walk${C_RESET}"
sleep 0.9

# Phase 2 — Hierarchical interview
echo ""
echo -e "${C_BOLD}Phase 2${C_RESET} ${C_GRAY}— Hierarchical interview${C_RESET}"
sleep 0.4

# Layer 1
echo ""
echo -e "${C_CYAN}┃ Layer 1${C_RESET} ${C_BOLD}Project Identity${C_RESET}"
sleep 0.25
echo -e "  ${C_DIM}❯${C_RESET} One-sentence project description?"
sleep 0.45
echo -e "${C_YELLOW}    An iOS habit tracker for AI-literate users${C_RESET}"
sleep 0.55

# Layer 2
echo -e "${C_CYAN}┃ Layer 2${C_RESET} ${C_BOLD}Architecture${C_RESET}"
sleep 0.25
echo -e "  ${C_DIM}❯${C_RESET} Stack confirmed (Expo + RN). File-size ceiling?"
sleep 0.45
echo -e "${C_YELLOW}    1000 LOC, decompose at 900${C_RESET}"
sleep 0.55

# Layer 3
echo -e "${C_CYAN}┃ Layer 3${C_RESET} ${C_BOLD}Process Discipline${C_RESET}"
sleep 0.25
echo -e "  ${C_DIM}❯${C_RESET} Plan-driven for major features? (spec → conformance)"
sleep 0.45
echo -e "${C_YELLOW}    yes${C_RESET}"
sleep 0.55

# Layer 4
echo -e "${C_CYAN}┃ Layer 4${C_RESET} ${C_BOLD}Quality Bar${C_RESET}"
sleep 0.25
echo -e "  ${C_DIM}❯${C_RESET} Tier 1 chrome benchmarks?"
sleep 0.45
echo -e "${C_YELLOW}    Apple iOS 26, Telegram, Things 3${C_RESET}"
sleep 0.55

# Layer 5
echo -e "${C_CYAN}┃ Layer 5${C_RESET} ${C_BOLD}Knowledge Graph${C_RESET}"
sleep 0.25
echo -e "  ${C_DIM}❯${C_RESET} Set up docs/ — brainstorms/specs/plans/audits?"
sleep 0.45
echo -e "${C_YELLOW}    yes, default layout${C_RESET}"
sleep 0.55

# Layer 6
echo -e "${C_CYAN}┃ Layer 6${C_RESET} ${C_BOLD}Domain Kits${C_RESET}"
sleep 0.25
echo -e "  ${C_DIM}❯${C_RESET} Detected: design, coding, planning. Add data / ai-workflow?"
sleep 0.45
echo -e "${C_YELLOW}    add data, skip ai-workflow${C_RESET}"
sleep 0.55

# Layer 7
echo -e "${C_CYAN}┃ Layer 7${C_RESET} ${C_BOLD}Maintenance${C_RESET}"
sleep 0.25
echo -e "  ${C_DIM}❯${C_RESET} Saturday-style drift-detection ritual?"
sleep 0.45
echo -e "${C_YELLOW}    defer (project too young)${C_RESET}"
sleep 0.9

# Phase 3 — Cross-layer coordination
echo ""
echo -e "${C_BOLD}Phase 3${C_RESET} ${C_GRAY}— Cross-layer coordination${C_RESET}"
sleep 0.3
echo -e "  ${C_GREEN}✓${C_RESET} Merged forbidden phrases (Layer 4 + Layer 6 design + coding)"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} Reconciled audit routing across 4 domains"
sleep 0.85

# Phase 4 — Authored inventory
echo ""
echo -e "${C_BOLD}Phase 4${C_RESET} ${C_GRAY}— Authored to .claude-staging/${C_RESET}"
sleep 0.3
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}CLAUDE.md${C_RESET}         ${C_DIM}124 LOC, 6 sections${C_RESET}"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}docs/${C_RESET}             ${C_DIM}README.md + 6 subdirs${C_RESET}"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}.claude/rules/${C_RESET}    ${C_DIM}5 files${C_RESET}"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}.claude/agents/${C_RESET}   ${C_DIM}5 files (ux/code/pre-flight/data/+1)${C_RESET}"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}.claude/skills/${C_RESET}   ${C_DIM}6 dirs${C_RESET}"
sleep 0.18
echo -e "  ${C_GREEN}✓${C_RESET} ${C_GRAY}.claude/hooks/${C_RESET}    ${C_DIM}8 .sh files${C_RESET}"
sleep 0.8

# Approval gate
echo ""
echo -e "  ${C_CYAN}❯${C_RESET} Review .claude-staging/ + commit?"
sleep 0.5
echo -e "${C_YELLOW}    ship it${C_RESET}"
sleep 0.6

# Phase 5 — Done
echo ""
echo -e "${C_GREEN}${C_BOLD}✓ Bootstrap complete.${C_RESET} ${C_DIM}Tailored to your stack.${C_RESET}"
sleep 0.3
echo -e "${C_DIM}  Next: fill capabilities.md as features ship.${C_RESET}"
sleep 2.0
