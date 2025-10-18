/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/services/analytics
/// 🎯 Feature: analytics
/// 🔧 Type: service implementation (mock)
///
/// Mock Analytics service for testing and development
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';

/// Mock Analytics service implementation
///
/// Testing/development implementation that logs all events to console.
/// Does not send any data to Firebase or external services.
///
/// Features:
/// - Console logging of all events
/// - In-memory storage of events for testing assertions
/// - Simulated trace timing
/// - No network calls
/// - GDPR-compliant by design (no data leaves device)
///
/// Usage:
/// ```dart
/// final analyticsService = MockAnalyticsService();
/// await analyticsService.initialize();
///
/// // Track event (logged to console only)
/// await analyticsService.logEvent(
///   name: 'workout_completed',
///   parameters: {'duration': 3600},
/// );
///
/// // Assert in tests
/// expect(
///   analyticsService.loggedEvents,
///   contains(predicate((e) => e['name'] == 'workout_completed')),
/// );
/// ```
class MockAnalyticsService implements IAnalyticsService {
  bool _isInitialized = false;
  bool _isEnabled = true;
  bool _debugMode = true; // Always in debug mode
  String? _userId;
  final Map<String, String?> _userProperties = {};

  /// All logged events (for testing assertions)
  final List<Map<String, dynamic>> loggedEvents = [];

  /// All logged screen views (for testing assertions)
  final List<Map<String, String>> loggedScreenViews = [];

  /// Active traces with start times
  final Map<String, DateTime> _activeTraces = {};

  /// Completed traces with durations
  final List<Map<String, dynamic>> completedTraces = [];

  // ===== LIFECYCLE =====

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('🔥 MockAnalyticsService initialized');
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _isEnabled = enabled;

    if (kDebugMode) {
      debugPrint('📊 Mock Analytics collection ${enabled ? 'enabled' : 'disabled'}');
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

    final event = {
      'name': name,
      'parameters': parameters ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    loggedEvents.add(event);

    if (_debugMode && kDebugMode) {
      debugPrint('📊 [MOCK] Event logged: $name');
      if (parameters != null && parameters.isNotEmpty) {
        debugPrint('   Parameters: $parameters');
      }
    }
  }

  @override
  Future<void> logAppOpen() async {
    if (!_isEnabled) return;

    await logEvent(name: 'app_open');
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isEnabled) return;

    final screenView = {
      'screen_name': screenName,
      'screen_class': screenClass ?? screenName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    loggedScreenViews.add(screenView);

    if (_debugMode && kDebugMode) {
      debugPrint('📊 [MOCK] Screen view logged: $screenName');
    }
  }

  // ===== USER PROPERTIES =====

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_isEnabled) return;

    _userProperties[name] = value;

    if (_debugMode && kDebugMode) {
      debugPrint('📊 [MOCK] User property set: $name = $value');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!_isEnabled) return;

    _userId = userId;

    if (_debugMode && kDebugMode) {
      debugPrint('📊 [MOCK] User ID set: $userId');
    }
  }

  // ===== PERFORMANCE MONITORING =====

  @override
  Future<String> startTrace(String name) async {
    final traceId = '${name}_${DateTime.now().millisecondsSinceEpoch}';
    _activeTraces[traceId] = DateTime.now();

    if (_debugMode && kDebugMode) {
      debugPrint('⏱️ [MOCK] Trace started: $name (ID: $traceId)');
    }

    return traceId;
  }

  @override
  Future<void> stopTrace(
    String traceId, {
    Map<String, int>? metrics,
  }) async {
    final startTime = _activeTraces[traceId];
    if (startTime == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [MOCK] Warning: Trace $traceId not found');
      }
      return;
    }

    final duration = DateTime.now().difference(startTime);
    _activeTraces.remove(traceId);

    final trace = {
      'trace_id': traceId,
      'duration_ms': duration.inMilliseconds,
      'metrics': metrics ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    completedTraces.add(trace);

    if (_debugMode && kDebugMode) {
      debugPrint('⏱️ [MOCK] Trace stopped: $traceId');
      debugPrint('   Duration: ${duration.inMilliseconds}ms');
      if (metrics != null && metrics.isNotEmpty) {
        debugPrint('   Metrics: $metrics');
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
    if (!_isEnabled) return;

    if (_debugMode && kDebugMode) {
      debugPrint('🌐 [MOCK] Network request logged:');
      debugPrint('   Method: $httpMethod');
      debugPrint('   URL: $url');
      if (httpResponseCode != null) {
        debugPrint('   Response code: $httpResponseCode');
      }
      if (responseTime != null) {
        debugPrint('   Response time: ${responseTime}ms');
      }
      if (requestPayloadSize != null) {
        debugPrint('   Request size: ${requestPayloadSize}B');
      }
      if (responsePayloadSize != null) {
        debugPrint('   Response size: ${responsePayloadSize}B');
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

    await logEvent(
      name: 'purchase',
      parameters: {
        'product_id': productId,
        'price': price,
        'currency': currency,
        if (transactionId != null) 'transaction_id': transactionId,
      },
    );

    if (_debugMode && kDebugMode) {
      debugPrint('💰 [MOCK] Purchase logged: $productId ($price $currency)');
      if (transactionId != null) {
        debugPrint('   Transaction ID: $transactionId');
      }
    }
  }

  // ===== DEBUG & TESTING =====

  @override
  Future<void> setDebugMode(bool enabled) async {
    _debugMode = enabled;

    if (kDebugMode) {
      debugPrint('🐛 [MOCK] Analytics debug mode ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    _userId = null;
    _userProperties.clear();
    loggedEvents.clear();
    loggedScreenViews.clear();
    _activeTraces.clear();
    completedTraces.clear();

    if (_debugMode && kDebugMode) {
      debugPrint('🔄 [MOCK] Analytics data reset');
    }
  }

  // ===== TESTING HELPERS =====

  /// Get user ID (for testing assertions)
  String? get userId => _userId;

  /// Get user properties (for testing assertions)
  Map<String, String?> get userProperties => Map.unmodifiable(_userProperties);

  /// Get count of events with given name
  int getEventCount(String eventName) {
    return loggedEvents.where((e) => e['name'] == eventName).length;
  }

  /// Get all events with given name
  List<Map<String, dynamic>> getEvents(String eventName) {
    return loggedEvents.where((e) => e['name'] == eventName).toList();
  }

  /// Get latest event with given name
  Map<String, dynamic>? getLatestEvent(String eventName) {
    final events = getEvents(eventName);
    return events.isEmpty ? null : events.last;
  }

  /// Clear all logged data (for testing)
  void clearAll() {
    loggedEvents.clear();
    loggedScreenViews.clear();
    completedTraces.clear();
    _activeTraces.clear();
  }
}
