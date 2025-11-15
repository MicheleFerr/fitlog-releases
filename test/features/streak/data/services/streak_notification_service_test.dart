import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:gymbro_flutter_new/features/streak/data/services/streak_notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeTZDateTime extends Fake implements tz.TZDateTime {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

void main() {
  late StreakNotificationService service;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(FakeTZDateTime());
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exact);
    registerFallbackValue(DateTimeComponents.time);
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    service = StreakNotificationService(mockPlugin);
  });

  group('StreakNotificationService', () {
    test('should request notification permissions', () async {
      when(() => mockPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>())
          .thenReturn(null);

      when(() => mockPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(null);

      await service.requestPermissions();

      verify(() => mockPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()).called(1);
    });

    test('should schedule daily streak reminder at specific time', () async {
      when(() => mockPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          )).thenAnswer((_) async => {});

      await service.scheduleDailyReminder(
        hour: 20, // 8 PM
        minute: 0,
      );

      verify(() => mockPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          )).called(1);
    });

    test('should cancel streak reminder', () async {
      when(() => mockPlugin.cancel(1)).thenAnswer((_) async => {});

      await service.cancelDailyReminder();

      verify(() => mockPlugin.cancel(1)).called(1);
    });

    test('should check if notifications are enabled', () async {
      when(() => mockPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>())
          .thenReturn(null);

      when(() => mockPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(null);

      final enabled = await service.areNotificationsEnabled();

      expect(enabled, isA<bool>());
    });
  });
}
