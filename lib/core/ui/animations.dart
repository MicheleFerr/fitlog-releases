import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Smooth animations for GymBro
class GymBroAnimations {
  // Animation durations
  static const Duration superFast = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration superSlow = Duration(milliseconds: 800);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutQuart;
  static const Curve sharpCurve = Curves.easeOutExpo;
}

/// Animated scale widget with haptic feedback
class ScaleButton extends StatefulWidget {

  const ScaleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleFactor = 0.95,
    this.duration = GymBroAnimations.fast,
    this.enableHaptic = true,
    this.hapticType,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleFactor;
  final Duration duration;
  final bool enableHaptic;
  final HapticFeedback? hapticType;

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
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

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Slide fade transition for page routes
class SlideFadeRoute<T> extends PageRouteBuilder<T> {

  SlideFadeRoute({
    required this.page,
    this.duration = GymBroAnimations.normal,
    this.begin = const Offset(1.0, 0.0),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideTween = Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: GymBroAnimations.smoothCurve,
            ));

            final fadeTween = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            ));

            return SlideTransition(
              position: slideTween,
              child: FadeTransition(
                opacity: fadeTween,
                child: child,
              ),
            );
          },
        );
  final Widget page;
  final Duration duration;
  final Offset begin;
}

/// Hero animation wrapper with automatic tag
class HeroWrapper extends StatelessWidget {

  const HeroWrapper({
    super.key,
    required this.child,
    required this.tag,
    this.enabled = true,
  });
  final Widget child;
  final String tag;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// Staggered animation list
class StaggeredList extends StatefulWidget {

  const StaggeredList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 50),
    this.animationDuration = GymBroAnimations.normal,
    this.direction = Axis.vertical,
  });
  final List<Widget> children;
  final Duration itemDelay;
  final Duration animationDuration;
  final Axis direction;

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _createAnimationControllers();
    _startAnimations();
  }

  void _createAnimationControllers() {
    for (int i = 0; i < widget.children.length; i++) {
      _controllers.add(
        AnimationController(
          duration: widget.animationDuration,
          vsync: this,
        ),
      );
    }
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(widget.itemDelay);
      if (mounted) {
        unawaited(_controllers[i].forward());
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.vertical
        ? Column(
            children: List.generate(
              widget.children.length,
              (index) => FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controllers[index],
                  curve: Curves.easeOut,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _controllers[index],
                    curve: Curves.easeOut,
                  )),
                  child: widget.children[index],
                ),
              ),
            ),
          )
        : Row(
            children: List.generate(
              widget.children.length,
              (index) => FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controllers[index],
                  curve: Curves.easeOut,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.2, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _controllers[index],
                    curve: Curves.easeOut,
                  )),
                  child: widget.children[index],
                ),
              ),
            ),
          );
  }
}

/// Animated counter for numbers
class AnimatedCounter extends StatelessWidget {

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = GymBroAnimations.normal,
    this.style,
    this.prefix,
    this.suffix,
  });
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: value.toDouble(),
      ),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          '${prefix ?? ''}${value.toInt()}${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

/// Pulse animation widget
class PulseAnimation extends StatefulWidget {

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.repeat = true,
  });
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool repeat;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
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
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: widget.child,
      ),
    );
  }
}