/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: flexible_routine
/// 🔧 Type: entity
/// 🌍 Localization: N/A (domain logic only)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// SKIP TRACKER ENTITY - Track skipped and recovered workouts
///
/// This entity provides:
/// - Skip history with reasons
/// - Recovery tracking
/// - Skip analytics (rate, streaks, patterns)
/// - Skip tolerance management
///
/// Dependencies:
/// - Freezed: Code generation
/// - JSON serialization
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'skip_tracker.freezed.dart';
part 'skip_tracker.g.dart';

/// Entry for a skipped workout
@freezed
class SkipEntry with _$SkipEntry {
  const factory SkipEntry({
    required DateTime date,
    String? reason,
    String? notes,
    required DateTime skippedAt,
  }) = _SkipEntry;

  factory SkipEntry.fromJson(Map<String, dynamic> json) =>
      _$SkipEntryFromJson(json);

  /// Factory for creating a skip entry
  factory SkipEntry.create({
    required DateTime date,
    String? reason,
    String? notes,
  }) {
    return SkipEntry(
      date: date,
      reason: reason,
      notes: notes,
      skippedAt: DateTime.now(),
    );
  }
}

/// Entry for a recovered workout
@freezed
class RecoveryEntry with _$RecoveryEntry {
  const factory RecoveryEntry({
    required DateTime originalDate, // Date that was skipped
    required DateTime recoveryDate, // Date when recovered
    String? notes,
    required DateTime recoveredAt, // Timestamp of recovery
  }) = _RecoveryEntry;

  factory RecoveryEntry.fromJson(Map<String, dynamic> json) =>
      _$RecoveryEntryFromJson(json);

  /// Factory for creating a recovery entry
  factory RecoveryEntry.create({
    required DateTime originalDate,
    required DateTime recoveryDate,
    String? notes,
  }) {
    return RecoveryEntry(
      originalDate: originalDate,
      recoveryDate: recoveryDate,
      notes: notes,
      recoveredAt: DateTime.now(),
    );
  }
}

/// Common skip reasons
class SkipReasons {
  static const String sick = 'Sick';
  static const String injury = 'Injury';
  static const String busy = 'Too Busy';
  static const String tired = 'Too Tired';
  static const String travel = 'Traveling';
  static const String weather = 'Bad Weather';
  static const String other = 'Other';

  static List<String> get all => [
        sick,
        injury,
        busy,
        tired,
        travel,
        weather,
        other,
      ];
}

/// 🎯 SKIP TRACKER ENTITY
///
/// Tracks all skipped and recovered workouts in a routine.
/// Provides analytics and insights about skip patterns.
///
/// Example:
/// ```dart
/// SkipTracker(
///   skippedDays: {
///     DateTime(2025, 1, 5): SkipEntry(date: ..., reason: 'Sick'),
///     DateTime(2025, 1, 10): SkipEntry(date: ..., reason: 'Busy'),
///   },
///   recoveredDays: {
///     DateTime(2025, 1, 5): RecoveryEntry(
///       originalDate: DateTime(2025, 1, 5),
///       recoveryDate: DateTime(2025, 1, 7),
///     ),
///   },
/// )
/// ```
@freezed
class SkipTracker with _$SkipTracker {
  const factory SkipTracker({
    /// Map of date → skip entry
    required Map<String, SkipEntry> skippedDays, // String key for JSON serialization

    /// Map of original date → recovery entry
    required Map<String, RecoveryEntry> recoveredDays,

    // === ANALYTICS ===
    @Default(0) int totalSkips,
    @Default(0) int totalRecoveries,

    /// Consecutive skips (current)
    @Default(0) int currentSkipStreak,

    /// Longest skip streak ever
    @Default(0) int longestSkipStreak,

    /// Date of last skip
    DateTime? lastSkipDate,

    /// Most common skip reason
    String? mostCommonReason,
  }) = _SkipTracker;

  factory SkipTracker.fromJson(Map<String, dynamic> json) =>
      _$SkipTrackerFromJson(json);

  /// Factory for creating an empty skip tracker
  factory SkipTracker.empty() {
    return const SkipTracker(
      skippedDays: {},
      recoveredDays: {},
    );
  }
}

/// Extension methods for SkipTracker
extension SkipTrackerExtensions on SkipTracker {
  /// Get skip rate as percentage (0-100)
  double get skipRate {
    if (totalSkips == 0) return 0.0;
    final total = totalSkips + totalRecoveries;
    if (total == 0) return 0.0;
    return (totalSkips / total * 100).clamp(0.0, 100.0);
  }

  /// Get recovery rate as percentage (0-100)
  double get recoveryRate {
    if (totalSkips == 0) return 0.0;
    return (totalRecoveries / totalSkips * 100).clamp(0.0, 100.0);
  }

  /// Check if a specific date was skipped
  bool isSkipped(DateTime date) {
    return skippedDays.containsKey(_dateKey(date));
  }

  /// Check if a specific date was recovered
  bool isRecovered(DateTime date) {
    return recoveredDays.containsKey(_dateKey(date));
  }

  /// Get skip entry for a date
  SkipEntry? getSkipEntry(DateTime date) {
    return skippedDays[_dateKey(date)];
  }

  /// Get recovery entry for a date
  RecoveryEntry? getRecoveryEntry(DateTime date) {
    return recoveredDays[_dateKey(date)];
  }

  /// Add a new skip
  SkipTracker addSkip(DateTime date, String? reason) {
    final key = _dateKey(date);

    // Don't add if already skipped
    if (skippedDays.containsKey(key)) return this;

    final newSkippedDays = Map<String, SkipEntry>.from(skippedDays);
    newSkippedDays[key] = SkipEntry.create(
      date: date,
      reason: reason,
    );

    // Update analytics
    final newTotalSkips = totalSkips + 1;
    final newCurrentStreak = currentSkipStreak + 1;
    final newLongestStreak = newCurrentStreak > longestSkipStreak
        ? newCurrentStreak
        : longestSkipStreak;
    final newMostCommonReason = _calculateMostCommonReason(newSkippedDays);

    return copyWith(
      skippedDays: newSkippedDays,
      totalSkips: newTotalSkips,
      currentSkipStreak: newCurrentStreak,
      longestSkipStreak: newLongestStreak,
      lastSkipDate: date,
      mostCommonReason: newMostCommonReason,
    );
  }

  /// Add a recovery for a skipped day
  SkipTracker addRecovery(DateTime originalDate, DateTime recoveryDate) {
    final originalKey = _dateKey(originalDate);
    final recoveryKey = _dateKey(recoveryDate);

    // Check if original date was actually skipped
    if (!skippedDays.containsKey(originalKey)) return this;

    // Don't add if already recovered
    if (recoveredDays.containsKey(originalKey)) return this;

    final newRecoveredDays = Map<String, RecoveryEntry>.from(recoveredDays);
    newRecoveredDays[originalKey] = RecoveryEntry.create(
      originalDate: originalDate,
      recoveryDate: recoveryDate,
    );

    // Reset current skip streak on recovery
    return copyWith(
      recoveredDays: newRecoveredDays,
      totalRecoveries: totalRecoveries + 1,
      currentSkipStreak: 0,
    );
  }

  /// Get all unrecovered skips
  List<SkipEntry> get unrecoveredSkips {
    return skippedDays.entries
        .where((entry) => !recoveredDays.containsKey(entry.key))
        .map((entry) => entry.value)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  /// Get recent skips (last N days)
  List<SkipEntry> getRecentSkips(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));

    return skippedDays.values
        .where((skip) => skip.date.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get skip count for last N days
  int getSkipCountForPeriod(int days) {
    return getRecentSkips(days).length;
  }

  /// Check if skip tolerance is exceeded for period
  bool isSkipToleranceExceeded(int maxSkipsPerWeek) {
    final lastWeekSkips = getSkipCountForPeriod(7);
    return lastWeekSkips >= maxSkipsPerWeek;
  }

  /// Get skip reasons breakdown
  Map<String, int> get skipReasonBreakdown {
    final breakdown = <String, int>{};

    for (final skip in skippedDays.values) {
      final reason = skip.reason ?? SkipReasons.other;
      breakdown[reason] = (breakdown[reason] ?? 0) + 1;
    }

    return breakdown;
  }

  /// Calculate most common skip reason
  String? _calculateMostCommonReason(Map<String, SkipEntry> skips) {
    if (skips.isEmpty) return null;

    final breakdown = <String, int>{};
    for (final skip in skips.values) {
      final reason = skip.reason ?? SkipReasons.other;
      breakdown[reason] = (breakdown[reason] ?? 0) + 1;
    }

    // Find reason with max count
    String? mostCommon;
    int maxCount = 0;

    breakdown.forEach((reason, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = reason;
      }
    });

    return mostCommon;
  }

  /// Get summary string
  String get summary {
    if (totalSkips == 0) return 'No skips yet';

    final recovered = recoveryRate.toInt();
    return '$totalSkips skips • $recovered% recovered • Streak: $currentSkipStreak';
  }

  /// Clear all skip data (reset)
  SkipTracker clear() {
    return SkipTracker.empty();
  }

  /// Copy with method
  SkipTracker copyWith({
    Map<String, SkipEntry>? skippedDays,
    Map<String, RecoveryEntry>? recoveredDays,
    int? totalSkips,
    int? totalRecoveries,
    int? currentSkipStreak,
    int? longestSkipStreak,
    DateTime? lastSkipDate,
    String? mostCommonReason,
  }) {
    return SkipTracker(
      skippedDays: skippedDays ?? this.skippedDays,
      recoveredDays: recoveredDays ?? this.recoveredDays,
      totalSkips: totalSkips ?? this.totalSkips,
      totalRecoveries: totalRecoveries ?? this.totalRecoveries,
      currentSkipStreak: currentSkipStreak ?? this.currentSkipStreak,
      longestSkipStreak: longestSkipStreak ?? this.longestSkipStreak,
      lastSkipDate: lastSkipDate ?? this.lastSkipDate,
      mostCommonReason: mostCommonReason ?? this.mostCommonReason,
    );
  }

  /// Convert date to string key
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse date from string key
  static DateTime _parseKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
