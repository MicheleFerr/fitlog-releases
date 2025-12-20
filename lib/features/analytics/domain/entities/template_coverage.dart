/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// Template Coverage Entities - Track muscle coverage in user's templates
///
/// **Purpose**:
/// Enable Template-Aware Muscle Balance by analyzing which muscles
/// are covered by the user's workout templates.
///
/// **Key Entities**:
/// - [TemplateMuscleScore]: Coverage data for a single muscle
/// - [TemplateCoverageResult]: Complete coverage analysis result
/// - [AdjustedNeglectedMuscle]: Neglected muscle with template context
library;

import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';

/// Coverage of a muscle in user's templates
///
/// Tracks how well a muscle is represented across all user templates.
///
/// **Usage**:
/// ```dart
/// final score = TemplateMuscleScore(
///   muscleName: 'back',
///   templateCount: 2,
///   totalExercises: 5,
///   templateNames: ['Pull Day', 'Full Body A'],
/// );
///
/// if (score.isWellCovered) {
///   print('Back is well covered by templates');
/// }
/// ```
class TemplateMuscleScore {
  const TemplateMuscleScore({
    required this.muscleName,
    required this.templateCount,
    required this.totalExercises,
    required this.templateNames,
    this.estimatedWeeklySets = 0,
  });

  /// Muscle group name (lowercase)
  final String muscleName;

  /// Number of templates containing exercises for this muscle
  final int templateCount;

  /// Total exercises targeting this muscle across all templates
  final int totalExercises;

  /// Estimated sets per week (sum of template sets)
  final int estimatedWeeklySets;

  /// List of template names containing this muscle
  final List<String> templateNames;

  /// Normalized coverage score (0.0 - 1.0)
  ///
  /// Scoring:
  /// - 0.0 = not covered at all
  /// - 0.5 = moderately covered (1 template or 2-4 exercises)
  /// - 1.0 = well covered (≥3 templates or ≥6 exercises)
  double get coverageScore {
    // Weight template count more heavily than exercise count
    final templateScore = (templateCount / 3.0).clamp(0.0, 1.0);
    final exerciseScore = (totalExercises / 6.0).clamp(0.0, 1.0);

    // 60% weight on template count, 40% on exercise count
    return (templateScore * 0.6 + exerciseScore * 0.4).clamp(0.0, 1.0);
  }

  /// Whether this muscle is considered well covered (score ≥ 0.5)
  bool get isWellCovered => coverageScore >= 0.5;

  /// Whether this muscle is in at least one template
  bool get hasAnyCoverage => templateCount > 0;

  @override
  String toString() =>
      'TemplateMuscleScore($muscleName: $templateCount templates, $totalExercises exercises)';
}

/// Result of template coverage analysis
///
/// Contains comprehensive data about which muscles and exercises
/// are covered by the user's workout templates.
///
/// **Usage**:
/// ```dart
/// final coverage = await service.analyzeTemplateCoverage(
///   templates: userTemplates,
///   exerciseMuscleMap: muscleMap,
/// );
///
/// if (coverage.isExercisePlanned('Lat Pulldown')) {
///   print('Lat Pulldown is already in a template');
/// }
///
/// final backCoverage = coverage.getCoverage('back');
/// print('Back is in ${backCoverage?.templateCount ?? 0} templates');
/// ```
class TemplateCoverageResult {
  const TemplateCoverageResult({
    required this.muscleScores,
    required this.exerciseToTemplates,
  });

  /// Empty coverage result (no templates)
  factory TemplateCoverageResult.empty() => const TemplateCoverageResult(
        muscleScores: {},
        exerciseToTemplates: {},
      );

  /// Coverage scores per muscle (lowercase muscle name → score)
  final Map<String, TemplateMuscleScore> muscleScores;

  /// Exercise name (lowercase) → list of template names containing it
  final Map<String, List<String>> exerciseToTemplates;

  /// Check if an exercise is already planned in any template
  bool isExercisePlanned(String exerciseName) =>
      exerciseToTemplates.containsKey(exerciseName.toLowerCase());

  /// Get templates containing a specific exercise
  List<String> getTemplatesForExercise(String exerciseName) =>
      exerciseToTemplates[exerciseName.toLowerCase()] ?? [];

  /// Get coverage for a specific muscle
  TemplateMuscleScore? getCoverage(String muscleName) =>
      muscleScores[muscleName.toLowerCase()];

  /// Check if a muscle has any template coverage
  bool hasCoverage(String muscleName) =>
      muscleScores[muscleName.toLowerCase()]?.hasAnyCoverage ?? false;

  /// Get all well-covered muscles (score ≥ 0.5)
  List<String> get wellCoveredMuscles => muscleScores.entries
      .where((e) => e.value.isWellCovered)
      .map((e) => e.key)
      .toList();

  /// Get all muscles with any coverage
  List<String> get coveredMuscles => muscleScores.entries
      .where((e) => e.value.hasAnyCoverage)
      .map((e) => e.key)
      .toList();

  /// Total number of unique exercises in templates
  int get totalPlannedExercises => exerciseToTemplates.length;

  /// Whether any templates were analyzed
  bool get hasData => muscleScores.isNotEmpty || exerciseToTemplates.isNotEmpty;

  @override
  String toString() =>
      'TemplateCoverageResult(${muscleScores.length} muscles, ${exerciseToTemplates.length} exercises)';
}

/// Adjusted neglected muscle with template context
///
/// Wraps a [NeglectedMuscle] with additional information about
/// template coverage, allowing severity adjustment.
///
/// **Severity Adjustment Rules**:
/// - Muscle in ≥2 templates → reduce severity by 1 level
/// - Muscle in ≥3 templates → reduce severity by 2 levels
/// - CRITICAL never drops below MEDIUM
///
/// **Usage**:
/// ```dart
/// final adjusted = AdjustedNeglectedMuscle(
///   original: neglectedMuscle,
///   coverage: templateCoverage.getCoverage('back'),
/// );
///
/// if (adjusted.hasPlannedExercises) {
///   print('This muscle will be trained in: ${adjusted.coveringTemplates}');
/// }
/// ```
class AdjustedNeglectedMuscle {
  AdjustedNeglectedMuscle({
    required this.original,
    TemplateMuscleScore? coverage,
  })  : _coverage = coverage,
        coveringTemplates = coverage?.templateNames ?? [],
        plannedExerciseCount = coverage?.totalExercises ?? 0;

  /// Original neglected muscle data
  final NeglectedMuscle original;

  /// Template coverage for this muscle (if any)
  final TemplateMuscleScore? _coverage;

  /// Templates covering this muscle
  final List<String> coveringTemplates;

  /// Number of planned exercises for this muscle
  final int plannedExerciseCount;

  /// Whether this muscle has exercises planned in templates
  bool get hasPlannedExercises => coveringTemplates.isNotEmpty;

  /// Whether severity was reduced due to template coverage
  bool get wasSeverityReduced =>
      hasPlannedExercises && adjustedSeverity != original.severity;

  /// Adjusted severity based on template coverage
  ///
  /// Rules:
  /// - ≥3 templates → reduce 2 levels (but not below MEDIUM)
  /// - ≥2 templates → reduce 1 level
  /// - <2 templates → no change
  NeglectSeverity get adjustedSeverity {
    if (!hasPlannedExercises) return original.severity;

    final templateCount = coveringTemplates.length;

    // Calculate severity reduction
    int reduction = 0;
    if (templateCount >= 3) {
      reduction = 2;
    } else if (templateCount >= 2) {
      reduction = 1;
    }

    if (reduction == 0) return original.severity;

    // Apply reduction
    final currentIndex = NeglectSeverity.values.indexOf(original.severity);
    final newIndex = (currentIndex + reduction)
        .clamp(0, NeglectSeverity.values.length - 1);

    return NeglectSeverity.values[newIndex];
  }

  /// Adjusted priority score (reduced if well covered)
  ///
  /// Reduces priority by 1-2 points based on template coverage
  double get adjustedPriority {
    if (!hasPlannedExercises) return original.priority;

    final reduction = (_coverage?.coverageScore ?? 0) * 2.0;
    return (original.priority - reduction).clamp(0.0, 10.0);
  }

  /// Muscle name (from original)
  String get muscleName => original.muscleName;

  /// Volume percentage (from original)
  double get volumePercentage => original.volumePercentage;

  @override
  String toString() =>
      'AdjustedNeglectedMuscle($muscleName: ${original.severity} → $adjustedSeverity, '
      '${coveringTemplates.length} templates)';
}
