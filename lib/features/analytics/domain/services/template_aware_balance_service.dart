/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// Template-Aware Balance Service
///
/// Combines MuscleBalanceMetrics with template analysis to provide
/// smarter, context-aware muscle balance recommendations.
///
/// **Key Features**:
/// - Analyzes muscle coverage across user's workout templates
/// - Adjusts neglected muscle severity based on planned exercises
/// - Filters exercise suggestions already present in templates
///
/// **Architecture**:
/// Post-processing approach - does not modify core balance calculation.
/// Takes existing [MuscleBalanceMetrics] and enhances with template context.
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/template_coverage.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Template-Aware Balance Service
///
/// Enhances muscle balance analysis with workout template context.
///
/// **Usage**:
/// ```dart
/// final service = TemplateAwareBalanceService();
///
/// // Step 1: Analyze template coverage
/// final coverage = service.analyzeTemplateCoverage(
///   templates: userTemplates,
///   exerciseMuscleMap: muscleMap,
/// );
///
/// // Step 2: Adjust neglected muscles
/// final adjusted = service.adjustNeglectedMuscles(
///   neglected: detector.detectNeglectedMuscles(balance),
///   coverage: coverage,
/// );
///
/// // Step 3: Filter suggestions
/// final filtered = service.filterAlreadyPlanned(
///   suggestions: suggestions,
///   coverage: coverage,
/// );
/// ```
class TemplateAwareBalanceService {
  /// Analyze which muscles are covered by templates
  ///
  /// Scans all exercises in templates and maps them to muscle groups
  /// using the [exerciseMuscleMap].
  ///
  /// Handles:
  /// - Regular exercises in templates
  /// - Superset sub-exercises
  /// - Case-insensitive exercise matching
  /// - Fallback to exercise category when muscle map unavailable
  TemplateCoverageResult analyzeTemplateCoverage({
    required List<WorkoutTemplate> templates,
    required Map<String, ExerciseMuscleData> exerciseMuscleMap,
  }) {
    if (templates.isEmpty) {
      return TemplateCoverageResult.empty();
    }

    // Track muscle → template coverage
    final Map<String, _MuscleTracker> muscleTrackers = {};

    // Track exercise → templates
    final Map<String, Set<String>> exerciseToTemplates = {};

    for (final template in templates) {
      if (template.exercises.isEmpty) continue;

      // Process each exercise in template
      for (final exercise in template.exercises) {
        _processExercise(
          exercise: exercise,
          templateName: template.name,
          exerciseMuscleMap: exerciseMuscleMap,
          muscleTrackers: muscleTrackers,
          exerciseToTemplates: exerciseToTemplates,
        );
      }
    }

    // Convert trackers to scores
    final muscleScores = <String, TemplateMuscleScore>{};
    for (final entry in muscleTrackers.entries) {
      final tracker = entry.value;
      muscleScores[entry.key] = TemplateMuscleScore(
        muscleName: entry.key,
        templateCount: tracker.templateNames.length,
        totalExercises: tracker.exerciseCount,
        estimatedWeeklySets: tracker.totalSets,
        templateNames: tracker.templateNames.toList(),
      );
    }

    // Convert exercise map to list
    final exerciseMap = exerciseToTemplates.map(
      (key, value) => MapEntry(key, value.toList()),
    );

    return TemplateCoverageResult(
      muscleScores: muscleScores,
      exerciseToTemplates: exerciseMap,
    );
  }

  /// Process a single exercise (handles supersets recursively)
  void _processExercise({
    required ExerciseTemplate exercise,
    required String templateName,
    required Map<String, ExerciseMuscleData> exerciseMuscleMap,
    required Map<String, _MuscleTracker> muscleTrackers,
    required Map<String, Set<String>> exerciseToTemplates,
  }) {
    final exerciseName = exercise.exerciseName;
    final exerciseNameLower = exerciseName.toLowerCase();

    // Track exercise → template mapping
    exerciseToTemplates.putIfAbsent(exerciseNameLower, () => {});
    exerciseToTemplates[exerciseNameLower]!.add(templateName);

    // Get muscle data from map (case-insensitive lookup)
    final muscleData =
        exerciseMuscleMap[exerciseName] ?? exerciseMuscleMap[exerciseNameLower];

    final setsCount = exercise.sets.length;

    if (muscleData != null && muscleData.hasData) {
      // Use primary and secondary muscles from exercise data
      for (final muscle in muscleData.primary) {
        _addMuscleTracking(
          muscleTrackers: muscleTrackers,
          muscleName: muscle.toLowerCase(),
          templateName: templateName,
          setsCount: setsCount,
        );
      }
      for (final muscle in muscleData.secondary) {
        _addMuscleTracking(
          muscleTrackers: muscleTrackers,
          muscleName: muscle.toLowerCase(),
          templateName: templateName,
          // Secondary muscles get half credit for sets
          setsCount: (setsCount / 2).ceil(),
        );
      }
    } else {
      // Fallback: use exercise category
      final categoryMuscle = _categoryToMuscle(exercise.category);
      if (categoryMuscle != null) {
        _addMuscleTracking(
          muscleTrackers: muscleTrackers,
          muscleName: categoryMuscle,
          templateName: templateName,
          setsCount: setsCount,
        );
      }
    }

    // Process sub-exercises (for supersets)
    if (exercise.subExercises != null) {
      for (final subExercise in exercise.subExercises!) {
        _processExercise(
          exercise: subExercise,
          templateName: templateName,
          exerciseMuscleMap: exerciseMuscleMap,
          muscleTrackers: muscleTrackers,
          exerciseToTemplates: exerciseToTemplates,
        );
      }
    }
  }

  /// Add tracking for a muscle
  void _addMuscleTracking({
    required Map<String, _MuscleTracker> muscleTrackers,
    required String muscleName,
    required String templateName,
    required int setsCount,
  }) {
    muscleTrackers.putIfAbsent(muscleName, () => _MuscleTracker());
    muscleTrackers[muscleName]!.templateNames.add(templateName);
    muscleTrackers[muscleName]!.exerciseCount++;
    muscleTrackers[muscleName]!.totalSets += setsCount;
  }

  /// Map exercise category to muscle group (fallback)
  String? _categoryToMuscle(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return 'chest';
      case ExerciseCategory.back:
        return 'back';
      case ExerciseCategory.shoulders:
        return 'shoulders';
      case ExerciseCategory.arms:
        return 'arms';
      case ExerciseCategory.legs:
        return 'legs';
      case ExerciseCategory.abs:
        return 'abs';
      case ExerciseCategory.cardio:
      case ExerciseCategory.other:
        return null;
    }
  }

  /// Adjust neglected muscles based on template coverage
  ///
  /// Applies severity reduction rules:
  /// - Muscle in ≥2 templates → reduce severity by 1 level
  /// - Muscle in ≥3 templates → reduce severity by 2 levels
  /// - CRITICAL never drops below MEDIUM
  ///
  /// Returns list sorted by adjusted priority (highest first)
  List<AdjustedNeglectedMuscle> adjustNeglectedMuscles({
    required List<NeglectedMuscle> neglected,
    required TemplateCoverageResult coverage,
  }) {
    final adjusted = neglected.map((muscle) {
      final muscleCoverage = coverage.getCoverage(muscle.muscleName);
      return AdjustedNeglectedMuscle(
        original: muscle,
        coverage: muscleCoverage,
      );
    }).toList();

    // Sort by adjusted priority (highest first)
    adjusted.sort((a, b) => b.adjustedPriority.compareTo(a.adjustedPriority));

    return adjusted;
  }

  /// Filter suggestions that are already in templates
  ///
  /// By default, removes exercises already present in any template.
  /// When [includeWithBadge] is true, keeps them but marks as planned.
  ///
  /// Returns filtered list with [isInTemplate] flag set appropriately.
  List<FilteredExerciseSuggestion> filterAlreadyPlanned({
    required List<ExerciseSuggestion> suggestions,
    required TemplateCoverageResult coverage,
    bool includeWithBadge = false,
  }) {
    final result = <FilteredExerciseSuggestion>[];

    for (final suggestion in suggestions) {
      final isPlanned = coverage.isExercisePlanned(suggestion.exerciseName);
      final templates = coverage.getTemplatesForExercise(
        suggestion.exerciseName,
      );

      if (isPlanned && !includeWithBadge) {
        // Skip this suggestion
        continue;
      }

      result.add(
        FilteredExerciseSuggestion(
          original: suggestion,
          isInTemplate: isPlanned,
          templateNames: templates,
        ),
      );
    }

    return result;
  }

  /// Get summary of template coverage for UI display
  ///
  /// Returns a human-readable summary like:
  /// "2 neglected muscles, both covered by your planned templates"
  String getCoverageSummary({
    required List<NeglectedMuscle> neglected,
    required TemplateCoverageResult coverage,
  }) {
    if (neglected.isEmpty) {
      return 'All muscles are well balanced';
    }

    final coveredCount = neglected
        .where((m) => coverage.hasCoverage(m.muscleName))
        .length;

    if (coveredCount == 0) {
      return '${neglected.length} neglected muscles need attention';
    }

    if (coveredCount == neglected.length) {
      return '${neglected.length} neglected muscles, all covered by your templates';
    }

    final uncoveredCount = neglected.length - coveredCount;
    return '$uncoveredCount of ${neglected.length} neglected muscles not in templates';
  }
}

/// Internal tracker for muscle coverage during analysis
class _MuscleTracker {
  final Set<String> templateNames = {};
  int exerciseCount = 0;
  int totalSets = 0;
}

/// Exercise suggestion with template filter result
///
/// Wraps an [ExerciseSuggestion] with information about whether
/// it's already in user's templates.
class FilteredExerciseSuggestion {
  const FilteredExerciseSuggestion({
    required this.original,
    required this.isInTemplate,
    this.templateNames = const [],
  });

  /// Original suggestion data
  final ExerciseSuggestion original;

  /// Whether this exercise is already in a template
  final bool isInTemplate;

  /// Names of templates containing this exercise
  final List<String> templateNames;

  // Delegate to original
  String get exerciseName => original.exerciseName;
  String get description => original.description;
  ExerciseDifficulty get difficulty => original.difficulty;
  String? get imageUrl => original.imageUrl;
  String get exerciseId => original.exerciseId;

  /// First template name (for display)
  String? get firstTemplateName =>
      templateNames.isNotEmpty ? templateNames.first : null;

  @override
  String toString() =>
      'FilteredSuggestion($exerciseName, inTemplate: $isInTemplate)';
}
