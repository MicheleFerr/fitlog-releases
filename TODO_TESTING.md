# 🧪 TODO TESTING - GymBro TrackLog

> **Last Updated**: 2025-10-31
> **Current Coverage**: 27.7% (510/1839 lines)
> **Target Coverage**: 70%+
> **Tests Created Today**: 145 new tests (83% passing)

---

## 📊 STATO ATTUALE

### ✅ Completato (11 files testati)
- [x] `pattern_detection_service.dart` - 35+ tests ✅
- [x] `recovery_time_calculator.dart` - 20+ tests ✅
- [x] `rest_time_suggestion_service.dart` - 13 tests ✅
- [x] `rpe_autoregulation_service.dart` - 31 tests ✅
- [x] `workout_export_service.dart` - 6 tests ✅
- [x] `workout_import_service.dart` - 40+ tests (⚠️ 7 CSV tests da fixare)
- [x] `exercise_history_service.dart` - Test esistente
- [x] `workout_provider.dart` - Test esistente
- [x] `workout_auto_save_provider.dart` - Test esistente
- [x] `workout_performance_provider.dart` - Test esistente
- [x] `workout_repository.dart` - Test base esistente

---

## ⚙️ WORKFLOW TESTING (OBBLIGATORIO)

**🔄 IMPORTANTE**: Per ogni fase, seguire questo workflow completo:

### 1️⃣ **CREA** i test
- Scrivi i test seguendo i template pattern
- Usa mocking appropriato (mocktail, fake_cloud_firestore)
- Segui naming convention: `should [behavior] when [condition]`

### 2️⃣ **ESEGUI** tutti i test
```bash
# Esegui tutti i test della feature
flutter test test/features/workout/

# Oppure test specifico
flutter test test/features/workout/data/repositories/hybrid_workout_repository_impl_test.dart
```

### 3️⃣ **FIX** test falliti
- ❌ Se test falliscono → **OBBLIGATORIO**: fixare PRIMA di procedere
- Verifica errori di compilazione
- Controlla assertion failures
- Valida mock behavior
- **NON procedere** alla fase successiva con test falliti

### 4️⃣ **VERIFICA** coverage
```bash
# Genera coverage report
flutter test test/features/workout/ --coverage

# Verifica percentuale
lcov --summary coverage/lcov.info
```

### 5️⃣ **COMMIT** solo quando tutto passa
```bash
git add test/
git commit -m "test: add [feature] tests - [X] tests passing"
```

**⚠️ REGOLA D'ORO**: Mai committare test che falliscono. Ogni fase deve avere 100% test passing prima di procedere alla successiva.

---

## 🔴 FASE 1: CRITICO (2-3 giorni) ⚠️ START HERE

**Impact**: Alto | **Effort**: 12-14 ore | **ROI**: Massimo

### Domain Services (Business Logic Core)

- [ ] **`apre_calculation_service.dart`** 🔴 PRIORITÀ #1
  - **Perché**: Calcoli APRE (Autoregulated Progressive Resistance Exercise)
  - **Rischio**: Errori nei calcoli → programmazione allenamento sbagliata
  - **Effort**: 2h
  - **Test da creare**:
    - Pre-calculate APRE weights per workout
    - Calcolo 1RM, 3RM, 6RM, 10RM basato su performance
    - Gestione concorrenza (mutex per calcoli paralleli)
    - Error handling con calcoli falliti
  - **Mock richiesti**: Riverpod Ref (complesso - richiede ProviderContainer mock)

- [ ] **`apre_auto_regulation_service.dart`** 🔴 PRIORITÀ #2
  - **Perché**: Auto-regolazione carichi basata su performance
  - **Rischio**: Suggerimenti peso errati → overtraining o undertraining
  - **Effort**: 2h
  - **Test da creare**:
    - Calcolo adjustment peso basato su reps effettive vs target
    - Soglie adjustment (+5%, +10%, -5%, -10%)
    - Capping adjustment (max ±20%)
    - Integration con RPE service

- [ ] **`apre_service.dart`** 🔴 PRIORITÀ #3
  - **Perché**: Servizio principale coordinamento APRE
  - **Rischio**: Orchestrazione errata dei calcoli
  - **Effort**: 1h
  - **Test da creare**:
    - Coordinamento calcoli APRE per workout completo
    - Gestione cache risultati
    - Error recovery e fallback

### Data Layer (Persistence & Sync)

- [ ] **`hybrid_workout_repository_impl.dart`** 🔴 PRIORITÀ #4
  - **Perché**: Repository PRINCIPALE - tutti i workout passano da qui
  - **Rischio**: Loss dati, sync errors, corruzione database
  - **Effort**: 4h (più complesso - richiede mock Firebase + Hive)
  - **Test da creare**:
    - **Local storage (Hive)**:
      - CRUD operations (Create, Read, Update, Delete)
      - Batch operations
      - Transaction safety
      - Error handling con Hive unavailable
    - **Cloud sync (Firebase)**:
      - Sync premium users only
      - Conflict resolution (local vs remote)
      - Offline-first behavior
      - Retry logic con network errors
    - **Hybrid logic**:
      - Free users → local only
      - Premium users → local + cloud
      - Fallback local quando cloud fails
  - **Mock richiesti**:
    - `HiveWorkoutDataSource` (mock Hive)
    - `FirebaseWorkoutDataSource` (fake_cloud_firestore)
    - `FirebaseAuth` (mocktail)
    - `UserProfile` con tier detection

- [ ] **`workout_sync_service.dart`** 🔴 PRIORITÀ #5
  - **Perché**: Sincronizzazione dati Firebase - se fallisce, dati persi
  - **Rischio**: Sync conflicts, data loss, infinite retry loops
  - **Effort**: 3h
  - **Test da creare**:
    - Sync strategies (full sync, incremental, conflict resolution)
    - Retry logic con exponential backoff
    - Conflict detection (lastModified timestamps)
    - Network error handling (offline queue)
    - Background sync scheduling
  - **Mock richiesti**: Firebase, connectivity status

---

## 🟡 FASE 2: ALTO (2-3 giorni)

**Impact**: Alto | **Effort**: 11-13 ore

### Domain Services (Analytics & Cache)

- [ ] **`workout_suggestion_analytics.dart`** 🟡 PRIORITÀ #6
  - **Perché**: Analytics per suggerimenti workout (feature killer app)
  - **Effort**: 2h
  - **Test da creare**:
    - Pattern detection su storico workout
    - Calcolo metriche (frequency, volume, intensity)
    - Confidence scoring per suggerimenti
    - Recovery time integration

- [ ] **`workout_template_cache_service.dart`** 🟡 PRIORITÀ #7
  - **Perché**: Cache template → performance critica (evita query ripetute)
  - **Effort**: 1h
  - **Test da creare**:
    - Cache hit/miss
    - TTL (time to live) invalidation
    - Memory management
    - Cache size limits

### Data Layer (Template & History)

- [ ] **`workout_history_service.dart`** 🟡 PRIORITÀ #8
  - **Perché**: Storico + analytics → calcoli PR, volumi, progressi
  - **Effort**: 2h
  - **Test da creare**:
    - PR detection (1RM, volume, intensity records)
    - Progress calculations (volume trend, strength gain)
    - Time-series aggregations (weekly/monthly stats)
    - Exercise-specific history

- [ ] **`workout_template_repository.dart`** 🟡 PRIORITÀ #9
  - **Perché**: CRUD template personalizzati utente
  - **Effort**: 2h
  - **Test da creare**:
    - Create/Read/Update/Delete template
    - Template validation (required fields)
    - Duplicate detection
    - User-specific filtering

- [ ] **`firebase_workout_template_repository.dart`** 🟡 PRIORITÀ #10
  - **Perché**: Cloud sync template (premium feature)
  - **Effort**: 2h
  - **Test da creare**:
    - Upload/download template
    - Conflict resolution
    - Sharing template tra dispositivi
    - Premium tier validation

- [ ] **`workout_draft_repository.dart`** 🟡 PRIORITÀ #11
  - **Perché**: Auto-save bozze → recovery da crash/kill app
  - **Effort**: 2h
  - **Test da creare**:
    - Auto-save on changes (debounced)
    - Recovery on app restart
    - Draft expiration (cleanup old drafts)
    - Multiple draft management

---

## 🟢 FASE 3: MEDIO (3-4 giorni)

**Impact**: Medio | **Effort**: 15-18 ore

### Presentation Providers (UI State Critical)

- [ ] **`intelligent_workout_suggestion_provider.dart`**
  - **Effort**: 2h
  - Suggerimenti AI workout basati su pattern/recovery

- [ ] **`workout_template_provider.dart`**
  - **Effort**: 2h
  - State management template UI

- [ ] **`workout_history_provider.dart`**
  - **Effort**: 1.5h
  - State management storico UI

- [ ] **`recovery_provider.dart`**
  - **Effort**: 1.5h
  - Recovery status tracking UI

### Domain Services (Utility)

- [ ] `weight_recovery_service.dart`
  - **Effort**: 1h
  - Recovery peso post-deload

- [ ] `exercise_compatibility_service.dart`
  - **Effort**: 1h
  - Compatibilità esercizi in superset

### Data Repositories (Minori)

- [ ] `json_preset_repository.dart`
  - **Effort**: 1h
  - Preset statici da JSON

- [ ] `workout_repository_impl.dart`
  - **Effort**: 1.5h
  - Implementazione base repository

- [ ] `exercise_activity_repository.dart`
  - **Effort**: 1h
  - Tracciamento attività esercizi

- [ ] `hybrid_exercise_activity_repository.dart`
  - **Effort**: 1.5h
  - Hybrid tracking esercizi

### Presentation Providers (Minori)

- [ ] `exercise_suggestion_provider.dart` - 1h
- [ ] `previous_workout_provider.dart` - 1h
- [ ] `add_exercise_provider.dart` - 1h
- [ ] `exercise_gif_provider.dart` - 0.5h
- [ ] `screen_wakelock_provider.dart` - 0.5h
- [ ] `set_duration_tracker_provider.dart` - 1h
- [ ] `zen_mode_provider.dart` - 0.5h
- [ ] `template_onboarding_provider.dart` - 0.5h

---

## 🔧 FASE 4: FIX ESISTENTI

### Fix Test Falliti (30 min)

- [ ] **Fix 7 CSV import tests** in `workout_import_service_test.dart`
  - **Problema**: CSV parsing con indentazione/formatting
  - **Fix**: Rimuovere spazi leading dalle stringhe CSV nei test

---

## 📐 TEMPLATE TEST PATTERNS

### Pattern 1: Domain Service Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/SERVICE_NAME.dart';

void main() {
  late ServiceName service;

  setUp(() {
    service = ServiceName();
  });

  group('ServiceName', () {
    test('should do expected behavior', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

### Pattern 2: Repository Test (con Firebase Mock)
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockHiveDataSource extends Mock implements HiveWorkoutDataSource {}

void main() {
  late Repository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    repository = Repository(
      firestore: fakeFirestore,
      auth: mockAuth,
      localDataSource: MockHiveDataSource(),
    );
  });

  test('should save to local and cloud', () async {
    // Test implementation
  });
}
```

### Pattern 3: Provider Test (con Riverpod)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        // Mock dependencies
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('should update state correctly', () {
    final provider = container.read(myProvider);
    // Test state changes
  });
}
```

---

## 🎯 OBIETTIVI COVERAGE

| Fase | Coverage Target | Timeframe |
|------|-----------------|-----------|
| Baseline | **27.7%** | ✅ Oggi |
| Fase 1 | **45%** | +2-3 giorni |
| Fase 2 | **60%** | +2-3 giorni |
| Fase 3 | **70%+** | +3-4 giorni |

**Totale effort stimato**: ~40 ore (5 giorni full-time o 10 giorni part-time)

---

## 📝 NOTE IMPORTANTI

### Problemi Noti
1. **APRE calculation service** richiede mock complesso di `Riverpod Ref`
2. **Hybrid repository** richiede sia Hive che Firebase mocks
3. **CSV import tests** hanno problemi di formatting da fixare

### Best Practices
- ✅ Usa `mocktail` per mocking (preferito vs mockito)
- ✅ Usa `fake_cloud_firestore` per Firebase tests
- ✅ Arrange-Act-Assert pattern in tutti i test
- ✅ Test naming: `should [expected behavior] when [condition]`
- ✅ Group related tests con `group()`
- ✅ Cleanup in `tearDown()` (dispose containers/mocks)

### Dependencies Richieste
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  fake_cloud_firestore: ^2.5.0
  integration_test:
    sdk: flutter
```

---

## 🚀 QUICK START

### Per iniziare subito:
```bash
# 1. Fix test falliti
flutter test test/features/workout/domain/services/workout_import_service_test.dart

# 2. Inizia FASE 1 - Test APRE
flutter test test/features/workout/domain/services/apre_calculation_service_test.dart

# 3. Verifica coverage
flutter test test/features/workout/ --coverage
```

### Per vedere progress:
```bash
# Test count
find test/features/workout -name "*_test.dart" | wc -l

# Coverage report
lcov --summary coverage/lcov.info
```

---

**🎯 Prossimo step**: Iniziare con `apre_calculation_service_test.dart` (FASE 1, Priorità #1)
