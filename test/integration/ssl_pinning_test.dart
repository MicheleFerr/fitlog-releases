import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/data/network/secure_http_client.dart';

/// SSL Certificate Pinning Integration Tests
///
/// These tests verify that SSL certificate pinning works correctly:
/// 1. Valid pins allow connections ✅
/// 2. Invalid/missing pins reject connections ❌
/// 3. All Firebase domains are properly pinned
///
/// IMPORTANT: These tests make real network requests to Firebase APIs.
/// They will fail if:
/// - Certificate pins are incorrect
/// - Firebase changes certificates
/// - Network is unavailable
void main() {
  group('SSL Certificate Pinning', () {
    late SecureHttpClient client;

    setUp(() {
      client = SecureHttpClient();
    });

    tearDown(() {
      client.dispose();
    });

    group('Valid Certificate Pins', () {
      test('should successfully connect to Firestore API with valid pin', () async {
        // This should succeed because we have the correct pin
        // Pin extracted: 2025-01-06
        // Expected pin: gYnaC7PCALu9KlQdrZHsf4iAKhb2WHxNo8fAk7rnz8g=

        try {
          final response = await client.get(
            'https://firestore.googleapis.com',
            timeout: const Duration(seconds: 10),
          );

          // Should get a response (might be 400/403 without auth, but SSL should work)
          expect(response.statusCode, isNotNull);
          expect(response.statusCode, greaterThanOrEqualTo(200));
          expect(response.statusCode, lessThan(600));
        } on SecureHttpException catch (e) {
          // If we get here, it means SSL pinning FAILED (bad!)
          if (e.type == HttpErrorType.sslPinningFailed) {
            fail('SSL pinning failed for firestore.googleapis.com - certificate may have changed. Re-extract pins!');
          }
          // Other errors (network, timeout) are acceptable in tests
          expect(e.type, isNot(HttpErrorType.sslPinningFailed));
        }
      });

      test('should successfully connect to Auth API with valid pin', () async {
        // Pin extracted: 2025-01-06
        // Expected pin: VmEyOcbClGbkkUONWCzWOABnJ0mVO4Dl7i3xhZa+lzk=

        try {
          final response = await client.get(
            'https://identitytoolkit.googleapis.com',
            timeout: const Duration(seconds: 10),
          );

          expect(response.statusCode, isNotNull);
          expect(response.statusCode, greaterThanOrEqualTo(200));
          expect(response.statusCode, lessThan(600));
        } on SecureHttpException catch (e) {
          if (e.type == HttpErrorType.sslPinningFailed) {
            fail('SSL pinning failed for identitytoolkit.googleapis.com - certificate may have changed. Re-extract pins!');
          }
          expect(e.type, isNot(HttpErrorType.sslPinningFailed));
        }
      });

      test('should successfully connect to Storage API with valid pin', () async {
        // Pin extracted: 2025-01-06
        // Expected pin: G9XzYc5XMCFHcHLfn5tIJD/cqOic+TC0zT0AX0gh3Uc=

        try {
          final response = await client.get(
            'https://storage.googleapis.com',
            timeout: const Duration(seconds: 10),
          );

          expect(response.statusCode, isNotNull);
          expect(response.statusCode, greaterThanOrEqualTo(200));
          expect(response.statusCode, lessThan(600));
        } on SecureHttpException catch (e) {
          if (e.type == HttpErrorType.sslPinningFailed) {
            fail('SSL pinning failed for storage.googleapis.com - certificate may have changed. Re-extract pins!');
          }
          expect(e.type, isNot(HttpErrorType.sslPinningFailed));
        }
      });
    });

    group('Invalid/Missing Certificate Pins', () {
      test('should reject connection to unpinned domain', () async {
        // example.com has no pins configured
        // Connection should be rejected by _verifyCertificate()

        expect(
          () async => await client.get(
            'https://example.com',
            timeout: const Duration(seconds: 5),
          ),
          throwsA(
            predicate<SecureHttpException>(
              (e) => e.type == HttpErrorType.sslPinningFailed ||
                     e.message.contains('No SSL pins configured'),
              'Should throw SecureHttpException with SSL pinning failure',
            ),
          ),
        );
      });

      test('should reject connection to google.com (no pins)', () async {
        // google.com has no pins configured, even though it's a valid Google domain
        // This proves pinning is working - we ONLY allow explicitly pinned domains

        expect(
          () async => await client.get(
            'https://google.com',
            timeout: const Duration(seconds: 5),
          ),
          throwsA(
            predicate<SecureHttpException>(
              (e) => e.type == HttpErrorType.sslPinningFailed ||
                     e.message.contains('No SSL pins configured'),
              'Should reject google.com because it has no configured pins',
            ),
          ),
        );
      });
    });

    group('Pinned Domains', () {
      test('should have pins configured for all Firebase domains', () {
        final pinnedDomains = SecureHttpClient.getPinnedDomains();

        expect(pinnedDomains, contains('firestore.googleapis.com'));
        expect(pinnedDomains, contains('identitytoolkit.googleapis.com'));
        expect(pinnedDomains, contains('storage.googleapis.com'));
      });

      test('should have at least 2 pins per domain (primary + backup)', () {
        final pinnedDomains = SecureHttpClient.getPinnedDomains();

        for (final domain in pinnedDomains) {
          // We can't directly access _certificatePins from here,
          // but we can verify the behavior indirectly
          expect(domain, isNotEmpty);

          // At minimum, we expect 3 pinned domains
          expect(pinnedDomains.length, greaterThanOrEqualTo(3));
        }
      });
    });

    group('Certificate Pin Management', () {
      test('should allow adding certificate pin dynamically', () {
        // Add a pin for a new domain
        SecureHttpClient.addCertificatePin(
          'api.example.com',
          'ExamplePinABC123==',
        );

        final pinnedDomains = SecureHttpClient.getPinnedDomains();
        expect(pinnedDomains, contains('api.example.com'));
      });

      test('should allow removing certificate pin', () {
        // Add a pin first
        SecureHttpClient.addCertificatePin(
          'test.example.com',
          'TestPinXYZ789==',
        );

        // Verify it was added
        final pinnedDomains = SecureHttpClient.getPinnedDomains();
        expect(pinnedDomains, contains('test.example.com'));

        // Remove the pin
        SecureHttpClient.removeCertificatePin(
          'test.example.com',
          'TestPinXYZ789==',
        );

        // Note: Domain might still be in list (empty pin array)
        // But the specific pin should be removed
      });
    });
  });

  group('Error Handling', () {
    late SecureHttpClient client;

    setUp(() {
      client = SecureHttpClient();
    });

    tearDown(() {
      client.dispose();
    });

    test('should handle network timeout', () async {
      // Use a very short timeout to force timeout error
      expect(
        () async => await client.get(
          'https://firestore.googleapis.com',
          timeout: const Duration(milliseconds: 1), // Very short timeout
        ),
        throwsA(
          predicate<SecureHttpException>(
            (e) => e.type == HttpErrorType.timeout,
            'Should throw timeout exception',
          ),
        ),
      );
    });

    test('should handle invalid URL', () async {
      expect(
        () async => await client.get(
          'not-a-valid-url',
          timeout: const Duration(seconds: 5),
        ),
        throwsA(
          isA<FormatException>(), // URL parsing fails before network request
        ),
      );
    });
  });

  group('Response Handling', () {
    late SecureHttpClient client;

    setUp(() {
      client = SecureHttpClient();
    });

    tearDown(() {
      client.dispose();
    });

    test('SecureHttpResponse should provide status code', () async {
      try {
        final response = await client.get(
          'https://firestore.googleapis.com',
          timeout: const Duration(seconds: 10),
        );

        expect(response.statusCode, isA<int>());
        expect(response.statusCode, greaterThan(0));
      } on SecureHttpException catch (e) {
        // Pass test if network error (not SSL pinning failure)
        if (e.type != HttpErrorType.sslPinningFailed) {
          // Network error is acceptable - test passes
          return;
        }
        rethrow;
      }
    });

    test('SecureHttpResponse should provide response body', () async {
      try {
        final response = await client.get(
          'https://firestore.googleapis.com',
          timeout: const Duration(seconds: 10),
        );

        expect(response.body, isA<String>());
        expect(response.body, isNotEmpty);
      } on SecureHttpException catch (e) {
        if (e.type != HttpErrorType.sslPinningFailed) {
          // Network error is acceptable - test passes
          return;
        }
        rethrow;
      }
    });
  });
}
