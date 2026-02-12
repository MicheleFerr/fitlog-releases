import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Micro tip hint - minimal tooltip-like element.
///
/// Nearly invisible background with small icon, text, and discreet X to close.
/// Animates in with fade + slide from bottom over 500ms.
///
/// Usage:
/// ```dart
/// HintMicroTip(
///   hint: HintRegistry.longPressSkipTimer,
///   message: context.l10n.hint_long_press_skip_timer,
///   icon: AppIcons.touchApp,
/// )
/// ```
class HintMicroTip extends ConsumerStatefulWidget {
  const HintMicroTip({
    super.key,
    required this.hint,
    required this.message,
    this.icon,
    this.onDismissed,
  });

  final HintConfig hint;

  /// Tip message text (from context.l10n).
  final String message;

  /// Optional leading icon. Defaults to [AppIcons.lightbulbOutline].
  final IconData? icon;

  /// Called when the tip is dismissed.
  final VoidCallback? onDismissed;

  @override
  ConsumerState<HintMicroTip> createState() => _HintMicroTipState();
}

class _HintMicroTipState extends ConsumerState<HintMicroTip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

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
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

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
      label: widget.message,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon ?? AppIcons.lightbulbOutline,
                  size: AppIconSize.small,
                  color: context.colors.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
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
                      color: context.colors.onSurfaceVariant,
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
