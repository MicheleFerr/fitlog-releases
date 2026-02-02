/// 🏋️ Workout Template Cache Service
///
/// Servizio per il caching locale delle modifiche ai template durante la sessione.
/// Permette di salvare automaticamente le modifiche (note, pesi, reps) e ricaricarle
/// quando si riapre lo stesso template.
///
/// Features:
/// - Auto-save delle modifiche durante la sessione
/// - Carica l'ultima versione modificata invece del template originale
/// - Possibilità di resettare alla versione originale
/// - Cleanup automatico dei dati vecchi (> 30 giorni)
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

class WorkoutTemplateCacheService {
  WorkoutTemplateCacheService({HiveBoxManagerEnhanced? boxManager})
    : _boxManager = boxManager ?? HiveBoxManagerEnhanced();

  final HiveBoxManagerEnhanced _boxManager;
  static const String _boxName = 'template_cache';
  static const int _maxCacheDays = 30; // Giorni massimi di cache
  static const Duration _debounceTime = Duration(
    seconds: 1,
  ); // Save ogni 1 secondo (ridotto per UX migliore)

  late Box<Map<dynamic, dynamic>> _cacheBox;
  bool _isInitialized = false;
  bool _isDisposed = false; // MEMORY LEAK FIX: Track disposal state

  // Debounce timer per evitare salvataggi continui
  Timer? _debounceTimer;

  // Pending save data
  Map<String, Workout>? _pendingSaveData;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _cacheBox = await _boxManager.openBox<Map<dynamic, dynamic>>(_boxName);
    _isInitialized = true;

    // Cleanup old cache entries
    await _cleanupOldCache();
  }

  /// Save workout modifications to cache with debouncing
  /// This is called automatically when user modifies anything during session
  /// Actual save happens after 1 second of no modifications
  void saveWorkoutModifications({
    required String templateId,
    required Workout workout,
  }) {
    if (!_isInitialized) {
      initialize().then((_) {
        _scheduleDebouncedSave(templateId, workout);
      });
      return;
    }

    _scheduleDebouncedSave(templateId, workout);
  }

  /// Schedule a debounced save
  void _scheduleDebouncedSave(String templateId, Workout workout) {
    // Cancel existing timer if any
    _debounceTimer?.cancel();

    // Store pending data
    _pendingSaveData = {templateId: workout};

    if (kDebugMode) {
      debugPrint(
        '⏱️ [TemplateCache] Scheduled save for template: $templateId (will save in 1 second)',
      );
    }

    // Start new timer
    _debounceTimer = Timer(_debounceTime, () async {
      await _executePendingSave();
    });
  }

  /// Execute pending save
  Future<void> _executePendingSave() async {
    if (_pendingSaveData == null) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [TemplateCache] _executePendingSave called but NO pending data',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '💾 [TemplateCache] _executePendingSave START - Templates: ${_pendingSaveData!.keys.toList()}',
      );
    }

    for (final entry in _pendingSaveData!.entries) {
      try {
        final cacheKey = _getCacheKey(entry.key);
        final cacheData = {
          'workout': entry.value.toJson(),
          'lastModified': DateTime.now().toIso8601String(),
          'templateId': entry.key,
        };

        await _cacheBox.put(cacheKey, cacheData);

        if (kDebugMode) {
          debugPrint('✅ [TemplateCache] Saved template: ${entry.key}');
          debugPrint('   📝 Exercises count: ${entry.value.exercises.length}');
          debugPrint('   🔑 Cache key: $cacheKey');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '❌ [TemplateCache] Error saving template ${entry.key}: $e',
          );
        }
      }
    }

    _pendingSaveData = null;

    if (kDebugMode) {
      debugPrint('✅ [TemplateCache] _executePendingSave COMPLETED');
    }
  }

  /// Force immediate save (useful when app goes to background)
  Future<void> forceSave() async {
    if (kDebugMode) {
      debugPrint(
        '🚀 [TemplateCache] forceSave() CALLED - Pending data: ${_pendingSaveData?.keys.toList()}',
      );
    }

    _debounceTimer?.cancel();

    // FIX: Skip if not initialized (box not opened yet)
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
          '⏭️ [TemplateCache] forceSave() skipped - not initialized yet',
        );
      }
      return;
    }

    await _executePendingSave();

    // 🔥 CRITICAL FIX: Force flush to disk
    try {
      await _cacheBox.flush();
      if (kDebugMode) {
        debugPrint(
          '✅ [TemplateCache] forceSave() COMPLETED with flush to disk',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateCache] Flush failed: $e');
      }
    }
  }

  /// Get cached workout modifications if they exist
  /// Returns null if no cache found or cache is expired
  Future<Workout?> getCachedWorkout(String templateId) async {
    if (!_isInitialized) await initialize();

    if (kDebugMode) {
      debugPrint('🔍 [TemplateCache] getCachedWorkout CALLED for: $templateId');
      debugPrint('   📦 All cache keys: ${_cacheBox.keys.toList()}');
    }

    try {
      final cacheKey = _getCacheKey(templateId);

      if (kDebugMode) {
        debugPrint('   🔑 Looking for cache key: $cacheKey');
      }

      final cacheData = _cacheBox.get(cacheKey);

      if (cacheData == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ [TemplateCache] No cache found for template: $templateId',
          );
        }
        return null;
      }

      if (kDebugMode) {
        debugPrint('✅ [TemplateCache] Cache FOUND for template: $templateId');
        debugPrint('   ⏰ Last modified: ${cacheData['lastModified']}');
      }

      // Check if cache is expired
      final lastModified = DateTime.parse(cacheData['lastModified'] as String);
      final daysDiff = DateTime.now().difference(lastModified).inDays;

      if (daysDiff > _maxCacheDays) {
        if (kDebugMode) {
          debugPrint(
            '⏰ [TemplateCache] Cache expired for template: $templateId ($daysDiff days old)',
          );
        }
        await _cacheBox.delete(cacheKey);
        return null;
      }

      // Reconstruct workout from cache
      // ⚡ FIX: Removed explicit cast to avoid "type '_Map<dynamic, dynamic>' is not a subtype" error
      // Map.from() automatically handles the conversion from Map<dynamic, dynamic> to Map<String, dynamic>
      final workoutJson = Map<String, dynamic>.from(cacheData['workout']);
      final workout = Workout.fromJson(workoutJson);

      if (kDebugMode) {
        debugPrint(
          '✅ [TemplateCache] Loaded cached workout for template: $templateId',
        );
      }

      return workout;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateCache] Error loading cache: $e');
      }
      return null;
    }
  }

  /// Check if template has cached modifications
  Future<bool> hasCache(String templateId) async {
    if (!_isInitialized) await initialize();

    final cacheKey = _getCacheKey(templateId);
    return _cacheBox.containsKey(cacheKey);
  }

  /// Get cache info (last modified date)
  Future<DateTime?> getCacheLastModified(String templateId) async {
    if (!_isInitialized) await initialize();

    try {
      final cacheKey = _getCacheKey(templateId);
      final cacheData = _cacheBox.get(cacheKey);

      if (cacheData == null) return null;

      return DateTime.parse(cacheData['lastModified'] as String);
    } catch (e) {
      return null;
    }
  }

  /// Clear cache for specific template
  Future<void> clearCache(String templateId) async {
    if (!_isInitialized) await initialize();

    try {
      final cacheKey = _getCacheKey(templateId);
      await _cacheBox.delete(cacheKey);

      if (kDebugMode) {
        debugPrint(
          '🗑️ [TemplateCache] Cleared cache for template: $templateId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateCache] Error clearing cache: $e');
      }
    }
  }

  /// Clear all cached templates
  Future<void> clearAllCache() async {
    if (!_isInitialized) await initialize();

    try {
      await _cacheBox.clear();

      if (kDebugMode) {
        debugPrint('🗑️ [TemplateCache] Cleared all template cache');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateCache] Error clearing all cache: $e');
      }
    }
  }

  /// Cleanup old cache entries (> 30 days)
  Future<void> _cleanupOldCache() async {
    try {
      final keysToDelete = <String>[];

      for (final key in _cacheBox.keys) {
        final cacheData = _cacheBox.get(key);
        if (cacheData != null) {
          final lastModified = DateTime.parse(
            cacheData['lastModified'] as String,
          );
          final daysDiff = DateTime.now().difference(lastModified).inDays;

          if (daysDiff > _maxCacheDays) {
            keysToDelete.add(key as String);
          }
        }
      }

      for (final key in keysToDelete) {
        await _cacheBox.delete(key);
      }

      if (keysToDelete.isNotEmpty && kDebugMode) {
        debugPrint(
          '🧹 [TemplateCache] Cleaned up ${keysToDelete.length} old cache entries',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateCache] Error during cleanup: $e');
      }
    }
  }

  /// Get cache key for template
  String _getCacheKey(String templateId) {
    return 'template_$templateId';
  }

  /// Dispose of resources
  /// MEMORY LEAK FIX: Close Hive box to free memory
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _debounceTimer?.cancel();
    _debounceTimer = null;

    forceSave(); // Save any pending data before disposing

    // MEMORY LEAK FIX: Close cache box
    if (_isInitialized && _cacheBox.isOpen) {
      _cacheBox.close();
      if (kDebugMode) {
        debugPrint('✅ WorkoutTemplateCacheService: Closed cache box');
      }
    }
  }
}

/// Provider for the template cache service
final workoutTemplateCacheServiceProvider =
    Provider<WorkoutTemplateCacheService>((ref) {
      final service = WorkoutTemplateCacheService();

      // Initialize on creation with error handling
      service.initialize().catchError((e, stack) {
        if (kDebugMode) {
          debugPrint(
            '[WorkoutTemplateCacheService] Failed to initialize: $e\n$stack',
          );
        }
      });

      // Clean up when provider is disposed
      ref.onDispose(() {
        service.dispose();
      });

      return service;
    });
