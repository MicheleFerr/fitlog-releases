# Root/Jailbreak Detection Guide

## Overview

Root/Jailbreak detection identifies compromised devices to protect sensitive user data and app integrity.

**OWASP Mobile Security**: M8 - Code Tampering

## Why Detect Root/Jailbreak?

Rooted/jailbroken devices bypass OS security restrictions, enabling:

❌ **Reverse Engineering** - Attackers can inspect app code and assets
❌ **Data Theft** - Access to encrypted storage and sensitive files
❌ **Code Injection** - Hooking frameworks can modify app behavior
❌ **Certificate Tampering** - Bypass SSL pinning and intercept traffic
❌ **Piracy** - In-app purchase bypass and license violations

## Implementation Status

**Current State**: ✅ DeviceSecurityChecker implemented
**Detection Methods**: ✅ File-based, property-based, behavior-based
**Response Strategy**: 🟡 Warning only (configurable)

## Detection Methods

### iOS Jailbreak Detection

**File-based Detection:**
```
- /Applications/Cydia.app
- /bin/bash
- /usr/sbin/sshd
- /private/var/lib/cydia
- /usr/libexec/cydia/
```

**Behavior-based Detection:**
- Can write outside sandbox
- Suspicious URL schemes (cydia://, sileo://)
- Dynamic libraries loaded (MobileSubstrate)

**Common Jailbreak Tools:**
- Cydia, Sileo, Zebra
- Checkra1n, Unc0ver, Taurine
- Chimera, Electra

### Android Root Detection

**Binary Detection:**
```
- /system/bin/su
- /system/xbin/su
- /sbin/su
- /data/local/su
```

**App Detection:**
```
- com.topjohnwu.magisk (Magisk)
- eu.chainfire.supersu (SuperSU)
- com.koushikdutta.superuser (Superuser)
- com.kingroot.kinguser (KingRoot)
```

**Build Properties:**
- ro.build.tags = "test-keys" (custom ROM)
- ro.debuggable = "1" (debug mode)
- ro.secure = "0" (ADB enabled)

## How to Use

### Basic Usage

```dart
import 'package:gymbro_flutter_new/shared/domain/security/device_security_checker.dart';

// Initialize checker (usually in main.dart)
final securityChecker = DeviceSecurityChecker();
await securityChecker.initialize();

// Check security status
if (securityChecker.isDeviceCompromised) {
  // Device is rooted/jailbroken
  print('⚠️ Device security compromised!');
  print('Security level: ${securityChecker.securityLevel}%');
  print('Status: ${securityChecker.securityStatus}');

  // Show warning to user
  _showSecurityWarning(securityChecker.securityRecommendations);
}
```

### With Riverpod Provider

```dart
// Provider for security checker
final deviceSecurityProvider = FutureProvider<DeviceSecurityChecker>((ref) async {
  final checker = DeviceSecurityChecker();
  await checker.initialize();
  return checker;
});

// Use in widget
class SecureScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityAsync = ref.watch(deviceSecurityProvider);

    return securityAsync.when(
      data: (checker) {
        if (checker.isDeviceCompromised) {
          return SecurityWarningScreen(checker: checker);
        }
        return NormalScreen();
      },
      loading: () => LoadingIndicator(),
      error: (err, stack) => ErrorScreen(error: err),
    );
  }
}
```

### In Main Initialization

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize security checker
  final securityChecker = DeviceSecurityChecker();
  await securityChecker.initialize();

  // Log security status
  if (kDebugMode) {
    print('Device Security: ${securityChecker.securityStatus}');
    print('Recommendations: ${securityChecker.securityRecommendations}');
  }

  runApp(MyApp(securityChecker: securityChecker));
}
```

## Response Strategies

### 1. Warning Only (Recommended - GDPR Friendly)

Show informational dialog but allow usage:

```dart
if (securityChecker.isDeviceCompromised) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(context.l10n.securityWarning),
      content: Text(context.l10n.deviceCompromisedWarning),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.iUnderstand),
        ),
      ],
    ),
  );
}
```

**Pros:**
- ✅ User-friendly (doesn't block legitimate users)
- ✅ GDPR compliant (no data collected)
- ✅ No legal liability (user assumes risk)

**Cons:**
- ⚠️ Doesn't prevent usage on compromised device

### 2. Feature Restriction (Balanced Approach)

Disable sensitive features on compromised devices:

```dart
class PaymentScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final security = ref.watch(deviceSecurityProvider).value;

    if (security?.isDeviceCompromised ?? false) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.security, size: 64, color: Colors.orange),
            Text(context.l10n.paymentDisabledOnRootedDevice),
            Text(context.l10n.pleaseUseSecureDevice),
          ],
        ),
      );
    }

    return NormalPaymentScreen();
  }
}
```

**Features to Restrict:**
- 💳 Payments and in-app purchases
- 🔐 OAuth/SSO authentication
- 📤 Export of sensitive data
- 🔑 API key generation

**Pros:**
- ✅ Protects sensitive operations
- ✅ Still allows basic app usage
- ✅ Reduces liability for data breaches

**Cons:**
- ⚠️ May frustrate power users
- ⚠️ Requires feature-by-feature logic

### 3. Full Block (Not Recommended)

Prevent all app usage:

```dart
if (securityChecker.isDeviceCompromised) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 100, color: Colors.red),
            Text(
              'App cannot run on rooted/jailbroken devices',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
```

**Pros:**
- ✅ Maximum security
- ✅ Prevents any potential abuse

**Cons:**
- ❌ Blocks legitimate users (developers, testers, privacy-conscious users)
- ❌ Poor user experience
- ❌ May violate app store policies
- ❌ Can be bypassed with simple hooks

## Bypassing Detection (Why Full Block is Ineffective)

Root/jailbreak detection can be bypassed using:

- **Frida/Objection**: Runtime hooking
- **Xposed Framework**: Method swizzling
- **Liberty Lite**: Jailbreak detection bypass
- **Magisk Hide**: Root hiding

**Conclusion**: Detection is a deterrent, not a guarantee. Use warning + feature restriction instead of full blocking.

## Best Practices

### ✅ DO:

1. **Show transparent warnings** - Inform users about risks
2. **Restrict sensitive features** - Disable payments, OAuth on compromised devices
3. **Log security events** - Track detection rates for analytics
4. **Test thoroughly** - Verify detection works on real devices
5. **Update detection** - New jailbreak methods emerge regularly

### ❌ DON'T:

1. **Don't block all usage** - Frustrates legitimate users
2. **Don't collect device info** - Privacy violation (GDPR)
3. **Don't trust detection 100%** - Can be bypassed
4. **Don't punish users** - Many root for legitimate reasons (custom ROMs, privacy)
5. **Don't ignore false positives** - Some devices trigger false alarms

## Security Recommendations by Severity

### High Risk (Security Level < 50)
- ❌ **Disable**: Payments, API keys, OAuth
- ⚠️ **Warn**: Display persistent security banner
- 📊 **Log**: Report security event (no PII)

### Moderate Risk (Security Level 50-79)
- ⚠️ **Warn**: Show dismissible dialog on app launch
- 📊 **Monitor**: Track feature usage patterns

### Secure (Security Level ≥ 80)
- ✅ **Allow**: All features enabled
- 📊 **Track**: Normal analytics

## Localizations

Add to `assets/i18n/app_en.arb`:

```json
{
  "securityWarning": "Security Warning",
  "deviceCompromisedWarning": "Your device appears to be rooted/jailbroken. This may compromise your data security. Proceed with caution.",
  "iUnderstand": "I Understand",
  "paymentDisabledOnRootedDevice": "Payments are disabled on rooted/jailbroken devices for your protection.",
  "pleaseUseSecureDevice": "Please use a secure device to access this feature.",
  "securityLevel": "Security Level",
  "deviceStatus": "Device Status"
}
```

Italian (`app_it.arb`):

```json
{
  "securityWarning": "Avviso di Sicurezza",
  "deviceCompromisedWarning": "Il tuo dispositivo sembra essere rootato/jailbroken. Questo potrebbe compromettere la sicurezza dei tuoi dati. Procedi con cautela.",
  "iUnderstand": "Ho Capito",
  "paymentDisabledOnRootedDevice": "I pagamenti sono disabilitati su dispositivi rootati/jailbroken per la tua protezione.",
  "pleaseUseSecureDevice": "Utilizza un dispositivo sicuro per accedere a questa funzione.",
  "securityLevel": "Livello di Sicurezza",
  "deviceStatus": "Stato Dispositivo"
}
```

## Testing

### Test on Real Devices

**iOS:**
1. Test on jailbroken iPhone (checkra1n/unc0ver)
2. Verify Cydia detection works
3. Check sandbox write detection
4. Test on normal iPhone for false positives

**Android:**
1. Test on rooted Android (Magisk)
2. Verify su binary detection
3. Check build tags detection
4. Test on custom ROM devices

### Unit Tests

```dart
test('should detect jailbroken device', () async {
  final checker = DeviceSecurityChecker();
  await checker.initialize();

  // Mock jailbreak files
  // Add test assertions
});

test('should detect rooted device', () async {
  final checker = DeviceSecurityChecker();
  await checker.initialize();

  // Mock root binaries
  // Add test assertions
});
```

## Privacy & GDPR Compliance

**Important**: Root/jailbreak detection is performed **entirely on-device**.

✅ **No data transmitted** - All checks are local
✅ **No PII collected** - Detection doesn't identify users
✅ **Transparent** - Users are informed of security checks
✅ **Optional** - Can disable sensitive features instead of blocking

**GDPR Articles:**
- Article 25: Privacy by design (on-device only)
- Article 32: Security of processing (protects user data)

## Monitoring & Analytics

### Track Detection Rates (Privacy-Safe)

```dart
if (securityChecker.isDeviceCompromised) {
  // Log event (no PII, no device identifiers)
  await PrivacySafeAnalytics.trackEvent(
    name: 'device_security_warning',
    props: {
      'security_level': securityChecker.securityLevel,
      'platform': Platform.operatingSystem,
      // NO: device_id, user_id, or any identifiers
    },
  );
}
```

### Metrics to Track

- Detection rate (% of users with compromised devices)
- False positive rate (user reports)
- Feature restriction impact (conversion loss)
- Security event trends (increasing/decreasing)

## References

- [OWASP Mobile Top 10 - M8](https://owasp.org/www-project-mobile-top-10/2016-risks/m8-code-tampering)
- [iOS Jailbreak Detection](https://www.theiphonewiki.com/wiki/Bypassing_Jailbreak_Detection)
- [Android Root Detection](https://developer.android.com/training/safetynet/attestation)

## Support

For questions about root/jailbreak detection:
1. Check this guide first
2. Review `lib/shared/domain/security/device_security_checker.dart`
3. Test on real rooted/jailbroken devices
4. Consult OWASP Mobile Security documentation
