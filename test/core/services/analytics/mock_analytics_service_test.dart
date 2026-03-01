/// MockAnalyticsService unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/services/analytics/mock_analytics_service.dart';

void main() {
  late MockAnalyticsService service;

  setUp(() {
    service = MockAnalyticsService();
  });

  group('MockAnalyticsService - lifecycle', () {
    test('initialize', () async {
      await service.initialize();
      // Should not throw
    });

    test('initialize idempotent', () async {
      await service.initialize();
      await service.initialize();
    });

    test('setAnalyticsCollectionEnabled', () async {
      await service.setAnalyticsCollectionEnabled(false);
      expect(await service.isAnalyticsCollectionEnabled(), false);
      await service.setAnalyticsCollectionEnabled(true);
      expect(await service.isAnalyticsCollectionEnabled(), true);
    });
  });

  group('MockAnalyticsService - event tracking', () {
    setUp(() async {
      await service.initialize();
    });

    test('logEvent records event', () async {
      await service.logEvent(name: 'test_event');
      expect(service.loggedEvents.length, 1);
      expect(service.loggedEvents[0]['name'], 'test_event');
    });

    test('logEvent with parameters', () async {
      await service.logEvent(
        name: 'workout_completed',
        parameters: {'duration': 3600, 'exercises': 8},
      );
      expect(service.loggedEvents.length, 1);
      final params = service.loggedEvents[0]['parameters'] as Map;
      expect(params['duration'], 3600);
      expect(params['exercises'], 8);
    });

    test('logEvent includes user_id', () async {
      await service.setUserId('user-123');
      await service.logEvent(name: 'event');
      expect(service.loggedEvents[0]['user_id'], 'user-123');
    });

    test('logEvent includes timestamp', () async {
      await service.logEvent(name: 'event');
      expect(service.loggedEvents[0]['timestamp'], isNotNull);
    });

    test('logEvent noop when disabled', () async {
      await service.setAnalyticsCollectionEnabled(false);
      await service.logEvent(name: 'event');
      expect(service.loggedEvents, isEmpty);
    });

    test('logAppOpen', () async {
      await service.logAppOpen();
      expect(service.loggedEvents.length, 1);
      expect(service.loggedEvents[0]['name'], 'app_open');
    });

    test('logAppOpen noop when disabled', () async {
      await service.setAnalyticsCollectionEnabled(false);
      await service.logAppOpen();
      expect(service.loggedEvents, isEmpty);
    });

    test('logScreenView records screen', () async {
      await service.logScreenView(screenName: 'HomeScreen');
      expect(service.loggedScreenViews.length, 1);
      expect(service.loggedScreenViews[0]['screen_name'], 'HomeScreen');
    });

    test('logScreenView with screenClass', () async {
      await service.logScreenView(
        screenName: 'HomeScreen',
        screenClass: 'HomeScreenClass',
      );
      expect(service.loggedScreenViews[0]['screen_class'], 'HomeScreenClass');
    });

    test('logScreenView defaults screenClass to screenName', () async {
      await service.logScreenView(screenName: 'WorkoutScreen');
      expect(service.loggedScreenViews[0]['screen_class'], 'WorkoutScreen');
    });

    test('logScreenView noop when disabled', () async {
      await service.setAnalyticsCollectionEnabled(false);
      await service.logScreenView(screenName: 'Screen');
      expect(service.loggedScreenViews, isEmpty);
    });
  });

  group('MockAnalyticsService - user properties', () {
    setUp(() async {
      await service.initialize();
    });

    test('setUserProperty', () async {
      await service.setUserProperty(name: 'theme', value: 'dark');
      expect(service.userProperties['theme'], 'dark');
    });

    test('setUserProperty null value', () async {
      await service.setUserProperty(name: 'theme', value: null);
      expect(service.userProperties['theme'], isNull);
    });

    test('setUserProperty noop when disabled', () async {
      await service.setAnalyticsCollectionEnabled(false);
      await service.setUserProperty(name: 'theme', value: 'dark');
      expect(service.userProperties, isEmpty);
    });

    test('setUserId', () async {
      await service.setUserId('user-123');
      expect(service.userId, 'user-123');
    });

    test('setUserId null', () async {
      await service.setUserId('user-123');
      await service.setUserId(null);
      expect(service.userId, isNull);
    });

    test('setUserId noop when disabled', () async {
      await service.setAnalyticsCollectionEnabled(false);
      await service.setUserId('user-123');
      expect(service.userId, isNull);
    });
  });

  group('MockAnalyticsService - performance monitoring', () {
    setUp(() async {
      await service.initialize();
    });

    test('startTrace returns traceId', () async {
      final traceId = await service.startTrace('test_trace');
      expect(traceId, contains('test_trace'));
    });

    test('stopTrace records completed trace', () async {
      final traceId = await service.startTrace('test_trace');
      await service.stopTrace(traceId);
      expect(service.completedTraces.length, 1);
      expect(service.completedTraces[0]['trace_id'], traceId);
      expect(service.completedTraces[0]['duration_ms'], isA<int>());
    });

    test('stopTrace with metrics', () async {
      final traceId = await service.startTrace('test_trace');
      await service.stopTrace(traceId, metrics: {'items': 10});
      expect(service.completedTraces[0]['metrics'], {'items': 10});
    });

    test('stopTrace unknown traceId does not throw', () async {
      await service.stopTrace('unknown_id');
      expect(service.completedTraces, isEmpty);
    });

    test('logNetworkRequest does not throw', () async {
      await service.logNetworkRequest(
        url: 'https://api.example.com',
        httpMethod: 'GET',
        httpResponseCode: 200,
        responseTime: 150,
        requestPayloadSize: 0,
        responsePayloadSize: 1024,
      );
    });

    test('logNetworkRequest noop when disabled', () async {
      await service.setAnalyticsCollectionEnabled(false);
      await service.logNetworkRequest(
        url: 'https://api.example.com',
        httpMethod: 'GET',
      );
      // No assertion needed - just verifies no crash
    });
  });

  group('MockAnalyticsService - ecommerce', () {
    setUp(() async {
      await service.initialize();
    });

    test('logPurchase records event', () async {
      await service.logPurchase(
        productId: 'premium_monthly',
        price: 9.99,
        currency: 'EUR',
        transactionId: 'tx-123',
      );
      expect(service.loggedEvents.length, 1);
      expect(service.loggedEvents[0]['name'], 'purchase');
    });

    test('logPurchase without transactionId', () async {
      await service.logPurchase(
        productId: 'premium',
        price: 9.99,
        currency: 'EUR',
      );
      expect(service.loggedEvents.length, 1);
    });

    test('logPurchase noop when disabled', () async {
      await service.setAnalyticsCollectionEnabled(false);
      await service.logPurchase(
        productId: 'premium',
        price: 9.99,
        currency: 'EUR',
      );
      expect(service.loggedEvents, isEmpty);
    });
  });

  group('MockAnalyticsService - debug & testing', () {
    setUp(() async {
      await service.initialize();
    });

    test('setDebugMode', () async {
      await service.setDebugMode(false);
      await service.setDebugMode(true);
      // Should not throw
    });

    test('resetAnalyticsData clears everything', () async {
      await service.setUserId('user-123');
      await service.setUserProperty(name: 'theme', value: 'dark');
      await service.logEvent(name: 'event');
      await service.logScreenView(screenName: 'Screen');
      final traceId = await service.startTrace('trace');
      await service.stopTrace(traceId);

      await service.resetAnalyticsData();

      expect(service.userId, isNull);
      expect(service.userProperties, isEmpty);
      expect(service.loggedEvents, isEmpty);
      expect(service.loggedScreenViews, isEmpty);
      expect(service.completedTraces, isEmpty);
    });
  });

  group('MockAnalyticsService - testing helpers', () {
    setUp(() async {
      await service.initialize();
    });

    test('getEventCount', () async {
      await service.logEvent(name: 'click');
      await service.logEvent(name: 'click');
      await service.logEvent(name: 'scroll');
      expect(service.getEventCount('click'), 2);
      expect(service.getEventCount('scroll'), 1);
      expect(service.getEventCount('unknown'), 0);
    });

    test('getEvents', () async {
      await service.logEvent(name: 'click', parameters: {'id': 1});
      await service.logEvent(name: 'click', parameters: {'id': 2});
      final events = service.getEvents('click');
      expect(events.length, 2);
    });

    test('getLatestEvent', () async {
      await service.logEvent(name: 'click', parameters: {'id': 1});
      await service.logEvent(name: 'click', parameters: {'id': 2});
      final latest = service.getLatestEvent('click');
      expect((latest!['parameters'] as Map)['id'], 2);
    });

    test('getLatestEvent returns null for unknown', () {
      expect(service.getLatestEvent('unknown'), isNull);
    });

    test('clearAll', () async {
      await service.logEvent(name: 'event');
      await service.logScreenView(screenName: 'screen');
      final traceId = await service.startTrace('trace');
      await service.stopTrace(traceId);
      service.clearAll();

      expect(service.loggedEvents, isEmpty);
      expect(service.loggedScreenViews, isEmpty);
      expect(service.completedTraces, isEmpty);
    });
  });
}
