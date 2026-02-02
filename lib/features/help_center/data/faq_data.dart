/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/help_center/data
/// 🎯 Feature: help_center
/// 🔧 Type: data
///
/// FAQ Data - Comprehensive FAQ content definitions covering ALL app features
/// 12 categories with 5-8 questions each for complete coverage
library;

import 'package:gymbro_flutter_new/features/help_center/domain/entities/faq_category.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Static FAQ data organized by categories
class FAQData {
  FAQData._();

  /// All FAQ categories - comprehensive coverage of ALL app features
  static List<FAQCategory> get categories => [
    gettingStartedCategory,
    workoutsCategory,
    exerciseTrackingCategory,
    advancedTechniquesCategory,
    timerCategory,
    analyticsCategory,
    premiumCategory,
    accountCategory,
    profileCategory,
    settingsCategory,
    healthSyncCategory,
    troubleshootingCategory,
  ];

  // ============================================================
  // 1. GETTING STARTED
  // ============================================================
  static const gettingStartedCategory = FAQCategory(
    id: 'getting_started',
    titleKey: 'helpCategoryGettingStarted',
    descriptionKey: 'helpCategoryGettingStartedDesc',
    icon: AppIcons.play,
    items: [
      FAQItem(
        id: 'what_is_app',
        questionKey: 'faqWhatIsAppQuestion',
        answerKey: 'faqWhatIsAppAnswer',
      ),
      FAQItem(
        id: 'first_workout',
        questionKey: 'faqFirstWorkoutQuestion',
        answerKey: 'faqFirstWorkoutAnswer',
      ),
      FAQItem(
        id: 'quick_start',
        questionKey: 'faqQuickStartQuestion',
        answerKey: 'faqQuickStartAnswer',
      ),
      FAQItem(
        id: 'navigation',
        questionKey: 'faqNavigationQuestion',
        answerKey: 'faqNavigationAnswer',
      ),
      FAQItem(
        id: 'templates_intro',
        questionKey: 'faqTemplatesIntroQuestion',
        answerKey: 'faqTemplatesIntroAnswer',
      ),
    ],
  );

  // ============================================================
  // 2. WORKOUTS & TEMPLATES
  // ============================================================
  static const workoutsCategory = FAQCategory(
    id: 'workouts',
    titleKey: 'helpCategoryWorkouts',
    descriptionKey: 'helpCategoryWorkoutsDesc',
    icon: AppIcons.workout,
    items: [
      FAQItem(
        id: 'create_workout',
        questionKey: 'faqCreateWorkoutQuestion',
        answerKey: 'faqCreateWorkoutAnswer',
      ),
      FAQItem(
        id: 'templates',
        questionKey: 'faqTemplatesQuestion',
        answerKey: 'faqTemplatesAnswer',
      ),
      FAQItem(
        id: 'save_template',
        questionKey: 'faqSaveTemplateQuestion',
        answerKey: 'faqSaveTemplateAnswer',
      ),
      FAQItem(
        id: 'edit_workout',
        questionKey: 'faqEditWorkoutQuestion',
        answerKey: 'faqEditWorkoutAnswer',
      ),
      FAQItem(
        id: 'draft_recovery',
        questionKey: 'faqDraftRecoveryQuestion',
        answerKey: 'faqDraftRecoveryAnswer',
      ),
      FAQItem(
        id: 'complete_workout',
        questionKey: 'faqCompleteWorkoutQuestion',
        answerKey: 'faqCompleteWorkoutAnswer',
      ),
    ],
  );

  // ============================================================
  // 3. EXERCISE TRACKING
  // ============================================================
  static const exerciseTrackingCategory = FAQCategory(
    id: 'exercise_tracking',
    titleKey: 'helpCategoryExerciseTracking',
    descriptionKey: 'helpCategoryExerciseTrackingDesc',
    icon: AppIcons.fitnessCenterRounded,
    items: [
      FAQItem(
        id: 'add_exercise',
        questionKey: 'faqAddExerciseQuestion',
        answerKey: 'faqAddExerciseAnswer',
      ),
      FAQItem(
        id: 'sets_reps',
        questionKey: 'faqSetsRepsQuestion',
        answerKey: 'faqSetsRepsAnswer',
      ),
      FAQItem(
        id: 'rpe_rir',
        questionKey: 'faqRpeRirQuestion',
        answerKey: 'faqRpeRirAnswer',
      ),
      FAQItem(
        id: 'counting_modes',
        questionKey: 'faqCountingModesQuestion',
        answerKey: 'faqCountingModesAnswer',
      ),
      FAQItem(
        id: 'warmup_sets',
        questionKey: 'faqWarmupSetsQuestion',
        answerKey: 'faqWarmupSetsAnswer',
      ),
      FAQItem(
        id: 'exercise_notes',
        questionKey: 'faqExerciseNotesQuestion',
        answerKey: 'faqExerciseNotesAnswer',
      ),
    ],
  );

  // ============================================================
  // 4. ADVANCED TECHNIQUES
  // ============================================================
  static const advancedTechniquesCategory = FAQCategory(
    id: 'advanced_techniques',
    titleKey: 'helpCategoryAdvancedTechniques',
    descriptionKey: 'helpCategoryAdvancedTechniquesDesc',
    icon: AppIcons.bolt,
    items: [
      FAQItem(
        id: 'supersets',
        questionKey: 'faqSupersetsQuestion',
        answerKey: 'faqSupersetsAnswer',
      ),
      FAQItem(
        id: 'dropsets',
        questionKey: 'faqDropsetsQuestion',
        answerKey: 'faqDropsetsAnswer',
      ),
      FAQItem(
        id: 'rest_pause',
        questionKey: 'faqRestPauseQuestion',
        answerKey: 'faqRestPauseAnswer',
      ),
      FAQItem(
        id: 'auto_warmup',
        questionKey: 'faqAutoWarmupQuestion',
        answerKey: 'faqAutoWarmupAnswer',
      ),
      FAQItem(
        id: 'auto_regulation',
        questionKey: 'faqAutoRegulationQuestion',
        answerKey: 'faqAutoRegulationAnswer',
      ),
    ],
  );

  // ============================================================
  // 5. REST TIMER
  // ============================================================
  static const timerCategory = FAQCategory(
    id: 'timer',
    titleKey: 'helpCategoryTimer',
    descriptionKey: 'helpCategoryTimerDesc',
    icon: AppIcons.timer,
    items: [
      FAQItem(
        id: 'timer_use',
        questionKey: 'faqTimerQuestion',
        answerKey: 'faqTimerAnswer',
      ),
      FAQItem(
        id: 'timer_background',
        questionKey: 'faqTimerBackgroundQuestion',
        answerKey: 'faqTimerBackgroundAnswer',
      ),
      FAQItem(
        id: 'live_activities',
        questionKey: 'faqLiveActivitiesQuestion',
        answerKey: 'faqLiveActivitiesAnswer',
      ),
      FAQItem(
        id: 'timer_sounds',
        questionKey: 'faqTimerSoundsQuestion',
        answerKey: 'faqTimerSoundsAnswer',
      ),
      FAQItem(
        id: 'default_rest',
        questionKey: 'faqDefaultRestQuestion',
        answerKey: 'faqDefaultRestAnswer',
      ),
    ],
  );

  // ============================================================
  // 6. PROGRESS & ANALYTICS
  // ============================================================
  static const analyticsCategory = FAQCategory(
    id: 'analytics',
    titleKey: 'helpCategoryAnalytics',
    descriptionKey: 'helpCategoryAnalyticsDesc',
    icon: AppIcons.analytics,
    items: [
      FAQItem(
        id: 'track_progress',
        questionKey: 'faqTrackProgressQuestion',
        answerKey: 'faqTrackProgressAnswer',
      ),
      FAQItem(
        id: 'personal_records',
        questionKey: 'faqPersonalRecordsQuestion',
        answerKey: 'faqPersonalRecordsAnswer',
      ),
      FAQItem(
        id: 'volume',
        questionKey: 'faqVolumeQuestion',
        answerKey: 'faqVolumeAnswer',
      ),
      FAQItem(
        id: 'muscle_balance',
        questionKey: 'faqMuscleBalanceQuestion',
        answerKey: 'faqMuscleBalanceAnswer',
      ),
      FAQItem(
        id: 'charts',
        questionKey: 'faqChartsQuestion',
        answerKey: 'faqChartsAnswer',
      ),
      FAQItem(
        id: 'history',
        questionKey: 'faqHistoryQuestion',
        answerKey: 'faqHistoryAnswer',
      ),
    ],
  );

  // ============================================================
  // 7. PREMIUM FEATURES
  // ============================================================
  static const premiumCategory = FAQCategory(
    id: 'premium',
    titleKey: 'helpCategoryPremium',
    descriptionKey: 'helpCategoryPremiumDesc',
    icon: AppIcons.premium,
    items: [
      FAQItem(
        id: 'premium_benefits',
        questionKey: 'faqPremiumBenefitsQuestion',
        answerKey: 'faqPremiumBenefitsAnswer',
      ),
      FAQItem(
        id: 'premium_pricing',
        questionKey: 'faqPremiumPricingQuestion',
        answerKey: 'faqPremiumPricingAnswer',
      ),
      FAQItem(
        id: 'restore_purchase',
        questionKey: 'faqRestorePurchaseQuestion',
        answerKey: 'faqRestorePurchaseAnswer',
      ),
      FAQItem(
        id: 'cancel_subscription',
        questionKey: 'faqCancelSubscriptionQuestion',
        answerKey: 'faqCancelSubscriptionAnswer',
      ),
      FAQItem(
        id: 'free_vs_premium',
        questionKey: 'faqFreeVsPremiumQuestion',
        answerKey: 'faqFreeVsPremiumAnswer',
      ),
    ],
  );

  // ============================================================
  // 8. ACCOUNT & CLOUD SYNC
  // ============================================================
  static const accountCategory = FAQCategory(
    id: 'account',
    titleKey: 'helpCategoryAccount',
    descriptionKey: 'helpCategoryAccountDesc',
    icon: AppIcons.person,
    items: [
      FAQItem(
        id: 'sign_in_methods',
        questionKey: 'faqSignInMethodsQuestion',
        answerKey: 'faqSignInMethodsAnswer',
      ),
      FAQItem(
        id: 'cloud_sync',
        questionKey: 'faqCloudSyncQuestion',
        answerKey: 'faqCloudSyncAnswer',
      ),
      FAQItem(
        id: 'backup',
        questionKey: 'faqBackupQuestion',
        answerKey: 'faqBackupAnswer',
      ),
      FAQItem(
        id: 'switch_device',
        questionKey: 'faqSwitchDeviceQuestion',
        answerKey: 'faqSwitchDeviceAnswer',
      ),
      FAQItem(
        id: 'delete_account',
        questionKey: 'faqDeleteAccountQuestion',
        answerKey: 'faqDeleteAccountAnswer',
      ),
    ],
  );

  // ============================================================
  // 9. PROFILE & GOALS
  // ============================================================
  static const profileCategory = FAQCategory(
    id: 'profile',
    titleKey: 'helpCategoryProfile',
    descriptionKey: 'helpCategoryProfileDesc',
    icon: AppIcons.person,
    items: [
      FAQItem(
        id: 'set_goals',
        questionKey: 'faqSetGoalsQuestion',
        answerKey: 'faqSetGoalsAnswer',
      ),
      FAQItem(
        id: 'streaks',
        questionKey: 'faqStreaksQuestion',
        answerKey: 'faqStreaksAnswer',
      ),
      FAQItem(
        id: 'body_measurements',
        questionKey: 'faqBodyMeasurementsQuestion',
        answerKey: 'faqBodyMeasurementsAnswer',
      ),
      FAQItem(
        id: 'xp_levels',
        questionKey: 'faqXpLevelsQuestion',
        answerKey: 'faqXpLevelsAnswer',
      ),
      FAQItem(
        id: 'achievements',
        questionKey: 'faqAchievementsQuestion',
        answerKey: 'faqAchievementsAnswer',
      ),
    ],
  );

  // ============================================================
  // 10. SETTINGS & CUSTOMIZATION
  // ============================================================
  static const settingsCategory = FAQCategory(
    id: 'settings',
    titleKey: 'helpCategorySettings',
    descriptionKey: 'helpCategorySettingsDesc',
    icon: AppIcons.settings,
    items: [
      FAQItem(
        id: 'units',
        questionKey: 'faqUnitsQuestion',
        answerKey: 'faqUnitsAnswer',
      ),
      FAQItem(
        id: 'language',
        questionKey: 'faqLanguageQuestion',
        answerKey: 'faqLanguageAnswer',
      ),
      FAQItem(
        id: 'theme',
        questionKey: 'faqThemeQuestion',
        answerKey: 'faqThemeAnswer',
      ),
      FAQItem(
        id: 'notifications',
        questionKey: 'faqNotificationsQuestion',
        answerKey: 'faqNotificationsAnswer',
      ),
    ],
  );

  // ============================================================
  // 11. HEALTH SYNC
  // ============================================================
  static const healthSyncCategory = FAQCategory(
    id: 'health_sync',
    titleKey: 'helpCategoryHealthSync',
    descriptionKey: 'helpCategoryHealthSyncDesc',
    icon: AppIcons.healthAndSafety,
    items: [
      FAQItem(
        id: 'apple_health',
        questionKey: 'faqAppleHealthQuestion',
        answerKey: 'faqAppleHealthAnswer',
      ),
      FAQItem(
        id: 'health_connect',
        questionKey: 'faqHealthConnectQuestion',
        answerKey: 'faqHealthConnectAnswer',
      ),
      FAQItem(
        id: 'health_permissions',
        questionKey: 'faqHealthPermissionsQuestion',
        answerKey: 'faqHealthPermissionsAnswer',
      ),
      FAQItem(
        id: 'weight_sync',
        questionKey: 'faqWeightSyncQuestion',
        answerKey: 'faqWeightSyncAnswer',
      ),
    ],
  );

  // ============================================================
  // 12. TROUBLESHOOTING
  // ============================================================
  static const troubleshootingCategory = FAQCategory(
    id: 'troubleshooting',
    titleKey: 'helpCategoryTroubleshooting',
    descriptionKey: 'helpCategoryTroubleshootingDesc',
    icon: AppIcons.help,
    items: [
      FAQItem(
        id: 'data_lost',
        questionKey: 'faqDataLostQuestion',
        answerKey: 'faqDataLostAnswer',
      ),
      FAQItem(
        id: 'timer_not_working',
        questionKey: 'faqTimerNotWorkingQuestion',
        answerKey: 'faqTimerNotWorkingAnswer',
      ),
      FAQItem(
        id: 'sync_issues',
        questionKey: 'faqSyncIssuesQuestion',
        answerKey: 'faqSyncIssuesAnswer',
      ),
      FAQItem(
        id: 'app_crash',
        questionKey: 'faqAppCrashQuestion',
        answerKey: 'faqAppCrashAnswer',
      ),
      FAQItem(
        id: 'contact_support',
        questionKey: 'faqContactSupportQuestion',
        answerKey: 'faqContactSupportAnswer',
      ),
    ],
  );

  /// Get category by ID
  static FAQCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
