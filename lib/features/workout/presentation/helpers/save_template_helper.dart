import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/template_name_generator.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Helper class for template saving functionality
class SaveTemplateHelper {
  static void showSaveAsTemplateDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return;

    // Get tier-based template limit
    final maxTemplates = ref.read(maxTemplatesProvider);

    // Check user quota from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    int usedTemplates = 0;

    if (userDoc.exists) {
      final data = userDoc.data()!;
      final quotaData = data['templateQuota'] as Map<String, dynamic>?;
      if (quotaData != null) {
        usedTemplates =
            quotaData['usedLibraryTemplates'] ??
            quotaData['libraryEditableCount'] ??
            quotaData['usedPrivateTemplates'] ??
            0;
      }
    }

    // Check if quota exceeded
    if (usedTemplates >= maxTemplates) {
      if (!context.mounted) return;
      unawaited(
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.templateQuotaExceeded),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SemanticIcon(
                  icon: AppIcons.package,
                  semanticLabel: 'Package',
                  size: AppIconSize.xxlarge,
                  color: context.colors.error,
                ),
                const SizedBox(height: 16),
                Text(context.l10n.templateQuotaExceededMessage(maxTemplates)),
                const SizedBox(height: 8),
                Text(
                  context.l10n.upgradeToUnlimited,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.ok),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed(AppRoutes.premiumName);
                },
                child: Text(context.l10n.upgrade),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: currentWorkout.name);
    final descriptionController = TextEditingController();

    if (!context.mounted) return;
    unawaited(
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Text(context.l10n.saveAsTemplate),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: usedTemplates >= maxTemplates - 2
                      ? context.warningColor.withValues(alpha: 0.2)
                      : context.colors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.templateQuotaUsed(usedTemplates, maxTemplates),
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: usedTemplates >= maxTemplates - 2
                        ? context.warningColor
                        : context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show warning if close to limit
                if (maxTemplates - usedTemplates <= 2 &&
                    maxTemplates - usedTemplates > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: context.warningContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.warningColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.warningAmberRounded,
                          color: context.warningColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.l10n.templateQuotaWarning(
                              usedTemplates,
                              maxTemplates,
                            ),
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 12,
                              color: context.warningColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.templateName,
                    hintText: context.l10n.templateNameHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const SemanticIcon(
                      icon: AppIcons.workout,
                      semanticLabel: 'Workout',
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: context.l10n.description,
                    hintText: context.l10n.descriptionHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const SemanticIcon(
                      icon: AppIcons.template,
                      semanticLabel: 'Template',
                    ),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(AppIcons.cloudUpload, color: context.colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.templateSyncDescription,
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            FilledButton.icon(
              onPressed: () async {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();
                final resolvedName = name.isNotEmpty
                    ? name
                    : TemplateNameGenerator.generateFromExercises(
                        currentWorkout.exercises,
                        fallbackName: context.l10n.customTemplate,
                      );

                Navigator.of(context).pop();

                try {
                  // Mostra loading indicator
                  SnackBarService.showInfo(
                    context,
                    context.l10n.savingToFirebase,
                  );

                  // Crea e salva il template
                  final template = await ref
                      .read(workoutTemplateNotifierProvider.notifier)
                      .createTemplateFromWorkout(
                        name: resolvedName,
                        description: description.isEmpty
                            ? 'Template personalizzato'
                            : description,
                        exercises: currentWorkout.exercises,
                        tags: [], // Potremmo aggiungere tags in futuro
                      );

                  // Mostra successo
                  if (!context.mounted) return;
                  SnackBarService.showCustom(
                    context,
                    message:
                        '✅ ${context.l10n.templateSavedSuccessfully(template.name)}',
                    backgroundColor: context.successColor,
                    actionLabel: context.l10n.view,
                    onAction: () => context.push('/templates'),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  SnackBarService.dismiss(context);

                  // Check if it's a quota error
                  final errorMessage = e.toString();
                  final isQuotaError = errorMessage.contains('quota exceeded');

                  if (isQuotaError) {
                    unawaited(
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.l10n.limitReached),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SemanticIcon(
                                icon: AppIcons.inventory2,
                                semanticLabel: 'Inventory2',
                                size: AppIconSize.xxlarge,
                                color: context.warningColor,
                              ),
                              const SizedBox(height: 16),
                              Text(errorMessage.replaceAll('Exception: ', '')),
                              const SizedBox(height: 8),
                              Text(
                                'Elimina template esistenti o passa a Premium.',
                                style: context.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(context.l10n.ok),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.pushNamed(AppRoutes.premiumName);
                              },
                              child: Text(context.l10n.upgrade),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    if (!context.mounted) return;
                    // 🔧 FIX: Show explicit error dialog (not just snackbar)
                    // This prevents users thinking template was saved when it wasn't
                    unawaited(
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Salvataggio fallito'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SemanticIcon(
                                icon: AppIcons.error,
                                semanticLabel: 'Error',
                                size: AppIconSize.xxlarge,
                                color: context.colors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage.replaceAll('Exception: ', ''),
                                style: context.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.colors.errorContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Il template NON è stato salvato. Riprova.',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(context.l10n.ok),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const SemanticIcon(
                icon: AppIcons.cloudUpload,
                semanticLabel: 'Cloud upload',
              ),
              label: Text(context.l10n.saveToFirebase),
            ),
          ],
        ),
      ),
    );
  }
}
