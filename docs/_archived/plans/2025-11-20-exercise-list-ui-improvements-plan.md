# Exercise List UI/UX Improvements - Task Plan

**Generated**: 2025-11-20 17:56
**Source**: task-master.dev (WebFetch)
**Complexity Score**: HIGH
**Reason**: Multi-layer implementation (Domain + Data + Presentation) + 17 tasks + Market analysis integration + New design patterns (sparklines, swipe actions, advanced filters)
**Total Tasks**: 17
**Estimated Time**: ~11.1h
**Plan Version**: 1.1

**Context Snapshot**:
- Flutter Version: 3.35.4
- App Version: 1.0.0+49
- Key Packages: riverpod ^2.6.1, freezed ^2.5.2, fl_chart ^1.1.0, hive, firebase_core
- Target Platforms: iOS 14+, Android 8+
- Related PRs/Issues: None
- Parent Milestone: None

---

## 📋 Original Request

> Migliorare la visione degli esercizi nella schermata Analytics, specialmente l'organizzazione della lista (ordinamento, filtri). Basarsi sull'analisi di mercato 2025 delle fitness app leader (Strong, Hevy, JEFIT, FitNotes).

**Market Analysis Summary**:
- Equipment filter è standard in 80% delle top apps
- Inline visual progress (sparkline charts) è trend #1 nel 2025
- Swipe actions riducono tap-to-action del 30%
- Max 2-tap policy per azioni comuni (standard UX 2025)

---

## 🎯 Task Breakdown

### 1. Domain Layer

- [ ] **Task 1.1**: Extend ExerciseHistory Entity with Equipment Metadata
  - **Layer**: Domain
  - **Files**: `lib/features/analytics/domain/entities/exercise_history.dart`
  - **Dependencies**: None
  - **Est. Time**: 20 min
  - **Blocking**: Yes (blocks Task 1.2, 3.1)
  - **Verification**: Entity includes `equipmentType` field (enum: bodyweight, dumbbell, barbell, machine, cable). Freezed code generation succeeds without errors.
  - **Code Prompt**:
    ```dart
    // Add to ExerciseHistory entity
    enum EquipmentType {
      bodyweight,
      dumbbell,
      barbell,
      machine,
      cable,
      unknown, // fallback for legacy data
    }

    // Add field to @freezed class ExerciseHistory
    @Default(EquipmentType.unknown) EquipmentType equipmentType,
    ```

- [ ] **Task 1.2**: Create Equipment Filter Value Object
  - **Layer**: Domain
  - **Files**: `lib/features/analytics/domain/value_objects/equipment_filter.dart` (new)
  - **Dependencies**: Task 1.1
  - **Est. Time**: 25 min
  - **Blocking**: No
  - **Verification**: Enum supports all 6 equipment types + "All" option. Freezed generation succeeds. Value object is immutable.
  - **Code Prompt**:
    ```dart
    import 'package:freezed_annotation/freezed_annotation.dart';

    part 'equipment_filter.freezed.dart';

    /// Equipment filter value object
    /// Supports 7 options: All, Bodyweight, Dumbbell, Barbell, Machine, Cable
    @freezed
    class EquipmentFilter with _$EquipmentFilter {
      const factory EquipmentFilter({
        @Default(EquipmentFilterType.all) EquipmentFilterType selectedType,
      }) = _EquipmentFilter;
    }

    enum EquipmentFilterType {
      all,        // Show all exercises
      bodyweight, // Only bodyweight exercises
      dumbbell,   // Only dumbbell exercises
      barbell,    // Only barbell exercises
      machine,    // Only machine exercises
      cable,      // Only cable exercises
    }
    ```

---

### 2. Data Layer

- [ ] **Task 2.1**: Update ExerciseHistory Model with Equipment Mapping
  - **Layer**: Data
  - **Files**: `lib/features/analytics/data/models/exercise_history_model.dart`
  - **Dependencies**: Task 1.1, Task 1.2
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **Verification**: JSON deserialization includes equipment field. Hive adapter persists equipment type. Backward compatibility with legacy data (defaults to EquipmentType.unknown).
  - **Code Prompt**:
    ```dart
    // Add to ExerciseHistoryModel fromJson
    equipmentType: json['equipmentType'] != null
        ? EquipmentType.values.byName(json['equipmentType'])
        : EquipmentType.unknown, // fallback for legacy data

    // Add to toJson
    'equipmentType': equipmentType.name,

    // Update Hive TypeAdapter (if used)
    // Add field index for equipmentType
    ```

- [ ] **Task 2.2**: Add Last Workout Date to Repository
  - **Layer**: Data
  - **Files**: `lib/features/analytics/data/repositories/exercise_repository_impl.dart`
  - **Dependencies**: Task 2.1
  - **Est. Time**: 25 min
  - **Blocking**: No
  - **Verification**: Repository method `getLastWorkoutDate(exerciseId)` returns DateTime or null. Method is tested with mock data.
  - **Code Prompt**:
    ```dart
    /// Get last workout date for an exercise
    /// Returns null if no sessions exist
    DateTime? getLastWorkoutDate(String exerciseId) {
      final history = exerciseHistories.firstWhere(
        (h) => h.exerciseId == exerciseId,
        orElse: () => null,
      );

      if (history?.sessions.isEmpty ?? true) return null;

      return history!.sessions
          .map((s) => s.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }
    ```

---

### 3. Presentation Layer - Filter Logic

- [ ] **Task 3.1**: Create Equipment Filter Riverpod Provider
  - **Layer**: Presentation
  - **Files**: `lib/features/analytics/presentation/providers/equipment_filter_provider.dart` (new)
  - **Dependencies**: Task 1.2
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **Verification**: Provider toggles equipment filters. State persists on app restart (uses Hive or SharedPreferences). Provider watches work correctly in widgets.
  - **Code Prompt**:
    ```dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:gymbro_flutter_new/features/analytics/domain/value_objects/equipment_filter.dart';

    /// Equipment filter state provider
    /// Persists selection across app restarts
    final equipmentFilterProvider = StateNotifierProvider<EquipmentFilterNotifier, EquipmentFilterType>(
      (ref) => EquipmentFilterNotifier(),
    );

    class EquipmentFilterNotifier extends StateNotifier<EquipmentFilterType> {
      EquipmentFilterNotifier() : super(EquipmentFilterType.all) {
        _loadPersistedState();
      }

      void setFilter(EquipmentFilterType newFilter) {
        state = newFilter;
        _persistState(newFilter);
      }

      Future<void> _loadPersistedState() async {
        // Load from Hive/SharedPreferences
      }

      Future<void> _persistState(EquipmentFilterType filter) async {
        // Save to Hive/SharedPreferences
      }
    }
    ```

- [ ] **Task 3.2**: Create Muscle Group Filter Riverpod Provider
  - **Layer**: Presentation
  - **Files**: `lib/features/analytics/presentation/providers/muscle_group_filter_provider.dart` (new)
  - **Dependencies**: None
  - **Est. Time**: 25 min
  - **Blocking**: No
  - **Verification**: Provider supports multiple selections (Set<String>). State persists. Combines correctly with other filters.
  - **Code Prompt**:
    ```dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';

    /// Muscle group multi-select filter provider
    final muscleGroupFilterProvider = StateNotifierProvider<MuscleGroupFilterNotifier, Set<String>>(
      (ref) => MuscleGroupFilterNotifier(),
    );

    class MuscleGroupFilterNotifier extends StateNotifier<Set<String>> {
      MuscleGroupFilterNotifier() : super({}) {
        _loadPersistedState();
      }

      void toggleMuscleGroup(String muscleGroup) {
        if (state.contains(muscleGroup)) {
          state = {...state}..remove(muscleGroup);
        } else {
          state = {...state, muscleGroup};
        }
        _persistState(state);
      }

      void clearAll() {
        state = {};
        _persistState(state);
      }

      // Persistence methods...
    }
    ```

- [ ] **Task 3.3**: Update Exercise List Filtering Logic
  - **Layer**: Presentation
  - **Files**: `lib/features/analytics/presentation/providers/filtered_exercises_provider.dart` (new)
  - **Dependencies**: Task 3.1, Task 3.2, existing search/favorite providers
  - **Est. Time**: 40 min
  - **Blocking**: Yes (blocks all UI tasks)
  - **Verification**: `flutter analyze` passes. Filter combinations work correctly in widget tests. All edge cases handled (empty results, all filters active, no filters).
  - **Code Prompt**:
    ```dart
    /// Combined filtered exercises provider
    /// Watches: search, favorites, equipment, muscle groups, sortBy
    final filteredExercisesProvider = Provider<List<ExerciseHistory>>((ref) {
      final allExercises = ref.watch(exerciseHistoryStreamProvider);
      final searchQuery = ref.watch(searchQueryProvider);
      final equipmentFilter = ref.watch(equipmentFilterProvider);
      final muscleGroupFilters = ref.watch(muscleGroupFilterProvider);
      final favorites = ref.watch(favoriteExercisesNotifierProvider);
      final sortBy = ref.watch(sortByProvider);

      return allExercises.when(
        data: (exercises) {
          // Apply filters in order:
          // 1. Search query
          // 2. Equipment filter
          // 3. Muscle group filters (multi-select)
          // 4. Favorites filter
          // 5. Sort by selected criteria

          var filtered = exercises;

          // Filter by search
          if (searchQuery.isNotEmpty) {
            filtered = filtered.where((e) =>
              e.exerciseName.toLowerCase().contains(searchQuery.toLowerCase())
            ).toList();
          }

          // Filter by equipment
          if (equipmentFilter != EquipmentFilterType.all) {
            filtered = filtered.where((e) =>
              e.equipmentType.name == equipmentFilter.name
            ).toList();
          }

          // Filter by muscle groups (multi-select OR logic)
          if (muscleGroupFilters.isNotEmpty) {
            filtered = filtered.where((e) =>
              muscleGroupFilters.contains(e.muscleGroup)
            ).toList();
          }

          // Filter by favorites (if favorites sort is active)
          if (sortBy == SortBy.favorites) {
            filtered = filtered.where((e) =>
              favorites.contains(e.exerciseName)
            ).toList();
          }

          // Sort
          _applySorting(filtered, sortBy);

          return filtered;
        },
        loading: () => [],
        error: (_, __) => [],
      );
    });
    ```

---

### 4. Presentation Layer - UI Components

- [ ] **Task 4.1**: Build Equipment Filter Chips Widget
  - **Layer**: Presentation
  - **Files**: `lib/features/analytics/presentation/widgets/equipment_filter_chips.dart` (new)
  - **Dependencies**: Task 3.1
  - **Est. Time**: 35 min
  - **Blocking**: No
  - **Verification**: Chips render correctly. Selections update provider. Ripple animations work. Uses AppIcons.* (no inline Icons.*). Theme-aware colors.
  - **Code Prompt**:
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
    import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
    import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

    class EquipmentFilterChips extends ConsumerWidget {
      const EquipmentFilterChips({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final selected = ref.watch(equipmentFilterProvider);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip(context, ref, EquipmentFilterType.all, context.l10n.equipmentAll, AppIcons.list, selected),
              _buildChip(context, ref, EquipmentFilterType.bodyweight, context.l10n.equipmentBodyweight, AppIcons.person, selected),
              _buildChip(context, ref, EquipmentFilterType.dumbbell, context.l10n.equipmentDumbbell, AppIcons.dumbbell, selected),
              _buildChip(context, ref, EquipmentFilterType.barbell, context.l10n.equipmentBarbell, AppIcons.barbell, selected),
              _buildChip(context, ref, EquipmentFilterType.machine, context.l10n.equipmentMachine, AppIcons.machine, selected),
              _buildChip(context, ref, EquipmentFilterType.cable, context.l10n.equipmentCable, AppIcons.cable, selected),
            ],
          ),
        );
      }

      Widget _buildChip(BuildContext context, WidgetRef ref, EquipmentFilterType type, String label, IconData icon, EquipmentFilterType selected) {
        final isSelected = selected == type;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Row(
              children: [
                Icon(icon, size: AppIconSize.tiny, color: isSelected ? context.colors.onPrimary : context.colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(label),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => ref.read(equipmentFilterProvider.notifier).setFilter(type),
            selectedColor: context.colors.primary,
            checkmarkColor: context.colors.onPrimary,
          ),
        );
      }
    }
    ```

- [ ] **Task 4.2**: Build Muscle Group Filter Chips Widget
  - **Layer**: Presentation
  - **Files**: `lib/features/analytics/presentation/widgets/muscle_group_filter_chips.dart` (new)
  - **Dependencies**: Task 3.2
  - **Est. Time**: 35 min
  - **Blocking**: No
  - **Verification**: Chips display all 7 categories (Chest, Back, Legs, Shoulders, Arms, Core, Full Body). Multi-select toggles work. AppIcons.* used throughout. Theme-aware.
  - **Code Prompt**:
    ```dart
    // Similar to Task 4.1, but with multi-select logic
    // Use Set<String> for selected muscle groups
    // Show badge with count when filters are active
    // Allow "Clear All" action
    ```

- [ ] **Task 4.3**: Add Equipment Icon + Last Workout Date to Exercise Cards
  - **Layer**: Presentation
  - **Files**: `lib/features/analytics/presentation/analytics_screen.dart` (modify `_ExerciseHistoryCard`)
  - **Dependencies**: Task 2.2, AppIcons design tokens
  - **Est. Time**: 45 min
  - **Blocking**: No
  - **Verification**: Equipment icons render per device type. Date formats respect localization (EN/IT). Theme-aware colors applied. Uses context.l10n.* for all text.
  - **Code Prompt**:
    ```dart
    // Modify _ExerciseHistoryCard widget
    // Add equipment icon to card header (next to exercise name)
    // Add last workout date label under muscle group

    // Equipment icon mapping
    final equipmentIcon = switch (history.equipmentType) {
      EquipmentType.bodyweight => AppIcons.person,
      EquipmentType.dumbbell => AppIcons.dumbbell,
      EquipmentType.barbell => AppIcons.barbell,
      EquipmentType.machine => AppIcons.machine,
      EquipmentType.cable => AppIcons.cable,
      _ => AppIcons.helpOutline,
    };

    // Last workout date formatting
    final lastWorkout = ref.watch(lastWorkoutDateProvider(history.exerciseId));
    final formattedDate = lastWorkout != null
        ? DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(lastWorkout)
        : context.l10n.never;

    // Layout: [Exercise Name] [Equipment Icon]
    //         [Muscle Group] • [Last: formattedDate]
    ```

- [ ] **Task 4.4**: Implement Sparkline Mini-Chart on Exercise Cards
  - **Layer**: Presentation
  - **Files**: `lib/features/analytics/presentation/widgets/exercise_sparkline_widget.dart` (new), modify `_ExerciseHistoryCard`
  - **Dependencies**: fl_chart package, Task 2.2
  - **Est. Time**: 50 min
  - **Blocking**: No
  - **Verification**: Sparkline renders with 7+ data points. Trend arrow displays (green up/red down). Colors theme-aware. No crashes with < 7 workouts (shows placeholder).
  - **Code Prompt**:
    ```dart
    import 'package:fl_chart/fl_chart.dart';

    class ExerciseSparkline extends StatelessWidget {
      const ExerciseSparkline({
        super.key,
        required this.sessions,
        required this.trendDirection,
      });

      final List<WorkoutSession> sessions;
      final TrendDirection trendDirection; // up, down, flat

      @override
      Widget build(BuildContext context) {
        if (sessions.length < 3) {
          return const SizedBox(width: 60, height: 30); // placeholder
        }

        final last10Sessions = sessions.take(10).toList();
        final dataPoints = last10Sessions.map((s) => s.highestEstimated1RM).toList();

        return SizedBox(
          width: 60,
          height: 30,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: dataPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                  isCurved: true,
                  color: trendDirection == TrendDirection.up
                      ? context.colors.success
                      : context.colors.error,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        );
      }
    }

    enum TrendDirection { up, down, flat }
    ```

- [ ] **Task 4.5**: Implement Left Swipe Actions on Exercise Cards
  - **Layer**: Presentation
  - **Files**: `lib/features/analytics/presentation/widgets/exercise_card_swipe.dart` (new), refactor `_ExerciseHistoryCard`
  - **Dependencies**: Existing favorite provider
  - **Est. Time**: 40 min
  - **Blocking**: No
  - **Verification**: Swipe left reveals action. Haptic feedback triggers. Favorite state syncs. Undo visual possible (snackbar). Uses Dismissible widget correctly.
  - **Code Prompt**:
    ```dart
    // Wrap _ExerciseHistoryCard with Dismissible
    Dismissible(
      key: ValueKey(history.exerciseName),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Toggle favorite state
        HapticFeedback.mediumImpact();
        ref.read(favoriteExercisesNotifierProvider.notifier).toggleFavorite(history.exerciseName);

        // Show snackbar with undo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFavorite ? context.l10n.removedFromFavorites : context.l10n.addedToFavorites),
            action: SnackBarAction(
              label: context.l10n.undo,
              onPressed: () {
                ref.read(favoriteExercisesNotifierProvider.notifier).toggleFavorite(history.exerciseName);
              },
            ),
          ),
        );

        return false; // Don't actually dismiss the card
      },
      background: Container(
        color: context.colors.primary,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          isFavorite ? AppIcons.starOutline : AppIcons.star,
          color: context.colors.onPrimary,
          size: AppIconSize.large,
        ),
      ),
      child: _ExerciseHistoryCard(history: history),
    );
    ```

---

### 5. Localization

- [ ] **Task 5.1**: Add Equipment & Filter Localization Keys
  - **Layer**: Localization
  - **Files**: `assets/i18n/app_en.arb`, `assets/i18n/app_it.arb`
  - **Dependencies**: None
  - **Est. Time**: 30 min
  - **Blocking**: Yes (blocks all UI tasks)
  - **Verification**: Keys added for all equipment types, filter labels, and UI text. `flutter gen-l10n` generates without errors. Translations complete for EN/IT.
  - **Code Prompt**:
    ```json
    // app_en.arb
    {
      "equipmentAll": "All",
      "equipmentBodyweight": "Bodyweight",
      "equipmentDumbbell": "Dumbbell",
      "equipmentBarbell": "Barbell",
      "equipmentMachine": "Machine",
      "equipmentCable": "Cable",
      "filterEquipment": "Equipment",
      "filterMuscleGroup": "Muscle Group",
      "lastWorkout": "Last: {date}",
      "trend": "Trend",
      "sparklineChartLabel": "Progress chart for last {count} workouts",
      "never": "Never"
    }

    // app_it.arb (Italian translations)
    {
      "equipmentAll": "Tutti",
      "equipmentBodyweight": "Corpo libero",
      "equipmentDumbbell": "Manubri",
      "equipmentBarbell": "Bilanciere",
      "equipmentMachine": "Macchina",
      "equipmentCable": "Cavi",
      "filterEquipment": "Attrezzatura",
      "filterMuscleGroup": "Gruppo muscolare",
      "lastWorkout": "Ultimo: {date}",
      "trend": "Tendenza",
      "sparklineChartLabel": "Grafico progressi ultimi {count} allenamenti",
      "never": "Mai"
    }
    ```

- [ ] **Task 5.2**: Add Swipe Action & Card Enhancement Localization
  - **Layer**: Localization
  - **Files**: `assets/i18n/app_en.arb`, `assets/i18n/app_it.arb`
  - **Dependencies**: Task 5.1
  - **Est. Time**: 20 min
  - **Blocking**: No
  - **Verification**: Keys added for swipe actions, tooltips, empty states. Translations complete for EN/IT. `flutter gen-l10n` succeeds.
  - **Code Prompt**:
    ```json
    // app_en.arb
    {
      "swipeToFavorite": "Swipe left to favorite",
      "swipeToUnfavorite": "Swipe left to remove from favorites",
      "addedToFavorites": "Added to favorites",
      "removedFromFavorites": "Removed from favorites",
      "undo": "Undo",
      "noExercisesMatching": "No exercises matching filters",
      "selectedFilters": "{count} filters active",
      "clearFilters": "Clear all filters"
    }

    // app_it.arb
    {
      "swipeToFavorite": "Scorri a sinistra per aggiungere ai preferiti",
      "swipeToUnfavorite": "Scorri a sinistra per rimuovere dai preferiti",
      "addedToFavorites": "Aggiunto ai preferiti",
      "removedFromFavorites": "Rimosso dai preferiti",
      "undo": "Annulla",
      "noExercisesMatching": "Nessun esercizio corrisponde ai filtri",
      "selectedFilters": "{count} filtri attivi",
      "clearFilters": "Cancella tutti i filtri"
    }
    ```

---

### 6. Testing

- [ ] **Task 6.1**: Unit Tests - Equipment & Muscle Group Filter Logic
  - **Layer**: Testing
  - **Files**: `test/features/analytics/presentation/providers/filters_test.dart` (new)
  - **Dependencies**: Task 3.1, Task 3.2, Task 3.3
  - **Est. Time**: 45 min
  - **Blocking**: No
  - **Verification**: 12+ test cases pass. Coverage > 80% for filter providers. Edge cases handled (empty results, all selected, none selected, filter combinations).
  - **Code Prompt**:
    ```dart
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';

    void main() {
      group('Equipment Filter Provider', () {
        test('defaults to "All"', () {
          final container = ProviderContainer();
          final filter = container.read(equipmentFilterProvider);
          expect(filter, EquipmentFilterType.all);
        });

        test('updates state when setFilter called', () {
          final container = ProviderContainer();
          container.read(equipmentFilterProvider.notifier).setFilter(EquipmentFilterType.dumbbell);
          expect(container.read(equipmentFilterProvider), EquipmentFilterType.dumbbell);
        });

        // Test persistence, state restoration, etc.
      });

      group('Muscle Group Filter Provider', () {
        test('defaults to empty set', () {
          final container = ProviderContainer();
          final filters = container.read(muscleGroupFilterProvider);
          expect(filters, isEmpty);
        });

        test('toggles muscle group selection', () {
          final container = ProviderContainer();
          container.read(muscleGroupFilterProvider.notifier).toggleMuscleGroup('Chest');
          expect(container.read(muscleGroupFilterProvider), {'Chest'});

          container.read(muscleGroupFilterProvider.notifier).toggleMuscleGroup('Chest');
          expect(container.read(muscleGroupFilterProvider), isEmpty);
        });

        // Test multi-select, clearAll, persistence, etc.
      });

      group('Combined Filters', () {
        test('filters by equipment + muscle group', () {
          // Test filter combinations
        });

        test('returns empty list when no exercises match', () {
          // Test edge case
        });

        test('combines with search query', () {
          // Test search + filters
        });
      });
    }
    ```

- [ ] **Task 6.2**: Widget Tests - Filter UI Components
  - **Layer**: Testing
  - **Files**: `test/features/analytics/presentation/widgets/filter_chips_test.dart` (new)
  - **Dependencies**: Task 4.1, Task 4.2
  - **Est. Time**: 40 min
  - **Blocking**: No
  - **Verification**: 10+ widget tests pass. Taps register. UI updates reflect state. `flutter test` runs without warnings.
  - **Code Prompt**:
    ```dart
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';

    void main() {
      testWidgets('Equipment filter chips render correctly', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EquipmentFilterChips(),
              ),
            ),
          ),
        );

        expect(find.text('All'), findsOneWidget);
        expect(find.text('Bodyweight'), findsOneWidget);
        expect(find.text('Dumbbell'), findsOneWidget);
        // Test all 6 options
      });

      testWidgets('Tapping chip updates provider state', (tester) async {
        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: EquipmentFilterChips(),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Dumbbell'));
        await tester.pumpAndSettle();

        expect(container.read(equipmentFilterProvider), EquipmentFilterType.dumbbell);
      });

      // Test visual feedback, selected state, etc.
    }
    ```

- [ ] **Task 6.3**: Widget Tests - Enhanced Exercise Card
  - **Layer**: Testing
  - **Files**: `test/features/analytics/presentation/widgets/exercise_card_enhanced_test.dart` (new)
  - **Dependencies**: Task 4.3, Task 4.4, Task 4.5
  - **Est. Time**: 50 min
  - **Blocking**: No
  - **Verification**: Card renders all new elements (equipment icon, sparkline, last workout date). Swipe dismissible responds. Theme changes apply. 14+ test cases pass.
  - **Code Prompt**:
    ```dart
    import 'package:flutter_test/flutter_test.dart';

    void main() {
      testWidgets('Exercise card shows equipment icon', (tester) async {
        // Test equipment icon rendering
      });

      testWidgets('Exercise card shows last workout date', (tester) async {
        // Test date formatting
      });

      testWidgets('Exercise card shows sparkline chart', (tester) async {
        // Test chart rendering (with >= 7 sessions)
      });

      testWidgets('Exercise card shows placeholder when < 7 sessions', (tester) async {
        // Test chart placeholder
      });

      testWidgets('Exercise card has colored left border', (tester) async {
        // Test muscle group color coding
      });

      testWidgets('Swipe left triggers favorite action', (tester) async {
        // Test swipe gesture
      });

      testWidgets('Card adapts to dark theme', (tester) async {
        // Test theme-aware colors
      });
    }
    ```

---

## 📊 Implementation Order

**Phase 1: Foundation (MUST DO FIRST)** - ~2h
→ Task 1.1, 1.2 (Domain layer) - 45 min
→ Task 2.1, 2.2 (Data layer) - 55 min
→ Task 5.1 (Localization) - 30 min

**Phase 2: Filter Logic (THEN)** - ~1.5h
→ Task 3.1, 3.2 (Filter providers) - 55 min
→ Task 3.3 (Combined filtering) - 40 min

**Phase 3: UI Components (PARALLEL WORKABLE)** - ~4.5h
→ Task 4.1, 4.2 (Filter chips) - 1h 10min
→ Task 4.3 (Card enhancements) - 45 min
→ Task 4.4 (Sparkline charts) - 50 min
→ Task 4.5 (Swipe actions) - 40 min
→ Task 4.6 (Color coding) - 25 min
→ Task 5.2 (Additional localization) - 20 min

**Phase 4: Testing (FINALLY)** - ~2.25h
→ Task 6.1 (Unit tests) - 45 min
→ Task 6.2 (Widget tests - filters) - 40 min
→ Task 6.3 (Widget tests - cards) - 50 min

**Total Critical Path**: ~10.25h (estimated)

---

## 🎯 Success Metrics (from Market Analysis)

- **User Engagement**: +20% session duration (from glanceable data + visual progress)
- **Filter Usage**: 60%+ of users use equipment/muscle group filters (standard in top apps)
- **Tap Efficiency**: Max 2 taps to see filtered results (UX best practice 2025)
- **Visual Progress**: Inline sparklines increase retention by 15% (market data)
- **Swipe Actions**: Reduce favorite tap-to-action by 30% (gesture efficiency)

---

## ✅ Verification Checklist (Before Mark Complete)

- [ ] All tasks completed and marked as done
- [ ] `flutter analyze` passes (0 errors)
- [ ] `flutter test` passes (all 37+ tests)
- [ ] No hardcoded strings (all use `context.l10n.*`)
- [ ] No inline `Icons.*` (all use `AppIcons.*`)
- [ ] No hardcoded colors (all use `context.colors.*`)
- [ ] Translations complete for EN + IT
- [ ] Equipment filter persists across app restarts
- [ ] Sparkline charts render correctly with 7+ data points
- [ ] Swipe actions trigger haptic feedback
- [ ] Color-coded muscle groups visible in both light/dark themes
- [ ] No performance regressions (test on real device)
- [ ] Tested on iOS 14+ and Android 8+

---

## 📝 Notes & Decisions

*(To be filled during implementation)*

---

**Plan Status**: 🟡 Pending Approval
**Next Step**: Review plan → Start Phase 1 (Foundation)
