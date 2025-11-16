/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// Feature Gate Config - Configuration for feature gating system
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_gate_config.freezed.dart';
part 'feature_gate_config.g.dart';

/// AI Coach Feature
///
/// Specific features that can be gated on/off
enum AiCoachFeature {
  /// Show AI insights on workout screen
  insights,

  /// Smart notification system
  notifications,

  /// Achievement system and gamification
  achievements,

  /// Streak tracking and motivation
  streakTracking,

  /// Advanced analytics and trends
  advancedAnalytics,

  /// Personalized workout suggestions
  workoutSuggestions,

  /// Recovery recommendations
  recoveryInsights,

  /// Form correction suggestions
  formCorrections,
}

/// Gate Rule Type
///
/// Different criteria for gating features
enum GateRuleType {
  /// User must have minimum experience level
  minExperienceLevel,

  /// Feature must have minimum feedback effectiveness
  minEffectiveness,

  /// User must have completed minimum workouts
  minWorkoutCount,

  /// User must have used app for minimum days
  minDaysSinceRegistration,

  /// Manually enabled by user in settings
  userPreference,

  /// A/B testing group
  abTestGroup,

  /// Feature flag (admin/developer control)
  featureFlag,
}

/// Feature Gate Config
///
/// Configuration for a specific feature gate
///
/// Determines whether a feature should be enabled for a user
/// based on multiple criteria (AND logic - all rules must pass)
@freezed
class FeatureGateConfig with _$FeatureGateConfig {
  const factory FeatureGateConfig({
    /// Feature being gated
    required AiCoachFeature feature,

    /// Feature display name (localization key)
    required String displayNameKey,

    /// Feature description (localization key)
    required String descriptionKey,

    /// Gate rules (ALL must be satisfied)
    @Default([]) List<GateRule> rules,

    /// Whether feature is globally enabled
    @Default(true) bool isGloballyEnabled,

    /// Default enabled state if no rules apply
    @Default(false) bool defaultEnabled,

    /// Whether user can manually toggle in settings
    @Default(true) bool userConfigurable,
  }) = _FeatureGateConfig;

  factory FeatureGateConfig.fromJson(Map<String, dynamic> json) =>
      _$FeatureGateConfigFromJson(json);
}

/// Gate Rule
///
/// Individual rule that must be satisfied for feature access
@freezed
class GateRule with _$GateRule {
  const factory GateRule({
    /// Type of rule
    required GateRuleType type,

    /// Required value for rule (interpretation depends on type)
    required dynamic value,
  }) = _GateRule;

  factory GateRule.fromJson(Map<String, dynamic> json) =>
      _$GateRuleFromJson(json);
}

/// Extension methods for FeatureGateConfig
extension FeatureGateConfigX on FeatureGateConfig {
  /// Whether feature is enabled by default
  bool get isEnabledByDefault => defaultEnabled && isGloballyEnabled;

  /// Whether feature has any rules
  bool get hasRules => rules.isNotEmpty;

  /// Get minimum experience level required (if any)
  String? get minExperienceLevel {
    final rule = rules.firstWhere(
      (r) => r.type == GateRuleType.minExperienceLevel,
      orElse: () => const GateRule(
        type: GateRuleType.minExperienceLevel,
        value: null,
      ),
    );

    return rule.value as String?;
  }

  /// Get minimum workout count required (if any)
  int? get minWorkoutCount {
    final rule = rules.firstWhere(
      (r) => r.type == GateRuleType.minWorkoutCount,
      orElse: () => const GateRule(
        type: GateRuleType.minWorkoutCount,
        value: null,
      ),
    );

    return rule.value as int?;
  }
}

/// Feature Gate Status
///
/// Evaluation result for a specific feature gate
@freezed
class FeatureGateStatus with _$FeatureGateStatus {
  const factory FeatureGateStatus({
    /// Feature being evaluated
    required AiCoachFeature feature,

    /// Whether feature is enabled for current user
    required bool isEnabled,

    /// Reason why feature is enabled/disabled
    required String reasonKey,

    /// Which rules passed
    @Default([]) List<GateRuleType> passedRules,

    /// Which rules failed
    @Default([]) List<GateRuleType> failedRules,

    /// When status was evaluated
    required DateTime evaluatedAt,
  }) = _FeatureGateStatus;

  factory FeatureGateStatus.fromJson(Map<String, dynamic> json) =>
      _$FeatureGateStatusFromJson(json);
}

/// Extension methods for FeatureGateStatus
extension FeatureGateStatusX on FeatureGateStatus {
  /// Whether all rules passed
  bool get allRulesPassed => failedRules.isEmpty;

  /// Whether any rules failed
  bool get hasFailedRules => failedRules.isNotEmpty;
}
