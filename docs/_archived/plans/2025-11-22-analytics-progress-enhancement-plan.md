# Analytics Progress Tab Enhancement - Task Plan

**Generated**: 2025-11-22 16:45
**Source**: task-master.dev (WebFetch) + Claude Code enrichment
**Complexity Score**: HIGH
**Reason**: Multi-layer feature (Domain/Data/Presentation) + New calculations (POI, Balance) + Multiple charts + 17 tasks
**Total Tasks**: 17
**Estimated Time**: ~9.5-11 hours
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- Key Packages: flutter_riverpod ^2.4.9, hive_flutter ^1.1.0, fl_chart (charting), firebase_core (backend)
- Target Platforms: iOS 14+, Android 8+
- Related PRs/Issues: None
- Parent Milestone: None
- Last Commit: c1f405a5 fix: add ignore:timer comment

---

## 📋 Original Request

> Enhance Analytics Progress Tab with:
> 1. Progressive Overload Index (POI) calculation and visualization
> 2. Balance indicators (Push/Pull, Upper/Lower, Core engagement)
> 3. Enhanced muscle group tracking with bar charts, line charts, and multi-metric support
> 4. Period selector (7d/30d/3m/6m/1y/All) and metric toggle (Volume kg/Sets/Reps/%)
> 5. AI insights for premium users
>
> **Integration**: Modify existing `analytics_progress_tab.dart` (currently basic/empty)
> **Navigation**: Home → Analytics → Progress Tab (Tab 1 - trendUp icon)

---

## 🎯 Task Breakdown

### 1. Domain Layer (3 tasks)

---

#### Task 1.1: Create POI Data Entity

- **Layer**: Domain/Entities
- **Files**: `lib/features/analytics/domain/entities/poi_data.dart`
- **Dependencies**: None
- **Est. Time**: 20 min
- **Blocking**: Yes (blocks Task 1.2, 2.1, 3.4)
- **Verification**: `flutter analyze` passes + entity instantiation works in unit test

**Description**:
Create freezed entity with fields:
- `currentValue` (double)
- `previousValue` (double)
- `poiPercentage` (double) - calculated as `((current - previous) / previous) * 100`
- `timestamp` (DateTime)
- `muscleGroup` (MuscleGroup enum)
- `category` (POICategory enum: excellent/good/slow/stagnant/plateau)

**Code Prompt**:
```dart
@freezed
class POIData with _$POIData {
  const factory POIData({
    required double currentValue,
    required double previousValue,
    required double poiPercentage,
    required DateTime timestamp,
    required MuscleGroup muscleGroup,
    required POICategory category,
  }) = _POIData;

  factory POIData.fromJson(Map<String, dynamic> json) => _$POIDataFromJson(json);
}

enum POICategory {
  excellent,  // >+10%
  good,       // +5-10%
  slow,       // 0-5%
  stagnant,   // -5-0%
  plateau,    // <-5%
}
```

**FitLog Pro Requirements**:
- ✅ No hardcoded strings (use enum names)
- ✅ Use freezed + json_serializable pattern
- ✅ Follow naming conventions (camelCase)

---

#### Task 1.2: Create Balance Indicators Entity

- **Layer**: Domain/Entities
- **Files**: `lib/features/analytics/domain/entities/balance_indicators.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 25 min
- **Blocking**: Yes (blocks Task 2.2, 3.2)
- **Verification**: Unit test validates ratio calculations within 0-100% bounds

**Description**:
Create freezed entity for balance metrics:
- `pushPullRatio` (double) - Push volume / Pull volume
- `upperLowerRatio` (double) - Upper body / Lower body volume
- `coreEngagement` (double) - Core volume / Total volume (percentage)
- `pushPullStatus` (BalanceStatus enum: balanced/warning/critical)
- `upperLowerStatus` (BalanceStatus)
- `timestamp` (DateTime)

**Code Prompt**:
```dart
@freezed
class BalanceIndicators with _$BalanceIndicators {
  const factory BalanceIndicators({
    required double pushPullRatio,
    required double upperLowerRatio,
    required double coreEngagement,
    required BalanceStatus pushPullStatus,
    required BalanceStatus upperLowerStatus,
    required DateTime timestamp,
  }) = _BalanceIndicators;

  factory BalanceIndicators.fromJson(Map<String, dynamic> json) =>
      _$BalanceIndicatorsFromJson(json);
}

enum BalanceStatus {
  balanced,  // Ratio 0.9-1.1 (±10%)
  warning,   // Ratio 0.8-0.9 or 1.1-1.2 (±20%)
  critical,  // Ratio <0.8 or >1.2
}
```

**Calculation Logic**:
```dart
// Push: Petto + Spalle + Triceps (60% of Braccia)
// Pull: Schiena + Biceps (40% of Braccia)
// Upper: Petto + Spalle + Schiena + Braccia
// Lower: Gambe
// Core: Addome
```

---

#### Task 1.3: Define Analytics Repository Interface

- **Layer**: Domain/Repositories
- **Files**: `lib/features/analytics/domain/repositories/analytics_repository.dart` (existing - add methods)
- **Dependencies**: Tasks 1.1, 1.2
- **Est. Time**: 15 min
- **Blocking**: Yes (blocks all Data layer tasks 2.1-2.4)
- **Verification**: Interface compiles + all methods properly typed

**Description**:
Add abstract methods to existing repository interface:

```dart
abstract class AnalyticsRepository {
  // Existing methods...

  // NEW: POI calculation
  Future<Map<MuscleGroup, POIData>> calculatePOI({
    required DateTime periodStart,
    required DateTime periodEnd,
  });

  // NEW: Balance indicators
  Future<BalanceIndicators> getBalanceIndicators({
    required DateTime periodStart,
    required DateTime periodEnd,
  });

  // NEW: Muscle group metrics with period/metric filters
  Future<Map<MuscleGroup, double>> getMuscleGroupMetrics({
    required DateTime periodStart,
    required DateTime periodEnd,
    required MetricType metric, // Volume/Sets/Reps/%
  });

  // NEW: Weekly aggregated data for performance
  Future<List<WeeklyAggregate>> getWeeklyAggregates({
    required DateTime periodStart,
    required DateTime periodEnd,
  });
}
```

---

### 2. Data Layer (4 tasks)

---

#### Task 2.1: Implement POI Calculation Logic

- **Layer**: Data/UseCases
- **Files**: `lib/features/analytics/data/services/poi_calculator.dart` (NEW)
- **Dependencies**: Tasks 1.1, 1.3
- **Est. Time**: 30 min
- **Blocking**: Yes (blocks Task 2.4, 3.4)
- **Verification**: Unit test with 5+ scenarios (positive/negative/zero deltas) + edge cases pass

**Description**:
Create POI calculator service with formula implementation + null safety.

**Code Prompt**:
```dart
class POICalculator {
  /// Calculates POI percentage: ((current - previous) / previous) * 100
  /// Returns 0.0 if previous is 0 (avoid division by zero)
  static double calculatePOI({
    required double currentValue,
    required double previousValue,
  }) {
    if (previousValue == 0) return 0.0;
    return ((currentValue - previousValue) / previousValue) * 100;
  }

  /// Classifies POI into category
  static POICategory classifyPOI(double poiPercentage) {
    if (poiPercentage >= 10) return POICategory.excellent;
    if (poiPercentage >= 5) return POICategory.good;
    if (poiPercentage >= 0) return POICategory.slow;
    if (poiPercentage >= -5) return POICategory.stagnant;
    return POICategory.plateau;
  }

  /// Calculates weighted POI across all muscle groups
  static double calculateWeightedPOI({
    required Map<MuscleGroup, double> poiByMuscle,
    required Map<MuscleGroup, double> volumeByMuscle,
  }) {
    final totalVolume = volumeByMuscle.values.reduce((a, b) => a + b);
    if (totalVolume == 0) return 0.0;

    double weightedSum = 0.0;
    for (final muscle in MuscleGroup.values) {
      final weight = (volumeByMuscle[muscle] ?? 0.0) / totalVolume;
      final poi = poiByMuscle[muscle] ?? 0.0;
      weightedSum += poi * weight;
    }
    return weightedSum;
  }
}
```

**Unit Tests** (must cover):
- Positive progress: 3560kg → 4200kg = +18%
- Negative progress: 4200kg → 3800kg = -9.5%
- Zero previous: 0kg → 4200kg = 0% (avoid NaN)
- Zero change: 4200kg → 4200kg = 0%
- Edge case: Very small values (0.01kg → 0.02kg = +100%)

---

#### Task 2.2: Implement Balance Calculation Logic

- **Layer**: Data/Services
- **Files**: `lib/features/analytics/data/services/balance_calculator.dart` (NEW)
- **Dependencies**: Task 1.2
- **Est. Time**: 35 min
- **Blocking**: Yes (blocks Task 2.4, 3.2)
- **Verification**: Unit test with muscle group volume variations + status classification

**Description**:
Create balance calculator for Push/Pull, Upper/Lower, Core ratios.

**Code Prompt**:
```dart
class BalanceCalculator {
  /// Calculate Push/Pull ratio
  /// Push: Petto + Spalle + Triceps (60% Braccia)
  /// Pull: Schiena + Biceps (40% Braccia)
  static double calculatePushPullRatio(Map<MuscleGroup, double> volumeByMuscle) {
    final petto = volumeByMuscle[MuscleGroup.petto] ?? 0.0;
    final spalle = volumeByMuscle[MuscleGroup.spalle] ?? 0.0;
    final braccia = volumeByMuscle[MuscleGroup.braccia] ?? 0.0;
    final schiena = volumeByMuscle[MuscleGroup.schiena] ?? 0.0;

    final pushVolume = petto + spalle + (braccia * 0.6);
    final pullVolume = schiena + (braccia * 0.4);

    return pullVolume == 0 ? 0.0 : pushVolume / pullVolume;
  }

  /// Calculate Upper/Lower ratio
  static double calculateUpperLowerRatio(Map<MuscleGroup, double> volumeByMuscle) {
    final petto = volumeByMuscle[MuscleGroup.petto] ?? 0.0;
    final spalle = volumeByMuscle[MuscleGroup.spalle] ?? 0.0;
    final schiena = volumeByMuscle[MuscleGroup.schiena] ?? 0.0;
    final braccia = volumeByMuscle[MuscleGroup.braccia] ?? 0.0;
    final gambe = volumeByMuscle[MuscleGroup.gambe] ?? 0.0;

    final upperVolume = petto + spalle + schiena + braccia;
    final lowerVolume = gambe;

    return lowerVolume == 0 ? 0.0 : upperVolume / lowerVolume;
  }

  /// Calculate Core engagement percentage
  static double calculateCoreEngagement(Map<MuscleGroup, double> volumeByMuscle) {
    final addome = volumeByMuscle[MuscleGroup.addome] ?? 0.0;
    final totalVolume = volumeByMuscle.values.reduce((a, b) => a + b);

    return totalVolume == 0 ? 0.0 : (addome / totalVolume) * 100;
  }

  /// Classify balance status
  static BalanceStatus classifyBalance(double ratio) {
    if (ratio >= 0.9 && ratio <= 1.1) return BalanceStatus.balanced;
    if ((ratio >= 0.8 && ratio < 0.9) || (ratio > 1.1 && ratio <= 1.2)) {
      return BalanceStatus.warning;
    }
    return BalanceStatus.critical;
  }
}
```

---

#### Task 2.3: Create Firestore Aggregation Service

- **Layer**: Data/Services
- **Files**: `lib/features/analytics/data/services/firestore_aggregation_service.dart` (NEW)
- **Dependencies**: Task 1.3
- **Est. Time**: 40 min
- **Blocking**: Yes (blocks Task 2.4)
- **Verification**: Firestore query logic tested with mock data + timestamp filtering validated

**Description**:
Implement weekly data aggregation queries for performance (reduce Firestore reads).

**Code Prompt**:
```dart
class FirestoreAggregationService {
  final FirebaseFirestore _firestore;

  FirestoreAggregationService(this._firestore);

  /// Fetch pre-aggregated weekly data for period
  Future<List<WeeklyAggregate>> getWeeklyAggregates({
    required String userId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics_weekly')
        .where('weekStart', isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart))
        .where('weekStart', isLessThanOrEqualTo: Timestamp.fromDate(periodEnd))
        .orderBy('weekStart', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => WeeklyAggregate.fromJson(doc.data()))
        .toList();
  }

  /// Aggregate raw workout data into weekly summaries
  /// (Background task - not called in UI)
  Future<void> aggregateWeeklyData({
    required String userId,
    required DateTime weekStart,
  }) async {
    // Calculate totals for the week
    final weekEnd = weekStart.add(const Duration(days: 7));

    // Query all workouts in week
    // Calculate volume by muscle group
    // Store in analytics_weekly collection

    // Implementation details...
  }
}

@freezed
class WeeklyAggregate with _$WeeklyAggregate {
  const factory WeeklyAggregate({
    required DateTime weekStart,
    required Map<MuscleGroup, double> volumeByMuscle,
    required Map<MuscleGroup, int> setsByMuscle,
    required Map<MuscleGroup, int> repsByMuscle,
    required int totalWorkouts,
  }) = _WeeklyAggregate;

  factory WeeklyAggregate.fromJson(Map<String, dynamic> json) =>
      _$WeeklyAggregateFromJson(json);
}
```

**Performance Benefit**:
- Without aggregation: 30 workouts × 10 exercises = 300 Firestore reads
- With aggregation: 4 weeks × 1 aggregate = 4 Firestore reads (75x reduction!)

---

#### Task 2.4: Complete Analytics Repository Implementation

- **Layer**: Data/Repositories
- **Files**: `lib/features/analytics/data/repositories/analytics_repository_impl.dart` (existing - add methods)
- **Dependencies**: Tasks 2.1, 2.2, 2.3
- **Est. Time**: 45 min
- **Blocking**: Yes (blocks Task 3.4 - Riverpod providers)
- **Verification**: Integration test with mock Firestore + cache behavior validated

**Description**:
Implement concrete repository with Firestore + Hive caching.

**Code Prompt**:
```dart
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirebaseFirestore _firestore;
  final Box<String> _cacheBox;
  final FirestoreAggregationService _aggregationService;
  final POICalculator _poiCalculator;
  final BalanceCalculator _balanceCalculator;

  @override
  Future<Map<MuscleGroup, POIData>> calculatePOI({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    // 1. Check Hive cache first (1-hour TTL)
    final cacheKey = 'poi_${periodStart.millisecondsSinceEpoch}_${periodEnd.millisecondsSinceEpoch}';
    final cached = _cacheBox.get(cacheKey);
    if (cached != null) {
      final cacheData = jsonDecode(cached);
      final cacheTime = DateTime.parse(cacheData['timestamp']);
      if (DateTime.now().difference(cacheTime).inHours < 1) {
        return _parsePOIFromCache(cacheData);
      }
    }

    // 2. Fetch current period data
    final currentData = await _aggregationService.getWeeklyAggregates(
      userId: _userId,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );

    // 3. Calculate previous period (same length)
    final periodLength = periodEnd.difference(periodStart);
    final previousEnd = periodStart.subtract(const Duration(days: 1));
    final previousStart = previousEnd.subtract(periodLength);

    final previousData = await _aggregationService.getWeeklyAggregates(
      userId: _userId,
      periodStart: previousStart,
      periodEnd: previousEnd,
    );

    // 4. Calculate POI for each muscle group
    final poiByMuscle = <MuscleGroup, POIData>{};
    for (final muscle in MuscleGroup.values) {
      final currentVolume = _sumVolume(currentData, muscle);
      final previousVolume = _sumVolume(previousData, muscle);

      final poiPercentage = _poiCalculator.calculatePOI(
        currentValue: currentVolume,
        previousValue: previousVolume,
      );

      poiByMuscle[muscle] = POIData(
        currentValue: currentVolume,
        previousValue: previousVolume,
        poiPercentage: poiPercentage,
        timestamp: DateTime.now(),
        muscleGroup: muscle,
        category: _poiCalculator.classifyPOI(poiPercentage),
      );
    }

    // 5. Cache result for 1 hour
    await _cacheBox.put(cacheKey, jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'data': poiByMuscle.map((k, v) => MapEntry(k.name, v.toJson())),
    }));

    return poiByMuscle;
  }

  // Similar implementations for getBalanceIndicators, getMuscleGroupMetrics...
}
```

---

### 3. Presentation Layer (7 tasks)

---

#### Task 3.1: Create Period Selector Widget

- **Layer**: Presentation/Widgets
- **Files**: `lib/features/analytics/presentation/widgets/period_selector_widget.dart` (NEW)
- **Dependencies**: None
- **Est. Time**: 30 min
- **Blocking**: No
- **Verification**: Visual check + period changes trigger callback + uses AppIcons/context.colors

**Description**:
Horizontal scrollable chip selector for period (7d/30d/3m/6m/1y/All).

**Code Prompt**:
```dart
class PeriodSelectorWidget extends ConsumerWidget {
  const PeriodSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AnalyticsPeriod.values.map((period) {
          final isSelected = selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period.label(context)),
              selected: isSelected,
              onSelected: (_) {
                HapticFeedback.lightImpact();
                ref.read(selectedPeriodProvider.notifier).state = period;
              },
              selectedColor: context.colors.primary,
              backgroundColor: context.colors.surfaceContainerHighest,
              labelStyle: TextStyle(
                color: isSelected
                    ? context.colors.onPrimary
                    : context.colors.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

enum AnalyticsPeriod {
  week7,    // 7 days
  days30,   // 30 days
  months3,  // 3 months
  months6,  // 6 months
  year1,    // 1 year
  all,      // All time
}

extension AnalyticsPeriodX on AnalyticsPeriod {
  String label(BuildContext context) {
    switch (this) {
      case AnalyticsPeriod.week7: return context.l10n.sevenDays;
      case AnalyticsPeriod.days30: return context.l10n.thirtyDays;
      case AnalyticsPeriod.months3: return context.l10n.threeMonths;
      case AnalyticsPeriod.months6: return context.l10n.sixMonths;
      case AnalyticsPeriod.year1: return context.l10n.oneYear;
      case AnalyticsPeriod.all: return context.l10n.allTime;
    }
  }
}
```

**FitLog Pro Requirements**:
- ✅ Use `context.l10n.*` for labels (no hardcoded "7d", "30d")
- ✅ Use `context.colors.*` for chip colors
- ✅ Add `HapticFeedback.lightImpact()` on selection
- ✅ Touch targets ≥ 48x48 dp

---

#### Task 3.2: Create Balance Indicators Widget

- **Layer**: Presentation/Widgets
- **Files**: `lib/features/analytics/presentation/widgets/balance_indicators_widget.dart` (NEW)
- **Dependencies**: Task 2.2, 2.4
- **Est. Time**: 40 min
- **Blocking**: No
- **Verification**: Visual check + all AppIcons.* used + responsive on mobile/tablet

**Description**:
3 horizontal progress indicators with icons for Push/Pull, Upper/Lower, Core.

**Code Prompt**:
```dart
class BalanceIndicatorsWidget extends ConsumerWidget {
  const BalanceIndicatorsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodStart = ref.watch(selectedPeriodProvider).startDate;
    final periodEnd = DateTime.now();

    final balanceAsync = ref.watch(balanceIndicatorsProvider(
      periodStart: periodStart,
      periodEnd: periodEnd,
    ));

    return balanceAsync.when(
      data: (balance) => Column(
        children: [
          _buildIndicator(
            context,
            icon: AppIcons.balanceOutlined,
            label: context.l10n.pushPullBalance,
            ratio: balance.pushPullRatio,
            status: balance.pushPullStatus,
          ),
          const SizedBox(height: 12),
          _buildIndicator(
            context,
            icon: AppIcons.fitnessCenter,
            label: context.l10n.upperLowerBalance,
            ratio: balance.upperLowerRatio,
            status: balance.upperLowerStatus,
          ),
          const SizedBox(height: 12),
          _buildIndicator(
            context,
            icon: AppIcons.coreStrength,
            label: context.l10n.coreEngagement,
            ratio: balance.coreEngagement / 100, // Convert % to ratio
            status: BalanceStatus.balanced, // Core doesn't need status
          ),
        ],
      ),
      loading: () => const LoadingIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _buildIndicator(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double ratio,
    required BalanceStatus status,
  }) {
    final color = _getStatusColor(context, status);
    final statusText = _getStatusText(context, status, ratio);

    return Row(
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: label,
          size: AppIconSize.medium,
          color: color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: ratio.clamp(0.0, 2.0) / 2.0, // Normalize to 0-1
                backgroundColor: context.colors.surfaceContainerHighest,
                color: color,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          statusText,
          style: context.textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context, BalanceStatus status) {
    switch (status) {
      case BalanceStatus.balanced: return context.colors.success;
      case BalanceStatus.warning: return context.colors.warning;
      case BalanceStatus.critical: return context.colors.error;
    }
  }

  String _getStatusText(BuildContext context, BalanceStatus status, double ratio) {
    final ratioText = ratio.toStringAsFixed(2);
    switch (status) {
      case BalanceStatus.balanced:
        return '$ratioText ✅ ${context.l10n.balanced}';
      case BalanceStatus.warning:
        return '$ratioText ⚠️ ${context.l10n.warning}';
      case BalanceStatus.critical:
        return '$ratioText ❌ ${context.l10n.critical}';
    }
  }
}
```

**FitLog Pro Requirements**:
- ✅ Use `SemanticIcon` for accessibility
- ✅ Use `AppIcons.*` constants (balanceOutlined, fitnessCenter, coreStrength)
- ✅ Use `context.colors.success/warning/error` for status colors
- ✅ Use `context.l10n.*` for all text
- ✅ Use `LoadingIndicator` for async loading

---

#### Task 3.3: Create POI Score Summary Widget

- **Layer**: Presentation/Widgets
- **Files**: `lib/features/analytics/presentation/widgets/poi_score_summary_widget.dart` (NEW)
- **Dependencies**: Task 2.1, 2.4
- **Est. Time**: 45 min
- **Blocking**: No
- **Verification**: Color-coded bars + POI categories displayed + responsive layout

**Description**:
Card displaying overall POI + 6 muscle group bars with color-coding.

**Code Prompt**:
```dart
class POIScoreSummaryWidget extends ConsumerWidget {
  const POIScoreSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodStart = ref.watch(selectedPeriodProvider).startDate;
    final periodEnd = DateTime.now();

    final poiAsync = ref.watch(poiDataProvider(
      periodStart: periodStart,
      periodEnd: periodEnd,
    ));

    return poiAsync.when(
      data: (poiByMuscle) {
        // Calculate weighted overall POI
        final volumeByMuscle = <MuscleGroup, double>{};
        for (final muscle in MuscleGroup.values) {
          volumeByMuscle[muscle] = poiByMuscle[muscle]!.currentValue;
        }

        final overallPOI = POICalculator.calculateWeightedPOI(
          poiByMuscle: poiByMuscle.map((k, v) => MapEntry(k, v.poiPercentage)),
          volumeByMuscle: volumeByMuscle,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall POI
                Text(
                  context.l10n.overallProgressiveOverload,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${overallPOI.toStringAsFixed(1)}%',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: _getPOIColor(context, overallPOI),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SemanticIcon(
                      icon: _getPOIIcon(overallPOI),
                      semanticLabel: _getPOICategoryText(context, overallPOI),
                      size: AppIconSize.large,
                      color: _getPOIColor(context, overallPOI),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Muscle group breakdown
                ...MuscleGroup.values.map((muscle) {
                  final poi = poiByMuscle[muscle]!;
                  return _buildMuscleBar(context, muscle, poi);
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _buildMuscleBar(BuildContext context, MuscleGroup muscle, POIData poi) {
    final color = _getPOIColor(context, poi.poiPercentage);
    final progress = (poi.poiPercentage / 20).clamp(0.0, 1.0); // Normalize to 0-1 (max 20%)

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              muscle.displayName(context),
              style: context.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.colors.surfaceContainerHighest,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              '${poi.poiPercentage > 0 ? '+' : ''}${poi.poiPercentage.toStringAsFixed(1)}%',
              style: context.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPOIColor(BuildContext context, double poi) {
    if (poi >= 10) return const Color(0xFF4CAF50); // Green - Excellent
    if (poi >= 5) return const Color(0xFF8BC34A);   // Light Green - Good
    if (poi >= 0) return const Color(0xFFFFC107);   // Yellow - Slow
    if (poi >= -5) return const Color(0xFFFF9800);  // Orange - Stagnant
    return const Color(0xFFF44336);                 // Red - Plateau
  }

  IconData _getPOIIcon(double poi) {
    if (poi >= 10) return AppIcons.trendingUp;
    if (poi >= 5) return AppIcons.arrowUpward;
    if (poi >= 0) return AppIicons.remove;
    if (poi >= -5) return AppIcons.arrowDownward;
    return AppIcons.trendingDown;
  }

  String _getPOICategoryText(BuildContext context, double poi) {
    if (poi >= 10) return context.l10n.excellent;
    if (poi >= 5) return context.l10n.good;
    if (poi >= 0) return context.l10n.slow;
    if (poi >= -5) return context.l10n.stagnant;
    return context.l10n.plateau;
  }
}
```

**FitLog Pro Requirements**:
- ✅ Use hardcoded POI colors (as specified in ANALYTICS_ENHANCEMENT_MOCKUPS_UI.md)
- ✅ Use `AppIcons.*` for trend icons
- ✅ Use `context.l10n.*` for all text
- ✅ Use `SemanticIcon` for accessibility
- ✅ Use `LoadingIndicator` for async loading

---

#### Task 3.4: Create Riverpod Providers

- **Layer**: Presentation/Providers
- **Files**: `lib/features/analytics/presentation/providers/analytics_enhancement_providers.dart` (NEW)
- **Dependencies**: Task 2.4
- **Est. Time**: 35 min
- **Blocking**: Yes (blocks Task 3.5 - Tab integration)
- **Verification**: Providers handle loading/error states + cache invalidation works

**Description**:
Create Riverpod providers for POI, Balance, Period, Metric selection.

**Code Prompt**:
```dart
// Period selection state
final selectedPeriodProvider = StateProvider<AnalyticsPeriod>((ref) {
  return AnalyticsPeriod.days30; // Default 30 days
});

// Metric selection state
final selectedMetricProvider = StateProvider<MetricType>((ref) {
  return MetricType.volume; // Default Volume (kg)
});

// POI data provider (cached, auto-refresh on period change)
@riverpod
Future<Map<MuscleGroup, POIData>> poiData(
  PoiDataRef ref, {
  required DateTime periodStart,
  required DateTime periodEnd,
}) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.calculatePOI(
    periodStart: periodStart,
    periodEnd: periodEnd,
  );
}

// Balance indicators provider
@riverpod
Future<BalanceIndicators> balanceIndicators(
  BalanceIndicatorsRef ref, {
  required DateTime periodStart,
  required DateTime periodEnd,
}) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getBalanceIndicators(
    periodStart: periodStart,
    periodEnd: periodEnd,
  );
}

// Muscle group metrics provider (supports metric toggle)
@riverpod
Future<Map<MuscleGroup, double>> muscleGroupMetrics(
  MuscleGroupMetricsRef ref, {
  required DateTime periodStart,
  required DateTime periodEnd,
  required MetricType metric,
}) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getMuscleGroupMetrics(
    periodStart: periodStart,
    periodEnd: periodEnd,
    metric: metric,
  );
}

enum MetricType {
  volume,      // Total weight (kg)
  sets,        // Total sets
  reps,        // Total reps
  percentage,  // % of total volume
}
```

**Auto-refresh Logic**:
```dart
// In consumer widgets, watch period and auto-refresh:
final periodStart = ref.watch(selectedPeriodProvider).startDate;
final periodEnd = DateTime.now();

final poiAsync = ref.watch(poiDataProvider(
  periodStart: periodStart,
  periodEnd: periodEnd,
));
// When selectedPeriodProvider changes, poiDataProvider auto-rebuilds!
```

---

#### Task 3.5: Implement Analytics Progress Tab

- **Layer**: Presentation/Screens
- **Files**: `lib/features/analytics/presentation/tabs/analytics_progress_tab.dart` (existing - major rewrite)
- **Dependencies**: Tasks 3.1, 3.2, 3.3, 3.4
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**: No horizontal overflow + smooth scrolling on iOS/Android + all sections visible

**Description**:
Compose scrollable tab with 3 sections: Muscle Groups Enhanced, POI, AI Insights.

**Code Prompt**:
```dart
class AnalyticsProgressTab extends ConsumerWidget {
  final List<Workout> workouts;
  final bool isPremium;

  const AnalyticsProgressTab({
    super.key,
    required this.workouts,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Global Controls
          _buildGlobalControls(context, ref),
          const SizedBox(height: 24),

          // Section 1: Muscle Groups Enhanced
          _buildSectionHeader(context, context.l10n.muscleGroups),
          const SizedBox(height: 12),
          EnhancedMuscleGroupsSection(
            workouts: workouts,
          ),
          const SizedBox(height: 32),

          // Section 2: Progressive Overload
          _buildSectionHeader(context, context.l10n.progressiveOverload),
          const SizedBox(height: 12),
          const POIScoreSummaryWidget(),
          const SizedBox(height: 16),
          // TODO: Add multi-line progression chart (Task 3.6)
          const SizedBox(height: 32),

          // Section 3: Balance Indicators
          _buildSectionHeader(context, context.l10n.balanceIndicators),
          const SizedBox(height: 12),
          const BalanceIndicatorsWidget(),
          const SizedBox(height: 32),

          // Section 4: AI Insights (Premium only)
          if (isPremium) ...[
            _buildSectionHeader(context, context.l10n.aiInsights),
            const SizedBox(height: 12),
            const AIInsightsPlaceholder(), // Task 3.7
          ],
        ],
      ),
    );
  }

  Widget _buildGlobalControls(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.period,
          style: context.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        const PeriodSelectorWidget(),
        const SizedBox(height: 16),
        Text(
          context.l10n.metric,
          style: context.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildMetricToggle(context, ref),
      ],
    );
  }

  Widget _buildMetricToggle(BuildContext context, WidgetRef ref) {
    final selectedMetric = ref.watch(selectedMetricProvider);

    return SegmentedButton<MetricType>(
      segments: [
        ButtonSegment(
          value: MetricType.volume,
          label: Text(context.l10n.volume),
          icon: const SemanticIcon(
            icon: AppIcons.weight,
            semanticLabel: 'Volume',
            size: AppIconSize.small,
          ),
        ),
        ButtonSegment(
          value: MetricType.sets,
          label: Text(context.l10n.sets),
          icon: const SemanticIcon(
            icon: AppIcons.format123,
            semanticLabel: 'Sets',
            size: AppIconSize.small,
          ),
        ),
        ButtonSegment(
          value: MetricType.reps,
          label: Text(context.l10n.reps),
          icon: const SemanticIcon(
            icon: AppIcons.repeat,
            semanticLabel: 'Reps',
            size: AppIconSize.small,
          ),
        ),
      ],
      selected: {selectedMetric},
      onSelectionChanged: (newSelection) {
        HapticFeedback.lightImpact();
        ref.read(selectedMetricProvider.notifier).state = newSelection.first;
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
```

**FitLog Pro Requirements**:
- ✅ Use `context.l10n.*` for all text
- ✅ Use `SemanticIcon` for icons
- ✅ Use `HapticFeedback.lightImpact()` on interactions
- ✅ Use `const` where possible
- ✅ Responsive padding (16dp standard)

---

#### Task 3.6: Create Enhanced Muscle Groups Section

- **Layer**: Presentation/Widgets
- **Files**: `lib/features/analytics/presentation/widgets/enhanced_muscle_groups_section.dart` (NEW)
- **Dependencies**: Task 3.4
- **Est. Time**: 55 min
- **Blocking**: No
- **Verification**: Bar chart + Line chart rendered + metric toggle works + period changes update charts

**Description**:
Bar chart comparativo + expandable line chart for single muscle trend.

**Code Prompt**:
```dart
class EnhancedMuscleGroupsSection extends ConsumerStatefulWidget {
  final List<Workout> workouts;

  const EnhancedMuscleGroupsSection({
    super.key,
    required this.workouts,
  });

  @override
  ConsumerState<EnhancedMuscleGroupsSection> createState() =>
      _EnhancedMuscleGroupsSectionState();
}

class _EnhancedMuscleGroupsSectionState
    extends ConsumerState<EnhancedMuscleGroupsSection> {
  MuscleGroup? _expandedMuscle;

  @override
  Widget build(BuildContext context) {
    final periodStart = ref.watch(selectedPeriodProvider).startDate;
    final periodEnd = DateTime.now();
    final metric = ref.watch(selectedMetricProvider);

    final metricsAsync = ref.watch(muscleGroupMetricsProvider(
      periodStart: periodStart,
      periodEnd: periodEnd,
      metric: metric,
    ));

    return metricsAsync.when(
      data: (metricsByMuscle) => Column(
        children: [
          // Bar Chart Comparativo
          _buildBarChart(context, metricsByMuscle, metric),
          const SizedBox(height: 16),

          // Expandable Line Chart
          if (_expandedMuscle != null) ...[
            _buildLineChart(context, _expandedMuscle!, metric),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _expandedMuscle = null),
              child: Text(context.l10n.collapse),
            ),
          ],
        ],
      ),
      loading: () => const LoadingIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    Map<MuscleGroup, double> metrics,
    MetricType metric,
  ) {
    // Sort by value descending
    final sorted = metrics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: sorted.asMap().entries.map((entry) {
            final index = entry.key;
            final muscle = entry.value.key;
            final value = entry.value.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: _getMuscleColor(muscle),
                  width: 20,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final muscle = sorted[value.toInt()].key;
                  return Text(
                    muscle.shortName(context),
                    style: context.textTheme.bodySmall,
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: context.textTheme.bodySmall,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchCallback: (event, response) {
              if (event is FlTapUpEvent && response?.spot != null) {
                final index = response!.spot!.touchedBarGroupIndex;
                setState(() {
                  _expandedMuscle = sorted[index].key;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(
    BuildContext context,
    MuscleGroup muscle,
    MetricType metric,
  ) {
    // TODO: Fetch daily/weekly trend data for muscle
    // For now, placeholder
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${muscle.displayName(context)} - ${_getMetricLabel(context, metric)}',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: 200,
              child: Center(child: Text('Line chart placeholder')),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMuscleColor(MuscleGroup muscle) {
    // From ANALYTICS_ENHANCEMENT_MOCKUPS_UI.md
    switch (muscle) {
      case MuscleGroup.petto: return const Color(0xFFE53935);
      case MuscleGroup.schiena: return const Color(0xFF1E88E5);
      case MuscleGroup.gambe: return const Color(0xFF43A047);
      case MuscleGroup.spalle: return const Color(0xFFFB8C00);
      case MuscleGroup.braccia: return const Color(0xFF8E24AA);
      case MuscleGroup.addome: return const Color(0xFFFFB300);
    }
  }

  String _getMetricLabel(BuildContext context, MetricType metric) {
    switch (metric) {
      case MetricType.volume: return context.l10n.volumeKg;
      case MetricType.sets: return context.l10n.sets;
      case MetricType.reps: return context.l10n.reps;
      case MetricType.percentage: return context.l10n.percentage;
    }
  }
}
```

**Note**: Requires `fl_chart` package dependency.

---

#### Task 3.7: Add AI Insights Placeholder (Premium)

- **Layer**: Presentation/Widgets
- **Files**: `lib/features/analytics/presentation/widgets/ai_insights_placeholder.dart` (NEW)
- **Dependencies**: None
- **Est. Time**: 20 min
- **Blocking**: No
- **Verification**: Shows placeholder text for premium users + upgrade prompt for free users

**Description**:
Simple card with placeholder insights (real AI implementation later).

**Code Prompt**:
```dart
class AIInsightsPlaceholder extends ConsumerWidget {
  const AIInsightsPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumUserProvider);

    if (!isPremium) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SemanticIcon(
                icon: AppIcons.autoAwesomeOutlined,
                semanticLabel: context.l10n.aiInsights,
                size: AppIconSize.xlarge,
                color: context.colors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.unlockAiInsights,
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.upgradeForPersonalizedRecommendations,
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push('/premium'),
                child: Text(context.l10n.upgradeToPremium),
              ),
            ],
          ),
        ),
      );
    }

    // Premium: Show placeholder insights
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SemanticIcon(
                  icon: AppIcons.autoAwesome,
                  semanticLabel: 'AI Insights',
                  size: AppIconSize.medium,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.aiInsights,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              context,
              icon: AppIcons.trendingUp,
              text: context.l10n.aiInsightExcellentChestProgress,
            ),
            const SizedBox(height: 8),
            _buildInsightItem(
              context,
              icon: AppIcons.warning,
              text: context.l10n.aiInsightConsiderIncreasingLegVolume,
            ),
            const SizedBox(height: 8),
            _buildInsightItem(
              context,
              icon: AppIcons.balanceOutlined,
              text: context.l10n.aiInsightPushPullBalanceGood,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: text,
          size: AppIconSize.small,
          color: context.colors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
```

**FitLog Pro Requirements**:
- ✅ Use `context.l10n.*` for all text
- ✅ Use `SemanticIcon` for accessibility
- ✅ Use `AppIcons.*` constants
- ✅ Premium check with `isPremiumUserProvider`

---

### 4. Localization (1 task)

---

#### Task 4.1: Add EN/IT Localization Strings

- **Layer**: Localization
- **Files**:
  - `assets/i18n/app_en.arb`
  - `assets/i18n/app_it.arb`
- **Dependencies**: Tasks 3.1-3.7
- **Est. Time**: 30 min
- **Blocking**: Yes (blocks Task 5.1 - flutter analyze will fail without strings)
- **Verification**: `flutter gen-l10n` passes + all `context.l10n.*` calls resolve

**Description**:
Add 25+ new localization strings for analytics enhancement.

**English Strings** (`app_en.arb`):
```json
{
  "progressiveOverload": "Progressive Overload",
  "overallProgressiveOverload": "Overall Progressive Overload",
  "excellent": "Excellent",
  "good": "Good",
  "slow": "Slow Progress",
  "stagnant": "Stagnant",
  "plateau": "Plateau",
  "balanceIndicators": "Balance Indicators",
  "pushPullBalance": "Push/Pull Balance",
  "upperLowerBalance": "Upper/Lower Balance",
  "coreEngagement": "Core Engagement",
  "balanced": "Balanced",
  "warning": "Warning",
  "critical": "Critical",
  "sevenDays": "7 Days",
  "thirtyDays": "30 Days",
  "threeMonths": "3 Months",
  "sixMonths": "6 Months",
  "oneYear": "1 Year",
  "allTime": "All Time",
  "period": "Period",
  "metric": "Metric",
  "volume": "Volume",
  "volumeKg": "Volume (kg)",
  "sets": "Sets",
  "reps": "Reps",
  "percentage": "Percentage",
  "collapse": "Collapse",
  "aiInsights": "AI Insights",
  "unlockAiInsights": "Unlock AI Insights",
  "upgradeForPersonalizedRecommendations": "Upgrade to Premium for personalized training recommendations",
  "upgradeToPremium": "Upgrade to Premium",
  "aiInsightExcellentChestProgress": "💪 Excellent chest progress! Keep up the current training intensity.",
  "aiInsightConsiderIncreasingLegVolume": "🦵 Consider increasing leg volume by 10-15% for balanced development.",
  "aiInsightPushPullBalanceGood": "✅ Push/Pull balance is optimal for injury prevention."
}
```

**Italian Strings** (`app_it.arb`):
```json
{
  "progressiveOverload": "Sovraccarico Progressivo",
  "overallProgressiveOverload": "Sovraccarico Progressivo Generale",
  "excellent": "Eccellente",
  "good": "Buono",
  "slow": "Progresso Lento",
  "stagnant": "Stagnante",
  "plateau": "Plateau",
  "balanceIndicators": "Indicatori di Equilibrio",
  "pushPullBalance": "Equilibrio Spinta/Trazione",
  "upperLowerBalance": "Equilibrio Parte Superiore/Inferiore",
  "coreEngagement": "Coinvolgimento Core",
  "balanced": "Bilanciato",
  "warning": "Attenzione",
  "critical": "Critico",
  "sevenDays": "7 Giorni",
  "thirtyDays": "30 Giorni",
  "threeMonths": "3 Mesi",
  "sixMonths": "6 Mesi",
  "oneYear": "1 Anno",
  "allTime": "Tutto il Tempo",
  "period": "Periodo",
  "metric": "Metrica",
  "volume": "Volume",
  "volumeKg": "Volume (kg)",
  "sets": "Serie",
  "reps": "Ripetizioni",
  "percentage": "Percentuale",
  "collapse": "Riduci",
  "aiInsights": "Insights IA",
  "unlockAiInsights": "Sblocca Insights IA",
  "upgradeForPersonalizedRecommendations": "Aggiorna a Premium per raccomandazioni personalizzate",
  "upgradeToPremium": "Aggiorna a Premium",
  "aiInsightExcellentChestProgress": "💪 Ottimo progresso petto! Mantieni l'intensità attuale.",
  "aiInsightConsiderIncreasingLegVolume": "🦵 Considera di aumentare il volume gambe del 10-15% per uno sviluppo bilanciato.",
  "aiInsightPushPullBalanceGood": "✅ Equilibrio spinta/trazione ottimale per prevenzione infortuni."
}
```

**Verification**:
```bash
flutter gen-l10n
# Should complete without errors
# Check generated files in lib/l10n/
```

---

### 5. Testing (2 tasks)

---

#### Task 5.1: Unit Tests for Domain/Data Layers

- **Layer**: Testing
- **Files**:
  - `test/features/analytics/domain/entities/poi_data_test.dart`
  - `test/features/analytics/data/services/poi_calculator_test.dart`
  - `test/features/analytics/data/services/balance_calculator_test.dart`
  - `test/features/analytics/data/repositories/analytics_repository_impl_test.dart`
- **Dependencies**: Tasks 1.1-2.4
- **Est. Time**: 45 min
- **Blocking**: No
- **Verification**: `flutter test` all pass + 85%+ coverage for calculation logic

**Description**:
Test POI calculation, balance ratios, Firestore queries, cache TTL.

**Example Test** (POI Calculator):
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('POICalculator', () {
    test('calculates POI correctly for positive progress', () {
      final poi = POICalculator.calculatePOI(
        currentValue: 4200,
        previousValue: 3560,
      );
      expect(poi, closeTo(18.0, 0.1)); // +18%
    });

    test('calculates POI correctly for negative progress', () {
      final poi = POICalculator.calculatePOI(
        currentValue: 3800,
        previousValue: 4200,
      );
      expect(poi, closeTo(-9.5, 0.1)); // -9.5%
    });

    test('returns 0 when previous value is 0', () {
      final poi = POICalculator.calculatePOI(
        currentValue: 4200,
        previousValue: 0,
      );
      expect(poi, 0.0); // Avoid division by zero
    });

    test('classifies POI as excellent when >10%', () {
      final category = POICalculator.classifyPOI(18.0);
      expect(category, POICategory.excellent);
    });

    test('classifies POI as good when 5-10%', () {
      final category = POICalculator.classifyPOI(7.5);
      expect(category, POICategory.good);
    });

    test('classifies POI as plateau when <-5%', () {
      final category = POICalculator.classifyPOI(-9.5);
      expect(category, POICategory.plateau);
    });

    test('calculates weighted POI correctly', () {
      final poiByMuscle = {
        MuscleGroup.petto: 18.0,
        MuscleGroup.gambe: 12.0,
        MuscleGroup.schiena: 5.0,
      };
      final volumeByMuscle = {
        MuscleGroup.petto: 4200,
        MuscleGroup.gambe: 3800,
        MuscleGroup.schiena: 2000,
      };

      final weightedPOI = POICalculator.calculateWeightedPOI(
        poiByMuscle: poiByMuscle,
        volumeByMuscle: volumeByMuscle,
      );

      // Weighted: (18*4200 + 12*3800 + 5*2000) / (4200+3800+2000)
      expect(weightedPOI, closeTo(13.2, 0.1));
    });
  });
}
```

**Coverage Target**: 85%+ for:
- POICalculator methods
- BalanceCalculator methods
- AnalyticsRepositoryImpl (with mock Firestore)

---

#### Task 5.2: Widget Tests for Presentation

- **Layer**: Testing
- **Files**:
  - `test/features/analytics/presentation/widgets/period_selector_widget_test.dart`
  - `test/features/analytics/presentation/widgets/balance_indicators_widget_test.dart`
  - `test/features/analytics/presentation/widgets/poi_score_summary_widget_test.dart`
  - `test/features/analytics/presentation/tabs/analytics_progress_tab_test.dart`
- **Dependencies**: Tasks 3.1-3.7
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**: All widget tests pass + no accessibility violations + localization works

**Description**:
Test chart rendering, period/metric toggles, error states, localization.

**Example Test** (Period Selector):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PeriodSelectorWidget shows all periods', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PeriodSelectorWidget(),
          ),
        ),
      ),
    );

    // Verify all period chips are visible
    expect(find.text('7 Days'), findsOneWidget);
    expect(find.text('30 Days'), findsOneWidget);
    expect(find.text('3 Months'), findsOneWidget);
    expect(find.text('6 Months'), findsOneWidget);
    expect(find.text('1 Year'), findsOneWidget);
    expect(find.text('All Time'), findsOneWidget);
  });

  testWidgets('PeriodSelectorWidget changes selection on tap', (tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: PeriodSelectorWidget(),
          ),
        ),
      ),
    );

    // Initially 30 Days selected
    expect(
      container.read(selectedPeriodProvider),
      AnalyticsPeriod.days30,
    );

    // Tap 7 Days
    await tester.tap(find.text('7 Days'));
    await tester.pump();

    // Verify selection changed
    expect(
      container.read(selectedPeriodProvider),
      AnalyticsPeriod.week7,
    );
  });

  testWidgets('PeriodSelectorWidget respects localization', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: PeriodSelectorWidget(),
          ),
        ),
      ),
    );

    // Verify Italian translations
    expect(find.text('7 Giorni'), findsOneWidget);
    expect(find.text('30 Giorni'), findsOneWidget);
  });
}
```

---

### 6. Documentation (1 task)

---

#### Task 6.1: Update Documentation

- **Layer**: Documentation
- **Files**:
  - `docs/NAVIGATION/INDEX.md`
  - `CLAUDE.md` (optional - feature mapping table)
- **Dependencies**: All tasks 1.1-5.2
- **Est. Time**: 20 min
- **Blocking**: No
- **Verification**: Markdown syntax valid + all code references match actual files

**Description**:
Update INDEX.md with feature overview, add entity schemas to CLAUDE.md.

**INDEX.md Update**:
```markdown
## Analytics Enhancement (2025-11-22)

**Location**: `lib/features/analytics/presentation/tabs/analytics_progress_tab.dart`

**Features**:
- Progressive Overload Index (POI) calculation and visualization
- Balance indicators (Push/Pull, Upper/Lower, Core engagement)
- Enhanced muscle group tracking with bar/line charts
- Period selector (7d/30d/3m/6m/1y/All)
- Metric toggle (Volume/Sets/Reps/%)
- AI insights for premium users

**Entities**:
- `POIData` (lib/features/analytics/domain/entities/poi_data.dart)
- `BalanceIndicators` (lib/features/analytics/domain/entities/balance_indicators.dart)
- `WeeklyAggregate` (lib/features/analytics/data/services/firestore_aggregation_service.dart)

**Providers**:
- `poiDataProvider` - POI calculation for all muscle groups
- `balanceIndicatorsProvider` - Balance ratios and status
- `muscleGroupMetricsProvider` - Metric data with period/metric filters
- `selectedPeriodProvider` - Current selected period
- `selectedMetricProvider` - Current selected metric

**Related Docs**:
- [Analytics System Overview](../UX_FLOWS/analytics/ANALYTICS_SYSTEM_OVERVIEW.md)
- [Analytics Enhancement Mockups](../UX_FLOWS/analytics/ANALYTICS_ENHANCEMENT_MOCKUPS_UI.md)
- [Analytics Technical Specifications](../UX_FLOWS/analytics/ANALYTICS_TECHNICAL_SPECIFICATIONS.md)

**Implementation Plan**: [2025-11-22-analytics-progress-enhancement-plan.md](../plans/2025-11-22-analytics-progress-enhancement-plan.md)
```

---

## 📊 Implementation Order

**MUST DO FIRST** (blocking tasks):
→ Task 1.1-1.3 (Domain foundation) - ~60 min

**THEN** (parallel workable):
→ Task 2.1-2.4 (Data layer) - ~2.5h
→ Task 3.1 (Period selector) - ~30 min (can start early)

**THEN**:
→ Task 3.2-3.4 (Core widgets + providers) - ~2h

**THEN**:
→ Task 3.5-3.7 (Tab integration + AI placeholder) - ~1.5h

**FINALLY**:
→ Task 4.1 (Localization) - ~30 min
→ Task 5.1-5.2 (Testing) - ~1.5h
→ Task 6.1 (Documentation) - ~20 min

**Total Critical Path**: ~9.5-11 hours

---

## 🚀 Quick Start Checklist

Before starting implementation:

### Design System Compliance:
- [ ] ✅ Use `AppIcons.*` constants (NO `Icons.*` inline)
- [ ] ✅ Use `AppIconSize.*` for sizing (NO magic numbers 24, 28)
- [ ] ✅ Use `context.icon*` for colors (NO `Colors.blue/red/green`)
- [ ] ✅ Prefer `SemanticIcon` for accessibility

### Localization:
- [ ] ✅ NO hardcoded strings (use `context.l10n.*`)
- [ ] ✅ Add EN + IT translations to ARB files
- [ ] ✅ Run `flutter gen-l10n` after adding strings

### Theme:
- [ ] ✅ NO `Colors.blue/red/green` (use `context.colors.primary/error/success`)
- [ ] ✅ NO hardcoded TextStyle (use `context.textTheme.*`)
- [ ] ✅ Test in BOTH dark AND light themes
- [ ] ✅ Exception: `Colors.transparent` is allowed

### Code Quality:
- [ ] ✅ NO `print()` (use `debugPrint() + kDebugMode`)
- [ ] ✅ Run `flutter analyze` (0 errors required)
- [ ] ✅ Use `const` where possible
- [ ] ✅ Use `select()` to avoid unnecessary rebuilds

### iOS Build Compliance:
- [ ] ❌ NEVER `const` with `context.l10n` (CRITICAL)
- [ ] ❌ NO `context.l10n` in providers (use hardcoded strings)
- [ ] ✅ BuildContext parameter for methods using `context.l10n`

### Performance:
- [ ] ✅ Hive caching with 1-hour TTL
- [ ] ✅ Firestore weekly aggregation (reduce reads)
- [ ] ✅ Lazy loading for charts (>50 data points)

---

## 📝 Notes & Decisions

**Firestore Structure**:
```
users/{userId}/analytics_weekly/{weekId}
  - weekStart: Timestamp
  - volumeByMuscle: Map<String, double>
  - setsByMuscle: Map<String, int>
  - repsByMuscle: Map<String, int>
  - totalWorkouts: int
```

**Cache Strategy**:
- Cache key: `poi_{periodStart}_{periodEnd}`
- TTL: 1 hour (3600 seconds)
- Invalidation: Manual via refresh button or period change

**POI Color Palette** (hardcoded as per specs):
```dart
const excellentProgress = Color(0xFF4CAF50);  // Green >+10%
const goodProgress = Color(0xFF8BC34A);       // Light Green +5-10%
const slowProgress = Color(0xFFFFC107);       // Yellow 0-5%
const stagnantProgress = Color(0xFFFF9800);   // Orange -5-0%
const plateauRegression = Color(0xFFF44336);  // Red <-5%
```

**Muscle Group Colors** (hardcoded as per specs):
```dart
Petto: Color(0xFFE53935)     // Red
Schiena: Color(0xFF1E88E5)   // Blue
Gambe: Color(0xFF43A047)     // Green
Spalle: Color(0xFFFB8C00)    // Orange
Braccia: Color(0xFF8E24AA)   // Purple
Addome: Color(0xFFFFB300)    // Amber
```

---

## 🔄 Version History

### v1.0 - 2025-11-22 16:45

**Initial plan generation** via task-master.dev + Claude Code enrichment

**Total Tasks**: 17
**Estimated Time**: ~9.5-11h
**Complexity**: HIGH (multi-layer feature with calculations + charts)

**Generated by**: Claude Code (automatic)
**Plan**: docs/plans/2025-11-22-analytics-progress-enhancement-plan.md

---

## 🎯 Execution Notes

(This section will be updated as tasks are completed)

### Completed Tasks:
- None yet

### In Progress:
- None yet

### Blocked:
- None yet

### Time Tracking:
- Estimated: 9.5-11h
- Actual: TBD

---

## 📚 Related Documentation

- [Analytics System Overview](../UX_FLOWS/analytics/ANALYTICS_SYSTEM_OVERVIEW.md)
- [Analytics Enhancement Mockups](../UX_FLOWS/analytics/ANALYTICS_ENHANCEMENT_MOCKUPS_UI.md)
- [Analytics Technical Specifications](../UX_FLOWS/analytics/ANALYTICS_TECHNICAL_SPECIFICATIONS.md)
- [Design Guidelines](../DESIGN_GUIDELINES.md)
- [Icon Design System](../CLAUDE.md#tier-1-icon-design-system)
- [iOS Build Compliance](../CLAUDE.md#ios-build-compliance)
