/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: data_export
/// 🔧 Type: widget
/// 📱 Platform: Universal
///
/// GDPR Article 20 - Right to Data Portability
/// Bottom sheet for configuring and starting data export
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;

import 'package:gymbro_flutter_new/features/data_export/domain/entities/export_data.dart';
import 'package:gymbro_flutter_new/features/data_export/presentation/providers/data_export_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Bottom sheet for GDPR data export
///
/// Features:
/// - Category selection (workouts, templates, measurements, etc.)
/// - Format selection (JSON, CSV, ZIP)
/// - Real-time progress indicator
/// - Share/save exported file
class DataExportSheet extends ConsumerStatefulWidget {
  const DataExportSheet({super.key});

  @override
  ConsumerState<DataExportSheet> createState() => _DataExportSheetState();
}

class _DataExportSheetState extends ConsumerState<DataExportSheet> {
  final Set<ExportCategory> _selectedCategories = {...ExportCategory.values};
  ExportFormat _selectedFormat = ExportFormat.zip;

  @override
  Widget build(BuildContext context) {
    final exportState = ref.watch(dataExportProvider);
    final canExport = ref.watch(canExportProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: exportState.isExporting
            ? _buildExportProgress(context, exportState)
            : _buildExportConfig(context, canExport),
      ),
    );
  }

  Widget _buildExportConfig(BuildContext context, bool canExport) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            // GDPR Info
            _buildGdprInfo(context),
            const SizedBox(height: 24),

            // Category selection
            _buildCategorySelection(context),
            const SizedBox(height: 24),

            // Format selection
            _buildFormatSelection(context),
            const SizedBox(height: 24),

            // Export button
            _buildExportButton(context, canExport),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            AppIcons.download,
            color: context.colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.exportData,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                context.l10n.exportDataDescription,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGdprInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(AppIcons.info, color: context.colors.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.gdprDataPortability,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.gdprDataPortabilityDescription,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.exportCategories,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedCategories.length ==
                      ExportCategory.values.length) {
                    _selectedCategories.clear();
                  } else {
                    _selectedCategories.addAll(ExportCategory.values);
                  }
                });
              },
              child: Text(
                _selectedCategories.length == ExportCategory.values.length
                    ? context.l10n.deselectAll
                    : context.l10n.selectAll,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExportCategory.values.map((category) {
            return FilterChip(
              selected: _selectedCategories.contains(category),
              label: Text(_getCategoryLabel(context, category)),
              avatar: Icon(_getCategoryIcon(category), size: 18),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFormatSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.exportFormat,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ExportFormat>(
          segments: [
            ButtonSegment(
              value: ExportFormat.zip,
              label: Text(context.l10n.formatZip),
              icon: const Icon(AppIcons.archive),
            ),
            ButtonSegment(
              value: ExportFormat.json,
              label: Text(context.l10n.formatJson),
              icon: const Icon(AppIcons.code),
            ),
            ButtonSegment(
              value: ExportFormat.csv,
              label: Text(context.l10n.formatCsv),
              icon: const Icon(AppIcons.tableChart),
            ),
          ],
          selected: {_selectedFormat},
          onSelectionChanged: (selection) {
            setState(() {
              _selectedFormat = selection.first;
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          _getFormatDescription(context, _selectedFormat),
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context, bool canExport) {
    final isEnabled = canExport && _selectedCategories.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isEnabled ? _startExport : null,
        icon: const Icon(AppIcons.download),
        label: Text(context.l10n.startExport),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildExportProgress(BuildContext context, DataExportState state) {
    final progress = state.progress;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 32),

          // Progress indicator
          if (progress.status == ExportStatus.completed) ...[
            _buildExportComplete(context, progress),
          ] else if (progress.status == ExportStatus.failed) ...[
            _buildExportFailed(context, progress),
          ] else ...[
            _buildExportInProgress(context, progress),
          ],
        ],
      ),
    );
  }

  Widget _buildExportInProgress(BuildContext context, ExportProgress progress) {
    return Column(
      children: [
        const LoadingIndicator(size: 64),
        const SizedBox(height: 24),
        Text(
          progress.currentStep ?? context.l10n.exporting,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress.progress,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress.progress * 100).toInt()}%',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        // Item counts
        if (progress.itemCounts.isNotEmpty) ...[
          _buildItemCounts(context, progress.itemCounts),
        ],
        const SizedBox(height: 24),
        // Cancel button
        OutlinedButton(
          onPressed: () {
            ref.read(dataExportProvider.notifier).cancelExport();
          },
          child: Text(context.l10n.cancel),
        ),
      ],
    );
  }

  Widget _buildItemCounts(
    BuildContext context,
    Map<ExportCategory, int> counts,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: counts.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(entry.key),
                  size: 16,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  _getCategoryLabel(context, entry.key),
                  style: context.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '${entry.value}',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExportComplete(BuildContext context, ExportProgress progress) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            AppIcons.checkCircle,
            size: 48,
            color: context.colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.exportCompleted,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.exportCompletedDescription,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Item counts summary
        if (progress.itemCounts.isNotEmpty) ...[
          _buildItemCounts(context, progress.itemCounts),
          const SizedBox(height: 24),
        ],
        // Share button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _shareExport(context, progress.exportFilePath!),
            icon: const Icon(AppIcons.share),
            label: Text(context.l10n.shareExport),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Done button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              ref.read(dataExportProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: Text(context.l10n.done),
          ),
        ),
      ],
    );
  }

  Widget _buildExportFailed(BuildContext context, ExportProgress progress) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            AppIcons.error,
            size: 48,
            color: context.colors.onErrorContainer,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.exportFailed,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          progress.errorMessage ?? context.l10n.exportFailedGeneric,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.error,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Retry button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _startExport,
            icon: const Icon(AppIcons.refresh),
            label: Text(context.l10n.retry),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Close button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              ref.read(dataExportProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: Text(context.l10n.close),
          ),
        ),
      ],
    );
  }

  void _startExport() {
    final request = ExportRequest(
      categories: _selectedCategories,
      format: _selectedFormat,
    );
    ref.read(dataExportProvider.notifier).startExport(request);
  }

  Future<void> _shareExport(BuildContext context, String filePath) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          subject: context.l10n.exportEmailSubject,
          text: context.l10n.exportEmailBody,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, context.l10n.exportShareFailed);
      }
    }
  }

  String _getCategoryLabel(BuildContext context, ExportCategory category) {
    return switch (category) {
      ExportCategory.workoutHistory => context.l10n.exportCategoryWorkouts,
      ExportCategory.templates => context.l10n.exportCategoryTemplates,
      ExportCategory.customExercises => context.l10n.exportCategoryExercises,
      ExportCategory.bodyMeasurements =>
        context.l10n.exportCategoryMeasurements,
      ExportCategory.progressPhotos => context.l10n.exportCategoryPhotos,
      ExportCategory.personalRecords => context.l10n.exportCategoryRecords,
      ExportCategory.settings => context.l10n.exportCategorySettings,
      ExportCategory.achievements => context.l10n.exportCategoryAchievements,
    };
  }

  IconData _getCategoryIcon(ExportCategory category) {
    return switch (category) {
      ExportCategory.workoutHistory => AppIcons.workout,
      ExportCategory.templates => AppIcons.template,
      ExportCategory.customExercises => AppIcons.exercise,
      ExportCategory.bodyMeasurements => AppIcons.bodyMeasurements,
      ExportCategory.progressPhotos => AppIcons.photoLibrary,
      ExportCategory.personalRecords => AppIcons.trophy,
      ExportCategory.settings => AppIcons.settings,
      ExportCategory.achievements => AppIcons.star,
    };
  }

  String _getFormatDescription(BuildContext context, ExportFormat format) {
    return switch (format) {
      ExportFormat.zip => context.l10n.formatZipDescription,
      ExportFormat.json => context.l10n.formatJsonDescription,
      ExportFormat.csv => context.l10n.formatCsvDescription,
    };
  }
}
