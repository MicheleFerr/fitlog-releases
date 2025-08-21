import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../workout/domain/entities/exercise_activity.dart';
import '../../../workout/data/repositories/exercise_activity_repository.dart';
import '../../domain/entities/progress_data.dart';

/// Provider per i dati di progresso reali basati sui workout salvati in Firestore
final progressDataProvider = FutureProvider<ProgressData?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.email == null) {
    return null;
  }

  final repository = ExerciseActivityRepository();
  final activities = await repository.getUserActivities(userEmail: currentUser!.email!);
  
  return ProgressData.fromActivities(activities);
});

/// Provider per le statistiche rapide mostrate nella home
final quickStatsProvider = FutureProvider<QuickStats?>((ref) async {
  final progressData = await ref.watch(progressDataProvider.future);
  return progressData?.quickStats;
});

/// Provider per l'attività più recente (per streak)
final recentActivityProvider = FutureProvider<DateTime?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.email == null) {
    return null;
  }

  final firestore = FirebaseFirestore.instance;
  // Prova prima con 'email' (formato attuale nel DB)
  var query = await firestore
      .collection('exerciseActivities')
      .where('email', isEqualTo: currentUser!.email!.toLowerCase().trim())
      .orderBy('createdAt', descending: true)
      .limit(1)
      .get();
  
  // Se non trova nulla, prova con 'userEmail' (formato vecchio)
  if (query.docs.isEmpty) {
    query = await firestore
        .collection('exerciseActivities')
        .where('userEmail', isEqualTo: currentUser!.email!.toLowerCase().trim())
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
  }

  if (query.docs.isEmpty) return null;
  
  final doc = query.docs.first;
  final timestamp = doc.data()['createdAt'] as Timestamp?;
  return timestamp?.toDate();
});

/// Provider per il numero totale di workout completati
final completedWorkoutsCountProvider = FutureProvider<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.email == null) {
    return 0;
  }
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Prima prova con 'email'
    var query = await firestore
        .collection('exerciseActivities')
        .where('email', isEqualTo: currentUser!.email!.toLowerCase().trim())
        .get();
    
    // Se non trova nulla, prova con 'userEmail'
    if (query.docs.isEmpty) {
      query = await firestore
          .collection('exerciseActivities')
          .where('userEmail', isEqualTo: currentUser!.email!.toLowerCase().trim())
          .get();
    }
    
    // Conta i workout unici per giorno
    final Set<String> uniqueDays = {};
    for (final doc in query.docs) {
      final timestamp = doc.data()['createdAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dayKey = '${date.year}-${date.month}-${date.day}';
        uniqueDays.add(dayKey);
      }
    }
    
    return uniqueDays.length;
  } catch (e) {
    print('Error getting workout count: $e');
    return 0;
  }
});

/// Provider per calcolare lo streak di giorni consecutivi
final currentStreakProvider = FutureProvider<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.email == null) {
    return 0;
  }

  final firestore = FirebaseFirestore.instance;
  
  // Prendi gli ultimi 30 giorni di attività per calcolare lo streak
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  
  // Prova prima con 'email' (formato attuale nel DB)
  var query = await firestore
      .collection('exerciseActivities')
      .where('email', isEqualTo: currentUser!.email!.toLowerCase().trim())
      .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
      .orderBy('createdAt', descending: true)
      .get();
  
  // Se non trova nulla, prova con 'userEmail' (formato vecchio)
  if (query.docs.isEmpty) {
    query = await firestore
        .collection('exerciseActivities')
        .where('userEmail', isEqualTo: currentUser!.email!.toLowerCase().trim())
        .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('createdAt', descending: true)
        .get();
  }

  if (query.docs.isEmpty) return 0;

  // Raggruppa per giorni
  final Map<String, bool> workoutDays = {};
  for (final doc in query.docs) {
    final timestamp = doc.data()['createdAt'] as Timestamp?;
    if (timestamp != null) {
      final date = timestamp.toDate();
      final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      workoutDays[dayKey] = true;
    }
  }

  // Calcola streak partendo da oggi
  int streak = 0;
  final today = DateTime.now();
  
  // Prima controlla se c'è un workout oggi o nei giorni recenti
  for (int i = 0; i < 30; i++) {
    final checkDate = today.subtract(Duration(days: i));
    final dayKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
    
    debugPrint('DEBUG Streak: Controllo giorno $dayKey - Presente: ${workoutDays.containsKey(dayKey)}');
    
    if (workoutDays.containsKey(dayKey)) {
      streak++;
    } else if (i <= 1) {
      // Se non c'è workout oggi o ieri, continua a cercare
      continue;
    } else {
      // Interrompi solo se c'è già uno streak e manca un giorno
      if (streak > 0) break;
    }
  }

  return streak;
});

/// Provider per la frequenza settimanale media
final weeklyFrequencyProvider = FutureProvider<double>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.email == null) {
    print('DEBUG Frequenza: Nessun utente autenticato');
    return 0.0;
  }

  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  
  print('DEBUG Frequenza: Data attuale: ${now.toString()}');
  print('DEBUG Frequenza: Cercando workout dal ${thirtyDaysAgo.toString()} per ${currentUser?.email}');
  
  // Prova prima con 'email' (formato attuale nel DB)
  var query = await firestore
      .collection('exerciseActivities')
      .where('email', isEqualTo: currentUser!.email!.toLowerCase().trim())
      .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
      .get();
  
  // Se non trova nulla, prova con 'userEmail' (formato vecchio)
  if (query.docs.isEmpty) {
    print('DEBUG Frequenza: Nessun documento con campo "email", provo con "userEmail"');
    query = await firestore
        .collection('exerciseActivities')
        .where('userEmail', isEqualTo: currentUser!.email!.toLowerCase().trim())
        .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();
  }

  print('DEBUG Frequenza: Trovati ${query.docs.length} documenti');
  
  if (query.docs.isEmpty) return 0.0;

  // Conta i giorni unici con workout per ogni settimana
  final Map<int, Set<String>> workoutDaysByWeek = {};
  
  for (final doc in query.docs) {
    final data = doc.data();
    final timestamp = data['createdAt'] as Timestamp?;
    // Prova sia 'schedaName' che 'workoutName' per compatibilità
    final workoutName = data['schedaName'] as String? ?? 
                        data['workoutName'] as String? ?? 
                        'Workout';
    
    if (timestamp != null) {
      final date = timestamp.toDate();
      
      // Per gestire correttamente i workout di oggi, usa solo la data senza orario
      final nowDate = DateTime(now.year, now.month, now.day);
      final workoutDate = DateTime(date.year, date.month, date.day);
      
      // Calcola la differenza in giorni basandosi solo sulla data
      final daysDifference = nowDate.difference(workoutDate).inDays;
      
      print('DEBUG: Workout "$workoutName" del ${date.toString()}');
      print('DEBUG: Data workout (solo giorno): $workoutDate, Oggi: $nowDate, Differenza giorni: $daysDifference');
      
      // Per la frequenza, conta solo i giorni unici con workout negli ultimi 30 giorni
      if (daysDifference >= 0 && daysDifference < 30) {
        // Determina in quale settimana ricade per il calcolo della media
        int weekNumber = daysDifference ~/ 7;
        
        print('DEBUG: Assegnato alla settimana $weekNumber (giorni fa: $daysDifference)');
        
        if (weekNumber < 5) { // Massimo 4.x settimane in 30 giorni
          workoutDaysByWeek.putIfAbsent(weekNumber, () => <String>{});
          // Usa solo la data (anno-mese-giorno) per identificare giorni unici
          final dayKey = '${date.year}-${date.month}-${date.day}';
          workoutDaysByWeek[weekNumber]!.add(dayKey);
        }
      }
    }
  }

  // Debug: mostra workout per settimana
  workoutDaysByWeek.forEach((week, days) {
    print('DEBUG Frequenza: Settimana $week - ${days.length} giorni con workout');
  });

  // Conta il totale di giorni con workout negli ultimi 30 giorni
  final totalWorkoutDays = workoutDaysByWeek.values.fold(0, (sum, days) => sum + days.length);
  
  // Calcola la media settimanale basata su 30 giorni (circa 4.3 settimane)
  final weeksIn30Days = 30.0 / 7.0; // circa 4.3 settimane
  final average = totalWorkoutDays / weeksIn30Days;
  
  print('DEBUG Frequenza: Totale giorni con workout in 30 giorni: $totalWorkoutDays');
  print('DEBUG Frequenza: Media settimanale: ${average.toStringAsFixed(1)} giorni/settimana');
  
  return average;
});