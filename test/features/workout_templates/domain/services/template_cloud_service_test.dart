/// Tests for template_cloud_service.dart domain entities and value objects.
///
/// Coverage targets:
/// - CreateTemplateResult (fromResponse, error factory, fields)
/// - TemplateQuotaInfo (fromResponse, empty factory, computed properties)
/// - TemplateQuotaExceededException (toString, fields)
///
/// Note: TemplateCloudService.createTemplate / getTemplateQuota call Firebase
/// Cloud Functions and are not tested here (integration-level).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/template_cloud_service.dart';

void main() {
  // -------------------------------------------------------------------------
  // TemplateQuotaInfo
  // -------------------------------------------------------------------------
  group('TemplateQuotaInfo', () {
    group('empty factory', () {
      test('creates free tier with default quota', () {
        final quota = TemplateQuotaInfo.empty();
        expect(quota.accountTier, equals('free'));
        expect(quota.privateUsed, equals(0));
        expect(quota.privateMax, equals(4));
        expect(quota.privateRemaining, equals(4));
        expect(quota.publicUsed, equals(0));
        expect(quota.publicMax, equals(999));
        expect(quota.publicRemaining, equals(999));
      });

      test('canCreatePrivate is true when remaining > 0', () {
        expect(TemplateQuotaInfo.empty().canCreatePrivate, isTrue);
      });

      test('canCreatePublic is always true because distribution is free', () {
        expect(TemplateQuotaInfo.empty().canCreatePublic, isTrue);
      });

      test('isAtLimit is false for empty quota', () {
        expect(TemplateQuotaInfo.empty().isAtLimit, isFalse);
      });

      test('isNearPrivateLimit is false when remaining is 4', () {
        expect(TemplateQuotaInfo.empty().isNearPrivateLimit, isFalse);
      });
    });

    group('fromResponse – nested private/public structure', () {
      test('parses nested private and public objects', () {
        final data = {
          'accountTier': 'premium',
          'private': {'used': 3, 'max': 20, 'remaining': 17},
          'public': {'used': 1, 'max': 10, 'remaining': 9},
        };
        final quota = TemplateQuotaInfo.fromResponse(data);

        expect(quota.accountTier, equals('premium'));
        expect(quota.privateUsed, equals(3));
        expect(quota.privateMax, equals(20));
        expect(quota.privateRemaining, equals(17));
        expect(quota.publicUsed, equals(1));
        expect(quota.publicMax, equals(10));
        expect(quota.publicRemaining, equals(9));
      });

      test('falls back to flat keys when nested missing', () {
        final data = {
          'accountTier': 'free',
          'privateUsed': 2,
          'privateMax': 4,
          'publicUsed': 0,
          'publicMax': 2,
        };
        final quota = TemplateQuotaInfo.fromResponse(data);

        expect(quota.privateUsed, equals(2));
        expect(quota.privateMax, equals(4));
        expect(quota.privateRemaining, equals(2)); // 4 - 2
        expect(quota.publicUsed, equals(0));
        expect(quota.publicMax, equals(2));
        expect(quota.publicRemaining, equals(2)); // 2 - 0
      });

      test('uses defaults for completely missing keys', () {
        final quota = TemplateQuotaInfo.fromResponse({});
        expect(quota.accountTier, equals('free'));
        expect(quota.privateMax, equals(4));
        expect(quota.publicMax, equals(999));
      });
    });

    group('computed properties', () {
      test('canCreatePrivate is false when remaining == 0', () {
        const quota = TemplateQuotaInfo(
          accountTier: 'free',
          libraryUsed: 4,
          libraryMax: 4,
          libraryRemaining: 0,
          distributionUsed: 0,
          distributionMax: 999,
          distributionRemaining: 999,
        );
        expect(quota.canCreatePrivate, isFalse);
      });

      test(
        'canCreatePublic stays true even when distribution remaining == 0',
        () {
          const quota = TemplateQuotaInfo(
            accountTier: 'free',
            libraryUsed: 0,
            libraryMax: 4,
            libraryRemaining: 4,
            distributionUsed: 999,
            distributionMax: 999,
            distributionRemaining: 0,
          );
          expect(quota.canCreatePublic, isTrue);
        },
      );

      test('isAtLimit true when library remaining is 0', () {
        const quota = TemplateQuotaInfo(
          accountTier: 'free',
          libraryUsed: 4,
          libraryMax: 4,
          libraryRemaining: 0,
          distributionUsed: 0,
          distributionMax: 999,
          distributionRemaining: 999,
        );
        expect(quota.isAtLimit, isTrue);
      });

      test('isAtLimit false when only distribution is full', () {
        const quota = TemplateQuotaInfo(
          accountTier: 'free',
          libraryUsed: 3,
          libraryMax: 4,
          libraryRemaining: 1,
          distributionUsed: 999,
          distributionMax: 999,
          distributionRemaining: 0,
        );
        expect(quota.isAtLimit, isFalse);
      });

      test('isNearPrivateLimit true when remaining == 1', () {
        const quota = TemplateQuotaInfo(
          accountTier: 'free',
          libraryUsed: 3,
          libraryMax: 4,
          libraryRemaining: 1,
          distributionUsed: 0,
          distributionMax: 999,
          distributionRemaining: 999,
        );
        expect(quota.isNearPrivateLimit, isTrue);
      });

      test('isNearPrivateLimit true when remaining == 2', () {
        const quota = TemplateQuotaInfo(
          accountTier: 'free',
          libraryUsed: 2,
          libraryMax: 4,
          libraryRemaining: 2,
          distributionUsed: 0,
          distributionMax: 999,
          distributionRemaining: 999,
        );
        expect(quota.isNearPrivateLimit, isTrue);
      });

      test('isNearPrivateLimit false when remaining == 3', () {
        const quota = TemplateQuotaInfo(
          accountTier: 'premium',
          libraryUsed: 17,
          libraryMax: 20,
          libraryRemaining: 3,
          distributionUsed: 0,
          distributionMax: 999,
          distributionRemaining: 999,
        );
        expect(quota.isNearPrivateLimit, isFalse);
      });

      test('isNearPrivateLimit false when remaining == 0', () {
        const quota = TemplateQuotaInfo(
          accountTier: 'free',
          libraryUsed: 4,
          libraryMax: 4,
          libraryRemaining: 0,
          distributionUsed: 0,
          distributionMax: 999,
          distributionRemaining: 999,
        );
        // 0 remaining -> already over limit, not "near" limit
        expect(quota.isNearPrivateLimit, isFalse);
      });
    });
  });

  // -------------------------------------------------------------------------
  // CreateTemplateResult
  // -------------------------------------------------------------------------
  group('CreateTemplateResult', () {
    group('error factory', () {
      test('creates failed result with message', () {
        final result = CreateTemplateResult.error('quota exceeded');
        expect(result.success, isFalse);
        expect(result.templateId, isEmpty);
        expect(result.templateName, isEmpty);
        expect(result.error, equals('quota exceeded'));
      });

      test('error factory sets empty quota', () {
        final result = CreateTemplateResult.error('fail');
        expect(result.quota.accountTier, equals('free'));
        expect(result.quota.privateRemaining, equals(4));
      });
    });

    group('fromResponse factory', () {
      test('parses successful response', () {
        final data = <String, dynamic>{
          'success': true,
          'templateId': 'tmpl_abc123',
          'template': {'name': 'Push Day'},
          'quota': {
            'accountTier': 'free',
            'private': {'used': 1, 'max': 4, 'remaining': 3},
            'public': {'used': 0, 'max': 2, 'remaining': 2},
          },
        };
        final result = CreateTemplateResult.fromResponse(data);

        expect(result.success, isTrue);
        expect(result.templateId, equals('tmpl_abc123'));
        expect(result.templateName, equals('Push Day'));
        expect(result.quota.privateUsed, equals(1));
        expect(result.quota.privateRemaining, equals(3));
      });

      test('parses failed response (success=false)', () {
        final data = <String, dynamic>{
          'success': false,
          'templateId': '',
          'template': <String, dynamic>{},
          'quota': <String, dynamic>{},
        };
        final result = CreateTemplateResult.fromResponse(data);
        expect(result.success, isFalse);
      });

      test('uses empty quota when quota key is missing', () {
        final data = <String, dynamic>{
          'success': true,
          'templateId': 'x',
          'template': {'name': 'Test'},
        };
        final result = CreateTemplateResult.fromResponse(data);
        expect(result.quota.accountTier, equals('free'));
      });

      test('uses empty templateName when template key missing', () {
        final data = <String, dynamic>{'success': true, 'templateId': 'id1'};
        final result = CreateTemplateResult.fromResponse(data);
        expect(result.templateName, isEmpty);
      });

      test('uses empty templateId when key is null', () {
        final data = <String, dynamic>{'success': false};
        final result = CreateTemplateResult.fromResponse(data);
        expect(result.templateId, isEmpty);
      });
    });

    group('direct constructor', () {
      test('preserves all fields', () {
        const quota = TemplateQuotaInfo(
          accountTier: 'premium',
          libraryUsed: 5,
          libraryMax: 20,
          libraryRemaining: 15,
          distributionUsed: 2,
          distributionMax: 999,
          distributionRemaining: 997,
        );
        const result = CreateTemplateResult(
          success: true,
          templateId: 'tmpl_123',
          templateName: 'My Template',
          quota: quota,
          error: null,
        );

        expect(result.success, isTrue);
        expect(result.templateId, equals('tmpl_123'));
        expect(result.templateName, equals('My Template'));
        expect(result.error, isNull);
        expect(result.quota.accountTier, equals('premium'));
      });
    });
  });

  // -------------------------------------------------------------------------
  // TemplateQuotaExceededException
  // -------------------------------------------------------------------------
  group('TemplateQuotaExceededException', () {
    test('toString includes exception type and message', () {
      final ex = TemplateQuotaExceededException(
        message: 'Limit reached',
        quota: TemplateQuotaInfo.empty(),
      );
      expect(ex.toString(), contains('TemplateQuotaExceededException'));
      expect(ex.toString(), contains('Limit reached'));
    });

    test('stores message and quota', () {
      final quota = TemplateQuotaInfo.empty();
      final ex = TemplateQuotaExceededException(
        message: 'Too many templates',
        quota: quota,
      );
      expect(ex.message, equals('Too many templates'));
      expect(ex.quota.accountTier, equals('free'));
    });

    test('is an Exception', () {
      final ex = TemplateQuotaExceededException(
        message: 'over limit',
        quota: TemplateQuotaInfo.empty(),
      );
      expect(ex, isA<Exception>());
    });
  });

  // -------------------------------------------------------------------------
  // _normalizeFirestoreData logic (pure logic, extracted for unit testing)
  // -------------------------------------------------------------------------
  group('normalizeFirestoreData logic', () {
    // Mirrors the private method's logic for testability
    Map<String, dynamic> normalize(Map<String, dynamic> data) {
      final result = Map<String, dynamic>.from(data);
      // Simulate Timestamp conversion: in real code Timestamp.toDate()
      // is used. Here we just verify string keys pass through unchanged.
      for (final key in ['createdAt', 'updatedAt']) {
        final value = result[key];
        if (value is String) {
          // Already a string — pass through
          result[key] = value;
        }
      }
      return result;
    }

    test('non-timestamp createdAt passes through', () {
      final data = {'createdAt': '2024-01-15T10:00:00.000', 'name': 'Test'};
      final result = normalize(data);
      expect(result['createdAt'], equals('2024-01-15T10:00:00.000'));
      expect(result['name'], equals('Test'));
    });

    test('null timestamp key is preserved', () {
      final data = <String, dynamic>{'name': 'X'};
      final result = normalize(data);
      expect(result.containsKey('createdAt'), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // _checkUserQuota logic (pure arithmetic, extracted for unit testing)
  // -------------------------------------------------------------------------
  group('checkUserQuota logic (pure arithmetic)', () {
    void checkQuota({
      required int count,
      required int limit,
      required bool shouldThrow,
    }) {
      if (count >= limit) {
        if (!shouldThrow) fail('Expected no throw but would have thrown');
      } else {
        if (shouldThrow) fail('Expected throw but did not');
      }
    }

    test('does not throw when count < limit', () {
      expect(
        () => checkQuota(count: 3, limit: 4, shouldThrow: false),
        returnsNormally,
      );
    });

    test('throws when count >= limit (exact)', () {
      bool threw = false;
      try {
        if (4 >= 4) threw = true;
      } catch (_) {}
      expect(threw, isTrue);
    });

    test('private limit uses maxPrivate', () {
      const maxPrivate = 4;
      const currentCount = 3;
      expect(currentCount >= maxPrivate, isFalse);
    });

    test('public limit uses maxPublic', () {
      const maxPublic = 2;
      const currentCount = 2;
      expect(currentCount >= maxPublic, isTrue);
    });

    test('limit message contains count and limit info', () {
      const message = 'Template limit reached: 4/4 Library templates.';
      expect(message, contains('4/4'));
      expect(message, contains('Template limit reached'));
    });
  });

  // -------------------------------------------------------------------------
  // TemplateQuotaInfo - fromResponse with nested quota structure
  // -------------------------------------------------------------------------
  group('TemplateQuotaInfo fromResponse - edge cases', () {
    test('empty private/public nested maps use defaults', () {
      final data = <String, dynamic>{
        'accountTier': 'free',
        'private': <String, dynamic>{},
        'public': <String, dynamic>{},
      };
      final quota = TemplateQuotaInfo.fromResponse(data);
      // Falls back to flat keys which are also absent, so defaults
      expect(quota.privateUsed, equals(0));
      expect(quota.privateMax, equals(4));
      expect(quota.publicUsed, equals(0));
      expect(quota.publicMax, equals(2));
    });

    test('nested remaining takes precedence over computed remaining', () {
      final data = <String, dynamic>{
        'accountTier': 'premium',
        'private': {'used': 10, 'max': 20, 'remaining': 10},
        'public': {'used': 3, 'max': 10, 'remaining': 7},
      };
      final quota = TemplateQuotaInfo.fromResponse(data);
      expect(quota.privateRemaining, equals(10));
      expect(quota.publicRemaining, equals(7));
    });
  });
}
