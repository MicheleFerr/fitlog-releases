/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// Template Coverage Provider - Analyzes muscle coverage in user templates
///
/// **Features**:
/// - Analyzes all user templates for muscle coverage
/// - Provides adjusted neglected muscles with severity reduction
/// - Caches coverage analysis for performance
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/template_coverage.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/template_aware_balance_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

/// Provider for template coverage analysis
///
/// Analyzes all user templates to determine which muscles are covered.
/// Result is cached and invalidated when templates change.
///
/// **Usage**:
/// ```dart
/// final coverageAsync = ref.watch(templateCoverageProvider);
///
/// coverageAsync.when(
///   data: (coverage) {
///     if (coverage.isExercisePlanned('Lat Pulldown')) {
///       print('Already in templates!');
///     }
///   },
///   loading: () => LoadingIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
final templateCoverageProvider =
    FutureProvider.autoDispose<TemplateCoverageResult>((ref) async {
      // Get user templates
      final templates = await ref.watch(customWorkoutTemplatesProvider.future);

      // Get exercise muscle map
      final muscleMap = await ref.watch(exerciseMuscleMapProvider.future);

      // Analyze coverage
      final service = TemplateAwareBalanceService();
      return service.analyzeTemplateCoverage(
        templates: templates,
        exerciseMuscleMap: muscleMap,
      );
    });

/// Parameters for adjusted neglected muscles
class AdjustedNeglectedParams {
  const AdjustedNeglectedParams({required this.neglectedMuscles});

  final List<NeglectedMuscle> neglectedMuscles;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdjustedNeglectedParams) return false;
    if (neglectedMuscles.length != other.neglectedMuscles.length) return false;

    for (var i = 0; i < neglectedMuscles.length; i++) {
      if (neglectedMuscles[i].muscleName !=
          other.neglectedMuscles[i].muscleName) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(neglectedMuscles.map((m) => m.muscleName));
}

/// Provider for adjusted neglected muscles with template context
///
/// Takes a list of neglected muscles and adjusts their severity
/// based on template coverage.
///
/// **Severity Adjustment Rules**:
/// - Muscle in ≥2 templates → reduce severity by 1 level
/// - Muscle in ≥3 templates → reduce severity by 2 levels
/// - CRITICAL never drops below MEDIUM
///
/// **Usage**:
/// ```dart
/// final adjustedAsync = ref.watch(
///   adjustedNeglectedMusclesProvider(
///     AdjustedNeglectedParams(neglectedMuscles: neglected),
///   ),
/// );
/// ```
final adjustedNeglectedMusclesProvider = FutureProvider.autoDispose
    .family<List<AdjustedNeglectedMuscle>, AdjustedNeglectedParams>((
      ref,
      params,
    ) async {
      // Get template coverage
      final coverage = await ref.watch(templateCoverageProvider.future);

      // Adjust neglected muscles
      final service = TemplateAwareBalanceService();
      return service.adjustNeglectedMuscles(
        neglected: params.neglectedMuscles,
        coverage: coverage,
      );
    });

/// Provider for coverage summary text
///
/// Returns a human-readable summary for UI display.
///
/// **Usage**:
/// ```dart
/// final summary = ref.watch(
///   coverageSummaryProvider(neglectedMuscles),
/// );
/// // Returns: "2 neglected muscles, both covered by your templates"
/// ```
final coverageSummaryProvider = FutureProvider.autoDispose
    .family<String, List<NeglectedMuscle>>((ref, neglected) async {
      final coverage = await ref.watch(templateCoverageProvider.future);

      final service = TemplateAwareBalanceService();
      return service.getCoverageSummary(
        neglected: neglected,
        coverage: coverage,
      );
    });

/// Provider to check if a specific exercise is in templates
///
/// **Usage**:
/// ```dart
/// final isPlanned = ref.watch(isExercisePlannedProvider('Lat Pulldown'));
/// ```
final isExercisePlannedProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, exerciseName) async {
      final coverage = await ref.watch(templateCoverageProvider.future);
      return coverage.isExercisePlanned(exerciseName);
    });

/// Provider to get templates containing a specific exercise
///
/// **Usage**:
/// ```dart
/// final templates = ref.watch(templatesForExerciseProvider('Lat Pulldown'));
/// // Returns: ['Pull Day', 'Full Body A']
/// ```
final templatesForExerciseProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, exerciseName) async {
      final coverage = await ref.watch(templateCoverageProvider.future);
      return coverage.getTemplatesForExercise(exerciseName);
    });
