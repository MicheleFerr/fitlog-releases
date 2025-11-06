#!/bin/bash

# Fix final 11 files with "Not a constant expression" errors
# Removes const from ALL widget patterns that use context.colors

FILES=(
  "lib/features/analytics/presentation/screens/exercise_detail_screen.dart"
  "lib/features/analytics/presentation/widgets/weekly_dashboard_widget.dart"
  "lib/features/community/presentation/widgets/animated_xp_bar.dart"
  "lib/features/community/presentation/widgets/create_contribution_modal.dart"
  "lib/features/community/presentation/widgets/voting_card.dart"
  "lib/features/home/presentation/widgets/feedback_history_modal.dart"
  "lib/features/notifications/presentation/widgets/notification_hub.dart"
  "lib/features/routine/presentation/widgets/dialogs/recovery_picker_dialog.dart"
  "lib/features/workout/presentation/widgets/community_contribution_modal.dart"
  "lib/features/workout/presentation/widgets/contribution_success_dialog.dart"
  "lib/features/workout/presentation/widgets/dropset_execution_modal.dart"
)

echo "🔧 Fixing final const errors in ${#FILES[@]} files..."

for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "⚠️  File not found: $file"
    continue
  fi

  echo "Processing: $file"

  # Remove const from common widget constructors
  sed -i '' 's/const Icon(/Icon(/g' "$file"
  sed -i '' 's/const Text(/Text(/g' "$file"
  sed -i '' 's/const TextStyle(/TextStyle(/g' "$file"
  sed -i '' 's/const Container(/Container(/g' "$file"
  sed -i '' 's/const SizedBox(/SizedBox(/g' "$file"
  sed -i '' 's/const Padding(/Padding(/g' "$file"
  sed -i '' 's/const Center(/Center(/g' "$file"
  sed -i '' 's/const Column(/Column(/g' "$file"
  sed -i '' 's/const Row(/Row(/g' "$file"
  sed -i '' 's/const Stack(/Stack(/g' "$file"
  sed -i '' 's/const Expanded(/Expanded(/g' "$file"
  sed -i '' 's/const Flexible(/Flexible(/g' "$file"

  # Remove const from layout widgets
  sed -i '' 's/const EdgeInsets\./EdgeInsets./g' "$file"
  sed -i '' 's/const BorderRadius\./BorderRadius./g' "$file"
  sed -i '' 's/const Radius\./Radius./g' "$file"

  # Remove const from Material widgets
  sed -i '' 's/const Card(/Card(/g' "$file"
  sed -i '' 's/const ListTile(/ListTile(/g' "$file"
  sed -i '' 's/const Divider(/Divider(/g' "$file"
  sed -i '' 's/const CircularProgressIndicator(/CircularProgressIndicator(/g' "$file"
  sed -i '' 's/const LinearProgressIndicator(/LinearProgressIndicator(/g' "$file"

  # Remove const from gradient and decoration classes
  sed -i '' 's/const LinearGradient(/LinearGradient(/g' "$file"
  sed -i '' 's/const RadialGradient(/RadialGradient(/g' "$file"
  sed -i '' 's/const BoxDecoration(/BoxDecoration(/g' "$file"
  sed -i '' 's/const ShapeDecoration(/ShapeDecoration(/g' "$file"

  # Remove const from SnackBar and other feedback widgets
  sed -i '' 's/const SnackBar(/SnackBar(/g' "$file"
  sed -i '' 's/const Dialog(/Dialog(/g' "$file"
  sed -i '' 's/const AlertDialog(/AlertDialog(/g' "$file"

  # Remove const from AlwaysStoppedAnimation (specific to some files)
  sed -i '' 's/const AlwaysStoppedAnimation</AlwaysStoppedAnimation</g' "$file"

  echo "✓ Fixed: $file"
done

echo ""
echo "✅ All ${#FILES[@]} files processed!"
echo ""
echo "🧪 Running flutter analyze to check..."
flutter analyze --no-pub

echo ""
echo "📦 Build test..."
flutter build ios --debug --no-codesign 2>&1 | grep -E "(Error:|warnings?|errors?)" | head -20
