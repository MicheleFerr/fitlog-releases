library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.savingsLabel,
    super.key,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final String? savingsLabel;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? context.colors.primary
        : context.colors.outline.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.05)
              : context.colors.surface,
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Plan info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _periodTitle(context),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (savingsLabel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            savingsLabel!,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _periodSubtitle(context),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Text(
              plan.priceString,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _periodTitle(BuildContext context) => switch (plan.period) {
    SubscriptionPeriod.monthly => context.l10n.perMonth,
    SubscriptionPeriod.yearly => context.l10n.perYear,
    SubscriptionPeriod.lifetime => context.l10n.oneTimePurchase,
  };

  String _periodSubtitle(BuildContext context) => switch (plan.period) {
    SubscriptionPeriod.monthly => context.l10n.perMonth,
    SubscriptionPeriod.yearly => context.l10n.perYear,
    SubscriptionPeriod.lifetime => context.l10n.oneTimePurchase,
  };
}
