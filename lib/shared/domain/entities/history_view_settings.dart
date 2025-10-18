/// 📊 History View Settings
///
/// Configuration for workout history visualization preferences.
library;

/// Available view modes for workout history
enum HistoryViewMode {
  /// List view - Full details in vertical list (default)
  list,

  /// Compact view - Minimal details, more items visible
  compact,

  /// Calendar view - Monthly calendar with workout indicators
  calendar,

  /// Stats view - Charts and statistics focus
  stats,
}

/// Settings for history view preferences
class HistoryViewSettings {
  const HistoryViewSettings({
    required this.viewMode,
    required this.showThumbnails,
    required this.showDuration,
    required this.showExerciseCount,
  });

  /// Current view mode
  final HistoryViewMode viewMode;

  /// Show exercise thumbnails in list/compact view
  final bool showThumbnails;

  /// Show workout duration
  final bool showDuration;

  /// Show exercise count
  final bool showExerciseCount;

  /// Default settings
  factory HistoryViewSettings.defaults() {
    return const HistoryViewSettings(
      viewMode: HistoryViewMode.list,
      showThumbnails: true,
      showDuration: true,
      showExerciseCount: true,
    );
  }

  /// Copy with modifications
  HistoryViewSettings copyWith({
    HistoryViewMode? viewMode,
    bool? showThumbnails,
    bool? showDuration,
    bool? showExerciseCount,
  }) {
    return HistoryViewSettings(
      viewMode: viewMode ?? this.viewMode,
      showThumbnails: showThumbnails ?? this.showThumbnails,
      showDuration: showDuration ?? this.showDuration,
      showExerciseCount: showExerciseCount ?? this.showExerciseCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryViewSettings &&
          runtimeType == other.runtimeType &&
          viewMode == other.viewMode &&
          showThumbnails == other.showThumbnails &&
          showDuration == other.showDuration &&
          showExerciseCount == other.showExerciseCount;

  @override
  int get hashCode =>
      viewMode.hashCode ^
      showThumbnails.hashCode ^
      showDuration.hashCode ^
      showExerciseCount.hashCode;

  @override
  String toString() {
    return 'HistoryViewSettings(viewMode: $viewMode, showThumbnails: $showThumbnails, showDuration: $showDuration, showExerciseCount: $showExerciseCount)';
  }
}
