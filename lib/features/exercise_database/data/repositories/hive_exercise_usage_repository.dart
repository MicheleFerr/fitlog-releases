/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/repositories
/// 🎯 Feature: exercise_database
/// 🔧 Type: repository implementation
///
/// Hive implementation of IExerciseUsageRepository
///
/// This repository handles local storage of exercise usage data using Hive.
/// It provides persistence for ML-enhanced personalized exercise suggestions.
library;

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/repositories/i_exercise_usage_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';

/// Hive-based implementation of exercise usage tracking repository
///
/// Features:
/// - Local-first: Data stored on device with Hive
/// - Fast batch operations: getBatchBoosts optimized for 1000+ exercises
/// - Automatic normalization: Boost scores relative to most-used exercise
/// - Thread-safe: Box operations are atomic
///
/// Example usage:
/// ```dart
/// final box = await Hive.openBox<ExerciseUsageModel>('exercise_usage');
/// final repository = HiveExerciseUsageRepository(box);
/// await repository.initialize();
///
/// // Increment usage
/// await repository.incrementUsage(
///   exerciseId: 'squat_123',
///   exerciseName: 'Squat',
///   userId: 'user_456',
/// );
///
/// // Get batch boosts for fuzzy search
/// final boosts = await repository.getBatchBoosts(['squat_123', 'bench_456']);
/// ```
class HiveExerciseUsageRepository implements IExerciseUsageRepository {
  /// Hive box for exercise usage data
  final Box<ExerciseUsageModel> _box;

  /// Flag to track initialization state
  bool _isInitialized = false;

  /// Create repository with Hive box
  ///
  /// [_box] - Pre-opened Hive box for ExerciseUsageModel
  ///
  /// Note: Box should be opened before creating repository instance
  HiveExerciseUsageRepository(this._box);

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('⚠️ HiveExerciseUsageRepository already initialized');
      }
      return;
    }

    try {
      // Verify box is open
      if (!_box.isOpen) {
        throw Exception('Hive box is not open. Open box before creating repository.');
      }

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ HiveExerciseUsageRepository initialized: ${_box.length} entries');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ HiveExerciseUsageRepository initialization error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> incrementUsage({
    required String exerciseId,
    required String exerciseName,
    required String userId,
  }) async {
    try {
      _ensureInitialized();

      // Check if entry already exists
      final existingEntry = _box.get(exerciseId);

      if (existingEntry != null) {
        // Increment existing entry
        existingEntry.increment();
        if (kDebugMode) {
          debugPrint('📈 Exercise usage incremented: $exerciseName (${existingEntry.usageCount})');
        }
      } else {
        // Create new entry for first use
        final newEntry = ExerciseUsageModel.firstUse(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          userId: userId,
        );
        await _box.put(exerciseId, newEntry);
        if (kDebugMode) {
          debugPrint('✅ New exercise usage tracked: $exerciseName');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error incrementing usage: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> decrementUsage({
    required String exerciseId,
  }) async {
    try {
      _ensureInitialized();

      final entry = _box.get(exerciseId);
      if (entry != null) {
        entry.decrement();
        if (kDebugMode) {
          debugPrint('📉 Exercise usage decremented: ${entry.exerciseName} (${entry.usageCount})');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error decrementing usage: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> removeExercise({
    required String exerciseId,
  }) async {
    try {
      _ensureInitialized();

      if (_box.containsKey(exerciseId)) {
        await _box.delete(exerciseId);
        if (kDebugMode) {
          debugPrint('🗑️ Exercise removed from usage tracking: $exerciseId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error removing exercise: $e');
      }
      rethrow;
    }
  }

  @override
  Future<double> getBoost(String exerciseId) async {
    try {
      _ensureInitialized();

      // Get entry
      final entry = _box.get(exerciseId);
      if (entry == null) return 0.0;

      // Find max count for normalization
      final maxCount = _getMaxCount();

      // Calculate normalized boost
      return entry.getBoost(maxCount);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting boost: $e');
      }
      return 0.0;
    }
  }

  @override
  Future<Map<String, double>> getBatchBoosts(List<String> exerciseIds) async {
    try {
      _ensureInitialized();

      // OPTIMIZATION: Calculate max count ONCE instead of N times
      final maxCount = _getMaxCount();

      // Batch lookup with single iteration
      final boosts = <String, double>{};
      for (final id in exerciseIds) {
        final entry = _box.get(id);
        boosts[id] = entry?.getBoost(maxCount) ?? 0.0;
      }

      return boosts;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting batch boosts: $e');
      }
      // Return 0.0 for all exercises on error
      return {for (final id in exerciseIds) id: 0.0};
    }
  }

  @override
  Future<Map<String, int>> getUserUsageCounts() async {
    try {
      _ensureInitialized();

      return Map.fromEntries(
        _box.values.map((entry) => MapEntry(entry.exerciseId, entry.usageCount)),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting usage counts: $e');
      }
      return {};
    }
  }

  @override
  Future<List<ExerciseUsageModel>> getTopUsedExercises({int limit = 10}) async {
    try {
      _ensureInitialized();

      // Sort by usage count descending
      final sorted = _box.values.toList()
        ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

      return sorted.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting top exercises: $e');
      }
      return [];
    }
  }

  @override
  Future<List<ExerciseUsageModel>> getRecentlyUsedExercises({int limit = 10}) async {
    try {
      _ensureInitialized();

      // Sort by last used timestamp descending
      final sorted = _box.values.toList()
        ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));

      return sorted.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting recent exercises: $e');
      }
      return [];
    }
  }

  @override
  Future<void> resetAllUsage() async {
    try {
      _ensureInitialized();

      await _box.clear();
      if (kDebugMode) {
        debugPrint('🗑️ All exercise usage data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error resetting usage: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _box.close();
      _isInitialized = false;
      if (kDebugMode) {
        debugPrint('🔒 HiveExerciseUsageRepository disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing repository: $e');
      }
    }
  }

  /// Get maximum usage count across all exercises
  ///
  /// Used for normalizing boost scores (max count = 1.0 boost)
  int _getMaxCount() {
    if (_box.isEmpty) return 0;

    return _box.values
        .map((e) => e.usageCount)
        .reduce((max, count) => count > max ? count : max);
  }

  /// Ensure repository is initialized before operations
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'HiveExerciseUsageRepository not initialized. Call initialize() first.',
      );
    }
  }
}
