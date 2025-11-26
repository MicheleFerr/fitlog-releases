/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/providers
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// NOTIFICATION SETTINGS PROVIDER V2.0 - Riverpod providers with Firestore sync
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/data/sync/notification_sync_manager.dart';
import 'package:gymbro_flutter_new/features/notifications/data/repositories/notification_settings_repository_impl.dart';
import 'package:gymbro_flutter_new/shared/providers/shared_preferences_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/daily_workout_reminder_service.dart';
import 'package:flutter/foundation.dart';

// === Infrastructure Providers ===

/// Provider for FirebaseFirestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for current user ID (from Firebase Auth)
/// Returns null if user is not authenticated
/// NOTE: Intentionally without .autoDispose - global auth state needed app-wide
final currentUserIdProvider = StreamProvider<String?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) => user?.uid);
});

// === Data Source Providers ===

/// Provider for NotificationLocalDataSource
final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationLocalDataSource(prefs);
});

/// Provider for NotificationRemoteDataSource
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider).value; // Extract String? from AsyncValue

  return NotificationRemoteDataSource(
    firestore: firestore,
    userId: userId, // Will be null if user not authenticated
  );
});

// === Sync Manager Provider ===

/// Provider for NotificationSyncManager
final notificationSyncManagerProvider =
    Provider<NotificationSyncManager>((ref) {
  final localDataSource = ref.watch(notificationLocalDataSourceProvider);
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);

  return NotificationSyncManager(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

// === Repository Provider ===

/// Provider for NotificationSettingsRepository (v2.0)
final notificationSettingsRepositoryV2Provider =
    Provider<NotificationSettingsRepository>((ref) {
  final localDataSource = ref.watch(notificationLocalDataSourceProvider);
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  final syncManager = ref.watch(notificationSyncManagerProvider);

  return NotificationSettingsRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    syncManager: syncManager,
  );
});

// === State Providers ===

/// Provider for NotificationSettings (v2.0)
///
/// **Features**:
/// - Loads from SharedPreferences first (offline support)
/// - Syncs with Firestore in background (debounced 5 min)
/// - Auto-migration from v1.0 to v2.0
/// - Real-time updates from Firestore (cross-device sync)
final notificationSettingsV2Provider = StateNotifierProvider<
    NotificationSettingsNotifierV2, AsyncValue<NotificationSettings>>((ref) {
  final repository = ref.watch(notificationSettingsRepositoryV2Provider);

  return NotificationSettingsNotifierV2(repository);
});

/// Notifier for NotificationSettings v2.0
class NotificationSettingsNotifierV2
    extends StateNotifier<AsyncValue<NotificationSettings>> {

  NotificationSettingsNotifierV2(this._repository)
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }
  final NotificationSettingsRepository _repository;

  /// Load settings (local first, Firestore fallback)
  Future<void> _loadSettings() async {
    try {
      state = const AsyncValue.loading();

      // Load settings (includes auto-migration v1.0 → v2.0)
      final settings = await _repository.getSettings();

      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update settings (debounced Firestore sync)
  Future<void> updateSettings(NotificationSettings newSettings) async {
    // Optimistic update (immediate UI feedback)
    state = AsyncValue.data(newSettings);

    try {
      // Enqueue debounced sync (5 min)
      await _repository.updateSettings(newSettings);
    } catch (error, stackTrace) {
      // Revert on error
      await _loadSettings();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    try {
      await _repository.resetToDefaults();
      await _loadSettings(); // Reload after reset
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Sync now (bypass debounce)
  Future<void> syncNow() async {
    try {
      await _repository.syncNow();
      await _loadSettings(); // Reload after sync
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Record consent (GDPR Article 7.1)
  Future<void> recordConsent(String consentVersion) async {
    try {
      await _repository.recordConsent(consentVersion);
      await _loadSettings(); // Reload to get updated settings
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Revoke consent and delete all data (GDPR Article 17)
  Future<void> revokeConsentAndDeleteData() async {
    try {
      await _repository.revokeConsentAndDeleteData();
      await _loadSettings(); // Reload to get opt-out defaults
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // === Convenience Methods (Backward Compatibility) ===

  /// Toggle workout reminders
  Future<void> toggleWorkoutReminders(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(enableWorkoutReminders: enabled));
  }

  /// Toggle recovery alerts
  Future<void> toggleRecoveryAlerts(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(enableRecoveryAlerts: enabled));
  }

  /// Toggle streak motivation
  Future<void> toggleStreakMotivation(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(enableStreakMotivation: enabled));
  }

  /// Toggle supplement reminders
  Future<void> toggleSupplementReminders(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(enableSupplementReminders: enabled));
  }

  /// Toggle PR (Personal Record) notifications
  Future<void> togglePRNotifications(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(enablePRNotifications: enabled));
  }

  /// Toggle workout streak achievement notifications
  Future<void> toggleStreakAchievements(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(enableStreakAchievements: enabled));
  }

  /// Toggle goal completion notifications
  Future<void> toggleGoalCompletions(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(enableGoalCompletions: enabled));
  }

  /// Toggle milestone achievement notifications
  Future<void> toggleMilestones(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(enableMilestones: enabled));
  }

  /// Update preferred time
  Future<void> updatePreferredTime(
      NotificationTimePreference preference) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(preferredTime: preference));
  }

  /// Update custom time
  Future<void> updateCustomTime(DateTime customTime) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(customTime: customTime));
  }

  /// Update DND window
  Future<void> updateDoNotDisturb({
    required bool enabled,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final current = state.value;
    if (current == null) return;

    await updateSettings(current.copyWith(
      doNotDisturbEnabled: enabled,
      doNotDisturbStart: startTime,
      doNotDisturbEnd: endTime,
    ));
  }
}

// === Real-Time Stream Providers ===

/// Stream provider for NotificationSettings (real-time Firestore updates)
///
/// **Use case**: Multi-device sync - see changes from other devices in real-time
/// NOTE: Intentionally without .autoDispose - settings needed throughout app lifecycle
final notificationSettingsStreamV2Provider =
    StreamProvider<NotificationSettings>((ref) {
  final repository = ref.watch(notificationSettingsRepositoryV2Provider);

  return repository.watchSettings();
});

/// Provider for last sync time
final lastSyncTimeProvider = FutureProvider.autoDispose<DateTime?>((ref) async {
  final repository = ref.watch(notificationSettingsRepositoryV2Provider);
  return await repository.getLastSyncTime();
});

/// Provider for out-of-sync status (last sync > 24h)
final isOutOfSyncProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repository = ref.watch(notificationSettingsRepositoryV2Provider);
  return await repository.isOutOfSync();
});

/// Provider for migration status
final needsMigrationProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(notificationSettingsRepositoryV2Provider);
  return await repository.needsMigration();
});

/// Provider for GDPR consent status
final hasValidConsentProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(notificationSettingsRepositoryV2Provider);
  return await repository.hasValidConsent();
});

// === Auto-Scheduling Integration ===

/// Provider that automatically schedules/cancels notifications when settings change
///
/// **How it works**:
/// 1. Watches `notificationSettingsV2Provider` for changes
/// 2. When `enableWorkoutReminders` changes → schedules or cancels reminders
/// 3. When `customTime` changes → reschedules with new time
/// 4. Must be read in `NotificationServicesInitializer` to activate
///
/// **Example usage**:
/// ```dart
/// // In NotificationServicesInitializer
/// ref.read(autoScheduleNotificationsV2Provider);
/// ```
final autoScheduleNotificationsV2Provider = Provider<void>((ref) {
  ref.listen<AsyncValue<NotificationSettings>>(
    notificationSettingsV2Provider,
    (previous, next) async {
      final prevSettings = previous?.value;
      final newSettings = next.value;

      // Skip if loading or error
      if (newSettings == null) return;

      try {
        final reminderService = ref.read(dailyWorkoutReminderServiceProvider);

        // Case 1: Workout reminders toggled
        final wasEnabled = prevSettings?.enableWorkoutReminders ?? false;
        final nowEnabled = newSettings.enableWorkoutReminders;

        if (wasEnabled != nowEnabled) {
          if (nowEnabled) {
            // Schedule with user's preferred time
            // v2.0: Check customTimePerType['workoutReminder'] first, then fallback to global customTime
            final customTime = newSettings.customTimePerType['workoutReminder'] ??
                newSettings.customTime;
            await reminderService.scheduleDailyReminders(
              customHour: customTime?.hour,
              customMinute: customTime?.minute,
            );
            if (kDebugMode) {
              debugPrint('✅ [AutoSchedule] Enabled → Scheduled reminders');
            }
          } else {
            await reminderService.cancelAllReminders();
            if (kDebugMode) {
              debugPrint('🔕 [AutoSchedule] Disabled → Cancelled reminders');
            }
          }
          return; // Don't check time change if toggle changed
        }

        // Case 2: Custom time changed (only if enabled)
        // v2.0: Check customTimePerType['workoutReminder'] first, then fallback to global customTime
        if (nowEnabled && prevSettings != null) {
          final prevTime = prevSettings.customTimePerType['workoutReminder'] ??
              prevSettings.customTime;
          final newTime = newSettings.customTimePerType['workoutReminder'] ??
              newSettings.customTime;

          final timeChanged = prevTime?.hour != newTime?.hour ||
              prevTime?.minute != newTime?.minute;

          if (timeChanged) {
            await reminderService.rescheduleReminders(
              customHour: newTime?.hour,
              customMinute: newTime?.minute,
            );
            if (kDebugMode) {
              debugPrint('🔄 [AutoSchedule] Time changed → Rescheduled');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [AutoSchedule] Error: $e');
        }
      }
    },
    fireImmediately: false, // Don't fire on initial load (handled by NotificationServicesInitializer)
  );
});
