/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/providers
/// 🎯 Feature: Achievement Notification Service (STUB)
/// 🔧 Type: Riverpod Provider
///
/// Temporary stub to prevent compilation errors
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub achievement notification service provider
final achievementNotificationServiceProvider = Provider<AchievementNotificationService>((ref) {
  return AchievementNotificationService();
});

/// Stub achievement notification service
class AchievementNotificationService {
  /// Show achievement notification
  Future<void> showAchievement({
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    // Stub implementation
  }

  /// Check for unlocked achievements
  Future<void> checkAchievements() async {
    // Stub implementation
  }
}
