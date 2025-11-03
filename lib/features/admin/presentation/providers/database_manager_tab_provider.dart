/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Providers for Database Manager tab structure and state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// TAB STATE PROVIDERS
// ============================================================================

/// Current selected tab index (0=Overview, 1=Exercises IT, 2=Exercises EN)
final selectedTabProvider = StateProvider<int>((ref) => 0);

/// Show detailed columns in data table (persisted to SharedPreferences)
final showDetailedColumnsProvider = StateProvider<bool>((ref) {
  // Default to false (minimal columns), will be loaded from SharedPreferences in initState
  return false;
});

/// Overview tab statistics language selector ('it' or 'en')
final overviewStatsLanguageProvider = StateProvider<String>((ref) => 'it');

// ============================================================================
// SELECTION STATE PROVIDERS
// ============================================================================

/// Selected exercise IDs for IT tab (for bulk operations)
final selectedExercisesITProvider = StateProvider<Set<String>>((ref) => {});

/// Selected exercise IDs for EN tab (for bulk operations)
final selectedExercisesENProvider = StateProvider<Set<String>>((ref) => {});

// ============================================================================
// FIRESTORE STREAM PROVIDERS
// ============================================================================

/// Stream provider for Italian exercises (exercises_it collection)
final exercisesITStreamProvider = StreamProvider<List<Exercise>>((ref) {
  return FirebaseFirestore.instance
      .collection('exercises_it')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add document ID to data
      return Exercise.fromJson(data);
    }).toList();
  }).handleError((error) {
    // Error handling with proper logging
    throw Exception('Failed to load IT exercises: $error');
  });
});

/// Stream provider for English exercises (exercises_en collection)
final exercisesENStreamProvider = StreamProvider<List<Exercise>>((ref) {
  return FirebaseFirestore.instance
      .collection('exercises_en')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add document ID to data
      return Exercise.fromJson(data);
    }).toList();
  }).handleError((error) {
    // Error handling with proper logging
    throw Exception('Failed to load EN exercises: $error');
  });
});

/// Stream provider for exercises metadata (version_info document)
final metadataStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return FirebaseFirestore.instance
      .collection('exercises_metadata')
      .doc('version_info')
      .snapshots()
      .map((snapshot) => snapshot.exists ? snapshot.data() : null)
      .handleError((error) {
    // Error handling with proper logging
    throw Exception('Failed to load metadata: $error');
  });
});

// ============================================================================
// SHARED PREFERENCES PROVIDER
// ============================================================================

/// Provider for SharedPreferences instance (for persisting column preference)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main.dart');
});

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Save column preference to SharedPreferences
Future<void> saveColumnPreference(bool showDetailed) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('show_detailed_columns', showDetailed);
}

/// Load column preference from SharedPreferences
Future<bool> loadColumnPreference() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('show_detailed_columns') ?? false;
}
