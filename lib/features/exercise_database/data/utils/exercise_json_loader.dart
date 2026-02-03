import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Utility per caricare esercizi dalla struttura a cartelle
///
/// Struttura: assets/data/exercises/ (IT) e assets/data/exercises_en/ (EN)
/// File: core.json, upper_push.json, upper_pull.json, lower.json, other.json
///
/// ⚡ PERFORMANCE: Static cache prevents duplicate loads when multiple providers
/// watch exercisesDatabaseProvider simultaneously during app startup
class ExerciseJsonLoader {
  ExerciseJsonLoader._();

  /// File nella nuova struttura splittata
  static const exerciseFiles = [
    'core.json',
    'upper_push.json',
    'upper_pull.json',
    'lower.json',
    'other.json',
  ];

  /// Static cache to prevent duplicate loads
  /// Key: languageCode (e.g., "it", "en")
  static final Map<String, List<Map<String, dynamic>>> _cache = {};

  /// In-flight requests to prevent concurrent loads
  static final Map<String, Future<List<Map<String, dynamic>>>> _pending = {};

  /// Carica tutti gli esercizi dalla struttura a cartelle
  /// ⚡ CACHED: Returns cached data if available, prevents duplicate asset loads
  static Future<List<Map<String, dynamic>>> loadExercises(
    String languageCode,
  ) async {
    // Return cached data if available
    if (_cache.containsKey(languageCode)) {
      if (kDebugMode) {
        debugPrint('📖 Loaded ${_cache[languageCode]!.length} exercises from cache');
      }
      return _cache[languageCode]!;
    }

    // If already loading, return the pending future
    if (_pending.containsKey(languageCode)) {
      if (kDebugMode) {
        debugPrint('⏳ Waiting for pending load...');
      }
      return _pending[languageCode]!;
    }

    // Start new load
    final loadFuture = _loadExercisesInternal(languageCode);
    _pending[languageCode] = loadFuture;

    try {
      final exercises = await loadFuture;
      _cache[languageCode] = exercises;
      if (kDebugMode) {
        debugPrint('📖 Loaded ${exercises.length} exercises from assets');
      }
      return exercises;
    } finally {
      _pending.remove(languageCode);
    }
  }

  /// Internal method to actually load from assets
  static Future<List<Map<String, dynamic>>> _loadExercisesInternal(
    String languageCode,
  ) async {
    final baseFolder = languageCode == 'it'
        ? 'assets/data/exercises'
        : 'assets/data/exercises_en';

    final List<Map<String, dynamic>> allExercises = [];

    for (final fileName in exerciseFiles) {
      try {
        final jsonString = await rootBundle.loadString('$baseFolder/$fileName');
        final List<dynamic> jsonList = json.decode(jsonString);
        allExercises.addAll(jsonList.cast<Map<String, dynamic>>());
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Could not load $baseFolder/$fileName: $e');
        }
      }
    }

    return allExercises;
  }

  /// Clear cache (useful for testing or language change)
  static void clearCache() {
    _cache.clear();
    _pending.clear();
  }
}
