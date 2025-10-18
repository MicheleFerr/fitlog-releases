/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/screens
/// 🎯 Feature: smart_notifications
/// 🔧 Type: screen
/// 🌍 Localization: ✅ YES (context.l10n) - TODO: Add translations
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// NOTIFICATION SETTINGS SCREEN - Configure notification preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionAsync = ref.watch(notificationPermissionProvider);
    final settings = ref.watch(notificationSettingsProvider);
    final pendingAsync = ref.watch(pendingNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: context.colors.primary),
            const SizedBox(width: 8),
            const Text('Notification Settings'),
          ],
        ),
      ),
      body: permissionAsync.when(
        data: (hasPermission) => _buildContent(
          context,
          ref,
          hasPermission,
          settings,
          pendingAsync,
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    bool hasPermission,
    NotificationSettings settings,
    AsyncValue<List<WorkoutNotification>> pendingAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permission Status
          if (!hasPermission) _buildPermissionBanner(context, ref),

          // Pending Notifications Count
          pendingAsync.when(
            data: (pending) =>
                _buildPendingNotificationsBanner(context, pending.length),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Notification Types Section
          _buildSectionHeader(context, '🔔 Notification Types'),
          const SizedBox(height: 12),
          _buildNotificationToggle(
            context,
            ref,
            title: 'Workout Reminders',
            subtitle: 'Get reminded before your scheduled workouts',
            value: settings.enableWorkoutReminders,
            onChanged: (value) => ref
                .read(notificationSettingsProvider.notifier)
                .toggleWorkoutReminders(value),
            enabled: hasPermission,
          ),
          _buildNotificationToggle(
            context,
            ref,
            title: 'Recovery Alerts',
            subtitle: 'Reminders when you have skipped workouts to recover',
            value: settings.enableRecoveryAlerts,
            onChanged: (value) => ref
                .read(notificationSettingsProvider.notifier)
                .toggleRecoveryAlerts(value),
            enabled: hasPermission,
          ),
          _buildNotificationToggle(
            context,
            ref,
            title: 'Streak Motivation',
            subtitle: 'Motivational messages to keep your streak going',
            value: settings.enableStreakMotivation,
            onChanged: (value) => ref
                .read(notificationSettingsProvider.notifier)
                .updateSettings(
                  settings.copyWith(enableStreakMotivation: value),
                ),
            enabled: hasPermission,
          ),
          _buildNotificationToggle(
            context,
            ref,
            title: 'Rest Day Reminders',
            subtitle: 'Gentle reminders on your scheduled rest days',
            value: settings.enableRestDayReminders,
            onChanged: (value) => ref
                .read(notificationSettingsProvider.notifier)
                .updateSettings(
                  settings.copyWith(enableRestDayReminders: value),
                ),
            enabled: hasPermission,
          ),

          const SizedBox(height: 24),

          // Preferred Time Section
          _buildSectionHeader(context, '⏰ Preferred Notification Time'),
          const SizedBox(height: 12),
          _buildTimePreferenceSelector(context, ref, settings, hasPermission),

          const SizedBox(height: 24),

          // Smart Scheduling Section
          _buildSectionHeader(context, '🧠 Smart Scheduling'),
          const SizedBox(height: 12),
          _buildNotificationToggle(
            context,
            ref,
            title: 'Enable Smart Scheduling',
            subtitle:
                'Optimize notification timing and avoid spam',
            value: settings.enableSmartScheduling,
            onChanged: (value) => ref
                .read(notificationSettingsProvider.notifier)
                .updateSettings(
                  settings.copyWith(enableSmartScheduling: value),
                ),
            enabled: hasPermission,
          ),

          const SizedBox(height: 24),

          // Do Not Disturb Section
          _buildSectionHeader(context, '🌙 Do Not Disturb'),
          const SizedBox(height: 12),
          _buildDoNotDisturbSection(context, ref, settings, hasPermission),

          const SizedBox(height: 24),

          // Test Notification Button
          if (hasPermission)
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _sendTestNotification(context, ref),
                icon: const Icon(Icons.send),
                label: const Text('Send Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPermissionBanner(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: context.colors.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Notifications are disabled',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Please enable notifications in your device settings to receive workout reminders.',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onErrorContainer,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final service = ref.read(smartNotificationServiceProvider);
              await service.initialize();
              ref.invalidate(notificationPermissionProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            child: const Text('Request Permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingNotificationsBanner(
    BuildContext context,
    int count,
  ) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: context.colors.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count pending ${count == 1 ? 'notification' : 'notifications'}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.colors.onSurface,
      ),
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool enabled,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        value: value && enabled,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget _buildTimePreferenceSelector(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
    bool enabled,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'When should we notify you?',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: NotificationTimePreference.values.map((pref) {
                final isSelected = settings.preferredTime == pref;
                return FilterChip(
                  label: Text(_getTimePreferenceLabel(pref)),
                  selected: isSelected && enabled,
                  onSelected: enabled
                      ? (selected) {
                          if (selected) {
                            ref
                                .read(notificationSettingsProvider.notifier)
                                .updatePreferredTime(pref);
                          }
                        }
                      : null,
                  selectedColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  labelStyle: context.textTheme.bodySmall?.copyWith(
                    color: isSelected && enabled
                        ? context.colors.onPrimary
                        : context.colors.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoNotDisturbSection(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
    bool enabled,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Enable Do Not Disturb',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Delay notifications during these hours'),
              value: settings.doNotDisturbEnabled && enabled,
              onChanged: enabled
                  ? (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .updateSettings(
                            settings.copyWith(doNotDisturbEnabled: value),
                          );
                    }
                  : null,
            ),
            if (settings.doNotDisturbEnabled && enabled) ...[
              const Divider(height: 24),
              Text(
                'DND Window: 22:00 - 7:00',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Notifications scheduled during this window will be delayed until 7:00 AM',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTimePreferenceLabel(NotificationTimePreference pref) {
    switch (pref) {
      case NotificationTimePreference.morning:
        return 'Morning (8:00)';
      case NotificationTimePreference.midday:
        return 'Midday (12:30)';
      case NotificationTimePreference.afternoon:
        return 'Afternoon (16:00)';
      case NotificationTimePreference.evening:
        return 'Evening (19:00)';
      case NotificationTimePreference.custom:
        return 'Custom';
    }
  }

  Future<void> _sendTestNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final service = ref.read(smartNotificationServiceProvider);
      await service.showTestNotification();

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          'Test notification sent! Check your notification tray.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'Failed to send test notification',
        );
      }
    }
  }
}
