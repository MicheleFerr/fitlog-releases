import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_local_datasource.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_remote_datasource.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/repositories/health_repository_impl.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthBackgroundServiceSnapshot {
  const HealthBackgroundServiceSnapshot({
    required this.enabled,
    required this.lastBackgroundSync,
    required this.lastError,
  });

  final bool enabled;
  final DateTime? lastBackgroundSync;
  final String? lastError;
}

class HealthBackgroundService {
  HealthBackgroundService._();

  static final HealthBackgroundService instance = HealthBackgroundService._();

  static const Duration _defaultSyncInterval = Duration(hours: 24);
  static const Duration _androidPollingInterval = Duration(minutes: 15);
  static const String _androidNotificationChannelId = 'health_background_sync';
  static const int _androidNotificationId = 99041;
  static const String _enabledKey = 'health_background_sync_enabled';
  static const String _intervalSecondsKey =
      'health_background_sync_interval_seconds';
  static const String _lastBackgroundSyncKey =
      'health_background_sync_last_sync';
  static const String _lastBackgroundErrorKey =
      'health_background_sync_last_error';
  static const String _lastBackgroundAttemptKey =
      'health_background_sync_last_attempt';
  static const String _stopCommand = 'health_background_stop';
  static const String _runNowCommand = 'health_background_run_now';

  bool _isConfigured = false;

  Future<void> configure({required Duration syncInterval}) async {
    await _persistSyncInterval(syncInterval);

    if (_isConfigured || kIsWeb) {
      return;
    }

    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }

    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _healthBackgroundForegroundEntryPoint,
        onBackground: _healthBackgroundIosEntryPoint,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        autoStartOnBoot: true,
        onStart: _healthBackgroundAndroidEntryPoint,
        isForegroundMode: true,
        notificationChannelId: _androidNotificationChannelId,
        initialNotificationTitle: 'FitLog Health Sync',
        initialNotificationContent: 'Preparing background sync',
        foregroundServiceNotificationId: _androidNotificationId,
        foregroundServiceTypes: const [
          AndroidForegroundType.health,
          AndroidForegroundType.dataSync,
        ],
      ),
    );

    _isConfigured = true;
  }

  Future<void> enable({required Duration syncInterval}) async {
    await configure(syncInterval: syncInterval);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.remove(_lastBackgroundErrorKey);
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);

    if (!kIsWeb && Platform.isAndroid) {
      final service = FlutterBackgroundService();
      if (await service.isRunning()) {
        service.invoke(_stopCommand);
      }
    }
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  Future<Duration> getSyncInterval() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_intervalSecondsKey);
    if (seconds == null || seconds <= 0) {
      return _defaultSyncInterval;
    }
    return Duration(seconds: seconds);
  }

  Future<HealthBackgroundServiceSnapshot> getSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return HealthBackgroundServiceSnapshot(
      enabled: prefs.getBool(_enabledKey) ?? true,
      lastBackgroundSync: _readDateTime(prefs, _lastBackgroundSyncKey),
      lastError: prefs.getString(_lastBackgroundErrorKey),
    );
  }

  Future<void> recordSuccessfulSync(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackgroundSyncKey, timestamp.toIso8601String());
    await prefs.setString(
      _lastBackgroundAttemptKey,
      timestamp.toIso8601String(),
    );
    await prefs.remove(_lastBackgroundErrorKey);
  }

  Future<void> recordFailedSync(Object error) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastBackgroundAttemptKey,
      DateTime.now().toIso8601String(),
    );
    await prefs.setString(_lastBackgroundErrorKey, error.toString());
  }

  Future<void> recordAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastBackgroundAttemptKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> handleAppBackgrounded({required Duration syncInterval}) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    await configure(syncInterval: syncInterval);

    if (!await isEnabled()) {
      return;
    }

    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      await service.startService();
      return;
    }

    service.invoke(_runNowCommand);
  }

  Future<void> handleAppForegrounded() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke(_stopCommand);
    }
  }

  Future<void> _persistSyncInterval(Duration syncInterval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_intervalSecondsKey, syncInterval.inSeconds);
  }

  DateTime? _readDateTime(SharedPreferences prefs, String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> _createAndroidNotificationChannel() async {
    final notifications = FlutterLocalNotificationsPlugin();
    const channel = AndroidNotificationChannel(
      _androidNotificationChannelId,
      'Health Background Sync',
      description: 'Runs Apple Health and Health Connect sync in background.',
      importance: Importance.low,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }
}

Timer? _healthBackgroundTimer;
bool _healthBackgroundSyncInProgress = false;
bool _healthBackgroundBootstrapComplete = false;

@pragma('vm:entry-point')
Future<bool> _healthBackgroundIosEntryPoint(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final outcome = await _HealthBackgroundSyncRunner.run(
    trigger: 'ios_background_fetch',
  );

  return outcome != _BackgroundSyncOutcome.failure;
}

@pragma('vm:entry-point')
void _healthBackgroundForegroundEntryPoint(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
}

@pragma('vm:entry-point')
void _healthBackgroundAndroidEntryPoint(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: 'FitLog Health Sync',
      content: 'Waiting for next background sync window',
    );
  }

  service.on(HealthBackgroundService._stopCommand).listen((_) async {
    _healthBackgroundTimer?.cancel();
    await service.stopSelf();
  });

  service.on(HealthBackgroundService._runNowCommand).listen((_) {
    unawaited(
      _runAndroidBackgroundTick(service, trigger: 'android_command_run_now'),
    );
  });

  if (!await HealthBackgroundService.instance.isEnabled()) {
    await service.stopSelf();
    return;
  }

  _healthBackgroundTimer?.cancel();
  _healthBackgroundTimer = Timer.periodic(
    HealthBackgroundService._androidPollingInterval,
    (_) {
      unawaited(
        _runAndroidBackgroundTick(service, trigger: 'android_periodic_tick'),
      );
    },
  );

  await _runAndroidBackgroundTick(service, trigger: 'android_service_start');
}

Future<void> _runAndroidBackgroundTick(
  ServiceInstance service, {
  required String trigger,
}) async {
  final outcome = await _HealthBackgroundSyncRunner.run(trigger: trigger);

  if (service is! AndroidServiceInstance) {
    return;
  }

  final content = switch (outcome) {
    _BackgroundSyncOutcome.synced => 'Last sync completed successfully',
    _BackgroundSyncOutcome.skipped => 'Waiting for next sync window',
    _BackgroundSyncOutcome.failure => 'Last sync failed, will retry later',
  };

  await service.setForegroundNotificationInfo(
    title: 'FitLog Health Sync',
    content: content,
  );
}

enum _BackgroundSyncOutcome { synced, skipped, failure }

class _HealthBackgroundSyncRunner {
  static Future<_BackgroundSyncOutcome> run({required String trigger}) async {
    if (_healthBackgroundSyncInProgress) {
      return _BackgroundSyncOutcome.skipped;
    }

    _healthBackgroundSyncInProgress = true;

    try {
      await _bootstrap();
      final service = HealthBackgroundService.instance;

      if (!await service.isEnabled()) {
        return _BackgroundSyncOutcome.skipped;
      }

      await service.recordAttempt();

      final syncInterval = await service.getSyncInterval();
      final localDatasource = HealthLocalDatasourceImpl();
      final repository = HealthRepositoryImpl(
        localDatasource: localDatasource,
        remoteDatasource: HealthRemoteDatasourceImpl(),
      );

      final permissionResult = await repository.checkPermissionStatus();
      final permissionStatus = permissionResult.fold(
        (failure) => throw Exception(failure.message),
        (status) => status,
      );

      final failures = <String>[];
      var performedSync = false;

      if (permissionStatus.canAttemptSync(HealthDataType.workout)) {
        final didRun = await _syncDataType(
          dataType: HealthDataType.workout,
          repository: repository,
          syncInterval: syncInterval,
          failures: failures,
        );
        performedSync = performedSync || didRun;
      }

      if (permissionStatus.canAttemptSync(HealthDataType.bodyWeight)) {
        final didRun = await _syncDataType(
          dataType: HealthDataType.bodyWeight,
          repository: repository,
          syncInterval: syncInterval,
          failures: failures,
        );
        performedSync = performedSync || didRun;
      }

      if (failures.isNotEmpty) {
        final message = failures.join('\n');
        await service.recordFailedSync(message);
        await FirebaseCrashlytics.instance.recordError(
          Exception(message),
          StackTrace.current,
          reason: 'Health background sync failed ($trigger)',
          fatal: false,
        );
        return _BackgroundSyncOutcome.failure;
      }

      if (!performedSync) {
        return _BackgroundSyncOutcome.skipped;
      }

      await service.recordSuccessfulSync(DateTime.now());
      return _BackgroundSyncOutcome.synced;
    } catch (error, stackTrace) {
      await HealthBackgroundService.instance.recordFailedSync(error);
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Health background sync runner crashed ($trigger)',
        fatal: false,
      );
      return _BackgroundSyncOutcome.failure;
    } finally {
      _healthBackgroundSyncInProgress = false;
    }
  }

  static Future<void> _bootstrap() async {
    if (_healthBackgroundBootstrapComplete) {
      return;
    }

    if (Firebase.apps.isEmpty) {
      final firebaseOptions = DefaultFirebaseOptions.maybeCurrentPlatform;
      if (firebaseOptions == null) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(options: firebaseOptions);
      }
    }

    await Hive.initFlutter();
    await HiveBoxManagerEnhanced.initialize();
    _healthBackgroundBootstrapComplete = true;
  }

  static Future<bool> _syncDataType({
    required HealthDataType dataType,
    required HealthRepositoryImpl repository,
    required Duration syncInterval,
    required List<String> failures,
  }) async {
    final statusResult = await repository.getLastSyncStatus(dataType);
    final status = statusResult.fold(
      (failure) => throw Exception(failure.message),
      (value) => value,
    );

    final dueForRegularSync = _isRegularSyncDue(status, syncInterval);
    final dueForRetry = !dueForRegularSync && _isRetryDue(status);

    if (!dueForRegularSync && !dueForRetry) {
      return false;
    }

    final result = dueForRetry
        ? await repository.retryFailedSync(dataType)
        : switch (dataType) {
            HealthDataType.workout => await repository.syncWorkouts(
              startDate: DateTime.now().subtract(const Duration(days: 30)),
              endDate: DateTime.now(),
            ),
            HealthDataType.bodyWeight => await repository.syncBodyWeight(
              startDate: DateTime.now().subtract(const Duration(days: 90)),
              endDate: DateTime.now(),
            ),
            _ => throw StateError(
              'Background sync is not supported for ${dataType.name}',
            ),
          };

    return result.fold((failure) {
      failures.add('${dataType.name}: ${failure.message}');
      return true;
    }, (_) => true);
  }

  static bool _isRegularSyncDue(
    HealthSyncStatus status,
    Duration syncInterval,
  ) {
    final lastSyncTime = status.lastSyncTime;
    if (lastSyncTime == null) {
      return true;
    }

    return DateTime.now().difference(lastSyncTime) >= syncInterval;
  }

  static bool _isRetryDue(HealthSyncStatus status) {
    if (!status.shouldRetry() || status.lastSyncTime == null) {
      return false;
    }

    const retryDelays = [
      Duration(hours: 1),
      Duration(hours: 4),
      Duration(hours: 24),
    ];

    final retryDelay = retryDelays[status.retryCount];
    return DateTime.now().difference(status.lastSyncTime!) >= retryDelay;
  }
}
