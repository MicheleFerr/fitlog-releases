import 'package:flutter_test/flutter_test.dart';

// Mock Analytics Service
class AnalyticsService {
  final List<AnalyticsEvent> _events = [];
  final Map<String, dynamic> _userProperties = {};
  
  List<AnalyticsEvent> get events => List.unmodifiable(_events);
  Map<String, dynamic> get userProperties => Map.unmodifiable(_userProperties);
  
  // Track workout events
  void trackWorkoutStarted({
    required String workoutId,
    required String workoutName,
    required int exerciseCount,
  }) {
    _events.add(AnalyticsEvent(
      name: 'workout_started',
      parameters: {
        'workout_id': workoutId,
        'workout_name': workoutName,
        'exercise_count': exerciseCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }
  
  void trackWorkoutCompleted({
    required String workoutId,
    required String workoutName,
    required Duration duration,
    required int totalSets,
    required int totalReps,
    required double totalVolume,
  }) {
    _events.add(AnalyticsEvent(
      name: 'workout_completed',
      parameters: {
        'workout_id': workoutId,
        'workout_name': workoutName,
        'duration_minutes': duration.inMinutes,
        'total_sets': totalSets,
        'total_reps': totalReps,
        'total_volume_kg': totalVolume,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }
  
  void trackExerciseCompleted({
    required String exerciseName,
    required int sets,
    required int totalReps,
    required double maxWeight,
    required double totalVolume,
  }) {
    _events.add(AnalyticsEvent(
      name: 'exercise_completed',
      parameters: {
        'exercise_name': exerciseName,
        'sets': sets,
        'total_reps': totalReps,
        'max_weight_kg': maxWeight,
        'total_volume_kg': totalVolume,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }
  
  // Track timer events
  void trackRestTimerStarted({
    required int durationSeconds,
    required String exerciseName,
    required int setNumber,
  }) {
    _events.add(AnalyticsEvent(
      name: 'rest_timer_started',
      parameters: {
        'duration_seconds': durationSeconds,
        'exercise_name': exerciseName,
        'set_number': setNumber,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }
  
  void trackRestTimerCompleted({
    required int durationSeconds,
    required bool skipped,
  }) {
    _events.add(AnalyticsEvent(
      name: 'rest_timer_completed',
      parameters: {
        'duration_seconds': durationSeconds,
        'was_skipped': skipped,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }
  
  // Track user achievements
  void trackPersonalRecord({
    required String exerciseName,
    required String recordType,
    required double value,
    required double previousValue,
  }) {
    _events.add(AnalyticsEvent(
      name: 'personal_record',
      parameters: {
        'exercise_name': exerciseName,
        'record_type': recordType, // 'weight', 'reps', 'volume'
        'new_value': value,
        'previous_value': previousValue,
        'improvement_percent': ((value - previousValue) / previousValue * 100).toStringAsFixed(1),
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }
  
  void trackStreakMilestone({
    required int streakDays,
    required String streakType,
  }) {
    _events.add(AnalyticsEvent(
      name: 'streak_milestone',
      parameters: {
        'streak_days': streakDays,
        'streak_type': streakType, // 'workout', 'weekly', 'monthly'
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }
  
  // Set user properties
  void setUserProperty(String name, dynamic value) {
    _userProperties[name] = value;
  }
  
  void updateUserStats({
    int? totalWorkouts,
    int? weeklyWorkouts,
    double? totalVolume,
    String? preferredWorkoutTime,
    String? fitnessLevel,
  }) {
    if (totalWorkouts != null) _userProperties['total_workouts'] = totalWorkouts;
    if (weeklyWorkouts != null) _userProperties['weekly_workouts'] = weeklyWorkouts;
    if (totalVolume != null) _userProperties['total_volume_kg'] = totalVolume;
    if (preferredWorkoutTime != null) _userProperties['preferred_workout_time'] = preferredWorkoutTime;
    if (fitnessLevel != null) _userProperties['fitness_level'] = fitnessLevel;
  }
  
  // Get analytics summary
  Map<String, dynamic> getWorkoutAnalytics() {
    final workoutEvents = _events.where((e) => e.name.contains('workout')).toList();
    
    if (workoutEvents.isEmpty) {
      return {
        'total_workouts': 0,
        'total_duration_minutes': 0,
        'average_duration_minutes': 0,
        'total_volume_kg': 0,
        'average_volume_kg': 0,
      };
    }
    
    final completedWorkouts = workoutEvents.where((e) => e.name == 'workout_completed').toList();
    
    int totalDuration = 0;
    double totalVolume = 0;
    
    for (final event in completedWorkouts) {
      totalDuration += (event.parameters['duration_minutes'] as int);
      totalVolume += (event.parameters['total_volume_kg'] as double);
    }
    
    return {
      'total_workouts': completedWorkouts.length,
      'total_duration_minutes': totalDuration,
      'average_duration_minutes': completedWorkouts.isNotEmpty ? totalDuration ~/ completedWorkouts.length : 0,
      'total_volume_kg': totalVolume,
      'average_volume_kg': completedWorkouts.isNotEmpty ? totalVolume / completedWorkouts.length : 0,
    };
  }
  
  Map<String, int> getMuscleGroupFrequency() {
    final exerciseEvents = _events.where((e) => e.name == 'exercise_completed').toList();
    final frequency = <String, int>{};
    
    for (final event in exerciseEvents) {
      final exerciseName = event.parameters['exercise_name'] as String;
      final muscleGroup = _getMuscleGroupFromExercise(exerciseName);
      frequency[muscleGroup] = (frequency[muscleGroup] ?? 0) + 1;
    }
    
    return frequency;
  }
  
  String _getMuscleGroupFromExercise(String exerciseName) {
    final lowerName = exerciseName.toLowerCase();
    if (lowerName.contains('bench') || lowerName.contains('chest')) return 'chest';
    if (lowerName.contains('squat') || lowerName.contains('leg')) return 'legs';
    if (lowerName.contains('pull') || lowerName.contains('row')) return 'back';
    if (lowerName.contains('curl')) return 'arms';
    if (lowerName.contains('press') && !lowerName.contains('bench')) return 'shoulders';
    return 'other';
  }
  
  // Clear analytics
  void clearEvents() {
    _events.clear();
  }
  
  void clearUserProperties() {
    _userProperties.clear();
  }
}

class AnalyticsEvent {
  
  AnalyticsEvent({
    required this.name,
    required this.parameters,
  });
  final String name;
  final Map<String, dynamic> parameters;
}

void main() {
  group('📊 Analytics Service Tests', () {
    late AnalyticsService analytics;
    
    setUp(() {
      analytics = AnalyticsService();
    });
    
    tearDown(() {
      analytics.clearEvents();
      analytics.clearUserProperties();
    });
    
    group('🏋️ Workout Analytics', () {
      test('✅ Track workout started', () {
        analytics.trackWorkoutStarted(
          workoutId: 'workout-123',
          workoutName: 'Chest Day',
          exerciseCount: 5,
        );
        
        expect(analytics.events.length, 1);
        expect(analytics.events.first.name, 'workout_started');
        expect(analytics.events.first.parameters['workout_name'], 'Chest Day');
        expect(analytics.events.first.parameters['exercise_count'], 5);
      });
      
      test('✅ Track workout completed', () {
        analytics.trackWorkoutCompleted(
          workoutId: 'workout-123',
          workoutName: 'Chest Day',
          duration: const Duration(minutes: 45),
          totalSets: 15,
          totalReps: 150,
          totalVolume: 2500.0,
        );
        
        expect(analytics.events.length, 1);
        expect(analytics.events.first.name, 'workout_completed');
        expect(analytics.events.first.parameters['duration_minutes'], 45);
        expect(analytics.events.first.parameters['total_sets'], 15);
        expect(analytics.events.first.parameters['total_volume_kg'], 2500.0);
      });
      
      test('✅ Calculate workout analytics summary', () {
        // Track multiple workouts
        analytics.trackWorkoutCompleted(
          workoutId: 'workout-1',
          workoutName: 'Workout 1',
          duration: const Duration(minutes: 30),
          totalSets: 10,
          totalReps: 100,
          totalVolume: 1000.0,
        );
        
        analytics.trackWorkoutCompleted(
          workoutId: 'workout-2',
          workoutName: 'Workout 2',
          duration: const Duration(minutes: 60),
          totalSets: 20,
          totalReps: 200,
          totalVolume: 2000.0,
        );
        
        final summary = analytics.getWorkoutAnalytics();
        
        expect(summary['total_workouts'], 2);
        expect(summary['total_duration_minutes'], 90);
        expect(summary['average_duration_minutes'], 45);
        expect(summary['total_volume_kg'], 3000.0);
        expect(summary['average_volume_kg'], 1500.0);
      });
    });
    
    group('💪 Exercise Analytics', () {
      test('✅ Track exercise completed', () {
        analytics.trackExerciseCompleted(
          exerciseName: 'Bench Press',
          sets: 4,
          totalReps: 40,
          maxWeight: 80.0,
          totalVolume: 3200.0,
        );
        
        expect(analytics.events.length, 1);
        expect(analytics.events.first.name, 'exercise_completed');
        expect(analytics.events.first.parameters['exercise_name'], 'Bench Press');
        expect(analytics.events.first.parameters['sets'], 4);
        expect(analytics.events.first.parameters['max_weight_kg'], 80.0);
      });
      
      test('✅ Track muscle group frequency', () {
        analytics.trackExerciseCompleted(
          exerciseName: 'Bench Press',
          sets: 4,
          totalReps: 40,
          maxWeight: 80.0,
          totalVolume: 3200.0,
        );
        
        analytics.trackExerciseCompleted(
          exerciseName: 'Incline Chest Press',
          sets: 3,
          totalReps: 30,
          maxWeight: 60.0,
          totalVolume: 1800.0,
        );
        
        analytics.trackExerciseCompleted(
          exerciseName: 'Squat',
          sets: 5,
          totalReps: 50,
          maxWeight: 100.0,
          totalVolume: 5000.0,
        );
        
        final frequency = analytics.getMuscleGroupFrequency();
        
        expect(frequency['chest'], 2);
        expect(frequency['legs'], 1);
      });
    });
    
    group('⏱️ Timer Analytics', () {
      test('✅ Track rest timer started', () {
        analytics.trackRestTimerStarted(
          durationSeconds: 60,
          exerciseName: 'Bench Press',
          setNumber: 2,
        );
        
        expect(analytics.events.length, 1);
        expect(analytics.events.first.name, 'rest_timer_started');
        expect(analytics.events.first.parameters['duration_seconds'], 60);
        expect(analytics.events.first.parameters['set_number'], 2);
      });
      
      test('✅ Track rest timer completed', () {
        analytics.trackRestTimerCompleted(
          durationSeconds: 60,
          skipped: false,
        );
        
        expect(analytics.events.length, 1);
        expect(analytics.events.first.name, 'rest_timer_completed');
        expect(analytics.events.first.parameters['was_skipped'], false);
      });
      
      test('✅ Track rest timer skipped', () {
        analytics.trackRestTimerCompleted(
          durationSeconds: 30,
          skipped: true,
        );
        
        expect(analytics.events.first.parameters['was_skipped'], true);
      });
    });
    
    group('🏆 Achievement Analytics', () {
      test('✅ Track personal record - weight', () {
        analytics.trackPersonalRecord(
          exerciseName: 'Bench Press',
          recordType: 'weight',
          value: 85.0,
          previousValue: 80.0,
        );
        
        expect(analytics.events.length, 1);
        expect(analytics.events.first.name, 'personal_record');
        expect(analytics.events.first.parameters['record_type'], 'weight');
        expect(analytics.events.first.parameters['new_value'], 85.0);
        expect(analytics.events.first.parameters['improvement_percent'], '6.3');
      });
      
      test('✅ Track personal record - reps', () {
        analytics.trackPersonalRecord(
          exerciseName: 'Pull Ups',
          recordType: 'reps',
          value: 15,
          previousValue: 12,
        );
        
        expect(analytics.events.first.parameters['record_type'], 'reps');
        expect(analytics.events.first.parameters['improvement_percent'], '25.0');
      });
      
      test('✅ Track streak milestone', () {
        analytics.trackStreakMilestone(
          streakDays: 30,
          streakType: 'workout',
        );
        
        expect(analytics.events.length, 1);
        expect(analytics.events.first.name, 'streak_milestone');
        expect(analytics.events.first.parameters['streak_days'], 30);
        expect(analytics.events.first.parameters['streak_type'], 'workout');
      });
    });
    
    group('👤 User Properties', () {
      test('✅ Set user property', () {
        analytics.setUserProperty('user_type', 'premium');
        
        expect(analytics.userProperties['user_type'], 'premium');
      });
      
      test('✅ Update user stats', () {
        analytics.updateUserStats(
          totalWorkouts: 100,
          weeklyWorkouts: 4,
          totalVolume: 50000.0,
          preferredWorkoutTime: 'morning',
          fitnessLevel: 'intermediate',
        );
        
        expect(analytics.userProperties['total_workouts'], 100);
        expect(analytics.userProperties['weekly_workouts'], 4);
        expect(analytics.userProperties['total_volume_kg'], 50000.0);
        expect(analytics.userProperties['preferred_workout_time'], 'morning');
        expect(analytics.userProperties['fitness_level'], 'intermediate');
      });
      
      test('✅ Partial update user stats', () {
        analytics.updateUserStats(totalWorkouts: 50);
        analytics.updateUserStats(weeklyWorkouts: 3);
        
        expect(analytics.userProperties['total_workouts'], 50);
        expect(analytics.userProperties['weekly_workouts'], 3);
        expect(analytics.userProperties.containsKey('total_volume_kg'), false);
      });
    });
    
    group('🧹 Data Management', () {
      test('✅ Clear events', () {
        analytics.trackWorkoutStarted(
          workoutId: 'test',
          workoutName: 'Test',
          exerciseCount: 1,
        );
        
        expect(analytics.events.length, 1);
        
        analytics.clearEvents();
        
        expect(analytics.events.length, 0);
      });
      
      test('✅ Clear user properties', () {
        analytics.setUserProperty('test', 'value');
        
        expect(analytics.userProperties.isNotEmpty, true);
        
        analytics.clearUserProperties();
        
        expect(analytics.userProperties.isEmpty, true);
      });
    });
  });
}