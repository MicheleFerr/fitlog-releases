import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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
///
/// Features:
/// - Smooth entrance animation
/// - Drag gesture with elastic spring return
/// - Limited downward drag (respects bottom nav margin)
/// - Haptic feedback on interactions
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
    with TickerProviderStateMixin {
  // Entrance animation
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation;

  // Drag animation
  late AnimationController _dragController;
  double _dragOffset = 0.0;

  // Timer for updating duration display
  Timer? _timerUpdateTimer;

  // Drag limits
  static const double _maxDragUp = -80.0; // Max pixels to drag up (negative = up)
  static const double _maxDragDown = 4.0; // Max pixels to drag down (limited by bottom nav)

  // Spring physics for smooth return
  static const SpringDescription _springDescription = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 25.0,
  );

  @override
  void initState() {
    super.initState();

    // Entrance animation controller
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    // Drag animation controller (for spring return)
    _dragController = AnimationController(vsync: this);
    _dragController.addListener(_onDragAnimationUpdate);

    // Start entrance animation
    _entranceController.forward();

    // Update timer display every second
    _timerUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _dragController.dispose();
    _timerUpdateTimer?.cancel();
    super.dispose();
  }

  void _onDragAnimationUpdate() {
    setState(() {
      _dragOffset = _dragController.value;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Update drag offset with rubber-band effect in both directions
      final newOffset = _dragOffset + details.delta.dy;

      if (newOffset < 0) {
        // Dragging UP - moderate rubber band effect
        final resistance = 1 - (newOffset.abs() / (_maxDragUp.abs() * 2)).clamp(0.0, 0.8);
        _dragOffset = (_dragOffset + details.delta.dy * resistance).clamp(_maxDragUp, _maxDragDown * 3);
      } else {
        // Dragging DOWN - high resistance rubber band effect (smooth but limited)
        // Exponential resistance: gets harder the further you drag
        const resistanceFactor = 0.15; // Very high resistance (lower = more resistance)
        final resistance = resistanceFactor / (1 + (newOffset / _maxDragDown));
        _dragOffset = (_dragOffset + details.delta.dy * resistance).clamp(_maxDragUp, _maxDragDown * 3);
      }
    });

    // Light haptic on significant drag
    if (_dragOffset.abs() > 15 && _dragOffset.abs() % 15 < 2) {
      HapticFeedback.selectionClick();
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // Animate back to original position with spring physics
    final simulation = SpringSimulation(
      _springDescription,
      _dragOffset,
      0.0, // Target position (back to original)
      details.velocity.pixelsPerSecond.dy / 1000, // Initial velocity
    );

    _dragController.animateWith(simulation);

    // Haptic feedback when releasing
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final isPaused = workout.status == WorkoutStatus.paused;
    final duration = workout.duration ?? Duration.zero;
    final progress = workout.progressPercentage;

    return SlideTransition(
      position: _slideAnimation,
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: GestureDetector(
          onTap: () => _navigateToWorkout(context),
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
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
                // Drag handle indicator
                _buildDragHandle(context),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        // Workout icon with subtle animation based on drag
                        Transform.scale(
                          scale: 1.0 + (_dragOffset.abs() / 200).clamp(0.0, 0.1),
                          child: SemanticIcon(
                            icon: AppIcons.workout,
                            semanticLabel: context.l10n.workout,
                            size: AppIconSize.medium,
                            color: isPaused
                                ? context.colors.onSurfaceVariant
                                : context.colors.primary,
                          ),
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
      ),
    );
  }

  /// Small drag handle indicator at the top of the bar
  Widget _buildDragHandle(BuildContext context) {
    // Opacity changes based on drag amount for visual feedback
    final handleOpacity = (0.3 + (_dragOffset.abs() / 100).clamp(0.0, 0.4));

    return Container(
      width: 32,
      height: 4,
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: context.colors.onSurfaceVariant.withValues(alpha: handleOpacity),
        borderRadius: BorderRadius.circular(2),
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
