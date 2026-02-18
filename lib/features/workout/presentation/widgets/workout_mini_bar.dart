import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
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
/// - Subtle floating animation (vertical oscillation)
/// - Live timer updating every second
/// - Horizontal swipe gestures:
///   - Swipe left→right: Save workout (green circle + check icon)
///   - Swipe right→left: Discard workout (red circle + trash icon)
/// - Haptic feedback on interactions
class WorkoutMiniBar extends ConsumerStatefulWidget {
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
  ConsumerState<WorkoutMiniBar> createState() => _WorkoutMiniBarState();
}

class _WorkoutMiniBarState extends ConsumerState<WorkoutMiniBar>
    with TickerProviderStateMixin {
  // Entrance animation
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation;

  // Floating animation (subtle vertical oscillation)
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // Horizontal swipe
  late AnimationController _horizontalController;
  double _horizontalDragOffset = 0.0;
  bool _isHorizontalDragging = false;

  // Swipe threshold (percentage of width)
  static const double _swipeThreshold = 0.35;

  @override
  void initState() {
    super.initState();

    // Entrance animation controller
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Floating animation - subtle vertical oscillation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: 0, end: 3.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );
    _floatController.repeat(reverse: true);

    // Horizontal animation controller
    _horizontalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Start entrance animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _horizontalController.dispose();
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
          _horizontalDragOffset =
              startOffset * (1 - _horizontalController.value);
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
          _horizontalDragOffset =
              startOffset +
              (endOffset - startOffset) * _horizontalController.value;
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
          _horizontalDragOffset =
              startOffset +
              (endOffset - startOffset) * _horizontalController.value;
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
        child: Icon(icon, color: iconColor, size: AppIconSize.medium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final isPaused = workout.status == WorkoutStatus.paused;
    final progress = workout.progressPercentage;

    // Calculate opacity for action indicators based on swipe progress
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeProgress =
        _horizontalDragOffset.abs() / (screenWidth * _swipeThreshold);

    // Save indicator opacity (swipe right, positive offset)
    final saveOpacity = _horizontalDragOffset > 0 ? swipeProgress : 0.0;

    // Discard indicator opacity (swipe left, negative offset)
    final discardOpacity = _horizontalDragOffset < 0 ? swipeProgress : 0.0;

    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_floatAnimation.value),
            child: child,
          );
        },
        child: Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                    iconColor: context.colors.onPrimary,
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
                    iconColor: context.colors.onError,
                    opacity: discardOpacity,
                  ),
                ),

              // Main card (slides horizontally) - frosted glass effect
              Transform.translate(
                offset: Offset(_horizontalDragOffset, 0),
                child: GestureDetector(
                  onTap: () => _navigateToWorkout(context),
                  onHorizontalDragStart: _onHorizontalDragStart,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.colors.surface.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.colors.outlineVariant.withValues(
                              alpha: 0.2,
                            ),
                            width: 0.5,
                          ),
                          boxShadow: [
                            // Soft ambient shadow
                            BoxShadow(
                              color: context.colors.shadow.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 32,
                              spreadRadius: 4,
                              offset: Offset.zero,
                            ),
                            // Depth shadow
                            BoxShadow(
                              color: context.colors.shadow.withValues(
                                alpha: 0.12,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Main content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                child: Row(
                                  children: [
                                    // Workout icon with pulse dot
                                    _StatusDot(isPaused: isPaused),
                                    const SizedBox(width: AppSpacing.sm),

                                    // Workout name
                                    Expanded(
                                      child: Text(
                                        workout.name,
                                        style: context.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Live timer - updates every second independently
                                    _LiveTimer(
                                      startTime: workout.startTime,
                                      endTime: workout.endTime,
                                      isPaused: isPaused,
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
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                ),
                                color: context.colors.surfaceContainerLow,
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(16),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToWorkout(BuildContext context) {
    HapticFeedback.lightImpact();
    context.go('/workout');
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Live Timer - Self-updating widget (isolated rebuild every second)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _LiveTimer extends StatefulWidget {
  const _LiveTimer({
    required this.startTime,
    required this.endTime,
    required this.isPaused,
  });

  final DateTime? startTime;
  final DateTime? endTime;
  final bool isPaused;

  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.isPaused) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(_LiveTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused && !oldWidget.isPaused) {
      _timer?.cancel();
      _timer = null;
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _computeDuration() {
    if (widget.startTime == null) return Duration.zero;
    final end = widget.endTime ?? DateTime.now();
    return end.difference(widget.startTime!);
  }

  @override
  Widget build(BuildContext context) {
    final duration = _computeDuration();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final text = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return RepaintBoundary(
      child: Text(
        text,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: widget.isPaused
              ? context.colors.warning
              : context.colors.primary,
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Status Dot - Animated pulsing indicator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.isPaused});
  final bool isPaused;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (!widget.isPaused) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused && !oldWidget.isPaused) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isPaused
        ? context.colors.warning
        : context.colors.primary;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: _pulseAnimation.value),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4 * _pulseAnimation.value),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
