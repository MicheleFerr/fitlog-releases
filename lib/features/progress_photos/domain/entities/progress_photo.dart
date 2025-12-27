import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_photo.freezed.dart';
part 'progress_photo.g.dart';

/// ProgressPhoto - Domain entity for user progress photos
///
/// Represents a single progress photo with full GDPR compliance metadata.
/// Photos are stored compressed as WebP in Firebase Storage.
///
/// Features:
/// - Immutable with freezed
/// - JSON serialization for Firestore sync
/// - Coach sharing support with granular consent
/// - Soft-delete with retention period
///
/// Example:
/// ```dart
/// final photo = ProgressPhoto(
///   id: 'uuid-123',
///   userId: 'user-456',
///   photoUrl: 'https://storage.firebase.com/...',
///   thumbnailUrl: 'https://storage.firebase.com/...',
///   pose: PhotoPose.front,
///   takenAt: DateTime.now(),
///   notes: 'Week 4 progress',
/// );
/// ```
@freezed
abstract class ProgressPhoto with _$ProgressPhoto {
  const factory ProgressPhoto({
    /// Unique identifier (UUID v4)
    required String id,

    /// User ID (Firebase Auth UID)
    /// GDPR: Required for data isolation and deletion
    required String userId,

    /// Firebase Storage URL for full-size photo (WebP, ~200KB)
    required String photoUrl,

    /// Firebase Storage URL for thumbnail (~20KB, 200x200)
    required String thumbnailUrl,

    /// Storage path in Firebase Storage (for deletion)
    /// Example: "users/{userId}/progress_photos/2025-01-15_front.webp"
    required String storagePath,

    /// Storage path for thumbnail
    required String thumbnailStoragePath,

    /// Pose/angle of the photo
    required PhotoPose pose,

    /// When the photo was taken (user's local time)
    required DateTime takenAt,

    /// File size in bytes (compressed WebP)
    required int fileSizeBytes,

    /// Original file size before compression (for stats)
    int? originalFileSizeBytes,

    /// Optional user notes (max 500 characters)
    String? notes,

    /// Optional body weight at time of photo (kg)
    double? weightKg,

    /// When this photo was created in the app
    DateTime? createdAt,

    /// When this photo was last modified
    DateTime? updatedAt,

    /// Whether this photo is shared with coach
    /// GDPR: Requires explicit consent
    @Default(false) bool isSharedWithCoach,

    /// Coach ID if shared (null if not shared)
    String? sharedWithCoachId,

    /// When sharing was enabled
    DateTime? sharedAt,

    /// Whether this photo is marked for deletion
    /// GDPR: Soft-delete with 30-day retention
    @Default(false) bool isDeleted,

    /// When this photo was soft-deleted
    DateTime? deletedAt,

    /// Sync status with cloud
    @Default(SyncStatus.pending) SyncStatus syncStatus,
  }) = _ProgressPhoto;

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) =>
      _$ProgressPhotoFromJson(json);
}

/// PhotoPose - Standard poses for progress photos
///
/// Based on fitness industry standard progress photo angles:
/// - Front relaxed: Arms at sides, facing camera
/// - Front flexed: Double biceps pose facing camera
/// - Side (left/right): Profile view
/// - Back relaxed: Arms at sides, back to camera
/// - Back flexed: Double biceps from behind
enum PhotoPose {
  /// Front view, relaxed stance
  frontRelaxed,

  /// Front view, flexed (double biceps)
  frontFlexed,

  /// Left side profile
  sideLeft,

  /// Right side profile
  sideRight,

  /// Back view, relaxed stance
  backRelaxed,

  /// Back view, flexed (double biceps)
  backFlexed,

  /// Custom/other pose
  other;

  /// Human-readable label for the pose
  String get label {
    switch (this) {
      case PhotoPose.frontRelaxed:
        return 'Front (Relaxed)';
      case PhotoPose.frontFlexed:
        return 'Front (Flexed)';
      case PhotoPose.sideLeft:
        return 'Side (Left)';
      case PhotoPose.sideRight:
        return 'Side (Right)';
      case PhotoPose.backRelaxed:
        return 'Back (Relaxed)';
      case PhotoPose.backFlexed:
        return 'Back (Flexed)';
      case PhotoPose.other:
        return 'Other';
    }
  }

  /// Icon name for the pose (Material icon)
  String get iconName {
    switch (this) {
      case PhotoPose.frontRelaxed:
      case PhotoPose.frontFlexed:
        return 'person';
      case PhotoPose.sideLeft:
      case PhotoPose.sideRight:
        return 'person_outline';
      case PhotoPose.backRelaxed:
      case PhotoPose.backFlexed:
        return 'person_off';
      case PhotoPose.other:
        return 'photo_camera';
    }
  }
}

/// SyncStatus - Tracks synchronization state with Firebase
enum SyncStatus {
  /// Not yet synced to Firebase
  pending,

  /// Currently uploading to Firebase Storage
  uploading,

  /// Successfully synced to Firebase
  synced,

  /// Sync failed (network error, permission denied, etc.)
  failed;
}

/// PhotoUploadProgress - Tracks upload progress
@freezed
abstract class PhotoUploadProgress with _$PhotoUploadProgress {
  const factory PhotoUploadProgress({
    /// Photo being uploaded
    required String photoId,

    /// Upload progress (0.0 - 1.0)
    required double progress,

    /// Current status
    required UploadStatus status,

    /// Error message if failed
    String? errorMessage,

    /// Bytes uploaded so far
    @Default(0) int bytesUploaded,

    /// Total bytes to upload
    @Default(0) int totalBytes,
  }) = _PhotoUploadProgress;

  factory PhotoUploadProgress.fromJson(Map<String, dynamic> json) =>
      _$PhotoUploadProgressFromJson(json);
}

/// UploadStatus - Status of photo upload
enum UploadStatus {
  /// Waiting to start
  pending,

  /// Compressing image
  compressing,

  /// Uploading to Firebase Storage
  uploading,

  /// Upload completed successfully
  completed,

  /// Upload failed
  failed,

  /// Upload cancelled by user
  cancelled;
}

/// PhotoComparisonPair - Two photos for comparison
@freezed
abstract class PhotoComparisonPair with _$PhotoComparisonPair {
  const factory PhotoComparisonPair({
    /// Earlier photo (before)
    required ProgressPhoto before,

    /// Later photo (after)
    required ProgressPhoto after,

    /// Days between photos
    required int daysBetween,

    /// Weight change in kg (if both have weight data)
    double? weightChangeKg,
  }) = _PhotoComparisonPair;

  factory PhotoComparisonPair.fromJson(Map<String, dynamic> json) =>
      _$PhotoComparisonPairFromJson(json);
}
