# 📋 Database Manager UI Redesign - Complete Design Document

**Date**: 2025-01-03
**Author**: Development Team + Design Consultant
**Status**: Design Complete - Pending Review
**Estimated Effort**: 28-36 hours (6 phases + contingency)
**Risk Level**: Medium (performance optimization required)

---

## 📑 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Requirements & User Stories](#requirements--user-stories)
3. [Architecture & Data Flow](#architecture--data-flow)
4. [UI Components Detailed Design](#ui-components-detailed-design)
5. [Implementation Plan (6 Phases)](#implementation-plan-6-phases)
6. [Success Metrics & Testing](#success-metrics--testing)
7. [⚠️ Risk Assessment & Mitigation](#️-risk-assessment--mitigation)
8. [Future Enhancements](#future-enhancements)

---

## 🎯 Executive Summary

### Current State

The Database Manager is a basic admin interface with:
- ✅ Version management (publish new versions)
- ✅ Exercise list view (read-only)
- ✅ Manual editing via dialogs
- ❌ No language separation (IT/EN mixed)
- ❌ No quick-edit capabilities
- ❌ No detailed statistics
- ❌ No bulk operations

### Desired State

Transform Database Manager into a **professional multilingua dashboard** with:
- ✅ **Tab-based organization**: Overview | Exercises IT | Exercises EN
- ✅ **Quick-edit system**: 2-click inline editing via chips
- ✅ **Bulk operations**: Multi-select + toolbar for batch updates
- ✅ **Detailed statistics**: Equipment, muscle groups, difficulty distribution
- ✅ **Context-aware language selector**: Smart behavior per tab
- ✅ **Adaptive columns**: Toggle between minimal (4) and detailed (8) columns
- ✅ **Advanced filtering**: Search + multi-criteria filters

### Key Benefits

1. **Efficiency**: 2-click edits vs 5+ clicks with dialogs
2. **Scalability**: Bulk edit 100+ exercises in one operation
3. **Visibility**: Comprehensive stats for IT (1550) and EN (1501) separately
4. **Maintainability**: Clear separation of language collections
5. **Future-proof**: Easy to add DE, ES, FR languages

---

## 📊 Requirements & User Stories

### User Story 1: Quick Equipment Change
> **As an admin**, I want to quickly change an exercise's equipment from "Bilanciere" to "Manubri" **in 2 clicks**, so I don't waste time with dialogs.

**Acceptance Criteria**:
- ✅ Click exercise row → row expands with chips
- ✅ Click "Manubri" chip → auto-saves to Firestore
- ✅ Change reflects immediately in table
- ✅ Total time: <2 seconds

### User Story 2: Bulk Difficulty Update
> **As an admin**, I want to select 50 exercises and change their difficulty to "Intermedio" **in one batch operation**, so I can correct database errors efficiently.

**Acceptance Criteria**:
- ✅ Select 50+ exercises via checkboxes
- ✅ Toolbar appears with "Change Difficulty" button
- ✅ Single dropdown → batch update to Firestore
- ✅ Loading indicator during batch write
- ✅ Success message shows count updated

### User Story 3: Compare IT vs EN Statistics
> **As an admin**, I want to see equipment distribution for Italian vs English exercises **side-by-side**, so I can ensure database consistency across languages.

**Acceptance Criteria**:
- ✅ Overview tab shows stats for selected language
- ✅ Language selector dropdown (IT/EN)
- ✅ Stats update in real-time when language changed
- ✅ Shows counts: IT (1550), EN (1501)

### User Story 4: Filter by Multiple Criteria
> **As an admin**, I want to filter exercises by "Bilanciere" + "Petto" + "Avanzato" **simultaneously**, so I can find specific exercises quickly.

**Acceptance Criteria**:
- ✅ Search bar for text search
- ✅ Filter button opens multi-select dialog
- ✅ Apply filters combines with AND logic
- ✅ "Clear Filters" button resets to all
- ✅ Filter state persists during session

### User Story 5: Toggle Table Columns
> **As an admin**, I want to toggle between minimal (4) and detailed (8) columns **based on my task**, so I have clean UI when browsing and detailed info when needed.

**Acceptance Criteria**:
- ✅ Default: 4 columns (Nome, Attrezzatura, Focus, Azioni)
- ✅ "Show More" button → 8 columns (+ Difficulty, Type, Pattern, Secondary)
- ✅ Preference saved to local storage
- ✅ Icon changes: compact ⇄ detailed

---

## 🏗️ Architecture & Data Flow

### Component Hierarchy

```
DatabaseManagerScreen (StatefulWidget with TabController)
├── AppBar
│   ├── Title: "Database Manager"
│   ├── Actions: [RefreshButton, SettingsButton]
│   └── TabBar (3 tabs)
│       ├── Tab("Overview")
│       ├── Tab("Exercises IT")
│       └── Tab("Exercises EN")
│
└── TabBarView
    ├── OverviewTab
    │   ├── VersionInfoCard (enhanced)
    │   │   ├── Version Grid (2x2)
    │   │   │   ├── Version | Last Published
    │   │   │   └── Exercises EN | Exercises IT
    │   │   └── Quick Actions Row
    │   │       ├── FilledButton("Publish New Version")
    │   │       ├── OutlinedButton("Export JSON")
    │   │       └── TextButton("Import")
    │   │
    │   ├── LanguageSelectorDropdown (context-aware)
    │   │   ├── MenuItem("🇮🇹 Italian (1550)")
    │   │   ├── MenuItem("🇬🇧 English (1501)")
    │   │   └── Future: DE, ES, FR
    │   │
    │   └── StatisticsGrid (2x2 grid)
    │       ├── EquipmentStatsCard
    │       │   ├── Title: "🏋️ Equipment Distribution"
    │       │   ├── Progress Bars (top 5 visible)
    │       │   └── "Show All 9" button
    │       ├── MuscleGroupStatsCard
    │       │   ├── Title: "💪 Muscle Groups"
    │       │   ├── Progress Bars (top 5 visible)
    │       │   └── "Show All" button
    │       ├── DifficultyStatsCard
    │       │   ├── Title: "📊 Difficulty Levels"
    │       │   └── Progress Bars (3 levels)
    │       └── ExerciseTypeStatsCard
    │           ├── Title: "🎯 Exercise Types"
    │           ├── Progress Bars (top 4 visible)
    │           └── "Show All" button
    │
    ├── ExercisesITTab
    │   ├── SearchBar
    │   │   ├── TextField(hintText: "Search exercises...")
    │   │   ├── PrefixIcon(AppIcons.search)
    │   │   ├── SuffixIcon(AppIcons.filter) → opens FilterDialog
    │   │   └── onChanged: real-time filtering
    │   │
    │   ├── ToolbarRow
    │   │   ├── Text("1550 exercises • 450 filtered")
    │   │   ├── Spacer
    │   │   └── IconButton(toggle columns icon)
    │   │
    │   ├── BulkEditToolbar (conditional: visible when 2+ selected)
    │   │   ├── AnimatedContainer(height: selected >= 2 ? 60 : 0)
    │   │   ├── Text("X selected")
    │   │   ├── TextButton.icon("Change Equipment")
    │   │   ├── TextButton.icon("Change Focus")
    │   │   ├── TextButton.icon("Delete")
    │   │   └── IconButton(close) → clear selection
    │   │
    │   ├── ExercisesDataTable (adaptive columns)
    │   │   ├── DataColumn("Name") [always visible]
    │   │   ├── DataColumn("Equipment") [always visible]
    │   │   ├── DataColumn("Primary Focus") [always visible]
    │   │   ├── DataColumn("Actions") [always visible]
    │   │   ├── DataColumn("Difficulty") [conditional]
    │   │   ├── DataColumn("Type") [conditional]
    │   │   ├── DataColumn("Movement Pattern") [conditional]
    │   │   └── DataColumn("Secondary Muscles") [conditional]
    │   │
    │   └── QuickEditChipsOverlay (per-row expandable)
    │       ├── AnimatedContainer(height: expanded ? 120 : 0)
    │       ├── Equipment Chips Row
    │       │   ├── FilterChip("Corpo Libero")
    │       │   ├── FilterChip("Bilanciere")
    │       │   ├── FilterChip("Manubri")
    │       │   └── ... (9 total)
    │       ├── Type Toggle Row
    │       │   ├── ChoiceChip("Compound")
    │       │   └── ChoiceChip("Isolation")
    │       └── Difficulty Chips Row
    │           ├── FilterChip("Principiante")
    │           ├── FilterChip("Intermedio")
    │           └── FilterChip("Avanzato")
    │
    └── ExercisesENTab
        └── [Same structure as ExercisesITTab]
```

### Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    FIRESTORE COLLECTIONS                    │
├─────────────────────────────────────────────────────────────┤
│  exercises_it (1550 docs) │ exercises_en (1501 docs)       │
│  exercises_metadata/version_info (shared metadata)         │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Stream snapshots
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    RIVERPOD PROVIDERS                       │
├─────────────────────────────────────────────────────────────┤
│  exercisesITStreamProvider → Stream<List<Exercise>>        │
│  exercisesENStreamProvider → Stream<List<Exercise>>        │
│  metadataStreamProvider → Stream<Map<String, dynamic>>     │
│  selectedTabProvider → StateProvider<int>                  │
│  selectedExercisesITProvider → StateProvider<Set<String>>  │
│  selectedExercisesENProvider → StateProvider<Set<String>>  │
│  showDetailedColumnsProvider → StateProvider<bool>         │
│  overviewStatsLanguageProvider → StateProvider<String>     │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ ref.watch() / ref.read()
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    UI COMPONENTS                            │
├─────────────────────────────────────────────────────────────┤
│  OverviewTab                                                │
│    ├── watch(metadataStreamProvider) → show version info   │
│    ├── watch(overviewStatsLanguageProvider) → lang select  │
│    └── computeStats(exercises, lang) → statistics grid     │
│                                                             │
│  ExercisesITTab                                             │
│    ├── watch(exercisesITStreamProvider) → load exercises   │
│    ├── watch(selectedExercisesITProvider) → checkboxes     │
│    ├── watch(showDetailedColumnsProvider) → columns        │
│    └── read(databaseManagerService) → CRUD operations      │
│                                                             │
│  ExercisesENTab                                             │
│    └── [Same as IT but with EN providers]                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ User actions
                              ▼
┌─────────────────────────────────────────────────────────────┐
│               DATABASE OPERATIONS                           │
├─────────────────────────────────────────────────────────────┤
│  Quick Edit (single exercise):                             │
│    quickUpdateField(id, field, value, language)            │
│      → _firestore.collection('exercises_$lang')            │
│         .doc(id).update({field: value})                    │
│                                                             │
│  Bulk Edit (multiple exercises):                           │
│    bulkUpdateField(ids[], field, value, language)          │
│      → WriteBatch batch = _firestore.batch()              │
│         for id in ids:                                      │
│           batch.update(ref, {field: value})                │
│         await batch.commit()                                │
│                                                             │
│  Statistics Computation (real-time):                       │
│    computeStats(exercises, language)                       │
│      → Map<String, int> equipmentBreakdown                 │
│      → Map<String, int> muscleGroupBreakdown               │
│      → Map<String, int> difficultyBreakdown                │
│      → Map<String, int> exerciseTypeBreakdown              │
└─────────────────────────────────────────────────────────────┘
```

### State Management (Riverpod Providers)

```dart
// Firestore streams
final exercisesITStreamProvider = StreamProvider<List<Exercise>>((ref) {
  return FirebaseFirestore.instance
    .collection('exercises_it')
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Exercise.fromJson(data);
      })
      .toList());
});

final exercisesENStreamProvider = StreamProvider<List<Exercise>>((ref) {
  return FirebaseFirestore.instance
    .collection('exercises_en')
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Exercise.fromJson(data);
      })
      .toList());
});

final metadataStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return FirebaseFirestore.instance
    .collection('exercises_metadata')
    .doc('version_info')
    .snapshots()
    .map((snapshot) => snapshot.exists ? snapshot.data() : null);
});

// UI state
final selectedTabProvider = StateProvider<int>((ref) => 0);

final selectedExercisesITProvider = StateProvider<Set<String>>((ref) => {});
final selectedExercisesENProvider = StateProvider<Set<String>>((ref) => {});

final showDetailedColumnsProvider = StateProvider<bool>((ref) {
  // Load from SharedPreferences
  return false; // Default to minimal columns
});

final overviewStatsLanguageProvider = StateProvider<String>((ref) => 'it');
```

### Performance Optimizations

1. **Memoized Statistics Computation**
```dart
// Cache computed stats to avoid recalculating on every build
final _statsCache = <String, ExerciseStatistics>{};

ExerciseStatistics computeStats(List<Exercise> exercises, String language) {
  final cacheKey = '$language-${exercises.length}-${exercises.hashCode}';

  if (_statsCache.containsKey(cacheKey)) {
    return _statsCache[cacheKey]!;
  }

  final stats = _computeStatsInternal(exercises);
  _statsCache[cacheKey] = stats;
  return stats;
}
```

2. **Debounced Search**
```dart
Timer? _searchDebounce;

void _onSearchChanged(String query) {
  _searchDebounce?.cancel();
  _searchDebounce = Timer(const Duration(milliseconds: 300), () {
    setState(() {
      _searchQuery = query;
    });
  });
}

@override
void dispose() {
  _searchDebounce?.cancel();
  super.dispose();
}
```

3. **Virtualized Lists (CRITICAL for 1550+ exercises)**
```dart
// ⚠️ MANDATORY: Use ListView.builder with lazy loading
// Without virtualization, rendering 1550 rows causes UI freeze
ListView.builder(
  itemCount: filteredExercises.length,
  itemBuilder: (context, index) {
    final exercise = filteredExercises[index];
    return ExerciseDataRow(exercise: exercise);
  },
  // Performance optimization: cache extent
  cacheExtent: 500, // Preload 500px ahead
)

// Alternative: Use flutter_sticky_headers or grouped_list
// for better performance with large datasets
```

**Performance Benchmark Target**:
- Initial render: <500ms for 1550 rows
- Scroll fps: ≥60 fps
- Memory usage: <100MB for full list

4. **Batch Limit Handling**
```dart
// Firestore WriteBatch has 500 ops limit
Future<void> bulkUpdateField({
  required List<String> exerciseIds,
  required String fieldName,
  required dynamic value,
  required String language,
}) async {
  const batchSize = 500;
  final batches = <WriteBatch>[];

  for (int i = 0; i < exerciseIds.length; i += batchSize) {
    final batch = _firestore.batch();
    final end = (i + batchSize < exerciseIds.length)
      ? i + batchSize
      : exerciseIds.length;

    for (int j = i; j < end; j++) {
      final docRef = _firestore
        .collection('exercises_$language')
        .doc(exerciseIds[j]);
      batch.update(docRef, {fieldName: value});
    }

    batches.add(batch);
  }

  // Commit all batches in parallel
  await Future.wait(batches.map((batch) => batch.commit()));
}
```

---

## 🎨 UI Components Detailed Design

### 1. OverviewTab

#### A) VersionInfoCard (Enhanced)

**Visual Design**:
```
┌────────────────────────────────────────────────────────┐
│  📦 Version Information                                │
├────────────────────────────────────────────────────────┤
│  ┌───────────────────────┬──────────────────────────┐  │
│  │ Version               │ Last Published           │  │
│  │ 1.0.1                 │ 2 days ago               │  │
│  └───────────────────────┴──────────────────────────┘  │
│  ┌───────────────────────┬──────────────────────────┐  │
│  │ 🏋️ Exercises (EN)     │ 🏋️ Exercises (IT)        │  │
│  │ 1501                  │ 1550                     │  │
│  └───────────────────────┴──────────────────────────┘  │
│                                                        │
│  [Publish New Version] [Export JSON] [Import]         │
└────────────────────────────────────────────────────────┘
```

**Code Implementation**:
```dart
Card(
  margin: const EdgeInsets.all(16),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.package, size: AppIconSize.medium),
            const SizedBox(width: 8),
            Text(
              "Version Information",
              style: context.textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2x2 Grid
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                context,
                "Version",
                currentVersion,
                AppIcons.tag,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                context,
                "Last Published",
                dateStr,
                AppIcons.calendar,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                context,
                "Exercises (EN)",
                totalExercisesEn.toString(),
                AppIcons.workout,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                context,
                "Exercises (IT)",
                totalExercisesIt.toString(),
                AppIcons.workout,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick Actions Row
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: Icon(AppIcons.upload, size: AppIconSize.small),
                label: Text(context.l10n.publishNewVersion),
                onPressed: () => _showPublishDialog(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(AppIcons.export, size: AppIconSize.small),
                label: Text(context.l10n.exportJson),
                onPressed: () => _exportToJson(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                icon: Icon(AppIcons.import, size: AppIconSize.small),
                label: Text(context.l10n.importJson),
                onPressed: () => _importFromJson(),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);

Widget _buildInfoTile(
  BuildContext context,
  String label,
  String value,
  IconData icon,
) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: AppIconSize.small, color: context.iconSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
```

#### B) LanguageSelectorDropdown (Context-Aware)

**Visual Design**:
```
┌────────────────────────────────────────────────────────┐
│  Statistics Language: [🇮🇹 Italian (1550) ▼]           │
└────────────────────────────────────────────────────────┘
```

**Behavior**:
- **OverviewTab**: Dropdown visible, changes stats display
- **ExercisesITTab**: No dropdown (fixed to IT)
- **ExercisesENTab**: No dropdown (fixed to EN)

**Code Implementation**:
```dart
// Only show in Overview tab
if (currentTab == 0) ...[
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Text(
          "Statistics Language:",
          style: context.textTheme.labelLarge,
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: ref.watch(overviewStatsLanguageProvider),
          items: [
            DropdownMenuItem(
              value: 'it',
              child: Row(
                children: [
                  const Text("🇮🇹"),
                  const SizedBox(width: 8),
                  Text("Italian ($totalExercisesIt)"),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Row(
                children: [
                  const Text("🇬🇧"),
                  const SizedBox(width: 8),
                  Text("English ($totalExercisesEn)"),
                ],
              ),
            ),
            // Future: 'de', 'es', 'fr'
          ],
          onChanged: (lang) {
            if (lang != null) {
              ref.read(overviewStatsLanguageProvider.notifier).state = lang;
            }
          },
        ),
      ],
    ),
  ),
  const SizedBox(height: 16),
],
```

#### C) StatisticsGrid (Card + Progress Bars)

**Visual Design**:
```
┌──────────────────────────┬──────────────────────────┐
│ 🏋️ Equipment Distribution│ 💪 Muscle Groups         │
│                          │                          │
│ Corpo Libero ████████ 450│ Petto      ████████ 180 │
│ Bilanciere   █████░░░ 320│ Schiena    ████████ 220 │
│ Manubri      ████░░░░ 280│ Gambe      ███████░ 190 │
│ Cavi         ███░░░░░ 200│ Spalle     ████░░░░ 140 │
│ Macchina     ███░░░░░ 180│ Braccia    ███░░░░░ 120 │
│                          │                          │
│ [Show All 9 →]           │ [Show All →]             │
└──────────────────────────┴──────────────────────────┘
┌──────────────────────────┬──────────────────────────┐
│ 📊 Difficulty Levels     │ 🎯 Exercise Types        │
│                          │                          │
│ Principiante ████░░░ 400 │ Compound   ██████░░ 600 │
│ Intermedio   ██████░ 800 │ Isolation  █████░░░ 500 │
│ Avanzato     ███░░░░ 350 │ Cardio     ███░░░░░ 300 │
│                          │ Stretching ██░░░░░░ 150 │
│                          │                          │
│                          │ [Show All →]             │
└──────────────────────────┴──────────────────────────┘
```

**Code Implementation**:
```dart
GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  padding: const EdgeInsets.all(16),
  childAspectRatio: 1.2,
  children: [
    _buildStatsCard(
      context,
      title: "🏋️ Equipment Distribution",
      stats: stats.equipmentBreakdown,
      maxVisible: 5,
    ),
    _buildStatsCard(
      context,
      title: "💪 Muscle Groups",
      stats: stats.muscleGroupBreakdown,
      maxVisible: 5,
    ),
    _buildStatsCard(
      context,
      title: "📊 Difficulty Levels",
      stats: stats.difficultyBreakdown,
      maxVisible: 3,
    ),
    _buildStatsCard(
      context,
      title: "🎯 Exercise Types",
      stats: stats.exerciseTypeBreakdown,
      maxVisible: 4,
    ),
  ],
);

Widget _buildStatsCard({
  required BuildContext context,
  required String title,
  required Map<String, int> stats,
  required int maxVisible,
}) {
  final total = stats.values.reduce((a, b) => a + b);
  final sortedEntries = stats.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topEntries = sortedEntries.take(maxVisible);

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(title, style: context.textTheme.titleMedium),
          const SizedBox(height: 12),

          // Progress bars (top N)
          Expanded(
            child: ListView(
              children: topEntries.map((entry) {
                final percentage = (entry.value / total * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: context.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${entry.value} ($percentage%)",
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / total,
                          minHeight: 4,
                          backgroundColor: context.colors.surfaceContainerHighest,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // "Show All" button if more than maxVisible
          if (sortedEntries.length > maxVisible) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: Icon(AppIcons.expand, size: AppIconSize.small),
                label: Text("Show All ${sortedEntries.length}"),
                onPressed: () => _showFullStatsDialog(context, title, stats),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
```

### 2. ExercisesITTab / ExercisesENTab

#### A) SearchBar + Filters + Column Toggle

**Visual Design**:
```
┌────────────────────────────────────────────────────────┐
│  [🔍 Search exercises...             | 🔍 Filter] [⚙️] │
│  1550 exercises • 450 filtered                         │
└────────────────────────────────────────────────────────┘
```

**Code Implementation**:
```dart
Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: context.l10n.searchExercises,
                prefixIcon: Icon(AppIcons.search),
                suffixIcon: IconButton(
                  icon: Icon(AppIcons.filter),
                  onPressed: () => _showFilterDialog(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged, // Debounced
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              showDetailedColumns
                ? AppIcons.viewCompact
                : AppIcons.viewDetailed,
              size: AppIconSize.medium,
            ),
            onPressed: () {
              final newValue = !showDetailedColumns;
              ref.read(showDetailedColumnsProvider.notifier).state = newValue;
              // Save to SharedPreferences
              _saveColumnPreference(newValue);
            },
            tooltip: showDetailedColumns
              ? "Show Fewer Columns"
              : "Show More Columns",
          ),
        ],
      ),
    ),

    // Exercise count
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            "$totalCount exercises${filteredCount != totalCount ? ' • $filteredCount filtered' : ''}",
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 8),
  ],
)
```

#### B) BulkEditToolbar (Conditional Slide-Up)

**Visual Design**:
```
When 0-1 selected: Hidden (height: 0)

When 2+ selected:
┌────────────────────────────────────────────────────────┐
│  ✓ 50 selected    [Change Equipment] [Change Focus]   │
│                   [Delete] [✕]                         │
└────────────────────────────────────────────────────────┘
```

**Code Implementation**:
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  height: selectedExercises.length >= 2 ? 60 : 0,
  child: selectedExercises.isEmpty ? const SizedBox.shrink() : Material(
    elevation: 4,
    color: context.colors.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(AppIcons.checkCircle, color: context.colors.primary),
          const SizedBox(width: 8),
          Text(
            "${selectedExercises.length} selected",
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            icon: Icon(AppIcons.equipment, size: AppIconSize.small),
            label: const Text("Change Equipment"),
            onPressed: () => _showBulkChangeEquipmentDialog(context),
          ),
          TextButton.icon(
            icon: Icon(AppIcons.focus, size: AppIconSize.small),
            label: const Text("Change Focus"),
            onPressed: () => _showBulkChangeFocusDialog(context),
          ),
          TextButton.icon(
            icon: Icon(AppIcons.delete, size: AppIconSize.small),
            label: const Text("Delete"),
            onPressed: () => _confirmBulkDelete(context),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: AppIconSize.small),
            onPressed: () => _clearSelection(),
          ),
        ],
      ),
    ),
  ),
)
```

#### C) ExercisesDataTable (Adaptive Columns)

**Visual Design (Minimal - 4 columns)**:
```
┌──────────────────┬─────────────┬──────────────┬─────────┐
│ Name             │ Equipment   │ Primary Focus│ Actions │
├──────────────────┼─────────────┼──────────────┼─────────┤
│ Bench Press      │ Bilanciere  │ Petto        │ ✏️ 🗑️  │
│ Squat            │ Bilanciere  │ Gambe        │ ✏️ 🗑️  │
│ Pull-up          │ Corpo Libero│ Schiena      │ ✏️ 🗑️  │
└──────────────────┴─────────────┴──────────────┴─────────┘
```

**Visual Design (Detailed - 8 columns)**:
```
┌─────────┬────────┬────────┬────────┬───────┬───────┬────────┬────────┐
│ Name    │ Equip  │ Focus  │ Diff   │ Type  │Pattern│Second  │ Actions│
├─────────┼────────┼────────┼────────┼───────┼───────┼────────┼────────┤
│ Bench   │ Bilanc │ Petto  │ Inter  │ Comp  │ Push  │ Spalle │ ✏️ 🗑️ │
│ Squat   │ Bilanc │ Gambe  │ Avanz  │ Comp  │ Squat │ Core   │ ✏️ 🗑️ │
│ Pull-up │ Corpo  │ Schien │ Avanz  │ Comp  │ Pull  │ Braccia│ ✏️ 🗑️ │
└─────────┴────────┴────────┴────────┴───────┴───────┴────────┴────────┘
```

**Code Implementation**:
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: DataTable(
    showCheckboxColumn: true,
    columns: [
      // Always visible (4 minimal)
      DataColumn(
        label: Text(context.l10n.name),
        onSort: (columnIndex, ascending) => _sortBy('name', ascending),
      ),
      DataColumn(
        label: Text(context.l10n.equipment),
        onSort: (columnIndex, ascending) => _sortBy('equipment', ascending),
      ),
      DataColumn(
        label: Text(context.l10n.primaryFocus),
      ),
      DataColumn(
        label: Text(context.l10n.actions),
      ),

      // Conditional (4 additional when showDetailedColumns = true)
      if (showDetailedColumns) ...[
        DataColumn(
          label: Text(context.l10n.difficulty),
          onSort: (columnIndex, ascending) => _sortBy('difficulty', ascending),
        ),
        DataColumn(
          label: Text(context.l10n.type),
        ),
        DataColumn(
          label: Text(context.l10n.movementPattern),
        ),
        DataColumn(
          label: Text(context.l10n.secondaryMuscles),
        ),
      ],
    ],
    rows: filteredExercises.map((exercise) {
      final isSelected = selectedExercises.contains(exercise.id);
      final isExpanded = expandedExerciseId == exercise.id;

      return DataRow(
        selected: isSelected,
        onSelectChanged: (selected) {
          if (selected == true) {
            _addToSelection(exercise.id);
          } else {
            _removeFromSelection(exercise.id);
          }
        },
        cells: [
          // Name (tappable to expand quick-edit)
          DataCell(
            Text(
              exercise.nome,
              style: TextStyle(
                fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () => _toggleQuickEdit(exercise.id),
          ),

          // Equipment
          DataCell(Text(exercise.attrezzatura)),

          // Primary Focus
          DataCell(Text(exercise.focus.join(", "))),

          // Actions
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(AppIcons.edit, size: AppIconSize.small),
                  onPressed: () => _editExercise(exercise),
                  tooltip: context.l10n.edit,
                ),
                IconButton(
                  icon: Icon(AppIcons.delete, size: AppIconSize.small),
                  onPressed: () => _deleteExercise(exercise.id),
                  tooltip: context.l10n.delete,
                ),
              ],
            ),
          ),

          // Conditional columns
          if (showDetailedColumns) ...[
            DataCell(Text(exercise.difficolta)),
            DataCell(Text(exercise.tipoEsercizio)),
            DataCell(Text(exercise.patternMovimento)),
            DataCell(Text(exercise.muscoliSecondari.join(", "))),
          ],
        ],
      );
    }).toList(),
  ),
)
```

#### D) QuickEditChipsOverlay (Expandable Row)

**Visual Design**:
```
Row collapsed (default):
┌────────────────────────────────────────────────────────┐
│ Bench Press  │ Bilanciere │ Petto │ ✏️ 🗑️              │
└────────────────────────────────────────────────────────┘

Row expanded (after tap):
┌────────────────────────────────────────────────────────┐
│ Bench Press  │ Bilanciere │ Petto │ ✏️ 🗑️              │
├────────────────────────────────────────────────────────┤
│ Equipment: [Corpo Libero] [●Bilanciere] [Manubri]...  │
│ Type: [●Compound] [Isolation]                          │
│ Difficulty: [Princ.] [●Inter.] [Avanz.]                │
└────────────────────────────────────────────────────────┘
```

**Code Implementation**:
```dart
// Add this below each DataRow in the table
if (isExpanded)
  Container(
    padding: const EdgeInsets.all(16),
    color: context.colors.surfaceContainerHighest,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Equipment chips
        Row(
          children: [
            Text(
              "${context.l10n.equipment}:",
              style: context.textTheme.labelSmall,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: EquipmentType.values.map((eq) {
                  final isSelected = exercise.attrezzatura == eq.displayName;
                  return FilterChip(
                    label: Text(eq.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _quickUpdateField(
                          exerciseId: exercise.id,
                          fieldName: 'attrezzatura',
                          value: eq.displayName,
                          language: currentLanguage,
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Type toggle (Compound/Isolation)
        Row(
          children: [
            Text(
              "${context.l10n.type}:",
              style: context.textTheme.labelSmall,
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text("Compound"),
              selected: exercise.tipoEsercizio == "Compound",
              onSelected: (_) => _quickUpdateField(
                exerciseId: exercise.id,
                fieldName: 'tipoEsercizio',
                value: 'Compound',
                language: currentLanguage,
              ),
            ),
            const SizedBox(width: 4),
            ChoiceChip(
              label: const Text("Isolation"),
              selected: exercise.tipoEsercizio == "Isolation",
              onSelected: (_) => _quickUpdateField(
                exerciseId: exercise.id,
                fieldName: 'tipoEsercizio',
                value: 'Isolation',
                language: currentLanguage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Difficulty chips
        Row(
          children: [
            Text(
              "${context.l10n.difficulty}:",
              style: context.textTheme.labelSmall,
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text("Principiante"),
              selected: exercise.difficolta == "Principiante",
              onSelected: (_) => _quickUpdateField(
                exerciseId: exercise.id,
                fieldName: 'difficolta',
                value: 'Principiante',
                language: currentLanguage,
              ),
            ),
            const SizedBox(width: 4),
            ChoiceChip(
              label: const Text("Intermedio"),
              selected: exercise.difficolta == "Intermedio",
              onSelected: (_) => _quickUpdateField(
                exerciseId: exercise.id,
                fieldName: 'difficolta',
                value: 'Intermedio',
                language: currentLanguage,
              ),
            ),
            const SizedBox(width: 4),
            ChoiceChip(
              label: const Text("Avanzato"),
              selected: exercise.difficolta == "Avanzato",
              onSelected: (_) => _quickUpdateField(
                exerciseId: exercise.id,
                fieldName: 'difficolta',
                value: 'Avanzato',
                language: currentLanguage,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
```

---

## 📅 Implementation Plan (6 Phases)

### **PHASE 1: Foundation & Tab Structure** ⏱️ ~5-7 hours (revised +1h for error handling)

**Goal**: Implement base tab structure with functional navigation + error boundaries

**Checklist**:
- [ ] Convert `DatabaseManagerScreen` from single-view to `TabController` with 3 tabs
- [ ] Create skeleton widgets: `OverviewTab`, `ExercisesITTab`, `ExercisesENTab`
- [ ] Move existing version management code into `OverviewTab`
- [ ] Setup dual Firestore streams:
  - [ ] `exercisesITStreamProvider` → collection('exercises_it')
  - [ ] `exercisesENStreamProvider` → collection('exercises_en')
  - [ ] `metadataStreamProvider` → collection('exercises_metadata').doc('version_info')
- [ ] Setup Riverpod state providers:
  - [ ] `selectedTabProvider` → current tab index
  - [ ] `selectedExercisesITProvider` → Set<String> for IT checkboxes
  - [ ] `selectedExercisesENProvider` → Set<String> for EN checkboxes
  - [ ] `showDetailedColumnsProvider` → bool for column toggle (load from SharedPreferences)
  - [ ] `overviewStatsLanguageProvider` → String ('it', 'en') for stats language
- [ ] Display basic exercise lists in IT/EN tabs using `ListView.builder`

**Deliverable**: App with 3 navigable tabs, exercises visible in IT (1550) and EN (1501) tabs

**Acceptance Criteria**:
- [ ] Tabs switch smoothly (no lag)
- [ ] Exercises IT tab shows 1550 documents from Firestore
- [ ] Exercises EN tab shows 1501 documents from Firestore
- [ ] Overview tab shows version metadata (EN + IT counts)
- [ ] `flutter analyze` passes (0 errors)

**Testing**:
```bash
# Hot restart app
flutter run --debug

# Navigate to Database Manager
# Verify:
# - Tab bar shows 3 tabs
# - Tap each tab → content changes
# - Exercises IT shows "1550 exercises"
# - Exercises EN shows "1501 exercises"
# - No console errors
```

---

### **PHASE 2: Statistics Dashboard (Overview Tab)** ⏱️ ~4-5 hours (revised +1h for optimization)

**Goal**: Implement detailed statistics grid with Card + Progress Bars + memoization

**Checklist**:
- [ ] Create `ExerciseStatistics` class:
  ```dart
  class ExerciseStatistics {
    final Map<String, int> equipmentBreakdown;
    final Map<String, int> muscleGroupBreakdown;
    final Map<String, int> difficultyBreakdown;
    final Map<String, int> exerciseTypeBreakdown;
    final int totalExercises;
    final int bodyweightCount;
    final int compoundCount;
    final int isolationCount;
  }
  ```
- [ ] Implement `computeStats()` function with memoization
- [ ] Create `_buildStatsCard()` widget (Card + Progress Bars pattern)
- [ ] Implement 4 stats cards in 2x2 grid:
  - [ ] Equipment Distribution (9 types: Corpo Libero, Bilanciere, Manubri, etc.)
  - [ ] Muscle Groups (primary focus breakdown)
  - [ ] Difficulty Levels (Principiante, Intermedio, Avanzato)
  - [ ] Exercise Types (Compound, Isolation, Cardio, etc.)
- [ ] Add language selector dropdown (context-aware):
  - [ ] Show only in Overview tab
  - [ ] Dropdown items: IT (1550), EN (1501)
  - [ ] On change → recompute stats for selected language
- [ ] Implement "Show All" expansion dialog for each stats card

**Deliverable**: Overview tab with interactive statistics dashboard

**Acceptance Criteria**:
- [ ] Stats accurately reflect IT exercises (1550 total)
- [ ] Stats accurately reflect EN exercises (1501 total)
- [ ] Language selector switches between IT/EN stats
- [ ] Progress bars show correct percentages
- [ ] "Show All" dialog displays full breakdown (all 9 equipment types, etc.)
- [ ] Stats update in real-time when exercises change

**Testing**:
```bash
# Navigate to Overview tab
# Verify:
# - Language selector shows "Italian (1550)" by default
# - Equipment card shows top 5 types with progress bars
# - Percentages add up to 100%
# - "Show All 9" button opens dialog with all equipment
# - Change language to "English (1501)" → stats recalculate
# - All 4 cards display correctly
```

---

### **PHASE 3: Quick Edit - Inline Chips** ⏱️ ~6-8 hours (revised +1-2h for performance + retry logic)

**Goal**: Implement inline quick-edit for single exercises (2-click workflow) + error handling

**Checklist**:
- [ ] Add expandable row state management:
  - [ ] `expandedExerciseId` state variable (String?)
  - [ ] `_toggleQuickEdit(exerciseId)` function
- [ ] Implement `AnimatedContainer` for row expansion (300ms transition)
- [ ] Create `QuickEditChipsOverlay` widget with sections:
  - [ ] **Equipment chips**: 9 FilterChips (Corpo Libero, Bilanciere, Manubri, Cavi, Macchina, Kettlebell, Elastici, TRX, Vario)
  - [ ] **Type toggle**: 2 ChoiceChips (Compound, Isolation)
  - [ ] **Difficulty chips**: 3 ChoiceChips (Principiante, Intermedio, Avanzato)
  - [ ] **Focus muscles**: Multi-select FilterChips (dynamic based on available muscles)
- [ ] Implement `quickUpdateField()` function:
  ```dart
  Future<void> _quickUpdateField({
    required String exerciseId,
    required String fieldName,
    required dynamic value,
    required String language, // 'it' or 'en'
  }) async {
    try {
      await DatabaseManagerService().quickUpdateField(
        exerciseId: exerciseId,
        fieldName: fieldName,
        value: value,
      );

      // Show success feedback
      HapticFeedback.lightImpact();
      SnackBarService.showSuccess(
        context,
        "Updated $fieldName to $value",
      );
    } catch (e) {
      SnackBarService.showError(context, "Failed to update: $e");
    }
  }
  ```
- [ ] Add haptic feedback on chip tap (`HapticFeedback.lightImpact()`)
- [ ] Add SnackBar confirmation after successful update
- [ ] Ensure changes reflect immediately in table (Firestore stream auto-updates)

**Deliverable**: Tap exercise row → chips expand → 2-click edit → auto-save

**Acceptance Criteria**:
- [ ] Row expands/collapses smoothly (300ms animation)
- [ ] Chips show current values as selected (●)
- [ ] Tapping chip updates Firestore immediately
- [ ] Change reflects in table without manual refresh
- [ ] Haptic feedback confirms action
- [ ] SnackBar shows "Updated equipment to Manubri"
- [ ] Works in both IT and EN tabs

**Testing**:
```bash
# Navigate to Exercises IT tab
# Find "Panca Piana" exercise
# Tap on row → chips expand
# Tap "Manubri" chip in Equipment section
# Verify:
# - Firestore updates immediately
# - Table shows "Manubri" without refresh
# - Haptic feedback plays
# - SnackBar shows success message
# - Row can collapse by tapping again
```

---

### **PHASE 4: Bulk Edit Mode** ⏱️ ~5-7 hours (revised +1-2h for batch error handling)

**Goal**: Implement checkbox multi-select + bulk toolbar + batch error recovery

**Checklist**:
- [ ] Enable `showCheckboxColumn: true` in DataTable
- [ ] Implement checkbox selection tracking:
  - [ ] `onSelectChanged` callback → add/remove from `selectedExercises` Set
  - [ ] Separate Sets for IT and EN tabs
- [ ] Create `BulkEditToolbar` widget (AnimatedContainer):
  - [ ] Slides up from bottom when `selectedExercises.length >= 2`
  - [ ] Slides down (height: 0) when selection cleared
  - [ ] Background: `context.colors.primaryContainer`
  - [ ] Elevation: 4dp
- [ ] Implement bulk action buttons:
  - [ ] **Change Equipment**: Opens dropdown dialog → batch update
  - [ ] **Change Focus**: Opens multi-select dialog → batch update
  - [ ] **Change Difficulty**: Opens dropdown dialog → batch update
  - [ ] **Delete Selected**: Opens confirmation dialog → batch delete
  - [ ] **Clear Selection** (X button): Clears Set
- [ ] Implement `bulkUpdateField()` function with WriteBatch:
  ```dart
  Future<void> _bulkUpdateField({
    required List<String> exerciseIds,
    required String fieldName,
    required dynamic value,
    required String language,
  }) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LoadingIndicator(text: "Updating ${exerciseIds.length} exercises..."),
      );

      // Batch update (handles 500+ limit)
      await DatabaseManagerService().bulkUpdateField(
        exerciseIds: exerciseIds,
        fieldName: fieldName,
        value: value,
      );

      // Dismiss loading
      Navigator.pop(context);

      // Clear selection
      _clearSelection();

      // Show success
      SnackBarService.showSuccess(
        context,
        "Updated ${exerciseIds.length} exercises",
      );
    } catch (e) {
      Navigator.pop(context); // Dismiss loading
      SnackBarService.showError(context, "Bulk update failed: $e");
    }
  }
  ```
- [ ] Add loading indicator during batch operations
- [ ] Handle Firestore WriteBatch 500 operations limit (auto-split into multiple batches)

**Deliverable**: Select 2+ exercises → toolbar appears → bulk edit → batch save

**Acceptance Criteria**:
- [ ] Toolbar slides up when 2+ exercises selected
- [ ] Toolbar shows correct count: "50 selected"
- [ ] Bulk update applies to all selected exercises
- [ ] Loading indicator shows during batch write
- [ ] Selection clears after successful update
- [ ] Works for 100+ exercises (batch size limit handled)
- [ ] No timeout errors on large batches

**Testing**:
```bash
# Navigate to Exercises IT tab
# Check 50 exercises (use shift-click if available)
# Verify toolbar appears: "50 selected"
# Tap "Change Equipment"
# Select "Cavi" from dropdown
# Tap "Confirm"
# Verify:
# - Loading dialog shows "Updating 50 exercises..."
# - Firestore batch write completes (<3s)
# - All 50 exercises show "Cavi" in Equipment column
# - Selection clears
# - SnackBar: "Updated 50 exercises"
```

---

### **PHASE 5: Adaptive Columns & Filters** ⏱️ ~4-5 hours (revised +1h for pagination)

**Goal**: Implement column toggle + search/filter + pagination (50 per page)

**Checklist**:
- [ ] Implement `showDetailedColumnsProvider` with persistence:
  ```dart
  final showDetailedColumnsProvider = StateProvider<bool>((ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool('show_detailed_columns') ?? false;
  });

  void _saveColumnPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_detailed_columns', value);
  }
  ```
- [ ] Add conditional columns in DataTable:
  - [ ] Always visible (4): Name, Equipment, Primary Focus, Actions
  - [ ] Conditional (4): Difficulty, Type, Movement Pattern, Secondary Muscles
- [ ] Create toggle button in toolbar:
  - [ ] Icon changes: `AppIcons.viewCompact` ⇄ `AppIcons.viewDetailed`
  - [ ] Tooltip updates: "Show More Columns" / "Show Fewer Columns"
- [ ] Implement SearchBar with debounced filtering:
  ```dart
  Timer? _searchDebounce;
  String _searchQuery = '';

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
    });
  }

  List<Exercise> get filteredExercises {
    var exercises = allExercises;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      exercises = exercises.where((e) =>
        e.nome.toLowerCase().contains(_searchQuery) ||
        e.focus.any((f) => f.toLowerCase().contains(_searchQuery)) ||
        e.muscoliSecondari.any((m) => m.toLowerCase().contains(_searchQuery))
      ).toList();
    }

    // Apply filters
    // ... (equipment, difficulty, focus filters)

    return exercises;
  }
  ```
- [ ] Create advanced filter dialog:
  - [ ] **Equipment filter**: Multi-select chips (9 types)
  - [ ] **Difficulty filter**: Multi-select chips (3 levels)
  - [ ] **Focus muscle filter**: Multi-select chips (dynamic)
  - [ ] **Type filter**: Compound/Isolation toggle
  - [ ] **Clear Filters** button resets all
- [ ] Add filter state management:
  - [ ] `selectedEquipment` Set<String>
  - [ ] `selectedDifficulties` Set<String>
  - [ ] `selectedFocusMuscles` Set<String>
  - [ ] `selectedType` String? (Compound/Isolation)
- [ ] Display active filter count: "1550 exercises • 450 filtered"

**Deliverable**: Toggle columns + search + multi-criteria filters

**Acceptance Criteria**:
- [ ] Column toggle persists across app restarts (SharedPreferences)
- [ ] Search filters exercises in real-time (<100ms)
- [ ] Multiple filters combine with AND logic
- [ ] "Clear Filters" button resets to all exercises
- [ ] Filter count updates dynamically
- [ ] Performance ok with 1550 exercises (no lag)

**Testing**:
```bash
# Navigate to Exercises IT tab
# Tap column toggle → verify 4 extra columns appear
# Restart app → verify columns stay visible
# Type "petto" in search → verify filtered to ~180 exercises
# Tap Filter button → select "Bilanciere" + "Avanzato"
# Verify:
# - Only exercises with BOTH filters shown
# - Count shows "1550 exercises • 45 filtered"
# - Tap "Clear Filters" → back to 1550
```

---

### **PHASE 6: Polish & Optimizations** ⏱️ ~4-6 hours (revised +2-3h for offline testing)

**Goal**: Production-ready refinements + offline mode testing + comprehensive error handling

**Checklist**:
- [ ] Add empty states:
  - [ ] No exercises found (after search/filter)
  - [ ] No exercises in collection (edge case)
  - [ ] Use `EmptyStateWidget` with icon + message
- [ ] Add error handling:
  - [ ] Firestore read failures → show error banner
  - [ ] Firestore write failures → SnackBar with retry option
  - [ ] Network offline → cached data + warning
- [ ] Implement pull-to-refresh:
  ```dart
  RefreshIndicator(
    onRefresh: () async {
      // Force refresh from Firestore
      await ref.refresh(exercisesITStreamProvider.future);
    },
    child: ExercisesList(...),
  )
  ```
- [ ] Add loading skeletons (shimmer effect):
  - [ ] While exercises loading → show shimmer rows
  - [ ] Use `shimmer` package or custom shimmer
- [ ] Performance optimizations:
  - [ ] Memoize `computeStats()` (cache results based on exercise list hashCode)
  - [ ] Debounce search input (300ms delay) ✅ (done in Phase 5)
  - [ ] Virtualize long lists with `ListView.builder` ✅ (done in Phase 1)
  - [ ] Use `const` widgets where possible
- [ ] Accessibility improvements:
  - [ ] Add `SemanticLabel` to all icons
  - [ ] Screen reader support for statistics (announcements)
  - [ ] Keyboard navigation for DataTable
- [ ] Test dark/light themes:
  - [ ] All colors use `context.colors.*`
  - [ ] Progress bars visible in both themes
  - [ ] No hardcoded colors
- [ ] Test localizations:
  - [ ] All text uses `context.l10n.*`
  - [ ] Switch to English → verify all labels translated
  - [ ] No hardcoded strings

**Deliverable**: Production-ready Database Manager

**Acceptance Criteria**:
- [ ] `flutter analyze` passes (0 errors, 0 warnings)
- [ ] All features work in dark mode
- [ ] All text localized (IT + EN)
- [ ] Smooth performance with 1550+ exercises
- [ ] No memory leaks (controllers disposed)
- [ ] Empty states show appropriate messages
- [ ] Error handling covers all failure cases

**Testing**:
```bash
# Run analyzer
flutter analyze
# Expect: No issues found!

# Test dark mode
# Settings → Toggle dark theme
# Navigate to Database Manager
# Verify all colors readable

# Test localizations
# Settings → Change language to English
# Navigate to Database Manager
# Verify all text in English

# Test empty state
# Filter by "zzz" (no results)
# Verify empty state widget shows

# Test error handling
# Turn off WiFi
# Try to update exercise
# Verify error SnackBar with retry option
```

---

## 🎯 Success Metrics & Testing

### Functionality Metrics

| Feature | Acceptance Criteria | Status |
|---------|---------------------|--------|
| **Tab Navigation** | 3 tabs switch smoothly, content loads correctly | ⬜ |
| **Statistics Accuracy** | IT (1550) and EN (1501) stats match Firestore | ⬜ |
| **Quick Edit** | 2-click workflow, <2s total time | ⬜ |
| **Bulk Edit** | 100+ exercises update in single batch (<3s) | ⬜ |
| **Search** | <100ms response time for 1550 exercises | ⬜ |
| **Filters** | Multi-criteria filters combine correctly (AND logic) | ⬜ |
| **Column Toggle** | Persists across restarts | ⬜ |

### Code Quality Metrics

| Metric | Target | Status |
|--------|--------|--------|
| `flutter analyze` | 0 errors | ⬜ |
| Hardcoded strings | 0 (all `context.l10n.*`) | ⬜ |
| Hardcoded colors | 0 (all `context.colors.*`) | ⬜ |
| Theme support | Dark + Light tested | ⬜ |
| Localization | IT + EN complete | ⬜ |
| Responsive | Mobile + Tablet + Desktop | ⬜ |

### Performance Metrics

| Operation | Target | Actual | Status |
|-----------|--------|--------|--------|
| Tab switch | <100ms | - | ⬜ |
| Stats computation | <200ms | - | ⬜ |
| Search filter (1550 exercises) | <100ms | - | ⬜ |
| Bulk update (100 exercises) | <3s | - | ⬜ |
| Quick edit (single exercise) | <1s | - | ⬜ |

### Comprehensive Test Plan

#### Unit Tests
```dart
// test/features/admin/domain/services/statistics_service_test.dart
void main() {
  group('ExerciseStatistics', () {
    test('computeStats calculates equipment breakdown correctly', () {
      final exercises = [
        Exercise(attrezzatura: 'Bilanciere'),
        Exercise(attrezzatura: 'Bilanciere'),
        Exercise(attrezzatura: 'Manubri'),
      ];

      final stats = computeStats(exercises, 'it');

      expect(stats.equipmentBreakdown['Bilanciere'], 2);
      expect(stats.equipmentBreakdown['Manubri'], 1);
      expect(stats.totalExercises, 3);
    });

    test('computeStats memoization works', () {
      final exercises = List.generate(1550, (i) => Exercise(...));

      final sw = Stopwatch()..start();
      final stats1 = computeStats(exercises, 'it');
      final time1 = sw.elapsedMilliseconds;

      sw.reset();
      final stats2 = computeStats(exercises, 'it'); // Should use cache
      final time2 = sw.elapsedMilliseconds;

      expect(time2, lessThan(time1 / 10)); // Cache should be 10x faster
    });
  });
}
```

#### Widget Tests
```dart
// test/features/admin/presentation/widgets/stats_card_test.dart
void main() {
  testWidgets('StatsCard shows progress bars correctly', (tester) async {
    final stats = {
      'Bilanciere': 500,
      'Manubri': 300,
      'Corpo Libero': 200,
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatsCard(
            title: 'Equipment',
            stats: stats,
            maxVisible: 3,
          ),
        ),
      ),
    );

    // Verify title
    expect(find.text('Equipment'), findsOneWidget);

    // Verify progress bars (3 visible)
    expect(find.byType(LinearProgressIndicator), findsNWidgets(3));

    // Verify top entry
    expect(find.text('Bilanciere'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
  });
}
```

#### Integration Tests
```dart
// integration_test/database_manager_flow_test.dart
void main() {
  testWidgets('Complete quick-edit flow', (tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to Database Manager
    await tester.tap(find.text('Database Manager'));
    await tester.pumpAndSettle();

    // Switch to Exercises IT tab
    await tester.tap(find.text('Exercises IT'));
    await tester.pumpAndSettle();

    // Find "Panca Piana" exercise
    await tester.tap(find.text('Panca Piana'));
    await tester.pumpAndSettle();

    // Verify chips expanded
    expect(find.text('Equipment:'), findsOneWidget);

    // Tap "Manubri" chip
    await tester.tap(find.text('Manubri'));
    await tester.pumpAndSettle();

    // Verify success SnackBar
    expect(find.text('Updated equipment to Manubri'), findsOneWidget);

    // Verify table updated
    final exerciseRow = find.ancestor(
      of: find.text('Panca Piana'),
      matching: find.byType(DataRow),
    );
    expect(find.descendant(of: exerciseRow, matching: find.text('Manubri')), findsOneWidget);
  });
}
```

---

## ⚠️ Risk Assessment & Mitigation

### 🔴 HIGH PRIORITY RISKS

#### Risk 1: Performance Degradation with 1550+ Exercises

**Problem**:
- Rendering 1550 DataTable rows without virtualization = UI freeze (5-10s)
- DataTable widget is NOT optimized for large datasets
- Each row with expandable chips = heavy widget tree

**Impact**: App becomes unusable, negative user experience

**Mitigation Strategy**:
```dart
// ✅ SOLUTION 1: Use ListView.builder instead of DataTable
// DataTable doesn't support virtualization natively
ListView.builder(
  itemCount: filteredExercises.length,
  itemBuilder: (context, index) {
    return CustomExerciseRow(exercise: filteredExercises[index]);
  },
)

// ✅ SOLUTION 2: Pagination (show 50 exercises at a time)
int _currentPage = 0;
int _pageSize = 50;

List<Exercise> get pagedExercises {
  final startIndex = _currentPage * _pageSize;
  final endIndex = min(startIndex + _pageSize, filteredExercises.length);
  return filteredExercises.sublist(startIndex, endIndex);
}

// ✅ SOLUTION 3: Lazy loading with infinite scroll
ScrollController _scrollController;

@override
void initState() {
  super.initState();
  _scrollController = ScrollController()..addListener(_onScroll);
}

void _onScroll() {
  if (_scrollController.position.pixels ==
      _scrollController.position.maxScrollExtent) {
    _loadMoreExercises();
  }
}
```

**Performance Benchmarks Required**:
- [ ] Initial render: <500ms for 50 exercises (first page)
- [ ] Scroll fps: ≥60 fps with 1550 exercises loaded
- [ ] Memory usage: <150MB total
- [ ] Search filter: <100ms response time

**Recommended Approach**: **Pagination + Virtual Scrolling** (Solution 2 + 3 combined)

---

#### Risk 2: Error Handling & Offline Mode

**Problem**:
- Current design assumes always-online Firestore connection
- No error handling for network failures
- No offline caching strategy
- No retry mechanisms

**Impact**: App crashes or shows blank screen when offline

**Mitigation Strategy**:
```dart
// ✅ SOLUTION 1: Firestore Offline Persistence (already enabled globally)
// In main.dart:
await FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// ✅ SOLUTION 2: Error Boundary Widget
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget Function(Object error) errorBuilder;

  @override
  Widget build(BuildContext context) {
    return child; // Wrap with try-catch in real implementation
  }
}

// Usage in DatabaseManagerScreen:
ErrorBoundary(
  errorBuilder: (error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(AppIcons.error, size: 64, color: context.iconError),
        Text('Failed to load exercises'),
        ElevatedButton(
          onPressed: () => ref.refresh(exercisesITStreamProvider),
          child: Text('Retry'),
        ),
      ],
    ),
  ),
  child: ExercisesDataTable(...),
)

// ✅ SOLUTION 3: Connection Status Banner
StreamBuilder<ConnectivityResult>(
  stream: Connectivity().onConnectivityChanged,
  builder: (context, snapshot) {
    if (snapshot.data == ConnectivityResult.none) {
      return MaterialBanner(
        content: Text('Offline mode - showing cached data'),
        actions: [TextButton(child: Text('Dismiss'), onPressed: () {})],
      );
    }
    return SizedBox.shrink();
  },
)

// ✅ SOLUTION 4: Retry Logic for Operations
Future<void> _quickUpdateFieldWithRetry({
  required String exerciseId,
  required String fieldName,
  required dynamic value,
  int maxRetries = 3,
}) async {
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      await _quickUpdateField(exerciseId, fieldName, value);
      return; // Success
    } on FirebaseException catch (e) {
      if (attempt == maxRetries - 1) {
        // Last attempt failed
        SnackBarService.showError(
          context,
          'Failed to update after $maxRetries attempts: ${e.message}',
        );
        rethrow;
      }
      // Wait before retry (exponential backoff)
      await Future.delayed(Duration(seconds: 2 ^ attempt));
    }
  }
}
```

**Required Error Scenarios to Handle**:
- [ ] Network offline (show cached data + banner)
- [ ] Firestore read timeout (show retry button)
- [ ] Firestore write failure (show retry with exponential backoff)
- [ ] Permission denied (redirect to login)
- [ ] Collection doesn't exist (show setup wizard)
- [ ] Batch write partial failure (show which exercises failed)

**Testing Requirements**:
- [ ] Test with airplane mode enabled
- [ ] Test with slow 3G network (throttled)
- [ ] Test with intermittent connection drops
- [ ] Test batch update with 500+ exercises (WriteBatch limit)

---

#### Risk 3: Timeline Underestimation

**Problem**:
- Original estimate: 21-28 hours
- Missing considerations:
  - Performance optimization iterations (3-5 hours)
  - Error handling implementation (2-3 hours)
  - Offline mode testing (2-3 hours)
  - Bug fixes and edge cases (4-6 hours)
  - Code review and refactoring (2-3 hours)

**Revised Estimate**: **28-36 hours** (33% contingency)

**Breakdown**:
| Phase | Original | Revised | Reason |
|-------|----------|---------|--------|
| Phase 1 | 4-6h | 5-7h | Add error handling |
| Phase 2 | 3-4h | 4-5h | Optimize stats computation |
| Phase 3 | 5-6h | 6-8h | Performance tuning + retry logic |
| Phase 4 | 4-5h | 5-7h | Batch error handling |
| Phase 5 | 3-4h | 4-5h | Pagination implementation |
| Phase 6 | 2-3h | 4-6h | Offline testing + polish |
| **Total** | **21-28h** | **28-38h** | **+7-10h buffer** |

**Critical Path Items** (highest risk of delays):
1. ⚠️ Phase 3 - Performance optimization (could take 2x time)
2. ⚠️ Phase 4 - Bulk edit with 500+ exercises (WriteBatch complexity)
3. ⚠️ Phase 5 - Pagination + virtual scrolling (requires DataTable replacement)

---

### 🟡 MEDIUM PRIORITY RISKS

#### Risk 4: Firestore Cost Explosion

**Problem**:
- Real-time streams for 1550 exercises = continuous reads
- Each quick-edit = 1 write operation
- Bulk edit 100 exercises = 100 writes
- Stats computation triggers on every exercise change

**Mitigation**:
```dart
// ✅ Use manual refresh instead of real-time streams
final exercisesITProvider = FutureProvider<List<Exercise>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
    .collection('exercises_it')
    .get();
  return snapshot.docs.map((doc) => Exercise.fromJson(doc.data())).toList();
});

// Refresh manually with button
IconButton(
  icon: Icon(AppIcons.refresh),
  onPressed: () => ref.refresh(exercisesITProvider),
)

// ✅ Debounce stats computation
Timer? _statsDebounce;

void _onExercisesChanged(List<Exercise> exercises) {
  _statsDebounce?.cancel();
  _statsDebounce = Timer(Duration(seconds: 1), () {
    _computeStats(exercises);
  });
}
```

**Cost Estimation**:
- Current design (real-time): ~50,000 reads/month
- Optimized design (manual refresh): ~5,000 reads/month
- **Savings**: ~$0.20/month (90% reduction)

---

#### Risk 5: State Management Complexity

**Problem**:
- Multiple providers for IT/EN tabs (duplication)
- Selection state needs to sync with Firestore updates
- Expanded row state conflicts with table rebuilds

**Mitigation**:
```dart
// ✅ Use family providers to reduce duplication
final exercisesProvider = StreamProvider.family<List<Exercise>, String>(
  (ref, language) {
    return FirebaseFirestore.instance
      .collection('exercises_$language')
      .snapshots()
      .map((snapshot) => /* parse */);
  },
);

// Usage:
ref.watch(exercisesProvider('it')); // IT exercises
ref.watch(exercisesProvider('en')); // EN exercises

// ✅ Use StateNotifierProvider for complex state
class ExercisesTableState {
  final Set<String> selectedIds;
  final String? expandedId;
  final bool showDetailedColumns;
}

class ExercisesTableNotifier extends StateNotifier<ExercisesTableState> {
  // Complex state logic here
}
```

---

### 🟢 LOW PRIORITY RISKS

#### Risk 6: Tab Switch Performance

**Problem**: Switching tabs triggers full rebuild of 1550 exercises

**Mitigation**: Use `AutomaticKeepAliveClientMixin` to preserve tab state

#### Risk 7: Search Filter Lag

**Problem**: Filtering 1550 exercises on every keystroke

**Mitigation**: 300ms debounce (already implemented in design)

---

### 📊 Risk Matrix

| Risk | Probability | Impact | Priority | Mitigation Status |
|------|-------------|--------|----------|-------------------|
| Performance (1550 exercises) | High | Critical | 🔴 P0 | ✅ Pagination + Virtual Scroll |
| Error Handling Missing | High | High | 🔴 P0 | ✅ Error Boundaries + Retry |
| Timeline Underestimation | Medium | High | 🔴 P0 | ✅ Revised to 28-38h |
| Firestore Cost | Medium | Medium | 🟡 P1 | ✅ Manual Refresh Option |
| State Complexity | Low | Medium | 🟡 P2 | ⚠️ Needs Review |
| Tab Switch Lag | Low | Low | 🟢 P3 | ✅ KeepAlive Mixin |
| Search Filter Lag | Low | Low | 🟢 P3 | ✅ Debounce (300ms) |

---

### ✅ Pre-Implementation Checklist

**Before starting Phase 1, verify**:
- [ ] Performance strategy decided: Pagination OR Virtual Scrolling OR Both
- [ ] Error handling pattern approved (Error Boundaries + Retry)
- [ ] Offline mode requirements clarified (cached data acceptable?)
- [ ] Timeline approved (28-38h with contingency)
- [ ] Firestore cost optimization reviewed (real-time vs manual refresh)
- [ ] State management approach validated (family providers)

**Go/No-Go Decision Criteria**:
- ✅ All P0 (🔴) risks have mitigation plans
- ✅ Performance benchmarks defined and achievable
- ✅ Timeline includes 25-30% contingency buffer
- ✅ Error scenarios documented and testable

---

## 🚀 Future Enhancements

### Phase 7: Advanced Features (Post-Launch)

**Enhancements to consider after initial rollout**:

1. **Multi-language Support (DE, ES, FR)**
   - Add `exercises_de`, `exercises_es`, `exercises_fr` collections
   - Add new tabs: "Exercises DE", "Exercises ES", "Exercises FR"
   - Update language selector with flags: 🇩🇪 🇪🇸 🇫🇷
   - Auto-translate exercises using Google Translate API (optional)

2. **CSV Import/Export**
   - Export to CSV for Excel editing
   - Import from CSV with validation
   - Bulk operations via CSV (update 1000+ exercises)

3. **Version Comparison**
   - Compare two versions side-by-side
   - Diff view showing added/removed/modified exercises
   - Rollback to previous version

4. **Exercise Templates**
   - Save common exercise configurations as templates
   - "Powerlifting Template": Bilanciere + Compound + Avanzato
   - Apply template to multiple exercises at once

5. **Advanced Analytics**
   - Trend charts: Exercise count over time
   - Popular equipment trends (Bilanciere usage increasing)
   - Muscle group balance (under-represented muscles)

6. **Collaboration Features**
   - Multi-admin support with permissions
   - Audit log: Who changed what, when
   - Approval workflow for exercise edits

7. **AI-Powered Suggestions**
   - Auto-tag exercises with OpenAI (analyze name → suggest equipment/focus)
   - Detect duplicate exercises (fuzzy matching)
   - Suggest missing exercises based on muscle balance

8. **Performance Dashboard**
   - Real-time Firestore usage metrics
   - Query performance monitoring
   - Cost estimation (reads/writes per month)

---

## 📚 References & Documentation

### Related Documentation
- **Exercise Database Architecture**: `docs/UX_FLOWS/exercise_database/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`
- **Admin Features Overview**: `docs/FEATURES_IMPLEMENTATE.md` (section: Admin Tools)
- **Firestore Data Model**: `docs/STRUTTURA_DATI.md` (section: exercises_it, exercises_en, exercises_metadata)

### External Resources
- [Material Design 3 Data Tables](https://m3.material.io/components/data-tables/overview)
- [Flutter DataTable Widget](https://api.flutter.dev/flutter/material/DataTable-class.html)
- [Riverpod State Management](https://riverpod.dev/)
- [Firestore WriteBatch](https://firebase.google.com/docs/firestore/manage-data/transactions#batched-writes)

### Code Examples
- **Quick Edit Pattern**: `lib/features/routine/presentation/widgets/daily_workout_card.dart` (expandable card)
- **Statistics Cards**: `lib/features/analytics/presentation/widgets/enhanced_stat_cards.dart`
- **Bulk Operations**: `lib/features/admin/data/services/database_manager_service.dart`

---

## ✅ Approval & Sign-off

**Design Review**:
- [ ] User requirements validated
- [ ] Architecture approved
- [ ] UI/UX design approved
- [ ] Implementation plan reviewed

**Ready for Implementation**: ⬜ YES / ⬜ NO

**Estimated Start Date**: _________________
**Estimated Completion Date**: _________________

**Stakeholder Approval**:
- Developer: _____________________ Date: __________
- Design Consultant: ______________ Date: __________

---

**Document Version**: 1.0
**Last Updated**: 2025-01-03
**Next Review**: After Phase 3 completion
