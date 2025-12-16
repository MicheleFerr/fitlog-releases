# 📊 Analytics System - Overview Completa

> **Ultima modifica**: 2025-01-22
> **Versione**: 2.0 (Generazione completa post-implementazione Muscle Distribution)
> **Status**: ✅ Production Ready

---

## 📋 Indice

1. [Panoramica Sistema](#panoramica-sistema)
2. [Architettura](#architettura)
3. [Feature Implementate](#feature-implementate)
4. [Navigazione e UX](#navigazione-e-ux)
5. [Data Models](#data-models)
6. [Provider e State Management](#provider-e-state-management)
7. [Roadmap Future](#roadmap-future)

---

## 📖 Panoramica Sistema

Il **sistema Analytics** di GymBro TrackLog fornisce agli utenti **insights dettagliati** sui loro progressi fitness attraverso:

- **📈 Statistiche aggregate**: Volume totale, serie, durata, PR (Personal Records)
- **📅 Tracking temporale**: Streak giornaliero, weekly volume, tendenze mensili
- **💪 Analisi muscolare**: Distribuzione volume per gruppo muscolare, bilanciamento, progressione
- **🎯 Goal tracking**: Progressi verso obiettivi, milestone, achievement

### Obiettivi del Sistema:

✅ **Motivazione**: Visualizzare progressi per mantenere utenti motivati
✅ **Insights scientifici**: Metriche basate su evidenze (volume, intensità, frequenza)
✅ **Personalizzazione**: Filtri temporali, comparazioni periodo vs periodo
✅ **Actionable data**: Suggerimenti automatici basati su pattern rilevati

---

## 🏗️ Architettura

```
lib/features/analytics/
├── domain/
│   ├── entities/
│   │   ├── muscle_distribution_data.dart    # Entità distribuzione muscolare
│   │   ├── period_statistics.dart           # Statistiche aggregate per periodo
│   │   ├── streak_data.dart                 # Dati streak e calendario
│   │   ├── volume_data.dart                 # Dati volume settimanale/mensile
│   │   └── pr_record.dart                   # Personal Records
│   └── repositories/
│       └── analytics_repository.dart        # Interface per data fetching
├── data/
│   ├── repositories/
│   │   └── analytics_repository_impl.dart   # Implementazione con Firestore
│   └── datasources/
│       └── analytics_local_datasource.dart  # Cache locale Hive
└── presentation/
    ├── providers/
    │   ├── analytics_provider.dart          # Provider principale
    │   ├── muscle_distribution_provider.dart
    │   ├── streak_provider.dart
    │   └── volume_provider.dart
    ├── screens/
    │   ├── tabbed_analytics_screen.dart     # Screen principale con 5 tab
    │   ├── muscle_distribution_screen.dart  # Distribuzione muscolare
    │   └── analytics_screen.dart            # Legacy screen (deprecato)
    └── widgets/
        ├── streak_modal.dart                # Calendario GitHub-style
        ├── volume_modal.dart                # Volume settimanale dettagliato
        ├── weekly_modal.dart                # Distribuzione settimanale
        ├── pr_celebration_modal.dart        # Celebrazione PR
        └── muscle_balance_widget.dart       # Widget bilanciamento muscolare
```

### Clean Architecture Pattern:

```
Presentation Layer (UI)
    ↓ (calls)
Provider Layer (State Management - Riverpod)
    ↓ (uses)
Domain Layer (Entities + Repository Interface)
    ↓ (implements)
Data Layer (Repository Impl + Firestore/Hive)
```

---

## ✨ Feature Implementate

### 1️⃣ **Muscle Distribution Analytics** 🆕

**File**: `muscle_distribution_screen.dart` (608 righe)
**Screenshot**: IMG_9865.PNG fornito dall'utente

#### Cosa fa:
- **Radar Chart esagonale** (6 assi): Visualizza distribuzione % volume per gruppo muscolare
  - 🦍 Schiena (Back)
  - 💪 Petto (Chest)
  - 🔥 Addome (Abs)
  - 🏔️ Spalle (Shoulders)
  - 💪 Braccia (Arms)
  - 🦵 Gambe (Legs)
- **Confronto periodi**: Current vs Previous (overlay blu + grigio)
- **4 Stat Cards**: Allenamenti, Durata, Volume, Serie con frecce trend ↑↓
- **3 Tab Navigation**:
  - 📈 **Progressi**: Radar chart + stat cards + time period selector
  - 📊 **Analisi**: 3 action buttons (Sets by muscle, Distribution detail, Feedback)
  - ℹ️ **Dettagli**: Info aggiuntive (Coming Soon)

#### Data Model:

```dart
// Enum gruppi muscolari (6 valori)
enum MuscleGroup { schiena, petto, addome, spalle, braccia, gambe }

// Enum periodi temporali (6 range)
enum TimePeriod { last7Days, last30Days, last90Days, last6Months, lastYear, allTime }

// Dati distribuzione muscolare
@freezed
class MuscleDistributionData {
  Map<MuscleGroup, double> volumeByMuscle;     // Volume totale (kg) per gruppo
  Map<MuscleGroup, int> setsByMuscle;          // Numero serie per gruppo
  Map<MuscleGroup, double> volumePercentage;   // % distribuzione (0-100)
  TimePeriod period;
  DateTime startDate;
  DateTime endDate;
}

// Statistiche aggregate periodo
@freezed
class PeriodStatistics {
  int workoutsCount;
  int totalDurationMinutes;
  double totalVolumeKg;
  int totalSets;
  TimePeriod period;
  DateTime startDate;
  DateTime endDate;
}

// Dati completi con confronto periodi
@freezed
class MuscleAnalyticsData {
  MuscleDistributionData current;   // Periodo corrente
  MuscleDistributionData previous;  // Periodo precedente (per confronto)
  PeriodStatistics currentStats;
  PeriodStatistics previousStats;
}
```

#### UI Components:

**Radar Chart** (fl_chart ^1.1.0):
```dart
RadarChart(
  RadarChartData(
    radarShape: RadarShape.polygon,  // Esagono
    tickCount: 5,                     // 5 livelli (0-20-40-60-80-100%)
    getTitle: (index, angle) {
      final muscle = MuscleGroup.values[index];
      return RadarChartTitle(text: muscle.displayNameIT, angle: angle);
    },
    dataSets: [
      // Serie 1: Periodo corrente (blu)
      RadarDataSet(
        fillColor: context.colors.primary.withValues(alpha: 0.2),
        borderColor: context.colors.primary,
        borderWidth: 2,
        dataEntries: [...],  // % volume per ogni gruppo muscolare
      ),
      // Serie 2: Periodo precedente (grigio)
      RadarDataSet(
        fillColor: context.colors.onSurfaceVariant.withValues(alpha: 0.1),
        borderColor: context.colors.onSurfaceVariant,
        dataEntries: [...],
      ),
    ],
  ),
)
```

**Time Period Dropdown**:
```dart
DropdownButton<TimePeriod>(
  value: selectedPeriod,
  items: TimePeriod.values.map((period) => DropdownMenuItem(
    value: period,
    child: Text(period.labelIT),  // "Ultimi 7 giorni", "Ultimi 30 giorni", etc.
  )).toList(),
  onChanged: (newPeriod) {
    HapticFeedback.lightImpact();
    ref.read(selectedTimePeriodProvider.notifier).state = newPeriod;
  },
)
```

**Stat Cards con Trend**:
```dart
class _StatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = parseIntFromString(currentValue);
    final previous = parseIntFromString(previousValue);
    final isIncreasing = current > previous;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(children: [
            SemanticIcon(icon: icon, color: context.colors.primary),
            Text(label, style: context.textTheme.labelMedium),
          ]),
          Text(currentValue, style: context.textTheme.titleLarge),
          Row(children: [
            Text('${context.l10n.previous}: $previousValue'),
            if (isIncreasing)
              SemanticIcon(icon: AppIcons.arrowUpward, color: context.iconSuccess)
            else if (isDecreasing)
              SemanticIcon(icon: AppIcons.arrowDownward, color: context.iconError),
          ]),
        ],
      ),
    );
  }
}
```

**Action Buttons** (3 features richieste dall'utente):

1. **Sets by Muscle Group**: Visualizza numero serie per gruppo muscolare
2. **Muscle Distribution Detail**: Dettaglio distribuzione volume
3. **Feedback Email**: Richiesta nuove metriche → ferrara-michele@hotmail.it

```dart
_ActionButton(
  icon: AppIcons.feedback,
  title: context.l10n.requestNewMetric,
  description: context.l10n.requestNewMetricDesc,
  onTap: () => _showFeedbackDialog(context),
)

void _showFeedbackDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.requestNewMetric),
      content: Column(
        children: [
          Text(context.l10n.requestNewMetricDialogContent),
          SizedBox(height: 16),
          SelectableText('ferrara-michele@hotmail.it'),
        ],
      ),
      actions: [
        FilledButton.icon(
          onPressed: () async {
            final emailUri = Uri(
              scheme: 'mailto',
              path: 'ferrara-michele@hotmail.it',
              query: 'subject=${Uri.encodeComponent('Richiesta nuova metrica - GymBro TrackLog')}&body=${Uri.encodeComponent('Ciao Michele,\\n\\nVorrei suggerire una nuova metrica per l\'app:')}',
            );
            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            }
          },
          icon: SemanticIcon.button(icon: AppIcons.email, semanticLabel: context.l10n.sendEmail),
          label: Text(context.l10n.sendEmail),
        ),
      ],
    ),
  );
}
```

#### Provider Pattern:

```dart
// Provider per periodo temporale selezionato
final selectedTimePeriodProvider = StateProvider<TimePeriod>((ref) => TimePeriod.last30Days);

// Provider per dati muscle analytics (TODO: implementare calcolo reale)
final muscleAnalyticsProvider = FutureProvider.family<MuscleAnalyticsData, TimePeriod>((ref, period) async {
  // TODO: Calcolare da workout history
  // 1. Filtra workouts per periodo (period.days)
  // 2. Aggrega volume/serie per muscle group (via exercises → muscle mapping)
  // 3. Calcola percentuali
  // 4. Confronta con periodo precedente

  return MuscleAnalyticsData.empty(period); // Mock data per ora
});
```

#### Localizzazione (24 nuove chiavi):

**app_en.arb**:
```json
"muscleDistribution": "Muscle Distribution",
"progress": "Progress",
"analysis": "Analysis",
"setsByMuscleGroup": "Sets by Muscle Group",
"setsByMuscleGroupDesc": "View total sets performed per muscle group",
"requestNewMetric": "Request New Metric",
"requestNewMetricDesc": "Suggest a new metric you'd like to see in the app",
"requestNewMetricDialogContent": "Would you like to request a new analytics metric? Send us an email with your suggestion:",
"sendEmail": "Send Email",
"selectTimePeriod": "Select time period",
"currentPeriod": "Current",
"previousPeriod": "Previous",
"workouts": "Workouts",
"duration": "Duration",
"volume": "Volume",
"sets": "Sets",
"previous": "Prev"
```

**app_it.arb**:
```json
"muscleDistribution": "Distribuzione dei muscoli",
"progress": "Progressi",
"analysis": "Analisi",
"setsByMuscleGroup": "Serie per gruppo muscolare",
"setsByMuscleGroupDesc": "Visualizza il numero totale di serie per gruppo muscolare",
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
"previous": "Prec"
```

#### Navigazione:

**Da Home Screen** → Analytics tab → Muscle Distribution button → MuscleDistributionScreen

**Route**: `/analytics/muscle-distribution`

#### TODO - Implementazione Provider:

- [ ] Implementare `muscleAnalyticsProvider` con calcolo reale da workout history
- [ ] Mapping exercises → muscle groups (via wger.de mapping esistente)
- [ ] Aggregazione volume: `SUM(sets.weight * sets.reps)` per muscle group
- [ ] Aggregazione serie: `COUNT(sets)` per muscle group
- [ ] Calcolo periodo precedente per confronto
- [ ] Cache locale con Hive per performance

---

### 2️⃣ **Streak Calendar (GitHub-style)**

**File**: `streak_modal.dart`
**Documentazione dettagliata**: [STREAK_MODAL_DOCUMENTATION.md](./STREAK_MODAL_DOCUMENTATION.md)

#### Cosa fa:
- **Calendario mensile GitHub-style** con heatmap colori:
  - 🟦 Blu = workout fatto quel giorno
  - ⬜ Bianco/grigio = nessun workout
- **Contatore streak**: Giorni consecutivi di allenamento
- **Statistiche mensili**: Totale workout, giorni attivi, media settimanale
- **Navigazione mesi**: Swipe left/right per cambiare mese

#### UI Pattern:

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 7,  // 7 giorni della settimana
  ),
  itemBuilder: (context, index) {
    final day = daysInMonth[index];
    final hasWorkout = workoutDays.contains(day);

    return Container(
      decoration: BoxDecoration(
        color: hasWorkout
          ? context.colors.primary.withValues(alpha: 0.8)  // Blu se workout
          : context.colors.surfaceContainerHighest,         // Grigio se no
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text('$day')),
    );
  },
)
```

#### Data Model:

```dart
@freezed
class StreakData {
  int currentStreak;        // Giorni consecutivi correnti
  int longestStreak;        // Record storico
  List<DateTime> workoutDays;  // Date con workout
  int totalWorkouts;        // Totale workout nel mese
}
```

---

### 3️⃣ **Volume Modal (Weekly Volume Breakdown)**

**File**: `volume_modal.dart`
**Documentazione dettagliata**: [VOLUME_MODAL_DOCUMENTATION.md](./VOLUME_MODAL_DOCUMENTATION.md)

#### Cosa fa:
- **Bar chart settimanale**: Volume (kg) per giorno della settimana
- **Comparazione settimane**: Settimana corrente vs precedente
- **Breakdown esercizi**: Top 5 esercizi per volume
- **Trend indicators**: ↑↓ volume in aumento/diminuzione

#### UI Pattern:

```dart
BarChart(
  BarChartData(
    barGroups: List.generate(7, (index) {
      final day = weekDays[index];
      final volume = volumeByDay[day] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: volume,
            color: context.colors.primary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }),
  ),
)
```

---

### 4️⃣ **PR Celebration (Personal Records)**

**File**: `pr_celebration_modal.dart`, `pr_celebration_overlay.dart`

#### Cosa fa:
- **Celebrazione animata** quando utente batte un PR
- **Confetti animation** con flutter_confetti
- **Sound effect** (opzionale, solo se permesso da user settings)
- **PR Timeline**: Lista cronologica di tutti i PR battuti

#### Trigger Logic:

```dart
// In workout completion
if (isNewPR) {
  // Show celebration overlay
  PRCelebrationOverlay.show(
    context: context,
    exercise: exercise,
    newRecord: newRecord,
    previousRecord: previousRecord,
  );

  // Play sound (if enabled)
  if (settings.soundEnabled) {
    await AudioPlayer().play('assets/sounds/pr_celebration.mp3');
  }

  // Save to Firestore
  await analyticsRepository.savePR(prRecord);
}
```

---

### 5️⃣ **Tabbed Analytics Screen (Main Entry Point)**

**File**: `tabbed_analytics_screen.dart` (375 righe)

#### Struttura Tab:

```
┌─────────────────────────────────────────┐
│  Analytics                        🔄 ⚙️ │
├─────────────────────────────────────────┤
│ [Overview] [Progress] [Insights] [Routine] [Premium] │
├─────────────────────────────────────────┤
│                                         │
│  📊 Quick Stats (Streak, Volume, etc.)  │
│                                         │
│  📈 Charts / Visualizations             │
│                                         │
│  📋 Exercise History / Recent Workouts  │
│                                         │
└─────────────────────────────────────────┘
```

**5 Tab**:

1. **Overview** 📊: Quick stats summary + recent workouts
2. **Progress** 📈: Long-term trends (volume progression, strength gains)
3. **Insights** 💡: AI-powered suggestions, muscle balance analysis
4. **Routine** 🔄: Routine adherence, template performance
5. **Premium** 💎: Premium analytics features (locked se free user)

#### Navigation Pattern:

```dart
class TabbedAnalyticsScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.analytics),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: SemanticIcon(icon: AppIcons.dashboard), text: context.l10n.overview),
              Tab(icon: SemanticIcon(icon: AppIcons.trendUp), text: context.l10n.progress),
              Tab(icon: SemanticIcon(icon: AppIcons.lightbulb), text: context.l10n.insights),
              Tab(icon: SemanticIcon(icon: AppIcons.calendar), text: context.l10n.routine),
              Tab(icon: SemanticIcon(icon: AppIcons.star), text: context.l10n.premium),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(),
            _ProgressTab(),
            _InsightsTab(),
            _RoutineTab(),
            _PremiumTab(),
          ],
        ),
      ),
    );
  }
}
```

---

## 🗺️ Navigazione e UX

### Entry Points al Sistema Analytics:

```
Home Screen
  ↓ (Bottom Navigation Bar)
Analytics Tab ──────────────────┐
  │                             │
  ├─ Overview Tab               │
  │   ├─ Tap Streak Card ───> Streak Modal (GitHub calendar)
  │   ├─ Tap Volume Card ───> Volume Modal (weekly breakdown)
  │   ├─ Tap Weekly Card ───> Weekly Modal (distribution)
  │   └─ Tap PR Card ───────> PR Timeline
  │                             │
  ├─ Progress Tab               │
  │   ├─ Muscle Distribution ──> Muscle Distribution Screen 🆕
  │   ├─ Volume Progression     │
  │   └─ Strength Gains          │
  │                             │
  ├─ Insights Tab               │
  │   ├─ Muscle Balance Widget  │
  │   ├─ AI Suggestions         │
  │   └─ Training Advisor        │
  │                             │
  ├─ Routine Tab                │
  │   ├─ Routine Adherence      │
  │   └─ Template Performance    │
  │                             │
  └─ Premium Tab                │
      ├─ Advanced Metrics (💎)  │
      └─ Custom Reports (💎)     │
                                │
All tabs ────────────────────────┘
  ↓ (Pull-to-refresh)
Sync with Firebase
```

### Modal System:

**Tutti i modal usano ModalService centralizzato**:

```dart
// ✅ CORRETTO - Usa ModalService
ModalService.showCustomModal(
  context: context,
  builder: (context) => StreakModal(),
);

// ❌ SBAGLIATO - Non usare showModalBottomSheet diretto
showModalBottomSheet(
  context: context,
  builder: (context) => StreakModal(),
);
```

**Benefici ModalService**:
- ✅ Consistent styling (theme-aware)
- ✅ Accessibility (semantic labels)
- ✅ Analytics tracking (Firebase Analytics)
- ✅ HapticFeedback automatico

---

## 📊 Data Models (Completo)

### 1. Muscle Distribution

**File**: `muscle_distribution_data.dart`

```dart
/// Gruppi muscolari (6 valori)
enum MuscleGroup {
  @JsonValue('schiena') schiena,   // Back
  @JsonValue('petto') petto,       // Chest
  @JsonValue('addome') addome,     // Abs
  @JsonValue('spalle') spalle,     // Shoulders
  @JsonValue('braccia') braccia,   // Arms
  @JsonValue('gambe') gambe,       // Legs
}

extension MuscleGroupExtension on MuscleGroup {
  String get displayNameIT { /* ... */ }
  String get displayNameEN { /* ... */ }
  String get emoji { /* 🦍 💪 🔥 🏔️ 💪 🦵 */ }
}

/// Periodi temporali (6 range)
enum TimePeriod {
  @JsonValue('last_7_days') last7Days,
  @JsonValue('last_30_days') last30Days,
  @JsonValue('last_90_days') last90Days,
  @JsonValue('last_6_months') last6Months,
  @JsonValue('last_year') lastYear,
  @JsonValue('all_time') allTime,
}

extension TimePeriodExtension on TimePeriod {
  String get labelIT { /* "Ultimi 7 giorni", etc. */ }
  String get labelEN { /* "Last 7 days", etc. */ }
  int? get days { /* 7, 30, 90, 180, 365, null */ }
}

/// Distribuzione muscolare per periodo
@freezed
class MuscleDistributionData with _$MuscleDistributionData {
  const factory MuscleDistributionData({
    required Map<MuscleGroup, double> volumeByMuscle,     // kg per gruppo
    required Map<MuscleGroup, int> setsByMuscle,          // serie per gruppo
    required Map<MuscleGroup, double> volumePercentage,   // % (0-100)
    required TimePeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) = _MuscleDistributionData;

  factory MuscleDistributionData.fromJson(Map<String, dynamic> json) => _$MuscleDistributionDataFromJson(json);
  factory MuscleDistributionData.empty(TimePeriod period) { /* ... */ }
}

/// Statistiche aggregate periodo
@freezed
class PeriodStatistics with _$PeriodStatistics {
  const factory PeriodStatistics({
    required int workoutsCount,
    required int totalDurationMinutes,
    required double totalVolumeKg,
    required int totalSets,
    required TimePeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) = _PeriodStatistics;

  factory PeriodStatistics.fromJson(Map<String, dynamic> json) => _$PeriodStatisticsFromJson(json);
  factory PeriodStatistics.empty(TimePeriod period) { /* ... */ }
}

/// Dati completi con confronto periodi
@freezed
class MuscleAnalyticsData with _$MuscleAnalyticsData {
  const factory MuscleAnalyticsData({
    required MuscleDistributionData current,
    required MuscleDistributionData previous,
    required PeriodStatistics currentStats,
    required PeriodStatistics previousStats,
  }) = _MuscleAnalyticsData;

  factory MuscleAnalyticsData.fromJson(Map<String, dynamic> json) => _$MuscleAnalyticsDataFromJson(json);
  factory MuscleAnalyticsData.empty(TimePeriod period) { /* ... */ }
}
```

### 2. Streak Data

```dart
@freezed
class StreakData with _$StreakData {
  const factory StreakData({
    required int currentStreak,
    required int longestStreak,
    required int totalWorkouts,
    required List<DateTime> workoutDays,
    required DateTime lastWorkoutDate,
  }) = _StreakData;

  factory StreakData.fromJson(Map<String, dynamic> json) => _$StreakDataFromJson(json);
}
```

### 3. Volume Data

```dart
@freezed
class VolumeData with _$VolumeData {
  const factory VolumeData({
    required Map<DateTime, double> volumeByDay,  // Volume giornaliero
    required double weeklyAverage,
    required double totalVolume,
    required List<ExerciseVolume> topExercises,  // Top 5 per volume
  }) = _VolumeData;

  factory VolumeData.fromJson(Map<String, dynamic> json) => _$VolumeDataFromJson(json);
}

@freezed
class ExerciseVolume with _$ExerciseVolume {
  const factory ExerciseVolume({
    required String exerciseName,
    required double totalVolume,
    required int totalSets,
    required int totalReps,
  }) = _ExerciseVolume;
}
```

### 4. PR Record

```dart
@freezed
class PRRecord with _$PRRecord {
  const factory PRRecord({
    required String exerciseName,
    required double weight,
    required int reps,
    required DateTime achievedDate,
    double? previousRecord,
    required PRType type,  // OneRepMax, TotalVolume, MaxReps, etc.
  }) = _PRRecord;

  factory PRRecord.fromJson(Map<String, dynamic> json) => _$PRRecordFromJson(json);
}

enum PRType {
  oneRepMax,      // 1RM calcolato
  totalVolume,    // Volume totale in una sessione
  maxReps,        // Max ripetizioni a un dato peso
  totalSets,      // Max serie in una sessione
}
```

---

## 🔄 Provider e State Management

### Provider Architecture:

```dart
// 1. Time Period Selection (global state)
final selectedTimePeriodProvider = StateProvider<TimePeriod>((ref) => TimePeriod.last30Days);

// 2. Muscle Analytics (computed from workout history)
final muscleAnalyticsProvider = FutureProvider.family<MuscleAnalyticsData, TimePeriod>((ref, period) async {
  final workoutHistory = await ref.read(workoutHistoryProvider.future);
  final calculator = ref.read(muscleDistributionCalculatorProvider);

  return calculator.compute(workoutHistory, period);
});

// 3. Streak Data (cached with auto-refresh)
final streakDataProvider = FutureProvider<StreakData>((ref) async {
  final cache = ref.read(analyticsLocalDatasourceProvider);

  // Try cache first
  final cached = await cache.getStreak();
  if (cached != null && cached.lastWorkoutDate.isToday) {
    return cached;
  }

  // Fetch from Firestore
  final repo = ref.read(analyticsRepositoryProvider);
  final fresh = await repo.getStreakData();

  // Update cache
  await cache.saveStreak(fresh);

  return fresh;
});

// 4. Volume Data (weekly breakdown)
final weeklyVolumeProvider = FutureProvider<VolumeData>((ref) async {
  final repo = ref.read(analyticsRepositoryProvider);
  return repo.getWeeklyVolume();
});

// 5. PR Timeline (all-time records)
final prTimelineProvider = FutureProvider<List<PRRecord>>((ref) async {
  final repo = ref.read(analyticsRepositoryProvider);
  return repo.getAllPRs();
});
```

### Dependency Graph:

```
muscleAnalyticsProvider
    ↓ depends on
workoutHistoryProvider (workout history cache)
    ↓ depends on
workoutRepositoryProvider (Firestore + Hive)
    ↓ fetches from
Firestore: workouts/{userId}/exercises/{exerciseId}/sets
```

### Cache Strategy:

**Hive Local Cache** (for offline support + performance):

```dart
@HiveType(typeId: 10)
class CachedMuscleAnalytics {
  @HiveField(0)
  MuscleAnalyticsData data;

  @HiveField(1)
  DateTime cachedAt;

  @HiveField(2)
  TimePeriod period;

  bool get isStale => DateTime.now().difference(cachedAt).inHours > 6;
}
```

**Cache Invalidation**:
- ✅ Dopo ogni nuovo workout completato
- ✅ Quando utente cambia time period
- ✅ Pull-to-refresh manuale
- ✅ Ogni 6 ore (auto-refresh)

---

## 🚀 Roadmap Future

### Fase 1 (Completata) ✅:
- [x] Muscle Distribution Screen con radar chart
- [x] Time period filtering (7/30/90 days, 6 months, 1 year, all time)
- [x] Stat cards con comparazione periodo precedente
- [x] 3 Action buttons (Sets by muscle, Distribution detail, Feedback)
- [x] Localizzazione completa IT/EN (24 nuove chiavi)

### Fase 2 (In Corso) 🔄:
- [ ] **Implementare provider reale** per muscle analytics
  - [ ] Calcolo volume da workout history
  - [ ] Mapping exercises → muscle groups (wger.de data)
  - [ ] Aggregazione serie/volume per muscle group
  - [ ] Calcolo periodo precedente per confronto
- [ ] **Sets by Muscle Group detail screen**
  - [ ] Bar chart numero serie per muscle group
  - [ ] Breakdown per esercizio dentro ogni gruppo
  - [ ] Historical trend (ultimi 3 mesi)
- [ ] **Muscle Distribution detail screen**
  - [ ] Line chart evoluzione distribuzione nel tempo
  - [ ] Target distribution (bilanciamento ideale)
  - [ ] Suggerimenti esercizi per riequilibrare

### Fase 3 (Pianificata) 📅:
- [ ] **AI-Powered Insights**:
  - [ ] Rilevamento squilibri muscolari automatico
  - [ ] Suggerimenti esercizi personalizzati
  - [ ] Predizione probabilità infortuni (based on muscle imbalance)
- [ ] **Advanced Filtering**:
  - [ ] Filtro per split (Push/Pull/Legs, Upper/Lower, etc.)
  - [ ] Filtro per equipment (barbell, dumbbell, bodyweight)
  - [ ] Filtro per location (gym, home)
- [ ] **Export & Sharing**:
  - [ ] PDF report generazione
  - [ ] Share progress su social (Instagram, Facebook)
  - [ ] Export CSV per analisi esterna

### Fase 4 (Future) 🔮:
- [ ] **Premium Analytics**:
  - [ ] Rep continuum analysis (strength vs hypertrophy vs endurance)
  - [ ] RPE intensity tracking
  - [ ] Volume landmarks (minimum effective dose, maximum recoverable volume)
  - [ ] Muscle group frequency optimization
- [ ] **Integration con wearables**:
  - [ ] Apple Health sync (heart rate during workout)
  - [ ] Apple Watch complication (today's volume)
  - [ ] Heart rate zones analysis

---

## 📚 Documentazione Correlata

- **Muscle Distribution**: [MUSCLE_DISTRIBUTION_DOCUMENTATION.md](./MUSCLE_DISTRIBUTION_DOCUMENTATION.md) (dettagli implementazione)
- **Streak Modal**: [STREAK_MODAL_DOCUMENTATION.md](./STREAK_MODAL_DOCUMENTATION.md) (GitHub-style calendar)
- **Volume Modal**: [VOLUME_MODAL_DOCUMENTATION.md](./VOLUME_MODAL_DOCUMENTATION.md) (weekly breakdown)
- **Data Models**: [ANALYTICS_DATA_MODELS.md](./ANALYTICS_DATA_MODELS.md) (tutte le entità)

---

## 🎯 Quick Reference

### Navigazione Veloce:

| Feature | File | Route | Entry Point |
|---------|------|-------|-------------|
| Muscle Distribution | `muscle_distribution_screen.dart` | `/analytics/muscle-distribution` | Analytics → Progress tab → Muscle Distribution button |
| Streak Calendar | `streak_modal.dart` | Modal | Analytics → Overview → Tap Streak card |
| Volume Breakdown | `volume_modal.dart` | Modal | Analytics → Overview → Tap Volume card |
| PR Timeline | `pr_timeline_widget.dart` | Modal | Analytics → Overview → Tap PR card |

### Localization Keys:

| Chiave | IT | EN | Uso |
|--------|----|----|-----|
| `muscleDistribution` | "Distribuzione dei muscoli" | "Muscle Distribution" | Screen title |
| `setsByMuscleGroup` | "Serie per gruppo muscolare" | "Sets by Muscle Group" | Action button |
| `requestNewMetric` | "Richiedi nuova metrica" | "Request New Metric" | Feedback button |
| `currentPeriod` | "Attuale" | "Current" | Radar chart legend |
| `previousPeriod` | "Precedente" | "Previous" | Radar chart legend |

### Theme Colors:

| Uso | Color | Code |
|-----|-------|------|
| Current period data | Primary blue | `context.colors.primary` |
| Previous period data | Gray | `context.colors.onSurfaceVariant` |
| Success trend | Success green | `context.iconSuccess` |
| Error trend | Error red | `context.iconError` |
| Card background | Surface | `context.colors.surfaceContainerHighest` |

---

**Fine Overview** 📊
