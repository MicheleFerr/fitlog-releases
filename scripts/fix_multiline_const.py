#!/usr/bin/env python3
"""
Fix multiline const violations with context.colors usage.
This script removes 'const' keywords from widget constructors that use context.colors,
even when the constructor spans multiple lines.
"""

import re
import sys
from pathlib import Path

def fix_const_in_file(file_path):
    """Remove const from widget constructors that use context.colors."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # Pattern: const WidgetName( ... context.colors ... )
    # This regex handles multiline constructors
    # Match: const + whitespace + CapitalizedName + ( + anything + context.colors + anything + )
    pattern = r'\bconst\s+([A-Z][a-zA-Z0-9]*)\s*\(([^{}]*?context\.colors[^{}]*?)\)'

    # Replace: remove the 'const' keyword
    content = re.sub(pattern, r'\1(\2)', content, flags=re.DOTALL)

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    # All files with "Invalid constant value" errors
    files = [
        "lib/features/admin/presentation/screens/exercise_review_screen.dart",
        "lib/features/admin/presentation/widgets/admin_quick_actions.dart",
        "lib/features/analytics/presentation/screens/exercise_detail_screen.dart",
        "lib/features/analytics/presentation/widgets/animated_search_icon.dart",
        "lib/features/analytics/presentation/widgets/enhanced_progress_indicators.dart",
        "lib/features/analytics/presentation/widgets/enhanced_volume_progress_chart.dart",
        "lib/features/analytics/presentation/widgets/exercise_stats_card.dart",
        "lib/features/analytics/presentation/widgets/muscle_balance_widget.dart",
        "lib/features/analytics/presentation/widgets/pr_timeline_widget.dart",
        "lib/features/analytics/presentation/widgets/premium/rep_continuum_card.dart",
        "lib/features/analytics/presentation/widgets/premium/volume_landmarks_card.dart",
        "lib/features/analytics/presentation/widgets/weekly_dashboard_widget.dart",
        "lib/features/analytics/presentation/widgets/workout_frequency_chart.dart",
        "lib/features/buddy_matching/presentation/screens/buddy_matching_screen.dart",
        "lib/features/buddy_matching/presentation/widgets/enhanced/super_like_button.dart",
        "lib/features/buddy_matching/presentation/widgets/matches_preview_bar.dart",
        "lib/features/buddy_matching/presentation/widgets/swipeable_buddy_card.dart",
        "lib/features/community/presentation/widgets/animated_xp_bar.dart",
        "lib/features/community/presentation/widgets/community_pulse_card.dart",
        "lib/features/community/presentation/widgets/create_contribution_modal.dart",
        "lib/features/community/presentation/widgets/radial_contribution_menu.dart",
        "lib/features/community/presentation/widgets/voting_card.dart",
        "lib/features/community/presentation/widgets/xp_display_widget.dart",
        "lib/features/exercise_database/presentation/widgets/exercise_sync_status_widget.dart",
        "lib/features/exercise_database/presentation/widgets/warmup_info_dialog.dart",
        "lib/features/home/presentation/widgets/customizable_workout_card.dart",
        "lib/features/home/presentation/widgets/enhanced_progress_stats_widget.dart",
        "lib/features/home/presentation/widgets/feedback_history_modal.dart",
        "lib/features/home/presentation/widgets/optimized_unified_stats_card.dart",
        "lib/features/home/presentation/widgets/real_progress_stats_widget.dart",
        "lib/features/home/presentation/widgets/recent_workouts_widget.dart",
        "lib/features/home/presentation/widgets/streak_tracker_widget.dart",
        "lib/features/home/presentation/widgets/volume_details_modal.dart",
        "lib/features/home/presentation/widgets/volume_display_widget.dart",
        "lib/features/home/presentation/widgets/weekly_distribution_modal.dart",
        "lib/features/home/presentation/widgets/weekly_goals_widget.dart",
        "lib/features/notifications/presentation/widgets/notification_hub.dart",
        "lib/features/premium/presentation/screens/premium_purchase_screen_v2.dart",
        "lib/features/premium/presentation/screens/premium_upgrade_screen.dart",
        "lib/features/routine/presentation/screens/routine_editor_screen.dart",
        "lib/features/routine/presentation/widgets/dialogs/recovery_picker_dialog.dart",
        "lib/features/routine/presentation/widgets/dialogs/skip_day_dialog.dart",
        "lib/features/smart_training/presentation/widgets/smart_templates_grid.dart",
        "lib/features/timer/presentation/screens/lockscreen_audio_test_screen.dart",
        "lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart",
        "lib/features/workout_templates/presentation/widgets/template_card.dart",
        "lib/features/workout/presentation/widgets/community_advice_modal.dart",
        "lib/features/workout/presentation/widgets/community_contribution_modal.dart",
        "lib/features/workout/presentation/widgets/contribution_success_dialog.dart",
        "lib/features/workout/presentation/widgets/dropset_execution_modal.dart",
        "lib/features/workout/presentation/widgets/exercise_gif_fullscreen.dart",
        "lib/features/workout/presentation/widgets/warmup_progression_v2.dart",
        "test/features/workout/data/services/exercise_history_service_test.dart",
    ]

    project_root = Path.cwd()
    if project_root.name == 'ios':
        project_root = project_root.parent

    modified_count = 0
    total_count = 0

    print(f"Fixing multiline const violations in {len(files)} files...")
    print()

    for file_path_str in files:
        file_path = project_root / file_path_str
        if file_path.exists():
            total_count += 1
            if fix_const_in_file(file_path):
                modified_count += 1
                print(f"✓ Modified: {file_path_str}")
            else:
                print(f"  Skipped: {file_path_str} (no changes)")
        else:
            print(f"✗ Not found: {file_path_str}")

    print()
    print(f"✅ Done! Modified {modified_count}/{total_count} files.")
    print()
    print("Next steps:")
    print("1. Run 'flutter analyze' to check for remaining errors")
    print("2. Fix Color operator [] errors manually (6 instances)")
    print("3. Retry iOS build")

if __name__ == "__main__":
    main()
