/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics_feedback
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ANALYTICS FEEDBACK PROVIDERS
///
/// Provider per feedback Analytics con sistema eligibility:
/// - Utente deve aver usato Analytics per 7+ giorni
/// - Utente deve aver completato 10+ workout
/// - Utente può dare feedback ogni 30 giorni (ricorrente)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/analytics_feedback_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_page_feedback.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';

// ========================================
// REPOSITORY PROVIDER
// ========================================

/// Provider del repository feedback
final analyticsFeedbackRepositoryProvider =
    Provider<AnalyticsFeedbackRepository>((ref) {
  return AnalyticsFeedbackRepository();
});

// ========================================
// ELIGIBILITY CHECK PROVIDERS
// ========================================

/// Provider per tracking prima visita Analytics
///
/// Salva timestamp in SharedPreferences quando utente apre Analytics per prima volta.
/// Ritorna timestamp in millisecondi (null se prima volta).
final firstAnalyticsVisitProvider = FutureProvider.autoDispose<int?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('first_analytics_visit');
});

/// Provider per salvare prima visita Analytics
///
/// Chiamato automaticamente quando utente apre schermata Analytics.
final saveFirstAnalyticsVisitProvider =
    FutureProvider.autoDispose<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final firstVisit = prefs.getInt('first_analytics_visit');

  if (firstVisit == null) {
    // Prima visita! Salva timestamp
    await prefs.setInt(
      'first_analytics_visit',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
});

/// Provider per contare workout completati dopo data specifica
///
/// Usato per verificare se utente ha completato 10+ workout dopo prima visita.
final workoutCountSinceProvider =
    FutureProvider.autoDispose.family<int, DateTime>((ref, since) async {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.uid;

  if (userId == null) return 0;

  // Ottieni tutti i workout dell'utente usando provider analytics
  final workouts = await ref.watch(historicalWorkoutsProvider.future);

  // Filtra workout dopo data specifica (usa createdAt)
  final workoutsSince = workouts
      .where((workout) => workout.createdAt.isAfter(since))
      .length;

  return workoutsSince;
});

/// Provider PRINCIPALE per eligibility check
///
/// Ritorna true se utente può dare feedback Analytics.
///
/// Requisiti:
/// 1. Prima visita Analytics registrata
/// 2. Passati almeno 7 giorni dalla prima visita
/// 3. Completati almeno 10 workout dopo prima visita
/// 4. Passati almeno 30 giorni dall'ultimo feedback (o nessun feedback dato)
final feedbackEligibilityProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.uid;

  if (userId == null) return false;

  // 1. Check: Prima visita registrata
  final firstVisitMs = await ref.watch(firstAnalyticsVisitProvider.future);
  if (firstVisitMs == null) return false;

  final firstVisit = DateTime.fromMillisecondsSinceEpoch(firstVisitMs);

  // 2. Check: Passati almeno 7 giorni dalla prima visita
  final daysSinceFirstVisit = DateTime.now().difference(firstVisit).inDays;
  if (daysSinceFirstVisit < 7) return false;

  // 3. Check: Almeno 10 workout completati dopo prima visita
  final workoutsSince = await ref.watch(workoutCountSinceProvider(firstVisit).future);
  if (workoutsSince < 10) return false;

  // 4. Check: Passati almeno 30 giorni dall'ultimo feedback
  final repository = ref.watch(analyticsFeedbackRepositoryProvider);
  final lastFeedback = await repository.getUserLastFeedback(userId);

  if (lastFeedback != null) {
    final daysSinceLastFeedback =
        DateTime.now().difference(lastFeedback.timestamp).inDays;
    if (daysSinceLastFeedback < 30) return false;
  }

  // ✅ Eligible!
  return true;
});

// ========================================
// USER FEEDBACK PROVIDERS
// ========================================

/// Provider per ottenere ultimo feedback dell'utente
///
/// Ritorna null se utente non ha mai dato feedback.
/// Usato per mostrare "Grazie" se feedback recente (< 30 giorni).
final userLastAnalyticsFeedbackProvider =
    FutureProvider.autoDispose<AnalyticsPageFeedback?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.uid;

  if (userId == null) return null;

  final repository = ref.watch(analyticsFeedbackRepositoryProvider);
  return await repository.getUserLastFeedback(userId);
});

/// Provider per cronologia feedback dell'utente (tutti i feedback)
final userFeedbackHistoryProvider =
    FutureProvider.autoDispose<List<AnalyticsPageFeedback>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.uid;

  if (userId == null) return [];

  final repository = ref.watch(analyticsFeedbackRepositoryProvider);
  return await repository.getUserFeedbackHistory(userId);
});

// ========================================
// FEEDBACK SUBMISSION
// ========================================

/// Notifier per submit feedback Analytics
class AnalyticsFeedbackNotifier extends StateNotifier<AsyncValue<void>> {
  AnalyticsFeedbackNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  /// Submit feedback utente
  ///
  /// Parametri:
  /// - [isHelpful]: true = 👍, false = 👎
  /// - [comment]: Commento opzionale dell'utente
  /// - [lastViewedSection]: Ultima sezione vista (es: 'progress')
  /// - [totalWorkoutsViewed]: Numero workout visualizzati in Analytics
  Future<void> submitFeedback({
    required bool isHelpful,
    String? comment,
    String? lastViewedSection,
    int? totalWorkoutsViewed,
  }) async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      state = AsyncValue.error(
        Exception('User not authenticated'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(analyticsFeedbackRepositoryProvider);
      final timestamp = DateTime.now();

      final feedback = AnalyticsPageFeedback(
        id: '${userId}_${timestamp.millisecondsSinceEpoch}',
        userId: userId,
        isHelpful: isHelpful,
        comment: comment?.trim().isEmpty ?? true ? null : comment?.trim(),
        timestamp: timestamp,
        totalWorkoutsViewed: totalWorkoutsViewed,
        lastViewedSection: lastViewedSection,
        // TODO: Add device info if needed
        deviceInfo: null,
      );

      await repository.saveFeedback(feedback);

      // Invalida provider per refresh UI
      ref.invalidate(userLastAnalyticsFeedbackProvider);
      ref.invalidate(feedbackEligibilityProvider);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Provider per feedback notifier
final analyticsFeedbackNotifierProvider =
    StateNotifierProvider.autoDispose<AnalyticsFeedbackNotifier, AsyncValue<void>>(
  (ref) => AnalyticsFeedbackNotifier(ref),
);

// ========================================
// ADMIN PROVIDERS
// ========================================

/// Provider per tutti i feedback (ADMIN ONLY)
///
/// Parametri:
/// - [limit]: Numero massimo feedback da recuperare (default: 50)
/// - [isHelpful]: Filtra per tipo (null = tutti)
final adminAllAnalyticsFeedbackProvider = FutureProvider.autoDispose
    .family<List<AnalyticsPageFeedback>, ({int? limit, bool? isHelpful})>(
  (ref, params) async {
    final repository = ref.watch(analyticsFeedbackRepositoryProvider);
    return await repository.getAllFeedback(
      limit: params.limit ?? 50,
      isHelpful: params.isHelpful,
    );
  },
);

/// Provider per statistiche aggregate (ADMIN ONLY)
final adminAnalyticsFeedbackStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(analyticsFeedbackRepositoryProvider);

  try {
    return await repository.getOverallStats();
  } catch (e) {
    return {
      'totalFeedback': 0,
      'totalHelpful': 0,
      'totalNotHelpful': 0,
      'helpfulPercentage': 0.0,
      'uniqueUsers': 0,
      'bySection': <String, dynamic>{},
    };
  }
});

/// Provider per feedback per sezione specifica (ADMIN ONLY)
final adminFeedbackBySectionProvider = FutureProvider.autoDispose
    .family<List<AnalyticsPageFeedback>, String>((ref, section) async {
  final repository = ref.watch(analyticsFeedbackRepositoryProvider);
  return await repository.getFeedbackBySection(section, limit: 20);
});
