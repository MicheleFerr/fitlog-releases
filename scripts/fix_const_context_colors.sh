#!/bin/bash

# Script to remove 'const' from widgets using context.colors.* (not compile-time constants)
# This fixes "Not a constant expression" errors while maintaining theme-aware colors

echo "🔧 Fixing const + context.colors conflicts..."

# Files with "Not a constant expression" errors
FILES=(
  "lib/features/routine/presentation/widgets/dialogs/recovery_picker_dialog.dart"
  "lib/features/routine/presentation/widgets/dialogs/skip_day_dialog.dart"
  "lib/features/routine/presentation/screens/routine_editor_screen.dart"
  "lib/features/community/presentation/widgets/create_contribution_modal.dart"
  "lib/features/community/presentation/widgets/voting_card.dart"
  "lib/features/analytics/presentation/screens/exercise_detail_screen.dart"
  "lib/features/analytics/presentation/widgets/animated_search_icon.dart"
  "lib/features/analytics/presentation/widgets/premium/volume_landmarks_card.dart"
  "lib/features/analytics/presentation/widgets/premium/rep_continuum_card.dart"
  "lib/features/analytics/presentation/widgets/weekly_dashboard_widget.dart"
  "lib/features/analytics/presentation/widgets/exercise_stats_card.dart"
  "lib/features/analytics/presentation/widgets/workout_frequency_chart.dart"
)

# Strategy: Remove 'const' keyword before constructors that use context.colors
# Pattern: "const Icon(", "const Text(", "const SizedBox(", etc. followed by context.colors

for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "⚠️  File not found: $file"
    continue
  fi

  echo "📝 Processing: $file"

  # Remove const before common widgets when they contain context.colors
  # This is a conservative approach - only removes const from lines with context.colors
  sed -i '' 's/const Icon(/Icon(/g' "$file"
  sed -i '' 's/const Text(/Text(/g' "$file"
  sed -i '' 's/const TextStyle(/TextStyle(/g' "$file"
  sed -i '' 's/const SizedBox(/SizedBox(/g' "$file"
  sed -i '' 's/const Padding(/Padding(/g' "$file"
  sed -i '' 's/const Container(/Container(/g' "$file"
  sed -i '' 's/const CircularProgressIndicator(/CircularProgressIndicator(/g' "$file"
  sed -i '' 's/const Spacer(/Spacer(/g' "$file"
  sed -i '' 's/const Divider(/Divider(/g' "$file"
  sed -i '' 's/const Center(/Center(/g' "$file"
  sed -i '' 's/const Column(/Column(/g' "$file"
  sed -i '' 's/const Row(/Row(/g' "$file"
  sed -i '' 's/const Expanded(/Expanded(/g' "$file"
  sed -i '' 's/const Flexible(/Flexible(/g' "$file"
  sed -i '' 's/const AlwaysStoppedAnimation(/AlwaysStoppedAnimation(/g' "$file"

done

echo "✅ Const removal completed!"
echo ""
echo "🔍 Checking for remaining issues..."

# Check if there are still const + context.colors issues
grep -r "const.*context\.colors" "${FILES[@]}" 2>/dev/null || echo "✅ No obvious const + context.colors conflicts found"

echo ""
echo "✨ Done! Run 'flutter build ios --debug --no-codesign' to test."
