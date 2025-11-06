import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:flutter/foundation.dart';

/// Personal Record entity
class PersonalRecord {

  PersonalRecord({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.value,
    this.previousValue,
    required this.achievedAt,
    this.metadata = const {},
  });

  factory PersonalRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PersonalRecord(
      id: doc.id,
      userId: data['userId'] ?? '',
      exerciseId: data['exerciseId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      type: PRType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => PRType.weight,
      ),
      value: (data['value'] ?? 0).toDouble(),
      previousValue: data['previousValue']?.toDouble(),
      achievedAt: (data['achievedAt'] as Timestamp).toDate(),
      metadata: data['metadata'] ?? {},
    );
  }
  final String id;
  final String userId;
  final String exerciseId;
  final String exerciseName;
  final PRType type;
  final double value;
  final double? previousValue;
  final DateTime achievedAt;
  final Map<String, dynamic> metadata;

  /// Calculate improvement percentage
  double get improvementPercentage {
    if (previousValue == null || previousValue == 0) return 0;
    return ((value - previousValue!) / previousValue!) * 100;
  }

  /// Check if this is a significant PR (>2.5% improvement)
  bool get isSignificant => improvementPercentage > 2.5;

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'type': type.name,
      'value': value,
      'previousValue': previousValue,
      'achievedAt': Timestamp.fromDate(achievedAt),
      'metadata': metadata,
    };
  }

  PersonalRecord copyWith({
    String? id,
    String? userId,
    String? exerciseId,
    String? exerciseName,
    PRType? type,
    double? value,
    double? previousValue,
    DateTime? achievedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PersonalRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      type: type ?? this.type,
      value: value ?? this.value,
      previousValue: previousValue ?? this.previousValue,
      achievedAt: achievedAt ?? this.achievedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Service for tracking and managing personal records
class PRTracker {
  
  PRTracker({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  /// Check and update PRs for a completed exercise
  Future<List<PersonalRecord>> checkAndUpdatePRs(
    ExerciseActivity activity,
  ) async {
    final newPRs = <PersonalRecord>[];
    
    // Get existing PRs for this exercise
    final existingPRs = await getExercisePRs(
      activity.email,
      activity.exerciseId,
    );
    
    // Check weight PR
    final weightPR = await _checkWeightPR(activity, existingPRs);
    if (weightPR != null) newPRs.add(weightPR);
    
    // Check reps PR
    final repsPR = await _checkRepsPR(activity, existingPRs);
    if (repsPR != null) newPRs.add(repsPR);
    
    // Check volume PR
    final volumePR = await _checkVolumePR(activity, existingPRs);
    if (volumePR != null) newPRs.add(volumePR);
    
    // Check 1RM PR
    final oneRMPR = await _checkOneRMPR(activity, existingPRs);
    if (oneRMPR != null) newPRs.add(oneRMPR);
    
    // Check total sets PR
    final setsPR = await _checkSetsPR(activity, existingPRs);
    if (setsPR != null) newPRs.add(setsPR);
    
    // Save all new PRs
    for (final pr in newPRs) {
      await savePR(pr);
    }
    
    return newPRs;
  }

  /// Get all PRs for a user
  Future<List<PersonalRecord>> getUserPRs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('personalRecords')
          .where('userId', isEqualTo: userId)
          .orderBy('achievedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => PersonalRecord.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching user PRs: $e');
      }
      return [];
    }
  }

  /// Get PRs for specific exercise
  Future<Map<PRType, PersonalRecord>> getExercisePRs(
    String userId,
    String exerciseId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('personalRecords')
          .where('userId', isEqualTo: userId)
          .where('exerciseId', isEqualTo: exerciseId)
          .get();
      
      final prs = <PRType, PersonalRecord>{};
      
      for (final doc in snapshot.docs) {
        final pr = PersonalRecord.fromFirestore(doc);
        final existing = prs[pr.type];
        
        // Keep only the highest value for each type
        if (existing == null || pr.value > existing.value) {
          prs[pr.type] = pr;
        }
      }
      
      return prs;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching exercise PRs: $e');
      }
      return {};
    }
  }

  /// Get recent PRs (last 30 days)
  Future<List<PersonalRecord>> getRecentPRs(String userId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    try {
      final snapshot = await _firestore
          .collection('personalRecords')
          .where('userId', isEqualTo: userId)
          .where('achievedAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('achievedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => PersonalRecord.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching recent PRs: $e');
      }
      return [];
    }
  }

  /// Save a personal record
  Future<void> savePR(PersonalRecord pr) async {
    try {
      await _firestore.collection('personalRecords').add(pr.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving PR: $e');
      }
    }
  }

  /// Delete a personal record
  Future<void> deletePR(String prId) async {
    try {
      await _firestore.collection('personalRecords').doc(prId).delete();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting PR: $e');
      }
    }
  }

  /// Get PR timeline for an exercise
  Future<List<PersonalRecord>> getPRTimeline(
    String userId,
    String exerciseId,
    PRType type,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('personalRecords')
          .where('userId', isEqualTo: userId)
          .where('exerciseId', isEqualTo: exerciseId)
          .where('type', isEqualTo: type.name)
          .orderBy('achievedAt')
          .get();
      
      return snapshot.docs.map((doc) => PersonalRecord.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching PR timeline: $e');
      }
      return [];
    }
  }

  /// Get PR statistics
  Future<PRStats> getPRStats(String userId) async {
    final allPRs = await getUserPRs(userId);
    final recentPRs = await getRecentPRs(userId);
    
    final prsByType = <PRType, int>{};
    for (final pr in allPRs) {
      prsByType[pr.type] = (prsByType[pr.type] ?? 0) + 1;
    }
    
    final prsByExercise = <String, int>{};
    for (final pr in allPRs) {
      prsByExercise[pr.exerciseName] = (prsByExercise[pr.exerciseName] ?? 0) + 1;
    }
    
    return PRStats(
      totalPRs: allPRs.length,
      recentPRs: recentPRs.length,
      prsByType: prsByType,
      prsByExercise: prsByExercise,
      lastPRDate: allPRs.isNotEmpty ? allPRs.first.achievedAt : null,
    );
  }

  // Private helper methods
  
  Future<PersonalRecord?> _checkWeightPR(
    ExerciseActivity activity,
    Map<PRType, PersonalRecord> existingPRs,
  ) async {
    final maxWeight = activity.sets
        .where((s) => s.done && !s.isWarmup)
        .fold(0.0, (max, set) {
      final weight = double.tryParse(set.weight) ?? 0;
      return weight > max ? weight : max;
    });
    
    if (maxWeight <= 0) return null;
    
    final existing = existingPRs[PRType.weight];
    if (existing != null && maxWeight <= existing.value) return null;
    
    return PersonalRecord(
      id: '',
      userId: activity.email,
      exerciseId: activity.exerciseId,
      exerciseName: activity.exerciseName,
      type: PRType.weight,
      value: maxWeight,
      previousValue: existing?.value,
      achievedAt: activity.createdAt,
      metadata: {
        'workoutName': activity.schedaName,
        'reps': activity.sets
            .firstWhere((s) => double.tryParse(s.weight) == maxWeight)
            .reps,
      },
    );
  }

  Future<PersonalRecord?> _checkRepsPR(
    ExerciseActivity activity,
    Map<PRType, PersonalRecord> existingPRs,
  ) async {
    // Find the set with most reps at highest weight
    ExerciseActivitySet? bestSet;
    double bestScore = 0;
    
    for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
      final weight = double.tryParse(set.weight) ?? 0;
      final reps = int.tryParse(set.actualReps ?? set.reps) ?? 0;
      final score = weight * reps; // Score combines weight and reps
      
      if (score > bestScore) {
        bestScore = score;
        bestSet = set;
      }
    }
    
    if (bestSet == null) return null;
    
    final reps = int.tryParse(bestSet.actualReps ?? bestSet.reps) ?? 0;
    final weight = double.tryParse(bestSet.weight) ?? 0;
    
    // Check if this is a PR for this weight
    final existing = existingPRs[PRType.reps];
    if (existing != null) {
      final existingWeight = existing.metadata['weight'] as double? ?? 0;
      final existingReps = existing.value;
      
      // Only PR if more reps at same or higher weight
      if (weight < existingWeight || (weight == existingWeight && reps <= existingReps)) {
        return null;
      }
    }
    
    return PersonalRecord(
      id: '',
      userId: activity.email,
      exerciseId: activity.exerciseId,
      exerciseName: activity.exerciseName,
      type: PRType.reps,
      value: reps.toDouble(),
      previousValue: existing?.value,
      achievedAt: activity.createdAt,
      metadata: {
        'workoutName': activity.schedaName,
        'weight': weight,
      },
    );
  }

  Future<PersonalRecord?> _checkVolumePR(
    ExerciseActivity activity,
    Map<PRType, PersonalRecord> existingPRs,
  ) async {
    final volume = VolumeCalculator.calculateTotalVolume(activity.sets);
    
    if (volume <= 0) return null;
    
    final existing = existingPRs[PRType.volume];
    if (existing != null && volume <= existing.value) return null;
    
    return PersonalRecord(
      id: '',
      userId: activity.email,
      exerciseId: activity.exerciseId,
      exerciseName: activity.exerciseName,
      type: PRType.volume,
      value: volume,
      previousValue: existing?.value,
      achievedAt: activity.createdAt,
      metadata: {
        'workoutName': activity.schedaName,
        'sets': activity.sets.length,
      },
    );
  }

  Future<PersonalRecord?> _checkOneRMPR(
    ExerciseActivity activity,
    Map<PRType, PersonalRecord> existingPRs,
  ) async {
    double maxEstimated1RM = 0;
    Map<String, dynamic>? bestSetData;
    
    for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
      final weight = double.tryParse(set.weight) ?? 0;
      final reps = int.tryParse(set.actualReps ?? set.reps) ?? 0;
      
      if (weight > 0 && reps > 0) {
        final estimated1RM = OneRMCalculator.calculateAverage(weight, reps);
        
        if (estimated1RM > maxEstimated1RM) {
          maxEstimated1RM = estimated1RM;
          bestSetData = {
            'weight': weight,
            'reps': reps,
          };
        }
      }
    }
    
    if (maxEstimated1RM <= 0) return null;
    
    final existing = existingPRs[PRType.oneRM];
    if (existing != null && maxEstimated1RM <= existing.value) return null;
    
    return PersonalRecord(
      id: '',
      userId: activity.email,
      exerciseId: activity.exerciseId,
      exerciseName: activity.exerciseName,
      type: PRType.oneRM,
      value: maxEstimated1RM,
      previousValue: existing?.value,
      achievedAt: activity.createdAt,
      metadata: {
        'workoutName': activity.schedaName,
        ...?bestSetData,
      },
    );
  }

  Future<PersonalRecord?> _checkSetsPR(
    ExerciseActivity activity,
    Map<PRType, PersonalRecord> existingPRs,
  ) async {
    final completedSets = activity.sets.where((s) => s.done && !s.isWarmup).length;
    
    if (completedSets <= 0) return null;
    
    final existing = existingPRs[PRType.totalSets];
    if (existing != null && completedSets <= existing.value) return null;
    
    return PersonalRecord(
      id: '',
      userId: activity.email,
      exerciseId: activity.exerciseId,
      exerciseName: activity.exerciseName,
      type: PRType.totalSets,
      value: completedSets.toDouble(),
      previousValue: existing?.value,
      achievedAt: activity.createdAt,
      metadata: {
        'workoutName': activity.schedaName,
        'totalVolume': VolumeCalculator.calculateTotalVolume(activity.sets),
      },
    );
  }
}

/// PR Statistics
class PRStats {

  PRStats({
    required this.totalPRs,
    required this.recentPRs,
    required this.prsByType,
    required this.prsByExercise,
    this.lastPRDate,
  });
  final int totalPRs;
  final int recentPRs;
  final Map<PRType, int> prsByType;
  final Map<String, int> prsByExercise;
  final DateTime? lastPRDate;

  /// Get most common PR type
  PRType? get mostCommonType {
    if (prsByType.isEmpty) return null;
    
    return prsByType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get exercise with most PRs
  String? get bestExercise {
    if (prsByExercise.isEmpty) return null;
    
    return prsByExercise.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Days since last PR
  int? get daysSinceLastPR {
    if (lastPRDate == null) return null;
    return DateTime.now().difference(lastPRDate!).inDays;
  }
}