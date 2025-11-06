/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test
/// 🎯 Feature: buddy_matching
/// 🔧 Type: unit test
/// 🌍 Localization: N/A - Test file
/// 🎨 Theme: N/A - Test file
/// 📱 Platform: Universal
///
/// Comprehensive tests for BuddyMatch entity and partnership logic
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_match.dart';

void main() {
  group('BuddyMatch Entity Tests', () {
    late BuddyMatch testMatch;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testMatch = BuddyMatch(
        id: 'match-123',
        user1Id: 'user-1',
        user2Id: 'user-2',
        status: MatchStatus.pending,
        compatibilityScore: 85.5,
        initiatorId: 'user-1',
        user1LikedAt: now,
        user2LikedAt: null,
        expiresAt: now.add(const Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
      );
    });

    group('Match Creation', () {
      test('create factory builds valid pending match', () {
        final match = BuddyMatch.create(
          user1Id: 'user-a',
          user2Id: 'user-b',
          compatibilityScore: 75.0,
          initiatorId: 'user-a',
        );

        expect(match.user1Id, equals('user-a'));
        expect(match.user2Id, equals('user-b'));
        expect(match.status, equals(MatchStatus.pending));
        expect(match.compatibilityScore, equals(75.0));
        expect(match.initiatorId, equals('user-a'));
        expect(match.user1LikedAt, isNotNull);
        expect(match.user2LikedAt, isNull);
        expect(match.expiresAt, isNotNull);
      });

      test('match expires in 7 days by default', () {
        final match = BuddyMatch.create(
          user1Id: 'user-a',
          user2Id: 'user-b',
          compatibilityScore: 75.0,
          initiatorId: 'user-a',
        );

        final expiryDuration = match.expiresAt!.difference(match.createdAt!);
        expect(expiryDuration.inDays, equals(7));
      });

      test('initiator sets correct liked timestamp', () {
        final matchUser1Init = BuddyMatch.create(
          user1Id: 'user-1',
          user2Id: 'user-2',
          compatibilityScore: 80.0,
          initiatorId: 'user-1',
        );

        expect(matchUser1Init.user1LikedAt, isNotNull);
        expect(matchUser1Init.user2LikedAt, isNull);

        final matchUser2Init = BuddyMatch.create(
          user1Id: 'user-1',
          user2Id: 'user-2',
          compatibilityScore: 80.0,
          initiatorId: 'user-2',
        );

        expect(matchUser2Init.user1LikedAt, isNull);
        expect(matchUser2Init.user2LikedAt, isNotNull);
      });
    });

    group('User Identification', () {
      test('getOtherUserId returns correct user', () {
        expect(testMatch.getOtherUserId('user-1'), equals('user-2'));
        expect(testMatch.getOtherUserId('user-2'), equals('user-1'));
      });

      test('hasUserLiked checks correct user', () {
        expect(testMatch.hasUserLiked('user-1'), isTrue);
        expect(testMatch.hasUserLiked('user-2'), isFalse);
      });

      test('hasUserLiked returns false for non-participants', () {
        expect(testMatch.hasUserLiked('user-3'), isFalse);
      });
    });

    group('Match Status Checks', () {
      test('isMutualMatch returns true when both liked', () {
        final mutualMatch = testMatch.copyWith(
          user1LikedAt: now,
          user2LikedAt: now.add(const Duration(hours: 1)),
        );

        expect(mutualMatch.isMutualMatch, isTrue);
      });

      test('isMutualMatch returns false when only one liked', () {
        expect(testMatch.isMutualMatch, isFalse);
      });

      test('isExpired returns true for expired pending match', () {
        final expiredMatch = testMatch.copyWith(
          expiresAt: now.subtract(const Duration(days: 1)),
          status: MatchStatus.pending,
        );

        expect(expiredMatch.isExpired, isTrue);
      });

      test('isExpired returns false for active pending match', () {
        expect(testMatch.isExpired, isFalse);
      });

      test('isExpired returns false for confirmed match', () {
        final confirmedMatch = testMatch.copyWith(
          status: MatchStatus.confirmed,
          expiresAt: now.subtract(const Duration(days: 1)),
        );

        expect(confirmedMatch.isExpired, isFalse);
      });

      test('isActivePartnership returns true for partnership status', () {
        final partnership = testMatch.copyWith(
          status: MatchStatus.partnership,
        );

        expect(partnership.isActivePartnership, isTrue);
      });

      test('isActivePartnership returns false for other statuses', () {
        expect(testMatch.isActivePartnership, isFalse);
      });
    });

    group('Unread Messages', () {
      test('getUnreadCount returns correct count for users', () {
        final matchWithUnread = testMatch.copyWith(
          unreadCount1: 5,
          unreadCount2: 3,
        );

        expect(matchWithUnread.getUnreadCount('user-1'), equals(5));
        expect(matchWithUnread.getUnreadCount('user-2'), equals(3));
      });

      test('getUnreadCount returns 0 for non-participants', () {
        expect(testMatch.getUnreadCount('user-3'), equals(0));
      });
    });

    group('Partnership Management', () {
      test('canStartPartnership returns true for confirmed match', () {
        final confirmed = testMatch.copyWith(status: MatchStatus.confirmed);

        expect(confirmed.canStartPartnership('user-1'), isTrue);
        expect(confirmed.canStartPartnership('user-2'), isTrue);
      });

      test('canStartPartnership returns false for pending match', () {
        expect(testMatch.canStartPartnership('user-1'), isFalse);
      });

      test('canStartPartnership returns false for non-participants', () {
        final confirmed = testMatch.copyWith(status: MatchStatus.confirmed);

        expect(confirmed.canStartPartnership('user-3'), isFalse);
      });

      test('partnershipDurationDays calculates correct duration', () {
        final partnership = testMatch.copyWith(
          status: MatchStatus.partnership,
          partnershipStartedAt: now.subtract(const Duration(days: 10)),
          partnershipEndedAt: now,
        );

        expect(partnership.partnershipDurationDays, equals(10));
      });

      test('partnershipDurationDays returns null when not started', () {
        expect(testMatch.partnershipDurationDays, isNull);
      });

      test('partnershipDurationDays uses now when still active', () {
        final activePartnership = testMatch.copyWith(
          status: MatchStatus.partnership,
          partnershipStartedAt: now.subtract(const Duration(days: 5)),
          partnershipEndedAt: null,
        );

        expect(activePartnership.partnershipDurationDays, equals(5));
      });
    });

    group('Workout Stats', () {
      test('workoutCompletionRate calculates correct percentage', () {
        final matchWithWorkouts = testMatch.copyWith(
          plannedWorkouts: 10,
          completedWorkouts: 7,
        );

        expect(matchWithWorkouts.workoutCompletionRate, equals(0.7));
      });

      test('workoutCompletionRate returns 0 when no planned workouts', () {
        expect(testMatch.workoutCompletionRate, equals(0.0));
      });

      test('workoutCompletionRate handles 100% completion', () {
        final perfectCompletion = testMatch.copyWith(
          plannedWorkouts: 5,
          completedWorkouts: 5,
        );

        expect(perfectCompletion.workoutCompletionRate, equals(1.0));
      });
    });

    group('Rating and Feedback', () {
      test('averageRating calculates correctly', () {
        final ratedMatch = testMatch.copyWith(
          user1Rating: 5,
          user2Rating: 4,
        );

        expect(ratedMatch.averageRating, equals(4.5));
      });

      test('averageRating returns null when incomplete', () {
        final partialRating = testMatch.copyWith(
          user1Rating: 5,
          user2Rating: null,
        );

        expect(partialRating.averageRating, isNull);
      });

      test('wasSuccessfulPartnership requires completed status', () {
        final goodPartnership = testMatch.copyWith(
          status: MatchStatus.completed,
          user1Rating: 5,
          user2Rating: 4,
          plannedWorkouts: 10,
          completedWorkouts: 8,
        );

        expect(goodPartnership.wasSuccessfulPartnership, isTrue);
      });

      test('wasSuccessfulPartnership requires good rating', () {
        final lowRating = testMatch.copyWith(
          status: MatchStatus.completed,
          user1Rating: 3,
          user2Rating: 2,
          plannedWorkouts: 10,
          completedWorkouts: 9,
        );

        expect(lowRating.wasSuccessfulPartnership, isFalse);
      });

      test('wasSuccessfulPartnership requires 70% completion', () {
        final lowCompletion = testMatch.copyWith(
          status: MatchStatus.completed,
          user1Rating: 5,
          user2Rating: 5,
          plannedWorkouts: 10,
          completedWorkouts: 6,
        );

        expect(lowCompletion.wasSuccessfulPartnership, isFalse);
      });
    });

    group('Time Until Expiration', () {
      test('timeUntilExpiration calculates remaining time', () {
        final expiresIn3Days = testMatch.copyWith(
          expiresAt: now.add(const Duration(days: 3)),
        );

        final timeLeft = expiresIn3Days.timeUntilExpiration;
        expect(timeLeft, isNotNull);
        expect(timeLeft!.inDays, greaterThanOrEqualTo(2)); // Account for timing
        expect(timeLeft!.inDays, lessThanOrEqualTo(3));
      });

      test('timeUntilExpiration returns null for expired match', () {
        final expired = testMatch.copyWith(
          expiresAt: now.subtract(const Duration(days: 1)),
          status: MatchStatus.pending,
        );

        expect(expired.timeUntilExpiration, isNull);
      });
    });

    group('Status Display', () {
      test('getStatusDisplay shows pending with days remaining', () {
        final display = testMatch.getStatusDisplay(currentUserId: 'user-1');

        expect(display, contains('In attesa di risposta'));
        expect(display, contains('rimasti'));
      });

      test('getStatusDisplay shows match request for non-initiator', () {
        final display = testMatch.getStatusDisplay(currentUserId: 'user-2');

        expect(display, contains('Vuole fare workout con te'));
      });

      test('getStatusDisplay shows confirmed status with action prompt', () {
        final confirmed = testMatch.copyWith(status: MatchStatus.confirmed);
        final display = confirmed.getStatusDisplay();

        expect(display, equals('Match confermato! Inizia una partnership'));
      });

      test('getStatusDisplay shows partnership duration', () {
        final partnership = testMatch.copyWith(
          status: MatchStatus.partnership,
          partnershipStartedAt: now.subtract(const Duration(days: 15)),
        );
        final display = partnership.getStatusDisplay();

        expect(display, contains('Partnership attiva da 15g'));
      });

      test('getStatusDisplay shows completed with rating', () {
        final completed = testMatch.copyWith(
          status: MatchStatus.completed,
          user1Rating: 5,
          user2Rating: 4,
        );
        final display = completed.getStatusDisplay();

        expect(display, contains('Completato'));
        expect(display, contains('4.5'));
      });
    });

    group('Status Enum', () {
      test('MatchStatus has correct display names', () {
        expect(MatchStatus.pending.displayName, equals('In attesa'));
        expect(MatchStatus.confirmed.displayName, equals('Confermato'));
        expect(MatchStatus.partnership.displayName, equals('Partnership attiva'));
        expect(MatchStatus.completed.displayName, equals('Completato'));
        expect(MatchStatus.expired.displayName, equals('Scaduto'));
        expect(MatchStatus.cancelled.displayName, equals('Cancellato'));
      });
    });
  });
}
