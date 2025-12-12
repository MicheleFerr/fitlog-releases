/// Exercise Name Mapper
///
/// Maps exercise names from imported CSV to our exercise database.
/// Uses fuzzy matching to handle variations in exercise naming.
///
/// **Common mappings**:
/// - "Flat Barbell Bench Press" → "Panca Piana con Bilanciere"
/// - "Squat (Barbell)" → "Squat con Bilanciere"
/// - "Pull Up" / "Pull-Up" / "Pullup" → "Trazioni alla Sbarra"
library;

import 'package:fuzzy_bolt/fuzzy_bolt.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';

/// Maps imported exercise names to our database
class ExerciseNameMapper {
  ExerciseNameMapper(this._exercises);

  final List<ExerciseDefinition> _exercises;

  /// Minimum score threshold for auto-mapping (0.0 - 1.0)
  static const double autoMapThreshold = 0.75;

  /// Minimum score threshold for suggestions (0.0 - 1.0)
  static const double suggestionThreshold = 0.4;

  /// Maximum suggestions to return
  static const int maxSuggestions = 5;

  /// Common English to Italian exercise name mappings
  /// These are known high-confidence mappings for Strong exports
  static const Map<String, List<String>> knownMappings = {
    // Chest
    'bench press': ['panca piana', 'distensioni panca'],
    'flat bench press': ['panca piana'],
    'incline bench press': ['panca inclinata'],
    'decline bench press': ['panca declinata'],
    'dumbbell press': ['distensioni manubri'],
    'dumbbell fly': ['croci manubri', 'fly manubri'],
    'cable fly': ['croci cavi'],
    'push up': ['piegamenti', 'flessioni'],
    'pushup': ['piegamenti', 'flessioni'],
    'push-up': ['piegamenti', 'flessioni'],
    'chest press': ['chest press', 'panca'],
    'pec deck': ['pec deck', 'pectoral machine'],

    // Back
    'pull up': ['trazioni', 'pull up'],
    'pullup': ['trazioni', 'pull up'],
    'pull-up': ['trazioni', 'pull up'],
    'chin up': ['trazioni supine'],
    'lat pulldown': ['lat machine', 'pulldown'],
    'seated row': ['rematore seduto', 'pulley'],
    'cable row': ['rematore cavi'],
    'bent over row': ['rematore bilanciere'],
    'barbell row': ['rematore bilanciere'],
    'dumbbell row': ['rematore manubrio'],
    't-bar row': ['t-bar row', 'rematore t-bar'],
    'deadlift': ['stacco', 'deadlift'],
    'romanian deadlift': ['stacco rumeno'],

    // Shoulders
    'overhead press': ['military press', 'lento avanti'],
    'shoulder press': ['lento avanti', 'military'],
    'military press': ['military press', 'lento avanti'],
    'lateral raise': ['alzate laterali'],
    'front raise': ['alzate frontali'],
    'rear delt': ['deltoide posteriore', 'alzate posteriori'],
    'face pull': ['face pull'],
    'upright row': ['tirate al mento'],
    'shrug': ['scrollate', 'shrug'],

    // Arms
    'bicep curl': ['curl bicipiti', 'curl manubri'],
    'barbell curl': ['curl bilanciere'],
    'dumbbell curl': ['curl manubri'],
    'hammer curl': ['curl martello'],
    'preacher curl': ['curl panca scott'],
    'tricep pushdown': ['pushdown tricipiti'],
    'tricep extension': ['estensioni tricipiti'],
    'skull crusher': ['french press'],
    'close grip bench': ['panca presa stretta'],
    'dip': ['dip', 'parallele'],
    'dips': ['dip', 'parallele'],

    // Legs
    'squat': ['squat', 'accosciata'],
    'back squat': ['squat bilanciere'],
    'front squat': ['front squat'],
    'leg press': ['leg press', 'pressa'],
    'leg extension': ['leg extension'],
    'leg curl': ['leg curl'],
    'lunge': ['affondi'],
    'walking lunge': ['affondi camminata'],
    'calf raise': ['calf raise', 'polpacci'],
    'hip thrust': ['hip thrust'],
    'glute bridge': ['ponte glutei'],
    'hack squat': ['hack squat'],

    // Abs
    'crunch': ['crunch', 'addominali'],
    'sit up': ['sit up'],
    'plank': ['plank'],
    'leg raise': ['alzate gambe'],
    'russian twist': ['russian twist'],
    'cable crunch': ['crunch cavi'],
    'ab wheel': ['ab wheel', 'rollout'],
  };

  /// Map all exercises from import, returning updated unmapped list
  Future<ImportParseResult> mapExercises(ImportParseResult parseResult) async {
    final Map<String, String> autoMapped = {};
    final List<UnmappedExercise> stillUnmapped = [];

    for (final unmapped in parseResult.unmappedExercises) {
      final result = await findBestMatch(unmapped.originalName);

      if (result != null && result.confidence >= autoMapThreshold) {
        // Auto-map high confidence matches
        autoMapped[unmapped.originalName] = result.exerciseId;
      } else {
        // Keep as unmapped with suggestions
        final suggestions = await findSuggestions(unmapped.originalName);
        stillUnmapped.add(unmapped.copyWith(suggestions: suggestions));
      }
    }

    // Update workouts with mapped exercise IDs
    final updatedWorkouts = parseResult.workouts.map((workout) {
      final updatedExercises = workout.exercises.map((exercise) {
        final mappedId = autoMapped[exercise.originalName];
        if (mappedId != null) {
          final mappedExercise = _exercises.firstWhere(
            (e) => e.id == mappedId,
            orElse: () => _exercises.first,
          );
          return exercise.copyWith(
            mappedExerciseId: mappedId,
            mappedExerciseName: mappedExercise.nome,
          );
        }
        return exercise;
      }).toList();

      return workout.copyWith(exercises: updatedExercises);
    }).toList();

    return parseResult.copyWith(
      workouts: updatedWorkouts,
      autoMappedExercises: autoMapped,
      unmappedExercises: stillUnmapped,
    );
  }

  /// Find the best matching exercise for a given name
  Future<ExerciseMatch?> findBestMatch(String importedName) async {
    final normalizedInput = _normalize(importedName);

    // First, try known mappings
    for (final entry in knownMappings.entries) {
      if (normalizedInput.contains(entry.key)) {
        // Find exercise matching any of the known translations
        for (final translation in entry.value) {
          final match = _exercises.firstWhere(
            (e) => _normalize(e.nome).contains(translation),
            orElse: () => _exercises.first,
          );
          if (_normalize(match.nome).contains(translation)) {
            return ExerciseMatch(
              exerciseId: match.id,
              name: match.nome,
              confidence: 0.95, // High confidence for known mappings
            );
          }
        }
      }
    }

    // Fallback: fuzzy search
    final results = await FuzzyBolt.searchWithScores<ExerciseDefinition>(
      _exercises,
      normalizedInput,
      selectors: [
        (e) => _normalize(e.nome),
        (e) => e.aliases.map((a) => _normalize(a)).join(' '),
      ],
      skipIsolate: true, // Run on main thread for simplicity
    );

    if (results.isEmpty) return null;

    final best = results.first;
    return ExerciseMatch(
      exerciseId: best.item.id,
      name: best.item.nome,
      confidence: best.score,
    );
  }

  /// Find multiple suggestions for manual mapping
  Future<List<ExerciseMatch>> findSuggestions(String importedName) async {
    final normalizedInput = _normalize(importedName);

    final results = await FuzzyBolt.searchWithScores<ExerciseDefinition>(
      _exercises,
      normalizedInput,
      selectors: [
        (e) => _normalize(e.nome),
        (e) => e.aliases.map((a) => _normalize(a)).join(' '),
      ],
      skipIsolate: true,
    );

    return results
        .where((r) => r.score >= suggestionThreshold)
        .take(maxSuggestions)
        .map((r) => ExerciseMatch(
              exerciseId: r.item.id,
              name: r.item.nome,
              confidence: r.score,
            ))
        .toList();
  }

  /// Normalize string for comparison
  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }
}
