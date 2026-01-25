/// Achievement Unlock Modal - Celebration UI
///
/// Displays a celebration modal when user unlocks a new achievement.
/// Features confetti animation and badge showcase.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'dart:math' as math;

/// Show achievement unlock modal
void showAchievementUnlockModal(
  BuildContext context,
  List<Achievement> achievements,
) {
  HapticFeedback.heavyImpact();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AchievementUnlockModal(achievements: achievements),
  );
}

class AchievementUnlockModal extends StatefulWidget {
  const AchievementUnlockModal({
    required this.achievements,
    super.key,
  });

  final List<Achievement> achievements;

  @override
  State<AchievementUnlockModal> createState() => _AchievementUnlockModalState();
}

class _AchievementUnlockModalState extends State<AchievementUnlockModal>
    with TickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final AnimationController _badgeController;
  final List<_ConfettiParticle> _particles = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Confetti animation (3 seconds)
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Badge animation (scale + pulse)
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Generate confetti particles
    _generateConfetti();

    // Start animations
    _confettiController.forward();
    _badgeController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: random.nextDouble() * 400,
        y: -20 - random.nextDouble() * 100,
        vx: (random.nextDouble() - 0.5) * 200,
        vy: random.nextDouble() * 300 + 200,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
        size: random.nextDouble() * 8 + 4,
        colorIndex: random.nextInt(5),
      ));
    }
  }

  Achievement get _currentAchievement => widget.achievements[_currentIndex];

  void _nextAchievement() {
    if (_currentIndex < widget.achievements.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _badgeController.reset();
      _badgeController.forward();
      HapticFeedback.lightImpact();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Confetti animation
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                  colors: [
                    context.colors.primary,
                    context.colors.secondary,
                    context.colors.tertiary,
                    context.colors.error,
                    context.colors.success,
                  ],
                ),
                child: Container(),
              );
            },
          ),

          // Modal content
          Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.shadow.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy icon
                    Icon(
                      AppIcons.achievement,
                      size: 48,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      context.l10n.achievementUnlocked,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Badge showcase
                    AnimatedBuilder(
                      animation: _badgeController,
                      builder: (context, child) {
                        final scale = Curves.elasticOut.transform(
                          _badgeController.value,
                        );
                        return Transform.scale(
                          scale: 0.5 + (scale * 0.5),
                          child: _BadgeCard(achievement: _currentAchievement),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Pagination dots (if multiple achievements)
                    if (widget.achievements.length > 1) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.achievements.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentIndex
                                  ? context.colors.primary
                                  : context.colors.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action button
                    FilledButton(
                      onPressed: _nextAchievement,
                      child: Text(
                        _currentIndex < widget.achievements.length - 1
                            ? context.l10n.next
                            : context.l10n.awesome,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge card widget
class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final badgeName = _getBadgeName(context, achievement.badgeType);
    final badgeDescription = _getBadgeDescription(context, achievement.badgeType);
    final badgeIcon = _getBadgeIcon(achievement.badgeType);
    final badgeColor = _getBadgeColor(achievement.badgeType, context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Badge icon
          Icon(
            badgeIcon,
            size: 64,
            color: badgeColor,
          ),
          const SizedBox(height: 16),

          // Badge name
          Text(
            badgeName,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Badge description
          Text(
            badgeDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getBadgeName(BuildContext context, BadgeType type) {
    switch (type) {
      case BadgeType.firstPR:
        return context.l10n.badgeFirstPR;
      case BadgeType.streakMaster7:
        return context.l10n.badgeStreakMaster7;
      case BadgeType.streakMaster14:
        return context.l10n.badgeStreakMaster14;
      case BadgeType.streakMaster30:
        return context.l10n.badgeStreakMaster30;
      case BadgeType.volumeLegend10k:
        return context.l10n.badgeVolumeLegend10k;
      case BadgeType.volumeLegend50k:
        return context.l10n.badgeVolumeLegend50k;
      case BadgeType.volumeLegend100k:
        return context.l10n.badgeVolumeLegend100k;
      case BadgeType.balancedBuilder:
        return context.l10n.badgeBalancedBuilder;
      case BadgeType.oneRepMonarch:
        return context.l10n.badgeOneRepMonarch;
      case BadgeType.workoutCompletionist50:
        return context.l10n.badgeWorkoutCompletionist50;
      case BadgeType.workoutCompletionist100:
        return context.l10n.badgeWorkoutCompletionist100;
      case BadgeType.workoutCompletionist500:
        return context.l10n.badgeWorkoutCompletionist500;
      case BadgeType.consistencyChampion:
        return context.l10n.badgeConsistencyChampion;
    }
  }

  String _getBadgeDescription(BuildContext context, BadgeType type) {
    switch (type) {
      case BadgeType.firstPR:
        return context.l10n.badgeFirstPRDescription;
      case BadgeType.streakMaster7:
        return context.l10n.badgeStreakMaster7Description;
      case BadgeType.streakMaster14:
        return context.l10n.badgeStreakMaster14Description;
      case BadgeType.streakMaster30:
        return context.l10n.badgeStreakMaster30Description;
      case BadgeType.volumeLegend10k:
        return context.l10n.badgeVolumeLegend10kDescription;
      case BadgeType.volumeLegend50k:
        return context.l10n.badgeVolumeLegend50kDescription;
      case BadgeType.volumeLegend100k:
        return context.l10n.badgeVolumeLegend100kDescription;
      case BadgeType.balancedBuilder:
        return context.l10n.badgeBalancedBuilderDescription;
      case BadgeType.oneRepMonarch:
        return context.l10n.badgeOneRepMonarchDescription;
      case BadgeType.workoutCompletionist50:
        return context.l10n.badgeWorkoutCompletionist50Description;
      case BadgeType.workoutCompletionist100:
        return context.l10n.badgeWorkoutCompletionist100Description;
      case BadgeType.workoutCompletionist500:
        return context.l10n.badgeWorkoutCompletionist500Description;
      case BadgeType.consistencyChampion:
        return context.l10n.badgeConsistencyChampionDescription;
    }
  }

  IconData _getBadgeIcon(BadgeType type) {
    switch (type) {
      case BadgeType.firstPR:
        return AppIcons.trendingUp;
      case BadgeType.streakMaster7:
      case BadgeType.streakMaster14:
      case BadgeType.streakMaster30:
        return AppIcons.localFireDepartment;
      case BadgeType.volumeLegend10k:
      case BadgeType.volumeLegend50k:
      case BadgeType.volumeLegend100k:
        return AppIcons.fitnessCenter;
      case BadgeType.balancedBuilder:
        return AppIcons.balance;
      case BadgeType.oneRepMonarch:
        return AppIcons.achievement;
      case BadgeType.workoutCompletionist50:
      case BadgeType.workoutCompletionist100:
      case BadgeType.workoutCompletionist500:
        return AppIcons.checkCircle;
      case BadgeType.consistencyChampion:
        return AppIcons.timerOutlined;
    }
  }

  Color _getBadgeColor(BadgeType type, BuildContext context) {
    switch (type) {
      case BadgeType.firstPR:
      case BadgeType.oneRepMonarch:
        return context.colors.error;
      case BadgeType.streakMaster7:
      case BadgeType.streakMaster14:
      case BadgeType.streakMaster30:
        return const Color(0xFFFF9800); // Orange
      case BadgeType.volumeLegend10k:
      case BadgeType.volumeLegend50k:
      case BadgeType.volumeLegend100k:
        return context.colors.success;
      case BadgeType.balancedBuilder:
        return context.colors.primary;
      case BadgeType.workoutCompletionist50:
      case BadgeType.workoutCompletionist100:
      case BadgeType.workoutCompletionist500:
        return context.colors.tertiary;
      case BadgeType.consistencyChampion:
        return context.colors.secondary;
    }
  }
}

/// Confetti particle
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
  });

  double x;
  double y;
  final double vx;
  final double vy;
  double rotation;
  final double rotationSpeed;
  final double size;
  final int colorIndex;
}

/// Confetti painter
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
      // Update position based on progress
      final currentX = particle.x + (particle.vx * progress);
      final currentY = particle.y + (particle.vy * progress);
      final currentRotation = particle.rotation + (particle.rotationSpeed * progress);

      // Only draw if within bounds
      if (currentY < size.height && currentY > -100) {
        canvas.save();
        canvas.translate(currentX, currentY);
        canvas.rotate(currentRotation);

        final paint = Paint()
          ..color = colors[particle.colorIndex % colors.length]
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
