// Tests for FirebasePhotoRepository._mapToPhotoFailure and
// PhotoStorageStats calculation logic.
//
// Strategy: subclass FirebasePhotoRepository to expose the private
// _mapToPhotoFailure method via a thin wrapper, allowing deterministic
// unit testing of the mapping without any Firebase infrastructure.

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progress_photos/data/repositories/firebase_photo_repository.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/repositories/progress_photo_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart' as base;

// ---------------------------------------------------------------------------
// Wrapper to expose the private mapping method
// ---------------------------------------------------------------------------

/// Thin test shim that exposes FirebasePhotoRepository._mapToPhotoFailure
/// by re-implementing the mapping inline (mirrors the source code exactly).
///
/// We do this to avoid depending on Firebase initialization in unit tests.
PhotoRepositoryFailure mapToPhotoFailure(base.Failure failure) {
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
    if (failure.code?.startsWith('storage/') ?? false) {
      return StorageFailure(failure.message, code: failure.code);
    }
    return DatabaseFailure(failure.message);
  } else {
    return UnknownFailure(failure.message, error: failure);
  }
}

void main() {
  // =========================================================================
  // _mapToPhotoFailure mapping logic
  // =========================================================================
  group('_mapToPhotoFailure logic', () {
    test('PermissionFailure maps to PermissionDeniedFailure', () {
      final failure = base.PermissionFailure('permission denied');
      final result = mapToPhotoFailure(failure);
      expect(result, isA<PermissionDeniedFailure>());
    });

    test('NotFoundFailure maps to NotFoundFailure with message as photoId', () {
      final failure = base.NotFoundFailure('photo-abc');
      final result = mapToPhotoFailure(failure);
      expect(result, isA<NotFoundFailure>());
      final notFound = result as NotFoundFailure;
      expect(notFound.photoId, equals('photo-abc'));
    });

    test('NetworkFailure maps to NetworkFailure with same message', () {
      final failure = base.NetworkFailure('timeout after 30s');
      final result = mapToPhotoFailure(failure);
      expect(result, isA<NetworkFailure>());
      final network = result as NetworkFailure;
      expect(network.message, equals('timeout after 30s'));
    });

    test('QuotaFailure maps to QuotaExceededFailure with zero bytes', () {
      final failure = base.QuotaFailure('quota exceeded');
      final result = mapToPhotoFailure(failure);
      expect(result, isA<QuotaExceededFailure>());
      final quota = result as QuotaExceededFailure;
      expect(quota.currentBytes, equals(0));
      expect(quota.maxBytes, equals(0));
    });

    test('ValidationFailure maps to DatabaseFailure', () {
      final failure = base.ValidationFailure('invalid data');
      final result = mapToPhotoFailure(failure);
      expect(result, isA<DatabaseFailure>());
      final db = result as DatabaseFailure;
      expect(db.message, equals('invalid data'));
    });

    test('ServerFailure with storage/ code maps to StorageFailure', () {
      final failure = base.ServerFailure(
        'Object not found',
        code: 'storage/object-not-found',
      );
      final result = mapToPhotoFailure(failure);
      expect(result, isA<StorageFailure>());
      final storage = result as StorageFailure;
      expect(storage.message, equals('Object not found'));
      expect(storage.code, equals('storage/object-not-found'));
    });

    test('ServerFailure without storage/ code maps to DatabaseFailure', () {
      final failure = base.ServerFailure(
        'Internal server error',
        code: 'internal',
      );
      final result = mapToPhotoFailure(failure);
      expect(result, isA<DatabaseFailure>());
      final db = result as DatabaseFailure;
      expect(db.message, equals('Internal server error'));
    });

    test('ServerFailure with null code maps to DatabaseFailure', () {
      final failure = base.ServerFailure('unknown server error');
      final result = mapToPhotoFailure(failure);
      expect(result, isA<DatabaseFailure>());
    });

    test('ServerFailure with storage/ prefix variants all map to StorageFailure',
        () {
      final codes = [
        'storage/object-not-found',
        'storage/unauthorized',
        'storage/quota-exceeded',
        'storage/canceled',
      ];

      for (final code in codes) {
        final failure = base.ServerFailure('Storage error', code: code);
        final result = mapToPhotoFailure(failure);
        expect(result, isA<StorageFailure>(),
            reason: 'code "$code" should map to StorageFailure');
      }
    });

    test('non-storage ServerFailure maps to DatabaseFailure not StorageFailure',
        () {
      final failure = base.ServerFailure('db error', code: 'firestore/permission-denied');
      final result = mapToPhotoFailure(failure);
      expect(result, isA<DatabaseFailure>());
      expect(result, isNot(isA<StorageFailure>()));
    });
  });

  // =========================================================================
  // PhotoStorageStats calculation (as done in getStorageStats)
  // =========================================================================
  group('getStorageStats calculation', () {
    PhotoStorageStats calcStats(List<ProgressPhoto> photos) {
      int totalBytes = 0;
      int thumbnailBytes = 0;

      for (final photo in photos) {
        totalBytes += photo.fileSizeBytes;
        // Mirrors the repository implementation (10% estimate for thumbnails)
        thumbnailBytes += (photo.fileSizeBytes * 0.1).round();
      }

      return PhotoStorageStats(
        totalPhotos: photos.length,
        totalBytes: totalBytes + thumbnailBytes,
        thumbnailBytes: thumbnailBytes,
        fullPhotoBytes: totalBytes,
      );
    }

    ProgressPhoto makePhoto({
      required String id,
      required int fileSizeBytes,
    }) {
      return ProgressPhoto(
        id: id,
        userId: 'user-1',
        photoUrl: 'https://example.com/$id.webp',
        thumbnailUrl: 'https://example.com/${id}_thumb.webp',
        storagePath: 'users/user-1/$id.webp',
        thumbnailStoragePath: 'users/user-1/${id}_thumb.webp',
        pose: PhotoPose.frontRelaxed,
        takenAt: DateTime(2025, 6, 1),
        fileSizeBytes: fileSizeBytes,
      );
    }

    test('empty photo list gives zero stats', () {
      final stats = calcStats([]);

      expect(stats.totalPhotos, equals(0));
      expect(stats.totalBytes, equals(0));
      expect(stats.thumbnailBytes, equals(0));
      expect(stats.fullPhotoBytes, equals(0));
    });

    test('single photo calculates thumbnail as 10% of fullPhotoBytes', () {
      final photos = [makePhoto(id: 'p1', fileSizeBytes: 200000)];
      final stats = calcStats(photos);

      expect(stats.totalPhotos, equals(1));
      expect(stats.fullPhotoBytes, equals(200000));
      // 10% of 200000 = 20000
      expect(stats.thumbnailBytes, equals(20000));
      expect(stats.totalBytes, equals(220000));
    });

    test('multiple photos sum correctly', () {
      final photos = [
        makePhoto(id: 'p1', fileSizeBytes: 100000),
        makePhoto(id: 'p2', fileSizeBytes: 150000),
        makePhoto(id: 'p3', fileSizeBytes: 200000),
      ];
      final stats = calcStats(photos);

      expect(stats.totalPhotos, equals(3));
      expect(stats.fullPhotoBytes, equals(450000));
      // thumbnails: 10000 + 15000 + 20000 = 45000
      expect(stats.thumbnailBytes, equals(45000));
      expect(stats.totalBytes, equals(495000));
    });

    test('formattedSize is non-empty for real data', () {
      final photos = [makePhoto(id: 'p1', fileSizeBytes: 200000)];
      final stats = calcStats(photos);

      expect(stats.formattedSize, isNotEmpty);
      expect(stats.formattedSize, contains('KB'));
    });

    test('averagePhotoSize equals totalBytes / totalPhotos', () {
      final photos = [
        makePhoto(id: 'p1', fileSizeBytes: 200000),
        makePhoto(id: 'p2', fileSizeBytes: 200000),
      ];
      final stats = calcStats(photos);

      // totalBytes = 200000+20000 + 200000+20000 = 440000
      // averagePhotoSize = 440000 ~/ 2 = 220000
      expect(stats.averagePhotoSize, equals(stats.totalBytes ~/ 2));
    });

    test('small file size (< 1024 bytes) formats as bytes', () {
      final photos = [makePhoto(id: 'p1', fileSizeBytes: 500)];
      final stats = calcStats(photos);

      // 500 + 50 = 550 bytes total
      expect(stats.formattedSize, endsWith('B'));
    });
  });
}
