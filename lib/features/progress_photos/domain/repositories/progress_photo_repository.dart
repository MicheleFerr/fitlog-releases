import 'dart:io';

import 'package:fpdart/fpdart.dart';

import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';

/// ProgressPhotoRepository - Abstract interface for photo storage
///
/// Follows Clean Architecture principles:
/// - Domain layer defines the contract
/// - Data layer implements with Firebase Storage + Firestore
///
/// GDPR Compliance:
/// - All photos are isolated by userId
/// - Supports soft-delete with 30-day retention
/// - Supports complete data deletion on user request
abstract class ProgressPhotoRepository {
  /// Upload a new progress photo
  ///
  /// Steps:
  /// 1. Compress image to WebP
  /// 2. Generate thumbnail
  /// 3. Upload both to Firebase Storage
  /// 4. Save metadata to Firestore
  ///
  /// Returns [Right<ProgressPhoto>] on success
  /// Returns [Left<PhotoRepositoryFailure>] on error
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> uploadPhoto({
    required String userId,
    required File imageFile,
    required PhotoPose pose,
    DateTime? takenAt,
    String? notes,
    double? weightKg,
  });

  /// Stream of upload progress for a specific photo
  ///
  /// Emits [PhotoUploadProgress] updates during upload
  Stream<PhotoUploadProgress> watchUploadProgress(String photoId);

  /// Get all photos for a user
  ///
  /// Returns photos sorted by takenAt descending (newest first)
  /// Excludes soft-deleted photos unless [includeDeleted] is true
  Future<Either<PhotoRepositoryFailure, List<ProgressPhoto>>> getPhotos({
    required String userId,
    bool includeDeleted = false,
  });

  /// Stream of photos for real-time updates
  ///
  /// Emits new list whenever photos change
  Stream<List<ProgressPhoto>> watchPhotos({
    required String userId,
    bool includeDeleted = false,
  });

  /// Get photos filtered by pose
  ///
  /// Useful for comparison views (e.g., all front photos)
  Future<Either<PhotoRepositoryFailure, List<ProgressPhoto>>> getPhotosByPose({
    required String userId,
    required PhotoPose pose,
  });

  /// Get photos within a date range
  Future<Either<PhotoRepositoryFailure, List<ProgressPhoto>>> getPhotosInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get a single photo by ID
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> getPhoto({
    required String userId,
    required String photoId,
  });

  /// Update photo metadata (notes, weight, pose)
  ///
  /// Does NOT re-upload the image
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> updatePhoto({
    required String userId,
    required String photoId,
    String? notes,
    double? weightKg,
    PhotoPose? pose,
  });

  /// Soft-delete a photo
  ///
  /// GDPR: Photo is marked as deleted but retained for 30 days
  /// After 30 days, a Cloud Function permanently deletes it
  Future<Either<PhotoRepositoryFailure, Unit>> softDeletePhoto({
    required String userId,
    required String photoId,
  });

  /// Permanently delete a photo
  ///
  /// GDPR: Immediate permanent deletion on user request
  /// Removes from both Storage and Firestore
  Future<Either<PhotoRepositoryFailure, Unit>> permanentlyDeletePhoto({
    required String userId,
    required String photoId,
  });

  /// Restore a soft-deleted photo
  ///
  /// Only works within 30-day retention period
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> restorePhoto({
    required String userId,
    required String photoId,
  });

  /// Delete all photos for a user
  ///
  /// GDPR: Used when user requests complete data deletion
  Future<Either<PhotoRepositoryFailure, int>> deleteAllPhotos({
    required String userId,
  });

  /// Share photo with coach
  ///
  /// GDPR: Requires explicit consent (handled by UI)
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> shareWithCoach({
    required String userId,
    required String photoId,
    required String coachId,
  });

  /// Revoke coach sharing
  ///
  /// GDPR: User can revoke sharing at any time
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> revokeCoachSharing({
    required String userId,
    required String photoId,
  });

  /// Get photos shared with a specific coach
  ///
  /// Used by coach dashboard to view athlete photos
  Future<Either<PhotoRepositoryFailure, List<ProgressPhoto>>>
  getSharedPhotosForCoach({required String coachId, required String athleteId});

  /// Get storage usage for a user
  ///
  /// Returns total bytes used by all photos
  Future<Either<PhotoRepositoryFailure, PhotoStorageStats>> getStorageStats({
    required String userId,
  });
}

/// PhotoRepositoryFailure - Possible failure types
sealed class PhotoRepositoryFailure {
  const PhotoRepositoryFailure();
}

/// Network error (no internet, timeout, etc.)
class NetworkFailure extends PhotoRepositoryFailure {
  final String message;
  const NetworkFailure(this.message);
}

/// Firebase Storage error
class StorageFailure extends PhotoRepositoryFailure {
  final String message;
  final String? code;
  const StorageFailure(this.message, {this.code});
}

/// Firestore error
class DatabaseFailure extends PhotoRepositoryFailure {
  final String message;
  const DatabaseFailure(this.message);
}

/// Photo not found
class NotFoundFailure extends PhotoRepositoryFailure {
  final String photoId;
  const NotFoundFailure(this.photoId);
}

/// Permission denied (trying to access another user's photo)
class PermissionDeniedFailure extends PhotoRepositoryFailure {
  const PermissionDeniedFailure();
}

/// Image compression failed
class CompressionFailure extends PhotoRepositoryFailure {
  final String message;
  const CompressionFailure(this.message);
}

/// Storage quota exceeded
class QuotaExceededFailure extends PhotoRepositoryFailure {
  final int currentBytes;
  final int maxBytes;
  const QuotaExceededFailure(this.currentBytes, this.maxBytes);
}

/// Unknown error
class UnknownFailure extends PhotoRepositoryFailure {
  final String message;
  final Object? error;
  const UnknownFailure(this.message, {this.error});
}

/// PhotoStorageStats - Storage usage statistics
class PhotoStorageStats {
  final int totalPhotos;
  final int totalBytes;
  final int thumbnailBytes;
  final int fullPhotoBytes;

  const PhotoStorageStats({
    required this.totalPhotos,
    required this.totalBytes,
    required this.thumbnailBytes,
    required this.fullPhotoBytes,
  });

  /// Human-readable total size
  String get formattedSize {
    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Average size per photo
  int get averagePhotoSize => totalPhotos > 0 ? totalBytes ~/ totalPhotos : 0;
}
