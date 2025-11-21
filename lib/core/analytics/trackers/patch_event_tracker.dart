/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/analytics/trackers
/// 🎯 Feature: analytics
/// 🔧 Type: tracker helper
///
/// Exercise patch tracking helper
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/patch_conflict_detector.dart';

/// Patch event tracker
///
/// Helper class for tracking exercise patch events (submissions, reviews, conflicts).
/// Provides convenient methods with predefined event names and parameters.
///
/// Usage:
/// ```dart
/// final tracker = PatchEventTracker(analytics);
///
/// // Track patch submission
/// await tracker.trackPatchSubmitted(
///   patchId: 'patch_123',
///   exerciseId: 'ex_456',
///   fieldName: 'nome',
///   source: 'exercise_detail_screen',
/// );
///
/// // Track admin approval
/// await tracker.trackPatchApproved(
///   patchId: 'patch_123',
///   adminNote: 'Good correction',
/// );
/// ```
class PatchEventTracker {
  PatchEventTracker(this.analytics);

  final IAnalyticsService analytics;

  /// Track patch submission by user
  ///
  /// Logs when a user submits an exercise correction patch
  ///
  /// Parameters:
  /// - [patchId] - Generated patch ID
  /// - [exerciseId] - Exercise being corrected
  /// - [exerciseName] - Exercise name
  /// - [fieldName] - Field being corrected (nome, noteTecniche, etc.)
  /// - [source] - Where submission occurred (screen name)
  Future<void> trackPatchSubmitted({
    required String patchId,
    required String exerciseId,
    required String exerciseName,
    required String fieldName,
    required String source,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.patchSubmitted,
        parameters: {
          AnalyticsParameters.patchId: patchId,
          AnalyticsParameters.patchExerciseId: exerciseId,
          AnalyticsParameters.patchExerciseName: exerciseName,
          AnalyticsParameters.patchFieldName: fieldName,
          AnalyticsParameters.source: source,
          AnalyticsParameters.submissionTime: DateTime.now().millisecondsSinceEpoch,
          AnalyticsParameters.success: true,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Patch submitted: $patchId for $exerciseName ($fieldName) from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking patch submission: $e');
      }
    }
  }

  /// Track patch submission failure
  ///
  /// Logs when patch submission fails (validation, duplicate, network error)
  ///
  /// Parameters:
  /// - [exerciseId] - Exercise being corrected
  /// - [fieldName] - Field being corrected
  /// - [errorMessage] - Error description
  /// - [errorType] - Error type (validation, duplicate, network)
  /// - [source] - Where submission occurred
  Future<void> trackPatchSubmissionFailed({
    required String exerciseId,
    required String fieldName,
    required String errorMessage,
    required String errorType,
    required String source,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.patchSubmissionFailed,
        parameters: {
          AnalyticsParameters.patchExerciseId: exerciseId,
          AnalyticsParameters.patchFieldName: fieldName,
          AnalyticsParameters.errorMessage: errorMessage,
          AnalyticsParameters.errorType: errorType,
          AnalyticsParameters.source: source,
          AnalyticsParameters.success: false,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Patch submission failed: $errorType - $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking patch submission failure: $e');
      }
    }
  }

  /// Track patch approval by admin
  ///
  /// Logs when admin approves an exercise correction patch
  ///
  /// Parameters:
  /// - [patchId] - Approved patch ID
  /// - [exerciseId] - Exercise being corrected
  /// - [fieldName] - Field being corrected
  /// - [adminNote] - Optional admin note
  /// - [source] - Where approval occurred
  Future<void> trackPatchApproved({
    required String patchId,
    required String exerciseId,
    required String fieldName,
    String? adminNote,
    String source = 'patch_review_screen',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.patchApproved,
        parameters: {
          AnalyticsParameters.patchId: patchId,
          AnalyticsParameters.patchExerciseId: exerciseId,
          AnalyticsParameters.patchFieldName: fieldName,
          AnalyticsParameters.patchStatus: 'approved',
          if (adminNote != null) AnalyticsParameters.adminNote: adminNote,
          AnalyticsParameters.source: source,
          AnalyticsParameters.reviewTime: DateTime.now().millisecondsSinceEpoch,
          AnalyticsParameters.action: 'approve',
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Patch approved: $patchId ($fieldName) from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking patch approval: $e');
      }
    }
  }

  /// Track patch rejection by admin
  ///
  /// Logs when admin rejects an exercise correction patch
  ///
  /// Parameters:
  /// - [patchId] - Rejected patch ID
  /// - [exerciseId] - Exercise being corrected
  /// - [fieldName] - Field being corrected
  /// - [adminNote] - Rejection reason
  /// - [source] - Where rejection occurred
  Future<void> trackPatchRejected({
    required String patchId,
    required String exerciseId,
    required String fieldName,
    required String adminNote,
    String source = 'patch_review_screen',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.patchRejected,
        parameters: {
          AnalyticsParameters.patchId: patchId,
          AnalyticsParameters.patchExerciseId: exerciseId,
          AnalyticsParameters.patchFieldName: fieldName,
          AnalyticsParameters.patchStatus: 'rejected',
          AnalyticsParameters.adminNote: adminNote,
          AnalyticsParameters.source: source,
          AnalyticsParameters.reviewTime: DateTime.now().millisecondsSinceEpoch,
          AnalyticsParameters.action: 'reject',
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Patch rejected: $patchId ($fieldName) from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking patch rejection: $e');
      }
    }
  }

  /// Track user viewing their submitted patches
  ///
  /// Logs when user opens their patch history/status screen
  ///
  /// Parameters:
  /// - [patchCount] - Number of patches user has
  /// - [source] - Where view was triggered
  Future<void> trackMyPatchesViewed({
    required int patchCount,
    String source = 'community_pulse_card',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.myPatchesViewed,
        parameters: {
          'patch_count': patchCount,
          AnalyticsParameters.source: source,
          AnalyticsParameters.screenName: 'my_patches_screen',
        },
      );

      if (kDebugMode) {
        debugPrint('📊 My patches viewed: $patchCount patches from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking my patches view: $e');
      }
    }
  }

  /// Track admin opening patch review queue
  ///
  /// Logs when admin opens patch review screen
  ///
  /// Parameters:
  /// - [pendingCount] - Number of pending patches
  /// - [source] - Where review was opened from
  Future<void> trackPatchReviewOpened({
    required int pendingCount,
    String source = 'admin_panel',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.patchReviewOpened,
        parameters: {
          'pending_count': pendingCount,
          AnalyticsParameters.source: source,
          AnalyticsParameters.screenName: 'patch_review_screen',
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Patch review opened: $pendingCount pending patches from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking patch review open: $e');
      }
    }
  }

  /// Track patch conflict detected
  ///
  /// Logs when conflict detection finds issues with a patch
  ///
  /// Parameters:
  /// - [patchId] - Patch with conflicts
  /// - [conflictTypes] - List of conflict types detected
  /// - [highestSeverity] - Highest severity level
  /// - [source] - Where conflict was detected
  Future<void> trackPatchConflictDetected({
    required String patchId,
    required List<ConflictType> conflictTypes,
    required ConflictSeverity highestSeverity,
    String source = 'patch_review_screen',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.patchConflictDetected,
        parameters: {
          AnalyticsParameters.patchId: patchId,
          'conflict_count': conflictTypes.length,
          AnalyticsParameters.conflictType: conflictTypes.map((t) => t.name).join(','),
          AnalyticsParameters.conflictSeverity: highestSeverity.name,
          AnalyticsParameters.source: source,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Patch conflict detected: $patchId - ${conflictTypes.length} conflicts (${highestSeverity.name}) from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking patch conflict: $e');
      }
    }
  }

  /// Track duplicate patch submission blocked
  ///
  /// Logs when user tries to submit duplicate patch
  ///
  /// Parameters:
  /// - [exerciseId] - Exercise being corrected
  /// - [fieldName] - Field being corrected
  /// - [existingPatchId] - ID of existing patch
  /// - [source] - Where duplicate was blocked
  Future<void> trackDuplicatePatchBlocked({
    required String exerciseId,
    required String fieldName,
    required String existingPatchId,
    String source = 'patch_submission_dialog',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.duplicatePatchBlocked,
        parameters: {
          AnalyticsParameters.patchExerciseId: exerciseId,
          AnalyticsParameters.patchFieldName: fieldName,
          'existing_patch_id': existingPatchId,
          AnalyticsParameters.source: source,
          AnalyticsParameters.errorType: 'duplicate',
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Duplicate patch blocked: $exerciseId.$fieldName (existing: $existingPatchId) from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking duplicate patch block: $e');
      }
    }
  }

  /// Track patch performance metric
  ///
  /// Logs performance trace for patch operations
  ///
  /// Parameters:
  /// - [traceId] - Firebase Performance trace ID
  /// - [operation] - Operation name (submit, review, analyze_conflicts)
  /// - [durationMs] - Operation duration in milliseconds
  Future<void> trackPatchPerformance({
    required String traceId,
    required String operation,
    required int durationMs,
  }) async {
    try {
      await analytics.logEvent(
        name: 'patch_performance',
        parameters: {
          'trace_id': traceId,
          'operation': operation,
          'duration_ms': durationMs,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Patch performance: $operation took ${durationMs}ms');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking patch performance: $e');
      }
    }
  }
}
