import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';

/// Peek animation hint inspired by iOS Mail swipe peek.
///
/// Wraps a child and translates it horizontally by [peekDistance] to reveal
/// content underneath. Purely visual -- no text.
///
/// Single direction: 800ms delay -> 400ms slide -> 600ms pause -> 400ms return.
///
/// Bidirectional (when [peekDistanceSecond] is set):
/// 600ms delay -> 350ms left -> 450ms hold -> 350ms return ->
/// 200ms pause -> 350ms right -> 450ms hold -> 350ms return.
///
/// Usage:
/// ```dart
/// HintPeek(
///   hintId: 'swipe_template_actions',
///   hint: HintRegistry.swipeTemplateActions,
///   revealChild: Row(children: [EditButton(), DeleteButton()]),
///   child: TemplateCard(...),
/// )
/// ```
class HintPeek extends ConsumerStatefulWidget {
  const HintPeek({
    super.key,
    required this.hintId,
    required this.hint,
    required this.child,
    this.revealChild,
    this.revealChildStart,
    this.peekDistance = -48.0,
    this.peekDistanceSecond,
    this.onDismiss,
    this.autoTimeout,
  });

  /// Unique identifier for this hint instance.
  final String hintId;

  /// Configuration from HintRegistry.
  final HintConfig hint;

  /// The main child widget to animate.
  final Widget child;

  /// Optional widget revealed on the end side (right) during left peek.
  final Widget? revealChild;

  /// Optional widget revealed on the start side (left) during right peek.
  final Widget? revealChildStart;

  /// How far to peek (negative = left). Default: -48px.
  final double peekDistance;

  /// Second peek distance (positive = right). When set, enables bidirectional peek.
  final double? peekDistanceSecond;

  /// Called when the peek animation completes.
  final VoidCallback? onDismiss;

  /// Override auto-dismiss duration. Falls back to [hint.autoTimeout].
  final Duration? autoTimeout;

  @override
  ConsumerState<HintPeek> createState() => _HintPeekState();
}

class _HintPeekState extends ConsumerState<HintPeek>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _translateAnimation;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      _controller = AnimationController(
        vsync: this,
        duration: Duration.zero,
      );
      _translateAnimation = const AlwaysStoppedAnimation(0.0);
      _markCompleted();
      return;
    }

    final isBidirectional = widget.peekDistanceSecond != null;

    if (isBidirectional) {
      // Bidirectional: 600+350+450+350+200+350+450+350 = 3100ms
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3100),
      );

      _translateAnimation = TweenSequence<double>([
        // Phase 1: Wait (600ms)
        TweenSequenceItem(tween: ConstantTween(0.0), weight: 600),
        // Phase 2: Slide left (350ms)
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: widget.peekDistance)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 350,
        ),
        // Phase 3: Hold at left (450ms)
        TweenSequenceItem(
          tween: ConstantTween(widget.peekDistance),
          weight: 450,
        ),
        // Phase 4: Return to center (350ms)
        TweenSequenceItem(
          tween: Tween(begin: widget.peekDistance, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 350,
        ),
        // Phase 5: Pause at center (200ms)
        TweenSequenceItem(tween: ConstantTween(0.0), weight: 200),
        // Phase 6: Slide right (350ms)
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: widget.peekDistanceSecond!)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 350,
        ),
        // Phase 7: Hold at right (450ms)
        TweenSequenceItem(
          tween: ConstantTween(widget.peekDistanceSecond!),
          weight: 450,
        ),
        // Phase 8: Return to center (350ms)
        TweenSequenceItem(
          tween: Tween(begin: widget.peekDistanceSecond!, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 350,
        ),
      ]).animate(_controller);
    } else {
      // Single direction: 800+400+600+400 = 2200ms
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2200),
      );

      _translateAnimation = TweenSequence<double>([
        // Phase 1: Wait (800ms)
        TweenSequenceItem(tween: ConstantTween(0.0), weight: 800),
        // Phase 2: Slide (400ms)
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: widget.peekDistance)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 400,
        ),
        // Phase 3: Pause at peek position (600ms)
        TweenSequenceItem(
          tween: ConstantTween(widget.peekDistance),
          weight: 600,
        ),
        // Phase 4: Return to original (400ms)
        TweenSequenceItem(
          tween: Tween(begin: widget.peekDistance, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 400,
        ),
      ]).animate(_controller);
    }

    // Notify service that hint is shown
    ref.read(hintActionsProvider.notifier).showHint(widget.hint);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_completed) {
        _markCompleted();
      }
    });

    _controller.forward();
  }

  void _markCompleted() {
    _completed = true;
    if (!mounted) return;
    final actions = ref.read(hintActionsProvider.notifier);
    if (widget.hint.permanent) {
      actions.completeHint(widget.hint.hintId);
    } else {
      actions.dismissHint(widget.hint.hintId);
    }
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Semantics(
      label: 'Swipe hint',
      child: AnimatedBuilder(
        animation: _translateAnimation,
        builder: (context, child) {
          final dx = _translateAnimation.value;
          // Reveal end (right) when sliding left (dx < 0)
          final revealEndOpacity = widget.revealChild != null
              ? (dx / widget.peekDistance).clamp(0.0, 1.0)
              : 0.0;
          // Reveal start (left) when sliding right (dx > 0)
          final revealStartOpacity =
              widget.revealChildStart != null && widget.peekDistanceSecond != null
                  ? (dx / widget.peekDistanceSecond!).clamp(0.0, 1.0)
                  : 0.0;

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Opaque background to prevent bleed-through
                Positioned.fill(
                  child: ColoredBox(color: scaffoldBg),
                ),
                // Reveal content on end side (right) - only visible during left peek
                if (widget.revealChild != null && revealEndOpacity > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: revealEndOpacity,
                      child: widget.revealChild!,
                    ),
                  ),
                // Reveal content on start side (left) - only visible during right peek
                if (widget.revealChildStart != null && revealStartOpacity > 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: revealStartOpacity,
                      child: widget.revealChildStart!,
                    ),
                  ),
                // Animated main child
                Transform.translate(
                  offset: Offset(dx, 0),
                  child: child,
                ),
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
