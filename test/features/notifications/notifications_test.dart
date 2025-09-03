import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

// Mock Notifications Service
class NotificationService {
  final List<AppNotification> _notifications = [];
  final StreamController<AppNotification> _notificationStream = StreamController<AppNotification>.broadcast();
  final Map<String, bool> _preferences = {
    'workout_reminders': true,
    'rest_timer_alerts': true,
    'achievement_notifications': true,
    'social_updates': false,
    'daily_tips': true,
  };
  
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  Stream<AppNotification> get notificationStream => _notificationStream.stream;
  Map<String, bool> get preferences => Map.unmodifiable(_preferences);
  
  // Schedule notifications
  Future<bool> scheduleWorkoutReminder({
    required DateTime scheduledTime,
    required String workoutName,
    String? message,
  }) async {
    if (!_preferences['workout_reminders']!) {
      return false;
    }
    
    final notification = AppNotification(
      id: 'workout-${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.workoutReminder,
      title: 'Time for $workoutName!',
      body: message ?? 'Your workout is scheduled to start now',
      scheduledTime: scheduledTime,
      createdAt: DateTime.now(),
    );
    
    _notifications.add(notification);
    
    // Simulate scheduling delay
    await Future.delayed(const Duration(milliseconds: 50));
    
    // If scheduled for now or past, trigger immediately
    if (scheduledTime.isBefore(DateTime.now()) || scheduledTime.isAtSameMomentAs(DateTime.now())) {
      _notificationStream.add(notification);
    }
    
    return true;
  }
  
  Future<bool> scheduleRestTimerNotification({
    required int seconds,
    required String exerciseName,
    required int setNumber,
  }) async {
    if (!_preferences['rest_timer_alerts']!) {
      return false;
    }
    
    final notification = AppNotification(
      id: 'rest-${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.restTimer,
      title: 'Rest Timer Complete!',
      body: 'Time to start set $setNumber of $exerciseName',
      scheduledTime: DateTime.now().add(Duration(seconds: seconds)),
      createdAt: DateTime.now(),
      metadata: {
        'exercise': exerciseName,
        'set': setNumber,
        'duration': seconds,
      },
    );
    
    _notifications.add(notification);
    
    // Simulate timer
    Timer(Duration(seconds: seconds), () {
      if (!notification.isCancelled) {
        _notificationStream.add(notification);
      }
    });
    
    return true;
  }
  
  // Send instant notifications
  Future<void> sendAchievementNotification({
    required String achievement,
    required String description,
  }) async {
    if (!_preferences['achievement_notifications']!) {
      return;
    }
    
    final notification = AppNotification(
      id: 'achievement-${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.achievement,
      title: '🏆 Achievement Unlocked!',
      body: '$achievement: $description',
      scheduledTime: DateTime.now(),
      createdAt: DateTime.now(),
    );
    
    _notifications.add(notification);
    _notificationStream.add(notification);
  }
  
  Future<void> sendPersonalRecordNotification({
    required String exerciseName,
    required String recordType,
    required double value,
    required double previousValue,
  }) async {
    if (!_preferences['achievement_notifications']!) {
      return;
    }
    
    final improvement = ((value - previousValue) / previousValue * 100).toStringAsFixed(1);
    
    final notification = AppNotification(
      id: 'pr-${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.personalRecord,
      title: '💪 New Personal Record!',
      body: '$exerciseName: ${value.toStringAsFixed(1)} ($recordType) - $improvement% improvement!',
      scheduledTime: DateTime.now(),
      createdAt: DateTime.now(),
      metadata: {
        'exercise': exerciseName,
        'type': recordType,
        'value': value,
        'previous': previousValue,
      },
    );
    
    _notifications.add(notification);
    _notificationStream.add(notification);
  }
  
  Future<void> sendDailyTip({
    required String tip,
    String? category,
  }) async {
    if (!_preferences['daily_tips']!) {
      return;
    }
    
    final notification = AppNotification(
      id: 'tip-${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.dailyTip,
      title: '💡 Daily Fitness Tip',
      body: tip,
      scheduledTime: DateTime.now(),
      createdAt: DateTime.now(),
      metadata: category != null ? {'category': category} : null,
    );
    
    _notifications.add(notification);
    _notificationStream.add(notification);
  }
  
  // Manage notifications
  Future<bool> cancelNotification(String notificationId) async {
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => throw Exception('Notification not found'),
    );
    
    notification.isCancelled = true;
    return true;
  }
  
  Future<void> cancelAllScheduledNotifications() async {
    for (final notification in _notifications) {
      if (notification.scheduledTime.isAfter(DateTime.now())) {
        notification.isCancelled = true;
      }
    }
  }
  
  Future<void> markAsRead(String notificationId) async {
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => throw Exception('Notification not found'),
    );
    
    notification.isRead = true;
  }
  
  Future<void> markAllAsRead() async {
    for (final notification in _notifications) {
      notification.isRead = true;
    }
  }
  
  // Preferences management
  Future<void> updatePreference(String key, bool value) async {
    if (!_preferences.containsKey(key)) {
      throw Exception('Invalid preference key: $key');
    }
    
    _preferences[key] = value;
  }
  
  Future<void> updateAllPreferences(Map<String, bool> newPreferences) async {
    for (final entry in newPreferences.entries) {
      if (_preferences.containsKey(entry.key)) {
        _preferences[entry.key] = entry.value;
      }
    }
  }
  
  // Get notifications with filters
  List<AppNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }
  
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }
  
  List<AppNotification> getScheduledNotifications() {
    return _notifications
        .where((n) => n.scheduledTime.isAfter(DateTime.now()) && !n.isCancelled)
        .toList();
  }
  
  List<AppNotification> getRecentNotifications({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _notifications
        .where((n) => n.createdAt.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  // Clear notifications
  void clearAll() {
    _notifications.clear();
  }
  
  void clearOldNotifications({int daysToKeep = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: daysToKeep));
    _notifications.removeWhere((n) => n.createdAt.isBefore(cutoff));
  }
  
  // Internal method to add notifications for testing
  void _addNotificationForTesting(AppNotification notification) {
    _notifications.add(notification);
  }
  
  // Dispose
  void dispose() {
    _notificationStream.close();
  }
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  bool isRead;
  bool isCancelled;
  
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.createdAt,
    this.metadata,
    this.isRead = false,
    this.isCancelled = false,
  });
}

enum NotificationType {
  workoutReminder,
  restTimer,
  achievement,
  personalRecord,
  dailyTip,
  social,
  system
}

void main() {
  group('🔔 Notification Service Tests', () {
    late NotificationService notificationService;
    
    setUp(() {
      notificationService = NotificationService();
    });
    
    tearDown(() {
      notificationService.clearAll();
      notificationService.dispose();
    });
    
    group('📅 Scheduled Notifications', () {
      test('✅ Schedule workout reminder', () async {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));
        final result = await notificationService.scheduleWorkoutReminder(
          scheduledTime: scheduledTime,
          workoutName: 'Chest Day',
          message: 'Time to train chest and triceps!',
        );
        
        expect(result, true);
        expect(notificationService.notifications.length, 1);
        expect(notificationService.notifications.first.type, NotificationType.workoutReminder);
        expect(notificationService.notifications.first.title, contains('Chest Day'));
      });
      
      test('✅ Schedule rest timer notification', () async {
        final result = await notificationService.scheduleRestTimerNotification(
          seconds: 60,
          exerciseName: 'Bench Press',
          setNumber: 2,
        );
        
        expect(result, true);
        expect(notificationService.notifications.length, 1);
        expect(notificationService.notifications.first.type, NotificationType.restTimer);
        expect(notificationService.notifications.first.metadata?['exercise'], 'Bench Press');
        expect(notificationService.notifications.first.metadata?['set'], 2);
      });
      
      test('✅ Immediate notification for past scheduled time', () async {
        final pastTime = DateTime.now().subtract(const Duration(minutes: 1));
        bool notificationReceived = false;
        
        notificationService.notificationStream.listen((notification) {
          notificationReceived = true;
        });
        
        await notificationService.scheduleWorkoutReminder(
          scheduledTime: pastTime,
          workoutName: 'Test Workout',
        );
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(notificationReceived, true);
      });
      
      test('❌ Blocked by preferences - workout reminders', () async {
        await notificationService.updatePreference('workout_reminders', false);
        
        final result = await notificationService.scheduleWorkoutReminder(
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          workoutName: 'Test Workout',
        );
        
        expect(result, false);
        expect(notificationService.notifications.isEmpty, true);
      });
    });
    
    group('🏆 Achievement Notifications', () {
      test('✅ Send achievement notification', () async {
        bool notificationReceived = false;
        
        notificationService.notificationStream.listen((notification) {
          notificationReceived = true;
          expect(notification.type, NotificationType.achievement);
        });
        
        await notificationService.sendAchievementNotification(
          achievement: 'Iron Will',
          description: 'Complete 30 workouts in a month',
        );
        
        expect(notificationService.notifications.length, 1);
        expect(notificationReceived, true);
        expect(notificationService.notifications.first.body, contains('Iron Will'));
      });
      
      test('✅ Send personal record notification', () async {
        await notificationService.sendPersonalRecordNotification(
          exerciseName: 'Squat',
          recordType: 'weight',
          value: 120,
          previousValue: 100,
        );
        
        expect(notificationService.notifications.length, 1);
        expect(notificationService.notifications.first.type, NotificationType.personalRecord);
        expect(notificationService.notifications.first.body, contains('20.0% improvement'));
        expect(notificationService.notifications.first.metadata?['value'], 120);
      });
      
      test('❌ Blocked by preferences - achievements', () async {
        await notificationService.updatePreference('achievement_notifications', false);
        
        await notificationService.sendAchievementNotification(
          achievement: 'Test',
          description: 'Test achievement',
        );
        
        expect(notificationService.notifications.isEmpty, true);
      });
    });
    
    group('💡 Daily Tips', () {
      test('✅ Send daily tip', () async {
        await notificationService.sendDailyTip(
          tip: 'Stay hydrated! Drink water before, during, and after your workout.',
          category: 'hydration',
        );
        
        expect(notificationService.notifications.length, 1);
        expect(notificationService.notifications.first.type, NotificationType.dailyTip);
        expect(notificationService.notifications.first.metadata?['category'], 'hydration');
      });
      
      test('❌ Blocked by preferences - daily tips', () async {
        await notificationService.updatePreference('daily_tips', false);
        
        await notificationService.sendDailyTip(
          tip: 'Test tip',
        );
        
        expect(notificationService.notifications.isEmpty, true);
      });
    });
    
    group('⚙️ Notification Management', () {
      test('✅ Cancel specific notification', () async {
        await notificationService.scheduleWorkoutReminder(
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          workoutName: 'Test',
        );
        
        final notificationId = notificationService.notifications.first.id;
        final result = await notificationService.cancelNotification(notificationId);
        
        expect(result, true);
        expect(notificationService.notifications.first.isCancelled, true);
      });
      
      test('✅ Cancel all scheduled notifications', () async {
        // Schedule multiple notifications
        await notificationService.scheduleWorkoutReminder(
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          workoutName: 'Workout 1',
        );
        await notificationService.scheduleWorkoutReminder(
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          workoutName: 'Workout 2',
        );
        
        await notificationService.cancelAllScheduledNotifications();
        
        final scheduled = notificationService.getScheduledNotifications();
        expect(scheduled.isEmpty, true);
      });
      
      test('✅ Mark notification as read', () async {
        await notificationService.sendDailyTip(tip: 'Test tip');
        
        final notificationId = notificationService.notifications.first.id;
        await notificationService.markAsRead(notificationId);
        
        expect(notificationService.notifications.first.isRead, true);
      });
      
      test('✅ Mark all as read', () async {
        await notificationService.sendDailyTip(tip: 'Tip 1');
        await notificationService.sendDailyTip(tip: 'Tip 2');
        await notificationService.sendDailyTip(tip: 'Tip 3');
        
        await notificationService.markAllAsRead();
        
        final unread = notificationService.getUnreadNotifications();
        expect(unread.isEmpty, true);
      });
    });
    
    group('🔍 Notification Filters', () {
      test('✅ Get unread notifications', () async {
        await notificationService.sendDailyTip(tip: 'Tip 1');
        await notificationService.sendDailyTip(tip: 'Tip 2');
        
        await notificationService.markAsRead(notificationService.notifications.first.id);
        
        final unread = notificationService.getUnreadNotifications();
        expect(unread.length, 1);
      });
      
      test('✅ Get notifications by type', () async {
        await notificationService.sendDailyTip(tip: 'Tip');
        await notificationService.sendAchievementNotification(
          achievement: 'Test',
          description: 'Test',
        );
        await notificationService.scheduleRestTimerNotification(
          seconds: 60,
          exerciseName: 'Test',
          setNumber: 1,
        );
        
        final tips = notificationService.getNotificationsByType(NotificationType.dailyTip);
        final achievements = notificationService.getNotificationsByType(NotificationType.achievement);
        
        expect(tips.length, 1);
        expect(achievements.length, 1);
      });
      
      test('✅ Get scheduled notifications', () async {
        await notificationService.scheduleWorkoutReminder(
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          workoutName: 'Future Workout',
        );
        await notificationService.sendDailyTip(tip: 'Immediate tip');
        
        final scheduled = notificationService.getScheduledNotifications();
        expect(scheduled.length, 1);
        expect(scheduled.first.title, contains('Future Workout'));
      });
      
      test('✅ Get recent notifications', () async {
        await notificationService.sendDailyTip(tip: 'Today');
        await notificationService.sendDailyTip(tip: 'Also today');
        
        final recent = notificationService.getRecentNotifications(days: 1);
        expect(recent.length, 2);
      });
    });
    
    group('⚙️ Preferences Management', () {
      test('✅ Update single preference', () async {
        await notificationService.updatePreference('social_updates', true);
        
        expect(notificationService.preferences['social_updates'], true);
      });
      
      test('✅ Update all preferences', () async {
        await notificationService.updateAllPreferences({
          'workout_reminders': false,
          'rest_timer_alerts': false,
          'achievement_notifications': false,
        });
        
        expect(notificationService.preferences['workout_reminders'], false);
        expect(notificationService.preferences['rest_timer_alerts'], false);
        expect(notificationService.preferences['achievement_notifications'], false);
      });
      
      test('❌ Invalid preference key', () async {
        expect(
          () async => await notificationService.updatePreference('invalid_key', true),
          throwsException,
        );
      });
    });
    
    group('🧹 Cleanup Operations', () {
      test('✅ Clear all notifications', () async {
        await notificationService.sendDailyTip(tip: 'Tip 1');
        await notificationService.sendDailyTip(tip: 'Tip 2');
        
        notificationService.clearAll();
        
        expect(notificationService.notifications.isEmpty, true);
      });
      
      test('✅ Clear old notifications', () async {
        // Manually add old notification for testing
        final oldNotification = AppNotification(
          id: 'old',
          type: NotificationType.dailyTip,
          title: 'Old tip',
          body: 'Old body',
          scheduledTime: DateTime.now().subtract(const Duration(days: 31)),
          createdAt: DateTime.now().subtract(const Duration(days: 31)),
        );
        
        notificationService._addNotificationForTesting(oldNotification);
        await notificationService.sendDailyTip(tip: 'Recent tip');
        
        expect(notificationService.notifications.length, 2);
        
        notificationService.clearOldNotifications(daysToKeep: 30);
        
        expect(notificationService.notifications.length, 1);
        expect(notificationService.notifications.first.body, 'Recent tip');
      });
    });
    
    group('📡 Stream Testing', () {
      test('✅ Receive notifications via stream', () async {
        final receivedNotifications = <AppNotification>[];
        
        final subscription = notificationService.notificationStream.listen((notification) {
          receivedNotifications.add(notification);
        });
        
        await notificationService.sendDailyTip(tip: 'Tip 1');
        await notificationService.sendAchievementNotification(
          achievement: 'Test',
          description: 'Test',
        );
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(receivedNotifications.length, 2);
        expect(receivedNotifications[0].type, NotificationType.dailyTip);
        expect(receivedNotifications[1].type, NotificationType.achievement);
        
        await subscription.cancel();
      });
      
      test('✅ Rest timer triggers after delay', () async {
        bool notificationReceived = false;
        
        notificationService.notificationStream.listen((notification) {
          if (notification.type == NotificationType.restTimer) {
            notificationReceived = true;
          }
        });
        
        await notificationService.scheduleRestTimerNotification(
          seconds: 1, // 1 second for testing
          exerciseName: 'Test Exercise',
          setNumber: 1,
        );
        
        // Wait for timer to trigger
        await Future.delayed(const Duration(milliseconds: 1100));
        
        expect(notificationReceived, true);
      });
    });
  });
}