# SupersetExerciseData V1 → V2 Migration Strategy

## 📋 Overview

This document outlines the migration strategy for upgrading `SupersetExerciseData` from schema V1 (without `countingMode`) to V2 (with full counting mode support).

**Target**: Single-user app in testing phase (developer only)
**Risk Level**: LOW (no production users)
**Breaking Changes**: Allowed

---

## 🎯 Migration Goals

1. ✅ **Backward Compatibility**: V1 data automatically migrates on read
2. ✅ **Zero Downtime**: No app downtime required
3. ✅ **Automatic Migration**: Happens transparently via `fromJson()`
4. ✅ **Data Integrity**: All existing data preserved with sensible defaults

---

## 🔄 Migration Flow

### **Approach: Lazy Migration on Read**

We use a **lazy migration** strategy where V1 data is automatically upgraded to V2 when read from Firestore.

```dart
// When reading from Firestore:
factory SupersetExerciseData.fromJson(Map<String, dynamic> json) {
  final schemaVersion = json['_schemaVersion'] as int? ?? 1; // Default to V1

  return switch(schemaVersion) {
    1 => _migrateFromV1(json),  // Automatic V1→V2 migration
    2 => _parseV2(json),        // Native V2 parsing
    _ => throw UnsupportedError('Unknown schema version: $schemaVersion'),
  };
}
```

**Benefits:**
- ✅ No manual migration script needed
- ✅ No database-wide update required
- ✅ V1 and V2 data coexist safely
- ✅ Gradual migration as data is accessed

---

## 📊 Schema Comparison

### **V1 Schema (Old - No countingMode)**
```json
{
  "exerciseId": "ex_123",
  "exerciseName": "Bench Press",
  "targetWeight": 80.0,
  "targetReps": 10,
  "actualWeight": 75.0,
  "actualReps": 12,
  "rpe": 8,
  "isCompleted": true,
  "notes": "Good form"
}
```

### **V2 Schema (New - With countingMode)**
```json
{
  "_schemaVersion": 2,
  "exerciseId": "ex_123",
  "exerciseName": "Bench Press",
  "countingMode": "weighted",
  "targetWeight": 80.0,
  "targetReps": 10,
  "targetSeconds": null,
  "actualWeight": 75.0,
  "actualReps": 12,
  "actualSeconds": null,
  "rpe": 8,
  "isCompleted": true,
  "notes": "Good form"
}
```

### **Key Differences:**
1. ✅ `_schemaVersion` field added (value: 2)
2. ✅ `countingMode` field added (required)
3. ✅ `targetSeconds` / `actualSeconds` fields added (optional)

---

## 🛡️ Migration Rules

### **V1 → V2 Default Mapping**

| V1 Field | V2 Field | Migration Logic |
|----------|----------|-----------------|
| *(missing)* | `countingMode` | → `ExerciseCountingMode.weighted` (default) |
| *(missing)* | `_schemaVersion` | → `2` (on write) |
| `targetWeight` | `targetWeight` | → Preserved as-is |
| `targetReps` | `targetReps` | → Preserved as-is |
| *(missing)* | `targetSeconds` | → `null` (not applicable in V1) |
| `actualWeight` | `actualWeight` | → Preserved as-is |
| `actualReps` | `actualReps` | → Preserved as-is |
| *(missing)* | `actualSeconds` | → `null` (not applicable in V1) |
| `rpe` | `rpe` | → Preserved as-is |
| `isCompleted` | `isCompleted` | → Preserved as-is |
| `notes` | `notes` | → Preserved as-is |

**Why default to `weighted`?**
- In V1, all exercises implicitly used weighted mode (targetWeight + targetReps)
- Defaulting to `weighted` preserves original behavior
- No data loss or semantic change

---

## 🚀 Deployment Strategy

### **For Single-User Testing Phase (Current)**

Since you're the only user, migration is **automatic and safe**:

1. **Deploy Code**
   - Push Phase 1 changes (SupersetExerciseData V2)
   - No database changes needed

2. **Test Locally**
   ```bash
   flutter run
   # Open app → Navigate to superset workout
   # V1 data automatically migrates on read
   # New data saves as V2
   ```

3. **Verify Migration**
   - Open existing workout with superset
   - Edit superset round → Check data integrity
   - Complete workout → Verify save as V2

4. **Monitor Logs**
   ```dart
   // Add temporary logging (optional)
   if (kDebugMode) {
     debugPrint('Migrated V$schemaVersion data for ${json['exerciseName']}');
   }
   ```

### **Phase Timeline**
- **Day 1**: Deploy code (already done ✅)
- **Day 2**: Test existing workouts
- **Day 3**: Verify new workouts save as V2
- **Day 4-5**: Monitor for issues

---

## 🧪 Testing Checklist

### **Pre-Deployment**
- [x] Unit tests pass (23/23 tests ✅)
- [x] V1 → V2 migration tested
- [x] V2 parsing tested
- [x] Validation methods tested
- [x] Display formatting tested

### **Post-Deployment**
- [ ] Open existing superset workout (V1 data)
- [ ] Verify exercise data displays correctly
- [ ] Edit superset round → Save
- [ ] Verify saved as V2 (`_schemaVersion: 2`)
- [ ] Create new superset workout
- [ ] Verify new data saves as V2
- [ ] Test time-based exercise (plank) in superset
- [ ] Verify `targetSeconds`/`actualSeconds` work

---

## 🔧 Manual Migration Script (Optional)

If you want to **force migrate all existing V1 data** to V2 immediately (not required):

```dart
// lib/scripts/migrate_superset_data_v1_to_v2.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// One-time migration script to upgrade all V1 SupersetExerciseData to V2
///
/// Usage:
/// 1. Run this in a debug build
/// 2. Watch console for progress
/// 3. Verify in Firestore console
class SupersetDataMigrationV1ToV2 {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId; // Your user ID

  SupersetDataMigrationV1ToV2({required this.userId});

  /// Migrate all workouts for current user
  Future<void> migrateAllWorkouts() async {
    print('🔄 Starting migration V1 → V2 for user: $userId');

    // Get all workouts
    final workoutsSnapshot = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .get();

    int totalUpdated = 0;
    int totalSkipped = 0;

    for (final doc in workoutsSnapshot.docs) {
      final data = doc.data();
      final exercises = data['exercises'] as List<dynamic>?;

      if (exercises == null) {
        totalSkipped++;
        continue;
      }

      bool needsUpdate = false;
      final updatedExercises = exercises.map((ex) {
        final exerciseData = ex as Map<String, dynamic>;

        // Check if this is a superset
        if (exerciseData['type'] == 'superset') {
          final supersetSets = exerciseData['supersetSets'] as List<dynamic>?;

          if (supersetSets != null) {
            final updatedSets = supersetSets.map((set) {
              final setData = set as Map<String, dynamic>;
              final exerciseDataMap = setData['exerciseData'] as Map<String, dynamic>?;

              if (exerciseDataMap != null) {
                final updatedExerciseData = <String, dynamic>{};

                for (final entry in exerciseDataMap.entries) {
                  final exData = entry.value as Map<String, dynamic>;

                  // Check if V1 (no _schemaVersion or _schemaVersion == 1)
                  final schemaVersion = exData['_schemaVersion'] as int? ?? 1;

                  if (schemaVersion == 1) {
                    needsUpdate = true;

                    // Upgrade to V2
                    updatedExerciseData[entry.key] = {
                      ...exData,
                      '_schemaVersion': 2,
                      'countingMode': 'weighted', // Default for V1
                      'targetSeconds': null,
                      'actualSeconds': null,
                    };
                  } else {
                    updatedExerciseData[entry.key] = exData;
                  }
                }

                return {
                  ...setData,
                  'exerciseData': updatedExerciseData,
                };
              }

              return setData;
            }).toList();

            return {
              ...exerciseData,
              'supersetSets': updatedSets,
            };
          }
        }

        return exerciseData;
      }).toList();

      // Update document if needed
      if (needsUpdate) {
        await doc.reference.update({
          'exercises': updatedExercises,
        });
        totalUpdated++;
        print('✅ Updated workout: ${doc.id}');
      } else {
        totalSkipped++;
      }
    }

    print('');
    print('✅ Migration complete!');
    print('   Updated: $totalUpdated workouts');
    print('   Skipped: $totalSkipped workouts (already V2 or no supersets)');
  }
}

/// Usage example:
void main() async {
  // Initialize Firebase
  // ...

  final migration = SupersetDataMigrationV1ToV2(
    userId: 'YOUR_USER_ID_HERE',
  );

  await migration.migrateAllWorkouts();
}
```

**When to use:**
- ⚠️ **Not required** for single-user testing
- ✅ Useful if you want clean V2 data immediately
- ✅ Good for peace of mind before production

---

## 📈 Monitoring & Validation

### **Firestore Console Checks**

1. **Before Migration**
   ```
   workouts/{workoutId}/exercises[]/supersetSets[]/exerciseData/
   {
     "exerciseId": "...",
     "targetWeight": 80.0,
     // No _schemaVersion, no countingMode
   }
   ```

2. **After Migration** (automatic on read + save)
   ```
   workouts/{workoutId}/exercises[]/supersetSets[]/exerciseData/
   {
     "_schemaVersion": 2,
     "exerciseId": "...",
     "countingMode": "weighted",
     "targetWeight": 80.0,
     "targetSeconds": null,
     // ✅ V2 schema
   }
   ```

### **Log Monitoring**

Add temporary debug logging to track migration:

```dart
// In SupersetExerciseData.fromJson()
factory SupersetExerciseData.fromJson(Map<String, dynamic> json) {
  final schemaVersion = json['_schemaVersion'] as int? ?? 1;

  if (kDebugMode && schemaVersion == 1) {
    debugPrint('🔄 Migrating V1 → V2: ${json['exerciseName']}');
  }

  return switch(schemaVersion) {
    1 => _migrateFromV1(json),
    2 => _parseV2(json),
    _ => throw UnsupportedError('Unknown schema version: $schemaVersion'),
  };
}
```

---

## 🚨 Rollback Plan

### **If Issues Occur**

Since migration is **backward compatible**, rollback is simple:

1. **Code Rollback**
   ```bash
   git revert <commit-hash>
   flutter run
   ```

2. **Data Rollback** (if manual migration was run)
   - V2 data remains readable by old code (fields ignored)
   - Or restore from Firestore backup if needed

3. **No Data Loss**
   - V1 fields (`targetWeight`, `targetReps`) always preserved
   - V2 adds fields (`countingMode`, `targetSeconds`) but doesn't remove

### **Risk Assessment**
- **Risk Level**: 🟢 **LOW**
- **User Impact**: None (auto-migration)
- **Data Loss Risk**: None (additive changes only)
- **Rollback Time**: < 5 minutes

---

## ✅ Success Criteria

Migration is successful when:

1. ✅ All unit tests pass (23/23)
2. ✅ Existing V1 workouts load correctly
3. ✅ New workouts save as V2 (`_schemaVersion: 2`)
4. ✅ Time-based exercises work in supersets
5. ✅ No user-facing errors or data loss

---

## 📚 Related Documentation

- [Implementation Plan](./IMPLEMENTATION_PLAN_REVISED.md)
- [Schema Versions Config](../../lib/core/config/schema_versions.dart)
- [Test Suite](../../test/features/workout/domain/entities/superset_exercise_data_test.dart)

---

## 🎯 Next Steps

After successful migration:
1. ✅ Monitor for 3-5 days
2. ✅ Remove debug logging
3. ✅ Proceed to **Phase 4: UI Layer** (unified execution sheets)

---

**Status**: ✅ **READY FOR DEPLOYMENT**
**Last Updated**: 2025-01-31
**Author**: Claude (with consultant feedback)
