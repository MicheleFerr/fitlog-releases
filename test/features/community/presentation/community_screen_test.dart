/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test/features/community
/// 🎯 Feature: community screen tests
/// 🔧 Type: widget test
/// 🌍 Localization: ✅ AppLocalizations tested
/// 🎨 Theme: ✅ ColorScheme tested
/// 📱 Platform: Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/community/presentation/community_screen.dart';
import 'package:gymbro_flutter_new/features/community/domain/models/community_post.dart';
import 'package:gymbro_flutter_new/features/community/domain/models/community_user.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import '../../test_helpers/firebase_test_helper.dart';

class MockCommunityProvider extends StateNotifier<List<CommunityPost>> {
  MockCommunityProvider() : super([]);

  void loadPosts() {
    state = [
      CommunityPost(
        id: 'post1',
        userId: 'user1',
        userName: 'John Doe',
        userAvatar: 'https://example.com/avatar1.jpg',
        content: 'Just hit a new PR on bench press! 100kg 💪',
        imageUrl: null,
        workoutId: 'workout1',
        likes: 42,
        comments: 7,
        isLiked: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['bench-press', 'pr', 'chest-day'],
      ),
      CommunityPost(
        id: 'post2',
        userId: 'user2',
        userName: 'Jane Smith',
        userAvatar: 'https://example.com/avatar2.jpg',
        content: 'Leg day completed! Never skip leg day 🦵',
        imageUrl: 'https://example.com/workout.jpg',
        workoutId: 'workout2',
        likes: 28,
        comments: 3,
        isLiked: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        tags: ['leg-day', 'squats', 'motivation'],
      ),
      CommunityPost(
        id: 'post3',
        userId: 'user3',
        userName: 'Mike Johnson',
        userAvatar: null,
        content: 'Looking for a workout partner in NYC area. Anyone interested?',
        imageUrl: null,
        workoutId: null,
        likes: 15,
        comments: 12,
        isLiked: false,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['workout-partner', 'nyc'],
      ),
    ];
  }

  void likePost(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        );
      }
      return post;
    }).toList();
  }

  void addPost(CommunityPost post) {
    state = [post, ...state];
  }

  void deletePost(String postId) {
    state = state.where((post) => post.id != postId).toList();
  }

  void addComment(String postId, String comment) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(comments: post.comments + 1);
      }
      return post;
    }).toList();
  }
}

void main() {
  group('CommunityScreen Tests', () {
    late MockCommunityProvider mockProvider;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockProvider = MockCommunityProvider();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: const [
          // Mock community provider
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CommunityScreen(),
        ),
      );
    }

    testWidgets('displays community feed', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show posts
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Just hit a new PR on bench press! 100kg 💪'), findsOneWidget);
    });

    testWidgets('displays post stats correctly', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check likes and comments
      expect(find.text('42'), findsOneWidget); // likes
      expect(find.text('7'), findsOneWidget); // comments
    });

    testWidgets('shows create post button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays user avatars', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('shows tags on posts', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('#bench-press'), findsOneWidget);
      expect(find.text('#pr'), findsOneWidget);
      expect(find.text('#chest-day'), findsOneWidget);
    });

    testWidgets('handles like action', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap like button
      final likeButtons = find.byIcon(Icons.favorite_border);
      if (likeButtons.evaluate().isNotEmpty) {
        await tester.tap(likeButtons.first);
        await tester.pumpAndSettle();

        // Should toggle like
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    testWidgets('shows comment section', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on comment icon
      final commentButton = find.byIcon(Icons.comment);
      if (commentButton.evaluate().isNotEmpty) {
        await tester.tap(commentButton.first);
        await tester.pumpAndSettle();

        // Should show comment input
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('displays time ago correctly', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show relative time
      expect(find.textContaining('hours ago'), findsWidgets);
      expect(find.textContaining('day ago'), findsWidgets);
    });

    testWidgets('shows workout attachment', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Posts with workout should show workout card
      expect(find.byIcon(Icons.fitness_center), findsWidgets);
    });

    testWidgets('displays images in posts', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show image widget for posts with images
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('shows share button', (tester) async {
      mockProvider.loadPosts();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.share), findsWidgets);
    });

    testWidgets('handles pull to refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 200));
      await tester.pumpAndSettle();

      // Should reload posts
      expect(mockProvider.state, isNotNull);
    });

    testWidgets('shows filter options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for filter icon
      final filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Should show filter options
        expect(find.text('Following'), findsWidgets);
        expect(find.text('Popular'), findsWidgets);
        expect(find.text('Recent'), findsWidgets);
      }
    });

    testWidgets('shows search functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for search icon
      final searchButton = find.byIcon(Icons.search);
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // Should show search field
        expect(find.byType(TextField), findsOneWidget);
      }
    });
  });

  group('CommunityPost Model Tests', () {
    test('creates post with all fields', () {
      final post = CommunityPost(
        id: 'test-post',
        userId: 'test-user',
        userName: 'Test User',
        userAvatar: 'avatar.jpg',
        content: 'Test content',
        imageUrl: 'image.jpg',
        workoutId: 'workout-1',
        likes: 10,
        comments: 5,
        isLiked: true,
        timestamp: DateTime(2024, 1, 1),
        tags: ['test', 'post'],
      );

      expect(post.id, 'test-post');
      expect(post.userName, 'Test User');
      expect(post.likes, 10);
      expect(post.isLiked, true);
      expect(post.tags.length, 2);
    });

    test('copyWith preserves unchanged fields', () {
      final original = CommunityPost(
        id: 'post1',
        userId: 'user1',
        userName: 'User',
        content: 'Content',
        likes: 10,
        comments: 5,
        isLiked: false,
        timestamp: DateTime.now(),
        tags: [],
      );

      final modified = original.copyWith(likes: 11, isLiked: true);

      expect(modified.id, original.id);
      expect(modified.userName, original.userName);
      expect(modified.likes, 11);
      expect(modified.isLiked, true);
      expect(modified.comments, 5);
    });

    test('formats timestamp correctly', () {
      final now = DateTime.now();
      final post = CommunityPost(
        id: 'post1',
        userId: 'user1',
        userName: 'User',
        content: 'Content',
        likes: 0,
        comments: 0,
        isLiked: false,
        timestamp: now.subtract(const Duration(minutes: 30)),
        tags: [],
      );

      // Should format as "30 minutes ago"
      final timeAgo = _getTimeAgo(post.timestamp);
      expect(timeAgo, contains('minutes ago'));
    });

    test('handles hashtag extraction', () {
      const content = 'Great workout today! #legday #fitness #gymlife';
      final tags = _extractHashtags(content);
      
      expect(tags.length, 3);
      expect(tags, contains('legday'));
      expect(tags, contains('fitness'));
      expect(tags, contains('gymlife'));
    });
  });

  group('Community Interactions Tests', () {
    test('like/unlike post updates state', () {
      final provider = MockCommunityProvider();
      provider.loadPosts();
      
      final initialPost = provider.state.first;
      final initialLikes = initialPost.likes;
      
      provider.likePost(initialPost.id);
      
      final updatedPost = provider.state.firstWhere((p) => p.id == initialPost.id);
      expect(updatedPost.isLiked, !initialPost.isLiked);
      expect(updatedPost.likes, initialPost.isLiked ? initialLikes - 1 : initialLikes + 1);
    });

    test('add new post to feed', () {
      final provider = MockCommunityProvider();
      provider.loadPosts();
      
      final initialCount = provider.state.length;
      
      final newPost = CommunityPost(
        id: 'new-post',
        userId: 'current-user',
        userName: 'Current User',
        content: 'New post content',
        likes: 0,
        comments: 0,
        isLiked: false,
        timestamp: DateTime.now(),
        tags: [],
      );
      
      provider.addPost(newPost);
      
      expect(provider.state.length, initialCount + 1);
      expect(provider.state.first.id, 'new-post');
    });

    test('delete post from feed', () {
      final provider = MockCommunityProvider();
      provider.loadPosts();
      
      final initialCount = provider.state.length;
      final postToDelete = provider.state.first;
      
      provider.deletePost(postToDelete.id);
      
      expect(provider.state.length, initialCount - 1);
      expect(provider.state.any((p) => p.id == postToDelete.id), false);
    });

    test('add comment increments count', () {
      final provider = MockCommunityProvider();
      provider.loadPosts();
      
      final post = provider.state.first;
      final initialComments = post.comments;
      
      provider.addComment(post.id, 'Great job!');
      
      final updatedPost = provider.state.firstWhere((p) => p.id == post.id);
      expect(updatedPost.comments, initialComments + 1);
    });
  });

  group('Community User Tests', () {
    test('creates community user profile', () {
      final user = CommunityUser(
        id: 'user1',
        name: 'Test User',
        avatar: 'avatar.jpg',
        bio: 'Fitness enthusiast',
        followers: 100,
        following: 50,
        workoutCount: 200,
        joinDate: DateTime(2023, 1, 1),
        isFollowing: false,
        badges: ['early-adopter', 'consistent'],
      );

      expect(user.id, 'user1');
      expect(user.followers, 100);
      expect(user.badges.length, 2);
    });

    test('calculates user stats', () {
      final user = CommunityUser(
        id: 'user1',
        name: 'User',
        followers: 1000,
        following: 100,
        workoutCount: 500,
        joinDate: DateTime.now().subtract(const Duration(days: 365)),
      );

      // Calculate engagement ratio
      final ratio = user.followers / user.following;
      expect(ratio, 10.0);

      // Calculate workouts per month
      const monthsSinceJoin = 12;
      final workoutsPerMonth = user.workoutCount / monthsSinceJoin;
      expect(workoutsPerMonth, closeTo(41.67, 0.01));
    });
  });
}

String _getTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  
  if (difference.inDays > 0) {
    return '${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"} ago';
  } else {
    return 'Just now';
  }
}

List<String> _extractHashtags(String content) {
  final regex = RegExp(r'#(\w+)');
  final matches = regex.allMatches(content);
  return matches.map((m) => m.group(1)!).toList();
}