/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: test
 * 🎯 Feature: buddy_matching
 * 🔧 Type: unit test
 * 🌍 Localization: N/A - Test file
 * 🎨 Theme: N/A - Test file
 * 📱 Platform: Universal
 * 
 * Testing enhanced BuddyProfile entity with tier-1 features
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';

void main() {
  group('Enhanced BuddyProfile Tests', () {
    late BuddyProfile testProfile;
    late BuddyPreferences testPreferences;

    setUp(() {
      testPreferences = const BuddyPreferences(
        isLookingForBuddy: true,
        fitnessLevel: FitnessLevel.intermediate,
        goals: [WorkoutGoal.muscleGain, WorkoutGoal.strength],
        cityName: 'Milano',
        cityCode: 'MI',
        zoneName: 'Centro Storico',
        matchingPurpose: MatchingPurpose.workoutPartner,
        openToDating: false,
        openToFriendship: true,
      );

      testProfile = BuddyProfile(
        uid: 'test_user_123',
        displayName: 'Test User',
        preferences: testPreferences,
        badges: [BadgeType.verified, BadgeType.instagramVerified],
        partnershipsCount: 5,
        successfulPartnerships: 4,
        averageRating: 4.5,
        totalRatings: 10,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 10)),
        isActive: true,
        isVerified: true,
        totalWorkouts: 100,
        totalVolume: 50000.0,
        superLikesRemaining: 2,
        isBoosted: true,
        boostExpiry: DateTime.now().add(const Duration(minutes: 30)),
        isPhotoVerified: true,
        completedWorkoutsTogether: 25,
        workoutTogetherIds: ['w1', 'w2', 'w3'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
    });

    group('Super Likes', () {
      test('should check if user can super like', () {
        expect(testProfile.canSuperLike, isTrue);
      });

      test('should not allow super like when no remaining', () {
        final profileNoSuper = testProfile.copyWith(superLikesRemaining: 0);
        expect(profileNoSuper.canSuperLike, isFalse);
      });

      test('should detect when super like reset is needed', () {
        final profileOldReset = testProfile.copyWith(
          lastSuperLikeReset: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(profileOldReset.needsSuperLikeReset, isTrue);
      });

      test('should not need reset for same day', () {
        final profileSameDay = testProfile.copyWith(
          lastSuperLikeReset: DateTime.now().subtract(const Duration(hours: 2)),
        );
        expect(profileSameDay.needsSuperLikeReset, isFalse);
      });
    });

    group('Boost System', () {
      test('should detect currently boosted profile', () {
        expect(testProfile.isCurrentlyBoosted, isTrue);
      });

      test('should not be boosted when expired', () {
        final expiredProfile = testProfile.copyWith(
          boostExpiry: DateTime.now().subtract(const Duration(minutes: 10)),
        );
        expect(expiredProfile.isCurrentlyBoosted, isFalse);
      });

      test('should not be boosted when flag is false', () {
        final notBoostedProfile = testProfile.copyWith(isBoosted: false);
        expect(notBoostedProfile.isCurrentlyBoosted, isFalse);
      });

      test('should check if can start boost', () {
        final nonBoostedProfile = testProfile.copyWith(
          isBoosted: false,
          boostExpiry: null,
        );
        expect(nonBoostedProfile.canStartBoost(), isTrue);
      });

      test('should not allow boost during cooldown', () {
        final recentBoostProfile = testProfile.copyWith(
          isBoosted: false,
          boostExpiry: DateTime.now().subtract(const Duration(minutes: 30)),
        );
        expect(recentBoostProfile.canStartBoost(), isFalse);
      });
    });

    group('Verification System', () {
      test('should detect Instagram verification', () {
        expect(testProfile.hasInstagramVerification, isTrue);
      });

      test('should not have Instagram verification without badge', () {
        final noInstagramProfile = testProfile.copyWith(
          badges: [BadgeType.verified],
        );
        expect(noInstagramProfile.hasInstagramVerification, isFalse);
      });

      test('should check tier-1 badges', () {
        expect(BadgeType.verified.isTier1Badge, isTrue);
        expect(BadgeType.instagramVerified.isTier1Badge, isTrue);
        expect(BadgeType.workoutBuddy.isTier1Badge, isFalse);
        expect(BadgeType.newbie.isTier1Badge, isFalse);
      });
    });

    group('Security & Safety', () {
      test('should not be blocked with zero reports', () {
        expect(testProfile.isBlocked, isFalse);
      });

      test('should be blocked with high report count', () {
        final reportedProfile = testProfile.copyWith(reportCount: 5);
        expect(reportedProfile.isBlocked, isTrue);
      });

      test('should be blocked when banned', () {
        final bannedProfile = testProfile.copyWith(isBanned: true);
        expect(bannedProfile.isBlocked, isTrue);
      });

      test('should check if user has blocked another user', () {
        final profileWithBlocked = testProfile.copyWith(
          blockedUsers: ['blocked_user_1', 'blocked_user_2'],
        );
        expect(profileWithBlocked.hasBlocked('blocked_user_1'), isTrue);
        expect(profileWithBlocked.hasBlocked('other_user'), isFalse);
      });

      test('should check if user has reported another user', () {
        final profileWithReports = testProfile.copyWith(
          reportedUsers: ['reported_user_1'],
        );
        expect(profileWithReports.hasReported('reported_user_1'), isTrue);
        expect(profileWithReports.hasReported('other_user'), isFalse);
      });
    });

    group('Workout Together System', () {
      test('should calculate workout partnership strength', () {
        final strength = testProfile.workoutPartnershipStrength;
        expect(strength, greaterThan(0));
        expect(strength, lessThanOrEqualTo(100));
      });

      test('should return zero strength with no completed workouts', () {
        final noWorkoutsProfile = testProfile.copyWith(
          completedWorkoutsTogether: 0,
        );
        expect(noWorkoutsProfile.workoutPartnershipStrength, equals(0.0));
      });

      test('should handle empty workout together list', () {
        final emptyWorkoutsProfile = testProfile.copyWith(
          workoutTogetherIds: [],
          completedWorkoutsTogether: 0,
        );
        expect(emptyWorkoutsProfile.workoutPartnershipStrength, equals(0.0));
      });
    });

    group('Trust Score System', () {
      test('should calculate trust score based on verification', () {
        final trustScore = testProfile.trustScore;
        expect(trustScore, greaterThan(50)); // Base score
        expect(trustScore, lessThanOrEqualTo(100));
      });

      test('should have high trust score for verified user', () {
        final trustScore = testProfile.trustScore;
        expect(trustScore, greaterThan(80)); // Should be high due to verifications
      });

      test('should have low trust score for reported user', () {
        final reportedProfile = testProfile.copyWith(
          reportCount: 3,
          isVerified: false,
          isPhotoVerified: false,
          badges: [],
        );
        final trustScore = reportedProfile.trustScore;
        expect(trustScore, lessThan(50));
      });

      test('should have zero trust score for banned user', () {
        final bannedProfile = testProfile.copyWith(isBanned: true);
        expect(bannedProfile.trustScore, equals(0.0));
      });
    });

    group('Matchability', () {
      test('should be matchable when active and not blocked', () {
        expect(testProfile.isMatchable, isTrue);
      });

      test('should not be matchable when banned', () {
        final bannedProfile = testProfile.copyWith(isBanned: true);
        expect(bannedProfile.isMatchable, isFalse);
      });

      test('should not be matchable when inactive', () {
        final inactiveProfile = testProfile.copyWith(isActive: false);
        expect(inactiveProfile.isMatchable, isFalse);
      });

      test('should not be matchable with high report count', () {
        final reportedProfile = testProfile.copyWith(reportCount: 6);
        expect(reportedProfile.isMatchable, isFalse);
      });
    });

    group('Enhanced Compatibility', () {
      test('should consider verification in compatibility score', () {
        final otherProfile = testProfile.copyWith(
          uid: 'other_user',
          isVerified: true,
          preferences: testPreferences.copyWith(
            fitnessLevel: FitnessLevel.intermediate,
            goals: [WorkoutGoal.muscleGain],
          ),
        );

        final score = testProfile.getCompatibilityScore(otherProfile);
        expect(score, greaterThan(0));
      });

      test('should give bonus for high ratings', () {
        final highRatedProfile = testProfile.copyWith(
          uid: 'high_rated',
          averageRating: 4.8,
        );
        
        final otherHighRated = testProfile.copyWith(
          uid: 'other_high_rated',
          averageRating: 4.9,
        );

        final score = highRatedProfile.getCompatibilityScore(otherHighRated);
        expect(score, greaterThan(50)); // Should have verification + rating bonuses
      });
    });
  });

  group('MatchingPurpose', () {
    test('should have correct display names', () {
      expect(MatchingPurpose.workoutPartner.displayName, equals('Workout Partner'));
      expect(MatchingPurpose.gymBuddy.displayName, equals('Gym Buddy'));
      expect(MatchingPurpose.both.displayName, equals('Entrambi'));
      expect(MatchingPurpose.openToEverything.displayName, equals('Aperto a tutto'));
    });

    test('should have appropriate emojis', () {
      expect(MatchingPurpose.workoutPartner.emoji, equals('💪'));
      expect(MatchingPurpose.gymBuddy.emoji, equals('🤝'));
      expect(MatchingPurpose.both.emoji, equals('💪🤝'));
      expect(MatchingPurpose.openToEverything.emoji, equals('❤️'));
    });
  });
}