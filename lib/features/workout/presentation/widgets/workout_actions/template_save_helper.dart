/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: helper
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS/Android/Universal
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart'
    as wt;
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class TemplateSaveHelper {
  static void showSaveAsTemplateDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return;

    try {
      // Get tier-based template limit
      final tierMaxTemplates = ref.read(maxTemplatesProvider);
      final quotaInfo = await _checkUserQuota(tierMaxTemplates);

      if (!context.mounted) return;

      if (quotaInfo.isExceeded) {
        _showQuotaExceededDialog(context, quotaInfo);
        return;
      }

      _showSaveDialog(context, ref, currentWorkout, quotaInfo);
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(context, e.toString());
    }
  }

  static Future<_QuotaInfo> _checkUserQuota(int tierMaxTemplates) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    int usedTemplates = 0;

    if (userDoc.exists) {
      final data = userDoc.data()!;
      final quotaData = data['templateQuota'] as Map<String, dynamic>?;
      if (quotaData != null) {
        usedTemplates = quotaData['usedPrivateTemplates'] ?? 0;
      }
    }

    return _QuotaInfo(
      usedTemplates: usedTemplates,
      maxTemplates: tierMaxTemplates,
    );
  }

  static void _showQuotaExceededDialog(
    BuildContext context,
    _QuotaInfo quotaInfo,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(
            context,
          ).templateLimitReached(quotaInfo.maxTemplates),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.package,
              semanticLabel: 'Package',
              size: AppIconSize.xxlarge,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(
                context,
              ).templateLimitMessage(quotaInfo.maxTemplates),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).templateLimitSuggestion,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).ok),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium screen
            },
            child: Text(AppLocalizations.of(context).upgrade),
          ),
        ],
      ),
    );
  }

  static void _showSaveDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic currentWorkout,
    _QuotaInfo quotaInfo,
  ) {
    final nameController = TextEditingController(text: currentWorkout.name);
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(AppLocalizations.of(context).saveAsTemplate),
            const Spacer(),
            _buildQuotaIndicator(context, quotaInfo),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (quotaInfo.isNearLimit)
                _buildWarningBanner(context, quotaInfo),
              _buildNameField(nameController, context),
              const SizedBox(height: 16),
              _buildDescriptionField(descriptionController, context),
              const SizedBox(height: 16),
              _buildInfoBanner(context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton.icon(
            onPressed: () => _saveTemplate(
              context,
              ref,
              nameController.text.trim(),
              descriptionController.text.trim(),
              currentWorkout,
            ),
            icon: const SemanticIcon(
              icon: AppIcons.cloudUpload,
              semanticLabel: 'Cloud upload',
            ),
            label: Text(AppLocalizations.of(context).saveToFirebase),
          ),
        ],
      ),
    );
  }

  static Widget _buildQuotaIndicator(
    BuildContext context,
    _QuotaInfo quotaInfo,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: quotaInfo.isNearLimit
            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)
            : Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Text(
        '${quotaInfo.usedTemplates}/${quotaInfo.maxTemplates}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: quotaInfo.isNearLimit
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  static Widget _buildWarningBanner(
    BuildContext context,
    _QuotaInfo quotaInfo,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.warningAmberRounded,
            color: Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(
                context,
              ).templatesRemaining(quotaInfo.remaining),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNameField(
    TextEditingController controller,
    BuildContext context,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).templateName,
        hintText: AppLocalizations.of(context).templateNameHint,
        border: const OutlineInputBorder(),
        prefixIcon: const SemanticIcon(
          icon: AppIcons.workout,
          semanticLabel: 'Workout',
        ),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  static Widget _buildDescriptionField(
    TextEditingController controller,
    BuildContext context,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).description,
        hintText: AppLocalizations.of(context).descriptionHint,
        border: const OutlineInputBorder(),
        prefixIcon: const SemanticIcon(
          icon: AppIcons.template,
          semanticLabel: 'Template',
        ),
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  static Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.cloudUpload,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).templateSyncDescription,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _saveTemplate(
    BuildContext context,
    WidgetRef ref,
    String name,
    String description,
    dynamic currentWorkout,
  ) async {
    if (name.isEmpty) {
      _showErrorSnackBar(
        context,
        AppLocalizations.of(context).enterTemplateName,
      );
      return;
    }

    Navigator.of(context).pop();

    try {
      // Show loading
      SnackBarService.showCustom(
        context,
        message: AppLocalizations.of(context).savingToFirebase,
        duration: const Duration(seconds: 30),
      );

      // Save template
      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .createTemplateFromWorkout(
            name: name,
            description: description.isEmpty
                ? AppLocalizations.of(context).customTemplate
                : description,
            exercises: currentWorkout.exercises,
            tags: [],
          );

      if (!context.mounted) return;

      // Show success
      SnackBarService.showCustom(
        context,
        message:
            '✅ ${AppLocalizations.of(context).templateSavedSuccessfully(name)}',
        actionLabel: AppLocalizations.of(context).view,
        onAction: () => context.push('/templates'),
      );
    } catch (e) {
      if (!context.mounted) return;
      _handleSaveError(context, e);
    }
  }

  static void _handleSaveError(BuildContext context, dynamic error) {
    final errorMessage = error.toString();
    final isQuotaError = errorMessage.contains('quota exceeded');

    if (isQuotaError) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).limitReached),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemanticIcon(
                icon: AppIcons.package,
                semanticLabel: 'Package',
                size: AppIconSize.xxlarge,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(errorMessage.replaceAll('Exception: ', '')),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).upgradeForMoreTemplates,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).ok),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to premium
              },
              child: Text(AppLocalizations.of(context).upgrade),
            ),
          ],
        ),
      );
    } else {
      _showErrorSnackBar(
        context,
        AppLocalizations.of(
          context,
        ).saveError(errorMessage.replaceAll('Exception: ', '')),
      );
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    SnackBarService.showError(context, message);
  }

  /// Show dialog to update an existing template with current workout exercises.
  /// This allows users to update a template without ending the workout.
  static void showUpdateTemplateDialog(
    BuildContext context,
    WidgetRef ref,
    String templateId,
  ) async {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return;

    // Get the existing template
    final existingTemplate = await ref.read(
      templateByIdProvider(templateId).future,
    );
    if (existingTemplate == null) {
      if (context.mounted) {
        _showErrorSnackBar(context, AppLocalizations.of(context).errorOccurred);
      }
      return;
    }

    if (!context.mounted) return;

    unawaited(
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).updateTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.refresh,
              semanticLabel: 'Update',
              size: AppIconSize.xlarge,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).updateTemplateDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Row(
                children: [
                  const SemanticIcon(
                    icon: AppIcons.template,
                    semanticLabel: 'Template',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          existingTemplate.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${currentWorkout.exercises.length} ${AppLocalizations.of(context).exercises.toLowerCase()}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton.icon(
            onPressed: () =>
                _updateTemplate(context, ref, existingTemplate, currentWorkout),
            icon: const SemanticIcon(
              icon: AppIcons.save,
              semanticLabel: 'Save',
            ),
            label: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
      ),
    );
  }

  static Future<void> _updateTemplate(
    BuildContext context,
    WidgetRef ref,
    wt.WorkoutTemplate existingTemplate,
    dynamic currentWorkout,
  ) async {
    Navigator.of(context).pop();

    try {
      // Show loading
      SnackBarService.showCustom(
        context,
        message: AppLocalizations.of(context).savingToFirebase,
        duration: const Duration(seconds: 30),
      );

      // Convert current workout exercises to ExerciseTemplates
      final exerciseTemplates = currentWorkout.exercises
          .map<wt.ExerciseTemplate>((exercise) {
            return wt.ExerciseTemplate.fromExercise(exercise);
          })
          .toList();

      // Create updated template preserving existing metadata
      final updatedTemplate = existingTemplate.copyWith(
        exercises: exerciseTemplates,
        updatedAt: DateTime.now(),
      );

      // Save the updated template
      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .saveTemplate(updatedTemplate);

      // Show success
      if (context.mounted) {
        SnackBarService.showCustom(
          context,
          message:
              '✅ ${AppLocalizations.of(context).templateSavedSuccessfully(existingTemplate.name)}',
          actionLabel: AppLocalizations.of(context).view,
          onAction: () => context.push('/templates'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          AppLocalizations.of(
            context,
          ).saveError(e.toString().replaceAll('Exception: ', '')),
        );
      }
    }
  }
}

class _QuotaInfo {
  const _QuotaInfo({required this.usedTemplates, required this.maxTemplates});
  final int usedTemplates;
  final int maxTemplates;

  bool get isExceeded => usedTemplates >= maxTemplates;
  bool get isNearLimit =>
      maxTemplates - usedTemplates <= 2 && maxTemplates - usedTemplates > 0;
  int get remaining => maxTemplates - usedTemplates;
}
