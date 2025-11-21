/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/providers
/// 🎯 Feature: flexible_routine
/// 🔧 Type: providers (state management)
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// ROUTINE PROVIDERS - Core State Management
///
/// Provides Riverpod providers for:
/// - Active routine watching (real-time Firestore stream)
/// - User routines list watching (all routines for user)
/// - Selected preset state (for routine creation wizard)
/// - Training days state (for routine creation wizard)
/// - Day-to-template assignments (for routine creation wizard)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/data/repositories/firebase_routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/routine_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

// ──────────────────────────────────────────────────────────────────────────
// REPOSITORY PROVIDERS
// ──────────────────────────────────────────────────────────────────────────

/// Firebase auth user provider (dependency)
final authUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Current user ID provider (extracted from auth)
final currentUserIdProvider = Provider<String?>((ref) {
  final authUser = ref.watch(authUserProvider).value;
  return authUser?.uid;
});

/// Firestore instance provider (for repository injection)
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Routine repository provider (singleton)
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseRoutineRepository(firestore: firestore);
});

// ──────────────────────────────────────────────────────────────────────────
// ACTIVE ROUTINE PROVIDERS
// ──────────────────────────────────────────────────────────────────────────

/// Watch active routine for current user (real-time stream)
///
/// Returns:
/// - FlexibleRoutine if user has active routine
/// - null if no active routine
/// - AsyncLoading while loading
/// - AsyncError on Firestore errors
final activeRoutineProvider = StreamProvider<FlexibleRoutine?>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  // Return empty stream if no user logged in
  if (userId == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(routineRepositoryProvider);
  return repository.watchActiveRoutine(userId);
});

// ──────────────────────────────────────────────────────────────────────────
// USER ROUTINES LIST PROVIDERS
// ──────────────────────────────────────────────────────────────────────────

/// Watch all routines for current user (real-time stream, sorted by createdAt desc)
///
/// Returns:
/// - `List<FlexibleRoutine>` (may be empty)
/// - AsyncLoading while loading
/// - AsyncError on Firestore errors
final userRoutinesProvider = StreamProvider<List<FlexibleRoutine>>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  // Return empty list if no user logged in
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(routineRepositoryProvider);
  return repository.watchUserRoutines(userId);
});

// ──────────────────────────────────────────────────────────────────────────
// ROUTINE CREATION WIZARD STATE (Step 1: Preset Selection)
// ──────────────────────────────────────────────────────────────────────────

/// Selected preset type state (for creation wizard)
///
/// Usage:
/// - Step 1: User selects preset → setState
/// - Step 2: Use preset to load suggested templates
final selectedPresetProvider =
    StateProvider<RoutinePreset?>((ref) => null);

// ──────────────────────────────────────────────────────────────────────────
// ROUTINE CREATION WIZARD STATE (Step 2: Training Days + Template Assignment)
// ──────────────────────────────────────────────────────────────────────────

/// Training days state (selected weekdays)
///
/// Usage:
/// - User toggles days (1=Monday, 7=Sunday)
/// - State updates to `Set<int>`
/// - Used to create FlexibleRoutine.trainingDays
final trainingDaysProvider = StateProvider<Set<int>>((ref) {
  // Initialize with preset's default days if preset selected
  final preset = ref.watch(selectedPresetProvider);
  if (preset != null && preset != RoutinePreset.custom) {
    return preset.defaultTrainingDays;
  }
  return {};
});

/// Day-to-template assignments state (`Map<int, WorkoutTemplate>`)
///
/// Usage:
/// - Key = weekday (1-7)
/// - Value = assigned WorkoutTemplate
/// - User assigns templates to each training day
/// - Used to create FlexibleRoutine.dayTemplates
final dayTemplatesProvider =
    StateProvider<Map<int, WorkoutTemplate>>((ref) => {});

// ──────────────────────────────────────────────────────────────────────────
// COMPUTED PROVIDERS (Derived State)
// ──────────────────────────────────────────────────────────────────────────

/// Check if user has active routine (derived from activeRoutineProvider)
final hasActiveRoutineProvider = Provider<bool>((ref) {
  final activeRoutine = ref.watch(activeRoutineProvider).value;
  return activeRoutine != null;
});

/// Get total routine count (derived from userRoutinesProvider)
final routineCountProvider = Provider<int>((ref) {
  final routines = ref.watch(userRoutinesProvider).value ?? [];
  return routines.length;
});

/// Check if routine creation wizard is complete (all required fields filled)
///
/// Required:
/// - Preset selected
/// - Training days selected (at least 1)
/// - Template assigned for EACH training day
final isRoutineCreationCompleteProvider = Provider<bool>((ref) {
  final preset = ref.watch(selectedPresetProvider);
  final trainingDays = ref.watch(trainingDaysProvider);
  final dayTemplates = ref.watch(dayTemplatesProvider);

  // Must have preset and at least 1 training day
  if (preset == null || trainingDays.isEmpty) {
    return false;
  }

  // Must have template assigned for EACH training day
  for (final day in trainingDays) {
    if (!dayTemplates.containsKey(day)) {
      return false; // Missing template for this day
    }
  }

  return true;
});
