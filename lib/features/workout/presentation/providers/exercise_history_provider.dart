/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/providers
 * 🎯 Feature: workout
 * 🔧 Type: provider
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: StateNotifierProvider
 * - Exercise History Service
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/exercise_history_service.dart';
import '../../data/repositories/exercise_activity_repository.dart';
import '../../../auth/presentation/providers/user_provider_v2.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Service provider
final exerciseHistoryServiceProvider = Provider<ExerciseHistoryService>((ref) {
  return const ExerciseHistoryService(enableDebugLogging: true);
});

// Recent weights provider
final recentWeightsProvider = FutureProvider.family<List<double>, String>((ref, exerciseName) async {
  final service = ref.read(exerciseHistoryServiceProvider);
  final userState = ref.read(currentUserStateProvider);
  
  final uid = userState.profileOrNull?.uid;
  if (uid == null) return [];
  
  return await service.getRecentWeights(exerciseName, uid, limit: 5);
});

// Recent weights with details provider (weight, reps, date)
// SYNC FIX: Added autoDispose to ensure fresh data when analytics refresh
final recentWeightsWithDetailsProvider = FutureProvider.family.autoDispose<List<ExerciseHistoryData>, String>((ref, exerciseName) async {
  final service = ref.read(exerciseHistoryServiceProvider);
  
  // Try to get user ID directly from Firebase Auth first
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    // Fallback to provider
    final userState = ref.read(currentUserStateProvider);
    final providerUid = userState.profileOrNull?.uid;
    if (providerUid == null) {
      print('DEBUG recentWeightsWithDetailsProvider: No user ID found from Firebase or provider');
      return [];
    }
    // Use provider uid if Firebase Auth uid is null
    print('DEBUG recentWeightsWithDetailsProvider: Using provider uid: "$providerUid"');
  }
  
  final finalUid = uid ?? ref.read(currentUserStateProvider).profileOrNull?.uid;
  if (finalUid == null) {
    print('DEBUG recentWeightsWithDetailsProvider: No user ID available');
    return [];
  }
  
  print('DEBUG recentWeightsWithDetailsProvider: Looking for exercise "$exerciseName" for user "$finalUid"');
  
  // First, let's debug what exercise names we have in the database
  final allExerciseNames = await service.getAllExerciseNames(finalUid);
  print('DEBUG recentWeightsWithDetailsProvider: All exercise names in DB: $allExerciseNames');
  print('DEBUG recentWeightsWithDetailsProvider: Looking for exact match of: "$exerciseName"');
  
  try {
    // Get recent history, then filter for unique weights
    final history = await service.getExerciseHistory(exerciseName, finalUid, limit: 20);
    print('DEBUG recentWeightsWithDetailsProvider: Found ${history.length} history items');
    
    if (history.isEmpty) {
      // Try with variations of the name
      print('DEBUG recentWeightsWithDetailsProvider: No exact match, trying variations...');
      
      // Find similar names in the database
      final similarNames = allExerciseNames.where((name) {
        final nameLower = name.toLowerCase();
        final searchLower = exerciseName.toLowerCase();
        return nameLower.contains(searchLower) || searchLower.contains(nameLower);
      }).toList();
      
      if (similarNames.isNotEmpty) {
        print('DEBUG recentWeightsWithDetailsProvider: Found similar names: $similarNames');
        // Try with the first similar name
        final alternateHistory = await service.getExerciseHistory(similarNames.first, finalUid, limit: 20);
        if (alternateHistory.isNotEmpty) {
          print('DEBUG recentWeightsWithDetailsProvider: Found ${alternateHistory.length} items with name "${similarNames.first}"');
          // Use the alternate history
          history.addAll(alternateHistory);
        }
      }
    }
    
    // Collect all weights with their data
    final allWeights = <ExerciseHistoryData>[];
    for (final data in history) {
      if (data.weight != null && data.weight! > 0) {
        allWeights.add(data);
      }
    }
    
    // Sort by weight descending (heaviest first)
    allWeights.sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));
    
    // Get unique weights, prioritizing heavier weights
    final uniqueWeights = <double, ExerciseHistoryData>{};
    final seenWeights = <double>{};
    
    for (final data in allWeights) {
      final weight = data.weight!;
      
      // Skip if we already have this weight or a very similar one (within 2.5kg)
      bool tooSimilar = false;
      for (final seen in seenWeights) {
        if ((weight - seen).abs() < 2.5) {
          tooSimilar = true;
          break;
        }
      }
      
      if (!tooSimilar && !uniqueWeights.containsKey(weight)) {
        uniqueWeights[weight] = data;
        seenWeights.add(weight);
        print('DEBUG recentWeightsWithDetailsProvider: Added weight ${weight}kg from ${data.date}');
        
        if (uniqueWeights.length >= 5) break; // Limit to 5 unique weights
      }
    }
    
    // Sort the final list by weight descending for display
    final result = uniqueWeights.values.toList()
      ..sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));
    
    print('DEBUG recentWeightsWithDetailsProvider: Returning ${result.length} unique weights: ${result.map((d) => d.weight).toList()}');
    return result;
  } catch (e, stack) {
    print('ERROR recentWeightsWithDetailsProvider: $e');
    print('Stack: $stack');
    return [];
  }
});

// Last exercise data provider
final lastExerciseDataProvider = FutureProvider.family<({double? weight, DateTime? date}), String>((ref, exerciseName) async {
  final service = ref.read(exerciseHistoryServiceProvider);
  final userState = ref.read(currentUserStateProvider);
  
  final uid = userState.profileOrNull?.uid;
  if (uid == null) return (weight: null, date: null);
  
  return await service.getLastExerciseData(exerciseName, uid);
});

// Exercise history provider
final exerciseHistoryProvider = FutureProvider.family<List<ExerciseHistoryData>, String>((ref, exerciseName) async {
  final service = ref.read(exerciseHistoryServiceProvider);
  final userState = ref.read(currentUserStateProvider);
  
  final uid = userState.profileOrNull?.uid;
  if (uid == null) return [];
  
  return await service.getExerciseHistory(exerciseName, uid, limit: 50);
});

// Exercise history grouped provider
final exerciseHistoryGroupedProvider = FutureProvider.family<Map<DateTime, List<ExerciseHistoryData>>, String>((ref, exerciseName) async {
  final service = ref.read(exerciseHistoryServiceProvider);
  final userState = ref.read(currentUserStateProvider);
  
  final uid = userState.profileOrNull?.uid;
  if (uid == null) return {};
  
  return await service.getExerciseHistoryGrouped(exerciseName, uid, limit: 50);
});

// Exercise stats provider
final exerciseStatsProvider = FutureProvider.family<({
  double? maxWeight,
  int totalSets,
  double avgWeight,
  DateTime? firstWorkout,
  DateTime? lastWorkout,
}), String>((ref, exerciseName) async {
  final service = ref.read(exerciseHistoryServiceProvider);
  final userState = ref.read(currentUserStateProvider);
  
  final uid = userState.profileOrNull?.uid;
  if (uid == null) {
    return (
      maxWeight: null,
      totalSets: 0,
      avgWeight: 0.0,
      firstWorkout: null,
      lastWorkout: null,
    );
  }
  
  return await service.getExerciseStats(exerciseName, uid);
});