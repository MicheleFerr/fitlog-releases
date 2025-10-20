/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: widget
/// 🌍 Localization: ✅ Uses AppLocalizations
/// 🎨 Theme: ✅ Uses ColorScheme
/// 📱 Platform: Universal
///
/// Progress dialog shown during JSON template import process
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Dialog showing import progress with phases and steps
class ImportProgressDialog extends StatelessWidget {
  const ImportProgressDialog({
    super.key,
    this.progress = 0.0,
    this.currentPhase = '',
    this.currentStep = '',
    this.isCompleted = false,
    this.totalTemplates = 0,
    this.processedTemplates = 0,
    this.onCancel,
  });

  /// Progress value from 0.0 to 1.0
  final double progress;

  /// Current phase of import (e.g., "Parsing JSON", "Matching Exercises")
  final String currentPhase;

  /// Current step details (e.g., "Processing template 2 of 5")
  final String currentStep;

  /// Whether import is completed
  final bool isCompleted;

  /// Total number of templates to import
  final int totalTemplates;

  /// Number of templates processed so far
  final int processedTemplates;

  /// Callback when user cancels import
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing with back button
      child: Dialog(
        backgroundColor: context.colors.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon or loading indicator
              if (isCompleted)
                Icon(
                  Icons.check_circle,
                  color: context.colors.primary,
                  size: 64,
                )
              else
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                    strokeWidth: 6,
                    color: context.colors.primary,
                    backgroundColor: context.colors.surfaceContainerHighest,
                  ),
                ),

              const SizedBox(height: 24),

              // Title
              Text(
                isCompleted ? l10n.importCompleted : l10n.importing,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              // Current phase
              if (currentPhase.isNotEmpty && !isCompleted)
                Text(
                  currentPhase,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 8),

              // Current step details
              if (currentStep.isNotEmpty && !isCompleted)
                Text(
                  currentStep,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

              // Progress indicator
              if (totalTemplates > 0 && !isCompleted) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  color: context.colors.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '$processedTemplates / $totalTemplates',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],

              // Completed message
              if (isCompleted && totalTemplates > 0) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.templatesImportedSuccessfully(processedTemplates),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Actions
              if (!isCompleted && onCancel != null) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: onCancel,
                  child: Text(l10n.cancel),
                ),
              ],

              if (isCompleted) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.done),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows import progress dialog
Future<bool?> showImportProgressDialog({
  required BuildContext context,
  double progress = 0.0,
  String currentPhase = '',
  String currentStep = '',
  bool isCompleted = false,
  int totalTemplates = 0,
  int processedTemplates = 0,
  VoidCallback? onCancel,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ImportProgressDialog(
      progress: progress,
      currentPhase: currentPhase,
      currentStep: currentStep,
      isCompleted: isCompleted,
      totalTemplates: totalTemplates,
      processedTemplates: processedTemplates,
      onCancel: onCancel,
    ),
  );
}
