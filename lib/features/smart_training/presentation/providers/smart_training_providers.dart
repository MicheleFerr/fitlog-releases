import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_training_metrics.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/progressive_overload_analysis.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_suggestion.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_workout_template.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/services/progressive_overload_engine.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/services/deload_detection_service.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/services/plateau_breaker_service.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/services/volume_optimizer_service.dart' hide TrainingExperience;
import 'package:gymbro_flutter_new/features/smart_training/domain/services/smart_workout_templates_service.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/services/smart_suggestions_engine.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Provider for smart training metrics analysis
final smartTrainingMetricsProvider = StateNotifierProvider<SmartTrainingMetricsNotifier, AsyncValue<List<SmartTrainingMetrics>>>(
  (ref) => SmartTrainingMetricsNotifier(),
);

class SmartTrainingMetricsNotifier extends StateNotifier<AsyncValue<List<SmartTrainingMetrics>>> {
  SmartTrainingMetricsNotifier() : super(const AsyncValue.loading());

  /// Analyze workout and generate metrics
  Future<void> analyzeWorkout(Workout workout) async {
    try {
      state = const AsyncValue.loading();
      
      // Convert workout to smart metrics
      final metrics = _convertWorkoutToMetrics(workout);
      
      // Get existing metrics and add new one
      final currentMetrics = state.value ?? [];
      final updatedMetrics = [metrics, ...currentMetrics].take(20).toList();
      
      state = AsyncValue.data(updatedMetrics);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  SmartTrainingMetrics _convertWorkoutToMetrics(Workout workout) {
    double totalVolume = 0.0;
    int totalSets = 0;
    int totalReps = 0;
    const double totalIntensity = 0.0;
    final exerciseMetrics = <ExerciseMetrics>[];
    final muscleGroupVolume = <String, double>{};

    for (final exercise in workout.exercises) {
      final setMetrics = <SetMetrics>[];
      double exerciseVolume = 0.0;
      double maxWeight = 0.0;
      double avgRPE = 0.0;
      int validSets = 0;

      for (final set in exercise.sets.where((s) => s.isCompleted && !s.isWarmup)) {
        final weight = set.weight ?? 0.0;
        final reps = (set.actualReps ?? set.reps) ?? 0;
        final volume = weight * reps;
        exerciseVolume += volume;
        totalVolume += volume;
        totalSets++;
        totalReps += reps;

        if (weight > maxWeight) maxWeight = weight;
        if (set.rpe != null) {
          avgRPE += set.rpe!;
          validSets++;
        }

        // Calculate 1RM for intensity
        final oneRM = ProgressiveOverloadEngine.calculateOneRM(
          weight,
          reps,
          rpe: set.rpe,
        );

        setMetrics.add(SetMetrics(
          setNumber: set.setNumber,
          weight: weight,
          targetReps: set.reps ?? 0,
          actualReps: reps,
          rpe: set.rpe ?? 7,
          estimatedOneRM: oneRM,
          intensityPercent: weight / oneRM * 100,
          volume: volume,
          isWarmup: set.isWarmup,
        ));
      }

      if (validSets > 0) {
        avgRPE /= validSets;
        final estimatedOneRM = setMetrics.isNotEmpty ? 
            setMetrics.map((s) => s.estimatedOneRM).reduce((a, b) => a > b ? a : b) : 0.0;

        exerciseMetrics.add(ExerciseMetrics(
          exerciseName: exercise.name,
          category: exercise.category.name,
          volume: exerciseVolume,
          maxWeight: maxWeight,
          averageWeight: setMetrics.isNotEmpty ? 
              setMetrics.map((s) => s.weight).reduce((a, b) => a + b) / setMetrics.length : 0.0,
          totalSets: exercise.sets.where((s) => !s.isWarmup).length,
          totalReps: totalReps,
          averageRPE: avgRPE,
          estimatedOneRM: estimatedOneRM,
          intensityScore: estimatedOneRM > 0 ? maxWeight / estimatedOneRM * 100 : 0.0,
          setMetrics: setMetrics,
        ));

        // Update muscle group volume
        final muscleGroup = _getMuscleGroupFromCategory(exercise.category);
        muscleGroupVolume[muscleGroup] = (muscleGroupVolume[muscleGroup] ?? 0.0) + exerciseVolume;
      }
    }

    final avgIntensity = exerciseMetrics.isNotEmpty ? 
        exerciseMetrics.map((e) => e.intensityScore).reduce((a, b) => a + b) / exerciseMetrics.length : 0.0;

    return SmartTrainingMetrics(
      userId: 'current_user', // TODO: Get from auth
      date: DateTime.now(),
      volume: totalVolume,
      totalSets: totalSets,
      totalReps: totalReps,
      averageIntensity: avgIntensity,
      trainingLoad: totalVolume * (avgIntensity / 100),
      sessionDuration: workout.duration?.inMinutes ?? 60,
      fatigueScore: 5.0, // TODO: Get from user input
      readinessScore: 8.0, // TODO: Get from user input
      muscleGroupVolume: muscleGroupVolume,
      exerciseMetrics: exerciseMetrics,
    );
  }

  String _getMuscleGroupFromCategory(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest: return 'chest';
      case ExerciseCategory.back: return 'back';
      case ExerciseCategory.shoulders: return 'shoulders';
      case ExerciseCategory.arms: return 'arms';
      case ExerciseCategory.legs: return 'legs';
      case ExerciseCategory.abs: return 'abs';
      default: return 'other';
    }
  }
}

/// Provider for progressive overload analysis
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final progressiveOverloadProvider = FutureProvider.autoDispose.family<ProgressiveOverloadAnalysis?, String>(
  (ref, exerciseName) async {
    final metricsAsync = ref.watch(smartTrainingMetricsProvider);
    
    return metricsAsync.when(
      data: (metrics) {
        if (metrics.length < 2) return null;
        
        // Generate overload recommendations
        final recommendations = ProgressiveOverloadEngine.generateOverloadRecommendations(
          exerciseName,
          metrics,
          null, // Previous analysis could be stored separately
        );

        // Calculate trends
        final exerciseMetrics = metrics
            .expand((m) => m.exerciseMetrics)
            .where((e) => e.exerciseName == exerciseName)
            .toList();

        if (exerciseMetrics.length < 2) return null;

        final volumeHistory = exerciseMetrics.asMap().entries.map((entry) => 
          TrendDataPoint(
            date: DateTime.now().subtract(Duration(days: entry.key * 3)),
            value: entry.value.volume,
          )
        ).toList();

        final trend = OverloadTrend(
          volumeTrend: _calculateTrend(exerciseMetrics.map((e) => e.volume).toList()),
          intensityTrend: _calculateTrend(exerciseMetrics.map((e) => e.intensityScore).toList()),
          oneRMTrend: _calculateTrend(exerciseMetrics.map((e) => e.estimatedOneRM).toList()),
          fatigueIndex: 0.5, // Could be calculated from metrics
          consistencyScore: 8, // Could be calculated from frequency
          volumeHistory: volumeHistory,
          intensityHistory: [], // Similar calculation
          oneRMHistory: [], // Similar calculation
        );

        return ProgressiveOverloadAnalysis(
          userId: 'current_user',
          exerciseName: exerciseName,
          analysisDate: DateTime.now(),
          recommendations: recommendations,
          trend: trend,
          progressRate: ProgressiveOverloadEngine.calculateProgressRate(metrics),
          stallWeeks: 0, // Calculate from trend
          isProgressing: trend.volumeTrend > 0 || trend.intensityTrend > 0,
          needsDeload: ProgressiveOverloadEngine.needsDeload(metrics),
          nextProgressionDate: DateTime.now().add(const Duration(days: 7)),
        );
      },
      loading: () => null,
      error: (_, __) => null,
    );
  },
);

double _calculateTrend(List<double> values) {
  if (values.length < 2) return 0.0;
  final recent = values.take(2).reduce((a, b) => a + b) / 2;
  final previous = values.skip(2).take(2).reduce((a, b) => a + b) / 2;
  return previous > 0 ? (recent - previous) / previous : 0.0;
}

/// Provider for deload detection
final deloadDetectionProvider = FutureProvider<DeloadAnalysis?>(
  (ref) async {
    final metricsAsync = ref.watch(smartTrainingMetricsProvider);
    
    return metricsAsync.when(
      data: (metrics) {
        if (metrics.length < 3) return null;
        return DeloadDetectionService.analyzeDeloadNeed(metrics);
      },
      loading: () => null,
      error: (_, __) => null,
    );
  },
);

/// Provider for plateau detection
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final plateauDetectionProvider = FutureProvider.autoDispose.family<PlateauDetection?, String>(
  (ref, exerciseName) async {
    final metricsAsync = ref.watch(smartTrainingMetricsProvider);

    return metricsAsync.when(
      data: (metrics) {
        if (metrics.length < 4) return null;
        return PlateauBreakerService.detectPlateau(exerciseName, metrics);
      },
      loading: () => null,
      error: (_, __) => null,
    );
  },
);

/// Provider for volume optimization
final volumeOptimizationProvider = FutureProvider<VolumeOptimization?>(
  (ref) async {
    final metricsAsync = ref.watch(smartTrainingMetricsProvider);
    
    return metricsAsync.when(
      data: (metrics) {
        if (metrics.isEmpty) return null;
        
        // Calculate current muscle group volumes
        final currentVolumes = <String, MuscleGroupData>{};
        final latest = metrics.first;
        
        for (final entry in latest.muscleGroupVolume.entries) {
          currentVolumes[entry.key] = MuscleGroupData(
            weeklyVolume: entry.value,
            weeksOfData: metrics.length,
            averageIntensity: 75.0, // Could be calculated from metrics
          );
        }
        
        return VolumeOptimizerService.optimizeVolume(
          'current_user',
          TrainingGoal.hypertrophy, // TODO: Get from user preferences
          TrainingExperience.intermediate, // TODO: Get from user profile
          metrics,
          currentVolumes,
        );
      },
      loading: () => null,
      error: (_, __) => null,
    );
  },
);

/// Provider for smart workout templates
final smartWorkoutTemplatesProvider = Provider<List<SmartWorkoutTemplate>>((ref) {
  return SmartWorkoutTemplatesService.getAllTemplates();
});

/// Provider for filtered templates
final filteredTemplatesProvider = Provider.family<List<SmartWorkoutTemplate>, TemplateFilter>(
  (ref, filter) {
    final allTemplates = ref.watch(smartWorkoutTemplatesProvider);
    
    return SmartWorkoutTemplatesService.filterTemplates(
      category: filter.category,
      difficulty: filter.difficulty,
      style: filter.style,
      maxDuration: filter.maxDuration,
      requiredTags: filter.requiredTags,
      premiumOnly: filter.premiumOnly,
    );
  },
);

/// Provider for smart suggestions
final smartSuggestionsProvider = StateNotifierProvider<SmartSuggestionsNotifier, List<SmartSuggestion>>(
  (ref) => SmartSuggestionsNotifier(ref),
);

class SmartSuggestionsNotifier extends StateNotifier<List<SmartSuggestion>> {
  
  SmartSuggestionsNotifier(this._ref) : super([]);
  final Ref _ref;

  /// Generate suggestions for current context
  Future<void> generateSuggestions(SuggestionContext context) async {
    try {
      final metricsAsync = _ref.read(smartTrainingMetricsProvider);
      
      metricsAsync.when(
        data: (metrics) {
          final suggestions = SmartSuggestionsEngine.generateSuggestions(context, metrics);
          state = suggestions;
        },
        loading: () => state = [],
        error: (_, __) => state = [],
      );
    } catch (e) {
      state = [];
    }
  }

  /// Apply a suggestion
  void applySuggestion(String suggestionId) {
    state = state.map((suggestion) {
      if (suggestion.id == suggestionId) {
        return suggestion.copyWith(
          isApplied: true,
          appliedAt: DateTime.now(),
        );
      }
      return suggestion;
    }).toList();
  }

  /// Dismiss a suggestion
  void dismissSuggestion(String suggestionId) {
    state = state.map((suggestion) {
      if (suggestion.id == suggestionId) {
        return suggestion.copyWith(
          isDismissed: true,
          dismissedAt: DateTime.now(),
        );
      }
      return suggestion;
    }).toList();
  }

  /// Clear all suggestions
  void clearSuggestions() {
    state = [];
  }
}

/// Template filter model
class TemplateFilter {

  const TemplateFilter({
    this.category,
    this.difficulty,
    this.style,
    this.maxDuration,
    this.requiredTags,
    this.premiumOnly,
  });
  final WorkoutCategory? category;
  final DifficultyLevel? difficulty;
  final TrainingStyle? style;
  final int? maxDuration;
  final List<String>? requiredTags;
  final bool? premiumOnly;

  TemplateFilter copyWith({
    WorkoutCategory? category,
    DifficultyLevel? difficulty,
    TrainingStyle? style,
    int? maxDuration,
    List<String>? requiredTags,
    bool? premiumOnly,
  }) {
    return TemplateFilter(
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      style: style ?? this.style,
      maxDuration: maxDuration ?? this.maxDuration,
      requiredTags: requiredTags ?? this.requiredTags,
      premiumOnly: premiumOnly ?? this.premiumOnly,
    );
  }
}

/// Provider for current template filter
final templateFilterProvider = StateProvider<TemplateFilter>((ref) {
  return const TemplateFilter();
});

/// Provider for recommended templates
final recommendedTemplatesProvider = FutureProvider<List<SmartWorkoutTemplate>>(
  (ref) async {
    // TODO: Get user preferences from profile
    return SmartWorkoutTemplatesService.getRecommendedTemplates(
      experience: TrainingExperience.intermediate,
      goals: ['hypertrophy', 'strength'],
      availableTime: 60,
      preferredStyles: ['bodybuilding', 'powerlifting'],
    );
  },
);

/// Provider for template search
final templateSearchProvider = StateProvider<String>((ref) => '');

/// Provider for searched templates
final searchedTemplatesProvider = Provider<List<SmartWorkoutTemplate>>((ref) {
  final query = ref.watch(templateSearchProvider);
  
  if (query.isEmpty) {
    return ref.watch(smartWorkoutTemplatesProvider);
  }
  
  return SmartWorkoutTemplatesService.searchTemplates(query);
});