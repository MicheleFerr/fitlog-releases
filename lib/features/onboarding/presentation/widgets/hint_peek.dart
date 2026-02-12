import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';

/// Peek animation hint (similar to iOS Mail swipe peek).
///
/// Wraps the child widget and animates translateX by -48px to reveal
/// hidden swipe actions underneath. Purely visual, no text.
///
/// Timing: 800ms wait -> 400ms slide left -> 600ms pause -> 400ms return.
///
/// Usage:
/// ```dart
/// HintPeek(
///   hint: HintRegistry.swipeTemplateActions,
///   child: TemplateCard(...),
/// )
/// ```
class HintPeek extends ConsumerStatefulWidget {
  const HintPeek({
    super.key,
    required this.hint,
    required this.child,
    this.peekDistance = -48.0,
    this.onCompleted,
  });

  final HintConfig hint;
  final Widget child;

  /// How far to peek (negative = left). Default: -48px.
  final double peekDistance;

  /// Called when the peek animation completes.
  final VoidCallback? onCompleted;

  @override
  ConsumerState<HintPeek> createState() => _HintPeekState();
}

class _HintPeekState extends ConsumerState<HintPeek>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      // Skip animation entirely for reduced motion
      _controller = AnimationController(
        vsync: this,
        duration: Duration.zero,
      );
      _slideAnimation = const AlwaysStoppedAnimation(Offset.zero);
      _markCompleted();
      return;
    }

    // Total: 800ms wait + 400ms slide + 600ms pause + 400ms return = 2200ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Normalize peek distance to fraction of screen width (approx)
    // -48px as fraction offset for SlideTransition
    final peekFraction = widget.peekDistance / 300.0;

    _slideAnimation = TweenSequence<Offset>([
      // Phase 1: Wait (800ms / 2200ms ≈ 0.364)
      TweenSequenceItem(
        tween: ConstantTween(Offset.zero),
        weight: 800,
      ),
      // Phase 2: Slide left (400ms)
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: Offset(peekFraction, 0))
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 400,
      ),
      // Phase 3: Pause at peek position (600ms)
      TweenSequenceItem(
        tween: ConstantTween(Offset(peekFraction, 0)),
        weight: 600,
      ),
      // Phase 4: Return to original (400ms)
      TweenSequenceItem(
        tween: Tween(begin: Offset(peekFraction, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 400,
      ),
    ]).animate(_controller);

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
    widget.onCompleted?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}
