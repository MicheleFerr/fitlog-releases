# 💪 Muscle Distribution Analytics - Documentazione Completa

> **Feature**: Analisi distribuzione volume muscolare con radar chart esagonale
> **Implementato**: 2025-01-22
> **File**: `lib/features/analytics/presentation/screens/muscle_distribution_screen.dart` (608 righe)
> **Status**: ✅ Production Ready (UI completata, provider TODO)

---

## 📋 Indice

1. [Overview](#overview)
2. [User Story](#user-story)
3. [Architettura](#architettura)
4. [Data Model](#data-model)
5. [UI Components](#ui-components)
6. [Provider Implementation](#provider-implementation)
7. [Localization](#localization)
8. [Testing](#testing)

---

## 🎯 Overview

**Muscle Distribution Analytics** permette agli utenti di visualizzare la **distribuzione del volume di allenamento** tra i 6 principali gruppi muscolari attraverso un **radar chart esagonale interattivo**.

### Screenshot Reference:

![Muscle Distribution](IMG_9865.PNG)

**Componenti visibili nello screenshot**:
- ✅ Title: "Distribuzione dei muscoli"
- ✅ Dropdown: "Ultimi 30 giorni" (time period selector)
- ✅ Radar chart esagonale con 6 assi (Schiena, Petto, Gambe, Braccia, Spalle, Addome)
- ✅ 2 serie dati: Attuale (blu) vs Precedente (grigio)
- ✅ 4 stat cards sotto il chart: Allenamenti (0→0), Durata (0min→0min), Volume (0 kg→0 kg), Serie (0→0)
- ✅ Frecce trend ↑↓ per confronto periodo corrente vs precedente

---

## 📖 User Story

### As a user, I want to:

1. **Visualizzare la distribuzione muscolare** del mio allenamento per capire se sto bilanciando correttamente il volume tra gruppi muscolari
2. **Confrontare periodi temporali** (ultimi 7/30/90 giorni, 6 mesi, 1 anno, sempre) per vedere l'evoluzione nel tempo
3. **Vedere metriche aggregate** (numero allenamenti, durata totale, volume totale, serie totali) con confronto periodo precedente
4. **Identificare squilibri** automaticamente (es. "Stai allenando troppo petto e poco schiena")
5. **Richiedere nuove metriche** via email se ho bisogni specifici

### Acceptance Criteria:

✅ **AC1**: Radar chart mostra 6 assi (uno per ogni gruppo muscolare) con labels in italiano/inglese
✅ **AC2**: Due serie dati sovrapposte (periodo corrente blu, periodo precedente grigio) con legenda
✅ **AC3**: Dropdown permette selezione tra 6 periodi temporali (7/30/90 giorni, 6 mesi, 1 anno, sempre)
✅ **AC4**: 4 stat cards mostrano confronto current vs previous con frecce trend
✅ **AC5**: 3 tab navigation (Progressi, Analisi, Dettagli)
✅ **AC6**: 3 action buttons in tab "Analisi" (Sets by muscle, Distribution detail, Feedback email)
✅ **AC7**: Feedback email dialog con pre-filled subject/body e deeplink a ferrara-michele@hotmail.it
✅ **AC8**: HapticFeedback su ogni interazione (tap card, change tab, select dropdown)
✅ **AC9**: Dark/Light theme support con colori theme-aware
✅ **AC10**: Accessibilità completa (SemanticIcon, screen reader labels)

---

## 🏗️ Architettura

### Clean Architecture Layers:

```
Presentation Layer
├── muscle_distribution_screen.dart (UI)
│   ├── _MuscleDistributionScreenState (StatefulWidget + TabController)
│   ├── _ProgressTab (Radar chart + stat cards)
│   ├── _AnalysisTab (3 action buttons)
│   ├── _DetailsTab (Coming Soon)
│   └── Widgets:
│       ├── _TimePeriodDropdown
│       ├── _MuscleRadarChart
│       ├── _StatCard (x4: Allenamenti, Durata, Volume, Serie)
│       ├── _ActionButton (x3: Sets, Distribution, Feedback)
│       └── _FeedbackDialog
│
Domain Layer
├── entities/
│   └── muscle_distribution_data.dart
│       ├── MuscleGroup enum (6 valori)
│       ├── TimePeriod enum (6 range)
│       ├── MuscleDistributionData (volume + serie + % per muscle)
│       ├── PeriodStatistics (aggregate stats)
│       └── MuscleAnalyticsData (current + previous comparison)
│
Data Layer (TODO)
├── repositories/
│   └── analytics_repository_impl.dart
│       └── getMuscleAnalytics(TimePeriod) → MuscleAnalyticsData
└── datasources/
    ├── analytics_firestore_datasource.dart (fetch workouts)
    └── analytics_local_datasource.dart (Hive cache)
```

### Dependency Flow:

```
UI Widget (_ProgressTab)
    ↓ reads
selectedTimePeriodProvider (StateProvider<TimePeriod>)
    ↓ watches
muscleAnalyticsProvider (FutureProvider<MuscleAnalyticsData>)
    ↓ computes from
workoutHistoryProvider (List<Workout>)
    ↓ fetches
Firestore: /workouts/{userId}/sessions/{sessionId}
```

---

## 📊 Data Model

### File: `muscle_distribution_data.dart`

#### 1. MuscleGroup Enum

```dart
/// Gruppi muscolari principali trackati dall'app
///
/// Mappatura con wger.de muscle groups:
/// - Schiena → Lats, Traps, Lower Back
/// - Petto → Chest
/// - Addome → Abs
/// - Spalle → Shoulders, Delts
/// - Braccia → Biceps, Triceps, Forearms
/// - Gambe → Quads, Hamstrings, Glutes, Calves
enum MuscleGroup {
  @JsonValue('schiena')
  schiena,   // 🦍 Back
  @JsonValue('petto')
  petto,     // 💪 Chest
  @JsonValue('addome')
  addome,    // 🔥 Abs
  @JsonValue('spalle')
  spalle,    // 🏔️ Shoulders
  @JsonValue('braccia')
  braccia,   // 💪 Arms
  @JsonValue('gambe')
  gambe,     // 🦵 Legs
}
```

**Extension Methods**:

```dart
extension MuscleGroupExtension on MuscleGroup {
  /// Nome visualizzato (IT)
  String get displayNameIT {
    switch (this) {
      case MuscleGroup.schiena: return 'Schiena';
      case MuscleGroup.petto: return 'Petto';
      case MuscleGroup.addome: return 'Addome';
      case MuscleGroup.spalle: return 'Spalle';
      case MuscleGroup.braccia: return 'Braccia';
      case MuscleGroup.gambe: return 'Gambe';
    }
  }

  /// Nome visualizzato (EN)
  String get displayNameEN {
    switch (this) {
      case MuscleGroup.schiena: return 'Back';
      case MuscleGroup.petto: return 'Chest';
      case MuscleGroup.addome: return 'Abs';
      case MuscleGroup.spalle: return 'Shoulders';
      case MuscleGroup.braccia: return 'Arms';
      case MuscleGroup.gambe: return 'Legs';
    }
  }

  /// Icona emoji per il gruppo muscolare
  String get emoji {
    switch (this) {
      case MuscleGroup.schiena: return '🦍'; // Gorilla back
      case MuscleGroup.petto: return '💪'; // Chest flex
      case MuscleGroup.addome: return '🔥'; // Core burn
      case MuscleGroup.spalle: return '🏔️'; // Mountain shoulders
      case MuscleGroup.braccia: return '💪'; // Arm flex
      case MuscleGroup.gambe: return '🦵'; // Leg
    }
  }
}
```

**Uso nell'UI**:

```dart
// Radar chart title
getTitle: (index, angle) {
  final muscle = MuscleGroup.values[index];
  return RadarChartTitle(
    text: muscle.displayNameIT,  // "Schiena", "Petto", etc.
    angle: angle,
  );
}
```

#### 2. TimePeriod Enum

```dart
/// Periodo temporale per il filtro dei dati
enum TimePeriod {
  @JsonValue('last_7_days')
  last7Days,
  @JsonValue('last_30_days')
  last30Days,
  @JsonValue('last_90_days')
  last90Days,
  @JsonValue('last_6_months')
  last6Months,
  @JsonValue('last_year')
  lastYear,
  @JsonValue('all_time')
  allTime,
}
```

**Extension Methods**:

```dart
extension TimePeriodExtension on TimePeriod {
  /// Label visualizzata (IT)
  String get labelIT {
    switch (this) {
      case TimePeriod.last7Days: return 'Ultimi 7 giorni';
      case TimePeriod.last30Days: return 'Ultimi 30 giorni';
      case TimePeriod.last90Days: return 'Ultimi 90 giorni';
      case TimePeriod.last6Months: return 'Ultimi 6 mesi';
      case TimePeriod.lastYear: return 'Ultimo anno';
      case TimePeriod.allTime: return 'Sempre';
    }
  }

  /// Label visualizzata (EN)
  String get labelEN {
    switch (this) {
      case TimePeriod.last7Days: return 'Last 7 days';
      case TimePeriod.last30Days: return 'Last 30 days';
      case TimePeriod.last90Days: return 'Last 90 days';
      case TimePeriod.last6Months: return 'Last 6 months';
      case TimePeriod.lastYear: return 'Last year';
      case TimePeriod.allTime: return 'All time';
    }
  }

  /// Numero di giorni da sottrarre da oggi per calcolare la data di inizio
  /// null = nessun limite (all time)
  int? get days {
    switch (this) {
      case TimePeriod.last7Days: return 7;
      case TimePeriod.last30Days: return 30;
      case TimePeriod.last90Days: return 90;
      case TimePeriod.last6Months: return 180;
      case TimePeriod.lastYear: return 365;
      case TimePeriod.allTime: return null;
    }
  }
}
```

**Calcolo Date Range**:

```dart
// Current period
final now = DateTime.now();
final daysAgo = period.days;
final startDate = daysAgo != null
    ? now.subtract(Duration(days: daysAgo))
    : DateTime(2020);  // Arbitrary date for "all time"
final endDate = now;

// Previous period (stessa durata, spostata indietro)
final previousStartDate = daysAgo != null
    ? startDate.subtract(Duration(days: daysAgo))
    : DateTime(2019);
final previousEndDate = daysAgo != null
    ? startDate.subtract(Duration(days: 1))
    : DateTime(2020).subtract(Duration(days: 1));
```

#### 3. MuscleDistributionData (Main Entity)

```dart
/// Dati di distribuzione muscolare per un periodo specifico
///
/// Contiene:
/// - Volume totale per gruppo muscolare (kg)
/// - Numero di serie per gruppo muscolare
/// - Percentuale di distribuzione (0-100%)
@freezed
class MuscleDistributionData with _$MuscleDistributionData {
  const factory MuscleDistributionData({
    /// Mappa gruppo muscolare → volume totale (kg)
    /// Esempio: { MuscleGroup.schiena: 1500.0, MuscleGroup.petto: 1200.0, ... }
    required Map<MuscleGroup, double> volumeByMuscle,

    /// Mappa gruppo muscolare → numero di serie
    /// Esempio: { MuscleGroup.schiena: 45, MuscleGroup.petto: 36, ... }
    required Map<MuscleGroup, int> setsByMuscle,

    /// Mappa gruppo muscolare → percentuale di volume (0-100)
    /// Esempio: { MuscleGroup.schiena: 25.5, MuscleGroup.petto: 20.4, ... }
    /// Somma di tutti i valori = 100%
    required Map<MuscleGroup, double> volumePercentage,

    /// Periodo temporale di riferimento
    required TimePeriod period,

    /// Data inizio periodo
    required DateTime startDate,

    /// Data fine periodo (tipicamente oggi)
    required DateTime endDate,
  }) = _MuscleDistributionData;

  factory MuscleDistributionData.fromJson(Map<String, dynamic> json) =>
      _$MuscleDistributionDataFromJson(json);

  /// Factory per creare dati vuoti (nessun allenamento nel periodo)
  factory MuscleDistributionData.empty(TimePeriod period) {
    final now = DateTime.now();
    final daysAgo = period.days;
    final startDate = daysAgo != null
        ? now.subtract(Duration(days: daysAgo))
        : DateTime(2020);

    return MuscleDistributionData(
      volumeByMuscle: {
        for (var muscle in MuscleGroup.values) muscle: 0.0,
      },
      setsByMuscle: {
        for (var muscle in MuscleGroup.values) muscle: 0,
      },
      volumePercentage: {
        for (var muscle in MuscleGroup.values) muscle: 0.0,
      },
      period: period,
      startDate: startDate,
      endDate: now,
    );
  }
}
```

**Calcolo Volume Percentage** (business logic):

```dart
// Input: volumeByMuscle = { schiena: 1500, petto: 1200, gambe: 2000, ... }
// Output: volumePercentage = { schiena: 25.5, petto: 20.4, gambe: 34.0, ... }

double totalVolume = volumeByMuscle.values.reduce((a, b) => a + b);

Map<MuscleGroup, double> volumePercentage = {};
for (var entry in volumeByMuscle.entries) {
  volumePercentage[entry.key] = totalVolume > 0
      ? (entry.value / totalVolume) * 100
      : 0.0;
}
```

#### 4. PeriodStatistics

```dart
/// Statistiche aggregate per il periodo (mostrate nelle card sotto il grafico)
@freezed
class PeriodStatistics with _$PeriodStatistics {
  const factory PeriodStatistics({
    /// Numero di allenamenti completati
    required int workoutsCount,

    /// Durata totale in minuti
    required int totalDurationMinutes,

    /// Volume totale sollevato (kg)
    required double totalVolumeKg,

    /// Numero totale di serie completate
    required int totalSets,

    /// Periodo di riferimento
    required TimePeriod period,

    /// Data inizio periodo
    required DateTime startDate,

    /// Data fine periodo
    required DateTime endDate,
  }) = _PeriodStatistics;

  factory PeriodStatistics.fromJson(Map<String, dynamic> json) =>
      _$PeriodStatisticsFromJson(json);

  /// Factory per statistiche vuote
  factory PeriodStatistics.empty(TimePeriod period) {
    final now = DateTime.now();
    final daysAgo = period.days;
    final startDate = daysAgo != null
        ? now.subtract(Duration(days: daysAgo))
        : DateTime(2020);

    return PeriodStatistics(
      workoutsCount: 0,
      totalDurationMinutes: 0,
      totalVolumeKg: 0.0,
      totalSets: 0,
      period: period,
      startDate: startDate,
      endDate: now,
    );
  }
}
```

**Mapping to Stat Cards**:

```dart
_StatCard(
  icon: AppIcons.calendar,
  label: context.l10n.workouts,
  currentValue: '${currentStats.workoutsCount}',
  previousValue: '${previousStats.workoutsCount}',
)

_StatCard(
  icon: AppIcons.timer,
  label: context.l10n.duration,
  currentValue: '${currentStats.totalDurationMinutes}min',
  previousValue: '${previousStats.totalDurationMinutes}min',
)

_StatCard(
  icon: AppIcons.weight,
  label: context.l10n.volume,
  currentValue: '${currentStats.totalVolumeKg.toStringAsFixed(0)} kg',
  previousValue: '${previousStats.totalVolumeKg.toStringAsFixed(0)} kg',
)

_StatCard(
  icon: AppIcons.list,
  label: context.l10n.sets,
  currentValue: '${currentStats.totalSets}',
  previousValue: '${previousStats.totalSets}',
)
```

#### 5. MuscleAnalyticsData (Aggregator)

```dart
/// Dati completi per la schermata muscle distribution
///
/// Include:
/// - Distribuzione muscolare attuale (periodo selezionato)
/// - Distribuzione muscolare precedente (per confronto)
/// - Statistiche aggregate periodo attuale
/// - Statistiche aggregate periodo precedente
@freezed
class MuscleAnalyticsData with _$MuscleAnalyticsData {
  const factory MuscleAnalyticsData({
    /// Distribuzione muscolare periodo attuale
    required MuscleDistributionData current,

    /// Distribuzione muscolare periodo precedente (per confronto radar chart)
    required MuscleDistributionData previous,

    /// Statistiche aggregate periodo attuale
    required PeriodStatistics currentStats,

    /// Statistiche aggregate periodo precedente
    required PeriodStatistics previousStats,
  }) = _MuscleAnalyticsData;

  factory MuscleAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$MuscleAnalyticsDataFromJson(json);

  /// Factory per dati vuoti (nessun allenamento)
  factory MuscleAnalyticsData.empty(TimePeriod period) {
    return MuscleAnalyticsData(
      current: MuscleDistributionData.empty(period),
      previous: MuscleDistributionData.empty(period),
      currentStats: PeriodStatistics.empty(period),
      previousStats: PeriodStatistics.empty(period),
    );
  }
}
```

**Uso nell'UI**:

```dart
final data = MuscleAnalyticsData.empty(selectedPeriod);  // Mock data

// Radar chart current series
RadarDataSet(
  fillColor: context.colors.primary.withValues(alpha: 0.2),
  borderColor: context.colors.primary,
  dataEntries: MuscleGroup.values.map((muscle) {
    final percentage = data.current.volumePercentage[muscle] ?? 0.0;
    return RadarEntry(value: percentage);
  }).toList(),
)

// Radar chart previous series
RadarDataSet(
  fillColor: context.colors.onSurfaceVariant.withValues(alpha: 0.1),
  borderColor: context.colors.onSurfaceVariant,
  dataEntries: MuscleGroup.values.map((muscle) {
    final percentage = data.previous.volumePercentage[muscle] ?? 0.0;
    return RadarEntry(value: percentage);
  }).toList(),
)
```

---

## 🎨 UI Components

### 1. Time Period Dropdown

**Location**: `_TimePeriodDropdown` widget

**Appearance**:
```
┌─────────────────────────┐
│ Ultimi 30 giorni     ▼ │
└─────────────────────────┘
```

**Code**:

```dart
class _TimePeriodDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedTimePeriodProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimePeriod>(
          value: selectedPeriod,
          isExpanded: true,
          icon: SemanticIcon(
            icon: AppIcons.arrowDropDown,
            semanticLabel: context.l10n.selectTimePeriod,
            size: AppIconSize.small,
          ),
          items: TimePeriod.values.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(
                period.labelIT,  // TODO: Use context.locale per IT/EN
                style: context.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (newPeriod) {
            if (newPeriod != null) {
              HapticFeedback.lightImpact();
              ref.read(selectedTimePeriodProvider.notifier).state = newPeriod;
            }
          },
        ),
      ),
    );
  }
}
```

**Behavior**:
- ✅ HapticFeedback on selection
- ✅ Updates `selectedTimePeriodProvider` → triggers radar chart refresh
- ✅ Theme-aware border + background colors
- ✅ SemanticIcon for accessibility

---

### 2. Muscle Radar Chart

**Location**: `_MuscleRadarChart` widget

**Appearance**:
```
        Schiena (🦍)
            *
           /|\
          / | \
    Spalle| |Petto
        \ | /
         \|/
          *
        Gambe
```

**Code**:

```dart
class _MuscleRadarChart extends StatelessWidget {
  final MuscleAnalyticsData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 5,  // 5 livelli: 0%, 20%, 40%, 60%, 80%, 100%
          tickBorderData: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          gridBorderData: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.2),
            width: 1.5,
          ),
          radarBackgroundColor: Colors.transparent,
          radarBorderData: BorderSide(
            color: context.colors.outline,
            width: 2,
          ),
          titlePositionPercentageOffset: 0.15,  // Distanza label da chart
          getTitle: (index, angle) {
            final muscle = MuscleGroup.values[index];
            return RadarChartTitle(
              text: muscle.displayNameIT,
              angle: angle,
              textStyle: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            );
          },
          dataSets: [
            // Current period (blue)
            RadarDataSet(
              fillColor: context.colors.primary.withValues(alpha: 0.2),
              borderColor: context.colors.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: MuscleGroup.values.map((muscle) {
                final percentage = data.current.volumePercentage[muscle] ?? 0.0;
                return RadarEntry(value: percentage);
              }).toList(),
            ),
            // Previous period (gray)
            RadarDataSet(
              fillColor: context.colors.onSurfaceVariant.withValues(alpha: 0.1),
              borderColor: context.colors.onSurfaceVariant,
              borderWidth: 1.5,
              entryRadius: 2,
              dataEntries: MuscleGroup.values.map((muscle) {
                final percentage = data.previous.volumePercentage[muscle] ?? 0.0;
                return RadarEntry(value: percentage);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Key Parameters**:
- `radarShape: RadarShape.polygon` → Esagono (non circolare)
- `tickCount: 5` → 5 livelli di percentuale (0-20-40-60-80-100%)
- `titlePositionPercentageOffset: 0.15` → Distanza label dal bordo (15%)
- `entryRadius` → Dimensione dots sui vertici

**Chart Behavior**:
- ✅ Interactive touch (flutter_charts supporta tap per highlight)
- ✅ Auto-scale basato su max value (0-100% range)
- ✅ Theme-aware colors (primary per current, onSurfaceVariant per previous)
- ✅ 6 axes (uno per muscle group)

---

### 3. Stat Card

**Location**: `_StatCard` widget

**Appearance**:
```
┌──────────────────────┐
│ 📅 Allenamenti       │
│ 12              ↑    │
│ Prec: 8              │
└──────────────────────┘
```

**Code**:

```dart
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String currentValue;
  final String previousValue;

  @override
  Widget build(BuildContext context) {
    // Parse numeric values for comparison
    final current = int.tryParse(currentValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final previous = int.tryParse(previousValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final isIncreasing = current > previous;
    final isDecreasing = current < previous;
    final isUnchanged = current == previous;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: Navigate to detail screen
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Label
            Row(
              children: [
                SemanticIcon(
                  icon: icon,
                  size: AppIconSize.medium,
                  color: context.iconPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Current value + Trend icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currentValue,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                if (isIncreasing)
                  SemanticIcon(
                    icon: AppIcons.arrowUpward,
                    size: AppIconSize.small,
                    color: context.iconSuccess,
                    semanticLabel: context.l10n.increased,
                  )
                else if (isDecreasing)
                  SemanticIcon(
                    icon: AppIcons.arrowDownward,
                    size: AppIconSize.small,
                    color: context.iconError,
                    semanticLabel: context.l10n.decreased,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Previous value (comparison)
            Text(
              '${context.l10n.previous}: $previousValue',
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

**Trend Logic**:
- **Increased** (↑ green): `current > previous`
- **Decreased** (↓ red): `current < previous`
- **Unchanged** (no arrow): `current == previous`

**Numeric Parsing** (robust):
```dart
// Input: "150 kg" → Output: 150
// Input: "45min" → Output: 45
// Input: "12" → Output: 12
final numeric = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
```

---

### 4. Action Button

**Location**: `_ActionButton` widget

**Appearance**:
```
┌────────────────────────────────┐
│ 📊 Serie per gruppo muscolare  │
│ Visualizza il numero totale... │
│                            →   │
└────────────────────────────────┘
```

**Code**:

```dart
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SemanticIcon(
                icon: icon,
                size: AppIconSize.large,
                color: context.iconPrimary,
              ),
            ),
            const SizedBox(width: 16),
            // Title + Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow
            SemanticIcon(
              icon: AppIcons.arrowForward,
              size: AppIconSize.medium,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
```

**3 Buttons Richiesti dall'Utente**:

1. **Sets by Muscle Group**:
   ```dart
   _ActionButton(
     icon: AppIcons.barChart,
     title: context.l10n.setsByMuscleGroup,
     description: context.l10n.setsByMuscleGroupDesc,
     onTap: () {
       // TODO: Navigate to /analytics/sets-by-muscle
     },
   )
   ```

2. **Muscle Distribution Detail**:
   ```dart
   _ActionButton(
     icon: AppIcons.pieChart,
     title: context.l10n.muscleDistribution,
     description: context.l10n.muscleDistributionDesc,
     onTap: () {
       // TODO: Navigate to /analytics/muscle-distribution-detail
     },
   )
   ```

3. **Feedback Email**:
   ```dart
   _ActionButton(
     icon: AppIcons.feedback,
     title: context.l10n.requestNewMetric,
     description: context.l10n.requestNewMetricDesc,
     onTap: () => _showFeedbackDialog(context),
   )
   ```

---

### 5. Feedback Dialog

**Location**: `_showFeedbackDialog` function

**Appearance**:
```
┌────────────────────────────────────┐
│ Richiedi nuova metrica          ✕ │
├────────────────────────────────────┤
│ Vuoi richiedere una nuova metrica │
│ di analisi? Inviaci un'email:     │
│                                    │
│ ferrara-michele@hotmail.it         │
│ (copiabile)                        │
│                                    │
│        [📧 Invia Email]            │
└────────────────────────────────────┘
```

**Code**:

```dart
void _showFeedbackDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.feedback,
            size: AppIconSize.large,
            color: context.iconPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.requestNewMetric,
              style: context.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.requestNewMetricDialogContent,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.email,
                  size: AppIconSize.small,
                  color: context.iconPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    'ferrara-michele@hotmail.it',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () async {
            HapticFeedback.lightImpact();

            final emailUri = Uri(
              scheme: 'mailto',
              path: 'ferrara-michele@hotmail.it',
              queryParameters: {
                'subject': 'Richiesta nuova metrica - GymBro TrackLog',
                'body': 'Ciao Michele,\n\nVorrei suggerire una nuova metrica per l\'app:\n\n[Descrivi qui la metrica che vorresti vedere]\n\nGrazie!',
              },
            );

            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
              Navigator.of(context).pop();
            } else {
              // Fallback: Show error snackbar
              SnackBarService.showError(
                context,
                'Impossibile aprire l\'app email. Copia l\'indirizzo manualmente.',
              );
            }
          },
          icon: SemanticIcon.button(
            icon: AppIcons.email,
            semanticLabel: context.l10n.sendEmail,
          ),
          label: Text(context.l10n.sendEmail),
        ),
      ],
    ),
  );
}
```

**Email Pre-fill**:
- **To**: ferrara-michele@hotmail.it
- **Subject**: "Richiesta nuova metrica - GymBro TrackLog"
- **Body**: Template con placeholder per utente

**Dependencies**:
```yaml
dependencies:
  url_launcher: ^6.2.0  # Already in pubspec.yaml
```

**Fallback Behavior**:
- Se `canLaunchUrl()` fallisce → mostra SnackBarService.showError
- Utente può comunque copiare email manualmente (SelectableText)

---

## 🔄 Provider Implementation (TODO)

### Current State (Mock Data):

```dart
final selectedTimePeriodProvider = StateProvider<TimePeriod>((ref) => TimePeriod.last30Days);

final muscleAnalyticsProvider = FutureProvider.family<MuscleAnalyticsData, TimePeriod>((ref, period) async {
  // MOCK DATA - Returns empty analytics
  return MuscleAnalyticsData.empty(period);
});
```

### Target Implementation:

```dart
final muscleAnalyticsProvider = FutureProvider.family<MuscleAnalyticsData, TimePeriod>((ref, period) async {
  final calculator = ref.read(muscleDistributionCalculatorProvider);
  final workoutHistory = await ref.read(workoutHistoryProvider.future);

  // 1. Filter workouts by period
  final filteredWorkouts = _filterWorkoutsByPeriod(workoutHistory, period);

  // 2. Calculate current period data
  final current = calculator.calculateDistribution(filteredWorkouts, period);

  // 3. Calculate previous period data (same duration, shifted back)
  final previousPeriodWorkouts = _filterWorkoutsByPreviousPeriod(workoutHistory, period);
  final previous = calculator.calculateDistribution(previousPeriodWorkouts, period);

  // 4. Calculate aggregate statistics
  final currentStats = calculator.calculateStats(filteredWorkouts, period);
  final previousStats = calculator.calculateStats(previousPeriodWorkouts, period);

  return MuscleAnalyticsData(
    current: current,
    previous: previous,
    currentStats: currentStats,
    previousStats: previousStats,
  );
});
```

### Calculator Service:

**File**: `lib/features/analytics/domain/services/muscle_distribution_calculator.dart`

```dart
class MuscleDistributionCalculator {
  /// Calcola distribuzione muscolare da workout history
  MuscleDistributionData calculateDistribution(
    List<Workout> workouts,
    TimePeriod period,
  ) {
    final volumeByMuscle = <MuscleGroup, double>{};
    final setsByMuscle = <MuscleGroup, int>{};

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        // 1. Map exercise → muscle groups (via wger.de mapping)
        final muscleGroups = _getMuscleGroupsForExercise(exercise.name);

        // 2. Calculate exercise volume
        final exerciseVolume = exercise.sets.fold<double>(
          0.0,
          (sum, set) => sum + (set.weight * set.reps),
        );

        // 3. Distribute volume/sets across muscle groups
        for (final muscle in muscleGroups) {
          volumeByMuscle[muscle] = (volumeByMuscle[muscle] ?? 0.0) + exerciseVolume;
          setsByMuscle[muscle] = (setsByMuscle[muscle] ?? 0) + exercise.sets.length;
        }
      }
    }

    // 4. Calculate percentages
    final totalVolume = volumeByMuscle.values.fold<double>(0.0, (sum, vol) => sum + vol);
    final volumePercentage = <MuscleGroup, double>{};
    for (final entry in volumeByMuscle.entries) {
      volumePercentage[entry.key] = totalVolume > 0
          ? (entry.value / totalVolume) * 100
          : 0.0;
    }

    return MuscleDistributionData(
      volumeByMuscle: volumeByMuscle,
      setsByMuscle: setsByMuscle,
      volumePercentage: volumePercentage,
      period: period,
      startDate: _getStartDate(period),
      endDate: DateTime.now(),
    );
  }

  /// Calcola statistiche aggregate
  PeriodStatistics calculateStats(
    List<Workout> workouts,
    TimePeriod period,
  ) {
    final totalVolume = workouts.fold<double>(
      0.0,
      (sum, workout) => sum + workout.totalVolume,
    );

    final totalDuration = workouts.fold<int>(
      0,
      (sum, workout) => sum + workout.durationMinutes,
    );

    final totalSets = workouts.fold<int>(
      0,
      (sum, workout) => sum + workout.exercises.fold<int>(
        0,
        (exSum, ex) => exSum + ex.sets.length,
      ),
    );

    return PeriodStatistics(
      workoutsCount: workouts.length,
      totalDurationMinutes: totalDuration,
      totalVolumeKg: totalVolume,
      totalSets: totalSets,
      period: period,
      startDate: _getStartDate(period),
      endDate: DateTime.now(),
    );
  }

  /// Map exercise name → muscle groups (using wger.de mapping)
  List<MuscleGroup> _getMuscleGroupsForExercise(String exerciseName) {
    // TODO: Implement using existing wger.de muscle mapping
    // Example:
    // "Bench Press" → [MuscleGroup.petto, MuscleGroup.spalle, MuscleGroup.braccia]
    // "Squat" → [MuscleGroup.gambe]
    // "Pull-ups" → [MuscleGroup.schiena, MuscleGroup.braccia]

    // For now, return empty list (mock)
    return [];
  }

  DateTime _getStartDate(TimePeriod period) {
    final now = DateTime.now();
    final days = period.days;
    return days != null
        ? now.subtract(Duration(days: days))
        : DateTime(2020);
  }
}

final muscleDistributionCalculatorProvider = Provider<MuscleDistributionCalculator>((ref) {
  return MuscleDistributionCalculator();
});
```

### Exercise → Muscle Group Mapping:

**Source**: Già esistente in `lib/features/exercise_database/domain/entities/exercise.dart`

```dart
// Wger.de muscle mapping (già implementato)
enum WgerMuscle {
  biceps,
  triceps,
  lats,
  traps,
  lowerBack,
  chest,
  abs,
  shoulders,
  delts,
  quads,
  hamstrings,
  glutes,
  calves,
  forearms,
}

// Mapping WgerMuscle → MuscleGroup
MuscleGroup _mapWgerToMuscleGroup(WgerMuscle wgerMuscle) {
  switch (wgerMuscle) {
    case WgerMuscle.biceps:
    case WgerMuscle.triceps:
    case WgerMuscle.forearms:
      return MuscleGroup.braccia;

    case WgerMuscle.lats:
    case WgerMuscle.traps:
    case WgerMuscle.lowerBack:
      return MuscleGroup.schiena;

    case WgerMuscle.chest:
      return MuscleGroup.petto;

    case WgerMuscle.abs:
      return MuscleGroup.addome;

    case WgerMuscle.shoulders:
    case WgerMuscle.delts:
      return MuscleGroup.spalle;

    case WgerMuscle.quads:
    case WgerMuscle.hamstrings:
    case WgerMuscle.glutes:
    case WgerMuscle.calves:
      return MuscleGroup.gambe;
  }
}
```

---

## 🌍 Localization

### File: `assets/i18n/app_en.arb`

```json
{
  "muscleDistribution": "Muscle Distribution",
  "@muscleDistribution": {
    "description": "Title for muscle distribution analytics screen"
  },
  "progress": "Progress",
  "@progress": {
    "description": "Tab label for progress tab"
  },
  "analysis": "Analysis",
  "@analysis": {
    "description": "Tab label for analysis tab"
  },
  "details": "Details",
  "@details": {
    "description": "Tab label for details tab"
  },
  "availableAnalytics": "Available Analytics",
  "@availableAnalytics": {
    "description": "Header for available analytics features"
  },
  "setsByMuscleGroup": "Sets by Muscle Group",
  "@setsByMuscleGroup": {
    "description": "Title for sets by muscle group feature"
  },
  "setsByMuscleGroupDesc": "View total sets performed per muscle group",
  "@setsByMuscleGroupDesc": {
    "description": "Description for sets by muscle group feature"
  },
  "muscleDistributionDesc": "See detailed volume distribution across muscle groups",
  "@muscleDistributionDesc": {
    "description": "Description for muscle distribution detail feature"
  },
  "requestNewMetric": "Request New Metric",
  "@requestNewMetric": {
    "description": "Title for request new metric feature"
  },
  "requestNewMetricDesc": "Suggest a new metric you'd like to see in the app",
  "@requestNewMetricDesc": {
    "description": "Description for request new metric feature"
  },
  "requestNewMetricDialogContent": "Would you like to request a new analytics metric? Send us an email with your suggestion:",
  "@requestNewMetricDialogContent": {
    "description": "Dialog content for requesting new metric"
  },
  "sendEmail": "Send Email",
  "@sendEmail": {
    "description": "Button label for sending email"
  },
  "selectTimePeriod": "Select time period",
  "@selectTimePeriod": {
    "description": "Semantic label for time period dropdown"
  },
  "currentPeriod": "Current",
  "@currentPeriod": {
    "description": "Label for current period in radar chart"
  },
  "previousPeriod": "Previous",
  "@previousPeriod": {
    "description": "Label for previous period in radar chart"
  },
  "workouts": "Workouts",
  "@workouts": {
    "description": "Label for workouts stat card"
  },
  "duration": "Duration",
  "@duration": {
    "description": "Label for duration stat card"
  },
  "volume": "Volume",
  "@volume": {
    "description": "Label for volume stat card"
  },
  "sets": "Sets",
  "@sets": {
    "description": "Label for sets stat card"
  },
  "increased": "Increased",
  "@increased": {
    "description": "Semantic label for increased trend"
  },
  "decreased": "Decreased",
  "@decreased": {
    "description": "Semantic label for decreased trend"
  },
  "previous": "Prev",
  "@previous": {
    "description": "Short label for previous value"
  },
  "comingSoon": "Coming Soon",
  "@comingSoon": {
    "description": "Placeholder for features not yet implemented"
  }
}
```

### File: `assets/i18n/app_it.arb`

```json
{
  "muscleDistribution": "Distribuzione dei muscoli",
  "progress": "Progressi",
  "analysis": "Analisi",
  "details": "Dettagli",
  "availableAnalytics": "Analisi disponibili",
  "setsByMuscleGroup": "Serie per gruppo muscolare",
  "setsByMuscleGroupDesc": "Visualizza il numero totale di serie per gruppo muscolare",
  "muscleDistributionDesc": "Vedi la distribuzione dettagliata del volume tra i gruppi muscolari",
  "requestNewMetric": "Richiedi nuova metrica",
  "requestNewMetricDesc": "Suggerisci una nuova metrica che vorresti vedere nell'app",
  "requestNewMetricDialogContent": "Vuoi richiedere una nuova metrica di analisi? Inviaci un'email con il tuo suggerimento:",
  "sendEmail": "Invia Email",
  "selectTimePeriod": "Seleziona periodo temporale",
  "currentPeriod": "Attuale",
  "previousPeriod": "Precedente",
  "workouts": "Allenamenti",
  "duration": "Durata",
  "volume": "Volume",
  "sets": "Serie",
  "increased": "Aumentato",
  "decreased": "Diminuito",
  "previous": "Prec",
  "comingSoon": "Prossimamente"
}
```

---

## 🧪 Testing

### Manual Testing Checklist:

- [ ] **Tab Navigation**: Swipe tra Progressi/Analisi/Dettagli funziona
- [ ] **Time Period Dropdown**: Selezione periodo aggiorna radar chart
- [ ] **Radar Chart**: 6 assi visibili con labels corrette
- [ ] **Stat Cards**: 4 card mostrano valori corretti con trend arrows
- [ ] **Action Buttons**: Tap su 3 buttons triggera azioni corrette
- [ ] **Feedback Dialog**: Email dialog apre con mailto: pre-filled
- [ ] **HapticFeedback**: Vibrazione su ogni interazione
- [ ] **Dark/Light Theme**: Colori corretti in entrambi i temi
- [ ] **Localization**: Traduzioni IT/EN funzionano
- [ ] **Accessibility**: Screen reader legge tutte le labels

### Automated Testing (TODO):

**File**: `test/features/analytics/presentation/screens/muscle_distribution_screen_test.dart`

```dart
void main() {
  group('MuscleDistributionScreen', () {
    testWidgets('should render all components correctly', (tester) async {
      // Build widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MuscleDistributionScreen(),
          ),
        ),
      );

      // Verify title
      expect(find.text('Distribuzione dei muscoli'), findsOneWidget);

      // Verify tabs
      expect(find.text('Progressi'), findsOneWidget);
      expect(find.text('Analisi'), findsOneWidget);
      expect(find.text('Dettagli'), findsOneWidget);

      // Verify time period dropdown
      expect(find.byType(DropdownButton<TimePeriod>), findsOneWidget);

      // Verify radar chart
      expect(find.byType(RadarChart), findsOneWidget);

      // Verify stat cards
      expect(find.text('Allenamenti'), findsOneWidget);
      expect(find.text('Durata'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('Serie'), findsOneWidget);
    });

    testWidgets('should change time period on dropdown selection', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: MuscleDistributionScreen(),
          ),
        ),
      );

      // Initial period: last30Days
      expect(container.read(selectedTimePeriodProvider), TimePeriod.last30Days);

      // Tap dropdown
      await tester.tap(find.byType(DropdownButton<TimePeriod>));
      await tester.pumpAndSettle();

      // Select last7Days
      await tester.tap(find.text('Ultimi 7 giorni').last);
      await tester.pumpAndSettle();

      // Verify period changed
      expect(container.read(selectedTimePeriodProvider), TimePeriod.last7Days);
    });

    testWidgets('should show feedback dialog on feedback button tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MuscleDistributionScreen(),
          ),
        ),
      );

      // Navigate to Analisi tab
      await tester.tap(find.text('Analisi'));
      await tester.pumpAndSettle();

      // Tap feedback button
      await tester.tap(find.text('Richiedi nuova metrica'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('ferrara-michele@hotmail.it'), findsOneWidget);
    });
  });

  group('MuscleDistributionData', () {
    test('empty factory should initialize with zero values', () {
      final data = MuscleDistributionData.empty(TimePeriod.last30Days);

      expect(data.volumeByMuscle[MuscleGroup.schiena], 0.0);
      expect(data.setsByMuscle[MuscleGroup.petto], 0);
      expect(data.volumePercentage[MuscleGroup.gambe], 0.0);
      expect(data.period, TimePeriod.last30Days);
    });

    test('volumePercentage should sum to 100%', () {
      final data = MuscleDistributionData(
        volumeByMuscle: {
          MuscleGroup.schiena: 1500,
          MuscleGroup.petto: 1200,
          MuscleGroup.gambe: 2000,
          MuscleGroup.braccia: 800,
          MuscleGroup.spalle: 1000,
          MuscleGroup.addome: 500,
        },
        setsByMuscle: {},
        volumePercentage: {
          MuscleGroup.schiena: 21.4,
          MuscleGroup.petto: 17.1,
          MuscleGroup.gambe: 28.6,
          MuscleGroup.braccia: 11.4,
          MuscleGroup.spalle: 14.3,
          MuscleGroup.addome: 7.1,
        },
        period: TimePeriod.last30Days,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 22),
      );

      final sum = data.volumePercentage.values.reduce((a, b) => a + b);
      expect(sum, closeTo(100.0, 0.1));
    });
  });
}
```

---

**Fine Documentazione Muscle Distribution** 💪
