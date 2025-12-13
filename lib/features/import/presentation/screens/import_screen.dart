/// Import Screen
///
/// Main screen for importing workout data from external apps.
///
/// **Flow**:
/// 1. Select source app (Strong, Hevy, etc.)
/// 2. Pick CSV file
/// 3. Preview parsed data
/// 4. Review/adjust exercise mappings
/// 5. Confirm import
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gymbro_flutter_new/features/import/presentation/providers/import_provider.dart';
import 'package:gymbro_flutter_new/features/import/presentation/widgets/import_preview_widget.dart';
import 'package:gymbro_flutter_new/features/import/presentation/widgets/exercise_mapping_widget.dart';
import 'package:gymbro_flutter_new/features/import/presentation/widgets/import_result_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Import screen for importing workout data
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  String _selectedSourceApp = 'strong';
  int _currentStep = 0;

  @override
  void dispose() {
    // Reset import state when leaving screen
    ref.read(importNotifierProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importNotifierProvider);
    final sourceApps = ref.watch(importSourceAppsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.importData),
        actions: [
          if (importState is ImportParsed)
            IconButton(
              icon: const Icon(AppIcons.refresh),
              onPressed: () => ref.read(importNotifierProvider.notifier).reset(),
              tooltip: context.l10n.reset,
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(importState, sourceApps),
      ),
    );
  }

  Widget _buildBody(ImportState state, List<ImportSourceApp> sourceApps) {
    return switch (state) {
      ImportInitial() => _buildSourceSelection(sourceApps),
      ImportParsing() => _buildLoading(context.l10n.parsing),
      ImportParsed(:final result) => _buildParsedView(result),
      ImportExecuting() => _buildLoading(context.l10n.importing),
      ImportCompleted(:final result) => ImportResultWidget(result: result),
      ImportError(:final message) => _buildError(message),
    };
  }

  Widget _buildSourceSelection(List<ImportSourceApp> sourceApps) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Icon(
            AppIcons.download,
            size: 64,
            color: context.colors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.importFromOtherApp,
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.importDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Source app selection
          Text(
            context.l10n.selectSourceApp,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...sourceApps.map((app) => _buildSourceAppTile(app)),

          const SizedBox(height: 32),

          // Pick file button
          FilledButton.icon(
            onPressed: _pickAndParseFile,
            icon: const Icon(AppIcons.uploadFile),
            label: Text(context.l10n.selectCsvFile),
          ),

          const SizedBox(height: 16),

          // Instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.info, size: 20, color: context.colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.howToExport,
                        style: context.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep('1', context.l10n.exportStep1),
                  _buildInstructionStep('2', context.l10n.exportStep2),
                  _buildInstructionStep('3', context.l10n.exportStep3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceAppTile(ImportSourceApp app) {
    final isSelected = _selectedSourceApp == app.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: app.isSupported ? () => setState(() => _selectedSourceApp = app.id) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? context.colors.primary : context.colors.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? context.colors.primaryContainer.withValues(alpha: 0.3)
                : null,
          ),
          child: Row(
            children: [
              // TODO: Add app icons when available
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    app.name[0],
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: context.textTheme.titleMedium,
                    ),
                    Text(
                      app.description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!app.isSupported)
                Chip(
                  label: Text(context.l10n.comingSoon),
                  backgroundColor: context.colors.surfaceContainerHighest,
                )
              else if (isSelected)
                Icon(AppIcons.check, color: context.colors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsedView(result) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < 2) {
          setState(() => _currentStep++);
        } else {
          _executeImport();
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        } else {
          ref.read(importNotifierProvider.notifier).reset();
        }
      },
      steps: [
        Step(
          title: Text(context.l10n.preview),
          content: ImportPreviewWidget(result: result),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text(context.l10n.mapExercises),
          content: ExerciseMappingWidget(result: result),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text(context.l10n.confirm),
          content: _buildConfirmStep(result),
          isActive: _currentStep >= 2,
          state: StepState.indexed,
        ),
      ],
    );
  }

  Widget _buildConfirmStep(result) {
    final unmappedCount = result.unmappedExercises.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.readyToImport,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        _buildSummaryRow(
          context.l10n.workouts,
          '${result.workouts.length}',
        ),
        _buildSummaryRow(
          context.l10n.exercises,
          '${result.autoMappedExercises.length + unmappedCount}',
        ),
        _buildSummaryRow(
          context.l10n.autoMapped,
          '${result.autoMappedExercises.length}',
        ),
        if (unmappedCount > 0)
          _buildSummaryRow(
            context.l10n.unmapped,
            '$unmappedCount',
            isWarning: true,
          ),
        if (result.warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            context.l10n.warnings,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.warning,
            ),
          ),
          ...result.warnings.take(3).map((w) => Text(
                '• $w',
                style: context.textTheme.bodySmall,
              )),
          if (result.warnings.length > 3)
            Text(
              context.l10n.andMoreWarnings(result.warnings.length - 3),
              style: context.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: isWarning ? context.colors.warning : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.error,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.importError,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(importNotifierProvider.notifier).reset(),
              icon: const Icon(AppIcons.refresh),
              label: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndParseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        _showError(context.l10n.couldNotReadFile);
        return;
      }

      final content = String.fromCharCodes(file.bytes!);

      await ref.read(importNotifierProvider.notifier).parseCSV(
            content,
            sourceApp: _selectedSourceApp,
          );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _executeImport() {
    ref.read(importNotifierProvider.notifier).executeImport();
  }

  void _showError(String message) {
    SnackBarService.showError(context, message);
  }
}
