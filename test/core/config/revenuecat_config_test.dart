import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/config/revenuecat_config.dart';

void main() {
  group('RevenueCatConfig.resolveApiKey', () {
    test('returns configured value when provided', () {
      final resolved = RevenueCatConfig.resolveApiKey(
        configuredValue: '  appl_configured_key  ',
        targetPlatform: TargetPlatform.iOS,
      );

      expect(resolved, 'appl_configured_key');
    });

    test('falls back to the default Apple key on iOS when unset', () {
      final resolved = RevenueCatConfig.resolveApiKey(
        targetPlatform: TargetPlatform.iOS,
      );

      expect(resolved, RevenueCatConfig.defaultAppleApiKey);
    });

    test('returns empty when unset on Android', () {
      final resolved = RevenueCatConfig.resolveApiKey(
        targetPlatform: TargetPlatform.android,
      );

      expect(resolved, isEmpty);
    });
  });
}
