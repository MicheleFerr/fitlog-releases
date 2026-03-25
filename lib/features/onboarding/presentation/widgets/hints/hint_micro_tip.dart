import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Micro tip hint -- small, nearly invisible suggestion.
///
/// Container with very light primary background, icon (optional),
/// text, and a discreet close button. Animates in with fade + slide
/// from bottom over 500ms.
///
/// Usage:
/// ```dart
/// HintMicroTip(
///   hintId: 'tap_workout_name_share',
///   hint: HintRegistry.tapWorkoutNameShare,
///   message: context.l10n.hintTapWorkoutNameShare,
///   icon: AppIcons.share,
/// )
/// ```
class HintMicroTip extends ConsumerStatefulWidget {
  const HintMicroTip({
    super.key,
    required this.hintId,
    required this.hint,
    required this.message,
    this.icon,
    this.onDismiss,
    this.autoTimeout,
  });

  /// Unique identifier for this hint instance.
  final String hintId;

  /// Configuration from HintRegistry.
  final HintConfig hint;

  /// Hint message text (from context.l10n).
  final String message;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the tip is dismissed.
  final VoidCallback? onDismiss;

  /// Override auto-dismiss duration. Falls back to [hint.autoTimeout].
  final Duration? autoTimeout;

  @override
  ConsumerState<HintMicroTip> createState() => _HintMicroTipState();
}

class _HintMicroTipState extends ConsumerState<HintMicroTip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _autoTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    _controller = AnimationController(
      vsync: this,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

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
    if (!_isDismissing) {
      ref.read(discoverabilityHintServiceProvider).markHintDismissed();
    }
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    _isDismissing = true;
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
    return Semantics(
      label: widget.message,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.05),
              borderRadius: AppBorderRadius.smRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: AppIconSize.small,
                    color: context.colors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.message,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _dismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      AppIcons.close,
                      size: AppIconSize.tiny,
                      color: context.colors.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
