import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Contextual chip hint - pill-shaped badge near target element.
///
/// Tap to dismiss. Animates in with fade + scale (0.95 -> 1.0) over 400ms.
///
/// Usage:
/// ```dart
/// HintContextualChip(
///   hint: HintRegistry.swipeMiniBar,
///   label: context.l10n.hint_swipe_mini_bar,
/// )
/// ```
class HintContextualChip extends ConsumerStatefulWidget {
  const HintContextualChip({
    super.key,
    required this.hint,
    required this.label,
    this.onDismissed,
  });

  final HintConfig hint;

  /// Chip text (from context.l10n).
  final String label;

  /// Called when the chip is dismissed.
  final VoidCallback? onDismissed;

  @override
  ConsumerState<HintContextualChip> createState() =>
      _HintContextualChipState();
}

class _HintContextualChipState extends ConsumerState<HintContextualChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    _controller = AnimationController(
      vsync: this,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto-dismiss after timeout
    Future.delayed(widget.hint.autoTimeout, () {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (!mounted) return;
      final actions = ref.read(hintActionsProvider.notifier);
      if (widget.hint.permanent) {
        actions.completeHint(widget.hint.hintId);
      } else {
        actions.dismissHint(widget.hint.hintId);
      }
      widget.onDismissed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.15),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
