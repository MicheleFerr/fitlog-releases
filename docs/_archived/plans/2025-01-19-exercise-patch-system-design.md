# 🏋️ Exercise Patch System - Complete Design Document

**Created**: 2025-01-19
**Author**: Claude Code (AI Assistant) + Michele
**Status**: ✅ Ready for Implementation
**Complexity**: HIGH (Multi-layer: Hive + Firestore + Cloud Functions)
**Estimated Time**: 5-7 days (full implementation + testing)

---

## 📋 Table of Contents

1. [Problem Statement](#problem-statement)
2. [Solution Architecture](#solution-architecture)
3. [Data Flow](#data-flow)
4. [Implementation Details](#implementation-details)
5. [Security & Safety](#security--safety)
6. [Edge Cases Handled](#edge-cases-handled)
7. [Testing Strategy](#testing-strategy)
8. [Rollout Plan](#rollout-plan)

---

## 🎯 Problem Statement

### Current State
- ❌ Users report exercise errors via `exercise_feedback` collection
- ❌ Admin reviews in dashboard but **NO instant fix for reporting user**
- ❌ Fix requires manual edit + "Publish New Version" → users wait days/weeks
- ❌ No community-driven corrections (crowdsourcing wasted)

### Desired State
- ✅ User reports error → **Patch applied INSTANTLY (local Hive cache)**
- ✅ User correction sent to admin for review
- ✅ Admin approves → **Patch becomes global** (Firestore update)
- ✅ Next "Publish" → Exercise permanently fixed for all users
- ✅ TTL 30 days → Auto-cleanup expired patches (no admin burden)

---

## 🏗️ Solution Architecture

### **Option Selected: B + Conflict Resolution A+D**

- **B**: Full Integration (Hive local + Firestore global + Admin approval)
- **A+D**: Server Wins (admin priority) + TTL 30 days (auto-cleanup)

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER DEVICE (Flutter App)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│ ┌─────────────┐         ┌──────────────┐      ┌──────────────┐  │
│ │  UI Layer   │────────▶│ Patch Manager│◀─────│  Hive Cache  │  │
│ │ (Report)    │         │  Service     │      │(exercise_box)│  │
│ └─────────────┘         └──────────────┘      └──────────────┘  │
│         ▲                      │                       ▲         │
│         │                      ▼                       │         │
│         │              ┌──────────────┐                │         │
│         │              │ Sync Service │                │         │
│         │              │  (Firestore) │                │         │
│         │              └──────────────┘                │         │
│         │                      │                       │         │
│         └──────────────────────┼───────────────────────┘         │
│                                │                                 │
└────────────────────────────────┼─────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FIREBASE (Backend)                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│ ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│ │ exercises_it │  │exercises_en  │  │exercise_     │            │
│ │ (Collection) │  │ (Collection) │  │patches       │            │
│ │   (MAIN)     │  │   (MAIN)     │  │ (NEW!)       │            │
│ └──────┬───────┘  └──────┬───────┘  │ [PENDING]    │            │
│        │                 │           │ [APPROVED]   │            │
│        │                 │           │ [REJECTED]   │            │
│        │                 │           │ [EXPIRED]    │            │
│        │                 │           └──────┬───────┘            │
│        │                 │                  │                    │
│        │       ┌─────────┴──────────┐       │                    │
│        │       │  Admin Dashboard   │       │                    │
│        └───────│  (Review Patches)  │◀──────┘                    │
│                └──────────┬─────────┘                            │
│                           │                                      │
│                           ▼                                      │
│           ┌────────────────────────────┐                         │
│           │ Cloud Functions (Triggers) │                         │
│           ├────────────────────────────┤                         │
│           │ 1. applyApprovedPatches()  │ ← onUpdate trigger     │
│           │ 2. cleanupExpiredPatches() │ ← Daily schedule (2am) │
│           └────────────────────────────┘                         │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow (Step-by-Step)

### **Timeline: User Reports Error**

#### **T0: User Detects Error**
```
User sees: "Bench Press" (wrong Italian translation)
User taps: "Report Error" button on exercise card
```

#### **T1: User Submits Patch**
```dart
// User fills form:
// - Field: "nome"
// - Current: "Bench Press"
// - Correct: "Panca Piana"
// - Reason: "Wrong Italian translation"

// PatchManagerService.submitPatch() called:
final patch = ExercisePatch(
  id: 'ex123_1704067200000',
  exerciseId: 'exercise_123',
  userId: 'user_456',
  fieldName: 'nome',
  oldValue: 'Bench Press',      // Current (wrong)
  newValue: 'Panca Piana',      // User correction
  originalValue: 'Bench Press', // Original from Firestore
  reason: 'Wrong Italian translation',
  status: PatchStatus.pending,
  createdAt: DateTime.now(),
  expiresAt: DateTime.now().add(Duration(days: 30)), // TTL
  version: 5, // Exercise version at patch creation
);

// 1. Upload to Firestore (exercise_patches collection)
await _firestore.collection('exercise_patches').doc(patch.id).set(patch.toMap());

// 2. Apply IMMEDIATELY to Hive (user-only view)
final hiveExercise = hiveBox.get('exercise_123');
hiveExercise['nome'] = 'Panca Piana'; // ← INSTANT FIX
hiveExercise['_hasLocalPatch'] = true; // Flag
await hiveBox.put('exercise_123', hiveExercise);

// 3. UI update
notifyListeners(); // Exercise card now shows "Panca Piana" ✅

// 4. Show success message
SnackBarService.showSuccess(context,
  'Correzione applicata! Verrà revisionata dall\'admin entro 30 giorni.');
```

**Result**: User immediately sees "Panca Piana" in the app (Hive cached).

---

#### **T2: Admin Receives Notification**

```dart
// DatabaseManagerScreen updated to show badge:
// "Exercise Patches (3 pending)"

// Admin taps → ExercisePatchReviewScreen

// UI shows:
┌─────────────────────────────────────────────┐
│ PENDING PATCH #1 (25 days left)             │
├─────────────────────────────────────────────┤
│ Exercise ID: exercise_123                   │
│ Field: nome                                 │
│                                             │
│ ❌ Current: "Bench Press"                   │
│ ✅ Proposed: "Panca Piana"                  │
│                                             │
│ Reason: "Wrong Italian translation"         │
│ Reported by: user_456 (5⭐ rating)          │
│ Created: 2025-01-15 10:30                   │
│ Expires: 2025-02-14 10:30                   │
└─────────────────────────────────────────────┘
[❌ REJECT] [💬 COMMENT] [✅ APPROVE]
```

---

#### **T3: Admin Approves Patch**

```dart
// Admin clicks "APPROVE" button

// Frontend updates Firestore:
await _firestore.collection('exercise_patches').doc(patchId).update({
  'status': 'APPROVED',
  'approvedAt': FieldValue.serverTimestamp(),
  'approvedBy': currentAdminUid,
});

// ⚡ CLOUD FUNCTION TRIGGERED AUTOMATICALLY ⚡
// (See Cloud Functions section below)
```

**Cloud Function: `applyApprovedPatches`** (auto-triggered)
```javascript
exports.applyApprovedPatches = functions.firestore
  .document('exercise_patches/{patchId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger on status change to APPROVED
    if (before.status !== 'APPROVED' && after.status === 'APPROVED') {
      const patchId = context.params.patchId;
      const patch = after;

      console.log(`📝 Applying approved patch: ${patchId}`);

      // 1. Get exercise from Firestore
      const collectionName = patch.language === 'it' ? 'exercises_it' : 'exercises_en';
      const exerciseRef = admin.firestore()
        .collection(collectionName)
        .doc(patch.exerciseId);

      const exerciseSnap = await exerciseRef.get();

      if (!exerciseSnap.exists) {
        console.error(`❌ Exercise ${patch.exerciseId} not found`);
        return;
      }

      const exercise = exerciseSnap.data();

      // 2. VERSION CHECK (prevent applying outdated patches)
      if (exercise.version !== patch.version) {
        console.warn(`⚠️ Version mismatch! Exercise: ${exercise.version}, Patch: ${patch.version}`);

        // Auto-reject outdated patch
        await change.after.ref.update({
          status: 'REJECTED',
          rejectReason: 'AUTO_REJECTED_VERSION_MISMATCH',
          rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
          adminNote: 'Exercise was modified after patch creation. Please submit a new patch.',
        });

        console.log(`🔄 Patch auto-rejected due to version mismatch`);
        return; // Exit without applying
      }

      // 3. Apply patch to Firestore exercise
      const updatedExercise = {
        ...exercise,
        [patch.fieldName]: patch.newValue, // ← MERGE
        patchedAt: admin.firestore.FieldValue.serverTimestamp(),
        patchVersion: patch.version,
        version: exercise.version + 1, // Increment version
      };

      await exerciseRef.update(updatedExercise);
      console.log(`✅ Patch applied to ${collectionName}/${patch.exerciseId}`);

      // 4. Update metadata (for next publish changelog)
      await admin.firestore()
        .collection('exercises_metadata')
        .doc('version_info')
        .update({
          changelog: admin.firestore.FieldValue.arrayUnion(
            `User correction applied: ${patch.reason} (${patch.fieldName})`
          ),
          lastPatchApplied: admin.firestore.FieldValue.serverTimestamp(),
          pendingPatchCount: admin.firestore.FieldValue.increment(-1),
        });

      // 5. Log approval for audit trail
      await admin.firestore()
        .collection('admin_logs')
        .add({
          action: 'PATCH_APPROVED',
          patchId: patchId,
          exerciseId: patch.exerciseId,
          fieldName: patch.fieldName,
          approvedBy: patch.approvedBy,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

      console.log(`🎉 Patch ${patchId} fully applied!`);
    }
  });
```

**Result**: Exercise in Firestore (`exercises_it/exercise_123`) now has `nome: "Panca Piana"`.

---

#### **T4: TTL Cleanup (30 Days Later)**

**Cloud Function: `cleanupExpiredPatches`** (scheduled daily at 2am)
```javascript
exports.cleanupExpiredPatches = functions.pubsub
  .schedule('every day 02:00')
  .timeZone('Europe/Rome')
  .onRun(async (context) => {
    console.log('🧹 Starting expired patches cleanup...');

    const now = admin.firestore.Timestamp.now();
    const batch = admin.firestore().batch();

    // Find all PENDING patches with expiresAt < now
    const snapshot = await admin.firestore()
      .collection('exercise_patches')
      .where('status', '==', 'PENDING')
      .where('expiresAt', '<', now)
      .get();

    console.log(`Found ${snapshot.size} expired patches`);

    // Mark as EXPIRED (don't delete for audit trail)
    snapshot.docs.forEach(doc => {
      batch.update(doc.ref, {
        status: 'EXPIRED',
        expiredAt: admin.firestore.FieldValue.serverTimestamp(),
        autoExpired: true,
      });
    });

    await batch.commit();

    console.log(`✅ Marked ${snapshot.size} patches as EXPIRED`);

    // Update metadata
    await admin.firestore()
      .collection('exercises_metadata')
      .doc('version_info')
      .update({
        lastCleanupAt: admin.firestore.FieldValue.serverTimestamp(),
        expiredPatchCount: admin.firestore.FieldValue.increment(snapshot.size),
      });

    return null;
  });
```

**User-side sync** (when app detects EXPIRED patch):
```dart
// Periodic sync checks for status changes
Stream<List<ExercisePatch>> watchUserPatches() {
  return _firestore
    .collection('exercise_patches')
    .where('userId', isEqualTo: currentUserId)
    .snapshots()
    .map((snapshot) {
      final patches = snapshot.docs
        .map((doc) => ExercisePatch.fromMap(doc.data()))
        .toList();

      // Remove EXPIRED patches from Hive
      for (final patch in patches.where((p) => p.status == PatchStatus.expired)) {
        _removeLocalPatch(patch.exerciseId, patch.fieldName);
      }

      return patches;
    });
}

Future<void> _removeLocalPatch(String exerciseId, String fieldName) async {
  final exercise = hiveBox.get('exercise_$exerciseId');

  // Revert to original Firestore value (download if needed)
  final firestoreExercise = await _firestore
    .collection('exercises_it')
    .doc(exerciseId)
    .get();

  exercise[fieldName] = firestoreExercise.data()?[fieldName];
  exercise['_hasLocalPatch'] = false;

  await hiveBox.put('exercise_$exerciseId', exercise);
}
```

---

#### **T5: Next "Publish New Version"**

```dart
// Admin clicks "Publish New Version" in DatabaseManagerScreen
// ExercisePublishService.publishNewVersion() executes:

// 1. Load exercises from Firestore (already includes approved patches!)
final exercisesIt = await downloadFromFirestore('exercises_it');
// exercisesIt['exercise_123'].nome = "Panca Piana" ← PATCH ALREADY IN!

// 2. Upload to Firestore (no change needed, already there)

// 3. Update version metadata
await _firestore.collection('exercises_metadata').doc('version_info').update({
  versionCode: FieldValue.increment(1),
  versionName: '1.2.6',
  changelog: [
    'User correction applied: Wrong Italian translation (nome)',
    // ...other changes
  ],
  lastPublishAt: FieldValue.serverTimestamp(),
});

// 4. All users download v1.2.6 → get "Panca Piana" permanently
```

---

## 🛡️ Security & Safety

### **Firestore Security Rules**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isAdmin() {
      return isAuthenticated()
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Exercise Patches Collection (NEW!)
    match /exercise_patches/{patchId} {
      // CREATE: Only authenticated users, must match userId
      allow create: if isAuthenticated()
                    && request.resource.data.userId == request.auth.uid
                    && request.resource.data.status == 'PENDING'; // Can only create PENDING

      // READ: Owner can read own patches, Admin can read all
      allow read: if isAuthenticated()
                  && (resource.data.userId == request.auth.uid || isAdmin());

      // UPDATE: Only admin can approve/reject
      allow update: if isAdmin()
                    && request.resource.data.userId == resource.data.userId; // Can't change userId

      // DELETE: Never allow (audit trail preservation)
      allow delete: if false;
    }

    // Exercises Collections (existing, unchanged)
    match /exercises_it/{exerciseId} {
      allow read: if true; // Public read
      allow write: if isAdmin(); // Only admin can modify
    }

    match /exercises_en/{exerciseId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // Metadata Collection
    match /exercises_metadata/{docId} {
      allow read: if true; // Public read (version checks)
      allow write: if isAdmin();
    }

    // Admin Logs Collection
    match /admin_logs/{logId} {
      allow read: if isAdmin();
      allow write: if isAdmin(); // Only Cloud Functions write here
    }
  }
}
```

### **Safety Mechanisms**

1. ✅ **Version Check**: Prevents applying outdated patches (auto-reject if exercise changed)
2. ✅ **Duplicate Prevention**: Can't submit multiple pending patches for same field
3. ✅ **TTL Auto-Cleanup**: Expired patches marked (not deleted) for audit trail
4. ✅ **Audit Trail**: All approvals logged in `admin_logs` collection
5. ✅ **User Isolation**: Users can only read/create their own patches
6. ✅ **Admin-Only Approval**: Only admins can change patch status

---

## 🧩 Edge Cases Handled

### **Case 1: Multiple Patches on Same Exercise**
```
User submits patch #1: nome = "Panca Piana"
User tries patch #2: nome = "Distensioni su Panca"

→ BLOCKED with exception:
"Hai già una patch pending per questo campo. Aspetta approvazione prima di crearne un'altra."
```

**Implementation**:
```dart
// In submitPatch(), check for existing pending
final existing = await _firestore
  .collection('exercise_patches')
  .where('exerciseId', isEqualTo: exerciseId)
  .where('fieldName', isEqualTo: fieldName)
  .where('userId', isEqualTo: userId)
  .where('status', isEqualTo: 'PENDING')
  .limit(1)
  .get();

if (existing.docs.isNotEmpty) {
  throw PatchAlreadyExistsException('Duplicate pending patch');
}
```

---

### **Case 2: Exercise Modified Before Patch Approved**
```
T0: User patch → nome: "Bench Press" → "Panca Piana" (version 5)
T1: Admin publishes v1.2.5 → exercise renamed to "Barbell Bench Press" (version 6)
T2: Admin approves patch → CONFLICT! Version mismatch

→ Cloud Function AUTO-REJECTS patch:
status = REJECTED
rejectReason = "AUTO_REJECTED_VERSION_MISMATCH"
adminNote = "Exercise was updated after your patch. Please submit new one."
```

**Implementation**: See Cloud Function code in T3 (version check).

---

### **Case 3: Offline User Submits Patch**
```
User offline → Hive patch applied locally ✅
Firestore write queued by Flutter offline persistence ✅
When online → Firestore sync completes ✅
```

**No special handling needed** - Flutter Firestore SDK handles offline writes automatically.

---

### **Case 4: User Reinstalls App**
```
Hive cache cleared → Patches lost locally ❌
BUT: Patches still in Firestore ✅
On redownload exercises → Check for APPROVED patches:

final userPatches = await _firestore
  .collection('exercise_patches')
  .where('userId', isEqualTo: userId)
  .where('status', isEqualTo: 'APPROVED')
  .get();

// Reapply approved patches to Hive on download
for (final patch in userPatches) {
  await applyPatchLocally(patch.exerciseId, patch.fieldName, patch.newValue);
}
```

---

### **Case 5: Admin Rejects Patch**
```
Admin clicks "REJECT" → Firestore updated:
status = REJECTED
rejectedAt = timestamp
rejectedBy = admin_uid

User device syncs → Detects REJECTED status:
→ Remove local Hive patch
→ Revert to Firestore original value
→ Show notification: "La tua patch è stata rifiutata. Motivo: [admin note]"
```

---

## 🧪 Testing Strategy

### **Phase 1: Manual Testing (Dev Firestore Project)**

**Setup**:
```bash
# Create separate Firebase project for testing
firebase projects:create gymbro-dev

# Deploy Cloud Functions to dev
firebase deploy --only functions --project gymbro-dev

# Point Flutter app to dev project
# lib/firebase_options_dev.dart
```

**Test Cases**:
1. ✅ User submits patch → Hive updated instantly
2. ✅ Firestore receives patch document
3. ✅ Admin sees patch in review screen
4. ✅ Admin approves → Cloud Function triggers → Exercise updated
5. ✅ Admin rejects → User receives notification
6. ✅ Duplicate patch blocked
7. ✅ Version mismatch auto-rejects
8. ✅ TTL cleanup (simulate 30 days later with manual Firestore edit)

---

### **Phase 2: Integration Testing**

**Test Workflow**:
```dart
// integration_test/patch_system_test.dart
testWidgets('Full patch workflow', (tester) async {
  // 1. User login
  await tester.pumpWidget(MyApp());
  await loginAsUser();

  // 2. Navigate to exercise detail
  await tester.tap(find.text('Bench Press'));
  await tester.pumpAndSettle();

  // 3. Submit patch
  await tester.tap(find.byIcon(Icons.flag));
  await tester.enterText(find.byKey('patch_new_value'), 'Panca Piana');
  await tester.tap(find.text('Submit'));
  await tester.pumpAndSettle();

  // 4. Verify Hive cache updated
  final hiveExercise = hiveBox.get('exercise_123');
  expect(hiveExercise['nome'], 'Panca Piana');

  // 5. Verify Firestore document created
  final patchDoc = await FirebaseFirestore.instance
    .collection('exercise_patches')
    .where('exerciseId', isEqualTo: 'exercise_123')
    .get();
  expect(patchDoc.docs.length, 1);

  // 6. Admin approves (simulate)
  await patchDoc.docs.first.reference.update({'status': 'APPROVED'});
  await Future.delayed(Duration(seconds: 5)); // Wait for Cloud Function

  // 7. Verify exercise updated in Firestore
  final exerciseDoc = await FirebaseFirestore.instance
    .collection('exercises_it')
    .doc('exercise_123')
    .get();
  expect(exerciseDoc.data()?['nome'], 'Panca Piana');
});
```

---

### **Phase 3: Load Testing (Optional)**

**Simulate 1000 concurrent patches**:
```dart
// scripts/load_test_patches.dart
void main() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  for (int i = 0; i < 1000; i++) {
    final patchRef = firestore.collection('exercise_patches').doc();
    batch.set(patchRef, {
      'exerciseId': 'exercise_${i % 100}',
      'userId': 'user_$i',
      'fieldName': 'nome',
      'oldValue': 'Test $i',
      'newValue': 'Patch $i',
      'status': 'PENDING',
      'createdAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(Duration(days: 30)).toIso8601String(),
    });
  }

  await batch.commit();
  print('✅ Created 1000 test patches');
}
```

**Expected**: Cloud Functions handle load without throttling (Firestore auto-scales).

---

## 🚀 Rollout Plan

### **Phase 1: Foundation (Day 1-2)**
- [ ] Create `ExercisePatch` model (Freezed + JsonSerializable)
- [ ] Implement `PatchManagerService` (Hive + Firestore integration)
- [ ] Add Firestore security rules
- [ ] Unit tests for model + service

### **Phase 2: Cloud Functions (Day 2-3)**
- [ ] Setup Firebase Cloud Functions project
- [ ] Implement `applyApprovedPatches` (onUpdate trigger)
- [ ] Implement `cleanupExpiredPatches` (scheduled function)
- [ ] Deploy to dev Firebase project
- [ ] Manual testing with Firestore console

### **Phase 3: Admin UI (Day 3-4)**
- [ ] Create `ExercisePatchReviewScreen`
- [ ] Add badge counter to DatabaseManagerScreen
- [ ] Implement approve/reject buttons
- [ ] Add "My Patches" screen for users (view status)
- [ ] Integration testing

### **Phase 4: User UI (Day 4)**
- [ ] Add "Report Error" button to exercise cards
- [ ] Create patch submission dialog
- [ ] Implement Hive local patch application
- [ ] Add success/error notifications
- [ ] E2E testing (user → admin → publish)

### **Phase 5: Sync & Conflict Resolution (Day 5)**
- [ ] Implement smart merge logic
- [ ] Handle version mismatch detection
- [ ] Test offline scenarios
- [ ] Test reinstall scenarios

### **Phase 6: Polish & Deployment (Day 6-7)**
- [ ] Documentation updates (INDEX.md, CLAUDE.md)
- [ ] Final integration tests
- [ ] Deploy Cloud Functions to production
- [ ] Deploy Flutter app update
- [ ] Monitor Firestore metrics

---

## 📊 Firestore Schema

```
firestore/
│
├── exercises_it/                    [MAIN - Existing]
│   └── exercise_123/
│       ├── nome: "Panca Piana"      ← Patch applied here
│       ├── attrezzatura: "Bilanciere"
│       ├── imageUrl: "..."
│       ├── version: 6               ← Incremented on patch apply
│       ├── patchedAt: Timestamp     ← When last patch applied
│       └── patchVersion: 5          ← Which patch version
│
├── exercises_en/                    [MAIN - Existing]
│   └── exercise_123/
│       └── ...
│
├── exercise_patches/                [NEW - Patch Management]
│   ├── ex123_1704067200000/
│   │   ├── id: "ex123_1704067200000"
│   │   ├── exerciseId: "exercise_123"
│   │   ├── userId: "user_456"
│   │   ├── fieldName: "nome"
│   │   ├── oldValue: "Bench Press"
│   │   ├── newValue: "Panca Piana"
│   │   ├── originalValue: "Bench Press"  ← For conflict detection
│   │   ├── reason: "Wrong translation"
│   │   ├── status: "APPROVED"           ← PENDING/APPROVED/REJECTED/EXPIRED
│   │   ├── language: "it"               ← it or en
│   │   ├── createdAt: Timestamp
│   │   ├── expiresAt: Timestamp         ← T + 30 days
│   │   ├── approvedAt: Timestamp        ← When approved
│   │   ├── approvedBy: "admin_123"      ← Who approved
│   │   ├── rejectedAt: Timestamp?       ← If rejected
│   │   ├── rejectReason: String?        ← Why rejected
│   │   ├── adminNote: String?           ← Admin comment
│   │   ├── version: 5                   ← Exercise version at creation
│   │   └── autoExpired: false           ← TTL cleanup flag
│
├── exercises_metadata/              [MAIN - Existing]
│   └── version_info/
│       ├── versionCode: 126
│       ├── versionName: "1.2.6"
│       ├── totalExercisesIt: 450
│       ├── totalExercisesEn: 450
│       ├── lastPublishAt: Timestamp
│       ├── lastPatchApplied: Timestamp  ← NEW
│       ├── pendingPatchCount: 3         ← NEW (for admin badge)
│       ├── expiredPatchCount: 12        ← NEW (audit)
│       ├── changelog: [
│       │   "User correction: Wrong translation (nome)",
│       │   "Added 10 new exercises",
│       │ ]
│       └── lastCleanupAt: Timestamp     ← NEW (TTL cleanup tracking)
│
└── admin_logs/                      [NEW - Audit Trail]
    └── patch_approvals/
        ├── approval_2024_01_19_1/
        │   ├── action: "PATCH_APPROVED"
        │   ├── patchId: "ex123_1704067200000"
        │   ├── exerciseId: "exercise_123"
        │   ├── fieldName: "nome"
        │   ├── approvedBy: "admin_123"
        │   └── timestamp: Timestamp
```

---

## 💾 Hive Schema (Local Cache)

```dart
// Box: exercise_cache
{
  'exercise_123': {
    'id': 'exercise_123',
    'nome': 'Panca Piana',        // ← Patched value (if patch applied)
    'attrezzatura': 'Bilanciere',
    'imageUrl': '...',
    '_hasLocalPatch': true,       // Flag indicating local patch applied
    '_patchedFields': ['nome'],   // List of patched fields
    '_firestoreVersion': 5,       // Original Firestore version
  }
}

// Box: user_patches_cache (optional, for quick lookup)
{
  'user_456_patches': [
    {
      'exerciseId': 'exercise_123',
      'fieldName': 'nome',
      'status': 'PENDING',
      'createdAt': '2025-01-15T10:30:00Z',
      'expiresAt': '2025-02-14T10:30:00Z',
    }
  ]
}
```

---

## 🔧 Implementation Code Snippets

### **ExercisePatch Model**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_patch.freezed.dart';
part 'exercise_patch.g.dart';

enum PatchStatus {
  pending,
  approved,
  rejected,
  expired,
}

@freezed
class ExercisePatch with _$ExercisePatch {
  const factory ExercisePatch({
    required String id,
    required String exerciseId,
    required String userId,
    required String fieldName,
    required dynamic oldValue,
    required dynamic newValue,
    required dynamic originalValue, // For conflict detection
    required String reason,
    required PatchStatus status,
    required String language, // 'it' or 'en'
    required DateTime createdAt,
    required DateTime expiresAt,
    required int version, // Exercise version at patch creation
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? rejectedAt,
    String? rejectReason,
    String? adminNote,
    @Default(false) bool autoExpired,
  }) = _ExercisePatch;

  factory ExercisePatch.fromJson(Map<String, dynamic> json) =>
      _$ExercisePatchFromJson(json);
}
```

---

### **PatchManagerService**

```dart
class PatchManagerService {
  final FirebaseFirestore _firestore;
  final Box<Map> _hiveBox;
  final String _currentUserId;

  PatchManagerService({
    required FirebaseFirestore firestore,
    required Box hiveBox,
    required String currentUserId,
  })  : _firestore = firestore,
        _hiveBox = hiveBox,
        _currentUserId = currentUserId;

  /// Submit user patch
  Future<void> submitPatch({
    required String exerciseId,
    required String fieldName,
    required dynamic oldValue,
    required dynamic newValue,
    required dynamic originalValue,
    required String reason,
    required String language,
    required int version,
  }) async {
    // 1. Check for existing pending patch
    final existingPending = await _firestore
        .collection('exercise_patches')
        .where('exerciseId', isEqualTo: exerciseId)
        .where('fieldName', isEqualTo: fieldName)
        .where('userId', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'PENDING')
        .limit(1)
        .get();

    if (existingPending.docs.isNotEmpty) {
      throw PatchAlreadyExistsException(
        'Hai già una patch pending per questo campo. '
        'Aspetta che venga approvata/rifiutata prima di crearne un\'altra.',
      );
    }

    // 2. Create patch
    final patchId = '${exerciseId}_${DateTime.now().millisecondsSinceEpoch}';
    final patch = ExercisePatch(
      id: patchId,
      exerciseId: exerciseId,
      userId: _currentUserId,
      fieldName: fieldName,
      oldValue: oldValue,
      newValue: newValue,
      originalValue: originalValue,
      reason: reason,
      status: PatchStatus.pending,
      language: language,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      version: version,
    );

    // 3. Upload to Firestore
    await _firestore
        .collection('exercise_patches')
        .doc(patchId)
        .set(patch.toJson());

    // 4. Apply locally to Hive (instant user feedback)
    await applyPatchLocally(exerciseId, fieldName, newValue);

    // 5. Increment pending count in metadata
    await _firestore
        .collection('exercises_metadata')
        .doc('version_info')
        .update({
      'pendingPatchCount': FieldValue.increment(1),
    });
  }

  /// Apply patch locally to Hive cache
  Future<void> applyPatchLocally(
    String exerciseId,
    String fieldName,
    dynamic newValue,
  ) async {
    final key = 'exercise_$exerciseId';
    final exercise = _hiveBox.get(key) as Map? ?? {};

    exercise[fieldName] = newValue;
    exercise['_hasLocalPatch'] = true;
    exercise['_patchedFields'] = [
      ...(exercise['_patchedFields'] as List? ?? []),
      fieldName,
    ];

    await _hiveBox.put(key, exercise);
  }

  /// Stream user's patches
  Stream<List<ExercisePatch>> streamUserPatches() {
    return _firestore
        .collection('exercise_patches')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs
                .map((doc) => ExercisePatch.fromJson(doc.data()))
                .toList());
  }

  /// Stream pending patches (for admin)
  Stream<List<ExercisePatch>> streamPendingPatches() {
    return _firestore
        .collection('exercise_patches')
        .where('status', isEqualTo: 'PENDING')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs
                .map((doc) => ExercisePatch.fromJson(doc.data()))
                .toList());
  }

  /// Approve patch (admin only)
  Future<void> approvePatch(String patchId) async {
    await _firestore.collection('exercise_patches').doc(patchId).update({
      'status': 'APPROVED',
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': _currentUserId,
    });

    // Cloud Function handles the rest!
  }

  /// Reject patch (admin only)
  Future<void> rejectPatch(String patchId, String reason) async {
    await _firestore.collection('exercise_patches').doc(patchId).update({
      'status': 'REJECTED',
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectReason': reason,
      'approvedBy': _currentUserId, // Who rejected
    });
  }
}

class PatchAlreadyExistsException implements Exception {
  final String message;
  PatchAlreadyExistsException(this.message);

  @override
  String toString() => message;
}
```

---

## 📈 Success Metrics

**Week 1 After Launch**:
- [ ] ≥ 10 patches submitted by users
- [ ] ≥ 5 patches approved by admin
- [ ] 0 critical bugs reported
- [ ] User satisfaction ≥ 4.5/5 (survey)

**Month 1 After Launch**:
- [ ] ≥ 50 patches submitted
- [ ] ≥ 30 patches approved
- [ ] ≥ 1 "Publish New Version" with approved patches
- [ ] Cloud Function costs < $5/month

---

## 🔄 Future Enhancements (v2.0+)

- [ ] **Push Notifications**: FCM alerts when patch approved/rejected
- [ ] **Voting System**: Multiple users can upvote same patch (crowdsourcing)
- [ ] **Image Uploads**: Allow users to upload better exercise images
- [ ] **Video Submissions**: User-contributed exercise demo videos
- [ ] **Reputation System**: Users earn points for approved patches
- [ ] **Automatic Approval**: Trusted users (5+ approved patches) get auto-approval
- [ ] **Localization Sync**: Auto-translate approved IT patches to EN (AI-assisted)

---

## ✅ Final Checklist Before Implementation

- [x] Architecture designed
- [x] Data flow documented
- [x] Security rules specified
- [x] Edge cases identified
- [x] Testing strategy defined
- [x] Rollout plan created
- [ ] Dev Firebase project setup
- [ ] Cloud Functions deployed
- [ ] Flutter implementation started

---

**Next Steps**: Begin with **Phase 1 (Foundation)** → Create ExercisePatch model + PatchManagerService.

**Estimated Completion**: 5-7 days (with testing)

**Risk Level**: 🟡 MEDIUM (Cloud Functions new, but well-documented)

**Complexity**: ⚠️ HIGH (Multi-layer: Hive + Firestore + Cloud Functions)

---

**Document Version**: 1.0
**Last Updated**: 2025-01-19
**Status**: ✅ Ready for Implementation
