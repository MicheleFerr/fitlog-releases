/// Workout Import Provider
///
/// Riverpod state management for the workout import flow.
/// Handles text/photo parsing, exercise matching, and template creation.
///
/// **Layer**: Presentation - Provider
/// **Feature**: Workout Import
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/config/environment_config.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/openrouter_http_client.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    show ExerciseDefinition;
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout_import/data/datasources/workout_import_ai_client.dart';
import 'package:gymbro_flutter_new/features/workout_import/domain/entities/parsed_workout.dart';
import 'package:gymbro_flutter_new/features/workout_import/domain/services/workout_import_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// State for the workout import flow
enum WorkoutImportStatus { idle, loading, success, error }

class WorkoutImportState {
  const WorkoutImportState({
    this.status = WorkoutImportStatus.idle,
    this.parsedWorkout,
    this.errorMessage,
  });

  final WorkoutImportStatus status;
  final ParsedWorkout? parsedWorkout;
  final String? errorMessage;

  WorkoutImportState copyWith({
    WorkoutImportStatus? status,
    ParsedWorkout? parsedWorkout,
    String? errorMessage,
  }) {
    return WorkoutImportState(
      status: status ?? this.status,
      parsedWorkout: parsedWorkout ?? this.parsedWorkout,
      errorMessage: errorMessage,
    );
  }
}

/// Provider for the import service (singleton via keepAlive)
final _workoutImportServiceProvider = Provider<WorkoutImportService>((ref) {
  final apiKey = EnvironmentConfig.openRouterApiKey ?? '';
  final httpClient = OpenRouterHttpClient(apiKey: apiKey);
  final aiClient = WorkoutImportAiClient(httpClient: httpClient);
  ref.keepAlive();
  return WorkoutImportService(aiClient: aiClient);
});

/// Main provider for the workout import flow
final workoutImportProvider =
    NotifierProvider<WorkoutImportNotifier, WorkoutImportState>(
      WorkoutImportNotifier.new,
    );

class WorkoutImportNotifier extends Notifier<WorkoutImportState> {
  /// Rate limiting: minimum 3 seconds between requests
  DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(seconds: 3);

  @override
  WorkoutImportState build() => const WorkoutImportState();

  /// Check if API key is configured
  bool _isApiKeyConfigured() {
    final apiKey = EnvironmentConfig.openRouterApiKey;
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Parse text input
  Future<void> parseText(String text) async {
    if (text.trim().isEmpty) {
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'empty',
      );
      return;
    }

    if (!_isApiKeyConfigured()) {
      debugPrint('[WorkoutImport] ERROR: OPENROUTER_API_KEY not configured');
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'api',
      );
      return;
    }

    if (!_checkRateLimit()) {
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'rate_limit',
      );
      return;
    }

    state = state.copyWith(status: WorkoutImportStatus.loading);

    try {
      final service = ref.read(_workoutImportServiceProvider);
      final exercises = await _getExerciseDb();

      final result = await service.parseFromText(
        text: text,
        exerciseDb: exercises,
      );

      state = state.copyWith(
        status: WorkoutImportStatus.success,
        parsedWorkout: result,
      );
    } on TimeoutException {
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'api',
      );
    } on FormatException {
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'parsing',
      );
    } catch (e, stackTrace) {
      debugPrint('[WorkoutImport] Error: $e');
      debugPrint('[WorkoutImport] Stack: $stackTrace');
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'api',
      );
    }
  }

  /// Parse image from camera or gallery
  Future<void> parseImage(ImageSource source) async {
    if (!_isApiKeyConfigured()) {
      debugPrint('[WorkoutImport] ERROR: OPENROUTER_API_KEY not configured');
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'api',
      );
      return;
    }

    if (!_checkRateLimit()) {
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'rate_limit',
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image == null) return; // User cancelled

    state = state.copyWith(status: WorkoutImportStatus.loading);

    try {
      final bytes = await image.readAsBytes();
      final base64 = base64Encode(bytes);

      final service = ref.read(_workoutImportServiceProvider);
      final exercises = await _getExerciseDb();

      final result = await service.parseFromImage(
        base64Image: base64,
        exerciseDb: exercises,
      );

      state = state.copyWith(
        status: WorkoutImportStatus.success,
        parsedWorkout: result,
      );
    } on TimeoutException {
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'api',
      );
    } on FormatException {
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'parsing',
      );
    } catch (e, stackTrace) {
      debugPrint('[WorkoutImport] Image error: $e');
      debugPrint('[WorkoutImport] Stack: $stackTrace');
      state = state.copyWith(
        status: WorkoutImportStatus.error,
        errorMessage: 'api',
      );
    }
  }

  /// Update a single exercise match (e.g., after user picks from picker)
  void updateExerciseMatch({
    required int dayIndex,
    required int exerciseIndex,
    required String exerciseId,
    required String exerciseName,
    required ExerciseCategory category,
  }) {
    final workout = state.parsedWorkout;
    if (workout == null) return;

    final days = List<ParsedDay>.from(workout.days);
    final exercises = List<ParsedExerciseLine>.from(days[dayIndex].exercises);

    exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(
      matchedExerciseId: exerciseId,
      matchedExerciseName: exerciseName,
      matchConfidence: 1.0, // Manual selection = 100% confidence
      matchedCategory: category,
    );

    days[dayIndex] = days[dayIndex].copyWith(exercises: exercises);

    state = state.copyWith(
      parsedWorkout: workout.copyWith(days: days),
    );
  }

  /// Create workout templates from parsed data
  Future<List<WorkoutTemplate>> createTemplates() async {
    final workout = state.parsedWorkout;
    if (workout == null) return [];

    final userId = ref.read(currentUserIdProvider);
    final templates = <WorkoutTemplate>[];

    for (final day in workout.days) {
      final exerciseTemplates = day.exercises
          .where((e) => e.matchedExerciseId != null)
          .map(_toExerciseTemplate)
          .toList();

      if (exerciseTemplates.isEmpty) continue;

      final template = WorkoutTemplate(
        id: const Uuid().v4(),
        name: day.name,
        description: '',
        exercises: exerciseTemplates,
        isCustom: true,
        userId: userId,
      );

      templates.add(template);
    }

    // Save all templates
    final notifier = ref.read(workoutTemplateNotifierProvider.notifier);
    for (final template in templates) {
      await notifier.saveTemplate(template);
    }

    // Invalidate template providers to refresh UI
    ref.invalidate(customWorkoutTemplatesProvider);

    return templates;
  }

  /// Convert a parsed exercise line into an ExerciseTemplate
  ExerciseTemplate _toExerciseTemplate(ParsedExerciseLine exercise) {
    final sets = exercise.sets.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;

      return SetTemplate(
        setNumber: i + 1,
        targetWeight: s.weight,
        targetReps: s.reps ?? s.maxReps ?? (s.isMaxReps ? null : 8),
        targetMinReps: s.minReps,
        targetMaxReps: s.maxReps,
      );
    }).toList();

    // Default to 3 sets if none parsed
    if (sets.isEmpty) {
      sets.addAll([
        const SetTemplate(setNumber: 1, targetReps: 8),
        const SetTemplate(setNumber: 2, targetReps: 8),
        const SetTemplate(setNumber: 3, targetReps: 8),
      ]);
    }

    return ExerciseTemplate(
      exerciseId: exercise.matchedExerciseId ?? '',
      exerciseName: exercise.matchedExerciseName ?? exercise.rawName,
      category: exercise.matchedCategory ?? ExerciseCategory.other,
      type: ExerciseType.single,
      sets: sets,
      notes: exercise.notes,
      restTime: exercise.restSeconds,
    );
  }

  /// Reset to initial state
  void reset() {
    state = const WorkoutImportState();
  }

  /// Check rate limiting
  bool _checkRateLimit() {
    final now = DateTime.now();
    if (_lastRequestTime != null &&
        now.difference(_lastRequestTime!) < _minRequestInterval) {
      return false;
    }
    _lastRequestTime = now;
    return true;
  }

  /// Get exercise database
  Future<List<ExerciseDefinition>> _getExerciseDb() async {
    final asyncValue = ref.read(allExercisesProvider);
    return asyncValue.when(
      data: (exercises) => exercises,
      loading: () => <ExerciseDefinition>[],
      error: (_, __) => <ExerciseDefinition>[],
    );
  }
}
