import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_tour_manager.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_tour_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Bottom sheet that displays tour step information
///
/// Adaptive design:
/// - SIMPLE steps: Casual tone, 2-3 sentences, emoji moderate
/// - COMPLEX steps: Mix casual+informative tone, bullet points, emoji moderate
///
/// Research: Adaptive tone achieves 75% comprehension + 85% satisfaction.
class TourBottomSheet extends ConsumerWidget {
  const TourBottomSheet({
    required this.step,
    this.manager,
    super.key,
  });

  final OnboardingTourStep step;
  final OnboardingTourManager? manager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use manager if provided (new flow), otherwise fall back to provider (legacy)
    final usesManager = manager != null;
    final tourState = usesManager ? null : ref.watch(onboardingTourProvider);

    // Check if bottom sheet should be positioned at top (for FAB, Analytics, History steps)
    final isTop = step.bottomSheetPosition == BottomSheetPosition.top;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      left: 0,
      right: 0,
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      child: Material(
        elevation: 8,
        borderRadius: isTop
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : const BorderRadius.vertical(top: Radius.circular(20)),
        color: context.colors.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                _ProgressIndicator(
                  current: step.position + 1,
                  total: step.totalSteps,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  _getLocalizedString(context, step.titleKey),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  _getLocalizedString(context, step.descriptionKey),
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                // Bullet points (for COMPLEX steps only)
                if (step.hasBulletPoints) ...[
                  const SizedBox(height: 12),
                  ...step.bulletPointKeys.map(
                    (key) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, right: 8),
                            child: SemanticIcon(
                              icon: AppIcons.checkCircle,
                              semanticLabel: context.l10n.bullet,
                              size: AppIconSize.small,
                              color: context.colors.primary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _getLocalizedString(context, key),
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Auto-advance indicator (for SIMPLE steps)
                if (step.isSimple && step.autoAdvanceDuration != null) ...[
                  _AutoAdvanceIndicator(
                    key: ValueKey('auto_advance_${step.id}'), // Force rebuild on step change
                    duration: step.autoAdvanceDuration!,
                  ),
                  const SizedBox(height: 16),
                ],

                // Buttons
                Row(
                  children: [
                    // Back button (disabled if first step)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: usesManager
                            ? (!manager!.isFirstStep
                                ? () => manager!.previousStep()
                                : null)
                            : (tourState!.canGoBack
                                ? () => ref
                                    .read(onboardingTourProvider.notifier)
                                    .previousStep()
                                : null),
                        icon: SemanticIcon(
                          icon: AppIcons.back,
                          semanticLabel: context.l10n.back,
                          size: AppIconSize.buttonPrimary,
                        ),
                        label: Text(context.l10n.back),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Skip tour button (hidden on last step)
                    if (!(usesManager ? manager!.isLastStep : tourState!.isLastStep))
                      Expanded(
                        child: OutlinedButton(
                          onPressed: usesManager
                              ? () => manager!.endTour()
                              : () => ref
                                  .read(onboardingTourProvider.notifier)
                                  .skipTour(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(context.l10n.skipTour),
                        ),
                      ),

                    if (!(usesManager ? manager!.isLastStep : tourState!.isLastStep))
                      const SizedBox(width: 12),

                    // Next/Done/Start Workout button
                    Expanded(
                      flex: (usesManager ? manager!.isLastStep : tourState!.isLastStep) ? 3 : 2,
                      child: FilledButton.icon(
                        onPressed: () {
                          final isLast = usesManager ? manager!.isLastStep : tourState!.isLastStep;

                          if (isLast) {
                            // Last step: Navigate to workout screen and end tour
                            if (usesManager) {
                              manager!.endTour();
                            } else {
                              ref.read(onboardingTourProvider.notifier).skipTour();
                            }

                            // Navigate to workout screen to start first workout
                            context.push('/workout');
                          } else {
                            // Regular step: advance to next
                            if (usesManager) {
                              manager!.nextStep();
                            } else {
                              ref.read(onboardingTourProvider.notifier).nextStep();
                            }
                          }
                        },
                        icon: SemanticIcon(
                          icon: (usesManager ? manager!.isLastStep : tourState!.isLastStep)
                              ? AppIcons.workout // Changed from check to workout icon
                              : AppIcons.forward,
                          semanticLabel: (usesManager ? manager!.isLastStep : tourState!.isLastStep)
                              ? context.l10n.startFirstWorkout
                              : context.l10n.next,
                          size: AppIconSize.buttonPrimary,
                        ),
                        label: Text(
                          (usesManager ? manager!.isLastStep : tourState!.isLastStep)
                              ? context.l10n.startFirstWorkout
                              : context.l10n.next,
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
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
}

/// Progress indicator showing current step
class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Progress text
        Text(
          '$current/$total',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),

        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(context.colors.primary),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}

/// Auto-advance countdown indicator
class _AutoAdvanceIndicator extends StatefulWidget {
  const _AutoAdvanceIndicator({
    required this.duration,
    super.key,
  });

  final Duration duration;

  @override
  State<_AutoAdvanceIndicator> createState() => _AutoAdvanceIndicatorState();
}

class _AutoAdvanceIndicatorState extends State<_AutoAdvanceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remaining =
            (widget.duration.inSeconds * (1 - _controller.value)).ceil();
        return Row(
          children: [
            SemanticIcon(
              icon: AppIcons.timer,
              semanticLabel: context.l10n.autoAdvance,
              size: AppIconSize.small,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.autoAdvanceIn(remaining),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _controller.value,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(context.colors.primary),
                  minHeight: 4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Helper function to get localized strings by key
/// Uses reflection-like approach to access AppLocalizations properties
String _getLocalizedString(BuildContext context, String key) {
  final l10n = context.l10n;

  // Map of all tour-related localization keys
  // This is a manual mapping but ensures type safety
  final Map<String, String Function(AppLocalizations)> keyMap = {
    // General
    'bullet': (l) => l.bullet,
    'back': (l) => l.back,
    'skipTour': (l) => l.skipTour,
    'next': (l) => l.next,
    'done': (l) => l.done,
    'autoAdvance': (l) => l.autoAdvance,

    // Step 1: AI Coach
    'tourAiCoachTitle': (l) => l.tourAiCoachTitle,
    'tourAiCoachDescription': (l) => l.tourAiCoachDescription,

    // Step 2: FAB
    'tourFabTitle': (l) => l.tourFabTitle,
    'tourFabDescription': (l) => l.tourFabDescription,

    // Step 3: Smart Workout
    'tourSmartWorkoutTitle': (l) => l.tourSmartWorkoutTitle,
    'tourSmartWorkoutDescription': (l) => l.tourSmartWorkoutDescription,

    // Step 4: Analytics
    'tourAnalyticsTitle': (l) => l.tourAnalyticsTitle,
    'tourAnalyticsDescription': (l) => l.tourAnalyticsDescription,
    'tourAnalyticsBullet1': (l) => l.tourAnalyticsBullet1,
    'tourAnalyticsBullet2': (l) => l.tourAnalyticsBullet2,
    'tourAnalyticsBullet3': (l) => l.tourAnalyticsBullet3,

    // Step 5: History
    'tourHistoryTitle': (l) => l.tourHistoryTitle,
    'tourHistoryDescription': (l) => l.tourHistoryDescription,

    // Step 6: Routine Center
    'tourRoutineCenterTitle': (l) => l.tourRoutineCenterTitle,
    'tourRoutineCenterDescription': (l) => l.tourRoutineCenterDescription,
    'tourRoutineCenterBullet1': (l) => l.tourRoutineCenterBullet1,
    'tourRoutineCenterBullet2': (l) => l.tourRoutineCenterBullet2,
    'tourRoutineCenterBullet3': (l) => l.tourRoutineCenterBullet3,

    // Step 7: Community
    'tourCommunityTitle': (l) => l.tourCommunityTitle,
    'tourCommunityDescription': (l) => l.tourCommunityDescription,

    // Step 8: Notifications
    'tourNotificationsTitle': (l) => l.tourNotificationsTitle,
    'tourNotificationsDescription': (l) => l.tourNotificationsDescription,
  };

  final getter = keyMap[key];
  if (getter != null) {
    return getter(l10n);
  }

  // Fallback if key not found
  return key;
}
