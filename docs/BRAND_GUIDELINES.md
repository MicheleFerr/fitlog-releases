# FitLog Pro - Brand Guidelines

**Version**: 1.0 | **Last Updated**: 2026-02-12

Guida di riferimento per l'identita visiva e il design system di FitLog Pro. Ogni elemento UI dell'app DEVE seguire queste linee guida per garantire coerenza visiva.

---

## 1. Nome & Identita

| Elemento | Valore |
|----------|--------|
| **Nome app** | FitLog Pro |
| **Nome interno** | gymbro_flutter_new |
| **Tagline** | Advanced Fitness Tracking App |
| **Lingue** | Inglese (primaria), Italiano |

### Uso del nome

- **Corretto**: "FitLog Pro", "FitLog"
- **Sbagliato**: "fitlog pro", "Fit Log", "GymBro" (nome legacy)
- In contesti informali si puo abbreviare in "FitLog"

---

## 2. Palette Colori

### 2.1 Colori Brand (Costanti)

Colori fissi usati per significati semantici specifici, indipendenti dal tema scelto dall'utente.

| Nome | Hex | RGB | Uso |
|------|-----|-----|-----|
| **Primary Blue** | `#1E88E5` | 30, 136, 229 | Colore brand principale, azioni primarie |
| **Secondary Orange** | `#FF7043` | 255, 112, 67 | Workout in corso, stato attivo |
| **Success Green** | `#43A047` | 67, 160, 71 | Completamento, feedback positivo |
| **Warning Amber** | `#FFB300` | 255, 179, 0 | Avvisi, attenzione richiesta |
| **Error Red** | `#E53935` | 229, 57, 53 | Errori, azioni distruttive |

### 2.2 Temi Utente (Seed Colors)

L'utente puo scegliere il tema dell'app. Ogni colore genera una palette Material 3 completa via `ColorScheme.fromSeed()`.

| Tema | Hex | Nome Material |
|------|-----|---------------|
| Blue (default) | `#2196F3` | Material Blue 500 |
| Red | `#F44336` | Material Red 500 |
| Green | `#4CAF50` | Material Green 500 |
| Purple | `#9C27B0` | Material Purple 500 |
| Orange | `#FF9800` | Material Orange 500 |
| Teal | `#009688` | Material Teal 500 |
| Pink | `#E91E63` | Material Pink 500 |

### 2.3 Colori Semantici Estesi

Colori che cambiano automaticamente tra light e dark mode.

| Semantica | Light | Dark | Uso |
|-----------|-------|------|-----|
| Warning | `#FFB300` | `#FFD54F` | Avvisi |
| Warning Container | `#FFE082` | `#6A4C00` | Sfondo avvisi |
| Success | `#43A047` | `#66BB6A` | Completamento |
| Success Container | `#C8E6C9` | `#1B5E20` | Sfondo successo |

### 2.4 Colori Workout-Specific

| Ruolo | Colore | Hex |
|-------|--------|-----|
| Workout attivo | Deep Orange | `#FF6F00` |
| Rest timer | Blue | `#1976D2` |
| Personal Record | Gold | `#FFD700` |
| Timer inattivo | Surface Variant | `#E7E0EC` |

### 2.5 Regole d'Uso

```dart
// CORRETTO - Usa context extensions
context.colors.primary
context.colors.success
context.colors.warning
context.iconPrimary
context.iconSuccess

// SBAGLIATO - Mai colori hardcoded
Colors.blue        // NO
Color(0xFF1E88E5)  // NO (eccetto in file tema)
```

---

## 3. Tipografia

### 3.1 Font

**Font**: [Inter](https://rsms.me/inter/) via `google_fonts` package

| Weight | Uso |
|--------|-----|
| Regular (400) | Body text, descrizioni, contenuto generico |
| Medium (500) | Label, sottotitoli, testo secondario enfatizzato |
| SemiBold (600) | Titoli di sezione, card header, bottoni |
| Bold (700) | Titoli principali, numeri importanti (peso, PR) |

**Perche Inter**:
- Eccellente leggibilita sui numeri (critico per set/rep/peso)
- Ottimizzato per schermi a bassa risoluzione e dimensioni piccole
- Open-source, nessun costo di licenza
- Usato da GitHub, Linear, Figma - feeling moderno e tech

**Implementazione**: Font bundlati localmente in `assets/fonts/` e dichiarati in `pubspec.yaml`. Applicato globalmente tramite `fontFamily: 'Inter'` in `app_theme.dart`. Nessun download runtime, nessuna dipendenza da `google_fonts`. Tutti i widget ereditano il font automaticamente.

### 3.2 Regole Testo

- Tutti i testi visibili devono usare `context.l10n.*` (mai stringhe hardcoded)
- `context.l10n` solo nel Presentation layer (widgets/screens)
- Mai usare `const` con `context.l10n` (causa errori build iOS)
- Non specificare `fontFamily` nei widget: il tema gestisce tutto

---

## 4. Iconografia

### 4.1 Sistema Icone

Tutte le icone sono centralizzate in `AppIcons` (1000+ icone Material Design).

```dart
// CORRETTO
Icon(AppIcons.workout)
Icon(AppIcons.timer)

// SBAGLIATO
Icon(Icons.fitness_center)  // Mai usare Icons.* direttamente
```

### 4.2 Dimensioni Icone

Sistema semantico basato su Material Design 3:

| Token | Dimensione | Contesto |
|-------|------------|----------|
| `tiny` | 16dp | Badge, indicatori inline |
| `small` | 20dp | Chip, liste dense, bottoni compatti |
| `medium` | 24dp | **Standard** - bottoni, list items |
| `large` | 28dp | Card headers, azioni evidenziate |
| `xlarge` | 32dp | Feature icons, section headers |
| `xxlarge` | 48dp | Hero sections, empty states |

**Alias contestuali**:

| Contesto | Token | Dimensione |
|----------|-------|------------|
| AppBar | `appBar` | 24dp |
| Bottom Nav | `bottomNavBar` | 24dp |
| Tab Bar | `tabBar` | 20dp |
| Card | `card` | 28dp |
| Exercise Card | `exerciseCard` | 28dp |
| Workout Timer | `workoutTimer` | 48dp |
| Rest Timer | `restTimer` | 32dp |
| Input field | `input` | 20dp |
| Chip | `chip` | 20dp |
| Empty state | `emptyState` | 48dp |

```dart
// CORRETTO
Icon(AppIcons.workout, size: AppIconSize.medium)
Icon(AppIcons.timer, size: AppIconSize.workoutTimer)

// SBAGLIATO
Icon(AppIcons.workout, size: 24)  // Mai magic numbers
```

### 4.3 Colori Icone

Sistema semantico theme-aware tramite `IconColorContext`:

| Token | Significato |
|-------|-------------|
| `context.iconPrimary` | Azioni principali, brand |
| `context.iconSecondary` | Azioni secondarie |
| `context.iconSuccess` | Completamento, positivo |
| `context.iconError` | Errori, distruttivo |
| `context.iconWarning` | Attenzione |
| `context.iconDefault` | Contenuto primario (alta enfasi) |
| `context.iconMediumEmphasis` | Contenuto secondario (60%) |
| `context.iconLowEmphasis` | Hint, placeholder (40%) |
| `context.iconDisabled` | Disabilitato |
| `context.iconWorkoutActive` | Workout attivo (arancione) |
| `context.iconRestTimer` | Rest timer (blu) |
| `context.iconPersonalRecord` | Record personale (oro) |

---

## 5. Spacing

### 5.1 Sistema Base 4

Tutti gli spacing sono multipli di 4px per allineamento pixel-perfect.

| Token | Valore | Uso tipico |
|-------|--------|------------|
| `xxs` | 4px | Padding interno chip, micro gap |
| `xs` | 8px | Gap elementi correlati, padding list tile |
| `sm` | 12px | Gap in gruppo, padding card sezione |
| `md` | 16px | **Default** - padding card, margin list items |
| `lg` | 20px | Gap tra sezioni, margin screen orizzontale |
| `xl` | 24px | Padding dialog, gap major sections |
| `xxl` | 32px | Spacing tra feature sections |
| `xxxl` | 48px | Empty state, hero sections |
| `xxxxl` | 64px | Onboarding, splash |

### 5.2 Alias Semantici

| Alias | Valore | Contesto |
|-------|--------|----------|
| `cardPadding` | 16px | Interno card standard |
| `cardPaddingCompact` | 12px | Card compatta |
| `dialogPadding` | 24px | Interno dialog |
| `bottomSheetPadding` | 24px | Interno bottom sheet |
| `sectionSpacing` | 32px | Tra sezioni principali |
| `screenMarginHorizontal` | 20px | Margine orizzontale schermo |
| `screenMarginVertical` | 24px | Margine verticale schermo |
| `listItemGap` | 16px | Gap tra list items |
| `formFieldGap` | 16px | Gap tra campi form |
| `iconTextGap` | 8px | Gap tra icona e testo |
| `buttonGap` | 12px | Gap tra bottoni in riga |

### 5.3 Responsive

| Breakpoint | Scala | Device |
|------------|-------|--------|
| < 600px | 1.0x | Mobile |
| 600-900px | 1.25x | Tablet |
| > 900px | 1.5x | Desktop |

```dart
// CORRETTO
Padding(padding: EdgeInsets.all(AppSpacing.md))
SizedBox(height: AppSpacing.xs)
EdgeInsets.symmetric(horizontal: AppSpacing.screenMarginHorizontal)

// SBAGLIATO
Padding(padding: EdgeInsets.all(15))  // Non multiplo di 4!
SizedBox(height: 10)                  // Usa AppSpacing.xs (8) o AppSpacing.sm (12)
```

---

## 6. Border Radius

### 6.1 Scala

| Token | Valore | Uso |
|-------|--------|-----|
| `xxs` | 2px | Progress bar, slider, handle |
| `xxs2` | 4px | Chip interno, badge piccolo |
| `xs` | 8px | Chip, badge, tooltip |
| `sm` | 12px | **Bottoni**, input, card compatta |
| `md` | 16px | **Card standard**, bottom sheet |
| `lg` | 20px | Card con enfasi |
| `xl` | 24px | Dialog, modal |
| `xxl` | 32px | Hero section |
| `circular` | 9999px | Avatar, FAB |

### 6.2 Alias Semantici

| Componente | Token | Valore |
|------------|-------|--------|
| Card | `card` | 16px |
| Card compatta | `cardCompact` | 12px |
| Bottone | `button` | 12px |
| Input field | `input` | 12px |
| Dialog | `dialog` | 24px |
| Bottom sheet | `bottomSheet` | 16px |
| Chip | `chip` | 8px |
| Badge | `badge` | 8px |
| Progress bar | `progressBar` | 2px |

```dart
// CORRETTO
BorderRadius.circular(AppBorderRadius.card)
AppBorderRadius.smRadius  // Pre-built BorderRadius

// SBAGLIATO
BorderRadius.circular(15)  // Non standardizzato
```

---

## 7. Card System

### 7.1 Design Tokens

| Token | Valore |
|-------|--------|
| Corner radius standard | 16px |
| Corner radius compact | 12px |
| Category strip width | 4px (default), 6px (pressed), 3px (compact) |
| Watermark opacity | 0.08 |
| Press scale | 0.98x |
| Strip glow opacity | 0.3 |

### 7.2 Dimensioni Watermark

| Card Size | Watermark |
|-----------|-----------|
| Large (200px height) | 120px |
| Medium (grid) | 80px |
| Small (compact) | 48px |

### 7.3 Elevazione

| Modo | Card elevation | Tipo |
|------|---------------|------|
| Light | 2 | Standard |
| Dark | 4 | Standard |
| FAB | 4 | Floating |
| Bottom Nav | 8 | Navigation |
| AppBar | 0 (scrolled: 1) | Flat |

### 7.4 Animazioni

| Animazione | Durata |
|------------|--------|
| Press feedback | 150ms |
| Fade-in on mount | 500ms |

---

## 8. Componenti UI Obbligatori

| Componente | Usare | Non usare |
|------------|-------|-----------|
| Icone | `AppIcons.*` | `Icons.*` |
| Testi | `context.l10n.*` | Stringhe hardcoded |
| Colori | `context.colors.*` | `Colors.*` |
| Loading | `LoadingIndicator()` | `CircularProgressIndicator()` |
| Snackbar | `SnackBarService.*` | `ScaffoldMessenger.*` |
| Icon size | `AppIconSize.*` | Magic number |
| Spacing | `AppSpacing.*` | Numeri diretti |
| Radius | `AppBorderRadius.*` | `BorderRadius.circular(n)` |

---

## 9. Splash Screen & Branding

### 9.1 Native Splash

- **Colore sfondo**: `#1B2838` (dark blue)
- **Stile**: Solo colore solido (no immagine)
- **Transizione**: Native splash (colore) -> Animated splash (Lottie + logo)

### 9.2 Asset

| Asset | File | Uso |
|-------|------|-----|
| Logo splash | `assets/images/splash_logo.png` | Splash screen animata |
| Loading animation | `assets/animations/fitness_loading.json` | Lottie loading indicator |
| Body diagram | `assets/images/human_body.svg` | Selezione muscoli |

### 9.3 Audio

| Suono | File | Trigger |
|-------|------|---------|
| App intro | `assets/sounds/app_intro.mp3` | Avvio app |
| Timer complete | `assets/sounds/timer_complete.wav` | Fine rest timer |
| Timer finished | `assets/sounds/timer_finished.caf` | Fine workout timer |
| LightWeight | `assets/sounds/LightWeight.caf` | Cue motivazionale |
| YehBuddie | `assets/sounds/YehBuddie.caf` | Cue motivazionale |

---

## 10. Dark Mode

FitLog Pro supporta dark mode completo:

- Generato automaticamente da Material 3 `ColorScheme.fromSeed(brightness: Brightness.dark)`
- Colori semantici (success, warning) hanno varianti light/dark dedicate
- Ombreggiature card piu marcate in dark (alpha 0.25 vs 0.12)
- Android supporta varianti native (`drawable-night-*`, `values-night-v31`)

---

## 11. Accessibilita

- **Standard**: WCAG 2.2 Level AA
- **Verifica automatica**: `ContrastChecker.verifyColorScheme()` eseguito in debug mode per ogni ColorScheme
- **Touch target minimo**: 48dp (gestito da `AppIconSize.forTouchTarget()`)
- **Responsive**: Scale automatiche per tablet (1.15x icone, 1.25x spacing) e desktop (1.25x icone, 1.5x spacing)

---

## 12. File di Riferimento

| File | Contenuto |
|------|-----------|
| `lib/shared/presentation/theme/app_theme.dart` | Palette colori, tema light/dark |
| `lib/shared/presentation/theme/color_scheme_extensions.dart` | Colori semantici estesi |
| `lib/shared/presentation/theme/app_icons.dart` | Libreria 1000+ icone |
| `lib/shared/presentation/theme/app_icon_size.dart` | Sistema dimensioni icone |
| `lib/shared/presentation/theme/app_icon_colors.dart` | Colori semantici icone |
| `lib/shared/presentation/theme/app_spacing.dart` | Sistema spacing base 4 |
| `lib/shared/presentation/theme/app_border_radius.dart` | Sistema border radius |
| `lib/shared/presentation/theme/app_card_styles.dart` | Design tokens card |
| `lib/shared/presentation/extensions/build_context_extensions.dart` | Context extensions |

---

## 13. Gap Noti

Elementi non ancora implementati che potrebbero essere aggiunti in futuro:

| Elemento | Priorita | Note |
|----------|----------|------|
| ~~Font custom~~ | ~~Alta~~ | ~~Attualmente solo font di sistema~~ -> Implementato: Inter |
| Varianti logo | Media | Solo 1 splash logo, mancano icon-only e orizzontale |
| App Store assets | Alta (per lancio) | Screenshot, promo graphics |
| Figma design file | Media | Nessun file di design collegato |
| Web branding | Bassa | Favicon, manifest, social share images |

---

*Questo documento formalizza il design system implementato nel codice. Per modifiche al sistema, aggiornare sia il codice che questo documento.*
