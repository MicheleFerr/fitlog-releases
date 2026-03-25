import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/config/google_sign_in_config.dart';

void main() {
  group('GoogleSignInConfig.resolveServerClientId', () {
    test('returns configured value when provided', () {
      final resolved = GoogleSignInConfig.resolveServerClientId(
        configuredValue:
            '  custom-server-client-id.apps.googleusercontent.com  ',
      );

      expect(resolved, 'custom-server-client-id.apps.googleusercontent.com');
    });

    test('falls back to the default Firebase web client id when unset', () {
      final resolved = GoogleSignInConfig.resolveServerClientId();

      expect(resolved, GoogleSignInConfig.defaultServerClientId);
    });

    test('falls back to the default Firebase web client id when blank', () {
      final resolved = GoogleSignInConfig.resolveServerClientId(
        configuredValue: '   ',
      );

      expect(resolved, GoogleSignInConfig.defaultServerClientId);
    });
  });
}
