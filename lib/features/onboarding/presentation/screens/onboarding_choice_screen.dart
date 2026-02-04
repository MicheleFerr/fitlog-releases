/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/presentation/screens
/// Feature: Onboarding Choice Screen
/// Type: Screen
///
/// Asks user how they want to proceed after initial onboarding:
/// - "Guide me" → Start template creation wizard
/// - "I'll explore" → Go to home
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_choice_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Screen shown after initial onboarding to ask user preference
class OnboardingChoiceScreen extends ConsumerWidget {
  const OnboardingChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.checkCircle,
                  size: AppIconSize.xxlarge,
                  color: context.colors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                context.l10n.onboardingChoiceTitle,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                context.l10n.onboardingChoiceSubtitle,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Option 1: Guide me
              _ChoiceCard(
                icon: AppIcons.school,
                title: context.l10n.onboardingChoiceGuided,
                description: context.l10n.onboardingChoiceGuidedDescription,
                isPrimary: true,
                onTap: () => _onChoiceSelected(context, ref, OnboardingChoice.guided),
              ),

              const SizedBox(height: AppSpacing.md),

              // Option 2: Explore
              _ChoiceCard(
                icon: AppIcons.explore,
                title: context.l10n.onboardingChoiceExplore,
                description: context.l10n.onboardingChoiceExploreDescription,
                isPrimary: false,
                onTap: () => _onChoiceSelected(context, ref, OnboardingChoice.explore),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onChoiceSelected(
    BuildContext context,
    WidgetRef ref,
    OnboardingChoice choice,
  ) async {
    unawaited(HapticFeedback.mediumImpact());

    final service = ref.read(onboardingChoiceServiceProvider);
    await service?.setChoice(choice);

    if (!context.mounted) return;

    if (choice == OnboardingChoice.guided) {
      // Navigate to Templates screen with tour flag
      // The templates screen will show a tour and mark wizard completed after
      context.go('/templates?showTour=true');
    } else {
      // Go to home - reminder card will show later
      context.go('/');
    }
  }
}

/// Card for each choice option
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? context.colors.primaryContainer
          : context.colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary
                  ? context.colors.primary.withValues(alpha: 0.3)
                  : context.colors.outlineVariant.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? context.colors.primary.withValues(alpha: 0.15)
                      : context.colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: AppIconSize.large,
                  color: isPrimary
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPrimary
                            ? context.colors.onPrimaryContainer
                            : context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isPrimary
                            ? context.colors.onPrimaryContainer.withValues(alpha: 0.8)
                            : context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                AppIcons.chevronRight,
                size: AppIconSize.medium,
                color: isPrimary
                    ? context.colors.onPrimaryContainer.withValues(alpha: 0.6)
                    : context.colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
