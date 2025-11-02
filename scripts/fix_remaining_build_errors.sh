#!/bin/bash

# Fix remaining specific build errors after const removal

echo "🔧 Fixing remaining build errors..."

# 1. Fix undefined getters (onSurface26, onSurface54, primaryGrey)
echo "1️⃣ Fixing undefined color getters..."

# onSurface26 -> onSurface with alpha
sed -i '' 's/context\.colors\.onSurface26/context.colors.onSurface.withValues(alpha: 0.26)/g' \
  lib/features/workout/presentation/widgets/superset_sequential_execution_sheet.dart

# onSurface54 -> onSurface with alpha
sed -i '' 's/context\.colors\.onSurface54/context.colors.onSurface.withValues(alpha: 0.54)/g' \
  lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart

# primaryGrey -> surfaceVariant (semantic equivalent)
sed -i '' 's/context\.colors\.primaryGrey/context.colors.surfaceVariant/g' \
  lib/features/workout/presentation/widgets/barbell_selector_widget.dart

# 2. Fix Color[] operator (not supported - use MaterialColor or hardcode shade)
echo "2️⃣ Fixing Color[] operator issues..."

# success[700] -> success with darker shade
sed -i '' 's/context\.colors\.success\[700\]/context.colors.success.withValues(red: context.colors.success.r * 0.7, green: context.colors.success.g * 0.7, blue: context.colors.success.b * 0.7)/g' \
  lib/features/routine/presentation/widgets/calendar_view.dart

# primary[700] -> primary with darker shade
sed -i '' 's/context\.colors\.primary\[700\]/context.colors.primary.withValues(red: context.colors.primary.r * 0.7, green: context.colors.primary.g * 0.7, blue: context.colors.primary.b * 0.7)/g' \
  lib/features/routine/presentation/widgets/calendar_view.dart

# secondary[800] -> secondary with darker shade
sed -i '' 's/context\.colors\.secondary\[800\]/context.colors.secondary.withValues(red: context.colors.secondary.r * 0.6, green: context.colors.secondary.g * 0.6, blue: context.colors.secondary.b * 0.6)/g' \
  lib/features/routine/presentation/widgets/dialogs/skip_day_dialog.dart

# surfaceVariant[300] -> surfaceVariant with lighter shade
sed -i '' 's/context\.colors\.surfaceVariant\[300\]/context.colors.surfaceVariant.withValues(alpha: 0.3)/g' \
  lib/features/analytics/presentation/widgets/exercise_stats_card.dart

# 3. Fix surfaceContainerHighest (correct property name)
echo "3️⃣ Fixing surfaceContainerHighest..."
sed -i '' 's/context\.colors\.surfaceContainerHighest/Theme.of(context).colorScheme.surfaceContainerHighest/g' \
  lib/features/analytics/presentation/widgets/workout_frequency_chart.dart

echo "✅ All specific fixes applied!"
echo ""
echo "🧪 Test with: flutter build ios --debug --no-codesign"
