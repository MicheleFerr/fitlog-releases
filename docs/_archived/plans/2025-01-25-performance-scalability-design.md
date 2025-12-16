# Performance & Scalability - Design Document

**Generated**: 2025-01-25
**Source**: Web research + codebase analysis
**Complexity Score**: HIGH
**Total Tasks**: 18
**Estimated Time**: ~12h
**Plan Version**: 1.1
**Last Validated**: 2025-01-25 (Best Practices 2024/2025 ✅)

---

## 1. Overview

### Problemi Identificati

| Area | Problema | Impatto | Soluzione |
|------|----------|---------|-----------|
| **Workout History** | Carica TUTTI i workout in memoria (~10KB × N) | OOM su device con 500+ workout | Pagination server-side Firestore |
| **Analytics Cache** | Service è uno STUB (ritorna sempre `null`) | Ogni view ricalcola tutto | Implementazione reale con Hive + TTL |
| **Exercise Search** | Carica 400+ esercizi in memoria per ogni ricerca | Lag UI 200-400ms su cold start | Pre-cache + search indexing |

### Fonti Best Practices 2024-2025

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Firestore Pagination Guide](https://firebase.google.com/docs/firestore/query-data/query-cursors)
- [Riverpod Async Patterns](https://riverpod.dev/docs/essentials/side_effects)
- [Hive Caching Strategies](https://docs.hivedb.dev/)

---

## 2. Problema #1: Workout History Pagination

### 2.1 Stato Attuale (CRITICO)

**File**: `lib/features/workout/presentation/providers/workout_history_provider.dart`

```dart
// PROBLEMA: Linea 122 - Carica TUTTI i workout
final allWorkouts = await _dataSource.getWorkouts(_userId);
_allWorkouts = allWorkouts.map((model) => _mapWorkoutModelToEntity(model)).toList();

// Poi applica filtri/paginazione client-side (inutile!)
final filteredWorkouts = _applyFilters(_allWorkouts);
final paginatedWorkouts = _applyPagination(filteredWorkouts);
```

**Problemi**:
1. `_allWorkouts` contiene TUTTI i workout dell'utente
2. Paginazione è "fake" - dati già in memoria
3. Con 500+ workout → ~5MB+ memoria
4. Crash su device low-end

### 2.2 Soluzione: Cursor-Based Pagination (Firestore)

**Architettura**:

```
┌─────────────────────────────────────────────────────────────┐
│                    WorkoutHistoryProvider                   │
├─────────────────────────────────────────────────────────────┤
│ - currentPage: List<Workout> (solo pagina corrente)         │
│ - lastDocument: DocumentSnapshot? (cursor per next page)    │
│ - hasMore: bool (flag per infinite scroll)                  │
│ - isLoading: bool (prevent double fetch)                    │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│               WorkoutRepository (NEW METHOD)                │
├─────────────────────────────────────────────────────────────┤
│ Future<PaginatedResult<Workout>> getWorkoutsPaginated({     │
│   required String userId,                                   │
│   int pageSize = 20,                                        │
│   DocumentSnapshot? startAfter,                             │
│   WorkoutFilter? filter,                                    │
│ })                                                          │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     Firestore Query                          │
├─────────────────────────────────────────────────────────────┤
│ collection('workouts')                                      │
│   .where('userId', isEqualTo: userId)                       │
│   .orderBy('createdAt', descending: true)                   │
│   .startAfterDocument(cursor)  // cursor-based              │
│   .limit(pageSize)                                          │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Implementazione

**Nuovo file**: `lib/features/workout/domain/entities/paginated_result.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.lastDocument,
  });

  final List<T> items;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;

  PaginatedResult<T> copyWith({
    List<T>? items,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}
```

**Repository method** (aggiungere a `WorkoutRepository`):

```dart
Future<PaginatedResult<Workout>> getWorkoutsPaginated({
  required String userId,
  int pageSize = 20,
  DocumentSnapshot? startAfter,
  DateTime? dateFrom,
  DateTime? dateTo,
}) async {
  var query = _firestore
      .collection('workouts')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true);

  // Apply date filters
  if (dateFrom != null) {
    query = query.where('createdAt', isGreaterThanOrEqualTo: dateFrom);
  }
  if (dateTo != null) {
    query = query.where('createdAt', isLessThanOrEqualTo: dateTo);
  }

  // Cursor-based pagination
  if (startAfter != null) {
    query = query.startAfterDocument(startAfter);
  }

  // Fetch pageSize + 1 to check if more exist
  final snapshot = await query.limit(pageSize + 1).get();

  final hasMore = snapshot.docs.length > pageSize;
  final docs = hasMore
      ? snapshot.docs.sublist(0, pageSize)
      : snapshot.docs;

  final workouts = docs.map((doc) => Workout.fromFirestore(doc)).toList();

  return PaginatedResult(
    items: workouts,
    hasMore: hasMore,
    lastDocument: docs.isNotEmpty ? docs.last : null,
  );
}
```

**Provider refactored** (AsyncNotifier pattern):

```dart
@riverpod
class WorkoutHistoryNotifier extends _$WorkoutHistoryNotifier {
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  @override
  Future<List<Workout>> build() async {
    // Initial load
    final result = await _loadPage();
    return result.items;
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || state.isLoading) return;

    state = const AsyncValue.loading();

    final result = await _loadPage(startAfter: _lastDocument);

    final currentWorkouts = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentWorkouts, ...result.items]);
  }

  Future<PaginatedResult<Workout>> _loadPage({DocumentSnapshot? startAfter}) async {
    final repository = ref.read(workoutRepositoryProvider);
    final userId = ref.read(userIdProvider);

    final result = await repository.getWorkoutsPaginated(
      userId: userId!,
      pageSize: 20,
      startAfter: startAfter,
    );

    _lastDocument = result.lastDocument;
    _hasMore = result.hasMore;

    return result;
  }
}
```

### 2.4 UI Integration

```dart
// In WorkoutHistoryScreen
class WorkoutHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryNotifierProvider);

    return workoutsAsync.when(
      data: (workouts) => NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200) {
              // Trigger load more when 200px from bottom
              ref.read(workoutHistoryNotifierProvider.notifier).loadNextPage();
            }
          }
          return false;
        },
        child: ListView.builder(
          itemCount: workouts.length,
          itemBuilder: (context, index) => WorkoutCard(workout: workouts[index]),
        ),
      ),
      loading: () => const LoadingIndicator(),
      error: (e, st) => ErrorWidget(error: e),
    );
  }
}
```

---

## 3. Problema #2: Analytics Cache (STUB Fix)

### 3.1 Stato Attuale (CRITICO)

**File**: `lib/features/analytics/data/services/analytics_cache_service.dart`

```dart
class AnalyticsCacheService {
  // PROBLEMA: TUTTO è uno STUB!

  Future<T?> get<T>(String key, ...) async {
    return null;  // SEMPRE NULL!
  }

  Future<void> set<T>(String key, T value, ...) async {
    // NON FA NIENTE!
  }
}
```

**Impatto**:
- Ogni apertura Analytics ricalcola TUTTO
- ~2-3 secondi di loading ogni volta
- Batteria drain per calcoli ripetitivi
- UX pessima

### 3.2 Soluzione: Implementazione Reale con Hive

**Architettura**:

```
┌─────────────────────────────────────────────────────────────┐
│                  AnalyticsCacheService                       │
├─────────────────────────────────────────────────────────────┤
│ - _analyticsBox: Box<dynamic>                               │
│ - _metadataBox: Box<CacheMetadata>                          │
│                                                              │
│ + get<T>(key, fromJson?) → T?                               │
│ + set<T>(key, value, ttl?, toJson?)                         │
│ + invalidate(key)                                           │
│ + invalidatePattern(pattern)                                │
│ + invalidateUser(userId)                                    │
│ + getStatistics() → Map<String, dynamic>                    │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     Hive Storage                             │
├─────────────────────────────────────────────────────────────┤
│ analytics_cache_box:                                        │
│   - workout_history_{userId}_{limit}_{since} → List<Map>    │
│   - analytics_stats_{userId} → Map<String, dynamic>         │
│   - muscle_distribution_{userId} → Map<String, dynamic>     │
│   - weekly_volume_{userId}_{week} → double                  │
│                                                              │
│ analytics_cache_metadata_box:                               │
│   - {key} → CacheMetadata(createdAt, ttl, userId)           │
└─────────────────────────────────────────────────────────────┘
```

### 3.3 Implementazione Completa

**Nuovo file**: `lib/features/analytics/data/services/analytics_cache_service_impl.dart`

```dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Cache entry metadata for TTL management
class CacheMetadata {
  CacheMetadata({
    required this.createdAt,
    required this.ttl,
    this.userId,
  });

  final DateTime createdAt;
  final Duration ttl;
  final String? userId;

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;

  Map<String, dynamic> toJson() => {
    'createdAt': createdAt.toIso8601String(),
    'ttlMs': ttl.inMilliseconds,
    'userId': userId,
  };

  factory CacheMetadata.fromJson(Map<String, dynamic> json) => CacheMetadata(
    createdAt: DateTime.parse(json['createdAt'] as String),
    ttl: Duration(milliseconds: json['ttlMs'] as int),
    userId: json['userId'] as String?,
  );
}

/// Real implementation of AnalyticsCacheService with Hive backend
class AnalyticsCacheServiceImpl {
  static const _dataBoxName = 'analytics_cache_data';
  static const _metadataBoxName = 'analytics_cache_metadata';

  // Default TTLs
  static const defaultTtl = Duration(minutes: 15);
  static const workoutHistoryTtl = Duration(hours: 1);
  static const statsOverviewTtl = Duration(minutes: 30);
  static const muscleDistributionTtl = Duration(hours: 2);

  Box<String>? _dataBox;
  Box<String>? _metadataBox;

  // Statistics
  int _hits = 0;
  int _misses = 0;

  /// Initialize cache boxes
  Future<void> initialize() async {
    _dataBox = await Hive.openBox<String>(_dataBoxName);
    _metadataBox = await Hive.openBox<String>(_metadataBoxName);

    // Cleanup expired entries on init
    await _cleanupExpired();

    if (kDebugMode) {
      debugPrint('📦 AnalyticsCacheService initialized');
      debugPrint('   Data entries: ${_dataBox!.length}');
      debugPrint('   Metadata entries: ${_metadataBox!.length}');
    }
  }

  /// Dispose cache service
  Future<void> dispose() async {
    await _dataBox?.close();
    await _metadataBox?.close();
  }

  /// Get cached value with automatic deserialization
  Future<T?> get<T>(String key, [T Function(Map<String, dynamic>)? fromJson]) async {
    if (_dataBox == null) {
      if (kDebugMode) debugPrint('⚠️ Cache not initialized');
      return null;
    }

    // Check if key exists
    final rawData = _dataBox!.get(key);
    if (rawData == null) {
      _misses++;
      if (kDebugMode) debugPrint('❌ Cache MISS: $key');
      return null;
    }

    // Check TTL
    final metadataRaw = _metadataBox!.get(key);
    if (metadataRaw != null) {
      final metadata = CacheMetadata.fromJson(
        jsonDecode(metadataRaw) as Map<String, dynamic>,
      );

      if (metadata.isExpired) {
        _misses++;
        if (kDebugMode) debugPrint('⏰ Cache EXPIRED: $key');
        await invalidate(key);
        return null;
      }
    }

    // Deserialize
    try {
      final decoded = jsonDecode(rawData);
      _hits++;

      if (kDebugMode) debugPrint('✅ Cache HIT: $key');

      if (fromJson != null && decoded is Map<String, dynamic>) {
        return fromJson(decoded);
      }

      return decoded as T;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Cache deserialization error: $e');
      await invalidate(key);
      return null;
    }
  }

  /// Set cached value with automatic serialization
  Future<void> set<T>(
    String key,
    T value, [
    Duration? ttl,
    Map<String, dynamic> Function(T)? toJson,
  ]) async {
    if (_dataBox == null) {
      if (kDebugMode) debugPrint('⚠️ Cache not initialized');
      return;
    }

    try {
      // Serialize
      dynamic serializable;
      if (toJson != null) {
        serializable = toJson(value);
      } else if (value is Map || value is List) {
        serializable = value;
      } else {
        serializable = value;
      }

      final encoded = jsonEncode(serializable);

      // Store data
      await _dataBox!.put(key, encoded);

      // Store metadata
      final metadata = CacheMetadata(
        createdAt: DateTime.now(),
        ttl: ttl ?? defaultTtl,
        userId: _extractUserId(key),
      );
      await _metadataBox!.put(key, jsonEncode(metadata.toJson()));

      if (kDebugMode) {
        debugPrint('💾 Cache SET: $key (TTL: ${ttl ?? defaultTtl})');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Cache set error: $e');
    }
  }

  /// Invalidate specific key
  Future<void> invalidate(String key) async {
    await _dataBox?.delete(key);
    await _metadataBox?.delete(key);
    if (kDebugMode) debugPrint('🗑️ Cache INVALIDATE: $key');
  }

  /// Invalidate by pattern (e.g., "workout_history_*")
  Future<void> invalidatePattern(String pattern) async {
    if (_dataBox == null) return;

    final regex = RegExp(pattern.replaceAll('*', '.*'));
    final keysToDelete = _dataBox!.keys
        .where((key) => regex.hasMatch(key.toString()))
        .toList();

    for (final key in keysToDelete) {
      await invalidate(key.toString());
    }

    if (kDebugMode) {
      debugPrint('🗑️ Cache INVALIDATE pattern: $pattern (${keysToDelete.length} keys)');
    }
  }

  /// Invalidate all cache for a specific user
  Future<void> invalidateUser(String userId) async {
    if (_metadataBox == null) return;

    final keysToDelete = <String>[];

    for (final key in _metadataBox!.keys) {
      final metadataRaw = _metadataBox!.get(key);
      if (metadataRaw != null) {
        final metadata = CacheMetadata.fromJson(
          jsonDecode(metadataRaw) as Map<String, dynamic>,
        );
        if (metadata.userId == userId) {
          keysToDelete.add(key.toString());
        }
      }
    }

    for (final key in keysToDelete) {
      await invalidate(key);
    }

    if (kDebugMode) {
      debugPrint('🗑️ Cache INVALIDATE user: $userId (${keysToDelete.length} keys)');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalKeys': _dataBox?.length ?? 0,
      'hits': _hits,
      'misses': _misses,
      'hitRate': _hits + _misses > 0
          ? (_hits / (_hits + _misses) * 100).toStringAsFixed(1) + '%'
          : '0%',
    };
  }

  /// Cleanup expired entries
  Future<void> _cleanupExpired() async {
    if (_metadataBox == null) return;

    final expiredKeys = <String>[];

    for (final key in _metadataBox!.keys) {
      final metadataRaw = _metadataBox!.get(key);
      if (metadataRaw != null) {
        final metadata = CacheMetadata.fromJson(
          jsonDecode(metadataRaw) as Map<String, dynamic>,
        );
        if (metadata.isExpired) {
          expiredKeys.add(key.toString());
        }
      }
    }

    for (final key in expiredKeys) {
      await invalidate(key);
    }

    if (kDebugMode && expiredKeys.isNotEmpty) {
      debugPrint('🧹 Cache cleanup: ${expiredKeys.length} expired entries removed');
    }
  }

  /// Extract userId from cache key (e.g., "workout_history_abc123_20" → "abc123")
  String? _extractUserId(String key) {
    final parts = key.split('_');
    if (parts.length >= 3) {
      // Format: prefix_type_userId_...
      return parts[2];
    }
    return null;
  }
}
```

### 3.4 Cache Keys Standardizzate

```dart
/// Standardized cache key generators
class AnalyticsCacheKeys {
  /// Workout history cache key
  static String workoutHistory(String userId, {int? limit, DateTime? since}) {
    final limitPart = limit?.toString() ?? 'all';
    final sincePart = since?.millisecondsSinceEpoch.toString() ?? 'none';
    return 'workout_history_${userId}_${limitPart}_$sincePart';
  }

  /// Stats overview cache key
  static String statsOverview(String userId) {
    return 'analytics_stats_$userId';
  }

  /// Muscle distribution cache key
  static String muscleDistribution(String userId, {DateTime? date}) {
    final datePart = date != null
        ? '${date.year}_${date.month}'
        : 'current';
    return 'muscle_distribution_${userId}_$datePart';
  }

  /// Weekly volume cache key
  static String weeklyVolume(String userId, int weekNumber, int year) {
    return 'weekly_volume_${userId}_${year}_$weekNumber';
  }

  /// Exercise progress cache key
  static String exerciseProgress(String userId, String exerciseId) {
    return 'exercise_progress_${userId}_$exerciseId';
  }

  /// PR history cache key
  static String prHistory(String userId) {
    return 'pr_history_$userId';
  }
}
```

### 3.5 Integration con Analytics Provider

```dart
// In analytics provider - esempio di utilizzo
@riverpod
Future<AnalyticsOverview> analyticsOverview(AnalyticsOverviewRef ref) async {
  final userId = ref.watch(userIdProvider);
  final cache = ref.watch(analyticsCacheServiceProvider);

  if (userId == null) throw Exception('User not logged in');

  final cacheKey = AnalyticsCacheKeys.statsOverview(userId);

  // Try cache first
  final cached = await cache.get<Map<String, dynamic>>(cacheKey);
  if (cached != null) {
    return AnalyticsOverview.fromJson(cached);
  }

  // Calculate fresh data
  final repository = ref.watch(analyticsRepositoryProvider);
  final overview = await repository.calculateOverview(userId);

  // Store in cache with 30 min TTL
  await cache.set(
    cacheKey,
    overview.toJson(),
    AnalyticsCacheServiceImpl.statsOverviewTtl,
  );

  return overview;
}
```

---

## 4. Problema #3: Exercise Search Optimization

### 4.1 Stato Attuale

**File**: `exercise_fuzzy_matcher.dart` + `exercise_search_provider.dart`

```dart
// PROBLEMA: searchExercises riceve TUTTI gli esercizi come parametro
static Future<List<ExerciseFuzzyResult>> searchExercises({
  required List<Exercise> exercises,  // <-- 400+ esercizi passati!
  required String query,
  ...
})

// Provider streams ALL exercises
return repository.getAllExercises().map((exercises) {
  return exercises.where((exercise) {
    // Filter in memory after loading ALL
  }).toList();
});
```

**Problemi**:
1. 400+ esercizi caricati OGNI ricerca
2. Cold start: ~200-400ms per caricare tutti
3. Memoria occupata anche senza ricerca attiva

### 4.2 Soluzione: Pre-Cache + Indexed Search

**Architettura**:

```
┌─────────────────────────────────────────────────────────────┐
│                   App Initialization                         │
├─────────────────────────────────────────────────────────────┤
│ 1. Load exercise database to Hive (one-time/on update)      │
│ 2. Initialize fuzzy search isolate (warm up)                │
│ 3. Pre-build search index in memory                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│               ExerciseSearchService (Singleton)              │
├─────────────────────────────────────────────────────────────┤
│ - _cachedExercises: List<Exercise>? (in-memory, lazy)       │
│ - _searchIndex: Map<String, List<int>> (trigram index)      │
│ - _lastLoad: DateTime                                       │
│                                                              │
│ + ensureLoaded() → Future<void>                             │
│ + search(query, {limit}) → Future<List<Exercise>>           │
│ + refreshCache() → Future<void>                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Implementazione: Pre-Loading Service

```dart
/// Optimized exercise search with pre-caching
class ExerciseSearchServiceOptimized {
  static ExerciseSearchServiceOptimized? _instance;
  static ExerciseSearchServiceOptimized get instance {
    _instance ??= ExerciseSearchServiceOptimized._();
    return _instance!;
  }

  ExerciseSearchServiceOptimized._();

  List<Exercise>? _cachedExercises;
  Map<String, Set<int>>? _trigramIndex;
  DateTime? _lastLoad;
  bool _isLoading = false;

  /// Check if cache is valid (loaded within 24h)
  bool get isCacheValid {
    if (_cachedExercises == null || _lastLoad == null) return false;
    return DateTime.now().difference(_lastLoad!) < const Duration(hours: 24);
  }

  /// Ensure exercises are loaded (call at app startup)
  Future<void> ensureLoaded(ExerciseRepository repository) async {
    if (isCacheValid || _isLoading) return;

    _isLoading = true;
    try {
      // Load from local Hive first (fast)
      final exercises = await repository.getAllExercisesOnce();
      _cachedExercises = exercises;
      _lastLoad = DateTime.now();

      // Build trigram index for fast prefix search
      _buildTrigramIndex();

      if (kDebugMode) {
        debugPrint('📚 Exercise cache loaded: ${exercises.length} exercises');
        debugPrint('🔍 Trigram index built: ${_trigramIndex?.length ?? 0} trigrams');
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Build trigram index for fast search
  void _buildTrigramIndex() {
    _trigramIndex = {};

    if (_cachedExercises == null) return;

    for (var i = 0; i < _cachedExercises!.length; i++) {
      final exercise = _cachedExercises![i];
      final name = exercise.nome.toLowerCase();

      // Generate trigrams
      for (var j = 0; j <= name.length - 3; j++) {
        final trigram = name.substring(j, j + 3);
        _trigramIndex!.putIfAbsent(trigram, () => {});
        _trigramIndex![trigram]!.add(i);
      }
    }
  }

  /// Fast search using trigram index + fuzzy matcher
  Future<List<ExerciseFuzzyResult>> search({
    required String query,
    int maxResults = 50,
    String? userId,
    String? category,
  }) async {
    if (_cachedExercises == null) {
      return [];
    }

    // For very short queries, use trigram pre-filter
    List<Exercise> candidates;
    if (query.length >= 3 && _trigramIndex != null) {
      candidates = _getTrigramCandidates(query);
      if (kDebugMode) {
        debugPrint('🔍 Trigram filtered: ${candidates.length}/${_cachedExercises!.length}');
      }
    } else {
      candidates = _cachedExercises!;
    }

    // Apply category filter if provided
    if (category != null) {
      candidates = candidates.where((e) => e.categoria == category).toList();
    }

    // Use fuzzy matcher on reduced candidate set
    return ExerciseFuzzyMatcher.searchExercises(
      exercises: candidates,
      query: query,
      maxResults: maxResults,
      userId: userId,
      currentCategory: category,
    );
  }

  /// Get candidates using trigram index
  List<Exercise> _getTrigramCandidates(String query) {
    if (_trigramIndex == null || _cachedExercises == null) {
      return _cachedExercises ?? [];
    }

    final queryLower = query.toLowerCase();
    final queryTrigrams = <String>[];

    for (var i = 0; i <= queryLower.length - 3; i++) {
      queryTrigrams.add(queryLower.substring(i, i + 3));
    }

    // Find exercises that match ANY trigram
    final candidateIndices = <int>{};
    for (final trigram in queryTrigrams) {
      final indices = _trigramIndex![trigram];
      if (indices != null) {
        candidateIndices.addAll(indices);
      }
    }

    return candidateIndices
        .map((i) => _cachedExercises![i])
        .toList();
  }

  /// Force refresh cache (e.g., after database update)
  Future<void> refreshCache(ExerciseRepository repository) async {
    _cachedExercises = null;
    _trigramIndex = null;
    _lastLoad = null;
    await ensureLoaded(repository);
  }

  /// Get cached exercises (for direct access)
  List<Exercise>? get cachedExercises => _cachedExercises;
}
```

### 4.4 Provider Refactored

```dart
/// Provider that ensures exercises are pre-loaded
final exerciseSearchServiceOptimizedProvider = Provider<ExerciseSearchServiceOptimized>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  final service = ExerciseSearchServiceOptimized.instance;

  // Ensure loaded on first access
  service.ensureLoaded(repository);

  return service;
});

/// Optimized search provider
final optimizedExerciseSearchProvider = FutureProvider.autoDispose
    .family<List<ExerciseFuzzyResult>, String>((ref, query) async {
  final service = ref.watch(exerciseSearchServiceOptimizedProvider);
  final userId = ref.watch(userIdProvider);

  if (query.isEmpty) return [];

  // Debounce search
  await Future.delayed(const Duration(milliseconds: 300));

  // Check if still mounted
  if (!ref.exists(optimizedExerciseSearchProvider(query))) return [];

  return service.search(
    query: query,
    userId: userId,
    maxResults: 30,
  );
});
```

### 4.5 App Initialization Hook

```dart
// In main.dart or AppInitializer
Future<void> _initializePerformanceOptimizations() async {
  // 1. Initialize exercise fuzzy matcher isolate
  await ExerciseFuzzyMatcher.initialize();

  // 2. Pre-load exercise database
  final repository = container.read(exerciseRepositoryProvider);
  await ExerciseSearchServiceOptimized.instance.ensureLoaded(repository);

  // 3. Initialize analytics cache
  final cacheService = container.read(analyticsCacheServiceProvider);
  await cacheService.initialize();
}
```

---

## 5. Piano di Implementazione

### Fase 1: Workout History Pagination (4h)

| # | Task | Layer | Files | Est. |
|---|------|-------|-------|------|
| 1.1 | Create PaginatedResult entity | Domain | `paginated_result.dart` | 15m |
| 1.2 | Add getWorkoutsPaginated to repository interface | Domain | `workout_repository.dart` | 15m |
| 1.3 | Implement getWorkoutsPaginated in repository impl | Data | `workout_repository_impl.dart` | 45m |
| 1.4 | Create WorkoutHistoryNotifier (AsyncNotifier) | Presentation | `workout_history_notifier.dart` | 1h |
| 1.5 | Update WorkoutHistoryScreen with infinite scroll | Presentation | `workout_history_screen.dart` | 1h |
| 1.6 | Add loading states and error handling | Presentation | Various | 30m |
| 1.7 | Test pagination with 100+ workouts | Testing | Unit + Widget tests | 30m |

### Fase 2: Analytics Cache Fix (4h)

| # | Task | Layer | Files | Est. |
|---|------|-------|-------|------|
| 2.1 | Create CacheMetadata model | Data | `cache_metadata.dart` | 15m |
| 2.2 | Implement AnalyticsCacheServiceImpl | Data | `analytics_cache_service_impl.dart` | 1.5h |
| 2.3 | Update AnalyticsCacheKeys with all keys | Data | `analytics_cache_service.dart` | 30m |
| 2.4 | Create analytics cache provider | Presentation | `analytics_cache_provider.dart` | 30m |
| 2.5 | Integrate cache in analytics providers | Presentation | Various providers | 45m |
| 2.6 | Add cache invalidation on workout save | Data | `workout_repository.dart` | 30m |
| 2.7 | Test cache hit/miss scenarios | Testing | Unit tests | 30m |

### Fase 3: Exercise Search Optimization (4h)

| # | Task | Layer | Files | Est. |
|---|------|-------|-------|------|
| 3.1 | Create ExerciseSearchServiceOptimized | Domain | `exercise_search_service_optimized.dart` | 1h |
| 3.2 | Implement trigram index builder | Domain | Same file | 45m |
| 3.3 | Create optimized search provider | Presentation | `exercise_search_provider.dart` | 30m |
| 3.4 | Add app initialization hook | Core | `app_initializer.dart` | 30m |
| 3.5 | Update ExerciseSearchScreen to use optimized provider | Presentation | `exercise_search_screen.dart` | 30m |
| 3.6 | Add debounce to search input | Presentation | Same file | 15m |
| 3.7 | Test search performance (benchmark) | Testing | Performance test | 30m |

---

## 6. Metriche di Successo

| Metrica | Prima | Dopo | Target |
|---------|-------|------|--------|
| **Workout History Load (500 items)** | ~3s + OOM risk | <500ms first page | <1s |
| **Analytics Screen Load (cached)** | ~2-3s | <100ms | <200ms |
| **Exercise Search (cold)** | ~400ms | <150ms | <200ms |
| **Exercise Search (warm)** | ~200ms | <50ms | <100ms |
| **Memory (Workout History)** | ~5MB (500 items) | ~200KB (20 items) | <500KB |

---

## 7. Rischi e Mitigazioni

| Rischio | Probabilità | Mitigazione |
|---------|-------------|-------------|
| Firestore index missing | Alta | Creare composite index prima di deploy |
| Cache stale data | Media | Invalidazione automatica su write |
| Trigram index memory | Bassa | ~50KB per 400 exercises (acceptable) |
| Migration existing data | Bassa | Backward compatible changes |

---

## 8. Dipendenze

- `hive_flutter: ^1.1.0` - già presente
- `cloud_firestore: ^4.x` - già presente
- `flutter_riverpod: ^2.x` - già presente
- Firestore composite index su `workouts` collection

---

## 9. Validazione Best Practices 2024/2025

### ✅ Conferme da Ricerche Web

| Proposta | Validazione | Fonte |
|----------|-------------|-------|
| Cursor-based pagination Firestore | ✅ "A cursor marks a position in dataset... split data into batches" | [Firebase Docs](https://firebase.google.com/docs/firestore/query-data/query-cursors) |
| AsyncNotifier invece di StateNotifier | ✅ "StateNotifier will be deprecated. AsyncNotifier simplifies async loading" | [DEV Community](https://dev.to/dinko7/implementing-infinite-scroll-with-riverpods-asyncnotifier-3fai) |
| Hive per cache locale | ✅ "Faster than shared preferences and sqflite, works on any platform" | [Medium](https://medium.com/flutter-community/flutter-cache-with-hive-410c3283280c) |
| TTL-based invalidation | ✅ "Implement strategies like TTL or event-based invalidation" | [Vibe Studio](https://vibe-studio.ai/insights/implementing-app-wide-caching-strategies-in-flutter/) |
| Trigram index per search | ✅ "Finds objects matching max 3-char strings, similar strings share trigrams" | [Wikipedia](https://en.wikipedia.org/wiki/Trigram_search) |
| Pre-cache all'avvio app | ✅ Pattern consigliato per offline-first | [Medium](https://medium.com/@tiger.chirag/offline-first-flutter-app-with-firestore-hive-build-smart-fast-reliable-c60786d8c6f1) |

### ⚠️ Limitazioni Scoperte

| Limitazione | Impatto | Soluzione |
|-------------|---------|-----------|
| Hive NON ha TTL built-in | Serve implementazione manuale | ✅ Già prevista nel design (CacheMetadata) |
| Composite index richiesto per where+orderBy | Deve essere creato prima del deploy | Creare via console o URL errore |

### 🆕 Alternative Scoperte

#### Per Workout History Pagination

| Alternativa | Pro | Contro | Consiglio |
|-------------|-----|--------|-----------|
| **1. Custom AsyncNotifier** (proposta attuale) | Controllo totale, flessibile | Più codice da scrivere | ✅ **Raccomandato** per customizzazione |
| **2. FirestoreListView** (`firebase_ui_firestore`) | Dichiarativo, zero boilerplate, real-time | Meno controllo, dipendenza extra | Valutare se serve real-time |
| **3. infinite_scroll_pagination** package | Architecture-agnostic, collaudato | Generica, non Firestore-specific | Alternativa valida |

```dart
// Alternativa 2: FirestoreListView (più semplice)
FirestoreListView<Map<String, dynamic>>(
  query: FirebaseFirestore.instance
      .collection('workouts')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true),
  pageSize: 20,
  itemBuilder: (context, snapshot) => WorkoutCard(
    workout: Workout.fromFirestore(snapshot),
  ),
)
```

#### Per Analytics Cache

| Alternativa | Pro | Contro | Consiglio |
|-------------|-----|--------|-----------|
| **1. Custom Hive + TTL** (proposta attuale) | Controllo TTL, statistics | Più codice | ✅ **Raccomandato** |
| **2. Hybrid Map + Hive** | Session cache velocissimo | Complessità extra | Valutare per hot data |
| **3. offline_sync_helper** package | Full sync engine | Overkill per cache | Non necessario |

---

## 10. Riferimenti

### Documentazione Ufficiale
- [Firebase - Paginate with Query Cursors](https://firebase.google.com/docs/firestore/query-data/query-cursors)
- [Firebase - Index Overview](https://firebase.google.com/docs/firestore/query-data/index-overview)
- [Flutter - Local Caching](https://docs.flutter.dev/get-started/fundamentals/local-caching)
- [Riverpod - AsyncNotifier](https://riverpod.dev/docs/providers/notifier_provider)

### Tutorial e Guide (2024)
- [Riverpod Pagination: Ultimate Guide](https://dinkomarinac.dev/riverpod-pagination-the-ultimate-guide-for-flutter-developers) (April 2024)
- [Implementing Infinite Scroll with AsyncNotifier](https://dev.to/dinko7/implementing-infinite-scroll-with-riverpods-asyncnotifier-3fai) (February 2024)
- [Code With Andrea - Firestore Pagination](https://codewithandrea.com/articles/firestore-pagination-list-view/)
- [LogRocket - Infinite Scroll in Flutter](https://blog.logrocket.com/implement-infinite-scroll-pagination-flutter/) (June 2024)
- [Offline-First Flutter with Hive](https://medium.com/@tiger.chirag/offline-first-flutter-app-with-firestore-hive-build-smart-fast-reliable-c60786d8c6f1)
- [Flutter Cache with Hive](https://medium.com/flutter-community/flutter-cache-with-hive-410c3283280c)
- [Efficient API Caching with Hive](https://kotlincodes.com/flutter-dart/networking-apis/efficient-api-caching-in-flutter-with-hive/)

### Packages
- [infinite_scroll_pagination](https://pub.dev/packages/infinite_scroll_pagination) - Architecture-agnostic pagination
- [firebase_ui_firestore](https://pub.dev/packages/firebase_ui_firestore) - FirestoreListView widget
- [riverpod_infinite_scroll_pagination](https://pub.dev/packages/riverpod_infinite_scroll_pagination) - Riverpod-specific
- [offline_sync_helper](https://pub.dev/packages/offline_sync_helper) - Full offline sync engine

### Algoritmi
- [Trigram Search - Wikipedia](https://en.wikipedia.org/wiki/Trigram_search)
- [Cockroach Labs - Use Cases for Trigram Indexes](https://www.cockroachlabs.com/blog/use-cases-trigram-indexes/)
