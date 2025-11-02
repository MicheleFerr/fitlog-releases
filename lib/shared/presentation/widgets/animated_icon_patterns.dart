import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Reusable icon animation patterns
///
/// Provides standardized animation builders for common icon animations:
/// - Rotating (infinite spin for loading states)
/// - Pulsing (scale animation for emphasis/CTA)
/// - Bouncing (elastic entrance for notifications)
/// - Fading (fade in/out transitions)
/// - Shaking (error/alert emphasis)
///
/// **Usage:**
/// ```dart
/// // Rotating loader
/// AnimatedIconPatterns.rotating(
///   icon: AppIcons.loading,
///   color: context.iconPrimary,
/// )
///
/// // Pulsing CTA
/// AnimatedIconPatterns.pulsing(
///   icon: AppIcons.playArrow,
///   color: context.iconSuccess,
/// )
/// ```
///
/// See also:
/// - [SemanticIcon] for accessible icons
/// - [AppIconSize] for sizing constants
class AnimatedIconPatterns {
  AnimatedIconPatterns._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔄 ROTATING PATTERN (Loading, Processing)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Infinite rotating icon (for loading states)
  ///
  /// Perfect for:
  /// - Loading indicators
  /// - Processing states
  /// - Background sync indicators
  ///
  /// ```dart
  /// AnimatedIconPatterns.rotating(
  ///   icon: AppIcons.sync,
  ///   duration: Duration(seconds: 2),
  ///   color: context.iconPrimary,
  /// )
  /// ```
  static Widget rotating({
    required IconData icon,
    Duration duration = const Duration(seconds: 2),
    Color? color,
    double size = AppIconSize.medium,
    String? semanticLabel,
  }) {
    return _RotatingIcon(
      icon: icon,
      duration: duration,
      color: color,
      size: size,
      semanticLabel: semanticLabel,
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 💓 PULSING PATTERN (Call-to-Action, Emphasis)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Pulsing scale animation (for emphasis)
  ///
  /// Perfect for:
  /// - Call-to-action buttons
  /// - Important notifications
  /// - Drawing attention to features
  ///
  /// ```dart
  /// AnimatedIconPatterns.pulsing(
  ///   icon: AppIcons.notification,
  ///   duration: Duration(seconds: 1),
  ///   scaleAmount: 0.2,
  /// )
  /// ```
  static Widget pulsing({
    required IconData icon,
    Duration duration = const Duration(seconds: 1),
    double scaleAmount = 0.2,
    Color? color,
    double size = AppIconSize.medium,
    String? semanticLabel,
  }) {
    return _PulsingIcon(
      icon: icon,
      duration: duration,
      scaleAmount: scaleAmount,
      color: color,
      size: size,
      semanticLabel: semanticLabel,
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎾 BOUNCING PATTERN (Notifications, Alerts)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Bouncing entrance animation (for notifications)
  ///
  /// Perfect for:
  /// - New notification badges
  /// - Alert popups
  /// - Achievement unlocked
  ///
  /// ```dart
  /// AnimatedIconPatterns.bouncing(
  ///   icon: AppIcons.trophy,
  ///   color: Colors.gold,
  /// )
  /// ```
  static Widget bouncing({
    required IconData icon,
    Duration duration = const Duration(milliseconds: 500),
    double bounceHeight = 20.0,
    Color? color,
    double size = AppIconSize.medium,
    String? semanticLabel,
  }) {
    return _BouncingIcon(
      icon: icon,
      duration: duration,
      bounceHeight: bounceHeight,
      color: color,
      size: size,
      semanticLabel: semanticLabel,
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🌫️ FADING PATTERN (Transitions, State Changes)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Fading animation (for smooth transitions)
  ///
  /// Perfect for:
  /// - State transitions
  /// - Conditional rendering
  /// - Smooth icon changes
  ///
  /// ```dart
  /// AnimatedIconPatterns.fading(
  ///   icon: AppIcons.checkmark,
  ///   show: isComplete,
  /// )
  /// ```
  static Widget fading({
    required IconData icon,
    required bool show,
    Duration duration = const Duration(milliseconds: 300),
    Color? color,
    double size = AppIconSize.medium,
    String? semanticLabel,
  }) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: duration,
      child: Icon(
        icon,
        color: color,
        size: size,
        semanticLabel: semanticLabel,
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🥁 SHAKING PATTERN (Errors, Alerts)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Shaking animation (for error emphasis)
  ///
  /// Perfect for:
  /// - Form validation errors
  /// - Invalid input
  /// - Alert icons
  ///
  /// ```dart
  /// AnimatedIconPatterns.shaking(
  ///   icon: AppIcons.error,
  ///   trigger: hasError,
  /// )
  /// ```
  static Widget shaking({
    required IconData icon,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 500),
    double shakeOffset = 10.0,
    Color? color,
    double size = AppIconSize.medium,
    String? semanticLabel,
  }) {
    return _ShakingIcon(
      icon: icon,
      trigger: trigger,
      duration: duration,
      shakeOffset: shakeOffset,
      color: color,
      size: size,
      semanticLabel: semanticLabel,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRIVATE IMPLEMENTATION WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _RotatingIcon extends StatefulWidget {
  final IconData icon;
  final Duration duration;
  final Color? color;
  final double size;
  final String? semanticLabel;

  const _RotatingIcon({
    required this.icon,
    required this.duration,
    this.color,
    required this.size,
    this.semanticLabel,
  });

  @override
  State<_RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        widget.icon,
        color: widget.color,
        size: widget.size,
        semanticLabel: widget.semanticLabel,
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Duration duration;
  final double scaleAmount;
  final Color? color;
  final double size;
  final String? semanticLabel;

  const _PulsingIcon({
    required this.icon,
    required this.duration,
    required this.scaleAmount,
    this.color,
    required this.size,
    this.semanticLabel,
  });

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + widget.scaleAmount,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(
        widget.icon,
        color: widget.color,
        size: widget.size,
        semanticLabel: widget.semanticLabel,
      ),
    );
  }
}

class _BouncingIcon extends StatelessWidget {
  final IconData icon;
  final Duration duration;
  final double bounceHeight;
  final Color? color;
  final double size;
  final String? semanticLabel;

  const _BouncingIcon({
    required this.icon,
    required this.duration,
    required this.bounceHeight,
    this.color,
    required this.size,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -bounceHeight * (1 - value)),
          child: child,
        );
      },
      child: Icon(
        icon,
        color: color,
        size: size,
        semanticLabel: semanticLabel,
      ),
    );
  }
}

class _ShakingIcon extends StatefulWidget {
  final IconData icon;
  final bool trigger;
  final Duration duration;
  final double shakeOffset;
  final Color? color;
  final double size;
  final String? semanticLabel;

  const _ShakingIcon({
    required this.icon,
    required this.trigger,
    required this.duration,
    required this.shakeOffset,
    this.color,
    required this.size,
    this.semanticLabel,
  });

  @override
  State<_ShakingIcon> createState() => _ShakingIconState();
}

class _ShakingIconState extends State<_ShakingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: widget.shakeOffset), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.shakeOffset, end: -widget.shakeOffset), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -widget.shakeOffset, end: widget.shakeOffset), weight: 2),
      TweenSequenceItem(tween: Tween(begin: widget.shakeOffset, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(_ShakingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: child,
        );
      },
      child: Icon(
        widget.icon,
        color: widget.color,
        size: widget.size,
        semanticLabel: widget.semanticLabel,
      ),
    );
  }
}
