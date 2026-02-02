import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_step.dart';

/// Configuration for the Home Screen Guided Tour
///
/// Defines all steps of the tour with their properties.
/// Based on research: adaptive pacing (auto 15s for SIMPLE, user-controlled for COMPLEX)
/// achieves 70% completion + 85% satisfaction.
///
/// Updated to match current MinimalHomeScreen widgets.
class OnboardingTourConfig {
  /// Total number of steps in the tour
  static const int totalSteps = 10;

  /// Standard auto-advance duration for SIMPLE steps
  static const Duration simpleStepDuration = Duration(seconds: 12);

  /// Quick auto-advance for brief utility steps
  static const Duration briefStepDuration = Duration(seconds: 8);

  /// All tour steps in order (matching MinimalHomeScreen layout)
  static List<OnboardingTourStep> get allSteps => [
    // Step 1: XP Progress Bar - Your level and experience
    const OnboardingTourStep(
      id: 'xpProgress',
      titleKey: 'tourXpProgressTitle',
      descriptionKey: 'tourXpProgressDescription',
      type: TourStepType.simple,
      autoAdvanceDuration: briefStepDuration,
      targetWidgetKey: 'xpProgressBar',
      position: 0,
      totalSteps: totalSteps,
    ),

    // Step 2: Activity Rings - HealthKit integration
    const OnboardingTourStep(
      id: 'activityRings',
      titleKey: 'tourActivityRingsTitle',
      descriptionKey: 'tourActivityRingsDescription',
      type: TourStepType.simple,
      autoAdvanceDuration: simpleStepDuration,
      targetWidgetKey: 'activityRings',
      position: 1,
      totalSteps: totalSteps,
    ),

    // Step 3: Pro Insights Preview - Analytics CTA
    const OnboardingTourStep(
      id: 'proInsights',
      titleKey: 'tourProInsightsTitle',
      descriptionKey: 'tourProInsightsDescription',
      type: TourStepType.simple,
      autoAdvanceDuration: simpleStepDuration,
      targetWidgetKey: 'proInsights',
      position: 2,
      totalSteps: totalSteps,
    ),

    // Step 4: Recovery Insight - Sleep-based recovery
    const OnboardingTourStep(
      id: 'recoveryInsight',
      titleKey: 'tourRecoveryInsightTitle',
      descriptionKey: 'tourRecoveryInsightDescription',
      type: TourStepType.simple,
      autoAdvanceDuration: simpleStepDuration,
      targetWidgetKey: 'recoveryInsight',
      position: 3,
      totalSteps: totalSteps,
    ),

    // Step 5: Stress Prediction - Banister model predictions
    const OnboardingTourStep(
      id: 'stressPrediction',
      titleKey: 'tourStressPredictionTitle',
      descriptionKey: 'tourStressPredictionDescription',
      type: TourStepType.simple,
      autoAdvanceDuration: simpleStepDuration,
      targetWidgetKey: 'stressPrediction',
      position: 4,
      totalSteps: totalSteps,
      bottomSheetPosition: BottomSheetPosition.top,
    ),

    // Step 6: Template Suggestion - AI workout recommendation
    const OnboardingTourStep(
      id: 'templateSuggestion',
      titleKey: 'tourTemplateSuggestionTitle',
      descriptionKey: 'tourTemplateSuggestionDescription',
      type: TourStepType.simple,
      autoAdvanceDuration: simpleStepDuration,
      targetWidgetKey: 'templateSuggestion',
      position: 5,
      totalSteps: totalSteps,
      bottomSheetPosition: BottomSheetPosition.top,
    ),

    // Step 7: Start Workout Card - Main CTA
    const OnboardingTourStep(
      id: 'startWorkout',
      titleKey: 'tourStartWorkoutTitle',
      descriptionKey: 'tourStartWorkoutDescription',
      type: TourStepType.simple,
      autoAdvanceDuration: simpleStepDuration,
      targetWidgetKey: 'startWorkout',
      position: 6,
      totalSteps: totalSteps,
      bottomSheetPosition: BottomSheetPosition.top,
    ),

    // Step 8: Templates Carousel - Quick access templates
    const OnboardingTourStep(
      id: 'templatesCarousel',
      titleKey: 'tourTemplatesCarouselTitle',
      descriptionKey: 'tourTemplatesCarouselDescription',
      type: TourStepType.simple,
      autoAdvanceDuration: simpleStepDuration,
      targetWidgetKey: 'templatesCarousel',
      position: 7,
      totalSteps: totalSteps,
      bottomSheetPosition: BottomSheetPosition.top,
    ),

    // Step 9: Exercise Wiki - Community exercise database
    const OnboardingTourStep(
      id: 'exerciseWiki',
      titleKey: 'tourExerciseWikiTitle',
      descriptionKey: 'tourExerciseWikiDescription',
      type: TourStepType.simple,
      autoAdvanceDuration: simpleStepDuration,
      targetWidgetKey: 'exerciseWiki',
      position: 8,
      totalSteps: totalSteps,
      bottomSheetPosition: BottomSheetPosition.top,
    ),

    // Step 10: Settings - App configuration (final step)
    const OnboardingTourStep(
      id: 'settings',
      titleKey: 'tourSettingsTitle',
      descriptionKey: 'tourSettingsDescription',
      type: TourStepType.complex,
      targetWidgetKey: 'settingsButton',
      position: 9,
      totalSteps: totalSteps,
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
