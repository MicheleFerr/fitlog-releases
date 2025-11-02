#!/bin/bash

# Fix const violations with context.colors usage
# This script removes 'const' keyword from contexts where context.colors is used

cd "$(dirname "$0")/.."

# List of files with const violations (from build errors)
FILES=(
  "lib/features/analytics/presentation/screens/exercise_detail_screen.dart"
  "lib/features/notifications/presentation/widgets/notification_hub.dart"
  "lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart"
  "lib/features/analytics/presentation/widgets/animated_search_icon.dart"
  "lib/features/community/presentation/widgets/voting_card.dart"
  "lib/features/community/presentation/widgets/create_contribution_modal.dart"
  "lib/features/routine/presentation/screens/routine_editor_screen.dart"
  "lib/features/home/presentation/widgets/feedback_history_modal.dart"
  "lib/features/workout/presentation/widgets/dropset_execution_modal.dart"
  "lib/features/workout/presentation/widgets/community_contribution_modal.dart"
  "lib/features/workout/presentation/widgets/community_advice_modal.dart"
  "lib/features/workout/presentation/widgets/exercise_gif_fullscreen.dart"
  "lib/features/analytics/presentation/widgets/workout_frequency_chart.dart"
  "lib/features/analytics/presentation/widgets/exercise_stats_card.dart"
  "lib/features/analytics/presentation/widgets/weekly_dashboard_widget.dart"
  "lib/features/analytics/presentation/widgets/premium/rep_continuum_card.dart"
  "lib/features/analytics/presentation/widgets/premium/volume_landmarks_card.dart"
  "lib/features/routine/presentation/widgets/calendar_view.dart"
  "lib/features/routine/presentation/widgets/dialogs/skip_day_dialog.dart"
  "lib/features/routine/presentation/widgets/dialogs/recovery_picker_dialog.dart"
  "lib/features/workout/presentation/widgets/contribution_success_dialog.dart"
  "lib/features/exercise_database/presentation/widgets/warmup_info_dialog.dart"
  "lib/features/community/presentation/widgets/animated_xp_bar.dart"
)

echo "Fixing const violations in ${#FILES[@]} files..."

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Processing: $file"

    # Pattern 1: const [ ... context.colors ... ]
    sed -i '' 's/const \[\(.*context\.colors.*\)\]/[\1]/g' "$file"

    # Pattern 2: const TextStyle(color: context.colors.xxx)
    sed -i '' 's/const TextStyle(\(.*context\.colors.*\))/TextStyle(\1)/g' "$file"

    # Pattern 3: const AlwaysStoppedAnimation<Color>(context.colors.xxx)
    sed -i '' 's/const AlwaysStoppedAnimation<Color>(\(.*context\.colors.*\))/AlwaysStoppedAnimation<Color>(\1)/g' "$file"

    # Pattern 4: Remove const from any constructor with context.colors
    sed -i '' 's/const \([A-Z][a-zA-Z0-9]*\)(\(.*context\.colors.*\))/\1(\2)/g' "$file"

  else
    echo "File not found: $file"
  fi
done

echo "Done! Please run 'flutter analyze' to verify."
