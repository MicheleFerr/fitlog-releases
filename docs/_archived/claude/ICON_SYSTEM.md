# 🎯 TIER-1 ICON DESIGN SYSTEM (MANDATORY)

> **⚠️ CRITICAL**: Sistema icone completo con centralizzazione, semantic sizing, colors, accessibility, animations e badges.

## 📐 1. AppIcons Centralizzate
**SEMPRE** `AppIcons.*` - MAI `Icons.*` | ~445 icone | Import: `app_icons.dart`
```dart
Icon(AppIcons.workout) // ✅ | Icon(Icons.fitness_center) // ❌
```

## 📏 2. AppIconSize
**SEMPRE** `AppIconSize.*` - MAI magic numbers | Sizes: tiny(16), small(20), medium(24), large(28), xlarge(32), xxlarge(48) | Import: `app_icon_size.dart`
```dart
Icon(AppIcons.workout, size: AppIconSize.medium) // ✅ | size: 24 // ❌
```

## 🎨 3. Semantic Icon Colors
**SEMPRE** `context.icon*` - MAI hardcoded | Colors: Primary/Secondary/Tertiary, Success/Error/Warning/Info, Emphasis levels, Workout-specific | Helpers: `iconStateActive()`, `iconProgressColor()`, `iconPriority()` | Import: `app_icon_colors.dart`
```dart
Icon(AppIcons.workout, color: context.iconPrimary) // ✅ | Colors.blue // ❌
```

## ♿ 4. SemanticIcon - Accessibility
**SEMPRE** usa `SemanticIcon` per screen readers | Factories: `.button()`, `.state()` | Import: `semantic_icon.dart`
```dart
SemanticIcon(icon: AppIcons.workout, semanticLabel: context.l10n.start) // ✅
AppIcons.workout.semantic(label: context.l10n.start) // ✅ shorthand
```

## 🎬 5. AnimatedIconPatterns
Patterns: `rotating()`, `pulsing()`, `bouncing()`, `fading()`, `shaking()` | Import: `animated_icon_patterns.dart`
```dart
AnimatedIconPatterns.rotating(icon: AppIcons.loading) // ✅
```

## 🔴 6. BadgedIcon
Factories: `.notification(count)`, `.dot(showDot)` | Extensions: `.withBadge()`, `.withDot()` | Import: `badged_icon.dart`
```dart
AppIcons.notifications.withBadge(count: 3) // ✅
```

## 🔍 7. Icon Showcase
Tool per esplorare 445 icone | Features: search, 11 categories, copy name | Location: `icon_showcase_screen.dart`

## 📦 8-10. Advanced Features (Priority 3)
- **AppIconCategory**: Type-safe 11 categories | `app_icon_category.dart`
- **AppIconVariants**: Filled/outlined toggle (13 variants) | `app_icon_variants.dart` | `ToggleIcon` widget
- **AppIconMetadata**: Rich metadata (descriptions, keywords, semantic labels) | `app_icon_metadata.dart`

## 🚫 Enforcement
Pre-commit hook: blocca `Icons.*` inline, warn su `Icon()` senza SemanticIcon/hardcoded sizes | 100% coverage (~445 icone)

## ⚡ Quick Examples
```dart
SemanticIcon(icon: AppIcons.workout, semanticLabel: context.l10n.start, size: AppIconSize.large, color: context.iconPrimary)
AppIcons.notifications.withBadge(count: 3) // Badge
AnimatedIconPatterns.rotating(icon: AppIcons.loading) // Animation
Icon(AppIcons.wifi, color: context.iconStateActive(isConnected)) // State color
```
