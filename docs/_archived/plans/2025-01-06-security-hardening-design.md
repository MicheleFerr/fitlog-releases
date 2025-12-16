# Security Hardening Implementation Plan

**Date**: 2025-01-06
**Status**: Approved ✅
**Strategy**: Comprehensive Security (Fix all findings including MEDIUM/LOW)
**Approach**: Conservative (patch-only dependency updates)
**Testing**: Automated workflow with manual smoke testing
**Execution**: Parallel agent orchestration (6 teams, ~75 min wall-clock)

---

## 📋 Executive Summary

This plan addresses all 7 security findings from the comprehensive security audit:

| Priority | Finding | Team | Branch | ETA |
|----------|---------|------|--------|-----|
| 🔴 HIGH | Outdated Firebase SDKs | Team 1 | `security/dep-updates` | 15 min |
| 🔴 HIGH | SSL Pinning Incomplete | Team 3 | `security/ssl-pinning` | 40 min |
| 🟡 CRITICAL | Exposed API Keys (mitigated) | Team 2 | `security/firebase-hardening` | 20 min |
| 🟡 MEDIUM | Input Validation Gaps | Team 4 | `security/input-validation` | 25 min |
| 🟡 MEDIUM | Secrets Management Prep | Team 5 | `security/secrets-prep` | 10 min |
| 🟢 LOW | Debug Logging | Team 6 | `security/logging-hardening` | 15 min |
| 🟢 LOW | Production App Check | Team 2 | `security/firebase-hardening` | (included) |

**Total Wall-Clock Time**: ~75 minutes (parallel execution)

---

## 🎯 Section 1: Architecture & Agent Orchestration

### Parallel Execution Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                 Parallel Phase (0-45 min)                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Team 1     │  │   Team 2     │  │   Team 3     │    │
│  │ Dependencies │  │  Firebase    │  │ SSL Pinning  │    │
│  │   15 min     │  │   20 min     │  │   40 min     │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Team 4     │  │   Team 5     │  │   Team 6     │    │
│  │    Input     │  │   Secrets    │  │   Logging    │    │
│  │   25 min     │  │   10 min     │  │   15 min     │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              Integration Phase (45-60 min)                  │
├─────────────────────────────────────────────────────────────┤
│  • Merge all branches                                       │
│  • Resolve conflicts (if any)                               │
│  • Run integration tests                                    │
│  • Flutter analyze + test                                   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│               Testing Phase (60-75 min)                     │
├─────────────────────────────────────────────────────────────┤
│  • Deploy to test device                                    │
│  • Manual smoke testing                                     │
│  • Monitor Firebase Console                                 │
│  • Verify no crashes/errors                                 │
└─────────────────────────────────────────────────────────────┘
```

### Team Assignments

| Team | Agent Type | Branch | Files Modified | Exit Criteria |
|------|-----------|--------|----------------|---------------|
| 1 | `flutter-expert` | `security/dep-updates` | `pubspec.yaml` | `flutter analyze` passes, tests pass |
| 2 | `firebase-expert` | `security/firebase-hardening` | Firebase Console config | App Check enforced, debug file deleted |
| 3 | `security-specialist` | `security/ssl-pinning` | `secure_http_client.dart` | Real pins extracted, validation tested |
| 4 | `flutter-architect` | `security/input-validation` | 4-6 screens, 1 service | XSS/SQL tests pass, unit tests 100% |
| 5 | `devops-maestro` | `security/secrets-prep` | `.gitignore`, templates | No secrets in git, docs complete |
| 6 | `devops-maestro` | `security/logging-hardening` | 10-15 files, 1 service | Zero `print()`, production config verified |

### Tool: Superpowers Parallel Agents

```bash
# Orchestration via superpowers:dispatching-parallel-agents
# Max 3 agents at once (system limit)
# Wave 1: Teams 1, 2, 3 (0-40 min)
# Wave 2: Teams 4, 5, 6 (parallel after wave 1 slots free)
```

---

## 🔧 Section 2: Component Details

### Team 1: Dependency Update (Conservative)

**Branch**: `security/dep-updates`
**Agent**: `flutter-expert`
**Time**: 15 minutes

#### Tasks

1. **Update Firebase SDKs** (patch versions only):
   ```yaml
   # pubspec.yaml changes
   firebase_auth: ^6.1.1 → ^6.1.4
   firebase_messaging: ^16.0.3 → ^16.0.5
   firebase_analytics: ^12.0.3 → ^12.0.4
   audioplayers: ^6.5.1 → ^6.5.2
   ```

2. **Validation**:
   ```bash
   flutter pub outdated  # Verify no major/minor bumps
   flutter pub get
   flutter analyze       # Must pass (0 errors)
   flutter test          # Must pass (100%)
   ```

3. **Deliverables**:
   - Updated `pubspec.yaml`
   - Regenerated `pubspec.lock`
   - Commit: `security: update Firebase SDKs to latest patch versions`

#### Exit Criteria
- ✅ All dependencies updated conservatively (patch only)
- ✅ `flutter analyze` passes (0 errors)
- ✅ All tests pass
- ✅ No breaking changes introduced

#### Rollback Plan
```bash
git checkout main -- pubspec.yaml pubspec.lock
flutter pub get
flutter clean && flutter pub get
```

---

### Team 2: Firebase Security Hardening

**Branch**: `security/firebase-hardening`
**Agent**: `firebase-expert`
**Time**: 20 minutes

#### Tasks

1. **Enable App Check Rate Limiting**:
   - Navigate to: Firebase Console → App Check → Apps
   - Enable "Enforce" mode for:
     - Cloud Firestore ✅
     - Cloud Functions ✅
     - Firebase Storage ✅
   - Set rate limits: 1000 req/min per device
   - Screenshot confirmation

2. **Delete Debug Token Generator**:
   ```bash
   git rm lib/main_debug_appcheck.dart
   ```

3. **Production App Check Config**:
   - Verify `ios/Runner/Info.plist` has App Attest provider
   - Verify `android/app/build.gradle` has Play Integrity API
   - Document debug token workflow (for future debug needs)

4. **Create Documentation**:
   ```markdown
   # docs/FIREBASE_SECURITY.md
   - App Check setup guide
   - Debug token workflow (when needed)
   - Rate limiting configuration
   - Troubleshooting guide
   ```

#### Deliverables
- Firebase Console screenshot: Enforce mode enabled
- Deleted file: `lib/main_debug_appcheck.dart`
- New documentation: `docs/FIREBASE_SECURITY.md` (~300 lines)
- Commit: `security: enable App Check enforcement and remove debug tools`

#### Exit Criteria
- ✅ App Check in Enforce mode (verified via screenshot)
- ✅ Debug token generator removed from codebase
- ✅ Documentation complete with setup guide
- ✅ App tested with production App Check (manual)

#### Rollback Plan
- **App Check**: Disable "Enforce" → switch back to "Monitor" mode
- **Debug file**: Recreate temporarily if needed for debugging
- **Rate limiting**: Increase limits if legit users blocked

---

### Team 3: SSL Certificate Pinning

**Branch**: `security/ssl-pinning`
**Agent**: `security-specialist` or `devops-maestro`
**Time**: 40 minutes (longest task - critical path)

#### Tasks

1. **Extract Real Certificate Pins**:
   ```bash
   # Firestore API
   openssl s_client -connect firestore.googleapis.com:443 \
     -servername firestore.googleapis.com < /dev/null | \
     openssl x509 -pubkey -noout | \
     openssl pkey -pubin -outform der | \
     openssl dgst -sha256 -binary | \
     openssl enc -base64

   # Firebase Auth API
   openssl s_client -connect identitytoolkit.googleapis.com:443 \
     -servername identitytoolkit.googleapis.com < /dev/null | \
     openssl x509 -pubkey -noout | \
     openssl pkey -pubin -outform der | \
     openssl dgst -sha256 -binary | \
     openssl enc -base64

   # Cloud Storage (if used)
   openssl s_client -connect storage.googleapis.com:443 \
     -servername storage.googleapis.com < /dev/null | \
     openssl x509 -pubkey -noout | \
     openssl pkey -pubin -outform der | \
     openssl dgst -sha256 -binary | \
     openssl enc -base64
   ```

2. **Update secure_http_client.dart**:
   ```dart
   // lib/shared/data/network/secure_http_client.dart
   static final Map<String, List<String>> _certificatePins = {
     'firestore.googleapis.com': [
       '[REAL_PIN_FROM_OPENSSL_COMMAND]',  // ✅ Primary pin
       '[BACKUP_PIN_INTERMEDIATE_CA]',     // ✅ Backup pin
     ],
     'identitytoolkit.googleapis.com': [
       '[REAL_PIN_FROM_OPENSSL_COMMAND]',
       '[BACKUP_PIN_INTERMEDIATE_CA]',
     ],
     'storage.googleapis.com': [
       '[REAL_PIN_FROM_OPENSSL_COMMAND]',
       '[BACKUP_PIN_INTERMEDIATE_CA]',
     ],
   };
   ```

3. **Backup Pin Strategy**:
   - Extract backup pins from intermediate CA certificates
   - Google's cert chain usually has 2-3 levels
   - Document pin rotation process (every 2 years typically)

4. **Testing**:
   ```bash
   # Integration test
   flutter test test/integration/ssl_pinning_test.dart

   # Manual test
   flutter run --release
   # Try: Create workout, sync to Firebase, view analytics
   # Should work normally → pins valid ✅
   ```

5. **Create Documentation**:
   ```markdown
   # docs/SSL_PINNING.md
   - Certificate extraction commands
   - Pin rotation process (every 2 years)
   - Backup pin strategy
   - Troubleshooting guide
   - What to do if pins expire
   ```

#### Deliverables
- Updated: `lib/shared/data/network/secure_http_client.dart` with real pins
- New integration test: `test/integration/ssl_pinning_test.dart`
- New documentation: `docs/SSL_PINNING.md` (~400 lines)
- Commit: `security: implement real SSL certificate pinning for Firebase APIs`

#### Exit Criteria
- ✅ Real certificate pins extracted and verified
- ✅ Backup pins configured (2 pins per domain minimum)
- ✅ Pin validation tested (pass and fail cases)
- ✅ Documentation complete with rotation process
- ✅ Manual test succeeds (Firebase sync works)

#### Rollback Plan
```bash
# Disable pinning temporarily
git checkout main -- lib/shared/data/network/secure_http_client.dart

# Or: Comment out pin validation in code
# Replace _certificatePins with empty map
```

**Indicators of failure**:
- `SecurityException: SSL certificate doesn't match pinned certificates`
- Network requests fail with SSL errors
- Firebase sync stops working

---

### Team 4: Input Validation & Sanitization

**Branch**: `security/input-validation`
**Agent**: `flutter-architect`
**Time**: 25 minutes

#### Tasks

1. **Create InputValidator Service**:
   ```dart
   // lib/shared/domain/services/input_validator.dart
   import 'package:flutter/foundation.dart';

   /// Input Validator Service
   ///
   /// Provides client-side input sanitization and validation
   /// to prevent XSS, SQL injection, and other injection attacks.
   ///
   /// SECURITY: Defense in depth - server-side validation required too
   class InputValidator {
     /// Sanitize user input (remove HTML, SQL injection attempts)
     static String sanitize(String input) {
       return input
         .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
         .replaceAll(RegExp(r'[;\'"\\]'), '') // Remove SQL chars
         .trim();
     }

     /// Validate workout name
     static bool isValidWorkoutName(String name) {
       return name.length >= 3 &&
              name.length <= 50 &&
              RegExp(r'^[a-zA-Z0-9\s\-_]+$').hasMatch(name);
     }

     /// Validate exercise notes
     static bool isValidNotes(String notes) {
       return notes.length <= 500; // Max 500 chars
     }

     /// Validate numeric inputs
     static bool isValidWeight(double? weight) {
       return weight != null && weight >= 0 && weight <= 1000;
     }

     static bool isValidReps(int? reps) {
       return reps != null && reps >= 1 && reps <= 100;
     }

     /// Validate user bio
     static bool isValidBio(String bio) {
       return bio.length <= 200;
     }

     /// Validate template name
     static bool isValidTemplateName(String name) {
       return name.length >= 3 &&
              name.length <= 50 &&
              RegExp(r'^[a-zA-Z0-9\s\-_]+$').hasMatch(name);
     }
   }
   ```

2. **Apply Validation to User-Facing Inputs**:

   **File 1**: `lib/features/workout/presentation/screens/workout_form_screen.dart`
   ```dart
   // Before saving workout
   final sanitizedName = InputValidator.sanitize(workoutNameController.text);
   if (!InputValidator.isValidWorkoutName(sanitizedName)) {
     SnackBarService.showError(context, context.l10n.invalidWorkoutName);
     return;
   }
   ```

   **File 2**: `lib/features/workout/presentation/widgets/exercise_card_widget.dart`
   ```dart
   // Before saving exercise notes
   final sanitizedNotes = InputValidator.sanitize(notesController.text);
   if (!InputValidator.isValidNotes(sanitizedNotes)) {
     SnackBarService.showError(context, context.l10n.notesTooLong);
     return;
   }
   ```

   **File 3**: `lib/features/user/presentation/screens/profile_edit_screen.dart`
   ```dart
   // Before saving user bio
   final sanitizedBio = InputValidator.sanitize(bioController.text);
   if (!InputValidator.isValidBio(sanitizedBio)) {
     SnackBarService.showError(context, context.l10n.bioTooLong);
     return;
   }
   ```

   **File 4**: `lib/features/workout_templates/presentation/screens/template_creation_screen.dart`
   ```dart
   // Before saving template name
   final sanitizedName = InputValidator.sanitize(templateNameController.text);
   if (!InputValidator.isValidTemplateName(sanitizedName)) {
     SnackBarService.showError(context, context.l10n.invalidTemplateName);
     return;
   }
   ```

3. **Create Unit Tests**:
   ```dart
   // test/shared/domain/services/input_validator_test.dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:gymbro_flutter_new/shared/domain/services/input_validator.dart';

   void main() {
     group('InputValidator', () {
       group('sanitize', () {
         test('removes HTML tags', () {
           expect(
             InputValidator.sanitize('<script>alert("xss")</script>Hello'),
             'alertxssHello',
           );
         });

         test('removes SQL injection attempts', () {
           expect(
             InputValidator.sanitize("'; DROP TABLE workouts; --"),
             ' DROP TABLE workouts ',
           );
         });

         test('handles emoji and unicode', () {
           expect(
             InputValidator.sanitize('Leg Day 💪'),
             'Leg Day 💪',
           );
         });
       });

       group('isValidWorkoutName', () {
         test('accepts valid names', () {
           expect(InputValidator.isValidWorkoutName('Leg Day'), true);
           expect(InputValidator.isValidWorkoutName('Push-Pull-Legs'), true);
           expect(InputValidator.isValidWorkoutName('Upper_Body_2024'), true);
         });

         test('rejects too short names', () {
           expect(InputValidator.isValidWorkoutName('ab'), false);
         });

         test('rejects too long names', () {
           expect(
             InputValidator.isValidWorkoutName('a' * 51),
             false,
           );
         });

         test('rejects invalid characters', () {
           expect(InputValidator.isValidWorkoutName('<script>'), false);
           expect(InputValidator.isValidWorkoutName("'; DROP"), false);
         });
       });

       group('isValidWeight', () {
         test('accepts valid weights', () {
           expect(InputValidator.isValidWeight(100), true);
           expect(InputValidator.isValidWeight(0), true);
           expect(InputValidator.isValidWeight(500), true);
         });

         test('rejects negative weights', () {
           expect(InputValidator.isValidWeight(-10), false);
         });

         test('rejects excessive weights', () {
           expect(InputValidator.isValidWeight(1500), false);
         });

         test('rejects null', () {
           expect(InputValidator.isValidWeight(null), false);
         });
       });

       group('isValidReps', () {
         test('accepts valid reps', () {
           expect(InputValidator.isValidReps(10), true);
           expect(InputValidator.isValidReps(1), true);
           expect(InputValidator.isValidReps(100), true);
         });

         test('rejects zero or negative reps', () {
           expect(InputValidator.isValidReps(0), false);
           expect(InputValidator.isValidReps(-5), false);
         });

         test('rejects excessive reps', () {
           expect(InputValidator.isValidReps(101), false);
         });
       });
     });
   }
   ```

#### Deliverables
- New service: `lib/shared/domain/services/input_validator.dart`
- Updated screens: 4-6 files with validation applied
- New unit tests: `test/shared/domain/services/input_validator_test.dart`
- Commit: `security: add input sanitization and validation service`

#### Exit Criteria
- ✅ InputValidator service created with comprehensive methods
- ✅ Applied to all user-facing inputs (4+ screens)
- ✅ Unit tests pass (100% coverage)
- ✅ XSS/SQL injection test cases pass
- ✅ No hardcoded validation logic in widgets

#### Rollback Plan
```bash
git checkout main -- lib/shared/domain/services/input_validator.dart
git checkout main -- lib/features/*/presentation/screens/*_screen.dart
```

**Indicators of failure**:
- Users can't save valid workouts (false positives)
- Validation crashes (null-safety issues)
- Performance degradation

---

### Team 5: Secrets Management Preparation

**Branch**: `security/secrets-prep`
**Agent**: `devops-maestro`
**Time**: 10 minutes

#### Tasks

1. **Update .gitignore**:
   ```gitignore
   # .gitignore additions

   # Secrets & Environment
   .env
   .env.local
   .env.production
   .env.staging
   **/secrets/
   **/*.key
   **/*.pem
   **/*.p12
   **/*.keystore

   # Firebase
   firebase_options_prod.dart
   google-services.json
   GoogleService-Info.plist

   # iOS Provisioning
   ios/**/*.mobileprovision
   ios/**/*.p12
   ios/**/*.cer

   # Android Signing
   android/app/release.keystore
   android/app/debug.keystore
   android/key.properties
   ```

2. **Create Cloud Functions Template** (not deployed yet):
   ```javascript
   // functions/index.js
   const functions = require('firebase-functions');
   const admin = require('firebase-admin');

   admin.initializeApp();

   /**
    * Server-side workout validation
    *
    * Validates workout data before saving to Firestore.
    * Prevents injection attacks and enforces business rules.
    */
   exports.validateWorkout = functions.https.onCall(async (data, context) => {
     // Authentication check
     if (!context.auth) {
       throw new functions.https.HttpsError(
         'unauthenticated',
         'User must be authenticated'
       );
     }

     const { workoutName, exercises } = data;
     const userId = context.auth.uid;

     // Input validation
     if (!workoutName || workoutName.length < 3 || workoutName.length > 50) {
       throw new functions.https.HttpsError(
         'invalid-argument',
         'Invalid workout name (3-50 chars required)'
       );
     }

     // Remove HTML/SQL injection attempts
     const sanitizedName = workoutName
       .replace(/<[^>]*>/g, '')
       .replace(/[;'"\\]/g, '');

     // Business logic validation
     if (!Array.isArray(exercises) || exercises.length === 0) {
       throw new functions.https.HttpsError(
         'invalid-argument',
         'Workout must have at least one exercise'
       );
     }

     // Rate limiting check (prevent spam)
     const userDoc = await admin.firestore()
       .collection('users')
       .doc(userId)
       .get();

     const lastWorkoutTime = userDoc.data()?.lastWorkoutTime || 0;
     const now = Date.now();

     if (now - lastWorkoutTime < 10000) { // 10 seconds
       throw new functions.https.HttpsError(
         'resource-exhausted',
         'Please wait before creating another workout'
       );
     }

     return {
       success: true,
       validated: true,
       sanitizedName,
     };
   });

   /**
    * Server-side exercise validation
    */
   exports.validateExercise = functions.https.onCall(async (data, context) => {
     if (!context.auth) {
       throw new functions.https.HttpsError('unauthenticated', 'Auth required');
     }

     const { weight, reps, notes } = data;

     // Numeric validation
     if (weight < 0 || weight > 1000) {
       throw new functions.https.HttpsError(
         'invalid-argument',
         'Weight must be 0-1000 kg'
       );
     }

     if (reps < 1 || reps > 100) {
       throw new functions.https.HttpsError(
         'invalid-argument',
         'Reps must be 1-100'
       );
     }

     // Sanitize notes
     const sanitizedNotes = (notes || '')
       .replace(/<[^>]*>/g, '')
       .substring(0, 500);

     return {
       success: true,
       validated: true,
       sanitizedNotes,
     };
   });
   ```

3. **Create package.json** (for Cloud Functions):
   ```json
   {
     "name": "functions",
     "description": "Cloud Functions for GymBro",
     "scripts": {
       "serve": "firebase emulators:start --only functions",
       "shell": "firebase functions:shell",
       "start": "npm run shell",
       "deploy": "firebase deploy --only functions",
       "logs": "firebase functions:log"
     },
     "engines": {
       "node": "18"
     },
     "main": "index.js",
     "dependencies": {
       "firebase-admin": "^11.11.0",
       "firebase-functions": "^4.5.0"
     },
     "devDependencies": {
       "firebase-functions-test": "^3.1.0"
     },
     "private": true
   }
   ```

4. **Create Documentation**:
   ```markdown
   # docs/SECRETS_MANAGEMENT.md

   ## GitHub Secrets Setup

   1. Navigate to: Repository → Settings → Secrets and variables → Actions
   2. Add the following secrets:
      - `FIREBASE_API_KEY_PROD`: Production Firebase API key
      - `FIREBASE_PROJECT_ID`: Firebase project ID
      - `ANDROID_SIGNING_KEY`: Base64-encoded Android keystore
      - `IOS_CERTIFICATE`: Base64-encoded iOS certificate

   ## Cloud Functions Deployment

   1. Install Firebase CLI:
      ```bash
      npm install -g firebase-tools
      ```

   2. Login to Firebase:
      ```bash
      firebase login
      ```

   3. Deploy functions:
      ```bash
      cd functions
      npm install
      firebase deploy --only functions
      ```

   ## Environment Variables Best Practices

   - NEVER commit `.env` files to git
   - Use GitHub Secrets for CI/CD
   - Use Firebase Remote Config for app-level config
   - Rotate API keys every 90 days

   ## API Key Rotation Process

   1. Generate new key in Firebase Console
   2. Update GitHub Secrets
   3. Deploy new app version
   4. Monitor for errors (24h)
   5. Revoke old key after confirmation
   ```

#### Deliverables
- Updated `.gitignore` with secrets exclusions
- Template: `functions/index.js` (not deployed)
- Template: `functions/package.json`
- Documentation: `docs/SECRETS_MANAGEMENT.md` (~350 lines)
- Commit: `security: prepare secrets management and Cloud Functions template`

#### Exit Criteria
- ✅ .gitignore updated to exclude all secrets
- ✅ Cloud Functions template ready (NOT deployed yet)
- ✅ Documentation complete with setup guides
- ✅ No secrets currently in git history (verified)

#### Rollback Plan
```bash
git checkout main -- .gitignore
rm -rf functions/
```

**Indicators of failure**:
- Required files accidentally ignored by git
- Build fails due to missing files

---

### Team 6: Logging & Production Config

**Branch**: `security/logging-hardening`
**Agent**: `devops-maestro`
**Time**: 15 minutes

#### Tasks

1. **Create SecureLogger Service**:
   ```dart
   // lib/shared/domain/services/secure_logger.dart
   import 'package:flutter/foundation.dart';

   /// Secure Logger Service
   ///
   /// Production-safe logging that:
   /// - Only logs in debug mode
   /// - Never logs sensitive data (tokens, passwords, etc.)
   /// - Sends errors to Firebase Crashlytics in production
   ///
   /// SECURITY: Prevents sensitive data leakage via logs
   class SecureLogger {
     /// Log informational message (debug only)
     static void log(String message, {String? tag}) {
       if (kDebugMode) {
         debugPrint('${tag != null ? "[$tag] " : ""}$message');
       }
       // TODO: Send to Firebase Analytics in production (non-PII)
     }

     /// Log error with optional exception and stack trace
     static void error(
       String message, {
       Object? error,
       StackTrace? stackTrace,
       String? tag,
     }) {
       if (kDebugMode) {
         debugPrint('${tag != null ? "[$tag] " : ""}❌ ERROR: $message');
         if (error != null) debugPrint('   Error: $error');
         if (stackTrace != null) debugPrint('   StackTrace: $stackTrace');
       }
       // TODO: Send to Firebase Crashlytics in production
       // FirebaseCrashlytics.instance.recordError(error, stackTrace);
     }

     /// Log warning (debug only)
     static void warning(String message, {String? tag}) {
       if (kDebugMode) {
         debugPrint('${tag != null ? "[$tag] " : ""}⚠️ WARNING: $message');
       }
     }

     /// Debug-only logging (NEVER sent to production)
     static void debug(String message, {String? tag}) {
       if (kDebugMode) {
         debugPrint('${tag != null ? "[$tag] " : ""}🐛 DEBUG: $message');
       }
       // Explicitly never sent to production analytics
     }

     /// Log performance metric
     static void performance(String operation, Duration duration, {String? tag}) {
       if (kDebugMode) {
         debugPrint(
           '${tag != null ? "[$tag] " : ""}⚡ PERFORMANCE: $operation took ${duration.inMilliseconds}ms'
         );
       }
       // TODO: Send to Firebase Performance in production
     }
   }
   ```

2. **Replace print() Statements**:
   ```bash
   # Find all print() usage
   grep -rn "print(" lib/ --include="*.dart" > print_usage.txt

   # Replace with SecureLogger (manual review required)
   # Examples:
   # print('Starting workout') → SecureLogger.log('Starting workout', tag: 'Workout')
   # print('Error: $e') → SecureLogger.error('Operation failed', error: e)
   # print('DEBUG: $data') → SecureLogger.debug('Data: $data')
   ```

3. **Verify Production App Check Config**:
   ```dart
   // lib/main.dart - Verify this exists
   await FirebaseAppCheck.instance.activate(
     appleProvider: kDebugMode
       ? AppleProvider.debug
       : AppleProvider.appAttest,  // ✅ Production
     androidProvider: kDebugMode
       ? AndroidProvider.debug
       : AndroidProvider.playIntegrity,  // ✅ Production
   );
   ```

4. **Add Firebase Crashlytics Integration** (preparation):
   ```dart
   // lib/shared/domain/services/secure_logger.dart
   // Update error() method:
   static void error(
     String message, {
     Object? error,
     StackTrace? stackTrace,
     String? tag,
   }) {
     if (kDebugMode) {
       debugPrint('${tag != null ? "[$tag] " : ""}❌ ERROR: $message');
       if (error != null) debugPrint('   Error: $error');
       if (stackTrace != null) debugPrint('   StackTrace: $stackTrace');
     } else {
       // Production: Send to Crashlytics
       try {
         FirebaseCrashlytics.instance.recordError(
           error ?? Exception(message),
           stackTrace,
           reason: message,
         );
       } catch (e) {
         // Fail silently - logging errors shouldn't crash app
       }
     }
   }
   ```

#### Deliverables
- New service: `lib/shared/domain/services/secure_logger.dart`
- Updated files: Replace `print()` with `SecureLogger.*` (10-15 files estimated)
- Verified production App Check config in `lib/main.dart`
- Commit: `security: implement secure logging and verify production config`

#### Exit Criteria
- ✅ SecureLogger service created
- ✅ Zero `print()` statements in `lib/` directory
- ✅ Production App Check config verified in main.dart
- ✅ Debug logging disabled in release builds

#### Rollback Plan
```bash
git checkout main -- lib/shared/domain/services/secure_logger.dart
git checkout main -- lib/**/*.dart
```

**Indicators of failure**:
- Crashes due to SecureLogger calls
- Performance degradation from excessive logging
- Missing logs in debug mode

---

## 🔄 Section 3: Error Handling & Rollback

### Rollback Strategy by Team

| Team | Rollback Complexity | Rollback Time | Auto/Manual |
|------|---------------------|---------------|-------------|
| 1: Dependencies | Low | 2 min | Auto (git revert) |
| 2: Firebase Security | Medium | 5 min | Manual (Console) |
| 3: SSL Pinning | Low | 2 min | Auto (git revert) |
| 4: Input Validation | Low | 2 min | Auto (git revert) |
| 5: Secrets Prep | Low | 1 min | Auto (git revert) |
| 6: Logging | Low | 2 min | Auto (git revert) |

### Emergency Full Rollback

```bash
# Nuclear option - rollback everything
git checkout main
git branch -D security/*
flutter clean
flutter pub get
flutter run --release
```

**When to use**: Multiple teams failed, app non-functional, deadline critical

**Recovery time**: 5 minutes

### Monitoring Post-Deployment

**Metrics to monitor** (first 24-48 hours):

1. **Firebase Crashlytics**:
   - Crash rate < 0.1% ✅
   - No new `SecurityException` crashes ✅

2. **Firebase App Check**:
   - Validation success rate > 99% ✅
   - Rejected requests < 1% ✅

3. **Firebase Analytics**:
   - Active users stable (no drop) ✅
   - Session duration stable ✅
   - No spike in error events ✅

4. **User Feedback**:
   - No "can't save workout" reports ❌
   - No "connection failed" reports ❌

**Alert Thresholds**:
- 🚨 Crash rate > 1% → Investigate immediately
- 🚨 Active users drop > 20% → Rollback App Check enforcement
- 🚨 Network errors > 5% → Check SSL pinning

---

## 🧪 Section 4: Testing Strategy

### Automated Tests per Team

#### Team 1: Dependencies
```bash
flutter pub get
flutter analyze              # 0 errors required
flutter test                 # 100% pass required
flutter build ios --debug    # Must succeed
flutter build apk --debug    # Must succeed
```

#### Team 2: Firebase Security
```bash
# Manual: Firebase Console verification
# Automated: Check file deletion
test ! -f lib/main_debug_appcheck.dart && echo "✅ Deleted"
test -f docs/FIREBASE_SECURITY.md && echo "✅ Docs exist"
```

#### Team 3: SSL Pinning
```dart
// test/integration/ssl_pinning_test.dart
void main() {
  testWidgets('SSL pinning validates certificates', (tester) async {
    final client = SecureHttpClient();

    // Valid certificate → should succeed
    final response = await client.get('https://firestore.googleapis.com');
    expect(response.statusCode, 200);
  });
}
```

#### Team 4: Input Validation
```dart
// test/shared/domain/services/input_validator_test.dart
void main() {
  group('InputValidator', () {
    test('blocks XSS', () {
      expect(
        InputValidator.sanitize('<script>alert("xss")</script>'),
        'alertxss',
      );
    });

    test('blocks SQL injection', () {
      expect(
        InputValidator.sanitize("'; DROP TABLE users; --"),
        ' DROP TABLE users ',
      );
    });
  });
}
```

#### Team 5: Secrets Management
```bash
# Check no secrets committed
git ls-files | grep -E '\.(env|key|pem|p12)$' && echo "❌ Secrets!" || echo "✅ Clean"
```

#### Team 6: Logging
```bash
# Check no print() statements
grep -r "print(" lib/ && echo "❌ Found print()" || echo "✅ No print()"
```

### Integration Test Suite (Post-Merge)

```bash
# Full pipeline
flutter clean
flutter pub get
flutter analyze                    # Must pass
flutter test --coverage            # Must pass, >80% coverage
flutter build ios --release        # Must build
flutter build apk --release        # Must build

# Deploy to device
flutter run --release

# Manual smoke test (5 min):
# - [ ] Login with Google/Apple
# - [ ] Create workout with special chars (test validation)
# - [ ] Save workout (test input sanitization)
# - [ ] Start workout timer (test background/Live Activity)
# - [ ] View analytics (test Firestore with App Check)
# - [ ] Export workout (test SSL pinning)
# - [ ] Check logs (should see SecureLogger, not print)
```

**Success Criteria**:
- ✅ All automated tests pass
- ✅ Manual smoke test completes without errors
- ✅ No crashes in first hour (Firebase Crashlytics)

---

## 📊 Section 5: Staged Rollout

### Phase 1: Internal Testing (1 day)
- **Audience**: Developer only
- **Deployment**: Local device + TestFlight Internal
- **Testing**: Full manual testing of all features
- **Metrics**: Local logs, Firebase Console

**Go/No-Go Decision**:
- All smoke tests pass ✅
- No crashes in 8+ hours ✅
- Firebase App Check validation working ✅

### Phase 2: Beta Testing (3 days)
- **Audience**: 5-10 beta testers
- **Deployment**: TestFlight Public / Play Console Internal Testing
- **Metrics**: Crashlytics, App Check validation rate, user feedback

**Go/No-Go Decision**:
- Crash rate < 0.5% ✅
- App Check validation rate > 99% ✅
- No critical bugs reported ✅

### Phase 3: Public Beta (1 week)
- **Audience**: 100 users (open beta)
- **Deployment**: TestFlight Public / Play Console Open Testing
- **Metrics**: All Firebase metrics, user feedback

**Go/No-Go Decision**:
- Crash rate < 0.1% ✅
- Active users stable ✅
- Network errors < 2% ✅
- Positive user feedback ✅

### Phase 4: Production (Full Rollout)
- **Audience**: All users
- **Deployment**: App Store / Play Store
- **Monitoring**: 24/7 for first 48 hours

**Rollback Trigger**: Any critical metric fails

---

## 📦 Section 6: Deliverables Summary

### Code Changes

| Category | Files Modified | New Files | Tests Added | LOC |
|----------|----------------|-----------|-------------|-----|
| Dependencies | 1 | 0 | 0 | ~10 |
| Firebase Security | 0 | 1 doc | 0 | ~300 |
| SSL Pinning | 1 | 1 test + 1 doc | 1 | ~450 |
| Input Validation | 4-6 | 1 service + 1 test | 1 | ~600 |
| Secrets Prep | 1 | 2 templates + 1 doc | 0 | ~400 |
| Logging | 10-15 | 1 service | 0 | ~350 |

**Total**:
- 📝 Files modified: ~20
- ✨ New files: 8
- 🧪 Tests added: 2 test files
- 📚 Documentation: 3 new docs (~1050 lines)
- 💻 Total LOC: ~2,110

### Documentation Deliverables

1. **`docs/FIREBASE_SECURITY.md`** (~300 lines)
   - App Check setup and configuration
   - Debug token workflow
   - Rate limiting guide
   - Troubleshooting

2. **`docs/SSL_PINNING.md`** (~400 lines)
   - Certificate extraction commands
   - Pin rotation process
   - Backup pin strategy
   - Troubleshooting guide

3. **`docs/SECRETS_MANAGEMENT.md`** (~350 lines)
   - GitHub Secrets setup
   - Cloud Functions deployment
   - Environment variables best practices
   - API key rotation process

---

## ⏱️ Section 7: Timeline & Execution

```
┌────────────────────────────────────────────────────────────────┐
│                    Wave 1 (0-20 min)                           │
├────────────────────────────────────────────────────────────────┤
│  Team 1: Dependencies [████████████████] 15 min                │
│  Team 2: Firebase     [████████████████████] 20 min            │
│  Team 5: Secrets Prep [██████████] 10 min                      │
└────────────────────────────────────────────────────────────────┘
                          ↓ (as slots free)
┌────────────────────────────────────────────────────────────────┐
│                    Wave 2 (20-45 min)                          │
├────────────────────────────────────────────────────────────────┤
│  Team 3: SSL Pinning  [████████████████████████████] 40 min    │ ← Critical path
│  Team 4: Input Valid  [█████████████████████] 25 min           │
│  Team 6: Logging      [███████████████] 15 min                 │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│              Integration Phase (45-60 min)                     │
├────────────────────────────────────────────────────────────────┤
│  • Merge all branches                    [████] 5 min          │
│  • Resolve conflicts (if any)            [████] 5 min          │
│  • Run integration tests                 [████] 5 min          │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│               Testing Phase (60-75 min)                        │
├────────────────────────────────────────────────────────────────┤
│  • Deploy to device                      [██] 3 min            │
│  • Manual smoke testing                  [████████] 10 min     │
│  • Monitor Firebase Console              [████] 2 min          │
└────────────────────────────────────────────────────────────────┘

TOTAL WALL-CLOCK TIME: ~75 minutes (1h 15min)
```

**Critical Path**: Team 3 (SSL Pinning) at 40 minutes

---

## ✅ Section 8: Success Criteria

### Per-Team Success Criteria

| Team | Exit Criteria |
|------|---------------|
| 1 | ✅ Dependencies updated (patch only)<br>✅ `flutter analyze` passes<br>✅ All tests pass |
| 2 | ✅ App Check enforced (screenshot)<br>✅ Debug file deleted<br>✅ Documentation complete |
| 3 | ✅ Real pins extracted<br>✅ Validation tested<br>✅ Documentation with rotation guide |
| 4 | ✅ InputValidator service created<br>✅ Applied to 4+ screens<br>✅ XSS/SQL tests pass |
| 5 | ✅ .gitignore updated<br>✅ No secrets in git<br>✅ Cloud Functions template ready |
| 6 | ✅ SecureLogger created<br>✅ Zero `print()` in lib/<br>✅ Production config verified |

### Integration Success Criteria

- ✅ All 6 branches merged without conflicts
- ✅ `flutter analyze` passes (0 errors)
- ✅ All tests pass (>80% coverage)
- ✅ iOS release build succeeds
- ✅ Android release build succeeds

### Deployment Success Criteria

- ✅ App launches without crashes
- ✅ Login works (Google/Apple)
- ✅ Create/save workout works (tests validation)
- ✅ Timer/Live Activity works
- ✅ Firebase sync works (tests SSL pinning + App Check)
- ✅ No crashes in first hour (Crashlytics)

---

## 🚀 Section 9: Execution Plan

### Step 1: Launch Parallel Agents (0-45 min)

```bash
# Using superpowers:dispatching-parallel-agents
# Wave 1 (3 agents, system limit)
- Team 1: flutter-expert (security/dep-updates)
- Team 2: firebase-expert (security/firebase-hardening)
- Team 5: devops-maestro (security/secrets-prep)

# Wave 2 (as Wave 1 completes, slots become available)
- Team 3: security-specialist (security/ssl-pinning) ← Critical path
- Team 4: flutter-architect (security/input-validation)
- Team 6: devops-maestro (security/logging-hardening)
```

### Step 2: Monitor Progress (45 min)

- Check each agent's branch for commits
- Verify exit criteria met per team
- Address any blockers or failures

### Step 3: Integration (45-60 min)

```bash
# Merge all branches
git checkout main
git merge security/dep-updates
git merge security/firebase-hardening
git merge security/ssl-pinning
git merge security/input-validation
git merge security/secrets-prep
git merge security/logging-hardening

# Run integration tests
flutter clean
flutter pub get
flutter analyze
flutter test --coverage
```

### Step 4: Manual Testing (60-75 min)

```bash
# Deploy to device
flutter run --release

# Manual smoke test:
# 1. Login with Google/Apple ✅
# 2. Create workout "Test <script>" (tests validation) ✅
# 3. Save workout (tests sanitization) ✅
# 4. Start timer (tests background/Live Activity) ✅
# 5. View analytics (tests Firestore + App Check) ✅
# 6. Export workout (tests SSL pinning) ✅
# 7. Check logs (SecureLogger, not print) ✅
```

### Step 5: Staged Rollout (75+ min)

- Phase 1: Internal (1 day) → Developer testing
- Phase 2: Beta (3 days) → 5-10 testers
- Phase 3: Public Beta (1 week) → 100 users
- Phase 4: Production → Full rollout

---

## 📝 Section 10: Agent Prompts

### Team 1: Dependency Update

```markdown
You are working on security hardening for the GymBro Flutter app.

**Task**: Update Firebase SDKs conservatively (patch versions only)

**Branch**: security/dep-updates

**Steps**:
1. Checkout new branch: `git checkout -b security/dep-updates`
2. Update pubspec.yaml:
   - firebase_auth: ^6.1.1 → ^6.1.4
   - firebase_messaging: ^16.0.3 → ^16.0.5
   - firebase_analytics: ^12.0.3 → ^12.0.4
   - audioplayers: ^6.5.1 → ^6.5.2
3. Run: `flutter pub outdated` (verify patch-only)
4. Run: `flutter pub get`
5. Run: `flutter analyze` (must pass with 0 errors)
6. Run: `flutter test` (must pass 100%)
7. Commit: "security: update Firebase SDKs to latest patch versions"
8. Push branch

**Exit Criteria**:
- ✅ All dependencies updated (patch only)
- ✅ flutter analyze passes
- ✅ All tests pass

**Rollback**: `git checkout main -- pubspec.yaml pubspec.lock`
```

### Team 2: Firebase Security

```markdown
You are working on Firebase security hardening.

**Task**: Enable App Check enforcement and remove debug tools

**Branch**: security/firebase-hardening

**Steps**:
1. Checkout: `git checkout -b security/firebase-hardening`
2. Firebase Console:
   - Navigate to App Check
   - Enable "Enforce" mode for Firestore, Functions, Storage
   - Set rate limit: 1000 req/min
   - Take screenshot
3. Delete debug file: `git rm lib/main_debug_appcheck.dart`
4. Create docs/FIREBASE_SECURITY.md with:
   - App Check setup guide
   - Debug token workflow
   - Rate limiting config
   - Troubleshooting
5. Commit: "security: enable App Check enforcement and remove debug tools"
6. Push branch

**Exit Criteria**:
- ✅ App Check enforced (screenshot proof)
- ✅ Debug file deleted
- ✅ Documentation complete

**Rollback**: Disable Enforce mode in Firebase Console
```

### Team 3: SSL Pinning

```markdown
You are implementing SSL certificate pinning.

**Task**: Extract real certificate pins and update secure_http_client.dart

**Branch**: security/ssl-pinning

**Steps**:
1. Checkout: `git checkout -b security/ssl-pinning`
2. Extract pins:
   ```bash
   openssl s_client -connect firestore.googleapis.com:443 -servername firestore.googleapis.com < /dev/null | \
     openssl x509 -pubkey -noout | \
     openssl pkey -pubin -outform der | \
     openssl dgst -sha256 -binary | \
     openssl enc -base64
   ```
   Repeat for identitytoolkit.googleapis.com, storage.googleapis.com
3. Update lib/shared/data/network/secure_http_client.dart:
   - Replace placeholder pins with real pins
   - Add backup pins (intermediate CA)
4. Create test/integration/ssl_pinning_test.dart
5. Create docs/SSL_PINNING.md (extraction commands, rotation guide)
6. Test: `flutter test test/integration/ssl_pinning_test.dart`
7. Commit: "security: implement real SSL certificate pinning for Firebase APIs"
8. Push branch

**Exit Criteria**:
- ✅ Real pins extracted
- ✅ Validation tested
- ✅ Documentation with rotation process

**Rollback**: `git checkout main -- lib/shared/data/network/secure_http_client.dart`
```

### Team 4: Input Validation

```markdown
You are implementing input validation and sanitization.

**Task**: Create InputValidator service and apply to user-facing inputs

**Branch**: security/input-validation

**Steps**:
1. Checkout: `git checkout -b security/input-validation`
2. Create lib/shared/domain/services/input_validator.dart with:
   - sanitize() method (remove HTML/SQL chars)
   - isValidWorkoutName()
   - isValidNotes()
   - isValidWeight()
   - isValidReps()
3. Apply to screens:
   - workout_form_screen.dart
   - exercise_card_widget.dart
   - profile_edit_screen.dart
   - template_creation_screen.dart
4. Create test/shared/domain/services/input_validator_test.dart with:
   - XSS test cases
   - SQL injection test cases
   - Valid input test cases
5. Run: `flutter test test/shared/domain/services/input_validator_test.dart`
6. Commit: "security: add input sanitization and validation service"
7. Push branch

**Exit Criteria**:
- ✅ Service created
- ✅ Applied to 4+ screens
- ✅ XSS/SQL tests pass
- ✅ Unit tests 100% coverage

**Rollback**: `git checkout main -- lib/shared/domain/services/input_validator.dart`
```

### Team 5: Secrets Management

```markdown
You are preparing secrets management infrastructure.

**Task**: Update .gitignore and create Cloud Functions template

**Branch**: security/secrets-prep

**Steps**:
1. Checkout: `git checkout -b security/secrets-prep`
2. Update .gitignore:
   - Add .env, .env.*, secrets/, *.key, *.pem, *.p12
   - Add firebase_options_prod.dart
   - Add iOS provisioning profiles
   - Add Android keystores
3. Create functions/index.js (template, not deployed)
4. Create functions/package.json
5. Create docs/SECRETS_MANAGEMENT.md with:
   - GitHub Secrets setup
   - Cloud Functions deployment guide
   - Env var best practices
   - API key rotation process
6. Verify no secrets in git: `git ls-files | grep -E '\.(env|key|pem)$'`
7. Commit: "security: prepare secrets management and Cloud Functions template"
8. Push branch

**Exit Criteria**:
- ✅ .gitignore updated
- ✅ Cloud Functions template ready (not deployed)
- ✅ No secrets in git history
- ✅ Documentation complete

**Rollback**: `git checkout main -- .gitignore`
```

### Team 6: Logging & Config

```markdown
You are implementing secure logging.

**Task**: Create SecureLogger service and replace print() statements

**Branch**: security/logging-hardening

**Steps**:
1. Checkout: `git checkout -b security/logging-hardening`
2. Create lib/shared/domain/services/secure_logger.dart with:
   - log() - info (debug only)
   - error() - errors (Crashlytics in prod)
   - warning() - warnings (debug only)
   - debug() - debug (never prod)
3. Find all print() usage: `grep -rn "print(" lib/`
4. Replace with SecureLogger.log(), .error(), or .debug()
5. Verify production App Check config in lib/main.dart:
   - AppleProvider.appAttest (not debug)
   - AndroidProvider.playIntegrity (not debug)
6. Run: `grep -r "print(" lib/` (should return 0 results)
7. Commit: "security: implement secure logging and verify production config"
8. Push branch

**Exit Criteria**:
- ✅ SecureLogger created
- ✅ Zero print() in lib/
- ✅ Production config verified

**Rollback**: `git checkout main -- lib/shared/domain/services/secure_logger.dart`
```

---

## 📋 Checklist: Pre-Execution

Before launching agents, verify:

- [x] Design approved by user ✅
- [x] TodoWrite created with 10 tasks ✅
- [ ] Git status clean (no uncommitted changes)
- [ ] All tests currently passing
- [ ] Flutter version compatible (SDK ^3.8.1)
- [ ] Firebase project accessible
- [ ] TestFlight/Play Console access ready

---

## 📋 Checklist: Post-Execution

After all agents complete:

- [ ] All 6 branches created and pushed
- [ ] All exit criteria met per team
- [ ] Integration tests pass
- [ ] Manual smoke test pass
- [ ] Documentation complete (3 new docs)
- [ ] No secrets in git history
- [ ] Production config verified
- [ ] Firebase Console configured
- [ ] Staged rollout plan initiated

---

**END OF DESIGN DOCUMENT**

*This plan implements comprehensive security hardening for the GymBro Flutter app, addressing all 7 audit findings through parallel agent execution in ~75 minutes.*
