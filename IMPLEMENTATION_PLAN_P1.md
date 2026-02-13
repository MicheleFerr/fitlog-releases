# Piano di Implementazione Tecnico - Task P1 Rimanenti

## Executive Summary

**Obiettivo**: Completare i task P1 per migliorare UX della sezione Statistiche
**Status P0**: ✅ Tutti completati (Correlazioni, +0% Messages, WeeklySummaryBanner)
**Tasks P1 Rimanenti**: 5 task (P1.2, P1.3, P1.4, P1.5, P1.6)
**Effort Totale**: ~650 righe di codice
**Tempo Stimato**: 2-3 sessioni

---

## Batch 1: Quick Wins (P1.4, P1.5) - Effort: Basso

### Task 1.1: P1.4 - Delta nelle Summary Cards

**File**: `lib/features/analytics/presentation/analytics_screen.dart`
**Righe**: ~120 righe modificate/aggiunte
**Componente Target**: `_QuickStatsSummary` (linea 467+)

**Implementazione**:

1. **Aggiungere calcolo delta per ogni card**:
   - `_calculateStreakDelta()` - Streak vs settimana scorsa
   - `_calculateVolumeDelta()` - Volume vs settimana scorsa
   - `_calculateWeeklyDelta()` - Workout count vs settimana scorsa
   - `_calculatePRDelta()` - PR count vs settimana scorsa

2. **Modificare ogni StatCard per mostrare delta**:
   ```dart
   // Formato target:
   // [Icon] Valore
   //        +X% ↑ vs settimana scorsa
   ```

3. **Usare colori semantici**:
   - `context.colors.success` per delta positivo
   - `context.colors.warning` per delta negativo
   - `context.colors.onSurfaceVariant` per delta = 0

4. **Aggiungere icone direzionali**:
   - `AppIcons.trendUp` per > 0
   - `AppIcons.trendFlat` per = 0
   - `AppIcons.trendDown` per < 0

**Nuove l10n keys** (8 keys):
- `analyticsStreakDelta`
- `analyticsVolumeDelta`
- `analyticsWeeklyDelta`
- `analyticsPRDelta`
- `analyticsVsPreviousWeek`
- `analyticsNoChange`
- `analyticsFirstWeek`
- `analyticsNoDataYet`

**Verifica**:
```bash
flutter analyze
# Check: No errors, delta shows correctly on cards
```

---

### Task 1.2: P1.5 - Tooltip Educativi su Metriche

**File Nuovi**:
- `lib/features/analytics/presentation/widgets/metric_tooltip_button.dart` (~80 righe)
- `lib/features/analytics/presentation/widgets/metric_explanation_sheet.dart` (~150 righe)

**File Modificati**:
- `lib/features/analytics/presentation/screens/exercise_detail_screen.dart` (aggiungi tooltip su RPE, 1RM, Volume)

**Implementazione**:

1. **Creare `MetricTooltipButton` widget**:
   ```dart
   class MetricTooltipButton extends StatelessWidget {
     final String metricKey; // 'rpe', '1rm', 'volume', etc.
     // Mostra icona "?" che apre MetricExplanationSheet
   }
   ```

2. **Creare `MetricExplanationSheet` bottom sheet**:
   ```dart
   class MetricExplanationSheet extends StatelessWidget {
     final String metricKey;
     // Mostra:
     // - Titolo metrica in italiano semplice
     // - Spiegazione 2-3 frasi
     // - Esempio pratico con numeri
     // - "Perché è importante per te"
   }
   ```

3. **Definire spiegazioni in l10n** (per ogni metrica):
   - RPE (Rate of Perceived Exertion)
   - 1RM (One-Rep Max)
   - Volume (peso × reps × sets)
   - Tonnage
   - Frequency

4. **Aggiungere tooltip a**:
   - Stats box in `exercise_detail_screen.dart` (4 metriche: PR, Peso Medio, Reps, RPE)
   - Correlations sheet (r, r²)
   - Pro Insights badge

**Nuove l10n keys** (20+ keys):
- Titoli: `metricRpeTitle`, `metric1rmTitle`, `metricVolumeTitle`, etc.
- Descrizioni: `metricRpeDescription`, `metric1rmDescription`, etc.
- Esempi: `metricRpeExample`, `metric1rmExample`, etc.
- Why: `metricRpeWhy`, `metric1rmWhy`, etc.

**Verifica**:
```bash
flutter analyze
# Tap "?" icon → sheet opens with clear explanation
```

---

## Batch 2: Medium Tasks (P1.6, P1.3) - Effort: Medio

### Task 2.1: P1.6 - Empty States Motivanti

**File Modificati**:
- `lib/features/analytics/presentation/analytics_screen.dart` (sostituisci `_EmptyStateView`)
- `lib/features/analytics/presentation/screens/exercise_detail_screen.dart` (aggiungi empty per grafici)
- `lib/features/analytics/presentation/widgets/exercise_correlations_sheet.dart` (già fatto parzialmente)

**Implementazione**:

1. **Sostituire `_EmptyStateView` in analytics_screen.dart**:
   ```dart
   // OLD: class _EmptyStateView
   // NEW: Usa EnhancedEmptyState con:
   EnhancedEmptyState(
     type: EmptyStateType.motivational,
     icon: AppIcons.barChart,
     title: context.l10n.analyticsEmptyTitle,
     description: context.l10n.analyticsEmptyDescription,
     motivationalQuote: context.l10n.analyticsEmptyQuote,
     proTip: context.l10n.analyticsEmptyTip,
     primaryActionLabel: context.l10n.startWorkout,
     onPrimaryAction: () => context.go(AppRoutes.workoutCreate),
   )
   ```

2. **Aggiungere empty states per grafici in exercise_detail_screen.dart**:
   - Quando < 3 sessioni: "Il tuo grafico apparirà qui"
   - Progress bar: "█████░░░ 2/3 allenamenti"
   - CTA: "Completa ancora 1 sessione per vedere il trend"

3. **Aggiungere empty per lista esercizi filtrata**:
   - Quando search non trova risultati
   - Quando filtro "Preferiti" è vuoto

**Scenari Empty State**:
| Scenario | Icon | Tipo | Messaggio |
|----------|------|------|-----------|
| Nessun allenamento | `barChart` | motivational | "Inizia ad allenarti per vedere i tuoi progressi!" |
| Ricerca vuota | `search` | info | "Nessun esercizio trovato per '{query}'" |
| Nessun preferito | `starOutline` | info | "Non hai ancora esercizi preferiti. Tocca la stella per aggiungerli!" |
| Dati insufficienti grafico | `chartLine` | info | "Completa ancora X sessioni per vedere il trend" |

**Nuove l10n keys** (12 keys):
- Empty titles/descriptions per ogni scenario
- Motivational quotes
- Pro tips

**Verifica**:
```bash
flutter analyze
# Check empty states show correctly in ogni scenario
```

---

### Task 2.2: P1.3 - Sparklines nella Lista Esercizi

**File Nuovi**:
- `lib/features/analytics/presentation/widgets/mini_sparkline.dart` (~100 righe)

**File Modificati**:
- `lib/features/analytics/presentation/analytics_screen.dart` (widget `_ExerciseHistoryCard`)

**Implementazione**:

1. **Creare `MiniSparkline` widget**:
   ```dart
   class MiniSparkline extends StatelessWidget {
     final List<double> dataPoints; // Ultime 8-12 sessioni
     final bool isPositiveTrend;
     final double width;
     final double height;

     // Disegna mini line chart con CustomPaint
     // Colori:
     // - Verde se trend positivo
     // - Arancio se trend negativo
     // - Grigio se stabile
   }
   ```

2. **Modificare `_ExerciseHistoryCard` per includere sparkline**:
   ```dart
   Row(
     children: [
       ExerciseAvatar(...),
       Expanded(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(exerciseName),
             Text(muscleGroup),
           ],
         ),
       ),
       // NUOVO: Sparkline
       MiniSparkline(
         dataPoints: _extractWeightProgression(history),
         isPositiveTrend: history.weeklyProgression > 0,
         width: 60,
         height: 24,
       ),
       SizedBox(width: 8),
       // Peso corrente + trend %
       Column(...),
     ],
   )
   ```

3. **Estrarre dati per sparkline** (funzione helper):
   ```dart
   List<double> _extractWeightProgression(ExerciseHistory history) {
     // Prendi ultime 12 sessioni
     // Estrai peso medio per sessione
     // Normalizza per grafico (0-1 range)
   }
   ```

**Design sparkline**:
- Width: 60px
- Height: 24px
- Line width: 1.5px
- Gradient fill sotto la linea (opzionale)
- Smooth curve (catmull-rom spline)

**Verifica**:
```bash
flutter analyze
# Check sparklines render correctly nella lista
# Check trend positivo/negativo ha colore giusto
```

---

## Batch 3: Complex Task (P1.2) - Effort: Medio-Alto

### Task 3.1: P1.2 - Progressive Disclosure a 2 Livelli

**File Modificati**:
- `lib/features/analytics/presentation/analytics_screen.dart` (main screen)
- `lib/features/analytics/presentation/screens/exercise_detail_screen.dart` (detail screen)

**Nuovi Provider**:
- `lib/features/analytics/presentation/providers/analytics_view_mode_provider.dart` (~30 righe)

**Implementazione**:

1. **Creare provider per view mode**:
   ```dart
   enum AnalyticsViewMode { simple, detailed }

   final analyticsViewModeProvider = StateProvider<AnalyticsViewMode>(
     (ref) => AnalyticsViewMode.simple, // Default
   );
   ```

2. **Aggiungere toggle in AppBar di analytics_screen.dart**:
   ```dart
   actions: [
     Consumer(
       builder: (context, ref, _) {
         final viewMode = ref.watch(analyticsViewModeProvider);
         return IconButton(
           icon: Icon(
             viewMode == AnalyticsViewMode.simple
                 ? AppIcons.viewDetailed
                 : AppIcons.viewSimple,
           ),
           onPressed: () {
             final newMode = viewMode == AnalyticsViewMode.simple
                 ? AnalyticsViewMode.detailed
                 : AnalyticsViewMode.simple;
             ref.read(analyticsViewModeProvider.notifier).state = newMode;
             HapticFeedback.lightImpact();
           },
         );
       },
     ),
     SearchButton(...),
   ]
   ```

3. **Nascondere/mostrare elementi basati su view mode**:

   **Vista Semplice (default)**:
   - ✅ WeeklySummaryBanner
   - ✅ _QuickStatsSummary (4 cards)
   - ✅ Lista esercizi con sparkline
   - ❌ Pro Insights badge (nascosto)
   - ❌ Filtri avanzati (nascosti)

   **Vista Dettagliata**:
   - ✅ Tutto della vista semplice
   - ✅ Pro Insights badge espanso
   - ✅ Filtri avanzati (mostrati)
   - ✅ Correlazioni nella detail screen

4. **Modificare sezioni per rispettare view mode**:
   ```dart
   final viewMode = ref.watch(analyticsViewModeProvider);

   if (viewMode == AnalyticsViewMode.detailed) {
     // Mostra Pro Insights badge
   }
   ```

5. **Salvare preferenza utente** (persistente):
   - Usare `SharedPreferences` o Hive
   - Chiave: `'analytics_view_mode'`
   - Default: `'simple'`

**Nuove l10n keys** (4 keys):
- `analyticsViewSimple`
- `analyticsViewDetailed`
- `analyticsSwitchToSimple`
- `analyticsSwitchToDetailed`

**Verifica**:
```bash
flutter analyze
# Toggle simple/detailed → UI aggiorna correttamente
# Preferenza persiste tra sessioni
```

---

## Sequenza di Esecuzione

### Batch 1 (Quick Wins):
1. Task 1.1: Delta Cards (~1h)
2. Task 1.2: Tooltip (~1h)
3. **Verifica Batch 1**: `flutter analyze`, test manuale

### Batch 2 (Medium):
1. Task 2.1: Empty States (~1h)
2. Task 2.2: Sparklines (~1.5h)
3. **Verifica Batch 2**: `flutter analyze`, test grafico

### Batch 3 (Complex):
1. Task 3.1: Progressive Disclosure (~2h)
2. **Verifica Batch 3**: `flutter analyze`, test toggle

### Final Phase:
1. Run comprehensive tests
2. Verify all l10n keys
3. Check performance
4. Create commit
5. Done! ✅

---

## Verifica Finale Completa

```bash
# 1. Analyze
flutter analyze

# 2. Test compilation
flutter build apk --debug

# 3. L10n generation
flutter gen-l10n

# 4. Performance check
.claude/scripts/performance-check.sh lib/features/analytics/

# 5. Git status
git status
git diff --stat
```

**Success Criteria**:
- ✅ All P1 tasks implemented
- ✅ 0 errors, 0 warnings from `flutter analyze`
- ✅ All l10n keys present in EN + IT
- ✅ No performance regressions
- ✅ Follows FitLog patterns (AppIcons, context.l10n, context.colors)
- ✅ All personas benefit (verified via testing)

---

## L10n Keys Summary

**Total New Keys**: ~48 keys (24 EN + 24 IT)

**Breakdown**:
- Delta cards: 8 keys
- Tooltip: 20 keys
- Empty states: 12 keys
- Sparklines: 2 keys
- Progressive disclosure: 4 keys
- Misc: 2 keys

**Files to Update**:
- `assets/i18n/app_en.arb`
- `assets/i18n/app_it.arb`

---

## Dependencies Check

**Required packages** (already in pubspec.yaml):
- ✅ `flutter_riverpod` - state management
- ✅ `go_router` - navigation
- ✅ `shared_preferences` - persistence (for view mode)

**No new dependencies needed** ✅

---

*Piano generato il 2026-02-13 per completamento autonomo task P1.*
