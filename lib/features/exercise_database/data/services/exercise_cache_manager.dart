/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: service
///
/// Gestione cache locale degli esercizi con Hive per funzionamento offline
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_model.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

class ExerciseCacheManager {
  ExerciseCacheManager([HiveBoxManagerEnhanced? boxManager])
      : _boxManager = boxManager ?? HiveBoxManagerEnhanced();

  static const String _exercisesBoxName = 'exercises_cache';
  static const String _metadataBoxName = 'exercises_metadata';
  static const String _syncQueueBoxName = 'exercises_sync_queue';

  final HiveBoxManagerEnhanced _boxManager;
  late Box<Map> _exercisesBox;
  late Box<Map> _metadataBox;
  late Box<Map> _syncQueueBox;

  bool _initialized = false;

  /// Inizializza le Hive boxes
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _exercisesBox = await _boxManager.openBox<Map>(_exercisesBoxName);
      _metadataBox = await _boxManager.openBox<Map>(_metadataBoxName);
      _syncQueueBox = await _boxManager.openBox<Map>(_syncQueueBoxName);

      _initialized = true;
      debugPrint('✅ ExerciseCacheManager initialized');

      // Log statistiche cache
      await _logCacheStats();
    } catch (e) {
      debugPrint('❌ Failed to initialize ExerciseCacheManager: $e');
      rethrow;
    }
  }

  /// Salva esercizi nella cache
  Future<void> cacheExercises(List<Exercise> exercises, String version) async {
    await _ensureInitialized();

    try {
      debugPrint('💾 Caching ${exercises.length} exercises (v$version)...');

      // Inizia una transazione
      final batch = <String, Map<String, dynamic>>{};

      for (final exercise in exercises) {
        final exerciseModel = ExerciseModel.fromEntity(exercise);
        batch[exercise.id] = exerciseModel.toJson();
      }

      // Salva tutti gli esercizi in una volta
      await _exercisesBox.putAll(batch);

      // Aggiorna metadata
      await _updateCacheMetadata(version, exercises.length);

      debugPrint('✅ Successfully cached ${exercises.length} exercises');

    } catch (e) {
      debugPrint('❌ Failed to cache exercises: $e');
      rethrow;
    }
  }

  /// Carica tutti gli esercizi dalla cache
  Future<List<Exercise>> getCachedExercises() async {
    await _ensureInitialized();

    try {
      if (_exercisesBox.isEmpty) {
        debugPrint('📂 No exercises in cache');
        return [];
      }

      final exercises = <Exercise>[];

      for (final entry in _exercisesBox.values) {
        try {
          final exerciseData = Map<String, dynamic>.from(entry);
          final exercise = ExerciseModel.fromJson(exerciseData).toEntity();
          exercises.add(exercise);
        } catch (e) {
          debugPrint('⚠️ Failed to parse cached exercise: $e');
          continue;
        }
      }

      debugPrint('📖 Loaded ${exercises.length} exercises from cache');
      return exercises;

    } catch (e) {
      debugPrint('❌ Failed to get cached exercises: $e');
      return [];
    }
  }

  /// Carica un singolo esercizio dalla cache
  Future<Exercise?> getCachedExercise(String exerciseId) async {
    await _ensureInitialized();

    try {
      final exerciseData = _exercisesBox.get(exerciseId);
      if (exerciseData == null) return null;

      final exercise = ExerciseModel.fromJson(Map<String, dynamic>.from(exerciseData)).toEntity();
      return exercise;

    } catch (e) {
      debugPrint('❌ Failed to get cached exercise $exerciseId: $e');
      return null;
    }
  }

  /// Aggiorna un singolo esercizio nella cache
  Future<void> updateCachedExercise(Exercise exercise) async {
    await _ensureInitialized();

    try {
      final exerciseModel = ExerciseModel.fromEntity(exercise);
      await _exercisesBox.put(exercise.id, exerciseModel.toJson());

      debugPrint('✏️ Updated exercise ${exercise.id} in cache');

    } catch (e) {
      debugPrint('❌ Failed to update cached exercise: $e');
      rethrow;
    }
  }

  /// Rimuove un esercizio dalla cache
  Future<void> removeCachedExercise(String exerciseId) async {
    await _ensureInitialized();

    try {
      await _exercisesBox.delete(exerciseId);
      debugPrint('🗑️ Removed exercise $exerciseId from cache');

    } catch (e) {
      debugPrint('❌ Failed to remove cached exercise: $e');
      rethrow;
    }
  }

  /// Ottiene metadata della cache
  Future<CacheMetadata?> getCacheMetadata() async {
    await _ensureInitialized();

    try {
      final data = _metadataBox.get('metadata');
      if (data == null) return null;

      return CacheMetadata.fromMap(Map<String, dynamic>.from(data));

    } catch (e) {
      debugPrint('❌ Failed to get cache metadata: $e');
      return null;
    }
  }

  /// Aggiorna metadata della cache
  Future<void> _updateCacheMetadata(String version, int exerciseCount) async {
    final metadata = CacheMetadata(
      version: version,
      exerciseCount: exerciseCount,
      lastUpdated: DateTime.now(),
      cacheSize: await _calculateCacheSize(),
    );

    await _metadataBox.put('metadata', metadata.toMap());
  }

  /// Cerca esercizi nella cache
  Future<List<Exercise>> searchCachedExercises(String query) async {
    await _ensureInitialized();

    if (query.isEmpty) return getCachedExercises();

    try {
      final allExercises = await getCachedExercises();
      final lowerQuery = query.toLowerCase();

      return allExercises.where((exercise) {
        return exercise.nome.toLowerCase().contains(lowerQuery) ||
               exercise.focusDisplayName.toLowerCase().contains(lowerQuery) ||
               exercise.attrezzatura.toLowerCase().contains(lowerQuery) ||
               exercise.muscoliSecondariDisplayName.toLowerCase().contains(lowerQuery);
      }).toList();

    } catch (e) {
      debugPrint('❌ Failed to search cached exercises: $e');
      return [];
    }
  }

  /// Filtra esercizi per focus
  Future<List<Exercise>> getCachedExercisesByFocus(List<String> focusGroups) async {
    await _ensureInitialized();

    try {
      final allExercises = await getCachedExercises();

      return allExercises.where((exercise) {
        return exercise.focus.any((focus) => focusGroups.contains(focus));
      }).toList();

    } catch (e) {
      debugPrint('❌ Failed to get exercises by focus: $e');
      return [];
    }
  }

  /// Aggiunge modifiche alla queue di sincronizzazione
  Future<void> addToSyncQueue(String exerciseId, Map<String, dynamic> changes, SyncOperation operation) async {
    await _ensureInitialized();

    try {
      final syncItem = SyncQueueItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_$exerciseId',
        exerciseId: exerciseId,
        operation: operation,
        changes: changes,
        timestamp: DateTime.now(),
      );

      await _syncQueueBox.put(syncItem.id, syncItem.toMap());
      debugPrint('📋 Added to sync queue: ${operation.name} for $exerciseId');

    } catch (e) {
      debugPrint('❌ Failed to add to sync queue: $e');
    }
  }

  /// Ottiene elementi dalla queue di sincronizzazione
  Future<List<SyncQueueItem>> getSyncQueue() async {
    await _ensureInitialized();

    try {
      final items = <SyncQueueItem>[];

      for (final entry in _syncQueueBox.values) {
        try {
          final item = SyncQueueItem.fromMap(Map<String, dynamic>.from(entry));
          items.add(item);
        } catch (e) {
          debugPrint('⚠️ Failed to parse sync queue item: $e');
        }
      }

      return items..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    } catch (e) {
      debugPrint('❌ Failed to get sync queue: $e');
      return [];
    }
  }

  /// Rimuove elemento dalla queue di sincronizzazione
  Future<void> removeSyncQueueItem(String itemId) async {
    await _ensureInitialized();

    try {
      await _syncQueueBox.delete(itemId);
      debugPrint('✅ Removed sync queue item: $itemId');

    } catch (e) {
      debugPrint('❌ Failed to remove sync queue item: $e');
    }
  }

  /// Pulisce la cache completamente
  Future<void> clearCache() async {
    await _ensureInitialized();

    try {
      await _exercisesBox.clear();
      await _metadataBox.clear();
      await _syncQueueBox.clear();

      debugPrint('🧹 Cache cleared completely');

    } catch (e) {
      debugPrint('❌ Failed to clear cache: $e');
      rethrow;
    }
  }

  /// Pulisce cache vecchia
  Future<void> cleanupOldCache(Duration maxAge) async {
    await _ensureInitialized();

    try {
      final metadata = await getCacheMetadata();
      if (metadata == null) return;

      final now = DateTime.now();
      if (now.difference(metadata.lastUpdated) > maxAge) {
        await clearCache();
        debugPrint('🧹 Cleaned up old cache (age: ${now.difference(metadata.lastUpdated).inHours}h)');
      }

    } catch (e) {
      debugPrint('❌ Failed to cleanup old cache: $e');
    }
  }

  /// Calcola dimensione cache
  Future<int> _calculateCacheSize() async {
    try {
      int size = 0;

      // Calcola dimensione approssimativa
      for (final entry in _exercisesBox.values) {
        final jsonString = jsonEncode(entry);
        size += jsonString.length;
      }

      return size;
    } catch (e) {
      return 0;
    }
  }

  /// Log statistiche cache
  Future<void> _logCacheStats() async {
    if (!kDebugMode) return; // Skip in release mode

    try {
      final metadata = await getCacheMetadata();
      if (metadata != null) {
        debugPrint('📊 Cache: ${metadata.exerciseCount} exercises (v${metadata.version})');
      }
    } catch (e) {
      // Silent fail in release
    }
  }

  /// Assicura che il manager sia inizializzato
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Cleanup delle risorse
  Future<void> dispose() async {
    if (_initialized) {
      await _exercisesBox.close();
      await _metadataBox.close();
      await _syncQueueBox.close();
      _initialized = false;
    }
  }
}

/// Metadata della cache
class CacheMetadata {

  const CacheMetadata({
    required this.version,
    required this.exerciseCount,
    required this.lastUpdated,
    required this.cacheSize,
  });

  factory CacheMetadata.fromMap(Map<String, dynamic> map) {
    return CacheMetadata(
      version: map['version'] as String,
      exerciseCount: map['exercise_count'] as int,
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      cacheSize: map['cache_size'] as int,
    );
  }
  final String version;
  final int exerciseCount;
  final DateTime lastUpdated;
  final int cacheSize;

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'exercise_count': exerciseCount,
      'last_updated': lastUpdated.toIso8601String(),
      'cache_size': cacheSize,
    };
  }
}

/// Elemento della queue di sincronizzazione
class SyncQueueItem {

  const SyncQueueItem({
    required this.id,
    required this.exerciseId,
    required this.operation,
    required this.changes,
    required this.timestamp,
  });

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as String,
      exerciseId: map['exercise_id'] as String,
      operation: SyncOperation.values.firstWhere(
        (e) => e.name == map['operation'],
        orElse: () => SyncOperation.update,
      ),
      changes: Map<String, dynamic>.from(map['changes'] as Map),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
  final String id;
  final String exerciseId;
  final SyncOperation operation;
  final Map<String, dynamic> changes;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'operation': operation.name,
      'changes': changes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Tipi di operazioni di sincronizzazione
enum SyncOperation {
  create,
  update,
  delete,
}