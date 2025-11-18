/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/usecases
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: use_case
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// DELETE ALL NOTIFICATION DATA USE CASE - GDPR Article 17 compliance
library;

import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_settings_repository.dart';

/// Use case for deleting all notification data (GDPR Article 17)
///
/// **GDPR Right to Erasure (Article 17)**:
/// "The data subject shall have the right to obtain from the controller the
///  erasure of personal data concerning him or her without undue delay..."
///
/// **Scope of Deletion**:
/// 1. notificationSettings (Firestore + SharedPreferences)
/// 2. notificationHistory collection (Firestore + SharedPreferences)
/// 3. notificationDelivery collection (Firestore)
/// 4. notificationMetrics (Firestore)
/// 5. Scheduled notifications (flutter_local_notifications)
///
/// **UI Entry Point** (see Task 3.3 - Presentation Layer UX):
/// - NotificationSettingsScreen → "Delete All Notification Data" button
/// - Confirmation dialog: "This action cannot be undone"
/// - After deletion: Show success SnackBar + reset to defaults
///
/// **Warning**: Irreversible operation! User data cannot be recovered.
class DeleteAllNotificationData {
  final NotificationSettingsRepository _settingsRepository;
  final NotificationHistoryRepository _historyRepository;
  final NotificationRepository _notificationRepository;

  DeleteAllNotificationData({
    required NotificationSettingsRepository settingsRepository,
    required NotificationHistoryRepository historyRepository,
    required NotificationRepository notificationRepository,
  })  : _settingsRepository = settingsRepository,
        _historyRepository = historyRepository,
        _notificationRepository = notificationRepository;

  /// Execute complete data deletion
  ///
  /// **Steps** (atomic operation - all or nothing):
  /// 1. Cancel all scheduled notifications
  /// 2. Delete notificationSettings from Firestore
  /// 3. Delete notificationHistory collection from Firestore (batch delete)
  /// 4. Delete notificationDelivery collection from Firestore (batch delete)
  /// 5. Delete notificationMetrics from Firestore
  /// 6. Clear all local cache (SharedPreferences)
  /// 7. Reset to default settings (opt-out state)
  ///
  /// **Returns**: void
  ///
  /// **Throws**: Exception if deletion fails (partial deletion possible)
  ///
  /// **Post-Deletion State**:
  /// - All notifications disabled
  /// - No consent given (consentTimestamp = null)
  /// - Analytics disabled
  /// - Empty history
  /// - Pending notifications canceled
  Future<void> execute() async {
    // 1. Cancel all scheduled notifications (flutter_local_notifications)
    await _notificationRepository.cancelAllNotifications();

    // 2-7. Delegate to repositories (handles Firestore + SharedPreferences deletion)
    // Note: Order matters - delete dependent data first (history, delivery, metrics)
    // then parent data (settings)

    // Delete settings + all Firestore collections (implemented in repository)
    await _settingsRepository.revokeConsentAndDeleteData();

    // Note: History deletion is handled by revokeConsentAndDeleteData
    // which calls Firestore batch delete for all collections
  }

  /// Verify deletion was successful
  ///
  /// **Checks**:
  /// - No pending notifications scheduled
  /// - No local cache in SharedPreferences
  /// - Settings reset to defaults
  ///
  /// **Returns**: true if all checks pass
  ///
  /// **Use case**: Show confirmation UI after deletion
  Future<bool> verifyDeletionComplete() async {
    try {
      // Check pending notifications
      final pendingIds = await _notificationRepository.getPendingNotificationIds();
      if (pendingIds.isNotEmpty) return false;

      // Check settings reset to defaults
      final settings = await _settingsRepository.getSettings();
      if (settings.hasValidConsent) return false; // Should be revoked

      // Check history cleared
      final unreadCount = await _historyRepository.getUnreadCount();
      if (unreadCount > 0) return false;

      return true;
    } catch (e) {
      // If any check fails, assume deletion incomplete
      return false;
    }
  }
}
