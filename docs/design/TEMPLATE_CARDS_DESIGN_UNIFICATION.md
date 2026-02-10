# 🎨 Template Cards Design Unification

**Data**: 2026-02-08
**Status**: ✅ Implementato
**Priorità**: Media
**Effort stimato**: 2-3 ore
**Completato**: 2026-02-08

---

## 📋 Executive Summary

Unificazione del design delle template card tra `WorkoutScreen` e `TemplatesHomeScreen` per creare un'esperienza visiva coerente, mantenendo le funzionalità specifiche di ogni contesto.

---

## 🗂️ File Analizzati

| File | Widget | Contesto |
|------|--------|----------|
| `lib/features/workout/presentation/widgets/template_card.dart` | `TemplateCard` | WorkoutScreen (horizontal scroll) |
| `lib/features/workout_templates/presentation/widgets/cards/workout_template_card.dart` | `WorkoutTemplateCard` | TemplatesHomeScreen (grid) |
| `lib/features/workout_templates/presentation/widgets/cards/compact_template_card.dart` | `CompactTemplateCard` | Discover tab (horizontal) |

---

## 🔍 Analisi Codice Dettagliata

### Confronto Strutturale

| Aspetto | TemplateCard | WorkoutTemplateCard | CompactTemplateCard |
|---------|-------------|---------------------|---------------------|
| **Dimensioni** | 200px × auto | auto × auto (grid) | 180px × auto |
| **Corner radius** | `16px` ✅ | `12px` (AppSpacing.md) ❌ | `12px` ❌ |
| **Container** | `Container` con gradient | `DecoratedBox` | `Card` |

### Indicatore Categoria

| Aspetto | TemplateCard | WorkoutTemplateCard | CompactTemplateCard |
|---------|-------------|---------------------|---------------------|
| **Tipo** | Left strip 3-5pt | Border 1.5pt + header icon | Border 1.5pt + header icon |
| **Animazione** | ✅ AnimatedContainer | ❌ | ❌ |
| **Glow** | ✅ BoxShadow 6px | ❌ | ❌ |
| **Watermark** | 120px, alpha 0.08 | 80px, alpha 0.08 | 48px, alpha 0.10 |

### Sistema Ombre

| Aspetto | TemplateCard | WorkoutTemplateCard | CompactTemplateCard |
|---------|-------------|---------------------|---------------------|
| **Primary** | blur 16, offset (0,6) | blur 8, offset (0,2) | Card default |
| **Secondary** | blur 4, offset (0,2) | ❌ | ❌ |
| **Dark mode** | alpha 0.25/0.10 | alpha 0.10 | N/A |

### Contenuto Card

| Elemento | TemplateCard | WorkoutTemplateCard | CompactTemplateCard |
|----------|-------------|---------------------|---------------------|
| **Titolo** | titleLarge + bold | titleSmall + bold | labelLarge + bold |
| **Badge difficoltà** | ✅ _DifficultyBadge | ❌ Mancante | ❌ Mancante |
| **Preview esercizi** | ✅ "A · B · C +N" | ❌ Mancante | ❌ Mancante |
| **Durata** | ✅ Con icona schedule | ✅ Con icona timer | ✅ Semplice |
| **Last performed** | ✅ Con status color | ❌ Mancante | ❌ Mancante |
| **Fork attribution** | ❌ | ✅ | ❌ |
| **Menu azioni** | ❌ (onTap diretto) | ✅ PopupMenuButton | ❌ (onUse button) |

### Interazioni

| Aspetto | TemplateCard | WorkoutTemplateCard | CompactTemplateCard |
|---------|-------------|---------------------|---------------------|
| **Scala press** | ✅ 0.98 | ❌ | ❌ |
| **Haptic** | ✅ mediumImpact | ❌ | ❌ |
| **Fade-in mount** | ✅ 500ms | ❌ | ❌ |
| **Strip animation** | ✅ 3→5pt | ❌ | ❌ |

---

## 🎯 Obiettivi

1. **Coerenza visiva** → Stessa identità tra le due schermate
2. **Riconoscibilità categoria** → Utente capisce subito il tipo di workout
3. **Gerarchia informativa** → Dati più importanti in evidenza
4. **Performance** → Nessun impatto negativo su scroll/rendering

---

## 👥 Analisi Personas

### Marco (Principiante intimidito)
| Aspetto | Impatto | Note |
|---------|---------|------|
| Strip categoria colorata | ✅ **++** | Orientamento visivo immediato senza leggere |
| Watermark icona | ✅ **+** | Rinforza visivamente la categoria |
| Badge difficoltà | ✅ **++** | Sa subito se è adatto al suo livello |
| Preview esercizi | ✅ **+** | Capisce cosa farà prima di iniziare |

**Verdict**: 🟢 Molto positivo - Design più accessibile e meno intimidatorio

---

### Chiara (Mamma multitasking)
| Aspetto | Impatto | Note |
|---------|---------|------|
| Strip categoria colorata | ✅ **+** | Scan rapido della lista |
| Watermark icona | ⚪ **0** | Non aggiunge friction |
| Badge difficoltà | ✅ **+** | Scelta rapida |
| Durata visibile | ✅ **++** | Critico per pianificare tempo |
| Last performed | ✅ **+** | Sa cosa ha fatto di recente |

**Verdict**: 🟢 Positivo - Velocizza la scelta del workout

---

### Luca (Powerlifter serio)
| Aspetto | Impatto | Note |
|---------|---------|------|
| Strip categoria | ⚪ **0** | Non essenziale per lui |
| Watermark | ⚪ **0** | Decorativo |
| Badge difficoltà | ⚪ **0** | Lui sa già il suo livello |
| Preview esercizi | ✅ **+** | Utile per verificare contenuto |
| Stats dettagliate | ✅ **++** | Vuole vedere avgDuration reale |
| Last performed con colore | ✅ **+** | Traccia recovery tra sessioni |

**Verdict**: 🟡 Neutro/Positivo - Non lo disturba, apprezza i dati

---

### Sofia (Estetica-driven)
| Aspetto | Impatto | Note |
|---------|---------|------|
| Gradient categoria | ✅ **++** | Visivamente accattivante |
| Watermark icona | ✅ **+** | Design moderno |
| Ombre e profondità | ✅ **++** | App sembra premium |
| Colori coerenti | ✅ **++** | Esperienza curata |
| Badge difficoltà | ✅ **+** | Elemento di gamification |

**Verdict**: 🟢 Molto positivo - Migliora percezione qualità app

---

### Roberto (Professionista busy)
| Aspetto | Impatto | Note |
|---------|---------|------|
| Strip categoria | ✅ **+** | Scan efficiente |
| Informazioni dense | ✅ **++** | Tutto visibile senza tap extra |
| Durata prominente | ✅ **++** | Critico per time-boxing |
| Design pulito | ✅ **+** | No distrazioni |
| Coerenza tra schermate | ✅ **+** | Meno cognitive load |

**Verdict**: 🟢 Positivo - Aumenta efficienza

---

### 📊 Summary Personas

| Persona | Score | Blockers |
|---------|-------|----------|
| Marco | ✅ ++ | Nessuno |
| Chiara | ✅ + | Nessuno |
| Luca | ⚪ 0/+ | Nessuno |
| Sofia | ✅ ++ | Nessuno |
| Roberto | ✅ + | Nessuno |

**Decisione**: ✅ Procedere - Nessun impatto negativo, 4/5 personas beneficiano

---

---

## 🎯 Raccomandazioni Design (Basate su Ricerca Online)

### Ispirazione: Nike Training Club + Apple Fitness+

Secondo [Nike Training Club UX Case Study](https://medium.com/@eunice.choi/ux-case-study-nike-training-club-371c2b79e6dc):
- Card design segue "visual system" coerente in tutta l'app
- Uso di **forme dinamiche** che incoraggiano movimento
- **Contrasto bold** per gerarchia visiva

Secondo [Stormotion Fitness App UI](https://stormotion.io/blog/fitness-app-ux/):
- **Non sovraccaricare** - evidenziare solo elementi principali
- **Diagrammi e visuali** funzionano meglio del testo
- Mantenere **consistenza comportamentale** tra schermate

### Pattern Chiave da Adottare

1. **Strip laterale** → Elemento distintivo di FitLog (come Activity Rings per Apple)
2. **Gerarchia colori** → Categoria = accento primario
3. **Micro-interazioni** → Press feedback su tutte le card
4. **Info density** → Mostrare 3-4 dati chiave max

---

## 🔄 Stato Attuale vs Target

### Design Tokens Unificati

```dart
// 📐 Dimensioni
const double kCardCornerRadius = 16.0;
const double kCategoryStripWidth = 4.0;
const double kCategoryStripWidthPressed = 6.0;

// 🎨 Opacità
const double kWatermarkOpacity = 0.08;
const double kBorderOpacity = 0.4;
const double kGlowOpacity = 0.3;

// 📏 Watermark sizes
const double kWatermarkSizeLarge = 120.0;  // TemplateCard (200px height)
const double kWatermarkSizeMedium = 80.0;  // _WorkoutTemplateCard (grid)
const double kWatermarkSizeSmall = 48.0;   // _CompactTemplateCard (horizontal)

// 🌫️ Ombre
const List<BoxShadow> kCardShadows = [
  BoxShadow(blurRadius: 16, offset: Offset(0, 6)),  // Primary
  BoxShadow(blurRadius: 4, offset: Offset(0, 2)),   // Secondary
];
```

### Confronto Elementi (Basato su Analisi Codice)

| Elemento | TemplateCard | WorkoutTemplateCard | CompactTemplateCard | Target |
|----------|--------------|---------------------|---------------------|--------|
| **Corner radius** | 16px ✅ | 12px ❌ | 12px ❌ | **16px** |
| **Strip categoria** | ✅ 3-5pt animated | ❌ Border only | ❌ Border only | **Strip left** |
| **Ombre** | ✅ Double | ❌ Single | ❌ Card default | **Double** |
| **Watermark** | 120px | 80px | 48px | **Proporzionale** ✅ |
| **Badge difficoltà** | ✅ | ❌ | ❌ | **Aggiungere** |
| **Preview esercizi** | ✅ "A·B·C +N" | ❌ | ❌ | **Aggiungere** |
| **Last performed** | ✅ status color | ❌ | ❌ | **Aggiungere** |
| **Press animation** | ✅ 0.98 scale | ❌ | ❌ | **Aggiungere** |
| **Haptic feedback** | ✅ medium | ❌ | ❌ | **Aggiungere** |
| **Gradient header** | ❌ | ✅ | ✅ | **Mantenere** ✅ |

---

## 📝 Piano Implementazione

### Fase 1: Design Tokens (30 min)

**File**: `lib/shared/presentation/theme/app_card_styles.dart` (nuovo)

```dart
/// Unified card design tokens for template cards
class AppCardStyles {
  AppCardStyles._();

  // Corner radius
  static const double cornerRadius = 16.0;

  // Category strip
  static const double stripWidth = 4.0;
  static const double stripWidthPressed = 6.0;

  // Shadows
  static List<BoxShadow> cardShadows(BuildContext context) => [
    BoxShadow(
      color: context.colors.shadow.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 1,
    ),
    BoxShadow(
      color: context.colors.onSurface.withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  // Watermark
  static const double watermarkOpacity = 0.08;
  static double watermarkSize(CardSize size) => switch (size) {
    CardSize.large => 120.0,
    CardSize.medium => 80.0,
    CardSize.small => 48.0,
  };
}

enum CardSize { large, medium, small }
```

---

### Fase 2: Aggiornare `WorkoutTemplateCard` (45 min)

**File**: `lib/features/workout_templates/presentation/widgets/cards/workout_template_card.dart`

#### 2.1 Aggiungere Strip Categoria

```dart
// Dentro Stack children, PRIMA del DecoratedBox:
// Left accent strip (matches TemplateCard)
AnimatedContainer(
  duration: const Duration(milliseconds: 150),
  curve: Curves.easeOut,
  width: _isPressed ? 6 : 4,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        categoryColor.withValues(alpha: 0.9),
        categoryColor.withValues(alpha: 0.7),
      ],
    ),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      bottomLeft: Radius.circular(16),
    ),
    boxShadow: [
      BoxShadow(
        color: categoryColor.withValues(alpha: 0.3),
        blurRadius: 6,
        offset: const Offset(2, 0),
      ),
    ],
  ),
),
```

#### 2.2 Aggiungere Badge Difficoltà

```dart
// Nel header Row, dopo il titolo:
const SizedBox(width: AppSpacing.sm),
_DifficultyBadge(difficulty: template.effectiveDifficulty),
```

#### 2.3 Aggiungere Preview Esercizi

```dart
// Dopo il titolo:
if (template.exercises.isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    child: Text(
      _buildExercisePreview(template),
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  ),

// Helper method:
String _buildExercisePreview(WorkoutTemplate template) {
  final names = template.exercises.take(3).map((e) => e.exerciseName).join(' · ');
  final remaining = template.exercises.length > 3 ? ' +${template.exercises.length - 3}' : '';
  return '$names$remaining';
}
```

#### 2.4 Aggiornare Stats Row con Last Performed

```dart
// Aggiungere dopo duration:
if (stats?.lastPerformed != null) ...[
  const SizedBox(width: AppSpacing.xs),
  Container(/* bullet separator */),
  const SizedBox(width: AppSpacing.xs),
  SemanticIcon(
    icon: AppIcons.history,
    size: AppIconSize.tiny,
    color: stats!.statusColor(context),
  ),
  const SizedBox(width: 2),
  Text(
    stats!.formattedLastPerformed(context),
    style: context.textTheme.labelSmall?.copyWith(
      color: stats!.statusColor(context),
    ),
  ),
],
```

#### 2.5 Aggiornare Corner Radius e Ombre

```dart
decoration: BoxDecoration(
  color: context.colors.surface,
  borderRadius: BorderRadius.circular(16), // Era 12
  boxShadow: [
    BoxShadow(
      color: context.colors.shadow.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 1,
    ),
    BoxShadow(
      color: context.colors.onSurface.withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ],
  // Rimuovere border, sostituito dalla strip
),
```

---

### Fase 3: Estrarre Widget Condivisi (30 min)

**File**: `lib/features/workout/presentation/widgets/shared/` (nuova cartella)

#### 3.1 `difficulty_badge.dart`

Estrarre `_DifficultyBadge` da `template_card.dart` in widget riutilizzabile.

#### 3.2 `exercise_preview_text.dart`

Widget per "Panca · Croci · Dips +3" pattern.

#### 3.3 `category_strip.dart`

Widget per la strip colorata sinistra.

#### 3.4 `template_metadata_row.dart`

Widget per duration + last performed.

---

### Fase 4: Aggiornare `_CompactTemplateCard` (20 min)

Applicare stesso pattern ma con dimensioni ridotte:
- Strip categoria più sottile (3pt)
- Watermark 48px
- Badge difficoltà opzionale (spazio limitato)

---

### Fase 5: Testing Visivo (15 min)

- [ ] Verificare coerenza light/dark mode
- [ ] Testare su diversi device sizes
- [ ] Verificare accessibilità contrasti
- [ ] Controllare performance scroll

---

## 📁 File da Modificare

### File Principali (Corretti dopo analisi codice)

| File | Widget | Azione | Priorità |
|------|--------|--------|----------|
| `lib/features/workout_templates/presentation/widgets/cards/workout_template_card.dart` | `WorkoutTemplateCard` | ✏️ Aggiungere strip, press animation, difficulty | **P1** |
| `lib/features/workout_templates/presentation/widgets/cards/compact_template_card.dart` | `CompactTemplateCard` | ✏️ Aggiornare radius, ombre | **P2** |
| `lib/features/workout/presentation/widgets/template_card.dart` | `TemplateCard` | 🔄 Estrarre widget condivisi | **P2** |

### File Nuovi da Creare

| File | Scopo | Priorità |
|------|-------|----------|
| `lib/shared/presentation/theme/app_card_styles.dart` | Design tokens unificati | **P1** |
| `lib/features/workout/presentation/widgets/shared/category_strip.dart` | Widget strip riutilizzabile | **P2** |
| `lib/features/workout/presentation/widgets/shared/difficulty_badge.dart` | Badge estratto da TemplateCard | **P2** |

---

## ✅ Checklist Pre-Implementazione

- [ ] Leggere `TemplateCard` per copiare esattamente lo stile
- [ ] Verificare che `effectiveCategory` e `effectiveDifficulty` funzionino
- [ ] Controllare import di `TemplateCategory` (hide conflict)
- [ ] Testare su template con e senza stats

---

## 🔗 Reference

- [Fitness App UI Best Practices](https://stormotion.io/blog/fitness-app-ux/)
- [Apple HIG - Cards](https://developer.apple.com/design/human-interface-guidelines/patterns)
- [Dribbble Workout Cards](https://dribbble.com/tags/workout-card)

---

## 📊 Metriche Successo

| Metrica | Target |
|---------|--------|
| Coerenza visiva | 100% elementi allineati |
| Performance | <16ms frame time (60fps) |
| Accessibilità | WCAG AA contrast ratio |
| Code duplication | <10% (widget condivisi) |
