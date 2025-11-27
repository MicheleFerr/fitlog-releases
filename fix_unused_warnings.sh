#!/bin/bash

# Fix unused imports, variables, and fields
# Generated script for systematic cleanup

set -e

echo "🔧 Fixing unused imports..."

# Unused imports (39 total)
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/l10n\/generated\/app_localizations.dart.;$/' lib/debug/exercise_history_test_widget.dart
perl -i -ne 'print unless /^import .package:flutter\/foundation.dart.;$/' lib/features/analytics/domain/services/analytics_calculation_service.dart
perl -i -ne 'print unless /^import .package:cloud_firestore\/cloud_firestore.dart.;$/' lib/features/analytics/domain/usecases/migrate_analytics_from_workouts.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/features\/analytics\/domain\/services\/one_rm_calculator.dart.;$/' lib/features/analytics/presentation/providers/analytics_provider.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/analytics/presentation/widgets/exercise_stats_card.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/analytics/presentation/widgets/tier1_fab.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/auth/presentation/login_screen.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/features\/exercise_database\/data\/services\/exercise_sync_service.dart.;$/' lib/features/exercise_database/presentation/widgets/exercise_sync_status_widget.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/widgets\/semantic_icon.dart.;$/' lib/features/home/presentation/home_screen_optimized.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/widgets\/semantic_icon.dart.;$/' lib/features/home/presentation/home_screen_performance.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/extensions\/build_context_extensions.dart.;$/' lib/features/home/providers/achievement_xp_provider.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/home/providers/achievement_xp_provider.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/features\/workout\/presentation\/providers\/workout_provider.dart.;$/' lib/features/settings/presentation/widgets/premium_sync_card.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/smart_training/presentation/widgets/smart_suggestions_widget.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/features\/workout\/data\/repositories\/exercise_activity_repository.dart.;$/' lib/features/workout/presentation/providers/exercise_history_provider.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/features\/progress\/presentation\/providers\/progress_provider.dart.;$/' lib/features/workout/presentation/providers/workout_provider.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/features\/workout\/presentation\/providers\/firebase_template_provider.dart.;$/' lib/features/workout/presentation/screens/edit_template_screen.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/screens/workout_templates_screen.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/auto_adjustment_modal.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/community_contribution_modal.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/dropset_weight_picker_modal.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/features\/exercise_database\/presentation\/widgets\/exercise_card_feedback.dart.;$/' lib/features/workout/presentation/widgets/exercise_list_item.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/exercise_onboarding_overlay.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/premium_workout_gestures.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/rep_preset_chips.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/rest_time_picker_modal.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/scrollable_exercise_chips.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/template_cards/template_quick_start_card.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout/presentation/widgets/template_onboarding_overlay.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/features/workout_templates/presentation/widgets/template_quota_indicator.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/extensions\/build_context_extensions.dart.;$/' lib/main_debug_appcheck.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/main_debug_appcheck.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/shared/presentation/services/snackbar_service.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/extensions\/build_context_extensions.dart.;$/' lib/shared/presentation/widgets/animated_icon_swap.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/shared/presentation/widgets/animated_icon_swap.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/shared/presentation/widgets/draggable_tutorial_overlay.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/shared/presentation/widgets/error_boundary.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/theme\/color_scheme_extensions.dart.;$/' lib/shared/presentation/widgets/pressable_card.dart
perl -i -ne 'print unless /^import .package:gymbro_flutter_new\/shared\/presentation\/extensions\/build_context_extensions.dart.;$/' lib/shared/utils/accessibility_utils.dart

echo "✅ Fixed 39 unused imports"
echo ""
echo "🔧 Now manually fixing unused variables and fields using Read/Edit tools..."
