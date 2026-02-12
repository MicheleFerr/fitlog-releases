import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Inline subtle text hint inspired by Apple TipKit inline.
///
/// Displays a lightweight message near the action area. The accent portion
/// is shown in primary color, the rest in a muted grey.
/// Auto-dismisses after [HintConfig.autoTimeout] or on [onDismiss].
///
/// Usage:
/// ```dart
/// HintSubtleText(
///   hintId: 'tap_complete_set',
///   hint: HintRegistry.tapCompleteSet,
///   message: context.l10n.hintTapCompleteSet,
///   accent: context.l10n.hintTapCompleteSetAccent,
/// )
/// ```
class HintSubtleText extends ConsumerStatefulWidget {
  const HintSubtleText({
    super.key,
    required this.hintId,
    required this.hint,
    required this.message,
    this.accent,
    this.onDismiss,
    this.autoTimeout,
  });

  /// Unique identifier for this hint instance.
  final String hintId;

  /// Configuration from HintRegistry.
  final HintConfig hint;

  /// Full hint message text (from context.l10n).
  final String message;

  /// Optional accented portion to highlight in primary color.
  final String? accent;

  /// Called when the hint is dismissed.
  final VoidCallback? onDismiss;

  /// Override auto-dismiss duration. Falls back to [hint.autoTimeout].
  final Duration? autoTimeout;

  @override
  ConsumerState<HintSubtleText> createState() => _HintSubtleTextState();
}

class _HintSubtleTextState extends ConsumerState<HintSubtleText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    _controller = AnimationController(
      vsync: this,
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Notify service that hint is shown
    ref.read(hintActionsProvider.notifier).showHint(widget.hint);

    _controller.forward();

    // Auto-dismiss after timeout
    final timeout = widget.autoTimeout ?? widget.hint.autoTimeout;
    _autoTimer = Timer(timeout, () {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    _autoTimer?.cancel();
    _controller.reverse().then((_) {
      if (!mounted) return;
      final actions = ref.read(hintActionsProvider.notifier);
      if (widget.hint.permanent) {
        actions.completeHint(widget.hint.hintId);
      } else {
        actions.dismissHint(widget.hint.hintId);
      }
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.labelSmall;

    return Semantics(
      label: widget.message,
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
