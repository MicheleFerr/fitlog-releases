import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Floating mini-bar showing active workout status
/// Appears above bottom navigation when workout is active and user is not on workout screen
class WorkoutMiniBar extends ConsumerStatefulWidget {
  const WorkoutMiniBar({
    required this.workout,
    super.key,
  });

  final Workout workout;

  @override
  ConsumerState<WorkoutMiniBar> createState() => _WorkoutMiniBarState();
}

class _WorkoutMiniBarState extends ConsumerState<WorkoutMiniBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Timer? _timerUpdateTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start entrance animation
    _animationController.forward();

    // Update timer display every second
    _timerUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timerUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final isPaused = workout.status == WorkoutStatus.paused;
    final duration = workout.duration ?? Duration.zero;
    final progress = workout.progressPercentage;

    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: () => _navigateToWorkout(context),
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(alpha: 0.15),
                blurRadius: AppSpacing.sm,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      // Workout icon
                      SemanticIcon(
                        icon: AppIcons.workout,
                        semanticLabel: context.l10n.workout,
                        size: AppIconSize.medium,
                        color: isPaused
                            ? context.colors.onSurfaceVariant
                            : context.colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Workout name
                      Expanded(
                        child: Text(
                          workout.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Status icon
                      SemanticIcon(
                        icon: isPaused ? AppIcons.pause : AppIcons.playArrow,
                        semanticLabel: isPaused
                            ? context.l10n.workoutPaused
                            : context.l10n.workoutActive,
                        size: AppIconSize.small,
                        color: isPaused
                            ? context.colors.warning
                            : context.colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),

                      // Timer
                      Text(
                        _formatDuration(duration),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isPaused
                              ? context.colors.warning
                              : context.colors.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Play/Pause button
                      _buildPlayPauseButton(context, isPaused),
                    ],
                  ),
                ),
              ),

              // Progress bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppSpacing.md),
                  ),
                  color: context.colors.surfaceContainerLow,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppSpacing.md),
                      ),
                      color: isPaused
                          ? context.colors.warning
                          : context.colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, bool isPaused) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _togglePause(isPaused),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.primary.withValues(alpha: 0.1),
          ),
          child: SemanticIcon(
            icon: isPaused ? AppIcons.playArrow : AppIcons.pause,
            semanticLabel: isPaused
                ? context.l10n.resumeWorkout
                : context.l10n.pauseWorkout,
            size: AppIconSize.medium,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }

  void _navigateToWorkout(BuildContext context) {
    HapticFeedback.lightImpact();
    context.go('/workout');
  }

  void _togglePause(bool isPaused) {
    HapticFeedback.selectionClick();
    final notifier = ref.read(currentWorkoutProvider.notifier);
    if (isPaused) {
      notifier.resumeWorkout();
    } else {
      notifier.pauseWorkout();
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
