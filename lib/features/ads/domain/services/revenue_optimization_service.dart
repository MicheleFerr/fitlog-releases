/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain/services
 * 🎯 Feature: ads
 * 🔧 Type: service (revenue optimization)
 * 📱 Platform: Universal
 */

/// Revenue optimization and projection service
class RevenueOptimizationService {
  
  /// Ad revenue projections based on fitness app benchmarks
  static const Map<String, double> _adRevenueBenchmarks = {
    // RPM (Revenue per Mille) values for fitness apps
    'banner_rpm_low': 0.50,      // €0.50 per 1000 banner impressions (conservative)
    'banner_rpm_avg': 1.20,      // €1.20 per 1000 banner impressions (average)
    'banner_rpm_high': 2.50,     // €2.50 per 1000 banner impressions (optimized)
    
    'interstitial_rpm_low': 2.00,   // €2.00 per 1000 interstitial impressions
    'interstitial_rpm_avg': 5.50,   // €5.50 per 1000 interstitial impressions
    'interstitial_rpm_high': 12.00, // €12.00 per 1000 interstitial impressions
    
    'native_rpm_low': 1.00,      // €1.00 per 1000 native impressions
    'native_rpm_avg': 2.80,      // €2.80 per 1000 native impressions
    'native_rpm_high': 6.00,     // €6.00 per 1000 native impressions
  };

  /// Premium conversion benchmarks for fitness apps
  static const Map<String, double> _conversionBenchmarks = {
    'trial_to_paid_rate': 0.15,     // 15% trial to paid conversion
    'freemium_to_paid_rate': 0.03,  // 3% freemium to paid conversion
    'retention_month_1': 0.70,      // 70% first month retention
    'retention_month_3': 0.45,      // 45% three month retention
    'retention_month_12': 0.25,     // 25% twelve month retention
  };

  /// Calculate monthly revenue projections
  static RevenueProjection calculateMonthlyRevenue({
    required int dailyActiveUsers,
    required double premiumConversionRate,
    required AdMetrics adMetrics,
    required double premiumPrice,
  }) {
    // Premium revenue calculation
    final monthlyActiveUsers = dailyActiveUsers * 30; // Approximate MAU
    final newPremiumUsers = monthlyActiveUsers * premiumConversionRate;
    final premiumRevenue = newPremiumUsers * premiumPrice;

    // Ad revenue calculation
    final bannerRevenue = _calculateBannerRevenue(dailyActiveUsers, adMetrics);
    final interstitialRevenue = _calculateInterstitialRevenue(dailyActiveUsers, adMetrics);
    final nativeRevenue = _calculateNativeRevenue(dailyActiveUsers, adMetrics);
    
    final totalAdRevenue = bannerRevenue + interstitialRevenue + nativeRevenue;
    final totalRevenue = premiumRevenue + totalAdRevenue;

    return RevenueProjection(
      premiumRevenue: premiumRevenue,
      adRevenue: totalAdRevenue,
      totalRevenue: totalRevenue,
      bannerRevenue: bannerRevenue,
      interstitialRevenue: interstitialRevenue,
      nativeRevenue: nativeRevenue,
      newPremiumUsers: newPremiumUsers.round(),
      adImpressions: adMetrics.totalMonthlyImpressions(dailyActiveUsers),
    );
  }

  /// Calculate banner ad revenue
  static double _calculateBannerRevenue(int dailyActiveUsers, AdMetrics metrics) {
    final monthlyImpressions = dailyActiveUsers * 30 * metrics.bannerImpressionsPerUser;
    final rpm = _adRevenueBenchmarks['banner_rpm_avg']!;
    return (monthlyImpressions / 1000) * rpm;
  }

  /// Calculate interstitial ad revenue
  static double _calculateInterstitialRevenue(int dailyActiveUsers, AdMetrics metrics) {
    final monthlyImpressions = dailyActiveUsers * 30 * metrics.interstitialImpressionsPerUser;
    final rpm = _adRevenueBenchmarks['interstitial_rpm_avg']!;
    return (monthlyImpressions / 1000) * rpm;
  }

  /// Calculate native ad revenue
  static double _calculateNativeRevenue(int dailyActiveUsers, AdMetrics metrics) {
    final monthlyImpressions = dailyActiveUsers * 30 * metrics.nativeImpressionsPerUser;
    final rpm = _adRevenueBenchmarks['native_rpm_avg']!;
    return (monthlyImpressions / 1000) * rpm;
  }

  /// Get optimization recommendations
  static List<OptimizationRecommendation> getOptimizationRecommendations({
    required int dailyActiveUsers,
    required double currentPremiumRate,
    required AdMetrics currentAdMetrics,
  }) {
    final recommendations = <OptimizationRecommendation>[];

    // Premium conversion optimization
    if (currentPremiumRate < _conversionBenchmarks['freemium_to_paid_rate']!) {
      recommendations.add(OptimizationRecommendation(
        type: OptimizationType.premiumConversion,
        title: 'Improve Premium Conversion',
        description: 'Current conversion rate (${(currentPremiumRate * 100).toStringAsFixed(1)}%) is below industry average (3.0%)',
        potentialImpact: _calculatePremiumImprovementImpact(
          dailyActiveUsers, 
          currentPremiumRate,
          _conversionBenchmarks['freemium_to_paid_rate']!,
        ),
        actionItems: [
          'Add premium feature previews',
          'Implement trial period',
          'Show value proposition at key moments',
          'Add social proof and testimonials',
        ],
      ));
    }

    // Ad placement optimization
    if (currentAdMetrics.bannerImpressionsPerUser < 2.0) {
      recommendations.add(OptimizationRecommendation(
        type: OptimizationType.adPlacement,
        title: 'Increase Banner Ad Frequency',
        description: 'Current banner frequency is conservative, can be increased without hurting UX',
        potentialImpact: _calculateAdImprovementImpact(dailyActiveUsers, currentAdMetrics),
        actionItems: [
          'Add banner in exercise list',
          'Show banner in analytics screen',
          'Test adaptive banner sizes',
        ],
      ));
    }

    // Interstitial frequency optimization
    if (currentAdMetrics.interstitialImpressionsPerUser < 0.15) {
      recommendations.add(OptimizationRecommendation(
        type: OptimizationType.adFrequency,
        title: 'Optimize Interstitial Timing',
        description: 'Interstitial frequency can be increased at natural break points',
        potentialImpact: (dailyActiveUsers * 30 * 0.1 * _adRevenueBenchmarks['interstitial_rpm_avg']! / 1000),
        actionItems: [
          'Show after template saves',
          'Show when entering analytics',
          'Add after exercise selection',
        ],
      ));
    }

    return recommendations;
  }

  /// Calculate premium improvement impact
  static double _calculatePremiumImprovementImpact(
    int dailyActiveUsers, 
    double currentRate, 
    double targetRate,
  ) {
    final currentUsers = dailyActiveUsers * 30 * currentRate;
    final targetUsers = dailyActiveUsers * 30 * targetRate;
    final additionalUsers = targetUsers - currentUsers;
    return additionalUsers * 0.99; // €0.99 per user
  }

  /// Calculate ad improvement impact
  static double _calculateAdImprovementImpact(int dailyActiveUsers, AdMetrics current) {
    final improved = AdMetrics(
      bannerImpressionsPerUser: (current.bannerImpressionsPerUser * 1.5).clamp(0, 4.0),
      interstitialImpressionsPerUser: (current.interstitialImpressionsPerUser * 1.2).clamp(0, 0.3),
      nativeImpressionsPerUser: (current.nativeImpressionsPerUser * 1.3).clamp(0, 1.0),
    );
    
    final currentRevenue = _calculateBannerRevenue(dailyActiveUsers, current) +
                          _calculateInterstitialRevenue(dailyActiveUsers, current) +
                          _calculateNativeRevenue(dailyActiveUsers, current);
    
    final improvedRevenue = _calculateBannerRevenue(dailyActiveUsers, improved) +
                           _calculateInterstitialRevenue(dailyActiveUsers, improved) +
                           _calculateNativeRevenue(dailyActiveUsers, improved);
    
    return improvedRevenue - currentRevenue;
  }

  /// Get revenue scenarios (conservative, realistic, optimistic)
  static Map<String, RevenueProjection> getRevenueScenarios({
    required int dailyActiveUsers,
    required double baseConversionRate,
  }) {
    const premiumPrice = 0.99;
    
    return {
      'conservative': calculateMonthlyRevenue(
        dailyActiveUsers: dailyActiveUsers,
        premiumConversionRate: baseConversionRate * 0.8,
        adMetrics: const AdMetrics(
          bannerImpressionsPerUser: 1.5,
          interstitialImpressionsPerUser: 0.08,
          nativeImpressionsPerUser: 0.3,
        ),
        premiumPrice: premiumPrice,
      ),
      'realistic': calculateMonthlyRevenue(
        dailyActiveUsers: dailyActiveUsers,
        premiumConversionRate: baseConversionRate,
        adMetrics: const AdMetrics(
          bannerImpressionsPerUser: 2.5,
          interstitialImpressionsPerUser: 0.12,
          nativeImpressionsPerUser: 0.5,
        ),
        premiumPrice: premiumPrice,
      ),
      'optimistic': calculateMonthlyRevenue(
        dailyActiveUsers: dailyActiveUsers,
        premiumConversionRate: baseConversionRate * 1.3,
        adMetrics: const AdMetrics(
          bannerImpressionsPerUser: 3.5,
          interstitialImpressionsPerUser: 0.18,
          nativeImpressionsPerUser: 0.8,
        ),
        premiumPrice: premiumPrice,
      ),
    };
  }
}

/// Ad metrics for a user session
class AdMetrics {
  final double bannerImpressionsPerUser;      // Banner ads per user per day
  final double interstitialImpressionsPerUser; // Interstitials per user per day  
  final double nativeImpressionsPerUser;      // Native ads per user per day

  const AdMetrics({
    required this.bannerImpressionsPerUser,
    required this.interstitialImpressionsPerUser,
    required this.nativeImpressionsPerUser,
  });

  double totalMonthlyImpressions(int dailyActiveUsers) {
    return dailyActiveUsers * 30 * (
      bannerImpressionsPerUser + 
      interstitialImpressionsPerUser + 
      nativeImpressionsPerUser
    );
  }
}

/// Revenue projection results
class RevenueProjection {
  final double premiumRevenue;
  final double adRevenue;
  final double totalRevenue;
  final double bannerRevenue;
  final double interstitialRevenue;
  final double nativeRevenue;
  final int newPremiumUsers;
  final double adImpressions;

  const RevenueProjection({
    required this.premiumRevenue,
    required this.adRevenue,
    required this.totalRevenue,
    required this.bannerRevenue,
    required this.interstitialRevenue,
    required this.nativeRevenue,
    required this.newPremiumUsers,
    required this.adImpressions,
  });

  Map<String, dynamic> toJson() => {
    'premiumRevenue': premiumRevenue,
    'adRevenue': adRevenue,
    'totalRevenue': totalRevenue,
    'bannerRevenue': bannerRevenue,
    'interstitialRevenue': interstitialRevenue,
    'nativeRevenue': nativeRevenue,
    'newPremiumUsers': newPremiumUsers,
    'adImpressions': adImpressions,
  };
}

/// Optimization recommendation types
enum OptimizationType {
  premiumConversion,
  adPlacement,
  adFrequency,
  userRetention,
  monetizationTiming,
}

/// Optimization recommendation
class OptimizationRecommendation {
  final OptimizationType type;
  final String title;
  final String description;
  final double potentialImpact; // Monthly revenue impact in EUR
  final List<String> actionItems;

  const OptimizationRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.potentialImpact,
    required this.actionItems,
  });
}