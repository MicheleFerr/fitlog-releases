/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: flexible_routine
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// RECOVERY PREVENTION SERVICE - Enforce recovery limits and prevent abuse
///
/// Provides:
/// - Once-per-day recovery limit enforcement
/// - Recovery tracking per routine
/// - Cooldown period management
/// - Recovery history maintenance
/// - User-level recovery statistics
///
library;

import 'package:flutter/foundation.dart';

/// Statistics for a user's recovery activity
class RecoveryStatistics {
  /// Constructor for recovery statistics
  const RecoveryStatistics({
    required this.totalRecoveries,
    required this.recoveriesThisWeek,
    required this.recoveriesThisMonth,
    required this.lastRecoveryDate,
    required this.lastRecoveryRoutineId,
    required this.recoveryStreak,
    required this.averageRecoveriesPerWeek,
  });

  /// Total recovery operations performed
  final int totalRecoveries;

  /// Recovery count this week (last 7 days)
  final int recoveriesThisWeek;

  /// Recovery count this month (last 30 days)
  final int recoveriesThisMonth;

  /// Date of last recovery operation
  final DateTime? lastRecoveryDate;

  /// Routine ID where last recovery occurred
  final String? lastRecoveryRoutineId;

  /// Current consecutive recovery streak (days)
  final int recoveryStreak;

  /// Average recoveries per week (lifetime)
  final double averageRecoveriesPerWeek;
}

/// Recovery prevention service for enforcing limits and tracking recovery activity
///
/// Prevents abuse of recovery feature by:
/// - Limiting recoveries to once per day per routine
/// - Tracking recovery history
/// - Preventing back-to-back recoveries
/// - Monitoring recovery frequency for user patterns
class RecoveryPreventionService extends ChangeNotifier {
  /// Constructor
  RecoveryPreventionService() : _recoveryHistory = {};

  /// Map of userId -> list of recovery dates
  final Map<String, List<DateTime>> _recoveryHistory;

  /// Cooldown period between recoveries (hours)
  static const int cooldownHours = 24;

  /// Maximum recoveries allowed per week
  static const int maxRecoveriesPerWeek = 3;

  /// Maximum recoveries allowed per month
  static const int maxRecoveriesPerMonth = 10;

  /// Can the user perform a recovery today?
  ///
  /// Returns true if:
  /// - No recovery performed today for this routine
  /// - Within weekly limit
  /// - Within monthly limit
  bool canPerformRecovery({
    required String userId,
    required String routineId,
  }) {
    // Check daily limit for this routine
    if (_hasRecoveredToday(userId, routineId)) {
      return false;
    }

    // Check weekly limit
    final weeklyCount = _getRecoveriesInDays(userId, 7);
    if (weeklyCount >= maxRecoveriesPerWeek) {
      return false;
    }

    // Check monthly limit
    final monthlyCount = _getRecoveriesInDays(userId, 30);
    if (monthlyCount >= maxRecoveriesPerMonth) {
      return false;
    }

    return true;
  }

  /// Record a recovery operation
  void recordRecovery({
    required String userId,
    required String routineId,
  }) {
    final key = userId;
    _recoveryHistory.putIfAbsent(key, () => []);
    _recoveryHistory[key]!.add(DateTime.now());

    // Keep only last 90 days of history
    _pruneHistory(userId, days: 90);

    notifyListeners();
  }

  /// Check if user has already recovered today for this routine
  bool _hasRecoveredToday(String userId, String routineId) {
    if (!_recoveryHistory.containsKey(userId)) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final history = _recoveryHistory[userId]!;
    return history.any((date) {
      final dateNormalized = DateTime(date.year, date.month, date.day);
      return dateNormalized.isAtSameMomentAs(today);
    });
  }

  /// Get number of recoveries in the last N days
  int _getRecoveriesInDays(String userId, int days) {
    if (!_recoveryHistory.containsKey(userId)) return 0;

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _recoveryHistory[userId]!
        .where((date) => date.isAfter(cutoffDate))
        .length;
  }

  /// Get recovery statistics for a user
  RecoveryStatistics getStatistics(String userId) {
    if (!_recoveryHistory.containsKey(userId)) {
      return const RecoveryStatistics(
        totalRecoveries: 0,
        recoveriesThisWeek: 0,
        recoveriesThisMonth: 0,
        lastRecoveryDate: null,
        lastRecoveryRoutineId: null,
        recoveryStreak: 0,
        averageRecoveriesPerWeek: 0,
      );
    }

    final history = _recoveryHistory[userId]!;
    if (history.isEmpty) {
      return const RecoveryStatistics(
        totalRecoveries: 0,
        recoveriesThisWeek: 0,
        recoveriesThisMonth: 0,
        lastRecoveryDate: null,
        lastRecoveryRoutineId: null,
        recoveryStreak: 0,
        averageRecoveriesPerWeek: 0,
      );
    }

    final total = history.length;
    final weeklyCount = _getRecoveriesInDays(userId, 7);
    final monthlyCount = _getRecoveriesInDays(userId, 30);
    final lastRecovery = history.last;

    // Calculate recovery streak (consecutive days with recovery)
    final streak = _calculateStreak(history);

    // Calculate average (assume user has been active for reasonable time)
    final daysSinceFirst = DateTime.now()
        .difference(history.first)
        .inDays;
    final weeks = (daysSinceFirst / 7).ceil();
    final average = total / (weeks > 0 ? weeks : 1);

    return RecoveryStatistics(
      totalRecoveries: total,
      recoveriesThisWeek: weeklyCount,
      recoveriesThisMonth: monthlyCount,
      lastRecoveryDate: lastRecovery,
      lastRecoveryRoutineId: null, // Would need additional tracking
      recoveryStreak: streak,
      averageRecoveriesPerWeek: average,
    );
  }

  /// Calculate consecutive day streak from recovery history
  int _calculateStreak(List<DateTime> history) {
    if (history.isEmpty) return 0;

    history.sort();
    int streak = 1;
    int maxStreak = 1;

    for (int i = 1; i < history.length; i++) {
      final prevDate = DateTime(
        history[i - 1].year,
        history[i - 1].month,
        history[i - 1].day,
      );
      final currDate = DateTime(
        history[i].year,
        history[i].month,
        history[i].day,
      );

      final difference = currDate.difference(prevDate).inDays;

      if (difference == 1) {
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        streak = 1;
      }
    }

    return maxStreak;
  }

  /// Remove old history entries beyond the specified days
  void _pruneHistory(String userId, {required int days}) {
    if (!_recoveryHistory.containsKey(userId)) return;

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    _recoveryHistory[userId] = _recoveryHistory[userId]!
        .where((date) => date.isAfter(cutoffDate))
        .toList();
  }

  /// Get hours until next recovery is allowed
  int getHoursUntilNextRecovery(String userId) {
    if (!_recoveryHistory.containsKey(userId)) return 0;

    final history = _recoveryHistory[userId]!;
    if (history.isEmpty) return 0;

    final lastRecovery = history.last;
    final nextAllowed = lastRecovery.add(const Duration(hours: cooldownHours));
    final now = DateTime.now();

    if (now.isAfter(nextAllowed)) return 0;

    return nextAllowed.difference(now).inHours;
  }

  /// Check if user is approaching weekly limit
  bool isApproachingWeeklyLimit(String userId) {
    final weeklyCount = _getRecoveriesInDays(userId, 7);
    return weeklyCount >= (maxRecoveriesPerWeek - 1);
  }

  /// Check if user is approaching monthly limit
  bool isApproachingMonthlyLimit(String userId) {
    final monthlyCount = _getRecoveriesInDays(userId, 30);
    return monthlyCount >= (maxRecoveriesPerMonth - 2);
  }

  /// Clear history for a specific user (admin/testing)
  void clearUserHistory(String userId) {
    _recoveryHistory.remove(userId);
    notifyListeners();
  }

  /// Clear all history (admin/testing)
  void clearAllHistory() {
    _recoveryHistory.clear();
    notifyListeners();
  }
}
