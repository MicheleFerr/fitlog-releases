#!/bin/bash

# Fix surfaceVariant deprecation (Flutter 3.18+)
# Replace deprecated surfaceVariant with surfaceContainerHighest

cd "$(dirname "$0")/.."

# All files with surfaceVariant deprecation warnings (30 files)
FILES=(
  "lib/features/admin/presentation/widgets/correction_review_card.dart"
  "lib/features/analytics/presentation/screens/exercise_progress_screen.dart"
  "lib/features/analytics/presentation/widgets/enhanced_chart_widgets.dart"
  "lib/features/analytics/presentation/widgets/enhanced_volume_progress_chart.dart"
  "lib/features/analytics/presentation/widgets/exercise_stats_card.dart"
  "lib/features/analytics/presentation/widgets/muscle_balance_widget.dart"
  "lib/features/analytics/presentation/widgets/pr_timeline_widget.dart"
  "lib/features/analytics/presentation/widgets/premium/volume_landmarks_card.dart"
  "lib/features/analytics/presentation/widgets/workout_frequency_chart.dart"
  "lib/features/buddy_matching/presentation/widgets/swipeable_buddy_card.dart"
  "lib/features/buddy_matching/presentation/widgets/workout_goals_chips.dart"
  "lib/features/community/presentation/widgets/community_pulse_card.dart"
  "lib/features/exercise_database/presentation/widgets/exercise_customization_screen.dart"
  "lib/features/home/presentation/widgets/level_info_modal.dart"
  "lib/features/home/presentation/widgets/streak_tracker_widget.dart"
  "lib/features/notifications/presentation/widgets/notification_hub.dart"
  "lib/features/routine/presentation/widgets/editor_steps/custom_pattern_builder.dart"
  "lib/features/smart_training/presentation/widgets/smart_suggestions_widget.dart"
  "lib/features/workout_templates/presentation/widgets/template_card.dart"
  "lib/features/workout/presentation/widgets/add_exercise_modal.dart"
  "lib/features/workout/presentation/widgets/auto_adjustment_modal.dart"
  "lib/features/workout/presentation/widgets/barbell_selector_widget.dart"
  "lib/features/workout/presentation/widgets/create_template_modal.dart"
  "lib/features/workout/presentation/widgets/dropset_weight_picker_modal.dart"
  "lib/features/workout/presentation/widgets/exercise_name_autocomplete.dart"
  "lib/features/workout/presentation/widgets/exercise_replacement_dialog.dart"
  "lib/features/workout/presentation/widgets/rest_time_picker_modal.dart"
  "lib/features/workout/presentation/widgets/superset_exercises_tooltip.dart"
  "lib/features/workout/presentation/widgets/template_cards/template_quick_start_card.dart"
  "lib/features/workout/presentation/widgets/workout_customization_modal_v2.dart"
)

echo "🔧 Fixing surfaceVariant deprecation in ${#FILES[@]} files..."
echo ""

modified_count=0

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    # Replace .surfaceVariant with .surfaceContainerHighest
    # Also replace colorScheme.surfaceVariant
    if sed -i '' \
      -e 's/\.surfaceVariant/.surfaceContainerHighest/g' \
      -e 's/colorScheme\.surfaceContainerHighest/colorScheme.surfaceContainerHighest/g' \
      "$file"; then
      modified_count=$((modified_count + 1))
      echo "✓ $file"
    fi
  else
    echo "✗ Not found: $file"
  fi
done

echo ""
echo "✅ Done! Modified $modified_count/${#FILES[@]} files."
echo ""
echo "📝 Changes made:"
echo "   .surfaceVariant → .surfaceContainerHighest"
echo "   colorScheme.surfaceVariant → colorScheme.surfaceContainerHighest"
echo ""
echo "Next: Run 'flutter analyze' to verify no more surfaceVariant warnings"
