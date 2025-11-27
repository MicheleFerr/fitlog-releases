import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';

/// 🚀 TIER-1 OPTIMIZATION PROVIDERS
/// High-performance state management with selective updates

// ============================================================================
// EXERCISE STATS PROVIDER - Memoized calculations per exercise
// ============================================================================

final exerciseStatsProvider = Provider.family<ExerciseStats, String>((ref, exerciseId) {
  final workout = ref.watch(currentWorkoutProvider);
  final exercise = workout?.exercises.firstWhereOrNull((e) => e.id == exerciseId);
  
  if (exercise == null) {
    return ExerciseStats.empty();
  }
  
  return ExerciseStats.fromExercise(exercise);
});

class ExerciseStats {
  
  ExerciseStats({
    required this.completedSets,
    required this.totalSets,
    required this.totalVolume,
    required this.averageRpe,
    required this.totalRestTime,
    required this.isComplete,
  });
  
  factory ExerciseStats.empty() => ExerciseStats(
    completedSets: 0,
    totalSets: 0,
    totalVolume: 0,
    averageRpe: 0,
    totalRestTime: Duration.zero,
    isComplete: false,
  );
  
  factory ExerciseStats.fromExercise(Exercise exercise) {
    final completedSets = exercise.sets.where((s) => s.isCompleted).length;
    final totalSets = exercise.sets.length;
    
    double totalVolume = 0;
    double totalRpe = 0;
    int rpeCount = 0;
    Duration totalRest = Duration.zero;
    
    for (final set in exercise.sets) {
      if (set.isCompleted) {
        totalVolume += set.volume;
        
        if (set.rpe != null) {
          totalRpe += set.rpe!;
          rpeCount++;
        }
        
        if (set.restTime != null) {
          totalRest += Duration(seconds: set.restTime!);
        }
      }
    }
    
    return ExerciseStats(
      completedSets: completedSets,
      totalSets: totalSets,
      totalVolume: totalVolume,
      averageRpe: rpeCount > 0 ? totalRpe / rpeCount : 0,
      totalRestTime: totalRest,
      isComplete: completedSets == totalSets && totalSets > 0,
    );
  }
  final int completedSets;
  final int totalSets;
  final double totalVolume;
  final double averageRpe;
  final Duration totalRestTime;
  final bool isComplete;
}

// ============================================================================
// SET PROVIDER - Individual set state management
// ============================================================================

final setProvider = NotifierProvider.family<SetNotifier, ExerciseSet?, (String, String)>(
  SetNotifier.new,
);

class SetNotifier extends FamilyNotifier<ExerciseSet?, (String, String)> {
  late final String exerciseId;
  late final String setId;

  @override
  ExerciseSet? build((String, String) params) {
    exerciseId = params.$1;
    setId = params.$2;

    final workout = ref.read(currentWorkoutProvider);
    final exercise = workout?.exercises.firstWhereOrNull((e) => e.id == exerciseId);
    return exercise?.sets.firstWhereOrNull((s) => s.id == setId);
  }

  void updateSet({
    double? weight,
    int? reps,
    int? actualReps,
    int? rpe,
    String? notes,
  }) {
    if (state == null) return;
    
    state = state!.copyWith(
      weight: weight,
      reps: reps,
      actualReps: actualReps,
      rpe: rpe,
      notes: notes,
    );

    // Update in workout
    ref.read(currentWorkoutProvider.notifier).updateExerciseSet(exerciseId, state!);
  }

  void toggleComplete() {
    if (state == null) return;

    final now = DateTime.now();
    state = state!.copyWith(
      isCompleted: !state!.isCompleted,
      completedAt: !state!.isCompleted ? now : null,
      actualReps: !state!.isCompleted ? state!.reps : null,
    );

    // Update in workout
    ref.read(currentWorkoutProvider.notifier).updateExerciseSet(exerciseId, state!);
  }
}

// ============================================================================
// WORKOUT CACHE PROVIDER - Memory-efficient caching
// ============================================================================

final workoutCacheProvider = Provider<WorkoutCache>((ref) {
  return WorkoutCache(ref);
});

class WorkoutCache {
  
  WorkoutCache(this.ref);
  final Ref ref;
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _timestamps = {};
  static const _cacheTimeout = Duration(seconds: 30);
  
  T? get<T>(String key) {
    final timestamp = _timestamps[key];
    if (timestamp != null && 
        DateTime.now().difference(timestamp) < _cacheTimeout) {
      return _cache[key] as T?;
    }
    return null;
  }
  
  void set<T>(String key, T value) {
    _cache[key] = value;
    _timestamps[key] = DateTime.now();
  }
  
  void invalidate(String key) {
    _cache.remove(key);
    _timestamps.remove(key);
  }
  
  void clear() {
    _cache.clear();
    _timestamps.clear();
  }
}

// ============================================================================
// UNDO/REDO PROVIDER - Command pattern for actions
// ============================================================================

final undoRedoProvider = NotifierProvider<UndoRedoNotifier, UndoRedoState>(UndoRedoNotifier.new);

class UndoRedoState {
  
  UndoRedoState({
    required this.undoStack,
    required this.redoStack,
  }) : canUndo = undoStack.isNotEmpty,
       canRedo = redoStack.isNotEmpty;
  
  factory UndoRedoState.initial() => UndoRedoState(
    undoStack: [],
    redoStack: [],
  );
  final List<WorkoutCommand> undoStack;
  final List<WorkoutCommand> redoStack;
  final bool canUndo;
  final bool canRedo;
}

abstract class WorkoutCommand {
  
  WorkoutCommand({
    required this.description,
  }) : timestamp = DateTime.now();
  final DateTime timestamp;
  final String description;
  
  void execute(Ref ref);
  void undo(Ref ref);
}

class AddExerciseCommand extends WorkoutCommand {
  
  AddExerciseCommand(this.exercise) 
    : super(description: 'Add ${exercise.name}');
  final Exercise exercise;
  
  @override
  void execute(Ref ref) {
    ref.read(currentWorkoutProvider.notifier).addExercise(exercise);
  }
  
  @override
  void undo(Ref ref) {
    ref.read(currentWorkoutProvider.notifier).removeExercise(exercise.id);
  }
}

class UpdateSetCommand extends WorkoutCommand {
  
  UpdateSetCommand({
    required this.exerciseId,
    required this.oldSet,
    required this.newSet,
  }) : super(description: 'Update set');
  final String exerciseId;
  final ExerciseSet oldSet;
  final ExerciseSet newSet;
  
  @override
  void execute(Ref ref) {
    ref.read(currentWorkoutProvider.notifier).updateExerciseSet(exerciseId, newSet);
  }

  @override
  void undo(Ref ref) {
    ref.read(currentWorkoutProvider.notifier).updateExerciseSet(exerciseId, oldSet);
  }
}

class UndoRedoNotifier extends Notifier<UndoRedoState> {
  static const _maxStackSize = 20;

  @override
  UndoRedoState build() => UndoRedoState.initial();
  
  void execute(WorkoutCommand command) {
    command.execute(ref);
    
    // Add to undo stack
    final newUndoStack = [...state.undoStack, command];
    if (newUndoStack.length > _maxStackSize) {
      newUndoStack.removeAt(0);
    }
    
    // Clear redo stack
    state = UndoRedoState(
      undoStack: newUndoStack,
      redoStack: [],
    );
  }
  
  void undo() {
    if (!state.canUndo) return;
    
    final command = state.undoStack.last;
    command.undo(ref);
    
    state = UndoRedoState(
      undoStack: state.undoStack.sublist(0, state.undoStack.length - 1),
      redoStack: [...state.redoStack, command],
    );
  }
  
  void redo() {
    if (!state.canRedo) return;
    
    final command = state.redoStack.last;
    command.execute(ref);
    
    state = UndoRedoState(
      undoStack: [...state.undoStack, command],
      redoStack: state.redoStack.sublist(0, state.redoStack.length - 1),
    );
  }
  
  void clear() {
    state = UndoRedoState.initial();
  }
}

// ============================================================================
// BATCH OPERATIONS PROVIDER
// ============================================================================

final batchOperationsProvider = Provider<BatchOperations>((ref) {
  return BatchOperations(ref);
});

class BatchOperations {
  
  BatchOperations(this.ref);
  final Ref ref;
  
  /// Complete all sets for an exercise
  void completeAllSets(String exerciseId) {
    final workout = ref.read(currentWorkoutProvider);
    final exercise = workout?.exercises.firstWhereOrNull((e) => e.id == exerciseId);
    
    if (exercise == null) return;
    
    final now = DateTime.now();
    final updatedSets = exercise.sets.map((set) => 
      set.copyWith(
        isCompleted: true,
        completedAt: now,
        actualReps: set.actualReps ?? set.reps,
      )
    ).toList();
    
    // ✅ Note: isCompleted and completedAt are computed getters
    // They are automatically calculated from the completed sets
    final updatedExercise = exercise.copyWith(
      sets: updatedSets,
    );

    ref.read(currentWorkoutProvider.notifier).updateExercise(exerciseId, updatedExercise);
  }
  
  /// Clear all sets for an exercise
  void clearAllSets(String exerciseId) {
    final workout = ref.read(currentWorkoutProvider);
    final exercise = workout?.exercises.firstWhereOrNull((e) => e.id == exerciseId);
    
    if (exercise == null) return;
    
    final updatedSets = exercise.sets.map((set) => 
      set.copyWith(
        isCompleted: false,
        completedAt: null,
        actualReps: null,
      )
    ).toList();
    
    // ✅ Note: isCompleted and completedAt are computed getters
    // They are automatically calculated from the completed sets
    final updatedExercise = exercise.copyWith(
      sets: updatedSets,
    );

    ref.read(currentWorkoutProvider.notifier).updateExercise(exerciseId, updatedExercise);
  }
  
  /// Copy sets from previous workout
  Future<void> copySetsFromHistory(String exerciseId) async {
    // Implementation for copying sets from history
  }
  
  /// Apply progressive overload
  void applyProgressiveOverload(String exerciseId, {
    double weightIncrease = 2.5,
    int repsIncrease = 0,
  }) {
    final workout = ref.read(currentWorkoutProvider);
    final exercise = workout?.exercises.firstWhereOrNull((e) => e.id == exerciseId);
    
    if (exercise == null) return;
    
    // ✅ Null-safe: weight and reps are nullable
    final updatedSets = exercise.sets.map((set) =>
      set.copyWith(
        weight: set.weight != null ? set.weight! + weightIncrease : null,
        reps: set.reps != null ? set.reps! + repsIncrease : null,
      )
    ).toList();

    final updatedExercise = exercise.copyWith(sets: updatedSets);

    ref.read(currentWorkoutProvider.notifier).updateExercise(exerciseId, updatedExercise);
  }
}

// ============================================================================
// OFFLINE SYNC PROVIDER
// ============================================================================

final offlineSyncProvider = NotifierProvider<OfflineSyncNotifier, OfflineSyncState>(OfflineSyncNotifier.new);

class OfflineSyncState {
  
  OfflineSyncState({
    required this.isOnline,
    required this.pendingActions,
    this.lastSyncTime,
    required this.isSyncing,
  });
  
  factory OfflineSyncState.initial() => OfflineSyncState(
    isOnline: true,
    pendingActions: [],
    isSyncing: false,
  );
  final bool isOnline;
  final List<PendingAction> pendingActions;
  final DateTime? lastSyncTime;
  final bool isSyncing;
}

class PendingAction {
  
  PendingAction({
    required this.id,
    required this.type,
    required this.data,
  }) : timestamp = DateTime.now();
  final String id;
  final ActionType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
}

enum ActionType {
  createWorkout,
  updateWorkout,
  deleteWorkout,
  createExercise,
  updateExercise,
  deleteExercise,
  updateSet,
}

class OfflineSyncNotifier extends Notifier<OfflineSyncState> {
  @override
  OfflineSyncState build() => OfflineSyncState.initial();
  
  void addPendingAction(ActionType type, Map<String, dynamic> data) {
    state = state.copyWith(
      pendingActions: [
        ...state.pendingActions,
        PendingAction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          data: data,
        ),
      ],
    );
  }
  
  Future<void> syncPendingActions() async {
    if (state.isSyncing || !state.isOnline || state.pendingActions.isEmpty) {
      return;
    }
    
    state = state.copyWith(isSyncing: true);
    
    try {
      for (final action in state.pendingActions) {
        await _processPendingAction(action);
      }
      
      state = state.copyWith(
        pendingActions: [],
        lastSyncTime: DateTime.now(),
        isSyncing: false,
      );
    } catch (e) {
      state = state.copyWith(isSyncing: false);
      rethrow;
    }
  }
  
  Future<void> _processPendingAction(PendingAction action) async {
    // Process each action type
    switch (action.type) {
      case ActionType.createWorkout:
        // Sync workout creation
        break;
      case ActionType.updateWorkout:
        // Sync workout update
        break;
      // ... handle other action types
      default:
        break;
    }
  }
}

// Extension to add copyWith method to OfflineSyncState
extension OfflineSyncStateExtension on OfflineSyncState {
  OfflineSyncState copyWith({
    bool? isOnline,
    List<PendingAction>? pendingActions,
    DateTime? lastSyncTime,
    bool? isSyncing,
  }) {
    return OfflineSyncState(
      isOnline: isOnline ?? this.isOnline,
      pendingActions: pendingActions ?? this.pendingActions,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}