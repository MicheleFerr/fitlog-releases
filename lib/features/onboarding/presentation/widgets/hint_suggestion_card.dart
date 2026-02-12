import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Suggestion card hint - styled like other app cards.
///
/// Contains icon in circle, title, description, CTA button, and close X.
/// Animates in with a 600ms fade (slow, elegant).
///
/// Usage:
/// ```dart
/// HintSuggestionCard(
///   hint: HintRegistry.discoverSuperset,
///   icon: AppIcons.superset,
///   title: context.l10n.hint_discover_superset_title,
///   description: context.l10n.hint_discover_superset_desc,
///   ctaLabel: context.l10n.hint_discover_cta,
///   onCtaTap: () => navigateToSuperset(),
/// )
/// ```
class HintSuggestionCard extends ConsumerStatefulWidget {
  const HintSuggestionCard({
    super.key,
    required this.hint,
    required this.icon,
    required this.title,
    required this.description,
    required this.ctaLabel,
    this.onCtaTap,
    this.onDismissed,
  });

  final HintConfig hint;

  /// Leading icon displayed in a circle.
  final IconData icon;

  /// Card title (from context.l10n).
  final String title;

  /// Card description (from context.l10n).
  final String description;

  /// CTA button label (from context.l10n).
  final String ctaLabel;

  /// Called when the CTA button is tapped.
  final VoidCallback? onCtaTap;

  /// Called when the card is dismissed.
  final VoidCallback? onDismissed;

  @override
  ConsumerState<HintSuggestionCard> createState() =>
      _HintSuggestionCardState();
}

class _HintSuggestionCardState extends ConsumerState<HintSuggestionCard>
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

  void _onCtaTap() {
    _dismiss();
    widget.onCtaTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.title}. ${widget.description}',
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            border: Border.all(color: context.colors.outlineVariant),
            borderRadius: AppBorderRadius.mdRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon in circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: AppIconSize.small,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: context.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: _dismiss,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        AppIcons.close,
                        size: AppIconSize.small,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // CTA button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _onCtaTap,
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(widget.ctaLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
