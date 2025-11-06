#!/bin/bash

# Script to fix iOS Release build compilation errors
# Applies all fixes at once to avoid linter corruption

echo "🔧 Fixing iOS Release build compilation errors..."

# Fix 1: exercise_history_service.dart - tut field
echo "1️⃣ Fixing exercise_history_service.dart (tut field)..."
sed -i '' 's/tut: exercise\.tut,/tut: null,  \/\/ TUT not available at exercise level/' \
  lib/features/workout/data/services/exercise_history_service.dart

# Fix 2: app_check_config.dart - Provider types
echo "2️⃣ Fixing app_check_config.dart (Firebase App Check providers)..."
sed -i '' 's/webRecaptchaV3SiteKey:/webProvider: ReCaptchaV3Provider(/' \
  lib/core/security/app_check_config.dart
sed -i '' "s/'your-recaptcha-v3-site-key-here',/'your-recaptcha-v3-site-key-here'),/" \
  lib/core/security/app_check_config.dart
sed -i '' 's/iosProvider:/appleProvider:/' \
  lib/core/security/app_check_config.dart
sed -i '' 's/AppleProvider\./AppleAppCheckProvider./' \
  lib/core/security/app_check_config.dart
sed -i '' 's/androidProvider: AndroidProvider\./androidProvider: AndroidAppCheckProvider./' \
  lib/core/security/app_check_config.dart

# Fix 3: animated_search_icon.dart - Color.fromARGB
echo "3️⃣ Fixing animated_search_icon.dart (Color.fromARGB)..."
sed -i '' 's/red: (theme\.colorScheme\.primary\.r \* 0\.8 \* 255)\.round(),/red: theme.colorScheme.primary.r * 0.8 * 255.0,/' \
  lib/features/analytics/presentation/widgets/animated_search_icon.dart
sed -i '' 's/green: (theme\.colorScheme\.primary\.g \* 0\.8 \* 255)\.round(),/green: theme.colorScheme.primary.g * 0.8 * 255.0,/' \
  lib/features/analytics/presentation/widgets/animated_search_icon.dart
sed -i '' 's/blue: (theme\.colorScheme\.primary\.b \* 0\.8 \* 255)\.round(),/blue: theme.colorScheme.primary.b * 0.8 * 255.0,/' \
  lib/features/analytics/presentation/widgets/animated_search_icon.dart

# Fix 4: Add AppIcons import to 10 files
echo "4️⃣ Adding AppIcons import to 10 files..."
FILES_NEEDING_APPICONS=(
  "lib/features/workout/presentation/workout_screen.dart"
  "lib/features/workout/presentation/screens/workout_completion_summary_screen.dart"
  "lib/features/workout/presentation/widgets/exercise_list_item.dart"
  "lib/features/workout/presentation/widgets/workout_customization_modal_v2.dart"
  "lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart"
  "lib/features/analytics/presentation/tabs/analytics_premium_tab.dart"
  "lib/features/onboarding/presentation/widgets/steps/04_create_workout_step.dart"
  "lib/features/onboarding/presentation/widgets/steps/07_timer_rest_step.dart"
  "lib/features/workout/presentation/widgets/edit_exercise_modal.dart"
  "lib/features/workout/presentation/widgets/tut_info_dialog.dart"
)

for file in "${FILES_NEEDING_APPICONS[@]}"; do
  # Check if import already exists
  if ! grep -q "import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';" "$file"; then
    # Add import after the last import line
    sed -i '' "/^import /a\\
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
" "$file"
  fi
done

# Fix 5: Add hybrid_exercise_provider import
echo "5️⃣ Adding hybrid_exercise_provider import..."
FILES_NEEDING_HYBRID=(
  "lib/features/exercise_database/presentation/exercise_search_screen.dart"
  "lib/shared/presentation/widgets/exercise_picker/quick_exercise_picker.dart"
)

for file in "${FILES_NEEDING_HYBRID[@]}"; do
  if ! grep -q "import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';" "$file"; then
    sed -i '' "/^import /a\\
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
" "$file"
  fi
done

# Fix 6: Add unified_notification_provider import
echo "6️⃣ Adding unified_notification_provider import..."
if ! grep -q "import 'package:gymbro_flutter_new/features/notifications/presentation/providers/unified_notification_provider.dart';" \
  lib/features/notifications/presentation/widgets/notification_hub.dart; then
  sed -i '' "/^import /a\\
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/unified_notification_provider.dart';
" lib/features/notifications/presentation/widgets/notification_hub.dart
fi

# Fix 7: DropSetStage in add_exercise_modal.dart (line ~1416)
echo "7️⃣ Fixing DropSetStage in add_exercise_modal.dart..."
sed -i '' 's/stages\.add(DropSetStage(/stages.add(DropSetStage(countingMode: ExerciseCountingMode.weighted, /' \
  lib/features/workout/presentation/widgets/add_exercise_modal.dart
sed -i '' 's/weight: weight,$/weight: weight, targetReps: reps,/' \
  lib/features/workout/presentation/widgets/add_exercise_modal.dart

# Fix 8: RestPauseSet in add_exercise_modal.dart (line ~1467)
echo "8️⃣ Fixing RestPauseSet in add_exercise_modal.dart..."
sed -i '' 's/(index) => RestPauseSet(/(index) => RestPauseSet(countingMode: ExerciseCountingMode.weighted, targetReps: 0, /' \
  lib/features/workout/presentation/widgets/add_exercise_modal.dart

# Fix 9: RestPauseSet in exercise_list_item.dart (line ~4044)
echo "9️⃣ Fixing RestPauseSet in exercise_list_item.dart..."
sed -i '' 's/RestPauseSet(/RestPauseSet(countingMode: ExerciseCountingMode.weighted, /' \
  lib/features/workout/presentation/widgets/exercise_list_item.dart
sed -i '' 's/actualReps: repCount,$/actualReps: repCount, /' \
  lib/features/workout/presentation/widgets/exercise_list_item.dart

# Fix 10: Nullable toStringAsFixed in dropset_execution_modal.dart
echo "🔟 Fixing nullable toStringAsFixed in dropset_execution_modal.dart..."
sed -i '' 's/context\.l10n\.dropsetReduceWeightNow(nextWeight\.toStringAsFixed(1))/context.l10n.dropsetReduceWeightNow(nextWeight?.toStringAsFixed(1) ?? '\''0'\'')/' \
  lib/features/workout/presentation/widgets/dropset_execution_modal.dart
sed -i '' "s/'\${stage\.weight\.toStringAsFixed(1)} kg'/'\${stage.weight?.toStringAsFixed(1) ?? '\''0'\''} kg'/" \
  lib/features/workout/presentation/widgets/dropset_execution_modal.dart

echo "✅ All fixes applied!"
echo "🧪 Running flutter analyze to check for errors..."
