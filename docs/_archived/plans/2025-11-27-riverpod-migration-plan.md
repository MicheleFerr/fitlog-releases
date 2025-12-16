# Riverpod Migration Plan - StateNotifier → Notifier + autoDispose

**Generated**: 2025-11-27 12:30
**Updated**: 2025-11-27 16:30
**Source**: task-master.dev + codebase analysis
**Complexity Score**: **VERY HIGH**
**Reason**: 63 StateNotifier instances (not 46!) + 2 core base classes across 15 features
**Total Tasks**: 42
**Estimated Time**: ~28h
**Plan Version**: 2.0

**Context Snapshot**:
- Flutter Version: 3.24.x
- Riverpod Version: ^2.4.9
- Target: Riverpod 2.x best practices (NotifierProvider pattern)
- Platform: iOS 14+, Android 8+

---

## 📋 Original Request

> Migrate all deprecated StateNotifierProvider to the new NotifierProvider/AsyncNotifierProvider pattern, and add autoDispose where appropriate to prevent memory leaks.

---

## 📊 Actual Codebase Analysis (v2.0)

### StateNotifier Distribution by Feature

| Feature | Count | Risk | Priority | Dependencies |
|---------|-------|------|----------|--------------|
| **workout** | 27 | 🔴 CRITICAL | P0 | Core app functionality |
| **home** | 8 | 🟡 HIGH | P1 | Main screen, XP, customization |
| **ai_coach** | 5 | 🟡 HIGH | P1 | Chat, voice, feedback |
| **admin** | 4 | 🟢 LOW | P3 | Admin-only features |
| **workout_templates** | 3 | 🟡 MEDIUM | P2 | Template import/export |
| **timer** | 3 | 🔴 CRITICAL | P0 | Live Activity, iOS background |
| **onboarding** | 3 | 🟢 LOW | P3 | First-time user flow |
| **settings** | 2 | 🟢 LOW | P3 | Cloud sync, premium |
| **exercise_database** | 2 | 🟢 LOW | P3 | Search, updates |
| **community** | 2 | 🟢 LOW | P3 | Social features |
| **exercise** | 1 | 🟢 LOW | P3 | Exercise optimization |
| **smart_training** | 1 | 🟢 LOW | P3 | ML suggestions |
| **premium** | 1 | 🟡 MEDIUM | P2 | IAP critical |
| **migration** | 1 | 🟢 LOW | P3 | One-time migration |
| **core (base)** | 2 | ⬜ SKIP | - | Mixin/utilities |

**Total**: 65 classes (63 to migrate, 2 base classes to skip)

---

## 🎯 Migration Patterns

### StateNotifier → Notifier

```dart
// ❌ OLD (deprecated in Riverpod 2.x)
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState.initial());

  void doSomething() {
    state = state.copyWith(...);
  }
}
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) => MyNotifier());

// ✅ NEW (Riverpod 2.x)
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState.initial();

  void doSomething() {
    state = state.copyWith(...);
  }
}
final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);
```

### StateNotifier with Dependencies → Notifier with ref

```dart
// ❌ OLD - manual dependency injection
class MyNotifier extends StateNotifier<MyState> {
  final Repository _repo;
  MyNotifier(this._repo) : super(MyState.initial());
}
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier(ref.watch(repoProvider));
});

// ✅ NEW - ref available in build()
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() {
    final repo = ref.watch(repoProvider);
    return MyState.initial();
  }
}
final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);
```

### Async StateNotifier → AsyncNotifier

```dart
// ❌ OLD
class MyNotifier extends StateNotifier<AsyncValue<Data>> {
  MyNotifier() : super(const AsyncLoading()) {
    _load();
  }
  Future<void> _load() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() => api.fetch());
  }
}

// ✅ NEW
class MyNotifier extends AsyncNotifier<Data> {
  @override
  Future<Data> build() async {
    return await api.fetch();
  }
}
```

### .family Pattern

```dart
// ❌ OLD
final myProvider = StateNotifierProvider.family<MyNotifier, State, String>(...);

// ✅ NEW
final myProvider = NotifierProvider.family<MyNotifier, State, String>(MyNotifier.new);

class MyNotifier extends FamilyNotifier<State, String> {
  @override
  State build(String arg) => State.initial(arg);
}
```

---

## 📋 Phase 0: Pre-Migration Checks

### Task 0.1: Verify Test Coverage
- **Est. Time**: 30 min
- **Action**: Run existing tests, note coverage gaps
- **Command**: `flutter test --coverage`
- **Verification**:
  - [ ] Note current test pass rate
  - [ ] Identify untested providers
  - [ ] Document baseline

### Task 0.2: Create Safety Snapshot
- **Est. Time**: 10 min
- **Action**: Create git branch for rollback
- **Command**: `git checkout -b feature/riverpod-migration`
- **Verification**:
  - [ ] Branch created
  - [ ] Working tree clean

---

## 📋 Phase 1: Low Risk - Admin & Settings (6 files, ~2h)

### Task 1.1: Admin Providers
- **Est. Time**: 40 min
- **Files**:
  - `lib/features/admin/presentation/providers/admin_sync_provider.dart`
  - `lib/features/admin/presentation/providers/community_corrections_provider.dart`
  - `lib/features/admin/presentation/providers/database_manager_provider.dart`
  - `lib/features/admin/presentation/providers/firebase_init_provider.dart`
- **Dependencies**: None (admin-only)
- **Blocking**: No
- **Verification**:
  - [ ] Admin dashboard loads
  - [ ] Sync monitoring works
  - [ ] `flutter analyze` passes

### Task 1.2: Settings Providers
- **Est. Time**: 30 min
- **Files**:
  - `lib/features/settings/presentation/providers/cloud_sync_provider.dart`
  - `lib/features/settings/presentation/widgets/premium_sync_card.dart`
- **Dependencies**: None
- **Blocking**: No
- **Verification**:
  - [ ] Settings screen loads
  - [ ] Cloud sync toggle works

### Task 1.3: Migration Provider
- **Est. Time**: 15 min
- **Files**:
  - `lib/features/migration/presentation/providers/migration_provider.dart`
- **Dependencies**: None (one-time use)
- **Blocking**: No
- **Verification**:
  - [ ] Migration screen still works (if accessible)

### Task 1.4: Community Providers
- **Est. Time**: 25 min
- **Files**:
  - `lib/features/community/presentation/providers/community_provider.dart`
  - `lib/features/community/presentation/providers/admin_moderation_provider.dart`
- **Dependencies**: None
- **Blocking**: No
- **Verification**:
  - [ ] Community feed loads
  - [ ] Moderation tools work (admin)

### Task 1.5: Exercise Database Providers
- **Est. Time**: 25 min
- **Files**:
  - `lib/features/exercise_database/presentation/providers/exercise_search_provider.dart`
  - `lib/features/exercise_database/presentation/providers/exercise_update_provider.dart`
- **Dependencies**: None
- **Blocking**: No
- **Verification**:
  - [ ] Exercise search works
  - [ ] Exercise details load

### Task 1.6: Smart Training Provider
- **Est. Time**: 15 min
- **Files**:
  - `lib/features/smart_training/presentation/providers/smart_training_providers.dart`
- **Dependencies**: workout providers (read-only)
- **Blocking**: No
- **Verification**:
  - [ ] Smart suggestions appear

---

## 📋 Phase 2: Medium Risk - Onboarding & Premium (5 files, ~1.5h)

### Task 2.1: Onboarding Providers
- **Est. Time**: 45 min
- **Files**:
  - `lib/features/onboarding/presentation/providers/onboarding_provider.dart`
  - `lib/features/onboarding/presentation/providers/onboarding_state_provider.dart`
  - `lib/features/onboarding/presentation/providers/onboarding_tour_provider.dart`
- **Dependencies**: User state
- **Blocking**: First-time user experience
- **Verification**:
  - [ ] Onboarding flow completes
  - [ ] Tour tooltips appear
  - [ ] Progress persists

### Task 2.2: Premium Provider
- **Est. Time**: 30 min
- **Files**:
  - `lib/features/premium/presentation/providers/premium_upgrade_provider.dart`
- **Dependencies**: RevenueCat, user state
- **Blocking**: Yes (IAP)
- **Verification**:
  - [ ] Premium status detected
  - [ ] Purchase flow works
  - [ ] Restore purchases works

### Task 2.3: Exercise Provider
- **Est. Time**: 15 min
- **Files**:
  - `lib/features/exercise/presentation/providers/optimized_exercise_provider.dart`
- **Dependencies**: Exercise database
- **Blocking**: No
- **Verification**:
  - [ ] Exercise optimization works

---

## 📋 Phase 3: High Risk - Home Feature (8 files, ~3h)

### Task 3.1: Home State & Customization
- **Est. Time**: 45 min
- **Files**:
  - `lib/features/home/presentation/providers/home_state_notifier.dart`
  - `lib/features/home/providers/home_customization_provider.dart`
- **Dependencies**: User preferences
- **Blocking**: Yes (main screen)
- **Verification**:
  - [ ] Home screen loads
  - [ ] Widget customization works

### Task 3.2: Achievement & XP Providers
- **Est. Time**: 45 min
- **Files**:
  - `lib/features/home/providers/achievement_xp_provider.dart`
  - `lib/features/home/providers/optimized_achievement_xp_provider.dart`
  - `lib/features/home/providers/daily_login_provider.dart`
- **Dependencies**: User data, streak
- **Blocking**: No
- **Verification**:
  - [ ] XP displays correctly
  - [ ] Daily login bonus works
  - [ ] Achievements unlock

### Task 3.3: Home Settings Providers
- **Est. Time**: 30 min
- **Files**:
  - `lib/features/home/providers/volume_settings_provider.dart`
  - `lib/features/home/providers/progress_widget_preferences_provider.dart`
  - `lib/features/home/presentation/providers/insight_feedback_provider.dart`
- **Dependencies**: User preferences
- **Blocking**: No
- **Verification**:
  - [ ] Volume display works
  - [ ] Progress widget shows

---

## 📋 Phase 4: High Risk - AI Coach (5 files, ~2h)

### Task 4.1: Chat Provider
- **Est. Time**: 45 min
- **Files**:
  - `lib/features/ai_coach/presentation/providers/chat_providers.dart`
- **Dependencies**: Firebase, user auth
- **Blocking**: Yes (chat history)
- **Verification**:
  - [ ] Chat loads
  - [ ] Messages send/receive
  - [ ] History persists

### Task 4.2: Voice & Feedback Providers
- **Est. Time**: 35 min
- **Files**:
  - `lib/features/ai_coach/presentation/providers/voice_input_provider.dart`
  - `lib/features/ai_coach/presentation/providers/feedback_provider.dart`
- **Dependencies**: Speech recognition
- **Blocking**: No
- **Verification**:
  - [ ] Voice input works
  - [ ] Feedback submission works

### Task 4.3: Feature Gate & Streak Providers
- **Est. Time**: 25 min
- **Files**:
  - `lib/features/ai_coach/presentation/providers/feature_gate_provider.dart`
  - `lib/features/ai_coach/presentation/providers/streak_tracker_provider.dart`
- **Dependencies**: Premium status
- **Blocking**: No
- **Verification**:
  - [ ] Feature gates work
  - [ ] Streak tracking accurate

---

## 📋 Phase 5: Critical - Timer (3 files, ~1.5h)

### Task 5.1: Unified Timer Provider
- **Est. Time**: 60 min
- **Files**:
  - `lib/features/timer/presentation/providers/unified_timer_provider.dart`
- **Dependencies**: iOS Live Activity, background tasks
- **Blocking**: Yes (core workout feature)
- **⚠️ CRITICAL**: Test on both iOS and Android
- **Verification**:
  - [ ] Timer starts/stops
  - [ ] Live Activity updates (iOS)
  - [ ] Background timer works
  - [ ] Sound plays on completion

### Task 5.2: Timer UI & State Providers
- **Est. Time**: 30 min
- **Files**:
  - `lib/features/timer/presentation/providers/timer_providers.dart`
  - `lib/features/timer/presentation/providers/timer_ui_state_provider.dart`
- **Dependencies**: unified_timer_provider
- **Blocking**: No
- **Verification**:
  - [ ] Timer UI displays correctly
  - [ ] State transitions smooth

---

## 📋 Phase 6: Critical - Workout Templates (3 files, ~1h)

### Task 6.1: Template Providers
- **Est. Time**: 45 min
- **Files**:
  - `lib/features/workout_templates/presentation/providers/template_provider.dart`
  - `lib/features/workout_templates/presentation/providers/template_export_provider.dart`
  - `lib/features/workout_templates/presentation/providers/template_import_provider.dart`
- **Dependencies**: Firebase, local storage
- **Blocking**: Yes (template management)
- **Verification**:
  - [ ] Templates load
  - [ ] Export works
  - [ ] Import works

---

## 📋 Phase 7: Most Critical - Workout Feature (27 files, ~12h)

### IMPORTANT: This phase should be done in sub-batches with testing between each.

### Task 7.1: Core Workout Providers (Batch A)
- **Est. Time**: 2h
- **Files**:
  - `lib/features/workout/presentation/providers/workout_provider.dart` ⚠️ CENTRAL
  - `lib/features/workout/presentation/providers/workout_repository_provider.dart`
  - `lib/features/workout/presentation/providers/workout_history_provider.dart`
- **Dependencies**: Firebase, local storage
- **Blocking**: Yes (ALL workout features depend on this)
- **Verification**:
  - [ ] Workout creation works
  - [ ] Workout completion works
  - [ ] History loads
  - [ ] Data persists

### Task 7.2: Exercise Management Providers (Batch B)
- **Est. Time**: 2h
- **Files**:
  - `lib/features/workout/presentation/providers/exercise_selection_provider.dart`
  - `lib/features/workout/presentation/providers/exercise_suggestion_provider.dart`
  - `lib/features/workout/presentation/providers/exercise_notes_provider.dart`
  - `lib/features/workout/presentation/providers/exercise_onboarding_provider.dart`
- **Dependencies**: workout_provider
- **Blocking**: No
- **Verification**:
  - [ ] Exercise selection works
  - [ ] Suggestions appear
  - [ ] Notes save

### Task 7.3: UI State Providers (Batch C)
- **Est. Time**: 1.5h
- **Files**:
  - `lib/features/workout/presentation/providers/exercise_expansion_provider.dart`
  - `lib/features/workout/presentation/providers/exercise_autocollapse_provider.dart`
  - `lib/features/workout/presentation/providers/exercise_optimization_provider.dart`
  - `lib/features/workout/presentation/providers/zen_mode_provider.dart`
- **Dependencies**: workout_provider
- **Blocking**: No
- **Verification**:
  - [ ] Expand/collapse works
  - [ ] Zen mode works
  - [ ] Auto-collapse works

### Task 7.4: Template & Auto-Save Providers (Batch D)
- **Est. Time**: 1.5h
- **Files**:
  - `lib/features/workout/presentation/providers/workout_template_provider.dart`
  - `lib/features/workout/presentation/providers/firebase_template_provider.dart`
  - `lib/features/workout/presentation/providers/workout_auto_save_provider.dart`
  - `lib/features/workout/presentation/providers/template_onboarding_provider.dart`
- **Dependencies**: workout_provider, firebase
- **Blocking**: Yes (data integrity)
- **Verification**:
  - [ ] Templates save
  - [ ] Auto-save works
  - [ ] No data loss

### Task 7.5: Recovery & Performance Providers (Batch E)
- **Est. Time**: 1h
- **Files**:
  - `lib/features/workout/presentation/providers/recovery_provider.dart`
  - `lib/features/workout/presentation/providers/workout_performance_provider.dart`
  - `lib/features/workout/presentation/providers/workout_suggestion_provider.dart`
- **Dependencies**: workout_provider, analytics
- **Blocking**: No
- **Verification**:
  - [ ] Recovery suggestions work
  - [ ] Performance metrics display

### Task 7.6: Utility Providers (Batch F)
- **Est. Time**: 1h
- **Files**:
  - `lib/features/workout/presentation/providers/add_exercise_provider.dart`
  - `lib/features/workout/presentation/providers/pdf_preferences_provider.dart`
  - `lib/features/workout/presentation/providers/screen_wakelock_provider.dart`
  - `lib/features/workout/presentation/providers/set_duration_tracker_provider.dart`
- **Dependencies**: Various
- **Blocking**: No
- **Verification**:
  - [ ] Add exercise modal works
  - [ ] PDF export works
  - [ ] Screen stays awake

### Task 7.7: Debug & Context Providers (Batch G)
- **Est. Time**: 45 min
- **Files**:
  - `lib/features/workout/presentation/providers/debug_local_data_provider.dart`
  - `lib/features/workout/presentation/providers/workout_context_provider.dart`
  - `lib/features/workout/presentation/providers/workout_edit_mode_provider.dart`
- **Dependencies**: workout_provider
- **Blocking**: No
- **Verification**:
  - [ ] Debug features work (dev mode)
  - [ ] Edit mode works

### Task 7.8: Controllers (Batch H) - Complex
- **Est. Time**: 2h
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/controllers/exercise_list_item_controller.dart`
  - `lib/features/workout/presentation/workout_screen/controllers/workout_screen_controller.dart`
- **Dependencies**: workout_provider, many UI interactions
- **Blocking**: Yes (main workout UI)
- **⚠️ COMPLEX**: These are UI controllers with complex state
- **Verification**:
  - [ ] Exercise list items work
  - [ ] Swipe actions work
  - [ ] All workout screen interactions work
  - [ ] No UI glitches

---

## 📋 Phase 8: Final Testing & Cleanup (~2h)

### Task 8.1: Full Regression Test
- **Est. Time**: 60 min
- **Action**: Run all tests, manual testing
- **Verification**:
  - [ ] All unit tests pass
  - [ ] All widget tests pass
  - [ ] Manual E2E testing
  - [ ] No memory leaks (DevTools)

### Task 8.2: Remove Deprecated Imports
- **Est. Time**: 30 min
- **Action**: Clean up any remaining StateNotifier imports
- **Verification**:
  - [ ] No StateNotifier imports remain
  - [ ] `flutter analyze` clean

### Task 8.3: Documentation Update
- **Est. Time**: 30 min
- **Action**: Update CLAUDE.md with new Riverpod patterns
- **Verification**:
  - [ ] CLAUDE.md updated
  - [ ] Example code updated

---

## 📊 Implementation Order Summary

```
Phase 0: Pre-checks           →  0.5h
Phase 1: Admin/Settings       →  2h    (6 files)
Phase 2: Onboarding/Premium   →  1.5h  (5 files)
Phase 3: Home                 →  3h    (8 files)
Phase 4: AI Coach             →  2h    (5 files)
Phase 5: Timer                →  1.5h  (3 files)  ⚠️ CRITICAL
Phase 6: Workout Templates    →  1h    (3 files)
Phase 7: Workout              →  12h   (27 files) ⚠️ MOST CRITICAL
Phase 8: Final Testing        →  2h
─────────────────────────────────────────────────
TOTAL                         → ~28h
```

**Recommended pace**: 1-2 phases per session, with full testing between phases.

---

## 🛡️ Rollback Strategy

If any phase fails:

1. `git stash` current changes
2. `git checkout main` to return to stable
3. Analyze failure in isolation
4. Fix and retry single file at a time

---

## ✅ FitLog Pro Compliance Checklist

Per ogni task, verificare:

- [ ] `flutter analyze` passa (0 errori)
- [ ] Nessun warning di deprecazione Riverpod
- [ ] Pattern Notifier corretto (build() invece di constructor)
- [ ] ref disponibile in build() per dependency injection
- [ ] autoDispose dove appropriato per memory management
- [ ] Test unitari aggiornati
- [ ] Nessuna regressione funzionale

---

## 📝 Notes & Decisions

### 2025-11-27 - Piano Aggiornato v2.0

**Cambiamenti dal v1.0**:
- ✅ Conteggio reale: 63 StateNotifier (non 46)
- ✅ 42 task (non 25)
- ✅ ~28h stimate (non 16h)
- ✅ Ordine per rischio/dipendenze
- ✅ Workout feature suddivisa in 8 batch

**Lavoro già completato** (fuori dal piano originale):
- ✅ `select()` optimization su 5+ file (commit cc8e047e → 36257b29)
- ✅ `autoDispose` parziale su notification providers (commit fc49b961)

**Stato attuale**:
- Phase 0: ❌ Non iniziato
- Phase 1-8: ❌ Non iniziato

---

## 📝 Version History

### v2.0 - 2025-11-27 16:30

**Major Revision**:
- 📊 Analisi completa codebase: 63 StateNotifier trovati
- 📋 Piano espanso da 25 a 42 task
- ⏱️ Tempo stimato da 16h a 28h
- 🎯 Workout feature suddivisa in 8 batch per ridurre rischio
- 🛡️ Aggiunta strategia di rollback
- ✅ Checklist di verifica per ogni fase

---

### v1.1 - 2025-11-27 16:00

**Changes**:
- ✏️ Aggiunto stato attuale delle migrazioni
- 📊 Aggiornato conteggio: 46 → ~21 StateNotifier rimanenti (errato)

---

### v1.0 - 2025-11-27 12:30

**Initial plan generation** via task-master.dev API
- Total Tasks: 25 (sottostimato)
- Estimated Time: ~16h (sottostimato)
- Complexity: HIGH

---
