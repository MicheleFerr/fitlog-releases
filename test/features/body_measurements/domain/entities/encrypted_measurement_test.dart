import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/encrypted_measurement.dart';

void main() {
  final baseTime = DateTime.utc(2025, 6, 15, 9, 30);

  EncryptedMeasurement makeEncrypted({
    String id = 'meas-1',
    String userId = 'user-1',
    String metricType = 'weight',
    String encryptedData = 'base64ciphertext==',
    String iv = 'base64iv====',
    String tag = 'base64tag===',
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EncryptedMeasurement(
      id: id,
      userId: userId,
      metricType: metricType,
      encryptedData: encryptedData,
      iv: iv,
      tag: tag,
      timestamp: timestamp ?? baseTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // EncryptedMeasurement construction
  // ---------------------------------------------------------------------------
  group('EncryptedMeasurement construction', () {
    test('creates with all required fields', () {
      final em = makeEncrypted();

      expect(em.id, equals('meas-1'));
      expect(em.userId, equals('user-1'));
      expect(em.metricType, equals('weight'));
      expect(em.encryptedData, equals('base64ciphertext=='));
      expect(em.iv, equals('base64iv===='));
      expect(em.tag, equals('base64tag==='));
      expect(em.timestamp, equals(baseTime));
    });

    test('optional fields default to null', () {
      final em = makeEncrypted();

      expect(em.createdAt, isNull);
      expect(em.updatedAt, isNull);
    });

    test('accepts optional timestamps', () {
      final created = DateTime.utc(2025, 6, 14);
      final updated = DateTime.utc(2025, 6, 15);
      final em = makeEncrypted(createdAt: created, updatedAt: updated);

      expect(em.createdAt, equals(created));
      expect(em.updatedAt, equals(updated));
    });

    test('stores metric type as string (unencrypted for querying)', () {
      final em = makeEncrypted(metricType: 'bodyFatPercentage');
      expect(em.metricType, equals('bodyFatPercentage'));
    });
  });

  // ---------------------------------------------------------------------------
  // EncryptedMeasurement copyWith (Freezed-generated)
  // ---------------------------------------------------------------------------
  group('EncryptedMeasurement.copyWith', () {
    test('returns new instance without mutating original', () {
      final original = makeEncrypted(encryptedData: 'oldCiphertext==');
      final updated = original.copyWith(encryptedData: 'newCiphertext==');

      expect(updated.encryptedData, equals('newCiphertext=='));
      expect(original.encryptedData, equals('oldCiphertext==')); // invariato
    });

    test('can update IV and tag', () {
      final original = makeEncrypted(iv: 'oldIV====', tag: 'oldTag===');
      final updated = original.copyWith(iv: 'newIV====', tag: 'newTag===');

      expect(updated.iv, equals('newIV===='));
      expect(updated.tag, equals('newTag==='));
      expect(original.iv, equals('oldIV====')); // invariato
    });

    test('can update userId', () {
      final original = makeEncrypted(userId: 'user-old');
      final updated = original.copyWith(userId: 'user-new');

      expect(updated.userId, equals('user-new'));
      expect(original.userId, equals('user-old'));
    });

    test('can set updatedAt timestamp', () {
      final now = DateTime.utc(2025, 7, 1);
      final original = makeEncrypted();
      final updated = original.copyWith(updatedAt: now);

      expect(updated.updatedAt, equals(now));
      expect(original.updatedAt, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // EncryptedMeasurement equality (Freezed value equality)
  // ---------------------------------------------------------------------------
  group('EncryptedMeasurement equality', () {
    test('identical instances are equal', () {
      final a = makeEncrypted(id: 'same-id');
      final b = makeEncrypted(id: 'same-id');

      expect(a, equals(b));
    });

    test('instances with different ids are not equal', () {
      final a = makeEncrypted(id: 'id-1');
      final b = makeEncrypted(id: 'id-2');

      expect(a, isNot(equals(b)));
    });

    test('instances with different encrypted data are not equal', () {
      final a = makeEncrypted(encryptedData: 'cipher-a==');
      final b = makeEncrypted(encryptedData: 'cipher-b==');

      expect(a, isNot(equals(b)));
    });

    test('same content produces same hashCode', () {
      final a = makeEncrypted(id: 'hash-test');
      final b = makeEncrypted(id: 'hash-test');

      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // EncryptedMeasurement JSON round-trip
  // ---------------------------------------------------------------------------
  group('EncryptedMeasurement JSON', () {
    test('fromJson/toJson preserves all required fields', () {
      final original = makeEncrypted(
        id: 'json-test-1',
        userId: 'json-user',
        metricType: 'waistCircumference',
        encryptedData: 'VGVzdERhdGE=',
        iv: 'VGVzdElW',
        tag: 'VGVzdFRhZw==',
      );

      final json = original.toJson();
      final restored = EncryptedMeasurement.fromJson(json);

      expect(restored.id, equals('json-test-1'));
      expect(restored.userId, equals('json-user'));
      expect(restored.metricType, equals('waistCircumference'));
      expect(restored.encryptedData, equals('VGVzdERhdGE='));
      expect(restored.iv, equals('VGVzdElW'));
      expect(restored.tag, equals('VGVzdFRhZw=='));
    });

    test('fromJson/toJson preserves timestamp', () {
      final timestamp = DateTime.utc(2025, 3, 15, 8, 30, 0);
      final original = makeEncrypted(timestamp: timestamp);

      final json = original.toJson();
      final restored = EncryptedMeasurement.fromJson(json);

      expect(restored.timestamp, equals(timestamp));
    });

    test('fromJson/toJson preserves optional timestamps', () {
      final created = DateTime.utc(2025, 1, 10);
      final updated = DateTime.utc(2025, 6, 20);
      final original = makeEncrypted(createdAt: created, updatedAt: updated);

      final json = original.toJson();
      final restored = EncryptedMeasurement.fromJson(json);

      expect(restored.createdAt, equals(created));
      expect(restored.updatedAt, equals(updated));
    });

    test('fromJson/toJson with null optional fields', () {
      final original = makeEncrypted(); // no createdAt/updatedAt

      final json = original.toJson();
      final restored = EncryptedMeasurement.fromJson(json);

      expect(restored.createdAt, isNull);
      expect(restored.updatedAt, isNull);
    });

    test('toJson produces map with all expected keys', () {
      final em = makeEncrypted();
      final json = em.toJson();

      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('userId'), isTrue);
      expect(json.containsKey('metricType'), isTrue);
      expect(json.containsKey('encryptedData'), isTrue);
      expect(json.containsKey('iv'), isTrue);
      expect(json.containsKey('tag'), isTrue);
      expect(json.containsKey('timestamp'), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // EncryptionMetadata
  // ---------------------------------------------------------------------------
  group('EncryptionMetadata construction', () {
    test('creates with required fields', () {
      final keyTime = DateTime.utc(2025, 1, 1);
      final meta = EncryptionMetadata(
        keyVersion: 1,
        keyGeneratedAt: keyTime,
      );

      expect(meta.keyVersion, equals(1));
      expect(meta.keyGeneratedAt, equals(keyTime));
      expect(meta.algorithm, equals('AES-256-GCM')); // default
    });

    test('optional fields default to null', () {
      final meta = EncryptionMetadata(
        keyVersion: 1,
        keyGeneratedAt: DateTime.utc(2025, 1, 1),
      );

      expect(meta.keyLastRotated, isNull);
      expect(meta.keyRotationScheduled, isNull);
      expect(meta.keyDerivationFunction, isNull);
    });

    test('default algorithm is AES-256-GCM', () {
      final meta = EncryptionMetadata(
        keyVersion: 1,
        keyGeneratedAt: DateTime.utc(2025, 1, 1),
      );
      expect(meta.algorithm, equals('AES-256-GCM'));
    });

    test('can override default algorithm', () {
      final meta = EncryptionMetadata(
        keyVersion: 2,
        keyGeneratedAt: DateTime.utc(2025, 1, 1),
        algorithm: 'ChaCha20-Poly1305',
      );
      expect(meta.algorithm, equals('ChaCha20-Poly1305'));
    });

    test('accepts key rotation timestamps', () {
      final generated = DateTime.utc(2025, 1, 1);
      final rotated = DateTime.utc(2025, 4, 1);
      final scheduled = DateTime.utc(2025, 7, 1);

      final meta = EncryptionMetadata(
        keyVersion: 3,
        keyGeneratedAt: generated,
        keyLastRotated: rotated,
        keyRotationScheduled: scheduled,
        keyDerivationFunction: 'PBKDF2-SHA256',
      );

      expect(meta.keyLastRotated, equals(rotated));
      expect(meta.keyRotationScheduled, equals(scheduled));
      expect(meta.keyDerivationFunction, equals('PBKDF2-SHA256'));
    });
  });

  group('EncryptionMetadata.copyWith', () {
    test('increments key version without mutating original', () {
      final original = EncryptionMetadata(
        keyVersion: 1,
        keyGeneratedAt: DateTime.utc(2025, 1, 1),
      );
      final updated = original.copyWith(keyVersion: 2);

      expect(updated.keyVersion, equals(2));
      expect(original.keyVersion, equals(1));
    });
  });

  group('EncryptionMetadata equality', () {
    test('identical instances are equal', () {
      final time = DateTime.utc(2025, 1, 1);
      final a = EncryptionMetadata(keyVersion: 1, keyGeneratedAt: time);
      final b = EncryptionMetadata(keyVersion: 1, keyGeneratedAt: time);

      expect(a, equals(b));
    });

    test('different keyVersion produces inequality', () {
      final time = DateTime.utc(2025, 1, 1);
      final a = EncryptionMetadata(keyVersion: 1, keyGeneratedAt: time);
      final b = EncryptionMetadata(keyVersion: 2, keyGeneratedAt: time);

      expect(a, isNot(equals(b)));
    });
  });

  group('EncryptionMetadata JSON', () {
    test('fromJson/toJson round-trip preserves all fields', () {
      final generated = DateTime.utc(2025, 1, 1);
      final rotated = DateTime.utc(2025, 4, 1);
      final scheduled = DateTime.utc(2025, 7, 1);

      final original = EncryptionMetadata(
        keyVersion: 3,
        keyGeneratedAt: generated,
        keyLastRotated: rotated,
        keyRotationScheduled: scheduled,
        algorithm: 'AES-256-GCM',
        keyDerivationFunction: 'PBKDF2-SHA256',
      );

      final json = original.toJson();
      final restored = EncryptionMetadata.fromJson(json);

      expect(restored.keyVersion, equals(3));
      expect(restored.keyGeneratedAt, equals(generated));
      expect(restored.keyLastRotated, equals(rotated));
      expect(restored.keyRotationScheduled, equals(scheduled));
      expect(restored.algorithm, equals('AES-256-GCM'));
      expect(restored.keyDerivationFunction, equals('PBKDF2-SHA256'));
    });

    test('fromJson/toJson with null optional fields', () {
      final original = EncryptionMetadata(
        keyVersion: 1,
        keyGeneratedAt: DateTime.utc(2025, 1, 1),
      );

      final json = original.toJson();
      final restored = EncryptionMetadata.fromJson(json);

      expect(restored.keyLastRotated, isNull);
      expect(restored.keyRotationScheduled, isNull);
      expect(restored.keyDerivationFunction, isNull);
    });
  });
}
