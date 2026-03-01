import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

class JsonExerciseRepository {
  JsonExerciseRepository({required this.locale});
  final Locale locale;
  List<Exercise>? _cachedExercises;
  String? _cachedLocaleCode;

  Future<List<Exercise>> getAllExercises() async {
    // Clear cache if locale changed
    if (_cachedLocaleCode != locale.languageCode) {
      _cachedExercises = null;
      _cachedLocaleCode = locale.languageCode;
    }

    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    try {
      // Use ExerciseJsonLoader to load from folder structure
      final jsonList = await ExerciseJsonLoader.loadExercises(
        locale.languageCode,
      );

      _cachedExercises = jsonList
          .map((json) => Exercise.fromJson(json))
          .toList();

      return _cachedExercises!;
    } catch (e) {
      throw Exception('Failed to load exercises: $e');
    }
  }

  Future<List<Exercise>> searchExercises(String query) async {
    final exercises = await getAllExercises();
    if (query.isEmpty) return exercises;

    final lowerQuery = query.toLowerCase();
    return exercises.where((exercise) {
      return exercise.nome.toLowerCase().contains(lowerQuery) ||
          exercise.focusDisplayName.toLowerCase().contains(lowerQuery) ||
          exercise.attrezzatura.toLowerCase().contains(lowerQuery) ||
          exercise.muscoliSecondariDisplayName.toLowerCase().contains(
            lowerQuery,
          );
    }).toList();
  }

}

// Providers per il nuovo sistema
// DEPRECATED: Use hybridExerciseRepositoryProvider from hybrid_exercise_provider.dart instead
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
@Deprecated(
  'Use hybridExerciseRepositoryProvider from hybrid_exercise_provider.dart',
)
final jsonExerciseRepositoryProvider =
    FutureProvider.autoDispose<List<Exercise>>((ref) async {
      final locale = ref.watch(localeProvider);
      final repository = JsonExerciseRepository(locale: locale);
      return repository.getAllExercises();
    });
