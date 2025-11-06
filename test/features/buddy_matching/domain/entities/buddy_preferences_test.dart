/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test
/// 🎯 Feature: buddy_matching
/// 🔧 Type: unit test
/// 🌍 Localization: N/A - Test file
/// 🎨 Theme: N/A - Test file
/// 📱 Platform: Universal
///
/// Comprehensive tests for BuddyPreferences compatibility algorithm
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/matching_purpose.dart';

void main() {
  group('BuddyPreferences - Compatibility Algorithm Tests', () {
    late BuddyPreferences testPreferences;

    setUp(() {
      testPreferences = const BuddyPreferences(
        isLookingForBuddy: true,
        fitnessLevel: FitnessLevel.intermediate,
        goals: [WorkoutGoal.muscleGain, WorkoutGoal.strength],
        preferredTimes: [PreferredTime.evening, PreferredTime.afternoon],
        preferredDays: ['monday', 'wednesday', 'friday'],
        maxDistance: 10.0,
        minAge: 20,
        maxAge: 40,
      );
    });

    group('Fitness Level Compatibility', () {
      test('perfect match - same fitness level gives high score', () {
        final other = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.intermediate,
        );

        final score = testPreferences.getCompatibilityScore(other);
        expect(score, greaterThanOrEqualTo(60.0));
      });

      test('adjacent fitness levels get partial score', () {
        final advanced = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.advanced,
        );

        final score = testPreferences.getCompatibilityScore(advanced);
        expect(score, greaterThan(40.0));
        expect(score, lessThan(100.0));
      });

      test('distant fitness levels get lower score than perfect match', () {
        final beginner = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.beginner,
        );
        final expert = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.expert,
        );
        final perfectMatch = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.intermediate,
        );

        final beginnerScore = testPreferences.getCompatibilityScore(beginner);
        final expertScore = testPreferences.getCompatibilityScore(expert);
        final perfectScore = testPreferences.getCompatibilityScore(perfectMatch);

        expect(beginnerScore, lessThan(perfectScore));
        expect(expertScore, lessThan(perfectScore));
      });

      test('matchSameFitnessLevel=false provides neutral score', () {
        final noLevelReq = testPreferences.copyWith(
          matchSameFitnessLevel: false,
          fitnessLevel: FitnessLevel.beginner,
        );

        final score = testPreferences.getCompatibilityScore(noLevelReq);
        expect(score, greaterThan(0));
      });
    });

    group('Goals Compatibility', () {
      test('identical goals give maximum goal score', () {
        final sameGoals = testPreferences.copyWith(
          goals: [WorkoutGoal.muscleGain, WorkoutGoal.strength],
        );

        final score = testPreferences.getCompatibilityScore(sameGoals);
        expect(score, greaterThan(60.0));
      });

      test('overlapping goals give proportional score', () {
        final partialOverlap = testPreferences.copyWith(
          goals: [WorkoutGoal.muscleGain, WorkoutGoal.endurance],
        );

        final score = testPreferences.getCompatibilityScore(partialOverlap);
        expect(score, greaterThan(40.0));
      });

      test('no overlapping goals give lower score', () {
        final noOverlap = testPreferences.copyWith(
          goals: [WorkoutGoal.flexibility, WorkoutGoal.endurance],
        );

        final score = testPreferences.getCompatibilityScore(noOverlap);
        expect(score, lessThan(70.0));
      });

      test('empty goals list handled gracefully', () {
        final noGoals = testPreferences.copyWith(goals: []);

        final score = testPreferences.getCompatibilityScore(noGoals);
        expect(score, greaterThan(0)); // Should still have neutral score
      });
    });

    group('Time Preferences Compatibility', () {
      test('matching preferred times increase score', () {
        final sameTimes = testPreferences.copyWith(
          preferredTimes: [PreferredTime.evening, PreferredTime.afternoon],
        );

        final score = testPreferences.getCompatibilityScore(sameTimes);
        expect(score, greaterThan(60.0));
      });

      test('partially matching times give proportional score', () {
        final partialTimes = testPreferences.copyWith(
          preferredTimes: [PreferredTime.evening, PreferredTime.morning],
        );

        final score = testPreferences.getCompatibilityScore(partialTimes);
        expect(score, greaterThan(40.0));
      });

      test('no matching times reduce score', () {
        final noMatchTimes = testPreferences.copyWith(
          preferredTimes: [PreferredTime.morning, PreferredTime.midday],
        );

        final score = testPreferences.getCompatibilityScore(noMatchTimes);
        expect(score, lessThan(80.0));
      });
    });

    group('Day Preferences Compatibility', () {
      test('matching days increase score', () {
        final sameDays = testPreferences.copyWith(
          preferredDays: ['monday', 'wednesday', 'friday'],
        );

        final score = testPreferences.getCompatibilityScore(sameDays);
        expect(score, greaterThan(60.0));
      });

      test('partially matching days give proportional score', () {
        final partialDays = testPreferences.copyWith(
          preferredDays: ['monday', 'tuesday', 'thursday'],
        );

        final score = testPreferences.getCompatibilityScore(partialDays);
        expect(score, greaterThan(40.0));
      });
    });

    group('Bio and Instagram Presence', () {
      test('both users with bio and instagram get bonus', () {
        final withBio = testPreferences.copyWith(
          bio: 'Passionate about fitness!',
          instagramHandle: '@fitness_lover',
        );
        final other = testPreferences.copyWith(
          bio: 'Love working out',
          instagramHandle: '@gym_buddy',
        );

        final score = withBio.getCompatibilityScore(other);
        expect(score, greaterThan(60.0));
      });

      test('missing bio and instagram reduces bonus', () {
        final noBio = testPreferences.copyWith(
          bio: null,
          instagramHandle: null,
        );
        final other = testPreferences.copyWith(
          bio: null,
          instagramHandle: null,
        );

        final scoreWithBio = testPreferences.copyWith(
          bio: 'Test',
          instagramHandle: '@test',
        ).getCompatibilityScore(testPreferences.copyWith(
          bio: 'Test',
          instagramHandle: '@test',
        ));

        final scoreNoBio = noBio.getCompatibilityScore(other);

        expect(scoreWithBio, greaterThan(scoreNoBio));
      });
    });

    group('Overall Compatibility Score', () {
      test('score is always between 0 and 100', () {
        final other = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.expert,
          goals: [WorkoutGoal.flexibility],
          preferredTimes: [PreferredTime.morning],
          preferredDays: ['saturday', 'sunday'],
        );

        final score = testPreferences.getCompatibilityScore(other);
        expect(score, greaterThanOrEqualTo(0.0));
        expect(score, lessThanOrEqualTo(100.0));
      });

      test('perfect match gives high score (80%+)', () {
        final perfectMatch = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.intermediate,
          goals: [WorkoutGoal.muscleGain, WorkoutGoal.strength],
          preferredTimes: [PreferredTime.evening, PreferredTime.afternoon],
          preferredDays: ['monday', 'wednesday', 'friday'],
          bio: 'Fitness enthusiast',
          instagramHandle: '@fitness',
        );

        final score = testPreferences.getCompatibilityScore(perfectMatch);
        expect(score, greaterThanOrEqualTo(80.0));
      });

      test('completely mismatched gives low score', () {
        final mismatch = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.beginner,
          goals: [WorkoutGoal.flexibility],
          preferredTimes: [PreferredTime.morning],
          preferredDays: ['saturday', 'sunday'],
          bio: null,
          instagramHandle: null,
        );

        final score = testPreferences.getCompatibilityScore(mismatch);
        expect(score, lessThan(50.0));
      });
    });

    group('wouldMatch Helper', () {
      test('returns true for high compatibility', () {
        final goodMatch = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.intermediate,
          goals: [WorkoutGoal.muscleGain],
          preferredTimes: [PreferredTime.evening],
        );

        expect(testPreferences.wouldMatch(goodMatch, minScore: 60.0), isTrue);
      });

      test('returns false for low compatibility', () {
        final poorMatch = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.beginner,
          goals: [WorkoutGoal.flexibility],
          preferredTimes: [PreferredTime.morning],
        );

        expect(testPreferences.wouldMatch(poorMatch, minScore: 80.0), isFalse);
      });

      test('respects custom minScore threshold', () {
        final mediumMatch = testPreferences.copyWith(
          fitnessLevel: FitnessLevel.advanced,
          goals: [WorkoutGoal.strength],
        );

        expect(testPreferences.wouldMatch(mediumMatch, minScore: 40.0), isTrue);
        expect(testPreferences.wouldMatch(mediumMatch, minScore: 90.0), isFalse);
      });
    });

    group('Location Helpers', () {
      test('hasLocation returns true when coordinates set', () {
        final withLocation = testPreferences.copyWith(
          latitude: 45.4642,
          longitude: 9.1900,
        );

        expect(withLocation.hasLocation, isTrue);
      });

      test('hasLocation returns false when coordinates missing', () {
        expect(testPreferences.hasLocation, isFalse);
      });

      test('hasRecentLocation checks 24h window', () {
        final recentLocation = testPreferences.copyWith(
          lastLocationUpdate: DateTime.now().subtract(const Duration(hours: 12)),
          latitude: 45.0,
          longitude: 9.0,
        );

        expect(recentLocation.hasRecentLocation, isTrue);
      });

      test('hasRecentLocation returns false for old location', () {
        final oldLocation = testPreferences.copyWith(
          lastLocationUpdate: DateTime.now().subtract(const Duration(days: 2)),
          latitude: 45.0,
          longitude: 9.0,
        );

        expect(oldLocation.hasRecentLocation, isFalse);
      });
    });

    group('Enum Display Names', () {
      test('FitnessLevel display names', () {
        expect(FitnessLevel.beginner.displayName, equals('Principiante'));
        expect(FitnessLevel.intermediate.displayName, equals('Intermedio'));
        expect(FitnessLevel.advanced.displayName, equals('Avanzato'));
        expect(FitnessLevel.expert.displayName, equals('Esperto'));
      });

      test('WorkoutGoal display names', () {
        expect(WorkoutGoal.weightLoss.displayName, equals('Perdita di peso'));
        expect(WorkoutGoal.muscleGain.displayName, equals('Aumento massa'));
        expect(WorkoutGoal.strength.displayName, equals('Forza'));
        expect(WorkoutGoal.endurance.displayName, equals('Resistenza'));
        expect(WorkoutGoal.flexibility.displayName, equals('Flessibilità'));
        expect(WorkoutGoal.general.displayName, equals('Generale'));
      });

      test('PreferredTime display names', () {
        expect(PreferredTime.morning.displayName, equals('Mattina (6-10)'));
        expect(PreferredTime.midday.displayName, equals('Mezzogiorno (10-14)'));
        expect(PreferredTime.afternoon.displayName, equals('Pomeriggio (14-18)'));
        expect(PreferredTime.evening.displayName, equals('Sera (18-22)'));
      });
    });
  });
}
