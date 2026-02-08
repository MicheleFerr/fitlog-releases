/// Empty state widget shown when user has no templates
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class EmptyTemplatesState extends StatelessWidget {
  const EmptyTemplatesState({super.key, required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: SemanticIcon(
              icon: AppIcons.workout,
              semanticLabel: l10n.workout,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.noTemplatesYet,
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.createFirstTemplate,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onCreateTap,
            icon: SemanticIcon(
              icon: AppIcons.add,
              semanticLabel: l10n.createTemplate,
            ),
            label: Text(l10n.createTemplate),
          ),
        ],
      ),
    );
  }
}
