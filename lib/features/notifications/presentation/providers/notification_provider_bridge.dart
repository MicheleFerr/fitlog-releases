import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification_state.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/unified_notification_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
import 'package:flutter/foundation.dart';

/// Bridge provider that maintains backward compatibility while migrating to unified system
/// This allows gradual migration of all components without breaking existing functionality
/// 
/// MIGRATION TIMELINE:
/// 1. Deploy this bridge (maintains existing API)
/// 2. Update components one by one to use unified provider directly
/// 3. Remove this bridge once migration is complete
@Deprecated('Use unifiedNotificationProvider directly. This bridge will be removed in next version.')
final notificationProvider = StateNotifierProvider<NotificationBridgeNotifier, List<AppNotification>>((ref) {
  return NotificationBridgeNotifier(ref);
});

/// Legacy provider aliases for backward compatibility
@Deprecated('Use unreadNotificationCountProvider from unified_notification_provider.dart')
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(unreadNotificationCountProvider);
});

@Deprecated('Use todayNotificationsProvider from unified_notification_provider.dart')
final recentNotificationsProvider = Provider<List<AppNotification>>((ref) {
  // For now, return empty list until full bridge implementation
  // This prevents breaking existing code while migration is in progress
  return <AppNotification>[];
});

/// Bridge notifier that wraps the unified provider to maintain backward compatibility
class NotificationBridgeNotifier extends StateNotifier<List<AppNotification>> {
  
  NotificationBridgeNotifier(this.ref) : super([]) {
    // Listen to unified provider and convert to legacy format
    ref.listen(unifiedNotificationProvider, (previous, next) {
      _syncFromUnified(next);
    });
    
    _loadInitialNotifications();
    _setupProgressListeners();
  }
  final Ref ref;

  void _syncFromUnified(UnifiedNotificationState unifiedState) {
    // For now, keep existing notifications to prevent data loss during migration
    // Full conversion will be implemented in next phase
    if (kDebugMode) {
      debugPrint('Unified notification state updated: ${unifiedState.notifications.length} notifications');
    }
  }

  Future<void> _loadInitialNotifications() async {
    // Delegate to unified provider - it will handle loading and sync
    try {
      final unifiedProvider = ref.read(unifiedNotificationProvider.notifier);
      // Let unified provider initialize - we'll receive updates via listener
      
      // If empty after initialization, create welcome notification
      if (state.isEmpty) {
        _createWelcomeNotification();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error during initial notification load: $e');
      }
    }
  }
  
  void _setupProgressListeners() {
    // Keep existing progress listeners for fitness-specific notifications
    // These will be gradually moved to intelligent notification service
    
    ref.listen(currentStreakProvider, (previous, next) {
      if (previous != null && next.hasValue) {
        final previousStreak = previous.asData?.value ?? 0;
        final currentStreak = next.asData!.value;
        
        // Generate achievement notifications
        if (currentStreak > previousStreak) {
          if (currentStreak == 3) {
            addAchievement(
              '🔥 Streak di 3 giorni!',
              'Ottimo inizio! Continua così per sbloccare nuovi achievement.'
            );
          } else if (currentStreak == 7) {
            addAchievement(
              '⚡ Consistency Master',
              'Una settimana intera di allenamenti! Sei sulla strada giusta.'
            );
          } else if (currentStreak == 14) {
            addAchievement(
              '💎 Due settimane di fuoco!',
              '14 giorni consecutivi! La tua dedizione sta dando frutti.'
            );
          } else if (currentStreak == 30) {
            addAchievement(
              '🏆 Leggenda del Fitness',
              '30 giorni consecutivi! Sei entrato nell\'élite del fitness!'
            );
          }
        }
      }
    });
    
    ref.listen(quickStatsProvider, (previous, next) {
      if (previous != null && next.hasValue && next.asData?.value != null) {
        final stats = next.asData!.value!;
        final prevStats = previous.asData?.value;
        
        if (prevStats != null && stats.volumeIncrease > 20) {
          addProgressUpdate(
            'Volume aumentato del ${stats.formattedVolumeIncrease}! Stai diventando più forte 💪'
          );
        }
        
        // Notification for new PR
        if (prevStats != null && stats.maxPR > prevStats.maxPR) {
          addMilestone(
            'Nuovo Personal Record: ${stats.formattedMaxPR} su ${stats.prExercise}! 🏋️',
            {'pr': stats.maxPR, 'exercise': stats.prExercise}
          );
        }
      }
    });
  }
  
  void _createWelcomeNotification() {
    addNotification(AppNotification.create(
      type: NotificationType.system,
      title: 'Benvenuto in GymBro! 👋',
      message: 'Inizia il tuo viaggio fitness. Tocca la campanella per vedere i tuoi progressi e ricevere consigli personalizzati.',
      emoji: '🎯',
      action: const NotificationAction(
        label: 'Inizia ora',
        route: '/workout',
      ),
    ));
  }

  /// Add notification through legacy system but maintain state
  Future<void> addNotification(AppNotification notification) async {
    try {
      // For now, just add to local state to maintain functionality
      // Full unified provider integration will come in next phase
      state = [notification, ...state];
      
      // Log for debugging
      if (kDebugMode) {
        debugPrint('Added notification via bridge: ${notification.title}');
      }
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding notification through bridge: $e');
      }
      // Still add locally as fallback
      state = [notification, ...state];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Try unified provider first
      final unifiedProvider = ref.read(unifiedNotificationProvider.notifier);
      await unifiedProvider.markAsRead(notificationId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking as read through bridge: $e');
      }
    }
    
    // Update local state regardless
    state = state.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  Future<void> markAllAsRead() async {
    try {
      // Try unified provider first
      final unifiedProvider = ref.read(unifiedNotificationProvider.notifier);
      await unifiedProvider.markAllAsRead();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking all as read through bridge: $e');
      }
    }
    
    // Update local state regardless
    state = state.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();
  }

  Future<void> removeNotification(String notificationId) async {
    try {
      // Try unified provider first
      final unifiedProvider = ref.read(unifiedNotificationProvider.notifier);
      await unifiedProvider.cancelNotification(notificationId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error removing notification through bridge: $e');
      }
    }
    
    // Update local state regardless
    state = state.where((notification) => notification.id != notificationId).toList();
  }

  Future<void> clearOldNotifications() async {
    try {
      // This functionality will be handled by unified provider's cleanup system
      final unifiedProvider = ref.read(unifiedNotificationProvider.notifier);
      await unifiedProvider.clearAllNotifications();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing old notifications through bridge: $e');
      }
    }
    
    // Fallback: Clear local state of old notifications
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    state = state.where((notification) {
      return notification.createdAt.isAfter(oneWeekAgo);
    }).toList();
  }

  // Factory methods for creating specific notifications - maintain exact same API
  void addAITip(String tip) {
    addNotification(AppNotification.create(
      type: NotificationType.aiTip,
      title: 'AI Coach',
      message: tip,
      emoji: '🧠',
      action: const NotificationAction(
        label: 'Vedi dettagli',
        route: '/ai-coach',
      ),
    ));
  }

  void addAchievement(String title, String description) {
    addNotification(AppNotification.create(
      type: NotificationType.achievement,
      title: title,
      message: description,
      emoji: '🏆',
      action: const NotificationAction(
        label: 'Vedi achievement',
        route: '/achievements',
      ),
    ));
  }

  void addMilestone(String milestone, Map<String, dynamic> data) {
    addNotification(AppNotification.create(
      type: NotificationType.milestone,
      title: 'Milestone Raggiunto!',
      message: milestone,
      emoji: '🎯',
      data: data,
    ));
  }

  void addProgressUpdate(String progress) {
    addNotification(AppNotification.create(
      type: NotificationType.progress,
      title: 'Aggiornamento Progressi',
      message: progress,
      emoji: '📈',
    ));
  }
}