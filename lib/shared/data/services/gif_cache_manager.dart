/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/data/services
/// 🎯 Feature: GIF caching optimization
/// 🔧 Type: service
///
/// Global GIF cache manager for optimizing exercise animation loading
/// Prevents infinite reload loops by centralizing cache configuration
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Centralized GIF cache manager for exercise animations
///
/// Features:
/// - 30-day cache validity for offline access
/// - Up to 200 cached GIFs in storage
/// - Memory-efficient with size constraints
/// - Singleton pattern for app-wide usage
class GifCacheManager {
  static const String _cacheKey = 'exerciseGifCache';

  static final CacheManager _instance = CacheManager(
    Config(
      _cacheKey,
      // GIFs are valid for 30 days before refresh
      // Users can still access offline for years, but will refresh daily if available
      stalePeriod: const Duration(days: 30),
      // Limit to 200 cached GIFs to prevent unlimited storage growth
      // Average GIF ~300KB = 60MB total max cache
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: _cacheKey),
      fileService: HttpFileService(),
    ),
  );

  /// Get the global GIF cache manager instance
  static CacheManager get instance => _instance;

  /// Pre-cache a GIF URL (useful for workout preparation)
  static Future<void> precacheGif(String gifUrl) async {
    try {
      await _instance.getSingleFile(gifUrl);
    } catch (e) {
      // Silently fail - image will load on-demand if precache fails
      debugPrint('❌ Failed to precache GIF: $gifUrl - $e');
    }
  }

  /// Pre-cache multiple GIFs in parallel
  /// Used when loading workout with multiple exercises
  static Future<void> precacheGifs(List<String> gifUrls) async {
    await Future.wait(
      gifUrls.where((url) => url.isNotEmpty).map((url) => precacheGif(url)),
      eagerError: false,
    );
  }
}
