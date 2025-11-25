import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';

/// Background message handler - MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed
  // await Firebase.initializeApp();
  
  if (kDebugMode) {
    debugPrint('[FCM] Handling background message: ${message.messageId}');
  }
  
  // Process the message
  // Note: Can't access providers here since it's isolate
  await FCMService._handleBackgroundMessage(message);
}

/// Firebase Cloud Messaging Service
/// ✅ BEST PRACTICE 2024-2025: Uses callback pattern for navigation
class FCMService {

  factory FCMService(
    FlutterLocalNotificationsPlugin localNotifications, {
    void Function(Map<String, dynamic> payload)? onNotificationTapped,
  }) {
    _instance ??= FCMService._internal(localNotifications, onNotificationTapped);
    return _instance!;
  }

  FCMService._internal(this._localNotifications, this._onNotificationTapped) {
    _messageStreamController = StreamController<UnifiedNotification>.broadcast();
  }
  static FCMService? _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final void Function(Map<String, dynamic> payload)? _onNotificationTapped;

  StreamController<UnifiedNotification>? _messageStreamController;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  String? _fcmToken;
  bool _isInitialized = false;
  bool _isDisposed = false;
  
  /// Stream of incoming notifications
  Stream<UnifiedNotification> get notificationStream => 
      _messageStreamController?.stream ?? const Stream.empty();
  
  /// Current FCM token
  String? get fcmToken => _fcmToken;
  
  /// Initialize FCM
  Future<void> initialize() async {
    if (_isInitialized || _isDisposed) return;
    
    try {
      // Request permissions
      final settings = await _requestPermissions();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          debugPrint('[FCM]' 'FCM permissions granted');
        }
        
        // Get FCM token
        _fcmToken = await _getToken();

        // ✅ FIXED: Save initial token to backend
        if (_fcmToken != null) {
          await _sendTokenToBackend(_fcmToken!);
        }

        // Setup message handlers
        await _setupMessageHandlers();

        // Setup token refresh
        _setupTokenRefresh();

        _isInitialized = true;

        if (kDebugMode) {
          debugPrint('[FCM] FCM initialized with token: ${_fcmToken?.substring(0, 10)}...');
        }
      } else {
        if (kDebugMode) {
          debugPrint('[FCM] FCM permissions denied: ${settings.authorizationStatus}');
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[FCM] FCM initialization failed: $e\n$stack');
      }
    }
  }
  
  /// Request notification permissions
  Future<NotificationSettings> _requestPermissions() async {
    return await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
  
  /// Get FCM token
  Future<String?> _getToken() async {
    try {
      if (Platform.isIOS) {
        // On iOS, get APNS token first
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          if (kDebugMode) {
            debugPrint('[FCM] APNS token not available, waiting...');
          }
          // Wait a bit and retry
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] Failed to get FCM token: $e');
      }
      return null;
    }
  }
  
  /// Setup message handlers
  Future<void> _setupMessageHandlers() async {
    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Foreground message handler
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
      onError: (error) {
        if (kDebugMode) {
          debugPrint('[FCM] Foreground message error: $error');
        }
      },
    );
    
    // Message opened handler (when user taps notification)
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageOpened,
      onError: (error) {
        if (kDebugMode) {
          debugPrint('[FCM] Message opened error: $error');
        }
      },
    );
    
    // Check if app was opened from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpened(initialMessage);
    }
  }
  
  /// Setup token refresh listener
  void _setupTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) {
        debugPrint('[FCM] FCM token refreshed: ${newToken.substring(0, 10)}...');
      }

      // TODO: Send new token to backend
      _sendTokenToBackend(newToken);
    });
  }
  
  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM] Foreground message received: ${message.messageId}');
    }

    // Convert to UnifiedNotification
    final notification = _convertToUnifiedNotification(message);

    // Add to stream
    _messageStreamController?.add(notification);

    // Show local notification
    _showLocalNotification(notification);
  }
  
  /// Handle message opened (user tapped notification)
  void _handleMessageOpened(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM] Message opened: ${message.messageId}');
    }

    // Convert to UnifiedNotification
    final notification = _convertToUnifiedNotification(message);

    // Handle navigation based on data
    _handleNotificationTap(notification);
  }
  
  /// Handle background messages (static for isolate)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Note: Can't access instance variables or providers here
    // This runs in a separate isolate

    // Log the message
    if (kDebugMode) {
      debugPrint('Background message: ${message.messageId}');
      debugPrint('Data: ${message.data}');
    }

    // You can store to local storage or database here if needed
    // But can't update UI directly
  }
  
  /// Convert RemoteMessage to UnifiedNotification
  UnifiedNotification _convertToUnifiedNotification(RemoteMessage message) {
    // Determine notification type from data
    final typeString = message.data['type'] as String?;
    final type = _parseNotificationType(typeString);
    
    return UnifiedNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: message.notification?.title ?? 'GymBro Notification',
      body: message.notification?.body ?? '',
      scheduledTime: DateTime.now(),
      status: NotificationDeliveryStatus.delivered,
      payload: message.data,
      priority: _parsePriority(message),
      soundName: message.notification?.android?.sound ?? 
                 message.notification?.apple?.sound?.name,
    );
  }
  
  /// Parse notification type from string
  NotificationType _parseNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'timer_complete':
        return NotificationType.timerComplete;
      case 'workout_reminder':
        return NotificationType.workoutReminder;
      case 'achievement':
        return NotificationType.achievementUnlocked;
      case 'progress':
        return NotificationType.progressMilestone;
      case 'ai_tip':
        return NotificationType.coachMessage;
      case 'milestone':
        return NotificationType.progressMilestone;
      case 'social':
        return NotificationType.friendActivity;
      default:
        return NotificationType.systemUpdate;
    }
  }
  
  /// Parse priority from RemoteMessage
  NotificationPriority _parsePriority(RemoteMessage message) {
    // Check Android priority
    final androidPriority = message.notification?.android?.priority;
    if (androidPriority == AndroidNotificationPriority.highPriority) {
      return NotificationPriority.high;
    }
    
    // Check custom data
    final priorityString = message.data['priority'] as String?;
    switch (priorityString?.toLowerCase()) {
      case 'critical':
        return NotificationPriority.critical;
      case 'high':
        return NotificationPriority.high;
      case 'low':
        return NotificationPriority.low;
      default:
        return NotificationPriority.normal;
    }
  }
  
  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(UnifiedNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'fcm_default_channel',
      'FCM Notifications',
      channelDescription: 'Push notifications from server',
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
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: notification.id,
    );
  }
  
  /// Handle notification tap navigation
  /// ✅ BEST PRACTICE 2024-2025: Uses callback pattern for navigation
  /// Repository/Service layer should not have direct access to routing
  void _handleNotificationTap(UnifiedNotification notification) {
    if (_onNotificationTapped == null) {
      if (kDebugMode) {
        debugPrint('[FCM] ⚠️ No navigation callback set');
      }
      return;
    }

    // Build payload for navigation callback
    final payload = <String, dynamic>{
      'type': notification.type.name,
      '_notificationId': notification.id,
      '_scheduledAt': notification.scheduledTime.toIso8601String(),
      ...?notification.payload,
    };

    // Fire callback with delay to prevent race condition with screen lifecycle
    Future.delayed(const Duration(milliseconds: 100), () {
      _onNotificationTapped(payload);
    });

    if (kDebugMode) {
      debugPrint('[FCM] ✅ Notification tap handled: ${notification.type.name}');
    }
  }
  
  /// Send token to backend (Firestore)
  /// ✅ FIXED: Now properly saves FCM token to Firestore
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (kDebugMode) {
          debugPrint('[FCM] Cannot save token: User not authenticated');
        }
        return;
      }

      // Save token to Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': Platform.isIOS ? 'ios' : 'android',
      }, SetOptions(merge: true));

      if (kDebugMode) {
        debugPrint('[FCM] Token saved to Firestore for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] Failed to save token to backend: $e');
      }
      // Don't throw - token save failure shouldn't break the app
    }
  }
  
  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (!_isInitialized || _isDisposed) return;
    
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        debugPrint('[FCM] Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] Failed to subscribe to topic $topic: $e');
      }
    }
  }
  
  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_isInitialized || _isDisposed) return;

    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        debugPrint('[FCM] Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] Failed to unsubscribe from topic $topic: $e');
      }
    }
  }
  
  /// Delete token (logout)
  Future<void> deleteToken() async {
    if (_isDisposed) return;

    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      if (kDebugMode) {
        debugPrint('[FCM] FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] Failed to delete FCM token: $e');
      }
    }
  }
  
  /// Dispose service
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _isInitialized = false;

    _foregroundMessageSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
    _messageStreamController?.close();

    _foregroundMessageSubscription = null;
    _messageOpenedSubscription = null;
    _messageStreamController = null;

    if (kDebugMode) {
      debugPrint('[FCM] FCM service disposed');
    }
  }
}

/// Provider for FCM service
/// ✅ BEST PRACTICE 2024-2025: Moved to notification_providers.dart
/// This provider is kept for backward compatibility but the main provider
/// with navigation callback is defined in notification_providers.dart
final fcmServiceProvider = Provider<FCMService>((ref) {
  // Get local notifications plugin from somewhere
  // This is a simplified version - you'd get it from another provider
  final localNotifications = FlutterLocalNotificationsPlugin();

  final service = FCMService(
    localNotifications,
    // Note: Navigation callback should be set via notification_providers.dart
    // where GoRouter is accessible
  );

  // Initialize on creation
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});