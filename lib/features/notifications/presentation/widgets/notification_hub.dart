import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
// MIGRATION: Using bridge provider for backward compatibility while migrating to unified system
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_provider_bridge.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class NotificationHub extends ConsumerWidget {
  const NotificationHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);
    
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showNotificationPanel(context, ref),
              borderRadius: BorderRadius.circular(22),
              child: Icon(
                Icons.notifications_outlined,
                color: context.colors.surface,
                size: 22,
              ),
            ),
          ),
        ),
        
        // Badge per notifiche non lette
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: context.colors.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.colors.surface,
                  width: 2,
                ),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(
                  color: context.colors.surface,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationPanel(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    );
  }
}

class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final recentNotifications = ref.watch(recentNotificationsProvider);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).notifications ?? 'Notifiche',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (notifications.any((n) => !n.isRead))
                  TextButton(
                    onPressed: () {
                      ref.read(notificationProvider.notifier).markAllAsRead();
                    },
                    child: Text(
                      AppLocalizations.of(context).markAllAsRead ?? 'Segna tutte lette',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Quick stats section
          _buildQuickStats(context, ref),
          
          SizedBox(height: 16),
          
          // Notifications list
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationTile(
                        notification: notification,
                        onTap: () => _handleNotificationTap(context, ref, notification),
                        onDismiss: () => ref.read(notificationProvider.notifier)
                            .removeNotification(notification.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    // Ottieni i dati reali dell'utente
    final streakAsync = ref.watch(currentStreakProvider);
    final quickStatsAsync = ref.watch(quickStatsProvider);
    final frequencyAsync = ref.watch(weeklyFrequencyProvider);
    final user = ref.watch(authServiceProvider).currentUser;
    
    // Calcola numero di achievement basato sullo streak
    final streak = streakAsync.asData?.value ?? 0;
    int achievements = 0;
    if (streak >= 3) achievements++;
    if (streak >= 7) achievements++;
    if (streak >= 14) achievements++;
    if (streak >= 30) achievements++;
    
    // Calcola workout totali questa settimana
    final weeklyWorkouts = (frequencyAsync.asData?.value ?? 0.0).round();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📊',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).quickStats ?? 'I tuoi progressi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (user != null)
                Icon(
                  AppIcons.verifiedUser,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                ),
            ],
          ),
          SizedBox(height: 12),
          if (streakAsync.isLoading || quickStatsAsync.isLoading)
            Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context, 
                    '🔥', 
                    streak.toString(), 
                    AppLocalizations.of(context).streak ?? 'Streak'
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context, 
                    '💪', 
                    weeklyWorkouts.toString(), 
                    AppLocalizations.of(context).thisWeek ?? 'Settimana'
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context, 
                    '🏆', 
                    achievements.toString(), 
                    AppLocalizations.of(context).achievements ?? 'Obiettivi'
                  ),
                ),
              ],
            ),
          if (quickStatsAsync.hasValue && quickStatsAsync.value != null)
            if (quickStatsAsync.value!.volumeIncrease > 0) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: context.colors.success,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Volume +${quickStatsAsync.value!.formattedVolumeIncrease}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 20)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.notificationsNone,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noNotifications ?? 'Nessuna notifica',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).notificationsDescription ?? 'Ti terremo aggiornato sui tuoi progressi!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, WidgetRef ref, AppNotification notification) {
    // Segna come letta
    ref.read(notificationProvider.notifier).markAsRead(notification.id);
    
    // Chiudi il panel
    Navigator.pop(context);
    
    // Naviga se ha un'azione
    if (notification.action != null) {
      context.push(notification.action!.route);
    }
  }
}

class NotificationTile extends StatelessWidget {

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: context.colors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: context.colors.surface,
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead 
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: notification.isRead 
              ? Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2))
              : Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Emoji/Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getTypeColor(context, notification.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        notification.emoji,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              notification.timeAgo,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (notification.action != null) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                notification.action!.label,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Unread indicator
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.aiTip:
        return context.colors.tertiary;
      case NotificationType.achievement:
        return context.colors.warning;
      case NotificationType.milestone:
        return context.colors.success;
      case NotificationType.progress:
        return context.colors.primary;
      case NotificationType.reminder:
        return context.colors.secondary;
      case NotificationType.social:
        return Colors.pink;
      case NotificationType.system:
        return context.colors.surfaceContainerHighest;
    }
  }
}