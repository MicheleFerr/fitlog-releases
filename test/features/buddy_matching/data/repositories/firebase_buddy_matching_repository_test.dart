/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/buddy_matching/data/repositories
/// 🎯 Feature: buddy_matching
/// 🔧 Type: repository_test
///
/// FIREBASE BUDDY MATCHING REPOSITORY TESTS
///
/// Tests per FirebaseBuddyMatchingRepository - Matching, profiles, partnerships
/// Coverage target: 637 lines di implementazione
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/data/repositories/firebase_buddy_matching_repository.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_match.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:mocktail/mocktail.dart';

// ============================================================
// MOCKS
// ============================================================

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {}

class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockQueryDocumentSnapshot<T> extends Mock
    implements QueryDocumentSnapshot<T> {}

class MockQuery<T> extends Mock implements Query<T> {}

class MockWriteBatch extends Mock implements WriteBatch {}

// ============================================================
// FAKES for fallback values
// ============================================================

class FakeBuddyProfile extends Fake implements BuddyProfile {}

class FakeBuddyPreferences extends Fake implements BuddyPreferences {}

class FakeBuddyMatch extends Fake implements BuddyMatch {}

class FakeGeoPoint extends Fake implements GeoPoint {}

class FakeTimestamp extends Fake implements Timestamp {}

class FakeDocumentReference<T> extends Fake implements DocumentReference<T> {}

// ============================================================
// TEST DATA FACTORIES
// ============================================================

BuddyProfile createTestProfile({
  String uid = 'user-1',
  String displayName = 'Test User',
  bool isLookingForBuddy = true,
  List<BadgeType> badges = const [],
}) {
  return BuddyProfile(
    uid: uid,
    displayName: displayName,
    photoUrl: 'https://example.com/photo.jpg',
    bio: 'Test bio',
    age: 25,
    gender: 'male',
    location: const GeoPoint(0, 0),
    locationName: 'Test City',
    fitnessLevel: FitnessLevel.intermediate,
    workoutGoals: [WorkoutGoal.muscleGain],
    preferredWorkoutTimes: ['morning'],
    preferences: createTestPreferences(),
    isLookingForBuddy: isLookingForBuddy,
    isVerified: false,
    isActive: true,
    badges: badges,
    likedProfiles: [],
    dislikedProfiles: [],
    matchedProfiles: [],
    partnershipsCount: 0,
    successfulPartnerships: 0,
    averageRating: 0.0,
    lastSeen: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

BuddyPreferences createTestPreferences({
  List<FitnessLevel> fitnessLevels = const [FitnessLevel.intermediate],
  double maxDistance = 10.0,
}) {
  return BuddyPreferences(
    fitnessLevels: fitnessLevels,
    workoutGoals: [WorkoutGoal.muscleGain],
    ageRange: const RangeValues(18, 60),
    maxDistance: maxDistance,
    genderPreference: 'any',
    matchingPurpose: MatchingPurpose.workoutPartner,
    showOnlyVerified: false,
    showOnlyActive: true,
  );
}

BuddyMatch createTestMatch({
  String id = 'match-1',
  String user1Id = 'user-1',
  String user2Id = 'user-2',
  MatchStatus status = MatchStatus.pending,
  double compatibilityScore = 0.85,
}) {
  return BuddyMatch(
    id: id,
    user1Id: user1Id,
    user2Id: user2Id,
    status: status,
    compatibilityScore: compatibilityScore,
    initiatorId: user1Id,
    user1LikedAt: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

class RangeValues {
  const RangeValues(this.start, this.end);
  final double start;
  final double end;
}

// ============================================================
// MAIN TEST SUITE
// ============================================================

void main() {
  late FirebaseBuddyMatchingRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockProfilesCollection;
  late MockCollectionReference<Map<String, dynamic>> mockMatchesCollection;
  late MockCollectionReference<Map<String, dynamic>> mockFiltersCollection;
  late MockDocumentReference<Map<String, dynamic>> mockProfileDoc;
  late MockDocumentReference<Map<String, dynamic>> mockMatchDoc;
  late MockDocumentSnapshot<Map<String, dynamic>> mockProfileSnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockMatchSnapshot;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDoc;
  late MockQuery<Map<String, dynamic>> mockQuery;

  setUpAll(() {
    registerFallbackValue(FakeBuddyProfile());
    registerFallbackValue(FakeBuddyPreferences());
    registerFallbackValue(FakeBuddyMatch());
    registerFallbackValue(FakeGeoPoint());
    registerFallbackValue(FakeTimestamp());
    registerFallbackValue(
      FakeDocumentReference<Map<String, dynamic>>(),
    );
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockProfilesCollection = MockCollectionReference();
    mockMatchesCollection = MockCollectionReference();
    mockFiltersCollection = MockCollectionReference();
    mockProfileDoc = MockDocumentReference();
    mockMatchDoc = MockDocumentReference();
    mockProfileSnapshot = MockDocumentSnapshot();
    mockMatchSnapshot = MockDocumentSnapshot();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQueryDoc = MockQueryDocumentSnapshot();
    mockQuery = MockQuery();

    // Setup Firestore collections
    when(() => mockFirestore.collection('buddy_profiles'))
        .thenReturn(mockProfilesCollection);
    when(() => mockFirestore.collection('buddy_matches'))
        .thenReturn(mockMatchesCollection);
    when(() => mockFirestore.collection('buddy_search_filters'))
        .thenReturn(mockFiltersCollection);

    repository = FirebaseBuddyMatchingRepository(
      firestore: mockFirestore,
    );
  });

  group('Initialization', () {
    test('repository initializes with firestore instance', () {
      expect(repository, isNotNull);
    });

    test('repository uses default firestore instance when none provided', () {
      final defaultRepo = FirebaseBuddyMatchingRepository();
      expect(defaultRepo, isNotNull);
    });
  });

  group('getUserProfile', () {
    const userId = 'user-123';

    test('returns profile when document exists', () async {
      // Arrange
      final testProfile = createTestProfile(uid: userId);
      when(() => mockProfilesCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.get()).thenAnswer(
        (_) async => mockProfileSnapshot,
      );
      when(() => mockProfileSnapshot.exists).thenReturn(true);
      when(() => mockProfileSnapshot.data()).thenReturn(
        testProfile.toFirestore(),
      );

      // Act
      final result = await repository.getUserProfile(userId);

      // Assert
      expect(result, isNotNull);
      expect(result!.uid, userId);
      verify(() => mockProfilesCollection.doc(userId)).called(1);
      verify(() => mockProfileDoc.get()).called(1);
    });

    test('returns null when profile does not exist', () async {
      // Arrange
      when(() => mockProfilesCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.get()).thenAnswer(
        (_) async => mockProfileSnapshot,
      );
      when(() => mockProfileSnapshot.exists).thenReturn(false);

      // Act
      final result = await repository.getUserProfile(userId);

      // Assert
      expect(result, isNull);
    });

    test('throws exception on Firestore error', () async {
      // Arrange
      when(() => mockProfilesCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.get())
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () => repository.getUserProfile(userId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('createUserProfile', () {
    test('creates profile successfully', () async {
      // Arrange
      final testProfile = createTestProfile();
      when(() => mockProfilesCollection.doc(testProfile.uid))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.set(any())).thenAnswer((_) async {});

      // Act
      await repository.createUserProfile(testProfile);

      // Assert
      verify(() => mockProfilesCollection.doc(testProfile.uid)).called(1);
      verify(() => mockProfileDoc.set(any())).called(1);
    });

    test('throws exception on create error', () async {
      // Arrange
      final testProfile = createTestProfile();
      when(() => mockProfilesCollection.doc(testProfile.uid))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.set(any()))
          .thenThrow(Exception('Create error'));

      // Act & Assert
      expect(
        () => repository.createUserProfile(testProfile),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateUserProfile', () {
    test('updates profile successfully', () async {
      // Arrange
      final testProfile = createTestProfile();
      when(() => mockProfilesCollection.doc(testProfile.uid))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.updateUserProfile(testProfile);

      // Assert
      verify(() => mockProfileDoc.update(any())).called(1);
    });

    test('throws exception on update error', () async {
      // Arrange
      final testProfile = createTestProfile();
      when(() => mockProfilesCollection.doc(testProfile.uid))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any()))
          .thenThrow(Exception('Update error'));

      // Act & Assert
      expect(
        () => repository.updateUserProfile(testProfile),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateUserPreferences', () {
    const userId = 'user-123';

    test('updates preferences successfully', () async {
      // Arrange
      final testPreferences = createTestPreferences();
      when(() => mockProfilesCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.updateUserPreferences(userId, testPreferences);

      // Assert
      verify(() => mockProfileDoc.update(any())).called(1);
    });
  });

  group('updateUserLocation', () {
    const userId = 'user-123';
    const lat = 45.4642;
    const lng = 9.1900;
    const locationName = 'Milan';

    test('updates location successfully', () async {
      // Arrange
      when(() => mockProfilesCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.updateUserLocation(userId, lat, lng, locationName);

      // Assert
      verify(() => mockProfileDoc.update(any())).called(1);
    });
  });

  group('setLookingForBuddy', () {
    const userId = 'user-123';

    test('sets looking for buddy status', () async {
      // Arrange
      when(() => mockProfilesCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.setLookingForBuddy(userId, true);

      // Assert
      verify(() => mockProfileDoc.update(any())).called(1);
    });
  });

  group('likeProfile', () {
    const currentUserId = 'user-1';
    const targetUserId = 'user-2';

    test('creates new match when liking profile', () async {
      // Arrange - No existing match
      when(() => mockMatchesCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
          .thenReturn(mockQuery);
      when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(any())).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Mock profile fetches for compatibility calculation
      final currentProfile = createTestProfile(uid: currentUserId);
      final targetProfile = createTestProfile(uid: targetUserId);

      when(() => mockProfilesCollection.doc(currentUserId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfilesCollection.doc(targetUserId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.get()).thenAnswer(
        (_) async => mockProfileSnapshot,
      );
      when(() => mockProfileSnapshot.exists).thenReturn(true);
      when(() => mockProfileSnapshot.data()).thenReturn(
        currentProfile.toFirestore(),
      );

      // Mock match creation
      when(() => mockMatchesCollection.add(any())).thenAnswer(
        (_) async => mockMatchDoc,
      );
      when(() => mockMatchDoc.id).thenReturn('match-123');

      // Mock profile update
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.likeProfile(currentUserId, targetUserId);

      // Assert
      expect(result, isNotNull);
      expect(result.user1Id, currentUserId);
      expect(result.user2Id, targetUserId);
      verify(() => mockMatchesCollection.add(any())).called(1);
    });

    test('throws exception when user profiles not found', () async {
      // Arrange - No existing match
      when(() => mockMatchesCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
          .thenReturn(mockQuery);
      when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(any())).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Mock profile not found
      when(() => mockProfilesCollection.doc(any())).thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.get()).thenAnswer(
        (_) async => mockProfileSnapshot,
      );
      when(() => mockProfileSnapshot.exists).thenReturn(false);

      // Act & Assert
      expect(
        () => repository.likeProfile(currentUserId, targetUserId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('dislikeProfile', () {
    const currentUserId = 'user-1';
    const targetUserId = 'user-2';

    test('updates profile with disliked user', () async {
      // Arrange
      when(() => mockProfilesCollection.doc(currentUserId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.dislikeProfile(currentUserId, targetUserId);

      // Assert
      verify(() => mockProfileDoc.update(any())).called(1);
    });
  });

  group('confirmMatch', () {
    const matchId = 'match-123';
    const userId = 'user-1';

    test('confirms match and updates timestamps', () async {
      // Arrange
      final testMatch = createTestMatch(
        id: matchId,
        user1Id: userId,
        status: MatchStatus.pending,
      );

      when(() => mockMatchesCollection.doc(matchId)).thenReturn(mockMatchDoc);
      when(() => mockMatchDoc.get()).thenAnswer(
        (_) async => mockMatchSnapshot,
      );
      when(() => mockMatchSnapshot.exists).thenReturn(true);
      when(() => mockMatchSnapshot.data()).thenReturn(testMatch.toFirestore());
      when(() => mockMatchDoc.update(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.confirmMatch(matchId, userId);

      // Assert
      expect(result, isNotNull);
      expect(result!.status, MatchStatus.confirmed);
      verify(() => mockMatchDoc.update(any())).called(1);
    });

    test('returns null when match not found', () async {
      // Arrange
      when(() => mockMatchesCollection.doc(matchId)).thenReturn(mockMatchDoc);
      when(() => mockMatchDoc.get()).thenAnswer(
        (_) async => mockMatchSnapshot,
      );
      when(() => mockMatchSnapshot.exists).thenReturn(false);

      // Act
      final result = await repository.confirmMatch(matchId, userId);

      // Assert
      expect(result, isNull);
    });
  });

  group('cancelMatch', () {
    const matchId = 'match-123';
    const userId = 'user-1';

    test('cancels match successfully', () async {
      // Arrange
      when(() => mockMatchesCollection.doc(matchId)).thenReturn(mockMatchDoc);
      when(() => mockMatchDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.cancelMatch(matchId, userId);

      // Assert
      verify(() => mockMatchDoc.update(any())).called(1);
    });
  });

  group('getMatch', () {
    const matchId = 'match-123';

    test('returns match when exists', () async {
      // Arrange
      final testMatch = createTestMatch(id: matchId);
      when(() => mockMatchesCollection.doc(matchId)).thenReturn(mockMatchDoc);
      when(() => mockMatchDoc.get()).thenAnswer(
        (_) async => mockMatchSnapshot,
      );
      when(() => mockMatchSnapshot.exists).thenReturn(true);
      when(() => mockMatchSnapshot.data()).thenReturn(testMatch.toFirestore());

      // Act
      final result = await repository.getMatch(matchId);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, matchId);
    });

    test('returns null when match not found', () async {
      // Arrange
      when(() => mockMatchesCollection.doc(matchId)).thenReturn(mockMatchDoc);
      when(() => mockMatchDoc.get()).thenAnswer(
        (_) async => mockMatchSnapshot,
      );
      when(() => mockMatchSnapshot.exists).thenReturn(false);

      // Act
      final result = await repository.getMatch(matchId);

      // Assert
      expect(result, isNull);
    });
  });

  group('updateMatchStatus', () {
    const matchId = 'match-123';

    test('updates match status successfully', () async {
      // Arrange
      when(() => mockMatchesCollection.doc(matchId)).thenReturn(mockMatchDoc);
      when(() => mockMatchDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.updateMatchStatus(matchId, MatchStatus.confirmed);

      // Assert
      verify(() => mockMatchDoc.update(any())).called(1);
    });
  });

  group('expireOldMatches', () {
    test('expires old pending matches', () async {
      // Arrange
      final batch = MockWriteBatch();
      when(() => mockFirestore.batch()).thenReturn(batch);
      when(() => mockMatchesCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
          .thenReturn(mockQuery);
      when(() => mockQuery.where(any(), isLessThan: any(named: 'isLessThan')))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
      when(() => mockQueryDoc.reference).thenReturn(mockMatchDoc);
      when(() => batch.update(any(), any())).thenReturn(batch);
      when(() => batch.commit()).thenAnswer((_) async {});

      // Act
      await repository.expireOldMatches();

      // Assert
      verify(() => batch.update(any(), any())).called(1);
      verify(() => batch.commit()).called(1);
    });
  });

  group('startPartnership', () {
    const matchId = 'match-123';
    const userId = 'user-1';

    test('starts partnership successfully', () async {
      // Arrange
      final testMatch = createTestMatch(
        id: matchId,
        user1Id: userId,
        user2Id: 'user-2',
        status: MatchStatus.confirmed,
      );

      when(() => mockMatchesCollection.doc(matchId)).thenReturn(mockMatchDoc);
      when(() => mockMatchDoc.get()).thenAnswer(
        (_) async => mockMatchSnapshot,
      );
      when(() => mockMatchSnapshot.exists).thenReturn(true);
      when(() => mockMatchSnapshot.data()).thenReturn(testMatch.toFirestore());
      when(() => mockMatchDoc.update(any())).thenAnswer((_) async {});

      // Mock profile updates
      when(() => mockProfilesCollection.doc(any())).thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.startPartnership(matchId, userId);

      // Assert
      expect(result, isNotNull);
      expect(result!.status, MatchStatus.partnership);
      verify(() => mockMatchDoc.update(any())).called(1);
      verify(() => mockProfileDoc.update(any())).called(2); // Both users
    });
  });

  group('endPartnership', () {
    const matchId = 'match-123';
    const userId = 'user-1';
    const rating = 5;
    const feedback = 'Great partner!';

    test('ends partnership with rating and feedback', () async {
      // Arrange
      final testMatch = createTestMatch(
        id: matchId,
        user1Id: userId,
        user2Id: 'user-2',
        status: MatchStatus.partnership,
      );

      when(() => mockMatchesCollection.doc(matchId)).thenReturn(mockMatchDoc);
      when(() => mockMatchDoc.get()).thenAnswer(
        (_) async => mockMatchSnapshot,
      );
      when(() => mockMatchSnapshot.exists).thenReturn(true);
      when(() => mockMatchSnapshot.data()).thenReturn(testMatch.toFirestore());
      when(() => mockMatchDoc.update(any())).thenAnswer((_) async {});

      // Mock profile updates
      when(() => mockProfilesCollection.doc(any())).thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.endPartnership(
        matchId,
        userId,
        rating: rating,
        feedback: feedback,
      );

      // Assert
      verify(() => mockMatchDoc.update(any())).called(1);
      verify(() => mockProfileDoc.update(any())).called(greaterThanOrEqualTo(2));
    });
  });

  group('updatePartnershipStats', () {
    const matchId = 'match-123';

    test('updates partnership workout stats', () async {
      // Arrange
      when(() => mockMatchesCollection.doc(matchId)).thenReturn(mockMatchDoc);
      when(() => mockMatchDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.updatePartnershipStats(
        matchId,
        sharedWorkouts: 10,
        completedWorkouts: 8,
      );

      // Assert
      verify(() => mockMatchDoc.update(any())).called(1);
    });
  });

  group('updateUserActivity', () {
    const userId = 'user-123';

    test('updates user last seen timestamp', () async {
      // Arrange
      when(() => mockProfilesCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.updateUserActivity(userId);

      // Assert
      verify(() => mockProfileDoc.update(any())).called(1);
    });
  });

  group('setUserOnlineStatus', () {
    const userId = 'user-123';

    test('sets user online status', () async {
      // Arrange
      when(() => mockProfilesCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.setUserOnlineStatus(userId, true);

      // Assert
      verify(() => mockProfileDoc.update(any())).called(1);
    });
  });

  group('saveSearchFilters', () {
    const userId = 'user-123';
    final filters = {'maxDistance': 10.0, 'ageRange': [18, 60]};

    test('saves search filters successfully', () async {
      // Arrange
      when(() => mockFiltersCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.set(any())).thenAnswer((_) async {});

      // Act
      await repository.saveSearchFilters(userId, filters);

      // Assert
      verify(() => mockProfileDoc.set(filters)).called(1);
    });
  });

  group('getSearchFilters', () {
    const userId = 'user-123';

    test('returns saved search filters', () async {
      // Arrange
      final filters = {'maxDistance': 10.0};
      when(() => mockFiltersCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.get()).thenAnswer(
        (_) async => mockProfileSnapshot,
      );
      when(() => mockProfileSnapshot.data()).thenReturn(filters);

      // Act
      final result = await repository.getSearchFilters(userId);

      // Assert
      expect(result, filters);
    });

    test('returns null when no filters saved', () async {
      // Arrange
      when(() => mockFiltersCollection.doc(userId))
          .thenReturn(mockProfileDoc);
      when(() => mockProfileDoc.get()).thenAnswer(
        (_) async => mockProfileSnapshot,
      );
      when(() => mockProfileSnapshot.data()).thenReturn(null);

      // Act
      final result = await repository.getSearchFilters(userId);

      // Assert
      expect(result, isNull);
    });
  });
}
