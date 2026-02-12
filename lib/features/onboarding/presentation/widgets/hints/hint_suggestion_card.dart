import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Suggestion card hint -- blends with existing app cards.
///
/// A flat card with an icon circle, title, description, a CTA TextButton,
/// and a discreet close button. Animates in with fade over 600ms.
///
/// Usage:
/// ```dart
/// HintSuggestionCard(
///   hintId: 'discover_superset',
///   hint: HintRegistry.discoverSuperset,
///   icon: AppIcons.merge,
///   title: context.l10n.hintDiscoverSupersetTitle,
///   description: context.l10n.hintDiscoverSupersetDesc,
///   ctaLabel: context.l10n.hintDiscoverSupersetCta,
///   onCtaTap: () => navigateToSuperset(),
/// )
/// ```
class HintSuggestionCard extends ConsumerStatefulWidget {
  const HintSuggestionCard({
    super.key,
    required this.hintId,
    required this.hint,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCtaTap,
    this.onDismiss,
    this.autoTimeout,
  });

  /// Unique identifier for this hint instance.
  final String hintId;

  /// Configuration from HintRegistry.
  final HintConfig hint;

  /// Leading icon displayed in a circle.
  final IconData icon;

  /// Card title.
  final String title;

  /// Card description.
  final String description;

  /// Optional CTA button label.
  final String? ctaLabel;

  /// Called when CTA button is tapped.
  final VoidCallback? onCtaTap;

  /// Called when the card is dismissed.
  final VoidCallback? onDismiss;

  /// Override auto-dismiss duration. Falls back to [hint.autoTimeout].
  final Duration? autoTimeout;

  @override
  ConsumerState<HintSuggestionCard> createState() =>
      _HintSuggestionCardState();
}

class _HintSuggestionCardState extends ConsumerState<HintSuggestionCard>
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
    return Semantics(
      label: '${widget.title}. ${widget.description}',
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            border: Border.all(color: context.colors.outlineVariant),
            borderRadius: AppBorderRadius.mdRadius,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
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
              const SizedBox(width: AppSpacing.sm),
              // Title + Description + CTA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    if (widget.ctaLabel != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      GestureDetector(
                        onTap: () {
                          widget.onCtaTap?.call();
                          _dismiss();
                        },
                        child: Text(
                          widget.ctaLabel!,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
                    size: AppIconSize.tiny,
                    color: context.colors.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
