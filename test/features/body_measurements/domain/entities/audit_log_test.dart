// Tests for AuditLog entity from user_consent.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';

void main() {
  final baseTime = DateTime.utc(2025, 6, 15, 10, 0);

  AuditLog _makeLog({
    String id = 'audit-1',
    String userId = 'user-1',
    AuditAction action = AuditAction.dataAccess,
    DateTime? timestamp,
    String ipAddress = '192.168.1.***',
    List<MetricType>? affectedMetrics,
    String? actionDetails,
    String? previousHash,
    String? hash,
    String? userAgent,
    String? platform,
    String? appVersion,
  }) {
    return AuditLog(
      id: id,
      userId: userId,
      action: action,
      timestamp: timestamp ?? baseTime,
      ipAddress: ipAddress,
      affectedMetrics: affectedMetrics,
      actionDetails: actionDetails,
      previousHash: previousHash,
      hash: hash,
      userAgent: userAgent,
      platform: platform,
      appVersion: appVersion,
    );
  }

  // ---------------------------------------------------------------------------
  // AuditLog construction
  // ---------------------------------------------------------------------------
  group('AuditLog construction', () {
    test('creates with required fields', () {
      final log = _makeLog();

      expect(log.id, 'audit-1');
      expect(log.userId, 'user-1');
      expect(log.action, AuditAction.dataAccess);
      expect(log.timestamp, baseTime);
      expect(log.ipAddress, '192.168.1.***');
    });

    test('optional fields default to null', () {
      final log = _makeLog();

      expect(log.affectedMetrics, isNull);
      expect(log.actionDetails, isNull);
      expect(log.previousHash, isNull);
      expect(log.hash, isNull);
      expect(log.userAgent, isNull);
      expect(log.platform, isNull);
      expect(log.appVersion, isNull);
    });

    test('accepts affectedMetrics list', () {
      final log = _makeLog(
        affectedMetrics: [MetricType.weight, MetricType.bodyFatPercentage],
      );

      expect(log.affectedMetrics, hasLength(2));
      expect(log.affectedMetrics, contains(MetricType.weight));
    });

    test('accepts actionDetails', () {
      final log = _makeLog(actionDetails: 'Exported 150 measurements to JSON');
      expect(log.actionDetails, 'Exported 150 measurements to JSON');
    });

    test('accepts hash chain fields', () {
      final log = _makeLog(
        previousHash: 'GENESIS',
        hash: 'sha256abc123',
      );

      expect(log.previousHash, 'GENESIS');
      expect(log.hash, 'sha256abc123');
    });

    test('accepts platform and app version metadata', () {
      final log = _makeLog(
        platform: 'iOS',
        appVersion: '1.0.0+49',
        userAgent: 'FitLog Pro/1.0.0 iOS/17.2',
      );

      expect(log.platform, 'iOS');
      expect(log.appVersion, '1.0.0+49');
      expect(log.userAgent, 'FitLog Pro/1.0.0 iOS/17.2');
    });
  });

  // ---------------------------------------------------------------------------
  // AuditLog copyWith (Freezed generated)
  // ---------------------------------------------------------------------------
  group('AuditLog.copyWith', () {
    test('returns new instance without mutating original', () {
      final original = _makeLog(action: AuditAction.dataAccess);
      final updated = original.copyWith(action: AuditAction.dataExport);

      expect(updated.action, AuditAction.dataExport);
      expect(original.action, AuditAction.dataAccess);
    });

    test('can update hash fields', () {
      final original = _makeLog(previousHash: 'prev123');
      final updated = original.copyWith(hash: 'computed_hash_abc');

      expect(updated.previousHash, 'prev123');
      expect(updated.hash, 'computed_hash_abc');
    });

    test('can add affectedMetrics', () {
      final original = _makeLog();
      final updated = original.copyWith(
        affectedMetrics: [MetricType.weight],
      );

      expect(updated.affectedMetrics, hasLength(1));
      expect(original.affectedMetrics, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // AuditLog equality (Freezed value equality)
  // ---------------------------------------------------------------------------
  group('AuditLog equality', () {
    test('identical instances are equal', () {
      final a = _makeLog(id: 'same-id');
      final b = _makeLog(id: 'same-id');

      expect(a, equals(b));
    });

    test('instances with different ids are not equal', () {
      final a = _makeLog(id: 'id-1');
      final b = _makeLog(id: 'id-2');

      expect(a, isNot(equals(b)));
    });

    test('instances with different actions are not equal', () {
      final a = _makeLog(action: AuditAction.dataAccess);
      final b = _makeLog(action: AuditAction.dataDelete);

      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // AuditLog JSON round-trip
  // ---------------------------------------------------------------------------
  group('AuditLog JSON', () {
    test('fromJson/toJson preserves required fields', () {
      final original = _makeLog(
        id: 'json-audit-1',
        userId: 'json-user',
        action: AuditAction.dataExport,
        ipAddress: '10.0.0.***',
      );

      final json = original.toJson();
      final restored = AuditLog.fromJson(json);

      expect(restored.id, 'json-audit-1');
      expect(restored.userId, 'json-user');
      expect(restored.action, AuditAction.dataExport);
      expect(restored.ipAddress, '10.0.0.***');
    });

    test('fromJson/toJson preserves all optional fields', () {
      final original = _makeLog(
        affectedMetrics: [MetricType.weight],
        actionDetails: 'Test action',
        previousHash: 'prev-hash-123',
        hash: 'current-hash-456',
        userAgent: 'TestAgent/1.0',
        platform: 'Android',
        appVersion: '2.0.0+100',
      );

      final json = original.toJson();
      final restored = AuditLog.fromJson(json);

      expect(restored.affectedMetrics, hasLength(1));
      expect(restored.affectedMetrics!.first, MetricType.weight);
      expect(restored.actionDetails, 'Test action');
      expect(restored.previousHash, 'prev-hash-123');
      expect(restored.hash, 'current-hash-456');
      expect(restored.userAgent, 'TestAgent/1.0');
      expect(restored.platform, 'Android');
      expect(restored.appVersion, '2.0.0+100');
    });

    test('fromJson/toJson with null optional fields', () {
      final original = _makeLog();
      final json = original.toJson();
      final restored = AuditLog.fromJson(json);

      expect(restored.affectedMetrics, isNull);
      expect(restored.actionDetails, isNull);
      expect(restored.previousHash, isNull);
      expect(restored.hash, isNull);
    });

    test('toJson contains all expected keys', () {
      final log = _makeLog();
      final json = log.toJson();

      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('userId'), isTrue);
      expect(json.containsKey('action'), isTrue);
      expect(json.containsKey('timestamp'), isTrue);
      expect(json.containsKey('ipAddress'), isTrue);
    });

    test('action serialized as string', () {
      final log = _makeLog(action: AuditAction.keyRotation);
      final json = log.toJson();

      expect(json['action'], isA<String>());
    });
  });

  // ---------------------------------------------------------------------------
  // AuditAction enum
  // ---------------------------------------------------------------------------
  group('AuditAction enum', () {
    test('has 9 values', () {
      expect(AuditAction.values.length, 9);
    });

    test('contains all expected audit actions', () {
      expect(AuditAction.values, contains(AuditAction.dataAccess));
      expect(AuditAction.values, contains(AuditAction.dataExport));
      expect(AuditAction.values, contains(AuditAction.dataDelete));
      expect(AuditAction.values, contains(AuditAction.consentChange));
      expect(AuditAction.values, contains(AuditAction.measurementCreated));
      expect(AuditAction.values, contains(AuditAction.measurementUpdated));
      expect(AuditAction.values, contains(AuditAction.healthPlatformSync));
      expect(AuditAction.values, contains(AuditAction.keyRotation));
      expect(AuditAction.values, contains(AuditAction.privacyPolicyAccepted));
    });
  });

  // ---------------------------------------------------------------------------
  // Hash chain integrity (conceptual)
  // ---------------------------------------------------------------------------
  group('AuditLog hash chain', () {
    test('genesis log has no previousHash', () {
      final genesis = _makeLog(previousHash: null, hash: 'genesis_hash_abc');
      expect(genesis.previousHash, isNull);
      expect(genesis.hash, isNotNull);
    });

    test('chained log references previous hash', () {
      final genesis = _makeLog(
        id: 'log-1',
        previousHash: null,
        hash: 'hash_1',
      );
      final second = _makeLog(
        id: 'log-2',
        previousHash: genesis.hash,
        hash: 'hash_2',
      );

      expect(second.previousHash, equals(genesis.hash));
    });

    test('hash chain can be verified by checking previousHash links', () {
      final log1 = _makeLog(id: 'l1', hash: 'h1', previousHash: 'GENESIS');
      final log2 = _makeLog(id: 'l2', hash: 'h2', previousHash: 'h1');
      final log3 = _makeLog(id: 'l3', hash: 'h3', previousHash: 'h2');

      final chain = [log1, log2, log3];
      // Verify chain integrity
      for (int i = 1; i < chain.length; i++) {
        expect(chain[i].previousHash, equals(chain[i - 1].hash));
      }
    });
  });
}
