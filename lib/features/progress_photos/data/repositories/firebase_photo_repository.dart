import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/repositories/progress_photo_repository.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/services/photo_compression_service.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart' as base;

/// FirebasePhotoRepository - Firebase implementation of photo storage
///
/// Storage Structure:
/// ```
/// Firebase Storage:
/// └── users/{userId}/progress_photos/
///     ├── {photoId}.webp           (full photo, ~200KB)
///     └── {photoId}_thumb.webp     (thumbnail, ~20KB)
///
/// Firestore:
/// └── users/{userId}/progress_photos/{photoId}
///     └── { ...ProgressPhoto metadata }
/// ```
class FirebasePhotoRepository
    with FirebaseErrorMapperMixin
    implements ProgressPhotoRepository {
  FirebasePhotoRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    PhotoCompressionService? compressionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _compressionService = compressionService ?? PhotoCompressionService();

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final PhotoCompressionService _compressionService;
  static const _uuid = Uuid();

  /// Stream controllers for upload progress
  final _uploadProgressControllers =
      <String, StreamController<PhotoUploadProgress>>{};

  /// Get Firestore collection reference for user's photos
  CollectionReference<Map<String, dynamic>> _photosCollection(String userId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('progress_photos');

  /// Get Storage reference for user's photos
  Reference _storageRef(String userId) =>
      _storage.ref().child('users').child(userId).child('progress_photos');

  /// Map base Failure to PhotoRepositoryFailure
  PhotoRepositoryFailure _mapToPhotoFailure(base.Failure failure) {
    if (failure is base.PermissionFailure) {
      return const PermissionDeniedFailure();
    } else if (failure is base.NotFoundFailure) {
      return NotFoundFailure(failure.message);
    } else if (failure is base.NetworkFailure) {
      return NetworkFailure(failure.message);
    } else if (failure is base.QuotaFailure) {
      return const QuotaExceededFailure(0, 0);
    } else if (failure is base.ValidationFailure) {
      return DatabaseFailure(failure.message);
    } else if (failure is base.ServerFailure) {
      // Storage errors come through as ServerFailure
      if (failure.code?.startsWith('storage/') ?? false) {
        return StorageFailure(failure.message, code: failure.code);
      }
      return DatabaseFailure(failure.message);
    } else {
      return UnknownFailure(failure.message, error: failure);
    }
  }

  @override
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> uploadPhoto({
    required String userId,
    required File imageFile,
    required PhotoPose pose,
    DateTime? takenAt,
    String? notes,
    double? weightKg,
  }) async {
    final photoId = _uuid.v4();
    final controller = StreamController<PhotoUploadProgress>.broadcast();
    _uploadProgressControllers[photoId] = controller;

    try {
      // Emit initial progress
      controller.add(PhotoUploadProgress(
        photoId: photoId,
        progress: 0.0,
        status: UploadStatus.compressing,
      ));

      // Step 1: Compress image (may throw CompressionException)
      final compressed =
          await _compressionService.compressAndSaveToTemp(imageFile);

      controller.add(PhotoUploadProgress(
        photoId: photoId,
        progress: 0.2,
        status: UploadStatus.uploading,
        totalBytes: compressed.totalSize,
      ));

      // Step 2-5: Handle all Firebase operations through mixin
      final result = await handleFirebaseOperation<ProgressPhoto>(
        () async {
          // Step 2: Generate storage paths
          final dateStr =
              DateFormat('yyyy-MM-dd').format(takenAt ?? DateTime.now());
          final poseName = pose.name;
          final fullPhotoPath = '$dateStr/${photoId}_$poseName.webp';
          final thumbPath = '$dateStr/${photoId}_${poseName}_thumb.webp';

          // Step 3: Upload full photo
          final fullPhotoRef = _storageRef(userId).child(fullPhotoPath);
          final fullUploadTask = fullPhotoRef.putData(
            compressed.fullPhotoBytes,
            SettableMetadata(
              contentType: 'image/webp',
              customMetadata: {
                'userId': userId,
                'photoId': photoId,
                'pose': poseName,
                'originalSize': compressed.originalSize.toString(),
              },
            ),
          );

          // Track upload progress
          fullUploadTask.snapshotEvents.listen((snapshot) {
            final progress =
                0.2 + (snapshot.bytesTransferred / snapshot.totalBytes) * 0.5;
            controller.add(PhotoUploadProgress(
              photoId: photoId,
              progress: progress,
              status: UploadStatus.uploading,
              bytesUploaded: snapshot.bytesTransferred,
              totalBytes: compressed.totalSize,
            ));
          });

          await fullUploadTask;
          final fullPhotoUrl = await fullPhotoRef.getDownloadURL();

          // Step 4: Upload thumbnail
          controller.add(PhotoUploadProgress(
            photoId: photoId,
            progress: 0.7,
            status: UploadStatus.uploading,
            bytesUploaded: compressed.compressedSize,
            totalBytes: compressed.totalSize,
          ));

          final thumbRef = _storageRef(userId).child(thumbPath);
          await thumbRef.putData(
            compressed.thumbnailBytes,
            SettableMetadata(contentType: 'image/webp'),
          );
          final thumbUrl = await thumbRef.getDownloadURL();

          // Step 5: Create Firestore document
          controller.add(PhotoUploadProgress(
            photoId: photoId,
            progress: 0.9,
            status: UploadStatus.uploading,
          ));

          final now = DateTime.now();
          final photo = ProgressPhoto(
            id: photoId,
            userId: userId,
            photoUrl: fullPhotoUrl,
            thumbnailUrl: thumbUrl,
            storagePath: fullPhotoPath,
            thumbnailStoragePath: thumbPath,
            pose: pose,
            takenAt: takenAt ?? now,
            fileSizeBytes: compressed.compressedSize,
            originalFileSizeBytes: compressed.originalSize,
            notes: notes,
            weightKg: weightKg,
            createdAt: now,
            updatedAt: now,
            syncStatus: SyncStatus.synced,
          );

          await _photosCollection(userId).doc(photoId).set(photo.toJson());

          // Cleanup temp files
          await compressed.cleanup();

          // Emit completion
          controller.add(PhotoUploadProgress(
            photoId: photoId,
            progress: 1.0,
            status: UploadStatus.completed,
          ));

          return photo;
        },
        operationName: 'uploadPhoto',
      );

      return result.fold(
        (failure) {
          controller.add(PhotoUploadProgress(
            photoId: photoId,
            progress: 0,
            status: UploadStatus.failed,
            errorMessage: failure.message,
          ));
          return left(_mapToPhotoFailure(failure));
        },
        (photo) => right(photo),
      );
    } on CompressionException catch (e) {
      // CompressionException is not a Firebase error, handle separately
      controller.add(PhotoUploadProgress(
        photoId: photoId,
        progress: 0,
        status: UploadStatus.failed,
        errorMessage: e.message,
      ));
      return left(CompressionFailure(e.message));
    } catch (e) {
      // Fallback for any other unexpected errors
      controller.add(PhotoUploadProgress(
        photoId: photoId,
        progress: 0,
        status: UploadStatus.failed,
        errorMessage: e.toString(),
      ));
      return left(UnknownFailure(e.toString(), error: e));
    } finally {
      await controller.close();
      _uploadProgressControllers.remove(photoId);
    }
  }

  @override
  Stream<PhotoUploadProgress> watchUploadProgress(String photoId) {
    final controller = _uploadProgressControllers[photoId];
    if (controller == null) {
      return Stream.value(PhotoUploadProgress(
        photoId: photoId,
        progress: 0,
        status: UploadStatus.pending,
      ));
    }
    return controller.stream;
  }

  @override
  Future<Either<PhotoRepositoryFailure, List<ProgressPhoto>>> getPhotos({
    required String userId,
    bool includeDeleted = false,
  }) async {
    final result = await handleFirebaseOperation<List<ProgressPhoto>>(
      () async {
        var query =
            _photosCollection(userId).orderBy('takenAt', descending: true);

        if (!includeDeleted) {
          query = query.where('isDeleted', isEqualTo: false);
        }

        final snapshot = await query.get();
        return snapshot.docs
            .map((doc) => ProgressPhoto.fromJson(doc.data()))
            .toList();
      },
      operationName: 'getPhotos',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (photos) => right(photos),
    );
  }

  @override
  Stream<List<ProgressPhoto>> watchPhotos({
    required String userId,
    bool includeDeleted = false,
  }) {
    var query = _photosCollection(userId).orderBy('takenAt', descending: true);

    if (!includeDeleted) {
      query = query.where('isDeleted', isEqualTo: false);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProgressPhoto.fromJson(doc.data())).toList());
  }

  @override
  Future<Either<PhotoRepositoryFailure, List<ProgressPhoto>>> getPhotosByPose({
    required String userId,
    required PhotoPose pose,
  }) async {
    final result = await handleFirebaseOperation<List<ProgressPhoto>>(
      () async {
        final snapshot = await _photosCollection(userId)
            .where('pose', isEqualTo: pose.name)
            .where('isDeleted', isEqualTo: false)
            .orderBy('takenAt', descending: true)
            .get();

        return snapshot.docs
            .map((doc) => ProgressPhoto.fromJson(doc.data()))
            .toList();
      },
      operationName: 'getPhotosByPose',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (photos) => right(photos),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, List<ProgressPhoto>>> getPhotosInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await handleFirebaseOperation<List<ProgressPhoto>>(
      () async {
        final snapshot = await _photosCollection(userId)
            .where('takenAt',
                isGreaterThanOrEqualTo: startDate.toIso8601String())
            .where('takenAt', isLessThanOrEqualTo: endDate.toIso8601String())
            .where('isDeleted', isEqualTo: false)
            .orderBy('takenAt', descending: true)
            .get();

        return snapshot.docs
            .map((doc) => ProgressPhoto.fromJson(doc.data()))
            .toList();
      },
      operationName: 'getPhotosInRange',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (photos) => right(photos),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> getPhoto({
    required String userId,
    required String photoId,
  }) async {
    final result = await handleFirebaseOperation<ProgressPhoto>(
      () async {
        final doc = await _photosCollection(userId).doc(photoId).get();

        if (!doc.exists) {
          throw base.NotFoundFailure('Photo not found: $photoId');
        }

        return ProgressPhoto.fromJson(doc.data()!);
      },
      operationName: 'getPhoto',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (photo) => right(photo),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> updatePhoto({
    required String userId,
    required String photoId,
    String? notes,
    double? weightKg,
    PhotoPose? pose,
  }) async {
    final result = await handleFirebaseOperation<ProgressPhoto>(
      () async {
        final updates = <String, dynamic>{
          'updatedAt': DateTime.now().toIso8601String(),
        };

        if (notes != null) updates['notes'] = notes;
        if (weightKg != null) updates['weightKg'] = weightKg;
        if (pose != null) updates['pose'] = pose.name;

        await _photosCollection(userId).doc(photoId).update(updates);

        // Get updated photo
        final getResult = await getPhoto(userId: userId, photoId: photoId);
        return getResult.fold(
          (failure) => throw base.ServerFailure(failure.toString()),
          (photo) => photo,
        );
      },
      operationName: 'updatePhoto',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (photo) => right(photo),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, Unit>> softDeletePhoto({
    required String userId,
    required String photoId,
  }) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        await _photosCollection(userId).doc(photoId).update({
          'isDeleted': true,
          'deletedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      },
      operationName: 'softDeletePhoto',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (unit) => right(unit),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, Unit>> permanentlyDeletePhoto({
    required String userId,
    required String photoId,
  }) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        // Get photo to find storage paths
        final photoResult = await getPhoto(userId: userId, photoId: photoId);

        await photoResult.fold(
          (failure) => throw base.ServerFailure(failure.toString()),
          (photo) async {
            // Delete from Storage
            try {
              await _storageRef(userId).child(photo.storagePath).delete();
              await _storageRef(userId)
                  .child(photo.thumbnailStoragePath)
                  .delete();
            } catch (_) {
              // Ignore storage errors (file might already be deleted)
            }

            // Delete from Firestore
            await _photosCollection(userId).doc(photoId).delete();
          },
        );
      },
      operationName: 'permanentlyDeletePhoto',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (unit) => right(unit),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> restorePhoto({
    required String userId,
    required String photoId,
  }) async {
    final result = await handleFirebaseOperation<ProgressPhoto>(
      () async {
        await _photosCollection(userId).doc(photoId).update({
          'isDeleted': false,
          'deletedAt': null,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Get restored photo
        final getResult = await getPhoto(userId: userId, photoId: photoId);
        return getResult.fold(
          (failure) => throw base.ServerFailure(failure.toString()),
          (photo) => photo,
        );
      },
      operationName: 'restorePhoto',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (photo) => right(photo),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, int>> deleteAllPhotos({
    required String userId,
  }) async {
    final result = await handleFirebaseOperation<int>(
      () async {
        // Get all photos
        final photosResult =
            await getPhotos(userId: userId, includeDeleted: true);

        return await photosResult.fold(
          (failure) => throw base.ServerFailure(failure.toString()),
          (photos) async {
            // Delete all storage files
            for (final photo in photos) {
              try {
                await _storageRef(userId).child(photo.storagePath).delete();
                await _storageRef(userId)
                    .child(photo.thumbnailStoragePath)
                    .delete();
              } catch (_) {
                // Continue even if some files fail
              }
            }

            // Delete all Firestore documents
            final batch = _firestore.batch();
            for (final photo in photos) {
              batch.delete(_photosCollection(userId).doc(photo.id));
            }
            await batch.commit();

            return photos.length;
          },
        );
      },
      operationName: 'deleteAllPhotos',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (deletedCount) => right(deletedCount),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> shareWithCoach({
    required String userId,
    required String photoId,
    required String coachId,
  }) async {
    final result = await handleFirebaseOperation<ProgressPhoto>(
      () async {
        await _photosCollection(userId).doc(photoId).update({
          'isSharedWithCoach': true,
          'sharedWithCoachId': coachId,
          'sharedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Get updated photo
        final getResult = await getPhoto(userId: userId, photoId: photoId);
        return getResult.fold(
          (failure) => throw base.ServerFailure(failure.toString()),
          (photo) => photo,
        );
      },
      operationName: 'shareWithCoach',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (photo) => right(photo),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, ProgressPhoto>> revokeCoachSharing({
    required String userId,
    required String photoId,
  }) async {
    final result = await handleFirebaseOperation<ProgressPhoto>(
      () async {
        await _photosCollection(userId).doc(photoId).update({
          'isSharedWithCoach': false,
          'sharedWithCoachId': null,
          'sharedAt': null,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Get updated photo
        final getResult = await getPhoto(userId: userId, photoId: photoId);
        return getResult.fold(
          (failure) => throw base.ServerFailure(failure.toString()),
          (photo) => photo,
        );
      },
      operationName: 'revokeCoachSharing',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (photo) => right(photo),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, List<ProgressPhoto>>>
      getSharedPhotosForCoach({
    required String coachId,
    required String athleteId,
  }) async {
    final result = await handleFirebaseOperation<List<ProgressPhoto>>(
      () async {
        final snapshot = await _photosCollection(athleteId)
            .where('isSharedWithCoach', isEqualTo: true)
            .where('sharedWithCoachId', isEqualTo: coachId)
            .where('isDeleted', isEqualTo: false)
            .orderBy('takenAt', descending: true)
            .get();

        return snapshot.docs
            .map((doc) => ProgressPhoto.fromJson(doc.data()))
            .toList();
      },
      operationName: 'getSharedPhotosForCoach',
    );

    return result.fold(
      (failure) => left(_mapToPhotoFailure(failure)),
      (photos) => right(photos),
    );
  }

  @override
  Future<Either<PhotoRepositoryFailure, PhotoStorageStats>> getStorageStats({
    required String userId,
  }) async {
    // getPhotos already uses handleFirebaseOperation, so we just need
    // to handle the stats calculation
    final photosResult = await getPhotos(userId: userId);

    return photosResult.fold(
      (failure) => left(failure),
      (photos) {
        int totalBytes = 0;
        int thumbnailBytes = 0;

        for (final photo in photos) {
          totalBytes += photo.fileSizeBytes;
          // Estimate thumbnail size as ~10% of full photo
          thumbnailBytes += (photo.fileSizeBytes * 0.1).round();
        }

        return right(PhotoStorageStats(
          totalPhotos: photos.length,
          totalBytes: totalBytes + thumbnailBytes,
          thumbnailBytes: thumbnailBytes,
          fullPhotoBytes: totalBytes,
        ));
      },
    );
  }
}
