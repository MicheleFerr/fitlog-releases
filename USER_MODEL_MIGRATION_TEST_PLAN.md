# 🔬 GymBro User Model Migration Test Plan

## 📋 Overview

This comprehensive test plan ensures ZERO regression during the migration from the old user model to the new consolidated UserProfile system in GymBro TrackLog. The migration involves transitioning from:

- **OLD**: `currentUserProvider` + separate `userProfileProvider` 
- **NEW**: `userStateProvider` with consolidated `UserProfile` entity

## 🎯 Critical User Flows to Test

### 1. Login/Registration Flow
- **Priority**: CRITICAL
- **Impact**: App unusable if broken
- **Test Coverage**: Unit + Widget + Integration + E2E

### 2. Premium Upgrade Flow  
- **Priority**: HIGH
- **Impact**: Revenue critical
- **Test Coverage**: Unit + Integration + E2E

### 3. Workout Creation with userId
- **Priority**: CRITICAL
- **Impact**: Core app functionality
- **Test Coverage**: Unit + Integration + E2E

### 4. Settings Screen & User Profile
- **Priority**: MEDIUM
- **Impact**: User experience
- **Test Coverage**: Widget + Integration

### 5. Cloud Sync Operations
- **Priority**: HIGH  
- **Impact**: Data integrity
- **Test Coverage**: Integration + E2E

## 🧪 Test Structure

```
test/
├── unit/
│   ├── user_model_migration/
│   │   ├── user_profile_consolidated_test.dart
│   │   ├── user_state_test.dart
│   │   ├── backwards_compatibility_test.dart
│   │   └── template_quota_test.dart
├── widget/
│   ├── auth/
│   │   ├── login_screen_migration_test.dart
│   │   ├── settings_screen_migration_test.dart
│   │   └── premium_upgrade_widget_test.dart
├── integration/
│   ├── user_migration/
│   │   ├── firebase_user_migration_test.dart
│   │   ├── cloud_sync_migration_test.dart
│   │   └── workout_creation_migration_test.dart
└── e2e/
    ├── patrol/
    │   ├── auth_flow_migration_test.dart
    │   ├── premium_upgrade_flow_test.dart
    │   └── complete_user_journey_test.dart
```

## 🔄 Backwards Compatibility Test Cases

### Test 1: Old UserModel to New UserProfile Migration

```dart
// Test that old user documents can be read by new system
test('migrates old user documents to new UserProfile format', () async {
  // Arrange: Create old-format document
  final oldUserDoc = {
    'uid': 'test-uid',
    'email': 'test@example.com',
    'displayName': 'Test User',
    'isPremium': false,
    'stats': {
      'totalWorkouts': 5,
      'privateTemplateCount': 2,
      'publicTemplateCount': 1,
    }
  };

  // Act: Parse with new system
  final profile = UserProfile.fromFirestore(
    MockDocumentSnapshot(data: oldUserDoc)
  );

  // Assert: All fields migrated correctly
  expect(profile.uid, 'test-uid');
  expect(profile.accountTier, AccountTier.free);
  expect(profile.templateQuota.usedPrivateTemplates, 2);
  expect(profile.templateQuota.usedPublicTemplates, 1);
  expect(profile.stats.totalWorkouts, 5);
});
```

### Test 2: Provider Migration Helpers

```dart
// Test migration helpers work correctly
test('migration helpers provide backwards compatibility', () {
  final container = ProviderContainer();
  
  // Test old provider access patterns still work
  final userProfile = container.read(currentUserProfileProvider);
  final isAuth = container.read(isAuthenticatedProvider);
  final isPremium = container.read(isPremiumUserProvider);
  
  expect(userProfile, isA<UserProfile?>());
  expect(isAuth, isA<bool>());
  expect(isPremium, isA<bool>());
});
```

## 🔥 Firebase Integration Tests

### Firebase User Document Migration

```dart
class FirebaseUserMigrationTest {
  late MockFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  
  setUp(() {
    firestore = MockFirebaseFirestore();
    auth = MockFirebaseAuth();
  });

  test('creates new user document for first-time users', () async {
    // Arrange
    final firebaseUser = createMockFirebaseUser();
    when(() => auth.currentUser).thenReturn(firebaseUser);
    
    // Act: User state provider should create document
    final container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
        firebaseAuthProvider.overrideWithValue(auth),
      ]
    );
    
    final userState = await container.read(userStateProvider.future);
    
    // Assert
    expect(userState, isA<UserAuthenticated>());
    verify(() => firestore.collection('users').doc(firebaseUser.uid).set(any()));
  });

  test('handles existing user document updates', () async {
    // Arrange: Existing user document
    final existingDoc = createMockUserDocument();
    when(() => firestore.collection('users').doc('test-uid').get())
        .thenAnswer((_) async => existingDoc);
    
    // Act: Load user
    final userState = await container.read(userStateProvider.future);
    
    // Assert: No new document created
    verifyNever(() => firestore.collection('users').doc('test-uid').set(any()));
    expect(userState, isA<UserAuthenticated>());
  });

  test('handles user document creation failure gracefully', () async {
    // Arrange: Firestore write fails
    when(() => firestore.collection('users').doc(any()).set(any()))
        .thenThrow(FirebaseException(plugin: 'firestore', code: 'permission-denied'));
    
    // Act & Assert: Should fallback to basic profile
    final userState = await container.read(userStateProvider.future);
    expect(userState, isA<UserAuthenticated>());
  });
}
```

### Cloud Sync Migration Tests

```dart
class CloudSyncMigrationTest extends IntegrationTest {
  test('cloud sync works with new user profile format', () async {
    // Arrange: User with mixed data formats
    await setupMixedUserData();
    
    // Act: Trigger cloud sync
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'patrol', // Use Patrol for integration testing
      utf8.encode('{"method": "triggerCloudSync"}'),
      (data) {},
    );
    
    // Assert: All data synced correctly
    final syncStatus = await getSyncStatus();
    expect(syncStatus.success, true);
    expect(syncStatus.workoutsSynced, greaterThan(0));
    expect(syncStatus.settingsSynced, 1);
  });
}
```

## 🤖 Patrol E2E Tests

### Complete Authentication Flow

```dart
// integration_test/e2e/auth_flow_migration_test.dart
void main() {
  patrolTest(
    'complete authentication flow with user migration',
    ($) async {
      // Test app startup with no user
      await $.pumpWidgetAndSettle(const MyApp());
      
      // Should show login screen
      expect($('Login'), findsOneWidget);
      
      // Test login flow
      await $('Email').enterText('test@gymbro.app');
      await $('Password').enterText('TestPassword123!');
      await $('Login').tap();
      
      // Wait for authentication and user document creation
      await $.waitUntilVisible($('Welcome'));
      
      // Verify user state is correct
      await $.native.grantPermissionWhenInUse(); // For any permissions needed
      
      // Test navigation to settings
      await $.native.tap(Selector(text: 'Settings'));
      
      // Verify user profile displays correctly
      expect($('test@gymbro.app'), findsOneWidget);
      expect($('Account Tier: FREE'), findsOneWidget);
      
      // Test premium upgrade flow
      await $('Upgrade to Premium').tap();
      await $.waitUntilVisible($('Premium Features'));
      
      // Mock premium purchase (don't actually charge!)
      await mockPremiumPurchase($);
      
      // Verify premium status updated
      await $.waitUntilVisible($('Account Tier: PREMIUM'));
      
      // Test workout creation with new user system
      await $.native.tap(Selector(text: 'Workouts'));
      await $('Start New Workout').tap();
      
      // Verify userId is correctly attached to workout
      final workoutProvider = await getWorkoutProvider();
      expect(workoutProvider.currentWorkout?.userId, isNotNull);
      
      // Test logout
      await $.native.tap(Selector(text: 'Settings'));
      await $('Sign Out').tap();
      await $('Confirm').tap();
      
      // Should return to login screen
      await $.waitUntilVisible($('Login'));
    },
  );
}
```

### Premium Upgrade E2E Test

```dart
patrolTest(
  'premium upgrade flow maintains user data integrity',
  ($) async {
    // Login as free user
    await loginAsUser($, 'free@gymbro.app', 'password');
    
    // Create some workout data
    await createTestWorkout($);
    
    // Navigate to premium upgrade
    await $.native.tap(Selector(text: 'Upgrade to Premium'));
    
    // Complete mock purchase
    await mockPremiumPurchase($);
    
    // Verify upgrade completed
    expect($('Welcome to Premium!'), findsOneWidget);
    
    // Verify all previous data still accessible
    await $.native.tap(Selector(text: 'Workouts'));
    expect($('Test Workout'), findsOneWidget); // Previous workout still there
    
    // Verify new premium features available
    await $.native.tap(Selector(text: 'Templates'));
    expect($('Premium Templates'), findsOneWidget);
    
    // Test cloud sync (premium feature)
    await $.native.tap(Selector(text: 'Settings'));
    await $('Cloud Sync').tap();
    await $('Sync from Cloud').tap();
    await $('Confirm').tap();
    
    // Wait for sync to complete
    await $.waitUntilVisible($('Sync completed'));
  },
);
```

## ⚠️ Edge Cases & Failure Scenarios

### 1. Network Failure During Migration
```dart
test('handles network failure during user document creation', () async {
  // Simulate network failure
  when(() => firestore.collection('users').doc(any()).set(any()))
      .thenThrow(SocketException('Network unreachable'));
  
  final userState = await container.read(userStateProvider.future);
  
  // Should fallback to local-only profile
  expect(userState, isA<UserAuthenticated>());
  expect((userState as UserAuthenticated).profile.isGuest, false);
});
```

### 2. Corrupted User Document
```dart
test('handles corrupted user document gracefully', () async {
  // Arrange: Corrupted document
  final corruptedDoc = MockDocumentSnapshot(data: {
    'uid': 'test-uid',
    // Missing required fields
    'corrupted': true,
  });
  
  // Act & Assert: Should not crash
  expect(
    () => UserProfile.fromFirestore(corruptedDoc),
    throwsA(isA<Exception>()),
  );
});
```

### 3. Concurrent User Updates
```dart
test('handles concurrent user profile updates', () async {
  // Simulate multiple widgets trying to update user profile
  final futures = List.generate(5, (i) => 
    updateUserProfile({'field$i': 'value$i'})
  );
  
  final results = await Future.wait(futures);
  
  // All updates should succeed or fail gracefully
  for (final result in results) {
    expect(result.isSuccess || result.isFailureHandledGracefully, true);
  }
});
```

### 4. App State Restoration
```dart
patrolTest(
  'app state restores correctly after kill/restart',
  ($) async {
    // Login and create data
    await loginAsUser($, 'test@gymbro.app', 'password');
    await createTestWorkout($);
    
    // Kill and restart app
    await $.native.killApp();
    await $.native.startApp();
    
    // Verify user still logged in
    await $.waitUntilVisible($('Welcome'));
    
    // Verify data still accessible
    await $.native.tap(Selector(text: 'Workouts'));
    expect($('Test Workout'), findsOneWidget);
  },
);
```

## 📊 Test Coverage Requirements

### Unit Tests: 80%+ Coverage
- `UserProfile` entity methods
- `UserState` sealed class patterns  
- Provider state transitions
- Migration helper methods
- Template quota calculations
- Error handling paths

### Widget Tests: 70%+ Coverage
- Login/Register screens with new providers
- Settings screen with user profile display
- Premium upgrade UI components
- Cloud sync status widgets
- User-dependent conditional rendering

### Integration Tests: Key Flows
- Firebase user document CRUD
- Provider state synchronization
- Cloud sync operations
- Premium upgrade process
- Workout creation with userId

### E2E Tests: Critical Journeys
- Complete authentication flow
- Premium upgrade journey
- Cloud sync operation
- App state persistence
- Cross-screen user data consistency

## 🚀 Test Execution Strategy

### Phase 1: Unit & Widget Tests (Local)
```bash
# Run user migration specific tests
flutter test test/unit/user_model_migration/
flutter test test/widget/auth/

# Check coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Phase 2: Integration Tests
```bash
# Firebase integration tests
flutter test integration_test/user_migration/

# Test with Firebase emulator
firebase emulators:start --only firestore,auth
flutter test --dart-define=USE_FIREBASE_EMULATOR=true
```

### Phase 3: E2E Tests with Patrol
```bash
# iOS E2E tests
patrol test --target integration_test/e2e/auth_flow_migration_test.dart --ios

# Android E2E tests  
patrol test --target integration_test/e2e/auth_flow_migration_test.dart --android
```

### Phase 4: Performance & Load Testing
```bash
# Test with multiple concurrent users
flutter test integration_test/load/concurrent_users_test.dart

# Memory leak detection
flutter test --dart-define=TRACK_MEMORY_LEAKS=true
```

## 📋 Pre-Migration Checklist

- [ ] All existing tests pass
- [ ] New user model tests implemented
- [ ] Migration helper methods tested
- [ ] Firebase security rules updated
- [ ] Backwards compatibility verified
- [ ] Error handling paths tested
- [ ] Performance benchmarks established

## 📋 Post-Migration Verification

- [ ] All critical flows work in production
- [ ] User data integrity maintained
- [ ] No performance regressions
- [ ] Cloud sync working correctly
- [ ] Premium features accessible
- [ ] Analytics data continues flowing
- [ ] No memory leaks introduced

## 🔧 Test Utilities & Mocks

### Mock Providers
```dart
// test/mocks/user_migration_mocks.dart
class MockUserStateNotifier extends StateNotifier<UserState> {
  MockUserStateNotifier() : super(const UserUnauthenticated());
  
  void setAuthenticatedUser(UserProfile profile) {
    state = UserAuthenticated(profile);
  }
  
  void setError(Object error) {
    state = UserError(error, StackTrace.current);
  }
}

final mockUserStateProvider = StateNotifierProvider<MockUserStateNotifier, UserState>((ref) {
  return MockUserStateNotifier();
});
```

### Test Data Factories
```dart
class UserProfileFactory {
  static UserProfile createFreeUser({
    String uid = 'test-uid',
    String email = 'test@example.com',
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: 'Test User',
      accountTier: AccountTier.free,
      templateQuota: TemplateQuota.forTier(AccountTier.free),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: const UserPreferences(),
      stats: const UserStats(),
    );
  }
  
  static UserProfile createPremiumUser({
    String uid = 'premium-uid',
    String email = 'premium@example.com',
  }) {
    return createFreeUser(uid: uid, email: email).copyWith(
      accountTier: AccountTier.premium,
      templateQuota: TemplateQuota.forTier(AccountTier.premium),
    );
  }
}
```

This comprehensive test plan ensures zero regression during the user model migration by covering all critical paths, edge cases, and user journeys with appropriate test types and coverage levels.