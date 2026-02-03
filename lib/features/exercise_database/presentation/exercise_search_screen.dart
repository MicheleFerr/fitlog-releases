import 'dart:async';

import 'package:collection/collection.dart';

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
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart'
    as WorkoutExercise;
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_options_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_history_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_customization_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/exercise_search_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/missing_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/widgets/custom_exercise_form_sheet.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/providers/custom_exercise_providers.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/i_exercise_preferences.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/superset_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_template_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_template_preview_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_converter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
// Exercise search tutorial REMOVED - UX 2025 analysis: search UI is standard pattern

class ExerciseSearchScreen extends ConsumerStatefulWidget {
  // New: Just select and return exercise template (for DropSet/Rest-Pause)

  const ExerciseSearchScreen({
    super.key,
    this.onExerciseAdded,
    this.multiSelectMode = false,
    this.selectionMode = false,
    this.showSupersetTemplates, // ✅ FIX: Control when to show superset templates
  });
  final Function(WorkoutExercise.Exercise)?
  onExerciseAdded; // 🔥 FIX: Add callback parameter
  final bool multiSelectMode; // New: Support multi-select for superset builder
  final bool selectionMode;
  final bool?
  showSupersetTemplates; // ✅ FIX: null = auto (true for multiSelect, false for single)

  @override
  ConsumerState<ExerciseSearchScreen> createState() =>
      _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends ConsumerState<ExerciseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<Exercise> _selectedExercises = <Exercise>{};

  // Widget keys (used for widget identification)
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _filterButtonKey = GlobalKey();
  final GlobalKey _exerciseCardKey = GlobalKey();
  final GlobalKey _addButtonKey = GlobalKey();

  String _searchQuery = '';
  List<String> _selectedFocus = [];
  final List<String> _selectedMuscleGroups = [];
  List<String> _selectedEquipment = [];
  final List<String> _selectedDifficulty = [];
  String? _selectedType;

  bool _showSearch =
      true; // P1-3 FIX: Show search by default for faster logging

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
    // Exercise search tutorial removed - UX 2025: search UI is intuitive standard pattern
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose(); // 🔐 SECURITY: Proper cleanup
    super.dispose();
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
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        // Clear search when closing
        _searchController.clear();
        _searchQuery = '';
        _useFuzzyResults = false;
        _fuzzyResults = [];
        _searchDebouncer.cancel();
      }
    });
  }

  /// Get count of active filters
  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedDifficulty.isNotEmpty) count++;
    if (_selectedEquipment.isNotEmpty) count++;
    if (_selectedMuscleGroups.isNotEmpty) count++;
    if (_selectedFocus.isNotEmpty) count++;
    if (_selectedType != null) count++;
    return count;
  }

  /// Show filter bottom sheet
  Future<void> _showFilterBottomSheet() async {
    final exercisesAsync = ref.read(jsonExerciseRepositoryProvider);
    final exercises = exercisesAsync.value ?? [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface.withValues(alpha: 0),
      builder: (sheetContext) => _FilterBottomSheet(
        exercises: exercises,
        selectedDifficulty: _selectedDifficulty,
        selectedEquipment: _selectedEquipment,
        onApply: (difficulty, equipment) {
          setState(() {
            _selectedDifficulty.clear();
            _selectedDifficulty.addAll(difficulty);
            _selectedEquipment.clear();
            _selectedEquipment.addAll(equipment);
          });
        },
        onReset: () {
          setState(() {
            _clearAllFilters();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use fuzzy search for active queries, fallback to JSON repository for browsing
    final exercisesAsync = ref.watch(jsonExerciseRepositoryProvider);
    final l10n = context.l10n;
    final activeFilterCount = _getActiveFilterCount();

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.searchExercises} (${_selectedExercises.length})'),
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
          if (_selectedExercises.isNotEmpty)
            Semantics(
              label: widget.multiSelectMode
                  ? 'Select Exercises'
                  : l10n.addToWorkout,
              button: true,
              enabled: true,
              child: IconButton(
                icon: Icon(
                  widget.multiSelectMode ? AppIcons.check : AppIcons.add,
                ),
                onPressed: widget.multiSelectMode
                    ? _selectExercises
                    : _addSelectedToWorkout,
                tooltip: widget.multiSelectMode
                    ? 'Select Exercises'
                    : l10n.addToWorkout,
              ),
            ),
          // Filter button with badge
          Stack(
            children: [
              Semantics(
                label: l10n.filters,
                button: true,
                child: IconButton(
                  key: _filterButtonKey,
                  icon: const Icon(AppIcons.filterListOutlined),
                  onPressed: _showFilterBottomSheet,
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
      body: Column(
        children: [
          // Search Bar (shown when FAB is tapped)
          if (_showSearch) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              color: context.colors.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchExercisesHint,
                  // ✅ FIX: Icona search sempre visibile (mai nascosta dal loader)
                  prefixIcon: const SemanticIcon(
                    icon: AppIcons.search,
                    semanticLabel: 'Search',
                  ),
                  // ✅ FIX: Loader a destra quando carica, altrimenti X per cancellare
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: LoadingIndicator(size: 20),
                        )
                      : (_searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const SemanticIcon(
                                  icon: AppIcons.clear,
                                  semanticLabel: 'Clear',
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _useFuzzyResults = false;
                                    _fuzzyResults = [];
                                  });
                                  _searchDebouncer
                                      .cancel(); // 🔐 SECURITY: Cancel pending search
                                },
                              )
                            : null),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.colors.primary,
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: context.colors.surface,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                  // Trigger fuzzy search
                  _performFuzzySearch(value);
                },
              ),
            ),
          ],

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

      // Selected Exercises Count
      bottomNavigationBar: _selectedExercises.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedExercises.length} ${l10n.exercisesSelected}',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      key: _addButtonKey, // Tutorial target
                      onPressed: widget.multiSelectMode
                          ? _selectExercises
                          : _addSelectedToWorkout,
                      icon: Icon(
                        widget.multiSelectMode ? AppIcons.check : AppIcons.add,
                      ),
                      label: Text(
                        widget.multiSelectMode ? l10n.confirm : l10n.add,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,

      // FAB for search (always visible)
      floatingActionButton: FloatingActionButton(
        key: _searchBarKey, // Tutorial target for search
        onPressed: _toggleSearch,
        tooltip: _showSearch ? l10n.close : l10n.search,
        child: Icon(_showSearch ? AppIcons.close : AppIcons.search),
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
            nome: custom.nome,
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

    // Merge: custom exercises first, then catalog
    final allExercises = [...customAsExercises, ...exercises];

    // P1-3 FIX: Get recent/frequent exercises for quick access
    final recentExercises = _searchQuery.isEmpty
        ? allExercises
              .where(
                (e) =>
                    _frequentExerciseIds.contains(e.id) ||
                    _trendingExerciseIds.contains(e.id),
              )
              .take(5)
              .toList()
        : <Exercise>[];

    return Column(
      children: [
        // Recommended Superset Templates (when no search)
        // ✅ FIX: Show only for superset mode, not for single exercise selection
        if (_searchQuery.isEmpty && _shouldShowSupersetTemplates()) ...[
          _buildRecommendedTemplatesSection(),
        ],

        // P1-3 FIX: Show recent exercises for quick access (when no search)
        if (recentExercises.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(AppIcons.history, size: 16, color: context.colors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.recentExercises,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: recentExercises.length,
              itemBuilder: (context, index) {
                final exercise = recentExercises[index];
                final isSelected = _selectedExercises.contains(exercise);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    avatar: isSelected
                        ? Icon(
                            AppIcons.check,
                            size: 16,
                            color: context.colors.onPrimary,
                          )
                        : null,
                    label: Text(
                      exercise.nome,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: isSelected ? context.colors.onPrimary : null,
                      ),
                    ),
                    backgroundColor: isSelected ? context.colors.primary : null,
                    onPressed: () {
                      // Selection mode: return and close
                      if (widget.selectionMode) {
                        Navigator.of(context).pop(exercise);
                        return;
                      }
                      // Toggle selection
                      setState(() {
                        if (_selectedExercises.contains(exercise)) {
                          _selectedExercises.remove(exercise);
                        } else {
                          _selectedExercises.add(exercise);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 16),
        ],

        // Results count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Text(
            '${allExercises.length} ${l10n.exercisesFound}',
            style: context.textTheme.bodySmall,
          ),
        ),

        // Exercise List + Missing Exercise Widget
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('exercise_search_list'),
            itemCount:
                allExercises.length + 1, // +1 for missing exercise widget
            itemBuilder: (context, index) {
              // Show missing exercise widget as last item
              if (index == allExercises.length) {
                return _buildMissingExerciseWidget();
              }

              final exercise = allExercises[index];
              final isSelected = _selectedExercises.contains(exercise);
              final isCustom = index < customAsExercises.length;
              // Get original CustomExercise for status info (if custom)
              final customExercise = isCustom
                  ? customExerciseMap[exercise.id]
                  : null;

              // Add tutorial key to first exercise card
              return _buildExerciseCard(
                exercise,
                isSelected,
                isCustom: isCustom,
                customExercise: customExercise,
                hasUnlimitedExercises: hasUnlimitedExercises,
                tutorialKey: index == 0 ? _exerciseCardKey : null,
              );
            },
          ),
        ),
      ],
    );
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
                '(Smart Search)',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        // Fuzzy Exercise List + Missing Exercise Widget
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('exercise_fuzzy_search_list'),
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
                  l10n.exerciseNotFound,
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

    // Se c'è un'immagine, mostra quella, altrimenti l'icona
    if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: context.colors.surfaceContainerHighest,
        radius: 20,
        child: ClipOval(
          child: Image.network(
            exercise.imageUrl!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback all'icona se l'immagine non carica
              return Container(
                width: 40,
                height: 40,
                color: context.colors.surfaceContainerHighest,
                child: Center(
                  child: Text(
                    exercise.attrezzaturaIcon,
                    style: context.textTheme.titleMedium,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 40,
                height: 40,
                color: context.colors.surfaceContainerHighest,
                child: const Center(child: LoadingIndicator(size: 16)),
              );
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: context.colors.surfaceContainerHighest,
        child: Text(exercise.attrezzaturaIcon),
      );
    }
  }

  Widget _buildExerciseCard(
    Exercise exercise,
    bool isSelected, {
    bool isCustom = false,
    CustomExercise? customExercise,
    bool hasUnlimitedExercises = false,
    GlobalKey? tutorialKey,
  }) {
    return Card(
      key: tutorialKey,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Stack(
        children: [
          ListTile(
            leading: _buildExerciseLeading(exercise, isSelected),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.nome,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                // Custom exercise status badge
                if (isCustom && customExercise != null)
                  _buildCustomExerciseBadge(
                    customExercise,
                    hasUnlimitedExercises: hasUnlimitedExercises,
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.focusDisplayName),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          exercise.difficolta,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exercise.difficolta,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: _getDifficultyColor(exercise.difficolta),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exercise.attrezzatura,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Create variant button for catalog exercises
                if (!isCustom && !widget.selectionMode)
                  Semantics(
                    label: context.l10n.createVariant,
                    button: true,
                    child: IconButton(
                      icon: const Icon(AppIcons.copy),
                      tooltip: context.l10n.createVariant,
                      onPressed: () => _showCreateVariantSheet(context, exercise),
                      iconSize: 20,
                    ),
                  ),
                const SizedBox(width: 8),
                // Selection indicator
                isSelected
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
              ],
            ),
            onTap: () {
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
            onLongPress: widget.selectionMode
                ? null
                : () => _showExerciseOptionsModal(exercise),
          ),
        ],
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
                            'Frequente',
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
                            'Recente',
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
            Text(exercise.focusDisplayName),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(
                      exercise.difficolta,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise.difficolta,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: _getDifficultyColor(exercise.difficolta),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(exercise.attrezzatura, style: context.textTheme.bodySmall),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: isSelected || widget.selectionMode ? 24 : 56,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Negative feedback button (only if not selected)
              if (!isSelected && !widget.selectionMode)
                Semantics(
                  label: 'Hide exercise',
                  button: true,
                  child: InkWell(
                    onTap: () => _handleNegativeFeedback(exercise),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: SemanticIcon(
                        icon: AppIcons.close,
                        semanticLabel: 'Close',
                        size: AppIconSize.tiny,
                        color: context.colors.error.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              // Spacer
              if (!isSelected && !widget.selectionMode)
                const SizedBox(width: 4),
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
        onLongPress: widget.selectionMode
            ? null
            : () => _showExerciseOptionsModal(exercise),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;
    return ListView(
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

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    return exercises.where((exercise) {
      // Search query filter - skip if it's a smart filter
      // (improved search already handled it)
      if (_searchQuery.isNotEmpty && !_isSmartFilter(_searchQuery)) {
        final query = _searchQuery.toLowerCase();
        if (!exercise.nome.toLowerCase().contains(query) &&
            !exercise.focusDisplayName.toLowerCase().contains(query) &&
            !exercise.attrezzatura.toLowerCase().contains(query)) {
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

      // Difficulty filter
      if (_selectedDifficulty.isNotEmpty) {
        if (!_selectedDifficulty.contains(exercise.difficolta)) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != null) {
        if (exercise.tipoEsercizio != _selectedType) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return context.colors.success;
      case 'intermedio':
        return context.colors.warning;
      case 'avanzato':
        return context.colors.error;
      default:
        return context.colors.surfaceContainerHighest;
    }
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

    showModalBottomSheet(
      context: context,
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
                    customExercise.nome,
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
                child: Text(l10n.cancel),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
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
      _selectedDifficulty.clear();
      _selectedType = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  bool _isAllFiltersEmpty() {
    return _selectedFocus.isEmpty &&
        _selectedMuscleGroups.isEmpty &&
        _selectedEquipment.isEmpty &&
        _selectedDifficulty.isEmpty &&
        _selectedType == null &&
        _searchQuery.isEmpty;
  }

  bool _isSmartFilter(String query) {
    return ExerciseSearchService.quickFilters.any(
      (filter) => filter['query'] == query.toLowerCase(),
    );
  }

  void _applySmartFilter(String query) {
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
    });
    // 🔥 FIX: Update provider to trigger improved search
    ref.read(exerciseSearchQueryProvider.notifier).state = query;
  }

  void _addSelectedToWorkout() {
    if (_selectedExercises.isEmpty) return;

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
        restBetweenExercises: template.restBetween,
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

  WorkoutExercise.Exercise _convertToWorkoutExercise(Exercise exercise) {
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
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surface.withValues(alpha: 0),
          builder: (context) => ExerciseHistoryBottomSheet(
            exerciseName: exercise.nome,
            exerciseId: exercise.id,
          ),
        );
      },
      imageUrl: exercise.imageUrl,
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
        '${result.nome} ${context.l10n.addedSuccessfully}',
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
        '${result.nome} ${context.l10n.addedSuccessfully}',
      );
    }
  }
}

/// Filter Bottom Sheet Widget
class _FilterBottomSheet extends StatefulWidget {
  final List<Exercise> exercises;
  final List<String> selectedDifficulty;
  final List<String> selectedEquipment;
  final Function(List<String> difficulty, List<String> equipment) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    required this.exercises,
    required this.selectedDifficulty,
    required this.selectedEquipment,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late List<String> _tempDifficulty;
  late List<String> _tempEquipment;

  @override
  void initState() {
    super.initState();
    _tempDifficulty = List.from(widget.selectedDifficulty);
    _tempEquipment = List.from(widget.selectedEquipment);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final equipmentOptions =
        widget.exercises.map((e) => e.attrezzatura).toSet().toList()..sort();

    final difficultyOptions =
        widget.exercises.map((e) => e.difficolta).toSet().toList()..sort();

    return Container(
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
                  Icon(
                    AppIcons.filterListOutlined,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.filters,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    label: l10n.reset,
                    button: true,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _tempDifficulty.clear();
                          _tempEquipment.clear();
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

            // Filter content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Difficulty Section
                    Text(
                      l10n.difficulty,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: difficultyOptions.map((difficulty) {
                        final isSelected = _tempDifficulty.contains(difficulty);
                        return FilterChip(
                          label: Text(difficulty),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _tempDifficulty.add(difficulty);
                              } else {
                                _tempDifficulty.remove(difficulty);
                              }
                            });
                          },
                          backgroundColor: context.colors.surface,
                          selectedColor: context.colors.primaryContainer,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Equipment Section
                    Text(
                      l10n.equipment,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: equipmentOptions.map((equipment) {
                        final isSelected = _tempEquipment.contains(equipment);
                        return FilterChip(
                          label: Text(equipment),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _tempEquipment.add(equipment);
                              } else {
                                _tempEquipment.remove(equipment);
                              }
                            });
                          },
                          backgroundColor: context.colors.surface,
                          selectedColor: context.colors.primaryContainer,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onReset();
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.reset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        widget.onApply(_tempDifficulty, _tempEquipment);
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.apply),
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
