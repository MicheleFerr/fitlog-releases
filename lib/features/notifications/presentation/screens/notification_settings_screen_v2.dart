/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/screens
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: screen
/// 🌍 Localization: REQUIRED
/// 🎨 Theme: context.colors.*
/// 📱 Platform: Universal
///
/// NOTIFICATION SETTINGS SCREEN V2.0 - Enhanced UI with v2.0 features
///
/// **New Features** (v2.0):
/// - Per-category quiet hours (workout/recovery/streak/rest)
/// - Frequency caps (max 3/day, 5/week)
/// - GDPR consent tracking with timestamp
/// - Data retention preferences (30-365 days)
/// - Sync status indicator (last synced time)
/// - Firestore sync toggle (immediate vs debounced)
/// - Analytics opt-in/out
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_settings_provider_v2.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/frequency_cap.dart';

/// Notification Settings Screen v2.0
///
/// **Sections**:
/// 1. Quick Toggles (workout/recovery/streak/rest reminders)
/// 2. Timing Preferences (preferred time, custom time, smart scheduling)
/// 3. Frequency Caps (max/day, max/week, min interval)
/// 4. Quiet Hours (global + per-category)
/// 5. Privacy & GDPR (consent, analytics, data retention)
/// 6. Sync Status (last synced, force sync button)
/// 7. Advanced (reset to defaults, delete all data)
class NotificationSettingsScreenV2 extends ConsumerWidget {
  const NotificationSettingsScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsV2Provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notificationSettings),
        actions: [
          // Sync status indicator
          IconButton(
            icon: const Icon(AppIcons.sync),
            onPressed: () {
              ref.read(notificationSettingsV2Provider.notifier).syncNow();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.syncingSettings)),
              );
            },
            tooltip: context.l10n.syncNow,
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsContent(context, ref, settings),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.error, size: AppIconSize.xxlarge, color: context.colors.error),
              const SizedBox(height: 16),
              Text(
                context.l10n.errorLoadingSettings,
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section 1: Quick Toggles
        _buildQuickToggles(context, ref, settings),
        const SizedBox(height: 24),

        // Section 2: Timing Preferences
        _buildTimingPreferences(context, ref, settings),
        const SizedBox(height: 24),

        // Section 3: Frequency Caps (v2.0)
        _buildFrequencyCaps(context, ref, settings),
        const SizedBox(height: 24),

        // Section 4: Quiet Hours (v2.0)
        _buildQuietHours(context, ref, settings),
        const SizedBox(height: 24),

        // Section 5: Privacy & GDPR (v2.0)
        _buildPrivacySection(context, ref, settings),
        const SizedBox(height: 24),

        // Section 6: Sync Status (v2.0)
        _buildSyncStatus(context, ref),
        const SizedBox(height: 24),

        // Section 7: Advanced
        _buildAdvancedSection(context, ref),
      ],
    );
  }

  // === Section 1: Quick Toggles ===

  Widget _buildQuickToggles(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.notificationTypes,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(context.l10n.workoutReminders),
              subtitle: Text(context.l10n.dailyWorkoutRemindersDescription),
              value: settings.enableWorkoutReminders,
              onChanged: (value) {
                ref
                    .read(notificationSettingsV2Provider.notifier)
                    .toggleWorkoutReminders(value);
              },
            ),
            if (settings.enableWorkoutReminders)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(AppIcons.schedule),
                  title: Text(_getCustomTimeText(context, settings, 'workoutReminder')),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () => _showCustomTimePicker(context, ref, settings, 'workoutReminder'),
                ),
              ),
            SwitchListTile(
              title: Text(context.l10n.recoveryAlerts),
              subtitle: Text(context.l10n.recoveryAlertsDescription),
              value: settings.enableRecoveryAlerts,
              onChanged: (value) {
                ref
                    .read(notificationSettingsV2Provider.notifier)
                    .toggleRecoveryAlerts(value);
              },
            ),
            if (settings.enableRecoveryAlerts)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(AppIcons.schedule),
                  title: Text(_getCustomTimeText(context, settings, 'recoveryAlert')),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () => _showCustomTimePicker(context, ref, settings, 'recoveryAlert'),
                ),
              ),
            SwitchListTile(
              title: Text(context.l10n.streakMotivation),
              subtitle: Text(context.l10n.streakMotivationDescription),
              value: settings.enableStreakMotivation,
              onChanged: (value) {
                ref
                    .read(notificationSettingsV2Provider.notifier)
                    .toggleStreakMotivation(value);
              },
            ),
            if (settings.enableStreakMotivation)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(AppIcons.schedule),
                  title: Text(_getCustomTimeText(context, settings, 'streakMotivation')),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () => _showCustomTimePicker(context, ref, settings, 'streakMotivation'),
                ),
              ),
            SwitchListTile(
              title: Text(context.l10n.supplementReminders),
              subtitle: Text(context.l10n.supplementRemindersDescription),
              value: settings.enableSupplementReminders,
              onChanged: (value) {
                ref
                    .read(notificationSettingsV2Provider.notifier)
                    .toggleSupplementReminders(value);
              },
            ),
            if (settings.enableSupplementReminders)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(AppIcons.schedule),
                  title: Text(_getCustomTimeText(context, settings, 'supplementReminder')),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () => _showCustomTimePicker(context, ref, settings, 'supplementReminder'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // === Section 2: Timing Preferences ===

  Widget _buildTimingPreferences(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.timingPreferences,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(context.l10n.preferredTime),
              subtitle: Text(_formatTimePreference(context, settings.preferredTime)),
              trailing: const Icon(AppIcons.chevronRight),
              onTap: () => _showTimePreferencePicker(context, ref, settings),
            ),
            SwitchListTile(
              title: Text(context.l10n.smartScheduling),
              subtitle: Text(context.l10n.smartSchedulingDescription),
              value: settings.enableSmartScheduling,
              onChanged: (value) {
                final updated = settings.copyWith(enableSmartScheduling: value);
                ref
                    .read(notificationSettingsV2Provider.notifier)
                    .updateSettings(updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  // === Section 3: Frequency Caps (v2.0) ===

  Widget _buildFrequencyCaps(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    final frequencyCap = settings.frequencyCapPreferences;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.l10n.frequencyCaps,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: const Text('v2.0'),
                  backgroundColor: context.colors.primary.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.frequencyCapsDescription,
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(context.l10n.maxPerDay),
              subtitle: Text(context.l10n.maxPerDayDescription),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${frequencyCap?.maxPerDay ?? 3}',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(AppIcons.chevronRight),
                ],
              ),
              onTap: () => _showMaxPerDayPicker(context, ref, settings),
            ),
            ListTile(
              title: Text(context.l10n.maxPerWeek),
              subtitle: Text(context.l10n.maxPerWeekDescription),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${frequencyCap?.maxPerWeek ?? 5}',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(AppIcons.chevronRight),
                ],
              ),
              onTap: () => _showMaxPerWeekPicker(context, ref, settings),
            ),
            ListTile(
              title: Text(context.l10n.minIntervalHours),
              subtitle: Text(context.l10n.minIntervalHoursDescription),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${frequencyCap?.minIntervalHours ?? 2}h',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(AppIcons.chevronRight),
                ],
              ),
              onTap: () => _showMinIntervalHoursPicker(context, ref, settings),
            ),
          ],
        ),
      ),
    );
  }

  // === Section 4: Quiet Hours (v2.0) ===

  Widget _buildQuietHours(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.l10n.quietHours,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: const Text('v2.0'),
                  backgroundColor: context.colors.primary.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(context.l10n.enableDoNotDisturb),
              subtitle: Text(context.l10n.doNotDisturbDescription),
              value: settings.doNotDisturbEnabled,
              onChanged: (value) {
                final updated = settings.copyWith(doNotDisturbEnabled: value);
                ref
                    .read(notificationSettingsV2Provider.notifier)
                    .updateSettings(updated);
              },
            ),
            if (settings.doNotDisturbEnabled) ...[
              ListTile(
                title: Text(context.l10n.quietHoursWindow),
                subtitle: Text(_formatQuietHours(settings)),
                trailing: const Icon(AppIcons.chevronRight),
                onTap: () => _showQuietHoursPicker(context, ref, settings),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // === Section 5: Privacy & GDPR (v2.0) ===

  Widget _buildPrivacySection(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.l10n.privacyAndGDPR,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: const Text('GDPR'),
                  backgroundColor: context.colors.success.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                settings.hasValidConsent
                    ? AppIcons.checkCircle
                    : AppIcons.warning,
                color: settings.hasValidConsent
                    ? context.colors.success
                    : context.colors.warning,
              ),
              title: Text(context.l10n.consentStatus),
              subtitle: Text(
                settings.hasValidConsent
                    ? context.l10n.consentGiven
                    : context.l10n.consentNotGiven,
              ),
              trailing: TextButton(
                onPressed: () => _showConsentDialog(context, ref),
                child: Text(context.l10n.viewConsent),
              ),
            ),
            SwitchListTile(
              title: Text(context.l10n.enableAnalytics),
              subtitle: Text(context.l10n.analyticsDescription),
              value: settings.enableAnalytics,
              onChanged: (value) {
                final updated = settings.copyWith(enableAnalytics: value);
                ref
                    .read(notificationSettingsV2Provider.notifier)
                    .updateSettings(updated);
              },
            ),
            ListTile(
              title: Text(context.l10n.dataRetentionPeriod),
              subtitle: Text('${settings.dataRetentionDays} ${context.l10n.days}'),
              trailing: const Icon(AppIcons.chevronRight),
              onTap: () => _showDataRetentionPicker(context, ref, settings),
            ),
          ],
        ),
      ),
    );
  }

  // === Section 6: Sync Status (v2.0) ===

  Widget _buildSyncStatus(BuildContext context, WidgetRef ref) {
    final lastSyncAsync = ref.watch(lastSyncTimeProvider);
    final isOutOfSyncAsync = ref.watch(isOutOfSyncProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.syncStatus,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            lastSyncAsync.when(
              data: (lastSync) => ListTile(
                leading: Icon(
                  AppIcons.cloudDone,
                  color: context.colors.success,
                ),
                title: Text(context.l10n.lastSynced),
                subtitle: Text(lastSync != null
                    ? _formatLastSync(context, lastSync)
                    : context.l10n.neverSynced),
              ),
              loading: () => const ListTile(
                leading: LoadingIndicator(),
                title: Text('Loading...'),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            isOutOfSyncAsync.when(
              data: (isOutOfSync) => isOutOfSync
                  ? ListTile(
                      leading: Icon(
                        AppIcons.warning,
                        color: context.colors.warning,
                      ),
                      title: Text(context.l10n.outOfSync),
                      subtitle: Text(context.l10n.outOfSyncDescription),
                      trailing: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(notificationSettingsV2Provider.notifier)
                              .syncNow();
                        },
                        child: Text(context.l10n.syncNow),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // === Section 7: Advanced ===

  Widget _buildAdvancedSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.advanced,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(AppIcons.restore, color: context.colors.primary),
              title: Text(context.l10n.resetToDefaults),
              subtitle: Text(context.l10n.resetToDefaultsDescription),
              onTap: () {
                _showResetDialog(context, ref);
              },
            ),
            ListTile(
              leading: Icon(AppIcons.delete, color: context.colors.error),
              title: Text(context.l10n.deleteAllData),
              subtitle: Text(context.l10n.deleteAllDataDescription),
              onTap: () {
                _showDeleteAllDataDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  // === Dialog Methods ===

  /// Show time preference picker dialog
  Future<void> _showTimePreferencePicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final result = await showDialog<NotificationTimePreference>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.preferredTime),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final pref in NotificationTimePreference.values)
              RadioListTile<NotificationTimePreference>(
                title: Text(_formatTimePreference(context, pref)),
                value: pref,
                groupValue: settings.preferredTime,
                onChanged: (value) => Navigator.pop(context, value),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );

    if (result != null) {
      unawaited(
        ref.read(notificationSettingsV2Provider.notifier).updatePreferredTime(result),
      );
    }
  }

  /// Show quiet hours time picker dialog
  Future<void> _showQuietHoursPicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final startTime = settings.doNotDisturbStart ?? DateTime(2025, 1, 1, 22, 0);
    final endTime = settings.doNotDisturbEnd ?? DateTime(2025, 1, 1, 7, 0);

    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) => _QuietHoursPickerDialog(
        startTime: startTime,
        endTime: endTime,
      ),
    );

    if (result != null) {
      unawaited(
        ref.read(notificationSettingsV2Provider.notifier).updateDoNotDisturb(
          enabled: true,
          startTime: result['start'],
          endTime: result['end'],
        ),
      );
    }
  }

  /// Show GDPR consent dialog
  Future<void> _showConsentDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.privacyConsent),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.consentDescription,
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '${context.l10n.consentVersion}: 2.0',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  /// Show data retention period picker dialog
  Future<void> _showDataRetentionPicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final options = [30, 60, 90, 180, 365]; // Days

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.dataRetentionPeriod),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final days in options)
              RadioListTile<int>(
                title: Text('$days ${context.l10n.days}'),
                value: days,
                groupValue: settings.dataRetentionDays,
                onChanged: (value) => Navigator.pop(context, value),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );

    if (result != null) {
      final updated = settings.copyWith(dataRetentionDays: result);
      unawaited(
        ref.read(notificationSettingsV2Provider.notifier).updateSettings(updated),
      );
    }
  }

  // === Helper Methods ===

  String _formatTimePreference(
      BuildContext context, NotificationTimePreference pref) {
    switch (pref) {
      case NotificationTimePreference.morning:
        return context.l10n.morning;
      case NotificationTimePreference.midday:
        return context.l10n.midday;
      case NotificationTimePreference.afternoon:
        return context.l10n.afternoon;
      case NotificationTimePreference.evening:
        return context.l10n.evening;
      case NotificationTimePreference.custom:
        return context.l10n.custom;
    }
  }

  String _formatQuietHours(NotificationSettings settings) {
    if (settings.doNotDisturbStart == null ||
        settings.doNotDisturbEnd == null) {
      return 'Not set';
    }

    final start = settings.doNotDisturbStart!;
    final end = settings.doNotDisturbEnd!;

    return '${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}';
  }

  String _formatLastSync(BuildContext context, DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return context.l10n.justNow;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${context.l10n.minutesAgo}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${context.l10n.hoursAgo}';
    } else {
      return '${difference.inDays} ${context.l10n.daysAgo}';
    }
  }

  /// Get custom time text for a notification type
  String _getCustomTimeText(
    BuildContext context,
    NotificationSettings settings,
    String typeKey,
  ) {
    final customTime = settings.customTimePerType[typeKey];

    if (customTime == null) {
      // Use default time based on preferredTime global setting
      return '${context.l10n.customTime}: ${context.l10n.useDefaultTime}';
    }

    // Show custom time for this specific type
    final hour = customTime.hour.toString().padLeft(2, '0');
    final minute = customTime.minute.toString().padLeft(2, '0');
    return '${context.l10n.customTime}: $hour:$minute';
  }

  /// Show custom time picker for a specific notification type
  Future<void> _showCustomTimePicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
    String typeKey,
  ) async {
    // Get current custom time or default to 09:00
    final currentTime = settings.customTimePerType[typeKey] ??
        DateTime(2025, 1, 1, 9, 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
    );

    if (picked != null) {
      // Create DateTime with only time component (date is ignored)
      final newTime = DateTime(2025, 1, 1, picked.hour, picked.minute);

      // Update customTimePerType map
      final updatedMap = Map<String, DateTime>.from(settings.customTimePerType);
      updatedMap[typeKey] = newTime;

      // Save to provider
      final updated = settings.copyWith(customTimePerType: updatedMap);
      unawaited(
        ref.read(notificationSettingsV2Provider.notifier).updateSettings(updated),
      );
    }
  }

  /// Show picker for maxPerDay (range: 1-10)
  Future<void> _showMaxPerDayPicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final currentValue = settings.frequencyCapPreferences?.maxPerDay ?? 3;
    double selectedValue = currentValue.toDouble();

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.maxPerDay),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.maxPerDayDescription,
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Text(
                '${selectedValue.toInt()}',
                style: context.textTheme.displayMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: selectedValue,
                min: 1,
                max: 10,
                divisions: 9,
                label: '${selectedValue.toInt()}',
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Range: 1-10 ${context.l10n.notificationsPerDay}',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selectedValue.toInt()),
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final updatedCap = (settings.frequencyCapPreferences ?? const FrequencyCap()).copyWith(
        maxPerDay: result,
      );
      final updated = settings.copyWith(frequencyCapPreferences: updatedCap);
      unawaited(
        ref.read(notificationSettingsV2Provider.notifier).updateSettings(updated),
      );
    }
  }

  /// Show picker for maxPerWeek (range: 1-20)
  Future<void> _showMaxPerWeekPicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final currentValue = settings.frequencyCapPreferences?.maxPerWeek ?? 5;
    double selectedValue = currentValue.toDouble();

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.maxPerWeek),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.maxPerWeekDescription,
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Text(
                '${selectedValue.toInt()}',
                style: context.textTheme.displayMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: selectedValue,
                min: 1,
                max: 20,
                divisions: 19,
                label: '${selectedValue.toInt()}',
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Range: 1-20 ${context.l10n.notificationsPerWeek}',
                style: context.textTheme.bodySmall,
              ),
              if (selectedValue > 5) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(AppIcons.warningAmber, color: context.colors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.exceedsResearchLimit,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selectedValue.toInt()),
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final updatedCap = (settings.frequencyCapPreferences ?? const FrequencyCap()).copyWith(
        maxPerWeek: result,
      );
      final updated = settings.copyWith(frequencyCapPreferences: updatedCap);
      unawaited(
        ref.read(notificationSettingsV2Provider.notifier).updateSettings(updated),
      );
    }
  }

  /// Show picker for minIntervalHours (range: 1-24)
  Future<void> _showMinIntervalHoursPicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final currentValue = settings.frequencyCapPreferences?.minIntervalHours ?? 2;
    double selectedValue = currentValue.toDouble();

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.minIntervalHours),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.minIntervalHoursDescription,
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Text(
                '${selectedValue.toInt()}h',
                style: context.textTheme.displayMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: selectedValue,
                min: 1,
                max: 24,
                divisions: 23,
                label: '${selectedValue.toInt()}h',
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Range: 1-24 ${context.l10n.hours}',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selectedValue.toInt()),
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final updatedCap = (settings.frequencyCapPreferences ?? const FrequencyCap()).copyWith(
        minIntervalHours: result,
      );
      final updated = settings.copyWith(frequencyCapPreferences: updatedCap);
      unawaited(
        ref.read(notificationSettingsV2Provider.notifier).updateSettings(updated),
      );
    }
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.resetToDefaults),
        content: Text(context.l10n.resetToDefaultsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(notificationSettingsV2Provider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.settingsReset)),
              );
            },
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteAllData),
        content: Text(context.l10n.deleteAllDataWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () {
              ref
                  .read(notificationSettingsV2Provider.notifier)
                  .revokeConsentAndDeleteData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.allDataDeleted)),
              );
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}

// === Quiet Hours Picker Dialog ===

class _QuietHoursPickerDialog extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;

  const _QuietHoursPickerDialog({
    required this.startTime,
    required this.endTime,
  });

  @override
  State<_QuietHoursPickerDialog> createState() => _QuietHoursPickerDialogState();
}

class _QuietHoursPickerDialogState extends State<_QuietHoursPickerDialog> {
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );

    if (picked != null) {
      setState(() {
        _startTime = DateTime(2025, 1, 1, picked.hour, picked.minute);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );

    if (picked != null) {
      setState(() {
        _endTime = DateTime(2025, 1, 1, picked.hour, picked.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.quietHoursWindow),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(context.l10n.startTime),
            subtitle: Text(
              '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(AppIcons.accessTime),
            onTap: _pickStartTime,
          ),
          ListTile(
            title: Text(context.l10n.endTime),
            subtitle: Text(
              '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(AppIcons.accessTime),
            onTap: _pickEndTime,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, {'start': _startTime, 'end': _endTime}),
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
