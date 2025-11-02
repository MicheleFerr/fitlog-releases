#!/usr/bin/env python3
"""
Fix remaining const violations with a more aggressive pattern.
This handles nested parentheses and complex multiline constructors.
"""

import re
from pathlib import Path

def remove_const_before_context_colors(content):
    """
    Remove const keyword from any constructor that contains context.colors,
    using a more aggressive pattern that handles complex nesting.
    """
    lines = content.split('\n')
    result_lines = []
    i = 0

    while i < len(lines):
        line = lines[i]

        # Check if line has 'const' followed by a constructor name
        const_match = re.match(r'^(\s*)const\s+([A-Z][a-zA-Z0-9<>]*)\s*\(', line)

        if const_match:
            # Found a const constructor, collect all lines until matching closing paren
            indent = const_match.group(1)
            constructor_name = const_match.group(2)

            # Collect the entire constructor call
            constructor_lines = [line]
            paren_count = line.count('(') - line.count(')')
            j = i + 1

            while j < len(lines) and paren_count > 0:
                constructor_lines.append(lines[j])
                paren_count += lines[j].count('(') - lines[j].count(')')
                j += 1

            # Check if any of these lines contain context.colors
            full_constructor = '\n'.join(constructor_lines)

            if 'context.colors' in full_constructor:
                # Remove the const keyword from the first line
                fixed_first_line = re.sub(r'^(\s*)const\s+', r'\1', constructor_lines[0])
                result_lines.append(fixed_first_line)
                result_lines.extend(constructor_lines[1:])
                i = j
            else:
                # No context.colors, keep as is
                result_lines.extend(constructor_lines)
                i = j
        else:
            # Not a const constructor line, keep as is
            result_lines.append(line)
            i += 1

    return '\n'.join(result_lines)

def fix_file(file_path):
    """Fix const violations in a file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    content = remove_const_before_context_colors(content)

    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    # Files that still have errors after the previous fix
    files = [
        "lib/features/admin/presentation/widgets/admin_quick_actions.dart",
        "lib/features/analytics/presentation/screens/exercise_detail_screen.dart",
        "lib/features/analytics/presentation/widgets/animated_search_icon.dart",
        "lib/features/analytics/presentation/widgets/enhanced_volume_progress_chart.dart",
        "lib/features/analytics/presentation/widgets/exercise_stats_card.dart",
        "lib/features/analytics/presentation/widgets/pr_timeline_widget.dart",
        "lib/features/analytics/presentation/widgets/workout_frequency_chart.dart",
        "lib/features/buddy_matching/presentation/widgets/enhanced/super_like_button.dart",
        "lib/features/buddy_matching/presentation/widgets/matches_preview_bar.dart",
        "lib/features/buddy_matching/presentation/widgets/swipeable_buddy_card.dart",
        "lib/features/community/presentation/widgets/voting_card.dart",
        "lib/features/exercise_database/presentation/widgets/exercise_sync_status_widget.dart",
        "lib/features/home/presentation/widgets/customizable_workout_card.dart",
        "lib/features/home/presentation/widgets/real_progress_stats_widget.dart",
        "lib/features/home/presentation/widgets/recent_workouts_widget.dart",
        "lib/features/home/presentation/widgets/streak_tracker_widget.dart",
        "lib/features/home/presentation/widgets/volume_details_modal.dart",
        "lib/features/home/presentation/widgets/weekly_distribution_modal.dart",
        "lib/features/premium/presentation/screens/premium_purchase_screen_v2.dart",
        "lib/features/premium/presentation/screens/premium_upgrade_screen.dart",
        "lib/features/smart_training/presentation/widgets/smart_templates_grid.dart",
        "lib/features/timer/presentation/screens/lockscreen_audio_test_screen.dart",
        "lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart",
        "lib/features/workout/presentation/widgets/community_contribution_modal.dart",
        "lib/features/workout/presentation/widgets/exercise_gif_fullscreen.dart",
        "lib/features/workout/presentation/widgets/warmup_progression_v2.dart",
        "test/features/workout/data/services/exercise_history_service_test.dart",
    ]

    project_root = Path.cwd()
    if project_root.name == 'ios':
        project_root = project_root.parent

    modified = 0
    total = 0

    print("Fixing remaining const violations...")
    print()

    for file_str in files:
        file_path = project_root / file_str
        if file_path.exists():
            total += 1
            if fix_file(file_path):
                modified += 1
                print(f"✓ {file_str}")

    print()
    print(f"✅ Modified {modified}/{total} files")
    print()
    print("Run 'flutter analyze' to verify")

if __name__ == "__main__":
    main()
