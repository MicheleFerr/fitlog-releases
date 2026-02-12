import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import '../../helpers/test_setup.dart';

/// Test to verify HiveBoxManagerEnhanced.initialize() correctly pre-opens critical boxes
void main() {
  setUpAll(() async {
    mockSecureStorage();
    // Initialize Hive with temporary directory for tests
    Hive.init('./test/.hive_test_init');
  });

  tearDown(() async {
    // Clean up all boxes after each test
    await Hive.deleteFromDisk();

    // Reset HiveBoxManagerEnhanced for next test (singleton state)
    HiveBoxManagerEnhanced().resetForTesting();

    // ✅ CRITICAL: Also reset the static initialization flag for this test suite
    // This is specific to initialization tests where we test the initialize() method itself
    // Other test suites don't need this because they call initialize() once in setUpAll()
    HiveBoxManagerEnhanced.resetInitializationForTesting();
  });

  group('HiveBoxManagerEnhanced Initialization Tests', () {
    test('should pre-open critical boxes during initialize()', () async {
      // Verify boxes are NOT open before initialize
      expect(Hive.isBoxOpen('user_consents'), false);
      expect(Hive.isBoxOpen('privacy'), false);

      // Initialize HiveBoxManagerEnhanced
      await HiveBoxManagerEnhanced.initialize();

      // Verify critical boxes ARE open after initialize
      expect(Hive.isBoxOpen('user_consents'), true,
          reason: 'user_consents box should be pre-opened for GDPR compliance');
      expect(Hive.isBoxOpen('privacy'), true,
          reason: 'privacy box should be pre-opened for Privacy Manager');

      // Verify manager tracks these boxes
      final manager = HiveBoxManagerEnhanced();
      expect(manager.isBoxOpen('user_consents'), true);
      expect(manager.isBoxOpen('privacy'), true);
      expect(manager.openBoxCount, 2,
          reason: 'Should have exactly 2 pre-opened boxes');
    });

    test('should handle multiple initialize() calls gracefully', () async {
      // First call
      await HiveBoxManagerEnhanced.initialize();
      expect(Hive.isBoxOpen('user_consents'), true);
      expect(Hive.isBoxOpen('privacy'), true);

      final firstBoxCount = HiveBoxManagerEnhanced().openBoxCount;

      // Second call should be no-op
      await HiveBoxManagerEnhanced.initialize();

      // Should not create duplicate boxes
      expect(HiveBoxManagerEnhanced().openBoxCount, firstBoxCount,
          reason: 'Should not duplicate boxes on second initialize()');
    });

    test('should set _isHiveInitialized flag before opening boxes', () async {
      // This test verifies the chicken-and-egg fix
      // If flag is set AFTER opening boxes, openBox() would fail

      await HiveBoxManagerEnhanced.initialize();

      // If we reach here without StateError, the flag was set correctly
      expect(Hive.isBoxOpen('user_consents'), true);
      expect(Hive.isBoxOpen('privacy'), true);
    });

    test('should allow opening additional boxes after initialize()', () async {
      // Initialize with critical boxes
      await HiveBoxManagerEnhanced.initialize();

      final manager = HiveBoxManagerEnhanced();

      // Open additional box (simulating app_config or other typed box)
      final additionalBox = await manager.openBox<Map>('test_additional');
      expect(additionalBox.isOpen, true);
      expect(manager.openBoxCount, 3,
          reason: 'Should have 2 critical + 1 additional = 3 boxes');
    });

    test('pre-opened boxes should be accessible via manager', () async {
      await HiveBoxManagerEnhanced.initialize();

      final manager = HiveBoxManagerEnhanced();

      // Access pre-opened boxes (should NOT trigger a new open)
      final consentsBox = await manager.openBox<dynamic>('user_consents');
      final privacyBox = await manager.openBox<dynamic>('privacy');

      // Verify they work
      expect(consentsBox.isOpen, true);
      expect(privacyBox.isOpen, true);

      // Should still have only 2 boxes (no duplicates)
      expect(manager.openBoxCount, 2);
    });
  });
}
