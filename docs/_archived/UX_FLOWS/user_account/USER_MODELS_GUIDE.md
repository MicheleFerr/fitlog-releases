# 📚 User Models Architecture Guide - UPDATED

> **UPDATED**: October 18, 2025 - Updated with 4 user models and consolidated approach
> **Status**: Current - Matches actual code structure

---

## 🚨 Current Architecture

The codebase has **evolved to a consolidated approach** with these components:

### The Four User Entities

| Model | Location | Purpose | Status |
|-------|----------|---------|--------|
| **1. UserState** | `user_state.dart` | Type-safe state management (sealed class) | ✅ CURRENT |
| **2. UserModel** | `user_model.dart` | Legacy user model | ⚠️ LEGACY |
| **3. UserProfile** | `user_profile.dart` | Old user profile model | ⚠️ LEGACY |
| **4. UserProfileConsolidated** | `user_profile_consolidated.dart` | **NEW: Single source of truth** | ✅ CURRENT |

---

## 📊 Model Evolution

```
┌─────────────────────────────────────────┐
│  Firebase Auth User (Firebase SDK)      │
│  • uid, email, displayName, photoURL    │
└──────────────┬──────────────────────────┘
               │
        ┌──────▼───────┐
        │  Two Paths:  │
        └──────┬───────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ▼                     ▼
┌─────────────┐    ┌──────────────────┐
│  UserModel  │    │  UserProfile     │
│  (Legacy)   │    │  (Old Version)   │
└─────────────┘    └──────────────────┘
    │                     │
    └──────────┬──────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  UserProfileConsolidated             │
│  (CONSOLIDATED - NEW SOURCE OF TRUTH)│
│  • All fields from UserModel         │
│  • All fields from UserProfile       │
│  • Premium tier support             │
│  • Template quota management        │
└──────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  UserState (Sealed Class)            │
│  • UserAuthenticated(UserProfile)   │
│  • UserAnonymous()                  │
│  • UserUnauthenticated()            │
│  • UserLoading()                    │
│  • UserError()                      │
│  (FOR STATE MANAGEMENT)             │
└──────────────────────────────────────┘
```

---

## ✅ Which Model to Use Where

### 1. **UserState** - For State Management
**Use When**: Managing auth state in providers

```dart
// ✅ CORRECT - Use in auth providers
final authProvider = StateNotifierProvider<AuthNotifier, UserState>((ref) {
  return AuthNotifier();
});

// Pattern matching
ref.watch(authProvider).when(
  authenticated: (profile) {
    // User is logged in
    print('Logged in as: ${profile.email}');
  },
  anonymous: () {
    // User is anonymous
  },
  unauthenticated: () {
    // User is not logged in
  },
  loading: () {
    // Loading auth state
  },
  error: (error, st) {
    // Error occurred
  },
);
```

### 2. **UserProfileConsolidated** - For User Data
**Use When**: Accessing user information (PREFERRED - NEW APPROACH)

```dart
// ✅ CORRECT - Use for user data (CURRENT APPROACH)
final currentUserProvider = FutureProvider<UserProfileConsolidated?>((ref) {
  // Fetch from Firestore as UserProfileConsolidated
});

// Access user data
final userProfile = ref.watch(currentUserProvider);
if (userProfile.hasValue && userProfile.value != null) {
  final profile = userProfile.value!;
  print('User email: ${profile.email}');
  print('Account tier: ${profile.accountTier}');
  print('Premium: ${profile.isPremium}');
}
```

### 3. **UserModel** - Legacy (DEPRECATED)
**Status**: ⚠️ Legacy - DO NOT USE in new code

```dart
// ❌ WRONG - Legacy approach
final user = UserModel(...);  // Don't use this

// Use UserProfileConsolidated instead
final user = UserProfileConsolidated(...);  // ✅ Use this
```

### 4. **UserProfile** - Legacy (DEPRECATED)
**Status**: ⚠️ Legacy - Use UserProfileConsolidated instead

```dart
// ❌ WRONG - Old model
UserProfile oldModel = ...;  // Don't use

// ✅ CORRECT - New consolidated model
UserProfileConsolidated newModel = ...;  // Use this
```

---

## 📋 UserProfileConsolidated - The New Standard

### What It Includes

```dart
class UserProfileConsolidated {
  // Firebase User fields
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  // User preferences & stats
  final UserPreferences preferences;
  final UserStats stats;

  // Premium tier system
  final AccountTier accountTier;  // free, premium, pro
  final TemplateQuota templateQuota;

  // Metadata
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isGuest;

  // Helper properties
  bool get isPremium => accountTier != AccountTier.free;
  bool get isPro => accountTier == AccountTier.pro;
  String get displayNameOrEmail => displayName ?? email ?? 'Guest';
}
```

### Account Tiers

```dart
enum AccountTier {
  free,    // Default tier
  premium, // Paid tier with more features
  pro,     // Professional tier with all features
}

// Helper for tier-based checks
profile.accountTier.when(
  free: () => print('Free tier'),
  premium: () => print('Premium features'),
  pro: () => print('Pro features'),
);
```

### Template Quota System

```dart
class TemplateQuota {
  final int maxPrivateTemplates;
  final int maxPublicTemplates;
  final int usedPrivateTemplates;
  final int usedPublicTemplates;

  // Helpers
  bool get canSavePrivate => usedPrivateTemplates < maxPrivateTemplates;
  bool get canSavePublic => usedPublicTemplates < maxPublicTemplates;
  int get remainingPrivate => maxPrivateTemplates - usedPrivateTemplates;
  int get remainingPublic => maxPublicTemplates - usedPublicTemplates;
}

// Tier-based quotas
final quota = TemplateQuota.forTier(AccountTier.premium);
// Premium: 50 private, 10 public
```

---

## 🔄 UserState - Type-Safe State Management

### Sealed Class Pattern

```dart
sealed class UserState {
  const UserState();

  // Pattern matching - ensures all states are handled
  T when<T>({
    required T Function(UserProfile profile) authenticated,
    required T Function() anonymous,
    required T Function() unauthenticated,
    required T Function() loading,
    required T Function(Object error, StackTrace st) error,
  });
}

// Implementations
class UserAuthenticated extends UserState {
  final UserProfileConsolidated profile;
  const UserAuthenticated(this.profile);
}

class UserAnonymous extends UserState {
  const UserAnonymous();
}

class UserUnauthenticated extends UserState {
  const UserUnauthenticated();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserError extends UserState {
  final Object error;
  final StackTrace stackTrace;
  const UserError(this.error, this.stackTrace);
}
```

### Usage Pattern

```dart
// ✅ CORRECT - Forces you to handle all cases
final state = ref.watch(authProvider);

state.when(
  authenticated: (profile) {
    // MUST handle authenticated case
    return UserContent(profile: profile);
  },
  anonymous: () {
    // MUST handle anonymous case
    return AnonymousContent();
  },
  unauthenticated: () {
    // MUST handle unauthenticated case
    return LoginPrompt();
  },
  loading: () {
    // MUST handle loading case
    return LoadingScreen();
  },
  error: (error, st) {
    // MUST handle error case
    return ErrorScreen(error: error);
  },
);
```

---

## 🎯 Migration Guide: Old → New

### From UserModel to UserProfileConsolidated

```dart
// ❌ OLD WAY
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(userModelProvider);  // OLD
    return Text(userModel.email);
  }
}

// ✅ NEW WAY
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);  // NEW
    return authState.when(
      authenticated: (profile) => Text(profile.email),
      anonymous: () => Text('Anonymous'),
      unauthenticated: () => Text('Not logged in'),
      loading: () => Text('Loading...'),
      error: (e, st) => Text('Error'),
    );
  }
}
```

### From UserProfile to UserProfileConsolidated

```dart
// ❌ OLD - Using old UserProfile
UserProfile oldProfile = UserProfile(
  uid: uid,
  email: email,
);

// ✅ NEW - Using consolidated model
UserProfileConsolidated newProfile = UserProfileConsolidated(
  uid: uid,
  email: email,
  accountTier: AccountTier.free,
  templateQuota: TemplateQuota.forTier(AccountTier.free),
);
```

---

## 📝 Common Operations

### Check If User Is Logged In

```dart
// ✅ CORRECT
final authState = ref.watch(authProvider);
final isLoggedIn = authState is UserAuthenticated;

// Or with when
authState.when(
  authenticated: (_) => true,
  orElse: () => false,
);
```

### Get Current User Email

```dart
// ✅ CORRECT
final authState = ref.watch(authProvider);
String? email = authState.maybeWhen(
  authenticated: (profile) => profile.email,
  orElse: () => null,
);
```

### Check If Premium

```dart
// ✅ CORRECT
authState.maybeWhen(
  authenticated: (profile) {
    if (profile.isPremium) {
      // Show premium features
    }
  },
);
```

### Check Template Quota

```dart
// ✅ CORRECT
authState.maybeWhen(
  authenticated: (profile) {
    if (profile.templateQuota.canSavePrivate) {
      // Allow saving template
    } else {
      // Show "quota exceeded" message
    }
  },
);
```

---

## 🚨 Common Mistakes

### ❌ Mistake 1: Direct Access Without Pattern Matching
```dart
// ❌ WRONG - Assumes authenticated without checking
final email = (authState as UserAuthenticated).profile.email;
// Could throw error if not authenticated!

// ✅ CORRECT - Use pattern matching
authState.maybeWhen(
  authenticated: (profile) => profile.email,
  orElse: () => null,
);
```

### ❌ Mistake 2: Using Old UserModel
```dart
// ❌ WRONG - Don't use old model
final user = UserModel(...);

// ✅ CORRECT - Use new consolidated model
final user = UserProfileConsolidated(...);
```

### ❌ Mistake 3: Ignoring Tier System
```dart
// ❌ WRONG - Assumes all users have same limits
if (templatesCount > 100) ...  // Wrong limit for tier

// ✅ CORRECT - Check tier-based quota
if (!profile.templateQuota.canSavePrivate) ...
```

---

## 📂 File Locations

```
lib/features/auth/domain/entities/
├── user_state.dart                    # Sealed state class (NEW)
├── user_profile_consolidated.dart     # New source of truth (NEW)
├── user_model.dart                    # Legacy (DEPRECATED)
└── user_profile.dart                  # Old version (DEPRECATED)
```

---

## 🔗 Related Files

- **Auth Provider**: `lib/features/auth/presentation/providers/auth_provider.dart`
- **User Model Migration Example**: Archive for reference
- **Account Tier System**: Defined in `user_profile_consolidated.dart`
- **Firebase Integration**: Firestore user document structure

---

## ✅ Summary

| Aspect | Use | Don't Use |
|--------|-----|-----------|
| **For State** | `UserState` (sealed class) | Direct access to `Firebase User` |
| **For Data** | `UserProfileConsolidated` | `UserModel` or `UserProfile` |
| **For Tiers** | `AccountTier` enum | Hardcoded tier checks |
| **For Quotas** | `TemplateQuota` class | Manual quota tracking |

---

**Last Updated**: October 18, 2025 - Updated with consolidation approach
**Status**: ✅ CURRENT - Matches actual code
**Next Review**: When auth system changes
