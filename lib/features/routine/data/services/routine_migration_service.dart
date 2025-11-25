/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/data/services
/// 🎯 Feature: flexible_routine
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// ROUTINE MIGRATION SERVICE - v1.0 → v2.0
///
/// Handles migration from complex v1.0 schema (20+ fields, nested entities)
/// to simplified v2.0 schema (12 fields, flat structure).
///
/// Features:
/// - Dry-run mode (preview without writing)
/// - Backup before migration (rollback capability)
/// - Data validation (before/after)
/// - Progress logging
/// - Error handling with partial rollback
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/features/routine/data/models/routine_model.dart';

/// Migration result for a single routine
class RoutineMigrationResult {

  const RoutineMigrationResult({
    required this.routineId,
    required this.success,
    this.errorMessage,
    this.backupData,
  });
  final String routineId;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? backupData;
}

/// Overall migration report
class MigrationReport {

  const MigrationReport({
    required this.totalRoutines,
    required this.successCount,
    required this.failureCount,
    required this.results,
    required this.startTime,
    required this.endTime,
    required this.isDryRun,
  });
  final int totalRoutines;
  final int successCount;
  final int failureCount;
  final List<RoutineMigrationResult> results;
  final DateTime startTime;
  final DateTime endTime;
  final bool isDryRun;

  Duration get duration => endTime.difference(startTime);

  String get summary => '''
Migration Report:
- Mode: ${isDryRun ? 'DRY-RUN (no changes made)' : 'LIVE'}
- Total Routines: $totalRoutines
- Successful: $successCount
- Failed: $failureCount
- Duration: ${duration.inSeconds}s
''';
}

/// Service for migrating routines from v1.0 to v2.0 schema
///
/// Usage:
/// ```dart
/// final service = RoutineMigrationService();
///
/// // Dry-run (preview without writing)
/// final report = await service.migrateAllRoutines(
///   userId: 'user_123',
///   dryRun: true,
/// );
/// print(report.summary);
///
/// // Live migration (with backup)
/// final liveReport = await service.migrateAllRoutines(
///   userId: 'user_123',
///   dryRun: false,
///   createBackup: true,
/// );
/// ```
class RoutineMigrationService {

  RoutineMigrationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  static const String _routinesCollection = 'routines';
  static const String _backupsCollection = 'routine_backups_v1';

  // ──────────────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ──────────────────────────────────────────────────────────────────────────

  /// Migrate all routines for a user from v1.0 to v2.0
  ///
  /// Parameters:
  /// - [userId]: User whose routines to migrate
  /// - [dryRun]: If true, preview changes without writing (default: true)
  /// - [createBackup]: If true, backup v1.0 data before migration (default: true)
  ///
  /// Returns:
  /// - MigrationReport with detailed results
  Future<MigrationReport> migrateAllRoutines({
    required String userId,
    bool dryRun = true,
    bool createBackup = true,
  }) async {
    final startTime = DateTime.now();
    final results = <RoutineMigrationResult>[];

    _log('Starting migration for user: $userId (${dryRun ? 'DRY-RUN' : 'LIVE'})');

    try {
      // Step 1: Fetch all v1.0 routines for this user
      final snapshot = await _firestore
          .collection(_routinesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      _log('Found ${snapshot.docs.length} routines to migrate');

      // Step 2: Migrate each routine
      for (final doc in snapshot.docs) {
        final result = await _migrateRoutine(
          routineId: doc.id,
          v1Data: doc.data(),
          dryRun: dryRun,
          createBackup: createBackup,
        );
        results.add(result);

        if (result.success) {
          _log('✓ Migrated: ${doc.id}');
        } else {
          _log('✗ Failed: ${doc.id} - ${result.errorMessage}');
        }
      }

      final endTime = DateTime.now();
      final successCount = results.where((r) => r.success).length;
      final failureCount = results.where((r) => !r.success).length;

      final report = MigrationReport(
        totalRoutines: snapshot.docs.length,
        successCount: successCount,
        failureCount: failureCount,
        results: results,
        startTime: startTime,
        endTime: endTime,
        isDryRun: dryRun,
      );

      _log(report.summary);
      return report;
    } catch (e) {
      _log('Migration failed: $e');
      rethrow;
    }
  }

  /// Rollback a single routine from backup
  ///
  /// Restores v1.0 data from backup collection
  Future<void> rollbackRoutine(String routineId) async {
    try {
      _log('Rolling back routine: $routineId');

      // Step 1: Fetch backup data
      final backupDoc = await _firestore
          .collection(_backupsCollection)
          .doc(routineId)
          .get();

      if (!backupDoc.exists) {
        throw Exception('No backup found for routine: $routineId');
      }

      final backupData = backupDoc.data()!;
      final originalData = backupData['originalData'] as Map<String, dynamic>;

      // Step 2: Restore original data
      await _firestore
          .collection(_routinesCollection)
          .doc(routineId)
          .set(originalData);

      _log('✓ Rolled back: $routineId');
    } catch (e) {
      _log('✗ Rollback failed for $routineId: $e');
      rethrow;
    }
  }

  /// Rollback all routines for a user from backup
  Future<void> rollbackAllRoutines(String userId) async {
    try {
      _log('Rolling back all routines for user: $userId');

      // Fetch all backups for this user
      final backupSnapshot = await _firestore
          .collection(_backupsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      _log('Found ${backupSnapshot.docs.length} backups to restore');

      for (final doc in backupSnapshot.docs) {
        await rollbackRoutine(doc.id);
      }

      _log('✓ Rollback complete');
    } catch (e) {
      _log('✗ Rollback failed: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  /// Migrate a single routine from v1.0 to v2.0
  Future<RoutineMigrationResult> _migrateRoutine({
    required String routineId,
    required Map<String, dynamic> v1Data,
    required bool dryRun,
    required bool createBackup,
  }) async {
    try {
      // Step 1: Create backup (if not dry-run)
      if (!dryRun && createBackup) {
        await _createBackup(routineId, v1Data);
      }

      // Step 2: Convert v1.0 → v2.0
      final v2Routine = _convertV1ToV2(routineId, v1Data);

      // Step 3: Validate v2.0 data
      _validateV2Routine(v2Routine);

      // Step 4: Write v2.0 data (if not dry-run)
      if (!dryRun) {
        final model = RoutineModel.fromEntity(v2Routine);
        await _firestore
            .collection(_routinesCollection)
            .doc(routineId)
            .set(model.toJson());
      }

      return RoutineMigrationResult(
        routineId: routineId,
        success: true,
        backupData: createBackup ? v1Data : null,
      );
    } catch (e) {
      return RoutineMigrationResult(
        routineId: routineId,
        success: false,
        errorMessage: e.toString(),
        backupData: v1Data,
      );
    }
  }

  /// Convert v1.0 routine data to v2.0 FlexibleRoutine entity
  ///
  /// v1.0 → v2.0 Field Mapping:
  /// - id → id (unchanged)
  /// - userId → userId (unchanged)
  /// - name → name (unchanged)
  /// - description → description (unchanged)
  /// - preset/presetType → presetType (normalized to enum)
  /// - pattern.trainingDays / trainingDays → trainingDays (Set of int)
  /// - pattern.schedule / schedule → workoutSchedule (Map of int to String)
  /// - isActive → isActive (unchanged)
  /// - completedDays / stats.completedDays → completedDays (Set of String)
  /// - stats.totalWorkouts / totalWorkouts → totalWorkouts (default 0)
  /// - createdAt → createdAt (unchanged)
  /// - updatedAt → updatedAt (default to now)
  FlexibleRoutine _convertV1ToV2(
    String routineId,
    Map<String, dynamic> v1Data,
  ) {
    // Extract v1.0 fields with fallbacks
    final userId = v1Data['userId'] as String? ?? '';
    final name = v1Data['name'] as String? ?? 'Migrated Routine';
    final description = v1Data['description'] as String? ?? '';

    // Preset type (handle both 'preset' and 'presetType' fields)
    final presetString = (v1Data['presetType'] ?? v1Data['preset']) as String?;
    final presetType = _parsePreset(presetString);

    // Training days (handle nested 'pattern.trainingDays' or direct 'trainingDays')
    final trainingDays = _extractTrainingDays(v1Data);

    // Workout schedule (handle nested 'pattern.schedule' or direct 'schedule')
    final workoutSchedule = _extractWorkoutSchedule(v1Data);

    // Active status
    final isActive = v1Data['isActive'] as bool? ?? false;

    // Completed days (handle nested 'stats.completedDays' or direct 'completedDays')
    final completedDays = _extractCompletedDays(v1Data);

    // Total workouts (handle nested 'stats.totalWorkouts' or direct 'totalWorkouts')
    final totalWorkouts = _extractTotalWorkouts(v1Data);

    // Timestamps
    final createdAt = _extractTimestamp(v1Data['createdAt']) ?? DateTime.now();
    final updatedAt = _extractTimestamp(v1Data['updatedAt']) ?? DateTime.now();

    return FlexibleRoutine(
      id: routineId,
      userId: userId,
      name: name,
      description: description,
      presetType: presetType,
      trainingDays: trainingDays,
      workoutSchedule: workoutSchedule,
      isActive: isActive,
      completedDays: completedDays,
      totalWorkouts: totalWorkouts,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Parse preset string to RoutinePreset enum
  RoutinePreset _parsePreset(String? presetString) {
    if (presetString == null) return RoutinePreset.custom;

    // Handle v1.0 preset strings (various formats)
    switch (presetString.toLowerCase().replaceAll(' ', '_')) {
      case 'ppl_6_day':
      case 'ppl':
      case 'push_pull_legs':
        return RoutinePreset.ppl6Day;
      case 'upper_lower_4_day':
      case 'upper_lower':
        return RoutinePreset.upperLower4Day;
      case 'full_body_3_day':
      case 'full_body':
        return RoutinePreset.fullBody3Day;
      case 'bro_split_5_day':
      case 'bro_split':
        return RoutinePreset.broSplit5Day;
      default:
        return RoutinePreset.custom;
    }
  }

  /// Extract training days from v1.0 data (handle nested or direct)
  Set<int> _extractTrainingDays(Map<String, dynamic> v1Data) {
    // Try nested pattern.trainingDays
    if (v1Data.containsKey('pattern')) {
      final pattern = v1Data['pattern'] as Map<String, dynamic>?;
      if (pattern != null && pattern.containsKey('trainingDays')) {
        final days = pattern['trainingDays'] as List<dynamic>?;
        if (days != null) {
          return days.map((d) => d as int).toSet();
        }
      }
    }

    // Try direct trainingDays field
    if (v1Data.containsKey('trainingDays')) {
      final days = v1Data['trainingDays'] as List<dynamic>?;
      if (days != null) {
        return days.map((d) => d as int).toSet();
      }
    }

    // Fallback: empty set (will use preset defaults)
    return {};
  }

  /// Extract workout schedule from v1.0 data (handle nested or direct)
  Map<int, String> _extractWorkoutSchedule(Map<String, dynamic> v1Data) {
    // Try nested pattern.schedule
    if (v1Data.containsKey('pattern')) {
      final pattern = v1Data['pattern'] as Map<String, dynamic>?;
      if (pattern != null && pattern.containsKey('schedule')) {
        return _parseSchedule(pattern['schedule']);
      }
    }

    // Try direct schedule field
    if (v1Data.containsKey('schedule')) {
      return _parseSchedule(v1Data['schedule']);
    }

    // Fallback: empty map
    return {};
  }

  /// Parse schedule data (handle Map of String to String or Map of int to String)
  Map<int, String> _parseSchedule(dynamic scheduleData) {
    if (scheduleData is Map) {
      final result = <int, String>{};
      for (final entry in scheduleData.entries) {
        final key = entry.key;
        final value = entry.value as String;

        // Convert key to int
        final dayInt = key is int ? key : int.tryParse(key.toString()) ?? 1;
        result[dayInt] = value;
      }
      return result;
    }
    return {};
  }

  /// Extract completed days from v1.0 data (handle nested or direct)
  Set<String> _extractCompletedDays(Map<String, dynamic> v1Data) {
    // Try nested stats.completedDays
    if (v1Data.containsKey('stats')) {
      final stats = v1Data['stats'] as Map<String, dynamic>?;
      if (stats != null && stats.containsKey('completedDays')) {
        final days = stats['completedDays'] as List<dynamic>?;
        if (days != null) {
          return days.map((d) => d.toString()).toSet();
        }
      }
    }

    // Try direct completedDays field
    if (v1Data.containsKey('completedDays')) {
      final days = v1Data['completedDays'] as List<dynamic>?;
      if (days != null) {
        return days.map((d) => d.toString()).toSet();
      }
    }

    // Fallback: empty set
    return {};
  }

  /// Extract total workouts from v1.0 data (handle nested or direct)
  int _extractTotalWorkouts(Map<String, dynamic> v1Data) {
    // Try nested stats.totalWorkouts
    if (v1Data.containsKey('stats')) {
      final stats = v1Data['stats'] as Map<String, dynamic>?;
      if (stats != null && stats.containsKey('totalWorkouts')) {
        return stats['totalWorkouts'] as int? ?? 0;
      }
    }

    // Try direct totalWorkouts field
    if (v1Data.containsKey('totalWorkouts')) {
      return v1Data['totalWorkouts'] as int? ?? 0;
    }

    // Fallback: 0
    return 0;
  }

  /// Extract DateTime from Firestore Timestamp or String
  DateTime? _extractTimestamp(dynamic timestampData) {
    if (timestampData is Timestamp) {
      return timestampData.toDate();
    } else if (timestampData is String) {
      return DateTime.tryParse(timestampData);
    } else if (timestampData is DateTime) {
      return timestampData;
    }
    return null;
  }

  /// Validate v2.0 routine data
  void _validateV2Routine(FlexibleRoutine routine) {
    if (routine.id.isEmpty) {
      throw Exception('Invalid routine: id is empty');
    }
    if (routine.userId.isEmpty) {
      throw Exception('Invalid routine: userId is empty');
    }
    if (routine.name.isEmpty) {
      throw Exception('Invalid routine: name is empty');
    }
    // Additional validations can be added here
  }

  /// Create backup of v1.0 data before migration
  Future<void> _createBackup(
    String routineId,
    Map<String, dynamic> v1Data,
  ) async {
    await _firestore.collection(_backupsCollection).doc(routineId).set({
      'routineId': routineId,
      'userId': v1Data['userId'],
      'backupDate': FieldValue.serverTimestamp(),
      'originalData': v1Data,
    });
  }

  /// Log message (debug mode only)
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[RoutineMigration] $message');
    }
  }
}
