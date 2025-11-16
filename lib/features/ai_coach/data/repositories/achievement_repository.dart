/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: repository
///
/// Achievement Repository - Manages achievement unlocking and progress
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/achievement_data.dart';

/// Repository for managing achievements
///
/// Responsibilities:
/// - Define all available achievements
/// - Check unlock conditions based on user statistics
/// - Track achievement progress
/// - Handle achievement unlocking
/// - Persist unlocked achievements
///
/// Achievement unlock conditions are checked against user stats:
/// - Workout count
/// - Streak days
/// - Total volume lifted
/// - Template count
/// - Personal records count
/// - Workout timing (hour of day)
class AchievementRepository {
  /// Get all available achievements (locked and unlocked)
  ///
  /// Returns complete list of achievements with current unlock status
  List<AchievementData> getAllAchievements({
    Map<String, DateTime>? unlockedAchievements,
  }) {
    return [
      // First Time Achievements (Common)
      _createAchievement(
        id: AchievementIds.firstWorkout,
        name: 'achievementFirstWorkout',
        description: 'achievementFirstWorkoutDesc',
        category: AchievementCategory.firstTime,
        rarity: AchievementRarity.common,
        conditionDescription: 'achievementFirstWorkoutCondition',
        iconKey: 'workout',
        rewardMessage: 'achievementFirstWorkoutReward',
        sortOrder: 1,
        unlockedAt: unlockedAchievements?[AchievementIds.firstWorkout],
      ),

      _createAchievement(
        id: AchievementIds.firstTemplate,
        name: 'achievementFirstTemplate',
        description: 'achievementFirstTemplateDesc',
        category: AchievementCategory.firstTime,
        rarity: AchievementRarity.common,
        conditionDescription: 'achievementFirstTemplateCondition',
        iconKey: 'template',
        rewardMessage: 'achievementFirstTemplateReward',
        sortOrder: 2,
        unlockedAt: unlockedAchievements?[AchievementIds.firstTemplate],
      ),

      // Consistency Achievements (Uncommon → Legendary)
      _createAchievement(
        id: AchievementIds.streak7Days,
        name: 'achievementStreak7Days',
        description: 'achievementStreak7DaysDesc',
        category: AchievementCategory.consistency,
        rarity: AchievementRarity.uncommon,
        conditionDescription: 'achievementStreak7DaysCondition',
        iconKey: 'stars',
        rewardMessage: 'achievementStreak7DaysReward',
        sortOrder: 10,
        unlockedAt: unlockedAchievements?[AchievementIds.streak7Days],
      ),

      _createAchievement(
        id: AchievementIds.streak30Days,
        name: 'achievementStreak30Days',
        description: 'achievementStreak30DaysDesc',
        category: AchievementCategory.consistency,
        rarity: AchievementRarity.rare,
        conditionDescription: 'achievementStreak30DaysCondition',
        iconKey: 'stars',
        rewardMessage: 'achievementStreak30DaysReward',
        sortOrder: 11,
        unlockedAt: unlockedAchievements?[AchievementIds.streak30Days],
      ),

      _createAchievement(
        id: AchievementIds.streak90Days,
        name: 'achievementStreak90Days',
        description: 'achievementStreak90DaysDesc',
        category: AchievementCategory.consistency,
        rarity: AchievementRarity.epic,
        conditionDescription: 'achievementStreak90DaysCondition',
        iconKey: 'stars',
        rewardMessage: 'achievementStreak90DaysReward',
        sortOrder: 12,
        unlockedAt: unlockedAchievements?[AchievementIds.streak90Days],
      ),

      _createAchievement(
        id: AchievementIds.streak365Days,
        name: 'achievementStreak365Days',
        description: 'achievementStreak365DaysDesc',
        category: AchievementCategory.consistency,
        rarity: AchievementRarity.legendary,
        conditionDescription: 'achievementStreak365DaysCondition',
        iconKey: 'stars',
        rewardMessage: 'achievementStreak365DaysReward',
        sortOrder: 13,
        unlockedAt: unlockedAchievements?[AchievementIds.streak365Days],
      ),

      // Volume Achievements (Uncommon → Legendary)
      _createAchievement(
        id: AchievementIds.volume10k,
        name: 'achievementVolume10k',
        description: 'achievementVolume10kDesc',
        category: AchievementCategory.volume,
        rarity: AchievementRarity.uncommon,
        conditionDescription: 'achievementVolume10kCondition',
        iconKey: 'trendingUp',
        rewardMessage: 'achievementVolume10kReward',
        sortOrder: 20,
        unlockedAt: unlockedAchievements?[AchievementIds.volume10k],
      ),

      _createAchievement(
        id: AchievementIds.volume100k,
        name: 'achievementVolume100k',
        description: 'achievementVolume100kDesc',
        category: AchievementCategory.volume,
        rarity: AchievementRarity.rare,
        conditionDescription: 'achievementVolume100kCondition',
        iconKey: 'trendingUp',
        rewardMessage: 'achievementVolume100kReward',
        sortOrder: 21,
        unlockedAt: unlockedAchievements?[AchievementIds.volume100k],
      ),

      _createAchievement(
        id: AchievementIds.volume500k,
        name: 'achievementVolume500k',
        description: 'achievementVolume500kDesc',
        category: AchievementCategory.volume,
        rarity: AchievementRarity.legendary,
        conditionDescription: 'achievementVolume500kCondition',
        iconKey: 'trendingUp',
        rewardMessage: 'achievementVolume500kReward',
        sortOrder: 22,
        unlockedAt: unlockedAchievements?[AchievementIds.volume500k],
      ),

      // Workout Count Achievements
      _createAchievement(
        id: AchievementIds.workouts10,
        name: 'achievementWorkouts10',
        description: 'achievementWorkouts10Desc',
        category: AchievementCategory.firstTime,
        rarity: AchievementRarity.common,
        conditionDescription: 'achievementWorkouts10Condition',
        iconKey: 'checkCircle',
        rewardMessage: 'achievementWorkouts10Reward',
        sortOrder: 30,
        unlockedAt: unlockedAchievements?[AchievementIds.workouts10],
      ),

      _createAchievement(
        id: AchievementIds.workouts100,
        name: 'achievementWorkouts100',
        description: 'achievementWorkouts100Desc',
        category: AchievementCategory.volume,
        rarity: AchievementRarity.rare,
        conditionDescription: 'achievementWorkouts100Condition',
        iconKey: 'checkCircle',
        rewardMessage: 'achievementWorkouts100Reward',
        sortOrder: 31,
        unlockedAt: unlockedAchievements?[AchievementIds.workouts100],
      ),

      // Hidden Achievements
      _createAchievement(
        id: AchievementIds.earlyBird,
        name: 'achievementEarlyBird',
        description: 'achievementEarlyBirdDesc',
        category: AchievementCategory.hidden,
        rarity: AchievementRarity.uncommon,
        conditionDescription: 'achievementEarlyBirdCondition',
        iconKey: 'wbSunny',
        rewardMessage: 'achievementEarlyBirdReward',
        sortOrder: 100,
        isHidden: true,
        unlockedAt: unlockedAchievements?[AchievementIds.earlyBird],
      ),

      _createAchievement(
        id: AchievementIds.nightOwl,
        name: 'achievementNightOwl',
        description: 'achievementNightOwlDesc',
        category: AchievementCategory.hidden,
        rarity: AchievementRarity.uncommon,
        conditionDescription: 'achievementNightOwlCondition',
        iconKey: 'nightlightRound',
        rewardMessage: 'achievementNightOwlReward',
        sortOrder: 101,
        isHidden: true,
        unlockedAt: unlockedAchievements?[AchievementIds.nightOwl],
      ),
    ];
  }

  /// Check achievements and return newly unlocked ones
  ///
  /// Compares current user statistics with achievement conditions
  /// Returns list of achievements that were just unlocked
  List<AchievementData> checkAchievements({
    required int totalWorkouts,
    required int currentStreak,
    required double totalVolumeKg,
    required int templateCount,
    required int personalRecordCount,
    required List<DateTime> recentWorkoutTimes,
    required Map<String, DateTime> previouslyUnlocked,
  }) {
    final newlyUnlocked = <AchievementData>[];
    final allAchievements = getAllAchievements(
      unlockedAchievements: previouslyUnlocked,
    );

    for (final achievement in allAchievements) {
      // Skip if already unlocked
      if (previouslyUnlocked.containsKey(achievement.id)) continue;

      // Check unlock conditions
      final shouldUnlock = _checkUnlockCondition(
        achievement: achievement,
        totalWorkouts: totalWorkouts,
        currentStreak: currentStreak,
        totalVolumeKg: totalVolumeKg,
        templateCount: templateCount,
        personalRecordCount: personalRecordCount,
        recentWorkoutTimes: recentWorkoutTimes,
      );

      if (shouldUnlock) {
        newlyUnlocked.add(
          achievement.copyWith(unlockedAt: DateTime.now()),
        );
      }
    }

    return newlyUnlocked;
  }

  /// Calculate progress for achievements (0.0 - 1.0)
  ///
  /// Returns updated achievements list with progress values
  List<AchievementData> updateAchievementProgress({
    required List<AchievementData> achievements,
    required int totalWorkouts,
    required int currentStreak,
    required double totalVolumeKg,
    required int templateCount,
    required int personalRecordCount,
  }) {
    return achievements.map((achievement) {
      // Skip unlocked achievements
      if (achievement.isUnlocked) return achievement;

      final progress = _calculateProgress(
        achievement: achievement,
        totalWorkouts: totalWorkouts,
        currentStreak: currentStreak,
        totalVolumeKg: totalVolumeKg,
        templateCount: templateCount,
        personalRecordCount: personalRecordCount,
      );

      return achievement.copyWith(progress: progress);
    }).toList();
  }

  /// Create achievement with defaults
  AchievementData _createAchievement({
    required String id,
    required String name,
    required String description,
    required AchievementCategory category,
    required AchievementRarity rarity,
    required String conditionDescription,
    required String iconKey,
    required String rewardMessage,
    required int sortOrder,
    DateTime? unlockedAt,
    bool isHidden = false,
  }) {
    return AchievementData(
      id: id,
      name: name,
      description: description,
      category: category,
      rarity: rarity,
      conditionDescription: conditionDescription,
      iconKey: iconKey,
      rewardMessage: rewardMessage,
      sortOrder: sortOrder,
      unlockedAt: unlockedAt,
      isHidden: isHidden,
    );
  }

  /// Check if specific achievement unlock condition is met
  bool _checkUnlockCondition({
    required AchievementData achievement,
    required int totalWorkouts,
    required int currentStreak,
    required double totalVolumeKg,
    required int templateCount,
    required int personalRecordCount,
    required List<DateTime> recentWorkoutTimes,
  }) {
    switch (achievement.id) {
      // First time achievements
      case AchievementIds.firstWorkout:
        return totalWorkouts >= 1;
      case AchievementIds.firstTemplate:
        return templateCount >= 1;

      // Streak achievements
      case AchievementIds.streak7Days:
        return currentStreak >= 7;
      case AchievementIds.streak30Days:
        return currentStreak >= 30;
      case AchievementIds.streak90Days:
        return currentStreak >= 90;
      case AchievementIds.streak365Days:
        return currentStreak >= 365;

      // Volume achievements
      case AchievementIds.volume10k:
        return totalVolumeKg >= 10000;
      case AchievementIds.volume100k:
        return totalVolumeKg >= 100000;
      case AchievementIds.volume500k:
        return totalVolumeKg >= 500000;

      // Workout count achievements
      case AchievementIds.workouts10:
        return totalWorkouts >= 10;
      case AchievementIds.workouts100:
        return totalWorkouts >= 100;

      // Hidden achievements
      case AchievementIds.earlyBird:
        return _hasWorkoutBefore6am(recentWorkoutTimes);
      case AchievementIds.nightOwl:
        return _hasWorkoutAfter10pm(recentWorkoutTimes);

      default:
        return false;
    }
  }

  /// Calculate achievement progress (0.0 - 1.0)
  double _calculateProgress({
    required AchievementData achievement,
    required int totalWorkouts,
    required int currentStreak,
    required double totalVolumeKg,
    required int templateCount,
    required int personalRecordCount,
  }) {
    switch (achievement.id) {
      // First time achievements (0 or 1)
      case AchievementIds.firstWorkout:
        return totalWorkouts >= 1 ? 1.0 : 0.0;
      case AchievementIds.firstTemplate:
        return templateCount >= 1 ? 1.0 : 0.0;

      // Streak achievements
      case AchievementIds.streak7Days:
        return (currentStreak / 7).clamp(0.0, 1.0);
      case AchievementIds.streak30Days:
        return (currentStreak / 30).clamp(0.0, 1.0);
      case AchievementIds.streak90Days:
        return (currentStreak / 90).clamp(0.0, 1.0);
      case AchievementIds.streak365Days:
        return (currentStreak / 365).clamp(0.0, 1.0);

      // Volume achievements
      case AchievementIds.volume10k:
        return (totalVolumeKg / 10000).clamp(0.0, 1.0);
      case AchievementIds.volume100k:
        return (totalVolumeKg / 100000).clamp(0.0, 1.0);
      case AchievementIds.volume500k:
        return (totalVolumeKg / 500000).clamp(0.0, 1.0);

      // Workout count achievements
      case AchievementIds.workouts10:
        return (totalWorkouts / 10).clamp(0.0, 1.0);
      case AchievementIds.workouts100:
        return (totalWorkouts / 100).clamp(0.0, 1.0);

      // Hidden achievements (no progress shown)
      default:
        return 0.0;
    }
  }

  /// Check if any workout was before 6am
  bool _hasWorkoutBefore6am(List<DateTime> workoutTimes) {
    return workoutTimes.any((time) => time.hour < 6);
  }

  /// Check if any workout was after 10pm
  bool _hasWorkoutAfter10pm(List<DateTime> workoutTimes) {
    return workoutTimes.any((time) => time.hour >= 22);
  }

  /// Get unlock percentage for category
  double getCategoryUnlockPercentage({
    required AchievementCategory category,
    required List<AchievementData> achievements,
  }) {
    final categoryAchievements =
        achievements.where((a) => a.category == category).toList();
    if (categoryAchievements.isEmpty) return 0.0;

    final unlockedCount =
        categoryAchievements.where((a) => a.isUnlocked).length;
    return unlockedCount / categoryAchievements.length;
  }

  /// Get total achievement points earned
  int getTotalPoints(List<AchievementData> achievements) {
    int total = 0;
    for (final achievement in achievements) {
      if (achievement.isUnlocked) {
        total += _getRarityPoints(achievement.rarity);
      }
    }
    return total;
  }

  /// Get points for rarity level
  int _getRarityPoints(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 10;
      case AchievementRarity.uncommon:
        return 25;
      case AchievementRarity.rare:
        return 50;
      case AchievementRarity.epic:
        return 100;
      case AchievementRarity.legendary:
        return 250;
    }
  }
}
