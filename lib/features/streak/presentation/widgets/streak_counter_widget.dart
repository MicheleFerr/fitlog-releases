import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/streak_milestone.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Widget that displays workout streak counter with fire emoji and progress
///
/// Features:
/// - Fire emoji (🔥) for active streaks
/// - Current streak number with large display
/// - Progress bar to next milestone (7, 30, 100 days)
/// - Longest streak stat
/// - Total workout days stat
/// - Loading and error states
class StreakCounterWidget extends ConsumerWidget {
  const StreakCounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(currentStreakProvider);

    return streakAsync.when(
      data: (streak) => _StreakContent(streak: streak),
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.error,
              semanticLabel: context.l10n.errorLoadingData,
              size: AppIconSize.xlarge,
              color: context.colors.error,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.errorLoadingData,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakContent extends StatelessWidget {

  const _StreakContent({required this.streak});
  final dynamic streak;

  @override
  Widget build(BuildContext context) {
    final currentStreak = streak.currentStreak as int;
    final longestStreak = streak.longestStreak as int;
    final totalWorkoutDays = streak.totalWorkoutDays as int;
    final isActive = streak.isActive as bool;

    // Calculate progress to next milestone
    final progress = StreakMilestone.getProgressToNext(currentStreak);
    final nextMilestone = StreakMilestone.getNextMilestone(currentStreak);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fire emoji + current streak
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isActive) ...[
                  Text(
                    '🔥',
                    style: context.textTheme.displayMedium,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  '$currentStreak',
                  style: context.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.dayStreak,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Progress to next milestone
            if (nextMilestone != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.nextMilestone,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        nextMilestone.badge,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: context.colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.primary,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentStreak / ${nextMilestone.days} ${context.l10n.days}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: context.l10n.longestStreak,
                  value: '$longestStreak',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: context.colors.outlineVariant,
                ),
                _StatItem(
                  label: context.l10n.totalDays,
                  value: '$totalWorkoutDays',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {

  const _StatItem({
    required this.label,
    required this.value,
  });
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
