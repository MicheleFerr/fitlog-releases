/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: data
 * 🎯 Feature: analytics
 * 🔧 Type: repository implementation
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Firebase: Firestore
 * - Hive: Local storage
 * - workout/domain/entities: Workout
 * - analytics/domain: Repository, Entities, Services
 */

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';

/// Firebase and Hive implementation of WorkoutAnalyticsRepository
class WorkoutAnalyticsRepositoryImpl implements WorkoutAnalyticsRepository {
  final FirebaseFirestore _firestore;
  final Box<Map<String, dynamic>> _metricsCache;
  final PRTracker _prTracker;

  // Stream controllers for real-time updates
  final Map<String, StreamController<WorkoutAnalyticsUpdate>> _updateControllers = {};

  WorkoutAnalyticsRepositoryImpl({
    FirebaseFirestore? firestore,
    required Box<Map<String, dynamic>> metricsCache,
    PRTracker? prTracker,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _metricsCache = metricsCache,
        _prTracker = prTracker ?? PRTracker();

  @override
  Future<List<Workout>> getHistoricalWorkouts(
    String userId, {
    int limit = 50,
    DateTime? since,
  }) async {
    try {
      // First try to get workouts from local Hive storage
      final localWorkouts = await _getLocalWorkouts(userId, limit: limit, since: since);
      
      if (localWorkouts.isNotEmpty) {
        print('📊 Analytics: Using ${localWorkouts.length} local workouts from Hive');
        return localWorkouts;
      }
      
      // If no local workouts, try Firestore (for backward compatibility)
      print('📊 Analytics: No local workouts, trying Firestore...');
      Query query = _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .orderBy('endTime', descending: true)
          .limit(limit);

      if (since != null) {
        query = query.where('endTime', isGreaterThan: Timestamp.fromDate(since));
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Workout.fromJson(data);
      }).toList();
      
    } catch (e) {
      print('Error fetching historical workouts: $e');
      return [];
    }
  }
  
  /// Get workouts from local Hive storage
  Future<List<Workout>> _getLocalWorkouts(
    String userId, {
    int? limit,
    DateTime? since,
  }) async {
    try {
      final box = await Hive.openBox<Map>('workouts');
      
      // Get all workouts for this user
      var workouts = box.keys
          .where((key) => key.toString().startsWith('${userId}_'))
          .map((key) {
            final data = box.get(key);
            if (data == null) return null;
            
            try {
              // Convert Map<dynamic, dynamic> to Map<String, dynamic>
              final Map<String, dynamic> jsonData;
              if (data is Map<String, dynamic>) {
                jsonData = data;
              } else if (data is Map) {
                jsonData = Map<String, dynamic>.from(
                  data.map((key, value) => MapEntry(key.toString(), value))
                );
              } else {
                return null;
              }
              
              // Convert to domain entity
              final workoutModel = WorkoutModel.fromJson(jsonData);
              return workoutModel.toDomain();
            } catch (e) {
              print('Error parsing workout: $e');
              return null;
            }
          })
          .where((workout) => workout != null)
          .cast<Workout>()
          .toList();
      
      // Filter by status (only completed)
      workouts = workouts.where((w) => w.status == WorkoutStatus.completed).toList();
      
      // Filter by date if specified
      if (since != null) {
        workouts = workouts.where((w) => 
          w.endTime != null && w.endTime!.isAfter(since)
        ).toList();
      }
      
      // Sort by date (most recent first)
      workouts.sort((a, b) => 
        (b.endTime ?? b.updatedAt).compareTo(a.endTime ?? a.updatedAt)
      );
      
      // Apply limit
      if (limit != null && workouts.length > limit) {
        workouts = workouts.take(limit).toList();
      }
      
      return workouts;
    } catch (e) {
      print('Error fetching local workouts: $e');
      return [];
    }
  }

  @override
  Future<List<Workout>> getSimilarWorkouts(
    String userId,
    Workout targetWorkout, {
    int limit = 10,
    double minSimilarity = 0.3,
  }) async {
    // For now, get recent workouts and filter by muscle groups
    // In a full implementation, this would use ML/vector similarity
    
    final recentWorkouts = await getHistoricalWorkouts(userId, limit: 100);
    final targetMuscleGroups = targetWorkout.exercises
        .map((e) => e.category)
        .toSet();

    final similarWorkouts = recentWorkouts.where((workout) {
      final workoutMuscleGroups = workout.exercises
          .map((e) => e.category)
          .toSet();
      
      final overlap = targetMuscleGroups.intersection(workoutMuscleGroups);
      final union = targetMuscleGroups.union(workoutMuscleGroups);
      
      final similarity = union.isEmpty ? 0.0 : overlap.length / union.length;
      return similarity >= minSimilarity;
    }).take(limit).toList();

    return similarWorkouts;
  }

  @override
  Future<List<PersonalRecord>> getUserPRs(String userId) async {
    return await _prTracker.getUserPRs(userId);
  }

  @override
  Future<Map<PRType, PersonalRecord>> getExercisePRs(
    String userId,
    String exerciseId,
  ) async {
    return await _prTracker.getExercisePRs(userId, exerciseId);
  }

  @override
  Future<void> savePR(PersonalRecord pr) async {
    await _prTracker.savePR(pr);
    
    // Notify subscribers of PR achievement
    _notifyPRUpdate(pr);
  }

  @override
  Future<List<WorkoutMetrics>> getWorkoutMetricsHistory(
    String userId, {
    int limit = 30,
    DateTime? since,
  }) async {
    try {
      Query query = _firestore
          .collection('workoutMetrics')
          .where('userId', isEqualTo: userId)
          .orderBy('calculatedAt', descending: true)
          .limit(limit);

      if (since != null) {
        query = query.where('calculatedAt', isGreaterThan: Timestamp.fromDate(since));
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _workoutMetricsFromFirestore(data);
      }).toList();
      
    } catch (e) {
      print('Error fetching workout metrics history: $e');
      return [];
    }
  }

  @override
  Future<void> cacheWorkoutMetrics(WorkoutMetrics metrics) async {
    try {
      final data = _workoutMetricsToMap(metrics);
      await _metricsCache.put(metrics.workoutId, data);
    } catch (e) {
      print('Error caching workout metrics: $e');
    }
  }

  @override
  Future<WorkoutMetrics?> getCachedWorkoutMetrics(String workoutId) async {
    try {
      final data = _metricsCache.get(workoutId);
      if (data == null) return null;
      
      return _workoutMetricsFromMap(data);
    } catch (e) {
      print('Error getting cached workout metrics: $e');
      return null;
    }
  }

  @override
  Future<WorkoutAnalyticsStats> getAnalyticsStats(String userId) async {
    try {
      // Get workout statistics from local storage first, then Firestore
      final workouts = await getHistoricalWorkouts(userId, limit: 1000);
      final prs = await getUserPRs(userId);
      
      print('📊 Analytics Stats: Found ${workouts.length} total workouts for stats calculation');

      if (workouts.isEmpty) {
        return const WorkoutAnalyticsStats(
          totalWorkouts: 0,
          totalPRs: 0,
          averageWorkoutVolume: 0,
          averageWorkoutDuration: 0,
          totalVolumeLifted: 0,
          exerciseFrequency: {},
          exerciseVolumeDistribution: {},
        );
      }

      // Calculate statistics
      final totalVolume = workouts.fold(0.0, (sum, workout) {
        return sum + WorkoutMetrics.fromWorkout(workout).totalVolume;
      });

      final totalDuration = workouts.fold(0.0, (sum, workout) {
        return sum + (workout.duration?.inMinutes ?? 0);
      });

      final exerciseFreq = <String, int>{};
      final exerciseVolDist = <String, double>{};

      for (final workout in workouts) {
        for (final exercise in workout.exercises) {
          exerciseFreq[exercise.name] = (exerciseFreq[exercise.name] ?? 0) + 1;
          
          final exerciseVolume = exercise.sets
              .where((s) => s.isCompleted)
              .fold(0.0, (sum, set) => sum + set.volume);
          
          exerciseVolDist[exercise.name] = 
              (exerciseVolDist[exercise.name] ?? 0) + exerciseVolume;
        }
      }

      workouts.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

      return WorkoutAnalyticsStats(
        totalWorkouts: workouts.length,
        totalPRs: prs.length,
        averageWorkoutVolume: totalVolume / workouts.length,
        averageWorkoutDuration: totalDuration / workouts.length,
        totalVolumeLifted: totalVolume,
        exerciseFrequency: exerciseFreq,
        exerciseVolumeDistribution: exerciseVolDist,
        firstWorkoutDate: workouts.isNotEmpty ? workouts.first.updatedAt : null,
        lastWorkoutDate: workouts.isNotEmpty ? workouts.last.updatedAt : null,
      );

    } catch (e) {
      print('Error calculating analytics stats: $e');
      return const WorkoutAnalyticsStats(
        totalWorkouts: 0,
        totalPRs: 0,
        averageWorkoutVolume: 0,
        averageWorkoutDuration: 0,
        totalVolumeLifted: 0,
        exerciseFrequency: {},
        exerciseVolumeDistribution: {},
      );
    }
  }

  @override
  Stream<WorkoutAnalyticsUpdate> watchWorkoutUpdates(String workoutId) {
    if (!_updateControllers.containsKey(workoutId)) {
      _updateControllers[workoutId] = StreamController<WorkoutAnalyticsUpdate>.broadcast();
    }

    return _updateControllers[workoutId]!.stream;
  }

  /// Notify subscribers of workout metrics update
  void notifyWorkoutUpdate(WorkoutMetrics metrics) {
    final controller = _updateControllers[metrics.workoutId];
    if (controller != null && !controller.isClosed) {
      controller.add(WorkoutAnalyticsUpdate(
        workoutId: metrics.workoutId,
        metrics: metrics,
        newPRs: metrics.personalRecords,
        timestamp: DateTime.now(),
      ));
    }
  }

  /// Notify subscribers of PR achievement
  void _notifyPRUpdate(PersonalRecord pr) {
    // This would typically be called from the workout context
    // For now, we'll emit a minimal update
    final prAchieved = PersonalRecordAchieved(
      exerciseId: pr.exerciseId,
      exerciseName: pr.exerciseName,
      type: pr.type,
      newValue: pr.value,
      previousValue: pr.previousValue,
      achievedAt: pr.achievedAt,
      context: pr.metadata,
    );

    // Find the appropriate controller (would need workout context)
    for (final controller in _updateControllers.values) {
      if (!controller.isClosed) {
        controller.add(WorkoutAnalyticsUpdate(
          workoutId: 'unknown', // Would need workout context
          metrics: WorkoutMetrics.empty('unknown'),
          newPRs: [prAchieved],
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  /// Save workout metrics to Firestore
  Future<void> saveWorkoutMetrics(WorkoutMetrics metrics, String userId) async {
    try {
      final data = _workoutMetricsToFirestore(metrics, userId);
      await _firestore.collection('workoutMetrics').add(data);
    } catch (e) {
      print('Error saving workout metrics: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    for (final controller in _updateControllers.values) {
      controller.close();
    }
    _updateControllers.clear();
  }

  // Private helper methods

  Map<String, dynamic> _workoutMetricsToFirestore(WorkoutMetrics metrics, String userId) {
    return {
      'userId': userId,
      'workoutId': metrics.workoutId,
      'calculatedAt': Timestamp.fromDate(metrics.calculatedAt),
      'totalVolume': metrics.totalVolume,
      'workingSetsVolume': metrics.workingSetsVolume,
      'warmupVolume': metrics.warmupVolume,
      'volumeByMuscleGroup': metrics.volumeByMuscleGroup.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'totalSets': metrics.totalSets,
      'completedSets': metrics.completedSets,
      'workingSets': metrics.workingSets,
      'warmupSets': metrics.warmupSets,
      'averageWeight': metrics.averageWeight,
      'averageRPE': metrics.averageRPE,
      'averageIntensity': metrics.averageIntensity,
      'peakIntensity': metrics.peakIntensity,
      'totalDurationMinutes': metrics.totalDuration.inMinutes,
      'workingTimeMinutes': metrics.workingTime.inMinutes,
      'restTimeMinutes': metrics.restTime.inMinutes,
      'trainingDensity': metrics.trainingDensity,
      'completionPercentage': metrics.completionPercentage,
      'exercisesCompleted': metrics.exercisesCompleted,
      'totalExercises': metrics.totalExercises,
      'qualityScore': metrics.qualityScore,
    };
  }

  WorkoutMetrics _workoutMetricsFromFirestore(Map<String, dynamic> data) {
    return WorkoutMetrics(
      workoutId: data['workoutId'] ?? '',
      calculatedAt: (data['calculatedAt'] as Timestamp).toDate(),
      totalVolume: (data['totalVolume'] as num?)?.toDouble() ?? 0,
      workingSetsVolume: (data['workingSetsVolume'] as num?)?.toDouble() ?? 0,
      warmupVolume: (data['warmupVolume'] as num?)?.toDouble() ?? 0,
      volumeByMuscleGroup: _parseVolumeByMuscleGroup(data['volumeByMuscleGroup']),
      totalSets: data['totalSets'] ?? 0,
      completedSets: data['completedSets'] ?? 0,
      workingSets: data['workingSets'] ?? 0,
      warmupSets: data['warmupSets'] ?? 0,
      averageWeight: (data['averageWeight'] as num?)?.toDouble() ?? 0,
      averageRPE: (data['averageRPE'] as num?)?.toDouble() ?? 0,
      averageIntensity: (data['averageIntensity'] as num?)?.toDouble() ?? 0,
      peakIntensity: (data['peakIntensity'] as num?)?.toDouble() ?? 0,
      totalDuration: Duration(minutes: data['totalDurationMinutes'] ?? 0),
      workingTime: Duration(minutes: data['workingTimeMinutes'] ?? 0),
      restTime: Duration(minutes: data['restTimeMinutes'] ?? 0),
      trainingDensity: (data['trainingDensity'] as num?)?.toDouble() ?? 0,
      completionPercentage: (data['completionPercentage'] as num?)?.toDouble() ?? 0,
      exercisesCompleted: data['exercisesCompleted'] ?? 0,
      totalExercises: data['totalExercises'] ?? 0,
    );
  }

  Map<String, dynamic> _workoutMetricsToMap(WorkoutMetrics metrics) {
    return {
      'workoutId': metrics.workoutId,
      'calculatedAt': metrics.calculatedAt.toIso8601String(),
      'totalVolume': metrics.totalVolume,
      'completedSets': metrics.completedSets,
      'totalSets': metrics.totalSets,
      'completionPercentage': metrics.completionPercentage,
      'trainingDensity': metrics.trainingDensity,
      'averageRPE': metrics.averageRPE,
      'totalDurationMinutes': metrics.totalDuration.inMinutes,
    };
  }

  WorkoutMetrics _workoutMetricsFromMap(Map<String, dynamic> data) {
    return WorkoutMetrics(
      workoutId: data['workoutId'] ?? '',
      calculatedAt: DateTime.parse(data['calculatedAt'] ?? DateTime.now().toIso8601String()),
      totalVolume: (data['totalVolume'] as num?)?.toDouble() ?? 0,
      workingSetsVolume: 0, // Simplified for cache
      warmupVolume: 0,
      volumeByMuscleGroup: {},
      totalSets: data['totalSets'] ?? 0,
      completedSets: data['completedSets'] ?? 0,
      workingSets: 0,
      warmupSets: 0,
      averageWeight: 0,
      averageRPE: (data['averageRPE'] as num?)?.toDouble() ?? 0,
      averageIntensity: 0,
      peakIntensity: 0,
      totalDuration: Duration(minutes: data['totalDurationMinutes'] ?? 0),
      workingTime: Duration.zero,
      restTime: Duration.zero,
      trainingDensity: (data['trainingDensity'] as num?)?.toDouble() ?? 0,
      completionPercentage: (data['completionPercentage'] as num?)?.toDouble() ?? 0,
      exercisesCompleted: 0,
      totalExercises: 0,
    );
  }

  Map<ExerciseCategory, double> _parseVolumeByMuscleGroup(dynamic data) {
    final result = <ExerciseCategory, double>{};
    if (data is Map<String, dynamic>) {
      for (final entry in data.entries) {
        try {
          final category = ExerciseCategory.values.firstWhere(
            (cat) => cat.name == entry.key,
          );
          result[category] = (entry.value as num?)?.toDouble() ?? 0;
        } catch (e) {
          // Skip invalid categories
        }
      }
    }
    return result;
  }
}