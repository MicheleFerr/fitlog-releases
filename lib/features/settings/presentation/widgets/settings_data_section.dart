import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/data_export/presentation/widgets/data_export_sheet.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_shared_helpers.dart';

/// Data & Backup settings section: health sync, import, export (GDPR Art. 20).
class SettingsDataSection extends ConsumerWidget {
  const SettingsDataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  icon: AppIcons.storage,
                  semanticLabel: 'Data',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.dataBackup,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Health Sync Settings
            buildSettingTile(
              context,
              title: context.l10n.healthSyncSettings,
              subtitle: context.l10n.healthSyncSettingsDesc,
              leading: const SemanticIcon(
                icon: AppIcons.favorite,
                semanticLabel: 'Health',
              ),
              onTap: () => context.pushNamed('health-sync'),
            ),

            const Divider(),

            // Import Data from other apps
            buildSettingTile(
              context,
              title: context.l10n.importData,
              subtitle: context.l10n.importFromOtherApp,
              leading: const SemanticIcon(
                icon: AppIcons.download,
                semanticLabel: 'Import',
              ),
              onTap: () => context.pushNamed('import-data'),
            ),

            const Divider(),

            // Export Data (GDPR Art. 20)
            buildSettingTile(
              context,
              title: context.l10n.exportData,
              subtitle: context.l10n.exportDataSubtitle,
              leading: const SemanticIcon(
                icon: AppIcons.upload,
                semanticLabel: 'Export',
              ),
              onTap: () => _showExportDataSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDataSheet(BuildContext context) {
    ModalService.showSheet(
      context,
      isScrollControlled: true,
      builder: (context) => const DataExportSheet(),
    );
  }
}
