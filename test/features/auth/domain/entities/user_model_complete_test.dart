import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('🔥 UserModel 100% Coverage Tests', () {
    late FakeFirebaseFirestore firestore;
    
    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    group('UserModel Edge Cases', () {
      test('fromDocumentSnapshot throws when data is null', () async {
        // Crea un documento che non esiste
        final docRef = firestore.collection('users').doc('non-existent');
        final snapshot = await docRef.get();
        
        // Dovrebbe lanciare un'eccezione perché il documento non esiste
        expect(
          () => UserModel.fromDocumentSnapshot(snapshot),
          throwsException,
        );
      });

      test('fromFirestore handles null preferences map', () async {
        final docRef = firestore.collection('users').doc('test-uid');
        
        await docRef.set({
          'email': 'test@example.com',
          'displayName': 'Test User',
          'isGuest': false,
          'preferences': null, // Explicitly null
          'stats': null, // Explicitly null
        });

        final snapshot = await docRef.get();
        final user = UserModel.fromFirestore(snapshot);
        
        expect(user.preferences, isNotNull);
        expect(user.preferences.units, 'kg'); // Default value
        expect(user.stats, isNotNull);
        expect(user.stats.totalWorkouts, 0); // Default value
      });

      test('toString includes all fields', () {
        final user = UserModel(
          uid: 'test-123',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
          createdAt: DateTime(2024, 1, 1),
          lastLoginAt: DateTime(2024, 1, 2),
          isGuest: true,
          preferences: const UserPreferences(units: 'lbs'),
          stats: const UserStats(totalWorkouts: 10),
        );

        final str = user.toString();
        
        // Verifica che toString contenga le info principali
        expect(str, contains('test-123'));
        expect(str, contains('test@example.com'));
        expect(str, contains('Test User'));
        expect(str, contains('true')); // isGuest
        expect(str, contains('2024-01-01'));
      });

      test('copyWith with null values preserves originals', () {
        final original = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
          createdAt: DateTime(2024, 1, 1),
          lastLoginAt: DateTime(2024, 1, 2),
          isGuest: false,
          preferences: const UserPreferences(),
          stats: const UserStats(),
        );

        // copyWith senza parametri mantiene tutti i valori
        final copy = original.copyWith();
        
        expect(copy.uid, original.uid);
        expect(copy.email, original.email);
        expect(copy.displayName, original.displayName);
        expect(copy.photoURL, original.photoURL);
        expect(copy.createdAt, original.createdAt);
        expect(copy.lastLoginAt, original.lastLoginAt);
        expect(copy.isGuest, original.isGuest);
      });
    });

    group('UserPreferences Edge Cases', () {
      test('copyWith preserves original values when no params', () {
        const original = UserPreferences(
          units: 'lbs',
          restTimerSound: false,
          notifications: false,
        );

        final copy = original.copyWith();
        
        expect(copy.units, 'lbs');
        expect(copy.restTimerSound, false);
        expect(copy.notifications, false);
      });

      test('toString includes all preferences', () {
        const prefs = UserPreferences(
          units: 'lbs',
          restTimerSound: false,
          notifications: true,
        );

        final str = prefs.toString();
        
        expect(str, contains('lbs'));
        expect(str, contains('false')); // restTimerSound
        expect(str, contains('true')); // notifications
      });

      test('equality with different types', () {
        const prefs = UserPreferences();
        
        // Test con oggetti di tipo diverso
        expect(prefs == 'not a UserPreferences', false);
        expect(prefs == 123, false);
        expect(prefs == null, false);
      });

      test('hashCode consistency', () {
        const prefs1 = UserPreferences(units: 'kg');
        const prefs2 = UserPreferences(units: 'kg');
        const prefs3 = UserPreferences(units: 'lbs');
        
        // Hash code uguale per oggetti uguali
        expect(prefs1.hashCode, prefs2.hashCode);
        // Hash code diverso per oggetti diversi
        expect(prefs1.hashCode, isNot(prefs3.hashCode));
      });
    });

    group('UserStats Edge Cases', () {
      test('copyWith preserves original values when no params', () {
        const original = UserStats(
          totalWorkouts: 100,
          totalExercises: 500,
          totalVolume: 10000.0,
        );

        final copy = original.copyWith();
        
        expect(copy.totalWorkouts, 100);
        expect(copy.totalExercises, 500);
        expect(copy.totalVolume, 10000.0);
      });

      test('toString includes all stats', () {
        const stats = UserStats(
          totalWorkouts: 50,
          totalExercises: 250,
          totalVolume: 5000.5,
        );

        final str = stats.toString();
        
        expect(str, contains('50')); // totalWorkouts
        expect(str, contains('250')); // totalExercises
        expect(str, contains('5000.5')); // totalVolume
      });

      test('equality with different types', () {
        const stats = UserStats();
        
        // Test con oggetti di tipo diverso
        expect(stats == 'not a UserStats', false);
        expect(stats == 123, false);
        expect(stats == null, false);
      });

      test('hashCode consistency', () {
        const stats1 = UserStats(totalWorkouts: 10);
        const stats2 = UserStats(totalWorkouts: 10);
        const stats3 = UserStats(totalWorkouts: 20);
        
        // Hash code uguale per oggetti uguali
        expect(stats1.hashCode, stats2.hashCode);
        // Hash code diverso per oggetti diversi
        expect(stats1.hashCode, isNot(stats3.hashCode));
      });
    });

    group('UserModel equality edge cases', () {
      test('equality with different types', () {
        const user = UserModel(
          uid: 'test',
          email: 'test@test.com',
          displayName: 'Test',
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );
        
        // Test con oggetti di tipo diverso
        expect(user == 'not a UserModel', false);
        expect(user == 123, false);
        expect(user == null, false);
      });

      test('equality with all fields different', () {
        final user1 = UserModel(
          uid: 'uid1',
          email: 'email1@test.com',
          displayName: 'User1',
          photoURL: 'url1',
          createdAt: DateTime(2024, 1, 1),
          lastLoginAt: DateTime(2024, 1, 2),
          isGuest: false,
          preferences: const UserPreferences(units: 'kg'),
          stats: const UserStats(totalWorkouts: 10),
        );

        final user2 = UserModel(
          uid: 'uid2',
          email: 'email2@test.com',
          displayName: 'User2',
          photoURL: 'url2',
          createdAt: DateTime(2024, 2, 1),
          lastLoginAt: DateTime(2024, 2, 2),
          isGuest: true,
          preferences: const UserPreferences(units: 'lbs'),
          stats: const UserStats(totalWorkouts: 20),
        );

        expect(user1 == user2, false);
        expect(user1.hashCode == user2.hashCode, false);
      });

      test('hashCode with null fields', () {
        const user1 = UserModel(
          uid: 'test',
          email: 'test@test.com',
          displayName: 'Test',
          photoURL: null,
          createdAt: null,
          lastLoginAt: null,
          isGuest: false,
          preferences: UserPreferences(),
          stats: UserStats(),
        );

        final user2 = UserModel(
          uid: 'test',
          email: 'test@test.com',
          displayName: 'Test',
          photoURL: 'url',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isGuest: false,
          preferences: const UserPreferences(),
          stats: const UserStats(),
        );

        // HashCode dovrebbe essere diverso
        expect(user1.hashCode == user2.hashCode, false);
      });
    });
  });
}