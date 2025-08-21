import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/workout_template.dart';
import '../providers/workout_template_provider.dart';
import '../providers/firebase_template_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/template_card.dart';
import '../widgets/create_template_modal.dart';
import 'edit_template_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Schede'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTemplateModal(context),
            tooltip: 'Crea Template',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tutti', icon: Icon(Icons.list)),
            Tab(text: 'Popolari', icon: Icon(Icons.trending_up)),
            Tab(text: 'I Miei', icon: Icon(Icons.person)),
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
        ],
      ),
    );
  }

  Widget _buildAllTemplatesTab() {
    final searchQuery = ref.watch(templateSearchQueryProvider);
    
    if (searchQuery.isEmpty) {
      final templatesAsync = ref.watch(allWorkoutTemplatesProvider);
      
      return templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore: $error')),
        data: (templates) => _buildTemplatesList(templates),
      );
    }
  }

  Widget _buildPopularTemplatesTab() {
    final popularTemplatesAsync = ref.watch(popularTemplatesProvider);
    
    return popularTemplatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
    final customTemplatesAsync = ref.watch(customWorkoutTemplatesProvider);
    
    return customTemplatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Errore: $error')), 
      data: (templates) {
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
            onTap: () => _startWorkoutFromTemplate(template),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateTemplateModal(),
    );
  }

  void _startWorkoutFromTemplate(WorkoutTemplate template) async {
    try {
      // Incrementa contatore utilizzo
      await ref.read(workoutTemplateNotifierProvider.notifier).incrementUsage(template.id);
      
      // Crea workout dal template
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
      workoutNotifier.createWorkout(template.name);
      workoutNotifier.startWorkout();
      
      // Aggiungi esercizi dal template
      final exercises = template.toWorkoutExercises();
      for (final exercise in exercises) {
        workoutNotifier.addExercise(exercise);
      }
      
      // Mostra messaggio di successo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout "${template.name}" avviato!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Vai',
            textColor: Colors.white,
            onPressed: () => context.go('/workout'),
          ),
        ),
      );
      
      // Vai alla schermata workout
      context.go('/workout');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nell\'avvio del workout: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
              
              try {
                await ref.read(workoutTemplateNotifierProvider.notifier)
                    .deleteTemplate(template.id);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Template eliminato'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Errore: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
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
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sincronizzazione completata'),
                        backgroundColor: Colors.green,
                      ),
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