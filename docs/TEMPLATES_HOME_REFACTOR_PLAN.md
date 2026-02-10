# Documento d'Implementazione: Refactoring templates_home_screen.dart

**Data**: 2026-02-08
**File Target**: `lib/features/workout_templates/presentation/screens/templates_home_screen.dart`
**Stato Attuale**: 5537 righe, 22 classi
**Obiettivo**: ~300 righe orchestratore + moduli estratti

---

## Executive Summary

Il file `templates_home_screen.dart` viola massivamente il Single Responsibility Principle con 22 classi e 50+ metodi. Questo documento descrive l'estrazione in 15 file modulari seguendo i pattern già presenti nel progetto (vedi `pro_analytics_tabbed_screen.dart`).

---

## FASE 1: Creazione Struttura Directory

### Task 1.1: Creare le directory

```bash
mkdir -p lib/features/workout_templates/presentation/tabs
mkdir -p lib/features/workout_templates/presentation/controllers
mkdir -p lib/features/workout_templates/presentation/widgets/cards
mkdir -p lib/features/workout_templates/presentation/widgets/sheets
mkdir -p lib/features/workout_templates/presentation/widgets/common
```

---

## FASE 2: Estrazione Widget Comuni (Rischio: BASSO)

### Task 2.1: `widgets/common/stat_chip.dart`

**Estrai da**: linee 5502-5537

```dart
/// Small stat chip for preview sheets
///
/// Usage:
/// ```dart
/// StatChip(
///   icon: AppIcons.timer,
///   label: '30s',
///   color: context.colors.primary,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### Task 2.2: `widgets/common/empty_templates_state.dart`

**Estrai da**: linee 2890-2944

```dart
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class EmptyTemplatesState extends StatelessWidget {
  const EmptyTemplatesState({super.key, required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: SemanticIcon(
              icon: AppIcons.workout,
              semanticLabel: l10n.workout,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.noTemplatesYet,
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.createFirstTemplate,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onCreateTap,
            icon: SemanticIcon(
              icon: AppIcons.add,
              semanticLabel: l10n.createTemplate,
            ),
            label: Text(l10n.createTemplate),
          ),
        ],
      ),
    );
  }
}
```

---

### Task 2.3: `widgets/common/difficulty_badge.dart`

**Estrai da**: linee 4132-4157

```dart
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({
    super.key,
    required this.difficulty,
  });

  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final color = _getDifficultyColor(context, difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getDifficultyColor(BuildContext context, String difficulty) {
    final lowerDifficulty = difficulty.toLowerCase();
    if (lowerDifficulty.contains('easy') || lowerDifficulty.contains('facile')) {
      return context.colors.success;
    } else if (lowerDifficulty.contains('medium') || lowerDifficulty.contains('medio')) {
      return context.colors.warning;
    } else if (lowerDifficulty.contains('hard') || lowerDifficulty.contains('difficile')) {
      return context.colors.error;
    }
    return context.colors.primary;
  }
}
```

---

## FASE 3: Controller con State Management (Rischio: BASSO)

### Task 3.1: `controllers/templates_home_controller.dart`

```dart
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'templates_home_controller.freezed.dart';
part 'templates_home_controller.g.dart';

@freezed
class TemplatesHomeState with _$TemplatesHomeState {
  const factory TemplatesHomeState({
    @Default(true) bool isGridView,
    @Default(false) bool isMetricsMinimized,
    @Default(false) bool isSaving,
    @Default(false) bool isSupersetsExpanded,
    @Default(false) bool isDropsetsExpanded,
    @Default(false) bool isRestPauseExpanded,
    @Default(null) String? selectedCategory,
    @Default(0) int discoverSubTabIndex,
  }) = _TemplatesHomeState;
}

@riverpod
class TemplatesHomeController extends _$TemplatesHomeController {
  @override
  TemplatesHomeState build() => const TemplatesHomeState();

  void toggleGridView() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void setMetricsMinimized(bool minimized) {
    state = state.copyWith(isMetricsMinimized: minimized);
  }

  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving);
  }

  void toggleSupersetsExpanded() {
    state = state.copyWith(isSupersetsExpanded: !state.isSupersetsExpanded);
  }

  void toggleDropsetsExpanded() {
    state = state.copyWith(isDropsetsExpanded: !state.isDropsetsExpanded);
  }

  void toggleRestPauseExpanded() {
    state = state.copyWith(isRestPauseExpanded: !state.isRestPauseExpanded);
  }

  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setDiscoverSubTabIndex(int index) {
    state = state.copyWith(discoverSubTabIndex: index);
  }
}
```

**Dopo creazione, eseguire**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## FASE 4: Estrazione Card Widgets (Rischio: MEDIO)

### Task 4.1: `widgets/cards/compact_template_card.dart`

**Estrai da**: linee 3662-3832 (classe `_CompactTemplateCard`)

**Signature**:
```dart
class CompactTemplateCard extends StatelessWidget {
  const CompactTemplateCard({
    super.key,
    required this.template,
    required this.stats,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onShare,
    required this.onMakePublic,
  });

  final WorkoutTemplate template;
  final TemplateStats? stats;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onShare;
  final VoidCallback onMakePublic;

  // ... build method from original
}
```

### Task 4.2: `widgets/cards/compact_superset_card.dart`

**Estrai da**: linee 3835-3932 (classe `_CompactSupersetCard`)

### Task 4.3: `widgets/cards/compact_dropset_card.dart`

**Estrai da**: linee 3934-4031 (classe `_CompactDropsetCard`)

### Task 4.4: `widgets/cards/compact_rest_pause_card.dart`

**Estrai da**: linee 4033-4130 (classe `_CompactRestPauseCard`)

### Task 4.5: `widgets/cards/workout_template_card.dart`

**Estrai da**: linee 3296-3660 (classe `_WorkoutTemplateCard`)

**Nota**: Questo è un `ConsumerWidget`, mantenerlo così.

---

## FASE 5: Estrazione Preview Sheets (Rischio: MEDIO)

### Task 5.1: `widgets/sheets/template_preview_sheet.dart`

**Estrai da**: linee 4265-4492 (classe `_DefaultTemplatePreviewSheet`)

```dart
class TemplatePreviewSheet extends StatelessWidget {
  const TemplatePreviewSheet({
    super.key,
    required this.template,
    required this.onUse,
  });

  final DefaultTemplate template;
  final VoidCallback onUse;

  // ... build method
}
```

### Task 5.2: `widgets/sheets/superset_preview_sheet.dart`

**Estrai da**: linee 4853-5068 (classe `_PredefinedSupersetPreviewSheet`)

### Task 5.3: `widgets/sheets/dropset_preview_sheet.dart`

**Estrai da**: linee 5070-5285 (classe `_PredefinedDropsetPreviewSheet`)

### Task 5.4: `widgets/sheets/rest_pause_preview_sheet.dart`

**Estrai da**: linee 5287-5500 (classe `_PredefinedRestPausePreviewSheet`)

---

## FASE 6: Estrazione Tabs (Rischio: ALTO)

### Task 6.1: `tabs/my_templates_tab.dart`

**Estrai**:
- `_buildMyTemplatesTab()` (linea 499)
- `_buildMyTemplatesGrid()` (linea 546)
- `_buildMyTemplatesList()` (linea 581)
- Callback methods: `_openWorkoutTemplate`, `_editWorkoutTemplate`, `_deleteWorkoutTemplate`, `_duplicateTemplate`, `_shareTemplate`, `_makeTemplatePublic`

**Struttura**:
```dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ... altri import

class MyTemplatesTab extends ConsumerWidget {
  const MyTemplatesTab({
    super.key,
    required this.isGridView,
    required this.onToggleView,
    required this.onCreateTemplate,
  });

  final bool isGridView;
  final VoidCallback onToggleView;
  final VoidCallback onCreateTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);
    final statsAsync = ref.watch(allTemplateStatsProvider);
    final l10n = AppLocalizations.of(context);

    return templatesAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (templates) {
        if (templates.isEmpty) {
          return EmptyTemplatesState(onCreateTap: onCreateTemplate);
        }

        return Column(
          children: [
            // Quota indicator + view toggle
            _buildHeader(context, ref, templates.length),
            // Grid or list
            Expanded(
              child: isGridView
                  ? _buildGrid(context, ref, templates, statsAsync)
                  : _buildList(context, ref, templates, statsAsync),
            ),
          ],
        );
      },
    );
  }

  // ... metodi privati per grid/list

  // Business logic delegata a metodi helper o callback
  Future<void> _deleteTemplate(BuildContext context, WidgetRef ref, String id) async {
    // Conferma + delete via provider
  }

  Future<void> _shareTemplate(BuildContext context, WidgetRef ref, WorkoutTemplate template) async {
    // PDF generation + share
  }
}
```

---

### Task 6.2: `tabs/advanced_templates_tab.dart`

**Estrai**:
- `_buildAdvancedTemplatesTab()` (linea 2173)
- `_buildTemplateSection<T>()` (linea 2327)
- CRUD methods per exercises, supersets, dropsets, rest-pause

**Struttura**:
```dart
class AdvancedTemplatesTab extends ConsumerWidget {
  const AdvancedTemplatesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(templatesHomeControllerProvider);

    return CustomScrollView(
      slivers: [
        // Section: Custom Exercises
        _buildSection<CustomExercise>(
          context: context,
          ref: ref,
          title: context.l10n.myExercises,
          // ...
        ),
        // Section: Supersets
        _buildSection<SupersetTemplate>(...),
        // Section: Dropsets
        _buildSection<DropsetTemplate>(...),
        // Section: Rest-Pause
        _buildSection<RestPauseTemplate>(...),
      ],
    );
  }
}
```

---

### Task 6.3: `tabs/discover_tab.dart`

**Estrai**:
- `_buildDiscoverTab()` (linea 1027)
- Sub-tab logic per Workout Templates vs Advanced Techniques
- Preview/Use methods per template predefiniti

**Struttura**:
```dart
class DiscoverTab extends ConsumerStatefulWidget {
  const DiscoverTab({super.key});

  @override
  ConsumerState<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<DiscoverTab> {
  int _subTabIndex = 0;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tab toggle
        _buildSubTabSelector(),
        // Content
        Expanded(
          child: _subTabIndex == 0
              ? _buildWorkoutTemplates()
              : _buildAdvancedTechniques(),
        ),
      ],
    );
  }
}
```

---

## FASE 7: Semplificazione Screen Principale (Rischio: ALTO)

### Task 7.1: Refactor `templates_home_screen.dart`

**Target**: ~300 righe

```dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ... import tabs, controllers, widgets

class TemplatesHomeScreen extends ConsumerStatefulWidget {
  const TemplatesHomeScreen({super.key, this.showTour = false});
  final bool showTour;

  @override
  ConsumerState<TemplatesHomeScreen> createState() => _TemplatesHomeScreenState();
}

class _TemplatesHomeScreenState extends ConsumerState<TemplatesHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _minimizeController;
  late Animation<double> _minimizeAnimation;

  // Tour keys
  final _myTemplatesTabKey = GlobalKey();
  final _discoverTabKey = GlobalKey();
  final _createButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupAnimations();
    _startTourIfRequested();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _minimizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templatesHomeControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(l10n),
          _buildAnimatedMetricsHeader(state),
          _buildSliverTabBar(l10n),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            MyTemplatesTab(
              key: _myTemplatesTabKey,
              isGridView: state.isGridView,
              onToggleView: () => ref
                  .read(templatesHomeControllerProvider.notifier)
                  .toggleGridView(),
              onCreateTemplate: () => _createNewTemplate(context),
            ),
            const AdvancedTemplatesTab(),
            DiscoverTab(key: _discoverTabKey),
          ],
        ),
      ),
      floatingActionButton: DraggableActionButton(
        key: _createButtonKey,
        onPressed: () => _createNewTemplate(context),
        icon: AppIcons.add,
        label: l10n.newTemplate,
      ),
    );
  }

  // Metodi helper per AppBar, Metrics Header, TabBar
  // ...

  void _createNewTemplate(BuildContext context) {
    // Navigate to create screen
  }
}
```

---

## FASE 8: Cleanup e Test

### Task 8.1: Rimuovere codice morto

Dopo le estrazioni, verificare che non rimangano:
- Import non utilizzati
- Classi private non referenziate
- Metodi orfani

### Task 8.2: Aggiornare import

Creare barrel file `widgets/widgets.dart`:
```dart
export 'cards/compact_template_card.dart';
export 'cards/compact_superset_card.dart';
export 'cards/compact_dropset_card.dart';
export 'cards/compact_rest_pause_card.dart';
export 'cards/workout_template_card.dart';
export 'sheets/template_preview_sheet.dart';
export 'sheets/superset_preview_sheet.dart';
export 'sheets/dropset_preview_sheet.dart';
export 'sheets/rest_pause_preview_sheet.dart';
export 'common/stat_chip.dart';
export 'common/empty_templates_state.dart';
export 'common/difficulty_badge.dart';
```

### Task 8.3: Verifiche

```bash
# 1. Analisi statica
flutter analyze

# 2. Build test
flutter build ios --debug

# 3. Generazione codice (se usato Freezed)
dart run build_runner build --delete-conflicting-outputs

# 4. Test esistenti
flutter test
```

---

## Checklist di Verifica Funzionale

Dopo ogni fase, testare:

| Feature | Test |
|---------|------|
| Tab navigation | Swipe tra 3 tab |
| My Templates - Grid | Toggle vista griglia |
| My Templates - List | Toggle vista lista |
| My Templates - CRUD | Crea, modifica, elimina template |
| My Templates - Share | Condividi PDF |
| My Templates - Duplicate | Duplica template |
| Advanced - Exercises | CRUD custom exercises |
| Advanced - Supersets | CRUD superset templates |
| Advanced - Dropsets | CRUD dropset templates |
| Advanced - RestPause | CRUD rest-pause templates |
| Discover - Categories | Filtro per categoria |
| Discover - Preview | Preview template predefiniti |
| Discover - Use | Usa template predefinito |
| Tour | Guided tour se showTour=true |
| Metrics animation | Auto-minimize dopo 3s |

---

## File Creati (Riepilogo)

| # | File | Righe stimate |
|---|------|---------------|
| 1 | `controllers/templates_home_controller.dart` | ~60 |
| 2 | `widgets/common/stat_chip.dart` | ~40 |
| 3 | `widgets/common/empty_templates_state.dart` | ~60 |
| 4 | `widgets/common/difficulty_badge.dart` | ~50 |
| 5 | `widgets/cards/compact_template_card.dart` | ~180 |
| 6 | `widgets/cards/compact_superset_card.dart` | ~100 |
| 7 | `widgets/cards/compact_dropset_card.dart` | ~100 |
| 8 | `widgets/cards/compact_rest_pause_card.dart` | ~100 |
| 9 | `widgets/cards/workout_template_card.dart` | ~370 |
| 10 | `widgets/sheets/template_preview_sheet.dart` | ~230 |
| 11 | `widgets/sheets/superset_preview_sheet.dart` | ~220 |
| 12 | `widgets/sheets/dropset_preview_sheet.dart` | ~220 |
| 13 | `widgets/sheets/rest_pause_preview_sheet.dart` | ~220 |
| 14 | `tabs/my_templates_tab.dart` | ~450 |
| 15 | `tabs/advanced_templates_tab.dart` | ~400 |
| 16 | `tabs/discover_tab.dart` | ~500 |
| 17 | `screens/templates_home_screen.dart` (refactored) | ~300 |

**Totale righe**: ~3600 (vs 5537 attuali = -35% + molto più leggibile)

---

## Timeline Suggerita

| Fase | Durata | Commit |
|------|--------|--------|
| Fase 1: Directory | 5 min | - |
| Fase 2: Widget comuni | 30 min | `refactor: extract common widgets from templates_home_screen` |
| Fase 3: Controller | 20 min | `refactor: add TemplatesHomeController with Riverpod` |
| Fase 4: Card widgets | 45 min | `refactor: extract card widgets from templates_home_screen` |
| Fase 5: Preview sheets | 30 min | `refactor: extract preview sheets from templates_home_screen` |
| Fase 6: Tabs | 90 min | `refactor: extract tab widgets from templates_home_screen` |
| Fase 7: Screen principale | 60 min | `refactor: simplify templates_home_screen as orchestrator` |
| Fase 8: Cleanup | 30 min | `chore: cleanup imports and dead code` |

**Totale stimato**: ~5 ore di lavoro
