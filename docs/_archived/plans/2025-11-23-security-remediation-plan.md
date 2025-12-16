# Security Remediation - Task Plan

**Generated**: 2025-11-23 17:45
**Source**: task-master.dev (WebFetch API)
**Complexity Score**: HIGH
**Reason**: 10 critical/high/medium vulnerabilities + Multi-layer fixes (Domain/Data/Presentation/Infrastructure) + Security testing + 28 tasks
**Total Tasks**: 28
**Estimated Time**: ~18-20 hours
**Plan Version**: 1.0

---

## 📋 Context Snapshot

- **Flutter Version**: 3.16.0
- **App Version**: 1.0.0+49
- **Key Packages**:
  - `flutter_riverpod: ^2.4.9`
  - `firebase_core: ^2.24.2`
  - `hive_flutter: ^1.1.0`
- **Target Platforms**: iOS 14+, Android 8+
- **Current State**: Testing phase (single developer user - no production users)
- **Last Commit**: 339a913b feat(health-sync): add localization support (Phase 5)
- **Related Issues**: Security audit - 10 vulnerabilities identified
- **Parent Milestone**: None (standalone security hardening)

---

## 📋 Original Request

> Se tu fossi un mal'intenzionato e volessi hackerare la mia app, cosa faresti? come agiresti?

**Response**: Threat modeling analysis identified 10 critical/high/medium/low security vulnerabilities:
1. API Keys hardcoded in source
2. Admin privilege escalation (client-side check bypass)
3. Firestore security rules bypass (`true ||` debug code)
4. Unencrypted local storage (Hive boxes)
5. Input injection in exercise database
6. Payment data leakage in logs
7. Missing rate limiting
8. iOS Live Activity data leak
9. Excessive logging in production
10. Missing certificate pinning

**Goal**: Remediate all 10 vulnerabilities before production launch.

---

## 🎯 Task Breakdown

### 🔴 CRITICAL VULNERABILITIES (3 vulnerabilities → 8 tasks)

#### Vulnerability 1: API Keys Hardcoded

- [ ] **Task 1.1**: Setup Environment Configuration
  - **Layer**: Infrastructure
  - **Files**: `lib/core/config/environment_config.dart` (new)
  - **Dependencies**: None
  - **Est. Time**: 30 min
  - **Blocking**: Yes (blocks Task 1.2)
  - **Verification**: `.env` loads without exposing keys in version control
  - **Code Prompt**:
    ```
    Add flutter_dotenv: ^5.1.0 to pubspec.yaml
    Create .env.example template with placeholders
    Create .gitignore entry for .env
    Load dotenv in main.dart before runApp()
    ```

- [ ] **Task 1.2**: Migrate Firebase Options
  - **Layer**: Infrastructure
  - **Files**: `lib/firebase_options.dart` (refactor), `lib/core/config/firebase_config.dart` (new)
  - **Dependencies**: Task 1.1
  - **Est. Time**: 45 min
  - **Blocking**: Yes (blocks Task 1.3)
  - **Verification**: App runs with `.env`; no keys in source code
  - **Code Prompt**:
    ```
    Remove hardcoded credentials from firebase_options.dart:62-66
    Load apiKey, appId, messagingSenderId from dotenv
    Create factory method: FirebaseConfig.fromEnvironment()
    Update FirebaseOptions initialization in main.dart
    ```

- [ ] **Task 1.3**: Update CI/CD Pipeline
  - **Layer**: Infrastructure
  - **Files**: `.github/workflows/` or CI config (if exists)
  - **Dependencies**: Task 1.2
  - **Est. Time**: 20 min
  - **Blocking**: No
  - **Verification**: Build logs show no exposed keys
  - **Code Prompt**:
    ```
    Inject FIREBASE_API_KEY as secure environment variable
    Configure build script to create .env at build time
    Verify secrets not logged in CI output
    ```

---

#### Vulnerability 2: Admin Bypass

- [ ] **Task 2.1**: Implement Firebase Custom Claims
  - **Layer**: Data + Backend
  - **Files**: `lib/features/admin/data/repositories/admin_auth_repository.dart` (new), `functions/src/setAdminClaim.ts` (new)
  - **Dependencies**: None
  - **Est. Time**: 40 min
  - **Blocking**: Yes (blocks Task 2.2, 2.3)
  - **Verification**: Custom claims visible in Firebase Console
  - **Code Prompt**:
    ```
    Create Cloud Function: setAdminClaim(userId, isAdmin)
    Use Firebase Admin SDK: auth().setCustomUserClaims()
    Create repository method: checkAdminClaims()
    Test with Firebase emulator
    ```

- [ ] **Task 2.2**: Remove Client-Side Admin Check
  - **Layer**: Presentation + Domain
  - **Files**: `lib/features/admin/presentation/providers/admin_moderation_provider.dart:97-100` (remove/refactor)
  - **Dependencies**: Task 2.1
  - **Est. Time**: 30 min
  - **Blocking**: Yes (blocks Task 2.3)
  - **Verification**: Unprivileged user cannot trigger admin actions
  - **Code Prompt**:
    ```
    Remove local isAdmin getter from provider
    Replace with server-validated claims check
    Update all admin UI conditionals to use claims
    Add loading state while validating claims
    ```

- [ ] **Task 2.3**: Add Server-Side Validation
  - **Layer**: Backend (Cloud Functions)
  - **Files**: `functions/src/validateAdminClaims.ts` (new)
  - **Dependencies**: Task 2.1, Task 2.2
  - **Est. Time**: 50 min
  - **Blocking**: No
  - **Verification**: Test with invalid/missing claims; operations blocked
  - **Code Prompt**:
    ```
    Create Cloud Function: validateAdminClaims(context)
    Check context.auth.token.admin === true
    Throw PERMISSION_DENIED if not admin
    Wrap all admin operations (ban user, edit exercises)
    ```

---

#### Vulnerability 3: Firestore Rules Bypass

- [ ] **Task 3.1**: Fix Firestore Security Rules
  - **Layer**: Infrastructure
  - **Files**: `firestore.rules:519` (fix debug bypass)
  - **Dependencies**: None
  - **Est. Time**: 45 min
  - **Blocking**: Yes (blocks Task 3.2)
  - **Verification**: Deploy to test emulator; verify bypass blocked
  - **Code Prompt**:
    ```
    Remove "true ||" debug bypass from firestore.rules:519
    Implement proper userId validation:
      allow read: if request.auth.uid == resource.data.userId;
    Add field-level restrictions (payment_data read-only)
    Test unauthorized access scenarios
    ```

- [ ] **Task 3.2**: Validate Firestore Rules in Tests
  - **Layer**: Testing
  - **Files**: `test/firestore_rules_test.dart` (new)
  - **Dependencies**: Task 3.1
  - **Est. Time**: 35 min
  - **Blocking**: No
  - **Verification**: 100% test coverage for rule edge cases
  - **Code Prompt**:
    ```
    Use @firebase/rules-unit-testing package
    Test unauthorized read/write attempts
    Verify user isolation (user A cannot read user B data)
    Test admin-only operations with non-admin user
    ```

---

### 🟠 HIGH VULNERABILITIES (1 vulnerability → 4 tasks)

#### Vulnerability 4: Unencrypted Local Data

- [ ] **Task 4.1**: Setup Encrypted Hive Boxes
  - **Layer**: Data + Infrastructure
  - **Files**: `lib/core/local_storage/encrypted_hive_manager.dart` (new)
  - **Dependencies**: None
  - **Est. Time**: 40 min
  - **Blocking**: Yes (blocks Task 4.2, 4.3)
  - **Verification**: Inspect Hive database file; confirm encrypted bytes
  - **Code Prompt**:
    ```
    Add dependencies: hive_flutter: ^1.1.0, pointycastle: ^3.7.0
    Implement HiveAesCipher with 256-bit key
    Create EncryptedHiveManager.init(encryptionKey)
    Open box with cipher: Hive.openBox('workouts', encryptionCipher: cipher)
    ```

- [ ] **Task 4.2**: Secure Key Management
  - **Layer**: Infrastructure
  - **Files**: `lib/core/local_storage/secure_key_provider.dart` (new)
  - **Dependencies**: Task 4.1
  - **Est. Time**: 35 min
  - **Blocking**: Yes (blocks Task 4.3)
  - **Verification**: Retrieve key from iOS Keychain / Android Keystore
  - **Code Prompt**:
    ```
    Add flutter_secure_storage: ^9.0.0
    Generate 256-bit key if not exists
    Store key in platform Keychain/Keystore
    Retrieve key securely for HiveAesCipher
    Handle key rotation scenario
    ```

- [ ] **Task 4.3**: Data Migration Strategy
  - **Layer**: Data
  - **Files**: `lib/core/local_storage/hive_migration.dart` (new)
  - **Dependencies**: Task 4.1, Task 4.2
  - **Est. Time**: 1 hour
  - **Blocking**: Yes (blocks Task 4.4)
  - **Verification**: Migrate test database; verify data integrity
  - **Code Prompt**:
    ```
    Read data from unencrypted box
    Write to new encrypted box with same keys
    Verify count matches (old == new)
    Delete old box after successful migration
    Track migration version in secure storage
    ```

- [ ] **Task 4.4**: Test Encrypted Storage
  - **Layer**: Testing
  - **Files**: `test/local_storage_encryption_test.dart` (new)
  - **Dependencies**: Task 4.1, Task 4.2, Task 4.3
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **Verification**: All encryption tests pass; no plaintext exposure
  - **Code Prompt**:
    ```
    Test encryption/decryption round-trip
    Verify data persists across app restarts
    Test key rotation scenario
    Verify raw Hive file is encrypted (no readable strings)
    ```

---

### 🟡 MEDIUM VULNERABILITIES (4 vulnerabilities → 11 tasks)

#### Vulnerability 5: Input Injection

- [ ] **Task 5.1**: Add Input Validation Layer
  - **Layer**: Domain
  - **Files**: `lib/features/exercise_database/domain/validators/input_sanitizer.dart` (new)
  - **Dependencies**: None
  - **Est. Time**: 45 min
  - **Blocking**: Yes (blocks Task 5.2)
  - **Verification**: XSS payloads rejected; safe strings accepted
  - **Code Prompt**:
    ```
    Create InputSanitizer.sanitizeExerciseName(String input)
    Allowlist: alphanumeric + space + dash + apostrophe
    Max length: 50 characters
    Strip HTML tags, script tags, SQL keywords
    Return Either<ValidationError, String>
    ```

- [ ] **Task 5.2**: Create Exercise Input Use Case
  - **Layer**: Domain
  - **Files**: `lib/features/exercise_database/domain/usecases/validate_exercise_input_usecase.dart` (new)
  - **Dependencies**: Task 5.1
  - **Est. Time**: 40 min
  - **Blocking**: Yes (blocks Task 5.3)
  - **Verification**: Unit tests for boundary conditions
  - **Code Prompt**:
    ```
    Create use case: ValidateExerciseInputUseCase
    Validate name (sanitize + length check)
    Validate description (max 500 chars, no HTML)
    Return Either<Failure, ValidatedExercise>
    Write unit tests (valid, empty, XSS, SQL injection)
    ```

- [ ] **Task 5.3**: Update Exercise Repository
  - **Layer**: Data
  - **Files**: `lib/features/exercise_database/data/repositories/exercise_repository.dart` (update)
  - **Dependencies**: Task 5.2
  - **Est. Time**: 35 min
  - **Blocking**: Yes (blocks Task 5.4)
  - **Verification**: Integration test with injection payloads
  - **Code Prompt**:
    ```
    Call ValidateExerciseInputUseCase before Firestore write
    Reject malformed inputs with proper error message
    Localize error messages (context.l10n.invalidExerciseName)
    Log rejected inputs (for security monitoring)
    ```

- [ ] **Task 5.4**: Secure WebView Rendering
  - **Layer**: Presentation
  - **Files**: `lib/features/exercise_database/presentation/widgets/exercise_detail_webview.dart` (new or update)
  - **Dependencies**: Task 5.1
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **Verification**: Manual XSS test in WebView context
  - **Code Prompt**:
    ```
    HTML-escape user content before WebView render
    Disable JavaScript if not needed (javascriptMode: disabled)
    Use CSP headers if possible
    Test with <script>alert('XSS')</script> payload
    ```

---

#### Vulnerability 6: Payment Data Leakage

- [ ] **Task 6.1**: Audit Logging Calls
  - **Layer**: Codebase review
  - **Files**: All files with `debugPrint()` + payment context
  - **Dependencies**: None
  - **Est. Time**: 30 min
  - **Blocking**: Yes (blocks Task 6.2)
  - **Verification**: Checklist of sensitive logs found
  - **Code Prompt**:
    ```bash
    grep -r "debugPrint" lib/features/payment/ --include="*.dart"
    grep -r "print" lib/features/payment/ --include="*.dart"
    Identify: transaction IDs, card fragments, amounts
    Create checklist of files to fix
    ```

- [ ] **Task 6.2**: Implement Secure Logging Wrapper
  - **Layer**: Infrastructure
  - **Files**: `lib/core/logging/secure_logger.dart` (new)
  - **Dependencies**: Task 6.1
  - **Est. Time**: 45 min
  - **Blocking**: Yes (blocks Task 6.3)
  - **Verification**: Log output excludes full transaction IDs
  - **Code Prompt**:
    ```
    Create SecureLogger class with levels (debug, info, error)
    Mask sensitive fields: maskCardNumber(), maskTransactionId()
    Only log in kDebugMode
    Example: "Transaction: ****1234" instead of full ID
    ```

- [ ] **Task 6.3**: Replace Unsafe Logging
  - **Layer**: Data
  - **Files**: `lib/features/payment/data/datasources/` (update all)
  - **Dependencies**: Task 6.2
  - **Est. Time**: 35 min
  - **Blocking**: No
  - **Verification**: `grep` confirms no `debugPrint()` in payment code
  - **Code Prompt**:
    ```
    Replace all debugPrint() with SecureLogger.debug()
    Remove transaction logs in production builds
    Add if (kDebugMode) guards where needed
    Verify with: grep -r "debugPrint" lib/features/payment/
    ```

---

#### Vulnerability 7: Rate Limiting

- [ ] **Task 7.1**: Cloud Function Rate Limiter
  - **Layer**: Backend (Cloud Functions)
  - **Files**: `functions/src/rateLimiter.ts` (new)
  - **Dependencies**: None
  - **Est. Time**: 50 min
  - **Blocking**: Yes (blocks Task 7.3)
  - **Verification**: Test with rapid requests; 429 responses after limit
  - **Code Prompt**:
    ```
    Implement per-user rate limits (Firestore counters)
    Define limits: 100 exercises/hour, 50 workouts/hour
    Return 429 Too Many Requests when exceeded
    Reset counters every hour (Cloud Scheduler)
    ```

- [ ] **Task 7.2**: Client-Side Throttling
  - **Layer**: Presentation + Application
  - **Files**: `lib/core/utils/throttle_helper.dart` (new)
  - **Dependencies**: None
  - **Est. Time**: 30 min
  - **Blocking**: Yes (blocks Task 7.3)
  - **Verification**: UI buttons disabled; rapid taps ignored
  - **Code Prompt**:
    ```
    Create throttle utility (min 500ms between requests)
    Return bool canExecute() based on last execution time
    Disable buttons during throttle period
    Show SnackBar if user tries too fast
    ```

- [ ] **Task 7.3**: Update Exercise & Workout Providers
  - **Layer**: Presentation
  - **Files**: `lib/features/exercise_database/presentation/providers/exercise_provider.dart` (update), `lib/features/workout/presentation/providers/workout_provider.dart` (update)
  - **Dependencies**: Task 7.1, Task 7.2
  - **Est. Time**: 25 min
  - **Blocking**: No
  - **Verification**: Manual test on slow network; no duplicate submissions
  - **Code Prompt**:
    ```
    Wrap submit/delete calls with throttle check
    Show loading indicator during throttle
    Handle 429 response with user-friendly message
    Localize: context.l10n.tooManyRequests
    ```

---

#### Vulnerability 8: iOS Live Activity Data Leak

- [ ] **Task 8.1**: Setup iOS Keychain Integration
  - **Layer**: Infrastructure
  - **Files**: `lib/core/platform/ios_keychain_provider.dart` (new), `ios/Runner/KeychainHelper.swift` (new)
  - **Dependencies**: None
  - **Est. Time**: 40 min
  - **Blocking**: Yes (blocks Task 8.2)
  - **Verification**: Data persists in Keychain; Xcode confirms encryption
  - **Code Prompt**:
    ```
    Add flutter_keychain_service or create native wrapper
    Store sensitive activity data in Keychain (workout title, stats)
    Create Swift helper: KeychainHelper.save(key, value)
    Test retrieval from Flutter side
    ```

- [ ] **Task 8.2**: Encrypt Live Activity Payloads
  - **Layer**: Data + Infrastructure
  - **Files**: `lib/features/live_activity/data/live_activity_encryption.dart` (new)
  - **Dependencies**: Task 8.1
  - **Est. Time**: 35 min
  - **Blocking**: Yes (blocks Task 8.3)
  - **Verification**: Verify encrypted payload in Activity Kit logs
  - **Code Prompt**:
    ```
    Encrypt workout title/stats before Live Activity push
    Use AES-256 with key from Keychain
    Decrypt in iOS app extension (Swift)
    Test with sensitive workout names
    ```

- [ ] **Task 8.3**: Add Access Control Rules
  - **Layer**: Presentation
  - **Files**: `lib/features/live_activity/presentation/live_activity_manager.dart` (update)
  - **Dependencies**: Task 8.1, Task 8.2
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **Verification**: Test on different devices; only authorized user sees activity
  - **Code Prompt**:
    ```
    Restrict Live Activity visibility to current user
    Add deviceID validation (store in Keychain)
    Prevent cross-user data leakage
    Test on multiple iOS devices
    ```

---

### 🔵 LOW VULNERABILITIES (2 vulnerabilities → 5 tasks)

#### Vulnerability 9: Excessive Logging

- [ ] **Task 9.1**: Replace debugPrint with Conditional Logger
  - **Layer**: Infrastructure
  - **Files**: `lib/core/logging/app_logger.dart` (new)
  - **Dependencies**: None
  - **Est. Time**: 45 min
  - **Blocking**: Yes (blocks Task 9.2, 9.3)
  - **Verification**: No logs in release build; logs visible in debug
  - **Code Prompt**:
    ```
    Create AppLogger class with levels (debug, info, error)
    Only log when kDebugMode && !kIsWeb
    Add static methods: AppLogger.debug(), AppLogger.error()
    Use logger package (or custom implementation)
    ```

- [ ] **Task 9.2**: Migrate All Logging
  - **Layer**: Codebase refactor
  - **Files**: All `.dart` files with `debugPrint()`
  - **Dependencies**: Task 9.1
  - **Est. Time**: 1 hour
  - **Blocking**: Yes (blocks Task 9.3)
  - **Verification**: `grep` confirms zero `debugPrint()` instances
  - **Code Prompt**:
    ```bash
    grep -r "debugPrint" lib/ --include="*.dart" | wc -l
    Replace all with AppLogger.debug()
    Use IDE find-replace: debugPrint( → AppLogger.debug(
    Verify with: grep -r "debugPrint" lib/ (should return 0)
    ```

- [ ] **Task 9.3**: Add kDebugMode Guards
  - **Layer**: Presentation + Data
  - **Files**: `lib/features/*/presentation/providers/*.dart`, `lib/features/*/data/datasources/*.dart` (review)
  - **Dependencies**: Task 9.1, Task 9.2
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **Verification**: Build with `--release`; zero logs
  - **Code Prompt**:
    ```
    Wrap verbose logs: if (kDebugMode) { AppLogger.debug(...) }
    Remove production-irrelevant logs (API call details, state changes)
    Keep only error logs for crash reporting
    Test: flutter build apk --release && install on device
    ```

---

#### Vulnerability 10: Certificate Pinning

- [ ] **Task 10.1**: Implement SSL Pinning
  - **Layer**: Infrastructure
  - **Files**: `lib/core/network/http_client_with_pinning.dart` (new)
  - **Dependencies**: None
  - **Est. Time**: 50 min
  - **Blocking**: Yes (blocks Task 10.2, 10.3)
  - **Verification**: Test with Charles Proxy; connections rejected without valid cert
  - **Code Prompt**:
    ```
    Add dio_http_cache or http_certificate_pinning package
    Pin Firebase certificate SHA-256 fingerprint
    Create custom HttpClient with pinning
    Test with MITM proxy (Charles, mitmproxy)
    ```

- [ ] **Task 10.2**: Setup Platform-Specific Pinning
  - **Layer**: Infrastructure + Platform
  - **Files**: `ios/Runner/Info.plist` (NSPinnedDomains), `android/app/src/main/res/xml/network_security_config.xml` (new)
  - **Dependencies**: Task 10.1
  - **Est. Time**: 40 min
  - **Blocking**: Yes (blocks Task 10.3)
  - **Verification**: Manual MITM test; blocked on public WiFi
  - **Code Prompt**:
    ```
    Configure iOS App Transport Security (Info.plist)
    Add Android Network Security Config (pin firebaseio.com)
    Get Firebase cert fingerprint: openssl s_client -connect firebaseio.com:443
    Test on public WiFi with MITM proxy
    ```

- [ ] **Task 10.3**: Test Certificate Pinning
  - **Layer**: Testing
  - **Files**: `test/network/certificate_pinning_test.dart` (new)
  - **Dependencies**: Task 10.1, Task 10.2
  - **Est. Time**: 35 min
  - **Blocking**: No
  - **Verification**: Test suite passes; no bypass possible
  - **Code Prompt**:
    ```
    Mock invalid certificate scenarios
    Verify connections fail with wrong cert
    Test fallback behavior (if pinning fails)
    Verify Firebase calls still work with valid cert
    ```

---

### 📚 CROSS-CUTTING TASKS (3 tasks)

- [ ] **Task 11**: Update Security Documentation
  - **Layer**: Documentation
  - **Files**: `SECURITY.md` (new), `docs/security/security-implementation.md` (new)
  - **Dependencies**: All vulnerability tasks (1.1–10.3)
  - **Est. Time**: 45 min
  - **Blocking**: No
  - **Verification**: README links to SECURITY.md; all fixes documented
  - **Code Prompt**:
    ```
    Create SECURITY.md with vulnerability disclosure policy
    Document all 10 fixes with rationale
    Include: threat model, mitigation strategy, testing approach
    Add localization notes (EN/IT security messages)
    Link from main README.md
    ```

- [ ] **Task 12**: Localization Audit (EN/IT)
  - **Layer**: Localization
  - **Files**: `assets/i18n/app_en.arb`, `assets/i18n/app_it.arb` (review)
  - **Dependencies**: Tasks 1–10
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **Verification**: l10n files reviewed; no sensitive strings
  - **Code Prompt**:
    ```
    Review security error messages (don't expose implementation details)
    Add translations:
      - tooManyRequests (rate limit)
      - invalidInput (injection)
      - adminOnly (privilege)
    Verify no API keys or secrets in l10n files
    Run: flutter gen-l10n
    ```

- [ ] **Task 13**: Integration Testing & Security Regression Suite
  - **Layer**: Testing
  - **Files**: `test/security_integration_test.dart` (new)
  - **Dependencies**: All vulnerability tasks (1.1–10.3)
  - **Est. Time**: 1.5 hours
  - **Blocking**: No
  - **Verification**: 100% test pass; no security regressions detected
  - **Code Prompt**:
    ```
    Test all 10 vulnerabilities cannot be re-exploited:
      - Verify API keys not in source (grep test)
      - Test admin bypass (unauthorized user → 403)
      - Test Firestore rules (cross-user read → denied)
      - Test encryption (Hive file → no plaintext)
      - Test input injection (XSS payload → rejected)
      - Test logging (release build → no logs)
      - Test rate limit (100+ requests → 429)
      - Test pinning (MITM → connection failed)
    Verify theme support (dark/light) on all security screens
    ```

---

## 📊 Implementation Order (Recommended)

### **Phase 1 (Day 1 - ~4.5h)**: Critical Path
**MUST DO FIRST** (blocking tasks):
- ✅ Task 1.1 → 1.2 → 1.3 (API keys) - ~1h 35min
- ✅ Task 2.1 → 2.2 → 2.3 (Admin bypass) - ~2h
- ✅ Task 3.1 → 3.2 (Firestore rules) - ~1h 20min

**Total**: ~4h 55min | **Severity**: 🔴 CRITICAL

---

### **Phase 2 (Day 2 - ~5h)**: High Priority + Input Security
**THEN** (parallel workable):
- ✅ Task 4.1 → 4.2 → 4.3 → 4.4 (Encryption) - ~2h 45min
- ✅ Task 5.1 → 5.2 → 5.3 → 5.4 (Input injection) - ~2h 30min

**Total**: ~5h 15min | **Severity**: 🟠 HIGH + 🟡 MEDIUM

---

### **Phase 3 (Day 3 - ~3.5h)**: Payment & Rate Limiting
**THEN**:
- ✅ Task 6.1 → 6.2 → 6.3 (Payment logging) - ~1h 50min
- ✅ Task 7.1 → 7.2 → 7.3 (Rate limiting) - ~1h 45min

**Total**: ~3h 35min | **Severity**: 🟡 MEDIUM

---

### **Phase 4 (Day 4 - ~3.5h)**: iOS Security + Logging
**THEN**:
- ✅ Task 8.1 → 8.2 → 8.3 (iOS Live Activity) - ~1h 45min
- ✅ Task 9.1 → 9.2 → 9.3 (Logging cleanup) - ~2h 15min

**Total**: ~4h | **Severity**: 🟡 MEDIUM + 🔵 LOW

---

### **Phase 5 (Day 5 - ~3h)**: Certificate Pinning + Finalization
**FINALLY**:
- ✅ Task 10.1 → 10.2 → 10.3 (Certificate pinning) - ~2h 5min
- ✅ Task 11 (Documentation) - ~45min
- ✅ Task 12 (Localization audit) - ~30min
- ✅ Task 13 (Integration testing) - ~1h 30min

**Total**: ~4h 50min | **Severity**: 🔵 LOW + 📚 Cross-cutting

---

## 📈 Total Estimated Time

**Critical path**: ~18-20 hours (solo developer)
**Recommended schedule**: 5 days @ 4 hours/day

---

## 🎯 Success Criteria

- [ ] All 10 vulnerabilities remediated
- [ ] Zero API keys in source code
- [ ] Admin operations require server-validated custom claims
- [ ] Firestore rules pass security audit (no `true ||` bypasses)
- [ ] Local data encrypted (Hive + Keychain/Keystore)
- [ ] Input validation on all user-generated content
- [ ] Payment logs sanitized (no transaction IDs in logs)
- [ ] Rate limiting active (100 exercises/hour, 50 workouts/hour)
- [ ] iOS Live Activities encrypted
- [ ] Zero `debugPrint()` in production builds
- [ ] Certificate pinning active (MITM attacks blocked)
- [ ] Security documentation complete (SECURITY.md)
- [ ] Localization audit passed (EN/IT)
- [ ] Integration test suite passes (100% coverage)

---

## 📝 Notes & Decisions

*(To be filled during implementation)*

---

## 🔄 Retrospective

*(To be filled after completion)*

**Execution**:
- Actual time spent: ___
- Tasks completed: ___ / 28
- Tasks skipped: ___
- Unexpected challenges: ___

**Learnings**:
- What worked well: ___
- What didn't work: ___
- Estimation accuracy: ___

**Carry-forward to Next Milestone**:
- Tech debt introduced: ___
- Follow-up tasks: ___
- Process improvements: ___

---

## 📦 Version History

### v1.0 - 2025-11-23 17:45

**Initial plan generation** via task-master.dev API

**Total Tasks**: 28
**Estimated Time**: ~18-20 hours
**Complexity**: HIGH (10 vulnerabilities + multi-layer fixes)

---

**Generated by**: Claude Code with task-master.dev integration
**Plan Location**: `docs/plans/2025-11-23-security-remediation-plan.md`
**Related Files**: `docs/plans/CONTEXT.md`, `docs/plans/LEARNINGS.md`
