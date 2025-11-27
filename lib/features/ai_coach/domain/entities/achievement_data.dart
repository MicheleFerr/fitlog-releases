/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// Achievement Data Entity - Tracks unlockable achievements
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_data.freezed.dart';
part 'achievement_data.g.dart';

/// Achievement Category
enum AchievementCategory {
  /// First-time milestones (first workout, first template, etc.)
  firstTime,

  /// Streak-based achievements (7/30/90 day streaks)
  consistency,

  /// Volume achievements (total sets, total weight lifted)
  volume,

  /// Personal record achievements
  personalRecords,

  /// Template usage achievements
  templates,

  /// Special hidden achievements
  hidden,
}

/// Achievement Rarity Level
enum AchievementRarity {
  /// Common achievements (easy to unlock)
  common,

  /// Uncommon achievements (moderate difficulty)
  uncommon,

  /// Rare achievements (challenging)
  rare,

  /// Epic achievements (very challenging)
  epic,

  /// Legendary achievements (extremely rare)
  legendary,
}

/// Achievement Data
///
/// Represents a single unlockable achievement with:
/// - Unique identifier
/// - Display name and description
/// - Category and rarity
/// - Unlock condition description
/// - Unlock timestamp (null if locked)
/// - Icon data
/// - Reward message
///
/// Examples:
/// - "First Steps" → Complete first workout
/// - "Week Warrior" → Achieve 7-day workout streak
/// - "Volume King" → Lift 100,000 kg total
/// - "Template Master" → Create 10 custom templates
@freezed
abstract class AchievementData with _$AchievementData {
  const factory AchievementData({
    /// Unique achievement identifier
    required String id,

    /// Display name (localization key)
    required String name,

    /// Description (localization key)
    required String description,

    /// Achievement category
    required AchievementCategory category,

    /// Rarity level
    required AchievementRarity rarity,

    /// Unlock condition description (localization key)
    required String conditionDescription,

    /// Icon identifier (maps to IconData)
    required String iconKey,

    /// Reward message shown on unlock (localization key)
    required String rewardMessage,

    /// Unlock timestamp (null if locked)
    DateTime? unlockedAt,

    /// Progress towards unlock (0.0 - 1.0)
    @Default(0.0) double progress,

    /// Whether achievement is hidden until unlocked
    @Default(false) bool isHidden,

    /// Sort order for display
    @Default(0) int sortOrder,
  }) = _AchievementData;

  factory AchievementData.fromJson(Map<String, dynamic> json) =>
      _$AchievementDataFromJson(json);
}

/// Extension methods for AchievementData
extension AchievementDataX on AchievementData {
  /// Check if achievement is unlocked
  bool get isUnlocked => unlockedAt != null;

  /// Check if achievement is locked
  bool get isLocked => unlockedAt == null;

  /// Get progress percentage (0-100)
  int get progressPercentage => (progress * 100).round();

  /// Check if achievement is in progress (0 < progress < 1)
  bool get isInProgress => progress > 0 && progress < 1;

  /// Days since unlocked (null if locked)
  int? get daysSinceUnlocked {
    if (unlockedAt == null) return null;
    return DateTime.now().difference(unlockedAt!).inDays;
  }

  /// Check if recently unlocked (within 24 hours)
  bool get isRecentlyUnlocked {
    if (unlockedAt == null) return false;
    final hoursSinceUnlocked =
        DateTime.now().difference(unlockedAt!).inHours;
    return hoursSinceUnlocked < 24;
  }

  /// Get rarity color indicator (for UI)
  ///
  /// Returns localization key for color name
  String get rarityColorKey {
    switch (rarity) {
      case AchievementRarity.common:
        return 'rarityColorCommon'; // Gray
      case AchievementRarity.uncommon:
        return 'rarityColorUncommon'; // Green
      case AchievementRarity.rare:
        return 'rarityColorRare'; // Blue
      case AchievementRarity.epic:
        return 'rarityColorEpic'; // Purple
      case AchievementRarity.legendary:
        return 'rarityColorLegendary'; // Gold
    }
  }

  /// Get rarity display name (for UI)
  ///
  /// Returns localization key for rarity name
  String get rarityNameKey {
    switch (rarity) {
      case AchievementRarity.common:
        return 'rarityCommon';
      case AchievementRarity.uncommon:
        return 'rarityUncommon';
      case AchievementRarity.rare:
        return 'rarityRare';
      case AchievementRarity.epic:
        return 'rarityEpic';
      case AchievementRarity.legendary:
        return 'rarityLegendary';
    }
  }
}

/// Predefined Achievement IDs
///
/// Standard achievement identifiers for consistency
class AchievementIds {
  // First Time Achievements
  static const String firstWorkout = 'first_workout';
  static const String firstTemplate = 'first_template';
  static const String firstExercise = 'first_exercise';

  // Consistency Achievements
  static const String streak7Days = 'streak_7_days';
  static const String streak30Days = 'streak_30_days';
  static const String streak90Days = 'streak_90_days';
  static const String streak365Days = 'streak_365_days';

  // Volume Achievements
  static const String volume10k = 'volume_10k'; // 10,000 kg
  static const String volume50k = 'volume_50k'; // 50,000 kg
  static const String volume100k = 'volume_100k'; // 100,000 kg
  static const String volume500k = 'volume_500k'; // 500,000 kg

  // Workout Count Achievements
  static const String workouts10 = 'workouts_10';
  static const String workouts50 = 'workouts_50';
  static const String workouts100 = 'workouts_100';
  static const String workouts500 = 'workouts_500';

  // Template Achievements
  static const String templates5 = 'templates_5';
  static const String templates10 = 'templates_10';

  // Personal Record Achievements
  static const String pr10 = 'pr_10'; // 10 personal records
  static const String pr50 = 'pr_50'; // 50 personal records

  // Hidden Achievements
  static const String perfectWeek = 'perfect_week'; // 7 workouts in 7 days
  static const String earlyBird = 'early_bird'; // Workout before 6am
  static const String nightOwl = 'night_owl'; // Workout after 10pm
}
