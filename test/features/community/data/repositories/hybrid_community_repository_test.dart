import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/hybrid_community_repository.dart'
    as repo;
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'hybrid_community_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentSnapshot,
  HiveBoxManagerEnhanced,
  Box,
  User,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HybridCommunityRepository - Search & Filter', () {
    late repo.HybridCommunityRepository repository;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockHiveBoxManagerEnhanced mockBoxManager;
    late MockBox<Map> mockContributionsBox;
    late MockBox<Map> mockVotesBox;
    late MockBox<Map> mockStatsBox;
    late MockUser mockUser;

    // Helper to setup mock box with test data
    void setupMockBoxWithData(List<CommunityContribution> contributions) {
      final mockData = Map<String, Map<String, dynamic>>.fromEntries(
        contributions.map((c) => MapEntry(c.id, c.toJson())),
      );

      // Update the contributions box to return the test data
      when(mockContributionsBox.keys).thenReturn(mockData.keys.toList());
      when(mockContributionsBox.values).thenReturn(mockData.values.toList());
      when(mockContributionsBox.get(any, defaultValue: anyNamed('defaultValue')))
          .thenAnswer((invocation) {
        final key = invocation.positionalArguments[0];
        return mockData.containsKey(key) ? mockData[key] : null;
      });
    }

    // Test data
    final testContributions = [
      CommunityContribution(
        id: '1',
        exerciseId: 'ex_1',
        exerciseName: 'Bench Press',
        userId: 'user_1',
        userName: 'John Doe',
        type: ContributionType.tip,
        status: ContributionStatus.approved,
        title: 'Perfect Bench Press Form',
        description: 'Keep your back flat and drive through your heels',
        createdAt: DateTime(2025, 1, 1),
        upvotes: 50,
        downvotes: 2,
        difficulty: 'beginner',
        authorTier: 'expert',
        saves: 10,
        viewCount: 100,
        lastActivityAt: DateTime(2025, 1, 5),
      ),
      CommunityContribution(
        id: '2',
        exerciseId: 'ex_2',
        exerciseName: 'Squat',
        userId: 'user_2',
        userName: 'Jane Smith',
        type: ContributionType.technique,
        status: ContributionStatus.approved,
        title: 'Advanced Squat Technique',
        description: 'Focus on depth and ankle mobility for optimal results',
        createdAt: DateTime(2025, 1, 2),
        upvotes: 30,
        downvotes: 5,
        difficulty: 'advanced',
        authorTier: 'community',
        saves: 5,
        viewCount: 50,
        lastActivityAt: DateTime(2025, 1, 4),
      ),
      CommunityContribution(
        id: '3',
        exerciseId: 'ex_1',
        exerciseName: 'Bench Press',
        userId: 'user_3',
        userName: 'Admin User',
        type: ContributionType.warning,
        status: ContributionStatus.approved,
        title: 'Bench Press Safety Warning',
        description: 'Always use a spotter for heavy lifts',
        createdAt: DateTime(2025, 1, 3),
        upvotes: 100,
        downvotes: 1,
        difficulty: 'intermediate',
        authorTier: 'admin',
        saves: 20,
        viewCount: 200,
        lastActivityAt: DateTime(2025, 1, 6),
      ),
      CommunityContribution(
        id: '4',
        exerciseId: 'ex_3',
        exerciseName: 'Deadlift',
        userId: 'user_1',
        userName: 'John Doe',
        type: ContributionType.correction,
        status: ContributionStatus.pending,
        title: 'Deadlift Form Correction',
        description: 'Keep the bar close to your body',
        createdAt: DateTime(2025, 1, 4),
        upvotes: 5,
        downvotes: 0,
        difficulty: 'beginner',
        authorTier: 'expert',
        saves: 2,
        viewCount: 20,
        lastActivityAt: DateTime(2025, 1, 4),
      ),
    ];

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockBoxManager = MockHiveBoxManagerEnhanced();
      mockContributionsBox = MockBox<Map>();
      mockVotesBox = MockBox<Map>();
      mockStatsBox = MockBox<Map>();
      mockUser = MockUser();

      // Setup auth mock
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_user_id');

      // Setup box manager mocks to return different boxes based on name
      when(mockBoxManager.openBox<Map>(argThat(contains('data')))).thenAnswer((_) async => mockContributionsBox);
      when(mockBoxManager.openBox<Map>(argThat(contains('votes')))).thenAnswer((_) async => mockVotesBox);
      when(mockBoxManager.openBox<Map>(argThat(contains('stats')))).thenAnswer((_) async => mockStatsBox);
      when(mockBoxManager.openBox<Map>(argThat(contains('sync')))).thenAnswer((_) async => mockContributionsBox);

      // Setup contributions box
      when(mockContributionsBox.values).thenReturn([]);
      when(mockContributionsBox.keys).thenReturn([]);
      when(mockContributionsBox.get(any, defaultValue: anyNamed('defaultValue'))).thenReturn(null);
      when(mockContributionsBox.put(any, any)).thenAnswer((_) async => {});
      when(mockContributionsBox.delete(any)).thenAnswer((_) async => {});

      // Setup votes box
      when(mockVotesBox.values).thenReturn([]);
      when(mockVotesBox.keys).thenReturn([]);
      when(mockVotesBox.get(any, defaultValue: anyNamed('defaultValue'))).thenReturn(null);
      when(mockVotesBox.put(any, any)).thenAnswer((_) async => {});

      // Setup stats box
      when(mockStatsBox.values).thenReturn([]);
      when(mockStatsBox.keys).thenReturn([]);
      when(mockStatsBox.get(any, defaultValue: anyNamed('defaultValue'))).thenReturn(null);
      when(mockStatsBox.put(any, any)).thenAnswer((_) async => {});

      repository = repo.HybridCommunityRepository(
        boxManager: mockBoxManager,
        firestore: mockFirestore,
        auth: mockAuth,
      );
    });

    group('Search Functionality', () {
      test('searchContributions returns filtered results by title', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final results = await repository.searchContributions('Bench Press');

        // Assert
        expect(results.length, 2);
        expect(results.every((c) => c.title.contains('Bench Press') ||
                                     c.exerciseName.contains('Bench Press')), true);
      });

      test('searchContributions returns filtered results by description', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final results = await repository.searchContributions('mobility');

        // Assert
        expect(results.length, 1);
        expect(results.first.description.toLowerCase().contains('mobility'), true);
      });

      test('searchContributions returns filtered results by exercise name', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final results = await repository.searchContributions('Squat');

        // Assert
        expect(results.length, 1);
        expect(results.first.exerciseName, 'Squat');
      });

      test('searchContributions is case insensitive', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final results = await repository.searchContributions('BENCH PRESS');

        // Assert
        expect(results.length, 2);
      });

      test('searchContributions returns empty list for empty query', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final results = await repository.searchContributions('');

        // Assert
        expect(results, isEmpty);
      });

      test('searchContributions returns empty list when no matches', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final results = await repository.searchContributions('NonExistent Exercise');

        // Assert
        expect(results, isEmpty);
      });
    });

    group('Filter Application', () {
      test('getContributions filters by exerciseId', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final resultsStream = repository.getContributions(exerciseId: 'ex_1');
        final results = await resultsStream.first;

        // Assert
        expect(results.length, 2);
        expect(results.every((c) => c.exerciseId == 'ex_1'), true);
      });

      test('getContributions filters by status', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final resultsStream = repository.getContributions(
          status: ContributionStatus.pending,
        );
        final results = await resultsStream.first;

        // Assert
        expect(results.length, 1);
        expect(results.first.status, ContributionStatus.pending);
      });

      test('getContributions filters by userId', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final resultsStream = repository.getContributions(userId: 'user_1');
        final results = await resultsStream.first;

        // Assert
        expect(results.length, 2);
        expect(results.every((c) => c.userId == 'user_1'), true);
      });

      test('getContributions applies multiple filters', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final resultsStream = repository.getContributions(
          exerciseId: 'ex_1',
          status: ContributionStatus.approved,
        );
        final results = await resultsStream.first;

        // Assert
        expect(results.length, 2);
        expect(results.every((c) =>
          c.exerciseId == 'ex_1' &&
          c.status == ContributionStatus.approved
        ), true);
      });

      test('getContributions returns empty list when no matches', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final resultsStream = repository.getContributions(
          exerciseId: 'non_existent',
        );
        final results = await resultsStream.first;

        // Assert
        expect(results, isEmpty);
      });
    });

    group('Sort Options', () {
      test('getContributions sorts by createdAt descending (recent)', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final resultsStream = repository.getContributions();
        final results = await resultsStream.first;

        // Assert
        expect(results.length, 4);
        // Verify descending order by createdAt
        for (int i = 0; i < results.length - 1; i++) {
          expect(
            results[i].createdAt.isAfter(results[i + 1].createdAt) ||
            results[i].createdAt.isAtSameMomentAs(results[i + 1].createdAt),
            true,
            reason: 'Results should be sorted by createdAt descending',
          );
        }
      });

      test('contributions can be sorted by upvotes (helpful)', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Get all contributions
        final resultsStream = repository.getContributions();
        final results = await resultsStream.first;

        // Act - Sort by upvotes (helpful)
        results.sort((a, b) => b.upvotes.compareTo(a.upvotes));

        // Assert
        expect(results.first.upvotes, 100); // Admin warning
        expect(results.last.upvotes, 5); // Pending correction
      });

      test('contributions can be sorted by saves count', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Get all contributions
        final resultsStream = repository.getContributions();
        final results = await resultsStream.first;

        // Act - Sort by saves
        results.sort((a, b) => b.saves.compareTo(a.saves));

        // Assert
        expect(results.first.saves, 20);
        expect(results.last.saves, 2);
      });

      test('contributions can be sorted by trending (lastActivityAt)', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Get all contributions
        final resultsStream = repository.getContributions();
        final results = await resultsStream.first;

        // Act - Sort by trending (recent activity)
        results.sort((a, b) {
          final aActivity = a.lastActivityAt ?? a.createdAt;
          final bActivity = b.lastActivityAt ?? b.createdAt;
          return bActivity.compareTo(aActivity);
        });

        // Assert
        expect(results.first.id, '3'); // Admin warning (Jan 6)
        expect(results.last.id, '4'); // Deadlift (Jan 4)
      });
    });

    group('Save/Unsave Operations', () {
      test('voteOnContribution records upvote correctly', () async {
        // Arrange
        final contribution = testContributions.first;
        setupMockBoxWithData([contribution]);

        // Act
        await repository.voteOnContribution(contribution.id, true);

        // Assert
        verify(mockVotesBox.put(
          'test_user_id_${contribution.id}',
          argThat(isA<Map>().having(
            (m) => m['isUpvote'],
            'isUpvote',
            true,
          )),
        )).called(1);
      });

      test('voteOnContribution records downvote correctly', () async {
        // Arrange
        final contribution = testContributions.first;
        setupMockBoxWithData([contribution]);

        // Act
        await repository.voteOnContribution(contribution.id, false);

        // Assert
        verify(mockVotesBox.put(
          'test_user_id_${contribution.id}',
          argThat(isA<Map>().having(
            (m) => m['isUpvote'],
            'isUpvote',
            false,
          )),
        )).called(1);
      });

      test('voteOnContribution updates stats', () async {
        // Arrange
        final contribution = testContributions.first;
        setupMockBoxWithData([contribution]);

        // Act
        await repository.voteOnContribution(contribution.id, true);

        // Assert
        verify(mockStatsBox.put(
          'stats_test_user_id',
          argThat(isA<Map>().having(
            (m) => m['totalPoints'],
            'totalPoints',
            repo.ContributionPoints.voteOnContribution,
          )),
        )).called(1);
      });

      test('voteOnContribution throws when user not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => repository.voteOnContribution('contrib_id', true),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User not authenticated'),
          )),
        );
      });

      test('commentOnContribution adds comment to contribution', () async {
        // Arrange
        final contribution = testContributions.first;
        final comment = ContributionComment(
          id: 'comment_1',
          userId: 'test_user_id',
          userName: 'Test User',
          text: 'Great tip!',
          createdAt: DateTime.now(),
        );

        setupMockBoxWithData([contribution]);

        // Act
        await repository.commentOnContribution(contribution.id, comment);

        // Assert
        verify(mockStatsBox.put(
          'stats_test_user_id',
          argThat(isA<Map>().having(
            (m) => m['totalPoints'],
            'totalPoints',
            repo.ContributionPoints.commentOnContribution,
          )),
        )).called(1);
      });
    });

    group('Edge Cases', () {
      test('handles null values gracefully in search', () async {
        // Arrange
        final contributionWithNulls = CommunityContribution(
          id: '99',
          exerciseId: 'ex_99',
          exerciseName: '',
          userId: 'user_99',
          userName: 'User 99',
          type: ContributionType.tip,
          status: ContributionStatus.pending,
          title: '',
          description: '',
          createdAt: DateTime.now(),
        );

        setupMockBoxWithData([contributionWithNulls]);

        // Act
        final results = await repository.searchContributions('anything');

        // Assert
        expect(results, isEmpty);
      });

      test('handles empty database', () async {
        // Arrange
        setupMockBoxWithData([]);

        // Act
        final results = await repository.searchContributions('query');

        // Assert
        expect(results, isEmpty);
      });

      test('getContributions returns all when no filters provided', () async {
        // Arrange
        setupMockBoxWithData(testContributions);

        // Act
        final resultsStream = repository.getContributions();
        final results = await resultsStream.first;

        // Assert
        expect(results.length, testContributions.length);
      });

      test('getUserStats handles empty contributions', () async {
        // Arrange
        setupMockBoxWithData([]);

        // Act
        final statsStream = repository.getUserStats('test_user_id');
        final stats = await statsStream.first;

        // Assert
        expect(stats.totalContributions, 0);
        expect(stats.approvalRate, 0.0);
        expect(stats.level, 'Rookie');
      });

      test('getTrendingContributions returns empty for free users', () async {
        // Arrange - Free user (non-premium)
        // Default setup has user as non-premium

        // Act
        final resultsStream = repository.getTrendingContributions();
        final results = await resultsStream.first;

        // Assert
        expect(results, isEmpty);
      });

      test('submitContribution validates required fields', () async {
        // Arrange
        final invalidContribution = CommunityContribution(
          id: '',
          exerciseId: '',
          exerciseName: '',
          userId: 'user_1',
          userName: 'User',
          type: ContributionType.tip,
          status: ContributionStatus.pending,
          title: '',
          description: 'Description',
          createdAt: DateTime.now(),
        );

        // Act & Assert
        // The repository uses validate() which checks id.isNotEmpty && title.isNotEmpty && exerciseId.isNotEmpty
        // Invalid contributions should throw an exception
        expect(
          () => repository.submitContribution(invalidContribution),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Entity validation failed'),
          )),
        );
      });
    });

    group('getUserStats', () {
      test('calculates stats correctly from contributions', () async {
        // Arrange
        final userContributions = testContributions
            .where((c) => c.userId == 'user_1')
            .toList();

        setupMockBoxWithData(userContributions);

        // Act
        final statsStream = repository.getUserStats('user_1');
        final stats = await statsStream.first;

        // Assert
        expect(stats.totalContributions, 2);
        expect(stats.approvedContributions, 1);
        expect(stats.pendingContributions, 1);
        expect(stats.rejectedContributions, 0);
        expect(stats.approvalRate, 0.5); // 1 approved out of 2 total
      });

      test('caches stats after calculation', () async {
        // Arrange
        setupMockBoxWithData([]);

        // Act
        final statsStream = repository.getUserStats('test_user_id');
        await statsStream.first;

        // Assert - Verify stats were cached
        verify(mockStatsBox.put('stats_test_user_id', any)).called(1);
      });

      test('returns cached stats when available', () async {
        // Arrange
        final cachedStats = <String, dynamic>{
          'userId': 'test_user_id',
          'totalContributions': 10,
          'approvedContributions': 8,
          'rejectedContributions': 1,
          'pendingContributions': 1,
          'totalVotes': 0,
          'totalPoints': 500,
          'currentStreak': 0,
          'longestStreak': 0,
          'level': 'Advanced',
          'badges': <Map<String, dynamic>>[],
          'contributionsByType': <String, int>{},
          'approvalRate': 0.8,
          'weeklyRank': 0,
          'monthlyRank': 0,
          'allTimeRank': 0,
        };

        when(mockStatsBox.get('stats_test_user_id', defaultValue: anyNamed('defaultValue'))).thenReturn(cachedStats);

        // Act
        final statsStream = repository.getUserStats('test_user_id');
        final stats = await statsStream.first;

        // Assert
        expect(stats.totalContributions, 10);
        expect(stats.approvedContributions, 8);
        expect(stats.level, 'Advanced');
        expect(stats.approvalRate, 0.8);
      });
    });
  });
}
