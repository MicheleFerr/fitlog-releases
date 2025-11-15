#!/usr/bin/env bash

# taskmaster_plan.sh - CLI wrapper for task-master.dev API integration
# Part of task-master.dev integration - Fase 2
#
# Usage:
#   ./scripts/taskmaster_plan.sh "Implement analytics system"
#   ./scripts/taskmaster_plan.sh --help
#
# Requirements:
#   - curl (for API calls)
#   - jq (for JSON parsing)
#   - task-master.dev API key in ~/.taskmaster/api_key
#
# Output:
#   Plan saved to docs/plans/YYYY-MM-DD-{topic}-plan.md

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
API_KEY_FILE="$HOME/.taskmaster/api_key"
PLANS_DIR="$PROJECT_ROOT/docs/plans"
API_ENDPOINT="https://api.task-master.dev/v1/breakdown" # Placeholder URL

# Functions
usage() {
    cat <<EOF
taskmaster_plan.sh - Generate task plans via task-master.dev API

Usage:
    $0 "<description>"
    $0 --help
    $0 --setup        # Configure API key

Examples:
    $0 "Implement analytics system with charts"
    $0 "Refactor workout timer for background execution"

Options:
    -h, --help        Show this help message
    -s, --setup       Run API key setup
    -v, --verbose     Verbose output
    --api-key KEY     Use specific API key (override config)

Environment:
    TASKMASTER_API_KEY    Override API key file

Files:
    ~/.taskmaster/api_key    API key storage
    docs/plans/              Generated plan documents

Status: FASE 2 - CLI Automation
EOF
    exit 0
}

setup_api_key() {
    echo -e "${BLUE}🔧 Task-Master.dev API Key Setup${NC}\n"

    mkdir -p "$(dirname "$API_KEY_FILE")"

    echo "Enter your task-master.dev API key:"
    echo "(Get it from: https://www.task-master.dev/api-keys)"
    echo ""
    read -r -s api_key

    if [[ -z "$api_key" ]]; then
        echo -e "${RED}❌ No API key provided${NC}"
        exit 1
    fi

    echo "$api_key" > "$API_KEY_FILE"
    chmod 600 "$API_KEY_FILE"

    echo -e "\n${GREEN}✅ API key saved to $API_KEY_FILE${NC}"
    echo -e "${YELLOW}⚠️  Keep this file secure (permissions: 600)${NC}"
    exit 0
}

check_dependencies() {
    local missing=()

    command -v curl >/dev/null 2>&1 || missing+=("curl")
    command -v jq >/dev/null 2>&1 || missing+=("jq")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing dependencies: ${missing[*]}${NC}"
        echo ""
        echo "Install with:"
        echo "  brew install ${missing[*]}"  # macOS
        echo "  apt-get install ${missing[*]}" # Linux
        exit 1
    fi
}

load_api_key() {
    if [[ -n "${TASKMASTER_API_KEY:-}" ]]; then
        echo "$TASKMASTER_API_KEY"
        return
    fi

    if [[ ! -f "$API_KEY_FILE" ]]; then
        echo -e "${RED}❌ API key not found${NC}"
        echo ""
        echo "Run setup first:"
        echo "  $0 --setup"
        exit 1
    fi

    cat "$API_KEY_FILE"
}

call_taskmaster_api() {
    local description="$1"
    local api_key="$2"

    echo -e "${BLUE}🌐 Calling task-master.dev API...${NC}"

    # Prepare enriched prompt (Flutter/Clean Architecture context)
    local prompt
    prompt=$(cat <<EOF
Break down the following Flutter/Dart development task into
manageable, atomic tasks following Clean Architecture pattern:

Task: $description

Context:
- Framework: Flutter
- Architecture: Clean Architecture (Domain/Data/Presentation)
- State Management: Riverpod 2.x
- Platforms: iOS 14+, Android 8+
- Key requirements: Localization (EN/IT), Theme support (dark/light)

Output format:
- Task list with category grouping
- Estimated time per task (15min - 1.5h max)
- Dependencies between tasks
- Verification criteria per task

Provide 8-15 tasks total.
EOF
)

    # API call (adapt to actual task-master.dev API format)
    local response
    response=$(curl -s -X POST "$API_ENDPOINT" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        -d @- <<EOF
{
    "prompt": $(echo "$prompt" | jq -Rs .),
    "context": {
        "framework": "Flutter",
        "architecture": "Clean Architecture"
    }
}
EOF
) || {
        echo -e "${RED}❌ API call failed${NC}"
        echo "Check your internet connection and API key"
        exit 1
    }

    echo "$response"
}

parse_api_response() {
    local response="$1"

    # Parse JSON response (adapt to actual API format)
    # Example: extract tasks array
    echo "$response" | jq -r '.tasks // .breakdown // .plan' || {
        echo -e "${YELLOW}⚠️  Failed to parse API response${NC}"
        echo "$response"
        exit 1
    }
}

generate_plan_filename() {
    local description="$1"

    # Convert description to slug
    local slug
    slug=$(echo "$description" | tr '[:upper:]' '[:lower:]' | \
           sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | \
           sed 's/^-//' | sed 's/-$//' | cut -c1-50)

    local date
    date=$(date +%Y-%m-%d)

    echo "$date-$slug-plan.md"
}

enrich_tasks_with_flutter() {
    local tasks="$1"

    # Add Flutter-specific tasks if missing
    # (localization, theme compliance, flutter analyze, tests)

    echo "$tasks" # For now, passthrough

    # TODO in Fase 2 enhancement:
    # - Check if "localization" task present
    # - Check if "theme" task present
    # - Add file paths (lib/features/{feature}/)
    # - Add verification criteria
}

create_plan_document() {
    local description="$1"
    local tasks="$2"
    local filename="$3"

    local filepath="$PLANS_DIR/$filename"

    mkdir -p "$PLANS_DIR"

    # Read current context (Flutter version, etc.)
    local flutter_version
    flutter_version=$(grep "version:" "$PROJECT_ROOT/pubspec.yaml" | head -1 | sed 's/.*version: //' | tr -d '"' || echo "unknown")

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M')

    # Count tasks
    local task_count
    task_count=$(echo "$tasks" | grep -c "^- \[ \]" || echo "unknown")

    # Use template from design document
    cat > "$filepath" <<EOF
# $(echo "$description" | sed 's/^./\U&/') - Task Plan

**Generated**: $timestamp
**Source**: task-master.dev (API CLI)
**Complexity Score**: MEDIUM
**Reason**: Auto-generated via CLI
**Total Tasks**: $task_count
**Estimated Time**: ~$(( task_count / 2 ))h (auto-estimate)
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: $flutter_version
- Key Packages: riverpod, firebase_core
- Target Platforms: iOS 14+, Android 8+
- Related PRs/Issues: None
- Parent Milestone: None

---

## 📋 Original Request

> $description

---

## 🎯 Task Breakdown

$tasks

---

## 📊 Implementation Order

**TODO**: Analyze task dependencies and order

---

## ✅ Completion Criteria

- [ ] All tasks marked complete in TodoWrite
- [ ] \`flutter analyze\` passes (0 errors)
- [ ] Localization complete (EN + IT)
- [ ] Theme compliance tested (dark/light)

---

**Generated by**: taskmaster_plan.sh (Fase 2 CLI)
**Plan Version**: 1.0
EOF

    echo "$filepath"
}

main() {
    # Parse arguments
    local description=""
    local verbose=false
    local custom_api_key=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -s|--setup)
                setup_api_key
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --api-key)
                custom_api_key="$2"
                shift 2
                ;;
            -*)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                usage
                ;;
            *)
                description="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$description" ]]; then
        echo -e "${RED}❌ No description provided${NC}\n"
        usage
    fi

    # Check dependencies
    check_dependencies

    # Load API key
    local api_key
    if [[ -n "$custom_api_key" ]]; then
        api_key="$custom_api_key"
    else
        api_key=$(load_api_key)
    fi

    echo -e "${BLUE}🎯 Task-Master.dev Plan Generator${NC}\n"
    echo -e "Request: ${GREEN}$description${NC}\n"

    # Call API
    local response
    response=$(call_taskmaster_api "$description" "$api_key")

    if [[ "$verbose" == true ]]; then
        echo -e "\n${YELLOW}API Response:${NC}"
        echo "$response" | jq '.'
        echo ""
    fi

    # Parse response
    echo -e "${BLUE}📝 Parsing API response...${NC}"
    local tasks
    tasks=$(parse_api_response "$response")

    # Enrich with Flutter specifics
    tasks=$(enrich_tasks_with_flutter "$tasks")

    # Generate filename
    local filename
    filename=$(generate_plan_filename "$description")

    # Create plan document
    echo -e "${BLUE}💾 Creating plan document...${NC}"
    local filepath
    filepath=$(create_plan_document "$description" "$tasks" "$filename")

    echo -e "\n${GREEN}✅ Plan created successfully!${NC}\n"
    echo -e "File: ${BLUE}$filepath${NC}"
    echo -e "Tasks: ${YELLOW}$task_count${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Review plan: cat $filepath"
    echo "2. Create TodoWrite from plan"
    echo "3. Start implementation"
    echo ""
    echo -e "Or use: ${BLUE}git plan \"$description\"${NC} (if git alias configured)"
}

main "$@"
