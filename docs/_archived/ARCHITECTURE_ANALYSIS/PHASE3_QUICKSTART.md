# Phase 3 Quick Start Guide

## 🚀 Ready to Deploy?

Your app now has **automatic V1 → V2 migration** built-in. Here's what to do:

---

## ✅ Checklist Before Deployment

- [x] Phase 0 complete (feature flags + schema versions)
- [x] Phase 1 complete (SupersetExerciseData V2)
- [x] Phase 2 complete (23/23 tests passing)
- [ ] Read [Migration Strategy](./MIGRATION_STRATEGY_V1_TO_V2.md)
- [ ] Test with existing workout data
- [ ] Verify new workouts save as V2

---

## 🎯 Quick Actions

### **Option A: Just Deploy (Recommended)**

1. **Deploy code** (already done ✅)
2. **Open app** and test existing superset workouts
3. **Monitor logs** for automatic V1→V2 migration
4. **Done!** Migration happens automatically on read

### **Option B: Force Migrate All Data**

If you want to upgrade all V1 data to V2 immediately:

1. **Run dry-run** to preview changes:
   ```dart
   // In your app code:
   import 'lib/scripts/migrate_superset_data_v1_to_v2.dart';

   final result = await SupersetDataMigrationV1ToV2.migrateUser(
     userId,
     dryRun: true, // Safe: no changes
   );
   print(result);
   ```

2. **Run live migration** if dry-run looks good:
   ```dart
   final result = await SupersetDataMigrationV1ToV2.migrateUser(
     userId,
     dryRun: false, // CAUTION: will update Firestore
   );
   ```

3. **Check Firestore console** to verify `_schemaVersion: 2`

---

## 🧪 Testing Steps

1. **Test Existing Workouts**
   - Open workout with superset
   - Verify exercise data displays correctly
   - Edit round → Save
   - Check Firestore: should have `_schemaVersion: 2`

2. **Test New Workouts**
   - Create new superset workout
   - Add exercises (weighted, reps, time-based)
   - Complete workout
   - Check Firestore: should have `_schemaVersion: 2`

3. **Test Time-Based Exercises**
   - Add plank or wall sit to superset
   - Set target seconds (e.g., 60)
   - Complete round with actual seconds
   - Verify `targetSeconds`/`actualSeconds` saved

---

## 📊 What Changed?

### **Before (V1)**
```json
{
  "exerciseId": "ex_123",
  "targetWeight": 80.0,
  "targetReps": 10
}
```

### **After (V2)**
```json
{
  "_schemaVersion": 2,
  "exerciseId": "ex_123",
  "countingMode": "weighted",
  "targetWeight": 80.0,
  "targetReps": 10,
  "targetSeconds": null,
  "actualSeconds": null
}
```

---

## 🔍 Monitoring

### **Check Migration Status**

```dart
// Add temporary logging in SupersetExerciseData.fromJson()
if (kDebugMode && schemaVersion == 1) {
  debugPrint('🔄 Migrating V1→V2: ${json['exerciseName']}');
}
```

### **Verify in Firestore Console**

1. Go to Firestore console
2. Navigate to: `workouts/{id}/exercises[]/supersetSets[]/exerciseData/`
3. Check for `_schemaVersion: 2` field
4. Check for `countingMode` field

---

## ⚠️ Rollback (if needed)

If issues occur:

1. **Code rollback**:
   ```bash
   git revert <commit-hash>
   flutter run
   ```

2. **No data loss**:
   - V2 data is backward compatible
   - Old code ignores new fields
   - All V1 fields preserved

---

## 📚 Full Documentation

- [Complete Migration Strategy](./MIGRATION_STRATEGY_V1_TO_V2.md)
- [Migration Script](../../lib/scripts/migrate_superset_data_v1_to_v2.dart)
- [Test Suite](../../test/features/workout/domain/entities/superset_exercise_data_test.dart)

---

## ✅ Success Criteria

Phase 3 is complete when:

- [x] Documentation created
- [x] Migration script created
- [ ] Existing workouts tested
- [ ] New workouts save as V2
- [ ] No errors for 3-5 days

---

**Status**: ✅ **READY TO TEST**
**Risk**: 🟢 **LOW** (single user, backward compatible)
**Next**: Test with real data → Phase 4 (UI layer)
