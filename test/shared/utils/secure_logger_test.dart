import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/utils/secure_logger.dart';

void main() {
  group('SecureLogger', () {
    test('should have public log methods', () {
      // Test that SecureLogger methods exist and can be called
      expect(
        () => SecureLogger.log('Test message'),
        returnsNormally,
      );

      expect(
        () => SecureLogger.info('Info message'),
        returnsNormally,
      );

      expect(
        () => SecureLogger.warning('Warning message'),
        returnsNormally,
      );

      expect(
        () => SecureLogger.error('Error message'),
        returnsNormally,
      );
    });

    test('should handle metadata in logs', () {
      final metadata = {
        'userId': 'user_123',
        'action': 'login',
      };

      expect(
        () => SecureLogger.info('Test', metadata: metadata),
        returnsNormally,
      );

      expect(
        () => SecureLogger.warning('Test', metadata: metadata),
        returnsNormally,
      );

      expect(
        () => SecureLogger.error('Test', metadata: metadata),
        returnsNormally,
      );
    });

    test('should partially redact strings', () {
      const value = 'user123456789';
      final redacted = SecureLogger.partialRedact(value, show: 4);

      expect(redacted, 'user...6789');
      expect(redacted, isNot(contains('1234567')));
    });

    test('should fully redact short strings', () {
      const value = '12345';
      final redacted = SecureLogger.partialRedact(value, show: 4);

      expect(redacted, '[REDACTED]');
    });

    test('should handle empty strings', () {
      const value = '';
      final redacted = SecureLogger.partialRedact(value);

      expect(redacted, '[REDACTED]');
    });

    test('should handle exact length strings', () {
      const value = '12345678'; // length = 8, show = 4*2 = 8
      final redacted = SecureLogger.partialRedact(value, show: 4);

      expect(redacted, '[REDACTED]');
    });
  });
}
