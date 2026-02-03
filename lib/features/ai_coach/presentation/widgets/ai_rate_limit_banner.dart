/// AI Rate Limit Banner Widget
///
/// Warning banner shown when approaching daily message limit.
/// Displays at 80% (warning) and 95% (critical) quota.
///
/// **Layer**: Presentation - Widget
/// **Feature**: AI Coach
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Rate limit warning banner
class AIRateLimitBanner extends StatelessWidget {
  const AIRateLimitBanner({
    super.key,
    required this.message,
    this.isCritical = false,
  });

  final String message;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isCritical
            ? context.colors.errorContainer
            : context.colors.warningContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              isCritical ? AppIcons.error : AppIcons.warning,
              color: isCritical
                  ? context.colors.onErrorContainer
                  : context.colors.onWarningContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodySmall?.copyWith(
                  color: isCritical
                      ? context.colors.onErrorContainer
                      : context.colors.onWarningContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
