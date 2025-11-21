/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/entities
/// 🎯 Feature: exercise_database
/// 🔧 Type: entity
///
/// Immutable entity representing a user-submitted exercise correction patch
///
/// **Lifecycle**:
/// 1. User submits patch → status: PENDING
/// 2. Applied locally to Hive (instant user feedback)
/// 3. Admin reviews → status: APPROVED or REJECTED
/// 4. If APPROVED → Cloud Function applies to Firestore
/// 5. Next publish → correction available to all users
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/enums/patch_status.dart';

part 'exercise_patch.freezed.dart';
part 'exercise_patch.g.dart';

@freezed
class ExercisePatch with _$ExercisePatch {
  const factory ExercisePatch({
    /// Unique patch ID (Firestore document ID)
    required String id,

    /// ID of the exercise being patched
    required String exerciseId,

    /// User ID who submitted the patch
    required String userId,

    /// Name of the field being modified (e.g., "nome", "difficolta", "noteTecniche")
    required String fieldName,

    /// Original value before user's modification (from Firestore)
    required dynamic oldValue,

    /// New value proposed by user
    required dynamic newValue,

    /// Server value at time of patch creation (for conflict detection)
    /// If this differs from current Firestore value, patch is stale
    required dynamic originalValue,

    /// User's explanation for the change (required, min 10 chars)
    required String reason,

    /// Current status of the patch
    required PatchStatus status,

    /// Language version ('it' or 'en')
    required String language,

    /// When patch was created
    required DateTime createdAt,

    /// When patch will expire (createdAt + 30 days)
    required DateTime expiresAt,

    /// Exercise version at time of patch creation
    /// Used to detect if exercise was updated before patch approval
    required int version,

    /// When patch was approved (null if not approved)
    DateTime? approvedAt,

    /// Admin user ID who approved the patch
    String? approvedBy,

    /// When patch was rejected (null if not rejected)
    DateTime? rejectedAt,

    /// Reason for rejection (null if approved or pending)
    String? rejectReason,

    /// Additional notes from admin
    String? adminNote,

    /// Whether patch was auto-expired by TTL cleanup (Cloud Function)
    @Default(false) bool autoExpired,

    /// User email (for admin notification)
    String? userEmail,

    /// User display name (for admin UI)
    String? userDisplayName,
  }) = _ExercisePatch;

  factory ExercisePatch.fromJson(Map<String, dynamic> json) =>
      _$ExercisePatchFromJson(json);
}

/// Extension methods for ExercisePatch
extension ExercisePatchX on ExercisePatch {
  /// Check if patch is still pending review
  bool get isPending => status == PatchStatus.pending;

  /// Check if patch was approved
  bool get isApproved => status == PatchStatus.approved;

  /// Check if patch was rejected (manual or auto)
  bool get isRejected =>
      status == PatchStatus.rejected || status == PatchStatus.autoRejected;

  /// Check if patch has expired
  bool get isExpired => status == PatchStatus.expired;

  /// Check if patch can still be approved by admin
  bool get isActionable => isPending && DateTime.now().isBefore(expiresAt);

  /// Check if patch is stale (originalValue != current server value)
  bool isStale(dynamic currentServerValue) {
    return originalValue != currentServerValue;
  }

  /// Days remaining before expiration
  int get daysUntilExpiration {
    if (isExpired || !isPending) return 0;
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return 0;
    return expiresAt.difference(now).inDays;
  }

  /// Human-readable description of the patch
  String get description {
    return 'Modifica campo "$fieldName": "$oldValue" → "$newValue"';
  }

  /// Firestore collection name based on language
  String get firestoreCollection => 'exercises_$language';
}
