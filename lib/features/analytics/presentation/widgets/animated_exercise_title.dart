/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget (animated)
///
/// AnimatedExerciseTitle - Animated title for exercise detail screen
///
/// **Purpose**: Display exercise name with slide-left + fade-in animation
///
/// **Animation**:
/// - Slide: Offset(-0.3, 0.0) → Offset.zero (400ms)
/// - Fade: opacity 0.0 → 1.0 (400ms + 100ms delay)
/// - Curve: Curves.easeOut
///
/// **Features**:
/// - Automatic animation on mount
/// - FittedBox for long names (>20 characters)
/// - Theme-aware colors
/// - Semantics for accessibility
///
/// **Usage**:
/// ```dart
/// // In AppBar.title
/// AnimatedExerciseTitle(exerciseName: 'Bench Press')
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Animated title widget for exercise detail screen
///
/// **Animation Timing**:
/// - Duration: 400ms total
/// - Slide: starts immediately
/// - Fade: starts after 100ms (Interval(0.25, 1.0))
///
/// **Performance**: 60fps smooth animation with SingleTickerProviderStateMixin
class AnimatedExerciseTitle extends StatefulWidget {
  const AnimatedExerciseTitle({
    required this.exerciseName,
    super.key,
  });

  /// Exercise name to display
  final String exerciseName;

  @override
  State<AnimatedExerciseTitle> createState() => _AnimatedExerciseTitleState();
}

class _AnimatedExerciseTitleState extends State<AnimatedExerciseTitle>
    with SingleTickerProviderStateMixin {
  /// Animation controller for slide + fade
  late final AnimationController _controller;

  /// Slide animation: -0.3 left → center
  late final Animation<Offset> _slideAnimation;

  /// Fade animation: transparent → opaque (with 100ms delay)
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller (400ms duration)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Slide animation: starts immediately
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0.0), // Start 30% left
      end: Offset.zero, // End at center
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Fade animation: starts after 100ms (25% of 400ms)
    _fadeAnimation = Tween<double>(
      begin: 0.0, // Start transparent
      end: 1.0, // End opaque
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.25, // Start at 25% (100ms delay)
          1.0, // End at 100%
          curve: Curves.easeOut,
        ),
      ),
    );

    // Start animation on mount
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with Semantics for screen reader accessibility
    return Semantics(
      label: '${context.l10n.exercise}: ${widget.exerciseName}',
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildTitle(context),
        ),
      ),
    );
  }

  /// Build title text with FittedBox for long names
  Widget _buildTitle(BuildContext context) {
    final textStyle = context.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: context.colors.onSurface,
    );

    final titleText = Text(
      widget.exerciseName,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    // Use FittedBox for long names (>20 characters)
    if (widget.exerciseName.length > 20) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: titleText,
      );
    }

    return titleText;
  }
}
