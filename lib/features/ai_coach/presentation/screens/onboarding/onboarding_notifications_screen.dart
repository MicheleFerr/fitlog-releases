/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/screens/onboarding
/// 🎯 Feature: ai_coach
/// 🔧 Type: screen
///
/// Onboarding Notifications Screen - Step 4 of 4
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Onboarding Step 4: Notification Permission
///
/// Final step requesting notification permission for AI Coach insights.
///
/// Features:
/// - Notification permission request
/// - Benefits explanation
/// - Skip option (can enable later)
/// - Progress indicator (4/4)
/// - Completes onboarding flow
///
/// Navigation:
/// - Back: OnboardingQuickWinScreen (Step 3)
/// - Next: Complete onboarding, navigate to home
class OnboardingNotificationsScreen extends ConsumerStatefulWidget {
  const OnboardingNotificationsScreen({
    required this.selectedExperience,
    required this.selectedGoal,
    super.key,
  });

  final ExperienceLevel selectedExperience;
  final TrainingGoal selectedGoal;

  @override
  ConsumerState<OnboardingNotificationsScreen> createState() =>
      _OnboardingNotificationsScreenState();
}

class _OnboardingNotificationsScreenState
    extends ConsumerState<OnboardingNotificationsScreen> {
  bool _isRequestingPermission = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.onboardingTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator (4/4)
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SemanticIcon(
                            icon: AppIcons.notifications,
                            semanticLabel: context.l10n.notifications,
                            size: 64,
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        context.l10n.onboardingNotificationsTitle,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        context.l10n.onboardingNotificationsSubtitle,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Benefits list
                      _buildBenefitCard(
                        icon: AppIcons.lightbulb,
                        title: context.l10n.notificationBenefit1Title,
                        description: context.l10n.notificationBenefit1Description,
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitCard(
                        icon: AppIcons.trendingUp,
                        title: context.l10n.notificationBenefit2Title,
                        description: context.l10n.notificationBenefit2Description,
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitCard(
                        icon: AppIcons.timer,
                        title: context.l10n.notificationBenefit3Title,
                        description: context.l10n.notificationBenefit3Description,
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isRequestingPermission ? null : _onEnableNotifications,
                child: _isRequestingPermission
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingIndicator(),
                      )
                    : Text(context.l10n.enableNotifications),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isRequestingPermission ? null : _onSkip,
                child: Text(context.l10n.skipForNow),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build progress indicator (4/4)
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: context.colors.primary, // All filled (last step)
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Build benefit card
  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SemanticIcon(
                  icon: icon,
                  semanticLabel: title,
                  size: AppIconSize.large,
                  color: context.colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Title and description
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
                    description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle enable notifications button press
  Future<void> _onEnableNotifications() async {
    setState(() => _isRequestingPermission = true);

    // TODO: Request notification permission via permission_handler
    // In production: final status = await Permission.notification.request();

    // Simulate permission request delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isRequestingPermission = false);

    // TODO: Navigate to home and save onboarding completion
    // TODO: Save user context (experience + goal) to provider
  }

  /// Handle skip button press
  void _onSkip() {
    // TODO: Navigate to home without requesting permission
    // TODO: Save onboarding completion (notifications disabled)
    // TODO: Save user context (experience + goal) to provider
  }
}
