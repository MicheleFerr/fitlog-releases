/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider (PERFORMANCE MONITORING & MEMOIZATION)
/// 🌍 Localization: ✅ N/A (utility provider)
/// 🎨 Theme: ✅ N/A (utility provider)
/// 📱 Platform: iOS/Android/Universal
/// 
/// Dependencies:
/// - Riverpod: Memoization and caching
/// - Performance: Memory and CPU optimization
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';

// 🚀 PERFORMANCE MONITORING & MEMOIZATION PROVIDERS

// 📊 MEMOIZED WORKOUT CALCULATIONS
class WorkoutCalculations {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Clear expired cache entries
  static void _cleanupCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheExpiry)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  // Get cached value or compute and cache
  static T _getCachedOrCompute<T>(String key, T Function() compute) {
    _cleanupCache();
    
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }
    
    final result = compute();
    _cache[key] = result;
    _cacheTimestamps[key] = DateTime.now();
    
    return result;
  }

  // 🧮 HEAVY CALCULATION: Workout volume (weight * reps * sets)
  static double calculateTotalVolume(Workout workout) {
    final cacheKey = 'volume_${workout.id}_${workout.hashCode}';
    
    return _getCachedOrCompute(cacheKey, () {
      return workout.exercises.fold<double>(0.0, (total, exercise) {
        final exerciseVolume = exercise.sets.fold<double>(0.0, (exerciseTotal, set) {
          if (set.isCompleted) {
            return exerciseTotal + (set.weight * set.reps);
          }
          return exerciseTotal;
        });
        return total + exerciseVolume;
      });
    });
  }

  // 🧮 HEAVY CALCULATION: Personal records detection
  static List<PersonalRecord> detectPersonalRecords(Workout workout, List<Workout> history) {
    final cacheKey = 'pr_${workout.id}_${history.length}_${history.fold<int>(0, (sum, w) => sum + w.hashCode)}';
    
    return _getCachedOrCompute(cacheKey, () {
      final records = <PersonalRecord>[];
      
      for (final exercise in workout.exercises) {
        // Find best previous performance for this exercise
        final previousBest = _findBestPreviousPerformance(exercise.name, history);
        
        // Check each completed set for PRs
        for (final set in exercise.sets.where((s) => s.isCompleted)) {
          if (_isPersonalRecord(set, previousBest)) {
            records.add(PersonalRecord(
              exerciseName: exercise.name,
              weight: set.weight,
              reps: set.reps,
              volume: set.weight * set.reps,
              date: DateTime.now(),
            ));
          }
        }
      }
      
      return records;
    });
  }

  // 🧮 HEAVY CALCULATION: Exercise progression analysis
  static Map<String, ExerciseProgression> analyzeProgression(List<Workout> workouts) {
    final cacheKey = 'progression_${workouts.length}_${workouts.fold<int>(0, (sum, w) => sum + w.hashCode)}';
    
    return _getCachedOrCompute(cacheKey, () {
      final progressionMap = <String, ExerciseProgression>{};
      
      // Group workouts by exercise
      final exerciseData = <String, List<WorkoutExerciseData>>{};
      
      for (final workout in workouts) {
        if (workout.isCompleted && workout.completedAt != null) {
          for (final exercise in workout.exercises) {
            exerciseData.putIfAbsent(exercise.name, () => []);
            
            final maxWeight = exercise.sets
                .where((s) => s.isCompleted)
                .map((s) => s.weight)
                .maxOrNull ?? 0.0;
            
            final totalVolume = exercise.sets
                .where((s) => s.isCompleted)
                .fold<double>(0.0, (sum, s) => sum + (s.weight * s.reps));
            
            exerciseData[exercise.name]!.add(WorkoutExerciseData(
              date: workout.completedAt!,
              maxWeight: maxWeight,
              totalVolume: totalVolume,
              totalSets: exercise.sets.where((s) => s.isCompleted).length,
            ));
          }
        }
      }
      
      // Calculate progression for each exercise
      for (final entry in exerciseData.entries) {
        final exerciseName = entry.key;
        final data = entry.value..sort((a, b) => a.date.compareTo(b.date));
        
        if (data.length >= 2) {
          final first = data.first;
          final last = data.last;
          
          final weightProgression = ((last.maxWeight - first.maxWeight) / first.maxWeight) * 100;
          final volumeProgression = ((last.totalVolume - first.totalVolume) / first.totalVolume) * 100;
          
          progressionMap[exerciseName] = ExerciseProgression(
            exerciseName: exerciseName,
            weightProgression: weightProgression,
            volumeProgression: volumeProgression,
            workoutCount: data.length,
            firstWorkoutDate: first.date,
            lastWorkoutDate: last.date,
            trend: _calculateTrend(data),
          );
        }
      }
      
      return progressionMap;
    });
  }

  static ExerciseSet? _findBestPreviousPerformance(String exerciseName, List<Workout> history) {
    ExerciseSet? best;
    double bestVolume = 0;
    
    for (final workout in history) {
      if (workout.isCompleted) {
        for (final exercise in workout.exercises) {
          if (exercise.name == exerciseName) {
            for (final set in exercise.sets.where((s) => s.isCompleted)) {
              final volume = set.weight * set.reps;
              if (volume > bestVolume) {
                bestVolume = volume;
                best = set;
              }
            }
          }
        }
      }
    }
    
    return best;
  }

  static bool _isPersonalRecord(ExerciseSet set, ExerciseSet? previousBest) {
    if (previousBest == null) return true;
    
    final currentVolume = set.weight * set.reps;
    final previousVolume = previousBest.weight * previousBest.reps;
    
    return currentVolume > previousVolume || 
           (set.weight > previousBest.weight && set.reps >= previousBest.reps);
  }

  static ProgressionTrend _calculateTrend(List<WorkoutExerciseData> data) {
    if (data.length < 3) return ProgressionTrend.stable;
    
    final recentData = data.takeLast(3).toList();
    final weights = recentData.map((d) => d.maxWeight).toList();
    
    bool increasing = true;
    bool decreasing = true;
    
    for (int i = 1; i < weights.length; i++) {
      if (weights[i] <= weights[i - 1]) increasing = false;
      if (weights[i] >= weights[i - 1]) decreasing = false;
    }
    
    if (increasing) return ProgressionTrend.increasing;
    if (decreasing) return ProgressionTrend.decreasing;
    return ProgressionTrend.stable;
  }
}

// 🎯 WORKOUT PERFORMANCE PROVIDERS

// Memoized total volume provider
final workoutTotalVolumeProvider = Provider.family<double, Workout>((ref, workout) {
  return WorkoutCalculations.calculateTotalVolume(workout);
});

// Current workout volume provider
final currentWorkoutVolumeProvider = Provider<double>((ref) {
  // OPTIMIZED: Only rebuild when workout exercises or sets change
  final workout = ref.watch(
    currentWorkoutProvider.select((w) => w)
  );
  if (workout == null) return 0.0;
  
  return ref.watch(workoutTotalVolumeProvider(workout));
});

// Personal records provider (requires workout history)
final personalRecordsProvider = Provider.family<List<PersonalRecord>, ({Workout workout, List<Workout> history})>((ref, params) {
  return WorkoutCalculations.detectPersonalRecords(params.workout, params.history);
});

// Exercise progression analysis provider
final exerciseProgressionProvider = Provider.family<Map<String, ExerciseProgression>, List<Workout>>((ref, workouts) {
  return WorkoutCalculations.analyzeProgression(workouts);
});

// 📊 PERFORMANCE MONITORING PROVIDER
final performanceMonitorProvider = StateNotifierProvider<PerformanceMonitor, PerformanceMetrics>((ref) {
  return PerformanceMonitor();
});

class PerformanceMonitor extends StateNotifier<PerformanceMetrics> {
  PerformanceMonitor() : super(PerformanceMetrics());

  void recordRebuild(String widgetName) {
    final now = DateTime.now();
    final metrics = state;
    
    final updatedRebuilds = {
      ...metrics.widgetRebuilds,
      widgetName: (metrics.widgetRebuilds[widgetName] ?? 0) + 1,
    };
    
    final updatedTimestamps = {
      ...metrics.lastRebuildTimestamps,
      widgetName: now,
    };
    
    state = metrics.copyWith(
      widgetRebuilds: updatedRebuilds,
      lastRebuildTimestamps: updatedTimestamps,
      totalRebuilds: metrics.totalRebuilds + 1,
    );
  }

  void recordProviderWatch(String providerName) {
    final metrics = state;
    
    final updatedWatches = {
      ...metrics.providerWatches,
      providerName: (metrics.providerWatches[providerName] ?? 0) + 1,
    };
    
    state = metrics.copyWith(
      providerWatches: updatedWatches,
      totalProviderWatches: metrics.totalProviderWatches + 1,
    );
  }

  void clearMetrics() {
    state = PerformanceMetrics();
  }

  // Get widgets with excessive rebuilds (more than 10 per minute)
  List<String> getExcessiveRebuildWidgets() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    
    return state.lastRebuildTimestamps.entries
        .where((entry) => 
          entry.value.isAfter(oneMinuteAgo) && 
          (state.widgetRebuilds[entry.key] ?? 0) > 10)
        .map((entry) => entry.key)
        .toList();
  }
}

// 📊 DATA CLASSES

class PersonalRecord {

  PersonalRecord({
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.volume,
    required this.date,
  });
  final String exerciseName;
  final double weight;
  final int reps;
  final double volume;
  final DateTime date;
}

class ExerciseProgression {

  ExerciseProgression({
    required this.exerciseName,
    required this.weightProgression,
    required this.volumeProgression,
    required this.workoutCount,
    required this.firstWorkoutDate,
    required this.lastWorkoutDate,
    required this.trend,
  });
  final String exerciseName;
  final double weightProgression; // Percentage change
  final double volumeProgression; // Percentage change
  final int workoutCount;
  final DateTime firstWorkoutDate;
  final DateTime lastWorkoutDate;
  final ProgressionTrend trend;
}

enum ProgressionTrend {
  increasing,
  decreasing,
  stable,
}

class WorkoutExerciseData {

  WorkoutExerciseData({
    required this.date,
    required this.maxWeight,
    required this.totalVolume,
    required this.totalSets,
  });
  final DateTime date;
  final double maxWeight;
  final double totalVolume;
  final int totalSets;
}

class PerformanceMetrics {

  PerformanceMetrics({
    this.widgetRebuilds = const {},
    this.providerWatches = const {},
    this.lastRebuildTimestamps = const {},
    this.totalRebuilds = 0,
    this.totalProviderWatches = 0,
  });
  final Map<String, int> widgetRebuilds;
  final Map<String, int> providerWatches;
  final Map<String, DateTime> lastRebuildTimestamps;
  final int totalRebuilds;
  final int totalProviderWatches;

  PerformanceMetrics copyWith({
    Map<String, int>? widgetRebuilds,
    Map<String, int>? providerWatches,
    Map<String, DateTime>? lastRebuildTimestamps,
    int? totalRebuilds,
    int? totalProviderWatches,
  }) {
    return PerformanceMetrics(
      widgetRebuilds: widgetRebuilds ?? this.widgetRebuilds,
      providerWatches: providerWatches ?? this.providerWatches,
      lastRebuildTimestamps: lastRebuildTimestamps ?? this.lastRebuildTimestamps,
      totalRebuilds: totalRebuilds ?? this.totalRebuilds,
      totalProviderWatches: totalProviderWatches ?? this.totalProviderWatches,
    );
  }
}

// 🎯 PERFORMANCE DEBUG WIDGET (Development only)
// Use this to monitor rebuilds in debug mode
class PerformanceDebugWidget extends ConsumerWidget {

  const PerformanceDebugWidget({
    super.key,
    required this.widgetName,
    required this.child,
  });
  final String widgetName;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only track in debug mode
    assert(() {
      ref.read(performanceMonitorProvider.notifier).recordRebuild(widgetName);
      return true;
    }());
    
    return child;
  }
}