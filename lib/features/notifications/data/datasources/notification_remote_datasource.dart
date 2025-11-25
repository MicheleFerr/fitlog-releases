/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/data/datasources
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: datasource
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// REMOTE DATA SOURCE - Firestore persistence & cross-device sync
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart' hide NotificationType;
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';

/// Remote data source for notification persistence (Firestore)
///
/// **Responsibilities**:
/// - Read/write NotificationSettings v2.0 to Firestore
/// - Cross-device sync with server timestamps
/// - Notification history persistence (90-day TTL)
/// - Real-time streams for settings changes
///
/// **Firestore Schema**:
/// ```
/// users/{userId}/notificationSettings (document)
/// users/{userId}/notificationHistory/{notificationId} (collection)
/// users/{userId}/notificationDelivery/{notificationId} (collection)
/// users/{userId}/notificationMetrics (document)
/// ```
class NotificationRemoteDataSource {

  NotificationRemoteDataSource({
    required FirebaseFirestore firestore,
    required String? userId,
  })  : _firestore = firestore,
        _userId = userId;
  final FirebaseFirestore _firestore;
  final String? _userId;

  // Collection/document paths
  // Settings and metrics are documents (4 segments: collection/doc/collection/doc)
  String? get _settingsPath => _userId != null ? 'users/$_userId/settings/notifications' : null;
  String? get _metricsPath => _userId != null ? 'users/$_userId/settings/metrics' : null;

  // History and delivery are collections (3 segments: collection/doc/collection)
  String? get _historyPath => _userId != null ? 'users/$_userId/notificationHistory' : null;
  String? get _deliveryPath => _userId != null ? 'users/$_userId/notificationDelivery' : null;

  // === NotificationSettings Operations ===

  /// Save NotificationSettings to Firestore (with server timestamp)
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    if (_settingsPath == null) {
      debugPrint('⚠️ Cannot save to Firestore: User not authenticated');
      return; // Silently skip if user not authenticated
    }

    try {
      final json = settings.toJson();

      // Add server timestamp for conflict resolution
      json['lastSyncedAt'] = FieldValue.serverTimestamp();
      json['deviceId'] = settings.deviceId ?? 'unknown';

      await _firestore.doc(_settingsPath!).set(
            json,
            SetOptions(merge: true), // Merge to preserve existing data
          );

      debugPrint('✅ Saved notification settings to Firestore');
    } catch (e) {
      debugPrint('❌ Failed to save notification settings to Firestore: $e');
      rethrow;
    }
  }

  /// Get NotificationSettings from Firestore
  Future<NotificationSettings?> getNotificationSettings() async {
    if (_settingsPath == null) {
      debugPrint('⚠️ Cannot get from Firestore: User not authenticated');
      return null; // Return null if user not authenticated
    }

    try {
      final doc = await _firestore.doc(_settingsPath!).get();

      if (!doc.exists) {
        debugPrint('⚠️ No notification settings found in Firestore');
        return null;
      }

      final data = doc.data();
      if (data == null) return null;

      // Convert Timestamp to DateTime for lastSyncedAt
      if (data['lastSyncedAt'] is Timestamp) {
        data['lastSyncedAt'] =
            (data['lastSyncedAt'] as Timestamp).toDate();
      }

      // Convert Timestamp to DateTime for consentTimestamp
      if (data['consentTimestamp'] is Timestamp) {
        data['consentTimestamp'] =
            (data['consentTimestamp'] as Timestamp).toDate();
      }

      // Convert Timestamp to DateTime for customTime
      if (data['customTime'] is Timestamp) {
        data['customTime'] =
            (data['customTime'] as Timestamp).toDate();
      }

      // Convert Timestamp to DateTime for doNotDisturbStart/End
      if (data['doNotDisturbStart'] is Timestamp) {
        data['doNotDisturbStart'] =
            (data['doNotDisturbStart'] as Timestamp).toDate();
      }
      if (data['doNotDisturbEnd'] is Timestamp) {
        data['doNotDisturbEnd'] =
            (data['doNotDisturbEnd'] as Timestamp).toDate();
      }

      return NotificationSettings.fromJson(data);
    } catch (e) {
      debugPrint('❌ Failed to get notification settings from Firestore: $e');
      return null;
    }
  }

  /// Watch NotificationSettings for real-time updates
  Stream<NotificationSettings?> watchNotificationSettings() {
    if (_settingsPath == null) {
      debugPrint('⚠️ Cannot watch Firestore: User not authenticated');
      return Stream.value(null); // Return stream with null if not authenticated
    }

    return _firestore.doc(_settingsPath!).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null) return null;

      // Convert Timestamps to DateTime (same logic as get)
      if (data['lastSyncedAt'] is Timestamp) {
        data['lastSyncedAt'] =
            (data['lastSyncedAt'] as Timestamp).toDate();
      }
      if (data['consentTimestamp'] is Timestamp) {
        data['consentTimestamp'] =
            (data['consentTimestamp'] as Timestamp).toDate();
      }
      if (data['customTime'] is Timestamp) {
        data['customTime'] =
            (data['customTime'] as Timestamp).toDate();
      }
      if (data['doNotDisturbStart'] is Timestamp) {
        data['doNotDisturbStart'] =
            (data['doNotDisturbStart'] as Timestamp).toDate();
      }
      if (data['doNotDisturbEnd'] is Timestamp) {
        data['doNotDisturbEnd'] =
            (data['doNotDisturbEnd'] as Timestamp).toDate();
      }

      try {
        return NotificationSettings.fromJson(data);
      } catch (e) {
        debugPrint('⚠️ Failed to parse notification settings from stream: $e');
        return null;
      }
    });
  }

  /// Delete NotificationSettings from Firestore
  Future<void> deleteNotificationSettings() async {
    if (_settingsPath == null) {
      debugPrint('⚠️ Cannot delete from Firestore: User not authenticated');
      return;
    }

    try {
      await _firestore.doc(_settingsPath!).delete();
      debugPrint('✅ Deleted notification settings from Firestore');
    } catch (e) {
      debugPrint(
          '❌ Failed to delete notification settings from Firestore: $e');
      rethrow;
    }
  }

  // === Notification History Operations ===

  /// Save notification to history
  Future<void> saveNotificationHistory(UnifiedNotification notification) async {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot save to history: User not authenticated');
      return;
    }

    try {
      final json = notification.toJson();

      // Add expiration timestamp (90 days from now by default)
      final expiresAt = DateTime.now().add(const Duration(days: 90));
      json['expiresAt'] = Timestamp.fromDate(expiresAt);

      await _firestore.doc('$_historyPath/${notification.id}').set(json);

      debugPrint('✅ Saved notification ${notification.id} to history');
    } catch (e) {
      debugPrint('❌ Failed to save notification to history: $e');
      rethrow;
    }
  }

  /// Get notification history with filters
  Future<List<UnifiedNotification>> getNotificationHistory({
    int limit = 50,
    DateTime? since,
    DateTime? until,
    List<NotificationType>? types,
    bool unreadOnly = false,
  }) async {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot get history: User not authenticated');
      return []; // Return empty list if not authenticated
    }

    try {
      Query query = _firestore.collection(_historyPath!);

      // Apply filters
      if (since != null) {
        query = query.where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(since));
      }
      if (until != null) {
        query = query.where('scheduledTime',
            isLessThanOrEqualTo: Timestamp.fromDate(until));
      }
      if (types != null && types.isNotEmpty) {
        final typeNames = types.map((NotificationType t) => t.name).toList();
        query = query.where('type', whereIn: typeNames);
      }
      if (unreadOnly) {
        query = query.where('isRead', isEqualTo: false);
      }

      // Order by scheduled time (newest first)
      query = query.orderBy('scheduledTime', descending: true);

      // Limit results
      query = query.limit(limit);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Timestamps to DateTime
        if (data['scheduledTime'] is Timestamp) {
          data['scheduledTime'] =
              (data['scheduledTime'] as Timestamp).toDate().toIso8601String();
        }
        if (data['deliveredAt'] is Timestamp) {
          data['deliveredAt'] =
              (data['deliveredAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['readAt'] is Timestamp) {
          data['readAt'] =
              (data['readAt'] as Timestamp).toDate().toIso8601String();
        }

        return UnifiedNotification.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('❌ Failed to get notification history: $e');
      return [];
    }
  }

  /// Get single notification by ID
  Future<UnifiedNotification?> getNotificationById(String id) async {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot get notification: User not authenticated');
      return null;
    }

    try {
      final doc = await _firestore.doc('$_historyPath/$id').get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      // Convert Timestamps to DateTime
      if (data['scheduledTime'] is Timestamp) {
        data['scheduledTime'] =
            (data['scheduledTime'] as Timestamp).toDate().toIso8601String();
      }
      if (data['deliveredAt'] is Timestamp) {
        data['deliveredAt'] =
            (data['deliveredAt'] as Timestamp).toDate().toIso8601String();
      }
      if (data['readAt'] is Timestamp) {
        data['readAt'] =
            (data['readAt'] as Timestamp).toDate().toIso8601String();
      }

      return UnifiedNotification.fromJson(data);
    } catch (e) {
      debugPrint('❌ Failed to get notification by ID: $e');
      return null;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot mark as read: User not authenticated');
      return;
    }

    try {
      await _firestore.doc('$_historyPath/$notificationId').update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Marked notification $notificationId as read');
    } catch (e) {
      debugPrint('❌ Failed to mark notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot mark all as read: User not authenticated');
      return;
    }

    try {
      final batch = _firestore.batch();

      // Get all unread notifications
      final snapshot = await _firestore
          .collection(_historyPath!)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      debugPrint('✅ Marked ${snapshot.docs.length} notifications as read');
    } catch (e) {
      debugPrint('❌ Failed to mark all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot delete notification: User not authenticated');
      return;
    }

    try {
      await _firestore.doc('$_historyPath/$notificationId').delete();
      debugPrint('✅ Deleted notification $notificationId');
    } catch (e) {
      debugPrint('❌ Failed to delete notification: $e');
      rethrow;
    }
  }

  /// Search notifications by text (title/body)
  Future<List<UnifiedNotification>> searchNotifications(String query) async {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot search notifications: User not authenticated');
      return [];
    }

    try {
      // Firestore doesn't support full-text search natively
      // Workaround: Get all recent notifications and filter in-memory
      final snapshot = await _firestore
          .collection(_historyPath!)
          .orderBy('scheduledTime', descending: true)
          .limit(200) // Get last 200 for searching
          .get();

      final queryLower = query.toLowerCase();

      final notifications = snapshot.docs
          .map((doc) {
            final data = doc.data();

            // Convert Timestamps to DateTime
            if (data['scheduledTime'] is Timestamp) {
              data['scheduledTime'] = (data['scheduledTime'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }
            if (data['deliveredAt'] is Timestamp) {
              data['deliveredAt'] =
                  (data['deliveredAt'] as Timestamp).toDate().toIso8601String();
            }
            if (data['readAt'] is Timestamp) {
              data['readAt'] =
                  (data['readAt'] as Timestamp).toDate().toIso8601String();
            }

            return UnifiedNotification.fromJson(data);
          })
          .where((notification) =>
              notification.title.toLowerCase().contains(queryLower) ||
              notification.body.toLowerCase().contains(queryLower))
          .toList();

      return notifications;
    } catch (e) {
      debugPrint('❌ Failed to search notifications: $e');
      return [];
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot get unread count: User not authenticated');
      return 0;
    }

    try {
      final snapshot = await _firestore
          .collection(_historyPath!)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ Failed to get unread count: $e');
      return 0;
    }
  }

  /// Watch unread count (real-time)
  Stream<int> watchUnreadCount() {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot watch unread count: User not authenticated');
      return Stream.value(0);
    }

    return _firestore
        .collection(_historyPath!)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Cleanup expired notifications (90-day TTL)
  Future<int> cleanupExpiredNotifications() async {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot cleanup notifications: User not authenticated');
      return 0;
    }

    try {
      final now = DateTime.now();

      // Find notifications with expiresAt < now
      final snapshot = await _firestore
          .collection(_historyPath!)
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      debugPrint('✅ Cleaned up ${snapshot.docs.length} expired notifications');
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Failed to cleanup expired notifications: $e');
      return 0;
    }
  }

  /// Watch for new notifications (real-time)
  Stream<UnifiedNotification> watchNewNotifications() {
    if (_historyPath == null) {
      debugPrint('⚠️ Cannot watch new notifications: User not authenticated');
      return const Stream.empty(); // Return empty stream if not authenticated
    }

    return _firestore
        .collection(_historyPath!)
        .orderBy('scheduledTime', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        throw Exception('No new notifications');
      }

      final data = snapshot.docs.first.data();

      // Convert Timestamps to DateTime
      if (data['scheduledTime'] is Timestamp) {
        data['scheduledTime'] =
            (data['scheduledTime'] as Timestamp).toDate().toIso8601String();
      }
      if (data['deliveredAt'] is Timestamp) {
        data['deliveredAt'] =
            (data['deliveredAt'] as Timestamp).toDate().toIso8601String();
      }
      if (data['readAt'] is Timestamp) {
        data['readAt'] =
            (data['readAt'] as Timestamp).toDate().toIso8601String();
      }

      return UnifiedNotification.fromJson(data);
    });
  }

  // === GDPR Operations ===

  /// Delete all notification data (GDPR Article 17)
  Future<void> deleteAllNotificationData() async {
    if (_settingsPath == null || _historyPath == null ||
        _deliveryPath == null || _metricsPath == null) {
      debugPrint('⚠️ Cannot delete all data: User not authenticated');
      return;
    }

    try {
      final batch = _firestore.batch();

      // Delete settings
      batch.delete(_firestore.doc(_settingsPath!));

      // Delete all history (batch max 500)
      final historySnapshot =
          await _firestore.collection(_historyPath!).limit(500).get();
      for (final doc in historySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete all delivery records
      final deliverySnapshot =
          await _firestore.collection(_deliveryPath!).limit(500).get();
      for (final doc in deliverySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete metrics
      batch.delete(_firestore.doc(_metricsPath!));

      await batch.commit();

      debugPrint('✅ Deleted all notification data from Firestore');

      // If more than 500 history items, recursively delete
      if (historySnapshot.docs.length == 500) {
        await deleteAllNotificationData(); // Recursion for pagination
      }
    } catch (e) {
      debugPrint('❌ Failed to delete all notification data: $e');
      rethrow;
    }
  }
}
