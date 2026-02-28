/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/home/presentation/widgets
/// Feature: Template Wizard Reminder
/// Type: Widget
///
/// Dismissible card that reminds users to create their first
/// workout routine using the guided wizard.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_choice_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/home_tour_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Reminder card for users who haven't completed the template wizard
///
/// Shows when:
/// - User chose "explore" at onboarding choice screen
/// - OR user was never asked (existing users)
/// - AND wizard not completed
/// - AND card not dismissed
class TemplateWizardReminderCard extends ConsumerWidget {
  const TemplateWizardReminderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShow = ref.watch(shouldShowTemplateWizardReminderProvider);

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.tertiaryContainer.withValues(alpha: 0.8),
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.tertiary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: colorScheme.tertiary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.school,
                        size: AppIconSize.medium,
                        color: colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.templateWizardReminderTitle,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.templateWizardReminderDescription,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Dismiss button
                    TextButton(
                      onPressed: () => _onDismiss(context, ref),
                      child: Text(
                        l10n.templateWizardReminderDismiss,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Start wizard button
                    FilledButton.tonal(
                      onPressed: () => _onStartWizard(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.tertiary.withValues(
                          alpha: 0.15,
                        ),
                        foregroundColor: colorScheme.tertiary,
                      ),
                      child: Text(l10n.templateWizardReminderAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDismiss(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final service = ref.read(onboardingChoiceServiceProvider);
    if (service != null) {
      unawaited(service.dismissTemplateWizardReminder());
    }

    ref.invalidate(templateWizardDismissedProvider);
    ref.invalidate(shouldShowTemplateWizardReminderProvider);
  }

  void _onStartWizard(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();

    // Avoid overlap between Home Tour and Templates guided tour.
    ref.read(homeTourProvider.notifier).stopTour();

    // Mark the user's intent as "guided" and start the guided templates tour.
    final service = ref.read(onboardingChoiceServiceProvider);
    if (service != null) {
      unawaited(service.setChoice(OnboardingChoice.guided));
    }
    ref.invalidate(onboardingChoiceProvider);
    ref.invalidate(shouldShowTemplateWizardReminderProvider);

    context.push('/templates?showTour=true');
  }
}
