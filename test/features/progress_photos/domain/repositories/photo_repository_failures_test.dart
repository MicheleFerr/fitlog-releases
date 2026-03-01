// Tests for all sealed failure classes and PhotoStorageStats
// in progress_photo_repository.dart.
//
// These are pure Dart classes with no Firebase dependencies,
// so they can be unit-tested without any mocking framework.

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/repositories/progress_photo_repository.dart';

void main() {
  // =========================================================================
  // NetworkFailure
  // =========================================================================
  group('NetworkFailure', () {
    test('stores message', () {
      const f = NetworkFailure('No internet connection');
      expect(f.message, equals('No internet connection'));
    });

    test('is a PhotoRepositoryFailure', () {
      const f = NetworkFailure('timeout');
      expect(f, isA<PhotoRepositoryFailure>());
    });

    test('two instances with same message are equal via identity check', () {
      const f1 = NetworkFailure('err');
      const f2 = NetworkFailure('err');
      // sealed class default equality: same runtime type & same fields iff const
      expect(f1 == f2, isTrue);
    });

    test('two instances with different messages are not equal', () {
      const f1 = NetworkFailure('timeout');
      const f2 = NetworkFailure('DNS error');
      expect(f1 == f2, isFalse);
    });
  });

  // =========================================================================
  // StorageFailure
  // =========================================================================
  group('StorageFailure', () {
    test('stores message', () {
      const f = StorageFailure('Upload failed');
      expect(f.message, equals('Upload failed'));
    });

    test('code is null when not provided', () {
      const f = StorageFailure('Error');
      expect(f.code, isNull);
    });

    test('stores code when provided', () {
      const f = StorageFailure('Object not found', code: 'storage/object-not-found');
      expect(f.code, equals('storage/object-not-found'));
    });

    test('is a PhotoRepositoryFailure', () {
      const f = StorageFailure('err');
      expect(f, isA<PhotoRepositoryFailure>());
    });
  });

  // =========================================================================
  // DatabaseFailure
  // =========================================================================
  group('DatabaseFailure', () {
    test('stores message', () {
      const f = DatabaseFailure('Firestore permission denied');
      expect(f.message, equals('Firestore permission denied'));
    });

    test('is a PhotoRepositoryFailure', () {
      const f = DatabaseFailure('err');
      expect(f, isA<PhotoRepositoryFailure>());
    });

    test('equal when message matches', () {
      const f1 = DatabaseFailure('same');
      const f2 = DatabaseFailure('same');
      expect(f1 == f2, isTrue);
    });
  });

  // =========================================================================
  // NotFoundFailure
  // =========================================================================
  group('NotFoundFailure', () {
    test('stores photoId', () {
      const f = NotFoundFailure('photo-123');
      expect(f.photoId, equals('photo-123'));
    });

    test('is a PhotoRepositoryFailure', () {
      const f = NotFoundFailure('photo-x');
      expect(f, isA<PhotoRepositoryFailure>());
    });

    test('two instances with different photoIds are not equal', () {
      const f1 = NotFoundFailure('photo-1');
      const f2 = NotFoundFailure('photo-2');
      expect(f1 == f2, isFalse);
    });
  });

  // =========================================================================
  // PermissionDeniedFailure
  // =========================================================================
  group('PermissionDeniedFailure', () {
    test('can be instantiated', () {
      const f = PermissionDeniedFailure();
      expect(f, isA<PermissionDeniedFailure>());
    });

    test('is a PhotoRepositoryFailure', () {
      const f = PermissionDeniedFailure();
      expect(f, isA<PhotoRepositoryFailure>());
    });

    test('two instances are equal (no fields)', () {
      const f1 = PermissionDeniedFailure();
      const f2 = PermissionDeniedFailure();
      expect(f1 == f2, isTrue);
    });
  });

  // =========================================================================
  // CompressionFailure
  // =========================================================================
  group('CompressionFailure', () {
    test('stores message', () {
      const f = CompressionFailure('Failed to compress image');
      expect(f.message, equals('Failed to compress image'));
    });

    test('is a PhotoRepositoryFailure', () {
      const f = CompressionFailure('err');
      expect(f, isA<PhotoRepositoryFailure>());
    });
  });

  // =========================================================================
  // QuotaExceededFailure
  // =========================================================================
  group('QuotaExceededFailure', () {
    test('stores currentBytes and maxBytes', () {
      const f = QuotaExceededFailure(1024 * 1024 * 500, 1024 * 1024 * 1024);
      expect(f.currentBytes, equals(1024 * 1024 * 500));
      expect(f.maxBytes, equals(1024 * 1024 * 1024));
    });

    test('is a PhotoRepositoryFailure', () {
      const f = QuotaExceededFailure(0, 0);
      expect(f, isA<PhotoRepositoryFailure>());
    });

    test('two instances with same values are equal', () {
      const f1 = QuotaExceededFailure(100, 200);
      const f2 = QuotaExceededFailure(100, 200);
      expect(f1 == f2, isTrue);
    });

    test('two instances with different values are not equal', () {
      const f1 = QuotaExceededFailure(100, 200);
      const f2 = QuotaExceededFailure(150, 200);
      expect(f1 == f2, isFalse);
    });
  });

  // =========================================================================
  // UnknownFailure
  // =========================================================================
  group('UnknownFailure', () {
    test('stores message', () {
      const f = UnknownFailure('Unexpected error');
      expect(f.message, equals('Unexpected error'));
    });

    test('error is null when not provided', () {
      const f = UnknownFailure('err');
      expect(f.error, isNull);
    });

    test('stores error object when provided', () {
      final err = Exception('something went wrong');
      final f = UnknownFailure('wrapped', error: err);
      expect(f.error, same(err));
    });

    test('is a PhotoRepositoryFailure', () {
      const f = UnknownFailure('err');
      expect(f, isA<PhotoRepositoryFailure>());
    });
  });

  // =========================================================================
  // PhotoStorageStats
  // =========================================================================
  group('PhotoStorageStats', () {
    group('constructor', () {
      test('stores all fields', () {
        const stats = PhotoStorageStats(
          totalPhotos: 10,
          totalBytes: 2 * 1024 * 1024,
          thumbnailBytes: 200 * 1024,
          fullPhotoBytes: 1800 * 1024,
        );

        expect(stats.totalPhotos, equals(10));
        expect(stats.totalBytes, equals(2 * 1024 * 1024));
        expect(stats.thumbnailBytes, equals(200 * 1024));
        expect(stats.fullPhotoBytes, equals(1800 * 1024));
      });
    });

    group('formattedSize', () {
      test('formats bytes correctly (< 1024)', () {
        const stats = PhotoStorageStats(
          totalPhotos: 1,
          totalBytes: 512,
          thumbnailBytes: 50,
          fullPhotoBytes: 462,
        );
        expect(stats.formattedSize, equals('512 B'));
      });

      test('formats kilobytes correctly', () {
        const stats = PhotoStorageStats(
          totalPhotos: 1,
          totalBytes: 204800, // 200 KB
          thumbnailBytes: 20000,
          fullPhotoBytes: 184800,
        );
        expect(stats.formattedSize, equals('200.0 KB'));
      });

      test('formats megabytes correctly', () {
        const stats = PhotoStorageStats(
          totalPhotos: 5,
          totalBytes: 3 * 1024 * 1024, // 3 MB
          thumbnailBytes: 300 * 1024,
          fullPhotoBytes: 2724 * 1024,
        );
        expect(stats.formattedSize, equals('3.0 MB'));
      });

      test('formats fractional megabytes correctly', () {
        const stats = PhotoStorageStats(
          totalPhotos: 3,
          totalBytes: 1572864, // 1.5 MB
          thumbnailBytes: 150000,
          fullPhotoBytes: 1422864,
        );
        expect(stats.formattedSize, equals('1.5 MB'));
      });

      test('formats exactly 1024 bytes as 1.0 KB', () {
        const stats = PhotoStorageStats(
          totalPhotos: 1,
          totalBytes: 1024,
          thumbnailBytes: 100,
          fullPhotoBytes: 924,
        );
        expect(stats.formattedSize, equals('1.0 KB'));
      });
    });

    group('averagePhotoSize', () {
      test('returns 0 when totalPhotos is 0', () {
        const stats = PhotoStorageStats(
          totalPhotos: 0,
          totalBytes: 0,
          thumbnailBytes: 0,
          fullPhotoBytes: 0,
        );
        expect(stats.averagePhotoSize, equals(0));
      });

      test('returns integer division of totalBytes by totalPhotos', () {
        const stats = PhotoStorageStats(
          totalPhotos: 4,
          totalBytes: 800000,
          thumbnailBytes: 80000,
          fullPhotoBytes: 720000,
        );
        // 800000 ~/ 4 = 200000
        expect(stats.averagePhotoSize, equals(200000));
      });

      test('truncates fractional result (integer division)', () {
        const stats = PhotoStorageStats(
          totalPhotos: 3,
          totalBytes: 1000000,
          thumbnailBytes: 100000,
          fullPhotoBytes: 900000,
        );
        // 1000000 ~/ 3 = 333333
        expect(stats.averagePhotoSize, equals(333333));
      });

      test('works with single photo', () {
        const stats = PhotoStorageStats(
          totalPhotos: 1,
          totalBytes: 150000,
          thumbnailBytes: 15000,
          fullPhotoBytes: 135000,
        );
        expect(stats.averagePhotoSize, equals(150000));
      });

      test('works with many photos', () {
        const stats = PhotoStorageStats(
          totalPhotos: 100,
          totalBytes: 20000000,
          thumbnailBytes: 2000000,
          fullPhotoBytes: 18000000,
        );
        expect(stats.averagePhotoSize, equals(200000));
      });
    });

    group('zero values', () {
      test('all-zero stats is valid', () {
        const stats = PhotoStorageStats(
          totalPhotos: 0,
          totalBytes: 0,
          thumbnailBytes: 0,
          fullPhotoBytes: 0,
        );
        expect(stats.formattedSize, equals('0 B'));
        expect(stats.averagePhotoSize, equals(0));
      });
    });
  });

  // =========================================================================
  // Failure type hierarchy – pattern matching
  // =========================================================================
  group('PhotoRepositoryFailure sealed type matching', () {
    PhotoRepositoryFailure makeNetworkFailure() =>
        const NetworkFailure('net error');
    PhotoRepositoryFailure makeStorageFailure() =>
        const StorageFailure('storage error');
    PhotoRepositoryFailure makeDatabaseFailure() =>
        const DatabaseFailure('db error');
    PhotoRepositoryFailure makeNotFoundFailure() =>
        const NotFoundFailure('photo-x');
    PhotoRepositoryFailure makePermissionFailure() =>
        const PermissionDeniedFailure();
    PhotoRepositoryFailure makeCompressionFailure() =>
        const CompressionFailure('comp error');
    PhotoRepositoryFailure makeQuotaFailure() =>
        const QuotaExceededFailure(100, 200);
    PhotoRepositoryFailure makeUnknownFailure() =>
        const UnknownFailure('unknown');

    test('all failure subtypes are PhotoRepositoryFailure', () {
      expect(makeNetworkFailure(), isA<PhotoRepositoryFailure>());
      expect(makeStorageFailure(), isA<PhotoRepositoryFailure>());
      expect(makeDatabaseFailure(), isA<PhotoRepositoryFailure>());
      expect(makeNotFoundFailure(), isA<PhotoRepositoryFailure>());
      expect(makePermissionFailure(), isA<PhotoRepositoryFailure>());
      expect(makeCompressionFailure(), isA<PhotoRepositoryFailure>());
      expect(makeQuotaFailure(), isA<PhotoRepositoryFailure>());
      expect(makeUnknownFailure(), isA<PhotoRepositoryFailure>());
    });

    test('NetworkFailure is only NetworkFailure', () {
      final f = makeNetworkFailure();
      expect(f, isA<NetworkFailure>());
      expect(f, isNot(isA<StorageFailure>()));
      expect(f, isNot(isA<DatabaseFailure>()));
    });

    test('StorageFailure is only StorageFailure', () {
      final f = makeStorageFailure();
      expect(f, isA<StorageFailure>());
      expect(f, isNot(isA<NetworkFailure>()));
    });

    test('PermissionDeniedFailure is only PermissionDeniedFailure', () {
      final f = makePermissionFailure();
      expect(f, isA<PermissionDeniedFailure>());
      expect(f, isNot(isA<NetworkFailure>()));
      expect(f, isNot(isA<NotFoundFailure>()));
    });

    test('switch on sealed failure type compiles and runs correctly', () {
      // Verify exhaustive pattern matching works on all variants
      String classify(PhotoRepositoryFailure f) {
        return switch (f) {
          NetworkFailure() => 'network',
          StorageFailure() => 'storage',
          DatabaseFailure() => 'database',
          NotFoundFailure() => 'not_found',
          PermissionDeniedFailure() => 'permission',
          CompressionFailure() => 'compression',
          QuotaExceededFailure() => 'quota',
          UnknownFailure() => 'unknown',
        };
      }

      expect(classify(makeNetworkFailure()), equals('network'));
      expect(classify(makeStorageFailure()), equals('storage'));
      expect(classify(makeDatabaseFailure()), equals('database'));
      expect(classify(makeNotFoundFailure()), equals('not_found'));
      expect(classify(makePermissionFailure()), equals('permission'));
      expect(classify(makeCompressionFailure()), equals('compression'));
      expect(classify(makeQuotaFailure()), equals('quota'));
      expect(classify(makeUnknownFailure()), equals('unknown'));
    });
  });
}
