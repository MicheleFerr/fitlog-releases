import 'dart:async';

import 'package:gymbro_flutter_new/features/timer/domain/entities/set_execution_timing.dart';

/// Abstract repository for TIER-1 set timing data with production-grade requirements
abstract class SetTimingRepository {
  // CRUD Operations with millisecond precision
  Future<void> saveSetTiming(SetExecutionTiming timing);
  Future<SetExecutionTiming?> getSetTiming(String id);
  Future<List<SetExecutionTiming>> getSetTimingsForWorkout(String workoutId);
  Future<List<SetExecutionTiming>> getSetTimingsForExercise(String exerciseId);
  Future<void> deleteSetTiming(String id);
  Future<void> bulkSaveSetTimings(List<SetExecutionTiming> timings);
  
  // Analytics queries
  Future<List<SetExecutionTiming>> getTimingsInDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  Future<List<SetExecutionTiming>> getPersonalBestTimings(
    String exerciseId,
    int limit,
  );
  
  Future<Map<String, double>> getAverageTimingsPerExercise();
  
  // Real-time streaming
  Stream<SetExecutionTiming> watchSetTiming(String id);
  Stream<List<SetExecutionTiming>> watchWorkoutTimings(String workoutId);
  
  // Sync operations
  Future<void> syncWithFirebase();
  Future<List<SetExecutionTiming>> getUnsyncedTimings();
  Future<void> markAsSynced(List<String> timingIds);
  
  // Backup & Recovery
  Future<void> exportTimingsToJson(String filePath);
  Future<void> importTimingsFromJson(String filePath);
  
  // Performance monitoring
  Future<void> cleanupOldTimings(Duration olderThan);
  Future<int> getStorageSize();
  Future<void> optimizeStorage();
}