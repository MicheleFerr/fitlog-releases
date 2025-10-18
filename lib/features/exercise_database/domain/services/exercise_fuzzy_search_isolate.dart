/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: isolate service
///
/// Persistent isolate per fuzzy search ottimizzato (pre-indexed)
library;

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:fuzzy_bolt/fuzzy_bolt.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Messaggio per comunicazione con isolate
class _SearchMessage {
  final String query;
  final List<Exercise> exercises;
  final Map<String, double> userBoosts; // Pre-calculated boosts
  final String? currentCategory;
  final double strictThreshold;
  final double typeThreshold;
  final int maxResults;
  final SendPort replyPort;

  _SearchMessage({
    required this.query,
    required this.exercises,
    required this.userBoosts,
    this.currentCategory,
    required this.strictThreshold,
    required this.typeThreshold,
    required this.maxResults,
    required this.replyPort,
  });
}

/// Risultato serializzabile per invio da isolate
class _SearchResult {
  final String exerciseId;
  final double score;
  final String matchedText;
  final bool wasAutoCorrected;

  _SearchResult({
    required this.exerciseId,
    required this.score,
    required this.matchedText,
    required this.wasAutoCorrected,
  });
}

/// Servizio per gestire persistent isolate per fuzzy search
///
/// Vantaggi:
/// - Isolate creato UNA SOLA VOLTA all'avvio app
/// - Evita overhead creazione/distruzione isolate (200ms saved per search)
/// - Pre-calcola ML boosts fuori dall'isolate
/// - Ottimizzato per 1500+ esercizi
class ExerciseFuzzySearchIsolate {
  /// Singleton instance
  static final ExerciseFuzzySearchIsolate _instance =
      ExerciseFuzzySearchIsolate._internal();

  factory ExerciseFuzzySearchIsolate() => _instance;

  ExerciseFuzzySearchIsolate._internal();

  /// Isolate reference
  Isolate? _isolate;

  /// Port per inviare messaggi all'isolate
  SendPort? _sendPort;

  /// Receive port per ricevere messaggi
  ReceivePort? _receivePort;

  /// Flag inizializzazione
  bool _isInitialized = false;

  /// Inizializza isolate persistente
  ///
  /// Chiamare all'avvio app (es: main.dart o app initialization)
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('⚠️ ExerciseFuzzySearchIsolate already initialized');
      }
      return;
    }

    try {
      // Create receive port
      _receivePort = ReceivePort();

      // Spawn isolate
      _isolate = await Isolate.spawn(
        _isolateEntryPoint,
        _receivePort!.sendPort,
        debugName: 'ExerciseFuzzySearchIsolate',
      );

      // Get send port from isolate
      _sendPort = await _receivePort!.first as SendPort;

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ ExerciseFuzzySearchIsolate initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize isolate: $e');
      }
      _isInitialized = false;
    }
  }

  /// Entry point isolate
  static void _isolateEntryPoint(SendPort callerSendPort) {
    // Create receive port in isolate
    final isolateReceivePort = ReceivePort();

    // Send sendPort back to main isolate
    callerSendPort.send(isolateReceivePort.sendPort);

    // Listen for search requests
    isolateReceivePort.listen((dynamic data) {
      final message = data as _SearchMessage;

      // Perform search and handle results (don't await in listen callback)
      _performSearch(message).then((results) {
        message.replyPort.send(results);
      }).catchError((e) {
        // Send error back
        message.replyPort.send(<_SearchResult>[]);
        if (kDebugMode) {
          debugPrint('❌ Isolate search error: $e');
        }
      });
    });
  }

  /// Esegui fuzzy search nell'isolate
  static Future<List<_SearchResult>> _performSearch(
      _SearchMessage message) async {
    // Normalizza query
    final normalizedQuery = _normalizeQuery(message.query);

    // Threshold dinamici per query corte
    final effectiveStrictThreshold = normalizedQuery.length < 4
        ? 0.60
        : message.strictThreshold;
    final effectiveTypeThreshold = normalizedQuery.length < 4
        ? 0.45
        : message.typeThreshold;

    // Fuzzy search con fuzzy_bolt
    // NOTE: skipIsolate=true perché siamo GIÀ in un isolate!
    final results = await FuzzyBolt.searchWithScores<Exercise>(
      message.exercises,
      normalizedQuery,
      selectors: [
        (e) => _normalizeString(e.nome),
        (e) => e.aliases.map((a) => _normalizeString(a)).join(' '),
      ],
      strictThreshold: effectiveStrictThreshold,
      typeThreshold: effectiveTypeThreshold,
      skipIsolate: true, // CRITICO: siamo già in isolate!
      maxResults: message.maxResults, // No *2, optimized
    );

    // Converti in formato serializzabile + apply ML boosts
    final searchResults = results.map((r) {
      final normalizedNome = _normalizeString(r.item.nome);
      final isExactNameMatch = normalizedNome.contains(normalizedQuery);
      final isStartOfName = normalizedNome.startsWith(normalizedQuery);

      // 1. Fuzzy score con name match boost
      double fuzzyScore = r.score;
      if (isExactNameMatch) {
        fuzzyScore = fuzzyScore * 1.3;
        if (isStartOfName) {
          fuzzyScore = fuzzyScore * 1.2;
        }
      }
      fuzzyScore = fuzzyScore > 1.0 ? 1.0 : fuzzyScore;

      // 2. User boost (pre-calculated da main thread)
      final userBoost = message.userBoosts[r.item.id] ?? 0.0;

      // 3. Category boost
      double categoryBoost = 0.0;
      if (message.currentCategory != null) {
        final exerciseCategories = r.item.focus.map((f) => f.toLowerCase());
        final normalizedCurrentCategory =
            message.currentCategory!.toLowerCase();

        if (exerciseCategories.contains(normalizedCurrentCategory)) {
          categoryBoost = 1.0;
        } else if (exerciseCategories.any((cat) =>
            cat.contains(normalizedCurrentCategory) ||
            normalizedCurrentCategory.contains(cat))) {
          categoryBoost = 0.5;
        }
      }

      // 4. Formula combinata
      final finalScore =
          (0.5 * fuzzyScore) + (0.3 * userBoost) + (0.2 * categoryBoost);
      final cappedScore = finalScore > 1.0 ? 1.0 : finalScore;

      return _SearchResult(
        exerciseId: r.item.id,
        score: cappedScore,
        matchedText: r.matchedText ?? r.item.nome,
        wasAutoCorrected: r.score < 0.95,
      );
    }).toList();

    // Re-sort per score
    searchResults.sort((a, b) => b.score.compareTo(a.score));

    return searchResults;
  }

  /// Esegui search (chiamata da main thread)
  Future<List<ExerciseFuzzySearchResult>> search({
    required String query,
    required List<Exercise> exercises,
    required Map<String, double> userBoosts,
    String? currentCategory,
    double strictThreshold = 0.65,
    double typeThreshold = 0.50,
    int maxResults = 50,
  }) async {
    if (!_isInitialized || _sendPort == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Isolate not initialized, initializing now...');
      }
      await initialize();

      // If still not initialized, return empty
      if (!_isInitialized || _sendPort == null) {
        if (kDebugMode) {
          debugPrint('❌ Failed to initialize isolate');
        }
        return [];
      }
    }

    // Create reply port per ricevere risultati
    final replyPort = ReceivePort();

    // Invia messaggio all'isolate
    _sendPort!.send(_SearchMessage(
      query: query,
      exercises: exercises,
      userBoosts: userBoosts,
      currentCategory: currentCategory,
      strictThreshold: strictThreshold,
      typeThreshold: typeThreshold,
      maxResults: maxResults,
      replyPort: replyPort.sendPort,
    ));

    // Aspetta risultati (con timeout)
    try {
      final results = await replyPort.first
          .timeout(const Duration(seconds: 5)) as List<_SearchResult>;

      // Converti back in ExerciseFuzzySearchResult con Exercise completo
      final exerciseMap = {for (var e in exercises) e.id: e};

      return results
          .map((r) {
            final exercise = exerciseMap[r.exerciseId];
            if (exercise == null) return null;

            return ExerciseFuzzySearchResult(
              exercise: exercise,
              score: r.score,
              matchedText: r.matchedText,
              wasAutoCorrected: r.wasAutoCorrected,
            );
          })
          .whereType<ExerciseFuzzySearchResult>()
          .toList();
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('❌ Search timeout');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Search error: $e');
      }
      return [];
    } finally {
      replyPort.close();
    }
  }

  /// Normalizza query
  static String _normalizeQuery(String query) {
    return _normalizeString(query);
  }

  /// Normalizza stringa
  static String _normalizeString(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .trim();
  }

  /// Dispose isolate
  Future<void> dispose() async {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    _isInitialized = false;

    if (kDebugMode) {
      debugPrint('🔒 ExerciseFuzzySearchIsolate disposed');
    }
  }
}

/// Risultato search (versione public API)
class ExerciseFuzzySearchResult {
  final Exercise exercise;
  final double score;
  final String matchedText;
  final bool wasAutoCorrected;

  ExerciseFuzzySearchResult({
    required this.exercise,
    required this.score,
    required this.matchedText,
    required this.wasAutoCorrected,
  });

  /// Formatta score come percentuale
  String get scorePercentage => '${(score * 100).toStringAsFixed(0)}%';

  /// Livello di confidenza
  String get confidenceLevel {
    if (score >= 0.90) return 'High';
    if (score >= 0.75) return 'Medium';
    return 'Low';
  }

  @override
  String toString() {
    return 'ExerciseFuzzySearchResult(name: ${exercise.nome}, score: $scorePercentage, autocorrected: $wasAutoCorrected)';
  }
}
