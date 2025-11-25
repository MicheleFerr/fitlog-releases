import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/domain/enums/feedback_tier.dart';
import 'package:gymbro_flutter_new/shared/domain/enums/haptic_feedback_style.dart';
import 'package:gymbro_flutter_new/shared/domain/enums/visual_feedback_style.dart';
import 'package:gymbro_flutter_new/shared/domain/models/feedback_config.dart';

/// Interactive element with unified tap feedback system
///
/// **Core Responsibilities**:
/// - Manages UN AnimationController (source of truth)
/// - Synchronizes scale animation
/// - Triggers haptic feedback
/// - Exposes Animation\<double\> via builder pattern
///
/// **Pattern**: Builder pattern shares Animation with child widgets
/// (e.g., ExpandingStripContainer) for frame-perfect synchronization.
///
/// **Usage**:
/// ```dart
/// InteractiveElement(
///   feedbackConfig: FeedbackConfig.high(),
///   visualStyle: VisualFeedbackStyle.expandingStrip,
///   onTap: () => _action(),
///   builder: (context, animation) {
///     return ExpandingStripContainer(
///       animation: animation,  // ← Shared animation
///       stripColor: context.colors.primary,
///       child: CardContent(),
///     );
///   },
/// )
/// ```
class InteractiveElement extends StatefulWidget {
  const InteractiveElement({
    super.key,
    required this.builder,
    this.onTap,
    this.feedbackConfig = const FeedbackConfig(
      baseTier: FeedbackTier.standard,
    ),
    this.enabled = true,
    this.visualStyle = VisualFeedbackStyle.scaleOnly,
  });

  /// Builder that receives Animation\<double\> for synchronization
  ///
  /// The animation parameter is the AnimationController, allowing
  /// child widgets (e.g., ExpandingStripContainer) to derive
  /// their own animations from the same source.
  final Widget Function(BuildContext context, Animation<double> animation)
      builder;

  /// Callback when tap completes (onTapUp)
  final VoidCallback? onTap;

  /// Feedback configuration (tier + overrides)
  final FeedbackConfig feedbackConfig;

  /// Whether the element is interactive
  final bool enabled;

  /// Visual feedback style (determines widget tree)
  final VisualFeedbackStyle visualStyle;

  @override
  State<InteractiveElement> createState() => _InteractiveElementState();
}

class _InteractiveElementState extends State<InteractiveElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Create UN AnimationController (source of truth)
    _controller = AnimationController(
      duration: widget.feedbackConfig.duration,
      vsync: this, // SingleTickerProviderStateMixin
    );

    // Create scale animation (Tween + CurvedAnimation)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.feedbackConfig.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(InteractiveElement oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller duration if feedbackConfig changed
    if (oldWidget.feedbackConfig.duration != widget.feedbackConfig.duration) {
      _controller.duration = widget.feedbackConfig.duration;
    }

    // Recreate scale animation if scaleFactor changed
    if (oldWidget.feedbackConfig.scaleFactor !=
        widget.feedbackConfig.scaleFactor) {
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.feedbackConfig.scaleFactor,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================
  // Gesture Handlers
  // ============================================

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;

    // 1. Trigger haptic BEFORE animation (instant feedback)
    if (widget.feedbackConfig.hapticStyle != null) {
      widget.feedbackConfig.hapticStyle!.trigger();
    }

    // 2. Start scale animation
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;

    // Animation is already forwarded, don't repeat
    // Callback happens here, after visual feedback
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;

    // Abort animation if user drags outside
    _controller.reverse();
  }

  // ============================================
  // Build
  // ============================================

  @override
  Widget build(BuildContext context) {
    // Check accessibility: reduce motion
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    if (disableAnimations && _controller.duration != Duration.zero) {
      _controller.duration = Duration.zero; // Instant feedback
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, _) => Transform.scale(
          scale: _scaleAnimation.value,
          // ✅ CRITICAL: Pass controller as Animation<double>
          // This allows child widgets (e.g., ExpandingStripContainer)
          // to derive their own animations from the same source
          child: widget.builder(context, _controller),
        ),
      ),
    );
  }
}
