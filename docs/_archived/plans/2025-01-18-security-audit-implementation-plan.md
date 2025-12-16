# Security Audit Implementation - Task Plan

**Generated**: 2025-01-18 18:30
**Source**: task-master.dev (WebFetch) + Claude enrichment
**Complexity Score**: HIGH
**Reason**: Critical security fixes + Multi-system integration + 16 tasks + Platform-specific testing
**Total Tasks**: 16
**Estimated Time**: ~9.5 hours
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- App Version: 1.0.0+49
- Key Packages: flutter_riverpod ^2.4.9, hive_flutter ^1.1.0
- Target Platforms: iOS 14+, Android 8+
- Related Audit: SECURITY_AUDIT_2025-01-18.md
- Last Commit: 16ba1619 (docs: security audit documentation)
- Parent Milestone: None (standalone security implementation)

---

## 📋 Original Request

> Implement all security fixes from comprehensive security audit (SECURITY_AUDIT_2025-01-18.md)
>
> **Findings:**
> - CRITICAL (P0): 4 Hive boxes storing PII without encryption
> - MEDIUM (P1): 8 text fields missing maxLength (DoS risk)
> - LOW (P2): Duration inputs missing range validation

---

## 🎯 Task Breakdown

### P0: CRITICAL - Unencrypted Sensitive Data Storage

**Blocks:** P1, P2 (must complete first)
**Total Effort:** ~4.25 hours

---

#### P0.1: Create HiveEncryptionManager

- **Layer**: Security / Core
- **Files**: `lib/core/security/hive_encryption_manager.dart` (NEW)
- **Dependencies**: None
- **Est. Time**: 45 minutes
- **Blocking**: Yes (blocks P0.2, P0.3)

**Description:**
Create encryption manager class that handles:
- Key generation using `flutter_secure_storage`
- HiveAesCipher initialization
- Key retrieval and rotation logic
- Secure key storage in iOS Keychain / Android KeyStore

**Verification:**
- [ ] Unit test: `test/core/security/hive_encryption_manager_test.dart`
- [ ] Key generated on first call
- [ ] Same key retrieved on subsequent calls
- [ ] HiveAesCipher properly initialized

**Code Prompt:**
```dart
// Create HiveEncryptionManager with:
// - Static method: getEncryptionCipher() → Future<HiveAesCipher>
// - Generate 256-bit key if not exists
// - Store in flutter_secure_storage with key 'hive_encryption_key'
// - Return HiveAesCipher instance
```

---

#### P0.2: Create HiveMigrationService

- **Layer**: Data / Core
- **Files**: `lib/core/data/hive_migration_service.dart` (NEW)
- **Dependencies**: P0.1 (needs HiveEncryptionManager)
- **Est. Time**: 60 minutes
- **Blocking**: Yes (blocks P0.3, P0.4)

**Description:**
Create migration service to convert existing unencrypted boxes to encrypted:
- Migrate `user_consents` box (GDPR data)
- Migrate `privacy` box (privacy settings)
- Migrate `app_config` box (user preferences)
- Migrate `user_profile_cache` box (email, displayName)
- Backup existing data before migration
- Validate data integrity post-migration
- Handle migration failures gracefully

**Verification:**
- [ ] Integration test: `test/integration/hive_migration_test.dart`
- [ ] All 4 boxes migrated successfully
- [ ] Data preserved (no loss)
- [ ] Old unencrypted boxes deleted
- [ ] New encrypted boxes readable

**Code Prompt:**
```dart
// Create HiveMigrationService with:
// - Static method: migrateToEncrypted(String boxName)
// - Read all data from unencrypted box
// - Close and delete old box
// - Reopen with encryptionCipher from P0.1
// - Restore all data to encrypted box
```

---

#### P0.3: Update HiveBoxManagerEnhanced

- **Layer**: Data / Core
- **Files**: `lib/core/data/hive_box_manager_enhanced.dart` (MODIFY)
- **Dependencies**: P0.1, P0.2 (needs encryption + migration)
- **Est. Time**: 45 minutes
- **Blocking**: Yes (blocks P0.4)

**Description:**
Modify existing HiveBoxManagerEnhanced to auto-encrypt sensitive boxes:
- Add `_sensitiveBoxes` list: ['user_consents', 'privacy', 'app_config', 'user_profile_cache']
- Modify `openBox()` method to detect sensitive boxes
- Auto-apply encryption cipher for sensitive boxes
- Add encryption status logging (debug mode)

**Verification:**
- [ ] Code review: All sensitive boxes auto-encrypted
- [ ] Log output shows encryption status
- [ ] `flutter analyze` passes
- [ ] Existing non-sensitive boxes still work

**Code Prompt:**
```dart
// In HiveBoxManagerEnhanced.openBox():
// - Check if boxName in _sensitiveBoxes
// - If yes: get cipher from HiveEncryptionManager
// - Pass cipher to Hive.openBox(encryptionCipher: cipher)
```

---

#### P0.4: Update main.dart Initialization

- **Layer**: App / Main
- **Files**: `lib/main.dart` (MODIFY)
- **Dependencies**: P0.2, P0.3 (needs migration + updated manager)
- **Est. Time**: 30 minutes
- **Blocking**: Yes (blocks P0.5, P0.6, P1, P2)

**Description:**
Add migration check on app startup:
- Check SharedPreferences flag 'hive_encrypted'
- If false: run migration for all 4 boxes
- Set flag to true after successful migration
- Handle migration errors gracefully (show error dialog)
- Initialize HiveBoxManagerEnhanced after migration

**Verification:**
- [ ] First launch: Migration executes
- [ ] Second launch: Migration skipped
- [ ] Encrypted boxes load successfully
- [ ] No data loss

**Code Prompt:**
```dart
// In main.dart _initializeHive():
// - Check SharedPreferences.getBool('hive_encrypted')
// - If null/false: call HiveMigrationService for each box
// - Set flag to true
// - Call HiveBoxManagerEnhanced.initialize()
```

---

#### P0.5: iOS Keychain Verification Test

- **Layer**: Testing / Integration
- **Files**: `test/integration/ios_keychain_encryption_test.dart` (NEW)
- **Dependencies**: P0.4 (needs full implementation)
- **Est. Time**: 45 minutes
- **Platform**: iOS 14+ only

**Description:**
Create integration test to verify iOS Keychain storage:
- Launch app on iOS simulator
- Verify encryption key stored in Keychain
- Check accessibility attributes (kSecAttrAccessibleAfterFirstUnlock)
- Restart app and verify key persists
- Verify decryption works after restart

**Verification:**
- [ ] Test passes on iOS 14+ simulator
- [ ] Key visible in iOS Keychain (Settings > Developer > Keychain)
- [ ] App works after device reboot (simulator restart)

**Code Prompt:**
```dart
// Integration test:
// - Use flutter_driver or integration_test
// - Launch app, wait for init
// - Check Keychain contains key (native platform channel)
// - Restart app
// - Verify data loads correctly
```

---

#### P0.6: Android KeyStore Verification Test

- **Layer**: Testing / Integration
- **Files**: `test/integration/android_keystore_encryption_test.dart` (NEW)
- **Dependencies**: P0.4 (needs full implementation)
- **Est. Time**: 45 minutes
- **Platform**: Android 8+ only

**Description:**
Create integration test to verify Android KeyStore storage:
- Launch app on Android emulator
- Verify encryption key stored in KeyStore
- Check key persistence across app restarts
- Verify key survives app data clear (but not uninstall)
- Verify decryption works correctly

**Verification:**
- [ ] Test passes on Android 8+ emulator
- [ ] Key persists after app restart
- [ ] Key deleted after uninstall (expected behavior)

**Code Prompt:**
```dart
// Integration test:
// - Use flutter_driver or integration_test
// - Launch app, wait for init
// - Verify KeyStore contains key (platform channel)
// - Restart app
// - Verify data loads correctly
```

---

### P1: MEDIUM - Missing Input Length Limits

**Depends on:** P0.4 (blocked until encryption complete)
**Total Effort:** ~1.75 hours

---

#### P1.1: Admin Panel Text Field Constraints

- **Layer**: Presentation / Admin
- **Files**:
  - `lib/features/admin/presentation/screens/exercise_editor_screen.dart` (MODIFY)
  - 4 TextFormField instances (Description, Image URL, Technical Notes, Tempo Notes)
- **Dependencies**: P0.4 complete
- **Est. Time**: 30 minutes
- **Blocking**: No

**Description:**
Add maxLength constraints to admin panel text fields:
- Description: maxLength 500
- Image URL: maxLength 200
- Technical Notes: maxLength 1000
- Tempo Notes: maxLength 500

**Verification:**
- [ ] Character counter displays for each field
- [ ] Input blocked at limit
- [ ] `flutter analyze` passes
- [ ] Widget test: `test/features/admin/exercise_editor_widget_test.dart`

**Code Prompt:**
```dart
// For each TextFormField in exercise_editor_screen.dart:
// - Add maxLength: [appropriate_limit]
// - Add validator checking length
// - Add InputDecoration with counter
```

---

#### P1.2: Buddy Matching Text Field Constraint

- **Layer**: Presentation / Buddy Matching
- **Files**: `lib/features/buddy_matching/presentation/screens/edit_buddy_profile_screen.dart` (MODIFY)
- **Dependencies**: P0.4 complete
- **Est. Time**: 15 minutes
- **Blocking**: No

**Description:**
Add maxLength to Instagram Handle field:
- maxLength: 30 characters
- Add character counter UI feedback
- Validate @username pattern (optional enhancement)

**Verification:**
- [ ] Character counter visible
- [ ] Input blocked at 30 chars
- [ ] Widget test confirms rejection beyond limit

**Code Prompt:**
```dart
// Instagram Handle TextFormField:
// - Add maxLength: 30
// - Add validator: length <= 30
// - Optional: regex pattern @[a-zA-Z0-9._]+
```

---

#### P1.3: Workout Duration Text Fields

- **Layer**: Presentation / Workout
- **Files**: `lib/features/workout/presentation/widgets/exercise_list_item.dart` (MODIFY)
- **Dependencies**: P0.4 complete
- **Est. Time**: 30 minutes
- **Blocking**: No

**Description:**
Add maxLength to 3 duration input fields:
- Exercise Notes (inline): maxLength 500
- Full Notes Modal: maxLength 1000
- Minutes/Seconds inputs: numeric-only formatter
- Add localized error messages

**Verification:**
- [ ] All 3 fields have character counters
- [ ] Numeric inputs block non-numeric characters
- [ ] Widget test for input rejection

**Code Prompt:**
```dart
// For Notes fields:
// - Add maxLength: 500 / 1000
// For Minutes/Seconds:
// - Add inputFormatters: [FilteringTextInputFormatter.digitsOnly]
// - Keep existing int.tryParse with .clamp()
```

---

#### P1.4: Localized Error Messages

- **Layer**: Core / Localization
- **Files**:
  - `assets/i18n/app_en.arb` (MODIFY)
  - `assets/i18n/app_it.arb` (MODIFY)
- **Dependencies**: P1.1, P1.2, P1.3 (needs field changes)
- **Est. Time**: 20 minutes
- **Blocking**: No

**Description:**
Add localization keys for input validation errors:
- `inputTooLongError` (generic)
- `descriptionTooLong` (500 chars)
- `imageUrlTooLong` (200 chars)
- `technicalNotesTooLong` (1000 chars)
- `tempoNotesTooLong` (500 chars)
- `instagramHandleTooLong` (30 chars)
- `exerciseNotesTooLong` (500/1000 chars)

Translate all to Italian.

**Verification:**
- [ ] `flutter gen-l10n` runs successfully
- [ ] Generated files compile
- [ ] Visual inspection of EN/IT strings in UI

**Code Prompt:**
```json
// app_en.arb:
"inputTooLongError": "Input too long (max {limit} characters)",
"descriptionTooLong": "Description must be less than 500 characters",
...

// app_it.arb:
"inputTooLongError": "Input troppo lungo (max {limit} caratteri)",
"descriptionTooLong": "La descrizione deve essere inferiore a 500 caratteri",
...
```

---

#### P1.5: Input Validation Tests

- **Layer**: Testing / Unit
- **Files**: `test/features/validation/input_validation_test.dart` (NEW)
- **Dependencies**: P1.1-P1.4 (needs all field changes)
- **Est. Time**: 20 minutes
- **Blocking**: No

**Description:**
Create comprehensive unit tests for all 8 fields with maxLength:
- Test boundary values (exactly at limit, 1 over limit)
- Test special characters handling
- Test localized error messages (EN/IT)
- Test empty input (should pass)

**Verification:**
- [ ] `flutter test` passes 100%
- [ ] Coverage report shows all validators tested

**Code Prompt:**
```dart
// Unit tests for each field:
// - testWidgets('Description field rejects 501 chars', ...)
// - testWidgets('Instagram handle accepts 30 chars', ...)
// - Verify error message matches context.l10n key
```

---

### P2: LOW - Missing Range Validation

**Depends on:** P0.4 (blocked until encryption complete)
**Total Effort:** ~30 minutes

---

#### P2.1: Duration Range Validation Implementation

- **Layer**: Domain / Validators
- **Files**: `lib/features/workout/domain/validators/duration_validator.dart` (NEW)
- **Dependencies**: P0.4 complete
- **Est. Time**: 20 minutes
- **Blocking**: Yes (blocks P2.2)

**Description:**
Create DurationValidator class:
- Validate minutes: clamp(0, 999)
- Validate seconds: clamp(0, 59)
- Return error messages for invalid ranges
- Define max duration constants

**Verification:**
- [ ] Unit test: `test/features/workout/domain/validators/duration_validator_test.dart`
- [ ] Test min boundary (0)
- [ ] Test max boundaries (999, 59)
- [ ] Test negative numbers (clamped to 0)

**Code Prompt:**
```dart
// Create DurationValidator:
// - static const maxMinutes = 999;
// - static const maxSeconds = 59;
// - static int validateMinutes(int value) => value.clamp(0, maxMinutes);
// - static int validateSeconds(int value) => value.clamp(0, maxSeconds);
```

---

#### P2.2: Apply Range Validation to Duration Fields

- **Layer**: Presentation / Workout
- **Files**: `lib/features/workout/presentation/widgets/exercise_list_item.dart` (MODIFY - lines 2978, 3004)
- **Dependencies**: P2.1 (needs DurationValidator)
- **Est. Time**: 10 minutes
- **Blocking**: No

**Description:**
Apply DurationValidator to existing duration input fields:
- Minutes input (line 2978): Use validateMinutes()
- Seconds input (line 3004): Use validateSeconds()
- Replace current int.tryParse() with validator

**Verification:**
- [ ] Widget test: Enter 1000 minutes → clamped to 999
- [ ] Widget test: Enter 60 seconds → clamped to 59
- [ ] Widget test: Enter -5 → clamped to 0

**Code Prompt:**
```dart
// Line 2978 (Minutes):
onChanged: (value) {
  final parsed = int.tryParse(value) ?? 0;
  minutes = DurationValidator.validateMinutes(parsed);
},

// Line 3004 (Seconds):
onChanged: (value) {
  final parsed = int.tryParse(value) ?? 0;
  seconds = DurationValidator.validateSeconds(parsed);
},
```

---

### Cross-Cutting Tasks

---

#### Verification.1: Static Analysis Pass

- **Layer**: Quality Assurance
- **Command**: `flutter analyze`
- **Dependencies**: After each P0/P1/P2 task
- **Est. Time**: 10 minutes (cumulative - run after each task)
- **Blocking**: No

**Description:**
Run Flutter static analyzer after completing each major task:
- After P0.1, P0.2, P0.3, P0.4
- After P1.1-P1.5
- After P2.1-P2.2
- Verify zero warnings/errors

**Verification:**
- [ ] `flutter analyze` output: "No issues found!"
- [ ] No security lint violations
- [ ] No deprecated API usage

**Code Prompt:**
```bash
# Run after each task:
flutter analyze
# Expected output: "No issues found!"
```

---

#### Verification.2: Security Integration Suite

- **Layer**: Testing / Integration
- **Files**: `test/integration/security_suite_test.dart` (NEW)
- **Dependencies**: ALL tasks complete (P0, P1, P2, Verification.1)
- **Est. Time**: 45 minutes
- **Platforms**: iOS 14+, Android 8+

**Description:**
Create comprehensive integration test suite verifying all security fixes:
1. Encryption: Verify all 4 boxes encrypted
2. Input validation: Test all 8 maxLength fields
3. Range validation: Test minutes/seconds clamping
4. Platform-specific: Run on both iOS simulator and Android emulator
5. Data integrity: Verify no data loss after encryption

**Verification:**
- [ ] Test passes on iOS 14+ simulator
- [ ] Test passes on Android 8+ emulator
- [ ] All 3 security areas covered
- [ ] Integration with existing test suite

**Code Prompt:**
```dart
// Integration test:
// - testEncryptionWorking() → check all 4 boxes
// - testInputValidation() → verify all 8 fields reject overflow
// - testRangeValidation() → verify clamping works
// - Run with: flutter test integration_test/security_suite_test.dart
```

---

## 📊 Implementation Order

### MUST DO FIRST (Blocking tasks - Sequential):
1. **P0.1** → HiveEncryptionManager (~45 min)
2. **P0.2** → HiveMigrationService (~60 min) [depends on P0.1]
3. **P0.3** → Update HiveBoxManagerEnhanced (~45 min) [depends on P0.1, P0.2]
4. **P0.4** → Update main.dart (~30 min) [depends on P0.3]

**Total Critical Path:** ~3 hours

---

### THEN (Parallel workable - can split across devs):

**Track A - Platform Testing:**
- **P0.5** → iOS Keychain Test (~45 min)
- **P0.6** → Android KeyStore Test (~45 min)

**Track B - Input Validation:**
- **P1.1** → Admin fields (~30 min)
- **P1.2** → Buddy matching field (~15 min)
- **P1.3** → Workout duration fields (~30 min)
- **P1.4** → Localized errors (~20 min)
- **P1.5** → Validation tests (~20 min)

**Track C - Range Validation:**
- **P2.1** → DurationValidator (~20 min)
- **P2.2** → Apply validation (~10 min)

**Total Parallel Tracks:** ~3.75 hours (if 3 devs) OR ~5.25 hours (if 1 dev)

---

### FINALLY (After all above):
- **Verification.1** → flutter analyze (~10 min - run throughout)
- **Verification.2** → Security integration suite (~45 min)

---

## 🔗 Cross-Milestone Dependencies

**None** - This is a standalone security implementation milestone

**Artifacts Created (will be reused in future):**
- `HiveEncryptionManager` - Reusable for future encrypted boxes
- `DurationValidator` - Reusable for other duration inputs
- Input validation patterns - Template for future forms

**Tech Debt Introduced:**
- None (this milestone FIXES tech debt)

**Blocks:**
- None (but recommended before production launch)

---

## 🧪 Testing Strategy

### Unit Tests (5 files):
1. `test/core/security/hive_encryption_manager_test.dart`
2. `test/core/data/hive_migration_test.dart`
3. `test/features/validation/input_validation_test.dart`
4. `test/features/workout/domain/validators/duration_validator_test.dart`
5. Widget tests inline with P1.1, P1.2, P1.3

### Integration Tests (3 files):
1. `test/integration/ios_keychain_encryption_test.dart` (iOS only)
2. `test/integration/android_keystore_encryption_test.dart` (Android only)
3. `test/integration/security_suite_test.dart` (both platforms)

### Manual Testing Checklist:
- [ ] Install on physical iOS device → verify Keychain storage
- [ ] Install on physical Android device → verify KeyStore storage
- [ ] Uninstall/reinstall → verify new key generated, no crash
- [ ] Test all 8 input fields → verify maxLength enforcement
- [ ] Test duration inputs → verify clamping to valid ranges
- [ ] Switch locale EN ↔ IT → verify translated error messages
- [ ] `flutter analyze` → zero warnings/errors

---

## 📝 Notes & Decisions

### Design Decisions:
- **Encryption Key Storage:** Using `flutter_secure_storage` (iOS Keychain / Android KeyStore) for maximum security
- **Migration Strategy:** Aggressive (one-time migration, no rollback) - acceptable since testing phase with 1 user
- **maxLength Values:** Conservative limits based on typical use cases, can be increased if needed
- **Range Validation:** Using `.clamp()` instead of throwing errors - silent correction for better UX

### Risks & Mitigations:
- **Risk:** Migration failure loses user data
  - **Mitigation:** Backup data before migration (P0.2), integration test validates no loss (P0.5, P0.6)
- **Risk:** Platform-specific encryption issues
  - **Mitigation:** Dedicated iOS/Android tests (P0.5, P0.6), manual testing on physical devices
- **Risk:** Performance impact of encryption
  - **Mitigation:** HiveAesCipher is highly performant (<5ms per operation), minimal impact expected

### Open Questions:
- None - All requirements clear from audit report

---

## 📚 Related Documentation

**Source Audit:**
- [`docs/security/SECURITY_AUDIT_2025-01-18.md`](../security/SECURITY_AUDIT_2025-01-18.md) - Full audit report

**Implementation Guide:**
- [`docs/security/SECURITY_IMPLEMENTATION_CHECKLIST.md`](../security/SECURITY_IMPLEMENTATION_CHECKLIST.md) - Step-by-step checklist

**Architecture Reference:**
- [`CLAUDE.md`](../../CLAUDE.md) - Project rules and patterns
- [`docs/NAVIGATION/INDEX.md`](../NAVIGATION/INDEX.md) - Documentation index

---

## 🎯 Success Criteria

**Definition of Done:**
- [ ] All 16 tasks completed and verified
- [ ] All 4 Hive boxes encrypted (user_consents, privacy, app_config, user_profile_cache)
- [ ] All 8 text fields have maxLength enforcement
- [ ] Duration inputs clamped to valid ranges (0-999 minutes, 0-59 seconds)
- [ ] `flutter analyze` passes with zero errors
- [ ] All unit tests pass (5+ test files)
- [ ] All integration tests pass on iOS + Android (3 test files)
- [ ] Manual testing checklist 100% complete
- [ ] Documentation updated: `SECURITY_AUDIT_2025-01-18.md` status → "IMPLEMENTED"

**Security Posture After Implementation:**
- Current: ⚠️ MEDIUM risk
- After: ✅ LOW risk
- GDPR Article 32 compliance: ✅ Achieved (encrypted PII at rest)

---

## 📈 Progress Tracking

**Not Started:** 16/16 tasks
**In Progress:** 0/16 tasks
**Completed:** 0/16 tasks

**Estimated Total Time:** ~9.5 hours
**Actual Time Spent:** 0 hours
**Remaining:** ~9.5 hours

---

## 📊 Execution Metrics (to be filled during implementation)

| Task | Estimated | Actual | Variance | Notes |
|------|-----------|--------|----------|-------|
| P0.1 | 45min | - | - | - |
| P0.2 | 60min | - | - | - |
| P0.3 | 45min | - | - | - |
| P0.4 | 30min | - | - | - |
| P0.5 | 45min | - | - | - |
| P0.6 | 45min | - | - | - |
| P1.1 | 30min | - | - | - |
| P1.2 | 15min | - | - | - |
| P1.3 | 30min | - | - | - |
| P1.4 | 20min | - | - | - |
| P1.5 | 20min | - | - | - |
| P2.1 | 20min | - | - | - |
| P2.2 | 10min | - | - | - |
| Verification.1 | 10min | - | - | - |
| Verification.2 | 45min | - | - | - |

---

**Plan Created By:** Claude Code (task-master.dev integration)
**Plan Status:** ✅ Ready for Implementation
**Next Action:** Start with P0.1 (Create HiveEncryptionManager)
