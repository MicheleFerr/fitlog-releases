/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain/entities  
 * 🎯 Feature: ads
 * 🔧 Type: entity
 * 📱 Platform: Universal
 */

/// Ad loading and display state
class AdState {
  final bool isLoaded;
  final bool isLoading;
  final bool isShowing;
  final String? error;
  final DateTime? lastShown;
  final int impressionCount;

  const AdState({
    this.isLoaded = false,
    this.isLoading = false,
    this.isShowing = false,
    this.error,
    this.lastShown,
    this.impressionCount = 0,
  });

  AdState copyWith({
    bool? isLoaded,
    bool? isLoading,
    bool? isShowing,
    String? error,
    DateTime? lastShown,
    int? impressionCount,
  }) {
    return AdState(
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      isShowing: isShowing ?? this.isShowing,
      error: error ?? this.error,
      lastShown: lastShown ?? this.lastShown,
      impressionCount: impressionCount ?? this.impressionCount,
    );
  }

  /// Check if ad can be shown based on timing rules
  bool canShowInterstitial({
    required Duration minInterval,
    required int maxPerSession,
  }) {
    if (impressionCount >= maxPerSession) return false;
    
    if (lastShown != null) {
      final timeSinceLastShown = DateTime.now().difference(lastShown!);
      if (timeSinceLastShown < minInterval) return false;
    }
    
    return isLoaded && !isShowing;
  }
}

/// Global ad manager state
class AdManagerState {
  final bool isInitialized;
  final bool adsEnabled;
  final bool hasConsent;
  final bool isTestMode;
  final Map<String, AdState> adStates;
  final int sessionInterstitialCount;
  final DateTime sessionStartTime;

  const AdManagerState({
    this.isInitialized = false,
    this.adsEnabled = true,
    this.hasConsent = false,
    this.isTestMode = false,
    this.adStates = const {},
    this.sessionInterstitialCount = 0,
    required this.sessionStartTime,
  });

  AdManagerState copyWith({
    bool? isInitialized,
    bool? adsEnabled,
    bool? hasConsent,
    bool? isTestMode,
    Map<String, AdState>? adStates,
    int? sessionInterstitialCount,
    DateTime? sessionStartTime,
  }) {
    return AdManagerState(
      isInitialized: isInitialized ?? this.isInitialized,
      adsEnabled: adsEnabled ?? this.adsEnabled,
      hasConsent: hasConsent ?? this.hasConsent,
      isTestMode: isTestMode ?? this.isTestMode,
      adStates: adStates ?? this.adStates,
      sessionInterstitialCount: sessionInterstitialCount ?? this.sessionInterstitialCount,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }

  /// Check if ads should be shown (respects premium status and consent)
  bool get shouldShowAds {
    return isInitialized && adsEnabled && hasConsent;
  }

  /// Get ad state for specific placement
  AdState getAdState(String adUnitId) {
    return adStates[adUnitId] ?? const AdState();
  }
}