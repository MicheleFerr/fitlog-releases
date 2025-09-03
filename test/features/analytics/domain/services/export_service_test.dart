import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/export_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/models/analytics_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/insights_engine.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ExportService', () {
    late List<AnalyticsActivity> mockActivities;
    late List<PersonalRecord> mockPRs;
    late List<TrainingInsight> mockInsights;
    late Map<String, dynamic> mockStatistics;
    late Directory testDirectory;
    
    setUp(() async {
      // Create test directory
      testDirectory = await Directory.systemTemp.createTemp('export_test_');
      
      // Create mock data
      mockActivities = [
        AnalyticsActivity(
          id: '1',
          userId: 'user1',
          date: DateTime(2024, 1, 15),
          exerciseId: 'ex1',
          exerciseName: 'Bench Press',
          muscleGroup: 'Chest',
          sets: [
            AnalyticsSet(weight: 100, reps: 10, rpe: 8, restTime: 120),
            AnalyticsSet(weight: 110, reps: 8, rpe: 9, restTime: 150),
            AnalyticsSet(weight: 120, reps: 6, rpe: 10),
          ],
          totalVolume: 2360,
          totalReps: 24,
          maxWeight: 120,
          averageIntensity: 8.5,
          duration: 45,
        ),
        AnalyticsActivity(
          id: '2',
          userId: 'user1',
          date: DateTime(2024, 1, 17),
          exerciseId: 'ex2',
          exerciseName: 'Squat',
          muscleGroup: 'Legs',
          sets: [
            AnalyticsSet(weight: 140, reps: 8, rpe: 8),
            AnalyticsSet(weight: 150, reps: 6, rpe: 9),
            AnalyticsSet(weight: 160, reps: 5, rpe: 10),
          ],
          totalVolume: 2820,
          totalReps: 19,
          maxWeight: 160,
          averageIntensity: 9,
          duration: 50,
        ),
      ];
      
      mockPRs = [
        PersonalRecord(
          id: 'pr1',
          userId: 'user1',
          exerciseId: 'ex1',
          exerciseName: 'Bench Press',
          type: PRType.weight,
          value: 120,
          previousValue: 115,
          achievedAt: DateTime(2024, 1, 15),
          metadata: {'workoutId': 'w1'},
        ),
        PersonalRecord(
          id: 'pr2',
          userId: 'user1',
          exerciseId: 'ex2',
          exerciseName: 'Squat',
          type: PRType.volume,
          value: 2820,
          previousValue: 2500,
          achievedAt: DateTime(2024, 1, 17),
          metadata: {'workoutId': 'w2'},
        ),
      ];
      
      mockInsights = [
        TrainingInsight(
          id: 'i1',
          type: InsightType.achievement,
          priority: InsightPriority.high,
          title: 'New Bench Press PR!',
          message: 'You set a new personal record of 120kg on Bench Press',
          recommendation: 'Keep progressively overloading to maintain gains',
          metadata: {'exerciseId': 'ex1', 'confidence': 1.0},
        ),
        TrainingInsight(
          id: 'i2',
          type: InsightType.suggestion,
          priority: InsightPriority.medium,
          title: 'Focus on Recovery',
          message: 'Your training volume has increased significantly',
          recommendation: 'Consider adding a deload week to prevent overtraining',
          metadata: {'confidence': 0.85},
        ),
      ];
      
      mockStatistics = {
        'totalWorkouts': 25,
        'totalVolume': 125000,
        'avgDuration': 45,
        'currentStreak': 5,
        'longestStreak': 12,
        'totalPRs': 8,
        'mostTrainedMuscle': 'Chest',
        'favoriteExercise': 'Bench Press',
      };
    });
    
    tearDown(() async {
      // Clean up test directory
      if (await testDirectory.exists()) {
        await testDirectory.delete(recursive: true);
      }
    });
    
    group('CSV Export', () {
      test('should generate workout CSV with correct headers', () async {
        final filePath = await ExportService.exportToCSV(
          activities: mockActivities,
          type: ExportCSVType.workouts,
          customDirectory: testDirectory,
        );
        
        expect(filePath, isNotEmpty);
        
        final file = File(filePath);
        expect(await file.exists(), true);
        
        final content = await file.readAsString();
        expect(content, contains('Date,Exercise,Sets,Total Reps,Total Volume (kg)'));
        expect(content, contains('2024-01-15,Bench Press,3,24,2360.0'));
        expect(content, contains('2024-01-17,Squat,3,19,2820.0'));
        
        // Clean up
        await file.delete();
      });
      
      test('should generate exercise detail CSV', () async {
        final filePath = await ExportService.exportToCSV(
          activities: mockActivities,
          type: ExportCSVType.exercises,
          customDirectory: testDirectory,
        );
        
        final file = File(filePath);
        expect(await file.exists(), true);
        
        final content = await file.readAsString();
        expect(content, contains('Date,Exercise,Set,Reps,Weight (kg),Volume (kg),RPE,Rest (sec)'));
        expect(content, contains('2024-01-15,Bench Press,1,10,100.0,1000.0,8.0,120'));
        expect(content, contains('2024-01-17,Squat,2,6,150.0,900.0,9.0,'));
        
        // Clean up
        await file.delete();
      });
      
      test('should generate volume CSV grouped by date', () async {
        final filePath = await ExportService.exportToCSV(
          activities: mockActivities,
          type: ExportCSVType.volume,
          customDirectory: testDirectory,
        );
        
        final file = File(filePath);
        expect(await file.exists(), true);
        
        final content = await file.readAsString();
        expect(content, contains('Date,Total Volume (kg),Total Volume (tons)'));
        expect(content, contains('2024-01-15,2360.0,2.360'));
        expect(content, contains('2024-01-17,2820.0,2.820'));
        
        // Clean up
        await file.delete();
      });
      
      test('should generate personal records CSV', () async {
        final filePath = await ExportService.exportToCSV(
          activities: mockActivities,
          type: ExportCSVType.personalRecords,
          customDirectory: testDirectory,
        );
        
        final file = File(filePath);
        expect(await file.exists(), true);
        
        final content = await file.readAsString();
        expect(content, contains('Date,Exercise,Type,Value,Previous Best,Improvement %'));
        
        // Clean up
        await file.delete();
      });
    });
    
    group('PDF Export', () {
      test('should create PDF file with all sections', () async {
        final filePath = await ExportService.exportToPDF(
          activities: mockActivities,
          personalRecords: mockPRs,
          insights: mockInsights,
          statistics: mockStatistics,
          userName: 'Test User',
          customDirectory: testDirectory,
        );
        
        expect(filePath, isNotEmpty);
        
        final file = File(filePath);
        expect(await file.exists(), true);
        
        // Check file size is reasonable (PDF should have content)
        final fileSize = await file.length();
        expect(fileSize, greaterThan(1000)); // At least 1KB
        
        // Clean up
        await file.delete();
      });
      
      test('should handle empty data gracefully', () async {
        final filePath = await ExportService.exportToPDF(
          activities: [],
          personalRecords: [],
          insights: [],
          statistics: {
            'totalWorkouts': 0,
            'totalVolume': 0,
            'avgDuration': 0,
            'currentStreak': 0,
            'longestStreak': 0,
            'totalPRs': 0,
            'mostTrainedMuscle': 'N/A',
            'favoriteExercise': 'N/A',
          },
          userName: 'Empty User',
          customDirectory: testDirectory,
        );
        
        final file = File(filePath);
        expect(await file.exists(), true);
        
        // Clean up
        await file.delete();
      });
    });
    
    group('File naming', () {
      test('should create unique file names with timestamp', () async {
        final file1 = await ExportService.exportToCSV(
          activities: mockActivities,
          type: ExportCSVType.workouts,
          customDirectory: testDirectory,
        );
        
        // Small delay to ensure different timestamp
        await Future.delayed(Duration(milliseconds: 10));
        
        final file2 = await ExportService.exportToCSV(
          activities: mockActivities,
          type: ExportCSVType.workouts,
          customDirectory: testDirectory,
        );
        
        expect(file1, isNot(equals(file2)));
        
        // Clean up
        await File(file1).delete();
        await File(file2).delete();
      });
      
      test('should include export type in CSV filename', () async {
        final workoutFile = await ExportService.exportToCSV(
          activities: mockActivities,
          type: ExportCSVType.workouts,
          customDirectory: testDirectory,
        );
        
        final volumeFile = await ExportService.exportToCSV(
          activities: mockActivities,
          type: ExportCSVType.volume,
          customDirectory: testDirectory,
        );
        
        expect(workoutFile, contains('workouts_'));
        expect(volumeFile, contains('volume_'));
        
        // Clean up
        await File(workoutFile).delete();
        await File(volumeFile).delete();
      });
    });
  });
}