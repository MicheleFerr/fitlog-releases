/// Coach Repository Implementation
///
/// Implements CoachRepository using Firestore `coach_delegations` collection.
/// Uses direct Firestore access (not BaseHybridRepository) because coach data
/// is shared between two users (coach and athlete).
///
/// **Layer**: Data
/// **Feature**: Coach
/// **Firestore Collection**: coach_delegations, users
library;

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';
import 'package:gymbro_flutter_new/features/coach/domain/repositories/coach_repository.dart';

/// Firestore-based implementation of CoachRepository
class CoachRepositoryImpl with FirebaseErrorMapperMixin implements CoachRepository {
  CoachRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Collection references
  CollectionReference<Map<String, dynamic>> get _delegations =>
      _firestore.collection('coach_delegations');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ============================================================
  // ATHLETE MANAGEMENT (Coach perspective)
  // ============================================================

  @override
  Future<List<CoachRelationship>> getAthletes(String coachId) async {
    final result = await handleFirebaseOperation<List<CoachRelationship>>(
      () async {
        // First get coach email from users collection
        final coachDoc = await _users.doc(coachId).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Firestore getAthletes user lookup timed out'),
        );
        final coachEmail = coachDoc.data()?['email'] as String?;

        if (coachEmail == null) {
          if (kDebugMode) {
            debugPrint('[CoachRepo] No email found for coach: $coachId');
          }
          return [];
        }

        // Query by coachEmail (current schema)
        final snapshot = await _delegations
            .where('coachEmail', isEqualTo: coachEmail)
            .where('status', whereIn: ['pending', 'active', 'paused'])
            .orderBy('createdAt', descending: true)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () =>
                  throw TimeoutException('Firestore getAthletes query timed out'),
            );

        final relationships = snapshot.docs
            .map((doc) => CoachRelationship.fromFirestore(doc))
            .toList();

        // Sort: active first, then pending, then paused
        relationships.sort((a, b) {
          final order = {
            RelationshipStatus.active: 0,
            RelationshipStatus.pending: 1,
            RelationshipStatus.paused: 2,
            RelationshipStatus.ended: 3,
          };
          return order[a.status]!.compareTo(order[b.status]!);
        });

        if (kDebugMode) {
          debugPrint('[CoachRepo] Found ${relationships.length} athletes');
        }

        return relationships;
      },
      operationName: 'getAthletes',
    );

    return result.fold(
      (failure) => throw Exception('Failed to get athletes: ${failure.message}'),
      (value) => value,
    );
  }

  @override
  Stream<List<CoachRelationship>> watchAthletes(String coachEmail) {
    return _delegations
        .where('coachEmail', isEqualTo: coachEmail)
        .where('status', whereIn: ['pending', 'active', 'paused'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final relationships = snapshot.docs
          .map((doc) => CoachRelationship.fromFirestore(doc))
          .toList();

      // Sort by status
      relationships.sort((a, b) {
        final order = {
          RelationshipStatus.active: 0,
          RelationshipStatus.pending: 1,
          RelationshipStatus.paused: 2,
          RelationshipStatus.ended: 3,
        };
        return order[a.status]!.compareTo(order[b.status]!);
      });

      return relationships;
    });
  }

  @override
  Future<CoachRelationship?> getAthleteRelationship(
    String coachId,
    String athleteId,
  ) async {
    final result = await handleFirebaseOperation<CoachRelationship?>(
      () async {
        // Try new format first
        final newFormatId = CoachRelationship.generateId(coachId, athleteId);
        final doc = await _delegations.doc(newFormatId).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Firestore getAthleteRelationship doc timed out'),
        );

        if (doc.exists) {
          return CoachRelationship.fromFirestore(doc);
        }

        // Fallback: query by IDs
        final snapshot = await _delegations
            .where('coachId', isEqualTo: coachId)
            .where('athleteId', isEqualTo: athleteId)
            .limit(1)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () =>
                  throw TimeoutException('Firestore getAthleteRelationship query timed out'),
            );

        if (snapshot.docs.isNotEmpty) {
          return CoachRelationship.fromFirestore(snapshot.docs.first);
        }

        return null;
      },
      operationName: 'getAthleteRelationship',
    );

    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[CoachRepo] Error getting relationship: ${failure.message}');
        }
        return null;
      },
      (value) => value,
    );
  }

  @override
  Future<String> inviteAthlete({
    required String coachId,
    required String coachEmail,
    required String coachName,
    required String athleteEmail,
  }) async {
    final result = await handleFirebaseOperation<String>(
      () async {
        // Check if relationship already exists
        final existing = await _delegations
            .where('coachEmail', isEqualTo: coachEmail)
            .where('athleteEmail', isEqualTo: athleteEmail)
            .limit(1)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () =>
                  throw TimeoutException('Firestore inviteAthlete check timed out'),
            );

        if (existing.docs.isNotEmpty) {
          final existingStatus = existing.docs.first.data()['status'];
          if (existingStatus == 'active' || existingStatus == 'pending') {
            throw Exception('Athlete already linked or invitation pending');
          }
        }

        // Create new relationship
        final relationship = CoachRelationship(
          id: '', // Will be set by Firestore
          athleteId: '', // Will be set when athlete accepts
          athleteEmail: athleteEmail,
          coachId: coachId,
          coachEmail: coachEmail,
          coachName: coachName,
          status: RelationshipStatus.pending,
          athleteHasApp: false, // Unknown until they accept
          createdAt: DateTime.now(),
        );

        // Use email-based ID for legacy compatibility
        final docId = CoachRelationship.generateLegacyId(coachEmail, athleteEmail);
        await _delegations.doc(docId).set(relationship.toFirestore()).timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Firestore inviteAthlete set timed out'),
        );

        if (kDebugMode) {
          debugPrint('[CoachRepo] Invited athlete: $athleteEmail');
        }

        // Send notification to athlete (if they have an account)
        await _sendAthleteNotification(
          athleteEmail: athleteEmail,
          coachEmail: coachEmail,
          coachName: coachName,
          type: 'invitation',
        );

        return docId;
      },
      operationName: 'inviteAthlete',
    );

    return result.fold(
      (failure) => throw Exception('Failed to invite athlete: ${failure.message}'),
      (value) => value,
    );
  }

  @override
  Future<void> removeAthlete(String relationshipId) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        await _delegations.doc(relationshipId).update({
          'status': RelationshipStatus.ended.value,
          'endedAt': FieldValue.serverTimestamp(),
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Firestore removeAthlete timed out'),
        );

        if (kDebugMode) {
          debugPrint('[CoachRepo] Removed athlete: $relationshipId');
        }
      },
      operationName: 'removeAthlete',
    );

    result.fold(
      (failure) => throw Exception('Failed to remove athlete: ${failure.message}'),
      (_) => null,
    );
  }

  @override
  Future<void> updateAthletePermissions(
    String relationshipId,
    CoachPermissions permissions,
  ) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        await _delegations.doc(relationshipId).update({
          'permissions': permissions.toJson(),
        });

        if (kDebugMode) {
          debugPrint('[CoachRepo] Updated permissions: $relationshipId');
        }
      },
      operationName: 'updateAthletePermissions',
    );

    result.fold(
      (failure) => throw Exception('Failed to update permissions: ${failure.message}'),
      (_) => null,
    );
  }

  @override
  Future<void> addAthleteNote(
    String relationshipId,
    String note,
  ) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        await _delegations.doc(relationshipId).update({
          'coachNotes': note,
        });
      },
      operationName: 'addAthleteNote',
    );

    result.fold(
      (failure) => throw Exception('Failed to add note: ${failure.message}'),
      (_) => null,
    );
  }

  // ============================================================
  // COACH MANAGEMENT (Athlete perspective)
  // ============================================================

  @override
  Future<CoachRelationship?> getMyCoach(String athleteId) async {
    final result = await handleFirebaseOperation<CoachRelationship?>(
      () async {
        // Get athlete email
        final athleteDoc = await _users.doc(athleteId).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Firestore getMyCoach user lookup timed out'),
        );
        final athleteEmail = athleteDoc.data()?['email'] as String?;

        if (athleteEmail == null) return null;

        // Query by athleteId first (new format)
        var snapshot = await _delegations
            .where('athleteId', isEqualTo: athleteId)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () =>
                  throw TimeoutException('Firestore getMyCoach query timed out'),
            );

        if (snapshot.docs.isNotEmpty) {
          return CoachRelationship.fromFirestore(snapshot.docs.first);
        }

        // Fallback: query by athleteEmail (legacy)
        snapshot = await _delegations
            .where('athleteEmail', isEqualTo: athleteEmail)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () =>
                  throw TimeoutException('Firestore getMyCoach legacy query timed out'),
            );

        if (snapshot.docs.isNotEmpty) {
          return CoachRelationship.fromFirestore(snapshot.docs.first);
        }

        return null;
      },
      operationName: 'getMyCoach',
    );

    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[CoachRepo] Error getting my coach: ${failure.message}');
        }
        return null;
      },
      (value) => value,
    );
  }

  @override
  Stream<CoachRelationship?> watchMyCoach(String athleteId) {
    return _delegations
        .where('athleteId', isEqualTo: athleteId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return CoachRelationship.fromFirestore(snapshot.docs.first);
    });
  }

  @override
  Future<void> acceptCoachInvitation({
    required String relationshipId,
    required String athleteId,
    required String athleteName,
  }) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        await _delegations.doc(relationshipId).update({
          'athleteId': athleteId,
          'athleteName': athleteName,
          'athleteHasApp': true,
          'status': RelationshipStatus.active.value,
          'connectedAt': FieldValue.serverTimestamp(),
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Firestore acceptCoachInvitation update timed out'),
        );

        // Notify coach
        final doc = await _delegations.doc(relationshipId).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Firestore acceptCoachInvitation get timed out'),
        );
        final coachEmail = doc.data()?['coachEmail'] as String?;
        final athleteEmail = doc.data()?['athleteEmail'] as String?;
        if (coachEmail != null && athleteEmail != null) {
          await _sendCoachNotification(
            coachEmail: coachEmail,
            athleteEmail: athleteEmail,
            athleteName: athleteName,
            type: 'accepted',
          );
        }

        if (kDebugMode) {
          debugPrint('[CoachRepo] Accepted invitation: $relationshipId');
        }
      },
      operationName: 'acceptCoachInvitation',
    );

    result.fold(
      (failure) => throw Exception('Failed to accept invitation: ${failure.message}'),
      (_) => null,
    );
  }

  @override
  Future<void> declineCoachInvitation(String relationshipId) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        await _delegations.doc(relationshipId).update({
          'status': RelationshipStatus.ended.value,
          'endedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          debugPrint('[CoachRepo] Declined invitation: $relationshipId');
        }
      },
      operationName: 'declineCoachInvitation',
    );

    result.fold(
      (failure) => throw Exception('Failed to decline invitation: ${failure.message}'),
      (_) => null,
    );
  }

  @override
  Future<void> disconnectFromCoach(String relationshipId) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        await _delegations.doc(relationshipId).update({
          'status': RelationshipStatus.ended.value,
          'endedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          debugPrint('[CoachRepo] Disconnected from coach: $relationshipId');
        }
      },
      operationName: 'disconnectFromCoach',
    );

    result.fold(
      (failure) => throw Exception('Failed to disconnect from coach: ${failure.message}'),
      (_) => null,
    );
  }

  // ============================================================
  // LINKING VIA CODE
  // ============================================================

  @override
  Future<String> linkViaCode({
    required String athleteId,
    required String athleteEmail,
    required String athleteName,
    required String coachCode,
  }) async {
    final result = await handleFirebaseOperation<String>(
      () async {
        // Find coach by code
        final coachInfo = await findCoachByCode(coachCode);
        if (coachInfo == null) {
          throw Exception('Invalid or expired coach code');
        }

        // Check if relationship already exists
        final existing = await _delegations
            .where('coachEmail', isEqualTo: coachInfo.coachEmail)
            .where('athleteEmail', isEqualTo: athleteEmail)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          final existingStatus = existing.docs.first.data()['status'];
          if (existingStatus == 'active') {
            throw Exception('Already linked to this coach');
          }
          if (existingStatus == 'pending') {
            // Accept existing invitation
            await acceptCoachInvitation(
              relationshipId: existing.docs.first.id,
              athleteId: athleteId,
              athleteName: athleteName,
            );
            return existing.docs.first.id;
          }
        }

        // Create new relationship (directly active since athlete initiated)
        final relationship = CoachRelationship(
          id: '',
          athleteId: athleteId,
          athleteEmail: athleteEmail,
          athleteName: athleteName,
          coachId: coachInfo.coachId,
          coachEmail: coachInfo.coachEmail,
          coachName: coachInfo.coachName,
          status: RelationshipStatus.active,
          athleteHasApp: true,
          createdAt: DateTime.now(),
          connectedAt: DateTime.now(),
        );

        final docId = CoachRelationship.generateId(
          coachInfo.coachId,
          athleteId,
        );
        await _delegations.doc(docId).set(relationship.toFirestore());

        // Notify coach
        await _sendCoachNotification(
          coachEmail: coachInfo.coachEmail,
          athleteEmail: athleteEmail,
          athleteName: athleteName,
          type: 'linked',
        );

        if (kDebugMode) {
          debugPrint('[CoachRepo] Linked via code: $docId');
        }

        return docId;
      },
      operationName: 'linkViaCode',
    );

    return result.fold(
      (failure) => throw Exception('Failed to link via code: ${failure.message}'),
      (value) => value,
    );
  }

  @override
  Future<CoachInfo?> findCoachByCode(String code) async {
    final result = await handleFirebaseOperation<CoachInfo?>(
      () async {
        final snapshot = await _users
            .where('preferences.coachCode', isEqualTo: code.toUpperCase())
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) return null;

        final doc = snapshot.docs.first;
        final data = doc.data();

        return CoachInfo(
          coachId: doc.id,
          coachEmail: data['email'] as String? ?? '',
          coachName: data['displayName'] as String? ?? 'Coach',
          photoUrl: data['photoURL'] as String?,
        );
      },
      operationName: 'findCoachByCode',
    );

    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[CoachRepo] Error finding coach by code: ${failure.message}');
        }
        return null;
      },
      (value) => value,
    );
  }

  // ============================================================
  // COACH CODE MANAGEMENT
  // ============================================================

  @override
  Future<String> getOrCreateCoachCode(String coachId) async {
    final result = await handleFirebaseOperation<String>(
      () async {
        final doc = await _users.doc(coachId).get();
        final preferences = doc.data()?['preferences'] as Map<String, dynamic>?;
        final existingCode = preferences?['coachCode'] as String?;

        if (existingCode != null && existingCode.isNotEmpty) {
          return existingCode;
        }

        // Generate new code
        return regenerateCoachCode(coachId);
      },
      operationName: 'getOrCreateCoachCode',
    );

    return result.fold(
      (failure) => throw Exception('Failed to get/create coach code: ${failure.message}'),
      (value) => value,
    );
  }

  @override
  Future<String> regenerateCoachCode(String coachId) async {
    final result = await handleFirebaseOperation<String>(
      () async {
        final code = _generateUniqueCode();

        // Ensure code is unique
        final existing = await findCoachByCode(code);
        if (existing != null) {
          // Extremely unlikely, but handle collision
          return regenerateCoachCode(coachId);
        }

        // Update user preferences
        await _users.doc(coachId).update({
          'preferences.coachCode': code,
          'preferences.coachCodeGeneratedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          debugPrint('[CoachRepo] Generated coach code: $code');
        }

        return code;
      },
      operationName: 'regenerateCoachCode',
    );

    return result.fold(
      (failure) => throw Exception('Failed to regenerate coach code: ${failure.message}'),
      (value) => value,
    );
  }

  @override
  Future<bool> isValidCoachCode(String code) async {
    final coach = await findCoachByCode(code);
    return coach != null;
  }

  // ============================================================
  // ATHLETE WORKOUT ACCESS
  // ============================================================

  @override
  Future<List<AthleteWorkoutSummary>> fetchAthleteWorkouts({
    required String coachEmail,
    required String athleteId,
    int limit = 20,
  }) async {
    final result = await handleFirebaseOperation<List<AthleteWorkoutSummary>>(
      () async {
        // Verify coach has permission
        final relationship = await _verifyCoachPermission(coachEmail, athleteId);
        if (relationship == null || !relationship.permissions.canViewDashboard) {
          throw Exception('No permission to view athlete workouts');
        }

        // Fetch workout history from athlete's subcollection
        final snapshot = await _users
            .doc(athleteId)
            .collection('workoutHistory')
            .orderBy('completedAt', descending: true)
            .limit(limit)
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          final exercises = (data['exercises'] as List<dynamic>?) ?? [];

          return AthleteWorkoutSummary(
            id: doc.id,
            name: data['name'] ?? 'Workout',
            completedAt: (data['completedAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            durationMinutes: data['durationMinutes'] ?? 0,
            exerciseCount: exercises.length,
            totalSets: _countTotalSets(exercises),
            totalVolume: _calculateTotalVolume(exercises),
            exercises: _parseExercises(exercises),
          );
        }).toList();
      },
      operationName: 'fetchAthleteWorkouts',
    );

    return result.fold(
      (failure) => throw Exception('Failed to fetch athlete workouts: ${failure.message}'),
      (value) => value,
    );
  }

  @override
  Future<AthleteWeeklyStats> getAthleteWeeklyStats({
    required String coachEmail,
    required String athleteId,
  }) async {
    final result = await handleFirebaseOperation<AthleteWeeklyStats>(
      () async {
        // Verify coach has permission
        final relationship = await _verifyCoachPermission(coachEmail, athleteId);
        if (relationship == null || !relationship.permissions.canViewDashboard) {
          throw Exception('No permission to view athlete stats');
        }

        // Get workouts from the last 7 days
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        final snapshot = await _users
            .doc(athleteId)
            .collection('workoutHistory')
            .where('completedAt', isGreaterThan: Timestamp.fromDate(weekAgo))
            .orderBy('completedAt', descending: true)
            .get();

        final workouts = snapshot.docs;
        if (workouts.isEmpty) {
          return const AthleteWeeklyStats.empty();
        }

        int totalMinutes = 0;
        double totalVolume = 0;
        DateTime? lastWorkoutAt;

        for (final doc in workouts) {
          final data = doc.data();
          totalMinutes += (data['durationMinutes'] as int?) ?? 0;
          final exercises = (data['exercises'] as List<dynamic>?) ?? [];
          totalVolume += _calculateTotalVolume(exercises);

          lastWorkoutAt ??= (data['completedAt'] as Timestamp?)?.toDate();
        }

        // Assume 4 planned workouts per week (can be customized later)
        const plannedWorkouts = 4;
        final compliancePercent =
            ((workouts.length / plannedWorkouts) * 100).clamp(0, 100).toInt();

        return AthleteWeeklyStats(
          totalWorkouts: workouts.length,
          plannedWorkouts: plannedWorkouts,
          totalMinutes: totalMinutes,
          totalVolume: totalVolume,
          compliancePercent: compliancePercent,
          lastWorkoutAt: lastWorkoutAt,
        );
      },
      operationName: 'getAthleteWeeklyStats',
    );

    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[CoachRepo] Error getting weekly stats: ${failure.message}');
        }
        return const AthleteWeeklyStats.empty();
      },
      (value) => value,
    );
  }

  /// Verify coach has permission to view athlete data
  Future<CoachRelationship?> _verifyCoachPermission(
    String coachEmail,
    String athleteId,
  ) async {
    // First get athlete email
    final athleteDoc = await _users.doc(athleteId).get();
    final athleteEmail = athleteDoc.data()?['email'] as String?;
    if (athleteEmail == null) return null;

    // Find the relationship
    final snapshot = await _delegations
        .where('coachEmail', isEqualTo: coachEmail)
        .where('athleteEmail', isEqualTo: athleteEmail)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CoachRelationship.fromFirestore(snapshot.docs.first);
  }

  int _countTotalSets(List<dynamic> exercises) {
    int total = 0;
    for (final exercise in exercises) {
      final sets = (exercise as Map<String, dynamic>)['sets'] as List?;
      total += sets?.length ?? 0;
    }
    return total;
  }

  double _calculateTotalVolume(List<dynamic> exercises) {
    double total = 0;
    for (final exercise in exercises) {
      final sets =
          ((exercise as Map<String, dynamic>)['sets'] as List?) ?? [];
      for (final set in sets) {
        final weight = ((set as Map<String, dynamic>)['weight'] ?? 0).toDouble();
        final reps = (set['reps'] ?? 0) as int;
        total += weight * reps;
      }
    }
    return total;
  }

  List<AthleteExerciseSummary> _parseExercises(List<dynamic> exercises) {
    return exercises.map((e) {
      final exercise = e as Map<String, dynamic>;
      final sets = (exercise['sets'] as List?) ?? [];

      return AthleteExerciseSummary(
        name: exercise['name'] ?? 'Exercise',
        sets: sets.map((s) {
          final set = s as Map<String, dynamic>;
          return AthleteSetSummary(
            weight: (set['weight'] ?? 0).toDouble(),
            reps: (set['reps'] ?? 0) as int,
          );
        }).toList(),
      );
    }).toList();
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  /// Generate a unique 6-character code
  String _generateUniqueCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excluding O, 0, I, 1
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Send notification to athlete
  ///
  /// [coachEmail] is required for Firestore security rules validation
  /// (only the actual coach can create notifications for their athletes)
  Future<void> _sendAthleteNotification({
    required String athleteEmail,
    required String coachEmail,
    required String coachName,
    required String type,
  }) async {
    try {
      await _firestore.collection('athleteNotifications').add({
        'athleteEmail': athleteEmail,
        'coachEmail': coachEmail, // Required for security rules
        'coachName': coachName,
        'type': type,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Non-critical, log and continue
      if (kDebugMode) {
        debugPrint('[CoachRepo] Failed to send athlete notification: $e');
      }
    }
  }

  /// Send notification to coach
  ///
  /// [athleteEmail] is required for Firestore security rules validation
  /// (only the actual athlete can create notifications for their coach)
  Future<void> _sendCoachNotification({
    required String coachEmail,
    required String athleteEmail,
    required String athleteName,
    required String type,
  }) async {
    try {
      await _firestore.collection('coachNotifications').add({
        'coachEmail': coachEmail,
        'athleteEmail': athleteEmail, // Required for security rules
        'athleteName': athleteName,
        'type': type,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Non-critical, log and continue
      if (kDebugMode) {
        debugPrint('[CoachRepo] Failed to send coach notification: $e');
      }
    }
  }
}
