/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: repository
///
/// Feature Gate Repository - Evaluates feature access rules
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/feature_gate_config.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';

/// Repository for managing feature gates
///
/// Responsibilities:
/// - Define feature gate configurations
/// - Evaluate gate rules for current user
/// - Determine which features are enabled
/// - Track feature usage and effectiveness
/// - Support A/B testing and gradual rollout
///
/// Evaluation logic:
/// - ALL rules must pass for feature to be enabled (AND logic)
/// - User preferences can override if feature is user-configurable
/// - Global feature flags can disable features entirely
class FeatureGateRepository {
  /// Get all feature gate configurations
  List<FeatureGateConfig> getAllFeatureGates() {
    return [
      // Core Features (always enabled)
      const FeatureGateConfig(
        feature: AiCoachFeature.insights,
        displayNameKey: 'featureInsightsName',
        descriptionKey: 'featureInsightsDescription',
        isGloballyEnabled: true,
        defaultEnabled: true,
        userConfigurable: true,
      ),

      // Notifications (enabled for all after onboarding)
      const FeatureGateConfig(
        feature: AiCoachFeature.notifications,
        displayNameKey: 'featureNotificationsName',
        descriptionKey: 'featureNotificationsDescription',
        isGloballyEnabled: true,
        defaultEnabled: true,
        userConfigurable: true,
      ),

      // Achievements (enabled for all)
      const FeatureGateConfig(
        feature: AiCoachFeature.achievements,
        displayNameKey: 'featureAchievementsName',
        descriptionKey: 'featureAchievementsDescription',
        isGloballyEnabled: true,
        defaultEnabled: true,
        userConfigurable: false, // Always enabled
      ),

      // Streak Tracking (enabled for all)
      const FeatureGateConfig(
        feature: AiCoachFeature.streakTracking,
        displayNameKey: 'featureStreakTrackingName',
        descriptionKey: 'featureStreakTrackingDescription',
        isGloballyEnabled: true,
        defaultEnabled: true,
        userConfigurable: false, // Always enabled
      ),

      // Advanced Analytics (requires intermediate+ experience)
      FeatureGateConfig(
        feature: AiCoachFeature.advancedAnalytics,
        displayNameKey: 'featureAdvancedAnalyticsName',
        descriptionKey: 'featureAdvancedAnalyticsDescription',
        isGloballyEnabled: true,
        defaultEnabled: false,
        userConfigurable: true,
        rules: [
          GateRule(
            type: GateRuleType.minExperienceLevel,
            value: ExperienceLevel.intermediate.name,
          ),
          const GateRule(
            type: GateRuleType.minWorkoutCount,
            value: 5, // Must have 5+ workouts
          ),
        ],
      ),

      // Workout Suggestions (requires beginner+, 3+ workouts)
      const FeatureGateConfig(
        feature: AiCoachFeature.workoutSuggestions,
        displayNameKey: 'featureWorkoutSuggestionsName',
        descriptionKey: 'featureWorkoutSuggestionsDescription',
        isGloballyEnabled: true,
        defaultEnabled: false,
        userConfigurable: true,
        rules: [
          GateRule(
            type: GateRuleType.minWorkoutCount,
            value: 3, // Must have 3+ workouts for personalization
          ),
        ],
      ),

      // Recovery Insights (requires intermediate+)
      FeatureGateConfig(
        feature: AiCoachFeature.recoveryInsights,
        displayNameKey: 'featureRecoveryInsightsName',
        descriptionKey: 'featureRecoveryInsightsDescription',
        isGloballyEnabled: true,
        defaultEnabled: false,
        userConfigurable: true,
        rules: [
          GateRule(
            type: GateRuleType.minExperienceLevel,
            value: ExperienceLevel.intermediate.name,
          ),
          const GateRule(
            type: GateRuleType.minWorkoutCount,
            value: 10, // Need workout history for recovery analysis
          ),
        ],
      ),

      // Form Corrections (requires advanced, effectiveness check)
      FeatureGateConfig(
        feature: AiCoachFeature.formCorrections,
        displayNameKey: 'featureFormCorrectionsName',
        descriptionKey: 'featureFormCorrectionsDescription',
        isGloballyEnabled: false, // Disabled for now (future feature)
        defaultEnabled: false,
        userConfigurable: false,
        rules: [
          GateRule(
            type: GateRuleType.minExperienceLevel,
            value: ExperienceLevel.advanced.name,
          ),
        ],
      ),
    ];
  }

  /// Evaluate feature gate for specific user
  ///
  /// Returns status indicating if feature is enabled and why
  Future<FeatureGateStatus> evaluateFeatureGate({
    required AiCoachFeature feature,
    required ExperienceLevel userExperienceLevel,
    required int userWorkoutCount,
    required int daysSinceRegistration,
    Map<AiCoachFeature, bool>? userPreferences,
    Map<String, bool>? featureFlags,
  }) async {
    final config = getAllFeatureGates().firstWhere(
      (c) => c.feature == feature,
      orElse: () => FeatureGateConfig(
        feature: feature,
        displayNameKey: 'unknownFeature',
        descriptionKey: 'unknownFeature',
        isGloballyEnabled: false,
        defaultEnabled: false,
      ),
    );

    // Check global feature flag
    if (!config.isGloballyEnabled) {
      return FeatureGateStatus(
        feature: feature,
        isEnabled: false,
        reasonKey: 'featureGateReasonGloballyDisabled',
        evaluatedAt: DateTime.now(),
      );
    }

    // Check user preference (if configurable)
    if (config.userConfigurable && userPreferences != null) {
      final userPref = userPreferences[feature];
      if (userPref != null && !userPref) {
        return FeatureGateStatus(
          feature: feature,
          isEnabled: false,
          reasonKey: 'featureGateReasonUserDisabled',
          evaluatedAt: DateTime.now(),
        );
      }
    }

    // Evaluate all rules
    final passedRules = <GateRuleType>[];
    final failedRules = <GateRuleType>[];

    for (final rule in config.rules) {
      final passed = _evaluateRule(
        rule: rule,
        userExperienceLevel: userExperienceLevel,
        userWorkoutCount: userWorkoutCount,
        daysSinceRegistration: daysSinceRegistration,
      );

      if (passed) {
        passedRules.add(rule.type);
      } else {
        failedRules.add(rule.type);
      }
    }

    // Feature enabled if all rules passed
    final isEnabled = failedRules.isEmpty;

    // Determine reason
    String reasonKey;
    if (isEnabled) {
      if (config.rules.isEmpty) {
        reasonKey = 'featureGateReasonDefaultEnabled';
      } else {
        reasonKey = 'featureGateReasonAllRulesPassed';
      }
    } else {
      // Use first failed rule as reason
      reasonKey = _getFailureReasonKey(failedRules.first);
    }

    return FeatureGateStatus(
      feature: feature,
      isEnabled: isEnabled,
      reasonKey: reasonKey,
      passedRules: passedRules,
      failedRules: failedRules,
      evaluatedAt: DateTime.now(),
    );
  }

  /// Evaluate all feature gates for current user
  ///
  /// Returns map of feature → status
  Future<Map<AiCoachFeature, FeatureGateStatus>> evaluateAllFeatureGates({
    required ExperienceLevel userExperienceLevel,
    required int userWorkoutCount,
    required int daysSinceRegistration,
    Map<AiCoachFeature, bool>? userPreferences,
    Map<String, bool>? featureFlags,
  }) async {
    final results = <AiCoachFeature, FeatureGateStatus>{};

    for (final config in getAllFeatureGates()) {
      final status = await evaluateFeatureGate(
        feature: config.feature,
        userExperienceLevel: userExperienceLevel,
        userWorkoutCount: userWorkoutCount,
        daysSinceRegistration: daysSinceRegistration,
        userPreferences: userPreferences,
        featureFlags: featureFlags,
      );

      results[config.feature] = status;
    }

    return results;
  }

  /// Evaluate single gate rule
  bool _evaluateRule({
    required GateRule rule,
    required ExperienceLevel userExperienceLevel,
    required int userWorkoutCount,
    required int daysSinceRegistration,
  }) {
    switch (rule.type) {
      case GateRuleType.minExperienceLevel:
        final requiredLevel = ExperienceLevel.values.firstWhere(
          (l) => l.name == rule.value,
          orElse: () => ExperienceLevel.beginner,
        );
        return userExperienceLevel.index >= requiredLevel.index;

      case GateRuleType.minWorkoutCount:
        return userWorkoutCount >= (rule.value as int);

      case GateRuleType.minDaysSinceRegistration:
        return daysSinceRegistration >= (rule.value as int);

      case GateRuleType.userPreference:
        // Handled separately in evaluateFeatureGate
        return true;

      case GateRuleType.featureFlag:
        // Handled separately in evaluateFeatureGate
        return true;

      case GateRuleType.minEffectiveness:
      case GateRuleType.abTestGroup:
        // TODO: Implement when feedback/AB testing systems integrated
        return true;
    }
  }

  /// Get failure reason localization key
  String _getFailureReasonKey(GateRuleType ruleType) {
    switch (ruleType) {
      case GateRuleType.minExperienceLevel:
        return 'featureGateReasonInsufficientExperience';
      case GateRuleType.minWorkoutCount:
        return 'featureGateReasonInsufficientWorkouts';
      case GateRuleType.minDaysSinceRegistration:
        return 'featureGateReasonAccountTooNew';
      case GateRuleType.minEffectiveness:
        return 'featureGateReasonLowEffectiveness';
      default:
        return 'featureGateReasonUnknown';
    }
  }

  /// Get enabled features for current user
  Future<List<AiCoachFeature>> getEnabledFeatures({
    required ExperienceLevel userExperienceLevel,
    required int userWorkoutCount,
    required int daysSinceRegistration,
    Map<AiCoachFeature, bool>? userPreferences,
  }) async {
    final allStatuses = await evaluateAllFeatureGates(
      userExperienceLevel: userExperienceLevel,
      userWorkoutCount: userWorkoutCount,
      daysSinceRegistration: daysSinceRegistration,
      userPreferences: userPreferences,
    );

    return allStatuses.entries
        .where((entry) => entry.value.isEnabled)
        .map((entry) => entry.key)
        .toList();
  }
}
