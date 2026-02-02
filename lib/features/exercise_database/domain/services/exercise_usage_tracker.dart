/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: service
///
/// Servizio per tracking utilizzo esercizi (ML-enhanced fuzzy search)
library;

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// Servizio per tracciare e gestire l'utilizzo degli esercizi da parte dell'utente
///
/// Features:
/// - Increment/decrement usage count
/// - Calcolo boost score per fuzzy matching
/// - Persistenza con Hive (locale)
/// - Auto-sync con Firebase (future)
class ExerciseUsageTracker {
  factory ExerciseUsageTracker() => _instance;

  ExerciseUsageTracker._internal();

  /// Box Hive per storage locale
  static const String _boxName = 'exercise_usage';

  /// Lazy-loaded box reference
  Box<ExerciseUsageModel>? _box;

  /// HiveBoxManagerEnhanced instance
  HiveBoxManagerEnhanced? _boxManager;

  /// Singleton instance
  static final ExerciseUsageTracker _instance =
      ExerciseUsageTracker._internal();

  /// Inizializza Hive box (chiamare all'avvio app)
  Future<void> initialize({HiveBoxManagerEnhanced? boxManager}) async {
    try {
      _boxManager = boxManager ?? HiveBoxManagerEnhanced();

      // Registra adapter se non già fatto
      if (!Hive.isAdapterRegistered(30)) {
        Hive.registerAdapter(ExerciseUsageModelAdapter());
      }

      // Apri box
      _box = await _boxManager!.openBox<ExerciseUsageModel>(_boxName);

      if (kDebugMode) {
        debugPrint(
          '✅ ExerciseUsageTracker initialized: ${_box!.length} entries',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ExerciseUsageTracker initialization error: $e');
      }
    }
  }

  /// Ottieni box (con lazy loading)
  Future<Box<ExerciseUsageModel>> get _getBox async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
    return _box!;
  }

  /// Incrementa contatore utilizzo per un esercizio
  ///
  /// [exerciseId] - ID univoco esercizio
  /// [exerciseName] - Nome esercizio (per logging)
  /// [userId] - ID utente corrente
  Future<void> incrementUsage({
    required String exerciseId,
    required String exerciseName,
    required String userId,
  }) async {
    try {
      final box = await _getBox;

      // Cerca entry esistente
      final existingEntry = box.get(exerciseId);

      if (existingEntry != null) {
        // Incrementa existing
        existingEntry.increment();
        if (kDebugMode) {
          debugPrint(
            '📈 Exercise usage incremented: $exerciseName (${existingEntry.usageCount})',
          );
        }
      } else {
        // Crea nuovo entry
        final newEntry = ExerciseUsageModel.firstUse(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          userId: userId,
        );
        await box.put(exerciseId, newEntry);
        if (kDebugMode) {
          debugPrint('✅ New exercise usage tracked: $exerciseName');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error incrementing usage: $e');
      }
    }
  }

  /// Decrementa contatore utilizzo (negative feedback)
  ///
  /// [exerciseId] - ID univoco esercizio
  Future<void> decrementUsage({required String exerciseId}) async {
    try {
      final box = await _getBox;

      final entry = box.get(exerciseId);
      if (entry != null) {
        entry.decrement();
        if (kDebugMode) {
          debugPrint(
            '📉 Exercise usage decremented: ${entry.exerciseName} (${entry.usageCount})',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error decrementing usage: $e');
      }
    }
  }

  /// Rimuove completamente un esercizio dai dati di utilizzo
  ///
  /// Questo elimina totalmente l'esercizio dai "popolari" e "recenti"
  /// [exerciseId] - ID univoco esercizio da rimuovere
  Future<void> removeExercise({required String exerciseId}) async {
    try {
      final box = await _getBox;

      if (box.containsKey(exerciseId)) {
        await box.delete(exerciseId);
        if (kDebugMode) {
          debugPrint('🗑️ Exercise removed from usage tracking: $exerciseId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error removing exercise: $e');
      }
    }
  }

  /// Ottieni boost score per un esercizio (0.0 - 1.0)
  ///
  /// [exerciseId] - ID univoco esercizio
  /// Returns: Score 0.0-1.0, dove 1.0 = massimo boost
  Future<double> getBoost(String exerciseId) async {
    try {
      final box = await _getBox;

      // Get entry
      final entry = box.get(exerciseId);
      if (entry == null) return 0.0;

      // Trova max count tra tutti gli esercizi per normalizzazione
      final maxCount = _getMaxCount(box);

      // Calcola boost normalizzato
      return entry.getBoost(maxCount);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting boost: $e');
      }
      return 0.0;
    }
  }

  /// OPTIMIZATION: Batch get boosts per multiple esercizi
  ///
  /// Molto più efficiente di chiamare getBoost() in loop
  /// [exerciseIds] - Lista ID esercizi
  /// Returns: Map exerciseId → boost (0.0-1.0)
  Future<Map<String, double>> getBatchBoosts(List<String> exerciseIds) async {
    try {
      final box = await _getBox;

      // Get max count UNA VOLTA (invece di N volte)
      final maxCount = _getMaxCount(box);

      // Batch lookup
      final boosts = <String, double>{};
      for (final id in exerciseIds) {
        final entry = box.get(id);
        boosts[id] = entry?.getBoost(maxCount) ?? 0.0;
      }

      return boosts;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting batch boosts: $e');
      }
      // Return 0.0 for all
      return {for (final id in exerciseIds) id: 0.0};
    }
  }

  /// Ottieni tutti i contatori utilizzo (per analytics/debug)
  ///
  /// Returns: Map exerciseId → usageCount
  Future<Map<String, int>> getUserUsageCounts() async {
    try {
      final box = await _getBox;

      return Map.fromEntries(
        box.values.map((entry) => MapEntry(entry.exerciseId, entry.usageCount)),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting usage counts: $e');
      }
      return {};
    }
  }

  /// Ottieni top N esercizi più usati
  ///
  /// [limit] - Numero massimo risultati (default 10)
  /// Returns: Lista di ExerciseUsageModel ordinata per usageCount DESC
  Future<List<ExerciseUsageModel>> getTopUsedExercises({int limit = 10}) async {
    try {
      final box = await _getBox;

      // Sort per usageCount DESC
      final sorted = box.values.toList()
        ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

      return sorted.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting top exercises: $e');
      }
      return [];
    }
  }

  /// Ottieni esercizi usati recentemente
  ///
  /// [limit] - Numero massimo risultati (default 10)
  /// Returns: Lista di ExerciseUsageModel ordinata per lastUsedAt DESC
  Future<List<ExerciseUsageModel>> getRecentlyUsedExercises({
    int limit = 10,
  }) async {
    try {
      final box = await _getBox;

      // Sort per lastUsedAt DESC
      final sorted = box.values.toList()
        ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));

      return sorted.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting recent exercises: $e');
      }
      return [];
    }
  }

  /// Reset tutti i contatori (per testing/debug)
  Future<void> resetAllUsage() async {
    try {
      final box = await _getBox;
      await box.clear();
      if (kDebugMode) {
        debugPrint('🗑️ All exercise usage data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error resetting usage: $e');
      }
    }
  }

  /// Ottieni contatore massimo (per normalizzazione boost)
  int _getMaxCount(Box<ExerciseUsageModel> box) {
    if (box.isEmpty) return 0;

    return box.values
        .map((e) => e.usageCount)
        .reduce((max, count) => count > max ? count : max);
  }

  /// 🔐 SECURITY: Clear all usage data on logout to prevent data leakage
  Future<void> clearOnLogout() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.clear();
      }
      if (kDebugMode) {
        debugPrint('🔐 ExerciseUsageTracker cleared on logout');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing ExerciseUsageTracker on logout: $e');
      }
    }
  }

  /// Chiudi box (chiamare in dispose app)
  Future<void> dispose() async {
    await _box?.close();
    if (kDebugMode) {
      debugPrint('🔒 ExerciseUsageTracker disposed');
    }
  }
}
