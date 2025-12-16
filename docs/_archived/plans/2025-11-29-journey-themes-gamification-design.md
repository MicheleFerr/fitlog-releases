# Journey Themes - Gamification System Design

**Generated**: 2025-11-29
**Source**: Claude Code (research + codebase analysis)
**Complexity Score**: HIGH
**Reason**: New gamification feature + Multi-layer ThemeExtension + 6 themes + ~120 unlock combinations
**Total Tasks**: 18
**Estimated Time**: ~12-15h
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.24.5
- Key Packages: riverpod ^2.4.9, hive ^2.2.3
- Target Platforms: iOS 14+, Android 8+
- Related Features: UserTier (compact_profile_header.dart), appConfigProvider
- Parent Milestone: Premium/Gamification Features

---

## 1. Original Request

> "ok va bene, pero quello che farei e dare accesso a tutti i journei ma bloccarne alcune cose che si sbloccano via via con i livelli, cosi fin da subito una persona si sente padrona di personalizzare la propria app"

**Key Insight**: User wants ALL themes accessible from Day 1, but with features WITHIN each theme progressively unlockable based on XP tiers. This creates:
- Immediate psychological ownership (IKEA Effect)
- Progressive disclosure of complexity
- Sustained engagement through unlock goals

---

## 2. Research Findings

### 2.1 Psychology & Marketing Research

| Finding | Source | Impact on Design |
|---------|--------|------------------|
| IKEA Effect | Behavioral Economics | Users value customized products 63% more |
| Day 1 Customization | Mobile App Retention Studies | 77% users abandon apps in 3 days - immediate personalization critical |
| Progressive Disclosure | UX Patterns | Reduces cognitive load, increases engagement |
| Gamification Retention | Mockplus Research | 29% better Day 1, 36% Day 7, 34% Day 30 retention |
| Psychological Ownership | Marketing Psychology | Immediate access creates emotional investment |

### 2.2 Flutter/Technical Best Practices

| Pattern | Source | Application |
|---------|--------|-------------|
| ThemeExtension | flutter.dev 2024 | Custom theme properties (NOT extension methods) |
| DraggableScrollableSheet | Flutter docs | 80%→95% expandable modal |
| Design Tokens | Material 3 | Reference → Semantic → Component tokens |
| Glassmorphism Blur | iOS 26 "Liquid Glass" | Locked content preview (premium_feature_card.dart) |

### 2.3 Codebase Patterns Identified

| Pattern | File | Reuse Strategy |
|---------|------|----------------|
| 80%→95% expand modal | `level_info_modal.dart` | AnimatedContainer pattern |
| Blur overlay for locked | `premium_feature_card.dart` | BackdropFilter + gradient |
| UserTier enum | `compact_profile_header.dart` | Direct reuse |
| Modal service | `modal_service.dart` | Extend with `showThemeSelector` |
| PageView carousel | `insights_carousel.dart` | Horizontal theme selection |
| AppConfig persistence | `app_config_provider.dart` | Add journeyTheme field |

---

## 3. Journey Themes Specification

### 3.1 Theme Definitions

| Theme | Emoji | Primary | Secondary | Tagline | Style |
|-------|-------|---------|-----------|---------|-------|
| Hunter | `#FF5722` Deep Orange | `#795548` Brown | "Track your prey" | Anime/action |
| Hero | `#1976D2` Royal Blue | `#7C4DFF` Purple | "Rise to legend" | Fantasy/epic |
| Warrior Goddess | `#9C27B0` Purple | `#E91E63` Pink | "Elegant power" | Elegant/feminine |
| Nature Spirit | `#4CAF50` Green | `#8BC34A` Light Green | "Flow with nature" | Calm/organic |
| Phoenix | `#F44336` Red | `#FF9800` Orange | "Rise from ashes" | Transformation |
| Frost | `#03A9F4` Light Blue | `#B3E5FC` Ice | "Cold precision" | Minimal/cool |

### 3.2 Unlock Structure (Per Theme)

| Tier | Min XP | Unlockable Features |
|------|--------|---------------------|
| **Starter** (0 XP) | 0 | Primary Color, Card Background, Basic Button Style |
| **Bronze** (100 XP) | 100 | Secondary Color, Card Border, Button Hover Effect |
| **Silver** (500 XP) | 500 | Accent Color, Progress Bar Style, Input Fields |
| **Gold** (1500 XP) | 1500 | Glow/Shadow Effects, Animations, Special Icons |
| **Platinum** (5000 XP) | 5000 | App Icon, Custom Sounds, Premium Particles |

**Total Features per Theme**: ~15-18
**Total Combinations**: ~108 (6 themes × 18 features)

---

## 4. Architecture Design

### 4.1 File Structure

```
lib/features/journey_themes/
├── domain/
│   ├── entities/
│   │   ├── journey_theme.dart              # JourneyTheme enum
│   │   ├── journey_theme_config.dart       # Hive-persisted config
│   │   └── unlockable_feature.dart         # Feature definition
│   └── services/
│       └── theme_unlock_service.dart       # Unlock logic
├── data/
│   ├── repositories/
│   │   └── journey_theme_repository.dart   # Hive persistence
│   └── tokens/
│       ├── journey_color_tokens.dart       # Color definitions
│       ├── journey_shape_tokens.dart       # BorderRadius, shadows
│       ├── journey_effect_tokens.dart      # Glow, particles
│       └── journey_animation_tokens.dart   # Durations, curves
├── presentation/
│   ├── providers/
│   │   └── journey_theme_provider.dart     # Riverpod state
│   ├── widgets/
│   │   ├── journey_theme_selector_modal.dart  # Main selector UI
│   │   ├── journey_theme_card.dart            # Theme preview card
│   │   ├── feature_row.dart                   # Lock/unlock row
│   │   └── theme_preview_widget.dart          # Live preview
│   └── extensions/
│       └── journey_theme_extension.dart    # ThemeExtension<JourneyThemeExtension>
└── index.dart                              # Barrel export
```

### 4.2 Domain Layer

#### JourneyTheme Enum

```dart
/// lib/features/journey_themes/domain/entities/journey_theme.dart
enum JourneyTheme {
  hunter(
    emoji: '',
    displayName: 'Hunter',
    tagline: 'Track your prey',
    primaryColor: Color(0xFFFF5722),
    secondaryColor: Color(0xFF795548),
    accentColor: Color(0xFFFFAB91),
  ),
  hero(
    emoji: '',
    displayName: 'Hero',
    tagline: 'Rise to legend',
    primaryColor: Color(0xFF1976D2),
    secondaryColor: Color(0xFF7C4DFF),
    accentColor: Color(0xFF82B1FF),
  ),
  warriorGoddess(
    emoji: '',
    displayName: 'Warrior Goddess',
    tagline: 'Elegant power',
    primaryColor: Color(0xFF9C27B0),
    secondaryColor: Color(0xFFE91E63),
    accentColor: Color(0xFFF8BBD9),
  ),
  natureSpirit(
    emoji: '',
    displayName: 'Nature Spirit',
    tagline: 'Flow with nature',
    primaryColor: Color(0xFF4CAF50),
    secondaryColor: Color(0xFF8BC34A),
    accentColor: Color(0xFFC8E6C9),
  ),
  phoenix(
    emoji: '',
    displayName: 'Phoenix',
    tagline: 'Rise from ashes',
    primaryColor: Color(0xFFF44336),
    secondaryColor: Color(0xFFFF9800),
    accentColor: Color(0xFFFFEB3B),
  ),
  frost(
    emoji: '',
    displayName: 'Frost',
    tagline: 'Cold precision',
    primaryColor: Color(0xFF03A9F4),
    secondaryColor: Color(0xFFB3E5FC),
    accentColor: Color(0xFFE1F5FE),
  );

  const JourneyTheme({
    required this.emoji,
    required this.displayName,
    required this.tagline,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  final String emoji;
  final String displayName;
  final String tagline;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  /// Get features unlocked at current tier
  List<UnlockableFeature> getUnlockedFeatures(UserTier tier) {
    return UnlockableFeature.forTheme(this)
        .where((f) => tier.minXP >= f.requiredTier.minXP)
        .toList();
  }

  /// Calculate unlock percentage
  double getUnlockPercentage(UserTier tier) {
    final all = UnlockableFeature.forTheme(this);
    final unlocked = getUnlockedFeatures(tier);
    return all.isEmpty ? 0 : unlocked.length / all.length;
  }

  int getUnlockedFeaturesCount(UserTier tier) => getUnlockedFeatures(tier).length;
  int get totalFeatures => UnlockableFeature.forTheme(this).length;
}
```

#### UnlockableFeature

```dart
/// lib/features/journey_themes/domain/entities/unlockable_feature.dart
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';

enum FeatureCategory {
  colors,
  cards,
  buttons,
  progress,
  effects,
  icons,
}

class UnlockableFeature {
  const UnlockableFeature({
    required this.id,
    required this.name,
    required this.category,
    required this.requiredTier,
    required this.description,
  });

  final String id;
  final String name;
  final FeatureCategory category;
  final UserTier requiredTier;
  final String description;

  /// Get all features for a theme (same structure for all themes)
  static List<UnlockableFeature> forTheme(JourneyTheme theme) {
    return [
      // Starter (0 XP)
      const UnlockableFeature(
        id: 'primary_color',
        name: 'Primary Color',
        category: FeatureCategory.colors,
        requiredTier: UserTier.starter,
        description: 'Main theme color for buttons and accents',
      ),
      const UnlockableFeature(
        id: 'card_background',
        name: 'Card Background',
        category: FeatureCategory.cards,
        requiredTier: UserTier.starter,
        description: 'Background color for content cards',
      ),
      const UnlockableFeature(
        id: 'basic_button',
        name: 'Basic Button Style',
        category: FeatureCategory.buttons,
        requiredTier: UserTier.starter,
        description: 'Standard button appearance',
      ),

      // Bronze (100 XP)
      const UnlockableFeature(
        id: 'secondary_color',
        name: 'Secondary Color',
        category: FeatureCategory.colors,
        requiredTier: UserTier.bronze,
        description: 'Accent color for secondary elements',
      ),
      const UnlockableFeature(
        id: 'card_border',
        name: 'Card Border Style',
        category: FeatureCategory.cards,
        requiredTier: UserTier.bronze,
        description: 'Custom border for cards',
      ),
      const UnlockableFeature(
        id: 'button_hover',
        name: 'Button Hover Effect',
        category: FeatureCategory.buttons,
        requiredTier: UserTier.bronze,
        description: 'Interactive button feedback',
      ),

      // Silver (500 XP)
      const UnlockableFeature(
        id: 'accent_color',
        name: 'Accent Color',
        category: FeatureCategory.colors,
        requiredTier: UserTier.silver,
        description: 'Highlight color for emphasis',
      ),
      const UnlockableFeature(
        id: 'progress_bar',
        name: 'Progress Bar Style',
        category: FeatureCategory.progress,
        requiredTier: UserTier.silver,
        description: 'Custom progress indicators',
      ),
      const UnlockableFeature(
        id: 'input_fields',
        name: 'Input Field Style',
        category: FeatureCategory.cards,
        requiredTier: UserTier.silver,
        description: 'Custom text field appearance',
      ),

      // Gold (1500 XP)
      const UnlockableFeature(
        id: 'glow_effects',
        name: 'Glow Effects',
        category: FeatureCategory.effects,
        requiredTier: UserTier.gold,
        description: 'Ambient glow on UI elements',
      ),
      const UnlockableFeature(
        id: 'animations',
        name: 'Theme Animations',
        category: FeatureCategory.effects,
        requiredTier: UserTier.gold,
        description: 'Custom transition animations',
      ),
      const UnlockableFeature(
        id: 'special_icons',
        name: 'Special Icons',
        category: FeatureCategory.icons,
        requiredTier: UserTier.gold,
        description: 'Theme-specific icon variants',
      ),

      // Platinum (5000 XP)
      const UnlockableFeature(
        id: 'app_icon',
        name: 'App Icon',
        category: FeatureCategory.icons,
        requiredTier: UserTier.platinum,
        description: 'Custom home screen icon',
      ),
      const UnlockableFeature(
        id: 'custom_sounds',
        name: 'Custom Sounds',
        category: FeatureCategory.effects,
        requiredTier: UserTier.platinum,
        description: 'Theme-specific audio feedback',
      ),
      const UnlockableFeature(
        id: 'particles',
        name: 'Particle Effects',
        category: FeatureCategory.effects,
        requiredTier: UserTier.platinum,
        description: 'Premium visual particles',
      ),
    ];
  }
}
```

#### JourneyThemeConfig (Hive)

```dart
/// lib/features/journey_themes/domain/entities/journey_theme_config.dart
import 'package:hive/hive.dart';

part 'journey_theme_config.g.dart';

@HiveType(typeId: 50) // New typeId for Journey themes
class JourneyThemeConfig {
  const JourneyThemeConfig({
    this.selectedTheme = JourneyTheme.hunter,
    this.previewMode = false,
  });

  @HiveField(0)
  final JourneyTheme selectedTheme;

  @HiveField(1)
  final bool previewMode;

  JourneyThemeConfig copyWith({
    JourneyTheme? selectedTheme,
    bool? previewMode,
  }) {
    return JourneyThemeConfig(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      previewMode: previewMode ?? this.previewMode,
    );
  }
}

// Adapter for JourneyTheme enum
@HiveType(typeId: 51)
class JourneyThemeAdapter extends TypeAdapter<JourneyTheme> {
  @override
  final typeId = 51;

  @override
  JourneyTheme read(BinaryReader reader) {
    final index = reader.readInt();
    return JourneyTheme.values[index];
  }

  @override
  void write(BinaryWriter writer, JourneyTheme obj) {
    writer.writeInt(obj.index);
  }
}
```

### 4.3 Presentation Layer

#### JourneyThemeExtension (ThemeData integration)

```dart
/// lib/features/journey_themes/presentation/extensions/journey_theme_extension.dart
import 'package:flutter/material.dart';

class JourneyThemeExtension extends ThemeExtension<JourneyThemeExtension> {
  const JourneyThemeExtension({
    required this.theme,
    required this.userTier,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.cardBackgroundColor,
    required this.cardBorderColor,
    required this.cardBorderRadius,
    required this.buttonBorderRadius,
    required this.progressBarColor,
    required this.glowEnabled,
    required this.glowColor,
    required this.animationDuration,
    required this.animationCurve,
  });

  final JourneyTheme theme;
  final UserTier userTier;

  // Colors (unlock at different tiers)
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  // Cards
  final Color cardBackgroundColor;
  final Color cardBorderColor;
  final BorderRadius cardBorderRadius;

  // Buttons
  final BorderRadius buttonBorderRadius;

  // Progress
  final Color progressBarColor;

  // Effects (Gold+)
  final bool glowEnabled;
  final Color glowColor;

  // Animations
  final Duration animationDuration;
  final Curve animationCurve;

  /// Factory to create extension based on theme and tier
  factory JourneyThemeExtension.fromThemeAndTier({
    required JourneyTheme theme,
    required UserTier tier,
    required Brightness brightness,
  }) {
    final isUnlocked = (UserTier requiredTier) => tier.minXP >= requiredTier.minXP;

    return JourneyThemeExtension(
      theme: theme,
      userTier: tier,
      // Colors - unlock progressively
      primaryColor: isUnlocked(UserTier.starter)
          ? theme.primaryColor
          : _defaultPrimary(brightness),
      secondaryColor: isUnlocked(UserTier.bronze)
          ? theme.secondaryColor
          : _defaultSecondary(brightness),
      accentColor: isUnlocked(UserTier.silver)
          ? theme.accentColor
          : _defaultAccent(brightness),
      // Cards
      cardBackgroundColor: isUnlocked(UserTier.starter)
          ? theme.primaryColor.withValues(alpha: 0.05)
          : Colors.transparent,
      cardBorderColor: isUnlocked(UserTier.bronze)
          ? theme.primaryColor.withValues(alpha: 0.2)
          : Colors.transparent,
      cardBorderRadius: BorderRadius.circular(16),
      // Buttons
      buttonBorderRadius: BorderRadius.circular(12),
      // Progress
      progressBarColor: isUnlocked(UserTier.silver)
          ? theme.primaryColor
          : _defaultPrimary(brightness),
      // Effects
      glowEnabled: isUnlocked(UserTier.gold),
      glowColor: theme.primaryColor.withValues(alpha: 0.3),
      // Animations
      animationDuration: isUnlocked(UserTier.gold)
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 200),
      animationCurve: Curves.easeInOut,
    );
  }

  static Color _defaultPrimary(Brightness brightness) =>
      brightness == Brightness.light
          ? const Color(0xFF1976D2)
          : const Color(0xFF90CAF9);

  static Color _defaultSecondary(Brightness brightness) =>
      brightness == Brightness.light
          ? const Color(0xFF757575)
          : const Color(0xFFBDBDBD);

  static Color _defaultAccent(Brightness brightness) =>
      brightness == Brightness.light
          ? const Color(0xFFFF5722)
          : const Color(0xFFFFAB91);

  @override
  JourneyThemeExtension copyWith({
    JourneyTheme? theme,
    UserTier? userTier,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? cardBackgroundColor,
    Color? cardBorderColor,
    BorderRadius? cardBorderRadius,
    BorderRadius? buttonBorderRadius,
    Color? progressBarColor,
    bool? glowEnabled,
    Color? glowColor,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return JourneyThemeExtension(
      theme: theme ?? this.theme,
      userTier: userTier ?? this.userTier,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      progressBarColor: progressBarColor ?? this.progressBarColor,
      glowEnabled: glowEnabled ?? this.glowEnabled,
      glowColor: glowColor ?? this.glowColor,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  @override
  JourneyThemeExtension lerp(JourneyThemeExtension? other, double t) {
    if (other == null) return this;
    return JourneyThemeExtension(
      theme: t < 0.5 ? theme : other.theme,
      userTier: t < 0.5 ? userTier : other.userTier,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      cardBackgroundColor: Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t)!,
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t)!,
      cardBorderRadius: BorderRadius.lerp(cardBorderRadius, other.cardBorderRadius, t)!,
      buttonBorderRadius: BorderRadius.lerp(buttonBorderRadius, other.buttonBorderRadius, t)!,
      progressBarColor: Color.lerp(progressBarColor, other.progressBarColor, t)!,
      glowEnabled: t < 0.5 ? glowEnabled : other.glowEnabled,
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
      animationCurve: t < 0.5 ? animationCurve : other.animationCurve,
    );
  }
}

/// Extension to easily access journey theme from context
extension JourneyThemeContext on BuildContext {
  JourneyThemeExtension get journeyTheme =>
      Theme.of(this).extension<JourneyThemeExtension>()!;
}
```

#### JourneyThemeProvider

```dart
/// lib/features/journey_themes/presentation/providers/journey_theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final journeyThemeConfigProvider = NotifierProvider<JourneyThemeConfigNotifier, JourneyThemeConfig>(
  JourneyThemeConfigNotifier.new,
);

class JourneyThemeConfigNotifier extends Notifier<JourneyThemeConfig> {
  static const String _boxName = 'journey_theme_config';
  Box<JourneyThemeConfig>? _box;

  @override
  JourneyThemeConfig build() {
    _initBox();
    return _box?.get('config') ?? const JourneyThemeConfig();
  }

  Future<void> _initBox() async {
    _box = await Hive.openBox<JourneyThemeConfig>(_boxName);
  }

  Future<void> setTheme(JourneyTheme theme) async {
    state = state.copyWith(selectedTheme: theme);
    await _saveConfig();
  }

  Future<void> togglePreviewMode(bool enabled) async {
    state = state.copyWith(previewMode: enabled);
    await _saveConfig();
  }

  Future<void> _saveConfig() async {
    await _box?.put('config', state);
  }
}

/// Helper provider for current theme
final currentJourneyThemeProvider = Provider<JourneyTheme>((ref) {
  return ref.watch(journeyThemeConfigProvider).selectedTheme;
});

/// Helper provider for theme extension
final journeyThemeExtensionProvider = Provider.family<JourneyThemeExtension, Brightness>(
  (ref, brightness) {
    final config = ref.watch(journeyThemeConfigProvider);
    final xpData = ref.watch(achievementXPProvider);
    final tier = UserTier.fromXP(xpData.valueOrNull?.totalXP ?? 0);

    return JourneyThemeExtension.fromThemeAndTier(
      theme: config.selectedTheme,
      tier: tier,
      brightness: brightness,
    );
  },
);
```

---

## 5. UI Design: Theme Selector Modal

### 5.1 Modal Structure (level_info_modal.dart pattern)

```dart
/// lib/features/journey_themes/presentation/widgets/journey_theme_selector_modal.dart
class JourneyThemeSelectorModal extends ConsumerStatefulWidget {
  const JourneyThemeSelectorModal({super.key});

  static Future<JourneyTheme?> show(BuildContext context) {
    return showModalBottomSheet<JourneyTheme>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JourneyThemeSelectorModal(),
    );
  }

  @override
  ConsumerState<JourneyThemeSelectorModal> createState() => _JourneyThemeSelectorModalState();
}

class _JourneyThemeSelectorModalState extends ConsumerState<JourneyThemeSelectorModal> {
  bool _isExpanded = false;
  late PageController _pageController;
  int _currentThemeIndex = 0;

  @override
  void initState() {
    super.initState();
    final currentTheme = ref.read(currentJourneyThemeProvider);
    _currentThemeIndex = JourneyTheme.values.indexOf(currentTheme);
    _pageController = PageController(
      initialPage: _currentThemeIndex,
      viewportFraction: 0.85,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xpData = ref.watch(achievementXPProvider);
    final totalXP = xpData.valueOrNull?.totalXP ?? 0;
    final currentTier = UserTier.fromXP(totalXP);

    final height = _isExpanded
        ? context.screenHeight * 0.95
        : context.screenHeight * 0.80;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildTierProgress(context, currentTier, totalXP),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildThemeCarousel(context, currentTier),
                  const SizedBox(height: 16),
                  _buildFeaturesBreakdown(context, currentTier),
                ],
              ),
            ),
          ),
          _buildActionButtons(context),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  // ... widget methods as designed in Section C above ...
}
```

### 5.2 Visual Specifications

| Element | Spec | Token Reference |
|---------|------|-----------------|
| Modal border radius | 24px top | `BorderRadius.circular(24)` |
| Handle bar | 40x4px, 0.4 alpha | Standard pattern |
| Theme card height | 200px | Fixed for carousel |
| Card border radius | 20px | `BorderRadius.circular(20)` |
| Selection border | 3px primary | When selected |
| Page indicator | 8px dot, 24px selected | Animated width |
| Feature row height | 44px | Touch target minimum |
| Progress bar height | 8px | `minHeight: 8` |
| CTA button height | 56px primary, 48px secondary | `minimumSize` |

---

## 6. Task Breakdown

### Phase 1: Domain Layer (Est. 2h)

| Task | File | Est. | Deps |
|------|------|------|------|
| 1.1 | Create `journey_theme.dart` enum | 30min | None |
| 1.2 | Create `unlockable_feature.dart` entity | 45min | 1.1 |
| 1.3 | Create `journey_theme_config.dart` + Hive adapter | 45min | 1.1 |

### Phase 2: Data Layer (Est. 1.5h)

| Task | File | Est. | Deps |
|------|------|------|------|
| 2.1 | Register Hive adapters in main.dart | 15min | 1.3 |
| 2.2 | Create `journey_theme_repository.dart` | 30min | 2.1 |
| 2.3 | Create design tokens files | 45min | 1.1 |

### Phase 3: Theme Extension (Est. 2h)

| Task | File | Est. | Deps |
|------|------|------|------|
| 3.1 | Create `journey_theme_extension.dart` | 60min | 1.1, 1.2 |
| 3.2 | Integrate with `dynamic_theme_provider.dart` | 30min | 3.1 |
| 3.3 | Add `context.journeyTheme` extension | 30min | 3.1 |

### Phase 4: Provider Layer (Est. 1h)

| Task | File | Est. | Deps |
|------|------|------|------|
| 4.1 | Create `journey_theme_provider.dart` | 30min | 2.2 |
| 4.2 | Create helper providers | 30min | 4.1 |

### Phase 5: UI - Modal (Est. 3h)

| Task | File | Est. | Deps |
|------|------|------|------|
| 5.1 | Create `journey_theme_selector_modal.dart` shell | 30min | None |
| 5.2 | Implement header + expand toggle | 30min | 5.1 |
| 5.3 | Implement tier progress bar | 30min | 5.1 |
| 5.4 | Implement theme carousel (PageView) | 45min | 5.1, 4.2 |
| 5.5 | Implement `journey_theme_card.dart` | 45min | 5.4 |

### Phase 6: UI - Features (Est. 2h)

| Task | File | Est. | Deps |
|------|------|------|------|
| 6.1 | Implement features breakdown section | 45min | 5.1, 1.2 |
| 6.2 | Implement `feature_row.dart` with lock/unlock | 45min | 6.1 |
| 6.3 | Implement action buttons | 30min | 5.1 |

### Phase 7: Integration & Polish (Est. 1.5h)

| Task | File | Est. | Deps |
|------|------|------|------|
| 7.1 | Add entry point in Profile/Settings | 30min | 5.1 |
| 7.2 | Add localizations (EN + IT) | 30min | All |
| 7.3 | Add `flutter analyze` + testing | 30min | All |

---

## 7. Localization Keys

```json
// app_en.arb
{
  "journeyThemes": "Journey Themes",
  "journeyThemesSubtitle": "Customize your fitness journey",
  "yourTier": "YOUR TIER:",
  "featuresBreakdown": "FEATURES BREAKDOWN",
  "features": "features",
  "applyTheme": "Apply Theme",
  "previewChanges": "Preview Changes",
  "themeApplied": "Theme applied successfully!",
  "unlockAt": "Unlock at {tier}",
  "@unlockAt": { "placeholders": { "tier": { "type": "String" } } },

  "themeHunter": "Hunter",
  "themeHunterTagline": "Track your prey",
  "themeHero": "Hero",
  "themeHeroTagline": "Rise to legend",
  "themeWarriorGoddess": "Warrior Goddess",
  "themeWarriorGoddessTagline": "Elegant power",
  "themeNatureSpirit": "Nature Spirit",
  "themeNatureSpiritTagline": "Flow with nature",
  "themePhoenix": "Phoenix",
  "themePhoenixTagline": "Rise from ashes",
  "themeFrost": "Frost",
  "themeFrostTagline": "Cold precision",

  "featurePrimaryColor": "Primary Color",
  "featureCardBackground": "Card Background",
  "featureBasicButton": "Basic Button Style",
  "featureSecondaryColor": "Secondary Color",
  "featureCardBorder": "Card Border Style",
  "featureButtonHover": "Button Hover Effect",
  "featureAccentColor": "Accent Color",
  "featureProgressBar": "Progress Bar Style",
  "featureInputFields": "Input Field Style",
  "featureGlowEffects": "Glow Effects",
  "featureAnimations": "Theme Animations",
  "featureSpecialIcons": "Special Icons",
  "featureAppIcon": "App Icon",
  "featureCustomSounds": "Custom Sounds",
  "featureParticles": "Particle Effects"
}
```

```json
// app_it.arb
{
  "journeyThemes": "Temi Journey",
  "journeyThemesSubtitle": "Personalizza il tuo percorso fitness",
  "yourTier": "IL TUO LIVELLO:",
  "featuresBreakdown": "DETTAGLIO FUNZIONALITA'",
  "features": "funzionalita'",
  "applyTheme": "Applica Tema",
  "previewChanges": "Anteprima",
  "themeApplied": "Tema applicato con successo!",
  "unlockAt": "Sblocca a {tier}",

  "themeHunter": "Cacciatore",
  "themeHunterTagline": "Caccia la tua preda",
  "themeHero": "Eroe",
  "themeHeroTagline": "Diventa leggenda",
  "themeWarriorGoddess": "Dea Guerriera",
  "themeWarriorGoddessTagline": "Potenza elegante",
  "themeNatureSpirit": "Spirito della Natura",
  "themeNatureSpiritTagline": "Fluisci con la natura",
  "themePhoenix": "Fenice",
  "themePhoenixTagline": "Risorgi dalle ceneri",
  "themeFrost": "Gelo",
  "themeFrostTagline": "Precisione glaciale"
}
```

---

## 8. Testing Checklist

- [ ] Theme selector opens at 80% height
- [ ] Expand toggle animates to 95%
- [ ] PageView carousel shows all 6 themes
- [ ] Page indicators update correctly
- [ ] Tier progress bar shows current XP/tier
- [ ] Features breakdown shows correct lock/unlock state
- [ ] Locked features show progress to unlock
- [ ] "Apply Theme" saves to Hive
- [ ] Theme persists across app restart
- [ ] Works in both light and dark mode
- [ ] Localizations work (EN + IT)
- [ ] `flutter analyze` passes with 0 errors
- [ ] Accessibility: screen reader announces theme names
- [ ] HapticFeedback on selections

---

## 9. Version History

### v1.0 - 2025-11-29

**Initial design document** based on:
- User requirements for progressive unlock gamification
- Online research (IKEA Effect, retention, Flutter patterns)
- Codebase analysis (level_info_modal.dart, premium_feature_card.dart, UserTier)

---

## 10. References

### Research Sources
- [Gamification UI/UX Guide](https://www.mockplus.com/blog/post/gamification-ui-ux-design-guide)
- [Mobile App Retention Patterns](https://procreator.design/blog/mobile-app-design-patterns-boost-retention/)
- [Flutter Bottom Sheet Types](https://medium.com/@afnan.almohd/bottom-sheet-types-in-flutter-a-step-by-step-guide-e6ffefe7a8d4)
- [Flutter showModalBottomSheet](https://api.flutter.dev/flutter/material/showModalBottomSheet.html)
- [Wolt Modal Sheet](https://pub.dev/packages/wolt_modal_sheet)

### Codebase References
- `lib/features/profile/presentation/widgets/level_info_modal.dart` - 80%→95% expand pattern
- `lib/features/profile/presentation/widgets/compact_profile_header.dart` - UserTier enum
- `lib/shared/presentation/widgets/premium_feature_card.dart` - Blur/lock overlay
- `lib/shared/presentation/services/modal_service.dart` - Modal patterns
- `lib/shared/presentation/theme/app_spacing.dart` - Design tokens reference
