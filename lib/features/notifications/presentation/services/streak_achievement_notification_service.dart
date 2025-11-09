/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/services
/// 🎯 Feature: streak_achievements
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// STREAK ACHIEVEMENT NOTIFICATION SERVICE - Triggers notifications for streak milestones
///
/// Features:
/// - Detects streak milestones (3, 7, 14, 30 days)
/// - Shows immediate achievement notifications
/// - Prevents duplicate notifications for same milestone
/// - Integrates with unified notification system
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/unified_notification_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/use_cases/schedule_notification_use_case.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';

/// Service for streak achievement notifications
class StreakAchievementNotificationService {

  StreakAchievementNotificationService(this._ref);
  final Ref _ref;

  /// Streak milestones to trigger notifications
  static const List<int> milestones = [3, 7, 14, 30];

  /// SharedPreferences keys for tracking sent achievements
  static const String _prefsPrefix = 'streak_achievement_sent_';

  /// Check current streak and trigger achievement notification if milestone reached
  ///
  /// This method should be called after every workout completion.
  ///
  /// Logic:
  /// 1. Get current streak from progress provider
  /// 2. Check if it's a milestone (3, 7, 14, 30)
  /// 3. Check if we already sent notification for this milestone
  /// 4. If not, send achievement notification and mark as sent
  ///
  /// Example usage:
  /// ```dart
  /// final service = ref.read(streakAchievementNotificationServiceProvider);
  /// await service.checkAndNotifyStreak();
  /// ```
  Future<void> checkAndNotifyStreak() async {
    try {
      // Get current user
      final authService = _ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [StreakAchievement] No user logged in - skipping check');
        }
        return;
      }

      // Get current streak from progress provider
      final currentStreakAsync = _ref.read(currentStreakProvider);

      await currentStreakAsync.when(
        data: (currentStreak) async {
          if (kDebugMode) {
            debugPrint('🔥 [StreakAchievement] Current streak: $currentStreak days');
          }

          // Check if current streak is a milestone
          if (!milestones.contains(currentStreak)) {
            if (kDebugMode) {
              debugPrint('   Not a milestone - no notification needed');
            }
            return;
          }

          // Check if we already sent notification for this milestone
          final alreadySent = await _hasAchievementBeenSent(currentUser.uid, currentStreak);

          if (alreadySent) {
            if (kDebugMode) {
              debugPrint('   ✅ Achievement already sent for $currentStreak days');
            }
            return;
          }

          // Send achievement notification
          await _sendAchievementNotification(currentUser.uid, currentStreak);

          // Mark as sent
          await _markAchievementAsSent(currentUser.uid, currentStreak);

          if (kDebugMode) {
            debugPrint('🏆 [StreakAchievement] Sent achievement for $currentStreak days!');
          }
        },
        loading: () {
          if (kDebugMode) {
            debugPrint('⏳ [StreakAchievement] Still loading streak data...');
          }
        },
        error: (error, stack) {
          if (kDebugMode) {
            debugPrint('❌ [StreakAchievement] Error getting streak: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [StreakAchievement] Error checking streak: $e');
      }
    }
  }

  /// Send achievement notification for streak milestone
  Future<void> _sendAchievementNotification(String userId, int streakDays) async {
    try {
      final notificationProvider = _ref.read(unifiedNotificationProvider.notifier);

      // Get achievement message based on milestone
      final achievement = _getAchievementForStreak(streakDays);

      // Create notification params
      final params = ScheduleNotificationParams(
        type: NotificationType.achievementUnlocked,
        title: achievement.title,
        body: achievement.body,
        scheduledTime: DateTime.now(), // Immediate notification
        priority: NotificationPriority.high,
        deliveryMethod: NotificationDeliveryMethod.local,
        payload: {
          'achievement_type': 'streak',
          'streak_days': streakDays.toString(),
          'emoji': achievement.emoji,
          'route': '/analytics',
        },
        actions: [
          NotificationAction(
            id: 'view_progress',
            title: 'View Progress',
            payload: {'route': '/analytics'},
          ),
          NotificationAction(
            id: 'share',
            title: 'Share',
            payload: {'action': 'share_achievement'},
          ),
        ],
        tags: ['streak_achievement', 'milestone_$streakDays'],
        userId: userId,
      );

      // Schedule notification (immediate)
      final result = await notificationProvider.scheduleNotification(params);

      if (result.isSuccess) {
        if (kDebugMode) {
          debugPrint('✅ [StreakAchievement] Notification sent: ${achievement.title}');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ [StreakAchievement] Failed to send notification: ${result.error}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [StreakAchievement] Error sending notification: $e');
      }
      rethrow;
    }
  }

  /// Get achievement details for streak milestone
  StreakAchievement _getAchievementForStreak(int days) {
    switch (days) {
      case 3:
        return const StreakAchievement(
          title: '🔥 3-Day Streak!',
          body: 'Great start! You\'ve worked out 3 days in a row. Keep it going!',
          emoji: '🔥',
        );
      case 7:
        return const StreakAchievement(
          title: '⚡ 7-Day Streak - One Week!',
          body: 'Amazing! A full week of consistent training. You\'re building a habit!',
          emoji: '⚡',
        );
      case 14:
        return const StreakAchievement(
          title: '💎 14-Day Streak - Two Weeks!',
          body: 'Outstanding dedication! Two weeks straight. You\'re unstoppable!',
          emoji: '💎',
        );
      case 30:
        return const StreakAchievement(
          title: '🏆 30-Day Streak - Fitness Legend!',
          body: 'Incredible! A full month of commitment. You\'ve joined the elite!',
          emoji: '🏆',
        );
      default:
        return StreakAchievement(
          title: '🎯 $days-Day Streak!',
          body: 'Keep up the great work! You\'re on a roll!',
          emoji: '🎯',
        );
    }
  }

  /// Check if achievement notification has been sent for this milestone
  Future<bool> _hasAchievementBeenSent(String userId, int streakDays) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefsPrefix${userId}_$streakDays';
      return prefs.getBool(key) ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [StreakAchievement] Error checking sent status: $e');
      }
      return false; // Assume not sent if error
    }
  }

  /// Mark achievement notification as sent for this milestone
  Future<void> _markAchievementAsSent(String userId, int streakDays) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefsPrefix${userId}_$streakDays';
      await prefs.setBool(key, true);

      if (kDebugMode) {
        debugPrint('💾 [StreakAchievement] Marked as sent: $streakDays days');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [StreakAchievement] Error marking as sent: $e');
      }
    }
  }

  /// Reset all achievement notifications (useful for testing or streak reset)
  ///
  /// This will allow the user to receive achievement notifications again
  /// if they rebuild their streak from 0.
  ///
  /// Example usage:
  /// ```dart
  /// await service.resetAchievements();
  /// ```
  Future<void> resetAchievements() async {
    try {
      final authService = _ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [StreakAchievement] No user logged in - cannot reset');
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      // Remove all achievement sent flags for this user
      for (final milestone in milestones) {
        final key = '$_prefsPrefix${currentUser.uid}_$milestone';
        await prefs.remove(key);
      }

      if (kDebugMode) {
        debugPrint('🔄 [StreakAchievement] Reset all achievements for user');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [StreakAchievement] Error resetting achievements: $e');
      }
    }
  }

  /// Get list of achieved milestones
  ///
  /// Returns list of milestone days that have been achieved (e.g., [3, 7])
  Future<List<int>> getAchievedMilestones() async {
    try {
      final authService = _ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final achieved = <int>[];

      for (final milestone in milestones) {
        final key = '$_prefsPrefix${currentUser.uid}_$milestone';
        final sent = prefs.getBool(key) ?? false;

        if (sent) {
          achieved.add(milestone);
        }
      }

      return achieved;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [StreakAchievement] Error getting achieved milestones: $e');
      }
      return [];
    }
  }
}

/// Achievement data model
class StreakAchievement {

  const StreakAchievement({
    required this.title,
    required this.body,
    required this.emoji,
  });
  final String title;
  final String body;
  final String emoji;
}

/// Provider for StreakAchievementNotificationService
final streakAchievementNotificationServiceProvider = Provider<StreakAchievementNotificationService>((ref) {
  return StreakAchievementNotificationService(ref);
});

/// Auto-check provider - listens to streak changes and triggers notifications
///
/// This provider automatically checks for streak milestones whenever the
/// current streak changes. It should be watched by the app to enable automatic
/// achievement notifications.
///
/// Example usage in main app:
/// ```dart
/// ref.listen(autoCheckStreakAchievementsProvider, (previous, next) {
///   // Streak check triggered automatically
/// });
/// ```
final autoCheckStreakAchievementsProvider = Provider<void>((ref) {
  // Watch current streak
  final currentStreak = ref.watch(currentStreakProvider);

  // When streak changes and has value, check for achievements
  currentStreak.whenData((streak) async {
    if (streak > 0) {
      final service = ref.read(streakAchievementNotificationServiceProvider);
      await service.checkAndNotifyStreak();
    }
  });
});
