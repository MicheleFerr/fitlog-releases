# Firestore Consistency Audit - Task Plan

**Generated**: 2025-01-18 16:45
**Source**: task-master.dev (WebFetch)
**Complexity Score**: HIGH
**Reason**: Multi-system audit + Data integrity + 13 tasks
**Total Tasks**: 13
**Estimated Time**: ~5h
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- App Version: 1.0.0+49
- Key Packages: riverpod ^2.4.9, cloud_firestore ^4.13.6, firebase_core ^2.24.2
- Target Platforms: iOS 14+, Android 8+
- Last Commit: f4dda99d - fix(notifications): connect NotificationSettings v2 to scheduling system
- Related Issues: Homepage error "Errore nel caricamento dei dati" (FIXED)
- Parent Milestone: None

---

## 📋 Original Request

> Debug entire Flutter app to find code inconsistencies, specifically:
> - Firestore collection name mismatches (e.g., exerciseActivities vs workouts)
> - Field name inconsistencies (userId vs email, completedAt vs createdAt, done vs completed)
> - Query patterns that don't match security rules
> - Indexes that don't match actual queries
> - Data structure assumptions (flat vs nested documents)
> - Hardcoded collection/field names that should be constants

---

## 🔍 Background - Recent Fixes

**Issue Fixed Today** (2025-01-18):
- ❌ `cached_progress_provider.dart` was querying non-existent collection `exerciseActivities`
- ✅ Fixed to query correct collection `workouts`
- ✅ Changed field `email` → `userId`
- ✅ Changed timestamp `createdAt` → `completedAt`
- ✅ Fixed nested data parsing: `workout.exercises[].sets[]`

**This audit ensures no similar issues exist elsewhere in the app.**

---

## 🎯 Task Breakdown

### 1. Firestore Queries (HIGH PRIORITY)

#### Task 1.1: Audit Collection Name References
- **Layer**: Data (Repositories)
- **Files**: `lib/features/*/data/repositories/*_repository*.dart`
- **Priority**: HIGH
- **Est. Time**: 20 min
- **Blocking**: Yes (blocks Task 1.2, 4.1)
- **Verification**:
  - ✅ Grep all `.collection('...')` calls
  - ✅ List unique collection names
  - ✅ Verify each collection exists in Firestore console
  - ❌ Flag hardcoded strings (should be constants)
- **Code Prompt**:
  ```bash
  # Find all collection references
  grep -r "\.collection\(" lib/features/*/data/repositories/ --include="*.dart" -n

  # Expected collections (valid):
  # - workouts
  # - users
  # - routines
  # - exercises
  # - dropSetActivity
  # - userMassimali
  # - community_contributions
  # - insight_feedback
  # - exercise_feedback

  # Unexpected collections (investigate):
  # - exerciseActivities (already fixed in cached_progress_provider.dart)
  # - any collection not in firestore.rules
  ```

#### Task 1.2: Cross-Repository Query Pattern Audit
- **Layer**: Data (Repositories)
- **Files**: All repository implementations
- **Priority**: HIGH
- **Est. Time**: 30 min
- **Dependencies**: Task 1.1
- **Blocking**: Yes (blocks Task 2.1, 3.1, 5.2)
- **Verification**:
  - ✅ Audit `.where('fieldName', ...)` calls
  - ✅ Standardize field names across repos:
    - `userId` (NOT `email` or `uid`)
    - `completedAt` (NOT `createdAt` for workout completion)
    - `completed` (NOT `done` for set completion)
  - ✅ Document standard field names in `firestore_constants.dart`
- **Code Prompt**:
  ```dart
  // Search for inconsistent field names
  grep -r "\.where\(" lib/features/*/data/repositories/ --include="*.dart" -A 2

  // Common inconsistencies to fix:
  // ❌ .where('email', ...)      → ✅ .where('userId', ...)
  // ❌ .where('createdAt', ...)  → ✅ .where('completedAt', ...) // for workouts
  // ❌ set['done']               → ✅ set['completed']
  ```

#### Task 1.3: Nested Document Query Validation
- **Layer**: Data (Repositories)
- **Files**: Repositories accessing subcollections
- **Priority**: HIGH
- **Est. Time**: 25 min
- **Dependencies**: Task 1.1
- **Blocking**: Yes (blocks Task 5.1)
- **Verification**:
  - ✅ List all subcollection queries (`.collection('users').doc(userId).collection('...')`)
  - ✅ Verify path structure matches Firestore schema
  - ✅ Check nested array parsing (e.g., `workout.exercises[].sets[]`)
  - ✅ Ensure no assumptions of flat structure when data is nested
- **Code Prompt**:
  ```dart
  // Find subcollection queries
  grep -r "\.doc\(.*\)\.collection\(" lib/features/*/data/repositories/ --include="*.dart" -n

  // Verify nested array access
  grep -r "data\['exercises'\]" lib/features/*/data/repositories/ --include="*.dart" -A 5
  grep -r "data\['sets'\]" lib/features/*/data/repositories/ --include="*.dart" -A 5
  ```

---

### 2. Security Rules (HIGH PRIORITY)

#### Task 2.1: Query Pattern vs Rules Alignment
- **Layer**: Infrastructure (Firebase)
- **Files**: `firestore.rules`, all repositories
- **Priority**: HIGH
- **Est. Time**: 40 min
- **Dependencies**: Task 1.2
- **Blocking**: No
- **Verification**:
  - ✅ For each repository query, verify corresponding security rule exists
  - ✅ Check rule allows authenticated user access
  - ✅ Verify field-level access (e.g., `resource.data.userId == request.auth.uid`)
  - ❌ Flag queries that would fail due to missing rules
- **Code Prompt**:
  ```
  Compare firestore.rules against queries:

  1. List all queries with .where('userId', ...)
  2. For each collection, verify rule:
     match /collectionName/{docId} {
       allow read: if request.auth != null &&
         request.auth.uid == resource.data.userId;
     }
  3. Check subcollection rules:
     match /users/{userId}/subcollection/{docId} {
       allow read: if request.auth != null &&
         request.auth.uid == userId;
     }
  ```

#### Task 2.2: Field-Level Access Validation
- **Layer**: Infrastructure (Firebase)
- **Files**: `firestore.rules`
- **Priority**: MEDIUM
- **Est. Time**: 20 min
- **Dependencies**: Task 2.1
- **Blocking**: No
- **Verification**:
  - ✅ Ensure sensitive fields (email, personal data) protected
  - ✅ Check timestamp fields have proper validation
  - ✅ Verify user can only access own data
- **Code Prompt**:
  ```
  Review firestore.rules for:
  - resource.data.userId == request.auth.uid (ownership check)
  - resource.data.email == request.auth.token.email (email verification)
  - Timestamp validation for createdAt/completedAt fields
  ```

---

### 3. Firestore Indexes (MEDIUM PRIORITY)

#### Task 3.1: Index Requirements Audit
- **Layer**: Infrastructure (Firebase)
- **Files**: `firestore.indexes.json`, repositories
- **Priority**: MEDIUM
- **Est. Time**: 25 min
- **Dependencies**: Task 1.2
- **Blocking**: Yes (blocks Task 3.2)
- **Verification**:
  - ✅ List all compound queries (`.where(...).orderBy(...)`)
  - ✅ Cross-reference with `firestore.indexes.json`
  - ✅ Check Firestore console for missing indexes
  - ✅ Verify query patterns match index definitions
- **Code Prompt**:
  ```bash
  # Find compound queries (require indexes)
  grep -r "\.where\(.*\)\.orderBy\(" lib/features/*/data/repositories/ --include="*.dart" -A 3

  # Compare against firestore.indexes.json
  cat firestore.indexes.json | jq '.indexes[] | {collection: .collectionGroup, fields: .fields}'
  ```

#### Task 3.2: Index Performance Validation
- **Layer**: Infrastructure (Firebase)
- **Files**: `firestore.indexes.json`
- **Priority**: MEDIUM
- **Est. Time**: 15 min
- **Dependencies**: Task 3.1
- **Blocking**: No
- **Verification**:
  - ✅ Check if indexes are actually used by queries
  - ✅ Remove indexes for deleted collections (e.g., exerciseActivities - already done)
  - ✅ Simplify overly complex indexes
- **Code Prompt**:
  ```bash
  # Check firestore.indexes.json for unused indexes
  # Already cleaned: exerciseActivities indexes removed (2025-01-18)

  # Verify all indexes match active queries
  ```

---

### 4. Constants & Configuration (HIGH PRIORITY)

#### Task 4.1: Centralize Collection/Field Names
- **Layer**: Data (Constants)
- **Files**: Create `lib/shared/data/constants/firestore_constants.dart`
- **Priority**: HIGH
- **Est. Time**: 30 min
- **Dependencies**: Task 1.1
- **Blocking**: No
- **Verification**:
  - ✅ Create centralized constants file
  - ✅ Replace all hardcoded collection names with constants
  - ✅ Replace all hardcoded field names with constants
  - ✅ Update imports across repositories
- **Code Prompt**:
  ```dart
  // Create lib/shared/data/constants/firestore_constants.dart

  class FirestoreCollections {
    static const String workouts = 'workouts';
    static const String users = 'users';
    static const String routines = 'routines';
    static const String exercises = 'exercises';
    // ... etc
  }

  class FirestoreFields {
    static const String userId = 'userId';
    static const String completedAt = 'completedAt';
    static const String completed = 'completed';
    static const String email = 'email';
    // ... etc
  }

  // Usage in repositories:
  // ❌ .collection('workouts')
  // ✅ .collection(FirestoreCollections.workouts)
  // ❌ .where('userId', ...)
  // ✅ .where(FirestoreFields.userId, ...)
  ```

#### Task 4.2: Environment-Specific Configuration
- **Layer**: Infrastructure (Config)
- **Files**: Check if needed
- **Priority**: MEDIUM
- **Est. Time**: 20 min
- **Dependencies**: Task 4.1
- **Blocking**: No
- **Verification**:
  - ✅ Verify collection names don't differ between dev/prod
  - ✅ Check if any environment-specific prefixes needed
  - ✅ Document environment switching if implemented
- **Code Prompt**:
  ```dart
  // Check if Firebase project uses separate collections for dev/prod
  // If yes, implement:

  class FirestoreConfig {
    static String get environment => kDebugMode ? 'dev' : 'prod';

    static String collection(String name) {
      // Add prefix only if needed
      return name; // or '${environment}_$name'
    }
  }
  ```

---

### 5. Data Models (HIGH PRIORITY)

#### Task 5.1: Domain Model Assumptions Audit
- **Layer**: Domain (Entities)
- **Files**: `lib/features/*/domain/entities/*.dart`
- **Priority**: HIGH
- **Est. Time**: 30 min
- **Dependencies**: Task 1.3
- **Blocking**: Yes (blocks Task 5.3)
- **Verification**:
  - ✅ Check all `fromMap()` / `fromJson()` methods
  - ✅ Verify they handle nested structures correctly
  - ✅ Ensure no assumptions of flat data when Firestore has nested arrays
  - ✅ Test parsing with actual Firestore document samples
- **Code Prompt**:
  ```dart
  // Audit all fromMap/fromJson methods
  grep -r "fromMap\|fromJson" lib/features/*/domain/entities/ --include="*.dart" -A 10

  // Verify nested parsing (e.g., workout.exercises[].sets[])
  // Example correct pattern:

  factory Workout.fromMap(Map<String, dynamic> data) {
    final exercisesData = data['exercises'] as List<dynamic>? ?? [];
    final exercises = exercisesData.map((e) {
      final setsData = e['sets'] as List<dynamic>? ?? [];
      final sets = setsData.map((s) => ExerciseSet.fromMap(s)).toList();
      return Exercise(name: e['name'], sets: sets);
    }).toList();

    return Workout(
      userId: data['userId'] as String,  // ✅ userId
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),  // ✅ completedAt
      exercises: exercises,
    );
  }
  ```

#### Task 5.2: Field Naming Convention Consistency
- **Layer**: All layers (Domain/Data/Presentation)
- **Files**: All entity/model/state classes
- **Priority**: HIGH
- **Est. Time**: 25 min
- **Dependencies**: Task 1.2
- **Blocking**: Yes (blocks Task 6.1)
- **Verification**:
  - ✅ Ensure domain entities use standard field names
  - ✅ Data layer maps Firestore fields to domain fields correctly
  - ✅ Presentation layer uses domain field names
  - ✅ No field name mismatches across layers
- **Code Prompt**:
  ```dart
  // Verify standard field names across layers:

  // Domain Entity:
  class Workout {
    final String userId;           // ✅ Standard
    final DateTime completedAt;    // ✅ Standard
  }

  // Data Model (Firestore mapping):
  factory WorkoutModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      userId: data['userId'],          // ✅ Maps correctly
      completedAt: data['completedAt'], // ✅ Maps correctly
    );
  }

  // Presentation State:
  class WorkoutState {
    final String userId;        // ✅ Uses domain name
    final DateTime completedAt; // ✅ Uses domain name
  }
  ```

#### Task 5.3: Null Safety & Default Values
- **Layer**: Domain (Entities), Data (Models)
- **Files**: All entity/model classes with fromMap methods
- **Priority**: MEDIUM
- **Est. Time**: 20 min
- **Dependencies**: Task 5.1
- **Blocking**: No
- **Verification**:
  - ✅ Check all optional fields have safe defaults
  - ✅ Verify null coalescing operators (`??`)
  - ✅ Test parsing with incomplete Firestore documents
  - ✅ Ensure no crashes on missing fields
- **Code Prompt**:
  ```dart
  // Safe parsing pattern:

  factory Exercise.fromMap(Map<String, dynamic> data) {
    return Exercise(
      name: data['name'] as String? ?? 'Unknown',  // ✅ Default for missing name
      sets: (data['sets'] as List<dynamic>? ?? [])  // ✅ Empty list default
          .map((s) => ExerciseSet.fromMap(s))
          .toList(),
      notes: data['notes'] as String?,  // ✅ Nullable, no default needed
    );
  }
  ```

---

### 6. Presentation Layer (MEDIUM PRIORITY)

#### Task 6.1: Riverpod Provider Data Consistency
- **Layer**: Presentation (Providers)
- **Files**: `lib/features/*/presentation/providers/*_provider.dart`
- **Priority**: MEDIUM
- **Est. Time**: 20 min
- **Dependencies**: Task 5.2
- **Blocking**: No
- **Verification**:
  - ✅ Check Riverpod providers map repository data correctly
  - ✅ Verify state classes use domain field names
  - ✅ Ensure no field name translation errors in providers
- **Code Prompt**:
  ```dart
  // Verify provider mappings:

  final workoutProvider = FutureProvider.autoDispose<Workout>((ref) async {
    final repository = ref.watch(workoutRepositoryProvider);
    final workout = await repository.getWorkout(workoutId);

    // ✅ Direct mapping (no field translation needed)
    return workout;
  });

  // State class uses domain names:
  class WorkoutState {
    final String userId;        // ✅ From domain.Workout.userId
    final DateTime completedAt; // ✅ From domain.Workout.completedAt
  }
  ```

---

## 📊 Implementation Order

**PHASE 1: MUST DO FIRST** (blocking tasks) - ~75 min
- → Task 1.1: Audit Collection Name References (20 min)
- → Task 1.2: Cross-Repository Query Pattern Audit (30 min)
- → Task 1.3: Nested Document Query Validation (25 min)

**PHASE 2: PARALLEL WORKABLE** - ~100 min
- → Task 4.1: Centralize Collection/Field Names (30 min) - Parallel with Phase 1
- → Task 2.1: Query Pattern vs Rules Alignment (40 min) - After 1.2
- → Task 3.1: Index Requirements Audit (25 min) - After 1.2
- → Task 5.1: Domain Model Assumptions Audit (30 min) - After 1.3

**PHASE 3: REFINEMENT** - ~125 min
- → Task 2.2: Field-Level Access Validation (20 min) - After 2.1
- → Task 3.2: Index Performance Validation (15 min) - After 3.1
- → Task 4.2: Environment-Specific Configuration (20 min) - After 4.1
- → Task 5.2: Field Naming Convention Consistency (25 min) - After 1.2
- → Task 5.3: Null Safety & Default Values (20 min) - After 5.1
- → Task 6.1: Riverpod Provider Data Consistency (20 min) - After 5.2

**Total Critical Path**: ~5h (300 min)

---

## 🎯 Success Criteria

**Audit Complete When**:
1. ✅ All Firestore queries use correct collection names (no exerciseActivities, etc.)
2. ✅ All queries use standard field names (userId, completedAt, completed)
3. ✅ Security rules allow all legitimate queries
4. ✅ Indexes exist for all compound queries
5. ✅ All collection/field names centralized in constants
6. ✅ Domain entities parse Firestore data correctly (nested structures)
7. ✅ No hardcoded strings in repositories
8. ✅ No field name mismatches across layers

**Verification Commands**:
```bash
# 1. Find hardcoded collection names
grep -r "\.collection\('[^']*'\)" lib/features/*/data/repositories/ --include="*.dart" | grep -v "FirestoreCollections"

# 2. Find hardcoded field names
grep -r "\.where\('[^']*'" lib/features/*/data/repositories/ --include="*.dart" | grep -v "FirestoreFields"

# 3. Run flutter analyze
flutter analyze

# 4. Deploy and test on device
flutter run --release
```

---

## 📝 Notes & Decisions

**Design Decisions**:
- Use centralized constants (`FirestoreCollections`, `FirestoreFields`)
- Standardize on `userId` (not `email` or `uid`)
- Standardize on `completedAt` for workout completion timestamps
- Standardize on `completed` for set completion status

**Known Issues to Address**:
- ✅ exerciseActivities collection removed (fixed 2025-01-18)
- Check if other legacy collections exist
- Verify all subcollection paths are correct

**Tech Debt**:
- Consider Firebase emulator for testing queries locally
- Add integration tests for Firestore queries
- Document Firestore schema in separate markdown file

---

## 🔗 Related Documentation

- `firestore.rules` - Security rules
- `firestore.indexes.json` - Index definitions
- `lib/features/progress/presentation/providers/cached_progress_provider.dart` - Recently fixed query example
- `docs/plans/CONTEXT.md` - Milestone tracking (if audit spans multiple sessions)

---

## 📦 Execution Log

**Completed Tasks**: 0/13
**Last Updated**: 2025-01-18 16:45
**Status**: ⏸️ Pending user approval

---

## 🚀 Next Steps After Audit

1. Create PR with all fixes
2. Deploy security rules: `firebase deploy --only firestore:rules`
3. Deploy indexes: `firebase deploy --only firestore:indexes`
4. Run integration tests
5. Document Firestore schema in `docs/FIRESTORE_SCHEMA.md`
