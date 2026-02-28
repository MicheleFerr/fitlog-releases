import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';

void main() {
  final now = DateTime(2025, 4, 10, 10, 0);

  UserConsent _makeConsent({
    Map<MetricGroup, ConsentState>? consents,
    bool isRevoked = false,
  }) {
    return UserConsent(
      id: 'consent-1',
      userId: 'user-1',
      groupConsents: consents ??
          {
            MetricGroup.essential: ConsentState.granted,
            MetricGroup.measurements: ConsentState.notAsked,
            MetricGroup.vitals: ConsentState.denied,
          },
      consentVersion: 1,
      acceptedAt: now,
      ipAddress: '192.168.1.***',
      isRevoked: isRevoked,
    );
  }

  // ---------------------------------------------------------------------------
  // ConsentState enum
  // ---------------------------------------------------------------------------
  group('ConsentState', () {
    test('has 3 values', () {
      expect(ConsentState.values.length, 3);
    });

    test('contains notAsked, denied, granted', () {
      expect(ConsentState.values, contains(ConsentState.notAsked));
      expect(ConsentState.values, contains(ConsentState.denied));
      expect(ConsentState.values, contains(ConsentState.granted));
    });
  });

  // ---------------------------------------------------------------------------
  // AuditAction enum
  // ---------------------------------------------------------------------------
  group('AuditAction', () {
    test('contains key actions', () {
      expect(AuditAction.values, contains(AuditAction.dataAccess));
      expect(AuditAction.values, contains(AuditAction.dataExport));
      expect(AuditAction.values, contains(AuditAction.dataDelete));
      expect(AuditAction.values, contains(AuditAction.consentChange));
      expect(AuditAction.values, contains(AuditAction.measurementCreated));
    });
  });

  // ---------------------------------------------------------------------------
  // UserConsent construction
  // ---------------------------------------------------------------------------
  group('UserConsent construction', () {
    test('creates with required fields', () {
      final consent = _makeConsent();

      expect(consent.id, 'consent-1');
      expect(consent.userId, 'user-1');
      expect(consent.consentVersion, 1);
      expect(consent.acceptedAt, now);
      expect(consent.ipAddress, '192.168.1.***');
    });

    test('defaults isRevoked to false', () {
      final consent = _makeConsent();

      expect(consent.isRevoked, isFalse);
    });

    test('optional fields default to null', () {
      final consent = _makeConsent();

      expect(consent.essentialGrantedAt, isNull);
      expect(consent.measurementsGrantedAt, isNull);
      expect(consent.vitalsGrantedAt, isNull);
      expect(consent.createdAt, isNull);
      expect(consent.updatedAt, isNull);
      expect(consent.revokedAt, isNull);
      expect(consent.userAgent, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // UserConsentX.hasConsentFor
  // ---------------------------------------------------------------------------
  group('UserConsentX.hasConsentFor', () {
    test('returns true for metric whose group is granted', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      // weight is in essential group → granted
      expect(consent.hasConsentFor(MetricType.weight), isTrue);
    });

    test('returns false for metric whose group is denied', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      // bodyTemperature is in vitals → denied
      expect(consent.hasConsentFor(MetricType.bodyTemperature), isFalse);
    });

    test('returns false for metric whose group is notAsked', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      // waistCircumference is in measurements → notAsked
      expect(consent.hasConsentFor(MetricType.waistCircumference), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // UserConsentX.consentedMetrics
  // ---------------------------------------------------------------------------
  group('UserConsentX.consentedMetrics', () {
    test('returns only metrics whose group is granted', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      final consented = consent.consentedMetrics;

      // All essential metrics should be present
      expect(consented, contains(MetricType.weight));
      expect(consented, contains(MetricType.height));
      expect(consented, contains(MetricType.bmi));

      // Measurements and vitals should NOT be present
      expect(consented, isNot(contains(MetricType.waistCircumference)));
      expect(consented, isNot(contains(MetricType.bodyTemperature)));
    });

    test('returns empty list when no groups are granted', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.denied,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      expect(consent.consentedMetrics, isEmpty);
    });

    test('returns all metrics when all groups are granted', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.granted,
          MetricGroup.vitals: ConsentState.granted,
        },
      );

      expect(
        consent.consentedMetrics.length,
        MetricType.values.length,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // UserConsentX.hasDenied
  // ---------------------------------------------------------------------------
  group('UserConsentX.hasDenied', () {
    test('returns true when group is denied', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      expect(consent.hasDenied(MetricGroup.vitals), isTrue);
    });

    test('returns false when group is granted', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      expect(consent.hasDenied(MetricGroup.essential), isFalse);
    });

    test('returns false when group is notAsked', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      expect(consent.hasDenied(MetricGroup.measurements), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // UserConsentX.isNotAsked
  // ---------------------------------------------------------------------------
  group('UserConsentX.isNotAsked', () {
    test('returns true when group is notAsked', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      expect(consent.isNotAsked(MetricGroup.measurements), isTrue);
    });

    test('returns false when group is granted', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      expect(consent.isNotAsked(MetricGroup.essential), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // UserConsentX.grantConsentFor
  // ---------------------------------------------------------------------------
  group('UserConsentX.grantConsentFor', () {
    test('grants consent for measurements group', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      final updated = consent.grantConsentFor(MetricGroup.measurements);

      expect(
        updated.groupConsents[MetricGroup.measurements],
        ConsentState.granted,
      );
    });

    test('does not mutate original consent', () {
      final original = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      original.grantConsentFor(MetricGroup.measurements);

      // Original should remain unchanged
      expect(
        original.groupConsents[MetricGroup.measurements],
        ConsentState.notAsked,
      );
    });

    test('sets measurementsGrantedAt timestamp when granting measurements', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      final updated = consent.grantConsentFor(MetricGroup.measurements);

      expect(updated.measurementsGrantedAt, isNotNull);
    });

    test('sets essentialGrantedAt timestamp when granting essential', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.notAsked,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.notAsked,
        },
      );

      final updated = consent.grantConsentFor(MetricGroup.essential);

      expect(updated.essentialGrantedAt, isNotNull);
    });

    test('sets vitalsGrantedAt timestamp when granting vitals', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.notAsked,
        },
      );

      final updated = consent.grantConsentFor(MetricGroup.vitals);

      expect(updated.vitalsGrantedAt, isNotNull);
    });

    test('sets updatedAt timestamp', () {
      final consent = _makeConsent();
      final updated = consent.grantConsentFor(MetricGroup.vitals);

      expect(updated.updatedAt, isNotNull);
    });

    test('preserves other group consent states', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.notAsked,
          MetricGroup.vitals: ConsentState.denied,
        },
      );

      final updated = consent.grantConsentFor(MetricGroup.measurements);

      // essential and vitals states should be preserved
      expect(
        updated.groupConsents[MetricGroup.essential],
        ConsentState.granted,
      );
      expect(
        updated.groupConsents[MetricGroup.vitals],
        ConsentState.denied,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // UserConsentX.revokeConsentFor
  // ---------------------------------------------------------------------------
  group('UserConsentX.revokeConsentFor', () {
    test('revokes consent by setting group state to denied', () {
      final consent = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.granted,
          MetricGroup.vitals: ConsentState.notAsked,
        },
      );

      final updated = consent.revokeConsentFor(MetricGroup.measurements);

      expect(
        updated.groupConsents[MetricGroup.measurements],
        ConsentState.denied,
      );
    });

    test('does not mutate original consent on revoke', () {
      final original = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.granted,
          MetricGroup.vitals: ConsentState.notAsked,
        },
      );

      original.revokeConsentFor(MetricGroup.measurements);

      expect(
        original.groupConsents[MetricGroup.measurements],
        ConsentState.granted,
      );
    });

    test('sets updatedAt timestamp on revoke', () {
      final consent = _makeConsent();
      final updated = consent.revokeConsentFor(MetricGroup.essential);

      expect(updated.updatedAt, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // JSON serialization round-trip
  // ---------------------------------------------------------------------------
  group('UserConsent JSON', () {
    test('fromJson/toJson round-trip preserves required fields', () {
      final original = _makeConsent();
      final json = original.toJson();
      final restored = UserConsent.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.consentVersion, original.consentVersion);
      expect(restored.ipAddress, original.ipAddress);
      expect(restored.isRevoked, original.isRevoked);
    });

    test('fromJson/toJson round-trip preserves group consent states', () {
      final original = _makeConsent(
        consents: {
          MetricGroup.essential: ConsentState.granted,
          MetricGroup.measurements: ConsentState.denied,
          MetricGroup.vitals: ConsentState.notAsked,
        },
      );

      final json = original.toJson();
      final restored = UserConsent.fromJson(json);

      expect(
        restored.groupConsents[MetricGroup.essential],
        ConsentState.granted,
      );
      expect(
        restored.groupConsents[MetricGroup.measurements],
        ConsentState.denied,
      );
      expect(
        restored.groupConsents[MetricGroup.vitals],
        ConsentState.notAsked,
      );
    });
  });
}
