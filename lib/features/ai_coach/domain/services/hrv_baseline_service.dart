/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/services
/// 🎯 Feature: ai_coach
/// 🔧 Type: service
///
/// HRV Baseline Service - Calculate personal HRV baseline for overtraining detection
///
/// **HRV (Heart Rate Variability)**:
/// - Measures variation in time between heartbeats
/// - Higher HRV = better recovery, lower stress
/// - Lower HRV = fatigue, overtraining, illness
///
/// **Baseline Calculation**:
/// - Requires minimum 20 days of HRV data
/// - Uses 7-day rolling average for stability
/// - Filters outliers (±2 standard deviations)
/// - Updates weekly to adapt to fitness changes
///
/// **Usage for Overtraining Detection**:
/// - Compare current HRV (7-day avg) to baseline
/// - Deviation < -10%: High overtraining risk
/// - Deviation -5% to -10%: Moderate risk
/// - Deviation > -5%: Normal recovery
///
/// **Data Sources**:
/// - HealthKit (iOS): HRV readings from Apple Watch
/// - Health Connect (Android): HRV from compatible wearables
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/usecases/evaluate_advanced_tier_unlock.dart';

/// HRV Baseline Service for personal baseline calculation
///
/// **Usage**:
/// ```dart
/// final service = HrvBaselineService();
/// final baseline = service.calculateBaseline(hrvReadings);
///
/// if (baseline != null) {
///   final deviation = service.calculateDeviation(
///     currentReadings: last7DaysReadings,
///     baseline: baseline,
///   );
///   print('HRV Deviation: ${deviation.toStringAsFixed(1)}%');
/// }
/// ```
class HrvBaselineService {
  /// Minimum number of days required for baseline calculation
  static const int minDaysForBaseline = 20;

  /// Window size for rolling average (days)
  static const int rollingWindowDays = 7;

  /// Calculate HRV baseline from historical readings
  ///
  /// **Requirements**:
  /// - Minimum 20 days of data
  /// - At least 1 reading per day (ideally)
  ///
  /// **Algorithm**:
  /// 1. Filter readings to last 28 days
  /// 2. Group by day and calculate daily average
  /// 3. Remove outliers (±2 SD)
  /// 4. Calculate 7-day rolling averages
  /// 5. Return mean of rolling averages as baseline
  ///
  /// **Returns**: Baseline HRV value (ms) or null if insufficient data
  double? calculateBaseline(List<HrvReading> readings) {
    if (readings.isEmpty) return null;

    // Step 1: Filter to last 28 days
    final cutoffDate = DateTime.now().subtract(const Duration(days: 28));
    final recentReadings =
        readings.where((r) => r.timestamp.isAfter(cutoffDate)).toList();

    if (recentReadings.isEmpty) return null;

    // Step 2: Group by day and calculate daily averages
    final dailyAverages = _calculateDailyAverages(recentReadings);

    // Check if we have enough days (minimum 20)
    if (dailyAverages.length < minDaysForBaseline) return null;

    // Step 3: Remove outliers (values beyond ±2 standard deviations)
    final cleanedData = _removeOutliers(dailyAverages);

    if (cleanedData.length < minDaysForBaseline) return null;

    // Step 4: Calculate 7-day rolling averages
    final rollingAverages = _calculateRollingAverages(cleanedData);

    if (rollingAverages.isEmpty) return null;

    // Step 5: Return mean of rolling averages as baseline
    final baseline =
        rollingAverages.reduce((a, b) => a + b) / rollingAverages.length;

    return baseline;
  }

  /// Calculate HRV deviation from baseline
  ///
  /// **Formula**: Deviation % = ((Current HRV - Baseline HRV) / Baseline HRV) × 100
  ///
  /// **Parameters**:
  /// - `currentReadings`: Recent HRV readings (ideally last 7 days)
  /// - `baseline`: Personal HRV baseline (from calculateBaseline)
  ///
  /// **Interpretation**:
  /// - Positive deviation: HRV above baseline (good recovery)
  /// - Negative deviation: HRV below baseline (fatigue/overtraining)
  ///
  /// **Returns**: Deviation percentage (e.g., -8.5 means 8.5% below baseline)
  double calculateDeviation({
    required List<HrvReading> currentReadings,
    required double baseline,
  }) {
    if (currentReadings.isEmpty || baseline == 0) return 0.0;

    // Calculate current HRV (average of recent readings)
    final currentHrv = currentReadings.map((r) => r.value).reduce((a, b) => a + b) /
        currentReadings.length;

    // Calculate % deviation
    final deviation = ((currentHrv - baseline) / baseline) * 100;

    return deviation;
  }

  /// Check if HRV baseline needs updating
  ///
  /// **Update Criteria**:
  /// - Last update was 7+ days ago
  /// - New readings available since last update
  /// - User's fitness level may have changed
  ///
  /// **Returns**: True if baseline should be recalculated
  bool shouldUpdateBaseline({
    required DateTime? lastUpdateDate,
    required List<HrvReading> newReadings,
  }) {
    if (lastUpdateDate == null) return true;

    final daysSinceUpdate =
        DateTime.now().difference(lastUpdateDate).inDays;

    // Update weekly
    if (daysSinceUpdate >= 7) return true;

    // Update if significant new data (10+ readings since last update)
    final newReadingsCount =
        newReadings.where((r) => r.timestamp.isAfter(lastUpdateDate)).length;
    if (newReadingsCount >= 10) return true;

    return false;
  }

  /// Assess recovery quality based on HRV deviation
  ///
  /// **Thresholds**:
  /// - Deviation > +5%: Excellent recovery
  /// - Deviation 0% to +5%: Good recovery
  /// - Deviation -5% to 0%: Acceptable recovery
  /// - Deviation -10% to -5%: Low recovery (monitor)
  /// - Deviation < -10%: Very low recovery (overtraining risk)
  ///
  /// **Returns**: Recovery quality descriptor
  RecoveryQuality assessRecoveryQuality(double deviation) {
    if (deviation > 5.0) return RecoveryQuality.excellent;
    if (deviation > 0.0) return RecoveryQuality.good;
    if (deviation > -5.0) return RecoveryQuality.acceptable;
    if (deviation > -10.0) return RecoveryQuality.low;
    return RecoveryQuality.veryLow;
  }

  // ========================================================================
  // Private Helper Methods
  // ========================================================================

  /// Group readings by day and calculate daily averages
  ///
  /// **Logic**: Multiple readings per day are averaged to smooth variability
  Map<DateTime, double> _calculateDailyAverages(List<HrvReading> readings) {
    final dailyGroups = <DateTime, List<double>>{};

    for (final reading in readings) {
      // Normalize to start of day for grouping
      final dayKey = DateTime(
        reading.timestamp.year,
        reading.timestamp.month,
        reading.timestamp.day,
      );

      dailyGroups.putIfAbsent(dayKey, () => []).add(reading.value);
    }

    // Calculate averages
    final dailyAverages = <DateTime, double>{};
    dailyGroups.forEach((day, values) {
      final average = values.reduce((a, b) => a + b) / values.length;
      dailyAverages[day] = average;
    });

    return dailyAverages;
  }

  /// Remove outliers using standard deviation method
  ///
  /// **Algorithm**: Remove values beyond ±2 standard deviations from mean
  List<double> _removeOutliers(Map<DateTime, double> dailyAverages) {
    final values = dailyAverages.values.toList();
    if (values.length < 3) return values; // Not enough data to detect outliers

    // Calculate mean
    final mean = values.reduce((a, b) => a + b) / values.length;

    // Calculate standard deviation
    final variance = values
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
        values.length;
    final stdDev = _sqrt(variance);

    // Filter values within ±2 standard deviations
    final cleaned = values
        .where((v) => (v - mean).abs() <= 2 * stdDev)
        .toList();

    return cleaned;
  }

  /// Calculate 7-day rolling averages
  ///
  /// **Logic**: Smooth day-to-day variability by averaging 7-day windows
  List<double> _calculateRollingAverages(List<double> values) {
    if (values.length < rollingWindowDays) return [];

    final rollingAverages = <double>[];

    for (int i = 0; i <= values.length - rollingWindowDays; i++) {
      final window = values.sublist(i, i + rollingWindowDays);
      final average = window.reduce((a, b) => a + b) / window.length;
      rollingAverages.add(average);
    }

    return rollingAverages;
  }

  /// Simple square root implementation (Newton's method)
  double _sqrt(double value) {
    if (value < 0) return 0;
    if (value == 0) return 0;

    double x = value;
    double y = 1.0;
    const epsilon = 0.00001;

    while ((x - y).abs() > epsilon) {
      x = (x + y) / 2;
      y = value / x;
    }

    return x;
  }
}

/// Recovery quality assessment based on HRV deviation
enum RecoveryQuality {
  /// Excellent recovery (HRV > +5% above baseline)
  excellent,

  /// Good recovery (HRV 0% to +5% above baseline)
  good,

  /// Acceptable recovery (HRV -5% to 0% below baseline)
  acceptable,

  /// Low recovery (HRV -10% to -5% below baseline) - Monitor closely
  low,

  /// Very low recovery (HRV < -10% below baseline) - Overtraining risk
  veryLow,
}

/// Extension on RecoveryQuality for convenience methods
extension RecoveryQualityExtension on RecoveryQuality {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case RecoveryQuality.excellent:
        return 'Excellent Recovery';
      case RecoveryQuality.good:
        return 'Good Recovery';
      case RecoveryQuality.acceptable:
        return 'Acceptable Recovery';
      case RecoveryQuality.low:
        return 'Low Recovery';
      case RecoveryQuality.veryLow:
        return 'Very Low Recovery';
    }
  }

  /// Emoji representation
  String get emoji {
    switch (this) {
      case RecoveryQuality.excellent:
        return '🔥';
      case RecoveryQuality.good:
        return '✅';
      case RecoveryQuality.acceptable:
        return '😐';
      case RecoveryQuality.low:
        return '⚠️';
      case RecoveryQuality.veryLow:
        return '🚨';
    }
  }

  /// Color for UI (semantic)
  String get colorName {
    switch (this) {
      case RecoveryQuality.excellent:
      case RecoveryQuality.good:
        return 'success';
      case RecoveryQuality.acceptable:
        return 'primary';
      case RecoveryQuality.low:
        return 'warning';
      case RecoveryQuality.veryLow:
        return 'error';
    }
  }

  /// Recommendation text
  String get recommendation {
    switch (this) {
      case RecoveryQuality.excellent:
        return 'Peak recovery! Great time for high-intensity training.';
      case RecoveryQuality.good:
        return 'Well-recovered. Continue current training load.';
      case RecoveryQuality.acceptable:
        return 'Adequate recovery. Maintain current intensity.';
      case RecoveryQuality.low:
        return 'Low recovery. Consider reducing volume or intensity.';
      case RecoveryQuality.veryLow:
        return 'Very low recovery. Rest day or deload strongly recommended.';
    }
  }
}
