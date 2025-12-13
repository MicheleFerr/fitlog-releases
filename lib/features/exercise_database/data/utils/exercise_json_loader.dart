import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Utility per caricare esercizi dalla nuova struttura a cartelle
///
/// Supporta sia la nuova struttura (assets/data/exercises/)
/// che il fallback al vecchio file singolo (exercises_it.json)
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

  /// Carica tutti gli esercizi dalla nuova struttura a cartelle
  /// con fallback al vecchio file singolo
  static Future<List<Map<String, dynamic>>> loadExercises(String languageCode) async {
    // Prima prova la nuova struttura
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
        // File potrebbe non esistere, continua
        if (kDebugMode) {
          debugPrint('Could not load $baseFolder/$fileName: $e');
        }
      }
    }

    // Se la nuova struttura ha dati, usala
    if (allExercises.isNotEmpty) {
      return allExercises;
    }

    // Fallback al vecchio file singolo
    try {
      final legacyFileName = languageCode == 'it'
          ? 'assets/data/exercises_it.json'
          : 'assets/data/exercises.json';

      final jsonString = await rootBundle.loadString(legacyFileName);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load exercises from legacy file: $e');
      }
      return [];
    }
  }
}
