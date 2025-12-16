# Dependency Migration Plan - FitLog Pro

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate all outdated dependencies to latest major versions for security, performance, and maintainability.

**Architecture:** Sequential migration by dependency group, starting with code generation (freezed) since it affects all entities, then navigation (go_router), then auth/monetization.

**Tech Stack:** Flutter 3.x, Dart 3.x, Riverpod 3.x, Freezed 3.x, go_router 17.x

---

## Overview

### Impact Analysis

| Package | Current | Target | Files Impacted | Effort |
|---------|---------|--------|----------------|--------|
| freezed | 2.5.8 | 3.2.3 | 74 .freezed.dart | 🟡 2h |
| go_router | 12.1.3 | 17.0.0 | 20+ files | 🔴 3-4h |
| google_sign_in | 6.3.0 | 7.2.0 | 1 file | 🟢 30min |
| google_mobile_ads | 5.3.1 | 6.0.0 | 11 files | 🟡 1h |
| permission_handler | 11.4.0 | 12.0.1 | ~5 files | 🟢 30min |
| connectivity_plus | 6.1.5 | 7.0.0 | ~3 files | 🟢 15min |
| share_plus | 10.1.4 | 12.0.1 | ~2 files | 🟢 15min |
| flutter_dotenv | 5.2.1 | 6.0.0 | 1 file | 🟢 10min |

**Total Estimated Time:** ~8-10h

### Migration Order (Critical Path)

```
1. freezed 3.x          ← MUST be first (code generation base)
   ↓
2. Minor utilities      ← Low risk, quick wins
   (connectivity_plus, flutter_dotenv, share_plus)
   ↓
3. permission_handler   ← Used by health features
   ↓
4. google_sign_in       ← Auth (critical but isolated)
   ↓
5. google_mobile_ads    ← Monetization
   ↓
6. go_router            ← LAST (highest risk, most changes)
```

---

## Phase 1: Freezed 3.x Migration

### Task 1.1: Backup and Branch Setup

**Files:**
- None (git operations only)

**Step 1: Create migration branch**

```bash
git checkout -b feat/dependency-migration
```

**Step 2: Verify clean state**

```bash
git status
flutter clean
```

Expected: Clean working directory

**Step 3: Commit checkpoint**

```bash
git commit --allow-empty -m "chore: start dependency migration"
```

---

### Task 1.2: Update Freezed Dependencies

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Update freezed packages in pubspec.yaml**

```yaml
# In dependencies section:
freezed_annotation: ^3.1.0  # was ^2.4.1

# In dev_dependencies section:
freezed: ^3.2.3  # was ^2.4.6
```

**Step 2: Run pub get**

```bash
flutter pub get
```

Expected: Resolution success (may show deprecation warnings)

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): update freezed to 3.x"
```

---

### Task 1.3: Fix Freezed Breaking Changes

**Files:**
- Modify: All files with `@freezed` annotation (~40 source files)

**Step 1: Find all freezed classes**

```bash
grep -r "@freezed" lib/ --include="*.dart" | grep -v ".freezed.dart" | grep -v ".g.dart"
```

**Step 2: Apply migration pattern to each file**

For EACH freezed class, change:

```dart
// BEFORE (v2)
@freezed
class ModelState with _$ModelState {
  const factory ModelState.loading() = _Loading;
  const factory ModelState.loaded(Data data) = _Loaded;
  const factory ModelState.error(String message) = _Error;
}

// AFTER (v3)
@freezed
sealed class ModelState with _$ModelState {
  const factory ModelState.loading() = ModelLoadingState;
  const factory ModelState.loaded(Data data) = ModelLoadedState;
  const factory ModelState.error(String message) = ModelErrorState;
}
```

**Key changes:**
1. Add `sealed` keyword before `class`
2. Change private types `_Loading` → public `ModelLoadingState`

**Step 3: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: 74 files regenerated without errors

**Step 4: Run analyzer**

```bash
flutter analyze
```

Expected: No errors (warnings OK)

**Step 5: Run tests**

```bash
flutter test
```

Expected: All tests pass

**Step 6: Commit**

```bash
git add -A
git commit -m "refactor: migrate freezed classes to v3 sealed syntax"
```

---

### Task 1.4: Update Pattern Matching (Optional)

**Files:**
- Modify: Files using `.when()` / `.map()` methods

**Step 1: Find when/map usage**

```bash
grep -r "\.when\(|\.map\(" lib/ --include="*.dart" | grep -v ".freezed.dart"
```

**Step 2: (Optional) Migrate to Dart switch expressions**

```dart
// BEFORE (freezed when)
state.when(
  loading: () => CircularProgressIndicator(),
  loaded: (data) => Text(data),
  error: (msg) => Text(msg),
);

// AFTER (Dart switch - optional but recommended)
switch (state) {
  case ModelLoadingState(): CircularProgressIndicator();
  case ModelLoadedState(:final data): Text(data);
  case ModelErrorState(:final message): Text(message);
}
```

**Note:** This is optional - `when`/`map` still work but are deprecated.

**Step 3: Commit if changes made**

```bash
git add -A
git commit -m "refactor: migrate when/map to Dart switch expressions"
```

---

## Phase 2: Minor Utilities Migration

### Task 2.1: connectivity_plus 7.x

**Files:**
- Modify: `pubspec.yaml`
- Modify: Files using `Connectivity` class

**Step 1: Update pubspec**

```yaml
connectivity_plus: ^7.0.0  # was ^6.0.5
```

**Step 2: Run pub get**

```bash
flutter pub get
```

**Step 3: Check for breaking changes**

```bash
grep -r "Connectivity\|connectivity_plus" lib/ --include="*.dart"
```

**Step 4: Fix any API changes**

v7.0 changes:
- `ConnectivityResult` is now a `List<ConnectivityResult>` (multiple connections)

```dart
// BEFORE
final result = await Connectivity().checkConnectivity();
if (result == ConnectivityResult.wifi) { ... }

// AFTER
final results = await Connectivity().checkConnectivity();
if (results.contains(ConnectivityResult.wifi)) { ... }
```

**Step 5: Test and commit**

```bash
flutter analyze && flutter test
git add -A
git commit -m "chore(deps): upgrade connectivity_plus to 7.x"
```

---

### Task 2.2: flutter_dotenv 6.x

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart` (likely)

**Step 1: Update pubspec**

```yaml
flutter_dotenv: ^6.0.0  # was ^5.1.0
```

**Step 2: Run pub get and check usage**

```bash
flutter pub get
grep -r "dotenv\|DotEnv" lib/ --include="*.dart"
```

**Step 3: Fix any breaking changes**

v6.0 changes:
- `dotenv.env` access may have changed

```dart
// Usually no changes needed for basic usage:
await dotenv.load(fileName: ".env");
final apiKey = dotenv.env['API_KEY'];
```

**Step 4: Test and commit**

```bash
flutter analyze && flutter test
git add -A
git commit -m "chore(deps): upgrade flutter_dotenv to 6.x"
```

---

### Task 2.3: share_plus 12.x

**Files:**
- Modify: `pubspec.yaml`
- Modify: Files using `Share.share()`

**Step 1: Update pubspec**

```yaml
share_plus: ^12.0.1  # was ^10.1.0
```

**Step 2: Run pub get and check usage**

```bash
flutter pub get
grep -r "Share\.share\|share_plus" lib/ --include="*.dart"
```

**Step 3: Fix any breaking changes**

v12.0 changes:
- `Share.share()` signature may have changed
- Check for `shareXFiles` vs `share` API

**Step 4: Test and commit**

```bash
flutter analyze && flutter test
git add -A
git commit -m "chore(deps): upgrade share_plus to 12.x"
```

---

### Task 2.4: permission_handler 12.x

**Files:**
- Modify: `pubspec.yaml`
- Modify: Files requesting permissions (~5 files)

**Step 1: Update pubspec**

```yaml
permission_handler: ^12.0.1  # was ^11.0.1
```

**Step 2: Run pub get and check usage**

```bash
flutter pub get
grep -r "Permission\." lib/ --include="*.dart"
```

**Step 3: Fix any breaking changes**

v12.0 changes:
- `Permission.activityRecognition` → check new enum values
- iOS permission descriptions may need updating

**Step 4: Test and commit**

```bash
flutter analyze && flutter test
git add -A
git commit -m "chore(deps): upgrade permission_handler to 12.x"
```

---

## Phase 3: Google Sign-In 7.x

### Task 3.1: Update Google Sign-In

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/features/auth/data/auth_service.dart`

**Step 1: Update pubspec**

```yaml
google_sign_in: ^7.2.0  # was ^6.3.0
```

**Step 2: Run pub get**

```bash
flutter pub get
```

**Step 3: Read auth_service.dart**

```bash
cat lib/features/auth/data/auth_service.dart
```

**Step 4: Apply v7 migration**

```dart
// BEFORE (v6)
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<UserCredential?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  // ...
}

// AFTER (v7)
Future<UserCredential?> signInWithGoogle() async {
  // Singleton pattern - no need to create instance
  await GoogleSignIn.instance.initialize();

  // Authentication
  final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.signIn();

  // Authorization (if needed)
  final auth = await googleUser?.authentication;
  // ...
}
```

**Key v7 changes:**
1. `GoogleSignIn` is now singleton via `GoogleSignIn.instance`
2. Must call `initialize()` before first use
3. Auth and authorization are separate steps

**Step 5: Test sign-in flow manually**

Run app and test Google Sign-In on both iOS and Android.

**Step 6: Commit**

```bash
git add -A
git commit -m "feat(auth): migrate google_sign_in to v7 singleton API"
```

---

## Phase 4: Google Mobile Ads 6.x

### Task 4.1: Update Google Mobile Ads

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle` (minSdk)
- Modify: 11 ad-related files

**Step 1: Update pubspec**

```yaml
google_mobile_ads: ^6.0.0  # was ^5.1.0
```

**Step 2: Update Android minSdk**

In `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdk = 23  // was 21 or lower
    }
}
```

**Step 3: Run pub get**

```bash
flutter pub get
```

**Step 4: Check ad files**

```bash
grep -r "AppOpenAd\|BannerAd\|InterstitialAd" lib/ --include="*.dart"
```

**Step 5: Fix breaking changes**

v6.0 changes:
- `AppOpenAd.load()` no longer accepts `orientation` parameter
- `MediationNetworkExtrasProvider` deprecated → use `MediationExtras`

```dart
// BEFORE
AppOpenAd.load(
  adUnitId: adUnitId,
  orientation: AppOpenAd.orientationPortrait,  // REMOVE THIS
  request: AdRequest(),
  // ...
);

// AFTER
AppOpenAd.load(
  adUnitId: adUnitId,
  request: AdRequest(),
  // ...
);
```

**Step 6: Test ads**

Run app and verify:
- Banner ads load
- Interstitial ads work
- App open ads work (if used)

**Step 7: Commit**

```bash
git add -A
git commit -m "chore(deps): upgrade google_mobile_ads to 6.x"
```

---

## Phase 5: go_router 17.x (Highest Risk)

### Task 5.1: Analyze Current Router Usage

**Files:**
- Read: All 20+ files using go_router

**Step 1: List all router files**

```bash
grep -r "GoRouter\|GoRoute\|go_router" lib/ --include="*.dart" -l
```

**Step 2: Identify patterns used**

Check for:
- `GoRouterState.location` (deprecated)
- `params` / `queryParams` (renamed)
- `redirect` functions
- `ShellRoute` usage

**Step 3: Document current patterns**

Create a checklist of patterns to migrate.

---

### Task 5.2: Update go_router

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Update pubspec**

```yaml
go_router: ^17.0.0  # was ^12.1.3
```

**Step 2: Run pub get**

```bash
flutter pub get
```

Expected: Success with possible warnings

---

### Task 5.3: Run dart fix

**Step 1: Try automatic fixes**

```bash
dart fix --apply
```

**Step 2: Check what was fixed**

```bash
git diff lib/
```

**Step 3: Run analyzer**

```bash
flutter analyze
```

Expected: Some manual fixes still needed

---

### Task 5.4: Manual Fixes

**Files:**
- Modify: Each file with remaining errors

**Common migrations:**

```dart
// 1. GoRouterState.location → uri
// BEFORE
final location = GoRouterState.of(context).location;
// AFTER
final uri = GoRouterState.of(context).uri;
final location = uri.toString();

// 2. params → pathParameters
// BEFORE
final id = state.params['id'];
// AFTER
final id = state.pathParameters['id'];

// 3. queryParams → queryParameters
// BEFORE
final filter = state.queryParams['filter'];
// AFTER
final filter = state.uri.queryParameters['filter'];

// 4. redirect signature
// BEFORE
redirect: (context, state) {
  return state.location == '/login' ? null : '/login';
}
// AFTER
redirect: (context, state) {
  return state.uri.path == '/login' ? null : '/login';
}
```

**Step 4: Fix each file**

Go through each of the 20+ files and apply fixes.

**Step 5: Run analyzer**

```bash
flutter analyze
```

Expected: No errors

---

### Task 5.5: Test Navigation

**Step 1: Run app**

```bash
flutter run
```

**Step 2: Test critical navigation paths**

- [ ] App launch → Home
- [ ] Home → Workout
- [ ] Workout → Exercise selection
- [ ] Deep links (if used)
- [ ] Back navigation
- [ ] Tab navigation
- [ ] Modal routes

**Step 3: Run all tests**

```bash
flutter test
```

**Step 4: Commit**

```bash
git add -A
git commit -m "feat(nav): migrate go_router to v17"
```

---

## Phase 6: Final Verification

### Task 6.1: Full Test Suite

**Step 1: Clean build**

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Step 2: Run all tests**

```bash
flutter test
```

Expected: All tests pass

**Step 3: Run analyzer**

```bash
flutter analyze
```

Expected: No errors, minimal warnings

---

### Task 6.2: Integration Testing

**Step 1: Build and run on iOS**

```bash
flutter run -d ios
```

Test critical flows.

**Step 2: Build and run on Android**

```bash
flutter run -d android
```

Test critical flows.

---

### Task 6.3: Merge

**Step 1: Review all changes**

```bash
git log --oneline feat/dependency-migration..HEAD
git diff main..feat/dependency-migration --stat
```

**Step 2: Squash or merge**

```bash
git checkout main
git merge feat/dependency-migration
```

**Step 3: Push**

```bash
git push origin main
```

---

## Rollback Plan

If any phase fails:

```bash
# Revert to before migration
git checkout main
git branch -D feat/dependency-migration

# Or revert specific commit
git revert <commit-hash>
```

---

## Summary Checklist

- [ ] Phase 1: freezed 2.x → 3.x (74 files)
- [ ] Phase 2.1: connectivity_plus 6.x → 7.x
- [ ] Phase 2.2: flutter_dotenv 5.x → 6.x
- [ ] Phase 2.3: share_plus 10.x → 12.x
- [ ] Phase 2.4: permission_handler 11.x → 12.x
- [ ] Phase 3: google_sign_in 6.x → 7.x (1 file)
- [ ] Phase 4: google_mobile_ads 5.x → 6.x (11 files)
- [ ] Phase 5: go_router 12.x → 17.x (20+ files)
- [ ] Phase 6: Final verification
- [ ] Merge to main

**Total Estimated Time:** 8-10 hours (can be split across multiple sessions)
