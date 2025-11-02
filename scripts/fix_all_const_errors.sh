#!/bin/bash

# Comprehensive fix for all "Not a constant expression" errors

echo "🔧 Phase 3: Comprehensive const removal from ALL affected files..."

# Extended list of ALL files with const + context.colors errors
ALL_FILES=(
  "lib/features/analytics/presentation/screens/exercise_detail_screen.dart"
  "lib/features/workout/presentation/widgets/exercise_list_item.dart"
  "lib/features/community/presentation/widgets/voting_card.dart"
  "lib/features/community/presentation/widgets/create_contribution_modal.dart"
  "lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart"
  "lib/features/analytics/presentation/widgets/weekly_dashboard_widget.dart"
  "lib/features/routine/presentation/widgets/dialogs/recovery_picker_dialog.dart"
  "lib/features/exercise_database/presentation/widgets/warmup_info_dialog.dart"
  "lib/features/workout/presentation/widgets/exercise_gif_fullscreen.dart"
  "lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart"
  "lib/features/workout/presentation/widgets/community_advice_modal.dart"
)

for file in "${ALL_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "⚠️  File not found: $file"
    continue
  fi

  echo "📝 Processing: $file"

  # Remove const from ALL common widget constructors
  sed -i '' 's/const Icon(/Icon(/g' "$file"
  sed -i '' 's/const Text(/Text(/g' "$file"
  sed -i '' 's/const TextStyle(/TextStyle(/g' "$file"
  sed -i '' 's/const SizedBox(/SizedBox(/g' "$file"
  sed -i '' 's/const Padding(/Padding(/g' "$file"
  sed -i '' 's/const Container(/Container(/g' "$file"
  sed -i '' 's/const CircularProgressIndicator(/CircularProgressIndicator(/g' "$file"
  sed -i '' 's/const LinearProgressIndicator(/LinearProgressIndicator(/g' "$file"
  sed -i '' 's/const Spacer(/Spacer(/g' "$file"
  sed -i '' 's/const Divider(/Divider(/g' "$file"
  sed -i '' 's/const Center(/Center(/g' "$file"
  sed -i '' 's/const Column(/Column(/g' "$file"
  sed -i '' 's/const Row(/Row(/g' "$file"
  sed -i '' 's/const Expanded(/Expanded(/g' "$file"
  sed -i '' 's/const Flexible(/Flexible(/g' "$file"
  sed -i '' 's/const Card(/Card(/g' "$file"
  sed -i '' 's/const Chip(/Chip(/g' "$file"
  sed -i '' 's/const Badge(/Badge(/g' "$file"
  sed -i '' 's/const ListTile(/ListTile(/g' "$file"
  sed -i '' 's/const EdgeInsets(/EdgeInsets(/g' "$file"
done

echo "✅ Const removal phase 3 completed!"

# Fix additional undefined getters
echo ""
echo "🔧 Fixing additional undefined color getters..."

# onSurface54 (was missed in previous script)
find lib -name "*.dart" -exec sed -i '' 's/context\.colors\.onSurface54/context.colors.onSurface.withValues(alpha: 0.54)/g' {} \;

# onSurface87
find lib -name "*.dart" -exec sed -i '' 's/context\.colors\.onSurface87/context.colors.onSurface.withValues(alpha: 0.87)/g' {} \;

echo "✅ Additional getter fixes completed!"
