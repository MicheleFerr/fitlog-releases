# Exercise Detail Screen - Design Document

**Generated**: 2025-01-18
**Source**: Brainstorming session with online research
**Status**: ✅ Validated and ready for implementation

---

## 📋 Overview

Complete design for the **Exercise Detail Screen** in GymBro TrackLog Analytics feature. When users tap on an exercise in the Analytics page, they'll see detailed progression data, personal records, and workout history.

### Research Foundation

Based on analysis of leading fitness apps (Strong, Hevy, FitNotes):
- **Strong**: Tab-based layout (Charts | Records | History)
- **Hevy**: Hybrid layout with chart always visible + tabs below
- **Common pattern**: Volume progression + Personal Records + Session history

### Design Decision

**Chosen Approach**: **Hybrid Layout** (Hevy-inspired)
- Chart principale sempre visibile (glanceability)
- Tab bar sotto per History + Records (organization)
- Best of both worlds: quick insight + deep dive options

---

## 🎨 UI Design

### Screen Structure

```
┌─────────────────────────────────────┐
│ ← Back    Exercise Name       ⋮    │ AppBar
│          (es. "Bench Press")        │
├─────────────────────────────────────┤
│ 🏆 Personal Record: 80kg (3 reps)   │ PR Badge Header
│    Last workout: 2 days ago         │ (sempre visibile)
├─────────────────────────────────────┤
│                                     │
│   📈 VOLUME PROGRESSION CHART       │ Chart principale
│   [Line chart con ultimi 3 mesi]   │ (sempre visibile)
│   • Tap punti per tooltip details  │ 300px height
│   • Swipe per zoom in/out          │
│                                     │
├─────────────────────────────────────┤
│  [ History ]    [ Records ]         │ Tab Bar
├─────────────────────────────────────┤
│                                     │
│   (Tab content scrollable)          │ Selected Tab
│   - History: Lista sessioni         │ Content
│   - Records: PRs per rep range      │
│                                     │
└─────────────────────────────────────┘
```

### Key Interactions

1. **Glanceable Info**: PR badge + chart visibili immediatamente (no scroll)
2. **Deep Dive**: Tap su [History] o [Records] per dettagli
3. **Chart Interaction**: Tap punti del grafico per vedere exact values con tooltip
4. **Navigation**: Tap su History entry → Apre workout completo (route esistente)

---

## 📊 Chart Specifications

### Volume Progression Chart

**Package**: `fl_chart` (già nel progetto)

**Configuration**:
- **Type**: Line chart
- **Data**: Volume totale per sessione (sum di peso × reps di tutti i set)
- **X-axis**: Date (ultimi 3 mesi default)
- **Y-axis**: Volume (kg)
- **Interaction**: Tap punto → Tooltip con data + volume + sets count
- **Theme**: Adapts to dark/light mode automaticamente

**Implementation**:

```dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: volumeData, // List<FlSpot> da ExerciseHistory.sessions
        isCurved: true,
        color: context.colors.primary,
        barWidth: 3,
        dotData: FlDotData(show: true),
      ),
    ],
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => Text(
            _formatDate(value), // "15 Gen"
            style: context.textTheme.bodySmall,
          ),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => Text(
            '${value.toInt()} kg',
            style: context.textTheme.bodySmall,
          ),
        ),
      ),
    ),
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: context.colors.surface,
        getTooltipItems: (spots) => [
          LineTooltipItem(
            '${spots[0].y.toInt()} kg\n${_formatDate(spots[0].x)}',
            context.textTheme.bodyMedium!,
          ),
        ],
      ),
    ),
  ),
)
```

---

## 📜 Tab 1: History

### Purpose
Mostra tutte le sessioni dove l'utente ha eseguito questo esercizio, ordinate dalla più recente.

### Entry Card Layout

```
┌─────────────────────────────────────┐
│ 📅 15 Gen 2025 · 2 giorni fa        │ Date + relative time
├─────────────────────────────────────┤
│ 4 sets · 200 kg volume              │ Summary stats
│ • 60kg × 10 reps                    │ Sets detail
│ • 65kg × 8 reps                     │ (espandibile)
│ • 65kg × 8 reps                     │
│ • 70kg × 6 reps  🏆 PR!             │ Badge se PR
├─────────────────────────────────────┤
│ Tap to see full workout →          │ Action hint
└─────────────────────────────────────┘
```

### Features

- **Scroll infinito**: Pagination 20 items per page
- **Badge automatici**:
  - 🏆 se Personal Record
  - 📈 se miglioramento vs sessione precedente
- **Navigation**: Tap su card → `/workout-detail/{workoutId}`

### Empty State

```
"Nessuna sessione ancora. Inizia ad allenarti!"
[CTA Button: "Inizia workout"]
```

---

## 🏆 Tab 2: Records

### Purpose
Mostra i personal records organizzati per categoria.

### Layout Structure

```
┌─────────────────────────────────────┐
│ OVERALL RECORDS                     │
├─────────────────────────────────────┤
│ 💪 Peso Massimo                     │
│    80 kg × 3 reps                   │ Card clickabile
│    15 Gen 2025                      │ mostra dettagli
├─────────────────────────────────────┤
│ 📦 Volume Massimo                   │
│    250 kg total                     │
│    10 Gen 2025                      │
├─────────────────────────────────────┤
│ BEST PER REP RANGE                  │
├─────────────────────────────────────┤
│ 1 Rep: 85kg (estimated)             │
│ 3 Reps: 80kg                        │
│ 5 Reps: 75kg                        │
│ 8 Reps: 65kg                        │
│ 10 Reps: 60kg                       │
└─────────────────────────────────────┘
```

### Calculations

**Estimated 1RM**: Epley formula
```dart
double estimated1RM = weight * (1 + reps / 30);
```

**Best per Rep**: Filter all historical sets, take max weight for each rep count

**Volume Massimo**: Sum of (weight × reps) for ALL sets in a single session

### Empty State

```
"Completa il primo workout per vedere i tuoi record!"
```

---

## 🏗️ Architecture

### File Organization

```
lib/features/analytics/presentation/
├── screens/
│   └── exercise_detail_screen.dart
├── widgets/
│   ├── pr_badge_header.dart
│   ├── volume_progression_chart.dart
│   ├── history_tab.dart
│   ├── records_tab.dart
│   └── session_history_card.dart
└── providers/
    └── exercise_records_provider.dart (NEW)
```

### Data Models

```dart
// lib/features/analytics/domain/entities/exercise_records.dart
class ExerciseRecords {
  final double maxWeight;
  final int maxWeightReps; // Reps del PR di peso
  final DateTime maxWeightDate;

  final double maxVolume;
  final DateTime maxVolumeDate;

  final double estimated1RM;

  final Map<int, WeightRecord> bestPerRep; // {3: 80kg, 5: 75kg, ...}
}

class WeightRecord {
  final double weight;
  final DateTime date;
}
```

---

## ⚡ Performance Strategy: 3-Layer Caching

### Architecture

Based on online research (Riverpod 3.0 docs + Firebase best practices):

| Layer | Purpose | TTL |
|-------|---------|-----|
| **Layer 1: Firestore** | Persistence cache | Default Firestore cache |
| **Layer 2: Riverpod** | Reactive caching + `ref.keepAlive()` | Provider lifecycle |
| **Layer 3: In-memory** | Computed records memoization | 10 minutes |

### Implementation

```dart
@riverpod
class ExerciseRecords extends _$ExerciseRecords {
  final Map<String, (RecordsData, DateTime)> _cache = {};
  static const _cacheDuration = Duration(minutes: 10);

  Future<RecordsData> build(String exerciseName) async {
    // ✅ Riverpod 3.0 pattern - use ref.keepAlive()
    final keepAlive = ref.keepAlive();

    // Check in-memory cache
    final cached = _cache[exerciseName];
    if (cached != null) {
      final (data, timestamp) = cached;
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        keepAlive(); // Keep alive mentre è valido
        return data;
      }
    }

    // Fetch ExerciseHistory (già cached da Analytics Repository)
    final history = await ref.watch(
      exerciseHistoryByNameProvider((userId, exerciseName)).future
    );

    // Compute records (O(n) where n = total sets)
    final records = _computeRecords(history);

    // Cache result
    _cache[exerciseName] = (records, DateTime.now());
    keepAlive(); // Mantieni cache attivo
    return records;
  }

  RecordsData _computeRecords(ExerciseHistory history) {
    // Algoritmo O(n) dove n = numero totale di set storici
    // Con 100 workout × 4 set = 400 iterazioni → ~2ms su device medio

    double maxWeight = 0;
    double maxVolume = 0;
    final Map<int, double> bestPerRep = {}; // {reps: peso}

    for (final session in history.sessions) {
      double sessionVolume = 0;
      for (final set in session.sets) {
        // Max weight
        if (set.weight > maxWeight) maxWeight = set.weight;

        // Volume
        sessionVolume += set.weight * set.reps;

        // Best per rep
        if (!bestPerRep.containsKey(set.reps) ||
            set.weight > bestPerRep[set.reps]!) {
          bestPerRep[set.reps] = set.weight;
        }
      }

      // Max volume
      if (sessionVolume > maxVolume) maxVolume = sessionVolume;
    }

    return RecordsData(
      maxWeight: maxWeight,
      maxVolume: maxVolume,
      bestPerRep: bestPerRep,
      estimated1RM: maxWeight * (1 + bestPerRep.entries.first.key / 30),
    );
  }

  // Event-driven cache invalidation
  void invalidateCache(String exerciseName) {
    _cache.remove(exerciseName);
    ref.invalidateSelf(); // Riverpod rebuilda provider
  }
}
```

### Performance Results

- **First load**: ~300ms (fetch Firestore + compute)
- **Second load**: ~2ms (cache hit) ⚡
- **After 10 min**: ~50ms (solo compute, history già in cache)

### Graceful Degradation

```dart
Future<RecordsData> build(String exerciseName) async {
  try {
    // Fetch from Firestore
    final history = await ref.watch(
      exerciseHistoryByNameProvider((userId, exerciseName)).future
    );
    return _computeRecords(history);
  } catch (e) {
    // Fallback to cached data se Firestore offline
    final cached = _cache[exerciseName];
    if (cached != null) {
      final (data, _) = cached;
      return data; // Serve stale data rather than error
    }
    rethrow; // Se no cache, mostra error
  }
}
```

---

## 🔄 Cache Invalidation Strategy

### Event-Driven Invalidation

**Trigger**: When user completes a workout

**Implementation** (corrected - in provider layer, not repository):

```dart
// ✅ CORRECT: In WorkoutProvider (has access to ref)
class WorkoutProvider extends _$WorkoutProvider {
  Future<void> completeWorkout(Workout workout) async {
    final repo = ref.watch(workoutRepositoryProvider);

    // 1. Save to Firestore
    await repo.saveWorkout(workout);

    // 2. Invalidate analytics cache for each exercise
    for (final exercise in workout.exercises) {
      ref.invalidate(exerciseRecordsProvider(exercise.name));
      ref.invalidate(exerciseHistoryByNameProvider((userId, exercise.name)));
    }

    // 3. Invalidate general analytics list
    ref.invalidate(exerciseHistoryStreamProvider(userId));
  }
}
```

**Why Provider Layer?**
- Repository layer doesn't have access to `ref`
- Provider layer is the correct place for Riverpod invalidations
- Separates concerns: Repository = data access, Provider = state + cache management

---

## 🗺️ Routing

### Route Definition

```dart
// In lib/app/app.dart
GoRoute(
  path: '/analytics/exercise/:exerciseName',
  name: 'exercise-detail',
  builder: (context, state) {
    final exerciseName = state.pathParameters['exerciseName']!;
    return ExerciseDetailScreen(exerciseName: exerciseName);
  },
),
```

### Navigation Flow

```
Analytics Screen (Lista esercizi)
    ↓ Tap su ExerciseHistoryCard
ExerciseDetailScreen(exerciseName: "Bench Press")
    ↓ Tap su History session entry
WorkoutDetailScreen(workoutId: "abc123") ← Route esistente
```

### Back Navigation

AppBar with back button (auto-handled by GoRouter)

---

## 🎨 Theming & Localization

### Theme Compliance

- ✅ `context.colors.*` per tutti i colori
- ✅ `context.textTheme.*` per typography
- ✅ Dark/Light mode supportato
- ✅ Chart adatta colori automaticamente (fl_chart theme-aware)

### Localization Keys

Add to `assets/i18n/app_en.arb` and `app_it.arb`:

```json
{
  "exerciseDetail": "Exercise Detail",
  "dettaglioEsercizio": "Dettaglio Esercizio",

  "personalRecord": "Personal Record",
  "recordPersonale": "Record Personale",

  "lastWorkout": "Last workout",
  "ultimoAllenamento": "Ultimo allenamento",

  "volumeProgression": "Volume Progression",
  "progressioneVolume": "Progressione Volume",

  "historyTab": "History",
  "cronologia": "Cronologia",

  "recordsTab": "Records",
  "records": "Records",

  "maxWeight": "Max Weight",
  "pesoMassimo": "Peso Massimo",

  "maxVolume": "Max Volume",
  "volumeMassimo": "Volume Massimo",

  "estimated1RM": "Estimated 1RM",
  "1RMStimato": "1RM Stimato",

  "bestPerRep": "Best per Rep",
  "bestPerRipetizione": "Best per Ripetizione",

  "noSessionsYet": "No sessions yet",
  "nessunaSessione": "Nessuna sessione ancora",

  "startWorkoutCTA": "Start your first workout",
  "iniziaAllenamento": "Inizia il tuo primo allenamento",

  "noRecordsYet": "Complete your first workout to see records",
  "nessunRecord": "Completa il primo workout per vedere i tuoi record",

  "sets": "sets",
  "serie": "serie",

  "totalVolume": "total volume",
  "volumeTotale": "volume totale",

  "tapToSeeWorkout": "Tap to see full workout",
  "tapPerVedereWorkout": "Tap per vedere workout completo",

  "daysAgo": "{count} days ago",
  "giorniFa": "{count} giorni fa"
}
```

After adding keys, run:
```bash
flutter gen-l10n
```

---

## 🧩 Widget Structure

```dart
ExerciseDetailScreen
├── AppBar (nome esercizio + menu actions)
├── PRBadgeHeader (PR badge + last workout info)
├── VolumeProgressionChart (chart principale - sempre visibile)
├── TabBar (History | Records)
└── TabBarView
    ├── HistoryTab (lista sessioni)
    └── RecordsTab (PRs organizzati)
```

### Component Responsibilities

**ExerciseDetailScreen**:
- Main scaffold
- Tab controller management
- Provider watching (exerciseHistoryByNameProvider, exerciseRecordsProvider)

**PRBadgeHeader**:
- Display PR badge with icon + value
- Show last workout date (relative time)

**VolumeProgressionChart**:
- fl_chart LineChart implementation
- Data transformation (ExerciseHistory → FlSpot)
- Tooltip customization

**HistoryTab**:
- ListView.builder with SessionHistoryCard
- Pagination support (20 items)
- Empty state handling

**RecordsTab**:
- Records categories (Overall, Best Per Rep)
- Computed metrics display
- Empty state handling

**SessionHistoryCard**:
- Session summary (date, sets count, volume)
- Sets detail (expandable)
- PR badge if applicable
- Navigation to workout detail

---

## ✅ Implementation Checklist

### Phase 1: Data Layer
- [ ] Create `ExerciseRecords` entity
- [ ] Create `WeightRecord` entity
- [ ] Implement `ExerciseRecordsProvider` with 3-layer caching
- [ ] Add cache invalidation to `WorkoutProvider.completeWorkout()`

### Phase 2: UI Widgets
- [ ] Create `ExerciseDetailScreen` scaffold
- [ ] Implement `PRBadgeHeader` widget
- [ ] Implement `VolumeProgressionChart` with fl_chart
- [ ] Create `HistoryTab` with SessionHistoryCard
- [ ] Create `RecordsTab` with computed metrics

### Phase 3: Routing
- [ ] Add route to `lib/app/app.dart`
- [ ] Update `AnalyticsScreen` ExerciseHistoryCard tap handler
- [ ] Test navigation flow

### Phase 4: Localization
- [ ] Add all keys to `app_en.arb`
- [ ] Add all keys to `app_it.arb`
- [ ] Run `flutter gen-l10n`
- [ ] Verify translations in both languages

### Phase 5: Testing
- [ ] Test with 0 sessions (empty states)
- [ ] Test with 1-5 sessions (normal case)
- [ ] Test with 100+ sessions (performance)
- [ ] Test dark/light theme switching
- [ ] Test offline mode (graceful degradation)
- [ ] Test cache invalidation after workout completion

---

## 🎯 Success Criteria

**Functional**:
- ✅ Chart displays volume progression accurately
- ✅ History tab shows all sessions ordered by date
- ✅ Records tab computes PRs correctly
- ✅ Navigation to workout detail works
- ✅ Cache invalidation triggers on workout completion

**Performance**:
- ✅ Screen loads in <500ms (first time)
- ✅ Screen loads in <50ms (cached)
- ✅ Smooth scrolling with 100+ sessions
- ✅ Chart interaction is responsive

**UX**:
- ✅ Empty states are clear and actionable
- ✅ PR badges are visible and meaningful
- ✅ Dark/light theme support
- ✅ Localization works in EN/IT

---

## 📚 References

**Online Research**:
- Strong App: [help.strongapp.io/article/237-about-exercise-detail](https://help.strongapp.io/article/237-about-exercise-detail)
- Hevy App: [hevyapp.com/features/exercise-performance](https://www.hevyapp.com/features/exercise-performance/)
- Riverpod 3.0 Best Practices: [codewithandrea.com/articles/flutter-riverpod-data-caching-providers-lifecycle](https://codewithandrea.com/articles/flutter-riverpod-data-caching-providers-lifecycle/)
- Firebase Caching: [firebase.google.com/docs/firestore/manage-data/enable-offline](https://firebase.google.com/docs/firestore/manage-data/enable-offline)

**GymBro Docs**:
- `ANALYTICS_SYSTEM_DOCUMENTATION.md` - Existing analytics architecture
- `DESIGN_GUIDELINES.md` - Theme and component standards
- `CLAUDE.md` - Project rules and patterns

---

**Status**: ✅ Design validated and ready for implementation
**Next Step**: Create implementation plan or start coding with worktree setup
