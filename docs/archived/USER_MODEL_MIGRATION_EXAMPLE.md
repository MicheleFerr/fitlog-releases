# 🔄 User Model Migration Example

This document shows how to migrate from the old fragmented user models to the new consolidated type-safe system.

## 📦 What's New

1. **Single User Model**: `UserProfile` (consolidated)
2. **Type-Safe State**: `UserState` sealed class
3. **Unified Provider**: `userStateProvider`
4. **Better Error Handling**: No more null pointer exceptions

## 🔄 Migration Examples

### Example 1: Basic User Check

#### ❌ OLD WAY (Error-prone)
```dart
// Multiple models causing confusion
final firebaseUser = ref.watch(currentUserProvider).value;  // Firebase User
final userModel = ref.watch(userModelProvider);  // UserModel
final userProfile = ref.watch(userProfileProvider);  // UserProfile

// Error-prone null checks
if (firebaseUser != null) {
  final isPremium = userProfile?.isPremium ?? false;  // Which model?
  final uid = firebaseUser.uid;  // Or userModel.uid? Or userProfile.id?
}
```

#### ✅ NEW WAY (Type-safe)
```dart
// Single source of truth
final userState = ref.watch(currentUserStateProvider);

// Type-safe pattern matching
userState.when(
  authenticated: (profile) {
    final isPremium = profile.isPremium;  // Always correct
    final uid = profile.uid;  // No confusion
  },
  unauthenticated: () => showLoginScreen(),
  anonymous: () => showGuestUI(),
  loading: () => showLoader(),
  error: (e, s) => showError(e),
);
```

### Example 2: Premium Feature Check

#### ❌ OLD WAY
```dart
Widget build(BuildContext context, WidgetRef ref) {
  // Confusing AsyncValue handling
  final userProfileAsync = ref.watch(userProfileProvider);
  
  if (userProfileAsync.isLoading) {
    return CircularProgressIndicator();
  }
  
  final userProfile = userProfileAsync.value;
  if (userProfile == null) {
    return Text('Not logged in');
  }
  
  // Error: tried to use userProfile.id instead of uid
  final userId = userProfile.id;  // COMPILE ERROR!
  
  if (userProfile.accountTier == AccountTier.premium ||
      userProfile.accountTier == AccountTier.pro) {
    return PremiumContent();
  }
  
  return FreeContent();
}
```

#### ✅ NEW WAY
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final userState = ref.watch(currentUserStateProvider);
  
  // Clean, type-safe pattern matching
  return userState.buildWhen(
    authenticated: (profile) {
      final userId = profile.uid;  // Always correct property
      
      if (profile.isPremium) {  // Built-in helper
        return PremiumContent();
      }
      return FreeContent();
    },
    unauthenticated: () => Text('Not logged in'),
    loading: () => CircularProgressIndicator(),
  );
}
```

### Example 3: Settings Screen

#### ❌ OLD WAY
```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Multiple providers, multiple points of failure
    final firebaseUser = ref.watch(currentUserProvider).value;
    final userProfile = ref.watch(userProfileProvider).value;
    
    if (firebaseUser == null || userProfile == null) {
      return LoginPrompt();
    }
    
    return Column(
      children: [
        // Mixing models causes errors
        Text('Email: ${firebaseUser.email}'),
        Text('Name: ${userProfile.displayName}'),
        // Error: isPremium doesn't exist on Firebase User
        if (firebaseUser.isPremium) PremiumBadge(),  // COMPILE ERROR!
      ],
    );
  }
}
```

#### ✅ NEW WAY
```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserStateProvider);
    
    return userState.buildWhen(
      authenticated: (profile) => Column(
        children: [
          // Single model, all data available
          Text('Email: ${profile.email}'),
          Text('Name: ${profile.displayName}'),
          if (profile.isPremium) PremiumBadge(),  // Works!
          Text('Member since: ${profile.createdAt}'),
          Text('Tier: ${profile.accountTier.name}'),
        ],
      ),
      unauthenticated: () => LoginPrompt(),
    );
  }
}
```

### Example 4: Workout Save with User Check

#### ❌ OLD WAY
```dart
Future<void> saveWorkout(Workout workout) async {
  // Multiple null checks, easy to miss one
  final user = ref.read(currentUserProvider).value;
  if (user == null) throw Exception('Not authenticated');
  
  final profile = ref.read(userProfileProvider).value;
  if (profile == null) throw Exception('Profile not loaded');
  
  // Confusion: which uid to use?
  workout = workout.copyWith(userId: user.uid);  // or profile.uid?
  
  // Template quota check with wrong property
  if (profile.templateQuota.canSavePrivate) {
    await repository.save(workout);
  }
}
```

#### ✅ NEW WAY
```dart
Future<void> saveWorkout(Workout workout) async {
  final userState = ref.read(currentUserStateProvider);
  
  // Type-safe, single check
  final profile = userState.profileOrNull;
  if (profile == null) {
    throw Exception('Not authenticated');
  }
  
  // No confusion about properties
  workout = workout.copyWith(userId: profile.uid);
  
  // Clear quota check
  if (profile.templateQuota.canSavePrivate) {
    await repository.save(workout);
  }
}
```

### Example 5: Navigation Guards

#### ❌ OLD WAY
```dart
// In router configuration
redirect: (context, state) {
  final user = ref.read(currentUserProvider).value;
  final profile = ref.read(userProfileProvider).value;
  
  // Complex null checks
  if (user == null) {
    return '/login';
  }
  
  // Checking premium with wrong model
  if (state.location == '/premium' && !user.isPremium) {  // ERROR!
    return '/upgrade';
  }
  
  return null;
}
```

#### ✅ NEW WAY
```dart
// In router configuration
redirect: (context, state) {
  final userState = ref.read(currentUserStateProvider);
  
  // Clean pattern matching
  return userState.when(
    authenticated: (profile) {
      if (state.location == '/premium' && !profile.isPremium) {
        return '/upgrade';
      }
      return null;
    },
    unauthenticated: () => '/login',
    anonymous: () => '/guest-mode',
    loading: () => '/splash',
    error: (e, s) => '/error',
  );
}
```

## 🔧 Step-by-Step Migration Guide

### Step 1: Update Imports
```dart
// Remove old imports
- import '.../user_model.dart';
- import '.../current_user_provider.dart';
- import '.../user_profile_provider.dart';

// Add new imports
+ import '.../user_profile_consolidated.dart';
+ import '.../user_state.dart';
+ import '.../user_provider_v2.dart';
```

### Step 2: Replace Provider Usage
```dart
// Old providers
- ref.watch(currentUserProvider)
- ref.watch(userProfileProvider)
- ref.watch(userModelProvider)

// New unified provider
+ ref.watch(currentUserStateProvider)
+ ref.watch(currentUserProfileProvider)  // For quick profile access
+ ref.watch(isPremiumUserProvider)  // For premium check
```

### Step 3: Update Property Access
```dart
// Fix property names
- profile.id
+ profile.uid

// Use built-in helpers
- profile.accountTier == AccountTier.premium || profile.accountTier == AccountTier.pro
+ profile.isPremium

// Safe access
- ref.watch(userProfileProvider).value!.displayName
+ ref.watch(currentUserDisplayNameProvider)  // Never null, defaults to 'Guest'
```

### Step 4: Handle AsyncValue → UserState
```dart
// Old AsyncValue handling
- userProfileAsync.when(
-   data: (profile) => ...,
-   loading: () => ...,
-   error: (e, s) => ...,
- )

// New UserState handling
+ userState.when(
+   authenticated: (profile) => ...,
+   unauthenticated: () => ...,
+   anonymous: () => ...,
+   loading: () => ...,
+   error: (e, s) => ...,
+ )
```

## 🎯 Quick Wins

Use these helper providers for common needs:

```dart
// Instead of complex null checks
final isPremium = ref.watch(isPremiumUserProvider);  // bool
final userId = ref.watch(currentUserIdProvider);  // String?
final displayName = ref.watch(currentUserDisplayNameProvider);  // Never null
final tier = ref.watch(currentAccountTierProvider);  // AccountTier
final quota = ref.watch(templateQuotaProvider);  // TemplateQuota
```

## 📋 Migration Checklist

For each file you migrate:

- [ ] Update imports to use new models
- [ ] Replace all provider references
- [ ] Fix property names (id → uid)
- [ ] Use built-in helpers (isPremium, etc.)
- [ ] Replace AsyncValue with UserState patterns
- [ ] Test authentication flows
- [ ] Test premium features
- [ ] Test error cases

## 🚀 Benefits After Migration

1. **No more null pointer exceptions** - Type safety enforced
2. **Clear data flow** - Single source of truth
3. **Better error handling** - Explicit error states
4. **Easier testing** - Sealed classes are predictable
5. **Less code** - Built-in helpers reduce boilerplate
6. **Faster debugging** - Clear state transitions

## 🆘 Need Help?

If you encounter issues during migration:

1. Check `USER_MODELS_GUIDE.md` for architecture overview
2. Use the migration helpers in `user_provider_v2.dart`
3. Run `flutter analyze` to catch type errors
4. Test with both free and premium accounts

Remember: The goal is to have **ONE** user model (`UserProfile`) and **ONE** state provider (`userStateProvider`) used everywhere!