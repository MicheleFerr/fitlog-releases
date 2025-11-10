#!/bin/bash

# 🎯 GymBro Auto-Checkpoint Script
#
# Auto-committa modifiche significative per triggerare pre-commit hook checks
#
# USAGE:
#   ./scripts/checkpoint.sh              # Commit immediato
#   ./scripts/checkpoint.sh --watch      # Watch mode (auto-commit su grandi modifiche)
#   ./scripts/checkpoint.sh --threshold 100  # Custom threshold (righe modificate)
#
# SOGLIE DEFAULT:
#   - 50+ righe modificate in totale
#   - OPPURE 3+ file .dart modificati
#   - Esegue tutti i check del pre-commit hook

set -e

# Colori
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Config
THRESHOLD_LINES=50
THRESHOLD_FILES=3
WATCH_INTERVAL=30  # secondi
WATCH_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --watch)
      WATCH_MODE=true
      shift
      ;;
    --threshold)
      THRESHOLD_LINES="$2"
      shift 2
      ;;
    --interval)
      WATCH_INTERVAL="$2"
      shift 2
      ;;
    --help)
      echo "GymBro Auto-Checkpoint Script"
      echo ""
      echo "Usage:"
      echo "  ./scripts/checkpoint.sh              # Commit immediato"
      echo "  ./scripts/checkpoint.sh --watch      # Watch mode"
      echo "  ./scripts/checkpoint.sh --threshold 100  # Custom threshold"
      echo ""
      echo "Options:"
      echo "  --watch          Enable watch mode (auto-commit on changes)"
      echo "  --threshold N    Set line change threshold (default: 50)"
      echo "  --interval N     Watch interval in seconds (default: 30)"
      echo "  --help           Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Function: Check if we should commit
should_commit() {
  # Check if there are unstaged changes in lib/
  CHANGED_FILES=$(git diff --name-only lib/ 2>/dev/null | grep "\.dart$" | wc -l | xargs)

  if [ "$CHANGED_FILES" = "0" ]; then
    return 1  # No changes
  fi

  # Count total lines changed
  LINES_CHANGED=$(git diff --stat lib/ 2>/dev/null | tail -1 | awk '{print $4+$6}' || echo "0")
  LINES_CHANGED=${LINES_CHANGED:-0}

  # Debug output
  if [ "$WATCH_MODE" = true ]; then
    echo -e "${CYAN}📊 Changes detected: ${CHANGED_FILES} files, ~${LINES_CHANGED} lines${NC}"
  fi

  # Check thresholds
  if [ "$LINES_CHANGED" -ge "$THRESHOLD_LINES" ]; then
    echo -e "${YELLOW}⚡ Threshold met: ${LINES_CHANGED} lines (>= ${THRESHOLD_LINES})${NC}"
    return 0  # Should commit
  fi

  if [ "$CHANGED_FILES" -ge "$THRESHOLD_FILES" ]; then
    echo -e "${YELLOW}⚡ Threshold met: ${CHANGED_FILES} files (>= ${THRESHOLD_FILES})${NC}"
    return 0  # Should commit
  fi

  return 1  # Thresholds not met
}

# Function: Create checkpoint commit
create_checkpoint() {
  echo ""
  echo -e "${BLUE}🔍 Analyzing changes...${NC}"

  # Get changed files summary
  CHANGED_FILES_LIST=$(git diff --name-only lib/ 2>/dev/null | grep "\.dart$" || true)
  FILE_COUNT=$(echo "$CHANGED_FILES_LIST" | grep -v "^$" | wc -l | xargs)

  if [ "$FILE_COUNT" = "0" ]; then
    echo -e "${GREEN}✅ No Dart files modified in lib/${NC}"
    return 0
  fi

  # Show summary
  echo -e "${CYAN}📝 Files to commit (${FILE_COUNT}):${NC}"
  echo "$CHANGED_FILES_LIST" | head -n 5
  if [ "$FILE_COUNT" -gt 5 ]; then
    echo "   ... and $((FILE_COUNT - 5)) more"
  fi
  echo ""

  # Stage all .dart files in lib/
  echo -e "${BLUE}📦 Staging changes...${NC}"
  git add lib/**/*.dart 2>/dev/null || git add lib/*.dart 2>/dev/null || true

  # Also stage CLAUDE.md if modified (redundant with pre-commit hook, but explicit)
  if [ -f "CLAUDE.md" ]; then
    git diff --name-only CLAUDE.md 2>/dev/null | grep -q "CLAUDE.md" && git add CLAUDE.md || true
  fi

  # Generate commit message with timestamp and file summary
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  COMMIT_MSG="chore: checkpoint - ${FILE_COUNT} files modified

Auto-checkpoint at ${TIMESTAMP}

Modified files:
$(echo "$CHANGED_FILES_LIST" | head -n 10 | sed 's/^/- /')
$([ "$FILE_COUNT" -gt 10 ] && echo "... and $((FILE_COUNT - 10)) more")

🤖 Auto-generated checkpoint commit
Triggered by: checkpoint.sh
Threshold: ${THRESHOLD_LINES} lines OR ${THRESHOLD_FILES} files"

  # Create commit (triggers pre-commit hook)
  echo -e "${BLUE}💾 Creating checkpoint commit...${NC}"
  echo ""

  if git commit -m "$COMMIT_MSG"; then
    echo ""
    echo -e "${GREEN}✅ Checkpoint created successfully!${NC}"
    echo -e "${GREEN}   Pre-commit hooks executed${NC}"
    echo -e "${GREEN}   ${FILE_COUNT} files committed${NC}"

    # Show commit hash
    COMMIT_HASH=$(git rev-parse --short HEAD)
    echo -e "${CYAN}   Commit: ${COMMIT_HASH}${NC}"
    return 0
  else
    echo ""
    echo -e "${RED}❌ Commit failed (pre-commit hook blocked)${NC}"
    echo -e "${YELLOW}💡 Fix the errors shown above and try again${NC}"
    return 1
  fi
}

# Function: Watch mode
watch_mode() {
  echo -e "${BLUE}👁️  Watch mode enabled${NC}"
  echo -e "${CYAN}   Threshold: ${THRESHOLD_LINES} lines OR ${THRESHOLD_FILES} files${NC}"
  echo -e "${CYAN}   Interval: ${WATCH_INTERVAL}s${NC}"
  echo -e "${CYAN}   Monitoring: lib/**/*.dart${NC}"
  echo ""
  echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
  echo ""

  while true; do
    if should_commit; then
      echo ""
      echo -e "${YELLOW}🎯 Significant changes detected! Creating checkpoint...${NC}"
      create_checkpoint
      echo ""
      echo -e "${BLUE}👁️  Resuming watch mode...${NC}"
      echo ""
    fi

    sleep "$WATCH_INTERVAL"
  done
}

# Main
echo ""
echo -e "${BLUE}🎯 GymBro Auto-Checkpoint${NC}"
echo ""

if [ "$WATCH_MODE" = true ]; then
  watch_mode
else
  # Manual mode - commit immediately if changes exist
  if should_commit; then
    create_checkpoint
  else
    CHANGED_FILES=$(git diff --name-only lib/ 2>/dev/null | grep "\.dart$" | wc -l | xargs)
    LINES_CHANGED=$(git diff --stat lib/ 2>/dev/null | tail -1 | awk '{print $4+$6}' || echo "0")
    LINES_CHANGED=${LINES_CHANGED:-0}

    echo -e "${YELLOW}⚠️  No significant changes to commit${NC}"
    echo -e "${CYAN}   Current: ${CHANGED_FILES} files, ~${LINES_CHANGED} lines${NC}"
    echo -e "${CYAN}   Needed: ${THRESHOLD_FILES} files OR ${THRESHOLD_LINES} lines${NC}"
    echo ""
    echo -e "${BLUE}💡 Continue coding or use --watch mode to auto-commit${NC}"
  fi
fi

echo ""
