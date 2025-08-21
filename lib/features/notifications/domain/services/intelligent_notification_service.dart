/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain
 * 🎯 Feature: notifications
 * 🔧 Type: service
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: Provider
 * - Firebase: Firestore
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/notification.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../progress/domain/entities/progress_data.dart';
import '../../../workout/domain/entities/workout.dart';

final intelligentNotificationServiceProvider = Provider<IntelligentNotificationService>((ref) {
  return IntelligentNotificationService(ref);
});

class IntelligentNotificationService {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  IntelligentNotificationService(this.ref);
  
  /// Analizza il workout completato e genera notifiche appropriate
  Future<List<AppNotification>> analyzeWorkoutCompletion(Workout workout) async {
    final notifications = <AppNotification>[];
    
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser?.uid == null) return notifications;
      
      // Analizza performance del workout
      final totalVolume = _calculateWorkoutVolume(workout);
      final totalSets = _countTotalSets(workout);
      final duration = workout.endTime?.difference(workout.startTime ?? DateTime.now());
      
      // Recupera statistiche precedenti per confronto
      final previousWorkouts = await _getPreviousWorkouts(currentUser!.uid, workout.name);
      
      if (previousWorkouts.isNotEmpty) {
        final avgVolume = _calculateAverageVolume(previousWorkouts);
        final volumeIncrease = ((totalVolume - avgVolume) / avgVolume * 100).round();
        
        // Notifica per miglioramento significativo
        if (volumeIncrease > 10) {
          notifications.add(AppNotification.create(
            type: NotificationType.progress,
            title: '📈 Performance Migliorata!',
            message: 'Volume aumentato del $volumeIncrease% rispetto alla media. Stai diventando più forte!',
            emoji: '💪',
            data: {
              'volume': totalVolume,
              'increase': volumeIncrease,
              'workout': workout.name,
            },
          ));
        }
        
        // Notifica per nuovo PR
        final newPRs = _checkForNewPRs(workout, previousWorkouts);
        for (final pr in newPRs) {
          notifications.add(AppNotification.create(
            type: NotificationType.achievement,
            title: '🏆 Nuovo Personal Record!',
            message: '${pr['weight']}kg su ${pr['exercise']}! Hai superato il tuo record precedente di ${pr['previous']}kg',
            emoji: '🎯',
            action: NotificationAction(
              label: 'Vedi dettagli',
              route: '/analytics',
            ),
            data: pr,
          ));
        }
      }
      
      // Suggerimenti AI basati sulla performance
      if (duration != null && duration.inMinutes > 90) {
        notifications.add(AppNotification.create(
          type: NotificationType.aiTip,
          title: '🧠 Suggerimento AI',
          message: 'Workout durato ${duration.inMinutes} minuti. Considera di ridurre i tempi di riposo per ottimizzare l\'allenamento.',
          emoji: '⏱️',
        ));
      }
      
      // Motivazione basata sul numero di workout questa settimana
      final weeklyCount = await _getWeeklyWorkoutCount(currentUser.uid);
      if (weeklyCount == 3) {
        notifications.add(AppNotification.create(
          type: NotificationType.milestone,
          title: '🎯 Obiettivo Settimanale',
          message: 'Terzo workout della settimana! Ancora uno per raggiungere l\'obiettivo ottimale.',
          emoji: '📅',
        ));
      } else if (weeklyCount == 4) {
        notifications.add(AppNotification.create(
          type: NotificationType.achievement,
          title: '⭐ Settimana Perfetta!',
          message: '4 workout questa settimana! Hai raggiunto la frequenza ottimale per risultati eccellenti.',
          emoji: '🌟',
        ));
      }
      
    } catch (e) {
      print('Errore nell\'analisi workout: $e');
    }
    
    return notifications;
  }
  
  /// Genera suggerimenti personalizzati basati sui pattern dell'utente
  Future<AppNotification?> generateDailySuggestion() async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser?.uid == null) return null;
      
      // Analizza pattern di allenamento
      final lastWorkoutDate = await _getLastWorkoutDate(currentUser!.uid);
      final daysSinceLastWorkout = lastWorkoutDate != null 
          ? DateTime.now().difference(lastWorkoutDate).inDays 
          : 999;
      
      // Suggerimenti basati sull'inattività
      if (daysSinceLastWorkout == 2) {
        return AppNotification.create(
          type: NotificationType.reminder,
          title: '💪 Tempo di allenarsi!',
          message: 'Sono passati 2 giorni dall\'ultimo workout. Mantieni il ritmo per non perdere i progressi!',
          emoji: '🏃',
          action: NotificationAction(
            label: 'Inizia workout',
            route: '/workout',
          ),
        );
      } else if (daysSinceLastWorkout >= 3) {
        return AppNotification.create(
          type: NotificationType.aiTip,
          title: '🧠 Coach AI',
          message: 'Dopo ${daysSinceLastWorkout} giorni di riposo, inizia con carichi leggermente ridotti per evitare infortuni.',
          emoji: '⚠️',
          action: NotificationAction(
            label: 'Vedi consigli',
            route: '/workout',
          ),
        );
      }
      
      // Suggerimenti basati sul giorno della settimana
      final weekday = DateTime.now().weekday;
      final mostActiveDay = await _getMostActiveWeekday(currentUser.uid);
      
      if (weekday == mostActiveDay && daysSinceLastWorkout >= 1) {
        return AppNotification.create(
          type: NotificationType.reminder,
          title: '📅 Il tuo giorno preferito!',
          message: 'Di solito ti alleni di ${_getWeekdayName(weekday)}. Pronto per oggi?',
          emoji: '💪',
          action: NotificationAction(
            label: 'Vai!',
            route: '/workout',
          ),
        );
      }
      
    } catch (e) {
      print('Errore nella generazione suggerimento: $e');
    }
    
    return null;
  }
  
  /// Analizza i progressi mensili e genera report
  Future<List<AppNotification>> generateMonthlyReport() async {
    final notifications = <AppNotification>[];
    
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser?.uid == null) return notifications;
      
      // Recupera statistiche del mese
      final monthlyStats = await _getMonthlyStatistics(currentUser!.uid);
      
      if (monthlyStats['totalWorkouts'] > 0) {
        notifications.add(AppNotification.create(
          type: NotificationType.progress,
          title: '📊 Report Mensile',
          message: '${monthlyStats['totalWorkouts']} workout completati, ${monthlyStats['totalVolume']}kg di volume totale, frequenza media: ${monthlyStats['avgFrequency']}/settimana',
          emoji: '📈',
          action: NotificationAction(
            label: 'Vedi analytics',
            route: '/analytics',
          ),
          data: monthlyStats,
        ));
        
        // Achievement per consistenza
        if (monthlyStats['totalWorkouts'] >= 16) {
          notifications.add(AppNotification.create(
            type: NotificationType.achievement,
            title: '🏆 Mese Eccezionale!',
            message: 'Hai mantenuto una frequenza ottimale per tutto il mese. I risultati arriveranno!',
            emoji: '⭐',
          ));
        }
      }
      
    } catch (e) {
      print('Errore nel report mensile: $e');
    }
    
    return notifications;
  }
  
  // Helper methods privati
  
  double _calculateWorkoutVolume(Workout workout) {
    double totalVolume = 0;
    
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          totalVolume += (set.weight ?? 0) * (set.reps ?? 0);
        }
      }
    }
    
    return totalVolume;
  }
  
  int _countTotalSets(Workout workout) {
    int totalSets = 0;
    
    for (final exercise in workout.exercises) {
      totalSets += exercise.sets.where((s) => s.isCompleted).length;
    }
    
    return totalSets;
  }
  
  Future<List<Map<String, dynamic>>> _getPreviousWorkouts(String userId, String workoutName) async {
    try {
      final query = await _firestore
          .collection('exerciseActivities')
          .where('userId', isEqualTo: userId)
          .where('workoutName', isEqualTo: workoutName)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      
      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Errore nel recupero workout precedenti: $e');
      return [];
    }
  }
  
  double _calculateAverageVolume(List<Map<String, dynamic>> workouts) {
    if (workouts.isEmpty) return 0;
    
    double totalVolume = 0;
    for (final workout in workouts) {
      totalVolume += (workout['totalVolume'] ?? 0).toDouble();
    }
    
    return totalVolume / workouts.length;
  }
  
  List<Map<String, dynamic>> _checkForNewPRs(Workout currentWorkout, List<Map<String, dynamic>> previousWorkouts) {
    final prs = <Map<String, dynamic>>[];
    
    for (final exercise in currentWorkout.exercises) {
      double maxWeight = 0;
      
      for (final set in exercise.sets) {
        if (set.isCompleted && (set.weight ?? 0) > maxWeight) {
          maxWeight = set.weight ?? 0;
        }
      }
      
      // Confronta con i precedenti
      double previousMax = 0;
      for (final workout in previousWorkouts) {
        final exercises = workout['exercises'] as List<dynamic>? ?? [];
        for (final ex in exercises) {
          if (ex['name'] == exercise.name) {
            final exMaxWeight = (ex['maxWeight'] ?? 0).toDouble();
            if (exMaxWeight > previousMax) {
              previousMax = exMaxWeight;
            }
          }
        }
      }
      
      if (maxWeight > previousMax && previousMax > 0) {
        prs.add({
          'exercise': exercise.name,
          'weight': maxWeight,
          'previous': previousMax,
          'improvement': maxWeight - previousMax,
        });
      }
    }
    
    return prs;
  }
  
  Future<int> _getWeeklyWorkoutCount(String userId) async {
    try {
      final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      
      final query = await _firestore
          .collection('exerciseActivities')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .get();
      
      return query.docs.length;
    } catch (e) {
      print('Errore nel conteggio settimanale: $e');
      return 0;
    }
  }
  
  Future<DateTime?> _getLastWorkoutDate(String userId) async {
    try {
      final query = await _firestore
          .collection('exerciseActivities')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        final timestamp = query.docs.first.data()['createdAt'] as Timestamp?;
        return timestamp?.toDate();
      }
    } catch (e) {
      print('Errore nel recupero ultima data workout: $e');
    }
    
    return null;
  }
  
  Future<int> _getMostActiveWeekday(String userId) async {
    try {
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final query = await _firestore
          .collection('exerciseActivities')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(monthAgo))
          .get();
      
      final weekdayCount = <int, int>{};
      
      for (final doc in query.docs) {
        final timestamp = doc.data()['createdAt'] as Timestamp?;
        if (timestamp != null) {
          final weekday = timestamp.toDate().weekday;
          weekdayCount[weekday] = (weekdayCount[weekday] ?? 0) + 1;
        }
      }
      
      if (weekdayCount.isEmpty) return 1; // Default lunedì
      
      return weekdayCount.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    } catch (e) {
      print('Errore nel calcolo giorno più attivo: $e');
      return 1;
    }
  }
  
  String _getWeekdayName(int weekday) {
    const days = ['Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato', 'Domenica'];
    return days[weekday - 1];
  }
  
  Future<Map<String, dynamic>> _getMonthlyStatistics(String userId) async {
    try {
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
      
      final query = await _firestore
          .collection('exerciseActivities')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .get();
      
      double totalVolume = 0;
      int totalWorkouts = query.docs.length;
      
      for (final doc in query.docs) {
        totalVolume += (doc.data()['totalVolume'] ?? 0).toDouble();
      }
      
      final weeksInMonth = (DateTime.now().day / 7).ceil();
      final avgFrequency = (totalWorkouts / weeksInMonth).toStringAsFixed(1);
      
      return {
        'totalWorkouts': totalWorkouts,
        'totalVolume': totalVolume.round(),
        'avgFrequency': avgFrequency,
        'month': DateTime.now().month,
        'year': DateTime.now().year,
      };
    } catch (e) {
      print('Errore nelle statistiche mensili: $e');
      return {
        'totalWorkouts': 0,
        'totalVolume': 0,
        'avgFrequency': '0',
      };
    }
  }
}