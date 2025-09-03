# 📚 User Models Architecture Guide

> **IMPORTANT**: This guide documents the user model architecture in GymBro and provides clear guidelines on which model to use in each layer.

## 🚨 Current Problems

The codebase currently has **3 different user models** causing confusion:

1. **Firebase `User`** - From FirebaseAuth
2. **`UserModel`** - Custom model with preferences and stats
3. **`UserProfile`** - Extended model with premium tiers and quotas

This causes:
- ❌ Build errors when using wrong properties (e.g., `User.isPremium` doesn't exist)
- ❌ Confusion about which provider to use
- ❌ Data duplication and sync issues
- ❌ Type safety problems

## 📊 Current Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Firebase Auth                         │
│                  User (Firebase SDK)                     │
│            • uid, email, displayName, photoURL          │
└─────────────────┬───────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────┐
│                    UserModel (Legacy)                    │
│              lib/features/auth/domain/entities/          │
│        • All Firebase User fields                        │
│        • preferences (UserPreferences)                   │
│        • stats (UserStats)                              │
│        • isGuest                                        │
└─────────────────┬───────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────┐
│                  UserProfile (Current)                   │
│              lib/features/auth/domain/entities/          │
│        • All UserModel fields                            │
│        • accountTier (free/premium/pro)                  │
│        • templateQuota                                   │
│        • isPremium helper                                │
└─────────────────────────────────────────────────────────┘
```

## ✅ Which Model to Use Where

### 🔐 Authentication Layer
```dart
// ✅ USE: Firebase User + currentUserProvider
import 'package:firebase_auth/firebase_auth.dart';
import '.../providers/current_user_provider.dart';

final user = ref.watch(currentUserProvider).value;
final uid = user?.uid;
final isAuthenticated = user != null;
```

**When to use:**
- Checking if user is logged in
- Getting basic auth info (uid, email)
- Auth state changes
- Sign in/out operations

### 💼 Business Logic Layer
```dart
// ✅ USE: UserProfile + userProfileProvider
import '.../entities/user_profile.dart';
import '.../providers/user_profile_provider.dart';

final userProfile = ref.watch(userProfileProvider).value;
final isPremium = userProfile?.isPremium ?? false;
final tier = userProfile?.accountTier ?? AccountTier.free;
```

**When to use:**
- Checking premium features
- Template quotas
- User preferences
- User statistics
- Any business logic

### 🎨 Presentation Layer
```dart
// ✅ USE: UserProfile for display
final userProfile = ref.watch(userProfileProvider).value;

Text(userProfile?.displayName ?? 'Guest')
if (userProfile?.isPremium == true) PremiumBadge()
```

**When to use:**
- Displaying user info
- Conditional UI based on tier
- Settings screens
- Profile screens

## 🔄 Provider Dependencies

```dart
// Current correct flow:
FirebaseAuth.authStateChanges() 
    ↓
currentUserProvider (StreamProvider<User?>)
    ↓
userProfileProvider (StreamProvider<UserProfile?>)
    ↓
All feature providers
```

## ⚠️ Common Mistakes to Avoid

### ❌ DON'T: Mix Models
```dart
// ❌ WRONG - Firebase User doesn't have isPremium
final user = ref.watch(currentUserProvider).value;
if (user.isPremium) { ... } // COMPILE ERROR!

// ❌ WRONG - Using wrong property name
final profile = ref.watch(userProfileProvider).value;
final id = profile.id; // ERROR: Should be 'uid'
```

### ✅ DO: Use Correct Model
```dart
// ✅ CORRECT - Use UserProfile for premium
final profile = ref.watch(userProfileProvider).value;
if (profile?.isPremium == true) { ... }

// ✅ CORRECT - Use correct property
final uid = profile?.uid;
```

### ❌ DON'T: Access Nested Properties Without Null Checks
```dart
// ❌ WRONG - Can crash
final isPremium = ref.watch(userProfileProvider).value!.isPremium;

// ❌ WRONG - AsyncValue not handled
final userId = ref.watch(userProfileProvider).id; // No .value!
```

### ✅ DO: Handle AsyncValue Properly
```dart
// ✅ CORRECT - Safe access
final userProfileAsync = ref.watch(userProfileProvider);
final isPremium = userProfileAsync.value?.isPremium ?? false;

// ✅ CORRECT - With loading state
userProfileAsync.when(
  data: (profile) => Text(profile?.displayName ?? 'Guest'),
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);
```

## 🎯 Migration Plan

### Phase 1: Documentation (COMPLETED ✅)
- Document current state
- Create this guide
- Identify all usage points

### Phase 2: Consolidation (IN PROGRESS)
1. **Deprecate UserModel** - Migrate all usage to UserProfile
2. **Rename confusing properties** - Ensure consistency
3. **Add type safety** - Use sealed classes where appropriate

### Phase 3: Type Safety Enhancement
```dart
// Future improvement: Sealed classes for better type safety
sealed class UserState {}
class UserAuthenticated extends UserState {
  final UserProfile profile;
  UserAuthenticated(this.profile);
}
class UserAnonymous extends UserState {}
class UserUnauthenticated extends UserState {}
```

## 📝 Quick Reference Cheat Sheet

| Need to...                  | Use Provider              | Get Property           |
|-----------------------------|---------------------------|------------------------|
| Check if logged in          | currentUserProvider       | user != null           |
| Get user ID                 | currentUserProvider       | user?.uid              |
| Get email                   | currentUserProvider       | user?.email            |
| Check if premium            | userProfileProvider       | profile?.isPremium     |
| Get account tier            | userProfileProvider       | profile?.accountTier   |
| Get display name            | userProfileProvider       | profile?.displayName   |
| Get preferences             | userProfileProvider       | profile?.preferences   |
| Get statistics              | userProfileProvider       | profile?.stats         |
| Get template quota          | userProfileProvider       | profile?.templateQuota |

## 🔍 Finding Usage in Code

```bash
# Find all Firebase User usage
grep -r "User?" lib/ | grep -v UserProfile | grep -v UserModel

# Find all UserModel usage (to migrate)
grep -r "UserModel" lib/

# Find all UserProfile usage (current standard)
grep -r "UserProfile" lib/

# Find provider usage
grep -r "currentUserProvider\|userProfileProvider" lib/
```

## 🚀 Best Practices

1. **Always use UserProfile for business logic**
2. **Only use Firebase User for auth operations**
3. **Handle AsyncValue properly with .value?**
4. **Never assume properties exist - use null safety**
5. **Document which model you're using in comments**

## 🛠️ Tooling

### VSCode Snippet for Safe User Access
```json
{
  "Safe User Profile Access": {
    "prefix": "userprofile",
    "body": [
      "final userProfileAsync = ref.watch(userProfileProvider);",
      "final userProfile = userProfileAsync.value;",
      "if (userProfile == null) return ${1:Container()};",
      "$0"
    ],
    "description": "Safe UserProfile access with null check"
  }
}
```

## 📅 Maintenance

- **Last Updated**: 2025-01-21
- **Next Review**: After UserModel deprecation
- **Owner**: Architecture Team

---

> 💡 **Remember**: When in doubt, use `UserProfile` with `userProfileProvider` for all business logic and UI display. Only use Firebase `User` for authentication state.