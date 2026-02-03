/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// ExerciseViewModeProvider - Manage exercise detail view mode
///
/// **Purpose**: Track and update the selected view mode for exercise detail screen
///
/// **State**: ExerciseViewMode enum (compact, detailed, byMuscleGroup, byDate, byMajorWorkouts)
///
/// **Usage**:
/// ```dart
/// // Watch current view mode
/// final viewMode = ref.watch(exerciseViewModeProvider);
///
/// // Update view mode
/// ref.read(exerciseViewModeProvider.notifier).state = ExerciseViewMode.compact;
/// ```
library;

import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/enums/exercise_view_mode.dart';

/// Exercise view mode provider
///
/// **Type**: StateProvider<ExerciseViewMode>
/// **Default**: ExerciseViewMode.detailed
/// **Persistence**: No (resets on app restart)
///
/// **State Management**:
/// - Read: `ref.watch(exerciseViewModeProvider)` (rebuild on change)
/// - Update: `ref.read(exerciseViewModeProvider.notifier).state = newMode`
final exerciseViewModeProvider = createStateProvider<ExerciseViewMode>(
  ExerciseViewMode.detailed,
);
