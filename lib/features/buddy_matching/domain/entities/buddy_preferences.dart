/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: buddy_matching
/// 🔧 Type: entity
/// 🌍 Localization: N/A - Entity class
/// 🎨 Theme: N/A - Entity class
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'buddy_preferences.freezed.dart';
part 'buddy_preferences.g.dart';

/// Fitness level enum for buddy matching
enum FitnessLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  String get displayName {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Principiante';
      case FitnessLevel.intermediate:
        return 'Intermedio';
      case FitnessLevel.advanced:
        return 'Avanzato';
      case FitnessLevel.expert:
        return 'Esperto';
    }
  }
}

/// Workout goals for buddy matching
enum WorkoutGoal {
  weightLoss,
  muscleGain,
  strength,
  endurance,
  flexibility,
  general;

  String get displayName {
    switch (this) {
      case WorkoutGoal.weightLoss:
        return 'Perdita di peso';
      case WorkoutGoal.muscleGain:
        return 'Aumento massa';
      case WorkoutGoal.strength:
        return 'Forza';
      case WorkoutGoal.endurance:
        return 'Resistenza';
      case WorkoutGoal.flexibility:
        return 'Flessibilità';
      case WorkoutGoal.general:
        return 'Generale';
    }
  }
}

/// Matching purpose enum for multi-purpose matching
enum MatchingPurpose {
  workoutPartner,
  gymBuddy,
  both,
  openToEverything;

  String get displayName {
    switch (this) {
      case MatchingPurpose.workoutPartner:
        return 'Workout Partner';
      case MatchingPurpose.gymBuddy:
        return 'Gym Buddy';
      case MatchingPurpose.both:
        return 'Entrambi';
      case MatchingPurpose.openToEverything:
        return 'Aperto a tutto';
    }
  }

  String get emoji {
    switch (this) {
      case MatchingPurpose.workoutPartner:
        return '💪';
      case MatchingPurpose.gymBuddy:
        return '🤝';
      case MatchingPurpose.both:
        return '💪🤝';
      case MatchingPurpose.openToEverything:
        return '❤️';
    }
  }
}

/// Time preferences for workouts
enum PreferredTime {
  morning,   // 6-10 AM
  midday,    // 10-14 PM
  afternoon, // 14-18 PM
  evening;   // 18-22 PM

  String get displayName {
    switch (this) {
      case PreferredTime.morning:
        return 'Mattina (6-10)';
      case PreferredTime.midday:
        return 'Mezzogiorno (10-14)';
      case PreferredTime.afternoon:
        return 'Pomeriggio (14-18)';
      case PreferredTime.evening:
        return 'Sera (18-22)';
    }
  }

  String get timeRange {
    switch (this) {
      case PreferredTime.morning:
        return '6:00-10:00';
      case PreferredTime.midday:
        return '10:00-14:00';
      case PreferredTime.afternoon:
        return '14:00-18:00';
      case PreferredTime.evening:
        return '18:00-22:00';
    }
  }
}

@freezed
class BuddyPreferences with _$BuddyPreferences {
  const factory BuddyPreferences({
    @Default(false) bool isLookingForBuddy,
    @Default(25.0) double maxDistance, // km
    @Default(FitnessLevel.intermediate) FitnessLevel fitnessLevel,
    @Default([]) List<WorkoutGoal> goals,
    @Default([]) List<PreferredTime> preferredTimes,
    @Default([]) List<String> preferredDays, // ['monday', 'tuesday', etc.]
    String? instagramHandle,
    String? bio,
    @Default(18) int minAge,
    @Default(65) int maxAge,
    @Default(true) bool allowMessages,
    @Default(true) bool showOnMap,
    // Enhanced location system
    double? latitude,
    double? longitude,
    String? locationName,
    String? cityName,
    String? cityCode, // For Italian cities system
    String? zoneName, // For city zones/districts
    DateTime? lastLocationUpdate,
    // Multi-purpose matching
    @Default(MatchingPurpose.workoutPartner) MatchingPurpose matchingPurpose,
    @Default(false) bool openToDating, // Romance flag
    @Default(true) bool openToFriendship, // Friendship flag
    // Matching preferences
    @Default(true) bool matchSameFitnessLevel,
    @Default(true) bool matchSameGoals,
    @Default(false) bool matchOnlyVerified,
    // Tier-1 preferences
    @Default(false) bool requireVerification,
    @Default(true) bool allowSuperLikes,
    @Default(true) bool allowBoosts,
  }) = _BuddyPreferences;

  factory BuddyPreferences.fromJson(Map<String, dynamic> json) =>
      _$BuddyPreferencesFromJson(json);

  /// Create default preferences for new user
  factory BuddyPreferences.defaultPreferences() => const BuddyPreferences();

  /// Create from Firestore document
  factory BuddyPreferences.fromFirestore(Map<String, dynamic> data) {
    return BuddyPreferences(
      isLookingForBuddy: data['isLookingForBuddy'] ?? false,
      maxDistance: (data['maxDistance'] ?? 25.0).toDouble(),
      fitnessLevel: FitnessLevel.values.firstWhere(
        (level) => level.name == (data['fitnessLevel'] ?? 'intermediate'),
        orElse: () => FitnessLevel.intermediate,
      ),
      goals: (data['goals'] as List<dynamic>?)
          ?.map((goal) => WorkoutGoal.values.firstWhere(
                (g) => g.name == goal,
                orElse: () => WorkoutGoal.general,
              ))
          .toList() ?? [],
      preferredTimes: (data['preferredTimes'] as List<dynamic>?)
          ?.map((time) => PreferredTime.values.firstWhere(
                (t) => t.name == time,
                orElse: () => PreferredTime.evening,
              ))
          .toList() ?? [],
      preferredDays: (data['preferredDays'] as List<dynamic>?)
          ?.map((day) => day.toString())
          .toList() ?? [],
      instagramHandle: data['instagramHandle'] as String?,
      bio: data['bio'] as String?,
      minAge: data['minAge'] ?? 18,
      maxAge: data['maxAge'] ?? 65,
      allowMessages: data['allowMessages'] ?? true,
      showOnMap: data['showOnMap'] ?? true,
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      locationName: data['locationName'] as String?,
      lastLocationUpdate: data['lastLocationUpdate'] != null 
          ? (data['lastLocationUpdate'] as Timestamp).toDate() 
          : null,
      cityName: data['cityName'] as String?,
      cityCode: data['cityCode'] as String?,
      zoneName: data['zoneName'] as String?,
      matchingPurpose: MatchingPurpose.values.firstWhere(
        (purpose) => purpose.name == (data['matchingPurpose'] ?? 'workoutPartner'),
        orElse: () => MatchingPurpose.workoutPartner,
      ),
      openToDating: data['openToDating'] ?? false,
      openToFriendship: data['openToFriendship'] ?? true,
      matchSameFitnessLevel: data['matchSameFitnessLevel'] ?? true,
      matchSameGoals: data['matchSameGoals'] ?? true,
      matchOnlyVerified: data['matchOnlyVerified'] ?? false,
      requireVerification: data['requireVerification'] ?? false,
      allowSuperLikes: data['allowSuperLikes'] ?? true,
      allowBoosts: data['allowBoosts'] ?? true,
    );
  }
}

extension BuddyPreferencesX on BuddyPreferences {
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'isLookingForBuddy': isLookingForBuddy,
      'maxDistance': maxDistance,
      'fitnessLevel': fitnessLevel.name,
      'goals': goals.map((goal) => goal.name).toList(),
      'preferredTimes': preferredTimes.map((time) => time.name).toList(),
      'preferredDays': preferredDays,
      'instagramHandle': instagramHandle,
      'bio': bio,
      'minAge': minAge,
      'maxAge': maxAge,
      'allowMessages': allowMessages,
      'showOnMap': showOnMap,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'lastLocationUpdate': lastLocationUpdate != null 
          ? Timestamp.fromDate(lastLocationUpdate!) 
          : null,
      'cityName': cityName,
      'cityCode': cityCode,
      'zoneName': zoneName,
      'matchingPurpose': matchingPurpose.name,
      'openToDating': openToDating,
      'openToFriendship': openToFriendship,
      'matchSameFitnessLevel': matchSameFitnessLevel,
      'matchSameGoals': matchSameGoals,
      'matchOnlyVerified': matchOnlyVerified,
      'requireVerification': requireVerification,
      'allowSuperLikes': allowSuperLikes,
      'allowBoosts': allowBoosts,
    };
  }

  /// Check if user has valid location data
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if location is recent (within 24 hours)
  bool get hasRecentLocation {
    if (lastLocationUpdate == null) return false;
    return DateTime.now().difference(lastLocationUpdate!).inHours < 24;
  }

  /// Get compatibility score with another user's preferences (0-100)
  double getCompatibilityScore(BuddyPreferences other) {
    double score = 0.0;
    int factors = 0;

    // Fitness level compatibility (30% weight)
    if (matchSameFitnessLevel) {
      if (fitnessLevel == other.fitnessLevel) {
        score += 30.0;
      } else if ((fitnessLevel.index - other.fitnessLevel.index).abs() <= 1) {
        score += 15.0; // Adjacent levels get partial score
      }
    } else {
      score += 20.0; // Neutral score if level doesn't matter
    }
    factors += 30;

    // Goals compatibility (25% weight)
    if (goals.isNotEmpty && other.goals.isNotEmpty) {
      final commonGoals = goals.where((goal) => other.goals.contains(goal)).length;
      final totalGoals = (goals.length + other.goals.length) / 2;
      score += (commonGoals / totalGoals) * 25.0;
    } else {
      score += 12.5; // Neutral if no goals set
    }
    factors += 25;

    // Time preferences compatibility (20% weight)
    if (preferredTimes.isNotEmpty && other.preferredTimes.isNotEmpty) {
      final commonTimes = preferredTimes.where((time) => other.preferredTimes.contains(time)).length;
      final totalTimes = (preferredTimes.length + other.preferredTimes.length) / 2;
      score += (commonTimes / totalTimes) * 20.0;
    } else {
      score += 10.0; // Neutral if no times set
    }
    factors += 20;

    // Day preferences compatibility (15% weight)
    if (preferredDays.isNotEmpty && other.preferredDays.isNotEmpty) {
      final commonDays = preferredDays.where((day) => other.preferredDays.contains(day)).length;
      final totalDays = (preferredDays.length + other.preferredDays.length) / 2;
      score += (commonDays / totalDays) * 15.0;
    } else {
      score += 7.5; // Neutral if no days set
    }
    factors += 15;

    // Bio/Instagram presence (10% weight)
    int bioScore = 0;
    if (bio != null && bio!.isNotEmpty) bioScore += 5;
    if (instagramHandle != null && instagramHandle!.isNotEmpty) bioScore += 5;
    if (other.bio != null && other.bio!.isNotEmpty) bioScore += 5;
    if (other.instagramHandle != null && other.instagramHandle!.isNotEmpty) bioScore += 5;
    score += (bioScore / 20.0) * 10.0;
    factors += 10;

    return (score / factors) * 100;
  }

  /// Check if this user would be interested in another user
  bool wouldMatch(BuddyPreferences other, {double minScore = 60.0}) {
    return getCompatibilityScore(other) >= minScore;
  }
}