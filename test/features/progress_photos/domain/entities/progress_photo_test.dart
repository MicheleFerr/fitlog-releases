import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared test fixtures
  // ---------------------------------------------------------------------------

  final baseDate = DateTime(2025, 6, 15, 10, 30);

  ProgressPhoto makePhoto({
    String id = 'photo-001',
    String userId = 'user-abc',
    String photoUrl = 'https://storage.example.com/photo.webp',
    String thumbnailUrl = 'https://storage.example.com/photo_thumb.webp',
    String storagePath = 'users/user-abc/progress_photos/2025-06-15_front.webp',
    String thumbnailStoragePath =
        'users/user-abc/progress_photos/2025-06-15_front_thumb.webp',
    PhotoPose pose = PhotoPose.frontRelaxed,
    DateTime? takenAt,
    int fileSizeBytes = 150000,
    int? originalFileSizeBytes,
    String? notes,
    double? weightKg,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isSharedWithCoach = false,
    String? sharedWithCoachId,
    DateTime? sharedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    SyncStatus syncStatus = SyncStatus.pending,
  }) {
    return ProgressPhoto(
      id: id,
      userId: userId,
      photoUrl: photoUrl,
      thumbnailUrl: thumbnailUrl,
      storagePath: storagePath,
      thumbnailStoragePath: thumbnailStoragePath,
      pose: pose,
      takenAt: takenAt ?? baseDate,
      fileSizeBytes: fileSizeBytes,
      originalFileSizeBytes: originalFileSizeBytes,
      notes: notes,
      weightKg: weightKg,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSharedWithCoach: isSharedWithCoach,
      sharedWithCoachId: sharedWithCoachId,
      sharedAt: sharedAt,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      syncStatus: syncStatus,
    );
  }

  // ---------------------------------------------------------------------------
  // ProgressPhoto entity
  // ---------------------------------------------------------------------------

  group('ProgressPhoto', () {
    group('factory constructor', () {
      test('creates entity with required fields', () {
        final photo = makePhoto();

        expect(photo.id, equals('photo-001'));
        expect(photo.userId, equals('user-abc'));
        expect(
          photo.photoUrl,
          equals('https://storage.example.com/photo.webp'),
        );
        expect(
          photo.thumbnailUrl,
          equals('https://storage.example.com/photo_thumb.webp'),
        );
        expect(
          photo.storagePath,
          equals('users/user-abc/progress_photos/2025-06-15_front.webp'),
        );
        expect(
          photo.thumbnailStoragePath,
          equals('users/user-abc/progress_photos/2025-06-15_front_thumb.webp'),
        );
        expect(photo.pose, equals(PhotoPose.frontRelaxed));
        expect(photo.takenAt, equals(baseDate));
        expect(photo.fileSizeBytes, equals(150000));
      });

      test('applies default values for optional fields', () {
        final photo = makePhoto();

        expect(photo.isSharedWithCoach, isFalse);
        expect(photo.isDeleted, isFalse);
        expect(photo.syncStatus, equals(SyncStatus.pending));
        expect(photo.notes, isNull);
        expect(photo.weightKg, isNull);
        expect(photo.originalFileSizeBytes, isNull);
        expect(photo.createdAt, isNull);
        expect(photo.updatedAt, isNull);
        expect(photo.sharedWithCoachId, isNull);
        expect(photo.sharedAt, isNull);
        expect(photo.deletedAt, isNull);
      });

      test('stores optional fields when provided', () {
        final createdAt = DateTime(2025, 6, 15, 9, 0);
        final photo = makePhoto(
          notes: 'Week 4 progress',
          weightKg: 82.5,
          originalFileSizeBytes: 3500000,
          createdAt: createdAt,
          isSharedWithCoach: true,
          sharedWithCoachId: 'coach-xyz',
        );

        expect(photo.notes, equals('Week 4 progress'));
        expect(photo.weightKg, equals(82.5));
        expect(photo.originalFileSizeBytes, equals(3500000));
        expect(photo.createdAt, equals(createdAt));
        expect(photo.isSharedWithCoach, isTrue);
        expect(photo.sharedWithCoachId, equals('coach-xyz'));
      });
    });

    group('equality', () {
      test('two photos with same fields are equal', () {
        final a = makePhoto();
        final b = makePhoto();

        expect(a, equals(b));
      });

      test('two photos with different ids are not equal', () {
        final a = makePhoto(id: 'photo-001');
        final b = makePhoto(id: 'photo-002');

        expect(a, isNot(equals(b)));
      });

      test('two photos with different poses are not equal', () {
        final a = makePhoto(pose: PhotoPose.frontRelaxed);
        final b = makePhoto(pose: PhotoPose.backRelaxed);

        expect(a, isNot(equals(b)));
      });

      test('two photos with different syncStatus are not equal', () {
        final a = makePhoto(syncStatus: SyncStatus.pending);
        final b = makePhoto(syncStatus: SyncStatus.synced);

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('creates a copy with updated notes', () {
        final original = makePhoto();
        final updated = original.copyWith(notes: 'Updated notes');

        expect(updated.notes, equals('Updated notes'));
        expect(updated.id, equals(original.id));
        expect(updated.userId, equals(original.userId));
      });

      test('creates a copy with updated syncStatus', () {
        final original = makePhoto(syncStatus: SyncStatus.pending);
        final updated = original.copyWith(syncStatus: SyncStatus.synced);

        expect(updated.syncStatus, equals(SyncStatus.synced));
        expect(original.syncStatus, equals(SyncStatus.pending));
      });

      test('creates a copy marking photo as deleted', () {
        final deletedAt = DateTime(2025, 7, 1);
        final original = makePhoto();
        final deleted = original.copyWith(
          isDeleted: true,
          deletedAt: deletedAt,
        );

        expect(deleted.isDeleted, isTrue);
        expect(deleted.deletedAt, equals(deletedAt));
        expect(original.isDeleted, isFalse);
      });

      test('creates a copy sharing with coach', () {
        final sharedAt = DateTime(2025, 6, 20);
        final original = makePhoto();
        final shared = original.copyWith(
          isSharedWithCoach: true,
          sharedWithCoachId: 'coach-999',
          sharedAt: sharedAt,
        );

        expect(shared.isSharedWithCoach, isTrue);
        expect(shared.sharedWithCoachId, equals('coach-999'));
        expect(shared.sharedAt, equals(sharedAt));
      });

      test('original is unchanged after copyWith', () {
        final original = makePhoto(fileSizeBytes: 100000);
        final copy = original.copyWith(fileSizeBytes: 200000);

        expect(copy.fileSizeBytes, equals(200000));
        expect(original.fileSizeBytes, equals(100000));
      });
    });

    group('JSON serialization', () {
      test('serializes all required fields to JSON', () {
        final photo = makePhoto();
        final json = photo.toJson();

        expect(json['id'], equals('photo-001'));
        expect(json['userId'], equals('user-abc'));
        expect(
          json['photoUrl'],
          equals('https://storage.example.com/photo.webp'),
        );
        expect(
          json['thumbnailUrl'],
          equals('https://storage.example.com/photo_thumb.webp'),
        );
        expect(json['pose'], equals('frontRelaxed'));
        expect(json['fileSizeBytes'], equals(150000));
        expect(json['isSharedWithCoach'], isFalse);
        expect(json['isDeleted'], isFalse);
        expect(json['syncStatus'], equals('pending'));
      });

      test('deserializes from JSON back to same entity', () {
        final original = makePhoto(
          notes: 'Week 4',
          weightKg: 80.0,
          originalFileSizeBytes: 2000000,
          syncStatus: SyncStatus.synced,
        );

        final json = original.toJson();
        final restored = ProgressPhoto.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.userId, equals(original.userId));
        expect(restored.photoUrl, equals(original.photoUrl));
        expect(restored.thumbnailUrl, equals(original.thumbnailUrl));
        expect(restored.storagePath, equals(original.storagePath));
        expect(
          restored.thumbnailStoragePath,
          equals(original.thumbnailStoragePath),
        );
        expect(restored.pose, equals(original.pose));
        expect(restored.takenAt, equals(original.takenAt));
        expect(restored.fileSizeBytes, equals(original.fileSizeBytes));
        expect(restored.notes, equals(original.notes));
        expect(restored.weightKg, equals(original.weightKg));
        expect(
          restored.originalFileSizeBytes,
          equals(original.originalFileSizeBytes),
        );
        expect(restored.syncStatus, equals(original.syncStatus));
      });

      test('serializes null optional fields as null', () {
        final photo = makePhoto();
        final json = photo.toJson();

        expect(json['notes'], isNull);
        expect(json['weightKg'], isNull);
        expect(json['originalFileSizeBytes'], isNull);
        expect(json['createdAt'], isNull);
        expect(json['updatedAt'], isNull);
        expect(json['sharedWithCoachId'], isNull);
        expect(json['sharedAt'], isNull);
        expect(json['deletedAt'], isNull);
      });

      test('serializes all SyncStatus enum values', () {
        for (final status in SyncStatus.values) {
          final photo = makePhoto(syncStatus: status);
          final json = photo.toJson();
          final restored = ProgressPhoto.fromJson(json);
          expect(restored.syncStatus, equals(status));
        }
      });

      test('serializes all PhotoPose enum values', () {
        for (final pose in PhotoPose.values) {
          final photo = makePhoto(pose: pose);
          final json = photo.toJson();
          final restored = ProgressPhoto.fromJson(json);
          expect(restored.pose, equals(pose));
        }
      });

      test('fromJson uses pending syncStatus when field missing', () {
        final json = {
          'id': 'photo-001',
          'userId': 'user-abc',
          'photoUrl': 'https://example.com/photo.webp',
          'thumbnailUrl': 'https://example.com/thumb.webp',
          'storagePath': 'users/abc/photo.webp',
          'thumbnailStoragePath': 'users/abc/thumb.webp',
          'pose': 'frontRelaxed',
          'takenAt': '2025-06-15T10:30:00.000',
          'fileSizeBytes': 100000,
        };

        final photo = ProgressPhoto.fromJson(json);

        expect(photo.syncStatus, equals(SyncStatus.pending));
        expect(photo.isSharedWithCoach, isFalse);
        expect(photo.isDeleted, isFalse);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // PhotoPose enum
  // ---------------------------------------------------------------------------

  group('PhotoPose', () {
    group('label', () {
      test('frontRelaxed returns correct label', () {
        expect(PhotoPose.frontRelaxed.label, equals('Front (Relaxed)'));
      });

      test('frontFlexed returns correct label', () {
        expect(PhotoPose.frontFlexed.label, equals('Front (Flexed)'));
      });

      test('sideLeft returns correct label', () {
        expect(PhotoPose.sideLeft.label, equals('Side (Left)'));
      });

      test('sideRight returns correct label', () {
        expect(PhotoPose.sideRight.label, equals('Side (Right)'));
      });

      test('backRelaxed returns correct label', () {
        expect(PhotoPose.backRelaxed.label, equals('Back (Relaxed)'));
      });

      test('backFlexed returns correct label', () {
        expect(PhotoPose.backFlexed.label, equals('Back (Flexed)'));
      });

      test('other returns correct label', () {
        expect(PhotoPose.other.label, equals('Other'));
      });

      test('all enum values have non-empty labels', () {
        for (final pose in PhotoPose.values) {
          expect(
            pose.label,
            isNotEmpty,
            reason: '${pose.name} label should not be empty',
          );
        }
      });
    });

    group('iconName', () {
      test('frontRelaxed and frontFlexed share person icon', () {
        expect(PhotoPose.frontRelaxed.iconName, equals('person'));
        expect(PhotoPose.frontFlexed.iconName, equals('person'));
      });

      test('sideLeft and sideRight share person_outline icon', () {
        expect(PhotoPose.sideLeft.iconName, equals('person_outline'));
        expect(PhotoPose.sideRight.iconName, equals('person_outline'));
      });

      test('backRelaxed and backFlexed share person_off icon', () {
        expect(PhotoPose.backRelaxed.iconName, equals('person_off'));
        expect(PhotoPose.backFlexed.iconName, equals('person_off'));
      });

      test('other returns photo_camera icon', () {
        expect(PhotoPose.other.iconName, equals('photo_camera'));
      });

      test('all enum values have non-empty icon names', () {
        for (final pose in PhotoPose.values) {
          expect(
            pose.iconName,
            isNotEmpty,
            reason: '${pose.name} iconName should not be empty',
          );
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // SyncStatus enum
  // ---------------------------------------------------------------------------

  group('SyncStatus', () {
    test('has all expected values', () {
      expect(
        SyncStatus.values,
        containsAll([
          SyncStatus.pending,
          SyncStatus.uploading,
          SyncStatus.synced,
          SyncStatus.failed,
        ]),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // PhotoUploadProgress entity
  // ---------------------------------------------------------------------------

  group('PhotoUploadProgress', () {
    group('factory constructor', () {
      test('creates with required fields and defaults', () {
        const progress = PhotoUploadProgress(
          photoId: 'photo-001',
          progress: 0.5,
          status: UploadStatus.uploading,
        );

        expect(progress.photoId, equals('photo-001'));
        expect(progress.progress, equals(0.5));
        expect(progress.status, equals(UploadStatus.uploading));
        expect(progress.bytesUploaded, equals(0));
        expect(progress.totalBytes, equals(0));
        expect(progress.errorMessage, isNull);
      });

      test('stores error message when provided', () {
        const progress = PhotoUploadProgress(
          photoId: 'photo-001',
          progress: 0.0,
          status: UploadStatus.failed,
          errorMessage: 'Network timeout',
        );

        expect(progress.errorMessage, equals('Network timeout'));
      });

      test('stores upload progress bytes', () {
        const progress = PhotoUploadProgress(
          photoId: 'photo-001',
          progress: 0.75,
          status: UploadStatus.uploading,
          bytesUploaded: 150000,
          totalBytes: 200000,
        );

        expect(progress.bytesUploaded, equals(150000));
        expect(progress.totalBytes, equals(200000));
      });
    });

    group('equality', () {
      test('two identical progress objects are equal', () {
        const a = PhotoUploadProgress(
          photoId: 'photo-001',
          progress: 0.5,
          status: UploadStatus.uploading,
        );
        const b = PhotoUploadProgress(
          photoId: 'photo-001',
          progress: 0.5,
          status: UploadStatus.uploading,
        );

        expect(a, equals(b));
      });

      test('progress objects with different progress values are not equal', () {
        const a = PhotoUploadProgress(
          photoId: 'photo-001',
          progress: 0.5,
          status: UploadStatus.uploading,
        );
        const b = PhotoUploadProgress(
          photoId: 'photo-001',
          progress: 0.9,
          status: UploadStatus.uploading,
        );

        expect(a, isNot(equals(b)));
      });
    });

    group('JSON serialization', () {
      test('round-trips through JSON', () {
        const original = PhotoUploadProgress(
          photoId: 'photo-001',
          progress: 0.6,
          status: UploadStatus.uploading,
          bytesUploaded: 60000,
          totalBytes: 100000,
        );

        final json = original.toJson();
        final restored = PhotoUploadProgress.fromJson(json);

        expect(restored.photoId, equals(original.photoId));
        expect(restored.progress, equals(original.progress));
        expect(restored.status, equals(original.status));
        expect(restored.bytesUploaded, equals(original.bytesUploaded));
        expect(restored.totalBytes, equals(original.totalBytes));
      });

      test('serializes all UploadStatus values', () {
        for (final status in UploadStatus.values) {
          const progress = PhotoUploadProgress(
            photoId: 'test',
            progress: 0.0,
            status: UploadStatus.pending,
          );
          final updated = progress.copyWith(status: status);
          final json = updated.toJson();
          final restored = PhotoUploadProgress.fromJson(json);
          expect(restored.status, equals(status));
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // PhotoComparisonPair entity
  // ---------------------------------------------------------------------------

  group('PhotoComparisonPair', () {
    final beforeDate = DateTime(2025, 1, 1);
    final afterDate = DateTime(2025, 3, 1);

    final beforePhoto = ProgressPhoto(
      id: 'before-001',
      userId: 'user-abc',
      photoUrl: 'https://example.com/before.webp',
      thumbnailUrl: 'https://example.com/before_thumb.webp',
      storagePath: 'users/abc/before.webp',
      thumbnailStoragePath: 'users/abc/before_thumb.webp',
      pose: PhotoPose.frontRelaxed,
      takenAt: beforeDate,
      fileSizeBytes: 120000,
      weightKg: 85.0,
    );

    final afterPhoto = ProgressPhoto(
      id: 'after-001',
      userId: 'user-abc',
      photoUrl: 'https://example.com/after.webp',
      thumbnailUrl: 'https://example.com/after_thumb.webp',
      storagePath: 'users/abc/after.webp',
      thumbnailStoragePath: 'users/abc/after_thumb.webp',
      pose: PhotoPose.frontRelaxed,
      takenAt: afterDate,
      fileSizeBytes: 110000,
      weightKg: 80.0,
    );

    group('factory constructor', () {
      test('creates comparison pair with required fields', () {
        final pair = PhotoComparisonPair(
          before: beforePhoto,
          after: afterPhoto,
          daysBetween: 59,
        );

        expect(pair.before.id, equals('before-001'));
        expect(pair.after.id, equals('after-001'));
        expect(pair.daysBetween, equals(59));
        expect(pair.weightChangeKg, isNull);
      });

      test('stores weight change when provided', () {
        final pair = PhotoComparisonPair(
          before: beforePhoto,
          after: afterPhoto,
          daysBetween: 59,
          weightChangeKg: -5.0,
        );

        expect(pair.weightChangeKg, equals(-5.0));
      });
    });

    group('JSON serialization', () {
      test('round-trips through JSON including nested photos', () {
        final original = PhotoComparisonPair(
          before: beforePhoto,
          after: afterPhoto,
          daysBetween: 59,
          weightChangeKg: -5.0,
        );

        final json = original.toJson();
        final restored = PhotoComparisonPair.fromJson(json);

        expect(restored.before.id, equals(original.before.id));
        expect(restored.after.id, equals(original.after.id));
        expect(restored.daysBetween, equals(original.daysBetween));
        expect(restored.weightChangeKg, equals(original.weightChangeKg));
        expect(restored.before.takenAt, equals(original.before.takenAt));
        expect(restored.after.takenAt, equals(original.after.takenAt));
      });

      test('handles null weightChangeKg in JSON round-trip', () {
        final original = PhotoComparisonPair(
          before: beforePhoto,
          after: afterPhoto,
          daysBetween: 30,
        );

        final json = original.toJson();
        final restored = PhotoComparisonPair.fromJson(json);

        expect(restored.weightChangeKg, isNull);
      });
    });

    group('equality', () {
      test('two identical pairs are equal', () {
        final a = PhotoComparisonPair(
          before: beforePhoto,
          after: afterPhoto,
          daysBetween: 59,
        );
        final b = PhotoComparisonPair(
          before: beforePhoto,
          after: afterPhoto,
          daysBetween: 59,
        );

        expect(a, equals(b));
      });

      test('pairs with different daysBetween are not equal', () {
        final a = PhotoComparisonPair(
          before: beforePhoto,
          after: afterPhoto,
          daysBetween: 30,
        );
        final b = PhotoComparisonPair(
          before: beforePhoto,
          after: afterPhoto,
          daysBetween: 60,
        );

        expect(a, isNot(equals(b)));
      });
    });
  });

  // ---------------------------------------------------------------------------
  // UploadStatus enum
  // ---------------------------------------------------------------------------

  group('UploadStatus', () {
    test('has all expected values', () {
      expect(
        UploadStatus.values,
        containsAll([
          UploadStatus.pending,
          UploadStatus.compressing,
          UploadStatus.uploading,
          UploadStatus.completed,
          UploadStatus.failed,
          UploadStatus.cancelled,
        ]),
      );
    });
  });
}
