# Firestore Rules Unit Testing Setup

## Installazione

```bash
# Installa Firebase Emulator Suite
npm install -g firebase-tools

# Inizializza progetto (se non già fatto)
firebase init emulators

# Seleziona: Firestore, Authentication
```

## Struttura Test

```
test/firestore_rules/
├── rules_test_setup.md          # Questo file
├── workout_rules_test.dart      # Test per workouts collection
├── user_rules_test.dart         # Test per users collection
├── coach_delegation_test.dart   # Test per coach delegations
└── test_helpers.dart            # Utilities per testing
```

## Esempio Test

```dart
import 'package:test/test.dart';
// TODO: Aggiungi dependency
// firebase_rules_unit_testing: ^1.0.0

void main() {
  group('Workouts Collection Security', () {
    test('user can read own workouts', () async {
      // Setup
      final testEnv = await setupTestEnvironment(/* ... */);

      // Test read access
      await expectLater(
        testEnv.withAuth({'uid': 'user123'})
          .firestore()
          .collection('workouts')
          .doc('workout1')
          .get(),
        completes,
      );
    });

    test('user CANNOT read other users workouts', () async {
      // Test should fail
      await expectLater(
        testEnv.withAuth({'uid': 'user123'})
          .firestore()
          .collection('workouts')
          .doc('workout_of_user456')  // Different user
          .get(),
        throwsA(isA<PermissionDeniedError>()),
      );
    });

    test('coach can read delegated athlete workouts', () async {
      // Setup delegation first
      await testEnv.firestore()
        .collection('coach_delegations')
        .doc('coach@test.com_athlete@test.com')
        .set({
          'coachEmail': 'coach@test.com',
          'athleteEmail': 'athlete@test.com',
          'permissions': {'canViewDashboard': true},
        });

      // Test coach access
      await expectLater(
        testEnv.withAuth({
          'uid': 'coach123',
          'email': 'coach@test.com',
        })
          .firestore()
          .collection('workouts')
          .where('email', isEqualTo: 'athlete@test.com')
          .get(),
        completes,
      );
    });
  });

  group('Firestore Transactions', () {
    test('concurrent user stats updates should not lose data', () async {
      // TODO: Test race conditions
    });
  });
}
```

## Esecuzione Test

```bash
# Start emulator
firebase emulators:start --only firestore

# In altra finestra: run tests
flutter test test/firestore_rules/

# Oppure con npm script
npm run test:rules
```

## Coverage Goal

- ✅ Workouts collection (CRUD)
- ✅ Users collection (stats updates)
- ✅ Coach delegations (access control)
- ✅ Exercise activities (ownership)
- ✅ Templates (sharing logic)
- ✅ Transactions (race conditions)

## Resources

- https://firebase.google.com/docs/rules/unit-tests
- https://github.com/firebase/quickstart-testing/tree/master/unit-test-security-rules
