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
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
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
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Countdown
  int _countdown = 5;
  Timer? _countdownTimer;
  bool _isCancelled = false;

  // Confetti particles
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

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

    // Generate confetti particles
    _generateConfetti();

    // Start animations
    _mainController.forward();
    _confettiController.repeat();

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
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.5 - 0.1,
        vx: (_random.nextDouble() - 0.5) * 0.02,
        vy: _random.nextDouble() * 0.01 + 0.005,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        size: _random.nextDouble() * 8 + 4,
        colorIndex: _random.nextInt(6),
        shape: _random.nextInt(3),
      ));
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _mainController.dispose();
    _confettiController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final themeColors = _getThemeColors(context);
    final colorScheme = context.colors;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () {}, // Don't dismiss on tap
              child: Container(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      constraints: BoxConstraints(maxHeight: maxCardHeight),
      decoration: BoxDecoration(
        // ✅ Solid background with proper border
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                // Trophy icon
                _buildAnimatedIcon(context),
                const SizedBox(height: 12),
                // Title
                Text(
                  context.l10n.workoutComplete,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Workout name
                Text(
                  widget.workout.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Exercise list (scrollable)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats summary row
                  _buildStatsRow(context),
                  const SizedBox(height: 16),

                  // Exercise details header
                  Text(
                    context.l10n.exerciseSummary,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Exercise list with details
                  ...widget.workout.exercises.map((exercise) =>
                      _buildExerciseDetail(context, exercise)),
                ],
              ),
            ),
          ),

          // Footer with countdown and buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child: Column(
              children: [
                // Countdown text
                _buildCountdownIndicator(context),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(context.l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Continue button
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _dismiss,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(context.l10n.continueToHome),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          size: AppIconSize.small,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          context.l10n.redirectingToHome(_countdown.toString()),
          style: context.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        // Animated countdown number
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(_countdown),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$_countdown',
                style: context.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final pulse = (math.sin(_mainController.value * math.pi * 4) * 0.1) + 1.0;
        return Transform.scale(
          scale: pulse,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              AppIcons.checkCircle,
              size: AppIconSize.xlarge,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final colorScheme = context.colors;
    final exerciseCount = widget.workout.exercises.length;
    final setsCount = widget.workout.exercises.fold<int>(
      0,
      (total, ex) => total + ex.sets.where((s) => s.isCompleted).length,
    );
    final duration = widget.workout.duration ?? Duration.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(
            context,
            icon: AppIcons.workout,
            value: '$exerciseCount',
            label: context.l10n.exercises,
          ),
          _buildDivider(context),
          _buildStat(
            context,
            icon: AppIcons.repeat,
            value: '$setsCount',
            label: context.l10n.sets,
          ),
          _buildDivider(context),
          _buildStat(
            context,
            icon: AppIcons.timer,
            value: _formatDuration(duration),
            label: context.l10n.duration,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final colorScheme = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: AppIconSize.small,
        ),
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

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: context.colors.outlineVariant,
    );
  }

  Widget _buildExerciseDetail(BuildContext context, Exercise exercise) {
    final colorScheme = context.colors;
    final config = ref.watch(appConfigProvider);
    final useRir = ref.watch(useRirModeProvider);
    final completedSets = exercise.sets.where((s) => s.isCompleted).toList();

    if (completedSets.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name
          Text(
            exercise.name,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Sets table
          ...completedSets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            final isWarmup = set.isWarmup;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  // Set number
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isWarmup
                          ? context.warningColor.withValues(alpha: 0.2)
                          : colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        isWarmup ? 'W' : '${index + 1}',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isWarmup
                              ? context.warningColor
                              : colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Weight (if applicable)
                  if (set.weight != null) ...[
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${set.weight?.toStringAsFixed(1) ?? "-"} ${config.measurementUnit}',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      ' × ',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  // Reps
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${set.actualReps ?? set.reps ?? "-"} reps',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // RPE/RIR (if available)
                  if (set.rpe != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRpeColor(set.rpe!).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        useRir
                            ? 'RIR ${10 - set.rpe!}'
                            : 'RPE ${set.rpe}',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getRpeColor(set.rpe!),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],

                  // Checkmark
                  const SizedBox(width: 8),
                  Icon(
                    AppIcons.checkCircle,
                    size: AppIconSize.tiny,
                    color: colorScheme.tertiary,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getRpeColor(int rpe) {
    if (rpe >= 9) return const Color(0xFFE53935); // Red - very hard
    if (rpe >= 8) return const Color(0xFFFF9800); // Orange - hard
    if (rpe >= 7) return const Color(0xFFFFC107); // Yellow - moderate
    return const Color(0xFF4CAF50); // Green - easy
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
    barrierColor: Colors.transparent,
    builder: (context) => WorkoutCompletionCelebration(
      workout: workout,
      onDismiss: () => Navigator.of(context).pop(CelebrationResult.confirmed),
      onCancel: () => Navigator.of(context).pop(CelebrationResult.cancelled),
    ),
  );
  return result ?? CelebrationResult.cancelled;
}
