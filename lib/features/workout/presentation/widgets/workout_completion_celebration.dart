/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/workout/presentation/widgets
/// Feature: Workout Completion
/// Type: Widget
///
/// Celebration overlay shown when user completes a workout.
/// Features journey-themed confetti, detailed workout summary, and countdown.
library;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/services/workout_share_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Workout completion celebration overlay with journey-themed confetti
/// and detailed workout summary with countdown redirect.
class WorkoutCompletionCelebration extends ConsumerStatefulWidget {
  const WorkoutCompletionCelebration({
    required this.workout,
    required this.onDismiss,
    this.onCancel,
    super.key,
  });

  final Workout workout;
  final VoidCallback onDismiss;
  final VoidCallback? onCancel;

  @override
  ConsumerState<WorkoutCompletionCelebration> createState() =>
      _WorkoutCompletionCelebrationState();
}

class _WorkoutCompletionCelebrationState
    extends ConsumerState<WorkoutCompletionCelebration>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  // Countdown
  int _countdown = 5;
  Timer? _countdownTimer;
  bool _isCancelled = false;
  bool _isSharing = false;

  // Confetti particles
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  // Motivational message index (random per session)
  late int _motivationalIndex;

  @override
  void initState() {
    super.initState();

    _motivationalIndex = _random.nextInt(5);

    // Main animation for card
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Pulse animation for trophy
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Generate confetti particles
    _generateConfetti();

    // Start animations
    _mainController.forward();
    _confettiController.repeat();
    _pulseController.repeat(reverse: true);

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Start countdown
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isCancelled) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _dismiss();
      }
    });
  }

  void _generateConfetti() {
    for (int i = 0; i < 50; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(),
          y: -_random.nextDouble() * 0.5 - 0.1,
          vx: (_random.nextDouble() - 0.5) * 0.02,
          vy: _random.nextDouble() * 0.01 + 0.005,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
          size: _random.nextDouble() * 8 + 4,
          colorIndex: _random.nextInt(6),
          shape: _random.nextInt(3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _mainController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _countdownTimer?.cancel();
    _mainController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  void _cancel() {
    _isCancelled = true;
    _countdownTimer?.cancel();
    _mainController.reverse().then((_) {
      widget.onCancel?.call();
    });
  }

  Future<void> _share() async {
    if (_isSharing) return;
    // Pause countdown while sharing
    _isCancelled = true;
    _countdownTimer?.cancel();
    setState(() => _isSharing = true);

    HapticFeedback.lightImpact();

    final success = await WorkoutShareService.shareWorkout(
      context: context,
      workout: widget.workout,
      userName: '',
      elapsedDuration: widget.workout.duration ?? Duration.zero,
    );

    if (!mounted) return;
    setState(() => _isSharing = false);

    // Resume countdown after share
    if (success) {
      _isCancelled = false;
      _startCountdown();
    } else {
      _isCancelled = false;
      _startCountdown();
    }
  }

  String _getMotivationalMessage(BuildContext context) {
    final l10n = context.l10n;
    return switch (_motivationalIndex) {
      0 => l10n.celebrationMotivational1,
      1 => l10n.celebrationMotivational2,
      2 => l10n.celebrationMotivational3,
      3 => l10n.celebrationMotivational4,
      _ => l10n.celebrationMotivational5,
    };
  }

  // --- Computed stats ---

  int get _exerciseCount => widget.workout.exercises.length;

  int get _setsCount => widget.workout.exercises.fold<int>(
        0,
        (total, ex) => total + ex.sets.where((s) => s.isCompleted).length,
      );

  double get _totalVolume => widget.workout.exercises.fold<double>(
        0,
        (total, ex) =>
            total +
            ex.sets
                .where((s) => s.isCompleted && !s.isWarmup)
                .fold<double>(
                  0,
                  (sum, s) =>
                      sum + (s.weight ?? 0) * (s.actualReps ?? s.reps ?? 0),
                ),
      );

  double get _avgRpe {
    final rpes = widget.workout.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted && !s.isWarmup && s.rpe != null)
        .map((s) => s.rpe!)
        .toList();
    if (rpes.isEmpty) return 0;
    return rpes.reduce((a, b) => a + b) / rpes.length;
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = _getThemeColors(context);
    final colorScheme = context.colors;

    return Material(
      color: colorScheme.surface.withValues(alpha: 0),
      child: Stack(
        children: [
          // Background overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () {}, // Don't dismiss on tap
              child: Container(
                color: colorScheme.scrim.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Confetti layer
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                  colors: themeColors,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Celebration card
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildCelebrationCard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get confetti colors based on current theme
  List<Color> _getThemeColors(BuildContext context) {
    final colorScheme = context.colors;
    return [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];
  }

  Widget _buildCelebrationCard(BuildContext context) {
    final colorScheme = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxCardHeight = screenHeight * 0.75;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: BoxConstraints(maxHeight: maxCardHeight),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with gradient
          _buildHeader(context),

          // Content (scrollable)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats grid
                  _buildStatsGrid(context),
                  const SizedBox(height: 20),

                  // Exercise details header
                  Text(
                    context.l10n.exerciseSummary,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Exercise compact list
                  ...widget.workout.exercises.map(
                    (exercise) => _buildExerciseCompact(context, exercise),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Footer with share, countdown, and buttons
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
            colorScheme.secondary,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Trophy icon with animated pulse
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onPrimary.withValues(alpha: 0.15),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                AppIcons.trophy,
                size: AppIconSize.xxlarge,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            context.l10n.workoutComplete,
            style: context.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Workout name
          Text(
            widget.workout.name,
            style: context.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Motivational message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getMotivationalMessage(context),
              style: context.textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final colorScheme = context.colors;
    final measurementUnit = ref.watch(
      appConfigProvider.select((c) => c.measurementUnit),
    );
    final duration = widget.workout.duration ?? Duration.zero;
    final hasRpe = _avgRpe > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // First row: Exercises, Sets, Duration
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: AppIcons.workout,
                  value: '$_exerciseCount',
                  label: context.l10n.exercises,
                ),
              ),
              _buildStatDivider(context),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: AppIcons.repeat,
                  value: '$_setsCount',
                  label: context.l10n.sets,
                ),
              ),
              _buildStatDivider(context),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: AppIcons.timer,
                  value: _formatDuration(duration),
                  label: context.l10n.duration,
                ),
              ),
            ],
          ),

          // Divider between rows
          if (_totalVolume > 0 || hasRpe) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),

            // Second row: Volume and avg RPE
            Row(
              children: [
                if (_totalVolume > 0)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: AppIcons.workout,
                      value: _formatVolume(_totalVolume, measurementUnit),
                      label: context.l10n.totalVolume,
                    ),
                  ),
                if (_totalVolume > 0 && hasRpe) _buildStatDivider(context),
                if (hasRpe)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: AppIcons.star,
                      value: _avgRpe.toStringAsFixed(1),
                      label: context.l10n.averageRpe,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final colorScheme = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: colorScheme.primary, size: AppIconSize.small),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: context.colors.outlineVariant.withValues(alpha: 0.5),
    );
  }

  Widget _buildExerciseCompact(BuildContext context, Exercise exercise) {
    final colorScheme = context.colors;
    final measurementUnit = ref.watch(
      appConfigProvider.select((c) => c.measurementUnit),
    );
    final completedSets =
        exercise.sets.where((s) => s.isCompleted && !s.isWarmup).toList();

    if (completedSets.isEmpty) return const SizedBox.shrink();

    // Find best set (highest volume = weight * reps)
    final bestSet = completedSets.reduce((best, current) {
      final bestVol =
          (best.weight ?? 0) * (best.actualReps ?? best.reps ?? 0);
      final currentVol =
          (current.weight ?? 0) * (current.actualReps ?? current.reps ?? 0);
      return currentVol > bestVol ? current : best;
    });

    final bestWeight = bestSet.weight;
    final bestReps = bestSet.actualReps ?? bestSet.reps;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Exercise name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Best set info
                if (bestWeight != null && bestWeight > 0)
                  Text(
                    '${ bestWeight % 1 == 0 ? bestWeight.toInt() : bestWeight.toStringAsFixed(1)} $measurementUnit × $bestReps',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Sets count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              context.l10n.setsCompleted(completedSets.length),
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Checkmark
          Icon(
            AppIcons.checkCircle,
            size: AppIconSize.small,
            color: context.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Countdown text
          _buildCountdownIndicator(context),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              // Cancel button
              OutlinedButton(
                onPressed: _cancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(context.l10n.cancel),
              ),
              const SizedBox(width: 8),

              // Share button
              OutlinedButton(
                onPressed: _isSharing ? null : _share,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: _isSharing
                    ? SizedBox(
                        width: AppIconSize.small,
                        height: AppIconSize.small,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(AppIcons.share, size: AppIconSize.small),
                          const SizedBox(width: 4),
                          Text(context.l10n.shareResult),
                        ],
                      ),
              ),
              const SizedBox(width: 8),

              // Primary: Go Home with countdown
              Expanded(
                child: FilledButton(
                  onPressed: _dismiss,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(AppIcons.home, size: AppIconSize.small),
                      const SizedBox(width: 8),
                      Text(context.l10n.goHome),
                      if (_countdown > 0) ...[
                        const SizedBox(width: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            key: ValueKey(_countdown),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withValues(
                                alpha: 0.25,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_countdown',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownIndicator(BuildContext context) {
    final colorScheme = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          AppIcons.timer,
          size: AppIconSize.tiny,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          context.l10n.redirectingToHome(_countdown.toString()),
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _formatVolume(double volume, String unit) {
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}t';
    return '${volume.toInt()} $unit';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    return '${hours}h ${remainingMins}m';
  }
}

/// Single confetti particle data
class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.colorIndex,
    required this.shape,
  });

  double x;
  double y;
  final double vx;
  final double vy;
  double rotation;
  final double rotationSpeed;
  final double size;
  final int colorIndex;
  final int shape;
}

/// Custom painter for confetti effect
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.colors,
  });

  final List<_ConfettiParticle> particles;
  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.x += particle.vx;
      particle.y += particle.vy + (progress * 0.005);
      particle.rotation += particle.rotationSpeed;

      if (particle.y > 1.2) continue;

      final paint = Paint()
        ..color = colors[particle.colorIndex]
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation);

      switch (particle.shape) {
        case 0:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 2:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 0.4,
              height: particle.size * 1.5,
            ),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

/// Result of the celebration dialog
enum CelebrationResult {
  /// User confirmed - save workout and go home
  confirmed,

  /// User cancelled - go back to modify workout
  cancelled,
}

/// Shows workout completion celebration overlay
///
/// Returns [CelebrationResult.confirmed] if user confirms (countdown or button),
/// or [CelebrationResult.cancelled] if user wants to go back and modify.
Future<CelebrationResult> showWorkoutCompletionCelebration(
  BuildContext context,
  Workout workout,
) async {
  final result = await showDialog<CelebrationResult>(
    context: context,
    barrierDismissible: false, // Must use buttons
    barrierColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
    builder: (context) => WorkoutCompletionCelebration(
      workout: workout,
      onDismiss: () => Navigator.of(context).pop(CelebrationResult.confirmed),
      onCancel: () => Navigator.of(context).pop(CelebrationResult.cancelled),
    ),
  );
  return result ?? CelebrationResult.cancelled;
}
