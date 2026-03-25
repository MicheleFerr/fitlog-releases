import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/config/firebase_config.dart';

void main() {
  group('FirebaseConfig.hasRequiredCoreValues', () {
    test('returns true when all required values are present', () {
      final isValid = FirebaseConfig.hasRequiredCoreValues(
        apiKey: 'api-key',
        appId: 'app-id',
        messagingSenderId: 'sender-id',
        projectId: 'project-id',
      );

      expect(isValid, isTrue);
    });

    test('returns false when one required value is blank', () {
      final isValid = FirebaseConfig.hasRequiredCoreValues(
        apiKey: 'api-key',
        appId: '   ',
        messagingSenderId: 'sender-id',
        projectId: 'project-id',
      );

      expect(isValid, isFalse);
    });
  });
}
