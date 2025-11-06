import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('UserModel Tests', () {
    late FakeFirebaseFirestore firestore;
    
    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    group('Constructor', () {
      test('creates UserModel with all required fields', () {
        final now = DateTime.now();
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
          createdAt: DateTime(2024, 1, 1),
          lastLoginAt: now,
          isGuest: false,
          preferences: const UserPreferences(),
          stats: const UserStats(),
        );

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.photoURL, 'https://example.com/photo.jpg');
        expect(user.createdAt, now);
        expect(user.lastLoginAt, now);
        expect(user.isGuest, false);
        expect(user.preferences, isNotNull);
        expect(user.stats, isNotNull);
      });

      test('creates UserModel with minimal fields', () {
        const user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.photoURL, isNull);
        expect(user.createdAt, isNull);
        expect(user.lastLoginAt, isNull);
        expect(user.isGuest, false);
      });

      test('creates guest user', () {
        const user = UserModel(
          uid: 'guest-uid',
          email: 'guest@example.com',
          displayName: 'Guest',
          isGuest: true,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        expect(user.isGuest, true);
      });
    });

    group('fromFirestore', () {
      test('creates UserModel from Firestore document', () async {
        final now = DateTime.now();
        final docRef = firestore.collection('users').doc('test-uid');
        
        await docRef.set({
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoURL': 'https://example.com/photo.jpg',
          'createdAt': Timestamp.fromDate(now),
          'lastLoginAt': Timestamp.fromDate(now),
          'isGuest': false,
          'preferences': {
            'units': 'kg',
            'restTimerSound': true,
            'notifications': true,
          },
          'stats': {
            'totalWorkouts': 10,
            'totalExercises': 50,
            'totalVolume': 5000.0,
          },
        });

        final snapshot = await docRef.get();
        final user = UserModel.fromFirestore(snapshot);

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.photoURL, 'https://example.com/photo.jpg');
        expect(user.isGuest, false);
        expect(user.preferences.units, 'kg');
        expect(user.stats.totalWorkouts, 10);
      });

      test('handles missing optional fields', () async {
        final docRef = firestore.collection('users').doc('test-uid');
        
        await docRef.set({
          'email': 'test@example.com',
        });

        final snapshot = await docRef.get();
        final user = UserModel.fromFirestore(snapshot);

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'GymBro User'); // Default value
        expect(user.photoURL, isNull);
        expect(user.isGuest, false); // Default value
      });

      test('throws exception for null document data', () async {
        final docRef = firestore.collection('users').doc('non-existent');
        final snapshot = await docRef.get();

        expect(
          () => UserModel.fromFirestore(snapshot),
          throwsException,
        );
      });
    });

    group('fromDocumentSnapshot', () {
      test('creates UserModel from generic DocumentSnapshot', () async {
        final now = DateTime.now();
        final docRef = firestore.collection('users').doc('test-uid');
        
        await docRef.set(<String, dynamic>{
          'email': 'test@example.com',
          'displayName': 'Test User',
          'createdAt': Timestamp.fromDate(now),
          'isGuest': false,
          'preferences': <String, dynamic>{},
          'stats': <String, dynamic>{},
        });

        final snapshot = await docRef.get();
        final user = UserModel.fromDocumentSnapshot(snapshot);

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
      });
    });

    group('toFirestore', () {
      test('converts to Firestore map with server timestamp', () {
        final now = DateTime.now();
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
          createdAt: DateTime(2024, 1, 1),
          lastLoginAt: now,
          isGuest: false,
          preferences: const UserPreferences(),
          stats: const UserStats(),
        );

        final map = user.toFirestore(useServerTimestamp: true);

        expect(map['uid'], 'test-uid');
        expect(map['email'], 'test@example.com');
        expect(map['displayName'], 'Test User');
        expect(map['photoURL'], 'https://example.com/photo.jpg');
        expect(map['isGuest'], false);
        expect(map['preferences'], isA<Map<String, dynamic>>());
        expect(map['stats'], isA<Map<String, dynamic>>());
        expect(map['createdAt'], isA<Timestamp>());
        expect(map['lastLoginAt'], isA<Timestamp>());
      });

      test('converts to Firestore map without server timestamp', () {
        const user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        final map = user.toFirestore(useServerTimestamp: false);

        expect(map['uid'], 'test-uid');
        expect(map['email'], 'test@example.com');
        expect(map['createdAt'], isNull);
        expect(map['lastLoginAt'], isNull);
      });

      test('handles null timestamps with server timestamp', () {
        const user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        final map = user.toFirestore(useServerTimestamp: true);

        // When createdAt is null and useServerTimestamp is true,
        // it should use FieldValue.serverTimestamp()
        expect(map['createdAt'], isA<FieldValue>());
      });
    });

    group('toFirestoreUpdate', () {
      test('excludes uid from update map', () {
        const user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        final map = user.toFirestoreUpdate();

        expect(map.containsKey('uid'), false);
        expect(map['email'], 'test@example.com');
        expect(map['displayName'], 'Test User');
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: const UserPreferences(),
          stats: const UserStats(),
          createdAt: DateTime(2024, 1, 1),
        );

        final updated = original.copyWith(
          displayName: 'Updated User',
          photoURL: 'https://example.com/new.jpg',
        );

        expect(updated.uid, 'test-uid'); // Unchanged
        expect(updated.email, 'test@example.com'); // Unchanged
        expect(updated.displayName, 'Updated User'); // Updated
        expect(updated.photoURL, 'https://example.com/new.jpg'); // Updated
        expect(updated.createdAt, DateTime(2024, 1, 1)); // Unchanged
      });

      test('creates copy with all fields unchanged when no parameters', () {
        const original = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        final copy = original.copyWith();

        expect(copy.uid, original.uid);
        expect(copy.email, original.email);
        expect(copy.displayName, original.displayName);
        expect(copy.isGuest, original.isGuest);
      });
    });

    group('isValid', () {
      test('returns true for valid user', () {
        const user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        expect(user.isValid, true);
      });

      test('returns false for empty uid', () {
        const user = UserModel(
          uid: '',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        expect(user.isValid, false);
      });

      test('returns false for empty email', () {
        const user = UserModel(
          uid: 'test-uid',
          email: '',
          displayName: 'Test User',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        expect(user.isValid, false);
      });

      test('returns false for empty displayName', () {
        const user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: '',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        expect(user.isValid, false);
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final now = DateTime(2024, 1, 1);
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: const UserPreferences(),
          stats: const UserStats(),
          createdAt: DateTime(2024, 1, 1),
        );

        final str = user.toString();

        expect(str, contains('test-uid'));
        expect(str, contains('test@example.com'));
        expect(str, contains('Test User'));
        expect(str, contains('false'));
        expect(str, contains('2024-01-01'));
      });
    });

    group('equality', () {
      test('equal users are equal', () {
        final now = DateTime(2024, 1, 1);
        final user1 = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: const UserPreferences(),
          stats: const UserStats(),
          createdAt: DateTime(2024, 1, 1),
        );

        final user2 = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: const UserPreferences(),
          stats: const UserStats(),
          createdAt: DateTime(2024, 1, 1),
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('different users are not equal', () {
        const user1 = UserModel(
          uid: 'test-uid-1',
          email: 'test1@example.com',
          displayName: 'Test User 1',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        const user2 = UserModel(
          uid: 'test-uid-2',
          email: 'test2@example.com',
          displayName: 'Test User 2',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        expect(user1, isNot(equals(user2)));
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });

      test('identical users are equal', () {
        const user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        expect(user, equals(user));
      });
    });
  });

  group('UserPreferences Tests', () {
    group('Constructor', () {
      test('creates with default values', () {
        const prefs = UserPreferences();

        expect(prefs.units, 'kg');
        expect(prefs.restTimerSound, true);
        expect(prefs.notifications, true);
      });

      test('creates with custom values', () {
        const prefs = UserPreferences(
          units: 'lbs',
          restTimerSound: false,
          notifications: false,
        );

        expect(prefs.units, 'lbs');
        expect(prefs.restTimerSound, false);
        expect(prefs.notifications, false);
      });
    });

    group('fromMap', () {
      test('creates from map with all fields', () {
        final prefs = UserPreferences.fromMap({
          'units': 'lbs',
          'restTimerSound': false,
          'notifications': false,
        });

        expect(prefs.units, 'lbs');
        expect(prefs.restTimerSound, false);
        expect(prefs.notifications, false);
      });

      test('uses defaults for missing fields', () {
        final prefs = UserPreferences.fromMap({});

        expect(prefs.units, 'kg');
        expect(prefs.restTimerSound, true);
        expect(prefs.notifications, true);
      });
    });

    group('toMap', () {
      test('converts to map', () {
        const prefs = UserPreferences(
          units: 'lbs',
          restTimerSound: false,
          notifications: true,
        );

        final map = prefs.toMap();

        expect(map['units'], 'lbs');
        expect(map['restTimerSound'], false);
        expect(map['notifications'], true);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        const original = UserPreferences(
          units: 'kg',
          restTimerSound: true,
          notifications: true,
        );

        final updated = original.copyWith(
          units: 'lbs',
          restTimerSound: false,
        );

        expect(updated.units, 'lbs');
        expect(updated.restTimerSound, false);
        expect(updated.notifications, true); // Unchanged
      });
    });

    group('equality', () {
      test('equal preferences are equal', () {
        const prefs1 = UserPreferences(
          units: 'kg',
          restTimerSound: true,
          notifications: false,
        );

        const prefs2 = UserPreferences(
          units: 'kg',
          restTimerSound: true,
          notifications: false,
        );

        expect(prefs1, equals(prefs2));
        expect(prefs1.hashCode, equals(prefs2.hashCode));
      });

      test('different preferences are not equal', () {
        const prefs1 = UserPreferences(units: 'kg');
        const prefs2 = UserPreferences(units: 'lbs');

        expect(prefs1, isNot(equals(prefs2)));
      });
    });
  });

  group('UserStats Tests', () {
    group('Constructor', () {
      test('creates with default values', () {
        const stats = UserStats();

        expect(stats.totalWorkouts, 0);
        expect(stats.totalExercises, 0);
        expect(stats.totalVolume, 0.0);
      });

      test('creates with custom values', () {
        const stats = UserStats(
          totalWorkouts: 10,
          totalExercises: 50,
          totalVolume: 5000.0,
        );

        expect(stats.totalWorkouts, 10);
        expect(stats.totalExercises, 50);
        expect(stats.totalVolume, 5000.0);
      });
    });

    group('fromMap', () {
      test('creates from map with all fields', () {
        final stats = UserStats.fromMap({
          'totalWorkouts': 10,
          'totalExercises': 50,
          'totalVolume': 5000.0,
        });

        expect(stats.totalWorkouts, 10);
        expect(stats.totalExercises, 50);
        expect(stats.totalVolume, 5000.0);
      });

      test('uses defaults for missing fields', () {
        final stats = UserStats.fromMap({});

        expect(stats.totalWorkouts, 0);
        expect(stats.totalExercises, 0);
        expect(stats.totalVolume, 0.0);
      });

      test('handles different numeric types', () {
        final stats = UserStats.fromMap({
          'totalWorkouts': 10,
          'totalExercises': 50,
          'totalVolume': 5000, // int instead of double
        });

        expect(stats.totalVolume, 5000.0); // Should convert to double
      });
    });

    group('toMap', () {
      test('converts to map', () {
        const stats = UserStats(
          totalWorkouts: 10,
          totalExercises: 50,
          totalVolume: 5000.0,
        );

        final map = stats.toMap();

        expect(map['totalWorkouts'], 10);
        expect(map['totalExercises'], 50);
        expect(map['totalVolume'], 5000.0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        const original = UserStats(
          totalWorkouts: 10,
          totalExercises: 50,
          totalVolume: 5000.0,
        );

        final updated = original.copyWith(
          totalWorkouts: 15,
          totalVolume: 6000.0,
        );

        expect(updated.totalWorkouts, 15);
        expect(updated.totalExercises, 50); // Unchanged
        expect(updated.totalVolume, 6000.0);
      });
    });

    group('equality', () {
      test('equal stats are equal', () {
        const stats1 = UserStats(
          totalWorkouts: 10,
          totalExercises: 50,
          totalVolume: 5000.0,
        );

        const stats2 = UserStats(
          totalWorkouts: 10,
          totalExercises: 50,
          totalVolume: 5000.0,
        );

        expect(stats1, equals(stats2));
        expect(stats1.hashCode, equals(stats2.hashCode));
      });

      test('different stats are not equal', () {
        const stats1 = UserStats(totalWorkouts: 10);
        const stats2 = UserStats(totalWorkouts: 20);

        expect(stats1, isNot(equals(stats2)));
      });
    });
  });
}