#!/bin/bash

# 🔍 Verifica Dipendenze Template Screens
# Verifica che le schermate template inutilizzate possano essere rimosse in sicurezza
#
# Usage: ./scripts/verify_unused_template_screens.sh

set -e

echo "🔍 Verifying Template Screens Dependencies..."
echo "============================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

# Function to check dependencies
check_dependency() {
    local screen_name=$1
    local file_to_exclude=$2
    local description=$3

    echo ""
    echo "📋 Checking: $description"
    echo "   Screen: $screen_name"
    echo "   Excluded: $file_to_exclude"

    # Search for imports or usage
    results=$(grep -r "$screen_name" lib/ --include="*.dart" 2>/dev/null | grep -v "$file_to_exclude" || true)

    if [ -z "$results" ]; then
        echo -e "   ${GREEN}✅ SAFE TO REMOVE${NC} - No dependencies found"
        return 0
    else
        echo -e "   ${RED}❌ DEPENDENCIES FOUND${NC}:"
        echo "$results" | head -5
        echo ""
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        return 1
    fi
}

# Function to check router
check_router() {
    local screen_name=$1

    echo ""
    echo "📋 Checking Router for: $screen_name"

    results=$(grep -r "$screen_name" lib/app/app.dart 2>/dev/null || true)

    if [ -z "$results" ]; then
        echo -e "   ${GREEN}✅ NOT IN ROUTER${NC} - Safe to remove"
        return 0
    else
        echo -e "   ${YELLOW}⚠️ FOUND IN ROUTER${NC}:"
        echo "$results"
        echo ""
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        return 1
    fi
}

echo ""
echo "🔍 STEP 1: Checking TemplatesHomeScreen..."
echo "==========================================="
check_dependency "TemplatesHomeScreen" "templates_home_screen.dart" "Templates Home Screen (workout_templates feature)"
check_router "TemplatesHomeScreen"

echo ""
echo "🔍 STEP 2: Checking WorkoutTemplateScreen (singular)..."
echo "========================================================"
check_dependency "WorkoutTemplateScreen[^s]" "workout_template_screen.dart" "Workout Template Screen (singular)"
check_router "WorkoutTemplateScreen"

echo ""
echo "🔍 STEP 3: Checking TemplateExportScreen..."
echo "============================================"
check_dependency "TemplateExportScreen" "template_export_screen.dart" "Template Export Screen"
check_router "TemplateExportScreen"

echo ""
echo "🔍 STEP 4: Checking workout_templates feature imports..."
echo "=========================================================="
echo "📋 Checking imports of workout_templates feature"

results=$(grep -r "from 'package:gymbro_flutter_new/features/workout_templates/" lib/ --include="*.dart" 2>/dev/null | grep -v "lib/features/workout_templates/" || true)

if [ -z "$results" ]; then
    echo -e "   ${GREEN}✅ NO EXTERNAL IMPORTS${NC} - Feature is isolated"
else
    echo -e "   ${RED}❌ EXTERNAL IMPORTS FOUND${NC}:"
    echo "$results" | head -10
    echo ""
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

echo ""
echo "🔍 STEP 5: Checking backup files..."
echo "====================================="
echo "📋 Finding .backup and .bak files"

backup_files=$(find lib/ -name "*.backup" -o -name "*.bak" 2>/dev/null || true)

if [ -z "$backup_files" ]; then
    echo -e "   ${GREEN}✅ NO BACKUP FILES${NC} - Already clean"
else
    echo -e "   ${YELLOW}⚠️ BACKUP FILES FOUND${NC}:"
    echo "$backup_files"
    echo ""
fi

echo ""
echo "========================================="
echo "🎯 FINAL RESULT"
echo "========================================="

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CHECKS PASSED${NC}"
    echo ""
    echo "Safe to remove:"
    echo "  1. lib/features/workout_templates/ (entire folder)"
    echo "  2. lib/features/workout/presentation/screens/workout_template_screen.dart"
    echo "  3. All .backup and .bak files"
    echo ""
    echo "Next steps:"
    echo "  1. Archive useful code in docs/archived/"
    echo "  2. Run: rm -rf lib/features/workout_templates/"
    echo "  3. Run: rm lib/features/workout/presentation/screens/workout_template_screen.dart"
    echo "  4. Run: find lib/ -name '*.backup' -delete && find lib/ -name '*.bak' -delete"
    echo "  5. Run: flutter analyze"
    echo "  6. Test app manually"
    echo "  7. Commit changes"
    echo ""
    exit 0
else
    echo -e "${RED}❌ ISSUES FOUND: $ISSUES_FOUND${NC}"
    echo ""
    echo "⚠️ CANNOT SAFELY REMOVE"
    echo ""
    echo "Please review the dependencies above before removing."
    echo "Some files may still be imported or used."
    echo ""
    exit 1
fi
