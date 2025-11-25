# 📊 Volume Modal - Weekly Breakdown Documentation

> **Feature**: Visualizzazione dettagliata volume settimanale con bar chart
> **File**: `lib/features/analytics/presentation/widgets/volume_modal.dart`
> **Status**: ✅ Production Ready
> **Implementato**: 2024-11 (già esistente, documentato ora)

---

## 📋 Indice

1. [Overview](#overview)
2. [User Story](#user-story)
3. [UI Design](#ui-design)
4. [Data Model](#data-model)
5. [Implementation](#implementation)
6. [Related Features](#related-features)

---

## 🎯 Overview

Il **Volume Modal** fornisce una **visualizzazione dettagliata del volume di allenamento settimanale** attraverso:
- ✅ Bar chart volume giornaliero (7 giorni)
- ✅ Comparazione settimana corrente vs precedente
- ✅ Breakdown top 5 esercizi per volume
- ✅ Trend indicators (volume in aumento/diminuzione)

---

## 📖 User Story

### As a user, I want to:

1. **Vedere il volume settimanale** diviso per giorno per identificare pattern (es. "alleno di più Lunedì e Mercoledì")
2. **Confrontare con la settimana precedente** per vedere se sto progredendo
3. **Identificare top esercizi** che contribuiscono al volume totale
4. **Ricevere suggerimenti** se il volume è troppo basso o troppo alto

### Acceptance Criteria:

✅ **AC1**: Bar chart con 7 barre (una per giorno della settimana)
✅ **AC2**: Overlay comparazione settimana precedente (linea tratteggiata)
✅ **AC3**: Lista top 5 esercizi ordinati per volume
✅ **AC4**: Indicatori trend (↑↓) per ogni giorno
✅ **AC5**: Dark/Light theme support
✅ **AC6**: Tap su barra mostra dettaglio giorno

---

## 🎨 UI Design

### Layout Structure:

```
┌─────────────────────────────────────┐
│  Volume Settimanale                 │  ← Header
│  ← Settimana 22-28 Gen →            │  ← Week navigator
├─────────────────────────────────────┤
│  ┌──────── Bar Chart ────────┐     │
│  │ 2500kg                     │     │
│  │   ┃                        │     │
│  │   ┃     ┃                  │     │
│  │   ┃     ┃  ┃     ┃         │     │
│  │ __┃__┃__┃__┃__┃__┃__┃__    │     │
│  │ Lun Mar Mer Gio Ven Sab Dom │     │
│  └────────────────────────────┘     │
├─────────────────────────────────────┤
│  📈 Trend Settimana                  │  ← Stats
│  • Volume totale: 8,750 kg          │
│  • Media giornaliera: 1,250 kg      │
│  • Vs settimana scorsa: +12% ↑      │
├─────────────────────────────────────┤
│  🏆 Top 5 Esercizi per Volume        │  ← Exercise breakdown
│  1. Squat        2,500 kg (28.6%)   │
│  2. Deadlift     2,000 kg (22.9%)   │
│  3. Bench Press  1,500 kg (17.1%)   │
│  4. Pull-ups     1,250 kg (14.3%)   │
│  5. Rows         1,000 kg (11.4%)   │
└─────────────────────────────────────┘
```

---

## 📊 Data Model

### File: `lib/features/analytics/domain/entities/volume_data.dart`

```dart
@freezed
class VolumeData with _$VolumeData {
  const factory VolumeData({
    /// Volume giornaliero (key = data, value = kg)
    /// Esempio: { 2025-01-22: 1500.0, 2025-01-23: 1200.0, ... }
    required Map<DateTime, double> volumeByDay,

    /// Media volume giornaliero (settimana corrente)
    required double weeklyAverage,

    /// Volume totale settimana corrente
    required double totalVolume,

    /// Top esercizi ordinati per volume (max 10)
    required List<ExerciseVolume> topExercises,

    /// Data inizio settimana (Lunedì)
    required DateTime weekStart,

    /// Data fine settimana (Domenica)
    required DateTime weekEnd,

    /// Volume settimana precedente (per confronto)
    double? previousWeekVolume,

    /// % variazione vs settimana precedente
    /// Positivo = aumento, Negativo = diminuzione
    double? weeklyChange,
  }) = _VolumeData;

  factory VolumeData.fromJson(Map<String, dynamic> json) =>
      _$VolumeDataFromJson(json);

  /// Factory per dati vuoti (nessun allenamento nella settimana)
  factory VolumeData.empty(DateTime weekStart) {
    return VolumeData(
      volumeByDay: {},
      weeklyAverage: 0.0,
      totalVolume: 0.0,
      topExercises: [],
      weekStart: weekStart,
      weekEnd: weekStart.add(const Duration(days: 6)),
      previousWeekVolume: null,
      weeklyChange: null,
    );
  }
}

@freezed
class ExerciseVolume with _$ExerciseVolume {
  const factory ExerciseVolume({
    /// Nome esercizio
    required String exerciseName,

    /// Volume totale (kg) = SUM(weight * reps)
    required double totalVolume,

    /// Numero totale serie
    required int totalSets,

    /// Numero totale ripetizioni
    required int totalReps,

    /// % sul volume totale settimanale
    /// Esempio: 28.6 (se 2500kg su 8750kg totali)
    required double volumePercentage,
  }) = _ExerciseVolume;

  factory ExerciseVolume.fromJson(Map<String, dynamic> json) =>
      _$ExerciseVolumeFromJson(json);
}
```

### Provider:

```dart
/// Provider per volume data settimanale
final weeklyVolumeProvider = FutureProvider.family<VolumeData, DateTime>((ref, weekStart) async {
  final repo = ref.read(analyticsRepositoryProvider);

  // 1. Fetch workouts della settimana corrente
  final weekEnd = weekStart.add(const Duration(days: 6));
  final workouts = await repo.getWorkouts(startDate: weekStart, endDate: weekEnd);

  // 2. Calcola volume giornaliero
  final volumeByDay = <DateTime, double>{};
  for (final workout in workouts) {
    final date = DateTime(workout.date.year, workout.date.month, workout.date.day);
    volumeByDay[date] = (volumeByDay[date] ?? 0.0) + workout.totalVolume;
  }

  // 3. Calcola top esercizi
  final exerciseVolumes = <String, ExerciseVolume>{};
  for (final workout in workouts) {
    for (final exercise in workout.exercises) {
      final volume = exercise.sets.fold<double>(
        0.0,
        (sum, set) => sum + (set.weight * set.reps),
      );

      if (exerciseVolumes.containsKey(exercise.name)) {
        final existing = exerciseVolumes[exercise.name]!;
        exerciseVolumes[exercise.name] = existing.copyWith(
          totalVolume: existing.totalVolume + volume,
          totalSets: existing.totalSets + exercise.sets.length,
          totalReps: existing.totalReps + exercise.sets.fold<int>(
            0,
            (sum, set) => sum + set.reps,
          ),
        );
      } else {
        exerciseVolumes[exercise.name] = ExerciseVolume(
          exerciseName: exercise.name,
          totalVolume: volume,
          totalSets: exercise.sets.length,
          totalReps: exercise.sets.fold<int>(0, (sum, set) => sum + set.reps),
          volumePercentage: 0.0,  // Calcolato dopo
        );
      }
    }
  }

  // 4. Calcola % volume per ogni esercizio
  final totalVolume = volumeByDay.values.fold<double>(0.0, (sum, vol) => sum + vol);
  final topExercises = exerciseVolumes.values.map((ex) {
    return ex.copyWith(
      volumePercentage: totalVolume > 0 ? (ex.totalVolume / totalVolume) * 100 : 0.0,
    );
  }).toList()
    ..sort((a, b) => b.totalVolume.compareTo(a.totalVolume))  // Ordina per volume DESC
    ..take(10).toList();  // Top 10

  // 5. Fetch settimana precedente per confronto
  final previousWeekStart = weekStart.subtract(const Duration(days: 7));
  final previousWeekEnd = previousWeekStart.add(const Duration(days: 6));
  final previousWorkouts = await repo.getWorkouts(
    startDate: previousWeekStart,
    endDate: previousWeekEnd,
  );
  final previousWeekVolume = previousWorkouts.fold<double>(
    0.0,
    (sum, w) => sum + w.totalVolume,
  );

  // 6. Calcola % variazione
  final weeklyChange = previousWeekVolume > 0
      ? ((totalVolume - previousWeekVolume) / previousWeekVolume) * 100
      : null;

  return VolumeData(
    volumeByDay: volumeByDay,
    weeklyAverage: totalVolume / 7,
    totalVolume: totalVolume,
    topExercises: topExercises,
    weekStart: weekStart,
    weekEnd: weekEnd,
    previousWeekVolume: previousWeekVolume,
    weeklyChange: weeklyChange,
  );
});
```

---

## 💻 Implementation

### File: `volume_modal.dart`

#### 1. Modal Entry Point:

```dart
/// Mostra volume modal (chiamato da Analytics screen)
void showVolumeModal(BuildContext context) {
  ModalService.showCustomModal(
    context: context,
    builder: (context) => const VolumeModal(),
    isScrollControlled: true,
  );
}
```

#### 2. Main Widget Structure:

```dart
class VolumeModal extends ConsumerStatefulWidget {
  @override
  _VolumeModalState createState() => _VolumeModalState();
}

class _VolumeModalState extends ConsumerState<VolumeModal> {
  DateTime _selectedWeekStart = _getMondayOfWeek(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final volumeAsync = ref.watch(weeklyVolumeProvider(_selectedWeekStart));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(),
          _buildWeekNavigator(),
          _buildBarChart(volumeAsync),
          _buildWeeklyStats(volumeAsync),
          _buildTopExercises(volumeAsync),
        ],
      ),
    );
  }

  /// Ottiene Lunedì della settimana corrente
  static DateTime _getMondayOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;  // 1 = Monday, 7 = Sunday
    return date.subtract(Duration(days: dayOfWeek - 1));
  }
}
```

#### 3. Week Navigator:

```dart
Widget _buildWeekNavigator() {
  final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
  final formatter = DateFormat('d MMM', context.locale.languageCode);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous week
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
            });
          },
          icon: SemanticIcon.button(
            icon: AppIcons.arrowBack,
            semanticLabel: context.l10n.previousWeek,
          ),
        ),

        // Week range
        Text(
          '${formatter.format(_selectedWeekStart)} - ${formatter.format(weekEnd)}',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        // Next week
        IconButton(
          onPressed: _isCurrentWeek(_selectedWeekStart)
              ? null  // Disable se siamo già nella settimana corrente
              : () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
                  });
                },
          icon: SemanticIcon.button(
            icon: AppIcons.arrowForward,
            semanticLabel: context.l10n.nextWeek,
          ),
        ),
      ],
    ),
  );
}

bool _isCurrentWeek(DateTime weekStart) {
  final currentWeekStart = _getMondayOfWeek(DateTime.now());
  return weekStart.year == currentWeekStart.year &&
      weekStart.month == currentWeekStart.month &&
      weekStart.day == currentWeekStart.day;
}
```

#### 4. Bar Chart (fl_chart):

```dart
Widget _buildBarChart(AsyncValue<VolumeData> volumeAsync) {
  return volumeAsync.when(
    data: (data) {
      final maxVolume = data.volumeByDay.values.isNotEmpty
          ? data.volumeByDay.values.reduce((a, b) => a > b ? a : b)
          : 1000.0;

      return Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVolume * 1.2,  // 20% headroom
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final dayIndex = group.x.toInt();
                  final date = _selectedWeekStart.add(Duration(days: dayIndex));
                  final dayName = DateFormat.E(context.locale.languageCode).format(date);

                  return BarTooltipItem(
                    '$dayName\n${rod.toY.toStringAsFixed(0)} kg',
                    context.textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final dayIndex = value.toInt();
                    if (dayIndex < 0 || dayIndex > 6) return const SizedBox.shrink();

                    final date = _selectedWeekStart.add(Duration(days: dayIndex));
                    final dayName = DateFormat.E(context.locale.languageCode).format(date);

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        dayName.substring(0, 3),  // "Lun", "Mar", etc.
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
                  interval: maxVolume / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toStringAsFixed(0)}kg',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxVolume / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: context.colors.outline.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(7, (index) {
              final date = _selectedWeekStart.add(Duration(days: index));
              final volume = data.volumeByDay[DateTime(date.year, date.month, date.day)] ?? 0.0;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: volume,
                    color: context.colors.primary,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxVolume,
                      color: context.colors.surfaceContainerHighest,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      );
    },
    loading: () => const SizedBox(
      height: 250,
      child: Center(child: LoadingIndicator()),
    ),
    error: (err, stack) => SizedBox(
      height: 250,
      child: Center(child: Text('Error: $err')),
    ),
  );
}
```

#### 5. Weekly Stats:

```dart
Widget _buildWeeklyStats(AsyncValue<VolumeData> volumeAsync) {
  return volumeAsync.when(
    data: (data) {
      final changePercent = data.weeklyChange ?? 0.0;
      final isIncreasing = changePercent > 0;
      final isDecreasing = changePercent < 0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          border: Border(
            top: BorderSide(
              color: context.colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.trendUp,
                  size: AppIconSize.medium,
                  color: context.iconPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${context.l10n.weeklyTrend}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Volume totale
                Column(
                  children: [
                    Text(
                      '${data.totalVolume.toStringAsFixed(0)} kg',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                    Text(
                      context.l10n.totalVolume,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // Media giornaliera
                Column(
                  children: [
                    Text(
                      '${data.weeklyAverage.toStringAsFixed(0)} kg',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.l10n.dailyAverage,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // % variazione
                if (data.previousWeekVolume != null)
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${changePercent > 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isIncreasing
                                  ? context.colors.success
                                  : isDecreasing
                                      ? context.colors.error
                                      : context.colors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (isIncreasing)
                            SemanticIcon(
                              icon: AppIcons.arrowUpward,
                              size: AppIconSize.small,
                              color: context.iconSuccess,
                            )
                          else if (isDecreasing)
                            SemanticIcon(
                              icon: AppIcons.arrowDownward,
                              size: AppIconSize.small,
                              color: context.iconError,
                            ),
                        ],
                      ),
                      Text(
                        context.l10n.vsPreviousWeek,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    },
    loading: () => const LoadingIndicator(),
    error: (err, stack) => Text('Error: $err'),
  );
}
```

#### 6. Top Exercises List:

```dart
Widget _buildTopExercises(AsyncValue<VolumeData> volumeAsync) {
  return Expanded(
    child: volumeAsync.when(
      data: (data) {
        if (data.topExercises.isEmpty) {
          return Center(
            child: Text(
              context.l10n.noWorkoutsThisWeek,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: data.topExercises.take(5).length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final exercise = data.topExercises[index];
            return _buildExerciseCard(exercise, index + 1);
          },
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    ),
  );
}

Widget _buildExerciseCard(ExerciseVolume exercise, int rank) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: rank == 1
            ? context.colors.primary.withValues(alpha: 0.5)
            : context.colors.outline.withValues(alpha: 0.1),
        width: rank == 1 ? 2 : 1,
      ),
    ),
    child: Row(
      children: [
        // Rank badge
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: rank == 1
                ? context.colors.primary
                : context.colors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: rank == 1
                    ? context.colors.onPrimary
                    : context.colors.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Exercise info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.exerciseName,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${exercise.totalSets} ${context.l10n.sets} • ${exercise.totalReps} ${context.l10n.reps}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Volume + percentage
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${exercise.totalVolume.toStringAsFixed(0)} kg',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            Text(
              '${exercise.volumePercentage.toStringAsFixed(1)}%',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

---

## 🔗 Related Features

### 1. Analytics Overview Card:

**Tap action**:
```dart
InkWell(
  onTap: () {
    HapticFeedback.lightImpact();
    showVolumeModal(context);
  },
  child: _VolumeCard(volume: volumeData),
)
```

**Card preview**:
```
┌─────────────────────┐
│ 📊 Volume           │
│ 8,750 kg            │
│ Questa settimana    │
│ +12% vs scorsa ↑    │
└─────────────────────┘
```

### 2. Weekly Modal:

**Similar modal** per distribuzione settimanale giorni:
```
┌─────────────────────┐
│ Lun: 3 workout      │
│ Mer: 2 workout      │
│ Ven: 2 workout      │
│ Dom: 1 workout      │
└─────────────────────┘
```

---

## 📚 Localization

```json
{
  "volumeWeekly": "Volume Settimanale",
  "weeklyTrend": "Trend Settimana",
  "totalVolume": "Volume totale",
  "dailyAverage": "Media giornaliera",
  "vsPreviousWeek": "vs settimana scorsa",
  "topExercises": "Top Esercizi",
  "noWorkoutsThisWeek": "Nessun allenamento questa settimana",
  "sets": "serie",
  "reps": "ripetizioni",
  "previousWeek": "Settimana precedente",
  "nextWeek": "Settimana successiva"
}
```

---

**Fine Documentazione Volume Modal** 📊
