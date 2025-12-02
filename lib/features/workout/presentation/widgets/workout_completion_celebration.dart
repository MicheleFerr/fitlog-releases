/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/workout/presentation/widgets
/// Feature: Workout Completion
/// Type: Widget
///
/// Celebration overlay shown when user completes a workout.
/// Features journey-themed confetti and workout stats.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme.dart';
import 'package:gymbro_flutter_new/features/journey_themes/presentation/providers/journey_theme_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Workout completion celebration overlay with journey-themed confetti
class WorkoutCompletionCelebration extends ConsumerStatefulWidget {
  const WorkoutCompletionCelebration({
    required this.workout,
    required this.onDismiss,
    super.key,
  });

  final Workout workout;
  final VoidCallback onDismiss;

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

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
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
    _mainController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _mainController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final journeyTheme = ref.watch(effectiveJourneyThemeProvider);
    final themeColors = _getThemeColors(journeyTheme);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                color: context.colors.onSurface.withValues(alpha: 0.6),
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
                child: _buildCelebrationCard(context, journeyTheme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getThemeColors(JourneyTheme theme) {
    switch (theme) {
      case JourneyTheme.classic:
        return [
          const Color(0xFF2196F3), // Blue (primary)
          const Color(0xFF64B5F6), // Light blue
          const Color(0xFF1E88E5), // Medium blue
          const Color(0xFFBBDEFB), // Pale blue
          const Color(0xFF42A5F5), // Sky blue
          const Color(0xFF1976D2), // Dark blue
        ];
      case JourneyTheme.hero:
        return [
          const Color(0xFFFFD700), // Gold
          const Color(0xFFFFA500), // Orange
          const Color(0xFFFF6B6B), // Coral
          const Color(0xFFFFE66D), // Yellow
          const Color(0xFFFF8C42), // Orange red
          const Color(0xFFFFC857), // Warm gold
        ];
      case JourneyTheme.hunter:
        return [
          const Color(0xFF4CAF50), // Green
          const Color(0xFF81C784), // Light green
          const Color(0xFF2E7D32), // Dark green
          const Color(0xFFA5D6A7), // Pale green
          const Color(0xFF66BB6A), // Medium green
          const Color(0xFF388E3C), // Forest green
        ];
      case JourneyTheme.warriorGoddess:
        return [
          const Color(0xFF9C27B0), // Purple
          const Color(0xFFBA68C8), // Light purple
          const Color(0xFFE040FB), // Pink accent
          const Color(0xFF7B1FA2), // Dark purple
          const Color(0xFFCE93D8), // Pale purple
          const Color(0xFFAB47BC), // Medium purple
        ];
      case JourneyTheme.natureSpirit:
        return [
          const Color(0xFF26A69A), // Teal
          const Color(0xFF4DB6AC), // Light teal
          const Color(0xFF00897B), // Dark teal
          const Color(0xFF80CBC4), // Pale teal
          const Color(0xFF009688), // Medium teal
          const Color(0xFF26C6DA), // Cyan
        ];
      case JourneyTheme.phoenix:
        return [
          const Color(0xFFFF5722), // Deep orange
          const Color(0xFFFF7043), // Light orange
          const Color(0xFFE64A19), // Dark orange
          const Color(0xFFFFAB91), // Pale orange
          const Color(0xFFFF8A65), // Medium orange
          const Color(0xFFDD2C00), // Red accent
        ];
      case JourneyTheme.frost:
        return [
          const Color(0xFF2196F3), // Blue
          const Color(0xFF64B5F6), // Light blue
          const Color(0xFF1976D2), // Dark blue
          const Color(0xFF90CAF9), // Pale blue
          const Color(0xFF42A5F5), // Medium blue
          const Color(0xFF00BCD4), // Cyan
        ];
    }
  }

  Widget _buildCelebrationCard(BuildContext context, JourneyTheme theme) {
    final journeyColors = context.journeyThemeOrDefault;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: journeyColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: journeyColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          if (journeyColors.isGlowEnabled)
            BoxShadow(
              color: journeyColors.glowColor.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 5,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy icon with pulse
          _buildAnimatedIcon(context),

          const SizedBox(height: 20),

          // Title
          Text(
            context.l10n.workoutComplete,
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Workout name
          Text(
            widget.workout.name,
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 20),

          // Stats row
          _buildStatsRow(context),

          const SizedBox(height: 24),

          // Dismiss button
          _buildDismissButton(context),
        ],
      ),
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
            padding: const EdgeInsets.all(20),
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
              size: AppIconSize.xxlarge + 16,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final exerciseCount = widget.workout.exercises.length;
    final setsCount = widget.workout.exercises.fold<int>(
      0,
      (total, ex) => total + ex.sets.where((s) => s.isCompleted).length,
    );
    final duration = widget.workout.duration ?? Duration.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
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
          _buildDivider(),
          _buildStat(
            context,
            icon: AppIcons.repeat,
            value: '$setsCount',
            label: context.l10n.sets,
          ),
          _buildDivider(),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: AppIconSize.small,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
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

  Widget _buildDismissButton(BuildContext context) {
    return TextButton(
      onPressed: _dismiss,
      style: TextButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        context.l10n.awesome,
        style: context.textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  double x; // 0-1 screen width
  double y; // 0-1 screen height (starts negative)
  final double vx; // x velocity
  final double vy; // y velocity
  double rotation;
  final double rotationSpeed;
  final double size;
  final int colorIndex;
  final int shape; // 0=circle, 1=square, 2=rectangle
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
      // Update particle position
      particle.x += particle.vx;
      particle.y += particle.vy + (progress * 0.005);
      particle.rotation += particle.rotationSpeed;

      // Skip if offscreen
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
        case 0: // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 2: // Rectangle (ribbon-like)
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

/// Shows workout completion celebration overlay
void showWorkoutCompletionCelebration(
  BuildContext context,
  Workout workout,
) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) => WorkoutCompletionCelebration(
      workout: workout,
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}
