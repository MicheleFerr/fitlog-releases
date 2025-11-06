/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data
/// 🎯 Feature: buddy_matching
/// 🔧 Type: demo_data
/// 🌍 Localization: N/A - Demo data
/// 🎨 Theme: N/A - Demo data  
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Domain entities
library;

import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/matching_purpose.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/italian_city.dart';

/// Demo profiles for development and testing
class DemoProfiles {
  static List<BuddyProfile> get allProfiles => [
    _createMarcoBuddyProfile(),
    _createGiuliaBuddyProfile(), 
    _createAndreaBuddyProfile(),
    _createChiaraBuddyProfile(),
    _createLucaBuddyProfile(),
    _createFrancescaBuddyProfile(),
    _createStefanoBuddyProfile(),
    _createValetiaBuddyProfile(),
    _createMatteoProfile(),
    _createSaraBuddyProfile(),
  ];

  static BuddyProfile _createMarcoBuddyProfile() {
    final milanCity = ItalianCities.findByCode('MI')!;
    return BuddyProfile(
      uid: 'demo_marco_123',
      displayName: 'Marco Rossi',
      photoURL: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 15.0,
        fitnessLevel: FitnessLevel.intermediate,
        goals: [WorkoutGoal.muscleGain, WorkoutGoal.strength],
        preferredTimes: [PreferredTime.evening],
        preferredDays: ['monday', 'wednesday', 'friday'],
        instagramHandle: '@marco_fitness_journey',
        bio: 'Appassionato di powerlifting da 3 anni. Cerco qualcuno con cui condividere la passione per i pesi e motivarci a vicenda! 💪',
        minAge: 22,
        maxAge: 35,
        latitude: milanCity.latitude,
        longitude: milanCity.longitude,
        locationName: 'Milano Centro',
        cityName: milanCity.name,
        cityCode: milanCity.code,
        zoneName: 'Centro Storico',
        matchingPurpose: MatchingPurpose.workoutPartner,
        openToDating: false,
        openToFriendship: true,
        lastLocationUpdate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      badges: [BadgeType.workoutBuddy, BadgeType.instagramVerified],
      partnershipsCount: 2,
      successfulPartnerships: 2,
      averageRating: 4.8,
      totalRatings: 12,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
      isActive: true,
      isVerified: true,
      totalWorkouts: 156,
      totalVolume: 45000.0,
      isPhotoVerified: true,
      superLikesRemaining: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    );
  }

  static BuddyProfile _createGiuliaBuddyProfile() {
    final romeCity = ItalianCities.findByCode('RM')!;
    return BuddyProfile(
      uid: 'demo_giulia_456',
      displayName: 'Giulia Bianchi',
      photoURL: 'https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 20.0,
        fitnessLevel: FitnessLevel.beginner,
        goals: [WorkoutGoal.weightLoss, WorkoutGoal.general],
        preferredTimes: [PreferredTime.morning, PreferredTime.afternoon],
        preferredDays: ['tuesday', 'thursday', 'saturday'],
        instagramHandle: '@giulia_healthy_life',
        bio: 'Nuova nel mondo del fitness! Cerco una persona paziente che mi aiuti a iniziare questo percorso. Sono molto motivata! 🌟',
        minAge: 20,
        maxAge: 30,
        latitude: romeCity.latitude,
        longitude: romeCity.longitude,
        locationName: 'Roma Trastevere',
        cityName: romeCity.name,
        cityCode: romeCity.code,
        zoneName: 'Trastevere',
        matchingPurpose: MatchingPurpose.gymBuddy,
        openToDating: false,
        openToFriendship: true,
        lastLocationUpdate: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      badges: [BadgeType.newbie, BadgeType.instagramVerified],
      partnershipsCount: 0,
      successfulPartnerships: 0,
      averageRating: 0.0,
      totalRatings: 0,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
      isActive: true,
      isVerified: false,
      totalWorkouts: 12,
      totalVolume: 2400.0,
      superLikesRemaining: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    );
  }

  static BuddyProfile _createAndreaBuddyProfile() {
    final napoliCity = ItalianCities.findByCode('NA')!;
    return BuddyProfile(
      uid: 'demo_andrea_789',
      displayName: 'Andrea Esposito',
      photoURL: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 25.0,
        fitnessLevel: FitnessLevel.advanced,
        goals: [WorkoutGoal.strength, WorkoutGoal.endurance],
        preferredTimes: [PreferredTime.morning],
        preferredDays: ['monday', 'tuesday', 'wednesday', 'friday'],
        instagramHandle: '@andrea_crossfit_warrior',
        bio: 'CrossFit athlete da 5 anni. Mi alleno alle 6 del mattino e cerco qualcuno che condivida la mia dedizione! ⚡',
        minAge: 25,
        maxAge: 40,
        latitude: napoliCity.latitude,
        longitude: napoliCity.longitude,
        locationName: 'Napoli Vomero',
        cityName: napoliCity.name,
        cityCode: napoliCity.code,
        zoneName: 'Vomero',
        matchingPurpose: MatchingPurpose.workoutPartner,
        openToDating: false,
        openToFriendship: true,
        lastLocationUpdate: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      badges: [BadgeType.veteran, BadgeType.motivator, BadgeType.verified, BadgeType.instagramVerified],
      partnershipsCount: 8,
      successfulPartnerships: 7,
      averageRating: 4.9,
      totalRatings: 28,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
      isActive: true,
      isVerified: true,
      totalWorkouts: 890,
      totalVolume: 167000.0,
      isPhotoVerified: true,
      superLikesRemaining: 1,
      completedWorkoutsTogether: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    );
  }

  static BuddyProfile _createChiaraBuddyProfile() {
    final torinoCity = ItalianCities.findByCode('TO')!;
    return BuddyProfile(
      uid: 'demo_chiara_101',
      displayName: 'Chiara Romano',
      photoURL: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 12.0,
        fitnessLevel: FitnessLevel.intermediate,
        goals: [WorkoutGoal.flexibility, WorkoutGoal.endurance],
        preferredTimes: [PreferredTime.afternoon, PreferredTime.evening],
        preferredDays: ['monday', 'wednesday', 'friday', 'sunday'],
        bio: 'Yoga instructor e runner. Amo variare molto gli allenamenti e scoprire nuove attività! Cerco qualcuno con cui esplorare. 🧘‍♀️',
        minAge: 23,
        maxAge: 35,
        latitude: torinoCity.latitude,
        longitude: torinoCity.longitude,
        locationName: 'Torino San Salvario',
        cityName: torinoCity.name,
        cityCode: torinoCity.code,
        zoneName: 'San Salvario',
        matchingPurpose: MatchingPurpose.both,
        openToDating: true,
        openToFriendship: true,
        lastLocationUpdate: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      badges: [BadgeType.motivator, BadgeType.consistentPartner],
      partnershipsCount: 3,
      successfulPartnerships: 3,
      averageRating: 4.7,
      totalRatings: 15,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 45)),
      isActive: true,
      isVerified: false,
      totalWorkouts: 234,
      totalVolume: 28000.0,
      superLikesRemaining: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 67)),
    );
  }

  static BuddyProfile _createLucaBuddyProfile() {
    final bolognaCity = ItalianCities.findByCode('BO')!;
    return BuddyProfile(
      uid: 'demo_luca_202',
      displayName: 'Luca Ferrari',
      photoURL: 'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 30.0,
        fitnessLevel: FitnessLevel.expert,
        goals: [WorkoutGoal.strength, WorkoutGoal.muscleGain],
        preferredTimes: [PreferredTime.evening],
        preferredDays: ['monday', 'tuesday', 'thursday', 'friday', 'saturday'],
        instagramHandle: '@luca_bodybuilding_pro',
        bio: 'Bodybuilder competitive da 8 anni. Preparazione gare e allenamenti intensi. Cerco qualcuno serio e determinato! 🏆',
        minAge: 28,
        maxAge: 45,
        latitude: bolognaCity.latitude,
        longitude: bolognaCity.longitude,
        locationName: 'Bologna Centro',
        cityName: bolognaCity.name,
        cityCode: bolognaCity.code,
        zoneName: 'Centro Storico',
        matchingPurpose: MatchingPurpose.workoutPartner,
        openToDating: false,
        openToFriendship: true,
        matchOnlyVerified: true,
        lastLocationUpdate: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      badges: [BadgeType.veteran, BadgeType.verified, BadgeType.instagramVerified, BadgeType.earlyAdopter],
      partnershipsCount: 15,
      successfulPartnerships: 13,
      averageRating: 4.8,
      totalRatings: 45,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
      isActive: true,
      isVerified: true,
      totalWorkouts: 1250,
      totalVolume: 345000.0,
      isPhotoVerified: true,
      superLikesRemaining: 0,
      completedWorkoutsTogether: 156,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    );
  }

  static BuddyProfile _createFrancescaBuddyProfile() {
    final firenzeCity = ItalianCities.findByCode('FI')!;
    return BuddyProfile(
      uid: 'demo_francesca_303',
      displayName: 'Francesca Conti',
      photoURL: 'https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 18.0,
        fitnessLevel: FitnessLevel.intermediate,
        goals: [WorkoutGoal.endurance, WorkoutGoal.general],
        preferredTimes: [PreferredTime.morning, PreferredTime.midday],
        preferredDays: ['wednesday', 'friday', 'saturday', 'sunday'],
        bio: 'Trail running e hiking enthusiast! Amo gli allenamenti outdoor e cerco qualcuno con cui esplorare nuovi percorsi. 🏃‍♀️',
        minAge: 25,
        maxAge: 38,
        latitude: firenzeCity.latitude,
        longitude: firenzeCity.longitude,
        locationName: 'Firenze Oltrarno',
        cityName: firenzeCity.name,
        cityCode: firenzeCity.code,
        zoneName: 'Oltrarno',
        matchingPurpose: MatchingPurpose.openToEverything,
        openToDating: true,
        openToFriendship: true,
        lastLocationUpdate: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      badges: [BadgeType.consistentPartner, BadgeType.motivator],
      partnershipsCount: 4,
      successfulPartnerships: 4,
      averageRating: 4.9,
      totalRatings: 22,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 25)),
      isActive: true,
      isVerified: false,
      totalWorkouts: 298,
      totalVolume: 42000.0,
      superLikesRemaining: 2,
      completedWorkoutsTogether: 38,
      createdAt: DateTime.now().subtract(const Duration(days: 89)),
    );
  }

  static BuddyProfile _createStefanoBuddyProfile() {
    final genovaCity = ItalianCities.findByCode('GE')!;
    return BuddyProfile(
      uid: 'demo_stefano_404',
      displayName: 'Stefano Lombardi',
      photoURL: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 22.0,
        fitnessLevel: FitnessLevel.beginner,
        goals: [WorkoutGoal.weightLoss, WorkoutGoal.endurance],
        preferredTimes: [PreferredTime.evening],
        preferredDays: ['monday', 'wednesday', 'friday'],
        instagramHandle: '@stefano_new_beginning',
        bio: 'Ho appena iniziato il mio percorso fitness dopo anni di sedentarietà. Cerco qualcuno paziente che mi aiuti! 💚',
        minAge: 30,
        maxAge: 45,
        latitude: genovaCity.latitude,
        longitude: genovaCity.longitude,
        locationName: 'Genova Castelletto',
        cityName: genovaCity.name,
        cityCode: genovaCity.code,
        zoneName: 'Castelletto',
        matchingPurpose: MatchingPurpose.gymBuddy,
        openToDating: false,
        openToFriendship: true,
        lastLocationUpdate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      badges: [BadgeType.newbie],
      partnershipsCount: 0,
      successfulPartnerships: 0,
      averageRating: 0.0,
      totalRatings: 0,
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
      isVerified: false,
      totalWorkouts: 8,
      totalVolume: 1200.0,
      superLikesRemaining: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    );
  }

  static BuddyProfile _createValetiaBuddyProfile() {
    final bariCity = ItalianCities.findByCode('BA')!;
    return BuddyProfile(
      uid: 'demo_valeria_505',
      displayName: 'Valeria Greco',
      photoURL: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 16.0,
        fitnessLevel: FitnessLevel.advanced,
        goals: [WorkoutGoal.muscleGain, WorkoutGoal.strength],
        preferredTimes: [PreferredTime.morning, PreferredTime.afternoon],
        preferredDays: ['tuesday', 'thursday', 'saturday', 'sunday'],
        instagramHandle: '@valeria_strong_woman',
        bio: 'Powerlifter appassionata! Records: Squat 140kg, Bench 85kg, Deadlift 160kg. Cerco qualcuno che ami i pesi quanto me! 💪',
        minAge: 26,
        maxAge: 40,
        latitude: bariCity.latitude,
        longitude: bariCity.longitude,
        locationName: 'Bari Murat',
        cityName: bariCity.name,
        cityCode: bariCity.code,
        zoneName: 'Murat',
        matchingPurpose: MatchingPurpose.both,
        openToDating: true,
        openToFriendship: true,
        lastLocationUpdate: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      badges: [BadgeType.veteran, BadgeType.motivator, BadgeType.verified, BadgeType.superLiker],
      partnershipsCount: 6,
      successfulPartnerships: 5,
      averageRating: 4.8,
      totalRatings: 31,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 8)),
      isActive: true,
      isVerified: true,
      totalWorkouts: 567,
      totalVolume: 89000.0,
      isPhotoVerified: true,
      superLikesRemaining: 1,
      completedWorkoutsTogether: 67,
      createdAt: DateTime.now().subtract(const Duration(days: 156)),
    );
  }

  static BuddyProfile _createMatteoProfile() {
    final cataniaCity = ItalianCities.findByCode('CT')!;
    return BuddyProfile(
      uid: 'demo_matteo_606',
      displayName: 'Matteo Ricci',
      photoURL: 'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 35.0,
        fitnessLevel: FitnessLevel.intermediate,
        goals: [WorkoutGoal.general, WorkoutGoal.endurance],
        preferredTimes: [PreferredTime.evening],
        preferredDays: ['monday', 'wednesday', 'friday', 'saturday'],
        bio: 'Functional training e calisthenics! Amo allenamenti vari e dinamici. Cerco qualcuno con cui sperimentare nuovi workout! 🤸‍♂️',
        minAge: 22,
        maxAge: 32,
        latitude: cataniaCity.latitude,
        longitude: cataniaCity.longitude,
        locationName: 'Catania Centro',
        cityName: cataniaCity.name,
        cityCode: cataniaCity.code,
        zoneName: 'Centro Storico',
        matchingPurpose: MatchingPurpose.workoutPartner,
        openToDating: false,
        openToFriendship: true,
        lastLocationUpdate: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      badges: [BadgeType.workoutBuddy, BadgeType.consistentPartner],
      partnershipsCount: 2,
      successfulPartnerships: 2,
      averageRating: 4.6,
      totalRatings: 8,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 12)),
      isActive: true,
      isVerified: false,
      totalWorkouts: 123,
      totalVolume: 18500.0,
      superLikesRemaining: 2,
      completedWorkoutsTogether: 24,
      createdAt: DateTime.now().subtract(const Duration(days: 34)),
    );
  }

  static BuddyProfile _createSaraBuddyProfile() {
    final palermoCity = ItalianCities.findByCode('PA')!;
    return BuddyProfile(
      uid: 'demo_sara_707',
      displayName: 'Sara Marino',
      photoURL: 'https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=400',
      preferences: BuddyPreferences(
        isLookingForBuddy: true,
        maxDistance: 28.0,
        fitnessLevel: FitnessLevel.expert,
        goals: [WorkoutGoal.flexibility, WorkoutGoal.endurance],
        preferredTimes: [PreferredTime.morning],
        preferredDays: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
        instagramHandle: '@sara_pilates_master',
        bio: 'Pilates instructor certificata e personal trainer. Specializzata in riabilitazione e movimento funzionale. 🧘‍♀️',
        minAge: 28,
        maxAge: 42,
        latitude: palermoCity.latitude,
        longitude: palermoCity.longitude,
        locationName: 'Palermo Kalsa',
        cityName: palermoCity.name,
        cityCode: palermoCity.code,
        zoneName: 'Kalsa',
        matchingPurpose: MatchingPurpose.gymBuddy,
        openToDating: false,
        openToFriendship: true,
        matchOnlyVerified: false,
        lastLocationUpdate: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      badges: [BadgeType.veteran, BadgeType.motivator, BadgeType.verified, BadgeType.instagramVerified, BadgeType.earlyAdopter],
      partnershipsCount: 12,
      successfulPartnerships: 11,
      averageRating: 4.9,
      totalRatings: 67,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 3)),
      isActive: true,
      isVerified: true,
      totalWorkouts: 945,
      totalVolume: 78000.0,
      isPhotoVerified: true,
      superLikesRemaining: 2,
      completedWorkoutsTogether: 123,
      createdAt: DateTime.now().subtract(const Duration(days: 278)),
    );
  }

  /// Get profiles by city
  static List<BuddyProfile> getProfilesByCity(String cityCode) {
    return allProfiles
        .where((profile) => profile.preferences.cityCode == cityCode)
        .toList();
  }

  /// Get profiles by fitness level
  static List<BuddyProfile> getProfilesByFitnessLevel(FitnessLevel level) {
    return allProfiles
        .where((profile) => profile.preferences.fitnessLevel == level)
        .toList();
  }

  /// Get verified profiles only
  static List<BuddyProfile> get verifiedProfiles {
    return allProfiles.where((profile) => profile.isVerified).toList();
  }

  /// Get profiles looking for specific purpose
  static List<BuddyProfile> getProfilesByPurpose(MatchingPurpose purpose) {
    return allProfiles
        .where((profile) =>
            profile.preferences.matchingPurpose == purpose ||
            profile.preferences.matchingPurpose == MatchingPurpose.both ||
            profile.preferences.matchingPurpose == MatchingPurpose.openToEverything)
        .toList();
  }

  /// Get random subset of profiles for testing
  static List<BuddyProfile> getRandomProfiles({int count = 5}) {
    final shuffled = List<BuddyProfile>.from(allProfiles);
    shuffled.shuffle();
    return shuffled.take(count).toList();
  }
}