import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_step.dart';

/// Configuration for the Home Screen Guided Tour
///
/// Defines all 8 steps of the tour with their properties.
/// Based on research: adaptive pacing (auto 20s for SIMPLE, user-controlled for COMPLEX)
/// achieves 70% completion + 85% satisfaction.
///
/// New: FAB step re-added as final step with top-positioned bottom sheet.
class OnboardingTourConfig {
  /// Total number of steps in the tour
  static const int totalSteps = 8;

  /// Standard auto-advance duration for SIMPLE steps
  static const Duration simpleStepDuration = Duration(seconds: 20);

  /// Quick auto-advance for brief utility steps
  static const Duration briefStepDuration = Duration(seconds: 15);

  /// All tour steps in order
  static List<OnboardingTourStep> get allSteps => [
        // Step 1: AI Coach Card (SIMPLE - 20s auto)
        const OnboardingTourStep(
          id: 'aiCoach',
          titleKey: 'tourAiCoachTitle',
          descriptionKey: 'tourAiCoachDescription',
          type: TourStepType.simple,
          autoAdvanceDuration: simpleStepDuration,
          targetWidgetKey: 'aiCoachCard',
          position: 0,
          totalSteps: totalSteps,
        ),

        // Step 2: Smart Workout CTA (SIMPLE - 20s auto)
        const OnboardingTourStep(
          id: 'smartWorkout',
          titleKey: 'tourSmartWorkoutTitle',
          descriptionKey: 'tourSmartWorkoutDescription',
          type: TourStepType.simple,
          autoAdvanceDuration: simpleStepDuration,
          targetWidgetKey: 'smartWorkoutCard',
          position: 1,
          totalSteps: totalSteps,
        ),

        // Step 3: Routine Center (SIMPLE - 20s auto)
        const OnboardingTourStep(
          id: 'routineCenter',
          titleKey: 'tourRoutineCenterTitle',
          descriptionKey: 'tourRoutineCenterDescription',
          type: TourStepType.simple,
          autoAdvanceDuration: simpleStepDuration,
          targetWidgetKey: 'routineCenterCard',
          position: 2,
          totalSteps: totalSteps,
        ),

        // Step 4: Analytics (NEW - SIMPLE - 20s auto - bottom sheet positioned at top)
        const OnboardingTourStep(
          id: 'analytics',
          titleKey: 'tourAnalyticsTitle',
          descriptionKey: 'tourAnalyticsDescription',
          bulletPointKeys: [
            'tourAnalyticsBullet1',
            'tourAnalyticsBullet2',
            'tourAnalyticsBullet3',
          ],
          type: TourStepType.simple,
          autoAdvanceDuration: simpleStepDuration,
          targetWidgetKey: 'analytics',
          position: 3,
          totalSteps: totalSteps,
          bottomSheetPosition: BottomSheetPosition.top,
        ),

        // Step 5: History (NEW - SIMPLE - 20s auto - bottom sheet positioned at top)
        const OnboardingTourStep(
          id: 'history',
          titleKey: 'tourHistoryTitle',
          descriptionKey: 'tourHistoryDescription',
          type: TourStepType.simple,
          autoAdvanceDuration: simpleStepDuration,
          targetWidgetKey: 'history',
          position: 4,
          totalSteps: totalSteps,
          bottomSheetPosition: BottomSheetPosition.top,
        ),

        // Step 6: Community (SIMPLE - 20s auto)
        const OnboardingTourStep(
          id: 'community',
          titleKey: 'tourCommunityTitle',
          descriptionKey: 'tourCommunityDescription',
          type: TourStepType.simple,
          autoAdvanceDuration: simpleStepDuration,
          targetWidgetKey: 'communityCard',
          position: 5,
          totalSteps: totalSteps,
        ),

        // Step 7: Notification Hub (SIMPLE - 15s auto)
        const OnboardingTourStep(
          id: 'notifications',
          titleKey: 'tourNotificationsTitle',
          descriptionKey: 'tourNotificationsDescription',
          type: TourStepType.simple,
          autoAdvanceDuration: briefStepDuration,
          targetWidgetKey: 'notifications',
          position: 6,
          totalSteps: totalSteps,
        ),

        // Step 8: FAB (NEW - COMPLEX - user-controlled - bottom sheet positioned at top)
        // This is the final step - user must press button to continue to workout
        const OnboardingTourStep(
          id: 'fab',
          titleKey: 'tourFabTitle',
          descriptionKey: 'tourFabDescription',
          type: TourStepType.complex,
          targetWidgetKey: 'fab',
          position: 7,
          totalSteps: totalSteps,
          bottomSheetPosition: BottomSheetPosition.top,
        ),
      ];

  /// Get a specific step by ID
  static OnboardingTourStep? getStepById(String id) {
    try {
      return allSteps.firstWhere((step) => step.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a step by position
  static OnboardingTourStep? getStepByPosition(int position) {
    if (position < 0 || position >= totalSteps) return null;
    return allSteps[position];
  }
}
