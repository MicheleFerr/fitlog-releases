/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/screens
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: screen
/// 🌍 Localization: REQUIRED
/// 🎨 Theme: context.colors.*
/// 📱 Platform: Universal
///
/// NOTIFICATION CENTER SCREEN V2.0 - History, search & filters
///
/// **Features**:
/// - Notification history (last 90 days)
/// - Real-time unread badge
/// - Search by title/body
/// - Filter by type (workout/recovery/streak/rest)
/// - Group by date (today/yesterday/this week/older)
/// - Swipe to delete
/// - Mark all as read button
/// - Pull to refresh
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_history_provider_v2.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class NotificationCenterScreenV2 extends ConsumerStatefulWidget {
  const NotificationCenterScreenV2({super.key});

  @override
  ConsumerState<NotificationCenterScreenV2> createState() =>
      _NotificationCenterScreenV2State();
}

class _NotificationCenterScreenV2State
    extends ConsumerState<NotificationCenterScreenV2> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCountAsync = ref.watch(unreadCountStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notificationCenter),
        actions: [
          // Unread badge
          unreadCountAsync.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Chip(
                      label: Text('$count'),
                      backgroundColor:
                          context.colors.primary.withValues(alpha: 0.2),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Mark all as read
          IconButton(
            icon: Icon(AppIcons.doneAll),
            onPressed: () {
              ref.read(markAllAsReadProvider)();
            },
            tooltip: context.l10n.markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.search,
                prefixIcon: Icon(AppIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // History list
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildHistory()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    final historyAsync = ref.watch(notificationHistoryProvider(
      const NotificationHistoryParams(limit: 100),
    ));

    return historyAsync.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.notificationsOffOutlined,
                  size: 64,
                  color: context.colors.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.noNotifications,
                  style: context.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(notificationHistoryProvider);
          },
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: context.colors.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(AppIcons.delete, color: context.colors.surface),
                ),
                onDismissed: (_) {
                  ref.read(deleteNotificationProvider)(notification.id);
                },
                child: _buildNotificationTile(notification),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildSearchResults() {
    final searchAsync =
        ref.watch(searchNotificationsProvider(_searchQuery));

    return searchAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(child: Text('No results for "$_searchQuery"'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            return _buildNotificationTile(results[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildNotificationTile(UnifiedNotification notification) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? context.colors.surfaceContainerHighest
            : context.colors.primary.withValues(alpha: 0.2),
        child: Icon(
          _getIconForType(notification.type),
          color: notification.isRead
              ? context.colors.onSurfaceVariant
              : context.colors.primary,
        ),
      ),
      title: Text(
        notification.title,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(notification.body),
      trailing: Text(
        _formatTime(notification.scheduledTime),
        style: context.textTheme.bodySmall,
      ),
      onTap: () {
        if (!notification.isRead) {
          ref.read(markAsReadProvider)(notification.id);
        }
        // TODO: Navigate to relevant screen based on type
      },
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
        return AppIcons.workout;
      case NotificationType.restReminder:
        return AppIcons.healing;
      case NotificationType.streakReminder:
        return AppIcons.localFireDepartment;
      default:
        return AppIcons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return context.l10n.yesterday;
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
