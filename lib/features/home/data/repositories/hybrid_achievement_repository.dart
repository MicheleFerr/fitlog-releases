/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data/repositories
/// 🎯 Feature: achievements
/// 🔧 Type: repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - BaseHybridRepository (local + premium sync)
/// - Hive (local storage)
/// - Firebase (premium cloud sync)
library;

import 'package:gymbro_flutter_new/core/data/repositories/base_hybrid_repository.dart';
import 'package:gymbro_flutter_new/features/home/providers/achievement_xp_provider.dart';
import 'package:flutter/material.dart';

/// Hybrid repository for achievements and XP
/// - FREE users: Local storage only (all achievements work offline)
/// - PREMIUM users: Local + Cloud sync
class HybridAchievementRepository extends BaseHybridRepository<UserAchievementData> {
  HybridAchievementRepository({
    super.firestore,
    super.auth,
  }) : super(
    featureName: 'achievements',
    collectionName: 'user_achievements',
    requiresPremiumForCloud: true,
  );

  @override
  Map<String, dynamic> toJson(UserAchievementData entity) {
    return entity.toJson();
  }

  @override
  UserAchievementData fromJson(Map<String, dynamic> json) {
    return UserAchievementData.fromJson(json);
  }

  @override
  String getId(UserAchievementData entity) {
    return entity.userId;
  }

  @override
  bool validate(UserAchievementData entity) {
    return entity.userId.isNotEmpty && entity.achievements.isNotEmpty;
  }

  /// Unlock an achievement for a user
  Future<void> unlockAchievement(String achievementId, Achievement achievement) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Get current achievements
    UserAchievementData? userData = await get(userId);
    
    // Create new data if first achievement
    userData ??= UserAchievementData(
        userId: userId,
        achievements: {},
        totalXP: 0,
        lastUpdated: DateTime.now(),
      );

    // Check if already unlocked
    if (userData.achievements.containsKey(achievementId)) {
      debugPrint('Achievement $achievementId already unlocked');
      return;
    }

    // Add new achievement
    final updatedAchievements = Map<String, UnlockedAchievement>.from(userData.achievements);
    updatedAchievements[achievementId] = UnlockedAchievement(
      achievementId: achievementId,
      unlockedAt: DateTime.now(),
      xpAwarded: achievement.xpReward,
      viewedAt: null,
    );

    // Update total XP
    final updatedUserData = userData.copyWith(
      achievements: updatedAchievements,
      totalXP: userData.totalXP + achievement.xpReward,
      lastUpdated: DateTime.now(),
    );

    // Save using base repository (handles local + sync)
    await update(updatedUserData);

    debugPrint('✅ Achievement unlocked: $achievementId (+${achievement.xpReward} XP)');
  }

  /// Mark achievements as viewed
  Future<void> markAchievementsAsViewed(List<String> achievementIds) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final userData = await get(userId);
    if (userData == null) return;

    final updatedAchievements = Map<String, UnlockedAchievement>.from(userData.achievements);
    bool hasChanges = false;

    for (final id in achievementIds) {
      if (updatedAchievements.containsKey(id)) {
        final achievement = updatedAchievements[id]!;
        if (achievement.viewedAt == null) {
          updatedAchievements[id] = achievement.copyWith(
            viewedAt: DateTime.now(),
          );
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      final updatedUserData = userData.copyWith(
        achievements: updatedAchievements,
        lastUpdated: DateTime.now(),
      );
      await update(updatedUserData);
    }
  }

  /// Get user achievement data with caching
  Future<UserAchievementData?> getUserAchievements() async {
    final userId = currentUserId;
    if (userId == null) return null;

    return await get(userId);
  }

  /// Calculate achievement statistics
  Future<Map<String, dynamic>> getAchievementStats() async {
    final userData = await getUserAchievements();
    if (userData == null) {
      return {
        'totalXP': 0,
        'unlockedCount': 0,
        'recentUnlocks': 0,
        'averageXP': 0,
      };
    }

    final now = DateTime.now();
    final recentUnlocks = userData.achievements.values
        .where((a) => now.difference(a.unlockedAt).inDays <= 7)
        .length;

    return {
      'totalXP': userData.totalXP,
      'unlockedCount': userData.achievements.length,
      'recentUnlocks': recentUnlocks,
      'averageXP': userData.achievements.isNotEmpty 
          ? userData.totalXP ~/ userData.achievements.length 
          : 0,
      'lastAchievement': userData.achievements.values.isNotEmpty
          ? userData.achievements.values
              .reduce((a, b) => a.unlockedAt.isAfter(b.unlockedAt) ? a : b)
              .achievementId
          : null,
    };
  }

  /// Get color for achievement type
  Color _getColorFromType(AchievementType type) {
    switch (type) {
      case AchievementType.workout:
        return const Color(0xFF4CAF50); // Green
      case AchievementType.volume:
        return const Color(0xFF2196F3); // Blue
      case AchievementType.streak:
        return const Color(0xFFFF9800); // Orange
      case AchievementType.pr:
        return const Color(0xFFE91E63); // Pink
      case AchievementType.community:
        return const Color(0xFF9C27B0); // Purple
      case AchievementType.general:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  /// Check and unlock eligible achievements based on stats
  Future<List<String>> checkAndUnlockAchievements({
    int? workoutCount,
    int? streakDays,
    double? totalVolume,
    int? prCount,
    int? communityContributions,
  }) async {
    final unlockedIds = <String>[];

    // This would typically check conditions and unlock achievements
    // For now, just a placeholder that can be expanded
    
    if (workoutCount != null) {
      // Check workout-based achievements
      final workoutAchievements = [
        ('first_workout', 1, 50),
        ('workout_5', 5, 100),
        ('workout_10', 10, 200),
        ('workout_25', 25, 500),
        ('workout_50', 50, 1000),
      ];

      for (final (id, threshold, xp) in workoutAchievements) {
        if (workoutCount >= threshold) {
          final userData = await getUserAchievements();
          if (userData == null || !userData.achievements.containsKey(id)) {
            await unlockAchievement(id, Achievement(
              id: id,
              title: '', // Will be filled by UI
              description: '',
              emoji: '',
              xpReward: xp,
              color: _getColorFromType(AchievementType.workout),
              isUnlocked: true,
              type: AchievementType.workout,
            ));
            unlockedIds.add(id);
          }
        }
      }
    }

    // Similar checks for other achievement types...

    return unlockedIds;
  }
}

/// User achievement data model
class UserAchievementData {

  UserAchievementData({
    required this.userId,
    required this.achievements,
    required this.totalXP,
    required this.lastUpdated,
  });

  factory UserAchievementData.fromJson(Map<String, dynamic> json) {
    return UserAchievementData(
      userId: json['userId'] ?? '',
      achievements: (json['achievements'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, UnlockedAchievement.fromJson(v as Map<String, dynamic>)),
      ) ?? {},
      totalXP: json['totalXP'] ?? 0,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }
  final String userId;
  final Map<String, UnlockedAchievement> achievements;
  final int totalXP;
  final DateTime lastUpdated;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'achievements': achievements.map((k, v) => MapEntry(k, v.toJson())),
    'totalXP': totalXP,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  UserAchievementData copyWith({
    Map<String, UnlockedAchievement>? achievements,
    int? totalXP,
    DateTime? lastUpdated,
  }) {
    return UserAchievementData(
      userId: userId,
      achievements: achievements ?? this.achievements,
      totalXP: totalXP ?? this.totalXP,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Unlocked achievement data
class UnlockedAchievement {

  UnlockedAchievement({
    required this.achievementId,
    required this.unlockedAt,
    required this.xpAwarded,
    this.viewedAt,
  });

  factory UnlockedAchievement.fromJson(Map<String, dynamic> json) {
    return UnlockedAchievement(
      achievementId: json['achievementId'] ?? '',
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'])
          : DateTime.now(),
      xpAwarded: json['xpAwarded'] ?? 0,
      viewedAt: json['viewedAt'] != null 
          ? DateTime.parse(json['viewedAt'])
          : null,
    );
  }
  final String achievementId;
  final DateTime unlockedAt;
  final int xpAwarded;
  final DateTime? viewedAt;

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'unlockedAt': unlockedAt.toIso8601String(),
    'xpAwarded': xpAwarded,
    'viewedAt': viewedAt?.toIso8601String(),
  };

  UnlockedAchievement copyWith({
    DateTime? viewedAt,
  }) {
    return UnlockedAchievement(
      achievementId: achievementId,
      unlockedAt: unlockedAt,
      xpAwarded: xpAwarded,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }
}