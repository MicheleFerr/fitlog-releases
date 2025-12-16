# Tier Rewards Refactoring Plan

**Date**: 2024-12-08
**Status**: Ready for Implementation
**Objective**: Remove Journey Themes, implement tier-based functional rewards

---

## Executive Summary

Replace cosmetic Journey Themes (7 themes with unlockable visual features) with functional tier-based rewards that provide real value to users.

### Tier Rewards Matrix

| Feature | Starter (0 XP) | Bronze (100 XP) | Silver (500 XP) | Gold (1500 XP) | Platinum (5000 XP) |
|---------|----------------|-----------------|-----------------|----------------|-------------------|
| **Private Templates** | 4 | 4 | 5 | 5 | 7 |
| **Banner Ads** | Yes | Yes | Yes | Yes | **No** |
| **Pro Analytics** | No | No | No | No | **Yes** |
| **Cloud Sync** | No | No | No | No | **Yes** |
| **Rest Timers** | Unlimited | Unlimited | Unlimited | Unlimited | Unlimited |

---

## Architecture

### Pattern: Entitlement System (PDP/PEP)

Based on [RevenueCat Common Architecture](https://www.revenuecat.com/docs/guides/common-architecture) and [Qonversion Entitlement Engine](https://qonversion.io/blog/subscription-entitlement/).

```
┌─────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ UserTier (Enhanced Enum)                            │    │
│  │ - minXP, displayName, color                         │    │
│  │ - maxTemplates, showAds, hasProAnalytics, hasCloud  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ tierEntitlementsProvider (PDP - Policy Decision)    │    │
│  │ - Reads userTierProvider                            │    │
│  │ - Exposes entitlement checks                        │    │
│  └─────────────────────────────────────────────────────┘    │
│                              │                               │
│         ┌────────────────────┼────────────────────┐         │
│         ▼                    ▼                    ▼         │
│  shouldShowAdsProvider  maxTemplatesProvider  hasProAnalytics│
│  (PEP - Enforcement)    (PEP - Enforcement)   (PEP)         │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Tasks

### Task 1: Create UserTier in Domain Layer

**File**: `lib/core/domain/entities/user_tier.dart`

**Why**: Currently `UserTier` is in presentation layer (`compact_profile_header.dart`) - violates Clean Architecture.

```dart
import 'package:flutter/material.dart';

/// User tier based on XP with entitlements
///
/// Pattern: Enhanced Enum (Dart 3) with embedded entitlement properties
/// This is the single source of truth for tier definitions and rewards.
enum UserTier {
  starter(
    minXP: 0,
    displayName: 'Starter',
    color: Color(0xFF9E9E9E),
    maxTemplates: 4,
    showAds: true,
    hasProAnalytics: false,
    hasCloudSync: false,
  ),
  bronze(
    minXP: 100,
    displayName: 'Bronze',
    color: Color(0xFFCD7F32),
    maxTemplates: 4,
    showAds: true,
    hasProAnalytics: false,
    hasCloudSync: false,
  ),
  silver(
    minXP: 500,
    displayName: 'Silver',
    color: Color(0xFFC0C0C0),
    maxTemplates: 5,
    showAds: true,
    hasProAnalytics: false,
    hasCloudSync: false,
  ),
  gold(
    minXP: 1500,
    displayName: 'Gold',
    color: Color(0xFFFFD700),
    maxTemplates: 5,
    showAds: true,
    hasProAnalytics: false,
    hasCloudSync: false,
  ),
  platinum(
    minXP: 5000,
    displayName: 'Platinum',
    color: Color(0xFFE5E4E2),
    maxTemplates: 7,
    showAds: false,
    hasProAnalytics: true,
    hasCloudSync: true,
  );

  const UserTier({
    required this.minXP,
    required this.displayName,
    required this.color,
    required this.maxTemplates,
    required this.showAds,
    required this.hasProAnalytics,
    required this.hasCloudSync,
  });

  final int minXP;
  final String displayName;
  final Color color;

  // Entitlements
  final int maxTemplates;
  final bool showAds;
  final bool hasProAnalytics;
  final bool hasCloudSync;

  /// Get tier for given XP amount
  static UserTier fromXP(int xp) {
    if (xp >= platinum.minXP) return platinum;
    if (xp >= gold.minXP) return gold;
    if (xp >= silver.minXP) return silver;
    if (xp >= bronze.minXP) return bronze;
    return starter;
  }

  /// Get next tier (or null if max)
  UserTier? get next {
    final index = UserTier.values.indexOf(this);
    if (index >= UserTier.values.length - 1) return null;
    return UserTier.values[index + 1];
  }

  /// Calculate progress to next tier (0.0 to 1.0)
  double progressToNext(int currentXP) {
    final nextTier = next;
    if (nextTier == null) return 1.0;

    final xpInCurrentTier = currentXP - minXP;
    final xpNeededForNext = nextTier.minXP - minXP;

    return (xpInCurrentTier / xpNeededForNext).clamp(0.0, 1.0);
  }
}
```

---

### Task 2: Create Tier Entitlements Provider

**File**: `lib/core/presentation/providers/tier_entitlements_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/features/home/providers/user_xp_provider.dart';

/// Centralized entitlement provider (Policy Decision Point)
///
/// Pattern: PDP from entitlement architecture
/// All access decisions should go through this provider.
final tierEntitlementsProvider = Provider<TierEntitlements>((ref) {
  final tier = ref.watch(userTierProvider);
  return TierEntitlements(tier);
});

/// Entitlements wrapper with helper methods
class TierEntitlements {
  TierEntitlements(this._tier);
  final UserTier _tier;

  UserTier get tier => _tier;
  int get maxTemplates => _tier.maxTemplates;
  bool get shouldShowAds => _tier.showAds;
  bool get hasProAnalytics => _tier.hasProAnalytics;
  bool get hasCloudSync => _tier.hasCloudSync;

  /// Check if user can save another template
  bool canSaveTemplate(int currentCount) => currentCount < maxTemplates;

  /// Get remaining template slots
  int remainingTemplates(int currentCount) =>
      (maxTemplates - currentCount).clamp(0, maxTemplates);
}

// ============================================================
// SELECTIVE PROVIDERS (Performance optimization)
// Use .select() to avoid unnecessary rebuilds
// ============================================================

/// Whether to show banner ads
final shouldShowAdsProvider = Provider<bool>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.shouldShowAds),
  );
});

/// Maximum templates user can save
final maxTemplatesProvider = Provider<int>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.maxTemplates),
  );
});

/// Whether user has Pro Analytics access
final hasProAnalyticsProvider = Provider<bool>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.hasProAnalytics),
  );
});

/// Whether user has Cloud Sync access
final hasCloudSyncProvider = Provider<bool>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.hasCloudSync),
  );
});
```

---

### Task 3: Update compact_profile_header.dart

**Action**: Remove `UserTier` enum definition, import from new location.

```dart
// BEFORE
enum UserTier {
  starter(0, 'Starter', Color(0xFF9E9E9E)),
  // ... 60+ lines of enum definition
}

// AFTER
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
// Just use UserTier from import
```

---

### Task 4: Update user_xp_provider.dart

**File**: `lib/features/home/providers/user_xp_provider.dart`

**Action**: Change import from `compact_profile_header.dart` to new location.

```dart
// BEFORE
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';

// AFTER
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
```

---

### Task 5: Delete Journey Themes

**Files to DELETE** (entire folder):
```
lib/features/journey_themes/
├── domain/
│   ├── entities/
│   │   ├── journey_theme.dart
│   │   ├── journey_theme_config.dart
│   │   ├── journey_theme_config.g.dart
│   │   └── unlockable_feature.dart
│   └── services/
│       └── journey_greeting_service.dart
├── data/
│   └── repositories/
│       └── journey_theme_repository.dart
└── presentation/
    ├── providers/
    │   └── journey_theme_provider.dart
    ├── widgets/
    │   ├── journey_theme_card.dart
    │   ├── journey_theme_selector_modal.dart
    │   └── theme_features_breakdown.dart
    └── theme/
        └── journey_theme_extension.dart
```

**Command**:
```bash
rm -rf lib/features/journey_themes/
```

---

### Task 6: Update Files with Journey Theme References

| File | Action |
|------|--------|
| `lib/app/app.dart` | Remove JourneyTheme initialization |
| `lib/core/navigation/main_shell.dart` | Remove `context.journeyTheme?.primaryColor`, use `context.colors.primary` |
| `lib/features/profile/presentation/widgets/settings_bottom_sheet.dart` | Remove theme selector option |
| `lib/features/settings/presentation/settings_screen.dart` | Remove journey theme settings |
| `lib/features/home/presentation/widgets/ai_coach_card.dart` | Remove journeyTheme references |
| `lib/features/workout/presentation/widgets/workout_completion_celebration.dart` | Remove theme-based colors |
| `lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_orchestrator.dart` | Remove journeyTheme references |
| `lib/features/home/presentation/minimal_home_screen.dart` | Remove journeyTheme references |
| `lib/shared/presentation/extensions/build_context_extensions.dart` | Remove `journeyTheme` extension |

---

### Task 7: Integrate Entitlements at Enforcement Points

#### 7.1 Banner Ads (`lib/shared/presentation/widgets/adaptive_banner_ad.dart`)

```dart
// Add to build method
final showAds = ref.watch(shouldShowAdsProvider);
if (!showAds) return const SizedBox.shrink();
// ... rest of ad logic
```

#### 7.2 Template Quota Check

Update template save logic to use `maxTemplatesProvider` instead of `TemplateQuota.forTier()`.

#### 7.3 Pro Analytics Gate

```dart
// In pro_analytics_screen.dart or pro_analytics_section.dart
final hasAccess = ref.watch(hasProAnalyticsProvider);
if (!hasAccess) {
  return _LockedProAnalyticsWidget();
}
```

#### 7.4 Cloud Sync Gate

```dart
// In cloud sync settings
final hasCloudSync = ref.watch(hasCloudSyncProvider);
if (!hasCloudSync) {
  return _LockedCloudSyncWidget();
}
```

---

### Task 8: Update Localization

Remove journey theme related strings from:
- `assets/i18n/app_en.arb`
- `assets/i18n/app_it.arb`

Then run: `flutter gen-l10n`

---

### Task 9: Clean Up Hive TypeAdapters

Remove from Hive registration (in `main.dart` or wherever Hive is initialized):
- `JourneyThemeAdapter` (typeId: 71)
- `JourneyThemeConfigAdapter` (typeId: 70)

---

## Verification Checklist

- [ ] `flutter analyze` passes with no errors
- [ ] `flutter test` passes (if applicable)
- [ ] App builds successfully on iOS
- [ ] App builds successfully on Android
- [ ] UserTier correctly determines entitlements
- [ ] Banner ads hidden for Platinum users
- [ ] Pro Analytics locked for non-Platinum users
- [ ] Cloud Sync locked for non-Platinum users
- [ ] Template limits enforced per tier

---

## Rollback Plan

If issues arise:
1. Revert commits
2. Re-add `lib/features/journey_themes/` from git history
3. Restore imports in affected files

---

## References

- [RevenueCat: Common Architecture](https://www.revenuecat.com/docs/guides/common-architecture)
- [Qonversion: Subscription Entitlement](https://qonversion.io/blog/subscription-entitlement/)
- [Flutter Riverpod 2.0 Guide](https://codewithandrea.com/articles/flutter-state-management-riverpod/)
- [Enhanced Enums in Flutter 3.0](https://blog.logrocket.com/deep-dive-enhanced-enums-flutter-3-0/)
