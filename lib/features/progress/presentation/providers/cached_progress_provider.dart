/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// CACHED PROGRESS PROVIDER
/// Provider con cache locale per statistiche workout
/// Risolve il problema del conteggio errato (esercizi vs workout)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/providers/shared_preferences_provider.dart';
import 'package:gymbro_flutter_new/shared/data/mixins/firestore_cache_first_mixin.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Helper class for cache-first Firestore operations
class _CacheHelper with FirestoreCacheFirstMixin {}

final _cache = _CacheHelper();

/// Debug logging utility with detailed tracking
class _CacheLogger {
  static const bool _enableDebugLogs =
      kDebugMode; // Solo in debug mode, non in production

  static void log(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('🔍 DEBUG [$timestamp] CachedProgress: $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint(
        '❌ ERROR [$timestamp] CachedProgress: $message${error != null ? ' - $error' : ''}',
      );
    }
  }

  static void step(String step, String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('📍 STEP [$timestamp] $step: $message');
    }
  }

  static void firebase(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('🔥 FIREBASE [$timestamp] $message');
    }
  }

  static void cache(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('💾 CACHE [$timestamp] $message');
    }
  }

  static void auth(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('🔐 AUTH [$timestamp] $message');
    }
  }
}

/// Cached dashboard stats entity
class CachedDashboardStats {
  // Per validità cache

  const CachedDashboardStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.currentStreak,
    required this.weeklyFrequency,
    required this.totalVolume,
    required this.maxPR,
    required this.prExercise,
    required this.workoutDates,
    required this.lastCalculated,
  });

  /// Create from JSON
  factory CachedDashboardStats.fromJson(Map<String, dynamic> json) {
    return CachedDashboardStats(
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalExercises: json['totalExercises'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      weeklyFrequency: (json['weeklyFrequency'] ?? 0.0).toDouble(),
      totalVolume: (json['totalVolume'] ?? 0.0).toDouble(),
      maxPR: (json['maxPR'] ?? 0.0).toDouble(),
      prExercise: json['prExercise'] ?? 'N/A',
      workoutDates: Map<String, bool>.from(json['workoutDates'] ?? {}),
      lastCalculated: DateTime.parse(
        json['lastCalculated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Create empty stats
  factory CachedDashboardStats.empty() {
    return CachedDashboardStats(
      totalWorkouts: 0,
      totalExercises: 0,
      currentStreak: 0,
      weeklyFrequency: 0.0,
      totalVolume: 0.0,
      maxPR: 0.0,
      prExercise: 'N/A',
      workoutDates: {},
      lastCalculated: DateTime.now(),
    );
  }
  final int totalWorkouts; // Workout reali (non esercizi)
  final int totalExercises; // Esercizi totali
  final int currentStreak; // Streak giorni consecutivi
  final double weeklyFrequency; // Frequenza settimanale
  final double totalVolume; // Volume totale
  final double maxPR; // PR massimo
  final String prExercise; // Esercizio del PR
  final Map<String, bool> workoutDates; // Date workout per streak
  final DateTime lastCalculated;

  /// Check if cache is still valid (adaptive based on user activity)
  bool get isValid {
    final now = DateTime.now();
    final age = now.difference(lastCalculated);

    // Cache più fresca = validità più lunga
    if (age.inHours < 24) return true; // Ultimo giorno sempre valido
    if (age.inDays < 3 && totalWorkouts < 100) return true; // Utenti nuovi
    if (age.inDays < 7 && totalWorkouts < 500) return true; // Utenti medi
    return age.inDays < 30; // Power users - refresh mensile
  }

  /// Convert to simple dashboard stats
  DashboardStats toDashboardStats() {
    return DashboardStats(
      currentStreak: currentStreak,
      totalWorkouts: totalWorkouts,
      weeklyFrequency: weeklyFrequency,
      totalVolume: totalVolume,
      volumeIncrease: 0.0, // TODO: Calculate if needed
      maxPR: maxPR,
      prExercise: prExercise,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'currentStreak': currentStreak,
      'weeklyFrequency': weeklyFrequency,
      'totalVolume': totalVolume,
      'maxPR': maxPR,
      'prExercise': prExercise,
      'workoutDates': workoutDates,
      'lastCalculated': lastCalculated.toIso8601String(),
    };
  }

  /// Add new workout to stats
  CachedDashboardStats addWorkout(String dateKey) {
    final newWorkoutDates = Map<String, bool>.from(workoutDates);
    newWorkoutDates[dateKey] = true;

    // Recalculate streak
    final newStreak = _calculateStreak(newWorkoutDates);

    // Recalculate weekly frequency
    final newWeeklyFreq = _calculateWeeklyFrequency(newWorkoutDates);

    return CachedDashboardStats(
      totalWorkouts: totalWorkouts + 1,
      totalExercises: totalExercises, // Will be updated separately
      currentStreak: newStreak,
      weeklyFrequency: newWeeklyFreq,
      totalVolume: totalVolume, // Will be updated separately
      maxPR: maxPR, // Will be updated separately
      prExercise: prExercise,
      workoutDates: newWorkoutDates,
      lastCalculated: DateTime.now(),
    );
  }

  /// Calculate current streak
  int _calculateStreak(Map<String, bool> dates) {
    if (dates.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dayKey = _dateToKey(checkDate);

      if (dates.containsKey(dayKey)) {
        streak++;
      } else if (i <= 1) {
        // Allow 1 day gap
        continue;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate weekly frequency from workout dates
  double _calculateWeeklyFrequency(Map<String, bool> dates) {
    if (dates.isEmpty) return 0.0;

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    int workoutsInLast30Days = 0;

    for (final dateKey in dates.keys) {
      final date = _keyToDate(dateKey);
      if (date.isAfter(thirtyDaysAgo)) {
        workoutsInLast30Days++;
      }
    }

    return workoutsInLast30Days * 7 / 30; // Convert to weekly
  }

  /// Convert date to string key
  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Convert string key to date
  DateTime _keyToDate(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

/// Dashboard stats entity (from existing code)
class DashboardStats {
  const DashboardStats({
    required this.currentStreak,
    required this.totalWorkouts,
    required this.weeklyFrequency,
    required this.totalVolume,
    required this.volumeIncrease,
    required this.maxPR,
    required this.prExercise,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      currentStreak: 0,
      totalWorkouts: 0,
      weeklyFrequency: 0.0,
      totalVolume: 0.0,
      volumeIncrease: 0.0,
      maxPR: 0.0,
      prExercise: 'N/A',
    );
  }
  final int currentStreak;
  final int totalWorkouts;
  final double weeklyFrequency;
  final double totalVolume;
  final double volumeIncrease;
  final double maxPR;
  final String prExercise;
}

/// Cache repository for progress stats
///
/// 🔐 USER ISOLATION: Cache key is now user-scoped to prevent data leakage
/// when switching between accounts. Uses UserCacheKeyManager.
class ProgressCacheRepository {
  ProgressCacheRepository(this._prefs) {
    _initCompleter = Completer<void>();
    _initialize();
  }

  // 🔐 User-scoped cache key via UserCacheKeyManager
  // Pattern: 'cached_dashboard_stats_{userId}' instead of global 'cached_dashboard_stats'
  String get _cacheKey => userCacheKeys.userScopedKey('cached_dashboard_stats');

  final SharedPreferences _prefs;

  // Mutex for thread-safe SharedPreferences access
  static final Map<String, Completer<void>> _operationLocks = {};
  static final Map<String, Timer> _debouncedInvalidations = {};

  // State tracking to prevent concurrent operations
  bool _isCalculating = false;
  Timer? _autoValidationCooldown;

  // GOLD STANDARD: Initialization tracking
  bool _isInitialized = false;
  bool _isDisposed = false;
  Completer<void>? _initCompleter;
  int _initRetryCount = 0;
  static const int _maxInitRetries = 3;

  /// Initialize the repository
  Future<void> _initialize() async {
    try {
      _CacheLogger.step('REPO_INIT', 'Initializing ProgressCacheRepository...');

      // Test SharedPreferences accessibility
      final testKey = 'init_test_key_${DateTime.now().millisecondsSinceEpoch}';
      const testValue = 'test_value';
      await _prefs.setString(testKey, testValue);
      final readBack = _prefs.getString(testKey);
      await _prefs.remove(testKey);

      if (readBack != testValue) {
        throw Exception('SharedPreferences read/write test failed');
      }

      _isInitialized = true;
      _initRetryCount = 0;
      _initCompleter?.complete();

      _CacheLogger.step(
        'REPO_INIT',
        '✅ ProgressCacheRepository initialized successfully',
      );
    } catch (e, stackTrace) {
      _CacheLogger.error('Failed to initialize ProgressCacheRepository', e);
      _CacheLogger.error('Stack trace: $stackTrace');

      if (_initRetryCount < _maxInitRetries) {
        _initRetryCount++;
        _CacheLogger.step(
          'REPO_INIT',
          'Retrying initialization (attempt $_initRetryCount/$_maxInitRetries)',
        );
        await Future.delayed(Duration(seconds: _initRetryCount));
        await _initialize();
      } else {
        _initCompleter?.completeError(e, stackTrace);
      }
    }
  }

  /// Ensure repository is initialized before operations
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (_initRetryCount >= _maxInitRetries) {
      throw Exception(
        'ProgressCacheRepository initialization failed after $_maxInitRetries attempts',
      );
    }
    if (_initCompleter != null) {
      try {
        await _initCompleter!.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            _CacheLogger.error(
              'ProgressCacheRepository initialization timeout',
            );
            throw TimeoutException('Repository initialization timeout');
          },
        );
      } catch (e) {
        _initRetryCount++;
        _initCompleter = Completer<void>();
        await _initialize();
      }
    }
  }

  /// Save stats to cache with mutex protection and detailed debug
  Future<void> saveStats(CachedDashboardStats stats) async {
    await _ensureInitialized();
    if (_isDisposed) {
      _CacheLogger.error('Cannot save stats: repository is disposed');
      return;
    }

    _CacheLogger.step('CACHE_SAVE', 'Starting cache save operation');
    return _withLock('save', () async {
      try {
        _CacheLogger.cache(
          'Converting stats to JSON: ${stats.totalWorkouts} workouts',
        );
        final json = jsonEncode(stats.toJson());
        _CacheLogger.cache('JSON size: ${json.length} chars');

        await _prefs.setString(_cacheKey, json);
        _CacheLogger.cache('✅ Successfully saved to SharedPreferences');
      } catch (e, stack) {
        _CacheLogger.error('Failed to save stats to cache', e);
        _CacheLogger.error('Stack trace: $stack');
        rethrow;
      }
    });
  }

  /// Load stats from cache with mutex protection and detailed debug
  Future<CachedDashboardStats?> loadStats() async {
    await _ensureInitialized();
    if (_isDisposed) {
      _CacheLogger.error('Cannot load stats: repository is disposed');
      return null;
    }

    _CacheLogger.step('CACHE_LOAD', 'Starting cache load operation');
    return _withLock('load', () async {
      try {
        _CacheLogger.cache('Checking SharedPreferences for key: $_cacheKey');
        final jsonString = _prefs.getString(_cacheKey);

        if (jsonString == null) {
          _CacheLogger.cache('No cached data found in SharedPreferences');
          return null;
        }

        _CacheLogger.cache(
          'Found cached data, length: ${jsonString.length} chars',
        );
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _CacheLogger.cache('Successfully parsed JSON data');

        final stats = CachedDashboardStats.fromJson(json);
        _CacheLogger.cache(
          'Created stats object: ${stats.totalWorkouts} workouts, lastCalculated: ${stats.lastCalculated}',
        );

        if (stats.isValid) {
          _CacheLogger.cache('✅ Cache is valid, using cached stats');
          return stats;
        } else {
          final age = DateTime.now().difference(stats.lastCalculated);
          _CacheLogger.cache(
            '❌ Cache expired - Age: ${age.inDays} days, ${age.inHours} hours',
          );
          return null;
        }
      } catch (e, stack) {
        _CacheLogger.error('Failed to load cached stats', e);
        _CacheLogger.error('Stack trace: $stack');
        // Clear corrupted cache
        await clearCache();
        return null;
      }
    });
  }

  /// Increment workout count with auto-validation and race condition protection
  Future<void> incrementWorkout(String dateKey) async {
    await _ensureInitialized();
    if (_isDisposed) {
      _CacheLogger.error('Cannot increment workout: repository is disposed');
      return;
    }

    return _withLock('increment', () async {
      try {
        // Prevent recursive auto-validation
        if (_isCalculating) {
          _CacheLogger.log(
            'Already calculating stats, skipping increment for $dateKey',
          );
          return;
        }

        final current = await loadStats();
        if (current != null) {
          // Check if this is a duplicate (same day workout)
          if (current.workoutDates.containsKey(dateKey)) {
            _CacheLogger.log(
              'Same day workout detected for $dateKey - not incrementing',
            );
            return; // Don't increment, same day
          }

          final updated = current.addWorkout(dateKey);
          await saveStats(updated);
          _CacheLogger.log(
            'Incremented workout count: ${updated.totalWorkouts}',
          );

          // Auto-validation with cooldown to prevent recursion
          if (updated.totalWorkouts % 10 == 0 &&
              _autoValidationCooldown == null) {
            _CacheLogger.log(
              'Triggering auto-validation at ${updated.totalWorkouts} workouts',
            );
            _scheduleAutoValidation();
          }
        } else {
          _CacheLogger.log(
            'No cache found for increment - scheduling recalculation',
          );
          _scheduleDebouncedInvalidation();
        }
      } catch (e) {
        _CacheLogger.error('Failed to increment workout', e);
        // Fallback: schedule recalculation
        _scheduleDebouncedInvalidation();
      }
    });
  }

  /// Clear cache with mutex protection
  Future<void> clearCache() async {
    await _ensureInitialized();
    if (_isDisposed) {
      _CacheLogger.error('Cannot clear cache: repository is disposed');
      return;
    }

    return _withLock('clear', () async {
      try {
        await _prefs.remove(_cacheKey);
        _CacheLogger.log('Cleared progress cache');
      } catch (e) {
        _CacheLogger.error('Failed to clear cache', e);
      }
    });
  }

  /// Thread-safe operation wrapper using per-operation locks
  Future<T> _withLock<T>(String operation, Future<T> Function() action) async {
    final lockKey = '${_cacheKey}_$operation';

    // Wait for any existing operation of this type to complete
    if (_operationLocks.containsKey(lockKey)) {
      await _operationLocks[lockKey]!.future;
    }

    // Create new lock for this operation
    final completer = Completer<void>();
    _operationLocks[lockKey] = completer;

    try {
      final result = await action();
      completer.complete();
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _operationLocks.remove(lockKey);
    }
  }

  /// Schedule auto-validation with cooldown to prevent recursion
  void _scheduleAutoValidation() {
    _autoValidationCooldown?.cancel();
    _autoValidationCooldown = Timer(const Duration(seconds: 5), () async {
      try {
        await clearCache();
        _autoValidationCooldown = null;
      } catch (e) {
        _CacheLogger.error('Auto-validation failed', e);
        _autoValidationCooldown = null;
      }
    });
  }

  /// Schedule debounced invalidation to batch multiple requests
  void _scheduleDebouncedInvalidation() {
    const key = 'invalidation';
    _debouncedInvalidations[key]?.cancel();
    _debouncedInvalidations[key] = Timer(
      const Duration(milliseconds: 500),
      () async {
        try {
          await clearCache();
          _debouncedInvalidations.remove(key);
        } catch (e) {
          _CacheLogger.error('Debounced invalidation failed', e);
          _debouncedInvalidations.remove(key);
        }
      },
    );
  }

  /// Dispose method to clean up timers and resources
  void dispose() {
    _CacheLogger.step(
      'REPO_DISPOSE',
      '🧹 Starting disposal of ProgressCacheRepository',
    );
    _isDisposed = true;

    try {
      // Cancel all timers
      _autoValidationCooldown?.cancel();
      _autoValidationCooldown = null;

      for (final timer in _debouncedInvalidations.values) {
        timer.cancel();
      }
      _debouncedInvalidations.clear();

      // Complete any pending completers
      for (final lock in _operationLocks.values) {
        if (!lock.isCompleted) {
          lock.completeError(Exception('Repository disposed'));
        }
      }
      _operationLocks.clear();

      // Null out completer
      _initCompleter = null;

      _CacheLogger.step(
        'REPO_DISPOSE',
        '✅ ProgressCacheRepository disposed successfully',
      );
    } catch (e, stackTrace) {
      _CacheLogger.error('Error during disposal', e);
      _CacheLogger.error('Stack trace: $stackTrace');
    }
  }
}

/// Provider for cache repository with debug logging
final progressCacheRepositoryProvider = Provider<ProgressCacheRepository>((
  ref,
) {
  ref.keepAlive(); // FIX: previene ricreazione repository con stato/cache
  _CacheLogger.step('PROVIDER_INIT', 'Initializing ProgressCacheRepository...');

  final prefs = ref.watch(sharedPreferencesProvider);
  _CacheLogger.step('PROVIDER_INIT', 'SharedPreferences obtained');
  _CacheLogger.step(
    'PROVIDER_INIT',
    'SharedPreferences type: ${prefs.runtimeType}',
  );

  // Test SharedPreferences accessibility
  try {
    const testKey = 'debug_test_key';
    final testValue =
        'debug_test_value_${DateTime.now().millisecondsSinceEpoch}';
    prefs.setString(testKey, testValue);
    final readBack = prefs.getString(testKey);
    _CacheLogger.step(
      'PROVIDER_INIT',
      'SharedPreferences test: write/read ${readBack == testValue ? 'SUCCESS' : 'FAILED'}',
    );
    prefs.remove(testKey); // Cleanup
  } catch (e) {
    _CacheLogger.error('SharedPreferences test failed', e);
  }

  final repository = ProgressCacheRepository(prefs);
  _CacheLogger.step(
    'PROVIDER_INIT',
    'ProgressCacheRepository created successfully',
  );

  // Clean up timers when provider is disposed
  ref.onDispose(() {
    _CacheLogger.step(
      'PROVIDER_DISPOSE',
      'Disposing ProgressCacheRepository...',
    );
    repository.dispose();
  });

  return repository;
});

/// Workout stats calculator
class WorkoutStatsCalculator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calculate stats from Firebase with detailed debug logging
  Future<CachedDashboardStats> calculateFromFirebase(String userId) async {
    _CacheLogger.step(
      'FIREBASE_CALC',
      'Starting Firebase calculation for userId: $userId',
    );

    try {
      // Performance optimization: Only load last 90 days
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      _CacheLogger.firebase(
        'Query range: ${ninetyDaysAgo.toIso8601String()} to ${DateTime.now().toIso8601String()}',
      );

      _CacheLogger.firebase('Building Firestore query...');
      final query = _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .where(
            'completedAt',
            isGreaterThan: Timestamp.fromDate(ninetyDaysAgo),
          )
          .orderBy('completedAt', descending: true)
          .limit(500); // Max 500 workouts

      _CacheLogger.firebase('Executing Firebase query...');
      final startTime = DateTime.now();
      final querySnapshot = await _cache
          .queryCacheFirst(query)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              _CacheLogger.error('Firebase query timeout after 30s');
              throw TimeoutException('Firebase query timeout after 30 seconds');
            },
          );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final docs = querySnapshot.docs;
      _CacheLogger.firebase(
        '✅ Query completed in ${duration.inMilliseconds}ms',
      );
      _CacheLogger.firebase('Found ${docs.length} documents');

      if (docs.isEmpty) {
        _CacheLogger.firebase('No workouts found - returning empty stats');
        return CachedDashboardStats.empty();
      }

      // Process workout documents
      _CacheLogger.step('AGGREGATION', 'Starting data aggregation...');
      final workoutDates = <String, bool>{};
      int validDocs = 0;
      int invalidDocs = 0;
      int totalExercises = 0;

      double totalVolume = 0;
      double maxPR = 0;
      String prExercise = 'N/A';
      int completedSets = 0;
      int totalSets = 0;

      for (final doc in docs) {
        final data = doc.data();
        final timestamp = data['completedAt'] as Timestamp?;

        if (timestamp != null) {
          validDocs++;
          final date = timestamp.toDate();
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          workoutDates[dateKey] = true;

          // Process exercises in this workout
          final exercises = data['exercises'] as List<dynamic>? ?? [];
          totalExercises += exercises.length;

          for (final exercise in exercises) {
            if (exercise is Map<String, dynamic>) {
              final exerciseName = exercise['name'] as String? ?? 'Unknown';
              final sets = exercise['sets'] as List<dynamic>? ?? [];

              for (final set in sets) {
                totalSets++;
                if (set is Map<String, dynamic>) {
                  final isCompleted =
                      set['completed'] == true || set['done'] == true;
                  if (isCompleted) {
                    completedSets++;
                    final weightValue = set['weight'];
                    final weight = weightValue is num
                        ? weightValue.toDouble()
                        : double.tryParse(weightValue?.toString() ?? '0') ?? 0;

                    final repsValue = set['reps'];
                    final reps = repsValue is num
                        ? repsValue.toInt()
                        : int.tryParse(repsValue?.toString() ?? '0') ?? 0;

                    totalVolume += weight * reps;

                    if (weight > maxPR) {
                      maxPR = weight;
                      prExercise = exerciseName;
                    }
                  }
                }
              }
            }
          }
        } else {
          invalidDocs++;
          _CacheLogger.firebase(
            'Invalid document found (no completedAt): ${doc.id}',
          );
        }
      }

      final totalWorkouts = workoutDates.length;

      _CacheLogger.step(
        'AGGREGATION_RESULT',
        'Valid docs: $validDocs, Invalid docs: $invalidDocs',
      );
      _CacheLogger.step('AGGREGATION_RESULT', 'Total workouts: $totalWorkouts');
      _CacheLogger.step(
        'AGGREGATION_RESULT',
        'Total exercises: $totalExercises',
      );
      _CacheLogger.step(
        'AGGREGATION_RESULT',
        'Sample workout dates: ${workoutDates.keys.take(5).toList()}',
      );

      _CacheLogger.step(
        'STATS_CALC',
        'Completed sets: $completedSets/$totalSets',
      );
      _CacheLogger.step(
        'STATS_CALC',
        'Total volume: ${totalVolume.toStringAsFixed(1)} kg',
      );
      _CacheLogger.step(
        'STATS_CALC',
        'Max PR: ${maxPR.toStringAsFixed(1)} kg ($prExercise)',
      );

      // Calculate streak
      _CacheLogger.step('STREAK_CALC', 'Calculating current streak...');
      final currentStreak = _calculateStreak(workoutDates);
      _CacheLogger.step('STREAK_CALC', 'Current streak: $currentStreak days');

      // Calculate weekly frequency
      _CacheLogger.step('FREQ_CALC', 'Calculating weekly frequency...');
      final weeklyFrequency = _calculateWeeklyFrequency(workoutDates);
      _CacheLogger.step(
        'FREQ_CALC',
        'Weekly frequency: ${weeklyFrequency.toStringAsFixed(1)} workouts/week',
      );

      final result = CachedDashboardStats(
        totalWorkouts: totalWorkouts,
        totalExercises: totalExercises,
        currentStreak: currentStreak,
        weeklyFrequency: weeklyFrequency,
        totalVolume: totalVolume,
        maxPR: maxPR,
        prExercise: prExercise,
        workoutDates: workoutDates,
        lastCalculated: DateTime.now(),
      );

      _CacheLogger.step('FINAL_RESULT', '✅ Calculation complete!');
      _CacheLogger.step(
        'FINAL_RESULT',
        'Workouts: $totalWorkouts, Exercises: $totalExercises',
      );
      _CacheLogger.step(
        'FINAL_RESULT',
        'Streak: $currentStreak, Frequency: ${weeklyFrequency.toStringAsFixed(1)}',
      );
      return result;
    } catch (e) {
      _CacheLogger.error('Error calculating stats from Firebase: $e', e);
      rethrow;
    }
  }

  /// Calculate current streak
  int _calculateStreak(Map<String, bool> workoutDates) {
    if (workoutDates.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dayKey =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

      if (workoutDates.containsKey(dayKey)) {
        streak++;
      } else if (i <= 1) {
        // Allow 1 day gap
        continue;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate weekly frequency
  double _calculateWeeklyFrequency(Map<String, bool> workoutDates) {
    if (workoutDates.isEmpty) return 0.0;

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    int workoutsInLast30Days = 0;

    for (final dateKey in workoutDates.keys) {
      final parts = dateKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      if (date.isAfter(thirtyDaysAgo)) {
        workoutsInLast30Days++;
      }
    }

    return workoutsInLast30Days * 7 / 30; // Convert to weekly frequency
  }
}

/// Provider for stats calculator
final workoutStatsCalculatorProvider = Provider<WorkoutStatsCalculator>((ref) {
  ref.keepAlive(); // FIX: previene ricreazione calculator service
  return WorkoutStatsCalculator();
});

/// Global state manager for cache operations
class _CacheStateManager {
  static final Map<String, Completer<DashboardStats>> _activeCalculations = {};

  /// Ensure only one calculation per user at a time with debug logging
  static Future<DashboardStats> withSingleCalculation(
    String userEmail,
    Future<DashboardStats> Function() calculation,
  ) async {
    // If already calculating for this user, wait for it
    if (_activeCalculations.containsKey(userEmail)) {
      _CacheLogger.step(
        'CONCURRENT_CALC',
        '⏳ Calculation already in progress for $userEmail, waiting...',
      );
      return _activeCalculations[userEmail]!.future;
    }

    // Start new calculation
    _CacheLogger.step('NEW_CALC', '🆕 Starting new calculation for $userEmail');
    final completer = Completer<DashboardStats>();
    _activeCalculations[userEmail] = completer;

    try {
      final result = await calculation();
      _CacheLogger.step(
        'CALC_SUCCESS',
        '✅ Calculation completed successfully for $userEmail',
      );
      completer.complete(result);
      return result;
    } catch (e, stack) {
      _CacheLogger.error('💥 Calculation failed for $userEmail', e);
      _CacheLogger.error('Full stack trace: $stack');
      completer.completeError(e, stack);
      rethrow;
    } finally {
      _activeCalculations.remove(userEmail);
      _CacheLogger.step(
        'CALC_CLEANUP',
        '🧹 Removed calculation for $userEmail from active list',
      );
    }
  }
}

/// MAIN CACHED PROGRESS PROVIDER with race condition protection and detailed debug
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final cachedProgressProvider = FutureProvider.autoDispose<DashboardStats>((
  ref,
) async {
  _CacheLogger.step('PROVIDER_START', '🚀 Starting cached progress provider');

  final authService = ref.watch(authServiceProvider);
  _CacheLogger.auth('Auth service obtained, checking current user...');

  final currentUser = authService.currentUser;
  if (currentUser == null) {
    _CacheLogger.auth('❌ No user logged in (currentUser is null)');
    return DashboardStats.empty();
  }

  if (currentUser.email == null) {
    _CacheLogger.auth('❌ User logged in but email is null');
    _CacheLogger.auth('User UID: ${currentUser.uid}');
    _CacheLogger.auth('User displayName: ${currentUser.displayName}');
    return DashboardStats.empty();
  }

  final userEmail = currentUser.email!.toLowerCase().trim();
  _CacheLogger.auth('✅ User authenticated: $userEmail');
  _CacheLogger.auth('User UID: ${currentUser.uid}');

  final cacheRepo = ref.watch(progressCacheRepositoryProvider);
  _CacheLogger.step('PROVIDERS', 'Cache repository obtained');

  final calculator = ref.watch(workoutStatsCalculatorProvider);
  _CacheLogger.step('PROVIDERS', 'Stats calculator obtained');

  _CacheLogger.step(
    'CALCULATION_START',
    'Starting calculation workflow for: $userEmail',
  );

  return _CacheStateManager.withSingleCalculation(userEmail, () async {
    try {
      _CacheLogger.step('STATE_MANAGER', 'Entered single calculation mode');
      // Mark repository as calculating to prevent concurrent increments
      cacheRepo._isCalculating = true;
      _CacheLogger.step('STATE_MANAGER', 'Set calculating flag to true');

      // 1. Try to load from cache first
      _CacheLogger.step('CACHE_CHECK', 'Attempting to load from cache...');
      final cached = await cacheRepo.loadStats();

      if (cached != null && cached.isValid) {
        _CacheLogger.step(
          'CACHE_HIT',
          '✅ Using valid cached stats: ${cached.totalWorkouts} workouts',
        );
        cacheRepo._isCalculating = false;
        final result = cached.toDashboardStats();
        _CacheLogger.step(
          'PROVIDER_SUCCESS',
          '🎉 Provider completed successfully (from cache)',
        );
        return result;
      }

      _CacheLogger.step(
        'CACHE_MISS',
        '❌ Cache miss or expired, calculating from Firebase...',
      );

      // 2. Calculate from Firebase (first time or cache expired)
      _CacheLogger.step('FIREBASE_START', 'Starting Firebase calculation...');
      final freshStats = await calculator.calculateFromFirebase(
        currentUser.uid,
      );
      _CacheLogger.step(
        'FIREBASE_COMPLETE',
        '✅ Firebase calculation completed',
      );

      // 3. Save to cache for next time
      _CacheLogger.step('CACHE_SAVE_START', 'Saving fresh stats to cache...');
      await cacheRepo.saveStats(freshStats);
      _CacheLogger.step('CACHE_SAVE_COMPLETE', '✅ Stats saved to cache');

      final result = freshStats.toDashboardStats();
      _CacheLogger.step(
        'PROVIDER_SUCCESS',
        '🎉 Provider completed successfully (from Firebase)',
      );
      _CacheLogger.step(
        'PROVIDER_SUCCESS',
        'Final result: ${result.totalWorkouts} workouts, ${result.currentStreak} streak',
      );
      return result;
    } catch (e, stack) {
      _CacheLogger.error('💥 Critical error in cached progress provider', e);
      _CacheLogger.error('Full stack trace: $stack');
      _CacheLogger.step(
        'PROVIDER_ERROR',
        'Rethrowing error to be handled by UI',
      );
      rethrow;
    } finally {
      // Always reset calculating state
      cacheRepo._isCalculating = false;
      _CacheLogger.step('STATE_MANAGER', 'Reset calculating flag to false');
    }
  });
});
