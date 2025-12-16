# Settings Screen Redesign - Design Document

**Date:** 2025-11-08
**Status:** Approved
**Priority:** High
**Effort:** Medium (4-6 hours)

---

## 🎯 Problem Statement

The current Settings screen has several critical issues:

1. **Font size slider is broken** - Validation checks 8.0-24.0 but slider sends 0.8-1.2 (percentage multipliers)
2. **Accent color has no visible effect** - Color is saved but not applied to runtime theme
3. **Too many sections (7)** - Confusing organization with redundant/always-on settings
4. **Unclear purpose** - "Accent Color" name doesn't explain what it affects
5. **No visual feedback** - Color/font changes lack preview before applying

### User Feedback

> "Lo slider non si muove, il colore accent non capisco a cosa serva... le sezioni sono troppo confusionarie"

---

## ✅ Solution Overview

**Simplify from 7 sections → 4 sections:**

1. User Info (unchanged)
2. Appearance (improved with previews)
3. Workout Essentials (new - minimal)
4. Units & Language (unchanged)

**Key Changes:**
- Fix font size validation bug
- Add dynamic theme provider for color
- Remove 4 redundant sections
- Hardcode 5+ always-on settings
- Add visual previews (color circle, live font size)

---

## 📐 Detailed Design

### Section 1: User Info (Unchanged)

**Content:**
- Email display
- Sign out button
- Admin access (if admin)

**No changes needed** - Working correctly.

---

### Section 2: Appearance (Improved)

**Before → After:**

| Before | After | Change |
|--------|-------|--------|
| Theme Mode | Theme Mode | ✅ Keep |
| Font Size (broken) | Text Size (fixed + preview) | 🔧 Fix + enhance |
| Accent Color (no effect) | Theme Color (preview circle) | 🔧 Fix + rename |

**Implementation Details:**

#### 2.1 Theme Mode (Keep As-Is)
```dart
ListTile(
  leading: Icon(_getThemeModeIcon(config.themeMode)),
  title: Text(context.l10n.theme),
  subtitle: Text(_getThemeModeText(context.l10n, config.themeMode)),
  onTap: () => _showThemeDialog(...),
)
```

#### 2.2 Text Size (Fixed + Preview)
```dart
Column(
  children: [
    Row(
      children: [
        Icon(AppIcons.formatSize),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.settingsTextSize),
              // LIVE PREVIEW
              Text(
                context.l10n.settingsTextSizePreview(
                  _getFontSizeText(context, config.fontSize)
                ),
                style: TextStyle(
                  fontSize: 16 * config.fontSize, // Real-time scaling
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    Slider(
      value: config.fontSize,
      min: 0.8,
      max: 1.2,
      divisions: 4,
      label: '${(config.fontSize * 100).round()}%', // Show percentage
      onChanged: (val) => ref.read(appConfigProvider.notifier).setFontSize(val),
    ),
  ],
)
```

**Bug Fix:** Validation in `app_config_provider.dart:218`
```dart
// BEFORE (broken)
if (fontSize < 8.0 || fontSize > 24.0) {
  return; // Blocks all 0.8-1.2 values!
}

// AFTER (fixed)
if (fontSize < 0.8 || fontSize > 1.2) {
  debugPrint('⚠️ Invalid font size: $fontSize (must be 0.8-1.2)');
  return;
}
```

#### 2.3 Theme Color (Preview + Rename)
```dart
ListTile(
  leading: Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: _parseColor(config.primaryColor), // Visual preview
      shape: BoxShape.circle,
      border: Border.all(color: context.colors.outline, width: 2),
    ),
  ),
  title: Text(context.l10n.settingsThemeColor), // Renamed from "Accent Color"
  subtitle: Text(context.l10n.settingsThemeColorDesc), // "Tap to change"
  onTap: () => _showColorDialog(context, ref, config.primaryColor),
)
```

**Color Application Fix:**

Create new `DynamicThemeProvider`:

```dart
// lib/shared/presentation/providers/dynamic_theme_provider.dart
final dynamicThemeProvider = Provider.family<ThemeData, Brightness>((ref, brightness) {
  final config = ref.watch(appConfigProvider);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _parseColor(config.primaryColor),
      brightness: brightness,
    ),
    textTheme: _getScaledTextTheme(config.fontSize),
  );
});

Color _parseColor(String hexColor) {
  // Remove # if present
  final hex = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

TextTheme _getScaledTextTheme(double scale) {
  final base = ThemeData.light().textTheme;
  return TextTheme(
    displayLarge: base.displayLarge?.copyWith(fontSize: (base.displayLarge?.fontSize ?? 57) * scale),
    displayMedium: base.displayMedium?.copyWith(fontSize: (base.displayMedium?.fontSize ?? 45) * scale),
    // ... scale all text styles
  );
}
```

**Apply in MaterialApp:**
```dart
// main.dart
MaterialApp(
  theme: ref.watch(dynamicThemeProvider(Brightness.light)),
  darkTheme: ref.watch(dynamicThemeProvider(Brightness.dark)),
  themeMode: ref.watch(themeModeProvider),
  // ...
)
```

---

### Section 3: Workout Essentials (NEW)

**Purpose:** Minimal section for essential workout settings only.

**Content (2 items):**

#### 3.1 Default Rest Time
```dart
ListTile(
  leading: Icon(AppIcons.timer),
  title: Text(context.l10n.settingsDefaultRestTime),
  subtitle: Text('${config.defaultRestTime}s'),
  onTap: () => _showRestTimeDialog(context, ref, config.defaultRestTime),
)
```

#### 3.2 APRE System (Collapsible)
```dart
SwitchListTile(
  secondary: Icon(AppIcons.trending),
  title: Text(context.l10n.settingsApreAutoAdjustment),
  subtitle: Text(context.l10n.settingsApreAutoAdjustmentDesc),
  value: config.enableApre ?? false,
  onChanged: (val) => ref.read(appConfigProvider.notifier)
    .updateWorkoutSettings(enableApre: val),
)

// Show config ONLY if enabled
if (config.enableApre == true) ...[
  Divider(),
  ListTile(
    leading: Icon(AppIcons.settings),
    title: Text(context.l10n.settingsApreProtocol),
    subtitle: Text('Protocol ${config.defaultApreProtocol ?? 3}'),
    onTap: () => _showApreProtocolDialog(context, ref, config.defaultApreProtocol ?? 3),
  ),
]
```

**Why minimal?** Most workout settings are now hardcoded (see below).

---

### Section 4: Units & Language (Unchanged)

**Content:**
- Measurement unit (kg/lbs)
- Language (IT/EN)

**No changes needed** - Working correctly.

---

## 🗑️ Removed Sections

### ❌ Section: Workout (Eliminated)

**Before:**
- Auto Start Timer (toggle)
- Default Rest Time (input)
- Show Intensity Techniques (toggle)

**After:**
- Default Rest Time → Moved to "Workout Essentials"
- Auto Start Timer → **Hardcoded to `true`** (always on)
- Show Intensity Techniques → **Hardcoded to `true`** (always visible)

**Rationale:** Auto-timer and advanced techniques should always be available. No reason to disable them.

---

### ❌ Section: iOS Features (Eliminated)

**Before:**
- Enable Live Activities (toggle)
- Sync with HealthKit (toggle)

**After:**
- **All hardcoded to `true`** (always enabled on iOS)

**Rationale:** These are core iOS features that should always work. No need for user control.

**Implementation:**
```dart
// Platform check remains, but no toggle
if (Platform.isIOS) {
  // Live Activities always enabled
  // HealthKit always enabled
}
```

---

### ❌ Section: Audio & Feedback (Eliminated)

**Before:**
- Sound Enabled (toggle)
- Vibrations Enabled (toggle)
- Timer Sound Selector (picker)

**After:**
- **All hardcoded to `true`** (always enabled)
- Timer sound → Use default, no picker

**Rationale:** Audio feedback is essential for workout app. No reason to disable.

---

### ❌ Section: Advanced Settings (Hidden)

**Before (visible):**
- Beta Mode
- Reset Settings
- Clear Cache
- Export/Import Data
- Onboarding Reset
- APRE System

**After (hidden):**
- Most items moved to debug-only menu
- APRE System → Moved to "Workout Essentials"

**Rationale:** These are rarely used. Keep UI clean. Developers can access via debug menu.

---

## 🔧 AppConfig Hardcoding

### Changes to Default Values

**File:** `lib/shared/domain/entities/app_config.dart`

```dart
@HiveType(typeId: 1)
class AppConfig with _$AppConfig {
  const factory AppConfig({
    // ... existing fields

    // HARDCODED VALUES (no longer user-configurable)
    @Default(true) bool autoStartTimer,          // Always on
    @Default(true) bool showIntensityTechniques, // Always visible
    @Default(true) bool soundEnabled,            // Always on
    @Default(true) bool vibrationsEnabled,       // Always on
    @Default(true) bool enableLiveActivities,    // Always on (iOS)
    @Default(true) bool syncWithHealthKit,       // Always on (iOS)

  }) = _AppConfig;
}
```

### Remove Setter Methods

**File:** `lib/shared/presentation/providers/app_config_provider.dart`

**Delete these methods (no longer needed):**
- `setAutoStartTimer(bool)`
- `setSoundEnabled(bool)`
- `setVibrationsEnabled(bool)`
- `setEnableLiveActivities(bool)`
- `setSyncWithHealthKit(bool)`

**Keep setter for:**
- `setShowIntensityTechniques(bool)` - Actually, DELETE this too (hardcoded)

---

## 🌍 Localization (ARB Keys)

### New Keys Needed

**English** (`assets/i18n/app_en.arb`):
```json
{
  "settingsThemeColor": "Theme Color",
  "settingsThemeColorDesc": "Tap to change",
  "settingsTextSize": "Text Size",
  "settingsTextSizePreview": "Sample Text ({size})",
  "settingsWorkoutEssentials": "Workout",
  "settingsApreAutoAdjustment": "APRE Auto-Adjustment",
  "settingsApreAutoAdjustmentDesc": "Automatic weight progression",
  "settingsApreProtocol": "APRE Protocol",
  "settingsApreProtocolDesc": "Protocol {number}"
}
```

**Italian** (`assets/i18n/app_it.arb`):
```json
{
  "settingsThemeColor": "Colore Tema",
  "settingsThemeColorDesc": "Tocca per cambiare",
  "settingsTextSize": "Dimensione Testo",
  "settingsTextSizePreview": "Testo di esempio ({size})",
  "settingsWorkoutEssentials": "Allenamento",
  "settingsApreAutoAdjustment": "Auto-Regolazione APRE",
  "settingsApreAutoAdjustmentDesc": "Progressione automatica del peso",
  "settingsApreProtocol": "Protocollo APRE",
  "settingsApreProtocolDesc": "Protocollo {number}"
}
```

### Deprecated Keys (Can Remove)

These keys are no longer used:
- `settingsAutoStartTimer`
- `settingsAutoStartTimerDesc`
- `settingsAdvancedTechniques`
- `settingsAdvancedTechniquesDesc`
- `settingsSoundEnabled`
- `settingsVibrationsEnabled`
- `settingsTimerSound`
- `settingsIOSFeatures`
- `settingsEnableLiveActivities`
- `settingsSyncHealthKit`
- `settingsAudioFeedback`

**Action:** Mark as deprecated in comments, remove in future cleanup.

---

## 📂 File Changes Summary

### Modified Files

1. **`lib/features/settings/presentation/settings_screen.dart`**
   - Remove 4 section builders
   - Add `_buildWorkoutEssentialsSection()`
   - Update `_buildAppearanceSection()` with previews
   - Fix font size slider
   - Add theme color preview circle

2. **`lib/shared/presentation/providers/app_config_provider.dart`**
   - Fix `setFontSize()` validation (0.8-1.2)
   - Remove 5 deprecated setter methods

3. **`lib/shared/domain/entities/app_config.dart`**
   - Update default values to hardcoded `true`

4. **`assets/i18n/app_en.arb`**
   - Add 9 new keys
   - Mark 11 keys as deprecated

5. **`assets/i18n/app_it.arb`**
   - Add 9 new translations

### New Files

1. **`lib/shared/presentation/providers/dynamic_theme_provider.dart`**
   - Provider that rebuilds theme when primaryColor changes
   - Handles color parsing from hex string
   - Scales text theme based on fontSize multiplier

2. **`lib/shared/presentation/theme/theme_helper.dart`** (optional)
   - Helper functions: `parseColor()`, `getScaledTextTheme()`
   - Extracted for reusability

---

## ✅ Testing Checklist

### Functional Tests

- [ ] Font size slider moves smoothly (0.8 → 1.2)
- [ ] Font size changes are visible immediately in preview
- [ ] Theme color changes are visible immediately (circle preview)
- [ ] Theme color applies to entire app after selection
- [ ] Default rest time dialog works
- [ ] APRE toggle shows/hides protocol config
- [ ] APRE protocol dialog works
- [ ] Theme mode (light/dark/system) works
- [ ] Language switching works
- [ ] Measurement unit switching works

### Visual Tests

- [ ] Color preview circle shows current theme color
- [ ] Font preview text scales in real-time
- [ ] All 4 sections render without overflow
- [ ] Dark mode renders correctly
- [ ] Italian translations display correctly

### Regression Tests

- [ ] Auto-start timer still works (hardcoded)
- [ ] Intensity techniques still visible (hardcoded)
- [ ] Sound/vibrations still work (hardcoded)
- [ ] Live Activities still work on iOS (hardcoded)
- [ ] HealthKit sync still works on iOS (hardcoded)

---

## 🚀 Implementation Plan

### Phase 1: Bug Fixes (30 min)

1. Fix font size validation in `app_config_provider.dart`
2. Create `dynamic_theme_provider.dart`
3. Connect dynamic theme to `MaterialApp`
4. Test font slider + theme color change

**Deliverable:** Bugs fixed, color/font work correctly

---

### Phase 2: Section Restructure (2 hours)

1. Remove 4 section builders from `settings_screen.dart`
2. Create `_buildWorkoutEssentialsSection()`
3. Update `_buildAppearanceSection()` with previews
4. Remove deprecated setter methods from provider
5. Update `app_config.dart` default values

**Deliverable:** Settings screen simplified to 4 sections

---

### Phase 3: Localization (30 min)

1. Add 9 new keys to `app_en.arb`
2. Add 9 translations to `app_it.arb`
3. Run `flutter gen-l10n`
4. Update all UI strings to use new keys

**Deliverable:** All strings localized

---

### Phase 4: Testing & Polish (1 hour)

1. Manual testing of all functionality
2. Visual testing in light/dark modes
3. Test on iOS for hardcoded features
4. Fix any issues found
5. Commit with comprehensive message

**Deliverable:** Production-ready settings screen

---

## 📊 Impact Assessment

### User Experience

**Before:**
- 7 confusing sections
- Broken slider
- Invisible color changes
- Too many toggles

**After:**
- 4 clear sections
- Working previews
- Immediate visual feedback
- Streamlined options

**Expected Improvement:** +80% user satisfaction with settings

---

### Code Quality

**Before:**
- 500+ lines settings screen
- 7 section builders
- 15+ toggle handlers
- Redundant provider methods

**After:**
- ~350 lines settings screen
- 4 section builders
- 5 essential handlers
- Clean provider API

**Expected Improvement:** -30% code complexity

---

### Maintenance

**Benefits:**
- Fewer user-configurable options = fewer edge cases
- Hardcoded values = no "I disabled X and now Y doesn't work" bugs
- Clear separation = easier to find settings
- Preview feedback = fewer "is it working?" support tickets

---

## 🎯 Success Metrics

**Post-Launch (1 week):**
- [ ] Zero bug reports about font size slider
- [ ] Zero confusion about theme color
- [ ] Settings screen completion time < 30 seconds
- [ ] Support tickets about settings -50%

**Post-Launch (1 month):**
- [ ] User feedback score > 4.5/5 for settings UX
- [ ] Settings-related crashes = 0
- [ ] Average settings changes per user < 3 (sign of good defaults)

---

## 🔄 Future Enhancements (Out of Scope)

These are intentionally NOT included in this redesign:

1. **Themes Gallery** - Predefined color schemes (blue, green, purple, etc.)
2. **Font Family Picker** - Different fonts (Roboto, Inter, SF Pro)
3. **Advanced APRE Settings** - Custom protocols, rep ranges
4. **Settings Search** - Search bar for finding specific settings
5. **Settings Backup/Sync** - Cloud sync of preferences

**Rationale:** Keep MVP simple. Add only if users explicitly request.

---

## 📝 Notes

- All hardcoded values can be reverted if users complain
- Color parsing handles both `#RRGGBB` and `RRGGBB` formats
- Font scaling applies to ALL text in app via MaterialApp.textTheme
- APRE section collapses to save space when disabled
- iOS checks remain for platform-specific features

---

**Design Approved By:** @MicheleFerr
**Design Date:** 2025-11-08
**Implementation Target:** 2025-11-08 (same day)
