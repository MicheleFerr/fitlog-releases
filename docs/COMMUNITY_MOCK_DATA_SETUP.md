# 🏋️ Community Mock Data Setup Guide

## 📊 Overview

Complete setup for testing Community Discovery & Search with realistic mock data.

**What's included:**
- ✅ **Admin-Only Restriction**: Community feature restricted to admins
- ✅ **Mock Data Generator**: 20+ realistic contributions
- ✅ **Firestore Seeder Script**: Populate Firebase with mock data
- ✅ **Comprehensive Coverage**: All contribution types, statuses, difficulties

---

## 🎯 Features Implemented

### 1️⃣ Admin-Only Restriction

**File**: `lib/features/community/presentation/screens/community_discovery_screen.dart`

**What it does:**
- Checks `userProfile.isAdmin` before showing community
- Non-admin users see "Admin Only" screen with explanation
- Admin users see badge in AppBar

**How it works:**
```dart
final userProfileAsync = ref.watch(userProfileProvider);

if (userProfile == null || !userProfile.isAdmin) {
  return _buildAdminOnlyScreen(context); // Shows admin-only message
}

// Admin user - show full community discovery
```

### 2️⃣ Mock Data Generator

**File**: `lib/features/community/data/mock_community_data.dart`

**Generates 20+ contributions with:**
- 🏋️ **8 Bench Press** contributions (tips, warnings, variants, corrections)
- 🦵 **4 Squat** contributions (technique, warnings, bracing)
- 💪 **3 Deadlift** contributions (setup, safety, form)
- 🏃 **Cardio, Mobility, Nutrition** contributions
- ✅ **Approved** (90%), ⏳ **Pending** (5%), ❌ **Rejected** (5%)

**Realistic metadata:**
- Upvotes: 2-234 (realistic distribution)
- Comments: 0-3 per contribution
- Saves: 0-201 (correlates with quality)
- ViewCount: 45-3421 (popularity simulation)
- Tags: 2-5 relevant tags per contribution
- Author tiers: community, expert, admin
- Quality scores: 0.12-0.99

**Usage:**
```dart
import 'package:gymbro_flutter_new/features/community/data/mock_community_data.dart';

// Get all mock contributions
final allContributions = MockCommunityData.generateMockContributions();

// Get by status
final approved = MockCommunityData.getByStatus(ContributionStatus.approved);
final pending = MockCommunityData.getByStatus(ContributionStatus.pending);

// Get by exercise
final benchPress = MockCommunityData.getByExercise('bench_press');

// Get top rated (upvotes > 100)
final topRated = MockCommunityData.getTopRated();

// Get trending (recent + high engagement)
final trending = MockCommunityData.getTrending();
```

### 3️⃣ Firestore Seeder Script

**File**: `scripts/seed_community_data.dart`

**What it does:**
- Reads mock data from `MockCommunityData`
- Uploads to Firestore `community_contributions` collection
- Creates sample user contribution stats
- Handles duplicate detection (idempotent - safe to run multiple times)

---

## 🚀 Setup Instructions

### Step 1: Run Seeder Script

```bash
# From project root
dart scripts/seed_community_data.dart
```

**Expected output:**
```
🏋️ GymBro TrackLog - Community Data Seeder
============================================================

⚠️  WARNING: This will populate Firestore with mock data.
   Collection: community_contributions
   Documents: ~20+ contributions

Continue? (y/n): y

🔥 Initializing Firebase...
✅ Firebase initialized

📊 Generating mock contributions...
   Generated: 21 contributions

📤 Uploading to Firestore...
   ✅ Uploaded: mock_contrib_001 - Perfect Elbow Position for Maximum Po...
   ✅ Uploaded: mock_contrib_002 - How to Create a Safe Lower Back Arch...
   ...

============================================================
📊 Summary:
   ✅ Uploaded: 21 contributions
   ⏭️  Skipped: 0 contributions (already exist)

👤 Creating sample user contribution stats...
   ✅ Stats created for: mock_user_001
   ✅ Stats created for: mock_user_002
   ✅ Stats created for: mock_user_008

🎉 Seeding complete!
```

### Step 2: Set Your User as Admin

**Option A: Firebase Console (Recommended)**
1. Open Firebase Console: https://console.firebase.google.com
2. Navigate to: **Firestore Database**
3. Collection: **users**
4. Find your user document (your UID)
5. Add field:
   - **Field name**: `isAdmin`
   - **Type**: boolean
   - **Value**: `true`
6. Save

**Option B: Firestore Rules (Development Only)**
```javascript
// ⚠️ DEVELOPMENT ONLY - DO NOT USE IN PRODUCTION
match /users/{userId} {
  allow write: if request.auth != null; // Allow any authenticated user to write
}
```

### Step 3: Test Community Discovery

1. **Restart your app** (hot restart won't work - need full restart)
2. Navigate to: **Community Discovery**
3. You should see:
   - ✅ "Admin" badge in AppBar
   - ✅ All 20+ mock contributions
   - ✅ Search, filters, sorting working
   - ✅ Save/unsave functionality
   - ✅ Different contribution types (tips, warnings, corrections)

**If you DON'T see contributions:**
- Check Firestore Console: `community_contributions` collection should exist
- Check user profile: `isAdmin = true` exists
- Check console logs for errors
- Try full app restart (not hot restart)

### Step 4: Test Non-Admin Experience

1. Set `isAdmin = false` in Firestore (your user document)
2. Restart app
3. Navigate to Community Discovery
4. You should see:
   - ❌ No contributions
   - ℹ️ "Admin Only" screen with shield icon
   - ℹ️ Explanation message

---

## 📊 Mock Data Breakdown

### Contribution Types Distribution

| Type | Count | Description |
|------|-------|-------------|
| **Tip** | 8 | Helpful advice and techniques |
| **Warning** | 5 | Safety critical information |
| **Technique** | 3 | Form and execution corrections |
| **Correction** | 3 | Myth-busting and info corrections |
| **Variant** | 1 | Exercise alternatives |
| **Translation** | 1 | Language translations |

### Status Distribution

| Status | Count | Purpose |
|--------|-------|---------|
| **Approved** | 18 (85%) | Live contributions ready for users |
| **Pending** | 2 (10%) | Awaiting admin review |
| **Rejected** | 1 (5%) | Example of rejected contribution |

### Exercise Coverage

| Exercise | Contributions | Topics Covered |
|----------|---------------|----------------|
| **Bench Press** | 8 | Elbow position, arch, grip, safety, breathing, variants |
| **Squat** | 4 | Depth, knee health, bracing, bar position |
| **Deadlift** | 3 | Setup, back safety, lower back rounding |
| **Overhead Press** | 1 | Shoulder impingement prevention |
| **Pull-Up** | 1 | Scapular depression and lat activation |
| **Rowing** | 1 | Cheating vs proper form |
| **Running** | 1 | Shin splints prevention |
| **Mobility** | 1 | Hip mobility for squat depth |
| **Nutrition** | 1 | Protein timing myth-busting |

### Quality Distribution

| Quality Tier | Count | Upvotes Range | Saves Range |
|--------------|-------|---------------|-------------|
| **Top Rated** (featured) | 5 | 143-234 | 102-201 |
| **High Quality** | 8 | 76-127 | 54-89 |
| **Good Quality** | 5 | 58-94 | 38-68 |
| **Pending/Low** | 3 | 2-12 | 0-8 |

---

## 💰 Firestore Cost Analysis

### Seeding Cost (One-time)

```
Upload 21 contributions = 21 writes
Create 3 user stats = 3 writes
Total = 24 writes = $0.000072 (~$0.00007)
```

**Negligible cost** - less than $0.001 USD

### Reading Cost (Per User Session)

**Scenario**: User opens Community Discovery screen

```
1. searchResultsProvider stream: 60 reads (over-fetch 3x)
2. savedContributionIdsProvider: 1 read
Total per session = 61 reads = $0.00018
```

**10 sessions/day** = 610 reads/day = $0.0018/day = **$0.054/month per user**

See `docs/plans/2025-11-05-community-discovery-search.md` for full cost analysis.

---

## 🧪 Testing Checklist

### Admin User Testing

- [ ] ✅ See "Admin" badge in AppBar
- [ ] ✅ See all 20+ contributions in list
- [ ] ✅ Search works (try "bench press", "shoulder", "safety")
- [ ] ✅ Filters work (type, difficulty, sort)
- [ ] ✅ Save/unsave contributions (heart icon)
- [ ] ✅ View contribution details (tap card)
- [ ] ✅ Comments visible on contributions
- [ ] ✅ Upvote/downvote counts accurate
- [ ] ✅ Featured contributions marked with star
- [ ] ✅ Rejected contribution shows red badge

### Non-Admin User Testing

- [ ] ✅ See "Admin Only" screen
- [ ] ✅ Shield icon displayed
- [ ] ✅ Explanation message clear
- [ ] ✅ No errors in console
- [ ] ✅ Can navigate back

### Edge Cases

- [ ] ✅ Search empty query returns all
- [ ] ✅ Search no results shows empty state
- [ ] ✅ Filters applied correctly
- [ ] ✅ Sorting changes order (helpful, recent, saved, trending)
- [ ] ✅ Pull-to-refresh works
- [ ] ✅ Scroll performance good (21 items)

---

## 🔧 Troubleshooting

### Issue: "No contributions visible"

**Solutions:**
1. Check Firestore Console: `community_contributions` collection exists?
2. Check user document: `isAdmin = true` exists?
3. Check console logs: Any Firestore permission errors?
4. Try: Full app restart (not hot restart)
5. Try: Run seeder script again (idempotent, safe)

### Issue: "Admin badge not showing"

**Solutions:**
1. Check: `userProfileProvider` returning user with `isAdmin = true`
2. Check: Full app restart (hot restart won't update providers)
3. Debug: Add `print(userProfile?.isAdmin)` in build method

### Issue: "Seeder script fails"

**Solutions:**
1. Check: Firebase initialized correctly (`firebase_options.dart` exists)
2. Check: Internet connection active
3. Check: Firestore security rules allow writes
4. Try: Run with verbose logging: `dart scripts/seed_community_data.dart --verbose`

### Issue: "Search not working"

**Cause:** Client-side search, not Firestore query
**Check:** Contributions fetched first (loading indicator disappears)

---

## 📚 Related Documentation

- **Community Feature Plan**: `docs/plans/2025-11-05-community-discovery-search.md`
- **Firestore Cost Analysis**: See "Costo Mensile Stimato" in plan
- **Architecture**: Clean Architecture + Riverpod
- **Testing**: Use Patrol for E2E tests

---

## 🎯 Next Steps (Production)

### Remove Admin-Only Restriction

**File**: `lib/features/community/presentation/screens/community_discovery_screen.dart`

**Remove:**
```dart
// DELETE THIS ENTIRE BLOCK:
final userProfileAsync = ref.watch(userProfileProvider);
return userProfileAsync.when(
  data: (userProfile) {
    if (userProfile == null || !userProfile.isAdmin) {
      return _buildAdminOnlyScreen(context);
    }
    // ... rest
  },
);
```

**Replace with:**
```dart
@override
Widget build(BuildContext context) {
  final searchResults = ref.watch(searchResultsProvider);
  final activeFilters = ref.watch(activeFiltersProvider);

  return Scaffold(
    // ... normal build
  );
}
```

### Add Real User Contributions

**Replace mock data with:**
1. User submission form (already implemented)
2. Admin review workflow (already implemented)
3. Community voting system (already implemented)

---

## ✅ Summary

**What you have now:**
- ✅ Admin-only restriction (easy to remove for production)
- ✅ 20+ realistic mock contributions for testing
- ✅ Firestore seeder script (one command setup)
- ✅ Full community discovery UI working

**Cost:**
- Seeding: < $0.001 USD (one-time)
- Testing: ~$0.054/month per active user
- Production: Scale linearly with users

**Ready to test!** 🎉
