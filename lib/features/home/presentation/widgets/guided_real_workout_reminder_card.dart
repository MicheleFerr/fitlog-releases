library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_choice_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/workout_tutorial_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Soft gate reminder shown after guided test completion,
/// until first real workout is completed.
class GuidedRealWorkoutReminderCard extends ConsumerStatefulWidget {
  const GuidedRealWorkoutReminderCard({super.key});

  @override
  ConsumerState<GuidedRealWorkoutReminderCard> createState() =>
      _GuidedRealWorkoutReminderCardState();
}

class _GuidedRealWorkoutReminderCardState
    extends ConsumerState<GuidedRealWorkoutReminderCard> {
  bool _trackedImpression = false;
  bool _dismissedInSession = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissedInSession) return const SizedBox.shrink();

    final shouldShow = ref.watch(shouldShowGuidedSoftGateReminderProvider);
    if (!shouldShow) {
      _trackedImpression = false;
      return const SizedBox.shrink();
    }

    if (!_trackedImpression) {
      _trackedImpression = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_trackReminderSeen());
      });
    }

    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primaryContainer.withValues(alpha: 0.8),
              colors.surfaceContainerHighest.withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.play,
                      size: AppIconSize.medium,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pronto per il workout reale?',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hai finito il test guidato. Avvia ora la prima sessione reale.',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _onLaterPressed,
                    child: const Text('Più tardi'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _onStartNowPressed,
                    child: const Text('Inizia ora'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _trackReminderSeen() async {
    final service = await _resolveChoiceService();
    final analytics = ref.read(analyticsServiceProvider);
    await service.incrementGuidedReminderImpression();
    await analytics.logEvent(
      name: AnalyticsEvents.guidedSoftGateSeen,
      parameters: {AnalyticsParameters.source: 'home_reminder'},
    );
  }

  Future<void> _onLaterPressed() async {
    unawaited(HapticFeedback.lightImpact());
    final service = await _resolveChoiceService();
    final analytics = ref.read(analyticsServiceProvider);

    await service.deferGuidedRealReminder();
    await analytics.logEvent(
      name: AnalyticsEvents.guidedSoftGateCta,
      parameters: {
        AnalyticsParameters.source: 'home_reminder',
        AnalyticsParameters.action: 'later',
      },
    );

    if (mounted) {
      setState(() {
        _dismissedInSession = true;
      });
    }
    ref.invalidate(shouldShowGuidedSoftGateReminderProvider);
  }

  Future<void> _onStartNowPressed() async {
    unawaited(HapticFeedback.mediumImpact());
    final service = await _resolveChoiceService();
    final analytics = ref.read(analyticsServiceProvider);
    final workoutNotifier = ref.read(currentWorkoutProvider.notifier);

    await service.startGuidedRealMode();
    await ref.read(workoutTutorialProvider.notifier).resetTutorial();

    workoutNotifier.createWorkout('Quick Workout');
    final workout = ref.read(currentWorkoutProvider);
    await workoutNotifier.startWorkout();

    await analytics.logEvent(
      name: AnalyticsEvents.guidedSoftGateCta,
      parameters: {
        AnalyticsParameters.source: 'home_reminder',
        AnalyticsParameters.action: 'start_real_now',
      },
    );
    await analytics.logEvent(
      name: AnalyticsEvents.guidedRealStarted,
      parameters: {
        AnalyticsParameters.source: 'home_reminder',
        if (workout != null) AnalyticsParameters.workoutId: workout.id,
      },
    );

    if (mounted) {
      setState(() {
        _dismissedInSession = true;
      });
      context.go('/workout');
    }
  }

  Future<OnboardingChoiceService> _resolveChoiceService() async {
    final fromProvider = ref.read(onboardingChoiceServiceProvider);
    if (fromProvider != null) return fromProvider;
    final prefs = await SharedPreferences.getInstance();
    return OnboardingChoiceService(prefs);
  }
}
