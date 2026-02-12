# Exercise Popularity Ranking - Testing Guide

**Status**: ✅ Backend Deployed | ⏳ Manual Testing Required | 🧪 Flutter Tests Passing

## 🎯 Quick Status

| Component | Status |
|-----------|--------|
| Cloud Functions | ✅ Deployed (`generatePopularityBundle`, `onTemplateCreated`) |
| Flutter Client | ✅ Implemented (cache, bundle service, search boost) |
| Unit Tests | ✅ 9/9 passing (cache) + boost formula tests |
| Firestore Rules | ✅ Deployed (read-only for authenticated users) |
| **Test Data** | ⏳ **REQUIRES MANUAL CREATION** |
| **End-to-End Flow** | ⏳ **REQUIRES VERIFICATION** |

---

## 📋 Manual Testing Steps

### Step 1: Create Test Popularity Data

**Vai a Firebase Console:**
```
https://console.firebase.google.com/project/gymprogressapp-184bc/firestore/data/~2Fexercise_popularity
```

**Crea questi 5 documenti** (click "Add Document"):

| Document ID | Field: `count` (number) | Field: `lastUpdated` (timestamp) |
|-------------|-------------------------|----------------------------------|
| `squat_full_bilanciere` | 150 | (click "Use current timestamp") |
| `panca_piana_bilanciere` | 120 | (click "Use current timestamp") |
| `stacco_terra_bilanciere` | 100 | (click "Use current timestamp") |
| `military_press` | 80 | (click "Use current timestamp") |
| `trazioni_sbarra` | 60 | (click "Use current timestamp") |

**Expected Result:**
- 5 documents in `/exercise_popularity` collection
- Each with `count` (number) and `lastUpdated` (timestamp)

---

### Step 2: Trigger Bundle Generation (Option A - Automatic)

**La funzione `generatePopularityBundle` è schedulata per le 3:00 AM Europe/Rome.**

- **Wait**: Bundle verrà generato automaticamente domani alle 3am
- **Check logs** dopo le 3am:
  ```bash
  firebase functions:log | grep generatePopularityBundle
  ```

Expected output:
```
📊 Starting popularity bundle generation...
✅ Fetched 5 popularity documents
📦 Bundle created: popularity_2026-02-10
   Size: ~X KB
✅ Bundle uploaded to Storage: bundles/latest.bundle
```

---

### Step 2: Trigger Bundle Generation (Option B - Manual Trigger)

**Per testare subito senza aspettare le 3am**, triggera manualmente:

1. **Vai a Cloud Scheduler Console:**
   ```
   https://console.cloud.google.com/cloudscheduler?project=gymprogressapp-184bc
   ```

2. **Trova il job `firebase-schedule-generatePopularityBundle-us-central1`**

3. **Click "Force Run"** (pulsante ▶️)

4. **Verifica logs:**
   ```bash
   firebase functions:log | grep -A 10 "generatePopularityBundle"
   ```

---

### Step 3: Verify Bundle in Firebase Storage

**Vai a Firebase Storage:**
```
https://console.firebase.google.com/project/gymprogressapp-184bc/storage
```

**Verifica:**
- ✅ File exists: `/bundles/latest.bundle`
- ✅ File size: ~5-10KB (for 5 exercises)
- ✅ Metadata:
  - `cacheControl`: `public, max-age=86400`
  - `customMetadata.documentCount`: `5`
  - `customMetadata.generatedAt`: (recent timestamp)

---

### Step 4: Test Flutter Bundle Download

**Start Flutter app** (dopo che bundle è stato creato):

```bash
cd /Users/michele/gymbro_flutter_new
flutter run --release
```

**Verifica nel log dell'app:**
- Look for: `"✅ Popularity bundle loaded: X exercises"`
- Should see: `"📊 Cache populated with 5 exercises"`

**Check cache stats** (from Flutter DevTools or debug print):
```dart
final cache = ExercisePopularityCache();
final stats = cache.getStats();
print(stats); // Should show 5 fresh entries
```

---

### Step 5: Test Search Boost

**In Flutter app**, search for exercises:

1. **Search "squat"** → should return `squat_full_bilanciere` **higher** (150 uses = 1.5x boost)
2. **Search "panca"** → should return `panca_piana_bilanciere` **higher** (120 uses = 1.425x boost)
3. **Search "trazioni"** → should return `trazioni_sbarra` **lower boost** (60 uses = 1.1875x)

**Expected behavior:**
- Popular exercises (>100 uses) appear first
- Unpopular exercises appear lower in results

---

### Step 6: Test onTemplateCreated Trigger

**Create a new workout template** in Flutter app with these exercises:
- squat_full_bilanciere
- military_press

**Verifica in Firestore:**
1. Open `exercise_popularity` collection
2. Check `squat_full_bilanciere`:
   - `count` should be **151** (was 150, incremented by 1)
3. Check `military_press`:
   - `count` should be **81** (was 80, incremented by 1)

**Check Cloud Function logs:**
```bash
firebase functions:log | grep onTemplateCreated
```

Expected output:
```
📊 Incrementing popularity for template abc123 (2 exercises)
✅ Popularity incremented for 2 exercises
```

---

## 🧪 Automated Tests (Already Passing)

### Cache Tests (9/9 ✅)

```bash
flutter test test/shared/data/services/exercise_popularity_cache_test.dart
```

Tests:
- ✅ getPopularity returns 0 for missing exercise
- ✅ getPopularity returns cached count for existing exercise
- ✅ getPopularity returns 0 for expired cache entry (>24h)
- ✅ updateBatch populates cache correctly
- ✅ needsSync returns true for empty cache
- ✅ needsSync returns false for fresh cache
- ✅ needsSync returns true for expired cache
- ✅ clear removes all cache entries
- ✅ getStats returns correct statistics

### Boost Formula Tests (✅)

```bash
flutter test test/features/exercise_database/domain/services/exercise_search_service_boost_test.dart
```

Tests:
- ✅ 0-10 uses → 1.0x boost
- ✅ 11-50 uses → 1.0x-1.15x progressive
- ✅ 51-100 uses → 1.15x-1.25x progressive
- ✅ 100+ uses → 1.25x-1.5x progressive (capped at 1.5x)

---

## 🔍 Verification Commands

### Check Cloud Functions Status
```bash
firebase functions:list | grep -E "generatePopularityBundle|onTemplateCreated"
```

### Check Cloud Functions Logs
```bash
# All logs
firebase functions:log | grep -E "generatePopularityBundle|onTemplateCreated"

# Just errors
firebase functions:log | grep ERROR
```

### Check Firestore Documents
```bash
# Via Firebase CLI (if available)
firebase firestore:get exercise_popularity

# Via Console UI
https://console.firebase.google.com/project/gymprogressapp-184bc/firestore/data/~2Fexercise_popularity
```

### Check Storage Bundle
```bash
# Via Console UI
https://console.firebase.google.com/project/gymprogressapp-184bc/storage

# Look for: /bundles/latest.bundle
```

---

## 📊 Expected Metrics

### Bundle Size
- **5 exercises**: ~5KB
- **100 exercises**: ~50KB
- **1000 exercises**: ~100KB

### Cloud Function Costs (Monthly)
- **generatePopularityBundle**: ~$0.01 (30 executions × 1s × $0.0000004/GB-second)
- **onTemplateCreated**: ~$0.01 (100 template creations × avg cost)
- **Total**: ~$0.03/month (well within free tier)

### Bundle Download Costs
- **Zero** - Bundles are cached for 24h, no Firestore reads

---

## ⚠️ Known Issues

### Issue 1: Bundle Not Generated
**Symptoms**: Storage shows no `/bundles/latest.bundle` file

**Causes**:
- No documents in `exercise_popularity` collection
- Scheduled function not triggered yet (wait until 3am)
- Function error (check logs)

**Solution**:
1. Create test data (Step 1)
2. Manually trigger function (Step 2 Option B)
3. Check logs for errors

### Issue 2: Flutter App Not Downloading Bundle
**Symptoms**: Cache remains empty, no log messages

**Causes**:
- Bundle doesn't exist in Storage
- Firebase Storage rules incorrect
- Network error

**Solution**:
1. Verify bundle exists in Storage
2. Check Storage rules allow read
3. Check network connectivity
4. Force sync: `ref.read(exercisePopularityForceSyncProvider)`

### Issue 3: Search Boost Not Working
**Symptoms**: Popular exercises don't rank higher

**Causes**:
- Cache not populated
- Boost calculation error
- Search service not using cache

**Solution**:
1. Verify cache has data: `cache.getStats()`
2. Check boost calculation: run boost tests
3. Verify `ExerciseSearchService` receives cache in constructor

---

## ✅ Success Criteria

System is working correctly when:

- [x] Cloud Functions deployed (`firebase functions:list`)
- [ ] Test data exists in Firestore (`exercise_popularity` collection)
- [ ] Bundle generated in Storage (`/bundles/latest.bundle`)
- [ ] Flutter app downloads bundle on launch
- [ ] Cache populated with popularity data
- [ ] Popular exercises rank higher in search results
- [ ] Template creation increments popularity counts
- [x] All unit tests passing (9/9 cache + boost formula)

---

## 📝 Next Steps

1. **Create test data** in Firebase Console (Step 1)
2. **Trigger bundle generation** manually or wait until 3am (Step 2)
3. **Verify bundle** in Firebase Storage (Step 3)
4. **Test Flutter app** downloads and uses bundle (Step 4-5)
5. **Test trigger** by creating template (Step 6)

**After successful testing:**
- ✅ Mark feature as production-ready
- ✅ Monitor costs in Firebase Console
- ✅ Update `docs/INDEX.md` with implementation status

---

**Last Updated**: 2026-02-10
**Status**: Ready for Manual Testing
