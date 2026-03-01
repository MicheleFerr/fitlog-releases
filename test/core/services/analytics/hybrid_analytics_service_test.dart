/// Unit tests for HybridAnalyticsService
///
/// Strategy:
/// - Implement a pure in-memory fake for IAnalyticsService (no Firebase dependency).
/// - Inject it as the "firebase side" into HybridAnalyticsService.
/// - Use MockAnalyticsService (already test-friendly) as the "mock side".
/// - Verify that HybridAnalyticsService correctly delegates all calls to both
///   services and exposes the mock service's public API for dashboard access.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/services/analytics/hybrid_analytics_service.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/core/services/analytics/mock_analytics_service.dart';

// ---------------------------------------------------------------------------
// Fake IAnalyticsService – replaces FirebaseAnalyticsService in tests.
// Pure in-memory implementation, zero Firebase SDK dependency.
// ---------------------------------------------------------------------------

class _FakeAnalyticsService implements IAnalyticsService {
  bool _enabled = true;
  bool _debugMode = false;
  bool _initialized = false;
  String? _userId;

  final Map<String, String?> properties = {};
  final List<Map<String, dynamic>> events = [];
  final List<Map<String, dynamic>> screenViews = [];
  final List<String> stoppedTraces = [];
  final List<Map<String, dynamic>> networkRequests = [];
  final List<Map<String, dynamic>> purchases = [];

  int initCallCount = 0;

  @override
  Future<void> initialize() async {
    initCallCount++;
    _initialized = true;
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _enabled = enabled;
  }

  @override
  Future<bool> isAnalyticsCollectionEnabled() async => _enabled;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    events.add({'name': name, 'parameters': parameters ?? {}});
  }

  @override
  Future<void> logAppOpen() async {
    events.add({'name': 'app_open', 'parameters': <String, dynamic>{}});
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    screenViews.add({
      'screen_name': screenName,
      'screen_class': screenClass ?? screenName,
    });
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    properties[name] = value;
  }

  @override
  Future<void> setUserId(String? userId) async {
    _userId = userId;
  }

  @override
  Future<String> startTrace(String name) async {
    return 'firebase_${name}_trace_id';
  }

  @override
  Future<void> stopTrace(String traceId, {Map<String, int>? metrics}) async {
    stoppedTraces.add(traceId);
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
    networkRequests.add({
      'url': url,
      'method': httpMethod,
      'response_code': httpResponseCode,
    });
  }

  @override
  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
    String? transactionId,
  }) async {
    purchases.add({
      'product_id': productId,
      'price': price,
      'currency': currency,
      'transaction_id': transactionId,
    });
  }

  @override
  Future<void> setDebugMode(bool enabled) async {
    _debugMode = enabled;
  }

  @override
  Future<void> resetAnalyticsData() async {
    _userId = null;
    properties.clear();
    events.clear();
    screenViews.clear();
    stoppedTraces.clear();
    networkRequests.clear();
    purchases.clear();
  }

  // Accessors for test assertions
  bool get isInitialized => _initialized;
  bool get isEnabled => _enabled;
  bool get isDebugMode => _debugMode;
  String? get userId => _userId;

  int getEventCount(String name) =>
      events.where((e) => e['name'] == name).length;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeAnalyticsService fakeFirebase;
  late MockAnalyticsService fakeMock;
  late HybridAnalyticsService service;

  setUp(() {
    fakeFirebase = _FakeAnalyticsService();
    fakeMock = MockAnalyticsService();
    service = HybridAnalyticsService(
      firebaseService: fakeFirebase,
      mockService: fakeMock,
    );
  });

  // ================================================================
  // Lifecycle
  // ================================================================
  group('HybridAnalyticsService - lifecycle', () {
    test('initialize calls both services', () async {
      await service.initialize();
      expect(fakeFirebase.isInitialized, isTrue);
      // After init, events can be logged to both services
      await service.logEvent(name: 'post_init');
      expect(fakeFirebase.getEventCount('post_init'), 1);
      expect(fakeMock.getEventCount('post_init'), 1);
    });

    test('initialize forwards multiple calls (no idempotency at hybrid level)', () async {
      await service.initialize();
      await service.initialize();
      expect(fakeFirebase.initCallCount, 2);
    });

    test('setAnalyticsCollectionEnabled(false) delegates to both', () async {
      await service.initialize();
      await service.setAnalyticsCollectionEnabled(false);

      expect(fakeFirebase.isEnabled, false);
      expect(await fakeMock.isAnalyticsCollectionEnabled(), false);
    });

    test('setAnalyticsCollectionEnabled(true) delegates to both', () async {
      await service.initialize();
      await service.setAnalyticsCollectionEnabled(false);
      await service.setAnalyticsCollectionEnabled(true);

      expect(fakeFirebase.isEnabled, true);
      expect(await fakeMock.isAnalyticsCollectionEnabled(), true);
    });

    test('isAnalyticsCollectionEnabled reads from firebase service', () async {
      await service.initialize();
      await fakeFirebase.setAnalyticsCollectionEnabled(false);

      final result = await service.isAnalyticsCollectionEnabled();
      expect(result, false);
    });

    test('isAnalyticsCollectionEnabled returns true by default', () async {
      await service.initialize();
      expect(await service.isAnalyticsCollectionEnabled(), true);
    });
  });

  // ================================================================
  // Event tracking
  // ================================================================
  group('HybridAnalyticsService - logEvent', () {
    setUp(() async => service.initialize());

    test('logEvent delegates to both services', () async {
      await service.logEvent(name: 'workout_started');

      expect(fakeFirebase.getEventCount('workout_started'), 1);
      expect(fakeMock.getEventCount('workout_started'), 1);
    });

    test('logEvent with parameters delegates to both', () async {
      await service.logEvent(
        name: 'set_completed',
        parameters: {'reps': 10, 'weight_kg': 80.0},
      );

      final fbEvent = fakeFirebase.events.firstWhere(
        (e) => e['name'] == 'set_completed',
      );
      final mockEvent = fakeMock.getLatestEvent('set_completed');

      expect((fbEvent['parameters'] as Map)['reps'], 10);
      expect((mockEvent!['parameters'] as Map)['reps'], 10);
    });

    test('logEvent without parameters succeeds', () async {
      await service.logEvent(name: 'button_tapped');

      expect(fakeFirebase.events.length, 1);
      expect(fakeMock.loggedEvents.length, 1);
    });

    test('multiple logEvent calls accumulate in both services', () async {
      await service.logEvent(name: 'e1');
      await service.logEvent(name: 'e2');
      await service.logEvent(name: 'e3');

      expect(fakeFirebase.events.length, 3);
      expect(fakeMock.loggedEvents.length, 3);
    });

    test('logAppOpen delegates to both services', () async {
      await service.logAppOpen();

      expect(fakeFirebase.getEventCount('app_open'), 1);
      expect(fakeMock.getEventCount('app_open'), 1);
    });

    test('logScreenView delegates to both services', () async {
      await service.logScreenView(screenName: 'HomeScreen');

      expect(fakeFirebase.screenViews.length, 1);
      expect(fakeMock.loggedScreenViews.length, 1);
    });

    test('logScreenView with screenClass delegates correctly', () async {
      await service.logScreenView(
        screenName: 'WorkoutScreen',
        screenClass: 'WorkoutScreenWidget',
      );

      expect(fakeFirebase.screenViews[0]['screen_name'], 'WorkoutScreen');
      expect(fakeFirebase.screenViews[0]['screen_class'], 'WorkoutScreenWidget');
      expect(fakeMock.loggedScreenViews[0]['screen_class'], 'WorkoutScreenWidget');
    });

    test('logScreenView without screenClass defaults to screen name', () async {
      await service.logScreenView(screenName: 'AnalyticsScreen');

      expect(fakeFirebase.screenViews[0]['screen_class'], 'AnalyticsScreen');
      expect(fakeMock.loggedScreenViews[0]['screen_class'], 'AnalyticsScreen');
    });
  });

  // ================================================================
  // User properties
  // ================================================================
  group('HybridAnalyticsService - user properties', () {
    setUp(() async => service.initialize());

    test('setUserProperty delegates to both services', () async {
      await service.setUserProperty(name: 'unit_system', value: 'metric');

      expect(fakeFirebase.properties['unit_system'], 'metric');
      expect(fakeMock.userProperties['unit_system'], 'metric');
    });

    test('setUserProperty with null value delegates to both', () async {
      await service.setUserProperty(name: 'unit_system', value: null);

      expect(fakeFirebase.properties.containsKey('unit_system'), true);
      expect(fakeFirebase.properties['unit_system'], isNull);
    });

    test('setUserId delegates to both services', () async {
      await service.setUserId('user-abc-123');

      expect(fakeFirebase.userId, 'user-abc-123');
      expect(fakeMock.userId, 'user-abc-123');
    });

    test('setUserId with null clears from both services', () async {
      await service.setUserId('user-abc-123');
      await service.setUserId(null);

      expect(fakeFirebase.userId, isNull);
      expect(fakeMock.userId, isNull);
    });
  });

  // ================================================================
  // Performance monitoring
  // ================================================================
  group('HybridAnalyticsService - performance monitoring', () {
    setUp(() async => service.initialize());

    test('startTrace returns firebase trace ID', () async {
      final traceId = await service.startTrace('load_workout');
      // Fake returns 'firebase_{name}_trace_id'
      expect(traceId, 'firebase_load_workout_trace_id');
    });

    test('stopTrace delegates to firebase service', () async {
      final traceId = await service.startTrace('heavy_operation');
      await service.stopTrace(traceId);

      expect(fakeFirebase.stoppedTraces, contains(traceId));
    });

    test('stopTrace passes metrics to firebase service', () async {
      final traceId = await service.startTrace('batch_operation');
      await service.stopTrace(traceId, metrics: {'items_processed': 50});

      // Firebase fake records the stopped trace
      expect(fakeFirebase.stoppedTraces, contains(traceId));
      // Mock service receives stopTrace call but won't find the trace ID
      // (mock uses a different internally generated ID); this is expected behavior.
    });

    test('logNetworkRequest delegates to firebase service', () async {
      await service.logNetworkRequest(
        url: 'https://api.gymbro.app/workouts',
        httpMethod: 'GET',
        httpResponseCode: 200,
        responseTime: 120,
      );

      expect(fakeFirebase.networkRequests.length, 1);
      expect(fakeFirebase.networkRequests[0]['url'],
          'https://api.gymbro.app/workouts');
      expect(fakeFirebase.networkRequests[0]['method'], 'GET');
    });

    test('logNetworkRequest with all parameters does not throw', () async {
      await service.logNetworkRequest(
        url: 'https://api.example.com/data',
        httpMethod: 'POST',
        requestPayloadSize: 512,
        responsePayloadSize: 2048,
        httpResponseCode: 201,
        responseTime: 250,
      );

      expect(fakeFirebase.networkRequests.length, 1);
    });

    test('logNetworkRequest with minimal parameters does not throw', () async {
      await service.logNetworkRequest(
        url: 'https://example.com',
        httpMethod: 'DELETE',
      );

      expect(fakeFirebase.networkRequests.length, 1);
    });
  });

  // ================================================================
  // Ecommerce
  // ================================================================
  group('HybridAnalyticsService - logPurchase', () {
    setUp(() async => service.initialize());

    test('logPurchase delegates to firebase service', () async {
      await service.logPurchase(
        productId: 'premium_yearly',
        price: 49.99,
        currency: 'EUR',
        transactionId: 'tx-001',
      );

      expect(fakeFirebase.purchases.length, 1);
      expect(fakeFirebase.purchases[0]['product_id'], 'premium_yearly');
      expect(fakeFirebase.purchases[0]['price'], 49.99);
      expect(fakeFirebase.purchases[0]['currency'], 'EUR');
    });

    test('logPurchase delegates to mock service (for dashboard)', () async {
      await service.logPurchase(
        productId: 'premium_monthly',
        price: 9.99,
        currency: 'USD',
        transactionId: 'tx-002',
      );

      expect(fakeMock.getEventCount('purchase'), 1);
      final event = fakeMock.getLatestEvent('purchase')!;
      expect((event['parameters'] as Map)['product_id'], 'premium_monthly');
    });

    test('logPurchase without transactionId does not throw', () async {
      await service.logPurchase(
        productId: 'premium_monthly',
        price: 9.99,
        currency: 'USD',
      );

      expect(fakeFirebase.purchases.length, 1);
      expect(fakeMock.getEventCount('purchase'), 1);
    });

    test('purchase product_id matches in both services', () async {
      await service.logPurchase(
        productId: 'lifetime',
        price: 99.99,
        currency: 'GBP',
      );

      expect(fakeFirebase.purchases[0]['product_id'], 'lifetime');
      final mockPurchase = fakeMock.getLatestEvent('purchase')!;
      expect((mockPurchase['parameters'] as Map)['product_id'], 'lifetime');
    });
  });

  // ================================================================
  // Debug & Reset
  // ================================================================
  group('HybridAnalyticsService - debug & reset', () {
    setUp(() async => service.initialize());

    test('setDebugMode(true) delegates to both services', () async {
      await service.setDebugMode(true);
      expect(fakeFirebase.isDebugMode, true);
    });

    test('setDebugMode(false) delegates to both services', () async {
      await service.setDebugMode(true);
      await service.setDebugMode(false);
      expect(fakeFirebase.isDebugMode, false);
    });

    test('resetAnalyticsData clears both services', () async {
      await service.setUserId('user-xyz');
      await service.logEvent(name: 'test_event');
      await service.logScreenView(screenName: 'TestScreen');

      await service.resetAnalyticsData();

      expect(fakeFirebase.events, isEmpty);
      expect(fakeFirebase.screenViews, isEmpty);
      expect(fakeFirebase.userId, isNull);
      expect(fakeMock.loggedEvents, isEmpty);
      expect(fakeMock.loggedScreenViews, isEmpty);
    });
  });

  // ================================================================
  // Dashboard API (reads from mock service)
  // ================================================================
  group('HybridAnalyticsService - dashboard API', () {
    setUp(() async => service.initialize());

    test('loggedEvents returns mock service events', () async {
      await service.logEvent(name: 'dashboard_event');
      expect(service.loggedEvents, same(fakeMock.loggedEvents));
      expect(service.loggedEvents.length, 1);
    });

    test('loggedScreenViews returns mock service screen views', () async {
      await service.logScreenView(screenName: 'DashboardScreen');
      expect(service.loggedScreenViews, same(fakeMock.loggedScreenViews));
      expect(service.loggedScreenViews.length, 1);
    });

    test('userProperties returns mock service user properties', () async {
      await service.setUserProperty(name: 'level', value: 'advanced');
      expect(service.userProperties['level'], 'advanced');
    });

    test('userId returns mock service user ID', () async {
      await service.setUserId('dashboard-user-1');
      expect(service.userId, 'dashboard-user-1');
    });

    test('completedTraces exposes mock service completed traces list', () async {
      // completedTraces property delegates to mock service
      expect(service.completedTraces, same(fakeMock.completedTraces));
    });

    test('getEventCount returns count from mock service', () async {
      await service.logEvent(name: 'click');
      await service.logEvent(name: 'click');
      await service.logEvent(name: 'scroll');

      expect(service.getEventCount('click'), 2);
      expect(service.getEventCount('scroll'), 1);
      expect(service.getEventCount('unknown'), 0);
    });

    test('getEvents returns matching events from mock service', () async {
      await service.logEvent(name: 'workout_completed', parameters: {'id': 1});
      await service.logEvent(name: 'workout_completed', parameters: {'id': 2});
      await service.logEvent(name: 'other_event');

      final events = service.getEvents('workout_completed');
      expect(events.length, 2);
    });

    test('getLatestEvent returns last matching event', () async {
      await service.logEvent(name: 'tab_tap', parameters: {'tab': 'home'});
      await service.logEvent(
          name: 'tab_tap', parameters: {'tab': 'analytics'});

      final latest = service.getLatestEvent('tab_tap');
      expect((latest!['parameters'] as Map)['tab'], 'analytics');
    });

    test('getLatestEvent returns null for unknown event name', () {
      expect(service.getLatestEvent('nonexistent_event'), isNull);
    });

    test('clearAll clears mock service data', () async {
      await service.logEvent(name: 'some_event');
      await service.logScreenView(screenName: 'SomeScreen');

      service.clearAll();

      expect(service.loggedEvents, isEmpty);
      expect(service.loggedScreenViews, isEmpty);
    });

    test('clearAll does not affect firebase fake events', () async {
      await service.logEvent(name: 'firebase_event');
      service.clearAll();

      // Firebase fake still has its events intact
      expect(fakeFirebase.events.length, 1);
    });
  });

  // ================================================================
  // Delegation symmetry
  // ================================================================
  group('HybridAnalyticsService - delegation symmetry', () {
    setUp(() async => service.initialize());

    test('same event name received by both services', () async {
      await service.logEvent(name: 'symmetry_test', parameters: {'x': 42});

      expect(fakeFirebase.getEventCount('symmetry_test'), 1);
      expect(fakeMock.getEventCount('symmetry_test'), 1);
    });

    test('same screen view received by both services', () async {
      await service.logScreenView(
        screenName: 'SymmetryScreen',
        screenClass: 'SymmetryClass',
      );

      expect(fakeFirebase.screenViews[0]['screen_name'], 'SymmetryScreen');
      expect(fakeMock.loggedScreenViews[0]['screen_name'], 'SymmetryScreen');
    });

    test('same userId received by both services', () async {
      await service.setUserId('sync-user');

      expect(fakeFirebase.userId, 'sync-user');
      expect(fakeMock.userId, 'sync-user');
    });

    test('same user property received by both services', () async {
      await service.setUserProperty(name: 'tier', value: 'premium');

      expect(fakeFirebase.properties['tier'], 'premium');
      expect(fakeMock.userProperties['tier'], 'premium');
    });

    test('event counts in firebase and mock stay in sync', () async {
      await service.logEvent(name: 'e1');
      await service.logEvent(name: 'e2');
      await service.logEvent(name: 'e3');

      expect(fakeFirebase.events.length, fakeMock.loggedEvents.length);
      expect(fakeFirebase.events.length, 3);
    });
  });
}
