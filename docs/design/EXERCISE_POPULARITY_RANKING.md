# Exercise Popularity Ranking System - Design Document

**Data**: 2026-02-10
**Status**: Design Validato
**Strategia**: Data Bundles (Cloud Functions + Firebase Storage)

---

## Executive Summary

Sistema di ranking basato su popolarità globale per la ricerca esercizi. Gli esercizi più utilizzati dagli utenti ottengono un boost nei risultati di ricerca, migliorando l'UX per nuovi utenti che beneficiano delle scelte della community.

**Obiettivo**: Se 3 utenti su 4 cercano "squat" e selezionano "Squat Full Bilanciere", il quinto utente vedrà questo esercizio come primo risultato.

**Architettura**: Cloud Functions genera bundle giornaliero dei popularity counts → Storage hosting → Flutter scarica e cachea localmente → Zero latency durante ricerca.

**Costi stimati**: ~$0.03/mese (1000 utenti attivi/giorno)

---

## 1. Architettura Generale

### Componenti

```
┌──────────────────────────────────────────────────────────┐
│ CLOUD (Automatico ogni 24h)                             │
├──────────────────────────────────────────────────────────┤
│ Cloud Function (generatePopularityBundle)                │
│ ├─ Trigger: Firebase Scheduler (3am UTC+1)              │
│ ├─ Legge: /exercise_popularity/* (Firestore)            │
│ ├─ Genera: Firestore Data Bundle                        │
│ └─ Upload: /bundles/latest.bundle (Storage)             │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ CLIENT (Flutter App)                                     │
├──────────────────────────────────────────────────────────┤
│ ExercisePopularityBundleService                          │
│ ├─ Download: Bundle da Storage (1x/giorno)              │
│ ├─ Load: firestore.loadBundle()                          │
│ └─ Cache: Hive per offline access                       │
├──────────────────────────────────────────────────────────┤
│ ExerciseSearchService                                    │
│ ├─ Fuzzy matching (esistente)                           │
│ ├─ Applica boost popolarità                             │
│ └─ Ordina per score finale                              │
└──────────────────────────────────────────────────────────┘
```

### Data Flow

**Incremento popolarità (quando utente salva template):**
```
1. WorkoutTemplateRepository.saveTemplate()
2. Cloud Function trigger onTemplateCreated
3. Batch update Firestore: /exercise_popularity/{exerciseId}.count += 1
```

**Sincronizzazione cache (1x/giorno o al login):**
```
1. ExercisePopularityBundleService.syncPopularityData()
2. Download bundle da Storage
3. firestore.loadBundle()
4. Query named query "exercise_popularity"
5. Cache risultati in Hive
```

**Ricerca con boost (ogni search):**
```
1. User digita query
2. ExerciseSearchService.searchExercises()
3. Fuzzy matching → risultati rilevanti
4. Legge popularity da Hive cache
5. Applica boost factor
6. Ordina per score finale
```

---

## 2. Data Model

### Firestore Collection

**Path**: `/exercise_popularity/{exerciseId}`

```json
{
  "count": 142,
  "lastUpdated": "2026-02-10T14:30:00Z"
}
```

**Indexes**: Nessuno richiesto (query semplice by document ID)

**Security Rules**:
```javascript
match /exercise_popularity/{exerciseId} {
  allow read: if request.auth != null; // Tutti gli utenti autenticati
  allow write: if false; // Solo Cloud Functions
}
```

---

### Hive Cache (Local)

**Box name**: `exercise_popularity`

**HiveType ID**: 15 (next available)

```dart
@HiveType(typeId: 15)
class ExercisePopularityHiveModel {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  final int count;

  @HiveField(2)
  final DateTime lastUpdated;
}
```

**TTL**: 24 ore (soft expiration, non auto-delete)

---

### Domain Entity

```dart
// lib/shared/domain/entities/exercise_popularity_data.dart

@freezed
class ExercisePopularityData with _$ExercisePopularityData {
  const factory ExercisePopularityData({
    required String exerciseId,
    required int count,
    required DateTime lastUpdated,
  }) = _ExercisePopularityData;

  factory ExercisePopularityData.fromJson(Map<String, dynamic> json) =>
      _$ExercisePopularityDataFromJson(json);
}
```

---

## 3. Backend Implementation (Cloud Functions)

### Setup Cloud Functions

**Directory structure**:
```
functions/
├── package.json
├── index.js
└── src/
    ├── scheduled/
    │   └── generatePopularityBundle.js
    └── triggers/
        └── onTemplateCreated.js
```

**Dependencies (package.json)**:
```json
{
  "name": "fitlog-functions",
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0"
  },
  "engines": {
    "node": "18"
  }
}
```

---

### Cloud Function: Generate Bundle (Scheduled)

**File**: `functions/src/scheduled/generatePopularityBundle.js`

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { firestore } = admin;

exports.generatePopularityBundle = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '1GB'
  })
  .pubsub.schedule('0 3 * * *') // Ogni giorno alle 3am UTC
  .timeZone('Europe/Rome')
  .onRun(async (context) => {
    const db = admin.firestore();
    const storage = admin.storage();

    try {
      // 1. Fetch tutti i popularity counts
      const popularitySnapshot = await db
        .collection('exercise_popularity')
        .get();

      console.log(`Fetched ${popularitySnapshot.size} popularity documents`);

      // 2. Crea bundle
      const bundleId = `popularity_${new Date().toISOString().split('T')[0]}`;
      const bundle = firestore.bundle(bundleId);

      // Aggiungi query al bundle con nome
      bundle.add('exercise_popularity', popularitySnapshot.query);

      // 3. Converte bundle in buffer
      const bundleBuffer = bundle.build();

      // 4. Upload a Storage
      const bucket = storage.bucket();
      const file = bucket.file('bundles/latest.bundle');

      await file.save(bundleBuffer, {
        contentType: 'application/firestore-bundle',
        metadata: {
          cacheControl: 'public, max-age=86400', // Cache 24h
          customMetadata: {
            generatedAt: new Date().toISOString(),
            documentCount: String(popularitySnapshot.size),
            bundleId: bundleId,
          },
        },
      });

      console.log(`✅ Bundle generated successfully: ${bundleId}`);
      console.log(`   Documents: ${popularitySnapshot.size}`);
      console.log(`   Size: ${bundleBuffer.length} bytes`);

      return null;

    } catch (error) {
      console.error('❌ Bundle generation failed:', error);
      throw error;
    }
  });
```

**Cron schedule**: `0 3 * * *` = Ogni giorno alle 3am (orario con basso traffico)

**Resources**: 1GB RAM, 540s timeout (sufficiente per 10k+ esercizi)

---

### Cloud Function: Increment Popularity (Firestore Trigger)

**File**: `functions/src/triggers/onTemplateCreated.js`

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.onTemplateCreated = functions.firestore
  .document('workout_templates/{templateId}')
  .onCreate(async (snap, context) => {
    const template = snap.data();
    const exercises = template.exercises || [];

    if (exercises.length === 0) {
      console.log('Template has no exercises, skipping popularity update');
      return null;
    }

    const db = admin.firestore();
    const batch = db.batch();

    // Incrementa popularity per ogni esercizio
    exercises.forEach((exercise) => {
      const popularityRef = db
        .collection('exercise_popularity')
        .doc(exercise.exerciseId);

      batch.set(
        popularityRef,
        {
          count: admin.firestore.FieldValue.increment(1),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    });

    try {
      await batch.commit();
      console.log(`✅ Incremented popularity for ${exercises.length} exercises`);
      return null;
    } catch (error) {
      console.error('❌ Popularity increment failed:', error);
      // Non throw: non vogliamo bloccare il save del template
      return null;
    }
  });
```

**Trigger**: `onCreate` su `workout_templates/{templateId}`

**Batch write**: Incremento atomico per tutti gli esercizi del template

**Error handling**: Log ma non throw (template save non deve fallire)

---

### Deploy Cloud Functions

```bash
# Setup Firebase CLI
npm install -g firebase-tools
firebase login

# Navigate to functions directory
cd functions
npm install

# Deploy
firebase deploy --only functions

# Verify deployment
firebase functions:log
```

---

## 4. Flutter Client Implementation

### Service: Cache Manager

**File**: `lib/shared/data/services/exercise_popularity_cache.dart`

```dart
import 'package:hive/hive.dart';

class ExercisePopularityCache {
  static const String _boxName = 'exercise_popularity';
  static const Duration _cacheDuration = Duration(days: 1);

  Box<ExercisePopularityHiveModel>? _box;

  /// Initialize Hive box
  Future<void> init() async {
    if (_box != null) return; // Already initialized
    _box = await Hive.openBox<ExercisePopularityHiveModel>(_boxName);
  }

  /// Get popularity count for exercise
  int getPopularity(String exerciseId) {
    try {
      final data = _box?.get(exerciseId);
      if (data == null) return 0;

      // Check cache expiration
      if (DateTime.now().difference(data.lastUpdated) > _cacheDuration) {
        return 0; // Expired, return default
      }

      return data.count;
    } catch (e) {
      // Graceful degradation: return 0 on any error
      return 0;
    }
  }

  /// Update cache with batch data
  Future<void> updateBatch(List<ExercisePopularityData> popularityData) async {
    if (_box == null) return;

    final entries = <String, ExercisePopularityHiveModel>{};

    for (final data in popularityData) {
      entries[data.exerciseId] = ExercisePopularityHiveModel(
        exerciseId: data.exerciseId,
        count: data.count,
        lastUpdated: data.lastUpdated,
      );
    }

    await _box!.putAll(entries);
  }

  /// Check if cache needs sync
  bool needsSync() {
    if (_box == null || _box!.isEmpty) return true;

    // Find oldest update timestamp
    final timestamps = _box!.values.map((e) => e.lastUpdated);
    if (timestamps.isEmpty) return true;

    final oldestUpdate = timestamps.reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );

    return DateTime.now().difference(oldestUpdate) > _cacheDuration;
  }

  /// Clear all cache
  Future<void> clear() async {
    await _box?.clear();
  }

  /// Close box
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
```

---

### Service: Bundle Sync

**File**: `lib/shared/data/services/exercise_popularity_bundle_service.dart`

```dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExercisePopularityBundleService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ExercisePopularityCache _cache;

  static const String _bundlePath = 'bundles/latest.bundle';
  static const String _lastDownloadKey = 'popularity_bundle_last_download';

  ExercisePopularityBundleService({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required ExercisePopularityCache cache,
  })  : _firestore = firestore,
        _storage = storage,
        _cache = cache;

  /// Sync popularity data from bundle
  Future<void> syncPopularityData() async {
    // Check if download is needed
    if (!await _needsDownload()) {
      debugPrint('Popularity bundle: Cache still fresh, skipping download');
      return;
    }

    try {
      debugPrint('Popularity bundle: Starting download...');

      // 1. Download bundle from Storage
      final ref = _storage.ref(_bundlePath);
      final bundleData = await ref.getData();

      if (bundleData == null) {
        debugPrint('Popularity bundle: Not found in Storage');
        return;
      }

      debugPrint('Popularity bundle: Downloaded ${bundleData.length} bytes');

      // 2. Load bundle into Firestore local cache
      final loadBundleTask = _firestore.loadBundle(bundleData);

      // Wait for completion
      await loadBundleTask.stream.last;

      debugPrint('Popularity bundle: Loaded into Firestore');

      // 3. Query the named query from bundle
      final namedQuery = await _firestore.namedQueryGet('exercise_popularity');

      if (namedQuery == null) {
        debugPrint('Popularity bundle: Named query not found');
        return;
      }

      final snapshot = await namedQuery.get();

      if (snapshot.docs.isEmpty) {
        debugPrint('Popularity bundle: No documents in query result');
        return;
      }

      debugPrint('Popularity bundle: Queried ${snapshot.docs.length} documents');

      // 4. Convert to domain entities and cache in Hive
      final popularityData = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ExercisePopularityData(
          exerciseId: doc.id,
          count: data['count'] as int? ?? 0,
          lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate()
              ?? DateTime.now(),
        );
      }).toList();

      await _cache.updateBatch(popularityData);

      // 5. Save download timestamp
      await _saveDownloadTimestamp();

      debugPrint('✅ Popularity bundle synced: ${popularityData.length} exercises');

    } catch (e, stackTrace) {
      debugPrint('❌ Popularity bundle sync failed: $e');
      debugPrint(stackTrace.toString());
      // Graceful degradation: app uses existing cache
    }
  }

  /// Check if download is needed based on TTL
  Future<bool> _needsDownload() async {
    final lastDownload = await _getLastDownloadTimestamp();

    if (lastDownload == null) return true;

    final daysSinceDownload = DateTime.now().difference(lastDownload).inDays;
    return daysSinceDownload >= 1;
  }

  /// Get last download timestamp from SharedPreferences
  Future<DateTime?> _getLastDownloadTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastDownloadKey);

    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Save current timestamp as last download
  Future<void> _saveDownloadTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastDownloadKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Force sync (for debug/admin)
  Future<void> forceSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastDownloadKey);
    await syncPopularityData();
  }
}
```

---

### Modifiche a ExerciseSearchService

**File**: `lib/features/exercise_database/domain/services/exercise_search_service.dart`

**Aggiunte necessarie:**

```dart
class ExerciseSearchService {
  final ExercisePopularityCache _popularityCache;

  // Constructor modificato
  ExerciseSearchService({
    required ExercisePopularityCache popularityCache,
  }) : _popularityCache = popularityCache;

  // ... codice esistente ...

  Future<List<ExerciseTemplate>> searchExercises(
    String query,
    Locale locale,
  ) async {
    await loadExercises(locale);

    // Fuzzy matching (già esistente)
    final fuzzyResults = _orderAgnosticSearch(query);

    // ✨ NUOVO: Applica boost popolarità
    final boostedResults = _applyPopularityBoost(fuzzyResults);

    // Ordina per score finale
    boostedResults.sort((a, b) => b.score.compareTo(a.score));

    return boostedResults.map((r) => r.exercise).toList();
  }

  /// Applica boost popolarità ai risultati fuzzy
  List<_ScoredExercise> _applyPopularityBoost(
    List<_ScoredExercise> fuzzyResults,
  ) {
    return fuzzyResults.map((result) {
      final exerciseId = result.exercise.id;
      final popularityCount = _popularityCache.getPopularity(exerciseId);

      // Calcola boost factor
      final boostFactor = _calculateBoostFactor(popularityCount);

      // Applica boost
      final boostedScore = result.score * boostFactor;

      return _ScoredExercise(
        exercise: result.exercise,
        score: boostedScore,
      );
    }).toList();
  }

  /// Calcola boost factor in base a popolarità
  ///
  /// Formula progressiva:
  /// - 0-10 utilizzi: 1.0x (nessun boost)
  /// - 11-50: 1.0-1.15x (boost leggero)
  /// - 51-100: 1.15-1.25x (boost medio)
  /// - 100+: 1.25-1.5x (boost alto, cappato)
  double _calculateBoostFactor(int popularityCount) {
    if (popularityCount <= 10) return 1.0;

    if (popularityCount <= 50) {
      // Linear interpolation: 1.0 -> 1.15
      return 1.0 + (popularityCount - 10) * 0.00375;
    }

    if (popularityCount <= 100) {
      // Linear interpolation: 1.15 -> 1.25
      return 1.15 + (popularityCount - 50) * 0.002;
    }

    // Cap massimo a 1.5x per evitare dominanza assoluta
    final uncapped = 1.25 + (popularityCount - 100) * 0.0025;
    return uncapped.clamp(1.25, 1.5);
  }
}
```

---

### Riverpod Providers

**File**: `lib/shared/presentation/providers/exercise_popularity_provider.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider per cache locale
final exercisePopularityCacheProvider = Provider<ExercisePopularityCache>((ref) {
  return ExercisePopularityCache();
});

/// Provider per bundle service
final exercisePopularityBundleServiceProvider =
    Provider<ExercisePopularityBundleService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final cache = ref.watch(exercisePopularityCacheProvider);

  return ExercisePopularityBundleService(
    firestore: firestore,
    storage: storage,
    cache: cache,
  );
});

/// Provider per triggare sync manuale (debug/admin)
final syncPopularityProvider = FutureProvider.autoDispose<void>((ref) async {
  final service = ref.watch(exercisePopularityBundleServiceProvider);
  await service.syncPopularityData();
});

/// Provider per check se cache è stale
final popularityCacheNeedsSyncProvider = Provider<bool>((ref) {
  final cache = ref.watch(exercisePopularityCacheProvider);
  return cache.needsSync();
});
```

**Modificare provider esistente:**

**File**: `lib/features/exercise_database/presentation/providers/exercise_search_provider.dart`

```dart
// Aggiungere dipendenza da popularity cache
final exerciseSearchServiceProvider = Provider<ExerciseSearchService>((ref) {
  final locale = ref.watch(localeProvider);
  final popularityCache = ref.watch(exercisePopularityCacheProvider);

  final service = ExerciseSearchService(
    popularityCache: popularityCache,
  );
  service.loadExercises(locale);

  return service;
});
```

---

### App Initialization

**File**: `lib/main.dart`

```dart
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init (già esistente)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive init (già esistente)
  await Hive.initFlutter();

  // ✨ NUOVO: Registra adapter popolarità
  Hive.registerAdapter(ExercisePopularityHiveModelAdapter());

  // ✨ NUOVO: Inizializza popularity system
  await _initPopularitySystem();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> _initPopularitySystem() async {
  try {
    // 1. Apri Hive box per cache
    final cache = ExercisePopularityCache();
    await cache.init();

    // 2. Sync bundle in background (non blocca startup)
    final service = ExercisePopularityBundleService(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
      cache: cache,
    );

    // Fire-and-forget: non aspettare completamento
    unawaited(service.syncPopularityData());

  } catch (e) {
    // Fallback: app funziona comunque senza boost
    debugPrint('Popularity system init failed: $e');
  }
}
```

---

## 5. Testing Strategy

### Unit Tests

**File**: `test/shared/data/services/exercise_popularity_bundle_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockExercisePopularityCache mockCache;
  late ExercisePopularityBundleService service;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockCache = MockExercisePopularityCache();

    service = ExercisePopularityBundleService(
      firestore: mockFirestore,
      storage: mockStorage,
      cache: mockCache,
    );
  });

  group('syncPopularityData', () {
    test('downloads and caches bundle successfully', () async {
      // Arrange
      final mockBundle = Uint8List.fromList([1, 2, 3]);
      when(mockStorage.ref(any).getData()).thenAnswer((_) async => mockBundle);

      final mockSnapshot = MockQuerySnapshot();
      when(mockSnapshot.docs).thenReturn([
        MockDocumentSnapshot('squat_full', {'count': 100}),
        MockDocumentSnapshot('bench_press', {'count': 80}),
      ]);

      when(mockFirestore.namedQueryGet(any))
          .thenAnswer((_) async => MockQuery(mockSnapshot));

      // Act
      await service.syncPopularityData();

      // Assert
      verify(mockCache.updateBatch(any)).called(1);
    });

    test('handles missing bundle gracefully', () async {
      // Arrange
      when(mockStorage.ref(any).getData()).thenAnswer((_) async => null);

      // Act & Assert (no exception thrown)
      await service.syncPopularityData();

      verifyNever(mockCache.updateBatch(any));
    });

    test('respects 24h TTL', () async {
      // Test implementation...
    });
  });
}
```

---

### Integration Test

**File**: `integration_test/exercise_popularity_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Exercise search reflects popularity', (tester) async {
    // 1. Setup: Login utente
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // ... login flow ...

    // 2. Crea template con "Squat Full Bilanciere"
    // ... navigation to template creation ...
    // ... add exercise flow ...

    await tester.tap(find.text('Squat Full Bilanciere'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salva Template'));
    await tester.pumpAndSettle();

    // 3. Wait per Cloud Function trigger (simula)
    await Future.delayed(Duration(seconds: 2));

    // 4. Force sync bundle
    // ... trigger sync via debug menu ...

    // 5. Search "squat"
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'squat');
    await tester.pumpAndSettle();

    // 6. Verify "Squat Full Bilanciere" è primo risultato
    final firstResult = find.byType(ExerciseListTile).first;
    expect(
      tester.widget<ExerciseListTile>(firstResult).exercise.name,
      contains('Squat Full Bilanciere'),
    );
  });
}
```

---

### Manual Testing Checklist

- [ ] Cloud Function deploys correttamente
- [ ] Scheduled function esegue alle 3am
- [ ] Bundle viene generato in Storage
- [ ] Bundle size è ragionevole (~100KB per 1000 esercizi)
- [ ] App scarica bundle al primo avvio
- [ ] Cache Hive viene popolata
- [ ] Ricerca mostra boost per esercizi popolari
- [ ] TTL 24h funziona (no re-download prima di 24h)
- [ ] Graceful degradation se bundle manca
- [ ] Template save incrementa popolarità
- [ ] Firestore security rules bloccano write diretti

---

## 6. Monitoring e Analytics

### Firebase Console

**Cloud Functions logs:**
```bash
# View logs
firebase functions:log

# Filter per generatePopularityBundle
firebase functions:log --only generatePopularityBundle

# Filter per onTemplateCreated
firebase functions:log --only onTemplateCreated
```

**Storage usage:**
- Path: `/bundles/latest.bundle`
- Expected size: ~100KB per 1000 esercizi
- Monitor growth mensile

**Firestore usage:**
- Collection: `/exercise_popularity`
- Monitor document count (dovrebbe crescere con nuovi esercizi custom)
- Monitor write operations (ogni template save)

---

### Analytics Events

**Tracciare in app:**

```dart
// Quando bundle viene sincronizzato
FirebaseAnalytics.instance.logEvent(
  name: 'popularity_bundle_synced',
  parameters: {
    'document_count': popularityData.length,
    'download_duration_ms': downloadTime.inMilliseconds,
  },
);

// Quando boost viene applicato
FirebaseAnalytics.instance.logEvent(
  name: 'exercise_popularity_boosted',
  parameters: {
    'exercise_id': exerciseId,
    'boost_factor': boostFactor,
    'original_score': fuzzyScore,
    'final_score': boostedScore,
  },
);
```

---

### Dashboard Metrics

**KPIs da monitorare:**

| Metric | Target | Alert |
|--------|--------|-------|
| Bundle generation success rate | >99% | <95% |
| Bundle size | <200KB | >500KB |
| Client sync success rate | >95% | <90% |
| Avg download time | <2s | >5s |
| Cache hit rate | >99% | <90% |
| Cloud Function cost | <$1/mese | >$5/mese |
| Storage cost | <$0.01/mese | >$0.10/mese |

---

## 7. Deployment Plan

### Phase 1: Backend Setup (Day 1)

1. **Setup Cloud Functions project**
   ```bash
   firebase init functions
   cd functions
   npm install
   ```

2. **Implementa functions**
   - `generatePopularityBundle.js`
   - `onTemplateCreated.js`

3. **Configure Firebase Scheduler**
   - Schedule: `0 3 * * *` (3am daily)
   - Timezone: Europe/Rome

4. **Deploy**
   ```bash
   firebase deploy --only functions
   ```

5. **Verify**
   - Check logs per errori
   - Trigger manuale `generatePopularityBundle`
   - Verify bundle creato in Storage

---

### Phase 2: Client Implementation (Day 2-3)

1. **Crea entities e adapters**
   - `ExercisePopularityData` (domain)
   - `ExercisePopularityHiveModel` (adapter)

2. **Implementa services**
   - `ExercisePopularityCache`
   - `ExercisePopularityBundleService`

3. **Modifica ExerciseSearchService**
   - Aggiungi `_applyPopularityBoost()`
   - Aggiungi `_calculateBoostFactor()`

4. **Setup providers**
   - `exercisePopularityCacheProvider`
   - `exercisePopularityBundleServiceProvider`

5. **Modifica main.dart**
   - Registra Hive adapter
   - Chiama `_initPopularitySystem()`

---

### Phase 3: Testing (Day 4)

1. **Unit tests**
   - `ExercisePopularityCache` tests
   - `ExercisePopularityBundleService` tests
   - `ExerciseSearchService` boost tests

2. **Integration tests**
   - Full flow: save → increment → sync → search

3. **Manual testing**
   - Checklist completo (vedi sezione Testing)

---

### Phase 4: Gradual Rollout (Day 5-7)

1. **Deploy a staging**
   - Test con utenti interni
   - Verify logs e metrics

2. **Monitor per 48h**
   - Cloud Function execution
   - Storage costs
   - Client sync success rate

3. **Deploy a production**
   - Feature flag: `enable_popularity_ranking`
   - Rollout graduale: 10% → 50% → 100%

4. **Monitor post-release**
   - Search relevance feedback
   - Performance impact
   - Cost actuals vs estimates

---

## 8. Cost Analysis

### Estimated Monthly Costs (1000 active users/day)

| Component | Unit Cost | Usage | Monthly Cost |
|-----------|-----------|-------|--------------|
| **Cloud Functions** | | | |
| generatePopularityBundle | $0 | 30 invocations | $0 (tier gratuito) |
| onTemplateCreated | $0 | ~3k invocations | $0 (tier gratuito) |
| **Firebase Storage** | | | |
| Bundle storage | $0.026/GB | 100KB × 1 file | $0.000003 |
| Bundle downloads | $0.12/GB | 100KB × 30k downloads | $0.36 |
| **Firestore** | | | |
| Popularity reads (bundle gen) | $0.036/100k | 30 × 1k docs | $0.011 |
| Popularity writes (increments) | $0.108/100k | ~10k writes | $0.011 |
| **TOTAL** | | | **~$0.38/mese** |

**Note**:
- Cloud Functions tier gratuito: 2M invocations/mese
- Storage tier gratuito: 5GB storage, 1GB download/day
- Con tier gratuito Storage: **$0.02/mese** totale

---

### Comparison con Strategia B (Batch Query)

| Strategia | Monthly Cost | Performance | Complexity |
|-----------|--------------|-------------|------------|
| **A - Individual queries** | $18/mese | Lento (30s) | Semplice |
| **B - Batch query** | $5/mese | Veloce (1s) | Semplice |
| **C - Data Bundles** | $0.38/mese | Velocissimo (<100ms) | Medio |

**Risparmio C vs B**: 92.4%
**Risparmio C vs A**: 97.9%

---

## 9. Rollback Plan

### Scenario: Bundle generation fallisce

**Impatto**: Nessuno (app usa cache esistente)

**Azione**: Nessuna urgente, fix function e re-deploy

---

### Scenario: Sync bundle causa crash app

**Impatto**: App crash al login per alcuni utenti

**Azione immediata**:
1. Feature flag OFF: `enable_popularity_ranking = false`
2. App usa solo fuzzy matching (nessun boost)
3. Hotfix e re-deploy

**Rollback code:**
```dart
// In ExerciseSearchService
Future<List<ExerciseTemplate>> searchExercises(...) async {
  final fuzzyResults = _orderAgnosticSearch(query);

  // Feature flag check
  if (!ref.read(featureFlagsProvider).enablePopularityRanking) {
    return fuzzyResults.map((r) => r.exercise).toList(); // No boost
  }

  final boostedResults = _applyPopularityBoost(fuzzyResults);
  // ...
}
```

---

### Scenario: Costi inaspettati (>$10/mese)

**Azione**:
1. Disable scheduled function
2. Analizza Firebase billing dashboard
3. Identifica componente costoso
4. Ottimizza o rollback

---

## 10. Future Optimizations

### v2.0: Personalized Boost (Ibrido)

Combinare popolarità globale + preferenze utente:

```dart
double _calculateBoostFactor(
  int globalPopularity,
  int userUsageCount,
) {
  final globalBoost = _globalBoostFactor(globalPopularity);
  final personalBoost = _personalBoostFactor(userUsageCount);

  // Weighted average: 70% globale, 30% personale
  return (globalBoost * 0.7) + (personalBoost * 0.3);
}
```

**Pro**: Migliore UX per utenti esistenti
**Contro**: Più complesso, serve tracciare usage personale

---

### v2.1: Category-Specific Popularity

Tracciare popolarità per categoria:

```
/exercise_popularity/{exerciseId}/categories/{categoryId}
  - count: 50
```

Boost più forte se esercizio popolare nella categoria cercata.

---

### v2.2: Real-Time Bundle Updates

Invece di scheduled daily:
- Trigger bundle regeneration ogni 1000 template salvati
- O ogni 6 ore invece di 24h

**Pro**: Dati più freschi
**Contro**: Più costi Cloud Functions

---

## 11. Success Criteria

### Launch Criteria (Go/No-Go)

- [ ] Cloud Function esegue senza errori
- [ ] Bundle generato correttamente (size < 200KB)
- [ ] App scarica bundle senza crash
- [ ] Cache Hive popolata correttamente
- [ ] Boost applicato ai risultati search
- [ ] Unit tests pass al 100%
- [ ] Integration test pass
- [ ] Manual testing checklist completa
- [ ] Costi stimati verificati (<$1/mese)

---

### Post-Launch Metrics (dopo 1 settimana)

**Performance:**
- [ ] Bundle sync success rate >95%
- [ ] Search latency <500ms (p95)
- [ ] No crash increase

**Business:**
- [ ] Utenti cercano meno query (trovano al primo colpo)
- [ ] Esercizi popolari scelti più velocemente
- [ ] Feedback positivo su search relevance

**Cost:**
- [ ] Actual costs <$1/mese
- [ ] No unexpected spikes

---

### Long-Term Success (dopo 1 mese)

- [ ] Popolarità converge su esercizi "standard" (Squat, Panca, Stacchi)
- [ ] Nuovi utenti trovano esercizi comuni più facilmente
- [ ] Riduzione support tickets su "come trovo esercizio X"
- [ ] Sistema scala senza intervento manuale

---

## 12. References

### Firebase Documentation

- [Cloud Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Data Bundles Guide](https://firebase.blog/posts/2021/04/firestore-supports-data-bundles/)
- [Cloud Functions Scheduling](https://firebase.google.com/docs/functions/schedule-functions)
- [Firebase Storage Best Practices](https://firebase.google.com/docs/storage/best-practices)

### Performance Optimization

- [Reduce Firestore Costs via Local Cache](https://medium.com/@icutvaric/how-to-reduce-firestore-costs-via-local-cache-02c3f4ee8654)
- [Cut Costs by Reducing Reads](https://betterprogramming.pub/firebase-firestore-cut-costs-by-reducing-reads-edfccb538285)

### Codebase References

- `lib/features/exercise_database/domain/services/exercise_search_service.dart` - Fuzzy search implementation
- `lib/features/exercise_database/presentation/exercise_search_screen.dart` - Search UI
- `lib/features/workout/data/repositories/firebase_workout_template_repository.dart` - Template save logic

---

## Appendix A: Boost Formula Examples

### Calcolo Boost Factor

```
Popularity Count → Boost Factor

0:     1.00x (no boost)
5:     1.00x
10:    1.00x
15:    1.02x
25:    1.06x
40:    1.11x
50:    1.15x
75:    1.20x
100:   1.25x
150:   1.38x
200:   1.50x (cap)
500:   1.50x (cap)
```

### Esempi Pratici

**Scenario 1: Nuovo utente cerca "squat"**

| Esercizio | Fuzzy Score | Popularity | Boost | Final Score | Rank |
|-----------|-------------|------------|-------|-------------|------|
| Squat Full Bilanciere | 0.95 | 250 | 1.50x | 1.425 | 1️⃣ |
| Squat Bulgaro | 0.92 | 30 | 1.08x | 0.994 | 2️⃣ |
| Squat Goblet | 0.90 | 8 | 1.00x | 0.900 | 3️⃣ |

**Risultato**: Utente vede immediatamente "Squat Full Bilanciere" (scelta più comune).

---

**Scenario 2: Utente avanzato cerca "squat bulgaro unilaterale"**

| Esercizio | Fuzzy Score | Popularity | Boost | Final Score | Rank |
|-----------|-------------|------------|-------|-------------|------|
| Squat Bulgaro | 0.98 | 30 | 1.08x | 1.058 | 1️⃣ |
| Squat Full Bilanciere | 0.65 | 250 | 1.50x | 0.975 | 2️⃣ |

**Risultato**: Fuzzy matching vince, utente trova esercizio specifico cercato.

---

## Appendix B: File Checklist

### Nuovi File da Creare

**Backend (Cloud Functions):**
- [ ] `functions/package.json`
- [ ] `functions/index.js`
- [ ] `functions/src/scheduled/generatePopularityBundle.js`
- [ ] `functions/src/triggers/onTemplateCreated.js`

**Flutter (Domain):**
- [ ] `lib/shared/domain/entities/exercise_popularity_data.dart`
- [ ] `lib/shared/domain/entities/exercise_popularity_data.freezed.dart` (generated)
- [ ] `lib/shared/domain/entities/exercise_popularity_data.g.dart` (generated)

**Flutter (Data):**
- [ ] `lib/shared/data/adapters/exercise_popularity_hive_model.dart`
- [ ] `lib/shared/data/adapters/exercise_popularity_hive_model.g.dart` (generated)
- [ ] `lib/shared/data/services/exercise_popularity_cache.dart`
- [ ] `lib/shared/data/services/exercise_popularity_bundle_service.dart`

**Flutter (Presentation):**
- [ ] `lib/shared/presentation/providers/exercise_popularity_provider.dart`

**Tests:**
- [ ] `test/shared/data/services/exercise_popularity_cache_test.dart`
- [ ] `test/shared/data/services/exercise_popularity_bundle_service_test.dart`
- [ ] `test/features/exercise_database/domain/services/exercise_search_service_boost_test.dart`
- [ ] `integration_test/exercise_popularity_flow_test.dart`

---

### File da Modificare

- [ ] `lib/main.dart` - Add popularity system init
- [ ] `lib/features/exercise_database/domain/services/exercise_search_service.dart` - Add boost logic
- [ ] `lib/features/exercise_database/presentation/providers/exercise_search_provider.dart` - Inject cache
- [ ] `firestore.rules` - Add `/exercise_popularity` rules

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-10 | Initial design - Data Bundles strategy |

---

**Document Status**: ✅ Validated
**Ready for Implementation**: Yes
**Estimated Implementation Time**: 4-5 giorni
**Risk Level**: Low (graceful degradation su fallimenti)
