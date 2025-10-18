/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/data/repositories
/// 🎯 Feature: admin
/// 🔧 Type: repository
///
/// Repository contract per l'accesso ai dati di feedback
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Modello per un singolo feedback su esercizio
class ExerciseFeedback {
  final String id;
  final String userId;
  final String userEmail;
  final String exerciseId;
  final String exerciseName;
  final String version;
  final String feedbackType; // BUG, SUGGESTION, TYPO, OTHER
  final String message;
  final int severity; // 1-5
  final DateTime createdAt;
  final String status; // OPEN, REVIEWING, RESOLVED, DISMISSED
  final String? adminNotes;

  ExerciseFeedback({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.exerciseId,
    required this.exerciseName,
    required this.version,
    required this.feedbackType,
    required this.message,
    required this.severity,
    required this.createdAt,
    required this.status,
    this.adminNotes,
  });

  /// Factory constructor from Firestore document
  factory ExerciseFeedback.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExerciseFeedback(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      exerciseId: data['exerciseId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      version: data['version'] ?? '0.1.0',
      feedbackType: data['feedbackType'] ?? 'OTHER',
      message: data['message'] ?? '',
      severity: data['severity'] ?? 2,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'OPEN',
      adminNotes: data['adminNotes'],
    );
  }

  /// Convert to Firestore document map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'version': version,
      'feedbackType': feedbackType,
      'message': message,
      'severity': severity,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'adminNotes': adminNotes,
    };
  }

  /// Create a copy with optional field modifications
  ExerciseFeedback copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? exerciseId,
    String? exerciseName,
    String? version,
    String? feedbackType,
    String? message,
    int? severity,
    DateTime? createdAt,
    String? status,
    String? adminNotes,
  }) {
    return ExerciseFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      version: version ?? this.version,
      feedbackType: feedbackType ?? this.feedbackType,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}

/// 🏗️ Repository Contract: defines all data access operations
abstract class FeedbackRepository {
  /// Stream of ALL feedback (used as master stream for all filters)
  /// 🎯 Single source of truth for all feedback data
  /// 🔒 Ordered by createdAt descending for consistency
  Stream<List<ExerciseFeedback>> watchAllFeedback();

  /// Stream of feedback by exercise ID
  /// 💡 Can be optimized: filter from allFeedback or query
  Stream<List<ExerciseFeedback>> watchFeedbackByExercise(String exerciseId);

  /// Stream of feedback by status
  /// 💡 Can be optimized: filter from allFeedback or query
  Stream<List<ExerciseFeedback>> watchFeedbackByStatus(String status);

  /// Stream of critical feedback (severity >= 4, status = OPEN)
  /// 🎯 Used for admin dashboard critical issues section
  Stream<List<ExerciseFeedback>> watchCriticalFeedback();

  /// Get single feedback by ID (one-time read)
  /// 🔒 Prefer this for detail views instead of stream
  Future<ExerciseFeedback?> getFeedbackById(String feedbackId);

  /// Create new feedback
  /// 🔒 Server validates ownership (userId must match auth.uid)
  Future<String> createFeedback(ExerciseFeedback feedback);

  /// Update feedback status (admin only)
  /// 🔒 Server validates admin role
  /// ✅ Only status field can be updated
  Future<void> updateFeedbackStatus(String feedbackId, String newStatus);

  /// Update admin notes (admin only)
  /// 🔒 Server validates admin role
  Future<void> updateAdminNotes(String feedbackId, String notes);

  /// Update feedback severity (admin only)
  /// 🔒 Server validates admin role and value (1-5)
  Future<void> updateFeedbackSeverity(String feedbackId, int severity);

  /// Batch update multiple feedback items
  /// 💪 More efficient than individual updates
  /// 🔒 Server validates admin role for each update
  Future<void> batchUpdateFeedback(
    List<String> feedbackIds,
    Map<String, dynamic> updates,
  );

  /// Delete feedback (admin only)
  /// 🔒 Server validates admin role
  /// ⚠️ Use sparingly - consider marking as DISMISSED instead
  Future<void> deleteFeedback(String feedbackId);

  /// Count total feedback
  Future<int> countTotalFeedback();

  /// Count feedback by status
  Future<Map<String, int>> countByStatus();

  /// Count feedback by type
  Future<Map<String, int>> countByType();

  /// Count feedback by severity
  Future<Map<String, int>> countBySeverity();
}

/// ✅ Implementation using Firestore
/// 🔐 Inherits security from Firestore rules
/// 💾 Single Firebase instance for efficiency
class FirestoreFeedbackRepository implements FeedbackRepository {
  static const String _collection = 'exercise_feedback';

  final FirebaseFirestore _firestore;

  FirestoreFeedbackRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ExerciseFeedback>> watchAllFeedback() {
    if (kDebugMode) {
      debugPrint('🔴 FirestoreFeedbackRepository: Starting master stream listener');
    }

    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (kDebugMode) {
        debugPrint('🔴 FirestoreFeedbackRepository: Received ${snapshot.docs.length} feedback items');
      }

      return snapshot.docs
          .map((doc) => ExerciseFeedback.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<ExerciseFeedback>> watchFeedbackByExercise(String exerciseId) {
    return _firestore
        .collection(_collection)
        .where('exerciseId', isEqualTo: exerciseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExerciseFeedback.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<ExerciseFeedback>> watchFeedbackByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExerciseFeedback.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<ExerciseFeedback>> watchCriticalFeedback() {
    return _firestore
        .collection(_collection)
        .where('severity', isGreaterThanOrEqualTo: 4)
        .where('status', isEqualTo: 'OPEN')
        .orderBy('severity', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExerciseFeedback.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<ExerciseFeedback?> getFeedbackById(String feedbackId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(feedbackId).get();
      if (!doc.exists) return null;
      return ExerciseFeedback.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting feedback: $e');
      }
      rethrow;
    }
  }

  @override
  Future<String> createFeedback(ExerciseFeedback feedback) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(feedback.toFirestore());
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error creating feedback: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateFeedbackStatus(String feedbackId, String newStatus) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(feedbackId)
          .update({'status': newStatus});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating feedback status: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateAdminNotes(String feedbackId, String notes) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(feedbackId)
          .update({'adminNotes': notes});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating admin notes: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateFeedbackSeverity(String feedbackId, int severity) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(feedbackId)
          .update({'severity': severity});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating feedback severity: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> batchUpdateFeedback(
    List<String> feedbackIds,
    Map<String, dynamic> updates,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final feedbackId in feedbackIds) {
        batch.update(
          _firestore.collection(_collection).doc(feedbackId),
          updates,
        );
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error batch updating feedback: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection(_collection).doc(feedbackId).delete();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting feedback: $e');
      }
      rethrow;
    }
  }

  @override
  Future<int> countTotalFeedback() async {
    try {
      final snapshot = await _firestore.collection(_collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error counting total feedback: $e');
      }
      return 0;
    }
  }

  @override
  Future<Map<String, int>> countByStatus() async {
    try {
      final snapshot =
          await _firestore.collection(_collection).get();
      final counts = <String, int>{};

      for (final doc in snapshot.docs) {
        final status = doc['status'] ?? 'OPEN';
        counts[status] = (counts[status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error counting by status: $e');
      }
      return {};
    }
  }

  @override
  Future<Map<String, int>> countByType() async {
    try {
      final snapshot =
          await _firestore.collection(_collection).get();
      final counts = <String, int>{};

      for (final doc in snapshot.docs) {
        final type = doc['feedbackType'] ?? 'OTHER';
        counts[type] = (counts[type] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error counting by type: $e');
      }
      return {};
    }
  }

  @override
  Future<Map<String, int>> countBySeverity() async {
    try {
      final snapshot =
          await _firestore.collection(_collection).get();
      final counts = <String, int>{};

      for (final doc in snapshot.docs) {
        final severity = doc['severity'] ?? 2;
        final sevKey = severity.toString();
        counts[sevKey] = (counts[sevKey] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error counting by severity: $e');
      }
      return {};
    }
  }
}
