import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Soft pulse wrapper - adds a pulsing border around the child widget.
///
/// Border: primary color with alpha oscillating 0 -> 0.4 -> 0.
/// Scale: 1.0 -> 1.06 -> 1.0 over 2000ms cycle.
///
/// Pulse stops permanently on first tap on the child.
/// Respects [MediaQuery.disableAnimations].
///
/// Usage:
/// ```dart
/// HintSoftPulse(
///   hint: HintRegistry.longPressFabMenu,
///   child: FloatingActionButton(...),
/// )
/// ```
class HintSoftPulse extends ConsumerStatefulWidget {
  const HintSoftPulse({
    super.key,
    required this.hint,
    required this.child,
    this.onDismissed,
  });

  final HintConfig hint;
  final Widget child;

  /// Called when the pulse is dismissed by tapping.
  final VoidCallback? onDismissed;

  @override
  ConsumerState<HintSoftPulse> createState() => _HintSoftPulseState();
}

class _HintSoftPulseState extends ConsumerState<HintSoftPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _scaleAnimation;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      _controller = AnimationController(
        vsync: this,
        duration: Duration.zero,
      );
      _pulseAnimation = const AlwaysStoppedAnimation(0.0);
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
      return;
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.stop();

    final actions = ref.read(hintActionsProvider.notifier);
    if (widget.hint.permanent) {
      actions.completeHint(widget.hint.hintId);
    } else {
      actions.dismissHint(widget.hint.hintId);
    }
    widget.onDismissed?.call();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _dismiss,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.primary.withValues(
                    alpha: _pulseAnimation.value,
                  ),
                  width: 2,
                ),
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
