# Template Save System - Complete Design Document

**Generated**: 2025-11-22
**Source**: Brainstorming Session + User Feedback
**Complexity Score**: HIGH
**Reason**: Multi-layer architecture + Race condition fixes + Dual persistence + Transaction locks
**Total Components**: 12 (3 entities, 3 repositories, 3 services, 3 UI screens)
**Estimated Implementation Time**: ~12-15h
**Design Version**: 1.0

---

## 📋 Executive Summary

This document describes a complete redesign of the template save system for the GymBro Flutter fitness app. The new system addresses critical vulnerabilities in the current Firebase-based approach, including:

- **Offline-first architecture** with local-wins conflict resolution
- **Snapshot validation** to detect concurrent template modifications
- **Transaction locks** to prevent ghost state from undo+sync race conditions
- **Smart UX** with progressive disclosure and ≤3 taps workflow
- **Dual-layer persistence** (volatile provider + persistent Hive cache)
- **Hybrid preference system** (global defaults + template-specific overrides)

**Key Innovation**: The system uses a novel dual-layer snapshot persistence strategy combined with transaction locks to prevent all known race conditions while maintaining a seamless user experience.

---

## 🎯 Problem Statement

### Current Implementation Issues

**File**: `lib/features/workout/presentation/helpers/save_template_helper.dart`

The current implementation:
1. ✅ Uses Firebase for template storage
2. ❌ No duplicate name handling
3. ❌ No post-workout template update workflow
4. ❌ No ability to preserve exercise structure while updating weights/reps
5. ❌ No offline support
6. ❌ Vulnerable to race conditions on concurrent modifications

### User Requirements

1. **Primary**: Change from Firestore to local storage (Hive)
2. **Duplicate Names**: Ask user to overwrite or rename with smart suggestions
3. **Post-Workout Save**: Allow updating template weights/reps after completing workout
4. **Preserve Structure**: Keep exercise order, notes, flags but update performance data
5. **UX Quality**: ≤3 taps, progressive disclosure, "remember my choice" with reset
6. **Offline-First**: Local-wins strategy for conflict resolution

### Critical Vulnerabilities Discovered During Brainstorming

**Issue 1**: Template rename race condition
**Scenario**: User starts workout from "Push Day A", during workout template is renamed to "Push Day A v2", user completes workout → which template gets updated?
**Impact**: Data loss or wrong template overwrite

**Issue 2**: Ambiguous preservation logic
**Scenario**: `preserveFlags: true` doesn't specify what to preserve (timestamps? exercise order? notes?)
**Impact**: Unpredictable behavior, hard to debug

**Issue 3**: Undo + Background Sync ghost state
**Scenario**: User saves template, immediately hits undo, but background sync already sent to cloud → cloud overwrites local undo
**Impact**: User thinks undo worked but template is actually saved

---

## 🏗️ Architecture Overview

### High-Level Decision Tree

```
Workout Completed from Template
         ↓
┌─────────────────────────────────┐
│ Snapshot Validation              │
│ Compare: current name vs frozen  │
└─────────────────────────────────┘
         ↓
    ┌────┴────┐
 No change  Renamed
    │          │
    │          ├─→ Check timestamp
    │          │   ├─→ Renamed BEFORE workout start
    │          │   │   → Use current name silently
    │          │   └─→ Renamed AFTER workout start
    │          │       → Show conflict dialog
    │          │           ├─→ User: Keep new name
    │          │           └─→ User: Restore old name
    │
    ↓
┌─────────────────────────────────┐
│ Check User Preference            │
│ Global or Template-specific     │
└─────────────────────────────────┘
         ↓
    ┌────┴────┐
 askAlways  Remembered
    │          │
    │          ├─→ alwaysOverwrite → Apply silently
    │          ├─→ alwaysNew → Generate name + save
    │          └─→ neverSave → Skip silently
    │
    ↓
┌─────────────────────────────────┐
│ Show PostWorkoutTemplateDialog  │
│ Options:                        │
│ 1. Sovrascrivi pesi/reps        │
│ 2. Salva come nuovo             │
│ 3. Avanti senza salvare         │
│ + "Ricorda la mia scelta" ☐     │
└─────────────────────────────────┘
         ↓
    User chooses
         ↓
┌─────────────────────────────────┐
│ Acquire Transaction Lock        │
│ Duration: 15s (undo window)     │
│ Rollback snapshot: original     │
└─────────────────────────────────┘
         ↓
┌─────────────────────────────────┐
│ Apply Template Update           │
│ Local Hive save (instant)       │
│ Update provider state           │
│ Invalidate fuzzy search cache   │
│ Notify isolate (message pass)   │
└─────────────────────────────────┘
         ↓
┌─────────────────────────────────┐
│ Show Undo Toast (15s)           │
│ "Template aggiornato" [UNDO]    │
└─────────────────────────────────┘
         ↓
    ┌────┴────┐
 Undo tapped  Timer expires
    │            │
    │            ├─→ Release lock
    │            └─→ Background sync (if premium)
    │
    ↓
  Rollback to snapshot
  Release lock
  Show "Annullato" toast
```

### Layer Architecture (Clean Architecture)

```
┌──────────────────────────────────────────────────┐
│ PRESENTATION LAYER                               │
│ - PostWorkoutTemplateDialog                      │
│ - TemplateNameConflictDialog                     │
│ - TemplatePreferencesSettingsScreen              │
│ - workoutTemplateSnapshotProvider                │
└──────────────────────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────┐
│ DOMAIN LAYER                                     │
│ - TemplateModificationSnapshot (entity)          │
│ - TemplateTransactionLock (entity)               │
│ - TemplatePreserveFlag (enum)                    │
│ - TemplateTimestampBehavior (enum)               │
│ - TemplateSavePreference (enum)                  │
└──────────────────────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────┐
│ DATA LAYER                                       │
│ - HybridTemplateRepository (existing, enhanced)  │
│ - SnapshotCacheRepository (new)                  │
│ - TemplateTransactionLockRepository (new)        │
│ - TemplateNameConflictService (new)              │
│ - FuzzySearchIsolateManager (new)                │
└──────────────────────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────┐
│ LOCAL STORAGE                                    │
│ - Hive Box: workout_templates                    │
│ - Hive Box: template_snapshots                   │
│ - Hive Box: template_transaction_locks           │
│ - Hive Box: template_preferences                 │
└──────────────────────────────────────────────────┘
```

---

## 🛡️ Critical Issue Fixes

### Fix Issue 1: Template Rename Race Condition

**Problem**: Can't detect if template was renamed during workout

**Solution**: Snapshot validation with timestamp-based logic

#### Sub-fix 1.1: Snapshot Persistence with Local Cache Fallback

**Vulnerability**: Provider can be GC'd during long workouts

**Implementation**:

```dart
// ENTITY: lib/features/workout/domain/entities/workout_snapshot_cache.dart
@freezed
class WorkoutSnapshotCache with _$WorkoutSnapshotCache {
  const factory WorkoutSnapshotCache({
    required String workoutSessionId,
    required TemplateModificationSnapshot snapshot,
    required DateTime createdAt,
  }) = _WorkoutSnapshotCache;

  factory WorkoutSnapshotCache.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSnapshotCacheFromJson(json);
}

// REPOSITORY: lib/features/workout/data/repositories/snapshot_cache_repository.dart
class SnapshotCacheRepository {
  final Box<Map> _snapshotBox;

  SnapshotCacheRepository(this._snapshotBox);

  Future<void> saveSnapshot(WorkoutSnapshotCache cache) async {
    await _snapshotBox.put(cache.workoutSessionId, cache.toJson());

    debugPrint('💾 Snapshot saved to Hive: ${cache.workoutSessionId}');
  }

  Future<WorkoutSnapshotCache?> getSnapshot(String sessionId) async {
    final data = _snapshotBox.get(sessionId);
    if (data == null) return null;

    return WorkoutSnapshotCache.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<void> deleteSnapshot(String sessionId) async {
    await _snapshotBox.delete(sessionId);
  }

  /// Cleanup snapshots older than 7 days (called on app start)
  Future<void> cleanupOldSnapshots() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final keysToDelete = <String>[];

    for (final key in _snapshotBox.keys) {
      final data = _snapshotBox.get(key);
      if (data == null) continue;

      final cache = WorkoutSnapshotCache.fromJson(
        Map<String, dynamic>.from(data),
      );

      if (cache.createdAt.isBefore(cutoff)) {
        keysToDelete.add(key);
      }
    }

    await _snapshotBox.deleteAll(keysToDelete);
    debugPrint('🧹 Cleaned up ${keysToDelete.length} old snapshots');
  }
}

// PROVIDER: lib/features/workout/presentation/providers/workout_snapshot_provider.dart
final snapshotCacheRepositoryProvider = Provider<SnapshotCacheRepository>((ref) {
  final box = Hive.box<Map>('template_snapshots');
  return SnapshotCacheRepository(box);
});

final workoutTemplateSnapshotProvider =
    StateProvider<TemplateModificationSnapshot?>((ref) => null);
```

**Dual-layer persistence strategy**:

```dart
// When workout starts from template:
Future<void> startWorkoutFromTemplate(
  WorkoutTemplate template,
  TemplateSavePreference defaultPreference,
) async {
  final sessionId = const Uuid().v4();

  final snapshot = TemplateModificationSnapshot(
    templateId: template.id,
    snapshotName: template.name, // Freeze current name
    snapshotTimestamp: DateTime.now(),
    userPreference: defaultPreference,
  );

  final cache = WorkoutSnapshotCache(
    workoutSessionId: sessionId,
    snapshot: snapshot,
    createdAt: DateTime.now(),
  );

  // Layer 1: Provider (fast, in-memory)
  ref.read(workoutTemplateSnapshotProvider.notifier).state = snapshot;

  // Layer 2: Hive (persistent, survives GC)
  await ref.read(snapshotCacheRepositoryProvider).saveSnapshot(cache);

  debugPrint('📸 Snapshot created (dual-layer): ${template.name}');
}
```

**Retrieval with fallback**:

```dart
// When workout completes:
Future<TemplateModificationSnapshot?> getSnapshotWithFallback(
  String workoutSessionId,
) async {
  // Try Layer 1: Provider (fast)
  var snapshot = ref.read(workoutTemplateSnapshotProvider);

  if (snapshot != null) {
    debugPrint('✅ Snapshot from provider (fast path)');
    return snapshot;
  }

  // Fallback Layer 2: Hive (persistent)
  final cache = await ref
      .read(snapshotCacheRepositoryProvider)
      .getSnapshot(workoutSessionId);

  if (cache != null) {
    debugPrint('✅ Snapshot from Hive cache (fallback path)');

    // Restore to provider for future fast access
    ref.read(workoutTemplateSnapshotProvider.notifier).state = cache.snapshot;

    return cache.snapshot;
  }

  debugPrint('❌ No snapshot found (provider GC + Hive miss)');
  return null;
}
```

#### Sub-fix 1.2: Multi-Device Timestamp Check

**Problem**: Can't distinguish rename before vs after workout start

**Implementation**:

```dart
// SERVICE: lib/features/workout/domain/services/template_snapshot_validator.dart
class TemplateSnapshotValidator {
  /// Validates if template was modified during workout
  /// Returns validation result with recommended action
  Future<SnapshotValidationResult> validateSnapshot({
    required TemplateModificationSnapshot snapshot,
    required WorkoutTemplate currentTemplate,
  }) async {
    // Check 1: Name unchanged → VALID
    if (snapshot.snapshotName == currentTemplate.name) {
      return const SnapshotValidationResult.valid();
    }

    // Check 2: Name changed → compare timestamps
    final workoutStartTime = snapshot.snapshotTimestamp;
    final templateLastModified = currentTemplate.lastModified;

    // Scenario A: Template modified BEFORE workout start
    if (templateLastModified.isBefore(workoutStartTime)) {
      return SnapshotValidationResult.nameChangedBeforeWorkout(
        oldName: snapshot.snapshotName,
        newName: currentTemplate.name,
        recommendation: SnapshotRecommendation.useCurrent,
      );
    }

    // Scenario B: Template modified AFTER workout start (CONFLICT!)
    return SnapshotValidationResult.nameChangedDuringWorkout(
      oldName: snapshot.snapshotName,
      newName: currentTemplate.name,
      renameTimestamp: templateLastModified,
      workoutStartTimestamp: workoutStartTime,
      recommendation: SnapshotRecommendation.askUser,
    );
  }
}

@freezed
class SnapshotValidationResult with _$SnapshotValidationResult {
  const factory SnapshotValidationResult.valid() = _Valid;

  const factory SnapshotValidationResult.nameChangedBeforeWorkout({
    required String oldName,
    required String newName,
    required SnapshotRecommendation recommendation,
  }) = _NameChangedBeforeWorkout;

  const factory SnapshotValidationResult.nameChangedDuringWorkout({
    required String oldName,
    required String newName,
    required DateTime renameTimestamp,
    required DateTime workoutStartTimestamp,
    required SnapshotRecommendation recommendation,
  }) = _NameChangedDuringWorkout;
}

enum SnapshotRecommendation {
  useCurrent,   // Silently use current template name
  useSnapshot,  // Silently use snapshot name
  askUser,      // Show conflict dialog
}
```

**Usage in post-workout flow**:

```dart
Future<void> handlePostWorkoutSave() async {
  final snapshot = await getSnapshotWithFallback(workoutSessionId);
  if (snapshot == null) {
    // No snapshot → treat as new workout (not from template)
    return;
  }

  final currentTemplate = await ref
      .read(hybridTemplateRepositoryProvider)
      .getTemplateById(snapshot.templateId);

  if (currentTemplate == null) {
    // Template deleted during workout → show deleted dialog
    _showTemplateDeletedDialog();
    return;
  }

  // Validate snapshot
  final validation = await ref
      .read(templateSnapshotValidatorProvider)
      .validateSnapshot(
        snapshot: snapshot,
        currentTemplate: currentTemplate,
      );

  validation.when(
    valid: () {
      // No rename → proceed with preference
      _applySnapshotPreference(snapshot, currentTemplate);
    },
    nameChangedBeforeWorkout: (oldName, newName, rec) {
      // Renamed BEFORE workout → silently use current name
      debugPrint('📝 Template renamed before workout: $oldName → $newName');
      _applySnapshotPreference(snapshot, currentTemplate);
    },
    nameChangedDuringWorkout: (oldName, newName, renameTs, workoutTs, rec) {
      // Renamed DURING workout → CONFLICT!
      _showRenameConflictDialog(
        snapshot: snapshot,
        currentTemplate: currentTemplate,
        oldName: oldName,
        newName: newName,
      );
    },
  );
}
```

---

### Fix Issue 2: Ambiguous preserveFlags Parameter

**Problem**: `preserveFlags: true` doesn't specify what to preserve

**Solution**: Explicit enums for data preservation and timestamp behavior

#### Sub-fix 2.1: Separate TemplateUpdateBehavior from PreserveFlag

**Implementation**:

```dart
// DOMAIN: lib/features/workout/domain/entities/template_preserve_flag.dart

/// Fine-grained control over what data to preserve during template merge
enum TemplatePreserveFlag {
  /// ALWAYS preserve exercise order (critical for user intent)
  /// Example: User carefully ordered "Bench → Incline → Flies"
  exerciseOrder,

  /// Preserve custom exercise notes and instructions
  /// Example: "Use slow eccentric on last set"
  exerciseNotes,

  /// Preserve custom settings (rest timers, tags, difficulty)
  /// Example: Rest timer overrides, "heavy day" tag
  customSettings,

  /// Preserve exercise library reference (usually NOT wanted post-workout)
  /// Example: Keep wger.de exercise ID (rarely needed)
  exerciseLibraryRef,
}

/// Separate enum for timestamp update behavior
enum TemplateTimestampBehavior {
  /// Update lastModified to now (default for user edits)
  /// Use when: User explicitly saves/edits template
  refreshTimestamp,

  /// Keep original lastModified (silent sync, no user action)
  /// Use when: Background sync, migration, automatic cleanup
  preserveTimestamp,

  /// Reset both createdAt and lastModified to now (new template)
  /// Use when: "Save as new template" action
  resetTimestamps,
}

// USAGE: In HybridTemplateRepository
Future<void> updateTemplate(
  WorkoutTemplate template, {
  required Set<TemplatePreserveFlag> preserveFlags,
  required TemplateTimestampBehavior timestampBehavior,
}) async {
  // Build merged template based on preserve flags
  final updatedTemplate = _applyPreserveFlags(
    original: existingTemplate,
    update: template,
    preserveFlags: preserveFlags,
  );

  // Apply timestamp behavior
  final finalTemplate = timestampBehavior.when(
    refreshTimestamp: () => updatedTemplate.copyWith(
      lastModified: DateTime.now(),
    ),
    preserveTimestamp: () => updatedTemplate, // Keep as-is
    resetTimestamps: () => updatedTemplate.copyWith(
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    ),
  );

  await _saveTemplateLocally(finalTemplate);
}

WorkoutTemplate _applyPreserveFlags(
  WorkoutTemplate original,
  WorkoutTemplate update,
  Set<TemplatePreserveFlag> preserveFlags,
) {
  return WorkoutTemplate(
    id: original.id, // Always keep ID
    name: update.name, // Always use new name

    // Exercise order: preserve if flag set, otherwise use update
    exercises: preserveFlags.contains(TemplatePreserveFlag.exerciseOrder)
        ? original.exercises
        : update.exercises,

    // Exercise notes: merge if flag set
    // (keep original notes, add new notes for new exercises)
    exerciseNotes: preserveFlags.contains(TemplatePreserveFlag.exerciseNotes)
        ? _mergeExerciseNotes(original.exerciseNotes, update.exerciseNotes)
        : update.exerciseNotes,

    // Custom settings: preserve if flag set
    restTimers: preserveFlags.contains(TemplatePreserveFlag.customSettings)
        ? original.restTimers
        : update.restTimers,
    tags: preserveFlags.contains(TemplatePreserveFlag.customSettings)
        ? original.tags
        : update.tags,

    // Library ref: preserve if flag set (rarely needed)
    wgerId: preserveFlags.contains(TemplatePreserveFlag.exerciseLibraryRef)
        ? original.wgerId
        : update.wgerId,

    // Always update performance data (weights, reps)
    // This is the PRIMARY use case for post-workout save
    exerciseData: update.exerciseData,
  );
}
```

**Standard usage patterns**:

```dart
// Pattern 1: Post-workout save (overwrite weights/reps)
await updateTemplate(
  completedWorkout,
  preserveFlags: {
    TemplatePreserveFlag.exerciseOrder,    // Keep original order
    TemplatePreserveFlag.exerciseNotes,    // Keep instructions
    TemplatePreserveFlag.customSettings,   // Keep rest timers
  },
  timestampBehavior: TemplateTimestampBehavior.refreshTimestamp,
);

// Pattern 2: Save as new template
await createTemplate(
  completedWorkout,
  // No preserve flags (all new data)
  timestampBehavior: TemplateTimestampBehavior.resetTimestamps,
);

// Pattern 3: Background sync (silent)
await updateTemplate(
  cloudTemplate,
  preserveFlags: {},  // Overwrite everything
  timestampBehavior: TemplateTimestampBehavior.preserveTimestamp,
);
```

#### Sub-fix 2.2: FuzzySearchCache Isolate Invalidation

**Problem**: Main thread invalidates cache but background isolate continues serving stale data

**Implementation**:

```dart
// SERVICE: lib/features/exercise_database/domain/services/fuzzy_search_isolate_manager.dart

/// Message protocol for main thread ↔ isolate communication
@freezed
class FuzzySearchMessage with _$FuzzySearchMessage {
  const factory FuzzySearchMessage.invalidateCache({
    required String templateId,
    required DateTime timestamp,
  }) = _InvalidateCache;

  const factory FuzzySearchMessage.invalidateAll({
    required DateTime timestamp,
  }) = _InvalidateAll;

  const factory FuzzySearchMessage.shutdown() = _Shutdown;
}

class FuzzySearchIsolateManager {
  SendPort? _sendPort;
  Isolate? _isolate;

  /// Initialize isolate with two-way communication
  Future<void> initialize() async {
    final receivePort = ReceivePort();

    _isolate = await Isolate.spawn(
      _fuzzySearchIsolateEntryPoint,
      receivePort.sendPort,
    );

    // Wait for isolate to send back its SendPort
    _sendPort = await receivePort.first as SendPort;

    debugPrint('✅ FuzzySearch isolate initialized');
  }

  /// Notify isolate to invalidate cache for specific template
  Future<void> invalidateCache(String templateId) async {
    if (_sendPort == null) {
      debugPrint('⚠️ Isolate not initialized, skipping cache invalidation');
      return;
    }

    final message = FuzzySearchMessage.invalidateCache(
      templateId: templateId,
      timestamp: DateTime.now(),
    );

    _sendPort!.send(message);
    debugPrint('📤 Sent cache invalidation to isolate: $templateId');
  }

  /// Invalidate entire cache (used on bulk operations)
  Future<void> invalidateAllCache() async {
    if (_sendPort == null) return;

    final message = FuzzySearchMessage.invalidateAll(
      timestamp: DateTime.now(),
    );

    _sendPort!.send(message);
    debugPrint('📤 Sent INVALIDATE ALL to isolate');
  }

  /// Shutdown isolate (called on app dispose)
  Future<void> shutdown() async {
    if (_sendPort == null) return;

    _sendPort!.send(const FuzzySearchMessage.shutdown());
    _isolate?.kill();

    debugPrint('🛑 FuzzySearch isolate shutdown');
  }

  /// Isolate entry point (runs in background)
  static void _fuzzySearchIsolateEntryPoint(SendPort mainSendPort) {
    final isolateReceivePort = ReceivePort();

    // Send back SendPort to main thread
    mainSendPort.send(isolateReceivePort.sendPort);

    // Local cache in isolate
    final Map<String, List<Exercise>> _cache = {};

    // Listen for messages from main thread
    isolateReceivePort.listen((message) {
      if (message is! FuzzySearchMessage) return;

      message.when(
        invalidateCache: (templateId, timestamp) {
          _cache.remove(templateId);
          debugPrint('🗑️ [Isolate] Cache invalidated: $templateId');
        },
        invalidateAll: (timestamp) {
          _cache.clear();
          debugPrint('🗑️ [Isolate] All cache cleared');
        },
        shutdown: () {
          isolateReceivePort.close();
          debugPrint('🛑 [Isolate] Shutdown received');
        },
      );
    });
  }
}

// PROVIDER
final fuzzySearchIsolateManagerProvider = Provider<FuzzySearchIsolateManager>((ref) {
  final manager = FuzzySearchIsolateManager();

  // Initialize on first access
  manager.initialize();

  // Cleanup on dispose
  ref.onDispose(() {
    manager.shutdown();
  });

  return manager;
});
```

**Invalidation workflow**:

```dart
// When template is updated:
Future<void> updateTemplateWithCacheSync(WorkoutTemplate template) async {
  // 1. Save to local Hive
  await ref.read(hybridTemplateRepositoryProvider).updateTemplate(template);

  // 2. Invalidate main thread cache
  await _invalidateFuzzySearchCacheMainThread(template.id);

  // 3. Notify background isolate
  await ref
      .read(fuzzySearchIsolateManagerProvider)
      .invalidateCache(template.id);

  debugPrint('✅ Cache invalidated: main + isolate');
}
```

---

### Fix Issue 3: Undo + Background Sync Ghost State

**Problem**: Background sync can complete before undo, causing cloud to overwrite local undo

**Solution**: Transaction lock system with rollback snapshots

**Implementation**:

```dart
// ENTITY: lib/features/workout/domain/entities/template_transaction_lock.dart
@freezed
class TemplateTransactionLock with _$TemplateTransactionLock {
  const factory TemplateTransactionLock({
    required String lockId,
    required String templateId,
    required TemplateLockType lockType,
    required DateTime acquiredAt,
    required DateTime expiresAt,
    WorkoutTemplate? rollbackSnapshot, // For undo functionality
  }) = _TemplateTransactionLock;

  factory TemplateTransactionLock.fromJson(Map<String, dynamic> json) =>
      _$TemplateTransactionLockFromJson(json);
}

enum TemplateLockType {
  undoWindow,      // 15s undo period after save
  manualEdit,      // User actively editing template
  backgroundSync,  // Background sync in progress
}

// REPOSITORY: lib/features/workout/data/repositories/template_transaction_lock_repository.dart
class TemplateTransactionLockRepository {
  final Box<Map> _lockBox;

  TemplateTransactionLockRepository(this._lockBox);

  /// Acquire lock for template (fails if already locked)
  Future<TemplateTransactionLock?> acquireLock({
    required String templateId,
    required TemplateLockType lockType,
    required Duration duration,
    WorkoutTemplate? rollbackSnapshot,
  }) async {
    // Check if already locked
    if (await isLocked(templateId)) {
      debugPrint('⚠️ Template already locked: $templateId');
      return null;
    }

    final lock = TemplateTransactionLock(
      lockId: const Uuid().v4(),
      templateId: templateId,
      lockType: lockType,
      acquiredAt: DateTime.now(),
      expiresAt: DateTime.now().add(duration),
      rollbackSnapshot: rollbackSnapshot,
    );

    await _lockBox.put(templateId, lock.toJson());

    debugPrint('🔒 Lock acquired: $templateId (${lockType.name}, ${duration.inSeconds}s)');

    return lock;
  }

  /// Check if template is currently locked
  Future<bool> isLocked(String templateId) async {
    final data = _lockBox.get(templateId);
    if (data == null) return false;

    final lock = TemplateTransactionLock.fromJson(
      Map<String, dynamic>.from(data),
    );

    // Check if expired
    if (DateTime.now().isAfter(lock.expiresAt)) {
      await _lockBox.delete(templateId);
      debugPrint('🔓 Lock expired (auto-released): $templateId');
      return false;
    }

    return true;
  }

  /// Get current lock (returns null if not locked or expired)
  Future<TemplateTransactionLock?> getLock(String templateId) async {
    if (!await isLocked(templateId)) return null;

    final data = _lockBox.get(templateId);
    return TemplateTransactionLock.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  /// Release lock manually
  Future<void> releaseLock(String templateId) async {
    await _lockBox.delete(templateId);
    debugPrint('🔓 Lock released: $templateId');
  }

  /// Cleanup orphaned locks (app killed during lock period)
  Future<void> cleanupOrphanedLocks() async {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final key in _lockBox.keys) {
      final data = _lockBox.get(key);
      if (data == null) continue;

      final lock = TemplateTransactionLock.fromJson(
        Map<String, dynamic>.from(data),
      );

      if (now.isAfter(lock.expiresAt)) {
        expiredKeys.add(key);
      }
    }

    await _lockBox.deleteAll(expiredKeys);
    debugPrint('🧹 Cleaned up ${expiredKeys.length} orphaned locks');
  }
}

// PROVIDER
final templateTransactionLockRepositoryProvider =
    Provider<TemplateTransactionLockRepository>((ref) {
  final box = Hive.box<Map>('template_transaction_locks');
  return TemplateTransactionLockRepository(box);
});
```

**Usage in save workflow**:

```dart
Future<void> saveTemplateWithUndo(WorkoutTemplate template) async {
  final lockRepo = ref.read(templateTransactionLockRepositoryProvider);

  // Get original template for rollback
  final original = await ref
      .read(hybridTemplateRepositoryProvider)
      .getTemplateById(template.id);

  // 1. Acquire lock with rollback snapshot
  final lock = await lockRepo.acquireLock(
    templateId: template.id,
    lockType: TemplateLockType.undoWindow,
    duration: const Duration(seconds: 15),
    rollbackSnapshot: original, // Store for undo
  );

  if (lock == null) {
    SnackBarService.showError(
      context,
      'Template occupato, riprova tra poco',
    );
    return;
  }

  // 2. Save template locally
  await ref
      .read(hybridTemplateRepositoryProvider)
      .updateTemplate(template);

  // 3. Invalidate caches
  await _invalidateCaches(template.id);

  // 4. Show undo toast
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(context.l10n.templateUpdated),
      duration: const Duration(seconds: 15),
      action: SnackBarAction(
        label: context.l10n.undo,
        onPressed: () async {
          await _handleUndo(lock);
        },
      ),
    ),
  );

  // 5. Background sync will check lock before proceeding
  _scheduleBackgroundSync(template);

  // 6. Auto-release lock after 15s
  Future.delayed(const Duration(seconds: 15), () async {
    await lockRepo.releaseLock(template.id);
    debugPrint('🔓 Undo window expired, lock released');
  });
}

Future<void> _handleUndo(TemplateTransactionLock lock) async {
  if (lock.rollbackSnapshot == null) {
    debugPrint('❌ No rollback snapshot available');
    return;
  }

  // Restore original template
  await ref
      .read(hybridTemplateRepositoryProvider)
      .updateTemplate(
        lock.rollbackSnapshot!,
        preserveFlags: {},
        timestampBehavior: TemplateTimestampBehavior.preserveTimestamp,
      );

  // Release lock
  await ref
      .read(templateTransactionLockRepositoryProvider)
      .releaseLock(lock.templateId);

  // Invalidate caches
  await _invalidateCaches(lock.templateId);

  SnackBarService.showSuccess(context, context.l10n.changesCancelled);

  debugPrint('⏮️ Undo completed, template restored');
}
```

**Background sync lock check**:

```dart
Future<void> _backgroundSyncToCloud(WorkoutTemplate template) async {
  final lockRepo = ref.read(templateTransactionLockRepositoryProvider);

  // Check if template is locked
  if (await lockRepo.isLocked(template.id)) {
    final lock = await lockRepo.getLock(template.id);

    debugPrint('🔒 Template locked (${lock?.lockType.name}), deferring sync');

    // Add to sync queue for retry after lock expires
    await _addToSyncQueue(template);

    return;
  }

  // Proceed with sync
  await _syncTemplateToFirebase(template);
}
```

---

## 🎨 Component Design

### 1. Core Entities

#### TemplateModificationSnapshot

**File**: `lib/features/workout/domain/entities/template_modification_snapshot.dart`

```dart
@freezed
class TemplateModificationSnapshot with _$TemplateModificationSnapshot {
  const factory TemplateModificationSnapshot({
    required String templateId,
    required String snapshotName,        // Frozen at workout start
    required DateTime snapshotTimestamp, // When snapshot was taken
    required TemplateSavePreference userPreference, // Global default
  }) = _TemplateModificationSnapshot;

  factory TemplateModificationSnapshot.fromJson(Map<String, dynamic> json) =>
      _$TemplateModificationSnapshotFromJson(json);
}

enum TemplateSavePreference {
  askAlways,        // Show dialog every time
  alwaysOverwrite,  // Silently overwrite weights/reps
  alwaysNew,        // Always create new template
  neverSave,        // Skip template save completely
}
```

#### WorkoutSnapshotCache

**File**: `lib/features/workout/domain/entities/workout_snapshot_cache.dart`

```dart
@freezed
class WorkoutSnapshotCache with _$WorkoutSnapshotCache {
  const factory WorkoutSnapshotCache({
    required String workoutSessionId,
    required TemplateModificationSnapshot snapshot,
    required DateTime createdAt,
  }) = _WorkoutSnapshotCache;

  factory WorkoutSnapshotCache.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSnapshotCacheFromJson(json);
}
```

#### TemplateTransactionLock

**File**: `lib/features/workout/domain/entities/template_transaction_lock.dart`

(Already defined in Fix Issue 3 section)

---

### 2. Repositories

#### SnapshotCacheRepository

**File**: `lib/features/workout/data/repositories/snapshot_cache_repository.dart`

(Already defined in Sub-fix 1.1 section)

#### TemplateTransactionLockRepository

**File**: `lib/features/workout/data/repositories/template_transaction_lock_repository.dart`

(Already defined in Fix Issue 3 section)

#### Enhanced HybridTemplateRepository

**File**: `lib/features/workout_templates/data/repositories/hybrid_template_repository.dart` (modify existing)

**New methods to add**:

```dart
class HybridTemplateRepository {
  // ... existing code ...

  /// Update template with fine-grained preserve flags
  Future<void> updateTemplate(
    WorkoutTemplate template, {
    required Set<TemplatePreserveFlag> preserveFlags,
    required TemplateTimestampBehavior timestampBehavior,
  }) async {
    final existing = await getTemplateById(template.id);
    if (existing == null) {
      throw Exception('Template not found: ${template.id}');
    }

    // Apply preserve flags
    final merged = _applyPreserveFlags(
      original: existing,
      update: template,
      preserveFlags: preserveFlags,
    );

    // Apply timestamp behavior
    final final = _applyTimestampBehavior(merged, timestampBehavior);

    // Save locally (instant)
    await _saveTemplateLocally(finalTemplate);

    // Invalidate caches
    await _invalidateCaches(template.id);

    // Background sync (if premium & not locked)
    _scheduleBackgroundSync(finalTemplate);
  }

  /// Generate smart name for new template (handles duplicates)
  Future<String> generateUniqueTemplateName(String baseName) async {
    final existing = await getUserTemplates();
    final names = existing.map((t) => t.name).toSet();

    if (!names.contains(baseName)) {
      return baseName; // Original name available
    }

    // Generate suggestions
    final suggestions = await ref
        .read(templateNameConflictServiceProvider)
        .generateSmartSuggestions(baseName);

    // Return first available suggestion
    for (final suggestion in suggestions) {
      if (!names.contains(suggestion)) {
        return suggestion;
      }
    }

    // Fallback: append UUID suffix
    return '$baseName - ${const Uuid().v4().substring(0, 8)}';
  }
}
```

---

### 3. Services

#### TemplateNameConflictService

**File**: `lib/features/workout/domain/services/template_name_conflict_service.dart`

```dart
class TemplateNameConflictService {
  final HybridTemplateRepository _templateRepo;

  TemplateNameConflictService(this._templateRepo);

  /// Generate smart name suggestions for duplicate names
  Future<List<String>> generateSmartSuggestions(String baseName) async {
    final suggestions = <String>[];

    // Suggestion 1: Date suffix - "Push Day A - 22/01"
    final dateFormat = DateFormat('dd/MM');
    final dateStr = dateFormat.format(DateTime.now());
    suggestions.add('$baseName - $dateStr');

    // Suggestion 2: Version increment - "Push Day A - v2"
    final versionMatch = RegExp(r'- v(\d+)$').firstMatch(baseName);
    if (versionMatch != null) {
      final currentVersion = int.parse(versionMatch.group(1)!);
      final newVersion = currentVersion + 1;
      final baseWithoutVersion = baseName.replaceAll(versionMatch.group(0)!, '');
      suggestions.add('$baseWithoutVersion - v$newVersion');
    } else {
      suggestions.add('$baseName - v2');
    }

    // Suggestion 3: Contextual - "Push Day A - Lunedì"
    final weekdayFormat = DateFormat('EEEE', 'it_IT');
    final weekday = weekdayFormat.format(DateTime.now());
    suggestions.add('$baseName - $weekday');

    // Suggestion 4: Time-based - "Push Day A - Mattina"
    final hour = DateTime.now().hour;
    String timeOfDay;
    if (hour < 12) {
      timeOfDay = 'Mattina';
    } else if (hour < 18) {
      timeOfDay = 'Pomeriggio';
    } else {
      timeOfDay = 'Sera';
    }
    suggestions.add('$baseName - $timeOfDay');

    return suggestions;
  }

  /// Check if name conflicts with existing templates
  Future<bool> hasNameConflict(String name) async {
    final existing = await _templateRepo.getUserTemplates();
    return existing.any((t) => t.name == name);
  }

  /// Detect if name is a variant of base name
  bool isNameVariant(String name, String baseName) {
    // Remove common suffixes
    final normalized = name
        .replaceAll(RegExp(r' - \d{2}/\d{2}$'), '')
        .replaceAll(RegExp(r' - v\d+$'), '')
        .replaceAll(RegExp(r' - (Lunedì|Martedì|Mercoledì|Giovedì|Venerdì|Sabato|Domenica)$'), '')
        .replaceAll(RegExp(r' - (Mattina|Pomeriggio|Sera)$'), '');

    return normalized == baseName;
  }
}

// PROVIDER
final templateNameConflictServiceProvider = Provider<TemplateNameConflictService>((ref) {
  final repo = ref.watch(hybridTemplateRepositoryProvider);
  return TemplateNameConflictService(repo);
});
```

#### TemplateSnapshotValidator

**File**: `lib/features/workout/domain/services/template_snapshot_validator.dart`

(Already defined in Sub-fix 1.2 section)

#### FuzzySearchIsolateManager

**File**: `lib/features/exercise_database/domain/services/fuzzy_search_isolate_manager.dart`

(Already defined in Sub-fix 2.2 section)

---

### 4. UI Components

#### PostWorkoutTemplateDialog

**File**: `lib/features/workout/presentation/widgets/post_workout_template_dialog.dart`

```dart
class PostWorkoutTemplateDialog extends ConsumerStatefulWidget {
  final WorkoutTemplate completedWorkout;
  final TemplateModificationSnapshot snapshot;

  const PostWorkoutTemplateDialog({
    super.key,
    required this.completedWorkout,
    required this.snapshot,
  });

  @override
  ConsumerState<PostWorkoutTemplateDialog> createState() =>
      _PostWorkoutTemplateDialogState();
}

class _PostWorkoutTemplateDialogState
    extends ConsumerState<PostWorkoutTemplateDialog> {
  bool _rememberChoice = false;

  @override
  Widget build(BuildContext context) {
    // Get quota info
    final quota = ref.watch(templateQuotaProvider);

    return AlertDialog(
      title: Row(
        children: [
          const SemanticIcon(
            icon: AppIcons.checkCircle,
            semanticLabel: 'Success',
            size: AppIconSize.large,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.congratsWorkoutSaved,
              style: context.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.whatWouldYouLikeToDo,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Option 1: Overwrite weights/reps (RECOMMENDED)
            _OptionCard(
              icon: AppIcons.update,
              iconColor: context.iconPrimary,
              title: context.l10n.overwriteWeightsReps,
              subtitle: context.l10n.overwriteWeightsRepsSubtitle,
              badge: context.l10n.recommended,
              onTap: () => _handleOverwrite(),
            ),
            const SizedBox(height: 12),

            // Option 2: Save as new template
            _OptionCard(
              icon: AppIcons.addCircle,
              iconColor: context.iconSecondary,
              title: context.l10n.saveAsNewTemplate,
              subtitle: context.l10n.saveAsNewTemplateSubtitle(
                quota.remaining,
                quota.max,
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: quota.remaining <= 2
                      ? context.warningContainer
                      : context.colors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${quota.remaining}/${quota.max}',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: quota.remaining <= 2
                        ? context.warningColor
                        : context.colors.primary,
                  ),
                ),
              ),
              onTap: () => _handleSaveAsNew(),
              enabled: quota.remaining > 0,
            ),
            const SizedBox(height: 12),

            // Option 3: Continue without saving
            _OptionCard(
              icon: AppIcons.arrowForward,
              iconColor: context.iconTertiary,
              title: context.l10n.continueWithoutSaving,
              subtitle: context.l10n.continueWithoutSavingSubtitle,
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 20),

            // Remember choice checkbox
            CheckboxListTile(
              value: _rememberChoice,
              onChanged: (value) {
                setState(() {
                  _rememberChoice = value ?? false;
                });

                if (value == true) {
                  HapticFeedback.selectionClick();
                }
              },
              title: Text(
                context.l10n.rememberMyChoice,
                style: context.textTheme.bodyMedium,
              ),
              subtitle: Text(
                context.l10n.rememberMyChoiceSubtitle,
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOverwrite() async {
    if (_rememberChoice) {
      await _savePreference(TemplateSavePreference.alwaysOverwrite);
    }

    Navigator.of(context).pop();

    await ref.read(templateSaveServiceProvider).overwriteTemplate(
      widget.completedWorkout,
      snapshot: widget.snapshot,
    );
  }

  Future<void> _handleSaveAsNew() async {
    if (_rememberChoice) {
      await _savePreference(TemplateSavePreference.alwaysNew);
    }

    Navigator.of(context).pop();

    // Show name input dialog
    await showDialog(
      context: context,
      builder: (context) => TemplateNameInputDialog(
        workout: widget.completedWorkout,
        baseName: widget.snapshot.snapshotName,
      ),
    );
  }

  Future<void> _savePreference(TemplateSavePreference pref) async {
    await ref
        .read(templatePreferencesRepositoryProvider)
        .setGlobalPreference(pref);

    SnackBarService.showCustom(
      context,
      message: context.l10n.preferencesSaved,
      backgroundColor: context.successColor,
      actionLabel: context.l10n.reset,
      onAction: () async {
        await ref
            .read(templatePreferencesRepositoryProvider)
            .resetGlobalPreference();
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool enabled;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.trailing,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled
              ? context.colors.surfaceContainerHighest
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            SemanticIcon(
              icon: icon,
              semanticLabel: title,
              size: AppIconSize.large,
              color: enabled ? iconColor : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: enabled
                                ? context.colors.onSurface
                                : context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
```

#### TemplateNameConflictDialog

**File**: `lib/features/workout/presentation/widgets/template_name_conflict_dialog.dart`

```dart
class TemplateNameConflictDialog extends ConsumerStatefulWidget {
  final TemplateModificationSnapshot snapshot;
  final WorkoutTemplate currentTemplate;
  final String oldName;
  final String newName;

  const TemplateNameConflictDialog({
    super.key,
    required this.snapshot,
    required this.currentTemplate,
    required this.oldName,
    required this.newName,
  });

  @override
  ConsumerState<TemplateNameConflictDialog> createState() =>
      _TemplateNameConflictDialogState();
}

class _TemplateNameConflictDialogState
    extends ConsumerState<TemplateNameConflictDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const SemanticIcon(
            icon: AppIcons.warning,
            semanticLabel: 'Warning',
            size: AppIconSize.large,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.templateRenamedDuringWorkout,
              style: context.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.templateRenamedDuringWorkoutDescription,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Old name (snapshot)
            _NameComparisonRow(
              label: context.l10n.nameAtWorkoutStart,
              name: widget.oldName,
              icon: AppIcons.history,
              iconColor: context.iconSecondary,
            ),
            const SizedBox(height: 12),

            // Arrow down
            Center(
              child: SemanticIcon(
                icon: AppIcons.arrowDownward,
                semanticLabel: 'Changed to',
                size: AppIconSize.medium,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // New name (current)
            _NameComparisonRow(
              label: context.l10n.currentTemplateName,
              name: widget.newName,
              icon: AppIcons.edit,
              iconColor: context.iconPrimary,
            ),
            const SizedBox(height: 20),

            Text(
              context.l10n.whichNameWouldYouLikeToUse,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _handleKeepNewName(),
          child: Text(context.l10n.keepNewName(widget.newName)),
        ),
        FilledButton(
          onPressed: () => _handleRestoreOldName(),
          child: Text(context.l10n.restoreOldName(widget.oldName)),
        ),
      ],
    );
  }

  Future<void> _handleKeepNewName() async {
    Navigator.of(context).pop();

    // Proceed with current template name
    await ref.read(templateSaveServiceProvider).applySnapshotPreference(
      widget.snapshot,
      widget.currentTemplate,
    );
  }

  Future<void> _handleRestoreOldName() async {
    Navigator.of(context).pop();

    // Restore snapshot name first
    final restoredTemplate = widget.currentTemplate.copyWith(
      name: widget.oldName,
    );

    await ref.read(hybridTemplateRepositoryProvider).updateTemplate(
      restoredTemplate,
      preserveFlags: {TemplatePreserveFlag.exerciseOrder},
      timestampBehavior: TemplateTimestampBehavior.refreshTimestamp,
    );

    // Then proceed with preference
    await ref.read(templateSaveServiceProvider).applySnapshotPreference(
      widget.snapshot,
      restoredTemplate,
    );
  }
}

class _NameComparisonRow extends StatelessWidget {
  final String label;
  final String name;
  final IconData icon;
  final Color iconColor;

  const _NameComparisonRow({
    required this.label,
    required this.name,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: label,
            size: AppIconSize.medium,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### TemplatePreferencesSettingsScreen

**File**: `lib/features/settings/presentation/screens/template_preferences_settings_screen.dart`

```dart
class TemplatePreferencesSettingsScreen extends ConsumerStatefulWidget {
  const TemplatePreferencesSettingsScreen({super.key});

  @override
  ConsumerState<TemplatePreferencesSettingsScreen> createState() =>
      _TemplatePreferencesSettingsScreenState();
}

class _TemplatePreferencesSettingsScreenState
    extends ConsumerState<TemplatePreferencesSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(templatePreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.templateSavePreferences),
        actions: [
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.help,
              semanticLabel: 'Help',
            ),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: prefsAsync.when(
        data: (prefs) => _buildContent(prefs),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Text(context.l10n.errorLoadingPreferences(error.toString())),
        ),
      ),
    );
  }

  Widget _buildContent(TemplatePreferences prefs) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Global preference section
        _SectionHeader(
          icon: AppIcons.settings,
          title: context.l10n.globalPreference,
          subtitle: context.l10n.globalPreferenceSubtitle,
        ),
        const SizedBox(height: 12),

        _PreferenceRadioTile(
          value: TemplateSavePreference.askAlways,
          groupValue: prefs.globalPreference,
          title: context.l10n.askAlways,
          subtitle: context.l10n.askAlwaysSubtitle,
          icon: AppIcons.helpOutline,
          onChanged: (value) => _updateGlobalPreference(value!),
        ),

        _PreferenceRadioTile(
          value: TemplateSavePreference.alwaysOverwrite,
          groupValue: prefs.globalPreference,
          title: context.l10n.alwaysOverwrite,
          subtitle: context.l10n.alwaysOverwriteSubtitle,
          icon: AppIcons.update,
          onChanged: (value) => _updateGlobalPreference(value!),
        ),

        _PreferenceRadioTile(
          value: TemplateSavePreference.alwaysNew,
          groupValue: prefs.globalPreference,
          title: context.l10n.alwaysCreateNew,
          subtitle: context.l10n.alwaysCreateNewSubtitle,
          icon: AppIcons.addCircle,
          onChanged: (value) => _updateGlobalPreference(value!),
        ),

        _PreferenceRadioTile(
          value: TemplateSavePreference.neverSave,
          groupValue: prefs.globalPreference,
          title: context.l10n.neverSave,
          subtitle: context.l10n.neverSaveSubtitle,
          icon: AppIcons.blockRounded,
          onChanged: (value) => _updateGlobalPreference(value!),
        ),

        const SizedBox(height: 32),

        // Template-specific overrides section
        if (prefs.templateSpecificOverrides.isNotEmpty) ...[
          _SectionHeader(
            icon: AppIcons.template,
            title: context.l10n.templateSpecificOverrides,
            subtitle: context.l10n.templateSpecificOverridesSubtitle,
          ),
          const SizedBox(height: 12),

          ...prefs.templateSpecificOverrides.entries.map((entry) {
            return FutureBuilder<WorkoutTemplate?>(
              future: ref
                  .read(hybridTemplateRepositoryProvider)
                  .getTemplateById(entry.key),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final template = snapshot.data!;

                return _TemplateOverrideTile(
                  template: template,
                  preference: entry.value,
                  onRemove: () => _removeOverride(entry.key),
                );
              },
            );
          }).toList(),

          const SizedBox(height: 16),
        ],

        // Reset all button
        FilledButton.icon(
          onPressed: () => _resetAllPreferences(),
          icon: const SemanticIcon(
            icon: AppIcons.refresh,
            semanticLabel: 'Reset',
          ),
          label: Text(context.l10n.resetAllPreferences),
          style: FilledButton.styleFrom(
            backgroundColor: context.warningColor,
          ),
        ),
      ],
    );
  }

  Future<void> _updateGlobalPreference(TemplateSavePreference pref) async {
    await ref
        .read(templatePreferencesRepositoryProvider)
        .setGlobalPreference(pref);

    HapticFeedback.selectionClick();

    SnackBarService.showSuccess(
      context,
      context.l10n.preferenceSaved,
    );
  }

  Future<void> _removeOverride(String templateId) async {
    await ref
        .read(templatePreferencesRepositoryProvider)
        .removeTemplateOverride(templateId);

    HapticFeedback.mediumImpact();

    SnackBarService.showSuccess(
      context,
      context.l10n.overrideRemoved,
    );
  }

  Future<void> _resetAllPreferences() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmReset),
        content: Text(context.l10n.confirmResetDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.warningColor,
            ),
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(templatePreferencesRepositoryProvider)
        .resetAllPreferences();

    HapticFeedback.heavyImpact();

    SnackBarService.showSuccess(
      context,
      context.l10n.preferencesReset,
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const SemanticIcon(
              icon: AppIcons.help,
              semanticLabel: 'Help',
              size: AppIconSize.large,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(context.l10n.howItWorks),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            context.l10n.templatePreferencesHelpText,
            style: context.textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.gotIt),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: title,
          size: AppIconSize.medium,
          color: context.iconPrimary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceRadioTile extends StatelessWidget {
  final TemplateSavePreference value;
  final TemplateSavePreference groupValue;
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged<TemplateSavePreference?> onChanged;

  const _PreferenceRadioTile({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return RadioListTile<TemplateSavePreference>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Row(
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: title,
            size: AppIconSize.small,
            color: isSelected
                ? context.iconPrimary
                : context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: 12,
        ),
      ),
      dense: true,
    );
  }
}

class _TemplateOverrideTile extends StatelessWidget {
  final WorkoutTemplate template;
  final TemplateSavePreference preference;
  final VoidCallback onRemove;

  const _TemplateOverrideTile({
    required this.template,
    required this.preference,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.template,
            semanticLabel: template.name,
            size: AppIconSize.medium,
            color: context.iconSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  _getPreferenceName(context, preference),
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.delete,
              semanticLabel: 'Remove',
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  String _getPreferenceName(BuildContext context, TemplateSavePreference pref) {
    switch (pref) {
      case TemplateSavePreference.askAlways:
        return context.l10n.askAlways;
      case TemplateSavePreference.alwaysOverwrite:
        return context.l10n.alwaysOverwrite;
      case TemplateSavePreference.alwaysNew:
        return context.l10n.alwaysCreateNew;
      case TemplateSavePreference.neverSave:
        return context.l10n.neverSave;
    }
  }
}
```

---

## 📊 UX Flow Diagrams

### Post-Workout Save Flow

```
User completes workout from template
         ↓
Retrieve snapshot (provider → fallback Hive cache)
         ↓
    ┌────┴─────┐
 Found      Not found
    │            │
    │            └─→ Treat as new workout → Skip save flow
    │
    ↓
Get current template by snapshot.templateId
         ↓
    ┌────┴─────┐
 Found      Deleted
    │            │
    │            └─→ Show "Template deleted" dialog → Offer "Save as new"
    │
    ↓
Validate snapshot (name check + timestamp comparison)
         ↓
    ┌────┴──────────┬──────────────┐
 Valid    Renamed BEFORE  Renamed DURING
    │         workout         workout
    │            │                │
    │            │                └─→ Show TemplateNameConflictDialog
    │            │                    ├─→ Keep new name → continue
    │            │                    └─→ Restore old name → rename + continue
    │            │
    │            └─→ Use current name silently → continue
    │
    ↓
Check user preference (global or template-specific)
         ↓
    ┌────┴──────────┬──────────────┬──────────┐
askAlways   alwaysOverwrite  alwaysNew   neverSave
    │            │                │            │
    │            │                │            └─→ Skip save silently
    │            │                │
    │            │                └─→ Generate unique name
    │            │                    Show TemplateNameInputDialog
    │            │                    Create new template
    │            │                    Show success toast
    │            │
    │            └─→ Acquire transaction lock (15s)
    │                Update template (preserve flags)
    │                Invalidate caches (main + isolate)
    │                Show undo toast (15s)
    │                Background sync (if not locked)
    │
    ↓
Show PostWorkoutTemplateDialog
    ├─→ Option 1: Overwrite → (same as alwaysOverwrite above)
    ├─→ Option 2: Save as new → (same as alwaysNew above)
    └─→ Option 3: Continue → Skip save

    If "Remember my choice" checked:
    → Save preference (global or template-specific)
    → Show toast with "Reset" action
```

### Settings Reset Flow

```
User opens TemplatePreferencesSettingsScreen
         ↓
Display current preferences:
- Global preference (radio buttons)
- Template-specific overrides (list)
         ↓
User clicks "Reset All Preferences"
         ↓
Show confirmation dialog:
"This will reset global preference to 'Ask always'
 and remove all template-specific overrides."
         ↓
    ┌────┴────┐
 Cancel    Confirm
    │           │
    │           ├─→ Reset global → askAlways
    │           ├─→ Clear all template overrides
    │           ├─→ HapticFeedback.heavyImpact()
    │           └─→ Show success toast
    │
    └─→ Close dialog
```

---

## 🧪 Implementation Plan

### Phase 1: Core Entities & Repositories (Est. 3-4h)

**Tasks:**

1. **Create TemplateModificationSnapshot entity** (~30 min)
   - File: `lib/features/workout/domain/entities/template_modification_snapshot.dart`
   - Add freezed + json_serializable
   - Define TemplateSavePreference enum

2. **Create WorkoutSnapshotCache entity** (~20 min)
   - File: `lib/features/workout/domain/entities/workout_snapshot_cache.dart`
   - Add freezed + json_serializable

3. **Create TemplateTransactionLock entity** (~30 min)
   - File: `lib/features/workout/domain/entities/template_transaction_lock.dart`
   - Add TemplateLockType enum
   - Add freezed + json_serializable

4. **Create TemplatePreserveFlag & TemplateTimestampBehavior enums** (~20 min)
   - File: `lib/features/workout/domain/entities/template_preserve_flag.dart`

5. **Implement SnapshotCacheRepository** (~45 min)
   - File: `lib/features/workout/data/repositories/snapshot_cache_repository.dart`
   - Hive integration
   - Cleanup method for old snapshots
   - Provider setup

6. **Implement TemplateTransactionLockRepository** (~1h)
   - File: `lib/features/workout/data/repositories/template_transaction_lock_repository.dart`
   - Hive integration
   - Lock acquisition/release logic
   - Expiry checks
   - Cleanup method for orphaned locks
   - Provider setup

7. **Run code generation** (~5 min)
   - `flutter pub run build_runner build --delete-conflicting-outputs`

**Verification:**
- [ ] All entities compile without errors
- [ ] Freezed code generated successfully
- [ ] Hive boxes initialized correctly
- [ ] `flutter analyze` passes

---

### Phase 2: Services & Business Logic (Est. 4-5h)

**Tasks:**

8. **Implement TemplateSnapshotValidator** (~1h)
   - File: `lib/features/workout/domain/services/template_snapshot_validator.dart`
   - Snapshot validation logic
   - Timestamp comparison
   - SnapshotValidationResult sealed class
   - Unit tests for edge cases

9. **Implement TemplateNameConflictService** (~1.5h)
   - File: `lib/features/workout/domain/services/template_name_conflict_service.dart`
   - Smart name suggestion algorithm
   - Date, version, contextual suffixes
   - Duplicate detection
   - Unit tests

10. **Implement FuzzySearchIsolateManager** (~1.5h)
    - File: `lib/features/exercise_database/domain/services/fuzzy_search_isolate_manager.dart`
    - Message protocol (FuzzySearchMessage sealed class)
    - Isolate initialization
    - Cache invalidation messaging
    - Unit tests for message passing

11. **Enhance HybridTemplateRepository** (~1h)
    - File: `lib/features/workout_templates/data/repositories/hybrid_template_repository.dart`
    - Add updateTemplate() with preserve flags
    - Add generateUniqueTemplateName()
    - Add _applyPreserveFlags() helper
    - Add _applyTimestampBehavior() helper
    - Update existing methods to use new logic

**Verification:**
- [ ] Unit tests pass for all services
- [ ] Snapshot validation correctly detects rename timing
- [ ] Name conflict service generates valid suggestions
- [ ] Isolate message passing works correctly
- [ ] `flutter analyze` passes

---

### Phase 3: UI Components (Est. 3-4h)

**Tasks:**

12. **Create PostWorkoutTemplateDialog** (~1.5h)
    - File: `lib/features/workout/presentation/widgets/post_workout_template_dialog.dart`
    - 3 option cards (overwrite, save as new, skip)
    - "Remember my choice" checkbox
    - Quota display for "save as new"
    - Accessibility (SemanticIcon, labels)
    - Widget tests

13. **Create TemplateNameConflictDialog** (~45 min)
    - File: `lib/features/workout/presentation/widgets/template_name_conflict_dialog.dart`
    - Name comparison UI (old vs new)
    - Keep new / Restore old actions
    - Widget tests

14. **Create TemplatePreferencesSettingsScreen** (~1.5h)
    - File: `lib/features/settings/presentation/screens/template_preferences_settings_screen.dart`
    - Global preference radio buttons
    - Template-specific overrides list
    - Reset all functionality
    - Help dialog
    - Widget tests

15. **Add localization strings** (~30 min)
    - File: `assets/i18n/app_en.arb` and `app_it.arb`
    - Add all new UI strings (see Localization Requirements section)
    - Run `flutter gen-l10n`

**Verification:**
- [ ] All dialogs display correctly in light & dark themes
- [ ] Accessibility labels present for all icons/buttons
- [ ] Widget tests pass
- [ ] Localization works for both EN & IT
- [ ] `flutter analyze` passes

---

### Phase 4: Integration & Workflow (Est. 2-3h)

**Tasks:**

16. **Implement snapshot creation on workout start** (~45 min)
    - File: `lib/features/workout/presentation/providers/workout_provider.dart`
    - Create snapshot when starting workout from template
    - Dual-layer persistence (provider + Hive cache)
    - Add sessionId to workout state

17. **Implement post-workout save flow** (~1h)
    - File: `lib/features/workout/presentation/screens/workout_completion_summary_screen.dart`
    - Retrieve snapshot with fallback
    - Validate snapshot
    - Check user preference
    - Show appropriate dialog or apply silently
    - Handle undo workflow

18. **Implement transaction lock workflow** (~45 min)
    - Acquire lock on template save
    - Show undo toast with action
    - Handle undo (restore from rollback snapshot)
    - Auto-release lock after 15s
    - Background sync lock check

19. **Add cleanup service** (~30 min)
    - File: `lib/core/services/template_cleanup_service.dart`
    - Run on app start
    - Cleanup old snapshots (>7 days)
    - Cleanup orphaned locks
    - Run from main.dart

**Verification:**
- [ ] Snapshot created correctly on workout start
- [ ] Snapshot retrieved correctly on workout completion
- [ ] Rename detection works with timestamp logic
- [ ] Transaction locks prevent ghost state
- [ ] Undo workflow restores template correctly
- [ ] Cleanup service runs without errors
- [ ] Integration tests pass

---

### Phase 5: Testing & Polish (Est. 2-3h)

**Tasks:**

20. **Write integration tests** (~1.5h)
    - Test complete post-workout flow
    - Test rename during workout scenario
    - Test undo + background sync race condition
    - Test preference persistence
    - Test quota limits

21. **Manual testing scenarios** (~1h)
    - Test on iOS & Android
    - Test in light & dark themes
    - Test with long workout sessions (>1 hour)
    - Test with app backgrounding during workout
    - Test with manual template edits during workout
    - Test quota limits (create 10 templates)

22. **Performance testing** (~30 min)
    - Profile snapshot retrieval time
    - Profile cache invalidation time
    - Ensure no UI jank during save operations
    - Check memory usage with multiple snapshots

**Verification:**
- [ ] All integration tests pass
- [ ] Manual test scenarios complete successfully
- [ ] Performance metrics acceptable (<100ms save time)
- [ ] No memory leaks detected
- [ ] `flutter analyze` passes (0 errors)

---

### Total Estimated Time: ~12-15 hours

**Breakdown by phase:**
- Phase 1 (Core): 3-4h
- Phase 2 (Services): 4-5h
- Phase 3 (UI): 3-4h
- Phase 4 (Integration): 2-3h
- Phase 5 (Testing): 2-3h

---

## 🧪 Testing Strategy

### Unit Tests

**TemplateSnapshotValidator Tests** (`test/features/workout/domain/services/template_snapshot_validator_test.dart`):

```dart
test('valid snapshot when name unchanged', () async {
  final snapshot = TemplateModificationSnapshot(
    templateId: 'template-1',
    snapshotName: 'Push Day A',
    snapshotTimestamp: DateTime(2025, 1, 15, 10, 0),
    userPreference: TemplateSavePreference.askAlways,
  );

  final template = WorkoutTemplate(
    id: 'template-1',
    name: 'Push Day A', // Same name
    lastModified: DateTime(2025, 1, 15, 9, 0),
  );

  final result = await validator.validateSnapshot(
    snapshot: snapshot,
    currentTemplate: template,
  );

  expect(result, isA<_Valid>());
});

test('name changed before workout (silent acceptance)', () async {
  final snapshot = TemplateModificationSnapshot(
    templateId: 'template-1',
    snapshotName: 'Push Day A',
    snapshotTimestamp: DateTime(2025, 1, 15, 10, 0), // Workout started 10:00
    userPreference: TemplateSavePreference.askAlways,
  );

  final template = WorkoutTemplate(
    id: 'template-1',
    name: 'Push Day A v2', // Renamed
    lastModified: DateTime(2025, 1, 15, 9, 30), // Renamed at 09:30 (BEFORE)
  );

  final result = await validator.validateSnapshot(
    snapshot: snapshot,
    currentTemplate: template,
  );

  expect(result, isA<_NameChangedBeforeWorkout>());
  result.whenOrNull(
    nameChangedBeforeWorkout: (oldName, newName, rec) {
      expect(oldName, 'Push Day A');
      expect(newName, 'Push Day A v2');
      expect(rec, SnapshotRecommendation.useCurrent);
    },
  );
});

test('name changed during workout (conflict detection)', () async {
  final snapshot = TemplateModificationSnapshot(
    templateId: 'template-1',
    snapshotName: 'Push Day A',
    snapshotTimestamp: DateTime(2025, 1, 15, 10, 0), // Workout started 10:00
    userPreference: TemplateSavePreference.askAlways,
  );

  final template = WorkoutTemplate(
    id: 'template-1',
    name: 'Push Day A v2', // Renamed
    lastModified: DateTime(2025, 1, 15, 10, 30), // Renamed at 10:30 (AFTER)
  );

  final result = await validator.validateSnapshot(
    snapshot: snapshot,
    currentTemplate: template,
  );

  expect(result, isA<_NameChangedDuringWorkout>());
  result.whenOrNull(
    nameChangedDuringWorkout: (oldName, newName, renameTs, workoutTs, rec) {
      expect(oldName, 'Push Day A');
      expect(newName, 'Push Day A v2');
      expect(rec, SnapshotRecommendation.askUser);
      expect(renameTs.isAfter(workoutTs), true);
    },
  );
});
```

**TemplateNameConflictService Tests**:

```dart
test('generates date suffix suggestion', () async {
  final suggestions = await service.generateSmartSuggestions('Push Day A');

  final dateFormat = DateFormat('dd/MM');
  final expectedDateSuffix = 'Push Day A - ${dateFormat.format(DateTime.now())}';

  expect(suggestions, contains(expectedDateSuffix));
});

test('increments version number correctly', () async {
  final suggestions = await service.generateSmartSuggestions('Push Day A - v2');

  expect(suggestions, contains('Push Day A - v3'));
});

test('detects name variants correctly', () {
  expect(service.isNameVariant('Push Day A - 22/01', 'Push Day A'), true);
  expect(service.isNameVariant('Push Day A - v2', 'Push Day A'), true);
  expect(service.isNameVariant('Push Day A - Lunedì', 'Push Day A'), true);
  expect(service.isNameVariant('Pull Day B', 'Push Day A'), false);
});
```

**TemplateTransactionLockRepository Tests**:

```dart
test('acquires lock successfully', () async {
  final lock = await repo.acquireLock(
    templateId: 'template-1',
    lockType: TemplateLockType.undoWindow,
    duration: const Duration(seconds: 15),
  );

  expect(lock, isNotNull);
  expect(lock!.templateId, 'template-1');
  expect(lock.lockType, TemplateLockType.undoWindow);
});

test('prevents duplicate lock acquisition', () async {
  await repo.acquireLock(
    templateId: 'template-1',
    lockType: TemplateLockType.undoWindow,
    duration: const Duration(seconds: 15),
  );

  final duplicate = await repo.acquireLock(
    templateId: 'template-1',
    lockType: TemplateLockType.manualEdit,
    duration: const Duration(seconds: 15),
  );

  expect(duplicate, isNull);
});

test('auto-releases expired locks', () async {
  await repo.acquireLock(
    templateId: 'template-1',
    lockType: TemplateLockType.undoWindow,
    duration: const Duration(milliseconds: 100),
  );

  await Future.delayed(const Duration(milliseconds: 150));

  final isLocked = await repo.isLocked('template-1');
  expect(isLocked, false);
});
```

---

### Widget Tests

**PostWorkoutTemplateDialog Tests**:

```dart
testWidgets('displays all 3 options correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PostWorkoutTemplateDialog(
        completedWorkout: mockWorkout,
        snapshot: mockSnapshot,
      ),
    ),
  );

  expect(find.text('Sovrascrivi pesi/reps'), findsOneWidget);
  expect(find.text('Salva come nuovo template'), findsOneWidget);
  expect(find.text('Avanti senza salvare'), findsOneWidget);
  expect(find.byType(Checkbox), findsOneWidget); // "Ricorda" checkbox
});

testWidgets('quota display shows warning when low', (tester) async {
  // Mock quota: 9/10 used

  await tester.pumpWidget(...);

  final quotaText = find.text('9/10');
  expect(quotaText, findsOneWidget);

  // Should show warning color
  final container = tester.widget<Container>(
    find.ancestor(of: quotaText, matching: find.byType(Container)).first,
  );
  expect(
    (container.decoration as BoxDecoration).color,
    isA<Color>(), // Warning color
  );
});

testWidgets('"Remember my choice" checkbox saves preference', (tester) async {
  await tester.pumpWidget(...);

  // Tap checkbox
  await tester.tap(find.byType(Checkbox));
  await tester.pumpAndSettle();

  // Tap "Overwrite" option
  await tester.tap(find.text('Sovrascrivi pesi/reps'));
  await tester.pumpAndSettle();

  // Verify preference saved
  verify(mockPrefsRepo.setGlobalPreference(
    TemplateSavePreference.alwaysOverwrite,
  )).called(1);
});
```

---

### Integration Tests

**End-to-End Post-Workout Flow Test** (`integration_test/template_save_e2e_test.dart`):

```dart
testWidgets('complete post-workout template save flow', (tester) async {
  // 1. Start workout from template
  await tester.tap(find.text('Push Day A'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Start Workout'));
  await tester.pumpAndSettle();

  // Verify snapshot created
  expect(find.byType(WorkoutScreen), findsOneWidget);

  // 2. Complete workout
  await tester.tap(find.text('Finish Workout'));
  await tester.pumpAndSettle();

  // 3. Verify PostWorkoutTemplateDialog appears
  expect(find.byType(PostWorkoutTemplateDialog), findsOneWidget);
  expect(find.text('Sovrascrivi pesi/reps'), findsOneWidget);

  // 4. Select "Overwrite"
  await tester.tap(find.text('Sovrascrivi pesi/reps'));
  await tester.pumpAndSettle();

  // 5. Verify undo toast appears
  expect(find.text('Template aggiornato'), findsOneWidget);
  expect(find.text('UNDO'), findsOneWidget);

  // 6. Wait for toast to disappear (lock released)
  await tester.pumpAndSettle(const Duration(seconds: 16));

  // 7. Verify template updated in repository
  final template = await getTemplateById('template-1');
  expect(template.name, 'Push Day A');
  expect(template.exerciseData, isNotEmpty); // Weights updated
});

testWidgets('rename during workout shows conflict dialog', (tester) async {
  // 1. Start workout from template
  await tester.tap(find.text('Push Day A'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Start Workout'));
  await tester.pumpAndSettle();

  // 2. Simulate template rename DURING workout (background)
  await renameTemplateManually('template-1', 'Push Day A v2');

  // 3. Complete workout
  await tester.tap(find.text('Finish Workout'));
  await tester.pumpAndSettle();

  // 4. Verify TemplateNameConflictDialog appears
  expect(find.byType(TemplateNameConflictDialog), findsOneWidget);
  expect(find.text('Push Day A'), findsOneWidget); // Old name
  expect(find.text('Push Day A v2'), findsOneWidget); // New name

  // 5. Select "Keep new name"
  await tester.tap(find.text('Keep new name'));
  await tester.pumpAndSettle();

  // 6. Verify PostWorkoutTemplateDialog appears with new name
  expect(find.byType(PostWorkoutTemplateDialog), findsOneWidget);
});

testWidgets('undo workflow restores template correctly', (tester) async {
  // 1. Save template update
  await tester.tap(find.text('Sovrascrivi pesi/reps'));
  await tester.pumpAndSettle();

  // 2. Immediately tap UNDO
  await tester.tap(find.text('UNDO'));
  await tester.pumpAndSettle();

  // 3. Verify success message
  expect(find.text('Modifiche annullate'), findsOneWidget);

  // 4. Verify template restored to original state
  final template = await getTemplateById('template-1');
  expect(template.exerciseData, equals(originalData));
});
```

---

## 🌍 Localization Requirements

**All new UI strings must be added to `assets/i18n/app_en.arb` and `app_it.arb`**

### English (`app_en.arb`)

```json
{
  "congratsWorkoutSaved": "Congrats! Workout saved",
  "whatWouldYouLikeToDo": "What would you like to do?",
  "overwriteWeightsReps": "Overwrite weights/reps",
  "overwriteWeightsRepsSubtitle": "Update the template with your performance data",
  "recommended": "Recommended",
  "saveAsNewTemplate": "Save as new template",
  "saveAsNewTemplateSubtitle": "Create a new template ({remaining}/{max} remaining)",
  "continueWithoutSaving": "Continue without saving",
  "continueWithoutSavingSubtitle": "Your workout is saved, template stays unchanged",
  "rememberMyChoice": "Remember my choice",
  "rememberMyChoiceSubtitle": "You can reset this in Settings > Template Preferences",
  "templateRenamedDuringWorkout": "Template renamed during workout",
  "templateRenamedDuringWorkoutDescription": "The template was renamed while you were working out. Which name would you like to use?",
  "nameAtWorkoutStart": "Name at workout start",
  "currentTemplateName": "Current template name",
  "whichNameWouldYouLikeToUse": "Which name would you like to use?",
  "keepNewName": "Keep new name ({name})",
  "restoreOldName": "Restore old name ({name})",
  "templateUpdated": "Template updated",
  "changesCancelled": "Changes cancelled",
  "templateSavePreferences": "Template Save Preferences",
  "globalPreference": "Global Preference",
  "globalPreferenceSubtitle": "Default behavior when completing workouts from templates",
  "askAlways": "Ask always",
  "askAlwaysSubtitle": "Show dialog with options every time",
  "alwaysOverwrite": "Always overwrite weights/reps",
  "alwaysOverwriteSubtitle": "Update template silently without asking",
  "alwaysCreateNew": "Always create new template",
  "alwaysCreateNewSubtitle": "Save as new template every time",
  "neverSave": "Never save to template",
  "neverSaveSubtitle": "Skip template save completely",
  "templateSpecificOverrides": "Template-Specific Overrides",
  "templateSpecificOverridesSubtitle": "Custom preferences for individual templates",
  "resetAllPreferences": "Reset All Preferences",
  "confirmReset": "Confirm Reset",
  "confirmResetDescription": "This will reset the global preference to 'Ask always' and remove all template-specific overrides. Continue?",
  "preferenceSaved": "Preference saved",
  "preferencesReset": "Preferences reset",
  "overrideRemoved": "Override removed",
  "howItWorks": "How It Works",
  "templatePreferencesHelpText": "Global preference applies to all templates unless you have a template-specific override. Template-specific overrides take priority over the global preference. You can reset everything to default (Ask always) with the Reset button.",
  "gotIt": "Got it"
}
```

### Italian (`app_it.arb`)

```json
{
  "congratsWorkoutSaved": "Complimenti! L'allenamento è stato salvato",
  "whatWouldYouLikeToDo": "Cosa vuoi fare?",
  "overwriteWeightsReps": "Sovrascrivi pesi/reps",
  "overwriteWeightsRepsSubtitle": "Aggiorna il template con i tuoi dati di performance",
  "recommended": "Consigliato",
  "saveAsNewTemplate": "Salva come nuovo template",
  "saveAsNewTemplateSubtitle": "Crea un nuovo template (rimanenti: {remaining}/{max})",
  "continueWithoutSaving": "Avanti senza salvare",
  "continueWithoutSavingSubtitle": "Il tuo allenamento è salvato, il template rimane invariato",
  "rememberMyChoice": "Ricorda la mia scelta",
  "rememberMyChoiceSubtitle": "Puoi reimpostare nelle Impostazioni > Preferenze Template",
  "templateRenamedDuringWorkout": "Template rinominato durante l'allenamento",
  "templateRenamedDuringWorkoutDescription": "Il template è stato rinominato mentre ti allenavi. Quale nome vuoi usare?",
  "nameAtWorkoutStart": "Nome all'inizio allenamento",
  "currentTemplateName": "Nome template corrente",
  "whichNameWouldYouLikeToUse": "Quale nome vuoi utilizzare?",
  "keepNewName": "Mantieni nuovo nome ({name})",
  "restoreOldName": "Ripristina vecchio nome ({name})",
  "templateUpdated": "Template aggiornato",
  "changesCancelled": "Modifiche annullate",
  "templateSavePreferences": "Preferenze Salvataggio Template",
  "globalPreference": "Preferenza Globale",
  "globalPreferenceSubtitle": "Comportamento predefinito al completamento allenamenti da template",
  "askAlways": "Chiedi sempre",
  "askAlwaysSubtitle": "Mostra dialog con opzioni ogni volta",
  "alwaysOverwrite": "Sovrascrivi sempre pesi/reps",
  "alwaysOverwriteSubtitle": "Aggiorna template silenziosamente senza chiedere",
  "alwaysCreateNew": "Crea sempre nuovo template",
  "alwaysCreateNewSubtitle": "Salva come nuovo template ogni volta",
  "neverSave": "Non salvare mai nel template",
  "neverSaveSubtitle": "Salta completamente il salvataggio template",
  "templateSpecificOverrides": "Override Specifici per Template",
  "templateSpecificOverridesSubtitle": "Preferenze personalizzate per singoli template",
  "resetAllPreferences": "Reimposta Tutte le Preferenze",
  "confirmReset": "Conferma Reset",
  "confirmResetDescription": "Questo resetterà la preferenza globale a 'Chiedi sempre' e rimuoverà tutti gli override specifici. Continuare?",
  "preferenceSaved": "Preferenza salvata",
  "preferencesReset": "Preferenze reimpostate",
  "overrideRemoved": "Override rimosso",
  "howItWorks": "Come Funziona",
  "templatePreferencesHelpText": "La preferenza globale si applica a tutti i template a meno che non ci sia un override specifico. Gli override specifici hanno priorità sulla preferenza globale. Puoi reimpostare tutto al default (Chiedi sempre) con il pulsante Reset.",
  "gotIt": "Capito"
}
```

**After adding strings, run**:
```bash
flutter gen-l10n
```

---

## 📚 References

### UX Research

**Progressive Disclosure Pattern**:
- Material Design 3: https://m3.material.io/foundations/interaction/states/overview
- Nielsen Norman Group: https://www.nngroup.com/articles/progressive-disclosure/

**"Remember My Choice" UX**:
- Google Material Design Dialogs: https://m3.material.io/components/dialogs/overview
- iOS Human Interface Guidelines - Alerts: https://developer.apple.com/design/human-interface-guidelines/alerts

**Fitness App UX Best Practices**:
- Strava post-workout save flow (benchmark)
- Strong app template management (benchmark)
- Hevy app workout completion UX (benchmark)

**Mobile UX Optimization**:
- ≤3 taps principle: https://www.nngroup.com/articles/minimize-cognitive-load/
- Touch target sizes: https://developer.apple.com/design/human-interface-guidelines/layout

### Code References

**Existing Codebase**:
- `lib/features/workout/presentation/helpers/save_template_helper.dart` (current implementation)
- `lib/features/workout_templates/data/repositories/hybrid_template_repository.dart` (hybrid local+cloud)
- `lib/features/exercise_database/domain/services/exercise_fuzzy_search_isolate.dart` (isolate pattern)

**Flutter Patterns**:
- Freezed sealed classes: https://pub.dev/packages/freezed
- Riverpod 2.x providers: https://riverpod.dev/docs/concepts/providers
- Hive local storage: https://docs.hivedb.dev/

---

## ✅ Design Completion Checklist

- [x] Problem statement documented
- [x] Critical vulnerabilities identified and fixed
- [x] Architecture decision tree designed
- [x] All entities defined with freezed
- [x] All repositories designed with Hive integration
- [x] All services designed with business logic
- [x] All UI components designed with accessibility
- [x] UX flows documented with diagrams
- [x] Implementation plan with time estimates
- [x] Testing strategy with unit/widget/integration tests
- [x] Localization requirements (EN + IT strings)
- [x] References to UX research and code patterns

---

## 📝 Notes & Open Questions

**Design Decisions Made**:

1. **Offline-first with local-wins**: Chosen for single-user app with no collaboration requirements. Cloud sync is secondary (premium feature).

2. **Dual-layer snapshot persistence**: Provider (fast) + Hive cache (persistent) to survive long workouts and provider GC.

3. **Transaction locks over optimistic locking**: Simpler implementation for single-user app. Locks auto-expire to prevent deadlocks.

4. **Explicit enums over boolean flags**: Better type safety and self-documenting code. Prevents ambiguous `preserveFlags: true` issues.

5. **Smart name suggestions over manual input**: Reduces cognitive load. User can still type custom name if needed.

**Future Enhancements (Out of Scope for v1)**:

- [ ] Multi-device conflict resolution (CRDTs or vector clocks)
- [ ] Template versioning with rollback to any previous version
- [ ] Template sharing between users (collaborative templates)
- [ ] AI-powered template suggestions based on workout history
- [ ] Template marketplace (community templates)

**Known Limitations**:

- Cleanup service only runs on app start (not periodic background)
- Lock system doesn't handle app process kill gracefully (requires manual cleanup on next launch)
- Fuzzy search cache invalidation assumes single isolate (doesn't support multiple isolates)

---

**End of Design Document**

**Next Steps**: Proceed with Phase 1 implementation (Core Entities & Repositories)
