# 🎨 GymBro TrackLog - Design Guidelines & Standards

> **Purpose**: Ensure consistent, high-quality UI across the entire application
> **Status**: ✅ ACTIVE - Apply to ALL new features
> **Last Updated**: 2025-11-02

---

## 📋 Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Spacing System](#spacing-system)
3. [Color System](#color-system)
4. [Typography](#typography)
5. [Card Design Patterns](#card-design-patterns)
6. [Dialog & Modal Standards](#dialog--modal-standards)
7. [Button Patterns](#button-patterns)
8. [Icons & Imagery](#icons--imagery)
9. [Animations](#animations)
10. [State Feedback](#state-feedback)
11. [Localization](#localization)
12. [Empty States](#empty-states)
13. [Component Checklist](#component-checklist)

---

## Design Philosophy

### Core Principles:
1. **Consistency First**: Same elements should look and behave the same everywhere
2. **Context-Aware**: Use `context.colors`, `context.textTheme`, `context.l10n`
3. **Responsive**: Design works on all screen sizes
4. **Accessible**: Proper contrast, touch targets (min 44x44), haptic feedback
5. **Performance**: Animations smooth (60fps), const constructors, optimized rebuilds

### Material Design 3 Foundation:
- Follow M3 guidelines for spacing, elevation, motion
- Use theme colors exclusively (never hardcode)
- Leverage M3 components when available

---

## Spacing System

### Base Unit: 4px

Use multiples of 4 for ALL spacing:

```dart
// ✅ CORRECT
const EdgeInsets.all(4)   // 4px
const EdgeInsets.all(8)   // 8px
const EdgeInsets.all(12)  // 12px
const EdgeInsets.all(16)  // 16px
const EdgeInsets.all(20)  // 20px
const EdgeInsets.all(24)  // 24px

// ❌ WRONG
const EdgeInsets.all(5)   // Non-standard
const EdgeInsets.all(15)  // Non-standard
const EdgeInsets.all(33)  // Random number
```

### Spacing Scale:

| Use Case | Value | Usage |
|----------|-------|-------|
| **Tight** | 4px | Icon-text gap, chip padding |
| **Compact** | 8px | List item spacing, card internal gaps |
| **Default** | 12px | Default spacing between elements |
| **Comfortable** | 16px | Section internal padding |
| **Spacious** | 20px | Between major sections |
| **Loose** | 24px | Card/Dialog padding, screen margins |
| **Extra Loose** | 32px | Large section separators |

### Border Radius Scale:

| Use Case | Value | Usage |
|----------|-------|-------|
| **Small** | 8px | Chips, small buttons |
| **Medium** | 12px | Cards (nested), list items |
| **Large** | 16px | Buttons, input fields |
| **Extra Large** | 20px | Main cards |
| **Hero** | 24px | Dialog, bottom sheets, hero elements |

---

## Color System

### ⚠️ CRITICAL RULES:

1. **NEVER hardcode colors**
2. **ALWAYS use `context.colors.*`**
3. **Test in BOTH light AND dark themes**

### Color Usage:

```dart
// ✅ CORRECT - Theme-aware colors
color: context.colors.primary
color: context.colors.onSurface
color: context.colors.surface
color: context.colors.error
color: context.colors.primaryContainer

// ❌ WRONG - Hardcoded colors
color: Colors.blue
color: Color(0xFF1E88E5)
color: Colors.white
```

### Opacity Layers:

Use `withValues(alpha:)` for transparency (NOT `withOpacity`):

```dart
// ✅ CORRECT
color: context.colors.onSurface.withValues(alpha: 0.7)  // 70% opacity

// ❌ WRONG
color: context.colors.onSurface.withOpacity(0.7)  // Deprecated
```

### Common Alpha Values:

| Alpha | Usage | Visual Effect |
|-------|-------|---------------|
| **1.0** | Primary text, icons | Fully opaque |
| **0.9** | Emphasis text | Strong visibility |
| **0.8** | Secondary text | Good readability |
| **0.7** | Tertiary text, subtle icons | Clear but not dominant |
| **0.5** | Disabled text, placeholders | Muted |
| **0.3** | Borders, dividers (subtle) | Very subtle |
| **0.2** | Background tints, hover states | Barely visible tint |
| **0.1** | Extreme subtle backgrounds | Almost invisible |

### Semantic Colors:

```dart
// Success
context.colors.primary  // For positive actions
context.colors.success  // Explicit success states

// Warnings
context.colors.warning  // Caution states

// Errors
context.colors.error
context.colors.errorContainer

// Information
context.colors.primaryContainer  // Info boxes
context.colors.surfaceContainerHighest  // Neutral info
```

---

## Typography

### ⚠️ CRITICAL RULES:

1. **NEVER hardcode TextStyle**
2. **ALWAYS use `context.textTheme.*`**
3. **Override only specific properties with `.copyWith()`**

### Text Scale:

```dart
// Headlines (for major sections, dialog titles)
context.textTheme.headlineLarge    // 32sp, Bold
context.textTheme.headlineMedium   // 28sp, Bold
context.textTheme.headlineSmall    // 24sp, Bold

// Titles (for cards, subtitles, important labels)
context.textTheme.titleLarge       // 22sp, SemiBold
context.textTheme.titleMedium      // 16sp, SemiBold
context.textTheme.titleSmall       // 14sp, SemiBold

// Body (for paragraphs, descriptions, primary content)
context.textTheme.bodyLarge        // 16sp, Regular
context.textTheme.bodyMedium       // 14sp, Regular
context.textTheme.bodySmall        // 12sp, Regular

// Labels (for buttons, chips, tags)
context.textTheme.labelLarge       // 14sp, Medium
context.textTheme.labelMedium      // 12sp, Medium
context.textTheme.labelSmall       // 11sp, Medium
```

### Font Weights:

```dart
// Use semantic names
FontWeight.bold      // 700 - Headings, emphasis
FontWeight.w600      // 600 - Semi-bold titles
FontWeight.w500      // 500 - Medium emphasis
FontWeight.normal    // 400 - Body text
```

### Text Hierarchy Examples:

```dart
// ✅ Dialog Title
Text(
  context.l10n.dialogTitle,
  style: context.textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.bold,
    color: context.colors.onSurface,
  ),
)

// ✅ Card Subtitle
Text(
  context.l10n.subtitle,
  style: context.textTheme.bodyMedium?.copyWith(
    color: context.colors.onSurface.withValues(alpha: 0.7),
  ),
)

// ✅ Secondary Info
Text(
  context.l10n.info,
  style: context.textTheme.bodySmall?.copyWith(
    color: context.colors.onSurface.withValues(alpha: 0.5),
  ),
)
```

---

## Card Design Patterns

### Standard Card Pattern:

```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTap(),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: /* Content */,
        ),
      ),
    ),
  ),
)
```

### Elevated Card (Hero Elements):

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 1.5,
      colors: [
        context.colors.primaryContainer,
        context.colors.secondaryContainer.withValues(alpha: 0.9),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: context.colors.primary.withValues(alpha: 0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 2,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: /* Content */,
      ),
    ),
  ),
)
```

### Glassmorphism Card (Premium):

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: /* Content */,
    ),
  ),
)
```

---

## Dialog & Modal Standards

### Standard Dialog Pattern:

```dart
Dialog(
  backgroundColor: context.colors.surface,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Container(
    constraints: const BoxConstraints(
      maxWidth: 500,
      maxHeight: 700,
    ),
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.icon_here,
                color: context.colors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.dialogTitle,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          context.l10n.dialogSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),

        // Content (flexible)
        Expanded(
          child: /* Dynamic Content */,
        ),

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _handleConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(context.l10n.confirm),
            ),
          ],
        ),
      ],
    ),
  ),
)
```

### Bottom Sheet Pattern:

```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (context) => Container(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: /* Content */,
      ),
    ),
  ),
)
```

---

## Button Patterns

### Primary Button (CTA):

```dart
ElevatedButton(
  onPressed: _handleAction,
  style: ElevatedButton.styleFrom(
    backgroundColor: context.colors.primary,
    foregroundColor: context.colors.onPrimary,
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check, size: 20),
      const SizedBox(width: 8),
      Text(context.l10n.buttonLabel),
    ],
  ),
)
```

### Secondary Button:

```dart
OutlinedButton(
  onPressed: _handleAction,
  style: OutlinedButton.styleFrom(
    foregroundColor: context.colors.primary,
    side: BorderSide(
      color: context.colors.primary.withValues(alpha: 0.5),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text(context.l10n.buttonLabel),
)
```

### Text Button (Tertiary):

```dart
TextButton(
  onPressed: _handleAction,
  style: TextButton.styleFrom(
    foregroundColor: context.colors.onSurface,
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  ),
  child: Text(context.l10n.buttonLabel),
)
```

### Icon Button:

```dart
IconButton(
  onPressed: _handleAction,
  icon: Icon(
    Icons.icon_here,
    color: context.colors.primary,
  ),
  tooltip: context.l10n.tooltip,
  padding: const EdgeInsets.all(12),
)
```

---

## Icons & Imagery

### Icon Sizes:

| Use Case | Size | Usage |
|----------|------|-------|
| **Small** | 16px | Inline with text, chips |
| **Default** | 20-24px | Standard UI elements |
| **Medium** | 28-32px | Prominent actions |
| **Large** | 48-64px | Empty states, hero sections |

### Icon Colors:

```dart
// Primary action icons
Icon(
  Icons.icon,
  color: context.colors.primary,
  size: 24,
)

// Secondary/subtle icons
Icon(
  Icons.icon,
  color: context.colors.onSurface.withValues(alpha: 0.7),
  size: 20,
)

// Disabled icons
Icon(
  Icons.icon,
  color: context.colors.onSurface.withValues(alpha: 0.3),
  size: 20,
)
```

### Icon Usage:

```dart
// ✅ CORRECT - Use AppIcons constants
Icon(AppIcons.completeOutline)
Icon(AppIcons.workout)

// ✅ CORRECT - Use Material Icons
Icon(Icons.check_circle)
Icon(Icons.arrow_forward)

// ❌ WRONG - Don't use custom SVG without caching
SvgPicture.asset('assets/icons/custom.svg')  // Performance issue
```

---

## Animations

### Animation Durations:

| Type | Duration | Usage |
|------|----------|-------|
| **Instant** | 100ms | Micro-interactions, toggles |
| **Fast** | 200-300ms | Button feedback, simple transitions |
| **Default** | 400-600ms | Card animations, page transitions |
| **Slow** | 800-1200ms | Hero animations, loading |
| **Epic** | 1500ms+ | Onboarding, celebrations |

### Standard Fade-In Animation:

```dart
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Delay for staggered animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: /* Your Widget */,
        );
      },
    );
  }
}
```

### Curves:

```dart
// Smooth entry
Curves.easeOut

// Smooth exit
Curves.easeIn

// Balanced
Curves.easeInOut
Curves.easeInOutCubic

// Bouncy (sparingly)
Curves.elasticOut

// Spring-like
Curves.easeOutBack
```

---

## State Feedback

### Haptic Feedback:

```dart
// Selection (checkboxes, radio buttons, toggles)
HapticFeedback.selectionClick();

// Light impact (taps, button presses)
HapticFeedback.lightImpact();

// Medium impact (success, confirmations)
HapticFeedback.mediumImpact();

// Heavy impact (errors, important actions)
HapticFeedback.heavyImpact();
```

### Snackbars:

```dart
// ✅ CORRECT - Use SnackBarService
SnackBarService.showSuccess(context, context.l10n.successMessage);
SnackBarService.showError(context, context.l10n.errorMessage);
SnackBarService.showInfo(context, context.l10n.infoMessage);

// ❌ WRONG - Direct ScaffoldMessenger
ScaffoldMessenger.of(context).showSnackBar(/* ... */);
```

### Loading States:

```dart
// ✅ CORRECT - Use LoadingIndicator
if (isLoading)
  const Center(child: LoadingIndicator())

// ❌ WRONG - Direct CircularProgressIndicator
if (isLoading)
  const Center(child: CircularProgressIndicator())
```

---

## Localization

### ⚠️ CRITICAL RULES:

1. **NEVER hardcode text strings**
2. **ALWAYS use `context.l10n.*`**
3. **Add translations to BOTH `app_en.arb` AND `app_it.arb`**
4. **Run `flutter gen-l10n` after adding translations**

### Examples:

```dart
// ✅ CORRECT
Text(context.l10n.welcomeMessage)
Text(context.l10n.workoutsCount(count))
tooltip: context.l10n.editTooltip

// ❌ WRONG
Text('Welcome!')
Text('$count workouts')
tooltip: 'Edit'
```

### Date/Time Formatting:

```dart
// ❌ WRONG - Hardcoded English
'Mon 15 Jan'
'Today'
'Yesterday'

// ✅ CORRECT - Use DateFormat with locale
import 'package:intl/intl.dart';

final formattedDate = DateFormat.yMMMd(
  Localizations.localeOf(context).languageCode,
).format(date);

// OR use localized helpers
final relativeDate = _formatRelativeDate(date, context.l10n);
```

---

## Empty States

### Use EnhancedEmptyState:

```dart
EnhancedEmptyState(
  type: EmptyStateType.info,
  icon: Icons.inbox,
  title: context.l10n.noDataTitle,
  description: context.l10n.noDataDescription,
  motivationalQuote: context.l10n.motivationalQuote,
  proTip: context.l10n.proTip,
  primaryActionLabel: context.l10n.addNew,
  onPrimaryAction: _handleAdd,
  primaryActionIcon: Icons.add,
  secondaryActionLabel: context.l10n.learnMore,
  onSecondaryAction: _showHelp,
)
```

### Empty State Types:

- `EmptyStateType.info` - General information (blue)
- `EmptyStateType.motivational` - Encouragement (primary theme color)
- `EmptyStateType.warning` - Attention needed (orange)
- `EmptyStateType.success` - Completed state (green)
- `EmptyStateType.error` - Error state (red)
- `EmptyStateType.custom` - Use custom color

---

## Component Checklist

Before committing ANY new UI component, verify:

### ✅ Styling:
- [ ] Uses `context.colors.*` (NO hardcoded colors)
- [ ] Uses `context.textTheme.*` (NO hardcoded TextStyle)
- [ ] Spacing is multiples of 4 (4, 8, 12, 16, 20, 24, etc.)
- [ ] Border radius consistent (8, 12, 16, 20, 24)
- [ ] Tested in BOTH light AND dark themes

### ✅ Localization:
- [ ] Uses `context.l10n.*` (NO hardcoded strings)
- [ ] Translations added to `app_en.arb` and `app_it.arb`
- [ ] Ran `flutter gen-l10n` after adding translations
- [ ] Date/time formatting uses localized formatters

### ✅ Interactions:
- [ ] Haptic feedback on user actions
- [ ] Touch targets ≥ 44x44 dp
- [ ] Loading states use `LoadingIndicator`
- [ ] Snackbars use `SnackBarService`
- [ ] Modals use `ModalService`

### ✅ Performance:
- [ ] Uses `const` constructors where possible
- [ ] AnimationController properly disposed
- [ ] Riverpod providers use `.select()` to minimize rebuilds
- [ ] Images cached appropriately
- [ ] No unnecessary rebuilds

### ✅ Accessibility:
- [ ] Semantics labels for icons/buttons
- [ ] Sufficient color contrast (WCAG AA minimum)
- [ ] Keyboard navigation support (if applicable)
- [ ] Screen reader compatible

### ✅ Code Quality:
- [ ] No `print()` statements (use `debugPrint` + `kDebugMode`)
- [ ] No compiler warnings
- [ ] `flutter analyze` passes
- [ ] Follows Clean Architecture (domain/data/presentation)

---

## Quick Reference Card

```dart
// SPACING
padding: const EdgeInsets.all(24)        // Dialog/Card padding
padding: const EdgeInsets.all(16)        // Section padding
const SizedBox(height: 12)               // Default gap
const SizedBox(height: 24)               // Section separator

// COLORS
color: context.colors.primary
color: context.colors.onSurface.withValues(alpha: 0.7)
backgroundColor: context.colors.surface

// TYPOGRAPHY
style: context.textTheme.headlineSmall   // Dialog title
style: context.textTheme.titleMedium     // Card title
style: context.textTheme.bodyMedium      // Body text

// BORDER RADIUS
borderRadius: BorderRadius.circular(24)  // Dialog
borderRadius: BorderRadius.circular(16)  // Card
borderRadius: BorderRadius.circular(12)  // Button

// SHADOWS
BoxShadow(
  color: Colors.black.withValues(alpha: 0.1),
  blurRadius: 10,
  offset: const Offset(0, 4),
)

// LOCALIZATION
Text(context.l10n.keyName)

// FEEDBACK
HapticFeedback.mediumImpact()
SnackBarService.showSuccess(context, message)
```

---

## 🛠️ Advanced Tools & Utilities

### Semantic Colors (`SemanticColors` extension)

Use semantic color names for better intent clarity:

```dart
// ✅ Use semantic colors for clear intent
Container(
  color: context.successColor,        // Green - success states
  child: Text('Saved!', style: TextStyle(color: context.textOnSuccess)),
)

Container(
  color: context.errorColor,          // Red - error states
  child: Text('Error', style: TextStyle(color: context.textOnError)),
)

Container(
  color: context.warningColor,        // Orange - warnings
  child: Text('Warning', style: TextStyle(color: context.textOnWarning)),
)

Container(
  color: context.infoColor,           // Blue - info messages
  child: Text('Info', style: TextStyle(color: context.textOnInfo)),
)

// Container variants with proper alpha
Container(color: context.successContainer)  // Light green background
Container(color: context.errorContainer)    // Light red background
Container(color: context.warningContainer)  // Light orange background
Container(color: context.infoContainer)     // Light blue background
```

**Benefits**:
- ✅ WCAG AA compliant contrast ratios guaranteed
- ✅ Self-documenting code (intent is clear)
- ✅ Automatic theme adaptation

### Extended Spacing System (`AppSpacing`)

Beyond the base 8-level scale, use extended spacing and semantic aliases:

```dart
// Extended scale for edge cases
Padding(padding: EdgeInsets.all(AppSpacing.xxxl))   // 48px - full-screen modals
Padding(padding: EdgeInsets.all(AppSpacing.xxxxl))  // 64px - onboarding

// Semantic aliases (self-documenting)
Padding(padding: AppSpacing.card)              // EdgeInsets.all(16)
Padding(padding: AppSpacing.dialog)            // EdgeInsets.all(24)
Padding(padding: AppSpacing.screen)            // Horizontal(20), Vertical(24)
Padding(padding: AppSpacing.button)            // Horizontal(16), Vertical(12)

// Responsive spacing
final spacing = AppSpacing.responsive(
  context.screenWidth,
  AppSpacing.md,  // Base: 16px
);
// Returns: 16px (mobile), 20px (tablet), 24px (desktop)
```

**Benefits**:
- ✅ Covers all use cases (base + extended + semantic)
- ✅ Responsive out of the box
- ✅ Validation helper (`AppSpacing.isValid(value)`)

### Responsive Typography (`ResponsiveTypography` extension)

Automatically scale typography based on device size:

```dart
// ✅ Use responsive typography for tablets/desktops
Text(
  'Title',
  style: context.responsiveTextTheme.headlineMedium,
)
// Font size scales automatically:
// - Mobile (<600px): 1.0x (no scaling)
// - Tablet (600-900px): 1.15x
// - Desktop (>900px): 1.3x

// Device type checks
if (context.isMobile) {
  // Mobile-specific layout
} else if (context.isTablet) {
  // Tablet-specific layout
} else if (context.isDesktop) {
  // Desktop-specific layout
}
```

**Benefits**:
- ✅ Automatic scaling for larger screens
- ✅ Performance-optimized (returns base theme if scale = 1.0)
- ✅ Consistent breakpoints across app

### Accessibility Utilities (`AccessibilityUtils`)

Verify WCAG compliance programmatically:

```dart
// Check contrast ratio
final ratio = AccessibilityUtils.getContrastRatio(
  Colors.blue,   // Foreground
  Colors.white,  // Background
);
print('Contrast: ${ratio.toStringAsFixed(2)}:1');

// Check WCAG conformance
final isAccessible = AccessibilityUtils.meetsWCAG_AA(
  foreground: Colors.blue,
  background: Colors.white,
);

if (!isAccessible) {
  print('⚠️ Contrast ratio too low!');
}

// Get suggested text color (white or black)
final textColor = AccessibilityUtils.suggestTextColor(Colors.blue);

// Generate full accessibility report
print(AccessibilityUtils.getAccessibilityReport(
  foreground: Colors.blue,
  background: Colors.white,
  label: 'Primary Button',
));
// Output:
// 🎨 Accessibility Report: Primary Button
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Foreground: #2196F3
// Background: #FFFFFF
// Contrast Ratio: 3.14:1
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WCAG AA (4.5:1):        ❌ FAIL
// WCAG AA Large (3:1):    ✅ PASS
```

**WCAG Standards**:
- **AA Normal**: 4.5:1 (text < 18pt)
- **AA Large**: 3:1 (text ≥ 18pt or bold ≥ 14pt)
- **AAA Normal**: 7:1 (enhanced)
- **AAA Large**: 4.5:1 (enhanced)

### Theme Preview Screen (`ThemePreviewScreen`)

Developer tool for hot reload testing:

```dart
// Navigate to preview during development
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ThemePreviewScreen()),
);

// Features:
// - Toggle light/dark theme with button
// - See all components side-by-side
// - Test semantic colors
// - Verify spacing system
// - Hot reload after theme changes
```

**Location**: `lib/tools/theme_preview_screen.dart`

### Golden Tests (Visual Regression)

Prevent visual regressions automatically:

```bash
# Run golden tests
flutter test test/golden/

# Update goldens after intentional changes
flutter test --update-goldens test/golden/
```

**Test Files**:
- `test/golden/design_system_test.dart` - Core design system components
- `test/golden/README.md` - Complete golden test guide

**What They Test**:
- ✅ Standard cards (light + dark)
- ✅ Buttons (light + dark)
- ✅ Semantic colors (light + dark)
- ✅ Loading indicators
- ✅ Prevents accidental visual changes

### Pre-Commit Hook

Automatic design violations check before each commit:

**What It Checks**:
1. ❌ Hardcoded strings → Block commit
2. ⚠️ Hardcoded colors → Warning (allow commit)
3. ❌ `CircularProgressIndicator()` → Block commit (use `LoadingIndicator()`)
4. ✅ Localization regenerated if ARB files modified
5. ✅ `flutter analyze` passes

**Bypass** (emergency only):
```bash
git commit --no-verify -m "emergency fix"
```

### Design Violations Scanner

Find all violations across codebase:

```bash
# Run full scan
./scripts/check_design_violations.sh

# Output:
# 🎨 Design System Violations Checker
# ==========================================
#
# 📝 [1/6] Checking hardcoded strings...
# ✅ No hardcoded strings found
#
# 🎨 [2/6] Checking hardcoded colors...
# ❌ Found 182 files with Colors.*
# ...
```

**What It Scans**:
1. Hardcoded strings in `Text()`
2. Hardcoded colors (`Colors.*`, `Color(0x...)`)
3. Hardcoded `TextStyle()`
4. Wrong components (`CircularProgressIndicator`, `ScaffoldMessenger`)
5. Deprecated `.withOpacity()` (use `.withValues(alpha:)`)
6. `print()` statements (use `debugPrint()`)

---

## Resources

- **Material Design 3**: https://m3.material.io/
- **Flutter Docs**: https://docs.flutter.dev/
- **WCAG Guidelines**: https://www.w3.org/WAI/WCAG21/quickref/
- **Golden Tests**: https://docs.flutter.dev/cookbook/testing/integration/golden-tests
- **App Spacing System**: `lib/shared/presentation/theme/app_spacing.dart`
- **Accessibility Utils**: `lib/shared/utils/accessibility_utils.dart`
- **Theme Preview**: `lib/tools/theme_preview_screen.dart`

---

✅ **Remember**: Consistency > Creativity. Follow these guidelines ALWAYS!
