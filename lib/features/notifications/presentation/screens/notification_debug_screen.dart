/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/screens
/// 🎯 Feature: notification_debug
/// 🔧 Type: screen (debug)
/// 🌍 Localization: N/A (debug only)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// NOTIFICATION DEBUG SCREEN - Manual testing interface for notification services
///
/// Features:
/// - Schedule daily reminders manually
/// - Check streak achievements manually
/// - View pending notifications count
/// - Reset achievements
///
/// USAGE: Only for development/testing, not visible to end users
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/services/daily_workout_reminder_service.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/services/streak_achievement_notification_service.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';

class NotificationDebugScreen extends ConsumerWidget {
  const NotificationDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStreakAsync = ref.watch(currentStreakProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(AppIcons.bug, color: context.colors.primary),
            const SizedBox(width: 8),
            const Text('Notification Debug'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Debug & Test Notification Services',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manual testing interface for development',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 32),

            // Daily Workout Reminders Section
            _buildSectionHeader(context, '📅 Daily Workout Reminders'),
            const SizedBox(height: 12),

            _buildDebugButton(
              context,
              icon: AppIcons.notifications,
              label: 'Schedule 30 Days',
              subtitle: 'Schedule daily reminders (9:00 AM)',
              onPressed: () => _scheduleDailyReminders(context, ref),
            ),

            const SizedBox(height: 8),

            _buildDebugButton(
              context,
              icon: AppIcons.delete,
              label: 'Cancel All Reminders',
              subtitle: 'Remove all pending workout reminders',
              color: context.colors.error,
              onPressed: () => _cancelAllReminders(context, ref),
            ),

            const SizedBox(height: 8),

            _buildDebugButton(
              context,
              icon: AppIcons.info,
              label: 'Show Pending Count',
              subtitle: 'Display number of scheduled reminders',
              onPressed: () => _showPendingCount(context, ref),
            ),

            const SizedBox(height: 32),

            // Streak Achievements Section
            _buildSectionHeader(context, '🔥 Streak Achievements'),
            const SizedBox(height: 12),

            // Current streak display
            currentStreakAsync.when(
              data: (streak) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.flame,
                      color: context.colors.onPrimaryContainer,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Streak',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          '$streak days',
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: context.colors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error loading streak: $error'),
            ),

            const SizedBox(height: 12),

            _buildDebugButton(
              context,
              icon: AppIcons.trophy,
              label: 'Check Streak Achievement',
              subtitle: 'Manually trigger streak milestone check',
              onPressed: () => _checkStreakAchievement(context, ref),
            ),

            const SizedBox(height: 8),

            _buildDebugButton(
              context,
              icon: AppIcons.refresh,
              label: 'Reset Achievements',
              subtitle: 'Clear all achievement flags (for testing)',
              color: context.colors.warning,
              onPressed: () => _resetAchievements(context, ref),
            ),

            const SizedBox(height: 8),

            _buildDebugButton(
              context,
              icon: AppIcons.list,
              label: 'Show Achieved Milestones',
              subtitle: 'Display which milestones have been unlocked',
              onPressed: () => _showAchievedMilestones(context, ref),
            ),

            const SizedBox(height: 40),

            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        AppIcons.info,
                        color: context.colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Debug Info',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Milestones: 3, 7, 14, 30 days',
                    style: context.textTheme.bodySmall,
                  ),
                  Text(
                    'Default time: 9:00 AM',
                    style: context.textTheme.bodySmall,
                  ),
                  Text(
                    'Schedule window: 30 days',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
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

  Widget _buildDebugButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? context.colors.primary,
        foregroundColor:
            color != null ? context.colors.onError : context.colors.onPrimary,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color != null
                        ? context.colors.onError
                        : context.colors.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: (color != null
                            ? context.colors.onError
                            : context.colors.onPrimary)
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action Handlers

  Future<void> _scheduleDailyReminders(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final reminderService = ref.read(dailyWorkoutReminderServiceProvider);
      await reminderService.scheduleDailyReminders();

      final count = reminderService.getPendingReminderCount();

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          'Scheduled $count daily reminders',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'Failed to schedule reminders: $e',
        );
      }
    }
  }

  Future<void> _cancelAllReminders(BuildContext context, WidgetRef ref) async {
    try {
      final reminderService = ref.read(dailyWorkoutReminderServiceProvider);
      await reminderService.cancelAllReminders();

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          'All reminders cancelled',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'Failed to cancel reminders: $e',
        );
      }
    }
  }

  void _showPendingCount(BuildContext context, WidgetRef ref) {
    try {
      final reminderService = ref.read(dailyWorkoutReminderServiceProvider);
      final count = reminderService.getPendingReminderCount();
      final nextReminder = reminderService.getNextReminderTime();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pending Reminders'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: $count reminders'),
                if (nextReminder != null) ...[
                  const SizedBox(height: 8),
                  Text('Next reminder:'),
                  Text(
                    '${nextReminder.toLocal()}',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'Failed to get pending count: $e',
        );
      }
    }
  }

  Future<void> _checkStreakAchievement(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final streakService =
          ref.read(streakAchievementNotificationServiceProvider);
      await streakService.checkAndNotifyStreak();

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          'Streak achievement check completed',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'Failed to check streak: $e',
        );
      }
    }
  }

  Future<void> _resetAchievements(BuildContext context, WidgetRef ref) async {
    try {
      final streakService =
          ref.read(streakAchievementNotificationServiceProvider);
      await streakService.resetAchievements();

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          'All achievements reset',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'Failed to reset achievements: $e',
        );
      }
    }
  }

  Future<void> _showAchievedMilestones(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final streakService =
          ref.read(streakAchievementNotificationServiceProvider);
      final achieved = await streakService.getAchievedMilestones();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Achieved Milestones'),
            content: achieved.isEmpty
                ? const Text('No milestones achieved yet')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: achieved
                        .map(
                          (days) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  AppIcons.checkCircle,
                                  color: context.colors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text('$days days'),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'Failed to get milestones: $e',
        );
      }
    }
  }
}
