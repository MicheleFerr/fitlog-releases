import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/progress/domain/entities/progress_data.dart';

/// CRITICAL FIX: Helper to query both 'email' and 'userEmail' fields in parallel
/// This reduces latency from 2x sequential queries to 1x parallel execution
Future<QuerySnapshot> _queryUserActivitiesOptimized({
  required FirebaseFirestore firestore,
  required String userEmail,
  required String orderByField,
  DateTime? startDate,
  DateTime? endDate,
  int? limit,
  bool descending = true,
}) async {
  final normalizedEmail = userEmail.toLowerCase().trim();

  // Execute both queries in parallel
  final futures = [
    _buildQuery(
      firestore: firestore,
      email: normalizedEmail,
      emailField: 'email',
      orderByField: orderByField,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      descending: descending,
    ).get(),
    _buildQuery(
      firestore: firestore,
      email: normalizedEmail,
      emailField: 'userEmail',
      orderByField: orderByField,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      descending: descending,
    ).get(),
  ];

  final results = await Future.wait(futures);

  // Return the result with documents (prefer 'email' if both have data)
  if (results[0].docs.isNotEmpty) {
    return results[0];
  } else {
    return results[1];
  }
}

/// Build Firestore query with common parameters
Query _buildQuery({
  required FirebaseFirestore firestore,
  required String email,
  required String emailField,
  required String orderByField,
  DateTime? startDate,
  DateTime? endDate,
  int? limit,
  bool descending = true,
}) {
  Query query = firestore
      .collection('exerciseActivities')
      .where(emailField, isEqualTo: email);

  // Add date filters if provided
  if (startDate != null) {
    query = query.where(orderByField, isGreaterThan: Timestamp.fromDate(startDate));
  }

  if (endDate != null) {
    query = query.where(orderByField, isLessThan: Timestamp.fromDate(endDate));
  }

  // Add ordering
  query = query.orderBy(orderByField, descending: descending);

  // Add limit if provided
  if (limit != null) {
    query = query.limit(limit);
  }

  return query;
}

/// Provider per i dati di progresso reali basati sui workout salvati in Firestore
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final progressDataProvider = FutureProvider.autoDispose<ProgressData?>((ref) async {
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
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final quickStatsProvider = FutureProvider.autoDispose<QuickStats?>((ref) async {
  final progressData = await ref.watch(progressDataProvider.future);
  return progressData?.quickStats;
});

/// Provider per l'attività più recente (per streak)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final recentActivityProvider = FutureProvider.autoDispose<DateTime?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.email == null) {
    return null;
  }

  // CRITICAL FIX: Use optimized parallel query
  final firestore = FirebaseFirestore.instance;
  final query = await _queryUserActivitiesOptimized(
    firestore: firestore,
    userEmail: currentUser!.email!,
    orderByField: 'createdAt',
    limit: 1,
    descending: true,
  );

  if (query.docs.isEmpty) return null;

  final doc = query.docs.first;
  final data = doc.data() as Map<String, dynamic>?;
  final timestamp = data?['createdAt'] as Timestamp?;
  return timestamp?.toDate();
});

/// Provider per il numero totale di workout completati
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final completedWorkoutsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.email == null) {
    return 0;
  }

  try {
    final firestore = FirebaseFirestore.instance;

    // OTTIMIZZAZIONE: Limita a 365 giorni (1 anno) di workout
    // Per conteggi più vecchi, usare un contatore salvato nel profilo utente
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));

    // CRITICAL FIX: Use optimized parallel query
    final query = await _queryUserActivitiesOptimized(
      firestore: firestore,
      userEmail: currentUser!.email!,
      orderByField: 'createdAt',
      startDate: oneYearAgo,
      limit: 500, // OTTIMIZZAZIONE: Max 500 documenti (più che sufficiente per 1 anno)
      descending: true,
    );

    // Conta i workout unici per giorno
    final Set<String> uniqueDays = {};
    for (final doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      final timestamp = data?['createdAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dayKey = '${date.year}-${date.month}-${date.day}';
        uniqueDays.add(dayKey);
      }
    }

    return uniqueDays.length;
  } catch (e) {
    return 0;
  }
});

/// Provider per calcolare lo streak di giorni consecutivi
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final currentStreakProvider = FutureProvider.autoDispose<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.email == null) {
    debugPrint('🔥 [STREAK DEBUG] No user email - returning 0');
    return 0;
  }

  final firestore = FirebaseFirestore.instance;

  // Prendi gli ultimi 30 giorni di attività per calcolare lo streak
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

  debugPrint('🔥 [STREAK DEBUG] =====================');
  debugPrint('🔥 User email: ${currentUser!.email}');
  debugPrint('🔥 Querying from: $thirtyDaysAgo');
  debugPrint('🔥 Querying to: ${DateTime.now()}');

  // CRITICAL FIX: Use optimized parallel query
  final query = await _queryUserActivitiesOptimized(
    firestore: firestore,
    userEmail: currentUser!.email!,
    orderByField: 'createdAt',
    startDate: thirtyDaysAgo,
    limit: 100, // OTTIMIZZAZIONE: Max 100 workout per calcolare streak (più che sufficiente per 30 giorni)
    descending: true,
  );

  debugPrint('🔥 Query result: ${query.docs.length} documents found');

  if (query.docs.isEmpty) {
    debugPrint('❌ NO WORKOUT FOUND! Possible reasons:');
    debugPrint('  1. Email mismatch - check Firestore for correct email field');
    debugPrint('  2. Timestamp issue - check createdAt field format');
    debugPrint('  3. Security rules blocking query');
    debugPrint('  4. User has no workouts in last 30 days');
    return 0;
  }

  // Log first few documents for debugging
  debugPrint('🔥 First 3 workout documents:');
  for (var i = 0; i < query.docs.length && i < 3; i++) {
    final doc = query.docs[i];
    final data = doc.data() as Map<String, dynamic>?;
    debugPrint('  Doc $i: id=${doc.id}');
    debugPrint('    email: ${data?['email']}');
    debugPrint('    userEmail: ${data?['userEmail']}');
    debugPrint('    createdAt: ${data?['createdAt']}');
    debugPrint('    exerciseName: ${data?['exerciseName']}');
  }

  // Raggruppa per giorni
  final Map<String, bool> workoutDays = {};
  for (final doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>?;
    final timestamp = data?['createdAt'] as Timestamp?;
    if (timestamp != null) {
      final date = timestamp.toDate();
      final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      workoutDays[dayKey] = true;
    }
  }

  // Calcola streak partendo da oggi
  int streak = 0;
  final today = DateTime.now();

  debugPrint('🔥 Calculating streak from workout days: ${workoutDays.keys.toList()}');

  // Prima controlla se c'è un workout oggi o nei giorni recenti
  for (int i = 0; i < 30; i++) {
    final checkDate = today.subtract(Duration(days: i));
    final dayKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

    if (workoutDays.containsKey(dayKey)) {
      streak++;
      debugPrint('  Day $i ($dayKey): ✅ HAS WORKOUT (streak now: $streak)');
    } else if (i <= 1) {
      // Se non c'è workout oggi o ieri, continua a cercare
      debugPrint('  Day $i ($dayKey): ❌ NO WORKOUT (but i <= 1, continuing)');
      continue;
    } else {
      // Interrompi solo se c'è già uno streak e manca un giorno
      if (streak > 0) {
        debugPrint('  Day $i ($dayKey): ❌ NO WORKOUT (breaking streak at $streak)');
        break;
      }
      debugPrint('  Day $i ($dayKey): ❌ NO WORKOUT (no streak yet, continuing)');
    }
  }

  debugPrint('✅ Final streak: $streak days');
  return streak;
});

/// Provider per la frequenza settimanale media
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final weeklyFrequencyProvider = FutureProvider.autoDispose<double>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.email == null) {
    return 0.0;
  }

  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  // CRITICAL FIX: Use optimized parallel query
  final query = await _queryUserActivitiesOptimized(
    firestore: firestore,
    userEmail: currentUser!.email!,
    orderByField: 'createdAt',
    startDate: thirtyDaysAgo,
    limit: 100, // OTTIMIZZAZIONE: Max 100 workout per calcolare frequenza
    descending: true,
  );

  if (query.docs.isEmpty) return 0.0;

  // Conta i giorni unici con workout per ogni settimana
  final Map<int, Set<String>> workoutDaysByWeek = {};

  for (final doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) continue;

    final timestamp = data['createdAt'] as Timestamp?;

    if (timestamp != null) {
      final date = timestamp.toDate();
      
      // Per gestire correttamente i workout di oggi, usa solo la data senza orario
      final nowDate = DateTime(now.year, now.month, now.day);
      final workoutDate = DateTime(date.year, date.month, date.day);
      
      // Calcola la differenza in giorni basandosi solo sulla data
      final daysDifference = nowDate.difference(workoutDate).inDays;
      
      
      // Per la frequenza, conta solo i giorni unici con workout negli ultimi 30 giorni
      if (daysDifference >= 0 && daysDifference < 30) {
        // Determina in quale settimana ricade per il calcolo della media
        final int weekNumber = daysDifference ~/ 7;
        
        
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
  });

  // Conta il totale di giorni con workout negli ultimi 30 giorni
  final totalWorkoutDays = workoutDaysByWeek.values.fold(0, (sum, days) => sum + days.length);
  
  // Calcola la media settimanale basata su 30 giorni (circa 4.3 settimane)
  const weeksIn30Days = 30.0 / 7.0; // circa 4.3 settimane
  final average = totalWorkoutDays / weeksIn30Days;
  
  
  return average;
});