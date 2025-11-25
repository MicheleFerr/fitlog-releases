/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/services/analytics
/// 🎯 Feature: analytics
/// 🔧 Type: service implementation
///
/// Firebase Analytics service implementation for production use
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';

/// Firebase Analytics service implementation
///
/// Production implementation using Firebase Analytics and Firebase Performance.
/// Automatically disabled in debug mode unless explicitly enabled.
///
/// Features:
/// - Event tracking with custom parameters
/// - Screen view tracking
/// - User properties and segmentation
/// - Performance monitoring with custom traces
/// - Network request monitoring
/// - Purchase tracking
/// - GDPR-compliant opt-out support
///
/// Usage:
/// ```dart
/// final analyticsService = FirebaseAnalyticsService();
/// await analyticsService.initialize();
///
/// // Track event
/// await analyticsService.logEvent(
///   name: 'workout_completed',
///   parameters: {'duration': 3600},
/// );
/// ```
class FirebaseAnalyticsService implements IAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;

  /// Active traces mapped by trace ID
  final Map<String, Trace> _activeTraces = {};

  bool _isInitialized = false;
  bool _isEnabled = true;
  bool _debugMode = false;

  // ===== LIFECYCLE =====

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set analytics collection enabled based on debug mode
      await _analytics.setAnalyticsCollectionEnabled(!kDebugMode || _debugMode);

      // Enable performance monitoring
      await _performance.setPerformanceCollectionEnabled(
        !kDebugMode || _debugMode,
      );

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('🔥 FirebaseAnalyticsService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing FirebaseAnalyticsService: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _analytics.setAnalyticsCollectionEnabled(enabled);

    if (kDebugMode) {
      debugPrint('📊 Analytics collection ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  @override
  Future<bool> isAnalyticsCollectionEnabled() async {
    return _isEnabled;
  }

  // ===== EVENT TRACKING =====

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isEnabled) return;

    try {
      // Convert Map<String, dynamic> to Map<String, Object>
      final convertedParams = parameters?.map(
        (key, value) => MapEntry(key, value as Object),
      );

      await _analytics.logEvent(
        name: name,
        parameters: convertedParams,
      );

      if (_debugMode && kDebugMode) {
        debugPrint('📊 Event logged: $name ${parameters ?? ''}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error logging event $name: $e');
      }
    }
  }

  @override
  Future<void> logAppOpen() async {
    if (!_isEnabled) return;

    try {
      await _analytics.logAppOpen();

      if (_debugMode && kDebugMode) {
        debugPrint('📊 App open event logged');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error logging app open: $e');
      }
    }
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );

      if (_debugMode && kDebugMode) {
        debugPrint('📊 Screen view logged: $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error logging screen view $screenName: $e');
      }
    }
  }

  // ===== USER PROPERTIES =====

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.setUserProperty(
        name: name,
        value: value,
      );

      if (_debugMode && kDebugMode) {
        debugPrint('📊 User property set: $name = $value');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error setting user property $name: $e');
      }
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!_isEnabled) return;

    try {
      await _analytics.setUserId(id: userId);

      if (_debugMode && kDebugMode) {
        debugPrint('📊 User ID set: ${userId != null ? "${userId.substring(0, 8.clamp(0, userId.length))}..." : "null"}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error setting user ID: $e');
      }
    }
  }

  // ===== PERFORMANCE MONITORING =====

  @override
  Future<String> startTrace(String name) async {
    try {
      final trace = _performance.newTrace(name);
      await trace.start();

      final traceId = '${name}_${DateTime.now().millisecondsSinceEpoch}';
      _activeTraces[traceId] = trace;

      if (_debugMode && kDebugMode) {
        debugPrint('⏱️ Trace started: $name (ID: $traceId)');
      }

      return traceId;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error starting trace $name: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> stopTrace(
    String traceId, {
    Map<String, int>? metrics,
  }) async {
    try {
      final trace = _activeTraces[traceId];
      if (trace == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Warning: Trace $traceId not found');
        }
        return;
      }

      // Add custom metrics if provided
      if (metrics != null) {
        for (final entry in metrics.entries) {
          trace.setMetric(entry.key, entry.value);
        }
      }

      await trace.stop();
      _activeTraces.remove(traceId);

      if (_debugMode && kDebugMode) {
        debugPrint('⏱️ Trace stopped: $traceId ${metrics ?? ''}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error stopping trace $traceId: $e');
      }
    }
  }

  @override
  Future<void> logNetworkRequest({
    required String url,
    required String httpMethod,
    int? requestPayloadSize,
    int? responsePayloadSize,
    int? httpResponseCode,
    int? responseTime,
  }) async {
    try {
      final metric = _performance.newHttpMetric(url, HttpMethod.values.byName(httpMethod));

      if (requestPayloadSize != null) {
        metric.requestPayloadSize = requestPayloadSize;
      }
      if (responsePayloadSize != null) {
        metric.responsePayloadSize = responsePayloadSize;
      }
      if (httpResponseCode != null) {
        metric.httpResponseCode = httpResponseCode;
      }

      // Note: ResponseTime is automatically captured by Firebase Performance
      // We can't manually set it, but we can add custom attributes
      if (responseTime != null) {
        metric.putAttribute('response_time_ms', responseTime.toString());
      }

      await metric.stop();

      if (_debugMode && kDebugMode) {
        debugPrint('🌐 Network request logged: $httpMethod $url ($httpResponseCode)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error logging network request: $e');
      }
    }
  }

  // ===== ECOMMERCE & MONETIZATION =====

  @override
  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
    String? transactionId,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logPurchase(
        value: price,
        currency: currency,
        transactionId: transactionId,
        parameters: {
          'product_id': productId,
        },
      );

      if (_debugMode && kDebugMode) {
        debugPrint('💰 Purchase logged: $productId ($price $currency)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error logging purchase: $e');
      }
    }
  }

  // ===== DEBUG & TESTING =====

  @override
  Future<void> setDebugMode(bool enabled) async {
    _debugMode = enabled;

    if (kDebugMode) {
      debugPrint('🐛 Analytics debug mode ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();

      if (_debugMode && kDebugMode) {
        debugPrint('🔄 Analytics data reset');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error resetting analytics data: $e');
      }
    }
  }
}
