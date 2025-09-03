/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain/entities
 * 🎯 Feature: ads
 * 🔧 Type: entity
 * 📱 Platform: Universal
 */

/// Ad unit configuration
class AdUnitConfig {
  final String id;
  final AdType type;
  final bool isTestAd;
  final Map<String, dynamic> config;

  const AdUnitConfig({
    required this.id,
    required this.type,
    this.isTestAd = false,
    this.config = const {},
  });

  factory AdUnitConfig.banner({
    required String id,
    bool isTestAd = false,
    BannerAdSize size = BannerAdSize.standard,
  }) {
    return AdUnitConfig(
      id: id,
      type: AdType.banner,
      isTestAd: isTestAd,
      config: {'size': size},
    );
  }

  factory AdUnitConfig.interstitial({
    required String id,
    bool isTestAd = false,
  }) {
    return AdUnitConfig(
      id: id,
      type: AdType.interstitial,
      isTestAd: isTestAd,
    );
  }

  factory AdUnitConfig.native({
    required String id,
    bool isTestAd = false,
    String templateId = 'medium',
  }) {
    return AdUnitConfig(
      id: id,
      type: AdType.native,
      isTestAd: isTestAd,
      config: {'templateId': templateId},
    );
  }
}

/// Ad placement locations
enum AdPlacement {
  homeScreenBottom,
  workoutListBetween,
  analyticsScreenTop,
  exerciseSearchBottom,
  settingsBottom,
  workoutComplete,
  templateListBetween,
}

/// Banner ad sizes
enum BannerAdSize {
  standard, // 320x50
  large, // 320x100
  mediumRectangle, // 300x250
  adaptiveBanner, // Dynamic width
}

/// Ad types
enum AdType {
  banner,
  interstitial,
  native,
  rewarded,
}

/// Ad display policies based on user engagement
class AdDisplayPolicy {
  final Duration minTimeBetweenInterstitials;
  final int maxInterstitialsPerSession;
  final List<String> blockedDuringWorkout;
  final bool respectDoNotDisturb;

  const AdDisplayPolicy({
    this.minTimeBetweenInterstitials = const Duration(minutes: 3),
    this.maxInterstitialsPerSession = 5,
    this.blockedDuringWorkout = const ['interstitial'],
    this.respectDoNotDisturb = true,
  });

  /// Default policy for fitness apps
  factory AdDisplayPolicy.fitnessOptimized() {
    return const AdDisplayPolicy(
      minTimeBetweenInterstitials: Duration(minutes: 5),
      maxInterstitialsPerSession: 3,
      blockedDuringWorkout: ['interstitial'],
      respectDoNotDisturb: true,
    );
  }
}