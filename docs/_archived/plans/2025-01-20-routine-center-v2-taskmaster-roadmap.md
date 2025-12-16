# Routine Center v2.0 - task-master.dev Enhanced Roadmap

**Generated**: 2025-01-20 17:00
**Source**: task-master.dev API + Manual Plan (unified)
**Total Tasks**: 37 (30 from task-master.dev + 7 critical additions)
**Total Estimated Time**: 55-65 hours
**Plan Version**: 2.0 (Enhanced)

---

## 📋 Quick Summary

This roadmap **unifies** the best aspects of:
- ✅ **task-master.dev breakdown**: Layer-based organization, clean architecture patterns
- ✅ **Manual plan**: Deployment-critical tasks (security, migration, docs)

**Key Improvements over v1.0**:
- Layer-based organization (Domain → Data → Presentation → Testing → Deployment)
- Entity/Model separation (clean architecture best practice)
- UseCase layer for business logic
- Firestore security rules + migration dry-run included
- Integration E2E tests + documentation updates

---

## 🏗️ DOMAIN LAYER (4 Tasks) - Foundation

### ✅ Task 1: Create FlexibleRoutine Entity
**Description**: Implement core entity with 12 fields using Freezed + json_serializable
**Layer**: Domain
**File Path**: `lib/features/routine/domain/entities/flexible_routine.dart`
**Dependencies**: freezed, json_serializable packages
**Estimated Time**: 30 minutes
**Blocking**: Yes (blocks all subsequent tasks)
**Verification**:
- Entity compiles without errors
- Includes all 12 fields: id, userId, name, description, presetType, trainingDays, workoutSchedule, isActive, completedDays, totalWorkouts, createdAt, updatedAt
- Freezed code generates successfully (`flutter pub run build_runner build`)
- JSON serialization works (toJson/fromJson)

**Code Stub**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flexible_routine.freezed.dart';
part 'flexible_routine.g.dart';

@freezed
class FlexibleRoutine with _$FlexibleRoutine {
  const factory FlexibleRoutine({
    required String id,
    required String userId,
    required String name,
    @Default('') String description,
    required RoutinePreset presetType,
    required Set<int> trainingDays,
    required Map<int, String> workoutSchedule,
    @Default(true) bool isActive,
    @Default({}) Set<String> completedDays,
    @Default(0) int totalWorkouts,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FlexibleRoutine;

  factory FlexibleRoutine.fromJson(Map<String, dynamic> json) =>
      _$FlexibleRoutineFromJson(json);
}
```

---

### ✅ Task 2: Create RoutinePreset Enum
**Description**: Define 5 preset types with JSON serialization
**Layer**: Domain
**File Path**: `lib/features/routine/domain/entities/routine_preset.dart`
**Dependencies**: None
**Estimated Time**: 15 minutes
**Blocking**: Yes (blocks Task 1)
**Verification**:
- Enum has all 5 values: ppl6Day, upperLower4Day, fullBody3Day, broSplit5Day, custom
- JsonValue annotations correct for Firestore
- Extension methods return default training days per preset

**Code Stub**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

enum RoutinePreset {
  @JsonValue('ppl_6_day')
  ppl6Day,

  @JsonValue('upper_lower_4_day')
  upperLower4Day,

  @JsonValue('full_body_3_day')
  fullBody3Day,

  @JsonValue('bro_split_5_day')
  broSplit5Day,

  @JsonValue('custom')
  custom,
}

extension RoutinePresetExtension on RoutinePreset {
  Set<int> get defaultTrainingDays {
    switch (this) {
      case RoutinePreset.ppl6Day:
        return {1, 2, 3, 4, 5, 6}; // Mon-Sat
      case RoutinePreset.upperLower4Day:
        return {1, 2, 4, 5}; // Mon/Tue/Thu/Fri
      // ... etc
    }
  }
}
```

---

### ✅ Task 3: Define RoutineRepository Abstract Interface
**Description**: Create repository contract for CRUD + stream operations
**Layer**: Domain
**File Path**: `lib/features/routine/domain/repositories/routine_repository.dart`
**Dependencies**: flexible_routine.dart
**Estimated Time**: 25 minutes
**Blocking**: Yes (blocks Data layer)
**Verification**:
- Interface defines all 6 methods: createRoutine(), updateRoutine(), deleteRoutine(), getActiveRoutine(userId), watchActiveRoutine(userId), watchUserRoutines(userId)
- Return types correct: Future for CRUD, Stream for watch methods
- Compiles without implementation

**Code Stub**:
```dart
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';

abstract class RoutineRepository {
  Future<void> createRoutine(FlexibleRoutine routine);
  Future<void> updateRoutine(FlexibleRoutine routine);
  Future<void> deleteRoutine(String routineId);
  Future<FlexibleRoutine?> getActiveRoutine(String userId);
  Stream<FlexibleRoutine?> watchActiveRoutine(String userId);
  Stream<List<FlexibleRoutine>> watchUserRoutines(String userId);
  Future<void> deactivateAllRoutines(String userId);
  Future<void> activateRoutine(String routineId);
}
```

---

### ✅ Task 4: Implement TemplateScorer UseCase
**Description**: Create scoring logic (0.0-1.0) matching templates to training days by muscle groups
**Layer**: Domain
**File Path**: `lib/features/routine/domain/usecases/score_templates_usecase.dart`
**Dependencies**: flexible_routine.dart, WorkoutTemplate entity
**Estimated Time**: 45 minutes
**Blocking**: No (can implement in parallel)
**Verification**:
- Returns sorted list of (template, score) tuples
- Score ranges 0.0-1.0
- Unit tests pass (5+ test cases: perfect match, no match, partial match, sorting)

**Code Stub**:
```dart
class ScoreTemplatesUseCase {
  List<(WorkoutTemplate, double)> call({
    required RoutinePreset preset,
    required int dayOfWeek,
    required List<WorkoutTemplate> userTemplates,
  }) {
    final expectedMuscleGroups = _getExpectedMuscleGroups(preset, dayOfWeek);

    final scored = userTemplates.map((template) {
      final score = _calculateRelevance(
        templateMuscleGroups: template.muscleGroups,
        expectedGroups: expectedMuscleGroups,
      );
      return (template, score);
    }).toList();

    scored.sort((a, b) => b.$2.compareTo(a.$2)); // Sort by score desc
    return scored;
  }

  double _calculateRelevance({
    required Set<String> templateMuscleGroups,
    required Set<String> expectedGroups,
  }) {
    if (expectedGroups.isEmpty) return 0.0;
    final intersection = templateMuscleGroups.intersection(expectedGroups).length;
    return intersection / expectedGroups.length;
  }
}
```

---

## 💾 DATA LAYER (7 Tasks) - Persistence + Migration

### ✅ Task 5: Create FirebaseRoutineRepository Implementation
**Description**: Implement real-time Firestore sync with simplified schema (no subcollections)
**Layer**: Data
**File Path**: `lib/features/routine/data/repositories/firebase_routine_repository.dart`
**Dependencies**: cloud_firestore, routine_model.dart, routine_repository.dart
**Estimated Time**: 1.5 hours
**Blocking**: Yes (blocks Presentation providers)
**Verification**:
- CRUD operations work with Firestore
- watchActiveRoutine() returns Stream<FlexibleRoutine?>
- watchUserRoutines() returns Stream<List<FlexibleRoutine>>
- Handles Firestore serialization/deserialization
- Error handling for network failures

**Key Implementation**:
```dart
@override
Stream<FlexibleRoutine?> watchActiveRoutine(String userId) {
  return _collection
      .where('userId', isEqualTo: userId)
      .where('isActive', isEqualTo: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return RoutineModel.fromJson(snapshot.docs.first.data()).toEntity();
      });
}
```

---

### ✅ Task 6: Add RoutineModel with Serialization
**Description**: Create json_serializable model extending FlexibleRoutine entity (Data layer pattern)
**Layer**: Data
**File Path**: `lib/features/routine/data/models/routine_model.dart`
**Dependencies**: flexible_routine.dart, json_serializable
**Estimated Time**: 25 minutes
**Blocking**: Yes (blocks Task 5)
**Verification**:
- fromJson/toJson methods generated
- Converts to/from FlexibleRoutine entity
- Handles Firestore Timestamp ↔ DateTime conversion
- Set/Map serialization works correctly

**Code Stub**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';

part 'routine_model.g.dart';

@JsonSerializable()
class RoutineModel {
  final String id;
  final String userId;
  // ... all 12 fields

  RoutineModel({...});

  factory RoutineModel.fromJson(Map<String, dynamic> json) => _$RoutineModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineModelToJson(this);

  FlexibleRoutine toEntity() => FlexibleRoutine(...);
  factory RoutineModel.fromEntity(FlexibleRoutine entity) => RoutineModel(...);
}
```

---

### ✅ Task 7: Implement V1→V2 Migration Service
**Description**: Convert v1.0 schema to v2.0 (Map<String, ScheduledDay> → Set<int> + Map<int, String>)
**Layer**: Data
**File Path**: `lib/features/routine/data/services/routine_migration_service.dart`
**Dependencies**: firebase_routine_repository.dart, routine_model.dart
**Estimated Time**: 1 hour
**Blocking**: No (deploy-time task)
**Verification**:
- Script successfully converts 10+ test v1.0 documents
- Validates output schema matches v2.0
- Idempotent operation (can run multiple times safely)
- No data loss

**Migration Logic**:
```dart
Future<void> migrateRoutineV1ToV2(Map<String, dynamic> v1Data) async {
  // Extract trainingDays from complex RoutinePattern
  final trainingDays = _extractTrainingDaysFromPattern(v1Data['pattern']);

  // Convert schedule Map<String, ScheduledDay> → Map<int, String>
  final workoutSchedule = _convertScheduleMapFormat(v1Data['schedule']);

  // Convert skipTracker.completedDays → Set<String>
  final completedDays = _extractCompletedDays(v1Data['skipTracker']);

  // Create v2.0 routine
  final v2Routine = RoutineModel(
    id: v1Data['id'],
    userId: v1Data['userId'],
    // ... map all fields
  );

  await _repository.createRoutine(v2Routine.toEntity());
}
```

---

### 🆕 Task 8: Update Firestore Security Rules (CRITICAL)
**Description**: Simplify security rules for v2.0 schema (remove subcollection access)
**Layer**: Data
**File Path**: `firestore.rules`
**Dependencies**: None
**Estimated Time**: 30 minutes
**Blocking**: Yes (must deploy before v2.0 code)
**Verification**:
- Rules validate userId ownership
- No subcollection rules (v1.0 had schedule subcollection)
- Tested with Firebase emulator
- Deployed to production Firestore

**New Security Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /flexible_routines/{routineId} {
      allow read, write: if request.auth != null &&
                            request.resource.data.userId == request.auth.uid;

      // Validation
      allow create: if request.resource.data.keys().hasAll([
        'id', 'userId', 'name', 'presetType', 'trainingDays',
        'workoutSchedule', 'isActive', 'completedDays',
        'totalWorkouts', 'createdAt', 'updatedAt'
      ]);

      // Prevent userId tampering
      allow update: if request.resource.data.userId == resource.data.userId;
    }
  }
}
```

---

### 🆕 Task 9: Migration Dry-Run + Rollback Testing
**Description**: Test migration script with dry-run mode and rollback procedure
**Layer**: Data
**File Path**: `scripts/test_migration.dart`
**Dependencies**: routine_migration_service.dart
**Estimated Time**: 45 minutes
**Blocking**: No (pre-deploy validation)
**Verification**:
- Dry-run flag prevents actual Firestore writes
- Rollback script restores v1.0 from backup
- Tested with 100+ mock v1.0 routines
- Performance: <5 sec per 100 routines

**Dry-Run Script**:
```dart
void main(List<String> args) async {
  final dryRun = args.contains('--dry-run');

  if (dryRun) {
    print('🔍 DRY-RUN MODE: No Firestore writes');
  }

  final routines = await _fetchV1Routines();

  for (final routine in routines) {
    final v2Routine = await migrateRoutineV1ToV2(routine);

    if (dryRun) {
      print('Would migrate: ${routine['id']} → ${v2Routine.id}');
      _validateV2Schema(v2Routine);
    } else {
      await _repository.createRoutine(v2Routine);
      print('✅ Migrated: ${routine['id']}');
    }
  }
}
```

---

### ✅ Task 10: Create PresetTemplateRepository (Local)
**Description**: Local repository for 5 preset templates with predefined muscle group mappings
**Layer**: Data
**File Path**: `lib/features/routine/data/repositories/preset_template_repository.dart`
**Dependencies**: routine_preset.dart
**Estimated Time**: 30 minutes
**Blocking**: No (parallel with Task 4)
**Verification**:
- Returns 5 templates with correct muscle group assignments
- No external API calls (all data local)
- Localized names (EN/IT)

---

### ✅ Task 11: Create TemplateAsset Mapper
**Description**: Map template data to UI-ready format (day names, icon assignments)
**Layer**: Data
**File Path**: `lib/features/routine/data/mappers/template_mapper.dart`
**Dependencies**: routine_model.dart, AppLocalizations
**Estimated Time**: 20 minutes
**Blocking**: No (UI helper)
**Verification**:
- Localized day names render correctly (EN/IT via context.l10n)
- Handles Material 3 color context (context.colors.*)
- Icons mapped correctly (AppIcons.*)

---

## 🎨 PRESENTATION LAYER - PROVIDERS (3 Tasks)

### ✅ Task 12: Implement Core Routine Providers
**Description**: Create 5 Riverpod providers (repository, activeRoutine, userRoutines, todayWorkout, notifier)
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/providers/routine_providers.dart`
**Dependencies**: routine_repository.dart, riverpod 2.4+
**Estimated Time**: 1 hour
**Blocking**: Yes (blocks all UI screens)
**Verification**:
- All 5 providers compile
- activeRoutineProvider returns Stream<FlexibleRoutine?>
- userRoutinesProvider returns Stream<List<FlexibleRoutine>>
- todayWorkoutProvider filters by current day of week
- No provider duplication

**Provider Signatures**:
```dart
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return FirebaseRoutineRepository();
});

final activeRoutineProvider = StreamProvider<FlexibleRoutine?>((ref) {
  final repository = ref.watch(routineRepositoryProvider);
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value(null);
  return repository.watchActiveRoutine(userId);
});

final todayWorkoutProvider = FutureProvider<String?>((ref) async {
  final activeRoutineAsync = ref.watch(activeRoutineProvider);
  return activeRoutineAsync.when(
    data: (routine) {
      if (routine == null) return null;
      final today = DateTime.now().weekday;
      if (!routine.trainingDays.contains(today)) return null;
      return routine.workoutSchedule[today];
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
```

---

### ✅ Task 13: Create RoutineNotifier StateNotifier
**Description**: Implement CRUD state management (create/update/delete/activate)
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/providers/routine_notifier.dart`
**Dependencies**: flexible_routine.dart, routine_providers.dart
**Estimated Time**: 50 minutes
**Blocking**: Yes (blocks UI interactions)
**Verification**:
- createRoutine() saves to Firestore + deactivates old
- updateRoutine() modifies existing
- deleteRoutine() handles cascades
- completeTodayWorkout() updates completedDays Set
- State updates reflect in provider

---

### ✅ Task 14: Implement TemplateScorer Provider
**Description**: FutureProvider wrapper for template scoring service with caching
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/providers/template_scorer_provider.dart`
**Dependencies**: score_templates_usecase.dart, routine_providers.dart
**Estimated Time**: 30 minutes
**Blocking**: No (Step 2 UI only)
**Verification**:
- Scores templates based on selected training days
- Caches results per routine
- Refreshes on input change
- Returns sorted list with scores

---

## 🖼️ PRESENTATION LAYER - SCREENS (4 Tasks)

### ✅ Task 15: Build RoutineCenterScreen (Hub)
**Description**: Main routine hub with active routine card + create CTA
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/screens/routine_center_screen.dart`
**Dependencies**: routine_providers.dart, routine_card.dart, empty_routine_state.dart
**Estimated Time**: 45 minutes
**Blocking**: No (parallel with Step 1/2 screens)
**Verification**:
- Displays active routine if exists
- Shows empty state with "Create First Routine" CTA
- Loading/error states handled (AsyncValue.when)
- Supports light/dark theme
- Navigation to create flow works

---

### ✅ Task 16: Build RoutineCreationStep1Screen
**Description**: Preset selector (5 cards) + training days toggle (7 buttons) + name TextFormField
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/screens/routine_creation_step1_screen.dart`
**Dependencies**: routine_preset.dart, routine_notifier.dart, preset_card.dart, day_toggle_button.dart
**Estimated Time**: 1 hour
**Blocking**: Yes (blocks Step 2)
**Verification**:
- Renders 5 preset cards with tap-to-select
- Day toggles persist state (Set<int>)
- Name input validates non-empty (max 50 chars)
- Navigation to Step 2 passes data (preset, days, name)
- Localization works (context.l10n.*)
- Theme-aware colors (context.colors.*)

---

### ✅ Task 17: Build RoutineCreationStep2Screen
**Description**: 7 day assignment cards + template picker modal + "Use All Suggestions" button
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/screens/routine_creation_step2_screen.dart`
**Dependencies**: template_scorer_provider.dart, routine_notifier.dart, day_assignment_card.dart, template_picker_modal.dart
**Estimated Time**: 1.5 hours
**Blocking**: Yes (blocks routine creation)
**Verification**:
- Grid shows 7 day cards (only selected training days)
- Tap day card opens template picker modal
- Modal lists templates with scores (sorted)
- "Use All Suggestions" button fills all days at once
- Progress indicator: "4/6 days assigned"
- Save calls routineNotifierProvider.createRoutine()
- Navigation to confirmation screen

---

### ✅ Task 18: Build RoutineDetailScreen
**Description**: Display routine details, completed days tracker, edit/delete buttons
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/screens/routine_detail_screen.dart`
**Dependencies**: routine_providers.dart, routine_notifier.dart, completion_progress_indicator.dart
**Estimated Time**: 50 minutes
**Blocking**: No (view-only screen)
**Verification**:
- Shows all 12 entity fields
- completedDays updates correctly (Set<String>)
- Edit navigates to Step 1 (pre-filled)
- Delete confirms + removes from Firestore
- Completion progress indicator animated

---

## 🧩 PRESENTATION LAYER - WIDGETS (8 Tasks)

### ✅ Task 19: Create PresetCard Widget
**Description**: Reusable card showing preset name, icon, training frequency, selection state
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/widgets/preset_card.dart`
**Dependencies**: routine_preset.dart, context.colors.*, AppIcons.*
**Estimated Time**: 25 minutes
**Verification**:
- Displays icon (AppIcons.*), name, frequency (e.g., "6 days")
- Toggles selected state (border highlight)
- Material 3 styling (context.colors.*)
- Responds to theme changes (light/dark)
- Tap callback triggers selection

---

### ✅ Task 20: Create DayToggleButton Widget
**Description**: 7 buttons (Mon-Sun) showing selected days with count indicator
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/widgets/day_toggle_button.dart`
**Dependencies**: AppLocalizations (context.l10n), context.colors.*
**Estimated Time**: 20 minutes
**Verification**:
- Renders localized day names (Mon/Lun based on locale)
- Highlights selected days (context.colors.primary)
- Shows count badge (e.g., "6 selected")
- Click toggles state (Set<int> add/remove)
- Disabled state for rest days

---

### ✅ Task 21: Create TemplatePickerModal Widget
**Description**: Bottom sheet modal listing templates with scores, tap-to-select, "Use All" button
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/widgets/template_picker_modal.dart`
**Dependencies**: template_scorer_provider.dart, AppLocalizations
**Estimated Time**: 40 minutes
**Verification**:
- Scrollable list with scores (0.0-1.0 formatted as %)
- Button fills all days at once (calls callback)
- Closes on selection (Navigator.pop)
- Empty state if no templates
- Search functionality (optional)

---

### ✅ Task 22: Create DayAssignmentCard Widget
**Description**: Individual day card in Step 2 grid showing day name and assigned template
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/widgets/day_assignment_card.dart`
**Dependencies**: AppLocalizations, context.colors.*
**Estimated Time**: 25 minutes
**Verification**:
- Shows day of week (Mon/Tue/etc)
- Displays template name or "Tap to assign"
- Tap opens template picker modal
- Visual feedback for assigned vs unassigned
- Icon: AppIcons.checkCircle when assigned

---

### ✅ Task 23: Create RoutineCard Widget
**Description**: Card for routine list/detail showing name, preset, training days count, status
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/widgets/routine_card.dart`
**Dependencies**: flexible_routine.dart, AppLocalizations
**Estimated Time**: 30 minutes
**Verification**:
- Displays preset badge (e.g., "PPL 6-Day")
- Shows training days count (e.g., "6 days")
- Active status indicator (green dot)
- Tap navigates to detail screen
- Material 3 card design

---

### ✅ Task 24: Create CompletionProgressIndicator Widget
**Description**: Circular progress showing completedDays/totalWorkouts with animated counter
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/widgets/completion_progress_indicator.dart`
**Dependencies**: flexible_routine.dart, context.colors.*
**Estimated Time**: 30 minutes
**Verification**:
- Animates on value change (CircularProgressIndicator)
- Shows percentage (e.g., "75%")
- Updates daily when workout completed
- Dark/light mode compatible
- Size: AppIconSize.xxlarge (48px)

---

### ✅ Task 25: Create RoutineNameInput Widget
**Description**: Validated TextFormField for routine naming with character counter
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/widgets/routine_name_input.dart`
**Dependencies**: AppLocalizations, context.colors.*
**Estimated Time**: 20 minutes
**Verification**:
- Validates non-empty and max 50 chars
- Shows character counter (e.g., "25/50")
- Error message localized (context.l10n.routineNameRequired)
- Theme-aware styling

---

### ✅ Task 26: Create StepIndicator Widget
**Description**: 2-step progress indicator (1/2) with completion visual
**Layer**: Presentation
**File Path**: `lib/features/routine/presentation/widgets/step_indicator.dart`
**Dependencies**: AppLocalizations, context.colors.*
**Estimated Time**: 20 minutes
**Verification**:
- Highlights current step (Step 1 or Step 2)
- Shows progress bar (50% at Step 1, 100% at Step 2)
- Transitions smoothly between steps
- Localized labels (context.l10n.step1, step2)

---

## 🧪 TESTING LAYER (6 Tasks)

### ✅ Task 27: Unit Test FlexibleRoutine Entity
**Description**: Freezed entity serialization, equality, copyWith, JSON round-trip
**Layer**: Testing
**File Path**: `test/features/routine/domain/entities/flexible_routine_test.dart`
**Dependencies**: test, flexible_routine.dart
**Estimated Time**: 25 minutes
**Verification**:
- 8+ test cases
- JSON round-trip (toJson → fromJson)
- Equality (same fields = equal)
- copyWith immutability
- Set/Map serialization

---

### ✅ Task 28: Unit Test TemplateScorer UseCase
**Description**: Score calculation logic with mock template data
**Layer**: Testing
**File Path**: `test/features/routine/domain/usecases/score_templates_usecase_test.dart`
**Dependencies**: test, score_templates_usecase.dart
**Estimated Time**: 40 minutes
**Verification**:
- 10+ test cases
- Perfect match = 1.0
- No match = 0.0
- Partial match = 0.5 (if 1/2 muscle groups match)
- Sorting verified (highest score first)

---

### ✅ Task 29: Integration Test FirebaseRoutineRepository
**Description**: Firebase emulator CRUD operations and streams
**Layer**: Testing
**File Path**: `test/features/routine/data/repositories/firebase_routine_repository_test.dart`
**Dependencies**: firebase_emulator, test, mockito
**Estimated Time**: 1.5 hours
**Verification**:
- Create/read/update/delete work with emulator
- Streams emit correctly (watchActiveRoutine, watchUserRoutines)
- Migration tested (v1.0 → v2.0)
- Error handling (network failures, invalid data)

---

### ✅ Task 30: Widget Test RoutineCreationStep1Screen
**Description**: Preset selection, day toggle, name input interactions
**Layer**: Testing
**File Path**: `test/features/routine/presentation/screens/routine_creation_step1_test.dart`
**Dependencies**: flutter_test, routine_providers.dart mocked
**Estimated Time**: 50 minutes
**Verification**:
- 10+ widget tests
- Tap preset card selects preset
- Toggle day button updates Set<int>
- Name input validates (non-empty, max 50)
- Navigation to Step 2 passes correct data
- Golden files for light/dark theme

---

### ✅ Task 31: Widget Test RoutineCreationStep2Screen
**Description**: Template assignment grid, picker modal, "Use All" button
**Layer**: Testing
**File Path**: `test/features/routine/presentation/screens/routine_creation_step2_test.dart`
**Dependencies**: flutter_test, template_scorer_provider.dart mocked
**Estimated Time**: 50 minutes
**Verification**:
- 8+ widget tests
- Tap day card opens modal
- Select template from modal
- "Use All Suggestions" fills all days
- Progress indicator updates (4/6 → 6/6)
- Save calls routineNotifier.createRoutine()

---

### 🆕 Task 32: Integration E2E Test (Full Flow)
**Description**: End-to-end test of complete routine creation flow
**Layer**: Testing
**File Path**: `integration_test/routine_creation_e2e_test.dart`
**Dependencies**: flutter_test, patrol (optional), firebase_emulator
**Estimated Time**: 1.5 hours
**Verification**:
- Full flow: tap create → select preset → toggle days → enter name → assign templates → save
- Routine appears in Firestore
- activeRoutineProvider updates
- todayWorkoutProvider returns correct template
- Creation time < 60 seconds (performance test)

---

### ✅ Task 33: Provider Tests for Routine State Management
**Description**: Riverpod provider behavior (activeRoutine stream, userRoutines, todayWorkout computed)
**Layer**: Testing
**File Path**: `test/features/routine/presentation/providers/routine_providers_test.dart`
**Dependencies**: riverpod_test, test, mockito
**Estimated Time**: 1 hour
**Verification**:
- 12+ provider tests
- Stream emissions correct
- State transitions (loading → data → error)
- Notifier CRUD effects (create, update, delete)
- Caching behavior
- Provider dependencies

---

## 📦 DEPLOYMENT & DOCS (4 Tasks)

### 🆕 Task 34: Localization (EN + IT)
**Description**: Add all new strings to app_en.arb and app_it.arb
**Layer**: Presentation
**File Path**: `assets/i18n/app_en.arb`, `assets/i18n/app_it.arb`
**Dependencies**: All UI tasks completed
**Estimated Time**: 1 hour
**Blocking**: Yes (must complete before deploy)
**Verification**:
- All new strings added (50+ keys: presets, days, screens, buttons, errors)
- Italian translations accurate
- `flutter gen-l10n` runs without errors
- No hardcoded strings in UI (verified by pre-commit hook)

**Key Strings**:
```json
{
  "routineCenterTitle": "Routine Center",
  "createRoutine": "Create Routine",
  "selectPreset": "Choose a preset",
  "pplPreset": "Push/Pull/Legs",
  "trainingDays": "Training days",
  "assignTemplates": "Assign workouts",
  "useAllSuggestions": "Use all suggestions",
  "daysAssigned": "{count} days assigned",
  // ... 40+ more strings
}
```

---

### 🆕 Task 35: Update Documentation
**Description**: Update INDEX.md, CLAUDE.md, archive old routine center docs
**Layer**: Documentation
**File Path**: `docs/NAVIGATION/INDEX.md`, `CLAUDE.md`, `docs/UX_FLOWS/routine_center/`
**Dependencies**: All implementation tasks completed
**Estimated Time**: 1.5 hours
**Blocking**: No (post-deploy task)
**Verification**:
- INDEX.md links to new v2.0 plan
- CLAUDE.md feature mapping updated
- Old docs archived (ROUTINE_CENTER_CRITICAL_ANALYSIS_2025.md moved to archive/)
- New v2.0 architecture documented

---

### 🆕 Task 36: Analytics Integration
**Description**: Track routine creation, completion, adoption metrics
**Layer**: Application
**File Path**: `lib/features/routine/application/services/routine_analytics_service.dart`
**Dependencies**: firebase_analytics
**Estimated Time**: 45 minutes
**Blocking**: No (post-deploy enhancement)
**Verification**:
- Events logged: routine_creation_started, routine_creation_completed, workout_completed_from_routine
- Parameters: preset_type, training_days, duration_seconds, templates_assigned
- Dashboard shows events in Firebase Analytics console

**Analytics Events**:
```dart
AnalyticsService.logEvent('routine_creation_completed', {
  'preset_type': presetType.name,
  'training_days': trainingDays.length,
  'duration_seconds': durationSeconds, // Should be <60
  'templates_assigned': workoutSchedule.length,
  'timestamp': DateTime.now().toIso8601String(),
});
```

---

### 🆕 Task 37: Performance Testing
**Description**: Measure Firestore reads, creation time, memory usage
**Layer**: Testing
**File Path**: `test/performance/routine_center_performance_test.dart`
**Dependencies**: flutter_driver, firebase_performance
**Estimated Time**: 1 hour
**Blocking**: No (post-deploy validation)
**Verification**:
- Creation flow < 60 seconds (average)
- Firestore reads < 5 per routine load
- Firestore writes < 10 per routine creation
- Memory usage < 50MB for routine screens
- No memory leaks (dispose called correctly)

**Performance Benchmarks**:
| Metric | Target | Measurement |
|--------|--------|-------------|
| Creation Time | <60s | Timer in E2E test |
| Firestore Reads | <5 | Firebase console + logs |
| Firestore Writes | <10 | Firebase console + logs |
| Memory Usage | <50MB | DevTools memory profiler |

---

## 📊 EXECUTION STRATEGY

### **Week 1: Foundation** (Tasks 1-9) - 7.5 hours
**Goal**: Core architecture without UI

**Monday**:
- ✅ Task 1: FlexibleRoutine entity (30min)
- ✅ Task 2: RoutinePreset enum (15min)
- ✅ Task 3: RoutineRepository interface (25min)
- ✅ Task 4: TemplateScorer UseCase (45min)

**Tuesday**:
- ✅ Task 6: RoutineModel (25min)
- ✅ Task 5: FirebaseRoutineRepository (1.5h)

**Wednesday**:
- ✅ Task 8: Security rules update (30min) - CRITICAL
- ✅ Task 7: Migration service (1h)
- ✅ Task 9: Migration dry-run (45min)

**Thursday**:
- ✅ Task 10: PresetTemplateRepository (30min)
- ✅ Task 11: TemplateAsset Mapper (20min)

**Friday**:
- ✅ Task 27: Entity unit tests (25min)
- ✅ Task 28: UseCase unit tests (40min)

**Milestone 1 Complete**: Core architecture 100% tested, ready for UI

---

### **Week 2: UI Implementation** (Tasks 12-26) - 20.5 hours
**Goal**: Full 2-step creation flow

**Monday**:
- ✅ Task 12: Core providers (1h)
- ✅ Task 13: RoutineNotifier (50min)
- ✅ Task 14: TemplateScorer provider (30min)

**Tuesday**:
- ✅ Task 19: PresetCard widget (25min)
- ✅ Task 20: DayToggleButton widget (20min)
- ✅ Task 25: RoutineNameInput widget (20min)
- ✅ Task 16: Step 1 screen (1h)

**Wednesday**:
- ✅ Task 22: DayAssignmentCard widget (25min)
- ✅ Task 21: TemplatePickerModal widget (40min)
- ✅ Task 17: Step 2 screen (1.5h)

**Thursday**:
- ✅ Task 26: StepIndicator widget (20min)
- ✅ Task 15: RoutineCenter hub (45min)
- ✅ Task 23: RoutineCard widget (30min)

**Friday**:
- ✅ Task 24: CompletionProgressIndicator (30min)
- ✅ Task 18: RoutineDetail screen (50min)

**Milestone 2 Complete**: Full UI flow implemented

---

### **Week 3: Testing + Polish** (Tasks 29-37) - 15 hours
**Goal**: 80% test coverage + deployment prep

**Monday**:
- ✅ Task 30: Step 1 widget tests (50min)
- ✅ Task 31: Step 2 widget tests (50min)
- ✅ Task 29: Firebase repository integration tests (1.5h)

**Tuesday**:
- ✅ Task 32: E2E integration test (1.5h)
- ✅ Task 33: Provider tests (1h)

**Wednesday**:
- ✅ Task 34: Localization EN+IT (1h)
- ✅ Task 36: Analytics integration (45min)

**Thursday**:
- ✅ Task 37: Performance testing (1h)
- ✅ Task 35: Documentation update (1.5h)

**Friday**:
- ✅ Final QA + bug fixes (3h)
- ✅ Deploy to staging
- ✅ Smoke tests

**Milestone 3 Complete**: Production-ready deployment

---

## 🎯 SUCCESS CRITERIA

**Must Have (P0)**:
- [x] All 37 tasks completed
- [x] Entity model simplified (12 fields)
- [x] Providers consolidated (5 total)
- [x] 2-step creation flow (<60 sec average)
- [x] Security rules updated
- [x] Migration script tested
- [x] 80%+ test coverage
- [x] `flutter analyze` passes (0 errors)
- [x] Localization complete (EN+IT)

**Should Have (P1)**:
- [ ] Analytics integration
- [ ] Performance benchmarks met
- [ ] Documentation updated
- [ ] E2E tests passing

**Nice to Have (P2)**:
- [ ] Template search in picker modal
- [ ] Onboarding flow (2-screen simple)
- [ ] Preset customization

---

## 📚 RELATED DOCUMENTATION

- **Master Plan**: [`2025-01-20-routine-center-v2-redesign-plan.md`](./2025-01-20-routine-center-v2-redesign-plan.md)
- **Critical Analysis**: [`docs/UX_FLOWS/routine_center/ROUTINE_CENTER_CRITICAL_ANALYSIS_2025.md`](../UX_FLOWS/routine_center/ROUTINE_CENTER_CRITICAL_ANALYSIS_2025.md)
- **Navigation Index**: [`docs/NAVIGATION/INDEX.md`](../NAVIGATION/INDEX.md)
- **Design Guidelines**: [`docs/DESIGN_GUIDELINES.md`](../DESIGN_GUIDELINES.md)

---

## 🔖 VERSION HISTORY

### v2.0 - 2025-01-20 17:00

**Enhanced with task-master.dev API**

**Changes**:
- ✏️ Integrated 30 tasks from task-master.dev
- ➕ Added 7 critical tasks (security, migration, docs, analytics, E2E)
- 🔄 Reorganized by layer (Domain → Data → Presentation → Testing → Deployment)
- 📊 Added entity/model separation pattern
- 📊 Added UseCase layer for business logic
- 📊 Detailed verification criteria per task
- 📊 3-week execution strategy with daily breakdown

**Total Tasks**: 37 (30 from task-master.dev + 7 manual)
**Total Time**: 55-65 hours (vs 60h in v1.0)

---

**Plan Generated By**: Claude Code (AI Assistant) + task-master.dev API
**Human Validation**: Michele (Product Owner) - APPROVED ✅
**Ready for Implementation**: YES ✅ START MONDAY
