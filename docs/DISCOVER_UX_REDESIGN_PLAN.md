# 🎨 Piano Redesign UX - Sezione "Scopri"

**Data**: 2026-02-08
**Autore**: Claude + Michele
**Stato**: Da approvare
**Effort totale stimato**: M-L (2-3 giorni)

---

## 📋 Executive Summary

La sezione "Scopri" attualmente ha **5 livelli di navigazione sovrapposti** che creano confusione anche per il creatore dell'app. Questo piano propone una semplificazione radicale basata su:

1. **Evidenze UX** da ricerche Nielsen Norman Group, Netflix, e best practices fitness app 2025-2026
2. **Analisi Personas** (Marco, Chiara, Luca, Sofia, Roberto)
3. **Principio "One action per screen"** - ridurre cognitive load

### Problema Attuale (Screenshot)

```
┌─────────────────────────────────────────────────────────────────┐
│ LIVELLO 1: Header + Metriche (4, 0, 30 - criptici)              │
├─────────────────────────────────────────────────────────────────┤
│ LIVELLO 2: TAB BAR (Le Mie Schede | Esercizi | Scopri)          │
├─────────────────────────────────────────────────────────────────┤
│ LIVELLO 3: TOGGLE (Schede Allenamento ↔ Tecniche Avanzate)      │
├─────────────────────────────────────────────────────────────────┤
│ LIVELLO 4: FILTRI (Vedi tutti | Forza | Cardio | Flessibilità)  │
├─────────────────────────────────────────────────────────────────┤
│ LIVELLO 5: SEZIONI (Avanzate | Casa | Solo Manubri...)          │
├─────────────────────────────────────────────────────────────────┤
│ LIVELLO 6: Card orizzontali piccole (180x120px) → illeggibili   │
└─────────────────────────────────────────────────────────────────┘
```

### Soluzione Proposta

```
┌─────────────────────────────────────────────────────────────────┐
│ Header semplificato                                             │
├─────────────────────────────────────────────────────────────────┤
│ TAB BAR (Le Mie Schede | Esercizi | Scopri)                     │
├─────────────────────────────────────────────────────────────────┤
│ FILTRI INTELLIGENTI (⏱ Durata | 💪 Tipo | 🎯 Livello)           │
├─────────────────────────────────────────────────────────────────┤
│ "🎯 Per Te" - 3 template raccomandati (sezione hero)            │
├─────────────────────────────────────────────────────────────────┤
│ Lista verticale con CARD GRANDI (full-width, 160px height)      │
│ - Raggruppate per categoria con header collassabili             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 Evidenze UX (Fonti)

### 1. Nielsen Norman Group - Cards vs Lists

> "Lists are preferred when users need to quickly search for something... Lists that are vertical help focus the user's eyes much better than cards, as lists are fixed."

**Applicazione**: Le card orizzontali piccole (180px) forzano scroll orizzontale che nasconde contenuto. Passare a **lista verticale full-width**.

**Fonte**: [NN/G Cards Component](https://www.nngroup.com/articles/cards-component/)

### 2. Netflix Thumbnail Research

> "Netflix has tested larger thumbnails extensively against smaller thumbnail sizes with text and found that users prefer larger thumbnails."

**Applicazione**: Card più grandi (160px height) con visual hierarchy chiara.

**Fonte**: [UX Movement - List vs Grid](https://uxmovement.com/mobile/list-vs-grid-view-when-to-use-which-on-mobile/)

### 3. Fitness App Best Practices 2025

> "Users should be able to set up their profile and start their first workout within 60 seconds. Apps that simplify onboarding can increase retention by 50%."

> "Focus on one action per screen – one button, one decision, one goal."

> "Declutter navigation and save the bells and whistles for later. Only keep essentials."

**Applicazione**:
- Rimuovere toggle "Schede/Tecniche Avanzate"
- Filtro per DURATA come priorità (Chiara's need)
- Sezione "Per te" per ridurre decision fatigue

**Fonte**: [Dataconomy - Fitness App UX 2025](https://dataconomy.com/2025/11/11/best-ux-ui-practices-for-fitness-apps-retaining-and-re-engaging-users/)

### 4. Card Design Best Practices

> "Card format enables you to display long text in a much more readable format... Large text, images, and conditional color coding are more appropriate in card format."

**Applicazione**: Card con gradiente per categoria, badge livello prominente, info leggibili.

**Fonte**: [UX Collective - 8 Best Practices for Card Design](https://uxdesign.cc/8-best-practices-for-ui-card-design-898f45bb60cc)

### 5. Cognitive Load Research

> "70% of fitness app users drop off within the first 90 days. The reason isn't a lack of motivation—it's bad UX."

**Applicazione**: Ridurre livelli navigazione da 5 a 2.

**Fonte**: [Stormotion - Fitness App UX](https://stormotion.io/blog/fitness-app-ux/)

---

## 👥 Persona Impact Analysis

### Stato Attuale - Impatto Negativo

| Persona | Impatto | Problema Principale |
|---------|---------|---------------------|
| Marco   | `--`    | Troppi livelli, terminologia confusa |
| Chiara  | `-`     | Non può filtrare per durata (suo criterio #1) |
| Luca    | `0`     | Toggle nasconde tecniche avanzate |
| Sofia   | `-`     | Card monotone, nessun appeal visivo |
| Roberto | `-`     | Troppi tap per trovare workout |

**Decisione attuale**: ❌ BLOCCA - Marco (persona primaria per discovery) ha `--`

### Dopo Redesign - Impatto Previsto

| Persona | Impatto | Beneficio |
|---------|---------|-----------|
| Marco   | `++`    | "Per te" lo guida, meno scelte |
| Chiara  | `++`    | Filtro durata prominente |
| Luca    | `+`     | Tecniche avanzate integrate con tag |
| Sofia   | `+`     | Card con colori categoria, badge |
| Roberto | `++`    | 2 tap max per iniziare workout |

**Decisione**: ✅ PROCEDI - Tutti beneficiati

---

## 🏗️ Piano di Implementazione

### FASE 1: Semplificazione Strutturale
**Effort**: S | **Rischio**: Basso | **File**: `templates_home_screen.dart`

#### Task 1.1: Rimuovere Toggle "Schede/Tecniche Avanzate"

**File**: `lib/features/workout_templates/presentation/screens/templates_home_screen.dart`
**Linee**: 886-921 (SegmentedButton)

**Cosa fare**:
1. Rimuovere la variabile `_discoverSubTabIndex` (linea 119)
2. Rimuovere il `SegmentedButton<int>` (linee 886-921)
3. Integrare "Tecniche Avanzate" come sezione in fondo alla lista

**Codice da rimuovere**:
```dart
// RIMUOVERE: linea 119
int _discoverSubTabIndex = 0;

// RIMUOVERE: linee 886-921 (tutto il SliverToBoxAdapter con SegmentedButton)
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(...),
    child: SegmentedButton<int>(
      // ... tutto questo blocco
    ),
  ),
),
```

**Verifica**:
- [ ] La sezione Scopri mostra direttamente i template senza toggle
- [ ] Le tecniche avanzate appaiono come sezione in fondo

---

#### Task 1.2: Riordinare Sezioni per Livello Utente

**File**: `templates_home_screen.dart`
**Linee**: 982-991 (`orderedCategories`)

**Cambio ordine da**:
```dart
final orderedCategories = [
  'beginner',
  'intermediate',
  'advanced',
  'home',
  'dumbbell',
  'express',
  'specialty',
];
```

**Cambio ordine a** (UX-driven - principianti prima, intimidatori dopo):
```dart
final orderedCategories = [
  'express',      // ⚡ Quick wins per tutti
  'beginner',     // 🌱 Non intimidatorio
  'home',         // 🏠 Accessibile
  'dumbbell',     // 💪 Equipaggiamento minimo
  'intermediate', // 📈 Crescita
  'specialty',    // ⭐ Nicchie
  'advanced',     // 🔥 Ultimo - per chi cerca sfida
];
```

**Verifica**:
- [ ] "Express" appare per primo
- [ ] "Advanced" appare per ultimo

---

#### Task 1.3: Aggiungere Labels ai Numeri Header

**File**: `templates_home_screen.dart`
**Linee**: 318-366 (metric cards)

**Problema**: I numeri 4, 0, 30 sono criptici senza labels visibili permanenti.

**Soluzione**: Forzare labels sempre visibili (rimuovere auto-minimize o renderle sempre leggibili)

**Codice attuale** (linea 476-490):
```dart
if (labelOpacity > 0.01) ...[
  const SizedBox(height: AppSpacing.xs),
  Opacity(
    opacity: labelOpacity,
    child: Text(label, ...),
  ),
],
```

**Nuovo codice**:
```dart
// Labels sempre visibili con opacity minima 0.7
const SizedBox(height: AppSpacing.xs),
Opacity(
  opacity: labelOpacity.clamp(0.7, 1.0), // Min 0.7, mai invisibile
  child: Text(label, ...),
),
```

**Verifica**:
- [ ] Labels sempre leggibili anche quando minimizzato

---

### FASE 2: Nuovo Sistema di Filtri
**Effort**: M | **Rischio**: Medio | **File**: Nuovo widget + screen

#### Task 2.1: Creare `DiscoverFilterBar` Widget

**Nuovo file**: `lib/features/workout_templates/presentation/widgets/discover_filter_bar.dart`

```dart
/// Smart filter bar for Discover tab
///
/// Primary filters (always visible):
/// - Duration: Quick (<25'), Medium (25-45'), Long (45'+)
/// - Type: All | Strength | Cardio | Flexibility | Hybrid
///
/// Secondary filters (expandable):
/// - Level: Beginner | Intermediate | Advanced
/// - Equipment: None | Dumbbells | Full Gym
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Duration filter options
enum DurationFilter {
  all,      // Tutti
  quick,    // <25 min
  medium,   // 25-45 min
  long,     // >45 min
}

/// Category filter options (existing)
enum CategoryFilter {
  all,
  strength,
  cardio,
  flexibility,
  hybrid,
}

class DiscoverFilterBar extends StatelessWidget {
  const DiscoverFilterBar({
    super.key,
    required this.selectedDuration,
    required this.selectedCategory,
    required this.onDurationChanged,
    required this.onCategoryChanged,
  });

  final DurationFilter selectedDuration;
  final CategoryFilter selectedCategory;
  final ValueChanged<DurationFilter> onDurationChanged;
  final ValueChanged<CategoryFilter> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ROW 1: Duration chips (PRIMARY - most important for Chiara)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              _FilterChip(
                icon: AppIcons.timerOff,
                label: l10n.all,
                isSelected: selectedDuration == DurationFilter.all,
                onTap: () => onDurationChanged(DurationFilter.all),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                icon: AppIcons.bolt,
                label: '< 25\'', // Quick
                isSelected: selectedDuration == DurationFilter.quick,
                onTap: () => onDurationChanged(DurationFilter.quick),
                accentColor: context.colors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                icon: AppIcons.timer,
                label: '25-45\'', // Medium
                isSelected: selectedDuration == DurationFilter.medium,
                onTap: () => onDurationChanged(DurationFilter.medium),
                accentColor: context.colors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                icon: AppIcons.hourglass,
                label: '> 45\'', // Long
                isSelected: selectedDuration == DurationFilter.long,
                onTap: () => onDurationChanged(DurationFilter.long),
                accentColor: context.colors.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ROW 2: Category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              _FilterChip(
                icon: AppIcons.gridView,
                label: l10n.all,
                isSelected: selectedCategory == CategoryFilter.all,
                onTap: () => onCategoryChanged(CategoryFilter.all),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                icon: AppIcons.workout,
                label: l10n.strength,
                isSelected: selectedCategory == CategoryFilter.strength,
                onTap: () => onCategoryChanged(CategoryFilter.strength),
                accentColor: context.colors.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                icon: AppIcons.directionsRun,
                label: l10n.cardio,
                isSelected: selectedCategory == CategoryFilter.cardio,
                onTap: () => onCategoryChanged(CategoryFilter.cardio),
                accentColor: context.colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                icon: AppIcons.flexibility,
                label: l10n.flexibility,
                isSelected: selectedCategory == CategoryFilter.flexibility,
                onTap: () => onCategoryChanged(CategoryFilter.flexibility),
                accentColor: context.colors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                icon: AppIcons.fitnessCenter,
                label: l10n.hybrid,
                isSelected: selectedCategory == CategoryFilter.hybrid,
                onTap: () => onCategoryChanged(CategoryFilter.hybrid),
                accentColor: context.colors.tertiary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? context.colors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.small,
              color: isSelected ? color : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : context.colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Verifica**:
- [ ] Filtri durata appaiono per primi (priorità Chiara)
- [ ] Haptic feedback su selezione
- [ ] Colori categoria coerenti

---

#### Task 2.2: Aggiungere State Management per Filtri

**File**: `lib/features/workout_templates/presentation/providers/discover_filter_provider.dart`

```dart
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/discover_filter_bar.dart';

part 'discover_filter_provider.g.dart';

@riverpod
class DiscoverFilters extends _$DiscoverFilters {
  @override
  ({DurationFilter duration, CategoryFilter category}) build() {
    return (duration: DurationFilter.all, category: CategoryFilter.all);
  }

  void setDuration(DurationFilter filter) {
    state = (duration: filter, category: state.category);
  }

  void setCategory(CategoryFilter filter) {
    state = (duration: state.duration, category: filter);
  }

  void reset() {
    state = (duration: DurationFilter.all, category: CategoryFilter.all);
  }
}

/// Filtered templates provider
@riverpod
List<WorkoutTemplate> filteredDiscoverTemplates(
  FilteredDiscoverTemplatesRef ref,
  List<WorkoutTemplate> templates,
) {
  final filters = ref.watch(discoverFiltersProvider);

  return templates.where((t) {
    // Duration filter
    if (filters.duration != DurationFilter.all) {
      final duration = t.estimatedDuration;
      switch (filters.duration) {
        case DurationFilter.quick:
          if (duration >= 25) return false;
        case DurationFilter.medium:
          if (duration < 25 || duration > 45) return false;
        case DurationFilter.long:
          if (duration <= 45) return false;
        case DurationFilter.all:
          break;
      }
    }

    // Category filter
    if (filters.category != CategoryFilter.all) {
      final category = t.effectiveCategory;
      switch (filters.category) {
        case CategoryFilter.strength:
          if (category != TemplateCategory.strength) return false;
        case CategoryFilter.cardio:
          if (category != TemplateCategory.cardio) return false;
        case CategoryFilter.flexibility:
          if (category != TemplateCategory.flexibility) return false;
        case CategoryFilter.hybrid:
          if (category != TemplateCategory.hybrid) return false;
        case CategoryFilter.all:
          break;
      }
    }

    return true;
  }).toList();
}
```

**Dopo creazione**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Verifica**:
- [ ] Provider generato correttamente
- [ ] Filtri persistono durante sessione

---

### FASE 3: Sezione "Per Te" (Smart Recommendations)
**Effort**: M | **Rischio**: Medio | **File**: Nuovo widget

#### Task 3.1: Creare `ForYouSection` Widget

**Nuovo file**: `lib/features/workout_templates/presentation/widgets/for_you_section.dart`

```dart
/// "Per Te" hero section - Smart template recommendations
///
/// Logic:
/// 1. Se UserTier == starter → mostra 3 template beginner
/// 2. Se ha cronologia → mostra template simili a quelli usati
/// 3. Altrimenti → mostra mix di express + home (accessibili)
///
/// UX: Sezione hero prominente per ridurre decision fatigue (Marco)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';

class ForYouSection extends ConsumerWidget {
  const ForYouSection({
    super.key,
    required this.allTemplates,
    required this.onTemplateUse,
    required this.onTemplatePreview,
  });

  final List<WorkoutTemplate> allTemplates;
  final void Function(WorkoutTemplate) onTemplateUse;
  final void Function(WorkoutTemplate) onTemplatePreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userTier = ref.watch(userTierProvider);

    // Get recommended templates based on user tier
    final recommendations = _getRecommendations(userTier, allTemplates);

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary,
                      context.colors.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  AppIcons.autoAwesome,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.forYou, // "Per te"
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.recommendedForYourLevel, // "Consigliati per il tuo livello"
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Horizontal scroll of recommended cards (max 3)
        SizedBox(
          height: 180, // Taller than before
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final template = recommendations[index];
              return _ForYouCard(
                template: template,
                onUse: () => onTemplateUse(template),
                onPreview: () => onTemplatePreview(template),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  List<WorkoutTemplate> _getRecommendations(
    UserTier tier,
    List<WorkoutTemplate> templates,
  ) {
    // Starter tier → Beginner templates only
    if (tier == UserTier.starter) {
      return templates
          .where((t) => t.category == 'beginner' || t.category == 'express')
          .take(3)
          .toList();
    }

    // Bronze/Silver → Mix of home + intermediate
    if (tier == UserTier.bronze || tier == UserTier.silver) {
      return templates
          .where((t) => ['home', 'express', 'intermediate'].contains(t.category))
          .take(3)
          .toList();
    }

    // Gold/Platinum → Show more challenging options
    return templates
        .where((t) => ['intermediate', 'advanced', 'specialty'].contains(t.category))
        .take(3)
        .toList();
  }
}

class _ForYouCard extends StatelessWidget {
  const _ForYouCard({
    required this.template,
    required this.onUse,
    required this.onPreview,
  });

  final WorkoutTemplate template;
  final VoidCallback onUse;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = template.effectiveCategory;
    final color = category.color(context);

    return GestureDetector(
      onTap: onPreview,
      child: Container(
        width: 280, // Wider card
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.surface,
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Watermark icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                category.icon,
                size: 80,
                color: color.withValues(alpha: 0.08),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          category.localizedName(context),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Template name
                  Text(
                    template.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Stats row
                  Row(
                    children: [
                      Icon(
                        AppIcons.workout,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.exercises.length} ${l10n.exercises}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        AppIcons.timer,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.estimatedDuration}\'',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Use button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onUse,
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        l10n.startWorkout,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Localizzazioni da aggiungere** (`app_en.arb` / `app_it.arb`):
```json
"forYou": "For You",
"forYouIt": "Per te",
"recommendedForYourLevel": "Recommended for your level",
"recommendedForYourLevelIt": "Consigliati per il tuo livello"
```

**Verifica**:
- [ ] Sezione appare in cima al Discover tab
- [ ] Mostra template appropriati per tier utente
- [ ] Card più grandi e leggibili

---

### FASE 4: Card Verticali Grandi (List View)
**Effort**: M | **Rischio**: Medio | **File**: Nuovo widget

#### Task 4.1: Creare `DiscoverTemplateCard` (Full-Width)

**Nuovo file**: `lib/features/workout_templates/presentation/widgets/cards/discover_template_card.dart`

```dart
/// Full-width template card for Discover vertical list
///
/// Replaces horizontal scroll of small 180x120 cards with
/// vertical list of large, readable cards.
///
/// Design:
/// - Full width with 16px margin
/// - 160px fixed height
/// - Left color strip by category
/// - Clear visual hierarchy: Name → Stats → CTA
/// - Difficulty badge prominent
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/difficulty_level.dart';

class DiscoverTemplateCard extends StatefulWidget {
  const DiscoverTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onUse,
  });

  final WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback onUse;

  @override
  State<DiscoverTemplateCard> createState() => _DiscoverTemplateCardState();
}

class _DiscoverTemplateCardState extends State<DiscoverTemplateCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = widget.template.effectiveCategory;
    final difficulty = widget.template.effectiveDifficulty;
    final color = category.color(context);
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: 160,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.surface,
                color.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(
                  alpha: isDark ? 0.2 : 0.08,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Watermark icon
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  category.icon,
                  size: 100,
                  color: color.withValues(alpha: 0.06),
                ),
              ),

              // Left accent strip
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isPressed ? 5 : 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.9),
                        color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, // Extra left padding for strip
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // Left: Template info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row: Category badge + Difficulty badge
                          Row(
                            children: [
                              // Category chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      category.icon,
                                      size: 12,
                                      color: color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      category.localizedName(context),
                                      style: context.textTheme.labelSmall?.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: AppSpacing.sm),

                              // Difficulty badge
                              _DifficultyBadge(difficulty: difficulty),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Template name (larger, bolder)
                          Text(
                            widget.template.name,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const Spacer(),

                          // Stats row
                          Row(
                            children: [
                              Icon(
                                AppIcons.workout,
                                size: AppIconSize.small,
                                color: context.colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.template.exercises.length}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Icon(
                                AppIcons.timer,
                                size: AppIconSize.small,
                                color: context.colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.template.estimatedDuration}\'',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right: CTA button (vertical)
                    const SizedBox(width: AppSpacing.md),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Use button
                        FilledButton(
                          onPressed: widget.onUse,
                          style: FilledButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          child: Text(
                            l10n.use,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        // Preview link
                        TextButton(
                          onPressed: widget.onTap,
                          child: Text(
                            l10n.preview,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final DifficultyLevel difficulty;

  @override
  Widget build(BuildContext context) {
    final color = difficulty.color(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        difficulty.localizedName(context),
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

**Verifica**:
- [ ] Card full-width, 160px height
- [ ] Testo leggibile
- [ ] CTA "Usa" prominente
- [ ] Preview accessibile

---

#### Task 4.2: Sostituire ListView Orizzontale con Verticale

**File**: `templates_home_screen.dart`
**Linee**: 1052-1077

**Da sostituire**:
```dart
// VECCHIO: Scroll orizzontale con card piccole
SizedBox(
  height: 120,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: categoryTemplates.length,
    ...
    itemBuilder: (context, i) {
      return CompactTemplateCard(
        template: categoryTemplates[i],
        ...
      );
    },
  ),
),
```

**Con**:
```dart
// NUOVO: Lista verticale con card grandi
...categoryTemplates.map((template) =>
  DiscoverTemplateCard(
    template: template,
    onTap: () => _previewDefaultTemplate(context, template),
    onUse: () => _useDefaultTemplate(context, template),
  ),
).toList(),
```

**Verifica**:
- [ ] Nessuno scroll orizzontale
- [ ] Card occupano full width
- [ ] Scroll verticale fluido

---

### FASE 5: Integrazione e Polish
**Effort**: S | **Rischio**: Basso

#### Task 5.1: Aggiornare `_buildDiscoverTab` completo

**File**: `templates_home_screen.dart`

Sostituire l'intero metodo `_buildDiscoverTab` con la nuova implementazione che usa:
1. `DiscoverFilterBar`
2. `ForYouSection`
3. `DiscoverTemplateCard` in lista verticale
4. Sezioni raggruppate con header collassabili

#### Task 5.2: Aggiungere Localizzazioni Mancanti

**File**: `lib/shared/presentation/l10n/app_en.arb`
```json
"forYou": "For You",
"recommendedForYourLevel": "Recommended for your level",
"startWorkout": "Start Workout",
"preview": "Preview",
"quickWorkouts": "Quick Workouts",
"underMinutes": "Under {minutes} minutes",
"@underMinutes": {
  "placeholders": {
    "minutes": {"type": "int"}
  }
}
```

**File**: `lib/shared/presentation/l10n/app_it.arb`
```json
"forYou": "Per te",
"recommendedForYourLevel": "Consigliati per il tuo livello",
"startWorkout": "Inizia Allenamento",
"preview": "Anteprima",
"quickWorkouts": "Allenamenti Rapidi",
"underMinutes": "Sotto {minutes} minuti"
```

**Dopo modifica**:
```bash
flutter gen-l10n
```

#### Task 5.3: Verifiche Finali

```bash
# Analisi statica
flutter analyze

# Build test iOS
flutter build ios --debug

# Test
flutter test
```

---

## 📊 Metriche di Successo

| Metrica | Prima | Dopo | Target |
|---------|-------|------|--------|
| Livelli navigazione | 5 | 2 | ✅ |
| Tap per iniziare workout | 4+ | 2 | ✅ |
| Card height | 120px | 160px | ✅ |
| Filtro durata | ❌ | ✅ | ✅ |
| Sezione "Per te" | ❌ | ✅ | ✅ |
| Toggle confusi | 1 | 0 | ✅ |

---

## 🔗 File da Creare (Riepilogo)

| # | File | Effort |
|---|------|--------|
| 1 | `widgets/discover_filter_bar.dart` | M |
| 2 | `providers/discover_filter_provider.dart` | S |
| 3 | `widgets/for_you_section.dart` | M |
| 4 | `widgets/cards/discover_template_card.dart` | M |

**File da modificare**:
| File | Modifiche |
|------|-----------|
| `templates_home_screen.dart` | Rimuovere toggle, riordinare, integrare nuovi widget |
| `app_en.arb` / `app_it.arb` | Aggiungere localizzazioni |

---

## ✅ Checklist Pre-Implementazione

- [ ] Conferma design con utente
- [ ] Verifica che DifficultyLevel e TemplateCategory abbiano metodi `color()` e `icon`
- [ ] Backup del file `templates_home_screen.dart` attuale
- [ ] Creazione branch `feature/discover-ux-redesign`

---

## 📚 Fonti Citate

- [Dataconomy - Fitness App UX 2025](https://dataconomy.com/2025/11/11/best-ux-ui-practices-for-fitness-apps-retaining-and-re-engaging-users/)
- [NN/G - Cards Component](https://www.nngroup.com/articles/cards-component/)
- [UX Movement - List vs Grid](https://uxmovement.com/mobile/list-vs-grid-view-when-to-use-which-on-mobile/)
- [Stormotion - Fitness App UX](https://stormotion.io/blog/fitness-app-ux/)
- [UX Collective - Card Design Best Practices](https://uxdesign.cc/8-best-practices-for-ui-card-design-898f45bb60cc)
