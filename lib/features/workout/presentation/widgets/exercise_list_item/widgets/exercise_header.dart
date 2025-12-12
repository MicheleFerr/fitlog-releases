/// Exercise Header Widget
///
/// Displays the exercise name, type icon, badges (APRE, timer, countdown),
/// and provides navigation to exercise details.
///
/// Part of ExerciseListItem refactoring (split per sezione).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_gif_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Header widget for ExerciseListItem
///
/// Displays:
/// - Exercise type icon (GIF for single, icons for superset/dropset/restpause)
/// - Exercise name (tappable for details)
/// - Badge row (APRE, timer indicator, countdown)
class ExerciseHeader extends ConsumerWidget {
  const ExerciseHeader({
    super.key,
    required this.exercise,
    required this.config,
    required this.isExpanded,
    required this.countdown,
    required this.onShowAutoAdjustmentModal,
    required this.onShowTimerDurationSheet,
    required this.onShowTutInfoDialog,
  });

  final Exercise exercise;
  final AppConfig config;
  final bool isExpanded;
  final int countdown;
  final VoidCallback onShowAutoAdjustmentModal;
  final VoidCallback onShowTimerDurationSheet;
  final VoidCallback onShowTutInfoDialog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildExerciseTypeIcon(context, ref),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name - tappable for details
              _buildExerciseNameRow(context),
              const SizedBox(height: 6),
              // Badge row (APRE, Timer, Countdown) - Horizontally scrollable
              _buildBadgeRow(context, ref),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the exercise type icon (GIF or static icon)
  Widget _buildExerciseTypeIcon(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;

    // For single exercises, use animated GIF
    if (exercise.type == ExerciseType.single) {
      final gifUrlAsync = ref.watch(exerciseGifUrlProvider(exercise.name));

      return gifUrlAsync.when(
        data: (gifUrl) => RepaintBoundary(
          child: ExerciseGifWidget(
            gifUrl: gifUrl,
            exerciseName: exercise.name,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            iconColor: colorScheme.primary,
          ),
        ),
        loading: () => Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ),
        ),
        error: (_, __) => _buildStaticIcon(
          context,
          AppIcons.workout,
          colorScheme.primary,
        ),
      );
    }

    // For other exercise types, use static icons
    final (icon, color) = switch (exercise.type) {
      ExerciseType.superset => (AppIcons.repeat, colorScheme.secondary),
      ExerciseType.dropset => (AppIcons.trendDown, colorScheme.tertiary),
      ExerciseType.restPause => (AppIcons.pauseCircle, colorScheme.error),
      ExerciseType.single => (AppIcons.workout, colorScheme.primary),
    };

    return _buildStaticIcon(context, icon, color);
  }

  Widget _buildStaticIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: SemanticIcon(
        icon: icon,
        semanticLabel: exercise.type.name,
        color: color,
        size: AppIconSize.small,
      ),
    );
  }

  /// Builds the exercise name row with info icon
  Widget _buildExerciseNameRow(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          'workout-exercise-detail',
          pathParameters: {
            'exerciseName': Uri.encodeComponent(exercise.name),
          },
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                exercise.name,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SemanticIcon(
              icon: AppIcons.info,
              semanticLabel: 'Information',
              size: AppIconSize.small,
              color: context.colors.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the badge row with timer and countdown indicators
  Widget _buildBadgeRow(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Timer indicator (if TUT/duration configured)
          if (exercise.tut != null) ...[
            _buildTimerBadge(context),
            const SizedBox(width: 8),
          ],

          // Auto-collapse countdown indicator
          if (countdown > 0 && isExpanded) _buildCountdownBadge(context),
        ],
      ),
    );
  }

  Widget _buildTimerBadge(BuildContext context) {
    return InkWell(
      onTap: onShowTimerDurationSheet,
      onLongPress: onShowTutInfoDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.secondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.colors.secondary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.timer,
              semanticLabel: 'Timer',
              size: AppIconSize.tiny,
              color: context.colors.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              exercise.tut ?? '',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.tertiary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.tertiary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: AppIcons.unfoldLess,
            semanticLabel: 'Auto-collapse',
            size: AppIconSize.tiny,
            color: context.colors.tertiary,
          ),
          const SizedBox(width: 4),
          Text(
            '${countdown}s',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
