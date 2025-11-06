import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

// ============= STATE MODELS =============

class NotificationState {

  const NotificationState({
    required this.notifications,
    required this.preferences,
    required this.isInitialized,
    required this.unreadCount,
    this.error,
    this.isLoading = false,
  });

  factory NotificationState.initial() {
    return NotificationState(
      notifications: [],
      preferences: NotificationPreferences.defaultPreferences(),
      isInitialized: false,
      unreadCount: 0,
    );
  }
  final List<AppNotification> notifications;
  final NotificationPreferences preferences;
  final bool isInitialized;
  final int unreadCount;
  final String? error;
  final bool isLoading;

  NotificationState copyWith({
    List<AppNotification>? notifications,
    NotificationPreferences? preferences,
    bool? isInitialized,
    int? unreadCount,
    String? error,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
      isInitialized: isInitialized ?? this.isInitialized,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationPreferences {

  const NotificationPreferences({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.categories,
    required this.quietHours,
    required this.frequency,
    this.updatedAt,
  });

  factory NotificationPreferences.defaultPreferences() {
    return const NotificationPreferences(
      pushEnabled: true,
      emailEnabled: true,
      categories: {
        'achievement': true,
        'milestone': true,
        'reminder': true,
        'progress': true,
        'social': true,
        'system': true,
        'marketing': false,
      },
      quietHours: QuietHours(
        enabled: true,
        start: '22:00',
        end: '08:00',
      ),
      frequency: FrequencySettings(
        achievements: AchievementFrequency.instant,
        reminders: ReminderFrequency.daily,
        marketing: MarketingFrequency.disabled,
      ),
    );
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      categories: Map<String, bool>.from(json['categories'] ?? {}),
      quietHours: QuietHours.fromJson(json['quietHours'] ?? {}),
      frequency: FrequencySettings.fromJson(json['frequency'] ?? {}),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
  final bool pushEnabled;
  final bool emailEnabled;
  final Map<String, bool> categories;
  final QuietHours quietHours;
  final FrequencySettings frequency;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'categories': categories,
      'quietHours': quietHours.toJson(),
      'frequency': frequency.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    Map<String, bool>? categories,
    QuietHours? quietHours,
    FrequencySettings? frequency,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      categories: categories ?? this.categories,
      quietHours: quietHours ?? this.quietHours,
      frequency: frequency ?? this.frequency,
      updatedAt: DateTime.now(),
    );
  }
}

class QuietHours {   // "08:00"

  const QuietHours({
    required this.enabled,
    required this.start,
    required this.end,
  });

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      enabled: json['enabled'] ?? true,
      start: json['start'] ?? '22:00',
      end: json['end'] ?? '08:00',
    );
  }
  final bool enabled;
  final String start; // "22:00"
  final String end;

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'start': start,
      'end': end,
    };
  }
}

class FrequencySettings {

  const FrequencySettings({
    required this.achievements,
    required this.reminders,
    required this.marketing,
  });

  factory FrequencySettings.fromJson(Map<String, dynamic> json) {
    return FrequencySettings(
      achievements: AchievementFrequency.values.byName(
        json['achievements'] ?? 'instant'
      ),
      reminders: ReminderFrequency.values.byName(
        json['reminders'] ?? 'daily'
      ),
      marketing: MarketingFrequency.values.byName(
        json['marketing'] ?? 'disabled'
      ),
    );
  }
  final AchievementFrequency achievements;
  final ReminderFrequency reminders;
  final MarketingFrequency marketing;

  Map<String, dynamic> toJson() {
    return {
      'achievements': achievements.name,
      'reminders': reminders.name,
      'marketing': marketing.name,
    };
  }
}

enum AchievementFrequency { instant, daily, weekly, disabled }
enum ReminderFrequency { daily, weekly, disabled }
enum MarketingFrequency { enabled, disabled }

enum NotificationInteractionType { clicked, dismissed, read }

// ============= DEPRECATED PROVIDER =============

/// DEPRECATED: This legacy provider has confusing naming and will be removed
/// Use the actual unified_notification_provider.dart instead
/// This file maintains old FCM logic for backward compatibility during migration
@Deprecated('This is the legacy provider with confusing naming. Use unified_notification_provider.dart instead.')
final legacyUnifiedNotificationProvider = StateNotifierProvider<LegacyUnifiedNotificationNotifier, NotificationState>((ref) {
  return LegacyUnifiedNotificationNotifier(ref);
});

// ============= DEPRECATED COMPUTED PROVIDERS =============

@Deprecated('Use unreadNotificationCountProvider from unified_notification_provider.dart')
final legacyUnreadNotificationCountProvider = Provider<int>((ref) {
  final state = ref.watch(legacyUnifiedNotificationProvider);
  return state.unreadCount;
});

@Deprecated('Use todayNotificationsProvider from unified_notification_provider.dart')
final legacyRecentNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final state = ref.watch(legacyUnifiedNotificationProvider);
  final now = DateTime.now();
  
  return state.notifications
      .where((n) => now.difference(n.createdAt).inHours < 24)
      .take(10)
      .toList();
});

@Deprecated('Use computed providers from unified_notification_provider.dart')
final legacyNotificationsByTypeProvider = Provider.family<List<AppNotification>, NotificationType>((ref, type) {
  final state = ref.watch(legacyUnifiedNotificationProvider);
  return state.notifications.where((n) => n.type == type).toList();
});

// ============= DEPRECATED MAIN NOTIFIER =============

@Deprecated('Use UnifiedNotificationProvider from unified_notification_provider.dart')
class LegacyUnifiedNotificationNotifier extends StateNotifier<NotificationState> {

  LegacyUnifiedNotificationNotifier(this.ref) :
    _boxManager = ref.read(hiveBoxManagerProvider),
    super(NotificationState.initial()) {
    _initCompleter = Completer<void>();
    _initializeNotifications();
  }
  final Ref ref;
  final HiveBoxManagerEnhanced _boxManager;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CRITICAL: Initialization tracking (GOLD STANDARD pattern)
  bool _isInitialized = false;
  bool _isDisposed = false;
  Completer<void>? _initCompleter;
  int _initRetryCount = 0;
  static const int _maxInitRetries = 3;

  // CRITICAL: Resource tracking for disposal
  StreamSubscription<String>? _tokenRefreshSubscription;

  // ============= INITIALIZATION =============

  Future<void> _initializeNotifications() async {
    try {
      if (kDebugMode) {
        debugPrint('🔔 [LegacyNotification] Starting initialization (attempt ${_initRetryCount + 1})');
      }

      state = state.copyWith(isLoading: true);

      // Request permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize FCM
      await _initializeFCM();

      // Load preferences and notifications
      await Future.wait([
        _loadNotificationPreferences(),
        _loadNotifications(),
      ]);

      // Setup background message handler
      FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

      // Setup foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Setup notification interaction handler
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationInteraction);

      // Handle initial message (app opened from terminated state)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationInteraction(initialMessage);
      }

      // Setup real-time listener for notifications
      _setupNotificationListener();

      _isInitialized = true;
      _initRetryCount = 0;
      _initCompleter?.complete();

      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        error: null,
      );

      if (kDebugMode) {
        debugPrint('✅ [LegacyNotification] Initialization completed successfully');
      }

    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [LegacyNotification] Initialization failed (attempt ${_initRetryCount + 1}): $error');
        debugPrint('📍 Stack trace: $stackTrace');
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize notifications: $error',
      );

      if (!_initCompleter!.isCompleted) {
        _initCompleter?.completeError(error, stackTrace);
      }
    }
  }

  /// CRITICAL: Ensure initialization (GOLD STANDARD pattern)
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (_initRetryCount >= _maxInitRetries) {
      throw Exception('Legacy notification initialization failed after $_maxInitRetries attempts');
    }
    if (_initCompleter != null) {
      try {
        await _initCompleter!.future.timeout(const Duration(seconds: 15));
      } catch (e) {
        _initRetryCount++;
        _initCompleter = Completer<void>();
        await _initializeNotifications();
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Request notification permission
      final notificationStatus = await Permission.notification.request();
      
      // Request FCM permission
      final fcmSettings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (fcmSettings.authorizationStatus == AuthorizationStatus.denied) {
        throw Exception('Push notification permission denied');
      }

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Permission request failed: $error');
      }
      // Continue initialization even if permissions are denied
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleLocalNotificationTap,
      );

      // Create notification channels for Android
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Local notifications initialization failed: $error');
      }
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final channels = [
        const AndroidNotificationChannel(
          'achievements',
          'Achievements',
          description: 'Notifications for workout achievements and milestones',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('achievement_sound'),
        ),
        const AndroidNotificationChannel(
          'reminders',
          'Workout Reminders',
          description: 'Reminders to workout and stay active',
          importance: Importance.defaultImportance,
          sound: RawResourceAndroidNotificationSound('reminder_sound'),
        ),
        const AndroidNotificationChannel(
          'progress',
          'Progress Updates',
          description: 'Updates on your fitness progress and improvements',
          importance: Importance.defaultImportance,
        ),
        const AndroidNotificationChannel(
          'social',
          'Social',
          description: 'Social interactions and community updates',
          importance: Importance.defaultImportance,
        ),
        const AndroidNotificationChannel(
          'system',
          'System',
          description: 'Important system notifications',
          importance: Importance.high,
        ),
        const AndroidNotificationChannel(
          'marketing',
          'Marketing',
          description: 'Promotional and marketing messages',
          importance: Importance.low,
        ),
      ];

      for (final channel in channels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }

  Future<void> _initializeFCM() async {
    try {
      // Get FCM token
      final token = await _fcm.getToken();
      if (token != null) {
        await _saveFCMToken(token);
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen(_saveFCMToken);

    } catch (error) {
      if (kDebugMode) {
        debugPrint('FCM initialization failed: $error');
      }
    }
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.uid == null) return;

      final deviceInfo = _getDeviceInfo();

      await _firestore
          .collection('notification_subscriptions')
          .doc(currentUser!.uid)
          .set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'deviceInfo': deviceInfo,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to save FCM token: $error');
      }
    }
  }

  Map<String, dynamic> _getDeviceInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isPhysicalDevice': true, // You might want to use device_info_plus for more details
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // ============= DATA LOADING =============

  Future<void> _loadNotificationPreferences() async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.uid == null) return;

      final doc = await _firestore
          .collection('notification_preferences')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        final preferences = NotificationPreferences.fromJson(doc.data()!);
        state = state.copyWith(preferences: preferences);
      } else {
        // Create default preferences
        await updateNotificationPreferences(NotificationPreferences.defaultPreferences());
      }

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to load preferences: $error');
      }
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.uid == null) return;

      // Try to load from cache first (for offline support)
      final cachedNotifications = await _getCachedNotifications();
      if (cachedNotifications.isNotEmpty) {
        _updateNotificationsState(cachedNotifications);
      }

      // Load fresh data from Firestore
      final snapshot = await _firestore
          .collection('user_notifications')
          .doc(currentUser!.uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      _updateNotificationsState(notifications);

      // Cache the notifications
      await _cacheNotifications(notifications);

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to load notifications: $error');
      }
      
      // Fall back to cached data if available
      final cachedNotifications = await _getCachedNotifications();
      if (cachedNotifications.isNotEmpty) {
        _updateNotificationsState(cachedNotifications);
      }
    }
  }

  void _setupNotificationListener() {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser?.uid == null) return;

    _firestore
        .collection('user_notifications')
        .doc(currentUser!.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
          (snapshot) {
            final notifications = snapshot.docs
                .map((doc) => AppNotification.fromJson({
                      ...doc.data(),
                      'id': doc.id,
                    }))
                .toList();

            _updateNotificationsState(notifications);
          },
          onError: (error) {
            if (kDebugMode) {
              debugPrint('Notification listener error: $error');
            }
          },
        );
  }

  void _updateNotificationsState(List<AppNotification> notifications) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    
    state = state.copyWith(
      notifications: notifications,
      unreadCount: unreadCount,
    );
  }

  // ============= NOTIFICATION HANDLERS =============

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('Handling background message: ${message.messageId}');
    }
    
    // Handle background notification logic
    // This runs when the app is in the background or terminated
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      if (kDebugMode) {
        debugPrint('Handling foreground message: ${message.messageId}');
      }

      // Show local notification when app is in foreground
      await _showLocalNotification(message);

      // Mark as delivered in analytics
      await _recordNotificationDelivered(message);

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error handling foreground message: $error');
      }
    }
  }

  Future<void> _handleNotificationInteraction(RemoteMessage message) async {
    try {
      if (kDebugMode) {
        debugPrint('Handling notification interaction: ${message.messageId}');
      }

      final notificationId = message.data['notificationId'];
      if (notificationId != null) {
        await markNotificationInteraction(
          notificationId,
          NotificationInteractionType.clicked,
        );

        // Navigate to appropriate screen based on notification type
        _navigateBasedOnNotification(message);
      }

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error handling notification interaction: $error');
      }
    }
  }

  Future<void> _handleLocalNotificationTap(NotificationResponse response) async {
    try {
      final payload = response.payload;
      if (payload != null) {
        final data = json.decode(payload) as Map<String, dynamic>;
        final notificationId = data['notificationId'];
        
        if (notificationId != null) {
          await markNotificationInteraction(
            notificationId,
            NotificationInteractionType.clicked,
          );
        }
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error handling local notification tap: $error');
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      const androidDetails = AndroidNotificationDetails(
        'default',
        'Default',
        channelDescription: 'Default notification channel',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notification.title,
        notification.body,
        details,
        payload: json.encode(message.data),
      );

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error showing local notification: $error');
      }
    }
  }

  void _navigateBasedOnNotification(RemoteMessage message) {
    // Implement navigation logic based on notification type
    // This would integrate with your app's routing system
    final type = message.data['type'];
    
    switch (type) {
      case 'achievement':
        // Navigate to achievements page
        break;
      case 'workout_reminder':
        // Navigate to workout page
        break;
      case 'progress':
        // Navigate to progress page
        break;
      default:
        // Navigate to notifications page
        break;
    }
  }

  // ============= PUBLIC API =============

  Future<void> updateNotificationPreferences(NotificationPreferences preferences) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.uid == null) return;

      await _firestore
          .collection('notification_preferences')
          .doc(currentUser!.uid)
          .set(preferences.toJson());

      state = state.copyWith(preferences: preferences);

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to update preferences: $error');
      }
      state = state.copyWith(error: 'Failed to update preferences');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;
      await markNotificationInteraction(notificationId, NotificationInteractionType.read);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to mark notification as read: $error');
      }
    }
  }

  Future<void> markNotificationInteraction(
    String notificationId,
    NotificationInteractionType type,
  ) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.uid == null) return;

      final timestamp = FieldValue.serverTimestamp();

      // Update user notification
      await _firestore
          .collection('user_notifications')
          .doc(currentUser!.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({
        'lastInteractionAt': timestamp,
        '${type.name}At': timestamp,
        if (type == NotificationInteractionType.clicked ||
            type == NotificationInteractionType.read)
          'isRead': true,
      });

      // Record analytics
      await _firestore.collection('notification_analytics').add({
        'userId': currentUser.uid,
        'notificationId': notificationId,
        'interactionType': type.name,
        'timestamp': timestamp,
        'deviceInfo': _getDeviceInfo(),
      });

      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(
            isRead: type == NotificationInteractionType.clicked ||
                   type == NotificationInteractionType.read,
          );
        }
        return notification;
      }).toList();

      _updateNotificationsState(updatedNotifications);

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to mark interaction: $error');
      }
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.uid == null) return;

      final batch = _firestore.batch();
      
      for (final notification in state.notifications.where((n) => !n.isRead)) {
        final docRef = _firestore
            .collection('user_notifications')
            .doc(currentUser!.uid)
            .collection('notifications')
            .doc(notification.id);
        
        batch.update(docRef, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      _updateNotificationsState(updatedNotifications);

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to mark all as read: $error');
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.uid == null) return;

      await _firestore
          .collection('user_notifications')
          .doc(currentUser!.uid)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      // Update local state
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      _updateNotificationsState(updatedNotifications);

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to delete notification: $error');
      }
    }
  }

  // ============= OFFLINE SUPPORT =============

  Future<List<AppNotification>> _getCachedNotifications() async {
    try {
      final box = await _boxManager.openBox<AppNotification>('cached_notifications');
      return box.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to get cached notifications: $error');
      }
      return [];
    }
  }

  Future<void> _cacheNotifications(List<AppNotification> notifications) async {
    try {
      final box = await _boxManager.openBox<AppNotification>('cached_notifications');
      await box.clear();
      
      for (final notification in notifications.take(50)) {
        await box.put(notification.id, notification);
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to cache notifications: $error');
      }
    }
  }

  // ============= ANALYTICS =============

  Future<void> _recordNotificationDelivered(RemoteMessage message) async {
    try {
      final notificationId = message.data['notificationId'];
      if (notificationId == null) return;

      await _firestore.collection('notification_analytics').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'notificationId': notificationId,
        'interactionType': 'delivered',
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': _getDeviceInfo(),
        'fcmMessageId': message.messageId,
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to record delivery: $error');
      }
    }
  }

  // ============= GDPR COMPLIANCE =============

  Future<void> revokeNotificationConsent() async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.uid == null) return;

      // Remove FCM tokens
      await _firestore
          .collection('notification_subscriptions')
          .doc(currentUser!.uid)
          .delete();

      // Update preferences to disable all notifications
      final restrictedPreferences = state.preferences.copyWith(
        pushEnabled: false,
        emailEnabled: false,
        categories: state.preferences.categories.map((key, value) => MapEntry(key, false)),
      );

      await updateNotificationPreferences(restrictedPreferences);

      // Log compliance action
      await _firestore
          .collection('notification_compliance_logs')
          .add({
        'userId': currentUser.uid,
        'action': 'consent_revoked',
        'timestamp': FieldValue.serverTimestamp(),
        'details': {
          'previousPreferences': state.preferences.toJson(),
          'newPreferences': restrictedPreferences.toJson(),
        },
      });

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to revoke consent: $error');
      }
      state = state.copyWith(error: 'Failed to revoke notification consent');
    }
  }

  Future<Map<String, dynamic>> exportNotificationData() async {
    try {
      await _ensureInitialized();
      if (_isDisposed) throw Exception('Provider disposed');
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.uid == null) {
        throw Exception('User not authenticated');
      }

      // Collect all notification-related data
      final results = await Future.wait([
        _exportNotifications(currentUser!.uid),
        _exportPreferences(currentUser.uid),
        _exportAnalytics(currentUser.uid),
      ]);
      final notifications = results[0] as List<Map<String, dynamic>>;
      final preferences = results[1] as Map<String, dynamic>;
      final analytics = results[2] as List<Map<String, dynamic>>;

      final exportData = {
        'userId': currentUser.uid,
        'exportTimestamp': DateTime.now().toIso8601String(),
        'notifications': notifications,
        'preferences': preferences,
        'analytics': analytics,
      };

      // Log export action
      await _firestore
          .collection('notification_compliance_logs')
          .add({
        'userId': currentUser.uid,
        'action': 'data_exported',
        'timestamp': FieldValue.serverTimestamp(),
        'details': {
          'notificationCount': notifications.length,
          'analyticsCount': analytics.length,
        },
      });

      return exportData;

    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to export data: $error');
      }
      throw Exception('Failed to export notification data');
    }
  }

  Future<List<Map<String, dynamic>>> _exportNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('user_notifications')
        .doc(userId)
        .collection('notifications')
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  Future<Map<String, dynamic>> _exportPreferences(String userId) async {
    final doc = await _firestore
        .collection('notification_preferences')
        .doc(userId)
        .get();

    return doc.exists ? doc.data()! : {};
  }

  Future<List<Map<String, dynamic>>> _exportAnalytics(String userId) async {
    final snapshot = await _firestore
        .collection('notification_analytics')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// CRITICAL: Dispose method for resource cleanup
  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('🧹 [LegacyNotification] Starting disposal');
    }

    _isDisposed = true;

    try {
      // Cancel token refresh listener
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = null;

      // Note: FCM listeners (onMessage, onMessageOpenedApp) cannot be cancelled
      // They are static and handled by Firebase internally

      // Note: Firestore snapshot listener from _setupNotificationListener()
      // is not tracked, consider adding StreamSubscription tracking if needed

      _initCompleter = null;

      if (kDebugMode) {
        debugPrint('✅ [LegacyNotification] Disposal completed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [LegacyNotification] Error during disposal: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    } finally {
      super.dispose();
    }
  }
}