#!/bin/bash
# 🔍 Script per analizzare test falliti e categorizzarli
# Usage: ./scripts/analyze_failing_tests.sh

echo "🔍 Analyzing failing tests..."
echo ""

# Run tests and capture failures
flutter test --reporter expanded 2>&1 > /tmp/test_results.txt

# Count total failures
TOTAL_FAILURES=$(grep -c "\[E\]" /tmp/test_results.txt)
echo "📊 Total failing tests: $TOTAL_FAILURES"
echo ""

# Categorize by error type
echo "📋 Error Categories:"
echo ""

# Null safety errors
NULL_ERRORS=$(grep -B2 "\[E\]" /tmp/test_results.txt | grep -c "Null check operator")
echo "  ❌ Null Safety Errors: $NULL_ERRORS"

# Late initialization errors
LATE_ERRORS=$(grep -B2 "\[E\]" /tmp/test_results.txt | grep -c "LateInitializationError")
echo "  ❌ Late Init Errors: $LATE_ERRORS"

# Mock/Stub errors
MOCK_ERRORS=$(grep -B2 "\[E\]" /tmp/test_results.txt | grep -c "No stub was found")
echo "  ❌ Mock/Stub Errors: $MOCK_ERRORS"

# Type errors
TYPE_ERRORS=$(grep -B2 "\[E\]" /tmp/test_results.txt | grep -c "type.*is not a subtype")
echo "  ❌ Type Errors: $TYPE_ERRORS"

# Async errors
ASYNC_ERRORS=$(grep -B2 "\[E\]" /tmp/test_results.txt | grep -c "Bad state")
echo "  ❌ Async/State Errors: $ASYNC_ERRORS"

# CSV parsing errors
CSV_ERRORS=$(grep -B2 "\[E\]" /tmp/test_results.txt | grep -c "Missing required CSV columns")
echo "  ❌ CSV Parsing Errors: $CSV_ERRORS"

echo ""
echo "💡 Recommendations:"
echo ""

if [ $NULL_ERRORS -gt 0 ]; then
  echo "  1. Fix Null Safety: Add ? or ?? operators, use late keyword"
fi

if [ $LATE_ERRORS -gt 0 ]; then
  echo "  2. Fix Late Init: Initialize fields in setUp() or use late keyword properly"
fi

if [ $MOCK_ERRORS -gt 0 ]; then
  echo "  3. Fix Mocks: Add when().thenAnswer() for all mock methods called"
fi

if [ $CSV_ERRORS -gt 0 ]; then
  echo "  4. Fix CSV Tests: Review CSV string formatting and parser config"
fi

echo ""
echo "📄 Full report saved to: /tmp/test_results.txt"
echo ""
echo "🚀 To fix a category, run:"
echo "   ./scripts/fix_null_safety_tests.sh"
echo "   ./scripts/fix_mock_tests.sh"
echo "   ./scripts/fix_csv_tests.sh"
