# ITERATION 8 REPORT: Implementation & Testing Plan

**Date**: 2026-02-03
**Iteration**: 8/9
**Status**: ✅ Implementation Plan Complete

---

## 🎯 EXECUTIVE SUMMARY

Consolidated implementation plan for ALL fixes from Iterations 1-7. Prioritized by:
1. **P0 Blockers**: Must fix before public release (4 items, 26h)
2. **P1 High**: Fix in next sprint (7 items, 15h)
3. **P2 Medium**: Nice to have (9 items, 12h)

**Total Implementation Effort**: 53 hours (~2 weeks 1 developer)

---

## 🔥 P0 CRITICAL FIXES (Blockers)

### 1. App Kill Data Loss (Bug 4.9) - 4h ⏰

**Priority**: P0 - Affects ALL personas, instant uninstall trigger

**Implementation**:
```dart
// Step 1: Create Hive adapter (1h)
@HiveType(typeId: 50)
class InitialOnboardingProgress {
  @HiveField(0) final int currentStep;
  @HiveField(1) final String? goalJson;
  @HiveField(2) final String? sexJson;
  @HiveField(3) final int? age;
  @HiveField(4) final double? heightCm;
  @HiveField(5) final double? bodyweightKg;
  @HiveField(6) final String? experienceJson;
  @HiveField(7) final int workoutsPerWeek;
  @HiveField(8) final DateTime lastUpdated;
}

// Step 2: Update InitialOnboardingNotifier (2h)
class InitialOnboardingNotifier extends Notifier<InitialOnboardingState> {
  late Box<InitialOnboardingProgress> _progressBox;

  @override
  InitialOnboardingState build() {
    _progressBox = Hive.box('initial_onboarding_progress');
    final saved = _progressBox.get('current');

    if (saved != null && _isRecent(saved.lastUpdated)) {
      return _fromProgress(saved); // ✅ RESUME!
    }

    return const InitialOnboardingState();
  }

  void _autoSave() {
    _progressBox.put('current', _toProgress(state));
  }

  // Call _autoSave() in ALL mutators (setGoal, setSex, etc)
}

// Step 3: UI for resume (1h)
if (hasInProgressOnboarding) {
  AlertDialog(
    title: Text('Resume Onboarding?'),
    content: Text('You were 80% done! Continue from Step ${progress.currentStep}?'),
    actions: [
      TextButton(
        onPressed: () => _resetOnboarding(),
        child: Text('Start Over'),
      ),
      FilledButton(
        onPressed: () => _resumeOnboarding(),
        child: Text('Continue'),
      ),
    ],
  )
}
```

**Testing**:
```dart
testWidgets('recovers state after app kill', (tester) async {
  await enterOnboardingData(tester, steps: 4);
  await tester.binding.resetGestureBinding(); // Simulate kill
  await tester.pumpWidget(MyApp());

  expect(find.text('Resume Onboarding?'), findsOneWidget);
  await tester.tap(find.text('Continue'));

  expect(currentStep, 4);
  expect(onboardingState.goal, TrainingGoalUI.buildMuscle);
});
```

---

### 2. Enable Hive Encryption (Security 6.1) - 4h ⏰

**Priority**: P0 - GDPR Article 32 violation, ALL PII exposed

**Implementation**:
```dart
// Step 1: Add dependency (5min)
// pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0

// Step 2: Create SecureStorageService (1h)
class SecureStorageService {
  static const _hiveKeyName = 'hive_encryption_key_v1';

  Future<Uint8List> getOrCreateHiveKey() async {
    final storage = FlutterSecureStorage();
    String? keyBase64 = await storage.read(key: _hiveKeyName);

    if (keyBase64 == null) {
      final key = Hive.generateSecureKey();
      keyBase64 = base64Encode(key);
      await storage.write(key: _hiveKeyName, value: keyBase64);
    }

    return base64Decode(keyBase64);
  }
}

// Step 3: Update Hive initialization (2h)
Future<void> initializeHive() async {
  await Hive.initFlutter();

  final secureStorage = SecureStorageService();
  final encryptionKey = await secureStorage.getOrCreateHiveKey();

  await Hive.openBox<OnboardingState>(
    'onboarding_state',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  await Hive.openBox<InitialOnboardingProgress>(
    'initial_onboarding_progress',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
}

// Step 4: Migration for existing users (1h)
Future<void> migrateToEncryptedBoxes() async {
  // Read data from old unencrypted box
  final oldBox = await Hive.openBox('onboarding_state');
  final oldData = oldBox.get('current');

  if (oldData != null) {
    // Write to new encrypted box
    final encryptedBox = await Hive.openBox(
      'onboarding_state_encrypted',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    await encryptedBox.put('current', oldData);

    // Delete old box
    await oldBox.clear();
    await oldBox.close();
  }
}
```

**Testing**:
```dart
test('Hive boxes are encrypted', () async {
  await initializeHive();

  // Try to read box file directly (should fail)
  final boxPath = Hive.box('onboarding_state').path;
  final boxFile = File(boxPath);
  final rawBytes = await boxFile.readAsBytes();

  // Should NOT contain plaintext "male", "female", etc
  expect(String.fromCharCodes(rawBytes), isNot(contains('male')));
  expect(String.fromCharCodes(rawBytes), isNot(contains('female')));
});
```

---

### 3. GDPR Data Deletion Flow (Security 6.2) - 6h ⏰

**Priority**: P0 - GDPR Article 17 violation

**Implementation**:
```dart
// Step 1: Create GDPRService (3h)
class GDPRService {
  Future<void> deleteAllUserData(String uid) async {
    // 1. Delete Firestore
    await _firestore.collection('users').doc(uid).delete();
    await _firestore.collection('workouts')
        .where('userId', isEqualTo: uid)
        .get()
        .then((snapshot) async {
          for (var doc in snapshot.docs) {
            await doc.reference.delete();
          }
        });

    // 2. Clear Hive
    await Hive.box('onboarding_state').clear();
    await Hive.box('user_profile').clear();
    await Hive.box('workouts').clear();

    // 3. Revoke HealthKit permissions
    await _healthSync.clearAllData();

    // 4. Log audit event
    await _analytics.logEvent(
      name: 'gdpr_data_deletion',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );

    // 5. Sign out
    await FirebaseAuth.instance.signOut();
  }
}

// Step 2: UI in Settings (2h)
class ConsentManagementScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy & Data')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Delete All My Data'),
            subtitle: Text('Permanently delete account and all data'),
            onTap: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Everything?'),
        content: Text('This cannot be undone. All workouts, progress, and personal data will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(gdprServiceProvider).deleteAllUserData(currentUid);
      // Navigate to login screen
      context.go('/login');
    }
  }
}

// Step 3: Add to Settings navigation (30min)
// In settings_screen.dart
ListTile(
  leading: Icon(Icons.privacy_tip),
  title: Text('Privacy & Data'),
  onTap: () => context.push('/settings/privacy'),
)
```

**Testing**:
```dart
testWidgets('GDPR data deletion clears all data', (tester) async {
  // Setup: Create user with data
  await createTestUserWithWorkouts(tester);

  // Navigate to privacy settings
  await tester.tap(find.text('Privacy & Data'));
  await tester.pumpAndSettle();

  // Tap delete button
  await tester.tap(find.text('Delete All My Data'));
  await tester.pumpAndSettle();

  // Confirm deletion
  await tester.tap(find.text('Delete Forever'));
  await tester.pumpAndSettle();

  // Verify all data deleted
  expect(Hive.box('user_profile').isEmpty, true);
  expect(await FirebaseFirestore.instance
      .collection('users').doc(testUid).get(), isNull);
});
```

---

### 4. COPPA Age Verification (Security 6.3) - 2h ⏰

**Priority**: P0 - FTC fine risk $46K per child

**Implementation**:
```dart
// Step 1: Add checkbox to WelcomeStep (1h)
class WelcomeStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends ConsumerState<WelcomeStep> {
  bool _ageVerified = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ... existing welcome content ...

        const Spacer(),

        // COPPA Age Verification
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.warningContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            value: _ageVerified,
            onChanged: (value) => setState(() => _ageVerified = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text('I am 13 years of age or older'),
            subtitle: Text('Required by US federal law (COPPA)'),
          ),
        ),

        SizedBox(height: 16),

        FilledButton(
          onPressed: _ageVerified
              ? () async {
                  // Save age verification consent
                  await _saveAgeVerification();
                  ref.read(initialOnboardingNotifierProvider.notifier).nextStep();
                }
              : null,
          child: Text('Continue'),
        ),
      ],
    );
  }

  Future<void> _saveAgeVerification() async {
    final consentBox = Hive.box<LegalConsent>('legal_consents');
    await consentBox.add(LegalConsent(
      type: ConsentType.ageVerified,
      accepted: true,
      timestamp: DateTime.now(),
    ));
  }
}

// Step 2: Firestore security rule (30min)
// firestore.rules
match /users/{userId}/profile/onboarding {
  allow create: if request.auth != null
                && request.auth.uid == userId
                && request.resource.data.age >= 13;  // ✅ Block <13
}

// Step 3: Reject <13 at age input (30min)
void setAge(int age) {
  if (age < 13) {
    state = state.copyWith(
      errorMessage: 'You must be 13 or older to use FitLog',
    );
    _showAgeRestrictionDialog();
    return;
  }

  if (age >= 14 && age <= 80) {
    state = state.copyWith(age: age, clearError: true);
  }
}
```

**Testing**:
```dart
testWidgets('blocks onboarding if age verification not checked', (tester) async {
  await tester.pumpWidget(MyApp());

  // Try to continue without checking age verification
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  // Should still be on welcome step
  expect(find.text('Welcome'), findsOneWidget);
  expect(currentStep, 0);
});

testWidgets('rejects age <13', (tester) async {
  await completeOnboardingToStep2(tester);

  // Try to enter age 12
  notifier.setAge(12);

  expect(state.errorMessage, contains('13 or older'));
});
```

---

## 🔧 P1 HIGH PRIORITY FIXES (Next Sprint)

### 5. Add Notification Permission Request (Bug 4.8) - 3h ⏰

See Iteration 4 for details. Add new step or in-step permission priming.

### 6. Offline Sync Queue (Bug 4.10) - 6h ⏰

See Iteration 4 for details. Implement QueuedSync with retry logic.

### 7. Fix Keyboard Covers Input (Bug 4.4) - 30min ⏰

Simple: Dismiss keyboard on navigation
```dart
void previousStep() {
  FocusManager.instance.primaryFocus?.unfocus();
  if (state.currentStep > 0) {
    state = state.copyWith(currentStep: state.currentStep - 1);
  }
}
```

### 8. Animation Jank Fix (Bug 4.6) - 2h ⏰

PageView.builder implementation.

### 9. Age Validation in canProceedFromStep (Bug 4.3) - 1h ⏰

Add range checks.

### 10. Hive Init Error Handling (Bug 4.2) - 1h ⏰

Try-catch with DateTime.now() fallback.

### 11. copyWith Nulls Fix (Bug 4.1) - 3h ⏰

Wrapped Optionals pattern.

**Total P1 Effort**: 15 hours

---

## 🎯 TESTING STRATEGY

### Unit Tests (20 tests, 4h)
- OnboardingState serialization
- InitialOnboardingNotifier logic
- Age/weight/height validation
- COPPA age verification
- GDPR data deletion service

### Widget Tests (15 tests, 3h)
- Each onboarding step renders
- Navigation forward/backward
- Resume from saved state
- Permission dialogs
- Keyboard dismissal

### Integration Tests (10 tests, 4h)
- Complete onboarding flow E2E
- App kill recovery
- Offline onboarding + sync
- GDPR data deletion E2E
- Multi-device sync

**Total Testing Effort**: 11 hours

---

## 📋 IMPLEMENTATION TIMELINE

### Week 1 (20h)
- **Day 1-2**: P0 fixes 1-2 (App kill + Encryption) - 8h
- **Day 3**: P0 fix 3 (GDPR deletion) - 6h
- **Day 4**: P0 fix 4 (COPPA) + P1 fix 7 (Keyboard) - 2.5h
- **Day 5**: P1 fix 8 (Animation) + 9 (Validation) - 3h

### Week 2 (21h)
- **Day 6**: P1 fix 5 (Notification) - 3h
- **Day 7-8**: P1 fix 6 (Offline sync) - 6h
- **Day 9**: P1 fix 10-11 (Hive init + copyWith) - 4h
- **Day 10**: Testing (Unit + Widget + Integration) - 11h

**Total**: 41 hours implementation + 11h testing = 52h (~2 weeks)

---

**End of Iteration 8 Report**
**Next**: Iteration 9 - Documentation & Finalization
**Estimated completion**: 2026-02-03 (same day)
