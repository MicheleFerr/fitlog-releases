/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: analytics
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// **PR Celebration Overlay - Priority 1 Feature**
/// Evidence: +30% engagement from gamification (Fitbit study)
/// Shows: Animated celebration when PR achieved (trophy icon + gradient)
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Celebration overlay shown when user achieves a Personal Record
class PRCelebrationOverlay extends StatefulWidget {
  const PRCelebrationOverlay({
    required this.pr,
    required this.onDismiss,
    super.key,
  });

  final PersonalRecordAchieved pr;
  final VoidCallback onDismiss;

  @override
  State<PRCelebrationOverlay> createState() => _PRCelebrationOverlayState();
}

class _PRCelebrationOverlayState extends State<PRCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animations
    _animationController.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black54,
              ),
            ),
          ),

          // Simple confetti particles (native Flutter)
          ...List.generate(15, (index) {
            return _buildConfettiParticle(index);
          }),

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

  Widget _buildConfettiParticle(int index) {
    final random = math.Random(index);
    final xOffset = random.nextDouble() * 2 - 1; // -1 to 1
    final delay = random.nextDouble() * 0.3;
    final colors = [
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.blue,
      Colors.green,
    ];
    final color = colors[random.nextInt(colors.length)];

    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        final value = (_confettiAnimation.value - delay).clamp(0.0, 1.0);
        final yPos = value * MediaQuery.of(context).size.height;
        final xPos = MediaQuery.of(context).size.width / 2 + (xOffset * 100 * value);
        final rotation = value * math.pi * 4;

        return Positioned(
          left: xPos,
          top: yPos,
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCelebrationCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.success.withAlpha(230),
            context.colors.success.withAlpha(204),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.success.withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy icon with pulse animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final pulse = (math.sin(_animationController.value * math.pi * 2) * 0.1) + 1.0;
              return Transform.scale(
                scale: pulse,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    AppIcons.star,
                    size: AppIconSize.xxlarge,
                    color: context.colors.success,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            '🎉 ${context.l10n.newPersonalRecord}!',
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // PR details
          Text(
            widget.pr.exerciseName,
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.white.withAlpha(230),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // PR value
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatPRValue(widget.pr),
              style: context.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Improvement percentage
          if (widget.pr.improvementPercentage > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.trendUp,
                  color: Colors.white,
                  size: AppIconSize.small,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${widget.pr.improvementPercentage.toStringAsFixed(1)}%',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),

          // Dismiss button
          TextButton(
            onPressed: _dismiss,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(51),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              context.l10n.awesome,
              style: context.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPRValue(PersonalRecordAchieved pr) {
    switch (pr.type) {
      case PRType.weight:
        return '${pr.newValue.toStringAsFixed(1)} kg';
      case PRType.reps:
        return '${pr.newValue.toInt()} reps';
      case PRType.volume:
        return '${pr.newValue.toStringAsFixed(0)} kg total';
      case PRType.oneRM:
        return '${pr.newValue.toStringAsFixed(1)} kg (1RM)';
      case PRType.totalSets:
        return '${pr.newValue.toInt()} sets';
      case PRType.duration:
        return '${pr.newValue.toInt()} min';
    }
  }
}

/// Shows PR celebration overlay
void showPRCelebration(BuildContext context, PersonalRecordAchieved pr) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) => PRCelebrationOverlay(
      pr: pr,
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}
