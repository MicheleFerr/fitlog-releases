import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/services/exercise_matching_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/exercise_selection_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/firebase_template_provider.dart';
// UNIFIED SYSTEM IMPORT
import 'package:gymbro_flutter_new/shared/domain/entities/template_bridge.dart' hide ExerciseTemplate, SetTemplate;
import 'package:gymbro_flutter_new/shared/data/repositories/unified_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/template_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/create_template_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/edit_template_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/weight_recovery_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/previous_workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/weight_recovery_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart' hide syncStatusProvider;
import 'package:gymbro_flutter_new/shared/presentation/widgets/adaptive_banner_ad.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class WorkoutTemplatesScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  ConsumerState<WorkoutTemplatesScreen> createState() => _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState extends ConsumerState<WorkoutTemplatesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutTemplates),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(AppIcons.back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          // Indicatore stato sync
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(authStateProvider).value;
              if (user != null) {
                final syncStatus = ref.watch(syncStatusProvider);
                final firebaseState = ref.watch(firebaseTemplateNotifierProvider);
                
                return IconButton(
                  icon: Stack(
                    children: [
                      const Icon(AppIcons.cloud),
                      if (firebaseState.isSyncing)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
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
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => _showSyncInfo(context, syncStatus),
                  tooltip: syncStatus,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(AppIcons.add),
            onPressed: () => _showCreateTemplateModal(context),
            tooltip: 'Crea Template',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.allExercises.replaceAll(' Exercises', ''), icon: const Icon(AppIcons.list)),
            Tab(text: l10n.popularTemplates, icon: const Icon(AppIcons.trendUp)),
            Tab(text: l10n.myTemplates, icon: const Icon(AppIcons.person)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔵 DEBUG BANNER - SCHERMATA CORRENTE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: const Text(
              '🔵 WORKOUT TEMPLATES LIST SCREEN (principale)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // DEBUG BANNER per identificare la schermata
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.red.withOpacity(0.3),
            child: Row(
              children: [
                const Icon(AppIcons.warning, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '❌ WorkoutTemplatesScreen - Qui NON VEDO i miei template',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final templates = ref.watch(customWorkoutTemplatesProvider);
                    return templates.when(
                      data: (data) => Text(
                        'Templates: ${data.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
          ),
          // Barra di ricerca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca template...',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(templateSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                _buildPopularTemplatesTab(),
                _buildMyTemplatesTab(),
              ],
            ),
          ),

          // 📱 Banner Ad in fondo
          AdaptiveBannerAd(
            adUnitId: AdMobConfig.bannerSettings,
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildAllTemplatesTab() {
    final searchQuery = ref.watch(templateSearchQueryProvider);

    if (searchQuery.isEmpty) {
      // UNIFIED SYSTEM: Usa il repository unificato
      final unifiedTemplatesAsync = ref.watch(userTemplatesProvider);

      // Converti UnifiedWorkoutTemplate a WorkoutTemplate per compatibilità UI
      final templatesAsync = unifiedTemplatesAsync.when(
        data: (unifiedTemplates) => AsyncValue.data(
          unifiedTemplates.map((unified) => TemplateBridge.toLegacy(unified)).toList()
        ),
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
      
      return templatesAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(AppIcons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Errore: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(allWorkoutTemplatesProvider),
                child: const Text('Riprova'),
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
        error: (error, stack) => Center(child: Text('Errore: $error')),
        data: (templates) => _buildTemplatesList(templates),
      );
    }
  }

  Widget _buildPopularTemplatesTab() {
    // UNIFIED SYSTEM: Per ora usa template pubblici, in futuro implementare ordinamento per popolarità
    final unifiedTemplatesAsync = ref.watch(publicTemplatesProvider(
      const PublicTemplateQuery(limit: 20)
    ));

    final popularTemplatesAsync = unifiedTemplatesAsync.when(
      data: (unifiedTemplates) => AsyncValue.data(
        unifiedTemplates
            .map((unified) => TemplateBridge.toLegacy(unified))
            .toList()
      ),
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
    
    return popularTemplatesAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(child: Text('Errore: $error')),
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.trendUp, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nessun template popolare ancora'),
                SizedBox(height: 8),
                Text(
                  'I template più utilizzati appariranno qui',
                  style: TextStyle(color: Colors.grey),
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

    debugPrint('🔍 MyTemplatesTab - Using customWorkoutTemplatesProvider (same as WorkoutScreen)');

    // Non serve più convertire da UnifiedWorkoutTemplate perché customWorkoutTemplatesProvider
    // restituisce già WorkoutTemplate
    
    return customTemplatesAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(child: Text('Errore: $error')),
      data: (templates) {
        debugPrint('🔍 MyTemplatesTab - Got ${templates.length} templates from customWorkoutTemplatesProvider');
        for (final template in templates) {
          debugPrint('  - ${template.name}: isCustom=${template.isCustom}, id=${template.id}');
        }

        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.workout, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Nessun template personalizzato'),
                const SizedBox(height: 8),
                const Text(
                  'Crea il tuo primo template personalizzato',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showCreateTemplateModal(context),
                  icon: const Icon(AppIcons.add),
                  label: const Text('Crea Template'),
                ),
              ],
            ),
          );
        }
        
        return _buildTemplatesList(templates);
      },
    );
  }

  Widget _buildTemplatesList(List<WorkoutTemplate> templates) {
    if (templates.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.searchOff, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nessun template trovato'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TemplateCard(
            template: template,
            onTap: () => _showStartWorkoutConfirmation(template),
            onEdit: template.isCustom ? () => _editTemplate(template) : null,
            onDelete: template.isCustom ? () => _deleteTemplate(template) : null,
          ),
        );
      },
    );
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
            const Divider(),
            ListTile(
              leading: Icon(AppIcons.uploadFile, color: context.colors.secondary),
              title: Text(context.l10n.importFromJSON),
              subtitle: Text(context.l10n.importJSONDescription),
              onTap: () {
                Navigator.pop(context);
                _showJsonImportDialog(context);
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _startWorkoutFromTemplate(template);
            },
            child: Text(l10n.startWorkout),
          ),
        ],
      ),
    );
  }

  void _startWorkoutFromTemplate(WorkoutTemplate template) async {
    final l10n = context.l10n;

    try {
      // UNIFIED SYSTEM: Incrementa contatore utilizzo usando repository unificato
      final unifiedRepo = ref.read(unifiedTemplateRepositoryProvider);
      final unifiedTemplate = await unifiedRepo.getTemplateById(template.id);

      if (unifiedTemplate != null) {
        final updatedTemplate = unifiedTemplate.copyWith(
          useCount: unifiedTemplate.useCount + 1,
          version: (unifiedTemplate.version ?? 0) + 1,
        );
        await unifiedRepo.updateTemplate(updatedTemplate);
      }

      // Crea workout dal template con templateId
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
      workoutNotifier.createWorkout(template.name);

      // Aggiungi templateId al workout
      final currentWorkout = ref.read(currentWorkoutProvider);
      if (currentWorkout != null) {
        final workoutWithTemplateId = currentWorkout.copyWith(templateId: template.id);
        // Aggiorna il provider con il workout modificato
        await ref.read(workoutRepositoryProvider).updateWorkout(workoutWithTemplateId);
      }

      workoutNotifier.startWorkout();

      // 🎯 WEIGHT RECOVERY: Recupera workout precedente e chiedi se applicare i pesi
      WeightRecoveryOption? selectedOption;
      try {
        final recoveryData = await ref.read(weightRecoveryDataProvider(template.id).future);

        if (recoveryData.hasData && recoveryData.previousWorkout != null && mounted) {
          // Mostra dialog di recupero pesi
          selectedOption = await WeightRecoveryDialog.show(
            context,
            recoveryData.previousWorkout!,
            recoveryData.lastSessionDate!,
            recoveryData.daysSinceLastSession,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Errore nel recupero workout precedente: $e');
        }
        // Continua comunque senza recupero pesi
      }

      // Aggiungi esercizi dal template
      var exercises = template.toWorkoutExercises();

      // 📊 APPLY WEIGHTS: Se l'utente ha scelto un'opzione, applica i pesi
      if (selectedOption != null &&
          selectedOption != WeightRecoveryOption.none &&
          currentWorkout != null) {
        try {
          final recoveryData = await ref.read(weightRecoveryDataProvider(template.id).future);
          if (recoveryData.hasData && recoveryData.previousWorkout != null) {
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
            debugPrint('⚠️ Errore nell\'applicazione pesi: $e');
          }
          // Continua con esercizi originali
        }
      }

      // Aggiungi gli esercizi (con o senza pesi applicati)
      for (final exercise in exercises) {
        workoutNotifier.addExercise(exercise);
      }

      // Mostra messaggio di successo
      if (mounted) {
        SnackBarService.showCustom(
          context,
          message: '✅ ${l10n.startWorkout} "${template.name}"!',
          backgroundColor: Colors.green,
          actionLabel: l10n.viewDetails,
          onAction: () => context.go('/workout'),
        );
      }

      // Vai alla schermata workout
      if (mounted) {
        context.go('/workout');
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Template'),
        content: Text('Sei sicuro di voler eliminare "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: LoadingIndicator(),
                ),
              );

              try {
                debugPrint('🗑️ Starting deletion for template: ${template.id} - ${template.name}');

                // Step 1: Delete from unified repository (handles all sources)
                final unifiedRepository = ref.read(unifiedTemplateRepositoryProvider);
                await unifiedRepository.deleteTemplate(template.id);
                debugPrint('✅ Deleted from unified repository');

                // Step 2: Try to delete from legacy repository as well (for safety)
                try {
                  final legacyRepository = ref.read(workoutTemplateRepositoryProvider);
                  await legacyRepository.deleteTemplate(template.id);
                  debugPrint('✅ Deleted from legacy repository');
                } catch (e) {
                  debugPrint('ℹ️ Not in legacy repository (expected for new templates): $e');
                }

                // Step 3: Try to delete from hybrid repository (for newer templates)
                try {
                  final hybridRepository = ref.read(hybridTemplateRepositoryProvider);
                  await hybridRepository.deleteTemplate(template.id);
                  debugPrint('✅ Deleted from hybrid repository');
                } catch (e) {
                  debugPrint('ℹ️ Not in hybrid repository: $e');
                }

                // Step 4: Invalidate ALL providers and wait for refresh
                debugPrint('🔄 Invalidating all template providers...');

                // Invalidate providers
                ref.invalidate(userTemplatesProvider);
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
                  await ref.refresh(customWorkoutTemplatesProvider.future);
                  await ref.refresh(userTemplatesProvider.future);
                } catch (e) {
                  debugPrint('⚠️ Error refreshing providers: $e');
                }

                debugPrint('✅ Template deletion completed successfully');

                // Dismiss loading indicator
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                // Show success message
                if (context.mounted) {
                  SnackBarService.showSuccess(
                    context,
                    '✅ Template "${template.name}" eliminato',
                  );
                }
              } catch (e) {
                debugPrint('❌ Error deleting template: $e');

                // Dismiss loading indicator
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                // Show error message
                if (context.mounted) {
                  SnackBarService.showError(
                    context,
                    'Errore nell\'eliminazione: $e',
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
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
            title: const Row(
              children: [
                Icon(AppIcons.cloud),
                SizedBox(width: 8),
                Text('Stato Sincronizzazione'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: $syncStatus'),
                const SizedBox(height: 8),
                if (firebaseState.lastSyncTime != null) ...[
                  Text('Ultimo sync: ${_formatDateTime(firebaseState.lastSyncTime!)}'),
                  const SizedBox(height: 8),
                ],
                Text('Template totali: ${firebaseState.templates.length}'),
                if (firebaseState.hasOfflineChanges) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Hai modifiche offline che verranno sincronizzate al prossimo accesso.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Chiudi'),
              ),
              if (FirebaseAuth.instance.currentUser != null && !firebaseState.isSyncing)
                FilledButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await ref.read(firebaseTemplateNotifierProvider.notifier).forcSync();

                    SnackBarService.showSuccess(
                      context,
                      '✅ Sincronizzazione completata',
                    );
                  },
                  child: const Text('Sincronizza Ora'),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // JSON Import Methods
  // ═══════════════════════════════════════════════════════════════════════════

  void _showJsonImportDialog(BuildContext context) {
    final l10n = context.l10n;
    final TextEditingController jsonController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    bool isExampleMinimized = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
        title: Text(l10n.importFromJSON),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Guidelines section - Minimizable
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Header with toggle
                      InkWell(
                        onTap: () {
                          setState(() {
                            isExampleMinimized = !isExampleMinimized;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.info,
                                color: context.colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.jsonFormatGuide,
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                              // Copy button
                              IconButton(
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: _getJsonExample()));
                                  if (context.mounted) {
                                    SnackBarService.showSuccess(
                                      context,
                                      '📋 ${l10n.exampleCopied}',
                                    );
                                    // Minimizza automaticamente dopo la copia
                                    setState(() {
                                      isExampleMinimized = true;
                                    });
                                  }
                                },
                                icon: Icon(
                                  AppIcons.iconCopy,
                                  color: context.colors.primary,
                                  size: 18,
                                ),
                                tooltip: l10n.copyExample,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                              // Toggle icon
                              Icon(
                                isExampleMinimized ? AppIcons.expandMore : AppIcons.expandLess,
                                color: context.colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Collapsible content
                      if (!isExampleMinimized) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.jsonFormatDescription,
                                style: context.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  // Solo copia negli appunti, non incolla nel campo
                                  final example = _getJsonExample();
                                  await Clipboard.setData(ClipboardData(text: example));
                                  if (context.mounted) {
                                    SnackBarService.showSuccess(
                                      context,
                                      '📋 ${l10n.exampleCopied}',
                                    );
                                    // Minimizza automaticamente
                                    setState(() {
                                      isExampleMinimized = true;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: context.colors.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: context.colors.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _getJsonExample(),
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                            color: context.colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        AppIcons.copy,
                                        size: 16,
                                        color: context.colors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.tapToCopyToClipboard,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Minimized state - show only brief info
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                          child: Text(
                            l10n.tapToExpandExample,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // JSON input field with dismiss keyboard area
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.pasteJSONHere,
                      style: context.textTheme.labelMedium,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        focusNode.unfocus();
                      },
                      icon: const Icon(AppIcons.keyboardHide, size: 16),
                      label: Text(l10n.hideKeyboard),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: isExampleMinimized ? 300 : 200,
                  child: TextField(
                    controller: jsonController,
                    focusNode: focusNode,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: '{\n  "name": "My Workout",\n  "description": "...",\n  ...\n}',
                      border: const OutlineInputBorder(),
                      suffixIcon: jsonController.text.isNotEmpty 
                        ? IconButton(
                            onPressed: () {
                              jsonController.clear();
                            },
                            icon: const Icon(AppIcons.clear),
                          )
                        : null,
                    ),
                    onChanged: (value) {
                      // Force rebuild to show/hide clear button
                      // We'll use a StatefulBuilder for this
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              focusNode.dispose();
              Navigator.pop(context);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              focusNode.dispose();
              Navigator.pop(context);
              if (jsonController.text.trim().isNotEmpty) {
                await _importFromJson(context, jsonController.text.trim());
              }
            },
            child: Text(l10n.import),
          ),
        ],
        ),
      ),
    );
  }

  // Traccia esercizi personalizzati creati durante l'import
  final Set<String> _customExercisesInCurrentImport = {};

  /// Dialog per permettere all'utente di scegliere cosa fare con un esercizio non trovato
  Future<Map<String, dynamic>?> _showExerciseCreationDialog(BuildContext context, String originalExerciseName) async {
    final l10n = context.l10n;
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exerciseNotFound),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.exerciseNotFoundDescription(originalExerciseName)),
            const SizedBox(height: 16),
            Text(
              l10n.whatWouldYouLikeToDo,
              style: context.textTheme.titleSmall,
            ),
          ],
        ),
        actions: [
          // Opzione 1: Scegli dall'elenco
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final selectedFromDatabase = await _showDatabaseExerciseSelector(context);
              if (selectedFromDatabase != null && context.mounted) {
                Navigator.of(context).pop(selectedFromDatabase);
              }
            },
            icon: const Icon(AppIcons.search),
            label: Text(l10n.chooseFromDatabase),
          ),
          
          // Opzione 2: Crea personalizzato (con limite per utenti free)
          TextButton.icon(
            onPressed: () async {
              // Check premium status and custom exercise limit
              final isPremium = await _checkPremiumStatus();
              final currentCustomCount = _customExercisesInCurrentImport.length;
              
              if (!isPremium && currentCustomCount >= 3) {
                Navigator.pop(context);
                _showPremiumLimitDialog(context);
                return;
              }
              
              Navigator.pop(context);
              final customExercise = await _showCustomExerciseCreationDialog(context, originalExerciseName);
              if (customExercise != null && context.mounted) {
                _customExercisesInCurrentImport.add(customExercise['name'] as String);
                Navigator.of(context).pop(customExercise);
              }
            },
            icon: const Icon(AppIcons.add),
            label: Text(l10n.createCustom),
          ),
          
          // Opzione 3: Usa nome originale
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context, {
                'name': originalExerciseName,
                'category': ExerciseCategory.other,
              });
            },
            icon: const Icon(AppIcons.textFields),
            label: Text(l10n.useOriginalName),
          ),
          
          // Opzione 4: Salta questo esercizio
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.skip),
          ),
        ],
      ),
    );
  }

  /// Gestisce il caso in cui nessun match viene trovato per un esercizio
  void _handleNoMatchFound(BuildContext context, String exerciseName) {
    final l10n = context.l10n;

    // Mostra un avviso discreto all'utente
    SnackBarService.showCustom(
      context,
      message: '⚠️ ${l10n.exerciseNotFoundInDatabase(exerciseName)}',
      backgroundColor: context.colors.secondary,
      duration: const Duration(seconds: 3),
      actionLabel: l10n.ok,
      onAction: () {},
    );
  }

  /// Dialog per selezionare un esercizio dal database
  Future<Map<String, dynamic>?> _showDatabaseExerciseSelector(BuildContext context) async {
    final l10n = context.l10n;
    
    // Carica tutti gli esercizi dal database
    await ExerciseMatchingService.instance.loadExerciseDatabase();
    final service = ExerciseMatchingService.instance;
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectExerciseFromDatabase),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: FutureBuilder<List<dynamic>>(
            future: _getAllExercisesFromDatabase(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingIndicator());
              }
              
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text(l10n.noExercisesInDatabase));
              }
              
              final exercises = snapshot.data!;
              return ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ListTile(
                    title: Text(exercise.nome),
                    subtitle: Text('${exercise.focus} • ${exercise.tipoEsercizio}'),
                    trailing: Text(
                      exercise.difficolta,
                      style: context.textTheme.bodySmall,
                    ),
                    onTap: () {
                      Navigator.pop(context, {
                        'name': exercise.nome,
                        'category': _mapFocusToCategory(exercise.focus),
                        'focus': exercise.focus,
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  /// Dialog per creare un esercizio personalizzato
  Future<Map<String, dynamic>?> _showCustomExerciseCreationDialog(BuildContext context, String originalName) async {
    final l10n = context.l10n;
    final nameController = TextEditingController(text: originalName);
    ExerciseCategory selectedCategory = ExerciseCategory.other;
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.createCustomExercise),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.exerciseName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExerciseCategory>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  labelText: l10n.category,
                  border: const OutlineInputBorder(),
                ),
                items: ExerciseCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryDisplayName(category, l10n)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.customExerciseNote,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(context, {
                    'name': nameController.text.trim(),
                    'category': selectedCategory,
                    'isCustom': true,
                  });
                }
              },
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra dialog limite premium
  void _showPremiumLimitDialog(BuildContext context) {
    final l10n = context.l10n;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.premiumFeature),
        content: Text(l10n.customExerciseLimit),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Naviga verso schermata premium
            },
            child: Text(l10n.upgradeToPremium),
          ),
        ],
      ),
    );
  }

  /// Check se l'utente è premium (placeholder)
  Future<bool> _checkPremiumStatus() async {
    // TODO: Implementare check reale premium status
    // Per ora tutti gli utenti sono considerati free
    return false;
  }

  /// Ottiene tutti gli esercizi dal database
  Future<List<dynamic>> _getAllExercisesFromDatabase() async {
    try {
      final service = ExerciseMatchingService.instance;
      await service.loadExerciseDatabase();
      
      // Accediamo alla lista privata tramite un match vuoto che restituisce tutti
      final allMatches = await service.findMatches('', maxResults: 1000);
      return allMatches.map((match) => match.exercise).toList();
    } catch (e) {
      return [];
    }
  }

  /// Ottiene il nome display per le categorie
  String _getCategoryDisplayName(ExerciseCategory category, dynamic l10n) {
    switch (category) {
      case ExerciseCategory.chest:
        return 'Petto';
      case ExerciseCategory.back:
        return 'Schiena';
      case ExerciseCategory.shoulders:
        return 'Spalle';
      case ExerciseCategory.arms:
        return 'Braccia';
      case ExerciseCategory.legs:
        return 'Gambe';
      case ExerciseCategory.abs:
        return 'Addominali';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.other:
        return 'Altro';
    }
  }

  String _getJsonExample() {
    return '''// LINEE GUIDA JSON / JSON GUIDELINES
// =====================================
// ⚠️ REGOLE IMPORTANTI PER SUPERSET:
// - Ogni esercizio DEVE avere lo stesso numero di set
// - Se hai "3 rounds", crea 3 set per ogni esercizio
// - NON usare auto-duplicazione, scrivi tutti i set esplicitamente

// FORMATO BASE / BASIC FORMAT:
// ----------------------------
// Scheda singola / Single template:
{
  "name": "Nome scheda",
  "description": "Descrizione",
  "exercises": [...]
}

// Schede multiple / Multiple templates:
[
  { "name": "Scheda 1", ... },
  { "name": "Scheda 2", ... }
]

// ESEMPI ESERCIZI / EXERCISE EXAMPLES:
// -------------------------------------

// 1. ESERCIZIO STANDARD / STANDARD EXERCISE:
{
  "exerciseName": "Panca Piana",
  "focus": "petto",
  "restTime": 180,
  "sets": [
    {"targetReps": 8, "targetWeight": 60.0},
    {"targetReps": 8, "targetWeight": 65.0}
  ]
}

// 2. SUPERSET (più esercizi senza riposo):
// ⚠️ IMPORTANTE: Ogni esercizio DEVE avere lo stesso numero di set!
// Se hai "3 rounds", DEVI creare 3 set per ogni esercizio

// Esempio CORRETTO con 3 set per esercizio:
{
  "exerciseName": "Superset Spalle",
  "type": "superset",
  "restTime": 90,
  "exercises": [
    {
      "name": "Alzate Laterali",
      "sets": [
        {"targetReps": 15, "targetWeight": 8},
        {"targetReps": 15, "targetWeight": 8},
        {"targetReps": 12, "targetWeight": 8}
      ]
    },
    {
      "name": "Alzate Frontali",
      "sets": [
        {"targetReps": 15, "targetWeight": 6},
        {"targetReps": 15, "targetWeight": 6},
        {"targetReps": 12, "targetWeight": 6}
      ]
    }
  ]
}

// Per "3 rounds" - CREA SEMPRE 3 set espliciti:
{
  "exerciseName": "Superset Finale",
  "type": "superset",
  "restTime": 45,
  "notes": "3 rounds totali",
  "exercises": [
    {
      "name": "Curl Martello",
      "sets": [
        {"targetReps": 10, "targetWeight": 8},
        {"targetReps": 10, "targetWeight": 8},
        {"targetReps": 10, "targetWeight": 8}
      ]
    },
    {
      "name": "Diamond Pushup",
      "sets": [
        {"targetReps": 15}, // Senza peso = corpo libero
        {"targetReps": 15},
        {"targetReps": 15}
      ]
    }
  ]
}

// Per max ripetizioni (inserisci 0 reps con note "max"):
{
  "exerciseName": "Superset Burnout",
  "type": "superset",
  "restTime": 60,
  "exercises": [
    {
      "name": "Push Up",
      "sets": [
        {"targetReps": 0, "notes": "max reps"},
        {"targetReps": 0, "notes": "max reps"}
      ]
    },
    {
      "name": "Dips",
      "sets": [
        {"targetReps": 0, "notes": "max reps"},
        {"targetReps": 0, "notes": "max reps"}
      ]
    }
  ]
}

// 3. ESERCIZIO CORPO LIBERO / BODYWEIGHT:
{
  "exerciseName": "Trazioni",
  "focus": "dorso",
  "restTime": 120,
  "sets": [
    {"targetReps": 8, "targetWeight": 0}, // peso 0 = corpo libero
    {"targetReps": 6, "targetWeight": 0}
  ]
}

// ESEMPIO COMPLETO / COMPLETE EXAMPLE:
{
  "name": "Push Workout",
  "description": "Petto, spalle e tricipiti",
  "estimatedDuration": 60,
  "exercises": [
    {
      "exerciseName": "Panca Piana",
      "focus": "petto",
      "restTime": 180,
      "sets": [
        {"targetReps": 8, "targetWeight": 60},
        {"targetReps": 8, "targetWeight": 65},
        {"targetReps": 6, "targetWeight": 70}
      ]
    },
    {
      "exerciseName": "Superset Finale",
      "type": "superset",
      "restTime": 60,
      "notes": "3 rounds totali",
      "exercises": [
        {
          "name": "Pushdown Cavi",
          "sets": [
            {"targetReps": 15, "targetWeight": 20},
            {"targetReps": 15, "targetWeight": 20},
            {"targetReps": 15, "targetWeight": 20}
          ]
        },
        {
          "name": "Dips",
          "sets": [
            {"targetReps": 10},
            {"targetReps": 10},
            {"targetReps": 10}
          ]
        }
      ]
    }
  ]
}''';
  }

  Future<void> _importFromJson(BuildContext context, String jsonString) async {
    final l10n = context.l10n;
    
    
    try {
      // Parse JSON
      final dynamic parsedJson = json.decode(jsonString);
      
      Map<String, dynamic> jsonData;
      
      if (parsedJson is List) {
        
        // Check if it's a list of templates (objects with name and exercises)
        // or a list of exercises (objects with exerciseName or sets)
        bool isListOfTemplates = false;
        if (parsedJson.isNotEmpty && parsedJson.first is Map<String, dynamic>) {
          final firstItem = parsedJson.first as Map<String, dynamic>;
          // If it has 'name' and 'exercises' fields, it's likely a template
          if (firstItem.containsKey('name') && firstItem.containsKey('exercises')) {
            isListOfTemplates = true;
          }
        }
        
        if (isListOfTemplates) {
          // It's a list of templates - show selection dialog
          await _handleMultipleTemplatesJson(context, parsedJson);
          return;
        } else {
          // It's a list of exercises - wrap as single template
          jsonData = {
            'name': l10n.importedTemplate,
            'description': l10n.importedFromProgram('JSON'),
            'exercises': parsedJson,
          };
        }
      } else if (parsedJson is Map<String, dynamic>) {
        jsonData = parsedJson;
      } else {
        throw Exception('Invalid JSON format: expected Map or List but got ${parsedJson.runtimeType}');
      }
      
      
      // Check JSON structure type
      if (jsonData.containsKey('days')) {
        
        if (jsonData['days'] is List) {
          // Program format with multiple days - let user choose
          await _handleProgramFormatJson(context, jsonData);
          return;
        } else {
        }
      }
      
      // Single template format
      await _handleSingleTemplateJson(context, jsonData);
      
    } catch (e) {

      if (context.mounted) {
        SnackBarService.showError(
          context,
          l10n.errorImportingJSON(e.toString()),
        );
      }
    }
  }

  Future<void> _handleMultipleTemplatesJson(BuildContext context, List templates) async {
    final l10n = context.l10n;
    
    if (templates.isEmpty) {
      throw Exception('No templates found');
    }
    
    // Show template selection dialog
    final selectedTemplateIndex = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.selectDayToImport),  // Reuse existing string
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text('${l10n.templates}: ${templates.length}'),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: templates.asMap().entries.map((entry) {
                      final index = entry.key;
                      
                      // Safely cast template to Map
                      if (entry.value is! Map<String, dynamic>) {
                        return const SizedBox.shrink();
                      }
                      
                      final template = entry.value as Map<String, dynamic>;
                      final templateName = template['name'] as String? ?? 'Template ${index + 1}';
                      final templateDescription = template['description'] as String? ?? '';
                      final dynamic exercisesRaw = template['exercises'];
                      final exerciseCount = exercisesRaw is List ? exercisesRaw.length : 0;
                      final estimatedDuration = template['estimatedDuration'] as int? ?? 0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(dialogContext).colorScheme.primary,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(dialogContext).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          title: Text(templateName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (templateDescription.isNotEmpty)
                                Text(templateDescription),
                              Text('${l10n.exercises}: $exerciseCount'),
                              if (estimatedDuration > 0)
                                Text('${l10n.duration}: $estimatedDuration min'),
                            ],
                          ),
                          trailing: Icon(
                            AppIcons.workout,
                            color: Theme.of(dialogContext).colorScheme.primary,
                          ),
                          onTap: () {
                            Navigator.of(dialogContext).pop(index);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    
    
    if (selectedTemplateIndex != null) {
      
      // Safely get selected template
      if (templates[selectedTemplateIndex] is! Map<String, dynamic>) {
        throw Exception('Invalid template data format');
      }
      final selectedTemplate = templates[selectedTemplateIndex] as Map<String, dynamic>;
      
      
      // Process the selected template
      try {
        await _handleSingleTemplateJson(context, selectedTemplate);
      } catch (e) {
        if (context.mounted) {
          SnackBarService.showError(
            context,
            l10n.errorImportingJSON(e.toString()),
          );
        }
      }
    } else {
    }
  }

  Future<void> _handleProgramFormatJson(BuildContext context, Map<String, dynamic> jsonData) async {
    final l10n = context.l10n;
    
    // Safely extract days
    final dynamic daysRaw = jsonData['days'];
    
    if (daysRaw is! List) {
      throw Exception('Invalid days format: expected List but got ${daysRaw.runtimeType}');
    }
    
    final List days = daysRaw;
    
    final programName = jsonData['programName'] as String? ?? l10n.importedProgram;
    
    if (days.isEmpty) {
      throw Exception(l10n.noDaysFoundInProgram);
    }
    
    // Show day selection dialog - Back to simple showDialog approach
    final selectedDayIndex = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.selectDayToImport),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text(l10n.programFoundWithDays(programName, days.length)),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: days.asMap().entries.map((entry) {
                      final index = entry.key;
                      
                      // Safely cast day to Map
                      if (entry.value is! Map<String, dynamic>) {
                        return const SizedBox.shrink();
                      }
                      
                      final day = entry.value as Map<String, dynamic>;
                      final dayName = day['name'] as String? ?? '${l10n.day} ${index + 1}';
                      final dynamic exercisesRaw = day['exercises'];
                      final exerciseCount = exercisesRaw is List ? exercisesRaw.length : 0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(dayName),
                          subtitle: Text(l10n.exercisesCount(exerciseCount)),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext, index);
                            },
                            child: Text(l10n.select),
                          ),
                          onTap: () {
                            Navigator.pop(dialogContext, index);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, null);
            },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    
    
    if (selectedDayIndex != null) {
      
      // Safely cast selected day to Map
      if (days[selectedDayIndex] is! Map<String, dynamic>) {
        throw Exception('Invalid day data format');
      }
      final selectedDay = days[selectedDayIndex] as Map<String, dynamic>;
      final dayName = selectedDay['name'] as String? ?? '${l10n.day} ${selectedDayIndex + 1}';
      
      // Create template data for selected day
      final templateData = {
        'name': '$programName - $dayName',
        'description': selectedDay['description'] as String? ?? l10n.importedFromProgram(programName),
        'exercises': selectedDay['exercises'] ?? [],
      };
      
      final exercisesForCount = templateData['exercises'];
      
      // Proceed even if context is not mounted - we have all the data we need
      try {
        await _handleSingleTemplateJson(context, templateData);
      } catch (e) {
        // Try to show error to user if context is available
        if (context.mounted) {
          SnackBarService.showError(
            context,
            'Errore durante l\'importazione: $e',
          );
        }
      }
    } else {
    }
  }

  Future<void> _handleSingleTemplateJson(BuildContext context, Map<String, dynamic> jsonData) async {
    
    // Try to get l10n, but provide fallbacks if context is not mounted
    AppLocalizations? l10n;
    try {
      if (context.mounted) {
        l10n = AppLocalizations.of(context);
      }
    } catch (e) {
    }
    
    // Use fallback strings if l10n is not available
    final fallbackStrings = {
      'importedTemplate': 'Imported Template',
      'exercise': 'Exercise',
      'noExercisesFoundInJSON': 'No exercises found in JSON',
    };
    
    
    // Extract template info
    String templateName;
    String templateDescription;
    List exercisesData;
    
    try {
      templateName = jsonData['name'] as String? ?? 
                          (l10n?.importedTemplate ?? fallbackStrings['importedTemplate']!);
      
      templateDescription = jsonData['description'] as String? ?? '';
      
      
      // Safely extract exercises data
      final dynamic exercisesRaw = jsonData['exercises'];
      exercisesData = exercisesRaw is List ? exercisesRaw : [];
    } catch (e) {
      rethrow;
    }
    
    
    
    if (exercisesData.isEmpty) {
      throw Exception(l10n?.noExercisesFoundInJSON ?? fallbackStrings['noExercisesFoundInJSON']!);
    }
    
    // Process exercises with intelligent matching
    final List<ExerciseTemplate> processedExercises = [];
    
    int i = 0;
    while (i < exercisesData.length) {
      // Safely cast exercise data to Map
      if (exercisesData[i] is! Map<String, dynamic>) {
        i++;
        continue;
      }
      final exerciseData = exercisesData[i] as Map<String, dynamic>;
      final exerciseName = (exerciseData['exerciseName'] as String?) ?? 
                           (exerciseData['name'] as String?) ?? 
                           '${l10n?.exercise ?? fallbackStrings['exercise']!} ${i + 1}';
      
      // Safely extract sets data
      final dynamic setsRaw = exerciseData['sets'];
      final List setsData = setsRaw is List ? setsRaw : [];
      
      
      // Check if this is a superset indicator
      if (exerciseName.toLowerCase().contains('superset') || 
          exerciseData['type']?.toString().toLowerCase() == 'superset' ||
          exerciseData['exercises'] != null) { // Also check if it has nested exercises
        
        
        // Collect the exercises that are part of this superset
        // Look for the "exercises" field in the superset data
        final dynamic supersetExercisesRaw = exerciseData['exercises'];
        final List? supersetExercises = supersetExercisesRaw is List ? supersetExercisesRaw : null;
        
        if (supersetExercises != null && supersetExercises.isNotEmpty) {
          // The JSON contains the superset exercises directly
          
          // Process each sub-exercise as ExerciseTemplate
          final List<ExerciseTemplate> subExerciseTemplates = [];
          
          // Check if notes mention rounds/circuits to duplicate sets
          final notes = exerciseData['notes'] as String? ?? '';
          int rounds = 1;
          
          // Try to extract rounds from notes (e.g., "Ripeti per 3 rounds", "3x circuits", etc.)
          final roundsMatch = RegExp(r'(\d+)\s*(rounds?|circuits?|volte|giri)', caseSensitive: false).firstMatch(notes);
          if (roundsMatch != null) {
            rounds = int.tryParse(roundsMatch.group(1) ?? '1') ?? 1;
          }
          
          for (final subExercise in supersetExercises) {
            // Safely cast to Map
            if (subExercise is! Map<String, dynamic>) {
              continue;
            }
            final subExerciseData = subExercise;
            final subName = subExerciseData['name'] as String? ?? 
                           subExerciseData['exerciseName'] as String? ?? 'Exercise';
            
            
            // Parse sets for sub-exercise
            final dynamic subSetsRaw = subExerciseData['sets'];
            final List subSets = subSetsRaw is List ? subSetsRaw : [];
            final List<SetTemplate> setTemplates = [];
            
            
            // If sets array is empty but we have rounds, create default sets
            if (subSets.isEmpty && rounds > 1) {
              // Extract default values from subExerciseData if available
              double? defaultWeight;
              final weightValue = subExerciseData['weight'] ?? 
                                 subExerciseData['targetWeight'] ?? 
                                 subExerciseData['kg'];
              if (weightValue != null) {
                defaultWeight = weightValue is num ? weightValue.toDouble() : double.tryParse(weightValue.toString());
                if (defaultWeight == 0) defaultWeight = null; // 0 means bodyweight
              }
              
              int? defaultReps;
              final repsValue = subExerciseData['reps'] ?? 
                               subExerciseData['targetReps'] ?? 
                               subExerciseData['ripetizioni'];
              if (repsValue != null) {
                defaultReps = repsValue is int ? repsValue : int.tryParse(repsValue.toString());
              }
              if (defaultReps == null || defaultReps == 0) {
                defaultReps = 10; // Default to 10 reps if not specified
              }
              
              
              for (int round = 0; round < rounds; round++) {
                setTemplates.add(SetTemplate(
                  setNumber: round + 1,
                  targetWeight: defaultWeight,
                  targetReps: defaultReps,
                ));
              }
            } else if (subSets.length == 1 && rounds > 1) {
              final singleSetData = subSets[0];
              for (int round = 0; round < rounds; round++) {
                if (singleSetData is! Map<String, dynamic>) continue;
                
                // Parse set data
                double? weight;
                final weightValue = singleSetData['targetWeight'] ?? singleSetData['weight'];
                if (weightValue != null) {
                  weight = weightValue is num ? weightValue.toDouble() : double.tryParse(weightValue.toString());
                  if (weight == 0) weight = null;
                }
                
                int? reps;
                final repsValue = singleSetData['targetReps'] ?? singleSetData['reps'];
                final notesValue = singleSetData['notes'] as String?;
                if (repsValue != null) {
                  reps = repsValue is int ? repsValue : int.tryParse(repsValue.toString());
                  // If reps is 0 and notes contain "max", keep it as null (means max reps)
                  if (reps == 0) {
                    if (notesValue?.toLowerCase().contains('max') ?? false) {
                      reps = null; // null means max reps
                    } else {
                      reps = 10; // Default for bodyweight
                    }
                  }
                }
                
                setTemplates.add(SetTemplate(
                  setNumber: round + 1,
                  targetWeight: weight,
                  targetReps: reps,
                  notes: round == 0 ? (singleSetData['notes'] as String?) : null,
                ));
              }
            } else if (subSets.isEmpty) {
              // Handle the case where there are no sets at all
              
              // Try to extract weight and reps from exercise data itself
              double? defaultWeight;
              final weightValue = subExerciseData['weight'] ?? 
                                 subExerciseData['targetWeight'] ?? 
                                 subExerciseData['kg'];
              if (weightValue != null) {
                defaultWeight = weightValue is num ? weightValue.toDouble() : double.tryParse(weightValue.toString());
                if (defaultWeight == 0) defaultWeight = null; // 0 means bodyweight
              }
              
              int? defaultReps;
              final repsValue = subExerciseData['reps'] ?? 
                               subExerciseData['targetReps'] ?? 
                               subExerciseData['ripetizioni'];
              if (repsValue != null) {
                defaultReps = repsValue is int ? repsValue : int.tryParse(repsValue.toString());
              }
              if (defaultReps == null || defaultReps == 0) {
                defaultReps = 10; // Default to 10 reps
              }
              
              // If we have rounds > 1, create multiple sets
              final setsToCreate = rounds > 1 ? rounds : 1;
              
              for (int i = 0; i < setsToCreate; i++) {
                setTemplates.add(SetTemplate(
                  setNumber: i + 1,
                  targetWeight: defaultWeight,
                  targetReps: defaultReps,
                ));
              }
            } else {
              // Process sets normally
              for (int setIndex = 0; setIndex < subSets.length; setIndex++) {
              // Safely cast set data to Map
              if (subSets[setIndex] is! Map<String, dynamic>) {
                continue;
              }
              final setData = subSets[setIndex] as Map<String, dynamic>;
              
              // Parse set data safely
              double? weight;
              final weightValue = setData['targetWeight'] ?? setData['weight'];
              if (weightValue != null) {
                weight = weightValue is num ? weightValue.toDouble() : double.tryParse(weightValue.toString());
                // If weight is 0, treat it as bodyweight (null)
                if (weight == 0) weight = null;
              }
              
              int? reps;
              final repsValue = setData['targetReps'] ?? setData['reps'];
              final notesValue = setData['notes'] as String?;
              if (repsValue != null) {
                reps = repsValue is int ? repsValue : int.tryParse(repsValue.toString());
                // If reps is 0 and notes contain "max", keep it as null (means max reps)
                if (reps == 0) {
                  if (notesValue?.toLowerCase().contains('max') ?? false) {
                    reps = null; // null means max reps
                  } else {
                    reps = 10; // Default for bodyweight exercises
                  }
                }
              }
              
              int? rpe;
              final rpeValue = setData['targetRpe'] ?? setData['rpe'];
              if (rpeValue != null) {
                rpe = rpeValue is int ? rpeValue : int.tryParse(rpeValue.toString());
              }
              
              setTemplates.add(SetTemplate(
                setNumber: setIndex + 1,
                targetWeight: weight,
                targetReps: reps,
                targetRpe: rpe,
                notes: setData['notes'] as String?,
              ));
            }
            }
            
            // Try to match exercise name and get category
            String finalExerciseName = subName;
            ExerciseCategory finalCategory = ExerciseCategory.other;
            
            final exactMatch = await ExerciseMatchingService.instance.findExactMatch(subName);
            if (exactMatch != null) {
              finalExerciseName = exactMatch.nome;
              finalCategory = _mapFocusToCategory(exactMatch.focus);
            } else {
              final matches = await ExerciseMatchingService.instance.findMatches(subName);
              if (matches.isNotEmpty) {
                finalExerciseName = matches.first.exercise.nome;
                finalCategory = _mapFocusToCategory(matches.first.exercise.focus);
              }
            }
            
            // Create sub-exercise template
            subExerciseTemplates.add(ExerciseTemplate(
              exerciseId: const Uuid().v4(),
              exerciseName: finalExerciseName,
              category: finalCategory,
              type: ExerciseType.single,
              sets: setTemplates,
              notes: subExerciseData['notes'] as String?,
              restTime: null, // Sub-exercises don't have individual rest times
            ));
          }
          
          // Parse restTime for the superset
          int? restTime;
          final restTimeValue = exerciseData['restTime'];
          if (restTimeValue != null) {
            restTime = restTimeValue is int ? restTimeValue : int.tryParse(restTimeValue.toString());
          }
          
          // Create superset description
          final supersetDescription = subExerciseTemplates
              .map((e) => e.exerciseName)
              .join(' + ');
          
          // Create sets for the superset based on the number of sets in sub-exercises
          final List<SetTemplate> supersetSets = [];
          if (subExerciseTemplates.isNotEmpty && subExerciseTemplates.first.sets.isNotEmpty) {
            final numSets = subExerciseTemplates.first.sets.length;
            for (int i = 0; i < numSets; i++) {
              supersetSets.add(SetTemplate(
                setNumber: i + 1,
                targetWeight: 0, // Superset doesn't have its own weight
                targetReps: 0,   // Superset doesn't have its own reps
              ));
            }
          }
          
          // Create a single ExerciseTemplate for the superset with sub-exercises
          final supersetTemplate = ExerciseTemplate(
            exerciseId: const Uuid().v4(),
            exerciseName: exerciseName.toLowerCase().contains('superset') 
                ? exerciseName 
                : 'Superset: $supersetDescription',
            category: subExerciseTemplates.isNotEmpty 
                ? subExerciseTemplates.first.category 
                : ExerciseCategory.other,
            type: ExerciseType.superset,
            sets: supersetSets, // Now has sets matching the sub-exercises
            notes: exerciseData['notes'] as String?,
            restTime: restTime,
            subExercises: subExerciseTemplates,
          );
          
          for (var subEx in subExerciseTemplates) {
            for (var set in subEx.sets) {
            }
          }
          
          processedExercises.add(supersetTemplate);
          i++; // Move to next exercise
          continue;
        } else {
          // If no explicit exercises list, treat next exercises as part of superset
          // This is a heuristic approach - look for consecutive exercises
          
          // For now, just process it as a regular exercise with superset type
          // You could implement logic here to group following exercises
        }
      }
      
      // Exercise matching logic
      String finalExerciseName = exerciseName;
      ExerciseCategory finalCategory = ExerciseCategory.other;
      
      // Try to find exact match first
      final exactMatch = await ExerciseMatchingService.instance.findExactMatch(exerciseName);
      if (exactMatch != null) {
        // ✅ MATCH ESATTO TROVATO
        finalExerciseName = exactMatch.nome;
        finalCategory = _mapFocusToCategory(exactMatch.focus);
      } else {
        // ❌ NESSUN MATCH ESATTO - Prova match simili
        final matches = await ExerciseMatchingService.instance.findMatches(exerciseName);
        
        if (matches.isNotEmpty) {
          // 🔄 MATCH SIMILI TROVATI - Usa automaticamente il primo match migliore
          
          if (context.mounted) {
            // Se il context è ancora disponibile, mostra dialog per selezione manuale
            final selectedExercise = await _showExerciseSelectionDialog(context, exerciseName, matches);
            
            if (selectedExercise != null) {
              // ✅ USER HA SELEZIONATO UN MATCH
              finalExerciseName = selectedExercise['name'] as String;
              finalCategory = _mapFocusToCategory(selectedExercise['focus'] as String? ?? '');
            } else {
              // ❌ USER HA ANNULLATO LA SELEZIONE - Usa il primo match automaticamente
              final bestMatch = matches.first;
              finalExerciseName = bestMatch.exercise.nome;
              finalCategory = _mapFocusToCategory(bestMatch.exercise.focus);
            }
          } else {
            // Context non disponibile - usa automaticamente il primo match migliore
            final bestMatch = matches.first;
            finalExerciseName = bestMatch.exercise.nome;
            finalCategory = _mapFocusToCategory(bestMatch.exercise.focus);
          }
        } else {
          // ❌ NESSUN MATCH TROVATO NEL DATABASE
          
          if (context.mounted) {
            // Se il context è disponibile, mostra dialog per creazione manuale
            final userChoice = await _showExerciseCreationDialog(context, exerciseName);
            
            if (userChoice != null) {
              finalExerciseName = userChoice['name'] as String;
              finalCategory = userChoice['category'] as ExerciseCategory;
            } else {
              // Fallback: usa nome originale e inferisce categoria da focus
              finalExerciseName = exerciseName;
              final focus = exerciseData['focus'] as String?;
              if (focus != null && focus.isNotEmpty) {
                finalCategory = _mapFocusToCategory(focus);
              } else {
              }
            }
          } else {
            // Context non disponibile - usa nome originale e inferisce categoria
            finalExerciseName = exerciseName;
            final focus = exerciseData['focus'] as String?;
            if (focus != null && focus.isNotEmpty) {
              finalCategory = _mapFocusToCategory(focus);
            } else {
            }
            
            // Mostra notifica discreta solo se il context è disponibile
            if (context.mounted) {
              _handleNoMatchFound(context, exerciseName);
            }
          }
        }
      }
      
      // Final validation to ensure exercise name is not empty
      if (finalExerciseName.trim().isEmpty) {
        finalExerciseName = exerciseName.isNotEmpty ? exerciseName : 'Esercizio ${i + 1}';
      }
      
      // Convert sets to SetTemplate
      final List<SetTemplate> setTemplates = [];
      
      for (int setIndex = 0; setIndex < setsData.length; setIndex++) {
        // Safely cast set data to Map
        if (setsData[setIndex] is! Map<String, dynamic>) {
          continue;
        }
        final setData = setsData[setIndex] as Map<String, dynamic>;
        
        // Handle different JSON field names for weight and reps
        // Parse weight (can be num or String)
        double? weight;
        final targetWeightValue = setData['targetWeight'];
        final weightValue = setData['weight'];
        if (targetWeightValue != null) {
          weight = targetWeightValue is num ? targetWeightValue.toDouble() : double.tryParse(targetWeightValue.toString());
        } else if (weightValue != null) {
          weight = weightValue is num ? weightValue.toDouble() : double.tryParse(weightValue.toString());
        }
        
        // Parse reps (can be int or String)
        int? reps;
        final targetRepsValue = setData['targetReps'];
        final repsValue = setData['reps'];
        final notesValue = setData['notes'] as String?;
        if (targetRepsValue != null) {
          reps = targetRepsValue is int ? targetRepsValue : int.tryParse(targetRepsValue.toString());
        } else if (repsValue != null) {
          reps = repsValue is int ? repsValue : int.tryParse(repsValue.toString());
        }
        
        // If reps is 0 and notes contain "max", treat as max reps (null)
        if (reps == 0 && (notesValue?.toLowerCase().contains('max') ?? false)) {
          reps = null; // null means max reps
        }
        
        // Parse rpe (can be int or String)
        int? rpe;
        final targetRpeValue = setData['targetRpe'];
        final rpeValue = setData['rpe'];
        if (targetRpeValue != null) {
          rpe = targetRpeValue is int ? targetRpeValue : int.tryParse(targetRpeValue.toString());
        } else if (rpeValue != null) {
          rpe = rpeValue is int ? rpeValue : int.tryParse(rpeValue.toString());
        }
        
        setTemplates.add(SetTemplate(
          setNumber: setIndex + 1,
          targetWeight: weight,
          targetReps: reps,
          targetRpe: rpe,
          notes: setData['notes'] as String?,
        ));
      }
      
      // Create exercise template
      // Parse restTime safely (can be int or String)
      int? restTime;
      final restTimeValue = exerciseData['restTime'];
      if (restTimeValue != null) {
        restTime = restTimeValue is int ? restTimeValue : int.tryParse(restTimeValue.toString());
      }
      
      // Determine exercise type based on name or JSON field
      ExerciseType exerciseType = ExerciseType.single;
      
      // Check if it's a superset based on name or type field
      final typeField = exerciseData['type'] as String?;
      if (typeField != null && typeField.toLowerCase() == 'superset') {
        exerciseType = ExerciseType.superset;
      } else if (exerciseName.toLowerCase().contains('superset')) {
        exerciseType = ExerciseType.superset;
      } else if (exerciseName.toLowerCase().contains('dropset') || 
                 exerciseName.toLowerCase().contains('drop set')) {
        exerciseType = ExerciseType.dropset;
      } else if (exerciseName.toLowerCase().contains('rest pause') || 
                 exerciseName.toLowerCase().contains('rest-pause')) {
        exerciseType = ExerciseType.restPause;
      }
      
      final exerciseTemplate = ExerciseTemplate(
        exerciseId: const Uuid().v4(),
        exerciseName: finalExerciseName,
        category: finalCategory,
        type: exerciseType,
        sets: setTemplates,
        notes: exerciseData['notes'] as String?,
        restTime: restTime,
      );
      
      
      processedExercises.add(exerciseTemplate);
      i++; // Move to next exercise
    }
    
    // Create workout template
    final workoutTemplate = WorkoutTemplate(
      id: const Uuid().v4(),
      name: templateName,
      description: templateDescription,
      exercises: processedExercises,
      createdAt: DateTime.now(),
      isPublic: false, // Private by default
      userId: FirebaseAuth.instance.currentUser?.uid,
    );
    
    
    // Save template with comprehensive error handling
    
    try {
      await ref.read(workoutTemplateNotifierProvider.notifier).saveTemplate(workoutTemplate);
    } catch (e) {
      
      for (int i = 0; i < workoutTemplate.exercises.length; i++) {
        final ex = workoutTemplate.exercises[i];
        if (ex.exerciseId.isEmpty) {
        }
        if (ex.exerciseName.trim().isEmpty) {
        }
      }
      
      // Re-throw the exception to maintain the error flow
      rethrow;
    }
    
    
    // Force refresh of template providers
    try {
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      await Future.delayed(const Duration(milliseconds: 100)); // Small delay for state propagation
    } catch (e) {
    }
    
    // Try to show success message if context is available

    if (context.mounted && l10n != null) {
      try {
        SnackBarService.showSuccess(
          context,
          '✅ ${l10n.templateImportedSuccessfully(templateName)}',
        );
      } catch (e) {
      }
    } else {
    }
    
  }

  Future<Map<String, dynamic>?> _showExerciseSelectionDialog(
    BuildContext context,
    String originalExerciseName,
    List<ExerciseMatch> matches,
  ) async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ExerciseSelectionDialog(
        originalExerciseName: originalExerciseName,
        suggestedMatches: matches,
        onExerciseSelected: (exerciseId, exerciseName) {
          Navigator.pop(context, {
            'id': exerciseId,
            'name': exerciseName,
            'focus': matches.firstWhere((m) => m.exercise.id == exerciseId).exercise.focus,
          });
        },
        onSkipExercise: () => Navigator.pop(context, null),
        onCreateNew: () => Navigator.pop(context, {
          'id': const Uuid().v4(),
          'name': originalExerciseName,
          'focus': '',
        }),
      ),
    );
  }

  ExerciseCategory _mapFocusToCategory(String focus) {
    // Split focus string by comma to create a list (handles both single and multi-muscle)
    final focusList = focus.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    // Use centralized converter for consistent category mapping
    return ExerciseConverter.mapFocusToCategory(focusList);
  }

}
