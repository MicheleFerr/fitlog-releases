import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Statistics for a workout template
///
/// Tracks usage metrics to show freshness and engagement.
/// Used to display "last performed" metadata in template cards.
class TemplateStats {
  /// Last time this template was used (null if never)
  final DateTime? lastPerformed;

  /// Total number of times this template was completed
  final int totalCompletions;

  /// Average duration of completed workouts (null if never completed)
  final Duration? avgDuration;

  const TemplateStats({
    this.lastPerformed,
    this.totalCompletions = 0,
    this.avgDuration,
  });

  /// Format last performed date with contextual messaging
  ///
  /// Returns:
  /// - "🆕 Nuovo" if never performed
  /// - "✅ Oggi" if performed today
  /// - "🕐 X giorni fa" if performed recently (< 14 days)
  /// - "🔄 Riprendi?" if performed long ago (≥ 14 days)
  String formattedLastPerformed(BuildContext context) {
    if (lastPerformed == null) {
      return "Template Stats New";
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final performedDate = DateTime(
      lastPerformed!.year,
      lastPerformed!.month,
      lastPerformed!.day,
    );

    final daysDifference = today.difference(performedDate).inDays;

    if (daysDifference == 0) {
      // Performed today
      return "Template Stats Today";
    } else if (daysDifference == 1) {
      // Performed yesterday
      return "Template Stats Yesterday";
    } else if (daysDifference < 14) {
      // Performed recently (< 2 weeks)
      return "Performed $daysDifference days ago";
    } else {
      // Performed long ago (≥ 2 weeks) - encourage resuming
      return "Template Stats Resume";
    }
  }

  /// Get semantic color for last performed status
  ///
  /// Returns:
  /// - Green if performed recently (< 7 days)
  /// - Amber if performed moderately ago (7-13 days)
  /// - Null if never performed or very old (≥ 14 days)
  Color? statusColor(BuildContext context) {
    if (lastPerformed == null) {
      return null; // New template, no color
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final performedDate = DateTime(
      lastPerformed!.year,
      lastPerformed!.month,
      lastPerformed!.day,
    );

    final daysDifference = today.difference(performedDate).inDays;

    if (daysDifference < 7) {
      // Recent: green (active, engaged)
      return context.colors.success;
    } else if (daysDifference < 14) {
      // Moderate: amber (warning, time to resume)
      return context.colors.warning;
    } else {
      // Old: no color (neutral, encourage resuming)
      return null;
    }
  }

  /// Check if template is "fresh" (performed within last 7 days)
  bool get isFresh {
    if (lastPerformed == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastPerformed!).inDays;
    return difference < 7;
  }

  /// Check if template needs attention (not performed in 14+ days)
  bool get needsAttention {
    if (lastPerformed == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastPerformed!).inDays;
    return difference >= 14;
  }

  /// Check if template is new (never performed)
  bool get isNew => lastPerformed == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateStats &&
          runtimeType == other.runtimeType &&
          lastPerformed == other.lastPerformed &&
          totalCompletions == other.totalCompletions &&
          avgDuration == other.avgDuration;

  @override
  int get hashCode =>
      lastPerformed.hashCode ^
      totalCompletions.hashCode ^
      avgDuration.hashCode;

  @override
  String toString() {
    return 'TemplateStats(lastPerformed: $lastPerformed, '
        'totalCompletions: $totalCompletions, avgDuration: $avgDuration)';
  }

  /// Create empty stats (never performed)
  factory TemplateStats.empty() {
    return const TemplateStats(
      lastPerformed: null,
      totalCompletions: 0,
      avgDuration: null,
    );
  }

  /// Copy with new values
  TemplateStats copyWith({
    DateTime? Function()? lastPerformed,
    int? totalCompletions,
    Duration? Function()? avgDuration,
  }) {
    return TemplateStats(
      lastPerformed:
          lastPerformed != null ? lastPerformed() : this.lastPerformed,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      avgDuration: avgDuration != null ? avgDuration() : this.avgDuration,
    );
  }
}
