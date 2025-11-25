/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Onboarding Modal - First-time user welcome flow
///
/// **Purpose**: Introduce AI Coach capabilities to new users
///
/// **Features**:
/// - Welcome message with user name
/// - 7 capability categories with examples
/// - Pattern-based explanation (no LLM, local analysis)
/// - Dismissible with "Got it!" button
/// - Beautiful modal design (DESIGN_GUIDELINES.md compliant)
///
/// **Usage**:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => OnboardingModal(
///     userName: 'Michele',
///     onDismiss: () {
///       // Mark onboarding as seen
///     },
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Onboarding modal widget
class OnboardingModal extends StatelessWidget {

  const OnboardingModal({
    super.key,
    required this.userName,
    required this.onDismiss,
  });
  final String userName;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content (scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon
                    Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.ai,
                          semanticLabel: context.l10n.aiCoach,
                          size: AppIconSize.xxlarge,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.onboardingWelcomeTitle(userName),
                                style: context.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.onboardingWelcomeSubtitle,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Capabilities list
                    Text(
                      context.l10n.onboardingCapabilitiesTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _CapabilityItem(
                      icon: AppIcons.analytics,
                      title: context.l10n.onboardingProgressionTitle,
                      example: context.l10n.onboardingProgressionExample,
                    ),
                    _CapabilityItem(
                      icon: AppIcons.workout,
                      title: context.l10n.onboardingVolumeTitle,
                      example: context.l10n.onboardingVolumeExample,
                    ),
                    _CapabilityItem(
                      icon: AppIcons.bedtime,
                      title: context.l10n.onboardingRecoveryTitle,
                      example: context.l10n.onboardingRecoveryExample,
                    ),
                    _CapabilityItem(
                      icon: AppIcons.balance,
                      title: context.l10n.onboardingBalanceTitle,
                      example: context.l10n.onboardingBalanceExample,
                    ),
                    _CapabilityItem(
                      icon: AppIcons.editNote,
                      title: context.l10n.onboardingFormTitle,
                      example: context.l10n.onboardingFormExample,
                    ),
                    _CapabilityItem(
                      icon: AppIcons.stars,
                      title: context.l10n.onboardingMotivationTitle,
                      example: context.l10n.onboardingMotivationExample,
                    ),
                    _CapabilityItem(
                      icon: AppIcons.schedule,
                      title: context.l10n.onboardingPlanTitle,
                      example: context.l10n.onboardingPlanExample,
                    ),

                    const SizedBox(height: 24),

                    // Pattern-based explanation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SemanticIcon(
                            icon: AppIcons.info,
                            semanticLabel: context.l10n.info,
                            size: AppIconSize.medium,
                            color: context.colors.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.l10n.onboardingPatternExplanation,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Got it button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onDismiss,
                        child: Text(context.l10n.onboardingGotIt),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Capability item widget
class _CapabilityItem extends StatelessWidget {

  const _CapabilityItem({
    required this.icon,
    required this.title,
    required this.example,
  });
  final IconData icon;
  final String title;
  final String example;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: title,
            size: AppIconSize.medium,
            color: context.colors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  example,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
