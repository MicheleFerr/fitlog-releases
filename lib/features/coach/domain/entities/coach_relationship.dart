/// Coach Relationship Entity
///
/// Maps to Firestore `coach_delegations` collection.
/// Represents the relationship between a coach and an athlete.
///
/// **Layer**: Domain
/// **Feature**: Coach
/// **Firestore Collection**: coach_delegations
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'coach_relationship.freezed.dart';
part 'coach_relationship.g.dart';

/// Relationship status between coach and athlete
enum RelationshipStatus {
  /// Invitation sent, waiting for athlete to accept
  pending('pending'),

  /// Active coaching relationship
  active('active'),

  /// Temporarily paused (vacation, injury, etc.)
  paused('paused'),

  /// Relationship ended
  ended('ended');

  const RelationshipStatus(this.value);
  final String value;

  static RelationshipStatus fromString(String? value) {
    if (value == null) return RelationshipStatus.pending;
    return RelationshipStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => RelationshipStatus.pending,
    );
  }
}

/// Permissions granted to coach for this athlete
@freezed
abstract class CoachPermissions with _$CoachPermissions {
  const factory CoachPermissions({
    /// Can view athlete's workout dashboard
    @Default(true) bool canViewDashboard,

    /// Can edit/assign workouts
    @Default(true) bool canEditWorkout,

    /// Can view health questionnaire (PAR-Q)
    @Default(false) bool canViewHealth,

    /// Can view body measurements
    @Default(false) bool canViewMeasurements,
  }) = _CoachPermissions;

  /// Private constructor for static getters
  const CoachPermissions._();

  factory CoachPermissions.fromJson(Map<String, dynamic> json) =>
      _$CoachPermissionsFromJson(json);

  /// Default permissions for new relationships
  static CoachPermissions get defaultPermissions => const CoachPermissions();

  /// Full permissions (premium feature)
  static CoachPermissions get fullPermissions => const CoachPermissions(
    canViewDashboard: true,
    canEditWorkout: true,
    canViewHealth: true,
    canViewMeasurements: true,
  );
}

/// Coach-Athlete relationship
///
/// Maps to `coach_delegations/{delegationId}` in Firestore.
/// Document ID format: `{coachEmail}_{athleteEmail}` (legacy)
/// or `{coachId}_{athleteId}` (new format)
@freezed
abstract class CoachRelationship with _$CoachRelationship {
  const factory CoachRelationship({
    /// Unique ID (Firestore document ID)
    required String id,

    /// Athlete's user ID
    required String athleteId,

    /// Athlete's email (for legacy compatibility)
    String? athleteEmail,

    /// Athlete's display name (denormalized for list display)
    String? athleteName,

    /// Coach's user ID
    String? coachId,

    /// Coach's email (required by current schema)
    required String coachEmail,

    /// Coach's display name (denormalized)
    String? coachName,

    /// Relationship status
    @Default(RelationshipStatus.pending) RelationshipStatus status,

    /// Whether athlete has the app installed
    @Default(true) bool athleteHasApp,

    /// Permissions granted to coach
    @Default(CoachPermissions()) CoachPermissions permissions,

    /// When the relationship was created
    required DateTime createdAt,

    /// When the athlete accepted (null if pending)
    DateTime? connectedAt,

    /// When the relationship ended (null if active)
    DateTime? endedAt,

    /// Optional notes from coach
    String? coachNotes,
  }) = _CoachRelationship;

  const CoachRelationship._();

  factory CoachRelationship.fromJson(Map<String, dynamic> json) =>
      _$CoachRelationshipFromJson(json);

  /// Create from Firestore document
  factory CoachRelationship.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse permissions (may be flat or nested)
    CoachPermissions permissions;
    if (data['permissions'] != null) {
      permissions = CoachPermissions.fromJson(
        data['permissions'] as Map<String, dynamic>,
      );
    } else {
      // Legacy flat format
      permissions = CoachPermissions(
        canViewDashboard: data['canViewDashboard'] as bool? ?? true,
        canEditWorkout: data['canEditWorkout'] as bool? ?? true,
      );
    }

    return CoachRelationship(
      id: doc.id,
      athleteId: data['userId'] as String? ?? '', // Legacy field name
      athleteEmail: data['athleteEmail'] as String?,
      athleteName: data['athleteName'] as String?,
      coachId: data['coachId'] as String?,
      coachEmail: data['coachEmail'] as String? ?? '',
      coachName: data['coachName'] as String?,
      status: RelationshipStatus.fromString(data['status'] as String?),
      athleteHasApp: data['athleteHasApp'] as bool? ?? true,
      permissions: permissions,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      connectedAt: (data['connectedAt'] as Timestamp?)?.toDate(),
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
      coachNotes: data['coachNotes'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': athleteId, // Legacy field name for compatibility
      'athleteId': athleteId,
      'athleteEmail': athleteEmail,
      'athleteName': athleteName,
      'coachId': coachId,
      'coachEmail': coachEmail,
      'coachName': coachName,
      'status': status.value,
      'athleteHasApp': athleteHasApp,
      'permissions': permissions.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      if (connectedAt != null) 'connectedAt': Timestamp.fromDate(connectedAt!),
      if (endedAt != null) 'endedAt': Timestamp.fromDate(endedAt!),
      if (coachNotes != null) 'coachNotes': coachNotes,
    };
  }

  /// Whether the relationship is currently active
  bool get isActive => status == RelationshipStatus.active;

  /// Whether the relationship is pending acceptance
  bool get isPending => status == RelationshipStatus.pending;

  /// Whether the relationship has ended
  bool get isEnded => status == RelationshipStatus.ended;

  /// Generate document ID (new format using IDs)
  static String generateId(String coachId, String athleteId) {
    return '${coachId}_$athleteId';
  }

  /// Generate legacy document ID (using emails)
  static String generateLegacyId(String coachEmail, String athleteEmail) {
    return '${coachEmail}_$athleteEmail';
  }
}
