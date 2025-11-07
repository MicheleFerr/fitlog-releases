/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data/datasources
/// 🎯 Feature: workout
/// 🔧 Type: datasource
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Hive (local storage)
/// - Data models
/// - Domain entities
library;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';

/// Local Hive data source for workout operations
/// Provides fast, offline-first storage for all users
///
/// ✅ MIGRATED to HiveBoxManagerEnhanced pattern (Oct 2025)
/// - No direct Hive.openBox() calls
/// - Centralized box lifecycle management
/// - Memory leak prevention
class HiveWorkoutDataSource {

  /// Constructor with dependency injection
  ///
  /// Usage:
  /// ```dart
  /// final dataSource = HiveWorkoutDataSource(ref.watch(hiveBoxManagerProvider));
  /// ```
  HiveWorkoutDataSource(this._boxManager);
  final HiveBoxManagerEnhanced _boxManager;

  /// Get workouts box via HiveBoxManagerEnhanced
  Future<Box<Map>> _getWorkoutsBox() async {
    return await _boxManager.openBox<Map>(HiveBoxNames.workouts);
  }

  /// Get summaries box via HiveBoxManagerEnhanced
  Future<Box<Map>> _getSummariesBox() async {
    return await _boxManager.openBox<Map>(HiveBoxNames.workoutSummaries);
  }

  /// Get exercise activities box via HiveBoxManagerEnhanced
  Future<Box<Map>> _getActivitiesBox() async {
    return await _boxManager.openBox<Map>(HiveBoxNames.exerciseActivities);
  }

  /// Get sync queue box via HiveBoxManagerEnhanced
  Future<Box<Map>> _getSyncQueueBox() async {
    return await _boxManager.openBox<Map>(HiveBoxNames.getSyncQueueName('workouts'));
  }

  /// Save workout locally
  Future<String> saveWorkout(WorkoutModel workout, String userId) async {
    final box = await _getWorkoutsBox();
    final key = '${userId}_${workout.id}';

    // Ensure data is properly typed as Map<String, dynamic>
    final Map<String, dynamic> data = workout.toJson();
    data['userId'] = userId;
    data['localLastModified'] = DateTime.now().toIso8601String();
    data['syncStatus'] = 'pending'; // pending, synced, conflict

    // DEBUG: Log first set's isCompleted value before saving
    if (workout.exercises.isNotEmpty && workout.exercises[0].sets.isNotEmpty) {
      final firstSet = workout.exercises[0].sets[0];
      if (kDebugMode) {
        debugPrint('💾 [Hive] Saving workout "${workout.name}" - First set isCompleted: ${firstSet.isCompleted}');
      }
      final exercisesJson = data['exercises'] as List?;
      if (exercisesJson != null && exercisesJson.isNotEmpty) {
        final firstExerciseJson = exercisesJson[0] as Map;
        final setsJson = firstExerciseJson['sets'] as List?;
        if (setsJson != null && setsJson.isNotEmpty) {
          final firstSetJson = setsJson[0] as Map;
          if (kDebugMode) {
            debugPrint('💾 [Hive] First set JSON isCompleted: ${firstSetJson['isCompleted']}');
          }
        }
      }
    }

    // Force conversion to ensure Hive saves as Map<String, dynamic>
    final Map<String, dynamic> dataToSave = Map<String, dynamic>.from(data);
    await box.put(key, dataToSave);

    // Add to sync queue for premium users
    await _addToSyncQueue(key, 'create', userId);

    return workout.id;
  }

  /// Update existing workout locally
  Future<void> updateWorkout(WorkoutModel workout, String userId) async {
    final box = await _getWorkoutsBox();
    final key = '${userId}_${workout.id}';
    
    final data = workout.toJson();
    data['userId'] = userId;
    data['localLastModified'] = DateTime.now().toIso8601String();
    data['syncStatus'] = 'pending';
    
    await box.put(key, data);
    
    // Add to sync queue
    await _addToSyncQueue(key, 'update', userId);
  }

  /// Get single workout by ID
  Future<WorkoutModel?> getWorkout(String workoutId, String userId) async {
    final box = await _getWorkoutsBox();
    final key = '${userId}_$workoutId';
    
    final data = box.get(key);
    if (data == null) return null;
    
    return WorkoutModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Get workouts with filtering
  Future<List<WorkoutModel>> getWorkouts(
    String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final box = await _getWorkoutsBox();
    
    debugPrint('📦 Reading workouts from Hive for user: $userId');
    debugPrint('📦 Total keys in box: ${box.keys.length}');
    
    // Get all workouts for this user
    final userWorkouts = box.keys
        .where((key) => key.toString().startsWith('${userId}_'))
        .map((key) {
          final data = box.get(key);
          if (data == null) return null;
          try {
            // Convert Map<dynamic, dynamic> to Map<String, dynamic>
            final Map<String, dynamic> jsonData;
            if (data is Map<String, dynamic>) {
              jsonData = data;
            } else {
              // Cast keys to String and preserve values
            jsonData = Map<String, dynamic>.from(
              data.map((key, value) => MapEntry(key.toString(), value))
            );
            }
          
            return WorkoutModel.fromJson(jsonData);
          } catch (e) {
            debugPrint('❌ Error parsing workout with key $key: $e');
            return null;
          }
        })
        .where((workout) => workout != null)
        .cast<WorkoutModel>()
        .toList();
    
    debugPrint('📦 Successfully parsed ${userWorkouts.length} workouts for user');
    
    // Apply filters
    var filtered = userWorkouts;
    
    if (startDate != null) {
      filtered = filtered.where((w) => w.createdAt.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      filtered = filtered.where((w) => w.createdAt.isBefore(endDate)).toList();
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Apply limit
    if (limit != null && filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered;
  }

  /// Delete workout locally
  Future<void> deleteWorkout(String workoutId, String userId) async {
    final box = await _getWorkoutsBox();
    final key = '${userId}_$workoutId';
    
    await box.delete(key);
    
    // Add to sync queue
    await _addToSyncQueue(key, 'delete', userId);
  }

  /// Save completed workout as exercise activities (local)
  Future<List<String>> saveCompletedWorkout(
    WorkoutModel workout,
    String userEmail,
  ) async {
    final activitiesBox = await _getActivitiesBox();
    final summariesBox = await _getSummariesBox();
    final activityIds = <String>[];
    
    // Create exercise activities for each completed exercise
    for (final exercise in workout.exercises) {
      final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
      
      if (completedSets.isNotEmpty) {
        final activityId = '${workout.id}_${exercise.id}';
        
        final activityData = {
          'id': activityId,
          'userEmail': userEmail.toLowerCase().trim(),
          'exerciseName': exercise.name,
          'category': exercise.category,
          'type': exercise.type,
          'workoutId': workout.id,
          'workoutName': workout.name,
          'sets': completedSets.map((set) => set.toJson()).toList(),
          'totalVolume': completedSets.fold<double>(
            0.0, 
            (sum, set) => sum + set.volume,
          ),
          'totalSets': completedSets.length,
          'date': (workout.startTime ?? workout.createdAt).toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'localOnly': true,
          'metadata': {
            'duration': workout.endTime != null && workout.startTime != null
                ? workout.endTime!.difference(workout.startTime!).inSeconds
                : null,
            'notes': exercise.notes,
            'restTime': exercise.restTime,
          }
        };
        
        await activitiesBox.put(activityId, activityData);
        activityIds.add(activityId);
      }
    }
    
    // Save workout summary
    final summaryId = 'summary_${workout.id}';
    final summaryData = {
      'id': summaryId,
      'userEmail': userEmail.toLowerCase().trim(),
      'workoutId': workout.id,
      'workoutName': workout.name,
      'totalExercises': workout.exercises.length,
      'completedExercises': workout.exercises.where((e) => e.isCompleted).length,
      'totalSets': workout.exercises.fold(0, (sum, e) => sum + e.sets.length),
      'completedSets': workout.exercises.fold(0, 
        (sum, e) => sum + e.sets.where((s) => s.isCompleted).length),
      'totalVolume': workout.exercises.fold<double>(0.0, 
        (sum, e) => sum + e.totalVolume),
      'duration': workout.endTime != null && workout.startTime != null
          ? workout.endTime!.difference(workout.startTime!).inSeconds
          : null,
      'date': (workout.startTime ?? workout.createdAt).toIso8601String(),
      'status': workout.status,
      'createdAt': DateTime.now().toIso8601String(),
      'localOnly': true,
    };
    
    await summariesBox.put(summaryId, summaryData);
    activityIds.add(summaryId);
    
    return activityIds;
  }

  /// Get workout statistics from local data
  Future<WorkoutStats> getWorkoutStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final workouts = await getWorkouts(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
    
    final completedWorkouts = workouts.where((w) => w.status == 'completed').toList();
    
    // Calculate statistics
    int totalExercises = 0;
    int totalSets = 0;
    Duration totalDuration = Duration.zero;
    final exercisesByCategory = <ExerciseCategory, int>{};
    DateTime? lastWorkoutDate;
    
    for (final workout in completedWorkouts) {
      totalExercises += workout.exercises.length;
      
      for (final exercise in workout.exercises) {
        totalSets += exercise.sets.length;
        
        // Count by category
        final category = ExerciseCategory.values.firstWhere(
          (e) => e.name == exercise.category,
          orElse: () => ExerciseCategory.chest,
        );
        exercisesByCategory[category] = (exercisesByCategory[category] ?? 0) + 1;
      }
      
      // Add duration
      if (workout.startTime != null && workout.endTime != null) {
        totalDuration += workout.endTime!.difference(workout.startTime!);
      }
      
      // Track last workout date
      final workoutDate = workout.startTime ?? workout.createdAt;
      if (lastWorkoutDate == null || workoutDate.isAfter(lastWorkoutDate)) {
        lastWorkoutDate = workoutDate;
      }
    }
    
    final averageWorkoutDuration = completedWorkouts.isNotEmpty 
        ? (totalDuration.inSeconds / completedWorkouts.length).toDouble()
        : 0.0;
    
    return WorkoutStats(
      totalWorkouts: completedWorkouts.length,
      totalExercises: totalExercises,
      totalSets: totalSets,
      totalDuration: totalDuration,
      averageWorkoutDuration: averageWorkoutDuration,
      exercisesByCategory: exercisesByCategory,
      lastWorkoutDate: lastWorkoutDate,
    );
  }

  /// Get active workout from local storage
  Future<WorkoutModel?> getActiveWorkout(String userId) async {
    final workouts = await getWorkouts(userId);
    
    try {
      return workouts.firstWhere((w) => w.status == 'inProgress');
    } catch (_) {
      return null;
    }
  }

  /// Get paginated workout history from local storage
  Future<WorkoutHistory> getWorkoutHistory(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    final allWorkouts = await getWorkouts(userId);
    
    final totalCount = allWorkouts.length;
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    final paginatedWorkouts = allWorkouts.skip(startIndex).take(limit)
        .map((model) => model.toDomain())
        .toList();
    
    final hasMore = endIndex < totalCount;
    
    return WorkoutHistory(
      workouts: paginatedWorkouts,
      totalCount: totalCount,
      hasMore: hasMore,
      currentPage: page,
    );
  }

  /// Add operation to sync queue for later processing
  Future<void> _addToSyncQueue(String key, String operation, String userId) async {
    final box = await _getSyncQueueBox();
    
    final queueItem = {
      'key': key,
      'operation': operation, // create, update, delete
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
      'status': 'pending', // pending, processing, failed, completed
    };
    
    await box.add(queueItem);
  }

  /// Get pending sync items for a user
  Future<List<Map<String, dynamic>>> getPendingSyncItems(String userId) async {
    final box = await _getSyncQueueBox();
    
    return box.values
        .where((item) => item['userId'] == userId && item['status'] == 'pending')
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Mark sync item as completed
  Future<void> markSyncCompleted(int syncQueueIndex) async {
    final box = await _getSyncQueueBox();
    
    final item = box.getAt(syncQueueIndex);
    if (item != null) {
      item['status'] = 'completed';
      item['completedAt'] = DateTime.now().toIso8601String();
      await box.putAt(syncQueueIndex, item);
    }
  }

  /// Clean old sync queue items
  Future<void> cleanSyncQueue() async {
    final box = await _getSyncQueueBox();
    final now = DateTime.now();
    final keysToDelete = <dynamic>[];
    
    for (var i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item != null && item['status'] == 'completed') {
        final completedAt = DateTime.parse(item['completedAt']);
        if (now.difference(completedAt).inDays > 7) {
          keysToDelete.add(box.keyAt(i));
        }
      }
    }
    
    await box.deleteAll(keysToDelete);
  }

  /// Export all local data for backup
  Future<Map<String, dynamic>> exportAllData(String userId) async {
    final workouts = await getWorkouts(userId);
    final activitiesBox = await _getActivitiesBox();
    final summariesBox = await _getSummariesBox();
    
    final activities = activitiesBox.values
        .where((item) => item['userEmail']?.toString().contains(userId) ?? false)
        .toList();
    
    final summaries = summariesBox.values
        .where((item) => item['userEmail']?.toString().contains(userId) ?? false)
        .toList();
    
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'userId': userId,
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'activities': activities,
      'summaries': summaries,
      'version': '1.0.0',
    };
  }

  /// Import data from backup
  Future<void> importData(Map<String, dynamic> data, String userId) async {
    final workoutsBox = await _getWorkoutsBox();
    
    // Import workouts
    if (data['workouts'] != null) {
      for (final workoutData in data['workouts']) {
        final workout = WorkoutModel.fromJson(workoutData);
        final key = '${userId}_${workout.id}';
        await workoutsBox.put(key, workoutData);
      }
    }
    
    // Import activities if present
    if (data['activities'] != null) {
      final activitiesBox = await _getActivitiesBox();
      for (final activity in data['activities']) {
        await activitiesBox.put(activity['id'], activity);
      }
    }
    
    // Import summaries if present
    if (data['summaries'] != null) {
      final summariesBox = await _getSummariesBox();
      for (final summary in data['summaries']) {
        await summariesBox.put(summary['id'], summary);
      }
    }
  }

  /// Get unsynced workouts for premium sync
  Future<List<WorkoutModel>> getUnsyncedWorkouts(String userId) async {
    final box = await _getWorkoutsBox();
    
    final unsyncedWorkouts = box.keys
        .where((key) => key.toString().startsWith('${userId}_'))
        .map((key) => box.get(key))
        .where((data) => data != null && data['syncStatus'] != 'synced')
        .map((data) => WorkoutModel.fromJson(Map<String, dynamic>.from(data!)))
        .toList();
    
    return unsyncedWorkouts;
  }
  
  /// Mark workout as synced
  Future<void> markWorkoutAsSynced(String workoutId, String userId) async {
    final box = await _getWorkoutsBox();
    final key = '${userId}_$workoutId';
    
    final data = box.get(key);
    if (data != null) {
      data['syncStatus'] = 'synced';
      data['cloudLastModified'] = DateTime.now().toIso8601String();
      await box.put(key, data);
    }
  }
  
  /// Clear all local data for a user (for logout/account deletion)
  Future<void> clearUserData(String userId) async {
    final workoutsBox = await _getWorkoutsBox();
    final keysToDelete = workoutsBox.keys
        .where((key) => key.toString().startsWith('${userId}_'))
        .toList();

    await workoutsBox.deleteAll(keysToDelete);

    // Also clear sync queue for this user
    final syncBox = await _getSyncQueueBox();
    final syncKeysToDelete = <dynamic>[];

    for (var i = 0; i < syncBox.length; i++) {
      final item = syncBox.getAt(i);
      if (item != null && item['userId'] == userId) {
        syncKeysToDelete.add(syncBox.keyAt(i));
      }
    }

    await syncBox.deleteAll(syncKeysToDelete);
  }

  /// Get workouts for analytics (domain entities for direct use by analytics repository)
  /// This ensures consistent data access across the application
  Future<List<WorkoutModel>> getWorkoutsForAnalytics(
    String userId, {
    int? limit,
    DateTime? since,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📊 [HiveWorkoutDataSource] Getting workouts for analytics - User: $userId');
      }

      // Use the same method as regular getWorkouts
      final workouts = await getWorkouts(
        userId,
        limit: limit,
        startDate: since,
      );

      if (kDebugMode) {
        debugPrint('✅ [HiveWorkoutDataSource] Retrieved ${workouts.length} workouts for analytics');
      }
      return workouts;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [HiveWorkoutDataSource] Error getting workouts for analytics: $e');
      }
      if (kDebugMode) {
        debugPrint('📍 Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Get last completed workout for user
  ///
  /// Returns the most recent workout with endTime != null (completed).
  /// Returns null if no completed workouts found.
  Future<WorkoutModel?> getLastCompletedWorkout(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 [HiveWorkoutDataSource] getLastCompletedWorkout - userId: $userId');
      }

      // Get all workouts for user
      final allWorkouts = await getWorkouts(userId);

      // Filter completed workouts only (endTime != null)
      final completedWorkouts = allWorkouts
          .where((workout) => workout.endTime != null)
          .toList();

      if (completedWorkouts.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ [HiveWorkoutDataSource] No completed workouts found');
        }
        return null;
      }

      // Sort by startTime descending (most recent first)
      completedWorkouts.sort((a, b) {
        final aTime = a.startTime ?? a.createdAt;
        final bTime = b.startTime ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      final lastWorkout = completedWorkouts.first;

      if (kDebugMode) {
        debugPrint('✅ [HiveWorkoutDataSource] Found last workout: ${lastWorkout.id}');
      }

      return lastWorkout;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HiveWorkoutDataSource] Error: $e');
      }
      throw Exception('Failed to get last completed workout: $e');
    }
  }

  /// ✅ DISPOSAL: No longer needed
  /// HiveBoxManagerEnhanced handles all box lifecycle management via ref.onDispose()
  /// Boxes are automatically closed when:
  /// - App terminates
  /// - User logs out
  /// - ProviderScope is replaced
}