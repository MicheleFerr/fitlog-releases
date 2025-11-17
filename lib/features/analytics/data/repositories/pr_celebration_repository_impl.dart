import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart' as fpdart show Either, Right, Left;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/personal_record.dart'
    as domain_pr;
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/pr_celebration_repository.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';

/// PR Celebration repository implementation
///
/// Uses Firestore for persistence + IAnalyticsService for event tracking.
/// Implements 5-minute post-workout notification window logic.
class PRCelebrationRepositoryImpl implements PRCelebrationRepository {
  PRCelebrationRepositoryImpl({
    FirebaseFirestore? firestore,
    required this.analyticsService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final IAnalyticsService analyticsService;

  static const _notificationWindowMinutes = 5;

  @override
  Future<fpdart.Either<Failure, void>> recordCelebration(
    String userId,
    domain_pr.PersonalRecord pr,
  ) async {
    try {
      // Look up previous PR value from historical celebrations
      final previousPRQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pr_celebrations')
          .where('exerciseName', isEqualTo: pr.exerciseName)
          .where('prType', isEqualTo: _mapDomainPRTypeToShared(pr.type).name)
          .orderBy('celebratedAt', descending: true)
          .limit(1)
          .get();

      final previousValue = previousPRQuery.docs.isNotEmpty
          ? (previousPRQuery.docs.first.data()['newValue'] as num?)?.toDouble() ??
              0.0
          : 0.0;

      final celebration = PRCelebration(
        id: '${userId}_${pr.id}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        prId: pr.id,
        prType: _mapDomainPRTypeToShared(pr.type),
        celebratedAt: DateTime.now(),
        engagement: CelebrationEngagement.viewed, // Default to viewed
        previousValue: previousValue,
        newValue: pr.value,
        exerciseName: pr.exerciseName,
      );

      // Calculate improvement for analytics
      final improvementPercentage = previousValue > 0
          ? ((pr.value - previousValue) / previousValue) * 100
          : 0.0;

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pr_celebrations')
          .doc(celebration.id)
          .set(celebration.toJson());

      // Track event in analytics
      await analyticsService.logEvent(
        name: 'pr_celebration_recorded',
        parameters: {
          'user_id': userId,
          'pr_id': pr.id,
          'pr_type': pr.type.name,
          'exercise_name': pr.exerciseName,
          'new_value': pr.value,
          'previous_value': previousValue,
          'improvement_percentage': improvementPercentage,
        },
      );

      return const fpdart.Right(null);
    } on FirebaseException catch (e) {
      return fpdart.Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to record celebration: $e'),
      );
    }
  }

  /// Map domain PRType to shared PRType for PRCelebration entity
  PRType _mapDomainPRTypeToShared(domain_pr.PRType domainType) {
    switch (domainType) {
      case domain_pr.PRType.weight:
        return PRType.weight;
      case domain_pr.PRType.volume:
        return PRType.volume;
      case domain_pr.PRType.reps:
        return PRType.reps;
      case domain_pr.PRType.oneRM:
        return PRType.oneRM;
      case domain_pr.PRType.totalSets:
        return PRType.totalSets;
      case domain_pr.PRType.time:
        return PRType.duration; // Domain 'time' maps to shared 'duration'
      case domain_pr.PRType.totalVolume:
        return PRType.volume; // Map totalVolume to volume
    }
  }

  @override
  Future<fpdart.Either<Failure, void>> trackEngagement(
    String userId,
    String prId,
    CelebrationEngagement engagement,
  ) async {
    try {
      // Find celebration document
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pr_celebrations')
          .where('prId', isEqualTo: prId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return fpdart.Left(
          ValidationFailure('PR celebration not found'),
        );
      }

      final doc = querySnapshot.docs.first;

      // Update engagement
      await doc.reference.update({
        'engagement': engagement.name,
        'engagementUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Track engagement event in analytics
      await analyticsService.logEvent(
        name: 'pr_celebration_engagement',
        parameters: {
          'user_id': userId,
          'pr_id': prId,
          'engagement_type': engagement.name,
        },
      );

      return fpdart.Right(null);
    } on FirebaseException catch (e) {
      return fpdart.Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to track engagement: $e'),
      );
    }
  }

  @override
  Future<fpdart.Either<Failure, bool>> shouldNotifyUser(
    String userId,
    DateTime workoutEndTime,
  ) async {
    try {
      final now = DateTime.now();
      final timeSinceWorkout = now.difference(workoutEndTime);

      // Check if within 5-minute notification window
      if (timeSinceWorkout.inMinutes < _notificationWindowMinutes) {
        return fpdart.Right(true);
      }

      return fpdart.Right(false);
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to check notification eligibility: $e'),
      );
    }
  }

  @override
  Future<fpdart.Either<Failure, List<PRCelebration>>> getRecentCelebrations(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pr_celebrations')
          .orderBy('celebratedAt', descending: true)
          .limit(limit)
          .get();

      final celebrations = snapshot.docs
          .map((doc) => PRCelebration.fromJson(doc.data()))
          .toList();

      return fpdart.Right(celebrations);
    } on FirebaseException catch (e) {
      return fpdart.Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to fetch celebrations: $e'),
      );
    }
  }

  @override
  Future<fpdart.Either<Failure, bool>> isCelebrationRecorded(
    String userId,
    String prId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pr_celebrations')
          .where('prId', isEqualTo: prId)
          .limit(1)
          .get();

      return fpdart.Right(querySnapshot.docs.isNotEmpty);
    } on FirebaseException catch (e) {
      return fpdart.Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to check celebration: $e'),
      );
    }
  }
}
