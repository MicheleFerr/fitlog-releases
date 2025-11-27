/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/widgets
/// 🎯 Feature: notifications_debug
/// 🔧 Type: debug_widget
/// 🌍 Localization: Minimal (debug only)
/// 🎨 Theme: Material 3
/// 📱 Platform: Universal
///
/// DEBUG NOTIFICATION SCHEDULER - Developer tool for testing notification deep linking
/// ⚠️ ONLY VISIBLE IN DEBUG MODE (kDebugMode)
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Debug widget to schedule test notifications
/// Opens bottom sheet with all notification types and delay options
class DebugNotificationScheduler extends ConsumerStatefulWidget {
  const DebugNotificationScheduler({super.key});

  @override
  ConsumerState<DebugNotificationScheduler> createState() =>
      _DebugNotificationSchedulerState();
}

class _DebugNotificationSchedulerState
    extends ConsumerState<DebugNotificationScheduler> {
  NotificationType _selectedType = NotificationType.workoutReminder;
  double _delaySeconds = 10; // Default 10 seconds

  /// Notification type configurations with emoji, title, body
  final Map<NotificationType, Map<String, String>> _notificationConfig = {
    NotificationType.workoutReminder: {
      'emoji': '🏋️',
      'title': 'Workout Reminder',
      'body': 'Time to get those gains! Tap to start workout.',
      'route': '/workout',
    },
    NotificationType.achievementUnlocked: {
      'emoji': '🏆',
      'title': 'Achievement Unlocked!',
      'body': 'You earned a new badge! Tap to view analytics.',
      'route': '/analytics',
    },
    NotificationType.progressMilestone: {
      'emoji': '📈',
      'title': 'Progress Milestone',
      'body': 'New PR achieved! Check your progress.',
      'route': '/analytics',
    },
    NotificationType.restReminder: {
      'emoji': '😴',
      'title': 'Rest Day Reminder',
      'body': 'Recovery is important. Check your routine.',
      'route': '/routine',
    },
    NotificationType.workoutSummary: {
      'emoji': '📊',
      'title': 'Workout Summary Ready',
      'body': 'Your workout stats are ready. Tap to view.',
      'route': '/analytics',
    },
    NotificationType.streakReminder: {
      'emoji': '🔥',
      'title': 'Streak Reminder',
      'body': 'Keep your streak alive! Tap to see analytics.',
      'route': '/analytics',
    },
    NotificationType.timerComplete: {
      'emoji': '⏰',
      'title': 'Rest Timer Complete',
      'body': 'Time for your next set! Tap to continue.',
      'route': '/workout',
    },
  };

  /// Delay presets in seconds
  final List<double> _delayPresets = [5, 10, 15, 30, 60, 120, 300];

  String _getDelayLabel(double seconds) {
    if (seconds < 60) {
      return '${seconds.toInt()}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '${minutes}m';
    } else {
      final hours = seconds ~/ 3600;
      return '${hours}h';
    }
  }

  Future<void> _scheduleNotification() async {
    final config = _notificationConfig[_selectedType]!;
    final repository = ref.read(notificationRepositoryProvider);

    try {
      final notification = UnifiedNotification(
        id: 'debug_${DateTime.now().millisecondsSinceEpoch}',
        type: _selectedType,
        title: '${config['emoji']} ${config['title']}',
        body: config['body']!,
        scheduledTime: DateTime.now().add(Duration(seconds: _delaySeconds.toInt())),
        priority: NotificationPriority.high,
        payload: {
          'type': _selectedType.toString(),
          'route': config['route']!,
        },
      );

      await repository.scheduleNotification(notification);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔔 Notification scheduled in ${_getDelayLabel(_delaySeconds)}',
            ),
            backgroundColor: context.colors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.notifications,
                  color: context.colors.primary,
                  size: AppIconSize.medium,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🐛 Debug Notification Scheduler',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    AppIcons.close,
                    color: context.colors.onPrimaryContainer,
                    size: AppIconSize.small,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Type Selector
                Text(
                  'Notification Type',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: NotificationType.values.map((type) {
                    final config = _notificationConfig[type]!;
                    final isSelected = type == _selectedType;

                    return FilterChip(
                      selected: isSelected,
                      label: Text('${config['emoji']} ${config['title']}'),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedType = type);
                        }
                      },
                      selectedColor: context.colors.primaryContainer,
                      checkmarkColor: context.colors.primary,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Delay Slider
                Text(
                  'Delay: ${_getDelayLabel(_delaySeconds)}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Preset buttons
                Wrap(
                  spacing: 8,
                  children: _delayPresets.map((preset) {
                    final isSelected = _delaySeconds == preset;

                    return ChoiceChip(
                      label: Text(_getDelayLabel(preset)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _delaySeconds = preset);
                        }
                      },
                      selectedColor: context.colors.secondaryContainer,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Custom slider
                Slider(
                  value: _delaySeconds,
                  min: 5,
                  max: 300,
                  divisions: 59,
                  label: _getDelayLabel(_delaySeconds),
                  onChanged: (value) {
                    setState(() => _delaySeconds = value);
                  },
                ),

                const SizedBox(height: 24),

                // Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _notificationConfig[_selectedType]!['title']!,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _notificationConfig[_selectedType]!['body']!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '→ Deep link: ${_notificationConfig[_selectedType]!['route']}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Schedule Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _scheduleNotification,
                    icon: Icon(AppIcons.schedule, size: AppIconSize.small),
                    label: Text('Schedule Notification (${_getDelayLabel(_delaySeconds)})'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Test Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.tertiaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.colors.tertiary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.info,
                        size: AppIconSize.small,
                        color: context.colors.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cold-start: Close app completely\nWarm-start: Put app in background',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
