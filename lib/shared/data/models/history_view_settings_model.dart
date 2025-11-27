/// 📊 History View Settings Model
///
/// Hive model for persisting history view preferences.
library;

import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/history_view_settings.dart';

part 'history_view_settings_model.g.dart';

/// Hive adapter for HistoryViewMode enum
@HiveType(typeId: 54)
enum HistoryViewModeModel {
  @HiveField(0)
  list,

  @HiveField(1)
  compact,

  @HiveField(2)
  calendar,

  @HiveField(3)
  stats,
}

/// Extension to convert between domain and model
extension HistoryViewModeModelExtension on HistoryViewModeModel {
  HistoryViewMode toDomain() {
    switch (this) {
      case HistoryViewModeModel.list:
        return HistoryViewMode.list;
      case HistoryViewModeModel.compact:
        return HistoryViewMode.compact;
      case HistoryViewModeModel.calendar:
        return HistoryViewMode.calendar;
      case HistoryViewModeModel.stats:
        return HistoryViewMode.stats;
    }
  }
}

/// Extension to convert from domain to model
extension HistoryViewModeExtension on HistoryViewMode {
  HistoryViewModeModel toModel() {
    switch (this) {
      case HistoryViewMode.list:
        return HistoryViewModeModel.list;
      case HistoryViewMode.compact:
        return HistoryViewModeModel.compact;
      case HistoryViewMode.calendar:
        return HistoryViewModeModel.calendar;
      case HistoryViewMode.stats:
        return HistoryViewModeModel.stats;
    }
  }
}

/// Hive model for HistoryViewSettings
@HiveType(typeId: 55)
class HistoryViewSettingsModel extends HiveObject {
  HistoryViewSettingsModel({
    required this.viewMode,
    required this.showThumbnails,
    required this.showDuration,
    required this.showExerciseCount,
  });

  /// Create from domain entity
  factory HistoryViewSettingsModel.fromDomain(HistoryViewSettings settings) {
    return HistoryViewSettingsModel(
      viewMode: settings.viewMode.toModel(),
      showThumbnails: settings.showThumbnails,
      showDuration: settings.showDuration,
      showExerciseCount: settings.showExerciseCount,
    );
  }

  @HiveField(0)
  HistoryViewModeModel viewMode;

  @HiveField(1)
  bool showThumbnails;

  @HiveField(2)
  bool showDuration;

  @HiveField(3)
  bool showExerciseCount;

  /// Convert to domain entity
  HistoryViewSettings toDomain() {
    return HistoryViewSettings(
      viewMode: viewMode.toDomain(),
      showThumbnails: showThumbnails,
      showDuration: showDuration,
      showExerciseCount: showExerciseCount,
    );
  }
}
