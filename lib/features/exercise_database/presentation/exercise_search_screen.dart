import 'dart:async';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/shared/domain/services/request_throttler.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart'
    hide exerciseSearchQueryProvider;
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart'
    as WorkoutExercise;
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_options_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_history_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_customization_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/missing_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/widgets/custom_exercise_form_sheet.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/providers/custom_exercise_providers.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/equipment_icon_badge.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/i_exercise_preferences.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/superset_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_template_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_template_preview_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_converter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/workout_tutorial_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
// Exercise search tutorial REMOVED - UX 2025 analysis: search UI is standard pattern

class _ExerciseSectionData {
  const _ExerciseSectionData({
    required this.title,
    required this.exercises,
    this.badge,
    this.emptyMessage,
  });

  final String title;
  final List<Exercise> exercises;
  final String? badge;
  final String? emptyMessage;
}

class ExerciseSearchScreen extends ConsumerStatefulWidget {
  // New: Just select and return exercise template (for DropSet/Rest-Pause)

  const ExerciseSearchScreen({
    super.key,
    this.onExerciseAdded,
    this.multiSelectMode = false,
    this.selectionMode = false,
    this.skipCustomizationOnContinue = false,
    this.showSupersetTemplates, // ✅ FIX: Control when to show superset templates
  });
  final Function(WorkoutExercise.Exercise)?
  onExerciseAdded; // 🔥 FIX: Add callback parameter
  final bool multiSelectMode; // New: Support multi-select for superset builder
  final bool selectionMode;
  final bool skipCustomizationOnContinue;
  final bool?
  showSupersetTemplates; // ✅ FIX: null = auto (true for multiSelect, false for single)

  @override
  ConsumerState<ExerciseSearchScreen> createState() =>
      _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends ConsumerState<ExerciseSearchScreen> {
  static const int _tutorialTargetMaxRetries = 6;
  static const String _selectionHintPrefKey =
      'exercise_search_selection_hint_dismissed';
  static const String _actionsHintPrefKey =
      'exercise_search_actions_hint_dismissed';
  final TextEditingController _searchController = TextEditingController();
  final Set<Exercise> _selectedExercises = <Exercise>{};
  bool _isHandlingFiltersTutorialAction = false;
  bool _isFilterBottomSheetOpen = false;

  // Widget keys (used for widget identification)
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _filterButtonKey = GlobalKey();
  final GlobalKey _exerciseCardKey = GlobalKey();
  final GlobalKey _addButtonKey = GlobalKey();

  String _searchQuery = '';
  final List<String> _selectedFocus = [];
  final List<String> _selectedMuscleGroups = [];
  List<String> _selectedEquipment = [];
  List<String> _selectedType = [];
  List<String> _selectedMovementPattern = [];
  bool _showOnlyCustom = false;
  bool _showOnlyRecent = false;
  bool _selectionHintDismissed = false;
  bool _actionsHintDismissed = false;
  bool _hasInteractedWithSelection = false;

  // 🔐 SECURITY: Fuzzy search state with proper debouncing
  late final Debouncer _searchDebouncer;
  List<ExerciseFuzzyResult> _fuzzyResults = [];
  bool _isSearching = false;
  bool _useFuzzyResults = false;

  // ML-enhanced state (usage tracking)
  Set<String> _frequentExerciseIds = {};
  Set<String> _trendingExerciseIds = {};

  @override
  void initState() {
    super.initState();
    // 🔐 SECURITY: Initialize search debouncer (P1-3: reduced to 200ms for faster logging)
    _searchDebouncer = Debouncer(
      duration: const Duration(milliseconds: 200),
      onError: (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('⚠️ [ExerciseSearch] Debouncer error: $error');
        }
      },
    );
    _loadUsageStats();
    _loadSavedFilters(); // Carica filtri persistiti
    _loadHintPreferences();
    // Exercise search tutorial removed - UX 2025: search UI is intuitive standard pattern
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFiltersTutorialIfNeeded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose(); // 🔐 SECURITY: Proper cleanup
    super.dispose();
  }

  void _showFiltersTutorialIfNeeded({int attempt = 0}) {
    if (!mounted) return;
    if (_isHandlingFiltersTutorialAction) return;
    if (_isFilterBottomSheetOpen) return;

    final tutorialState = ref.read(workoutTutorialProvider);
    if (!tutorialState.isActive ||
        tutorialState.currentStep != WorkoutTutorialStep.filtersAndCustom) {
      return;
    }

    if (_filterButtonKey.currentContext == null) {
      if (attempt >= _tutorialTargetMaxRetries) return;
      Future.delayed(const Duration(milliseconds: 220), () {
        if (mounted) _showFiltersTutorialIfNeeded(attempt: attempt + 1);
      });
      return;
    }

    ref
        .read(workoutTutorialProvider.notifier)
        .showCurrentStep(
          context: context,
          targetKey: _filterButtonKey,
          onCompleteFallbackAfterNext: true,
          onComplete: () {
            unawaited(_handleFiltersStepComplete());
          },
        );
  }

  Future<void> _handleFiltersStepComplete() async {
    if (_isHandlingFiltersTutorialAction) return;

    final tutorialState = ref.read(workoutTutorialProvider);
    if (!tutorialState.isActive ||
        tutorialState.currentStep != WorkoutTutorialStep.filtersAndCustom) {
      return;
    }

    _isHandlingFiltersTutorialAction = true;
    final tutorialNotifier = ref.read(workoutTutorialProvider.notifier);

    try {
      // Enforce deterministic sequence:
      // 1) dismiss tutorial overlay, 2) dismiss keyboard, 3) wait stable frame,
      // 4) open filter sheet.
      tutorialNotifier.dismissCurrentStepOverlay();
      if (!mounted) return;

      FocusScope.of(context).unfocus();
      FocusManager.instance.primaryFocus?.unfocus();

      await _waitForStableFiltersTransition();
      if (!mounted) return;

      tutorialNotifier.advanceToStep(WorkoutTutorialStep.customizeExercise);
      await _showFilterBottomSheet();
    } finally {
      _isHandlingFiltersTutorialAction = false;
    }
  }

  Future<void> _waitForStableFiltersTransition() async {
    // First frame after tutorial overlay dismissal.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    // Wait keyboard hide animation if needed (bounded wait).
    var attempts = 0;
    while (mounted &&
        MediaQuery.of(context).viewInsets.bottom > 0 &&
        attempts < 8) {
      await Future<void>.delayed(const Duration(milliseconds: 45));
      await WidgetsBinding.instance.endOfFrame;
      attempts++;
    }

    // Small settle delay for navigator/overlay transitions on iOS.
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
  }

  /// ✅ FIX: Check if superset templates should be shown
  bool _shouldShowSupersetTemplates() {
    // If explicitly specified, use that value
    if (widget.showSupersetTemplates != null) {
      return widget.showSupersetTemplates!;
    }
    // Otherwise show only for multiSelectMode (superset builder)
    return widget.multiSelectMode;
  }

  Future<void> _loadHintPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _selectionHintDismissed = prefs.getBool(_selectionHintPrefKey) ?? false;
      _actionsHintDismissed = prefs.getBool(_actionsHintPrefKey) ?? false;
    });
  }

  Future<void> _setSelectionHintDismissed() async {
    if (_selectionHintDismissed) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_selectionHintPrefKey, true);
    if (!mounted) return;
    setState(() {
      _selectionHintDismissed = true;
    });
  }

  Future<void> _setActionsHintDismissed() async {
    if (_actionsHintDismissed) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_actionsHintPrefKey, true);
    if (!mounted) return;
    setState(() {
      _actionsHintDismissed = true;
    });
  }

  bool get _isItalian => Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('it');

  bool get _hasAdvancedFiltersActive =>
      _selectedEquipment.isNotEmpty ||
      _selectedType.isNotEmpty ||
      _selectedMovementPattern.isNotEmpty ||
      _selectedMuscleGroups.isNotEmpty;

  bool get _shouldShowSelectionHint =>
      !_selectionHintDismissed &&
      !_hasInteractedWithSelection &&
      _selectedExercises.isEmpty;

  bool get _shouldShowActionsHint =>
      !_actionsHintDismissed && _selectedExercises.isEmpty;

  String _copy({required String it, required String en}) =>
      _isItalian ? it : en;

  String _musclesLabel() => _copy(it: 'Muscolo', en: 'Muscle');

  String _myExercisesLabel() => _copy(it: 'Solo miei', en: 'Only mine');

  String _createdByYouLabel() =>
      _copy(it: 'Creati da te', en: 'Created by you');

  String _recentSectionLabel() => _copy(it: 'Recenti', en: 'Recent');

  String _frequentSectionLabel() => _copy(it: 'Più usati', en: 'Most used');

  String _filterMatchLabel() => _copy(it: 'Match filtro', en: 'Filter match');

  String _selectionHintText() => _copy(
    it: 'Tocca un esercizio per selezionarlo.',
    en: 'Tap an exercise to select it.',
  );

  String _multiSelectHintText() => _copy(
    it: 'Puoi selezionare più esercizi e aggiungerli insieme.',
    en: 'You can select multiple exercises and add them together.',
  );

  String _actionsHintText() => _copy(
    it: 'Tieni premuto o tocca Dettagli per altre opzioni.',
    en: 'Long press or tap Details for more actions.',
  );

  String _detailsAffordanceText() =>
      _copy(it: 'Tocca per dettagli', en: 'Tap for details');

  String _selectedContinueHintText() => _copy(
    it: widget.skipCustomizationOnContinue
        ? 'Selezionato. Tocca Continua per aggiungerlo subito.'
        : 'Selezionato. Tocca Continua per personalizzare.',
    en: widget.skipCustomizationOnContinue
        ? 'Selected. Tap Continue to add it right away.'
        : 'Selected. Tap Continue to customize.',
  );

  String _similarResultsText() => _copy(
    it: 'Risultati simili alla tua ricerca',
    en: 'Results similar to your search',
  );

  String _filtersActiveText(int count) =>
      _copy(it: '$count filtri attivi', en: '$count active filters');

  String _missingExerciseSupportText() => _copy(
    it: 'Non trovi quello che cerchi?',
    en: 'Can’t find what you are looking for?',
  );

  String _selectedSummaryText(int count) {
    if (_isItalian) {
      return count == 1
          ? '1 esercizio selezionato'
          : '$count esercizi selezionati';
    }
    return count == 1 ? '1 exercise selected' : '$count exercises selected';
  }

  double get _listBottomInset {
    final hasSelectionBar = _selectedExercises.isNotEmpty;
    final baseInset =
        MediaQuery.of(context).viewInsets.bottom + context.tabBarInset;
    return hasSelectionBar ? baseInset + 116 : baseInset + 24;
  }

  void _markSelectionInteraction() {
    if (_hasInteractedWithSelection) return;
    setState(() {
      _hasInteractedWithSelection = true;
    });
    unawaited(_setSelectionHintDismissed());
  }

  /// Carica statistiche utilizzo esercizi (frequent/trending)
  Future<void> _loadUsageStats() async {
    try {
      final tracker = ExerciseUsageTracker();

      // Get top used exercises (top 10%)
      final topExercises = await tracker.getTopUsedExercises(limit: 50);

      // Get recently used (last 7 days)
      final recentExercises = await tracker.getRecentlyUsedExercises(limit: 30);
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentIds = recentExercises
          .where((e) => e.lastUsedAt.isAfter(sevenDaysAgo))
          .map((e) => e.exerciseId)
          .toSet();

      if (mounted) {
        setState(() {
          _frequentExerciseIds = topExercises.map((e) => e.exerciseId).toSet();
          _trendingExerciseIds = recentIds;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error loading usage stats: $e');
      }
    }
  }

  /// Build recommended superset templates section
  Widget _buildRecommendedTemplatesSection() {
    final templatesAsync = ref.watch(recommendedSupersetTemplatesProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Icon(AppIcons.link, size: 16, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.recommendedTemplates,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 168, // Card height 160 + padding
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SupersetTemplateCard(
                      template: template,
                      onTap: () {
                        SupersetTemplatePreviewSheet.show(
                          context,
                          ref: ref,
                          template: template,
                          source: 'exercise_search',
                          onUseTemplate: () => _handleUseTemplate(template),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 16),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Gestisce negative feedback con opzioni (decrementa o rimuovi)
  Future<void> _handleNegativeFeedback(Exercise exercise) async {
    // Mostra dialogo con opzioni
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const SemanticIcon(
              icon: AppIcons.feedbackOutlined,
              semanticLabel: 'Feedback outlined',
              size: AppIconSize.medium,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(context.l10n.exerciseFeedback)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Come vuoi gestire "${exercise.nome}"?',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '• Riduci priorità: L\'esercizio apparirà meno in alto\n• Rimuovi dai popolari: L\'esercizio non sarà più suggerito come frequente',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: context.l10n.cancel,
            button: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop('decrement'),
            icon: const SemanticIcon(
              icon: AppIcons.arrowDownward,
              semanticLabel: 'Arrow downward',
              size: AppIconSize.small,
            ),
            label: Text(context.l10n.reducePriority),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop('remove'),
            icon: const SemanticIcon(
              icon: AppIcons.deleteOutline,
              semanticLabel: 'Delete outline',
              size: AppIconSize.small,
            ),
            label: Text(context.l10n.remove),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.errorContainer,
              foregroundColor: context.colors.onErrorContainer,
            ),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    try {
      final tracker = ExerciseUsageTracker();

      if (result == 'decrement') {
        // Decrementa boost
        await tracker.decrementUsage(exerciseId: exercise.id);

        if (mounted) {
          SnackBarService.showInfo(
            context,
            'Priorità ridotta per "${exercise.nome}"',
          );
        }
      } else if (result == 'remove') {
        // Rimuovi completamente
        await tracker.removeExercise(exerciseId: exercise.id);

        if (mounted) {
          SnackBarService.showError(
            context,
            '"${exercise.nome}" rimosso dai popolari',
            actionLabel: 'ANNULLA',
            onAction: () async {
              // Re-add with usage count 1
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await tracker.incrementUsage(
                  exerciseId: exercise.id,
                  exerciseName: exercise.nome,
                  userId: user.uid,
                );
                await _loadUsageStats();
              }
            },
          );
        }
      }

      // Reload stats
      await _loadUsageStats();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling negative feedback: $e');
      }
    }
  }

  /// Tracka utilizzo esercizio quando viene selezionato
  Future<void> _trackExerciseSelection(Exercise exercise) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final tracker = ExerciseUsageTracker();
      await tracker.incrementUsage(
        exerciseId: exercise.id,
        exerciseName: exercise.nome,
        userId: user.uid,
      );

      // Reload stats in background (no await to not block UI)
      unawaited(_loadUsageStats());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error tracking exercise selection: $e');
      }
    }
  }

  Future<void> _performFuzzySearch(String query) async {
    if (query.trim().isEmpty || query.length < 2) {
      setState(() {
        _useFuzzyResults = false;
        _fuzzyResults = [];
        _isSearching = false;
      });
      return;
    }

    // OPTIMIZATION: Only show loading indicator after 100ms
    // This prevents flicker for fast typers
    Timer(const Duration(milliseconds: 100), () {
      if (mounted && _isSearching == false) {
        setState(() {
          _isSearching = true;
        });
      }
    });

    // 🔐 SECURITY: Use Debouncer for search throttling (400ms delay)
    _searchDebouncer.run(() async {
      if (!mounted) return;

      final searchStartTime = DateTime.now();

      try {
        // ✅ FIX: Usa esercizi già caricati dal provider (CACHED!)
        // Non ricaricare JSON ogni volta - causa lag UI
        final exercisesAsync = ref.read(jsonExerciseRepositoryProvider);
        final exercises = exercisesAsync.value;

        if (exercises == null) {
          // Provider still loading, skip
          if (mounted) {
            setState(() {
              _isSearching = false;
            });
          }
          return;
        }

        // Get userId for ML-enhanced personalization
        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.uid;

        // Get current category from selected muscle groups (if any)
        final currentCategory = _selectedMuscleGroups.isNotEmpty
            ? _selectedMuscleGroups.first
            : null;

        // 🚀 OPTIMIZED: Persistent isolate + batch ML boosts
        final results = await ExerciseFuzzyMatcher.searchExercises(
          exercises: exercises,
          query: query,
          strictThreshold: 0.65,
          typeThreshold: 0.50,
          maxResults: 50,
          userId: userId,
          currentCategory: currentCategory,
          enableUserBoost: true,
          enableCategoryBoost: true,
        );

        if (!mounted) return;

        // Filter quality (>= 65% score)
        final filteredResults = results.where((r) => r.score >= 0.65).toList();

        // PERFORMANCE METRICS (debug only)
        if (kDebugMode) {
          final duration = DateTime.now().difference(searchStartTime);
          debugPrint(
            '🔍 Fuzzy search completed in ${duration.inMilliseconds}ms (${filteredResults.length} results)',
          );
        }

        // OPTIMIZATION: Batch setState to reduce rebuilds
        setState(() {
          _fuzzyResults = filteredResults;
          _useFuzzyResults = filteredResults.isNotEmpty;
          _isSearching = false;
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Fuzzy search error: $e');
        }
        if (mounted) {
          setState(() {
            _useFuzzyResults = false;
            _fuzzyResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  /// Toggle search bar visibility
  void _toggleSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _useFuzzyResults = false;
      _fuzzyResults = [];
    });
    _searchDebouncer.cancel();
  }

  /// Get count of active filters
  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedEquipment.isNotEmpty) count++;
    if (_selectedMuscleGroups.isNotEmpty) count++;
    if (_selectedFocus.isNotEmpty) count++;
    if (_selectedType.isNotEmpty) count++;
    if (_selectedMovementPattern.isNotEmpty) count++;
    if (_showOnlyCustom) count++;
    if (_showOnlyRecent) count++;
    return count;
  }

  /// Show filter bottom sheet
  Future<void> _showFilterBottomSheet() async {
    if (_isFilterBottomSheetOpen) return;

    // Ensure keyboard is closed before showing the sheet.
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    final exercisesAsync = ref.read(jsonExerciseRepositoryProvider);
    final exercises = exercisesAsync.value ?? [];

    final currentFilters = ExerciseFilters(
      muscleGroups: _selectedMuscleGroups,
      equipment: _selectedEquipment,
      exerciseType: _selectedType,
      movementPattern: _selectedMovementPattern,
    );

    _isFilterBottomSheetOpen = true;
    try {
      await ModalService.showSheet(
        context,
        isScrollControlled: true,
        builder: (sheetContext) => _ExerciseFilterSheet(
          exercises: exercises,
          currentFilters: currentFilters,
          onApply: (filters) {
            _applyFilters(filters);
          },
          onSave: (filters) async {
            _applyFilters(filters);
            await _saveFilters(filters);
          },
        ),
      );
    } finally {
      _isFilterBottomSheetOpen = false;
    }
  }

  void _applyFilters(ExerciseFilters filters) {
    setState(() {
      _selectedMuscleGroups
        ..clear()
        ..addAll(filters.muscleGroups);
      _selectedEquipment = List.from(filters.equipment);
      _selectedType = List.from(filters.exerciseType);
      _selectedMovementPattern = List.from(filters.movementPattern);
    });
  }

  /// Salva i filtri in SharedPreferences
  Future<void> _saveFilters(ExerciseFilters filters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('exercise_muscle_filter', filters.muscleGroups);
    await prefs.setStringList('exercise_equipment_filter', filters.equipment);
    await prefs.setStringList('exercise_type_filter', filters.exerciseType);
    await prefs.setStringList(
      'exercise_pattern_filter',
      filters.movementPattern,
    );
  }

  /// Carica i filtri salvati da SharedPreferences
  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final muscles = prefs.getStringList('exercise_muscle_filter');
    final equipment = prefs.getStringList('exercise_equipment_filter');
    final type = prefs.getStringList('exercise_type_filter');
    final pattern = prefs.getStringList('exercise_pattern_filter');

    setState(() {
      if (muscles != null && muscles.isNotEmpty) {
        _selectedMuscleGroups
          ..clear()
          ..addAll(muscles);
      }
      if (equipment != null && equipment.isNotEmpty) {
        _selectedEquipment = equipment;
      }
      if (type != null && type.isNotEmpty) {
        _selectedType = type;
      }
      if (pattern != null && pattern.isNotEmpty) {
        _selectedMovementPattern = pattern;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use fuzzy search for active queries, fallback to JSON repository for browsing
    final exercisesAsync = ref.watch(jsonExerciseRepositoryProvider);
    final l10n = context.l10n;
    final activeFilterCount = _getActiveFilterCount();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(l10n.addExercisesTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const SemanticIcon(icon: AppIcons.back, semanticLabel: 'Back'),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          // Filter button with badge
          Stack(
            children: [
              Semantics(
                label: l10n.filters,
                button: true,
                child: IconButton(
                  key: _filterButtonKey,
                  icon: const Icon(AppIcons.filter),
                  onPressed:
                      _isHandlingFiltersTutorialAction ||
                          _isFilterBottomSheetOpen
                      ? null
                      : _showFilterBottomSheet,
                  tooltip: l10n.filters,
                ),
              ),
              if (activeFilterCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(l10n),
              _buildQuickFiltersBar(l10n),
              if (_shouldShowSelectionHint || _shouldShowActionsHint)
                _buildInlineActionHints(),

              // Results
              Expanded(
                child: _useFuzzyResults
                    ? _buildFuzzySearchResults()
                    : exercisesAsync.when(
                        data: (exercises) {
                          final filteredExercises = _filterExercises(exercises);

                          if (filteredExercises.isEmpty) {
                            return _buildEmptyState();
                          }

                          return _buildSearchResults(filteredExercises);
                        },
                        loading: () => const Center(child: LoadingIndicator()),
                        error: (error, stack) => _buildErrorState(error),
                      ),
              ),
            ],
          ),
          if (_selectedExercises.isNotEmpty) _buildStickySelectionBar(l10n),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Exercise> exercises) {
    final l10n = context.l10n;

    // Watch ALL custom exercises (including expired) and merge with catalog
    // UX FIX: Show all custom exercises so users can see/renew expired ones
    final customExercisesAsync = ref.watch(allCustomExercisesProvider);
    final customExercises = customExercisesAsync.value ?? [];

    // Check if user has unlimited exercises (Premium/Platinum)
    final entitlements = ref.watch(tierEntitlementsProvider);
    final hasUnlimitedExercises = entitlements.maxCustomSingleExercises >= 999;

    // Create lookup map for custom exercise status (for UI badges)
    final customExerciseMap = {for (final c in customExercises) c.id: c};

    // Convert custom exercises to Exercise format for display
    final customAsExercises = customExercises
        .map(
          (custom) => Exercise(
            id: custom.id,
            nome: custom.displayName,
            focus: custom.focus,
            imageUrl: null,
            muscoliSecondari: custom.muscoliSecondari,
            difficolta: 'Intermedio',
            tipoEsercizio: custom.tipoEsercizio,
            attrezzatura: custom.attrezzatura,
            patternMovimento: custom.patternMovimento,
            rangeRipetizioni: '8-12',
            noteTecniche: '',
            mobilitaPre: null,
            attivazionePre: null,
          ),
        )
        .toList();
    final customIds = customAsExercises.map((e) => e.id).toSet();
    final filteredCustomExercises = _filterExercises(customAsExercises);
    final filteredCatalogExercises = _sortExercisesByUsage(
      _filterExercises(exercises),
    );

    if (_showOnlyCustom) {
      return _buildFlatExerciseResults(
        displayExercises: filteredCustomExercises,
        customIds: customIds,
        customExerciseMap: customExerciseMap,
        hasUnlimitedExercises: hasUnlimitedExercises,
        showTemplates: false,
      );
    }

    if (_showOnlyRecent) {
      final recentExercises = filteredCatalogExercises
          .where((exercise) => _trendingExerciseIds.contains(exercise.id))
          .toList();
      return _buildFlatExerciseResults(
        displayExercises: recentExercises,
        customIds: customIds,
        customExerciseMap: customExerciseMap,
        hasUnlimitedExercises: hasUnlimitedExercises,
        showTemplates: false,
      );
    }

    if (_searchQuery.isEmpty && !_hasAdvancedFiltersActive) {
      final recentExercises = filteredCatalogExercises
          .where((exercise) => _trendingExerciseIds.contains(exercise.id))
          .toList();
      final frequentExercises = filteredCatalogExercises
          .where(
            (exercise) =>
                !recentExercises.contains(exercise) &&
                _frequentExerciseIds.contains(exercise.id),
          )
          .toList();
      final remainingCatalog =
          filteredCatalogExercises
              .where(
                (exercise) =>
                    !recentExercises.contains(exercise) &&
                    !frequentExercises.contains(exercise),
              )
              .toList()
            ..sort((a, b) => a.nome.compareTo(b.nome));

      return _buildSectionedExerciseResults(
        customIds: customIds,
        customExerciseMap: customExerciseMap,
        hasUnlimitedExercises: hasUnlimitedExercises,
        sections: [
          if (filteredCustomExercises.isNotEmpty)
            _ExerciseSectionData(
              title: _createdByYouLabel(),
              exercises: filteredCustomExercises,
              badge: _createdByYouLabel(),
            ),
          if (recentExercises.isNotEmpty)
            _ExerciseSectionData(
              title: _recentSectionLabel(),
              exercises: recentExercises,
            ),
          if (frequentExercises.isNotEmpty)
            _ExerciseSectionData(
              title: _frequentSectionLabel(),
              exercises: frequentExercises,
              badge: _frequentSectionLabel(),
            ),
          _ExerciseSectionData(
            title: l10n.allExercises,
            exercises: remainingCatalog,
            emptyMessage: l10n.noExercisesFound,
          ),
        ],
      );
    }

    return _buildFlatExerciseResults(
      displayExercises: [
        ...filteredCustomExercises,
        ...filteredCatalogExercises,
      ],
      customIds: customIds,
      customExerciseMap: customExerciseMap,
      hasUnlimitedExercises: hasUnlimitedExercises,
      showTemplates: _searchQuery.isEmpty && _shouldShowSupersetTemplates(),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      key: _searchBarKey,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.45),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: _searchController,
          autofocus: false,
          style: context.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: l10n.searchExercisesHint,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            isDense: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 8, right: 4),
              child: SemanticIcon(
                icon: AppIcons.search,
                semanticLabel: 'Search',
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: LoadingIndicator(size: 18),
                  )
                : (_searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const SemanticIcon(
                            icon: AppIcons.clear,
                            semanticLabel: 'Clear',
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: _toggleSearch,
                        )
                      : null),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.primary, width: 1.5),
            ),
            filled: true,
            fillColor: context.colors.surface,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value.toLowerCase());
            _performFuzzySearch(value);
          },
        ),
      ),
    );
  }

  Widget _buildQuickFiltersBar(AppLocalizations l10n) {
    final activeFilterCount = _getActiveFilterCount();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickFilterChip(
                  label: _musclesLabel(),
                  selected: _selectedMuscleGroups.isNotEmpty,
                  icon: AppIcons.workout,
                  onTap: () {
                    unawaited(_showMuscleQuickFilterSheet());
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickFilterChip(
                  label: l10n.equipment,
                  selected: _selectedEquipment.isNotEmpty,
                  icon: AppIcons.filter,
                  onTap: () {
                    unawaited(_showFilterBottomSheet());
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickFilterChip(
                  label: l10n.exerciseType,
                  selected: _selectedType.isNotEmpty,
                  icon: AppIcons.tune,
                  onTap: () {
                    unawaited(_showFilterBottomSheet());
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickFilterChip(
                  label: _myExercisesLabel(),
                  selected: _showOnlyCustom,
                  icon: AppIcons.personOutline,
                  onTap: () {
                    setState(() {
                      _showOnlyCustom = !_showOnlyCustom;
                      if (_showOnlyCustom) {
                        _showOnlyRecent = false;
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickFilterChip(
                  label: _recentSectionLabel(),
                  selected: _showOnlyRecent,
                  icon: AppIcons.history,
                  onTap: () {
                    setState(() {
                      _showOnlyRecent = !_showOnlyRecent;
                      if (_showOnlyRecent) {
                        _showOnlyCustom = false;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          if (activeFilterCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _filtersActiveText(activeFilterCount),
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _clearAllFilters,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.reset),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? context.colors.onPrimaryContainer : null,
      ),
      label: Text(label),
      selectedColor: context.colors.primaryContainer,
      backgroundColor: context.colors.surface,
      side: BorderSide(
        color: selected
            ? context.colors.primary.withValues(alpha: 0.2)
            : context.colors.outline.withValues(alpha: 0.2),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildInlineActionHints() {
    final hintLines = <String>[
      if (_shouldShowSelectionHint) _selectionHintText(),
      if (widget.multiSelectMode && _shouldShowSelectionHint)
        _multiSelectHintText(),
      if (_shouldShowActionsHint) _actionsHintText(),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(AppIcons.helpOutline, size: 18, color: context.colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: hintLines
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          line,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            IconButton(
              onPressed: () {
                unawaited(_setSelectionHintDismissed());
                unawaited(_setActionsHintDismissed());
              },
              icon: const Icon(AppIcons.close, size: 18),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minHeight: 28, minWidth: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickySelectionBar(AppLocalizations l10n) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).viewInsets.bottom,
      child: SafeArea(
        top: false,
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: context.colors.outline.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  color: Colors.black.withValues(alpha: 0.10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSummaryText(_selectedExercises.length),
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedContinueHintText(),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  key: _addButtonKey,
                  onPressed: widget.multiSelectMode
                      ? _selectExercises
                      : _addSelectedToWorkout,
                  icon: Icon(
                    widget.multiSelectMode ? AppIcons.check : AppIcons.forward,
                  ),
                  label: Text(l10n.continueButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Exercise> _sortExercisesByUsage(List<Exercise> exercises) {
    final sortedCatalog = List<Exercise>.from(exercises);
    sortedCatalog.sort((a, b) {
      final aFrequent = _frequentExerciseIds.contains(a.id);
      final bFrequent = _frequentExerciseIds.contains(b.id);
      final aTrending = _trendingExerciseIds.contains(a.id);
      final bTrending = _trendingExerciseIds.contains(b.id);
      final aScore = (aFrequent ? 2 : 0) + (aTrending ? 1 : 0);
      final bScore = (bFrequent ? 2 : 0) + (bTrending ? 1 : 0);

      if (aScore != bScore) return bScore.compareTo(aScore);
      return a.nome.compareTo(b.nome);
    });
    return sortedCatalog;
  }

  Widget _buildSectionedExerciseResults({
    required List<_ExerciseSectionData> sections,
    required Set<String> customIds,
    required Map<String, CustomExercise> customExerciseMap,
    required bool hasUnlimitedExercises,
  }) {
    return ListView(
      key: const PageStorageKey('exercise_search_sectioned_list'),
      padding: EdgeInsets.only(bottom: _listBottomInset),
      children: [
        if (_shouldShowSupersetTemplates()) _buildRecommendedTemplatesSection(),
        for (final section in sections) ...[
          _buildSectionHeader(section.title, section.exercises.length),
          if (section.exercises.isEmpty && section.emptyMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                section.emptyMessage!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            )
          else
            ...section.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              final isCustom = customIds.contains(exercise.id);
              return _buildExerciseCard(
                exercise,
                _selectedExercises.contains(exercise),
                isCustom: isCustom,
                customExercise: isCustom
                    ? customExerciseMap[exercise.id]
                    : null,
                hasUnlimitedExercises: hasUnlimitedExercises,
                tutorialKey: identical(section, sections.first) && index == 0
                    ? _exerciseCardKey
                    : null,
                reasonBadges: [if (section.badge != null) section.badge!],
              );
            }),
        ],
        _buildMissingExerciseWidget(),
      ],
    );
  }

  Widget _buildFlatExerciseResults({
    required List<Exercise> displayExercises,
    required Set<String> customIds,
    required Map<String, CustomExercise> customExerciseMap,
    required bool hasUnlimitedExercises,
    required bool showTemplates,
  }) {
    if (displayExercises.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (showTemplates) _buildRecommendedTemplatesSection(),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: ListView.builder(
              key: const PageStorageKey('exercise_search_list'),
              padding: EdgeInsets.only(bottom: _listBottomInset),
              itemCount: displayExercises.length + 1,
              itemBuilder: (context, index) {
                if (index == displayExercises.length) {
                  return _buildMissingExerciseWidget();
                }

                final exercise = displayExercises[index];
                final isCustom = customIds.contains(exercise.id);

                return _buildExerciseCard(
                  exercise,
                  _selectedExercises.contains(exercise),
                  isCustom: isCustom,
                  customExercise: isCustom
                      ? customExerciseMap[exercise.id]
                      : null,
                  hasUnlimitedExercises: hasUnlimitedExercises,
                  tutorialKey: index == 0 ? _exerciseCardKey : null,
                  reasonBadges: _buildReasonBadges(
                    exercise,
                    isCustom: isCustom,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildReasonBadges(Exercise exercise, {required bool isCustom}) {
    final badges = <String>[];

    if (isCustom) {
      badges.add(_createdByYouLabel());
    }
    if (_frequentExerciseIds.contains(exercise.id) &&
        !_trendingExerciseIds.contains(exercise.id)) {
      badges.add(_frequentSectionLabel());
    }
    if (_hasAdvancedFiltersActive && _matchesCurrentFilterContext(exercise)) {
      badges.add(_filterMatchLabel());
    }

    return badges.take(2).toList();
  }

  bool _matchesCurrentFilterContext(Exercise exercise) {
    if (_selectedMuscleGroups.isNotEmpty) {
      final normalizedFocus = exercise.focus.map(_normalizedMuscleCode);
      if (normalizedFocus.any(_selectedMuscleGroups.contains)) {
        return true;
      }
    }
    if (_selectedEquipment.isNotEmpty &&
        _selectedEquipment.contains(exercise.attrezzatura)) {
      return true;
    }
    if (_selectedType.isNotEmpty &&
        _selectedType.contains(exercise.tipoEsercizio)) {
      return true;
    }
    if (_selectedMovementPattern.isNotEmpty &&
        _selectedMovementPattern.contains(exercise.patternMovimento)) {
      return true;
    }
    return false;
  }

  Widget _buildFuzzySearchResults() {
    final l10n = context.l10n;

    return Column(
      children: [
        // Results count with fuzzy indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: context.colors.primaryContainer.withValues(alpha: 0.3),
          child: Row(
            children: [
              SemanticIcon(
                icon: AppIcons.autoAwesome,
                semanticLabel: 'Auto awesome',
                size: AppIconSize.tiny,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${_fuzzyResults.length} ${l10n.exercisesFound}',
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _similarResultsText(),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),

        // Fuzzy Exercise List + Missing Exercise Widget
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: ListView.builder(
              key: const PageStorageKey('exercise_fuzzy_search_list'),
              padding: EdgeInsets.only(bottom: _listBottomInset),
              itemCount:
                  _fuzzyResults.length + 1, // +1 for missing exercise widget
              itemBuilder: (context, index) {
                // Show missing exercise widget as last item
                if (index == _fuzzyResults.length) {
                  return _buildMissingExerciseWidget();
                }

                final fuzzyResult = _fuzzyResults[index];
                final exercise = fuzzyResult.exercise;
                final isSelected = _selectedExercises.contains(exercise);

                return _buildFuzzyExerciseCard(
                  exercise,
                  isSelected,
                  fuzzyResult.score,
                  fuzzyResult.wasAutoCorrected,
                  tutorialKey: index == 0 ? _exerciseCardKey : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissingExerciseWidget() {
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.help, color: context.colors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _missingExerciseSupportText(),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.exerciseNotFoundHelpText,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Create custom exercise button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  _showCreateCustomSheet(context, _searchController.text),
              icon: const SemanticIcon(
                icon: AppIcons.add,
                semanticLabel: 'Add',
              ),
              label: Text(l10n.createCustomExercise),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Or add temporary (fallback option)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddTemporaryExerciseDialog,
              icon: const SemanticIcon(
                icon: AppIcons.addCircleOutline,
                semanticLabel: 'Add circle outline',
              ),
              label: Text(l10n.addTemporaryExercise),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTemporaryExerciseDialog() {
    final l10n = context.l10n;
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.workout, color: context.colors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.addTemporaryExercise)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.exerciseNotFoundHelpText,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.enterExerciseName,
                hintText: 'es. Bulgarian Split Squat',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.primary,
                    width: 2.0,
                  ),
                ),
                prefixIcon: const SemanticIcon(
                  icon: AppIcons.edit,
                  semanticLabel: 'Edit',
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          Semantics(
            label: l10n.cancel,
            button: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              final exerciseName = nameController.text.trim();
              if (exerciseName.isEmpty) {
                SnackBarService.showError(context, l10n.enterExerciseName);
                return;
              }

              // Generate ID from exercise name
              final exerciseId = _generateExerciseId(exerciseName);

              // Create temporary exercise
              final temporaryExercise = Exercise(
                id: exerciseId,
                nome: exerciseName,
                focus: const ['VARIO'],
                imageUrl: null,
                muscoliSecondari: const [],
                difficolta: 'Intermedio',
                tipoEsercizio: 'Compound',
                attrezzatura: 'Vario',
                patternMovimento: '',
                rangeRipetizioni: '8-12',
                noteTecniche:
                    'Esercizio temporaneo - In attesa di approvazione',
                mobilitaPre: null,
                attivazionePre: null,
              );

              // Add to selected exercises so user can use it immediately
              setState(() {
                _selectedExercises.add(temporaryExercise);
              });

              // Send report to Firebase for admin review
              _sendMissingExerciseReport(exerciseName, exerciseId);

              Navigator.of(context).pop();

              // Show confirmation
              SnackBarService.showSuccess(
                context,
                l10n.temporaryExerciseAdded,
                actionLabel: l10n.add,
                onAction: () {
                  // Add to workout directly
                  _addSelectedToWorkout();
                },
              );
            },
            icon: const SemanticIcon(
              icon: AppIcons.check,
              semanticLabel: 'Check',
            ),
            label: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  String _generateExerciseId(String exerciseName) {
    // Convert exercise name to ID format
    // Example: "Bulgarian Split Squat" -> "bulgarian_split_squat_temp"
    return '${exerciseName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}_temp';
  }

  Future<void> _sendMissingExerciseReport(
    String exerciseName,
    String exerciseId,
  ) async {
    try {
      final service = ref.read(missingExerciseServiceProvider);
      await service.submitRequest(
        exerciseName: exerciseName,
        exerciseId: exerciseId,
      );
    } catch (e) {
      // Silent fail - don't interrupt user flow
      // The temporary exercise is already added
      debugPrint('Failed to submit missing exercise request: $e');
    }
  }

  Widget _buildErrorState(dynamic error) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: 'Error',
            size: AppIconSize.medium,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text('${l10n.errorLoadingData}: $error'),
          const SizedBox(height: 16),
          Semantics(
            label: l10n.retry,
            button: true,
            child: ElevatedButton(
              onPressed: () => ref.refresh(jsonExerciseRepositoryProvider),
              child: Text(l10n.retry),
            ),
          ),
        ],
      ),
    );
  }

  /// Normalize muscle codes to canonical form
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delegates to MuscleAbbreviationMapper.
  String _normalizedMuscleCode(String muscleCode) {
    return MuscleAbbreviationMapper.normalizeToCanonicalId(muscleCode);
  }

  Widget _buildExerciseLeading(Exercise exercise, bool isSelected) {
    if (isSelected) {
      return CircleAvatar(
        backgroundColor: context.colors.primary,
        child: Icon(AppIcons.check, color: context.colors.surface),
      );
    }

    if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) {
      return ExerciseGifWidget(
        gifUrl: exercise.imageUrl,
        exerciseName: exercise.nome,
        size: 64,
        backgroundColor: context.colors.surfaceContainerHighest,
        iconColor: context.colors.primary,
      );
    }

    return CircleAvatar(
      backgroundColor: context.colors.surfaceContainerHighest,
      radius: 32,
      child: Text(exercise.attrezzaturaIcon),
    );
  }

  Widget _buildExerciseCard(
    Exercise exercise,
    bool isSelected, {
    bool isCustom = false,
    CustomExercise? customExercise,
    bool hasUnlimitedExercises = false,
    GlobalKey? tutorialKey,
    List<String> reasonBadges = const [],
  }) {
    return Card(
      key: tutorialKey,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        minLeadingWidth: 44,
        leading: _buildExerciseLeading(exercise, isSelected),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                exercise.nome,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCustom && customExercise != null) ...[
              const SizedBox(width: 8),
              _buildCustomExerciseBadge(
                customExercise,
                hasUnlimitedExercises: hasUnlimitedExercises,
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _buildCompactMetadataLine(exercise),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (reasonBadges.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: reasonBadges
                      .map((badge) => _buildReasonBadgeChip(badge))
                      .toList(),
                ),
              ],
              const SizedBox(height: 8),
              _buildDetailsLink(
                exercise,
                isCustom: isCustom,
                icon: AppIcons.preview,
              ),
            ],
          ),
        ),
        trailing: isSelected
            ? Icon(AppIcons.checkCircle, color: context.colors.primary)
            : (widget.selectionMode
                  ? const SemanticIcon(
                      icon: AppIcons.arrowForwardIos,
                      semanticLabel: 'Arrow forward ios',
                      size: AppIconSize.tiny,
                    )
                  : const SemanticIcon(
                      icon: AppIcons.radioButtonUnchecked,
                      semanticLabel: 'Radio button unchecked',
                    )),
        onTap: () {
          _trackExerciseSelection(exercise);
          _markSelectionInteraction();

          if (widget.selectionMode) {
            Navigator.of(context).pop(exercise);
            return;
          }

          setState(() {
            if (isSelected) {
              _selectedExercises.remove(exercise);
            } else {
              _selectedExercises.add(exercise);
            }
          });
        },
        onLongPress: () {
          unawaited(_setActionsHintDismissed());
          _showExerciseQuickActionsSheet(exercise, isCustom: isCustom);
        },
      ),
    );
  }

  Widget _buildFuzzyExerciseCard(
    Exercise exercise,
    bool isSelected,
    double matchScore,
    bool wasAutoCorrected, {
    GlobalKey? tutorialKey,
  }) {
    final matchPercentage = (matchScore * 100).toInt();

    // Color based on match quality
    Color matchColor;
    if (matchScore >= 0.85) {
      matchColor = context.colors.success;
    } else if (matchScore >= 0.70) {
      matchColor = context.colors.warning;
    } else {
      matchColor = context.colors.surfaceContainerHighest;
    }

    // Check if exercise is frequent or trending (ML-enhanced)
    final isFrequent = _frequentExerciseIds.contains(exercise.id);
    final isTrending = _trendingExerciseIds.contains(exercise.id);

    // Check if category matches (for colored border)
    // ML-enhanced: show green border if exercise matches selected muscle groups
    final hasCategoryMatch =
        _selectedMuscleGroups.isNotEmpty &&
        exercise.focus.any(
          (focus) =>
              _selectedMuscleGroups.contains(_normalizedMuscleCode(focus)),
        );

    return Card(
      key: tutorialKey,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: wasAutoCorrected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasCategoryMatch
            ? BorderSide(color: context.colors.success, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        leading: _buildExerciseLeading(exercise, isSelected),
        title: Row(
          children: [
            Expanded(
              child: Text(
                exercise.nome,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // Match percentage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: matchColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: matchColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                '$matchPercentage%',
                style: context.textTheme.labelSmall?.copyWith(
                  color: matchColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Auto-correct icon
            if (wasAutoCorrected) ...[
              const SizedBox(width: 4),
              SemanticIcon(
                icon: AppIcons.autoFixHigh,
                semanticLabel: 'Auto fix high',
                size: AppIconSize.tiny,
                color: context.colors.secondary,
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ML-enhanced badges row
            if (isFrequent || isTrending) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (isFrequent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.warning.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('⭐', style: context.textTheme.labelSmall),
                          const SizedBox(width: 2),
                          Text(
                            _frequentSectionLabel(),
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isFrequent && isTrending) const SizedBox(width: 4),
                  if (isTrending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.warning.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥', style: context.textTheme.labelSmall),
                          const SizedBox(width: 2),
                          Text(
                            _recentSectionLabel(),
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: 4),
            Text(
              _buildCompactMetadataLine(exercise),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            _buildDetailsLink(exercise, icon: AppIcons.preview),
          ],
        ),
        trailing: SizedBox(
          width: 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Selection icon
              isSelected
                  ? Icon(AppIcons.complete, color: context.colors.primary)
                  : (widget.selectionMode
                        ? const SemanticIcon(
                            icon: AppIcons.arrowForwardIos,
                            semanticLabel: 'Arrow forward ios',
                            size: AppIconSize.tiny,
                          )
                        : const SemanticIcon(
                            icon: AppIcons.radioButtonUnchecked,
                            semanticLabel: 'Radio button unchecked',
                          )),
            ],
          ),
        ),
        onTap: () {
          // Track selection (ML-enhanced)
          _trackExerciseSelection(exercise);
          _markSelectionInteraction();

          // Selection mode: return exercise and close
          if (widget.selectionMode) {
            Navigator.of(context).pop(exercise);
            return;
          }

          // Multi-select mode or normal mode: toggle selection
          setState(() {
            if (isSelected) {
              _selectedExercises.remove(exercise);
            } else {
              _selectedExercises.add(exercise);
            }
          });
        },
        onLongPress: () {
          unawaited(_setActionsHintDismissed());
          _showExerciseQuickActionsSheet(exercise);
        },
      ),
    );
  }

  String _buildCompactMetadataLine(Exercise exercise) {
    final parts = <String>[];

    if (exercise.focus.isNotEmpty) {
      parts.add(
        MuscleAbbreviationMapper.codeToDisplayName(
          exercise.focus.first,
          italian: _isItalian,
        ),
      );
    }
    if (exercise.attrezzatura.isNotEmpty) {
      parts.add(exercise.attrezzatura);
    }
    if (exercise.tipoEsercizio.isNotEmpty) {
      parts.add(exercise.tipoEsercizio);
    }

    return parts.join(' • ');
  }

  Widget _buildReasonBadgeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDetailsLink(
    Exercise exercise, {
    required IconData icon,
    bool isCustom = false,
  }) {
    return InkWell(
      onTap: () {
        unawaited(_setActionsHintDismissed());
        _showExerciseQuickActionsSheet(exercise, isCustom: isCustom);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: context.colors.primary),
            const SizedBox(width: 6),
            Text(
              '${context.l10n.details} · ${_detailsAffordanceText()}',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;
    return ListView(
      padding: EdgeInsets.only(bottom: _listBottomInset),
      children: [
        const SizedBox(height: 64),
        SemanticIcon(
          icon: AppIcons.searchOff,
          semanticLabel: 'Search off',
          size: AppIconSize.medium,
          color: context.colors.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.noExercisesFound,
          style: context.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.tryModifyingFilters,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (_getActiveFilterCount() > 0)
          Semantics(
            label: l10n.clearAllFilters,
            button: true,
            child: TextButton(
              onPressed: _clearAllFilters,
              child: Text(l10n.clearAllFilters),
            ),
          ),
        const SizedBox(height: 24),
        _buildMissingExerciseWidget(),
      ],
    );
  }

  /// Soglia minima per fuzzy match (0-100)
  /// 70 = permette ~30% di errori (es: "distenzioni" → "distensioni")
  static const int _fuzzyThreshold = 70;

  /// Verifica se una query matcha un testo usando fuzzy matching
  bool _fuzzyMatch(String query, String text) {
    // Prima prova match esatto (più veloce)
    if (text.toLowerCase().contains(query)) {
      return true;
    }
    // Poi prova fuzzy match per typos
    // Tokenizza query e verifica che ogni token matchi
    final queryTokens = query.split(RegExp(r'\s+')).where((t) => t.length >= 2);
    if (queryTokens.isEmpty) return false;

    final textLower = text.toLowerCase();
    for (final token in queryTokens) {
      // Controlla se il token matcha direttamente
      if (textLower.contains(token)) continue;

      // Altrimenti prova fuzzy match con ogni parola del testo
      final textWords = textLower.split(RegExp(r'\s+'));
      bool tokenFound = false;
      for (final word in textWords) {
        if (ratio(token, word) >= _fuzzyThreshold) {
          tokenFound = true;
          break;
        }
      }
      if (!tokenFound) return false;
    }
    return true;
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    return exercises.where((exercise) {
      // Search query filter - skip if it's a smart filter
      // (improved search already handled it)
      if (_searchQuery.isNotEmpty && !_isSmartFilter(_searchQuery)) {
        final query = _searchQuery.toLowerCase();
        // Usa fuzzy matching invece di contains() semplice
        if (!_fuzzyMatch(query, exercise.nome) &&
            !_fuzzyMatch(query, exercise.focusDisplayName) &&
            !_fuzzyMatch(query, exercise.attrezzatura)) {
          return false;
        }
      }

      // Focus filter
      if (_selectedFocus.isNotEmpty) {
        if (!exercise.focus.any((focus) => _selectedFocus.contains(focus))) {
          return false;
        }
      }

      // Muscle groups filter
      if (_selectedMuscleGroups.isNotEmpty) {
        final normalizedFocus = exercise.focus
            .map(_normalizedMuscleCode)
            .toList();
        if (!normalizedFocus.any(
          (focus) => _selectedMuscleGroups.contains(focus),
        )) {
          return false;
        }
      }

      // Equipment filter
      if (_selectedEquipment.isNotEmpty) {
        if (!_selectedEquipment.contains(exercise.attrezzatura)) {
          return false;
        }
      }

      // Type filter
      if (_selectedType.isNotEmpty) {
        if (!_selectedType.contains(exercise.tipoEsercizio)) {
          return false;
        }
      }

      // Movement pattern filter
      if (_selectedMovementPattern.isNotEmpty) {
        if (!_selectedMovementPattern.contains(exercise.patternMovimento)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Build badge showing custom exercise status: permanent, temporary (days left), or expired
  /// For Premium users (hasUnlimitedExercises=true), just show ⚡ without extra badges
  Widget _buildCustomExerciseBadge(
    CustomExercise customExercise, {
    required bool hasUnlimitedExercises,
  }) {
    final l10n = context.l10n;

    // Determine status and colors
    final bool isExpired = customExercise.isExpired;
    final bool isTemporary = customExercise.isTemporary && !isExpired;

    // Premium users: just show ⚡ (all their exercises are permanent)
    // Also show just ⚡ for permanent exercises when user is Premium
    if (hasUnlimitedExercises || customExercise.isPermanent) {
      // For Premium: clean UI with just lightning bolt
      // For Free with permanent: also clean (they earned the permanent slot)
      return Text('⚡', style: context.textTheme.titleMedium);
    }

    // Badge color based on status (only for Free users with temporary/expired)
    final Color badgeColor;
    final String badgeText;
    final IconData badgeIcon;

    if (isExpired) {
      badgeColor = context.colors.error;
      badgeText = l10n.exerciseExpired;
      badgeIcon = AppIcons.warning;
    } else if (isTemporary) {
      final daysLeft = customExercise.daysRemaining ?? 0;
      badgeColor = daysLeft <= 2
          ? context.colors.warning
          : context.colors.secondary;
      badgeText = l10n.exerciseExpiresInDays(daysLeft);
      badgeIcon = AppIcons.schedule;
    } else {
      // Fallback (shouldn't reach here but safety)
      return Text('⚡', style: context.textTheme.titleMedium);
    }

    // Temporary or Expired badge
    return Semantics(
      label: 'Exercise status: $badgeText',
      button: true,
      child: GestureDetector(
        onTap: () => _showExerciseStatusSheet(customExercise),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚡', style: context.textTheme.titleMedium),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, size: 12, color: badgeColor),
                  const SizedBox(width: 2),
                  Text(
                    badgeText,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
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

  /// Show bottom sheet for expired/temporary exercise actions
  void _showExerciseStatusSheet(CustomExercise customExercise) {
    final l10n = context.l10n;
    final isExpired = customExercise.isExpired;

    ModalService.showSheet(
      context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isExpired ? AppIcons.warning : AppIcons.schedule,
                  color: isExpired
                      ? context.colors.error
                      : context.colors.warning,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    customExercise.displayName,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status description
            Text(
              isExpired
                  ? l10n.exerciseExpiredDescription
                  : l10n.exerciseTemporaryDescription(
                      customExercise.daysRemaining ?? 0,
                    ),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            // Option 1: Watch ad to renew (7 days)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                _handleWatchAdForRenewal(customExercise);
              },
              icon: const Icon(AppIcons.playCircle),
              label: Text(l10n.renewWithAd),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),

            // Option 2: Upgrade to premium
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                context.push('/subscription');
              },
              icon: const Icon(AppIcons.star),
              label: Text(l10n.upgradeForUnlimited),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 8),

            // Cancel
            Semantics(
              label: l10n.cancel,
              button: true,
              child: TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle ad watch for exercise renewal
  Future<void> _handleWatchAdForRenewal(CustomExercise customExercise) async {
    final l10n = context.l10n;

    // TODO: Integrate with actual ad provider (AdMob/Unity Ads)
    // For now, simulate successful ad watch
    try {
      // Show loading indicator
      SnackBarService.showInfo(context, l10n.loadingAd);

      // Simulate ad delay (in production: show rewarded ad)
      await Future.delayed(const Duration(seconds: 2));

      // Call limit service to extend exercise
      final limitService = ref.read(customExerciseLimitServiceProvider);
      await limitService.onAdWatched(customExercise.id);

      // Refresh providers
      ref.invalidate(allCustomExercisesProvider);

      // Show success
      if (mounted) {
        SnackBarService.showSuccess(context, l10n.exerciseRenewed);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, l10n.renewalFailed);
      }
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFocus.clear();
      _selectedMuscleGroups.clear();
      _selectedEquipment.clear();
      _selectedType.clear();
      _selectedMovementPattern.clear();
      _showOnlyCustom = false;
      _showOnlyRecent = false;
      _searchQuery = '';
      _searchController.clear();
      _useFuzzyResults = false;
      _fuzzyResults = [];
    });
    _searchDebouncer.cancel();
  }

  bool _isSmartFilter(String query) {
    return ExerciseSearchService.quickFilters.any(
      (filter) => filter['query'] == query.toLowerCase(),
    );
  }

  void _addSelectedToWorkout() {
    if (_selectedExercises.isEmpty) return;

    if (widget.skipCustomizationOnContinue && widget.onExerciseAdded != null) {
      final selectedExercises = _selectedExercises.toList();

      for (final exercise in selectedExercises) {
        widget.onExerciseAdded!(
          _convertToWorkoutExercise(exercise, initialSetCount: 1),
        );
      }

      SnackBarService.showSuccess(
        context,
        context.l10n.exercisesAddedToWorkout(selectedExercises.length),
      );
      Navigator.of(context).pop();
      return;
    }

    // ✅ Read user's saved counting mode preferences
    final overridesAsync = ref.read(allCountingModeOverridesProvider);
    final Map<String, ExerciseCountingMode> overrides = overridesAsync.when(
      data: (data) => data.map(
        (key, value) => MapEntry(key, ExerciseCountingMode.fromString(value)),
      ),
      loading: () => {},
      error: (_, __) => {},
    );

    // Navigate to customization screen and pass callback + overrides
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseCustomizationScreen(
          selectedExercises: _selectedExercises.toList(),
          onExerciseAdded: widget.onExerciseAdded, // 🔥 FIX: Pass callback
          countingModeOverrides: overrides.isEmpty
              ? null
              : overrides, // ✅ Pass user preferences
        ),
      ),
    );
  }

  void _selectExercises() {
    if (_selectedExercises.isEmpty) return;

    // Return selected exercises directly to caller (for superset builder)
    Navigator.of(context).pop(_selectedExercises.toList());
  }

  /// ✅ FIX #2: Convert SupersetTemplate to workout and add to current workout
  Future<void> _handleUseTemplate(SupersetTemplate template) async {
    try {
      // 1. Get all exercises from database
      final repository = ref.read(hybridExerciseRepositoryProvider);
      final allExercises = await repository.getAllExercises();

      // 2. Find exercises matching template names
      final selectedExercises = <Exercise>[];
      for (final name in template.exerciseNames) {
        final match = allExercises.firstWhereOrNull(
          (ex) => ex.nome.toLowerCase() == name.toLowerCase(),
        );
        if (match != null) {
          selectedExercises.add(match);
        }
      }

      // Verify we found all exercises
      if (selectedExercises.length != template.exerciseNames.length) {
        if (!mounted) return;
        SnackBarService.showError(context, context.l10n.someExercisesNotFound);
        return;
      }

      // 3. Parse reps range to get target reps (take first number from "10-12" or "8-10")
      final repsMatch = RegExp(r'(\d+)').firstMatch(template.repsRange);
      final targetReps = repsMatch != null
          ? int.parse(repsMatch.group(1)!)
          : 10;

      // 4. Create SupersetRounds
      final rounds = List.generate(
        template.rounds,
        (index) => SupersetRound.uniform(
          roundNumber: index + 1,
          targetReps: targetReps,
          targetWeight: null, // User will set weight during workout
          exerciseIds: selectedExercises.map((e) => e.id).toList(),
        ),
      );

      // 5. Create SupersetConfiguration
      final config = SupersetConfiguration(
        name: template.name,
        exercises: selectedExercises,
        rounds: rounds,
        restBetweenExercises: template.restAfterSuperset,
        restAfterRound: template.restAfterRound,
      );

      // 6. Convert to SupersetExercise
      final supersetExercise =
          SupersetConverter.configurationToSupersetExercise(config);

      // 7. Add to workout
      if (widget.onExerciseAdded != null) {
        widget.onExerciseAdded!(supersetExercise);
      }

      // 8. Close modal and show success
      if (!mounted) return;
      Navigator.of(context).pop();
      SnackBarService.showSuccess(
        context,
        '✅ ${context.l10n.templateAddedToWorkout}',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error using template: $e');
      }
      if (!mounted) return;
      SnackBarService.showError(context, context.l10n.errorAddingTemplate);
    }
  }

  WorkoutExercise.Exercise _convertToWorkoutExercise(
    Exercise exercise, {
    int initialSetCount = 3,
  }) {
    // ✅ Check for user-saved counting mode override
    final overridesAsync = ref.read(allCountingModeOverridesProvider);
    ExerciseCountingMode? override;
    overridesAsync.whenData((data) {
      final savedMode = data[exercise.id];
      if (savedMode != null) {
        override = ExerciseCountingMode.fromString(savedMode);
      }
    });

    // Use centralized converter with optional override
    return ExerciseConverter.fromDatabaseExercise(
      exercise,
      countingModeOverride: override,
      initialSetCount: initialSetCount,
    );
  }

  void _showExerciseHistorySheet(Exercise exercise) {
    ModalService.showSheet(
      context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => ExerciseHistoryBottomSheet(
        exerciseName: exercise.nome,
        exerciseId: exercise.id,
      ),
    );
  }

  void _showExerciseQuickActionsSheet(
    Exercise exercise, {
    bool isCustom = false,
  }) {
    ModalService.showSheet(
      context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                exercise.nome,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _buildCompactMetadataLine(exercise),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(AppIcons.preview),
                title: Text(context.l10n.preview),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showExerciseOptionsModal(exercise);
                },
              ),
              if (!isCustom && !widget.selectionMode)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.copy),
                  title: Text(context.l10n.createVariant),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showCreateVariantSheet(context, exercise);
                  },
                ),
              if (!widget.selectionMode)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.thumbDown),
                  title: Text(context.l10n.reducePriority),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _handleNegativeFeedback(exercise);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseOptionsModal(Exercise exercise) {
    // Converto l'esercizio del database in un esercizio workout per il modal
    final workoutExercise = _convertToWorkoutExercise(exercise);
    final locale = ref.read(localeProvider);

    ExerciseOptionsModal.show(
      context,
      workoutExercise,
      onHistory: () {
        _showExerciseHistorySheet(exercise);
      },
      imageUrl: exercise.imageUrl,
      databaseExercise: exercise,
      languageCode: locale.languageCode,
    );
  }

  /// Show custom exercise creation sheet (pure custom)
  Future<void> _showCreateCustomSheet(
    BuildContext context,
    String initialName,
  ) async {
    if (!mounted) return;

    final result = await CustomExerciseFormSheet.show(
      context,
      onSave: (exercise) async {
        final repository = ref.read(customExerciseRepositoryProvider);
        await repository.save(exercise);
      },
    );

    if (result != null && mounted && context.mounted) {
      SnackBarService.showSuccess(
        context,
        '${result.displayName} ${context.l10n.addedSuccessfully}',
      );
    }
  }

  /// Show custom exercise creation sheet (variant of base)
  Future<void> _showCreateVariantSheet(
    BuildContext context,
    Exercise base,
  ) async {
    if (!mounted) return;

    final result = await CustomExerciseFormSheet.show(
      context,
      baseExercise: base,
      onSave: (exercise) async {
        final repository = ref.read(customExerciseRepositoryProvider);
        await repository.save(exercise);
      },
    );

    if (result != null && mounted && context.mounted) {
      SnackBarService.showSuccess(
        context,
        '${result.displayName} ${context.l10n.addedSuccessfully}',
      );
    }
  }

  Future<void> _showMuscleQuickFilterSheet() async {
    final exercisesAsync = ref.read(jsonExerciseRepositoryProvider);
    final exercises = exercisesAsync.value ?? [];

    final muscleCodes =
        exercises
            .expand((exercise) => exercise.focus)
            .map(_normalizedMuscleCode)
            .where((code) => code.isNotEmpty)
            .toSet()
            .toList()
          ..sort(
            (a, b) =>
                MuscleAbbreviationMapper.codeToDisplayName(
                  a,
                  italian: _isItalian,
                ).compareTo(
                  MuscleAbbreviationMapper.codeToDisplayName(
                    b,
                    italian: _isItalian,
                  ),
                ),
          );

    await ModalService.showSheet(
      context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.colors.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _musclesLabel(),
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: context.screenHeight * 0.42,
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: muscleCodes.map((code) {
                            final label =
                                MuscleAbbreviationMapper.codeToDisplayName(
                                  code,
                                  italian: _isItalian,
                                );
                            final isSelected = _selectedMuscleGroups.contains(
                              code,
                            );
                            return FilterChip(
                              label: Text(label),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedMuscleGroups.add(code);
                                  } else {
                                    _selectedMuscleGroups.remove(code);
                                  }
                                });
                                setModalState(() {});
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_selectedMuscleGroups.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedMuscleGroups.clear();
                              });
                              setModalState(() {});
                            },
                            child: Text(context.l10n.reset),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text(context.l10n.apply),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Filter Bottom Sheet Widget - Solo attrezzatura
class ExerciseFilters {
  const ExerciseFilters({
    this.muscleGroups = const [],
    this.equipment = const [],
    this.exerciseType = const [],
    this.movementPattern = const [],
  });

  final List<String> muscleGroups;
  final List<String> equipment;
  final List<String> exerciseType;
  final List<String> movementPattern;

  bool get isEmpty =>
      muscleGroups.isEmpty &&
      equipment.isEmpty &&
      exerciseType.isEmpty &&
      movementPattern.isEmpty;

  int get activeCount {
    int count = 0;
    if (muscleGroups.isNotEmpty) count++;
    if (equipment.isNotEmpty) count++;
    if (exerciseType.isNotEmpty) count++;
    if (movementPattern.isNotEmpty) count++;
    return count;
  }

  ExerciseFilters copyWith({
    List<String>? muscleGroups,
    List<String>? equipment,
    List<String>? exerciseType,
    List<String>? movementPattern,
  }) {
    return ExerciseFilters(
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipment: equipment ?? this.equipment,
      exerciseType: exerciseType ?? this.exerciseType,
      movementPattern: movementPattern ?? this.movementPattern,
    );
  }
}

class _ExerciseFilterSheet extends StatefulWidget {
  const _ExerciseFilterSheet({
    required this.exercises,
    required this.currentFilters,
    required this.onApply,
    required this.onSave,
  });
  final List<Exercise> exercises;
  final ExerciseFilters currentFilters;
  final ValueChanged<ExerciseFilters> onApply;
  final ValueChanged<ExerciseFilters> onSave;

  @override
  State<_ExerciseFilterSheet> createState() => _ExerciseFilterSheetState();
}

class _ExerciseFilterSheetState extends State<_ExerciseFilterSheet> {
  late List<String> _tempMuscleGroups;
  late List<String> _tempEquipment;
  late List<String> _tempExerciseType;
  late List<String> _tempMovementPattern;

  @override
  void initState() {
    super.initState();
    _tempMuscleGroups = List.from(widget.currentFilters.muscleGroups);
    _tempEquipment = List.from(widget.currentFilters.equipment);
    _tempExerciseType = List.from(widget.currentFilters.exerciseType);
    _tempMovementPattern = List.from(widget.currentFilters.movementPattern);
  }

  ExerciseFilters _buildFilters() => ExerciseFilters(
    muscleGroups: List.from(_tempMuscleGroups),
    equipment: List.from(_tempEquipment),
    exerciseType: List.from(_tempExerciseType),
    movementPattern: List.from(_tempMovementPattern),
  );

  bool get _hasAnySelection =>
      _tempMuscleGroups.isNotEmpty ||
      _tempEquipment.isNotEmpty ||
      _tempExerciseType.isNotEmpty ||
      _tempMovementPattern.isNotEmpty;

  List<String> _extractOptions(String Function(Exercise) getter) {
    return widget.exercises
        .map(getter)
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> _extractMuscleOptions(BuildContext context) {
    final options = widget.exercises
        .expand((exercise) => exercise.focus)
        .map(MuscleAbbreviationMapper.normalizeToCanonicalId)
        .where((code) => code.isNotEmpty)
        .toSet()
        .toList();

    options.sort(
      (a, b) =>
          MuscleAbbreviationMapper.codeToDisplayName(
            a,
            italian: Localizations.localeOf(context).languageCode == 'it',
          ).compareTo(
            MuscleAbbreviationMapper.codeToDisplayName(
              b,
              italian: Localizations.localeOf(context).languageCode == 'it',
            ),
          ),
    );

    return options;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final muscleOptions = _extractMuscleOptions(context);
    final equipmentOptions = _extractOptions((e) => e.attrezzatura);
    final typeOptions = _extractOptions((e) => e.tipoEsercizio);
    final patternOptions = _extractOptions((e) => e.patternMovimento);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(AppIcons.filter, color: context.colors.primary),
                  const SizedBox(width: 12),
                  Text(
                    l10n.filters,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_hasAnySelection)
                    Semantics(
                      label: l10n.reset,
                      button: true,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _tempMuscleGroups.clear();
                            _tempEquipment.clear();
                            _tempExerciseType.clear();
                            _tempMovementPattern.clear();
                          });
                        },
                        icon: const Icon(AppIcons.clear),
                        label: Text(l10n.reset),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Filter sections
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFilterSection(
                      title:
                          Localizations.localeOf(context).languageCode == 'it'
                          ? 'Muscoli'
                          : 'Muscles',
                      options: muscleOptions,
                      selected: _tempMuscleGroups,
                      optionLabelBuilder: (option) =>
                          MuscleAbbreviationMapper.codeToDisplayName(
                            option,
                            italian:
                                Localizations.localeOf(context).languageCode ==
                                'it',
                          ),
                    ),
                    _buildFilterSection(
                      title: l10n.equipment,
                      options: equipmentOptions,
                      selected: _tempEquipment,
                      showEquipmentIcons: true,
                    ),
                    _buildFilterSection(
                      title: l10n.exerciseType,
                      options: typeOptions,
                      selected: _tempExerciseType,
                    ),
                    _buildFilterSection(
                      title: l10n.movementPattern,
                      options: patternOptions,
                      selected: _tempMovementPattern,
                    ),
                  ],
                ),
              ),
            ),

            // Dual CTA
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        widget.onApply(_buildFilters());
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.apply),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onSave(_buildFilters());
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        l10n.saveAsDefault,
                        textAlign: TextAlign.center,
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

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required List<String> selected,
    bool showEquipmentIcons = false,
    String Function(String option)? optionLabelBuilder,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();

    final count = selected.length;
    final subtitle = count > 0 ? ' ($count)' : '';

    return ExpansionTile(
      title: Text(
        '$title$subtitle',
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      initiallyExpanded: selected.isNotEmpty,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(
                optionLabelBuilder?.call(option) ?? option,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              avatar: showEquipmentIcons
                  ? _buildEquipmentAvatar(option, isSelected: isSelected)
                  : null,
              selected: isSelected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                });
              },
              backgroundColor: context.colors.surface,
              selectedColor: context.colors.primaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEquipmentAvatar(String equipment, {required bool isSelected}) {
    return Opacity(
      opacity: isSelected ? 1 : 0.95,
      child: EquipmentIconBadge(equipment: equipment, size: 16),
    );
  }
}
