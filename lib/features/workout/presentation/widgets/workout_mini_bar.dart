import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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
/// - Haptic feedback on interactions
class WorkoutMiniBar extends StatefulWidget {
  const WorkoutMiniBar({
    required this.workout,
    super.key,
  });

  final Workout workout;

  @override
  State<WorkoutMiniBar> createState() => _WorkoutMiniBarState();
}

class _WorkoutMiniBarState extends State<WorkoutMiniBar>
    with TickerProviderStateMixin {
  // Entrance animation
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation;

  // Drag animation with spring physics
  late AnimationController _springController;
  late Animation<double> _springAnimation;
  double _dragOffset = 0.0;
  bool _isDragging = false;

  // Timer for updating duration display
  Timer? _timerUpdateTimer;

  // Spring physics for ultra-smooth rubber-band return
  // Lower stiffness + higher damping = more natural, slower rubber feel
  static const SpringDescription _springDescription = SpringDescription(
    mass: 1.2,      // Slightly heavier for more natural feel
    stiffness: 180.0, // Lower = slower, more elastic return
    damping: 18.0,   // Higher = less oscillation, smoother stop
  );

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

    // Spring animation controller
    _springController = AnimationController(vsync: this);
    _springAnimation = _springController.drive(Tween<double>(begin: 0, end: 0));

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
    _springController.dispose();
    _timerUpdateTimer?.cancel();
    super.dispose();
  }

  /// Rubber-band resistance formula - infinite, never blocks
  /// Returns a multiplier between 0 and 1 that decreases as offset increases
  double _calculateResistance(double offset) {
    // Logarithmic resistance - gets harder but never reaches zero
    // Formula: 1 / (1 + k * |offset|^p) where k controls intensity, p controls curve shape
    const k = 0.008; // Intensity factor (higher = more resistance)
    const p = 1.4;   // Curve power (higher = steeper resistance curve)
    return 1.0 / (1.0 + k * _pow(offset.abs(), p));
  }

  /// Safe power function
  double _pow(double base, double exp) {
    if (base <= 0) return 0;
    return base <= 0 ? 0 : (base == 1 ? 1 : (base < 1 ? base : _fastPow(base, exp)));
  }

  double _fastPow(double base, double exp) {
    // Approximation for small exponents
    return base * (1 + (exp - 1) * (base - 1) * 0.5);
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
    _springController.stop();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      // Apply rubber-band resistance based on current offset
      final resistance = _calculateResistance(_dragOffset);
      _dragOffset += details.delta.dy * resistance;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;

    // Create spring simulation for smooth return
    final simulation = SpringSimulation(
      _springDescription,
      _dragOffset,
      0.0, // Target: back to original position
      details.velocity.pixelsPerSecond.dy * 0.001, // Convert velocity
    );

    // Animate with spring physics
    _springController.reset();
    _springAnimation = _springController.drive(
      Tween<double>(begin: _dragOffset, end: 0.0),
    );

    _springController.animateWith(simulation).then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = 0.0;
        });
      }
    });

    // Listen to animation updates
    _springController.addListener(_onSpringUpdate);

    // Haptic feedback when releasing
    HapticFeedback.lightImpact();
  }

  void _onSpringUpdate() {
    if (!_isDragging && mounted) {
      setState(() {
        _dragOffset = _springAnimation.value;
      });
    }
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
          onVerticalDragStart: _onVerticalDragStart,
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
