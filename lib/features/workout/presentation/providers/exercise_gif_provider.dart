/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Provider per recuperare URL delle GIF degli esercizi dal database
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Provider per il caricamento del database esercizi
/// Carica il file corretto in base alla lingua dell'app
final exercisesDatabaseProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    // Ottieni la lingua dell'app
    final locale = ref.watch(localeProvider);
    final languageCode = locale.languageCode;

    // Scegli il file giusto in base alla lingua
    final fileName = languageCode == 'it'
        ? 'assets/data/exercises_it.json'
        : 'assets/data/exercises.json';

    if (kDebugMode) {
      debugPrint('🌍 Loading exercises database for language: $languageCode -> $fileName');
    }

    final jsonString = await rootBundle.loadString(fileName);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Error loading exercises database: $e');
    }
    return [];
  }
});

/// Provider per ottenere l'URL della GIF di un esercizio specifico
final exerciseGifUrlProvider = Provider.family<AsyncValue<String?>, String>((ref, exerciseName) {
  final exercisesAsync = ref.watch(exercisesDatabaseProvider);

  return exercisesAsync.when(
    data: (exercises) {
      // Normalizza il nome dell'esercizio per il matching
      final normalizedName = _normalizeExerciseName(exerciseName);

      if (kDebugMode) {
        debugPrint('🔍 Searching GIF for: "$exerciseName" (normalized: "$normalizedName")');
      }

      // Cerca l'esercizio nel database con matching flessibile
      try {
        // Prima prova match esatto
        var exercise = exercises.firstWhere(
          (ex) {
            final dbName = _normalizeExerciseName(ex['nome'] ?? '');
            return dbName == normalizedName;
          },
          orElse: () => <String, dynamic>{},
        );

        // Se non trova match esatto, prova match parziale
        if (exercise.isEmpty) {
          if (kDebugMode) {
            debugPrint('🔍 No exact match, trying partial match...');
          }

          exercise = exercises.firstWhere(
            (ex) => _namesMatch(exerciseName, ex['nome'] ?? ''),
            orElse: () => <String, dynamic>{},
          );
        }

        final gifUrl = exercise['imageUrl'] as String?;

        if (kDebugMode) {
          if (gifUrl != null) {
            debugPrint('✅ Found GIF for "$exerciseName": $gifUrl');
          } else if (exercise.isNotEmpty) {
            debugPrint('⚠️ Exercise found but no imageUrl for "$exerciseName"');
          } else {
            debugPrint('❌ Exercise not found in DB: "$exerciseName"');
          }
        }

        return AsyncValue.data(gifUrl);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error searching exercise: $e');
        }
        return const AsyncValue.data(null);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Normalizza il nome dell'esercizio per il matching
/// - Converte in lowercase
/// - Rimuove spazi extra
/// - Sostituisce underscore con spazi
String _normalizeExerciseName(String name) {
  return name
      .toLowerCase()
      .trim()
      .replaceAll('_', ' ') // Sostituisce underscore con spazi
      .replaceAll(RegExp(r'\s+'), ' ') // Normalizza spazi multipli
      .replaceAll(RegExp(r'[^\w\s]'), ''); // Rimuove caratteri speciali
}

/// Verifica se due nomi sono simili (match parziale)
bool _namesMatch(String name1, String name2) {
  final n1 = _normalizeExerciseName(name1);
  final n2 = _normalizeExerciseName(name2);

  // Match esatto
  if (n1 == n2) return true;

  // Match parziale: uno contiene l'altro
  if (n1.contains(n2) || n2.contains(n1)) return true;

  // Match per parole: tutte le parole di n2 sono in n1
  final words1 = n1.split(' ').where((w) => w.isNotEmpty).toSet();
  final words2 = n2.split(' ').where((w) => w.isNotEmpty).toSet();

  if (words2.every((word) => words1.contains(word))) return true;

  return false;
}
