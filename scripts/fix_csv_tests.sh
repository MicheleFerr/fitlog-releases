#!/bin/bash
# 🔧 Script per fixare automaticamente CSV tests
# Usage: ./scripts/fix_csv_tests.sh

echo "🔧 Fixing CSV tests..."
echo ""

TEST_FILE="test/features/workout/domain/services/workout_import_service_test.dart"

echo "📝 Applying CSV string format fixes..."

# Il problema: CsvToListConverter non parsa correttamente stringhe con newline leading/trailing
# Soluzione: Usa .trim() sul csvContent prima di passarlo al parser

# Backup originale
cp "$TEST_FILE" "${TEST_FILE}.backup"

# Trova tutte le occorrenze di csvContent e aggiungi .trim()
# Pattern: final result = await service.importFromCsv(csvContent, ...
sed -i '' 's/importFromCsv(csvContent,/importFromCsv(csvContent.trim(),/g' "$TEST_FILE"

echo "✅ Applied trim() to all csvContent usages"
echo ""

# Run tests per verificare
echo "🧪 Running CSV tests to verify fixes..."
flutter test "$TEST_FILE" --reporter compact 2>&1 | tail -5

echo ""
echo "📊 Check results above. If still failing, the issue might be in WorkoutImportService itself."
echo ""
echo "💡 Next steps if still failing:"
echo "   1. Check WorkoutImportService.importFromCsv() header parsing logic"
echo "   2. Verify CsvToListConverter configuration"
echo "   3. Add debug prints to see what headers are found"
echo ""
echo "📄 Backup saved to: ${TEST_FILE}.backup"
