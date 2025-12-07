import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
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
/// - Infinite rubber-band drag in both directions (never blocks)
/// - Natural spring physics for return animation
/// - Horizontal swipe gestures:
///   - Swipe left→right: Save workout (green circle + check icon)
///   - Swipe right→left: Discard workout (red circle + trash icon)
/// - Haptic feedback on interactions
/// - No background overlay during swipe (transparent behind card)
class WorkoutMiniBar extends StatefulWidget {
  const WorkoutMiniBar({
    required this.workout,
    this.onDiscard,
    this.onSave,
    super.key,
  });

  final Workout workout;

  /// Called when user swipes right-to-left to discard workout.
  /// Returns `Future<bool>` - true if action was confirmed, false if canceled.
  final Future<bool> Function()? onDiscard;

  /// Called when user swipes left-to-right to save workout.
  /// Returns `Future<bool>` - true if action was confirmed, false if canceled.
  final Future<bool> Function()? onSave;

  @override
  State<WorkoutMiniBar> createState() => _WorkoutMiniBarState();
}

class _WorkoutMiniBarState extends State<WorkoutMiniBar>
    with TickerProviderStateMixin {
  // Entrance animation
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation;

  // Vertical drag disabled - was causing bugs with horizontal swipe

  // Horizontal swipe
  late AnimationController _horizontalController;
  double _horizontalDragOffset = 0.0;
  bool _isHorizontalDragging = false;

  // Swipe threshold (percentage of width)
  static const double _swipeThreshold = 0.35;

  // Timer for updating duration display
  Timer? _timerUpdateTimer;

  @override
  void initState() {
    super.initState();

    // Entrance animation controller
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    // Horizontal animation controller
    _horizontalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Start entrance animation
    _entranceController.forward();

    // Update timer display every second (only when workout is active)
    _timerUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.workout.status != WorkoutStatus.paused) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _horizontalController.dispose();
    _timerUpdateTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // HORIZONTAL DRAG (Swipe to discard/save)
  // ============================================================

  void _onHorizontalDragStart(DragStartDetails details) {
    _isHorizontalDragging = true;
    _horizontalController.stop();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isHorizontalDragging) return;

    setState(() {
      _horizontalDragOffset += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _isHorizontalDragging = false;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * _swipeThreshold;
    final velocity = details.velocity.pixelsPerSecond.dx;

    // Check if swipe exceeded threshold or has high velocity
    // Swipe left→right (positive offset): Save workout (green)
    if (_horizontalDragOffset > threshold || velocity > 800) {
      _triggerSave();
    }
    // Swipe right→left (negative offset): Discard workout (red)
    else if (_horizontalDragOffset < -threshold || velocity < -800) {
      _triggerDiscard();
    } else {
      // Return to original position
      _animateHorizontalReturn();
    }
  }

  void _animateHorizontalReturn() {
    final startOffset = _horizontalDragOffset;
    _horizontalController.reset();

    _horizontalController.addListener(() {
      if (mounted) {
        setState(() {
          _horizontalDragOffset = startOffset * (1 - _horizontalController.value);
        });
      }
    });

    _horizontalController.forward().then((_) {
      if (mounted) {
        setState(() {
          _horizontalDragOffset = 0;
        });
      }
    });
  }

  Future<void> _triggerDiscard() async {
    unawaited(HapticFeedback.mediumImpact());

    // Animate out to the left (swipe right-to-left = discard)
    final screenWidth = MediaQuery.of(context).size.width;
    final startOffset = _horizontalDragOffset;
    final endOffset = -screenWidth;

    _horizontalController.reset();
    _horizontalController.addListener(() {
      if (mounted) {
        setState(() {
          _horizontalDragOffset = startOffset + (endOffset - startOffset) * _horizontalController.value;
        });
      }
    });

    await _horizontalController.forward();

    // Call callback and check if action was confirmed
    final confirmed = await widget.onDiscard?.call() ?? false;

    // If action was canceled, animate back to original position
    if (!confirmed && mounted) {
      _animateHorizontalReturn();
    }
  }

  Future<void> _triggerSave() async {
    unawaited(HapticFeedback.mediumImpact());

    // Animate out to the right (swipe left-to-right = save)
    final screenWidth = MediaQuery.of(context).size.width;
    final startOffset = _horizontalDragOffset;
    final endOffset = screenWidth;

    _horizontalController.reset();
    _horizontalController.addListener(() {
      if (mounted) {
        setState(() {
          _horizontalDragOffset = startOffset + (endOffset - startOffset) * _horizontalController.value;
        });
      }
    });

    await _horizontalController.forward();

    // Call callback and check if action was confirmed
    final confirmed = await widget.onSave?.call() ?? false;

    // If action was canceled, animate back to original position
    if (!confirmed && mounted) {
      _animateHorizontalReturn();
    }
  }

  /// Builds the action indicator icon with circular background
  Widget _buildActionIndicator({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required double opacity,
  }) {
    return AnimatedOpacity(
      opacity: opacity.clamp(0.0, 1.0),
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: AppIconSize.medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final isPaused = workout.status == WorkoutStatus.paused;
    final duration = workout.duration ?? Duration.zero;
    final progress = workout.progressPercentage;

    // Calculate opacity for action indicators based on swipe progress
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeProgress = _horizontalDragOffset.abs() / (screenWidth * _swipeThreshold);

    // Save indicator opacity (swipe right, positive offset)
    final saveOpacity = _horizontalDragOffset > 0 ? swipeProgress : 0.0;

    // Discard indicator opacity (swipe left, negative offset)
    final discardOpacity = _horizontalDragOffset < 0 ? swipeProgress : 0.0;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Save indicator (left side, revealed when swiping right)
              if (_horizontalDragOffset > 10)
                Positioned(
                  left: AppSpacing.md,
                  child: _buildActionIndicator(
                    icon: AppIcons.checkCircle,
                    backgroundColor: context.colors.success,
                    iconColor: Colors.white,
                    opacity: saveOpacity,
                  ),
                ),

              // Discard indicator (right side, revealed when swiping left)
              if (_horizontalDragOffset < -10)
                Positioned(
                  right: AppSpacing.md,
                  child: _buildActionIndicator(
                    icon: AppIcons.delete,
                    backgroundColor: context.colors.error,
                    iconColor: Colors.white,
                    opacity: discardOpacity,
                  ),
                ),

              // Main card (slides horizontally) - NO background behind it
              Transform.translate(
                offset: Offset(_horizontalDragOffset, 0),
                child: GestureDetector(
                  onTap: () => _navigateToWorkout(context),
                  onHorizontalDragStart: _onHorizontalDragStart,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: Container(
                    decoration: BoxDecoration(
                      // Use surface for true floating effect (brighter than background)
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(
                        color: context.colors.outlineVariant.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        // Primary shadow for depth
                        BoxShadow(
                          color: context.colors.shadow.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                        // Secondary subtle shadow for softness
                        BoxShadow(
                          color: context.colors.shadow.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
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

                                // Timer (stops updating when paused)
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
                                const SizedBox(width: AppSpacing.xs),

                                // Arrow to indicate tap action
                                SemanticIcon(
                                  icon: AppIcons.chevronRight,
                                  semanticLabel: context.l10n.goToWorkout,
                                  size: AppIconSize.small,
                                  color: context.colors.onSurfaceVariant,
                                ),
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
                            child: DecoratedBox(
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
            ],
          ),
        ),
    );
  }

  void _navigateToWorkout(BuildContext context) {
    HapticFeedback.lightImpact();
    context.go('/workout');
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
