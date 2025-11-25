# 📐 Analytics System - Technical Specifications

> **Created**: 2025-01-22
> **Purpose**: Specifiche tecniche dettagliate per POI calculation, balance indicators, data models
> **Related**: `ANALYTICS_ENHANCEMENT_MOCKUPS_UI.md`, `ANALYTICS_SYSTEM_OVERVIEW.md`

---

## 📋 Indice

1. [Progressive Overload Index (POI)](#progressive-overload-index-poi)
2. [Balance Indicators](#balance-indicators)
3. [Data Models & Entities](#data-models--entities)
4. [Repository & Providers](#repository--providers)
5. [Chart Calculations](#chart-calculations)
6. [Performance Optimization](#performance-optimization)
7. [Testing Strategy](#testing-strategy)

---

## 1️⃣ Progressive Overload Index (POI)

### 📊 Formula Matematica

**Progressive Overload Index (POI)** = Percentage change in volume over time period

```dart
POI = ((CurrentVolume - PreviousVolume) / PreviousVolume) * 100
```

**Where**:
- `CurrentVolume` = Total volume in selected period (last N weeks)
- `PreviousVolume` = Total volume in previous period of same length

**Example**:
```
Period: Last 12 weeks (2024-11-01 to 2025-01-22)
Previous: 12 weeks before (2024-08-01 to 2024-10-31)

Petto:
- Current: 4200 kg
- Previous: 3560 kg
- POI = ((4200 - 3560) / 3560) * 100 = +18.0%
```

### 🎯 POI Classification

```dart
enum POICategory {
  excellent,    // >+10%  - Optimal progressive overload
  good,         // +5-10% - Good progress
  slow,         // 0-5%   - Slow but positive
  stagnant,     // -5-0%  - Minimal regression
  plateau,      // <-5%   - Concerning plateau/regression
}

POICategory classifyPOI(double poiValue) {
  if (poiValue >= 10) return POICategory.excellent;
  if (poiValue >= 5) return POICategory.good;
  if (poiValue >= 0) return POICategory.slow;
  if (poiValue >= -5) return POICategory.stagnant;
  return POICategory.plateau;
}
```

### 💡 Weighted POI (Overall Score)

```dart
/// Calculate overall POI weighted by muscle group volume
double calculateWeightedPOI(Map<MuscleGroup, double> poiByMuscle, Map<MuscleGroup, double> volumeByMuscle) {
  double totalVolume = volumeByMuscle.values.reduce((a, b) => a + b);
  double weightedSum = 0.0;

  for (final muscle in MuscleGroup.values) {
    final weight = volumeByMuscle[muscle]! / totalVolume; // Percentage of total
    final poi = poiByMuscle[muscle]!;
    weightedSum += poi * weight;
  }

  return weightedSum;
}

// Example:
// Petto: +18% (28% of volume) → 18 * 0.28 = 5.04
// Schiena: +12% (25% of volume) → 12 * 0.25 = 3.00
// Gambe: +2% (21% of volume) → 2 * 0.21 = 0.42
// ... (continue for all muscles)
// Overall POI = sum of weighted values = ~12.5%
```

### 📈 POI Trend Analysis

**Detect patterns over time** (for AI insights):

```dart
class POITrend {
  final List<double> weeklyPOI; // POI values week by week
  final TrendDirection direction;
  final double volatility; // Standard deviation
  final bool isPlateaued;

  POITrend.calculate(List<double> weeklyPOI) {
    this.weeklyPOI = weeklyPOI;
    this.direction = _calculateDirection();
    this.volatility = _calculateStdDev();
    this.isPlateaued = _detectPlateau();
  }

  TrendDirection _calculateDirection() {
    // Linear regression slope
    final n = weeklyPOI.length;
    final xMean = (n - 1) / 2.0; // 0, 1, 2, ... n-1
    final yMean = weeklyPOI.reduce((a, b) => a + b) / n;

    double numerator = 0.0;
    double denominator = 0.0;

    for (int i = 0; i < n; i++) {
      numerator += (i - xMean) * (weeklyPOI[i] - yMean);
      denominator += (i - xMean) * (i - xMean);
    }

    final slope = numerator / denominator;

    if (slope > 0.5) return TrendDirection.increasing;
    if (slope < -0.5) return TrendDirection.decreasing;
    return TrendDirection.stable;
  }

  double _calculateStdDev() {
    final mean = weeklyPOI.reduce((a, b) => a + b) / weeklyPOI.length;
    final variance = weeklyPOI
        .map((value) => (value - mean) * (value - mean))
        .reduce((a, b) => a + b) / weeklyPOI.length;
    return sqrt(variance);
  }

  bool _detectPlateau() {
    // Plateau if last 3 weeks have POI < 2% AND trend is stable
    final lastThree = weeklyPOI.skip(weeklyPOI.length - 3).toList();
    final avgLastThree = lastThree.reduce((a, b) => a + b) / 3;
    return avgLastThree.abs() < 2.0 && direction == TrendDirection.stable;
  }
}

enum TrendDirection {
  increasing,  // Slope > +0.5
  stable,      // Slope between -0.5 and +0.5
  decreasing,  // Slope < -0.5
}
```

### 🧮 Implementation Example

```dart
/// Domain Entity
@freezed
class POIData with _$POIData {
  const factory POIData({
    required Map<MuscleGroup, double> poiByMuscle,
    required double overallPOI,
    required Map<MuscleGroup, POICategory> categoryByMuscle,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime comparisonStart,
    required DateTime comparisonEnd,
    required Map<MuscleGroup, POITrend> trendByMuscle,
  }) = _POIData;
}

/// Provider
@riverpod
Future<POIData> poiData(PoiDataRef ref, {
  required DateTime periodStart,
  required DateTime periodEnd,
}) async {
  final repository = ref.watch(analyticsRepositoryProvider);

  // Fetch current period data
  final currentData = await repository.getMuscleDistributionData(
    start: periodStart,
    end: periodEnd,
  );

  // Calculate previous period (same length)
  final periodLength = periodEnd.difference(periodStart);
  final comparisonEnd = periodStart.subtract(Duration(days: 1));
  final comparisonStart = comparisonEnd.subtract(periodLength);

  // Fetch previous period data
  final previousData = await repository.getMuscleDistributionData(
    start: comparisonStart,
    end: comparisonEnd,
  );

  // Calculate POI for each muscle
  final poiByMuscle = <MuscleGroup, double>{};
  final categoryByMuscle = <MuscleGroup, POICategory>{};

  for (final muscle in MuscleGroup.values) {
    final currentVolume = currentData.volumeByMuscle[muscle] ?? 0.0;
    final previousVolume = previousData.volumeByMuscle[muscle] ?? 0.0;

    final poi = previousVolume == 0
        ? 0.0
        : ((currentVolume - previousVolume) / previousVolume) * 100;

    poiByMuscle[muscle] = poi;
    categoryByMuscle[muscle] = classifyPOI(poi);
  }

  // Calculate overall weighted POI
  final overallPOI = calculateWeightedPOI(
    poiByMuscle,
    currentData.volumeByMuscle,
  );

  // Calculate trends (fetch weekly data for last 12 weeks)
  final trendByMuscle = await _calculateTrends(
    repository,
    periodStart,
    periodEnd,
  );

  return POIData(
    poiByMuscle: poiByMuscle,
    overallPOI: overallPOI,
    categoryByMuscle: categoryByMuscle,
    periodStart: periodStart,
    periodEnd: periodEnd,
    comparisonStart: comparisonStart,
    comparisonEnd: comparisonEnd,
    trendByMuscle: trendByMuscle,
  );
}
```

---

## 2️⃣ Balance Indicators

### ⚖️ Push/Pull Ratio

**Definition**: Ratio of volume between push muscles (Petto, Spalle, Triceps) and pull muscles (Schiena, Biceps)

```dart
class PushPullRatio {
  final double pushVolume;
  final double pullVolume;
  final double ratio; // pushVolume / pullVolume
  final BalanceStatus status;

  PushPullRatio.calculate({
    required Map<MuscleGroup, double> volumeByMuscle,
  }) {
    // Push muscles
    final petto = volumeByMuscle[MuscleGroup.petto] ?? 0.0;
    final spalle = volumeByMuscle[MuscleGroup.spalle] ?? 0.0;
    // Note: Triceps is part of "Braccia" - estimate 60% of arm volume
    final triceps = (volumeByMuscle[MuscleGroup.braccia] ?? 0.0) * 0.6;

    pushVolume = petto + spalle + triceps;

    // Pull muscles
    final schiena = volumeByMuscle[MuscleGroup.schiena] ?? 0.0;
    // Note: Biceps is part of "Braccia" - estimate 40% of arm volume
    final biceps = (volumeByMuscle[MuscleGroup.braccia] ?? 0.0) * 0.4;

    pullVolume = schiena + biceps;

    ratio = pullVolume == 0 ? 0.0 : pushVolume / pullVolume;
    status = _classifyBalance(ratio);
  }

  BalanceStatus _classifyBalance(double ratio) {
    // Ideal: 0.9 - 1.1 (90-110% = ±10%)
    if (ratio >= 0.9 && ratio <= 1.1) return BalanceStatus.balanced;

    // Warning: 0.8 - 0.9 or 1.1 - 1.2 (±10-20%)
    if ((ratio >= 0.8 && ratio < 0.9) || (ratio > 1.1 && ratio <= 1.2)) {
      return BalanceStatus.warning;
    }

    // Critical: <0.8 or >1.2 (>±20%)
    return BalanceStatus.critical;
  }

  String getRecommendation() {
    if (status == BalanceStatus.balanced) {
      return 'Ottimo bilanciamento push/pull. Mantieni così!';
    }

    if (ratio > 1.1) {
      final excess = ((ratio - 1.0) * 100).toStringAsFixed(0);
      return 'Push muscles +$excess% vs pull. Aggiungi volume per schiena/biceps.';
    }

    final deficit = ((1.0 - ratio) * 100).toStringAsFixed(0);
    return 'Pull muscles +$deficit% vs push. Aggiungi volume per petto/spalle/triceps.';
  }
}

enum BalanceStatus {
  balanced,  // Green - optimal
  warning,   // Yellow - attention needed
  critical,  // Red - action required
}
```

### 📊 Upper/Lower Split Ratio

```dart
class UpperLowerRatio {
  final double upperVolume;
  final double lowerVolume;
  final double ratio; // upperVolume / lowerVolume
  final BalanceStatus status;

  UpperLowerRatio.calculate({
    required Map<MuscleGroup, double> volumeByMuscle,
  }) {
    // Upper muscles
    final petto = volumeByMuscle[MuscleGroup.petto] ?? 0.0;
    final schiena = volumeByMuscle[MuscleGroup.schiena] ?? 0.0;
    final spalle = volumeByMuscle[MuscleGroup.spalle] ?? 0.0;
    final braccia = volumeByMuscle[MuscleGroup.braccia] ?? 0.0;

    upperVolume = petto + schiena + spalle + braccia;

    // Lower muscles
    final gambe = volumeByMuscle[MuscleGroup.gambe] ?? 0.0;
    // Note: Core/Addome not counted in upper/lower

    lowerVolume = gambe;

    ratio = lowerVolume == 0 ? 0.0 : upperVolume / lowerVolume;
    status = _classifyBalance(ratio);
  }

  BalanceStatus _classifyBalance(double ratio) {
    // Ideal: 1.4 - 1.6 (60/40 split = 1.5 ratio)
    // Rationale: Upper body has more muscle groups (chest, back, shoulders, arms)
    //            vs lower (legs). 60/40 is typical split.
    if (ratio >= 1.4 && ratio <= 1.6) return BalanceStatus.balanced;

    // Warning: 1.2 - 1.4 or 1.6 - 1.8
    if ((ratio >= 1.2 && ratio < 1.4) || (ratio > 1.6 && ratio <= 1.8)) {
      return BalanceStatus.warning;
    }

    // Critical: <1.2 or >1.8
    return BalanceStatus.critical;
  }

  String getRecommendation() {
    if (status == BalanceStatus.balanced) {
      return 'Split upper/lower ottimale (60/40). Continua così!';
    }

    if (ratio > 1.6) {
      final upperPercent = (ratio / (ratio + 1) * 100).toStringAsFixed(0);
      return 'Troppo focus su upper body ($upperPercent%). Aumenta volume gambe.';
    }

    final lowerPercent = (1 / (ratio + 1) * 100).toStringAsFixed(0);
    return 'Troppo focus su lower body ($lowerPercent%). Bilancia con upper.';
  }
}
```

### 🔥 Core Engagement

```dart
class CoreEngagement {
  final double coreVolume;
  final double totalVolume;
  final double percentage; // coreVolume / totalVolume * 100
  final BalanceStatus status;

  CoreEngagement.calculate({
    required Map<MuscleGroup, double> volumeByMuscle,
  }) {
    coreVolume = volumeByMuscle[MuscleGroup.addome] ?? 0.0;
    totalVolume = volumeByMuscle.values.reduce((a, b) => a + b);

    percentage = totalVolume == 0 ? 0.0 : (coreVolume / totalVolume) * 100;
    status = _classifyEngagement(percentage);
  }

  BalanceStatus _classifyEngagement(double percent) {
    // Ideal: 12-15% of total volume
    // Rationale: Core should be trained but not dominate program
    if (percent >= 12 && percent <= 15) return BalanceStatus.balanced;

    // Warning: 8-12% or 15-18%
    if ((percent >= 8 && percent < 12) || (percent > 15 && percent <= 18)) {
      return BalanceStatus.warning;
    }

    // Critical: <8% or >18%
    return BalanceStatus.critical;
  }

  String getRecommendation() {
    if (status == BalanceStatus.balanced) {
      return 'Core engagement ottimale (12-15% volume). Perfetto!';
    }

    if (percentage < 12) {
      final deficit = (12 - percentage).toStringAsFixed(1);
      return 'Core sotto target (-$deficit%). Aggiungi 2-3 set core per workout.';
    }

    final excess = (percentage - 15).toStringAsFixed(1);
    return 'Core volume alto (+$excess%). Bilancia con altri muscle groups.';
  }
}
```

### 🎯 Overall Balance Score

```dart
/// Combined balance score (0-100)
class OverallBalanceScore {
  final double score; // 0-100
  final String grade; // A+, A, B, C, D, F
  final List<String> strengths;
  final List<String> weaknesses;

  OverallBalanceScore.calculate({
    required PushPullRatio pushPull,
    required UpperLowerRatio upperLower,
    required CoreEngagement core,
  }) {
    // Score each component 0-100
    final pushPullScore = _scoreBalance(pushPull.status);
    final upperLowerScore = _scoreBalance(upperLower.status);
    final coreScore = _scoreBalance(core.status);

    // Weighted average (push/pull most important)
    score = (pushPullScore * 0.5) + (upperLowerScore * 0.3) + (coreScore * 0.2);

    grade = _calculateGrade(score);
    strengths = _identifyStrengths(pushPull, upperLower, core);
    weaknesses = _identifyWeaknesses(pushPull, upperLower, core);
  }

  double _scoreBalance(BalanceStatus status) {
    switch (status) {
      case BalanceStatus.balanced:
        return 100.0;
      case BalanceStatus.warning:
        return 70.0;
      case BalanceStatus.critical:
        return 40.0;
    }
  }

  String _calculateGrade(double score) {
    if (score >= 95) return 'A+';
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  List<String> _identifyStrengths(PushPullRatio pp, UpperLowerRatio ul, CoreEngagement c) {
    final strengths = <String>[];
    if (pp.status == BalanceStatus.balanced) strengths.add('Push/Pull bilanciato');
    if (ul.status == BalanceStatus.balanced) strengths.add('Upper/Lower split ottimale');
    if (c.status == BalanceStatus.balanced) strengths.add('Core engagement corretto');
    return strengths;
  }

  List<String> _identifyWeaknesses(PushPullRatio pp, UpperLowerRatio ul, CoreEngagement c) {
    final weaknesses = <String>[];
    if (pp.status == BalanceStatus.critical) weaknesses.add('Push/Pull sbilanciato');
    if (ul.status == BalanceStatus.critical) weaknesses.add('Upper/Lower sbilanciato');
    if (c.status == BalanceStatus.critical) weaknesses.add('Core trascurato');
    return weaknesses;
  }
}
```

---

## 3️⃣ Data Models & Entities

### 📦 POI Entity (Freezed)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'poi_data.freezed.dart';
part 'poi_data.g.dart';

@freezed
class POIData with _$POIData {
  const factory POIData({
    required Map<MuscleGroup, double> poiByMuscle,
    required double overallPOI,
    required Map<MuscleGroup, POICategory> categoryByMuscle,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime comparisonStart,
    required DateTime comparisonEnd,
    required Map<MuscleGroup, POITrend> trendByMuscle,
  }) = _POIData;

  factory POIData.fromJson(Map<String, dynamic> json) => _$POIDataFromJson(json);
}

@freezed
class POITrend with _$POITrend {
  const factory POITrend({
    required List<double> weeklyPOI,
    required TrendDirection direction,
    required double volatility,
    required bool isPlateaued,
  }) = _POITrend;

  factory POITrend.fromJson(Map<String, dynamic> json) => _$POITrendFromJson(json);
}

enum POICategory {
  @JsonValue('excellent') excellent,
  @JsonValue('good') good,
  @JsonValue('slow') slow,
  @JsonValue('stagnant') stagnant,
  @JsonValue('plateau') plateau,
}

enum TrendDirection {
  @JsonValue('increasing') increasing,
  @JsonValue('stable') stable,
  @JsonValue('decreasing') decreasing,
}
```

### 📦 Balance Indicators Entity

```dart
@freezed
class BalanceIndicators with _$BalanceIndicators {
  const factory BalanceIndicators({
    required PushPullRatio pushPull,
    required UpperLowerRatio upperLower,
    required CoreEngagement core,
    required OverallBalanceScore overallScore,
    required DateTime calculatedAt,
  }) = _BalanceIndicators;

  factory BalanceIndicators.fromJson(Map<String, dynamic> json) =>
      _$BalanceIndicatorsFromJson(json);
}

@freezed
class PushPullRatio with _$PushPullRatio {
  const factory PushPullRatio({
    required double pushVolume,
    required double pullVolume,
    required double ratio,
    required BalanceStatus status,
    required String recommendation,
  }) = _PushPullRatio;

  factory PushPullRatio.fromJson(Map<String, dynamic> json) =>
      _$PushPullRatioFromJson(json);
}

@freezed
class UpperLowerRatio with _$UpperLowerRatio {
  const factory UpperLowerRatio({
    required double upperVolume,
    required double lowerVolume,
    required double ratio,
    required BalanceStatus status,
    required String recommendation,
  }) = _UpperLowerRatio;

  factory UpperLowerRatio.fromJson(Map<String, dynamic> json) =>
      _$UpperLowerRatioFromJson(json);
}

@freezed
class CoreEngagement with _$CoreEngagement {
  const factory CoreEngagement({
    required double coreVolume,
    required double totalVolume,
    required double percentage,
    required BalanceStatus status,
    required String recommendation,
  }) = _CoreEngagement;

  factory CoreEngagement.fromJson(Map<String, dynamic> json) =>
      _$CoreEngagementFromJson(json);
}

@freezed
class OverallBalanceScore with _$OverallBalanceScore {
  const factory OverallBalanceScore({
    required double score,
    required String grade,
    required List<String> strengths,
    required List<String> weaknesses,
  }) = _OverallBalanceScore;

  factory OverallBalanceScore.fromJson(Map<String, dynamic> json) =>
      _$OverallBalanceScoreFromJson(json);
}

enum BalanceStatus {
  @JsonValue('balanced') balanced,
  @JsonValue('warning') warning,
  @JsonValue('critical') critical,
}
```

### 📦 Chart Data Models

```dart
/// Multi-line chart data point
@freezed
class MultiLineChartData with _$MultiLineChartData {
  const factory MultiLineChartData({
    required DateTime date,
    required Map<MuscleGroup, double> volumeByMuscle,
  }) = _MultiLineChartData;

  factory MultiLineChartData.fromJson(Map<String, dynamic> json) =>
      _$MultiLineChartDataFromJson(json);
}

/// Comparison data (current vs previous period)
@freezed
class ComparisonData with _$ComparisonData {
  const factory ComparisonData({
    required Map<MuscleGroup, double> currentVolume,
    required Map<MuscleGroup, double> previousVolume,
    required Map<MuscleGroup, double> deltaPercentage,
    required double totalCurrentVolume,
    required double totalPreviousVolume,
    required double totalDeltaPercentage,
  }) = _ComparisonData;

  factory ComparisonData.fromJson(Map<String, dynamic> json) =>
      _$ComparisonDataFromJson(json);
}
```

---

## 4️⃣ Repository & Providers

### 🏗️ Analytics Repository Interface

```dart
abstract class AnalyticsRepository {
  /// Get muscle distribution for a specific period
  Future<MuscleDistributionData> getMuscleDistributionData({
    required DateTime start,
    required DateTime end,
  });

  /// Get weekly aggregated data for multi-line chart
  Future<List<MultiLineChartData>> getWeeklyVolumeData({
    required DateTime start,
    required DateTime end,
  });

  /// Get POI data with automatic comparison period calculation
  Future<POIData> getPOIData({
    required DateTime periodStart,
    required DateTime periodEnd,
  });

  /// Get balance indicators
  Future<BalanceIndicators> getBalanceIndicators({
    required DateTime start,
    required DateTime end,
  });

  /// Get comparison data (current vs previous)
  Future<ComparisonData> getComparisonData({
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  });
}
```

### 📡 Riverpod Providers

```dart
/// POI Data Provider (with period selection)
@riverpod
Future<POIData> poiData(
  PoiDataRef ref, {
  required DateTime periodStart,
  required DateTime periodEnd,
}) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getPOIData(
    periodStart: periodStart,
    periodEnd: periodEnd,
  );
}

/// Balance Indicators Provider
@riverpod
Future<BalanceIndicators> balanceIndicators(
  BalanceIndicatorsRef ref, {
  required DateTime start,
  required DateTime end,
}) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getBalanceIndicators(
    start: start,
    end: end,
  );
}

/// Multi-line chart data provider
@riverpod
Future<List<MultiLineChartData>> multiLineChartData(
  MultiLineChartDataRef ref, {
  required DateTime start,
  required DateTime end,
}) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getWeeklyVolumeData(
    start: start,
    end: end,
  );
}

/// Selected period state provider
@riverpod
class SelectedPeriod extends _$SelectedPeriod {
  @override
  ({DateTime start, DateTime end}) build() {
    // Default: Last 30 days
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    return (start: start, end: end);
  }

  void setLast7Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    state = (start: start, end: end);
  }

  void setLast30Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    state = (start: start, end: end);
  }

  void setLast3Months() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 90));
    state = (start: start, end: end);
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = (start: start, end: end);
  }
}

/// Selected metric state provider
@riverpod
class SelectedMetric extends _$SelectedMetric {
  @override
  MetricType build() => MetricType.volumeKg;

  void setMetric(MetricType metric) {
    state = metric;
  }
}

enum MetricType {
  volumeKg,
  volumePercent,
  sets,
  reps,
  intensity1RM,
  frequency,
}
```

---

## 5️⃣ Chart Calculations

### 📊 Bar Chart Data Transformation

```dart
/// Transform muscle distribution data for bar chart
List<BarChartGroupData> transformToBarChart({
  required Map<MuscleGroup, double> volumeByMuscle,
  required MetricType metric,
  required Map<MuscleGroup, double>? previousVolume, // For comparison arrows
}) {
  final totalVolume = volumeByMuscle.values.reduce((a, b) => a + b);

  return MuscleGroup.values.asMap().entries.map((entry) {
    final index = entry.key;
    final muscle = entry.value;
    final volume = volumeByMuscle[muscle] ?? 0.0;

    // Calculate value based on metric type
    final double value;
    switch (metric) {
      case MetricType.volumeKg:
        value = volume;
        break;
      case MetricType.volumePercent:
        value = totalVolume == 0 ? 0.0 : (volume / totalVolume) * 100;
        break;
      // ... other metrics
    }

    // Calculate delta if previous data available
    final double? deltaPercent;
    if (previousVolume != null) {
      final prevVolume = previousVolume[muscle] ?? 0.0;
      deltaPercent = prevVolume == 0
          ? null
          : ((volume - prevVolume) / prevVolume) * 100;
    } else {
      deltaPercent = null;
    }

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: value,
          color: _getMuscleColor(muscle),
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();
}

Color _getMuscleColor(MuscleGroup muscle) {
  switch (muscle) {
    case MuscleGroup.petto:
      return const Color(0xFFE53935); // Red
    case MuscleGroup.schiena:
      return const Color(0xFF1E88E5); // Blue
    case MuscleGroup.gambe:
      return const Color(0xFF43A047); // Green
    case MuscleGroup.spalle:
      return const Color(0xFFFB8C00); // Orange
    case MuscleGroup.braccia:
      return const Color(0xFF8E24AA); // Purple
    case MuscleGroup.addome:
      return const Color(0xFFFFB300); // Amber
  }
}
```

### 📈 Multi-Line Chart Data Transformation

```dart
/// Transform weekly data to multi-line chart format
Map<MuscleGroup, List<FlSpot>> transformToMultiLineChart({
  required List<MultiLineChartData> weeklyData,
}) {
  final Map<MuscleGroup, List<FlSpot>> linesByMuscle = {};

  for (final muscle in MuscleGroup.values) {
    linesByMuscle[muscle] = [];
  }

  for (int i = 0; i < weeklyData.length; i++) {
    final dataPoint = weeklyData[i];

    for (final muscle in MuscleGroup.values) {
      final volume = dataPoint.volumeByMuscle[muscle] ?? 0.0;
      linesByMuscle[muscle]!.add(FlSpot(i.toDouble(), volume));
    }
  }

  return linesByMuscle;
}

/// Create LineChartData for fl_chart
LineChartData createMultiLineChart({
  required Map<MuscleGroup, List<FlSpot>> linesByMuscle,
  required Set<MuscleGroup> visibleMuscles, // User can toggle visibility
}) {
  final lines = <LineChartBarData>[];

  for (final muscle in visibleMuscles) {
    final spots = linesByMuscle[muscle]!;

    lines.add(
      LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: _getMuscleColor(muscle),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: _getMuscleColor(muscle),
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
    );
  }

  return LineChartData(
    lineBarsData: lines,
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            // Show "W1", "W2", etc.
            return Text('W${value.toInt() + 1}');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            // Show volume in kg
            return Text('${value.toInt()}kg');
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 500, // Grid every 500kg
      verticalInterval: 1, // Grid every week
    ),
    borderData: FlBorderData(show: false),
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.blueGrey.withValues(alpha: 0.8),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final muscle = visibleMuscles.elementAt(spot.barIndex);
            return LineTooltipItem(
              '${muscle.name}\n${spot.y.toStringAsFixed(0)}kg',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          }).toList();
        },
      ),
    ),
  );
}
```

---

## 6️⃣ Performance Optimization

### ⚡ Caching Strategy

```dart
/// Cache POI calculations locally (avoid re-calculation)
@riverpod
Future<POIData> cachedPOIData(
  CachedPoiDataRef ref, {
  required DateTime periodStart,
  required DateTime periodEnd,
}) async {
  final cacheKey = 'poi_${periodStart.millisecondsSinceEpoch}_${periodEnd.millisecondsSinceEpoch}';

  // Check Hive cache first
  final hiveBox = await Hive.openBox<String>('analytics_cache');
  final cachedJson = hiveBox.get(cacheKey);

  if (cachedJson != null) {
    final json = jsonDecode(cachedJson) as Map<String, dynamic>;
    return POIData.fromJson(json);
  }

  // Not cached, fetch from repository
  final repository = ref.watch(analyticsRepositoryProvider);
  final data = await repository.getPOIData(
    periodStart: periodStart,
    periodEnd: periodEnd,
  );

  // Cache for 1 hour
  await hiveBox.put(cacheKey, jsonEncode(data.toJson()));

  // Auto-invalidate after 1 hour
  Timer(const Duration(hours: 1), () {
    ref.invalidateSelf();
  });

  return data;
}
```

### 🔄 Data Aggregation

```dart
/// Pre-aggregate weekly data in Firestore for faster queries
///
/// Instead of fetching all exercise sessions and calculating on-the-fly,
/// store pre-calculated weekly aggregates in separate collection.
///
/// Collection: analytics_weekly_aggregates/{userId}/weeks/{weekId}
/// Document structure:
/// {
///   weekStart: Timestamp,
///   weekEnd: Timestamp,
///   volumeByMuscle: {
///     'petto': 4200.0,
///     'schiena': 3800.0,
///     ...
///   },
///   setsByMuscle: {
///     'petto': 52,
///     'schiena': 48,
///     ...
///   },
///   lastUpdated: Timestamp,
/// }
///
/// Benefits:
/// - Query 12 weeks = fetch 12 documents (instead of 1000+ exercise sessions)
/// - Reduce Firebase read costs
/// - Faster chart rendering

class AnalyticsAggregationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Aggregate workout data weekly (run on workout completion)
  Future<void> aggregateWeeklyData(String userId) async {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = _getWeekEnd(now);

    // Fetch all workouts in current week
    final workouts = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: weekStart)
        .where('date', isLessThan: weekEnd)
        .get();

    // Calculate aggregates
    final volumeByMuscle = <String, double>{};
    final setsByMuscle = <String, int>{};

    for (final doc in workouts.docs) {
      // ... calculate volume and sets per muscle
    }

    // Store in weekly aggregates collection
    final weekId = '${weekStart.year}-W${_getWeekNumber(weekStart)}';
    await _firestore
        .collection('analytics_weekly_aggregates')
        .doc(userId)
        .collection('weeks')
        .doc(weekId)
        .set({
      'weekStart': weekStart,
      'weekEnd': weekEnd,
      'volumeByMuscle': volumeByMuscle,
      'setsByMuscle': setsByMuscle,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  DateTime _getWeekStart(DateTime date) {
    // Monday of current week (ISO 8601)
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getWeekEnd(DateTime date) {
    // Sunday of current week
    return _getWeekStart(date).add(const Duration(days: 7));
  }

  int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear + DateTime(date.year, 1, 1).weekday - 1) / 7).floor() + 1;
  }
}
```

### 🎯 Lazy Loading

```dart
/// Load chart data incrementally (pagination for long time periods)
@riverpod
class PaginatedChartData extends _$PaginatedChartData {
  static const int _itemsPerPage = 12; // 12 weeks per page
  int _currentPage = 0;

  @override
  Future<List<MultiLineChartData>> build() async {
    return _fetchPage(_currentPage);
  }

  Future<void> loadMore() async {
    _currentPage++;
    final nextPage = await _fetchPage(_currentPage);
    state = AsyncValue.data([...state.value!, ...nextPage]);
  }

  Future<List<MultiLineChartData>> _fetchPage(int page) async {
    final repository = ref.watch(analyticsRepositoryProvider);
    final end = DateTime.now().subtract(Duration(days: page * 7 * _itemsPerPage));
    final start = end.subtract(Duration(days: 7 * _itemsPerPage));

    return repository.getWeeklyVolumeData(start: start, end: end);
  }
}
```

---

## 7️⃣ Testing Strategy

### 🧪 Unit Tests

```dart
// test/features/analytics/domain/services/poi_calculator_test.dart

void main() {
  group('POI Calculation', () {
    test('calculates POI correctly for positive progress', () {
      final current = 4200.0;
      final previous = 3560.0;

      final poi = ((current - previous) / previous) * 100;

      expect(poi, closeTo(18.0, 0.1));
    });

    test('classifies POI as excellent when >10%', () {
      final poi = 18.0;
      final category = classifyPOI(poi);

      expect(category, POICategory.excellent);
    });

    test('handles zero previous volume gracefully', () {
      final current = 4200.0;
      final previous = 0.0;

      final poi = previous == 0 ? 0.0 : ((current - previous) / previous) * 100;

      expect(poi, 0.0); // Should not throw
    });
  });

  group('Weighted POI', () {
    test('calculates weighted POI correctly', () {
      final poiByMuscle = {
        MuscleGroup.petto: 18.0,   // 28% volume
        MuscleGroup.schiena: 12.0, // 25% volume
        MuscleGroup.gambe: 2.0,    // 21% volume
        MuscleGroup.spalle: -5.0,  // 16% volume
        MuscleGroup.braccia: 8.0,  // 11% volume
        MuscleGroup.addome: 0.0,   // 5% volume
      };

      final volumeByMuscle = {
        MuscleGroup.petto: 4200.0,
        MuscleGroup.schiena: 3800.0,
        MuscleGroup.gambe: 3200.0,
        MuscleGroup.spalle: 2400.0,
        MuscleGroup.braccia: 1600.0,
        MuscleGroup.addome: 800.0,
      };

      final weightedPOI = calculateWeightedPOI(poiByMuscle, volumeByMuscle);

      // Expected: (18*0.28) + (12*0.25) + (2*0.21) + (-5*0.16) + (8*0.11) + (0*0.05)
      //         = 5.04 + 3.00 + 0.42 - 0.80 + 0.88 + 0 = 8.54
      expect(weightedPOI, closeTo(8.54, 0.1));
    });
  });

  group('Balance Indicators', () {
    test('classifies push/pull ratio as balanced when ratio is 1.0', () {
      final volumeByMuscle = {
        MuscleGroup.petto: 4000.0,    // Push
        MuscleGroup.spalle: 2000.0,   // Push
        MuscleGroup.braccia: 2000.0,  // Push 60%, Pull 40%
        MuscleGroup.schiena: 6800.0,  // Pull
      };

      final pushPull = PushPullRatio.calculate(volumeByMuscle: volumeByMuscle);

      // Push: 4000 + 2000 + (2000*0.6) = 7200
      // Pull: 6800 + (2000*0.4) = 7600
      // Ratio: 7200 / 7600 = 0.947 ≈ 0.95 (within 0.9-1.1 range)
      expect(pushPull.status, BalanceStatus.balanced);
    });

    test('classifies core engagement as warning when <12%', () {
      final volumeByMuscle = {
        MuscleGroup.petto: 4000.0,
        MuscleGroup.schiena: 4000.0,
        MuscleGroup.gambe: 3000.0,
        MuscleGroup.spalle: 2000.0,
        MuscleGroup.braccia: 1500.0,
        MuscleGroup.addome: 800.0,    // 5.2% of total
      };

      final core = CoreEngagement.calculate(volumeByMuscle: volumeByMuscle);

      expect(core.percentage, closeTo(5.2, 0.1));
      expect(core.status, BalanceStatus.warning);
    });
  });
}
```

### 🎯 Widget Tests

```dart
// test/features/analytics/presentation/widgets/poi_score_widget_test.dart

void main() {
  testWidgets('POI score widget displays correct color for excellent category', (tester) async {
    final poiData = POIData(
      poiByMuscle: {MuscleGroup.petto: 18.0},
      categoryByMuscle: {MuscleGroup.petto: POICategory.excellent},
      // ... other fields
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POIScoreWidget(data: poiData),
        ),
      ),
    );

    // Find green bar for excellent category
    final barFinder = find.byType(Container).first;
    final container = tester.widget<Container>(barFinder);
    final decoration = container.decoration as BoxDecoration;

    expect(decoration.color, const Color(0xFF4CAF50)); // Green
  });
}
```

### 🔍 Integration Tests

```dart
// integration_test/analytics_flow_test.dart

void main() {
  testWidgets('Complete analytics flow with POI and balance', (tester) async {
    // 1. Navigate to Analytics tab
    await tester.tap(find.byIcon(Icons.analytics));
    await tester.pumpAndSettle();

    // 2. Select "Progressive Overload" tab
    await tester.tap(find.text('Progressive Overload'));
    await tester.pumpAndSettle();

    // 3. Verify POI scores loaded
    expect(find.textContaining('%'), findsAtLeastNWidgets(6)); // 6 muscle groups

    // 4. Tap muscle for detailed breakdown
    await tester.tap(find.text('Petto'));
    await tester.pumpAndSettle();

    // 5. Verify expanded card shows top exercises
    expect(find.textContaining('Bench Press'), findsOneWidget);

    // 6. Change period to 6 months
    await tester.tap(find.text('6m'));
    await tester.pumpAndSettle();

    // 7. Verify data reloaded
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
```

---

## 📚 Implementation Checklist

### Phase 1: POI Implementation
- [ ] Create POI entity with freezed
- [ ] Implement POI calculation logic
- [ ] Add POI repository methods
- [ ] Create POI provider
- [ ] Build POI score summary widget
- [ ] Add multi-line progression chart
- [ ] Implement expandable breakdown cards
- [ ] Unit tests for POI calculation
- [ ] Widget tests for POI UI

### Phase 2: Balance Indicators
- [ ] Create balance indicator entities
- [ ] Implement push/pull ratio calculation
- [ ] Implement upper/lower ratio calculation
- [ ] Implement core engagement calculation
- [ ] Create overall balance score
- [ ] Build balance indicator widgets
- [ ] Add recommendations logic
- [ ] Unit tests for balance calculations
- [ ] Widget tests for balance UI

### Phase 3: Advanced Features
- [ ] Implement weekly data aggregation (Firestore)
- [ ] Add caching with Hive
- [ ] Create lazy loading for chart data
- [ ] Build body heatmap visual
- [ ] Implement comparison mode
- [ ] Add AI insights generator
- [ ] Export to PDF functionality
- [ ] Integration tests for complete flow

---

## 🔗 Related Documentation

- **UI Mockups**: `ANALYTICS_ENHANCEMENT_MOCKUPS_UI.md`
- **System Overview**: `ANALYTICS_SYSTEM_OVERVIEW.md`
- **Muscle Distribution**: `MUSCLE_DISTRIBUTION_DOCUMENTATION.md`
- **Design Guidelines**: `DESIGN_GUIDELINES.md`

---

**Status**: ✅ Technical specs complete - Ready for implementation

**Next Steps**: Begin Phase 1 (POI implementation) with TodoWrite task planning
