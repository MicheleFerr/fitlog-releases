# Assets Attribution - FitLog Pro

This document lists all third-party assets used in FitLog Pro and their sources.

## Exercise Demonstration Images

**Source**: [ExerciseDB](https://exercisedb.io)
**Type**: GIF animations
**Usage**: Exercise form demonstrations
**License**: ExerciseDB Terms of Service
**API**: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb

Exercise demonstration GIF images are loaded dynamically from ExerciseDB servers. No images are stored locally. Only the image URL is requested - no personal data is shared.

**Attribution Notice**: Exercise GIF animations provided by ExerciseDB (exercisedb.io)

---

## Sound Effects

All sound effects are **original content created for FitLog Pro** or royalty-free.

| File | Description | Source | License |
|------|-------------|--------|---------|
| `timer_complete.wav` | Timer completion sound | Original | Proprietary |
| `timer_finished.caf` | iOS timer finished sound | Original (converted from wav) | Proprietary |
| `YehBuddie.wav` | Motivational audio clip | Royalty-free/Original | Internal use |
| `YehBuddie.caf` | iOS version | Converted from wav | Internal use |
| `LightWeight.wav` | Motivational audio clip | Royalty-free/Original | Internal use |
| `LightWeight.caf` | iOS version | Converted from wav | Internal use |
| `silent_1s.wav` | Silent audio for background mode | Generated | Public domain |

**Note**: `.caf` files are Core Audio Format versions for iOS compatibility.

---

## Body Illustration

**File**: `assets/images/human_body.svg`
**Type**: SVG vector graphic
**Usage**: Muscle group selection
**Source**: muscle_selector package (pub.dev)
**License**: Check package license

This SVG is also present in the `muscle_selector` package at:
`packages/muscle_selector/assets/maps/human_body.svg`

---

## App Icons

All app icons and branding are **original designs** created for FitLog Pro.

- App icon
- Splash screen assets
- Marketing materials

**Copyright**: Michele - All rights reserved

---

## Authentication Brand Logos

### Google Sign-In Logo

**File**: `assets/images/google_logo.svg`  
**Source**: Google "G" logo (Wikimedia mirror of official brand asset)  
**URL**: https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg  
**Usage**: Login / registration buttons for Google authentication  
**Trademark**: Google and the Google logo are trademarks of Google LLC.

### Apple Sign-In Logo

**File**: `assets/images/apple_logo.svg`  
**Source**: Apple logo (Wikimedia mirror of official brand mark)  
**URL**: https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg  
**Usage**: Login / registration buttons for Apple authentication  
**Trademark**: Apple and the Apple logo are trademarks of Apple Inc.

---

## Third-Party Packages

All Flutter/Dart packages are MIT, BSD, or Apache 2.0 licensed. See `flutter pub deps` for the complete list.

Key packages with bundled assets:
- `flutter_svg` - SVG rendering
- `google_fonts` - Font loading (fonts loaded from Google servers)
- `firebase_*` - Firebase SDK assets

---

## Fonts

**Primary Font**: System fonts (San Francisco on iOS, Roboto on Android)
**Fallback**: Google Fonts loaded at runtime (not bundled)

---

## Legal Compliance

This asset documentation is provided for:
1. **GDPR Compliance** - Transparency about data sources
2. **Copyright Compliance** - Proper attribution
3. **App Store Requirements** - Asset licensing disclosure

For questions about asset licensing, contact: ferrara-michele@hotmail.it

---

*Last updated: January 2025*
