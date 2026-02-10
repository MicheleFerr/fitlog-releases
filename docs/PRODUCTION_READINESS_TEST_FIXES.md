# 🔧 Production Readiness - Test Fixes Plan

**Status**: 🔴 **CRITICAL** - 3 major test failures blocking production
**Target**: Fix all within 4-5 hours
**Created**: 2026-02-10

---

## 📋 Overview

Tre problemi critici bloccano i test prima di poter fare il deploy:

| # | Problema | File | Severità | Tempo |
|---|----------|------|----------|-------|
| 1 | **StateNotifier Deprecation** | `test/shared/presentation/providers/localization_provider_test.dart` | 🔴 BLOCKER | 30 min |
| 2 | **Firebase Not Initialized** | `test/features/ai_coach/presentation/providers/ai_chat_provider_test.dart` | 🔴 BLOCKER | 1 hour |
| 3 | **Timeout Infinite Loops** | `test/unit/core/providers/tier_entitlements_provider_test.dart` | 🔴 BLOCKER | 1-2 hours |

**Total Fix Time**: ~4-5 ore

---

## PROBLEMA #1: StateNotifier Deprecation

### 🔍 Diagnosis

**Error**:
```
Error: Type 'StateNotifier' not found
File: test/shared/presentation/providers/localization_provider_test.dart:6
Class: LocalizationNotifier extends StateNotifier<Locale>
```

### 🤔 Root Cause

Upgrade da **Riverpod 2.x → 3.0.3** ha rimosso `StateNotifier` come pattern principale. Riverpod 3.0 preferisce `@riverpod` annotation con `Notifier` base class.

**Vecchio Pattern (Riverpod 2.x)**:
```dart
class LocalizationNotifier extends StateNotifier<Locale> {
  LocalizationNotifier(this.ref) : super(const Locale('en'));
  final Ref ref;

  Locale get currentLocale => state;
}
```

**Nuovo Pattern (Riverpod 3.0)**:
```dart
@riverpod
class localization extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale locale) => state = locale;
}
```

### ✅ Fix Step-by-Step

#### Step 1: Backup & Open File

```bash
# Backup originale (safety first)
cp test/shared/presentation/providers/localization_provider_test.dart \
   test/shared/presentation/providers/localization_provider_test.dart.backup

# Apri file per editing
# File path: /Users/michele/gymbro_flutter_new/test/shared/presentation/providers/localization_provider_test.dart
```

#### Step 2: Replace StateNotifier with Notifier

**Find this code block** (lines 5-90):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class LocalizationNotifier extends StateNotifier<Locale> {
  LocalizationNotifier([this.locale = const Locale('en')]) : super(locale);

  Locale locale;

  Locale get currentLocale => state;

  String get languageCode => state.languageCode;

  String? get countryCode => state.countryCode;

  Locale mapLanguageCode(String languageCode) {
    switch (state.languageCode) {
      case 'en':
        return const Locale('en', 'US');
      case 'it':
        return const Locale('it', 'IT');
      // ... rest of logic
    }
  }

  void setLocale(Locale locale) {
    state = locale;
  }
}
```

**Replace with**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'localization_provider_test.g.dart';

@riverpod
class localization extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  Locale get currentLocale => state;

  String get languageCode => state.languageCode;

  String? get countryCode => state.countryCode;

  Locale mapLanguageCode(String languageCode) {
    switch (state.languageCode) {
      case 'en':
        return const Locale('en', 'US');
      case 'it':
        return const Locale('it', 'IT');
      default:
        return const Locale('en', 'US');
    }
  }

  String countryCodeToUpperCase() {
    switch (state.languageCode) {
      case 'it':
        return state.languageCode.toUpperCase();
      case 'en':
      default:
        return state.languageCode.toUpperCase();
    }
  }

  String formatCountryCode() {
    final country = state.countryCode?.toUpperCase() ?? '';
    return country;
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  void reset() {
    state = const Locale('en');
  }
}
```

#### Step 3: Update Tests to Use New Provider

**Old test code**:
```dart
test('...', () {
  final container = ProviderContainer();
  final notifier = LocalizationNotifier();
  expect(notifier.currentLocale, const Locale('en'));
});
```

**New test code**:
```dart
test('...', () {
  final container = ProviderContainer();
  final locale = container.read(localizationProvider);
  expect(locale, const Locale('en'));
});
```

#### Step 4: Generate Riverpod Code

```bash
cd /Users/michele/gymbro_flutter_new

# Genera il file .g.dart (part file per @riverpod)
dart run build_runner build --delete-conflicting-outputs
```

#### Step 5: Run Test to Verify

```bash
flutter test test/shared/presentation/providers/localization_provider_test.dart -v
```

**Expected Output**:
```
✓ All localization tests pass
✗ No compilation errors
```

---

## PROBLEMA #2: Firebase Not Initialized in Tests

### 🔍 Diagnosis

**Error**:
```
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
File: test/features/ai_coach/presentation/providers/ai_chat_provider_test.dart:160

Stack Trace:
  AIChat.sendMessage
  → FirebaseCrashlytics.instance
  → Firebase.app()
  → ERROR: No Firebase initialized
```

### 🤔 Root Cause

Il test chiama `ref.read(aiChatProvider)` che trigga `AIChat.build()`:

```dart
// In ai_chat_provider.dart, riga 129
@override
AsyncValue<AIChat> build() {
  _scheduleAutoSync();  // ← Qui chiama FirebaseCrashlytics
  return AsyncValue.data(this);
}

// _scheduleAutoSync chiama:
_scheduleAutoSync() {
  scheduleMicrotask(() {
    ref.read(aiCoachServiceProvider).logChatMessage(...);
    // ↓ Qui dentro c'è FirebaseCrashlytics.instance
  });
}
```

**Problema**: Firebase non è inizializzato nel test environment.

### ✅ Fix Step-by-Step

#### Step 1: Create Test Firebase Setup Helper

**Create new file**: `test/shared/test_firebase_setup.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/config/firebase_options.dart';

/// Initialize Firebase for testing
Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

/// Mock Firebase for isolated unit tests
void mockFirebaseForUnitTests() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // No need to initialize for unit tests that don't use Firebase
  // Just ensure no crashes occur
}
```

#### Step 2: Update ai_chat_provider_test.dart

**Find**: `setUpAll` or `setUp` block (around line 30-50)

**Add Firebase setup**:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/config/firebase_options.dart';

void main() {
  setUpAll(() async {
    // ✅ CRITICAL: Initialize Firebase before running tests
    TestWidgetsFlutterBinding.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  });

  // ... rest of tests

  group('AIChat Provider', () {
    test('sendMessage updates chat state', () async {
      final container = ProviderContainer();

      // Now this won't throw "No Firebase App" error
      final aiChat = container.read(aiChatProvider);
      expect(aiChat, isNotNull);
    });
  });
}
```

#### Step 3: Fix Async Initialization Issues

**Problem**: `setUpAll` è async ma test runs potrebbero not await properly.

**Solution**: Use `flutter_test` proper async handling:

```dart
void main() {
  // Use setUpAll with proper async/await
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      print('Firebase init error (might be expected in test): $e');
      // Don't fail test - some Firebase APIs might not be available in test
    }
  });

  tearDownAll(() async {
    // Optional: cleanup Firebase after tests
    // Firebase.app().delete(); // Be careful with this
  });
}
```

#### Step 4: Mock AI Coach Service (Optional but Recommended)

Se test non ha bisogno di vero Firebase, mockare il service:

```dart
// test/features/ai_coach/presentation/providers/ai_chat_provider_test.dart

import 'package:mockito/mockito.dart';

// Mock the AI Coach service
class MockAICoachService extends Mock implements AICoachService {}

void main() {
  group('AIChat Provider - Mocked', () {
    test('sendMessage with mocked service', () async {
      final container = ProviderContainer(
        overrides: [
          aiCoachServiceProvider.overrideWithValue(MockAICoachService()),
        ],
      );

      // Now test won't need real Firebase
      final aiChat = container.read(aiChatProvider);
      expect(aiChat, isNotNull);
    });
  });
}
```

#### Step 5: Run Test to Verify

```bash
flutter test test/features/ai_coach/presentation/providers/ai_chat_provider_test.dart -v
```

**Expected**: Test completa senza "No Firebase App" error.

---

## PROBLEMA #3: Timeout Infinite Loops

### 🔍 Diagnosis

**Error**:
```
TimeoutException after 0:00:30.000000: Test timed out after 30 seconds
File: test/unit/core/providers/tier_entitlements_provider_test.dart

Tests affected (6):
- Premium user with Starter tier
- Premium user with Platinum tier
- Tier progression: Starter → Bronze → ... → Platinum
- Selective providers expose individual limits
- Free user limits never exceed 999
- Premium limits always exactly 999
```

### 🤔 Root Cause

Test rimane "bloccato" in infinite loop o deadlock per 30+ secondi. Probabilmente:

1. **Provider watchers infinite loop** - Provider chiama se stesso ricorsivamente
2. **Firestore query infinite retry** - Query non completa mai
3. **Riverpod infinite rebuild** - State change trigga rebuild infinito
4. **Missing async/await** - Test aspetta risultato che non arriva mai

### ✅ Fix Step-by-Step

#### Step 1: Add Debug Logging

**File**: `test/unit/core/providers/tier_entitlements_provider_test.dart`

```dart
void main() {
  group('TierEntitlementsProvider - Consolidation Logic', () {
    test('Premium user with Starter tier should get 999 unlimited', () async {
      print('[TEST] Starting test...');

      final container = ProviderContainer();
      print('[TEST] ProviderContainer created');

      // ← ADD HERE: Debug what's happening
      addTearDown(container.dispose);

      try {
        print('[TEST] Reading provider...');
        final entitlements = container.read(tierEntitlementsProvider);
        print('[TEST] Entitlements read: $entitlements');

        expect(entitlements.maxTemplates, 999);
        print('[TEST] ✓ Test passed');
      } catch (e, st) {
        print('[TEST] ✗ Error: $e');
        print('[TEST] Stack: $st');
        rethrow;
      }
    });
  });
}
```

#### Step 2: Identify Infinite Loop Source

**Look for these patterns in tier_entitlements_provider.dart**:

```dart
// ❌ BAD: Provider watching itself
final tierEntitlementsProvider = StateNotifierProvider<TierNotifier, Entitlements>((ref) {
  final tier = ref.watch(tierEntitlementsProvider); // ← INFINITE LOOP!
  return TierNotifier(tier);
});

// ✅ GOOD: Only watch dependencies, not self
final tierEntitlementsProvider = StateNotifierProvider<TierNotifier, Entitlements>((ref) {
  final userTier = ref.watch(userTierProvider); // ← OK: different provider
  final accountTier = ref.watch(accountTierProvider); // ← OK: different provider
  return TierNotifier(userTier, accountTier);
});
```

#### Step 3: Check for Async Issues

**Look for missing awaits**:

```dart
// ❌ BAD: Fire-and-forget that might block
final tierEntitlementsProvider = StateNotifierProvider<TierNotifier, Entitlements>((ref) {
  fetchDataFromFirestore(); // ← Missing await!
  return TierNotifier(data);
});

// ✅ GOOD: Properly handle async
final tierEntitlementsProvider = FutureProvider<Entitlements>((ref) async {
  final data = await fetchDataFromFirestore(); // ← Properly awaited
  return Entitlements.fromFirestoreData(data);
});
```

#### Step 4: Add Timeout Debugging

**Wrap test with timeout detection**:

```dart
test('Premium user with Starter tier should get 999 unlimited', () async {
  final completer = Completer<void>();

  // Set a completion timeout that prints debug info
  final timeoutTimer = Timer(Duration(seconds: 5), () {
    print('[TEST] ⏱️ Test taking longer than 5 seconds...');
    print('[TEST] Checking for infinite loops...');
    // Don't fail yet, just warn
  });

  try {
    final container = ProviderContainer();
    final entitlements = container.read(tierEntitlementsProvider);

    expect(entitlements.maxTemplates, 999);
    completer.complete();
  } catch (e) {
    completer.completeError(e);
  }

  // Await with explicit timeout
  await completer.future.timeout(Duration(seconds: 30));
  timeoutTimer.cancel();
}, timeout: Timeout(Duration(seconds: 35)));
```

#### Step 5: Fix Common Causes

**If cause is infinite watch loop**:

```dart
// In tier_entitlements_provider.dart

// ❌ WRONG
final tierEntitlementsProvider = StateNotifierProvider<TierNotifier, Entitlements>((ref) {
  final tier = ref.watch(tierEntitlementsProvider); // ← CIRCULAR!
  return TierNotifier(tier);
});

// ✅ CORRECT - Only depend on source providers
final tierEntitlementsProvider = StateNotifierProvider.family<TierNotifier, Entitlements, (UserTier, AccountTier)>((ref, (userTier, accountTier)) {
  return TierNotifier(userTier, accountTier);
});

// Or use FutureProvider if fetching from Firestore
final tierEntitlementsProvider = FutureProvider<Entitlements>((ref) async {
  final userTier = ref.watch(userTierProvider);
  final accountTier = ref.watch(accountTierProvider);
  // Consolidate logic
  return Entitlements.consolidate(userTier, accountTier);
});
```

#### Step 6: Run Test with Verbose Output

```bash
flutter test test/unit/core/providers/tier_entitlements_provider_test.dart \
  -v \
  --dart-define=ENABLE_DEBUG_LOGS=true
```

**Analyze output** for where test gets stuck.

#### Step 7: Verify Fix

```bash
# Run just the problematic test
flutter test test/unit/core/providers/tier_entitlements_provider_test.dart::Consolidation Logic
```

**Expected**: Test completa in <2 secondi senza timeout.

---

## 📋 EXECUTION CHECKLIST

Segui questo ordine per fixare i problemi:

### Phase 1: StateNotifier Fix (30 min)

- [ ] Backup `localization_provider_test.dart`
- [ ] Replace `StateNotifier` with `Notifier` + `@riverpod`
- [ ] Update test imports + usage
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verify test passes: `flutter test test/shared/presentation/providers/localization_provider_test.dart -v`
- [ ] ✅ DONE - Move to Phase 2

### Phase 2: Firebase Initialization (1 hour)

- [ ] Create `test/shared/test_firebase_setup.dart` helper
- [ ] Update `ai_chat_provider_test.dart`:
  - [ ] Add `setUpAll()` with Firebase initialization
  - [ ] Add error handling for Firebase init
  - [ ] Add `tearDownAll()` cleanup
- [ ] Consider mocking AI Coach service for isolated tests
- [ ] Run test: `flutter test test/features/ai_coach/presentation/providers/ai_chat_provider_test.dart -v`
- [ ] Verify no "No Firebase App" errors
- [ ] ✅ DONE - Move to Phase 3

### Phase 3: Timeout Issues (1-2 hours)

- [ ] Add debug logging to `tier_entitlements_provider_test.dart`
- [ ] Run test with verbose output
- [ ] Identify infinite loop source in provider code
- [ ] Check for self-referencing providers (circular dependencies)
- [ ] Fix root cause:
  - [ ] If circular: Restructure provider dependencies
  - [ ] If async: Add proper await/async handling
  - [ ] If state: Add guard conditions
- [ ] Re-run tests
- [ ] Verify all 6 tier tests complete in <2 sec each
- [ ] ✅ DONE - Move to Phase 4

### Phase 4: Full Test Suite (30 min)

- [ ] Run entire test suite: `flutter test`
- [ ] Verify:
  - [ ] No compilation errors
  - [ ] No Firebase initialization errors
  - [ ] No timeouts
  - [ ] Success rate > 95%
- [ ] If still failures, debug individually
- [ ] ✅ DONE - All tests passing

### Phase 5: Address Golden Tests (2-3 hours)

- [ ] Once unit tests pass, tackle golden tests
- [ ] Review 60 golden test failures
- [ ] Approve/reject UI changes
- [ ] Update master images: `flutter test --update-goldens`
- [ ] Verify golden tests pass
- [ ] ✅ DONE - Ready for production

### Phase 6: Final Verification (1 hour)

- [ ] Run `flutter analyze`
- [ ] Fix any remaining warnings
- [ ] Commit all changes atomically
- [ ] Push to main branch
- [ ] ✅ READY FOR PRODUCTION

---

## 🚀 Quick Command Reference

```bash
# Fix StateNotifier (Riverpod 3.0 migration)
dart run build_runner build --delete-conflicting-outputs

# Run specific failing test
flutter test test/shared/presentation/providers/localization_provider_test.dart -v
flutter test test/features/ai_coach/presentation/providers/ai_chat_provider_test.dart -v
flutter test test/unit/core/providers/tier_entitlements_provider_test.dart -v

# Run all tests
flutter test

# Update golden tests (after fixing unit tests)
flutter test --update-goldens

# Analyze code
flutter analyze --no-fatal-infos

# Format code
dart format lib/ test/

# Check git status before committing
git status && git diff --stat
```

---

## ⚠️ Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| **Firebase init fails in CI/CD** | Use `.env` file + GitHub Secrets for config |
| **Riverpod build_runner doesn't generate** | Delete `.dart_tool` + run `flutter pub get` first |
| **Test passes locally but fails in CI** | Set `--dart-define` variables explicitly |
| **Golden tests still failing after fixes** | Manually review each image, approve/reject changes |
| **Timeout still occurs** | Add `print()` debug logging, run with `-v` flag |

---

## 📞 Need Help?

If stuck:

1. **Read error message carefully** - First 3 lines usually have the answer
2. **Check git history** - See what changed recently
3. **Run with `-v` flag** - Verbose output shows full stack traces
4. **Use debugger** - `flutter run -d chrome --web-port=8080`
5. **Check CLAUDE.md** - Project rules might have patterns for this

---

## ✅ Success Criteria

All fixes complete when:

- ✅ No compilation errors: `flutter analyze` passes
- ✅ All tests pass: `flutter test` → Success
- ✅ No Firebase errors in test logs
- ✅ No timeout warnings
- ✅ Golden tests reviewed & approved
- ✅ All changes committed to main
- ✅ Ready for production deployment

---

**Next Step**: Start with **PROBLEMA #1: StateNotifier Deprecation** (easiest, fastest fix)

Then proceed to **PROBLEMA #2** and **PROBLEMA #3** in order.

**Estimated Total Time**: 4-5 hours
**Start**: Now! 🚀
**Target**: Complete by 2026-02-11 morning

---

**Document Version**: 1.0
**Last Updated**: 2026-02-10
**Created by**: Claude Production Readiness Audit
