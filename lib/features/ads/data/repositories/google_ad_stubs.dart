/// Stub classes for Google Mobile Ads SDK
/// These are temporary placeholders until AdMob is properly configured

// Stub classes to replace google_mobile_ads imports
class MobileAds {
  static MobileAds instance = MobileAds();
  Future<void> initialize() async {}
  Future<void> updateRequestConfiguration(RequestConfiguration config) async {}
}

class RequestConfiguration {
  final TagForChildDirectedTreatment? tagForChildDirectedTreatment;
  final TagForUnderAgeOfConsent? tagForUnderAgeOfConsent;
  final List<String>? testDeviceIds;
  
  RequestConfiguration({
    this.tagForChildDirectedTreatment,
    this.tagForUnderAgeOfConsent,
    this.testDeviceIds,
  });
}

enum TagForChildDirectedTreatment { yes, no, unspecified }
enum TagForUnderAgeOfConsent { yes, no, unspecified }

class BannerAd {
  final String adUnitId;
  final AdSize size;
  final AdRequest request;
  final BannerAdListener listener;
  
  BannerAd({
    required this.adUnitId,
    required this.size,
    required this.request,
    required this.listener,
  });
  
  Future<void> load() async {}
  void dispose() {}
}

class InterstitialAd {
  static Future<void> load({
    required String adUnitId,
    required AdRequest request,
    required InterstitialAdLoadCallback adLoadCallback,
  }) async {}
  
  FullScreenContentCallback? fullScreenContentCallback;
  Future<void> show() async {}
  void dispose() {}
}

class NativeAd {
  final String adUnitId;
  final AdRequest request;
  final String factoryId;
  final NativeAdListener listener;
  
  NativeAd({
    required this.adUnitId,
    required this.request,
    required this.factoryId,
    required this.listener,
  });
  
  Future<void> load() async {}
  void dispose() {}
}

class AdRequest {
  const AdRequest();
}

class AdSize {
  static const AdSize banner = AdSize._('banner');
  static const AdSize largeBanner = AdSize._('largeBanner');
  static const AdSize mediumRectangle = AdSize._('mediumRectangle');
  static const AdSize fullBanner = AdSize._('fullBanner');
  
  final String name;
  const AdSize._(this.name);
}

class BannerAdListener {
  final Function(dynamic)? onAdLoaded;
  final Function(dynamic, dynamic)? onAdFailedToLoad;
  final Function(dynamic)? onAdClicked;
  
  BannerAdListener({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
  });
}

class InterstitialAdLoadCallback {
  final Function(InterstitialAd)? onAdLoaded;
  final Function(dynamic)? onAdFailedToLoad;
  
  InterstitialAdLoadCallback({
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });
}

class NativeAdListener {
  final Function(dynamic)? onAdLoaded;
  final Function(dynamic, dynamic)? onAdFailedToLoad;
  final Function(dynamic)? onAdClicked;
  
  NativeAdListener({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
  });
}

class FullScreenContentCallback {
  final Function(dynamic)? onAdShowedFullScreenContent;
  final Function(dynamic)? onAdDismissedFullScreenContent;
  final Function(dynamic, dynamic)? onAdFailedToShowFullScreenContent;
  final Function(dynamic)? onAdClicked;
  
  FullScreenContentCallback({
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
    this.onAdClicked,
  });
}