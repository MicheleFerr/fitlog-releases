#!/bin/bash

################################################################################
# 🔧 GymBro Git Hooks Installer
#
# Installs git hooks for code quality enforcement
#
# Usage:
#   ./scripts/install_hooks.sh
#
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  🔧 ${BLUE}GymBro Git Hooks Installer${NC}                            ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}✗${NC}  Error: Not a git repository"
    echo -e "${YELLOW}ℹ${NC}  Run this script from the project root"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

echo -e "${BLUE}ℹ${NC}  Installing git hooks..."
echo ""

# Install pre-commit hook
HOOK_SOURCE="scripts/pre-commit-theme-check"
HOOK_DEST=".git/hooks/pre-commit"

if [ ! -f "$HOOK_SOURCE" ]; then
    echo -e "${RED}✗${NC}  Error: $HOOK_SOURCE not found"
    exit 1
fi

# Check if hook already exists
if [ -f "$HOOK_DEST" ]; then
    echo -e "${YELLOW}⚠${NC}  Pre-commit hook already exists"
    echo -ne "   Replace existing hook? (y/n): "
    read -r REPLACE

    if [ "$REPLACE" != "y" ] && [ "$REPLACE" != "Y" ]; then
        echo -e "${YELLOW}ℹ${NC}  Installation cancelled"
        exit 0
    fi

    # Backup existing hook
    cp "$HOOK_DEST" "$HOOK_DEST.backup"
    echo -e "${GREEN}✓${NC}  Backed up existing hook to: $HOOK_DEST.backup"
fi

# Copy and make executable
cp "$HOOK_SOURCE" "$HOOK_DEST"
chmod +x "$HOOK_DEST"

echo -e "${GREEN}✓${NC}  Installed: pre-commit hook (theme check)"
echo ""

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ✅ ${GREEN}Installation Complete${NC}                                   ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📋 What happens now:${NC}"
echo ""
echo -e "  • Every commit will be checked for hardcoded color violations"
echo -e "  • Violations will ${RED}block the commit${NC} with helpful error messages"
echo -e "  • Use ${CYAN}./scripts/fix_theme_violations.sh${NC} to auto-fix violations"
echo ""

echo -e "${YELLOW}⚠${NC}  To bypass the hook (NOT RECOMMENDED):"
echo -e "    ${CYAN}git commit --no-verify${NC}"
echo ""

echo -e "${GREEN}✓${NC}  Hooks installed successfully!"
echo ""
