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
import 'package:gymbro_flutter_new/shared/presentation/widgets/debug_screen_name_overlay.dart';
import 'package:flutter/foundation.dart';
// GDPR Consent Management
import 'package:gymbro_flutter_new/shared/domain/privacy/privacy_manager.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/privacy/consent_dialog.dart';
// Secure Logging
import 'package:gymbro_flutter_new/shared/utils/secure_logger.dart';

class WorkoutTemplatesScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  ConsumerState<WorkoutTemplatesScreen> createState() => _WorkoutTemplatesScreenState();
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
    _tabController = TabController(length: 3, vsync: this);
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

    return DebugScreenNameOverlay(
      screenName: 'WorkoutTemplatesScreen',
      child: Scaffold(
          appBar: AppBar(
          title: Text(l10n.workoutTemplates),
          centerTitle: true,
          leading: Semantics(
            label: l10n.back,
            button: true,
            hint: l10n.backHint,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
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
                final user = ref.watch(authStateProvider).value;
                if (user != null) {
                  final syncStatus = ref.watch(syncStatusProvider);
                  final firebaseState = ref.watch(firebaseTemplateNotifierProvider);
                
                return Semantics(
                  label: l10n.syncStatus,
                  button: true,
                  hint: l10n.syncStatusHint,
                  child: IconButton(
                    focusNode: _syncButtonFocusNode,
                    icon: Stack(
                      children: [
                        const Icon(Icons.cloud),
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
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateTemplateModal(context),
              tooltip: l10n.createTemplate,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.allExercises.replaceAll(' Exercises', ''), icon: const Icon(Icons.list)),
            Tab(text: l10n.popularTemplates, icon: const Icon(Icons.trending_up)),
            Tab(text: l10n.myTemplates, icon: const Icon(Icons.person)),
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
            color: Colors.red.withValues(alpha: 0.3),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 16),
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
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Cerca template...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                Icon(Icons.trending_up, size: 64, color: Colors.grey),
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
                const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
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
                  icon: const Icon(Icons.add),
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
            Icon(Icons.search_off, size: 64, color: Colors.grey),
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
              leading: Icon(Icons.edit, color: context.colors.primary),
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
                SecureLogger.info('Starting template deletion', metadata: {
                  'templateId': SecureLogger.partialRedact(template.id),
                  'templateName': template.name,
                });

                // Step 1: Delete from unified repository (handles all sources)
                final unifiedRepository = ref.read(unifiedTemplateRepositoryProvider);
                await unifiedRepository.deleteTemplate(template.id);
                SecureLogger.success('Deleted from unified repository');

                // Step 2: Try to delete from legacy repository as well (for safety)
                try {
                  final legacyRepository = ref.read(workoutTemplateRepositoryProvider);
                  await legacyRepository.deleteTemplate(template.id);
                  SecureLogger.success('Deleted from legacy repository');
                } catch (e) {
                  SecureLogger.info('Not in legacy repository (expected for new templates)');
                }

                // Step 3: Try to delete from hybrid repository (for newer templates)
                try {
                  final hybridRepository = ref.read(hybridTemplateRepositoryProvider);
                  await hybridRepository.deleteTemplate(template.id);
                  SecureLogger.success('Deleted from hybrid repository');
                } catch (e) {
                  SecureLogger.info('Not in hybrid repository');
                }

                // Step 4: Invalidate ALL providers and wait for refresh
                SecureLogger.info('Invalidating all template providers');

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
                  SecureLogger.warning('Error refreshing providers', metadata: {'error': e.toString()});
                }

                SecureLogger.success('Template deletion completed successfully');

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
                SecureLogger.error('Error deleting template', error: e);

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
                Icon(Icons.cloud),
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
}