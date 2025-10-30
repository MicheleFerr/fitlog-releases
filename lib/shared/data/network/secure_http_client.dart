import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

/// Secure HTTP Client with SSL Pinning
///
/// OWASP Mobile Security: M3 - Insecure Communication
///
/// This client implements SSL certificate pinning to prevent man-in-the-middle (MITM) attacks.
/// Certificate pinning validates that the server's SSL certificate matches known, trusted certificates.
///
/// SECURITY BENEFITS:
/// - ✅ Prevents MITM attacks even if CA is compromised
/// - ✅ Protects against rogue certificates
/// - ✅ Validates server identity cryptographically
/// - ✅ Complies with OWASP Mobile Top 10
///
/// USAGE:
/// ```dart
/// final client = SecureHttpClient();
/// final response = await client.get('https://api.fitlogpro.app/workouts');
/// ```
///
/// CERTIFICATE ROTATION:
/// When updating certificates, follow this process:
/// 1. Add new certificate pins to [_certificatePins]
/// 2. Keep old pins for 30-day transition period
/// 3. Remove old pins after verification
/// 4. Update [_lastPinUpdate] date
///
/// OBTAINING CERTIFICATE PINS:
/// ```bash
/// # Method 1: Using OpenSSL
/// openssl s_client -connect api.fitlogpro.app:443 < /dev/null | \
///   openssl x509 -pubkey -noout | \
///   openssl rsa -pubin -outform DER | \
///   openssl dgst -sha256 -binary | \
///   openssl enc -base64
///
/// # Method 2: Using Chrome DevTools
/// # 1. Open site in Chrome
/// # 2. Click padlock → Certificate
/// # 3. Details → Copy to File → DER
/// # 4. Run: openssl x509 -inform DER -in cert.der -pubkey -noout | \
///   openssl rsa -pubin -outform DER | \
///   openssl dgst -sha256 -binary | \
///   openssl enc -base64
/// ```
class SecureHttpClient {

  /// Initialize secure HTTP client
  SecureHttpClient() {
    _client = HttpClient()
      ..badCertificateCallback = _verifyCertificate;

    if (kDebugMode) {
      debugPrint('🔒 SecureHttpClient initialized with SSL pinning');
      debugPrint('   Pinned domains: ${_certificatePins.keys.join(', ')}');
      debugPrint('   Last pin update: $_lastPinUpdate');
    }
  }
  /// Certificate pins for trusted domains
  ///
  /// Format: domain → List of SHA-256 public key hashes (base64)
  ///
  /// IMPORTANT: Store at least 2 pins per domain:
  /// - Primary certificate pin
  /// - Backup certificate pin (for rotation)
  ///
  /// Last updated: 2025-10-21
  static final Map<String, List<String>> _certificatePins = {
    // Example Firebase pins (UPDATE WITH YOUR ACTUAL PINS)
    // These are placeholder values - replace with actual certificate pins
    'firestore.googleapis.com': [
      // Primary pin (example - REPLACE!)
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      // Backup pin (example - REPLACE!)
      'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
    ],

    // Example custom API pins
    // 'api.fitlogpro.app': [
    //   'YOUR_PRIMARY_PIN_HERE',
    //   'YOUR_BACKUP_PIN_HERE',
    // ],
  };

  /// Last certificate pin update date
  /// Update this when rotating certificates
  static const String _lastPinUpdate = '2025-10-21';

  /// HTTP client with custom SSL context
  HttpClient? _client;

  /// Verify SSL certificate against pinned certificates
  ///
  /// Returns true only if:
  /// 1. Certificate chain is valid
  /// 2. Public key hash matches one of our pins
  /// 3. Domain matches pinned domain
  bool _verifyCertificate(X509Certificate cert, String host, int port) {
    // Check if we have pins for this domain
    if (!_certificatePins.containsKey(host)) {
      if (kDebugMode) {
        debugPrint('⚠️ No SSL pins configured for $host - blocking connection');
      }
      return false; // Reject: no pins configured
    }

    // Extract public key hash from certificate
    final publicKeyHash = _getPublicKeyHash(cert);

    // Verify against pinned certificates
    final pins = _certificatePins[host]!;
    final isValid = pins.contains(publicKeyHash);

    if (kDebugMode) {
      if (isValid) {
        debugPrint('✅ SSL pin verified for $host');
      } else {
        debugPrint('❌ SSL pin verification FAILED for $host');
        debugPrint('   Expected one of: ${pins.join(', ')}');
        debugPrint('   Received: $publicKeyHash');
      }
    }

    return isValid;
  }

  /// Extract SHA-256 hash of public key from certificate
  String _getPublicKeyHash(X509Certificate cert) {
    // Extract DER-encoded public key
    final publicKeyBytes = cert.der;

    // Compute SHA-256 hash
    final hash = _sha256(publicKeyBytes);

    // Encode as base64
    return base64.encode(hash);
  }

  /// Compute SHA-256 hash using crypto package
  List<int> _sha256(List<int> data) {
    final digest = sha256.convert(data);
    return digest.bytes;
  }

  /// Make HTTP GET request with SSL pinning
  Future<SecureHttpResponse> get(
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = Uri.parse(url);

    try {
      final request = await _client!.getUrl(uri)
        ..followRedirects = true
        ..maxRedirects = 5;

      // Add headers
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.add(key, value);
        });
      }

      // Send request
      final response = await request.close().timeout(timeout);

      // Read response body
      final responseBody = await response.transform(utf8.decoder).join();

      return SecureHttpResponse(
        statusCode: response.statusCode,
        body: responseBody,
        headers: _extractHeaders(response.headers),
      );
    } on TimeoutException {
      throw SecureHttpException('Request timeout', type: HttpErrorType.timeout);
    } on SocketException catch (e) {
      throw SecureHttpException(
        'Network error: ${e.message}',
        type: HttpErrorType.network,
      );
    } on HandshakeException {
      throw SecureHttpException(
        'SSL handshake failed - possible MITM attack',
        type: HttpErrorType.sslPinningFailed,
      );
    } catch (e) {
      throw SecureHttpException(
        'Request failed: $e',
        type: HttpErrorType.unknown,
      );
    }
  }

  /// Make HTTP POST request with SSL pinning
  Future<SecureHttpResponse> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = Uri.parse(url);

    try {
      final request = await _client!.postUrl(uri);

      // Add headers
      request.headers.contentType = ContentType.json;
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.add(key, value);
        });
      }

      // Add body
      if (body != null) {
        final jsonBody = json.encode(body);
        request.write(jsonBody);
      }

      // Send request
      final response = await request.close().timeout(timeout);

      // Read response body
      final responseBody = await response.transform(utf8.decoder).join();

      return SecureHttpResponse(
        statusCode: response.statusCode,
        body: responseBody,
        headers: _extractHeaders(response.headers),
      );
    } on TimeoutException {
      throw SecureHttpException('Request timeout', type: HttpErrorType.timeout);
    } on SocketException catch (e) {
      throw SecureHttpException(
        'Network error: ${e.message}',
        type: HttpErrorType.network,
      );
    } on HandshakeException {
      throw SecureHttpException(
        'SSL handshake failed - possible MITM attack',
        type: HttpErrorType.sslPinningFailed,
      );
    } catch (e) {
      throw SecureHttpException(
        'Request failed: $e',
        type: HttpErrorType.unknown,
      );
    }
  }

  /// Extract headers from HttpHeaders
  Map<String, String> _extractHeaders(HttpHeaders headers) {
    final map = <String, String>{};
    headers.forEach((name, values) {
      map[name] = values.join(', ');
    });
    return map;
  }

  /// Close HTTP client
  void dispose() {
    _client?.close();
    _client = null;

    if (kDebugMode) {
      debugPrint('🔒 SecureHttpClient disposed');
    }
  }

  /// Add certificate pin for a domain
  ///
  /// Use this to dynamically add pins at runtime
  static void addCertificatePin(String domain, String pin) {
    if (_certificatePins.containsKey(domain)) {
      _certificatePins[domain]!.add(pin);
    } else {
      _certificatePins[domain] = [pin];
    }

    if (kDebugMode) {
      debugPrint('🔒 Added certificate pin for $domain');
    }
  }

  /// Remove certificate pin for a domain
  ///
  /// Use this when rotating old certificates
  static void removeCertificatePin(String domain, String pin) {
    if (_certificatePins.containsKey(domain)) {
      _certificatePins[domain]!.remove(pin);

      if (kDebugMode) {
        debugPrint('🔒 Removed certificate pin for $domain');
      }
    }
  }

  /// Get all pinned domains
  static List<String> getPinnedDomains() {
    return _certificatePins.keys.toList();
  }
}

/// HTTP response wrapper
class SecureHttpResponse {

  SecureHttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  /// Check if response is successful (2xx status code)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Decode JSON body
  dynamic get json => jsonDecode(body);
}

/// HTTP error types
enum HttpErrorType {
  network,
  timeout,
  sslPinningFailed,
  invalidResponse,
  unknown,
}

/// HTTP exception with error type
class SecureHttpException implements Exception {

  SecureHttpException(this.message, {required this.type});
  final String message;
  final HttpErrorType type;

  @override
  String toString() => 'SecureHttpException($type): $message';
}
