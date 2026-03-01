/// Tests for PrivacyManager - GDPR-compliant consent management.
///
/// Coverage targets:
/// - initialize() / uninitialized state error
/// - hasConsent() for required and optional types
/// - saveConsents() including always-add-essential logic
/// - getGrantedConsents()
/// - withdrawConsent() – essential guard and non-essential path
/// - hasProvidedConsent()
/// - needsConsentUpdate() – version mismatch, null version, old timestamp
/// - getConsentTimestamp()
/// - requestProcessingRestriction() / liftProcessingRestriction() / isProcessingRestricted()
/// - getRestrictionDetails()
/// - deleteAllUserData()
/// - exportUserData()
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/consent_type.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/privacy_manager.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Unique temp dir per test run so parallel runs don't collide.
Directory _tmpDir() {
  final dir = Directory.systemTemp.createTempSync('privacy_manager_test_');
  return dir;
}

/// Mock flutter_secure_storage so HiveEncryptionManager can generate / store
/// an AES-256 key without the native plugin.
void _mockSecureStorage(Map<String, String> storage) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (call) async {
      switch (call.method) {
        case 'read':
          final key = call.arguments['key'] as String;
          return storage[key];
        case 'write':
          final key = call.arguments['key'] as String;
          final value = call.arguments['value'] as String;
          storage[key] = value;
          return null;
        case 'delete':
          final key = call.arguments['key'] as String;
          storage.remove(key);
          return null;
        case 'deleteAll':
          storage.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(storage);
        case 'containsKey':
          final key = call.arguments['key'] as String;
          return storage.containsKey(key);
        default:
          return null;
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;
  final secureStorage = <String, String>{};

  setUpAll(() {
    _mockSecureStorage(secureStorage);
  });

  setUp(() async {
    secureStorage.clear();
    hiveDir = _tmpDir();

    // Reset manager singleton state so each test starts clean.
    HiveBoxManagerEnhanced.resetInitializationForTesting();
    HiveBoxManagerEnhanced().resetForTesting();

    Hive.init(hiveDir.path);
    // Mark Hive as initialized so openBox() works.
    await HiveBoxManagerEnhanced.initialize();

    // Wire PrivacyManager to the same singleton manager.
    await PrivacyManager.initialize(
      boxManager: HiveBoxManagerEnhanced(),
    );
  });

  tearDown(() async {
    await Hive.close();
    HiveBoxManagerEnhanced().resetForTesting();
    HiveBoxManagerEnhanced.resetInitializationForTesting();
    try {
      hiveDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  // -------------------------------------------------------------------------
  // initialize()
  // -------------------------------------------------------------------------
  group('initialize()', () {
    test('accepts a custom boxManager', () async {
      // Already initialized in setUp – just verify no exception was thrown.
      // hasConsent on a required type should return true without error.
      final result = await PrivacyManager.hasConsent(ConsentType.essential);
      expect(result, isTrue);
    });

    test('uses HiveBoxManagerEnhanced singleton when no boxManager given',
        () async {
      // Calling initialize() without argument must not throw.
      await expectLater(
        PrivacyManager.initialize(),
        completes,
      );
    });
  });

  // -------------------------------------------------------------------------
  // hasConsent()
  // -------------------------------------------------------------------------
  group('hasConsent()', () {
    test('essential always returns true regardless of stored value', () async {
      expect(await PrivacyManager.hasConsent(ConsentType.essential), isTrue);
    });

    test('returns false for optional consent when not set', () async {
      final result = await PrivacyManager.hasConsent(ConsentType.analytics);
      expect(result, isFalse);
    });

    test('returns true for optional consent after saveConsents', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      expect(await PrivacyManager.hasConsent(ConsentType.analytics), isTrue);
    });

    test('returns false for consent type that was not included', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      expect(await PrivacyManager.hasConsent(ConsentType.marketing), isFalse);
    });

    test('returns false after consent is withdrawn', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      await PrivacyManager.withdrawConsent(ConsentType.analytics);
      expect(await PrivacyManager.hasConsent(ConsentType.analytics), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // saveConsents()
  // -------------------------------------------------------------------------
  group('saveConsents()', () {
    test('always persists essential even when not in the passed set', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      expect(await PrivacyManager.hasConsent(ConsentType.essential), isTrue);
    });

    test('persists a timestamp after saving', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      expect(await PrivacyManager.hasProvidedConsent(), isTrue);
    });

    test('clears previous consents before saving new ones', () async {
      // First save with marketing.
      await PrivacyManager.saveConsents({ConsentType.marketing});
      // Second save without marketing.
      await PrivacyManager.saveConsents({ConsentType.analytics});

      expect(await PrivacyManager.hasConsent(ConsentType.marketing), isFalse);
      expect(await PrivacyManager.hasConsent(ConsentType.analytics), isTrue);
    });

    test('saves all provided consent types', () async {
      final consents = {
        ConsentType.analytics,
        ConsentType.marketing,
        ConsentType.personalization,
      };
      await PrivacyManager.saveConsents(consents);
      for (final type in consents) {
        expect(
          await PrivacyManager.hasConsent(type),
          isTrue,
          reason: '${type.name} should be true after saveConsents',
        );
      }
    });

    test('saving empty set still persists essential and timestamp', () async {
      await PrivacyManager.saveConsents({});
      expect(await PrivacyManager.hasConsent(ConsentType.essential), isTrue);
      expect(await PrivacyManager.hasProvidedConsent(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // getGrantedConsents()
  // -------------------------------------------------------------------------
  group('getGrantedConsents()', () {
    test('returns only essential when no consents saved', () async {
      final granted = await PrivacyManager.getGrantedConsents();
      // essential.isRequired == true so it defaults to true even when not set.
      expect(granted, contains(ConsentType.essential));
    });

    test('returns all granted consents after saveConsents', () async {
      await PrivacyManager.saveConsents({
        ConsentType.analytics,
        ConsentType.social,
      });
      final granted = await PrivacyManager.getGrantedConsents();
      expect(granted, containsAll([ConsentType.essential, ConsentType.analytics, ConsentType.social]));
    });

    test('does not return consents that were not granted', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      final granted = await PrivacyManager.getGrantedConsents();
      expect(granted, isNot(contains(ConsentType.marketing)));
    });
  });

  // -------------------------------------------------------------------------
  // withdrawConsent()
  // -------------------------------------------------------------------------
  group('withdrawConsent()', () {
    test('silently ignores withdrawal of essential consent', () async {
      // No exception should be thrown.
      await expectLater(
        PrivacyManager.withdrawConsent(ConsentType.essential),
        completes,
      );
      // Essential is still true (always required).
      expect(await PrivacyManager.hasConsent(ConsentType.essential), isTrue);
    });

    test('withdrawing a granted optional consent sets it to false', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      expect(await PrivacyManager.hasConsent(ConsentType.analytics), isTrue);

      await PrivacyManager.withdrawConsent(ConsentType.analytics);
      expect(await PrivacyManager.hasConsent(ConsentType.analytics), isFalse);
    });

    test('withdrawing a consent that was never granted is a no-op', () async {
      // Should not throw.
      await expectLater(
        PrivacyManager.withdrawConsent(ConsentType.marketing),
        completes,
      );
      expect(await PrivacyManager.hasConsent(ConsentType.marketing), isFalse);
    });

    test('withdrawing one consent does not affect others', () async {
      await PrivacyManager.saveConsents({
        ConsentType.analytics,
        ConsentType.marketing,
      });
      await PrivacyManager.withdrawConsent(ConsentType.analytics);
      expect(await PrivacyManager.hasConsent(ConsentType.analytics), isFalse);
      expect(await PrivacyManager.hasConsent(ConsentType.marketing), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // hasProvidedConsent()
  // -------------------------------------------------------------------------
  group('hasProvidedConsent()', () {
    test('returns false before any consent is saved', () async {
      final result = await PrivacyManager.hasProvidedConsent();
      expect(result, isFalse);
    });

    test('returns true after saveConsents is called', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      expect(await PrivacyManager.hasProvidedConsent(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // needsConsentUpdate()
  // -------------------------------------------------------------------------
  group('needsConsentUpdate()', () {
    test('returns true when no consents have been saved (null version)', () async {
      final result = await PrivacyManager.needsConsentUpdate();
      expect(result, isTrue);
    });

    test('returns false when consents are fresh and version matches', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      final result = await PrivacyManager.needsConsentUpdate();
      expect(result, isFalse);
    });

    test('returns true when consent timestamp is older than 365 days', () async {
      // Write a timestamp 366 days in the past directly into the box.
      await PrivacyManager.saveConsents({ConsentType.analytics});

      final box = await HiveBoxManagerEnhanced().openBox<dynamic>('user_consents');
      final oldTimestamp =
          DateTime.now().subtract(const Duration(days: 366)).toIso8601String();
      await box.put('consent_timestamp', oldTimestamp);

      final result = await PrivacyManager.needsConsentUpdate();
      expect(result, isTrue);
    });

    test('returns false when consent timestamp is recent (< 365 days)', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});

      final box = await HiveBoxManagerEnhanced().openBox<dynamic>('user_consents');
      final recentTimestamp =
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
      await box.put('consent_timestamp', recentTimestamp);

      final result = await PrivacyManager.needsConsentUpdate();
      expect(result, isFalse);
    });

    test('returns true when privacy policy version differs', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});

      final box = await HiveBoxManagerEnhanced().openBox<dynamic>('user_consents');
      await box.put('privacy_policy_version', 'v0.9.0'); // Old version

      final result = await PrivacyManager.needsConsentUpdate();
      expect(result, isTrue);
    });

    test('returns true when timestamp value is not a string', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});

      final box = await HiveBoxManagerEnhanced().openBox<dynamic>('user_consents');
      await box.put('consent_timestamp', 12345); // Non-string value

      final result = await PrivacyManager.needsConsentUpdate();
      expect(result, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // getConsentTimestamp()
  // -------------------------------------------------------------------------
  group('getConsentTimestamp()', () {
    test('returns null when no consent has been saved', () async {
      final ts = await PrivacyManager.getConsentTimestamp();
      expect(ts, isNull);
    });

    test('returns a DateTime after consents are saved', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      await PrivacyManager.saveConsents({ConsentType.analytics});
      final after = DateTime.now().add(const Duration(seconds: 1));

      final ts = await PrivacyManager.getConsentTimestamp();
      expect(ts, isNotNull);
      expect(ts!.isAfter(before), isTrue);
      expect(ts.isBefore(after), isTrue);
    });

    test('returns null when stored value is not a valid ISO string', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      final box = await HiveBoxManagerEnhanced().openBox<dynamic>('user_consents');
      await box.put('consent_timestamp', 'not-a-date');

      // DateTime.parse on invalid string throws; PrivacyManager should return null via catch.
      await expectLater(
        PrivacyManager.getConsentTimestamp(),
        completion(isNull),
      );
    });
  });

  // -------------------------------------------------------------------------
  // GDPR Art. 18 – Processing restriction
  // -------------------------------------------------------------------------
  group('requestProcessingRestriction()', () {
    test('sets isProcessingRestricted() to true', () async {
      expect(await PrivacyManager.isProcessingRestricted(), isFalse);

      await PrivacyManager.requestProcessingRestriction('accuracy_disputed');

      expect(await PrivacyManager.isProcessingRestricted(), isTrue);
    });

    test('stores the reason', () async {
      await PrivacyManager.requestProcessingRestriction('test_reason');
      final details = await PrivacyManager.getRestrictionDetails();

      expect(details, isNotNull);
      expect(details!['reason'], 'test_reason');
    });

    test('stores a timestamp', () async {
      await PrivacyManager.requestProcessingRestriction('test_reason');
      final details = await PrivacyManager.getRestrictionDetails();

      expect(details, isNotNull);
      expect(details!['timestamp'], isNotNull);
      // Should parse as ISO 8601.
      expect(() => DateTime.parse(details['timestamp'] as String), returnsNormally);
    });
  });

  group('liftProcessingRestriction()', () {
    test('sets isProcessingRestricted() to false', () async {
      await PrivacyManager.requestProcessingRestriction('reason');
      expect(await PrivacyManager.isProcessingRestricted(), isTrue);

      await PrivacyManager.liftProcessingRestriction();

      expect(await PrivacyManager.isProcessingRestricted(), isFalse);
    });

    test('clears restriction details', () async {
      await PrivacyManager.requestProcessingRestriction('reason');
      await PrivacyManager.liftProcessingRestriction();

      final details = await PrivacyManager.getRestrictionDetails();
      expect(details, isNull);
    });

    test('is idempotent when called without prior restriction', () async {
      await expectLater(
        PrivacyManager.liftProcessingRestriction(),
        completes,
      );
      expect(await PrivacyManager.isProcessingRestricted(), isFalse);
    });
  });

  group('isProcessingRestricted()', () {
    test('defaults to false when box is empty', () async {
      final result = await PrivacyManager.isProcessingRestricted();
      expect(result, isFalse);
    });

    test('returns true after requestProcessingRestriction', () async {
      await PrivacyManager.requestProcessingRestriction('x');
      expect(await PrivacyManager.isProcessingRestricted(), isTrue);
    });

    test('returns false after liftProcessingRestriction', () async {
      await PrivacyManager.requestProcessingRestriction('x');
      await PrivacyManager.liftProcessingRestriction();
      expect(await PrivacyManager.isProcessingRestricted(), isFalse);
    });
  });

  group('getRestrictionDetails()', () {
    test('returns null when processing is not restricted', () async {
      final details = await PrivacyManager.getRestrictionDetails();
      expect(details, isNull);
    });

    test('returns a map with isRestricted=true when restricted', () async {
      await PrivacyManager.requestProcessingRestriction('my_reason');
      final details = await PrivacyManager.getRestrictionDetails();

      expect(details, isNotNull);
      expect(details!['isRestricted'], isTrue);
      expect(details['reason'], 'my_reason');
    });

    test('returns null after restriction is lifted', () async {
      await PrivacyManager.requestProcessingRestriction('r');
      await PrivacyManager.liftProcessingRestriction();
      expect(await PrivacyManager.getRestrictionDetails(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // deleteAllUserData()
  // -------------------------------------------------------------------------
  group('deleteAllUserData()', () {
    test('completes without error', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      await expectLater(PrivacyManager.deleteAllUserData(), completes);
    });

    test('clears user_consents box (hasProvidedConsent returns false)', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      expect(await PrivacyManager.hasProvidedConsent(), isTrue);

      await PrivacyManager.deleteAllUserData();

      expect(await PrivacyManager.hasProvidedConsent(), isFalse);
    });

    test('clears all consent values after deletion', () async {
      await PrivacyManager.saveConsents({
        ConsentType.analytics,
        ConsentType.marketing,
      });

      await PrivacyManager.deleteAllUserData();

      // Optional consents should be back to false (no stored value → default false).
      expect(await PrivacyManager.hasConsent(ConsentType.analytics), isFalse);
      expect(await PrivacyManager.hasConsent(ConsentType.marketing), isFalse);
    });

    test('handles boxes that do not exist without throwing', () async {
      // No box pre-created for "workout_history" – should not throw.
      await expectLater(PrivacyManager.deleteAllUserData(), completes);
    });
  });

  // -------------------------------------------------------------------------
  // exportUserData()
  // -------------------------------------------------------------------------
  group('exportUserData()', () {
    test('returns a non-empty string', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      final result = await PrivacyManager.exportUserData();
      expect(result, isNotEmpty);
    });

    test('returned string contains export_date key', () async {
      await PrivacyManager.saveConsents({});
      final result = await PrivacyManager.exportUserData();
      expect(result, contains('export_date'));
    });

    test('returned string contains consents key', () async {
      await PrivacyManager.saveConsents({ConsentType.analytics});
      final result = await PrivacyManager.exportUserData();
      expect(result, contains('consents'));
    });

    test('works when no consents have been saved', () async {
      final result = await PrivacyManager.exportUserData();
      expect(result, isNotEmpty);
    });

    test('includes all ConsentType names in the output', () async {
      await PrivacyManager.saveConsents(ConsentType.values.toSet());
      final result = await PrivacyManager.exportUserData();
      for (final type in ConsentType.values) {
        expect(result, contains(type.name),
            reason: '${type.name} should appear in export');
      }
    });
  });
}
