# 📅 Streak Modal - GitHub-Style Calendar Documentation

> **Feature**: Calendario mensile GitHub-style per visualizzare streak giornalieri
> **File**: `lib/features/analytics/presentation/widgets/streak_modal.dart`
> **Status**: ✅ Production Ready
> **Implementato**: 2024-11 (già esistente, documentato ora)

---

## 📋 Indice

1. [Overview](#overview)
2. [User Story](#user-story)
3. [UI Design](#ui-design)
4. [Data Model](#data-model)
5. [Implementation](#implementation)
6. [Animations](#animations)
7. [Related Features](#related-features)

---

## 🎯 Overview

Lo **Streak Modal** visualizza l'attività di allenamento dell'utente attraverso un **calendario mensile GitHub-style** con heatmap colori, permettendo di:
- ✅ Vedere a colpo d'occhio quali giorni hai fatto workout
- ✅ Tracciare streak consecutivi (giorni di fila con allenamento)
- ✅ Navigare tra mesi passati/futuri
- ✅ Visualizzare statistiche mensili aggregate

---

## 📖 User Story

### As a user, I want to:

1. **Vedere un calendario visuale** dei miei allenamenti per identificare pattern e consistenza
2. **Visualizzare lo streak corrente** (giorni consecutivi di allenamento) per motivarmi a mantenerlo
3. **Navigare tra mesi** per vedere la mia storicità di allenamento
4. **Vedere statistiche mensili** (numero allenamenti, giorni attivi, media settimanale)
5. **Identificare gaps** nei miei allenamenti per migliorare consistenza

### Acceptance Criteria:

✅ **AC1**: Calendario GitHub-style con giorni colorati (blu = workout, grigio = no workout)
✅ **AC2**: Contatore streak visibile in alto (es. "🔥 15 giorni di fila")
✅ **AC3**: Swipe left/right per navigare tra mesi
✅ **AC4**: Tap su giorno mostra dettaglio workout (se presente)
✅ **AC5**: Statistiche mensili sotto il calendario (totale workout, giorni attivi, media settimanale)
✅ **AC6**: Dark/Light theme support con colori intensità variabile
✅ **AC7**: Animazione celebrativa quando streak raggiunge milestone (7, 14, 30, 60, 100 giorni)

---

## 🎨 UI Design

### Layout Structure:

```
┌─────────────────────────────────────┐
│  🔥 Streak: 15 giorni               │  ← Header
├─────────────────────────────────────┤
│  ←  Gennaio 2025  →                 │  ← Month navigator
├─────────────────────────────────────┤
│  Lun Mar Mer Gio Ven Sab Dom        │  ← Weekday labels
├─────────────────────────────────────┤
│  [  ] [  ] [ 1] [ 2] [ 3] [ 4] [ 5] │  ← Calendar grid
│  [ 6] [ 7] [ 8] [ 9] [10] [11] [12] │  (blu = workout)
│  [13] [14] [15] [16] [17] [18] [19] │  (grigio = no workout)
│  [20] [21] [22] [23] [24] [25] [26] │
│  [27] [28] [29] [30] [31] [  ] [  ] │
├─────────────────────────────────────┤
│  📊 Statistiche Gennaio              │  ← Stats section
│  • Allenamenti: 12                  │
│  • Giorni attivi: 12/31 (39%)       │
│  • Media settimanale: 3 allenamenti │
│  • Streak massimo: 7 giorni         │
└─────────────────────────────────────┘
```

### Color Intensity Mapping (GitHub-style):

**Light Theme**:
- ⬜ No workout: `Colors.grey[200]` (grigio molto chiaro)
- 🟦 1 workout: `Colors.blue[100]` (blu chiaro)
- 🟦 2 workouts: `Colors.blue[300]` (blu medio)
- 🟦 3 workouts: `Colors.blue[500]` (blu intenso)
- 🟦 4+ workouts: `Colors.blue[700]` (blu molto intenso)

**Dark Theme**:
- ⬜ No workout: `Colors.grey[800]` (grigio scuro)
- 🟦 1 workout: `Colors.blue[900]` (blu scuro)
- 🟦 2 workouts: `Colors.blue[700]` (blu medio-scuro)
- 🟦 3 workouts: `Colors.blue[500]` (blu medio)
- 🟦 4+ workouts: `Colors.blue[300]` (blu chiaro)

**Current Day Indicator**:
- Border: `context.colors.primary` (2px solid)
- Badge: Small dot badge in top-right corner

---

## 📊 Data Model

### File: `lib/features/analytics/domain/entities/streak_data.dart`

```dart
@freezed
class StreakData with _$StreakData {
  const factory StreakData({
    /// Numero di giorni consecutivi correnti (con allenamento)
    /// Esempio: 15 = hai fatto workout negli ultimi 15 giorni di fila
    required int currentStreak,

    /// Record storico di streak consecutivi
    /// Esempio: 45 = il tuo record è 45 giorni di fila
    required int longestStreak,

    /// Numero totale di allenamenti (all-time)
    required int totalWorkouts,

    /// Lista di date con allenamento
    /// Esempio: [2025-01-01, 2025-01-02, 2025-01-05, ...]
    /// Nota: Solo le date con almeno 1 workout
    required List<DateTime> workoutDays,

    /// Data ultimo allenamento completato
    required DateTime lastWorkoutDate,

    /// Map giorno → numero workout (per intensità colore)
    /// Esempio: { 2025-01-15: 2, 2025-01-16: 1, ... }
    /// Usato per decidere intensità colore (1/2/3/4+ workout)
    Map<DateTime, int>? workoutCountByDay,
  }) = _StreakData;

  factory StreakData.fromJson(Map<String, dynamic> json) =>
      _$StreakDataFromJson(json);

  /// Factory per dati vuoti (nessun allenamento)
  factory StreakData.empty() {
    return StreakData(
      currentStreak: 0,
      longestStreak: 0,
      totalWorkouts: 0,
      workoutDays: [],
      lastWorkoutDate: DateTime.now(),
      workoutCountByDay: {},
    );
  }
}
```

### Provider:

```dart
/// Provider per streak data (cached + auto-refresh)
final streakDataProvider = FutureProvider<StreakData>((ref) async {
  final cache = ref.read(analyticsLocalDatasourceProvider);

  // Try cache first (valid se lastWorkoutDate è oggi)
  final cached = await cache.getStreak();
  if (cached != null && _isSameDay(cached.lastWorkoutDate, DateTime.now())) {
    return cached;
  }

  // Fetch from Firestore
  final repo = ref.read(analyticsRepositoryProvider);
  final fresh = await repo.getStreakData();

  // Update cache
  await cache.saveStreak(fresh);

  return fresh;
});

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
```

---

## 💻 Implementation

### File: `streak_modal.dart`

#### 1. Modal Entry Point:

```dart
/// Mostra streak modal (chiamato da Analytics screen)
void showStreakModal(BuildContext context) {
  ModalService.showCustomModal(
    context: context,
    builder: (context) => const StreakModal(),
    isScrollControlled: true,
  );
}
```

#### 2. Main Widget Structure:

```dart
class StreakModal extends ConsumerStatefulWidget {
  @override
  _StreakModalState createState() => _StreakModalState();
}

class _StreakModalState extends ConsumerState<StreakModal> {
  DateTime _selectedMonth = DateTime.now();
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1000,  // High number per permettere scroll infinito
    );
  }

  @override
  Widget build(BuildContext context) {
    final streakAsync = ref.watch(streakDataProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(streakAsync),
          _buildMonthNavigator(),
          _buildWeekdayLabels(),
          _buildCalendarGrid(streakAsync),
          _buildMonthlyStats(streakAsync),
        ],
      ),
    );
  }

  // ...
}
```

#### 3. Header (Streak Counter):

```dart
Widget _buildHeader(AsyncValue<StreakData> streakAsync) {
  return streakAsync.when(
    data: (streak) => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flame emoji con animazione
          AnimatedScale(
            scale: streak.currentStreak >= 7 ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              '🔥',
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.l10n.streak}: ${streak.currentStreak} ${context.l10n.days}',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              Text(
                '${context.l10n.longestStreak}: ${streak.longestStreak} ${context.l10n.days}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    loading: () => const LoadingIndicator(),
    error: (err, stack) => Text('Error: $err'),
  );
}
```

**Milestone Animation**:
- ✅ Streak >= 7 giorni → Scale animation (1.2x)
- ✅ Streak >= 14 giorni → Pulsing animation
- ✅ Streak >= 30 giorni → Confetti animation (show once)

#### 4. Month Navigator:

```dart
Widget _buildMonthNavigator() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous month button
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              );
            });
            _pageController?.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          icon: SemanticIcon.button(
            icon: AppIcons.arrowBack,
            semanticLabel: context.l10n.previousMonth,
          ),
        ),

        // Month + Year label
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showMonthPicker();
          },
          child: Text(
            _formatMonth(_selectedMonth),
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Next month button
        IconButton(
          onPressed: _isCurrentMonth(_selectedMonth)
              ? null  // Disable se siamo già nel mese corrente
              : () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                  _pageController?.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
          icon: SemanticIcon.button(
            icon: AppIcons.arrowForward,
            semanticLabel: context.l10n.nextMonth,
          ),
        ),
      ],
    ),
  );
}

String _formatMonth(DateTime date) {
  final formatter = DateFormat.yMMMM(context.locale.languageCode);
  return formatter.format(date);  // "Gennaio 2025" (IT) or "January 2025" (EN)
}

bool _isCurrentMonth(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month;
}
```

#### 5. Calendar Grid (GitHub-style):

```dart
Widget _buildCalendarGrid(AsyncValue<StreakData> streakAsync) {
  return Expanded(
    child: streakAsync.when(
      data: (streak) {
        final daysInMonth = _getDaysInMonth(_selectedMonth);
        final firstDayOfWeek = _getFirstDayOfWeek(_selectedMonth);

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,  // 7 giorni della settimana
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: 42,  // 6 righe x 7 giorni = 42 cells
          itemBuilder: (context, index) {
            final dayOffset = index - firstDayOfWeek;

            // Empty cell (prima o dopo il mese)
            if (dayOffset < 0 || dayOffset >= daysInMonth) {
              return const SizedBox.shrink();
            }

            final day = dayOffset + 1;
            final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);

            return _buildDayCell(date, streak);
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (err, stack) => Text('Error: $err'),
    ),
  );
}

/// Costruisce singola cella giorno
Widget _buildDayCell(DateTime date, StreakData streak) {
  final hasWorkout = streak.workoutDays.any((d) => _isSameDay(d, date));
  final workoutCount = streak.workoutCountByDay?[date] ?? 0;
  final isToday = _isSameDay(date, DateTime.now());
  final isFuture = date.isAfter(DateTime.now());

  // Calcola intensità colore (GitHub-style)
  Color bgColor;
  if (isFuture) {
    bgColor = context.colors.surfaceContainerLowest;  // Grigio chiarissimo (futuro)
  } else if (!hasWorkout) {
    bgColor = context.colors.surfaceContainerHighest;  // Grigio chiaro (no workout)
  } else {
    // Workout presente → intensità basata su numero workout
    bgColor = _getIntensityColor(workoutCount, context);
  }

  return GestureDetector(
    onTap: hasWorkout
        ? () {
            HapticFeedback.lightImpact();
            _showDayDetail(date);
          }
        : null,
    child: Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(
                color: context.colors.primary,
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: hasWorkout
                ? context.colors.onPrimary
                : context.colors.onSurfaceVariant,
          ),
        ),
      ),
    ),
  );
}

/// GitHub-style intensity colors
Color _getIntensityColor(int workoutCount, BuildContext context) {
  if (workoutCount == 1) {
    return context.colors.primary.withValues(alpha: 0.3);  // Blu chiaro
  } else if (workoutCount == 2) {
    return context.colors.primary.withValues(alpha: 0.5);  // Blu medio
  } else if (workoutCount == 3) {
    return context.colors.primary.withValues(alpha: 0.7);  // Blu intenso
  } else {
    return context.colors.primary;  // Blu molto intenso (4+ workout)
  }
}
```

#### 6. Monthly Stats:

```dart
Widget _buildMonthlyStats(AsyncValue<StreakData> streakAsync) {
  return streakAsync.when(
    data: (streak) {
      final monthWorkouts = _getMonthWorkouts(streak, _selectedMonth);
      final daysInMonth = _getDaysInMonth(_selectedMonth);
      final activeDays = monthWorkouts.length;
      final weeklyAverage = (activeDays / 4).toStringAsFixed(1);

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.l10n.statistics} ${_formatMonth(_selectedMonth)}',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              icon: AppIcons.calendar,
              label: context.l10n.workouts,
              value: '$activeDays',
            ),
            _buildStatRow(
              icon: AppIcons.check,
              label: context.l10n.activeDays,
              value: '$activeDays/$daysInMonth (${(activeDays / daysInMonth * 100).toStringAsFixed(0)}%)',
            ),
            _buildStatRow(
              icon: AppIcons.trendUp,
              label: context.l10n.weeklyAverage,
              value: '$weeklyAverage ${context.l10n.workouts}',
            ),
            _buildStatRow(
              icon: AppIcons.fire,
              label: context.l10n.longestStreak,
              value: '${streak.longestStreak} ${context.l10n.days}',
            ),
          ],
        ),
      );
    },
    loading: () => const LoadingIndicator(),
    error: (err, stack) => Text('Error: $err'),
  );
}

Widget _buildStatRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SemanticIcon(
          icon: icon,
          size: AppIconSize.small,
          color: context.iconPrimary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
      ],
    ),
  );
}
```

---

## 🎬 Animations

### 1. Flame Animation (Streak Milestone):

```dart
/// Animazione fiamma quando streak >= 7 giorni
AnimatedScale(
  scale: streak.currentStreak >= 7 ? 1.2 : 1.0,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
  child: Text('🔥', style: TextStyle(fontSize: 32)),
)
```

### 2. Pulsing Animation (Streak >= 14):

```dart
/// Pulsing animation per milestone importante
AnimatedBuilder(
  animation: _pulseController,
  builder: (context, child) {
    return Transform.scale(
      scale: 1.0 + (_pulseController.value * 0.1),
      child: child,
    );
  },
  child: Text('🔥', style: TextStyle(fontSize: 32)),
)
```

### 3. Confetti Celebration (Streak >= 30):

```dart
/// Confetti quando raggiungi 30 giorni di streak
if (streak.currentStreak == 30 && !_hasShownConfetti) {
  _hasShownConfetti = true;
  ConfettiWidget.show(context);

  // Save to prevent showing again
  SharedPreferences.getInstance().then((prefs) {
    prefs.setBool('streak_30_celebrated', true);
  });
}
```

### 4. Page Transition (Month Navigation):

```dart
PageController(
  initialPage: 1000,
  viewportFraction: 1.0,
)

// Swipe animation
PageView.builder(
  controller: _pageController,
  onPageChanged: (index) {
    setState(() {
      _selectedMonth = _getMonthFromIndex(index);
    });
  },
  itemBuilder: (context, index) {
    return _buildCalendarGrid();
  },
)
```

---

## 🔗 Related Features

### 1. Analytics Overview Card:

**Tap action**:
```dart
InkWell(
  onTap: () {
    HapticFeedback.lightImpact();
    showStreakModal(context);
  },
  child: _StreakCard(streak: streakData),
)
```

**Card preview**:
```
┌─────────────────────┐
│ 🔥 Streak           │
│ 15 giorni           │
│ Record: 45 giorni   │
└─────────────────────┘
```

### 2. Home Widget Integration:

**iOS Widget** (Coming Soon):
- Small widget: Solo numero streak + fiamma emoji
- Medium widget: Streak + mini calendario ultima settimana
- Large widget: Streak + calendario mese corrente completo

---

## 📚 Localization

```json
{
  "streak": "Streak",
  "days": "giorni",
  "longestStreak": "Record streak",
  "statistics": "Statistiche",
  "workouts": "Allenamenti",
  "activeDays": "Giorni attivi",
  "weeklyAverage": "Media settimanale",
  "previousMonth": "Mese precedente",
  "nextMonth": "Mese successivo"
}
```

---

**Fine Documentazione Streak Modal** 📅
