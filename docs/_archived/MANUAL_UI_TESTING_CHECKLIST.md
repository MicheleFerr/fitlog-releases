# 📱 Settings Screen Redesign - Manual UI Testing Checklist

> **Project**: Settings Screen Redesign (9 Tasks)
> **Testing Phase**: Task 10 - Final Manual UI Testing
> **Date**: 08/11/2025

---

## ✅ Pre-Testing Verification (Automated - COMPLETED)

- [x] 21/21 automated tests passed
- [x] flutter analyze: 0 new errors
- [x] Pre-commit hooks validation passed
- [x] Code compiles without errors

---

## 🎨 Appearance Section

### Theme Mode Selection
- [ ] Open Settings → Appearance → Theme Mode
- [ ] Tap on current theme mode (shows dialog with 3 options)
- [ ] Select **Light** → Verify app immediately switches to light theme
- [ ] Select **Dark** → Verify app immediately switches to dark theme
- [ ] Select **System** → Verify app follows system theme
- [ ] **Expected**: Icon preview updates (sun/moon/auto icon)
- [ ] **Expected**: Theme applies instantly WITHOUT app restart

### Theme Color Selection
- [ ] Open Settings → Appearance → Theme Color
- [ ] Tap on current color (shows color picker dialog)
- [ ] Select **Blue** → Verify primary color changes to blue
- [ ] Select **Green** → Verify primary color changes to green
- [ ] Select **Orange** → Verify primary color changes to orange
- [ ] Select **Purple** → Verify primary color changes to purple
- [ ] **Expected**: Color circle preview updates immediately
- [ ] **Expected**: All UI elements with primary color update instantly (buttons, FAB, etc.)

### Font Size Adjustment
- [ ] Open Settings → Appearance → Text Size
- [ ] Move slider to **minimum** (0.8x)
- [ ] **Expected**: Preview text "Preview text size" scales down
- [ ] **Expected**: All app text becomes smaller
- [ ] Move slider to **default** (1.0x)
- [ ] **Expected**: Text returns to normal size
- [ ] Move slider to **maximum** (1.2x)
- [ ] **Expected**: Preview text and all app text becomes larger

---

## 🏋️ Workout Essentials Section

### Default Rest Time
- [ ] Open Settings → Workout Essentials → Default Rest Time
- [ ] Tap on current value (shows dialog)
- [ ] Change to **60 seconds**
- [ ] Start a workout → Complete a set → Verify rest timer starts at 60s
- [ ] Change to **120 seconds**
- [ ] Start a workout → Complete a set → Verify rest timer starts at 120s

### APRE Auto-Adjustment Toggle
- [ ] Open Settings → Workout Essentials
- [ ] **APRE Auto-Adjustment** should be ON by default (enableApre: true)
- [ ] Toggle OFF
- [ ] **Expected**: APRE Protocol setting disappears (conditional rendering)
- [ ] Toggle ON
- [ ] **Expected**: APRE Protocol setting reappears

### APRE Protocol Selection
- [ ] Ensure APRE Auto-Adjustment is ON
- [ ] Tap on **APRE Protocol** (shows dialog with 3 options)
- [ ] Select **3-Set Protocol (Quick)**
- [ ] **Expected**: Value saves and displays "3 sets"
- [ ] Select **6-Set Protocol (Balanced)** - DEFAULT
- [ ] **Expected**: Value saves and displays "6 sets"
- [ ] Select **10-Set Protocol (Thorough)**
- [ ] **Expected**: Value saves and displays "10 sets"
- [ ] Start APRE workout → Verify correct number of sets appear

---

## 🌍 General Section

### Language Selection
- [ ] Open Settings → General → Language
- [ ] Tap on current language (shows dialog)
- [ ] Select **English**
- [ ] **Expected**: All UI text switches to English immediately
- [ ] Select **Italiano**
- [ ] **Expected**: All UI text switches to Italian immediately
- [ ] **Localization keys to verify**:
  - Settings title
  - Section headers (Appearance, Workout Essentials, etc.)
  - Button labels (Save, Cancel, etc.)

### Measurement Unit Selection
- [ ] Open Settings → General → Measurement Unit
- [ ] Tap on current unit (shows dialog)
- [ ] Select **Kilograms (kg)**
- [ ] **Expected**: All weight displays show kg
- [ ] Go to workout → Verify exercises show kg
- [ ] Select **Pounds (lbs)**
- [ ] **Expected**: All weight displays convert to lbs
- [ ] Go to workout → Verify exercises show lbs with correct conversion

---

## 💾 Data Persistence Testing

### Settings Persistence After App Restart
- [ ] Configure ALL settings to non-default values:
  - Theme: Dark
  - Color: Green
  - Font: 1.2x
  - APRE: ON, Protocol 10
  - Rest Time: 90s
  - Language: Italian
  - Unit: lbs
- [ ] **Force quit** the app (swipe up on iOS, task manager on Android)
- [ ] **Reopen** the app
- [ ] **Expected**: ALL settings are preserved (check each one)
- [ ] Navigate to Settings screen
- [ ] **Verify**: Theme is Dark, Color is Green, Font is 1.2x, APRE 10, etc.

---

## 🚫 Removed Sections Verification

### Verify Deprecated Sections Are Gone
- [ ] Open Settings screen
- [ ] **Should NOT see** these sections:
  - ❌ Old "Workout" section (replaced by Workout Essentials)
  - ❌ "iOS Features" section (Live Activities, HealthKit)
  - ❌ "Audio & Feedback" section (Timer sounds, vibrations)
  - ❌ "Advanced" section (Beta mode, reset options)
- [ ] **Should ONLY see** these 4 sections:
  - ✅ Appearance
  - ✅ Workout Essentials
  - ✅ General (Language, Unit, Account)
  - ✅ About (Version, Privacy, Legal)

---

## 🎯 Visual UI Checks

### Preview Icons & Live Feedback
- [ ] Theme Mode shows correct icon (sun/moon/auto)
- [ ] Theme Color shows colored circle (20x20dp with border)
- [ ] Text Size preview text scales with slider in real-time
- [ ] All sections use proper Card design (rounded corners, elevation)
- [ ] ListTile icons use AppIcons.* (no inline Icons.*)
- [ ] All colors use context.colors.* (theme-aware, works in dark/light)

---

## 🐛 Edge Cases & Error Handling

### Invalid Input Validation
- [ ] Font size slider: Try to set below 0.8 or above 1.2
- [ ] **Expected**: Slider prevents going out of bounds
- [ ] APRE Protocol with APRE OFF
- [ ] **Expected**: Protocol setting is hidden

### Network/Offline Scenarios
- [ ] Turn off internet
- [ ] Change settings (theme, font, APRE)
- [ ] **Expected**: Settings save locally (no Firebase errors)
- [ ] Turn on internet
- [ ] **Expected**: Settings sync to Firebase (if logged in)

---

## ✅ Testing Completion

**Date Tested**: _________________

**Tested By**: _________________

**Test Results**:
- [ ] All tests passed ✅
- [ ] Issues found (document below)

### Issues Found (if any):

1. _______________________________________________________
2. _______________________________________________________
3. _______________________________________________________

---

## 📊 Expected Final State After All Tests

**Settings Screen Should Have**:
- ✅ 4 sections total (Appearance, Workout Essentials, General, About)
- ✅ ~1002 lines removed from settings_screen.dart
- ✅ All visual previews working (theme icon, color circle, live font preview)
- ✅ Instant theme updates (no app restart required)
- ✅ APRE system enabled by default with 6-set protocol
- ✅ All text localized (EN + IT)
- ✅ All settings persist after app restart

---

**🎉 If all checkboxes are ticked → Task 10 COMPLETE!**
