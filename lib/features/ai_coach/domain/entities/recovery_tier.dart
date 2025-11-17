/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// Recovery Tier System - Staged unlock for AI Coach insights
///
/// **3-Tier System**:
/// - **Basic Tier** (6 workouts, 14 days): Readiness score + basic recovery insights
/// - **Intermediate Tier** (12 workouts, 28 days): Muscle-specific recovery data
/// - **Advanced Tier** (20 workouts, 42 days): Overtraining detection via HRV + TSB
///
/// **Unlock Criteria**:
/// Each tier unlocks progressively based on user engagement:
/// - Minimum workout count (6/12/20)
/// - Minimum days of data collection (14/28/42)
/// - Data quality validation (consistent tracking)
///
/// **Design Goals**:
/// - Progressive disclosure (avoid overwhelming new users)
/// - Data quality requirements (ensure meaningful insights)
/// - Engagement incentive (unlock advanced features via usage)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recovery_tier.freezed.dart';
part 'recovery_tier.g.dart';

/// Recovery tier levels for staged AI Coach feature unlock
///
/// Tiers unlock progressively based on user engagement:
/// - **Basic**: Entry-level insights (6 workouts, 14 days)
/// - **Intermediate**: Muscle-specific recovery (12 workouts, 28 days)
/// - **Advanced**: Overtraining detection (20 workouts, 42 days)
enum RecoveryTier {
  /// Basic tier - Readiness score + basic recovery insights
  ///
  /// **Unlock Requirements**:
  /// - Minimum 6 workouts logged
  /// - Minimum 14 days of data
  ///
  /// **Features**:
  /// - Overall readiness score (0-100)
  /// - Basic rest day recommendation
  /// - Workout frequency analysis
  @JsonValue('basic')
  basic,

  /// Intermediate tier - Muscle-specific recovery data
  ///
  /// **Unlock Requirements**:
  /// - Minimum 12 workouts logged
  /// - Minimum 28 days of data
  ///
  /// **Features**:
  /// - Muscle group recovery status (chest, back, legs, etc.)
  /// - Volume load per muscle group
  /// - Recovery time estimates per muscle
  @JsonValue('intermediate')
  intermediate,

  /// Advanced tier - Overtraining detection via HRV + TSB
  ///
  /// **Unlock Requirements**:
  /// - Minimum 20 workouts logged
  /// - Minimum 42 days of data
  ///
  /// **Features**:
  /// - HRV baseline calculation
  /// - Training Stress Balance (TSB) score
  /// - Overtraining risk assessment
  /// - Personalized deload recommendations
  @JsonValue('advanced')
  advanced,
}

/// Configuration for recovery tier unlock requirements
///
/// Defines the criteria a user must meet to unlock a specific tier
///
/// **Usage**:
/// ```dart
/// const basicConfig = RecoveryTierConfig(
///   tier: RecoveryTier.basic,
///   minWorkouts: 6,
///   minDays: 14,
/// );
///
/// if (user.totalWorkouts >= basicConfig.minWorkouts &&
///     user.accountAgeDays >= basicConfig.minDays) {
///   // Unlock basic tier
/// }
/// ```
@freezed
class RecoveryTierConfig with _$RecoveryTierConfig {
  const factory RecoveryTierConfig({
    /// The tier this configuration applies to
    required RecoveryTier tier,

    /// Minimum number of workouts required to unlock
    ///
    /// **Values**:
    /// - Basic: 6 workouts
    /// - Intermediate: 12 workouts
    /// - Advanced: 20 workouts
    required int minWorkouts,

    /// Minimum days of data required to unlock
    ///
    /// **Values**:
    /// - Basic: 14 days
    /// - Intermediate: 28 days
    /// - Advanced: 42 days
    required int minDays,
  }) = _RecoveryTierConfig;

  factory RecoveryTierConfig.fromJson(Map<String, dynamic> json) =>
      _$RecoveryTierConfigFromJson(json);

  /// Predefined configuration for Basic tier
  static const basic = RecoveryTierConfig(
    tier: RecoveryTier.basic,
    minWorkouts: 6,
    minDays: 14,
  );

  /// Predefined configuration for Intermediate tier
  static const intermediate = RecoveryTierConfig(
    tier: RecoveryTier.intermediate,
    minWorkouts: 12,
    minDays: 28,
  );

  /// Predefined configuration for Advanced tier
  static const advanced = RecoveryTierConfig(
    tier: RecoveryTier.advanced,
    minWorkouts: 20,
    minDays: 42,
  );

  /// Get configuration for a specific tier
  static RecoveryTierConfig forTier(RecoveryTier tier) {
    switch (tier) {
      case RecoveryTier.basic:
        return basic;
      case RecoveryTier.intermediate:
        return intermediate;
      case RecoveryTier.advanced:
        return advanced;
    }
  }
}

/// User's current unlock status for a recovery tier
///
/// Tracks whether a tier is locked/unlocked and progress toward unlock
///
/// **Usage**:
/// ```dart
/// final status = RecoveryTierStatus(
///   tier: RecoveryTier.basic,
///   isUnlocked: false,
///   currentWorkouts: 4,
///   currentDays: 10,
///   config: RecoveryTierConfig.basic,
/// );
///
/// print('Progress: ${status.workoutsProgress}%'); // 66.7% (4/6)
/// print('Unlocks in: ${status.daysRemaining} days'); // 4 days
/// ```
@freezed
class RecoveryTierStatus with _$RecoveryTierStatus {
  const factory RecoveryTierStatus({
    /// The tier this status applies to
    required RecoveryTier tier,

    /// Whether the tier is currently unlocked
    required bool isUnlocked,

    /// Current number of workouts user has logged
    required int currentWorkouts,

    /// Current number of days since user started tracking
    required int currentDays,

    /// Configuration defining unlock requirements
    required RecoveryTierConfig config,

    /// Optional: Timestamp when tier was unlocked
    DateTime? unlockedAt,
  }) = _RecoveryTierStatus;

  const RecoveryTierStatus._();

  factory RecoveryTierStatus.fromJson(Map<String, dynamic> json) =>
      _$RecoveryTierStatusFromJson(json);

  /// Progress toward workout requirement (0.0 - 1.0)
  ///
  /// Returns 1.0 if requirement is met or exceeded
  double get workoutsProgress {
    if (currentWorkouts >= config.minWorkouts) return 1.0;
    return currentWorkouts / config.minWorkouts;
  }

  /// Progress toward days requirement (0.0 - 1.0)
  ///
  /// Returns 1.0 if requirement is met or exceeded
  double get daysProgress {
    if (currentDays >= config.minDays) return 1.0;
    return currentDays / config.minDays;
  }

  /// Overall progress toward unlock (0.0 - 1.0)
  ///
  /// Uses minimum of workouts and days progress
  /// (both requirements must be met to unlock)
  double get overallProgress {
    return workoutsProgress < daysProgress ? workoutsProgress : daysProgress;
  }

  /// Workouts remaining to unlock
  ///
  /// Returns 0 if requirement is already met
  int get workoutsRemaining {
    final remaining = config.minWorkouts - currentWorkouts;
    return remaining > 0 ? remaining : 0;
  }

  /// Days remaining to unlock
  ///
  /// Returns 0 if requirement is already met
  int get daysRemaining {
    final remaining = config.minDays - currentDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Whether all unlock criteria are met
  ///
  /// Returns `true` if both workout and days requirements are satisfied
  bool get canUnlock {
    return currentWorkouts >= config.minWorkouts &&
        currentDays >= config.minDays;
  }

  /// Human-readable description of unlock progress
  ///
  /// Examples:
  /// - "2 workouts, 4 days remaining"
  /// - "1 workout remaining"
  /// - "Unlocked!"
  String get progressDescription {
    if (isUnlocked) return 'Unlocked!';

    final parts = <String>[];

    if (workoutsRemaining > 0) {
      parts.add('$workoutsRemaining workout${workoutsRemaining == 1 ? '' : 's'}');
    }

    if (daysRemaining > 0) {
      parts.add('$daysRemaining day${daysRemaining == 1 ? '' : 's'}');
    }

    if (parts.isEmpty) return 'Ready to unlock';

    return '${parts.join(', ')} remaining';
  }
}

/// Extension on RecoveryTier enum for convenience methods
extension RecoveryTierExtension on RecoveryTier {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case RecoveryTier.basic:
        return 'Basic';
      case RecoveryTier.intermediate:
        return 'Intermediate';
      case RecoveryTier.advanced:
        return 'Advanced';
    }
  }

  /// Short description of tier features
  String get description {
    switch (this) {
      case RecoveryTier.basic:
        return 'Readiness score & basic recovery insights';
      case RecoveryTier.intermediate:
        return 'Muscle-specific recovery data';
      case RecoveryTier.advanced:
        return 'Overtraining detection via HRV & TSB';
    }
  }

  /// Icon for tier (Material Icons)
  String get iconName {
    switch (this) {
      case RecoveryTier.basic:
        return 'fitness_center'; // Basic workout tracking
      case RecoveryTier.intermediate:
        return 'insights'; // Deeper insights
      case RecoveryTier.advanced:
        return 'psychology'; // Advanced AI analysis
    }
  }

  /// Tier level (1-3) for sorting/comparison
  int get level {
    switch (this) {
      case RecoveryTier.basic:
        return 1;
      case RecoveryTier.intermediate:
        return 2;
      case RecoveryTier.advanced:
        return 3;
    }
  }

  /// Get configuration for this tier
  RecoveryTierConfig get config => RecoveryTierConfig.forTier(this);
}
