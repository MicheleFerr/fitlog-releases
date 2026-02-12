import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Inline subtle text hint (similar to Apple TipKit inline).
///
/// Displays a lightweight message near the action area. The accent portion
/// is shown in primary color, the rest in a muted grey.
///
/// Auto-dismisses after [HintConfig.autoTimeout] or when user interacts
/// with the target element.
///
/// Usage:
/// ```dart
/// HintSubtleText(
///   hint: HintRegistry.tapCompleteSet,
///   message: context.l10n.hint_tap_complete_set,
///   accent: context.l10n.hint_tap_complete_set_accent,
/// )
/// ```
class HintSubtleText extends ConsumerStatefulWidget {
  const HintSubtleText({
    super.key,
    required this.hint,
    required this.message,
    this.accent,
    this.onDismissed,
  });

  final HintConfig hint;

  /// Full hint message text (from context.l10n).
  final String message;

  /// Optional accented portion to highlight in primary color.
  final String? accent;

  /// Called when the hint is dismissed.
  final VoidCallback? onDismissed;

  @override
  ConsumerState<HintSubtleText> createState() => _HintSubtleTextState();
}

class _HintSubtleTextState extends ConsumerState<HintSubtleText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    _controller = AnimationController(
      vsync: this,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto-dismiss after timeout
    Future.delayed(widget.hint.autoTimeout, () {
      if (mounted) dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dismiss() {
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
    final textStyle = context.textTheme.labelSmall;

    return Semantics(
      label: widget.message,
      hint: widget.accent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _buildText(context, textStyle),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, TextStyle? baseStyle) {
    if (widget.accent == null || !widget.message.contains(widget.accent!)) {
      return Text(
        widget.message,
        style: baseStyle?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      );
    }

    // Split message around accent text
    final parts = widget.message.split(widget.accent!);

    return Text.rich(
      TextSpan(
        children: [
          if (parts.isNotEmpty)
            TextSpan(
              text: parts[0],
              style: baseStyle?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          TextSpan(
            text: widget.accent,
            style: baseStyle?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (parts.length > 1)
            TextSpan(
              text: parts[1],
              style: baseStyle?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
