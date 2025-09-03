import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import '../../../../core/utils/debug_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  /// ✅ PRODUCTION ENVIRONMENT DETECTION
  bool get _isProductionEnvironment {
    // TestFlight/App Store detection
    if (Platform.isIOS) {
      // Check if running in production (TestFlight or App Store)
      return !kDebugMode && !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
    }
    return !kDebugMode;
  }
  
  bool get _isTestFlightEnvironment {
    if (Platform.isIOS && _isProductionEnvironment) {
      // Additional TestFlight detection could be added here
      return true;
    }
    return false;
  }
  
  /// ✅ BACKGROUND STATE DETECTION for iOS audio compatibility
  bool _isAppInBackground = false;
  
  /// Set background state (chiamato dal timer quando l'app va in background)
  void setBackgroundState(bool isBackground) {
    _isAppInBackground = isBackground;
    DebugLogger.log(LogCategory.notification, 'Notification service background state: $isBackground');
  }

  /// Initialize notification service with production audio fix
  Future<void> initialize() async {
    if (_isInitialized) return;

    DebugLogger.log(LogCategory.notification, '=== NOTIFICATION SERVICE INITIALIZATION ===');
    DebugLogger.log(LogCategory.notification, 'Environment: ${_isProductionEnvironment ? "PRODUCTION" : "DEBUG"}');
    DebugLogger.log(LogCategory.notification, 'TestFlight: ${_isTestFlightEnvironment ? "YES" : "NO"}');
    DebugLogger.log(LogCategory.notification, 'Platform: ${Platform.operatingSystem}');

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // ✅ For timer notifications
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(initSettings);
    
    // ✅ PRODUCTION FIX: Explicitly request permissions after initialization
    await _requestIOSPermissionsExplicitly();
    
    _isInitialized = true;
    DebugLogger.log(LogCategory.notification, '✅ Notification service initialized with audio permissions');
  }

  /// ✅ Explicitly request iOS permissions for production compatibility
  Future<void> _requestIOSPermissionsExplicitly() async {
    try {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        DebugLogger.log(LogCategory.notification, 'Requesting iOS notification permissions...');
        
        final permissionsGranted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true, // ✅ Critical for timer notifications
        );
        
        DebugLogger.log(LogCategory.notification, 'iOS Permissions request result: $permissionsGranted');
        
        if (permissionsGranted != true) {
          DebugLogger.log(LogCategory.notification, '⚠️ WARNING: Some permissions not granted - notifications may not work properly!');
          DebugLogger.log(LogCategory.notification, '⚠️ Please check Settings > Notifications > FitLog Pro');
        } else {
    DebugLogger.log(LogCategory.notification, '✅ All iOS notification permissions granted successfully');
        }
      }
    } catch (e) {
      DebugLogger.error('Error requesting iOS permissions', e);
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    await initialize();
    
    final result = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    return result ?? false;
  }

  /// Send timer completion notification
  Future<void> sendTimerCompletionNotification({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    String? workoutName,
    String? customSoundFile,
  }) async {
    await initialize();

    DebugLogger.log(LogCategory.notification, '=== DEBUG NOTIFICA ===');
    DebugLogger.log(LogCategory.notification, 'App state: ${_isAppInBackground ? "BACKGROUND" : "FOREGROUND"}');
    DebugLogger.log(LogCategory.notification, 'Invio notifica con suono: ${customSoundFile ?? 'timer_complete'}');
    DebugLogger.log(LogCategory.notification, 'File audio iOS: ${customSoundFile ?? 'timer_complete'}.caf');

    // v3.0.2 TEMP: Use default Android notification sound instead of custom
    final androidDetails = AndroidNotificationDetails(
      'timer_completion',
      'Timer Completion',
      channelDescription: 'Notifications when rest timer completes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(customSoundFile ?? 'timer_complete'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]), // Vibration pattern
      category: AndroidNotificationCategory.alarm,
      ticker: 'Rest complete!',
    );

    // ✅ BACKGROUND/FOREGROUND SPECIFIC iOS CONFIGURATION
    final iOSDetails = _createIOSNotificationDetails(customSoundFile ?? 'timer_complete');

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    final title = currentSet < totalSets 
        ? 'Rest Complete! 💪'
        : 'Exercise Complete! 🎉';
        
    final body = currentSet < totalSets
        ? 'Ready for $exerciseName - Set $currentSet/$totalSets'
        : '$exerciseName finished! Great work!';

    DebugLogger.log(LogCategory.notification, 'Invio notifica: $title - $body');

    await _notifications.show(
      0, // notification id
      title,
      body,
      notificationDetails,
      payload: 'timer_complete:$exerciseName:$currentSet:$totalSets',
    );
    
    DebugLogger.log(LogCategory.notification, 'Notifica inviata con successo');
  }

  /// Send workout reminder notification
  Future<void> sendWorkoutReminder({
    required String title,
    required String body,
    DateTime? scheduledDate,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'workout_reminders',
      'Workout Reminders',
      channelDescription: 'Reminders for scheduled workouts',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    if (scheduledDate != null) {
      await _notifications.zonedSchedule(
        1, // notification id
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: 'workout_reminder',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      await _notifications.show(
        1,
        title,
        body,
        notificationDetails,
        payload: 'workout_reminder',
      );
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  /// Schedule timer completion notification for future
  Future<void> scheduleTimerCompletionNotification({
    required Duration delay,
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    String? workoutName,
    String? customSoundFile,
  }) async {
    await initialize();
    
    DebugLogger.log(LogCategory.notification, '=== SCHEDULING FUTURE NOTIFICATION ===');
    DebugLogger.log(LogCategory.notification, 'Will fire in: ${delay.inSeconds} seconds');
    DebugLogger.log(LogCategory.notification, 'Sound: ${customSoundFile ?? 'timer_complete'}');
    
    final androidDetails = AndroidNotificationDetails(
      'timer_completion',
      'Timer Completion',
      channelDescription: 'Notifications when rest timer completes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(customSoundFile ?? 'timer_complete'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      category: AndroidNotificationCategory.alarm,
      ticker: 'Rest complete!',
    );

    final iOSDetails = _createIOSNotificationDetails(customSoundFile ?? 'timer_complete');

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    final title = currentSet < totalSets 
        ? 'Rest Complete! 💪'
        : 'Exercise Complete! 🎉';
        
    final body = currentSet < totalSets
        ? 'Ready for $exerciseName - Set $currentSet/$totalSets'
        : '$exerciseName finished! Great work!';

    // Schedule for future
    final scheduledDate = DateTime.now().add(delay);
    
    await _notifications.zonedSchedule(
      100, // Use a specific ID for timer notifications so we can cancel them
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'timer_complete:$exerciseName:$currentSet:$totalSets',
    );
    
    DebugLogger.log(LogCategory.notification, '✅ Notification scheduled for ${scheduledDate.toIso8601String()}');
  }
  
  /// Cancel scheduled timer notification
  Future<void> cancelScheduledTimerNotification() async {
    await _notifications.cancel(100); // Cancel the timer notification ID
    DebugLogger.log(LogCategory.notification, 'Scheduled timer notification cancelled');
  }

  /// ✅ Create iOS notification details - ENABLE CUSTOM SOUNDS
  DarwinNotificationDetails _createIOSNotificationDetails(String soundName) {
    DebugLogger.log(LogCategory.notification, '=== iOS NOTIFICATION CONFIGURATION ===');
    DebugLogger.log(LogCategory.notification, 'Sound requested (ignored): $soundName');
    
    // v3.0.2 TEMP: Disabled custom sounds - using default iOS notification sound
    // This avoids conflicts with native iOS system sounds
    // String? soundFile;
    // if (soundName != 'timer_complete' && soundName.isNotEmpty) {
    //   // Use custom sound with .caf extension (Apple's preferred format)
    //   soundFile = '$soundName.caf';
    //   DebugLogger.log(LogCategory.notification, '✅ Using custom sound: $soundFile');
    // } else {
    //   // Use default timer sound
    //   soundFile = 'timer_complete.caf';
    //   DebugLogger.log(LogCategory.notification, '✅ Using default timer sound: $soundFile');
    // }
    
    DebugLogger.log(LogCategory.notification, '🔊 Using DEFAULT iOS notification sound');
    
    return DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: null, // v3.0.2: null = use default iOS notification sound
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'TIMER_COMPLETE',
    );
  }


  /// ✅ Create fallback notification with system sound
  Future<void> _sendFallbackNotification({
    required String title,
    required String body,
  }) async {
    DebugLogger.log(LogCategory.notification, '=== SENDING FALLBACK NOTIFICATION (SYSTEM SOUND) ===');
    
    const androidDetails = AndroidNotificationDetails(
      'timer_completion_fallback',
      'Timer Completion Fallback',
      channelDescription: 'Fallback notifications with system sound',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // ✅ No custom sound = iOS uses system default
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'TIMER_COMPLETE_FALLBACK',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      1, // Different ID for fallback
      title,
      body,
      notificationDetails,
    );
    
    DebugLogger.log(LogCategory.notification, '✅ Fallback notification sent with system sound');
  }

  /// ✅ Test Audio File Availability with multiple strategies
  Future<void> testAudioFiles() async {
    final testSounds = ['timer_complete', 'LightWeight', 'YehBuddie'];
    
    DebugLogger.debug('=== COMPREHENSIVE AUDIO TEST ===');
    
    // Test 1: Custom sounds
    for (final sound in testSounds) {
      DebugLogger.debug('Testing custom sound: $sound');
      
      await sendTimerCompletionNotification(
        exerciseName: 'TEST',
        currentSet: 1,
        totalSets: 1,
        customSoundFile: sound,
      );
      
      await Future.delayed(const Duration(seconds: 3));
    }
    
    // Test 2: System sound fallback
    DebugLogger.debug('Testing system sound fallback...');
    await _sendFallbackNotification(
      title: 'SYSTEM SOUND TEST',
      body: 'This should play the iOS system sound',
    );
    
    await Future.delayed(const Duration(seconds: 3));
    
    // Test 3: No sound (silent)
    DebugLogger.debug('Testing silent notification...');
    await _sendSilentTestNotification();
    
    DebugLogger.debug('=== END COMPREHENSIVE AUDIO TEST ===');
  }

  /// ✅ Send silent test notification
  Future<void> _sendSilentTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'timer_test_silent',
      'Silent Test',
      channelDescription: 'Silent test notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false, // ✅ Explicitly no sound
      enableVibration: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false, // ✅ Explicitly no sound
      interruptionLevel: InterruptionLevel.passive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      2, // Different ID for silent test
      'SILENT TEST',
      'This notification should be silent (vibration only)',
      notificationDetails,
    );
    
    DebugLogger.debug('✅ Silent test notification sent');
  }

  /// ✅ PRODUCTION-SPECIFIC TESTING METHOD for TestFlight debugging
  Future<void> testProductionAudio() async {
    DebugLogger.debug('=== PRODUCTION AUDIO TESTING ===');
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    
    // Test 1: Production environment notification with critical level
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    await sendTimerCompletionNotification(
      exerciseName: 'PRODUCTION TEST',
      currentSet: 1,
      totalSets: 1,
      customSoundFile: 'timer_complete',
    );
    
    await Future.delayed(const Duration(seconds: 3));
    
    // Test 2: Different sound file
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    await sendTimerCompletionNotification(
      exerciseName: 'LIGHTWEIGHT TEST',
      currentSet: 1,
      totalSets: 1,
      customSoundFile: 'LightWeight',
    );
    
    await Future.delayed(const Duration(seconds: 3));
    
    // Test 3: Fallback system sound
    DebugLogger.debug('Testing system sound fallback...');
    if (_isProductionEnvironment) {
      await _sendProductionFallbackNotification(
        title: 'SYSTEM SOUND TEST',
        body: 'TestFlight/Production system sound fallback',
      );
    }
    
    DebugLogger.debug('=== PRODUCTION AUDIO TESTING COMPLETE ===');
  }

  /// ✅ Production-specific fallback notification
  Future<void> _sendProductionFallbackNotification({
    required String title,
    required String body,
  }) async {
    DebugLogger.log(LogCategory.notification, '=== PRODUCTION FALLBACK NOTIFICATION ===');
    
    const androidDetails = AndroidNotificationDetails(
      'production_fallback',
      'Production Fallback',
      channelDescription: 'Production fallback notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // ✅ NO CUSTOM SOUND - Let iOS use system default
      interruptionLevel: InterruptionLevel.critical, // Critical for production
      categoryIdentifier: 'PRODUCTION_FALLBACK',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      99, // Special ID for production fallback
      title,
      body,
      notificationDetails,
    );
    
    DebugLogger.log(LogCategory.notification, '✅ Production fallback notification sent');
  }

  /// ✅ TEST BACKGROUND AUDIO SPECIFICALLY
  Future<void> testBackgroundAudio() async {
    DebugLogger.debug('=== BACKGROUND AUDIO TESTING ===');
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    
    // Force background state for testing
    setBackgroundState(true);
    
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    await sendTimerCompletionNotification(
      exerciseName: 'BACKGROUND TEST',
      currentSet: 1,
      totalSets: 1,
      customSoundFile: 'timer_complete',
    );
    
    await Future.delayed(const Duration(seconds: 3));
    
    // Test foreground for comparison
    setBackgroundState(false);
    
    DebugLogger.log(LogCategory.notification, 'Notification debug info');
    await sendTimerCompletionNotification(
      exerciseName: 'FOREGROUND TEST',
      currentSet: 1,
      totalSets: 1,
      customSoundFile: 'timer_complete',
    );
    
    DebugLogger.debug('=== BACKGROUND AUDIO TESTING COMPLETE ===');
  }

  /// ✅ HELPER: Force notification in background mode for testing
  Future<void> sendBackgroundTestNotification() async {
    DebugLogger.debug('=== FORCED BACKGROUND NOTIFICATION TEST ===');
    
    final oldState = _isAppInBackground;
    setBackgroundState(true); // Force background mode
    
    await sendTimerCompletionNotification(
      exerciseName: 'FORCED BACKGROUND',
      currentSet: 1,
      totalSets: 1,
      customSoundFile: 'timer_complete',
    );
    
    setBackgroundState(oldState); // Restore original state
    DebugLogger.debug('✅ Forced background notification sent - should use system sound');
  }
}