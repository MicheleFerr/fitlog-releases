/// Coach Repository Interface
///
/// Defines the contract for coach-athlete relationship management.
/// Implementation uses existing `coach_delegations` Firestore collection.
///
/// **Layer**: Domain
/// **Feature**: Coach
library;

import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';

/// Repository interface for coach-athlete relationships
abstract class CoachRepository {
  // ============================================================
  // ATHLETE MANAGEMENT (Coach perspective)
  // ============================================================

  /// Get all athletes for a coach
  ///
  /// [coachId] - Coach's user ID
  /// Returns list of relationships sorted by status (active first)
  Future<List<CoachRelationship>> getAthletes(String coachId);

  /// Watch athletes in real-time
  ///
  /// [coachEmail] - Coach's email (used in current schema)
  /// Returns stream of relationships
  Stream<List<CoachRelationship>> watchAthletes(String coachEmail);

  /// Get single athlete relationship
  Future<CoachRelationship?> getAthleteRelationship(
    String coachId,
    String athleteId,
  );

  /// Invite athlete by email
  ///
  /// Creates a pending relationship that athlete must accept
  /// Returns the created relationship ID
  Future<String> inviteAthlete({
    required String coachId,
    required String coachEmail,
    required String coachName,
    required String athleteEmail,
  });

  /// Remove athlete from coach's roster
  ///
  /// Sets status to 'ended', doesn't delete for audit trail
  Future<void> removeAthlete(String relationshipId);

  /// Update athlete permissions
  Future<void> updateAthletePermissions(
    String relationshipId,
    CoachPermissions permissions,
  );

  /// Add note to athlete profile
  Future<void> addAthleteNote(String relationshipId, String note);

  // ============================================================
  // ATHLETE WORKOUT ACCESS
  // ============================================================

  /// Fetch workout history for an athlete
  ///
  /// [coachEmail] - Coach's email (for permission check)
  /// [athleteId] - Athlete's user ID
  /// [limit] - Max number of workouts to fetch
  ///
  /// Returns list of workout history details
  /// Throws if coach doesn't have permission
  Future<List<AthleteWorkoutSummary>> fetchAthleteWorkouts({
    required String coachEmail,
    required String athleteId,
    int limit = 20,
  });

  /// Get weekly stats for an athlete
  Future<AthleteWeeklyStats> getAthleteWeeklyStats({
    required String coachEmail,
    required String athleteId,
  });

  // ============================================================
  // COACH MANAGEMENT (Athlete perspective)
  // ============================================================

  /// Get coach for an athlete
  ///
  /// [athleteId] - Athlete's user ID
  /// Returns the active coach relationship or null
  Future<CoachRelationship?> getMyCoach(String athleteId);

  /// Watch my coach relationship
  Stream<CoachRelationship?> watchMyCoach(String athleteId);

  /// Accept coach invitation
  ///
  /// [relationshipId] - The pending relationship ID
  /// [athleteId] - Athlete's user ID
  /// [athleteName] - Athlete's display name (for denormalization)
  Future<void> acceptCoachInvitation({
    required String relationshipId,
    required String athleteId,
    required String athleteName,
  });

  /// Decline coach invitation
  Future<void> declineCoachInvitation(String relationshipId);

  /// Disconnect from coach
  ///
  /// Athlete-initiated end of relationship
  Future<void> disconnectFromCoach(String relationshipId);

  // ============================================================
  // LINKING VIA CODE
  // ============================================================

  /// Link athlete to coach via code
  ///
  /// [athleteId] - Athlete's user ID
  /// [athleteEmail] - Athlete's email
  /// [athleteName] - Athlete's display name
  /// [coachCode] - 6-character code from coach
  ///
  /// Returns relationship ID if successful
  /// Throws if code is invalid or expired
  Future<String> linkViaCode({
    required String athleteId,
    required String athleteEmail,
    required String athleteName,
    required String coachCode,
  });

  /// Find coach by code
  ///
  /// Returns coach info (id, name, email) if found
  /// Returns null if code doesn't exist or expired
  Future<CoachInfo?> findCoachByCode(String code);

  // ============================================================
  // COACH CODE MANAGEMENT
  // ============================================================

  /// Generate or get coach code
  ///
  /// [coachId] - Coach's user ID
  /// Returns existing code or generates a new one
  Future<String> getOrCreateCoachCode(String coachId);

  /// Regenerate coach code
  ///
  /// Invalidates old code and creates new one
  Future<String> regenerateCoachCode(String coachId);

  /// Validate coach code
  Future<bool> isValidCoachCode(String code);
}

/// Basic coach info returned when looking up by code
class CoachInfo {
  const CoachInfo({
    required this.coachId,
    required this.coachEmail,
    required this.coachName,
    this.photoUrl,
    this.athleteCount,
  });

  final String coachId;
  final String coachEmail;
  final String coachName;
  final String? photoUrl;
  final int? athleteCount;
}

/// Summary of a single athlete workout (for coach view)
class AthleteWorkoutSummary {
  const AthleteWorkoutSummary({
    required this.id,
    required this.name,
    required this.completedAt,
    required this.durationMinutes,
    required this.exerciseCount,
    required this.totalSets,
    required this.totalVolume,
    this.exercises = const [],
  });

  final String id;
  final String name;
  final DateTime completedAt;
  final int durationMinutes;
  final int exerciseCount;
  final int totalSets;
  final double totalVolume;
  final List<AthleteExerciseSummary> exercises;
}

/// Summary of exercise in workout
class AthleteExerciseSummary {
  const AthleteExerciseSummary({required this.name, required this.sets});

  final String name;
  final List<AthleteSetSummary> sets;

  /// Format sets as compact string (e.g., "50kg × 8, 8, 7")
  String get formattedSets {
    if (sets.isEmpty) return '-';
    final weights = sets.map((s) => s.weight).toSet();
    if (weights.length == 1) {
      final reps = sets.map((s) => '${s.reps}').join(', ');
      return '${weights.first}kg × $reps';
    }
    return sets.map((s) => '${s.weight}kg × ${s.reps}').join(', ');
  }
}

/// Summary of a single set
class AthleteSetSummary {
  const AthleteSetSummary({required this.weight, required this.reps});

  final double weight;
  final int reps;
}

/// Weekly stats for an athlete
class AthleteWeeklyStats {
  const AthleteWeeklyStats({
    required this.totalWorkouts,
    required this.plannedWorkouts,
    required this.totalMinutes,
    required this.totalVolume,
    required this.compliancePercent,
    this.lastWorkoutAt,
  });

  /// Create empty stats
  const AthleteWeeklyStats.empty()
    : totalWorkouts = 0,
      plannedWorkouts = 4, // Default assumption
      totalMinutes = 0,
      totalVolume = 0,
      compliancePercent = 0,
      lastWorkoutAt = null;

  final int totalWorkouts;
  final int plannedWorkouts;
  final int totalMinutes;
  final double totalVolume;
  final int compliancePercent;
  final DateTime? lastWorkoutAt;
}
