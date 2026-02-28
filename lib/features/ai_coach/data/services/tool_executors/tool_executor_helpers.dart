/// Shared helpers for AI tool executors
///
/// Contains parsing utilities, normalization functions, inline card builders,
/// and data classes used across multiple tool executor services.
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:flutter/widgets.dart' show Locale;

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// A measurement waiting for user confirmation before being saved.
class PendingMeasurement {
  const PendingMeasurement({
    required this.metricType,
    required this.value,
    required this.unit,
    this.notes,
  });

  final MetricType metricType;
  final double value;
  final String unit;
  final String? notes;
}

/// Cache entry for scientific-source search results.
class DocumentSearchCacheEntry {
  const DocumentSearchCacheEntry({
    required this.payload,
    required this.timestamp,
  });

  final String payload;
  final DateTime timestamp;
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Canonical major muscle groups used for balance analysis.
const Set<String> majorMuscleGroups = {
  'chest',
  'back',
  'legs',
  'shoulders',
  'arms',
  'core',
  'glutes',
};

/// TTL for scientific-document search cache.
const Duration documentSearchCacheTtl = Duration(minutes: 10);

// ---------------------------------------------------------------------------
// String normalization
// ---------------------------------------------------------------------------

/// Normalize string from AI (handles unicode escapes like \u00b0 -> deg).
String normalizeString(String input) {
  final unicodePattern = RegExp(r'\\u([0-9a-fA-F]{4})');
  return input.replaceAllMapped(unicodePattern, (match) {
    final hexCode = match.group(1)!;
    final codePoint = int.parse(hexCode, radix: 16);
    return String.fromCharCode(codePoint);
  });
}

/// Normalize muscle group labels to canonical keys.
String canonicalMuscleGroup(String raw) {
  final v = raw.toLowerCase().trim();

  if (v.isEmpty) return 'other';
  if (v == 'other' || v == 'altro') return 'other';

  if (v.contains('dorso') ||
      v.contains('schiena') ||
      v == 'back' ||
      v.contains('lat') ||
      v.contains('trapez')) {
    return 'back';
  }
  if (v.contains('petto') || v == 'chest' || v.contains('pector')) {
    return 'chest';
  }
  if (v.contains('gamb') ||
      v == 'legs' ||
      v.contains('quad') ||
      v.contains('hamstring') ||
      v.contains('femor') ||
      v.contains('polpacc') ||
      v.contains('calf')) {
    return 'legs';
  }
  if (v.contains('glute')) return 'glutes';
  if (v.contains('spall') || v == 'shoulders' || v.contains('delt')) {
    return 'shoulders';
  }
  if (v.contains('bracc') ||
      v == 'arms' ||
      v.contains('bicip') ||
      v.contains('tricip') ||
      v.contains('avambr')) {
    return 'arms';
  }
  if (v.contains('core') ||
      v.contains('addom') ||
      v == 'abs' ||
      v.contains('obliqu') ||
      v.contains('lomb')) {
    return 'core';
  }
  if (v.contains('full') && v.contains('body')) return 'full_body';
  return 'other';
}

/// Canonical key -> Italian display label.
String muscleGroupLabel(String canonical) {
  return switch (canonical) {
    'back' => 'dorso',
    'chest' => 'petto',
    'legs' => 'gambe',
    'glutes' => 'glutei',
    'shoulders' => 'spalle',
    'arms' => 'braccia',
    'core' => 'core',
    'full_body' => 'full body',
    'recovery' => 'recupero attivo',
    _ => canonical,
  };
}

/// Canonical key -> Italian search query for exercise search.
String searchQueryForMuscle(String canonical) {
  return switch (canonical) {
    'back' => 'schiena',
    'chest' => 'petto',
    'legs' => 'gambe',
    'glutes' => 'glutei',
    'shoulders' => 'spalle',
    'arms' => 'braccia',
    'core' => 'addome',
    'full_body' => 'full body',
    _ => canonical,
  };
}

// ---------------------------------------------------------------------------
// Onboarding helpers
// ---------------------------------------------------------------------------

String? goalFromOnboarding(OnboardingState? state) {
  final aiGoal = state?.stepData['aiGoal']?.toString();
  final normalizedAiGoal = normalizeGoalInput(aiGoal);
  if (normalizedAiGoal != null) return normalizedAiGoal;

  return switch (state?.userGoal) {
    'buildMuscle' => 'muscle',
    'loseWeight' => 'fat_loss',
    'getStronger' => 'strength',
    'stayFit' => 'endurance',
    _ => null,
  };
}

String? experienceFromOnboarding(OnboardingState? state) {
  final aiLevel = state?.stepData['aiExperienceLevel']?.toString();
  final normalizedAiLevel = normalizeExperienceInput(aiLevel);
  if (normalizedAiLevel != null) return normalizedAiLevel;

  return switch (state?.userExperienceLevel) {
    'beginner' => 'beginner',
    'expert' => 'experienced',
    _ => null,
  };
}

String? normalizeGoalInput(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final v = raw.toLowerCase().trim();
  if (v.contains('ricompos') || v.contains('recomposition')) {
    return 'recomposition';
  }
  if (v.contains('muscle') || v.contains('massa') || v.contains('ipertrof')) {
    return 'muscle';
  }
  if (v.contains('strength') || v.contains('forza') || v.contains('power')) {
    return 'strength';
  }
  if (v.contains('fat') ||
      v.contains('dimagr') ||
      v.contains('lose') ||
      v.contains('peso')) {
    return 'fat_loss';
  }
  if (v.contains('endur') || v.contains('resistenza') || v.contains('fit')) {
    return 'endurance';
  }
  return null;
}

String? normalizeExperienceInput(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final v = raw.toLowerCase().trim();
  if (v.contains('begin') || v.contains('principiante')) return 'beginner';
  if (v.contains('athlet') || v.contains('atleta')) return 'athlete';
  if (v.contains('expert') ||
      v.contains('esperto') ||
      v.contains('advanced') ||
      v.contains('avanz')) {
    return 'experienced';
  }
  if (v.contains('intermedio') ||
      v.contains('intermediate') ||
      v.contains('some')) {
    return 'some';
  }
  return null;
}

String? goalToOnboardingValue(String normalizedGoal) {
  return switch (normalizedGoal) {
    'muscle' => 'buildMuscle',
    'fat_loss' => 'loseWeight',
    'strength' => 'getStronger',
    'endurance' => 'stayFit',
    _ => null,
  };
}

List<String> profileSuggestionsForMissing(String field) {
  return switch (field) {
    'experienceLevel' => const [
      'Sono principiante',
      'Sono intermedio',
      'Sono avanzato',
    ],
    'goal' => const [
      'Obiettivo: massa muscolare',
      'Obiettivo: forza',
      'Obiettivo: dimagrimento',
    ],
    'weeklyTarget' => const [
      'Mi alleno 3 volte a settimana',
      'Mi alleno 4 volte a settimana',
      'Mi alleno 5 volte a settimana',
    ],
    _ => const [],
  };
}

// ---------------------------------------------------------------------------
// Onboarding state persistence
// ---------------------------------------------------------------------------

Future<OnboardingState?> loadOnboardingState(
  OnboardingState? fallback,
) async {
  const boxName = 'onboarding_state';
  try {
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<OnboardingState>(boxName)
        : await Hive.openBox<OnboardingState>(boxName);
    return box.get('state');
  } catch (_) {
    return fallback;
  }
}

Future<void> saveOnboardingState(OnboardingState state) async {
  const boxName = 'onboarding_state';
  final box = Hive.isBoxOpen(boxName)
      ? Hive.box<OnboardingState>(boxName)
      : await Hive.openBox<OnboardingState>(boxName);
  await box.put('state', state);
}

// ---------------------------------------------------------------------------
// Fallback exercise data
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> fallbackExercisesForMuscle(String canonical) {
  return switch (canonical) {
    'back' => [
      {'name': 'Lat machine', 'muscles': ['dorso']},
      {'name': 'Rematore con bilanciere', 'muscles': ['dorso']},
      {'name': 'Pulley basso', 'muscles': ['dorso']},
      {'name': 'Pulldown a braccia tese', 'muscles': ['dorso']},
    ],
    'chest' => [
      {'name': 'Panca piana', 'muscles': ['petto']},
      {'name': 'Distensioni inclinate', 'muscles': ['petto']},
      {'name': 'Croci ai cavi', 'muscles': ['petto']},
      {'name': 'Chest press', 'muscles': ['petto']},
    ],
    'legs' => [
      {'name': 'Squat', 'muscles': ['gambe']},
      {'name': 'Leg press', 'muscles': ['gambe']},
      {'name': 'Affondi', 'muscles': ['gambe']},
      {'name': 'Leg curl', 'muscles': ['gambe']},
    ],
    'shoulders' => [
      {'name': 'Military press', 'muscles': ['spalle']},
      {'name': 'Alzate laterali', 'muscles': ['spalle']},
      {'name': 'Alzate posteriori', 'muscles': ['spalle']},
      {'name': 'Arnold press', 'muscles': ['spalle']},
    ],
    'arms' => [
      {'name': 'Curl bilanciere', 'muscles': ['braccia']},
      {'name': 'Curl manubri', 'muscles': ['braccia']},
      {'name': 'Pushdown cavo', 'muscles': ['braccia']},
      {'name': 'French press', 'muscles': ['braccia']},
    ],
    'core' => [
      {'name': 'Plank', 'muscles': ['core']},
      {'name': 'Crunch cavo', 'muscles': ['core']},
      {'name': 'Leg raise', 'muscles': ['core']},
      {'name': 'Ab wheel', 'muscles': ['core']},
    ],
    _ => [
      {'name': 'Squat', 'muscles': ['full body']},
      {'name': 'Panca piana', 'muscles': ['full body']},
      {'name': 'Rematore', 'muscles': ['full body']},
      {'name': 'Affondi', 'muscles': ['full body']},
    ],
  };
}

// ---------------------------------------------------------------------------
// Suggested-session builder
// ---------------------------------------------------------------------------

Future<Map<String, dynamic>> buildSuggestedSession({
  required String focusCanonical,
  required String intensity,
  required String recoveryStatus,
  required ExerciseSearchService exerciseSearchService,
  required Locale? locale,
}) async {
  if (recoveryStatus == 'red' || focusCanonical == 'recovery') {
    return {
      'type': 'active_recovery',
      'durationMinutes': 30,
      'warmupMinutes': 5,
      'activities': [
        'Camminata o cyclette leggera 20-25 minuti',
        'Mobilità anche/torace/spalle 8-10 minuti',
        'Defaticamento e respirazione 3-5 minuti',
      ],
      'note': 'Mantieni sforzo leggero (RPE 3-4/10).',
    };
  }

  final isHigh = intensity.contains('alta');
  final isVeryLight = intensity.contains('leggera');
  final sets = isHigh ? 4 : isVeryLight ? 2 : 3;
  final reps = isHigh ? '6-10' : isVeryLight ? '12-15' : '8-12';
  final rir = isHigh ? '1-2' : isVeryLight ? '3-4' : '2-3';
  final restSeconds = isHigh ? 120 : isVeryLight ? 60 : 90;

  List<Map<String, dynamic>> exercises;
  try {
    final query = searchQueryForMuscle(focusCanonical);
    final results = await exerciseSearchService.searchExercises(query, locale);
    final selected = selectDiverseExercises(results, 4);

    exercises = selected
        .take(4)
        .map(
          (ex) => {
            'name': ex.name,
            'muscles': ex.muscleGroups.take(2).toList(),
            'sets': sets,
            'reps': reps,
            'rir': rir,
            'restSeconds': restSeconds,
          },
        )
        .toList();
  } catch (_) {
    exercises = <Map<String, dynamic>>[];
  }

  if (exercises.isEmpty) {
    exercises = fallbackExercisesForMuscle(focusCanonical)
        .map(
          (ex) => {
            ...ex,
            'sets': sets,
            'reps': reps,
            'rir': rir,
            'restSeconds': restSeconds,
          },
        )
        .toList();
  }

  return {
    'type': 'workout',
    'focus': muscleGroupLabel(focusCanonical),
    'durationMinutes': 55,
    'warmupMinutes': 10,
    'intensity': intensity,
    'guidelines': [
      'Riscaldamento progressivo prima dei carichi di lavoro',
      'Mantieni tecnica pulita, evita cedimento nelle prime serie',
    ],
    'exercises': exercises,
  };
}

// ---------------------------------------------------------------------------
// Template search / match helpers
// ---------------------------------------------------------------------------

/// Normalize for fuzzy matching: lowercase, strip special chars.
String normalizeForMatch(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9àèéìòù\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Find exercises in a template whose name matches the query.
List<Exercise> findTemplateExercisesByQuery(
  List<Exercise> exercises,
  String query,
) {
  final normalizedQuery = normalizeForMatch(query);
  if (normalizedQuery.isEmpty) return const [];

  final exact = exercises
      .where((e) => normalizeForMatch(e.name) == normalizedQuery)
      .toList();
  if (exact.isNotEmpty) return exact;

  return exercises
      .where((e) => normalizeForMatch(e.name).contains(normalizedQuery))
      .toList();
}

// ---------------------------------------------------------------------------
// Template inline-card builders
// ---------------------------------------------------------------------------

Map<String, dynamic> buildTemplateAction({
  required String label,
  required String command,
  required String actionType,
  String? style,
}) {
  return {
    'label': label,
    'command': command,
    'actionType': actionType,
    if (style != null) 'style': style,
  };
}

Map<String, dynamic> buildTemplateActionInlineCard({
  required String title,
  required String subtitle,
  required String templateName,
  String? exerciseName,
  String? imageUrl,
  String? selectionHint,
  List<Map<String, dynamic>>? alternatives,
  required List<Map<String, dynamic>> actions,
}) {
  return {
    'title': title,
    'subtitle': subtitle,
    'templateName': templateName,
    if (exerciseName != null) 'exerciseName': exerciseName,
    if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    if (selectionHint != null && selectionHint.isNotEmpty)
      'selectionHint': selectionHint,
    if (alternatives != null && alternatives.isNotEmpty)
      'alternatives': alternatives,
    'actions': actions,
  };
}

List<Map<String, dynamic>> buildExerciseChoiceCards({
  required List<ExerciseDefinitionTemplate> candidates,
  required String Function(ExerciseDefinitionTemplate exercise) commandBuilder,
  String? excludeName,
  int limit = 6,
}) {
  final excluded =
      excludeName == null ? null : normalizeForMatch(excludeName);
  final seen = <String>{};
  final cards = <Map<String, dynamic>>[];

  for (final exercise in candidates) {
    final normalized = normalizeForMatch(exercise.name);
    if (normalized.isEmpty) continue;
    if (excluded != null && normalized == excluded) continue;
    if (seen.contains(normalized)) continue;
    seen.add(normalized);

    cards.add({
      'name': exercise.name,
      if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty)
        'imageUrl': exercise.imageUrl,
      'muscles': exercise.muscleGroups.take(3).toList(),
      'command': commandBuilder(exercise),
    });
    if (cards.length >= limit) break;
  }

  return cards;
}

/// Try to fetch an exercise image URL from the search service.
Future<String?> tryGetExerciseImage(
  String exerciseName,
  ExerciseSearchService exerciseSearchService,
  Locale? locale,
) async {
  try {
    final results = await exerciseSearchService.searchExercises(
      exerciseName,
      locale,
    );
    if (results.isEmpty) return null;

    final normalized = normalizeForMatch(exerciseName);
    final exact = results.firstWhereOrNull(
      (e) => normalizeForMatch(e.name) == normalized,
    );
    return (exact ?? results.first).imageUrl;
  } catch (_) {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Parsing utilities
// ---------------------------------------------------------------------------

int parseBoundedInt(
  dynamic raw, {
  required int defaultValue,
  required int min,
  required int max,
}) {
  final parsed =
      raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
  final value = parsed ?? defaultValue;
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

bool parseBoolFlag(dynamic raw, {bool defaultValue = false}) {
  if (raw == null) return defaultValue;
  if (raw is bool) return raw;
  if (raw is num) return raw != 0;

  final normalized = raw.toString().trim().toLowerCase();
  if (normalized.isEmpty) return defaultValue;

  if (normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes' ||
      normalized == 'si' ||
      normalized == 'sì' ||
      normalized == 'vero') {
    return true;
  }
  if (normalized == 'false' ||
      normalized == '0' ||
      normalized == 'no' ||
      normalized == 'falso') {
    return false;
  }
  return defaultValue;
}

/// Check if two exercise names are similar (variants of same exercise).
bool areSimilarNames(String a, String b) {
  final wordsA = a.split(RegExp(r'\s+')).where((w) => w.length > 2).toSet();
  final wordsB = b.split(RegExp(r'\s+')).where((w) => w.length > 2).toSet();
  if (wordsA.isEmpty || wordsB.isEmpty) return false;

  final intersection = wordsA.intersection(wordsB);
  final smaller = wordsA.length < wordsB.length ? wordsA : wordsB;
  return intersection.length >= (smaller.length * 0.6).ceil();
}

/// Select diverse exercises from a list, avoiding similar names.
List<ExerciseDefinitionTemplate> selectDiverseExercises(
  List<ExerciseDefinitionTemplate> exercises,
  int limit,
) {
  final selected = <ExerciseDefinitionTemplate>[];
  for (final exercise in exercises) {
    if (selected.length >= limit) break;
    final isDuplicate = selected.any(
      (s) => areSimilarNames(
        s.name.toLowerCase(),
        exercise.name.toLowerCase(),
      ),
    );
    if (!isDuplicate) {
      selected.add(exercise);
    }
  }
  return selected;
}

// ---------------------------------------------------------------------------
// Debug logging
// ---------------------------------------------------------------------------

void debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

/// Helper to record errors to Crashlytics with a reason.
///
/// Silently ignores errors if Crashlytics is not initialized (e.g. in tests).
Future<void> recordToolError(
  Object error,
  StackTrace stackTrace, {
  required String reason,
}) async {
  try {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: reason,
    );
  } catch (_) {
    // Crashlytics may not be fully initialized in test/development environments.
    // Errors are still visible in logs via the executor's catch block.
  }
}

/// Encode an error result for a tool.
String encodeToolError(String error, String toolName) {
  return jsonEncode({'error': error, 'toolName': toolName});
}
