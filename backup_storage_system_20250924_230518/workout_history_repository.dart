import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/workout.dart';

/// Repository for workout history with local-first approach
class WorkoutHistoryRepository {
  static const String _boxName = 'workout_history';
  static const String _patternBoxName = 'workout_patterns';
  Box<Map>? _historyBox;
  Box<Map>? _patternBox;
  bool _isInitialized = false;
  
  WorkoutHistoryRepository() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    if (_isInitialized) return;
    _historyBox = await Hive.openBox<Map>(_boxName);
    _patternBox = await Hive.openBox<Map>(_patternBoxName);
    _isInitialized = true;
  }
  
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
  }
  
  /// Save completed workout locally
  Future<void> saveWorkoutLocally(Workout workout) async {
    try {
      print('🏋️ [WorkoutHistory] Attempting to save workout locally: ${workout.name}');
      await _ensureInitialized();

      if (!workout.isCompleted || workout.endTime == null) {
        print('⚠️ [WorkoutHistory] Workout not completed or missing endTime, skipping save');
        return;
      }

      final workoutData = {
        'id': workout.id,
        'name': workout.name,
        'templateName': workout.name, // For pattern recognition
        'startTime': workout.startTime?.toIso8601String(),
        'endTime': workout.endTime?.toIso8601String(),
        'completedAt': workout.endTime?.toIso8601String(),
        'exerciseCount': workout.exercises.length,
        'totalSets': workout.exercises.fold<int>(
          0, (sum, exercise) => sum + exercise.sets.length
        ),
        'duration': workout.endTime!.difference(workout.startTime!).inMinutes,
      };

      // Save with date as key for easy retrieval
      final key = 'workout_${workout.endTime!.millisecondsSinceEpoch}';

      if (_historyBox == null) {
        print('❌ [WorkoutHistory] CRITICAL: History box is null! Cannot save workout.');
        throw Exception('WorkoutHistory box not initialized');
      }

      await _historyBox!.put(key, workoutData);
      print('✅ [WorkoutHistory] Workout saved locally with key: $key');
      print('📊 [WorkoutHistory] Total workouts in local storage: ${_historyBox!.length}');

      // Update pattern analysis
      await _updatePatternAnalysis();
      print('✅ [WorkoutHistory] Pattern analysis updated');

    } catch (e, stackTrace) {
      print('❌ [WorkoutHistory] CRITICAL ERROR saving workout locally: $e');
      print('📍 [WorkoutHistory] Stack trace: $stackTrace');
      rethrow; // Re-throw so caller can handle the error
    }
  }
  
  /// Get recent workout history (last 30 days) - LOCAL FIRST
  Future<List<WorkoutHistoryEntry>> getRecentWorkouts({int days = 30}) async {
    try {
      print('📊 [WorkoutHistory] Getting recent workouts (last $days days)');
      await _ensureInitialized();

      if (_historyBox == null) {
        print('❌ [WorkoutHistory] CRITICAL: History box is null! Cannot read workouts.');
        return [];
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final List<WorkoutHistoryEntry> workouts = [];

      print('📦 [WorkoutHistory] Total keys in history box: ${_historyBox!.keys.length}');

      // STEP 1: Always check local storage first
      for (var key in _historyBox!.keys) {
        final data = _historyBox!.get(key);
        if (data != null && data['completedAt'] != null) {
          try {
            final completedAt = DateTime.parse(data['completedAt']);
            if (completedAt.isAfter(cutoffDate)) {
              workouts.add(WorkoutHistoryEntry.fromMap(data));
            }
          } catch (e) {
            print('⚠️ [WorkoutHistory] Error parsing workout data for key $key: $e');
          }
        }
      }

      print('📊 [WorkoutHistory] Found ${workouts.length} workouts in date range');

      // STEP 2: If local data is sufficient (>= 3 workouts), use it
      if (workouts.length >= 3) {
        print('✅ [WorkoutHistory] Using LOCAL workout history: ${workouts.length} workouts found');
        return workouts..sort((a, b) => a.completedAt.compareTo(b.completedAt));
      } else {
        print('⚠️ [WorkoutHistory] Insufficient local data (${workouts.length} workouts), checking cloud fallback...');
      }
    
    // STEP 3: Only if local is empty AND user is premium, try Firebase as fallback
    if (workouts.isEmpty) {
      print('📱 No local history, checking if we should fetch from cloud...');
      
      // Check if user is premium (you can adjust this logic)
      final isPremium = await _checkIfUserIsPremium();
      
      if (isPremium) {
        print('☁️ User is premium, fetching from Firebase as fallback...');
        final cloudWorkouts = await _fetchFromFirebase(cutoffDate);
        
        // Save cloud data locally for next time
        for (var workout in cloudWorkouts) {
          final key = 'workout_${workout.completedAt.millisecondsSinceEpoch}';
          await _historyBox!.put(key, workout.toMap());
        }
        
        return cloudWorkouts;
      }
    }
    
      return workouts..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    } catch (e, stackTrace) {
      print('❌ [WorkoutHistory] CRITICAL ERROR in getRecentWorkouts: $e');
      print('📍 [WorkoutHistory] Stack trace: $stackTrace');
      return [];
    }
  }
  
  /// Get detected pattern - ALWAYS LOCAL
  Future<WorkoutPattern?> getDetectedPattern() async {
    await _ensureInitialized();
    final patternData = _patternBox!.get('current_pattern');
    if (patternData != null) {
      return WorkoutPattern.fromMap(patternData);
    }
    return null;
  }
  
  /// Update pattern analysis based on local history
  Future<void> _updatePatternAnalysis() async {
    final workouts = await getRecentWorkouts();
    
    if (workouts.length < 3) {
      // Not enough data for pattern
      await _patternBox!.delete('current_pattern');
      return;
    }
    
    // Analyze pattern
    final pattern = _analyzePattern(workouts);
    
    if (pattern != null) {
      await _patternBox!.put('current_pattern', pattern.toMap());
      print('📊 Pattern detected and saved locally: ${pattern.rotation.join(' → ')}');
    }
  }
  
  /// Analyze workout pattern
  WorkoutPattern? _analyzePattern(List<WorkoutHistoryEntry> workouts) {
    if (workouts.length < 3) return null;
    
    // Count frequency of each template
    final templateFrequency = <String, int>{};
    for (var workout in workouts) {
      templateFrequency[workout.templateName] = 
          (templateFrequency[workout.templateName] ?? 0) + 1;
    }
    
    // Get most frequent templates
    final sortedTemplates = templateFrequency.entries
        .map((e) => TemplateFrequency(name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    
    // Try to detect rotation
    final rotation = _detectRotation(workouts, sortedTemplates);
    
    if (rotation.isNotEmpty) {
      return WorkoutPattern(
        rotation: rotation,
        lastWorkout: workouts.last,
        confidence: _calculateConfidence(workouts, rotation),
        frequentTemplates: sortedTemplates.take(5).toList(),
      );
    }
    
    return null;
  }
  
  /// Detect rotation pattern
  List<String> _detectRotation(
    List<WorkoutHistoryEntry> workouts,
    List<TemplateFrequency> frequentTemplates,
  ) {
    if (workouts.length < 3) return [];
    
    // Get the most frequent templates
    final mainTemplates = frequentTemplates
        .take(5)
        .map((t) => t.name)
        .toSet();
    
    // Filter to only main templates
    final filteredWorkouts = workouts
        .where((w) => mainTemplates.contains(w.templateName))
        .toList();
    
    if (filteredWorkouts.length < 3) return [];
    
    // Try different pattern lengths
    for (int patternLen = 2; patternLen <= 5 && patternLen <= filteredWorkouts.length / 2; patternLen++) {
      final pattern = <String>[];
      
      // Get last N workouts as potential pattern
      for (int i = 0; i < patternLen; i++) {
        pattern.add(filteredWorkouts[filteredWorkouts.length - patternLen + i].templateName);
      }
      
      // Check if pattern repeats
      bool isValid = true;
      int checkStart = filteredWorkouts.length - patternLen * 2;
      
      if (checkStart >= 0) {
        for (int i = 0; i < patternLen; i++) {
          if (filteredWorkouts[checkStart + i].templateName != pattern[i]) {
            isValid = false;
            break;
          }
        }
        
        if (isValid) {
          // Remove duplicates while preserving order
          final uniquePattern = <String>[];
          for (var template in pattern) {
            if (!uniquePattern.contains(template)) {
              uniquePattern.add(template);
            }
          }
          return uniquePattern;
        }
      }
    }
    
    // Fallback: return last 3 unique templates
    final lastUnique = <String>[];
    for (int i = filteredWorkouts.length - 1; i >= 0 && lastUnique.length < 3; i--) {
      final template = filteredWorkouts[i].templateName;
      if (!lastUnique.contains(template)) {
        lastUnique.add(template);
      }
    }
    
    return lastUnique.reversed.toList();
  }
  
  /// Calculate confidence in pattern
  double _calculateConfidence(List<WorkoutHistoryEntry> workouts, List<String> rotation) {
    if (workouts.length < rotation.length * 2) return 0.5;
    
    int matches = 0;
    int checks = 0;
    
    for (int i = rotation.length; i < workouts.length; i++) {
      final expectedIndex = (i - rotation.length) % rotation.length;
      final expected = rotation[expectedIndex];
      
      if (workouts[i].templateName == expected) {
        matches++;
      }
      checks++;
    }
    
    return checks > 0 ? (matches / checks).clamp(0.5, 1.0) : 0.5;
  }
  
  /// Check if user is premium (simplified)
  Future<bool> _checkIfUserIsPremium() async {
    // This is a simplified check - adjust based on your premium logic
    // For now, return false to always prefer local storage
    return false;
  }
  
  /// Fetch from Firebase (only as fallback for premium users)
  Future<List<WorkoutHistoryEntry>> _fetchFromFirebase(DateTime cutoffDate) async {
    try {
      // Get user email from auth
      // This is just a fallback, so we can be less aggressive
      final querySnapshot = await FirebaseFirestore.instance
          .collection('exerciseActivities')
          .where('completedAt', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .orderBy('completedAt', descending: false)
          .limit(50) // Limit to prevent large downloads
          .get();
      
      return querySnapshot.docs
          .map((doc) => WorkoutHistoryEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('⚠️ Firebase fallback failed: $e');
      return [];
    }
  }
  
  /// Clear local history (for testing or user request)
  Future<void> clearLocalHistory() async {
    await _ensureInitialized();
    await _historyBox!.clear();
    await _patternBox!.clear();
  }
  
  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    await _ensureInitialized();
    return {
      'localWorkouts': _historyBox!.length,
      'hasPattern': _patternBox!.containsKey('current_pattern'),
      'oldestWorkout': _historyBox!.keys.isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch(
              _historyBox!.keys
                  .map((k) => int.tryParse(k.toString().split('_').last) ?? 0)
                  .reduce((a, b) => a < b ? a : b)
            ).toString()
          : null,
    };
  }
}

/// Data classes
class WorkoutHistoryEntry {
  final String id;
  final String templateName;
  final DateTime completedAt;
  final int exerciseCount;
  final int totalSets;
  final int duration; // minutes
  
  WorkoutHistoryEntry({
    required this.id,
    required this.templateName,
    required this.completedAt,
    required this.exerciseCount,
    required this.totalSets,
    required this.duration,
  });
  
  factory WorkoutHistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutHistoryEntry(
      id: map['id'] ?? '',
      templateName: map['templateName'] ?? map['name'] ?? 'Unknown',
      completedAt: DateTime.parse(map['completedAt']),
      exerciseCount: map['exerciseCount'] ?? 0,
      totalSets: map['totalSets'] ?? 0,
      duration: map['duration'] ?? 0,
    );
  }
  
  factory WorkoutHistoryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutHistoryEntry(
      id: doc.id,
      templateName: data['templateName'] ?? data['workoutName'] ?? 'Unknown',
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      exerciseCount: data['exerciseCount'] ?? 0,
      totalSets: data['totalSets'] ?? 0,
      duration: data['duration'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateName': templateName,
      'completedAt': completedAt.toIso8601String(),
      'exerciseCount': exerciseCount,
      'totalSets': totalSets,
      'duration': duration,
    };
  }
}

class WorkoutPattern {
  final List<String> rotation;
  final WorkoutHistoryEntry lastWorkout;
  final double confidence;
  final List<TemplateFrequency> frequentTemplates;
  
  WorkoutPattern({
    required this.rotation,
    required this.lastWorkout,
    required this.confidence,
    required this.frequentTemplates,
  });
  
  factory WorkoutPattern.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutPattern(
      rotation: List<String>.from(map['rotation'] ?? []),
      lastWorkout: WorkoutHistoryEntry.fromMap(map['lastWorkout']),
      confidence: map['confidence'] ?? 0.5,
      frequentTemplates: (map['frequentTemplates'] as List?)
          ?.map((t) => TemplateFrequency.fromMap(t))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'rotation': rotation,
      'lastWorkout': lastWorkout.toMap(),
      'confidence': confidence,
      'frequentTemplates': frequentTemplates.map((t) => t.toMap()).toList(),
    };
  }
}

class TemplateFrequency {
  final String name;
  final int count;
  
  TemplateFrequency({
    required this.name,
    required this.count,
  });
  
  factory TemplateFrequency.fromMap(Map<dynamic, dynamic> map) {
    return TemplateFrequency(
      name: map['name'] ?? '',
      count: map['count'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'count': count,
    };
  }
}