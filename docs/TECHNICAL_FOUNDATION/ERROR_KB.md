# GymBro Error Knowledge Base

## Build Errors

### 3. Missing Required Named Parameters

#### Error: Required named parameter 'title' must be provided
```dart
// ❌ WRONG
_ModalItem(
  label: AppLocalizations.of(context)!.technicalNotes,
  value: data['noteTecniche'],
  icon: Icons.note,
)
```

**Solution:**
```dart
// ✅ CORRECT - Add all required parameters
_ModalItem(
  title: AppLocalizations.of(context)!.technicalNotes,  // Required parameter
  label: AppLocalizations.of(context)!.technicalNotes,
  value: data['noteTecniche'],
  icon: Icons.note,
)
```
**Location:** `lib/features/workout/presentation/widgets/exercise_list_item.dart:3005-3036`
**Date Fixed:** 2025-08-23

### 4. Syntax Errors - Extra Parentheses

#### Error: Expected ';' after this / Unexpected token
```dart
// ❌ WRONG - Extra closing parenthesis
        ),
      ),
    );  // One too many
  }
```

**Solution:**
```dart
// ✅ CORRECT - Proper parenthesis matching
        ),
      );  // Correct closing
  }
```
**Location:** `lib/features/workout/presentation/widgets/exercise_history_bottom_sheet.dart:183`
**Date Fixed:** 2025-08-23

---

## Build Errors

### 1. Null Safety Errors

#### Error: Property cannot be accessed because it is potentially null
```dart
// ❌ WRONG
if (currentUser?.email == null || currentUser.uid == null) {
```

**Solution:**
```dart
// ✅ CORRECT
if (currentUser?.email == null || currentUser?.uid == null) {
```
**Location:** `lib/features/workout/presentation/providers/workout_provider.dart:206`
**Date Fixed:** 2025-08-22

---

### 2. Missing Semicolon

#### Error: Expected ';' after this
```dart
// ❌ WRONG
final userId = currentUser.uid!
```

**Solution:**
```dart
// ✅ CORRECT
final userId = currentUser.uid!;
```
**Location:** `lib/features/workout/presentation/providers/workout_provider.dart:213`
**Date Fixed:** 2025-08-22

---

## iOS Build Errors

### 1. Flutter Debug/Release Mode Mismatch

#### Error: Your Flutter project is currently configured for debug mode
When building in Xcode with Release configuration:
```
error: Your Flutter project is currently configured for debug mode. 
Please run `flutter build ios --config-only --release` in your Flutter project to update your settings.
```

**Solution:**
```bash
flutter build ios --config-only --release
```
This updates the Flutter configuration to match Xcode's build mode.

**Location:** Xcode build script phase
**Date Fixed:** 2025-08-23

### 2. Xcode Configuration Warnings
**Warning:** "Your Flutter project is currently configured for debug mode"
**Solution:** Run `flutter build ios --config-only --release`

### 2. Script Phase Warnings
**Warning:** "Run script build phase will be run during every build because the option to run the script phase 'Based on dependency analysis' is unchecked"
**Solution:** This is a note, not an error. Can be ignored or fixed in Xcode project settings.

---

## Enum Value Mismatch Errors

### 1. Wrong Enum Value Name

#### Error: Member not found in enum
```dart
// ❌ WRONG - Using wrong enum value name
if (state!.status != TimerStatus.waitingForRPE) {
```

**Solution:**
```dart
// ✅ CORRECT - Use actual enum value from definition
if (state!.status != TimerStatus.awaitingRPE) {
```
**Note:** Always check the actual enum definition for correct value names
**Location:** `lib/features/timer/presentation/providers/timer_provider.dart:668,1577`
**Date Fixed:** 2025-08-25

---

## Import Errors

### 1. Missing dart:async import for Timer

#### Error: Type 'Timer' not found
```dart
// ❌ WRONG - Missing import
Timer? _rpeMonitoringTimer;
```

**Solution:**
```dart
// ✅ CORRECT - Add dart:async import
import 'dart:async';

Timer? _rpeMonitoringTimer;
```
**Location:** `lib/features/timer/presentation/providers/live_activity_provider.dart:1`
**Date Fixed:** 2025-08-25

### 2. Missing or Wrong DebugLogger import

#### Error: The getter 'DebugLogger' isn't defined / No such file or directory
```dart
// ❌ WRONG - Missing import or wrong path
DebugLogger.log(LogCategory.liveActivity, 'message');
// or
import 'package:gymbro_flutter_new/shared/utils/debug_logger.dart'; // Wrong path!
```

**Solution:**
```dart
// ✅ CORRECT - Add debug_logger import with correct path
import 'package:gymbro_flutter_new/core/utils/debug_logger.dart';
```
**Note:** The DebugLogger class is located in `core/utils/`, not `shared/utils/`
**Location:** `lib/features/timer/presentation/providers/live_activity_provider.dart:7`
**Date Fixed:** 2025-08-25

---

## Common Flutter/Dart Patterns

### Null Safety Best Practices
1. Always use `?.` when accessing properties on nullable objects in conditions
2. Use `!` only when you're certain the value is not null (after null check)
3. Remember to add semicolons at the end of statements

### Firebase/Auth Patterns
```dart
// Safe user access pattern
final currentUser = authService.currentUser;
if (currentUser?.email == null || currentUser?.uid == null) {
  return;
}
// Now safe to use ! operator
final email = currentUser!.email!;
final uid = currentUser.uid!;
```

---

## Runtime Errors

### 1. NSInvalidArgumentException with UserDefaults

#### Error: Attempt to insert non-property list object
```
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', 
reason: 'Attempt to insert non-property list object {
    workoutName = "<null>";
} for key current_exercise_data'
```

**Cause:** Trying to save NSNull values to UserDefaults (not allowed in property lists)

**Solution:**
```swift
// ❌ WRONG - Directly saving dictionary with potential NSNull values
userDefaults.set(args, forKey: "current_exercise_data")

// ✅ CORRECT - Sanitize dictionary to remove NSNull values
var sanitizedArgs = [String: Any]()
for (key, value) in args {
    if !(value is NSNull) {
        sanitizedArgs[key] = value
    }
}
userDefaults.set(sanitizedArgs, forKey: "current_exercise_data")
```
**Location:** `ios/Runner/AppDelegate.swift:313-319`
**Date Fixed:** 2025-08-25

---

## Testing Errors

### 1. Timer Disposal Issues
**Error:** Timer not properly disposed in tests
**Solution:** Always dispose timers in tearDown or use Timer.cancel()

### 2. Widget Testing with Riverpod
**Error:** ProviderScope not found
**Solution:** Wrap test widgets with ProviderScope

---

## Performance Issues

### 1. Unnecessary Rebuilds
**Symptom:** Widget rebuilding too frequently
**Solution:** Use `ref.watch(provider.select((state) => state.field))` instead of `ref.watch(provider)`

### 2. Memory Leaks
**Symptom:** Disposed objects still receiving updates
**Solution:** Check mounted before setState, dispose controllers properly

---

## Localization Errors

### 1. Hardcoded Strings
**Detection:** `./scripts/find_hardcoded_strings.sh`
**Solution:** Use `AppLocalizations.of(context)!.key` instead

### 2. Missing Translations
**Error:** Key not found in ARB file
**Solution:** Add to both `app_en.arb` and `app_it.arb`, then run `flutter gen-l10n`

---

## Ad-Related Errors

### 1. Deprecated AdSize Methods
**Error:** The getter 'Orientation' isn't defined
**Context:** Using deprecated `AdSize.getSmartBanner(Orientation.portrait)`
**Solution:** Use modern adaptive banner methods or fallback to standard sizes
```dart
// ❌ WRONG (deprecated)
return AdSize.getSmartBanner(Orientation.portrait);

// ✅ CORRECT
return AdSize.fullBanner; // or AdSize.banner
// For true adaptive banners, use:
// AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width)
```
**Location:** `lib/features/ads/data/repositories/google_ad_repository.dart:363`
**Date Fixed:** 2025-08-22

### 2. Missing Widget Definition
**Error:** Widget class not found (e.g., HomeBannerAd)
**Context:** After removing Google Mobile Ads, widget references remain
**Solution:** Replace with SizedBox.shrink() placeholder
```dart
// ❌ WRONG (widget doesn't exist)
const HomeBannerAd()

// ✅ CORRECT
const SizedBox.shrink()  // Placeholder until feature is reimplemented
```
**Location:** `lib/features/home/presentation/home_screen.dart:165`
**Date Fixed:** 2025-08-22

### 5. Wrong Import Path for Entity Files

#### Error: No such file or directory when importing entity
```dart
// ❌ WRONG - File doesn't exist
import '../../domain/entities/exercise_set.dart';
```

**Solution:**
```dart
// ✅ CORRECT - ExerciseSet is defined in exercise.dart
import '../../domain/entities/exercise.dart';
```
**Location:** `lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart:19`
**Date Fixed:** 2025-08-23

---

## Workout History Entity Errors

### 1. ExerciseSet Type Mismatches

#### Error: The argument type 'double' can't be assigned to the parameter type 'String'
When ExerciseSet weight and reps are already double/int but code tries to parse them as strings:
```dart
// ❌ WRONG - weight is already double, reps is already int
final weight = double.tryParse(set.weight) ?? 0;
final reps = int.tryParse(set.reps) ?? 0;
```

**Solution:**
```dart
// ✅ CORRECT - Use directly
final weight = set.weight;
final reps = set.reps;
```
**Locations:** `workout_history_provider.dart:347-348`, `workout_history_list_item.dart:284-285`
**Date Fixed:** 2025-08-25

### 2. Entity Constructor Issues

#### Error: No named parameter with the name 'id'/'duration'/'isActive'
When using copyWith with parameters that don't exist:
```dart
// ❌ WRONG - copyWith doesn't have these parameters
workout.copyWith(
  id: newId,
  duration: duration,
  isActive: false,
)
```

**Solution:**
```dart
// ✅ CORRECT - Create new instance
Workout(
  id: newId,
  name: workout.name,
  exercises: workout.exercises,
  // ... other fields
)
```
**Locations:** `workout_history_provider.dart:221`
**Date Fixed:** 2025-08-25

### 3. ExerciseSet Missing Required Parameters

#### Error: Required named parameter 'setNumber' must be provided
```dart
// ❌ WRONG - Missing setNumber
ExerciseSet(
  weight: 70,
  reps: 10,
)
```

**Solution:**
```dart
// ✅ CORRECT - Include setNumber
ExerciseSet(
  setNumber: 1,
  weight: 70.0,
  reps: 10,
)
```
**Date Fixed:** 2025-08-25

---

## Quick Fixes Checklist

When encountering a build error:
1. ✅ Check for missing semicolons
2. ✅ Verify null safety operators (`?`, `!`)
3. ✅ Run `flutter analyze`
4. ✅ Check for hardcoded strings
5. ✅ Ensure proper disposal of resources
6. ✅ Verify Firebase/auth patterns

---

## Prevention Tips

1. **Always run before committing:**
   ```bash
   flutter analyze
   ./scripts/find_hardcoded_strings.sh
   flutter test
   ```

2. **Use proper null safety:**
   - Prefer `?.` over `!` when unsure
   - Do null checks before using `!`

3. **Follow existing patterns:**
   - Check similar code in the codebase
   - Use established auth/Firebase patterns

4. **Test incrementally:**
   - Build after each significant change
   - Don't accumulate multiple potential errors

---

## Swift/iOS Native Errors

### 2. Class Not Available in Widget Extension

#### Error: Cannot find 'LiveActivityHandler' in scope in widget extension
When trying to use a class from the main app in a widget extension:
```swift
// ❌ WRONG - Main app classes not accessible in extension
LiveActivityHandler.shared.showRPEInterfaceFromBackground(...)
```

**Solution:**
```swift
// ✅ CORRECT - Implement functionality directly in extension
let rpeAttributes = GymBroRPEAttributes(...)
let initialState = GymBroRPEAttributes.ContentState(...)

do {
    _ = try Activity<GymBroRPEAttributes>.request(
        attributes: rpeAttributes,
        content: ActivityContent(state: initialState, staleDate: nil),
        pushType: nil
    )
} catch {
    print("Failed to create RPE Live Activity: \(error)")
}
```
**Note:** Widget extensions run in separate process and cannot access main app classes
**Location:** `ios/GymBroTimerWidget/AppIntent.swift:484`
**Date Fixed:** 2025-08-25

### 3. IntentParameter Type Mismatch

#### Error: Cannot convert value of type 'Int' to expected argument type 'IntentParameter<Int>'
When using App Intents with parameters in Live Activities:
```swift
// ❌ WRONG - Using @Parameter with direct initialization
@Parameter(title: "RPE Value")
var rpeValue: Int

// In Button:
Button(intent: SetRPEIntent(rpeValue: rpe)) // Error!
```

**Solution:**
```swift
// ✅ CORRECT - Use regular property with init
var rpeValue: Int

init(rpeValue: Int) {
    self.rpeValue = rpeValue
}

init() {
    self.rpeValue = 5 // Default
}
```
**Location:** `ios/GymBroTimerWidget/AppIntent.swift:306-314`
**Date Fixed:** 2025-08-25

---

## Historical Fixes Log

| Date | File | Error Type | Line | Fixed By |
|------|------|------------|------|----------|
| 2025-08-22 | workout_provider.dart | Null safety | 206 | Added `?.` operator |
| 2025-08-22 | workout_provider.dart | Missing semicolon | 213 | Added `;` |
| 2025-08-22 | gdpr_consent_dialog.dart | Wrong import path | 15 | Fixed import to use package path |
| 2025-08-22 | workout_provider.dart | DateTime null safety | 200 | Added null checks before difference |
| 2025-08-22 | workout_provider.dart | Wrong Ref type | 213 | Removed direct ad call from provider |
| 2025-08-22 | google_ad_repository.dart | Deprecated API | 363 | Replaced AdSize.getSmartBanner with AdSize.fullBanner |
| 2025-08-22 | home_screen.dart | Missing widget | 165 | Replaced HomeBannerAd with SizedBox.shrink() |
| 2025-08-23 | exercise_list_item.dart | Missing required parameter | 3005-3036 | Added 'title' parameter to _ModalItem |
| 2025-08-23 | exercise_history_bottom_sheet.dart | Syntax error | 183 | Removed extra closing parenthesis |
| 2025-08-23 | quick_edit_overlay_v2.dart | Wrong import path | 19 | Fixed import from exercise_set.dart to exercise.dart |
| 2025-08-23 | Xcode build script | Flutter mode mismatch | - | Run flutter build ios --config-only --release |
| 2025-08-25 | AppIntent.swift | IntentParameter type mismatch | 306-314 | Removed @Parameter, added init methods |
| 2025-08-25 | GymBroTimerWidgetLiveActivity.swift | SetRPEIntent initialization | 408, 565 | Use direct Int parameter |
| 2025-08-25 | live_activity_provider.dart | Missing Timer import | 1 | Added dart:async import |
| 2025-08-25 | live_activity_provider.dart | Missing DebugLogger import | 7 | Added core/utils/debug_logger.dart import |
| 2025-08-25 | timer_provider.dart | Wrong enum value name | 668,1577 | Changed waitingForRPE to awaitingRPE |
| 2025-08-25 | AppIntent.swift | Class not accessible in extension | 484 | Replaced LiveActivityHandler with direct Activity creation |
| 2025-08-25 | AppDelegate.swift | NSInvalidArgumentException with NSNull | 313-319 | Sanitize dictionary to remove NSNull values |
| 2025-08-25 | app_en.arb, app_it.arb | Missing 'refresh' localization key | 2988, 1183 | Added 'refresh' key to both ARB files |
| 2025-08-25 | workout_history_provider.dart | Type mismatch - weight/reps as strings | 347-348 | Removed string parsing, use double/int directly |
| 2025-08-25 | workout_history_provider.dart | Missing 'id' parameter in copyWith | 221 | Use Workout constructor instead of copyWith |
| 2025-08-25 | workout_history_provider.dart | Invalid parameters in mapper functions | 444,456 | Fixed mapping with correct entity/model conversions |
| 2025-08-25 | workout_history_list_item.dart | Type mismatch - weight/reps as strings | 284-285 | Use weight/reps directly without parsing |
| 2025-08-25 | workout_history_editor.dart | Missing setNumber in ExerciseSet | 55 | Added setNumber parameter |
| 2025-08-25 | workout_history_editor.dart | Wrong parameter 'muscleGroup' | 54 | Changed to 'type' and 'category' |
| 2025-08-25 | workout_history_editor.dart | String to double/int conversion | 409,423 | Convert to string for display |
| 2025-08-25 | workout_history_editor.dart | String weight/reps in _updateSet | 524-525 | Parse strings to double/int when updating |
| 2025-08-25 | workout_history_editor.dart | Invalid 'createdAt' in copyWith | 562 | Use Workout constructor instead |

---

## Tools for Error Detection

```bash
# Static analysis
flutter analyze

# Localization check
./scripts/find_hardcoded_strings.sh

# Test runner
flutter test

# iOS build check
flutter build ios --no-codesign

# Full pre-commit check
make pre-commit
```