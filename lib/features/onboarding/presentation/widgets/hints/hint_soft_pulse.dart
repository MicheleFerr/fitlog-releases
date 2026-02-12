import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Soft pulse wrapper -- adds a pulsing border around the child widget.
///
/// Border: primary color with alpha oscillating 0 -> 0.4 -> 0 over 2s cycle.
/// NO scale animation (too invasive), only border opacity.
///
/// Pulse stops permanently on first tap on the child.
/// Respects [MediaQuery.disableAnimations] -- static border with alpha 0.3.
///
/// Usage:
/// ```dart
/// HintSoftPulse(
///   hintId: 'long_press_fab_menu',
///   hint: HintRegistry.longPressFabMenu,
///   child: FloatingActionButton(...),
/// )
/// ```
class HintSoftPulse extends ConsumerStatefulWidget {
  const HintSoftPulse({
    super.key,
    required this.hintId,
    required this.hint,
    required this.child,
    this.borderRadius,
    this.onDismiss,
    this.autoTimeout,
  });

  /// Unique identifier for this hint instance.
  final String hintId;

  /// Configuration from HintRegistry.
  final HintConfig hint;

  /// The child widget to wrap with a pulsing border.
  final Widget child;

  /// Border shape. Defaults to circular (for FAB-like elements).
  final BorderRadius? borderRadius;

  /// Called when the pulse is dismissed by tapping.
  final VoidCallback? onDismiss;

  /// Override auto-dismiss duration. Falls back to [hint.autoTimeout].
  final Duration? autoTimeout;

  @override
  ConsumerState<HintSoftPulse> createState() => _HintSoftPulseState();
}

class _HintSoftPulseState extends ConsumerState<HintSoftPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  bool _dismissed = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();

    _reduceMotion = MediaQuery.of(context).disableAnimations;

    if (_reduceMotion) {
      _controller = AnimationController(
        vsync: this,
        duration: Duration.zero,
      );
      _pulseAnimation = const AlwaysStoppedAnimation(0.3);
      return;
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Only border alpha oscillation, NO scale
    _pulseAnimation = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Notify service that hint is shown
    ref.read(hintActionsProvider.notifier).showHint(widget.hint);

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
    widget.onDismiss?.call();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return widget.child;
    }

    final isCircular = widget.borderRadius == null;

    return Semantics(
      label: 'Interactive element hint',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismiss,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isCircular ? null : widget.borderRadius,
                border: Border.all(
                  color: context.colors.primary.withValues(
                    alpha: _reduceMotion ? 0.3 : _pulseAnimation.value,
                  ),
                  width: 2,
                ),
              ),
              child: child!,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
