# SSL Certificate Pinning - Security Implementation

**Status**: ✅ Implemented with real certificate pins
**Last Updated**: 2025-01-06
**Next Pin Rotation**: 2027-01-06 (2 years)

---

## 📋 Overview

SSL certificate pinning validates that the server's SSL certificate matches known, trusted certificates. This prevents man-in-the-middle (MITM) attacks even if a Certificate Authority (CA) is compromised.

**Security Benefits**:
- ✅ Prevents MITM attacks
- ✅ Protects against rogue certificates
- ✅ Validates server identity cryptographically
- ✅ Complies with OWASP Mobile Top 10 (M3 - Insecure Communication)

---

## 🔐 Current Certificate Pins

### Firebase Firestore API
**Domain**: `firestore.googleapis.com`
```
Primary Pin:  gYnaC7PCALu9KlQdrZHsf4iAKhb2WHxNo8fAk7rnz8g=
Backup Pin:   iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0= (GTS Root R1)
Extracted:    2025-01-06
Expires:      ~2027 (typical Google cert lifecycle: 2 years)
```

### Firebase Authentication API
**Domain**: `identitytoolkit.googleapis.com`
```
Primary Pin:  VmEyOcbClGbkkUONWCzWOABnJ0mVO4Dl7i3xhZa+lzk=
Backup Pin:   iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0= (GTS Root R1)
Extracted:    2025-01-06
Expires:      ~2027
```

### Firebase Storage API
**Domain**: `storage.googleapis.com`
```
Primary Pin:  G9XzYc5XMCFHcHLfn5tIJD/cqOic+TC0zT0AX0gh3Uc=
Backup Pin:   iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0= (GTS Root R1)
Extracted:    2025-01-06
Expires:      ~2027
```

**Backup Pin Explained**:
- **GTS Root R1**: Google Trust Services root CA certificate
- **Purpose**: Allows rotation of leaf certificates without app update
- **Public Pin**: `iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0=`
- **Validity**: 5-10 years (root CAs rotate infrequently)

---

## 🛠️ Extracting Certificate Pins

### Method 1: OpenSSL Command Line (Recommended)

```bash
# Extract primary pin for any domain
openssl s_client -connect firestore.googleapis.com:443 \
  -servername firestore.googleapis.com </dev/null 2>/dev/null | \
  openssl x509 -pubkey -noout | \
  openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | \
  openssl enc -base64

# Output: gYnaC7PCALu9KlQdrZHsf4iAKhb2WHxNo8fAk7rnz8g=
```

**For all Firebase services**:
```bash
# Firestore
openssl s_client -connect firestore.googleapis.com:443 \
  -servername firestore.googleapis.com </dev/null 2>/dev/null | \
  openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | openssl enc -base64

# Firebase Auth
openssl s_client -connect identitytoolkit.googleapis.com:443 \
  -servername identitytoolkit.googleapis.com </dev/null 2>/dev/null | \
  openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | openssl enc -base64

# Firebase Storage
openssl s_client -connect storage.googleapis.com:443 \
  -servername storage.googleapis.com </dev/null 2>/dev/null | \
  openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | openssl enc -base64
```

### Method 2: Chrome DevTools (Visual)

1. Open the Firebase domain in Chrome
2. Click the **padlock icon** → **Certificate**
3. Navigate to **Details** tab
4. Click **Export** → Save as `cert.der` (DER format)
5. Extract pin:
   ```bash
   openssl x509 -inform DER -in cert.der -pubkey -noout | \
     openssl pkey -pubin -outform der | \
     openssl dgst -sha256 -binary | \
     openssl enc -base64
   ```

### Method 3: Firefox (Alternative)

1. Navigate to Firebase domain
2. Click **padlock** → **Connection secure** → **More information**
3. Click **View Certificate** → **Details**
4. Click **Export** → Save as `cert.pem`
5. Extract pin:
   ```bash
   openssl x509 -in cert.pem -pubkey -noout | \
     openssl pkey -pubin -outform der | \
     openssl dgst -sha256 -binary | \
     openssl enc -base64
   ```

---

## 🔄 Certificate Pin Rotation Process

### When to Rotate

- **Firebase certificate expires** (~every 2 years)
- **Google changes root CA** (rare, ~10 years)
- **Security incident** (compromised CA, immediate rotation)

### How to Rotate (30-Day Transition Period)

#### Step 1: Extract New Pins (Day 0)

```bash
# Extract new pin for domain that changed
openssl s_client -connect firestore.googleapis.com:443 \
  -servername firestore.googleapis.com </dev/null 2>/dev/null | \
  openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | openssl enc -base64

# Output (example): NEW_PIN_HERE_abc123xyz=
```

#### Step 2: Add New Pin to Array (Keep Old Pin)

```dart
// lib/shared/data/network/secure_http_client.dart

'firestore.googleapis.com': [
  'gYnaC7PCALu9KlQdrZHsf4iAKhb2WHxNo8fAk7rnz8g=',  // ✅ OLD pin (keep for 30 days)
  'NEW_PIN_HERE_abc123xyz=',                          // ✅ NEW pin (added today)
  'iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0=',  // ✅ Backup pin (GTS Root R1)
],
```

**Why keep old pin?**
- Users with old app versions can still connect
- Gradual rollout without breaking existing installs
- 30-day grace period for users to update

#### Step 3: Deploy App Update (Day 0-7)

```bash
# Update version in pubspec.yaml
version: 1.0.0+50  # Increment build number

# Deploy to TestFlight/Play Console
flutter build ios --release
flutter build apk --release

# Submit to App Store / Play Store
```

#### Step 4: Monitor Metrics (Day 7-30)

**Check Firebase Console → App Check → Metrics**:
- SSL handshake failures should be **< 0.1%**
- Token validation success rate should be **> 99%**

**If failures > 5%**:
- Check if certificate changed again
- Verify pin extraction was correct
- Roll back if necessary

#### Step 5: Remove Old Pin (Day 30)

```dart
// After 30 days, remove old pin
'firestore.googleapis.com': [
  'NEW_PIN_HERE_abc123xyz=',                          // ✅ Current pin
  'iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0=',  // ✅ Backup pin (GTS Root R1)
],

// Update last rotation date
static const String _lastPinUpdate = '2025-02-06';  // New date
```

#### Step 6: Deploy Final Update

```bash
# Increment version again
version: 1.0.0+51

# Deploy to stores
flutter build ios --release
flutter build apk --release
```

---

## 🧪 Testing SSL Pinning

### Integration Test

```dart
// test/integration/ssl_pinning_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/data/network/secure_http_client.dart';

void main() {
  group('SSL Certificate Pinning', () {
    late SecureHttpClient client;

    setUp(() {
      client = SecureHttpClient();
    });

    tearDown(() {
      client.dispose();
    });

    test('should successfully connect to Firestore API with valid pin', () async {
      // This should succeed because we have the correct pin
      final response = await client.get('https://firestore.googleapis.com');

      expect(response.statusCode, equals(200));
    });

    test('should successfully connect to Auth API with valid pin', () async {
      final response = await client.get('https://identitytoolkit.googleapis.com');

      expect(response.statusCode, equals(200));
    });

    test('should successfully connect to Storage API with valid pin', () async {
      final response = await client.get('https://storage.googleapis.com');

      expect(response.statusCode, equals(200));
    });

    test('should reject connection to unpinned domain', () async {
      // This should fail because we don't have pins for example.com
      expect(
        () async => await client.get('https://example.com'),
        throwsA(isA<SecureHttpException>()),
      );
    });
  });
}
```

### Manual Testing

```bash
# Run integration tests
flutter test test/integration/ssl_pinning_test.dart

# Expected output:
# ✅ should successfully connect to Firestore API with valid pin
# ✅ should successfully connect to Auth API with valid pin
# ✅ should successfully connect to Storage API with valid pin
# ✅ should reject connection to unpinned domain
```

### Testing on Real Device

1. **Build release app**:
   ```bash
   flutter build ios --release
   flutter build apk --release
   ```

2. **Install on physical device**

3. **Test Firebase operations**:
   - Login with Google/Apple
   - Create workout (tests Firestore with pinning)
   - View analytics (tests Firestore reads)
   - Upload profile photo (tests Storage with pinning)

4. **Check logs** (should see):
   ```
   🔒 SecureHttpClient initialized with SSL pinning
      Pinned domains: firestore.googleapis.com, identitytoolkit.googleapis.com, storage.googleapis.com
      Last pin update: 2025-01-06
   ✅ SSL pin verified for firestore.googleapis.com
   ✅ SSL pin verified for identitytoolkit.googleapis.com
   ✅ SSL pin verified for storage.googleapis.com
   ```

---

## ⚠️ Troubleshooting

### Problem 1: "SSL handshake failed - possible MITM attack"

**Symptom**: App can't connect to Firebase after enabling SSL pinning

**Cause**: Certificate pin mismatch (wrong pin or certificate changed)

**Solution**:
1. Re-extract certificate pin:
   ```bash
   openssl s_client -connect firestore.googleapis.com:443 \
     -servername firestore.googleapis.com </dev/null 2>/dev/null | \
     openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | \
     openssl dgst -sha256 -binary | openssl enc -base64
   ```

2. Compare with pin in `secure_http_client.dart`

3. Update if different

4. Rebuild and redeploy app

### Problem 2: "No SSL pins configured for [domain]"

**Symptom**: Connection rejected to domain not in `_certificatePins`

**Cause**: Trying to connect to domain without configured pins

**Solution**:
1. Extract pin for new domain
2. Add to `_certificatePins` map in `secure_http_client.dart`
3. Rebuild app

### Problem 3: SSL pinning works in debug but fails in release

**Symptom**: Debug builds connect fine, release builds fail

**Cause**: Certificate pinning verification logic error or obfuscation

**Solution**:
1. Check `_verifyCertificate()` method
2. Ensure pins are strings, not computed values
3. Test release build on physical device (not emulator)

### Problem 4: VPN/Proxy causes SSL failures

**Symptom**: App works on direct connection, fails with VPN/corporate proxy

**Cause**: VPN/proxy performs SSL inspection (replaces certificates)

**Expected Behavior**: SSL pinning SHOULD fail with VPN/proxy doing SSL inspection
- This is CORRECT security behavior
- VPN is performing MITM (even if legitimate)
- Pinning prevents this

**User Communication**:
- Show friendly error: "SSL security verification failed. Please disable VPN/proxy."
- Provide toggle: "Skip SSL verification" (debug only, NEVER in production)

### Problem 5: Certificate expired before rotation

**Symptom**: Sudden SSL failures across all users

**Cause**: Google rotated certificate earlier than expected

**Solution (EMERGENCY - 5 minute recovery)**:
1. **Disable pinning temporarily**:
   ```dart
   // lib/shared/data/network/secure_http_client.dart
   bool _verifyCertificate(X509Certificate cert, String host, int port) {
     // TEMPORARY: Skip pinning verification
     return true;  // ⚠️ INSECURE - temporary only!
   }
   ```

2. **Deploy hotfix immediately**:
   ```bash
   flutter build ios --release
   flutter build apk --release
   # Submit to stores with expedited review
   ```

3. **Extract new pins** (while hotfix deploys):
   ```bash
   openssl s_client -connect firestore.googleapis.com:443 ...
   ```

4. **Re-enable pinning with new pins**:
   ```dart
   'firestore.googleapis.com': [
     'NEW_PIN_HERE=',
     'iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0=',
   ],
   ```

5. **Deploy fixed version**

**Prevention**:
- Set calendar reminder for 60 days before expected expiration
- Monitor Firebase status page for certificate rotation announcements
- Always keep backup pin (GTS Root R1)

---

## 📊 Monitoring & Alerting

### Metrics to Monitor

**Firebase Console → App Check → Metrics**:
- **Token validation success rate**: Should be > 99%
- **Rejected requests**: Should be < 10/day
- **SSL handshake failures**: Should be < 0.1%

**Firebase Crashlytics**:
- Filter by: `SecureHttpException` with type `sslPinningFailed`
- Alert if count > 100 events/hour

**Custom Analytics Event**:
```dart
// Log SSL verification failures
if (!isValid) {
  FirebaseAnalytics.instance.logEvent(
    name: 'ssl_pinning_failed',
    parameters: {
      'domain': host,
      'expected_pins': pins.join(','),
      'received_pin': publicKeyHash,
    },
  );
}
```

### Alert Thresholds

| Metric | Threshold | Action |
|--------|-----------|--------|
| SSL handshake failures | > 5% of requests | Investigate certificate changes |
| Token validation failures | > 1% | Check App Check config |
| Crashlytics `sslPinningFailed` | > 100/hour | Emergency pin rotation |
| Network errors spike | > 20% increase | Check Firebase status |

---

## 🔒 Security Best Practices

### ✅ DO

- **Store at least 2 pins per domain** (primary + backup)
- **Use backup pin from root CA** (GTS Root R1 for Google services)
- **Rotate pins before expiration** (60-90 days before cert expires)
- **Keep old pin for 30 days** during rotation
- **Test on physical devices** (not emulators)
- **Monitor SSL handshake metrics** in production
- **Document pin extraction date** in code comments
- **Set calendar reminders** for pin rotation

### ❌ DON'T

- **Never disable pinning in production** (even temporarily)
- **Never commit expired pins** (check expiration dates)
- **Never pin to only one certificate** (always have backup)
- **Never skip testing** after pin rotation
- **Never trust emulator SSL** (pins may not work correctly)
- **Never use pins from untrusted sources** (always extract yourself)
- **Never forget to update `_lastPinUpdate` date**

---

## 📚 Resources

**Official Documentation**:
- [OWASP Certificate Pinning](https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning)
- [Google Certificate Transparency](https://transparencyreport.google.com/https/certificates)
- [Firebase App Check](https://firebase.google.com/docs/app-check)

**Tools**:
- [OpenSSL](https://www.openssl.org/) - Certificate extraction
- [Certificate Transparency Log](https://crt.sh/) - Search for certificates
- [SSL Labs](https://www.ssllabs.com/ssltest/) - Test SSL configuration

**Firebase Root CAs**:
- [GTS Root R1](https://pki.goog/repository/): `iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0=`
- [GTS Root R2](https://pki.goog/repository/): (alternative root CA)

---

## 📅 Maintenance Calendar

| Date | Task | Owner | Status |
|------|------|-------|--------|
| 2025-01-06 | Initial pin extraction | Team 3 | ✅ Complete |
| 2026-11-06 | Pre-expiration check (60 days before) | DevOps | ⏳ Scheduled |
| 2027-01-06 | Certificate rotation (if needed) | DevOps | ⏳ Scheduled |
| Every 90 days | Review SSL handshake metrics | DevOps | 🔄 Recurring |

---

**Last Updated**: 2025-01-06
**Next Review**: 2026-11-06 (60 days before expected expiration)
**Document Owner**: Security Team
