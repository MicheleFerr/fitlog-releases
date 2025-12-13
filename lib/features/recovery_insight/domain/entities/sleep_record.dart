/// Sleep Record Entity
///
/// Represents a single night's sleep data from HealthKit/Health Connect.
///
/// **Scientific Basis**:
/// - <6h: Critical (Knowles et al. - reduced strength output)
/// - 6-7h: Suboptimal (Res et al. - -22% MPS)
/// - 7-9h: Optimal (AASM recommendation)
/// - >9h: Excessive (may indicate overtraining/illness)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_record.freezed.dart';
part 'sleep_record.g.dart';

/// Quality category based on sleep duration
enum SleepQuality {
  /// <6h - Significant performance impact
  @JsonValue('critical')
  critical,

  /// 6-7h - Moderate impact
  @JsonValue('suboptimal')
  suboptimal,

  /// 7-9h - No impact (recommended)
  @JsonValue('optimal')
  optimal,

  /// >9h - May indicate overtraining/illness
  @JsonValue('excessive')
  excessive,
}

/// Extension for SleepQuality helpers
extension SleepQualityExtension on SleepQuality {
  /// Get quality from hours of sleep
  static SleepQuality fromHours(double hours) {
    if (hours < 6) return SleepQuality.critical;
    if (hours < 7) return SleepQuality.suboptimal;
    if (hours <= 9) return SleepQuality.optimal;
    return SleepQuality.excessive;
  }

  /// Color name for theming
  String get colorName {
    switch (this) {
      case SleepQuality.critical:
        return 'error';
      case SleepQuality.suboptimal:
        return 'warning';
      case SleepQuality.optimal:
        return 'success';
      case SleepQuality.excessive:
        return 'warning';
    }
  }
}

/// A single night's sleep record
@freezed
abstract class SleepRecord with _$SleepRecord {
  const factory SleepRecord({
    /// Date of the sleep (night of)
    required DateTime date,

    /// Time actually asleep (excludes awake time)
    required Duration asleepDuration,

    /// Total time in bed (includes awake time)
    required Duration inBedDuration,

    /// Sleep efficiency = asleep / inBed * 100
    ///
    /// - >85%: Good efficiency
    /// - 75-85%: Normal
    /// - <75%: Poor efficiency
    required double efficiency,

    /// Quality category based on asleep duration
    required SleepQuality quality,

    /// Data source (e.g., "HealthKit", "Health Connect")
    String? source,
  }) = _SleepRecord;

  const SleepRecord._();

  factory SleepRecord.fromJson(Map<String, dynamic> json) =>
      _$SleepRecordFromJson(json);

  /// Create from raw health data
  factory SleepRecord.fromHealthData({
    required DateTime date,
    required double asleepMinutes,
    required double inBedMinutes,
    String? source,
  }) {
    final asleepDuration = Duration(minutes: asleepMinutes.round());
    final inBedDuration = Duration(minutes: inBedMinutes.round());
    final efficiency =
        inBedMinutes > 0 ? (asleepMinutes / inBedMinutes) * 100 : 0.0;
    final hours = asleepMinutes / 60;
    final quality = SleepQualityExtension.fromHours(hours);

    return SleepRecord(
      date: date,
      asleepDuration: asleepDuration,
      inBedDuration: inBedDuration,
      efficiency: efficiency,
      quality: quality,
      source: source,
    );
  }

  /// Sleep duration in hours
  double get asleepHours => asleepDuration.inMinutes / 60;

  /// In bed duration in hours
  double get inBedHours => inBedDuration.inMinutes / 60;

  /// Formatted sleep duration (e.g., "7h 32m")
  String get formattedDuration {
    final hours = asleepDuration.inHours;
    final minutes = asleepDuration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Whether this is a "bad night" (<6h)
  bool get isBadNight => quality == SleepQuality.critical;

  /// Whether this meets minimum recommendation (>=7h)
  bool get meetsRecommendation =>
      quality == SleepQuality.optimal || quality == SleepQuality.excessive;
}
