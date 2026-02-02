import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Utility per caricare esercizi dalla struttura a cartelle
///
/// Struttura: assets/data/exercises/ (IT) e assets/data/exercises_en/ (EN)
/// File: core.json, upper_push.json, upper_pull.json, lower.json, other.json
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

  /// Carica tutti gli esercizi dalla struttura a cartelle
  static Future<List<Map<String, dynamic>>> loadExercises(
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
}
