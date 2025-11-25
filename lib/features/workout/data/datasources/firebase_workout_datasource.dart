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
/// - Cloud Firestore
/// - Data models
/// - Domain entities (for method signatures)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';

/// Firebase data source for workout operations
class FirebaseWorkoutDataSource {
  
  const FirebaseWorkoutDataSource(this._firestore);
  final FirebaseFirestore _firestore;

  /// Save workout to Firestore
  Future<String> saveWorkout(WorkoutModel workout, String userId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workout.id);
    
    await docRef.set(workout.toJson());
    
    return docRef.id;
  }

  /// Update existing workout
  Future<void> updateWorkout(WorkoutModel workout, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workout.id)
        .update(workout.toJson());
  }

  /// Get single workout by ID
  Future<WorkoutModel?> getWorkout(String workoutId, String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId)
        .get();

    if (!doc.exists) return null;

    return WorkoutModel.fromJson(doc.data()!);
  }

  /// Get workouts with filtering
  Future<List<WorkoutModel>> getWorkouts(
    String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts');

    // Apply date filtering
    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }
    
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate);
    }

    // Apply ordering and limit
    query = query.orderBy('createdAt', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    final querySnapshot = await query.get();
    
    return querySnapshot.docs
        .map((doc) => WorkoutModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Delete workout
  Future<void> deleteWorkout(String workoutId, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId)
        .delete();
  }

  /// Save completed workout as exercise activities
  Future<List<String>> saveCompletedWorkout(
    WorkoutModel workout,
    String userEmail,
  ) async {
    final batch = _firestore.batch();
    final activityIds = <String>[];

    // Create exercise activities for each completed exercise
    for (final exercise in workout.exercises) {
      final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
      
      if (completedSets.isNotEmpty) {
        final activityRef = _firestore.collection('exerciseActivities').doc();
        
        final activityData = {
          'id': activityRef.id,
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
          'date': workout.startTime ?? workout.createdAt,
          'createdAt': FieldValue.serverTimestamp(),
          'metadata': {
            'duration': workout.endTime != null && workout.startTime != null
                ? workout.endTime!.difference(workout.startTime!).inSeconds
                : null,
            'notes': exercise.notes,
            'restTime': exercise.restTime,
          }
        };

        batch.set(activityRef, activityData);
        activityIds.add(activityRef.id);
      }
    }

    // Also save workout summary
    final summaryRef = _firestore.collection('workoutSummaries').doc();
    final summaryData = {
      'id': summaryRef.id,
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
      'date': workout.startTime ?? workout.createdAt,
      'status': workout.status,
      'createdAt': FieldValue.serverTimestamp(),
    };

    batch.set(summaryRef, summaryData);
    activityIds.add(summaryRef.id);

    await batch.commit();
    return activityIds;
  }

  /// Update specific exercise set
  Future<void> updateExerciseSet(
    String workoutId,
    String exerciseId,
    ExerciseSet exerciseSet,
    String userId,
  ) async {
    final workoutRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId);

    // Get current workout
    final workoutDoc = await workoutRef.get();
    if (!workoutDoc.exists) {
      throw Exception('Workout not found');
    }

    final workoutData = workoutDoc.data()!;
    final exercises = List<Map<String, dynamic>>.from(workoutData['exercises']);

    // Find and update the specific exercise set
    bool updated = false;
    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i]['id'] == exerciseId) {
        final sets = List<Map<String, dynamic>>.from(exercises[i]['sets']);
        
        for (int j = 0; j < sets.length; j++) {
          if (sets[j]['id'] == exerciseSet.id) {
            sets[j] = ExerciseSetModel.fromDomain(exerciseSet).toJson();
            updated = true;
            break;
          }
        }
        
        if (updated) {
          exercises[i]['sets'] = sets;
          // Recalculate exercise total volume
          final completedSets = sets.where((set) => set['isCompleted'] == true);
          exercises[i]['totalVolume'] = completedSets.fold<double>(
            0.0, 
            (sum, set) => sum + (set['volume'] as num).toDouble(),
          );
          break;
        }
      }
    }

    if (!updated) {
      throw Exception('Exercise set not found');
    }

    // Update the workout with modified exercises
    await workoutRef.update({
      'exercises': exercises,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add exercise to existing workout
  Future<void> addExerciseToWorkout(
    String workoutId,
    Exercise exercise,
    String userId,
  ) async {
    final workoutRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId);

    final exerciseModel = ExerciseModel.fromDomain(exercise);

    await workoutRef.update({
      'exercises': FieldValue.arrayUnion([exerciseModel.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove exercise from workout
  Future<void> removeExerciseFromWorkout(
    String workoutId,
    String exerciseId,
    String userId,
  ) async {
    final workoutRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId);

    // Get current workout to find the exercise to remove
    final workoutDoc = await workoutRef.get();
    if (!workoutDoc.exists) {
      throw Exception('Workout not found');
    }

    final workoutData = workoutDoc.data()!;
    final exercises = List<Map<String, dynamic>>.from(workoutData['exercises']);

    // Remove the exercise with matching ID
    exercises.removeWhere((exercise) => exercise['id'] == exerciseId);

    // Update the workout
    await workoutRef.update({
      'exercises': exercises,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get workout statistics
  Future<WorkoutStats> getWorkoutStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .where('status', isEqualTo: 'completed');

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }
    
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate);
    }

    final querySnapshot = await query.get();
    final workouts = querySnapshot.docs
        .map((doc) => WorkoutModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Calculate statistics
    int totalExercises = 0;
    int totalSets = 0;
    Duration totalDuration = Duration.zero;
    final exercisesByCategory = <ExerciseCategory, int>{};
    DateTime? lastWorkoutDate;

    for (final workout in workouts) {
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

    final averageWorkoutDuration = workouts.isNotEmpty 
        ? (totalDuration.inSeconds / workouts.length).toDouble()
        : 0.0;

    return WorkoutStats(
      totalWorkouts: workouts.length,
      totalExercises: totalExercises,
      totalSets: totalSets,
      totalDuration: totalDuration,
      averageWorkoutDuration: averageWorkoutDuration,
      exercisesByCategory: exercisesByCategory,
      lastWorkoutDate: lastWorkoutDate,
    );
  }

  /// Watch active workout in real-time
  Stream<WorkoutModel?> watchActiveWorkout(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .where('status', isEqualTo: 'inProgress')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return WorkoutModel.fromJson(snapshot.docs.first.data());
        });
  }

  /// Get paginated workout history
  Future<WorkoutHistory> getWorkoutHistory(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    // Get total count first
    final totalQuery = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .count()
        .get();

    final totalCount = totalQuery.count ?? 0;

    // Get paginated results
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    // Skip for pagination
    if (page > 1) {
      final skipCount = (page - 1) * limit;
      final offsetSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('createdAt', descending: true)
          .limit(skipCount)
          .get();

      if (offsetSnapshot.docs.isNotEmpty) {
        query = query.startAfterDocument(offsetSnapshot.docs.last);
      }
    }

    final querySnapshot = await query.get();
    final workouts = querySnapshot.docs
        .map((doc) => WorkoutModel.fromJson(doc.data() as Map<String, dynamic>))
        .map((model) => model.toDomain())
        .toList();

    final hasMore = (page * limit) < totalCount;

    return WorkoutHistory(
      workouts: workouts,
      totalCount: totalCount,
      hasMore: hasMore,
      currentPage: page,
    );
  }

  /// Get workouts with cursor-based pagination (Firestore optimized)
  ///
  /// Uses startAfterDocument for efficient pagination.
  /// This method fetches pageSize + 1 to determine hasMore without extra count query.
  ///
  /// **Firestore Best Practice 2024**:
  /// - Uses startAfterDocument (cursor-based) instead of offset
  /// - Fetches N+1 to detect hasMore without count query (cost-efficient)
  /// - Returns DocumentSnapshot for next page cursor
  ///
  /// **Required Composite Index**:
  /// Collection: users/{userId}/workouts
  /// Fields: status ASC, createdAt DESC (if status filter used)
  /// Or: createdAt DESC (if no status filter)
  Future<PaginatedResult<WorkoutModel>> getWorkoutsPaginated(
    String userId, {
    int pageSize = 20,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  }) async {
    // Build base query - order by createdAt descending (newest first)
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('createdAt', descending: true);

    // Apply status filter if provided
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    // Apply date range filters
    // NOTE: Firestore allows only one inequality filter per query
    // Using createdAt >= dateFrom OR createdAt <= dateTo
    if (dateFrom != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateFrom));
    }

    if (dateTo != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(dateTo));
    }

    // Apply cursor if continuing from previous page
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    // Fetch pageSize + 1 to determine if more pages exist
    // This is more efficient than a separate count query
    query = query.limit(pageSize + 1);

    final querySnapshot = await query.get();
    final docs = querySnapshot.docs;

    // Determine if there are more pages
    final hasMore = docs.length > pageSize;

    // Take only pageSize items (exclude the extra one used for hasMore check)
    final resultDocs = hasMore ? docs.sublist(0, pageSize) : docs;

    // Get the last document for cursor (before trimming)
    final lastDoc = resultDocs.isNotEmpty ? resultDocs.last : null;

    // Convert to domain models
    final workouts = resultDocs
        .map((doc) => WorkoutModel.fromJson(doc.data()))
        .toList();

    return PaginatedResult<WorkoutModel>(
      items: workouts,
      hasMore: hasMore,
      lastDocument: lastDoc,
    );
  }
}