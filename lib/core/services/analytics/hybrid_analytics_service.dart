/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/services/analytics
/// 🎯 Feature: analytics
/// 🔧 Type: service implementation (hybrid)
///
/// Hybrid Analytics service - combines Firebase + local storage
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/core/services/analytics/firebase_analytics_service.dart';
import 'package:gymbro_flutter_new/core/services/analytics/mock_analytics_service.dart';

/// Hybrid Analytics Service
///
/// Combines Firebase Analytics (for production analytics) with local storage
/// (for in-app admin dashboard visualization).
///
/// Features:
/// - Sends all events to Firebase Analytics (production data)
/// - Stores events locally in memory (admin dashboard access)
/// - Provides same API as MockAnalyticsService for dashboard
/// - Works in both debug and production modes
///
/// Use case:
/// - Production apps where admins want to see analytics in-app
/// - No need to open Firebase Console
/// - Events still go to Firebase for full analytics platform
///
/// Implementation:
/// - Wraps both FirebaseAnalyticsService and MockAnalyticsService
/// - Delegates all calls to both services
/// - Exposes MockAnalyticsService public API for dashboard
class HybridAnalyticsService implements IAnalyticsService {
  HybridAnalyticsService({
    FirebaseAnalyticsService? firebaseService,
    MockAnalyticsService? mockService,
  })  : _firebaseService = firebaseService ?? FirebaseAnalyticsService(),
        _mockService = mockService ?? MockAnalyticsService();

  final FirebaseAnalyticsService _firebaseService;
  final MockAnalyticsService _mockService;

  // ===== PUBLIC API FOR ADMIN DASHBOARD =====

  /// All logged events (for admin dashboard)
  List<Map<String, dynamic>> get loggedEvents => _mockService.loggedEvents;

  /// All logged screen views (for admin dashboard)
  List<Map<String, String>> get loggedScreenViews => _mockService.loggedScreenViews;

  /// User properties (for admin dashboard)
  Map<String, String?> get userProperties => _mockService.userProperties;

  /// User ID (for admin dashboard)
  String? get userId => _mockService.userId;

  /// Completed traces (for admin dashboard)
  List<Map<String, dynamic>> get completedTraces => _mockService.completedTraces;

  /// Get count of events with given name
  int getEventCount(String eventName) => _mockService.getEventCount(eventName);

  /// Get all events with given name
  List<Map<String, dynamic>> getEvents(String eventName) =>
      _mockService.getEvents(eventName);

  /// Get latest event with given name
  Map<String, dynamic>? getLatestEvent(String eventName) =>
      _mockService.getLatestEvent(eventName);

  /// Clear all logged data (for testing)
  void clearAll() => _mockService.clearAll();

  // ===== LIFECYCLE =====

  @override
  Future<void> initialize() async {
    await Future.wait([
      _firebaseService.initialize(),
      _mockService.initialize(),
    ]);

    if (kDebugMode) {
      debugPrint('🔥 HybridAnalyticsService initialized (Firebase + Local)');
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await Future.wait([
      _firebaseService.setAnalyticsCollectionEnabled(enabled),
      _mockService.setAnalyticsCollectionEnabled(enabled),
    ]);
  }

  @override
  Future<bool> isAnalyticsCollectionEnabled() async {
    return await _firebaseService.isAnalyticsCollectionEnabled();
  }

  // ===== EVENT TRACKING =====

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    // Log to both services in parallel
    await Future.wait([
      _firebaseService.logEvent(name: name, parameters: parameters),
      _mockService.logEvent(name: name, parameters: parameters),
    ]);
  }

  @override
  Future<void> logAppOpen() async {
    await Future.wait([
      _firebaseService.logAppOpen(),
      _mockService.logAppOpen(),
    ]);
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await Future.wait([
      _firebaseService.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      ),
      _mockService.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      ),
    ]);
  }

  // ===== USER PROPERTIES =====

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await Future.wait([
      _firebaseService.setUserProperty(name: name, value: value),
      _mockService.setUserProperty(name: name, value: value),
    ]);
  }

  @override
  Future<void> setUserId(String? userId) async {
    await Future.wait([
      _firebaseService.setUserId(userId),
      _mockService.setUserId(userId),
    ]);
  }

  // ===== PERFORMANCE MONITORING =====

  @override
  Future<String> startTrace(String name) async {
    // Use Firebase trace ID as primary
    final traceId = await _firebaseService.startTrace(name);

    // Also start mock trace (uses same name, different ID format)
    await _mockService.startTrace(name);

    return traceId;
  }

  @override
  Future<void> stopTrace(
    String traceId, {
    Map<String, int>? metrics,
  }) async {
    await Future.wait([
      _firebaseService.stopTrace(traceId, metrics: metrics),
      _mockService.stopTrace(traceId, metrics: metrics),
    ]);
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
    await Future.wait([
      _firebaseService.logNetworkRequest(
        url: url,
        httpMethod: httpMethod,
        requestPayloadSize: requestPayloadSize,
        responsePayloadSize: responsePayloadSize,
        httpResponseCode: httpResponseCode,
        responseTime: responseTime,
      ),
      _mockService.logNetworkRequest(
        url: url,
        httpMethod: httpMethod,
        requestPayloadSize: requestPayloadSize,
        responsePayloadSize: responsePayloadSize,
        httpResponseCode: httpResponseCode,
        responseTime: responseTime,
      ),
    ]);
  }

  // ===== ECOMMERCE & MONETIZATION =====

  @override
  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
    String? transactionId,
  }) async {
    await Future.wait([
      _firebaseService.logPurchase(
        productId: productId,
        price: price,
        currency: currency,
        transactionId: transactionId,
      ),
      _mockService.logPurchase(
        productId: productId,
        price: price,
        currency: currency,
        transactionId: transactionId,
      ),
    ]);
  }

  // ===== DEBUG & TESTING =====

  @override
  Future<void> setDebugMode(bool enabled) async {
    await Future.wait([
      _firebaseService.setDebugMode(enabled),
      _mockService.setDebugMode(enabled),
    ]);
  }

  @override
  Future<void> resetAnalyticsData() async {
    await Future.wait([
      _firebaseService.resetAnalyticsData(),
      _mockService.resetAnalyticsData(),
    ]);
  }
}
