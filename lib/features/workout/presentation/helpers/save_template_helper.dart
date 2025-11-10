import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Helper class for template saving functionality
class SaveTemplateHelper {
  static void showSaveAsTemplateDialog(BuildContext context, WidgetRef ref) async {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return;

    // Import the provider (assuming it's available)
    // Check user quota
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    int usedTemplates = 0;
    int maxTemplates = 10;

    if (userDoc.exists) {
      final data = userDoc.data()!;
      final quotaData = data['templateQuota'] as Map<String, dynamic>?;
      if (quotaData != null) {
        usedTemplates = quotaData['usedPrivateTemplates'] ?? 0;
        maxTemplates = quotaData['maxPrivateTemplates'] ?? 10;
      }
    }

    // Check if quota exceeded
    if (usedTemplates >= maxTemplates) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.limitReached),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.package,
                size: 48,
                color: context.colors.error,
              ),
              const SizedBox(height: 16),
              Text(context.l10n.templateQuotaLimit(maxTemplates)),
              const SizedBox(height: 8),
              Text(
                'Elimina un template esistente o passa a Premium per avere più spazio.',
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
                // TODO: Navigate to premium screen
              },
              child: Text(context.l10n.upgrade),
            ),
          ],
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: currentWorkout.name);
    final descriptionController = TextEditingController();

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
                '$usedTemplates/$maxTemplates',
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
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
              if (maxTemplates - usedTemplates <= 2 && maxTemplates - usedTemplates > 0)
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
                          'Solo ${maxTemplates - usedTemplates} template rimanenti nel piano Free',
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
                  prefixIcon: const Icon(AppIcons.workout),
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
                  prefixIcon: const Icon(AppIcons.template),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.cloudUpload,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Il template verrà salvato su Firebase e sarà disponibile su tutti i tuoi dispositivi',
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

              if (name.isEmpty) {
                SnackBarService.showWarning(
                  context,
                  context.l10n.enterTemplateName,
                );
                return;
              }

              Navigator.of(context).pop();

              try {
                // Mostra loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: LoadingIndicator(),
                        ),
                        const SizedBox(width: 16),
                        Text(context.l10n.savingToFirebase),
                      ],
                    ),
                    duration: const Duration(seconds: 30),
                  ),
                );

                // Crea e salva il template
                await ref.read(workoutTemplateNotifierProvider.notifier)
                    .createTemplateFromWorkout(
                      name: name,
                      description: description.isEmpty ? 'Template personalizzato' : description,
                      exercises: currentWorkout.exercises,
                      tags: [], // Potremmo aggiungere tags in futuro
                    );

                // Rimuovi loading e mostra successo
                ScaffoldMessenger.of(context).clearSnackBars();
                SnackBarService.showCustom(
                  context,
                  message: '✅ ${context.l10n.templateSavedSuccessfully(name)}',
                  backgroundColor: context.successColor,
                  actionLabel: context.l10n.view,
                  onAction: () => context.push('/templates'),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).clearSnackBars();

                // Check if it's a quota error
                final errorMessage = e.toString();
                final isQuotaError = errorMessage.contains('quota exceeded');

                if (isQuotaError) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(context.l10n.limitReached),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.inventory2,
                            size: 48,
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
                            // TODO: Navigate to premium
                          },
                          child: Text(context.l10n.upgrade),
                        ),
                      ],
                    ),
                  );
                } else {
                  SnackBarService.showError(
                    context,
                    context.l10n.savingErrorMessage(errorMessage.replaceAll('Exception: ', '')),
                  );
                }
              }
            },
            icon: const Icon(AppIcons.cloudUpload),
            label: Text(context.l10n.saveToFirebase),
          ),
        ],
      ),
    );
  }
}
