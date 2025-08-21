import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier(ref);
});

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.where((n) => !n.isRead).length;
});

final recentNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications
      .where((n) => n.isRecent)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  NotificationNotifier(this.ref) : super([]) {
    _loadNotifications();
    _setupProgressListeners();
  }

  Future<void> _loadNotifications() async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser?.uid == null) return;
      
      // Carica notifiche da Firebase
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('notifications')
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();
      
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromJson({
            ...doc.data(),
            'id': doc.id,
          }))
          .toList();
      
      state = notifications;
      
      // Se è la prima volta che l'utente apre l'app, crea notifica di benvenuto
      if (notifications.isEmpty) {
        _createWelcomeNotification();
      }
    } catch (e) {
      print('Errore nel caricamento notifiche: $e');
    }
  }
  
  void _setupProgressListeners() {
    // Ascolta i progressi dell'utente per generare notifiche intelligenti
    ref.listen(currentStreakProvider, (previous, next) {
      if (previous != null && next.hasValue) {
        final previousStreak = previous.asData?.value ?? 0;
        final currentStreak = next.asData!.value;
        
        // Notifica per nuovi achievement di streak
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
    
    // Ascolta i cambiamenti di volume
    ref.listen(quickStatsProvider, (previous, next) {
      if (previous != null && next.hasValue && next.asData?.value != null) {
        final stats = next.asData!.value!;
        final prevStats = previous.asData?.value;
        
        if (prevStats != null && stats.volumeIncrease > 20) {
          addProgressUpdate(
            'Volume aumentato del ${stats.formattedVolumeIncrease}! Stai diventando più forte 💪'
          );
        }
        
        // Notifica per nuovo PR
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
      action: NotificationAction(
        label: 'Inizia ora',
        route: '/workout',
      ),
    ));
  }

  Future<void> addNotification(AppNotification notification) async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser?.uid == null) return;
      
      // Salva su Firebase
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
      
      // Aggiorna stato locale
      state = [notification, ...state];
    } catch (e) {
      print('Errore nel salvare notifica: $e');
      // Aggiungi comunque localmente
      state = [notification, ...state];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser?.uid != null) {
        // Aggiorna su Firebase
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('notifications')
            .doc(notificationId)
            .update({'is_read': true});
      }
      
      // Aggiorna stato locale
      state = state.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
    } catch (e) {
      print('Errore nel marcare come letta: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser?.uid != null) {
        // Batch update su Firebase
        final batch = _firestore.batch();
        
        for (final notification in state.where((n) => !n.isRead)) {
          final docRef = _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection('notifications')
              .doc(notification.id);
          batch.update(docRef, {'is_read': true});
        }
        
        await batch.commit();
      }
      
      // Aggiorna stato locale
      state = state.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();
    } catch (e) {
      print('Errore nel marcare tutte come lette: $e');
    }
  }

  Future<void> removeNotification(String notificationId) async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser?.uid != null) {
        // Rimuovi da Firebase
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('notifications')
            .doc(notificationId)
            .delete();
      }
      
      // Aggiorna stato locale
      state = state.where((notification) => notification.id != notificationId).toList();
    } catch (e) {
      print('Errore nella rimozione notifica: $e');
    }
  }

  Future<void> clearOldNotifications() async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser?.uid != null) {
        final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
        
        // Query per notifiche vecchie
        final oldNotifications = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('notifications')
            .where('created_at', isLessThan: Timestamp.fromDate(oneWeekAgo))
            .get();
        
        // Batch delete
        final batch = _firestore.batch();
        for (final doc in oldNotifications.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
      
      // Aggiorna stato locale
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      state = state.where((notification) {
        return notification.createdAt.isAfter(oneWeekAgo);
      }).toList();
    } catch (e) {
      print('Errore nella pulizia notifiche vecchie: $e');
    }
  }

  // Factory methods per creare notifiche specifiche
  void addAITip(String tip) {
    addNotification(AppNotification.create(
      type: NotificationType.aiTip,
      title: 'AI Coach',
      message: tip,
      emoji: '🧠',
      action: NotificationAction(
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
      action: NotificationAction(
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