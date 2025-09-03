/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/providers
 * 🎯 Feature: analytics
 * 🔧 Type: provider
 * 🌍 Localization: N/A (data analytics)
 * 🎨 Theme: N/A (data analytics)
 * 📱 Platform: iOS/Android/Universal
 * 
 * Dependencies:
 * - Riverpod: State management
 * - Firestore: Cloud storage
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/skip_analytics_local_repository.dart';

// Skip analytics data model
class SkipAnalytics {
  final Map<String, int> skipReasonCounts;
  final Map<String, int> exerciseSkipCounts;
  final Map<String, List<String>> exerciseSkipReasons;
  final Map<String, Map<String, int>> timeBasedSkips; // hour -> reason -> count
  final int totalSkips;
  final DateTime? lastSkipDate;

  SkipAnalytics({
    required this.skipReasonCounts,
    required this.exerciseSkipCounts,
    required this.exerciseSkipReasons,
    required this.timeBasedSkips,
    required this.totalSkips,
    this.lastSkipDate,
  });
  
  factory SkipAnalytics.empty() => SkipAnalytics(
    skipReasonCounts: {},
    exerciseSkipCounts: {},
    exerciseSkipReasons: {},
    timeBasedSkips: {},
    totalSkips: 0,
    lastSkipDate: null,
  );
}

// Provider for skip analytics
final skipAnalyticsProvider = StateNotifierProvider<SkipAnalyticsNotifier, SkipAnalytics>((ref) {
  return SkipAnalyticsNotifier(ref);
});

class SkipAnalyticsNotifier extends StateNotifier<SkipAnalytics> {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SkipAnalyticsLocalRepository _localRepository = SkipAnalyticsLocalRepository();
  
  SkipAnalyticsNotifier(this.ref) : super(SkipAnalytics.empty()) {
    _initRepository();
  }
  
  Future<void> _initRepository() async {
    await _localRepository.init();
    _loadAnalytics();
  }
  
  Future<void> _loadAnalytics() async {
    try {
      // First load from local cache for immediate UI update
      final localAnalytics = _localRepository.getLocalAnalytics();
      if (localAnalytics.isNotEmpty) {
        state = SkipAnalytics(
          skipReasonCounts: Map<String, int>.from(localAnalytics['reasonCounts'] ?? {}),
          exerciseSkipCounts: Map<String, int>.from(localAnalytics['exerciseCounts'] ?? {}),
          exerciseSkipReasons: _parseExerciseReasons(localAnalytics['exerciseSkipReasons']),
          timeBasedSkips: _parseTimeBasedSkips(localAnalytics['hourlyPatterns']),
          totalSkips: localAnalytics['totalSkips'] ?? 0,
          lastSkipDate: localAnalytics['lastSkipDate'] != null 
              ? DateTime.parse(localAnalytics['lastSkipDate'])
              : null,
        );
      }
      
      // Then attempt to sync with Firebase
      final userAsync = ref.read(firebaseUserProvider);
      final user = userAsync.value;
      if (user != null) {
        // Sync any pending data
        await _localRepository.syncToFirebase(userId: user.uid);
        
        // Load from Firestore to get complete picture
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('analytics')
            .doc('skip_data')
            .get();
        
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          
          state = SkipAnalytics(
            skipReasonCounts: Map<String, int>.from(data['skipReasonCounts'] ?? {}),
            exerciseSkipCounts: Map<String, int>.from(data['exerciseSkipCounts'] ?? {}),
            exerciseSkipReasons: _parseExerciseReasons(data['exerciseSkipReasons']),
            timeBasedSkips: _parseTimeBasedSkips(data['timeBasedSkips']),
            totalSkips: data['totalSkips'] ?? 0,
            lastSkipDate: data['lastSkipDate'] != null 
                ? (data['lastSkipDate'] as Timestamp).toDate()
                : null,
          );
        }
      }
    } catch (e) {
      print('Error loading skip analytics: $e');
    }
  }
  
  Map<String, List<String>> _parseExerciseReasons(dynamic data) {
    if (data == null) return {};
    final result = <String, List<String>>{};
    (data as Map).forEach((key, value) {
      result[key] = List<String>.from(value);
    });
    return result;
  }
  
  Map<String, Map<String, int>> _parseTimeBasedSkips(dynamic data) {
    if (data == null) return {};
    final result = <String, Map<String, int>>{};
    (data as Map).forEach((hour, reasons) {
      result[hour] = Map<String, int>.from(reasons);
    });
    return result;
  }
  
  Future<void> logSkippedExercise(String exerciseName, String reason) async {
    try {
      // Save locally first (immediate, no cost)
      await _localRepository.saveSkipLocally(
        exerciseName: exerciseName,
        reason: reason,
        timestamp: DateTime.now(),
      );
      
      // Update local state immediately from local repository
      final localAnalytics = _localRepository.getLocalAnalytics();
      
      // Update state for immediate UI feedback
      final newReasonCounts = Map<String, int>.from(localAnalytics['reasonCounts'] ?? {});
      final newExerciseCounts = Map<String, int>.from(localAnalytics['exerciseCounts'] ?? {});
      
      // Parse exercise reasons
      final newExerciseReasons = Map<String, List<String>>.from(state.exerciseSkipReasons);
      if (!newExerciseReasons.containsKey(exerciseName)) {
        newExerciseReasons[exerciseName] = [];
      }
      newExerciseReasons[exerciseName]!.add(reason);
      
      // Update time-based patterns from local data
      final newTimeBasedSkips = Map<String, Map<String, int>>.from(
        localAnalytics['hourlyPatterns'] ?? {}
      ).map((hour, patterns) => 
        MapEntry(hour, Map<String, int>.from(patterns))
      );
      
      state = SkipAnalytics(
        skipReasonCounts: newReasonCounts,
        exerciseSkipCounts: newExerciseCounts,
        exerciseSkipReasons: newExerciseReasons,
        timeBasedSkips: newTimeBasedSkips,
        totalSkips: localAnalytics['totalSkips'] ?? 0,
        lastSkipDate: localAnalytics['lastSkipDate'] != null
            ? DateTime.parse(localAnalytics['lastSkipDate'])
            : DateTime.now(),
      );
      
      // Get insights for logging
      final insights = _localRepository.getLocalInsights();
      print('💾 Skip saved locally. Pending sync: ${insights['pendingSync']} skips');
      print('📊 Will sync to Firebase after ${10 - insights['pendingSync']} more skips or next scheduled sync');
      
    } catch (e) {
      print('Error logging skipped exercise: $e');
    }
  }
  
  // Get insights from skip data
  String getMostCommonSkipReason() {
    if (state.skipReasonCounts.isEmpty) return 'No data';
    
    final sorted = state.skipReasonCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }
  
  String getMostSkippedExercise() {
    if (state.exerciseSkipCounts.isEmpty) return 'No data';
    
    final sorted = state.exerciseSkipCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }
  
  int getPeakSkipHour() {
    if (state.timeBasedSkips.isEmpty) return -1;
    
    int maxSkips = 0;
    int peakHour = -1;
    
    state.timeBasedSkips.forEach((hour, reasons) {
      final totalSkips = reasons.values.fold<int>(0, (sum, count) => sum + count);
      if (totalSkips > maxSkips) {
        maxSkips = totalSkips;
        peakHour = int.parse(hour);
      }
    });
    
    return peakHour;
  }
  
  // Get personalized recommendations
  List<String> getRecommendations() {
    final recommendations = <String>[];
    
    // Equipment busy pattern
    if ((state.skipReasonCounts['equipment_busy'] ?? 0) > 3) {
      final peakHour = getPeakSkipHour();
      if (peakHour > 0) {
        recommendations.add('Try working out at ${peakHour < 12 ? peakHour + 12 : peakHour - 12}:00 when equipment is less busy');
      }
    }
    
    // Fatigue pattern
    if ((state.skipReasonCounts['too_tired'] ?? 0) > 3) {
      recommendations.add('Consider reducing workout volume or adding a rest day');
    }
    
    // Time constraint pattern
    if ((state.skipReasonCounts['no_time'] ?? 0) > 3) {
      recommendations.add('Try shorter, more focused workouts or supersets');
    }
    
    // Specific exercise pattern
    final mostSkipped = getMostSkippedExercise();
    if (mostSkipped != 'No data' && (state.exerciseSkipCounts[mostSkipped] ?? 0) > 2) {
      recommendations.add('Consider replacing "$mostSkipped" with an alternative exercise');
    }
    
    return recommendations;
  }
  
  // Force sync to Firebase (user-triggered)
  Future<void> forceSync() async {
    final userAsync = ref.read(firebaseUserProvider);
    final user = userAsync.value;
    if (user != null) {
      await _localRepository.forceSync(user.uid);
      await _loadAnalytics(); // Reload to get updated data
    }
  }
  
  // Get local insights (immediate, no Firebase call)
  Map<String, dynamic> getLocalInsights() {
    return _localRepository.getLocalInsights();
  }
}