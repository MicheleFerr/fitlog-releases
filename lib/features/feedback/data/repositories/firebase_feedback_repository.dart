/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/data/repositories
/// 🎯 Feature: user_feedback
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FIREBASE FEEDBACK REPOSITORY - Firebase implementation
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/user_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/unified_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/repositories/i_unified_feedback_repository.dart' hide FeedbackStatistics;
import 'package:gymbro_flutter_new/shared/domain/services/secure_logger.dart'; // 🔐 SECURITY: Secure logging

/// Firebase implementation of FeedbackRepository
class FirebaseFeedbackRepository implements FeedbackRepository {

  FirebaseFeedbackRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    IUnifiedFeedbackRepository? unifiedRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _unifiedRepository = unifiedRepository;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final IUnifiedFeedbackRepository? _unifiedRepository;

  static const String _collectionName = 'userFeedback';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  // === USER OPERATIONS ===

  @override
  Future<void> submitFeedback(UserFeedback feedback) async {
    try {
      // Save to old collection (backward compatibility)
      await _collection.doc(feedback.id).set(feedback.toJson());

      // ALSO save to unified feedback system (new)
      if (_unifiedRepository != null) {
        final user = _auth.currentUser;
        if (user != null) {
          final unifiedFeedback = UnifiedFeedback(
            id: '',
            userId: feedback.userId,
            type: UnifiedFeedbackType.general,
            status: _mapUserFeedbackStatusToUnified(feedback.status),
            severity: _mapCategoryToSeverity(feedback.category),
            message: feedback.message,
            createdAt: feedback.createdAt,
            metadata: {
              'category': feedback.category.name,
              'rating': feedback.rating ?? 0,
              'userEmail': feedback.userEmail ?? '',
              'userDisplayName': feedback.userDisplayName ?? '',
              'deviceInfo': feedback.deviceInfo ?? '',
              'appVersion': feedback.appVersion ?? '',
              'screenshotUrl': feedback.screenshotUrl ?? '',
            },
            adminNotes: feedback.adminNotes,
            resolvedAt: feedback.status == FeedbackStatus.resolved
                ? feedback.reviewedAt
                : null,
            updatedAt: feedback.reviewedAt,
          );

          // Fire and forget - don't block
          _unifiedRepository.submitFeedback(unifiedFeedback).then(
            (result) => result.fold(
              (failure) {
                // 🔐 SECURITY: Use SecureLogger (debug-only, no production logs)
                SecureLogger.warning('General feedback to unified system failed', data: {
                  'failureMessage': failure.message,
                });
              },
              (_) {
                // Success - no action needed
              },
            ),
          );
        }
      }
    } catch (e) {
      throw _handleError(e, 'submitFeedback');
    }
  }

  /// Map UserFeedback status to UnifiedFeedback status
  UnifiedFeedbackStatus _mapUserFeedbackStatusToUnified(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.newFeedback:
        return UnifiedFeedbackStatus.open;
      case FeedbackStatus.reviewed:
        return UnifiedFeedbackStatus.reviewing;
      case FeedbackStatus.resolved:
        return UnifiedFeedbackStatus.resolved;
      case FeedbackStatus.dismissed:
        return UnifiedFeedbackStatus.dismissed;
    }
  }

  /// Map FeedbackCategory to FeedbackSeverity
  FeedbackSeverity _mapCategoryToSeverity(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.bug:
        return FeedbackSeverity.high;
      case FeedbackCategory.feature:
      case FeedbackCategory.improvement:
        return FeedbackSeverity.medium;
      case FeedbackCategory.praise:
      case FeedbackCategory.other:
        return FeedbackSeverity.low;
    }
  }

  @override
  Future<List<UserFeedback>> getUserFeedback(String userId) async {
    try {
      final query = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => UserFeedback.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getUserFeedback');
    }
  }

  // === ADMIN OPERATIONS ===

  @override
  Future<List<UserFeedback>> getAllFeedback() async {
    try {
      final query =
          await _collection.orderBy('createdAt', descending: true).get();

      return query.docs
          .map((doc) => UserFeedback.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getAllFeedback');
    }
  }

  @override
  Future<List<UserFeedback>> getFeedbackByStatus(FeedbackStatus status) async {
    try {
      final query = await _collection
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => UserFeedback.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getFeedbackByStatus');
    }
  }

  @override
  Future<List<UserFeedback>> getFeedbackByCategory(
      FeedbackCategory category) async {
    try {
      final query = await _collection
          .where('category', isEqualTo: category.name)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => UserFeedback.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getFeedbackByCategory');
    }
  }

  @override
  Future<void> updateFeedbackStatus({
    required String feedbackId,
    required FeedbackStatus status,
    required String adminUserId,
    String? notes,
  }) async {
    try {
      await _collection.doc(feedbackId).update({
        'status': status.name,
        'reviewedAt': DateTime.now().toIso8601String(),
        'reviewedBy': adminUserId,
        if (notes != null) 'adminNotes': notes,
      });
    } catch (e) {
      throw _handleError(e, 'updateFeedbackStatus');
    }
  }

  @override
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _collection.doc(feedbackId).delete();
    } catch (e) {
      throw _handleError(e, 'deleteFeedback');
    }
  }

  // === REAL-TIME STREAMS ===

  @override
  Stream<List<UserFeedback>> watchAllFeedback() {
    try {
      return _collection.orderBy('createdAt', descending: true).snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => UserFeedback.fromJson(doc.data()))
                .toList(),
          );
    } catch (e) {
      throw _handleError(e, 'watchAllFeedback');
    }
  }

  @override
  Stream<int> watchNewFeedbackCount() {
    try {
      return _collection
          .where('status', isEqualTo: FeedbackStatus.newFeedback.name)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      throw _handleError(e, 'watchNewFeedbackCount');
    }
  }

  // === STATISTICS ===

  @override
  Future<FeedbackStatistics> getFeedbackStatistics() async {
    try {
      final allFeedback = await getAllFeedback();
      return FeedbackStatistics.fromFeedbackList(allFeedback);
    } catch (e) {
      throw _handleError(e, 'getFeedbackStatistics');
    }
  }

  // === ERROR HANDLING ===

  Exception _handleError(Object error, String operation) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception(
              'Permission denied: You do not have access to feedback data.');
        case 'not-found':
          return Exception('Feedback not found.');
        case 'unavailable':
          return Exception(
              'Firestore service is temporarily unavailable. Please try again.');
        default:
          return Exception('Firebase error in $operation: ${error.message}');
      }
    }

    return Exception('Error in $operation: ${error.toString()}');
  }
}
