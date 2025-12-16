# Exercise Detail Screen Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build Exercise Detail Screen showing volume progression chart, workout history, and personal records when user taps exercise in Analytics.

**Architecture:** Hybrid layout (chart always visible + tabs below). 3-layer caching (Firestore + Riverpod + in-memory) for performance. Data from existing AnalyticsRepository, new ExerciseRecordsProvider for computed metrics.

**Tech Stack:** Flutter 3.16, Riverpod 2.4.9, fl_chart (line charts), GoRouter (navigation), Clean Architecture (domain/data/presentation)

---

## Phase 1: Data Layer - Exercise Records Entity & Provider

### Task 1.1: Create ExerciseRecords Domain Entity

**Files:**
- Create: `lib/features/analytics/domain/entities/exercise_records.dart`

**Step 1: Write entity with freezed**

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// ExerciseRecords - Personal records for a specific exercise
///
/// **Computed from ExerciseHistory sessions**:
/// - Max weight lifted
/// - Max volume in single session
/// - Estimated 1RM (Epley formula)
/// - Best weight for each rep range
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_records.freezed.dart';
part 'exercise_records.g.dart';

@freezed
class ExerciseRecords with _$ExerciseRecords {
  const factory ExerciseRecords({
    required double maxWeight,
    required int maxWeightReps,
    required DateTime maxWeightDate,
    required double maxVolume,
    required DateTime maxVolumeDate,
    required double estimated1RM,
    required Map<int, WeightRecord> bestPerRep, // {3: 80kg, 5: 75kg, ...}
  }) = _ExerciseRecords;

  factory ExerciseRecords.fromJson(Map<String, dynamic> json) =>
      _$ExerciseRecordsFromJson(json);
}

@freezed
class WeightRecord with _$WeightRecord {
  const factory WeightRecord({
    required double weight,
    required DateTime date,
  }) = _WeightRecord;

  factory WeightRecord.fromJson(Map<String, dynamic> json) =>
      _$WeightRecordFromJson(json);
}
```

**Step 2: Generate freezed code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

Expected: Files created:
- `exercise_records.freezed.dart`
- `exercise_records.g.dart`

**Step 3: Verify compilation**

Run: `flutter analyze lib/features/analytics/domain/entities/exercise_records.dart`

Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/features/analytics/domain/entities/exercise_records.dart
git commit -m "feat(analytics): add ExerciseRecords domain entity

- Max weight, volume, estimated 1RM
- Best weight per rep range
- Freezed + json_serializable support"
```

---

### Task 1.2: Create ExerciseRecordsProvider with 3-Layer Caching

**Files:**
- Create: `lib/features/analytics/presentation/providers/exercise_records_provider.dart`

**Step 1: Write provider with caching logic**

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: Riverpod provider
///
/// ExerciseRecordsProvider - Computes personal records with 3-layer caching
///
/// **Caching Strategy**:
/// - Layer 1: Firestore (AnalyticsRepository - 5 min TTL)
/// - Layer 2: Riverpod (provider lifecycle with keepAlive)
/// - Layer 3: In-memory (10 min TTL for computed records)
///
/// **Performance**: 100 workouts × 4 sets = 400 iterations → ~2ms
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_records.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/current_user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercise_records_provider.g.dart';

@riverpod
class ExerciseRecords extends _$ExerciseRecords {
  // Layer 3: In-memory cache for computed records
  static final Map<String, (ExerciseRecordsData, DateTime)> _cache = {};
  static const _cacheDuration = Duration(minutes: 10);

  @override
  Future<ExerciseRecordsData> build(String exerciseName) async {
    // Riverpod 3.0 pattern - keep alive while valid
    final keepAlive = ref.keepAlive();

    // Check in-memory cache (Layer 3)
    final cached = _cache[exerciseName];
    if (cached != null) {
      final (data, timestamp) = cached;
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        keepAlive();
        return data; // ⚡ Cache hit - instant return (~2ms)
      }
    }

    try {
      // Fetch ExerciseHistory (Layers 1+2: Firestore + Riverpod cache)
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final history = await ref.watch(
        exerciseHistoryByNameProvider((userId, exerciseName)).future,
      );

      // Compute records (heavy operation, but only once every 10 min)
      final records = _computeRecords(history);

      // Cache result (Layer 3)
      _cache[exerciseName] = (records, DateTime.now());
      keepAlive();
      return records;
    } catch (e) {
      // Graceful degradation: serve stale data if Firestore offline
      final cached = _cache[exerciseName];
      if (cached != null) {
        final (data, _) = cached;
        return data; // Serve stale rather than error
      }
      rethrow;
    }
  }

  /// Compute personal records from exercise history
  ///
  /// **Algorithm**: O(n) where n = total sets across all sessions
  /// **Example**: 100 workouts × 4 sets = 400 iterations → ~2ms
  ExerciseRecordsData _computeRecords(ExerciseHistory history) {
    double maxWeight = 0;
    int maxWeightReps = 0;
    DateTime? maxWeightDate;

    double maxVolume = 0;
    DateTime? maxVolumeDate;

    final Map<int, (double, DateTime)> bestPerRep = {};

    for (final session in history.sessions) {
      double sessionVolume = 0;

      for (final set in session.sets) {
        // Max weight
        if (set.weight > maxWeight) {
          maxWeight = set.weight;
          maxWeightReps = set.reps;
          maxWeightDate = set.date;
        }

        // Volume
        sessionVolume += set.weight * set.reps;

        // Best per rep
        if (!bestPerRep.containsKey(set.reps) ||
            set.weight > bestPerRep[set.reps]!.$1) {
          bestPerRep[set.reps] = (set.weight, set.date);
        }
      }

      // Max volume
      if (sessionVolume > maxVolume) {
        maxVolume = sessionVolume;
        maxVolumeDate = session.date;
      }
    }

    // Calculate estimated 1RM (Epley formula)
    final estimated1RM = maxWeight * (1 + maxWeightReps / 30);

    return ExerciseRecordsData(
      maxWeight: maxWeight,
      maxWeightReps: maxWeightReps,
      maxWeightDate: maxWeightDate ?? DateTime.now(),
      maxVolume: maxVolume,
      maxVolumeDate: maxVolumeDate ?? DateTime.now(),
      estimated1RM: estimated1RM,
      bestPerRep: bestPerRep.map(
        (reps, record) => MapEntry(
          reps,
          WeightRecord(weight: record.$1, date: record.$2),
        ),
      ),
    );
  }

  /// Invalidate cache for specific exercise
  ///
  /// **Called when**: User completes workout with this exercise
  void invalidateCache(String exerciseName) {
    _cache.remove(exerciseName);
    ref.invalidateSelf();
  }
}

// Type alias for return type
typedef ExerciseRecordsData = ExerciseRecords;
```

**Step 2: Generate Riverpod code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

Expected: `exercise_records_provider.g.dart` created

**Step 3: Verify compilation**

Run: `flutter analyze lib/features/analytics/presentation/providers/exercise_records_provider.dart`

Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/features/analytics/presentation/providers/exercise_records_provider.dart
git commit -m "feat(analytics): add ExerciseRecordsProvider with 3-layer caching

- In-memory cache (10 min TTL)
- Riverpod keepAlive pattern
- Graceful degradation if offline
- O(n) computation (~2ms for 100 workouts)"
```

---

## Phase 2: UI Layer - Screen & Widgets

### Task 2.1: Create ExerciseDetailScreen Scaffold

**Files:**
- Create: `lib/features/analytics/presentation/screens/exercise_detail_screen.dart`

**Step 1: Write screen scaffold with AppBar + TabController**

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/screens
/// 🎯 Feature: analytics
/// 🔧 Type: screen
///
/// ExerciseDetailScreen - Show detailed progression for single exercise
///
/// **Layout**: Hybrid (chart always visible + tabs below)
/// - PR Badge Header (glanceable)
/// - Volume Progression Chart (always visible)
/// - Tab Bar: History | Records
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_records_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/current_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String exerciseName;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
  });

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final historyAsync = ref.watch(
      exerciseHistoryByNameProvider((userId ?? '', widget.exerciseName)),
    );
    final recordsAsync = ref.watch(
      exerciseRecordsProvider(widget.exerciseName),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        backgroundColor: context.colors.surfaceContainerHighest,
        leading: IconButton(
          icon: SemanticIcon.button(
            icon: AppIcons.back,
            semanticLabel: context.l10n.back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: historyAsync.when(
        data: (history) => recordsAsync.when(
          data: (records) => _buildContent(history, records),
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) => _buildError(error.toString()),
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => _buildError(error.toString()),
      ),
    );
  }

  Widget _buildContent(dynamic history, dynamic records) {
    return Column(
      children: [
        // TODO: PR Badge Header
        const SizedBox(height: 16),

        // TODO: Volume Progression Chart
        Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              'Chart Placeholder',
              style: context.textTheme.bodyLarge,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.historyTab),
            Tab(text: context.l10n.recordsTab),
          ],
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // TODO: History Tab
              Center(child: Text('History Tab Placeholder')),

              // TODO: Records Tab
              Center(child: Text('Records Tab Placeholder')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: context.l10n.errorLoadingAnalytics,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.errorLoadingAnalytics,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Verify compilation**

Run: `flutter analyze lib/features/analytics/presentation/screens/exercise_detail_screen.dart`

Expected: Errors for missing localization keys (will fix in Phase 4)

**Step 3: Commit**

```bash
git add lib/features/analytics/presentation/screens/exercise_detail_screen.dart
git commit -m "feat(analytics): add ExerciseDetailScreen scaffold

- AppBar with back button
- TabController (History | Records)
- Provider watching (history + records)
- Error handling
- TODO placeholders for widgets"
```

---

### Task 2.2: Create PR Badge Header Widget

**Files:**
- Create: `lib/features/analytics/presentation/widgets/pr_badge_header.dart`

**Step 1: Write PR badge header widget**

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// PRBadgeHeader - Shows personal record badge with last workout info
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_records.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

class PRBadgeHeader extends StatelessWidget {
  final ExerciseRecords records;
  final DateTime lastWorkoutDate;

  const PRBadgeHeader({
    super.key,
    required this.records,
    required this.lastWorkoutDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.achievement,
            semanticLabel: context.l10n.personalRecord,
            size: AppIconSize.large,
            color: context.colors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.personalRecord,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${records.maxWeight.toStringAsFixed(1)} kg × ${records.maxWeightReps} reps',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.l10n.lastWorkout}: ${timeago.format(lastWorkoutDate)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Add timeago dependency**

Modify: `pubspec.yaml` - Add under dependencies:
```yaml
timeago: ^3.7.0
```

Run: `flutter pub get`

**Step 3: Verify compilation**

Run: `flutter analyze lib/features/analytics/presentation/widgets/pr_badge_header.dart`

Expected: Errors for missing localization keys (will fix in Phase 4)

**Step 4: Update ExerciseDetailScreen to use PRBadgeHeader**

Modify: `lib/features/analytics/presentation/screens/exercise_detail_screen.dart`

Replace `// TODO: PR Badge Header` with:
```dart
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_badge_header.dart';

// In _buildContent:
PRBadgeHeader(
  records: records,
  lastWorkoutDate: history.sessions.isNotEmpty
      ? history.sessions.last.date
      : DateTime.now(),
),
```

**Step 5: Commit**

```bash
git add lib/features/analytics/presentation/widgets/pr_badge_header.dart pubspec.yaml lib/features/analytics/presentation/screens/exercise_detail_screen.dart
git commit -m "feat(analytics): add PR badge header widget

- Shows max weight × reps
- Last workout relative time (timeago)
- Theme-aware styling"
```

---

### Task 2.3: Create Volume Progression Chart Widget

**Files:**
- Create: `lib/features/analytics/presentation/widgets/volume_progression_chart.dart`

**Step 1: Write chart widget with fl_chart**

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// VolumeProgressionChart - Line chart showing volume over time
///
/// **Data**: Sum of (weight × reps) for all sets in each session
/// **Package**: fl_chart (already in project)
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:intl/intl.dart';

class VolumeProgressionChart extends StatelessWidget {
  final ExerciseHistory history;

  const VolumeProgressionChart({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    if (history.sessions.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Text(
          context.l10n.noSessionsYet,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    }

    final spots = _generateSpots();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: context.colors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: context.colors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    value.toInt(),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd MMM').format(date),
                      style: context.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()} kg',
                    style: context.textTheme.bodySmall,
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: context.colors.outlineVariant,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => context.colors.surface,
              getTooltipItems: (spots) => spots
                  .map(
                    (spot) => LineTooltipItem(
                      '${spot.y.toInt()} kg\n${DateFormat('dd MMM yyyy').format(
                        DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()),
                      )}',
                      context.textTheme.bodyMedium!.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    return history.sessions.map((session) {
      // Calculate total volume for session
      final volume = session.sets.fold<double>(
        0,
        (sum, set) => sum + (set.weight * set.reps),
      );

      return FlSpot(
        session.date.millisecondsSinceEpoch.toDouble(),
        volume,
      );
    }).toList();
  }
}
```

**Step 2: Verify fl_chart is in pubspec.yaml**

Run: `grep fl_chart pubspec.yaml`

Expected: `fl_chart: ^0.69.0` (or similar version)

**Step 3: Update ExerciseDetailScreen to use chart**

Modify: `lib/features/analytics/presentation/screens/exercise_detail_screen.dart`

Replace chart placeholder with:
```dart
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/volume_progression_chart.dart';

// Replace placeholder:
VolumeProgressionChart(history: history),
```

**Step 4: Verify compilation**

Run: `flutter analyze lib/features/analytics/presentation/widgets/volume_progression_chart.dart`

Expected: Errors for missing localization keys (will fix in Phase 4)

**Step 5: Commit**

```bash
git add lib/features/analytics/presentation/widgets/volume_progression_chart.dart lib/features/analytics/presentation/screens/exercise_detail_screen.dart
git commit -m "feat(analytics): add volume progression chart

- fl_chart line chart implementation
- Volume = sum(weight × reps) per session
- Interactive tooltips with date + volume
- Theme-aware styling
- Empty state handling"
```

---

### Task 2.4: Create History Tab Widget

**Files:**
- Create: `lib/features/analytics/presentation/widgets/history_tab.dart`
- Create: `lib/features/analytics/presentation/widgets/session_history_card.dart`

**Step 1: Write SessionHistoryCard widget**

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// SessionHistoryCard - Shows single workout session for exercise
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class SessionHistoryCard extends StatelessWidget {
  final ExerciseSession session;
  final bool isPR; // Show PR badge if true

  const SessionHistoryCard({
    super.key,
    required this.session,
    this.isPR = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalVolume = session.sets.fold<double>(
      0,
      (sum, set) => sum + (set.weight * set.reps),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to workout detail (needs workoutId)
          // context.push('/workout-detail/$workoutId');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date + relative time
              Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.calendar,
                    semanticLabel: DateFormat('dd MMM yyyy').format(session.date),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM yyyy').format(session.date),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeago.format(session.date),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Summary stats
              Row(
                children: [
                  Text(
                    '${session.sets.length} ${context.l10n.sets}',
                    style: context.textTheme.bodyMedium,
                  ),
                  const Text(' · '),
                  Text(
                    '${totalVolume.toStringAsFixed(0)} kg ${context.l10n.totalVolume}',
                    style: context.textTheme.bodyMedium,
                  ),
                  if (isPR) ...[
                    const SizedBox(width: 8),
                    SemanticIcon(
                      icon: AppIcons.achievement,
                      semanticLabel: context.l10n.personalRecord,
                      color: context.colors.primary,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Sets detail
              ...session.sets.map(
                (set) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${set.weight.toStringAsFixed(1)} kg × ${set.reps} reps',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Action hint
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    context.l10n.tapToSeeWorkout,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SemanticIcon(
                    icon: AppIcons.chevronRight,
                    semanticLabel: context.l10n.viewDetails,
                    color: context.colors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Write HistoryTab widget**

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// HistoryTab - Shows chronological list of workout sessions
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/session_history_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class HistoryTab extends StatelessWidget {
  final ExerciseHistory history;

  const HistoryTab({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    if (history.sessions.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort sessions by date descending (most recent first)
    final sortedSessions = history.sessions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSessions.length,
      itemBuilder: (context, index) {
        final session = sortedSessions[index];
        // TODO: Detect if this session contains PR
        final isPR = false;

        return SessionHistoryCard(
          session: session,
          isPR: isPR,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.workout,
            semanticLabel: context.l10n.noSessionsYet,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noSessionsYet,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to workout start
            },
            child: Text(context.l10n.startWorkoutCTA),
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Update ExerciseDetailScreen to use HistoryTab**

Modify: `lib/features/analytics/presentation/screens/exercise_detail_screen.dart`

Replace history tab placeholder with:
```dart
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/history_tab.dart';

// In TabBarView children:
HistoryTab(history: history),
```

**Step 4: Commit**

```bash
git add lib/features/analytics/presentation/widgets/session_history_card.dart lib/features/analytics/presentation/widgets/history_tab.dart lib/features/analytics/presentation/screens/exercise_detail_screen.dart
git commit -m "feat(analytics): add history tab with session cards

- SessionHistoryCard shows date, sets, volume
- HistoryTab with ListView sorted by date
- PR badge support (TODO: detection)
- Empty state with CTA
- Navigation placeholder for workout detail"
```

---

### Task 2.5: Create Records Tab Widget

**Files:**
- Create: `lib/features/analytics/presentation/widgets/records_tab.dart`

**Step 1: Write RecordsTab widget**

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// RecordsTab - Shows personal records organized by category
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_records.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

class RecordsTab extends StatelessWidget {
  final ExerciseRecords records;

  const RecordsTab({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall Records Section
        Text(
          'OVERALL RECORDS',
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        _buildRecordCard(
          context,
          icon: AppIcons.workout,
          label: context.l10n.maxWeight,
          value: '${records.maxWeight.toStringAsFixed(1)} kg × ${records.maxWeightReps} reps',
          date: DateFormat('dd MMM yyyy').format(records.maxWeightDate),
        ),

        const SizedBox(height: 8),

        _buildRecordCard(
          context,
          icon: AppIcons.achievement,
          label: context.l10n.maxVolume,
          value: '${records.maxVolume.toStringAsFixed(0)} kg',
          date: DateFormat('dd MMM yyyy').format(records.maxVolumeDate),
        ),

        const SizedBox(height: 8),

        _buildRecordCard(
          context,
          icon: AppIcons.trendingUp,
          label: context.l10n.estimated1RM,
          value: '${records.estimated1RM.toStringAsFixed(1)} kg',
          date: 'Calculated',
        ),

        const SizedBox(height: 24),

        // Best Per Rep Section
        Text(
          context.l10n.bestPerRep.toUpperCase(),
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        ...records.bestPerRep.entries.map((entry) {
          final reps = entry.key;
          final record = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildBestPerRepCard(
              context,
              reps: reps,
              weight: record.weight,
              date: DateFormat('dd MMM yyyy').format(record.date),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecordCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String date,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SemanticIcon(
              icon: icon,
              semanticLabel: label,
              color: context.colors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestPerRepCard(
    BuildContext context, {
    required int reps,
    required double weight,
    required String date,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$reps',
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$reps ${context.l10n.reps}',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${weight.toStringAsFixed(1)} kg',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              date,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Update ExerciseDetailScreen to use RecordsTab**

Modify: `lib/features/analytics/presentation/screens/exercise_detail_screen.dart`

Replace records tab placeholder with:
```dart
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/records_tab.dart';

// In TabBarView children:
RecordsTab(records: records),
```

**Step 3: Verify compilation**

Run: `flutter analyze lib/features/analytics/presentation/widgets/records_tab.dart`

Expected: Errors for missing localization keys (will fix next)

**Step 4: Commit**

```bash
git add lib/features/analytics/presentation/widgets/records_tab.dart lib/features/analytics/presentation/screens/exercise_detail_screen.dart
git commit -m "feat(analytics): add records tab with PRs

- Overall records: max weight, volume, 1RM
- Best per rep range cards
- Theme-aware styling
- Date formatting"
```

---

## Phase 3: Routing

### Task 3.1: Add Route to GoRouter

**Files:**
- Modify: `lib/app/app.dart`

**Step 1: Add exercise detail route**

Find the analytics route section (around line 462) and add after it:

```dart
// After /analytics route
GoRoute(
  path: '/analytics/exercise/:exerciseName',
  name: 'exercise-detail',
  builder: (context, state) {
    final exerciseName = state.pathParameters['exerciseName']!;
    return ExerciseDetailScreen(exerciseName: exerciseName);
  },
),
```

Import at top of file:
```dart
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/exercise_detail_screen.dart';
```

**Step 2: Verify compilation**

Run: `flutter analyze lib/app/app.dart`

Expected: `No issues found!` (or existing issues, not new)

**Step 3: Commit**

```bash
git add lib/app/app.dart
git commit -m "feat(analytics): add exercise detail route

Route: /analytics/exercise/:exerciseName
Navigation from Analytics screen enabled"
```

---

### Task 3.2: Update Analytics Screen Navigation

**Files:**
- Modify: `lib/features/analytics/presentation/analytics_screen.dart`

**Step 1: Enable navigation on exercise card tap**

Find the `_ExerciseHistoryCard` widget (around line 238) and uncomment/update the onTap:

```dart
child: InkWell(
  onTap: () {
    // Navigate to exercise detail screen
    context.push('/analytics/exercise/${Uri.encodeComponent(history.exerciseName)}');
  },
  borderRadius: BorderRadius.circular(12),
```

**Step 2: Verify compilation**

Run: `flutter analyze lib/features/analytics/presentation/analytics_screen.dart`

Expected: `No issues found!`

**Step 3: Test navigation (manual)**

Manual test checklist:
1. Run app: `flutter run`
2. Go to Analytics page
3. Tap on any exercise
4. Verify: Exercise Detail Screen opens
5. Verify: Back button returns to Analytics

**Step 4: Commit**

```bash
git add lib/features/analytics/presentation/analytics_screen.dart
git commit -m "feat(analytics): enable navigation to exercise detail

Tap exercise card → Opens ExerciseDetailScreen
URI encode exercise name for safe routing"
```

---

## Phase 4: Localization

### Task 4.1: Add English Localization Keys

**Files:**
- Modify: `assets/i18n/app_en.arb`

**Step 1: Add all missing keys**

Add to `app_en.arb`:

```json
{
  "exerciseDetail": "Exercise Detail",
  "personalRecord": "Personal Record",
  "lastWorkout": "Last workout",
  "volumeProgression": "Volume Progression",
  "historyTab": "History",
  "recordsTab": "Records",
  "maxWeight": "Max Weight",
  "maxVolume": "Max Volume",
  "estimated1RM": "Estimated 1RM",
  "bestPerRep": "Best per Rep",
  "noSessionsYet": "No sessions yet",
  "startWorkoutCTA": "Start your first workout",
  "noRecordsYet": "Complete your first workout to see records",
  "sets": "sets",
  "totalVolume": "total volume",
  "tapToSeeWorkout": "Tap to see full workout",
  "reps": "reps"
}
```

**Step 2: Verify JSON syntax**

Run: `cat assets/i18n/app_en.arb | jq . > /dev/null`

Expected: No output (valid JSON)

**Step 3: Commit**

```bash
git add assets/i18n/app_en.arb
git commit -m "i18n: add English keys for exercise detail screen"
```

---

### Task 4.2: Add Italian Localization Keys

**Files:**
- Modify: `assets/i18n/app_it.arb`

**Step 1: Add Italian translations**

Add to `app_it.arb`:

```json
{
  "exerciseDetail": "Dettaglio Esercizio",
  "personalRecord": "Record Personale",
  "lastWorkout": "Ultimo allenamento",
  "volumeProgression": "Progressione Volume",
  "historyTab": "Cronologia",
  "recordsTab": "Records",
  "maxWeight": "Peso Massimo",
  "maxVolume": "Volume Massimo",
  "estimated1RM": "1RM Stimato",
  "bestPerRep": "Best per Ripetizione",
  "noSessionsYet": "Nessuna sessione ancora",
  "startWorkoutCTA": "Inizia il tuo primo allenamento",
  "noRecordsYet": "Completa il primo workout per vedere i tuoi record",
  "sets": "serie",
  "totalVolume": "volume totale",
  "tapToSeeWorkout": "Tap per vedere workout completo",
  "reps": "rip"
}
```

**Step 2: Verify JSON syntax**

Run: `cat assets/i18n/app_it.arb | jq . > /dev/null`

Expected: No output (valid JSON)

**Step 3: Commit**

```bash
git add assets/i18n/app_it.arb
git commit -m "i18n: add Italian keys for exercise detail screen"
```

---

### Task 4.3: Generate Localization Code

**Files:**
- Generated files in `lib/shared/presentation/l10n/generated/`

**Step 1: Run flutter gen-l10n**

Run: `flutter gen-l10n`

Expected output:
```
Generating localizations...
Generated localizations: lib/shared/presentation/l10n/generated/
```

**Step 2: Verify generated files exist**

Run: `ls lib/shared/presentation/l10n/generated/app_localizations*.dart`

Expected: 3 files (base + en + it)

**Step 3: Verify compilation**

Run: `flutter analyze`

Expected: Pre-existing issues only (no NEW errors)

**Step 4: Commit**

```bash
git add lib/shared/presentation/l10n/generated/
git commit -m "i18n: generate localizations for exercise detail"
```

---

## Phase 5: Cache Invalidation Integration

### Task 5.1: Add Cache Invalidation to Workout Provider

**Files:**
- Modify: `lib/features/workout/presentation/providers/workout_provider.dart`

**Step 1: Find completeWorkout method**

Search for the `completeWorkout` method in WorkoutProvider.

**Step 2: Add invalidation after save**

Add after workout save logic:

```dart
// Import at top
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_records_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';

// In completeWorkout method, after save:
// Invalidate analytics cache for each exercise
for (final exercise in workout.exercises) {
  ref.invalidate(exerciseRecordsProvider(exercise.name));
  ref.invalidate(exerciseHistoryByNameProvider((userId, exercise.name)));
}

// Invalidate general analytics list
ref.invalidate(exerciseHistoryStreamProvider(userId));
```

**Step 3: Verify compilation**

Run: `flutter analyze lib/features/workout/presentation/providers/workout_provider.dart`

Expected: No NEW issues

**Step 4: Test invalidation (manual)**

Manual test:
1. Open app → Go to Analytics
2. Tap exercise → See current data
3. Go back → Complete a workout with that exercise
4. Return to Analytics → Tap same exercise
5. Verify: New workout appears in History tab
6. Verify: PRs updated if applicable

**Step 5: Commit**

```bash
git add lib/features/workout/presentation/providers/workout_provider.dart
git commit -m "feat(analytics): add cache invalidation on workout completion

- Invalidate exercise records cache
- Invalidate exercise history cache
- Invalidate analytics stream
- Ensures fresh data after workout"
```

---

## Phase 6: Testing & Polish

### Task 6.1: Test Empty States

**Manual Test Checklist:**

1. **New User (0 workouts)**:
   - [ ] Analytics screen shows empty state
   - [ ] Exercise detail not accessible (no exercises to tap)

2. **After First Workout**:
   - [ ] Analytics shows 1 exercise
   - [ ] Tap exercise → Detail screen loads
   - [ ] Chart shows 1 data point
   - [ ] History shows 1 session
   - [ ] Records show actual values (not 0)

3. **Dark/Light Theme**:
   - [ ] Switch theme in settings
   - [ ] Chart colors adapt
   - [ ] PR badge colors correct
   - [ ] Cards readable in both modes

**Step 1: Document test results**

Create: `docs/testing/exercise-detail-manual-tests.md`

Record all test results with screenshots if possible.

**Step 2: Commit test documentation**

```bash
git add docs/testing/exercise-detail-manual-tests.md
git commit -m "docs: add manual test results for exercise detail"
```

---

### Task 6.2: Performance Verification

**Manual Performance Test:**

1. **Measure First Load**:
   - Clear app data
   - Open Analytics
   - Tap exercise
   - Measure time from tap to data visible

   Target: < 500ms

2. **Measure Cached Load**:
   - Back to Analytics
   - Tap same exercise again
   - Measure time

   Target: < 50ms

3. **Test with 100+ Workouts** (if available):
   - Tap exercise with many sessions
   - Verify smooth scrolling in History tab
   - Verify chart renders without lag

**Step 1: Document performance results**

Add to `docs/testing/exercise-detail-manual-tests.md`:

```markdown
## Performance Results

### First Load
- Time to data visible: XXXms
- Target: < 500ms
- Result: PASS/FAIL

### Cached Load
- Time to data visible: XXms
- Target: < 50ms
- Result: PASS/FAIL

### Scroll Performance (100+ workouts)
- Smooth scrolling: YES/NO
- Chart render time: XXXms
```

**Step 2: Commit performance results**

```bash
git add docs/testing/exercise-detail-manual-tests.md
git commit -m "docs: add performance test results"
```

---

### Task 6.3: Final Cleanup

**Step 1: Run flutter analyze**

Run: `flutter analyze`

Fix any NEW issues introduced by this implementation.

**Step 2: Format all code**

Run: `dart format lib/features/analytics/`

**Step 3: Final commit**

```bash
git add .
git commit -m "style: format analytics code"
```

---

## Summary

**Implementation complete!** 🎉

**Files Created** (13 total):
1. `lib/features/analytics/domain/entities/exercise_records.dart`
2. `lib/features/analytics/presentation/providers/exercise_records_provider.dart`
3. `lib/features/analytics/presentation/screens/exercise_detail_screen.dart`
4. `lib/features/analytics/presentation/widgets/pr_badge_header.dart`
5. `lib/features/analytics/presentation/widgets/volume_progression_chart.dart`
6. `lib/features/analytics/presentation/widgets/history_tab.dart`
7. `lib/features/analytics/presentation/widgets/session_history_card.dart`
8. `lib/features/analytics/presentation/widgets/records_tab.dart`
9. `docs/testing/exercise-detail-manual-tests.md`

**Files Modified** (4 total):
1. `lib/app/app.dart` - Added route
2. `lib/features/analytics/presentation/analytics_screen.dart` - Enabled navigation
3. `lib/features/workout/presentation/providers/workout_provider.dart` - Cache invalidation
4. `pubspec.yaml` - Added timeago dependency

**Localization Files Modified** (2):
1. `assets/i18n/app_en.arb`
2. `assets/i18n/app_it.arb`

**Total Tasks**: 19 (6 phases)
**Estimated Time**: ~3-4 hours

---

## Next Steps

After implementation:
1. Use `superpowers:finishing-a-development-branch` to merge/PR
2. Test on real device with production data
3. Gather user feedback
4. Iterate if needed

**Design Document**: `docs/plans/2025-01-18-exercise-detail-design.md`
**Implementation Plan**: `docs/plans/2025-01-18-exercise-detail-screen.md` (this file)
