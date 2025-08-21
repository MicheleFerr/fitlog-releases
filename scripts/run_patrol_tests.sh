#!/bin/bash

# Script to run Patrol tests for GymBro
# This script sets up the environment and runs patrol tests

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Add patrol to PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Check if patrol is installed
if ! command -v patrol &> /dev/null; then
    echo -e "${YELLOW}Patrol CLI not found. Installing...${NC}"
    dart pub global activate patrol_cli
fi

echo -e "${GREEN}🧪 GymBro Patrol Tests${NC}"
echo "========================"

# Function to run a specific test
run_test() {
    local test_name=$1
    local test_file=$2
    
    echo -e "\n${YELLOW}Running: $test_name${NC}"
    echo "------------------------"
    
    if patrol test --target "$test_file"; then
        echo -e "${GREEN}✅ $test_name passed${NC}"
    else
        echo -e "${RED}❌ $test_name failed${NC}"
        return 1
    fi
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    # No arguments - run all tests
    echo -e "${YELLOW}Running all Patrol tests...${NC}\n"
    
    # Run each test suite
    run_test "Live Activity Tests" "integration_test/tests/live_activity_test.dart"
    run_test "Background Timer Tests" "integration_test/tests/background_timer_test.dart"
    run_test "Permission Tests" "integration_test/tests/permission_test.dart"
    run_test "E2E Workflow Tests" "integration_test/tests/workout_flow_e2e_test.dart"
    
elif [ "$1" == "live" ]; then
    run_test "Live Activity Tests" "integration_test/tests/live_activity_test.dart"
    
elif [ "$1" == "background" ]; then
    run_test "Background Timer Tests" "integration_test/tests/background_timer_test.dart"
    
elif [ "$1" == "permissions" ]; then
    run_test "Permission Tests" "integration_test/tests/permission_test.dart"
    
elif [ "$1" == "e2e" ]; then
    run_test "E2E Workflow Tests" "integration_test/tests/workout_flow_e2e_test.dart"
    
elif [ "$1" == "help" ]; then
    echo "Usage: ./scripts/run_patrol_tests.sh [option]"
    echo ""
    echo "Options:"
    echo "  (no option)   Run all tests"
    echo "  live          Run Live Activity tests only"
    echo "  background    Run Background Timer tests only"
    echo "  permissions   Run Permission tests only"
    echo "  e2e           Run E2E Workflow tests only"
    echo "  help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./scripts/run_patrol_tests.sh"
    echo "  ./scripts/run_patrol_tests.sh live"
    echo "  ./scripts/run_patrol_tests.sh e2e"
    
else
    echo -e "${RED}Unknown option: $1${NC}"
    echo "Use './scripts/run_patrol_tests.sh help' for usage information"
    exit 1
fi

echo -e "\n${GREEN}Test run completed!${NC}"