import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Widget to display a banner when Beta Mode is active
class BetaModeBanner extends ConsumerWidget {

  const BetaModeBanner({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final betaModeEnabled = ref.watch(betaModeEnabledProvider);

    if (!betaModeEnabled) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.tertiary,
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
  icon: AppIcons.science,
  semanticLabel: 'Science',
  size: AppIconSize.tiny,
  color: Theme.of(context,
).colorScheme.onTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'BETA MODE - All Premium Features Unlocked',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                SemanticIcon(
  icon: AppIcons.science,
  semanticLabel: 'Science',
  size: AppIconSize.tiny,
  color: Theme.of(context,
).colorScheme.onTertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Small beta indicator for use in cards or lists
class BetaModeIndicator extends ConsumerWidget {
  const BetaModeIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final betaModeEnabled = ref.watch(betaModeEnabledProvider);

    if (!betaModeEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
  icon: AppIcons.science,
  semanticLabel: 'Science',
  size: AppIconSize.tiny,
  color: Theme.of(context,
).colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'BETA',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
