/// 🏋️‍♂️ GymBro TrackLog - Analytics Migration Script
///
/// **Purpose**: Populate analytics collection from existing workouts
///
/// **Problem**: Old workouts saved to `users/{userId}/workouts` but NOT to `users/{userId}/analytics`
///
/// **Solution**: Read all workouts and populate analytics retroactively
///
/// **Usage**:
/// ```bash
/// dart scripts/migrate_analytics.dart
/// ```
///
/// **What it does**:
/// 1. Reads all workouts from Firestore (users/{userId}/workouts)
/// 2. Converts each workout to analytics sessions using WorkoutToAnalyticsConverter
/// 3. Updates analytics collection (users/{userId}/analytics/{exerciseName})
/// 4. Shows progress and summary
///
/// **Safety**:
/// - Read-only on workouts collection (no modifications)
/// - Idempotent (can be run multiple times safely)
/// - Updates analytics incrementally (no data loss)
///
/// **Dry-run mode**:
/// ```bash
/// dart scripts/migrate_analytics.dart --dry-run
/// ```

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/analytics/data/converters/workout_to_analytics_converter.dart';

void main(List<String> arguments) async {
  print('🏋️ GymBro TrackLog - Analytics Migration Script');
  print('================================================\n');

  // Parse arguments
  final dryRun = arguments.contains('--dry-run');
  if (dryRun) {
    print('🔍 DRY-RUN MODE: No data will be written\n');
  }

  // Initialize Firebase
  print('📱 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase initialized\n');

  final firestore = FirebaseFirestore.instance;

  // Get user ID from command line or prompt
  String? userId;
  if (arguments.isNotEmpty && !arguments.first.startsWith('--')) {
    userId = arguments.first;
  } else {
    print('Enter user ID (Firebase UID):');
    userId = stdin.readLineSync();
  }

  if (userId == null || userId.isEmpty) {
    print('❌ Error: User ID is required');
    print('\nUsage: dart scripts/migrate_analytics.dart <userId> [--dry-run]');
    exit(1);
  }

  print('👤 User ID: $userId\n');

  // Fetch all workouts for user
  print('📊 Fetching workouts from Firestore...');
  final workoutsSnapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('workouts')
      .get();

  print('✅ Found ${workoutsSnapshot.docs.length} workouts\n');

  if (workoutsSnapshot.docs.isEmpty) {
    print('ℹ️ No workouts found for this user. Migration not needed.');
    exit(0);
  }

  // Process each workout
  int totalWorkouts = 0;
  int totalExercises = 0;
  int skippedWorkouts = 0;
  final Set<String> uniqueExercises = {};

  for (final doc in workoutsSnapshot.docs) {
    try {
      // Parse workout
      final data = doc.data();
      final workoutModel = WorkoutModel.fromJson(data);
      final workout = workoutModel.toDomain();

      // Skip if not completed
      if (!workout.isCompleted) {
        skippedWorkouts++;
        continue;
      }

      print('📝 Processing workout: ${workout.name} (${workout.createdAt})');

      // Convert to analytics data
      final analyticsData = WorkoutToAnalyticsConverter.convert(workout);

      if (analyticsData.isEmpty) {
        print('   ⚠️ No valid exercises to migrate (all sets incomplete)');
        skippedWorkouts++;
        continue;
      }

      print('   📊 Found ${analyticsData.length} exercises to migrate');

      // Update analytics for each exercise
      for (final data in analyticsData) {
        uniqueExercises.add(data.exerciseName);

        if (dryRun) {
          print('   🔍 DRY-RUN: Would update analytics for ${data.exerciseName} (${data.session.sets.length} sets)');
          continue;
        }

        // Read existing analytics document
        final docRef = firestore
            .collection('users')
            .doc(userId)
            .collection('analytics')
            .doc(data.exerciseName);

        final existingDoc = await docRef.get();

        List<Map<String, dynamic>> existingSessions = [];
        if (existingDoc.exists) {
          final existingData = existingDoc.data();
          existingSessions = List<Map<String, dynamic>>.from(
            existingData?['sessions'] ?? [],
          );
        }

        // Append new session
        existingSessions.add({
          'exerciseName': data.session.exerciseName,
          'muscleGroup': data.session.muscleGroup,
          'date': Timestamp.fromDate(data.session.date),
          'sets': data.session.sets.map((set) => {
            'weight': set.weight,
            'reps': set.reps,
            'date': Timestamp.fromDate(set.date),
          }).toList(),
        });

        // Write to Firestore
        await docRef.set({
          'exerciseName': data.exerciseName,
          'muscleGroup': data.muscleGroup,
          'sessions': existingSessions,
        });

        print('   ✅ Updated analytics for ${data.exerciseName}');
        totalExercises++;
      }

      totalWorkouts++;
    } catch (e, stackTrace) {
      print('   ❌ Error processing workout ${doc.id}: $e');
      print('   Stack trace: $stackTrace');
      skippedWorkouts++;
    }
  }

  // Summary
  print('\n================================================');
  print('📊 MIGRATION SUMMARY');
  print('================================================');
  print('Total workouts processed: $totalWorkouts');
  print('Total exercises migrated: $totalExercises');
  print('Unique exercises: ${uniqueExercises.length}');
  print('Workouts skipped: $skippedWorkouts');
  print('');

  if (dryRun) {
    print('🔍 DRY-RUN MODE: No data was written');
    print('   Remove --dry-run flag to execute migration');
  } else {
    print('✅ Migration completed successfully!');
    print('');
    print('Migrated exercises:');
    for (final exercise in uniqueExercises.toList()..sort()) {
      print('  - $exercise');
    }
  }

  print('\n🎉 Done!');
  exit(0);
}
