/// Coach Settings Screen
///
/// Settings for coach mode including:
/// - PDF Branding customization
/// - Template folder management
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_branding.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/coach_branding_provider.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/widgets/branding_editor_section.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/widgets/template_folders_section.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Settings screen for coach-specific features.
class CoachSettingsScreen extends ConsumerWidget {
  const CoachSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandingAsync = ref.watch(coachBrandingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.coachSettings)),
      body: brandingAsync.when(
        data: (branding) => _buildContent(context, ref, branding),
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, stack) => _buildErrorState(context, err),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    CoachBranding? branding,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PDF Branding Section
          _SectionHeader(
            icon: AppIcons.palette,
            title: context.l10n.pdfBranding,
            subtitle: context.l10n.customizePdfBranding,
          ),
          const SizedBox(height: AppSpacing.md),
          BrandingEditorSection(
            branding: branding,
            onSave: (updatedBranding) async {
              await HapticFeedback.mediumImpact();
              await ref
                  .read(coachBrandingProvider.notifier)
                  .saveBranding(updatedBranding);
              if (context.mounted) {
                SnackBarService.showSuccess(
                  context,
                  context.l10n.brandingSaved,
                );
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Template Folders Section
          _SectionHeader(
            icon: AppIcons.folder,
            title: context.l10n.templateFolders,
            subtitle: context.l10n.organizeFolders,
          ),
          const SizedBox(height: AppSpacing.md),
          const TemplateFoldersSection(),
          const SizedBox(height: AppSpacing.xl),

          // Bottom padding for tab bar overlay
          const TabBarBottomPadding(),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.errorOutline, size: 64, color: context.colors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.errorGeneric,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header with icon and titles
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: context.colors.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
