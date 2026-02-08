import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/firebase_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/swipeable_template_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/create_template_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/edit_template_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/weight_recovery_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/previous_workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/weight_recovery_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/adaptive_banner_ad.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:flutter/foundation.dart';
// GDPR Consent Management
import 'package:gymbro_flutter_new/shared/domain/privacy/privacy_manager.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/privacy/consent_dialog.dart';
// Secure Logging
import 'package:gymbro_flutter_new/shared/domain/services/secure_logger.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/superset_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_template_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_template_preview_sheet.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/superset_template_event_tracker.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';

class WorkoutTemplatesScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  ConsumerState<WorkoutTemplatesScreen> createState() =>
      _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState extends ConsumerState<WorkoutTemplatesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Focus nodes for keyboard navigation (WCAG 2.1.1)
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _createButtonFocusNode = FocusNode();
  final FocusNode _syncButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Track tab changes for Superset tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          !_tabController.previousIndex.isFinite) {
        return;
      }

      // Track when Superset tab (index 1) is opened
      if (_tabController.index == 1) {
        final analytics = ref.read(analyticsServiceProvider);
        final tracker = SupersetTemplateEventTracker(analytics);
        tracker.trackSupersetTabOpened(source: 'tab');
      }
    });

    _checkAndShowConsentDialog();
  }

  /// Check if user needs to provide GDPR consent
  /// Shows consent dialog if:
  /// - User hasn't provided consent yet
  /// - Privacy policy version changed
  /// - Consent is older than 12 months
  Future<void> _checkAndShowConsentDialog() async {
    // Wait for first frame to avoid showing dialog during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasProvided = await PrivacyManager.hasProvidedConsent();
      final needsUpdate = await PrivacyManager.needsConsentUpdate();

      if (!hasProvided || needsUpdate) {
        if (mounted) {
          await showConsentDialog(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    // Dispose focus nodes
    _searchFocusNode.dispose();
    _createButtonFocusNode.dispose();
    _syncButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutTemplates),
        centerTitle: true,
        leading: Semantics(
          label: l10n.back,
          button: true,
          hint: l10n.backHint,
          child: IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.back,
              semanticLabel: 'Back',
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/');
              }
            },
          ),
        ),
        actions: [
          // Indicatore stato sync
          Consumer(
            builder: (context, ref, child) {
              // PERFORMANCE FIX: Selective watching to reduce rebuilds
              final userId = ref.watch(
                authStateProvider.select((s) => s.value?.uid),
              );
              if (userId != null) {
                // Only watch isSyncing state, not entire object
                final isSyncing = ref.watch(
                  syncStatusProvider.select((s) => s.isSyncing),
                );
                final firebaseIsSyncing = ref.watch(
                  firebaseTemplateNotifierProvider.select((s) => s.isSyncing),
                );

                return Semantics(
                  label: l10n.syncStatus,
                  button: true,
                  hint: l10n.syncStatusHint,
                  child: IconButton(
                    focusNode: _syncButtonFocusNode,
                    icon: Stack(
                      children: [
                        const SemanticIcon(
                          icon: AppIcons.cloud,
                          semanticLabel: 'Cloud',
                        ),
                        if (firebaseIsSyncing)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        if (firebaseState.hasOfflineChanges)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: context.colors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () => _showSyncInfo(context, syncStatus),
                    tooltip: syncStatus,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Semantics(
            label: l10n.createTemplate,
            button: true,
            hint: l10n.createTemplateHint,
            child: IconButton(
              focusNode: _createButtonFocusNode,
              icon: const SemanticIcon(
                icon: AppIcons.add,
                semanticLabel: 'Add',
              ),
              onPressed: () => _showCreateTemplateModal(context),
              tooltip: l10n.createTemplate,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: l10n.allExercises.replaceAll(' Exercises', ''),
              icon: const SemanticIcon(
                icon: AppIcons.list,
                semanticLabel: 'List',
              ),
            ),
            const Tab(
              text: 'Superset',
              icon: SemanticIcon(
                icon: AppIcons.link,
                semanticLabel: 'Link',
              ),
            ),
            Tab(
              text: l10n.popularTemplates,
              icon: const SemanticIcon(
                icon: AppIcons.trendUp,
                semanticLabel: 'Trend up',
              ),
            ),
            Tab(
              text: l10n.myTemplates,
              icon: const SemanticIcon(
                icon: AppIcons.person,
                semanticLabel: 'Profile',
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra di ricerca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: context.l10n.workoutTemplateSearchHint,
                prefixIcon: const SemanticIcon(
                  icon: AppIcons.search,
                  semanticLabel: 'Search',
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const SemanticIcon(
                          icon: AppIcons.clear,
                          semanticLabel: 'Clear',
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(templateSearchQueryProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
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
              ),
              onChanged: (value) {
                ref.read(templateSearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Contenuto delle tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTemplatesTab(),
                _buildSupersetTemplatesTab(),
                _buildPopularTemplatesTab(),
                _buildMyTemplatesTab(),
              ],
            ),
          ),

          // 📱 Banner Ad in fondo
          AdaptiveBannerAd(adUnitId: AdMobConfig.bannerSettings, height: 60),
        ],
      ),
    );
  }

  Widget _buildAllTemplatesTab() {
    final searchQuery = ref.watch(templateSearchQueryProvider);

    if (searchQuery.isEmpty) {
      // LEGACY SYSTEM: Usa il repository legacy
      final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

      return templatesAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
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
              Text(context.l10n.erroreError),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(allWorkoutTemplatesProvider),
                child: Text(context.l10n.workoutTemplateRetry),
              ),
            ],
          ),
        ),
        data: (templates) => _buildTemplatesList(templates),
      );
    } else {
      final searchResultsAsync = ref.watch(templateSearchResultsProvider);

      return searchResultsAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(child: Text(context.l10n.erroreError)),
        data: (templates) => _buildTemplatesList(templates),
      );
    }
  }

  Widget _buildPopularTemplatesTab() {
    // LEGACY SYSTEM: Usa popularTemplatesProvider
    final popularTemplatesAsync = ref.watch(popularTemplatesProvider);

    return popularTemplatesAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(child: Text(context.l10n.erroreError)),
      data: (templates) {
        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
                  icon: AppIcons.trendUp,
                  semanticLabel: 'Trend up',
                  size: AppIconSize.medium,
                  color: context.colors.surfaceContainerHighest,
                ),
                const SizedBox(height: 16),
                Text(context.l10n.workoutTemplateNoPopularYet),
                const SizedBox(height: 8),
                Text(
                  context.l10n.workoutTemplateMostUsedWillAppear,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return _buildTemplatesList(templates);
      },
    );
  }

  Widget _buildMyTemplatesTab() {
    // FIX: Usa lo stesso provider che funziona in WorkoutScreen
    final customTemplatesAsync = ref.watch(customWorkoutTemplatesProvider);

    debugPrint(
      '🔍 MyTemplatesTab - Using customWorkoutTemplatesProvider (same as WorkoutScreen)',
    );

    // customWorkoutTemplatesProvider returns WorkoutTemplate directly (legacy system)

    return customTemplatesAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(child: Text(context.l10n.erroreError)),
      data: (templates) {
        debugPrint(
          '🔍 MyTemplatesTab - Got ${templates.length} templates from customWorkoutTemplatesProvider',
        );
        for (final template in templates) {
          debugPrint(
            '  - ${template.name}: isCustom=${template.isCustom}, id=${template.id}',
          );
        }

        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
                  icon: AppIcons.workout,
                  semanticLabel: 'Workout',
                  size: AppIconSize.medium,
                  color: context.colors.surfaceContainerHighest,
                ),
                const SizedBox(height: 16),
                Text(context.l10n.workoutTemplateNoCustom),
                const SizedBox(height: 8),
                Text(
                  context.l10n.workoutTemplateCreateFirstCustom,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showCreateTemplateModal(context),
                  icon: const SemanticIcon(
                    icon: AppIcons.add,
                    semanticLabel: 'Add',
                  ),
                  label: Text(context.l10n.creaTemplate),
                ),
              ],
            ),
          );
        }

        return _buildTemplatesList(templates);
      },
    );
  }

  Widget _buildSupersetTemplatesTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Recommended for You section
        _buildSupersetSection(
          title: context.l10n.recommendedForYou,
          icon: AppIcons.star,
          provider: recommendedSupersetTemplatesProvider,
        ),

        const SizedBox(height: 24),

        // Evidence-Based section
        _buildSupersetSection(
          title: context.l10n.evidenceBased,
          icon: AppIcons.science,
          provider: evidenceBasedSupersetTemplatesProvider,
        ),

        const SizedBox(height: 24),

        // Time-Efficient section
        _buildSupersetSection(
          title: context.l10n.timeEfficient,
          icon: AppIcons.timer,
          provider: timeEfficientSupersetTemplatesProvider,
        ),

        const SizedBox(height: 24),

        // Beginner-Friendly section
        _buildSupersetSection(
          title: context.l10n.beginnerFriendly,
          icon: AppIcons.school,
          provider: beginnerSupersetTemplatesProvider,
        ),

        const SizedBox(height: 24),

        // Advanced section
        _buildSupersetSection(
          title: context.l10n.advanced,
          icon: AppIcons.trophy,
          provider: advancedSupersetTemplatesProvider,
        ),

        const SizedBox(height: 24),

        // All Templates section
        _buildSupersetSection(
          title: context.l10n.allTemplates,
          icon: AppIcons.list,
          provider: allSupersetTemplatesProvider,
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSupersetSection({
    required String title,
    required IconData icon,
    required FutureProvider<List<SupersetTemplate>> provider,
  }) {
    final templatesAsync = ref.watch(provider);

    return templatesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (templates) {
        if (templates.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: AppIconSize.medium,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${templates.length}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Horizontal scroll
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
                          source: 'workout_templates',
                          onUseTemplate: () {
                            // TODO: Implement use template action
                            SnackBarService.showInfo(
                              context,
                              'Template "${template.name}" selected',
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTemplatesList(List<WorkoutTemplate> templates) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.searchOff,
              semanticLabel: 'Search off',
              size: AppIconSize.medium,
              color: context.colors.surfaceContainerHighest,
            ),
            const SizedBox(height: 16),
            Text(context.l10n.workoutTemplateNoneFound),
          ],
        ),
      );
    }

    // 🚀 OPTIMIZATION: Batch load all template stats in one pass
    // Instead of N provider calls (one per card), we make 1 call
    final allStatsAsync = ref.watch(allTemplateStatsProvider);
    final allStats = allStatsAsync.value ?? {};

    // Vertical ListView with fixed 200px item height for performance
    return ListView.builder(
      itemCount: templates.length,
      itemExtent: 216, // 200px card + 16px margin (8px top + 8px bottom)
      itemBuilder: (context, index) {
        final template = templates[index];
        return SwipeableTemplateCard(
          template: template,
          onTap: () => _showStartWorkoutConfirmation(template),
          onShare: () => _shareTemplate(template),
          onDuplicate: () => _duplicateTemplate(template),
          onEdit: () => _editTemplate(template),
          onDelete: () => _deleteTemplate(template),
          onRefresh: template.isCustom
              ? () => _refreshTemplate(template)
              : null,
          onView: () => _viewTemplate(template),
          preloadedStats: allStats[template.id], // Pass pre-calculated stats
        );
      },
    );
  }

  /// Navigate to template view screen (presentation mode)
  void _viewTemplate(WorkoutTemplate template) {
    context.push('/templates/detail', extra: template.id);
  }

  void _shareTemplate(WorkoutTemplate template) {
    // TODO: Implement template sharing functionality
    SnackBarService.showInfo(
      context,
      context.l10n.workoutTemplateSharingComingSoon,
    );
  }

  /// ⌚ Refresh template from exercise database to sync TUT and other fields
  Future<void> _refreshTemplate(WorkoutTemplate template) async {
    try {
      final updatedCount = await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .refreshTemplateFromDatabase(template);

      if (mounted) {
        if (updatedCount > 0) {
          // Invalidate providers to refresh UI
          ref.invalidate(customWorkoutTemplatesProvider);
          ref.invalidate(allWorkoutTemplatesProvider);

          SnackBarService.showSuccess(
            context,
            context.l10n.refreshFromDatabaseSuccess(updatedCount),
          );
        } else {
          SnackBarService.showInfo(
            context,
            context.l10n.refreshFromDatabaseNoUpdates,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'Errore: $e');
      }
    }
  }

  void _duplicateTemplate(WorkoutTemplate template) async {
    try {
      // Create a duplicate with "(Copia)" suffix
      final duplicatedTemplate = template.copyWith(
        name: '${template.name} (Copia)',
        isCustom: true,
        updatedAt: DateTime.now(),
      );

      // Save to legacy repository
      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .saveTemplate(duplicatedTemplate);

      // Invalidate providers to refresh list
      ref.invalidate(customWorkoutTemplatesProvider);

      if (mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.workoutTemplateDuplicatedSuccess(
            duplicatedTemplate.name,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.workoutTemplateDuplicationError(e.toString()),
        );
      }
    }
  }

  void _showCreateTemplateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.createTemplate,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(AppIcons.edit, color: context.colors.primary),
              title: Text(context.l10n.createManually),
              subtitle: Text(context.l10n.buildFromScratch),
              onTap: () {
                Navigator.pop(context);
                _showCreateTemplateModalOriginal(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTemplateModalOriginal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateTemplateModal(),
    );
  }

  void _showStartWorkoutConfirmation(WorkoutTemplate template) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.startWorkout),
        content: Text('${l10n.startWorkout} "${template.name}"?'),
        actions: [
          Semantics(
            label: l10n.cancel,
            button: true,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ),
          Semantics(
            label: l10n.startWorkout,
            button: true,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _startWorkoutFromTemplate(template);
              },
              child: Text(l10n.startWorkout),
            ),
          ),
        ],
      ),
    );
  }

  void _startWorkoutFromTemplate(WorkoutTemplate template) async {
    final l10n = context.l10n;

    try {
      // LEGACY SYSTEM: Incrementa contatore utilizzo
      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .incrementUsage(template.id);

      // Crea workout dal template con templateId per tracciare durata media
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
      workoutNotifier.createWorkout(template.name, templateId: template.id);

      // ⚠️ BUG FIX: Get exercises BEFORE weight recovery dialog
      // so they can be used for weight application
      var exercises = template.toWorkoutExercises();

      // 🎯 WEIGHT RECOVERY: Recupera workout precedente e chiedi se applicare i pesi
      WeightRecoveryOption? selectedOption;
      try {
        final recoveryData = await ref.read(
          weightRecoveryDataProvider(template.id).future,
        );

        if (recoveryData.hasData &&
            recoveryData.previousWorkout != null &&
            mounted) {
          // Mostra dialog di recupero pesi
          selectedOption = await WeightRecoveryDialog.show(
            context,
            recoveryData.previousWorkout!,
            recoveryData.lastSessionDate!,
            recoveryData.daysSinceLastSession,
          );
        }

        // 📊 APPLY WEIGHTS: Se l'utente ha scelto un'opzione, applica i pesi
        final currentWorkout = ref.read(currentWorkoutProvider);
        if (selectedOption != null &&
            selectedOption != WeightRecoveryOption.none &&
            currentWorkout != null &&
            recoveryData.hasData &&
            recoveryData.previousWorkout != null) {
          final multiplier = _getWeightMultiplier(selectedOption);

          // Crea un workout temporaneo con gli esercizi
          final tempWorkout = currentWorkout.copyWith(exercises: exercises);

          // Applica i pesi usando il servizio
          final workoutWithWeights = WeightRecoveryService.applyPreviousWeights(
            currentWorkout: tempWorkout,
            previousWorkout: recoveryData.previousWorkout!,
            multiplier: multiplier,
          );

          // Aggiorna gli esercizi con i pesi applicati
          exercises = workoutWithWeights.exercises;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Errore nel recupero workout precedente: $e');
        }
        // Continua comunque senza recupero pesi
      }

      // ⚠️ BUG FIX: Add exercises BEFORE startWorkout
      // so Watch notification has exercise data
      for (final exercise in exercises) {
        workoutNotifier.addExercise(exercise);
      }

      // Now start workout (with exercises already loaded)
      workoutNotifier.startWorkout();

      // 🔧 FIX: Naviga PRIMA alla schermata workout
      // Così l'utente vede subito il risultato
      if (mounted) {
        context.go('/workout');
      }

      // Mostra messaggio di successo DOPO la navigazione
      // 🔧 FIX: Usa showSuccess semplice invece di showCustom con action ridondante
      // Il pulsante "Visualizza Dettagli" era inutile perché si naviga già a /workout
      if (mounted) {
        SnackBarService.showSuccess(
          context,
          l10n.workoutStarted(template.name),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          'Errore nell\'avvio del workout: $e',
        );
      }
    }
  }

  double _getWeightMultiplier(WeightRecoveryOption option) {
    switch (option) {
      case WeightRecoveryOption.increase:
        return 1.025; // +2.5%
      case WeightRecoveryOption.exact:
        return 1.0;
      case WeightRecoveryOption.decrease:
        return 0.975; // -2.5%
      case WeightRecoveryOption.none:
        return 1.0;
    }
  }

  void _editTemplate(WorkoutTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTemplateScreen(template: template),
      ),
    );
  }

  void _deleteTemplate(WorkoutTemplate template) {
    // 🔧 FIX: Salva il root context PRIMA di aprire dialogs
    // per evitare problemi con context invalidati dopo il pop
    final rootContext = context;
    final rootNavigator = Navigator.of(rootContext, rootNavigator: true);

    showDialog(
      context: rootContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.workoutTemplateDeleteTitle),
        content: Text(
          dialogContext.l10n.workoutTemplateDeleteConfirm(template.name),
        ),
        actions: [
          Semantics(
            label: dialogContext.l10n.workoutTemplateCancel,
            button: true,
            child: TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogContext.l10n.workoutTemplateCancel),
            ),
          ),
          Semantics(
            label: context.l10n.delete,
            button: true,
            child: FilledButton(
            onPressed: () async {
              // Chiudi il dialog di conferma
              Navigator.of(dialogContext).pop();

              // Show loading indicator usando il rootNavigator
              // ignore: unawaited_futures - dialog intenzionalmente non awaited
              unawaited(
                showDialog(
                  context: rootContext,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: LoadingIndicator()),
                ),
              );

              try {
                SecureLogger.info(
                  'Starting template deletion',
                  metadata: {
                    'templateId': SecureLogger.partialRedact(template.id),
                    'templateName': template.name,
                  },
                );

                // Delete using workoutTemplateNotifierProvider (handles all repositories)
                await ref
                    .read(workoutTemplateNotifierProvider.notifier)
                    .deleteTemplate(template.id);
                SecureLogger.success('Template deleted successfully');

                // Invalidate providers to refresh UI
                SecureLogger.info('Invalidating all template providers');
                ref.invalidate(customWorkoutTemplatesProvider);
                ref.invalidate(allWorkoutTemplatesProvider);
                ref.invalidate(popularTemplatesProvider);
                ref.invalidate(templateSearchResultsProvider);
                ref.invalidate(filteredTemplatesProvider);

                // Also invalidate the notifier provider to force reload
                ref.invalidate(workoutTemplateNotifierProvider);

                // Wait a moment for invalidation to propagate
                await Future.delayed(const Duration(milliseconds: 100));

                // Force refresh the providers
                try {
                  // ignore: unused_result
                  await ref.refresh(customWorkoutTemplatesProvider.future);
                } catch (e) {
                  SecureLogger.warning(
                    'Error refreshing providers',
                    metadata: {'error': e.toString()},
                  );
                }

                SecureLogger.success(
                  'Template deletion completed successfully',
                );

                // 🔧 FIX: Dismiss loading usando rootNavigator
                if (rootNavigator.canPop()) {
                  rootNavigator.pop();
                }

                // Show success message
                if (rootContext.mounted) {
                  SnackBarService.showSuccess(
                    rootContext,
                    '✅ Template "${template.name}" eliminato',
                  );
                }
              } catch (e) {
                SecureLogger.error('Error deleting template', error: e);

                // 🔧 FIX: Dismiss loading usando rootNavigator
                if (rootNavigator.canPop()) {
                  rootNavigator.pop();
                }

                // Show error message
                if (rootContext.mounted) {
                  SnackBarService.showError(
                    rootContext,
                    'Errore nell\'eliminazione: $e',
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: dialogContext.colors.error,
            ),
            child: Text(context.l10n.delete),
            ),
          ),
        ],
      ),
    );
  }

  void _showSyncInfo(BuildContext context, String syncStatus) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final firebaseState = ref.watch(firebaseTemplateNotifierProvider);

          return AlertDialog(
            title: Row(
              children: [
                const SemanticIcon(
                  icon: AppIcons.cloud,
                  semanticLabel: 'Cloud',
                ),
                const SizedBox(width: 8),
                Text(context.l10n.workoutTemplateSyncStatus),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${context.l10n.status}: $syncStatus'),
                const SizedBox(height: 8),
                if (firebaseState.lastSyncTime != null) ...[
                  Text(
                    '${context.l10n.lastSync}: ${_formatDateTime(firebaseState.lastSyncTime!)}',
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '${context.l10n.totalTemplates}: ${firebaseState.templates.length}',
                ),
                if (firebaseState.hasOfflineChanges) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.offlineChangesMessage,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.secondary,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              Semantics(
                label: context.l10n.close,
                button: true,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.close),
                ),
              ),
              if (FirebaseAuth.instance.currentUser != null &&
                  !firebaseState.isSyncing)
                Semantics(
                  label: context.l10n.syncNow,
                  button: true,
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref
                          .read(firebaseTemplateNotifierProvider.notifier)
                          .forcSync();

                      if (!context.mounted) return;
                      SnackBarService.showSuccess(
                        context,
                        context.l10n.syncCompleted,
                      );
                    },
                    child: Text(context.l10n.syncNow),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
