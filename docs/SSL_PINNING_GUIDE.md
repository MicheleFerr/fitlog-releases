# SSL Pinning Implementation Guide

## Overview

SSL Certificate Pinning is a security technique that prevents man-in-the-middle (MITM) attacks by validating that the server's SSL certificate matches known, trusted certificates.

**OWASP Mobile Security**: M3 - Insecure Communication

## Why SSL Pinning?

Traditional SSL/TLS validation relies on Certificate Authorities (CAs). If a CA is compromised or issues a rogue certificate, attackers can perform MITM attacks. SSL pinning solves this by:

✅ **Validating against known certificates** - Only accept specific certificates you trust
✅ **Preventing CA compromise attacks** - Even if CA is hacked, your app won't trust rogue certs
✅ **Protecting sensitive data** - Ensure all API communication is with legitimate servers
✅ **OWASP compliance** - Meets OWASP Mobile Top 10 security requirements

## Implementation Status

**Current State**: ✅ SecureHttpClient implemented with SSL pinning
**Firebase SDK**: ✅ Already secured (built-in SSL/TLS validation)
**Custom APIs**: 🟡 Ready for use when needed

## How to Use SecureHttpClient

### Basic Usage

```dart
import 'package:gymbro_flutter_new/shared/data/network/secure_http_client.dart';

// Create client instance
final client = SecureHttpClient();

// Make GET request
try {
  final response = await client.get('https://api.fitlogpro.app/workouts');

  if (response.isSuccess) {
    final data = response.json;
    // Process data
  }
} on SecureHttpException catch (e) {
  if (e.type == HttpErrorType.sslPinningFailed) {
    // Possible MITM attack detected!
    debugPrint('⚠️ SSL pinning failed - blocking request');
  }
}

// Don't forget to dispose
client.dispose();
```

### POST Request

```dart
final response = await client.post(
  'https://api.fitlogpro.app/workouts',
  headers: {'Authorization': 'Bearer $token'},
  body: {
    'name': 'My Workout',
    'exercises': [...],
  },
);
```

### With Riverpod Provider

```dart
final secureHttpClientProvider = Provider<SecureHttpClient>((ref) {
  final client = SecureHttpClient();

  // Dispose when provider is disposed
  ref.onDispose(() => client.dispose());

  return client;
});

// Use in repository
class WorkoutRepository {
  final SecureHttpClient _client;

  WorkoutRepository(this._client);

  Future<List<Workout>> fetchWorkouts() async {
    final response = await _client.get('https://api.fitlogpro.app/workouts');
    // ...
  }
}
```

## Obtaining Certificate Pins

### Method 1: Using OpenSSL (Recommended)

```bash
# Step 1: Connect to server and get certificate
openssl s_client -connect api.fitlogpro.app:443 -servername api.fitlogpro.app < /dev/null 2>/dev/null | \
  openssl x509 -pubkey -noout -outform pem > pubkey.pem

# Step 2: Convert to DER and hash
openssl pkey -pubin -in pubkey.pem -outform der | \
  openssl dgst -sha256 -binary | \
  openssl enc -base64

# Output: base64-encoded SHA-256 hash of public key
# Example: aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890ABCDEF=
```

### Method 2: Using Browser DevTools

1. Open target URL in Chrome/Firefox
2. Click on the padlock icon → "Certificate"
3. Go to "Details" tab
4. Click "Export" and save as DER format
5. Run OpenSSL command:

```bash
openssl x509 -inform der -in certificate.der -pubkey -noout | \
  openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | \
  openssl enc -base64
```

### Method 3: Using curl + OpenSSL

```bash
# One-liner to get pin
echo | \
  openssl s_client -connect api.fitlogpro.app:443 -servername api.fitlogpro.app 2>/dev/null | \
  openssl x509 -pubkey -noout | \
  openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | \
  openssl enc -base64
```

## Adding Certificate Pins

### For Firebase (Example)

```dart
// In lib/shared/data/network/secure_http_client.dart
static final Map<String, List<String>> _certificatePins = {
  'firestore.googleapis.com': [
    // Primary certificate pin (obtained via OpenSSL)
    'aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890ABCDEF=',

    // Backup certificate pin (for rotation)
    'bBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890ABCDEF=',
  ],

  'firebasestorage.googleapis.com': [
    'cBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890ABCDEF=',
    'dBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890ABCDEF=',
  ],
};
```

### For Custom API

```dart
'api.fitlogpro.app': [
  // Current production certificate
  'YOUR_PRIMARY_PIN_HERE',

  // Backup certificate (keep for 30-day transition)
  'YOUR_BACKUP_PIN_HERE',
],
```

## Certificate Rotation Process

Certificate pins must be updated before certificates expire. Follow this process:

### Step 1: Add New Certificate Pin (30 days before expiry)

```dart
'api.fitlogpro.app': [
  'OLD_PIN_HERE',           // Keep old pin
  'NEW_PIN_HERE',           // Add new pin
  'BACKUP_PIN_HERE',        // Keep backup
],
```

### Step 2: Deploy App Update

- Release app with both old and new pins
- Monitor for SSL pinning failures
- Wait 30 days for users to update

### Step 3: Remove Old Pin (After 30 days)

```dart
'api.fitlogpro.app': [
  'NEW_PIN_HERE',           // Now primary
  'BACKUP_PIN_HERE',        // Still backup
],
```

### Step 4: Update Last Pin Date

```dart
static const String _lastPinUpdate = '2025-11-21'; // Update date
```

## Testing SSL Pinning

### Test Valid Certificate

```dart
test('should accept valid certificate', () async {
  final client = SecureHttpClient();

  // Should succeed
  final response = await client.get('https://firestore.googleapis.com');
  expect(response.isSuccess, true);

  client.dispose();
});
```

### Test MITM Attack Simulation

```dart
test('should reject invalid certificate', () async {
  final client = SecureHttpClient();

  // Configure invalid pins
  SecureHttpClient.addCertificatePin('example.com', 'INVALID_PIN');

  // Should throw SSL pinning exception
  expect(
    () => client.get('https://example.com'),
    throwsA(isA<SecureHttpException>()),
  );

  client.dispose();
});
```

### Manual Testing with Proxy

1. Install proxy tool (e.g., Charles Proxy, mitmproxy)
2. Configure device to use proxy
3. Try to intercept HTTPS traffic
4. **Expected**: SSL pinning should block the connection

## Security Considerations

### ✅ Best Practices

1. **Always pin at least 2 certificates** - Primary + backup
2. **Update pins before expiry** - Monitor certificate expiration
3. **Use backup pins** - For seamless rotation
4. **Log pinning failures** - Monitor for MITM attempts
5. **Test regularly** - Verify pins are working

### ⚠️ Common Mistakes

1. ❌ **Hardcoding expired certificates** - Always check expiry dates
2. ❌ **Single pin per domain** - Need backup for rotation
3. ❌ **No monitoring** - Track pinning failures
4. ❌ **Ignoring failures** - Pinning failure = possible attack
5. ❌ **Late rotation** - Update pins 30+ days before expiry

### 🔒 Additional Security

- **Use with network security config** (Android)
- **Combine with App Transport Security** (iOS)
- **Enable certificate transparency** monitoring
- **Implement fallback strategy** for emergency updates

## Monitoring & Alerts

### Log SSL Pinning Failures

SSL pinning failures are automatically logged in debug mode:

```
❌ SSL pin verification FAILED for api.fitlogpro.app
   Expected one of: [pin1, pin2]
   Received: different_pin
```

### Production Monitoring

Consider implementing:

```dart
// In production, send pinning failures to analytics
if (!isValid) {
  await AnalyticsService.logSecurityEvent(
    event: 'ssl_pinning_failed',
    domain: host,
    severity: 'CRITICAL',
  );
}
```

## Emergency Pin Update

If you need to update pins immediately (e.g., certificate compromised):

### Option 1: Hot Update (Firebase Remote Config)

```dart
// Fetch pins from Firebase Remote Config
final remotePins = await remoteConfig.getString('certificate_pins');
final pins = jsonDecode(remotePins);

// Add to client
for (final domain in pins.keys) {
  for (final pin in pins[domain]) {
    SecureHttpClient.addCertificatePin(domain, pin);
  }
}
```

### Option 2: Force App Update

- Release emergency app update with new pins
- Use Firebase In-App Messaging to notify users
- Block old app versions if necessary

## References

- [OWASP Mobile Top 10 - M3](https://owasp.org/www-project-mobile-top-10/2016-risks/m3-insecure-communication)
- [OWASP Certificate Pinning Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Pinning_Cheat_Sheet.html)
- [RFC 7469 - Public Key Pinning](https://tools.ietf.org/html/rfc7469)

## Support

For questions about SSL pinning implementation:
1. Check this guide first
2. Review `lib/shared/data/network/secure_http_client.dart` implementation
3. Consult OWASP Mobile Security documentation
4. Contact security team for certificate-related issues
