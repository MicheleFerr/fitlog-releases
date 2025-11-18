# 🚀 Security Fixes - Implementation Checklist

**Quick Reference:** Step-by-step checklist to implement security audit findings
**Full Report:** See `SECURITY_AUDIT_2025-01-18.md` for details

---

## 🔴 P0: CRITICAL - Hive Encryption (~3-4 hours)

### Step 1: Create HiveEncryptionManager (~1 hour)

- [ ] Create file: `lib/core/security/hive_encryption_manager.dart`
- [ ] Copy code from audit report (Section "Remediation Plan - Step 1")
- [ ] Add imports:
  ```dart
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:hive/hive.dart';
  import 'dart:convert';
  import 'dart:math';
  ```
- [ ] Verify `flutter_secure_storage: ^9.0.0` in `pubspec.yaml` (already present)
- [ ] Test key generation: `flutter test test/core/security/hive_encryption_manager_test.dart`

### Step 2: Create HiveMigrationService (~1 hour)

- [ ] Create file: `lib/core/data/hive_migration_service.dart`
- [ ] Copy code from audit report (Section "Remediation Plan - Step 2")
- [ ] Implement `migrateToEncrypted()` for each box:
  - [ ] `user_consents`
  - [ ] `privacy`
  - [ ] `app_config`
  - [ ] `user_profile_cache`
- [ ] Add error handling for migration failures
- [ ] Test migration with mock data

### Step 3: Update HiveBoxManagerEnhanced (~30 minutes)

- [ ] Open file: `lib/core/data/hive_box_manager_enhanced.dart`
- [ ] Add `_sensitiveBoxes` list at top of class:
  ```dart
  static final _sensitiveBoxes = [
    'user_consents',
    'privacy',
    'app_config',
    'user_profile_cache',
  ];
  ```
- [ ] Modify `openBox()` method to auto-encrypt sensitive boxes (copy from audit report)
- [ ] Verify no compilation errors: `flutter analyze`

### Step 4: Add Migration on App Startup (~1 hour)

- [ ] Open file: `lib/main.dart`
- [ ] Find `_initializeHive()` method
- [ ] Add migration check before `HiveBoxManagerEnhanced.initialize()`
- [ ] Copy code from audit report (Section "Remediation Plan - Step 4")
- [ ] Add `shared_preferences` for migration flag (already present)
- [ ] Test full flow:
  - [ ] Cold start (first launch)
  - [ ] Warm start (migration already done)
  - [ ] Verify data persists

### Step 5: Testing (~30 minutes)

**iOS Testing:**
- [ ] Run on iOS simulator
- [ ] Verify key stored in Keychain: Check iOS Settings > Developer > Keychain
- [ ] Uninstall/reinstall → new key generated
- [ ] Data loads correctly

**Android Testing:**
- [ ] Run on Android emulator
- [ ] Verify key stored in KeyStore
- [ ] Uninstall/reinstall → new key generated
- [ ] Data loads correctly

**Security Verification:**
- [ ] Find `.hive` files: `find ~/Library/Developer/CoreSimulator -name "*.hive"`
- [ ] Open in text editor → should see encrypted gibberish (not JSON)
- [ ] ✅ If unreadable → encryption working!

### Step 6: Commit

- [ ] Stage all changes: `git add lib/core/security lib/core/data lib/main.dart`
- [ ] Commit: `git commit -m "feat(security): implement Hive encryption for sensitive boxes

- Add HiveEncryptionManager with flutter_secure_storage
- Implement automatic migration from unencrypted to encrypted
- Auto-encrypt user_consents, privacy, app_config, user_profile_cache
- Store keys in iOS Keychain / Android KeyStore

Fixes: SECURITY_AUDIT_2025-01-18 - Critical Finding #1"`

---

## ⚠️ P1: HIGH - Input Validation (~1-2 hours)

### Part A: Add maxLength to Text Fields (~1 hour)

**Admin Exercise Editor** (`lib/features/admin/presentation/screens/exercise_editor_screen.dart`):
- [ ] Line 159 - Description:
  ```dart
  TextFormField(
    controller: _descriptionController,
    maxLength: 500,  // ADD THIS
    decoration: const InputDecoration(
      labelText: 'Description',
      border: OutlineInputBorder(),
    ),
    maxLines: 3,
  ),
  ```
- [ ] Line 170 - Image URL: `maxLength: 200`
- [ ] Line 257 - Technical Notes: `maxLength: 1000`
- [ ] Line 269 - Tempo Notes: `maxLength: 500`

**Buddy Matching** (`lib/features/buddy_matching/presentation/screens/edit_buddy_profile_screen.dart`):
- [ ] Line 393 - Instagram Handle: `maxLength: 30`

**Workout Input** (`lib/features/workout/presentation/widgets/exercise_list_item.dart`):
- [ ] Line 1242 - Exercise Notes: `maxLength: 500`
- [ ] Line 3209 - Full Notes Modal: `maxLength: 1000`

### Part B: Add Localized Error Messages (~30 minutes)

- [ ] Open `assets/i18n/app_en.arb`
- [ ] Add keys:
  ```json
  "descriptionTooLong": "Description must be less than 500 characters",
  "imageUrlTooLong": "URL must be less than 200 characters",
  "technicalNotesTooLong": "Notes must be less than 1000 characters",
  "tempoNotesTooLong": "Notes must be less than 500 characters",
  "instagramHandleTooLong": "Handle must be less than 30 characters",
  "exerciseNotesTooLong": "Notes must be less than 500 characters"
  ```
- [ ] Open `assets/i18n/app_it.arb`
- [ ] Add Italian translations:
  ```json
  "descriptionTooLong": "La descrizione deve essere inferiore a 500 caratteri",
  ...
  ```
- [ ] Run: `flutter gen-l10n`

### Part C: Add Validators (~30 minutes)

Add to each field with `maxLength`:
```dart
validator: (value) {
  if (value != null && value.length > 500) {  // Adjust number per field
    return context.l10n.descriptionTooLong;   // Use appropriate key
  }
  return null;
},
```

- [ ] Admin: 4 validators
- [ ] Buddy Matching: 1 validator
- [ ] Workout: 2 validators

### Testing

- [ ] Test each field:
  - [ ] Type 500+ characters
  - [ ] Character counter shows correctly
  - [ ] Validator error appears
  - [ ] Can't submit form with error
- [ ] Test both EN and IT locales
- [ ] Verify existing data still loads

### Commit

- [ ] Stage: `git add lib/features/admin lib/features/buddy_matching lib/features/workout assets/i18n`
- [ ] Commit: `git commit -m "feat(validation): add maxLength and validators to text fields

- Add maxLength limits: 30-1000 chars depending on field
- Add localized error messages (EN/IT)
- Prevent DoS via unlimited input

Fixes: SECURITY_AUDIT_2025-01-18 - Medium Finding #2"`

---

## 🔵 P2: MEDIUM - Range Validation (~30 minutes)

**Duration Input** (`lib/features/workout/presentation/widgets/exercise_list_item.dart`):

- [ ] Line 2978 - Minutes input:
  ```dart
  onChanged: (value) {
    final parsed = int.tryParse(value) ?? 0;
    minutes = parsed.clamp(0, 999);  // ADD CLAMP
  },
  ```

- [ ] Line 3004 - Seconds input:
  ```dart
  onChanged: (value) {
    final parsed = int.tryParse(value) ?? 0;
    seconds = parsed.clamp(0, 59);  // ADD CLAMP (0-59 only)
  },
  ```

### Testing

- [ ] Enter 999 minutes → accepted
- [ ] Enter 1000 minutes → clamped to 999
- [ ] Enter 59 seconds → accepted
- [ ] Enter 60 seconds → clamped to 59
- [ ] Enter negative numbers → clamped to 0

### Commit

- [ ] Stage: `git add lib/features/workout/presentation/widgets/exercise_list_item.dart`
- [ ] Commit: `git commit -m "feat(validation): add range clamping to duration inputs

- Clamp minutes to 0-999
- Clamp seconds to 0-59
- Prevent invalid duration values

Fixes: SECURITY_AUDIT_2025-01-18 - Low Finding #3"`

---

## ✅ Final Verification

### Security Re-Check
- [ ] Re-run security audit script (if available)
- [ ] Verify all 4 sensitive Hive boxes encrypted
- [ ] Verify all text fields have maxLength
- [ ] Verify duration inputs clamped

### Code Quality
- [ ] `flutter analyze` → 0 errors
- [ ] `flutter test` → all tests pass
- [ ] No console errors in debug
- [ ] App runs smoothly on iOS + Android

### Documentation
- [ ] Update `SECURITY_AUDIT_2025-01-18.md` status to "IMPLEMENTED"
- [ ] Add completion date
- [ ] Mark all findings as "FIXED"

---

## 🎯 Progress Tracker

**Total Tasks:** 30+
**Estimated Time:** 4-5 hours total

| Priority | Tasks | Status | Time |
|----------|-------|--------|------|
| P0: Encryption | 15 tasks | ⬜ | ~3-4h |
| P1: Validation | 12 tasks | ⬜ | ~1-2h |
| P2: Range | 3 tasks | ⬜ | ~30min |

**Next Action:** Start with P0 (Hive Encryption) - highest impact

---

**Document Version:** 1.0
**Last Updated:** 2025-01-18
