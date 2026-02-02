/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_merge/presentation/widgets
/// 🎯 Feature: exercise_merge
/// 🔧 Type: widget
///
/// Bottom sheet di conferma per merge esercizi
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/presentation/providers/exercise_merge_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Bottom sheet di conferma merge
///
/// Mostra preview delle modifiche che verranno applicate:
/// - Numero sessioni migrate
/// - Cambiamento PR
/// - Muscoli target
class MergeConfirmationBottomSheet extends ConsumerWidget {
  const MergeConfirmationBottomSheet({
    super.key,
    required this.sourceExerciseName,
    required this.targetExercise,
    required this.sessionCount,
    required this.personalRecord,
    required this.onConfirm,
  });

  final String sourceExerciseName;
  final Exercise targetExercise;
  final int sessionCount;
  final double? personalRecord;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colors;
    final textTheme = context.textTheme;
    final mergeProgress = ref.watch(mergeExecutionProvider);
    final isLoading = mergeProgress.state == MergeState.loading;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.merge,
                      color: colorScheme.onPrimaryContainer,
                      size: AppIconSize.medium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.confirmMerge,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.confirmMergeDescription,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Merge visualization
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Source exercise
                    _ExerciseRow(
                      label: l10n.fromExercise,
                      exerciseName: sourceExerciseName,
                      isSource: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Arrow
                    Icon(
                      AppIcons.arrowDown,
                      color: colorScheme.primary,
                      size: AppIconSize.medium,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Target exercise
                    _ExerciseRow(
                      label: l10n.toExercise,
                      exerciseName: targetExercise.nome,
                      isSource: false,
                      muscleGroups: targetExercise.focus,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Stats preview
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _StatRow(
                      icon: AppIcons.history,
                      label: l10n.sessionsToMerge,
                      value: '$sessionCount',
                    ),
                    if (personalRecord != null && personalRecord! > 0) ...[
                      const Divider(height: 24),
                      _StatRow(
                        icon: AppIcons.trophy,
                        label: l10n.personalRecord,
                        value: '${personalRecord!.toStringAsFixed(1)} kg',
                        valueColor: colorScheme.tertiary,
                      ),
                    ],
                    if (targetExercise.muscoliSecondari.isNotEmpty) ...[
                      const Divider(height: 24),
                      _StatRow(
                        icon: AppIcons.accessibility,
                        label: l10n.secondaryMuscles,
                        value: targetExercise.muscoliSecondari.join(', '),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Warning
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.warning,
                      color: colorScheme.error,
                      size: AppIconSize.small,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.mergeWarning,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Actions or Progress
              if (isLoading) ...[
                // Progress indicator
                _MergeProgressIndicator(
                  progress: mergeProgress.progress,
                  currentStep: mergeProgress.currentStep,
                ),
              ] else ...[
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: onConfirm,
                        icon: const Icon(AppIcons.check),
                        label: Text(l10n.confirmMergeButton),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.label,
    required this.exerciseName,
    required this.isSource,
    this.muscleGroups,
  });

  final String label;
  final String exerciseName;
  final bool isSource;
  final List<String>? muscleGroups;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSource ? colorScheme.error : colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                exerciseName,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: isSource ? TextDecoration.lineThrough : null,
                  color: isSource
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
              if (muscleGroups != null && muscleGroups!.isNotEmpty)
                Text(
                  muscleGroups!.join(', '),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSize.small,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Widget per mostrare il progresso del merge con animazione fluida
class _MergeProgressIndicator extends StatefulWidget {
  const _MergeProgressIndicator({
    required this.progress,
    required this.currentStep,
  });

  final double progress;
  final String currentStep;

  @override
  State<_MergeProgressIndicator> createState() =>
      _MergeProgressIndicatorState();
}

class _MergeProgressIndicatorState extends State<_MergeProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_MergeProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _currentProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        _currentProgress = _progressAnimation.value;
        final progressPercent = (_currentProgress * 100).round();

        return Column(
          children: [
            // Percentage text with animation
            Text(
              '$progressPercent%',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Animated progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _currentProgress,
                minHeight: 12,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Current step text with fade animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                widget.currentStep,
                key: ValueKey(widget.currentStep),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}
