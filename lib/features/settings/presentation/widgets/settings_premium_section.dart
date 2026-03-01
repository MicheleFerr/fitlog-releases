import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_shared_helpers.dart';

/// Premium CTA settings section: shows subscription status or upgrade prompt.
class SettingsPremiumSection extends ConsumerWidget {
  const SettingsPremiumSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final isActive = statusAsync.value?.isActive ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.star,
                  semanticLabel: context.l10n.gymbroPremium,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.gymbroPremium,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isActive
                            ? context.l10n.subscriptionLifetime
                            : context.l10n.allFeaturesFreeInBeta,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Premium features tile
            buildSettingTile(
              context,
              title: isActive
                  ? context.l10n.manageSubscription
                  : context.l10n.betaEarlyAdopterTitle,
              subtitle: isActive
                  ? context.l10n.subscriptionLifetime
                  : context.l10n.betaEarlyAdopterMessage,
              leading: SemanticIcon(
                icon: isActive ? AppIcons.complete : AppIcons.unlock,
                semanticLabel: isActive
                    ? context.l10n.manageSubscription
                    : context.l10n.betaEarlyAdopterTitle,
              ),
              onTap: () => context.pushNamed('premium'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.viewPlans,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
