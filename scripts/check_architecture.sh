#!/bin/bash
# FitLog Architecture Compliance Checker
# Run this to check current architecture status

set -e

PROJECT_ROOT="/Users/michele/gymbro_flutter_new"
cd "$PROJECT_ROOT"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          FitLog Architecture Compliance Report                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    local score=$1
    local target=$2
    local name=$3

    if [ "$score" -ge "$target" ]; then
        echo -e "${GREEN}✅ $name: $score (target: $target)${NC}"
    elif [ "$score" -ge $((target / 2)) ]; then
        echo -e "${YELLOW}⚠️  $name: $score (target: $target)${NC}"
    else
        echo -e "${RED}❌ $name: $score (target: $target)${NC}"
    fi
}

# 1. Domain Layer Purity Check
echo "1️⃣  Domain Layer Purity (Target: 0 violations)"
echo "─────────────────────────────────────────────────"

domain_presentation_violations=$(grep -r "import.*presentation" lib/features/*/domain --include="*.dart" 2>/dev/null | grep -v "test\|.g.dart" | wc -l | tr -d ' ')
domain_data_violations=$(grep -r "import.*data/models\|import.*data/repositories\|import.*data/datasources" lib/features/*/domain --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')

total_domain_violations=$((domain_presentation_violations + domain_data_violations))

if [ "$total_domain_violations" -eq 0 ]; then
    echo -e "${GREEN}✅ Domain layer is PURE (0 violations)${NC}"
else
    echo -e "${RED}❌ Domain layer has $total_domain_violations violations${NC}"
    echo "   - Presentation imports: $domain_presentation_violations"
    echo "   - Data layer imports: $domain_data_violations"
fi
echo ""

# 2. BaseHybridRepository Adoption
echo "2️⃣  BaseHybridRepository Pattern (Target: 30+ repositories)"
echo "─────────────────────────────────────────────────"

base_hybrid_count=$(grep -r "extends.*BaseHybridRepository\|extends.*OptimizedBaseHybridRepository" lib/features/*/data/repositories --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
total_repos=$(find lib/features/*/data/repositories -name "*repository*.dart" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$total_repos" -gt 0 ]; then
    percentage=$((base_hybrid_count * 100 / total_repos))
    print_status "$base_hybrid_count" 30 "BaseHybridRepository usage"
    echo "   Coverage: $percentage% ($base_hybrid_count/$total_repos repositories)"
else
    echo -e "${YELLOW}⚠️  No repositories found${NC}"
fi
echo ""

# 3. DataSource Pattern Adoption
echo "3️⃣  DataSource Pattern (Target: 25+ features)"
echo "─────────────────────────────────────────────────"

datasource_count=$(find lib/features/*/data/datasources -type d 2>/dev/null | wc -l | tr -d ' ')
total_features=$(ls -d lib/features/*/ 2>/dev/null | wc -l | tr -d ' ')

if [ "$total_features" -gt 0 ]; then
    percentage=$((datasource_count * 100 / total_features))
    print_status "$datasource_count" 25 "Features with DataSource layer"
    echo "   Coverage: $percentage% ($datasource_count/$total_features features)"
else
    echo -e "${YELLOW}⚠️  No features found${NC}"
fi
echo ""

# 4. Data Layer Purity
echo "4️⃣  Data Layer Purity (Target: 0 violations)"
echo "─────────────────────────────────────────────────"

data_presentation_violations=$(find lib/features/*/data -name "*.dart" -type f -exec grep -l "import.*presentation" {} \; 2>/dev/null | wc -l | tr -d ' ')

if [ "$data_presentation_violations" -eq 0 ]; then
    echo -e "${GREEN}✅ Data layer is PURE (0 violations)${NC}"
else
    echo -e "${RED}❌ Data layer has $data_presentation_violations files importing presentation${NC}"
fi
echo ""

# 5. Feature Structure Completeness
echo "5️⃣  Feature Structure Completeness"
echo "─────────────────────────────────────────────────"

complete_features=0
incomplete_features=0

for feature_dir in lib/features/*/; do
    feature_name=$(basename "$feature_dir")
    has_domain=false
    has_data=false
    has_presentation=false

    [ -d "${feature_dir}domain" ] && has_domain=true
    [ -d "${feature_dir}data" ] && has_data=true
    [ -d "${feature_dir}presentation" ] && has_presentation=true

    if $has_domain && $has_data && $has_presentation; then
        ((complete_features++))
    else
        ((incomplete_features++))
    fi
done

total_arch_features=$((complete_features + incomplete_features))
if [ "$total_arch_features" -gt 0 ]; then
    percentage=$((complete_features * 100 / total_arch_features))
    print_status "$complete_features" 30 "Complete feature structures"
    echo "   Coverage: $percentage% ($complete_features/$total_arch_features features)"
    echo "   Incomplete: $incomplete_features features"
else
    echo -e "${YELLOW}⚠️  No features found${NC}"
fi
echo ""

# 6. Direct Firestore Usage
echo "6️⃣  Direct Firestore Usage (Target: <5 repositories)"
echo "─────────────────────────────────────────────────"

direct_firestore=$(grep -r "final FirebaseFirestore" lib/features/*/data/repositories --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')

if [ "$direct_firestore" -lt 5 ]; then
    echo -e "${GREEN}✅ Low direct Firestore usage ($direct_firestore repositories)${NC}"
elif [ "$direct_firestore" -lt 15 ]; then
    echo -e "${YELLOW}⚠️  Moderate direct Firestore usage ($direct_firestore repositories)${NC}"
else
    echo -e "${RED}❌ High direct Firestore usage ($direct_firestore repositories)${NC}"
fi
echo ""

# Summary Score
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      COMPLIANCE SUMMARY                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"

total_checks=6
passed_checks=0

[ "$total_domain_violations" -eq 0 ] && ((passed_checks++))
[ "$base_hybrid_count" -ge 30 ] && ((passed_checks++))
[ "$datasource_count" -ge 25 ] && ((passed_checks++))
[ "$data_presentation_violations" -eq 0 ] && ((passed_checks++))
[ "$complete_features" -ge 30 ] && ((passed_checks++))
[ "$direct_firestore" -lt 5 ] && ((passed_checks++))

overall_percentage=$((passed_checks * 100 / total_checks))

echo ""
echo "Overall Compliance: $overall_percentage% ($passed_checks/$total_checks checks passing)"
echo ""

if [ "$overall_percentage" -ge 80 ]; then
    echo -e "${GREEN}🎉 EXCELLENT - Architecture is in great shape!${NC}"
elif [ "$overall_percentage" -ge 60 ]; then
    echo -e "${YELLOW}⚠️  MODERATE - Some improvements needed${NC}"
else
    echo -e "${RED}❌ CRITICAL - Significant refactoring required${NC}"
fi

echo ""
echo "📊 For detailed report, see:"
echo "   - ARCHITECTURE_AUDIT_REPORT.md (full analysis)"
echo "   - ARCHITECTURE_VIOLATIONS.txt (line-by-line fixes)"
echo "   - docs/architecture/CURRENT_VS_IDEAL.md (visual guide)"
echo ""
